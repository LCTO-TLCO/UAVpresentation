###########################################################################
#                                    Header										  #
###########################################################################
response_matching = simple_matching;
default_font_size = 48;
active_buttons = 4;
button_codes = 1,2,3,4; #yellow, green, blue, red
###########################################################################
#                                    SDL											  #
###########################################################################
begin;
#----------------------------------------------------------  Coller Trigger
box{color = 16,0,0;height= 5;width = 5;}box16;		#1		GO trial GO onset: left  middle box16
box{color = 32,0,0;height= 5;width = 5;}box32;		#2		GO trial GO onset: left  index
box{color = 48,0,0;height= 5;width = 5;}box48;		#3		GO trial GO onset: right index
box{color = 64,0,0;height= 5;width = 5;}box64;		#4		GO trial GO onset: right middle		
box{color = 80,0,0;height= 5;width = 5;}box80;		#5		SS trial GO onset: left  middle
box{color = 96,0,0;height= 5;width = 5;}box96;		#6		SS trial GO onset: left  index
box{color = 112,0,0;height= 5;width = 5;}box112;	#7		SS trial GO onset: right index
box{color = 128,0,0;height= 5;width = 5;}box128;	#8		SS trial GO onset: right middle
box{color = 144,0,0;height= 5;width = 5;}box144;	#9		SS trial STOP onset: left  middle
box{color = 160,0,0;height= 5;width = 5;}box160;	#10	SS trial STOP onset: left  index  
box{color = 176,0,0;height= 5;width = 5;}box176;	#11	SS trial STOP onset: right middle 
box{color = 192,0,0;height= 5;width = 5;}box192;	#12	SS trial STOP onset: right index   
box{color = 208,0,0;height= 5;width = 5;}box208;	#13	correct response / correct through
box{color = 224,0,0;height= 5;width = 5;}box224;	#14	incorrect response
box{color = 240,0,0;height= 5;width = 5;}box240;	#15	inhibition error

#-----------------------------------------------------------  Picture Parts
#BMPs
bitmap{filename = "target.bmp"; transparent_color = 255, 255, 255;}target;
bitmap{filename = "nontarget.bmp"; transparent_color = 255, 255, 255;}nontarget;
#XYcoordinates
$target1x=-240; $target1y=0;
$target2x=-100; $target2y=0;
$target3x= 100; $target3y=0;
$target4x= 240; $target4y=0;
$trigger_x=-962;$trigger_y=542;
#block
array {
   text { caption = "1/20ブロック目"; font_size=36; } block1;
   text { caption = "2/20ブロック目"; font_size=36; } block2;
   text { caption = "3/20ブロック目"; font_size=36; } block3;
   text { caption = "4/20ブロック目"; font_size=36; } block4;
   text { caption = "5/20ブロック目"; font_size=36; } block5;
	text { caption = "6/20ブロック目"; font_size=36; } block6;
   text { caption = "7/20ブロック目"; font_size=36; } block7;
   text { caption = "8/20ブロック目"; font_size=36; } block8;
   text { caption = "9/20ブロック目"; font_size=36; } block9;
   text { caption = "10/20ブロック目"; font_size=36; } block10;
	text { caption = "11/20ブロック目"; font_size=36; } block11;
	text { caption = "12/20ブロック目"; font_size=36; } block12;
	text { caption = "13/20ブロック目"; font_size=36; } block13;
	text { caption = "14/20ブロック目"; font_size=36; } block14;
	text { caption = "15/20ブロック目"; font_size=36; } block15;
	text { caption = "16/20ブロック目"; font_size=36; } block16;
	text { caption = "17/20ブロック目"; font_size=36; } block17;
	text { caption = "18/20ブロック目"; font_size=36; } block18;
	text { caption = "19/20ブロック目"; font_size=36; } block19;
	text { caption = "20/20ブロック目"; font_size=36; } block20;
} block_letters;

array {
   text { caption = "1/20ブロック目終了"; font_size=36; } block1_t;
   text { caption = "2/20ブロック目終了"; font_size=36; } block2_t;
   text { caption = "3/20ブロック目終了"; font_size=36; } block3_t;
   text { caption = "4/20ブロック目終了"; font_size=36; } block4_t;
   text { caption = "5/20ブロック目終了"; font_size=36; } block5_t;
	text { caption = "6/20ブロック目終了"; font_size=36; } block6_t;
   text { caption = "7/20ブロック目終了"; font_size=36; } block7_t;
   text { caption = "8/20ブロック目終了"; font_size=36; } block8_t;
   text { caption = "9/20ブロック目終了"; font_size=36; } block9_t;
   text { caption = "10/20ブロック目終了"; font_size=36; } block10_t;
	text { caption = "11/20ブロック目終了"; font_size=36; } block11_t;
	text { caption = "12/20ブロック目終了"; font_size=36; } block12_t;
	text { caption = "13/20ブロック目終了"; font_size=36; } block13_t;
	text { caption = "14/20ブロック目終了"; font_size=36; } block14_t;
	text { caption = "15/20ブロック目終了"; font_size=36; } block15_t;
	text { caption = "16/20ブロック目終了"; font_size=36; } block16_t;
	text { caption = "17/20ブロック目終了"; font_size=36; } block17_t;
	text { caption = "18/20ブロック目終了"; font_size=36; } block18_t;
	text { caption = "19/20ブロック目終了"; font_size=36; } block19_t;
	text { caption = "20/20ブロック目終了"; font_size=36; } block20_t;
} block_tale_letters;
#fixation
picture{
		text{caption="+"; font_size=48;};
		x=0; y=0;
		bitmap nontarget;
		x=$target1x; y=$target1y;
		bitmap nontarget;
		x=$target2x; y=$target2y;
		bitmap nontarget;
		x=$target3x; y=$target3y;
		bitmap nontarget;
		x=$target4x; y=$target4y;
	}pic_fix;

#Target_button left index	
picture{
		text{caption="+"; font_size=48;};
		x=0; y=0;
		bitmap nontarget;
		x=$target1x; y=$target1y;
		bitmap target;
		x=$target2x; y=$target2y;
		bitmap nontarget;
		x=$target3x; y=$target3y;
		bitmap nontarget;
		x=$target4x; y=$target4y;
	}pic_li;
#Target_button right index	
picture{
		text{caption="+"; font_size=48;};
		x=0; y=0;
		bitmap nontarget;
		x=$target1x; y=$target1y;
		bitmap nontarget;
		x=$target2x; y=$target2y;
		bitmap target;
		x=$target3x; y=$target3y;
		bitmap nontarget;
		x=$target4x; y=$target4y;
	}pic_ri;
#Target_button right middle	
picture{
		text{caption="+"; font_size=48;};
		x=0; y=0;
		bitmap nontarget;
		x=$target1x; y=$target1y;
		bitmap nontarget;
		x=$target2x; y=$target2y;
		bitmap nontarget;
		x=$target3x; y=$target3y;
		bitmap target;
		x=$target4x; y=$target4y;
	}pic_rm;


#-------------------------------------------------------------------  Sound
sound { wavefile { filename = "stop.wav"; }; } stop_signal;
#---------------------------------------------------------------------- TRIAL
#time
#time
$trigger_duration 		= 20;
$go_trial_duration 		= 500;
$go_stim_onset 			= 20;			#just after trigger (=$trigger_duration)
$go_stim_duration 		= 480;	  	#$trigger_duration分を引く
$go_after_stim_onset 	= 300;      #$trigger_duration+$go_stim_duration
$go_after_stim_duration = 200;		#$go_trial_duration-$go_stim_duration
$stop_stim_onset 			= 20;			#just after trigger (=$trigger_duration)
$init_ssd = 140;					
$stop_stim_duration 		= 120;		#$trigger_duration分を引く
$change_stim_onset 		= 20;			#just after trigger (=$trigger_duration)
$change_trial_duration 	= 600;
$change_stim_duration 	= 880;		#480;
$block_count = 1;
$block_count = 1;
#---------------------------------------------------------------------- INSTRUCTION
#---------------------------------------------------------------------- BLOCK HEAD
trial{
	trial_duration = forever;
	trial_type = correct_response;
	all_responses = false;
	stimulus_event{
		picture{
			text{caption="$block_countブロック目"; font_size=36;}text_block;
			x=0; y=0;
			
			text{caption="いずれかのボタンを押して始めてください"; font_size=24;};
			x=0; y=-200;
		}pic_block_head;
		target_button = 1,2,3,4;
		stimulus_time_in 	= 1000; 
		stimulus_time_out = never; 
	}event_block_head;
}trial_block_head;
#---------------------------------------------------------------------- BLOCK TALE
trial{
	trial_duration = forever;
	trial_type = correct_response;
	all_responses = false;
	stimulus_event{
		picture{
			text{caption="$block_countブロック目終了"; font_size=36;}text_block_tale;
			x=0; y=0;
			
			text{caption="設定を読み込みます。ボタンを押してしばらくお待ちください"; font_size=24;};
			x=0; y=-200;
		}pic_block_tale;
		target_button = 1,2,3,4;
		stimulus_time_in 	= 500; 
		stimulus_time_out = never; 
	}event_block_tale;
}trial_block_tale;
#---------------------------------------------------------------------- TASk TALE
trial{
	trial_duration = forever;
	trial_type = correct_response;
	all_responses = false;
	stimulus_event{
		picture{
			text{caption="全ブロック終了"; font_size=36;}text_task_tale;
			x=0; y=0;
			
			text{caption="しばらくお待ちください"; font_size=24;};
			x=0; y=-200;
		}pic_task_tale;
		target_button = 1,2,3,4;
		stimulus_time_in 	= 500; 
		stimulus_time_out = never; 
	}event_task_tale;
}trial_task_tale;
#---------------------------------------------------------------------- REST
#---------------------------------------------------------------------- FIX
trial{
	trial_duration=600;
	stimulus_event{
		picture pic_fix;
		time=0;
		code="fix";
	}event_fix;
	
}trial_fix;
#----------------------------------------------------------------------  GO
#trial go_l_mid
trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=$go_trial_duration;
	
	#trigger
	stimulus_event {
			#Target_button left middle	
			picture{
				#trigger
				box box16; #1
				x =$trigger_x; y =$trigger_y ;
			}pic_go;
			picture pic_lc;
		time=0;
		duration=$trigger_duration;
		#enable response
		target_button = 1;
		stimulus_time_in 	= 0;  					# assign response that occur
		stimulus_time_out = $go_trial_duration; 	# 0-1000 ms after the stimulus
		code = "GO trial GO stim left middle";
	}event_go_l_mid_t;
	
	#stim
	stimulus_event{
		picture{
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap target;
				x=$target1x; y=$target1y;
				bitmap nontarget;
				x=$target2x; y=$target2y;
				bitmap nontarget;
				x=$target3x; y=$target3y;
				bitmap nontarget;
				x=$target4x; y=$target4y;
			}pic_go_l_mid;
		time=$go_stim_onset;
		duration=$go_stim_duration;
	}event_go_l_mid;
	
	#fix_after_stim
	#stimulus_event{
	#	picture{
	#			text{caption="+"; font_size=48;};
	#			x=0; y=0;
	#			bitmap nontarget;
	#			x=$target1x; y=$target1y;
	#			bitmap nontarget;
	#			x=$target2x; y=$target2y;
	#			bitmap nontarget;
	#			x=$target3x; y=$target3y;
	#			bitmap nontarget;
	#			x=$target4x; y=$target4y;
	#		}pic_lm_after;
	#	time=$go_after_stim_onset;
	#	duration=$go_after_stim_duration;
	#}event_go_l_mid_after;
}trial_go_l_mid;

#trial_go_l_idx
trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=$go_trial_duration;
	
	#trigger
	stimulus_event {
			#Target_button left middle	
			picture{
				#trigger
				box box32; #2
				x =$trigger_x; y =$trigger_y ;
				#stim
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;
				bitmap target;
				x=$target2x; y=$target2y;
				bitmap nontarget;
				x=$target3x; y=$target3y;
				bitmap nontarget;
				x=$target4x; y=$target4y;
			}pic_go_l_idx_t;	#picture
		time=0;
		duration=$trigger_duration;
		#enable response
		target_button = 2;
		stimulus_time_in 	= 0;  					# assign response that occur
		stimulus_time_out = $go_trial_duration; 	# 0-1000 ms after the stimulus
		code = "GO trial GO stim left idx";
	}event_go_l_idx_t;
	
	#stim
	stimulus_event{
		picture{
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;
				bitmap target;
				x=$target2x; y=$target2y;
				bitmap nontarget;
				x=$target3x; y=$target3y;
				bitmap nontarget;
				x=$target4x; y=$target4y;
			}pic_go_l_idx;
		time=$go_stim_onset;
		duration=$go_stim_duration;
	}event_go_l_idx;
	
	#fix_after_stim
	#stimulus_event{
	#	picture{
	#			text{caption="+"; font_size=48;};
	#			x=0; y=0;
	#			bitmap nontarget;
	#			x=$target1x; y=$target1y;
	#			bitmap nontarget;
	#			x=$target2x; y=$target2y;
	#			bitmap nontarget;
	#			x=$target3x; y=$target3y;
	#			bitmap nontarget;
	#			x=$target4x; y=$target4y;
	#		}pic_lm_after;
	#	time=$go_after_stim_onset;
	#	duration=$go_after_stim_duration;
	#}event_go_l_mid_after;
}trial_go_l_idx;

#trial_go_r_idx
trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=$go_trial_duration;
	
	#trigger
	stimulus_event {
			#Target_button left middle	
			picture{
				#trigger
				box box48; #3
				x =$trigger_x; y =$trigger_y ;
				#stim
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;
				bitmap nontarget;
				x=$target2x; y=$target2y;
				bitmap target;
				x=$target3x; y=$target3y;
				bitmap nontarget;
				x=$target4x; y=$target4y;
			}pic_go_r_idx_t;	#picture
		time=0;
		duration=$trigger_duration;
		#enable response
		target_button = 3;
		stimulus_time_in 	= 0;  					# assign response that occur
		stimulus_time_out = $go_trial_duration; 	# 0-1000 ms after the stimulus
		code = "GO trial GO stim right idx";
	}event_go_r_idx_t;
	
	#stim
	stimulus_event{
		picture{
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;
				bitmap nontarget;
				x=$target2x; y=$target2y;
				bitmap target;
				x=$target3x; y=$target3y;
				bitmap nontarget;
				x=$target4x; y=$target4y;
			}pic_go_r_idx;
		time=$go_stim_onset;
		duration=$go_stim_duration;
	}event_go_r_idx;
	
	#fix_after_stim
	#stimulus_event{
	#	picture{
	#			text{caption="+"; font_size=48;};
	#			x=0; y=0;
	#			bitmap nontarget;
	#			x=$target1x; y=$target1y;
	#			bitmap nontarget;
	#			x=$target2x; y=$target2y;
	#			bitmap nontarget;
	#			x=$target3x; y=$target3y;
	#			bitmap nontarget;
	#			x=$target4x; y=$target4y;
	#		}pic_lm_after;
	#	time=$go_after_stim_onset;
	#	duration=$go_after_stim_duration;
	#}event_go_l_mid_after;
}trial_go_r_idx;

#trial_go_r_mid
trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=$go_trial_duration;
	
	#trigger
	stimulus_event {
			#Target_button left middle	
			picture{
				#trigger
				box box64; #4
				x =$trigger_x; y =$trigger_y ;
				#stim
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;
				bitmap nontarget;
				x=$target2x; y=$target2y;
				bitmap nontarget;
				x=$target3x; y=$target3y;
				bitmap target;
				x=$target4x; y=$target4y;
			}pic_go_r_mid_t;
		time=0;
		duration=$trigger_duration;
		#enable response
		target_button = 4;
		stimulus_time_in 	= 0;  					# assign response that occur
		stimulus_time_out = $go_trial_duration; 	# 0-1000 ms after the stimulus
		code = "GO trial GO stim right middle";
	}event_go_r_mid_t;
	
	#stim
	stimulus_event{
		picture{
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;
				bitmap nontarget;
				x=$target2x; y=$target2y;
				bitmap nontarget;
				x=$target3x; y=$target3y;
				bitmap target;
				x=$target4x; y=$target4y;
			}pic_go_r_mid;
		time=$go_stim_onset;
		duration=$go_stim_duration;
	}event_go_r_mid;
	
	#fix_after_stim
	#stimulus_event{
	#	picture{
	#			text{caption="+"; font_size=48;};
	#			x=0; y=0;
	#			bitmap nontarget;
	#			x=$target1x; y=$target1y;
	#			bitmap nontarget;
	#			x=$target2x; y=$target2y;
	#			bitmap nontarget;
	#			x=$target3x; y=$target3y;
	#			bitmap nontarget;
	#			x=$target4x; y=$target4y;
	#		}pic_lm_after;
	#	time=$go_after_stim_onset;
	#	duration=$go_after_stim_duration;
	#}event_go_l_mid_after;
}trial_go_r_mid;
#--------------------------------------------------------------------- STOP BEFORE TONE
# STOP SS_
#trial_stop_l_mid;
trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=$init_ssd;
	#trigger
	stimulus_event {
			#Target_button left middle	
			picture{
				#trigger
				box box80;		#5		SC trial GO onset: left  middle
				x =$trigger_x; y =$trigger_y ;
				#stim
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap target;
				x=$target1x; y=$target1y;
				bitmap nontarget;
				x=$target2x; y=$target2y;
				bitmap nontarget;
				x=$target3x; y=$target3y;
				bitmap nontarget;
				x=$target4x; y=$target4y;
			}pic_stop_l_mid_t;
		time=0;
		duration=$trigger_duration;
		#enable response
		response_active = true;
		stimulus_time_in 	= 0;  			# assign response that occur
		stimulus_time_out = $init_ssd; 	# 0-1000 ms after the stimulus
		code = "SC trial GO stim left middle";
	}event_t_stop_l_mid;
	#stim
	stimulus_event{
		picture{
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap target;
				x=$target1x; y=$target1y;
				bitmap nontarget;
				x=$target2x; y=$target2y;
				bitmap nontarget;
				x=$target3x; y=$target3y;
				bitmap nontarget;
				x=$target4x; y=$target4y;
			}pic_stop_l_mid;
		delta_time=20;
		#duration=trial_duration;
	}event_stop_l_mid;
}trial_stop_l_mid;

#trial_stop_l_idx;
trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=$init_ssd;
	#trigger
	stimulus_event {
			#Target_button left index	
			picture{
				#trigger
				box box96;		#6		SC trial GO onset: left  index
				x =$trigger_x; y =$trigger_y ;
				#stim
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;
				bitmap target;
				x=$target2x; y=$target2y;
				bitmap nontarget;
				x=$target3x; y=$target3y;
				bitmap nontarget;
				x=$target4x; y=$target4y;
			}pic_stop_l_idx_t;
		time=0;
		duration=$trigger_duration;
		#enable response
		response_active = true;
		stimulus_time_in 	= 0;  			# assign response that occur
		stimulus_time_out = $init_ssd; 	# 0-1000 ms after the stimulus
		code = "SC trial GO stim left index";
	}event_t_stop_l_idx;
	#stim
	stimulus_event{
		picture{
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;
				bitmap target;
				x=$target2x; y=$target2y;
				bitmap nontarget;
				x=$target3x; y=$target3y;
				bitmap nontarget;
				x=$target4x; y=$target4y;
			}pic_stop_l_idx;
		time=$stop_stim_onset;
		#duration=$stop_stim_duration;
	}event_stop_l_idx;	
}trial_stop_l_idx;

#trial_stop_r_idx;
trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=$init_ssd;
	#trigger
	stimulus_event {
			#Target_button right index
			picture{
				#trigger
				box box112;		#7		SC trial GO onset: right index
				x =$trigger_x; y =$trigger_y ;
				#stim
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;
				bitmap nontarget;
				x=$target2x; y=$target2y;
				bitmap target;
				x=$target3x; y=$target3y;
				bitmap nontarget;
				x=$target4x; y=$target4y;
			}pic_stop_r_idx_t;
		time=0;
		duration=$trigger_duration;
		#enable response
		response_active = true;
		stimulus_time_in 	= 0;  			# assign response that occur
		stimulus_time_out = $init_ssd; 	# 0-1000 ms after the stimulus
		code = "SC trial GO stim right index";
	}event_t_stop_r_idx;
	#stim
	stimulus_event{
		picture{
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;
				bitmap nontarget;
				x=$target2x; y=$target2y;
				bitmap target;
				x=$target3x; y=$target3y;
				bitmap nontarget;
				x=$target4x; y=$target4y;
			}pic_stop_r_idx;
		time=$stop_stim_onset;
		#duration=$stop_stim_duration;
	}event_stop_r_idx;	
}trial_stop_r_idx;

#trial_stop_r_mid;
trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=$init_ssd;
	#trigger
	stimulus_event {
			#Target_button right middle	
			picture{
				#trigger
				box box128;		#8		SC trial GO onset: right middle
				x =$trigger_x; y =$trigger_y ;
				#stim
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;
				bitmap nontarget;
				x=$target2x; y=$target2y;
				bitmap nontarget;
				x=$target3x; y=$target3y;
				bitmap target;
				x=$target4x; y=$target4y;
			}pic_stop_r_mid_t;
		time=0;
		duration=$trigger_duration;
		#enable response
		response_active = true;
		stimulus_time_in 	= 0;  			# assign response that occur
		stimulus_time_out = $init_ssd; 	# 0-1000 ms after the stimulus
		code = "SC trial GO stim right middle";
	}event_t_stop_r_mid;
	#stim
	stimulus_event{
		picture{
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;
				bitmap nontarget;
				x=$target2x; y=$target2y;
				bitmap nontarget;
				x=$target3x; y=$target3y;
				bitmap target;
				x=$target4x; y=$target4y;
			}pic_stop_r_mid;
		time=$stop_stim_onset;
		#duration=$stop_stim_duration;
	}event_stop_r_mid;
}trial_stop_r_mid;
#------------------------------------------------------------------- STOP WITH TONE(SS:STOP SIGNAL)
#trial_ss_l_mid;
trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=$change_trial_duration;
	
	#trigger
	stimulus_event {
			#Target_button left middle	
			picture{
				#trigger
				box box144;	#9		SS trial STOP onset: left  middle
				x =$trigger_x; y =$trigger_y ;
				#stim
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap target;
				x=$target1x; y=$target1y;						#target stim:left middle
				bitmap nontarget;					
				x=$target2x; y=$target2y;
				bitmap nontarget;
				x=$target3x; y=$target3y;
				bitmap nontarget;									
				x=$target4x; y=$target4y;
			}pic_ss_l_mid_t;
		time=0;
		duration=$trigger_duration;
		#enable response
		response_active = true;									#target button:none
		stimulus_time_in 	= 0;  							# assign response that occur
		stimulus_time_out = $trigger_duration; 	# 0-1000 ms after the stimulus
		code = "SS trial STOP stim left middle";
	}event_ss_l_mid_t;
	
	#sound
	stimulus_event {
		sound stop_signal;
		code = "sound";
		parallel = true;
		time=0;
	} sound_event_ss_l_mid;
	
	#stim
	stimulus_event{
		picture{
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap target;
				x=$target1x; y=$target1y;			#target stim:left middle
				bitmap nontarget;					
				x=$target2x; y=$target2y;
				bitmap nontarget;
				x=$target3x; y=$target3y;
				bitmap nontarget;							
				x=$target4x; y=$target4y;
			}pic_ss_l_mid;
		delta_time = 20;#$trigger_duration;
		duration=$change_stim_duration;
		response_active = true;	 #target button:none
		stimulus_time_in = $change_stim_onset;
		stimulus_time_out = $change_stim_duration;
	}event_ss_l_mid;
	
	#fix_after_stim
#	stimulus_event{
#		picture{
#				text{caption="+"; font_size=48;};
#				x=0; y=0;
#				bitmap nontarget;
#				x=$target1x; y=$target1y;
#				bitmap nontarget;
#				x=$target2x; y=$target2y;
#				bitmap nontarget;
#				x=$target3x; y=$target3y;
#				bitmap nontarget;
#				x=$target4x; y=$target4y;
#			}pic_ss_l_mid_after;
#		delta_time = $delta;
#		duration=$stop_after_stim_duration;
#		response_active = true;	 #target button:none
#		stimulus_time_in = 0;
#		stimulus_time_out = $stop_after_stim_duration;
#	}event_chg_l_mid_after;
}trial_ss_l_mid;
#trial_ss_l_idx;
trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=$change_trial_duration;
	
	#trigger
	stimulus_event {
			#Target_button left middle	
			picture{
				#trigger
				box box160;	#10	SS trial STOP onset: left  index
				x =$trigger_x; y =$trigger_y ;
				#stim
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;						
				bitmap target;					
				x=$target2x; y=$target2y;						#target stim:left index
				bitmap nontarget;
				x=$target3x; y=$target3y;
				bitmap nontarget;									
				x=$target4x; y=$target4y;
			}pic_ss_l_idx_t;
		time=0;
		duration=$trigger_duration;
		#enable response
		response_active = true;									#target button:none
		stimulus_time_in 	= 0;  							# assign response that occur
		stimulus_time_out = $trigger_duration; 	# 0-1000 ms after the stimulus
		code = "SS trial STOP stim left index";
	}event_ss_l_idx_t;
	
	#sound
	stimulus_event {
		sound stop_signal;
		code = "sound";
		parallel = true;
		time=0;
	} sound_event_ss_l_idx;
	
	#stim
	stimulus_event{
		picture{
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;			
				bitmap target;							#target stim:left index
				x=$target2x; y=$target2y;
				bitmap nontarget;
				x=$target3x; y=$target3y;
				bitmap nontarget;							
				x=$target4x; y=$target4y;
			}pic_ss_l_idx;
		delta_time = 20;#$trigger_duration;
		duration=$change_stim_duration;
		response_active = true;	 #target button:none
		stimulus_time_in = $change_stim_onset;
		stimulus_time_out = $change_stim_duration;
	}event_ss_l_idx;
	
	#fix_after_stim
#	stimulus_event{
#		picture{
#				text{caption="+"; font_size=48;};
#				x=0; y=0;
#				bitmap nontarget;
#				x=$target1x; y=$target1y;
#				bitmap nontarget;
#				x=$target2x; y=$target2y;
#				bitmap nontarget;
#				x=$target3x; y=$target3y;
#				bitmap nontarget;
#				x=$target4x; y=$target4y;
#			}pic_ss_l_idx_after;
#		delta_time = $delta;
#		duration=$stop_after_stim_duration;
#		response_active = true;	 #target button:none
#		stimulus_time_in = 0;
#		stimulus_time_out = $stop_after_stim_duration;
#	}event_chg_l_idx_after;
}trial_ss_l_idx;

#trial_ss_r_mid;
trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=$change_trial_duration;
	
	#trigger
	stimulus_event {
			#Target_button left middle	
			picture{
				#trigger
				box box176;	#11	SS trial STOP onset: right middle
				x =$trigger_x; y =$trigger_y ;
				#stim
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;
				bitmap nontarget;					
				x=$target2x; y=$target2y;
				bitmap nontarget;
				x=$target3x; y=$target3y;
				bitmap target;									#target stim:right middle
				x=$target4x; y=$target4y;
			}pic_ss_r_mid_t;
		time=0;
		duration=$trigger_duration;
		#enable response
		response_active = true;									#target button:right middle
		stimulus_time_in 	= 0;  							# assign response that occur
		stimulus_time_out = $trigger_duration; 	# 0-1000 ms after the stimulus
		code = "SC trial STOP stim right middle";
	}event_ss_r_mid_t;
	
	#sound
	stimulus_event {
		sound stop_signal;
		code = "sound";
		parallel = true;
		time=0;
	} sound_event_ss_r_mid;
	
	#stim
	stimulus_event{
		picture{
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;
				bitmap nontarget;					
				x=$target2x; y=$target2y;
				bitmap nontarget;
				x=$target3x; y=$target3y;
				bitmap target;							#target stim:left middle
				x=$target4x; y=$target4y;
			}pic_ss_r_mid;
		delta_time = 20;#$trigger_duration;
		duration=$change_stim_duration;
		response_active = true;	 #target button:right middle
		stimulus_time_in = $change_stim_onset;
		stimulus_time_out = $change_stim_duration;
	}event_ss_r_mid;
	
#	stimulus_event{
#		picture{
#				text{caption="+"; font_size=48;};
#				x=0; y=0;
#				bitmap nontarget;
#				x=$target1x; y=$target1y;
#				bitmap nontarget;
#				x=$target2x; y=$target2y;
#				bitmap nontarget;
#				x=$target3x; y=$target3y;
#				bitmap nontarget;
#				x=$target4x; y=$target4y;
#			}pic_ss_r_mid_after;
#		delta_time = $delta;
#		duration=$stop_after_stim_duration;
#		response_active = true;	 #target button:none
#		stimulus_time_in = 0;
#		stimulus_time_out = $stop_after_stim_duration;
#	}event_chg_r_mid_after;
}trial_ss_r_mid;

#trial_ss_r_idx;
trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=$change_trial_duration;
	
	#trigger
	stimulus_event {
			#Target_button left middle	
			picture{
				#trigger
				box box192;	#12	SS trial STOP onset: right index
				x =$trigger_x; y =$trigger_y ;
				#stim
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;
				bitmap nontarget;					
				x=$target2x; y=$target2y;
				bitmap target;								#target stim:right index
				x=$target3x; y=$target3y;
				bitmap nontarget;									
				x=$target4x; y=$target4y;
			}pic_ss_r_idx_t;
		time=0;
		duration=$trigger_duration;
		#enable response
		response_active = true;								#target button:right index
		stimulus_time_in 	= 0;  							# assign response that occur
		stimulus_time_out = $trigger_duration; 	# 0-1000 ms after the stimulus
		code = "SC trial STOP stim right idx";
	}event_ss_r_idx_t;
	
	#sound
	stimulus_event {
		sound stop_signal;
		code = "sound";
		parallel = true;
		time=0;
	} sound_event_ss_r_idx;
	
	#stim
	stimulus_event{
		picture{
				text{caption="+"; font_size=48;};
				x=0; y=0;
				bitmap nontarget;
				x=$target1x; y=$target1y;
				bitmap nontarget;					
				x=$target2x; y=$target2y;
				bitmap target;
				x=$target3x; y=$target3y;
				bitmap nontarget;							#target stim:right index
				x=$target4x; y=$target4y;
			}pic_ss_r_idx;
		delta_time = 20;#$trigger_duration;
		duration=$change_stim_duration;
		response_active = true;									#target stim:right index
		stimulus_time_in = $change_stim_onset;
		stimulus_time_out = $change_stim_duration;
	}event_ss_r_idx;
	
#	stimulus_event{
#		picture{
#				text{caption="+"; font_size=48;};
#				x=0; y=0;
#				bitmap nontarget;
#				x=$target1x; y=$target1y;
#				bitmap nontarget;
#				x=$target2x; y=$target2y;
#				bitmap nontarget;
#				x=$target3x; y=$target3y;
#				bitmap nontarget;
#				x=$target4x; y=$target4y;
#			}pic_ss_r_idx_after;
#		delta_time = $delta;
#		duration=$stop_after_stim_duration;
#		response_active = true;	 #target button:none
#		stimulus_time_in = 0;
#		stimulus_time_out = $stop_after_stim_duration;
#	}event_chg_r_idx_after;
}trial_ss_r_idx;
#--------------------------------------------------------- RESPONSE TRIGGER
#XYcoordinates

#Correct
trial{
	#trial settings
	all_responses = false;
	#trial duration
	trial_duration=20;
	#trigger
	stimulus_event{
		picture{
			text{caption="+"; font_size=48;};
			x=0; y=0;
			bitmap nontarget;
			x=$target1x; y=$target1y;
			bitmap nontarget;
			x=$target2x; y=$target2y;
			bitmap nontarget;
			x=$target3x; y=$target3y;
			bitmap nontarget;
			x=$target4x; y=$target4y;
			box box208; #13
			x =$trigger_x; y =$trigger_y ;
		}pic_t_correct;
		time=0;
		duration=20;
		code="correct response";
	}event_t_correct;
}trial_t_correct;

#Incorrect
trial{
	#trial settings
	all_responses = false;
	#trial duration
	trial_duration=20;
	#trigger
	stimulus_event{
		picture{
			text{caption="+"; font_size=48;};
			x=0; y=0;
			bitmap nontarget;
			x=$target1x; y=$target1y;
			bitmap nontarget;
			x=$target2x; y=$target2y;
			bitmap nontarget;
			x=$target3x; y=$target3y;
			bitmap nontarget;
			x=$target4x; y=$target4y;
			box box224; #14
			x =$trigger_x; y =$trigger_y ;
		}pic_t_incorrect;
		time=0;
		duration=20;
		code="incorrect response";
	}event_t_incorrect;
}trial_t_incorrect;

#inhibion error
trial{
	#trial settings
	all_responses = false;
	#trial duration
	trial_duration=20;
	#trigger
	stimulus_event{
		picture{
			text{caption="+"; font_size=48;};
			x=0; y=0;
			bitmap nontarget;
			x=$target1x; y=$target1y;
			bitmap nontarget;
			x=$target2x; y=$target2y;
			bitmap nontarget;
			x=$target3x; y=$target3y;
			bitmap nontarget;
			x=$target4x; y=$target4y;
			box box240; #15
			x =$trigger_x; y= $trigger_y;
		}pic_t_error_inhibit;
		time=0;
		duration=20;
		code="inhibition error";
	}event_t_error_inhibit;
}trial_t_error_inhibit;

#---------------------------------------------------------        feedback
text {caption = "正解";} good;
text {caption = "不正解";} oops;
text {caption = "もっと速く！";} missed;
text {caption = "お手付き";} f_a;
text {caption = "other";} other;

trial{
	trial_duration=300;
	stimulus_event{
		picture{text good; x=0; y=0;
		} feedback_pic;
		time=0;
		duration=300;
		code = "feedback";
	}event_feedback;
} feedback_trial;
###########################################################################
#                                    PCL											  #
###########################################################################
begin_pcl;
#------------------------------------------------------------------- PARAMS
#task manager
int max_block=20;							#10
int max_trial=120;							#96
array<int>select_trial[max_trial];	#1:go_l_mid; #2:go_l_idx; #3:go_l_idx; #4:go_r_mid;
												#5:sc_lm_rm; #6:sc_li_ri; #7:sc_rm_ri; #8:sc_ri_rm;
array<int>trial_checker[max_trial];
int s_checker=0;
int fix_jitter;

#SSD
int initial_ssd = 140;
int SS_ssd = initial_ssd;
int min_ssd = 20;
int max_ssd = 300;
int ssd_adjuster = 20;


#1 block分のtrial listを作る。後で派手に変える。



#loop int i=1 until i>max_trial/8 begin
#	select_trial.add(1);	#1:go_l_mid;
#	select_trial.add(2);	#2:go_l_idx;
#	select_trial.add(3); #3:go_l_idx;
#	select_trial.add(4); #4:go_r_mid;
#	select_trial.add(5); #5:ss_lm;
#	select_trial.add(6); #6:sc_li;
#	select_trial.add(7); #7:sc_rm;
#	select_trial.add(8); #8:sc_ri;
#	i=i+1;
#end;

loop int i=1 until i>9 begin
	select_trial.add(1);	#1:go_l_mid;
	select_trial.add(2);	#2:go_l_idx;
	select_trial.add(3); #3:go_l_idx;
	select_trial.add(4); #4:go_r_mid;
	i=i+1;
end;

loop int x=1 until x>6 begin
	select_trial.add(5); #5:ss_lm;
	select_trial.add(6); #6:sc_li;
	select_trial.add(7); #7:sc_rm;
	select_trial.add(8); #8:sc_ri;
	x=x+1;
end;

##############################################################################
#The seq_ok subroutine takes as arguments a 1d integer array that
#specifies the sequence and an integer that specifies the maximum
#number of times a particular item should be allowed in a row in the sequence
#The return value is a bool. If the sequence is acceptable, the subroutine
#will return true. Otherwise, it will return false
sub bool seq_ok( array<int, 1>& seq, int max_inarow )
begin
   #The loop checks each item in turn. It keeps track of the previous item in the
	#array and the number of times the same item has been seen in a row.
   loop int i = 1; int last = 0; int inarow = 0; int buff = 0; until i > seq.count()
   begin
		#改変パート：GOを1、STOPを2とする
		if seq[i] >=5  then
			buff=5;	
		else
			buff=seq[i];
		end;
      #If the current item in the sequence is the same as the previous item in the sequence
      if buff ==5  then
         #Increment the value of inarow by 1
         inarow = inarow + 1;
      else
         #Otherwise, set the value of inarow to 1, as it is the first item in a row of this value
         inarow = 1;
      end;
      #If we have exceeded our limit
      if inarow >= max_inarow then
         #Return a value of false
         return false;
      end;
      #Set the value of last to the current value for the next iteration of the loop
      last = buff;
      #Increment i
      i = i + 1;
   end;
   #If we get this far without returning false, then return true
   return true;
end;
##############################################################################

loop int blk = 1 until blk>max_block begin #loop int blk 
#ランダマイズ
#select_trial.shuffle();

##############################################################################

#Run a loop that shuffles the which_stim array until the which_stim array
#fits the randomization criterion
loop select_trial.shuffle() until seq_ok( select_trial, 3 )
begin
   select_trial.shuffle();
end;
##############################################################################


pic_block_head.set_part(1, block_letters[blk]);
trial_block_head.present();

loop int j=1 until j>select_trial.count() begin
		
	if(select_trial[j]==1)then #--------------------------------------------------------------------------------1:go_l_mid
		#trial start
		#event_fix.set_event_code("fix " + string(j));
		fix_jitter = random(500, 700);
		trial_fix.set_duration(fix_jitter);
		trial_fix.present();
		trial_go_l_mid.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		if last.type() == stimulus_incorrect then
				#feedback_pic.set_part(1, oops);	#debug feedback
				#feedback_trial.present();			#debug feedback
				trial_t_incorrect.present();	
		elseif last.type() == stimulus_miss then
			feedback_pic.set_part(1, missed);	#debug feedback
			event_feedback.set_event_code("omission");
			feedback_trial.present();				#debug feedback
		elseif last.type() == stimulus_hit then
			#feedback_pic.set_part(1, good);		#debug feedback
			#feedback_trial.present();				#debug feedback
			trial_t_correct.present();
		elseif last.type() == stimulus_false_alarm then
			#feedback_pic.set_part(1, f_a);		#debug feedback
			#feedback_trial.present();				#debug feedback
			trial_t_error_inhibit.present();
		elseif last.type() == stimulus_other then
			#feedback_pic.set_part(1, other);		#debug feedback
			#feedback_trial.present();				#debug feedback
		end;
	elseif(select_trial[j]==2)then #--------------------------------------------------------------------------------2:go_l_idx;
		#trial start
		#event_fix.set_event_code("fix " + string(j));
		fix_jitter = random(500, 700);
		trial_fix.set_duration(fix_jitter);
		trial_fix.present();
		trial_go_l_idx.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		if last.type() == stimulus_incorrect then
			#feedback_pic.set_part(1, oops);		#debug feedback
			#feedback_trial.present();				#debug feedback
			trial_t_incorrect.present();	
		elseif last.type() == stimulus_miss then
			feedback_pic.set_part(1, missed);	#debug feedback
			event_feedback.set_event_code("omission");
			feedback_trial.present();				#debug feedback
		elseif last.type() == stimulus_hit then
			#feedback_pic.set_part(1, good);		#debug feedback
			#feedback_trial.present();				#debug feedback
			trial_t_correct.present();
		elseif last.type() == stimulus_false_alarm then
			#feedback_pic.set_part(1, f_a);		#debug feedback
			#feedback_trial.present();				#debug feedback
			trial_t_error_inhibit.present();
		elseif last.type() == stimulus_other then
			#feedback_pic.set_part(1, other);		#debug feedback
			#feedback_trial.present();				#debug feedback
		end;
	elseif(select_trial[j]==3)then #--------------------------------------------------------------------------------3:go_r_idx; 
		#trial start
		#event_fix.set_event_code("fix " + string(j));
		fix_jitter = random(500, 700);
		trial_fix.set_duration(fix_jitter);
		trial_fix.present();
		trial_go_r_idx.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		if last.type() == stimulus_incorrect then
			#feedback_pic.set_part(1, oops);		#debug feedback
			#feedback_trial.present();				#debug feedback
			trial_t_incorrect.present();			#14 incorrect
		elseif last.type() == stimulus_miss then
			feedback_pic.set_part(1, missed);	#debug feedback
			event_feedback.set_event_code("omission");
			feedback_trial.present();				#debug feedback
		elseif last.type() == stimulus_hit then
			#feedback_pic.set_part(1, good);		#debug feedback
			#feedback_trial.present();				#debug feedback
			trial_t_correct.present();				#13 correct
		elseif last.type() == stimulus_false_alarm then
			#feedback_pic.set_part(1, f_a);		#debug feedback
			#feedback_trial.present();				#debug feedback
			trial_t_error_inhibit.present();		#15 inhibition error
		elseif last.type() == stimulus_other then
			#feedback_pic.set_part(1, other);		#debug feedback
			#feedback_trial.present();				#debug feedback
		end;
	elseif(select_trial[j]==4)then #--------------------------------------------------------------------------------4:go_r_mid; 
		#trial start
		#event_fix.set_event_code("fix " + string(j));
		fix_jitter = random(500, 700);
		trial_fix.set_duration(fix_jitter);
		trial_fix.present();
		trial_go_r_mid.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		if last.type() == stimulus_incorrect then
			#feedback_pic.set_part(1, oops);		#debug feedback
			#feedback_trial.present();				#debug feedback
			trial_t_incorrect.present();			#14 incorrect
		elseif last.type() == stimulus_miss then
			#feedback_pic.set_part(1, missed);	#debug feedback
			event_feedback.set_event_code("omission");
			feedback_trial.present();				#debug feedback
		elseif last.type() == stimulus_hit then
			#feedback_pic.set_part(1, good);		#debug feedback
			#feedback_trial.present();				#debug feedback
			trial_t_correct.present();				#13 correct
		elseif last.type() == stimulus_false_alarm then
			#feedback_pic.set_part(1, f_a);		#debug feedback
			#feedback_trial.present();				#debug feedback
			trial_t_error_inhibit.present();		#15 inhibition error
		elseif last.type() == stimulus_other then
			#feedback_pic.set_part(1, other);		#debug feedback
			#feedback_trial.present();				#debug feedback
		end;
	elseif(select_trial[j]==5)then#--------------------------------------------------------------------------------5:SS_lm;
		#set latest SSD
		trial_stop_l_mid.set_duration(SS_ssd);
		#set trigger
		pic_stop_l_mid_t.set_part(1,box80);		#5		SC trial GO onset: left  middle;
		#stop trial start
		#event_fix.set_event_code("fix " + string(j));
		fix_jitter = random(500, 700);
		trial_fix.set_duration(fix_jitter);
		trial_fix.present();
		trial_stop_l_mid.present();
		stimulus_data stop = stimulus_manager.last_stimulus_data();
		if stop.type() == stimulus_false_alarm then
			#feedback_pic.set_part(1, f_a);		#debug feedback
			#feedback_trial.present();				#debug feedback
			event_t_error_inhibit.set_event_code("inhibition error SS ssd" + string(SS_ssd));
			trial_t_error_inhibit.present();
			if SS_ssd <= min_ssd then		#SSD modulation
				SS_ssd = min_ssd;
			else
			SS_ssd = SS_ssd-ssd_adjuster;
			end;
		elseif stop.type() == stimulus_other then #Stop Signal Presentation
			sound_event_ss_l_mid.set_event_code("correct SS ssd " + string(SS_ssd));
			#change trial start
			trial_ss_l_mid.present();
			stimulus_data ss = stimulus_manager.last_stimulus_data();
			if ss.type() == stimulus_other then
				#feedback_pic.set_part(1, good);		#debug feedback
				#feedback_trial.present();				#debug feedback
				trial_t_correct.present();
				if SS_ssd >= max_ssd then			#SSD modulation
					SS_ssd = max_ssd;
				else
					SS_ssd = SS_ssd+ssd_adjuster;
				end;
			elseif ss.type() == stimulus_false_alarm then
				int last_r = response_manager.last_response();
				if last_r == 1 then						#GO stim is leftt middle
					#feedback_pic.set_part(1, f_a);	#debug feedback
					#feedback_trial.present();			#debug feedback
					event_t_error_inhibit.set_event_code("inhibition error SS ssd" + string(SS_ssd));
					trial_t_error_inhibit.present();
					if SS_ssd <= min_ssd then		#SSD modulation
						SS_ssd = min_ssd;
					else
						SS_ssd = SS_ssd-ssd_adjuster;
					end;
				else
					#feedback_pic.set_part(1, oops);	#debug feedback
					#feedback_trial.present();			#debug feedback
					sound_event_ss_l_mid.set_event_code("incorrect SS ssd " + string(SS_ssd));
					trial_t_incorrect.present();
					if SS_ssd <= min_ssd then		#SSD modulation
						SS_ssd = min_ssd;
					else
						SS_ssd = SS_ssd-ssd_adjuster;
					end;
				end;
			end;
		end;
	elseif(select_trial[j]==6)then#--------------------------------------------------------------------------------6:sc_li;
		#set latest SSD
		trial_stop_l_idx.set_duration(SS_ssd);
		#set trigger
		pic_stop_l_idx_t.set_part(1,box96);		#6		SC trial GO onset: left  index box96;		
		#stop trial start
		#event_fix.set_event_code("fix " + string(j));
		fix_jitter = random(500, 700);
		trial_fix.set_duration(fix_jitter);
		trial_fix.present();
		trial_stop_l_idx.present();
		stimulus_data stop = stimulus_manager.last_stimulus_data();
		if stop.type() == stimulus_false_alarm then
			#feedback_pic.set_part(1, f_a);		#debug feedback
			#feedback_trial.present();				#debug feedback
			event_t_error_inhibit.set_event_code("inhibition error SS ssd" + string(SS_ssd));
			trial_t_error_inhibit.present();
		elseif stop.type() == stimulus_other then
			#set trigger
			sound_event_ss_l_idx.set_event_code("correct SS ssd " + string(SS_ssd));
			#change trial start
			trial_ss_l_idx.present();
			stimulus_data chg = stimulus_manager.last_stimulus_data();
			if chg.type() == stimulus_other then
				#feedback_pic.set_part(1, good);		#debug feedback
				#feedback_trial.present();				#debug feedback
				trial_t_correct.present();
				if SS_ssd >= max_ssd then				#SSD modulation
					SS_ssd = max_ssd;
				else
					SS_ssd = SS_ssd+ssd_adjuster;
				end;
			elseif chg.type() == stimulus_false_alarm then
				int last_r = response_manager.last_response();
				if last_r == 2 then						#GO stim is leftt index
					#feedback_pic.set_part(1, f_a);	#debug feedback
					#feedback_trial.present();			#debug feedback
					event_t_error_inhibit.set_event_code("inhibition error SS ssd" + string(SS_ssd));
					trial_t_error_inhibit.present();
					if SS_ssd <= min_ssd then		#SSD modulation
						SS_ssd = min_ssd;
					else
						SS_ssd = SS_ssd-ssd_adjuster;
					end;
				else
					#feedback_pic.set_part(1, oops);	#debug feedback
					#feedback_trial.present();			#debug feedback
					event_t_error_inhibit.set_event_code("incorrect SS ssd" + string(SS_ssd));
					trial_t_incorrect.present();
					if SS_ssd <= min_ssd then		#SSD modulation
						SS_ssd = min_ssd;
					else
						SS_ssd = SS_ssd-ssd_adjuster;
					end;
				end;
			end;
		end
		elseif(select_trial[j]==7)then#--------------------------------------------------------------------------------#7:ss_rm;
		#set latest SSD
		trial_stop_r_mid.set_duration(SS_ssd);
		#set trigger
		#pic_stop_l_idx_t.set_part(1,box96);		#8		SC trial GO onset: right middle	
		#stop trial start
		#event_fix.set_event_code("fix " + string(j));
		fix_jitter = random(500, 700);
		trial_fix.set_duration(fix_jitter);
		trial_fix.present();
		trial_stop_r_mid.present();
		stimulus_data stop = stimulus_manager.last_stimulus_data();
		if stop.type() == stimulus_false_alarm then
			#feedback_pic.set_part(1, f_a);		#debug feedback
			#feedback_trial.present();			#debug feedback
			event_t_error_inhibit.set_event_code("inhibition error SS ssd" + string(SS_ssd));
			trial_t_error_inhibit.present();
			if SS_ssd <= min_ssd then		#SSD modulation
				SS_ssd = min_ssd;
			else
				SS_ssd = SS_ssd-ssd_adjuster;
			end;
		elseif stop.type() == stimulus_other then
			sound_event_ss_r_idx.set_event_code("correct SS ssd " + string(SS_ssd));
			#change trial start
			trial_ss_r_mid.present();
			stimulus_data ss = stimulus_manager.last_stimulus_data();
			if ss.type() == stimulus_other then
				#feedback_pic.set_part(1, good);		#debug feedback
				#feedback_trial.present();				#debug feedback
				trial_t_correct.present();
				if SS_ssd >= max_ssd then				#SSD modulation
					SS_ssd = max_ssd;
				else
					SS_ssd = SS_ssd+ssd_adjuster;
				end;
			elseif ss.type() == stimulus_false_alarm then
				int last_r = response_manager.last_response();
				if last_r == 4 then						#GO stim is right middle
					#feedback_pic.set_part(1, f_a);	#debug feedback
					#feedback_trial.present();			#debug feedback
					event_t_error_inhibit.set_event_code("inhibition error SS ssd" + string(SS_ssd));
					trial_t_error_inhibit.present();
					if SS_ssd <= min_ssd then		#SSD modulation
						SS_ssd = min_ssd;
					else
						SS_ssd = SS_ssd-ssd_adjuster;
					end;
				else
					#feedback_pic.set_part(1, oops);	#debug feedback
					#feedback_trial.present();			#debug feedback
					event_t_error_inhibit.set_event_code("incorrect SS ssd" + string(SS_ssd));
					trial_t_incorrect.present();
					if SS_ssd <= min_ssd then		#SSD modulation
						SS_ssd = min_ssd;
					else
						SS_ssd = SS_ssd-ssd_adjuster;
					end;
				end;
			end;
		end;
	#elseif
		elseif(select_trial[j]==8)then#--------------------------------------------------------------------------------#8:sc_ri;
		#set latest SSD
		trial_stop_r_idx.set_duration(SS_ssd);
		#set trigger
		#pic_stop_l_idx_t.set_part(1,box96);		#8		SC trial GO onset: right middle	
		#stop trial start
		#event_fix.set_event_code("fix " + string(j));
		fix_jitter = random(500, 700);
		trial_fix.set_duration(fix_jitter);
		trial_fix.present();
		trial_stop_r_idx.present();
		stimulus_data stop = stimulus_manager.last_stimulus_data();
		if stop.type() == stimulus_false_alarm then
			#feedback_pic.set_part(1, f_a);		#debug feedback
			#feedback_trial.present();				#debug feedback
			event_t_error_inhibit.set_event_code("inhibition error SS ssd" + string(SS_ssd));
			trial_t_error_inhibit.present();
			if SS_ssd <= min_ssd then		#SSD modulation
				SS_ssd = min_ssd;
			else
				SS_ssd = SS_ssd-ssd_adjuster;
			end;
		elseif stop.type() == stimulus_other then
			sound_event_ss_r_mid.set_event_code("correct SS ssd " + string(SS_ssd));
			#change trial start
			trial_ss_r_idx.present();
			stimulus_data ss = stimulus_manager.last_stimulus_data();
			if ss.type() == stimulus_other then
				#feedback_pic.set_part(1, good);		#debug feedback
				#feedback_trial.present();				#debug feedback
				trial_t_correct.present();
				if SS_ssd >= max_ssd then				#SSD modulation
					SS_ssd = max_ssd;
				else
					SS_ssd = SS_ssd+ssd_adjuster;
				end;
			elseif ss.type() == stimulus_false_alarm then
				int last_r = response_manager.last_response();
				if last_r == 3 then						#GO stim is right index
					#feedback_pic.set_part(1, f_a);	#debug feedback
					#feedback_trial.present();			#debug feedback
					event_t_error_inhibit.set_event_code("inhibition error SS ssd" + string(SS_ssd));
					trial_t_error_inhibit.present();
					if SS_ssd <= min_ssd then		#SSD modulation
						SS_ssd = min_ssd;
					else
						SS_ssd = SS_ssd-ssd_adjuster;
					end;
				else
					#feedback_pic.set_part(1, oops);	#debug feedback
					#feedback_trial.present();			#debug feedback
					event_t_error_inhibit.set_event_code("incorrect SS ssd" + string(SS_ssd));
					trial_t_incorrect.present();
					if SS_ssd <= min_ssd then		#SSD modulation
						SS_ssd = min_ssd;
					else
						SS_ssd = SS_ssd-ssd_adjuster;
					end;
				end;
			end;
		end;
	end;
	j=j+1;
end;
	trial_fix.present();
	pic_block_tale.set_part(1, block_tale_letters[blk]);
	trial_block_tale.present();
	blk=blk+1;
end; #loop int blk

trial_task_tale.present();