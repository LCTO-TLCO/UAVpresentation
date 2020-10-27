# -------------------------- Header Parameters --------------------------

scenario = "Corsi Block Tapping";

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
	block_number, number,
	test_type, string,
	trial_number, number,
	current_length, number,
	sequence, string,
	resp, string,
	accuracy, string,
	rt, number;
event_code_delimiter = ";";

# ------------------------------- SDL Part ------------------------------
begin;

text {
	caption = "Ready";
	font_color = EXPARAM( "Ready Text Color" );
	background_color = EXPARAM( "Ready Text Background Color" );
	preload = false;
} ready_text;

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
	} instruct_pic;
} instruct_trial;

trial {
	stimulus_event { 
		picture {
			ellipse_graphic {
				color = EXPARAM( "Cursor Color" );
				ellipse_height = EXPARAM( "Cursor Size" );
				ellipse_width = EXPARAM( "Cursor Size" );
			} cursor;
			x = 0;
			y = 0;
			on_top = true;
		} stim_pic;
		code = "Box";
	} main_event;
} main_trial;

trial {
	picture stim_pic;
} ready_trial;

trial {
	picture stim_pic;
} wait_trial;

trial {
	stimulus_event {
		nothing {};
	} info_event;
} info_trial;

# ----------------------------- PCL Program -----------------------------
begin_pcl;

include_once "../../Library/lib_visual_utilities.pcl";
include_once "../../Library/lib_utilities.pcl";

# --- CONSTANTS ---

string SPLIT_LABEL = "[SPLIT]";
string LINE_BREAK = "\n";
int BUTTON_FWD = 2;
int BUTTON_BWD = 1;

string PRACTICE_TYPE_PRACTICE = "Practice";
string PRACTICE_TYPE_MAIN = "Main";

string MAIN_EVENT_CODE = "Stim";

string TYPE_STAIRCASE = "Staircase";
string TYPE_FIXED = "Fixed";

string COND_FORWARD = "Forward";
string COND_BACKWARD = "Backward";

int COND_FORWARD_IDX = 1;
int COND_BACKWARD_IDX = 2;

int MIN_LENGTH = 2;

int TYPE_IDX = 1;
int START_IDX = 2;

int SEL_BUTTON = 1;
int END_BUTTON = 2;

string ACC_CORRECT = "Correct";
string ACC_INCORRECT = "Incorrect";

int PROMPT_P_CODE = 10;
int SEL_BUTTON_P_CODE = 20;
int END_BUTTON_P_CODE = 21;

double MOUSE_SENS = 5.0;

int SEL_TIME = 200; # Duration of "flash" when a block is clicked--i.e., feedback that click worked

double GRID_WIDTH = 200.0;
double GRID_HEIGHT = 180.0;

string CHARACTER_WRAP = "Character";

# --- Set up fixed stimulus parameters ---

language_file lang = load_language_file( scenario_directory + parameter_manager.get_string( "Language" ) + ".xml" );
bool char_wrap = ( get_lang_item( lang, "Word Wrap Mode" ).lower() == CHARACTER_WRAP.lower() );

adjust_used_screen_size( parameter_manager.get_bool( "Use Widescreen if Available" ) );

double font_size = parameter_manager.get_double( "Default Font Size" );

trial_refresh_fix( wait_trial, parameter_manager.get_int( "Time Between Trials" ) );

# The button codes get set differently in this experiment so that
# the values 1-9 are set aside for block 'taps'
begin
	array<int> b_codes[2];
	b_codes[SEL_BUTTON] = SEL_BUTTON_P_CODE;
	b_codes[END_BUTTON] = END_BUTTON_P_CODE;
	response_manager.set_button_codes( b_codes );
end;

# --- Stimulus Setup

int num_blocks = parameter_manager.get_int( "Block Positions" );
double block_size = parameter_manager.get_double( "Block Size" );
array<double> box_locs[0][0];
array<double> mouse_start[2];
array<box> corsi_blocks[0];
rgb_color box_color = parameter_manager.get_color( "Block Color" );
rgb_color sel_color = parameter_manager.get_color( "Block Highlight Color" );
rgb_color tap_color = parameter_manager.get_color( "Block Tap Color" );

begin
	# Start by figuring out how wide each row and column is
	# We always use a 3x3 grid, given a max of 9 blocks
	int grid_size = 3;
	double col_size = GRID_WIDTH / double( grid_size );
	double row_size = GRID_HEIGHT / double( grid_size );
	
	# Exit if the requested dims are too big
	double spacing = parameter_manager.get_double( "Block Spacing" );
	if ( col_size < block_size + spacing ) || ( row_size < block_size + spacing ) then
		exit( "Error: Not enough space for all blocks. Reduce block size and/or spacing." );
	end;
	
	# Figure out how much space is between each block in the grid
	double x_buffer = ( col_size - block_size - spacing )/2.0;
	double y_buffer = ( row_size - block_size - spacing )/2.0;

	# Now build the array containing the coordinates of each grid spot
	array<double> grid_locs[0][0];
	loop
		double start_x = -GRID_WIDTH/2.0 + col_size/2.0;
		double start_y = GRID_HEIGHT/2.0 - row_size/2.0;
		int row = 1
	until
		row > grid_size
	begin
		loop
			int col = 1
		until
			col > grid_size
		begin
			array<double> temp[2];
			temp[1] = start_x;
			temp[2] = start_y;
			grid_locs.add( temp );
			
			start_x = start_x + col_size;
			col = col + 1;
		end;
		start_x = -GRID_WIDTH/2.0 + col_size/2.0;
		start_y = start_y - row_size;
		row = row + 1;
	end;
	
	# Pick a random subset of grid locations to display
	array<int> block_nums[num_blocks];
	block_nums.fill( 1, 0, 1, 1 );
	block_nums.shuffle();
	
	# Randomly jitter the boxes around the grid locs
	# Find the one that's closest to center and put the mouse cursor there
	box_locs.resize( 0 );
	double max_dist = 1000.0;
	loop
		int i = 1
	until
		i > block_nums.count()
	begin
		int this_block = block_nums[i];
		
		array<double> temp[2] = grid_locs[this_block];
		temp[1] = temp[1] + ( double( random_exclude(-1,1,0) ) * random() * x_buffer );
		temp[2] = temp[2] + ( double( random_exclude(-1,1,0) ) * random() * y_buffer );
		
		box_locs.add( temp );
		
		# Put the cursor next to the box nearest screen center
		# Ensures the cursor doesn't start on a block.
		if ( dist( 0.0, 0.0, temp[1], temp[2] ) < max_dist ) then
			max_dist = dist( 0.0, 0.0, temp[1], temp[2] );
			mouse_start[1] = box_locs[i][1] + block_size/1.5;
			mouse_start[2] = box_locs[i][2] + block_size/1.5;
		end;
		
		i = i + 1;
	end;
	
	# Draw the blocks and add them to the stim picture 
	loop
		int i = 1
	until
		i > num_blocks
	begin
		box temp_box = new box( block_size, block_size, box_color );
		corsi_blocks.add( temp_box );
		stim_pic.add_part( corsi_blocks[i], box_locs[i][1], box_locs[i][2] );
		i = i + 1;
	end;
end;

# --- sub add_cursor

# Mouse setup 
mouse mse = response_manager.get_mouse( 1 );
begin
	int max_x = int( MOUSE_SENS * ( display_device.custom_width()/2.0 ) );
	int max_y = int( MOUSE_SENS * ( display_device.custom_height()/2.0 ) );
	mse.set_restricted( 1, true );
	mse.set_restricted( 2, true );
	mse.set_min_max( 1, -max_x, max_x );
	mse.set_min_max( 2, -max_y, max_y );
end;

bool show_cursor = parameter_manager.get_bool( "Show Cursor" );
bool cursor_on = true;

sub 
	add_cursor( double x_loc, double y_loc )
begin
	if ( !cursor_on ) then
		stim_pic.insert_part( 1, cursor, x_loc, y_loc );
		cursor_on = true;
	end;
	stim_pic.set_part_on_top( 1, true );
end;

# --- sub remove_cursor 

sub
	remove_cursor
begin
	if ( cursor_on ) then
		stim_pic.remove_part( 1 );
		cursor_on = false;
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

# --- sub present_instructions --- #

sub
	present_instructions( string instruct_string )
begin
	full_size_word_wrap( instruct_string, font_size, char_wrap, instruct_text );
	instruct_trial.present();
	default.present();
end;

# --- sub ready_set_go --- #

array<string> ready_caps[3];
ready_caps[1] = get_lang_item( lang, "Ready Caption" );
ready_caps[2] = get_lang_item( lang, "Set Caption" );
ready_caps[3] = get_lang_item( lang, "Go Caption" );
int ready_dur = parameter_manager.get_int( "Ready Duration" );
trial_refresh_fix( ready_trial, ready_dur );

begin
	int long_cap = 1;
	loop
		int i = 1
	until
		i > ready_caps.count()
	begin
		if ( ready_caps[i].count() > ready_caps[long_cap].count() ) then
			long_cap = i;
		end;
		i = i + 1;
	end;
	ready_text.set_caption( ready_caps[long_cap], true );
	ready_text.set_height( ready_text.height() * 1.25 );
	ready_text.set_width( ready_text.width() * 1.25 );
end;


sub
	ready_set_go
begin
	if ( ready_dur > 0 ) then
		remove_cursor();
		stim_pic.add_part( ready_text, 0, 0 );
		loop
			int i = 1
		until
			i > ready_caps.count()
		begin
			ready_text.set_caption( ready_caps[i], true );
			ready_trial.present();
			i = i + 1;
		end;
		stim_pic.remove_part( stim_pic.part_count() );
	end;
end;

# --- sub make_full_seq
# this returns a block/digit sequence of the requested length
# starts with a shuffled sequence with each block presented once
# & appends shuffled sequences until it's the requested
# size. Ensures no block is tapped consecutively.

sub
	array<int,1> make_full_seq( int size, int max_val )
begin
	array<int> my_sequence[0];
	
	array<int> temp_seq[max_val];
	temp_seq.fill( 1, 0, 1, 1 );
	temp_seq.shuffle();
	my_sequence.append( temp_seq );
	
	loop
	until
		my_sequence.count() >= size
	begin
		temp_seq.shuffle();
		if ( temp_seq[1] != my_sequence[my_sequence.count()] ) then
			my_sequence.append( temp_seq );
		end;
	end;
	my_sequence.resize( size );
	return my_sequence
end;

# --- sub check_accuracy 
# takes subject's response order, and the presented sequence order
# and returns the number of correct digit responses

sub
	string check_accuracy( array<int,1>& subj_resp, array<int,1>& corr_seq )
begin
	# Count the number of correct responses
	int acc_ctr = 0;
	loop
		int j = 1
	until
		j > subj_resp.count() || j > corr_seq.count()
	begin
		if ( subj_resp[j] == corr_seq[j] ) then
			acc_ctr = acc_ctr + 1;
		end;
		j = j + 1;
	end;
	
	# Return the accuracy & check that response is same length as correct sequence,
	# to ensure that "1,2" is not marked correct for "1,2,3"
	string rval = ACC_INCORRECT;
	if ( acc_ctr == corr_seq.count() ) && ( subj_resp.count() == corr_seq.count() ) then
		rval = ACC_CORRECT;
	end;
	return rval
end;

# --- sub return_string
# takes an int array and returns as a comma-delimited string
# if requested, returns the numbers in reverse order

sub
	string return_string( array<int,1>& this_int_array, string dir, bool reverse )
begin
	string rval = "";
	loop
		int i = 1
	until
		i > this_int_array.count()
	begin
		int this_val = this_int_array[i];
		if ( dir == COND_BACKWARD ) && ( reverse ) then
			this_val = this_int_array[this_int_array.count() + 1 - i];
		end;
		rval.append( string( this_val ) + "," );
		i = i + 1;
	end;
	if ( rval.count() > 1 ) then
		return rval.substring( 1, rval.count() - 1 );
	end;
	return " "
end;

# --- sub show_trial

int on_time = parameter_manager.get_int( "Stimulus Duration" );
int isi_time = parameter_manager.get_int( "ISI Duration" );

sub
	show_trial( array<int,1>& this_order, string dir )
begin
	# Get rid of the mouse cursor
	remove_cursor();
	
	# Now show an ISI
	trial_refresh_fix( main_trial, isi_time );
	main_trial.present();
	
	# Loop through the sequence
	loop
		int i = 1
	until
		i > this_order.count()
	begin
		# Which block are we tapping?
		int this_block = this_order[i];
		if ( dir == COND_BACKWARD ) then
			this_block = this_order[this_order.count() + 1 - i];
		end;
		
		# Flash the block by setting it to the selected color
		# Set the port code based on the block number
		corsi_blocks[this_block].set_color( sel_color );
		trial_refresh_fix( main_trial, on_time );
		main_event.set_port_code( this_block );
		main_trial.present();
		
		# Now change the color back and show the ISI
		corsi_blocks[this_block].set_color( box_color );
		trial_refresh_fix( main_trial, isi_time );
		main_event.set_port_code( 0 );
		main_trial.present();
		
		i = i + 1;
	end;
end;

# --- sub get_resp
# Allows the participant to use the mouse to select a block order by
# highlighting a block and clicking the left mouse button. Stores the 
# sequence and returns the RT when the right mouse button is clicked.

sub
	int get_resp( array<int,1>& this_seq, array<int,1>& this_resp )
begin
	# Clear the response order
	this_resp.resize( 0 );
	
	# Put the cursor on screen near the center block
	if ( show_cursor ) then
		add_cursor( mouse_start[1], mouse_start[2] );
	end;
	mse.set_xy( int( mouse_start[1] * MOUSE_SENS ), int( mouse_start[2] * MOUSE_SENS ) );

	# Present a single refresh of the main trial to get the onset time
	main_trial.set_duration( main_trial.STIMULI_LENGTH );
	main_event.set_port_code( PROMPT_P_CODE );
	main_trial.present();
	int onset_time = stimulus_manager.last_stimulus_data().time();
	
	# Loop until they press the exit button
	loop
		int selected = 0;
		int resp_ct = response_manager.total_response_count( SEL_BUTTON );
		int end_ct = response_manager.total_response_count( END_BUTTON );
	until
		response_manager.total_response_count( END_BUTTON ) > end_ct
	begin
		# Show the pic and move the mouse
		mse.poll();
		if ( show_cursor ) then
			stim_pic.set_part_x( 1, double( mse.x() )/ MOUSE_SENS );
			stim_pic.set_part_y( 1, double( mse.y() )/ MOUSE_SENS );
		end;
		stim_pic.present();

		# Now check which block they're on, if any
		# If they are on a block, highlight it with a diff color
		selected = 0;
		loop
			int i = 1
		until
			i > box_locs.count()
		begin
			double this_x = double( mse.x() )/MOUSE_SENS;
			double this_y = double( mse.y() )/MOUSE_SENS;
			if ( this_x < box_locs[i][1] + ( block_size/2.0 ) ) && 
				( this_x > box_locs[i][1] - ( block_size/2.0 ) ) &&
				( this_y < box_locs[i][2] + ( block_size/2.0 ) ) &&
				( this_y > box_locs[i][2] - ( block_size/2.0 ) ) then
				selected = i;
				corsi_blocks[i].set_color( sel_color );
			else
				corsi_blocks[i].set_color( box_color );
			end;

			i = i + 1;
		end;
		
		# Add the selected block to the list and "flash" the block with 
		# the mouse cursor color so that they know the response counted
		if ( response_manager.total_response_count( SEL_BUTTON ) > resp_ct ) then
			if ( selected > 0 ) then
				this_resp.add( selected );
				corsi_blocks[selected].set_color( tap_color );
				stim_pic.present();
				wait_interval( SEL_TIME );
				corsi_blocks[selected].set_color( sel_color );
			end;
			resp_ct = response_manager.total_response_count( 1 );
		end;
		
		# If they clicked the exit button, reset the boxes to the proper colors
		if ( response_manager.total_response_count( END_BUTTON ) > end_ct ) then
			loop
				int i = 1
			until
				i > corsi_blocks.count()
			begin
				corsi_blocks[i].set_color( box_color );
				i = i + 1;
			end;
		end;
	end;
	
	# Return the RT
	return response_manager.last_response_data().time() - onset_time
end;

# --- sub show_block
# shows a complete block tapping task in the specified direction
# specify the order (forward/backward), staring length, and block number

string test_type = parameter_manager.get_string( "Test Type" );
int corr_to_increase = parameter_manager.get_int( "Staircase Correct to Increase" );
int incorr_to_decrease = parameter_manager.get_int( "Staircase Incorrect to Decrease" );
int fixed_count = parameter_manager.get_int( "Fixed Trials at Each Length" );
int total_trials = parameter_manager.get_int( "Staircase Trial Count" );
int recall_delay = parameter_manager.get_int( "Recall Prompt Delay" );
int prac_trials = parameter_manager.get_int( "Practice Trials" );

# -- Set up info for summary stats -- #
int SUM_BLOCK_IDX = 1;
int SUM_SPAN_IDX = 2;

array<string> cond_names[2][0];
cond_names[SUM_BLOCK_IDX].resize( 2 );
cond_names[SUM_BLOCK_IDX][COND_FORWARD_IDX] = COND_FORWARD;
cond_names[SUM_BLOCK_IDX][COND_BACKWARD_IDX] = COND_BACKWARD;

loop
	int i = 1 
until
	i > 100
begin
	cond_names[SUM_SPAN_IDX].add( string(i) );
	i = i + 1;
end;

# Now build an empty array for all DVs of interest
array<int> acc_stats[cond_names[1].count()][cond_names[2].count()][0];
array<int> RT_stats[cond_names[1].count()][cond_names[2].count()][0];
# --- End Summary Stats --- #

sub
	show_block( string order, int start_length, int block_number )
begin
	loop
		array<int> resp_seq[0];
		int curr_length = start_length;
		bool ok = false;
		int length_ctr = 0;
		int corr_ctr = 0;
		int incorr_ctr = 0;
		int i = 1
	until
		ok
	begin
		# Make a legal block/digit sequence
		array<int> this_seq[curr_length] = make_full_seq( curr_length, num_blocks );
	
		# Show sequence
		ready_set_go();
		show_trial( this_seq, order );
		if ( recall_delay > 0 ) then
			trial_refresh_fix( wait_trial, recall_delay );
			wait_trial.present();
		end;
		
		# Now get the response
		int RT = get_resp( this_seq, resp_seq );
		remove_cursor();
		string accuracy = check_accuracy( resp_seq, this_seq );

		# Store the event info
		info_event.set_event_code( 
			MAIN_EVENT_CODE + ";" +
			string( block_number ) + ";" +
			order + ";" +
			string( i ) + ";" +
			string( curr_length ) + ";" +
			return_string( this_seq, order, true ) + ";" +
			return_string( resp_seq, order, false ) + ";" +
			accuracy + ";" +
			string( RT )
		);
		info_trial.present();
		
		# Record trial info for summary stats
		# Make an int array specifying the condition we're in
		# This tells us which subarray to store the trial info
		array<int> this_trial[cond_names.count()];
		if ( order == COND_FORWARD ) then
			this_trial[SUM_BLOCK_IDX] = COND_FORWARD_IDX;
		else
			this_trial[SUM_BLOCK_IDX] = COND_BACKWARD_IDX;
		end;
		this_trial[SUM_SPAN_IDX] = curr_length;

		int this_hit = int( accuracy == ACC_CORRECT );
		if ( block_number > 0 ) then
			acc_stats[this_trial[1]][this_trial[2]].add( this_hit );
			RT_stats[this_trial[1]][this_trial[2]].add( RT );
		end;
		
		# Update the list length, depending on previous trial performance/number
		length_ctr = length_ctr + 1;
		if ( accuracy == ACC_CORRECT ) then
			corr_ctr = corr_ctr + 1;
			incorr_ctr = 0;
		else
			incorr_ctr = incorr_ctr + 1;
			corr_ctr = 0;
		end;
		
		if ( test_type == TYPE_FIXED ) then
			if ( length_ctr >= fixed_count ) then
				if ( incorr_ctr >= fixed_count ) then
					ok = true;
				else
					curr_length = curr_length + 1;
					length_ctr = 0;
					incorr_ctr = 0;
					corr_ctr = 0;
				end;
			end;
		else
			if ( corr_ctr >= corr_to_increase ) then
				curr_length = curr_length + 1;
				corr_ctr = 0;
			end;
			if ( incorr_ctr >= incorr_to_decrease ) then
				curr_length = curr_length - 1;
				incorr_ctr = 0;
			end;
			if ( i >= total_trials ) then
				ok = true;
			end;
		end;
		
		# Make sure we don't go out of bounds on list length
		if ( curr_length < MIN_LENGTH ) then
			curr_length = MIN_LENGTH;
		end;
		
		# End after set number of practice trials
		if ( block_number == 0 ) && ( i == prac_trials ) then
			ok = true;
		end;
		
		# Wait for the next trial
		wait_trial.present();
		
		i = i + 1;
	end;
end;

# --- Conditions and Trial Order --- #

array<string> block_order[0][0];

begin
	# Determine the order of forward/backward blocks
	array<string> test_order[0];
	parameter_manager.get_strings( "Test Order", test_order );
	if ( test_order.count() == 0 ) then
		exit( "Error: 'Test Order' cannot be empty." );
	elseif ( parameter_manager.get_bool( "Randomize Test Order" ) ) then
		test_order.shuffle();
	end;
	
	# Set up the order of blocks and the starting list sizes
	int forward_start = parameter_manager.get_int( "Forward Span Starting Length" );
	int backward_start = parameter_manager.get_int( "Backward Span Starting Length" );
	loop
		int i = 1
	until
		i > test_order.count()
	begin
		array<string> temp[2];
		temp[TYPE_IDX] = test_order[i];
		if ( test_order[i] == COND_FORWARD ) then
			temp[START_IDX] = string( forward_start );
		else
			temp[START_IDX] = string( backward_start );
		end;
		block_order.add( temp );
		i = i + 1;
	end;
end;

# --- Main Sequence --- #

string fwd_instrucs = get_lang_item( lang, "Forward Instructions" );
string bwd_instrucs = get_lang_item( lang, "Backward Instructions" );

# Show practice trials
string prac_caption = get_lang_item( lang, "Practice Caption" );
if ( block_order[1][1] == COND_FORWARD ) then
	main_instructions( fwd_instrucs + " " + prac_caption );
else
	main_instructions( bwd_instrucs + " " + prac_caption );
end;
show_block( block_order[1][1], int( block_order[1][START_IDX] ), 0 );
present_instructions( get_lang_item( lang, "Practice Complete Caption" ) );

# Loop to present main trial blocks
loop
	int i = 1
until
	i > block_order.count()
begin
	string this_block = block_order[i][TYPE_IDX];
	if ( block_order[i][1] == COND_FORWARD ) then
		main_instructions( fwd_instrucs );
	else
		main_instructions( bwd_instrucs );
	end;
	show_block( block_order[i][TYPE_IDX], int( block_order[i][START_IDX] ), i );
	i = i + 1;
end;
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
	cond_headings[SUM_BLOCK_IDX + 1] = "Test Type";
	cond_headings[SUM_SPAN_IDX + 1] = "Span";
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
			if ( acc_stats[i][j].count() > 0 ) then
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
			end;
			j = j + 1;
		end;
		i = i + 1;
	end;

	# Close the file and exit
	out.close();
end;