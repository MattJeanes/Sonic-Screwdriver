
matproxy.Add(
{
    name    =   "SonicSDColor",

    init    =   function( self, mat, values )

        self.ResultTo = values.resultvar

    end,

    bind    =   function( self, mat, ent )

        if not IsValid( ent ) then return end

        local owner = ent:GetOwner();
        if not (IsValid(owner) and owner:IsPlayer()) then return end

        local col1 = Vector(GetConVarNumber("sonic_light_r")/255, GetConVarNumber("sonic_light_g")/255, GetConVarNumber("sonic_light_b")/255)
        local col2 = Vector(GetConVarNumber("sonic_light2_r")/255, GetConVarNumber("sonic_light2_g")/255, GetConVarNumber("sonic_light2_b")/255)
        if not isvector( col1 and col2 ) then return end

        local keydown1=owner:KeyDown(IN_ATTACK)
        local keydown2=owner:KeyDown(IN_ATTACK2)

        local mul
        if keydown1 or keydown2 then
            mul = 4.0 + math.sin( CurTime() * 5 ) * 0.25
        else
            mul = 0.7
        end

        if keydown1 then
            col = col1
        else
            col = col2
        end

        mat:SetVector( self.ResultTo, col * mul );

    end
})
