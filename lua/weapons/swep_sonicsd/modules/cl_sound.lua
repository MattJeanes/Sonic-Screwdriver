-- Sound

SWEP:AddHook("Initialize", "sound", function(self)
	self.curbeep=0
	self.eyeangles=Angle(0,0,0)
	self.sound=CreateSound(self,self:GetSonic().SoundLoop)
end)

SWEP:AddHook("OnRemove", "sound", function(self)
	if self.sound then self.sound:Stop() end
end)

SWEP:AddHook("Holster", "sound", function(self)
	if self.sound then self.sound:Stop() end
end)

SWEP:AddHook("Think", "sound", function(self,keydown1,keydown2)
	if keydown1 or keydown2 then
		if tobool(GetConVarNumber("sonic_sound"))==true then
			local diff=self.Owner:EyeAngles()-self.eyeangles
			if diff.p < 0 then diff.p=-diff.p end
			if diff.y < 0 then diff.y=-diff.y end
			local pitch=diff.p+diff.y*15
			self.sound:ChangePitch(math.Clamp(pitch+100,100,150),0.1)
			self.eyeangles=self.Owner:EyeAngles()
			if not self.sound:IsPlaying() then
				self.sound:Play()
			end
		elseif self.sound and self.sound:IsPlaying() then
			self.sound:Stop()
		end
	elseif self.sound and self.sound:IsPlaying() then
		self.sound:Stop()
	end
end)