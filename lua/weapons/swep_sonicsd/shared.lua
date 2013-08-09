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