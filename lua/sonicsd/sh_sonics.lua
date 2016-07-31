-- Sonics

SonicSD.sonics={}
function SonicSD:AddSonic(t)
	local base = table.Copy(self.sonics[t.Base] or self.sonics.default)
	if base then
		table.Merge(base,t)
		self.sonics[t.ID]=base
	else
		self.sonics[t.ID]=t
	end
end

SonicSD:LoadFolder("sonics",false,true)