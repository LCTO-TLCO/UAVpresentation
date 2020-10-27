# -------------------------- Header Parameters --------------------------

scenario = "Iowa Gambling Task";

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
	deck_select, number,
	RT, number,
	reward, number,
	penalty, number,
	total, number;
event_code_delimiter = ";";

# ------------------------------- SDL Part ------------------------------

begin;

ellipse_graphic {
	ellipse_height = EXPARAM( "Cursor Size" );
	ellipse_width = EXPARAM( "Cursor Size" );
	color = EXPARAM( "Cursor Color" );
} cursor;

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
		picture {} main_pic;
	} main_event;
} main_trial;

trial {
	stimulus_event {
		picture {} fb_pic;
		code = "Feedback";
	} fb_event;
} fb_trial;

trial {
	stimulus_event {
		nothing{};
	} info_event;
} info_trial;

# ----------------------------- PCL Program -----------------------------
begin_pcl;

include_once "../../Library/lib_visual_utilities.pcl";
include_once "../../Library/lib_utilities.pcl";

# --- Constants ---

string MAIN_EVENT_CODE = "Main";

string SPLIT_LABEL = "[SPLIT]";
string LINE_BREAK = "\n";
int BUTTON_FWD = 1;
int BUTTON_BWD = 0;

string DECK_COUNT_LABEL = "[NUMBER_DECKS_LABEL]";
string CHOICE_LABEL = "[CHOICE]";
string REWARD_LABEL = "[REWARD]";
string PENALTY_LABEL = "[PENALTY]";
string TOTAL_LABEL = "[TOTAL]";

double DECK_SPACE = 10.0; 		# Horizontal space between decks
double DECK_LW = 3.0; 			# Line width of the outline around the decks 
double Y_ADJ = 10.0; 			# Buffer distance from top/bottom of screen
double DECK_FONT_SIZE = 9.0; 	# Font size of deck numbers
double MOUSE_SENS = 4.0; 		# Mouse sensitivity (Higher value = less sensitive)

int REW_IDX = 1;
int PEN_IDX = 2;

string CHARACTER_WRAP = "Character";

# --- Fixed Stimulus Parameters

adjust_used_screen_size( parameter_manager.get_bool( "Use Widescreen if Available" ) );

string language = parameter_manager.get_string( "Language" );
language_file lang = load_language_file( scenario_directory + language + ".xml" );

bool char_wrap = ( get_lang_item( lang, "Word Wrap Mode" ).lower() == CHARACTER_WRAP.lower() );

double font_size = parameter_manager.get_double( "Default Font Size" );

trial_refresh_fix( fb_trial, parameter_manager.get_int( "Feedback Duration" ) );

# Build the deck boxes
sub
	line_graphic draw_outline( double bx_width, double bx_height, rgb_color lin_color, double lin_width )
begin
	line_graphic out_line = new line_graphic();
	out_line.set_line_color( lin_color );
	out_line.set_line_width( lin_width );
	out_line.set_join_type( out_line.JOIN_CIRCLE );
	
	array<double> vertices[0][2];
	array<double> temp[2];
	temp[1] = -bx_width/2.0;
	temp[2] = bx_height/2.0;
	vertices.add( temp );
	
	temp[1] = bx_width/2.0;
	vertices.add( temp );
	
	temp[2] = -bx_height/2.0;
	vertices.add( temp );
	
	temp[1] = -bx_width/2.0;
	vertices.add( temp );
	
	out_line.add_polygon( vertices, false, 1.0, 0.0 );
	out_line.redraw();
	
	return out_line
end;

int num_decks = parameter_manager.get_int( "Decks" );
array<text> number_texts[num_decks];
array<line_graphic> outlines[num_decks];
array<box> inner_boxes[num_decks];
array<double> deck_locs[0][0];

double deck_width = parameter_manager.get_double( "Deck Width" );
double deck_height = parameter_manager.get_double( "Deck Height" );
rgb_color outline_color = parameter_manager.get_color( "Deck Outline Color" );
rgb_color selected_color = parameter_manager.get_color( "Selected Deck Outline Color" );
double deck_bottom = used_screen_height/2.0 - Y_ADJ - deck_height - DECK_LW/2.0;

loop
	double y_pos = ( used_screen_height/2.0 ) - Y_ADJ - ( deck_height/2.0 );
	double tot_d_width = ( deck_width * double( num_decks ) ) + ( DECK_SPACE * double( num_decks - 1 ) );
	rgb_color num_font_color = parameter_manager.get_color( "Deck Number Font Color" );
	rgb_color deck_color = parameter_manager.get_color( "Deck Color" );
	double left_loc = ( -tot_d_width/2.0 ) + deck_width/2.0;
	int i = 1
until
	i > num_decks
begin
	# Draw the outline around each deck
	outlines[i] = draw_outline( deck_width, deck_height, outline_color, DECK_LW );
	
	# Now make the boxes (deck face) that goes inside in outline
	inner_boxes[i] = new box( deck_height, deck_width, deck_color );
	
	# Now make a new deck number text
	number_texts[i] = new text();
	number_texts[i].set_font_color( num_font_color );
	number_texts[i].set_max_text_height( deck_height );
	number_texts[i].set_max_text_width( deck_width );
	number_texts[i].set_background_color( deck_color );
	number_texts[i].set_font_size( DECK_FONT_SIZE );
	number_texts[i].set_caption( string(i), true );

	# Add the outline and box to both the main and feedback pictures
	main_pic.add_part( outlines[i], left_loc, y_pos );
	main_pic.add_part( inner_boxes[i], left_loc, y_pos );
	fb_pic.add_part( outlines[i], left_loc, y_pos );
	fb_pic.add_part( inner_boxes[i], left_loc, y_pos );
	
	# Add the deck numbers to the main and feedback pictures
	main_pic.add_part( number_texts[i], left_loc, y_pos );
	fb_pic.add_part( number_texts[i], left_loc, y_pos );
	
	# Save the x/y position of each deck
	array<double> temp[2];
	temp[1] = left_loc;
	temp[2] = y_pos;
	deck_locs.add( temp );
	
	left_loc = left_loc + deck_width + DECK_SPACE;
	i = i + 1;
end;

# Text object telling participant to choose a deck. 
# This is placed immediately below (on the y-axis) the decks.
text choice_text = new text();
choice_text.set_max_text_width( used_screen_width * 0.8 );
choice_text.set_max_text_height( used_screen_height * 0.1 );
choice_text.set_caption( get_lang_item( lang, "Deck Caption" ), true );
double choice_y = deck_bottom - choice_text.height()/1.5;
main_pic.add_part( choice_text, 0.0, choice_y );
double choice_bottom = choice_y - choice_text.height()/2.0;

# Text object showing the participant's current total. 
# This is placed at the bottom of screen.
string unit_char = parameter_manager.get_string( "Unit Character" );
string total_caption = get_lang_item( lang, "Total Caption" ) + ":  " + unit_char + TOTAL_LABEL;
text total_text = new text();
total_text.set_background_color( parameter_manager.get_color( "Total Text Background Color" ) );
total_text.set_font_color( parameter_manager.get_color( "Total Text Color" ) );
total_text.set_caption( total_caption, true );
total_text.set_max_text_width( used_screen_width/2.0 );
total_text.set_max_text_height( used_screen_height * 0.1 );
total_text.set_caption( total_caption.replace( TOTAL_LABEL, "0" ), true );
total_text.set_height( total_text.height() * 1.33 );
total_text.set_width( total_text.width() * 1.33 );
total_text.redraw();
if ( parameter_manager.get_bool( "Show Current Total" ) ) then
	main_pic.add_part( total_text, 0, 0 );
	main_pic.set_part_y( main_pic.part_count(), -used_screen_height/2.0 + Y_ADJ, main_pic.BOTTOM_COORDINATE );
	
	fb_pic.add_part( total_text, 0, 0 );
	fb_pic.set_part_y( fb_pic.part_count(), -used_screen_height/2.0 + Y_ADJ, fb_pic.BOTTOM_COORDINATE );
end;

double max_info_height = choice_bottom + used_screen_height/2.0 - Y_ADJ;

# Text object for feedback display. Goes below the decks.
string info_caption = "";
info_caption.append( get_lang_item( lang, "Choice Caption" ) + ":  " + CHOICE_LABEL + "\n" );
info_caption.append( get_lang_item( lang, "Reward Caption" ) + ":  " + REWARD_LABEL + "\n" );
info_caption.append( get_lang_item( lang, "Penalty Caption" ) + ":  " + PENALTY_LABEL + "\n\n" );
info_caption.append( get_lang_item( lang, "Total Caption" ) + ":  " + unit_char + TOTAL_LABEL );

text fb_text = new text();
fb_text.set_caption( info_caption );
fb_text.set_background_color( parameter_manager.get_color( "Feedback Background Color" ) );
fb_text.set_font_color( parameter_manager.get_color( "Feedback Text Color" ) );
fb_text.set_max_text_height( max_info_height/1.75 );
fb_text.redraw();
fb_text.set_height( fb_text.height() * 1.25 );
fb_text.set_width( fb_text.width() ); # We add a little buffer around the text so it looks nicer
fb_text.set_max_text_width( fb_text.width() );
fb_text.redraw();
fb_pic.add_part( fb_text, 0.0, 0.0 );
fb_pic.set_part_y( fb_pic.part_count(), deck_bottom - Y_ADJ, main_pic.TOP_COORDINATE );

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

# --- sub check_deck

# Mouse setup 
mouse mse = response_manager.get_mouse( 1 );
bool show_cursor = parameter_manager.get_bool( "Show Cursor" );
begin
	# Set mouse restrictions
	int max_x = int( MOUSE_SENS * ( display_device.custom_width() / 2.0 ) );
	int max_y = int( MOUSE_SENS * ( display_device.custom_height() / 2.0 ) );
	mse.set_restricted( 1, true );
	mse.set_restricted( 2, true );
	mse.set_min_max( 1, -max_x, max_x );
	mse.set_min_max( 2, -max_y, max_y );
	
	# Add the cursor
	if ( show_cursor ) then
		main_pic.insert_part( 1, cursor, 0, 0 );
	end;
end;

sub
	int check_deck
begin
	mse.poll();
	loop
		int i = 1
	until
		i > num_decks
	begin
		double this_x = double( mse.x() ) / MOUSE_SENS;
		double this_y = double( mse.y() ) / MOUSE_SENS;
		if ( this_x < deck_locs[i][1] + ( deck_width/2.0 ) ) && 
			( this_x > deck_locs[i][1] - ( deck_width/2.0 ) ) &&
			( this_y < deck_locs[i][2] + ( deck_height/2.0 ) ) &&
			( this_y > deck_locs[i][2] - ( deck_height/2.0 ) ) then
			return i;
		end;
		i = i + 1;
	end;
	return 0
end;

# --- sub selected_deck
# --- displays the decks and mouse cursor until a choice is made
# --- returns the selected deck number

sub
	int selected_deck
begin
	# Variable to hold which deck was chosen
	int selected = 0;
	
	# Reset the mouse and make sure the cursor draws on top of everything
	if ( show_cursor ) then
		mse.set_xy( 0, 0 );
		main_pic.set_part_on_top( 1, true );
	end;
	
	# Loop until a legal response is made
	loop
		bool ok = false
	until
		ok
	begin
		loop
			int resp_ct = response_manager.total_response_count( 1 )
		until
			response_manager.total_response_count( 1 ) > resp_ct
		begin
			# First update the mouse cursor
			if ( show_cursor ) then
				# Update the cursor
				mse.poll();
				main_pic.set_part_x( 1, double( mse.x() ) / MOUSE_SENS );
				main_pic.set_part_y( 1, double( mse.y() ) / MOUSE_SENS );
				
				# Show the main picture
				main_pic.present();
				
				# Highlight a deck if one is selected
				selected = check_deck();
				loop
					int i = 1
				until
					i > num_decks
				begin
					if ( i == selected ) then
						outlines[i].set_line_color( selected_color );
					else
						outlines[i].set_line_color( outline_color );
					end;
					outlines[i].redraw();
					i = i + 1;
				end;
			else
				main_pic.present();
			end;
		end;
		
		# End if response was on a deck, otherwise update the response count and restart
		selected = check_deck();
		if ( selected > 0 ) then
			ok = true;
		end;
	end;
	return selected
end;

# --- sub show_feedback
# --- after deck selection, update the caption and show the feedback about gains/losses

sub
	show_feedback( int chosen_deck, int reward, int penalty, int new_total )
begin
	# First update the feedback caption with the relevant info
	string temp_caption = info_caption;
	temp_caption = temp_caption.replace( CHOICE_LABEL, string( chosen_deck ) );
	temp_caption = temp_caption.replace( REWARD_LABEL, string( reward ) );
	temp_caption = temp_caption.replace( PENALTY_LABEL, string( penalty ) );
	if ( new_total >= 0 ) then
		temp_caption = temp_caption.replace( TOTAL_LABEL, string( new_total ) );
	else
		temp_caption = temp_caption.replace( unit_char, "-"+unit_char );
		temp_caption = temp_caption.replace( TOTAL_LABEL, string( abs( new_total ) ) );
	end;
	fb_text.set_caption( temp_caption, true );
	
	# Update the total text caption
	total_text.set_caption( total_caption.replace( TOTAL_LABEL, string( new_total ) ), true );
	
	# Show the feedback trial
	fb_trial.present();
end;

# --- sub show_block 

bool shuffle_seqs = parameter_manager.get_bool( "Shuffle Sequences" );

# -- Set up info for summary stats -- #
array<int> RT_stats[0];
array<int> responses[num_decks];
int net_value = 0;

sub
	show_block( int num_trials, array<int,3>& seqs )
begin
	# Set up some counters
	array<int> ctrs[2][num_decks];
	ctrs[REW_IDX].fill( 1,0,1,0 );
	ctrs[PEN_IDX].fill( 1,0,1,0 );
	
	# Loop to present trials
	loop
		int curr_total = 0;
		int i = 1
	until
		i > num_trials
	begin
		# Let them choose a deck
		int RT = clock.time();
		int deck_choice = selected_deck();
		RT = clock.time() - RT;
		
		# Figure out the reward and penalty and update the total
		int rew_ctr = ctrs[REW_IDX][deck_choice];
		int pen_ctr = ctrs[PEN_IDX][deck_choice];
		int this_penalty = seqs[PEN_IDX][deck_choice][pen_ctr];
		int this_reward = seqs[REW_IDX][deck_choice][rew_ctr];
		curr_total = curr_total + this_penalty + this_reward;
		
		# Show the feedback
		show_feedback( deck_choice, this_reward, this_penalty, curr_total );

		# Info trial to store event info
		info_event.set_event_code( 
			MAIN_EVENT_CODE + ";" +
			string( i ) + ";" +
			string( deck_choice ) + ";" +
			string( RT ) + ";" +
			string( this_reward ) + ";" +
			string( this_penalty ) + ";" +
			string( curr_total )
		);
		info_trial.present();
		
		# Update the reward and penalty counters
		loop
			int j = 1
		until
			j > ctrs.count()
		begin
			ctrs[j][deck_choice] = ctrs[j][deck_choice] + 1;
			# If we've run out of rewards/penalties, then reset the counter
			# so we don't get an array index error.
			if ( ctrs[j][deck_choice] > seqs[j][deck_choice].count() ) then
				ctrs[j][deck_choice] = 1;
				if ( shuffle_seqs ) then
					seqs[j][deck_choice].shuffle();
				end;
			end;
			j = j + 1;
		end;
		
		# Update summary stats
		RT_stats.add( RT );
		responses[deck_choice] = responses[deck_choice] + 1;
		net_value = net_value + this_reward + this_penalty;
		
		i = i + 1;
	end;
end;

# --- Conditions and Trial Order --- #

# First set up an array containing the reward/penalty sequences
array<int> seq[2][num_decks][0];
loop
	int i = 1
until
	i > num_decks
begin
	parameter_manager.get_ints( "Deck " + string(i) + " Reward Sequence", seq[REW_IDX][i] );
	parameter_manager.get_ints( "Deck " + string(i) + " Penalty Sequence", seq[PEN_IDX][i] );
	
	# Exit if either sequence is empty
	if ( seq[REW_IDX][i].count() == 0 ) then
		exit( "Error: 'Deck " + string( i ) + " Reward Sequence' must contain at least one value." );
	end;
	if ( seq[PEN_IDX][i].count() == 0 ) then
		exit( "Error: 'Deck " + string( i ) + " Penalty Sequence' must contain at least one value." );
	end;

	# Randomize the sequences if necessary
	if ( shuffle_seqs ) then
		seq[REW_IDX][i].shuffle();
		seq[PEN_IDX][i].shuffle();
	end;
	i = i + 1;
end;

# --- Main Sequence --- #

int trial_ct = parameter_manager.get_int( "Trials" );
string instructions = get_lang_item( lang, "Instructions" );
instructions = instructions.replace( DECK_COUNT_LABEL, string( num_decks ) );

main_instructions( instructions );
show_block( trial_ct, seq );
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

	# Print the headings
	array<string> cond_headings[0];
	cond_headings.add( "Subject ID" );
	loop
		int i = 1
	until
		i > responses.count()
	begin
		cond_headings.add( "Deck " + string( i ) + " Choices" );
		i = i + 1;
	end;
	cond_headings.add( "Avg RT" );
	cond_headings.add( "Avg RT (SD)" );
	cond_headings.add( "Net Gain" );
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

	# Print the data
	out.print( "\n" + subj + TAB );
	loop
		int i = 1
	until
		i > responses.count()
	begin
		out.print( string( responses[i] ) + TAB );
		i = i + 1;
	end;
	out.print( round( arithmetic_mean( RT_stats ), 3 ) );
	out.print( TAB );
	out.print( round( sample_std_dev( RT_stats ), 3 ) );
	out.print( TAB );
	out.print( string( net_value ) + TAB );
	out.print( int_array_sum( responses ) );
	out.print( TAB );
	out.print( date_time() );

	# Close the file and exit
	out.close();
end;