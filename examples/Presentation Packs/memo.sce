response_matching = simple_matching;
default_font_size = 48;
active_buttons = 4;
button_codes = 1,2,3,4;

#-----------------------------------------------------------SDL
begin;

#Trigger Box
box{color = 16,0,0;height= 5;width = 5;}box16;
box{color = 32,0,0;height= 5;width = 5;}box32;
box{color = 64,0,0;height= 5;width = 5;}box64;
box{color = 128,0,0;height= 5;width = 5;}box128;
box{color = 240,0,0;height= 5;width = 5;}box240;

#BMPs
bitmap{filename = "target.bmp"; transparent_color = 255, 255, 255;}target;
bitmap{filename = "nontarget.bmp"; transparent_color = 255, 255, 255;}nontarget;

#sound
sound { wavefile { filename = "stop.wav"; }; } stop_signal;

#pictures
picture{
		text{caption="+"; font_size=12;};
		x=0; y=0;
		bitmap nontarget;
		x=-100; y=0;
		bitmap nontarget;
		x=-240; y=0;
		bitmap nontarget;
		x=100; y=0;
		bitmap nontarget;
		x=240; y=0;
	}pic_fix;
	
picture{
		text{caption="+"; font_size=12;};
		x=0; y=0;
		bitmap target;
		x=-240; y=0;
		bitmap nontarget;
		x=-100; y=0;
		bitmap nontarget;
		x=100; y=0;
		bitmap nontarget;
		x=240; y=0;
	}pic_li;

picture{
		text{caption="+"; font_size=12;};
		x=0; y=0;
		bitmap nontarget;
		x=-240; y=0;
		bitmap target;
		x=-100; y=0;
		bitmap nontarget;
		x=100; y=0;
		bitmap nontarget;
		x=240; y=0;
	}pic_lm;

picture{
		text{caption="+"; font_size=12;};
		x=0; y=0;
		bitmap nontarget;
		x=-240; y=0;
		bitmap nontarget;
		x=-100; y=0;
		bitmap target;
		x=100; y=0;
		bitmap nontarget;
		x=240; y=0;
	}pic_ri;

picture{
		text{caption="+"; font_size=12;};
		x=0; y=0;
		bitmap nontarget;
		x=-240; y=0;
		bitmap nontarget;
		x=-100; y=0;
		bitmap nontarget;
		x=100; y=0;
		bitmap target;
		x=240; y=0;
	}pic_rm;

#trial
trial{
	trial_duration=500;
	
	picture pic_fix;
	time=0;
	
	picture pic_li;
	time=100;
	
	picture pic_lm;
	time=200;
	
	picture pic_ri;
	time=300;
	
	picture pic_rm;
	time=400;
	
	code="fix";
	
}trial_fix;

trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=1000;
	
	
	#trigger
	stimulus_event {
		picture{
			text{caption="A"; font_size=64;};
			x=0; y=0;
			box box16;
			x =-962; y =542 ;
		}pic_a_trig;
		time=0;
		duration=20;
		#enable response
		response_active = true;
		stimulus_time_in 	= 0;  	# assign response that occur
		stimulus_time_out = 1000; 	# 300-1000 ms after the stimulus
		code = "A";
	}event_t_a;
	
	
	#stim
	stimulus_event{
		picture{
			text{caption="A"; font_size=64;};
			x=0; y=0;
		}pic_a;
		time=20;
		duration=280;
	}event_s_a;
	
}trial_a;

trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=2000;
	#trigger
	stimulus_event {
		picture{
			text{caption="B"; font_size=64;};
			x=0; y=0;
			box box16;
			x =-962; y =542 ;
		}pic_b_trig;
		time=0;
		duration=20;
		#enable response
		target_button = 2;
		stimulus_time_in 	= 0;  	# assign response that occur
		stimulus_time_out = 20; 	# 300-1000 ms after the stimulus
		code = "B";
	}event_t_b;
	
	#
	stimulus_event {
		sound stop_signal;
		code = "sound";
		parallel = true;
		time=0;
	} sound_event;
	
	#stim
	stimulus_event{
		picture{
			text{caption="B"; font_size=64;};
			x=0; y=0;
		}pic_b;
		time=20;
		duration=980;
		target_button = 2;
		stimulus_time_in 	= 20;  	# assign response that occur
		stimulus_time_out = 1000; 	# 300-1000 ms after the stimulus
	}event_s_b;
}trial_b;



trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=2000;
	#trigger
	stimulus_event {
		picture{
			text{caption="C"; font_size=64;};
			x=0; y=0;
			box box16;
			x =-962; y =542 ;
		}pic_c_trig;
		time=0;
		duration=20;
		#enable response
		target_button = 3;
		stimulus_time_in 	= 0;  	# assign response that occur
		stimulus_time_out = 2000; 	# 300-1000 ms after the stimulus
		code = "C";
	}event_t_c;
	#stim
	stimulus_event{
		picture{
			text{caption="C"; font_size=64;};
			x=0; y=0;
		}pic_c;
		time=20;
		duration=980;
	}event_s_c;
}trial_c;

trial{
	#trial settings
	trial_type = first_response;
	all_responses = false;
	#trial duration
	trial_duration=2000;
	#trigger
	stimulus_event {
		picture{
			text{caption="D"; font_size=64;};
			x=0; y=0;
			box box16;
			x =-962; y =542 ;
		}pic_d_trig;
		time=0;
		duration=20;
		#enable response
		target_button = 4;
		stimulus_time_in 	= 0;  	# assign response that occur
		stimulus_time_out = 2000; 	# 300-1000 ms after the stimulus
		code = "D";
	}event_t_d;
	#stim
	stimulus_event{
		picture{
			text{caption="D"; font_size=64;};
			x=0; y=0;
		}pic_d;
		time=20;
		duration=980;
	}event_s_d;
}trial_d;

#feedback
text {caption = "Good!";} good;
text {caption = "Oops!";} oops;
text {caption = "Missed";} missed;
text {caption = "false alram";} f_a;
text {caption = "other";} other;

trial{
	trial_duration=1000;
	picture{text good; x=0; y=0;} feedback_pic;
	time=0;
	duration=500;
} feedback_trial;

#ITI
#trial{
#	all_responses = false;
#	trial_duration=1000;
#}wait_trial;

###########################################################################
#                                    PCL											  #
###########################################################################
begin_pcl;
int max_trial=12;

array<int>select_trial[max_trial];

loop int i=1 until i>3 begin
	select_trial.add(1);
	select_trial.add(2);
	select_trial.add(3);
	select_trial.add(4);
	i=i+1;
end;

select_trial.shuffle();

loop int j=1 until j>select_trial.count() begin
		
	if(select_trial[j]==1)then
		trial_fix.present();
		
		trial_a.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		if last.type() == stimulus_incorrect then
			feedback_pic.set_part(1, oops);
			feedback_trial.present();
		elseif last.type() == stimulus_miss then
			feedback_pic.set_part(1, missed);
			feedback_trial.present();
		elseif last.type() == stimulus_hit then
			feedback_pic.set_part(1, good);
			feedback_trial.present();
		elseif last.type() == stimulus_false_alarm then
			feedback_pic.set_part(1, f_a);
			feedback_trial.present();
		elseif last.type() == stimulus_other then
			feedback_pic.set_part(1, other);
			feedback_trial.present();
		end;
	elseif(select_trial[j]==2)then
		trial_fix.present();
		trial_b.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		if last.type() == stimulus_incorrect then
			feedback_pic.set_part(1, oops);
			feedback_trial.present();
		elseif last.type() == stimulus_miss then
			feedback_pic.set_part(1, missed);
			feedback_trial.present();
		elseif last.type() == stimulus_hit then
			feedback_pic.set_part(1, good);
			feedback_trial.present();
		end;
	elseif(select_trial[j]==3)then
		trial_fix.present();
		trial_c.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		if last.type() == stimulus_incorrect then
			feedback_pic.set_part(1, oops);
			feedback_trial.present();
		elseif last.type() == stimulus_miss then
			feedback_pic.set_part(1, missed);
			feedback_trial.present();
		elseif last.type() == stimulus_hit then
			feedback_pic.set_part(1, good);
			feedback_trial.present();
		end;
	elseif(select_trial[j]==4)then
		trial_fix.present();
		trial_d.present();
		stimulus_data last = stimulus_manager.last_stimulus_data();
		if last.type() == stimulus_incorrect then
			feedback_pic.set_part(1, oops);
			feedback_trial.present();
		elseif last.type() == stimulus_miss then
			feedback_pic.set_part(1, missed);
			feedback_trial.present();
		elseif last.type() == stimulus_hit then
			feedback_pic.set_part(1, good);
			feedback_trial.present();
		end;
	end;
	
	j=j+1;
	
end;