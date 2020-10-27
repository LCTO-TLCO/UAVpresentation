# -------------------------- Header Parameters --------------------------

scenario = "Berg's Card Sorting Task";

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
	trial_num, number,
	drawn_ct, number,
	drawn_shape, string,
	drawn_color, string,
	sel_ct, number,
	sel_shape, string,
	sel_color, string,
	curr_sort, string,
	corr_inarow, number,
	accuracy, string,
	RT, number;
event_code_delimiter = ";";

# ------------------------------- SDL Part ------------------------------
begin;

ellipse_graphic {
	ellipse_height = EXPARAM( "Cursor Size" );
	ellipse_width = EXPARAM( "Cursor Size" );
	color = EXPARAM( "Cursor Color" );
} cursor;

text {
	caption = "Feedback";
	preload = false;
} fb_text;

text {
	caption = "Select";
	preload = false;
} select_text;

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
		picture {} card_pic;
		code = "Trial Onset";
	} card_event;
} card_trial;

trial {
	stimulus_event {
		picture card_pic;
		code = "Feedback";
	} fb_event;
} fb_trial;

# ----------------------------- PCL Program -----------------------------
begin_pcl;

include_once "../../Library/lib_visual_utilities.pcl";
include_once "../../Library/lib_utilities.pcl";

# --- Constants --- #

string SPLIT_LABEL = "[SPLIT]";
string LINE_BREAK = "\n";
int BUTTON_FWD = 1;
int BUTTON_BWD = 0;

# Mouse sensitivity (increase to "slow down" the mouse). Cannot be negative!
double mse_scale = 5.0; 

string EVENT_CODE_MARKER = "Info";

string PRACTICE_TYPE_PRACTICE = "Practice";
string PRACTICE_TYPE_MAIN = "Main";

int COND_COLOR_IDX = 1;
int COND_SHAPE_IDX = 2;
int COND_COUNT_IDX = 3;

int TRI_IDX = 1;
int SQ_IDX = 2;
int PLUS_IDX = 3;
int CIRCLE_IDX = 4;

string SHAPE_TRI = "Triangle";
string SHAPE_PLUS = "Plus";
string SHAPE_CIRCLE = "Circle";
string SHAPE_SQ = "Diamond";

int DECK_CT = 4;

string STOP_TRIALS = "Trials";
string STOP_SWITCHES = "Rule Switches";

string ACC_CORRECT = "Correct";
string ACC_INCORRECT = "Incorrect";

string COND_SHAPE = "Shape";
string COND_COUNT = "Count";
string COND_COLOR = "Color";

string CHARACTER_WRAP = "Character";

# --- fixed stimulus values --- #

string language = parameter_manager.get_string( "Language" );
language_file lang = load_language_file( scenario_directory + language + ".xml" );
bool char_wrap = ( get_lang_item( lang, "Word Wrap Mode" ).lower() == CHARACTER_WRAP.lower() );

adjust_used_screen_size( parameter_manager.get_bool( "Use Widescreen if Available" ) );

double font_size = parameter_manager.get_double( "Default Font Size" );

trial_refresh_fix( fb_trial, parameter_manager.get_int( "Feedback Duration" ) );

# Stim values #
double deck_height = 50.0;
double deck_width = 50.0;
double spacing = 10.0;
double outline_width = 1.0;

double obj_size = 15.0;
double obj_spacing = 5.0;
double plus_width = 4.0;

double deck_bottom = ( display_device.custom_height()/2.0 ) - deck_height - spacing - outline_width;
double drawn_top = deck_bottom - ( deck_height/1.5 ) - outline_width;
double fb_y = deck_bottom - ( abs( deck_bottom - drawn_top ) / 2.0 );
int cursor_y = int( ( drawn_top + spacing ) * mse_scale );

# --- Stimuli --- #

# Draw the deck outlines #
rgb_color selected_color = parameter_manager.get_color( "Deck Highlight Color" );
rgb_color deck_outline_color = parameter_manager.get_color( "Deck Outline Color" );

line_graphic deck = new line_graphic();
line_graphic selected_deck = new line_graphic();

begin
	array<double> end_points[0][2];
	array<double> temp[2];
	temp[1] = -deck_width/2.0;
	temp[2] = deck_height/2.0;
	end_points.add( temp );
	temp[1] = deck_width/2.0;
	end_points.add( temp );
	temp[2] = -deck_height/2.0;
	end_points.add( temp );
	temp[1] = -deck_width/2.0;
	end_points.add( temp );

	# Draw the deck 
	deck.set_line_width( outline_width );
	deck.set_line_color( deck_outline_color );
	deck.set_fill_color( parameter_manager.get_color( "Deck Fill Color" ) );
	deck.add_polygon( end_points, true, 1.0, 0.0 );
	deck.set_join_type( deck.JOIN_CIRCLE );
	deck.redraw();

	# Draw the "highlighted" deck #
	selected_deck.set_line_width( outline_width );
	selected_deck.set_line_color( deck_outline_color );
	selected_deck.set_join_type( selected_deck.JOIN_CIRCLE );
	selected_deck.add_polygon( end_points, false, 1.0, 0.0 );
	selected_deck.redraw();
end;

# Draw the static and temporary circles
array<rgb_color> colors[0];
parameter_manager.get_colors( "Shape Colors", colors );

array<string> color_names[0];
parameter_manager.get_strings( "Shape Color Names", color_names );

if ( colors.count() != DECK_CT || color_names.count() != DECK_CT ) then
	exit( "Error: 'Colors Tested' and 'Color Names' must each contain four values." );
end;

ellipse_graphic circle = new ellipse_graphic();
circle.set_dimensions( obj_size, obj_size );
circle.set_color( colors[CIRCLE_IDX] );
circle.redraw();

ellipse_graphic adj_circle = new ellipse_graphic();
adj_circle.set_dimensions( obj_size, obj_size );
adj_circle.set_color( colors[CIRCLE_IDX] );
adj_circle.redraw();

# Draw the static and temporary triangles
line_graphic triangle = new line_graphic();
line_graphic adj_triangle = new line_graphic();

begin
	array<double> tri_points[0][2];
	array<double> temp[2];
	temp[1] = 0.0;
	temp[2] = obj_size/2.0;
	tri_points.add( temp );
	temp[1] = -obj_size/2.0;
	temp[2] = -obj_size/2.0;
	tri_points.add( temp );
	temp[1] = obj_size/2.0;
	tri_points.add( temp );

	triangle.add_polygon( tri_points, true, 1.0, 0.0 );
	triangle.set_fill_color( colors[TRI_IDX] );
	triangle.redraw();

	adj_triangle.add_polygon( tri_points, true, 1.0, 0.0 );
	adj_triangle.set_fill_color( colors[TRI_IDX] );
	adj_triangle.redraw();
end;

# Draw the static and temporary plus
line_graphic plus = new line_graphic();
line_graphic adj_plus = new line_graphic();

begin
	plus.set_line_color( colors[PLUS_IDX] );
	plus.set_line_width( plus_width );
	plus.add_line( 0.0, obj_size/2.0, 0.0, -obj_size/2.0 );
	plus.add_line( obj_size/2.0, 0.0, -obj_size/2.0, 0.0 );
	plus.redraw();

	adj_plus.set_line_color( colors[PLUS_IDX] );
	adj_plus.set_line_width( plus_width );
	adj_plus.add_line( 0.0, obj_size/2.0, 0.0, -obj_size/2.0 );
	adj_plus.add_line( obj_size/2.0, 0.0, -obj_size/2.0, 0.0 );
	adj_plus.redraw();
end;

# Draw the static and temporary diamonds
line_graphic square = new line_graphic();
line_graphic adj_square = new line_graphic();

begin
	array<double> sq_coords[0][2];
	array<double> temp[2];
	temp[1] = 0.0;
	temp[2] = obj_size/2.0;
	sq_coords.add( temp );
	temp[1] = obj_size/3.0;
	temp[2] = 0.0;
	sq_coords.add( temp );
	temp[1] = 0.0;
	temp[2] = -obj_size/2.0;
	sq_coords.add( temp );
	temp[1] = -obj_size/3.0;
	temp[2] = 0.0;
	sq_coords.add( temp );

	square.set_fill_color( colors[SQ_IDX] );
	square.add_polygon( sq_coords, true, 1.0, 0.0 );
	square.redraw();

	adj_square.set_fill_color( colors[SQ_IDX] );
	adj_square.add_polygon( sq_coords, true, 1.0, 0.0 );
	adj_square.redraw();
end;

# Put the objects into graphic surface arrays #
array<graphic_surface> all_objs[4];
all_objs[CIRCLE_IDX] = circle;
all_objs[TRI_IDX] = triangle;
all_objs[PLUS_IDX] = plus;
all_objs[SQ_IDX] = square;

array<graphic_surface> adj_objs[4];
adj_objs[CIRCLE_IDX] = adj_circle;
adj_objs[TRI_IDX] = adj_triangle;
adj_objs[PLUS_IDX] = adj_plus;
adj_objs[SQ_IDX] = adj_square;

# --- Stim and Object Locations --- #

array<double> deck_locs[0][2];
begin
	double total_width = ( deck_width * double( DECK_CT ) ) + ( spacing * double( DECK_CT - 1 ) );
	double start_x = ( -total_width/2.0 ) + ( deck_width/2.0 );
	loop
		int i = 1
	until
		i > DECK_CT
	begin
		array<double> temp[2];
		temp[1] = start_x;
		temp[2] = deck_bottom + ( deck_height/2.0 );
		deck_locs.add( temp );
		start_x = start_x + spacing + deck_width;
		i = i + 1;
	end;
end;

# Build an arry to hold positions for each of the four possible object counts
array<double> obj_locs[DECK_CT][0][2];
begin
	# One object locations
	array<double> temp[2] = { 0.0, 0.0 };
	obj_locs[1].add( temp );
	
	# Two object locations
	temp[1] = ( -deck_width/2.0 ) + obj_size/2.0 + obj_spacing;
	temp[2] = ( deck_height/2.0 ) - obj_size/2.0 - obj_spacing;
	obj_locs[2].add( temp );
	temp[1] = -temp[1];
	temp[2] = -temp[2];
	obj_locs[2].add( temp );
	
	# Three object locations
	obj_locs[3].add( temp );
	temp[1] = -temp[1];
	obj_locs[3].add( temp );
	temp[1] = 0.0;
	temp[2] = ( deck_height/2.0 ) - obj_size/2.0 - obj_spacing;
	obj_locs[3].add( temp );
	
	# Four object locations
	temp[1] = ( -deck_width/2.0 ) + obj_size/2.0 + obj_spacing;
	obj_locs[4].add( temp );
	temp[1] = -temp[1];
	obj_locs[4].add( temp );
	temp[2] = -temp[2];
	obj_locs[4].add( temp );
	temp[1] = -temp[1];
	obj_locs[4].add( temp );
end;

# --- Now add the static decks to the picture --- #

# pile_info will hold the color, count, and shape info for the sorting decks
array<int> pile_info[4][3];
pile_info[CIRCLE_IDX][COND_SHAPE_IDX] = CIRCLE_IDX;
pile_info[TRI_IDX][COND_SHAPE_IDX] = TRI_IDX;
pile_info[PLUS_IDX][COND_SHAPE_IDX] = PLUS_IDX;
pile_info[SQ_IDX][COND_SHAPE_IDX] = SQ_IDX;

loop
	int i = 1
until
	i > deck_locs.count()
begin
	card_pic.add_part( deck, deck_locs[i][1], deck_locs[i][2] );
	loop
		int j = 1
	until
		j > obj_locs[i].count()
	begin
		double curr_x = deck_locs[i][1];
		double curr_y = deck_locs[i][2];
		card_pic.add_part( all_objs[i], curr_x + obj_locs[i][j][1], curr_y + obj_locs[i][j][2] );
		j = j + 1;
	end;
	pile_info[i][COND_COUNT_IDX] = obj_locs[i].count();
	pile_info[i][COND_COLOR_IDX] = i;
	i = i + 1;
end;

# Make the deck from which stim are drawn 
array<int> deck_cards[0][0];

loop
	bool modified_deck = parameter_manager.get_bool( "Use Modified Deck" );
	int color_val = 1
until
	color_val > DECK_CT
begin
	loop
		int shape_val = 1
	until
		shape_val > DECK_CT
	begin
		loop
			int count_val = 1
		until
			count_val > DECK_CT
		begin
			array<int> temp[3];
			temp[COND_COLOR_IDX] = color_val;
			temp[COND_SHAPE_IDX] = shape_val;
			temp[COND_COUNT_IDX] = count_val;
			
			bool bad_card = ( temp[1] == temp[2] ) || ( temp[2] == temp[3] ) || ( temp[1] == temp[3] );
			if ( !bad_card ) || ( !modified_deck ) then
				deck_cards.add( temp );
			end;
			
			count_val = count_val + 1;
		end;
		shape_val = shape_val + 1;
	end;
	color_val = color_val + 1;
end;
deck_cards.shuffle();

# --- Subroutines --- #

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

# --- sub check_deck (returns deck # currently selected by mouse cursor position)

# Set up the mouse
mouse mse = response_manager.get_mouse( 1 );
begin
	int half_height = int( ( display_device.custom_height()/2.0 ) * mse_scale );
	int half_width = int( ( display_device.custom_width()/2.0 )  * mse_scale );
	mse.set_min_max( 1, -half_width, half_width );
	mse.set_min_max( 2, -half_height, half_height );
end;

sub
	int check_deck
begin
	# Get mouse position
	mse.poll();
	double x = double( mse.x() ) / mse_scale;
	double y = double( mse.y() ) / mse_scale;

	# Check against deck positions
	loop
		int i = 1
	until
		i > deck_locs.count()
	begin		
		if ( x > deck_locs[i][1] - deck_width/2.0 ) &&
			( x < deck_locs[i][1] + deck_width/2.0 ) &&
			( y > deck_locs[i][2] - deck_height/2.0 ) &&
			( y < deck_locs[i][2] + deck_height/2.0 ) then
			return i
		end;
		i = i + 1;
	end;
	return 0
end;

# --- sub draw_new_card
# --- updates the card pic with new color/shape/number for the drawn card

bool show_cursor = parameter_manager.get_bool( "Show Cursor" );
card_pic.add_part( selected_deck, deck_locs[1][1], deck_locs[1][2] );
int highlight_part = card_pic.part_count();
if ( show_cursor ) then
	card_pic.add_part( cursor, 0, 0 );
end;
int cursor_part = card_pic.part_count();

select_text.set_max_text_width( used_screen_width * 0.8 );
double select_text_top = drawn_top - deck_height - spacing/2.0;
select_text.set_max_text_height( abs( -used_screen_height/2.0 - select_text_top ) * 0.8 );
select_text.set_caption( get_lang_item( lang, "Select Caption" ), true );

sub
	draw_new_card( array<int,1>& card_info )
begin
	# Get the current part count
	int start_ct = card_pic.part_count();
	
	# Now add the deck outline and hang onto the x/y positions
	double x_off = 0.0;
	double y_off = drawn_top - ( deck_height/2.0 );
	card_pic.add_part( deck, x_off, y_off );
	
	# Get the shape, count, and color for the chosen card
	int this_shape = card_info[COND_SHAPE_IDX];
	int this_count = card_info[COND_COUNT_IDX];
	int this_color = card_info[COND_COLOR_IDX];
	
	# Draw the appropriate shape in the correct color
	if ( this_shape == CIRCLE_IDX ) then
		adj_circle.set_color( colors[this_color] );
		adj_circle.redraw();
	elseif ( this_shape == SQ_IDX ) then
		adj_square.set_fill_color( colors[this_color] );
		adj_square.redraw();
	elseif ( this_shape == TRI_IDX ) then
		adj_triangle.set_fill_color( colors[this_color] );
		adj_triangle.redraw();
	elseif ( this_shape == PLUS_IDX ) then
		adj_plus.set_line_color( colors[this_color] );
		adj_plus.redraw();
	end;
	
	# Now add the appropriate number of shapes to the card
	loop
		int j = 1
	until
		j > this_count
	begin
		card_pic.add_part( adj_objs[this_shape], x_off + obj_locs[this_count][j][1], y_off + obj_locs[this_count][j][2] );
		j = j + 1;
	end;
	
	# Now add the reminder text beneath the card
	card_pic.add_part( select_text, 0, 0 );
	card_pic.set_part_y( card_pic.part_count(), select_text_top, card_pic.TOP_COORDINATE );
end;

# --- sub show_trials

# Initialize some values
string corr_fb = fix_empty_string( parameter_manager.get_string( "Correct Feedback Caption" ) );
string incorr_fb = fix_empty_string( parameter_manager.get_string( "Incorrect Feedback Caption" ) );
int switch_ct = parameter_manager.get_int( "Switch Count" );
bool use_first_sort = parameter_manager.get_bool( "Use First Sort" );

array<string> shape_names[DECK_CT];
shape_names[TRI_IDX] = SHAPE_TRI;
shape_names[SQ_IDX] = SHAPE_SQ;
shape_names[PLUS_IDX] = SHAPE_PLUS;
shape_names[CIRCLE_IDX] = SHAPE_CIRCLE;

array<string> sort_names[3];
sort_names[COND_SHAPE_IDX] = COND_SHAPE;
sort_names[COND_COUNT_IDX] = COND_COUNT;
sort_names[COND_COLOR_IDX] = COND_COLOR;

# --- sub get_selection

sub
	int get_selection
begin
	# Return value
	int selected = 0;
	
	# Reset the mouse and make sure the cursor draws on top
	if ( show_cursor ) then
		card_pic.set_part_on_top( cursor_part, true );
	end;
	mse.set_xy( 0, cursor_y );
	
	# Loop until a legal response is made
	loop
	until
		selected > 0
	begin
		card_pic.present();
		loop
			int resp_ct = response_manager.total_response_count( 1 );
		until
			response_manager.total_response_count( 1 ) > resp_ct
		begin
			# First update the mouse cursor
			if ( show_cursor ) then
				# Update the cursor
				selected = check_deck();
				card_pic.set_part_x( cursor_part, double( mse.x() )/ mse_scale );
				card_pic.set_part_y( cursor_part, double( mse.y() )/ mse_scale );
				
				# We highlight a deck if one is selected
				if ( selected == 0 ) then
					selected_deck.set_line_color( deck_outline_color );
				else
					card_pic.set_part_x( highlight_part, deck_locs[selected][1] );
					selected_deck.set_line_color( selected_color );
				end;
				selected_deck.redraw();

				# Show the main picture
				card_pic.present();
			end;
		end;
		
		selected = check_deck();
	end;
	return selected
end;	

# -- Summary Stat Info -- #
int total_trials = 0;
int total_switches = 0;
int total_errors = 0;
int persev_errors = 0;
# -- End Summary Stat Info -- #

sub
	show_trials( string prac_check, string stop_type, int trials_to_run, int switches_to_run )
begin
	deck_cards.shuffle();
	loop
		bool escape = false;
		int card_ctr = 1;
		int switch_ctr = 0;
		int trial_ctr = 1;
		int corr_sort = random( 1, 3 );
		int last_sort_cat = 0;
		int corr_ctr = 0;
	until
		escape
	begin
		# Start by getting the current sorting attribute
		if ( corr_ctr >= switch_ct ) then
			last_sort_cat = corr_sort;
			corr_sort = random_exclude( 1, 3, last_sort_cat );
			switch_ctr = switch_ctr + 1;
		end;

		# Draw the next card
		int temp_ct = card_pic.part_count();
		array<int> drawn_card[3] = deck_cards[card_ctr];
		draw_new_card( drawn_card );
		int this_count = card_pic.part_count() - temp_ct;
		
		# Loop until they pick a card
		int RT = clock.time();
		int selected = get_selection();
		RT = clock.time() - RT;
				
		# Remove the selected text
		card_pic.remove_part( card_pic.part_count() );
		
		# Get the info of the chosen card
		array<int> selected_card[3] = pile_info[selected];
		
		# Check the accuracy
		bool corr = ( drawn_card[corr_sort] == selected_card[corr_sort] );
		if ( card_ctr == 1 ) && ( use_first_sort ) && ( !corr ) then
			loop
				int a = 1 
			until
				a > 3
			begin
				if ( drawn_card[a] == selected_card[a] ) then
					corr_sort = a;
					corr = true;
					break;
				end;
				a = a + 1;
			end;
		end;
		
		# Update the feedback text
		string accuracy = ACC_CORRECT;
		if ( corr ) then
			fb_text.set_caption( corr_fb, true );
			corr_ctr = corr_ctr + 1;
		else
			fb_text.set_caption( incorr_fb, true );
			accuracy = ACC_INCORRECT;
			corr_ctr = 0;
		end;
		
		# Set the event code
		fb_event.set_event_code( 
			EVENT_CODE_MARKER + ";" +
			prac_check + ";" +
			string( trial_ctr ) + ";" +
			string( drawn_card[COND_COUNT_IDX] ) + ";" +
			shape_names[drawn_card[COND_SHAPE_IDX]] + ";" +
			color_names[drawn_card[COND_COLOR_IDX]] + ";" +
			string( selected_card[COND_COUNT_IDX] ) + ";" +
			shape_names[selected_card[COND_SHAPE_IDX]] + ";" +
			color_names[selected_card[COND_COLOR_IDX]] + ";" +
			sort_names[corr_sort] + ";" +
			string( corr_ctr ) + ";" +
			accuracy + ";" +
			string( RT )
		);
		
		# Show the feedback
		card_pic.add_part( fb_text, 0.0, fb_y );
		fb_trial.present();
		
		# Get rid of the extraneous parts
		loop
			int i = 1
		until
			i > this_count
		begin
			card_pic.remove_part( card_pic.part_count() );
			i = i + 1;
		end;

		# Increment the counters
		trial_ctr = trial_ctr + 1;
		card_ctr = card_ctr + 1;
		if ( card_ctr > deck_cards.count() ) then
			card_ctr = 1;
			deck_cards.shuffle();
		end;
		
		# Update Summary Stats
		if ( prac_check == PRACTICE_TYPE_MAIN ) then
			total_trials = total_trials + 1;
			total_switches = switch_ctr;
			if ( accuracy == ACC_INCORRECT ) then
				total_errors = total_errors + 1;
				if ( last_sort_cat > 0 ) then
					if ( selected_card[last_sort_cat] == drawn_card[last_sort_cat] ) then
						persev_errors = persev_errors + 1;
					end;
				end;
			end;
		end;
				
		# Check if we should exit
		if ( ( stop_type == STOP_TRIALS ) && ( trial_ctr > trials_to_run ) ) ||
			( ( stop_type == STOP_SWITCHES ) && ( switch_ctr > switches_to_run ) ) then
			escape = true;
		end;
	end;
end;

# --- Main Sequence --- #

string instructions = get_lang_item( lang, "Instructions" );
int prac_trials = parameter_manager.get_int( "Practice Trials" );
string stop_cond = parameter_manager.get_string( "Stop Condition" );
int num_trials = parameter_manager.get_int( "Total Trials" );
int num_switches = parameter_manager.get_int( "Total Switches" );
if ( switch_ct >= num_trials ) then
	exit( "Error: 'Switch Count' must be less than 'Total Trials'" );
end;

if ( prac_trials > 0 ) then
	main_instructions( instructions + " " + get_lang_item( lang, "Practice Caption" ) );
	show_trials( PRACTICE_TYPE_PRACTICE, STOP_TRIALS, prac_trials, 0 );
	present_instructions( get_lang_item( lang, "Practice Complete Caption" ) );
else
	main_instructions( instructions );
end;
show_trials( PRACTICE_TYPE_MAIN, stop_cond, num_trials, num_switches );
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
	array<string> cond_headings[0];
	cond_headings.add( "Subject ID" );
	cond_headings.add( "Trials" );
	cond_headings.add( "Rule Changes" );
	cond_headings.add( "Correct Sorts" );
	cond_headings.add( "Total Errors" );
	cond_headings.add( "Persev. Errors" );
	
	loop
		int i = 1
	until
		i > cond_headings.count()
	begin
		out.print( cond_headings[i] + TAB );
		i = i + 1;
	end;

	out.print( "\n" + subj + TAB );
	out.print( string( total_trials ) + TAB );
	out.print( string( total_switches ) + TAB );
	out.print( string( total_trials - total_errors ) + TAB );
	out.print( string( total_errors ) + TAB );	
	out.print( string( persev_errors ) + TAB );
	out.print( date_time() );
	
	# Close the file and exit
	out.close();
end;