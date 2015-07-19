-- Misc

SWEP:AddFunction(function(self,data)
	if data.class=="pewpew_base_cannon" and data.hooks.cantool then
		data.ent:FireBullet()
	end
end)