--[[---------------------------------------------------------------------------------------------------------------------------
    ______                        _   __           _                 
   /_  __/__  ____ _____ ___     / | / /___  _  __(_)___  __  _______
    / / / _ \/ __ `/ __ `__ \   /  |/ / __ \| |/_/ / __ \/ / / / ___/
   / / /  __/ /_/ / / / / / /  / /|  / /_/ />  </ / /_/ / /_/ (__  ) 
  /_/  \___/\__,_/_/ /_/ /_/  /_/ |_/\____/_/|_/_/\____/\__,_/____/  

  Made by unable | Dandy's World API Library

---------------------------------------------------------------------------------------------------------------------------]]--

-- setup
local API = {}

local cloneref = cloneref or function(...) return ... end
local getgenv = getgenv() or _G

local exists = getgenv.DWAPIL_LOADED or nil
if exists then
	if getgenv.DWAPIL_Warn then
		getgenv.DWAPIL_Warn("Dandy's World API Library is already loaded.")
	end
	return
end
getgenv.DWAPIL_LOADED = true

local tisha = loadstring(game:HttpGet("https://raw.githubusercontent.com/did-i-leave-the-oven-on/Tisha/refs/heads/main/Tisha.lua"))()

-------------------------------------------------------------------------------------------------------------------------------

-- services
local ws = cloneref(game:GetService("Workspace"))
local plrs = cloneref(game:GetService("Players"))
local rst = cloneref(game:GetService("ReplicatedStorage"))
local coregui = cloneref(game:GetService("CoreGui"))

local rs = cloneref(game:GetService("RunService"))

-------------------------------------------------------------------------------------------------------------------------------

-- debug
function API.Print(message: string)
	print("[Sprout]: " .. message)
end

function API.Warn(message: string)
	warn("[Sprout]: " .. message)
end
getgenv.DWAPIL_Warn = API.Warn

function API.Error(message: string)
	error("[Sprout]: " .. message, 2)
end

function API.Assert(condition: any, message: string)
	if not condition then
		API.Error(message)
	end

	return condition
end

-------------------------------------------------------------------------------------------------------------------------------

-- player variables
local plr = plrs.LocalPlayer
local char = plr.Character or nil
local hum = char and char:FindFirstChild("Humanoid") or nil

local plrgui = plr:WaitForChild("PlayerGui")
local plrstats = char and char:FindFirstChild("Stats") or nil

function API.UpdateCharacterRefs()
	char = plr.CharacterAdded:Wait()

	if char then
		hum = char:FindFirstChild("Humanoid") or nil
		plrstats = char:FindFirstChild("Stats") or nil
	end
end

-------------------------------------------------------------------------------------------------------------------------------

-- game variables
local inrun = game.PlaceId == 16552821455

API.PlayersFolder = inrun and ws:WaitForChild("InGamePlayers")
API.Elevator = inrun and ws:WaitForChild("Elevators"):WaitForChild("Elevator")
API.FakeElevator = nil
API.GameInfoFolder = inrun and ws:WaitForChild("Info")
API.RoomFolder = inrun and ws:WaitForChild("CurrentRoom")

API.TwistedsFolder = nil
API.ItemsFolder = nil
API.MachinesFolder = nil
API.FreeAreaFolder = nil

function API.UpdateGameRefs()
	if not inrun then return end

	if not API.Get then
		repeat task.wait() until typeof(API.Get) == "function"
	end

	local room = API.Get("room")

	if room then
		API.TwistedsFolder = room:FindFirstChild("Monsters") or nil
		API.ItemsFolder = room:FindFirstChild("Items") or nil
		API.MachinesFolder = room:FindFirstChild("Generators") or nil
		freearea = room:FindFirstChild("FreeArea") or nil

		if freearea then
			API.FakeElevator = freearea:FindFirstChild("FakeElevator") or nil
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------

-- tables
API.ItemNameMaps, API.InvertedItemNameMaps = {
	["Air Horn"] = "AirHorn",
	["Bandage"] = "Bandage",
	["Bonbon"] = "BonBon",
	["Bottle o' Pop"] = "PopBottle",
	["Box o' Chocolates"] = "ChocolateBox",
	["Chocolate"] = "Chocolate",
	["Christmas Cookie"] = "ChristmasCookie",
	["Easter Egg"] = "DandyEasterEggs",
	["Eject Button"] = "EjectButton",
	["Extraction Speed Candy"] = "ExtractionSpeedCandy",
	["Event Currency"] = "HolidayCollectibleItem",
	["Fake Capsule"] = "FakeCapsule",
	["Gumballs"] = "Gumball",
	["Health Kit"] = "HealthKit",
	["Instructions"] = "Instructions",
	["Jawbreaker"] = "Jawbreaker",
	["Jumper Cable"] = "JumperCable",
	["Pop"] = "Pop",
	["Protein Bar"] = "ProteinBar",
	["Research Capsule"] = "ResearchCapsule",
	["Skill Check Candy"] = "SkillCheckCandy",
	["Smoke Bomb"] = "SmokeBomb",
	["Speed Candy"] = "SpeedCandy",
	["Stamina Candy"] = "StaminaCandy",
	["Stealth Candy"] = "StealthCandy",
	["Stopwatch"] = "Stopwatch",
	["Tape"] = "Tape",
	["Valve"] = "Valve"
}, {}
for k, v in pairs(API.ItemNameMaps) do
	API.InvertedItemNameMaps[v] = k
end

API.TwistedRarities = {
	["BoxtenMonster"] = "Common",
	["BrushaMonster"] = "Common",
	["CosmoMonster"] = "Common",
	["LooeyMonster"] = "Common",
	["PoppyMonster"] = "Common",
	["ShrimpoMonster"] = "Common",
	["TishaMonster"] = "Common",
	["YattaMonster"] = "Common",
	["RibeccaMonster"] = "Common",
	["RudieMonster"] = "Common",
	["EggsonMonster"] = "Common",

	["BrightneyMonster"] = "Uncommon",
	["ConnieMonster"] = "Uncommon",
	["FinnMonster"] = "Uncommon",
	["RazzleDazzleMonster"] = "Uncommon",
	["RodgerMonster"] = "Uncommon",
	["TeaganMonster"] = "Uncommon",
	["ToodlesMonster"] = "Uncommon",
	["SoulvesterMonster"] = "Uncommon",
	["GingerMonster"] = "Uncommon",
	["FlyteMonster"] = "Uncommon",

	["BlottMonster"] = "Rare",
	["FlutterMonster"] = "Rare",
	["GigiMonster"] = "Rare",
	["GlistenMonster"] = "Rare",
	["GoobMonster"] = "Rare",
	["ScrapsMonster"] = "Rare",
	["SquirmMonster"] = "Rare",
	["EclipseMonster"] = "Rare",
	["CoalMonster"] = "Rare",
	["CocoaMonster"] = "Rare",
	["WaxwellMonster"] = "Rare",

	["AstroMonster"] = "Main",
	["PebbleMonster"] = "Main",
	["ShellyMonster"] = "Main",
	["SproutMonster"] = "Main",
	["VeeMonster"] = "Main",
	["GourdyMonster"] = "Main",
	["BobetteMonster"] = "Main",
	["BassieMonster"] = "Main",

	["DandyMonster"] = "Lethal",
	["DyleMonster"] = "Lethal",
}

-------------------------------------------------------------------------------------------------------------------------------

-- helpers
function API.SpaceCamelCased(message: string?)
	API.Assert(message ~= nil and typeof(message) == "string", ".SpaceCamelCased: Invalid \"message\" parameter. Make sure \"message\" exists and is a string.")

	return message:sub(1, 1) .. message:sub(2):gsub("(%u)", " %1")
end --[[
example usage:

print(API.SpaceCamelCased("VeeRemote")) -> "Vee Remote"
print(API.SpaceCamelCased("CardboardArmor")) -> "Cardboard Armor"
print(API.SpaceCamelCased("None")) -> "None"
]]

function API.MapName(name: string?)
	API.Assert(name ~= nil and typeof(name) == "string", ".MapName: Invalid \"name\" parameter. Make sure \"name\" exists and is a string.")

	local mapped

	if name:find("Monster") then
		name = string.gsub(name, "Monster", "")
		if name == "RazzleDazzle" then
			name = "Razzle & Dazzle"
		elseif name == "Blott" then
			name = "Blot"
		end
		mapped = "Twisted " .. name
	end

	if name == "RazzleDazzle" then
		mapped = "Razzle & Dazzle"
	elseif name == "Blott" then
		mapped = "Blot"
	end

	mapped = API.ItemNameMaps[name] or API.InvertedItemNameMaps[name] or name

	return mapped
end --[[
example usage:

print(API.MapName("SproutMonster")) -> "Twisted Sprout"
print(API.MapName("RazzleDazzleMonster")) -> "Twisted Razzle & Dazzle"
print(API.MapName("BlottMonster")) -> "Twisted Blot"
]]

function API.GetGameInfo(give: string?)
	API.Assert(inrun ~= true, ".GetGameInfo: You can only use this function in a run.")

	give = give or "table" -- gameStarted, cardVoting, dandyStoreOpen, floor, floorActive, panicMode, machinesCompleted, machinesRequired, machinesLeft, blackout, playersAlive, boughtNothingForThisManyFloors, gameMessage, table

	API.Assert(give ~= nil and typeof(give) == "string", ".GetGameInfo: Invalid \"give\" parameter. Make sure \"give\" is a string.")

	local gameinfofolder = API.GameInfoFolder
	local gamestats = {
		gameStarted = (gameinfofolder and gameinfofolder:FindFirstChild("GameStarted")) and gameinfofolder.GameStarted.Value or false,
		cardVoting = (gameinfofolder and gameinfofolder:FindFirstChild("CardVoting")) and gameinfofolder.CardVoting.Value or false,
		dandyStoreOpen = (gameinfofolder and gameinfofolder:FindFirstChild("DandyStoreOpen")) and gameinfofolder.DandyStoreOpen.Value or false,
		floor = (gameinfofolder and gameinfofolder:FindFirstChild("Floor")) and gameinfofolder.Floor.Value or 0,
		floorActive = (gameinfofolder and gameinfofolder:FindFirstChild("FloorActive")) and gameinfofolder.FloorActive.Value or false,
		panicMode = (gameinfofolder and gameinfofolder:FindFirstChild("Panic")) and gameinfofolder.Panic.Value or false,
		machinesCompleted = (gameinfofolder and gameinfofolder:FindFirstChild("GeneratorsCompleted")) and gameinfofolder.GeneratorsCompleted.Value or 0,
		machinesRequired = (gameinfofolder and gameinfofolder:FindFirstChild("RequiredGenerators")) and gameinfofolder.RequiredGenerators.Value or 0,
		machinesLeft = ((gameinfofolder and gameinfofolder:FindFirstChild("RequiredGenerators")) and gameinfofolder.RequiredGenerators.Value or 0) - ((gameinfofolder and gameinfofolder:FindFirstChild("GeneratorsCompleted")) and gameinfofolder.GeneratorsCompleted.Value or 0),
		blackout = (gameinfofolder and gameinfofolder:FindFirstChild("BlackOut")) and gameinfofolder.BlackOut.Value or false,
		playersAlive = (gameinfofolder and gameinfofolder:FindFirstChild("ActivePlayers")) and #gameinfofolder.ActivePlayers:GetChildren() or 0,
		boughtNothingForThisManyFloors = (gameinfofolder and gameinfofolder:FindFirstChild("DandyTracker") and gameinfofolder.DandyTracker:FindFirstChild("NoBuy")) and gameinfofolder.DandyTracker.NoBuy.Value or 0,
		gameMessage = (gameinfofolder and gameinfofolder:FindFirstChild("Message")) and gameinfofolder.Message.Value or ""
	}

	if give == "table" then
		return gamestats
	else
		return gamestats[give]
	end
end --[[
example usage:

print("Floor " .. API.GetGameInfo("floor")) -> "Floor 12"
print(API.GetGameInfo("machinesLeft") .. " machines left!") -> "2 machines left!"

local info = API.GetGameInfo()
print(info.playersAlive .. " players alive | " .. info.machinesCompleted .. "/" .. info.machinesRequired .. " machines done") -> "4 players alive | 3/5 machines done"

if API.GetGameInfo("blackout") then print("The lights are out") end -> "The lights are out"
]]

function API.Panicking()
	API.Assert(inrun ~= true, ".Panicking: You can only use this function in a run.")

	return API.GetGameInfo("panicMode")
end --[[
example usage:

local panicking = API.Panicking() and "on" or "off"
print("Panic mode is " .. panicking .. ".") -> "Panic mode is off."
]]

function API.IsBreakRoom()
	API.Assert(inrun ~= true, ".IsBreakRoom: You can only use this function in a run.")

	return string.lower(plrgui.ScreenGui.Menu.TopBar.FloorNumber.Text):find("break")
end --[[
example usage:

local hammertime = API.IsBreakRoom() and "not" or ""
print("Currently " .. hammertime .. " in the break room") -> "Currently not in the break room"
]]

function API.FetchItemInPlayerInventorySlot(player: Instance?, slot: number?)
	API.Assert(inrun ~= true, ".FetchItemInPlayerInventorySlot: You can only use this function in a run.")

	player = player or plr

	API.Assert(player ~= nil and player:IsA("Player"), ".FetchItemInPlayerInventorySlot: Invalid \"player\" parameter. Make sure \"player\" is a Player.")
	API.Assert(slot ~= nil and typeof(slot) == "number", ".FetchItemInPlayerInventorySlot: Invalid \"slot\" parameter. Make sure \"slot\" exists and is a number.")

	local plrchar = player.Character or nil
	if not plrchar then
		API.Warn(".FetchItemInPlayerInventorySlot: Player does not have a Character.")
		return
	end

	local inventory = plrchar:FindFirstChild("Inventory")
	if not inventory then
		API.Warn(".FetchItemInPlayerInventorySlot: Player does not have an inventory.")
		return
	end

	local ins = inventory:FindFirstChild("Slot" .. slot)

	if not ins then
		return "None"
	end

	if (slot == 4) and not ins then
		return "None"
	end

	return ins.Value
end --[[
example usage:

print(API.FetchItemInPlayerInventorySlot(plr, 1)) -> "Bandage"
print(API.FetchItemInPlayerInventorySlot(plr, 3)) -> "None"

local thisguy = plrs.ThisGuy
print(thisguy.Name .. " has a " .. API.FetchItemInPlayerInventorySlot(thisguy, 2)) -> "ThisGuy has a Valve"
]]

function API.FetchPlayerTrinketSlot(player: Instance?, slot: number?)
	API.Assert(inrun ~= true, ".FetchPlayerTrinketSlot: You can only use this function in a run.")

	player = player or plr

	API.Assert(player ~= nil and player:IsA("Player"), ".FetchPlayerTrinketSlot: Invalid \"player\" parameter. Make sure \"player\" is a Player.")
	API.Assert(slot ~= nil and typeof(slot) == "number", ".FetchPlayerTrinketSlot: Invalid \"slot\" parameter. Make sure \"slot\" exists and is a number.")

	local trinketname = player:GetAttribute("EquippedTrinket" .. slot) or "None"

	return API.SpaceCamelCased(trinketname)
end --[[
example usage:

print(API.FetchPlayerTrinketSlot(plr, 1)) -> "Vee Remote"
print(API.FetchPlayerTrinketSlot(plr, 2)) -> "None"

local thisguy = plrs.ThisGuy
print(thisguy.Name .. " has a " .. API.FetchPlayerTrinketSlot(thisguy, 1) .. " equipped") -> "ThisGuy has a Vee Remote equipped"
]]

function API.Get(ins: string?)
	API.Assert(inrun ~= true, ".Get: You can only use this function in a run.")
	API.Assert(ins ~= nil and typeof(ins) == "string", ".Get: Invalid \"ins\" parameter. Make sure \"ins\" is a string.")

	ins = string.lower(ins)

	if ins == "room" then
		return API.RoomFolder:FindFirstChildWhichIsA("Model") or nil
	elseif ins == "items" then
		return API.ItemsFolder
	elseif ins == "twisteds" then
		return API.TwistedsFolder
	elseif ins == "machines" then
		return API.MachinesFolder
	elseif ins == "elevator" then
		return API.Elevator
	elseif ins == "fakelevator" then
		return API.FakeElevator
	end
end --[[
example usage:

local twisteds = API.Get("twisteds")
print(#twisteds:GetChildren() .. " twisteds are on the floor") -> "3 twisteds are on the floor"
]]

-------------------------------------------------------------------------------------------------------------------------------

-- player handling
function API.GetPlayerInfo(player: Instance?, give: string?, mapNames: boolean?)
	API.Assert(inrun ~= true, ".GetPlayerInfo: You can only use this function in a run.")

	player = player or plr
	give = give or "table" -- toon, health, tapes, walkSpeed, runSpeed, icon, inventorySlot1, inventorySlot2, inventorySlot3, inventorySlot4, trinketSlot1, trinketSlot2, abilityActive, dead, table
	mapNames = mapNames or false

	API.Assert(player ~= nil and player:IsA("Player"), ".GetPlayerInfo: Invalid \"player\" parameter. Make sure \"player\" is a Player.")
	API.Assert(give ~= nil and typeof(give) == "string", ".GetPlayerInfo: Invalid \"give\" parameter. Make sure \"give\" is a string.")
	API.Assert(mapNames ~= nil and typeof(mapNames) == "boolean", ".GetPlayerInfo: Invalid \"mapNames\" parameter. Make sure \"mapNames\" is a boolean.")

	local plrchar = player.Character
	local plrhum = plrchar and plrchar:FindFirstChildWhichIsA("Humanoid")

	local plrconfig = plrchar and plrchar:FindFirstChild("Config")
	local plrstats = plrchar and plrchar:FindFirstChild("Stats")
	local plrgamestats = API.GameInfoFolder and API.GameInfoFolder:FindFirstChild("PlayerStats") and API.GameInfoFolder.PlayerStats:FindFirstChild(player.Name)

	local toon = player:GetAttribute("ToonName") or ""
	if mapNames and API.MapName and toon ~= "" then
		toon = API.MapName(toon)
	end

	local walkspeedbase = (plrstats and plrstats:FindFirstChild("WalkSpeed")) and plrstats.WalkSpeed.Value or 0
	local walkspeedmodifier = (plrstats and plrstats:FindFirstChild("SpeedModifier")) and plrstats.SpeedModifier.Value or 1

	local runspeedbase = (plrstats and plrstats:FindFirstChild("RunSpeed")) and plrstats.RunSpeed.Value or 0
	local runspeedmodifier = (plrstats and plrstats:FindFirstChild("RunSpeedModifier")) and plrstats.RunSpeedModifier.Value or 1

	local abilityactive = false
	if plrchar and plrchar:FindFirstChild("Abilities") then
		for _, ability in pairs(plrchar.Abilities:GetChildren()) do
			if ability:FindFirstChild("CurrentCooldown") and ability.CurrentCooldown.Value == 0 then
				abilityactive = true
				break
			end
		end
	end

	local data = {
		toon = toon,
		health = plrhum and plrhum.Health or 0,
		tapes = (plrgamestats and plrgamestats:FindFirstChild("SurvivalPoints")) and plrgamestats.SurvivalPoints.Value or 0,
		walkSpeed = walkspeedbase * walkspeedmodifier,
		runSpeed = runspeedbase * runspeedmodifier,
		icon = (plrconfig and plrconfig:FindFirstChild("Icon")) and plrconfig.Icon.Texture or "rbxassetid://0",
		inventorySlot1 = API.FetchItemInPlayerInventorySlot and API.FetchItemInPlayerInventorySlot(player, 1) or nil,
		inventorySlot2 = API.FetchItemInPlayerInventorySlot and API.FetchItemInPlayerInventorySlot(player, 2) or nil,
		inventorySlot3 = API.FetchItemInPlayerInventorySlot and API.FetchItemInPlayerInventorySlot(player, 3) or nil,
		inventorySlot4 = API.FetchItemInPlayerInventorySlot and API.FetchItemInPlayerInventorySlot(player, 4) or nil,
		trinketSlot1 = API.FetchPlayerTrinketSlot and API.FetchPlayerTrinketSlot(player, 1) or nil,
		trinketSlot2 = API.FetchPlayerTrinketSlot and API.FetchPlayerTrinketSlot(player, 2) or nil,
		abilityactive = abilityactive,
		dead = API.PlayersFolder and API.PlayersFolder:FindFirstChild(player.Name) or nil,
	}

	if give == "table" then
		return data
	else
		return data[give]
	end
end --[[
example usage:

print(API.GetPlayerInfo(plr, "toon")) -> "Poppy"
print(API.GetPlayerInfo(plr, "health") .. " HP") -> "100 HP"

local thisguy = plrs.ThisGuy
local info = API.GetPlayerInfo(thisguy)
print(thisguy.Name .. " is playing as " .. info.toon .. " and currently has " .. info.tapes .. " tapes") -> "ThisGuy is playing as Shelly and currently has 12 tapes"

print(API.GetPlayerInfo(thisguy, "dead") and "dead" or "alive") -> "alive"
]]

function API.GetPlayersAlive(give: string?, toonify: boolean?)
	API.Assert(inrun ~= true, ".GetPlayersAlive: You can only use this function in a run.")

	give = give or "table" -- table, stringList, number
	toonify = toonify or false

	API.Assert(give ~= nil and typeof(give) == "string", ".GetPlayersAlive: Invalid \"give\" parameter. Make sure \"give\" is a string.")
	API.Assert(toonify ~= nil and typeof(toonify) == "boolean", ".GetPlayersAlive: Invalid \"toonify\" parameter. Make sure \"toonify\" is a boolean.")

	local alive = {}
	for _, player in ipairs(plrs:GetPlayers()) do
		local dead = API.GetPlayerInfo(player, "dead")
		if not dead then
			table.insert(alive, player)
		end
	end

	if give == "table" then
		return alive
	elseif give == "stringList" then
		local names = {}
		for _, player in ipairs(alive) do
			local name = player.Name
			if toonify then
				name = API.MapName(API.GetPlayerInfo(player, "toon")) or name
			end
			table.insert(names, name)
		end
		return table.concat(names, ", ")
	elseif give == "number" then
		return #alive
	end
end --[[
example usage:

print(API.GetPlayersAlive("number") .. " players alive") -> "4 players alive"
print(API.GetPlayersAlive("stringList")) -> "You, ThisGuy, ThatGuy, OtherGuy"
print(API.GetPlayersAlive("stringList", true)) -> "Poppy, Shelly, Astro, Pebble"

for _, player in ipairs(API.GetPlayersAlive()) do
	print(player.Name .. " is still alive") -> "ThisGuy is still alive"
end
]]

function API.GetPlayersInElevator(give: string?, toonify: boolean?)
	API.Assert(inrun ~= true, ".GetPlayersInElevator: You can only use this function in a run.")

	give = give or "table" -- table, stringList, number
	toonify = toonify or false

	API.Assert(give ~= nil and typeof(give) == "string", ".GetPlayersInElevator: Invalid \"give\" parameter. Make sure \"give\" is a string.")
	API.Assert(toonify ~= nil and typeof(toonify) == "boolean", ".GetPlayersInElevator: Invalid \"toonify\" parameter. Make sure \"toonify\" is a boolean.")

	local hitbox = API.Elevator and (API.Elevator:FindFirstChild("ElevatorHitBox") or API.Elevator:FindFirstChild("MonsterBlocker"))
	if not hitbox then 
		if give == "number" then return 0 end
		if give == "stringList" then return "" end
		return {} 
	end

	local overlapping = ws:GetPartsInPart(hitbox)
	local inside = {}
	local checked = {}

	for _, part in ipairs(overlapping) do
		if part.Name == "HumanoidRootPart" then
			local character = part.Parent
			if character and character:FindFirstChild("Humanoid") then
				local player = plrs:GetPlayerFromCharacter(character)
				if player and not checked[player] then
					checked[player] = true
					table.insert(inside, player)
				end
			end
		end
	end

	if give == "table" then
		return inside
	elseif give == "stringList" then
		local names = {}
		for _, player in ipairs(inside) do
			local name = player.Name
			if toonify then
				name = API.MapName(API.GetPlayerInfo(player, "toon")) or name
			end
			table.insert(names, name)
		end
		return table.concat(names, ", ")
	elseif give == "number" then
		return #inside
	end
end --[[
example usage:

print(API.GetPlayersInElevator("number") .. " players in the elevator") -> "3 players in the elevator"
print(API.GetPlayersInElevator("stringList")) -> "You, ThisGuy, ThatGuy"
print(API.GetPlayersInElevator("stringList", true)) -> "Poppy, Shelly, Astro"

for _, player in ipairs(API.GetPlayersInElevator()) do
	print(player.Name .. " is in the elevator") -> "ThisGuy is in the elevator"
end
]]

function API.GetPlayersOutOfElevator(give: string?, toonify: boolean?)
	API.Assert(inrun ~= true, ".GetPlayersOutOfElevator: You can only use this function in a run.")

	give = give or "table" -- table, stringList, number
	toonify = toonify or false

	API.Assert(give ~= nil and typeof(give) == "string", ".GetPlayersOutOfElevator: Invalid \"give\" parameter. Make sure \"give\" is a string.")
	API.Assert(toonify ~= nil and typeof(toonify) == "boolean", ".GetPlayersOutOfElevator: Invalid \"toonify\" parameter. Make sure \"toonify\" is a boolean.")

	local hitbox = API.Elevator and (API.Elevator:FindFirstChild("ElevatorHitBox") or API.Elevator:FindFirstChild("MonsterBlocker"))
	local playersinside = {}

	if hitbox then
		local overlapping = ws:GetPartsInPart(hitbox)
		local checked = {}

		for _, part in ipairs(overlapping) do
			if part.Name == "HumanoidRootPart" then
				local character = part.Parent
				if character and character:FindFirstChild("Humanoid") then
					local player = plrs:GetPlayerFromCharacter(character)
					if player and not checked[player] then
						checked[player] = true
						table.insert(playersinside, player)
					end
				end
			end
		end
	end

	local insidemapped = {}
	for _, p in ipairs(playersinside) do
		insidemapped[p] = true
	end

	local outside = {}
	for _, player in ipairs(plrs:GetPlayers()) do
		if not insidemapped[player] then
			table.insert(outside, player)
		end
	end

	if give == "table" then
		return outside
	elseif give == "stringList" then
		local names = {}
		for _, player in ipairs(outside) do
			local name = player.Name
			if toonify and API.MapName then
				name = API.MapName(API.GetPlayerInfo(player, "toon")) or name
			end
			table.insert(names, name)
		end
		return table.concat(names, ", ")
	elseif give == "number" then
		return #outside
	end
end --[[
example usage:

print(API.GetPlayersOutOfElevator("number") .. " players still outside") -> "1 players still outside"
print(API.GetPlayersOutOfElevator("stringList")) -> "OtherGuy"
print(API.GetPlayersOutOfElevator("stringList", true)) -> "Pebble"

if API.GetPlayersOutOfElevator("number") == 0 then
	print("Everyone is in the elevator") -> "Everyone is in the elevator"
end
]]

function API.TrinketActiveFor(trinket: string?, player: Instance?)
	API.Assert(inrun ~= true, ".TrinketActiveFor: You can only use this function in a run.")

	trinket = trinket or "VeeRemote" -- VeeRemote, Wrench, StarPillow, SavoryCharm, ClownHorn, RibbonSpool, DuckToy, VanityMirror, CardboardArmor
	player = player or plr

	API.Assert(trinket ~= nil and typeof(trinket) == "string", ".TrinketActiveFor: Invalid \"trinket\" parameter. Make sure \"trinket\" is a string.")
	API.Assert(player ~= nil and player:IsA("Player"), ".TrinketActiveFor: Invalid \"player\" parameter. Make sure \"player\" is a Player.")

	local active = false
	local trinketsfolder = player.Character:FindFirstChild("Trinkets")

	if trinketsfolder then
		for _, slot in ipairs(trinketsfolder:GetChildren()) do
			if slot.Value == trinket then
				active = slot:FindFirstChild("Active")
				if active then
					active = slot:FindFirstChild("Active").Value
				end
			end
		end
	end

	return active
end --[[
example usage:

print(API.TrinketActiveFor("VeeRemote")) -> true

local thisguy = plrs.ThisGuy
print(API.TrinketActiveFor("Wrench", thisguy)) -> false

if API.TrinketActiveFor("DuckToy") then
	print("Your Duck Toy is active") -> "Your Duck Toy is active"
end
]]

function API.GetPlayerToon(player: Instance?)
	API.Assert(inrun ~= true, ".GetPlayerToon: You can only use this function in a run.")

	player = player or plr

	API.Assert(player ~= nil and player:IsA("Player"), ".GetPlayerToon: Invalid \"player\" parameter. Make sure \"player\" is a Player.")

	return API.GetPlayerInfo(player, "toon")
end --[[
example usage:

print("You are playing as " .. API.GetPlayerToon()) -> "You are playing as Boxten"

local thisguy = plrs.ThisGuy
print(thisguy.Name .. " is playing as " .. API.GetPlayerToon(thisguy)) -> "ThisGuy is playing as Cosmo"
]]

function API.PlayerCanUseAbility(player: Instance?)
	API.Assert(inrun ~= true, ".PlayerCanUseAbility: You can only use this function in a run.")

	player = player or plr

	API.Assert(player ~= nil and player:IsA("Player"), ".PlayerCanUseAbility: Invalid \"player\" parameter. Make sure \"player\" is a Player.")

	return API.GetPlayerInfo(player, "abilityActive")
end --[[
example usage:

print(API.PlayerCanUseAbility()) -> true

local thisguy = plrs.ThisGuy
local thisguycan = API.PlayerCanUseAbility(thisguy) and "" or "not"
print(thisguy.Name .. " can" .. thisguycan .. " use their ability") -> "ThisGuy cannot use their ability"

if API.PlayerCanUseAbility() then
	print("Your ability is ready") -> "Your ability is ready"
end
]]

-------------------------------------------------------------------------------------------------------------------------------

-- floor handling
function API.GetTwistedsOnFloor(give: string?, mapNames: boolean?)
	API.Assert(inrun ~= true, ".GetTwistedsOnFloor: You can only use this function in a run.")

	give = give or "table" -- table, stringList, number
	mapNames = mapNames or false

	API.Assert(give ~= nil and typeof(give) == "string", ".GetTwistedsOnFloor: Invalid \"give\" parameter. Make sure \"give\" is a string.")
	API.Assert(mapNames ~= nil and typeof(mapNames) == "boolean", ".GetTwistedsOnFloor: Invalid \"mapNames\" parameter. Make sure \"mapNames\" is a boolean.")

	local twistedsfolder = API.Get("twisteds")
	local twisteds = {}

	if twistedsfolder then
		for _, obj in ipairs(twistedsfolder:GetChildren()) do
			if typeof(obj) == "Instance" then
				table.insert(twisteds, obj)
			end
		end
	end

	if give == "table" then
		return twisteds
	elseif give == "stringList" or give == "tableList" then
		local names = {}
		for _, twisted in ipairs(twisteds) do
			local name = twisted.Name
			if mapNames then
				name = API.MapName(name) or name
			end
			table.insert(names, name)
		end
		return table.concat(names, ", ")
	elseif give == "number" then
		return #twisteds
	end
end --[[
example usage:

print(API.GetTwistedsOnFloor("number") .. " twisteds on this floor") -> "3 twisteds on this floor"
print(API.GetTwistedsOnFloor("stringList")) -> "BoxtenMonster, CosmoMonster, SproutMonster"
print(API.GetTwistedsOnFloor("stringList", true)) -> "Twisted Boxten, Twisted Cosmo, Twisted Sprout"

for _, twisted in ipairs(API.GetTwistedsOnFloor()) do
	print(twisted.Name) -> "BoxtenMonster"
end
]]

function API.GetItemsOnFloor(give: string?, mapNames: boolean?)
	API.Assert(inrun ~= true, ".GetItemsOnFloor: You can only use this function in a run.")

	give = give or "table" -- table, stringList, number
	mapNames = mapNames or false

	API.Assert(give ~= nil and typeof(give) == "string", ".GetItemsOnFloor: Invalid \"give\" parameter. Make sure \"give\" is a string.")
	API.Assert(mapNames ~= nil and typeof(mapNames) == "boolean", ".GetItemsOnFloor: Invalid \"mapNames\" parameter. Make sure \"mapNames\" is a boolean.")

	local itemsfolder = API.Get("items")
	local items = {}

	if itemsfolder then
		for _, obj in ipairs(itemsfolder:GetChildren()) do
			if typeof(obj) == "Instance" then
				table.insert(items, obj)
			end
		end
	end

	if give == "table" then
		return items
	elseif give == "stringList" or give == "tableList" then
		local names = {}
		for _, twisted in ipairs(items) do
			local name = twisted.Name
			if mapNames then
				name = API.MapName(name) or name
			end
			table.insert(names, name)
		end
		return table.concat(names, ", ")
	elseif give == "number" then
		return #items
	end
end --[[
example usage:

print(API.GetItemsOnFloor("number") .. " items on the floor") -> "5 items on the floor"
print(API.GetItemsOnFloor("stringList")) -> "Bandage, Bandage, SpeedCandy"
print(API.GetItemsOnFloor("stringList", true)) -> "Bandage, Bandage, Speed Candy"

for _, item in ipairs(API.GetItemsOnFloor()) do
	print(item.Name) -> "Bandage"
end
]]

function API.GetMachineInfo(machine: Instance?, give: string?)
	API.Assert(inrun ~= true, ".GetMachineInfo: You can only use this function in a run.")
	API.Assert(machine ~= nil and typeof(machine) == "Instance", ".GetMachineInfo: Invalid \"machine\" parameter. Make sure \"machine\" is an Instance.")

	give = give or "table" -- type, completed, posessed, debuffed, inspired, table

	API.Assert(give ~= nil and typeof(give) == "string", ".GetMachineInfo: Invalid \"give\" parameter. Make sure \"give\" is a string.")

	local machinestats = machine:FindFirstChild("Stats") or nil

	local machtype = machine:GetAttribute("MinigameType")
	if machtype == "MovementTreadmill" then 
		machtype = "Treadmill"
	elseif machtype == "Circle" then 
		machtype = "Circle"
	elseif machtype == "Barnaby" then 
		machtype = "Arcade"
	else
		machtype = "Normal"
	end

	local machtype2 = machine:GetAttribute("Prompt2MinigameType") or nil
	if machtype2 then
		if machtype2 == "MovementTreadmill" then 
			machtype2 = "Treadmill"
		elseif machtype2 == "Circle" then 
			machtype2 = "Circle"
		elseif machtype2 == "Barnaby" then 
			machtype2 = "Arcade"
		else
			machtype2 = "Normal"
		end
	end

	local resolvedtype = machtype
	if machtype and machtype2 then
		resolvedtype = "Dual " .. machtype .. " and " .. machtype2
	elseif machtype then
		resolvedtype = machtype
	end

	local data = {
		type = resolvedtype,
		completed = machinestats and machinestats:FindFirstChild("Completed") and machinestats.Completed.Value or false,
		posessed = machinestats and machinestats:FindFirstChild("Connie") and machinestats.Connie.Value or false,
		debuffed = machine:GetAttribute("BrushaDebuffed") or false,
		inspired = machine:GetAttribute("Inspired") or false,
	}

	if give == "table" then
		return data
	else
		return data[give]
	end
end --[[
example usage:

local machine = API.Get("machines"):GetChildren()[1]

print(API.GetMachineInfo(machine, "type")) -> "Treadmill"
print(API.GetMachineInfo(machine, "completed")) -> false
print(API.GetMachineInfo(machine, "posessed")) -> true

local info = API.GetMachineInfo(machine)
print(info.type .. " machine | debuffed: " .. tostring(info.debuffed) .. " | inspired: " .. tostring(info.inspired)) -> "Treadmill machine | debuffed: false | inspired: true"
]]

function API.CountTwistedObstacles()
	API.Assert(inrun ~= true, ".CountTwistedObstacles: You can only use this function in a run.")

	local count = 0

	if freearea then
		for _, obj in ipairs(freearea:GetChildren()) do
			if obj.Name:find("Tendril") then
				count += 1
			end
		end
	end

	for _, obj in ipairs(API.Get("room"):GetChildren()) do
		if obj.Name:find("BlotHand") then
			count += 1
		end
	end

	return count
end --[[
example usage:

local obstacles = API.CountTwistedObstacles()
if obstacles > 0 then
	print("There are " .. obstacles .. " Twisted obstacles in this room") -> "There are 2 Twisted obstacles in this room"
end
]]

-------------------------------------------------------------------------------------------------------------------------------

-- twisted handling
function API.GetTwistedInfo(twisted: Instance?, give: string?)
	API.Assert(inrun ~= true, ".GetTwistedInfo: You can only use this function in a run.")
	API.Assert(twisted ~= nil and typeof(twisted) == "Instance", ".GetTwistedInfo: Invalid \"twisted\" parameter. Make sure \"twisted\" exists and is an Instance.")

	give = give or "table" -- mappedName, wanderSpeed, chaseSpeed, rarity, chasing, hitboxRadius, detectionRadius, sightRadius, hearingRadius, research, table

	API.Assert(give ~= nil and typeof(give) == "string", ".GetTwistedInfo: Invalid \"give\" parameter. Make sure \"give\" is a string.")

	local name = twisted.Name
	local statsfolder = twisted:FindFirstChild("Stats")

	local cannotchase = name:find("Connie") or name:find("Blot") or name:find("Waxwell")
	local chaser = not cannotchase and twisted:FindFirstChild("Chaser")

	local chasingvalue = not cannotchase and twisted:FindFirstChild("ChasingValue")

	local data = {
		mappedName = API.MapName(name),
		wanderSpeed = statsfolder:FindFirstChild("WalkSpeed").Value or 0,
		chaseSpeed = statsfolder:FindFirstChild("ChaseSpeed").Value or 0,
		rarity = API.GetTwistedRarity(twisted),
		chasing = chasingvalue and chasingvalue.Value or false,
		hitboxRadius = (chaser and chaser:FindFirstChild("KillRadius")) and chaser.KillRadius.Value or 0,
		detectionRadius = (chaser and chaser:FindFirstChild("InstantRadius")) and chaser.InstantRadius.Value or 0,
		sightRadius = (chaser and chaser:FindFirstChild("VisionRadius")) and chaser.VisionRadius.Value or 0,
		hearingRadius = (chaser and chaser:FindFirstChild("HearingRadius")) and chaser.HearingRadius.Value or 0,
		research = API.GetTwistedResearchFromPlayer(twisted),
	}

	if give == "table" then
		return data
	else
		return data[give]
	end
end --[[
example usage:

local boxten = API.Get("twisteds").BoxtenMonster

print(API.GetTwistedInfo(boxten, "mappedName")) -> "Twisted Boxten"
print(API.GetTwistedInfo(boxten, "rarity")) -> "Common"
print(API.GetTwistedInfo(boxten, "chasing")) -> false

local info = API.GetTwistedInfo(boxten)
print(info.mappedName .. " (" .. info.rarity .. ") | sight radius: " .. info.sightRadius .. " | research: " .. info.research .. "%") -> "Twisted Boxten (Common) | sight radius: 40 | research: 100%"
]]

function API.GetTwistedsChasingPlayer(player: Instance?, give: string?, mapNames: boolean?)
	API.Assert(inrun ~= true, ".GetTwistedsChasingPlayer: You can only use this function in a run.")

	player = player or plr
	give = give or "table" -- table, stringList, number
	mapNames = mapNames or false

	API.Assert(player ~= nil and player:IsA("Player"), ".GetTwistedsChasingPlayer: Invalid \"player\" parameter. Make sure \"player\" is a Player.")
	API.Assert(give ~= nil and typeof(give) == "string", ".GetTwistedsChasingPlayer: Invalid \"give\" parameter. Make sure \"give\" is a string.")
	API.Assert(mapNames ~= nil and typeof(mapNames) == "boolean", ".GetTwistedsChasingPlayer: Invalid \"mapNames\" parameter. Make sure \"mapNames\" is a boolean.")

	local chasing = {}
	local twistedsfolder = API.Get("twisteds")

	if twistedsfolder then
		for _, twisted in ipairs(twistedsfolder:GetChildren()) do
			if typeof(twisted) == "Instance" and twisted:IsA("Model") then
				local chasetarget = API.GetTwistedInfo(twisted, "chasing")

				local ischasing = false
				if chasetarget == player.Character then
					ischasing = true
				end

				if ischasing then
					table.insert(chasing, twisted)
				end
			end
		end
	end

	if give == "table" then
		return chasing
	elseif give == "stringList" or give == "tableList" then
		local names = {}
		for _, twisted in ipairs(chasing) do
			local name = twisted.Name
			if mapNames then
				name = API.MapName(name) or name
			end
			table.insert(names, name)
		end
		return table.concat(names, ", ")
	elseif give == "number" then
		return #chasing
	end

	return chasing
end --[[
example usage:

print(API.GetTwistedsChasingPlayer(plr, "stringList", true) .. " are chasing you") -> "Twisted Boxten, Twisted Cosmo, Twisted Sprout are chasing you"

local thisguy = plrs.ThisGuy
print(API.GetTwistedsChasingPlayer(thisguy, "stringList") .. " are chasing " .. thisguy.Name) -> "BoxtenMonster, CosmoMonster, SproutMonster are chasing ThisGuy"
]]

local lasthits = setmetatable({}, { __mode = "k" })
local monitored = setmetatable({}, { __mode = "k" })

local mainmaid = tisha.new()
local sessionmaid = nil

local function recordhit(twisted)
	local chasing = twisted and twisted:FindFirstChild("ChasingValue")
	local target = chasing and chasing.Value
	if typeof(target) ~= "Instance" then return end

	if target:IsA("Player") then target = target.Character end
	if not target then return end

	lasthits[target] = { twisted = twisted }
end

local function monitortwisted(twisted)
	if not twisted:IsA("Model") or monitored[twisted] then return end

	local maid = tisha.new()
	monitored[twisted] = maid

	maid:give(twisted:GetAttributeChangedSignal("Attacking"):Connect(function()
		if twisted:GetAttribute("Attacking") == true then
			recordhit(twisted)
		end
	end))

	maid:give(twisted.Destroying:Connect(function()
		monitored[twisted] = nil
		maid:destroy()
	end))

	if twisted:GetAttribute("Attacking") == true then
		recordhit(twisted)
	end
end

local function monitorroom()
	if sessionmaid then
		sessionmaid:destroy()
	end

	local maid = tisha.new()
	sessionmaid = maid

	maid:spawn(function()
		local folder = API.Get("twisteds")
		while not folder do
			task.wait(0.1)
			folder = API.Get("twisteds")
		end

		for _, twisted in ipairs(folder:GetChildren()) do
			monitortwisted(twisted)
		end

		maid:give(folder.ChildAdded:Connect(monitortwisted))
	end)
end

mainmaid:give(API.RoomFolder.ChildAdded:Connect(monitorroom), "roomadded")
monitorroom()

function API.GetPlayerLastHitBy(player: Instance?, mapName: boolean?)
	API.Assert(inrun ~= true, ".GetPlayerLastHitBy: You can only use this function in a run.")

	player = player or plr
	mapName = mapName or false

	API.Assert(player ~= nil and player:IsA("Player"), ".GetPlayerLastHitBy: Invalid \"player\" parameter. Make sure \"player\" is a Player.")
	API.Assert(mapName ~= nil and typeof(mapName) == "boolean", ".GetPlayerLastHitBy: Invalid \"mapName\" parameter. Make sure \"mapName\" is a boolean.")

	local character = player.Character
	local record = character and lasthits[character]
	if not record or not record.twisted.Parent then
		return nil
	end

	return mapName and API.MapName(record.twisted.Name) or record.twisted
end --[[
example usage:

print("You were last hit by " .. API.GetPlayerLastHitBy(game.Players.LocalPlayer, true)) -> "You were last hit by Twisted Boxten"

local thisguy = plrs.ThisGuy
print(thisguy.Name .. " was last hit by " .. API.GetPlayerLastHitBy(thisguy)) -> "ThisGuy was last hit by CosmoMonster"
]]

function API.GetTwistedRarity(twisted: Instance? | string?)
	if twisted and typeof(twisted) == "Instance" then
		API.Assert(inrun ~= true, ".GetTwistedRarity: The \"twisted\" parameter must be a string since the player isn't in a run. (E.g.: \"BoxtenMonster\"")
	end

	API.Assert(twisted ~= nil and (typeof(twisted) == "Instance" or typeof(twisted) == "string"), ".GetTwistedRarity: Invalid \"twisted\" parameter. Make sure \"twisted\" exists and is an Instance or a string.")

	local twistedname = twisted.Name

	return API.TwistedRarities[twistedname] or "Unknown"
end --[[
example usage:

print(API.GetTwistedRarity(API.Get("twisteds").BoxtenMonster)) -> "Common"
print(API.GetTwistedRarity("SproutMonster")) -> "Main"
]]

function API.GetTwistedResearchFromPlayer(twisted: Instance? | string?, player: Instance?)
	if twisted and typeof(twisted) == "Instance" then
		API.Assert(inrun ~= true, ".GetTwistedResearchFromPlayer: The \"twisted\" parameter must be a string since the player isn't in a run. (E.g.: \"BoxtenMonster\"")
	end

	API.Assert(twisted ~= nil and (typeof(twisted) == "Instance" or typeof(twisted) == "string"), ".GetTwistedResearchFromPlayer: Invalid \"twisted\" parameter. Make sure \"twisted\" exists and is an Instance or a string.")

	player = player or plr

	API.Assert(player ~= nil and player:IsA("Player"), ".GetTwistedResearchFromPlayer: Invalid \"player\" parameter. Make sure \"player\" is a Player.")

	local playerid = player.UserId
	if typeof(twisted) == "Instance" then
		twisted = twisted.Name
	end

	local researchfolder = rst:FindFirstChild("PlayerData"):FindFirstChild(playerid):FindFirstChild("Research")

	return researchfolder and researchfolder:FindFirstChild(twisted).Value or 0
end --[[
example usage:

local boxtenresearch = API.GetTwistedResearchFromPlayer(API.Get("twisteds").BoxtenMonster)
print(boxtenresearch) -> 100

local thisguy = plrs.ThisGuy
local cosmoresearch = API.GetTwistedResearchFromPlayer("CosmoMonster", thisguy)
print(thisguy.Name .. "'s research on Twisted Cosmo: " .. cosmoresearch .. "%") -> "ThisGuy's research on Twisted Cosmo: 69%"
]]

-------------------------------------------------------------------------------------------------------------------------------

if inrun then
	task.spawn(function()
		API.UpdateGameRefs()

		API.RoomFolder.ChildAdded:Connect(API.UpdateGameRefs)
		API.RoomFolder.ChildRemoved:Connect(API.UpdateGameRefs)

		plrgui:WaitForChild("ScreenGui"):WaitForChild("Menu"):WaitForChild("TopBar"):WaitForChild("FloorNumber"):WaitForChild("Text").Changed:Connect(API.UpdateGameRefs)
	end)
end

API.Print("Dandy's World API Library loaded successfully.")

-------------------------------------------------------------------------------------------------------------------------------
