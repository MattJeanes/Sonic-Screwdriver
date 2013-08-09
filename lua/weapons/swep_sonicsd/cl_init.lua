include('shared.lua')
 
SWEP.PrintName          = "Sonic Screwdriver"
SWEP.Slot               = 2
SWEP.SlotPos            = 1
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = true

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self.curbeep=0
	self.eyeangles=Angle(0,0,0)
	self.sound=CreateSound(self,"sonicsd/loop.wav")
	self.emitter = ParticleEmitter(self:GetPos())
	self.rgb = string.Explode(" ", GetConVarString("cl_weaponcolor")) // getting weapon color for effect
	for k,v in pairs(self.rgb) do self.rgb[k]=v*255 end // initially a vector, gotta make it RGB
end

function SWEP:PointingAt(ent)
	if not IsValid(ent) then return end
	
	local ViewEnt = self.Owner:GetViewEntity()
	local fov = 15
	local Disp = ent:GetPos() - ViewEnt:GetPos()
	local Dist = Disp:Length()
	local Width = 100
	
	local MaxCos = math.abs( math.cos( math.acos( Dist / math.sqrt( Dist * Dist + Width * Width ) ) + fov * ( math.pi / 180 ) ) )
	Disp:Normalize()
	
	if Disp:Dot( ViewEnt:EyeAngles():Forward() ) > MaxCos then
		return true
	end
	
    return false
end

function SWEP:OnRemove()
	if self.sound then self.sound:Stop() end
end

function SWEP:Holster( wep )
	if self.sound then self.sound:Stop() end
end

function SWEP:PreDrawViewModel(vm,ply,wep)
	local cureffect=0
	local keydown1=LocalPlayer():KeyDown(IN_ATTACK)
	local keydown2=LocalPlayer():KeyDown(IN_ATTACK2)
	if (keydown1 or keydown2) then
		if tobool(GetConVarNumber("sonic_light"))==true and CurTime()>cureffect then
			cureffect=CurTime()+0.05
			self.emitter:SetPos(vm:GetPos())
			local velocity = LocalPlayer():GetVelocity()
			local spawnpos = vm:LocalToWorld(Vector(20,-1.75,-2.75))
			local particle = self.emitter:Add("sprites/glow04_noz", spawnpos)
			if (particle) then
				particle:SetVelocity(velocity)
				particle:SetLifeTime(0)
				particle:SetColor(self.rgb[1],self.rgb[2],self.rgb[3])
				particle:SetDieTime(0.02)
				particle:SetStartSize(3)
				particle:SetEndSize(3)
				particle:SetAirResistance(0)
				particle:SetCollide(false)
				particle:SetBounce(0)
			end
		end
		if tobool(GetConVarNumber("sonic_dynamiclight"))==true then
			local dlight = DynamicLight( self:EntIndex() )
			if ( dlight ) then
				local size=75
				dlight.Pos = vm:LocalToWorld(Vector(40,-1.75,0))
				dlight.r = self.rgb[1]
				dlight.g = self.rgb[2]
				dlight.b = self.rgb[3]
				dlight.Brightness = 5
				dlight.Decay = size * 5
				dlight.Size = size
				dlight.DieTime = CurTime() + 1
			end
		end
	end
end

function SWEP:Think()
	local keydown1=LocalPlayer():KeyDown(IN_ATTACK)
	local keydown2=LocalPlayer():KeyDown(IN_ATTACK2)
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
		
		if (keydown1 and keydown2) and self.Owner.linked_tardis and IsValid(self.Owner.linked_tardis) and CurTime()>self.curbeep then
			local tardis=self.Owner.linked_tardis
			if self:PointingAt(tardis) then
				self.curbeep=CurTime()+0.4
				self:EmitSound("sonicsd/beep.wav")
			else
				self.curbeep=CurTime()+1
				self:EmitSound("sonicsd/beep.wav")
			end
		end
	elseif self.sound and self.sound:IsPlaying() then
		self.sound:Stop()
	end
end

net.Receive("Sonic-SetLinkedTARDIS", function()
	LocalPlayer().linked_tardis=net.ReadEntity()
end)

local checkbox_options={
	{"Sound", "sonic_sound"},
	{"Particle light", "sonic_light"},
	{"Dynamic light", "sonic_dynamiclight"},
}

for k,v in pairs(checkbox_options) do
	CreateClientConVar(v[2], "1", true)
end

hook.Add("PopulateToolMenu", "SonicSD-PopulateToolMenu", function()
	spawnmenu.AddToolMenuOption("Options", "Doctor Who", "Sonic_Options", "Sonic Screwdriver", "", "", function(panel)
		panel:ClearControls()	
		local checkboxes={}
		for k,v in pairs(checkbox_options) do
			CreateClientConVar(v[2], "1", true)
			local checkBox = vgui.Create( "DCheckBoxLabel" ) 
			checkBox:SetText( v[1] ) 
			checkBox:SetValue( GetConVarNumber( v[2] ) )
			checkBox:SetConVar( v[2] )
			panel:AddItem(checkBox)
			table.insert(checkboxes, checkBox)
		end
	end)
end)