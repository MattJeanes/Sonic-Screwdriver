-- Wiremod

SWEP:AddFunction(function(self,data)
	if data.class=="gmod_wire_keypad" and WireLib and data.hooks.cantool then
		-- bit hacky but the keypad hates everyone
		if data.keydown1 and not data.keydown2 then
			data.ent:SetNetworkedString("keypad_display", "y")
			Wire_TriggerOutput(data.ent, "Valid", 1)
			data.ent:EmitSound("buttons/button9.wav")
		elseif data.keydown2 and not data.keydown1 then
			data.ent:SetNetworkedString("keypad_display", "n")
			Wire_TriggerOutput(data.ent, "Invalid", 1)
			data.ent:EmitSound("buttons/button8.wav")
		end
		if (data.keydown1 and not data.keydown2) or (data.keydown2 and not data.keydown1) then
			data.ent.CurrentNum = -1
			timer.Create("wire_keypad_"..data.ent:EntIndex().."_"..tostring((data.keydown1 and not data.keydown2)), 2, 1, function()
				if IsValid(data.ent) then
					data.ent:SetNetworkedString("keypad_display", "")
					data.ent.Currdata.entNum = 0
					if access then
						Wire_TriggerOutput(data.ent, "Valid", 0)
					else
						Wire_TriggerOutput(data.ent, "Invalid", 0)
					end
				end
			end)
		end
	end
end)

SWEP:AddFunction(function(self,data)
	if data.class=="wired_door" and WireLib and data.hooks.cantool then
		if data.keydown1 and not data.keydown2 then
			data.ent:openself()
		elseif data.keydown2 and not data.keydown1 then
			data.ent:closeself()
		end
	end
end)