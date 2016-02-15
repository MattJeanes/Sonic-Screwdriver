AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
 
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.WaitTime = 0.5

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self.done=nil
	self.wait=nil
	self.ent=nil
	self:CallHook("Initialize")
end

function SWEP:Go(ent, trace, keydown1, keydown2)
	if not IsValid(ent) and not ent:IsWorld() then return end
	
	local hooks={}
	hooks.canuse=hook.Call("PlayerUse", GAMEMODE, self.Owner, ent)
	hooks.canmove=hook.Call("PhysgunPickup", GAMEMODE, self.Owner, ent)
	hooks.cantool=hook.Call("CanTool", GAMEMODE, self.Owner, self.Owner:GetEyeTraceNoCursor(), "")
	local class=ent:GetClass()
	for k,v in ipairs(self.functions) do
		v(self,{class=class,ent=ent,hooks=hooks,keydown1=keydown1,keydown2=keydown2,trace=trace})
	end
end

function SWEP:Reload()
	self:CallHook("Reload")
end

function SWEP:FirstThink()
	local id=self.Owner:GetInfo("sonic_model","default")
	self:SetSonicID(id)
	local sonic=self:GetSonic()
	self.ViewModel=sonic.ViewModel
	self.WorldModel=sonic.WorldModel
	self:SetModel(self.WorldModel)
end

function SWEP:Think()
	if not self.firstthink then
		self:FirstThink()
		self.firstthink=true
	end
	local keydown1=self.Owner:KeyDown(IN_ATTACK)
	local keydown2=self.Owner:KeyDown(IN_ATTACK2)
	
	if keydown1 or keydown2 then
		if (keydown1 and keydown2) and self.Owner.linked_tardis and IsValid(self.Owner.linked_tardis) then
			self.wait=CurTime()+self.WaitTime
		else
			local trace = util.QuickTrace( self.Owner:GetShootPos(), self.Owner:GetAimVector() * 1000, { self.Owner } )
			if not self.ent and not self.wait and trace.Entity then
				self.ent=trace.Entity
				self.wait=CurTime()+self.WaitTime
			end
			if CurTime() > self.wait and self.ent==trace.Entity and not self.done then
				self:Go(trace.Entity, trace, keydown1, keydown2)
				self.done=true
			end
			if (self.done and not self.ent==trace.Entity) or not (self.ent==trace.Entity) then
				self.done=nil
				self.wait=nil
				self.ent=nil
			end
		end
	else
		self.done=nil
		self.wait=nil
		self.ent=nil
	end
	
	self:CallHook("Think",keydown1,keydown2)
end