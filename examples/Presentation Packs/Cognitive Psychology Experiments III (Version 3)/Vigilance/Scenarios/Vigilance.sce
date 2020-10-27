# -------------------------- Header Parameters --------------------------

scenario = "Vigilance";

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
	tgt_location, string,
	stim_type, string,
	ISI_dur, number;
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
	};
} instruct_trial;

trial {
	clear_active_stimuli = false;
	
	stimulus_event {
		picture {} stim_pic;
	} stim_event;
} stim_trial;

trial {
	stimulus_event {
		picture {
			text { 
				caption = "+"; 
				font_size = EXPARAM( "Fixation Point Size" );
				font_color = EXPARAM( "Fixation Point Color" );
			} fix_text;
			x = 0;
			y = 0;
		} ISI_pic;
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
int BUTTON_FWD = 1;
int BUTTON_BWD = 0;

string STIM_EVENT_CODE = "Stim";

string PRACTICE_TYPE_PRACTICE = "Practice";
string PRACTICE_TYPE_MAIN = "Main";

string COND_TGT = "Target";
string COND_NTGT = "Non-target";

string LANGUAGE_FILE_TOTAL_BLOCKS_LABEL = "[TOTAL_BLOCKS]";
string LANGUAGE_FILE_BLOCK_NUMBER_LABEL = "[BLOCK_NUMBER]";

string TARGET_SIDE_LABEL = "[TARGET_SIDE]";

string TGT_LEFT = "Left";
string TGT_RIGHT = "Right";
string TGT_TOP = "Top";
string TGT_BOTTOM = "Bottom";

int PORT_CODE_TGT = 10;
int PORT_CODE_NTGT = 110;

int COND_TGT_IDX = 1;
int COND_NTGT_IDX = 2;

int BUTTON_TGT = 1;
int BUTTON_NTGT = 0;

string CHARACTER_WRAP = "Character";

# --- Set up fixed stimulus parameters ---

string language = parameter_manager.get_string( "Language" );
language_file lang = load_language_file( scenario_directory + language + ".xml" );
bool char_wrap = ( get_lang_item( lang, "Word Wrap Mode" ).lower() == CHARACTER_WRAP.lower() );

adjust_used_screen_size( parameter_manager.get_bool( "Use Widescreen if Available" ) );

double font_size = parameter_manager.get_double( "Default Font Size" );

trial_refresh_fix( stim_trial, parameter_manager.get_int( "Stimulus Duration" ) );

# --- Stimulus Setup ---

array<double> stim_locs[2][2] = { { 0.0, 0.0 }, { 0.0, 0.0 } };
string tgt_pos = parameter_manager.get_string( "Target Position" );

box stim_box = new box( 1.0, 1.0, parameter_manager.get_color( "Stimulus Box Color" ) );
box tgt_box = new box( 1.0, 1.0, parameter_manager.get_color( "Target Color" ) );
int box_part;

begin;
	# Grab the box dimensions from parameter settings, exit if bad
	array<double> stim_dims[0];
	parameter_manager.get_doubles( "Stimulus Box Dimensions", stim_dims );
	if ( stim_dims.count() != 2 ) then
		exit( "Error: 'Stimulus Box Dimensions' must contain two values (width and height)." );
	end;

	array<double> tgt_dims[0];
	parameter_manager.get_doubles( "Target Dimensions", tgt_dims );
	if ( tgt_dims.count() != 2 ) then
		exit( "Error: 'Target Dimensions' must contain two values (width and height)." );
	end;

	# Set the box sizes
	stim_box.set_width( stim_dims[1] );
	stim_box.set_height( stim_dims[2] );
	tgt_box.set_width( tgt_dims[1] );
	tgt_box.set_height( tgt_dims[2] );
	
	# Find the positions of the tgt and stimulus boxes
	# Based on buffer size and parameter setting
	double buffer = parameter_manager.get_double( "Target Position Buffer" );
	if ( tgt_pos == TGT_LEFT ) || ( tgt_pos == TGT_RIGHT ) then
		if ( tgt_dims[1] + buffer >= ( stim_dims[1]/2.0 ) ) then
			exit( "Error: Target width must be less than half the total stimulus width for left/right targets." );
		end;
		double temp_pos = ( stim_dims[1]/2.0 ) - ( tgt_dims[1]/2.0 ) - buffer;
		if ( tgt_pos == TGT_LEFT ) then
			stim_locs[COND_TGT_IDX][1] = -temp_pos;
			stim_locs[COND_NTGT_IDX][1] = temp_pos;
		else
			stim_locs[COND_TGT_IDX][1] = temp_pos;
			stim_locs[COND_NTGT_IDX][1] = -temp_pos;
		end;
	else
		if ( tgt_dims[2] + buffer >= ( stim_dims[2]/2.0 ) ) then
			exit( "Error: Target height must be less than half the total stimulus height for top/bottom targets." );
		end;
		double temp_pos = ( stim_dims[2]/2.0 ) - ( tgt_dims[2]/2.0 ) - buffer;
		if ( tgt_pos == TGT_TOP ) then
			stim_locs[COND_TGT_IDX][2] = temp_pos;
			stim_locs[COND_NTGT_IDX][2] = -temp_pos;
		else
			stim_locs[COND_TGT_IDX][2] = -temp_pos;
			stim_locs[COND_NTGT_IDX][2] = temp_pos;
		end;
	end;
	
	# Add the stim and tgt to the stim picture
	stim_pic.add_part( stim_box, 0, 0 );
	stim_pic.add_part( tgt_box, 0, 0 );
	box_part = stim_pic.part_count();
	
	# Build the ISI pic
	ISI_pic.clear();
	if ( parameter_manager.get_bool( "Show Stimulus Box During ISI" ) ) then
		ISI_pic.add_part( stim_box, 0, 0 );
		fix_text.set_background_color( parameter_manager.get_color( "Stimulus Box Color" ) );
		fix_text.redraw();
	end;
	if ( parameter_manager.get_bool( "Show Fixation Point" ) ) then
		ISI_pic.add_part( fix_text, 0, 0 );
		fix_text.redraw();
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

# --- sub show_block

int num_blocks = parameter_manager.get_int( "Blocks" );

array<int> ISI_durations[0];
parameter_manager.get_ints( "ISI Durations", ISI_durations );
if ( ISI_durations.count() == 0 ) then
	exit( "Error: 'ISI Durations' must contain at least one value." );
end;

array<string> tgt_conds[2];
tgt_conds[COND_TGT_IDX] = COND_TGT;
tgt_conds[COND_NTGT_IDX] = COND_NTGT;

array<int> buttons[2];
buttons[COND_TGT_IDX] = BUTTON_TGT;
buttons[COND_NTGT_IDX] = BUTTON_NTGT;

array<int> p_codes[2];
p_codes[COND_TGT_IDX] = PORT_CODE_TGT;
p_codes[COND_NTGT_IDX] = PORT_CODE_NTGT;

# -- Set up info for summary stats -- #
int SUM_BLOCK_IDX = 1;
int SUM_COND_IDX = 2;

# Put all the condition names into an array
# Used later to add column headings
array<string> cond_names[2][0];
cond_names[SUM_COND_IDX].assign( tgt_conds );
loop
	int i = 1
until
	i > num_blocks
begin
	cond_names[SUM_BLOCK_IDX].add( string(i) );
	i = i + 1;
end;

# Now build an empty array for all DVs of interest
array<int> acc_stats[cond_names[1].count()][cond_names[2].count()][0];
array<int> RT_stats[cond_names[1].count()][cond_names[2].count()][0];
# --- End Summary Stats --- #

sub
	double show_block( array<int,1>& block_order, string prac_check, int block_num )
begin
	# Randomize the trial order
	block_order.shuffle();
	
	# Start with an ISI
	trial_refresh_fix( ISI_trial, ISI_durations[random(1,ISI_durations.count())] );
	ISI_trial.present();
	
	# Show the trials
	double block_acc = 0.0;
	loop
		int hits = 0;
		int i = 1
	until
		i > block_order.count()
	begin
		int this_stim = block_order[i];

		# Set up the picture
		stim_pic.set_part_x( box_part, stim_locs[this_stim][1] );
		stim_pic.set_part_y( box_part, stim_locs[this_stim][2] );
		
		# Set target button
		stim_event.set_target_button( buttons[this_stim] );
		stim_event.set_response_active( true );

		# Set ISI
		trial_refresh_fix( ISI_trial, ISI_durations[random(1,ISI_durations.count())] );
		
		# Set port code
		stim_event.set_port_code( p_codes[this_stim] );
		
		# Set event code
		stim_event.set_event_code( 
			STIM_EVENT_CODE + ";" + 
			prac_check + ";" +
			string( block_num ) + ";" +
			string( i ) + ";" +
			tgt_pos + ";" +
			tgt_conds[this_stim] + ";" +
			string( ISI_trial.duration() )
		);
			
		# Present the trial sequence
		stim_trial.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		ISI_trial.present();
		
		# Update the block accuracy
		if ( last.type() == last.HIT ) || ( last.type() == last.OTHER ) then
			hits = hits + 1;
		end;
		block_acc = double( hits ) / double( i );
		
		# Record trial info for summary stats
		if ( prac_check == PRACTICE_TYPE_MAIN ) then
			# Make an int array specifying the condition we're in
			# This tells us which subarray to store the trial info
			array<int> this_trial[cond_names.count()];
			this_trial[SUM_BLOCK_IDX] = block_num;
			this_trial[SUM_COND_IDX] = this_stim;
			
			int this_acc = int(  last.type() == last.HIT || last.type() == last.OTHER );
			acc_stats[this_trial[1]][this_trial[2]].add( this_acc );
			if ( last.reaction_time() > 0 ) then
				RT_stats[this_trial[1]][this_trial[2]].add( last.reaction_time() );
			end;
		end;

		
		i = i + 1;
	end;
	return block_acc
end;

# --- Conditions & Trial Order --- #

array<int> cond_array[0][0];
array<int> prac_array[0];

begin
	# Grab the trial counts
	array<int> tgt_set[0];
	parameter_manager.get_ints( "Targets per Block", tgt_set );
	array<int> ntgt_set[0];
	parameter_manager.get_ints( "Non-targets per Block", ntgt_set );
	
	# If the trial count arrays aren't the right size, then exit
	if ( tgt_set.count() != num_blocks ) || ( ntgt_set.count() != num_blocks ) then
		exit( "Error: 'Targets per Block' and 'Non-targets per Block' must both contain " + string( num_blocks ) + " values." );
	end;
	
	# Loop through the trial count arrays to build block orders
	# Add each block order to the cond array
	loop
		int i = 1
	until
		i > num_blocks
	begin
		# Make a temporary block order and fill it with the correct
		# number of targets and non-targets
		array<int> temp_block[tgt_set[i] + ntgt_set[i]];
		temp_block.fill( 1, 0, COND_TGT_IDX, 0 );
		temp_block.fill( 1, ntgt_set[i], COND_NTGT_IDX, 0 );
		
		# Shuffle the trial order
		temp_block.shuffle();
		
		# Add this block to the conditiona array
		cond_array.add( temp_block );
		i = i + 1;
	end;
	
	# Shuffle the block order if requested
	if ( parameter_manager.get_bool( "Randomize Block Order" ) ) then
		cond_array.shuffle();
	end;
	
	# Build the practice array
	int prac_trials = parameter_manager.get_int( "Practice Trials" );
	loop
	until
		prac_array.count() >= prac_trials
	begin
		prac_array.add( cond_array[1][random(1,cond_array[1].count())] );
	end;
end;

# --- Main Sequence --- 

bool show_block_status = parameter_manager.get_bool( "Show Status Between Blocks" );
int prac_threshold = parameter_manager.get_int( "Minimum Percent Correct to Complete Practice" );
string instructions = get_lang_item( lang, "Instructions" );
instructions = instructions.replace( TARGET_SIDE_LABEL, parameter_manager.get_string( "Target Position Label" ) );

# Practice trials and/or instructions
if ( prac_array.count() > 0 ) then
	main_instructions( instructions + " " + get_lang_item( lang, "Practice Caption" ) );
	loop
		double block_accuracy = -1.0
	until
		block_accuracy >= ( double( prac_threshold ) / 100.0 )
	begin
		block_accuracy = show_block( prac_array, PRACTICE_TYPE_PRACTICE, 0 );
	end;
	present_instructions( get_lang_item( lang, "Practice Complete Caption" ) );
else
	main_instructions( instructions );
end;

# loop to present blocks
loop
	int a = 1
until
	a > cond_array.count()
begin
	show_block( cond_array[a], PRACTICE_TYPE_MAIN, a );
	
	if ( show_block_status ) then
		block_status( cond_array.count(), a );
	end;
	
	a = a + 1;
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
	cond_headings[SUM_BLOCK_IDX + 1] = "Block";
	cond_headings[SUM_COND_IDX + 1] = "Target Type";
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
		loop
			int j = 1
		until
			j > acc_stats[i].count()
		begin
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
			j = j + 1;
		end;
		i = i + 1;
	end;

	# Close the file and exit
	out.close();
end;