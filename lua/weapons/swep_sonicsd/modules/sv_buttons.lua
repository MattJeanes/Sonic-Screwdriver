-- Buttons

SWEP:AddFunction(function(self,data)
	if data.class=="func_button" and data.hooks.canuse then
		data.ent:Fire("Press", 0)
	end
end)

SWEP:AddFunction(function(self,data)
	if (data.class=="gmod_button" or data.class=="gmod_wire_button") and data.hooks.canuse then
		data.ent:Use( self.Owner, self, USE_ON, 0 )
	end
end)