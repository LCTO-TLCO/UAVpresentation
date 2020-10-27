# -------------------------- Header Parameters --------------------------

scenario = "Flankers ERN-LRP";

write_codes = EXPARAM( "Send Port Codes" );

screen_width_distance = EXPARAM( "Display Width" );
screen_height_distance = EXPARAM( "Display Height" );
screen_distance = EXPARAM( "Viewing Distance" );

default_background_color = EXPARAM( "Background Color" );
default_font = EXPARAM( "Non-Stimulus Font" );
default_font_size = EXPARAM( "Non-Stimulus Font Size" );
default_text_color = EXPARAM( "Non-Stimulus Font Color" );

active_buttons = 2;
response_matching = simple_matching;
default_clear_active_stimuli = false;
response_logging = EXPARAM( "Response Logging" );

stimulus_properties =
	event_name, string,
	block_name, string,
	block_number, number,
	trial_number, number,
	cent_char, string,
	flanker_char, string,
	num_flankers, number,
	compatibility, string,
	isi_duration, number,
	p_code, number;
event_code_delimiter = ";";

# ------------------------------- SDL Part ------------------------------
begin;

array {
	text {
		caption = "Left";
		font_size = EXPARAM( "Stimulus Size" );
		font_color = EXPARAM( "Stimulus Color" );
		font = EXPARAM( "Stimulus Font" );
		transparent_color = EXPARAM( "Background Color" );
		preload = false;
	} left_text;
	
	text {
		caption = "Right";
		font_size = EXPARAM( "Stimulus Size" );
		font_color = EXPARAM( "Stimulus Color" );
		font = EXPARAM( "Stimulus Font" );
		transparent_color = EXPARAM( "Background Color" );
		preload = false;
	} right_text;
} stim_texts;

ellipse_graphic {
	ellipse_width = EXPARAM( "Fixation Point Size" );
	ellipse_height = EXPARAM( "Fixation Point Size" );
	color = EXPARAM( "Fixation Point Color" );
} fix_ellipse;

trial {
	stimulus_event {
		picture {
			text { 
				caption = "Flankers Only"; 
				preload = false;
			} flanker_text;
			x = 0; 
			y = 0;
		} flanker_pic;
		code = "Flankers";
	} flanker_event;
} flanker_trial;
	
trial {
	trial_type = first_response;
	clear_active_stimuli = false;
	
	stimulus_event {
		picture {
			text left_text;
			x = 0;
			y = 0;
		} target_pic;
		response_active = true;
	} target_event;
} target_trial;
		
trial {
	clear_active_stimuli = true;
	stimulus_event {
		picture { 	
			ellipse_graphic fix_ellipse;
			x = 0;
			y = 0;
		} isi_pic;
		code = "ISI";
	} isi_event;
} isi_trial;
	
trial{
	trial_type = first_response;
	trial_duration = forever;
	
	picture{
		text { 
			caption = "rest";
			preload = false;
		} instruct_text;
		x = 0; y = 0;
	} instruct_pic;
} instruct_trial;

trial {
	picture {
		text {
			caption = "Ready";
			preload = false;
		} ready_text;
		x = 0;
		y = 0;
	} ready_pic;
} ready_trial;
		
# ----------------------------- PCL Program -----------------------------
begin_pcl;

include_once "../../Library/lib_visual_utilities.pcl";
include_once "../../Library/lib_utilities.pcl";

# --- CONSTANTS --- #

string TARGET_EVENT_CODE = "Target";

string LOG_ACTIVE = "log_active";

string PRACTICE_TYPE_PRACTICE = "Practice";
string PRACTICE_TYPE_MAIN = "Main";

int CORR_BUTTON_CODE = 1;
int ERROR_BUTTON_CODE = 2;

int COMPAT_VAL = 1;
int INCOMPAT_VAL = 2;

int LEFT_IDX = 1;
int RIGHT_IDX = 2;

int CENTER_IDX = 1;
int FLANK_IDX = 2;
int NUM_FLANKS_IDX = 3;

int BUTTON_LEFT = 1;
int BUTTON_RIGHT = 2;

string STIM_COMPATIBLE = "Compatible";
string STIM_INCOMPATIBLE = "Incompatible";
string STIM_NO_FLANKERS = "No Flankers";

string FEEDBACK_LABEL = "[FEEDBACK]";
string LEFT_CHAR_LABEL = "[LEFT_CHAR]";
string RIGHT_CHAR_LABEL = "[RIGHT_CHAR]";
string LEFT_BUTTON_LABEL = "[LEFT_BUTTON]";
string RIGHT_BUTTON_LABEL = "[RIGHT_BUTTON]";

string CHARACTER_WRAP = "Character";

# --- Set up fixed stimulus parameters ---

string language = parameter_manager.get_string( "Language" );
language_file lang = load_language_file( scenario_directory + language + ".xml" );
bool char_wrap = ( get_lang_item( lang, "Word Wrap Mode" ).lower() == CHARACTER_WRAP.lower() );
double font_size = parameter_manager.get_double( "Non-Stimulus Font Size" );

int flanker_duration = parameter_manager.get_int( "Pre-Target Flanker Duration" );
trial_refresh_fix( flanker_trial, flanker_duration );

trial_refresh_fix( target_trial, parameter_manager.get_int( "Target/Flanker Duration" ) );

if ( !parameter_manager.get_bool( "Show Fixation Point During ISI" ) ) then
	isi_pic.clear();
end;

if ( parameter_manager.get_string( "Response Logging" ) == LOG_ACTIVE ) then
	flanker_trial.set_all_responses( false );
	target_trial.set_all_responses( false );
	isi_trial.set_all_responses( false );
end;

# --- sub present_instructions --- #

sub
	present_instructions( string instruct_string )
begin
	full_size_word_wrap( instruct_string, font_size, char_wrap, instruct_text );
	instruct_trial.present();
	default.present();
end;

# --- sub show_feedback

# Get some captions that we'll use for feedback 
string left_name = parameter_manager.get_string( "Left Character Response Button Name" );
string right_name = parameter_manager.get_string( "Right Character Response Button Name" );
string slow_down_caption = get_lang_item( lang, "Slow Down Caption" );
string speed_up_caption = get_lang_item( lang, "Speed Up Caption" );
string ok_caption = get_lang_item( lang, "OK Caption" );
string timed_rest_caption = get_lang_item( lang, "Timed Rest Caption" );
string untimed_rest_caption = get_lang_item( lang, "Untimed Rest Caption" );

# Check that the thresholds are legal
double min_threshold = parameter_manager.get_double( "Minimum Error Rate" );
double max_threshold = parameter_manager.get_double( "Maximum Error Rate" );
if ( max_threshold <= min_threshold ) then
	exit( "Error: 'Maximum Error Rate' must be greater than 'Minimum Error Rate'" );
end;

# Get the feedback duration
int rest_dur = parameter_manager.get_int( "Rest/Feedback Duration" );

# Given an error rate, update the fb with the right caption
sub
	show_feedback( double current_error_rate )
begin
	# Get the rest screen caption
	string temp_caption = untimed_rest_caption;
	if ( rest_dur > 0 ) then
		temp_caption = timed_rest_caption;
		instruct_trial.set_type( instruct_trial.FIXED );
		instruct_trial.set_duration( rest_dur );
	end;
	
	# Add the button names
	temp_caption = temp_caption.replace( LEFT_BUTTON_LABEL, left_name );
	temp_caption = temp_caption.replace( RIGHT_BUTTON_LABEL, right_name );
	
	# Too few errors
	if ( current_error_rate < min_threshold ) then
		temp_caption = temp_caption.replace( FEEDBACK_LABEL, speed_up_caption );
		
	# Too many errors
	elseif ( current_error_rate > max_threshold ) then
		temp_caption = temp_caption.replace( FEEDBACK_LABEL, slow_down_caption );
		
	# Juuuuust right
	else 
		temp_caption = temp_caption.replace( FEEDBACK_LABEL, ok_caption );
	end;
	
	# Present the feedback
	present_instructions( temp_caption );
	
	# Reset the instructions trial
	instruct_trial.set_type( instruct_trial.FIRST_RESPONSE );
	instruct_trial.set_duration( instruct_trial.FOREVER );
end;

# --- sub build_stim

# Initialize some values
double spacing = parameter_manager.get_double( "Space Between Characters" );
bool show_fixation = parameter_manager.get_bool( "Show Fixation Point During Stimulus" );
string left_char = parameter_manager.get_string( "Left Character" );
string right_char = parameter_manager.get_string( "Right Character" );
double stim_y = parameter_manager.get_double( "Vertical Stimulus Position" );
	
# Set the captions, exit if specified incorrectly
if ( left_char.count() != 1 ) || ( right_char.count() != 1 ) then
	exit( "Error: A single character must be specified in both 'Left Character' and 'Right Character'." );
end;
stim_texts[LEFT_IDX].set_caption( left_char, true );
stim_texts[RIGHT_IDX].set_caption( right_char, true );

# Set up and grab some stimulus info
array<double> stim_widths[2];
array<string> stim_info[2];
stim_widths[LEFT_IDX] = stim_texts[LEFT_IDX].width();
stim_widths[RIGHT_IDX] = stim_texts[RIGHT_IDX].width();
stim_info[LEFT_IDX] = stim_texts[LEFT_IDX].caption();
stim_info[RIGHT_IDX] = stim_texts[RIGHT_IDX].caption();

if ( spacing < 0.0 ) then
	if ( abs( spacing ) > stim_widths[LEFT_IDX] ) ||
		( abs( spacing ) > stim_widths[RIGHT_IDX] ) then
		exit( "Error: 'Space Between Characters' must be increased." );
	end;
end;

# Subroutine to set up the picture containing the specified center, flanker, 
# Number of flankers, and whether the central stimulus is present
sub 
	build_stim( int cent_type, int flank_type, int num_flankers, picture this_pic, bool show_cent )
begin
	# First clear the pic
	this_pic.clear();
	
	# Add in the fixation
	if ( show_fixation ) then
		this_pic.add_part( fix_ellipse, 0, 0 );
	end;
	
	# Now add the center (target) stimulus
	if ( show_cent ) then
		this_pic.add_part( stim_texts[cent_type], 0.0, stim_y );
	end;
	double stim_pos = spacing + stim_widths[cent_type]/2.0 + stim_widths[flank_type]/2.0;
	int part_ctr = this_pic.part_count() + 1;

	# Now we'll add the flankers
	array<double> locs[0];
	loop
		int i = 1
	until 
		i > num_flankers
	begin
		locs.add( stim_pos );
		this_pic.add_part( stim_texts[flank_type], stim_pos, stim_y );
		this_pic.add_part( stim_texts[flank_type], -stim_pos, stim_y );
		
		stim_pos = stim_pos + spacing + stim_widths[flank_type];
		i = i + 1;
	end;
end;

# --- sub ready_set_go ---

int ready_dur = parameter_manager.get_int( "Ready-Set-Go Duration" );
trial_refresh_fix( ready_trial, ready_dur );

array<string> ready_caps[3];
ready_caps[1] = get_lang_item( lang, "Ready Caption" );
ready_caps[2] = get_lang_item( lang, "Set Caption" );
ready_caps[3] = get_lang_item( lang, "Go Caption" );

sub
	ready_set_go
begin
	if ( ready_dur > 0 ) then
		loop
			int i = 1
		until
			i > ready_caps.count()
		begin
			full_size_word_wrap( ready_caps[i], font_size, char_wrap, ready_text );
			ready_trial.present();
			i = i + 1;
		end;
	end;
end;

# --- sub update_port_and_buttons

sub
	int update_port_and_buttons( int compat_val, int cent_dir_val, stimulus_event this_event )
begin
	string this_p_code = string( compat_val ) + string( cent_dir_val );
	
	array<int> b_codes[2];
	b_codes[BUTTON_LEFT] = int( string( BUTTON_LEFT ) + this_p_code );
	b_codes[BUTTON_RIGHT] = int( string( BUTTON_RIGHT ) + this_p_code );
	
	this_event.set_port_code( int( this_p_code ) );
	response_manager.set_button_codes( b_codes );
	response_manager.set_target_button_codes( b_codes );
	
	return int( this_p_code )
end;

# --- sub string_replace

sub
	string string_replace( string start_string )
begin
	string rval = start_string;
	rval = rval.replace( LEFT_CHAR_LABEL, left_char );
	rval = rval.replace( RIGHT_CHAR_LABEL, right_char );
	rval = rval.replace( LEFT_BUTTON_LABEL, left_name );
	rval = rval.replace( RIGHT_BUTTON_LABEL, right_name );
	return rval
end;

# --- sub show_block 

array<int> isi_range[0];
parameter_manager.get_ints( "ISI Range", isi_range );
if ( isi_range.count() != 2 ) then
	exit( "Error: Two values must be specified in 'ISI Range'" );
end;

sub
	double show_block( array<int,2>& cond_array, string practice_check, int block_number )
begin
	# Shuffle the trial sequence
	cond_array.shuffle();
	
	# Show an ISI
	trial_refresh_fix( isi_trial, random( isi_range[1], isi_range[2] ) );
	isi_trial.present();
	
	# Loop to present trial sequence
	double error_rate = 0.0;
	loop 
		int hits = 0;
		int i = 1 
	until 
		i > cond_array.count() 
	begin
		# Trial info
		int this_cent = cond_array[i][CENTER_IDX];
		int this_flank = cond_array[i][FLANK_IDX];
		int this_num_flanks = cond_array[i][NUM_FLANKS_IDX];
		
		# Info for event codes
		string flank_info = stim_info[this_flank];
		string cent_info = stim_info[this_cent];
		string compatibility = STIM_INCOMPATIBLE;
		int this_compat = INCOMPAT_VAL;
		if ( this_cent == this_flank ) then
			compatibility = STIM_COMPATIBLE;
			this_compat = COMPAT_VAL;
		end;
		if ( this_num_flanks == 0 ) then
			compatibility = STIM_NO_FLANKERS;
			flank_info = " ";
			this_flank = 0;
		end;
		
		# Get ISI duration
		trial_refresh_fix( isi_trial, random( isi_range[1], isi_range[2] ) );
				
		# Build the stimulus
		build_stim( this_cent, this_flank, this_num_flanks, flanker_pic, false );
		build_stim( this_cent, this_flank, this_num_flanks, target_pic, true );

		# Set correct buttons
		if ( this_cent == LEFT_IDX ) then
			target_event.set_target_button( BUTTON_LEFT );
		else
			target_event.set_target_button( BUTTON_RIGHT );
		end;
		
		# Set the button and port codes
		int p_code = update_port_and_buttons( this_compat, this_cent, target_event );

		# Set event and port codes
		target_event.set_event_code( 
			TARGET_EVENT_CODE + ";" + 
			practice_check + ";" + 
			string( block_number ) + ";" +
			string( i ) + ";" + 
			cent_info + ";" + 
			flank_info + ";" +
			string( this_num_flanks ) + ";" + 
			compatibility + ";" +
			string( isi_trial.duration() )	+ ";" + 
			string( p_code ) 
		);
		
		# Trial sequence
		if ( flanker_duration > 0 ) then
			flanker_trial.present();
		end;
		target_trial.present();
		isi_trial.present();

		# Get error rate
		stimulus_data last = stimulus_manager.get_stimulus_data( stimulus_manager.stimulus_count() - 1 );
		if ( last.type() == last.HIT ) then
			hits = hits + 1;
		end;
		error_rate = 1.0 - ( double(hits)/double(i) );
		
		i = i + 1;
	end;
	return error_rate
end;

# --- Conditions and Trial Orders --- #

array<int> conditions[0][0];
array<int> block_order[0][0][0];

sub 
	add_trials( int cent_val, int flank_val, int num_trials, int flanker_ct )
begin
	loop
		int i = 1
	until 
		i > num_trials
	begin
		array<int> temp[3];
		temp[CENTER_IDX] = cent_val;
		temp[FLANK_IDX] = flank_val;
		temp[NUM_FLANKS_IDX] = flanker_ct;
		conditions.add( temp );
		i = i + 1;
	end;
end;

begin
	# Get some trial counts, exit if they didn't request any
	int left_cong = parameter_manager.get_int( "Left Congruent Trials per Block" );
	int right_cong = parameter_manager.get_int( "Right Congruent Trials per Block" );
	int left_incon = parameter_manager.get_int( "Left Incongruent Trials per Block" );
	int right_incon = parameter_manager.get_int( "Right Incongruent Trials per Block" );
	if ( left_cong == 0 ) && ( right_cong == 0 ) && ( left_incon == 0 ) && ( right_incon == 0 ) then
		exit( "Error: No trials specified." );
	end;

	# Now add trials to the conditions array
	int flanker_ct = parameter_manager.get_int( "Number of Flankers" );
	add_trials( LEFT_IDX, LEFT_IDX, left_cong, flanker_ct );
	add_trials( LEFT_IDX, RIGHT_IDX, left_incon, flanker_ct );
	add_trials( RIGHT_IDX, RIGHT_IDX, right_cong, flanker_ct );
	add_trials( RIGHT_IDX, LEFT_IDX, right_incon, flanker_ct );

	# Now add the blocks
	loop
		int i = 1
	until
		i > parameter_manager.get_int( "Blocks" )
	begin
		block_order.add( conditions );
		i = i + 1;
	end;
end;

# Add practice trials
int prac_trials = parameter_manager.get_int( "Practice Trials" );
array<int> prac_array[0][0];
loop
until
	prac_array.count() >= prac_trials
begin
	prac_array.add( block_order[1][random(1,block_order[1].count())] );
end;




# --- Main Sequence --- #

# Get some captions
string prac_caption = get_lang_item( lang, "Practice Caption" );
string instructions = string_replace( get_lang_item( lang, "Instructions" ) );
string prac_complete_caption = string_replace( get_lang_item( lang, "Practice Complete Caption" ) );
string reminder_cap = string_replace( get_lang_item( lang, "Reminder Caption" ) );

# Show the practice trials
if ( prac_trials > 0 ) then
	present_instructions( instructions + " " + prac_caption );
	ready_set_go();
	show_block( prac_array, PRACTICE_TYPE_PRACTICE, 0 );
	present_instructions( prac_complete_caption );
end;

loop
	int i = 1
until
	i > block_order.count()
begin
	if ( prac_trials == 0 ) && ( i == 1 ) then
		present_instructions( instructions );
	else
		present_instructions( reminder_cap );
	end;
	ready_set_go();
	
	# Show the block and record the error rate
	double block_error = show_block( block_order[i], PRACTICE_TYPE_MAIN, i );
	
	# Now show them the feedback, assuming it's not the last block
	if ( i < block_order.count() ) then
		show_feedback( block_error );
	end;
	
	i = i + 1;
end;
present_instructions( get_lang_item( lang, "Completion Screen Caption" ) );