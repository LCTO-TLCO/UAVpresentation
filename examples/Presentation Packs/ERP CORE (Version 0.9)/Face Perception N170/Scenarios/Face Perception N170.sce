# -------------------------- Header Parameters --------------------------

scenario = "Face Perception N170";

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
target_button_codes = 1,2;
response_logging = EXPARAM( "Response Logging" );

stimulus_properties =
	event_name, string,
	prac_type, string,
	trial_number, number,
	stim_type, string,
	stim_cond, string,
	ISI_duration, number,
	p_code, number,
	stim_file, string;
event_code_delimiter = ";";

# ------------------------------- SDL Part ------------------------------
begin;

trial{
	trial_type = first_response;
	trial_duration = forever;
	picture{
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
		picture {} ISI_pic;
		code = "ISI";
	} ISI_event;
} ISI_trial;
		
trial {
	clear_active_stimuli = false;
	stimulus_event {
		picture {
			ellipse_graphic {
				ellipse_height = EXPARAM( "Fixation Point Size" );
				ellipse_width = EXPARAM( "Fixation Point Size" );
				color = EXPARAM( "Fixation Point Color" );
			} fix_circ;
			x = 0;
			y = 0;
		} stim_pic;
		response_active = true;
		code = "Stim";
	} stim_event;
} stim_trial;
	
trial {
	trial_duration = forever;
	trial_type = first_response;
	
	stimulus_event {
		picture {
			text {
				caption = "Rest";
				preload = false;
			} rest_text;
			x = 0;
			y = 0;
		};
		code = "Rest";
	} rest_event;
} rest_trial;
	
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
	} ready_event;
} ready_trial;
	
# ----------------------------- PCL Program -----------------------------
begin_pcl;

include_once "../../Library/lib_visual_utilities.pcl";
include_once "../../Library/lib_utilities.pcl";

# --- CONSTANTS --- #

string STIM_EVENT_CODE = "Stimulus";

string PRACTICE_TYPE_PRACTICE = "Practice";
string PRACTICE_TYPE_MAIN = "Main";

string STD_BUTTON_LABEL = "[OBJECT_BUTTON]";
string SCR_BUTTON_LABEL = "[SCRAMBLED_BUTTON]";

string LOG_ACTIVE = "log_active";

int OBJ_IDX = 1;
int SCR_IDX = 2;

int TYPE_IDX = 1;
int COND_IDX = 2;
int STIM_IDX = 3;

int CORR_BUTTON = 201;
int INCORR_BUTTON = 202;

int PORT_CODE_PREFIX = 100;

string OBJECT_COND = "Object";
string SCRAMBLED_COND = "Scrambled";

string CHARACTER_WRAP = "Character";

# --- Set up fixed stimulus parameters ---

string language = parameter_manager.get_string( "Language" );
language_file lang = load_language_file( scenario_directory + language + ".xml" );
bool char_wrap = ( get_lang_item( lang, "Word Wrap Mode" ).lower() == CHARACTER_WRAP.lower() );
double font_size = parameter_manager.get_double( "Non-Stimulus Font Size" );

# Set up the rest trial 
int rest_dur = parameter_manager.get_int( "Rest Break Duration" );
if ( rest_dur > 0 ) then
	rest_trial.set_type( rest_trial.FIXED );
	trial_refresh_fix( rest_trial, rest_dur );
	string rest_cap = get_lang_item( lang, "Timed Rest Caption" );
	full_size_word_wrap( rest_cap, font_size, char_wrap, rest_text );
else
	string rest_cap = get_lang_item( lang, "Untimed Rest Caption" );
	full_size_word_wrap( rest_cap, font_size, char_wrap, rest_text );
end;

# Add fixation to ISI
if ( parameter_manager.get_bool( "Show Fixation Point During ISI" ) ) then
	ISI_pic.add_part( fix_circ, 0, 0 );
end;

# Set the target and nontarget buttons
begin
	array<int> b_codes[2];
	b_codes.fill( 1, 0, INCORR_BUTTON, 0 );
	response_manager.set_button_codes( b_codes );
	b_codes.fill( 1, 0, CORR_BUTTON, 0 );
	response_manager.set_target_button_codes( b_codes );
end;

# Change response logging
if ( parameter_manager.get_string( "Response Logging" ) == LOG_ACTIVE ) then
	ISI_trial.set_all_responses( false );
	stim_trial.set_all_responses( false );
end;

# --- Stimulus setup

array<bitmap> all_stim[2][0][0];
parameter_manager.get_bitmaps( "Object Condition Images", all_stim[OBJ_IDX] );
parameter_manager.get_bitmaps( "Texture Condition Images", all_stim[SCR_IDX] );

array<bitmap> prac_bmps[2][0];
parameter_manager.get_bitmaps( "Object Practice Images", prac_bmps[OBJ_IDX] );
parameter_manager.get_bitmaps( "Texture Practice Images", prac_bmps[SCR_IDX] );

# Get the condition (sub-array) counts
array<int> cond_counts[2];
cond_counts[OBJ_IDX] = all_stim[OBJ_IDX].count();
cond_counts[SCR_IDX] = all_stim[SCR_IDX].count();

# Get the requested trial counts
array<int> trial_cts[2];
trial_cts[OBJ_IDX] = parameter_manager.get_int( "Object Trials per Condition" );
trial_cts[SCR_IDX] = parameter_manager.get_int( "Texture Trials per Condition" );

# Get the specified condition names. Make sure there are the same number of names as subarrays
array<string> cond_names[2][0];
parameter_manager.get_strings( "Object Condition Names", cond_names[OBJ_IDX] );
parameter_manager.get_strings( "Texture Condition Names", cond_names[SCR_IDX] );

if ( cond_names[OBJ_IDX].count() != cond_counts[OBJ_IDX] ) then
	exit( "Error: There must be the same number of elements in 'Object Condition Names' as subarrays in 'Object Condition Images'" );
end;
if ( cond_names[SCR_IDX].count() != cond_counts[SCR_IDX] ) then
	exit( "Error: There must be the same number of elements in 'Texture Conditon Names' as subarrays in 'Texture Condition Images'" );
end;

# --- Subroutines --- #

# --- sub present_instructions 

sub
	present_instructions( string instruct_string )
begin
	full_size_word_wrap( instruct_string, font_size, char_wrap, instruct_text );
	instruct_trial.present();
	default.present();
end;

# --- sub get_filename

sub
	string get_filename( bitmap this_bitmap )
begin
	string temp_string = this_bitmap.filename();
	
	int last_slash = 1;
	loop
	until
		temp_string.find( "\\", last_slash ) == 0
	begin
		last_slash = last_slash + 1;
	end;
	
	temp_string = temp_string.substring( last_slash, temp_string.count()-last_slash+1 );
	
	return temp_string
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

# --- sub get_port_code

# If they aren't using 2 x 2 design, then default to generic
bool generic_codes = false;
if ( cond_counts[OBJ_IDX] != 2 ) || ( cond_counts[SCR_IDX] != 2 ) then
	generic_codes = true;
else
	loop
		int i = 1
	until
		i > all_stim.count()
	begin
		loop
			int j = 1
		until
			j > all_stim[i].count()
		begin
			if ( all_stim[i][j].count() > 50 ) then
				generic_codes = true;
			end;
			j = j + 1;
		end;
		i = i + 1;
	end;
end;

# If there are more than 100 conditions, then exit	
if ( cond_counts[OBJ_IDX] > 100 ) || ( cond_counts[SCR_IDX] > 100 ) then
	exit( "Error: There must be fewer than 100 conditions (subarrays) specified." );
end;

sub
	int get_port_code( int stim_type, int stim_cond, int stim_number )
begin
	int this_p_code = stim_number;
	if ( generic_codes ) then
		this_p_code = stim_cond;
	elseif ( stim_cond != OBJ_IDX ) then
		this_p_code = this_p_code + all_stim[OBJ_IDX][stim_cond].count();
	end;
	if ( stim_type == SCR_IDX ) then
		this_p_code = this_p_code + PORT_CODE_PREFIX;
	end;
	return this_p_code
end;

# --- sub string_replace

array<string> button_names[2];
button_names[1] = parameter_manager.get_string( "Response Button 1 Name" );
button_names[2] = parameter_manager.get_string( "Response Button 2 Name" );
int obj_button = parameter_manager.get_int( "Response Button Mapping" );

sub
	string string_replace( string start_string )
begin
	string rval = start_string;
	rval = rval.replace( STD_BUTTON_LABEL, button_names[obj_button] );
	rval = rval.replace( SCR_BUTTON_LABEL, button_names[(obj_button%2)+1] );
	return rval
end;

# --- sub show_trial_sequence

# Instructions
string instructions = string_replace( get_lang_item( lang, "Instructions" ) );
string reminder_cap = string_replace( get_lang_item( lang, "Reminder Caption" ) );

# Initialize some other values
int trials_per_rest = parameter_manager.get_int( "Trials Between Rest Breaks" );
bool repeat_stim = parameter_manager.get_bool( "Repeat Stimuli" );
array<int> ISI_range[0];
parameter_manager.get_ints( "ISI Range", ISI_range );
if ( ISI_range.count() != 2 ) then
	exit( "Error: Exactly two values must be specified in 'ISI Range'" );
end;

# Get the requested stimulus durations, exit if none
int stim_dur = parameter_manager.get_int( "Stimulus Duration" );
trial_refresh_fix( stim_trial, stim_dur );
	
array<int> corr_buttons[2];
corr_buttons[OBJ_IDX] = parameter_manager.get_int( "Response Button Mapping" );
corr_buttons[SCR_IDX] = ( corr_buttons[OBJ_IDX] % 2 ) + 1;

array<string> type_names[2];
type_names[OBJ_IDX] = OBJECT_COND;
type_names[SCR_IDX] = SCRAMBLED_COND;

sub
	show_trial_sequence( array<int,2>& trial_sequence, string prac_check )
begin
	# Get ready!
	ready_set_go();
	
	# Start with an ISI
	trial_refresh_fix( ISI_trial, random( ISI_range[1], ISI_range[2] ) );
	ISI_trial.present();
	
	# Loop to present trials
	loop
		int i = 1
	until
		i > trial_sequence.count()
	begin
		# Get some values for this trial
		int this_type = trial_sequence[i][TYPE_IDX];
		int this_cond = trial_sequence[i][COND_IDX];
		int this_stim = trial_sequence[i][STIM_IDX];
		string cond_name = cond_names[this_type][this_cond];
		string filename = get_filename( all_stim[this_type][this_cond][this_stim] );
		
		#term.print_line( string( this_type ) + " " + string( this_cond ) + " " + string( this_stim ) );
		# Set the stimulus
		if ( prac_check == PRACTICE_TYPE_PRACTICE ) then
			cond_name = PRACTICE_TYPE_PRACTICE;
			stim_pic.set_part( 1, prac_bmps[this_type][this_stim] );
			filename = get_filename( prac_bmps[this_type][this_stim] );
		else
			stim_pic.set_part( 1, all_stim[this_type][this_cond][this_stim] );
		end;
		
		# Set the ISI duration
		int this_isi = random( ISI_range[1], ISI_range[2] );
		trial_refresh_fix( ISI_trial, this_isi );
		
		# Set the target button
		stim_event.set_target_button( corr_buttons[this_type] );
		
		# Set port code
		int p_code = get_port_code( this_type, this_cond, this_stim );
		stim_event.set_port_code( p_code );
		
		# Set the event code
		stim_event.set_event_code(
			STIM_EVENT_CODE + ";" +
			prac_check + ";" +
			string( i ) + ";" +
			type_names[this_type] + ";" +
			cond_name + ";" +
			string( this_isi ) + ";" +
			string( p_code ) + ";" +
			filename
		);
		
		# Show the trial
		stim_trial.present();
		ISI_trial.present();
		
		# Show the rest
		if ( trials_per_rest > 0 ) && ( prac_check == PRACTICE_TYPE_MAIN ) then
			if ( i % trials_per_rest == 0 ) && ( i < trial_sequence.count() ) then
				rest_trial.present();
				present_instructions( reminder_cap );
				ready_set_go();
			end;
		end;
		
		# Increment
		i = i + 1;
	end;
end;

# --- Trial & Condition Sequence --- #

array<int> cond_array[0][0];
array<int> prac_cond_array[0][0];

# Build the trial sequence
begin
	# Randomize the stimulus order & check if there are enough stimuli (if they don't want to repeat)
	bool randomize_stim = parameter_manager.get_bool( "Randomize Stimulus Order" );
	
	# Now we'll set up the order of picture #s
	array<int> stim_order[2][0][0];
	loop
		int i = 1
	until
		i > all_stim.count()
	begin
		stim_order[i].resize( all_stim[i].count() );
		int trial_ct = trial_cts[i];
		
		# For each condition/type, set a picture order
		# This order can be the same as the pictures are entered in the param manager
		# or randomized. Note if pictures are repeated, the entire set for that 
		# condition is shown before any picture is repeated.
		loop
			int j = 1
		until
			j > all_stim[i].count()
		begin
			array<int> stim_indices[all_stim[i][j].count()];
			stim_indices.fill( 1, 0, 1, 1 );
			
			# Break if they don't have enough stimuli & don't want to repeat stim
			if ( !repeat_stim ) then
				if ( stim_indices.count() < trial_ct ) then
					exit( "Error: Not enough stimuli specified. Add more stimuli or reduce the number of trials per condition." );
				end;
			end;

			loop
			until
				stim_order[i][j].count() >= trial_ct
			begin
				if ( randomize_stim ) then
					stim_indices.shuffle();
				end;
				stim_order[i][j].append( stim_indices );
			end;
			stim_order[i][j].resize( trial_ct );
			
			j = j + 1;
		end;
		
		i = i + 1;
	end;
			
	# Now build the trial sequence
	loop
		int i = 1
	until
		i > stim_order.count()
	begin
		loop
			int j = 1
		until
			j > stim_order[i].count()
		begin
			loop
				int k = 1
			until
				k > stim_order[i][j].count()
			begin
				array<int> temp[3];
				temp[TYPE_IDX] = i;
				temp[COND_IDX] = j;
				
				cond_array.add( temp );
				k = k + 1;
			end;
			j = j + 1;
		end;
		i = i + 1;
	end;

	cond_array.shuffle();
	array<int> ctrs[2][0];
	ctrs[1].resize( all_stim[1].count() );
	ctrs[2].resize( all_stim[2].count() );
	loop
		int i = 1
	until
		i > cond_array.count()
	begin
		int this_type = cond_array[i][TYPE_IDX];
		int this_cond = cond_array[i][COND_IDX];
		if ( ctrs[this_type][this_cond] == 0 ) then
			ctrs[this_type][this_cond] = 1;
		end;
		int this_stim = ctrs[this_type][this_cond];
		cond_array[i][STIM_IDX] = stim_order[this_type][this_cond][this_stim];
		
		ctrs[this_type][this_cond] = ctrs[this_type][this_cond] + 1;
		i = i + 1;
	end;
	
	# Build a practice trial sequence
	int prac_trials = parameter_manager.get_int( "Practice Trials" );
	array<int> temp_prac_array[0][0];
	loop
		int i = 1
	until
		i > prac_bmps.count()
	begin
		loop
			int j = 1
		until
			j > prac_bmps[i].count()
		begin
			array<int> temp[3];
			temp[TYPE_IDX] = i;
			temp[COND_IDX] = 1;
			temp[STIM_IDX] = j;
				
			temp_prac_array.add( temp );
			
			j = j + 1;
		end;
		i = i + 1;
	end;
	
	loop
	until
		prac_cond_array.count() >= prac_trials
	begin
		prac_cond_array.append( temp_prac_array );
	end;
	prac_cond_array.resize( prac_trials );
	prac_cond_array.shuffle();
end;

# --- Main Sequence --- #

# Set some captions
string complete_caption = string_replace( get_lang_item( lang, "Completion Screen Caption" ) );

# Main sequence
if ( prac_cond_array.count() > 0 ) then
	present_instructions( instructions + get_lang_item( lang, "Practice Caption" ) );
	show_trial_sequence( prac_cond_array, PRACTICE_TYPE_PRACTICE );
	present_instructions( get_lang_item( lang, "Practice Complete Caption" ) );
	present_instructions( reminder_cap );
else
	present_instructions( instructions );
end;
show_trial_sequence( cond_array, PRACTICE_TYPE_MAIN );
present_instructions( complete_caption );