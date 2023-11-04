-- Sound

SWEP:AddHook("Initialize", "sound", function(self)
    self.curbeep=0
    self.eyeangles=Angle(0,0,0)
    self.sound1=CreateSound(self,self:GetSonic().SoundLoop)
    self.sound2=CreateSound(self,self:GetSonic().SoundLoop2)
    buttonsoundon=self:GetSonic().ButtonSoundOn
    buttonsoundoff=self:GetSonic().ButtonSoundOff
    holster=self:GetSonic().HolsterSound
end)

SWEP:AddHook("SonicChanged", "sound", function(self)
    self.sound1=CreateSound(self,self:GetSonic().SoundLoop)
    self.sound2=CreateSound(self,self:GetSonic().SoundLoop2)
end)

SWEP:AddHook("OnRemove", "sound", function(self)
    if self.sound1 then self.sound1:Stop() self:EmitSound(buttonsoundoff) end
    if self.sound2 then self.sound2:Stop() self:EmitSound(buttonsoundoff) end
end)

SWEP:AddHook("Holster", "sound", function(self)
    if self.sound1 then self.sound1:Stop() self:EmitSound(holster) end
    if self.sound2 then self.sound2:Stop() self:EmitSound(holster) end
end)

SWEP:AddHook("Think", "sound", function(self,keydown1,keydown2)
    if keydown1 then
        if tobool(GetConVarNumber("sonic_sound"))==true then
            local diff=self.Owner:EyeAngles()-self.eyeangles
            if diff.p < 0 then diff.p=-diff.p end
            if diff.y < 0 then diff.y=-diff.y end
            local pitch=diff.p+diff.y*15
            self.sound1:ChangePitch(math.Clamp(pitch+100,100,150),0.1)
            self.eyeangles=self.Owner:EyeAngles()
            if not self.sound1:IsPlaying() then
                self:EmitSound(buttonsoundon)
                self.sound1:Play()
            end
        elseif self.sound1 and self.sound1:IsPlaying() then
            self:EmitSound(buttonsoundoff)
            self.sound1:Stop()
        end
    elseif keydown2 then
        if tobool(GetConVarNumber("sonic_sound"))==true then
            local diff=self.Owner:EyeAngles()-self.eyeangles
            if diff.p < 0 then diff.p=-diff.p end
            if diff.y < 0 then diff.y=-diff.y end
            local pitch=diff.p+diff.y*15
            self.sound2:ChangePitch(math.Clamp(pitch+100,100,150),0.1)
            self.eyeangles=self.Owner:EyeAngles()
            if not self.sound2:IsPlaying() then
                self:EmitSound(buttonsoundon)
                self.sound2:Play()
            end
        elseif self.sound2 and self.sound2:IsPlaying() then
            self:EmitSound(buttonsoundoff)
            self.sound2:Stop()
        end
    elseif (self.sound1 and self.sound1:IsPlaying()) or (self.sound2 and self.sound2:IsPlaying()) then
        self:EmitSound(buttonsoundoff)
        self.sound1:Stop()
        self.sound2:Stop()
    end
end)