AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("shared.lua")
include ("shared.lua")
 
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.WaitTime = 0.5

util.AddNetworkString("Sonic-SetLinkedTARDIS")

//--------------------------------------------
// Called on initilization
//--------------------------------------------
function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self.done=nil
	self.wait=nil
	self.ent=nil
	self.reloadcur=0
end

function SWEP:IsDoor(class)
	local t={"func_door", "func_door_rotating", "prop_door_rotating"}
	for k,v in pairs(t) do
		if class==v then
			return true
		end
	end
	return false
end

function SWEP:Go(ent, trace, keydown1, keydown2)
	if not IsValid(ent) and not ent:IsWorld() then return end
	
	local hitpos=trace.HitPos
	local hitnorm=trace.HitNormal
	
	//hooks time, for prop protection addons and stuff!
	local hooks={}
	hooks.canuse=hook.Call("PlayerUse", GAMEMODE, self.Owner, ent)
	hooks.canmove=hook.Call("PhysgunPickup", GAMEMODE, self.Owner, ent)
	hooks.cantool=hook.Call("CanTool", GAMEMODE, self.Owner, self.Owner:GetEyeTraceNoCursor(), "")
	
	local class=ent:GetClass()
	local msg=""
	if self:IsDoor(class) then
		local savetable = ent:GetSaveTable()
		local open=(not tobool(savetable.m_toggle_state))
		local locked=tobool(savetable.m_bLocked)
		if locked and keydown2 and hooks.cantool then
			ent:Fire("Unlock", 0)
			ent:EmitSound("doors/door_latch3.wav")
			msg="Door unlocked."
		elseif not locked and keydown2 and hooks.cantool then
			ent:Fire("Lock", 0)
			ent:EmitSound("doors/door_latch3.wav")
			msg="Door locked."
		end
		if keydown1 and not keydown2 and hooks.canuse then
			if locked then
				msg="Door locked, right click to open"
			else
				ent:Fire("Toggle", 0)
			end
		end
	elseif ent.isWacAircraft and hooks.cantool then //new base
		ent:setEngine(!ent.active)
	elseif (string.find(class, "wac_hc_") or string.find(class, "wac_pl_")) and not ent.isWacAircraft and hooks.cantool then //old base
		ent:SwitchState()
	elseif class=="func_button" and hooks.canuse then
		ent:Fire("Press", 0)
	elseif (class=="gmod_button" or class=="gmod_wire_button") and hooks.canuse then
		ent:Use( self.Owner, self, USE_ON, 0 )
	elseif class=="npc_combine_camera" and hooks.cantool then
		ent:Fire("Toggle", 0)
	elseif (class=="npc_turret_floor" or class=="npc_rollermine") and hooks.cantool then
		local hacked=tobool(ent:GetSaveTable().m_bHackedByAlyx)
		ent:SetSaveValue("m_bHackedByAlyx", (not hacked))
		if not hacked then //this is because the variable is reversed after 'hacked' is set.	
			msg="NPC now friendly."
		else
			msg="NPC no longer friendly."
		end
	elseif class=="npc_turret_ceiling" and hooks.cantool then
		ent:Fire("Toggle",0)
	elseif (class=="npc_cscanner" or class=="npc_clawscanner") and hooks.cantool then
		ent:Fire("Break", 0)
	elseif class=="npc_manhack" and hooks.cantool then
		ent:Fire("InteractivePowerDown", 0)
	elseif class=="pewpew_base_cannon" and hooks.cantool then
		ent:FireBullet()
	elseif (class=="func_breakable" or class=="func_breakable_surf" or class=="func_physbox") and hooks.cantool then
		ent:Fire("Break", 0)
	elseif class=="func_tracktrain" and hooks.canuse then
		if keydown1 and not keydown2 then
			ent:Fire("Toggle", 0)
		elseif keydown2 and not keydown1 then
			ent:Fire("Reverse", 0)
		end
	elseif (class=="prop_physics" or class=="prop_physics_multiplayer") and hooks.canmove then
		local phys=ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:AddVelocity(self.Owner:GetAimVector()*200)
		end
		if (ent:GetSaveTable().max_health > 1) and hooks.cantool then
			ent:Fire("Break", 0)
		end
	elseif class=="item_item_crate" and hooks.cantool then
		ent:TakeDamage(100, self.Owner, self) //ent:Fire("Break", 0) crashed the game
	elseif class=="npc_helicopter" and hooks.cantool then
		if keydown1 and not keydown2 then
			ent:Fire("MissileOff", 0)
			ent:Fire("GunOff", 0)
			msg="Helicopter weaponry disabled."
		elseif keydown2 and not keydown1 then
			ent:Fire("GunOn", 0)
			ent:Fire("MissileOn", 0)
			msg="Helicopter weaponry enabled."
		end
	elseif class=="npc_barnacle" and hooks.canuse then
		ent:Fire("LetGo", 0)
	elseif class=="func_movelinear" and hooks.canuse then
		if keydown1 and not keydown2 then
			ent:Fire("Open", 0)
		elseif keydown2 and not keydown1 then
			ent:Fire("Close", 0)
		end
	elseif (class=="weepingangel" or class=="cube" or class=="cube2") and hooks.cantool then
		if ent.Victim == nil then
			local newvictim=self.Owner
			if ent.OldVictim and IsValid(ent.OldVictim) and ent.OldVictim:IsPlayer() then
				newvictim=ent.OldVictim
			end
			ent.Victim=newvictim
			ent.OldVictim=nil
			local name="Weeping Angel"
			if class=="cube" or class=="cube2" then name="Cube" end
			msg="The "..name.." has been un-frozen in time and is now chasing "..newvictim:Nick()
		else
			ent.OldVictim=ent.Victim
			ent.Victim=nil
			local name="Weeping Angel"
			if class=="cube" or class=="cube2" then name="Cube" end
			msg="The "..name.." has been frozen in time."
		end
	elseif class=="combine_mine" and hooks.cantool then
		local hacked=tobool(ent:GetSaveTable().m_bPlacedByPlayer)
		ent:SetSaveValue("m_bPlacedByPlayer", (not hacked))
		if not hacked then //this is because the variable is reversed after 'hacked' is set.	
			msg="Hopper Mine now friendly."
		else
			msg="Hopper Mine no longer friendly."
		end
	elseif class=="npc_turret_ground" and hooks.cantool then
		ent:SetSaveValue("m_IdealNPCState",7)
	elseif ent:IsNPC() and hooks.cantool then
		if keydown1 and not keydown2 then
			ent:AddEntityRelationship(self.Owner, D_LI, 999)
			msg="NPC now friendly towards you."
		elseif keydown2 and not keydown1 then
			ent:AddEntityRelationship(self.Owner, D_HT, 999)
			msg="NPC no longer friendly towards you."
		end
	elseif (class=="sent_tardis" or class=="sent_tardis_interior") and hooks.cantool then
		local e
		if class=="sent_tardis_interior" then
			e=ent.tardis
		else
			e=ent
		end
		if self.Owner:KeyDown(IN_WALK) then
			if self.Owner.linked_tardis==e then
				self.Owner.linked_tardis=NULL
				net.Start("Sonic-SetLinkedTARDIS")
					net.WriteEntity(NULL)
				net.Send(self.Owner)
				msg="TARDIS unlinked."
			elseif e.owner==self.Owner then
				self.Owner.linked_tardis=e
				net.Start("Sonic-SetLinkedTARDIS")
					net.WriteEntity(e)
				net.Send(self.Owner)
				msg="TARDIS linked."
			else
				msg="You may only link a TARDIS you spawned."
			end
		else
			if keydown1 and not keydown2 then
				local success=e:ToggleLocked()
				if success then
					if e.locked then
						msg="TARDIS locked."
					else
						msg="TARDIS unlocked."
					end
				end
			elseif keydown2 and not keydown1 then
				local success=e:TogglePhase()
				if success then
					if e.visible then
						msg="TARDIS now visible."
					else
						msg="TARDIS no longer visible."
					end
				end
			end
		end
	elseif class=="prop_thumper" and hooks.cantool then
		local enabled=tobool(ent:GetSaveTable().m_bEnabled)
		if enabled then
			ent:Fire("Disable", 0)
		else
			ent:Fire("Enable", 0)
		end
	elseif class=="worldspawn" and ent:IsWorld() and self.Owner.linked_tardis then
		self.Owner.tardis_vec=hitpos
		local ang=hitnorm:Angle()
		ang:RotateAroundAxis( ang:Right( ), -90 )
		self.Owner.tardis_ang=ang
		msg="TARDIS destination set."
	end
	if not (msg=="") then self.Owner:ChatPrint(msg) end
end

function SWEP:MoveTARDIS(ent)
	ent:Go(self.Owner.tardis_vec, self.Owner.tardis_ang)
	self.Owner.tardis_vec=nil
	self.Owner.tardis_ang=nil
end

function SWEP:Reload()
	if CurTime()>self.reloadcur then
		self.reloadcur=CurTime()+1
		local tardis = self.Owner.linked_tardis
		if IsValid(self.Owner.linked_tardis) then
			if not tardis.moving and self.Owner.tardis_vec and self.Owner.tardis_ang then
				self:MoveTARDIS(self.Owner.linked_tardis)
				self.Owner:ChatPrint("TARDIS moving to set destination.")
			elseif not tardis.moving and not self.Owner.tardis_vec and not self.Owner.tardis_ang then
				local trace=util.QuickTrace( self.Owner:GetShootPos(), self.Owner:GetAimVector() * 99999, { self.Owner } )
				self.Owner.tardis_vec=trace.HitPos
				local ang=trace.HitNormal:Angle()
				ang:RotateAroundAxis( ang:Right(), -90 )
				self.Owner.tardis_ang=ang
				self:MoveTARDIS(tardis)
				self.Owner:ChatPrint("TARDIS moving to AimPos.")
			elseif tardis.moving and tardis.longflight and tardis.invortex then
				self.Owner.linked_tardis:LongReappear()
				self.Owner:ChatPrint("TARDIS materialising.")
			end
		end
	end
end

//--------------------------------------------
// Called each frame when the Swep is active
//--------------------------------------------
function SWEP:Think()
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
end