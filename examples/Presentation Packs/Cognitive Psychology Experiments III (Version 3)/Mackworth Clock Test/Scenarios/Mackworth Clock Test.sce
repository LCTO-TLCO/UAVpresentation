# -------------------------- Header Parameters --------------------------

scenario = "Mackworth Clock Test";

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
	trial_number, number,
	stim_pos, number,
	elapsed_time, number,
	skip_cond, string,
	num_skips, number;
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
		code = "Stim";
	} stim_event;
} stim_trial;

trial {
	stimulus_event {
		picture stim_pic;
		code = "Delay";
	} delay_event;
} delay_trial;

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

string STIM_EVENT_CODE = "Stim";

string DIRECTION_LABEL = "[DIRECTION]";

int BUTTON_SKIP = 1;
int BUTTON_STD = 0;

int SKIP_IDX = 1;
int STD_IDX = 2;

int PORT_CODE_SKIP = 20;
int PORT_CODE_STD = 10;

string CHARACTER_WRAP = "Character";

# --- Set up fixed stimulus parameters ---

string language = parameter_manager.get_string( "Language" );
language_file lang = load_language_file( scenario_directory + language + ".xml" );
bool char_wrap = ( get_lang_item( lang, "Word Wrap Mode" ).lower() == CHARACTER_WRAP.lower() );

adjust_used_screen_size( parameter_manager.get_bool( "Use Widescreen if Available" ) );

double font_size = parameter_manager.get_double( "Default Font Size" );

trial_refresh_fix( stim_trial, parameter_manager.get_int( "Stimulus Duration" ) );
trial_refresh_fix( delay_trial, parameter_manager.get_int( "Delay Duration" ) );

# --- Stimulus Setup ---

bool clockwise = parameter_manager.get_bool( "Clockwise Movement" );
annulus_graphic small_circ = new annulus_graphic();
ellipse_graphic inner_ellipse = new ellipse_graphic();
ellipse_graphic tgt_ellipse = new ellipse_graphic();
array<double> end_locs[0][0];

begin
	# Initialize some values
	double clock_size = parameter_manager.get_double( "Clock Diameter" );
	double clock_rad = clock_size * 0.5;
	double circle_size = parameter_manager.get_double( "Circle Diameter" );
	double line_width = parameter_manager.get_double( "Outline Line Width" );
	double circumference = clock_size * pi_value;
	
	# Figure out how many degrees of arc are between each circle
	double num_circles = double( parameter_manager.get_int( "Clock Positions" ) );
	double small_degrees = ( 2.0 * pi_value ) / round( num_circles, 0 );

	# Draw the small circles
	double c_adj = line_width/2.0;
	small_circ.set_color( parameter_manager.get_color( "Circle Outline Color" ) );
	small_circ.set_dimensions( circle_size - c_adj, circle_size - c_adj, circle_size + c_adj, circle_size + c_adj );
	small_circ.redraw();
	bool add_outline = ( parameter_manager.get_color( "Circle Outline Color" ) ) != parameter_manager.get_color( "Default Background Color" );

	# Draw the ellipse
	rgb_color fill_color = parameter_manager.get_color( "Circle Fill Color" );
	inner_ellipse.set_dimensions( circle_size - c_adj, circle_size - c_adj );
	inner_ellipse.set_color( fill_color );
	inner_ellipse.redraw();

	# Draw the target/highlighted ellipse
	rgb_color sel_color = parameter_manager.get_color( "Selected Circle Fill Color" );
	tgt_ellipse.set_dimensions( circle_size - c_adj, circle_size - c_adj );
	tgt_ellipse.set_color( sel_color );
	tgt_ellipse.redraw();

	# Add the picture parts to the stimulus pic and save the locs
	# Go from 2pi -> 0 because that orders the circles in a clockwise direction
	array<double> locs[0][0];
	loop
		double deg = pi_value * 2.0
	until
		deg <= 0.0
	begin
		double this_x = clock_rad * cos( deg );
		double this_y = clock_rad * sin( deg );
		
		# Only draw the outline if it's different than the bg color
		if ( add_outline ) then
			stim_pic.add_part( small_circ, this_x, this_y );
		end;
		stim_pic.add_part( inner_ellipse, this_x, this_y );
		
		# Add each x/y location to the locs array
		array<double> temp[2];
		temp[1] = this_x;
		temp[2] = this_y;
		locs.add( temp );
		
		deg = deg - small_degrees; 
	end;

	# Exit if the circles end up too close together
	double min_dist = inner_ellipse.width();
	if ( add_outline ) then
		min_dist = small_circ.width();
	end;
	if ( dist( locs[1][1], locs[1][2], locs[2][1], locs[2][2] ) <= min_dist ) then
		exit( "Error: Not enough space to draw all the circles. Reduce 'Clock Positions' or 'Circle Diameter', or increase 'Clock Diameter'." );
	end;
	
	# Because of the rounding we did earlier, it's possible that the first
	# and last circle in the list will overlap. If they do, we want to get
	# rid of that overlap (by cutting out the last value).
	if ( round( locs[1][1], 3 ) == round( locs[locs.count()][1], 3 ) ) &&
		( round( locs[1][2], 3 ) == round( locs[locs.count()][2], 3 ) ) then
		locs.resize( locs.count() - 1 );
	end;

	# To look more like a clock, we want to re-order the list of x/y
	# locations so that the first value is at the top. Start by finding
	# the index of the maximum y value.
	int max_y_idx = 1;
	loop
		double max_y = 0.0;
		int i = 1
	until
		i > locs.count()
	begin
		if ( locs[i][2] > max_y ) then
			max_y_idx = i;
			max_y = locs[i][2];
		end;
		i = i + 1;
	end;

	# Now loop through, starting with the max y,
	# and place the values in order in the end_locs array
	loop
		int j = max_y_idx
	until
		j == max_y_idx -1
	begin
		if ( j > locs.count() ) then
			j = 1
		end;
		end_locs.add( locs[j] );
		j = j + 1;
		if ( j == max_y_idx - 1 ) then
			end_locs.add( locs[j] );
		end;
	end;
	
	# We need to reverse the array "end_locs" if the user requests
	# counter-clockwise rotation
	if ( !clockwise ) then
		array<double> temp_locs[0][0];
		temp_locs.add( end_locs[1] );
		loop
			int i = end_locs.count()
		until
			i < 2
		begin
			temp_locs.add( end_locs[i] );
			i = i - 1;
		end;
		end_locs.assign( temp_locs );
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

# --- sub show_sequence

# -- Summary stat holders -- #
int hit_ct = 0;
int miss_ct = 0;
int FA_ct = 0;
int CR_ct = 0;
# -- End Summary Stat -- #

int skip_ctr = 0;

sub
	int show_sequence( array<int,1>& cond_array )
begin
	# Start with a brief wait
	delay_trial.present();
	
	# Main loop to run sequence
	int start = clock.time();
	loop
		int loc_ctr = 1;
		int i = 1
	until
		i > cond_array.count()
	begin
		# Start with assumed values
		int skip = cond_array[i];
		
		# Get the target position
		loc_ctr = loc_ctr + skip;
		skip_ctr = skip_ctr + skip;
		
		# Add the target ellipse
		stim_pic.add_part( tgt_ellipse, end_locs[loc_ctr][1], end_locs[loc_ctr][2] );
		
		# Set target button & port code
		int p_code = PORT_CODE_STD;
		if ( skip > 0 ) then
			stim_event.set_target_button( BUTTON_SKIP );
			p_code = PORT_CODE_SKIP;
		else
			stim_event.set_target_button( 0 );
		end;
		stim_event.set_response_active( true );
		stim_event.set_port_code( p_code );

		# Present the stimulus
		stim_trial.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		
		# Remove the target for the delay
		stim_pic.remove_part( stim_pic.part_count() );
		delay_trial.present();
		
		# Save the initial start time
		if ( i == 1 ) then
			start = last.time();
		end;
		
		# Set the event code
		last.set_event_code( 
			STIM_EVENT_CODE + ";" +
			string( i ) + ";" +
			string( loc_ctr ) + ";" +
			string( last.time() - start ) + ";" +
			string( bool( skip ) ) + ";" +
			string( skip_ctr )
		);
		
		# Summary stats
		if ( last.type() == last.HIT ) then
			hit_ct = hit_ct + 1;
		elseif ( last.type() == last.FALSE_ALARM ) then
			FA_ct = FA_ct + 1;
		elseif ( last.type() == last.MISS ) then
			miss_ct = miss_ct + 1;
		else
			CR_ct = CR_ct + 1;
		end;

		# Increment the counters. If we've completed a full
		# circuit, then reset the loc_ctr to 1
		loc_ctr = loc_ctr + 1;
		if ( loc_ctr > end_locs.count() ) then
			loc_ctr = 1;
		end;
		
		i = i + 1;
	end;
	return clock.time() - start
end;

# --- Conditions & Trial Order --- #

array<int> cond_array[0];

begin
	int min_b = parameter_manager.get_int( "Min Standards Between Skips" );
	int std_trials = parameter_manager.get_int( "Standard Trials" );
	int skip_trials = parameter_manager.get_int( "Skip Trials" );
	
	# Check if the settings are legal
	if ( skip_trials * ( min_b + 1 ) ) > std_trials then
		exit( "Error: Not enough standard trials. Add additional standard trials, reduce skip trials, or reduce 'Min Standards Between Skips'" );
	end;
	
	# Make a temporary trial order, removing the standards that must precede each skip
	int std_less_skips = std_trials - ( skip_trials * min_b );
	array<int> temp_order[std_less_skips+skip_trials];
	temp_order.fill( 1, skip_trials, 1, 0 );
	temp_order.shuffle();
	
	# Expand that to a full sequence
	array<int> add_skip[min_b + 1];
	add_skip[add_skip.count()] = 1;
	loop
		int i = 1
	until
		i > temp_order.count()
	begin
		if ( temp_order[i] == 0 ) then
			cond_array.add( 0 );
		else
			cond_array.append( add_skip );
		end;
		i = i + 1;
	end;
end;


# --- Main Sequence ---

string instructions = get_lang_item( lang, "Instructions" );
if ( clockwise ) then
	instructions = instructions.replace( DIRECTION_LABEL, get_lang_item( lang, "Clockwise" ) );
else
	instructions = instructions.replace( DIRECTION_LABEL, get_lang_item( lang, "Counter-Clockwise" ) );
end;

main_instructions( instructions );
int total_dur = show_sequence( cond_array );
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
	array<string> cond_headings[0];
	cond_headings.add( "Subject ID" );
	cond_headings.add( "Total Time (s)" );
	cond_headings.add( "Total Trials" );
	cond_headings.add( "Total Skips" );
	cond_headings.add( "Hits" );
	cond_headings.add( "Misses" );
	cond_headings.add( "False Alarms" );
	cond_headings.add( "Correct Rejections" );
	cond_headings.add( "Date/Time" );

	loop
		int i = 1
	until
		i > cond_headings.count()
	begin
		out.print( cond_headings[i] + TAB );
		i = i + 1;
	end;

	out.print( "\n" + subj + TAB );
	out.print( string( total_dur / 1000 ) + TAB );
	out.print( string( cond_array.count() ) + TAB );
	out.print( string( skip_ctr ) + TAB );
	out.print( hit_ct );
	out.print( TAB );
	out.print( miss_ct );
	out.print( TAB );
	out.print( FA_ct );
	out.print( TAB );
	out.print( CR_ct );
	out.print( TAB );
	out.print( date_time() );

	# Close the file and exit
	out.close();
end;