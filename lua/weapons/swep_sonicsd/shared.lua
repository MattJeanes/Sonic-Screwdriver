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
	self.eyeangles=Angle(0,0,0)
	self.done=nil
	self.wait=nil
	self.ent=nil
end
 
//--------------------------------------------
// Called when it reloads 
//--------------------------------------------
function SWEP:Reload() 
	// All reload code goes in here
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

function SWEP:Go(ent, keydown1, keydown2)
	if not IsValid(ent) then return end
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
	elseif ent.isWacAircraft then
		ent:setEngine(!ent.active)
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
			ent.Victim=self.Owner
			msg="The Weeping Angel has been un-frozen in time."
		else
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
	end
	if not (msg=="") then self.Owner:ChatPrint(msg) end	
end
 
//--------------------------------------------
// Called each frame when the Swep is active
//--------------------------------------------
function SWEP:Think()
	if CLIENT then return end
	if not self.sound then self:Initialize() end
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
			self:Go(trace.Entity, keydown1, keydown2)
			self.done=true
		end
		if (self.done and not self.ent==trace.Entity) or not (self.ent==trace.Entity) then
			self.done=nil
			self.wait=nil
			self.ent=nil
		end
	else
		if self.sound:IsPlaying() then
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