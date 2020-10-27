# -------------------------- Header Parameters --------------------------

scenario = "AX-CPT";

write_codes = EXPARAM( "Send ERP Codes" );

default_font_size = EXPARAM( "Default Font Size" );
default_background_color = EXPARAM( "Default Background Color" );
default_text_color = EXPARAM( "Default Font Color" );
default_font = EXPARAM( "Default Font" );

max_y = 100;

active_buttons = 2;
response_matching = simple_matching;

stimulus_properties = 
	event_cond, string,
	block_name, string,
	block_number, number,
	trial_number, number,
	trial_condition, string,
	stim_type, string,
	tgt_type, string,
	stim_number, number,
	stim_caption, string;
event_code_delimiter = ";";

# ------------------------------- SDL Part ------------------------------
begin;

trial {
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 1,2;
	
	picture { 
		text { 
			caption = "Instructions"; 
			preload = false;
		} instruct_text; 
		x = 0; 
		y = 0; 
	};
} instruct_trial;

trial {
	stimulus_event {
		picture {
			text { 
				caption = "+"; 
				font_size = EXPARAM( "Fixation Point Size" ); 
			} fix_text;
			x = 0;
			y = 0;
		};
		code = "Fixation";
	} fix_event;
} fix_trial;

trial {
	clear_active_stimuli = false;
	
	stimulus_event {
		picture {
			text { 
				caption = "Stim";
				preload = false;
				font = EXPARAM( "Stimulus Font" );
				font_size = EXPARAM( "Stimulus Font Size" );
				font_color = EXPARAM( "Stimulus Font Color" );
			} stim_text;
			x = 0;
			y = 0;
		} stim_pic;
	} stim_event;
} stim_trial;

trial {
	stimulus_event {
		picture {} ISI_pic;
		code = "ISI";
	} ISI_event;
} ISI_trial;

# ----------------------------- PCL Program -----------------------------
begin_pcl;

include_once "../../Library/lib_visual_utilities.pcl";
include_once "../../Library/lib_utilities.pcl";

# --- Constants ---

string SPLIT_LABEL = "[SPLIT]";
string LINE_BREAK = "\n";
int BUTTON_FWD = 2;
int BUTTON_BWD = 1;

string PRACTICE_TYPE_PRACTICE = "Practice";
string PRACTICE_TYPE_MAIN = "Main";

string TARGET_LETTER_LABEL = "[TARGET_LETTER]";
string VALID_CUE_LABEL = "[VALID_CUE_LETTER]";
string INVALID_CUE_LABEL = "[INVALID_CUE_LETTER]";

string LANGUAGE_FILE_TOTAL_BLOCKS_LABEL = "[TOTAL_BLOCKS]";
string LANGUAGE_FILE_BLOCK_NUMBER_LABEL = "[BLOCK_NUMBER]";

string STIM_EVENT_CODE = "Stim";

string COND_CUE = "Cue";
string COND_PROBE = "Probe";

int COND_CUE_IDX = 1;
int COND_PROBE_IDX = 2;

string COND_VALID = "Valid";
string COND_INVALID = "Invalid";

int COND_VALID_IDX = 1;
int COND_INVALID_IDX = 2;

int STIM_TYPE_IDX = 1;
int VALIDITY_IDX = 2;

string COND_TGT = "Target";
string COND_NTGT = "Non-target";

int COND_TGT_IDX = 1;
int COND_NTGT_IDX = 2;

string CUE_VALID = "A";
string CUE_INVALID = "B";
string PROBE_VALID = "X";
string PROBE_INVALID = "Y";

int VAL_VAL_PORT_CODE = 1;
int VAL_INVAL_PORT_CODE = 2;
int INVAL_VAL_PORT_CODE = 3;
int INVAL_INVAL_PORT_CODE = 4;

int BUTTON_TGT = 1;
int BUTTON_NTGT = 2;

string CHARACTER_WRAP = "Character";

# --- Set up fixed stimulus parameters ---

string language = parameter_manager.get_string( "Language" );
language_file lang = load_language_file( scenario_directory + language + ".xml" );
bool char_wrap = ( get_lang_item( lang, "Word Wrap Mode" ).lower() == CHARACTER_WRAP.lower() );

adjust_used_screen_size( parameter_manager.get_bool( "Use Widescreen if Available" ) );

double font_size = parameter_manager.get_double( "Default Font Size" );

int fix_dur = parameter_manager.get_int( "Fixation Duration" );
trial_refresh_fix( fix_trial, fix_dur );

if ( parameter_manager.get_bool( "Show Fixation Point" ) ) then
	ISI_pic.add_part( fix_text, 0, 0 );
end;

# --- Stimulus Setup ---

array<string> all_stim[2][2][0];
begin
	# Get the valid cue
	all_stim[COND_CUE_IDX][COND_VALID_IDX].add( parameter_manager.get_string( "Valid Cue" ) );
	if ( all_stim[COND_CUE_IDX][COND_VALID_IDX][1].count() == 0 ) then
		exit( "Error: 'Valid Cue' must contain at least one character." );
	end;

	# Get the distractor stim
	parameter_manager.get_strings( "Distractor Stimuli", all_stim[COND_CUE_IDX][COND_INVALID_IDX] );
	if ( all_stim[COND_CUE_IDX][COND_INVALID_IDX].count() == 0 ) then
		exit( "Error: 'Distractor Stimuli' must contain at least one string." );
	end;

	# Get the target stim
	all_stim[COND_PROBE_IDX][COND_VALID_IDX].add( parameter_manager.get_string( "Target Stimulus" ) );
	if ( all_stim[COND_PROBE_IDX][COND_VALID_IDX][1].count() == 0 ) then
		exit( "Error: 'Target Stimulus' must contain at least one character." );
	end;
	all_stim[COND_PROBE_IDX][COND_INVALID_IDX].append( all_stim[COND_CUE_IDX][COND_INVALID_IDX] );

	# Make sure the valid and invalid cues are different
	if ( all_stim[COND_CUE_IDX][COND_VALID_IDX][1] == all_stim[COND_PROBE_IDX][COND_VALID_IDX][1] ) then
		exit( "Error: 'Valid Cue' must be different from 'Target Stimulus'" );
	end;

	# Make sure there aren't any repeats between the cue and probe stimuli
	loop
		int i = 1
	until
		i > all_stim[COND_CUE_IDX][COND_INVALID_IDX].count()
	begin
		if ( all_stim[COND_CUE_IDX][COND_INVALID_IDX][i] == all_stim[COND_CUE_IDX][COND_VALID_IDX][1] ) then
			exit( "Error: 'Distractor Stimuli' cannot contain 'Valid Cue'" );
		end;
		if ( all_stim[COND_CUE_IDX][COND_INVALID_IDX][i] == all_stim[COND_PROBE_IDX][COND_VALID_IDX][1] ) then
			exit( "Error: 'Distractor Stimuli' cannot contain 'Target Stimulus'" );
		end;
		i = i + 1;
	end;
end;

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

# --- sub present_instructions --- 

sub
	present_instructions( string instruct_string )
begin
	full_size_word_wrap( instruct_string, font_size, char_wrap, instruct_text );
	instruct_trial.present();
	default.present();
end;

# --- sub block_status ---

string block_complete = get_lang_item( lang, "Block Complete Caption" );

sub
	block_status( int total_blocks, int current_block )
begin
	if ( current_block < total_blocks ) then
		string block_temp = block_complete.replace( LANGUAGE_FILE_TOTAL_BLOCKS_LABEL, string(total_blocks) );
		block_temp = block_temp.replace( LANGUAGE_FILE_BLOCK_NUMBER_LABEL, string(current_block) );
		present_instructions( block_temp );
	end;
end;

# --- sub get_port_code
# AX = 1, AY = 2, BX = 3, BY = 4 #

sub
	int get_port_code( int trial_type, string trial_cond )
begin
	string rval = string( trial_type );
	if ( trial_cond.find( CUE_VALID ) > 0 ) then
		if ( trial_cond.find( PROBE_VALID ) > 0 ) then
			rval.append( string( VAL_VAL_PORT_CODE ) );
		else
			rval.append( string( VAL_INVAL_PORT_CODE ) );
		end;
	else
		if ( trial_cond.find( PROBE_VALID ) > 0 ) then
			rval.append( string( INVAL_VAL_PORT_CODE ) );
		else
			rval.append( string( INVAL_INVAL_PORT_CODE ) );
		end;
	end;
	return int( rval )
end;

# --- sub get_condition

sub
	string get_condition( int cue_type, int probe_type )
begin
	string rval = "";
	if ( cue_type == COND_VALID_IDX ) then
		rval.append( CUE_VALID );
	else
		rval.append( CUE_INVALID );
	end;
	if ( probe_type == COND_VALID_IDX ) then
		rval.append( PROBE_VALID );
	else
		rval.append( PROBE_INVALID );
	end;
	return rval
end;
		

# --- sub show_block ---

array<string> stim_conds[2];
stim_conds[COND_CUE_IDX] = COND_CUE;
stim_conds[COND_PROBE_IDX] = COND_PROBE;

array<string> tgt_conds[2];
tgt_conds[COND_TGT_IDX] = COND_TGT;
tgt_conds[COND_NTGT_IDX] = COND_NTGT;
	
array<int> ISI_durations[0];
parameter_manager.get_ints( "ISI Durations", ISI_durations );
if ( ISI_durations.count() == 0 ) then
	exit( "Error: 'ISI Durations' must contain at least one value." );
end;

array<int> stim_durs[2];
stim_durs[COND_CUE_IDX] = parameter_manager.get_int( "Cue Duration" );
stim_durs[COND_PROBE_IDX] = parameter_manager.get_int( "Probe Duration" );

# -- Set up info for summary stats -- #
int SUM_TYPE_IDX = 1;

# Put all the condition names into an array
# Used later to add column headings
array<string> cond_names[1][0];
cond_names[SUM_TYPE_IDX].assign( tgt_conds );

# Now build an empty array for all DVs of interest
array<int> acc_stats[cond_names[1].count()][0];
array<int> RT_stats[cond_names[1].count()][0];
# --- End Summary Stats --- #

sub
	double show_block( array<int,2>& trial_order, string prac_check, int block_num )
begin
	# Start with an ISI
	trial_refresh_fix( ISI_trial, ISI_durations[random(1,ISI_durations.count())] );
	ISI_trial.present();
	
	# Loop to show the block
	double block_acc = 0.0;
	loop
		string pair_cond = "";
		int hits = 0;
		int i = 1
	until
		i > trial_order.count()
	begin
		# Trial info
		int this_type = trial_order[i][STIM_TYPE_IDX];
		int this_validity = trial_order[i][VALIDITY_IDX];
		
		# "pair_cond" can be "AX", "BX", "AY", or "BY" trial, updated every other trial
		if ( i % 2 == 1 ) then
			pair_cond = get_condition( this_validity, trial_order[i+1][VALIDITY_IDX] );
		end;
		
		# Set cue text
		int stim_number = random( 1, all_stim[this_type][this_validity].count() );
		stim_text.set_caption( all_stim[this_type][this_validity][stim_number], true );

		# Set target button
		string tgt_type = COND_NTGT;
		if ( this_type == COND_PROBE_IDX ) && ( pair_cond == CUE_VALID + PROBE_VALID ) then
			stim_event.set_target_button( BUTTON_TGT );
			tgt_type = COND_TGT;
		else
			stim_event.set_target_button( BUTTON_NTGT );
		end;

		# Set cue port code # port codes: 1(cue)/2(probe) + 1AX/2AY/3BX/4BY
		int p_code = get_port_code( this_type, pair_cond );
		stim_event.set_port_code( p_code );
		
		# Set ISI duration
		trial_refresh_fix( ISI_trial, ISI_durations[random(1,ISI_durations.count())] );

		# Set stim duration
		int this_dur = stim_durs[this_type];
		if ( this_dur > 0 ) then
			stim_trial.set_type( stim_trial.FIXED );
			trial_refresh_fix( stim_trial, this_dur );
		else
			stim_trial.set_type( stim_trial.FIRST_RESPONSE );
			stim_trial.set_duration( stim_trial.FOREVER );
		end;
		
		# Set event code
		stim_event.set_event_code( 
			STIM_EVENT_CODE + ";" +
			prac_check + ";" +
			string( block_num ) + ";" +
			string( i ) + ";" +
			pair_cond + ";" +
			stim_conds[this_type] + ";" +
			tgt_type + ";" +
			string( stim_number ) + ";" +
			stim_text.caption()
		);

		# Show cue and ISI
		if ( fix_dur > 0 ) then
			fix_trial.present();
		end;
		stim_trial.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		ISI_trial.present();
		
		# Update block accuracy
		if ( last.type() == last.HIT ) then
			hits = hits + 1;
		end;
		block_acc = double(hits) / double(i);
		
		# Record trial info for summary stats
		if ( prac_check == PRACTICE_TYPE_MAIN ) then
			# Make an int array specifying the condition we're in
			# This tells us which subarray to store the trial info
			array<int> this_trial[cond_names.count()];
			this_trial[SUM_TYPE_IDX] = COND_TGT_IDX;
			if ( tgt_type == COND_NTGT ) then
				this_trial[SUM_TYPE_IDX] = COND_NTGT_IDX;
			end;

			int this_hit = int( last.type() == last.HIT );
			acc_stats[this_trial[1]].add( this_hit );
			if ( last.reaction_time() > 0 ) then
				RT_stats[this_trial[1]].add( last.reaction_time() );
			end;
		end;
		
		i = i + 1;
	end;
	return block_acc
end;

# --- Conditions & Trial Order

array<int> cond_array[0][0];
array<int> prac_array[0][0];

sub
	randomize_trial_order( array<int,2>& trial_order )
begin
	# Randomizing is complicated because we need to keep 
	# pairs of indices together (e.g., 1-2, 3-4, etc.)
	# Start by generating a random list of the cue indices (1,3,5,7...)
	array<int> idx_order[ trial_order.count()/2 ];
	idx_order.fill( 1,0,1,2 );
	idx_order.shuffle();
	
	# Now step through that randomized order and assign
	# both that index and the subsequent index to the cond_array
	array<int> temp_array[0][0];
	loop
		int i = 1
	until
		i > idx_order.count()
	begin
		temp_array.add( trial_order[idx_order[i]] );
		temp_array.add( trial_order[idx_order[i]+1] );
		i = i + 1;
	end;
	trial_order.assign( temp_array );
end;

# --- sub add_trials
# will add a specified number of specified cue/probe trials
# Note that because the cue and probe are presented as distinct trials
# each "trial" here adds two subarrays to the condition array

sub
	add_trials( int num_trials, int cue_validity, int probe_validity )
begin
	loop
		array<int> temp[2];
		int i = 1
	until
		i > num_trials
	begin
		temp[STIM_TYPE_IDX] = COND_CUE_IDX;
		temp[VALIDITY_IDX] = cue_validity;
		cond_array.add( temp );
		
		temp[STIM_TYPE_IDX] = COND_PROBE_IDX;
		temp[VALIDITY_IDX] = probe_validity;
		cond_array.add( temp );
		i = i + 1;
	end;
end;

begin
	# Build the condition array based on parameter values
	add_trials( parameter_manager.get_int( "AX Trials per Block" ), COND_VALID_IDX, COND_VALID_IDX );
	add_trials( parameter_manager.get_int( "AY Trials per Block" ), COND_VALID_IDX, COND_INVALID_IDX );
	add_trials( parameter_manager.get_int( "BY Trials per Block" ), COND_INVALID_IDX, COND_INVALID_IDX );
	add_trials( parameter_manager.get_int( "BX Trials per Block" ), COND_INVALID_IDX, COND_VALID_IDX );
	
	# Exit if no trials were requested
	if ( cond_array.count() == 0 ) then
		exit( "Error: No trials specified." );
	end;
	
	# Build a practice array based on requested number of trials
	# The condition array should contain 2 * number of requested trials
	# because we have a cue trial and a probe trial for each "Trial"
	int prac_trials = parameter_manager.get_int( "Practice Trials" );
	loop
	until
		prac_array.count() >= prac_trials * 2
	begin
		# The random trial we select must be an odd number (i.e., a cue)
		# Once we have that, we add that index (cue) and the next (probe)
		int rand_num = random( 1, cond_array.count() - 1 );
		if ( rand_num % 2 == 0 ) then
			rand_num = rand_num + 1;
		end;
		prac_array.add( cond_array[rand_num] );
		prac_array.add( cond_array[rand_num + 1] );
	end;
end;



# --- Main Sequence ---

int block_count = parameter_manager.get_int( "Blocks" );
bool show_block_status = parameter_manager.get_bool( "Show Status Between Blocks" );
int prac_threshold = parameter_manager.get_int( "Minimum Percent Correct to Complete Practice" );
string rest_caption = get_lang_item( lang, "Rest Screen Caption" );
string instructions = get_lang_item( lang, "Instructions" );
instructions = instructions.replace( TARGET_LETTER_LABEL, all_stim[COND_PROBE_IDX][COND_VALID_IDX][1] );
instructions = instructions.replace( VALID_CUE_LABEL, all_stim[COND_CUE_IDX][COND_VALID_IDX][1] );
instructions = instructions.replace( INVALID_CUE_LABEL, all_stim[COND_CUE_IDX][COND_INVALID_IDX][1] );

# Show practice trials or instructions
if ( prac_array.count() > 0 ) then
	main_instructions( instructions + " " + get_lang_item( lang, "Practice Caption" ) );
	loop 
		double block_accuracy = -1.0
	until 
		block_accuracy >= ( double( prac_threshold ) / 100.0 )
	begin
		randomize_trial_order( prac_array );
		block_accuracy = show_block( prac_array, PRACTICE_TYPE_PRACTICE, 0 );
	end;
	present_instructions( get_lang_item( lang, "Practice Complete Caption" ) );
else
	main_instructions( instructions );
end;

# Main block loop
loop
	int i = 1
until
	i > block_count
begin
	# Shuffle the trial order and show the block
	randomize_trial_order( cond_array );
	show_block( cond_array, PRACTICE_TYPE_MAIN, i );
	
	# Update participant if requested
	if ( show_block_status ) then
		block_status( block_count, i );
	elseif ( i < block_count ) then
		present_instructions( rest_caption );
	end;
	
	i = i + 1;
end;

present_instructions( get_lang_item( lang, "Completion Screen Caption" ) );


# --- Print Summary Stats --- #

string sum_log = logfile.filename();
if ( sum_log.count() > 0 ) then
	# Open & name the output file
	string TAB = "\t";
	int ext = sum_log.find( ".log" );
	sum_log = sum_log.substring( 1, ext - 1 ) + "-Summary-" + date_time( "yyyymmdd-yyyymmdd-hhnnssss" ) + ".txt";
	string subj = logfile.subject();
	output_file out = new output_file;
	out.open( sum_log );

	# Print the headings for each columns
	array<string> cond_headings[cond_names.count() + 1];
	cond_headings[1] = "Subject ID";
	cond_headings[SUM_TYPE_IDX + 1] = "Stimulus Type";
	cond_headings.add( "Accuracy" );
	cond_headings.add( "Accuracy (SD)" );
	cond_headings.add( "Avg RT" );
	cond_headings.add( "Avg RT (SD)" );
	cond_headings.add( "Median RT" );
	cond_headings.add( "Number of Trials" );
	cond_headings.add( "Date/Time" );

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
		out.print( "\n" + subj + TAB );
		out.print( cond_names[1][i] + TAB );
		out.print( round( arithmetic_mean( acc_stats[i] ), 3 ) );
		out.print( TAB );
		out.print( round( sample_std_dev( acc_stats[i] ), 3 ) );
		out.print( TAB );
		out.print( round( arithmetic_mean( RT_stats[i] ), 3 ) );
		out.print( TAB );
		out.print( round( sample_std_dev( RT_stats[i] ), 3 ) );
		out.print( TAB );
		out.print( round( median_value( RT_stats[i] ), 3 ) );
		out.print( TAB );
		out.print( acc_stats[i].count() );
		out.print( TAB );
		out.print( date_time() );
		i = i + 1;
	end;

	# Close the file and exit
	out.close();
end;