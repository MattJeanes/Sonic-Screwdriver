-- Props

SWEP:AddFunction(function(self,data)
    if (data.class=="func_breakable" or data.class=="func_breakable_surf" or data.class=="func_physbox") and data.hooks.cantool then
        data.ent:Fire("Break", 0)
    end
end)

SWEP:AddFunction(function(self,data)
    if (data.class=="prop_physics" or data.class=="prop_physics_multiplayer") and data.hooks.canmove then
        local phys=data.ent:GetPhysicsObject()
        if IsValid(phys) then
            local multiplier
            if data.keydown1 then
                multiplier = 200
            elseif data.keydown2 then
                multiplier = -200
            end

            if multiplier ~= nil then
                phys:AddVelocity(self.Owner:GetAimVector()*multiplier)
            end
        end
        if (data.ent:GetSaveTable().max_health > 1) and data.hooks.cantool then
            data.ent:Fire("Break", 0)
        end
    end
end)

SWEP:AddFunction(function(self,data)
    if data.class=="item_item_crate" and data.hooks.cantool then
        data.ent:TakeDamage(100, self.Owner, self) --data.ent:Fire("Break", 0) crashed the game
    end
end)