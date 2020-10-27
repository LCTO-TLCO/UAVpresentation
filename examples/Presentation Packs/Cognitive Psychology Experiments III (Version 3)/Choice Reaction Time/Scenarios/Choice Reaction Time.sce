# -------------------------- Header Parameters --------------------------

scenario = "Choice Reaction Time";

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
	trial_number, number,
	stim_type, string,
	tgt_number, number,
	ISI_dur, number;
event_code_delimiter = ";";

# ------------------------------- SDL Part ------------------------------
begin;

array {
	picture {};
	picture {};
} stim_pics;

sound { wavefile { filename = ""; preload = false; }; };

text { 
	caption = "+"; 
	font_size = EXPARAM( "Fixation Point Size" ); 
} fix_text; 

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
	trial_type = specific_response;
	terminator_button = 1,2;
	trial_duration = forever;
	clear_active_stimuli = false;
	all_responses = false;
	
	stimulus_event {
		picture {};
	} tgt_event;
} tgt_trial;

trial {
	stimulus_event {
		picture {} ISI_pic;
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
int BUTTON_FWD = 2;
int BUTTON_BWD = 1;

string PRACTICE_TYPE_PRACTICE = "Practice";
string PRACTICE_TYPE_MAIN = "Main";

string CHARACTER_WRAP = "Character";

string STIM_STRING = "String";
string STIM_BOX = "Box";
string STIM_IMAGE = "Image";
string STIM_ELLIPSE = "Ellipse";
string STIM_SOUND = "Sound";

int STIM_IDX = 1;
int ISI_IDX = 2;

string COND_STIM_ONE = "Stim One";
string COND_STIM_TWO = "Stim Two";

array<int> buttons[2] = { 1,2 };
array<int> p_codes[2] = { 10,20 };

string EVENT_MARKER = "Target";

string LANGUAGE_FILE_STIM_ONE_LABEL = "[STIM_ONE_DESCRIPTION]";
string LANGUAGE_FILE_STIM_TWO_LABEL = "[STIM_TWO_DESCRIPTION]";

# --- Set up fixed stimulus parameters ---

string language = parameter_manager.get_string( "Language" );
language_file lang = load_language_file( scenario_directory + language + ".xml" );
bool char_wrap = ( get_lang_item( lang, "Word Wrap Mode" ).lower() == CHARACTER_WRAP.lower() );

adjust_used_screen_size( parameter_manager.get_bool( "Use Widescreen if Available" ) );

double font_size = parameter_manager.get_double( "Default Font Size" );

# Set duration of the target trial
begin
	int tgt_dur = parameter_manager.get_int( "Target Duration" );
	if ( tgt_dur > 0 ) then
		trial_refresh_fix( tgt_trial, tgt_dur );
	end;
	tgt_event.set_stimulus_time_in( parameter_manager.get_int( "Minimum Allowable RT" ) );
	tgt_event.set_stimulus_time_out( parameter_manager.get_int( "Maximum Allowable RT" ) );
end;

# Set up ISI picture
if ( parameter_manager.get_bool( "Show Fixation During ISI" ) ) then
	ISI_pic.add_part( fix_text, 0, 0 );
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

# --- Set up the stimuli ---

array<stimulus> tgt_stims[2];
tgt_stims[1] = stim_pics[1];
tgt_stims[2] = stim_pics[2];

array<string> stim_types[2];
stim_types[1] = parameter_manager.get_string( "Target One Type" );
stim_types[2] = parameter_manager.get_string( "Target Two Type" );

# Exit if crossed modalities
if ( stim_types[1] != stim_types[2] ) then
	if ( stim_types[1] == STIM_SOUND ) || ( stim_types[2] == STIM_SOUND ) then
		exit( "Error: Both target stimuli must be the same modality (either auditory or visual)." );
	end;
end;

# Update the first target stimulus
if ( stim_types[1] == STIM_SOUND ) then
	sound stim_snd = parameter_manager.get_sound( "Target One Sound" );
	tgt_stims[1] = stim_snd;
	lang.set_map( STIM_SOUND );
elseif ( stim_types[1] == STIM_IMAGE ) then
	bitmap stim_bmp = parameter_manager.get_bitmap( "Target One Image" );
	stim_bmp.set_load_size( 0.0, 0.0, double( parameter_manager.get_int( "Target One Image Scaling" ) ) * 0.01 );
	stim_bmp.load();
	stim_pics[1].add_part( stim_bmp, 0, 0 );
elseif ( stim_types[1] == STIM_STRING ) then
	text stim_text = new text();
	stim_text.set_font_size( parameter_manager.get_double( "Target One Font Size" ) );
	stim_text.set_font_color( parameter_manager.get_color( "Target One Color" ) );
	string stim_cap = parameter_manager.get_string( "Target One String" );
	if ( stim_cap.count() == 0 ) then
		exit( "Error: 'Target One String' cannot be empty." );
	else
		stim_text.set_caption( stim_cap, true );
	end;
	stim_pics[1].add_part( stim_text, 0, 0 );
elseif ( stim_types[1] == STIM_ELLIPSE ) then
	ellipse_graphic stim_ellipse = new ellipse_graphic();
	stim_ellipse.set_dimensions( parameter_manager.get_double( "Target One Width" ), parameter_manager.get_double( "Target One Height" ) );
	stim_ellipse.set_color( parameter_manager.get_color( "Target One Color" ) );
	stim_ellipse.redraw();
	stim_pics[1].add_part( stim_ellipse, 0, 0 );
elseif ( stim_types[1] == STIM_BOX ) then
	box stim_box = new box( 1.0, 1.0, parameter_manager.get_color( "Target One Color" ) );
	stim_box.set_height( parameter_manager.get_double( "Target One Height" ) );
	stim_box.set_width( parameter_manager.get_double( "Target One Width" ) );
	stim_pics[1].add_part( stim_box, 0, 0 );
end;

# Update the second target stimulus
if ( stim_types[2] == STIM_SOUND ) then
	sound stim_snd = parameter_manager.get_sound( "Target Two Sound" );
	tgt_stims[2] = stim_snd;
	lang.set_map( STIM_SOUND );
elseif ( stim_types[2] == STIM_IMAGE ) then
	bitmap stim_bmp = parameter_manager.get_bitmap( "Target Two Image" );
	stim_bmp.set_load_size( 0.0, 0.0, double( parameter_manager.get_int( "Target Two Image Scaling" ) ) * 0.01 );
	stim_bmp.load();
	stim_pics[2].add_part( stim_bmp, 0, 0 );
elseif ( stim_types[2] == STIM_STRING ) then
	text stim_text = new text();
	stim_text.set_font_size( parameter_manager.get_double( "Target Two Font Size" ) );
	stim_text.set_font_color( parameter_manager.get_color( "Target Two Color" ) );
	string stim_cap = parameter_manager.get_string( "Target Two String" );
	if ( stim_cap.count() == 0 ) then
		exit( "Error: 'Target Two String' cannot be empty." );
	else
		stim_text.set_caption( stim_cap, true );
	end;
	stim_pics[2].add_part( stim_text, 0, 0 );
elseif ( stim_types[2] == STIM_ELLIPSE ) then
	ellipse_graphic stim_ellipse = new ellipse_graphic();
	stim_ellipse.set_dimensions( parameter_manager.get_double( "Target Two Width" ), parameter_manager.get_double( "Target Two Height" ) );
	stim_ellipse.set_color( parameter_manager.get_color( "Target Two Color" ) );
	stim_ellipse.redraw();
	stim_pics[2].add_part( stim_ellipse, 0, 0 );
elseif ( stim_types[2] == STIM_BOX ) then
	box stim_box = new box( 1.0, 1.0, parameter_manager.get_color( "Target Two Color" ) );
	stim_box.set_height( parameter_manager.get_double( "Target Two Height" ) );
	stim_box.set_width( parameter_manager.get_double( "Target Two Width" ) );
	stim_pics[2].add_part( stim_box, 0, 0 );
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

# -- Set up info for summary stats -- #
int SUM_TYPE_IDX = 1;

# Put all the condition names into an array
# Used later to add column headings
array<string> cond_names[1][2];
cond_names[SUM_TYPE_IDX][1] = COND_STIM_ONE;
cond_names[SUM_TYPE_IDX][2] = COND_STIM_TWO;
cond_names[SUM_TYPE_IDX].add( "All" );
int total_rt_idx = cond_names[SUM_TYPE_IDX].count();

# Now build an empty array for all DVs of interest
array<int> acc_stats[cond_names[1].count()][0];
array<int> RT_stats[cond_names[1].count()][0];
# --- End Summary Stats --- #

sub
	show_block( array<int,2>& trial_array, string prac_check )
begin
	# Shuffle the ISI ordering
	trial_array.shuffle();
	
	# Loop to present trials
	loop
		int i = 1
	until
		i > trial_array.count()
	begin
		# Trial info
		int this_stim = trial_array[i][STIM_IDX];
		int this_ISI = trial_array[i][ISI_IDX];
		
		# Set ISI
		trial_refresh_fix( ISI_trial, this_ISI );
		
		# Set event code
		tgt_event.set_event_code( 
			EVENT_MARKER + ";" +
			prac_check + ";" +
			string( i ) + ";" +
			stim_types[this_stim] + ";" +
			string( this_stim ) + ";" +
			string( this_ISI )
		);
		
		# Set target button
		tgt_event.set_target_button( buttons[this_stim] );
		
		# Set port code
		tgt_event.set_port_code( p_codes[this_stim] );
		
		# Set stimulus
		tgt_event.set_stimulus( tgt_stims[this_stim] );
		
		# Trial sequence
		ISI_trial.present();
		tgt_trial.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		
		# Record trial info for summary stats
		if ( prac_check == PRACTICE_TYPE_MAIN ) then
			# Make an int array specifying the condition we're in
			# This tells us which subarray to store the trial info
			array<int> this_trial[cond_names.count()];
			this_trial[SUM_TYPE_IDX] = this_stim;

			int this_hit = int( last.type() == last.HIT );
			acc_stats[this_trial[1]].add( this_hit );
			acc_stats[total_rt_idx].add( this_hit );
			if ( last.reaction_time() > 0 ) then
				RT_stats[this_trial[1]].add( last.reaction_time() );
				RT_stats[total_rt_idx].add( last.reaction_time() );
			end;
		end;

		# Show rest
		if ( prac_check == PRACTICE_TYPE_MAIN ) then
			if ( show_rest( i, trial_array.count() ) ) then
				ISI_trial.present();
			end;
		end;
		
		i = i + 1
	end;
	ISI_trial.present();
end;

# --- Conditions & Trial Order --- #

array<int> cond_array[0][0];
array<int> prac_array[0][0];

begin
	# Grab the possible ISI durations and exit if not specified
	array<int> ISI_durations[0];
	parameter_manager.get_ints( "ISI Durations", ISI_durations );
	if ( ISI_durations.count() == 0 ) then
		exit( "Error: 'ISI Durations' must contain at least one value." );
	end;
	ISI_durations.shuffle();
	
	# Build the condition array based on the requested stim 1/stim 2 trials
	int one_trials = parameter_manager.get_int( "Target One Trials" );
	int two_trials = parameter_manager.get_int( "Target Two Trials" );
	loop
		array<int> temp[2];
		int i = 1
	until
		i > one_trials && i > two_trials
	begin
		temp[ISI_IDX] = ISI_durations[( i % ISI_durations.count() ) + 1];
		if ( i <= one_trials ) then
			temp[STIM_IDX] = 1;
			cond_array.add( temp );
		end;
		if ( i <= two_trials ) then
			temp[STIM_IDX] = 2;
			cond_array.add( temp );
		end;
		i = i + 1;
	end;

	int prac_trials = parameter_manager.get_int( "Practice Trials" );
	loop
	until
		prac_array.count() >= prac_trials
	begin
		prac_array.add( cond_array[random( 1,cond_array.count() )] );
	end;
end;

# --- Main Sequence ---

string instructions = get_lang_item( lang, "Instructions" );
instructions = instructions.replace( LANGUAGE_FILE_STIM_ONE_LABEL, parameter_manager.get_string( "Target One Description" ) );
instructions = instructions.replace( LANGUAGE_FILE_STIM_TWO_LABEL, parameter_manager.get_string( "Target Two Description" ) );
string prac_caption = get_lang_item( lang, "Practice Caption" );
string prac_complete_caption = get_lang_item( lang, "Practice Complete Caption" );

if ( prac_array.count() > 0 ) then
	main_instructions( instructions + " " + prac_caption );
	show_block( prac_array, PRACTICE_TYPE_PRACTICE );
	present_instructions( prac_complete_caption );
else
	main_instructions( instructions );
end;
show_block( cond_array, PRACTICE_TYPE_MAIN );
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
	cond_headings[SUM_TYPE_IDX + 1] = "Stimulus";
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