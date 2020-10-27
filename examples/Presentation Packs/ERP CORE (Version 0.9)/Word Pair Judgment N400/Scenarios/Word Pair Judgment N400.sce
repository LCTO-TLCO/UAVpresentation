# -------------------------- Header Parameters --------------------------

scenario = "Word Pair Judgment N400";

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
	list_number, number,
	trial_number, number,
	prime_stim, string,
	tgt_stim, string,
	cond_name, string,
	ISI_dur, number,
	ITI_dur, number,
	prime_p_code, number,
	tgt_p_code, number;
event_code_delimiter = ";";

# ------------------------------- SDL Part ------------------------------
begin;

ellipse_graphic {
	ellipse_height = EXPARAM( "Fixation Point Size" );
	ellipse_width = EXPARAM( "Fixation Point Size" );
	color = EXPARAM( "Fixation Point Color" );
} fix_circ;

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
		picture {
			text {
				caption = "Target";
				font_size = EXPARAM( "Stimulus Font Size" );
				font_color = EXPARAM( "Prime Color" );
				transparent_color = EXPARAM( "Background Color" );
				font = EXPARAM( "Stimulus Font" );
				preload = false;
			} prime_text;
			x = 0;
			y = 0;
			
			ellipse_graphic fix_circ;
			x = 0;
			y = 0;
		} prime_pic;
	} prime_event;
} prime_trial;

trial {
	clear_active_stimuli = false;
	stimulus_event {
		picture {
			text {
				caption = "Target";
				font_size = EXPARAM( "Stimulus Font Size" );
				font_color = EXPARAM( "Target Color" );
				transparent_color = EXPARAM( "Background Color" );
				font = EXPARAM( "Stimulus Font" );
				preload = false;
			} tgt_text;
			x = 0;
			y = 0;
			
			ellipse_graphic fix_circ;
			x = 0;
			y = 0;
		} tgt_pic;
		response_active = true;
	} tgt_event;
} tgt_trial;
	
trial {
	trial_type = first_response;
	trial_duration = forever;
	
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

# --- CONSTANTS --- #

string STIM_EVENT_CODE = "Stimulus";

string PRACTICE_TYPE_PRACTICE = "Practice";
string PRACTICE_TYPE_MAIN = "Main";

string RELATED_BUTTON_LABEL = "[RELATED_BUTTON]";
string UNRELATED_BUTTON_LABEL = "[UNRELATED_BUTTON]";

string PRIME_COLOR_LABEL = "[PRIME_COLOR]";
string TARGET_COLOR_LABEL = "[TARGET_COLOR]";

string LOG_ACTIVE = "log_active";

string FILENAME_ONE = "N400_stimuli_list1_";
string FILENAME_TWO = "N400_stimuli_list2_";
string FILENAME_PRACTICE = "N400_stimuli_practice_";

string CASE_UPPER = "Upper";
string CASE_LOWER = "Lower";

string REL_COND = "Related";
string UNREL_COND = "Unrelated";

int REL_IDX = 1;
int UNREL_IDX = 2;

int CORR_BUTTON = 201;
int INCORR_BUTTON = 202;

int PRIME_IDX = 1;
int TGT_IDX = 2;

int PRIME_P_CODE = 1;
int TGT_P_CODE = 2;

int REL_P_CODE = 1;
int UNREL_P_CODE = 2;

int COND_LIST_IDX = 1;
int COND_COND_IDX = 2;
int COND_PRIME_IDX = 3;
int COND_TGT_IDX = 4;

string ISI_EVENT_CODE = "ISI";
string ITI_EVENT_CODE = "ITI";

string CHARACTER_WRAP = "Character";

# --- Set up fixed stimulus parameters --- #

string language = parameter_manager.get_string( "Language" );
language_file lang = load_language_file( scenario_directory + language + ".xml" );
bool char_wrap = ( get_lang_item( lang, "Word Wrap Mode" ).lower() == CHARACTER_WRAP.lower() );
double font_size = parameter_manager.get_double( "Non-Stimulus Font Size" );

# Setup the rest trial
begin
	int rest_dur = parameter_manager.get_int( "Rest Break Duration" );
	if ( rest_dur > 0 ) then
		rest_trial.set_type( rest_trial.FIXED );
		trial_refresh_fix( rest_trial, rest_dur );
		full_size_word_wrap( get_lang_item( lang, "Timed Rest Caption" ), font_size, char_wrap, rest_text );
	else
		full_size_word_wrap( get_lang_item( lang, "Untimed Rest Caption" ), font_size, char_wrap, rest_text );
	end;
end;

# Set some trial duraitons
trial_refresh_fix( prime_trial, parameter_manager.get_int( "Prime Duration" ) );
trial_refresh_fix( tgt_trial, parameter_manager.get_int( "Target Duration" ) );

# Setup the fixations on the ISI
if ( parameter_manager.get_bool( "Show Fixation Point During ISI" ) ) then
	ISI_pic.add_part( fix_circ, 0, 0 );
end;

if !( parameter_manager.get_bool( "Show Fixation Point During Stimulus" ) ) then
	prime_pic.set_part_on_top( 1, true );
	tgt_pic.set_part_on_top( 1, true );
end;

# Set the button numbers
begin
	array<int> temp_button_codes[2];
	temp_button_codes.fill( 1, 0, CORR_BUTTON, 0 );
	response_manager.set_target_button_codes( temp_button_codes );
	
	temp_button_codes.fill( 1, 0, INCORR_BUTTON, 0 );
	response_manager.set_button_codes( temp_button_codes );
end;

# Change response logging
if ( parameter_manager.get_string( "Response Logging" ) == LOG_ACTIVE ) then
	ISI_trial.set_all_responses( false );
	tgt_trial.set_all_responses( false );
	prime_trial.set_all_responses( false );
end;

# --- Subroutines --- #

# --- sub process_stim_file ---

string let_case = parameter_manager.get_string( "Stimulus Letter Case" );

sub
	process_stim_file( array<string,3>& stim_array, string input_filename )
begin
	# Open the input file only if it exists
	input_file in = new input_file;
	if ( !file_exists( input_filename ) ) then
		exit( "Error: The stimulus file '" + input_filename + "' does not exist." );
	end;
	in.open( input_filename );
	
	# Step through the file
	loop
	until
		in.end_of_file()
	begin
		# Split this line into component parts
		array<string> temp[0];
		string this_line = in.get_line();
		if ( let_case == CASE_UPPER ) then
			this_line = this_line.upper();
		elseif ( let_case == CASE_LOWER ) then
			this_line = this_line.lower();
		end;
		this_line.split( "\t", temp );
		
		# Add the related word pair		
		array<string> this_pair[2];
		if ( temp.count() >= REL_IDX * 2 ) then
			int start = ( REL_IDX * 2 ) - 1;
			if ( temp[start].count() > 0 ) && ( temp[start + 1].count() > 0 ) then
				this_pair[1] = temp[start];
				this_pair[2] = temp[start + 1];
				stim_array[REL_IDX].add( this_pair );
			end;
		end;

		# Add the unrelated pair
		if ( temp.count() >= UNREL_IDX * 2 ) then
			int start = ( UNREL_IDX * 2 ) - 1;
			if ( temp[start].count() > 0 && temp[start + 1].count() > 0 ) then
				this_pair[1] = temp[start];
				this_pair[2] = temp[start + 1];
				stim_array[UNREL_IDX].add( this_pair );
			end;
		end;
		
	end;
end;

# --- sub present_instructions 

sub
	present_instructions( string instruct_string )
begin
	full_size_word_wrap( instruct_string, font_size, char_wrap, instruct_text );
	instruct_trial.present();
	default.present();
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

# --- sub show_wait

sub
	show_wait( string ev_code, int req_dur )
begin
	ISI_event.set_event_code( ev_code );
	trial_refresh_fix( ISI_trial, req_dur );
	ISI_trial.present();
end;

# --- sub string_replace

array<string> button_names[2];
button_names[1] = parameter_manager.get_string( "Response Button 1 Name" );
button_names[2] = parameter_manager.get_string( "Response Button 2 Name" );

array<int> corr_buttons[2];
corr_buttons[REL_IDX] = parameter_manager.get_int( "Response Button Mapping" );
corr_buttons[UNREL_IDX] = ( corr_buttons[REL_IDX] % 2 ) + 1;

sub
	string string_replace( string start_string )
begin
	string rval = start_string;
	rval = rval.replace( RELATED_BUTTON_LABEL, button_names[corr_buttons[REL_IDX]] );
	rval = rval.replace( UNRELATED_BUTTON_LABEL, button_names[corr_buttons[UNREL_IDX]] );
	return rval
end;

# --- sub set_port_code

sub
	int get_port_code( bool is_tgt, bool is_related, int list_num )
begin
	string rval = string( PRIME_P_CODE );
	if ( is_tgt ) then
		rval = string( TGT_P_CODE );
	end;
	
	if ( is_related ) then
		rval.append( string( REL_P_CODE ) );
	else
		rval.append( string( UNREL_P_CODE )  );
	end;
	
	rval.append( string( list_num ) );
	return int( rval )
end;

# --- sub trial_block

array<int> ISI_range[0];
parameter_manager.get_ints( "Prime-to-Target ISI Range", ISI_range );
if ( ISI_range.count() != 2 ) then
	exit( "Error: You must specify exactly two values in 'Prime-to-Target ISI Range'" );
end;

array<int> ITI_range[0];
parameter_manager.get_ints( "Trial-to-Trial ISI Range", ITI_range );
if ( ITI_range.count() != 2 ) then
	exit( "Error: You must specify exactly two values in 'Trial-to-Trial ISI Range'" );
end;

array<string> cond_names[2];
cond_names[REL_IDX] = REL_COND;
cond_names[UNREL_IDX] = UNREL_COND;

string instructions = string_replace( get_lang_item( lang, "Instructions" ) );
begin
	rgb_color prime_color = parameter_manager.get_color( "Prime Color" );
	string rep_string = "<font color='" + color_to_string( prime_color ) + "'>";
	rep_string.append( parameter_manager.get_string( "Prime Color Name" ) + "</font>" );
	instructions = instructions.replace( PRIME_COLOR_LABEL, rep_string );
		
	rgb_color tgt_color = parameter_manager.get_color( "Target Color" );
	rep_string = "<font color='" + color_to_string( tgt_color ) + "'>";
	rep_string.append( parameter_manager.get_string( "Target Color Name" ) + "</font>" );
	instructions = instructions.replace( TARGET_COLOR_LABEL, rep_string );
	instruct_text.set_formatted_text( true );
end;

string reminder_cap = string_replace( get_lang_item( lang, "Reminder Caption" ) );
int trials_per_rest = parameter_manager.get_int( "Trials Between Rest Breaks" );

sub
	trial_block( array<string,2>& trial_array, string prac_check )
begin
	# Get ready screen
	ready_set_go();
	
	# Start with an ISI
	show_wait( ISI_EVENT_CODE, random( ISI_range[1], ISI_range[2] ) );
	
	# Loop to present trials
	loop
		int i = 1
	until
		i > trial_array.count()
	begin
		# Get trial info
		int this_list = int( trial_array[i][COND_LIST_IDX] );
		int this_cond = int( trial_array[i][COND_COND_IDX] );
		string prime_stim = trial_array[i][COND_PRIME_IDX];
		string tgt_stim = trial_array[i][COND_TGT_IDX];

		# Set captions
		prime_text.set_caption( prime_stim, true );
		tgt_text.set_caption( tgt_stim, true );
	
		# Set ISI
		int ISI_dur = random( ISI_range[1], ISI_range[2] );
		int ITI_dur = random( ITI_range[1], ITI_range[2] );
		
		# Set buttons
		tgt_event.set_target_button( corr_buttons[this_cond] );
		
		# Set port code
		int prime_p_code = get_port_code( false, this_cond == REL_IDX, this_list );
		int tgt_p_code = get_port_code( true, this_cond == REL_IDX, this_list );
		prime_event.set_port_code( prime_p_code );
		tgt_event.set_port_code( tgt_p_code );

		# Set Event code
		tgt_event.set_event_code(
			STIM_EVENT_CODE + ";" + 
			prac_check + ";" +
			string( this_list ) + ";" +
			string( i ) + ";" + 
			prime_stim + ";" +
			tgt_stim + ";" +
			cond_names[this_cond] + ";" +
			string( ISI_dur ) + ";" +
			string( ITI_dur ) + ";" +
			string( prime_p_code ) + ";" +
			string( tgt_p_code )
		);
		
		# Show stim
		prime_trial.present();
		show_wait( ISI_EVENT_CODE, ISI_dur );
		tgt_trial.present();
		show_wait( ITI_EVENT_CODE, ITI_dur );
		
		# Rest Trial
		if ( trials_per_rest > 0 ) && ( prac_check == PRACTICE_TYPE_MAIN ) then
			if ( i % trials_per_rest == 0 ) && ( i < trial_array.count() ) then
				rest_trial.present();
				present_instructions( reminder_cap );
				ready_set_go();
				show_wait( ISI_EVENT_CODE, random( ISI_range[1], ISI_range[2] ) );
			end;
		end;
		
		i = i + 1;
	end;
end;

# --- Conditions & Trial Order --- #

array<string> cond_array[0][0];
array<string> prac_cond_array[0][0];

begin
	# Get the list order
	array<int> list_order[0];
	parameter_manager.get_ints( "List Order", list_order );
	if ( list_order.count() == 0 ) then
		exit( "Error: You must specify at least one value in 'List Order'" );
	end;
	if ( parameter_manager.get_bool( "Randomize Word List Order" ) ) then
		list_order.shuffle();
	end;
	int list_ct = int_array_max( list_order );

	# Add the stimuli to the proper arrays
	array<string> all_stim[2][2][0][0];
	process_stim_file( all_stim[1], stimulus_directory + FILENAME_ONE + language + ".txt" );
	if ( list_ct > 1 ) then
		process_stim_file( all_stim[2], stimulus_directory + FILENAME_TWO + language + ".txt" );
	end;
	
	# Get the trial counts
	int rel_trials = parameter_manager.get_int( "Related Trials per List" );
	int unrel_trials = parameter_manager.get_int( "Unrelated Trials per List" );
	
	# Check whether we have enough stimuli
	loop
		int i = 1
	until
		i > list_ct
	begin
		if ( all_stim[i][REL_IDX].count() < rel_trials ) then
			exit( "Error: Not enough related word pairs in stimulus list " + string( i ) + ". Add more stimuli or reduce trial count." );
		end;
		if ( all_stim[i][UNREL_IDX].count() < unrel_trials ) then
			exit( "Error: Not enough unrelated word pairs in stimulus list " + string( i ) + ". Add more stimuli or reduce trial count." );
		end;
		i = i + 1;
	end;
	
	# Build a rel/unrel trial order
	array<int> cond_order[rel_trials + unrel_trials];
	cond_order.fill( 1, 0, UNREL_IDX, 0 );
	cond_order.fill( 1, rel_trials, REL_IDX, 0 );
	
	# To specify a trial: list, rel/unrel, prime, target
	bool shuffle_stim = parameter_manager.get_bool( "Randomize Stimulus Order" );
	loop
		int list_ctr = 1
	until
		list_ctr > list_order.count()
	begin
		int this_list = list_order[list_ctr];
		
		# Randomize stimulus order
		all_stim[this_list][REL_IDX].shuffle( 1, rel_trials );
		all_stim[this_list][UNREL_IDX].shuffle( 1, unrel_trials );
		
		# Randomize trial order
		cond_order.shuffle();
		
		loop
			array<int> ctrs[2] = { 1, 1 };
			int cond_ctr = 1
		until
			cond_ctr > cond_order.count()
		begin
			int this_cond = cond_order[cond_ctr];
			
			string prime_string = all_stim[this_list][this_cond][ctrs[this_cond]][1];
			string tgt_string = all_stim[this_list][this_cond][ctrs[this_cond]][2];
			
			array<string> temp[4];
			temp[COND_LIST_IDX] = string( this_list );
			temp[COND_COND_IDX] = string( this_cond );
			temp[COND_PRIME_IDX] = prime_string;
			temp[COND_TGT_IDX] = tgt_string;
			
			cond_array.add( temp );
			
			cond_ctr = cond_ctr + 1;
			ctrs[this_cond] = ctrs[this_cond] + 1;
		end;
		list_ctr = list_ctr + 1;
	end;
	
	# Set up practice trials
	int prac_trials = parameter_manager.get_int( "Practice Trials" );
	if ( prac_trials > 0 ) then
		array<string> prac_stim[2][0][0];
		process_stim_file( prac_stim, stimulus_directory + FILENAME_PRACTICE + language + ".txt" );
		loop
			int cond = 1
		until
			cond > prac_stim.count()
		begin
			loop
				int j = 1
			until
				j > prac_stim[cond].count()
			begin
				array<string> temp[4];
				temp[COND_LIST_IDX] = "0";
				temp[COND_COND_IDX] = string( cond );
				temp[COND_PRIME_IDX] = prac_stim[cond][j][1];
				temp[COND_TGT_IDX] = prac_stim[cond][j][2];
				
				prac_cond_array.add( temp );
				j = j + 1;
			end;
			cond = cond + 1;
		end;
		
		# Exit if no practice stim available
		if ( prac_cond_array.count() == 0 ) then
			exit( "Error: No stimuli found in practice stimulus file: " + FILENAME_PRACTICE );
		end;

		# Fill out the complete sequence
		array<string> temp_prac[0][0];
		temp_prac.assign( prac_cond_array );
		prac_cond_array.shuffle();
		loop
		until
			prac_cond_array.count() >= prac_trials
		begin
			temp_prac.shuffle();
			prac_cond_array.append( temp_prac );
		end;
		prac_cond_array.resize( prac_trials );
	end;
end;	

# --- Main Sequence --- #

# Set some captions
string complete_caption = string_replace( get_lang_item( lang, "Completion Screen Caption" ) );

# Main sequence
if ( prac_cond_array.count() > 0 ) then
	present_instructions( instructions + " " + string_replace( get_lang_item( lang, "Practice Caption" ) ) );
	trial_block( prac_cond_array, PRACTICE_TYPE_PRACTICE );
	present_instructions( string_replace( get_lang_item( lang, "Practice Complete Caption" ) ) );
	present_instructions( reminder_cap );
else
	present_instructions( instructions );
end;
trial_block( cond_array, PRACTICE_TYPE_MAIN );
present_instructions( complete_caption );