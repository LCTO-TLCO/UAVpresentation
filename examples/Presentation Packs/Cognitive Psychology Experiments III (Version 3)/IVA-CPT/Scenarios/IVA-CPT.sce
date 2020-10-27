# -------------------------- Header Parameters --------------------------

scenario = "IVA-CPT";

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
	target_id, number,
	stim_number, number,
	tgt_cond, string,
	modality, string,
	ISI_dur, number;
event_code_delimiter = ";";

# ------------------------------- SDL Part ------------------------------
begin;

sound { wavefile { filename = ""; preload = false; }; };

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

string TARGET_NUMBER_LABEL = "[TARGET_NUMBER]";

string LANGUAGE_FILE_TOTAL_BLOCKS_LABEL = "[TOTAL_BLOCKS]";
string LANGUAGE_FILE_BLOCK_NUMBER_LABEL = "[BLOCK_NUMBER]";

string STIM_EVENT_CODE = "Stim";

string COND_AUDITORY = "Auditory";
string COND_VISUAL = "Visual";

string COND_TARGET = "Target";
string COND_DIST = "Distractor";

int BUTTON_TGT = 1;
int BUTTON_DIST = 0;

int COND_TGT_IDX = 1;
int COND_DIST_IDX = 2;

int MOD_IDX = 1;
int STIM_IDX = 2;

int COND_AUD_IDX = 1;
int COND_VIS_IDX = 2;

int AUD_TGT_PORT_CODE = 11;
int VIS_TGT_PORT_CODE = 21;
int AUD_DIST_PORT_CODE = 12;
int VIS_DIST_PORT_CODE = 22;

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

sub
	int get_port_code( int modality, int stim_type )
begin
	if ( modality == COND_AUD_IDX ) && ( stim_type == COND_TGT_IDX ) then
		return AUD_TGT_PORT_CODE
	elseif( modality == COND_AUD_IDX ) && ( stim_type == COND_DIST_IDX ) then
		return AUD_DIST_PORT_CODE
	elseif ( modality == COND_VIS_IDX ) && ( stim_type == COND_TGT_IDX ) then
		return VIS_TGT_PORT_CODE
	end;
	return VIS_DIST_PORT_CODE
end;

# --- sub show_block

array<string> mod_names[2];
mod_names[COND_AUD_IDX] = COND_AUDITORY;
mod_names[COND_VIS_IDX] = COND_VISUAL;

array<string> type_names[2];
type_names[COND_TGT_IDX] = COND_TARGET;
type_names[COND_DIST_IDX] = COND_DIST;

array<int> buttons[2];
buttons[COND_TGT_IDX] = BUTTON_TGT;
buttons[COND_DIST_IDX] = BUTTON_DIST;

array<int> ISI_durations[0];
parameter_manager.get_ints( "ISI Durations", ISI_durations );
if ( ISI_durations.count() == 0 ) then
	exit( "Error: 'ISI Durations' must contain at least one value." );
end;

array<sound> stim_sounds[0];
parameter_manager.get_sounds( "Stimulus Sounds", stim_sounds );
if ( stim_sounds.count() != 9 ) then
	exit( "Error: 'Stimulus Sounds' must contain nine files, representing the digits 1-9." );
end;

# -- Set up info for summary stats -- #
int SUM_COND_IDX = 1;
int SUM_MOD_IDX = 2;

# Put all the condition names into an array
# Used later to add column headings
array<string> cond_names[2][0];
cond_names[SUM_COND_IDX].assign( type_names );
cond_names[SUM_MOD_IDX].assign( mod_names );

# Now build an empty array for all DVs of interest
array<int> acc_stats[cond_names[1].count()][cond_names[2].count()][0];
array<int> RT_stats[cond_names[1].count()][cond_names[2].count()][0];
# --- End Summary Stats --- #*/


sub
	double show_block( array<int,2>& cond_array, int tgt_id, int block_number, string prac_check )
begin
	# Shuffle the trial order
	cond_array.shuffle();
	
	# Show an ISI
	trial_refresh_fix( ISI_trial, ISI_durations[random(1,ISI_durations.count())] );
	ISI_trial.present();
	
	# Loop to present trials
	double block_acc = 0.0;
	loop
		int hits = 0;
		int i = 1
	until
		i > cond_array.count()
	begin
		# Condition info
		int this_mode = cond_array[i][MOD_IDX];
		int this_stim = cond_array[i][STIM_IDX];
		
		# First get the stimulus number
		int stim_num = random_exclude( 1,9,tgt_id );
		if ( this_stim == COND_TGT_IDX ) then
			stim_num = tgt_id;
		end;
		
		# Set the auditory or visual stimulus
		if ( this_mode == COND_AUD_IDX ) then
			stim_event.set_stimulus( stim_sounds[stim_num] );
		else
			stim_text.set_caption( string( stim_num ), true );
			stim_event.set_stimulus( stim_pic );
		end;
	
		# Set ISI
		trial_refresh_fix( ISI_trial, ISI_durations[random(1,ISI_durations.count())] );
		
		# Set target button
		stim_event.set_target_button( buttons[this_stim] );
		stim_event.set_response_active( true );
		
		# Set port code
		int p_code = get_port_code( this_mode, this_stim );
		stim_event.set_port_code( p_code );
		
		# Set event code
		stim_event.set_event_code( 
			STIM_EVENT_CODE + ";" +
			prac_check + ";" + 
			string( block_number ) + ";" +
			string( i ) + ";" +
			string( tgt_id ) + ";" +
			string( stim_num ) + ";" +
			type_names[this_stim] + ";" +
			mod_names[this_mode] + ";" +
			string( ISI_trial.duration() )
		);
		
		# Stim sequence
		stim_trial.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		ISI_trial.present();
		
		# Update block accuracy
		if ( last.type() == last.HIT ) || ( last.type() == last.OTHER ) then
			hits = hits + 1;
		end;
		block_acc = double( hits ) / double ( i );
		
		# Record trial info for summary stats
		# Make an int array specifying the condition we're in
		# This tells us which subarray to store the trial info
		if ( prac_check == PRACTICE_TYPE_MAIN ) then
			array<int> this_trial[cond_names.count()];
			this_trial[SUM_COND_IDX] = this_stim;
			this_trial[SUM_MOD_IDX] = this_mode;
			
			int this_hit = int( last.type() == last.HIT || last.type() == last.OTHER );
			acc_stats[this_trial[1]][this_trial[2]].add( this_hit );
			if ( last.reaction_time() > 0 ) then
				RT_stats[this_trial[1]][this_trial[2]].add( last.reaction_time() );
			end;
		end;
	
		i = i + 1;
	end;
	return block_acc
end;

# --- Conditions and Trial Order --- #

array<int> cond_array[0][0][0];
array<int> tgt_order[0];
array<int> prac_array[0][0];

begin
	int num_blocks = parameter_manager.get_int( "Blocks" );
	cond_array.resize( num_blocks );
	
	array<int> vis_tgts[0];
	parameter_manager.get_ints( "Visual Targets per Block", vis_tgts );
	if ( vis_tgts.count() != num_blocks ) then
		exit( "Error: 'Visual Targets per Block' must contain 'Blocks' elements  (one value per block)." );
	end;

	array<int> aud_tgts[0];
	parameter_manager.get_ints( "Auditory Targets per Block", aud_tgts );
	if ( aud_tgts.count() != num_blocks ) then
		exit( "Error: 'Auditory Targets per Block' must contain 'Blocks' elements  (one value per block)." );
	end;
	
	array<int> vis_dists[0];
	parameter_manager.get_ints( "Visual Distractors per Block", vis_dists );
	if ( vis_dists.count() != num_blocks ) then
		exit( "Error: 'Visual Distractors per Block' must contain 'Blocks' elements (one value per block)." );
	end;
	
	array<int> aud_dists[0];
	parameter_manager.get_ints( "Auditory Distractors per Block", aud_dists );
	if ( aud_dists.count() != num_blocks ) then
		exit( "Error: 'Auditory Distractors per Block' must contain 'Blocks' elements  (one value per block)." );
	end;
	
	array<int> block_order[num_blocks];
	block_order.fill( 1, 0, 1, 1 );
	if ( parameter_manager.get_bool( "Randomize Block Order" ) ) then
		block_order.shuffle();
	end;
	
	# Make/get the array with the targets for each block, or use random targets if requested
	array<int> temp_tgt_order[0];
	parameter_manager.get_ints( "Block Targets", temp_tgt_order );
	if ( parameter_manager.get_bool( "Random Block Targets" ) ) then
		temp_tgt_order.resize( 0 );
		loop
			int i = 1
		until
			i > block_order.count()
		begin
			temp_tgt_order.add( random( 1,9 ) );
			i = i + 1;
		end;
	end;
	if ( temp_tgt_order.count() != num_blocks ) then
		exit( "Error: 'Block Targets' must contain 'Blocks' elements (one value per block)." );
	end;

	bool prac_added_tgt = false;
	loop
		int i = 1
	until
		i > block_order.count()
	begin
		int this_block = block_order[i];
		
		# Add the target
		tgt_order.add( temp_tgt_order[this_block] );
		
		# Add auditory targets
		array<int> temp[2];
		temp[MOD_IDX] = COND_AUD_IDX;
		temp[STIM_IDX] = COND_TGT_IDX;
		loop
			int j = 1
		until
			j > aud_tgts[this_block]
		begin
			cond_array[i].add( temp );
			if ( !prac_added_tgt ) then
				prac_array.add( temp );
				prac_added_tgt = true;
			end;
			j = j + 1;
		end;
		
		# Add auditory distractors
		temp[STIM_IDX] = COND_DIST_IDX;
		loop	
			int j = 1
		until
			j > aud_dists[this_block]
		begin
			cond_array[i].add( temp );
			j = j + 1;
		end;
		
		# Add visual distractors
		temp[MOD_IDX] = COND_VIS_IDX;
		loop
			int j = 1
		until
			j > vis_dists[this_block]
		begin
			cond_array[i].add( temp );
			j = j + 1;
		end;
		
		# Add visual targets
		temp[STIM_IDX] = COND_TGT_IDX;
		loop
			int j = 1 
		until
			j > vis_tgts[this_block]
		begin
			cond_array[i].add( temp );
			if ( !prac_added_tgt ) then
				prac_array.add( temp );
				prac_added_tgt = true;
			end;
			j = j + 1;
		end;
		
		i = i + 1;
	end;
	
	# Make some practice trials
	int prac_trials = parameter_manager.get_int( "Practice Trials" );
	loop
	until
		prac_array.count() >= prac_trials
	begin
		prac_array.add( cond_array[1][random(1, cond_array[1].count())] );
	end;
	if ( prac_trials == 1 ) then
		prac_array.shuffle();
	end;
	prac_array.resize( prac_trials );
end;

# --- Main Sequence ---

string instructions = get_lang_item( lang, "Instructions" );
string simple_instrucs = get_lang_item( lang, "Simple Instructions" );
string prac_caption = get_lang_item( lang, "Practice Caption" );
bool show_block_status = parameter_manager.get_bool( "Show Status Between Blocks" );
int prac_threshold = parameter_manager.get_int( "Minimum Percent Correct to Complete Practice" );

# Show practice trials or instructions
if ( prac_array.count() > 0 ) then
	# Get the target
	int prac_tgt = random( 1,9 );
	
	# Show the instructions
	string temp_instrucs = instructions.replace( TARGET_NUMBER_LABEL, string( prac_tgt ) );
	temp_instrucs = temp_instrucs + " " + prac_caption;
	main_instructions( temp_instrucs );
	
	# Show the practice trials
	loop 
		double block_accuracy = -1.0
	until 
		block_accuracy >= ( double( prac_threshold ) / 100.0 )
	begin
		block_accuracy = show_block( prac_array, prac_tgt, 0, PRACTICE_TYPE_PRACTICE );
	end;
	present_instructions( get_lang_item( lang, "Practice Complete Caption" ) );
end;

loop
	int i = 1
until
	i > cond_array.count()
begin
	# Show the instructions
	string temp_instrucs = instructions.replace( TARGET_NUMBER_LABEL, string( tgt_order[i] ) );
	if ( i > 1 ) || ( prac_array.count() > 0 ) then
		temp_instrucs = simple_instrucs.replace( TARGET_NUMBER_LABEL, string( tgt_order[i] ) );
	end;
	main_instructions( temp_instrucs );
	
	# Block trials
	show_block( cond_array[i], tgt_order[i], i, PRACTICE_TYPE_MAIN );
	
	# Update participant
	if ( show_block_status ) then
		block_status( cond_array.count(), i );
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
	cond_headings[SUM_COND_IDX + 1] = "Stim Type";
	cond_headings[SUM_MOD_IDX + 1] = "Stim Modality";
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