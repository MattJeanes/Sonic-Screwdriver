SonicSD:AddSonic({
    ID = "default",
    Name = "11th Doctor Screwdriver",
    ViewModel = "models/fuzzyleo/sonics/c_11thsonic.mdl",
    WorldModel = "models/fuzzyleo/sonics/w_11thsonic.mdl",
    LightPos = Vector(-100,0,0),
    LightBrightness = 5,
    SoundLoop = "sonicsd/loop_2010_1.wav",
    SoundLoop2 = "sonicsd/loop_2010_2.wav",
    DefaultLightColor = Color(50, 250, 50),
    DefaultLightColor2 = Color(0, 200, 100),
    DefaultLightColorOff = Color(0, 80, 0),
    ModeSoundOn = "sonicsd/button_off_2.wav",
    ModeSoundOff = "sonicsd/button_off_2.wav",
    Animations = {
        Mode = {
            Param = "switch",
            Speed = 1
        }
    }
})