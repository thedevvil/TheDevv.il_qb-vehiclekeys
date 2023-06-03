-- Variables

local QBCore = exports['qb-core']:GetCoreObject()
local HasKey = false
local IsRobbing = false
local IsHotwiring = false
local AlertSend = false
local lockpicked = false
local lockpickedPlate = nil
local usingAdvanced

-- Functions

local function HasKey(plate)
	QBCore.Functions.TriggerCallback('vehiclekeys:CheckHasKey', function(result)
		if result then
			HasKey = true
		else
			HasKey = false
		end
	end, plate)
	return HasKey
end

RegisterNetEvent('lockpicks:UseLockpick', function(isAdvanced)
    if (IsPedInAnyVehicle(PlayerPedId())) then
        if not HasKey then
            LockpickIgnition(isAdvanced)
        end
    else
        LockpickDoor(isAdvanced)
    end
end)

function LockVehicle()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local veh = QBCore.Functions.GetClosestVehicle(pos)
    local plate = QBCore.Functions.GetPlate(veh)
    local vehpos = GetEntityCoords(veh)
    if IsPedInAnyVehicle(ped) then
        veh = GetVehiclePedIsIn(ped)
    end
    if veh ~= nil and #(pos - vehpos) < 7.5 then
        QBCore.Functions.TriggerCallback('vehiclekeys:CheckHasKey', function(result)
            if result then
                local vehLockStatus = GetVehicleDoorLockStatus(veh)
                loadAnimDict("anim@mp_player_intmenu@key_fob@")
                TaskPlayAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false, false)

                if vehLockStatus == 1 then
                    Wait(750)
                    ClearPedTasks(ped)
                    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.3)
                    SetVehicleDoorsLocked(veh, 2)
                    if (GetVehicleDoorLockStatus(veh) == 2) then
                        SetVehicleLights(veh, 2)
                        Wait(250)
                        SetVehicleLights(veh, 1)
                        Wait(200)
                        SetVehicleLights(veh, 0)
                        exports['obu-notify']:SendAlert("Arac Kilitlendi!")
                    else
                        exports['obu-notify']:SendAlert("Kilitlenme sisteminde birseyler ters gitti!")
                    end
                else
                    Wait(750)
                    ClearPedTasks(ped)
                    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "unlock", 0.3)
                    SetVehicleDoorsLocked(veh, 1)
                    if (GetVehicleDoorLockStatus(veh) == 1) then
                        SetVehicleLights(veh, 2)
                        Wait(250)
                        SetVehicleLights(veh, 1)
                        Wait(200)
                        SetVehicleLights(veh, 0)
                        exports['obu-notify']:SendAlert("Arac acildi!")
                    else
                        exports['obu-notify']:SendAlert("Kilitlenme sisteminde birseyler ters gitti!")
                    end
                end
            else
                exports['obu-notify']:SendAlert('Bu aracin anahtarlari sende yok..', 'error')
            end
        end, plate)
    end
end

function LockpickDoor(isAdvanced)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local vehicle = QBCore.Functions.GetClosestVehicle(pos)
    if vehicle ~= nil and vehicle ~= 0 then
        local vehpos = GetEntityCoords(vehicle)
        if #(pos - vehpos) < 2.5 then
            local vehLockStatus = GetVehicleDoorLockStatus(vehicle)
            if (vehLockStatus >= 2) then
                usingAdvanced = isAdvanced
                loadAnimDict("veh@break_in@0h@p_m_one@")
                if usingAdvanced then
                    TaskPlayAnim(ped, "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
                    local seconds = math.random(9,12)
					local circles = math.random(1,3)
                    local success = exports['qb-lock']:StartLockPickCircle(circles, seconds, success)
                    lockpickFinish(success)
                else 
                    TaskPlayAnim(ped, "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
                    local seconds = math.random(7,10)
					local circles = math.random(2,4)
                    local success = exports['qb-lock']:StartLockPickCircle(circles, seconds, success)
                    lockpickFinish(success)
                end
            end
        end
    end
end

function lockpickFinish(success)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local vehicle = QBCore.Functions.GetClosestVehicle(pos)
    local chance = math.random()
    StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
    if success then
        TriggerServerEvent('hud:server:GainStress', math.random(0, 0))
        exports['obu-notify']:SendAlert('Kapilar acildi!', 'success')
        SetVehicleDoorsLocked(vehicle, 1)
        lockpicked = true
        lockpickedPlate = QBCore.Functions.GetPlate(vehicle)
    else
        exports['ls-dispatch']:VehicleTheft(vehicle)
        TriggerServerEvent('hud:server:GainStress', math.random(0, 0))
		lockpicked = false
		lockpickedPlate = QBCore.Functions.GetPlate(vehicle)
    end
    if usingAdvanced then
        if chance <= Config.RemoveLockpickAdvanced then
            TriggerServerEvent("qb-vehiclekeys:gelismismaymuncuksil")
        end
    else
        if chance <= Config.RemoveLockpickNormal then
            TriggerServerEvent("qb-vehiclekeys:maymuncuksil")
        end
    end
end

function Hotwire()
    if not HasKey then
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, true)
        IsHotwiring = true
        lockpickedPlate = nil
        local hotwireTime = math.random(20000, 40000)
        SetVehicleAlarm(vehicle, true)
        SetVehicleAlarmTimeLeft(vehicle, hotwireTime)
        exports['ls-dispatch']:VehicleTheft(vehicle)
        QBCore.Functions.Progressbar("hotwire_vehicle", "Kontak anahtarının devreye alınması", hotwireTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true
        }, {
            animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            anim = "machinic_loop_mechandplayer",
            flags = 16
        }, {}, {}, function() -- Done
            StopAnimTask(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
            if (math.random() <= Config.HotwireChance) then
                lockpicked = false
                TriggerServerEvent('hud:server:GainStress', math.random(0, 0))
                TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(vehicle))
                exports['obu-notify']:SendAlert("Hotwire Basarili!")
            else
                SetVehicleEngineOn(veh, false, false, true)
                TriggerServerEvent('hud:server:GainStress', math.random(0, 0))
                exports['obu-notify']:SendAlert("Hotwire basarisiz!", "error")
            end
            IsHotwiring = false
        end, function() -- Cancel
            StopAnimTask(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
            SetVehicleEngineOn(veh, false, false, true)
            exports['obu-notify']:SendAlert("Hotwire basarisiz!", "error")
            IsHotwiring = false
        end)
    end
end

function PoliceCall()
    if not AlertSend then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local chance = Config.PoliceAlertChance
        if GetClockHours() >= 1 and GetClockHours() <= 6 then
            chance = Config.PoliceNightAlertChance
        end
        if math.random() <= chance then
            local closestPed = GetNearbyPed()
            if closestPed ~= nil then
                local msg = ""
                local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                local streetLabel = GetStreetNameFromHashKey(s1)
                local street2 = GetStreetNameFromHashKey(s2)
                if street2 ~= nil and street2 ~= "" then
                    streetLabel = streetLabel .. " " .. street2
                end
                local alertTitle = ""
                if IsPedInAnyVehicle(ped) then
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
                    if QBCore.Shared.Vehicles[modelName] ~= nil then
                        Name = QBCore.Shared.Vehicles[modelName]["brand"] .. ' ' .. QBCore.Shared.Vehicles[modelName]["name"]
                    else
                        Name = "Unknown"
                    end
                    local modelPlate = QBCore.Functions.GetPlate(vehicle)
                    local msg = "Araç hırsızlığı girişimi " .. streetLabel .. ". Araç: " .. Name .. ", Licenseplate: " .. modelPlate
                    local alertTitle = "Araç hırsızlığı girişimi"
                    TriggerServerEvent("police:server:VehicleCall", pos, msg, alertTitle, streetLabel, modelPlate, Name)
                else
                    local vehicle = QBCore.Functions.GetClosestVehicle()
                    local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
                    local modelPlate = QBCore.Functions.GetPlate(vehicle)
                    if QBCore.Shared.Vehicles[modelName] ~= nil then
                        Name = QBCore.Shared.Vehicles[modelName]["brand"] .. ' ' .. QBCore.Shared.Vehicles[modelName]["name"]
                    else
                        Name = "Unknown"
                    end
                    local msg = "Araç hırsızlığı girişimi " .. streetLabel .. ". Arac: " .. Name .. ", Licenseplate: " .. modelPlate
                    local alertTitle = "Araç hırsızlığı girişimi"
                    TriggerServerEvent("police:server:VehicleCall", pos, msg, alertTitle, streetLabel, modelPlate, Name)
                end
            end
        end
        AlertSend = true
        SetTimeout(Config.AlertCooldown, function()
            AlertSend = false
        end)
    end
end

function RobVehicle(target)
    IsRobbing = true
    loadAnimDict('mp_am_hold_up')
    TaskPlayAnim(target, "mp_am_hold_up", "holdup_victim_20s", 8.0, -8.0, -1, 2, 0, false, false, false)
    QBCore.Functions.Progressbar("rob_keys", "Anahtarı alıyorsun..", 6000, false, true, {}, {}, {}, {}, function()
        local chance = math.random()
        if chance <= Config.RobberyChance then
            veh = GetVehiclePedIsUsing(target)
            TaskEveryoneLeaveVehicle(veh)
            Wait(500)
            ClearPedTasksImmediately(target)
            TaskReactAndFleePed(target, PlayerPedId())
            local plate = QBCore.Functions.GetPlate(GetVehiclePedIsIn(target, true))
            TriggerServerEvent('hud:server:GainStress', math.random(0, 0))
            TriggerEvent('vehiclekeys:client:SetOwner', plate)
            exports['obu-notify']:SendAlert('Anahtarlari aldin!', 'success')
            Wait(10000)
            IsRobbing = false
        else
            exports['ls-dispatch']:VehicleTheft(vehicle)
            ClearPedTasks(target)
            TaskReactAndFleePed(target, PlayerPedId())
            TriggerServerEvent('hud:server:GainStress', math.random(0, 0))
            exports['obu-notify']:SendAlert('Polisi aradi!', 'error')
            Wait(10000)
            IsRobbing = false
        end
    end)
end

function LockpickIgnition(isAdvanced)
    if not HasKey then 
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, true)
        if vehicle ~= nil and vehicle ~= 0 then
            if GetPedInVehicleSeat(vehicle, -1) == ped then
                IsHotwiring = true
                exports['ls-dispatch']:VehicleTheft(vehicle)

                local dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"

                usingAdvanced = isAdvanced
                RequestAnimDict(dict)
                while not HasAnimDictLoaded(dict) do
                    RequestAnimDict(dict)
                    Citizen.Wait(100)
                end
                if usingAdvanced then
					local seconds = math.random(9,12)
					local circles = math.random(1,3)
					local success = exports['qb-lock']:StartLockPickCircle(circles, seconds, success)
					if success then
						StopAnimTask(ped, dict, "machinic_loop_mechandplayer", 1.0)
						exports['obu-notify']:SendAlert("Lockpick basarili!")
						HasKey = true
						TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
						IsHotwiring = false
					else
						exports['obu-notify']:SendAlert("Lockpick basarisiz!", "error")
					end
				else
                    local seconds = math.random(7,10)
					local circles = math.random(2,4)
					local success = exports['qb-lock']:StartLockPickCircle(circles, seconds, success)
					if success then
						StopAnimTask(ped, dict, "machinic_loop_mechandplayer", 1.0)
						exports['obu-notify']:SendAlert("Lockpick basarili!")
						HasKey = true
						TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
						IsHotwiring = false
					else
						exports['obu-notify']:SendAlert("Lockpick basarisiz!", "error")
					end
                end
            end
        end
    end
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(0)
    end
end

function IsBlacklistedWeapon()
    local weapon = GetSelectedPedWeapon(PlayerPedId())
    if weapon ~= nil then
        for _, v in pairs(Config.NoRobWeapons) do
            if weapon == GetHashKey(v) then
                return true
            end
        end
    end
    return false
end

function GetNearbyPed()
    local retval = nil
    local PlayerPeds = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        table.insert(PlayerPeds, ped)
    end
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    local closestPed, closestDistance = QBCore.Functions.GetClosestPed(coords, PlayerPeds)
    if not IsEntityDead(closestPed) and closestDistance < 30.0 then
        retval = closestPed
    end
    return retval
end

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

-- Events



RegisterNetEvent('vehiclekeys:client:SetOwner', function(plate)
    local VehPlate = plate
    local CurrentVehPlate = QBCore.Functions.GetPlate(GetVehiclePedIsIn(PlayerPedId(), true))
    if VehPlate == nil then
        VehPlate = CurrentVehPlate
    end
    TriggerServerEvent('vehiclekeys:server:SetVehicleOwner', VehPlate)
    if IsPedInAnyVehicle(PlayerPedId()) and plate == CurrentVehPlate then
        SetVehicleEngineOn(GetVehiclePedIsIn(PlayerPedId(), true), true, false, true)
    end
    HasKey = true
end)

RegisterNetEvent('vehiclekeys:client:GiveKeys', function(target)
    local plate = QBCore.Functions.GetPlate(GetVehiclePedIsIn(PlayerPedId(), true))
    TriggerServerEvent('vehiclekeys:server:GiveVehicleKeys', plate, target)
end)

RegisterNetEvent('vehiclekeys:client:ToggleEngine', function()
	local ped = PlayerPedId()
    local EngineOn = IsVehicleEngineOn(GetVehiclePedIsIn(ped))
    local veh = GetVehiclePedIsIn(ped, true)
	local plate = QBCore.Functions.GetPlate(veh)
	if IsPedInAnyVehicle(ped) then
        veh = GetVehiclePedIsIn(ped)
    end
	if veh ~= nil and not IsThisModelABicycle(GetEntityModel(GetVehiclePedIsIn(ped,false))) then
		QBCore.Functions.TriggerCallback('vehiclekeys:CheckHasKey', function(result)
			if result then
				if HasKey or lockpicked and isHotWired then
					if EngineOn then
						SetVehicleEngineOn(veh, false, false, true)
					else
						SetVehicleEngineOn(veh, true, false, true)
					end
				else
					exports['obu-notify']:SendAlert("Bu aracin anahtarlarina sahip degilsin.", 'error')
				end
            end
        end, plate)
	end
end)

-- command

RegisterKeyMapping('togglelocks', 'Araç Kilitlerini Değiştir', 'keyboard', 'L')
RegisterCommand('togglelocks', function()
    LockVehicle()
end)

-- thread

CreateThread(function()
    while true do
        local sleep = 100
        if LocalPlayer.state.isLoggedIn then
            local ped = PlayerPedId()
            local entering = GetVehiclePedIsTryingToEnter(ped)
            if entering ~= 0 then
                sleep = 2000
                local plate = QBCore.Functions.GetPlate(entering)
                QBCore.Functions.TriggerCallback('vehiclekeys:CheckOwnership', function(result)
                    if not result then -- if not player owned
                        local driver = GetPedInVehicleSeat(entering, -1)
                        if driver ~= 0 and not IsPedAPlayer(driver) then
                            if Config.Rob then
                                if IsEntityDead(driver) then
                                    TriggerEvent("vehiclekeys:client:SetOwner", plate)
                                    SetVehicleDoorsLocked(entering, 1)
                                    HasKey = true
                                else
                                    SetVehicleDoorsLocked(entering, 2)
                                end
                            else
                                TriggerEvent("vehiclekeys:client:SetOwner", plate)
                                SetVehicleDoorsLocked(entering, 1)
                                HasKey = true
                            end
                        else
                            QBCore.Functions.TriggerCallback('vehiclekeys:CheckHasKey', function(result)
                                if not lockpicked or lockpickedPlate ~= plate then
                                    if result == false then
                                        SetVehicleDoorsLocked(entering, 2)
                                        HasKey = false
                                    else 
                                        HasKey = true
                                    end
                                elseif lockpicked and lockpickedPlate == plate then
                                    if result == false then
                                        HasKey = false
                                    else 
                                        HasKey = true
                                    end
                                end
                            end, plate)
                        end
                    end
                end, plate)
            end

            if IsPedInAnyVehicle(ped, false) and lockpicked and not IsHotwiring and not HasKey then
                sleep = 7
                local veh = GetVehiclePedIsIn(ped)
                local vehpos = GetOffsetFromEntityInWorldCoords(veh, 0.0, 2.0, 1.0)
                SetVehicleEngineOn(veh, false, false, true)
            end

            if Config.Rob then
                if not IsRobbing then
                    local playerid = PlayerId()
                    local aiming, target = GetEntityPlayerIsFreeAimingAt(playerid)
                    if aiming and (target ~= nil and target ~= 0) then
                        if DoesEntityExist(target) and not IsEntityDead(target) and not IsPedAPlayer(target) then
                            if IsPedInAnyVehicle(target, false) then
                                local targetveh = GetVehiclePedIsIn(target)
                                if GetPedInVehicleSeat(targetveh, -1) == target then
                                    if not IsBlacklistedWeapon() then
                                        local pos = GetEntityCoords(ped, true)
                                        local targetpos = GetEntityCoords(target, true)
                                        if #(pos - targetpos) < 5.0 then
                                            RobVehicle(target)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)
