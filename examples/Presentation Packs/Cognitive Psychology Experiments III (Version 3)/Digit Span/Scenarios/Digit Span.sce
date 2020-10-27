# -------------------------- Header Parameters --------------------------

scenario = "Digit Span";

write_codes = EXPARAM( "Send ERP Codes" );

default_font_size = EXPARAM( "Default Font Size" );
default_background_color = EXPARAM( "Default Background Color" );
default_text_color = EXPARAM( "Default Font Color" );
default_font = EXPARAM( "Default Font" );

max_y = 100;

active_buttons = 1;
button_codes = 100;
response_matching = simple_matching;

stimulus_properties = 		
	event_cond, string,
	block_number, number,
	test_type, string,
	trial_number, number,
	current_length, number,
	sequence, string,
	resp, string,
	accuracy, string,
	rt, number;
event_code_delimiter = ";";

# ------------------------------- SDL Part ------------------------------
begin;

trial {
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 1;
	
	picture { 
		text { 
			caption = "Instructions";
			preload = false;
		} instruct_text; 
		x = 0; 
		y = 0; 
	} instruct_pic;
} instruct_trial;

trial {
	stimulus_event { 
		picture {
			text { 
				caption = "Main Text";
				font = EXPARAM( "Stimulus Font" );
				font_size = EXPARAM( "Stimulus Font Size" );
				font_color = EXPARAM( "Stimulus Color" );
				preload = false;
			} main_text;
			x = 0;
			y = 0;
		} main_pic; 
	} main_event;
} main_trial;

trial {
	stimulus_event {
		picture {
			text {
				caption = "Response Prompt";
				preload = false;
			} prompt_text;
			x = 0;
			y = 50;
			
			text {
				caption = " ";
			} resp_text;
			x = 0;
			y = 0;
		} resp_pic;
		code = "Prompt";
	} resp_event;
} resp_trial;

trial {
	stimulus_event {
		picture {};
		code = "ISI";
	} ISI_event;
} ISI_trial;

trial {
	stimulus_event {
		picture {
			text { 
				caption = "Ready";
				preload = false;
			} ready_text;
			x = 0;
			y = 0;
		};
		code = "Ready";
	} ready_event;
} ready_trial;

trial {
	picture {};
} wait_trial;

sound {
	wavefile { 
		preload = false;
	} main_wave;
} main_sound;

# ----------------------------- PCL Program -----------------------------
begin_pcl;

include_once "../../Library/lib_visual_utilities.pcl";
include_once "../../Library/lib_utilities.pcl";

# --- CONSTANTS ---

string SPLIT_LABEL = "[SPLIT]";
string LINE_BREAK = "\n";
int BUTTON_FWD = 1;
int BUTTON_BWD = 0;

string PRACTICE_TYPE_PRACTICE = "Practice";
string PRACTICE_TYPE_MAIN = "Main";

string MAIN_EVENT_CODE = "Stim";

string STIM_VISUAL = "Visual";
string STIM_AUDITORY = "Auditory";

string TYPE_STAIRCASE = "Staircase";
string TYPE_FIXED = "Fixed";

string COND_FORWARD = "Forward";
string COND_BACKWARD = "Backward";

int COND_FORWARD_IDX = 1;
int COND_BACKWARD_IDX = 2;

string ACC_CORRECT = "Correct";
string ACC_INCORRECT = "Incorrect";

int MIN_LENGTH = 2;

int TYPE_IDX = 1;
int START_IDX = 2;

int BUTTON_PORT_CODE = 100;
int RECALL_PORT_CODE = 10;

string CHARACTER_WRAP = "Character";

# --- Set up fixed stimulus parameters ---

language_file lang = load_language_file( scenario_directory + parameter_manager.get_string( "Language" ) + ".xml" );
bool char_wrap = ( get_lang_item( lang, "Word Wrap Mode" ).lower() == CHARACTER_WRAP.lower() );

adjust_used_screen_size( parameter_manager.get_bool( "Use Widescreen if Available" ) );

double font_size = parameter_manager.get_double( "Default Font Size" );

# Event setup
resp_trial.set_start_time( parameter_manager.get_int( "Recall Prompt Delay" ) );
trial_refresh_fix( main_trial, parameter_manager.get_int( "Stimulus Duration" ) );
trial_refresh_fix( ISI_trial, parameter_manager.get_int( "ISI Duration" ) );
trial_refresh_fix( ready_trial, parameter_manager.get_int( "Ready Duration" ) );
trial_refresh_fix( wait_trial, parameter_manager.get_int( "Time Between Trials" ) );

# Port setup
resp_event.set_port_code( RECALL_PORT_CODE );
array<int> button_codes[1];
button_codes[1] = BUTTON_PORT_CODE;
response_manager.set_button_codes( button_codes );

# --- sub main_instructions --- #

string next_screen = get_lang_item( lang, "Next Screen Caption" );
string prev_screen = get_lang_item( lang, "Previous Screen Caption" );
string final_screen = get_lang_item( lang, "Start Experiment Caption" );
string split_final_screen = get_lang_item( lang, "Multi-Screen Start Experiment Caption" );

bool split_instrucs = parameter_manager.get_bool( "Multi-Screen Instructions" );

sub
	main_instructions( string instruct_string )
begin
	bool has_splits = instruct_string.find( SPLIT_LABEL ) > 0;
	
	# Split screens only if requested and split labels are present
	if ( has_splits ) then
		if ( split_instrucs ) then
			# Split at split points
			array<string> split_instructions[0];
			instruct_string.split( SPLIT_LABEL, split_instructions );
			
			# Hold onto the old terminator buttons for later
			array<int> old_term_buttons[0];
			instruct_trial.get_terminator_buttons( old_term_buttons );
			
			array<int> new_term_buttons[0];
			new_term_buttons.add( BUTTON_FWD );

			# Present each screen in sequence
			loop
				int i = 1
			until
				i > split_instructions.count()
			begin
				# Remove labels and add screen switching/start experiment instructions
				# Remove leading whitespace
				string this_screen = split_instructions[i];
				this_screen = this_screen.trim();
				this_screen = this_screen.replace( SPLIT_LABEL, "" );
				this_screen.append( LINE_BREAK + LINE_BREAK );
				
				# Add the correct button options
				bool can_go_backward = ( i > 1 ) && ( BUTTON_BWD > 0 );
				new_term_buttons.resize( 0 );
				new_term_buttons.add( BUTTON_FWD );
				if ( can_go_backward ) then
					new_term_buttons.add( BUTTON_BWD );
					this_screen.append( prev_screen + " " );
				end;
				
				if ( i < split_instructions.count() ) then
					this_screen.append( next_screen );
				else
					this_screen.append( split_final_screen );
				end;
				
				instruct_trial.set_terminator_buttons( new_term_buttons );
				
				# Word wrap & present the screen
				full_size_word_wrap( this_screen, font_size, char_wrap, instruct_text );
				instruct_trial.present();
				if ( response_manager.last_response_data().button() == BUTTON_BWD ) then
					if ( i > 1 ) then
						i = i - 1;
					end;
				else
					i = i + 1;
				end;
			end;
			# Reset terminator buttons
			instruct_trial.set_terminator_buttons( old_term_buttons );
		else
			# If the caption has splits but multi-screen isn't requested
			# Remove split labels and present everything on one screen
			string this_screen = instruct_string.replace( SPLIT_LABEL, "" );
			this_screen = this_screen.trim();
			this_screen.append( LINE_BREAK + LINE_BREAK + final_screen );
			full_size_word_wrap( this_screen, font_size, char_wrap, instruct_text );
			instruct_trial.present();
		end;
	else
		# If no splits and no multi-screen, present the entire caption at once
		full_size_word_wrap( instruct_string, font_size, char_wrap, instruct_text );
		instruct_trial.present();
	end; 
	default.present();
end;

# --- sub present_instructions --- #

sub
	present_instructions( string instruct_string )
begin
	full_size_word_wrap( instruct_string, font_size, char_wrap, instruct_text );
	instruct_trial.present();
	default.present();
end;

# --- sub ready_set_go --- #

array<string> ready_caps[3];
ready_caps[1] = get_lang_item( lang, "Ready Caption" );
ready_caps[2] = get_lang_item( lang, "Set Caption" );
ready_caps[3] = get_lang_item( lang, "Go Caption" );
int ready_dur = parameter_manager.get_int( "Ready Duration" );

sub
	ready_set_go
begin
	if ( ready_dur > 0 ) then
		loop
			int i = 1
		until
			i > ready_caps.count()
		begin
			ready_text.set_caption( ready_caps[i], true );
			ready_trial.present();
			i = i + 1;
		end;
	end;
	default.present();
end;


# --- sub make_temp_seq --- #
# takes an int array and returns a full 9 digit sequence with 
# restriction that consecutive numbers (2-3, 3-2, etc) are not used )

sub
	make_temp_seq( array<int,1>& temp_seq )
begin
	temp_seq.resize( 9 );
	temp_seq.fill( 1, 0, 1, 1 );
	
	loop
		int i = 1
	until
		i > temp_seq.count() - 1
	begin
		if ( abs( temp_seq[i] - temp_seq[i+1] ) <= 2 ) then
			temp_seq.shuffle();
			i = 0;
		end;
		i = i + 1;
	end;
end;

# --- sub make_full_seq
# takes an input array and returns a list of the requested 
# size meeting the restrictions. for longer lists, generates 
# multiple shorter sequences using make_temp_seq and appends them

sub
	array<int,1> make_full_seq( int size )
begin
	array<int> temp_seq[0];
	make_temp_seq( temp_seq );
	if ( size > temp_seq.count() ) then
		loop
		until
			temp_seq.count() >= size
		begin
			array<int> added_seq[0];
			make_temp_seq( added_seq );
			loop
			until
				abs( added_seq[1] - temp_seq[temp_seq.count()] ) > 2
			begin
				make_temp_seq( added_seq );
			end;
			temp_seq.append( added_seq );
		end;
	end;
	temp_seq.resize( size );
	return temp_seq
end;

# --- sub check_accuracy 
# takes subject's response and the presented sequence 
# returns the number of correct digit responses

sub
	string check_accuracy( string subj_resp, array<int,1>& stim_seq )
begin
	subj_resp = subj_resp.replace( " ", "" );
	int acc_ctr = 0;
	loop
		int j = 1
	until
		j > subj_resp.count() || j > stim_seq.count()
	begin
		if ( int( subj_resp.substring( j,1 ) ) == stim_seq[j] ) then
			acc_ctr = acc_ctr + 1;
		end;
		j = j + 1;
	end;
	string rval = ACC_INCORRECT;
	if ( acc_ctr == stim_seq.count() ) && ( subj_resp.count() == stim_seq.count() ) then
		rval = ACC_CORRECT;
	end;
	return rval
end;

# --- sub show_block
# shows one complete digit span task in the specified direction

string stim_type = parameter_manager.get_string( "Stimulus Modality" );

array<sound> stim_snds[0];
parameter_manager.get_sounds( "Stimulus Sounds", stim_snds );
if ( stim_type == STIM_AUDITORY ) then
	if ( stim_snds.count() != 9 ) then
		exit( "Error: 'Stimulus Sounds' must contain exactly nine wavefiles, the digits 1-9." );
	end;
else
	lang.set_map( stim_type );
end;

string test_type = parameter_manager.get_string( "Test Type" );
int corr_to_increase = parameter_manager.get_int( "Staircase Correct to Increase" );
int incorr_to_decrease = parameter_manager.get_int( "Staircase Incorrect to Decrease" );
int fixed_count = parameter_manager.get_int( "Fixed Trials at Each Length" );
int total_trials = parameter_manager.get_int( "Staircase Trial Count" );
string prompt_caption = get_lang_item( lang, "Response Prompt" );
prompt_text.set_max_text_height( used_screen_height/2.0 );
prompt_text.set_max_text_width( used_screen_width );
prompt_text.set_caption( prompt_caption, true );

# -- Set up info for summary stats -- #
int SUM_BLOCK_IDX = 1;
int SUM_SPAN_IDX = 2;

array<string> cond_names[2][0];
cond_names[SUM_BLOCK_IDX].resize( 2 );
cond_names[SUM_BLOCK_IDX][COND_FORWARD_IDX] = COND_FORWARD;
cond_names[SUM_BLOCK_IDX][COND_BACKWARD_IDX] = COND_BACKWARD;

loop
	int i = 1 
until
	i > 100
begin
	cond_names[SUM_SPAN_IDX].add( string(i) );
	i = i + 1;
end;

# Now build an empty array for all DVs of interest
array<int> acc_stats[cond_names[1].count()][cond_names[2].count()][0];
array<int> RT_stats[cond_names[1].count()][cond_names[2].count()][0];
# --- End Summary Stats --- #

sub
	show_block( string order, int start_length, int block_number )
begin
	loop
		int curr_length = start_length;
		bool ok = false;
		int length_ctr = 0;
		int corr_ctr = 0;
		int incorr_ctr = 0;
		int i = 1
	until
		ok
	begin
		array<int> this_seq[curr_length] = make_full_seq( curr_length );
		string actual_seq = "";
		
		# Show sequence
		ready_set_go();
		
		loop
			int j = 1
		until
			j > this_seq.count()
		begin
			# Figure out the number we're using
			int stim_number = this_seq[j];
			if ( order == COND_BACKWARD ) then
				stim_number = this_seq[this_seq.count() - ( j - 1 )];
			end;
			
			# Set the stimulus based on that
			if ( stim_type == STIM_VISUAL ) then
				main_text.set_caption( string( stim_number ), true );
			else
				main_event.set_stimulus( stim_snds[stim_number] );
			end;
			
			# Record the stim number
			actual_seq.append( string( stim_number ) );
			
			# Set the port code
			main_event.set_port_code( stim_number );
			
			# Show the stimulus
			main_trial.present();
			ISI_trial.present();
			
			j = j + 1;
		end;
		
		# Check response
		resp_text.set_caption( " ", true );
		resp_trial.present();
		string subj_answer = system_keyboard.get_input( resp_pic, resp_text );
		int RT = clock.time() - stimulus_manager.last_stimulus_data().time();
		string accuracy = check_accuracy( subj_answer, this_seq );
		
		# Store this trial info 
		stimulus_data last = stimulus_manager.last_stimulus_data();
		last.set_event_code(
			MAIN_EVENT_CODE + ";" +
			string( block_number ) + ";" +
			order + ";" +
			string( i ) + ";" +
			string( curr_length ) + ";" +
			actual_seq + ";" +
			subj_answer + ";" +
			accuracy + ";" +
			string( RT )
		);
		
		# Record trial info for summary stats
		# Make an int array specifying the condition we're in
		# This tells us which subarray to store the trial info
		array<int> this_trial[cond_names.count()];
		if ( order == COND_FORWARD ) then
			this_trial[SUM_BLOCK_IDX] = COND_FORWARD_IDX;
		else
			this_trial[SUM_BLOCK_IDX] = COND_BACKWARD_IDX;
		end;
		this_trial[SUM_SPAN_IDX] = curr_length;

		int this_hit = int( accuracy == ACC_CORRECT );
		acc_stats[this_trial[1]][this_trial[2]].add( this_hit );
		RT_stats[this_trial[1]][this_trial[2]].add( RT );

		# Update the list length, depending on previous trial performance/number
		length_ctr = length_ctr + 1;
		if ( accuracy == ACC_CORRECT ) then
			corr_ctr = corr_ctr + 1;
			incorr_ctr = 0;
		else
			incorr_ctr = incorr_ctr + 1;
			corr_ctr = 0;
		end;
		
		if ( test_type == TYPE_FIXED ) then
			if ( length_ctr >= fixed_count ) then
				if ( incorr_ctr >= fixed_count ) then
					ok = true;
				else
					curr_length = curr_length + 1;
					length_ctr = 0;
					incorr_ctr = 0;
					corr_ctr = 0;
				end;
			end;
		else
			if ( corr_ctr >= corr_to_increase ) then
				curr_length = curr_length + 1;
				corr_ctr = 0;
			end;
			if ( incorr_ctr >= incorr_to_decrease ) then
				curr_length = curr_length - 1;
				incorr_ctr = 0;
			end;
			if ( i == total_trials ) then
				ok = true;
			end;
		end;
		
		# Make sure we don't go out of bounds on list length
		if ( curr_length < MIN_LENGTH ) then
			curr_length = MIN_LENGTH;
		end;
		
		# Wait for the next trial
		wait_trial.present();

		# Increment and check for breaks
		i = i + 1;
	end;
end;

# --- Conditions and Trial Order --- #

array<string> block_order[0][0];

begin
	# Determine the order of forward/backward blocks
	array<string> test_order[0];
	parameter_manager.get_strings( "Test Order", test_order );
	if ( test_order.count() == 0 ) then
		exit( "Error: You must specify at least one test type in 'Test Order'" );
	elseif ( parameter_manager.get_bool( "Randomize Test Order" ) ) then
		test_order.shuffle();
	end;
	
	# Set up the order of blocks and the starting list sizes
	int forward_start = parameter_manager.get_int( "Forward Span Starting Length" );
	int backward_start = parameter_manager.get_int( "Backward Span Starting Length" );
	loop
		int i = 1
	until
		i > test_order.count()
	begin
		array<string> temp[2];
		temp[TYPE_IDX] = test_order[i];
		if ( test_order[i] == COND_FORWARD ) then
			temp[START_IDX] = string( forward_start );
		else
			temp[START_IDX] = string( backward_start );
		end;
		block_order.add( temp );
		i = i + 1;
	end;
end;

# --- Main Sequence --- #

string fwd_instrucs = get_lang_item( lang, "Forward Instructions" );
string bwd_instrucs = get_lang_item( lang, "Backward Instructions" );

loop
	int i = 1
until
	i > block_order.count()
begin
	string this_block = block_order[i][TYPE_IDX];
	if ( this_block == COND_FORWARD ) then
		main_instructions( fwd_instrucs );
	else
		main_instructions( bwd_instrucs );
	end;
	show_block( block_order[i][TYPE_IDX], int( block_order[i][START_IDX] ), i );
	i = i + 1;
end;
present_instructions( get_lang_item( lang, "Completion Screen Caption" ) );

# --- Print Summary Stats --- #

string sum_log = logfile.filename();
if ( sum_log.count() > 0 ) then
	# Open & name the output file
	string TAB = "\t";
	int ext = sum_log.find( ".log" );
	sum_log = sum_log.substring( 1, ext - 1 ) + "-Summary-" + date_time( "yyyymmdd-hhnnss" ) + ".txt";
	string subj = logfile.subject();
	output_file out = new output_file;
	out.open( sum_log );

	# Get the headings for each columns
	array<string> cond_headings[cond_names.count() + 1];
	cond_headings[1] = "Subject ID";
	cond_headings[SUM_BLOCK_IDX + 1] = "Test Type";
	cond_headings[SUM_SPAN_IDX + 1] = "Span";
	cond_headings.add( "Accuracy" );
	cond_headings.add( "Accuracy (SD)" );
	cond_headings.add( "Avg RT" );
	cond_headings.add( "Avg RT (SD)" );
	cond_headings.add( "Median RT" );
	cond_headings.add( "Number of Trials" );
	cond_headings.add( "Date/Time" );

	# Now print them
	loop
		int i = 1
	until
		i > cond_headings.count()
	begin
		out.print( cond_headings[i] + TAB );
		i = i + 1;
	end;

	# Loop through the DV arrays to print each condition in its own row
	# Following the headings set up above
	loop
		int i = 1
	until
		i > acc_stats.count()
	begin
		loop
			int j = 1
		until
			j > acc_stats[i].count()
		begin
			if ( acc_stats[i][j].count() > 0 ) then
				out.print( "\n" + subj + TAB );
				out.print( cond_names[1][i] + TAB );
				out.print( cond_names[2][j] + TAB );
				out.print( round( arithmetic_mean( acc_stats[i][j] ), 3 ) );
				out.print( TAB );
				out.print( round( sample_std_dev( acc_stats[i][j] ), 3 ) );
				out.print( TAB );
				out.print( round( arithmetic_mean( RT_stats[i][j] ), 3 ) );
				out.print( TAB );
				out.print( round( sample_std_dev( RT_stats[i][j] ), 3 ) );
				out.print( TAB );
				out.print( round( median_value( RT_stats[i][j] ), 3 ) );
				out.print( TAB );
				out.print( acc_stats[i][j].count() );
				out.print( TAB );
				out.print( date_time() );
			end;
			j = j + 1;
		end;
		i = i + 1;
	end;

	# Close the file and exit
	out.close();
end;