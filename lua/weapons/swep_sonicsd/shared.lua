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
SWEP.Models = {
	[0] = {
		"models/weapons/c_sonicsd.mdl", -- View model
		"models/weapons/w_sonicsd.mdl", -- World model
		Vector(20,-1.75,-2.75), -- Particle light offset
		5 -- Particle light brightness
	},
	[1] = {
		"models/doctor_who/sonic_screwdriver/c_10thsonicsd.mdl",
		"models/doctor_who/sonic_screwdriver/w_10thsonicsd.mdl",
		Vector(20,-2.5,-3.15),
		2
	},
	[2] = {
		"models/doctor_who/sonic_screwdriver/c_4thsonicsd.mdl",
		"models/doctor_who/sonic_screwdriver/w_4thsonicsd.mdl",
		Vector(20,-2.1,-2.3),
		5
	}
}

function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "SonicModel" );
end

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

SWEP.functions={}

function SWEP:AddFunction(func)
	table.insert(self.functions,func)
end

SWEP.hooks={}

-- Hook system for modules
function SWEP:AddHook(name,id,func)
	if not (self.hooks[name]) then self.hooks[name]={} end
	self.hooks[name][id]=func
end

function SWEP:RemoveHook(name,id)
	if self.hooks[name] and self.hooks[name][id] then
		self.hooks[name][id]=nil
	end
end

function SWEP:CallHook(name,...)
	if not self.hooks[name] then return end
	local a,b,c,d,e,f
	for k,v in pairs(self.hooks[name]) do
		a,b,c,d,e,f = v(self,...)
		if ( a != nil ) then
			return a,b,c,d,e,f
		end
	end
end

function SWEP:LoadFolder(folder,addonly,noprefix)
	folder="weapons/swep_sonicsd/"..folder.."/"
	local modules = file.Find(folder.."*.lua","LUA")
	for _, plugin in ipairs(modules) do
		if noprefix then
			if SERVER then
				AddCSLuaFile(folder..plugin)
			end
			if not addonly then
				include(folder..plugin)
			end
		else
			local prefix = string.Left( plugin, string.find( plugin, "_" ) - 1 )
			if (CLIENT and (prefix=="sh" or prefix=="cl")) then
				if not addonly then
					include(folder..plugin)
				end
			elseif (SERVER) then
				if (prefix=="sv" or prefix=="sh") and (not addonly) then
					include(folder..plugin)
				end
				if (prefix=="sh" or prefix=="cl") then
					AddCSLuaFile(folder..plugin)
				end
			end
		end
	end
end
SWEP:LoadFolder("modules")

function SWEP:OnRestore()
	self:Initialize()
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