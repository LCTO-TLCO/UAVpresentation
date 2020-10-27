# -------------------------- Header Parameters --------------------------

scenario = "Simple Visual Search N2pc";

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
	block_num, number,
	trial_num, number,
	tgt_side, string,
	tgt_color, string,
	tgt_gap, string,
	dist_gap, string,
	p_code, number,
	isi_dur, number;
event_code_delimiter = ";";


# ------------------------------- SDL Part ------------------------------
begin;

trial{
	trial_type = first_response;
	trial_duration = forever;
	
	picture{
		text { 
			caption = "rest";
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
			} fix_ellipse;
			x = 0;
			y = 0;
		} test_pic;
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

trial {
	stimulus_event {
		picture {
			text ready_text;
			x = 0;
			y = 0;
		} noise_pic;
	} noise_event;
} noise_trial;
	
# ----------------------------- PCL Program -----------------------------
begin_pcl;

include_once "../../Library/lib_visual_utilities.pcl";
include_once "../../Library/lib_utilities.pcl";

# --- CONSTANTS --- #

string STIM_EVENT_CODE = "Stim";

string PRACTICE_TYPE_PRACTICE = "Practice";
string PRACTICE_TYPE_MAIN = "Main";

string LOG_ACTIVE = "log_active";

int SIDE_IDX = 1;
int GAP_IDX = 2;

int X_IDX = 1;
int Y_IDX = 2;

int TOP_IDX = 1;
int BOT_IDX = 2;

int LEFT_IDX = 1;
int RIGHT_IDX = 2;

int CORR_BUTTON = 201;
int INCORR_BUTTON = 202;

string LEFT_COND = "Left";
string RIGHT_COND = "Right";

string TOP_COND = "Top";
string BOT_COND = "Bottom";

int GRID_COLUMNS = 3;
int GRID_ROWS = 5;

string TOP_BUTTON_LABEL = "[TOP_BUTTON]";
string BOT_BUTTON_LABEL = "[BOTTOM_BUTTON]";
string COLOR_ONE_LABEL = "[COLOR_ONE]";
string COLOR_TWO_LABEL = "[COLOR_TWO]";
string TGT_COLOR_LABEL = "[TARGET_COLOR]";

rgb_color TRAINING_BG = rgb_color( 128,128,128 );

string CHARACTER_WRAP = "Character";

# --- Set up fixed stimulus parameters ---

string language = parameter_manager.get_string( "Language" );
language_file lang = load_language_file( scenario_directory + language + ".xml" );
bool char_wrap = ( get_lang_item( lang, "Word Wrap Mode" ).lower() == CHARACTER_WRAP.lower() );
double font_size = parameter_manager.get_double( "Non-Stimulus Font Size" );

# Set some durations
trial_refresh_fix( tgt_trial, parameter_manager.get_int( "Stimulus Duration" ) );

# Set the requested button codes
begin
	array<int> b_codes[2];
	b_codes.fill( 1, 0, INCORR_BUTTON, 0 );
	response_manager.set_button_codes( b_codes );
	
	b_codes.fill( 1, 0, CORR_BUTTON, 0 );
	response_manager.set_target_button_codes( b_codes );
end;

# Setup the fixation point
if ( parameter_manager.get_bool( "Show Fixation Point During ISI" ) ) then
	ISI_pic.add_part( fix_ellipse, 0, 0 );
end;
if ( !parameter_manager.get_bool( "Show Fixation Point During Stimulus" ) ) then
	test_pic.clear();
end;

# Change response logging
if ( parameter_manager.get_string( "Response Logging" ) == LOG_ACTIVE ) then
	ISI_trial.set_all_responses( false );
	tgt_trial.set_all_responses( false );
	noise_trial.set_all_responses( false );
end;

# --- Stimulus setup --- #

# --- sub pixel_round
# --- This subroutine rounds a custom unit value to the nearest pixel

double custom_to_pixel = double( display_device.height() ) / display_device.custom_height();
double pixel_to_custom = 1.0 / custom_to_pixel;

sub
	double pixel_round( double value )
begin
	return double( int( ( value * custom_to_pixel ) + 0.5 ) ) * pixel_to_custom
end;

# Initialize some values
array<plane> tgt_planes[2];
plane dist_plane = new plane( 1.0, 1.0 );
double max_dim = 0.0;

# Target Colors
array<rgb_color> tgt_colors[0];
parameter_manager.get_colors( "Target Colors", tgt_colors );
if ( tgt_colors.count() != 2 ) then
	exit( "Error: Two colors must be specified in 'Target Colors'" );
end;

# Set up the stimuli
begin
	# Get the requested line width (stroke width)
	double c_line_width = double( parameter_manager.get_int( "Stimulus Line Width" ) ) * pixel_to_custom;

	# Now add a half-pixel so it draws the correct width
	double adj_line_width = c_line_width + ( 0.5 * pixel_to_custom );

	# Get the requested dim, and subtract out the line width
	double c_size = parameter_manager.get_double( "Stimulus Size" );
	c_size = pixel_round( c_size - ( 2.0 * c_line_width ) );
	if ( c_size <= 0.0 ) then
		exit( "Error: 'Stimulus Line Width' must be reduced, or 'Stimulus Size' increased." );
	end;

	# Check the gap size
	double c_inset_size = ( c_size - parameter_manager.get_double( "Gap Size" ) ) / 2.0;
	c_inset_size = pixel_round( c_inset_size );
	if ( parameter_manager.get_double( "Gap Size" ) > parameter_manager.get_double( "Stimulus Size" ) ) then 
		exit( "Error: 'Gap Size' must be less than or equal to 'Stimulus Size'" );
	end;

	# Check the sizes of the line width and the C. We need to make sure that if
	# the line width is even, the coordinates land on whole pixels. If the line width is
	# odd, the coordinates need to land between pixels. Otherwise, lines may draw
	# at the incorrect width
	bool odd_width = mod( int( c_line_width * custom_to_pixel + 0.5 ), 2 ) == 1;
	bool odd_size = int( c_size ) % 2 == 1;
	double mod = 0.0;
	if ( odd_size != odd_width ) then
		mod = 0.5;
	end;

	# Build the distractor C
	line_graphic my_c = new line_graphic();
	my_c.set_join_type( my_c.JOIN_POINT );
	my_c.set_line_width( c_line_width );
	my_c.set_line_color( parameter_manager.get_color( "Distractor Color" ) );
	
	# If there are "nubs" on the C then we draw them here
	if ( c_inset_size > 0.0 ) then
		my_c.add_line( c_size/2.0 + mod, c_size/2.0 - c_inset_size + mod, c_size/2.0 + mod, c_size/2.0 + mod );
		my_c.line_to( -c_size/2.0 + mod, c_size/2.0 + mod );
		my_c.line_to( -c_size/2.0 + mod, -c_size/2.0 + mod );
		my_c.line_to( c_size/2.0 + mod, -c_size/2.0 + mod );
		my_c.line_to( c_size/2.0 + mod, -c_size/2.0 + c_inset_size + mod );
	# If there aren't nubs, we skip drawing them but extend the sides by 1/2 the line width to make like
	# they are there.
	else
		my_c.add_line( c_size/2.0 + mod + ( c_line_width/2.0 ), c_size/2.0 + mod, -c_size/2.0 + mod, c_size/2.0 + mod );
		my_c.line_to( -c_size/2.0 + mod, -c_size/2.0 + mod );
		my_c.line_to( c_size/2.0 + mod + ( c_line_width/2.0 ), -c_size/2.0 + mod );
	end;
	my_c.redraw();
	
	# Now copy it to a plane
	dist_plane.set_size( my_c.width(), my_c.height() );
	dist_plane.set_texture( my_c.copy_to_texture() );
	dist_plane.set_emissive( rgb_color( 255,255,255 ) );

	# Print some values to the terminal to report the actual sizes
	double gap_size = abs ( ( -c_size/2.0 + c_inset_size ) - ( c_size/2.0 - c_inset_size ) );
	term.print_line( "Actual Gap Size: " + string( gap_size ) + " degrees" );
	term.print_line( "Actual Stim Height: " + string( my_c.height() ) + " degrees" );
	term.print_line( "Actual Stim Width: " + string( my_c.width() ) + " degrees" );

	# Store the C dimensions
	max_dim = my_c.width();
	if ( my_c.height() > my_c.width() ) then
		max_dim = my_c.height();
	end;

	# Build the target c
	my_c.clear();
	if ( c_inset_size > 0.0 ) then
		my_c.add_line( c_size/2.0 - c_inset_size + mod, c_size/2.0 + mod, c_size/2.0 + mod, c_size/2.0 + mod );
		my_c.line_to( c_size/2.0 + mod, -c_size/2.0 + mod );
		my_c.line_to( -c_size/2.0 + mod, -c_size/2.0 + mod );
		my_c.line_to( -c_size/2.0 + mod, c_size/2.0 + mod );
		my_c.line_to( -c_size/2.0 + c_inset_size + mod, c_size/2.0 + mod );
	else
		my_c.add_line( c_size/2.0 + mod, c_size/2.0 + mod, c_size/2.0 + mod, -c_size/2.0 + mod );
		my_c.line_to( -c_size/2.0 + mod, -c_size/2.0 + mod );
		my_c.line_to( -c_size/2.0 + mod, c_size/2.0 + mod );
	end;
	my_c.set_line_color( tgt_colors[1] );
	my_c.redraw();
	
	term.print_line( "Rotated Gap Size: " + string( gap_size ) + " degrees" );
	term.print_line( "Rotated Stim Height: " + string( my_c.height() ) + " degrees" );
	term.print_line( "Rotated Stim Width: " + string( my_c.width() ) + " degrees" );	
	
	# Save it to a plane
	tgt_planes[1] = new plane( my_c.width(), my_c.height() );
	tgt_planes[1].set_texture( my_c.copy_to_texture() );
	tgt_planes[1].set_emissive( rgb_color( 255,255,255 ) );

	# Save the second condition plane
	my_c.set_line_color( tgt_colors[2] );
	my_c.redraw();
	tgt_planes[2] = new plane( my_c.width(), my_c.height() );
	tgt_planes[2].set_texture( my_c.copy_to_texture() );
	tgt_planes[2].set_emissive( rgb_color( 255,255,255 ) );
	
	test_pic.clear();
	test_pic.add_3dpart( dist_plane, -0.5, 0.0, 0.0 );
	test_pic.add_3dpart( tgt_planes[1], 0.5, 0.0, 0.0 );
end;

# Now set up the search grid
array<double> grid_locs[2][0][0];
array<double> jitters[2];
int num_stim = parameter_manager.get_int( "Stimuli per Side" );

begin
	# Get the size of the search array
	array<double> array_dims[2];
	array_dims[X_IDX] = parameter_manager.get_double( "Bounding Box Width" );
	array_dims[Y_IDX] = parameter_manager.get_double( "Bounding Box Height" );
	double inner_buffer = parameter_manager.get_double( "Bounding Box Horizontal Position" );
	
	# Exit if the requested dimensions are too big
	if ( array_dims[Y_IDX] > display_device.custom_height() ) then
		exit( "Error: 'Bounding Box Height' must be reduced." );
	end;
	if ( ( array_dims[X_IDX] + inner_buffer ) > ( display_device.custom_width()/2.0 ) ) then
		exit( "Error: 'Bounding Box Width' must be reduced." );
	end;

	# Get the total height/width of each possible stimulus slot
	array<double> slot_dims[2];
	slot_dims[X_IDX] = array_dims[X_IDX]/ double(GRID_COLUMNS);
	slot_dims[Y_IDX] = array_dims[Y_IDX]/ double(GRID_ROWS);
	
	# Get the buffer distances
	double x_buff = parameter_manager.get_double( "Minimum Horizontal Distance Between Stimuli" );
	double y_buff = parameter_manager.get_double( "Minimum Vertical Distance Between Stimuli" );

	# Get how much stuff can jitter
	jitters[X_IDX] = ( slot_dims[X_IDX] - max_dim - x_buff )/2.0;
	jitters[Y_IDX] = ( slot_dims[Y_IDX] - max_dim - y_buff )/2.0;
	
	if ( jitters[X_IDX] < 0.0 ) || ( jitters[Y_IDX] < 0.0 ) then
		exit( "Error: Not enough space for all stimuli. Reduce 'Stimulus Size' or the minimum distance between stimuli, or increase the bounding box size" );
	end;

	# store the x/y locs of the search array(s)
	loop
		double x_pos = inner_buffer + slot_dims[X_IDX]/2.0;
		int i = 1
	until
		i > GRID_COLUMNS
	begin
		loop
			double y_pos = ( array_dims[Y_IDX]/2.0 ) - ( slot_dims[Y_IDX]/2.0 );
			int j = 1
		until
			j > GRID_ROWS
		begin
			array<double> temp[2];
			temp[X_IDX] = x_pos;
			temp[Y_IDX] = y_pos;
			grid_locs[RIGHT_IDX].add( temp );
			
			temp[X_IDX] = -x_pos;
			grid_locs[LEFT_IDX].add( temp );
			
			y_pos = y_pos - slot_dims[Y_IDX];
			j = j + 1;
		end;
		x_pos = x_pos + slot_dims[X_IDX];
		i = i + 1;
	end;
end;

# --- Subroutines --- #

# --- sub present_instructions 

array<string> color_names[0];
parameter_manager.get_strings( "Target Color Names", color_names );
if ( color_names.count() != 2 ) then
	exit( "Error: Two condition names must be specified in 'Condition Color Names'" );
end;

array<string> formatted_color_names[2];
formatted_color_names[1] = "<font color='" + string( tgt_colors[1].red_byte() ) + ", ";
formatted_color_names[1].append( string( tgt_colors[1].green_byte() ) + ", " );
formatted_color_names[1].append( string( tgt_colors[1].blue_byte() ) + "'>" );
formatted_color_names[1].append( color_names[1] + "</font>" );
formatted_color_names[2] = "<font color='" + string( tgt_colors[2].red_byte() ) + ", ";
formatted_color_names[2].append( string( tgt_colors[2].green_byte() ) + ", " );
formatted_color_names[2].append( string( tgt_colors[2].blue_byte() ) + "'>" );
formatted_color_names[2].append( color_names[2] + "</font>" );

int top_button = parameter_manager.get_int( "Response Button Mapping" );
array<string> button_names[2];
button_names[1] = parameter_manager.get_string( "Response Button 1 Name" );
button_names[2] = parameter_manager.get_string( "Response Button 2 Name" );

sub
	present_instructions( string instruct_string )
begin
	instruct_string = instruct_string.replace( TOP_BUTTON_LABEL, button_names[top_button] );
	instruct_string = instruct_string.replace( BOT_BUTTON_LABEL, button_names[ ( top_button % 2 ) + 1 ] );
	instruct_string = instruct_string.replace( COLOR_ONE_LABEL, formatted_color_names[1] );
	instruct_string = instruct_string.replace( COLOR_TWO_LABEL, formatted_color_names[2] );
	instruct_text.set_formatted_text( true );
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
		rest_text.set_caption( untimed_rest_caption, true );
		rest_trial.set_duration( rest_trial.FOREVER );
		rest_trial.set_type( rest_trial.FIRST_RESPONSE );
	else
		rest_text.set_caption( timed_rest_caption, true );
		rest_trial.set_duration( temp_dur );
		rest_trial.set_type( rest_trial.FIXED );
	end;

	# Show the trial
	full_size_word_wrap( rest_text.caption(), font_size, char_wrap, rest_text );
	rest_trial.present();
end;

# --- sub show_reminder

string tgt_id_caption = get_lang_item( lang, "Target Reminder Caption" );

sub
	show_reminder( int tgt_id )
begin
	string temp_reminder = tgt_id_caption.replace( TGT_COLOR_LABEL, formatted_color_names[tgt_id] );
	present_instructions( temp_reminder );
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

# --- sub build_test_pic

array<double> stim_rots[2];
stim_rots[TOP_IDX] = 0.0;
stim_rots[BOT_IDX] = 180.0;

sub
	build_test_pic( int tgt_rot, int tgt_side, int tgt_number, int dist_rot )
begin
	# Clear the test pic then add the fixation
	test_pic.clear();
	test_pic.add_part( fix_ellipse, 0, 0 );
	
	# Shuffle the locs
	grid_locs[LEFT_IDX].shuffle();
	grid_locs[RIGHT_IDX].shuffle();
	
	# Loop to add the picture parts
	loop
		int j = 1
	until
		j > grid_locs.count()
	begin
		loop
			int k = 1
		until
			k > num_stim
		begin
			# Grab a random x/y jitter for this position
			double x_jitter = double( random_exclude( -1,1,0 ) ) * jitters[X_IDX] * random();
			double y_jitter = double( random_exclude( -1,1,0 ) ) * jitters[Y_IDX] * random();
			
			# Get the final x/y value
			double this_x = grid_locs[j][k][X_IDX] + x_jitter;
			double this_y = grid_locs[j][k][Y_IDX] + y_jitter;
			
			# Add the 3dpart at a random rotation
			test_pic.add_3dpart( dist_plane, this_x, this_y, 0.0 );
			test_pic.set_3dpart_rot( test_pic.d3d_part_count(), 0.0, 0.0, stim_rots[random(1,stim_rots.count() )] );
			
			# If this is the last stim, we need to add a target/distractor
			if ( k == num_stim ) then
				if ( j == tgt_side ) then
					test_pic.set_3dpart( test_pic.d3d_part_count(), tgt_planes[tgt_number] );
					test_pic.set_3dpart_rot( test_pic.d3d_part_count(), 0.0, 0.0, stim_rots[tgt_rot] );
				else
					test_pic.set_3dpart( test_pic.d3d_part_count(), tgt_planes[( tgt_number % 2 ) + 1] );
					test_pic.set_3dpart_rot( test_pic.d3d_part_count(), 0.0, 0.0, stim_rots[dist_rot] );
				end;
			end;
			
			k = k + 1;
		end;
		j = j + 1;
	end;
end;

# --- sub show_block 

# Initialize some values
array<int> buttons[2];
buttons[TOP_IDX] = parameter_manager.get_int( "Response Button Mapping" );
buttons[BOT_IDX] = ( buttons[TOP_IDX] % 2 ) + 1; 

array<string> side_cond_names[2];
side_cond_names[LEFT_IDX] = LEFT_COND;
side_cond_names[RIGHT_IDX] = RIGHT_COND;

array<string> gap_cond_names[2];
gap_cond_names[TOP_IDX] = TOP_COND;
gap_cond_names[BOT_IDX] = BOT_COND;

array<int> ISI_range[0];
parameter_manager.get_ints( "ISI Range", ISI_range );
if ( ISI_range.count() != 2 ) then
	exit( "Error: Two values must be specified in 'ISI Range'" );
end;

int trials_per_rest = parameter_manager.get_int( "Trials Between Rest Breaks" );

sub
	show_block( array<int,2>& order, int block_num, int tgt_id, string prac_check )
begin
	# Shuffle the order
	order[SIDE_IDX].shuffle();
	order[GAP_IDX].shuffle();
	
	# Ready set go
	ready_set_go();
	ISI_trial.set_duration( random( ISI_range[1], ISI_range[2] ) );
	ISI_trial.present();
	
	# Loop to present stimuli
	loop
		int i = 1
	until
		i > order[1].count()
	begin
		# Get some trial information
		int tgt_side = order[SIDE_IDX][i];
		int dist_gap = random( 1, stim_rots.count() );
		int tgt_gap = order[GAP_IDX][i];
		build_test_pic( tgt_gap, tgt_side, tgt_id, dist_gap );
		
		# Get port code
		int p_code = int( string( tgt_id ) + string( tgt_side ) + string( tgt_gap ) );
		tgt_event.set_port_code( p_code );
		
		# Set target button
		tgt_event.set_target_button( buttons[tgt_gap] );
		
		# Setup ISI
		trial_refresh_fix( ISI_trial, random( ISI_range[1], ISI_range[2] ) );
		
		# Set event code
		tgt_event.set_event_code( 
			STIM_EVENT_CODE + ";" +
			prac_check + ";" + 
			string( block_num ) + ";" +
			string( i ) + ";" +
			side_cond_names[tgt_side] + ";" +
			color_names[tgt_id] + ";" +
			gap_cond_names[tgt_gap] + ";" +
			gap_cond_names[dist_gap] + ";" +
			string( p_code ) + ";" + 
			string( ISI_trial.duration() )
		);
		
		# Trial sequence
		tgt_trial.present();
		ISI_trial.present();
		
		# Do rest sequence
		if ( trials_per_rest > 0 ) && ( prac_check == PRACTICE_TYPE_MAIN ) then
			if ( i % trials_per_rest == 0 ) && ( i < order[1].count() ) then
				show_rest( true );
				show_reminder( tgt_id );
				ready_set_go();
				ISI_trial.present();
			end;
		end;
		
		i = i + 1;
	end;
end;

# --- Trial Order & Conditions --- #

int trials_per_block = parameter_manager.get_int( "Trials per Block" );
array<int> trial_order[2][trials_per_block];
trial_order[SIDE_IDX].fill( 1, 0, LEFT_IDX, 0 );
trial_order[SIDE_IDX].fill( 1, trials_per_block/2, RIGHT_IDX, 0 );

double top_gap_prop = parameter_manager.get_double( "Top Gap Proportion" );
int top_gap_trials = int( round( double( trials_per_block ) * top_gap_prop, 0 ) );
trial_order[GAP_IDX].fill( 1, 0, BOT_IDX, 0 );
trial_order[GAP_IDX].fill( 1, top_gap_trials, TOP_IDX, 0 );

int prac_trials = parameter_manager.get_int( "Practice Trials" );
array<int> prac_trial_order[2][prac_trials];
if ( prac_trials > 0 ) then
	prac_trial_order[SIDE_IDX].fill( 1, 0, LEFT_IDX, 0 );
	prac_trial_order[SIDE_IDX].fill( 1, prac_trials/2, RIGHT_IDX, 0 );
	
	int prac_top_trials = int( round( double( prac_trials ) * top_gap_prop, 0 ) );
	prac_trial_order[GAP_IDX].fill( 1, 0, BOT_IDX, 0 );
	prac_trial_order[GAP_IDX].fill( 1, prac_top_trials, TOP_IDX, 0 );
end;

array<int> block_order[0];
parameter_manager.get_ints( "Target Color Order", block_order );
if ( block_order.count() == 0 ) then
	exit( "Error: At least one value must be specified in 'Block Order'" );
elseif ( parameter_manager.get_bool( "Randomize Block Order" ) ) then
	block_order.shuffle();
end;

# --- Main Sequence --- #

string practice_caption = get_lang_item( lang, "Practice Caption" );
string prac_complete_caption = get_lang_item( lang, "Practice Complete Caption" );
string instructions = get_lang_item( lang, "Main Instructions" );

loop
	int i = 1
until
	i > block_order.count()
begin
	# Block setup
	int this_tgt = block_order[i];
	
	# Do the practice and/or show the instructions
	if ( i == 1 ) then
		present_instructions( instructions );
		if ( prac_trials > 0 ) then
			string temp_reminder = tgt_id_caption.replace( TGT_COLOR_LABEL, formatted_color_names[this_tgt] );
			present_instructions( temp_reminder + " " + practice_caption );
			show_block( prac_trial_order, i, this_tgt, PRACTICE_TYPE_PRACTICE );
			present_instructions( prac_complete_caption );
		end;
	end;
	show_reminder( this_tgt );
	
	# Show the block
	show_block( trial_order, i, this_tgt, PRACTICE_TYPE_MAIN );
	if ( i < block_order.count() ) then
		show_rest( false );
	end;
	
	# Increment
	i = i + 1;
end;
present_instructions( get_lang_item( lang, "Completion Screen Caption" ) );