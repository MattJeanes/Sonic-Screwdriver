
matproxy.Add(
{
	name	=	"SonicSDColor",

	init	=	function( self, mat, values )

		self.ResultTo = values.resultvar

	end,

	bind	=	function( self, mat, ent )

		if not IsValid( ent ) then return end

		local owner = ent:GetOwner();
		if not (IsValid(owner) and owner:IsPlayer()) then return end

		local col = Vector(GetConVarNumber("sonic_light_r")/255, GetConVarNumber("sonic_light_g")/255, GetConVarNumber("sonic_light_b")/255)
		if not isvector( col ) then return end

		local mul = (1 + math.sin( CurTime() * 5 ) ) * 0.5

		mat:SetVector( self.ResultTo, col + col * mul );

	end
})
