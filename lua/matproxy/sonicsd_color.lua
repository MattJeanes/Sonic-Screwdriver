
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

        local col = Vector(GetConVarNumber("sonic_light_r")/255, GetConVarNumber("sonic_light_g")/255, GetConVarNumber("sonic_light_b")/255)
        if not isvector( col ) then return end

        local keydown1=owner:KeyDown(IN_ATTACK)
        local keydown2=owner:KeyDown(IN_ATTACK2)

        local mul
        if keydown1 or keydown2 then
            mul = 1.5 + math.sin( CurTime() * 5 ) * 0.75
        else
            mul = 0.05
        end

        mat:SetVector( self.ResultTo, col * mul );

    end
})
