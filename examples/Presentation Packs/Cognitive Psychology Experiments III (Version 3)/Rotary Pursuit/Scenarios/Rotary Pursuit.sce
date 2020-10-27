# -------------------------- Header Parameters --------------------------

scenario = "Rotary Pursuit";

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
	track_width, number,
	track_height, number,
	circuit_time, number,
	axis_setup, string,
	tgt_pct, number,
	avg_dist, number;
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
	stimulus_event {
		picture {} stim_pic;
		code = "Stim";
	} stim_event;
} stim_trial;

trial {
	stimulus_event {
		picture stim_pic;
		code = "Wait";
	} wait_event;
} wait_trial;

trial {
	stimulus_event {
		picture {
			text { 
				caption = "Feedback";
				preload = false;
			} fb_text;
			x = 0;
			y = 0;
		};
		code = "Feedback";
	};
} fb_trial;

trial {
	picture {};
} ITI_trial;

TEMPLATE "../../Library/lib_rest.tem";

# ----------------------------- PCL Program -----------------------------
begin_pcl;

include_once "../../Library/lib_visual_utilities.pcl";
include_once "../../Library/lib_utilities.pcl";

# --- Constants ---

string STIM_EVENT_CODE = "Stim";

string SPLIT_LABEL = "[SPLIT]";
string LINE_BREAK = "\n";
int BUTTON_FWD = 1;
int BUTTON_BWD = 0;

string PRACTICE_TYPE_PRACTICE = "Practice";
string PRACTICE_TYPE_MAIN = "Main";

string LANGUAGE_FILE_TOTAL_BLOCKS_LABEL = "[TOTAL_BLOCKS]";
string LANGUAGE_FILE_BLOCK_NUMBER_LABEL = "[BLOCK_NUMBER]";

string LANGUAGE_FILE_TARGET_LABEL = "[TARGET_DESCRIPTION]";

string COND_INV_X = "Invert X";
string COND_INV_Y = "Invert Y";
string COND_INV_BOTH = "Invert Both";
string COND_STD = "Standard";

int COND_INV_X_IDX = 1;
int COND_INV_Y_IDX = 2;
int COND_INV_BOTH_IDX = 3;
int COND_STD_IDX = 4;

int WIDTH_IDX = 1;
int HEIGHT_IDX = 2;
int TIME_IDX = 3;
int AXIS_IDX = 4;

string DESIGN_BLOCK = "Block";
string DESIGN_TRIAL = "Trial";

string CHARACTER_WRAP = "Character";

int TGT_MOVE_P_CODE = 10;

# --- Set up fixed stimulus parameters ---

string language = parameter_manager.get_string( "Language" );
language_file lang = load_language_file( scenario_directory + language + ".xml" );
bool char_wrap = ( get_lang_item( lang, "Word Wrap Mode" ).lower() == CHARACTER_WRAP.lower() );

adjust_used_screen_size( parameter_manager.get_bool( "Use Widescreen if Available" ) );

double font_size = parameter_manager.get_double( "Default Font Size" );

trial_refresh_fix( wait_trial, parameter_manager.get_int( "Wait Duration" ) );
trial_refresh_fix( fb_trial, parameter_manager.get_int( "Feedback Duration" ) );

stim_event.set_port_code( TGT_MOVE_P_CODE );

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


# --- Mouse Setup --- #

double scale_factor = parameter_manager.get_double( "Mouse Scaling" );
mouse mse = response_manager.get_mouse( 1 );
begin
	int max_x = int( scale_factor * ( used_screen_width / 2.0 ) );
	int max_y = int( scale_factor * ( used_screen_height / 2.0 ) );
	mse.set_min_max( 1, -max_x, max_x );
	mse.set_min_max( 2, -max_y, max_y );
	mse.set_restricted( 1, true );
	mse.set_restricted( 2, true );
end;

# --- Stimulus Setup --- #

annulus_graphic track = new annulus_graphic();
ellipse_graphic tgt = new ellipse_graphic();
ellipse_graphic cursor = new ellipse_graphic();
double tgt_size = parameter_manager.get_double( "Target Diameter" );

begin
	# Draw the cursor
	double cursor_size = parameter_manager.get_double( "Cursor Size" );
	rgb_color cursor_color = parameter_manager.get_color( "Cursor Color" );
	cursor.set_dimensions( cursor_size, cursor_size );
	cursor.set_color( cursor_color );
	cursor.redraw();
	
	# Draw the target
	rgb_color t_color = parameter_manager.get_color( "Target Color" );
	tgt.set_dimensions( tgt_size, tgt_size );
	tgt.set_color( t_color );
	tgt.redraw();
	
	# Set the track color (size gets set trial-by-trial)
	track.set_color( parameter_manager.get_color( "Track Color" ) );
end;

# Add in the picture parts
stim_pic.add_part( track, 0, 0 );
stim_pic.add_part( tgt, 0.0, 0.0 );
stim_pic.add_part( cursor, 0.0, 0.0 );

int tgt_part = stim_pic.part_count() - 1;
int cursor_part = stim_pic.part_count();

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

# --- sub show_ITI ---

array<int> ITI_durations[0];
parameter_manager.get_ints( "ITI Durations", ITI_durations );
if ( ITI_durations.count() == 0 ) then
	exit( "Error: 'ITI Durations' must contain at least one value" );
end;

sub
	show_ITI
begin
	int rand_dur = ITI_durations[random(1,ITI_durations.count())];
	trial_refresh_fix( ITI_trial, rand_dur );
	ITI_trial.present();
end;

# --- sub show_feedback ---

string fb_caption = get_lang_item( lang, "Feedback Caption" );

sub
	show_feedback( double pct_on_tgt )
begin
	string cap = fb_caption + " " + string( round( pct_on_tgt * 100.0, 1 ) ) + "%";
	fb_text.set_caption( cap, true );
	fb_trial.present();
end;

# --- sub show_block ---

bool show_fb = parameter_manager.get_bool( "Show Feedback" );
double width_adj = parameter_manager.get_double( "Track Line Width" )/2.0;
int num_blocks = parameter_manager.get_int( "Blocks" );

array<string> axis_types[4];
axis_types[COND_INV_X_IDX] = COND_INV_X;
axis_types[COND_INV_Y_IDX] = COND_INV_Y;
axis_types[COND_INV_BOTH_IDX] = COND_INV_BOTH;
axis_types[COND_STD_IDX] = COND_STD;

# -- Set up info for summary stats -- #
int SUM_BLOCK_IDX = 1;
int SUM_COND_IDX = 2;

# Put all the condition names into an array
# Used later to add column headings
array<string> cond_names[2][0];
cond_names[SUM_COND_IDX].assign( axis_types );

loop
	int i = 1
until
	i > num_blocks
begin
	cond_names[SUM_BLOCK_IDX].add( string(i) );
	i = i + 1;
end;

# Now build an empty array for all DVs of interest
array<double> acc_stats[cond_names[1].count()][cond_names[2].count()][0];
array<double> dist_stats[cond_names[1].count()][cond_names[2].count()][0];
# -- End Summary Stats -- #

sub
	show_block( int block_number, string prac_check, array<double,2>& block_order )
begin
	# Start with an ITI
	show_ITI();
	
	# Main loop to run trials
	loop
		int i = 1
	until
		i > block_order.count()
	begin
		# Draw the track
		double e_width = block_order[i][WIDTH_IDX];
		double e_height = block_order[i][HEIGHT_IDX];
		track.set_dimensions( e_width - width_adj, e_height - width_adj, e_width + width_adj, e_height + width_adj );
		track.redraw();

		# Setup the mouse axes. The array contains the multiplier 
		# for each axis; 1 = standard, -1 = reversed
		string axis_setup = axis_types[int(block_order[i][AXIS_IDX])];
		
		array<int> axis_vals[2] = { 1, 1 };
		if ( axis_setup == COND_INV_X ) || ( axis_setup == COND_INV_BOTH ) then
			axis_vals[1] = -1;
		end;
		if ( axis_setup == COND_INV_Y ) || ( axis_setup == COND_INV_BOTH ) then
			axis_vals[2] = -1;
		end;

		# Starting positions
		double start_pos_x = ( e_width/2.0 );
		double start_pos_y = ( e_height/2.0 );

		# Calculate the velocity of the target (based on lap time and refresh period)
		# Velocity is in radians/refresh
		double circuit_time = block_order[i][TIME_IDX];
		int refreshes = int( round( circuit_time / display_device.refresh_period(), 0 ) );
		double vel = ( ( 2.0 * pi_value ) / double( refreshes ) ); # Radians per refresh

		# Now add the tgt and cursor
		stim_pic.set_part_x( tgt_part, start_pos_x );
		stim_pic.set_part_y( tgt_part, 0 );
		stim_pic.set_part_x( cursor_part, start_pos_x );
		stim_pic.set_part_y( cursor_part, 0 );
		
		# Show the target and wait for movement
		wait_trial.present();
		stim_trial.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		mse.set_xy( axis_vals[1] * int( scale_factor * start_pos_x ), 0 );	

		# Initialize some values
		int tgt_ct = 0;
		array<double> dist_array[0];
		loop
			int start_x = mse.x();
			int start_y = mse.y();
			double t = 0.0
		until
			t > 2.0 * pi_value
		begin
			# Get the x/y position of the target
			double x = ( start_pos_x ) * cos( t ); # x = width * cos ( alpha )
			double y = ( start_pos_y ) * sin( t ); # y = height * sin ( alpha )
			stim_pic.set_part_x( tgt_part, x );
			stim_pic.set_part_y( tgt_part, y );
			
			# Now poll the mouse
			mse.poll();
			double mouse_x = double( mse.x() * axis_vals[1] ) / scale_factor;
			double mouse_y = double( mse.y() * axis_vals[2] ) / scale_factor;
			
			# Check if the mouse is on target
			double dist_to_tgt = dist( x, y, mouse_x, mouse_y );
			dist_array.add( dist_to_tgt );
			if ( dist_to_tgt <= tgt_size/2.0 ) then
				tgt_ct = tgt_ct + 1;
			end;
			
			# Update the cursor position if they've moved
			if ( mse.x() != start_x ) || ( mse.y() != start_y ) then
				stim_pic.set_part_x( cursor_part, double( mse.x() * axis_vals[1] )/scale_factor );
				stim_pic.set_part_y( cursor_part, double( mse.y() * axis_vals[2] )/scale_factor );
			end;
			
			# Present the picture
			stim_pic.present();
			
			t = t + vel;
		end;
		
		# Grab some values
		double tgt_pct = double( tgt_ct ) / double( dist_array.count() );
		double avg_dist = arithmetic_mean( dist_array );
		
		# Store the event info here
		last.set_event_code( 
			STIM_EVENT_CODE + ";" +
			prac_check + ";" +
			string( block_number ) + ";" +
			string( i ) + ";" +
			string( e_width ) + ";" +
			string( e_height ) + ";" +
			string( circuit_time ) + ";" +
			axis_setup + ";" +
			string( tgt_pct * 100.0 ) + ";" +
			string( avg_dist )
		);
		
		# Show feedback & ITI
		if ( show_fb ) then
			show_feedback( tgt_pct );
		end;
		show_ITI();
		
		# Record trial info for summary stats
		if ( prac_check == PRACTICE_TYPE_MAIN ) then
			# Make an int array specifying the condition we're in
			# This tells us which subarray to store the trial info
			array<int> this_trial[cond_names.count()];
			this_trial[SUM_BLOCK_IDX] = block_number;
			this_trial[SUM_COND_IDX] = int( block_order[i][AXIS_IDX] );
			
			acc_stats[this_trial[1]][this_trial[2]].add( tgt_pct * 100.0 );
			dist_stats[this_trial[1]][this_trial[2]].add( avg_dist );
		end;
		
		# Show rest
		if ( prac_check == PRACTICE_TYPE_MAIN ) then
			if ( show_rest( i, block_order.count() ) ) then
				show_ITI();
			end;
		end;
		
		i = i + 1;
	end;
end;

# --- Conditions & Trial order

array<double> cond_array[num_blocks][0][0];
array<double> prac_cond_array[0][0];

begin
	string exp_design = parameter_manager.get_string( "Experiment Design" );
	
	# Get the conditions
	array<double> track_widths[0];
	parameter_manager.get_doubles( "Track Widths", track_widths );

	array<double> track_heights[0];
	parameter_manager.get_doubles( "Track Heights", track_heights );
	
	array<int> circuit_times[0];
	parameter_manager.get_ints( "Circuit Times", circuit_times );
	
	array<string> axis_setups[0];
	parameter_manager.get_strings( "Mouse Control Conditions", axis_setups );

	if ( exp_design == DESIGN_BLOCK ) then
		if ( track_widths.count() != num_blocks ) || ( track_heights.count() != num_blocks ) then
			exit( "Error: 'Track Widths' and 'Track Heights' must both contain 'Blocks' values." );
		end;
		
		if ( circuit_times.count() != num_blocks ) then
			exit( "Error: 'Circuit Times' must contain 'Blocks' values." );
		end;
	
		if ( axis_setups.count() != num_blocks ) then
			exit( "Error: 'Mouse Control Conditions' must contain 'Blocks' values." );
		end;
	else
		if ( track_widths.count() != track_heights.count() ) ||
			( track_widths.count() != circuit_times.count() ) ||
			( track_widths.count() != axis_setups.count() ) ||
			( track_heights.count() != circuit_times.count() ) ||
			( track_heights.count() != axis_setups.count() ) ||
			( circuit_times.count() != axis_setups.count() ) then
			exit( "Error: 'Track Widths', 'Track Heights', 'Circuit Times', and 'Mouse Control Conditions' must contain the same number of values." );
		end;
		num_blocks = track_widths.count();
		cond_array.resize( 1 );
	end;
	
	# Set up the block order. The value of "Randomize Block Order" is irrelevant
	# when using a trial design
	array<int> temp_order[num_blocks];
	temp_order.fill( 1, 0, 1, 1 );
	if ( exp_design == DESIGN_BLOCK ) && ( parameter_manager.get_bool( "Randomize Block Order" ) ) then
		temp_order.shuffle();
	end;

	# Make an array to hold the block conditions temporarily. 
	# These conditions will later be used to build the full trial order.
	array<double> temp_cond_array[0][0];
	loop
		array<double> temp[4];
		int i = 1
	until
		i > num_blocks
	begin
		int this_block = temp_order[i];
		
		string this_axis = axis_setups[this_block];
		int ax_idx = 1;
		loop
		until
			axis_types[ax_idx] == this_axis
		begin
			ax_idx = ax_idx + 1;
		end;

		temp[HEIGHT_IDX] = track_heights[this_block];
		temp[WIDTH_IDX] = track_widths[this_block];
		temp[TIME_IDX] = double( circuit_times[this_block] );
		temp[AXIS_IDX] = double( ax_idx );
		
		temp_cond_array.add( temp );
		i = i + 1;
	end;
	
	# Build the array specifying trials for each condition
	# The structure of this array depends on whether using a block or trial design
	# For block designs, the same condition is repeated over and over in a single block
	# For trial designs, all possible conditions are intermixed into one big block
	int trials_per_cond = parameter_manager.get_int( "Trials per Condition" );
	loop
		int i = 1
	until
		i > num_blocks
	begin
		loop
			int j = 1
		until
			j > trials_per_cond
		begin
			if ( exp_design == DESIGN_BLOCK ) then
				cond_array[i].add( temp_cond_array[i] );
			else
				cond_array[1].add( temp_cond_array[i] );
			end;
			j = j + 1;
		end;
		i = i + 1;
	end;
	
	# Randomize the trial order for a trial design
	if ( exp_design == DESIGN_TRIAL ) then
		cond_array[1].shuffle();
	end;
	
	# Collect a set of random trials to perform practice trials
	int prac_trials = parameter_manager.get_int( "Practice Trials" );
	loop
	until
		prac_cond_array.count() >= prac_trials
	begin
		int rand_block = random( 1, cond_array.count() );
		int rand_trial = random( 1, cond_array[rand_block].count() );
		prac_cond_array.add( cond_array[rand_block][rand_trial] );
	end;
end;

# --- Main Sequence --- 

bool show_block_status = parameter_manager.get_bool( "Show Status Between Blocks" );
string instructions = get_lang_item( lang, "Instructions" );
instructions = instructions.replace( LANGUAGE_FILE_TARGET_LABEL, parameter_manager.get_string( "Target Description" ) );

# Show the practice trials and/or instructions
if ( prac_cond_array.count() > 0 ) then
	main_instructions( instructions + " " + get_lang_item( lang, "Practice Caption" ) );
	show_block( 0, PRACTICE_TYPE_PRACTICE, prac_cond_array );
	present_instructions( get_lang_item( lang, "Practice Complete Caption" ) );
else
	main_instructions( instructions );
end;

# Loop to present blocks
loop
	int a = 1
until
	a > cond_array.count()
begin
	show_block( a, PRACTICE_TYPE_MAIN, cond_array[a] );
	
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
	cond_headings[SUM_COND_IDX + 1] = "Axis Type";
	cond_headings.add( "Avg % on Target" );
	cond_headings.add( "Avg % (SD)" );
	cond_headings.add( "Avg Distance from Target" );
	cond_headings.add( "Avg Distance (SD)" );
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
			if ( dist_stats[i][j].count() > 0 ) then
				out.print( "\n" + subj + TAB );
				out.print( cond_names[1][i] + TAB );
				out.print( cond_names[2][j] + TAB );
				out.print( round( arithmetic_mean( acc_stats[i][j] ), 3 ) );
				out.print( TAB );
				out.print( round( sample_std_dev( acc_stats[i][j] ), 3 ) );
				out.print( TAB );
				out.print( round( arithmetic_mean( dist_stats[i][j] ), 3 ) );
				out.print( TAB );
				out.print( round( sample_std_dev( dist_stats[i][j] ), 3 ) );
				out.print( TAB );
				out.print( dist_stats[i][j].count() );
				out.print( TAB );
				out.print( date_time() );
			end;
			j = j + 1;
		end;
		i = i + 1;
	end;

	# Close the file and exit
	out.close();
end;