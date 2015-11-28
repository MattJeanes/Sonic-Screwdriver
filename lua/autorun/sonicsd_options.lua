//Sonic Screwdriver Spawnmenu Options

local checkbox_options={
	{"Sound", "sonic_sound"},
	{"Particle light", "sonic_light"},
	{"Dynamic light", "sonic_dynamiclight"},
}

for k,v in pairs(checkbox_options) do
	CreateClientConVar(v[2], "1", true)
end

CreateClientConVar("sonic_light_r", "0", true)
CreateClientConVar("sonic_light_g", "255", true)
CreateClientConVar("sonic_light_b", "0", true)
CreateClientConVar("sonic_model", "0", true, true)

hook.Add("PopulateToolMenu", "SonicSD-PopulateToolMenu", function()
	spawnmenu.AddToolMenuOption("Options", "Doctor Who", "Sonic_Options", "Sonic Screwdriver", "", "", function(panel)
		panel:ClearControls()
		
		local Mixer1 = vgui.Create( "DColorMixer" )
		Mixer1:SetPalette( true )  		--Show/hide the palette			DEF:true
		Mixer1:SetAlphaBar( false ) 		--Show/hide the alpha bar		DEF:true
		Mixer1:SetWangs( true )	 		--Show/hide the R G B A indicators 	DEF:true
		Mixer1:SetColor( Color(GetConVarNumber("sonic_light_r"), GetConVarNumber("sonic_light_g"), GetConVarNumber("sonic_light_b")) )	--Set the default color
		Mixer1.ValueChanged = function(self,col)
			RunConsoleCommand("sonic_light_r", col.r)
			RunConsoleCommand("sonic_light_g", col.g)
			RunConsoleCommand("sonic_light_b", col.b)
		end
		panel:AddItem(Mixer1)
		
		local checkboxes={}
		for k,v in pairs(checkbox_options) do
			CreateClientConVar(v[2], "1", true)
			local checkBox = vgui.Create( "DCheckBoxLabel" ) 
			checkBox:SetText( v[1] ) 
			checkBox:SetValue( GetConVarNumber( v[2] ) )
			checkBox:SetConVar( v[2] )
			panel:AddItem(checkBox)
			table.insert(checkboxes, checkBox)
		end
		
		local skins={
			{"2010 Model", 0},
			{"2005 Model", 1},
			{"1968 Model", 2}	
		}
		local comboBox = vgui.Create("DComboBox")
		comboBox:SetText("Model")
		for k,v in ipairs(skins) do
			comboBox:AddChoice(v[1])
		end
		for k,v in pairs(skins) do
			if GetConVarNumber("sonic_model")==v[2] then
				comboBox:ChooseOption(v[1])
			end
		end
		comboBox.OnSelect = function(panel,index,value,data)
			local n=0
			for k,v in pairs(skins) do
				if value==v[1] then
					n=v[2]
				end
			end
			RunConsoleCommand("sonic_model", n)
		end
		panel:AddItem(comboBox)
	end)
end)