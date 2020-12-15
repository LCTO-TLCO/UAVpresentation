import PresPy
import os

pc = PresPy.Presentation_control()
pc.open_experiment(os.path.abspath("./hello.exp"))

## SDL

scen = pc.run(0)

# stm_tr = scen.stimulus_event()
pic1 = scen.picture()

txt1 = scen.text()
txt1.set_font_size(48)
txt1.set_caption("Hello world!", redraw=True)
txt2 = scen.text()
txt2.set_font_size(48)
txt2.set_caption("Hello?", redraw=True)

pic1.add_part(txt1, origin_x=0, origin_y=0)

left_arrow_off = scen.text()
left_arrow_off.set_font_size(70)
left_arrow_off.set_background_color(70, 70, 70)
left_arrow_off.set_font_color(0, 0, 0)
left_arrow_off.set_caption("←", redraw=True)

left_arrow_on = scen.text()
left_arrow_on.set_font_size(70)
left_arrow_on.set_background_color(255, 255, 0)
left_arrow_on.set_font_color(0, 0, 0)
left_arrow_on.set_caption("←", redraw=True)

pic_left_off = scen.picture()
pic_left_off.add_part(left_arrow_on, -300, -300)

pic1.add_part(left_arrow_on, origin_x=-300, origin_y=-300)

pic2 = scen.picture()
pic2.add_part(txt1, origin_x=0, origin_y=0)
pic2.add_part(left_arrow_off, origin_x=-300, origin_y=-300)

trial = scen.trial()
trial.set_duration(600)
ste = trial.add_stimulus_event(pic1)
ste.set_time(300)
ste = trial.add_stimulus_event(pic_left_off)
ste.set_stimulus_time_in(0)
ste.set_stimulus_time_out(300)

# 下
ste2 = trial.add_stimulus_event(pic2, 1)
# ste = trial.add_stimulus_event(pic_left_off)
# ste2.set_stimulus_time_in(300)
# ste2.set_stimulus_time_out(600)


# stm_tr.add_stimulus_event()

## PCL

for i in range(10):
    pic1.set_part_y(1, 50 - i)
    pic2.set_part_y(1, 50 - i)
    trial.present()

del scen
