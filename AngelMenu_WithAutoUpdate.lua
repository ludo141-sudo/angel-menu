-- ========================================
-- ANGEL MENU V2.0 - MIT AUTO UPDATE
-- Einfach laden und F5 drücken!
-- ========================================

local CONFIG = {
    VERSION = "2.0.0",
    UPDATE_URL = "https://pastebin.com/raw/XXXXXXXX", -- <-- HIER DEINE PASTEBIN URL!
    CHECK_ON_START = true,
    AUTO_DOWNLOAD = true,
}

-- ========================================
-- AUTO UPDATE
-- ========================================

local function CheckForUpdates()
    print("^3[ANGEL MENU] Prüfe auf Updates...^0")
    
    PerformHttpRequest(CONFIG.UPDATE_URL, function(statusCode, response, headers)
        if statusCode == 200 and response then
            local newVersion = string.match(response, 'VERSION = "([%d%.]+)"')
            
            if newVersion and newVersion ~= CONFIG.VERSION then
                print("^2━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━^0")
                print("^2[UPDATE] Neue Version verfügbar!^0")
                print("^3Current: v" .. CONFIG.VERSION .. " → New: v" .. newVersion .. "^0")
                print("^2━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━^0")
                
                if CONFIG.AUTO_DOWNLOAD then
                    local file = io.open("AngelMenu_v" .. newVersion .. ".lua", "w")
                    if file then
                        file:write(response)
                        file:close()
                        print("^2✓ Update heruntergeladen: AngelMenu_v" .. newVersion .. ".lua^0")
                        print("^3→ Lade diese neue Datei in deinem Executor!^0")
                    end
                end
            else
                print("^2✓ Du hast die neueste Version (v" .. CONFIG.VERSION .. ")^0")
            end
        end
    end, "GET")
end

-- Start Check
if CONFIG.CHECK_ON_START then
    Citizen.CreateThread(function()
        Citizen.Wait(2000)
        CheckForUpdates()
    end)
end

-- Manual Check Command
RegisterCommand("update", function()
    CheckForUpdates()
end, false)


-- ========================================
-- HAUPTMENÜ CODE
-- ========================================

Chaos.Menu = {}
Chaos.Menu.debug = true

Chaos.Notifications = {}
Chaos.Notifications.enabled = true
Chaos.Notifications.queue = {}

Chaos.native = Citizen.InvokeNative
Chaos.rdr2 = Citizen

Chaos.version = "0.0.1-angel"

-- Globale Indices für Comboboxen
local geld_selfmade_index = 1
local moonshine_index = 1
local lockpick_index = 1
local brot_index = 1

local boxesp = false
local box2dESP = false

local box_esp_r = 0
local box_esp_g = 0
local box_esp_b = 0

local aimbot = false

local Keys = {
	["ESC"] = 322,
	["F1"] = 288,
	["F2"] = 289,
	["F3"] = 170,
	["F5"] = 166,
	["F6"] = 167,
	["F7"] = 168,
	["F8"] = 169,
	["F9"] = 56,
	["F10"] = 57,
	["~"] = 243,
	["1"] = 157,
	["2"] = 158,
	["3"] = 160,
	["4"] = 164,
	["5"] = 165,
	["6"] = 159,
	["7"] = 161,
	["8"] = 162,
	["9"] = 163,
	["-"] = 84,
	["="] = 83,
	["BACKSPACE"] = 177,
	["TAB"] = 37,
	["Q"] = 44,
	["W"] = 32,
	["E"] = 38,
	["R"] = 45,
	["T"] = 245,
	["Y"] = 246,
	["U"] = 303,
	["P"] = 199,
	["["] = 39,
	["]"] = 40,
	["ENTER"] = 18,
	["CAPS"] = 137,
	["A"] = 34,
	["S"] = 8,
	["D"] = 9,
	["F"] = 23,
	["G"] = 47,
	["H"] = 74,
	["K"] = 311,
	["L"] = 182,
	["LEFTSHIFT"] = 21,
	["Z"] = 20,
	["X"] = 73,
	["C"] = 26,
	["V"] = 0,
	["B"] = 29,
	["N"] = 249,
	["M"] = 244,
	[","] = 82,
	["."] = 81,
	["LEFTCTRL"] = 36,
	["LEFTALT"] = 19,
	["SPACE"] = 22,
	["RIGHTCTRL"] = 70,
	["HOME"] = 213,
	["PAGEUP"] = 10,
	["PAGEDOWN"] = 11,
	["DELETE"] = 178,
	["LEFT"] = 174,
	["RIGHT"] = 175,
	["TOP"] = 27,
	["DOWN"] = 173,
	["NENTER"] = 201,
	["N4"] = 108,
	["N5"] = 60,
	["N6"] = 107,
	["N+"] = 96,
	["N-"] = 97,
	["N7"] = 117,
	["N8"] = 61,
	["N9"] = 118,
	["MOUSE1"] = 24
}

AimbotBoneOps = { "Head", "Chest", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Dick" }
AimbotBone = "SKEL_HEAD"

function TxtAtWorldCoord(x, y, z, txt, size, font, alpha) --Cant remember where i got these two from. If someone knows please give me a pm on discord!
	alpha = alpha or 255
	local s, sx, sy = GetScreenCoordFromWorldCoord(x, y, z)
	if (sx > 0 and sx < 1) or (sy > 0 and sy < 1) then
		local s, sx, sy = GetHudScreenPositionFromWorldPosition(x, y, z)
		DrawTxt(txt, sx, sy, size, true, 255, 255, 255, alpha, true, font) -- Font 2 has some symbol conversions ex. @ becomes the rockstar logo
	end
end

function DrawTxt(str, x, y, size, enableShadow, r, g, b, a, centre, font)
	local str = CreateVarString(10, "LITERAL_STRING", str)
	SetTextScale(1, size)
	SetTextColor(math.floor(r), math.floor(g), math.floor(b), math.floor(a))
	SetTextCentre(centre)
	if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
	SetTextFontForCurrentCommand(font)
	DisplayText(str, x, y)
end

function AddVectors(vect1, vect2)
	return vector3(vect1.x + vect2.x, vect1.y + vect2.y, vect1.z + vect2.z)
end

local function ShootAt(target, bone)
	local boneTarget = GetPedBoneCoords(target, GetEntityBoneIndexByName(target, bone), 0.0, 0.0, 0.0)
	SetPedShootsAtCoord(PlayerPedId(), boneTarget, true)
end

local function ShootAt2(target, bone, damage)
	local boneTarget = GetPedBoneCoords(target, GetEntityBoneIndexByName(target, bone), 0.0, 0.0, 0.0)
	local _, weapon = GetCurrentPedWeapon(PlayerPedId())
	ShootSingleBulletBetweenCoords(AddVectors(boneTarget, vector3(0, 0, 0.1)), boneTarget, damage, true, weapon,
		PlayerPedId(), true, true, 1000.0)
end

local function ShootAimbot(k)
	if IsEntityOnScreen(k) and HasEntityClearLosToEntityInFront(PlayerPedId(), k) and
		not IsPedDeadOrDying(k) and not IsPedInVehicle(k, GetVehiclePedIsIn(k), false) and
		IsDisabledControlPressed(0, Keys["MOUSE1"]) and IsPlayerFreeAiming(PlayerId()) then
		local x, y, z = table.unpack(GetEntityCoords(k))
		local _, _x, _y = World3dToScreen2d(x, y, z)
		if _x > 0.25 and _x < 0.75 and _y > 0.25 and _y < 0.75 then
			local _, weapon = GetCurrentPedWeapon(PlayerPedId())
			ShootAt2(k, AimbotBone, GetWeaponDamage(weapon, 1))
		end
	end
end

function StartShapeTestRay(p1, p2, p3, p4, p5, p6, p7, p8, p9) return Chaos.native(0x377906D8A31E5586, p1, p2, p3, p4, p5,
		p6, p7, p8, p9, Chaos.rdr2.ReturnResultAnyway(), Chaos.rdr2.ResultAsInteger()) end

local function RGBRainbow(frequency)
	local result = {}
	local curtime = GetGameTimer() / 1000

	result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
	result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
	result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

	return result
end

function GetPlayers()
	local players = {}

	for i = 0, 63 do
		if NetworkIsPlayerActive(i) then
			table.insert(players, i)
		end
	end

	return players
end

GetMinVisualDistance = function(pos)
	local cam = GetFinalRenderedCamCoord()
	local self_ped = PlayerPedId()

	local hray, hit, coords, surfaceNormal, ent = GetShapeTestResult(StartShapeTestRay(cam.x, cam.y, cam.z, pos.x, pos.y,
		pos.z, -1, PlayerPedId(), 0))
	if hit then
		return #(cam - coords) / #(cam - pos) * 0.83
	end
end

GetCoordInNoodleSoup = function(vec, factor)
	local c = GetFinalRenderedCamCoord()
	factor = (not factor or factor >= 1) and 1 / 1.2 or factor
	return vector3(c.x + (vec.x - c.x) * factor, c.y + (vec.y - c.y) * factor, c.z + (vec.z - c.z) * factor)
end

local function get_mouse_movement()
	local x = GetDisabledControlNormal(0, GetHashKey('INPUT_LOOK_UD'))
	local y = 0
	local z = GetDisabledControlNormal(0, GetHashKey('INPUT_LOOK_LR'))
	return vector3(-x, y, -z)
end

local Crosshair = false
local Crosshairvarient2 = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if aimbot then
			local plist = GetActivePlayers()
			for i = 1, #plist do
				ShootAimbot(GetPlayerPed(plist[i]))
			end
		end


		if Crosshair then
			DrawRect(0.5, 0.5, 0.003, 0.005, 255, 0, 0, 255)
		end


		if Crosshairvarient2 then
			local pedcoords = GetEntityCoords(PlayerPedId())

			DrawRect(0.5, 0.5, 0.002, 0.003, 255, 0, 0, 255)
			DrawRect(0.5, 0.5 + -0.006, 0.002, 0.003, 255, 0, 0, 255)
			DrawRect(0.5, 0.5 + 0.006, 0.002, 0.003, 255, 0, 0, 255)
			DrawRect(0.5 + 0.003, 0.5, 0.002, 0.003, 255, 0, 0, 255)
			DrawRect(0.5 + -0.003, 0.5, 0.002, 0.003, 255, 0, 0, 255)
		end

		if box2dESP then
			local playercoords = GetEntityCoords(PlayerPedId())
			local currentPlayer = PlayerId()
			local players = GetPlayers()
			local playerPed = GetPlayerPed(player)
			local playerName = GetPlayerName(player)

			for player = 0, 64 do
				if player ~= currentPlayer and NetworkIsPlayerActive(player) then
					local pPed = GetPlayerPed(player)

					local pPed = PlayerPedId()


					local EspWidthOffset = 0
					local EspHightOffset = 0

					local box1and3Height = 0 --0.21
					local box2and4Height = 0 --0.004

					local box1and3Width = 0 --0.002
					local box2and4Width = 0 --0.048


					local box2and4Xoffset = 0 -- 0.023
					local box2and4Yoffset = 0 -- 0.105
					local box4Yoffset = 0 -- -0.105

					local box3Xoffset = 0 --0.046

					local line1xoffset = 0

					local targetCoords = GetEntityCoords(pPed)
					local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), targetCoords)

					_, x, y = GetScreenCoordFromWorldCoord(targetCoords.x, targetCoords.y, targetCoords.z)


					if distance < 5 then
						box1and3Height = 0.21
						box2and4Height = 0.004
						box1and3Width = 0.002
						box2and4Width = 0.048
						box4Yoffset = -0.105


						box2and4Xoffset = 0.023 -- 0.023
						box2and4Yoffset = 0.105 -- 0.105
						box3Xoffset = 0.046 --0.046
					elseif distance < 10 then
						box1and3Height = 0.15
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.046

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.075
						box3Xoffset = 0.046
						box4Yoffset = -0.075
					elseif distance < 15 then
						box1and3Height = 0.11
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.035

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.055
						box3Xoffset = 0.040
						box4Yoffset = -0.055
						line1xoffset = 0.006
					elseif distance < 20 then
						box1and3Height = 0.09
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.030

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.045
						box3Xoffset = 0.038
						box4Yoffset = -0.045
						line1xoffset = 0.008
					elseif distance < 40 then
						box1and3Height = 0.08
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.023

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.040
						box3Xoffset = 0.034
						box4Yoffset = -0.040
						line1xoffset = 0.012
					elseif distance < 60 then
						box1and3Height = 0.07
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.019

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.036
						box3Xoffset = 0.032
						box4Yoffset = -0.036
						line1xoffset = 0.014
					elseif distance < 80 then
						box1and3Height = 0.05
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.019

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.026
						box3Xoffset = 0.032
						box4Yoffset = -0.026
						line1xoffset = 0.014
					elseif distance < 120 then
						box1and3Height = 0.03
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.011

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.016
						box3Xoffset = 0.028
						box4Yoffset = -0.016
						line1xoffset = 0.018
					elseif distance < 140 then
						box1and3Height = 0.02
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.005

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.011
						box3Xoffset = 0.025
						box4Yoffset = -0.011
						line1xoffset = 0.021
					elseif distance < 170 then
						box1and3Height = 0.02
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.005

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.011
						box3Xoffset = 0.025
						box4Yoffset = -0.011
						line1xoffset = 0.021
					else

					end

					DrawRect(x + line1xoffset, y, box1and3Width, box1and3Height, 255, 0, 0, 255)       -- left line up line   1
					DrawRect(x + box2and4Xoffset, y + box2and4Yoffset, box2and4Width, box2and4Height, 255, 0, 0, 255) -- bottom line square base  2
					DrawRect(x + box3Xoffset, y, box1and3Width, box1and3Height, 255, 0, 0, 255)        -- right line up line 3
					DrawRect(x + box2and4Xoffset, y + box4Yoffset, box2and4Width, box2and4Height, 255, 0, 0, 255) -- top square base 4
				end
			end
		end






		if boxesp then
			local playercoords = GetEntityCoords(PlayerPedId())
			local currentPlayer = PlayerId()
			local players = GetPlayers()
			local playerPed = GetPlayerPed(player)
			local playerName = GetPlayerName(player)
			local rgb_r = box_esp_r
			local rgb_g = box_esp_g
			local rgb_b = box_esp_b

			for player = 0, 64 do
				if player ~= currentPlayer and NetworkIsPlayerActive(player) then
					local pPed = GetPlayerPed(player)



					--local pPed = PlayerPedId()
					local cx, cy, cz = table.unpack(GetEntityCoords(PlayerPedId()))
					local x, y, z = table.unpack(GetEntityCoords(pPed))


					-- box esp shit

					local mindistance = GetMinVisualDistance(GetPedBoneCoords(pPed, 0x0, 0.0, 0.0, 0.0))
					local rightknee = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0x3FCF, mindistance))
					local leftknee = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0xB3FE, mindistance))
					local neck = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0x9995, mindistance))
					local head = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0x796E, mindistance))
					local pelvis = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0x2E28, mindistance))
					local rightFoot = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0xCC4D, mindistance))
					local leftFoot = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0x3779, mindistance))
					local rightUpperArm = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0x9D4D, mindistance))
					local leftUpperArm = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0xB1C5, mindistance))
					local rightForeArm = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0x6E5C, mindistance))
					local leftForeArm = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0xEEEB, mindistance))
					local rightHand = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0xDEAD, mindistance))
					local leftHand = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0x49D9, mindistance))

					LineOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)
					LineOneEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)
					LineTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)
					LineTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
					LineThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
					LineThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, -0.9)
					LineFourBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)

					TLineOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)
					TLineOneEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
					TLineTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
					TLineTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
					TLineThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
					TLineThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, 0.8)
					TLineFourBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)

					ConnectorOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, 0.8)
					ConnectorOneEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, -0.9)
					ConnectorTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
					ConnectorTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
					ConnectorThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)
					ConnectorThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)
					ConnectorFourBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
					ConnectorFourEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)



					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, ConnectorOneBegin.x, ConnectorOneBegin.y,
						ConnectorOneBegin.z, ConnectorOneEnd.x, ConnectorOneEnd.y, ConnectorOneEnd.z, rgb_r, rgb_g, rgb_b,
						255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, ConnectorOneBegin.x, ConnectorOneBegin.y,
						ConnectorOneBegin.z, ConnectorOneEnd.x, ConnectorOneEnd.y, ConnectorOneEnd.z, rgb_r, rgb_g, rgb_b,
						255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, ConnectorTwoBegin.x, ConnectorTwoBegin.y,
						ConnectorTwoBegin.z, ConnectorTwoEnd.x, ConnectorTwoEnd.y, ConnectorTwoEnd.z, rgb_r, rgb_g, rgb_b,
						255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, ConnectorThreeBegin.x, ConnectorThreeBegin.y,
						ConnectorThreeBegin.z, ConnectorThreeEnd.x, ConnectorThreeEnd.y, ConnectorThreeEnd.z, rgb_r,
						rgb_g, rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, ConnectorFourBegin.x, ConnectorFourBegin.y,
						ConnectorFourBegin.z, ConnectorFourEnd.x, ConnectorFourEnd.y, ConnectorFourEnd.z, rgb_r, rgb_g,
						rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, LineOneBegin.x, LineOneBegin.y, LineOneBegin.z,
						LineOneEnd.x, LineOneEnd.y, LineOneEnd.z, rgb_r, rgb_g, rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, LineTwoBegin.x, LineTwoBegin.y, LineTwoBegin.z,
						LineTwoEnd.x, LineTwoEnd.y, LineTwoEnd.z, rgb_r, rgb_g, rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, LineThreeBegin.x, LineThreeBegin.y, LineThreeBegin.z,
						LineThreeEnd.x, LineThreeEnd.y, LineThreeEnd.z, rgb_r, rgb_g, rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, LineThreeEnd.x, LineThreeEnd.y, LineThreeEnd.z,
						LineFourBegin.x, LineFourBegin.y, LineFourBegin.z, rgb_r, rgb_g, rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, TLineOneBegin.x, TLineOneBegin.y, TLineOneBegin.z,
						TLineOneEnd.x, TLineOneEnd.y, TLineOneEnd.z, rgb_r, rgb_g, rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, TLineTwoBegin.x, TLineTwoBegin.y, TLineTwoBegin.z,
						TLineTwoEnd.x, TLineTwoEnd.y, TLineTwoEnd.z, rgb_r, rgb_g, rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, TLineThreeBegin.x, TLineThreeBegin.y,
						TLineThreeBegin.z, TLineThreeEnd.x, TLineThreeEnd.y, TLineThreeEnd.z, rgb_r, rgb_g, rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, TLineThreeEnd.x, TLineThreeEnd.y, TLineThreeEnd.z,
						TLineFourBegin.x, TLineFourBegin.y, TLineFourBegin.z, rgb_r, rgb_g, rgb_b, 255)
				end
			end
		end
	end
end)

local dumper = {
    client = {},
    cfg = {
        "client_script",
        "client_scripts",
        "shared_script",
        "shared_scripts",
        "ui_page",
        "ui_pages",
        "file",
        "files",
        "loadscreen",
        "map"
    }
}

function dumper:getResources()
    local resources = {}
    for i = 1, GetNumResources() do
        resources[i] = GetResourceByFindIndex(i)
    end
    return resources
end

function dumper:getFiles(res, cfg)
    res = (res or GetCurrentResourceName())
    cfg = (cfg or self.cfg)
    self.client[res] = {}
    for i, metaKey in ipairs(cfg) do
        for idx = 0, GetNumResourceMetadata(res, metaKey) - 1 do
            local file = (GetResourceMetadata(res, metaKey, idx) or "none")
            local code = (LoadResourceFile(res, file) or "")
            self.client[res][file] = code
        end
    end

    self.client[res]["manifest.lua"] = (LoadResourceFile(res, "__resource.lua") or LoadResourceFile(res, "fxmanifest.lua"))
end

Chaos.Configs = {}
Chaos.Configs.Weapons = {
	["RevolverCattleman"] = 0x169F59F7,
	["MeleeKnife"] = 0xDB21AC8C,
	["ShotgunDoublebarrel"] = 0x6DFA071B,
	["MeleeLantern"] = 0xF62FB3A3,
	["RepeaterCarbine"] = 0xF5175BA1,
	["RevolverSchofieldBill"] = 0x6DFE44AB,
	["RifleBoltactionBill"] = 0xD853C801,
	["MeleeKnifeBill"] = 0xCE3C31A4,
	["ShotgunSawedoffCharles"] = 0xBE8D2666,
	["BowCharles"] = 0x791BBD2C,
	["MeleeKnifeCharles"] = 0xB4774D3D,
	["ThrownTomahawk"] = 0xA5E972D7,
	["RevolverSchofieldDutch"] = 0xFA4B2D47,
	["RevolverSchofieldDutchDualwield"] = 0xD44A5A04,
	["MeleeKnifeDutch"] = 0x2C8DBB17,
	["RevolverCattlemanHosea"] = 0xA6FE9435,
	["RevolverCattlemanHoseaDualwield"] = 0x1EAA7376,
	["ShotgunSemiautoHosea"] = 0xFD9B510B,
	["MeleeKnifeHosea"] = 0xCACE760E,
	["RevolverDoubleactionJavier"] = 0x514B39A1,
	["ThrownThrowingKnivesJavier"] = 0x39B815A2,
	["MeleeKnifeJavier"] = 0xFA66468E,
	["RevolverCattlemanJohn"] = 0xC9622757,
	["RepeaterWinchesterJohn"] = 0xBE76397C,
	["MeleeKnifeJohn"] = 0x1D7D0737,
	["RevolverCattlemanKieran"] = 0x8FAE73BB,
	["MeleeKnifeKieran"] = 0x2F3ECD37,
	["RevolverCattlemanLenny"] = 0xC9095426,
	["SniperrifleRollingblockLenny"] = 0x21556EC2,
	["MeleeKnifeLenny"] = 0x9DD839AE,
	["RevolverDoubleactionMicah"] = 0x2300C65,
	["RevolverDoubleactionMicahDualwield"] = 0xD427AD,
	["MeleeKnifeMicah"] = 0xE9245D38,
	["RevolverCattlemanSadie"] = 0x49F6BE32,
	["RevolverCattlemanSadieDualwield"] = 0x8384D5FE,
	["RepeaterCarbineSadie"] = 0x7BD9C820,
	["ThrownThrowingKnives"] = 0xD2718D48,
	["MeleeKnifeSadie"] = 0xAF5EEF08,
	["RevolverCattlemanSean"] = 0x3EECE288,
	["MeleeKnifeSean"] = 0x64514239,
	["RevolverSchofieldUncle"] = 0x99496406,
	["ShotgunDoublebarrelUncle"] = 0x8BA6AF0A,
	["MeleeKnifeUncle"] = 0x46E97B10,
	["RevolverDoubleaction"] = 0x797FBF5,
	["RifleBoltaction"] = 0x772C8DD6,
	["RevolverSchofield"] = 0x7BBD1FF6,
	["RifleSpringfield"] = 0x63F46DE6,
	["RepeaterWinchester"] = 0xA84762EC,
	["RifleVarmint"] = 0xDDF7BC1E,
	["PistolVolcanic"] = 0x20D13FF,
	["ShotgunSawedoff"] = 0x1765A8F8,
	["PistolSemiauto"] = 0x657065D6,
	["PistolMauser"] = 0x8580C63E,
	["RepeaterHenry"] = 0x95B24592,
	["ShotgunPump"] = 0x31B7B9FE,
	["Bow"] = 0x88A8505C,
	["ThrownMolotov"] = 0x7067E7A7,
	["MeleeHatchetHewing"] = 0x1C02870C,
	["MeleeMachete"] = 0x28950C71,
	["RevolverDoubleactionExotic"] = 0x23C706CD,
	["RevolverSchofieldGolden"] = 0xE195D259,
	["ThrownDynamite"] = 0xA64DAA5E,
	["MeleeDavyLantern"] = 0x4A59E501,
	["Lasso"] = 0x7A8A724A,
	["KitBinoculars"] = 0xF6687C5A,
	["KitCamera"] = 0xC3662B7D,
	["Fishingrod"] = 0xABA87754,
	["SniperrifleRollingblock"] = 0xE1D2B317,
	["ShotgunSemiauto"] = 0x6D9BB970,
	["ShotgunRepeating"] = 0x63CA782A,
	["SniperrifleCarcano"] = 0x53944780,
	["MeleeBrokenSword"] = 0xF79190B4,
	["MeleeKnifeBear"] = 0x2BC12CDA,
	["MeleeKnifeCivilWar"] = 0xDA54DD53,
	["MeleeKnifeJawbone"] = 0x1086D041,
	["MeleeKnifeMiner"] = 0xC45B2DE,
	["MeleeKnifeVampire"] = 0x14D3F94D,
	["MeleeTorch"] = 0x67DC3FDE,
	["MeleeLanternElectric"] = 0x3155643F,
	["MeleeHatchet"] = 0x9E12A01,
	["MeleeAncientHatchet"] = 0x21CCCA44,
	["MeleeCleaver"] = 0xEF32A25D,
	["MeleeHatchetDoubleBit"] = 0xBCC63763,
	["MeleeHatchetDoubleBitRusted"] = 0x8F0FDE0E,
	["MeleeHatchetHunter"] = 0x2A5CF9D6,
	["MeleeHatchetHunterRusted"] = 0xE470B7AD,
	["MeleeHatchetViking"] = 0x74DC40ED,
	["RevolverCattlemanMexican"] = 0x16D655F7,
	["RevolverCattlemanPig"] = 0xF5E4207F,
	["RevolverSchofieldCalloway"] = 0x247E783,
	["PistolMauserDrunk"] = 0x4AAE5FFA,
	["ShotgunDoublebarrelExotic"] = 0x2250E150,
	["SniperrifleRollingblockExotic"] = 0x4E328256,
	["ThrownTomahawkAncient"] = 0x7F23B6C7,
	["MeleeTorchCrowd"] = 0xCC4588BD,
}
Chaos.Configs.AmmoTypes = {
	"AMMO_PISTOL",
	"AMMO_PISTOL_SPLIT_POINT",
	"AMMO_PISTOL_EXPRESS",
	"AMMO_PISTOL_EXPRESS_EXPLOSIVE",
	"AMMO_PISTOL_HIGH_VELOCITY",
	"AMMO_REVOLVER",
	"AMMO_REVOLVER_SPLIT_POINT",
	"AMMO_REVOLVER_EXPRESS",
	"AMMO_REVOLVER_EXPRESS_EXPLOSIVE",
	"AMMO_REVOLVER_HIGH_VELOCITY",
	"AMMO_RIFLE",
	"AMMO_RIFLE_SPLIT_POINT",
	"AMMO_RIFLE_EXPRESS",
	"AMMO_RIFLE_EXPRESS_EXPLOSIVE",
	"AMMO_RIFLE_HIGH_VELOCITY",
	"AMMO_22",
	"AMMO_REPEATER",
	"AMMO_REPEATER_SPLIT_POINT",
	"AMMO_REPEATER_EXPRESS",
	"AMMO_REPEATER_EXPRESS_EXPLOSIVE",
	"AMMO_REPEATER_HIGH_VELOCITY",
	"AMMO_SHOTGUN",
	"AMMO_SHOTGUN_BUCKSHOT_INCENDIARY",
	"AMMO_SHOTGUN_SLUG",
	"AMMO_SHOTGUN_SLUG_EXPLOSIVE",
	"AMMO_ARROW",
	"AMMO_TURRET",
	"ML_UNARMED",
	"AMMO_MOLOTOV",
	"AMMO_MOLOTOV_VOLATILE",
	"AMMO_DYNAMITE",
	"AMMO_DYNAMITE_VOLATILE",
	"AMMO_THROWING_KNIVES",
	"AMMO_THROWING_KNIVES_IMPROVED",
	"AMMO_THROWING_KNIVES_POISON",
	"AMMO_THROWING_KNIVES_JAVIER",
	"AMMO_THROWING_KNIVES_CONFUSE",
	"AMMO_THROWING_KNIVES_DISORIENT",
	"AMMO_THROWING_KNIVES_DRAIN",
	"AMMO_THROWING_KNIVES_TRAIL",
	"AMMO_THROWING_KNIVES_WOUND",
	"AMMO_TOMAHAWK",
	"AMMO_TOMAHAWK_ANCIENT",
	"AMMO_TOMAHAWK_HOMING",
	"AMMO_TOMAHAWK_IMPROVED",
	"AMMO_HATCHET",
	"AMMO_HATCHET_ANCIENT",
	"AMMO_HATCHET_CLEAVER",
	"AMMO_HATCHET_DOUBLE_BIT",
	"AMMO_HATCHET_DOUBLE_BIT_RUSTED",
	"AMMO_HATCHET_HEWING",
	"AMMO_HATCHET_HUNTER",
	"AMMO_HATCHET_HUNTER_RUSTED",
	"AMMO_HATCHET_VIKING",
	"AMMO_ARROW_FIRE",
	"AMMO_ARROW_DYNAMITE",
	"AMMO_ARROW_SMALL_GAME",
	"AMMO_ARROW_IMPROVED",
	"AMMO_ARROW_POISON",
	"AMMO_ARROW_CONFUSION",
	"AMMO_ARROW_DISORIENT",
	"AMMO_ARROW_DRAIN",
	"AMMO_ARROW_TRAIL",
	"AMMO_ARROW_WOUND",
}
Chaos.Configs.Peds = {

	Animal = {
		"a_c_alligator_01",
		"a_c_alligator_02",
		"a_c_alligator_03",
		"a_c_armadillo_01",
		"a_c_badger_01",
		"a_c_bat_01",
		"a_c_bear_01",
		"a_c_bearblack_01",
		"a_c_beaver_01",
		"a_c_bighornram_01",
		"a_c_bluejay_01",
		"a_c_boar_01",
		"a_c_boarlegendary_01",
		"a_c_buck_01",
		"a_c_buffalo_01",
		"a_c_buffalo_tatanka_01",
		"a_c_bull_01",
		"a_c_californiacondor_01",
		"a_c_cardinal_01",
		"a_c_carolinaparakeet_01",
		"a_c_cat_01",
		"a_c_cedarwaxwing_01",
		"a_c_chicken_01",
		"a_c_chipmunk_01",
		"a_c_cormorant_01",
		"a_c_cougar_01",
		"a_c_cow",
		"a_c_coyote_01",
		"a_c_crab_01",
		"a_c_cranewhooping_01",
		"a_c_crawfish_01",
		"a_c_crow_01",
		"a_c_deer_01",
		"a_c_dogamericanfoxhound_01",
		"a_c_dogaustraliansheperd_01",
		"a_c_dogbluetickcoonhound_01",
		"a_c_dogcatahoulacur_01",
		"a_c_dogchesbayretriever_01",
		"a_c_dogcollie_01",
		"a_c_doghobo_01",
		"a_c_doghound_01",
		"a_c_doghusky_01",
		"a_c_doglab_01",
		"a_c_doglion_01",
		"a_c_dogpoodle_01",
		"a_c_dogrufus_01",
		"a_c_dogstreet_01",
		"a_c_donkey_01",
		"a_c_duck_01",
		"a_c_eagle_01",
		"a_c_egret_01",
		"a_c_elk_01",
		"a_c_fishbluegil_01_ms",
		"a_c_fishbluegil_01_sm",
		"a_c_fishbullheadcat_01_ms",
		"a_c_fishbullheadcat_01_sm",
		"a_c_fishchainpickerel_01_ms",
		"a_c_fishchainpickerel_01_sm",
		"a_c_fishchannelcatfish_01_lg",
		"a_c_fishchannelcatfish_01_xl",
		"a_c_fishlakesturgeon_01_lg",
		"a_c_fishlargemouthbass_01_lg",
		"a_c_fishlargemouthbass_01_ms",
		"a_c_fishlongnosegar_01_lg",
		"a_c_fishmuskie_01_lg",
		"a_c_fishnorthernpike_01_lg",
		"a_c_fishperch_01_ms",
		"a_c_fishperch_01_sm",
		"a_c_fishrainbowtrout_01_lg",
		"a_c_fishrainbowtrout_01_ms",
		"a_c_fishredfinpickerel_01_ms",
		"a_c_fishredfinpickerel_01_sm",
		"a_c_fishrockbass_01_ms",
		"a_c_fishrockbass_01_sm",
		"a_c_fishsalmonsockeye_01_lg",
		"a_c_fishsalmonsockeye_01_ml",
		"a_c_fishsalmonsockeye_01_ms",
		"a_c_fishsmallmouthbass_01_lg",
		"a_c_fishsmallmouthbass_01_ms",
		"a_c_fox_01",
		"a_c_frogbull_01",
		"a_c_gilamonster_01",
		"a_c_goat_01",
		"a_c_goosecanada_01",
		"a_c_hawk_01",
		"a_c_heron_01",
		"a_c_horse_americanpaint_greyovero",
		"a_c_horse_americanpaint_overo",
		"a_c_horse_americanpaint_splashedwhite",
		"a_c_horse_americanpaint_tobiano",
		"a_c_horse_americanstandardbred_black",
		"a_c_horse_americanstandardbred_buckskin",
		"a_c_horse_americanstandardbred_lightbuckskin",
		"a_c_horse_americanstandardbred_palominodapple",
		"a_c_horse_americanstandardbred_silvertailbuckskin",
		"a_c_horse_andalusian_darkbay",
		"a_c_horse_andalusian_perlino",
		"a_c_horse_andalusian_rosegray",
		"a_c_horse_appaloosa_blacksnowflake",
		"a_c_horse_appaloosa_blanket",
		"a_c_horse_appaloosa_brownleopard",
		"a_c_horse_appaloosa_fewspotted_pc",
		"a_c_horse_appaloosa_leopard",
		"a_c_horse_appaloosa_leopardblanket",
		"a_c_horse_arabian_black",
		"a_c_horse_arabian_grey",
		"a_c_horse_arabian_redchestnut",
		"a_c_horse_arabian_redchestnut_pc",
		"a_c_horse_arabian_rosegreybay",
		"a_c_horse_arabian_warpedbrindle_pc",
		"a_c_horse_arabian_white",
		"a_c_horse_ardennes_bayroan",
		"a_c_horse_ardennes_irongreyroan",
		"a_c_horse_ardennes_strawberryroan",
		"a_c_horse_belgian_blondchestnut",
		"a_c_horse_belgian_mealychestnut",
		"a_c_horse_breton_grullodun",
		"a_c_horse_breton_mealydapplebay",
		"a_c_horse_breton_redroan",
		"a_c_horse_breton_sealbrown",
		"a_c_horse_breton_sorrel",
		"a_c_horse_breton_steelgrey",
		"a_c_horse_buell_warvets",
		"a_c_horse_criollo_baybrindle",
		"a_c_horse_criollo_bayframeovero",
		"a_c_horse_criollo_blueroanovero",
		"a_c_horse_criollo_dun",
		"a_c_horse_criollo_marblesabino",
		"a_c_horse_criollo_sorrelovero",
		"a_c_horse_dutchwarmblood_chocolateroan",
		"a_c_horse_dutchwarmblood_sealbrown",
		"a_c_horse_dutchwarmblood_sootybuckskin",
		"a_c_horse_eagleflies",
		"a_c_horse_gang_bill",
		"a_c_horse_gang_charles",
		"a_c_horse_gang_charles_endlesssummer",
		"a_c_horse_gang_dutch",
		"a_c_horse_gang_hosea",
		"a_c_horse_gang_javier",
		"a_c_horse_gang_john",
		"a_c_horse_gang_karen",
		"a_c_horse_gang_kieran",
		"a_c_horse_gang_lenny",
		"a_c_horse_gang_micah",
		"a_c_horse_gang_sadie",
		"a_c_horse_gang_sadie_endlesssummer",
		"a_c_horse_gang_sean",
		"a_c_horse_gang_trelawney",
		"a_c_horse_gang_uncle",
		"a_c_horse_gang_uncle_endlesssummer",
		"a_c_horse_gypsycob_palominoblagdon",
		"a_c_horse_gypsycob_piebald",
		"a_c_horse_gypsycob_skewbald",
		"a_c_horse_gypsycob_splashedbay",
		"a_c_horse_gypsycob_splashedpiebald",
		"a_c_horse_gypsycob_whiteblagdon",
		"a_c_horse_hungarianhalfbred_darkdapplegrey",
		"a_c_horse_hungarianhalfbred_flaxenchestnut",
		"a_c_horse_hungarianhalfbred_liverchestnut",
		"a_c_horse_hungarianhalfbred_piebaldtobiano",
		"a_c_horse_john_endlesssummer",
		"a_c_horse_kentuckysaddle_black",
		"a_c_horse_kentuckysaddle_buttermilkbuckskin_pc",
		"a_c_horse_kentuckysaddle_chestnutpinto",
		"a_c_horse_kentuckysaddle_grey",
		"a_c_horse_kentuckysaddle_silverbay",
		"a_c_horse_kladruber_black",
		"a_c_horse_kladruber_cremello",
		"a_c_horse_kladruber_dapplerosegrey",
		"a_c_horse_kladruber_grey",
		"a_c_horse_kladruber_silver",
		"a_c_horse_kladruber_white",
		"a_c_horse_missourifoxtrotter_amberchampagne",
		"a_c_horse_missourifoxtrotter_blacktovero",
		"a_c_horse_missourifoxtrotter_blueroan",
		"a_c_horse_missourifoxtrotter_buckskinbrindle",
		"a_c_horse_missourifoxtrotter_dapplegrey",
		"a_c_horse_missourifoxtrotter_sablechampagne",
		"a_c_horse_missourifoxtrotter_silverdapplepinto",
		"a_c_horse_morgan_bay",
		"a_c_horse_morgan_bayroan",
		"a_c_horse_morgan_flaxenchestnut",
		"a_c_horse_morgan_liverchestnut_pc",
		"a_c_horse_morgan_palomino",
		"a_c_horse_mp_mangy_backup",
		"a_c_horse_murfreebrood_mange_01",
		"a_c_horse_murfreebrood_mange_02",
		"a_c_horse_murfreebrood_mange_03",
		"a_c_horse_mustang_blackovero",
		"a_c_horse_mustang_buckskin",
		"a_c_horse_mustang_chestnuttovero",
		"a_c_horse_mustang_goldendun",
		"a_c_horse_mustang_grullodun",
		"a_c_horse_mustang_reddunovero",
		"a_c_horse_mustang_tigerstripedbay",
		"a_c_horse_mustang_wildbay",
		"a_c_horse_nokota_blueroan",
		"a_c_horse_nokota_reversedappleroan",
		"a_c_horse_nokota_whiteroan",
		"a_c_horse_norfolkroadster_black",
		"a_c_horse_norfolkroadster_dappledbuckskin",
		"a_c_horse_norfolkroadster_piebaldroan",
		"a_c_horse_norfolkroadster_rosegrey",
		"a_c_horse_norfolkroadster_speckledgrey",
		"a_c_horse_norfolkroadster_spottedtricolor",
		"a_c_horse_shire_darkbay",
		"a_c_horse_shire_lightgrey",
		"a_c_horse_shire_ravenblack",
		"a_c_horse_suffolkpunch_redchestnut",
		"a_c_horse_suffolkpunch_sorrel",
		"a_c_horse_tennesseewalker_blackrabicano",
		"a_c_horse_tennesseewalker_chestnut",
		"a_c_horse_tennesseewalker_dapplebay",
		"a_c_horse_tennesseewalker_flaxenroan",
		"a_c_horse_tennesseewalker_goldpalomino_pc",
		"a_c_horse_tennesseewalker_mahoganybay",
		"a_c_horse_tennesseewalker_redroan",
		"a_c_horse_thoroughbred_blackchestnut",
		"a_c_horse_thoroughbred_bloodbay",
		"a_c_horse_thoroughbred_brindle",
		"a_c_horse_thoroughbred_dapplegrey",
		"a_c_horse_thoroughbred_reversedappleblack",
		"a_c_horse_turkoman_black",
		"a_c_horse_turkoman_chestnut",
		"a_c_horse_turkoman_darkbay",
		"a_c_horse_turkoman_gold",
		"a_c_horse_turkoman_grey",
		"a_c_horse_turkoman_perlino",
		"a_c_horse_turkoman_silver",
		"a_c_horse_winter02_01",
		"a_c_horsemule_01",
		"a_c_horsemulepainted_01",
		"a_c_iguana_01",
		"a_c_iguanadesert_01",
		"a_c_javelina_01",
		"a_c_lionmangy_01",
		"a_c_loon_01",
		"a_c_moose_01",
		"a_c_muskrat_01",
		"a_c_oriole_01",
		"a_c_owl_01",
		"a_c_ox_01",
		"a_c_panther_01",
		"a_c_parrot_01",
		"a_c_pelican_01",
		"a_c_pheasant_01",
		"a_c_pig_01",
		"a_c_pigeon",
		"a_c_possum_01",
		"a_c_prairiechicken_01",
		"a_c_pronghorn_01",
		"a_c_quail_01",
		"a_c_rabbit_01",
		"a_c_raccoon_01",
		"a_c_rat_01",
		"a_c_raven_01",
		"a_c_redfootedbooby_01",
		"a_c_robin_01",
		"a_c_rooster_01",
		"a_c_roseatespoonbill_01",
		"a_c_seagull_01",
		"a_c_sharkhammerhead_01",
		"a_c_sharktiger",
		"a_c_sheep_01",
		"a_c_skunk_01",
		"a_c_snake_01",
		"a_c_snake_pelt_01",
		"a_c_snakeblacktailrattle_01",
		"a_c_snakeblacktailrattle_pelt_01",
		"a_c_snakeferdelance_01",
		"a_c_snakeferdelance_pelt_01",
		"a_c_snakeredboa10ft_01",
		"a_c_snakeredboa_01",
		"a_c_snakeredboa_pelt_01",
		"a_c_snakewater_01",
		"a_c_snakewater_pelt_01",
		"a_c_songbird_01",
		"a_c_sparrow_01",
		"a_c_squirrel_01",
		"a_c_toad_01",
		"a_c_turkey_01",
		"a_c_turkey_02",
		"a_c_turkeywild_01",
		"a_c_turtlesea_01",
		"a_c_turtlesnapping_01",
		"a_c_vulture_01",
		"a_c_wolf",
		"a_c_wolf_medium",
		"a_c_wolf_small",
		"a_c_woodpecker_01",
		"a_c_woodpecker_02",
		"mp_a_c_alligator_01",
		"mp_a_c_bear_01",
		"mp_a_c_beaver_01",
		"mp_a_c_bighornram_01",
		"mp_a_c_boar_01",
		"mp_a_c_buck_01",
		"mp_a_c_buffalo_01",
		"mp_a_c_chicken_01",
		"mp_a_c_cougar_01",
		"mp_a_c_coyote_01",
		"mp_a_c_deer_01",
		"mp_a_c_dogamericanfoxhound_01",
		"mp_a_c_elk_01",
		"mp_a_c_fox_01",
		"mp_a_c_horsecorpse_01",
		"mp_a_c_moose_01",
		"mp_a_c_owl_01",
		"mp_a_c_panther_01",
		"mp_a_c_possum_01",
		"mp_a_c_pronghorn_01",
		"mp_a_c_rabbit_01",
		"mp_a_c_sheep_01",
		"mp_a_c_wolf_01",
		"mp_a_f_m_protect_endflow_blackwater_01",
		"mp_a_f_m_unicorpse_01",
		"mp_a_m_m_asbminers_01",
		"mp_a_m_m_asbminers_02",
		"mp_a_m_m_coachguards_01",
		"mp_a_m_m_fos_coachguards_01",
		"mp_a_m_m_jamesonguard_01",
		"mp_a_m_m_lom_asbminers_01",
		"mp_a_m_m_protect_endflow_blackwater_01",
		"mp_a_m_m_unicorpse_01",
	},

	NPC = {
		"mp_re_rally_males_01",
		"re_rally_males_01",
		"cs_mp_policechief_lambert",
		"cs_mp_senator_ricard",
		"mp_beau_bink_females_01",
		"mp_beau_bink_males_01",
		"mp_bink_ember_of_the_east_males_01",
		"mp_carmela_bink_victim_males_01",
		"mp_cd_revengemayor_01",
		"mp_cs_antonyforemen",
		"mp_fm_bountytarget_females_dlc008_01",
		"mp_fm_bountytarget_males_dlc008_01",
		"mp_fm_bounty_horde_law_01",
		"mp_fm_knownbounty_informants_females_01",
		"mp_g_f_m_cultguards_01",
		"mp_g_m_m_cultguards_01",
		"mp_g_m_m_fos_debtgangcapitali_01",
		"mp_g_m_m_fos_debtgang_01",
		"mp_g_m_m_fos_vigilantes_01",
		"mp_g_m_m_mercs_01",
		"mp_g_m_m_mountainmen_01",
		"mp_g_m_m_riflecronies_01",
		"mp_g_m_o_uniexconfeds_cap_01",
		"mp_guidomartelli",
		"mp_lbm_carmela_banditos_01",
		"mp_lm_stealhorse_buyers_01",
		"mp_s_m_m_fos_harborguards_01",
		"mp_u_f_m_bountytarget_012",
		"mp_u_f_m_cultpriest_01",
		"mp_u_f_m_legendarybounty_03",
		"mp_u_f_m_outlaw_societylady_01",
		"mp_u_f_m_protect_mercer_01",
		"mp_u_m_m_asbdeputy_01",
		"mp_u_m_m_bankprisoner_01",
		"mp_u_m_m_binkmercs_01",
		"mp_u_m_m_cultpriest_01",
		"mp_u_m_m_dockrecipients_01",
		"mp_u_m_m_dropoff_bronte_01",
		"mp_u_m_m_dropoff_josiah_01",
		"mp_u_m_m_fos_bagholders_01",
		"mp_u_m_m_fos_coachholdup_recipient_01",
		"mp_u_m_m_fos_cornwallguard_01",
		"mp_u_m_m_fos_cornwall_bandits_01",
		"mp_u_m_m_fos_dockrecipients_01",
		"mp_u_m_m_fos_dockworker_01",
		"mp_u_m_m_fos_dropoff_01",
		"mp_u_m_m_fos_harbormaster_01",
		"mp_u_m_m_fos_interrogator_01",
		"mp_u_m_m_fos_interrogator_02",
		"mp_u_m_m_fos_musician_01",
		"mp_u_m_m_fos_railway_baron_01",
		"mp_u_m_m_fos_railway_driver_01",
		"mp_u_m_m_fos_railway_foreman_01",
		"mp_u_m_m_fos_railway_hunter_01",
		"mp_u_m_m_fos_railway_recipient_01",
		"mp_u_m_m_fos_recovery_recipient_01",
		"mp_u_m_m_fos_roguethief_01",
		"mp_u_m_m_fos_saboteur_01",
		"mp_u_m_m_fos_sdsaloon_gambler_01",
		"mp_u_m_m_fos_sdsaloon_owner_01",
		"mp_u_m_m_fos_sdsaloon_recipient_01",
		"mp_u_m_m_fos_sdsaloon_recipient_02",
		"mp_u_m_m_fos_town_outlaw_01",
		"mp_u_m_m_fos_town_vigilante_01",
		"mp_u_m_m_harbormaster_01",
		"mp_u_m_m_hctel_arm_hostage_01",
		"mp_u_m_m_hctel_arm_hostage_02",
		"mp_u_m_m_hctel_arm_hostage_03",
		"mp_u_m_m_hctel_sd_gang_01",
		"mp_u_m_m_hctel_sd_target_01",
		"mp_u_m_m_hctel_sd_target_02",
		"mp_u_m_m_hctel_sd_target_03",
		"mp_u_m_m_interrogator_01",
		"mp_u_m_m_legendarybounty_08",
		"mp_u_m_m_legendarybounty_09",
		"mp_u_m_m_lom_asbmercs_01",
		"mp_u_m_m_lom_dockworker_01",
		"mp_u_m_m_lom_dropoff_bronte_01",
		"mp_u_m_m_lom_head_security_01",
		"mp_u_m_m_lom_rhd_dealers_01",
		"mp_u_m_m_lom_rhd_sheriff_01",
		"mp_u_m_m_lom_rhd_smithassistant_01",
		"mp_u_m_m_lom_saloon_drunk_01",
		"mp_u_m_m_lom_sd_dockworker_01",
		"mp_u_m_m_lom_train_barricade_01",
		"mp_u_m_m_lom_train_clerk_01",
		"mp_u_m_m_lom_train_conductor_01",
		"mp_u_m_m_lom_train_lawtarget_01",
		"mp_u_m_m_lom_train_prisoners_01",
		"mp_u_m_m_lom_train_wagondropoff_01",
		"mp_u_m_m_musician_01",
		"mp_u_m_m_outlaw_arrestedthief_01",
		"mp_u_m_m_outlaw_coachdriver_01",
		"mp_u_m_m_outlaw_covington_01",
		"mp_u_m_m_outlaw_mpvictim_01",
		"mp_u_m_m_outlaw_rhd_noble_01",
		"mp_u_m_m_protect_armadillo_01",
		"mp_u_m_m_protect_blackwater_01",
		"mp_u_m_m_protect_friendly_armadillo_01",
		"mp_u_m_m_protect_halloween_ned_01",
		"mp_u_m_m_protect_macfarlanes_contact_01",
		"mp_u_m_m_protect_mercer_contact_01",
		"mp_u_m_m_protect_strawberry",
		"mp_u_m_m_protect_strawberry_01",
		"mp_u_m_m_protect_valentine_01",
		"mp_u_m_o_lom_asbforeman_01",
		"u_m_m_bht_outlawmauled",
		"a_f_m_armcholeracorpse_01",
		"a_f_m_armtownfolk_01",
		"a_f_m_armtownfolk_02",
		"a_f_m_asbtownfolk_01",
		"a_f_m_bivfancytravellers_01",
		"a_f_m_blwtownfolk_01",
		"a_f_m_blwtownfolk_02",
		"a_f_m_blwupperclass_01",
		"a_f_m_btchillbilly_01",
		"a_f_m_btcobesewomen_01",
		"a_f_m_bynfancytravellers_01",
		"a_f_m_familytravelers_cool_01",
		"a_f_m_familytravelers_warm_01",
		"a_f_m_gamhighsociety_01",
		"a_f_m_grifancytravellers_01",
		"a_f_m_guatownfolk_01",
		"a_f_m_htlfancytravellers_01",
		"a_f_m_lagtownfolk_01",
		"a_f_m_lowersdtownfolk_01",
		"a_f_m_lowersdtownfolk_02",
		"a_f_m_lowersdtownfolk_03",
		"a_f_m_lowertrainpassengers_01",
		"a_f_m_middlesdtownfolk_01",
		"a_f_m_middlesdtownfolk_02",
		"a_f_m_middlesdtownfolk_03",
		"a_f_m_middletrainpassengers_01",
		"a_f_m_nbxslums_01",
		"a_f_m_nbxupperclass_01",
		"a_f_m_nbxwhore_01",
		"a_f_m_rhdprostitute_01",
		"a_f_m_rhdtownfolk_01",
		"a_f_m_rhdtownfolk_02",
		"a_f_m_rhdupperclass_01",
		"a_f_m_rkrfancytravellers_01",
		"a_f_m_roughtravellers_01",
		"a_f_m_sclfancytravellers_01",
		"a_f_m_sdchinatown_01",
		"a_f_m_sdfancywhore_01",
		"a_f_m_sdobesewomen_01",
		"a_f_m_sdserversformal_01",
		"a_f_m_sdslums_02",
		"a_f_m_skpprisononline_01",
		"a_f_m_strtownfolk_01",
		"a_f_m_tumtownfolk_01",
		"a_f_m_tumtownfolk_02",
		"a_f_m_unicorpse_01",
		"a_f_m_uppertrainpassengers_01",
		"a_f_m_valprostitute_01",
		"a_f_m_valtownfolk_01",
		"a_f_m_vhtprostitute_01",
		"a_f_m_vhttownfolk_01",
		"a_f_m_waptownfolk_01",
		"a_f_o_blwupperclass_01",
		"a_f_o_btchillbilly_01",
		"a_f_o_guatownfolk_01",
		"a_f_o_lagtownfolk_01",
		"a_f_o_sdchinatown_01",
		"a_f_o_sdupperclass_01",
		"a_f_o_waptownfolk_01",
		"a_m_m_armcholeracorpse_01",
		"a_m_m_armdeputyresident_01",
		"a_m_m_armtownfolk_01",
		"a_m_m_armtownfolk_02",
		"a_m_m_asbboatcrew_01",
		"a_m_m_asbdeputyresident_01",
		"a_m_m_asbminer_01",
		"a_m_m_asbminer_02",
		"a_m_m_asbminer_03",
		"a_m_m_asbminer_04",
		"a_m_m_asbtownfolk_01",
		"a_m_m_asbtownfolk_01_laborer",
		"a_m_m_bivfancydrivers_01",
		"a_m_m_bivfancytravellers_01",
		"a_m_m_bivroughtravellers_01",
		"a_m_m_bivworker_01",
		"a_m_m_blwforeman_01",
		"a_m_m_blwlaborer_01",
		"a_m_m_blwlaborer_02",
		"a_m_m_blwobesemen_01",
		"a_m_m_blwtownfolk_01",
		"a_m_m_blwupperclass_01",
		"a_m_m_btchillbilly_01",
		"a_m_m_btcobesemen_01",
		"a_m_m_bynfancydrivers_01",
		"a_m_m_bynfancytravellers_01",
		"a_m_m_bynroughtravellers_01",
		"a_m_m_bynsurvivalist_01",
		"a_m_m_cardgameplayers_01",
		"a_m_m_chelonian_01",
		"a_m_m_deliverytravelers_cool_01",
		"a_m_m_deliverytravelers_warm_01",
		"a_m_m_dominoesplayers_01",
		"a_m_m_emrfarmhand_01",
		"a_m_m_familytravelers_cool_01",
		"a_m_m_familytravelers_warm_01",
		"a_m_m_farmtravelers_cool_01",
		"a_m_m_farmtravelers_warm_01",
		"a_m_m_fivefingerfilletplayers_01",
		"a_m_m_foreman",
		"a_m_m_gamhighsociety_01",
		"a_m_m_grifancydrivers_01",
		"a_m_m_grifancytravellers_01",
		"a_m_m_griroughtravellers_01",
		"a_m_m_grisurvivalist_01",
		"a_m_m_guatownfolk_01",
		"a_m_m_htlfancydrivers_01",
		"a_m_m_htlfancytravellers_01",
		"a_m_m_htlroughtravellers_01",
		"a_m_m_htlsurvivalist_01",
		"a_m_m_huntertravelers_cool_01",
		"a_m_m_huntertravelers_warm_01",
		"a_m_m_jamesonguard_01",
		"a_m_m_lagtownfolk_01",
		"a_m_m_lowersdtownfolk_01",
		"a_m_m_lowersdtownfolk_02",
		"a_m_m_lowertrainpassengers_01",
		"a_m_m_middlesdtownfolk_01",
		"a_m_m_middlesdtownfolk_02",
		"a_m_m_middlesdtownfolk_03",
		"a_m_m_middletrainpassengers_01",
		"a_m_m_moonshiners_01",
		"a_m_m_nbxdockworkers_01",
		"a_m_m_nbxlaborers_01",
		"a_m_m_nbxslums_01",
		"a_m_m_nbxupperclass_01",
		"a_m_m_nearoughtravellers_01",
		"a_m_m_rancher_01",
		"a_m_m_ranchertravelers_cool_01",
		"a_m_m_ranchertravelers_warm_01",
		"a_m_m_rhddeputyresident_01",
		"a_m_m_rhdforeman_01",
		"a_m_m_rhdobesemen_01",
		"a_m_m_rhdtownfolk_01",
		"a_m_m_rhdtownfolk_01_laborer",
		"a_m_m_rhdtownfolk_02",
		"a_m_m_rhdupperclass_01",
		"a_m_m_rkrfancydrivers_01",
		"a_m_m_rkrfancytravellers_01",
		"a_m_m_rkrroughtravellers_01",
		"a_m_m_rkrsurvivalist_01",
		"a_m_m_sclfancydrivers_01",
		"a_m_m_sclfancytravellers_01",
		"a_m_m_sclroughtravellers_01",
		"a_m_m_sdchinatown_01",
		"a_m_m_sddockforeman_01",
		"a_m_m_sddockworkers_02",
		"a_m_m_sdfancytravellers_01",
		"a_m_m_sdlaborers_02",
		"a_m_m_sdobesemen_01",
		"a_m_m_sdroughtravellers_01",
		"a_m_m_sdserversformal_01",
		"a_m_m_sdslums_02",
		"a_m_m_skpprisoner_01",
		"a_m_m_skpprisonline_01",
		"a_m_m_smhthug_01",
		"a_m_m_strdeputyresident_01",
		"a_m_m_strfancytourist_01",
		"a_m_m_strlaborer_01",
		"a_m_m_strtownfolk_01",
		"a_m_m_tumtownfolk_01",
		"a_m_m_tumtownfolk_02",
		"a_m_m_uniboatcrew_01",
		"a_m_m_unicoachguards_01",
		"a_m_m_unicorpse_01",
		"a_m_m_unigunslinger_01",
		"a_m_m_uppertrainpassengers_01",
		"a_m_m_valcriminals_01",
		"a_m_m_valdeputyresident_01",
		"a_m_m_valfarmer_01",
		"a_m_m_vallaborer_01",
		"a_m_m_valtownfolk_01",
		"a_m_m_valtownfolk_02",
		"a_m_m_vhtboatcrew_01",
		"a_m_m_vhtthug_01",
		"a_m_m_vhttownfolk_01",
		"a_m_m_wapwarriors_01",
		"a_m_o_blwupperclass_01",
		"a_m_o_btchillbilly_01",
		"a_m_o_guatownfolk_01",
		"a_m_o_lagtownfolk_01",
		"a_m_o_sdchinatown_01",
		"a_m_o_sdupperclass_01",
		"a_m_o_waptownfolk_01",
		"a_m_y_asbminer_01",
		"a_m_y_asbminer_02",
		"a_m_y_asbminer_03",
		"a_m_y_asbminer_04",
		"a_m_y_nbxstreetkids_01",
		"a_m_y_nbxstreetkids_slums_01",
		"a_m_y_sdstreetkids_slums_02",
		"a_m_y_unicorpse_01",
		"am_valentinedoctors_females_01",
		"amsp_robsdgunsmith_males_01",
		"casp_coachrobbery_lenny_males_01",
		"casp_coachrobbery_micah_males_01",
		"casp_hunting02_males_01",
		"charro_saddle_01",
		"cr_strawberry_males_01",
		"cs_abe",
		"cs_aberdeenpigfarmer",
		"cs_aberdeensister",
		"cs_abigailroberts",
		"cs_acrobat",
		"cs_adamgray",
		"cs_agnesdowd",
		"cs_albertcakeesquire",
		"cs_albertmason",
		"cs_andershelgerson",
		"cs_angel",
		"cs_angryhusband",
		"cs_angusgeddes",
		"cs_ansel_atherton",
		"cs_antonyforemen",
		"cs_archerfordham",
		"cs_archibaldjameson",
		"cs_archiedown",
		"cs_artappraiser",
		"cs_asbdeputy_01",
		"cs_ashton",
		"cs_balloonoperator",
		"cs_bandbassist",
		"cs_banddrummer",
		"cs_bandpianist",
		"cs_bandsinger",
		"cs_baptiste",
		"cs_bartholomewbraithwaite",
		"cs_bathingladies_01",
		"cs_beatenupcaptain",
		"cs_beaugray",
		"cs_billwilliamson",
		"cs_bivcoachdriver",
		"cs_blwphotographer",
		"cs_blwwitness",
		"cs_braithwaitebutler",
		"cs_braithwaitemaid",
		"cs_braithwaiteservant",
		"cs_brendacrawley",
		"cs_bronte",
		"cs_brontesbutler",
		"cs_brotherdorkins",
		"cs_brynntildon",
		"cs_bubba",
		"cs_cabaretmc",
		"cs_cajun",
		"cs_cancan_01",
		"cs_cancan_02",
		"cs_cancan_03",
		"cs_cancan_04",
		"cs_cancanman_01",
		"cs_captainmonroe",
		"cs_cassidy",
		"cs_catherinebraithwaite",
		"cs_cattlerustler",
		"cs_cavehermit",
		"cs_chainprisoner_01",
		"cs_chainprisoner_02",
		"cs_charlessmith",
		"cs_chelonianmaster",
		"cs_cigcardguy",
		"cs_clay",
		"cs_cleet",
		"cs_clive",
		"cs_colfavours",
		"cs_colmodriscoll",
		"cs_cooper",
		"cs_cornwalltrainconductor",
		"cs_crackpotinventor",
		"cs_crackpotrobot",
		"cs_creepyoldlady",
		"cs_creolecaptain",
		"cs_creoledoctor",
		"cs_creoleguy",
		"cs_dalemaroney",
		"cs_daveycallender",
		"cs_davidgeddes",
		"cs_desmond",
		"cs_didsbury",
		"cs_dinoboneslady",
		"cs_disguisedduster_01",
		"cs_disguisedduster_02",
		"cs_disguisedduster_03",
		"cs_doroetheawicklow",
		"cs_drhiggins",
		"cs_drmalcolmmacintosh",
		"cs_duncangeddes",
		"cs_dusterinformant_01",
		"cs_dutch",
		"cs_eagleflies",
		"cs_edgarross",
		"cs_edith_john",
		"cs_edithdown",
		"cs_edmundlowry",
		"cs_escapeartist",
		"cs_escapeartistassistant",
		"cs_evelynmiller",
		"cs_exconfedinformant",
		"cs_exconfedsleader_01",
		"cs_exoticcollector",
		"cs_famousgunslinger_01",
		"cs_famousgunslinger_02",
		"cs_famousgunslinger_03",
		"cs_famousgunslinger_04",
		"cs_famousgunslinger_05",
		"cs_famousgunslinger_06",
		"cs_featherstonchambers",
		"cs_featsofstrength",
		"cs_fightref",
		"cs_fire_breather",
		"cs_fishcollector",
		"cs_forgivenhusband_01",
		"cs_forgivenwife_01",
		"cs_formyartbigwoman",
		"cs_francis_sinclair",
		"cs_frenchartist",
		"cs_frenchman_01",
		"cs_fussar",
		"cs_garethbraithwaite",
		"cs_gavin",
		"cs_genstoryfemale",
		"cs_genstorymale",
		"cs_geraldbraithwaite",
		"cs_germandaughter",
		"cs_germanfather",
		"cs_germanmother",
		"cs_germanson",
		"cs_gilbertknightly",
		"cs_gloria",
		"cs_grizzledjon",
		"cs_guidomartelli",
		"cs_hamish",
		"cs_hectorfellowes",
		"cs_henrilemiux",
		"cs_herbalist",
		"cs_hercule",
		"cs_hestonjameson",
		"cs_hobartcrawley",
		"cs_hoseamatthews",
		"cs_iangray",
		"cs_jackmarston",
		"cs_jackmarston_teen",
		"cs_jamie",
		"cs_janson",
		"cs_javierescuella",
		"cs_jeb",
		"cs_jimcalloway",
		"cs_jockgray",
		"cs_joe",
		"cs_joebutler",
		"cs_johnmarston",
		"cs_johnthebaptisingmadman",
		"cs_johnweathers",
		"cs_josiahtrelawny",
		"cs_jules",
		"cs_karen",
		"cs_karensjohn_01",
		"cs_kieran",
		"cs_laramie",
		"cs_leighgray",
		"cs_lemiuxassistant",
		"cs_lenny",
		"cs_leon",
		"cs_leostrauss",
		"cs_levisimon",
		"cs_leviticuscornwall",
		"cs_lillianpowell",
		"cs_lillymillet",
		"cs_londonderryson",
		"cs_lucanapoli",
		"cs_magnifico",
		"cs_mamawatson",
		"cs_marshall_thurwell",
		"cs_marybeth",
		"cs_marylinton",
		"cs_meditatingmonk",
		"cs_meredith",
		"cs_meredithsmother",
		"cs_micahbell",
		"cs_micahsnemesis",
		"cs_mickey",
		"cs_miltonandrews",
		"cs_missmarjorie",
		"cs_mixedracekid",
		"cs_moira",
		"cs_mollyoshea",
		"cs_mp_agent_hixon",
		"cs_mp_alfredo_montez",
		"cs_mp_allison",
		"cs_mp_amos_lansing",
		"cs_mp_bessie_adair",
		"cs_mp_bonnie",
		"cs_mp_bountyhunter",
		"cs_mp_camp_cook",
		"cs_mp_cliff",
		"cs_mp_cripps",
		"cs_mp_dannylee",
		"cs_mp_grace_lancing",
		"cs_mp_gus_macmillan",
		"cs_mp_hans",
		"cs_mp_harriet_davenport",
		"cs_mp_henchman",
		"cs_mp_horley",
		"cs_mp_jeremiah_shaw",
		"cs_mp_jessica",
		"cs_mp_jorge_montez",
		"cs_mp_langston",
		"cs_mp_lee",
		"cs_mp_lem",
		"cs_mp_mabel",
		"cs_mp_maggie",
		"cs_mp_marshall_davies",
		"cs_mp_moonshiner",
		"cs_mp_mradler",
		"cs_mp_oldman_jones",
		"cs_mp_revenge_marshall",
		"cs_mp_samson_finch",
		"cs_mp_seth",
		"cs_mp_shaky",
		"cs_mp_sherifffreeman",
		"cs_mp_teddybrown",
		"cs_mp_terrance",
		"cs_mp_the_boy",
		"cs_mp_travellingsaleswoman",
		"cs_mp_went",
		"cs_mradler",
		"cs_mrdevon",
		"cs_mrlinton",
		"cs_mrpearson",
		"cs_mrs_calhoun",
		"cs_mrs_sinclair",
		"cs_mrsadler",
		"cs_mrsfellows",
		"cs_mrsgeddes",
		"cs_mrslondonderry",
		"cs_mrsweathers",
		"cs_mrwayne",
		"cs_mud2bigguy",
		"cs_mysteriousstranger",
		"cs_nbxdrunk",
		"cs_nbxexecuted",
		"cs_nbxpolicechiefformal",
		"cs_nbxreceptionist_01",
		"cs_nial_whelan",
		"cs_nicholastimmins",
		"cs_nils",
		"cs_norrisforsythe",
		"cs_obediahhinton",
		"cs_oddfellowspinhead",
		"cs_odprostitute",
		"cs_operasinger",
		"cs_paytah",
		"cs_penelopebraithwaite",
		"cs_pinkertongoon",
		"cs_poisonwellshaman",
		"cs_poorjoe",
		"cs_priest_wedding",
		"cs_princessisabeau",
		"cs_professorbell",
		"cs_rainsfall",
		"cs_ramon_cortez",
		"cs_reverendfortheringham",
		"cs_revswanson",
		"cs_rhodeputy_01",
		"cs_rhodeputy_02",
		"cs_rhodesassistant",
		"cs_rhodeskidnapvictim",
		"cs_rhodessaloonbouncer",
		"cs_ringmaster",
		"cs_rockyseven_widow",
		"cs_samaritan",
		"cs_scottgray",
		"cs_sd_streetkid_01",
		"cs_sd_streetkid_01a",
		"cs_sd_streetkid_01b",
		"cs_sd_streetkid_02",
		"cs_sddoctor_01",
		"cs_sdpriest",
		"cs_sdsaloondrunk_01",
		"cs_sdstreetkidthief",
		"cs_sean",
		"cs_sherifffreeman",
		"cs_sheriffowens",
		"cs_sistercalderon",
		"cs_slavecatcher",
		"cs_soothsayer",
		"cs_strawberryoutlaw_01",
		"cs_strawberryoutlaw_02",
		"cs_strdeputy_01",
		"cs_strdeputy_02",
		"cs_strsheriff_01",
		"cs_sunworshipper",
		"cs_susangrimshaw",
		"cs_swampfreak",
		"cs_swampweirdosonny",
		"cs_sworddancer",
		"cs_tavishgray",
		"cs_taxidermist",
		"cs_theodorelevin",
		"cs_thomasdown",
		"cs_tigerhandler",
		"cs_tilly",
		"cs_timothydonahue",
		"cs_tinyhermit",
		"cs_tomdickens",
		"cs_towncrier",
		"cs_treasurehunter",
		"cs_twinbrother_01",
		"cs_twinbrother_02",
		"cs_twingroupie_01",
		"cs_twingroupie_02",
		"cs_uncle",
		"cs_unidusterjail_01",
		"cs_valauctionboss_01",
		"cs_valdeputy_01",
		"cs_valprayingman",
		"cs_valprostitute_01",
		"cs_valprostitute_02",
		"cs_valsheriff",
		"cs_vampire",
		"cs_vht_bathgirl",
		"cs_wapitiboy",
		"cs_warvet",
		"cs_watson_01",
		"cs_watson_02",
		"cs_watson_03",
		"cs_welshfighter",
		"cs_wintonholmes",
		"cs_wrobel",
		"female_skeleton",
		"g_f_m_uniduster_01",
		"g_m_m_bountyhunters_01",
		"g_m_m_uniafricanamericangang_01",
		"g_m_m_unibanditos_01",
		"g_m_m_unibraithwaites_01",
		"g_m_m_unibrontegoons_01",
		"g_m_m_unicornwallgoons_01",
		"g_m_m_unicriminals_01",
		"g_m_m_unicriminals_02",
		"g_m_m_uniduster_01",
		"g_m_m_uniduster_02",
		"g_m_m_uniduster_03",
		"g_m_m_uniduster_04",
		"g_m_m_uniduster_05",
		"g_m_m_unigrays_01",
		"g_m_m_unigrays_02",
		"g_m_m_uniinbred_01",
		"g_m_m_unilangstonboys_01",
		"g_m_m_unimicahgoons_01",
		"g_m_m_unimountainmen_01",
		"g_m_m_uniranchers_01",
		"g_m_m_uniswamp_01",
		"g_m_o_uniexconfeds_01",
		"g_m_y_uniexconfeds_01",
		"g_m_y_uniexconfeds_02",
		"gc_lemoynecaptive_males_01",
		"gc_skinnertorture_males_01",
		"ge_delloboparty_females_01",
		"loansharking_asbminer_males_01",
		"loansharking_horsechase1_males_01",
		"loansharking_undertaker_females_01",
		"loansharking_undertaker_males_01",
		"male_skeleton",
		"mbh_rhodesrancher_females_01",
		"mbh_rhodesrancher_teens_01",
		"mbh_skinnersearch_males_01",
		"mcclellan_saddle_01",
		"mes_abigail2_males_01",
		"mes_finale2_females_01",
		"mes_finale2_males_01",
		"mes_finale3_males_01",
		"mes_marston1_males_01",
		"mes_marston2_males_01",
		"mes_marston5_2_males_01",
		"mes_marston6_females_01",
		"mes_marston6_males_01",
		"mes_marston6_teens_01",
		"mes_sadie4_males_01",
		"mes_sadie5_males_01",
		"motherhubbard_saddle_01",
		"mp_s_m_m_revenueagents_cap_01",
		"mp_u_m_m_fos_railway_guards_01",
		"mp_u_m_m_rhd_bountytarget_01",
		"mp_u_m_m_rhd_bountytarget_02",
		"mp_u_m_m_rhd_bountytarget_03",
		"mp_u_m_m_rhd_bountytarget_03b",
		"mp_a_f_m_cardgameplayers_01",
		"mp_a_f_m_saloonband_females_01",
		"mp_a_f_m_saloonpatrons_01",
		"mp_a_f_m_saloonpatrons_02",
		"mp_a_f_m_saloonpatrons_03",
		"mp_a_f_m_saloonpatrons_04",
		"mp_a_f_m_saloonpatrons_05",
		"mp_a_m_m_laboruprisers_01",
		"mp_a_m_m_moonshinemakers_01",
		"mp_a_m_m_saloonband_males_01",
		"mp_a_m_m_saloonpatrons_01",
		"mp_a_m_m_saloonpatrons_02",
		"mp_a_m_m_saloonpatrons_03",
		"mp_a_m_m_saloonpatrons_04",
		"mp_a_m_m_saloonpatrons_05",
		"mp_asn_benedictpoint_females_01",
		"mp_asn_benedictpoint_males_01",
		"mp_asn_blackwater_males_01",
		"mp_asn_braithwaitemanor_males_01",
		"mp_asn_braithwaitemanor_males_02",
		"mp_asn_braithwaitemanor_males_03",
		"mp_asn_civilwarfort_males_01",
		"mp_asn_gaptoothbreach_males_01",
		"mp_asn_pikesbasin_males_01",
		"mp_asn_sdpolicestation_males_01",
		"mp_asn_sdwedding_females_01",
		"mp_asn_sdwedding_males_01",
		"mp_asn_shadybelle_females_01",
		"mp_asn_stillwater_males_01",
		"mp_asntrk_elysianpool_males_01",
		"mp_asntrk_grizzlieswest_males_01",
		"mp_asntrk_hagenorchard_males_01",
		"mp_asntrk_isabella_males_01",
		"mp_asntrk_talltrees_males_01",
		"mp_campdef_bluewater_females_01",
		"mp_campdef_bluewater_males_01",
		"mp_campdef_chollasprings_females_01",
		"mp_campdef_chollasprings_males_01",
		"mp_campdef_eastnewhanover_females_01",
		"mp_campdef_eastnewhanover_males_01",
		"mp_campdef_gaptoothbreach_females_01",
		"mp_campdef_gaptoothbreach_males_01",
		"mp_campdef_gaptoothridge_females_01",
		"mp_campdef_gaptoothridge_males_01",
		"mp_campdef_greatplains_males_01",
		"mp_campdef_grizzlies_males_01",
		"mp_campdef_heartlands1_males_01",
		"mp_campdef_heartlands2_females_01",
		"mp_campdef_heartlands2_males_01",
		"mp_campdef_hennigans_females_01",
		"mp_campdef_hennigans_males_01",
		"mp_campdef_littlecreek_females_01",
		"mp_campdef_littlecreek_males_01",
		"mp_campdef_radleyspasture_females_01",
		"mp_campdef_radleyspasture_males_01",
		"mp_campdef_riobravo_females_01",
		"mp_campdef_riobravo_males_01",
		"mp_campdef_roanoke_females_01",
		"mp_campdef_roanoke_males_01",
		"mp_campdef_talltrees_females_01",
		"mp_campdef_talltrees_males_01",
		"mp_campdef_tworocks_females_01",
		"mp_chu_kid_armadillo_males_01",
		"mp_chu_kid_diabloridge_males_01",
		"mp_chu_kid_emrstation_males_01",
		"mp_chu_kid_greatplains2_males_01",
		"mp_chu_kid_greatplains_males_01",
		"mp_chu_kid_heartlands_males_01",
		"mp_chu_kid_lagras_males_01",
		"mp_chu_kid_lemoyne_females_01",
		"mp_chu_kid_lemoyne_males_01",
		"mp_chu_kid_recipient_males_01",
		"mp_chu_kid_rhodes_males_01",
		"mp_chu_kid_saintdenis_females_01",
		"mp_chu_kid_saintdenis_males_01",
		"mp_chu_kid_scarlettmeadows_males_01",
		"mp_chu_kid_tumbleweed_males_01",
		"mp_chu_kid_valentine_males_01",
		"mp_chu_rob_ambarino_males_01",
		"mp_chu_rob_annesburg_males_01",
		"mp_chu_rob_benedictpoint_females_01",
		"mp_chu_rob_benedictpoint_males_01",
		"mp_chu_rob_blackwater_males_01",
		"mp_chu_rob_caligahall_males_01",
		"mp_chu_rob_coronado_males_01",
		"mp_chu_rob_cumberland_males_01",
		"mp_chu_rob_fortmercer_females_01",
		"mp_chu_rob_fortmercer_males_01",
		"mp_chu_rob_greenhollow_males_01",
		"mp_chu_rob_macfarlanes_females_01",
		"mp_chu_rob_macfarlanes_males_01",
		"mp_chu_rob_macleans_males_01",
		"mp_chu_rob_millesani_males_01",
		"mp_chu_rob_montanariver_males_01",
		"mp_chu_rob_paintedsky_males_01",
		"mp_chu_rob_rathskeller_males_01",
		"mp_chu_rob_recipient_males_01",
		"mp_chu_rob_rhodes_males_01",
		"mp_chu_rob_strawberry_males_01",
		"mp_clay",
		"mp_convoy_recipient_females_01",
		"mp_convoy_recipient_males_01",
		"mp_de_u_f_m_bigvalley_01",
		"mp_de_u_f_m_bluewatermarsh_01",
		"mp_de_u_f_m_braithwaite_01",
		"mp_de_u_f_m_doverhill_01",
		"mp_de_u_f_m_greatplains_01",
		"mp_de_u_f_m_hangingrock_01",
		"mp_de_u_f_m_heartlands_01",
		"mp_de_u_f_m_hennigansstead_01",
		"mp_de_u_f_m_silentstead_01",
		"mp_de_u_m_m_aurorabasin_01",
		"mp_de_u_m_m_barrowlagoon_01",
		"mp_de_u_m_m_bigvalleygraves_01",
		"mp_de_u_m_m_centralunionrr_01",
		"mp_de_u_m_m_pleasance_01",
		"mp_de_u_m_m_rileyscharge_01",
		"mp_de_u_m_m_vanhorn_01",
		"mp_de_u_m_m_westernhomestead_01",
		"mp_dr_u_f_m_bayougatorfood_01",
		"mp_dr_u_f_m_bigvalleycave_01",
		"mp_dr_u_f_m_bigvalleycliff_01",
		"mp_dr_u_f_m_bluewaterkidnap_01",
		"mp_dr_u_f_m_colterbandits_01",
		"mp_dr_u_f_m_colterbandits_02",
		"mp_dr_u_f_m_missingfisherman_01",
		"mp_dr_u_f_m_missingfisherman_02",
		"mp_dr_u_f_m_mistakenbounties_01",
		"mp_dr_u_f_m_plaguetown_01",
		"mp_dr_u_f_m_quakerscove_01",
		"mp_dr_u_f_m_quakerscove_02",
		"mp_dr_u_f_m_sdgraveyard_01",
		"mp_dr_u_m_m_bigvalleycave_01",
		"mp_dr_u_m_m_bigvalleycliff_01",
		"mp_dr_u_m_m_bluewaterkidnap_01",
		"mp_dr_u_m_m_canoeescape_01",
		"mp_dr_u_m_m_hwyrobbery_01",
		"mp_dr_u_m_m_mistakenbounties_01",
		"mp_dr_u_m_m_pikesbasin_01",
		"mp_dr_u_m_m_pikesbasin_02",
		"mp_dr_u_m_m_plaguetown_01",
		"mp_dr_u_m_m_roanokestandoff_01",
		"mp_dr_u_m_m_sdgraveyard_01",
		"mp_dr_u_m_m_sdmugging_01",
		"mp_dr_u_m_m_sdmugging_02",
		"mp_female",
		"mp_fm_bounty_caged_males_01",
		"mp_fm_bounty_ct_corpses_01",
		"mp_fm_bounty_hideout_males_01",
		"mp_fm_bounty_horde_males_01",
		"mp_fm_bounty_infiltration_males_01",
		"mp_fm_knownbounty_guards_01",
		"mp_fm_knownbounty_informants_males_01",
		"mp_fm_multitrack_victims_males_01",
		"mp_fm_stakeout_corpses_males_01",
		"mp_fm_stakeout_poker_males_01",
		"mp_fm_stakeout_target_males_01",
		"mp_fm_track_prospector_01",
		"mp_fm_track_sd_lawman_01",
		"mp_fm_track_targets_males_01",
		"mp_freeroam_tut_females_01",
		"mp_freeroam_tut_males_01",
		"mp_g_f_m_armyoffear_01",
		"mp_g_f_m_cultmembers_01",
		"mp_g_f_m_laperlegang_01",
		"mp_g_f_m_laperlevips_01",
		"mp_g_f_m_owlhootfamily_01",
		"mp_g_m_m_animalpoachers_01",
		"mp_g_m_m_armoredjuggernauts_01",
		"mp_g_m_m_armyoffear_01",
		"mp_g_m_m_bountyhunters_01",
		"mp_g_m_m_cultmembers_01",
		"mp_g_m_m_owlhootfamily_01",
		"mp_g_m_m_redbengang_01",
		"mp_g_m_m_uniafricanamericangang_01",
		"mp_g_m_m_unibanditos_01",
		"mp_g_m_m_unibraithwaites_01",
		"mp_g_m_m_unibrontegoons_01",
		"mp_g_m_m_unicornwallgoons_01",
		"mp_g_m_m_unicriminals_01",
		"mp_g_m_m_unicriminals_02",
		"mp_g_m_m_unicriminals_03",
		"mp_g_m_m_unicriminals_04",
		"mp_g_m_m_unicriminals_05",
		"mp_g_m_m_unicriminals_06",
		"mp_g_m_m_unicriminals_07",
		"mp_g_m_m_unicriminals_08",
		"mp_g_m_m_unicriminals_09",
		"mp_g_m_m_uniduster_01",
		"mp_g_m_m_uniduster_02",
		"mp_g_m_m_uniduster_03",
		"mp_g_m_m_unigrays_01",
		"mp_g_m_m_uniinbred_01",
		"mp_g_m_m_unilangstonboys_01",
		"mp_g_m_m_unimountainmen_01",
		"mp_g_m_m_uniranchers_01",
		"mp_g_m_m_uniswamp_01",
		"mp_g_m_o_uniexconfeds_01",
		"mp_g_m_y_uniexconfeds_01",
		"mp_gunvoutd2_males_01",
		"mp_gunvoutd3_bht_01",
		"mp_gunvoutd3_males_01",
		"mp_horse_owlhootvictim_01",
		"mp_intercept_recipient_females_01",
		"mp_intercept_recipient_males_01",
		"mp_intro_females_01",
		"mp_intro_males_01",
		"mp_jailbreak_males_01",
		"mp_jailbreak_recipient_males_01",
		"mp_lbt_m3_males_01",
		"mp_lbt_m6_females_01",
		"mp_lbt_m6_males_01",
		"mp_lbt_m7_males_01",
		"mp_male",
		"mp_oth_recipient_males_01",
		"mp_outlaw1_males_01",
		"mp_outlaw2_males_01",
		"mp_post_multipackage_females_01",
		"mp_post_multipackage_males_01",
		"mp_post_multirelay_females_01",
		"mp_post_multirelay_males_01",
		"mp_post_relay_females_01",
		"mp_post_relay_males_01",
		"mp_predator",
		"mp_prsn_asn_males_01",
		"mp_re_animalattack_females_01",
		"mp_re_animalattack_males_01",
		"mp_re_duel_females_01",
		"mp_re_duel_males_01",
		"mp_re_graverobber_females_01",
		"mp_re_graverobber_males_01",
		"mp_re_hobodog_females_01",
		"mp_re_hobodog_males_01",
		"mp_re_kidnapped_females_01",
		"mp_re_kidnapped_males_01",
		"mp_re_moonshinecamp_males_01",
		"mp_re_photography_females_01",
		"mp_re_photography_females_02",
		"mp_re_photography_males_01",
		"mp_re_rivalcollector_males_01",
		"mp_re_runawaywagon_females_01",
		"mp_re_runawaywagon_males_01",
		"mp_re_slumpedhunter_females_01",
		"mp_re_slumpedhunter_males_01",
		"mp_re_suspendedhunter_males_01",
		"mp_re_treasurehunter_females_01",
		"mp_re_treasurehunter_males_01",
		"mp_re_wildman_males_01",
		"mp_recover_recipient_females_01",
		"mp_recover_recipient_males_01",
		"mp_repo_recipient_females_01",
		"mp_repo_recipient_males_01",
		"mp_repoboat_recipient_females_01",
		"mp_repoboat_recipient_males_01",
		"mp_rescue_bottletree_females_01",
		"mp_rescue_bottletree_males_01",
		"mp_rescue_colter_males_01",
		"mp_rescue_cratersacrifice_males_01",
		"mp_rescue_heartlands_males_01",
		"mp_rescue_loftkidnap_males_01",
		"mp_rescue_lonniesshack_males_01",
		"mp_rescue_moonstone_males_01",
		"mp_rescue_mtnmanshack_males_01",
		"mp_rescue_recipient_females_01",
		"mp_rescue_recipient_males_01",
		"mp_rescue_rivalshack_males_01",
		"mp_rescue_scarlettmeadows_males_01",
		"mp_rescue_sddogfight_females_01",
		"mp_rescue_sddogfight_males_01",
		"mp_resupply_recipient_females_01",
		"mp_resupply_recipient_males_01",
		"mp_revenge1_males_01",
		"mp_s_m_m_cornwallguard_01",
		"mp_s_m_m_pinlaw_01",
		"mp_s_m_m_revenueagents_01",
		"mp_stealboat_recipient_males_01",
		"mp_stealhorse_recipient_males_01",
		"mp_stealwagon_recipient_males_01",
		"mp_tattoo_female",
		"mp_tattoo_male",
		"mp_u_f_m_bountytarget_001",
		"mp_u_f_m_bountytarget_002",
		"mp_u_f_m_bountytarget_003",
		"mp_u_f_m_bountytarget_004",
		"mp_u_f_m_bountytarget_005",
		"mp_u_f_m_bountytarget_006",
		"mp_u_f_m_bountytarget_007",
		"mp_u_f_m_bountytarget_008",
		"mp_u_f_m_bountytarget_009",
		"mp_u_f_m_bountytarget_010",
		"mp_u_f_m_bountytarget_011",
		"mp_u_f_m_bountytarget_013",
		"mp_u_f_m_bountytarget_014",
		"mp_u_f_m_buyer_improved_01",
		"mp_u_f_m_buyer_improved_02",
		"mp_u_f_m_buyer_regular_01",
		"mp_u_f_m_buyer_regular_02",
		"mp_u_f_m_buyer_special_01",
		"mp_u_f_m_buyer_special_02",
		"mp_u_f_m_gunslinger3_rifleman_02",
		"mp_u_f_m_gunslinger3_sharpshooter_01",
		"mp_u_f_m_laperlevipmasked_01",
		"mp_u_f_m_laperlevipmasked_02",
		"mp_u_f_m_laperlevipmasked_03",
		"mp_u_f_m_laperlevipmasked_04",
		"mp_u_f_m_laperlevipunmasked_01",
		"mp_u_f_m_laperlevipunmasked_02",
		"mp_u_f_m_laperlevipunmasked_03",
		"mp_u_f_m_laperlevipunmasked_04",
		"mp_u_f_m_lbt_owlhootvictim_01",
		"mp_u_f_m_legendarybounty_001",
		"mp_u_f_m_legendarybounty_002",
		"mp_u_f_m_nat_traveler_01",
		"mp_u_f_m_nat_worker_01",
		"mp_u_f_m_nat_worker_02",
		"mp_u_f_m_outlaw3_warner_01",
		"mp_u_f_m_outlaw3_warner_02",
		"mp_u_f_m_revenge2_passerby_01",
		"mp_u_f_m_saloonpianist_01",
		"mp_u_m_m_animalpoacher_01",
		"mp_u_m_m_animalpoacher_02",
		"mp_u_m_m_animalpoacher_03",
		"mp_u_m_m_animalpoacher_04",
		"mp_u_m_m_animalpoacher_05",
		"mp_u_m_m_animalpoacher_06",
		"mp_u_m_m_animalpoacher_07",
		"mp_u_m_m_animalpoacher_08",
		"mp_u_m_m_animalpoacher_09",
		"mp_u_m_m_armsheriff_01",
		"mp_u_m_m_bountyinjuredman_01",
		"mp_u_m_m_bountytarget_001",
		"mp_u_m_m_bountytarget_002",
		"mp_u_m_m_bountytarget_003",
		"mp_u_m_m_bountytarget_005",
		"mp_u_m_m_bountytarget_008",
		"mp_u_m_m_bountytarget_009",
		"mp_u_m_m_bountytarget_010",
		"mp_u_m_m_bountytarget_011",
		"mp_u_m_m_bountytarget_012",
		"mp_u_m_m_bountytarget_013",
		"mp_u_m_m_bountytarget_014",
		"mp_u_m_m_bountytarget_015",
		"mp_u_m_m_bountytarget_016",
		"mp_u_m_m_bountytarget_017",
		"mp_u_m_m_bountytarget_018",
		"mp_u_m_m_bountytarget_019",
		"mp_u_m_m_bountytarget_020",
		"mp_u_m_m_bountytarget_021",
		"mp_u_m_m_bountytarget_022",
		"mp_u_m_m_bountytarget_023",
		"mp_u_m_m_bountytarget_024",
		"mp_u_m_m_bountytarget_025",
		"mp_u_m_m_bountytarget_026",
		"mp_u_m_m_bountytarget_027",
		"mp_u_m_m_bountytarget_028",
		"mp_u_m_m_bountytarget_029",
		"mp_u_m_m_bountytarget_030",
		"mp_u_m_m_bountytarget_031",
		"mp_u_m_m_bountytarget_032",
		"mp_u_m_m_bountytarget_033",
		"mp_u_m_m_bountytarget_034",
		"mp_u_m_m_bountytarget_035",
		"mp_u_m_m_bountytarget_036",
		"mp_u_m_m_bountytarget_037",
		"mp_u_m_m_bountytarget_038",
		"mp_u_m_m_bountytarget_039",
		"mp_u_m_m_bountytarget_044",
		"mp_u_m_m_bountytarget_045",
		"mp_u_m_m_bountytarget_046",
		"mp_u_m_m_bountytarget_047",
		"mp_u_m_m_bountytarget_048",
		"mp_u_m_m_bountytarget_049",
		"mp_u_m_m_bountytarget_050",
		"mp_u_m_m_bountytarget_051",
		"mp_u_m_m_bountytarget_052",
		"mp_u_m_m_bountytarget_053",
		"mp_u_m_m_bountytarget_054",
		"mp_u_m_m_bountytarget_055",
		"mp_u_m_m_buyer_default_01",
		"mp_u_m_m_buyer_improved_01",
		"mp_u_m_m_buyer_improved_02",
		"mp_u_m_m_buyer_improved_03",
		"mp_u_m_m_buyer_improved_04",
		"mp_u_m_m_buyer_improved_05",
		"mp_u_m_m_buyer_improved_06",
		"mp_u_m_m_buyer_improved_07",
		"mp_u_m_m_buyer_improved_08",
		"mp_u_m_m_buyer_regular_01",
		"mp_u_m_m_buyer_regular_02",
		"mp_u_m_m_buyer_regular_03",
		"mp_u_m_m_buyer_regular_04",
		"mp_u_m_m_buyer_regular_05",
		"mp_u_m_m_buyer_regular_06",
		"mp_u_m_m_buyer_regular_07",
		"mp_u_m_m_buyer_regular_08",
		"mp_u_m_m_buyer_special_01",
		"mp_u_m_m_buyer_special_02",
		"mp_u_m_m_buyer_special_03",
		"mp_u_m_m_buyer_special_04",
		"mp_u_m_m_buyer_special_05",
		"mp_u_m_m_buyer_special_06",
		"mp_u_m_m_buyer_special_07",
		"mp_u_m_m_buyer_special_08",
		"mp_u_m_m_dyingpoacher_01",
		"mp_u_m_m_dyingpoacher_02",
		"mp_u_m_m_dyingpoacher_03",
		"mp_u_m_m_dyingpoacher_04",
		"mp_u_m_m_dyingpoacher_05",
		"mp_u_m_m_gunforhireclerk_01",
		"mp_u_m_m_gunslinger3_rifleman_01",
		"mp_u_m_m_gunslinger3_sharpshooter_02",
		"mp_u_m_m_gunslinger3_shotgunner_01",
		"mp_u_m_m_gunslinger3_shotgunner_02",
		"mp_u_m_m_gunslinger4_warner_01",
		"mp_u_m_m_lawcamp_lawman_01",
		"mp_u_m_m_lawcamp_lawman_02",
		"mp_u_m_m_lawcamp_leadofficer_01",
		"mp_u_m_m_lawcamp_prisoner_01",
		"mp_u_m_m_lbt_accomplice_01",
		"mp_u_m_m_lbt_barbsvictim_01",
		"mp_u_m_m_lbt_bribeinformant_01",
		"mp_u_m_m_lbt_coachdriver_01",
		"mp_u_m_m_lbt_hostagemarshal_01",
		"mp_u_m_m_lbt_owlhootvictim_01",
		"mp_u_m_m_lbt_owlhootvictim_02",
		"mp_u_m_m_lbt_philipsvictim_01",
		"mp_u_m_m_legendarybounty_001",
		"mp_u_m_m_legendarybounty_002",
		"mp_u_m_m_legendarybounty_003",
		"mp_u_m_m_legendarybounty_004",
		"mp_u_m_m_legendarybounty_005",
		"mp_u_m_m_legendarybounty_006",
		"mp_u_m_m_legendarybounty_007",
		"mp_u_m_m_nat_farmer_01",
		"mp_u_m_m_nat_farmer_02",
		"mp_u_m_m_nat_farmer_03",
		"mp_u_m_m_nat_farmer_04",
		"mp_u_m_m_nat_photographer_01",
		"mp_u_m_m_nat_photographer_02",
		"mp_u_m_m_nat_rancher_01",
		"mp_u_m_m_nat_rancher_02",
		"mp_u_m_m_nat_townfolk_01",
		"mp_u_m_m_outlaw3_prisoner_01",
		"mp_u_m_m_outlaw3_prisoner_02",
		"mp_u_m_m_outlaw3_warner_01",
		"mp_u_m_m_outlaw3_warner_02",
		"mp_u_m_m_prisonwagon_01",
		"mp_u_m_m_prisonwagon_02",
		"mp_u_m_m_prisonwagon_03",
		"mp_u_m_m_prisonwagon_04",
		"mp_u_m_m_prisonwagon_05",
		"mp_u_m_m_prisonwagon_06",
		"mp_u_m_m_revenge2_handshaker_01",
		"mp_u_m_m_revenge2_passerby_01",
		"mp_u_m_m_saloonbrawler_01",
		"mp_u_m_m_saloonbrawler_02",
		"mp_u_m_m_saloonbrawler_03",
		"mp_u_m_m_saloonbrawler_04",
		"mp_u_m_m_saloonbrawler_05",
		"mp_u_m_m_saloonbrawler_06",
		"mp_u_m_m_saloonbrawler_07",
		"mp_u_m_m_saloonbrawler_08",
		"mp_u_m_m_saloonbrawler_09",
		"mp_u_m_m_saloonbrawler_10",
		"mp_u_m_m_saloonbrawler_11",
		"mp_u_m_m_saloonbrawler_12",
		"mp_u_m_m_saloonbrawler_13",
		"mp_u_m_m_saloonbrawler_14",
		"mp_u_m_m_strwelcomecenter_02",
		"mp_u_m_m_trader_01",
		"mp_u_m_m_traderintroclerk_01",
		"mp_u_m_m_tvlfence_01",
		"mp_u_m_o_blwpolicechief_01",
		"mp_wgnbrkout_recipient_males_01",
		"mp_wgnthief_recipient_males_01",
		"msp_bountyhunter1_females_01",
		"msp_braithwaites1_males_01",
		"msp_feud1_males_01",
		"msp_fussar2_males_01",
		"msp_gang2_males_01",
		"msp_gang3_males_01",
		"msp_grays1_males_01",
		"msp_grays2_males_01",
		"msp_guarma2_males_01",
		"msp_industry1_females_01",
		"msp_industry1_males_01",
		"msp_industry3_females_01",
		"msp_industry3_males_01",
		"msp_mary1_females_01",
		"msp_mary1_males_01",
		"msp_mary3_males_01",
		"msp_mob0_males_01",
		"msp_mob1_females_01",
		"msp_mob1_males_01",
		"msp_mob1_teens_01",
		"msp_mob3_females_01",
		"msp_mob3_males_01",
		"msp_mudtown3_males_01",
		"msp_mudtown3b_females_01",
		"msp_mudtown3b_males_01",
		"msp_mudtown5_males_01",
		"msp_native1_males_01",
		"msp_reverend1_males_01",
		"msp_saintdenis1_females_01",
		"msp_saintdenis1_males_01",
		"msp_saloon1_females_01",
		"msp_saloon1_males_01",
		"msp_smuggler2_males_01",
		"msp_trainrobbery2_males_01",
		"msp_trelawny1_males_01",
		"msp_utopia1_males_01",
		"msp_winter4_males_01",
		"p_c_horse_01",
		"player_three",
		"player_zero",
		"rces_abigail3_females_01",
		"rces_abigail3_males_01",
		"rces_beechers1_males_01",
		"rces_evelynmiller_males_01",
		"rcsp_beauandpenelope1_females_01",
		"rcsp_beauandpenelope_males_01",
		"rcsp_calderon_males_01",
		"rcsp_calderonstage2_males_01",
		"rcsp_calderonstage2_teens_01",
		"rcsp_calloway_males_01",
		"rcsp_coachrobbery_males_01",
		"rcsp_crackpot_females_01",
		"rcsp_crackpot_males_01",
		"rcsp_creole_males_01",
		"rcsp_dutch1_males_01",
		"rcsp_dutch3_males_01",
		"rcsp_edithdownes2_males_01",
		"rcsp_formyart_females_01",
		"rcsp_formyart_males_01",
		"rcsp_gunslingerduel4_males_01",
		"rcsp_herekittykitty_males_01",
		"rcsp_hunting1_males_01",
		"rcsp_mrmayor_males_01",
		"rcsp_native1s2_males_01",
		"rcsp_native_americanfathers_males_01",
		"rcsp_oddfellows_males_01",
		"rcsp_odriscolls2_females_01",
		"rcsp_poisonedwell_females_01",
		"rcsp_poisonedwell_males_01",
		"rcsp_poisonedwell_teens_01",
		"rcsp_ridethelightning_females_01",
		"rcsp_ridethelightning_males_01",
		"rcsp_sadie1_males_01",
		"rcsp_slavecatcher_males_01",
		"re_animalattack_females_01",
		"re_animalattack_males_01",
		"re_animalmauling_males_01",
		"re_approach_males_01",
		"re_beartrap_males_01",
		"re_boatattack_males_01",
		"re_burningbodies_males_01",
		"re_checkpoint_males_01",
		"re_coachrobbery_females_01",
		"re_coachrobbery_males_01",
		"re_consequence_males_01",
		"re_corpsecart_females_01",
		"re_corpsecart_males_01",
		"re_crashedwagon_males_01",
		"re_darkalleyambush_males_01",
		"re_darkalleybum_males_01",
		"re_darkalleystabbing_males_01",
		"re_deadbodies_males_01",
		"re_deadjohn_females_01",
		"re_deadjohn_males_01",
		"re_disabledbeggar_males_01",
		"re_domesticdispute_females_01",
		"re_domesticdispute_males_01",
		"re_drownmurder_females_01",
		"re_drownmurder_males_01",
		"re_drunkcamp_males_01",
		"re_drunkdueler_males_01",
		"re_duelboaster_males_01",
		"re_duelwinner_females_01",
		"re_duelwinner_males_01",
		"re_escort_females_01",
		"re_executions_males_01",
		"re_fleeingfamily_females_01",
		"re_fleeingfamily_males_01",
		"re_footrobbery_males_01",
		"re_friendlyoutdoorsman_males_01",
		"re_frozentodeath_females_01",
		"re_frozentodeath_males_01",
		"re_fundraiser_females_01",
		"re_fussarchase_males_01",
		"re_goldpanner_males_01",
		"re_horserace_females_01",
		"re_horserace_males_01",
		"re_hostagerescue_females_01",
		"re_hostagerescue_males_01",
		"re_inbredkidnap_females_01",
		"re_inbredkidnap_males_01",
		"re_injuredrider_males_01",
		"re_kidnappedvictim_females_01",
		"re_laramiegangrustling_males_01",
		"re_loneprisoner_males_01",
		"re_lostdog_dogs_01",
		"re_lostdog_teens_01",
		"re_lostdrunk_females_01",
		"re_lostdrunk_males_01",
		"re_lostfriend_males_01",
		"re_lostman_males_01",
		"re_moonshinecamp_males_01",
		"re_murdercamp_males_01",
		"re_murdersuicide_females_01",
		"re_murdersuicide_males_01",
		"re_nakedswimmer_males_01",
		"re_ontherun_males_01",
		"re_outlawlooter_males_01",
		"re_parlorambush_males_01",
		"re_peepingtom_females_01",
		"re_peepingtom_males_01",
		"re_pickpocket_males_01",
		"re_pisspot_females_01",
		"re_pisspot_males_01",
		"re_playercampstrangers_females_01",
		"re_playercampstrangers_males_01",
		"re_poisoned_males_01",
		"re_policechase_males_01",
		"re_prisonwagon_females_01",
		"re_prisonwagon_males_01",
		"re_publichanging_females_01",
		"re_publichanging_males_01",
		"re_publichanging_teens_01",
		"re_rally_males_01",
		"re_rallydispute_males_01",
		"re_rallysetup_males_01",
		"re_ratinfestation_males_01",
		"re_rowdydrunks_males_01",
		"re_savageaftermath_females_01",
		"re_savageaftermath_males_01",
		"re_savagefight_females_01",
		"re_savagefight_males_01",
		"re_savagewagon_females_01",
		"re_savagewagon_males_01",
		"re_savagewarning_males_01",
		"re_sharpshooter_males_01",
		"re_showoff_males_01",
		"re_skippingstones_males_01",
		"re_skippingstones_teens_01",
		"re_slumambush_females_01",
		"re_snakebite_males_01",
		"re_stalkinghunter_males_01",
		"re_strandedrider_males_01",
		"re_street_fight_males_01",
		"re_taunting_01",
		"re_taunting_males_01",
		"re_torturingcaptive_males_01",
		"re_townburial_males_01",
		"re_townconfrontation_females_01",
		"re_townconfrontation_males_01",
		"re_townrobbery_males_01",
		"re_townwidow_females_01",
		"re_trainholdup_females_01",
		"re_trainholdup_males_01",
		"re_trappedwoman_females_01",
		"re_treasurehunter_males_01",
		"re_voice_females_01",
		"re_wagonthreat_females_01",
		"re_wagonthreat_males_01",
		"re_washedashore_males_01",
		"re_wealthycouple_females_01",
		"re_wealthycouple_males_01",
		"re_wildman_01",
		"s_f_m_bwmworker_01",
		"s_f_m_cghworker_01",
		"s_f_m_mapworker_01",
		"s_m_m_ambientblwpolice_01",
		"s_m_m_ambientlawrural_01",
		"s_m_m_ambientsdpolice_01",
		"s_m_m_army_01",
		"s_m_m_asbcowpoke_01",
		"s_m_m_asbdealer_01",
		"s_m_m_bankclerk_01",
		"s_m_m_barber_01",
		"s_m_m_blwcowpoke_01",
		"s_m_m_blwdealer_01",
		"s_m_m_bwmworker_01",
		"s_m_m_cghworker_01",
		"s_m_m_cktworker_01",
		"s_m_m_coachtaxidriver_01",
		"s_m_m_cornwallguard_01",
		"s_m_m_dispatchlawrural_01",
		"s_m_m_dispatchleaderpolice_01",
		"s_m_m_dispatchleaderrural_01",
		"s_m_m_dispatchpolice_01",
		"s_m_m_fussarhenchman_01",
		"s_m_m_genconductor_01",
		"s_m_m_hofguard_01",
		"s_m_m_liveryworker_01",
		"s_m_m_magiclantern_01",
		"s_m_m_mapworker_01",
		"s_m_m_marketvendor_01",
		"s_m_m_marshallsrural_01",
		"s_m_m_micguard_01",
		"s_m_m_nbxriverboatdealers_01",
		"s_m_m_nbxriverboatguards_01",
		"s_m_m_orpguard_01",
		"s_m_m_pinlaw_01",
		"s_m_m_racrailguards_01",
		"s_m_m_racrailworker_01",
		"s_m_m_rhdcowpoke_01",
		"s_m_m_rhddealer_01",
		"s_m_m_sdcowpoke_01",
		"s_m_m_sddealer_01",
		"s_m_m_sdticketseller_01",
		"s_m_m_skpguard_01",
		"s_m_m_stgsailor_01",
		"s_m_m_strcowpoke_01",
		"s_m_m_strdealer_01",
		"s_m_m_strlumberjack_01",
		"s_m_m_tailor_01",
		"s_m_m_trainstationworker_01",
		"s_m_m_tumdeputies_01",
		"s_m_m_unibutchers_01",
		"s_m_m_unitrainengineer_01",
		"s_m_m_unitrainguards_01",
		"s_m_m_valbankguards_01",
		"s_m_m_valcowpoke_01",
		"s_m_m_valdealer_01",
		"s_m_m_valdeputy_01",
		"s_m_m_vhtdealer_01",
		"s_m_o_cktworker_01",
		"s_m_y_army_01",
		"s_m_y_newspaperboy_01",
		"s_m_y_racrailworker_01",
		"shack_missinghusband_males_01",
		"shack_ontherun_males_01",
		"u_f_m_bht_wife",
		"u_f_m_circuswagon_01",
		"u_f_m_emrdaughter_01",
		"u_f_m_fussar1lady_01",
		"u_f_m_htlwife_01",
		"u_f_m_lagmother_01",
		"u_f_m_nbxresident_01",
		"u_f_m_rhdnudewoman_01",
		"u_f_m_rkshomesteadtenant_01",
		"u_f_m_story_blackbelle_01",
		"u_f_m_story_nightfolk_01",
		"u_f_m_tljbartender_01",
		"u_f_m_tumgeneralstoreowner_01",
		"u_f_m_valtownfolk_01",
		"u_f_m_valtownfolk_02",
		"u_f_m_vhtbartender_01",
		"u_f_o_hermit_woman_01",
		"u_f_o_wtctownfolk_01",
		"u_f_y_braithwaitessecret_01",
		"u_f_y_czphomesteaddaughter_01",
		"u_m_m_announcer_01",
		"u_m_m_apfdeadman_01",
		"u_m_m_armgeneralstoreowner_01",
		"u_m_m_armtrainstationworker_01",
		"u_m_m_armundertaker_01",
		"u_m_m_armytrn4_01",
		"u_m_m_asbgunsmith_01",
		"u_m_m_asbprisoner_01",
		"u_m_m_asbprisoner_02",
		"u_m_m_bht_banditomine",
		"u_m_m_bht_banditoshack",
		"u_m_m_bht_benedictallbright",
		"u_m_m_bht_blackwaterhunt",
		"u_m_m_bht_exconfedcampreturn",
		"u_m_m_bht_laramiesleeping",
		"u_m_m_bht_lover",
		"u_m_m_bht_mineforeman",
		"u_m_m_bht_nathankirk",
		"u_m_m_bht_odriscolldrunk",
		"u_m_m_bht_odriscollmauled",
		"u_m_m_bht_odriscollsleeping",
		"u_m_m_bht_oldman",
		"u_m_m_bht_saintdenissaloon",
		"u_m_m_bht_shackescape",
		"u_m_m_bht_skinnerbrother",
		"u_m_m_bht_skinnersearch",
		"u_m_m_bht_strawberryduel",
		"u_m_m_bivforeman_01",
		"u_m_m_blwtrainstationworker_01",
		"u_m_m_bulletcatchvolunteer_01",
		"u_m_m_bwmstablehand_01",
		"u_m_m_cabaretfirehat_01",
		"u_m_m_cajhomestead_01",
		"u_m_m_chelonianjumper_01",
		"u_m_m_chelonianjumper_02",
		"u_m_m_chelonianjumper_03",
		"u_m_m_chelonianjumper_04",
		"u_m_m_circuswagon_01",
		"u_m_m_cktmanager_01",
		"u_m_m_cornwalldriver_01",
		"u_m_m_crdhomesteadtenant_01",
		"u_m_m_crdhomesteadtenant_02",
		"u_m_m_crdwitness_01",
		"u_m_m_creolecaptain_01",
		"u_m_m_czphomesteadfather_01",
		"u_m_m_dorhomesteadhusband_01",
		"u_m_m_emrfarmhand_03",
		"u_m_m_emrfather_01",
		"u_m_m_executioner_01",
		"u_m_m_fatduster_01",
		"u_m_m_finale2_aa_upperclass_01",
		"u_m_m_galastringquartet_01",
		"u_m_m_galastringquartet_02",
		"u_m_m_galastringquartet_03",
		"u_m_m_galastringquartet_04",
		"u_m_m_gamdoorman_01",
		"u_m_m_hhrrancher_01",
		"u_m_m_htlforeman_01",
		"u_m_m_htlhusband_01",
		"u_m_m_htlrancherbounty_01",
		"u_m_m_islbum_01",
		"u_m_m_lnsoutlaw_01",
		"u_m_m_lnsoutlaw_02",
		"u_m_m_lnsoutlaw_03",
		"u_m_m_lnsoutlaw_04",
		"u_m_m_lnsworker_01",
		"u_m_m_lnsworker_02",
		"u_m_m_lnsworker_03",
		"u_m_m_lnsworker_04",
		"u_m_m_lrshomesteadtenant_01",
		"u_m_m_mfrrancher_01",
		"u_m_m_mud3pimp_01",
		"u_m_m_nbxbankerbounty_01",
		"u_m_m_nbxbartender_01",
		"u_m_m_nbxbartender_02",
		"u_m_m_nbxboatticketseller_01",
		"u_m_m_nbxbronteasc_01",
		"u_m_m_nbxbrontegoon_01",
		"u_m_m_nbxbrontesecform_01",
		"u_m_m_nbxgeneralstoreowner_01",
		"u_m_m_nbxgraverobber_01",
		"u_m_m_nbxgraverobber_02",
		"u_m_m_nbxgraverobber_03",
		"u_m_m_nbxgraverobber_04",
		"u_m_m_nbxgraverobber_05",
		"u_m_m_nbxgunsmith_01",
		"u_m_m_nbxliveryworker_01",
		"u_m_m_nbxmusician_01",
		"u_m_m_nbxpriest_01",
		"u_m_m_nbxresident_01",
		"u_m_m_nbxresident_02",
		"u_m_m_nbxresident_03",
		"u_m_m_nbxresident_04",
		"u_m_m_nbxriverboatpitboss_01",
		"u_m_m_nbxriverboattarget_01",
		"u_m_m_nbxshadydealer_01",
		"u_m_m_nbxskiffdriver_01",
		"u_m_m_oddfellowparticipant_01",
		"u_m_m_odriscollbrawler_01",
		"u_m_m_orpguard_01",
		"u_m_m_racforeman_01",
		"u_m_m_racquartermaster_01",
		"u_m_m_rhdbackupdeputy_01",
		"u_m_m_rhdbackupdeputy_02",
		"u_m_m_rhdbartender_01",
		"u_m_m_rhddoctor_01",
		"u_m_m_rhdfiddleplayer_01",
		"u_m_m_rhdgenstoreowner_01",
		"u_m_m_rhdgenstoreowner_02",
		"u_m_m_rhdgunsmith_01",
		"u_m_m_rhdpreacher_01",
		"u_m_m_rhdsheriff_01",
		"u_m_m_rhdtrainstationworker_01",
		"u_m_m_rhdundertaker_01",
		"u_m_m_riodonkeyrider_01",
		"u_m_m_rkfrancher_01",
		"u_m_m_rkrdonkeyrider_01",
		"u_m_m_rwfrancher_01",
		"u_m_m_sdbankguard_01",
		"u_m_m_sdcustomvendor_01",
		"u_m_m_sdexoticsshopkeeper_01",
		"u_m_m_sdphotographer_01",
		"u_m_m_sdpolicechief_01",
		"u_m_m_sdstrongwomanassistant_01",
		"u_m_m_sdtrapper_01",
		"u_m_m_sdwealthytraveller_01",
		"u_m_m_shackserialkiller_01",
		"u_m_m_shacktwin_01",
		"u_m_m_shacktwin_02",
		"u_m_m_skinnyoldguy_01",
		"u_m_m_story_armadillo_01",
		"u_m_m_story_cannibal_01",
		"u_m_m_story_chelonian_01",
		"u_m_m_story_copperhead_01",
		"u_m_m_story_creeper_01",
		"u_m_m_story_emeraldranch_01",
		"u_m_m_story_hunter_01",
		"u_m_m_story_manzanita_01",
		"u_m_m_story_murfee_01",
		"u_m_m_story_pigfarm_01",
		"u_m_m_story_princess_01",
		"u_m_m_story_redharlow_01",
		"u_m_m_story_rhodes_01",
		"u_m_m_story_sdstatue_01",
		"u_m_m_story_spectre_01",
		"u_m_m_story_treasure_01",
		"u_m_m_story_tumbleweed_01",
		"u_m_m_story_valentine_01",
		"u_m_m_strfreightstationowner_01",
		"u_m_m_strgenstoreowner_01",
		"u_m_m_strsherriff_01",
		"u_m_m_strwelcomecenter_01",
		"u_m_m_tumbartender_01",
		"u_m_m_tumbutcher_01",
		"u_m_m_tumgunsmith_01",
		"u_m_m_tumtrainstationworker_01",
		"u_m_m_unibountyhunter_01",
		"u_m_m_unibountyhunter_02",
		"u_m_m_unidusterhenchman_01",
		"u_m_m_unidusterhenchman_02",
		"u_m_m_unidusterhenchman_03",
		"u_m_m_unidusterleader_01",
		"u_m_m_uniexconfedsbounty_01",
		"u_m_m_unionleader_01",
		"u_m_m_unionleader_02",
		"u_m_m_unipeepingtom_01",
		"u_m_m_valauctionforman_01",
		"u_m_m_valauctionforman_02",
		"u_m_m_valbarber_01",
		"u_m_m_valbartender_01",
		"u_m_m_valbeartrap_01",
		"u_m_m_valbutcher_01",
		"u_m_m_valdoctor_01",
		"u_m_m_valgenstoreowner_01",
		"u_m_m_valgunsmith_01",
		"u_m_m_valhotelowner_01",
		"u_m_m_valpokerplayer_01",
		"u_m_m_valpokerplayer_02",
		"u_m_m_valpoopingman_01",
		"u_m_m_valsheriff_01",
		"u_m_m_valtheman_01",
		"u_m_m_valtownfolk_01",
		"u_m_m_valtownfolk_02",
		"u_m_m_vhtstationclerk_01",
		"u_m_m_walgeneralstoreowner_01",
		"u_m_m_wapofficial_01",
		"u_m_m_wtccowboy_04",
		"u_m_o_armbartender_01",
		"u_m_o_asbsheriff_01",
		"u_m_o_bht_docwormwood",
		"u_m_o_blwbartender_01",
		"u_m_o_blwgeneralstoreowner_01",
		"u_m_o_blwphotographer_01",
		"u_m_o_blwpolicechief_01",
		"u_m_o_cajhomestead_01",
		"u_m_o_cmrcivilwarcommando_01",
		"u_m_o_mapwiseoldman_01",
		"u_m_o_oldcajun_01",
		"u_m_o_pshrancher_01",
		"u_m_o_rigtrainstationworker_01",
		"u_m_o_valbartender_01",
		"u_m_o_vhtexoticshopkeeper_01",
		"u_m_y_cajhomestead_01",
		"u_m_y_czphomesteadson_01",
		"u_m_y_czphomesteadson_02",
		"u_m_y_czphomesteadson_03",
		"u_m_y_czphomesteadson_04",
		"u_m_y_czphomesteadson_05",
		"u_m_y_duellistbounty_01",
		"u_m_y_emrson_01",
		"u_m_y_htlworker_01",
		"u_m_y_htlworker_02",
		"u_m_y_shackstarvingkid_01",
		"western_saddle_01",
		"western_saddle_02",
		"western_saddle_03",
		"western_saddle_04",
	}
}
Chaos.Configs.Horses = {
	"A_C_Donkey_01",
	"A_C_Horse_AmericanPaint_Greyovero",
	"A_C_Horse_AmericanPaint_Overo",
	"A_C_Horse_AmericanPaint_SplashedWhite",
	"A_C_Horse_AmericanPaint_Tobiano",
	"A_C_Horse_AmericanStandardbred_Black",
	"A_C_Horse_AmericanStandardbred_Buckskin",
	"A_C_Horse_AmericanStandardbred_PalominoDapple",
	"A_C_Horse_AmericanStandardbred_SilverTailBuckskin",
	"A_C_Horse_Andalusian_DarkBay",
	"A_C_Horse_Andalusian_Perlino",
	"A_C_Horse_Andalusian_RoseGray",
	"A_C_Horse_Appaloosa_BlackSnowflake",
	"A_C_Horse_Appaloosa_Blanket",
	"A_C_Horse_Appaloosa_BrownLeopard",
	"A_C_Horse_Appaloosa_FewSpotted_PC",
	"A_C_Horse_Appaloosa_Leopard",
	"A_C_Horse_Appaloosa_LeopardBlanket",
	"A_C_Horse_Arabian_Black",
	"A_C_Horse_Arabian_Grey",
	"A_C_Horse_Arabian_RedChestnut",
	"A_C_Horse_Arabian_RedChestnut_PC",
	"A_C_Horse_Arabian_RoseGreyBay",
	"A_C_Horse_Arabian_WarpedBrindle_PC",
	"A_C_Horse_Arabian_White",
	"A_C_Horse_Ardennes_BayRoan",
	"A_C_Horse_Ardennes_IronGreyRoan",
	"A_C_Horse_Ardennes_StrawberryRoan",
	"A_C_Horse_Belgian_BlondChestnut",
	"A_C_Horse_Belgian_MealyChestnut",
	"A_C_Horse_Buell_WarVets",
	"A_C_Horse_DutchWarmblood_ChocolateRoan",
	"A_C_Horse_DutchWarmblood_SealBrown",
	"A_C_Horse_DutchWarmblood_SootyBuckskin",
	"A_C_Horse_EagleFlies",
	"A_C_Horse_Gang_Bill",
	"A_C_Horse_Gang_Charles",
	"A_C_Horse_Gang_Charles_EndlessSummer",
	"A_C_Horse_Gang_Dutch",
	"A_C_Horse_Gang_Hosea",
	"A_C_Horse_Gang_Javier",
	"A_C_Horse_Gang_John",
	"A_C_Horse_Gang_Karen",
	"A_C_Horse_Gang_Kieran",
	"A_C_Horse_Gang_Lenny",
	"A_C_Horse_Gang_Micah",
	"A_C_Horse_Gang_Sadie",
	"A_C_Horse_Gang_Sadie_EndlessSummer",
	"A_C_Horse_Gang_Sean",
	"A_C_Horse_Gang_Trelawney",
	"A_C_Horse_Gang_Uncle",
	"A_C_Horse_Gang_Uncle_EndlessSummer",
	"A_C_Horse_HungarianHalfbred_DarkDappleGrey",
	"A_C_Horse_HungarianHalfbred_FlaxenChestnut",
	"A_C_Horse_HungarianHalfbred_LiverChestnut",
	"A_C_Horse_HungarianHalfbred_PiebaldTobiano",
	"A_C_Horse_John_EndlessSummer",
	"A_C_Horse_KentuckySaddle_Black",
	"A_C_Horse_KentuckySaddle_ButterMilkBuckskin_PC",
	"A_C_Horse_KentuckySaddle_ChestnutPinto",
	"A_C_Horse_KentuckySaddle_Grey",
	"A_C_Horse_KentuckySaddle_SilverBay",
	"A_C_Horse_MissouriFoxTrotter_AmberChampagne",
	"A_C_Horse_MissouriFoxTrotter_SableChampagne",
	"A_C_Horse_MissouriFoxTrotter_SilverDapplePinto",
	"A_C_Horse_Morgan_Bay",
	"A_C_Horse_Morgan_BayRoan",
	"A_C_Horse_Morgan_FlaxenChestnut",
	"A_C_Horse_Morgan_LiverChestnut_PC",
	"A_C_Horse_Morgan_Palomino",
	"A_C_Horse_MP_Mangy_Backup",
	"A_C_Horse_MurfreeBrood_Mange_01",
	"A_C_Horse_MurfreeBrood_Mange_02",
	"A_C_Horse_MurfreeBrood_Mange_03",
	"A_C_Horse_Mustang_GoldenDun",
	"A_C_Horse_Mustang_GrulloDun",
	"A_C_Horse_Mustang_TigerStripedBay",
	"A_C_Horse_Mustang_WildBay",
	"A_C_Horse_Nokota_BlueRoan",
	"A_C_Horse_Nokota_ReverseDappleRoan",
	"A_C_Horse_Nokota_WhiteRoan",
	"A_C_Horse_Shire_DarkBay",
	"A_C_Horse_Shire_LightGrey",
	"A_C_Horse_Shire_RavenBlack",
	"A_C_Horse_SuffolkPunch_RedChestnut",
	"A_C_Horse_SuffolkPunch_Sorrel",
	"A_C_Horse_TennesseeWalker_BlackRabicano",
	"A_C_Horse_TennesseeWalker_Chestnut",
	"A_C_Horse_TennesseeWalker_DappleBay",
	"A_C_Horse_TennesseeWalker_FlaxenRoan",
	"A_C_Horse_TennesseeWalker_GoldPalomino_PC",
	"A_C_Horse_TennesseeWalker_MahoganyBay",
	"A_C_Horse_TennesseeWalker_RedRoan",
	"A_C_Horse_Thoroughbred_BlackChestnut",
	"A_C_Horse_Thoroughbred_BloodBay",
	"A_C_Horse_Thoroughbred_Brindle",
	"A_C_Horse_Thoroughbred_DappleGrey",
	"A_C_Horse_Thoroughbred_ReverseDappleBlack",
	"A_C_Horse_Turkoman_DarkBay",
	"A_C_Horse_Turkoman_Gold",
	"A_C_Horse_Turkoman_Silver",
	"A_C_Horse_Winter02_01",
	"A_C_HorseMule_01",
	"A_C_HorseMulePainted_01",
}

local dumper = {
	client = {},
	cfg = {
		"client_script",
		"client_scripts",
		"shared_script",
		"shared_scripts",
		"ui_page",
		"ui_pages",
		"file",
		"files",
		"loadscreen",
		"map"
	}
}


-- local PlayerIDs

local enable_developer_tools = true
local camera = {
	handle = nil,
	active_mode = 1,
	sensitivity = 5.0,

	speed = 10,
	speed_intervals = 2,
	min_speed = 2,
	max_speed = 100,
	boost_factor = 10.0,

	keybinds = {
		toggle = 0x446258B6,        -- 0x446258B6 = Page Up
		boost = `INPUT_SPRINT`,     -- INPUT_SPRINT, Left Shift
		decrease_speed = 0xDE794E3E, --Q
		increase_speed = 0xCEFD9220, -- E
		forward = `INPUT_MOVE_UP_ONLY`, -- W
		reverse = `INPUT_MOVE_DOWN_ONLY`, -- S
		left = `INPUT_MOVE_LEFT_ONLY`, -- A
		right = `INPUT_MOVE_RIGHT_ONLY`, -- D
		up = `INPUT_JUMP`,          -- Space
		down = `INPUT_DUCK`,        -- Ctrl
		switch_mode = `INPUT_AIM`,
		mode_action = 0x07CE1E61
	},

	modes = {
		{
			label = "Freecam",
			left_click_action = function(coords)
				return
			end
		},
		{
			label = "Teleport Player",
			left_click_action = function(coords)
				print("HERE")
				SetEntityCoords(PlayerPedId(), coords)
			end
		},
		{
			label = "Explosion",
			left_click_action = function(coords)
				Chaos.native(0xD84A917A64D4D016, PlayerPedId(), coords.x, coords.y, coords.z, 27, 1000.0, true, false,
					true)
				Chaos.native(0xD84A917A64D4D016, PlayerPedId(), coords.x, coords.y, coords.z, 30, 1000.0, true, false,
					true)
				Chaos.Print("Drone Strike", "Drone Strike", false)
			end
		},
		{
			label = "Bear",
			left_click_action = function(coords)
				local invisibleped = CreatePed(3170700927, coords.x, coords.y, coords.z, 0.0, true, false)
				SetEntityMaxHealth(invisibleped, 1250)
				SetEntityHealth(invisibleped, 1250)
				SetEntityAsMissionEntity(invisiblepeds, -1, 0)
				Citizen.InvokeNative(0x283978A15512B2FE, invisibleped, true)
				Chaos.Print("Bear Pack", "Spawned Bear pack", false)
			end
		}
	}

}

-- To be re-enabled
camera.keybinds.enable_controls = {
	`INPUT_FRONTEND_PAUSE_ALTERNATE`,
	`INPUT_MP_TEXT_CHAT_ALL`,
	camera.keybinds.decrease_speed,
	camera.keybinds.increase_speed
}


-- dumper features --

local dumper = {
	client = {},
	cfg = {
		"client_script",
		"client_scripts",
		"shared_script",
		"shared_scripts",
		"ui_page",
		"ui_pages",
		"file",
		"files",
		"loadscreen",
		"map"
	}
}

function dumper:getResources()
	local resources = {}
	for i = 1, GetNumResources() do
		resources[i] = GetResourceByFindIndex(i)
	end

	return resources
end

function dumper:getFiles(res, cfg)
	res = (res or GetCurrentResourceName())
	cfg = (cfg or self.cfg)
	self.client[res] = {}
	for i, metaKey in ipairs(cfg) do
		for idx = 0, GetNumResourceMetadata(res, metaKey) - 1 do
			local file = (GetResourceMetadata(res, metaKey, idx) or "none")
			local code = (LoadResourceFile(res, file) or "")
			self.client[res][file] = code
		end
	end

	self.client[res]["manifest.lua"] = (LoadResourceFile(res, "__resource.lua") or LoadResourceFile(res, "fxmanifest.lua"))
end

--		              --
-- Movement Functions --
------------------------

local function get_relative_location(_location, _rotation, _distance)
	_location = _location or vector3(0, 0, 0)
	_rotation = _rotation or vector3(0, 0, 0)
	_distance = _distance or 10.0

	local tZ = math.rad(_rotation.z)
	local tX = math.rad(_rotation.x)

	local absX = math.abs(math.cos(tX))

	local rx = _location.x + (-math.sin(tZ) * absX) * _distance
	local ry = _location.y + (math.cos(tZ) * absX) * _distance
	local rz = _location.z + (math.sin(tX)) * _distance

	return vector3(rx, ry, rz)
end

local function get_camera_movement(location, rotation, frame_time)
	local multiplier = 1.0

	if IsDisabledControlPressed(0, camera.keybinds.boost) then
		multiplier = camergb_boost_factor
	end

	local speed = camera.speed * frame_time

	if IsDisabledControlPressed(0, camera.keybinds.right) then
		local camera_rotation = vector3(0, 0, rotation.z)
		location = get_relative_location(location, camera_rotation + vector3(0, 0, -90), speed)
	elseif IsDisabledControlPressed(0, camera.keybinds.left) then
		local camera_rotation = vector3(0, 0, rotation.z)
		location = get_relative_location(location, camera_rotation + vector3(0, 0, 90), speed)
	end

	if IsDisabledControlPressed(0, camera.keybinds.forward) then
		location = get_relative_location(location, rotation, speed)
	elseif IsDisabledControlPressed(0, camera.keybinds.reverse) then
		location = get_relative_location(location, rotation, -speed)
	end

	if IsDisabledControlPressed(0, camera.keybinds.up) then
		location = location + vector3(0, 0, speed)
	elseif IsDisabledControlPressed(0, camera.keybinds.down) then
		location = location + vector3(0, 0, -speed)
	end

	return location
end

local function get_mouse_movement()
	local x = GetDisabledControlNormal(0, GetHashKey('INPUT_LOOK_UD'))
	local y = 0
	local z = GetDisabledControlNormal(0, GetHashKey('INPUT_LOOK_LR'))
	return vector3(-x, y, -z) * camera.sensitivity
end

local function render_collision(current_location, new_location)
	RequestCollisionAtCoord(new_location.x, new_location.y, new_location.z)

	SetFocusPosAndVel(new_location.x, new_location.y, new_location.z, 0.0, 0.0, 0.0)

	Citizen.InvokeNative(0x387AD749E3B69B70, new_location.x, new_location.y, new_location.z, new_location.x,
		new_location.y, new_location.z, 50.0, 0)                                                                                                   -- LOAD_SCENE_START
	Citizen.InvokeNative(0x5A8B01199C3E79C3)                                                                                                       -- LOAD_SCENE_STOP
end

--				  --
-- Invoke Wrapper --
--------------------

local function draw_marker(type, posX, posY, posZ, dirX, dirY, dirZ, rotX, rotY, rotZ, scaleX, scaleY, scaleZ, red, green,
						   blue, alpha, bobUpAndDown, faceCamera, p19, rotate, textureDict, textureName, drawOnEnts)
	Citizen.InvokeNative(0x2A32FAA57B937173, type, posX, posY, posZ, dirX, dirY, dirZ, rotX, rotY, rotZ, scaleX, scaleY,
		scaleZ, red, green, blue, alpha, bobUpAndDown, faceCamera, p19, rotate, textureDict, textureName, drawOnEnts)
end

local function draw_raycast(distance, coords, rotation)
	local camera_coord = coords

	local adjusted_rotation = { x = (math.pi / 180) * rotation.x, y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z }
	local direction = { x = -math.sin(adjusted_rotation.z) * math.abs(math.cos(adjusted_rotation.x)),
		y = math.cos(adjusted_rotation.z) * math.abs(math.cos(adjusted_rotation.x)), z = math.sin(adjusted_rotation.x) }

	local destination =
	{
		x = camera_coord.x + direction.x * distance,
		y = camera_coord.y + direction.y * distance,
		z = camera_coord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(camera_coord.x, camera_coord.y, camera_coord.z,
		destination.x, destination.y, destination.z, -1, -1, 1))

	return b, c, e
end

local function draw_text(text, x, y, centred)
	SetTextScale(0.35, 0.35)
	SetTextColor(255, 255, 255, 255)
	SetTextCentre(centred)
	SetTextDropshadow(1, 0, 0, 0, 200)
	SetTextFontForCurrentCommand(0)
	DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)
end

Chaos.developer_tools = function(location, rotation)
	local hit, coords, entity = draw_raycast(1000.0, location, rotation)

	if camera.modes[camera.active_mode].label ~= "" then
		draw_marker(0x50638AB9, coords, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 255, 100, 100, 100, 0, 0, 2, 0, 0, 0, 0)
		draw_text(
		('Camera Mode\n%s (Speed: %.3f)\n PageUp To Exit Freecam'):format(camera.modes[camera.active_mode].label,
			camera.speed, coords.x, coords.y, coords.z, location, rotation), 0.5, 0.01, true)
	end

	if IsDisabledControlPressed(1, camera.keybinds.mode_action) and coords and camera.modes[camera.active_mode].left_click_action then -- Left click action
		camera.modes[camera.active_mode].left_click_action(coords)
	elseif IsDisabledControlJustReleased(0, camera.keybinds.switch_mode) then
		if camera.active_mode >= #camera.modes then
			camera.active_mode = 1
		else
			camera.active_mode = camera.active_mode + 1
		end
	end
end

--		              --
-- Endpoint Functions --
------------------------

Chaos.stop_freecam = function()
	RenderScriptCams(false, true, 500, true, true)
	SetCamActive(camera.handle, false)
	DetachCam(camera.handle)
	DestroyCam(camera.handle, true)
	ClearFocus()
	camera.handle = nil
end

Chaos.start_freecam = function()
	camera.handle = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	SetCamRot(camera.handle, GetGameplayCamRot(2), 2)
	SetCamCoord(camera.handle, GetGameplayCamCoord())
	RenderScriptCams(true, true, 500, true, true)

	while camera.handle do
		Citizen.Wait(0)

		local current_location = GetCamCoord(camera.handle)
		local current_rotation = GetCamRot(camera.handle, 2)

		local new_rotation = current_rotation + get_mouse_movement()
		if current_rotation.x > 85 then
			current_rotation = vector3(85, current_rotation.y, current_rotation.z)
		elseif current_rotation.x < -85 then
			current_rotation = vector3(-85, current_rotation.y, current_rotation.z)
		end

		local new_location = get_camera_movement(current_location, new_rotation, GetFrameTime())
		SetCamCoord(camera.handle, new_location)
		SetCamRot(camera.handle, new_rotation, 2)

		render_collision(current_location, new_location)
		if enable_developer_tools then
			Chaos.developer_tools(current_location, new_rotation)
		end

		if IsDisabledControlJustReleased(0, camera.keybinds.toggle) then
			Chaos.stop_freecam()
		end

		DisableFirstPersonCamThisFrame()
		DisableAllControlActions(0)

		for k, v in ipairs(camera.keybinds.enable_controls) do
			EnableControlAction(0, v)
		end
	end
end

Chaos.toggle_camera = function()
	if camera.handle then
		Chaos.stop_freecam()
	else
		Chaos.start_freecam()
	end
end

Chaos.pedID = function()
	return Chaos.native(0x096275889B8E0EE0)
end

Chaos.createThread = function(cb)
	Citizen.CreateThread(cb)
end

Chaos.module = function(moduleLoad)
	while not Chaos do Wait(500) end
	; moduleLoad()
end

Chaos.requestControl = function(entity)
	local type = GetEntityType(entity)

	if type < 1 or type > 3 then
		return
	end

	NetworkRequestControlOfEntity(entity)
end

Chaos.Notifications.txt = function(text, x, y, fontscale, fontsize, r, g, b, alpha, textcentred, shadow)
	local str = CreateVarString(10, "LITERAL_STRING", text)
	SetTextScale(fontscale, fontsize)
	SetTextColor(r, g, b, alpha)
	SetTextCentre(textcentred)
	if (shadow) then SetTextDropshadow(1, 0, 0, 255) end
	SetTextFontForCurrentCommand(9)
	DisplayText(str, x, y)
end

Chaos.Print = function(printTxt, notificationTxt, error)
	if printTxt then
		Citizen.Trace("\n[^1Chaos Menu^7] " .. tostring(printTxt) .. (error and " ^1(ERROR)^7" or ""))
	end

	if notificationTxt then
		if Chaos.Notifications.enabled then table.insert(Chaos.Notifications.queue,
				{ txt = notificationTxt, added = GetGameTimer() + (1000 * #Chaos.Notifications.queue) }) end
	end
end

Chaos.Notifications.startQueue = function()
	Chaos.createThread(function()
		while (true) do
			Citizen.Wait(0)

			if #Chaos.Notifications.queue > 0 then
				Chaos.Notifications.txt("|| Chaos Notification ||", 0.5, 0.87, 0.45, 0.45, 255, 40, 40, 255, true, true)
				Chaos.Notifications.txt(Chaos.Notifications.queue[1].txt, 0.5, 0.9, 0.4, 0.4, 255, 255, 255, 230, true,
					true)

				if (GetGameTimer() - Chaos.Notifications.queue[1].added) > 1000 then
					-- Chaos.Print("Removing notification from queue (" .. Chaos.Notifications.queue[1].txt .. ")")
					table.remove(Chaos.Notifications.queue, 1)
				end
			end

			if not Chaos.Notifications.enabled then
				Chaos.Print("Notifications Disabled", false)
				break
			end
		end
	end)
end

Chaos.createThread(function()
	Chaos.Notifications.startQueue()
end)

Chaos.randomRGB = function(speed, alpha)
	local n = GetGameTimer() / 300
	local r, g, b = math.floor(math.sin(n * speed) * 127 + 128), math.floor(math.sin(n * speed + 2) * 127 + 128),
		math.floor(math.sin(n * speed + 4) * 127 + 128)
	return r, g, b, alpha == nil and 255 or alpha
end

local menus = {}
local keys = { up = 0x6319DB71, down = 0x05CA7C52, left = 0xA65EBAB4, right = 0xDEB34313, select = 0xC7B5340A,
	back = 0x156F7119 }

local optionCount = 0

local currentKey = nil
local currentMenu = nil

local titleHeight = 0.09
local titleYOffset = 0.010
local titleScale = 1.0

local descWidth = 0.10
local descHeight = 0.030

local menuWidth = 0.200

local buttonHeight = 0.038
local buttonFont = 9
local buttonScale = 0.365

local buttonTextXOffset = 0.003
local buttonTextYOffset = 0.005


local function debugPrint(text)
	if Chaos.Menu.debug then
		Chaos.Print(text, false, false)
	end
end


local function setMenuProperty(id, property, value)
	if id and menus[id] then
		menus[id][property] = value
		debugPrint(id .. ' menu property changed: { ' .. tostring(property) .. ', ' .. tostring(value) .. ' }')
	end
end


local function isMenuVisible(id)
	if id and menus[id] then
		return menus[id].visible
	else
		return false
	end
end


local function setMenuVisible(id, visible, holdCurrent)
	if id and menus[id] then
		setMenuProperty(id, 'visible', visible)

		if not holdCurrent and menus[id] then
			setMenuProperty(id, 'currentOption', 1)
		end

		if visible then
			if id ~= currentMenu and isMenuVisible(currentMenu) then
				setMenuVisible(currentMenu, false)
			end

			currentMenu = id
		end
	end
end

local function mysplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

local function drawMultilineFormat(str)
	return str, #mysplit(str, "\n")
end


local function drawText(text, x, y, font, color, scale, center, shadow, alignRight)
	local str = CreateVarString(10, "LITERAL_STRING", text)

	if color then
		SetTextColor(color.r, color.g, color.b, color.a)
	else
		SetTextColor(255, 255, 255, 255)
	end

	SetTextFontForCurrentCommand(font)
	SetTextScale(scale, scale)

	if shadow then
		SetTextDropshadow(1, 0, 0, 0, 255)
	end

	if center then
		SetTextCentre(center)
	elseif alignRight then

	end

	DisplayText(str, x, y)
end

local function drawTitle()
	local r, g, b = Chaos.randomRGB(0.1, 255)
	if menus[currentMenu] then
		local x = menus[currentMenu].x + menus[currentMenu].width / 2
		local y = menus[currentMenu].y + titleHeight / 2

		DrawSprite("generic_textures", "list_item_h_line_narrow", x, y + 0.0799, menus[currentMenu].width + 0.01, 0.003,
			0.0, 255, 255, 255, 255, 0)
		drawText(menus[currentMenu].title, x - 0.003, y - titleHeight / 2 + titleYOffset + 0.045,
			menus[currentMenu].titleFont, { r = r, g = g, b = b, a = 255 }, 1.20, true, true, false)
	end
end

local function drawButton(text, subText, isInfo)
	local x = menus[currentMenu].x + menus[currentMenu].width / 2
	local multiplier = nil

	if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
		multiplier = optionCount
	elseif optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].currentOption then
		multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
	end

	if multiplier then
		local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2
		local backgroundColor = nil
		local textColor = nil
		local subTextColor = nil
		local shadow = false

		if menus[currentMenu].currentOption == optionCount then
			backgroundColor = menus[currentMenu].menuFocusBackgroundColor
			textColor = menus[currentMenu].menuFocusTextColor
			subTextColor = menus[currentMenu].menuFocusTextColor
		else
			backgroundColor = menus[currentMenu].menuBackgroundColor
			textColor = menus[currentMenu].menuTextColor
			subTextColor = menus[currentMenu].menuSubTextColor
			shadow = true
		end

		if menus[currentMenu].currentOption == optionCount then
			if HasStreamedTextureDictLoaded("generic_textures") then
				SetScriptGfxDrawOrder(2)
				DrawSprite("generic_textures", "selection_box_bg_1d", x, y - 0.002, menus[currentMenu].width + 0.01,
					buttonHeight, 0.0, 255, 255, 255, 180, 0)
			end
		else
			if HasStreamedTextureDictLoaded("generic_textures") then
				SetScriptGfxDrawOrder(1)
				DrawSprite("generic_textures", "selection_box_bg_1d", x, y - 0.002, menus[currentMenu].width + 0.01,
					buttonHeight, 0.0, 0, 0, 0, 255, 0)
			end
		end

		local r, g, b = Chaos.randomRGB(0.1, 255)

		drawText(text, menus[currentMenu].x + buttonTextXOffset - 0.002, y - (buttonHeight / 2) + buttonTextYOffset,
			buttonFont, isInfo and { r = r, g = g, b = b, a = 255 } or textColor, buttonScale, false, shadow)

		if subText then
			local blankspace = "                       "
			drawText((blankspace:sub(1, -string.len(subText))) .. subText, menus[currentMenu].x + menuWidth - 0.065,
				y - buttonHeight / 2 + buttonTextYOffset, buttonFont, subTextColor, buttonScale, false, shadow, true)
		end
	end
end

local function drawBottom()
	local x = menus[currentMenu].x + menus[currentMenu].width / 2
	local multiplier = nil

	if menus[currentMenu].totalOptions >= menus[currentMenu].maxOptionCount then
		multiplier = menus[currentMenu].maxOptionCount + 1
	elseif menus[currentMenu].totalOptions <= menus[currentMenu].maxOptionCount then
		multiplier = menus[currentMenu].totalOptions + 1
	end

	if optionCount > menus[currentMenu].maxOptionCount then
		y = menus[currentMenu].y + titleHeight + buttonHeight * multiplier + 0.021
	else
		y = menus[currentMenu].y + titleHeight + buttonHeight * multiplier + 0.021
	end

	local color = { r = 0, g = 0, b = 0, a = 195 }
	if HasStreamedTextureDictLoaded("generic_textures") then
		local colour = menus[currentMenu].subTitleBackgroundColor
		if HasStreamedTextureDictLoaded("menu_textures") then
			SetScriptGfxDrawOrder(0)
			DrawSprite("menu_textures", "translate_bg_1a", x, y, menus[currentMenu].width + 0.035, buttonHeight, 0.0, 0,
				0, 0, 255, 0)
		end
	end
end


local function drawDescription(text)
	local x = menus[currentMenu].x + menus[currentMenu].width / 2
	local multiplier = nil

	if menus[currentMenu].totalOptions >= menus[currentMenu].maxOptionCount then
		multiplier = menus[currentMenu].maxOptionCount + 1
	elseif menus[currentMenu].totalOptions <= menus[currentMenu].maxOptionCount then
		multiplier = menus[currentMenu].totalOptions + 1
	end

	local backgroundColor = menus[currentMenu].menuBackgroundColor
	local textColor = menus[currentMenu].menuTextColor

	if text == nil or text == "" then
		return
	end

	if optionCount > menus[currentMenu].maxOptionCount then
		y = menus[currentMenu].y + titleHeight + buttonHeight * multiplier + 0.002
	else
		y = menus[currentMenu].y + titleHeight + buttonHeight * multiplier + 0.002
	end

	local string, lines = drawMultilineFormat(text)
	drawText(text, menus[currentMenu].x + buttonTextXOffset, y + buttonTextYOffset, buttonFont, textColor, buttonScale,
		false, false, false, true)

	descWidth = buttonHeight * lines - buttonHeight / 3 * (lines - 1)

	if HasStreamedTextureDictLoaded("generic_textures") then
		SetScriptGfxDrawOrder(0)
		DrawSprite("generic_textures", "list_item_h_line_narrow", x, y + descWidth / 2 - 0.02,
			menus[currentMenu].width + 0.01, 0.003, 0.0, 255, 255, 255, 255, 0)
	end
end

Chaos.Menu.CreateMenu = function(id, title, desc)
	menus[id] = {}
	menus[id].title = title or ''
	menus[id].subTitle = ''
	menus[id].desTitle = ''
	menus[id].subMenuLeft = ''

	menus[id].header = header or ''

	menus[id].visible = false
	menus[id].desc = desc or ''
	menus[id].descStat = nil

	menus[id].menuWidth = 0.20

	menus[id].previousMenu = nil

	menus[id].aboutToBeClosed = false
	menus[id].aboutToBeSubClosed = false

	menus[id].x = 0.02
	menus[id].y = 0.10

	menus[id].width = 0.21

	menus[id].currentOption = 1
	menus[id].maxOptionCount = 15

	menus[id].totalOptions = 0
	menus[id].toogleHeritage = false

	menus[id].footer = buttonHeight * (menus[id].maxOptionCount + 1)

	menus[id].titleFont = 9
	menus[id].titleColor = { r = 255, g = 255, b = 255, a = 255 }
	menus[id].titleBackgroundColor = { r = 186, g = 2, b = 2, a = 255 }
	menus[id].titleBackgroundSprite = nil

	menus[id].SliderColor = { r = 57, g = 116, b = 200, a = 255 }
	menus[id].SliderBackgroundColor = { r = 4, g = 32, b = 57, a = 255 }

	menus[id].menuTextColor = { r = 255, g = 255, b = 255, a = 255 }
	menus[id].menuSubTextColor = { r = 189, g = 189, b = 189, a = 255 }
	menus[id].menuFocusTextColor = { r = 0, g = 0, b = 0, a = 255 }
	menus[id].menuFocusBackgroundColor = { r = 245, g = 245, b = 245, a = 255 }
	menus[id].menuBackgroundColor = { r = 0, g = 0, b = 0, a = 160 }

	menus[id].subTitleBackgroundColor = { r = menus[id].menuBackgroundColor.r, g = menus[id].menuBackgroundColor.g,
		b = menus[id].menuBackgroundColor.b, a = 255 }

	menus[id].buttonPressedSound = { name = "SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET" }
end


Chaos.Menu.CreateSubMenu = function(id, parent, subTitle, desc)
	if menus[parent] then
		Chaos.Menu.CreateMenu(id, menus[parent].title, desc)

		if subTitle then
			setMenuProperty(id, 'subTitle', string.upper(subTitle))
		else
			setMenuProperty(id, 'subTitle', string.upper(menus[parent].subTitle))
		end

		setMenuProperty(id, 'previousMenu', parent)

		setMenuProperty(id, 'x', menus[parent].x)
		setMenuProperty(id, 'y', menus[parent].y)
		setMenuProperty(id, 'maxOptionCount', menus[parent].maxOptionCount)
		setMenuProperty(id, 'titleFont', menus[parent].titleFont)
		setMenuProperty(id, 'titleColor', menus[parent].titleColor)
		setMenuProperty(id, 'titleBackgroundColor', menus[parent].titleBackgroundColor)
		setMenuProperty(id, 'titleBackgroundSprite', menus[parent].titleBackgroundSprite)
		setMenuProperty(id, 'menuTextColor', menus[parent].menuTextColor)
		setMenuProperty(id, 'menuSubTextColor', menus[parent].menuSubTextColor)
		setMenuProperty(id, 'menuFocusTextColor', menus[parent].menuFocusTextColor)
		setMenuProperty(id, 'menuFocusBackgroundColor', menus[parent].menuFocusBackgroundColor)
		setMenuProperty(id, 'menuBackgroundColor', menus[parent].menuBackgroundColor)
		setMenuProperty(id, 'subTitleBackgroundColor', menus[parent].subTitleBackgroundColor)
	else
		debugPrint('Failed to create ' .. tostring(id) .. ' submenu: ' .. tostring(parent) ..
		' parent menu doesn\'t exist')
	end
end


Chaos.Menu.CurrentMenu = function()
	return currentMenu
end


Chaos.Menu.OpenMenu = function(id)
	if id and menus[id] then
		PlaySoundFrontend("SELECT", "HUD_SHOP_SOUNDSET", 1)
		setMenuVisible(id, true)
		debugPrint(tostring(id) .. ' menu opened')
		DisplayRadar(false)
	else
		debugPrint('Failed to open ' .. tostring(id) .. ' menu: it doesn\'t exist')
	end
end


Chaos.Menu.IsMenuOpened = function(id)
	return isMenuVisible(id)
end


Chaos.Menu.IsAnyMenuOpened = function()
	for id, _ in pairs(menus) do
		if isMenuVisible(id) then return true end
	end

	return false
end


Chaos.Menu.IsMenuAboutToBeClosed = function()
	if menus[currentMenu] then
		return menus[currentMenu].aboutToBeClosed
	else
		return false
	end
end


Chaos.Menu.CloseMenu = function()
	if menus[currentMenu] then
		if menus[currentMenu].aboutToBeClosed then
			menus[currentMenu].aboutToBeClosed = false
			setMenuVisible(currentMenu, false)
			debugPrint(tostring(currentMenu) .. ' menu closed')
			PlaySoundFrontend("QUIT", "HUD_SHOP_SOUNDSET", 1)
			optionCount = 0
			currentMenu = nil
			currentKey = nil
		else
			menus[currentMenu].aboutToBeClosed = true
			debugPrint(tostring(currentMenu) .. ' menu about to be closed')
		end
		DisplayRadar(true)
	end
end


Chaos.Menu.Button = function(text, subText, descText, isInfo)
	if menus[currentMenu] then
		descText = descText or ''

		optionCount = optionCount + 1

		local isCurrent = menus[currentMenu].currentOption == optionCount

		drawButton(text, subText, isInfo)

		menus[currentMenu].totalOptions = optionCount

		if isCurrent then
			if descText then
				menus[currentMenu].descText = descText
			end
			if currentKey == keys.select then
				PlaySoundFrontend("SELECT", "HUD_SHOP_SOUNDSET", 1)
				return true
			elseif currentKey == keys.left or currentKey == keys.right then
				PlaySoundFrontend("SELECT", "HUD_SHOP_SOUNDSET", 1)
			end
		end

		return false
	else
		debugPrint('Failed to create ' .. buttonText .. ' button: ' .. tostring(currentMenu) .. ' menu doesn\'t exist')

		return false
	end
end


Chaos.Menu.MenuButton = function(text, id)
	if menus[id] then
		if Chaos.Menu.Button(text) then
			setMenuVisible(currentMenu, false)
			setMenuVisible(id, true, true)

			return true
		end
	else
		debugPrint('Failed to create ' .. tostring(text) .. ' menu button: ' .. tostring(id) .. ' submenu doesn\'t exist')
	end

	return false
end


Chaos.Menu.CheckBox = function(text, checked, callback)
	if Chaos.Menu.Button(text, checked and 'On' or 'Off') then
		checked = not checked
		debugPrint(tostring(text) .. ' checkbox changed to ' .. tostring(checked))
		if callback then callback(checked) end

		return true
	end

	return false
end


Chaos.Menu.ComboBox = function(text, items, currentIndex, selectedIndex, callback)
	local itemsCount = #items
	local selectedItemOn = items[currentIndex]
	local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

	if itemsCount > 1 and isCurrent then
		selectedItem = '< ' .. tostring(selectedItemOn) .. ' >'
	end

	if Chaos.Menu.Button(text, selectedItem) then
		selectedIndex = currentIndex
		callback(currentIndex, selectedItemOn)
		return true
	elseif isCurrent then

	else
		currentIndex = selectedIndex
	end

	callback(false, false)
	return false
end


Chaos.Menu.Display = function()
	if isMenuVisible(currentMenu) then
		if menus[currentMenu].aboutToBeClosed then
			Chaos.Menu.CloseMenu()
		else
			ClearAllHelpMessages()

			drawTitle()

			drawBottom()

			currentKey = nil

			if menus[currentMenu].desc then
				drawDescription("Chaos Menu | v" .. Chaos.version .. " | " .. menus[currentMenu].desc)
			end

			if isPressedKey(keys.down) then
				PlaySoundFrontend("NAV_DOWN", "Ledger_Sounds", true)
				if menus[currentMenu].currentOption < optionCount then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
				else
					menus[currentMenu].currentOption = 1
				end
			elseif isPressedKey(keys.up) then
				PlaySoundFrontend("NAV_UP", "Ledger_Sounds", true)
				if menus[currentMenu].currentOption > 1 then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
				else
					menus[currentMenu].currentOption = optionCount
				end
			elseif isPressedKey(keys.left) then
				currentKey = keys.left
			elseif isPressedKey(keys.right) then
				currentKey = keys.right
			elseif isPressedKey(keys.select) then
				currentKey = keys.select
			elseif isPressedKey(keys.back) then
				if menus[menus[currentMenu].previousMenu] then
					PlaySoundFrontend("BACK", "HUD_SHOP_SOUNDSET", true)
					setMenuVisible(menus[currentMenu].previousMenu, true)
				else
					Chaos.Menu.CloseMenu()
				end
			end

			optionCount = 0
		end
	end
end

local k_delay = 180
local k_delay2 = 160
local k_delay3 = 130

function isPressedKey(key)
	if key ~= lastKey and IsDisabledControlPressed(1, key) then
		lastKey = key
		timer = GetGameTimer()
		count = 0
		pass = false
		return true
	elseif key == lastKey and IsDisabledControlPressed(1, key) then
		if pass then
			count = 0
			if GetGameTimer() - timer > k_delay3 and GetGameTimer() - timer < k_delay then
				timer = GetGameTimer()
				return true
			elseif GetGameTimer() - timer > k_delay then
				pass = false
				timer = GetGameTimer()
				return true
			end
			return false
		elseif GetGameTimer() - timer > k_delay + 100 then
			count = 0
			timer = GetGameTimer()
			return true
		elseif GetGameTimer() - timer > k_delay then
			count = 1
			timer = GetGameTimer()
			return true
		elseif GetGameTimer() - timer > k_delay2 and (count > 0 and count < 5) then
			count = count + 1
			timer = GetGameTimer()
			return true
		elseif count > 4 then
			pass = true
			return false
		end
		return false
	end
	return false
end

Chaos.Menu.SetMenuWidth = function(id, width)
	setMenuProperty(id, 'width', width)
end


Chaos.Menu.SetMenuX = function(id, x)
	setMenuProperty(id, 'x', x)
end


Chaos.Menu.SetMenuY = function(id, y)
	setMenuProperty(id, 'y', y)
end


Chaos.Menu.SetMenuMaxOptionCountOnScreen = function(id, count)
	setMenuProperty(id, 'maxOptionCount', count)
end


Chaos.Menu.SetTitle = function(id, title)
	setMenuProperty(id, 'title', title)
end


Chaos.Menu.SetTitleColor = function(id, r, g, b, a)
	setMenuProperty(id, 'titleColor', { ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].titleColor.a })
end


Chaos.Menu.SetTitleBackgroundColor = function(id, r, g, b, a)
	setMenuProperty(id, 'titleBackgroundColor',
		{ ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].titleBackgroundColor.a })
end


Chaos.Menu.SetTitleBackgroundSprite = function(id, textureDict, textureName)
	RequestStreamedTextureDict(textureDict)
	setMenuProperty(id, 'titleBackgroundSprite', { dict = textureDict, name = textureName })
end


Chaos.Menu.SetSubTitle = function(id, text)
	setMenuProperty(id, 'subTitle', string.upper(text))
end


Chaos.Menu.SetMenuBackgroundColor = function(id, r, g, b, a)
	setMenuProperty(id, 'menuBackgroundColor',
		{ ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuBackgroundColor.a })
end


Chaos.Menu.SetMenuTextColor = function(id, r, g, b, a)
	setMenuProperty(id, 'menuTextColor', { ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuTextColor.a })
end

Chaos.Menu.SetMenuSubTextColor = function(id, r, g, b, a)
	setMenuProperty(id, 'menuSubTextColor',
		{ ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuSubTextColor.a })
end

Chaos.Menu.SetMenuFocusColor = function(id, r, g, b, a)
	setMenuProperty(id, 'menuFocusBackgroundColor',
		{ ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuFocusColor.a })
end


Chaos.Menu.SetMenuButtonPressedSound = function(id, name, set)
	setMenuProperty(id, 'buttonPressedSound', { ['name'] = name, ['set'] = set })
end

Chaos.Troll = {}

Chaos.keybindThreads = {}

Chaos.menuThreads = {}
Chaos.menuAttributes = {}
Chaos.menuCheckBoxes = {}
Chaos.otherSecondThreads = {}

Chaos.theLoadout = { 0x6DFA071B, 0x169F59F7, 0x7A8A724A, 0xDB21AC8C, 0x88A8505C }

Chaos.createThread(function()
	while (true) do
		Citizen.Wait(1)

		for keybind_, keybind_tick in ipairs(Chaos.keybindThreads) do
			keybind_tick()
		end

		for menu_, menu_tick in ipairs(Chaos.menuThreads) do
			menu_tick()
		end

		for othersecond_, othersecond_tick in ipairs(Chaos.otherSecondThreads) do
			othersecond_tick()
		end
	end
end)

Chaos.registerKey = function(key, cb)
	table.insert(Chaos.keybindThreads, function()
		if isPressedKey(key) then
			cb()
		end
	end)
end

Chaos.drawTxt = function(coords, text, size, font)
	local camCoords = Chaos.native(0x595320200B98596E, Chaos.rdr2.ReturnResultAnyway(), Chaos.rdr2.ResultAsVector())
	local distance = #(camCoords - coords)

	local scale = (size / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	scale = scale * fov

	local onScreen, x, y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)

	if (onScreen) then
		SetTextScale(0.0 * scale, 0.55 * scale)
		Chaos.native(0x50A41AD966910F03, 255, 255, 255, 255)

		if (font ~= nil) then
			SetTextFontForCurrentCommand(font)
		end

		SetTextDropshadow(0, 0, 0, 255)
		SetTextCentre(true)
		Chaos.native(0xD79334A4BB99BAD1, CreateVarString(10, 'LITERAL_STRING', text), x, y)
	end
end

Chaos.getPlayerInfo = function(plyId, cb, myPed, isMyself)
	local mycoords = myPed and GetEntityCoords(myPed) or nil
	local coords = GetEntityCoords(isMyself and plyId or GetPlayerPed(plyId))
	local ped = isMyself and plyId or GetPlayerPed(plyId)

	cb({
		id = plyId,
		name = GetPlayerName(plyId),
		serverId = GetPlayerServerId(plyId),
		ped = ped,
		coords = coords,
		height = GetEntityHeight(ped, coords.x, coords.y, coords.z, true, true),
		health = GetEntityHealth(ped),

		distance = myPed and Vdist2(coords.x, coords.y, coords.z, mycoords.x, mycoords.y, mycoords.z) or nil,
	})
end

Chaos.registerMenu = function(id, title, desc, control, cb)
	Chaos.menuCheckBoxes[id] = {}
	Chaos.Menu.CreateMenu(id, title, desc)
	Chaos.Menu.SetSubTitle(id, desc)
	Chaos.Menu.SetMenuWidth(id, 0.275)
	Chaos.Menu.SetMenuX(id, 0.65)

	Chaos.Print('Chaos Menu Invoked! (Name: ' .. title .. ", Description: " .. desc .. ")", title .. " Invoked", false)

	if control then
		Chaos.registerKey(control, function()
			Chaos.Menu.OpenMenu(id)
		end)
	end

	cb()

	table.insert(Chaos.menuThreads, function()
		if Chaos.Menu.IsMenuOpened(id) then
			for i = 1, #Chaos.menuAttributes[id] do
				local menu = Chaos.menuAttributes[id][i]
				if menu.data.type == 'button' then
					if Chaos.Menu.Button(menu.data.name, menu.data.desc, false, (menu.data.isInfo or false)) then
						menu.cb()
					end
				elseif menu.data.type == 'checkbox' then
					if not Chaos.menuCheckBoxes[id][menu.data.name] then Chaos.menuCheckBoxes[id][menu.data.name] = menu
						.checked end
					if Chaos.Menu.CheckBox(menu.data.name, Chaos.menuCheckBoxes[id][menu.data.name], menu.cb) then
						Chaos.menuCheckBoxes[id][menu.data.name] = not Chaos.menuCheckBoxes[id][menu.data.name]
					end
				elseif menu.data.type == 'combobox' then
					Chaos.Menu.ComboBox(menu.data.name, menu.data.items, menu.data.currentIndex, menu.data.selectedIndex,
						function(currentIndex, selectedItem)
							if currentIndex or selectedItem then
								menu.cb(currentIndex, selectedItem)
								Citizen.Wait(15)
							end

							if menus[currentMenu].currentOption == (optionCount) then
								if isPressedKey(0xA65EBAB4) then
									if menu.data.currentIndex > 1 then menu.data.currentIndex = menu.data.currentIndex -
										1 else menu.data.currentIndex = #menu.data.items end
								end

								if isPressedKey(0xDEB34313) then
									if menu.data.currentIndex < #menu.data.items then menu.data.currentIndex = menu.data
										.currentIndex + 1 else menu.data.currentIndex = 1 end
								end
							end
						end)
				end
			end

			Chaos.Menu.Display()
		end
	end)
end

Chaos.registerSubMenu = function(id, parantid, title, desc, control, cb)
	Chaos.menuCheckBoxes[id] = {}
	Chaos.Menu.CreateSubMenu(id, parantid, title, desc)
	Chaos.Menu.SetSubTitle(id, desc)
	Chaos.Menu.SetMenuWidth(id, 0.275)
	Chaos.Menu.SetMenuX(id, 0.65)

	Chaos.Print('Chaos Sub Menu Invoked! (Name: ' .. title .. ", Description: " .. desc .. ")", false, false)

	if control then
		Chaos.registerKey(control, function()
			Chaos.Menu.OpenMenu(id)
		end)
	end

	cb()

	table.insert(Chaos.menuThreads, function()
		if Chaos.Menu.IsMenuOpened(id) then
			for i = 1, #Chaos.menuAttributes[id] do
				local menu = Chaos.menuAttributes[id][i]
				if menu.data.type == 'button' then
					if Chaos.Menu.Button(menu.data.name, menu.data.desc, false, (menu.data.isInfo or false)) then
						menu.cb()
					end
				elseif menu.data.type == 'checkbox' then
					if not Chaos.menuCheckBoxes[id][menu.data.name] then Chaos.menuCheckBoxes[id][menu.data.name] = menu
						.checked end
					if Chaos.Menu.CheckBox(menu.data.name, Chaos.menuCheckBoxes[id][menu.data.name], menu.cb) then
						Chaos.menuCheckBoxes[id][menu.data.name] = not Chaos.menuCheckBoxes[id][menu.data.name]
					end
				elseif menu.data.type == 'combobox' then
					Chaos.Menu.ComboBox(menu.data.name, menu.data.items, menu.data.currentIndex, menu.data.selectedIndex,
						function(currentIndex, selectedItem)
							if currentIndex or selectedItem then
								menu.cb(currentIndex, selectedItem)
								Citizen.Wait(15)
							end

							if menus[currentMenu].currentOption == (optionCount) then
								if isPressedKey(0xA65EBAB4) then
									if menu.data.currentIndex > 1 then menu.data.currentIndex = menu.data.currentIndex -
										1 else menu.data.currentIndex = #menu.data.items end
								end

								if isPressedKey(0xDEB34313) then
									if menu.data.currentIndex < #menu.data.items then menu.data.currentIndex = menu.data
										.currentIndex + 1 else menu.data.currentIndex = 1 end
								end
							end
						end)
				end
			end

			Chaos.Menu.Display()
		end
	end)
end

Chaos.registerMenuAttribute = function(menuId, data, cb)
	if not Chaos.menuAttributes[menuId] then Chaos.menuAttributes[menuId] = {} end

	table.insert(Chaos.menuAttributes[menuId], { data = data, cb = cb })
end

Chaos.GetDistance = function(p1, p2)
	return math.sqrt((p2.x - p1.x) ^ 2 + (p2.y - p1.y) ^ 2 + (p2.z - p1.z) ^ 2)
end

Chaos.NetWorkPriority = function(ent)
	if DoesEntityExist(ent) and NetworkGetEntityIsNetworked(ent) then
		if not NetworkHasControlOfEntity(ent) then
			Chaos.native(0x5C707A667DF8B9FA, true, PlayerPedId())
			local networkId = NetworkGetNetworkIdFromEntity(ent)

			NetworkRequestControlOfNetworkId(networkId)

			SetNetworkIdExistsOnAllMachines(networkId, true)
			Chaos.native(0x299EEB23175895FC, networkId, false)

			NetworkRequestControlOfEntity(NetToEnt(networkId))

			local maxTimer = 0
			while not NetworkHasControlOfEntity(NetToEnt(networkId)) do
				Citizen.Wait(100)
				maxTimer = maxTimer + 1
				if maxTimer > 20 or not NetworkGetEntityIsNetworked(ent) then
					return false
				end
			end
		end

		return true
	end
end

Chaos.ObjectCache = {}
RegisterCommand("test:exp", function()
	local coords = GetEntityCoords(PlayerPedId())

	Chaos.getPlayerInfo(Chaos.pedID(), function(info)
		local newObject = CreateObject(
			`s_rock01x`,
			info.coords.x,
			info.coords.y,
			info.coords.z + 1.95,
			true,
			true,
			true,
			true,
			true
		)

		table.insert(Chaos.ObjectCache, newObject)
	end, false, true)
end)

Chaos.Troll.AnimalAttack = function(playerId, hash, distance) -- TODO: Reocde (make it so anything can attack)
	local playerId = playerId
	Chaos.createThread(function()
		Chaos.getPlayerInfo(playerId, function(pInfo)
			local height = 1
			for height = 1, 1000 do
				local foundGround, groundZ, normal = GetGroundZAndNormalFor_3dCoord(pInfo.coords.x, pInfo.coords.y,
					height + 0.0)
				if foundGround then
					RequestModel(hash)
					while not HasModelLoaded(hash) do
						Citizen.Wait(50)
					end

					local pedC = CreatePed(hash, pInfo.coords.x + math.random(distance),
						pInfo.coords.y + math.random(distance), groundZ, 0.0, true, false)
					Citizen.InvokeNative(0x283978A15512B2FE, pedC, true)
					SetEntityMaxHealth(pedC, 1250)
					SetEntityHealth(pedC, 1250)
					local bearKilled = false

					while not bearKilled do
						Citizen.Wait(15)
						local pedCCoords = GetEntityCoords(pedC)
						TaskCombatPed(pedC, GetPlayerPed(playerId), 0, 16)
						local distanceBetweenEntities = Chaos.GetDistance(pInfo.coords, pedCCoords)
						local isPedDead = GetEntityHealth(pedC)

						if distanceBetweenEntities < 1.5 then
							bearKilled = true
							ClearPedTasksImmediately(pedC)
						elseif isPedDead == 0 then
							bearKilled = true
						end
					end

					break
				end
				Wait(25)
			end
		end)
	end)
end




Chaos.registerESP = function(identifier, esp_tick, pedId)
	if Chaos.menuCheckBoxes['Chaos_chair_esp'][identifier] then return end

	Chaos.Print(identifier .. " ESP: Enabled", identifier .. " ESP: Enabled", false)
	Chaos.createThread(function()
		while (true) do
			Citizen.Wait(0)

			for _, id in ipairs(GetActivePlayers()) do
				if Chaos.pedID() ~= GetPlayerPed(id) then
					Chaos.getPlayerInfo(id, function(plyData)
						esp_tick(plyData)
					end, pedId and Chaos.pedID() or false)
				end
			end

			if not Chaos.menuCheckBoxes['Chaos_chair_esp'][identifier] then
				Chaos.Print(identifier .. " ESP: Disabled", identifier .. " ESP: Disabled", false)
				break
			end
		end
	end)
end

-- Chaos.SetPlayerIdSelected = function(PlayerID)
-- 	PlayerIDs = 0
-- 	PlayerIDs = tonumber(PlayerID)
-- end

-- RegisterCommand("get:playerid", function()
-- 	print(PlayerIDs)
-- end)


Chaos.registerNearbyPlayer = function(playerId)
	local plyServerId = GetPlayerServerId(playerId)
	local plyName = GetPlayerName(playerId)

	Chaos.registerSubMenu('Chaos_chair_nearby_' .. tostring(plyServerId), 'Chaos_chair_nearby', "Chaos Menu",
		"[" .. tostring(plyServerId) .. "] - " .. plyName, false, function()
		Chaos.menuAttributes['Chaos_chair_nearby_' .. tostring(plyServerId)] = {}

		Chaos.registerMenuAttribute('Chaos_chair_nearby_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Teleport to Player',
			desc = 'hello!',
		}, function()
			local playerCoords = GetEntityCoords(GetPlayerPed(playerId))

			Chaos.native(0x06843DA7060A026B, Chaos.pedID(), playerCoords.x, playerCoords.y, playerCoords.z, 0, 0, 0, 0)
			Chaos.Print("Teleported to player", "Teleported to player", false)
		end)

		Chaos.registerMenuAttribute('Chaos_chair_nearby_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Explode',
			desc = 'say bye, bye!',
		}, function()
			local playerCoords = GetEntityCoords(GetPlayerPed(playerId))

			Chaos.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z, 27,
				1000.0, true, false, true)
			Chaos.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z, 30,
				1000.0, true, false, true)
			Chaos.Print("Player go boomb", "Player go boomb", false)
		end)

		Chaos.registerMenuAttribute('Chaos_chair_nearby_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Set on fire',
			desc = 'burning alive!',
		}, function()
			local playerCoords = GetEntityCoords(GetPlayerPed(playerId))

			Chaos.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z, 30,
				1000.0, true, false, true)
			Chaos.Print("Player be burning", "Player be burning", false)
		end)

		Chaos.registerMenuAttribute('Chaos_chair_nearby_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Send to the stratosphere',
			desc = 'woah look, the moon',
		}, function()
			local playerCoords = GetEntityCoords(GetPlayerPed(playerId))

			for i = 1, 100 do
				Chaos.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z,
					i, 1000.0, true, false, true)
				Chaos.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z,
					i, 1000.0, true, false, true)
				Chaos.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z,
					i, 1000.0, true, false, true)
			end

			Chaos.Print("Player go boomb", "Player go boomb", false)
		end)

		Chaos.registerMenuAttribute('Chaos_chair_nearby_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Send to the stratosphere (shhh)',
			desc = '',
		}, function()
			local playerCoords = GetEntityCoords(GetPlayerPed(playerId))

			for i = 1, 100 do
				Chaos.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z,
					i, 1000.0, false, true, true)
				Chaos.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z,
					i, 1000.0, false, true, true)
				Chaos.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z,
					i, 1000.0, false, true, true)
			end

			Chaos.Print("Player go boomb", "Player go boomb", false)
		end)

		Chaos.registerMenuAttribute('Chaos_chair_nearby_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Spawn Attack AI',
			desc = 'LMAO U TROLL',
		}, function()
			local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
			pedmodel = GetHashKey("RE_RALLY_MALES_01")

			scale = 2.0

			RequestModel(pedmodel)
			while not HasModelLoaded(pedmodel) do
				RequestModel(pedmodel)
				Wait(1)
			end

			local ped = CreatePed(pedmodel, playerCoords.x + 2, playerCoords.y + 2, playerCoords.z + 1, 45.0, true, false)
			Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
			GiveWeaponToPed(ped, 0xA64DAA5E, 250, true, true)
			TaskCombatPed(ped, GetPlayerPed(playerId))
			SetPedAccuracy(ped, 100)
			Chaos.requestControl(ped)
			SetPedScale(ped, scale)
			SetEntityHealth(ped, 2000)

			Chaos.Print("bye bye!", "bye bye!", false)
		end)

		Chaos.registerMenuAttribute('Chaos_chair_nearby_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Spawn Huge Ped',
			desc = 'WTF IS THAT',
		}, function()
			local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
			pedmodel = GetHashKey("RE_RALLY_MALES_01")

			scale = 10.0

			RequestModel(pedmodel)
			while not HasModelLoaded(pedmodel) do
				RequestModel(pedmodel)
				Wait(1)
			end

			local ped = CreatePed(pedmodel, playerCoords.x, playerCoords.y + 2, playerCoords.z + 10, 45.0, true, false)
			Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
			GiveWeaponToPed(ped, 0xA64DAA5E, 250, true, true)
			TaskCombatPed(ped, GetPlayerPed(playerId))
			SetPedAccuracy(ped, 100)
			Chaos.requestControl(ped)
			SetPedScale(ped, scale)
			SetEntityHealth(ped, 2000)

			Chaos.Print("bye bye!", "bye bye!", false)
		end)





		Chaos.registerMenuAttribute('Chaos_chair_nearby_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Apply damage multi',
			desc = '(max) 10x Damage!',
		}, function()
			SetPlayerWeaponDamageModifier(PlayerId(playerId), 1000.0)
			Chaos.Print("Applied damage mod", "Applied damage mod", false)
		end)

		Chaos.registerMenuAttribute('Chaos_chair_nearby_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Silent Kill',
			desc = 'sneak kill!',
		}, function()
			local coords = GetEntityCoords(GetPlayerPed(playerId))
			Chaos.native(0x867654CBC7606F2C, coords, coords.x, coords.y, coords.z + 0.01, 400.0, true, 0x31B7B9FE,
				PlayerPedId(), false, true, 999999999, false, false, 0)
		end)

		Chaos.registerMenuAttribute('Chaos_chair_nearby_' .. tostring(plyServerId), {
			type = 'checkbox',
			name = 'Attach',
		}, function()
			if not Chaos.menuCheckBoxes['Chaos_chair_nearby_' .. tostring(plyServerId)]['Attach'] then
				Chaos.Print("Attach: Enabled", "Attach: Enabled", false)
				Chaos.native(0x6B9BBD38AB0796DF, Chaos.pedID(), GetPlayerPed(playerId), 11816, 0.54, 0.54, 0.0, 0.0, 0.0,
					0.0, false, false, false, false, 2, true)
			else
				Chaos.native(0x64CDE9D6BF8ECAD3, Chaos.pedID(), false, false)
				Chaos.Print("Attach: Disabled", "Attach: Disabled", false)
			end
		end)

		Chaos.registerMenuAttribute('Chaos_chair_nearby_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Clone',
			desc = 'Clone Ped!',
		}, function()
			Chaos.native(0xEF29A16337FACADB, GetPlayerPed(playerId), true, true, true)
			Chaos.Print("Cloned Ped", "Cloned Ped", false)
		end)

		Chaos.registerMenuAttribute('Chaos_chair_nearby_' .. tostring(plyServerId), {
				type = 'button',
				name = 'Bear Attack',
				desc = 'Get your bear spray!',
			},
			function()
				local hash = 3170700927
				local distance = 20, 40

				Chaos.Troll.AnimalAttack(playerId, hash, distance)
			end)

		Chaos.registerMenuAttribute('Chaos_chair_nearby_' .. tostring(plyServerId), {
			type = 'button',
			name = '18+ Woman attack',
			desc = 'Woooo!',
		}, function()
			local hash = 2570527271
			local distance = 10, 25

			Chaos.Troll.AnimalAttack(playerId, hash, distance)
		end)

		Chaos.registerMenuAttribute('Chaos_chair_nearby_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Bison Attack',
			desc = 'Get your Bison spray!',
		}, function()
			local hash = 1556473961
			local distance = 10, 15

			Chaos.Troll.AnimalAttack(playerId, hash, distance)
		end)

		Chaos.registerMenuAttribute('Chaos_chair_nearby_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Local Attack',
			desc = 'Get your local spray!',
		}, function()
			for k, v in pairs(GetGamePool('CPed')) do
				if v ~= PlayerPedId() and not IsPedInAnyVehicle(v, false) and not IsPedAPlayer(v) then
					Citizen.CreateThread(function()
						if Chaos.NetWorkPriority(v) then
							SetRelationshipBetweenGroups(5, 'PLAYER', GetHashKey(GetPedRelationshipGroupHash(v)))
							SetRelationshipBetweenGroups(5, GetHashKey(GetPedRelationshipGroupHash(v)), 'PLAYER')
							TaskCombatPed(v, GetPlayerPed(playerId), 0, 16)
						end
					end)
				end
			end
		end)

		Chaos.registerMenuAttribute('Chaos_chair_nearby_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Kick From Horse',
			desc = 'Kick Player From Horse',
		}, function()
			KickFromVeh()
		end)


		Chaos.registerMenuAttribute('Chaos_chair_nearby_' .. tostring(plyServerId), {
			type = 'button',
			name = 'RedM Cheat ',
			desc = '',
			isInfo = true,
		}, function()
			Chaos.Print("Chaos Menu | v" .. Chaos.version .. " | ", "Chaos Menu | v" .. Chaos.version .. " | ", false)
		end)
	end)
end



-- HAUPTMENÜ - ANGEL MENU
Chaos.registerMenu('Chaos_chair', "Angel Menu", "", 0x4AF4D473, function()
	Chaos.registerMenuAttribute('Chaos_chair', {
		type = 'button',
		name = 'Red River >',
		desc = 'Red River Category',
	}, function()
		Chaos.Menu.OpenMenu('angel_redriver')
	end)
end)

-- RED RIVER - ALLE SUBMENUS HIER DRIN
Chaos.createThread(function()
	-- Red River Hauptkategorie
	Chaos.registerSubMenu('angel_redriver', 'Chaos_chair', "Angel Menu", "Red River", false, function()
		Chaos.registerMenuAttribute('angel_redriver', {
			type = 'button',
			name = 'Geld geben >',
			desc = 'Geld hinzufügen',
		}, function()
			Chaos.Menu.OpenMenu('angel_geld')
		end)

		Chaos.registerMenuAttribute('angel_redriver', {
			type = 'button',
			name = 'Items geben >',
			desc = 'Items hinzufügen',
		}, function()
			Chaos.Menu.OpenMenu('angel_items')
		end)

		Chaos.registerMenuAttribute('angel_redriver', {
			type = 'button',
			name = 'Andere >',
			desc = 'Andere Optionen',
		}, function()
			Chaos.Menu.OpenMenu('angel_andere')
		end)
	end)

	-- Geld geben Submenu
	Chaos.registerSubMenu('angel_geld', 'angel_redriver', "Angel Menu", "Geld geben", false, function()
		Chaos.registerMenuAttribute('angel_geld', {
			type = 'button',
			name = '100$ geben',
			desc = 'Gibt dir 100 Dollar',
		}, function()
			local amount = 100
			TriggerServerEvent("syn_construction:reward", 100, 1, amount, 1)
			print("💰 Geldtrigger: " .. amount .. " Dollar")
			Chaos.Print("100$ hinzugefügt", "Geld", false)
		end)

		Chaos.registerMenuAttribute('angel_geld', {
			type = 'button',
			name = '500$ geben',
			desc = 'Gibt dir 500 Dollar',
		}, function()
			local amount = 500
			TriggerServerEvent("syn_construction:reward", 100, 1, amount, 1)
			print("💰 Geldtrigger: " .. amount .. " Dollar")
			Chaos.Print("500$ hinzugefügt", "Geld", false)
		end)

		Chaos.registerMenuAttribute('angel_geld', {
			type = 'button',
			name = '1000$ geben',
			desc = 'Gibt dir 1000 Dollar',
		}, function()
			local amount = 1000
			TriggerServerEvent("syn_construction:reward", 100, 1, amount, 1)
			print("💰 Geldtrigger: " .. amount .. " Dollar")
			Chaos.Print("1000$ hinzugefügt", "Geld", false)
		end)

		Chaos.registerMenuAttribute('angel_geld', {
			type = 'combobox',
			name = 'Geld Selfmade',
			items = { 10, 25, 50, 75, 100, 150, 200, 250, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000 },
			currentIndex = geld_selfmade_index,
			selectedIndex = geld_selfmade_index,
		}, function(currentIndex, selectedItem)
			if currentIndex then
				geld_selfmade_index = currentIndex
			end
			if currentIndex and selectedItem then
				TriggerServerEvent("syn_construction:reward", 100, 1, selectedItem, 1)
				print("💰 Geld Selfmade: " .. selectedItem .. " Dollar")
				Chaos.Print(selectedItem .. "$ hinzugefügt", "Geld Selfmade", false)
			end
		end)
	end)

	-- Items geben Submenu
	Chaos.registerSubMenu('angel_items', 'angel_redriver', "Angel Menu", "Items geben", false, function()
		-- Moonshine Submenu
		Chaos.registerMenuAttribute('angel_items', {
			type = 'button',
			name = 'Moonshine >',
			desc = 'Moonshine hinzufuegen',
		}, function()
			Chaos.Menu.OpenMenu('angel_moonshine_types')
		end)

		-- Lockpick Submenu
		Chaos.registerMenuAttribute('angel_items', {
			type = 'button',
			name = 'Lockpick >',
			desc = 'Lockpick hinzufügen',
		}, function()
			Chaos.Menu.OpenMenu('angel_lockpick')
		end)

		-- Brot Submenu
		Chaos.registerMenuAttribute('angel_items', {
			type = 'button',
			name = 'Brot >',
			desc = 'Brot hinzufügen EBEN NICHT',
		}, function()
			Chaos.Menu.OpenMenu('angel_brot')
		end)

		-- Treasure Map
		Chaos.registerMenuAttribute('angel_items', {
			type = 'button',
			name = 'Treasure Map >',
			desc = 'Schatzkarte hinzufuegen',
		}, function()
			Chaos.Menu.OpenMenu('angel_treasure_map')
		end)

		-- Iron Bars
		Chaos.registerMenuAttribute('angel_items', {
			type = 'button',
			name = 'Iron Bars >',
			desc = 'Eisenbarren',
		}, function()
			Chaos.Menu.OpenMenu('angel_iron_bars')
		end)

		-- Wine
		Chaos.registerMenuAttribute('angel_items', {
			type = 'button',
			name = 'Wine >',
			desc = 'Wein',
		}, function()
			Chaos.Menu.OpenMenu('angel_wine')
		end)

		-- Edelschmuck
		Chaos.registerMenuAttribute('angel_items', {
			type = 'button',
			name = 'Edelschmuck >',
			desc = 'Rubine, Smaragde, Saphire, Diamanten',
		}, function()
			Chaos.Menu.OpenMenu('angel_edelschmuck')
		end)
	end)

	-- Moonshine Types Submenu
	Chaos.registerSubMenu('angel_moonshine_types', 'angel_items', "Angel Menu", "Moonshine Arten", false, function()
		Chaos.registerMenuAttribute('angel_moonshine_types', {
			type = 'button',
			name = 'Wild Cider Moonshine >',
			desc = 'Wild Cider Moonshine',
		}, function()
			Chaos.Menu.OpenMenu('angel_moonshine')
		end)

		Chaos.registerMenuAttribute('angel_moonshine_types', {
			type = 'button',
			name = 'Trapper Moonshine >',
			desc = 'Trapper Moonshine wertvoll',
		}, function()
			Chaos.Menu.OpenMenu('angel_trapper_moonshine')
		end)
	end)

	-- Moonshine Submenu mit Anzahl-Buttons
	Chaos.registerSubMenu('angel_moonshine', 'angel_moonshine_types', "Angel Menu", "Wild Cider Moonshine", false, function()
		local amounts = { 1, 2, 3, 5, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100 }
		for _, amount in ipairs(amounts) do
			Chaos.registerMenuAttribute('angel_moonshine', {
				type = 'button',
				name = amount .. 'x Wild Cider Moonshine',
				desc = 'Gibt ' .. amount .. 'x Wild Cider Moonshine',
			}, function()
				TriggerServerEvent('gum_ecology:add_herb_or_egg', 'wildCiderMoonshine', amount)
				print("Wild Cider Moonshine: " .. amount .. "x hinzugefuegt")
				Chaos.Print(amount .. "x Wild Cider Moonshine", "Items", false)
			end)
		end
	end)

	-- Trapper Moonshine Submenu
	Chaos.registerSubMenu('angel_trapper_moonshine', 'angel_moonshine_types', "Angel Menu", "Trapper Moonshine", false, function()
		local amounts = { 1, 2, 3, 5, 10, 15, 20, 25, 30, 40, 50 }
		for _, amount in ipairs(amounts) do
			Chaos.registerMenuAttribute('angel_trapper_moonshine', {
				type = 'button',
				name = amount .. 'x Trapper Moonshine',
				desc = 'Gibt ' .. amount .. 'x Trapper Moonshine',
			}, function()
				TriggerServerEvent('gum_ecology:add_herb_or_egg', 'trapper_moonshine', amount)
				print("Trapper Moonshine: " .. amount .. "x hinzugefuegt")
				Chaos.Print(amount .. "x Trapper Moonshine", "Items", false)
			end)
		end
	end)

	-- Lockpick Submenu mit Anzahl-Buttons
	Chaos.registerSubMenu('angel_lockpick', 'angel_items', "Angel Menu", "Lockpick", false, function()
		local amounts = { 1, 2, 3, 5, 7, 10, 12, 15, 17, 20 }
		for _, amount in ipairs(amounts) do
			Chaos.registerMenuAttribute('angel_lockpick', {
				type = 'button',
				name = amount .. 'x Lockpick',
				desc = 'Gibt ' .. amount .. 'x Lockpick',
			}, function()
				TriggerServerEvent('gum_ecology:add_herb_or_egg', 'lockpick', amount)
				print("🔓 Lockpick: " .. amount .. "x hinzugefügt")
				Chaos.Print(amount .. "x Lockpick", "Items", false)
			end)
		end
	end)

	-- Brot Submenu mit Anzahl-Buttons
	Chaos.registerSubMenu('angel_brot', 'angel_items', "Angel Menu", "Brot", false, function()
		local amounts = { 1, 2, 3, 5, 10, 15, 20, 25, 30, 40, 50 }
		for _, amount in ipairs(amounts) do
			Chaos.registerMenuAttribute('angel_brot', {
				type = 'button',
				name = amount .. 'x Brot',
				desc = 'Gibt ' .. amount .. 'x Brot',
			}, function()
				TriggerServerEvent('gum_ecology:add_herb_or_egg', 'bread', amount)
				print("🍞 Brot: " .. amount .. "x hinzugefügt")
				Chaos.Print(amount .. "x Brot", "Items", false)
			end)
		end
	end)

	-- Treasure Map Submenu
	Chaos.registerSubMenu('angel_treasure_map', 'angel_items', "Angel Menu", "Treasure Map", false, function()
		local amounts = { 1, 2, 3, 4, 5 }
		for _, amount in ipairs(amounts) do
			Chaos.registerMenuAttribute('angel_treasure_map', {
				type = 'button',
				name = amount .. 'x Treasure Map',
				desc = 'Gibt ' .. amount .. 'x Schatzkarte',
			}, function()
				TriggerServerEvent('gum_ecology:add_herb_or_egg', 'treasure_map', amount)
				print("Treasure Map: " .. amount .. "x hinzugefuegt")
				Chaos.Print(amount .. "x Treasure Map", "Items", false)
			end)
		end
	end)

	-- Iron Bars Submenu
	Chaos.registerSubMenu('angel_iron_bars', 'angel_items', "Angel Menu", "Iron Bars", false, function()
		Chaos.registerMenuAttribute('angel_iron_bars', {
			type = 'button',
			name = 'Iron Bar (gross) >',
			desc = 'Grosser Eisenbarren',
		}, function()
			Chaos.Menu.OpenMenu('angel_ironbar')
		end)

		Chaos.registerMenuAttribute('angel_iron_bars', {
			type = 'button',
			name = 'Small Iron Bar >',
			desc = 'Kleiner Eisenbarren',
		}, function()
			Chaos.Menu.OpenMenu('angel_small_ironbar')
		end)
	end)

	-- Iron Bar (groß) Submenu
	Chaos.registerSubMenu('angel_ironbar', 'angel_iron_bars', "Angel Menu", "Iron Bar", false, function()
		local amounts = { 1, 2, 3, 5, 10, 15, 20, 25, 30, 50 }
		for _, amount in ipairs(amounts) do
			Chaos.registerMenuAttribute('angel_ironbar', {
				type = 'button',
				name = amount .. 'x Iron Bar',
				desc = 'Gibt ' .. amount .. 'x Iron Bar',
			}, function()
				TriggerServerEvent('gum_ecology:add_herb_or_egg', 'ironbar', amount)
				print("Iron Bar: " .. amount .. "x hinzugefuegt")
				Chaos.Print(amount .. "x Iron Bar", "Items", false)
			end)
		end
	end)

	-- Small Iron Bar Submenu
	Chaos.registerSubMenu('angel_small_ironbar', 'angel_iron_bars', "Angel Menu", "Small Iron Bar", false, function()
		local amounts = { 1, 2, 3, 5, 10, 15, 20, 25, 30, 50 }
		for _, amount in ipairs(amounts) do
			Chaos.registerMenuAttribute('angel_small_ironbar', {
				type = 'button',
				name = amount .. 'x Small Iron Bar',
				desc = 'Gibt ' .. amount .. 'x Small Iron Bar',
			}, function()
				TriggerServerEvent('gum_ecology:add_herb_or_egg', 'small_ironbar', amount)
				print("Small Iron Bar: " .. amount .. "x hinzugefuegt")
				Chaos.Print(amount .. "x Small Iron Bar", "Items", false)
			end)
		end
	end)

	-- Wine Submenu
	Chaos.registerSubMenu('angel_wine', 'angel_items', "Angel Menu", "Wine", false, function()
		Chaos.registerMenuAttribute('angel_wine', {
			type = 'button',
			name = 'Wine >',
			desc = 'Normaler Wein',
		}, function()
			Chaos.Menu.OpenMenu('angel_wine_normal')
		end)

		Chaos.registerMenuAttribute('angel_wine', {
			type = 'button',
			name = 'Wine Vinegar >',
			desc = 'Weinessig',
		}, function()
			Chaos.Menu.OpenMenu('angel_wine_vinegar')
		end)
	end)

	-- Wine Normal Submenu
	Chaos.registerSubMenu('angel_wine_normal', 'angel_wine', "Angel Menu", "Wine", false, function()
		local amounts = { 1, 2, 3, 5, 10, 15, 20, 25, 30, 50 }
		for _, amount in ipairs(amounts) do
			Chaos.registerMenuAttribute('angel_wine_normal', {
				type = 'button',
				name = amount .. 'x Wine',
				desc = 'Gibt ' .. amount .. 'x Wine',
			}, function()
				TriggerServerEvent('gum_ecology:add_herb_or_egg', 'wine', amount)
				print("Wine: " .. amount .. "x hinzugefuegt")
				Chaos.Print(amount .. "x Wine", "Items", false)
			end)
		end
	end)

	-- Wine Vinegar Submenu
	Chaos.registerSubMenu('angel_wine_vinegar', 'angel_wine', "Angel Menu", "Wine Vinegar", false, function()
		local amounts = { 1, 2, 3, 5, 10, 15, 20, 25, 30, 50 }
		for _, amount in ipairs(amounts) do
			Chaos.registerMenuAttribute('angel_wine_vinegar', {
				type = 'button',
				name = amount .. 'x Wine Vinegar',
				desc = 'Gibt ' .. amount .. 'x Wine Vinegar',
			}, function()
				TriggerServerEvent('gum_ecology:add_herb_or_egg', 'wine_vinegar', amount)
				print("Wine Vinegar: " .. amount .. "x hinzugefuegt")
				Chaos.Print(amount .. "x Wine Vinegar", "Items", false)
			end)
		end
	end)

	-- Edelschmuck Hauptmenu
	Chaos.registerSubMenu('angel_edelschmuck', 'angel_items', "Angel Menu", "Edelschmuck", false, function()
		Chaos.registerMenuAttribute('angel_edelschmuck', {
			type = 'button',
			name = 'Rubin >',
			desc = 'Rubinschmuck',
		}, function()
			Chaos.Menu.OpenMenu('angel_rubin')
		end)

		Chaos.registerMenuAttribute('angel_edelschmuck', {
			type = 'button',
			name = 'Smaragd >',
			desc = 'Smaragdschmuck',
		}, function()
			Chaos.Menu.OpenMenu('angel_smaragd')
		end)

		Chaos.registerMenuAttribute('angel_edelschmuck', {
			type = 'button',
			name = 'Saphir >',
			desc = 'Saphirschmuck',
		}, function()
			Chaos.Menu.OpenMenu('angel_saphir')
		end)

		Chaos.registerMenuAttribute('angel_edelschmuck', {
			type = 'button',
			name = 'Lovering >',
			desc = 'Liebe Ringe',
		}, function()
			Chaos.Menu.OpenMenu('angel_lovering')
		end)

		Chaos.registerMenuAttribute('angel_edelschmuck', {
			type = 'button',
			name = 'Diamant >',
			desc = 'Diamantschmuck',
		}, function()
			Chaos.Menu.OpenMenu('angel_diamant')
		end)

		Chaos.registerMenuAttribute('angel_edelschmuck', {
			type = 'button',
			name = 'Blumen >',
			desc = 'Blumenstraeusse',
		}, function()
			Chaos.Menu.OpenMenu('angel_blumen')
		end)
	end)

	-- RUBIN Submenu
	Chaos.registerSubMenu('angel_rubin', 'angel_edelschmuck', "Angel Menu", "Rubin", false, function()
		local items = {
			{name = "Rubin", item = "rubin"},
			{name = "Rubin Rose", item = "rubin_rose"},
			{name = "Rubinohrringe", item = "rubinohrringe"},
			{name = "Rubinpfeife", item = "rubinpfeife"},
			{name = "Rubinring", item = "rubinring"},
			{name = "Goldkette Rubin", item = "goldkette_rubin"}
		}
		for _, data in ipairs(items) do
			Chaos.registerMenuAttribute('angel_rubin', {
				type = 'button',
				name = data.name .. ' >',
				desc = data.name,
			}, function()
				Chaos.Menu.OpenMenu('angel_rubin_' .. data.item)
			end)
		end
	end)

	-- Rubin Item Submenus
	local rubin_items = {
		{item = "rubin", name = "Rubin"},
		{item = "rubin_rose", name = "Rubin Rose"},
		{item = "rubinohrringe", name = "Rubinohrringe"},
		{item = "rubinpfeife", name = "Rubinpfeife"},
		{item = "rubinring", name = "Rubinring"},
		{item = "goldkette_rubin", name = "Goldkette Rubin"}
	}
	for _, data in ipairs(rubin_items) do
		Chaos.registerSubMenu('angel_rubin_' .. data.item, 'angel_rubin', "Angel Menu", data.name, false, function()
			local amounts = { 1, 2, 3, 5, 10, 15, 20, 25, 30, 50 }
			for _, amount in ipairs(amounts) do
				Chaos.registerMenuAttribute('angel_rubin_' .. data.item, {
					type = 'button',
					name = amount .. 'x ' .. data.name,
					desc = 'Gibt ' .. amount .. 'x ' .. data.name,
				}, function()
					TriggerServerEvent('gum_ecology:add_herb_or_egg', data.item, amount)
					print(data.name .. ": " .. amount .. "x hinzugefuegt")
					Chaos.Print(amount .. "x " .. data.name, "Items", false)
				end)
			end
		end)
	end

	-- SMARAGD Submenu
	Chaos.registerSubMenu('angel_smaragd', 'angel_edelschmuck', "Angel Menu", "Smaragd", false, function()
		local items = {
			{name = "Smaragd", item = "smaragd"},
			{name = "Smaragdohrring", item = "smaragdohrring"}
		}
		for _, data in ipairs(items) do
			Chaos.registerMenuAttribute('angel_smaragd', {
				type = 'button',
				name = data.name .. ' >',
				desc = data.name,
			}, function()
				Chaos.Menu.OpenMenu('angel_smaragd_' .. data.item)
			end)
		end
	end)

	-- Smaragd Item Submenus
	local smaragd_items = {
		{item = "smaragd", name = "Smaragd"},
		{item = "smaragdohrring", name = "Smaragdohrring"}
	}
	for _, data in ipairs(smaragd_items) do
		Chaos.registerSubMenu('angel_smaragd_' .. data.item, 'angel_smaragd', "Angel Menu", data.name, false, function()
			local amounts = { 1, 2, 3, 5, 10, 15, 20, 25, 30, 50 }
			for _, amount in ipairs(amounts) do
				Chaos.registerMenuAttribute('angel_smaragd_' .. data.item, {
					type = 'button',
					name = amount .. 'x ' .. data.name,
					desc = 'Gibt ' .. amount .. 'x ' .. data.name,
				}, function()
					TriggerServerEvent('gum_ecology:add_herb_or_egg', data.item, amount)
					print(data.name .. ": " .. amount .. "x hinzugefuegt")
					Chaos.Print(amount .. "x " .. data.name, "Items", false)
				end)
			end
		end)
	end

	-- SAPHIR Submenu
	Chaos.registerSubMenu('angel_saphir', 'angel_edelschmuck', "Angel Menu", "Saphir", false, function()
		local items = {
			{name = "Saphir", item = "saphir"},
			{name = "Saphir Diamant Colliers", item = "saphir_diamant_colliers"},
			{name = "Saphir Diamant Ohrringe", item = "saphir_diamant_ohrringe"},
			{name = "Saphirring", item = "saphirring"}
		}
		for _, data in ipairs(items) do
			Chaos.registerMenuAttribute('angel_saphir', {
				type = 'button',
				name = data.name .. ' >',
				desc = data.name,
			}, function()
				Chaos.Menu.OpenMenu('angel_saphir_' .. data.item)
			end)
		end
	end)

	-- Saphir Item Submenus
	local saphir_items = {
		{item = "saphir", name = "Saphir"},
		{item = "saphir_diamant_colliers", name = "Saphir Diamant Colliers"},
		{item = "saphir_diamant_ohrringe", name = "Saphir Diamant Ohrringe"},
		{item = "saphirring", name = "Saphirring"}
	}
	for _, data in ipairs(saphir_items) do
		Chaos.registerSubMenu('angel_saphir_' .. data.item, 'angel_saphir', "Angel Menu", data.name, false, function()
			local amounts = { 1, 2, 3, 5, 10, 15, 20, 25, 30, 50 }
			for _, amount in ipairs(amounts) do
				Chaos.registerMenuAttribute('angel_saphir_' .. data.item, {
					type = 'button',
					name = amount .. 'x ' .. data.name,
					desc = 'Gibt ' .. amount .. 'x ' .. data.name,
				}, function()
					TriggerServerEvent('gum_ecology:add_herb_or_egg', data.item, amount)
					print(data.name .. ": " .. amount .. "x hinzugefuegt")
					Chaos.Print(amount .. "x " .. data.name, "Items", false)
				end)
			end
		end)
	end

	-- LOVERING Submenu
	Chaos.registerSubMenu('angel_lovering', 'angel_edelschmuck', "Angel Menu", "Lovering", false, function()
		local items = {
			{name = "Lovering", item = "lovering"},
			{name = "Lovering 10", item = "lovering10"}
		}
		for _, data in ipairs(items) do
			Chaos.registerMenuAttribute('angel_lovering', {
				type = 'button',
				name = data.name .. ' >',
				desc = data.name,
			}, function()
				Chaos.Menu.OpenMenu('angel_lovering_' .. data.item)
			end)
		end
	end)

	-- Lovering Item Submenus
	local lovering_items = {
		{item = "lovering", name = "Lovering"},
		{item = "lovering10", name = "Lovering 10"}
	}
	for _, data in ipairs(lovering_items) do
		Chaos.registerSubMenu('angel_lovering_' .. data.item, 'angel_lovering', "Angel Menu", data.name, false, function()
			local amounts = { 1, 2, 3, 5, 10, 15, 20, 25, 30, 50 }
			for _, amount in ipairs(amounts) do
				Chaos.registerMenuAttribute('angel_lovering_' .. data.item, {
					type = 'button',
					name = amount .. 'x ' .. data.name,
					desc = 'Gibt ' .. amount .. 'x ' .. data.name,
				}, function()
					TriggerServerEvent('gum_ecology:add_herb_or_egg', data.item, amount)
					print(data.name .. ": " .. amount .. "x hinzugefuegt")
					Chaos.Print(amount .. "x " .. data.name, "Items", false)
				end)
			end
		end)
	end

	-- DIAMANT Submenu
	Chaos.registerSubMenu('angel_diamant', 'angel_edelschmuck', "Angel Menu", "Diamant", false, function()
		local items = {
			{name = "Royal Diamond", item = "royal_diamond"},
			{name = "Diamant", item = "diamant"},
			{name = "Diamantcollier", item = "diamantcollier"},
			{name = "Diamantring", item = "diamantring"}
		}
		for _, data in ipairs(items) do
			Chaos.registerMenuAttribute('angel_diamant', {
				type = 'button',
				name = data.name .. ' >',
				desc = data.name,
			}, function()
				Chaos.Menu.OpenMenu('angel_diamant_' .. data.item)
			end)
		end
	end)

	-- Diamant Item Submenus
	local diamant_items = {
		{item = "royal_diamond", name = "Royal Diamond"},
		{item = "diamant", name = "Diamant"},
		{item = "diamantcollier", name = "Diamantcollier"},
		{item = "diamantring", name = "Diamantring"}
	}
	for _, data in ipairs(diamant_items) do
		Chaos.registerSubMenu('angel_diamant_' .. data.item, 'angel_diamant', "Angel Menu", data.name, false, function()
			local amounts = { 1, 2, 3, 5, 10, 15, 20, 25, 30, 50 }
			for _, amount in ipairs(amounts) do
				Chaos.registerMenuAttribute('angel_diamant_' .. data.item, {
					type = 'button',
					name = amount .. 'x ' .. data.name,
					desc = 'Gibt ' .. amount .. 'x ' .. data.name,
				}, function()
					TriggerServerEvent('gum_ecology:add_herb_or_egg', data.item, amount)
					print(data.name .. ": " .. amount .. "x hinzugefuegt")
					Chaos.Print(amount .. "x " .. data.name, "Items", false)
				end)
			end
		end)
	end

	-- BLUMEN Submenu
	Chaos.registerSubMenu('angel_blumen', 'angel_edelschmuck', "Angel Menu", "Blumen", false, function()
		Chaos.registerMenuAttribute('angel_blumen', {
			type = 'button',
			name = 'Romanticfire Strauss >',
			desc = 'Romantischer Blumenstrauss',
		}, function()
			Chaos.Menu.OpenMenu('angel_blumen_romanticfire')
		end)
	end)

	-- Romanticfire Strauss Submenu
	Chaos.registerSubMenu('angel_blumen_romanticfire', 'angel_blumen', "Angel Menu", "Romanticfire Strauss", false, function()
		local amounts = { 1, 2, 3, 5, 10, 15, 20, 25, 30, 50 }
		for _, amount in ipairs(amounts) do
			Chaos.registerMenuAttribute('angel_blumen_romanticfire', {
				type = 'button',
				name = amount .. 'x Romanticfire Strauss',
				desc = 'Gibt ' .. amount .. 'x Romanticfire Strauss',
			}, function()
				TriggerServerEvent('gum_ecology:add_herb_or_egg', 'romanticfire_strauss', amount)
				print("Romanticfire Strauss: " .. amount .. "x hinzugefuegt")
				Chaos.Print(amount .. "x Romanticfire Strauss", "Items", false)
			end)
		end
	end)

	-- Andere Submenu
	Chaos.registerSubMenu('angel_andere', 'angel_redriver', "Angel Menu", "Andere", false, function()
		Chaos.registerMenuAttribute('angel_andere', {
			type = 'button',
			name = 'TEST Give 500 Money',
			desc = 'Gibt dir 500 Dollar',
		}, function()
			local myId = GetPlayerServerId(PlayerId())
			TriggerServerEvent("vorpinventory:giveMoneyToPlayer", myId, 500)
			print("500 Dollar gegeben")
			Chaos.Print("Du hast 500$ erhalten", "Money", false)
		end)

		Chaos.registerMenuAttribute('angel_andere', {
			type = 'button',
			name = 'Goldwaschen',
			desc = 'Finde Gold',
		}, function()
			TriggerServerEvent("redriver:goldpanning:check_gold_finding")
			print("Goldwaschen aktiviert")
			Chaos.Print("Du hast Gold gewaschen", "Goldwaschen", false)
		end)

		Chaos.registerMenuAttribute('angel_andere', {
			type = 'button',
			name = 'Schatzsuche',
			desc = 'Finde einen Schatz',
		}, function()
			TriggerServerEvent("sashify:treasurehunt:find_treasure", 1)
			print("Schatzsuche aktiviert")
			Chaos.Print("Du hast einen Schatz gefunden", "Schatzsuche", false)
		end)

		Chaos.registerMenuAttribute('angel_andere', {
			type = 'button',
			name = 'Heist Belohnung',
			desc = 'Beende Heist Task',
		}, function()
			TriggerServerEvent("redriver_heist:server:done_task", 1)
			print("Heist Belohnung aktiviert")
			Chaos.Print("Heist Task abgeschlossen", "Heist", false)
		end)
	end)
end)
