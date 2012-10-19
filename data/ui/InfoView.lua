local ui = Engine.ui

local shipInfo = function (args)
	local shipId = Game.player.shipType
	local shipType = ShipType.GetShipType(shipId)

	local hyperdrive =              table.unpack(Game.player:GetEquip("ENGINE"))
	local frontWeapon, rearWeapon = table.unpack(Game.player:GetEquip("LASER"))

	hyperdrive =  hyperdrive  or "NONE"
	frontWeapon = frontWeapon or "NONE"
	rearWeapon =  rearWeapon  or "NONE"

	local stats = Game.player:GetStats()

	local equipColumn = { {}, {} }
	local t = 1
	for i = 1,#Constants.EquipType do
		local type = Constants.EquipType[i]
		local et = EquipType.GetEquipType(type)
		local slot = et.slot
		if (slot ~= "CARGO" and slot ~= "MISSILE" and slot ~= "ENGINE" and slot ~= "LASER") then
			local count = Game.player:GetEquipCount(slot, type)
			if count > 0 then
				if count > 1 then
					if type == "SHIELD_GENERATOR" then
						table.insert(equipColumn[t],
							ui:Label(string.interp("{quantity} Shield Generators", { quantity = string.format("%d", count) })))
					elseif type == "PASSENGER_CABIN" then
						table.insert(equipColumn[t],
							ui:Label(string.interp("{quantity} Occupied Passenger Cabins", { quantity = string.format("%d", count) })))
					elseif type == "UNOCCUPIED_CABIN" then
						table.insert(equipColumn[t],
							ui:Label(string.interp("{quantity} Unoccupied Passenger Cabins", { quantity = string.format("%d", count) })))
					else
						table.insert(equipColumn[t], ui:Label(et.name))
					end
				else
					table.insert(equipColumn[t], ui:Label(et.name))
				end
				t = t == 1 and 2 or 1
			end
		end
	end

	return
		ui:Grid(2,1)
			:SetColumn(0, {
				ui:VBox(20):PackEnd({
					ui:Label("Ship information"):SetFont("HEADING_LARGE"),
					ui:Grid(2,1)
						:SetColumn(0, {
							ui:VBox():PackEnd({
								ui:Label("Hyperdrive:"),
								ui:Label("Hyperspace range:"),
								ui:Margin(10),
								ui:Label("Capacity:"),
								ui:Label("Free:"),
								ui:Label("Used:"),
								ui:Label("All-up weight:"),
								ui:Margin(10),
								ui:Label("Front weapon:"),
								ui:Label("Rear weapon:"),
							})
						})
						:SetColumn(1, {
							ui:VBox():PackEnd({
								ui:Label(EquipType.GetEquipType(hyperdrive).name),
								ui:Label(string.interp(
									"{range} light years ({maxRange} max)", {
										range    = string.format("%.1f",stats.hyperspaceRange),
										maxRange = string.format("%.1f",stats.maxHyperspaceRange)
									}
								)),
								ui:Margin(10),
								ui:Label(string.format("%dt", stats.maxCapacity)),
								ui:Label(string.format("%dt", stats.freeCapacity)),
								ui:Label(string.format("%dt", stats.usedCapacity)),
								ui:Label(string.format("%dt", stats.totalMass)),
								ui:Margin(10),
								ui:Label(EquipType.GetEquipType(frontWeapon).name),
								ui:Label(EquipType.GetEquipType(rearWeapon).name),
							})
						}),
					ui:Label("Equipment"):SetFont("HEADING_NORMAL"),
					ui:Grid(2,1)
						:SetColumn(0, { ui:VBox():PackEnd(equipColumn[1]) })
						:SetColumn(1, { ui:VBox():PackEnd(equipColumn[2]) })
				})
			})
			:SetColumn(1, {
				ui:VBox(10)
					:PackEnd(ui:Label(shipType.name):SetFont("HEADING_LARGE"))
					:PackEnd(UI.Game.ShipSpinner.New(ui, Game.player.shipType))
			})
end

local personalInfo = function ()
	local player = PersistentCharacters.player
	local faceFlags = { player.female and "FEMALE" or "MALE" }

	return
		ui:Grid(2,1)
			:SetColumn(0, {
				ui:VBox(20):PackEnd({
					ui:Label("Personal information"):SetFont("HEADING_LARGE"),
					ui:Label("Combat"):SetFont("HEADING_NORMAL"),
					ui:Grid(2,1)
						:SetColumn(0, {
							ui:VBox():PackEnd({
								ui:Label("Rating:"),
								ui:Label("Kills:"),
							})
						})
						:SetColumn(1, {
							ui:VBox():PackEnd({
								ui:Label("Harmless"), -- XXX
								ui:Label("23"),	      -- XXX
							})
						}),
					ui:Label("Military"):SetFont("HEADING_NORMAL"),
					ui:Grid(2,1)
						:SetColumn(0, {
							ui:VBox():PackEnd({
								ui:Label("Allegiance:"),
								ui:Label("Rank:"),
							})
						})
						:SetColumn(1, {
							ui:VBox():PackEnd({
								ui:Label("None"), -- XXX
								ui:Label("None"), -- XXX
							})
						})
				})
			})
			:SetColumn(1, {
				ui:VBox(10)
					:PackEnd(ui:Label(player.name):SetFont("HEADING_LARGE"))
					:PackEnd(UI.Game.Face.New(ui, faceFlags, player.seed))
			})
end

local econTrade = function ()
	local cash = Game.player:GetMoney()

	local stats = Game.player:GetStats()

	local usedCargo = stats.usedCargo
	local totalCargo = stats.freeCapacity

	local usedCabins = Game.player:GetEquipCount("CABIN", "PASSENGER_CABIN")
	local totalCabins = Game.player:GetEquipCount("CABIN", "UNOCCUPIED_CABIN") + usedCabins

	local cargoNameColumn = {}
	local cargoQuantityColumn = {}
	for i = 1,#Constants.EquipType do
		local type = Constants.EquipType[i]
		if type ~= "NONE" then
			local et = EquipType.GetEquipType(type)
			local slot = et.slot
			if slot == "CARGO" then
				local count = Game.player:GetEquipCount(slot, type)
				if count > 0 then
					table.insert(cargoNameColumn, ui:Label(et.name))
					table.insert(cargoQuantityColumn, ui:Label(count.."t"))
				end
			end
		end
	end

	return ui:Expand():SetInnerWidget(
		ui:Grid(2,1)
			:SetColumn(0, {
				ui:VBox(20):PackEnd({
					ui:Label("Economy & Trade"):SetFont("HEADING_LARGE"),
					ui:Grid(2,1)
						:SetColumn(0, {
							ui:VBox():PackEnd({
								ui:Label("Cash:"),
								ui:Margin(10),
								ui:Label("Cargo space:"),
								ui:Label("Cabins:"),
							})
						})
						:SetColumn(1, {
							ui:VBox():PackEnd({
								ui:Label(string.format("$%.2f", cash)),
								ui:Margin(10),
								ui:Grid(2,1):SetRow(0, { ui:Label("Total: "..totalCargo), ui:Label("Used: "..usedCargo) }),
								ui:Grid(2,1):SetRow(0, { ui:Label("Total: "..totalCabins), ui:Label("Used: "..usedCabins) }),
							})
						}),
				})
			})
			:SetColumn(1, {
				ui:VBox(10):PackEnd({
					ui:Label("Cargo"):SetFont("HEADING_LARGE"),
					ui:Scroller():SetInnerWidget(
						ui:Grid(2,1)
							:SetColumn(0, { ui:VBox():PackEnd(cargoNameColumn) })
							:SetColumn(1, { ui:VBox():PackEnd(cargoQuantityColumn) })
					)
				})
			})
	)
end

local missions = function ()
	return ui:Label("missions")
end

ui.templates.InfoView = function (args)
	local buttonDefs = {
		{ "Ship Information",     shipInfo },
		{ "Personal Information", personalInfo },
		{ "Economy & Trade",      econTrade },
		{ "Missions",             missions }
    }

	local container = ui:Margin(30)

    local buttonSet = {}
    for i = 1,#buttonDefs do
        local def = buttonDefs[i]
        local b = ui:Button():SetInnerWidget(ui:HBox():PackEnd(ui:Label(def[1])))
        b.onClick:Connect(function () container:SetInnerWidget(def[2]()) end)
        table.insert(buttonSet, ui:Margin(2):SetInnerWidget(b))
    end

	container:SetInnerWidget(shipInfo())

	return
		ui:VBox()
			:PackEnd(
				ui:Grid(#buttonDefs,1):SetFont("HEADING_NORMAL")
					:SetRow(0, buttonSet))
			:PackEnd(
				ui:Background():SetInnerWidget(container))
end
