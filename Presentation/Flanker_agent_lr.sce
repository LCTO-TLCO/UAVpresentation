###########################################################################
#                                    Header										  #
###########################################################################
response_matching = simple_matching;
default_font_size = 48;
active_buttons = 3;
button_codes = 1,2,3; #left, right, space
#write_codes =true;

###########################################################################
#                                    SDL											  #
###########################################################################
begin;
#----------------------------------------------------------  Coller Trigger
box{color = 12,0,0;height= 5;width = 5;}box12;		#1		L <
box{color = 14,0,0;height= 5;width = 5;}box14;		#2		R >
box{color = 16,0,0;height= 5;width = 5;}box16;		#3		ANS_L_L
box{color = 32,0,0;height= 5;width = 5;}box32;		#4		ANS_R_R
box{color = 48,0,0;height= 5;width = 5;}box48;		#5
box{color = 64,0,0;height= 5;width = 5;}box64;		#6
box{color = 100,0,0;height= 5;width = 5;}box100;	#7
box{color = 120,0,0;height= 5;width = 5;}box120;	#8
box{color = 128,0,0;height= 5;width = 5;}box128;	#9
box{color = 208,0,0;height= 5;width = 5;}box208;	#10		correct response
box{color = 224,0,0;height= 5;width = 5;}box224;	#11		incorrect response
box{color = 240,0,0;height= 5;width = 5;}box240;	#12		omission

#XYcoordinates
$target1x=-240; $target1y=0;
$target2x=-100; $target2y=0;
$target3x= 100; $target3y=0;
$target4x= 240; $target4y=0;
$trigger_x=-962;$trigger_y=542;

#block
array {
   text { caption = "1/10ブロック目"; font_size=36; } block1;
   text { caption = "2/10ブロック目"; font_size=36; } block2;
   text { caption = "3/10ブロック目"; font_size=36; } block3;
   text { caption = "4/10ブロック目"; font_size=36; } block4;
   text { caption = "5/10ブロック目"; font_size=36; } block5;
	text { caption = "6/10ブロック目"; font_size=36; } block6;
   text { caption = "7/10ブロック目"; font_size=36; } block7;
   text { caption = "8/10ブロック目"; font_size=36; } block8;
   text { caption = "9/10ブロック目"; font_size=36; } block9;
   text { caption = "10/10ブロック目"; font_size=36; } block10;
} block_letters;

array {
   text { caption = "1/10ブロック目終了"; font_size=36; } block1_t;
   text { caption = "2/10ブロック目終了"; font_size=36; } block2_t;
   text { caption = "3/10ブロック目終了"; font_size=36; } block3_t;
   text { caption = "4/10ブロック目終了"; font_size=36; } block4_t;
   text { caption = "5/10ブロック目終了"; font_size=36; } block5_t;
	text { caption = "6/10ブロック目終了"; font_size=36; } block6_t;
   text { caption = "7/10ブロック目終了"; font_size=36; } block7_t;
   text { caption = "8/10ブロック目終了"; font_size=36; } block8_t;
	text { caption = "9/10ブロック目終了"; font_size=36; } block9_t;
	text { caption = "10/10ブロック目終了"; font_size=36; } block10_t;
} block_tale_letters;

text { caption = "正反応率（％）："; font_size=36; } p_correct_t;
text { caption = "遅延反応率（％）："; font_size=36; } p_omission_t; 


# arrow
text{
caption="←";
    font_size=70;
    background_color=70,70,70;
    font_color=0,0,0;
}text_left_arrow_off;
text{
    caption="→";
    font_size=70;
    background_color=70,70,70;
    font_color=0,0,0;
}text_right_arrow_off;
text{
    caption="←";
    font_size=70;
    background_color=255,255,0;
    font_color=0,0,0;
}text_left_arrow_on;
text{
    caption="→";
    font_size=70;
    background_color=255,255,0;
    font_color=0,0,0;
}text_right_arrow_on;

text{
    font_size=48;
    caption="*";
}text_modify;

#Target_button left congruent
$stim_fontsize 	= 96;

# TODO fix arrow pic l/r
#fixation
text{caption="◆"; font_size=48;}fix_text;
picture{
    text fix_text;
        x=0; y=0;

    text text_right_arrow_off;
        x=150; y=-100;

    text text_left_arrow_off;
        x=-150; y=-100;
}pic_fix;

picture{
    text fix_text;
        x=0; y=0;

    text text_right_arrow_off;
        x=150; y=-100;

    text text_left_arrow_on;
        x=-150; y=-100;
}pic_fix_left;

picture{
    text fix_text;
        x=0; y=0;

    text text_right_arrow_on;
        x=150; y=-100;

    text text_left_arrow_off;
        x=-150; y=-100;
}pic_fix_right;

picture{
    text text_modify;
        x=0; y=0;

    text text_right_arrow_off;
        x=150; y=-100;

    text text_left_arrow_off;
        x=-150; y=-100;
}pic_modify;

picture{
    text text_modify;
        x=0; y=0;

    text text_right_arrow_off;
        x=150; y=-100;

    text text_left_arrow_on;
        x=-150; y=-100;
}pic_modify_left;

picture{
    text text_modify;
        x=0; y=0;

    text text_right_arrow_off;
        x=150; y=-100;

    text text_left_arrow_on;
        x=-150; y=-100;

    box box100;
        x=$trigger_x; y=$trigger_y;

}pic_modify_left_t;

picture{
    text text_modify;
        x=0; y=0;

    text text_right_arrow_on;
        x=150; y=-100;

    text text_left_arrow_off;
        x=-150; y=-100;
}pic_modify_right;

picture{
    text text_modify;
        x=0; y=0;

    text text_right_arrow_on;
        x=150; y=-100;

    text text_left_arrow_off;
        x=-150; y=-100;

    box box100;
        x=$trigger_x; y=$trigger_y;
}pic_modify_right_t;


picture{
    text text_modify;
        x=0; y=0;

    text text_right_arrow_off;
        x=150; y=-100;

    text text_left_arrow_on;
        x=-150; y=-100;

    box box120;
        x=$trigger_x; y=$trigger_y;

}pic_modify_comp_left_t;

picture{
    text text_modify;
        x=0; y=0;

    text text_right_arrow_on;
        x=150; y=-100;

    text text_left_arrow_off;
        x=-150; y=-100;

    box box128;
        x=$trigger_x; y=$trigger_y;
}pic_modify_comp_right_t;

text{caption="◆"; font_size=48;}text_fix;
text{caption="<"; font_size=$stim_fontsize;}text_l;
text{caption=">"; font_size=$stim_fontsize;}text_r;


#time
$trigger_duration 	= 20;
$trial_duration 		= 500;		#500;
$agent_duration         = 750;
$modify_trial_duration = 1000;


$agent_button_duration = 730;           # 750 - trigger_duration
$modify_duration = 980;

$stim_onset 			= 20;			#just after trigger (=$trigger_duration)
$stim_duration 		= 480;	  	#$trigger_duration分を引く
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
			
			text{caption="ボタンを押して始めてください"; font_size=24;};
			x=0; y=-200;
		}pic_block_head;
		target_button = 3;
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
			#text{caption="せいはんのうりつ"; font_size=36;}text_block_tale2;
			#x=0;  y=100;
			#text{caption="ちえんはんのうりつ"; font_size=36;}text_block_tale3;
			#x=0;  y=150;
			text{caption="設定を読み込みます。ボタンを押してしばらくお待ちください"; font_size=24;};
			x=0; y=-200;
		}pic_block_tale;
		target_button = 3;
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
		target_button = 1,2;
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

#---------------------------------------------------------------------- L
trial{
	#trial settings
	trial_type = fixed;
	all_responses = false;
	#trial duration
	trial_duration=$trial_duration;
	
	#trigger
	stimulus_event {
			#Target_button left middle	
			picture{
				#trigger
				box box12; #1
				x =$trigger_x; y =$trigger_y ;
				#stim
				text text_l;
				x=0; y=0;
				text text_left_arrow_off;
				x = -150; y = -100;
				text text_right_arrow_off;
				x = 150; y = -100;
			}pic_lc_t;
		time=0;
		duration=$trigger_duration;
		#enable response
		code = "STIM L";
		port_code = 12;
	}event_l_t;
	
	#stim
	stimulus_event{
		picture{
				#stim
				text text_l;
				x=0; y=0;
                text text_left_arrow_off;
				x = -150; y = -100;
				text text_right_arrow_off;
				x = 150; y = -100;
			}pic_l;
		time=$stim_onset;
		duration=$stim_duration;
	}event_l;

}trial_l;
trial{
	#trial settings
	trial_type = fixed;
	all_responses = false;
	#trial duration
	trial_duration=$agent_duration;

	#trigger
	stimulus_event {
			#Target_button left middle
			picture{
				#trigger
				box box16; #1
				x =$trigger_x; y =$trigger_y;
				#stim
				text text_l;
				x=0; y=0;
				text text_left_arrow_on;
				x = -150; y = -100;
				text text_right_arrow_off;
				x = 150; y = -100;
			}pic_ll_t;
		time=0;
		duration=$trigger_duration;
		stimulus_time_in 	= 0;  					# assign response that occur
		stimulus_time_out = $agent_duration; 	# 0-1000 ms after the stimulus
		code = "ANS L L";
		port_code = 16;
	}event_ll_t;

	#stim
	stimulus_event{
		picture{
				#stim
				text text_l;
				x=0; y=0;
                text text_left_arrow_on;
				x = -150; y = -100;
				text text_right_arrow_off;
				x = 150; y = -100;
			}pic_l_left;
		time=$stim_onset;
		duration=$agent_button_duration;
	}event_l_left;
}trial_l_left;

trial{
	#trial settings
	trial_type = fixed;
	all_responses = false;
	#trial duration
	trial_duration=$agent_duration;

	#trigger
	stimulus_event {
			#Target_button left middle
			picture{
				#trigger
				box box48; #1
				x =$trigger_x; y =$trigger_y;
				#stim
				text text_l;
				x=0; y=0;
				text text_left_arrow_off;
				x = -150; y = -100;
				text text_right_arrow_on;
				x = 150; y = -100;
			}pic_lr_t;
		time=0;
		duration=$trigger_duration;
		stimulus_time_in 	= 0;  					# assign response that occur
		stimulus_time_out = $agent_duration; 	# 0-1000 ms after the stimulus
		code = "ANS L R";
		port_code = 48;
	}event_lr_t;

	#stim
	stimulus_event{
		picture{
				#stim
				text text_l;
				x=0; y=0;
                text text_left_arrow_off;
				x = -150; y = -100;
				text text_right_arrow_on;
				x = 150; y = -100;
			}pic_l_right;
		time=$stim_onset;
		duration=$agent_button_duration;
	}event_l_right;
}trial_l_right;

#---------------------------------------------------------------------- R
trial{
	#trial settings
	trial_type = fixed;
	all_responses = false;
	#trial duration
	trial_duration=$trial_duration;
	
	#trigger
	stimulus_event {
			#Target_button left middle	
			picture{
				#trigger
				box box14; #2
				x =$trigger_x; y =$trigger_y ;
				#stim
				text text_r;
				x=0; y=0;

                text text_left_arrow_off;
				x = -150; y = -100;
				text text_right_arrow_off;
				x = 150; y = -100;
			}pic_r_t;
		time=0;
		duration=$trigger_duration;
		#enable response
		#stimulus_time_in 	= 0;  					# assign response that occur
		#stimulus_time_out = $trial_duration; 	# 0-1000 ms after the stimulus
		code = "STIM R";
		port_code = 14;
	}event_r_t;
	
	#stim
	stimulus_event{
		picture{
				#stim
				text text_r;
				x=0; y=0;

                text text_left_arrow_off;
				x = -150; y = -100;
				text text_right_arrow_off;
				x = 150; y = -100;
			}pic_r;
		time=$stim_onset;
		duration=$stim_duration;
	}event_rc;

}trial_r;

trial{
	#trial settings
	trial_type = fixed;
	all_responses = false;
	#trial duration
	trial_duration=$agent_duration;

	#trigger
	stimulus_event {
			#Target_button left middle
			picture{
				#trigger
				box box64; #1
				x =$trigger_x; y =$trigger_y;
				#stim
				text text_r;
				x=0; y=0;
				text text_left_arrow_on;
				x = -150; y = -100;
				text text_right_arrow_off;
				x = 150; y = -100;
			}pic_rl_t;
		time=0;
		duration=$trigger_duration;
		#stimulus_time_in 	= 0;  					# assign response that occur
		#stimulus_time_out = $agent_duration; 	# 0-1000 ms after the stimulus
		code = "ANS R L";
		port_code = 64;
	}event_rl_t;

	#stim
	stimulus_event{
		picture{
				#stim
				text text_r;
				x=0; y=0;
                text text_left_arrow_on;
				x = -150; y = -100;
				text text_right_arrow_off;
				x = 150; y = -100;
			}pic_r_left;
		time=$stim_onset;
		duration=$agent_button_duration;
	}event_r_left;
}trial_r_left;

trial{
	#trial settings
	trial_type = fixed;
	all_responses = false;
	#trial duration
	trial_duration=$agent_duration;

	#trigger
	stimulus_event {
			#Target_button left middle
			picture{
				#trigger
				box box32; #1
				x =$trigger_x; y =$trigger_y;
				#stim
				text text_r;
				x=0; y=0;
				text text_left_arrow_off;
				x = -150; y = -100;
				text text_right_arrow_on;
				x = 150; y = -100;
			}pic_rr_t;
		time=0;
		duration=$trigger_duration;
		#stimulus_time_in 	= 0;  					# assign response that occur
		#stimulus_time_out = $trial_duration; 	# 0-1000 ms after the stimulus
		code = "ANS R R";
		port_code = 48;
	}event_rr_t;

	#stim
	stimulus_event{
		picture{
				#stim
				text text_r;
				x=0; y=0;
                text text_left_arrow_off;
				x = -150; y = -100;
				text text_right_arrow_on;
				x = 150; y = -100;
			}pic_r_right;
		time=$stim_onset;
		duration=$agent_button_duration;
	}event_r_right;
}trial_r_right;


# ---------------------------------------------------------        modify

trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration = $modify_trial_duration;

	#trigger
	stimulus_event {
        #Target_button left middle
        picture pic_modify_left_t;
		time=0;
		duration=$trigger_duration;
		stimulus_time_in 	= 0;  					# assign response that occur
		stimulus_time_out = $modify_trial_duration; 	# 0-1000 ms after the stimulus
	    target_button = 1,2;
		code = "STIM MOD L";
		port_code = 100;
	}event_modify_left_t;

	#stim
	stimulus_event{
		picture pic_modify_left;
		time=$stim_onset;
		duration=$modify_duration;
	}event_modify_left;
}trial_modify_left;

trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=$modify_trial_duration;

	#trigger
	stimulus_event {
        picture pic_modify_right_t;
		time=0;
		duration=$trigger_duration;
		stimulus_time_in 	= 0;  					# assign response that occur
		stimulus_time_out = $modify_trial_duration; 	# 0-1000 ms after the stimulus
        target_button = 1,2;
		code = "STIM MOD R";
		port_code = 100;
	}event_modify_right_t;

	#stim
	stimulus_event{
		picture pic_modify_right;
		time=$stim_onset;
		duration=$modify_duration;
	}event_modify_right;
}trial_modify_right;


# ---------------------------------------------------------   complete modify

trial{
	#trial settings
	trial_type = fixed;
	all_responses = false;
	#trial duration
	trial_duration=$modify_trial_duration;

	#trigger
	stimulus_event {
        #Target_button left middle
        picture pic_modify_comp_left_t;
		time=0;
		duration=$trigger_duration;
		#stimulus_time_in 	= 0;  					# assign response that occur
		#stimulus_time_out = $trial_duration; 	# 0-1000 ms after the stimulus
		code = "STIM MODTO L";
		port_code = 120;
	}event_modify_comp_left_t;

	#stim
	stimulus_event{
		picture pic_modify_left;
		time=$stim_onset;
		duration=$modify_duration;
	}event_modify_comp_left;
}trial_modify_comp_left;

trial{
	#trial settings
	trial_type = fixed;
	all_responses = false;
	#trial duration
	trial_duration=$modify_trial_duration;

	#trigger
	stimulus_event {
        picture pic_modify_right_t;
		time=0;
		duration=$trigger_duration;
		#stimulus_time_in 	= 0;  					# assign response that occur
		#stimulus_time_out = $trial_duration; 	# 0-1000 ms after the stimulus
		code = "STIM MODTO R";
		port_code = 128;
	}event_modify_comp_right_t;

	#stim
	stimulus_event{
		picture pic_modify_right;
		time=$stim_onset;
		duration=$modify_duration;
	}event_modify_comp_right;
}trial_modify_comp_right;


#--------------------------------------------------------- RESPONSE TRIGGER
#Correct
trial{
	#trial settings
	all_responses = false;
	#trial duration
	trial_duration=20;
	#trigger
	stimulus_event{
		picture{
			text text_fix;
			x=0; y=0;
			box box208; #13
			x =$trigger_x; y =$trigger_y ;
            text text_left_arrow_off;
            x = -150; y = -100;
            text text_right_arrow_off;
            x = 150; y = -100;
		}pic_t_correct;
		time=0;
		duration=20;
		code="correct response";
		port_code = 208;
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
			text text_fix;
			x=0; y=0;
			box box224; #14
			x =$trigger_x; y =$trigger_y ;
            text text_left_arrow_off;
            x = -150; y = -100;
            text text_right_arrow_off;
            x = 150; y = -100;
		}pic_t_incorrect;
		time=0;
		duration=20;
		code="incorrect response";
		port_code = 224;
	}event_t_incorrect;
}trial_t_incorrect;

#Omission
trial{
	#trial settings
	all_responses = false;
	#trial duration
	trial_duration=20;
	#trigger
	stimulus_event{
		picture{
			text text_fix;
			x=0; y=0;
			box box240; #14
			x =$trigger_x; y =$trigger_y ;
		}pic_t_omission;
		time=0;
		duration=20;
		code="omission";
	}event_t_omission;
}trial_t_omission;


#---------------------------------------------------------        feedback
text {caption = "正解";} good;
text {caption = "不正解";} oops;
text {caption = "もっと速く！";} missed;
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
int max_block=10;							
int max_trial=100;						
array<int>select_trial[max_trial];	#1:lc 2:rc #3:li #4:ri 
array<int>trial_checker[max_trial];
int s_checker=0;
int fix_jitter =500;
int num_correct = 0;
int num_omission = 0;
double percent_correct;
double percent_omission;
string p_correct;
string p_omission;
string cap_correct ="正反応率：";
string cap_omission ="遅延反応率：";


#fix
int fix_min = 400;						#200;
int fix_max = 600;						#300;

#1 block分のtrial listを作る。
loop int i=1 until i>20 begin
	select_trial.add(1);	#1:lc
	select_trial.add(2);	#2:rc
	select_trial.add(3); #3:li
	select_trial.add(4); #4:ri
	i=i+1;
end;
loop int i=1 until i>5 begin
	select_trial.add(5);
	select_trial.add(6);
	select_trial.add(7);
	select_trial.add(8);
	i=i+1;
end;


#ランダム化
select_trial.shuffle();

###########################################################################################################################
#																	BLOCK LOOP																				  #
###########################################################################################################################

loop int blk = 1 until blk>max_block begin #loop int blk 
	#format
	array<trial> selected_trial[0];
	selected_trial.add(trial_l);
	selected_trial.add(trial_r);

	array<trial> modify_trial[0];
	modify_trial.add(trial_modify_left);
	modify_trial.add(trial_modify_right);

   array<trial> agent_trial[2][0];
	agent_trial[1].add(trial_l_left);
	agent_trial[1].add(trial_l_right);
	agent_trial[2].add(trial_r_left);
	agent_trial[2].add(trial_r_right);

	array<trial> selected_modify_trial[0];
	selected_modify_trial.add(trial_modify_comp_left);
	selected_modify_trial.add(trial_modify_comp_right);

    num_correct = 0;
    num_omission = 0;

    #block head
	pic_block_head.set_part(1, block_letters[blk]);
	trial_block_head.present();

	loop int j=1 until j>select_trial.count() begin
        #fixのjitterを確定
        fix_jitter = random(fix_min, fix_max);
        trial_fix.set_duration(fix_jitter);
        #fix
        trial_fix.present();
        if(mod(select_trial[j],2)==1)then
            selected_trial[1].present();
        elseif(mod(select_trial[j],2)==0)then
            selected_trial[2].present();
        end;
        # selection
        bool answer = (select_trial[j]==1)||(select_trial[j]==2)||(select_trial[j]==5)||(select_trial[j]==6); # correct:true incorrect:false
        bool modify = select_trial[j]>=5;
        # if correct stimulus
        if(answer==true)then
            agent_trial[mod(select_trial[j]+1,2)+1][mod(select_trial[j]+1,2)+1].present();
            num_correct = num_correct + 1;
        elseif(answer==false)then
            agent_trial[mod(select_trial[j]+1,2)+1][mod(select_trial[j],2)+1].present();
        end;
        if(modify==true)then
            # modify
            if(answer==true)then
                modify_trial[mod(select_trial[j]+1,2)+1].present();
            elseif(answer==false)then
                modify_trial[mod(select_trial[j],2)+1].present();
            end;
			stimulus_data last = stimulus_manager.last_stimulus_data();
            if(last.type() == stimulus_incorrect)then
                feedback_pic.set_part(1,missed);
                event_feedback.set_event_code("omission");
                feedback_trial.present();
                trial_t_omission.present();
                num_omission = num_omission+1;
            elseif(last.type() == stimulus_miss)then
                feedback_pic.set_part(1,missed);
                event_feedback.set_event_code("omission");
                feedback_trial.present();
                trial_t_omission.present();
                num_omission = num_omission+1;
			elseif(last.type() == stimulus_hit)then
                if((last.button() == 1)||(last.button()==2))then
                selected_modify_trial[last.button()].present();
                trial_t_correct.present();
                end;
			elseif(last.type() == stimulus_other)then
            end;
        elseif(modify==false)then
            if(answer==true)then
                trial_t_correct.present();
            elseif(answer==false)then
                trial_t_incorrect.present();
            end;
        end;
        j=j+1;
	end; #until j>select_trial.count()

	#パフォーマンスを計算
	#percent_correct = (double(num_correct) / double(max_trial)) *100;
	#percent_omission = (double(num_omission) / double(max_trial)) *100;
	#Strに変換
	#printf(percent_correct,p_correct);
	#printf(percent_omission,p_omission);
	#capに追記
	#cap_correct.append(p_correct);
	#cap_omission.append(p_omission);
	#textに代入
	#p_correct_t.set_caption(cap_correct);
	#p_omission_t.set_caption(cap_omission);
	
	trial_fix.present();
	
	pic_block_tale.set_part(1, block_tale_letters[blk]);
	#pic_block_tale.set_part(2, p_correct_t);
	#pic_block_tale.set_part(3, p_omission_t);
		
	trial_block_tale.present();
	blk=blk+1;
end; #BLOCK LOOP END
trial_task_tale.present();