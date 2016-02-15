-- Sonics

SonicSD.sonics={}
function SonicSD:AddSonic(t)
	self.sonics[t.ID]=t
end

SonicSD:LoadFolder("sonics",false,true)