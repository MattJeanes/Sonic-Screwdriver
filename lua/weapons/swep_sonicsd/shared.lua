//----------------------------------------------
//Author Info
//----------------------------------------------
SWEP.Author             = "Dr. Matt"
SWEP.Contact            = "mattjeanes23@gmail.com"
SWEP.Purpose            = "Opening doors"
SWEP.Instructions       = "Point and press"
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

SWEP.WaitTime = 1

//--------------------------------------------
// Called on initilization
//--------------------------------------------
function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self.sound=CreateSound(self,"sonicsd/loop.wav")
	if CLIENT then
		self.emitter = ParticleEmitter(self:GetPos())
		self.rgb = string.Explode(" ", GetConVarString("cl_weaponcolor")) // getting weapon color for effect
		for k,v in pairs(self.rgb) do self.rgb[k]=v*255 end // initially a vector, gotta make it RGB
		self.drawlight = CreateClientConVar( "sonic_drawlight", "1", true, false )
	end
	self.eyeangles=Angle(0,0,0)
	self.done=nil
	self.wait=nil
	self.ent=nil
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
	/* -- this will be better implemented at another time
	local allowed=hook.Call("PhysgunPickup", GAMEMODE, self.Owner, ent)
	if not allowed then return end
	*/
	local class=ent:GetClass()
	local msg=""
	if self:IsDoor(class) then
		local savetable = ent:GetSaveTable()
		local open=(not tobool(savetable.m_toggle_state))
		local locked=tobool(savetable.m_bLocked)
		if locked and keydown2 then
			ent:Fire("Unlock", 0)
			ent:EmitSound("doors/door_latch3.wav")
			msg="Door unlocked."
		elseif not locked and keydown2 then
			ent:Fire("Lock", 0)
			ent:EmitSound("doors/door_latch3.wav")
			msg="Door locked."
		end
		if keydown1 and not keydown2 then
			if locked then
				msg="Door locked, right click to open"
			else
				ent:Fire("Toggle", 0)
			end
		end
	elseif ent.isWacAircraft then //new base
		ent:setEngine(!ent.active)
	elseif (string.find(class, "wac_hc_") or string.find(class, "wac_pl_")) and not ent.isWacAircraft then //old base
		ent:SwitchState()
	elseif class=="func_button" then
		ent:Fire("Press", 0)
	elseif class=="gmod_button" then
		ent:Use( self.Owner, self, USE_ON, 0 )
	elseif class=="npc_combine_camera" then
		ent:Fire("Toggle", 0)
	elseif class=="npc_turret_floor" or class=="npc_rollermine" then
		local hacked=tobool(ent:GetSaveTable().m_bHackedByAlyx)
		ent:SetSaveValue("m_bHackedByAlyx", (not hacked))
		if not hacked then //this is because the variable is reversed after 'hacked' is set.	
			msg="NPC now friendly."
		else
			msg="NPC no longer friendly."
		end
	elseif class=="npc_turret_ceiling" then
		ent:Fire("Toggle",0)
	elseif class=="npc_cscanner" or class=="npc_clawscanner" then
		ent:Fire("Break", 0)
	elseif class=="npc_manhack" then
		ent:Fire("InteractivePowerDown", 0)
	elseif class=="pewpew_base_cannon" then
		ent:FireBullet()
	elseif class=="func_breakable" or class=="func_breakable_surf" or class=="func_physbox" then
		ent:Fire("Break", 0)
	elseif class=="func_tracktrain" then
		if keydown1 and not keydown2 then
			ent:Fire("Toggle", 0)
		elseif keydown2 and not keydown1 then
			ent:Fire("Reverse", 0)
		end
	elseif class=="prop_physics" or class=="prop_physics_multiplayer" then
		if ent:GetSaveTable().max_health > 1 then
			ent:Fire("Break", 0)
		end
	elseif class=="item_item_crate" then
		ent:TakeDamage(100, self.Owner, self) //ent:Fire("Break", 0) crashed the game
	elseif class=="npc_helicopter" then
		if keydown1 and not keydown2 then
			ent:Fire("MissileOff", 0)
			ent:Fire("GunOff", 0)
			msg="Helicopter weaponry disabled."
		elseif keydown2 and not keydown1 then
			ent:Fire("GunOn", 0)
			ent:Fire("MissileOn", 0)
			msg="Helicopter weaponry enabled."
		end
	elseif class=="npc_barnacle" then
		ent:Fire("LetGo", 0)
	elseif class=="func_movelinear" then
		if keydown1 and not keydown2 then
			ent:Fire("Open", 0)
		elseif keydown2 and not keydown1 then
			ent:Fire("Close", 0)
		end
	elseif class=="weepingangel" then
		if ent.Victim == nil then
			local newvictim=self.Owner
			if ent.OldVictim and IsValid(ent.OldVictim) and ent.OldVictim:IsPlayer() then
				newvictim=ent.OldVictim
			end
			ent.Victim=newvictim
			ent.OldVictim=nil
			msg="The Weeping Angel has been un-frozen in time and is now chasing "..newvictim:Nick()
		else
			ent.OldVictim=ent.Victim
			ent.Victim=nil
			msg="The Weeping Angel has been frozen in time."
		end
	elseif class=="gmod_wire_button" then
		ent:Switch(not ent:IsOn())
	elseif class=="combine_mine" then
		local hacked=tobool(ent:GetSaveTable().m_bPlacedByPlayer)
		ent:SetSaveValue("m_bPlacedByPlayer", (not hacked))
		if not hacked then //this is because the variable is reversed after 'hacked' is set.	
			msg="Hopper Mine now friendly."
		else
			msg="Hopper Mine no longer friendly."
		end
	elseif class=="npc_turret_ground" then
		ent:SetSaveValue("m_IdealNPCState",7)
	elseif class=="worldspawn" and ent:IsWorld() then
		if IsValid(self.tardis) then
			local ang=self.Owner:GetAngles()
			self.tardis.vec=hitpos
			self.tardis.ang=Angle(0,ang.y+180,0)
			msg="TARDIS destination set."
		else
			msg="Please link a TARDIS."
		end
	elseif class=="sent_tardis" then
		if keydown1 and not keydown2 then
			self.tardis=ent
			msg="TARDIS linked."
		elseif keydown2 and not keydown1 then
			if ent.vec and ent.ang then
				ent:Go()
			end
		end
	end
	if not (msg=="") then self.Owner:ChatPrint(msg) end
end

function SWEP:Reload()
	if self.tardis and IsValid(self.tardis) and not self.tardis.moving and self.tardis.vec and self.tardis.ang then
		self.tardis:Go()
		self.Owner:ChatPrint("TARDIS moving to set destination.")
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
		if (LocalPlayer():KeyDown(IN_ATTACK) or LocalPlayer():KeyDown(IN_ATTACK2)) and self.drawlight:GetBool()==true and CurTime()>cureffect then
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
 
//--------------------------------------------
// Called each frame when the Swep is active
//--------------------------------------------
function SWEP:Think()
	if CLIENT then return end
	local keydown1=self.Owner:KeyDown(IN_ATTACK)
	local keydown2=self.Owner:KeyDown(IN_ATTACK2)
	if keydown1 or keydown2 then
		local diff=self.Owner:EyeAngles()-self.eyeangles
		if diff.p < 0 then diff.p=-diff.p end
		if diff.y < 0 then diff.y=-diff.y end
		local pitch=diff.p+diff.y*2.5
		self.sound:ChangePitch(math.Clamp(pitch+100,100,150),0)
		self.eyeangles=self.Owner:EyeAngles()
		if not self.sound:IsPlaying() then
			self.sound:Play()
		end
		
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
	else
		if self.sound and self.sound:IsPlaying() then
			self.sound:Stop()
		end
		self.done=nil
		self.wait=nil
		self.ent=nil
	end
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