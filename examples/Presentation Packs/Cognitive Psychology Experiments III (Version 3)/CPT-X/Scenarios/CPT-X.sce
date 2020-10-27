# -------------------------- Header Parameters --------------------------

scenario = "CPT-X";

write_codes = EXPARAM( "Send ERP Codes" );

default_font_size = EXPARAM( "Default Font Size" );
default_background_color = EXPARAM( "Default Background Color" );
default_text_color = EXPARAM( "Default Font Color" );
default_font = EXPARAM( "Default Font" );

max_y = 100;

active_buttons = 1;
response_matching = simple_matching;

stimulus_properties = 
	event_cond, string,
	block_name, string,
	block_number, number,
	trial_number, number,
	stim_cond, string,
	stim_caption, string,
	ISI_dur, number;
event_code_delimiter = ";";

# ------------------------------- SDL Part ------------------------------
begin;

trial {
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 1;
	
	stimulus_event {
		picture { 
			text { 
				caption = "Instructions"; 
				preload = false;
			} instruct_text; 
			x = 0; 
			y = 0; 
		} instruct_pic;
		code = "Instructions";
	} instruct_event;
} instruct_trial;

trial {
	clear_active_stimuli = false;
	
	stimulus_event {
		picture {
			text { 
				caption = "Stim";
				font_color = EXPARAM( "Stimulus Color" );
				font = EXPARAM( "Stimulus Font" );
				font_size = EXPARAM( "Stimulus Font Size" );
				preload = false;
			} stim_text;
			x = 0;
			y = 0;
		} stim_pic;
	} stim_event;
} stim_trial;

trial {
	stimulus_event {
		picture {
			text { 
				caption = "+"; 
				font_size = EXPARAM( "Fixation Point Size" ); 
				font_color = EXPARAM( "Stimulus Color" );
			} fix_text;
			x = 0;
			y = 0;
		} ISI_pic;
		code = "ISI";
	} ISI_event;
} ISI_trial;

TEMPLATE "../../Library/lib_rest.tem";

# ----------------------------- PCL Program -----------------------------
begin_pcl;

include_once "../../Library/lib_visual_utilities.pcl";
include_once "../../Library/lib_utilities.pcl";

# --- Constants ---

string SPLIT_LABEL = "[SPLIT]";
string LINE_BREAK = "\n";
int BUTTON_FWD = 1;
int BUTTON_BWD = 0;

string PRACTICE_TYPE_PRACTICE = "Practice";
string PRACTICE_TYPE_MAIN = "Main";

string TARGET_LETTER_LABEL = "[TARGET_LETTER]";

string LANGUAGE_FILE_TOTAL_BLOCKS_LABEL = "[TOTAL_BLOCKS]";
string LANGUAGE_FILE_BLOCK_NUMBER_LABEL = "[BLOCK_NUMBER]";

string STIM_EVENT_CODE = "Stim";

string COND_TGT = "Target";
string COND_NONTGT = "Non-target";

int COND_TGT_IDX = 1;
int COND_NONTGT_IDX = 2;

int BUTTON_TGT = 0;
int BUTTON_NONTGT = 1;

int PORT_CODE_TGT = 10;
int PORT_CODE_NONTGT = 20;

int MIN_WAIT_DUR = 1000; # Sets a minimum wait time between blocks

string CHARACTER_WRAP = "Character";

# --- Set up fixed stimulus parameters ---

string language = parameter_manager.get_string( "Language" );
language_file lang = load_language_file( scenario_directory + language + ".xml" );
bool char_wrap = ( get_lang_item( lang, "Word Wrap Mode" ).lower() == CHARACTER_WRAP.lower() );

adjust_used_screen_size( parameter_manager.get_bool( "Use Widescreen if Available" ) );

double font_size = parameter_manager.get_double( "Default Font Size" );

trial_refresh_fix( stim_trial, parameter_manager.get_int( "Stimulus Duration" ) );

if ( !parameter_manager.get_bool( "Show Fixation Point" ) ) then
	ISI_pic.clear();
end;

# Setup rest stuff
rest_event.set_port_code( special_port_code1 );
bool show_progress = parameter_manager.get_bool( "Show Progress Bar During Rests" );
word_wrap( get_lang_item( lang, "Rest Screen Caption" ), used_screen_width, used_screen_height / 2.0, font_size, char_wrap, rest_text );
if ( show_progress ) then
	double bar_width = used_screen_width * 0.5;
	full_box.set_width( bar_width );
	rest_pic.set_part_x( 3, -bar_width/2.0, rest_pic.LEFT_COORDINATE );
	rest_pic.set_part_x( 4, -bar_width/2.0, rest_pic.LEFT_COORDINATE );
	progress_text.set_caption( get_lang_item( lang, "Progress Bar Caption" ), true );
else
	rest_pic.clear();
	rest_pic.add_part( rest_text, 0, 0 );
end;

# --- Stimulus Setup ---

array<string> all_stim[2][0];

begin
	# Grab the target string & make sure it's legal
	string tgt_letter = parameter_manager.get_string( "Target Letter" );
	if ( tgt_letter.count() == 0 ) then
		exit( "Error: 'Target Letter' cannot be empty." );
	end;

	# Grab the set of non-targets. Make sure there is at least 1 stimulus
	# and that none of them match the target stim.
	array<string> ntgt_stim[0];
	parameter_manager.get_strings( "Non-target Letters", ntgt_stim );
	begin
		array<string> temp_ntgts[0];
		loop
			int i = 1
		until
			i > ntgt_stim.count()
		begin
			if ( ntgt_stim[i] != tgt_letter ) then
				temp_ntgts.add( ntgt_stim[i] );
			end;
			i = i + 1;
		end;
		ntgt_stim.resize( 0 );
		if ( temp_ntgts.count() == 0 ) then
			exit( "Error: 'Non-target Letters' cannot be empty." );
		else
			ntgt_stim.assign( temp_ntgts );
		end;
	end;
	
	# Set up the all_stim array. Holds both tgt and nontgt stim
	all_stim[COND_TGT_IDX].add( tgt_letter );
	all_stim[COND_NONTGT_IDX].assign( ntgt_stim );
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
	string block_status( int total_blocks, int current_block )
begin
	string block_temp = block_complete.replace( LANGUAGE_FILE_TOTAL_BLOCKS_LABEL, string(total_blocks) );
	block_temp = block_temp.replace( LANGUAGE_FILE_BLOCK_NUMBER_LABEL, string(current_block) );
	return block_temp
end;

# --- sub show_rest ---

int rest_every = parameter_manager.get_int( "Trials Between Rests" );

sub 
	bool show_rest( int counter_variable, int num_trials )
begin
	if ( rest_every != 0 ) then
		if ( counter_variable >= rest_every ) && ( counter_variable % rest_every == 0 ) && ( counter_variable < num_trials ) then
			if ( show_progress ) then
				progress_box.set_width( used_screen_width * 0.5 * ( double(counter_variable) / double(num_trials) ) );
			end;
			rest_trial.present();
			default.present();
			return true
		end;
	end;
	return false
end;

# --- sub show_block ---

array<string> tgt_conds[2];
tgt_conds[COND_TGT_IDX] = COND_TGT;
tgt_conds[COND_NONTGT_IDX] = COND_NONTGT;

array<int> p_codes[2];
p_codes[COND_TGT_IDX] = PORT_CODE_TGT;
p_codes[COND_NONTGT_IDX] = PORT_CODE_NONTGT;

array<int> t_buttons[2];
t_buttons[COND_TGT_IDX] = BUTTON_TGT;
t_buttons[COND_NONTGT_IDX] = BUTTON_NONTGT;

array<int> ISI_durations[0];
parameter_manager.get_ints( "ISI Durations", ISI_durations );
if ( ISI_durations.count() == 0 ) then
	exit( "Error: 'ISI Durations' must contain at least one value." );
end;

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
	double show_block( array<int,1>& trial_order, string prac_check, int block_num )
begin
	# Start with an ISI
	trial_refresh_fix( ISI_trial, ISI_durations[random(1,ISI_durations.count())] );
	ISI_trial.present();
	
	# Loop to show the block
	double block_acc = 0.0;
	loop
		int hits = 0;
		int i = 1
	until
		i > trial_order.count()
	begin
		# Trial info
		int this_type = trial_order[i];
		
		# Condition info
		string this_cond = tgt_conds[this_type];
		string this_stim = all_stim[this_type][random(1,all_stim[this_type].count())];
		int p_code = p_codes[this_type];
		
		# Set cue text
		stim_text.set_caption( this_stim, true );
		
		# Target button
		stim_event.set_target_button( t_buttons[this_type] );
		stim_event.set_response_active( true );
		stim_event.set_port_code( p_code );

		# Set ISI duration
		trial_refresh_fix( ISI_trial, ISI_durations[random(1,ISI_durations.count())] );

		# Set event code
		stim_event.set_event_code( 	
			STIM_EVENT_CODE + ";" +
			prac_check + ";" + 
			string( block_num ) + ";" +
			string( i ) + ";" +
			this_cond + ";" +
			stim_text.caption() + ";" +
			string( ISI_trial.duration() )
		);
		
		# Show cue and ISI
		stim_trial.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		ISI_trial.present();
		
		# Update block accuracy
		if ( last.type() == last.HIT ) || ( last.type() == last.OTHER ) then
			hits = hits + 1;
		end;
		block_acc = double(hits) / double(i);
		
		# Record trial info for summary stats
		if ( prac_check == PRACTICE_TYPE_MAIN ) then
			# Make an int array specifying the condition we're in
			# This tells us which subarray to store the trial info
			array<int> this_trial[cond_names.count()];
			this_trial[SUM_TYPE_IDX] = this_type;
			
			int this_hit = int( last.type() == last.HIT || last.type() == last.OTHER );
			acc_stats[this_trial[1]].add( this_hit );
			if ( last.reaction_time() > 0 ) then
				RT_stats[this_trial[1]].add( last.reaction_time() );
			end;
		end;
		
		# Show rest
		if ( prac_check == PRACTICE_TYPE_MAIN ) then
			if ( show_rest( i, trial_order.count() ) ) then
				ISI_trial.present();
			end;
		end;
		i = i + 1;
		
	end;
	return block_acc
end;

# --- Conditions & Trial Order

array<int> cond_array[0][0];
array<int> prac_cond_array[1][0];

begin
	array<int> tgts_per[0];
	parameter_manager.get_ints( "Targets per Block", tgts_per );
	
	array<int> ntgts_per[0];
	parameter_manager.get_ints( "Non-targets per Block", ntgts_per );
	
	int num_blocks = parameter_manager.get_int( "Blocks" );
	if ( tgts_per.count() != num_blocks ) || ( ntgts_per.count() != num_blocks ) then
		exit( "Error: 'Targets per Block' and 'Non-targets per Block' must contain exactly 'Blocks' values." );
	end;
	
	loop
		int i = 1
	until
		i > num_blocks
	begin
		array<int> temp_order[tgts_per[i] + ntgts_per[i]];
		temp_order.fill( 1, 0, COND_TGT_IDX, 0 );
		temp_order.fill( 1, ntgts_per[i], COND_NONTGT_IDX, 0 );
		temp_order.shuffle();
		cond_array.add( temp_order );
		i = i + 1;
	end;
	
	if ( parameter_manager.get_bool( "Randomize Block Order" ) ) then
		cond_array.shuffle();
	end;
	int prac_trials = parameter_manager.get_int( "Practice Trials" );
	loop
	until
		prac_cond_array[1].count() >= prac_trials
	begin
		prac_cond_array[1].append( cond_array[1] );
	end;
	if ( prac_trials > 1 ) then
		prac_cond_array[1][1] = COND_TGT_IDX;
	end;
	prac_cond_array[1].resize( prac_trials );
	prac_cond_array[1].shuffle();
end;

# --- Main Sequence ---

bool show_block_status = parameter_manager.get_bool( "Show Status Between Blocks" );
int prac_threshold = parameter_manager.get_int( "Minimum Percent Correct to Complete Practice" );
string rest_caption = get_lang_item( lang, "Rest Screen Caption" );
string instructions = get_lang_item( lang, "Instructions" );
instructions = instructions.replace( TARGET_LETTER_LABEL, all_stim[COND_TGT_IDX][1] );

# Show practice trials or instructions
if ( prac_cond_array[1].count() > 0 ) then
	main_instructions( instructions + " " + get_lang_item( lang, "Practice Caption" ) );
	loop 
		double block_accuracy = -1.0
	until 
		block_accuracy >= ( double( prac_threshold ) / 100.0 )
	begin
		block_accuracy = show_block( prac_cond_array[1], PRACTICE_TYPE_PRACTICE, 0 );
	end;
	present_instructions( get_lang_item( lang, "Practice Complete Caption" ) );
else
	main_instructions( instructions );
end;

loop
	int i = 1
until
	i > cond_array.count()
begin
	show_block( cond_array[i], PRACTICE_TYPE_MAIN, i );

	# Update participant
	if ( i < cond_array.count() ) then
		string temp_cap = block_status( cond_array.count(), i );
		if ( !show_block_status ) then
			temp_cap = rest_caption;
			instruct_event.set_response_active( true );
			instruct_event.set_stimulus_time_in( MIN_WAIT_DUR );
			instruct_trial.set_all_responses( false );
			present_instructions( temp_cap );
			instruct_event.set_stimulus_time_in( 0 );
			instruct_trial.set_all_responses( true );
		end;
	end;
	
	i = i + 1;
end;

# Finishing up
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

	# Print the headings for each columns
	array<string> cond_headings[cond_names.count() + 1];
	cond_headings[1] = "Subject ID";
	cond_headings[SUM_TYPE_IDX + 1] = "Stim Type";
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