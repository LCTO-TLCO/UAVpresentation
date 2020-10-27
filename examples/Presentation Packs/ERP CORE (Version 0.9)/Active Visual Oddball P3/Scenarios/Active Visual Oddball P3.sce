# -------------------------- Header Parameters --------------------------

scenario = "Active Visual Oddball P3";

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
	block_name, string,
	block_number, number,
	trial_number, number,
	stim_type, string,
	block_tgt, number,
	stim_number, number,
	tgt_type, string,
	p_code, number,
	ISI_dur, number;
event_code_delimiter = ";";

# ------------------------------- SDL Part ------------------------------
begin;

text { 
	caption = "Your target is";
	preload = false;
} reminder_top_text;

text {
	caption = "Reminder";
	preload = false;
} reminder_bot_text;

text {
	caption = "This target";
	preload = false;
} target_id_text;

trial{
	trial_type = first_response;
	trial_duration = forever;
	
	stimulus_event {		
		picture{
			text { 
				caption = "Instructions";
				preload = false;
			} instruct_text;
			x = 0; 
			y = 0;
		} instruct_pic;
		code = "Instructions";
		response_active = true;
	};
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
			
			text {
				caption = "Target";
				font_size = EXPARAM( "Stimulus Font Size" );
				font_color = EXPARAM( "Stimulus Color" );
				font = EXPARAM( "Stimulus Font" );
				preload = false;
			} tgt_text;
			x = 0;
			y = 0;
		} tgt_pic;
		response_active = true;
	} tgt_event;
} tgt_trial;
	
trial {
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 1,2;
	
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
		code = "Ready";
	} ready_event;
} ready_trial;
	
# ----------------------------- PCL Program -----------------------------
begin_pcl;

include_once "../../Library/lib_visual_utilities.pcl";
include_once "../../Library/lib_utilities.pcl";

# --- CONSTANTS --- #

string TARGET_EVENT_CODE = "Target";

string TARGET_BUTTON_LABEL = "[TARGET_BUTTON]";
string NONTARGET_BUTTON_LABEL = "[NONTARGET_BUTTON]";

string STIM_STRINGS = "Strings";

string STIM_TGT = "Target";
string STIM_NON = "Distractor";

string PRACTICE_TYPE_PRACTICE = "Practice";
string PRACTICE_TYPE_MAIN = "Main";

string LOG_ACTIVE = "log_active";

int TGT_VAL = 1;
int NONTGT_VAL = 2;

int INSTRUCS_PART = 1;

int TGT_PART = 2;

int CORR_BUTTON = 201;
int INCORR_BUTTON = 202;
int GENERIC_TGT_CODE = 101;
int MAX_STIM = 100;

string CHARACTER_WRAP = "Character";

# --- Set up fixed stimulus parameters ---

string language = parameter_manager.get_string( "Language" );
language_file lang = load_language_file( scenario_directory + language + ".xml" );
bool char_wrap = ( get_lang_item( lang, "Word Wrap Mode" ).lower() == CHARACTER_WRAP.lower() );
double font_size = parameter_manager.get_double( "Non-Stimulus Font Size" );

# Set some durations
trial_refresh_fix( tgt_trial, parameter_manager.get_int( "Stimulus Duration" ) );

# Adjust whether the fixation is on during the isi
if ( parameter_manager.get_bool( "Show Fixation Point During ISI" ) ) then
	ISI_pic.add_part( fix_circ, 0, 0 );
end;

# Set a transparent color on the text if necessary
if ( parameter_manager.get_bool( "Show Fixation Point During Stimulus" ) ) then
	tgt_text.set_transparent_color( parameter_manager.get_color( "Background Color" ) );
end;

# Set the button codes
begin
	array<int> temp_codes[2];
	temp_codes.fill( 1, 0, INCORR_BUTTON, 0 );
	response_manager.set_button_codes( temp_codes );
	
	temp_codes.fill( 1, 0, CORR_BUTTON, 0 );
	response_manager.set_target_button_codes( temp_codes );
end;

# Change response logging
if ( parameter_manager.get_string( "Response Logging" ) == LOG_ACTIVE ) then
	ISI_trial.set_all_responses( false );
	tgt_trial.set_all_responses( false );
end;

# --- Stimulus setup --- #

# Now grab all the stimuli
string stim_type = STIM_STRINGS;

array<string> let_stimuli[0];
parameter_manager.get_strings( "Stimuli", let_stimuli );

# Figure out the number of stimuli & exit if there are too many
int num_stim = let_stimuli.count();
if ( num_stim > MAX_STIM ) then
	exit( "Error: You must specify fewer than " + string( MAX_STIM ) + " stimuli in your stimulus array." );
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

# --- sub show_rest

# Initialize some values
int within_rest_dur = parameter_manager.get_int( "Within-Block Rest Duration" );
int between_rest_dur = parameter_manager.get_int( "Between-Block Rest Duration" );
string timed_rest_caption = get_lang_item( lang, "Timed Rest Caption" );
string untimed_rest_caption = get_lang_item( lang, "Untimed Rest Caption" );

sub
	show_rest( bool within_block )
begin
	# Get the duration
	int temp_dur = within_rest_dur;
	if ( !within_block ) then
		temp_dur = between_rest_dur;
	end;
	
	# Update the trial type and duration
	if ( temp_dur == 0 ) then
		full_size_word_wrap( untimed_rest_caption, font_size, char_wrap, rest_text );
		rest_trial.set_duration( rest_trial.FOREVER );
		rest_trial.set_type( rest_trial.FIRST_RESPONSE );
	else
		full_size_word_wrap( timed_rest_caption, font_size, char_wrap, rest_text );
		rest_trial.set_duration( temp_dur );
		rest_trial.set_type( rest_trial.FIXED );
	end;
	
	# Show the trial
	rest_trial.present();
end;

# --- sub get_port_code

# If more than 10 stim, use generic port codes
bool generic_p_codes = ( num_stim >= 10 );

sub 
	int get_port_code( int stim_id, int tgt_id )
begin
	# Standard port code adds tgt id to stim id (e.g., 11,22,33 for targets)
	int p_code = int( string( tgt_id ) + string( stim_id ) );
	
	# Generic port code sends the stim id or a generic target code
	if ( generic_p_codes ) then
		if ( stim_id == tgt_id ) then
			p_code = GENERIC_TGT_CODE;
		else
			p_code = stim_id;
		end;
	end;

	return p_code
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

# --- sub show_main_instructions

array<string> button_names[2];
button_names[1] = parameter_manager.get_string( "Response Button 1 Name" );
button_names[2] = parameter_manager.get_string( "Response Button 2 Name" );

int target_button = parameter_manager.get_int( "Response Button Mapping" );
int n_target_button = ( target_button % 2 ) + 1;

string instructions = get_lang_item( lang, "Instructions" );
instructions = instructions.replace( TARGET_BUTTON_LABEL, button_names[target_button] );
instructions = instructions.replace( NONTARGET_BUTTON_LABEL, button_names[n_target_button] );

sub
	show_main_instructions
begin
	present_instructions( instructions );
end;

# --- sub show_block_instructions

string reminder_cap = get_lang_item( lang, "Target Reminder Bottom Caption" );
reminder_cap = reminder_cap.replace( TARGET_BUTTON_LABEL, button_names[target_button] );
reminder_cap = reminder_cap.replace( NONTARGET_BUTTON_LABEL, button_names[n_target_button] );

string top_reminder = get_lang_item( lang, "Target Reminder Top Caption" );
top_reminder = top_reminder.replace( TARGET_BUTTON_LABEL, button_names[target_button] );
reminder_top_text.set_max_text_width( display_device.custom_width() * 0.9 );
reminder_bot_text.set_max_text_width( display_device.custom_width() * 0.9 );
reminder_top_text.set_caption( top_reminder + "\n", true );
reminder_bot_text.set_caption( "\n" + reminder_cap, true );

string prac_caption = get_lang_item( lang, "Practice Caption" );

sub
	show_block_instructions( int tgt_number, bool is_practice )
begin
	if ( is_practice ) then
		reminder_bot_text.set_caption( "\n" + reminder_cap + " " + prac_caption, true );
	else
		reminder_bot_text.set_caption( "\n" + reminder_cap, true );
	end;
	
	target_id_text.set_caption( let_stimuli[tgt_number], true );
	double max_reminder_height = display_device.custom_height() * 0.9 - target_id_text.height();
	double curr_reminder_height = reminder_top_text.height() + reminder_bot_text.height();
	loop
		double new_font_size = font_size;
	until
		curr_reminder_height < max_reminder_height
	begin
		new_font_size = new_font_size * 0.9;
		reminder_top_text.set_font_size( new_font_size );
		reminder_bot_text.set_font_size( new_font_size );
		reminder_top_text.redraw();
		reminder_bot_text.redraw();
		curr_reminder_height = reminder_top_text.height() + reminder_bot_text.height();
	end;

	picture temp_pic = new picture();
	double y_adj = ( reminder_bot_text.height() - reminder_top_text.height() ) / 2.0;
	double top_y = 0.0;
	double bot_y = 0.0;

	target_id_text.set_caption( let_stimuli[tgt_number], true );
	temp_pic.add_part( target_id_text, 0.0, y_adj );
	top_y = y_adj + target_id_text.height()/2.0;
	bot_y = y_adj - target_id_text.height()/2.0;
	
	temp_pic.add_part( reminder_top_text, 0, 0 );
	temp_pic.add_part( reminder_bot_text, 0, 0 );
	temp_pic.set_part_y( 2, top_y, temp_pic.BOTTOM_COORDINATE );
	temp_pic.set_part_y( 3, bot_y, temp_pic.TOP_COORDINATE );

	temp_pic.present();
	loop
		int resp_ct = response_manager.total_response_count()
	until
		response_manager.total_response_count() > resp_ct 
	begin
	end;
	
	default.present();
end;

# --- sub build_trial_order

bool random_ntar = parameter_manager.get_bool( "Randomize Non-Target Stimuli" );
array<int> trial_order[0];

sub
	build_trial_order( int target_number, int max_stim, int tgt_trials, int ntgt_trials )
begin
	# Start by clearing the array
	trial_order.resize( 0 );
	
	# Now we'll add the trials to it
	loop
		int temp_val = 0;
		int current_stim = 0;
	until
		trial_order.count() >= ntgt_trials + tgt_trials
	begin
		# This is the stimulus number we're on (used to ensure a rect. distribution)
		int stim_ctr = ( current_stim % max_stim ) + 1;
		
		# Add a target trial if we didn't add them all yet
		if ( trial_order.count() < tgt_trials ) then
			temp_val = target_number;
		else
			# Add a random nontarget if they don't want a rectangular distribution
			# or the next stim
			if ( random_ntar ) then
				temp_val = random_exclude( 1, max_stim, target_number );
			elseif ( stim_ctr != target_number ) then
				temp_val = stim_ctr
			end;
		end;
		
		# Add this trial to the list and increment
		trial_order.add( temp_val );
		current_stim = current_stim + 1;
	end;
	trial_order.shuffle();
end;

# --- sub show_block
	
int tar_trials = parameter_manager.get_int( "Target Trials per Block" );
int ntar_trials = parameter_manager.get_int( "Non-Target Trials per Block" );
int trials_per_rest = parameter_manager.get_int( "Trials Between Rest Breaks" );

array<int> ISI_range[0];
parameter_manager.get_ints( "ISI Range", ISI_range );
if ( ISI_range.count() != 2 ) then
	exit( "Error: 'Interstimulus Interval Range' must contain exactly two values." );
end;

sub
	show_block( string practice_check, int block_number, int this_tgt )
begin
	# Randomize the trial order
	trial_order.shuffle();
	
	# Now show an ISI to get started
	trial_refresh_fix( ISI_trial, random( ISI_range[1], ISI_range[2] ) );
	ISI_trial.present();
	
	# Now present the sequence
	loop
		int i = 1
	until
		i > trial_order.count()
	begin
		# Get some info about this trial
		int this_stim = trial_order[i];
		string tgt_type = STIM_TGT;
		if ( this_stim != this_tgt ) then
			tgt_type = STIM_NON;
		end;
		
		# Set the ISI
		trial_refresh_fix( ISI_trial, random( ISI_range[1], ISI_range[2] ) );
		
		# Setup the stimulus
		tgt_text.set_caption( let_stimuli[this_stim], true );
		
		# Set the port/button codes
		int p_code = get_port_code( this_stim, this_tgt );
		tgt_event.set_port_code( p_code );
		
		# Set the event code
		tgt_event.set_event_code( 
			TARGET_EVENT_CODE + ";" +
			practice_check + ";" +
			string( block_number ) + ";" +
			string( i ) + ";" +
			stim_type + ";" +
			string( this_tgt ) + ";" +
			string( this_stim ) + ";" + 
			tgt_type + ";" +
			string( p_code ) + ";" +
			string( ISI_trial.duration() )
		);
		
		# Set the target button
		if ( this_stim == this_tgt ) then
			tgt_event.set_target_button( target_button );
		else
			tgt_event.set_target_button( n_target_button );
		end;
		
		# Trial sequence
		tgt_trial.present();
		ISI_trial.present();
		
		# Rest Trial
		if ( trials_per_rest > 0 ) && ( practice_check != PRACTICE_TYPE_PRACTICE ) then
			if ( i % trials_per_rest == 0 ) && ( i < trial_order.count() ) then
				show_rest( true );
				show_block_instructions( this_tgt, false );
				ready_set_go();
				ISI_trial.present();
			end;
		end;
		
		i = i + 1;
	end;
end;

# --- Conditions and block order --- #

array<int> block_order[0];
parameter_manager.get_ints( "Target Block Order", block_order );
if ( block_order.count() == 0 ) then
	exit( "Error: No blocks specified. Check the 'Target Block Order' parameter." );
elseif ( parameter_manager.get_bool( "Randomize Block Order" ) ) then
	block_order.shuffle();
end;

if ( int_array_max( block_order ) > num_stim ) then
	exit( "Error: not enough stimuli for all the targets specified in 'Target Block Order'" );
end;

# --- Main Sequence --- #

# Set some captions
full_size_word_wrap( get_lang_item( lang, "Rest Screen Caption" ), font_size, char_wrap, rest_text );
string complete_caption = get_lang_item( lang, "Completion Screen Caption" );

# Show the practice stuff if requested
int prac_trials = parameter_manager.get_int( "Practice Trials" );
if ( prac_trials > 0 ) then
	# Get some info about the practice trials
	double tgt_pct = double( tar_trials ) / double( ntar_trials );
	int prac_tgts = int( tgt_pct * double( prac_trials ) );
	int prac_ntgts = prac_trials - prac_tgts;
	
	# Get a random target
	int prac_tgt = block_order[ random( 1, block_order.count() ) ];
	
	# Build the practice trial sequence
	build_trial_order( prac_tgt, num_stim, prac_tgts, prac_ntgts );
	
	# Show block instructions
	show_main_instructions();
	show_block_instructions( prac_tgt, true );
	ready_set_go();
	
	# Show the practice trial sequence
	show_block( PRACTICE_TYPE_PRACTICE, 0, prac_tgt );
	
	present_instructions( get_lang_item( lang, "Practice Complete Caption" ) );
else
	show_main_instructions();
end;

# Now show the trial blocks
loop
	int i = 1
until
	i > block_order.count()
begin
	int this_tgt = block_order[i];
	build_trial_order( this_tgt, num_stim, tar_trials, ntar_trials );
	show_block_instructions( this_tgt, false );
	ready_set_go();
	show_block( PRACTICE_TYPE_MAIN, i, this_tgt );
	
	if ( i < block_order.count() ) then
		show_rest( false );
	end;
	
	i = i + 1;
end;
present_instructions( complete_caption );