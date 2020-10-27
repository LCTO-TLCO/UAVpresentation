# -------------------------- Header Parameters --------------------------

scenario = "Serial Reaction Time";

write_codes = EXPARAM( "Send ERP Codes" );

default_font_size = EXPARAM( "Default Font Size" );
default_background_color = EXPARAM( "Default Background Color" );
default_text_color = EXPARAM( "Default Font Color" );
default_font = EXPARAM( "Default Font" );

max_y = 100;

active_buttons = 5;
response_matching = simple_matching;

stimulus_properties = 
	event_cond, string, 
	block_name, string,
	block_number, number,
	trial_number, number,
	stim_position, number,
	sequence_number, number,
	trial_cond, string;
event_code_delimiter = ";";

# ------------------------------- SDL Part ------------------------------
begin;

trial {
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 5;
	
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
	clear_active_stimuli = false;
	trial_type = specific_response;
	terminator_button = 1,2,3,4;
	all_responses = false;
	
	stimulus_event {
		picture {} tgt_pic; 
	} tgt_event;
} tgt_trial;

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

string LANGUAGE_FILE_TOTAL_BLOCKS_LABEL = "[TOTAL_BLOCKS]";
string LANGUAGE_FILE_BLOCK_NUMBER_LABEL = "[BLOCK_NUMBER]";

string COND_RANDOM = "Random";
string COND_LEARNED = "Learned";

int COND_RAND_IDX = 1;
int COND_LEARNED_IDX = 2;

string TGT_EVENT_CODE = "Target";

int STIM_IDX = 1;
int SEQ_IDX = 2;

int FIX_PART = 1;

int RESPONSES = 4;

array<int> button_numbers[4] = { 1,2,3,4 };

string CHARACTER_WRAP = "Character";

# --- Set up fixed stimulus parameters ---

string language = parameter_manager.get_string( "Language" );
language_file lang = load_language_file( scenario_directory + language + ".xml" );
bool char_wrap = ( get_lang_item( lang, "Word Wrap Mode" ).lower() == CHARACTER_WRAP.lower() );

adjust_used_screen_size( parameter_manager.get_bool( "Use Widescreen if Available" ) );

double font_size = parameter_manager.get_double( "Default Font Size" );

# Event Setup
int tgt_duration = parameter_manager.get_int( "Target Duration" );
if ( tgt_duration == 0 ) then
	tgt_trial.set_duration( tgt_trial.FOREVER );
else
	trial_refresh_fix( tgt_trial, tgt_duration );
end;

tgt_event.set_port_code( default_port_code1 );
ISI_event.set_port_code( default_port_code2 );

# --- Stimulus Setup ---

array<double> box_locs[0];

begin
	# Make the target box
	double tgt_height = parameter_manager.get_double( "Target Height" );
	double tgt_width = parameter_manager.get_double( "Target Width" );
	box tgt_box = new box( tgt_height, tgt_width, parameter_manager.get_color( "Target Color" ) );

	# Initialize some values
	double spacing = parameter_manager.get_double( "Space Between Boxes" );
	double box_height = parameter_manager.get_double( "Box Height" );
	double box_width = parameter_manager.get_double( "Box Width" );
	double line_width = parameter_manager.get_double( "Box Outline Width" );

	# Draw the outline boxes
	line_graphic tgt_outline = new line_graphic();
	tgt_outline.set_line_color( parameter_manager.get_color( "Box Outline Color" ) );
	tgt_outline.set_line_width( line_width );
	double box_side = box_width/2.0 + line_width/2.0;
	double box_top = box_height/2.0 + line_width/2.0;
	tgt_outline.set_join_type( tgt_outline.JOIN_POINT );
	tgt_outline.add_line( -box_side, box_top, box_side, box_top );
	tgt_outline.line_to( box_side, -box_top );
	tgt_outline.line_to( -box_side, -box_top );
	tgt_outline.line_to( -box_side, box_top );
	tgt_outline.line_to( box_side, box_top );
	tgt_outline.redraw();

	# If the target is too big, then exit
	if ( tgt_height > box_height ) then
		exit( "Error: The target box is too large. Reduce 'Target Height' or increase 'Box Height'" );
	end;
	if ( tgt_width > box_width ) then
		exit( "Error: The target box is too large. Reduce 'Target Width' or increase 'Box Width'" );
	end;

	# Check if the total width of all the stimuli will fit on screen
	double total_width = ( tgt_outline.width() * double( RESPONSES ) ) + ( spacing * double( RESPONSES - 1 ) );
	if ( total_width > used_screen_width ) then
		exit( "Error: The boxes (or spacing between boxes) are too large to fit on screen. Reduce 'Box Width' or 'Spacing Between Boxes'" );
	end;

	# Add the outline boxes to the pictures and store the box locations
	loop
		double left_pos = -total_width/2.0 + ( tgt_outline.width()/2.0 );
		int i = 1
	until
		i > 4
	begin
		tgt_pic.add_part( tgt_outline, left_pos, 0.0 );
		ISI_pic.add_part( tgt_outline, left_pos, 0.0 );
		box_locs.add( left_pos  );
		
		left_pos = left_pos + ( tgt_outline.width() ) + spacing;
		i = i + 1;
	end;
	
	# Draw the target
	tgt_pic.add_part( tgt_box, 0, 0 );
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

# --- sub show_block ---

array<int> ISI_durations[0];
parameter_manager.get_ints( "ISI Durations", ISI_durations );
if ( ISI_durations.count() == 0 ) then
	exit( "Error: 'ISI Durations' must contain at least one value." );
end;

# -- Set up info for summary stats -- #
int SUM_COND_IDX = 1;

# Put all the condition names into an array
# Used later to add column headings
array<string> cond_names[1][2];
cond_names[SUM_COND_IDX][COND_RAND_IDX] = COND_RANDOM;
cond_names[SUM_COND_IDX][COND_LEARNED_IDX] = COND_LEARNED;

# Now build an empty array for all DVs of interest
array<int> acc_stats[cond_names[1].count()][0];
array<int> RT_stats[cond_names[1].count()][0];
# --- End Summary Stats --- #

sub
	double show_block( string prac_check, array<int,2>& cond_array, int block_num )
begin
	# Show the ISI first to wait for a bit
	trial_refresh_fix( ISI_trial, ISI_durations[random(1,ISI_durations.count())] );
	
	# Main loop to show trials
	double block_acc = 0.0;
	loop
		int hits = 0;
		int i = 1
	until
		i > cond_array.count()
	begin
		# Get some info for this trial
		int this_pos = cond_array[i][STIM_IDX];
		int this_seq_num = cond_array[i][SEQ_IDX];
		string this_cond = COND_RANDOM;
		if ( this_seq_num > 0 ) then
			this_cond = COND_LEARNED;
		end;
		
		# Set the target location
		tgt_pic.set_part_x( tgt_pic.part_count(), box_locs[this_pos] );
		
		# Set the target button
		tgt_event.set_target_button( button_numbers[this_pos] );
		
		# Set the ISI Duration
		trial_refresh_fix( ISI_trial, ISI_durations[random(1,ISI_durations.count())] );
		
		# Set event code
		tgt_event.set_event_code( 
			TGT_EVENT_CODE + ";" +
			prac_check + ";" +
			string( block_num ) + ";" +
			string( i ) + ";" +
			string( this_pos ) + ";" +
			string( this_seq_num ) + ";" +
			this_cond
		);
		
		# Show the trial sequence
		tgt_trial.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		ISI_trial.present();
	
		# Update accuracy
		if ( last.type() == last.HIT ) then
			hits = hits + 1;
		end;
		block_acc = double( hits )/ double( i );

		# Record trial info for summary stats
		# Make an int array specifying the condition we're in
		# This tells us which subarray to store the trial info
		if ( prac_check == PRACTICE_TYPE_MAIN ) then
			array<int> this_trial[cond_names.count()];
			this_trial[SUM_COND_IDX] = COND_RAND_IDX;
			if ( this_seq_num > 0 ) then
				this_trial[SUM_COND_IDX] = COND_LEARNED_IDX;
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

# --- Sequence and Condition Setup

array<int> block_order[0][0][0];
array<int> prac_array[0][0];

begin
	block_order.resize( parameter_manager.get_int( "Blocks" ) );

	# Get the learned sequence
	array<int> learned_seq[0];
	parameter_manager.get_ints( "Learned Sequence", learned_seq );
	if ( learned_seq.count() < 2 ) then
		exit( "Error: 'Learned Sequence' must contain at least two values." );
	end;

	# Initialize some values
	int seq_repeats = parameter_manager.get_int( "Sequence Repeats" );
	int non_seq_trials = parameter_manager.get_int( "Non-Sequence Trials" );
	int min_intervening_trials = parameter_manager.get_int( "Minimum Intervening Trials" );
	int min_start_trials = parameter_manager.get_int( "Minimum Random Trials at Start" );
	int min_end_trials = parameter_manager.get_int( "Minimum Random Trials at End" );

	# Make sure the requested number of trials is adequate
	int required_non = ( ( seq_repeats - 1 ) * min_intervening_trials ) + min_start_trials + min_end_trials;
	if ( required_non > non_seq_trials ) then
		exit( "Error: Not enough non-sequence trials. Increase 'Non-Sequence Trials' or reduce 'Minimum Intervening Trials'" );
	end;
	
	# Get the number of non-sequence trials that aren't at the beginning/end OR
	# filled in as a buffer between the subsequent sequence trials
	int non_trials = non_seq_trials - ( ( seq_repeats - 1 ) * min_intervening_trials );
	non_trials = non_trials - min_start_trials - min_end_trials;

	# Start by creating start/end sequences where no non-random sequence trials occur
	array<int> start_seq[min_start_trials];
	array<int> end_seq[min_end_trials];
	
	# Build a sequence for the middle portion. 1's stand in for the learned sequence for the moment.
	array<int> mid_seq[seq_repeats + non_trials];
	mid_seq.fill( 1, seq_repeats, 1, 0 );

	loop
		int a = 1
	until
		a > block_order.count()
	begin
		# Start by shuffling the middle sequence
		mid_seq.shuffle();
		
		# Now append the start, middle, and end arrays
		array<int> temp_seq[0];
		temp_seq.append( start_seq );
		temp_seq.append( mid_seq );
		temp_seq.append( end_seq );

		# Now build a full sequence. Each "1" in the temp sequence
		# gets expanded out to include the full learned sequence
		array<int> full_seq[0][0];
		loop 
			bool first_learned = false;
			array<int> temp[2];
			int i = 1 
		until
			i > temp_seq.count()
		begin
			# When "0", then we're just adding a random value
			if ( temp_seq[i] == 0 ) then
				temp[STIM_IDX] = random( 1, RESPONSES );
				temp[SEQ_IDX] = 0;
				full_seq.add( temp );

			# Otherwise, we'll step through the learned sequence
			# and add one trial for each value in that sequence
			else
				if ( first_learned ) then
					loop
						int j = 1
					until
						j > min_intervening_trials
					begin
						temp[STIM_IDX] = random( 1, RESPONSES );
						temp[SEQ_IDX] = 0;
						full_seq.add( temp );
						j = j + 1;
					end;
				end;
				loop
					int j = 1
				until
					j > learned_seq.count()
				begin
					temp[STIM_IDX] = learned_seq[j];
					temp[SEQ_IDX] = j;
					full_seq.add( temp );
					j = j + 1;
				end;
				first_learned = true;
			end;
			i = i + 1;
		end;
		block_order[a].assign( full_seq );
		
		a = a + 1;
	end;
	
	# Add some practice trials
	int prac_trials = parameter_manager.get_int( "Practice Trials" );
	loop
	until
		prac_array.count() >= prac_trials
	begin
		array<int> temp[2];
		temp[STIM_IDX] = random( 1, RESPONSES );
		temp[SEQ_IDX] = 0;
		prac_array.add( temp );
	end;
end;

# --- Main Sequence ---

string instructions = get_lang_item( lang, "Instructions" );
bool show_block_status = parameter_manager.get_bool( "Show Status Between Blocks" );
int prac_threshold = parameter_manager.get_int( "Minimum Percent Correct to Complete Practice" );

# Show practice trials or instructions
if ( prac_array.count() > 0 ) then
	main_instructions( instructions + " " + get_lang_item( lang, "Practice Caption" ) );
	loop 
		double block_accuracy = -1.0
	until 
		block_accuracy >= ( double( prac_threshold ) / 100.0 )
	begin
		block_accuracy = show_block( PRACTICE_TYPE_PRACTICE, prac_array, 0 );
	end;
	present_instructions( get_lang_item( lang, "Practice Complete Caption" ) );
else
	main_instructions( instructions );
end;

loop
	int i = 1
until
	i > block_order.count()
begin
	show_block( PRACTICE_TYPE_MAIN, block_order[i], i );
	
	# Update participant
	if ( show_block_status ) then
		block_status( block_order.count(), i );
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
	sum_log = sum_log.substring( 1, ext - 1 ) + "-Summary-" + date_time( "yyyymmdd-hhnnss" ) + ".txt";
	string subj = logfile.subject();
	output_file out = new output_file;
	out.open( sum_log );

	# Print the headings for each columns
	array<string> cond_headings[cond_names.count() + 1];
	cond_headings[1] = "Subject ID";
	cond_headings[SUM_COND_IDX + 1] = "Condition";
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