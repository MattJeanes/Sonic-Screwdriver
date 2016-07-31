include('shared.lua')
 
SWEP.PrintName          = "Sonic Screwdriver"
SWEP.Slot               = 2
SWEP.SlotPos            = 1
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = true

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	net.Start("SonicSD-Initialize")
		net.WriteEntity(self)
	net.SendToServer()
end

net.Receive("SonicSD-Initialize",function(len)
	local sonic = net.ReadEntity()
	if IsValid(sonic) and sonic:GetClass()=="swep_sonicsd" then
		local id = net.ReadString()
		sonic:SetSonicID(id)
		sonic._ready = true
		sonic:CallHook("Initialize")
	end
end)

function SWEP:OnRemove()
	if self._ready then
		self:CallHook("OnRemove")
	end
end

function SWEP:Holster(wep)
	if self._ready then
		self:CallHook("Holster",wep)
	end
end

function SWEP:DrawWorldModel()
	if self._ready then
		self:SetModel(self:GetSonic().WorldModel)
		self:DrawModel()
	end
end

function SWEP:PreDrawViewModel(vm,ply,wep)
	if self._ready then
		vm:SetModel(self:GetSonic().ViewModel)
		local keydown1=LocalPlayer():KeyDown(IN_ATTACK)
		local keydown2=LocalPlayer():KeyDown(IN_ATTACK2)
		self:CallHook("PreDrawViewModel",vm,ply,wep,keydown1,keydown2)
	else
		render.SetBlend(0)
	end
end

function SWEP:PostDrawViewModel()
	if not self._ready then
		render.SetBlend(1)
	end
end

function SWEP:Think()
	if self._ready then
		local keydown1=LocalPlayer():KeyDown(IN_ATTACK)
		local keydown2=LocalPlayer():KeyDown(IN_ATTACK2)	
		self:CallHook("Think",keydown1,keydown2)
	end
end