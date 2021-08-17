### 注意
### Python 3.7.x 32bit系でのみ動作

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
for color in [12, 14, 16, 32, 48, 64, 100, 120, 128, 208, 224, 240]:
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
# modify answer
text_modify = scen.text()
text_modify.set_font_size(48)
text_modify.set_caption("*", redraw=True)

# fix pic
pic_fix = scen.picture()
pic_fix.add_part(fix_text, origin_x=0, origin_y=0)
pic_fix.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_fix.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)

pic_fix_left = scen.picture()
pic_fix_left.add_part(fix_text, origin_x=0, origin_y=0)
pic_fix_left.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_fix_left.add_part(text_left_arrow_on, origin_x=-150, origin_y=-100)

pic_fix_right = scen.picture()
pic_fix_right.add_part(fix_text, origin_x=0, origin_y=0)
pic_fix_right.add_part(text_right_arrow_on, origin_x=150, origin_y=-100)
pic_fix_right.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)

# modify pic
pic_modify = scen.picture()
pic_modify.add_part(text_modify, origin_x=0, origin_y=0)
pic_modify.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_modify.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)

pic_modify_left = scen.picture()
pic_modify_left.add_part(text_modify, origin_x=0, origin_y=0)
pic_modify_left.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_modify_left.add_part(text_left_arrow_on, origin_x=-150, origin_y=-100)

pic_modify_left_t = scen.picture()
pic_modify_left_t.add_part(box[100], origin_x=trigger_x, origin_y=trigger_y)
pic_modify_left_t.add_part(text_modify, origin_x=0, origin_y=0)
pic_modify_left_t.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_modify_left_t.add_part(text_left_arrow_on, origin_x=-150, origin_y=-100)

pic_modify_right = scen.picture()
pic_modify_right.add_part(text_modify, origin_x=0, origin_y=0)
pic_modify_right.add_part(text_right_arrow_on, origin_x=150, origin_y=-100)
pic_modify_right.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)

pic_modify_right_t = scen.picture()
pic_modify_right_t.add_part(box[100], origin_x=trigger_x, origin_y=trigger_y)
pic_modify_right_t.add_part(text_modify, origin_x=0, origin_y=0)
pic_modify_right_t.add_part(text_right_arrow_on, origin_x=150, origin_y=-100)
pic_modify_right_t.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)

# complete mod
pic_modify_comp_left_t = scen.picture()
pic_modify_comp_left_t.add_part(box[120], origin_x=trigger_x, origin_y=trigger_y)
pic_modify_comp_left_t.add_part(text_modify, origin_x=0, origin_y=0)
pic_modify_comp_left_t.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_modify_comp_left_t.add_part(text_left_arrow_on, origin_x=-150, origin_y=-100)
pic_modify_comp_right_t = scen.picture()
pic_modify_comp_right_t.add_part(box[128], origin_x=trigger_x, origin_y=trigger_y)
pic_modify_comp_right_t.add_part(text_modify, origin_x=0, origin_y=0)
pic_modify_comp_right_t.add_part(text_right_arrow_on, origin_x=150, origin_y=-100)
pic_modify_comp_right_t.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)

## Target_button left congruent
stim_fontsize = 96
text_fix = scen.text()
text_fix.set_font_size(48)
text_fix.set_caption("◆", redraw=True)
text_l = scen.text()
text_l.set_font_size(stim_fontsize)
text_l.set_caption("<", redraw=True)
text_r = scen.text()
text_r.set_font_size(stim_fontsize)
text_r.set_caption(">", redraw=True)

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
event_task_tail.set_target_button([1])
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

# ---------------------------------------------------------------------- l

trial_l = pc.trial(scen)
trial_l.set_type(trial_l.FIXED)
trial_l.set_all_responses(False)
trial_l.set_duration(trial_duration)
# trigger
pic_l_t = scen.picture()
pic_l_t.add_part(box[12], origin_x=trigger_x, origin_y=trigger_y)
pic_l_t.add_part(text_l, origin_x=0, origin_y=0)
pic_l_t.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_l_t.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
event_l_t = trial_l.add_stimulus_event(pic_l_t)
event_l_t.set_time(0)
event_l_t.set_duration(trigger_duration)
# event_l_t.set_stimulus_time_in(0)
# event_l_t.set_stimulus_time_out(trial_duration)
event_l_t.set_event_code("STIM L")
# event_l_t.set_port_code(12)
# stim
pic_l = scen.picture()
pic_l.add_part(text_l, origin_x=0, origin_y=0)
pic_l.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_l.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
event_l = trial_l.add_stimulus_event(pic_l)
event_l.set_time(stim_onset)
event_l.set_duration(stim_duration)
# agent answer
## left
trial_l_left = pc.trial(scen)
trial_l_left.set_type(trial_l_left.FIXED)
trial_l_left.set_all_responses(False)
trial_l_left.set_duration(agent_button_duration)

## left trigger
pic_ll_t = scen.picture()
pic_ll_t.add_part(box[16], origin_x=trigger_x, origin_y=trigger_y)
pic_ll_t.add_part(text_l, origin_x=0, origin_y=0)
pic_ll_t.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_ll_t.add_part(text_left_arrow_on, origin_x=-150, origin_y=-100)
event_ll_t = trial_l_left.add_stimulus_event(pic_ll_t)
event_ll_t.set_time(0)
event_ll_t.set_duration(trigger_duration)
event_ll_t.set_stimulus_time_in(0)
event_ll_t.set_stimulus_time_out(trial_duration)
event_ll_t.set_event_code("ANS L L")
# event_ll_t.set_port_code(8)
## answer left
pic_l_left = scen.picture()
pic_l_left.add_part(text_l, origin_x=0, origin_y=0)
pic_l_left.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_l_left.add_part(text_left_arrow_on, origin_x=-150, origin_y=-100)
event_l_left = trial_l_left.add_stimulus_event(pic_l_left)
event_l_left.set_time(stim_onset)
event_l_left.set_duration(agent_button_duration)
# event_l_left.set_stimulus_time_in(0)
event_l_left.set_stimulus_time_out(agent_button_duration)

## right
trial_l_right = pc.trial(scen)
trial_l_right.set_type(trial_l_right.FIXED)
trial_l_right.set_all_responses(False)
trial_l_right.set_duration(agent_button_duration + trigger_duration)
## right trigger
pic_lr_t = scen.picture()
pic_lr_t.add_part(box[48], origin_x=trigger_x, origin_y=trigger_y)
pic_lr_t.add_part(text_l, origin_x=0, origin_y=0)
pic_lr_t.add_part(text_right_arrow_on, origin_x=150, origin_y=-100)
pic_lr_t.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
event_lr_t = trial_l_right.add_stimulus_event(pic_lr_t)
event_lr_t.set_time(0)
event_lr_t.set_duration(trigger_duration)
event_lr_t.set_stimulus_time_in(0)
event_lr_t.set_stimulus_time_out(trial_duration)
event_lr_t.set_event_code("ANS L R")

## answer right
pic_l_right = scen.picture()
pic_l_right.add_part(text_l, origin_x=0, origin_y=0)
pic_l_right.add_part(text_right_arrow_on, origin_x=150, origin_y=-100)
pic_l_right.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
event_l_right = trial_l_right.add_stimulus_event(pic_l_right)
event_l_right.set_time(stim_onset)
event_l_right.set_duration(agent_button_duration)
# event_l_right.set_stimulus_time_in(0)
# event_l_right.set_stimulus_time_out(agent_button_duration)

# ---------------------------------------------------------------------- r

trial_r = pc.trial(scen)
trial_r.set_type(trial_r.FIXED)
trial_r.set_all_responses(False)
trial_r.set_duration(trial_duration)
# trigger
pic_r_t = scen.picture()
pic_r_t.add_part(box[14], origin_x=trigger_x, origin_y=trigger_y)
pic_r_t.add_part(text_r, origin_x=0, origin_y=0)
pic_r_t.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_r_t.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
event_r_t = trial_r.add_stimulus_event(pic_r_t)
event_r_t.set_time(0)
event_r_t.set_duration(trigger_duration)
event_r_t.set_stimulus_time_in(0)
event_r_t.set_stimulus_time_out(trial_duration)
event_r_t.set_event_code("STIM R")
# event_r_t.set_port_code(14)
# stim
pic_r = scen.picture()
pic_r.add_part(text_r, origin_x=0, origin_y=0)
pic_r.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_r.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
event_r = trial_r.add_stimulus_event(pic_r)
event_r.set_time(stim_onset)
event_r.set_duration(stim_duration)
# agent answer
## left
trial_r_left = pc.trial(scen)
trial_r_left.set_type(trial_r_left.FIXED)
trial_r_left.set_all_responses(False)
trial_r_left.set_duration(agent_button_duration)
## right trigger
pic_rl_t = scen.picture()
pic_lr_t.add_part(box[64], origin_x=trigger_x, origin_y=trigger_y)
pic_rl_t.add_part(text_r, origin_x=0, origin_y=0)
pic_rl_t.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_rl_t.add_part(text_left_arrow_on, origin_x=-150, origin_y=-100)
event_rl_t = trial_r_left.add_stimulus_event(pic_rl_t)
event_rl_t.set_time(0)
event_rl_t.set_duration(trigger_duration)
event_rl_t.set_stimulus_time_in(0)
event_rl_t.set_stimulus_time_out(trial_duration)
event_rl_t.set_event_code("ANS R L")
## answer left
pic_r_left = scen.picture()
pic_r_left.add_part(text_r, origin_x=0, origin_y=0)
pic_r_left.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_r_left.add_part(text_left_arrow_on, origin_x=-150, origin_y=-100)
event_r_left = trial_r_left.add_stimulus_event(pic_r_left)
event_r_left.set_time(stim_onset)
event_r_left.set_duration(agent_button_duration)
# event_r_left.set_stimulus_time_in(0)
# event_r_left.set_stimulus_time_out(agent_button_duration)

## right
trial_r_right = pc.trial(scen)
trial_r_right.set_type(trial_r_right.FIXED)
trial_r_right.set_all_responses(False)
trial_r_right.set_duration(agent_button_duration)
## right trigger
pic_rr_t = scen.picture()
pic_lr_t.add_part(box[32], origin_x=trigger_x, origin_y=trigger_y)
pic_rr_t.add_part(text_r, origin_x=0, origin_y=0)
pic_rr_t.add_part(text_right_arrow_on, origin_x=150, origin_y=-100)
pic_rr_t.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
event_rr_t = trial_r_right.add_stimulus_event(pic_rr_t)
event_rr_t.set_time(0)
event_rr_t.set_duration(trigger_duration)
event_rr_t.set_stimulus_time_in(0)
event_rr_t.set_stimulus_time_out(trial_duration)
event_rr_t.set_event_code("ANS R R")
## answer right
pic_r_right = scen.picture()
pic_r_right.add_part(text_r, origin_x=0, origin_y=0)
pic_r_right.add_part(text_right_arrow_on, origin_x=150, origin_y=-100)
pic_r_right.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
event_r_right = trial_r_right.add_stimulus_event(pic_r_right)
event_r_right.set_time(stim_onset)
event_r_right.set_duration(agent_button_duration)
# event_r_right.set_stimulus_time_in(0)
# event_r_right.set_stimulus_time_out(agent_button_duration)

# ---------------------------------------------------------        modify

trial_modify_left = pc.trial(scen)
trial_modify_left.set_type(trial_modify_left.CORRECT_RESPONSE)
trial_modify_left.set_duration(1000)
trial_modify_left.set_all_responses(False)

# trigger
event_modify_left_t = trial_modify_left.add_stimulus_event(pic_modify_left_t)
event_modify_left_t.set_time(0)
event_modify_left_t.set_stimulus_time_in(0)
event_modify_left_t.set_stimulus_time_out(trigger_duration)
event_modify_left_t.set_target_button([1, 2])
event_modify_left_t.set_duration(trigger_duration)
event_modify_left_t.set_event_code("STIM MOD L")
# event_modify_left_t.set_port_code(100)
# stim
event_modify_left = trial_modify_left.add_stimulus_event(pic_modify_left)
event_modify_left.set_time(stim_onset)
event_modify_left.set_stimulus_time_in(stim_onset)
event_modify_left.set_stimulus_time_out(1000)
event_modify_left.set_target_button([1, 2])
event_modify_left.set_duration(1000)

# right
trial_modify_right = pc.trial(scen)
trial_modify_right.set_type(trial_modify_right.CORRECT_RESPONSE)
trial_modify_right.set_duration(1000)
trial_modify_right.set_all_responses(False)

# trigger
event_modify_right_t = trial_modify_right.add_stimulus_event(pic_modify_right_t)
event_modify_right_t.set_time(0)
event_modify_right_t.set_stimulus_time_in(0)
event_modify_right_t.set_stimulus_time_out(trigger_duration)
event_modify_right_t.set_target_button([1, 2])
event_modify_right_t.set_duration(trigger_duration)
event_modify_right_t.set_event_code("STIM MOD R")
# event_modify_right_t.set_port_code(100)

# stim
event_modify_right = trial_modify_right.add_stimulus_event(pic_modify_right)
event_modify_right.set_time(stim_onset)
event_modify_right.set_stimulus_time_in(stim_onset)
event_modify_right.set_stimulus_time_out(1000)
event_modify_right.set_target_button([1, 2])
event_modify_right.set_duration(1000)

# ---------------------------------------------------------   complete modify
trial_modify_comp_left = pc.trial(scen)
trial_modify_comp_left.set_type(trial_modify_comp_left.FIXED)
trial_modify_comp_left.set_all_responses(False)
trial_modify_comp_left.set_duration(1000)
event_modify_comp_left_t = trial_modify_comp_left.add_stimulus_event(pic_modify_comp_left_t)
event_modify_comp_left_t.set_time(0)
event_modify_comp_left_t.set_duration(trigger_duration)
event_modify_comp_left_t.set_event_code("STIM MODTO L")
# event_modify_left_t.set_port_code(120)

event_modify_comp_left = trial_modify_comp_left.add_stimulus_event(pic_modify_left)
event_modify_comp_left.set_time(stim_onset)
event_modify_comp_left.set_duration(1000)

trial_modify_comp_right = pc.trial(scen)
trial_modify_comp_right.set_type(trial_modify_comp_right.FIXED)
trial_modify_comp_right.set_all_responses(False)
trial_modify_comp_right.set_duration(1000)
event_modify_comp_right_t = trial_modify_comp_right.add_stimulus_event(pic_modify_comp_right_t)
event_modify_comp_right_t.set_time(0)
event_modify_comp_right_t.set_duration(trigger_duration)
event_modify_comp_right_t.set_event_code("STIM MODTO R")
# event_modify_comp_right_t.set_port_code(128)

event_modify_comp_right = trial_modify_comp_right.add_stimulus_event(pic_modify_right)
event_modify_comp_right.set_time(stim_onset)
event_modify_comp_right.set_duration(1000)

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
event_t_correct = trial_t_correct.add_stimulus_event(pic_t_correct)
event_t_correct.set_time(0)
event_t_correct.set_duration(20)
event_t_correct.set_event_code("correct response")
# event_t_correct.set_port_code(208)

# Incorrect
trial_t_incorrect = pc.trial(scen)
trial_t_incorrect.set_all_responses(False)
trial_t_incorrect.set_duration(20)
pic_t_incorrect = scen.picture()
pic_t_incorrect.add_part(text_fix, origin_x=0, origin_y=0)
pic_t_incorrect.add_part(box[224], origin_x=trigger_x, origin_y=trigger_y)
pic_t_incorrect.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_t_incorrect.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
event_t_incorrect = trial_t_incorrect.add_stimulus_event(pic_t_incorrect)
event_t_incorrect.set_time(0)
event_t_incorrect.set_duration(20)
event_t_incorrect.set_event_code("incorrect response")
# event_t_incorrect.set_port_code(224)

# Omission
trial_t_omission = pc.trial(scen)
trial_t_omission.set_all_responses(False)
trial_t_omission.set_duration(20)
pic_t_omission = scen.picture()
pic_t_omission.add_part(text_fix, origin_x=0, origin_y=0)
pic_t_omission.add_part(box[240], origin_x=trigger_x, origin_y=trigger_y)
pic_t_omission.add_part(text_right_arrow_off, origin_x=150, origin_y=-100)
pic_t_omission.add_part(text_left_arrow_off, origin_x=-150, origin_y=-100)
event_t_omission = trial_t_omission.add_stimulus_event(pic_t_omission)
event_t_omission.set_time(0)
event_t_omission.set_duration(20)
event_t_omission.set_event_code("omission")

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
perent_correct = 0.0
percent_omission = 0.0
p_correct = ""
p_omission = ""
cap_correct = "正反応率："
cap_omission = "遅延反応率："

# fix
fix_min = 400
fix_max = 600

# 1 block分のtrial listを作る。
# 1: left correct
# 2: right correct
# 3: left incorrect
# 4: right incorrect
# 5: modify left correct
# 6: modify right correct
# 7: modify left incorrect
# 8: modify right incorrect

select_trial += [1 for _ in range(20)]
select_trial += [2 for _ in range(20)]
select_trial += [3 for _ in range(20)]
select_trial += [4 for _ in range(20)]
select_trial += [5 for _ in range(5)]
select_trial += [6 for _ in range(5)]
select_trial += [7 for _ in range(5)]
select_trial += [8 for _ in range(5)]

# 1 block分のagentの正誤listを作る

# random.seed(1234)
random.shuffle(select_trial)

###########################################################################################################################
#												        BLOCK LOOP	        										    #
###########################################################################################################################

for blk in range(max_block):
    random.shuffle(select_trial)
    # debug
    with open(f"./log/{today}_pythonlist_b{blk}.csv", "w") as f:
        f.write(",".join([str(a) for a in select_trial]))
    selected_trial = {1: trial_l, 2: trial_r}
    modify_trial = {"left": trial_modify_left, "right": trial_modify_right}
    # 問題ごとの正誤定義
    correct_answer = {1: "left", 2: "right"}
    agent_trial = {1: {"left": trial_l_left, "right": trial_l_right},
                   2: {"left": trial_r_left, "right": trial_r_right}
                   }
    selected_modify_trial = {"left": trial_modify_comp_left, "right": trial_modify_comp_right}
    not_lr = {"left": "right", "right": "left"}
    num_correct = 0
    num_omission = 0
    pic_block_head.set_part(1, block_letters[blk + 1])
    trial_block_head.present()
    for idx, selection in enumerate(select_trial):
        print(f"selection:{selection}")
        fix_jitter = random.randint(fix_min, fix_max)
        trial_fix.set_duration(fix_jitter)
        # fix
        trial_fix.present()
        # lc,rc,li,ri
        # modify lc,rc,li,ri
        print((selection - 1) % 2 + 1)
        selected_trial[(selection - 1) % 2 + 1].present()
        answer = not (bool(((selection - 1) // 2) % 2))
        modify = bool((selection - 1) // 4)
        # correct
        if answer:
            print("correct")
            agent_trial[(selection - 1) % 2 + 1][correct_answer[(selection - 1) % 2 + 1]].present()
            # present agent pic
            num_correct += 1
        # incorrect
        elif not answer:
            print("incorrect")
            agent_trial[(selection - 1) % 2 + 1][not_lr[correct_answer[(selection - 1) % 2 + 1]]].present()
            # trial_t_incorrect.present()
        else:
            pass
        # modify trial
        if not modify:
            trial_t_correct.present() if answer else trial_t_incorrect.present()
        elif modify:
            # * and lr arrow
            # 1000s or responce
            modify_trial[correct_answer[(selection - 1) % 2 + 1]].present() if answer else modify_trial[
                not_lr[correct_answer[(selection - 1) % 2 + 1]]].present()
            stimulus_manager = scen.get_var("stimulus_manager")
            last = stimulus_manager.last_stimulus_data()
            # omission
            if last.type() in [pc.stimulus_data.MISS, pc.stimulus_data.INCORRECT]:
                print("miss")
                feedback_pic.set_part(1, missed)
                # event_feedback.set_event_code("omission")
                feedback_trial.present()
                trial_t_omission.present()
                num_omission += 1
            # hit or incorrect
            elif last.type() in [pc.stimulus_data.HIT]:
                # elif last.type() in [pc.stimulus_data.HIT, pc.stimulus_data.INCORRECT]:
                # 修正後結果の提示
                # left
                if last.button() == 1:
                    print("modto left")
                    selected_modify_trial["left"].present()
                # right
                elif last.button() == 2:
                    print("modto right")
                    selected_modify_trial["right"].present()
                else:
                    print("other responce")
                # fix
                trial_t_correct.present() if answer else trial_t_incorrect.present()
            else:
                print(f"type={last.type()}")
                pass
    # block end
    pic_block_tail.set_part(1, block_tale_letters[blk + 1])
    trial_block_tail.present()
trial_task_tail.present()

del scen

###### TODO ######
# NI生やしてトリガーが入るかどうか
# 試行くらいランダムなタイミングで修正するトライアル
# 左右2パターンに統合
# 赤枠をなくす
# 修正後呈示
# トリガー直前のチラつき(低優先度)
# Presentation形式に再度書き下し
# トリガー再考
## correct,incorrectは入力した時のみ？エージェントのcorrect,incorrectは？(少なくともfixは？)


###### TODO Titan ######
# Titan de Xbox controler task
# 設定ファイルの配置確認


###### TODO test ######
# Presentation エラーなし動作の確認
# Presentation 入力と判定の、ログ確認
## リストとログの比較で出力の確認
## 呈示時間の確認
## ソースからトリガーの種類の確認
