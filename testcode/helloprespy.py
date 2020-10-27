import PresPy

pc = PresPy.Presentation_control()
pc.open_experiment("C:\\Users\\spike\\Documents\\Presentation\\hello.exp")

## SDL

scen = pc.run(0)

# stm_tr = scen.stimulus_event()
txt1 = scen.text()
txt1.set_font_size(48)
txt1.set_caption("Hello world!", redraw=True)

pic1 = scen.picture()
pic1.add_part(txt1, 0, 0)

trial = scen.trial()
ste = trial.add_stimulus_event(pic1)
ste.set_stimulus_time_in(0)
ste.set_stimulus_time_out(1000)

# stm_tr.add_stimulus_event()

## PCL

for i in range(100):
    # trial.set_part_y(1, 50 - i)
    trial.present()

del scen
