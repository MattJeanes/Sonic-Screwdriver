SonicSD:AddSonic({
    ID = "default",
    Name = "11th Doctor Screwdriver",
    ViewModel = "models/fuzzyleo/sonics/c_11thsonic.mdl",
    WorldModel = "models/fuzzyleo/sonics/w_11thsonic.mdl",
    LightPos = Vector(-100,0,0),
    LightBrightness = 2,
    SoundLoop = "sonicsd/loop_2010_1.wav",
    SoundLoop2 = "sonicsd/loop_2010_2.wav",
    DefaultLightColor = Color(50, 250, 50),
    DefaultLightColor2 = Color(0, 200, 100),
    DefaultLightColorOff = Color(0, 80, 0),
    ModeSoundOn = "sonicsd/extend_2010.wav",
    ModeSoundOff = "sonicsd/retract_2010.wav",
    Animations = {
        Mode = {
            Param = "switch",
            Speed = 1
        }
    }
})

SonicSD:AddSonic({
    ID = "9thdocsonic",
    Name = "9th Doctor Screwdriver",
    ViewModel = "models/fuzzyleo/sonics/c_10thsonic.mdl",
    WorldModel = "models/fuzzyleo/sonics/w_10thsonic.mdl",
    Skin = 0,
    LightPos = Vector(-100,0,0),
    LightBrightness = 2,
    SoundLoop = "sonicsd/loop_2005_1.wav",
    SoundLoop2 = "sonicsd/loop_2005_2.wav",
    ButtonSoundOff = "sonicsd/button_off_2.wav",
    DefaultLightColor = Color(0, 8, 215),
    DefaultLightColor2 = Color(17, 5, 255),
    DefaultLightColorOff = Color(34, 48, 127),
    ModeSoundOn = "sonicsd/extend_2005.wav",
    ModeSoundOff = "sonicsd/retract_2005.wav",
    ModeLightPos = Vector(-100,0,0),
    Animations = {
        Mode = {
            Param = "switch",
            Speed = 1
        }
    }
})

SonicSD:AddSonic({
    ID = "10thdocsonic",
    Base = "9thdocsonic",
    Name = "10th Doctor Screwdriver",
    Skin = 1
})

SonicSD:AddSonic({
    ID = "4thdocsonic",
    Name = "4th Doctor Screwdriver",
    ViewModel = "models/fuzzyleo/sonics/c_4thsonic.mdl",
    WorldModel = "models/fuzzyleo/sonics/w_4thsonic.mdl",
    SoundLoop = "sonicsd/loop_1968_1.wav",
    SoundLoop2 = "sonicsd/loop_1968_2.wav",
    ButtonSoundOn = "sonicsd/button_on_2.wav",
    ButtonSoundOff = "sonicsd/button_off_3.wav",
    ButtonDelay = 0.1,
    DefaultLightColor = Color(160, 0, 0),
    LightDisabled = true,
    ModeSoundOn = "sonicsd/extend_1968.wav",
    ModeSoundOff = "sonicsd/retract_1968.wav",
    Animations = {
        Mode = {
            Param = "extend",
            Speed = 1.5
        },
        Toggle = {
            Param = "active",
            Speed = 1
        }
    }
})