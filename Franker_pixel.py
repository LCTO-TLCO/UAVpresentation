import sys

sys.path.append('C:\\Users\\spike\\PycharmProjects\\UAVpresentation\\packages')
import PresPy
import random

pc = PresPy.Presentation_control()

# header
pc.set_header_parameter("response_matching", "simple_matching")
pc.set_header_parameter("default_font_size", 48)
pc.set_header_parameter("active_buttons", 3)
pc.set_header_parameter("button_codes", "1, 2, 3")  # left, right, space
# pc.set_header_parameter("write_codes", True)

pc.open_experiment("C:\\Users\\spike\\PycharmProjects\\UAVpresentation\\examples\\test presentation\\Flanker_pixel.exp")

scen = pc.run(pc.PRESCONTROL1_USER_CONTROL | pc.PRESCONTROL1_WRITE_OUTPUT, 0)

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
    block_tale_letters.append(tmp)

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
pic_fix = scen.picture()
pic_fix.add_part(fix_text, origin_x=0, origin_y=0)

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
event_fix.set_event_code("fix")

# ---------------------------------------------------------------------- LC

trial_lc = pc.trial(scen)
trial_lc.set_type(trial_lc.FIRST_RESPONSE)
trial_lc.set_all_responses(False)
trial_lc.set_duration(trial_duration)
# trigger
pic_lc_t = scen.picture()
pic_lc_t.add_part(box[16], origin_x=trigger_x, origin_y=trigger_y)
pic_lc_t.add_part(text_l_c, origin_x=0, origin_y=0)
event_lc_t = trial_lc.add_stimulus_event(pic_lc_t)
event_lc_t.set_time(0)
event_lc_t.set_duration(trigger_duration)
event_lc_t.set_target_button(1)
event_lc_t.set_stimulus_time_in(0)
event_lc_t.set_stimulus_time_out(trial_duration)
event_lc_t.set_event_code("STIM L C")
# event_lc_t.set_port_code(8)
# stim
pic_l_c = scen.picture()
pic_l_c.add_part(text_l_c, origin_x=0, origin_y=0)
event_lc = trial_lc.add_stimulus_event(pic_l_c)
event_lc.set_time(stim_onset)
event_lc.set_duration(stim_duration)

# ---------------------------------------------------------------------- RC

trial_rc = pc.trial(scen)
trial_rc.set_type(trial_rc.FIRST_RESPONSE)
trial_rc.set_all_responses(False)
trial_rc.set_duration(trial_duration)
# trigger
pic_rc_t = scen.picture()
pic_rc_t.add_part(box[32], origin_x=trigger_x, origin_y=trigger_y)
pic_rc_t.add_part(text_r_c, origin_x=0, origin_y=0)
event_rc_t = trial_rc.add_stimulus_event(pic_rc_t)
event_rc_t.set_time(0)
event_rc_t.set_duration(trigger_duration)
event_rc_t.set_target_button(2)
event_rc_t.set_stimulus_time_in(0)
event_rc_t.set_stimulus_time_out(trial_duration)
event_rc_t.set_event_code("STIM R C")
# event_rc_t.set_port_code(16)
# stim
pic_r_c = scen.picture()
pic_r_c.add_part(text_r_c, origin_x=0, origin_y=0)
event_rc = trial_rc.add_stimulus_event(pic_r_c)
event_rc.set_time(stim_onset)
event_rc.set_duration(stim_duration)

# ---------------------------------------------------------------------- LI

trial_li = pc.trial(scen)
trial_li.set_type(trial_li.FIRST_RESPONSE)
trial_li.set_all_responses(False)
trial_li.set_duration(trial_duration)
# trigger
pic_li_t = scen.picture()
pic_li_t.add_part(box[48], origin_x=trigger_x, origin_y=trigger_y)
pic_li_t.add_part(text_l_i, origin_x=0, origin_y=0)
event_li_t = trial_li.add_stimulus_event(pic_li_t)
event_li_t.set_time(0)
event_li_t.set_duration(trigger_duration)
event_li_t.set_target_button(1)
event_li_t.set_stimulus_time_in(0)
event_li_t.set_stimulus_time_out(trial_duration)
event_li_t.set_event_code("STIM L I")
# event_li_t.set_port_code(24)
# stim
pic_l_i = scen.picture()
pic_l_i.add_part(text_l_i, origin_x=0, origin_y=0)
event_li = trial_li.add_stimulus_event(pic_l_i)
event_li.set_time(stim_onset)
event_li.set_duration(stim_duration)

# ---------------------------------------------------------------------- RI

trial_ri = pc.trial(scen)
trial_ri.set_type(trial_ri.FIRST_RESPONSE)
trial_ri.set_all_responses(False)
trial_ri.set_duration(trial_duration)
# trigger
pic_ri_t = scen.picture()
pic_ri_t.add_part(box[64], origin_x=trigger_x, origin_y=trigger_y)
pic_ri_t.add_part(text_l_i, origin_x=0, origin_y=0)
event_ri_t = trial_ri.add_stimulus_event(pic_ri_t)
event_ri_t.set_time(0)
event_ri_t.set_duration(trigger_duration)
event_ri_t.set_target_button(2)
event_ri_t.set_stimulus_time_in(0)
event_ri_t.set_stimulus_time_out(trial_duration)
event_ri_t.set_event_code("STIM R I")
# event_ri_t.set_port_code(48)
# stim
pic_r_i = scen.picture()
pic_r_i.add_part(text_l_i, origin_x=0, origin_y=0)
event_ri = trial_ri.add_stimulus_event(pic_r_i)
event_ri.set_time(stim_onset)
event_ri.set_duration(stim_duration)

# --------------------------------------------------------- RESPONSE TRIGGER
# Correct
trial_t_correct = pc.trial(scen)
trial_t_correct.set_all_responses(False)
trial_t_correct.set_duration(20)
pic_t_correct = scen.picture()
pic_t_correct.add_part(text_fix, origin_x=0, origin_y=0)
pic_t_correct.add_part(box[208], origin_x=trigger_x, origin_y=trigger_y)
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
event_t_incorrect = trial_t_incorrect.add_stimulus_event(pic_t_incorrect)
event_t_incorrect.set_time(0)
event_t_incorrect.set_duration(20)
event_t_incorrect.set_event_code("incorrect response")
# event_t_incorrect.set_port_code(200)
# Omission
trial_t_omission = pc.trial(scen)
trial_t_omission.set_all_responses(False)
trial_t_omission.set_duration(20)
pic_t_omission = scen.picture()
pic_t_omission.add_part(text_fix, origin_x=0, origin_y=0)
pic_t_omission.add_part(box[240], origin_x=trigger_x, origin_y=trigger_y)
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

# random.seed(1234)
random.shuffle(select_trial)

###########################################################################################################################
#																	BLOCK LOOP																				  #
###########################################################################################################################

for blk in range(max_block):
    selected_trial = {1: trial_lc, 2: trial_rc, 3: trial_li, 4: trial_ri}
    num_correct = 0
    num_omission = 0
    pic_block_head.set_part(1, block_letters[blk + 1])
    trial_block_head.present()
    for selection in select_trial:
        fix_jitter = random.randint(fix_min, fix_max)
        trial_fix.set_duration(fix_jitter)
        # fix
        trial_fix.present()
        # lc,rc,li,ri
        selected_trial[selection].present()
        stimulus_manager = scen.get_var("stimulus_manager")
        help(stimulus_manager)
        last = stimulus_manager.last_stimulus_data()
        print(last.type())
        if last.type() == pc.stimulus_data.INCORRECT:
            trial_t_incorrect.present()
        elif last.type() == pc.stimulus_data.MISS:
            feedback_pic.set_part(1, missed)
            event_feedback.set_event_code("omission")
            feedback_trial.present()
            trial_t_omission.present()
            num_omission += 1
        elif last.type() == pc.stimulus_data.HIT:
            trial_t_correct.present()
            num_correct += 1
        elif last.type() == pc.stimulus_data.OTHER:
            pass
    trial_fix.present()
    pic_block_tail.set_part(1, block_tale_letters[blk + 1])
    trial_block_tail.present()
trial_task_tail.present()

# TODO exporting log

del scen
