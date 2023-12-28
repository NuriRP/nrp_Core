RegisterServerEvent('nrp_Core:loadclient')
AddEventHandler('nrp_Core:loadclient', function()
    local _source = source
    local code = [[
-----{ D E B U G }-----
if NRP_Config.DebugPrintStartMessage then
    local resourceName = GetCurrentResourceName()
    print("^6".. resourceName .." ^7>> Script started.")
end


-----{ E S X }-----
ESX = exports[NRP_Config.ESXName]:getSharedObject()


-----{ H E A D S H O T   O N E S H O T }-----
CreateThread(function()
    local playerPedId = PlayerPedId()
    local headshotOneshot = NRP_Config.HeadshotOneshot

    while true do
        Wait(0)
        SetPedSuffersCriticalHits(playerPedId, headshotOneshot)
    end
end)


-----{ A N T I   M O T O R B I K E H I T }-----
CreateThread(function()
    local playerPedId = PlayerPedId()
    
    while true do
        Wait(0)
        if NRP_Config.AntiMotorbikeHit and IsPedOnAnyBike(playerPedId) then
            DisableControlAction(0, 346, true)
            DisableControlAction(0, 347, true)
        end
    end
end)


-----{ K E E P   F L A S H L I G H T   O N   W H I L E   M O V I N G }-----
CreateThread(function()
    while true do
        Wait(1000)
        if NRP_Config.KeepFlashlightOnWhileMoving then
            local playerId = PlayerId()
            local playerPedId = PlayerPedId()
            
            if IsPedArmed(playerPedId, 6) then
                local isFlashlightOn = IsPlayerFreeAiming(playerId) and IsControlPressed(0, 25)
                SetFlashLightKeepOnWhileMoving(playerPedId, isFlashlightOn)
            end
        end
    end
end)


-----{ R A G D O L L }-----
local isRagdolling = false

if NRP_Config.Ragdoll then
    RegisterCommand(NRP_Config.RagdollCommand, function() ToggleRagdoll() end, false)
    RegisterKeyMapping(NRP_Config.RagdollCommand, NRP_Config.RagdollText, 'keyboard', NRP_Config.RagdollKey)

    function ToggleRagdoll()
        local ped = PlayerPedId()

        if not IsPedOnFoot(ped) or IsInAnimation() then
            return
        end

        isRagdolling = not isRagdolling

        if isRagdolling then
            CreateThread(function()
                while isRagdolling do
                    SetPedToRagdoll(ped, 1000, 1000, 0, false, false, false)
                    Wait(0)
                end
            end)
        end
    end
end

function IsInAnimation()
    local ped = PlayerPedId()
    return IsEntityPlayingAnim(ped, "amb@world_human_bum_slumped@male@laying_on_left_side@base", "base", 3) or
           IsEntityPlayingAnim(ped, "amb@world_human_bum_slumped@male@laying_on_right_side@base", "base", 3) or
           IsEntityPlayingAnim(ped, "amb@world_human_bum_slumped@male@laying_on_belly@base", "base", 3) or
           IsEntityPlayingAnim(ped, "amb@world_human_bum_standing@male@enter", "enter", 3) or
           IsEntityPlayingAnim(ped, "amb@world_human_bum_standing@male@exit", "exit", 3)
end


-----{ A N T I   V E H I C L E R O L L }-----
CreateThread(function()
    local playerPedId = PlayerPedId()
    while NRP_Config.AntiVehicleRoll do
        Wait(1)
        if IsPedInAnyVehicle(playerPedId, false) then
            local vehicle = GetVehiclePedIsIn(playerPedId, false)
            local roll = GetEntityRoll(vehicle)
            if (roll > 75.0 or roll < -75.0) and GetEntitySpeed(vehicle) < 2 then
                DisableControlAction(2, 59, true)
                DisableControlAction(2, 60, true)
            end
        end
    end
end)


-----{ R E S T O R E   S T A M I N A }-----
CreateThread(function()
    local playerId = PlayerId()
    while NRP_Config.RestoreStamina do
        Wait(80)
        RestorePlayerStamina(playerId, 1.0)
    end
end)


-----{ U N L I M I T E D   A I R   U N D E R W A T E R }-----
CreateThread(function()
    while NRP_Config.UnlimitedAirUnderwater do
        Wait(0)
        local playerPedId = PlayerPedId()
        if IsPedSwimmingUnderWater(playerPedId) then
            SetPedDiesInWater(playerPedId, false)
        end
    end
end)


-----{ A N T I   V D M }-----
CreateThread(function()
    while NRP_Config.AntiVDM do
        SetWeaponDamageModifier(-1553120962, 0.0)
        Wait(500)
    end
end)


-----{ / F P S   C O M M A N D }-----
local fps = false

if NRP_Config.FPS then
    RegisterCommand(NRP_Config.FPSCommand, function(source)
        fps = not fps
        if fps then
            SetTimecycleModifier("cinema")
            SetForceVehicleTrails(false)
            SetForcePedFootstepsTracks(false)
            ClearFocus()
            ClearHdArea()
            TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "FPS Boost aktiviert", 5000)
        else
            SetTimecycleModifier("default")
            TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "FPS Boost deaktiviert", 5000)
        end
    end)
end


-----{ H A N D S U P }-----
local handsup = handsup

if NRP_Config.Handsup then
    local handsup = false
    RegisterKeyMapping(NRP_Config.HandsupCommand, NRP_Config.HandsupText, 'keyboard', 'H')

    RegisterCommand(NRP_Config.HandsupCommand,function(source, args)

	    local dict = NRP_Config.HandsupAnimation
        local anim = NRP_Config.HandsupAnimation2
        local playerPedId = PlayerPedId()
    
	    RequestAnimDict(dict)
	    while not HasAnimDictLoaded(dict) do
		    Wait(100)
	    end
	
	    if isDead == true then
			
	    else
		    if not handsup then
                if IsPedInAnyVehicle(playerPedId, true) then
                    return
                end
			    TaskPlayAnim(playerPedId, dict, anim, 8.0, 8.0, -1, 50, 0, false, false, false)
			    handsup = true
		    else
			    handsup = false
			    ClearPedTasks(playerPedId)
		    end
	    end 
        while NRP_Config.HandsupDeactivateKeys do
            Wait(0)
            if handsup then
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 29, true)
                DisableControlAction(0, 37, true)
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 142, true)
                DisableControlAction(0, 170, true)
                DisableControlAction(0, 200, true)
		        DisablePlayerFiring(playerPedId, true)
            end
        end
    end)
end


-----{ E N G I N E }-----
if NRP_Config.Engine then
    local engineRunning = false
    local isInVehicle = false
    local currentVehicle = nil

    RegisterCommand(NRP_Config.EngineCommand, function()
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local vehicle = vehicle
        local engineStatus = GetIsVehicleEngineRunning(vehicle)
        local engineStatus = engineStatus
        engineRunning = not engineStatus

        SetVehicleEngineOn(vehicle, engineRunning, true, true)

        if engineRunning and IsPedInAnyVehicle(PlayerPedId(), true) then
            TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Motor gestartet", 5000)
        else if IsPedInAnyVehicle(PlayerPedId(), true) then
            TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Motor gestopt", 5000)
            end
        end
    end, false)
    RegisterKeyMapping(NRP_Config.EngineCommand, NRP_Config.EngineText, "keyboard", "m")

    local SetVehicleEngineOn = SetVehicleEngineOn

    CreateThread(function()
        while true do
            Wait(0)

            local playerPed = PlayerPedId()
            local isInAnyVehicle = IsPedInAnyVehicle(playerPed, true)

            if not isInVehicle and isInAnyVehicle then
                local vehicleEntering = GetVehiclePedIsEntering(playerPed)

                isInVehicle = true
                currentVehicle = vehicleEntering ~= 0 and vehicleEntering or GetVehiclePedIsIn(playerPed)
                engineRunning = GetIsVehicleEngineRunning(currentVehicle)

                SetVehicleEngineOn(currentVehicle, engineRunning, true, true)
            elseif isInVehicle and not isInAnyVehicle then
                isInVehicle = false

                SetVehicleEngineOn(currentVehicle, engineRunning, true, true)
            end
        end
    end)

    RegisterNetEvent("nrp_Core:engine", function(vehicle, state)
        local playerPed = PlayerPedId()

        if IsPedInAnyVehicle(playerPed, true) then
            if currentVehicle == vehicle then
                engineRunning = state
            end

            SetVehicleEngineOn(vehicle, state, true, true)
        else
            SetVehicleEngineOn(vehicle, state, true, true)
        end
    end)
end


-----{ / S H U F F   C O M M A N D }-----
if NRP_Config.Shuff then
    local disableShuffle = true

    function disableSeatShuffle(flag)
	    disableShuffle = flag
    end

    local playerPedId = PlayerPedId()

    CreateThread(function()
	    while true do
		    Wait(0)
            local getVehiclePedIsIn = GetVehiclePedIsIn(playerPedId, false), 0
		    if IsPedInAnyVehicle(playerPedId, false) and disableShuffle then
			    if GetPedInVehicleSeat(getVehiclePedIsIn) == playerPedId then
				    if GetIsTaskActive(playerPedId, 165) then
				    	SetPedIntoVehicle(playerPedId, getVehiclePedIsIn)
				    end
			    end
		    end
	    end
    end)

    RegisterNetEvent("nrp_Core:shuff")
    AddEventHandler("nrp_Core:shuff", function()
	    if IsPedInAnyVehicle(playerPedId, false) then
		    disableSeatShuffle(false)
		    Wait(5000)
    		disableSeatShuffle(true)
    	else
    		CancelEvent()
    	end
    end)

    RegisterCommand(NRP_Config.ShuffCommand, function(source, args, raw)
        TriggerEvent("nrp_Core:shuff")
    end, false)
end


-----{ N O   N P C }-----
if NRP_Config.NoNPC then
    SetRandomEventFlag(false)

    local scenarios = {
        'WORLD_VEHICLE_ATTRACTOR',
        'WORLD_VEHICLE_AMBULANCE',
        'WORLD_VEHICLE_BICYCLE_BMX',
        'WORLD_VEHICLE_BICYCLE_BMX_BALLAS',
        'WORLD_VEHICLE_BICYCLE_BMX_FAMILY',
        'WORLD_VEHICLE_BICYCLE_BMX_HARMONY',
        'WORLD_VEHICLE_BICYCLE_BMX_VAGOS',
        'WORLD_VEHICLE_BICYCLE_MOUNTAIN',
        'WORLD_VEHICLE_BICYCLE_ROAD',
        'WORLD_VEHICLE_BIKE_OFF_ROAD_RACE',
        'WORLD_VEHICLE_BIKER',
        'WORLD_VEHICLE_BOAT_IDLE',
        'WORLD_VEHICLE_BOAT_IDLE_ALAMO',
        'WORLD_VEHICLE_BOAT_IDLE_MARQUIS',
        'WORLD_VEHICLE_BOAT_IDLE_MARQUIS',
        'WORLD_VEHICLE_BROKEN_DOWN',
        'WORLD_VEHICLE_BUSINESSMEN',
        'WORLD_VEHICLE_HELI_LIFEGUARD',
        'WORLD_VEHICLE_CLUCKIN_BELL_TRAILER',
        'WORLD_VEHICLE_CONSTRUCTION_SOLO',
        'WORLD_VEHICLE_CONSTRUCTION_PASSENGERS',
        'WORLD_VEHICLE_DRIVE_PASSENGERS',
        'WORLD_VEHICLE_DRIVE_PASSENGERS_LIMITED',
        'WORLD_VEHICLE_DRIVE_SOLO',
        'WORLD_VEHICLE_FIRE_TRUCK',
        'WORLD_VEHICLE_EMPTY',
        'WORLD_VEHICLE_MARIACHI',
        'WORLD_VEHICLE_MECHANIC',
        'WORLD_VEHICLE_MILITARY_PLANES_BIG',
        'WORLD_VEHICLE_MILITARY_PLANES_SMALL',
        'WORLD_VEHICLE_PARK_PARALLEL',
        'WORLD_VEHICLE_PARK_PERPENDICULAR_NOSE_IN',
        'WORLD_VEHICLE_PASSENGER_EXIT',
        'WORLD_VEHICLE_POLICE_BIKE',
        'WORLD_VEHICLE_POLICE_CAR',
        'WORLD_VEHICLE_POLICE',
        'WORLD_VEHICLE_POLICE_NEXT_TO_CAR',
        'WORLD_VEHICLE_QUARRY',
        'WORLD_VEHICLE_SALTON',
        'WORLD_VEHICLE_SALTON_DIRT_BIKE',
        'WORLD_VEHICLE_SECURITY_CAR',
        'WORLD_VEHICLE_STREETRACE',
        'WORLD_VEHICLE_TOURBUS',
        'WORLD_VEHICLE_TOURIST',
        'WORLD_VEHICLE_TANDL',
        'WORLD_VEHICLE_TRACTOR',
        'WORLD_VEHICLE_TRACTOR_BEACH',
        'WORLD_VEHICLE_TRUCK_LOGS',
        'WORLD_VEHICLE_TRUCKS_TRAILERS',
        'WORLD_VEHICLE_DISTANT_EMPTY_GROUND'
    }

    for i, v in ipairs(scenarios) do
        SetScenarioTypeEnabled(v, false)
    end

    CreateThread(function()
        while true do
            Wait(0)

            StartAudioScene('CHARACTER_CHANGE_IN_SKY_SCENE')

            NoNPC()

            for i = 1, 15 do
                EnableDispatchService(i, false)
            end

        end
    end)

    function NoNPC()
        SetParkedVehicleDensityMultiplierThisFrame(0.0)
        SetVehicleDensityMultiplierThisFrame(0.0)
        SetRandomVehicleDensityMultiplierThisFrame(0.0)
        SetPedDensityMultiplierThisFrame(0.0)
        SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
    end
end


-----{ P A U S E T E X T }-----
if NRP_Config.PauseText then
    CreateThread(function()
	local playerId = PlayerId()
	local getPlayerName = GetPlayerName(playerId)
	local getPlayerServerId = GetPlayerServerId(playerId)
	AddTextEntry('FE_THDR_GTAO', NRP_Config.PauseText1 .. getPlayerServerId ..'~s~ - '.. getPlayerName)
        AddTextEntry('PM_PANE_LEAVE', 'Verbindung trennen')
    end)
end


-----{ H U D   C O L O R }-----
if NRP_Config.HUDColor then
    CreateThread(function()
        ReplaceHudColourWithRgba(116, NRP_Config.HUDColorR, NRP_Config.HUDColorG, NRP_Config.HUDColorB, NRP_Config.HUDColorA)
    end)
end


-----{ N O   I D L E C A M }-----
CreateThread(function()
    while NRP_Config.NoIdlecam do
	    InvalidateIdleCam()
	    InvalidateVehicleIdleCam()
        Wait(1000)
    end
end)


-----{ / M A P F I X   C O M M A N D }-----
if NRP_Config.Mapfix then
    RegisterCommand(NRP_Config.MapfixCommand, function()
        local playerPedId = PlayerPedId()
	    local interior = GetInteriorAtCoords(GetEntityCoords(playerPedId))
	    PinInteriorInMemory(interior)
	    RefreshInterior(interior)
        TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Map wurde neugeladen!", 5000)
    end)
end


-----{ E S C   A N I M A T I O N }-----
if NRP_Config.ESCAnimation then
    local inMenuMode = false
    local Animation = false
    local PlayerProps = {}
    local playerPedId = PlayerPedId()

    CreateThread(function()
        while true do
            Wait(500)
            if IsPauseMenuActive() then
                AnimMode()
            else
                if Animation then
                    Animation = false
                    ClearPedTasks(playerPedId)
                    DestroyAllProps()
                end
                inMenuMode = false
            end
        end
    end)

    function AnimMode()
        if not inMenuMode then
            if not IsPedInAnyVehicle(playerPedId) then
                Animation = true
                inMenuMode = true
                local anim1 = 'amb@world_human_tourist_map@male@idle_b'
                local anim2 = 'p_tourist_map_01_s'
                local anim3 = 'idle_d'
                LoadAnim(anim1)
                LoadPropDict(anim2)
                local prop = CreateObject(GetHashKey(anim2), 0.0, 0.0, 0.0, true, true, true)
                table.insert(PlayerProps, prop)
                AttachEntityToEntity(prop, playerPedId, GetPedBoneIndex(playerPedId, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                TaskPlayAnim(playerPedId, anim1, anim3, 2.0, 8.0, -1, 53, 0, false, false, false)
            end
        end
    end

    function LoadAnim(dict)
        if not HasAnimDictLoaded(dict) then
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do
                Wait(0)
            end
        end
    end

    function LoadPropDict(model)
        if not HasModelLoaded(GetHashKey(model)) then
            RequestModel(GetHashKey(model))
            while not HasModelLoaded(GetHashKey(model)) do
                Wait(0)
            end
        end
    end

    function DestroyAllProps()
        for i = #PlayerProps, 1, -1 do
            local prop = PlayerProps[i]
            if DoesEntityExist(prop) then
                DeleteEntity(prop)
            end
            table.remove(PlayerProps, i)
        end
    end
end


-----{ M A P C L E A R }-----
CreateThread(function()
    while NRP_Config.Mapclear do
        ClearAllBrokenGlass()
        ClearAllHelpMessages()
        LeaderboardsReadClearAll()
        ClearBrief()
        ClearGpsFlags()
        ClearPrints()
        ClearSmallPrints()
        ClearReplayStats()
        LeaderboardsClearCacheData()
        ClearFocus()
        ClearHdArea()
        Wait(NRP_Config.MapclearTime * 1000)
    end
end)


-----{ D I S C O R D   R I C H   P R E S E N C E }-----
CreateThread(function()
    while NRP_Config.DiscordRichPresence do
        SetDiscordAppId(NRP_Config.DiscordRichPresenceAppId)

        local playerId = PlayerId()
        local getPlayerName = GetPlayerName(playerId)
        local getPlayerServerId = GetPlayerServerId(playerId)
		local getActivePlayers = #GetActivePlayers() -1
        SetRichPresence(getActivePlayers .. NRP_Config.DiscordRichPresenceText .. getPlayerServerId)

        SetDiscordRichPresenceAsset(NRP_Config.DiscordRichPresencePictureBig)
        SetDiscordRichPresenceAssetText(NRP_Config.DiscordRichPresencePictureBigText)

        SetDiscordRichPresenceAction(0, NRP_Config.DiscordRichPresenceButtonText1, NRP_Config.DiscordRichPresenceButtonLink1)
        SetDiscordRichPresenceAction(1, NRP_Config.DiscordRichPresenceButtonText2, NRP_Config.DiscordRichPresenceButtonLink2)

        SetDiscordRichPresenceAssetSmall(NRP_Config.DiscordRichPresencePictureSmall)
        SetDiscordRichPresenceAssetSmallText(getPlayerName)
        Wait(10000)
    end
end)


-----{ V E H I C L E   R E N T A L }-----
CreateThread(function()
    while NRP_Config.VehicleRental do
        Wait(0)
        local playerPedId = PlayerPedId()
        local pedCoords = GetEntityCoords(playerPedId)
        local dist = GetDistanceBetweenCoords(pedCoords, vector3(NRP_Config.VehicleRentalMarkerCoordsX, NRP_Config.VehicleRentalMarkerCoordsY, NRP_Config.VehicleRentalMarkerCoordsZ))
        if dist <= NRP_Config.VehicleRentalMarkerDrawDistance then
            DrawMarker(NRP_Config.VehicleRentalMarkerType, vector3(NRP_Config.VehicleRentalMarkerCoordsX, NRP_Config.VehicleRentalMarkerCoordsY, NRP_Config.VehicleRentalMarkerCoordsZ), 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.5, NRP_Config.VehicleRentalColorR, NRP_Config.VehicleRentalColorG, NRP_Config.VehicleRentalColorB, NRP_Config.VehicleRentalColorA, false, false, 2, false, false, false, false)
            if dist <= 2.0 then
                if IsControlJustReleased(0, 38) then
                    ESX.Game.SpawnVehicle(NRP_Config.VehicleRentalVehicle, vector3(NRP_Config.VehicleRentalVehicleCoordsX, NRP_Config.VehicleRentalVehicleCoordsY, NRP_Config.VehicleRentalVehicleCoordsZ), NRP_Config.VehicleRentalVehicleCoordsR, function(vehicle)
                        SetVehicleFixed(vehicle)
                        if NRP_Config.VehicleRentalUseFuelSystem then
                            exports[NRP_Config.VehicleRentalFuelExport]:SetFuel(vehicle, NRP_Config.VehicleRentalFuelAmount)
                            SetVehicleFuelLevel(vehicle, NRP_Config.VehicleRentalFuelAmount)
                        end
                        TaskWarpPedIntoVehicle(playerPedId, vehicle, -1)
                        SetVehicleNumberPlateText(vehicle, NRP_Config.VehicleRentalPlate)
                        SetVehicleEngineOn(vehicle, true, true)
                        SetVehicleCustomPrimaryColour(vehicle, NRP_Config.VehicleRentalColorR, NRP_Config.VehicleRentalColorG, NRP_Config.VehicleRentalColorB)
                        SetVehicleCustomSecondaryColour(vehicle, NRP_Config.VehicleRentalColorR, NRP_Config.VehicleRentalColorG, NRP_Config.VehicleRentalColorB)
                        TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Du hast dein Fahrzeug erfolgreich ausgeparkt!", 5000)
                    end)
                else
                    NRP_Config.Helpnotify(NRP_Config.VehicleRentalText)
                end
            end
        else
            Wait(1000)
        end
    end       
end)


-----{ P M A - V O I C E   C I R C L E }-----
if NRP_Config.PMAVoiceCircle then
    local dist = 0

    AddEventHandler(NRP_Config.PMAVoiceCircleTrigger, function(data)
        local playerPedId = PlayerPedId()
        local plyState = Player(LocalPlayer).state
        local proximity = plyState.proximity
        local StartMarker = 0
     
        dist = proximity.distance
        StartMarker = 0
        while StartMarker < NRP_Config.PMAVoiceCircleDuration do
            if dist ~= proximity.distance then
                break
            else
            StartMarker = StartMarker + 5
                if IsPedInAnyVehicle(playerPedId, false) then
                    DrawMarker(NRP_Config.PMAVoiceCircleMarkerType, GetEntityCoords(playerPedId).x, GetEntityCoords(playerPedId).y, GetEntityCoords(playerPedId).z - 0.3, 0, 0, 0, 0, 0, 0, proximity.distance, proximity.distance, NRP_Config.PMAVoiceCircleMarkerHeight, NRP_Config.PMAVoiceCircleMarkerColorR, NRP_Config.PMAVoiceCircleMarkerColorG, NRP_Config.PMAVoiceCircleMarkerColorB, NRP_Config.PMAVoiceCircleMarkerColorA, 0, 0, 0, 0)
                else
                    DrawMarker(NRP_Config.PMAVoiceCircleMarkerType, GetEntityCoords(playerPedId).x, GetEntityCoords(playerPedId).y, GetEntityCoords(playerPedId).z - 1, 0, 0, 0, 0, 0, 0, proximity.distance, proximity.distance, NRP_Config.PMAVoiceCircleMarkerHeight, NRP_Config.PMAVoiceCircleMarkerColorR, NRP_Config.PMAVoiceCircleMarkerColorG, NRP_Config.PMAVoiceCircleMarkerColorB, NRP_Config.PMAVoiceCircleMarkerColorA, 0, 0, 0, 0)
                end
            Wait(1)
            end
        end
    end)
end


-----{ B U L L E T P R O O F }-----
if NRP_Config.Bulletproof then
    RegisterNetEvent('nrp_Core:bulletproof')
    AddEventHandler('nrp_Core:bulletproof', function()
        local playerPedId = PlayerPedId()
        if not IsPedFalling(playerPedId) then
            if not IsPedSwimming(playerPedId) then
                if not IsPedInAnyVehicle(playerPedId) then
                    local lib, anim = NRP_Config.BulletproofLib, NRP_Config.BulletproofAnim

                    ESX.Streaming.RequestAnimDict(lib, function()
                        TaskPlayAnim(playerPedId, lib, anim, 8.0, -8.0, NRP_Config.BulletproofTime * 1000, 0, 0, false, false, false)
                        NRP_Config.Progressbar(NRP_Config.BulletproofTime * 1000)
                        Wait(NRP_Config.BulletproofTime * 1000)
                        SetPedArmour(playerPedId, NRP_Config.BulletproofArmor)
                        SetPedComponentVariation(playerPedId, 9, 20, NRP_Config.BulletproofVestColor, 0)

                        TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Schutzweste erfolgreich angelegt", 5000)
                    end)
                else
                    TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du kannst die Schutzweste nicht im Fahrzeug benutzen", 5000)
                end
            else
                TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du kannst die Schutzweste nicht beim Schwimmen benutzen", 5000)
            end
        else
            TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du kannst die Schutzweste nicht im Fallen benutzen", 5000)
        end
    end)
end


-----{ M E D I K I T }-----
if NRP_Config.Medikit then
    RegisterNetEvent('nrp_Core:medikit')
    AddEventHandler('nrp_Core:medikit', function()
        local playerPedId = PlayerPedId()
        if not IsPedFalling(playerPedId) then
            if not IsPedSwimming(playerPedId) then
                if not IsPedInAnyVehicle(playerPedId) then
	                local lib, anim = NRP_Config.MedikitLib, NRP_Config.MedikitAnim

	                ESX.Streaming.RequestAnimDict(lib, function()
		        TaskPlayAnim(playerPedId, lib, anim, 8.0, -8.0, NRP_Config.MedikitTime * 1000, 0, 0, false, false, false)
                        NRP_Config.Progressbar(NRP_Config.MedikitTime * 1000)
		        Wait(NRP_Config.MedikitTime * 1000)
                        SetEntityHealth(playerPedId, NRP_Config.MedikitHealth)

                        TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Medikit erfolgreich angelegt", 5000)
	            end)
                else
                    TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du kannst das Medikit nicht im Fahrzeug benutzen", 5000)
                end
            else
                TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du kannst das Medikit nicht beim Schwimmen benutzen", 5000)
            end
        else
            TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du kannst das Medikit nicht im Fallen benutzen", 5000)
        end
    end)
end


-----{ B A N D A G E }-----
if NRP_Config.Bandage then
    RegisterNetEvent('nrp_Core:bandage')
    AddEventHandler('nrp_Core:bandage', function()
        local playerPedId = PlayerPedId()
        if not IsPedFalling(playerPedId) then
            if not IsPedSwimming(playerPedId) then
                if not IsPedInAnyVehicle(playerPedId) then
	           	local lib, anim = NRP_Config.BandageLib, NRP_Config.BandageAnim
                	local currentHealth = GetEntityHealth(playerPedId)

	                ESX.Streaming.RequestAnimDict(lib, function()
		        TaskPlayAnim(playerPedId, lib, anim, 8.0, -8.0, NRP_Config.BandageTime * 1000, 0, 0, false, false, false)
                        NRP_Config.Progressbar(NRP_Config.BandageTime * 1000)
		        Wait(NRP_Config.BandageTime * 1000)
                        SetEntityHealth(playerPedId, currentHealth + NRP_Config.BandageHealth)

                        TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Bandage erfolgreich angelegt", 5000)
	            end)
                else
                    TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du kannst die Bandage nicht im Fahrzeug benutzen", 5000)
                end
            else
                TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du kannst die Bandage nicht beim Schwimmen benutzen", 5000)
            end
        else
            TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du kannst die Bandage nicht im Fallen benutzen", 5000)
        end
    end)
end


-----{ B L O C K   K E Y S   B Y   B U L L E T P R O O F   O R   M E D I K I T   O R   B A N D A G E }-----
CreateThread(function()
    while NRP_Config.Bulletproof or NRP_Config.Medikit or NRP_Config.Bandage do
        Wait(0)
        if NRP_Config.BulletproofDisableKeys or NRP_Config.MedikitDisableKeys or NRP_Config.BandageDisableKeys then
            local playerPedId = PlayerPedId()
            if IsEntityPlayingAnim(playerPedId, NRP_Config.BandageLib or NRP_Config.MedikitLib or NRP_Config.BulletproofLib, NRP_Config.BandageAnim or NRP_Config.MedikitAnim or NRP_Config.BulletproofAnim, 3) then
                BlockWeaponWheelThisFrame()
                DisableControlAction(0, 0, true)
                DisableControlAction(0, 26, true)
                DisableControlAction(0, 29, true)
                DisableControlAction(0, 37, true)
                DisableControlAction(0, 73, true)
                DisableControlAction(0, 74, true)
                DisableControlAction(0, 167, true)
                DisableControlAction(0, 170, true)
                DisableControlAction(0, 200, true)
                DisableControlAction(0, 288, true)
                DisableControlAction(0, 289, true)
                DisableControlAction(0, 303, true)
            end
        end
    end
end)


-----{ A D U T Y }-----
if NRP_Config.Aduty then
    CreateThread(function()
        while true do
            ESX.TriggerServerCallback("nrp_Core:getRankFromPlayer", function(Pgroup)
                permissiongroup = Pgroup
            end)
            Wait(10000)
        end
    end)

    local oldSpeed = nil

    local GetCamDirection = function()
        local playerPed = PlayerPedId()
        local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(playerPed)
        local pitch = GetGameplayCamRelativePitch()

        local x = -math.sin(heading * math.pi / 180.0)
        local y = math.cos(heading * math.pi / 180.0)
        local z = math.sin(pitch * math.pi / 180.0)

        local len = math.sqrt(x * x + y * y + z * z)
        if len ~= 0 then
            x = x / len
            y = y / len
            z = z / len
        end

        return x, y, z
    end

    function cleanPlayer(playerPed)
        local playerPed = PlayerPedId()
        ClearPedWetness(playerPed)
        ClearPedBloodDamage(playerPed)
        ResetPedVisibleDamage(playerPed)
        ClearPedLastWeaponDamage(playerPed)
        ClearPedEnvDirt(playerPed)
        ResetPedMovementClipset(playerPed, 0)
    end

    function setUniform(playerPed)
        TriggerEvent(NRP_Config.AdutySkinTrigger, function(skin)
            if skin.sex == 0 then
                if permissiongroup == "admin" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.admin.male)
                elseif permissiongroup == "superadmin" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.superadmin.male)
                elseif permissiongroup == "projektinhaber" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.projektinhaber.male)
                elseif permissiongroup == "projektleitung" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.projektleitung.male)
                elseif permissiongroup == "stvprojektleitung" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.stvprojektleitung.male)
                elseif permissiongroup == "teamleitung" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.teamleitung.male)
                elseif permissiongroup == "supportleitung" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.supportleitung.male)
                elseif permissiongroup == "regelwerkmanagement" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.regelwerkmanagement.male)
                elseif permissiongroup == "fraktionsmanagement" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.fraktionsmanagement.male)
                elseif permissiongroup == "eventmanagement" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.eventmanagement.male)
                elseif permissiongroup == "ressourcenmanagement" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.ressourcenmanagement.male)
                elseif permissiongroup == "fahrzeugmanagement" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.fahrzeugmanagement.male)
                elseif permissiongroup == "mod" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.mod.male)
                elseif permissiongroup == "testmod" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.testmod.male)
                elseif permissiongroup == "supporter" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.supporter.male)
                elseif permissiongroup == "testsupporter" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.testsupporter.male)
                elseif permissiongroup == "guide" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.guide.male)
                elseif permissiongroup == "testguide" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.testguide.male)
                end
            else
                if permissiongroup == "admin" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.admin.female)
                elseif permissiongroup == "superadmin" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.superadmin.female)
                elseif permissiongroup == "projektinhaber" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.projektinhaber.female)
                elseif permissiongroup == "projektleitung" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.projektleitung.female)
                elseif permissiongroup == "stvprojektleitung" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.stvprojektleitung.female)
                elseif permissiongroup == "teamleitung" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.teamleitung.female)
                elseif permissiongroup == "supportleitung" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.supportleitung.female)
                elseif permissiongroup == "regelwerkmanagement" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.regelwerkmanagement.female)
                elseif permissiongroup == "fraktionsmanagement" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.fraktionsmanagement.female)
                elseif permissiongroup == "eventmanagement" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.eventmanagement.female)
                elseif permissiongroup == "ressourcenmanagement" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.ressourcenmanagement.female)
                elseif permissiongroup == "fahrzeugmanagement" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.fahrzeugmanagement.female)
                elseif permissiongroup == "mod" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.mod.female)
                elseif permissiongroup == "testmod" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.testmod.female)
                elseif permissiongroup == "supporter" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.supporter.female)
                elseif permissiongroup == "testsupporter" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.testsupporter.female)
                elseif permissiongroup == "guide" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.guide.female)
                elseif permissiongroup == "testguide" then
                    TriggerEvent(NRP_Config.AdutySkinTrigger2, skin, NRP_Config.Admin.testguide.female)
                end
            end
        end)
    end

    RegisterCommand(NRP_Config.AdutyCommand, function()
        local playerPed = PlayerPedId()
        local playerID = PlayerId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if permissiongroup ~= "user" then
            if aduty then
                aduty = false
                noclip = false
                SetPlayerInvincible(playerID, false)
			    SetEntityProofs(playerPed, false, false, false, false, false, false, false, false)
			    SetPedInfiniteAmmoClip(playerPed, false)
                SetPedCanRagdoll(playerPed, true)
                SetPedDiesInWater(playerPed, true)
                SetEntityVisible(playerPed, true, false)
                SetEveryoneIgnorePlayer(playerPed, false)
                SetEntityCollision(playerPed, true, true)
                if IsPedInAnyVehicle(playerPed, false) and NRP_Config.AdutyVehicleGodmode then
                    SetEntityInvincible(vehicle, false)
                    SetEntityProofs(vehicle, false, false, false, false, false, false, false, false)
                end
                if NRP_Config.AdutyNightVision then
                    SetNightvision(false)
                end
                if NRP_Config.AdutyThermalVision then
                    SetSeethrough(false)
                end
                if NRP_Config.AdutyAutoAim then
                    SetPlayerTargetingMode(0)
                end

                exports.nrp_Logs:createLog({
                    EmbedMessage = "**" .. GetPlayerName(playerID) .. "** mit der ID **" .. GetPlayerServerId(playerID) .. "** ist aus dem Aduty gegangen!",
                    player_id = source,
                    channel = "aduty",
                    screenshot = false
                })

                TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Du bist nun nicht mehr im Aduty", 5000)

                ESX.TriggerServerCallback(NRP_Config.AdutySkinTrigger3, function(skin)
                    TriggerEvent(NRP_Config.AdutySkinchangerTrigger, skin)
                end)
            else
                aduty = true
                noclip = false
                SetPlayerInvincible(playerID, true)
			    SetEntityProofs(playerPed, true, true, true, true, true, true, true, true)
			    SetPedInfiniteAmmoClip(playerPed, true)
                SetPedCanRagdoll(playerPed, false)
                SetPedDiesInWater(playerPed, false)
                if IsPedInAnyVehicle(playerPed, false) and NRP_Config.AdutyVehicleGodmode then
                    SetEntityInvincible(vehicle, true)
                    SetEntityProofs(vehicle, true, true, true, true, true, true, true, true)
                end
                if IsPlayerDead(playerID) then
                    TriggerEvent(NRP_Config.AdutyReviveTrigger, playerID)
                end
                CreateThread(function()
                    while NRP_Config.AdutySuperJump and aduty do
                        SetSuperJumpThisFrame(playerID)
                        Wait(0)
                    end
                end)
                if NRP_Config.AdutyUncuff then
                    TriggerEvent(NRP_Config.AdutyUncuffTrigger)
                    if NRP_Config.CabletieAndScissors then
                        TriggerEvent('nrp_Core:forceUncuff')
                    end
                end
                if NRP_Config.AdutyNightVision then
                    SetNightvision(true)
                end
                if NRP_Config.AdutyThermalVision then
                    SetSeethrough(true)
                end
                if NRP_Config.AdutyAutoAim then
                    SetPlayerTargetingMode(3)
                end

                exports.nrp_Logs:createLog({
                    EmbedMessage = "**" .. GetPlayerName(playerID) .. "** mit der ID **" .. GetPlayerServerId(playerID) .. "** ist in den Aduty gegangen!",
                    player_id = source,
                    channel = "aduty",
                    screenshot = false
                })

                TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Du bist nun im Aduty", 5000)

                cleanPlayer()
                setUniform()
            end
        else
            exports.nrp_Logs:createLog({
                EmbedMessage = "Der Spieler **" .. GetPlayerName(playerID) .. "** mit der ID **" .. GetPlayerServerId(playerID) .. "** hat versucht in den Aduty zu gehen, hat aber keine Rechte dafür!",
                player_id = source,
                channel = "aduty",
                screenshot = false
            })

            TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Du hast nicht genügend Rechte!", 5000)
        end
    end)

    local DrawText3D = function(x, y, z, text, r, g, b, scale)
        SetDrawOrigin(x, y, z, 0)
        SetTextFont(0)
        SetTextProportional(0)
        SetTextScale(0, scale or 0.2)
        SetTextColour(r, g, b, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(0, 0)
        ClearDrawOrigin()
    end
    
    CreateThread(function()
        while true do
            Wait(0)
            if aduty then
                local ppedID = PlayerPedId()
                local playerID = PlayerId()
                local vehicle = GetVehiclePedIsIn(ppedID, false)
                if IsDisabledControlJustPressed(0, 348) then
                    noclip = not noclip
                    if noclip then
                        TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Du hast den NoClip angeschaltet", 5000)
                        exports.nrp_Logs:createLog({
                            EmbedMessage = "Der Spieler **" .. GetPlayerName(playerID) .. "** mit der ID **" .. GetPlayerServerId(playerID) .. "** ist in den Aduty-Noclip gegangen!",
                            player_id = source,
                            channel = "aduty",
                            screenshot = false
                        })
                    end
                    if not noclip then
                        SetEntityVisible(vehicle, true, false)
                        SetEntityVisible(ppedID, true, false)
                        SetEveryoneIgnorePlayer(ppedID, false)
                        SetEntityCollision(vehicle, true, true)
                        SetEntityCollision(ppedID, true, true)
                        TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Du hast den NoClip ausgeschaltet", 5000)
                        exports.nrp_Logs:createLog({
                            EmbedMessage = "Der Spieler **" .. GetPlayerName(playerID) .. "** mit der ID **" .. GetPlayerServerId(playerID) .. "** ist aus den Aduty-Noclip gegangen!",
                            player_id = source,
                            channel = "aduty",
                            screenshot = false
                        })
                    end
                end

                if noclip then
                    SetEntityVisible(vehicle, false, false)
                    NetworkFadeInEntity(vehicle, false, false, true)
                    SetEntityVisible(ppedID, false, false)
                    SetEveryoneIgnorePlayer(ppedID, true)
                    SetEntityCollision(vehicle, false, false)
                    SetEntityCollision(ppedID, false, false)

                    local isInVehicle = IsPedInAnyVehicle(ppedID, 0)
                    local k = nil
                    local x, y, z = nil

                    if not isInVehicle then
                        k = ppedID
                        x, y, z = table.unpack(GetEntityCoords(ppedID, 2))
                    else
                        k = GetVehiclePedIsIn(ppedID, 0)
                        x, y, z = table.unpack(GetEntityCoords(ppedID, 1))
                    end

                    local dx, dy, dz = GetCamDirection()

                    SetEntityVelocity(k, 0.0001, 0.0001, 0.0001)

                    if IsDisabledControlJustPressed(0, 21) then
                        oldSpeed = currentNoclipSpeed
                        currentNoclipSpeed = currentNoclipSpeed * NRP_Config.AdutyNoclipSpeedboost
                    end
                    if IsDisabledControlJustReleased(0, 21) then
                        currentNoclipSpeed = oldSpeed
                    end

                    if IsDisabledControlJustPressed(0, 36) then
                        oldSpeed = currentNoclipSpeed
                        currentNoclipSpeed = currentNoclipSpeed / NRP_Config.AdutyNoclipSpeedlower
                    end
                    if IsDisabledControlJustReleased(0, 36) then
                        currentNoclipSpeed = oldSpeed
                    end

                    if currentNoclipSpeed == nil then
                        currentNoclipSpeed = NRP_Config.AdutyNoclipSpeed
                    end
                    if IsDisabledControlPressed(0, 32) then
                        x = x + currentNoclipSpeed * dx
                        y = y + currentNoclipSpeed * dy
                        z = z + currentNoclipSpeed * dz
                    end

                    if IsDisabledControlPressed(0, 269) then
                        x = x - currentNoclipSpeed * dx
                        y = y - currentNoclipSpeed * dy
                        z = z - currentNoclipSpeed * dz
                    end

                    if IsDisabledControlPressed(0, 300) then
                        z = z + currentNoclipSpeed
                    end

                    if IsDisabledControlPressed(0, 299) then
                        z = z - currentNoclipSpeed
                    end

                    SetEntityCoordsNoOffset(k, x, y, z, true, true, true)
                else
                    if aduty then
                        SetEntityVisible(ppedID, true, false)
                    end
                end
            else
                Wait(1000)
            end
        end
    end)

    CreateThread(function()
        while true do
            Wait(0)
            if aduty then
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
    
                for _, player in ipairs(GetActivePlayers()) do
                    local targetPed = GetPlayerPed(player)
    
                    if targetPed ~= playerPed and IsEntityVisible(targetPed) then
                        local targetCoords = GetEntityCoords(targetPed)
                        local distance = #(playerCoords - targetCoords)
    
                        if distance <= NRP_Config.AdutyNametagDistance then
                            local headPos = GetPedBoneCoords(targetPed, SKEL_Head, 0, 0, 0)
                            local playerIsSpeaking = NetworkIsPlayerTalking(player)
                            local audioIcon = playerIsSpeaking and "🔊" or ""
                            local playerIsInVehicle = IsPedInAnyVehicle(targetPed)
                            local vehicleIcon = playerIsInVehicle and "🚖" or ""
                            local playerIsArmed = IsPedArmed(targetPed, 7)
                            local weaponIcon = playerIsArmed and "⚔️" or ""
                            local playerIsDead = IsEntityDead(targetPed)
                            local deadIcon = playerIsDead and "💀" or ""
                            local playerId = GetPlayerServerId(player)
                            local playerName = GetPlayerName(player)
                            local playerHealth = GetEntityHealth(targetPed) - 100
                            local playerArmor = GetPedArmour(targetPed)

    
                            DrawText3D(
                                headPos.x,
                                headPos.y,
                                headPos.z + 0.23,
                                "~g~" .. playerHealth .. " ~s~| ~b~" .. playerArmor,
                                255,
                                255,
                                255,
                                0.25
                            )
    
                            DrawText3D(
                                headPos.x,
                                headPos.y,
                                headPos.z + 0.3,
                                "[" .. playerId .. "] " .. playerName,
                                255,
                                255,
                                255,
                                0.25
                            )
    
                            DrawText3D(
                                headPos.x,
                                headPos.y,
                                headPos.z + 0.4,
                                audioIcon .. " " .. vehicleIcon .. " " .. weaponIcon .. " " .. deadIcon,
                                255,
                                255,
                                255,
                                0.2
                            )
                        end
                    end
                end
            else
                Wait(500)
            end
        end
    end)
    RegisterKeyMapping(NRP_Config.AdutyCommand, NRP_Config.AdutyText, 'keyboard', NRP_Config.AdutyDefaultKey)
end


-----{ / I D   C O M M A N D }-----
if NRP_Config.Id then
    RegisterCommand(NRP_Config.IdCommand, function(command,rawCommand)
        local playerId = PlayerId()
        local getPlayerServerId = GetPlayerServerId(playerId)
        TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Deine ID ist: "..(getPlayerServerId), 5000)
    end)
end


-----{ / I D S   C O M M A N D }-----
if NRP_Config.Ids then
    RegisterCommand(NRP_Config.IdsCommand, function(source, args, rawCommand)
        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        local getPlayerServerId = GetPlayerServerId(closestPlayer)
        if closestPlayer ~= -1 and closestDistance <= 8.0 then
            TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Spieler ID in deiner Nähe: ".. getPlayerServerId, 5000)
        else
            TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Keine Spieler in der Nähe!", 5000)
        end
    end)
end


-----{ E I N R E I S E   T E X T }-----
CreateThread(function()
    while NRP_Config.EinreiseText do
        Wait(1)
        found2 = false
        local playerPedId = PlayerPedId()
        local distance = GetDistanceBetweenCoords(GetEntityCoords(playerPedId), vector3(NRP_Config.EinreiseTextCoordsX, NRP_Config.EinreiseTextCoordsY, NRP_Config.EinreiseTextCoordsZ))
        if distance <= NRP_Config.EinreiseTextMarkerDrawDistance then
            DrawMarker(NRP_Config.EinreiseTextMarkerType, vector3(NRP_Config.EinreiseTextCoordsX, NRP_Config.EinreiseTextCoordsY, NRP_Config.EinreiseTextCoordsZ), 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, NRP_Config.EinreiseTextMarkerColorR, NRP_Config.EinreiseTextMarkerColorG, NRP_Config.EinreiseTextMarkerColorB, NRP_Config.EinreiseTextMarkerColorA, false, false, 2, true, false, false, false)
            found2 = true
            if distance <= 1.5 then
                ESX.ShowHelpNotification(NRP_Config.EinreiseText1)
                Wait(NRP_Config.EinreiseTextChangeDuration * 1000)
                ESX.ShowHelpNotification(NRP_Config.EinreiseText2)
                Wait(NRP_Config.EinreiseTextChangeDuration * 1000)
                ESX.ShowHelpNotification(NRP_Config.EinreiseText3)
                Wait(NRP_Config.EinreiseTextChangeDuration * 1000)
            end
        end
        if not found2 then 
            Wait(NRP_Config.EinreiseTextChangeDuration * 1000)
        end
    end
end)


-----{ / C A R R Y   C O M M A N D }-----
if NRP_Config.Carry then
    local carry = {
	    InProgress = false,
	    targetSrc = -1,
	    type = "",
	    personCarrying = {
		    animDict = NRP_Config.CarryAnimation,
		    anim = NRP_Config.CarryAnimation2,
		    flag = 49,
	    },
	    personCarried = {
		    animDict = "nm",
		    anim = NRP_Config.CarryAnimation3,
		    attachX = 0.27,
		    attachY = 0.15,
		    attachZ = 0.63,
		    flag = 33,
	    }
    }

    local function GetClosestPlayer(radius)
        local players = GetActivePlayers()
        local closestDistance = -1
        local closestPlayer = -1
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _,playerId in ipairs(players) do
            local targetPed = GetPlayerPed(playerId)
            if targetPed ~= playerPed then
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(targetCoords-playerCoords)
                if closestDistance == -1 or closestDistance > distance then
                    closestPlayer = playerId
                    closestDistance = distance
                end
            end
        end
	    if closestDistance ~= -1 and closestDistance <= radius then
		    return closestPlayer
	    else
		    return nil
	    end
    end

    local function ensureAnimDict(animDict)
        if not HasAnimDictLoaded(animDict) then
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do
                Wait(0)
            end        
        end
        return animDict
    end

    local carryCooldown = NRP_Config.CarryCooldownTime  * 1000
    local lastCarryTime = 0

    RegisterCommand(NRP_Config.CarryCommand, function(source, args)
    local currentTime = GetGameTimer()
    if (currentTime - lastCarryTime) < carryCooldown then
        TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du musst noch " .. math.ceil((carryCooldown - (currentTime - lastCarryTime)) / 1000) .. " Sekunden warten, bevor du wieder tragen kannst!", 5000)
        return
    end
    
    lastCarryTime = currentTime
    local playerPed = PlayerPedId()
    
        if not IsEntityDead(playerPed) then
            if not carry.InProgress then
                local closestPlayer = GetClosestPlayer(3)
                if closestPlayer then
                    local targetSrc = GetPlayerServerId(closestPlayer)
                    if targetSrc ~= -1 then
                        carry.InProgress = true
                        carry.targetSrc = targetSrc
                        TriggerServerEvent("nrp_Core:carry:sync",targetSrc)
                        ensureAnimDict(carry.personCarrying.animDict)
                        carry.type = "carrying"
                    else
                        TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Niemand in der Nähe zum tragen!", 5000)
                    end
                else
                    TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Niemand in der Nähe zum tragen!", 5000)
                end
            else
                carry.InProgress = false
                ClearPedSecondaryTask(playerPed)
                DetachEntity(playerPed, true, false)
                TriggerServerEvent("nrp_Core:carry:stop",carry.targetSrc)
                carry.targetSrc = 0
            end
        else
            TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du kannst niemanden tragen wenn du tot bist!", 5000)
        end
    end, false)


    RegisterNetEvent("nrp_Core:carry:synctarget")
    AddEventHandler("nrp_Core:carry:synctarget", function(targetSrc)
	    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
	    carry.InProgress = true
	    ensureAnimDict(carry.personCarried.animDict)
	    AttachEntityToEntity(playerPed, targetPed, 0, carry.personCarried.attachX, carry.personCarried.attachY, carry.personCarried.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)
	    carry.type = "beingcarried"
    end)

    RegisterNetEvent("nrp_Core:carry:clientstop")
    AddEventHandler("nrp_Core:carry:clientstop", function()
	    carry.InProgress = false
	    ClearPedSecondaryTask(playerPed)
	    DetachEntity(playerPed, true, false)
    end)

    CreateThread(function()
	    while true do
		    if carry.InProgress then
			    if carry.type == "beingcarried" then
				    if not IsEntityPlayingAnim(playerPed, carry.personCarried.animDict, carry.personCarried.anim, 3) then
					    TaskPlayAnim(playerPed, carry.personCarried.animDict, carry.personCarried.anim, 8.0, -8.0, 100000, carry.personCarried.flag, 0, false, false, false)
				    end
			    elseif carry.type == "carrying" then
				    if not IsEntityPlayingAnim(playerPed, carry.personCarrying.animDict, carry.personCarrying.anim, 3) then
					    TaskPlayAnim(playerPed, carry.personCarrying.animDict, carry.personCarrying.anim, 8.0, -8.0, 100000, carry.personCarrying.flag, 0, false, false, false)
				    end
			    end
		    end
		    Wait(0)
	    end
    end)
end


-----{ / T A K E H O S T A G E   C O M M A N D }-----
if NRP_Config.Takehostage then
    local takeHostage = {
	    allowedWeapons = NRP_Config.TakehostageWeapons,
	    InProgress = false,
	    type = "",
	    targetSrc = -1,
	    agressor = {
		    animDict = NRP_Config.TakehostageAnimation,
		    anim = NRP_Config.TakehostageAnimation2,
		    flag = 49,
	    },
	    hostage = {
		    animDict = NRP_Config.TakehostageAnimation,
		    anim = NRP_Config.TakehostageAnimation3,
		    attachX = -0.24,
		    attachY = 0.11,
		    attachZ = 0.0,
		    flag = 49,
	    }
    }

    local function GetClosestPlayer(radius)
        local players = GetActivePlayers()
        local closestDistance = -1
        local closestPlayer = -1
        local playerpedid = PlayerPedId()
        local playerCoords = GetEntityCoords(playerpedid)

        for _,playerId in ipairs(players) do
            local targetPed = GetPlayerPed(playerId)
            if targetPed ~= playerpedid then
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(targetCoords-playerCoords)
                if closestDistance == -1 or closestDistance > distance then
                    closestPlayer = playerId
                    closestDistance = distance
                end
            end
        end
	    if closestDistance ~= -1 and closestDistance <= radius then
		    return closestPlayer
	    else
		    return nil
	    end
    end

    local function ensureAnimDict(animDict)
        if not HasAnimDictLoaded(animDict) then
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do
                Wait(0)
            end        
        end
        return animDict
    end

    local function drawNativeText(str)
	    SetTextEntry_2("STRING")
	    AddTextComponentString(str)
	    EndTextCommandPrint(1000, 1)
    end

    RegisterCommand(NRP_Config.TakehostageCommand,function()
	    callTakeHostage()
    end)

    function callTakeHostage()
        local playerpedid = PlayerPedId()
        ClearPedSecondaryTask(playerpedid)
        DetachEntity(playerpedid, true, false)

        local canTakeHostage = false
        for i=1, #takeHostage.allowedWeapons do
            if HasPedGotWeapon(playerpedid, takeHostage.allowedWeapons[i], false) then
                if GetAmmoInPedWeapon(playerpedid, takeHostage.allowedWeapons[i]) > 0 then
                    canTakeHostage = true 
                    foundWeapon = takeHostage.allowedWeapons[i]
                    break
                end 					
            end
        end

        if not canTakeHostage then
            TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du brauchst eine Waffe, um jemanden als Geisel zu nehmen!", 5000)
        end

        if not takeHostage.InProgress and canTakeHostage then
            local closestPlayer = GetClosestPlayer(3)
            if closestPlayer then
                local targetSrc = GetPlayerServerId(closestPlayer)
                if targetSrc ~= -1 then
                    SetCurrentPedWeapon(playerpedid, foundWeapon, true)
                    takeHostage.InProgress = true
                    takeHostage.targetSrc = targetSrc
                    TriggerServerEvent("nrp_Core:takehostage:sync", targetSrc)
                    ensureAnimDict(takeHostage.agressor.animDict)
                    takeHostage.type = "agressor"
                else
                    TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Keine Person in der Nähe!", 5000)
                end
            else
                TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Keine Person in der Nähe!", 5000)
            end
        end
    end

    local playerpedid = PlayerPedId()

    RegisterNetEvent("nrp_Core:takehostage:synctarget")
    AddEventHandler("nrp_Core:takehostage:synctarget", function(target)
	    local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	    takeHostage.InProgress = true
	    ensureAnimDict(takeHostage.hostage.animDict)
	    AttachEntityToEntity(playerpedid, targetPed, 0, takeHostage.hostage.attachX, takeHostage.hostage.attachY, takeHostage.hostage.attachZ, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
	    takeHostage.type = "hostage" 
    end)

    RegisterNetEvent("nrp_Core:takehostage:releasehostage")
    AddEventHandler("nrp_Core:takehostage:releasehostage", function()
	    takeHostage.InProgress = false 
	    takeHostage.type = ""
	    DetachEntity(playerpedid, true, false)
	    ensureAnimDict("reaction@shove")
	    TaskPlayAnim(playerpedid, "reaction@shove", "shoved_back", 8.0, -8.0, -1, 0, 0, false, false, false)
	    Wait(250)
	    ClearPedSecondaryTask(playerpedid)
    end)

    RegisterNetEvent("nrp_Core:takehostage:killhostage")
    AddEventHandler("nrp_Core:takehostage:killhostage", function()
	    takeHostage.InProgress = false 
	    takeHostage.type = ""
	    SetEntityHealth(playerpedid,0)
	    DetachEntity(playerpedid, true, false)
	    ensureAnimDict("anim@gangops@hostage@")
	    TaskPlayAnim(playerpedid, "anim@gangops@hostage@", "victim_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
    end)

    RegisterNetEvent("nrp_Core:takehostage:clientstop")
    AddEventHandler("nrp_Core:takehostage:clientstop", function()
	    takeHostage.InProgress = false
	    takeHostage.type = "" 
	    ClearPedSecondaryTask(playerpedid)
	    DetachEntity(playerpedid, true, false)
    end)

    CreateThread(function()
	    while true do
		    if takeHostage.type == "agressor" then
			    if not IsEntityPlayingAnim(playerpedid, takeHostage.agressor.animDict, takeHostage.agressor.anim, 3) then
				    TaskPlayAnim(playerpedid, takeHostage.agressor.animDict, takeHostage.agressor.anim, 8.0, -8.0, 100000, takeHostage.agressor.flag, 0, false, false, false)
			    end
		    elseif takeHostage.type == "hostage" then
			    if not IsEntityPlayingAnim(playerpedid, takeHostage.hostage.animDict, takeHostage.hostage.anim, 3) then
				    TaskPlayAnim(playerpedid, takeHostage.hostage.animDict, takeHostage.hostage.anim, 8.0, -8.0, 100000, takeHostage.hostage.flag, 0, false, false, false)
			    end
		    end
		    Wait(0)
	    end
    end)

    CreateThread(function()
	    while true do 
            local playerpedid = PlayerPedId()
		    if takeHostage.type == "agressor" then
			    DisableControlAction(0, 21, true)
			    DisableControlAction(0, 24, true)
			    DisableControlAction(0, 25, true)
			    DisableControlAction(0, 47, true)
			    DisableControlAction(0, 58, true)
			    DisablePlayerFiring(playerpedid, true)
			    drawNativeText(NRP_Config.TakehostageText)

			    if IsEntityDead(playerpedid) then	
				    takeHostage.type = ""
				    takeHostage.InProgress = false
				    ensureAnimDict("reaction@shove")
				    TaskPlayAnim(playerpedid, "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
				    TriggerServerEvent("nrp_Core:takehostage:releasehostage", takeHostage.targetSrc)
			    end 

			    if IsDisabledControlJustPressed(0, NRP_Config.TakehostageReleaseKey) then	
				    takeHostage.type = ""
				    takeHostage.InProgress = false 
				    ensureAnimDict("reaction@shove")
				    TaskPlayAnim(playerpedid, "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
				    TriggerServerEvent("nrp_Core:takehostage:releasehostage", takeHostage.targetSrc)
			    elseif IsDisabledControlJustPressed(0, NRP_Config.TakehostageKillKey) then		
				    takeHostage.type = ""
				    takeHostage.InProgress = false 		
				    ensureAnimDict("anim@gangops@hostage@")
				    TaskPlayAnim(playerpedid, "anim@gangops@hostage@", "perp_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
				    TriggerServerEvent("nrp_Core:takehostage:killhostage", takeHostage.targetSrc)
				    TriggerServerEvent("nrp_Core:takehostage:stop",takeHostage.targetSrc)
				    Wait(100)
				    SetPedShootsAtCoord(playerpedid, 0.0, 0.0, 0.0, 0)
			    end
		    elseif takeHostage.type == "hostage" then 
			    DisableControlAction(0, 21, true)
			    DisableControlAction(0, 22, true)
			    DisableControlAction(0, 24, true)
			    DisableControlAction(0, 25, true)
			    DisableControlAction(0, 32, true)
			    DisableControlAction(0, 33, true)
			    DisableControlAction(0, 34, true)
			    DisableControlAction(0, 35, true)
			    DisableControlAction(0, 47, true)
			    DisableControlAction(0, 58, true)
			    DisableControlAction(0, 75, true)
			    DisableControlAction(0, 140, true)
			    DisableControlAction(0, 141, true)
			    DisableControlAction(0, 142, true)
			    DisableControlAction(0, 143, true)
			    DisableControlAction(0, 170, true)
			    DisableControlAction(0, 257, true)
			    DisableControlAction(0, 263, true)
			    DisableControlAction(0, 264, true)
			    DisableControlAction(0, 268, true)
			    DisableControlAction(0, 269, true)
			    DisableControlAction(0, 270, true)
			    DisableControlAction(0, 271, true)
		    end
		    Wait(0)
	    end
    end)
end


-----{ S N O W }-----
CreateThread(function()
    if NRP_Config.Snow then
        SetWeatherTypePersist("xmas")
        SetWeatherTypeNowPersist("xmas")
        SetWeatherTypeNow("xmas")
        SetOverrideWeather("xmas")
        ForceSnowPass(true)
        SetForceVehicleTrails(true)
        SetForcePedFootstepsTracks(true)
        SetForcePedFootstepsTracks(true)
    end
end)


-----{ P O I N T   F I N G E R }-----
if NRP_Config.PointFinger then
    RegisterCommand(NRP_Config.PointFingerCommand, function()
        local ped = PlayerPedId()
        local anim = 'anim@mp_point'
        local dict = 'task_mp_pointing'
        repeat RequestAnimDict(anim) Wait(0)
        until HasAnimDictLoaded(anim)
        TaskMoveNetworkByName(ped, dict, 0.5, 0, anim, 24)
        RemoveAnimDict(anim)
        while IsControlPressed(0, 29) do
            SetTaskMoveNetworkSignalFloat(ped, 'Pitch', (GetGameplayCamRelativePitch() + 70) / 110)
            SetTaskMoveNetworkSignalFloat(ped, 'Heading', (GetGameplayCamRelativeHeading() + 180) / 360 * -1.0 + 1.0)
            Wait(25)
        end
        RequestTaskMoveNetworkStateTransition(ped, 'Stop')
        ClearPedSecondaryTask(ped)
    end)
    
    RegisterKeyMapping(NRP_Config.PointFingerCommand, NRP_Config.PointFingerText, 'keyboard', NRP_Config.PointFingerKey)
end


-----{ S N E A K E N }-----
if NRP_Config.Sneaken then
    Crouched = false
    CrouchedForce = false
    Aimed = false
    LastCam = 0
    
    NormalWalk = function() 
        local Player = PlayerPedId()
        SetPedMaxMoveBlendRatio(Player, 1.0)
        ResetPedMovementClipset(Player, 0.55)
        ResetPedStrafeClipset(Player)
        SetPedCanPlayAmbientAnims(Player, true)
        SetPedCanPlayAmbientBaseAnims(Player, true)
        ResetPedWeaponMovementClipset(Player)
        Crouched = false
    end
    
    SetupCrouch = function()
        while not HasAnimSetLoaded('move_ped_crouched') do
            Wait(5)
            RequestAnimSet('move_ped_crouched')
        end
    end
    
    RemoveCrouchAnim = function()
        RemoveAnimDict('move_ped_crouched')
    end
    
    CanCrouch = function()
        local PlayerPed = PlayerPedId()
        if IsPedOnFoot(PlayerPed) and not IsPedJumping(PlayerPed) and not IsPedFalling(PlayerPed) and not IsPedDeadOrDying(PlayerPed) then
            return true
        else
            return false
        end
    end
    
    CrouchPlayer = function()
        local Player = PlayerPedId()
        SetPedUsingActionMode(Player, false, -1, "DEFAULT_ACTION")
        SetPedMovementClipset(Player, 'move_ped_crouched', 0.55)
        SetPedStrafeClipset(Player, 'move_ped_crouched_strafing')
        SetWeaponAnimationOverride(Player, "Ballistic")
        Crouched = true
        Aimed = false
    end
    
    SetPlayerAimSpeed = function()
        local Player = PlayerPedId()
        SetPedMaxMoveBlendRatio(Player, 0.2)
        Aimed = true
    end
    
    CrouchLoop = function()
        SetupCrouch()
        while CrouchedForce do
            local CanDo = CanCrouch()
            if CanDo and Crouched then
                SetPlayerAimSpeed()
            elseif CanDo and (not Crouched or Aimed) then
                CrouchPlayer()
            elseif not CanDo and Crouched then
                CrouchedForce = false
                NormalWalk()
            end
    
            local NowCam = GetFollowPedCamViewMode()
            if CanDo and Crouched and NowCam == 4 then
                SetFollowPedCamViewMode(LastCam)
            elseif CanDo and Crouched and NowCam ~= 4 then
                LastCam = NowCam
            end
    
            Wait(100)
        end
        NormalWalk()
        RemoveCrouchAnim()
    end
    
    RegisterCommand('crouch', function()
        DisableControlAction(0, 36, true)
        local playerPed = PlayerPedId()
        local isInAnyVehicle = IsPedInAnyVehicle(playerPed, true)
        if not isInAnyVehicle then
            CrouchedForce = not CrouchedForce
    
            if CrouchedForce then
                CreateThread(CrouchLoop)
            end
        end
    end, false)
    
    RegisterKeyMapping('crouch', 'Schleichen', 'keyboard', 'LCONTROL')
end


-----{ R E M O V E   H E A L T H B A R   A N D   A R M O R B A R }-----
CreateThread(function()
    if NRP_Config.RemoveHealthbarAndArmorbar then
        local minimap = RequestScaleformMovie("minimap")
        local bar = "SETUP_HEALTH_ARMOUR"
        SetRadarBigmapEnabled(true, false)
        Wait(0)
        SetRadarBigmapEnabled(false, false)
        Wait(0)
        BeginScaleformMovieMethod(minimap, bar)
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)


-----{ N O   W E A P O N W H E E L }-----
CreateThread(function()
    while NRP_Config.NoWeaponwheel do
        Wait(0)
        BlockWeaponWheelThisFrame()
        DisableControlAction(0, 37, true)
    end
end)


-----{ T A Z E R E F F E C T }-----
if NRP_Config.Tazereffect then
    local isTazed = false
    CreateThread(function()
        while true do
            Wait(0)
            local playerPedId = PlayerPedId()

            if IsPedBeingStunned(playerPedId) then
                SetPedToRagdoll(playerPedId, 5000, 5000, 0, 0, 0, 0)
            end

            if IsPedBeingStunned(playerPedId) and not isTazed then
                isTazed = true
                SetTimecycleModifier("REDMIST_blend")
                ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 1.0)
            elseif not IsPedBeingStunned(playerPedId) and isTazed then
                isTazed = false
                Wait(5000)
                SetTimecycleModifier("hud_def_desat_Trevor")
                Wait(10000)
                SetTimecycleModifier("")
                SetTransitionTimecycleModifier("")
                StopGameplayCamShaking()
            end
        end
    end)
end


-----{ D R I F T M O D E }-----
if NRP_Config.Driftmode then
    local vehicleClassWhitelist = NRP_Config.DriftmodeVehicles

    local handleMods = {
	    {"fInitialDragCoeff", 90.22},
	    {"fDriveInertia", 0.31},
	    {"fSteeringLock", 22},
	    {"fTractionCurveMax", -1.1},
	    {"fTractionCurveMin", -0.4},
	    {"fTractionCurveLateral", 2.5},
	    {"fLowSpeedTractionLossMult", -0.57}
    }

    local ped, vehicle
    local driftMode = false

    CreateThread( function()
	    while true do
		    Wait(1)
		    ped = PlayerPedId()

		    if IsPedInAnyVehicle(ped) then
			    tmpvehicle = GetVehiclePedIsIn(ped, false)
			    if not(vehicle == tmpvehicle) then
				    if driftMode then
					    ToggleDrift()
				    end
				    vehicle = tmpvehicle
			    end
			    if (GetPedInVehicleSeat(vehicle, -1) == ped) and IsVehicleOnAllWheels(vehicle) and IsControlJustReleased(0, NRP_Config.DriftmodeKey) and IsVehicleClassWhitelisted(GetVehicleClass(vehicle)) then
				    ToggleDrift()
			    end
		    end
	    end
    end)

    function ToggleDrift()
	    local modifier = 1
	    if driftMode then
		    modifier = -1
	    end
	
	    for index, value in ipairs(handleMods) do
		    SetVehicleHandlingFloat(vehicle, "CHandlingData", value[1], GetVehicleHandlingFloat(vehicle, "CHandlingData", value[1]) + value[2] * modifier)
	    end
	
	    if driftMode then
		    SetVehicleEnginePowerMultiplier(vehicle, 0.0)
            TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Driftmodus deaktiviert", 5000)
	    else
		    if GetHandlingfDriveBiasFront == 0.0 then
			    SetVehicleEnginePowerMultiplier(vehicle, 190.0)
		    else
			    SetVehicleEnginePowerMultiplier(vehicle, 100.0)
		    end
            TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Driftmodus aktiviert", 5000)
	    end
	
	    driftMode = not(driftMode)
    end

    function IsVehicleClassWhitelisted(vehicleClass)
	    for index, value in ipairs(vehicleClassWhitelist) do
		    if value == vehicleClass then
			    return true
		    end
	    end

	    return false
    end
end


-----{ R E S T R I C T E D   Z O N E }-----
if NRP_Config.RestrictedZone then
    BlipRadius = NRP_Config.RestrictedZoneRadius
    BlipFarbe = NRP_Config.RestrictedZoneBlipColor
    Blip = "Sperrzone"

    local Blip = nil
    local BlipRadius2 = nil

    RegisterNetEvent("nrp_Core:SperrzoneErstellen")
    AddEventHandler("nrp_Core:SperrzoneErstellen", function(s, lspdRadius)
        RemoveBlip(Blip)
        RemoveBlip(BlipRadius2)

        if lspdRadius == nil then
            lspdRadius = BlipRadius
        end

        local src = s
        local coords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(src)))
        Blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        BlipRadius2 = AddBlipForRadius(coords.x, coords.y, coords.z, lspdRadius)
        SetBlipSprite(Blip, 161)
        SetBlipAsShortRange(Blip, true)
        SetBlipColour(Blip, BlipFarbe)
        SetBlipScale(Blip, 1.0)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(NRP_Config.RestrictedZoneBlipName)
        EndTextCommandSetBlipName(Blip)

        SetBlipAlpha(BlipRadius2, NRP_Config.RestrictedZoneBlipAlpha)
        SetBlipColour(BlipRadius2, BlipFarbe)

    end)

    RegisterNetEvent('nrp_Core:SperrzoneEntfernen')
    AddEventHandler("nrp_Core:SperrzoneEntfernen", function()
        RemoveBlip(Blip)
        RemoveBlip(BlipRadius2)
    end)
end


-----{ I N F I N I T Y   A M M O }-----
CreateThread(function()
    while NRP_Config.InfinityAmmo do
        Wait(0)
        if IsPedArmed(ped, 6) then
            local playerPedId = PlayerPedId()
            SetPedInfiniteAmmo(playerPedId, true)
        end
    end
end)


-----{ N O   R E L O A D }-----
CreateThread(function()
    while NRP_Config.NoReload do
        Wait(0)
        if IsPedArmed(ped, 6) then
            local playerPedId = PlayerPedId()
            SetPedInfiniteAmmoClip(playerPedId, true)
        end
    end
end)


-----{ A M M O   C L I P }-----
if NRP_Config.AmmoClip then
    RegisterNetEvent('nrp_Core:reloadmagazin')
    AddEventHandler('nrp_Core:reloadmagazin', function()
    local ped = PlayerPedId()
    if IsPedArmed(ped, 6) then
        hash=GetSelectedPedWeapon(ped)
        if hash~=nil then
            TriggerServerEvent('nrp_Core:removemagazin')
            AddAmmoToPed(ped, hash, NRP_Config.AmmoClipAmmount)
        else
            TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du hast keine Waffe in der Hand!", 5000)
        end
        else
            TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du hast keine Waffe in der Hand!", 5000)
        end
    end)
end


-----{ S A F E   H E A L T H   A N D   A R M O R }-----
if NRP_Config.SafeHealthAndArmor then
    CreateThread(function()
        while true do
            Wait(0)
            local playerPed = PlayerPedId()
            local playerid = PlayerId()
            if playerPed ~= -1 then
                if NetworkIsPlayerActive(playerid) then
                    Wait(7500)
                    TriggerServerEvent("nrp_Core:loadData")
                    break
                end
            end
        end
    end)

    RegisterNetEvent('nrp_Core:setData')
    AddEventHandler('nrp_Core:setData', function(data)
        local playerPed = PlayerPedId()
        local health = SetEntityHealth(playerPed, data.Health)
        local armour = SetPedArmour(playerPed, data.Armour)
    end)
end


-----{ R E P A I R K I T }-----
if NRP_Config.Repairkit then
    RegisterNetEvent('nrp_Core:repairkit:onUse')
    AddEventHandler('nrp_Core:repairkit:onUse', function()
        local playerPed		= PlayerPedId()
        local coords		= GetEntityCoords(playerPed)
  
        if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then

            if IsPedInAnyVehicle(playerPed, false) then
                vehicle = GetVehiclePedIsIn(playerPed, false)
            else
                vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71)
            end
  
            if DoesEntityExist(vehicle) then
                TriggerServerEvent('nrp_Core:repairkit:removeKit')
                TaskStartScenarioInPlace(playerPed, NRP_Config.RepairkitAnimation, 0, true)
  
                CreateThread(function()
                    CurrentAction = 'repair'
  
                    NRP_Config.Progressbar(NRP_Config.RepairkitTime * 1000)
                    Wait(NRP_Config.RepairkitTime * 1000)
  
                    if CurrentAction ~= nil then
                        SetVehicleFixed(vehicle)
                        SetVehicleDeformationFixed(vehicle)
                        SetVehicleUndriveable(vehicle, false)
                        SetVehicleOnGroundProperly(vehicle)
                        SetVehicleBodyHealth(vehicle, 1000)
                        ClearPedTasksImmediately(playerPed)
                    end
  
                    TriggerServerEvent('nrp_Core:repairkit:removeKit')
  
                    CurrentAction = nil
                end)
            end
        else
            TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Kein Fahrzeug in der Nähe!", 5000)
        end
    end)
end


-----{ W A S H K I T }-----
if NRP_Config.Washkit then
    RegisterNetEvent('nrp_Core:washkit:onUse')
    AddEventHandler('nrp_Core:washkit:onUse', function()
        local playerPed		= PlayerPedId()
        local coords		= GetEntityCoords(playerPed)
  
        if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
  
            if IsPedInAnyVehicle(playerPed, false) then
                vehicle = GetVehiclePedIsIn(playerPed, false)
            else
                vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71)
            end
  
            if DoesEntityExist(vehicle) then
                TriggerServerEvent('nrp_Core:washkit:removeKit')
                TaskStartScenarioInPlace(playerPed, NRP_Config.WashkitAnimation, 0, true)
  
                CreateThread(function()
                    CurrentAction = 'wash'
  
                    NRP_Config.Progressbar(NRP_Config.WashkitTime * 1000)
                    Wait(NRP_Config.WashkitTime * 1000)
  
                    if CurrentAction ~= nil then
                        SetVehicleDirtLevel(vehicle, 0)
                        RemoveDecalsFromVehicle(vehicle)
                        ClearPedTasksImmediately(playerPed)
                    end
  
                    TriggerServerEvent('nrp_Core:washkit:removeKit')
  
                    CurrentAction = nil
                end)
            end
        else
            TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Kein Fahrzeug in der Nähe!", 5000)
        end
    end)
end


-----{ B L I P S }-----
if NRP_Config.Blips then
    local blips = NRP_Config.BlipsList

    CreateThread(function()
        for _, info in pairs(blips) do
            info.blip = AddBlipForCoord(info.x, info.y, info.z)
            SetBlipSprite(info.blip, info.id)
            SetBlipDisplay(info.blip, 2)
            SetBlipScale(info.blip, info.size)
            SetBlipColour(info.blip, info.color)
            SetBlipFlashes(info.blip, info.flashing)
            SetBlipAsShortRange(info.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(info.title)
            EndTextCommandSetBlipName(info.blip)
        end
    end)
end


-----{ N O   M I N I M A P   O N   F O O T }-----
CreateThread(function()
    while NRP_Config.NoMinimapOnFoot do 
        Wait(0)
        local playerPedId = PlayerPedId()
        if IsPedInAnyVehicle(playerPedId, true) then 
            DisplayRadar(true)
            Wait(500)
        else
            DisplayRadar(false)
        end
    end
end)


-----{ / S T R E A M E R M O D E   C O M M A N D }-----
local streamermode = false

if NRP_Config.Streamermode then
    RegisterCommand(NRP_Config.StreamermodeCommand, function(source)
        streamermode = not streamermode
        if streamermode then
            SetTimecycleModifier("cinema")
            SetForceVehicleTrails(false)
            SetForcePedFootstepsTracks(false)
            ClearFocus()
            ClearHdArea()
            DisplayRadar(false)
            TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Streamermodus aktiviert", 5000)
        else
            SetTimecycleModifier("default")
            DisplayRadar(true)
            TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Streamermodus deaktiviert", 5000)
        end
    end)
end


-----{ C A B L E T I E   A N D   S C I S S O R S }-----
if NRP_Config.CabletieAndScissors then
    local IsHandcuffed2 = false

    RegisterNetEvent("nrp_Core:checkCuff")
    AddEventHandler("nrp_Core:checkCuff", function()
        local player, distance = ESX.Game.GetClosestPlayer()
        if distance~=-1 and distance<=NRP_Config.CabletieAndScissorsDistance then
            ESX.TriggerServerCallback("nrp_Core:isCuffed",function(cuffed)
                if not cuffed2 then
                    TriggerServerEvent("nrp_Core:handcuff",GetPlayerServerId(player),true)
                else
                    TriggerServerEvent("nrp_Core:handcuff",GetPlayerServerId(player),false)
                end
            end,GetPlayerServerId(player))
        else
            TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Keine Spieler in der Nähe!", 5000)
        end
    end)

    RegisterNetEvent("nrp_Core:uncuff")
    AddEventHandler("nrp_Core:uncuff",function()
        local player, distance = ESX.Game.GetClosestPlayer()
        if distance~=-1 and distance<=NRP_Config.CabletieAndScissorsDistance then
            TriggerServerEvent("nrp_Core:uncuff",GetPlayerServerId(player))
        else
            TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Keine Spieler in der Nähe!", 5000)
        end
    end)

    RegisterNetEvent('nrp_Core:forceUncuff')
    AddEventHandler('nrp_Core:forceUncuff',function()
        IsHandcuffed2 = false
        local playerPed = PlayerPedId()
        ClearPedSecondaryTask(playerPed)
        SetEnableHandcuffs(playerPed, false)
        DisablePlayerFiring(playerPed, false)
        SetPedCanPlayGestureAnims(playerPed, true)
        FreezeEntityPosition(playerPed, false)
        DisplayRadar(true)
    end)

    RegisterNetEvent("nrp_Core:handcuff")
    AddEventHandler("nrp_Core:handcuff",function()
        local playerPed = PlayerPedId()
        IsHandcuffed2 = not IsHandcuffed2
        CreateThread(function()
            if IsHandcuffed2 then
                ClearPedTasks(playerPed)
                SetPedCanPlayAmbientBaseAnims(playerPed, true)

                Wait(10)
                RequestAnimDict('anim@move_m@prisoner_cuffed')
                while not HasAnimDictLoaded('anim@move_m@prisoner_cuffed') do
                    Wait(0)
                end
			    Wait(0)
                TaskPlayAnim(playerPed, 'anim@move_m@prisoner_cuffed', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)

                SetEnableHandcuffs(playerPed, true)
                DisablePlayerFiring(playerPed, true)
                SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
                SetPedCanPlayGestureAnims(playerPed, false)
                DisplayRadar(false)
            end
        end)
    end)

    CreateThread(function()
        while true do
            Wait(0)
            local playerPed = PlayerPedId()
            if IsHandcuffed2 then
                SetEnableHandcuffs(playerPed, true)
                DisablePlayerFiring(playerPed, true)
                SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
                SetPedCanPlayGestureAnims(playerPed, false)
                DisplayRadar(false)
			    DisableControlAction(0, 2, true)
			    DisableControlAction(0, 22, true)
			    DisableControlAction(0, 24, true)
			    DisableControlAction(0, 37, true)
			    DisableControlAction(0, 44, true)
			    DisableControlAction(0, 45, true)
			    DisableControlAction(0, 47, true)
			    DisableControlAction(0, 69, true)
			    DisableControlAction(0, 70, true)
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 142, true)
			    DisableControlAction(0, 257, true)
			    DisableControlAction(0, 263, true)
			    DisableControlAction(0, 264, true)
            end
            if not IsHandcuffed2 and not IsControlEnabled(0, 140) then EnableControlAction(0, 140, true)  end
            if not IsHandcuffed2 and not IsControlEnabled(0, 74) then EnableControlAction(0, 74, true)  end
        end
    end)
end


-----{ N O   D R I V E B Y }-----
CreateThread(function()
    local playerId = PlayerId()
    local getPlayerPed = PlayerPedId()
    while NRP_Config.NoDriveby and IsPedInAnyVehicle(getPlayerPed, false) do
        Wait(10)
        SetPlayerCanDoDriveBy(playerId, false)
    end
end)


-----{ P E D }-----
if NRP_Config.Ped then
    local peds = NRP_Config.PedList

    CreateThread(function()
        for _,v in pairs(peds) do
            RequestModel(GetHashKey(v[7]))
            while not HasModelLoaded(GetHashKey(v[7])) do
                Wait(100)
            end
  
            ped = CreatePed(4, v[6],v[1],v[2],v[3], 3374176, false, true)
            SetEntityHeading(ped, v[5])
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetEntityProofs(ped, true, true, true, true, true, true, true, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            TaskStartScenarioInPlace(ped, v[8], 0, true)
        end
    end)
end


-----{ S A F E Z O N E }-----
if NRP_Config.Safezone then
    local SafezoneIn = false
    local SafezoneOut = false
    local closestZone = 1

    CreateThread(function()
        for i = 1, #NRP_Config.SafezoneZones, 1 do
            local blip = AddBlipForRadius(NRP_Config.SafezoneZones[i].x, NRP_Config.SafezoneZones[i].y, NRP_Config.SafezoneZones[i].z, NRP_Config.SafezoneRadius)
            SetBlipAlpha (blip, NRP_Config.SafezoneBlipAlpha)
            SetBlipColour (blip, NRP_Config.SafezoneBlipColor)
        end
    end)

    CreateThread(function()
        while true do
            local playerPed = PlayerPedId()
            local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
            local minDistance = -1
            Wait(1)
            for i = 1, #NRP_Config.SafezoneZones, 1 do
                dist = Vdist(NRP_Config.SafezoneZones[i].x, NRP_Config.SafezoneZones[i].y, NRP_Config.SafezoneZones[i].z, x, y, z)
                if dist < minDistance then
                    minDistance = dist
                    closestZone = i
                end
            end
            if NRP_Config.SafezoneMarker then
                DrawMarker(1, NRP_Config.SafezoneZones[closestZone].x +1.5, NRP_Config.SafezoneZones[closestZone].y +1.5, NRP_Config.SafezoneZones[closestZone].z-16.0001, 0, 0, 0, 0, 0, 0, 100.0, 100.0, 120.0, NRP_Config.SafezoneMarkerColorR, NRP_Config.SafezoneMarkerColorG, NRP_Config.SafezoneMarkerColorB, NRP_Config.SafezoneMarkerAlpha, 0, 0, 2, 0, 0, 0, 0)
            end
        end
    end)

    CreateThread(function()
        while true do
            local player = PlayerPedId()
            local x,y,z = table.unpack(GetEntityCoords(player, true))
            local dist = Vdist(NRP_Config.SafezoneZones[closestZone].x, NRP_Config.SafezoneZones[closestZone].y, NRP_Config.SafezoneZones[closestZone].z, x, y, z)
            local vehicle = GetVehiclePedIsIn(player, false)
            local playerId = PlayerId()

            if dist <= NRP_Config.SafezoneRadius then
                if not SafezoneIn then
                    NetworkSetFriendlyFireOption(false)
                    SetEntityCanBeDamaged(vehicle, false)
                    SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
                    if NRP_Config.SafezoneSound then
                        PlaySoundFrontend(-1, NRP_Config.SafezoneSoundName, "HUD_MINI_GAME_SOUNDSET", true)
                    end
                    if NRP_Config.SafezoneEffect then
                        SetTimecycleModifier(NRP_Config.SafezoneEffectName)
                        Wait(NRP_Config.SafezoneEffectDuration)
	                    ClearTimecycleModifier()
                    end
                    if NRP_Config.SafezoneNotify then
                        TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Du hast eine Safezone betreten", 5000)
                    end
                    SafezoneIn = true
                    SafezoneOut = false
                end
            else
                if not SafezoneOut then
                    NetworkSetFriendlyFireOption(true)
                    if NRP_Config.SafezoneNotify then
                        TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Du hast eine Safezone verlassen", 5000)
                    end
                    if NRP_Config.SafezoneSound then
                        PlaySoundFrontend(-1, NRP_Config.SafezoneSoundName, "HUD_MINI_GAME_SOUNDSET", true)
                    end
                    if NRP_Config.SafezoneEffect then
                        SetTimecycleModifier(NRP_Config.SafezoneEffectName)
                        Wait(NRP_Config.SafezoneEffectDuration)
	                    ClearTimecycleModifier()
                    end
                    if NRP_Config.SafezoneSpeedlimit then
                        SetVehicleMaxSpeed(vehicle, nil)
                    end
                    SetEntityCanBeDamaged(vehicle, true)
                    if NRP_Config.SafezoneOpacity then
                        ResetEntityAlpha(player)
                        ResetEntityAlpha(vehicle)
                    end
                    if NRP_Config.SafezoneGodmode then
                        SetPlayerInvincible(playerId, false)
                        SetEntityProofs(player, false, false, false, false, false, false, false, false)
                        SetEntityProofs(vehicle, false, false, false, false, false, false, false, false)
                        SetEntityInvincible(vehicle, false)
                        SetEntityCanBeDamaged(vehicle, true)
                        SetVehicleCanBreak(vehicle, true)
                        SetVehicleCanBeVisiblyDamaged(vehicle, true)
                        SetVehicleCanDeformWheels(vehicle, true)
                        SetVehicleTyresCanBurst(vehicle, true)
                    end
                    SafezoneOut = true
                    SafezoneIn = false
                end
                Wait(200)
            end
            if SafezoneIn then
                Wait(0)
                if NRP_Config.SafezoneFastrun then
                    SetPedMoveRateOverride(player, NRP_Config.SafezoneFastrunSpeed)
                end
                if NRP_Config.SafezoneOpacity then
                    SetEntityAlpha(player, NRP_Config.SafezoneOpacityValue, false)
                    SetEntityAlpha(vehicle, NRP_Config.SafezoneOpacityValue)
                end
                if NRP_Config.SafezoneGodmode then
                    SetPlayerInvincible(playerId, true)
                    SetEntityProofs(player, true, true, true, true, true, true, true, true)
                    SetEntityProofs(vehicle, true, true, true, true, true, true, true, true)
                    SetEntityInvincible(vehicle, true)
                    SetEntityCanBeDamaged(vehicle, false)
                    SetVehicleCanBreak(vehicle, false)
                    SetVehicleCanBeVisiblyDamaged(vehicle, false)
                    SetVehicleCanDeformWheels(vehicle, false)
                    SetVehicleTyresCanBurst(vehicle, false)
                end
                if NRP_Config.SafezoneRevive and IsPlayerDead(playerId) then
                    TriggerEvent(NRP_Config.SafezoneReviveTrigger, playerId)
                end
                BlockWeaponWheelThisFrame()
                DisablePlayerFiring(player, true)
                SetPlayerCanDoDriveBy(player, false)
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 37, true)
                DisableControlAction(0, 45, true)
                DisableControlAction(0, 47, true)
                DisableControlAction(0, 50, true)
                DisableControlAction(0, 53, true)
                DisableControlAction(0, 54, true)
                DisableControlAction(0, 56, true)
                DisableControlAction(0, 57, true)
                DisableControlAction(0, 58, true)
                DisableControlAction(0, 68, true)
                DisableControlAction(0, 69, true)
                DisableControlAction(0, 70, true)
                DisableControlAction(0, 91, true)
                DisableControlAction(0, 92, true)
                DisableControlAction(0, 106, true)
                DisableControlAction(0, 114, true)
                DisableControlAction(0, 115, true)
                DisableControlAction(0, 116, true)
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 142, true)
                DisableControlAction(0, 257, true)
                DisableControlAction(0, 261, true)
                DisableControlAction(0, 262, true)
                DisableControlAction(0, 263, true)
                DisableControlAction(0, 264, true)
                DisableControlAction(0, 331, true)
                DisableControlAction(0, 345, true)
                DisableControlAction(0, 346, true)
                DisableControlAction(0, 347, true)

                if NRP_Config.SafezoneSpeedlimit then
                    mphs = 2.237
                    maxspeed = NRP_Config.SafezoneSpeedlimit/mphs
                    SetVehicleMaxSpeed(vehicle, maxspeed)
                end
                if IsDisabledControlJustPressed(2, 37) or IsDisabledControlJustPressed(0, 106) then
                    SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
                end
                if NRP_Config.SafezoneYouCantNotify and IsDisabledControlJustPressed(0, 24) or IsDisabledControlJustPressed(0, 140) then
                    TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du kannst nicht in einer Safezone schlagen", 5000)
                end
            end
        end
    end)
end


-----{ S N O W B A L L   P I C K U P }-----
if NRP_Config.SnowballPickup then
    CreateThread(function()
        
        local showHelp = true
        local loaded = false
        
        while true do
            Wait(0)
            if IsNextWeatherType('XMAS') then
                
                WaterOverrideSetStrength(3.0)
                
                SetForceVehicleTrails(true)
                SetForcePedFootstepsTracks(true)
                
                if not loaded then
                    RequestScriptAudioBank("ICE_FOOTSTEPS", false)
                    RequestScriptAudioBank("SNOW_FOOTSTEPS", false)
                    RequestNamedPtfxAsset("core_snow")
                    while not HasNamedPtfxAssetLoaded("core_snow") do
                        Wait(0)
                    end
                    UseParticleFxAssetNextCall("core_snow")
                    loaded = true
                end
                local playerPedId = PlayerPedId()
                local playerId = PlayerId()
                local weapon_snowball = 'WEAPON_SNOWBALL'
                local anim = NRP_Config.SnowballPickupAnimation
                local anim2 = NRP_Config.SnowballPickupAnimation2
                RequestAnimDict(anim)
                if IsControlJustReleased(0, NRP_Config.SnowballPickupKey) and not IsPedInAnyVehicle(playerPedId, true) and not IsPlayerFreeAiming(playerId) and not IsPedSwimming(playerPedId) and not IsPedSwimmingUnderWater(playerPedId) and not IsPedRagdoll(playerPedId) and not IsPedFalling(playerPedId) and not IsPedRunning(playerPedId) and not IsPedSprinting(playerPedId) and GetInteriorFromEntity(playerPedId) == 0 and not IsPedShooting(playerPedId) and not IsPedUsingAnyScenario(playerPedId) and not IsPedInCover(playerPedId, 0) then
                    TaskPlayAnim(playerPedId, anim, anim2, 8.0, -1, -1, 0, 1, 0, 0, 0)
                    Wait(1950)
                    GiveWeaponToPed(playerPedId, GetHashKey(weapon_snowball), 2, false, true)
                end
                if not IsPedInAnyVehicle(playerPedId, true) and not IsPlayerFreeAiming(playerId) then
                    if showHelp then
                        NRP_Config.Helpnotify(NRP_Config.SnowballPickupText)
                    end
                    showHelp = false
                else
                    showHelp = true
                end
            else
                if loaded then WaterOverrideSetStrength(0.0) end
                loaded = false
                RemoveNamedPtfxAsset("core_snow")
                ReleaseNamedScriptAudioBank("ICE_FOOTSTEPS")
                ReleaseNamedScriptAudioBank("SNOW_FOOTSTEPS")
                SetForceVehicleTrails(false)
                SetForcePedFootstepsTracks(false)
            end
            if GetSelectedPedWeapon(playerPedId) == GetHashKey(weapon_snowball) then
                SetPlayerWeaponDamageModifier(playerId, 0.0)
            end
        end
    end)
end


-----{ H A L L O W E E N }-----
CreateThread(function()
    while NRP_Config.Halloween do        
    	SetWeatherTypePersist("HALLOWEEN")
    	SetWeatherTypeNowPersist("HALLOWEEN")
    	SetWeatherTypeNow("HALLOWEEN")
    	SetOverrideWeather("HALLOWEEN")
    	NetworkOverrideClockTime(0, 00, 00)
    	SetClockTime(0, 0, 0)
    	PauseClock(true)
    	Wait(1000)
    end
end)


-----{ W E A T H E R }-----
CreateThread(function()
    while NRP_Config.Weather do
        SetWeatherTypePersist(NRP_Config.WeatherType)
        SetWeatherTypeNowPersist(NRP_Config.WeatherType)
        SetWeatherTypeNow(NRP_Config.WeatherType)
        SetOverrideWeather(NRP_Config.WeatherType)
        Wait(1000)
    end
end)


-----{ L E S S   G R I P }-----
CreateThread(function()
    while NRP_Config.LessGrip do
        Wait(200)
        local ped = PlayerPedId()
        if IsPedOnFoot(ped) and not IsPedSwimming(ped) and (IsPedRunning(ped) or IsPedSprinting(ped)) and not IsPedClimbing(ped) and IsPedJumping(ped) and not IsPedRagdoll(ped) then
            local chance_result = math.random()
            if chance_result < NRP_Config.LessGripProbability then 
                Wait(600)
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.00)
                SetPedToRagdoll(ped, 5000, 1, 2)
            else
                Wait(2000)
            end
        end
    end
end)


-----{ H I D E   I N   T R U N K }-----
if NRP_Config.HideInTrunk then
    local inTrunk = false

    CreateThread(function()
        while true do
            Wait(0)
            if inTrunk then
                local playerPedId = PlayerPedId()
                local vehicle = GetEntityAttachedTo(playerPedId)
                local trunkAnimation = NRP_Config.HideInTrunkAnimation
                if DoesEntityExist(vehicle) or not IsPedDeadOrDying(playerPedId) or not IsPedFatallyInjured(playerPedId) then
                    local coords = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, 'boot'))
                    SetEntityCollision(playerPedId, false, false)
                    DrawText3D(coords, NRP_Config.HideInTrunkTextLeave)

                    if GetVehicleDoorAngleRatio(vehicle, 5) < 0.9 then
                        SetEntityVisible(playerPedId, false, false)
                    else
                        if not IsEntityPlayingAnim(playerPedId, trunkAnimation, 3) then
                            loadDict(trunkAnimation)
                            TaskPlayAnim(playerPedId, trunkAnimation, 'base', 8.0, -8.0, -1, 1, 0, false, false, false)

                            SetEntityVisible(playerPedId, true, false)
                        end
                    end
                    if IsControlJustReleased(0, NRP_Config.HideInTrunkEntryKey) and inTrunk then
                        SetCarBootOpen(vehicle)
                        SetEntityCollision(playerPedId, true, true)
                        Wait(750)
                        inTrunk = false
                        DetachEntity(playerPedId, true, true)
                        SetEntityVisible(playerPedId, true, false)
                        ClearPedTasks(playerPedId)
                        SetEntityCoords(playerPedId, GetOffsetFromEntityInWorldCoords(playerPedId, 0.0, -0.5, -0.75))
                        Wait(250)
                        SetVehicleDoorShut(vehicle, 5)
                    end
                else
                    SetEntityCollision(playerPedId, true, true)
                    DetachEntity(playerPedId, true, true)
                    SetEntityVisible(playerPedId, true, false)
                    ClearPedTasks(playerPedId)
                    SetEntityCoords(playerPedId, GetOffsetFromEntityInWorldCoords(playerPedId, 0.0, -0.5, -0.75))
                end
            end
        end
    end)   

    CreateThread(function()
        while not NetworkIsSessionStarted() or ESX.GetPlayerData().job == nil do Wait(0) end
            local playerPedId = PlayerPedId()
            local vehicle = GetClosestVehicle(GetEntityCoords(playerPedId), 10.0, 0, 70)
		    local lockStatus = GetVehicleDoorLockStatus(vehicle)
            if DoesEntityExist(vehicle) and IsVehicleSeatFree(vehicle,-1) then
            local trunk = GetEntityBoneIndexByName(vehicle, 'boot')
                if trunk ~= -1 then
                local coords = GetWorldPositionOfEntityBone(vehicle, trunk)
                if GetDistanceBetweenCoords(GetEntityCoords(playerPedId), coords, true) <= 1.5 then
                    if not inTrunk then
                        if GetVehicleDoorAngleRatio(vehicle, 5) < 0.9 then
                            DrawText3D(coords, NRP_Config.HideInTrunkTextEntry)
							    if IsControlJustReleased(0, NRP_Config.HideInTrunkTextLeaveKey)then
								    if lockStatus == 1 then
									    SetCarBootOpen(vehicle)
								    elseif lockStatus == 2 then
                                        TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Auto ist abgeschlossen!", 5000)
								    end
							    end
                            else
                                DrawText3D(coords, NRP_Config.HideInTrunkTextEntry)
                                if IsControlJustReleased(0, NRP_Config.HideInTrunkTextLeaveKey) then
                                    SetVehicleDoorShut(vehicle, 5)
                                end
                            end
                        end
                        if IsControlJustReleased(0, NRP_Config.HideInTrunkEntryKey) and not inTrunk then
                            local player = ESX.Game.GetClosestPlayer()
                            local playerPed = GetPlayerPed(player)
						    local playerPed2 = PlayerPedId()
                            local trunkAnimation = NRP_Config.HideInTrunkAnimation
						    if lockStatus == 1 then
							    if DoesEntityExist(playerPed) then
								    if not IsEntityAttached(playerPed) or GetDistanceBetweenCoords(GetEntityCoords(playerPed), GetEntityCoords(playerPedId), true) >= 5.0 then
									    SetCarBootOpen(vehicle)
									    Wait(350)
									    AttachEntityToEntity(playerPedId, vehicle, -1, 0.0, -2.2, 0.5, 0.0, 0.0, 0.0, false, false, false, false, 20, true)	
									    loadDict(trunkAnimation)
									    TaskPlayAnim(playerPedId, trunkAnimation, 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
									    Wait(50)
									    inTrunk = true

									    Wait(1500)
									    SetVehicleDoorShut(vehicle, 5)
								    else
                                        TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Jemand ist bereits im Kofferraum!", 5000)
								    end
							    end
						    elseif lockStatus == 2 then
                                TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Auto ist abgeschlossen!", 5000)
						    end
                        end
                    end
                end
            Wait(0)
        end
    end)

    loadDict = function(dict)
        while not HasAnimDictLoaded(dict) do Wait(0) RequestAnimDict(dict) end
    end

    function DrawText3D(coords, text)
        local getGameplayCamCoords = GetGameplayCamCoords()
        local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
        local pX, pY, pZ = table.unpack(getGameplayCamCoords)
  
        SetTextScale(0.4, 0.4)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextEntry("STRING")
        SetTextCentre(1)
        SetTextColour(255, 255, 255, 255)
        SetTextOutline()
  
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end


-----{ W E A P O N   A N I M A T I O N }-----
if NRP_Config.WeaponAnimation then
    local holstered  = true
    local blocked	 = false

    CreateThread(function()
	    while true do
		    Wait(100)
            local weaponAnimation = NRP_Config.WeaponAnimationAnimation
            local weaponAnimation2 = NRP_Config.WeaponAnimationAnimation2
		    loadAnimDict(weaponAnimation)
		    loadAnimDict(weaponAnimation2)
		    local ped = PlayerPedId()
		    if not IsPedInAnyVehicle(ped, false) then
		        if DoesEntityExist(ped) and not IsEntityDead(ped) and GetVehiclePedIsTryingToEnter(ped) == 0 and not IsPedInParachuteFreeFall (ped) then
			        if CheckWeapon(ped) then
			    	    if holstered then
			    		    blocked = true
			    		    TaskPlayAnim(ped, weaponAnimation, "intro", 8.0, 2.0, -1, 48, 2, 0, 0, 0 )
			    		    Wait(2500)
			    		    ClearPedTasks(ped)
			    		    holstered = false
			    	    else
			    		    blocked = false
			    	    end
			        else
			    	    if not holstered then
			    		    TaskPlayAnim(ped, weaponAnimation, "outro", 8.0, 2.0, -1, 48, 2, 0, 0, 0 )
			    		    Wait(1500)
			    		    ClearPedTasks(ped)
			    		    holstered = true
			    	    end
			        end
		        else
		    	    SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
		        end
		    else
			    holstered = false
		    end
	    end
    end)

    CreateThread(function()
	    while true do
		    Wait(0)
		    if blocked then
                DisableControlAction(0, 45, true)
                DisableControlAction(0, 47, true)
			    DisableControlAction(1, 23, true)
			    DisableControlAction(1, 25, true)
			    DisableControlAction(1, 37, true)
			    DisableControlAction(1, 140, true)
			    DisableControlAction(1, 141, true)
			    DisableControlAction(1, 142, true)
			    DisablePlayerFiring(ped, true)
                BlockWeaponWheelThisFrame()
		    end
	    end
    end)

    function CheckWeapon(ped)
	    for i = 1, #NRP_Config.WeaponAnimationWeapons do
		    if GetHashKey(NRP_Config.WeaponAnimationWeapons[i]) == GetSelectedPedWeapon(ped) then
			    return true
		    end
	    end
	    return false
    end

    function loadAnimDict(dict)
	    while ( not HasAnimDictLoaded(dict)) do
		    RequestAnimDict(dict)
		    Wait(10)
	    end
    end
end


-----{ A N T I   L O S E   H A T }-----
CreateThread(function()
    while NRP_Config.AntiLoseHat do
        Wait(1000)
        local playerPedId = PlayerPedId()
        SetPedCanLosePropsOnDamage(playerPedId, false, 0)
    end
end)


-----{ V E H I C L E   P U S H }-----
if NRP_Config.VehiclePush then
    local First = vector3(0.0, 0.0, 0.0)
    local Second = vector3(5.0, 5.0, 5.0)

    local Vehicle = {Coords = nil, Vehicle = nil, Dimension = nil, IsInFront = false, Distance = nil}
    CreateThread(function()
        Wait(200)
        while true do
            local ped = PlayerPedId()
            local closestVehicle, Distance = ESX.Game.GetClosestVehicle()
            local vehicleCoords = GetEntityCoords(closestVehicle)
            local dimension = GetModelDimensions(GetEntityModel(closestVehicle), First, Second)
            if Distance < 3.0  and not IsPedInAnyVehicle(ped, false) then
                Vehicle.Coords = vehicleCoords
                Vehicle.Dimensions = dimension
                Vehicle.Vehicle = closestVehicle
                Vehicle.Distance = Distance
                if GetDistanceBetweenCoords(GetEntityCoords(closestVehicle) + GetEntityForwardVector(closestVehicle), GetEntityCoords(ped), true) > GetDistanceBetweenCoords(GetEntityCoords(closestVehicle) + GetEntityForwardVector(closestVehicle) * -1, GetEntityCoords(ped), true) then
                    Vehicle.IsInFront = false
                else
                    Vehicle.IsInFront = true
                end
            else
                Vehicle = {Coords = nil, Vehicle = nil, Dimensions = nil, IsInFront = false, Distance = nil}
            end
            Wait(500)
        end
    end)

    CreateThread(function()
        while true do 
            Wait(5)
            local ped = PlayerPedId()
            if Vehicle.Vehicle ~= nil then
 
                if IsVehicleSeatFree(Vehicle.Vehicle, -1) and GetVehicleEngineHealth(Vehicle.Vehicle) <= NRP_Config.VehiclePushDamageNeeded then
                    ESX.Game.Utils.DrawText3D({x = Vehicle.Coords.x, y = Vehicle.Coords.y, z = Vehicle.Coords.z}, NRP_Config.VehiclePushText, NRP_Config.VehiclePushTextSize)
                end
     
                if IsControlPressed(0, NRP_Config.VehiclePushKey1) and IsVehicleSeatFree(Vehicle.Vehicle, -1) and not IsEntityAttachedToEntity(ped, Vehicle.Vehicle) and IsControlJustPressed(0, 38)  and GetVehicleEngineHealth(Vehicle.Vehicle) <= NRP_Config.VehiclePushDamageNeeded then
                    NetworkRequestControlOfEntity(Vehicle.Vehicle)
                    local coords = GetEntityCoords(ped)
                    if Vehicle.IsInFront then    
                        AttachEntityToEntity(ped, Vehicle.Vehicle, GetPedBoneIndex(6286), 0.0, Vehicle.Dimensions.y * -1 + 0.1 , Vehicle.Dimensions.z + 1.0, 0.0, 0.0, 180.0, 0.0, false, false, true, false, true)
                    else
                        AttachEntityToEntity(ped, Vehicle.Vehicle, GetPedBoneIndex(6286), 0.0, Vehicle.Dimensions.y - 0.3, Vehicle.Dimensions.z  + 1.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, true)
                    end
                    local pushAnimation1 = 'missfinale_c2ig_11'
                    local pushAnimation2 = 'pushcar_offcliff_m'

                    ESX.Streaming.RequestAnimDict(pushAnimation1)
                    TaskPlayAnim(ped, pushAnimation1, pushAnimation2, 2.0, -8.0, -1, 35, 0, 0, 0, 0)
                    Wait(200)

                    local currentVehicle = Vehicle.Vehicle
                    while true do
                        Wait(5)
                        if IsDisabledControlPressed(0, 34) then
                            TaskVehicleTempAction(ped, currentVehicle, 11, 1000)
                        end

                        if IsDisabledControlPressed(0, 9) then
                            TaskVehicleTempAction(ped, currentVehicle, 10, 1000)
                        end

                        if Vehicle.IsInFront then
                            SetVehicleForwardSpeed(currentVehicle, -1.0)
                        else
                            SetVehicleForwardSpeed(currentVehicle, 1.0)
                        end

                        if HasEntityCollidedWithAnything(currentVehicle) then
                            SetVehicleOnGroundProperly(currentVehicle)
                        end

                        if not IsDisabledControlPressed(0, NRP_Config.VehiclePushKey2) then
                            DetachEntity(ped, false, false)
                            StopAnimTask(ped, pushAnimation1, pushAnimation2, 2.0)
                            FreezeEntityPosition(ped, false)
                            break
                        end
                    end
                end
            end
        end
    end)
end


-----{ P M A - V O I C E   N O T   C O N N E C T E D   U I }-----
local ismuted = false

CreateThread(function()
	while true do
		Wait(10)
		if MumbleIsConnected() == 1 then
			SendNUIMessage({action = "toggleWindow", value = "false"})
			ismuted = false
		elseif not MumbleIsConnected() then
			SendNUIMessage({action = "toggleWindow", value = "true"})
			ismuted = true
            if NRP_Config.PMAVoiceNotConnectedDisableKeys then
                local player = PlayerPedId()
                BlockWeaponWheelThisFrame()
		        DisablePlayerFiring(player, true)
		        SetPlayerCanDoDriveBy(player, false)
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(2, 37, true)
                DisableControlAction(0, 45, true)
                DisableControlAction(0, 47, true)
                DisableControlAction(0, 50, true)
                DisableControlAction(0, 53, true)
                DisableControlAction(0, 54, true)
                DisableControlAction(0, 56, true)
                DisableControlAction(0, 57, true)
                DisableControlAction(0, 58, true)
                DisableControlAction(0, 68, true)
                DisableControlAction(0, 69, true)
                DisableControlAction(0, 70, true)
                DisableControlAction(0, 91, true)
                DisableControlAction(0, 92, true)
                DisableControlAction(0, 106, true)
                DisableControlAction(0, 114, true)
                DisableControlAction(0, 115, true)
                DisableControlAction(0, 116, true)
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 142, true)
                DisableControlAction(0, 257, true)
                DisableControlAction(0, 261, true)
                DisableControlAction(0, 262, true)
                DisableControlAction(0, 263, true)
                DisableControlAction(0, 264, true)
                DisableControlAction(0, 331, true)
                DisableControlAction(0, 345, true)
                DisableControlAction(0, 346, true)
                DisableControlAction(0, 347, true)
            end
		end
	end
end)


-----{ N O   H E L M E T }-----
CreateThread( function()
	while NRP_Config.NoHelmet do
		Wait(100)		
		local playerPed = PlayerPedId()
		local playerVeh = GetVehiclePedIsUsing(playerPed)

		if playerVeh ~= 0 then RemovePedHelmet(playerPed,true) end
	end
end)


-----{ / C O P Y O U T F I T   C O M M A N D }-----
if NRP_Config.CopyoutfitCommand then
    RegisterNetEvent("nrp_Core:getOutfit")
    AddEventHandler("nrp_Core:getOutfit", function(playerToGiveOutfit)
	    local ped1 = PlayerPedId()
        local outfit = {}
        for i=1,11 do
        local drawable, texture, palette = GetPedDrawableVariation(ped1, i), GetPedTextureVariation(ped1, i), GetPedPaletteVariation(ped1, i)
        table.insert(outfit, {drawable = drawable, texture = texture, palette = palette})
        end
        TriggerServerEvent("nrp_Core:sendToServer", outfit, playerToGiveOutfit)
    end)

    RegisterNetEvent("nrp_Core:setPed")
    AddEventHandler("nrp_Core:setPed", function(outfit)
        local ped2 = PlayerPedId()
        for k,v in pairs(outfit) do
 		    SetPedComponentVariation(ped2, k, v.drawable, v.texture, v.palette)
	    end
    end)
end


-----{ T I M E }-----
CreateThread(function()
    while NRP_Config.Time do
        NetworkOverrideClockTime(NRP_Config.TimeHours, NRP_Config.TimeMinutes, NRP_Config.TimeSeconds)

        PauseClock(true)

        Wait(1000)
    end
end)


-----{ W A L K S T I C K }-----
if NRP_Config.Walkstick then
    local used = false

    RegisterNetEvent('nrp_Core:walkstick')
    AddEventHandler('nrp_Core:walkstick',function()
        local ped = PlayerPedId()
	    ClearPedTasksImmediately(ped)
	    CreateThread(function()
	        if not used then
		        local ped = PlayerPedId()
		        local propName = NRP_Config.WalkstickProp
		        local coords = GetEntityCoords(ped)
		        local prop = GetHashKey(propName)
		        local dict = NRP_Config.WalkstickAnimation
		        local name = NRP_Config.WalkstickAnimation2
		        RequestWalking(NRP_Config.WalkstickWalkstyle)
		        SetPedMovementClipset(ped, NRP_Config.WalkstickWalkstyle, 1.0)
		        while not HasAnimDictLoaded(dict) do
		            Wait(10)
		            RequestAnimDict(dict)
		        end
  
		        RequestModel(prop)
		        while not HasModelLoaded(prop) do
		            Wait(100)
		        end
  
		        attachProps = CreateObject(prop, coords,  true,  false,  false)
		        local netid = ObjToNet(attachProps)
		        AttachEntityToEntity(attachProps,ped,GetPedBoneIndex(ped, 57005),0.15, 0.0, -0.00, 0.0, 266.0, 0.0, false, false, false, true, 2, true)
		        prop = netid
		        used = true
	        else
                local playerpedid = PlayerPedId()
                local playerid = PlayerId()
		        RequestWalking(NRP_Config.WalkstickWalkstyle2)
		        SetPedMovementClipset(playerpedid, NRP_Config.WalkstickWalkstyle2, 1.0)
		        used = false
		        ClearPedSecondaryTask(GetPlayerPed(playerid))
		        SetModelAsNoLongerNeeded(prop)
		        SetEntityAsMissionEntity(attachProps, true, false)
		        DetachEntity(NetToObj(prop), 1, 1)
		        DeleteEntity(NetToObj(prop))
		        DeleteEntity(attachProps)
		        prop = nil
	        end
        end)
    end)

    function RequestWalking(set)
	    RequestAnimSet(set)
	    while not HasAnimSetLoaded(set) do
	        Wait(1)
	    end 
    end
end


-----{ R O U T E N }-----
if NRP_Config.Routen then
    local Keys = {
        ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
        ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
        ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
        ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
        ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
        ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
        ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
        ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
        ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
    }

    local HasAlreadyEnteredMarker = false
    local CurrentAction = nil
    local CurrentActionMsg = ""
    local CurrentActionData = {}
    local type = ""
    local farming
    local verarbeiten
    local verkaufen
    local LastStation
    local isInAction = false

    function cooldowntimer()
        CreateThread(function()
            while cooldown do
                Wait(0)
                Wait(5 * 1000)
                cooldown = false
            end
        end)
    end

    function anim()
        local playerPedId = PlayerPedId()
        if not IsEntityPlayingAnim(playerPedId, "pickup_object", "pickup_low", 3) then
            RequestAnimDict("pickup_object")
            while not HasAnimDictLoaded("pickup_object") do
                Wait(100)
            end
            Wait(100)
            TaskPlayAnim(playerPedId, "pickup_object", "pickup_low", 8.0, -8, -1, 1, 0, 0, 0, 0)
            farming = true
            showabbruch()
        end
    end

    function clearanim()
        local playerPedId = PlayerPedId()
        ClearPedTasksImmediately(playerPedId)
    end

    CreateThread(function()
        for k, v in pairs(NRP_Config.RoutenFarms) do
            if v.legal then
                local blip = AddBlipForCoord(v.position.x, v.position.y, v.position.z)
                SetBlipSprite(blip, v.blip.sprite)
                SetBlipScale(blip, v.blip.size)
                SetBlipColour(blip, v.blip.colour)
                SetBlipDisplay(blip, 4)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(v.blip.name)
                EndTextCommandSetBlipName(blip)
            end
        end
        for k, v in pairs(NRP_Config.RoutenProcessor) do
            if v.legal then
                local blip = AddBlipForCoord(v.position.x, v.position.y, v.position.z)
                SetBlipSprite(blip, v.blip.sprite)
                SetBlipScale(blip, v.blip.size)
                SetBlipColour(blip, v.blip.colour)
                SetBlipDisplay(blip, 4)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(v.blip.name)
                EndTextCommandSetBlipName(blip)
            end
        end
        for k, v in pairs(NRP_Config.RoutenSelling) do
            if v.legal then
                local blip = AddBlipForCoord(v.position.x, v.position.y, v.position.z)
                SetBlipSprite(blip, v.blip.sprite)
                SetBlipScale(blip, v.blip.size)
                SetBlipColour(blip, v.blip.colour)
                SetBlipDisplay(blip, 4)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(v.blip.name)
                EndTextCommandSetBlipName(blip)
            end
        end
    end)

    AddEventHandler("nrp_core:routen:unfreeze:startFarming", function(route, CurrentActionData)        
        isInAction = true
        anim()
        TriggerServerEvent("nrp_core:routen:startfarming", route, CurrentActionData)
        TriggerEvent("nrp_core:routen:unfreeze:freezeFarming")
    end)

    AddEventHandler("nrp_core:routen:unfreeze:startVerarbeitung", function(route, CurrentActionData)        
        isInAction = true
        farming = true
        showabbruch()
        TriggerServerEvent("nrp_core:routen:startverarbeiten", route, CurrentActionData)
        TriggerEvent("nrp_core:routen:unfreeze:freezeFarming")
    end)

    AddEventHandler("nrp_core:routen:unfreeze:startVerkauf", function(route, CurrentActionData)
        isInAction = true
        farming = true
        showabbruch()
        TriggerServerEvent("nrp_core:routen:startverkaufen", route, CurrentActionData)
        TriggerEvent("nrp_core:routen:unfreeze:freezeFarming")
    end)

    AddEventHandler("nrp_core:routen:unfreeze:hasEnteredMarker", function(part, farmroute, farmType)
        for k, v in pairs(NRP_Config.RoutenFarms) do
            if k == farmroute then
                if part == "farmMenu" then
                    CurrentAction = "start_farming"
                    CurrentActionMsg = "Drücke E um "..v.item:gsub("^%l", string.upper).. " zu sammeln"
                    CurrentActionData = "farm"
                end
            end
        end
        for k, v in pairs(NRP_Config.RoutenProcessor) do
            if k == farmroute then
                if part == "verarbeiterMenu" then
                    CurrentAction = "start_verarbeiten"
                    CurrentActionMsg = "Drücke E zum Verarbeiten von "..v.item:gsub("^%l", string.upper)
                    CurrentActionData = "verarbeiten"
                end
            end
        end
        for k, v in pairs(NRP_Config.RoutenSelling) do
            if k == farmroute then
                if part == "verkaufMenu" then
                    CurrentAction = "start_verkauf"
                    CurrentActionMsg = "Drücke E zum Verkaufen von "..v.item_verkauf:gsub("^%l", string.upper)
                    CurrentActionData = "verkaufen"
                end
            end
        end
    end)

    AddEventHandler("nrp_core:routen:unfreeze:hasExitedMarker", function()
        CurrentAction = nil
    end)

CreateThread(function()
    while true do
        Wait(0)
        local playerPedId = PlayerPedId()
        local coords = GetEntityCoords(playerPedId)
        local isInMarker, hasExited, letSleep = false, false, true

        for k, v in pairs(NRP_Config.RoutenFarms) do
            local dist = GetDistanceBetweenCoords(coords, v.position, true)
            if dist < NRP_Config.RoutenMarkerDrawdistance then
                DrawMarker(NRP_Config.RoutenFarmMarkerType, v.position.x, v.position.y, v.position.z, 0, 0, 0, 0, 0, v.range, v.range, v.range, 1.5, NRP_Config.RoutenMarkerColorR, NRP_Config.RoutenMarkerColorG, NRP_Config.RoutenMarkerColorB, NRP_Config.RoutenMarkerColorA, 0, 0, 2, 0, 0, 0, 0)
                letSleep = false
                if dist < v.range - 5.0 then
                    isInMarker = true
                    type = "farmMenu"
                    farmroute = k
                end
            end
        end

        for k, v in pairs(NRP_Config.RoutenProcessor) do
            local dist = GetDistanceBetweenCoords(coords, v.position, true)
            if dist < NRP_Config.RoutenMarkerDrawdistance then
                DrawMarker(NRP_Config.RoutenProcessMarkerType, v.position, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.5, NRP_Config.RoutenMarkerColorR, NRP_Config.RoutenMarkerColorG, NRP_Config.RoutenMarkerColorB, NRP_Config.RoutenMarkerColorA, false, true, 2, true, false, false, false)
                letSleep = false
                if dist <= v.range then
                    isInMarker = true
                    type = "verarbeiterMenu"
                    farmroute = k
                end
            end
        end

        for k, v in pairs(NRP_Config.RoutenSelling) do
            local dist = GetDistanceBetweenCoords(coords, v.position, true)
            if dist < NRP_Config.RoutenMarkerDrawdistance then
                DrawMarker(NRP_Config.RoutenSellMarkerType, v.position, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.5, NRP_Config.RoutenMarkerColorR, NRP_Config.RoutenMarkerColorG, NRP_Config.RoutenMarkerColorB, NRP_Config.RoutenMarkerColorA, false, true, 2, true, false, false, false)
                letSleep = false
                if dist <= v.range then
                    isInMarker = true
                    type = "verkaufMenu"
                    farmroute = k
                end
            end
        end

        if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= farmroute)) then
            if (LastStation ~= nil) and (LastStation ~= farmroute) then
                TriggerEvent("nrp_core:routen:unfreeze:hasExitedMarker", LastStation)
                hasExited = true
            end
            HasAlreadyEnteredMarker = true
            LastStation             = farmroute
            TriggerEvent("nrp_core:routen:unfreeze:hasEnteredMarker", type, farmroute, farmroute, farmType)
        end

        if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
            HasAlreadyEnteredMarker = false
            TriggerEvent("nrp_core:routen:unfreeze:hasExitedMarker", LastStation)
        end

        if letSleep then 
            Wait(3000)
        end
    end
end)


CreateThread(function()
    while true do
        if CurrentAction ~= nil then
            Wait(0)
            NRP_Config.Helpnotify(CurrentActionMsg)
            if IsControlJustReleased(0, Keys["E"]) then
                if CurrentAction == "start_farming" then
                    if cooldown then
                        TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Cooldown ist noch aktiv!", 5000)
                    elseif isOnVehicle() then
                        TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "In einem Fahrzeug kannst du nicht farmen!", 5000)
                    elseif isPlayerMoving() then
                        TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du darfst dich nicht bewegen!", 5000)
                    else
                        TriggerEvent("nrp_core:routen:unfreeze:startFarming", farmroute, CurrentActionData)
                    end
                end

                if CurrentAction == "start_verarbeiten" then
                    if cooldown then
                        TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Cooldown ist noch aktiv!", 5000)
                    elseif isOnVehicle() then
                        TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "In einem Fahrzeug kannst du nicht farmen!", 5000)
                    elseif isPlayerMoving() then
                        TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du darfst dich nicht bewegen!", 5000)
                    else
                        TriggerEvent("nrp_core:routen:unfreeze:startVerarbeitung", farmroute, CurrentActionData)
                    end
                end

                if CurrentAction == "start_verkauf" then
                    if cooldown then
                        TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Cooldown ist noch aktiv!", 5000)
                    elseif isOnVehicle() then
                        TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "In einem Fahrzeug kannst du nicht farmen!", 5000)
                    elseif isPlayerMoving() then
                        TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du darfst dich nicht bewegen!", 5000)
                    else
                        TriggerEvent("nrp_core:routen:unfreeze:startVerkauf", farmroute, CurrentActionData)
                    end
                end
                CurrentAction = nil
            end
        else
            Wait(2500)
        end 
    end
end)

    AddEventHandler("nrp_core:routen:unfreeze:freezeFarming", function()
        local playerPedId = PlayerPedId()
        FreezeEntityPosition(playerPedId, true)
        freeze = true
        showabbruch()
    end)

    RegisterNetEvent("nrp_core:routen:unfreeze")
    AddEventHandler("nrp_core:routen:unfreeze", function()
        isInAction = false
        local playerPedId = PlayerPedId()
        FreezeEntityPosition(playerPedId, false)
        clearanim()
        freeze = false
        farming = false
        cooldown = true
        cooldowntimer()
        TriggerServerEvent("nrp_core:routen:stopfarming")
    end)

    function anim()
        local playerPedId = PlayerPedId()
        if not IsEntityPlayingAnim(playerPedId, NRP_Config.RoutenAnimation, NRP_Config.RoutenAnimation2, 3) then
            RequestAnimDict(NRP_Config.RoutenAnimation)
            while not HasAnimDictLoaded(NRP_Config.RoutenAnimation) do
                Wait(100)
            end
            Wait(100)
            TaskPlayAnim(playerPedId, NRP_Config.RoutenAnimation, NRP_Config.RoutenAnimation2, 8.0, -8, -1, 1, 0, 0, 0, 0)
            farming = true
            showabbruch()
        end
    end

    function showabbruch()
        CreateThread(function()
            local playerPedId = PlayerPedId()
            while farming do
                Wait(0)
                NRP_Config.Helpnotify(NRP_Config.RoutenText)
                if IsControlJustReleased(0, Keys["E"]) then
                    clearanim()
                    isInAction = false
                    freeze = false
                    verarbeiten = false
                    verkaufen = false

                    FreezeEntityPosition(playerPedId, false)
                    clearanim()
                    freeze = false
                    TriggerServerEvent("nrp_core:routen:stopfarming")
                    cooldown = true
                    cooldowntimer()
                    farming = false
                end
            end
        end)
    end

    function loadAnimDict(dict)
        while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
        end
    end

    CreateThread(function()
        Wait(0)
        if isInAction then
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            EnableControlAction(0, 48, true)
            EnableControlAction(0, 38, true)
            EnableControlAction(0, 288, true)
        else
            Wait(500)
        end
    end)

    function isOnVehicle()
        Wait(0)
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if IsPedInAnyVehicle(playerPed, false) then
            return true
        else
            return false
        end
    end

    CreateThread(function()
        if isPlayerMoving() then
            if farming then
                TriggerEvent("nrp_core:routen:unfreeze")
            elseif verarbeiten then
                TriggerEvent("nrp_core:routen:unfreeze")
            elseif verkaufen then
                TriggerEvent("nrp_core:routen:unfreeze")
            end
        end
    end)

    function isPlayerMoving()
        local playerPed = PlayerPedId()
        local derzeitigePos = GetEntityCoords(playerPed)
        Wait(0.5 * 1000)
        local neuePos = GetEntityCoords(playerPed)
        local distanz = #(derzeitigePos - neuePos)

        if distanz <= 2.0 then
            return false
        else
            return true
        end
    end
end


-----{ D R U G   E F F E C T S }-----
if NRP_Config.DrugEffects then
    local isDrunk = false

    function Drunk(level, start)
        isDrunk = true
        CreateThread(function()
            local playerPed = PlayerPedId()
            local movement = "move_m@drunk@verydrunk"
            if start then
                DoScreenFadeOut(800)
                Wait(1000)
            end
    
            RequestAnimSet(movement)
          
            while not HasAnimSetLoaded(movement) do
                Wait(0)
            end
    
            SetPedMovementClipset(playerPed, movement, true)
    
            SetTimecycleModifier("spectator5")
            SetPedMotionBlur(playerPed, true)
            SetPedIsDrunk(playerPed, true)
            SetFacialClipsetOverride(playerPed, "mood_drunk_1")
    
            if start then
                DoScreenFadeIn(800)
            end
        end)

        local isDrunk = true
	    local DRUNK_DRIVING_EFFECTS = NRP_Config.DrugEffectsDrive
	
	    local function getRandomDrunkCarTask()
            local getGameTimer = GetGameTimer()
		    math.randomseed(getGameTimer)
	
		    return DRUNK_DRIVING_EFFECTS[math.random(#DRUNK_DRIVING_EFFECTS)]
	    end

	    local playerPed = PlayerPedId()
  
        CreateThread(function()
            while isDrunk do
                local vehPedIsIn = GetVehiclePedIsIn(playerPed)
                local isPedInVehicleAndDriving = (vehPedIsIn ~= 0) and (GetPedInVehicleSeat(vehPedIsIn, -1) == playerPed)

                if isPedInVehicleAndDriving then
                    local randomTask = getRandomDrunkCarTask()
                    TaskVehicleTempAction(playerPed, vehPedIsIn, randomTask, 500)
                end

                Wait(3500)
            end
        end)
    end
    
    function DriveEffects()
        isDrunk = true
        CreateThread(function()
            local isDrunk = true
	        local DRUNK_DRIVING_EFFECTS = NRP_Config.DrugEffectsDrive
	
	        local function getRandomDrunkCarTask()
                local getGameTimer = GetGameTimer()
		        math.randomseed(getGameTimer)
	
		        return DRUNK_DRIVING_EFFECTS[math.random(#DRUNK_DRIVING_EFFECTS)]
	        end

	        local playerPed = PlayerPedId()
  
            CreateThread(function()
                while isDrunk do
                    local vehPedIsIn = GetVehiclePedIsIn(playerPed)
                    local isPedInVehicleAndDriving = (vehPedIsIn ~= 0) and (GetPedInVehicleSeat(vehPedIsIn, -1) == playerPed)

                    if isPedInVehicleAndDriving then
                        local randomTask = getRandomDrunkCarTask()
                        TaskVehicleTempAction(playerPed, vehPedIsIn, randomTask, 350)
                    end

                    Wait(5000)
                end
            end)
        end)
    end

    local alienPed, alienPed2, alienPed3 = nil
    local followDistance = 10.0

    function SpawnAlien()
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local heading = GetEntityHeading(playerPed)

        local spawnDistance = -1
        local spawnDistance2 = 1
        local x = playerCoords.x + (spawnDistance * math.sin(math.rad(heading)))
        local y = playerCoords.y + (spawnDistance2 * math.sin(math.rad(heading)))
        local alienModel = "u_m_y_zombie_01"
        local alienModel2 = "u_m_y_pogo_01"
        local alienModel3 = "u_m_m_jesus_01"

        RequestModel(alienModel)
        while not HasModelLoaded(alienModel) do
            Wait(0)
        end
        RequestModel(alienModel2)
        while not HasModelLoaded(alienModel2) do
            Wait(0)
        end
        RequestModel(alienModel3)
        while not HasModelLoaded(alienModel3) do
            Wait(0)
        end

        alienPed = CreatePed(28, alienModel, x, y, playerCoords.z, heading - 180.0, false, true)
        alienPed2 = CreatePed(28, alienModel2, x + 1, y + 1, playerCoords.z, heading - 180.0, false, true)
        alienPed3 = CreatePed(28, alienModel3, x - 1, y + 1, playerCoords.z, heading - 180.0, false, true)
        SetEntityInvincible(alienPed, true)
        SetEntityInvincible(alienPed2, true)
        SetEntityInvincible(alienPed3, true)
        SetBlockingOfNonTemporaryEvents(alienPed, true)
        SetBlockingOfNonTemporaryEvents(alienPed2, true)
        SetBlockingOfNonTemporaryEvents(alienPed3, true)

        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        if playerVeh ~= 0 then
            TaskVehicleFollow(alienPed, playerVeh, followDistance, 65544)
            TaskVehicleFollow(alienPed2, playerVeh, followDistance, 65544)
            TaskVehicleFollow(alienPed3, playerVeh, followDistance, 65544)
        else
            TaskFollowToOffsetOfEntity(alienPed, playerPed, 0.0, 0.0, 0.0, followDistance, -1, 5.0, true, true)
            TaskFollowToOffsetOfEntity(alienPed2, playerPed, 1.0, 1.0, 0.0, followDistance, -1, 5.0, true, true)
            TaskFollowToOffsetOfEntity(alienPed3, playerPed, 1.0, 1.0, 0.0, followDistance, -1, 5.0, true, true)
        end
    end

    function RemoveAlien()
        if DoesEntityExist(alienPed and alienPed2 and alienPed3) then
            DeleteEntity(alienPed)
            DeleteEntity(alienPed2)
            DeleteEntity(alienPed3)
            alienPed, alienPed2, alienPed3 = nil
        end
    end
    
    function Reality()
        isDrunk = false
        CreateThread(function()
            local playerPed = PlayerPedId()
    
            DoScreenFadeOut(800)
            Wait(1000)
    
            ClearTimecycleModifier()
            ResetScenarioTypesEnabled()
            ResetPedMovementClipset(playerPed, 0)
            SetPedIsDrunk(playerPed, false)
            SetPedMotionBlur(playerPed, false)
            AnimpostfxStopAll()
            SetPedMoveRateOverride(playerPed, 1.0)
            ShakeGameplayCam("DRUNK_SHAKE", 0.0)
            ClearFacialClipsetOverride(playerPed)
    
            DoScreenFadeIn(800)
        end)
    end
    
    RegisterNetEvent('nrp_Core:drugeffects:onDrink')
    AddEventHandler('nrp_Core:drugeffects:onDrink', function()
        local playerPed = PlayerPedId()
      
        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_DRINKING", 0, 1)
        Wait(1000)
        ClearPedTasksImmediately(playerPed)
        Drunk()
        Wait(NRP_Config.DrugEffectsDuration * 1000)
        Reality()
    end)

    RegisterNetEvent('nrp_Core:drugeffects:onMarijuana')
    AddEventHandler('nrp_Core:drugeffects:onMarijuana', function()
        local playerPed = PlayerPedId()

        RequestAnimSet("move_m@hipster@a") 
        while not HasAnimSetLoaded("move_m@hipster@a") do
            Wait(0)
        end    

        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
        Wait(3000)
        ClearPedTasksImmediately(playerPed)
        DriveEffects()
        SetTimecycleModifier("spectator6")
        SetPedMotionBlur(playerPed, true)
        SetPedMovementClipset(playerPed, "MOVE_M@DRUNK@VERYDRUNK", true)
        SetPedIsDrunk(playerPed, true)
        ShakeGameplayCam("DRUNK_SHAKE", 1.0)
        SetEntityHealth(playerPed, 200)


        local randomNumber = math.random(1, 100)
        if randomNumber <= 50 then
	        SetFacialClipsetOverride(playerPed, "mood_happy_1")
        else
            SetFacialClipsetOverride(playerPed, "mood_frustrated_1")
            SetEntityHealth(playerPed, 100)
            SetPedArmour(playerPed, 0)
            ShakeGameplayCam("DRUNK_SHAKE", 2.0)
            TriggerEvent('nrp_notify', "info", "Nuri Roleplay - Core", "Ooooh du hast ein Badtrip", 5000)
            Wait(1500)
            SetPedToRagdoll(playerPed, 1000, 1000, 0, 0, 0, 0)
        end

        Wait(NRP_Config.DrugEffectsDuration * 1000)
        Reality()
    end)

    RegisterNetEvent('nrp_Core:drugeffects:onSpeed')
    AddEventHandler('nrp_Core:drugeffects:onSpeed', function()
        local playerPed = PlayerPedId()

        RequestAnimSet("move_m@hipster@a") 
        while not HasAnimSetLoaded("move_m@hipster@a") do
            Wait(0)
        end    

        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
        Wait(3000)
        ClearPedTasksImmediately(playerPed)
        DriveEffects()
        SetTimecycleModifier("spectator6")
        SetPedMotionBlur(playerPed, true)
        SetPedMovementClipset(playerPed, "move_m@gangster@generic", true)
        SetPedIsDrunk(playerPed, true)
        ShakeGameplayCam("DRUNK_SHAKE", 1.5)
        SetFacialClipsetOverride(playerPed, "mood_angry_1")
        SetPedCombatAttributes(playerPed, 46, true)

        Wait(NRP_Config.DrugEffectsDuration * 1000)
        Reality()
        SetPedCombatAttributes(playerPed, 46, false)
    end)

    RegisterNetEvent('nrp_Core:drugeffects:onCoke')
    AddEventHandler('nrp_Core:drugeffects:onCoke', function()
        local playerPed = PlayerPedId()
        local maxHealth = GetEntityMaxHealth(playerPed)

        RequestAnimSet("move_m@hipster@a") 
        while not HasAnimSetLoaded("move_m@hipster@a") do
            Wait(0)
        end    

        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
        Wait(3000)
        ClearPedTasksImmediately(playerPed)
        DriveEffects()
        SetTimecycleModifier("spectator5")
        SetPedMotionBlur(playerPed, true)
        SetPedMovementClipset(playerPed, "move_m@hurry_butch@a", true)
        SetFacialClipsetOverride(playerPed, "mood_drunk_1")

        local player = PlayerId()
        SetPedArmour(playerPed, 10)
        local health = GetEntityHealth(playerPed)
        local newHealth = math.min(maxHealth , math.floor(health + maxHealth/6))
        SetEntityHealth(playerPed, newHealth)

        Wait(NRP_Config.DrugEffectsDuration * 1000)
        Reality()
    end)

    RegisterNetEvent('nrp_Core:drugeffects:onMeth')
    AddEventHandler('nrp_Core:drugeffects:onMeth', function()
        local playerPed = PlayerPedId()
        local maxHealth = GetEntityMaxHealth(playerPed)

        RequestAnimSet("move_m@hipster@a") 
        while not HasAnimSetLoaded("move_m@hipster@a") do
            Wait(0)
        end    

        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
        Wait(3000)
        ClearPedTasksImmediately(playerPed)
        DriveEffects()
        SetTimecycleModifier("spectator4")
        SetPedMotionBlur(playerPed, true)
        SetPedMovementClipset(playerPed, "move_m@hurry_butch@a", true)
        SetFacialClipsetOverride(playerPed, "mood_drunk_1")
        ShakeGameplayCam("DRUNK_SHAKE", 1.0)

        local player = PlayerId()
        SetPedArmour(playerPed, 10)
        local health = GetEntityHealth(playerPed)
        local newHealth = math.min(maxHealth , math.floor(health + maxHealth/6))
        SetEntityHealth(playerPed, newHealth)
        SetPedMoveRateOverride(playerPed, 1.5)

        Wait(NRP_Config.DrugEffectsDuration * 1000)
        Reality()
    end)

    RegisterNetEvent('nrp_Core:drugeffects:onHeroin')
    AddEventHandler('nrp_Core:drugeffects:onHeroin', function()
        local playerPed = PlayerPedId()

        RequestAnimSet("move_m@hipster@a") 
        while not HasAnimSetLoaded("move_m@hipster@a") do
            Wait(0)
        end    

        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
        Wait(3000)
        ClearPedTasksImmediately(playerPed)
        DriveEffects()
        SetTimecycleModifier("spectator2")
        SetPedMotionBlur(playerPed, true)
        SetPedMovementClipset(playerPed, "move_m@hurry_butch@a", true)
        SetFacialClipsetOverride(playerPed, "mood_drunk_1")

        Wait(5000)
        local randomNumber = math.random(1, 100)
        if randomNumber <= 20 then
            local veh = GetVehiclePedIsIn(playerPed, false)
	        if veh and veh ~= 0 then
		        for i=0, 1 do
			        SetVehicleTyreBurst(veh, i, true, 1000.0)
		        end
	        end
        end

        Wait(NRP_Config.DrugEffectsDuration * 1000)
        Reality()
    end)
    

    RegisterNetEvent('nrp_Core:drugeffects:onLSD')
    AddEventHandler('nrp_Core:drugeffects:onLSD', function()
        local playerPed = PlayerPedId()

        RequestAnimSet("move_m@hipster@a") 
        while not HasAnimSetLoaded("move_m@hipster@a") do
            Wait(0)
        end    

        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
        Wait(3000)
        ClearPedTasksImmediately(playerPed)
        SpawnAlien()
        DriveEffects()
        SetTimecycleModifier("spectator3")
        SetPedMotionBlur(playerPed, true)
        SetPedMovementClipset(playerPed, "move_m@hurry_butch@a", true)
        SetFacialClipsetOverride(playerPed, "mood_drunk_1")
        ShakeGameplayCam("DRUNK_SHAKE", 1.0)

        Wait(5000)
        PlaySoundFrontend(-1, 'ERROR', "HUD_MINI_GAME_SOUNDSET", true)
        SetPedToRagdoll(playerPed, 1000, 1000, 0, 0, 0, 0)

        Wait(5000)
        SetPedToRagdoll(playerPed, 1000, 1000, 0, 0, 0, 0)

        Wait(NRP_Config.DrugEffectsDuration * 1000)
    
        Reality()
        RemoveAlien()
    end)



    RegisterNetEvent('nrp_Core:drugeffects:onEcstasy')
    AddEventHandler('nrp_Core:drugeffects:onEcstasy', function()
        local playerPed = PlayerPedId()

        RequestAnimSet("move_m@hipster@a") 
        while not HasAnimSetLoaded("move_m@hipster@a") do
            Wait(0)
        end    

        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
        Wait(3000)
        ClearPedTasksImmediately(playerPed)
        DriveEffects()
        SetTimecycleModifier("spectator1")
        SetPedMotionBlur(playerPed, true)
        SetPedMovementClipset(playerPed, "move_m@hurry_butch@a", true)
        SetFacialClipsetOverride(playerPed, "mood_drunk_1")

        Wait(3000)
        SetPedCoordsKeepVehicle(playerPed, GetEntityCoords(playerPed).x, GetEntityCoords(playerPed).y, GetEntityCoords(playerPed).z + 0.25)

        Wait(NRP_Config.DrugEffectsDuration * 1000)
        Reality()
    end)
end


-----{ T R U C K E R J O B }-----
if NRP_Config.Truckerjob then
    local PlayerData              	= {}
	local alldeliveries             = {}
	local randomdelivery            = 1
	local isTaken                   = 0
	local isDelivered               = 0
	local currentZone               = ''
	local LastZone                  = ''
	local CurrentAction             = nil
	local CurrentActionMsg          = ''
	local CurrentActionData         = {}
	local actualZone                = ''
	local truck	                    = 0
	local trailer                   = 0
	local deliveryblip
		
	function SpawnTruck()
		ClearAreaOfVehicles(NRP_Config.TruckerjobVehicleSpawnPoint.Pos.x, NRP_Config.TruckerjobVehicleSpawnPoint.Pos.y, NRP_Config.TruckerjobVehicleSpawnPoint.Pos.z, 50.0, false, false, false, false, false)
		SetEntityAsNoLongerNeeded(trailer)
		DeleteVehicle(trailer)
		SetEntityAsNoLongerNeeded(truck)
		DeleteVehicle(truck)
		RemoveBlip(deliveryblip)

		local vehiclehash = GetHashKey(NRP_Config.TruckerjobTruck)
		RequestModel(vehiclehash)
		while not HasModelLoaded(vehiclehash) do
			RequestModel(vehiclehash)
			Wait(0)
		end
		truck = CreateVehicle(vehiclehash, NRP_Config.TruckerjobVehicleSpawnPoint.Pos.x, NRP_Config.TruckerjobVehicleSpawnPoint.Pos.y, NRP_Config.TruckerjobVehicleSpawnPoint.Pos.z, 0.0, true, false)
		SetEntityAsMissionEntity(truck, true, true)
        SetVehicleEngineOn(truck, true, true, true)

        if NRP_Config.TruckerjobFuel then
		    exports[NRP_Config.TruckerjobFuelTrigger]:SetFuel(truck, NRP_Config.TruckerjobFuelAmount)
            SetVehicleFuelLevel(truck, NRP_Config.TruckerjobFuelAmount)
        end

        if NRP_Config.TruckerjobTruckColor then
            SetVehicleCustomPrimaryColour(truck, NRP_Config.TruckerjobTruckColorR, NRP_Config.TruckerjobTruckColorG, NRP_Config.TruckerjobTruckColorB)
            SetVehicleCustomSecondaryColour(truck, NRP_Config.TruckerjobTruckColorR, NRP_Config.TruckerjobTruckColorG, NRP_Config.TruckerjobTruckColorB)
        end

		local trailerhash = GetHashKey(NRP_Config.TruckerjobTrailer)
		RequestModel(trailerhash)
		while not HasModelLoaded(trailerhash) do
			RequestModel(trailerhash)
			Wait(0)
		end
		trailer = CreateVehicle(trailerhash, NRP_Config.TruckerjobTrailerSpawnPoint.Pos.x, NRP_Config.TruckerjobTrailerSpawnPoint.Pos.y, NRP_Config.TruckerjobTrailerSpawnPoint.Pos.z, 0.0, true, false)
		SetEntityAsMissionEntity(trailer, true, true)
		  
		AttachVehicleToTrailer(truck, trailer, 1.1)
		  
		local getplayerped = PlayerPedId()
		TaskWarpPedIntoVehicle(getplayerped, truck, -1)

		local deliveryids = 1
		for k,v in pairs(NRP_Config.TruckerjobDelivery) do
			table.insert(alldeliveries, {
				id = deliveryids,
				posx = v.Pos.x,
				posy = v.Pos.y,
				posz = v.Pos.z,
				payment = v.Payment,
			})
			deliveryids = deliveryids + 1  
		end
		randomdelivery = math.random(1,#alldeliveries)
		  
		deliveryblip = AddBlipForCoord(alldeliveries[randomdelivery].posx, alldeliveries[randomdelivery].posy, alldeliveries[randomdelivery].posz)
		SetBlipSprite(deliveryblip, 304)
		SetBlipDisplay(deliveryblip, 4)
		SetBlipScale(deliveryblip, 0.7)
		SetBlipColour(deliveryblip, 27)
		SetBlipAsShortRange(deliveryblip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Ziel")
		EndTextCommandSetBlipName(deliveryblip)
		  
		SetBlipRoute(deliveryblip, true)
		  
		isTaken = 1
		  
		isDelivered = 0
		
        TriggerEvent('nrp_notify', "info", "Nuri Roleplay - Core", "Bringe die Lieferung zum Lieferpunkt", 5000)
	end
		
	function FinishDelivery()
		local playerpedid = PlayerPedId()
		if IsVehicleAttachedToTrailer(truck) and (GetVehiclePedIsIn(playerpedid, false) == truck) then
			DeleteVehicle(trailer)
			DeleteVehicle(hauler)
			DeleteVehicle(truck)

			SetEntityCoords(playerpedid, 182.83, 2777.74, 44.66, 0, 0, 0, false)
		
			RemoveBlip(deliveryblip)
		
			TriggerServerEvent('nrp_Core:truckerjob:pay', alldeliveries[randomdelivery].payment)
		
			isTaken = 0
		
			isDelivered = 1
		else
            TriggerEvent('nrp_notify', "info", "Nuri Roleplay - Core", "Bitte liefere den LKW der dir gegeben wurde", 5000)
		end
	end
		
	AddEventHandler('nrp_Core:truckerjob:hasEnteredMarker', function(zone)
		if actualZone == 'menutrucker' then
			CurrentAction     = 'trucker_menu'
			CurrentActionData = {zone = zone}
		elseif actualZone == 'delivered' then
			CurrentAction     = 'delivered_menu'
			CurrentActionData = {zone = zone}
		end
	end)
		
	AddEventHandler('nrp_Core:truckerjob:hasExitedMarker', function(zone)
		CurrentAction = nil
		ESX.UI.Menu.CloseAll()
	end)
		
	CreateThread(function()
		local getplayerped = PlayerPedId()
		while true do
			local coords      = GetEntityCoords(getplayerped)
			local isInMarker  = false
			local currentZone = nil
			  
			if(GetDistanceBetweenCoords(coords, NRP_Config.TruckerjobZonesMull.VehicleSpawner.Pos.x, NRP_Config.TruckerjobZonesMull.VehicleSpawner.Pos.y, NRP_Config.TruckerjobZonesMull.VehicleSpawner.Pos.z, true) < 3)  then
                NRP_Config.Helpnotify(NRP_Config.TruckerjobText)
                isInMarker  = true
				currentZone = 'menutrucker'
				LastZone    = 'menutrucker'
				actualZone  = 'menutrucker'
				sleep = 0
			end
			  
			if isTaken == 1 and (GetDistanceBetweenCoords(coords, alldeliveries[randomdelivery].posx, alldeliveries[randomdelivery].posy, alldeliveries[randomdelivery].posz, true) < 3) then
				NRP_Config.Helpnotify(NRP_Config.TruckerjobText2)
                isInMarker  = true
				currentZone = 'delivered'
				LastZone    = 'delivered'
				actualZone  = 'delivered'
				sleep = 0
			end
				
			if isInMarker and not HasAlreadyEnteredMarker then
				sleep = 0
				HasAlreadyEnteredMarker = true
				TriggerEvent('nrp_Core:truckerjob:hasEnteredMarker', currentZone)
			end
			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				sleep = 0
				TriggerEvent('nrp_Core:truckerjob:hasExitedMarker', LastZone)
			end

			if isTaken == 1 and isDelivered == 0 then
			local coords = GetEntityCoords(getplayerped)
				v = alldeliveries[randomdelivery]
				if (GetDistanceBetweenCoords(coords, v.posx, v.posy, v.posz, true) < NRP_Config.TruckerjobDrawDistance) then
					sleep = 0
					DrawMarker(1, v.posx, v.posy, v.posz, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 5.0, 5.0, 1.0, 71, 0, 104, 200, false, false, 0, false, false, false, false)
				end
			end

			local coords = GetEntityCoords(getplayerped)
			for k,v in pairs(NRP_Config.TruckerjobZonesMull) do
				if (v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < NRP_Config.TruckerjobDrawDistance)  then
					sleep = 0
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 200, false, false, 0, false, false, false, false)
				end
			end

			if CurrentAction ~= nil then
				sleep = 0
				SetTextComponentFormat('STRING')
				AddTextComponentString(CurrentActionMsg)
				DisplayHelpTextFromStringLabel(0, 0, 1, -1)
				if IsControlJustReleased(0, 38) then
					if CurrentAction == 'trucker_menu' then
						SpawnTruck()
					elseif CurrentAction == 'delivered_menu' then
						FinishDelivery()
					end
					CurrentAction = nil
				end
			end
			Wait(sleep)
		end
	end)
		
	CreateThread(function()
		info = NRP_Config.TruckerjobZonesMull.VehicleSpawner
		info.blip = AddBlipForCoord(info.Pos.x, info.Pos.y, info.Pos.z)
		SetBlipSprite(info.blip, info.Id)
		SetBlipDisplay(info.blip, 4)
		SetBlipScale(info.blip, 0.7)
		SetBlipColour(info.blip, info.Colour)
		SetBlipAsShortRange(info.blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(info.Title)
		EndTextCommandSetBlipName(info.blip)
	end)
end


-----{ / S U I C I D E   C O M M A N D }-----
if NRP_Config.SuicideCommand then
    local validWeapons = NRP_Config.SuicideAllowedWeapons

    function KillYourself()
        CreateThread(function()
            local playerPed = PlayerPedId()

            local canSuicide = false
            local foundWeapon = nil

            for i=1, #validWeapons do
                if HasPedGotWeapon(playerPed, GetHashKey(validWeapons[i]), false) then
                    if GetAmmoInPedWeapon(playerPed, GetHashKey(validWeapons[i])) > 0 then
                        canSuicide = true
                        foundWeapon = GetHashKey(validWeapons[i])

                        break
                    end
                end
            end

            if canSuicide then
                local anim = 'mp_suicide'
                if not HasAnimDictLoaded(anim) then
                    RequestAnimDict(anim)
                
                    while not HasAnimDictLoaded(anim) do
                        Wait(1)
                    end
                end

                SetCurrentPedWeapon(playerPed, foundWeapon, true)

                TaskPlayAnim(playerPed, anim, "pistol", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )

                Wait(750)

                SetPedShootsAtCoord(playerPed, 0.0, 0.0, 0.0, 0)
                SetEntityHealth(playerPed, 0)
                SetPedArmour(playerPedId, 0)
            else
                TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du hast keine passende Waffe und / oder keine Munition!", 5000)
            end
        end)
    end

    RegisterCommand(NRP_Config.SuicideCommandName, function()
        KillYourself()  
    end, false)
end


-----{ C R U I S E   C O N T R O L }-----
if NRP_Config.CruiseControl then
    local cruise = false

    RegisterCommand(NRP_Config.CruiseControlCommand, function()
        local getPlayerPed = PlayerPedId()
        if (IsPedInAnyVehicle(getPlayerPed, false)) then
            if cruise == false then
                cruise = true
                currentSpeed = (GetEntitySpeed(GetVehiclePedIsIn(getPlayerPed, false)))
                SetVehicleMaxSpeed(GetVehiclePedIsIn(getPlayerPed, false), currentSpeed)
                TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Tempomat aktiviert", 5000)
            else
                cruise = false
                SetVehicleMaxSpeed(GetVehiclePedIsIn(getPlayerPed, false), 0.0)
                TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Tempomat deaktiviert", 5000)
            end
        end
    end, false)
    RegisterKeyMapping(NRP_Config.CruiseControlCommand, NRP_Config.CruiseControlText, 'keyboard', NRP_Config.CruiseControlKey)
end


-----{ D I S A B L E   V E H I C L E   R E W A R D S }-----
CreateThread(function()
    local playerId = PlayerId()
    while NRP_Config.DisableVehicleRewards do
        Wait(10)
        DisablePlayerVehicleRewards(playerId)
    end
end)


-----{ D I S A B L E   N P C   A T T A C K S }-----
if NRP_Config.DisableNPCAttacks then
    local relationshipTypes = {GetHashKey('PLAYER'), GetHashKey('CIVMALE'), GetHashKey('CIVFEMALE'), GetHashKey('GANG_1'), GetHashKey('GANG_2'), GetHashKey('GANG_9'), GetHashKey('GANG_10'), GetHashKey('AMBIENT_GANG_LOST'), GetHashKey('AMBIENT_GANG_MEXICAN'), GetHashKey('AMBIENT_GANG_FAMILY'), GetHashKey('AMBIENT_GANG_BALLAS'), GetHashKey('AMBIENT_GANG_MARABUNTE'), GetHashKey('AMBIENT_GANG_CULT'), GetHashKey('AMBIENT_GANG_SALVA'), GetHashKey('AMBIENT_GANG_WEICHENG'), GetHashKey('AMBIENT_GANG_HILLBILLY'), GetHashKey('DEALER'), GetHashKey('COP'), GetHashKey('PRIVATE_SECURITY'), GetHashKey('SECURITY_GUARD'), GetHashKey('ARMY'), GetHashKey('MEDIC'), GetHashKey('FIREMAN'), GetHashKey('HATES_PLAYER'), GetHashKey('NO_RELATIONSHIP'), GetHashKey('SPECIAL'), GetHashKey('MISSION2'), GetHashKey('MISSION3'), GetHashKey('MISSION4'), GetHashKey('MISSION5'), GetHashKey('MISSION6'), GetHashKey('MISSION7'), GetHashKey('MISSION8')}

    CreateThread(function()
        while true do
            Wait(2000)
            local playerHash = GetHashKey('PLAYER')

            for k,groupHash in ipairs(relationshipTypes) do
                SetRelationshipBetweenGroups(1, playerHash, groupHash)
                SetRelationshipBetweenGroups(1, groupHash, playerHash)
            end
        end
    end)
end


-----{ L O C K   N P C   V E H I C L E S }-----
CreateThread(function()
    while NRP_Config.LockNPCVehicles do
        Wait(800)
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsTryingToEnter(playerPed)

        if vehicle and DoesEntityExist(vehicle) then
            local driverPed = GetPedInVehicleSeat(vehicle, -1)

            if GetVehicleDoorLockStatus(vehicle) == 7 then
                SetVehicleDoorsLocked(vehicle, 2)
            end

            if driverPed and DoesEntityExist(driverPed) then
                SetPedCanBeDraggedOut(driverPed, false)
            end
        end
    end
end)


-----{ D I S A B L E   H E A L T H   R E G E N E R A T I O N }-----
CreateThread(function()
    local playerId = PlayerId()
    while NRP_Config.DisableHealthRegeneration do
        Wait(10)
        SetPlayerHealthRechargeMultiplier(playerId, 0.0)
    end
end)


-----{ A I   V E H I C L E S   N U M B E R P L A T E }-----
CreateThread(function()
    while NRP_Config.AIVehiclesNumberPlate do
        Wait(0)
        SetDefaultVehicleNumberPlateTextPattern(-1, NRP_Config.AIVehiclesNumberPlateText)
    end
end)


-----{ C A Y O   P E R I C O }-----
if NRP_Config.CayoPerico then
    local requestedIpl = NRP_Config.CayoPericoList
    
    CreateThread(function()
        for i = #requestedIpl, 1, -1 do
            RequestIpl(requestedIpl[i])
            requestedIpl[i] = nil
        end

        requestedIpl = nil
    end)
    
    CreateThread(function()
        while true do
            SetRadarAsExteriorThisFrame()
            SetRadarAsInteriorThisFrame(`h4_fake_islandx`, vec(4700.0, -5145.0), 0, 0)
            Wait(0)
        end
    end)
    
    CreateThread(function()
        SetDeepOceanScaler(0.0)
        local islandLoaded = false
        local islandCoords = vector3(4840.571, -5174.425, 2.0)

        local playerpedid = PlayerPedId()
        local pCoords = GetEntityCoords(playerpedid)

        if #(pCoords - islandCoords) < 2000.0 then
            if not islandLoaded then
                islandLoaded = true
                SetIslandHopperEnabled("HeistIsland", 1)
                SetAiGlobalPathNodesType(1)
                SetScenarioGroupEnabled('Heist_Island_Peds', 1)
                SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Zones', 1, 1)
                SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Disabled_Zones', 0, 1)
            end
        else
            if islandLoaded then
                islandLoaded = false
                SetIslandHopperEnabled("HeistIsland", 0)
                SetAiGlobalPathNodesType(0)
                SetScenarioGroupEnabled('Heist_Island_Peds', 0)
                SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Zones', 0, 0)
                SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Disabled_Zones', 1, 0)
            end
        end
        Wait(5000)
    end)
end


-----{ M O N E Y K I L L }-----
if NRP_Config.Moneykill then
    AddEventHandler('esx:onPlayerDeath', function(data)
        TriggerServerEvent('nrp_Core:moneykill', data.killerServerId)
    end)
end


-----{ K I L L   N O T I F Y }-----
if NRP_Config.KillNotify then
    AddEventHandler('esx:onPlayerDeath', function(data)
        TriggerServerEvent('nrp_Core:killNotify', data.killerServerId)
    end)
end


-----{ A N T I   W E A P O N H I T }-----
CreateThread(function()
    while NRP_Config.AntiWeaponhit do
        Wait(0)
        local playerPedId = PlayerPedId()
        
        if IsPedArmed(playerPedId, 6) then
            DisableControlAction(1, 140, true)
	        DisableControlAction(1, 141, true)
	        DisableControlAction(1, 142, true)
	    end
    end
end)


-----{ I N C A P A C I T A T E D }-----
if NRP_Config.Incapacitated then
    local deadtimer = false

    RegisterNetEvent(NRP_Config.IncapacitatedReviveTrigger)
    AddEventHandler(NRP_Config.IncapacitatedReviveTrigger, function() 
        deadtimer = false

        Wait(1000)

        deadtimer = true

        StartDeathTimer()
        local movement = NRP_Config.IncapacitatedMovementStyle
        WalkMenuStart(movement)
    end)

    function StartDeathTimer()
        local deathtimertime = NRP_Config.IncapacitatedDuration

        CreateThread(function() 
            while deadtimer do
                Wait(0)

                while deathtimertime > 0 and deadtimer do
                    Wait(1000)

                    if deathtimertime > 0 then
                        deathtimertime = deathtimertime - 1
                    elseif time <= 1 then
                        deadtimer = false

                        break
                    end
                end
            end
        end)

        CreateThread(function()
            while deadtimer do
                Wait(1)

                if deathtimertime > 0 then
                    local getPlayerPed = PlayerPedId()
                    local weapon = "WEAPON_UNARMED"
                    SetCurrentPedWeapon(getPlayerPed, GetHashKey(weapon), true)

                    BlockWeaponWheelThisFrame()

                    DisableControlAction(0, 37, true)
                    DisableControlAction(0, 140, true) 
                    DisableControlAction(0, 141, true) 
                    DisableControlAction(0, 142, true) 

                    DrawTimerText(NRP_Config.IncapacitatedText .. secondsToClock(deathtimertime))
                elseif deathtimertime <= 1 then
                    deadtimer = false

                    TriggerEvent(NRP_Config.IncapacitatedSkinchangerTrigger, function(skin)
                        local movement = NRP_Config.IncapacitatedMovementStyle2
                        if skin.sex == 0 then
                            WalkMenuStart(movement)
                        elseif skin.sex == 1 then
                            WalkMenuStart(movement)
                        end
                    end)

                    break
                end
            end
        end)
    end

    function WalkMenuStart(name)
        local playerPedId = PlayerPedId()
        RequestWalking(name)
        SetPedMovementClipset(playerPedId, name, 0.2)
        RemoveAnimSet(name)
    end

    function RequestWalking(set)
        RequestAnimSet(set)
        while not HasAnimSetLoaded(set) do
            Wait(1)
        end 
    end

    function secondsToClock(seconds)
	    local seconds, hours, mins, secs = tonumber(seconds), 0, 0, 0

	    if seconds <= 0 then
		    return 0, 0
	    else
		    local hours = string.format('%02.f', math.floor(seconds / 3600))
		    local mins = string.format('%02.f', math.floor(seconds / 60 - (hours * 60)))
		    local secs = string.format('%02.f', math.floor(seconds - hours * 3600 - mins * 60))

		    return mins .. " Minuten " .. secs .. " Sekunden"
	    end
    end

    function DrawTimerText(text)
        DrawGenericTextThisFrame()
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(0.5)
    end

    function DrawGenericTextThisFrame()
	    SetTextFont(4)
	    SetTextScale(0.0, 0.5)
	    SetTextColour(255, 255, 255, 255)
	    SetTextOutline()
	    SetTextCentre(true)
    end
end


-----{ V E H I C L E   W H I T E L I S T }-----
if NRP_Config.VehicleWhitelist then
    CreateThread(function()
	    while not ESX.GetPlayerData().job do
		    Wait(10)
	    end

	    ESX.PlayerData = ESX.GetPlayerData()
    end)

    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(job)
        ESX.PlayerData.job = job
    end)

    CreateThread(function()
	    while ESX and ESX.PlayerData do
		    local playerPed = PlayerPedId()
		    if playerPed ~= 0 then
			    local vehicle = GetVehiclePedIsIn(playerPed, false)
			    if vehicle ~= 0 then
				    local seat = GetPedInVehicleSeat(vehicle, -1)
				    if seat == playerPed then
					    local isEmergencyJob = getEmergencyJob()
					    if not isEmergencyJob then
						    local isVehicleBlacklisted = getVehicleBlacklist(GetEntityModel(vehicle))
						    if isVehicleBlacklisted then
							    TaskLeaveVehicle(playerPed, vehicle, 1)
							    TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du darfst dieses Fahrzeug nicht fahren!", 5000)
						    end
					    end
				    end
			    end
		    end
		    Wait(700)
	    end
    end)

    function getEmergencyJob()
	    for k,v in ipairs(NRP_Config.VehicleWhitelistJobs) do
		    if ESX.PlayerData.job.name == v then
			    return true
		    end
	    end 
	    return false
    end

    function getVehicleBlacklist(model)
	    for k,v in ipairs(NRP_Config.VehicleWhitelistVehicles) do
		    if model == GetHashKey(v) then
			    return true
		    end
	    end
	    return false
    end
end


-----{ W E A P O N   W H I T E L I S T }-----
if NRP_Config.WeaponWhitelist then
    JOB = nil

    RegisterNetEvent("esx:playerLoaded")
    AddEventHandler("esx:playerLoaded", function(xPlayer)
        JOB = xPlayer.job.name
        main()
    end)

    RegisterNetEvent("esx:setJob", function(job)
        JOB = job.name
    end)

    AddEventHandler("onResourceStart", function(rn)
        if GetCurrentResourceName() == rn then 
            while not ESX.GetPlayerData() do 
                Wait(0)
            end
            JOB = ESX.GetPlayerData().job.name
            main()
        end 
    end)

    function main()
        CreateThread(function()
            while true do 
                local ped = PlayerPedId()
                local bool, weapon = GetCurrentPedWeapon(ped)
                local hasWeapon = weapon ~= GetHashKey("weapon_unarmed")
                if hasWeapon then 
                    if not HasPedWeaponAccess(ped, weapon) then 
                        SetCurrentPedWeapon(ped, GetHashKey("weapon_unarmed"), true)
                    end
                end
                Wait(700)
            end
        end)
    end

    function HasPedWeaponAccess(ped, weaponHash)
        if not isWeaponBlackListed(weaponHash) then 
            return true
        end
        local isWhitelisted, whitelistedWeapons = NRP_Config.WeaponWhitelistWeapons[JOB] ~= nil, NRP_Config.WeaponWhitelistWeapons[JOB]

        if isWhitelisted then 
            for key, weapon in pairs(whitelistedWeapons) do 
                if GetHashKey(weapon) == weaponHash then 
                    return true
                end
            end
        end

        TriggerEvent('nrp_notify', "error", "Nuri Roleplay - Core", "Du darfst diese Waffe nicht benutzen!", 5000)
        return false
    end

    function isWeaponBlackListed(hash)
        for k,v in pairs(NRP_Config.WeaponWhitelistWeapons) do
            for _k, _v in pairs(v) do 
                if GetHashKey(_v) == hash then 
                    return true
                end
            end
        end
        return false
    end
end


-----{ A N T I   P I C K U P S }-----
if NRP_Config.AntiPickups then
    local pickups = NRP_Config.AntiPickupsTypes

    for _, pickup in pairs(pickups) do
        RemoveAllPickupsOfType(pickup)
    end
end


-----{ N P C   E A S T E R E G G }-----
if NRP_Config.NPCEasteregg then
    local NPCPosition = NRP_Config.NPCEastereggPosition
    local isNearPed = false
    local isAtPed = false
    local isPedLoaded = false
    local pedModel = GetHashKey(NRP_Config.NPCEastereggModel)
    local npc

    CreateThread(function()
        while true do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = Vdist(playerCoords, NPCPosition.x, NPCPosition.y, NPCPosition.z)
            isNearPed = false
            isAtPed = false

            if distance < NRP_Config.NPCEastereggDrawDistance then
                isNearPed = true
                if not isPedLoaded then
                    RequestModel(pedModel)
                    while not HasModelLoaded(pedModel) do
                        Wait(10)
                    end

                    npc = CreatePed(4, pedModel, NPCPosition.x, NPCPosition.y, NPCPosition.z - 1.0, NPCPosition.rot, false, false)
                    FreezeEntityPosition(npc, true)
                    SetEntityHeading(npc, NPCPosition.rot)
                    SetEntityInvincible(npc, true)
                    SetBlockingOfNonTemporaryEvents(npc, true)

                    isPedLoaded = true
                end
            end

            if isPedLoaded and not isNearPed then
                DeleteEntity(npc)
                SetModelAsNoLongerNeeded(pedModel)
                isPedLoaded = false
            end

            if distance < 2.0 then
                isAtPed = true
            end
            Wait(500)
        end
    end)

    CreateThread(function()
        while true do
            if isAtPed then
                NRP_Config.Helpnotify(NRP_Config.NPCEastereggText)
                if IsControlJustReleased(0, NRP_Config.NPCEastereggKey) then
                    TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Moin, guck mal auf deine Karte. Dort findest du meinen Kollegen.", 5000)
                    Wait(500)
                    TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Er heißt Erson Pelmeni", 5000)
    
                    local blip = AddBlipForCoord(-442.3857, 1594.0382, 358.4680)
                    SetBlipSprite(blip, NRP_Config.NPCEastereggBlip)
                    SetBlipDisplay(blip, 4)
                    SetBlipScale(blip, NRP_Config.NPCEastereggBlipScale)
                    SetBlipColour(blip, NRP_Config.NPCEastereggBlipColor)
                    SetBlipFlashes(blip, true)
                    SetBlipRoute(blip, true)
                    SetBlipAsShortRange(blip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Erson Pelmeni")
                    EndTextCommandSetBlipName(blip)
    
                    local blipCoords = GetBlipCoords(blip)
    
                    while true do
                        Wait(0)
                        local playerCoords = GetEntityCoords(PlayerPedId())
                        local distance = GetDistanceBetweenCoords(playerCoords, blipCoords, true)
    
                        if distance < 5.0 then
                            RemoveBlip(blip)
    
                            TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Hallo, hier spricht Erson Pelmeni: Habs leider nicht geschaft hier her zu kommen.", 5000)
                            Wait(500)
                            TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Deswegen überweise ich dier 100$", 5000)

                            TriggerServerEvent('nrp_Core:npceasteregg')
                            
                            break
                        end
                    end
                end
            end
            Wait(1)
        end
    end)
end


-----{ / C O O R D S   C O M M A N D }-----
if NRP_Config.Coords then
    RegisterCommand(NRP_Config.CoordsCommand, function(source, args, raw)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        TriggerEvent('nrp_notify', "success", "Nuri Roleplay - Core", "Du bist bei den Koordinaten: " .. playerCoords, 5000)
    end, false)
end


-----{ C H R I S T M A S T R E E S }-----
if NRP_Config.Christmastrees then
    local treeLocations = NRP_Config.ChristmastreesCoords

    function spawnChristmasTree(location)
        local treeModel = GetHashKey("prop_xmas_tree_int")
        RequestModel(treeModel)
    
        while not HasModelLoaded(treeModel) do
            Wait(500)
        end
    
        local treeObject = CreateObject(treeModel, location.x, location.y, location.z, true, false, true)
        SetEntityHeading(treeObject, 0.0)
    end

    for _, location in ipairs(treeLocations) do
    spawnChristmasTree(location)
    end
end


-----{ D I S A B L E   A U T O A I M }-----
CreateThread(function()
    while NRP_Config.DisableAutoAim do
        SetPlayerTargetingMode(3)
        Wait(500)
    end
end)


-----{ I N D I C A T O R S }-----
if NRP_Config.Indicators then
    local leftkey = NRP_Config.IndicatorsLeftKey
    local rightkey = NRP_Config.IndicatorsRightKey
    local bothkey = NRP_Config.IndicatorsBothKey

    CreateThread(function()
        while true do
            Wait(0)
		    if IsControlJustPressed(1, leftkey) then 
			    if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
				    TriggerEvent('IND', 'left')
			    end
		    end

		    if IsControlJustPressed(1, rightkey) then 
			    if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
				    TriggerEvent('IND', 'right')
			    end
		    end
		
		    if IsControlJustPressed(1, bothkey) then
			    if IsPedInAnyVehicle(GetPlayerPed(-1),true) then
				    TriggerEvent('IND', 'left')
				    TriggerEvent('IND', 'right')
			    end
		    end
        end
    end)

    local INDL = false
    local INDR = false

    AddEventHandler('IND', function(dir)
	    CreateThread(function()
		    local Ped = GetPlayerPed(-1)
		    if IsPedInAnyVehicle(Ped, true) then
			    local Veh = GetVehiclePedIsIn(Ped, false)
			    if GetPedInVehicleSeat(Veh, -1) == Ped then
				    if dir == 'left' then
					    INDL = not INDL
					    TriggerServerEvent('INDL', INDL)
				    elseif dir == 'right' then
					    INDR = not INDR
					    TriggerServerEvent('INDR', INDR)
				    end
			    end
		    end
	    end)
    end)

    RegisterNetEvent('updateIndicators')
    AddEventHandler('updateIndicators', function(PID, dir, Toggle)
	local VehChecker = GetVehiclePedIsIn(GetPlayerPed(GetPlayerFromServerId(PID)), false)
	if dir == 'left' then
	    SetVehicleIndicatorLights(VehChecker, 1, Toggle)
	elseif dir == 'right' then
	    SetVehicleIndicatorLights(VehChecker, 0, Toggle)
	end
    end)
end


-----{ R E A L T I M E }-----
if NRP_Config.Realtime then
    SetMillisecondsPerGameMinute(60000)
    RegisterNetEvent("nrp_Realtime:event")
    AddEventHandler("nrp_Realtime:event", function(h, m, s)
        NetworkOverrideClockTime(h, m, s)
    end)
    TriggerServerEvent("nrp_Realtime:event")
end


-----{ D I S A B L E   A T T A C K   W A L K   S T Y L E }-----
if NRP_Config.DisableAttackWalkStyle then
    CreateThread(function()
	while true do
	    Wait(0)
            local playerPedId = PlayerPedId()
	    SetPedUsingActionMode(playerPedId, false, -1, 0)
	end
    end)
end
    ]]
    TriggerClientEvent('nrp_Core:loadclient', _source, code)
end)
