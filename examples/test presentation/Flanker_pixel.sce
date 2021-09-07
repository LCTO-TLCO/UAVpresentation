###########################################################################
#                                    Header										  #
###########################################################################
response_matching = simple_matching;
default_font_size = 48;
active_buttons = 3;
button_codes = 1,2,3; #left, right, space
write_codes =true;

###########################################################################
#                                    SDL											  #
###########################################################################
begin;
#----------------------------------------------------------  Coller Trigger
box{color = 16,0,0;height= 5;width = 5;}box16;		#1		Cong_L <<<<<
box{color = 32,0,0;height= 5;width = 5;}box32;		#2		Cong_R >>>>>
box{color = 48,0,0;height= 5;width = 5;}box48;		#3		Incong L >><>>
box{color = 64,0,0;height= 5;width = 5;}box64;		#4		Incong R <<><<	
box{color = 208,0,0;height= 5;width = 5;}box208;	#5		correct response 	
box{color = 224,0,0;height= 5;width = 5;}box224;	#6		incorrect response
box{color = 240,0,0;height= 5;width = 5;}box240;	#7		omission

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

#fixation
picture{
		text{caption="◆"; font_size=48;};
		x=0; y=0;
	}pic_fix;
	
#Target_button left congruent
$stim_fontsize 	= 96;
text{caption="◆"; font_size=48;}text_fix;
text{caption="<<<<<"; font_size=$stim_fontsize;}text_l_c;
text{caption=">>>>>"; font_size=$stim_fontsize;}text_r_c;
text{caption=">><>>"; font_size=$stim_fontsize;}text_l_i;
text{caption="<<><<"; font_size=$stim_fontsize;}text_r_i;
#time
$trigger_duration 	= 20;
$trial_duration 		= 500;		#500;
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
#---------------------------------------------------------------------- LC
trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=$trial_duration;
	
	#trigger
	stimulus_event {
			#Target_button left middle	
			picture{
				#trigger
				box box16; #1
				x =$trigger_x; y =$trigger_y ;
				#stim
				text text_l_c;
				x=0; y=0;
			}pic_lc_t;
		time=0;
		duration=$trigger_duration;
		#enable response
		target_button = 1;
		stimulus_time_in 	= 0;  					# assign response that occur
		stimulus_time_out = $trial_duration; 	# 0-1000 ms after the stimulus
		code = "STIM L C";
		port_code = 8;
	}event_lc_t;
	
	#stim
	stimulus_event{
		picture{
				#stim
				text text_l_c;
				x=0; y=0;
			}pic_l_c;
		time=$stim_onset;
		duration=$stim_duration;
	}event_lc;

}trial_lc;

#---------------------------------------------------------------------- RC
trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=$trial_duration;
	
	#trigger
	stimulus_event {
			#Target_button left middle	
			picture{
				#trigger
				box box32; #2
				x =$trigger_x; y =$trigger_y ;
				#stim
				text text_r_c;
				x=0; y=0;
			}pic_rc_t;
		time=0;
		duration=$trigger_duration;
		#enable response
		target_button = 2;
		stimulus_time_in 	= 0;  					# assign response that occur
		stimulus_time_out = $trial_duration; 	# 0-1000 ms after the stimulus
		code = "STIM R C";
		port_code = 16;
	}event_rc_t;
	
	#stim
	stimulus_event{
		picture{
				#stim
				text text_r_c;
				x=0; y=0;
			}pic_r_c;
		time=$stim_onset;
		duration=$stim_duration;
	}event_rc;

}trial_rc;

#---------------------------------------------------------------------- LI
trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=$trial_duration;
	
	#trigger
	stimulus_event {
			#Target_button left middle	
			picture{
				#trigger
				box box48; #1
				x =$trigger_x; y =$trigger_y ;
				#stim
				text text_l_i;
				x=0; y=0;
			}pic_li_t;
		time=0;
		duration=$trigger_duration;
		#enable response
		target_button = 1;
		stimulus_time_in 	= 0;  					# assign response that occur
		stimulus_time_out = $trial_duration; 	# 0-1000 ms after the stimulus
		code = "STIM L I";
		port_code = 24;
	}event_li_t;
	
	#stim
	stimulus_event{
		picture{
				#stim
				text text_l_i;
				x=0; y=0;
			}pic_l_i;
		time=$stim_onset;
		duration=$stim_duration;
	}event_li;

}trial_li;
#---------------------------------------------------------------------- RI
trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=$trial_duration;
	
	#trigger
	stimulus_event {
			#Target_button left middle	
			picture{
				#trigger
				box box64; #4
				x =$trigger_x; y =$trigger_y ;
				#stim
				text text_r_i;
				x=0; y=0;
			}pic_ri_t;
		time=0;
		duration=$trigger_duration;
		#enable response
		target_button = 2;
		stimulus_time_in 	= 0;  					# assign response that occur
		stimulus_time_out = $trial_duration; 	# 0-1000 ms after the stimulus
		code = "STIM R I";
		port_code = 48;
	}event_ri_t;
	
	#stim
	stimulus_event{
		picture{
				#stim
				text text_r_i;
				x=0; y=0;
			}pic_r_i;
		time=$stim_onset;
		duration=$stim_duration;
	}event_ri;

}trial_ri;

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
		}pic_t_correct;
		time=0;
		duration=20;
		code="correct response";
		port_code = 100;
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
		}pic_t_incorrect;
		time=0;
		duration=20;
		code="incorrect response";
		port_code = 200;
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
loop int i=1 until i>25 begin
	select_trial.add(1);	#1:lc
	select_trial.add(2);	#2:rc
	select_trial.add(3); #3:li
	select_trial.add(4); #4:ri
	i=i+1;
end;

#ランダム化
select_trial.shuffle();

###########################################################################################################################
#																	BLOCK LOOP																				  #
###########################################################################################################################

loop int blk = 1 until blk>max_block begin #loop int blk 
#format
	num_correct = 0;
   num_omission = 0;

#block head
	pic_block_head.set_part(1, block_letters[blk]);
	trial_block_head.present();

	loop int j=1 until j>select_trial.count() begin
		if(select_trial[j]==1)then #--------------------------------------------------------------------------------1:lc
			#fixのjitterを確定
			fix_jitter = random(fix_min, fix_max);
			trial_fix.set_duration(fix_jitter);
			#fix
			trial_fix.present();
			#lc
			trial_lc.present();
			stimulus_data last = stimulus_manager.last_stimulus_data();
			if last.type() == stimulus_incorrect then
				#feedback_pic.set_part(1, oops);	#debug feedback
				#feedback_trial.present();			#debug feedback
				trial_t_incorrect.present();	
			elseif last.type() == stimulus_miss then
				feedback_pic.set_part(1, missed);	#debug feedback
				event_feedback.set_event_code("omission");
				feedback_trial.present();				#debug feedback
				trial_t_omission.present();
				num_omission = num_omission +1;
			elseif last.type() == stimulus_hit then
				#feedback_pic.set_part(1, good);		#debug feedback
				#feedback_trial.present();				#debug feedback
				trial_t_correct.present();
				num_correct = num_correct +1;
			elseif last.type() == stimulus_other then
				#feedback_pic.set_part(1, other);		#debug feedback
				#feedback_trial.present();				#debug feedback
			end;
		elseif(select_trial[j]==2)then #--------------------------------------------------------------------------------2:rc
			#fixのjitterを確定
			fix_jitter = random(fix_min, fix_max);
			trial_fix.set_duration(fix_jitter);
			#fix
			trial_fix.present();
			#rc
			trial_rc.present();
			stimulus_data last = stimulus_manager.last_stimulus_data();
			if last.type() == stimulus_incorrect then
				#feedback_pic.set_part(1, oops);	#debug feedback
				#feedback_trial.present();			#debug feedback
				trial_t_incorrect.present();	
			elseif last.type() == stimulus_miss then
				feedback_pic.set_part(1, missed);	#debug feedback
				event_feedback.set_event_code("omission");
				feedback_trial.present();				#debug feedback
				trial_t_omission.present();
				num_omission = num_omission +1;
			elseif last.type() == stimulus_hit then
				#feedback_pic.set_part(1, good);		#debug feedback
				#feedback_trial.present();				#debug feedback
				trial_t_correct.present();
				num_correct = num_correct +1;
			elseif last.type() == stimulus_other then
				#feedback_pic.set_part(1, other);		#debug feedback
				#feedback_trial.present();				#debug feedback
			end;
		elseif(select_trial[j]==3)then #--------------------------------------------------------------------------------3:li
			#fixのjitterを確定
			fix_jitter = random(fix_min, fix_max);
			trial_fix.set_duration(fix_jitter);
			#fix
			trial_fix.present();
			#rc
			trial_li.present();
			stimulus_data last = stimulus_manager.last_stimulus_data();
			if last.type() == stimulus_incorrect then
				#feedback_pic.set_part(1, oops);	#debug feedback
				#feedback_trial.present();			#debug feedback
				trial_t_incorrect.present();	
			elseif last.type() == stimulus_miss then
				feedback_pic.set_part(1, missed);	#debug feedback
				event_feedback.set_event_code("omission");
				feedback_trial.present();				#debug feedback
				trial_t_omission.present();
				num_omission = num_omission +1;
			elseif last.type() == stimulus_hit then
				#feedback_pic.set_part(1, good);		#debug feedback
				#feedback_trial.present();				#debug feedback
				trial_t_correct.present();
			elseif last.type() == stimulus_other then
				#feedback_pic.set_part(1, other);		#debug feedback
				#feedback_trial.present();				#debug feedback
			end;
		elseif(select_trial[j]==4)then #--------------------------------------------------------------------------------3:ri
						#fixのjitterを確定
			fix_jitter = random(fix_min, fix_max);
			trial_fix.set_duration(fix_jitter);
			#fix
			trial_fix.present();
			#rc
			trial_ri.present();
			stimulus_data last = stimulus_manager.last_stimulus_data();
			if last.type() == stimulus_incorrect then
				#feedback_pic.set_part(1, oops);	#debug feedback
				#feedback_trial.present();			#debug feedback
				trial_t_incorrect.present();	
			elseif last.type() == stimulus_miss then
				feedback_pic.set_part(1, missed);	#debug feedback
				event_feedback.set_event_code("omission");
				feedback_trial.present();				#debug feedback
				trial_t_omission.present();
				num_omission = num_omission +1;
			elseif last.type() == stimulus_hit then
				#feedback_pic.set_part(1, good);		#debug feedback
				#feedback_trial.present();				#debug feedback
				trial_t_correct.present();
				num_correct = num_correct +1;
			elseif last.type() == stimulus_other then
				#feedback_pic.set_part(1, other);		#debug feedback
				#feedback_trial.present();				#debug feedback
			end;
		end; #IF
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