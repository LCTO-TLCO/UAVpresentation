### 注意
### Python 3.7.x 系でのみ動作

import os
from packages import PresPy
import random
import datetime

pc = PresPy.Presentation_control()

today = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")

# header
pc.set_header_parameter("response_matching", "simple_matching")
pc.set_header_parameter("default_font_size", 48)
pc.set_header_parameter("active_buttons", 3)
pc.set_header_parameter("button_codes", "1, 2, 3")  # left, right, space
# pc.set_header_parameter("write_codes", True)

pc.open_experiment(os.path.abspath("../examples/test presentation/Flanker_pixel.exp"))

scen = pc.run(pc.PRESCONTROL1_USER_CONTROL | pc.PRESCONTROL1_WRITE_OUTPUT, 0, os.path.abspath(f"./log/{today}.log"),
              os.path.abspath(f"./log/{today}.txt"))

# SDL
## coller Trigger
box = {}
for color in [16, 32, 48, 64, 208, 224, 240]:
    box[color] = scen.box(color=PresPy.rgb_color(color, 0, 0), height=5, width=5)

##XYcoordinates
target_x = {}
target_x[1] = -240
target_x[2] = -100
target_x[3] = 100
target_x[4] = 240

target_y = {}
target_y[1] = 0
target_y[2] = 0
target_y[3] = 0
target_y[4] = 0

trigger_x = -962
trigger_y = 542

# block

block_letters = []
block_tale_letters = []
for i in range(10):
    tmp = scen.text()
    tmp.set_font_size(36)
    tmp.set_caption(str(i + 1) + "/10ブロック目", redraw=True)
    block_letters.append(tmp)
    tmp_tale = scen.text()
    tmp_tale.set_font_size(36)
    tmp_tale.set_caption(str(i + 1) + "/10ブロック目終了", redraw=True)
    block_tale_letters.append(tmp_tale)

block_letters = dict(zip(range(1, 11), block_letters))

block_tale_letters = dict(zip(range(1, 11), block_tale_letters))

p_correct_t = scen.text()
p_correct_t.set_font_size(36)
p_correct_t.set_caption("正反応率（％）：", redraw=True)
p_omission_t = scen.text()
p_omission_t.set_font_size(36)
p_omission_t.set_caption("遅延反応率（％）：", redraw=True)

## fixation
fix_text = scen.text()
fix_text.set_font_size(48)
fix_text.set_caption("◆", redraw=True)

## arrow
text_left_arrow_off = scen.text()
text_left_arrow_off.set_font_size(70)
text_left_arrow_off.set_background_color(70, 70, 70)
text_left_arrow_off.set_font_color(0, 0, 0)
text_left_arrow_off.set_caption("←", redraw=True)
text_right_arrow_off = scen.text()
text_right_arrow_off.set_font_size(70)
text_right_arrow_off.set_background_color(70, 70, 70)
text_right_arrow_off.set_font_color(0, 0, 0)
text_right_arrow_off.set_caption("→", redraw=True)
text_left_arrow_on = scen.text()
text_left_arrow_on.set_font_size(70)
text_left_arrow_on.set_background_color(255, 255, 0)
text_left_arrow_on.set_font_color(0, 0, 0)
text_left_arrow_on.set_caption("←", redraw=True)
text_right_arrow_on = scen.text()
text_right_arrow_on.set_font_size(70)
text_right_arrow_on.set_background_color(255, 255, 0)
text_right_arrow_on.set_font_color(0, 0, 0)
text_right_arrow_on.set_caption("→", redraw=True)

# agent control
text_agent_box = scen.text()
text_agent_box.set_font_size(200)
text_agent_box.set_background_color(0, 0, 0, 0)
text_agent_box.set_font_color(255, 0, 0)
text_agent_box.set_caption("□", redraw=True)

pic_fix = scen.picture()
pic_fix.add_part(fix_text, origin_x=0, origin_y=0)
pic_fix.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_fix.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
pic_fix.add_part(text_agent_box, origin_x=0, origin_y=-70)

pic_fix_left = scen.picture()
pic_fix_left.add_part(fix_text, origin_x=0, origin_y=0)
pic_fix_left.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_fix_left.add_part(text_left_arrow_on, origin_x=-150, origin_y=-100)
pic_fix_left.add_part(text_agent_box, origin_x=-150, origin_y=-70)

pic_fix_right = scen.picture()
pic_fix_right.add_part(fix_text, origin_x=0, origin_y=0)
pic_fix_right.add_part(text_right_arrow_on, origin_x=150, origin_y=-100)
pic_fix_right.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
pic_fix_right.add_part(text_agent_box, origin_x=150, origin_y=-70)

## Target_button left congruent
stim_fontsize = 96
text_fix = scen.text()
text_fix.set_font_size(48)
text_fix.set_caption("◆", redraw=True)
text_l_c = scen.text()
text_l_c.set_font_size(stim_fontsize)
text_l_c.set_caption("<<<<<", redraw=True)
text_r_c = scen.text()
text_r_c.set_font_size(stim_fontsize)
text_r_c.set_caption(">>>>>", redraw=True)
text_l_i = scen.text()
text_l_i.set_font_size(stim_fontsize)
text_l_i.set_caption(">><>>", redraw=True)
text_r_i = scen.text()
text_r_i.set_font_size(stim_fontsize)
text_r_i.set_caption("<<><<", redraw=True)

## time
trigger_duration = 20
trial_duration = 500
agent_button_duration = 750
stim_onset = 20  # just after trigger (=$trigger_duration)
stim_duration = 480  # $trigger_duration分を引く
block_count = 1

# ---------------------------------------------------------------------- INSTRUCTION
# ---------------------------------------------------------------------- BLOCK HEAD

trial_block_head = pc.trial(scen)
trial_block_head.set_duration(pc.trial.FOREVER)
trial_block_head.set_type(pc.trial.CORRECT_RESPONSE)
trial_block_head.set_all_responses(False)
pic_block_head = scen.picture()
text_block = scen.text()
text_block.set_font_size(36)
text_block.set_caption(str(block_count) + "ブロック目", redraw=True)
pic_block_head.add_part(text_block, origin_x=0, origin_y=0)
text_pic_block_head = scen.text()
text_pic_block_head.set_font_size(24)
text_pic_block_head.set_caption("ボタンを押して始めてください", redraw=True)
pic_block_head.add_part(text_pic_block_head, origin_x=0, origin_y=-200)
event_block_head = trial_block_head.add_stimulus_event(pic_block_head)
event_block_head.set_target_button(3)
event_block_head.set_stimulus_time_in(1000)
event_block_head.set_stimulus_time_out(event_block_head.TIME_OUT_NEVER)

# ---------------------------------------------------------------------- BLOCK TALE

trial_block_tail = pc.trial(scen)
trial_block_tail.set_duration(pc.trial.FOREVER)
trial_block_tail.set_type(pc.trial.CORRECT_RESPONSE)
trial_block_tail.set_all_responses(False)
pic_block_tail = scen.picture()
text_block_tail = scen.text()
text_block_tail.set_font_size(36)
text_block_tail.set_caption(str(block_count) + "ブロック目終了", redraw=True)
pic_block_tail.add_part(text_block_tail, origin_x=0, origin_y=0)
text_block_tail_settings = scen.text()
text_block_tail_settings.set_font_size(24)
text_block_tail_settings.set_caption("設定を読み込みます。ボタンを押してしばらくお待ちください", redraw=True)
text_block_tail_settings.load()
pic_block_tail.add_part(text_block_tail_settings, origin_x=0, origin_y=-200)
event_block_tail = trial_block_tail.add_stimulus_event(pic_block_tail)
event_block_tail.set_target_button(3)
event_block_tail.set_stimulus_time_in(500)
event_block_tail.set_stimulus_time_out(event_block_tail.TIME_OUT_NEVER)

# ---------------------------------------------------------------------- REST

# ---------------------------------------------------------------------- TASk TALE

trial_task_tail = pc.trial(scen)
trial_task_tail.set_duration(pc.trial.FOREVER)
trial_task_tail.set_type(pc.trial.CORRECT_RESPONSE)
trial_task_tail.set_all_responses(False)
pic_task_tail = scen.picture()
text_task_tail = scen.text()
text_task_tail.set_font_size(36)
text_task_tail.set_caption("全ブロック終了", redraw=True)
text_task_tail.load()
pic_task_tail.add_part(text_task_tail, origin_x=0, origin_y=0)
text_task_tail_wait = scen.text()
text_task_tail_wait.set_font_size(24)
text_task_tail_wait.set_caption("しばらくお待ちください", redraw=True)
text_task_tail_wait.load()
pic_task_tail.add_part(text_task_tail_wait, origin_x=0, origin_y=-200)
event_task_tail = trial_task_tail.add_stimulus_event(pic_task_tail)
event_task_tail.set_target_button([1, 2])
event_task_tail.set_stimulus_time_in(500)
event_task_tail.set_stimulus_time_out(event_task_tail.TIME_OUT_NEVER)

# ---------------------------------------------------------------------- FIX

trial_fix = pc.trial(scen)
trial_fix.set_duration(600)
event_fix = trial_fix.add_stimulus_event(pic_fix)
event_fix.set_time(0)
event_fix.set_stimulus_time_in(0)
event_fix.set_stimulus_time_out(600)
event_fix.set_event_code("fix")

# ---------------------------------------------------------------------- LC

trial_lc = pc.trial(scen)
trial_lc.set_type(trial_lc.FIXED)
trial_lc.set_all_responses(False)
trial_lc.set_duration(trial_duration)
# trigger
pic_lc_t = scen.picture()
pic_lc_t.add_part(box[16], origin_x=trigger_x, origin_y=trigger_y)
pic_lc_t.add_part(text_l_c, origin_x=0, origin_y=0)
event_lc_t = trial_lc.add_stimulus_event(pic_lc_t)
event_lc_t.set_time(0)
event_lc_t.set_duration(trigger_duration)
event_lc_t.set_stimulus_time_in(0)
event_lc_t.set_stimulus_time_out(trial_duration)
event_lc_t.set_event_code("STIM L C")
# event_lc_t.set_port_code(8)
# stim
pic_l_c = scen.picture()
pic_l_c.add_part(text_l_c, origin_x=0, origin_y=0)
pic_l_c.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_l_c.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
pic_l_c.add_part(text_agent_box, origin_x=0, origin_y=-70)
event_lc = trial_lc.add_stimulus_event(pic_l_c)
event_lc.set_time(stim_onset)
event_lc.set_duration(stim_duration)
# agent answer
## left
trial_lc_left = pc.trial(scen)
trial_lc_left.set_type(trial_lc_left.FIXED)
trial_lc_left.set_all_responses(False)
trial_lc_left.set_duration(agent_button_duration)
pic_l_c_left = scen.picture()
pic_l_c_left.add_part(text_l_c, origin_x=0, origin_y=0)
pic_l_c_left.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_l_c_left.add_part(text_left_arrow_on, origin_x=-150, origin_y=-100)
pic_l_c_left.add_part(text_agent_box, origin_x=-150, origin_y=-70)
event_lc_left = trial_lc_left.add_stimulus_event(pic_l_c_left)
event_lc_left.set_time(0)
event_lc_left.set_duration(agent_button_duration)
event_lc_left.set_stimulus_time_in(0)
event_lc_left.set_stimulus_time_out(agent_button_duration)
event_lc_left.set_event_code("ANS L C L")
# right
trial_lc_right = pc.trial(scen)
trial_lc_right.set_type(trial_lc_right.FIXED)
trial_lc_right.set_all_responses(False)
trial_lc_right.set_duration(agent_button_duration)
pic_l_c_right = scen.picture()
pic_l_c_right.add_part(text_l_c, origin_x=0, origin_y=0)
pic_l_c_right.add_part(text_right_arrow_on, origin_x=150, origin_y=-100)
pic_l_c_right.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
pic_l_c_right.add_part(text_agent_box, origin_x=150, origin_y=-70)
event_lc_right = trial_lc_right.add_stimulus_event(pic_l_c_right)
event_lc_right.set_time(0)
event_lc_right.set_duration(agent_button_duration)
event_lc_right.set_stimulus_time_in(0)
event_lc_right.set_stimulus_time_out(agent_button_duration)
event_lc_right.set_event_code("ANS L C R")

# ---------------------------------------------------------------------- RC

trial_rc = pc.trial(scen)
trial_rc.set_type(trial_rc.FIXED)
trial_rc.set_all_responses(False)
trial_rc.set_duration(trial_duration)
# trigger
pic_rc_t = scen.picture()
pic_rc_t.add_part(box[32], origin_x=trigger_x, origin_y=trigger_y)
pic_rc_t.add_part(text_r_c, origin_x=0, origin_y=0)
event_rc_t = trial_rc.add_stimulus_event(pic_rc_t)
event_rc_t.set_time(0)
event_rc_t.set_duration(trigger_duration)
event_rc_t.set_stimulus_time_in(0)
event_rc_t.set_stimulus_time_out(trial_duration)
event_rc_t.set_event_code("STIM R C")
# event_rc_t.set_port_code(16)
# stim
pic_r_c = scen.picture()
pic_r_c.add_part(text_r_c, origin_x=0, origin_y=0)
pic_r_c.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_r_c.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
pic_r_c.add_part(text_agent_box, origin_x=0, origin_y=-70)
event_rc = trial_rc.add_stimulus_event(pic_r_c)
event_rc.set_time(stim_onset)
event_rc.set_duration(stim_duration)
# agent answer
## left
trial_rc_left = pc.trial(scen)
trial_rc_left.set_type(trial_rc_left.FIXED)
trial_rc_left.set_all_responses(False)
trial_rc_left.set_duration(agent_button_duration)
pic_r_c_left = scen.picture()
pic_r_c_left.add_part(text_r_c, origin_x=0, origin_y=0)
pic_r_c_left.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_r_c_left.add_part(text_left_arrow_on, origin_x=-150, origin_y=-100)
pic_r_c_left.add_part(text_agent_box, origin_x=-150, origin_y=-70)
event_rc_left = trial_rc_left.add_stimulus_event(pic_r_c_left)
event_rc_left.set_time(0)
event_rc_left.set_duration(agent_button_duration)
event_rc_left.set_stimulus_time_in(0)
event_rc_left.set_stimulus_time_out(agent_button_duration)
event_rc_left.set_event_code("ANS R C L")
# right
trial_rc_right = pc.trial(scen)
trial_rc_right.set_type(trial_rc_right.FIXED)
trial_rc_right.set_all_responses(False)
trial_rc_right.set_duration(agent_button_duration)
pic_r_c_right = scen.picture()
pic_r_c_right.add_part(text_r_c, origin_x=0, origin_y=0)
pic_r_c_right.add_part(text_right_arrow_on, origin_x=150, origin_y=-100)
pic_r_c_right.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
pic_r_c_right.add_part(text_agent_box, origin_x=150, origin_y=-70)
event_rc_right = trial_rc_right.add_stimulus_event(pic_r_c_right)
event_rc_right.set_time(0)
event_rc_right.set_duration(agent_button_duration)
event_rc_right.set_stimulus_time_in(0)
event_rc_right.set_stimulus_time_out(agent_button_duration)
event_rc_right.set_event_code("ANS R C R")

# ---------------------------------------------------------------------- LI

trial_li = pc.trial(scen)
trial_li.set_type(trial_li.FIXED)
trial_li.set_all_responses(False)
trial_li.set_duration(trial_duration)
# trigger
pic_li_t = scen.picture()
pic_li_t.add_part(box[48], origin_x=trigger_x, origin_y=trigger_y)
pic_li_t.add_part(text_l_i, origin_x=0, origin_y=0)
event_li_t = trial_li.add_stimulus_event(pic_li_t)
event_li_t.set_time(0)
event_li_t.set_duration(trigger_duration)
event_li_t.set_stimulus_time_in(0)
event_li_t.set_stimulus_time_out(trial_duration)
event_li_t.set_event_code("STIM L I")
# event_li_t.set_port_code(24)
# stim
pic_l_i = scen.picture()
pic_l_i.add_part(text_l_i, origin_x=0, origin_y=0)
pic_l_i.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_l_i.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
pic_l_i.add_part(text_agent_box, origin_x=0, origin_y=-70)
event_li = trial_li.add_stimulus_event(pic_l_i)
event_li.set_time(stim_onset)
event_li.set_duration(stim_duration)
# agent answer
## left
trial_li_left = pc.trial(scen)
trial_li_left.set_type(trial_li_left.FIXED)
trial_li_left.set_all_responses(False)
trial_li_left.set_duration(agent_button_duration)
pic_l_i_left = scen.picture()
pic_l_i_left.add_part(text_l_i, origin_x=0, origin_y=0)
pic_l_i_left.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_l_i_left.add_part(text_left_arrow_on, origin_x=-150, origin_y=-100)
pic_l_i_left.add_part(text_agent_box, origin_x=-150, origin_y=-70)
event_li_left = trial_li_left.add_stimulus_event(pic_l_i_left)
event_li_left.set_time(0)
event_li_left.set_duration(agent_button_duration)
event_li_left.set_stimulus_time_in(0)
event_li_left.set_stimulus_time_out(agent_button_duration)
event_li_left.set_event_code("ANS L I L")

# right
trial_li_right = pc.trial(scen)
trial_li_right.set_type(trial_li_right.FIXED)
trial_li_right.set_all_responses(False)
trial_li_right.set_duration(agent_button_duration)
pic_l_i_right = scen.picture()
pic_l_i_right.add_part(text_l_i, origin_x=0, origin_y=0)
pic_l_i_right.add_part(text_right_arrow_on, origin_x=150, origin_y=-100)
pic_l_i_right.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
pic_l_i_right.add_part(text_agent_box, origin_x=150, origin_y=-70)
event_li_right = trial_li_right.add_stimulus_event(pic_l_i_right)
event_li_right.set_time(0)
event_li_right.set_duration(agent_button_duration)
event_li_right.set_stimulus_time_in(0)
event_li_right.set_stimulus_time_out(agent_button_duration)
event_li_right.set_event_code("ANS L I R")

# ---------------------------------------------------------------------- RI

trial_ri = pc.trial(scen)
trial_ri.set_type(trial_ri.FIXED)
trial_ri.set_all_responses(False)
trial_ri.set_duration(trial_duration)
# trigger
pic_ri_t = scen.picture()
pic_ri_t.add_part(box[64], origin_x=trigger_x, origin_y=trigger_y)
pic_ri_t.add_part(text_r_i, origin_x=0, origin_y=0)
event_ri_t = trial_ri.add_stimulus_event(pic_ri_t)
event_ri_t.set_time(0)
event_ri_t.set_duration(trigger_duration)
event_ri_t.set_stimulus_time_in(0)
event_ri_t.set_stimulus_time_out(trial_duration)
event_ri_t.set_event_code("STIM R I")
# event_ri_t.set_port_code(48)
# stim
pic_r_i = scen.picture()
pic_r_i.add_part(text_r_i, origin_x=0, origin_y=0)
pic_r_i.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_r_i.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
pic_r_i.add_part(text_agent_box, origin_x=0, origin_y=-70)
event_ri = trial_ri.add_stimulus_event(pic_r_i)
event_ri.set_time(stim_onset)
event_ri.set_duration(stim_duration)
# agent answer
## left
trial_ri_left = pc.trial(scen)
trial_ri_left.set_type(trial_ri_left.FIXED)
trial_ri_left.set_all_responses(False)
trial_ri_left.set_duration(agent_button_duration)
pic_r_i_left = scen.picture()
pic_r_i_left.add_part(text_r_i, origin_x=0, origin_y=0)
pic_r_i_left.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_r_i_left.add_part(text_left_arrow_on, origin_x=-150, origin_y=-100)
pic_r_i_left.add_part(text_agent_box, origin_x=-150, origin_y=-70)
event_ri_left = trial_ri_left.add_stimulus_event(pic_r_i_left)
event_ri_left.set_time(0)
event_ri_left.set_duration(agent_button_duration)
event_ri_left.set_stimulus_time_in(0)
event_ri_left.set_stimulus_time_out(agent_button_duration)
event_ri_left.set_event_code("ANS R I L")
# right
trial_ri_right = pc.trial(scen)
trial_ri_right.set_type(trial_ri_right.FIXED)
trial_ri_right.set_all_responses(False)
trial_ri_right.set_duration(agent_button_duration)
pic_r_i_right = scen.picture()
pic_r_i_right.add_part(text_r_i, origin_x=0, origin_y=0)
pic_r_i_right.add_part(text_right_arrow_on, origin_x=150, origin_y=-100)
pic_r_i_right.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
pic_r_i_right.add_part(text_agent_box, origin_x=150, origin_y=-70)
event_ri_right = trial_ri_right.add_stimulus_event(pic_r_i_right)
event_ri_right.set_time(0)
event_ri_right.set_duration(agent_button_duration)
event_ri_right.set_stimulus_time_in(0)
event_ri_right.set_stimulus_time_out(agent_button_duration)
event_ri_right.set_event_code("ANS R I R")

# --------------------------------------------------------- RESPONSE TRIGGER
# Correct
trial_t_correct = pc.trial(scen)
trial_t_correct.set_all_responses(False)
trial_t_correct.set_duration(20)
pic_t_correct = scen.picture()
pic_t_correct.add_part(text_fix, origin_x=0, origin_y=0)
pic_t_correct.add_part(box[208], origin_x=trigger_x, origin_y=trigger_y)
pic_t_correct.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_t_correct.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
pic_t_correct.add_part(text_agent_box, origin_x=0, origin_y=-70)
event_t_correct = trial_t_correct.add_stimulus_event(pic_t_correct)
event_t_correct.set_time(0)
event_t_correct.set_duration(20)
event_t_correct.set_event_code("correct response")
# event_t_correct.set_port_code(100)
# Incorrect
trial_t_incorrect = pc.trial(scen)
trial_t_incorrect.set_all_responses(False)
trial_t_incorrect.set_duration(20)
pic_t_incorrect = scen.picture()
pic_t_incorrect.add_part(text_fix, origin_x=0, origin_y=0)
pic_t_incorrect.add_part(box[224], origin_x=trigger_x, origin_y=trigger_y)
pic_t_incorrect.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_t_incorrect.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
pic_t_incorrect.add_part(text_agent_box, origin_x=-0, origin_y=-70)
# event_t_incorrect = trial_t_incorrect.add_stimulus_event(pic_t_incorrect)
# event_t_incorrect.set_time(0)
# event_t_incorrect.set_duration(20)
# event_t_incorrect.set_event_code("incorrect response")
# event_t_incorrect.set_port_code(200)
# Omission
trial_t_omission = pc.trial(scen)
trial_t_omission.set_all_responses(False)
trial_t_omission.set_duration(20)
pic_t_omission = scen.picture()
pic_t_omission.add_part(text_fix, origin_x=0, origin_y=0)
pic_t_omission.add_part(box[240], origin_x=trigger_x, origin_y=trigger_y)
pic_t_omission.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_t_omission.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
pic_t_omission.add_part(text_agent_box, origin_x=0, origin_y=-70)
# event_t_omission = trial_t_omission.add_stimulus_event(pic_t_omission)
# event_t_omission.set_time(0)
# event_t_omission.set_duration(20)
# event_t_omission.set_event_code("omission")

# --------------------------------------------------------- RESPONSE TRIGGER PIC
# correct left
pic_t_correct_left = scen.picture()
pic_t_correct_left.add_part(text_fix, origin_x=0, origin_y=0)
pic_t_correct_left.add_part(box[208], origin_x=trigger_x, origin_y=trigger_y)
pic_t_correct_left.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_t_correct_left.add_part(text_left_arrow_on, origin_x=-150, origin_y=-100)
pic_t_correct_left.add_part(text_agent_box, origin_x=-150, origin_y=-70)
# correct right
pic_t_correct_right = scen.picture()
pic_t_correct_right.add_part(text_fix, origin_x=0, origin_y=0)
pic_t_correct_right.add_part(box[208], origin_x=trigger_x, origin_y=trigger_y)
pic_t_correct_right.add_part(text_right_arrow_on, origin_x=150, origin_y=-100)
pic_t_correct_right.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
pic_t_correct_right.add_part(text_agent_box, origin_x=150, origin_y=-70)
# incorrect left
pic_t_incorrect_left = scen.picture()
pic_t_incorrect_left.add_part(text_fix, origin_x=0, origin_y=0)
pic_t_incorrect_left.add_part(box[224], origin_x=trigger_x, origin_y=trigger_y)
pic_t_incorrect_left.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_t_incorrect_left.add_part(text_left_arrow_on, origin_x=-150, origin_y=-100)
pic_t_incorrect_left.add_part(text_agent_box, origin_x=-150, origin_y=-70)
# incorrect right
pic_t_incorrect_right = scen.picture()
pic_t_incorrect_right.add_part(text_fix, origin_x=0, origin_y=0)
pic_t_incorrect_right.add_part(box[224], origin_x=trigger_x, origin_y=trigger_y)
pic_t_incorrect_right.add_part(text_right_arrow_on, origin_x=150, origin_y=-100)
pic_t_incorrect_right.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
pic_t_incorrect_right.add_part(text_agent_box, origin_x=150, origin_y=-70)

# ---------------------------------------------------------        feedback

good = scen.text()
good.set_caption("正解", redraw=True)
good.load()
oops = scen.text()
oops.set_caption("不正解", redraw=True)
oops.load()
missed = scen.text()
missed.set_caption("もっと速く！", redraw=True)
missed.load()
other = scen.text()
other.set_caption("other", redraw=True)
other.load()

feedback_trial = pc.trial(scen)
feedback_trial.set_duration(300)
feedback_pic = scen.picture()
feedback_pic.add_part(good, origin_x=0, origin_y=0)
event_feedback = feedback_trial.add_stimulus_event(feedback_pic)
event_feedback.set_time(0)
event_feedback.set_duration(300)
event_feedback.set_event_code("feedback")

###########################################################################
#                                    PCL											  #
###########################################################################
# ------------------------------------------------------------------- PARAMS

max_block = 10
max_trial = 100
select_trial = []
agent_answer = []
trial_checker = []
s_checker = 0
fix_jitter = 500
num_correct = 0
num_omission = 0
percent_correct = 0.0
percent_omission = 0.0
p_correct = ""
p_omission = ""
cap_correct = "正反応率："
cap_omission = "遅延反応率："

# fix
fix_min = 400
fix_max = 600

# 1 block分のtrial listを作る。
select_trial += [1 for _ in range(25)]
select_trial += [2 for _ in range(25)]
select_trial += [3 for _ in range(25)]
select_trial += [4 for _ in range(25)]

# 1 block分のagentの正誤listを作る
# 20 ~ 25% の確率で失敗
agent_answer += [True for _ in range(75)]
agent_answer += [False for _ in range(25)]

# random.seed(1234)
random.shuffle(select_trial)
random.shuffle(agent_answer)

###########################################################################################################################
#												        BLOCK LOOP	        										    #
###########################################################################################################################

for blk in range(max_block):
    selected_trial = {1: trial_lc, 2: trial_rc, 3: trial_li, 4: trial_ri}
    # 問題ごとの正誤定義
    correct_answer = {1: "left", 2: "right", 3: "left", 4: "right"}
    agent_trial = {1: {"left": trial_lc_left, "right": trial_lc_right},
                   2: {"left": trial_rc_left, "right": trial_rc_right},
                   3: {"left": trial_li_left, "right": trial_li_right},
                   4: {"left": trial_ri_left, "right": trial_ri_right}}
    not_lr = {"left": "right", "right": "left"}
    num_correct = 0
    num_omission = 0
    pic_block_head.set_part(1, block_letters[blk + 1])
    trial_block_head.present()
    for idx, selection in enumerate(select_trial):
        print(idx)
        fix_jitter = random.randint(fix_min, fix_max)
        trial_fix.set_duration(fix_jitter)
        # fix
        trial_fix.present()
        # lc,rc,li,ri
        selected_trial[selection].present()
        answer = agent_answer[idx]
        # correct
        if answer:
            print("correct")
            agent_trial[selection][correct_answer[selection]].present()
            # present agent pic
            trial_t_correct.present()
            num_correct += 1
        # incorrect
        elif not answer:
            print("incorrect")
            agent_trial[selection][not_lr[correct_answer[selection]]].present()
            trial_t_incorrect.present()
        else:
            pass
    pic_block_tail.set_part(1, block_tale_letters[blk + 1])
    trial_block_tail.present()
trial_task_tail.present()

del scen

###### TODO ######
# NI生やしてトリガーが入るかどうか
# 試行くらいランダムなタイミングで修正するトライアル
# 左右2パターンに統合
# 赤枠をなくす
# Presentation形式に再度書き下し


###### TODO Titan ######
# Titan de Xbox controler task
# 設定ファイルの配置確認