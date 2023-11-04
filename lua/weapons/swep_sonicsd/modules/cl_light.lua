-- Light

SWEP:AddHook("Initialize", "light", function(self)
    self.emitter = ParticleEmitter(self:GetPos())
    self.rgb = Color(GetConVarNumber("sonic_light_r"), GetConVarNumber("sonic_light_g"), GetConVarNumber("sonic_light_b"))
end)

SWEP:AddHook("PreDrawViewModel", "light", function(self,vm,ply,wep,keydown1,keydown2)
    local sonic=self:GetSonic()
    if sonic.LightDisabled then return end
    local cureffect=0
    if (keydown1 or keydown2) then
        local r,g,b
        if keydown1 then
            r,g,b=GetConVarNumber("sonic_light_r"),GetConVarNumber("sonic_light_g"),GetConVarNumber("sonic_light_b")
        else
            r,g,b=GetConVarNumber("sonic_light2_r"),GetConVarNumber("sonic_light2_g"),GetConVarNumber("sonic_light2_b")
        end
        if tobool(GetConVarNumber("sonic_light")) and CurTime()>cureffect then
            cureffect=CurTime()+0.05
            self.emitter:SetPos(vm:GetPos())
            local velocity = LocalPlayer():GetVelocity()
            local pos=sonic.LightPos
            local spawnpos = vm:LocalToWorld(pos)
            local particle = self.emitter:Add("sprites/glow04_noz", spawnpos)
            if (particle) then
                particle:SetVelocity(velocity)
                particle:SetLifeTime(0)
                particle:SetColor(r,g,b)
                particle:SetDieTime(0.02)
                particle:SetStartSize(3)
                particle:SetEndSize(3)
                particle:SetAirResistance(0)
                particle:SetCollide(false)
                particle:SetBounce(0)
            end
        end
        if tobool(GetConVarNumber("sonic_dynamiclight")) then
            local dlight = DynamicLight( self:EntIndex() )
            if ( dlight ) then
                local size=75
                dlight.Pos = vm:LocalToWorld(Vector(40,-1.75,0))
                dlight.r = r
                dlight.g = g
                dlight.b = b
                dlight.Brightness = sonic.LightBrightness
                dlight.Decay = size * 5
                dlight.Size = size
                dlight.DieTime = CurTime() + 1
            end
        end
    end
end)

SWEP:AddHook("SonicChanged", "default-color", function(self)
    if GetConVar("sonic_should_set_default_colors"):GetBool() then
        local son = self:GetSonic()
        if son ~= nil and son.DefaultLightColor ~= nil then
            local default = son.DefaultLightColor
            local default2 = son.DefaultLightColor2 or default
            GetConVar("sonic_light_r"):SetInt(default.r)
            GetConVar("sonic_light_g"):SetInt(default.g)
            GetConVar("sonic_light_b"):SetInt(default.b)
            GetConVar("sonic_light2_r"):SetInt(default2.r)
            GetConVar("sonic_light2_g"):SetInt(default2.g)
            GetConVar("sonic_light2_b"):SetInt(default2.b)
        end
    end
end)