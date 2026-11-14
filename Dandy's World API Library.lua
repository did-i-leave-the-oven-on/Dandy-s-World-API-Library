--[[---------------------------------------------------------------------------------------------------------------------------
    ______                        _   __           _                 
   /_  __/__  ____ _____ ___     / | / /___  _  __(_)___  __  _______
    / / / _ \/ __ `/ __ `__ \   /  |/ / __ \| |/_/ / __ \/ / / / ___/
   / / /  __/ /_/ / / / / / /  / /|  / /_/ />  </ / /_/ / /_/ (__  ) 
  /_/  \___/\__,_/_/ /_/ /_/  /_/ |_/\____/_/|_/_/\____/\__,_/____/  

  Made by unable | Dandy's World API Library

---------------------------------------------------------------------------------------------------------------------------]]--

-- setup
local API, loadArgs = {}, (... and typeof(...) == "table") and ... or {}

local cloneref = cloneref or function(...) return ... end
local getgenv = (getgenv and getgenv()) or _G

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
local https = cloneref(game:GetService("HttpService"))

local request = request or (syn and syn.request) or (http and http.request)
local placeid = game.PlaceId

-------------------------------------------------------------------------------------------------------------------------------

-- debug
local debugmode = loadArgs.debugMode or false
local coloredconsole = loadArgs.coloredConsole or true

local CC = {
	cols = {
		["o"] = "255, 255, 255",
		["err"] = "255, 120, 120",
		["succ"] = "80, 255, 80",
		["w"] = "245, 242, 66",
		["i"] = "104, 143, 252",
	},
	registry = {}
}

if coloredconsole then
	rs.Heartbeat:Connect(function()
		local devconsole = coregui:FindFirstChild("DevConsoleMaster")
		if not devconsole then return end

		local devwindow = devconsole:FindFirstChild("DevConsoleWindow", true)
		if devwindow and not devwindow.Visible then return end

		for _, v in pairs(devconsole:GetDescendants()) do
			if v:IsA("TextLabel") then
				v.RichText = true

				if string.find(v.Text, "<font", 1, true) then
					continue
				end

				for raw, rich in pairs(CC.registry) do
					if #v.Text >= #raw and string.sub(v.Text, -#raw) == raw then
						local prefix = string.sub(v.Text, 1, #v.Text - #raw)

						if prefix == "" or string.match(prefix, "^%d%d:%d%d:%d%d %-%- $") then
							v.Text = prefix .. rich
							break
						end
					end
				end
			end
		end
	end)
end

function CC.print(color, text, size)
	if not CC.cols[color] then return end
	text = tostring(text)

	local detect = "[Sprout]:"
	local richtext

	if text:sub(1, #detect) == detect then
		local character = 'rgb(255, 87, 87)'
		local rest = text:sub(#detect + 1)

		richtext = '<font color="' .. character .. '">' .. detect .. '</font><font color="rgb(' .. CC.cols[color] .. ')">' .. rest .. '</font>'
	else
		richtext = '<font color="rgb(' .. CC.cols[color] .. ')">' .. text .. '</font>'
	end

	if size then
		richtext = richtext:gsub(
			"<font",
			'<font size="' .. tostring(size) .. '"',
			1
		)
	end

	CC.registry[text] = richtext
	print(text)
end

function API.Print(message: string)
	CC.print("o", "[Sprout]: " .. message)
end

function API.Warn(message: string)
	CC.print("w", "[Sprout]: " .. message)
end
getgenv.DWAPIL_Warn = API.Warn

function API.Error(message: string)
	CC.print("err", "[Sprout]: " .. message)
end

function API.Success(message: string)
	CC.print("succ", "[Sprout]: " .. message)
end

function API.Assert(condition: any, message: string)
	if not condition then
		API.Error(message)
	end

	return condition
end

function API.Debug(statementType: string, message: string)
	if not debugmode then return end

	if statementType == "print" then
		API.Print(message)
	elseif statementType == "warn" then
		API.Warn(message)
	elseif statementType == "err" then
		API.Error(message)
	elseif statementType == "succ" then
		API.Success(message)
	end
end

-------------------------------------------------------------------------------------------------------------------------------

-- player variables
local plr = plrs.LocalPlayer
local char = plr.Character or nil
local root = char and char:WaitForChild("HumanoidRootPart") or nil
local hum = char and char:FindFirstChild("Humanoid") or nil

local plrgui = plr:WaitForChild("PlayerGui")
local plrstats = char and char:FindFirstChild("Stats") or nil

function API.UpdateCharacterRefs()
	char = plr.CharacterAdded:Wait()

	if char then
		root = char:WaitForChild("HumanoidRootPart") or nil
		hum = char:FindFirstChild("Humanoid") or nil
		plrstats = char:FindFirstChild("Stats") or nil
	end
end

-------------------------------------------------------------------------------------------------------------------------------

-- game variables
API.LobbyPlaceID = 16116270224
API.RunPlaceID = 16552821455
API.RoleplayServerID = 18984416148

API.InLobby = placeid == API.LobbyPlaceID
API.InRun = placeid == API.RunPlaceID
API.InRoleplayServer = placeid == API.RoleplayServerID

API.PlayersFolder = API.InRun and ws:WaitForChild("InGamePlayers") or ws:WaitForChild("Players") or nil
API.Elevator = API.InRun and ws:WaitForChild("Elevators"):WaitForChild("Elevator") or nil
API.FakeElevator = nil
API.GameInfoFolder = API.InRun and ws:WaitForChild("Info") or nil
API.RoomFolder = API.InRun and ws:WaitForChild("CurrentRoom") or nil

API.TwistedsFolder = nil
API.ItemsFolder = nil
API.MachinesFolder = nil
API.FreeAreaFolder = nil
API.StarPillowsFolder = nil

function API.UpdateGameRefs()
	if not API.InRun then return end

	if not API.Get then
		repeat task.wait() until typeof(API.Get) == "function"
	end

	local room = API.Get("room")

	if room then
		API.TwistedsFolder = room:WaitForChild("Monsters", 5) or nil
		API.ItemsFolder = room:WaitForChild("Items", 5) or nil
		API.MachinesFolder = room:WaitForChild("Generators", 5) or nil
		API.FreeAreaFolder = room:WaitForChild("FreeArea", 5) or nil
		API.StarPillowsFolder = room:WaitForChild("StarPillows", 5) or nil

		if API.FreeAreaFolder then
			API.FakeElevator = API.FreeAreaFolder:WaitForChild("FakeElevator", 5) or nil
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

print(API.SpaceCamelCased("VeeRemote")) → "Vee Remote"
print(API.SpaceCamelCased("CardboardArmor")) → "Cardboard Armor"
print(API.SpaceCamelCased("None")) → "None"
]]

function API.MapName(name: string?)
	API.Assert(name ~= nil and typeof(name) == "string", ".MapName: Invalid \"name\" parameter. Make sure \"name\" exists and is a string.")

	if name:find("Monster") then
		name = string.gsub(name, "Monster", "")
		if name == "RazzleDazzle" then
			name = "Razzle & Dazzle"
		elseif name == "Blott" then
			name = "Blot"
		end
		return "Twisted " .. name
	end

	if name == "RazzleDazzle" then
		return "Razzle & Dazzle"
	elseif name == "Blott" then
		return "Blot"
	end

	return API.ItemNameMaps[name] or API.InvertedItemNameMaps[name] or name
end --[[
example usage:

print(API.MapName("SproutMonster")) → "Twisted Sprout"
print(API.MapName("RazzleDazzleMonster")) → "Twisted Razzle & Dazzle"
print(API.MapName("BlottMonster")) → "Twisted Blot"
]]

function API.GetGameInfo(give: string?)
	API.Assert(API.InRun == true, ".GetGameInfo: You can only use this function in a run.")

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

print("Floor " .. API.GetGameInfo("floor")) → "Floor 12"
print(API.GetGameInfo("machinesLeft") .. " machines left") → "2 machines left"

local info = API.GetGameInfo()
print(info.playersAlive .. " players alive | " .. info.machinesCompleted .. "/" .. info.machinesRequired .. " machines done") → "4 players alive | 3/5 machines done"

if API.GetGameInfo("blackout") then print("The lights are out") end → "The lights are out"
]]

function API.Panicking()
	API.Assert(API.InRun == true, ".Panicking: You can only use this function in a run.")

	return API.GetGameInfo("panicMode")
end --[[
example usage:

local panicking = API.Panicking() and "on" or "off"
print("Panic mode is " .. panicking) → "Panic mode is off"
]]

function API.IsBreakRoom()
	API.Assert(API.InRun == true, ".IsBreakRoom: You can only use this function in a run.")

	return string.lower(plrgui.ScreenGui.Menu.TopBar.FloorNumber.Text):find("break")
end --[[
example usage:

local hammertime = API.IsBreakRoom() and "not" or ""
print("Currently " .. hammertime .. " in the break room") → "Currently not in the break room"
]]

function API.FetchItemInPlayerInventorySlot(player: Instance?, slot: number?)
	API.Assert(API.InRun == true, ".FetchItemInPlayerInventorySlot: You can only use this function in a run.")

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

print(API.FetchItemInPlayerInventorySlot(plr, 1)) → "Bandage"
print(API.FetchItemInPlayerInventorySlot(plr, 3)) → "None"

local thisguy = plrs.ThisGuy
print(thisguy.Name .. " has a " .. API.FetchItemInPlayerInventorySlot(thisguy, 2)) → "ThisGuy has a Valve"
]]

function API.FetchPlayerTrinketSlot(player: Instance?, slot: number?)
	API.Assert(API.InRun == true, ".FetchPlayerTrinketSlot: You can only use this function in a run.")

	player = player or plr

	API.Assert(player ~= nil and player:IsA("Player"), ".FetchPlayerTrinketSlot: Invalid \"player\" parameter. Make sure \"player\" is a Player.")
	API.Assert(slot ~= nil and typeof(slot) == "number", ".FetchPlayerTrinketSlot: Invalid \"slot\" parameter. Make sure \"slot\" exists and is a number.")

	local trinketname = player:GetAttribute("EquippedTrinket" .. slot) or "None"

	return API.SpaceCamelCased(trinketname)
end --[[
example usage:

print(API.FetchPlayerTrinketSlot(plr, 1)) → "Vee Remote"
print(API.FetchPlayerTrinketSlot(plr, 2)) → "None"

local thisguy = plrs.ThisGuy
print(thisguy.Name .. " has a " .. API.FetchPlayerTrinketSlot(thisguy, 1) .. " equipped") → "ThisGuy has a Vee Remote equipped"
]]

function API.Get(ins: string?)
	API.Assert(API.InRun == true, ".Get: You can only use this function in a run.")
	API.Assert(ins ~= nil and typeof(ins) == "string", ".Get: Invalid \"ins\" parameter. Make sure \"ins\" is a string.")

	ins = string.lower(ins)

	if ins == "room" then
		return API.RoomFolder:FindFirstChildWhichIsA("Model") or nil
	elseif ins == "freearea" then
		return API.FreeAreaFolder
	elseif ins == "players" then
		return API.PlayersFolder
	elseif ins == "items" then
		return API.ItemsFolder
	elseif ins == "twisteds" then
		return API.TwistedsFolder
	elseif ins == "machines" then
		return API.MachinesFolder
	elseif ins == "starpillows" then
		return API.StarPillowsFolder
	elseif ins == "elevator" then
		return API.Elevator
	elseif ins == "fakelevator" then
		return API.FakeElevator
	end
end --[[
example usage:

local twisteds = API.Get("twisteds")
print(#twisteds:GetChildren() .. " twisteds are on the floor") → "3 twisteds are on the floor"
]]

-------------------------------------------------------------------------------------------------------------------------------

-- player handling
function API.GetPlayerInfo(player: Instance?, give: string?, mapNames: boolean?)
	API.Assert(API.InRun == true, ".GetPlayerInfo: You can only use this function in a run.")

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
		dead = API.Get("players"):FindFirstChild(player.Name) or nil,
	}

	if give == "table" then
		return data
	else
		return data[give]
	end
end --[[
example usage:

print(API.GetPlayerInfo(plr, "toon")) → "Poppy"
print(API.GetPlayerInfo(plr, "health") .. " HP") → "100 HP"

local thisguy = plrs.ThisGuy
local info = API.GetPlayerInfo(thisguy)
print(thisguy.Name .. " is playing as " .. info.toon .. " and currently has " .. info.tapes .. " tapes") → "ThisGuy is playing as Shelly and currently has 12 tapes"

print(API.GetPlayerInfo(thisguy, "dead") and "dead" or "alive") → "alive"
]]

function API.Exists(player: Instance?)
	player = player or plr
	
	API.Assert(player ~= nil and player:IsA("Player"), ".Exists: Invalid \"player\" parameter. Make sure \"player\" is a Player.")
	
	return API.Get("players"):FindFirstChild(player.Name)
end --[[
example usage:

print(API.Exists(plrs.ThisGuy) and "exists" or "doesn't exist yet") → "ThisGuy exists"
]]

function API.GetPlayersAlive(give: string?, toonify: boolean?)
	API.Assert(API.InRun == true, ".GetPlayersAlive: You can only use this function in a run.")

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

print(API.GetPlayersAlive("number") .. " players alive") → "4 players alive"
print(API.GetPlayersAlive("stringList")) → "You, ThisGuy, ThatGuy, OtherGuy"
print(API.GetPlayersAlive("stringList", true)) → "Poppy, Shelly, Astro, Pebble"

for _, player in ipairs(API.GetPlayersAlive()) do
	print(player.Name .. " is still alive") → "ThisGuy is still alive"
end
]]

function API.GetPlayersInElevator(give: string?, toonify: boolean?)
	API.Assert(API.InRun == true, ".GetPlayersInElevator: You can only use this function in a run.")

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

print(API.GetPlayersInElevator("number") .. " players in the elevator") → "3 players in the elevator"
print(API.GetPlayersInElevator("stringList")) → "You, ThisGuy, ThatGuy"
print(API.GetPlayersInElevator("stringList", true)) → "Poppy, Shelly, Astro"

for _, player in ipairs(API.GetPlayersInElevator()) do
	print(player.Name .. " is in the elevator") → "ThisGuy is in the elevator"
end
]]

function API.GetPlayersOutOfElevator(give: string?, toonify: boolean?)
	API.Assert(API.InRun == true, ".GetPlayersOutOfElevator: You can only use this function in a run.")

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

print(API.GetPlayersOutOfElevator("number") .. " players still outside") → "1 players still outside"
print(API.GetPlayersOutOfElevator("stringList")) → "OtherGuy"
print(API.GetPlayersOutOfElevator("stringList", true)) → "Pebble"

if API.GetPlayersOutOfElevator("number") == 0 then
	print("Everyone is in the elevator") → "Everyone is in the elevator"
end
]]

function API.TrinketActiveFor(trinket: string?, player: Instance?)
	API.Assert(API.InRun == true, ".TrinketActiveFor: You can only use this function in a run.")

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

print(API.TrinketActiveFor("VeeRemote")) → true

local thisguy = plrs.ThisGuy
print(API.TrinketActiveFor("Wrench", thisguy)) → false

if API.TrinketActiveFor("DuckToy") then
	print("Your Duck Toy is active") → "Your Duck Toy is active"
end
]]

function API.GetPlayerToon(player: Instance?)
	API.Assert(API.InRun == true, ".GetPlayerToon: You can only use this function in a run.")

	player = player or plr

	API.Assert(player ~= nil and player:IsA("Player"), ".GetPlayerToon: Invalid \"player\" parameter. Make sure \"player\" is a Player.")

	return API.GetPlayerInfo(player, "toon")
end --[[
example usage:

print("You are playing as " .. API.GetPlayerToon()) → "You are playing as Boxten"

local thisguy = plrs.ThisGuy
print(thisguy.Name .. " is playing as " .. API.GetPlayerToon(thisguy)) → "ThisGuy is playing as Cosmo"
]]

function API.PlayerCanUseAbility(player: Instance?)
	API.Assert(API.InRun == true, ".PlayerCanUseAbility: You can only use this function in a run.")

	player = player or plr

	API.Assert(player ~= nil and player:IsA("Player"), ".PlayerCanUseAbility: Invalid \"player\" parameter. Make sure \"player\" is a Player.")

	return API.GetPlayerInfo(player, "abilityActive")
end --[[
example usage:

print(API.PlayerCanUseAbility()) → true

local thisguy = plrs.ThisGuy
local thisguycan = API.PlayerCanUseAbility(thisguy) and "" or "not"
print(thisguy.Name .. " can" .. thisguycan .. " use their ability") → "ThisGuy cannot use their ability"

if API.PlayerCanUseAbility() then
	print("Your ability is ready") → "Your ability is ready"
end
]]

function API.NearTwisted(player: Instance?, studs: number?, raycastCheck: boolean?)
	API.Assert(API.InRun == true, ".NearTwisted: You can only use this function in a run.")
	API.Assert(studs ~= nil and typeof(studs) == "number", ".NearTwisted: Invalid \"studs\" parameter. Make sure \"studs\" exists and is a number.")

	player = player or plr
	raycastCheck = raycastCheck or false

	API.Assert(player ~= nil and player:IsA("Player"), ".NearTwisted: Invalid \"player\" parameter. Make sure \"player\" is a Player.")
	API.Assert(raycastCheck ~= nil and typeof(raycastCheck) == "boolean", ".NearTwisted: Invalid \"raycastCheck\" parameter. Make sure \"raycastCheck\" is a boolean.")

	local playerChar = player.Character
	local playerRoot = playerChar and playerChar:FindFirstChild("HumanoidRootPart")

	if not API.TwistedsFolder or not playerRoot then 
		return false 
	end

	for _, obj in ipairs(API.Get("twisteds"):GetChildren()) do
		if typeof(obj) == "Instance" and obj:IsA("Model") then
			local name = obj.Name

			if name:find("Blott") or name:find("Connie") or name:find("Waxwell") or name:find("Rodger") then
				continue
			end

			local twistedpos = nil

			pcall(function()
				twistedpos = obj:GetPivot().Position
			end)

			if not twistedpos then
				local twistedroot = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
				if twistedroot and twistedroot:IsA("BasePart") then
					twistedpos = twistedroot.Position
				end
			end

			if twistedpos then
				local distance = (twistedpos - playerRoot.Position).Magnitude
				if distance <= studs then
					if raycastCheck then
						local origin = playerRoot.Position
						local direction = twistedpos - origin

						local params = RaycastParams.new()
						params.FilterType = Enum.RaycastFilterType.Exclude
						params.FilterDescendantsInstances = {playerChar, obj}
						params.IgnoreWater = true

						local result = ws:Raycast(origin, direction, params)
						if not result then
							return true
						end
					else
						return true
					end
				end
			end
		end
	end

	return false
end --[[
example usage:

if API.NearTwisted(plrs.ThisGuy, 20) then
	warn("ThisGuy is 20 studs near a Twisted") → "ThisGuy is 20 studs near a Twisted"
else
	print("ThisGuy is not 20 studs near a Twisted") → "ThisGuy is not 20 studs near a Twisted"
end

if API.NearTwisted(plrs.ThisGuy, API.GetTwistedInfo(API.GetTwistedInfo(API.Get("twisteds").BoxtenMonster, "sightRadius"), true) then
	warn("ThisGuy is 20 studs within Twisted Boxten's sight") → "ThisGuy is 20 studs within Twisted Boxten's sight"
else
	print("ThisGuy is not 20 studs within Twisted Boxten's sight") → "ThisGuy is not 20 studs within Twisted Boxten's sight"
end
]]

-------------------------------------------------------------------------------------------------------------------------------

-- floor handling
function API.GetTwistedsOnFloor(give: string?, mapNames: boolean?)
	API.Assert(API.InRun == true, ".GetTwistedsOnFloor: You can only use this function in a run.")

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

print(API.GetTwistedsOnFloor("number") .. " twisteds on this floor") → "3 twisteds on this floor"
print(API.GetTwistedsOnFloor("stringList")) → "BoxtenMonster, CosmoMonster, SproutMonster"
print(API.GetTwistedsOnFloor("stringList", true)) → "Twisted Boxten, Twisted Cosmo, Twisted Sprout"

for _, twisted in ipairs(API.GetTwistedsOnFloor()) do
	print(twisted.Name) → "BoxtenMonster"
end
]]

function API.GetItemsOnFloor(give: string?, mapNames: boolean?)
	API.Assert(API.InRun == true, ".GetItemsOnFloor: You can only use this function in a run.")

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

print(API.GetItemsOnFloor("number") .. " items on the floor") → "5 items on the floor"
print(API.GetItemsOnFloor("stringList")) → "Bandage, Bandage, SpeedCandy"
print(API.GetItemsOnFloor("stringList", true)) → "Bandage, Bandage, Speed Candy"

for _, item in ipairs(API.GetItemsOnFloor()) do
	print(item.Name) → "Bandage"
end
]]

function API.GetMachineInfo(machine: Instance?, give: string?)
	API.Assert(API.InRun == true, ".GetMachineInfo: You can only use this function in a run.")
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

print(API.GetMachineInfo(machine, "type")) → "Treadmill"
print(API.GetMachineInfo(machine, "completed")) → false
print(API.GetMachineInfo(machine, "posessed")) → true

local info = API.GetMachineInfo(machine)
print(info.type .. " machine | debuffed: " .. tostring(info.debuffed) .. " | inspired: " .. tostring(info.inspired)) → "Treadmill machine | debuffed: false | inspired: true"
]]

function API.CountTwistedObstacles()
	API.Assert(API.InRun == true, ".CountTwistedObstacles: You can only use this function in a run.")

	local count = 0

	if API.FreeAreaFolder then
		for _, obj in ipairs(API.FreeAreaFolder:GetChildren()) do
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
	print("There are " .. obstacles .. " Twisted obstacles in this room") → "There are 2 Twisted obstacles in this room"
end
]]

function API.GetStarPillowOwner(pillow: Instance?, give: string?, mapNames: boolean?)
	give = give or "character" -- name, character, instance
	mapNames = mapNames or false

	API.Assert(pillow ~= nil and typeof(pillow) == "Instance", ".GetStarPillowOwner: Invalid \"pillow\" parameter. Make sure \"pillow\" exists and is an Instance.")
	API.Assert(mapNames ~= nil and typeof(mapNames) == "boolean", ".GetStarPillowOwner: Invalid \"mapNames\" parameter. Make sure \"mapNames\" is a boolean.")

	local kind = pillow:GetAttribute("PillowKind") or "Toon"
	local owner = pillow:FindFirstChild("StarPillowTarget") and pillow.StarPillowTarget.Value or nil

	if give == "character" or give == "instance" then
		if kind == "Twisted" then
			give = API.Get("twisteds"):FindFirstChild("AstroMonster")
		elseif kind == "Toon" then
			give = owner
		end
	elseif give == "name" then
		if kind == "Twisted" then
			give = mapNames and "Twisted Astro" or "AstroMonster" 
		elseif kind == "Toon" then
			give = owner and owner.Name or nil
		end
	end

	return give
end --[[
example usage:

print("This random Star pillow belongs to " .. API.GetStarPillowOwner(API.Get("starpillows")[1], "name") .. ".") → "This random Star pillow belongs to ThisGuy."
print("This random Star pillow belongs to " .. API.GetStarPillowOwner(API.Get("starpillows")[3], "name", true) .. ".") → "This random Star pillow belongs to Twisted Astro."
]]

function API.IsFloorLoaded()
	return API.IsBreakRoom() or API.GetGameInfo("gameMessage"):find("Doors open")
end --[[
example usage:

local isit = API.IsFloorLoaded()
if isit then
	warn("The floor is fully loaded") → "The floor is fully loaded"
else
	print("The floor has not finished loading") → "The floor has not finished loading"
end
]]

function API.IsFloorUnloading()
	return API.GetGameInfo("gameMessage"):find("Quickly") and not API.Get("elevator"):FindFirstChild("Opened").Value
end --[[
example usage:

local isit = API.IsFloorUnloading()
if isit then
	warn("The floor is unloading") → "The floor is unloading"
else
	print("The floor is fully loaded") → "The floor is fully loaded"
end
]]

-------------------------------------------------------------------------------------------------------------------------------

-- twisted handling
function API.GetTwistedInfo(twisted: Instance?, give: string?)
	API.Assert(API.InRun == true, ".GetTwistedInfo: You can only use this function in a run.")
	API.Assert(twisted ~= nil and typeof(twisted) == "Instance", ".GetTwistedInfo: Invalid \"twisted\" parameter. Make sure \"twisted\" exists and is an Instance.")

	give = give or "table" -- mappedName, wanderSpeed, chaseSpeed, rarity, chasing, hitboxRadius, detectionRadius, sightRadius, hearingRadius, research, awake, table

	API.Assert(give ~= nil and typeof(give) == "string", ".GetTwistedInfo: Invalid \"give\" parameter. Make sure \"give\" is a string.")

	local name = twisted.Name
	local statsfolder = twisted:FindFirstChild("Stats")

	local cannotchase = name:find("Connie") or name:find("Blot") or name:find("Waxwell")
	local chaser = not cannotchase and twisted:FindFirstChild("Chaser")

	local chasingvalue = not cannotchase and twisted:FindFirstChild("ChasingValue")

	local awake = false
	if name == "RodgerMonster" or name == "RazzleDazzleMonster" then
		awake = twisted:GetAttribute("Awake") == true
	end

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
		awake = awake
	}

	if give == "table" then
		return data
	else
		return data[give]
	end
end --[[
example usage:

local boxten = API.Get("twisteds").BoxtenMonster

print(API.GetTwistedInfo(boxten, "mappedName")) → "Twisted Boxten"
print(API.GetTwistedInfo(boxten, "rarity")) → "Common"
print(API.GetTwistedInfo(boxten, "chasing")) → false

local info = API.GetTwistedInfo(boxten)
print(info.mappedName .. " (" .. info.rarity .. ") | sight radius: " .. info.sightRadius .. " | research: " .. info.research .. "%") → "Twisted Boxten (Common) | sight radius: 40 | research: 100%"
]]

function API.GetTwistedsChasingPlayer(player: Instance?, give: string?, mapNames: boolean?)
	API.Assert(API.InRun == true, ".GetTwistedsChasingPlayer: You can only use this function in a run.")

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

print(API.GetTwistedsChasingPlayer(plr, "stringList", true) .. " are chasing you") → "Twisted Boxten, Twisted Cosmo, Twisted Sprout are chasing you"

local thisguy = plrs.ThisGuy
print(API.GetTwistedsChasingPlayer(thisguy, "stringList") .. " are chasing " .. thisguy.Name) → "BoxtenMonster, CosmoMonster, SproutMonster are chasing ThisGuy"
]]

local lasthits = setmetatable({}, { __mode = "k" })
local lastchased = setmetatable({}, { __mode = "k" })
local monitored = setmetatable({}, { __mode = "k" })

local mainmaid = tisha.new()
local sessionmaid = nil

local currentfolder = nil
local foldertimeout = 10

local function recordhit(twisted)
	local name = twisted and twisted.Name or "nil"

	local chasing = twisted and twisted:FindFirstChild("ChasingValue")
	local target = chasing and chasing.Value

	if typeof(target) ~= "Instance" then
		target = twisted and lastchased[twisted]
	end

	if typeof(target) ~= "Instance" then
		API.Debug("warn", "recordhit: Target is not a valid instance for Twisted: " .. name)
		return
	end

	if target:IsA("Player") then target = target.Character end
	if not target then
		API.Debug("warn", "recordhit: Target character could not be resolved for Twisted: " .. name)
		return
	end

	lasthits[target] = { twisted = twisted }
	API.Debug("succ", "recordhit: Success! Twisted \"" .. name .. "\" hit target character \"" .. target.Name .. "\"")
end

local function monitortwisted(twisted)
	if not twisted:IsA("Model") or monitored[twisted] then return end
	API.Debug("print", "monitortwisted: Monitoring new Twisted: " .. twisted.Name)

	local maid = tisha.new()
	monitored[twisted] = maid

	local function release()
		if monitored[twisted] ~= maid then return end
		monitored[twisted] = nil
		lastchased[twisted] = nil
		maid:destroy()
	end

	local function watchchasing(value)
		if not value:IsA("ObjectValue") then return end

		local function remember()
			if typeof(value.Value) == "Instance" then
				lastchased[twisted] = value.Value
			end
		end

		remember()
		maid:give(value:GetPropertyChangedSignal("Value"):Connect(remember))
	end

	local existing = twisted:FindFirstChild("ChasingValue")
	if existing then watchchasing(existing) end

	maid:give(twisted.ChildAdded:Connect(function(child)
		if child.Name == "ChasingValue" then
			watchchasing(child)
		end
	end))

	maid:give(twisted:GetAttributeChangedSignal("Attacking"):Connect(function()
		local attacking = twisted:GetAttribute("Attacking")
		API.Debug("print", "monitortwisted: Twisted \"" .. twisted.Name .. "\"'s \"Attacking\" attribute changed to: " .. tostring(attacking))
		if attacking == true then
			recordhit(twisted)
		end
	end))

	maid:give(twisted.Destroying:Connect(function()
		API.Debug("warn", "monitortwisted: Twisted model \"" .. twisted.Name .. "\" destroyed / removed.")
		release()
	end))

	if twisted:GetAttribute("Attacking") == true then
		API.Debug("print", "monitortwisted: Twisted " .. twisted.Name .. " is already attacking upon initialization.")
		recordhit(twisted)
	end
end

local function monitorroom(room)
	API.Debug("print", "monitorroom: Called / restarted.")

	if sessionmaid then
		API.Debug("print", "monitorroom: Destroying previous session maid.")
		sessionmaid:destroy()
	end

	local maid = tisha.new()
	sessionmaid = maid

	local previousfolder = currentfolder

	maid:spawn(function()
		API.Debug("print", "monitorroom: Waiting for the new room's Twisteds folder...")

		local startedat = os.clock()
		local folder

		while task.wait(0.1) do
			if room and not room.Parent then
				API.Debug("warn", "monitorroom: Room was removed before its Twisteds folder appeared.")
				return
			end

			folder = API.Get("twisteds")

			if typeof(folder) == "Instance" and folder:IsDescendantOf(game) then
				if room and folder:IsDescendantOf(room) then break end
				if folder ~= previousfolder then break end
				if os.clock() - startedat > foldertimeout then break end
			end
		end

		currentfolder = folder
		API.Debug("succ", "monitorroom: Twisteds folder found!")

		maid:give(folder.AncestryChanged:Connect(function()
			if not folder:IsDescendantOf(game) then
				API.Debug("warn", "monitorroom: Twisteds folder was destroyed. Restarting...")
				monitorroom()
			end
		end))

		API.Debug("print", "monitorroom: Waiting for floor...")
		repeat task.wait(0.1) until API.GetGameInfo("floorActive") == true
		API.Debug("print", "monitorroom: Floor is now active.")

		local children = folder:GetChildren()
		API.Debug("print", "monitorroom: Scanning " .. #children .. " existing children in Twisteds folder...")
		for _, twisted in ipairs(children) do
			monitortwisted(twisted)
		end

		maid:give(folder.ChildAdded:Connect(function(twisted)
			API.Debug("print", "monitorroom: ChildAdded event fired in Twisteds folder for Twisted: " .. twisted.Name)
			monitortwisted(twisted)
		end))
	end)
end

if API.InRun then
	mainmaid:give(API.RoomFolder.ChildAdded:Connect(function(room)
		API.Debug("print", ".GetPlayerLastHitBy: ChildAdded event fired for the current room. Resetting...")
		monitorroom(room)
	end), "roomadded")

	monitorroom()
end

function API.GetPlayerLastHitBy(player: Instance?, mapName: boolean?)
	API.Assert(API.InRun == true, ".GetPlayerLastHitBy: You can only use this function in a run.")

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

print("You were last hit by " .. API.GetPlayerLastHitBy(game.Players.LocalPlayer, true)) → "You were last hit by Twisted Boxten"

local thisguy = plrs.ThisGuy
print(thisguy.Name .. " was last hit by " .. API.GetPlayerLastHitBy(thisguy)) → "ThisGuy was last hit by CosmoMonster"
]]

function API.GetTwistedRarity(twisted: Instance? | string?)
	if twisted and typeof(twisted) == "Instance" then
		API.Assert(API.InRun == true, ".GetTwistedRarity: The \"twisted\" parameter must be a string since the player isn't in a run. (E.g.: \"BoxtenMonster\"")
	end

	API.Assert(twisted ~= nil and (typeof(twisted) == "Instance" or typeof(twisted) == "string"), ".GetTwistedRarity: Invalid \"twisted\" parameter. Make sure \"twisted\" exists and is an Instance or a string.")

	local twistedname = twisted.Name

	return API.TwistedRarities[twistedname] or "Unknown"
end --[[
example usage:

print(API.GetTwistedRarity(API.Get("twisteds").BoxtenMonster)) → "Common"
print(API.GetTwistedRarity("SproutMonster")) → "Main"
]]

function API.GetTwistedResearchFromPlayer(twisted: Instance? | string?, player: Instance?)
	if twisted and typeof(twisted) == "Instance" then
		API.Assert(API.InRun == true, ".GetTwistedResearchFromPlayer: The \"twisted\" parameter must be a string since the player isn't in a run. (E.g.: \"BoxtenMonster\"")
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
print(boxtenresearch) → 100

local thisguy = plrs.ThisGuy
local cosmoresearch = API.GetTwistedResearchFromPlayer("CosmoMonster", thisguy)
print(thisguy.Name .. "'s research on Twisted Cosmo: " .. cosmoresearch .. "%") → "ThisGuy's research on Twisted Cosmo: 69%"
]]

-------------------------------------------------------------------------------------------------------------------------------

-- wiki things
local function bywiki(template)
	local encoded = "https://dandys-world-robloxhorror.fandom.com/api.php?action=parse&page=Template%3A" .. template .. "&prop=wikitext&format=json"

	local ok, response = pcall(request, {Url = encoded, Method = "GET"})
	if not ok or not response or not response.Body then return nil end

	local ok2, data = pcall(https.JSONDecode, https, response.Body)
	if not ok2 or not data or not data.parse then return nil end

	return data.parse.wikitext["*"]
end

function API.GetTwistedOfTheDay()
	local twistedoftheday = bywiki("TOTDName")

	if twistedoftheday then
		twistedoftheday = twistedoftheday:gsub("<noinclude>.-</noinclude>", "")
		twistedoftheday = twistedoftheday:gsub("%[%[Category:.-%]%]", "")
		return "Twisted" .. twistedoftheday:match("^%s*(.-)%s*$")
	end
end --[[
example usage:

print("The current Twisted of the day is " .. API.GetTwistedOfTheDay() .. ".") → "The current Twisted of the day is Twisted Boxten."
]]

function API.GetPlayableToonsCount()
	local toons = bywiki("ToonAmount")

	if toons then
		return toons:match("|(%d+)%}%}")
	end
end --[[
example usage:

print("There are currently " .. API.GetPlayableToonsCount() .. " playable Toons.") → "There are currently 40 playable toons."
]]

function API.GetTwistedsCount()
	local twisteds = bywiki("TwistedAmount")

	if twisteds then
		return twisteds:match("|(%d+)%}%}")
	end
end --[[
example usage:

print("There are currently " .. API.GetTwistedsCount() .. " Twisteds that have a chance of spawning on a floor.") → "There are currently 42 Twisteds that have a chance of spawning on a floor."
]]

-------------------------------------------------------------------------------------------------------------------------------

-- init
if API.InRun then
	task.spawn(function()
		API.UpdateGameRefs()

		API.RoomFolder.ChildAdded:Connect(API.UpdateGameRefs)
		API.RoomFolder.ChildRemoved:Connect(API.UpdateGameRefs)

		plrgui:WaitForChild("ScreenGui"):WaitForChild("Menu"):WaitForChild("TopBar"):WaitForChild("FloorNumber"):GetPropertyChangedSignal("Text"):Connect(API.UpdateGameRefs)
	end)
end

API.Print("Dandy's World API Library loaded successfully.")

-------------------------------------------------------------------------------------------------------------------------------

return API

-------------------------------------------------------------------------------------------------------------------------------
