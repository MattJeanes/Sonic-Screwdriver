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

	local wep = {}
	wep.Category = "Doctor Who - Sonic Tools"
	wep.PrintName = t.Name
	wep.ClassName = t.ID
	if file.Exists("materials/vgui/weapons/sonic/"..t.ID..".vtf", "GAME") then
		wep.IconOverride="vgui/weapons/sonic/"..t.ID..".vtf"
	elseif file.Exists("materials/vgui/weapons/sonic/"..t.ID..".png", "GAME") then
		wep.IconOverride="vgui/weapons/sonic/"..t.ID..".png"
	else
		wep.IconOverride="vgui/weapons/sonic/default/"..t.ID..".png"
	end
	wep.ScriptedEntityType = "sonicsd"
	wep.Spawnable = true
	list.Set("Weapon", "sonicsd-"..t.ID, wep)
end


hook.Add("PostGamemodeLoaded", "sonicsd", function()
	if not spawnmenu then return end
	spawnmenu.AddContentType("sonicsd", function(container, obj)
		if not obj.material then return end
		if not obj.nicename then return end
		if not obj.spawnname then return end

		local icon = vgui.Create("ContentIcon", container)
		icon:SetContentType("weapon")
		icon:SetSpawnName(obj.spawnname)
		icon:SetName(obj.nicename)
		icon:SetMaterial(obj.material)
		icon:SetAdminOnly(obj.admin)
		icon:SetColor(Color(205, 92, 92, 255))
		icon.DoClick = function()
			RunConsoleCommand("sonic_model", obj.spawnname)
			RunConsoleCommand("sonicsd_give", obj.spawnname)
			surface.PlaySound("ui/buttonclickrelease.wav")
		end

		if IsValid(container) then
			container:Add(icon)
		end

		return icon
	end)
end)

if SERVER then
	function SonicSD:GiveSonic(ply, command, args)
		local sonicID = args[1]
		if not IsValid(ply) then return end
		if sonicID == nil then return end
		if not ply:Alive() then return end

		local weaponName = "swep_sonicsd"

		local swep = list.Get("Weapon")[weaponName]
		if ( swep == nil ) then return end

		if ((not swep.Spawnable) and (not ply:IsAdmin())) or (swep.AdminOnly and (not ply:IsAdmin())) then
			return
		end

		if not gamemode.Call("PlayerGiveSWEP", ply, weaponName, swep) then return end

		if not ply:HasWeapon(weaponName) then
			MsgAll("Giving " .. ply:Nick() .. " a " .. weaponName .. " (" .. sonicID .. ")\n")
			ply:Give(weaponName)
		end

		local sonic = ply:GetWeapon(weaponName)
		sonic:SetSonicID(sonicID)
		ply:SelectWeapon(weaponName)
	end
	concommand.Add("sonicsd_give", function(ply, command, args)
		SonicSD:GiveSonic(ply, command, args)
	end)
end

SonicSD:LoadFolder("sonics",false,true)