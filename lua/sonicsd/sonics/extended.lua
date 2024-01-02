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
    DefaultLightColor = Color(0, 20, 218),
    DefaultLightColor2 = Color(17, 5, 255),
    DefaultLightColorOff = Color(0, 12, 82),
    ModeSoundOn = "sonicsd/button_off_2.wav",
    ModeSoundOff = "sonicsd/button_off_2.wav",
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
    WorldModel = "models/doctor_who/sonic_screwdriver/w_4thsonicsd.mdl",
    SoundLoop = "sonicsd/loop_1968_1.wav",
    SoundLoop2 = "sonicsd/loop_1968_2.wav",
    LightDisabled = true,
    Animations = {
        Mode = {
            Param = "extend",
            Speed = 1
        },
        Toggle = {
            Param = "active",
            Speed = 1
        }
    }
})