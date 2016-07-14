-- Doctor Who

local function IsLegacy(ent)
	return not ent.TardisExterior
end

if SERVER then
	util.AddNetworkString("Sonic-SetLinkedTARDIS")

	function SWEP:MoveTARDIS(ent)
		if IsLegacy(ent) then
			ent:Go(self.Owner.tardis_vec, self.Owner.tardis_ang)
		else
			ent:Demat(self.Owner.tardis_vec, self.Owner.tardis_ang)
		end
		self.Owner.tardis_vec=nil
		self.Owner.tardis_ang=nil
	end

	SWEP:AddHook("Reload", "doctorwho", function(self)
		local tardis = self.Owner.linked_tardis
		if IsValid(tardis) then
			local moving = (tardis.moving or (tardis.GetData and tardis:GetData("teleport",false)))
			local vortex = (tardis.invortex or (tardis.GetData and tardis:GetData("vortex",false)))
			if (not moving) and (not vortex) and self.Owner.tardis_vec and self.Owner.tardis_ang then
				self:MoveTARDIS(self.Owner.linked_tardis)
				self.Owner:ChatPrint("TARDIS moving to set destination.")
			elseif not moving and not vortex and not self.Owner.tardis_vec and not self.Owner.tardis_ang then
				local trace=util.QuickTrace( self.Owner:GetShootPos(), self.Owner:GetAimVector() * 99999, { self.Owner } )
				self.Owner.tardis_vec=trace.HitPos
				local ang=trace.HitNormal:Angle()
				ang:RotateAroundAxis( ang:Right(), -90 )
				self.Owner.tardis_ang=ang
				self:MoveTARDIS(tardis)
				self.Owner:ChatPrint("TARDIS moving to AimPos.")
			elseif ((IsLegacy(tardis) and tardis.longflight) or (not IsLegacy(tardis))) and vortex then
				if IsLegacy(tardis) then
					self.Owner.linked_tardis:LongReappear()
				else
					self.Owner.linked_tardis:Mat()
				end
				self.Owner:ChatPrint("TARDIS materialising.")
			end
		end
	end)
	
	SWEP:AddFunction(function(self,data)
		if data.ent.TardisExterior and (not self.Owner:KeyDown(IN_WALK)) then
			data.ent:ToggleDoor()
		end
	end)

	SWEP:AddFunction(function(self,data)
		if self.Owner:KeyDown(IN_WALK) and self.Owner.linked_tardis and IsValid(self.Owner.linked_tardis) and IsLegacy(self.Owner.linked_tardis) and data.keydown2 and not data.keydown1 and data.hooks.cantool then
			self.Owner.linked_tardis:SetTrackingEnt(data.ent)
			if IsValid(self.Owner.linked_tardis.trackingent) then
				self.Owner:ChatPrint("Tracking entity set.")
			else
				self.Owner:ChatPrint("Tracking disabled.")
			end
		end
	end)

	SWEP:AddFunction(function(self,data)
		if (data.class=="weepingangel" or data.class=="cube" or data.class=="cube2") and data.hooks.cantool then
			if data.ent.Victim == nil then
				local newvictim=self.Owner
				if data.ent.OldVictim and IsValid(data.ent.OldVictim) and data.ent.OldVictim:IsPlayer() then
					newvictim=data.ent.OldVictim
				end
				data.ent.Victim=newvictim
				data.ent.OldVictim=nil
				local name="Weeping Angel"
				if data.class=="cube" or data.class=="cube2" then name="Cube" end
				self.Owner:ChatPrint("The "..name.." has been un-frozen in time and is now chasing "..newvictim:Nick())
			else
				data.ent.OldVictim=data.ent.Victim
				data.ent.Victim=nil
				local name="Weeping Angel"
				if data.class=="cube" or data.class=="cube2" then name="Cube" end
				self.Owner:ChatPrint("The "..name.." has been frozen in time.")
			end
		end
	end)

	SWEP:AddFunction(function(self,data)
		if (data.class=="sent_tardis" or data.class=="sent_tardis_interior" or data.class=="gmod_tardis" or data.class=="gmod_tardis_interior") and data.hooks.cantool then
			local e
			if data.class=="sent_tardis_interior" then
				e=data.ent.tardis
			elseif data.class=="gmod_tardis_interior" then
				e=data.ent.exterior
			else
				e=data.ent
			end
			if self.Owner:KeyDown(IN_WALK) then
				if data.keydown1 and (not data.keydown2) then
					if self.Owner.linked_tardis==e then
						self.Owner.linked_tardis=NULL
						net.Start("Sonic-SetLinkedTARDIS")
							net.WriteEntity(NULL)
						net.Send(self.Owner)
						self.Owner:ChatPrint("TARDIS unlinked.")
					elseif e.owner==self.Owner or (self.Owner:IsAdmin() or self.Owner:IsSuperAdmin()) then
						self.Owner.linked_tardis=e
						net.Start("Sonic-SetLinkedTARDIS")
							net.WriteEntity(e)
						net.Send(self.Owner)
						self.Owner:ChatPrint("TARDIS linked.")
					else
						self.Owner:ChatPrint("You may only link a TARDIS you spawned.")
					end
				end
			elseif IsLegacy(e) then
				if data.keydown1 and not data.keydown2 then
					local success=e:ToggleLocked()
					if success then
						if e.locked then
							self.Owner:ChatPrint("TARDIS locked.")
						else
							self.Owner:ChatPrint("TARDIS unlocked.")
						end
					end
				elseif data.keydown2 and not data.keydown1 then
					local success=e:TogglePhase()
					if success then
						if e.visible then
							self.Owner:ChatPrint("TARDIS now visible.")
						else
							self.Owner:ChatPrint("TARDIS no longer visible.")
						end
					end
				end
			end
		end
	end)

	SWEP:AddFunction(function(self,data)
		if data.ent.tardis_part or data.ent.TardisPart then
			data.ent:Use(self.Owner, self.Owner, USE_ON, 1)
		end
	end)

	SWEP:AddFunction(function(self,data)
		if data.class=="worldspawn" and data.ent:IsWorld() and self.Owner.linked_tardis then
			if self.Owner:KeyDown(IN_WALK) then
				self.Owner.tardis_vec=nil
				self.Owner.tardis_ang=nil
				local tardis=self.Owner.linked_tardis
				if IsValid(tardis) and IsLegacy(tardis) and tardis.invortex then
					tardis:SetDestination(tardis:GetPos(),tardis:GetAngles())
				end
				self.Owner:ChatPrint("TARDIS destination unset.")
			else
				self.Owner.tardis_vec=data.trace.HitPos
				local ang=data.trace.HitNormal:Angle()
				ang:RotateAroundAxis( ang:Right( ), -90 )
				self.Owner.tardis_ang=ang
				local tardis=self.Owner.linked_tardis
				if IsValid(tardis) and IsLegacy(tardis) and tardis.invortex then
					tardis:SetDestination(data.trace.HitPos,ang)
				end
				self.Owner:ChatPrint("TARDIS destination set.")
			end
		end
	end)
else
	function SWEP:PointingAt(ent)
		if not IsValid(ent) then return end
		
		local ViewEnt = self.Owner:GetViewEntity()
		local fov = 20
		local Disp = ent:GetPos() - ViewEnt:GetPos()
		local Dist = Disp:Length()
		local Width = 100
		
		local MaxCos = math.abs( math.cos( math.acos( Dist / math.sqrt( Dist * Dist + Width * Width ) ) + fov * ( math.pi / 180 ) ) )
		Disp:Normalize()
		local dot=Disp:Dot( ViewEnt:EyeAngles():Forward() )
		local tr=self.Owner:GetEyeTraceNoCursor()
		
		if IsValid(tr.Entity) and tr.Entity==ent then
			return 0.25
		elseif dot>MaxCos then
			return math.Clamp((1-dot)*2+0.3,0.1,1)
		else
			return 1
		end
	end
	
	SWEP:AddHook("Think", "doctorwho", function(self, keydown1, keydown2)	
		if (keydown1 and keydown2) and self.Owner.linked_tardis and IsValid(self.Owner.linked_tardis) and CurTime()>self.curbeep then
			local tardis=self.Owner.linked_tardis
			local n=self:PointingAt(tardis)
			self.curbeep=CurTime()+n
			self:EmitSound("sonicsd/beep.wav")
		end
	end)
	
	net.Receive("Sonic-SetLinkedTARDIS", function(len)
		LocalPlayer().linked_tardis=net.ReadEntity()
	end)
end