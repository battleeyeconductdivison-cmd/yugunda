local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Consistt/Ui/main/UnLeaked"))()

library.rank = "developer"

local Wm = library:Watermark("yugunda | v1 | developer")
local FpsWm = Wm:AddWatermark("fps: " .. library.fps)

local watermarkHidden = false

coroutine.wrap(function()
	while task.wait(.75) do
		if not watermarkHidden then
			FpsWm:Text("fps: " .. library.fps)
		end
	end
end)()

local Notif = library:InitNotifications()

Notif:Notify("Loading yugunda, please wait.", 5, "information")

library.title = "yugunda"

library:Introduction()
task.wait(1)

local Init = library:Init()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

local EnergyEvent = lp:WaitForChild("Events"):WaitForChild("Energy")
local yunter = ReplicatedStorage:WaitForChild("yunter")

local Tab1 = Init:NewTab("Main")
local Tab2 = Init:NewTab("Teleports")
local Tab3 = Init:NewTab("Settings")

local PlayerSection = Tab1:NewSection("Player options")

local InfiniteStamina = false

Tab1:NewToggle("Infinite Stamina", false, function(value)
	InfiniteStamina = value

	if value then
		Notif:Notify("Infinite stamina enabled.", 3, "success")
	else
		Notif:Notify("Infinite stamina disabled.", 3, "alert")
	end
end)

task.spawn(function()
	while task.wait() do
		if InfiniteStamina then
			EnergyEvent:FireServer(false)
		end
	end
end)

local messageText = ""

Tab1:NewTextbox("Message Input", "", "type message...", "all", "medium", true, false, function(val)
	messageText = val
end)

Tab1:NewButton("Send Message", function()
	local args = {
		messageText,
		"\226\128\142 Pr\226\128\142 1V\226\128\142 4t3\226\128\142 "
	}

	yunter:FireServer(unpack(args))
end)

local PlacesSection = Tab2:NewSection("Places")

local places = {
	{ name = "Gun Store",      pos = Vector3.new(194.59,  317.68,  949.08) },
	{ name = "Clothing Store", pos = Vector3.new(887.97,  317.55, -316.06) },
	{ name = "The Vault 215",  pos = Vector3.new(2466.12, 284.30, -366.06) },
	{ name = "Dealership",     pos = Vector3.new(643.06,  317.49,  350.04) },
}

for _, place in pairs(places) do
	Tab2:NewButton(place.name, function()
		local char = lp.Character or lp.CharacterAdded:Wait()
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(place.pos)
			Notif:Notify("Teleported to " .. place.name .. ".", 3, "success")
		end
	end)
end

Tab2:NewButton("Steal Closest Car", function()
	local char = lp.Character or lp.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	local hum = char:WaitForChild("Humanoid")

	local vehicles = workspace:FindFirstChild("Vehicles")
	if not vehicles then
		Notif:Notify("No vehicles folder found.", 3, "error")
		return
	end

	local closest = nil
	local closestDist = math.huge

	for _, vehicle in pairs(vehicles:GetChildren()) do
		local seat = vehicle:FindFirstChild("DriveSeat")
		if seat and seat.Occupant == nil then
			local dist = (seat.Position - hrp.Position).Magnitude
			if dist < closestDist then
				closestDist = dist
				closest = seat
			end
		end
	end

	if closest then
		hrp.CFrame = closest.CFrame * CFrame.new(0, 1.5, 0)
		task.wait(0.1)
		closest:Sit(hum)
		Notif:Notify("Stole closest car.", 3, "success")
	else
		Notif:Notify("No empty cars found.", 3, "error")
	end
end)

local PlayersSection = Tab2:NewSection("Players")

local playerButtons = {}

local function seatTeleport(target)
	local char = lp.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	if not hrp or not hum then return end

	local targetChar = target.Character
	if not targetChar then
		Notif:Notify(target.Name .. " has no character.", 3, "error")
		return
	end

	local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
	if not targetHrp then
		Notif:Notify("Could not find " .. target.Name .. ".", 3, "error")
		return
	end

	local seat = Instance.new("Seat")
	seat.Size = Vector3.new(2, 1, 2)
	seat.Anchored = true
	seat.CanCollide = false
	seat.Transparency = 1
	seat.CFrame = targetHrp.CFrame * CFrame.new(0, 3, 0)
	seat.Parent = workspace

	task.wait(0.1)

	hrp.CFrame = seat.CFrame * CFrame.new(0, 1, 0)

	task.wait(0.2)

	seat:Sit(hum)

	task.wait(0.3)

	seat:Destroy()

	Notif:Notify("Teleported to " .. target.Name .. ".", 3, "success")
end

local function addPlayerButton(player)
	if player == lp then return end
	if playerButtons[player.Name] then return end

	local btn = Tab2:NewButton(player.Name, function()
		seatTeleport(player)
	end)

	playerButtons[player.Name] = btn
end

local function removePlayerButton(player)
	if playerButtons[player.Name] then
		playerButtons[player.Name]:Remove()
		playerButtons[player.Name] = nil
	end
end

for _, player in pairs(Players:GetPlayers()) do
	addPlayerButton(player)
end

Players.PlayerAdded:Connect(function(player)
	task.wait(0.5)
	addPlayerButton(player)
	Notif:Notify(player.Name .. " joined the server.", 3, "notification")
end)

Players.PlayerRemoving:Connect(function(player)
	removePlayerButton(player)
	Notif:Notify(player.Name .. " left the server.", 3, "alert")
end)

local ClientSection = Tab3:NewSection("Client")

Tab3:NewToggle("Hide Watermark", false, function(value)
	watermarkHidden = value

	if value then
		Wm:Hide()
		FpsWm:Text("")
	else
		Wm:Show()
		FpsWm:Text("fps: " .. library.fps)
	end
end)

Tab3:NewKeybind("UI Keybind", Enum.KeyCode.RightControl, function(key)
	local newKey = Enum.KeyCode[key]

	if newKey then
		Init:UpdateKeybind(newKey)
		Notif:Notify("UI keybind changed to " .. key, 3, "success")
	end
end)

Tab3:NewButton("Unload UI", function()
	Notif:Notify("Unloading yugunda...", 3, "alert")
	task.wait(1.5)
	Wm:Remove()
	library:Remove()
end)

Notif:Notify("yugunda loaded successfully.", 4, "success")
