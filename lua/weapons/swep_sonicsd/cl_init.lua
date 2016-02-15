include('shared.lua')
 
SWEP.PrintName          = "Sonic Screwdriver"
SWEP.Slot               = 2
SWEP.SlotPos            = 1
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = true

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self:CallHook("Initialize")
end

function SWEP:OnRemove()
	self:CallHook("OnRemove")
end

function SWEP:Holster(wep)
	self:CallHook("Holster",wep)
end

function SWEP:DrawWorldModel()
	self:SetModel(self:GetSonic().WorldModel)
	self:DrawModel()
end

function SWEP:PreDrawViewModel(vm,ply,wep)
	vm:SetModel(self:GetSonic().ViewModel)
	local keydown1=LocalPlayer():KeyDown(IN_ATTACK)
	local keydown2=LocalPlayer():KeyDown(IN_ATTACK2)
	self:CallHook("PreDrawViewModel",vm,ply,wep,keydown1,keydown2)
end

function SWEP:Think()
	local keydown1=LocalPlayer():KeyDown(IN_ATTACK)
	local keydown2=LocalPlayer():KeyDown(IN_ATTACK2)	
	self:CallHook("Think",keydown1,keydown2)
end