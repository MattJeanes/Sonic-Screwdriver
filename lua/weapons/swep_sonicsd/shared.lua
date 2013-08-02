//----------------------------------------------
//Author Info
//----------------------------------------------
SWEP.Author             = "Dr. Matt"
SWEP.Contact            = "mattjeanes23@gmail.com"
SWEP.Purpose            = "Opening doors"
SWEP.Instructions       = "Point and press"
SWEP.Category			= "Doctor Who"
//----------------------------------------------
 
SWEP.Spawnable = true
SWEP.AdminSpawnable = true


SWEP.UseHands = true
// First person Model
SWEP.ViewModel = "models/weapons/c_sonicsd.mdl"
// Third Person Model
SWEP.WorldModel = "models/weapons/w_sonicsd.mdl"

// Weapon Details
SWEP.Primary.Clipsize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Clipsize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "pistol"

SWEP.WaitTime = 0.5

if SERVER then
	util.AddNetworkString("Sonic-SetLinkedTARDIS")
elseif CLIENT then
	net.Receive("Sonic-SetLinkedTARDIS", function()
		LocalPlayer().linked_tardis=net.ReadEntity()
	end)
end

//--------------------------------------------
// Called on initilization
//--------------------------------------------
function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	if CLIENT then
		self.curbeep=0
		self.eyeangles=Angle(0,0,0)
		self.sound=CreateSound(self,"sonicsd/loop.wav")
		self.emitter = ParticleEmitter(self:GetPos())
		self.rgb = string.Explode(" ", GetConVarString("cl_weaponcolor")) // getting weapon color for effect
		for k,v in pairs(self.rgb) do self.rgb[k]=v*255 end // initially a vector, gotta make it RGB
		self.drawlight = CreateClientConVar( "sonic_drawlight", "1", true, false )
	elseif SERVER then
		self.done=nil
		self.wait=nil
		self.ent=nil
		self.reloadcur=0
	end
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

function SWEP:Go(ent, hitpos, keydown1, keydown2)
	if not IsValid(ent) and not ent:IsWorld() then return end
	
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
		if keydown1 and not keydown2 then
			if self.Owner.linked_tardis==e then
				locked=e:ToggleLocked()
				if locked then
					msg="TARDIS locked."
				else
					msg="TARDIS unlocked."
				end
			else
				self.Owner.linked_tardis=e
				net.Start("Sonic-SetLinkedTARDIS")
					net.WriteEntity(e)
				net.Send(self.Owner)
				msg="TARDIS linked."
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
	elseif class=="prop_thumper" and hooks.cantool then
		local enabled=tobool(ent:GetSaveTable().m_bEnabled)
		if enabled then
			ent:Fire("Disable", 0)
		else
			ent:Fire("Enable", 0)
		end
	elseif class=="worldspawn" and ent:IsWorld() and self.Owner.linked_tardis then
		local ang=self.Owner:GetAngles()
		self.Owner.tardis_vec=hitpos
		self.Owner.tardis_ang=Angle(0,ang.y+180,0)
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
	if CLIENT then return end
	if CurTime()>self.reloadcur then
		self.reloadcur=CurTime()+1
		if self.Owner.linked_tardis and IsValid(self.Owner.linked_tardis) and not self.Owner.linked_tardis.moving and self.Owner.tardis_vec and self.Owner.tardis_ang then
			self:MoveTARDIS(self.Owner.linked_tardis)
			self.Owner:ChatPrint("TARDIS moving to set destination.")
		elseif self.Owner.linked_tardis and IsValid(self.Owner.linked_tardis) and not self.Owner.linked_tardis.moving and not self.Owner.tardis_vec and not self.Owner.tardis_ang then
			local trace=util.QuickTrace( self.Owner:GetShootPos(), self.Owner:GetAimVector() * 99999, { self.Owner } )
			local ang=self.Owner:GetAngles()
			self.Owner.tardis_vec=trace.HitPos
			self.Owner.tardis_ang=Angle(0,ang.y+180,0)
			self:MoveTARDIS(self.Owner.linked_tardis)
			self.Owner:ChatPrint("TARDIS moving to AimPos.")
		end
	end
end

function SWEP:OnRestore()
	self:Initialize()
end

function SWEP:OnRemove()
	if self.sound then self.sound:Stop() end
end

function SWEP:Holster( wep )
	if self.sound then self.sound:Stop() end
	return true
end

function SWEP:PreDrawViewModel(vm,ply,wep)
	if CLIENT then
		local cureffect=0
		local keydown1=LocalPlayer():KeyDown(IN_ATTACK)
		local keydown2=LocalPlayer():KeyDown(IN_ATTACK2)
		if (keydown1 or keydown2) and self.drawlight:GetBool()==true and CurTime()>cureffect then
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
	end
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
 
//--------------------------------------------
// Called each frame when the Swep is active
//--------------------------------------------
function SWEP:Think()
	local keydown1=self.Owner:KeyDown(IN_ATTACK)
	local keydown2=self.Owner:KeyDown(IN_ATTACK2)
	
	if keydown1 or keydown2 then
		if CLIENT then
			local diff=self.Owner:EyeAngles()-self.eyeangles
			if diff.p < 0 then diff.p=-diff.p end
			if diff.y < 0 then diff.y=-diff.y end
			local pitch=diff.p+diff.y*15
			self.sound:ChangePitch(math.Clamp(pitch+100,100,150),0.1)
			self.eyeangles=self.Owner:EyeAngles()
			if not self.sound:IsPlaying() then
				self.sound:Play()
			end
		end
		
		if (keydown1 and keydown2) and self.Owner.linked_tardis and IsValid(self.Owner.linked_tardis) then
			if CLIENT and CurTime()>self.curbeep then
				local tardis=self.Owner.linked_tardis
				if self:PointingAt(tardis) then
					self.curbeep=CurTime()+0.4
					self:EmitSound("sonicsd/beep.wav")
				else
					self.curbeep=CurTime()+1
					self:EmitSound("sonicsd/beep.wav")
				end
			end
			if SERVER then
				self.wait=CurTime()+self.WaitTime
			end
		elseif SERVER then
			local trace = util.QuickTrace( self.Owner:GetShootPos(), self.Owner:GetAimVector() * 1000, { self.Owner } )
			if not self.ent and not self.wait and trace.Entity then
				self.ent=trace.Entity
				self.wait=CurTime()+self.WaitTime
			end
			if CurTime() > self.wait and self.ent==trace.Entity and not self.done then
				self:Go(trace.Entity, trace.HitPos, keydown1, keydown2)
				self.done=true
			end
			if (self.done and not self.ent==trace.Entity) or not (self.ent==trace.Entity) then
				self.done=nil
				self.wait=nil
				self.ent=nil
			end
		end
		
		return
	end
	
	if CLIENT and self.sound and self.sound:IsPlaying() then
		self.sound:Stop()
	end
	self.done=nil
	self.wait=nil
	self.ent=nil
end 
 
//--------------------------------------------
// Called when the player Shoots
//--------------------------------------------
function SWEP:PrimaryAttack()
end
 
 
//--------------------------------------------
// Called when the player Uses secondary attack
//--------------------------------------------
function SWEP:SecondaryAttack() 
end