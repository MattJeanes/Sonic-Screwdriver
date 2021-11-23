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

	local weap = {}

	weap.Category = "Doctor Who"
	weap.PrintName = t.Name
	if file.Exists("materials/vgui/weapons/sonic/"..t.ID..".vtf", "GAME")
	then
		weap.IconOverride="vgui/weapons/sonic/"..t.ID..".vtf"
	else
		weap.IconOverride="vgui/weapons/sonic/"..t.ID..".png"
	end
	weap.ScriptedEntityType = "sonic_screwdriver"
	list.Set("Weapon", t.ID, weap)
	print("ADDED SONIC SWEP "..t.ID)

end


hook.Add("PostGamemodeLoaded", "sonic-skins", function()
	if not spawnmenu then return end
	spawnmenu.AddContentType("sonic_screwdriver", function(container, obj)
		--if not obj.material then return end
		--if not obj.nicename then return end
		--if not obj.spawnname then return end
		print("ADDED CONTENT TYPE")

		local icon = vgui.Create("ContentIcon", container)
		icon:SetContentType("weapon")
		--icon:SetSpawnName(obj.spawnname)
		icon:SetName(obj.nicename)
		icon:SetMaterial(obj.material)
		icon:SetAdminOnly(obj.admin)
		icon:SetColor(Color(205, 92, 92, 255))
		icon.DoClick = function()
			--RunConsoleCommand("tardis2_spawn", obj.spawnname)
			surface.PlaySound("ui/buttonclickrelease.wav")
		end

		if IsValid(container) then
			container:Add(icon)
		end

		return icon
	end)
end)


SonicSD:LoadFolder("sonics",false,true)