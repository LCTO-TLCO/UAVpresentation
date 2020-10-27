# -------------------------- Header Parameters --------------------------

scenario = "Stop Signal Task";

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
	stim_caption, string, 
	stim_cond, string,
	stop_type, string,
	curr_ssd, number;
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
				font = EXPARAM( "Stimulus Font" );
				font_size = EXPARAM( "Stimulus Font Size" );
				font_color = EXPARAM( "Stimulus Color" );
				preload = false;
			} stim_text;
			x = 0;
			y = 0;
		} stim_pic;
	} stim_event;
} stim_trial;

trial {
	clear_active_stimuli = false;
	stimulus_event {
		picture {
			text {
				caption = "Stop";
				font = EXPARAM( "Stop Signal Font" );
				font_size = EXPARAM( "Stop Signal Font Size" );
				font_color = EXPARAM( "Stop Signal Color" );
				preload = false;
			} stop_text;
			x = 0;
			y = 0;
		} stop_pic;
		code = "Stop";
	} stop_event;	
} stop_trial;

trial {
	nothing{};
} clear_trial;

trial {
	stimulus_event {
		picture { 
			text { 
				caption = "Feedback";
				preload = false;
			} feedback_text; 
			x = 0;
			y = 0;
		};
		code = "Feedback";
	} feedback_event;
} feedback_trial;

trial { 
	stimulus_event { 
		picture {}; 
		code = "ITI"; 
	} ITI_event; 
} ITI_trial;

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

string STIM_EVENT_CODE = "Stim";

string FEEDBACK_TYPE_ALL = "All";
string FEEDBACK_TYPE_NONE = "None";

string PRACTICE_TYPE_PRACTICE = "Practice";
string PRACTICE_TYPE_MAIN = "Main";

string LEFT_STIM_LABEL = "[LEFT_STIM]";
string RIGHT_STIM_LABEL = "[RIGHT_STIM]";
string STOP_STIM_LABEL = "[STOP_STIM]";

int BUTTON_LEFT = 1;
int BUTTON_RIGHT = 2;

int COND_LEFT_IDX = 1;
int COND_RIGHT_IDX = 2;

string COND_LEFT = "Left";
string COND_RIGHT = "Right";

int STIM_IDX = 1;
int TYPE_IDX = 2;

string COND_GO = "Go";
string COND_STOP = "Stop";

int COND_GO_IDX = 1;
int COND_STOP_IDX = 2;

int LEFT_PORT_CODE = 11;
int LEFT_STOP_PORT_CODE = 110;
int RIGHT_PORT_CODE = 21;
int RIGHT_STOP_PORT_CODE = 210;

string CHARACTER_WRAP = "Character";

# --- Set up fixed stimulus parameters ---

string language = parameter_manager.get_string( "Language" );
language_file lang = load_language_file( scenario_directory + language + ".xml" );
bool char_wrap = ( get_lang_item( lang, "Word Wrap Mode" ).lower() == CHARACTER_WRAP.lower() );

adjust_used_screen_size( parameter_manager.get_bool( "Use Widescreen if Available" ) );

double font_size = parameter_manager.get_double( "Default Font Size" );

# --- Events ---

int fix_duration = parameter_manager.get_int( "Fixation Point Duration" );
trial_refresh_fix( fix_trial, fix_duration );
fix_event.set_port_code( default_port_code1 );

stim_event.set_duration( simple_refresh_fix( parameter_manager.get_int( "Stimulus Duration" ) ) );

int SDT = parameter_manager.get_int( "Stop Signal Duration (SDT)" );
trial_refresh_fix( stop_trial, SDT );

trial_refresh_fix( feedback_trial, parameter_manager.get_int( "Feedback Duration" ) );

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

# --- Set up text stimuli ---

array<string> stim_caps[2];
begin
	string left_cap = parameter_manager.get_string( "Left Response Stimulus" );
	string right_cap = parameter_manager.get_string( "Right Response Stimulus" );
	string stop_cap = parameter_manager.get_string( "Stop Signal Caption" );
	if ( left_cap.count() == 0 || right_cap.count() == 0 ) then
		exit( "Error: 'Left Response Caption', 'Right Response Caption', and 'Stop Signal Caption' cannot be empty." );
	end;
	stop_text.set_caption( stop_cap, true );
	stim_caps[COND_LEFT_IDX] = left_cap;
	stim_caps[COND_RIGHT_IDX] = right_cap;
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

# --- sub show_ITI ---

array<int> ITI_durations[0];
parameter_manager.get_ints( "ITI Durations", ITI_durations );
if ( ITI_durations.count() == 0 ) then
	exit( "Error: 'ITI Durations' must contain at least one value." );
end;

sub 
	show_ITI
begin
	int rand_dur = ITI_durations[random( 1, ITI_durations.count() )];
	trial_refresh_fix( ITI_trial, rand_dur );
	ITI_trial.present();
end;

# --- sub show_fixation ---

sub 
	show_fixation
begin
	if ( fix_duration > 0 ) then
		fix_trial.present();
	end;
end;

# --- sub show_feedback ---

string fb_type = parameter_manager.get_string( "Feedback Type" );
string fb_correct = fix_empty_string( parameter_manager.get_string( "Correct Feedback Caption" ) );
string fb_incorrect = fix_empty_string( parameter_manager.get_string( "Incorrect Feedback Caption" ) );
string prac_fb_type = parameter_manager.get_string( "Practice Trials Feedback Type" );

sub
	show_feedback( string practice_check, bool correct_resp )
begin
	# Get feedback type
	string type = fb_type;
	if ( practice_check == PRACTICE_TYPE_PRACTICE ) then
		type = prac_fb_type;
	end;
	
	# Update caption and show feedback, if necessary
	if ( type != FEEDBACK_TYPE_NONE ) then
		feedback_text.set_caption( fb_incorrect );
		if ( correct_resp ) then
			feedback_text.set_caption( " " );
			if ( type == FEEDBACK_TYPE_ALL ) then
				feedback_text.set_caption( fb_correct );
			end;
		end;
		full_size_word_wrap( feedback_text.caption(), font_size, char_wrap, feedback_text );
		feedback_trial.present();
	end;
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

# --- sub correct_resp
# checks whether a response was correct (for stop trials, no response should be made)
sub
	bool correct_resp( bool stop_type, stimulus_data stim_data )
begin
	bool resp_type = false;
	if ( stop_type ) then
		if ( stim_data.type() == stim_data.OTHER ) then
			resp_type = true;
		end;
	else
		if ( stim_data.type() == stim_data.HIT ) then
			resp_type = true;
		end;
	end;
	return resp_type
end;

# --- sub get_port_code ---
# return the port code for this trial based on side L/R and Stop/Go condition

sub
	int get_port_code( int side_val, bool stop_type )
begin
	int rval = RIGHT_PORT_CODE;
	if ( side_val == COND_LEFT_IDX ) then
		if ( stop_type ) then
			rval = LEFT_STOP_PORT_CODE;
		else
			rval = LEFT_PORT_CODE;
		end;
	elseif ( stop_type ) then
		rval = RIGHT_STOP_PORT_CODE;
	end;
	return rval;
end;

# --- sub show_block

int SSD_inc = int( display_device.refresh_period() * double( parameter_manager.get_int( "SSD Increment" ) ) );
int start_SSD = parameter_manager.get_int( "Stop Signal Delay (SSD)" );
int SSD_min = parameter_manager.get_int( "Minimum SSD" );
int SSD_max = parameter_manager.get_int( "Maximum SSD" );
int final_SSD = 0;

array<string> stim_conds[2];
stim_conds[COND_LEFT_IDX] = COND_LEFT;
stim_conds[COND_RIGHT_IDX] = COND_RIGHT;

array<string> type_conds[2];
type_conds[COND_GO_IDX] = COND_GO;
type_conds[COND_STOP_IDX] = COND_STOP;

# -- Set up info for summary stats -- #
int SUM_STOP_IDX = 1;

# Put all the condition names into an array
# Used later to add column headings
array<string> cond_names[1][0];
cond_names[SUM_STOP_IDX].assign( type_conds );

# Now build an empty array for all DVs of interest
array<int> acc_stats[cond_names[1].count()][0];
array<int> RT_stats[cond_names[1].count()][0];
# --- End Summary Stats --- #

sub
	double show_block( array<int,2>& trial_order, string prac_check )
begin
	# Randomize the trial order
	trial_order.shuffle();
	
	# Show an ITI to start as a buffer
	show_ITI();
	
	# Loop to show trials
	int SSD = start_SSD;
	double block_acc = 0.0;
	loop
		int hits = 0;
		int i = 1
	until
		i > trial_order.count()
	begin
		# This trial info
		int this_stim = trial_order[i][STIM_IDX];
		bool stop = bool( trial_order[i][TYPE_IDX] );
		string dir_type = stim_conds[this_stim];
		string stop_type = COND_GO;
		
		# Set the stim caption
		stim_text.set_caption( stim_caps[this_stim], true );
		
		# Set the target button ( 0 for stop trials )
		if ( stop ) then
			stim_event.set_target_button( 0 );
			stop_type = COND_STOP;
		else
			stim_event.set_target_button( this_stim );
		end;
		stim_event.set_response_active( true );
		
		# Port code
		int p_code = get_port_code( this_stim, stop );
		stim_event.set_port_code( p_code );
		
		# Set event code
		stim_event.set_event_code( 
			STIM_EVENT_CODE + ";" +
			prac_check + ";" +
			string( i ) + ";" +
			stim_text.caption() + ";" + 
			dir_type + ";" +
			stop_type + ";" +
			string( SSD )
		);
		
		# Set the trial duration. Equal to SSD for stop trials, 
		# SSD + SDT for non-stop
		if ( stop ) then
			trial_refresh_fix( stim_trial, SSD );
		else
			trial_refresh_fix( stim_trial, SSD + SDT );
		end;
		
		# Trial sequence
		show_fixation();
		stim_trial.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		if ( stop ) then
			stop_trial.present();
		end;
		clear_trial.present();
		bool corr_resp = correct_resp( stop, last );
		
		show_feedback( prac_check, corr_resp );
		show_ITI();
		
		# Update the accuracy counter
		if ( corr_resp ) then
			hits = hits + 1;
		end;
		block_acc = double( hits ) / double( i );
		
		# Record trial info for summary stats
		# Make an int array specifying the condition we're in
		# This tells us which subarray to store the trial info
		if ( prac_check == PRACTICE_TYPE_MAIN ) then
			array<int> this_trial[cond_names.count()];
			if ( stop ) then
				this_trial[SUM_STOP_IDX] = COND_STOP_IDX;
			else
				this_trial[SUM_STOP_IDX] = COND_GO_IDX;
			end;
			
			int this_hit = int( corr_resp );
			acc_stats[this_trial[1]].add( this_hit );
			if ( last.reaction_time() > 0 ) then
				RT_stats[this_trial[1]].add( last.reaction_time() );
			end;
		end;	
		
		# Update the SSD, increases after successful stop, decreases after accidental go
		if ( stop ) then
			if ( corr_resp ) then
				SSD = SSD + SSD_inc;
				if ( SSD > SSD_max ) then
					SSD = SSD_max;
				end;
			else
				SSD = SSD - SSD_inc;
				if ( SSD < SSD_min ) then
					SSD = SSD_min;
				end;
			end;
		end;
		
		# Show rest
		if ( prac_check == PRACTICE_TYPE_MAIN ) then
			if ( show_rest( i, trial_order.count() ) ) then
				show_ITI();
			end;
		end;
		
		i = i + 1;
	end;
	final_SSD = SSD;
	return block_acc
end;

# --- Conditions & Trial Order

array<int> cond_array[0][0];
array<int> prac_cond_array[0][0];

sub
	add_trials( int stim_val, int stop_val, int repeats )
begin
	array<int> temp[2];
	temp[STIM_IDX] = stim_val;
	temp[TYPE_IDX] = stop_val;
	loop
		int i = 1
	until
		i > repeats
	begin
		cond_array.add( temp );
		i = i + 1;
	end;
end;

begin
	add_trials( COND_LEFT_IDX, 0, parameter_manager.get_int( "Left Trials" ) );
	add_trials( COND_RIGHT_IDX, 0, parameter_manager.get_int( "Right Trials" ) );
	add_trials( COND_LEFT_IDX, 1, parameter_manager.get_int( "Left Stop Trials" ) );
	add_trials( COND_RIGHT_IDX, 1, parameter_manager.get_int( "Right Stop Trials" ) );
	
	int prac_trials = parameter_manager.get_int( "Practice Trials" );
	loop
	until
		prac_cond_array.count() >= prac_trials
	begin
		prac_cond_array.add( cond_array[random(1,cond_array.count())] );
	end;
end;

# --- Main Sequence --- 

string instructions = get_lang_item( lang, "Instructions" );
instructions = instructions.replace( LEFT_STIM_LABEL, stim_caps[COND_LEFT_IDX] );
instructions = instructions.replace( RIGHT_STIM_LABEL, stim_caps[COND_RIGHT_IDX] );
instructions = instructions.replace( STOP_STIM_LABEL, stop_text.caption() );
int prac_threshold = parameter_manager.get_int( "Minimum Percent Correct to Complete Practice" );

if ( prac_cond_array.count() > 0 ) then
	main_instructions( instructions + " " + get_lang_item( lang, "Practice Caption" ) );
	loop 
		double block_accuracy = -1.0
	until 
		block_accuracy >= ( double( prac_threshold ) / 100.0 )
	begin
		block_accuracy = show_block( prac_cond_array, PRACTICE_TYPE_PRACTICE );
	end;
	main_instructions( get_lang_item( lang, "Practice Complete Caption" ) );
else
	present_instructions( instructions );
end;

show_block( cond_array, PRACTICE_TYPE_MAIN );

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
	cond_headings[SUM_STOP_IDX + 1] = "Stim Type";
	cond_headings.add( "Accuracy" );
	cond_headings.add( "Accuracy (SD)" );
	cond_headings.add( "Avg RT" );
	cond_headings.add( "Avg RT (SD)" );
	cond_headings.add( "Median RT" );
	cond_headings.add( "Final SSD (ms)" );
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
		out.print( final_SSD );
		out.print( TAB );
		out.print( acc_stats[i].count() );
		out.print( TAB );
		out.print( date_time() );
		i = i + 1;
	end;

	# Close the file and exit
	out.close();
end;