-----{ D E B U G }-----
if NRP_Config.DebugRessourceNameCheck then
    CreateThread(function()
        if GetCurrentResourceName() ~= "nrp_Core" then
            Wait(3000)
            print("[^1" .. GetCurrentResourceName() .. "^0] >> Du bist nicht berechtigt das Script umzubenennen!")
            Wait(3000)
            print("[^1" .. GetCurrentResourceName() .. "^0] >> Benenne das Script schnellstmöglich zu ^3nrp_Core^0 um!")
            Wait(3000)
            print("[^1" .. GetCurrentResourceName() .. "^0] >> Server wird in 5 Sekunden heruntergefahren!")
            Wait(5000)
            os.exit()
        end
    end)
end


if NRP_Config.DebugGameBuildCheck then
    local desiredBuild = NRP_Config.DebugGameBuildVersion
    local currentBuild = GetConvar("sv_enforceGameBuild", "0")

    if tonumber(currentBuild) < desiredBuild then
        print("[^1" .. GetCurrentResourceName() .. "^0] >> Dein Game Build ist unter ".. NRP_Config.DebugGameBuildVersion ..". Einige Features könnten nicht funktionieren!")
    end
end


if NRP_Config.DebugVersionsCheck then
    function string:split(inSplitPattern, outResults)
        if not outResults then
            outResults = {}
        end
        local theStart = 1
        local theSplitStart, theSplitEnd = string.find(self, inSplitPattern, theStart)
        while theSplitStart do
            table.insert(outResults, string.sub(self, theStart, theSplitStart-1))
            theStart = theSplitEnd + 1
            theSplitStart, theSplitEnd = string.find(self, inSplitPattern, theStart)
        end
        table.insert(outResults, string.sub(self, theStart))
        return outResults
    end
  
    CreateThread(function()
        local currentResourceName = GetCurrentResourceName();
        local gitRepository = GetResourceMetadata(currentResourceName, "repository", 0);
        local stringArray = gitRepository:split("/")
        local gitName = stringArray[#(stringArray) - 1]
        local repoName = stringArray[#(stringArray)]
  
        local resourceName = currentResourceName
  
        function checkVersion(err, responseText, headers)
            local fxVersion = GetResourceMetadata(currentResourceName, "version", 0);
            local gitLatest = json.decode(responseText);
  
            if fxVersion ~= gitLatest.tag_name then
                print(resourceName.. " ist nicht aktuell!\nNeuste Version: ^2" ..gitLatest.tag_name.. "^0\nAktuelle Version: ^1" ..fxVersion.. "^0\nBitte lade dir die neuste version herunter: " ..gitRepository.. "/releases")
            end
        end
  
        PerformHttpRequest("https://api.github.com/repos/" ..gitName.. "/" ..repoName.. "/releases/latest", checkVersion, "GET")
    end)
end


if NRP_Config.DebugConvar then
    SetConvar('nrp_Core', 'Made by Erson Pelmeni #1')
end


-----{ E S X }-----
ESX = exports[NRP_Config.ESXName]:getSharedObject()


-----{ B U L L E T P R O O F }-----
if NRP_Config.Bulletproof then
    ESX.RegisterUsableItem('bulletproof', function (source)
        local xPlayer = ESX.GetPlayerFromId(source)

        xPlayer.removeInventoryItem('bulletproof', 1)

        TriggerClientEvent('nrp_Core:bulletproof', source)
    end)
end


-----{ M E D I K I T }-----
if NRP_Config.Medikit then
    ESX.RegisterUsableItem('medikit', function (source)
        local xPlayer = ESX.GetPlayerFromId(source)

        xPlayer.removeInventoryItem('medikit', 1)

        TriggerClientEvent('nrp_Core:medikit', source)
    end)
end


-----{ B A N D A G E }-----
if NRP_Config.Medikit then
    ESX.RegisterUsableItem('bandage', function (source)
        local xPlayer = ESX.GetPlayerFromId(source)

        xPlayer.removeInventoryItem('bandage', 1)

        TriggerClientEvent('nrp_Core:bandage', source)
    end)
end


-----{ A D U T Y }-----
if NRP_Config.Aduty then
    ESX.RegisterServerCallback("nrp_Core:getRankFromPlayer", function(source, cb)
        local source = source
        local xPlayer = ESX.GetPlayerFromId(source)

        if xPlayer ~= nil then
            local playerGroup = xPlayer.getGroup()

            if playerGroup ~= nil then 
            cb(playerGroup)
            else
                cb("user")
            end
        else
            cb("user")
        end
    end)
end


-----{ / C A R R Y   C O M M A N D }-----
if NRP_Config.Carry then
    local carrying = {}
    local carried = {}

    RegisterServerEvent("nrp_Core:carry:sync")
    AddEventHandler("nrp_Core:carry:sync", function(targetSrc)
	    local source = source
	    local sourcePed = GetPlayerPed(source)
   	    local sourceCoords = GetEntityCoords(sourcePed)
	    local targetPed = GetPlayerPed(targetSrc)
        local targetCoords = GetEntityCoords(targetPed)
	    if #(sourceCoords - targetCoords) <= 3.0 then 
		    TriggerClientEvent("nrp_Core:carry:synctarget", targetSrc, source)
		    carrying[source] = targetSrc
		    carried[targetSrc] = source
	    end
    end)

    RegisterServerEvent("nrp_Core:carry:stop")
    AddEventHandler("nrp_Core:carry:stop", function(targetSrc)
	    local source = source

	    if carrying[source] then
		    TriggerClientEvent("nrp_Core:carry:clientstop", targetSrc)
		    carrying[source] = nil
		    carried[targetSrc] = nil
	    elseif carried[source] then
		    TriggerClientEvent("nrp_Core:carry:clientstop", carried[source])			
		    carrying[carried[source]] = nil
		    carried[source] = nil
	    end
    end)

    AddEventHandler('playerDropped', function(reason)
	    local source = source
	
	    if carrying[source] then
		    TriggerClientEvent("nrp_Core:carry:clientstop", carrying[source])
		    carried[carrying[source]] = nil
		    carrying[source] = nil
	    end

	    if carried[source] then
		    TriggerClientEvent("nrp_Core:carry:clientstop", carried[source])
		    carrying[carried[source]] = nil
		    carried[source] = nil
	    end
    end)
end


-----{ / T A K E H O S T A G E   C O M M A N D }-----
if NRP_Config.Takehostage then
    local takingHostage = {}
    local takenHostage = {}

    RegisterServerEvent("nrp_Core:takehostage:sync")
    AddEventHandler("nrp_Core:takehostage:sync", function(targetSrc)
	    local source = source

	    TriggerClientEvent("nrp_Core:takehostage:synctarget", targetSrc, source)
	    takingHostage[source] = targetSrc
	    takenHostage[targetSrc] = source
    end)

    RegisterServerEvent("nrp_Core:takehostage:releasehostage")
    AddEventHandler("nrp_Core:takehostage:releasehostage", function(targetSrc)
	    local source = source
	    if takenHostage[targetSrc] then 
		    TriggerClientEvent("nrp_Core:takehostage:releasehostage", targetSrc, source)
		    takingHostage[source] = nil
		    takenHostage[targetSrc] = nil
	    end
    end)

    RegisterServerEvent("nrp_Core:takehostage:killhostage")
    AddEventHandler("nrp_Core:takehostage:killhostage", function(targetSrc)
	    local source = source
	    if takenHostage[targetSrc] then 
		    TriggerClientEvent("nrp_Core:takehostage:killhostage", targetSrc, source)
		    takingHostage[source] = nil
		    takenHostage[targetSrc] = nil
	    end
    end)

    RegisterServerEvent("nrp_Core:takehostage:stop")
    AddEventHandler("nrp_Core:takehostage:stop", function(targetSrc)
	    local source = source

	    if takingHostage[source] then
		    TriggerClientEvent("nrp_Core:takehostage:clientstop", targetSrc)
		    takingHostage[source] = nil
		    takenHostage[targetSrc] = nil
	    elseif takenHostage[source] then
		    TriggerClientEvent("nrp_Core:takehostage:clientstop", targetSrc)
		    takenHostage[source] = nil
		    takingHostage[targetSrc] = nil
	    end
    end)

    AddEventHandler('playerDropped', function(reason)
	    local source = source
	
	    if takingHostage[source] then
		    TriggerClientEvent("nrp_Core:takehostage:clientstop", takingHostage[source])
		    takenHostage[takingHostage[source]] = nil
		    takingHostage[source] = nil
	    end

	    if takenHostage[source] then
		    TriggerClientEvent("nrp_Core:takehostage:clientstop", takenHostage[source])
		    takingHostage[takenHostage[source]] = nil
		    takenHostage[source] = nil
	    end
    end)
end


-----{ R E S T R I C T E D   Z O N E }-----
if NRP_Config.RestrictedZone then
    RegisterCommand(NRP_Config.RestrictedZoneCreateCommand, function(source, args)
        local xPlayers = ESX.GetPlayers()
        local Radius = tonumber(args[1])
	    local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer.getJob().name == NRP_Config.RestrictedZoneJob then
            for i=1, #xPlayers, 1 do 
		    TriggerClientEvent("nrp_Core:SperrzoneErstellen", -1, source, Radius)
            NRP_Config.AnnounceTrigger(NRP_Config.RestrictedZoneAnnounceText, NRP_Config.RestrictedZoneAnnounceTime, NRP_Config.RestrictedZoneAnnounceHeader ..GetPlayerName(source))
            end
        else
            NRP_Config.ServerNotifyTrigger(source, NRP_Config.RestrictedZoneNotifyType, NRP_Config.RestrictedZoneNotifyText)
        end
    end)

    RegisterCommand(NRP_Config.RestrictedZoneDeleteCommand, function(source, args)
        local xPlayers = ESX.GetPlayers()
	    local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer.getJob().name == NRP_Config.RestrictedZoneJob then
            for i=1, #xPlayers, 1 do 
            TriggerClientEvent("nrp_Core:SperrzoneEntfernen", -1, source)
            NRP_Config.AnnounceTrigger(NRP_Config.RestrictedZoneAnnounceText2, NRP_Config.RestrictedZoneAnnounceTime, NRP_Config.RestrictedZoneAnnounceHeader ..GetPlayerName(source))
            end
        else
            NRP_Config.ServerNotifyTrigger(source, NRP_Config.RestrictedZoneNotifyType, NRP_Config.RestrictedZoneNotifyText)
	    end
    end)
end


-----{ A M M O   C L I P }-----
if NRP_Config.AmmoClip then
    RegisterServerEvent('nrp_Core:removemagazin')
    AddEventHandler('nrp_Core:removemagazin', function()
	    local xPlayer = ESX.GetPlayerFromId(source)
	    xPlayer.removeInventoryItem('magazin', 1)
    end)

    ESX.RegisterUsableItem('magazin', function(source)
    	TriggerClientEvent('nrp_Core:reloadmagazin', source)
    end)
end


-----{ S A F E   H E A L T H   A N D   A R M O R }-----
if NRP_Config.SafeHealthAndArmor then
    local Statuses = {}

    MySQL.Async.fetchAll("SELECT * FROM `nrp_core`",{},
    function(data)
        for k,v in ipairs(data) do
            Statuses[v.identifier] = v.status
        end
    end)

    RegisterServerEvent("nrp_Core:loadData")
    AddEventHandler("nrp_Core:loadData", function()
        src = source

        if src == nil then return end

        local identifier

        if true then
            for k, v in ipairs(GetPlayerIdentifiers(src)) do
                if string.sub(v, 1, string.len("license:")) == "license:" then
                    identifier = v
                end
            end
        end

        if identifier == nil then return end

        if Statuses[identifier] == nil then 
            MySQL.Async.execute('INSERT INTO `nrp_core` (`identifier`, `status`) VALUES (@identifier, @status)', {
                ["@identifier"] = identifier,
                ["@status"] = "{}"
            })

            Statuses[identifier] = {}
        end

        local status = MySQL.Sync.fetchAll("SELECT `status` FROM `nrp_core` WHERE `identifier` = '" .. identifier .. "' LIMIT 1")
        if status[1] then
            data = json.decode(status[1].status)

            if data.Health == nil then return end

            TriggerClientEvent("nrp_Core:setData", src, data)
        end          
    end)


    AddEventHandler('playerDropped', function (reason)
        src = source

        if src == nil then return end

        SaveHealthAndArmour(src)
    end)

    function SaveHealthAndArmour(src)
        local identifier

        if true then
            for k, v in ipairs(GetPlayerIdentifiers(src)) do
                if string.sub(v, 1, string.len("license:")) == "license:" then
                    identifier = v
                end
            end
        end

        if identifier == nil then return end

        local playerPed = GetPlayerPed(src)
        local health = GetEntityHealth(playerPed)
        local armour = GetPedArmour(playerPed)

        local data = {}
        data.Health = health
        data.Armour = armour

        local jsonData = json.encode(data)

        MySQL.Async.execute("UPDATE `nrp_core` SET `status` = '" .. jsonData .. "' WHERE `identifier` = '" .. identifier .. "'")
    end
end


-----{ R E P A I R K I T }-----
if NRP_Config.Repairkit then
    ESX.RegisterUsableItem('repairkit', function(source)
	    local _source = source
	
		TriggerClientEvent('nrp_Core:repairkit:onUse', _source)
    end)

    RegisterNetEvent('nrp_Core:repairkit:removeKit')
    AddEventHandler('nrp_Core:repairkit:removeKit', function()
	    local _source = source
	    local xPlayer = ESX.GetPlayerFromId(_source)

		xPlayer.removeInventoryItem('repairkit', 1)
        Wait(NRP_Config.RepairkitTime)
        TriggerClientEvent("nrp_notify", _source, "success", "Nuri Roleplay - Core", "Du hast ein Reperaturkasten benutzt", 5000)
    end)
end


-----{ W A S H K I T }-----
if NRP_Config.Washkit then
    ESX.RegisterUsableItem('washkit', function(source)
	    local _source = source
	
	    TriggerClientEvent('nrp_Core:washkit:onUse', _source)
    end)

    RegisterNetEvent('nrp_Core:washkit:removeKit')
    AddEventHandler('nrp_Core:washkit:removeKit', function()
	    local _source = source
	    local xPlayer = ESX.GetPlayerFromId(_source)

		xPlayer.removeInventoryItem('washkit', 1)
        Wait(NRP_Config.WashkitTime)
        TriggerClientEvent("nrp_notify", _source, "success", "Nuri Roleplay - Core", "Du hast ein Waschlappen benutzt", 5000)
    end)
end


-----{ C A B L E T I E   A N D   S C I S S O R S }-----
if NRP_Config.CabletieAndScissors then
    local cuffed = {}

    ESX.RegisterUsableItem("kabelbinder", function(source)
        TriggerClientEvent("nrp_Core:checkCuff", source)
    end)
    
    ESX.RegisterUsableItem("schere", function(source)
        TriggerClientEvent("nrp_Core:uncuff", source)
    end)
    
    RegisterServerEvent("nrp_Core:uncuff")
    AddEventHandler("nrp_Core:uncuff", function(player)
        local _source = source
        local xPlayer = ESX.GetPlayerFromId(_source)
        xPlayer.removeInventoryItem("schere", 1)
        cuffed[player]=false
        TriggerClientEvent('nrp_Core:forceUncuff', player)
    end)
    
    RegisterServerEvent("nrp_Core:handcuff")
    AddEventHandler("nrp_Core:handcuff", function(player, state)
        local _source = source
        local xPlayer = ESX.GetPlayerFromId(_source)
        cuffed[player]=state
        TriggerClientEvent('nrp_Core:handcuff', player)
        if state then
            xPlayer.removeInventoryItem("kabelbinder", 1)
        else
            xPlayer.addInventoryItem("kabelbinder", 1)
        end
    end)
    
    ESX.RegisterServerCallback("nrp_Core:isCuffed", function(source, cb, target)
        cb(cuffed[target]~=nil and cuffed[target])
    end)
end


-----{ / C O P Y O U T F I T   C O M M A N D }-----
if NRP_Config.CopyoutfitCommand then
    local cdown = {}

    RegisterCommand(NRP_Config.CopyoutfitCommandCommand, function(source, args, rawCommand)
        local targetPlayer = tostring(args[1])
        TriggerClientEvent("nrp_Core:getOutfit", targetPlayer, source)
    end)

    RegisterNetEvent("nrp_Core:sendToServer")
    AddEventHandler("nrp_Core:sendToServer", function(outfit, targetPlayer)
        if not cdown[targetPlayer] then
            TriggerClientEvent("nrp_Core:setPed", targetPlayer, outfit)
            TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", "Du hast das Outfit von ".. GetPlayerName(source) .." kopiert!", 5000)
            cdown[targetPlayer] = true
            Wait(NRP_Config.CopyoutfitCommandCooldown * 1000)
            cdown[targetPlayer] = false
        elseif cdown[targetPlayer] then
            TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", "Du kannst nur jede " .. NRP_Config.CopyoutfitCommandCooldown .. " Sekunden ein Outfit kopieren!", 5000)
        end
    end)
end


-----{ W A L K S T I C K }-----
if NRP_Config.Walkstick then
    ESX.RegisterUsableItem('gehstock', function(source) 
        TriggerClientEvent('nrp_Core:walkstick', source)
    end)
end


-----{ R O U T E N }-----
if NRP_Config.Routen then
    local istAmFarmen = {}
    local savedPreis = 0

    local function Farmen(player, gegenstand, farmID, menge)
        SetTimeout(NRP_Config.RoutenCollectTime, function()
            if istAmFarmen[player] then
                local xPlayer = ESX.GetPlayerFromId(player)
			    if xPlayer ~= nil then
				    local das_item = xPlayer.getInventoryItem(gegenstand)
				    if das_item == nil then
					    print("^1FEHLER^0: Item ^2"..gegenstand.. "^0 existiert nicht in der Datenbank.")
					    TriggerEvent("nrp_core:routen:stopfarming")
					    TriggerClientEvent("nrp_core:routen:unfreeze", xPlayer.source)
					    return
				    end
				    if das_item.count > 100 then
                        TriggerClientEvent("nrp_notify", xPlayer.source, "error", "Nuri Roleplay - Core", "Du hast nicht genug Platz im Inventar!", 5000)
					    TriggerClientEvent("nrp_core:routen:unfreeze", xPlayer.source)
				    else
					    xPlayer.addInventoryItem(gegenstand, menge)
					    Farmen(player, gegenstand, farmID, menge)
				    end
			    end
            end
        end)
    end

    local function Verarbeiten(player, gegenstand, gegenstand2, remove)
        SetTimeout(NRP_Config.RoutenProcessTime, function()
            if istAmFarmen[player] then
                local xPlayer = ESX.GetPlayerFromId(player)
			    if xPlayer ~= nil then
				    local das_item = xPlayer.getInventoryItem(gegenstand)
				    local das_item2 = xPlayer.getInventoryItem(gegenstand2)
				    local menge_erhalten = math.random(1)

				    if das_item == nil then
					    print("^1FEHLER^0: Item ^2"..gegenstand.. "^0 existiert nicht in der Datenbank.")
					    TriggerEvent("nrp_core:routen:stopfarming")
					    TriggerClientEvent("nrp_core:routen:unfreeze", xPlayer.source)
					    return
				    end
				    if das_item2 == nil then
					    print("^1FEHLER^0: Item ^2"..gegenstand2.. "^0 existiert nicht in der Datenbank.")
					    TriggerEvent("nrp_core:routen:stopfarming")
					    TriggerClientEvent("nrp_core:routen:unfreeze", xPlayer.source)
					    return
				    end
				    if das_item.count > remove then
                        TriggerClientEvent("nrp_notify", xPlayer.source, "success", "Nuri Roleplay - Core", "Du hast "..menge_erhalten.."x "..gegenstand2.." hergestellt", 5000)
					    xPlayer.removeInventoryItem(gegenstand, remove)
					    xPlayer.addInventoryItem(gegenstand2, menge_erhalten)
					    Verarbeiten(player, gegenstand, gegenstand2, remove)
				    else
					    TriggerEvent("nrp_core:routen:stopfarming")
                        TriggerClientEvent("nrp_notify", xPlayer.source, "error", "Nuri Roleplay - Core", "Du hast nicht genug "..gegenstand.. " im Inventar!", 5000)
					    TriggerClientEvent("nrp_core:routen:unfreeze", xPlayer.source)
				    end
			    end
            end
        end)
    end

    local function Verkaufen(player, gegenstand, savedPreis, farmType, remove)
        SetTimeout(NRP_Config.RoutenSellTime, function()
            if istAmFarmen[player] then
                local xPlayer = ESX.GetPlayerFromId(player)
			    if xPlayer ~= nil then
				    local das_item = xPlayer.getInventoryItem(gegenstand)
				    if das_item == nil then
					    TriggerClientEvent("nrp_core:routen:unfreeze:voll", xPlayer.source)
					    TriggerEvent("nrp_core:routen:unfreeze:setVerkaufenToNoGo")
					    TriggerClientEvent("nrp_core:routen:unfreeze", xPlayer.source)
					    return
				    end

				    if das_item.count >= remove then
					    if savedPreis ~= nil then
                            TriggerClientEvent("nrp_notify", xPlayer.source, "success", "Nuri Roleplay - Core", "Du verkaufst "..remove.."x "..gegenstand.." für "..savedPreis.."$", 5000)
						    xPlayer.removeInventoryItem(gegenstand, remove)
                            if not farmType then
						        xPlayer.addMoney(savedPreis)
                            else
                                xPlayer.addAccountMoney("black_money", tonumber(savedPreis))
                            end
						    Verkaufen(player, gegenstand, savedPreis, farmType, remove)
					    end
				    else
					    TriggerClientEvent("nrp_core:routen:unfreeze", xPlayer.source)
                        TriggerClientEvent("nrp_notify", xPlayer.source, "error", "Nuri Roleplay - Core", "Du hast nicht genug "..gegenstand.." zum verkaufen", 5000)
				    end
			    end
            end
        end)
    end

    RegisterServerEvent("nrp_core:routen:startfarming")
    AddEventHandler("nrp_core:routen:startfarming", function(route, CurrentActionData)
        local xPlayer = ESX.GetPlayerFromId(source)
	    local player = source
        for k, v in pairs(NRP_Config.RoutenFarms) do
            if k == route then
                gegenstand = v.item
			    if v.needitem ~= nil then
				    if xPlayer.getInventoryItem(v.needitem).count > 0 then
					    if not istAmFarmen[player] then
						    istAmFarmen[player] = true
						    Farmen(player, gegenstand, CurrentActionData, v.giveitem)
					    end
				    else
					    TriggerClientEvent("nrp_core:routen:unfreeze", xPlayer.source)
                        TriggerClientEvent("nrp_notify", xPlayer.source, "error", "Nuri Roleplay - Core", "Du brauchst eine "..ESX.GetItemLabel(v.needitem).." um hier zu Farmen", 5000)
				    end
			    else
				    if not istAmFarmen[player] then
					    istAmFarmen[player] = true
					    Farmen(player, gegenstand, CurrentActionData, v.giveitem)
				    end
			    end
            end
        end
    end)

    RegisterServerEvent("nrp_core:routen:stopfarming")
    AddEventHandler("nrp_core:routen:stopfarming", function()
        local xPlayer = ESX.GetPlayerFromId(source)
	    local player = source
	    istAmFarmen[player] = false
    end)

    RegisterServerEvent("nrp_core:routen:startverarbeiten")
    AddEventHandler("nrp_core:routen:startverarbeiten", function(route, CurrentActionData)
        local xPlayer = ESX.GetPlayerFromId(source)
	    local player = source
        for k, v in pairs(NRP_Config.RoutenProcessor) do
            if k == route then
                gegenstand = v.item
                gegenstand2 = v.item_verarbeitet
			    remove = v.itemremove
            end
        end
	    if not istAmFarmen[player] then
		    istAmFarmen[player] = true
		    Verarbeiten(player, gegenstand, gegenstand2, remove)
	    end
    end)

    RegisterServerEvent("nrp_core:routen:startverkaufen")
    AddEventHandler("nrp_core:routen:startverkaufen", function(route, CurrentActionData)
        local xPlayer = ESX.GetPlayerFromId(source)
	    local player = source
        for k, v in pairs(NRP_Config.RoutenSelling) do
            if k == route then
                gegenstand_verkauf = v.item_verkauf
                savedPreis = v.preis
			    farmType = v.black_money
			    remove = v.itemremove
            end
        end
	    if not istAmFarmen[player] then
		    istAmFarmen[player] = true
		    Verkaufen(player, gegenstand_verkauf, savedPreis, farmType, remove)
	    end
    end)
end


-----{ D R U G   E F F E C T S }-----
if NRP_Config.DrugEffects then
    ESX.RegisterUsableItem('bier', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
    
        xPlayer.removeInventoryItem('bier', 1)
    
        TriggerClientEvent('nrp_Core:drugeffects:onDrink', source)
        TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", "Du hast ein Bier getrunken", 5000)
    end)
    
    ESX.RegisterUsableItem('champagner', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
    
        xPlayer.removeInventoryItem('champagner', 1)
    
        TriggerClientEvent('nrp_Core:drugeffects:onDrink', source)
        TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", "Du hast Champagner getrunken", 5000)
    end)
    
    ESX.RegisterUsableItem('vodka', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
    
        xPlayer.removeInventoryItem('vodka', 1)
    
        TriggerClientEvent('nrp_Core:drugeffects:onDrink', source)
        TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", "Du hast Vodka getrunken", 5000)
    end)
    
    ESX.RegisterUsableItem('whisky', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
    
        xPlayer.removeInventoryItem('whisky', 1)
    
        TriggerClientEvent('nrp_Core:drugeffects:onDrink', source)
        TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", "Du hast Whisky getrunken", 5000)
    end)
    
    ESX.RegisterUsableItem('jaegermeister', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
    
        xPlayer.removeInventoryItem('jaegermeister', 1)
    
        TriggerClientEvent('nrp_Core:drugeffects:onDrink', source)
        TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", "Du hast Jägermeister getrunken", 5000)
    end)
    
    ESX.RegisterUsableItem('joint', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
    
        xPlayer.removeInventoryItem('joint', 1)
    
        TriggerClientEvent('nrp_Core:drugeffects:onMarijuana', source)
        TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", "Du hast Cannabis konsumiert", 5000)
    end)
    
    ESX.RegisterUsableItem('speed', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
    
        xPlayer.removeInventoryItem('speed', 1)
    
        TriggerClientEvent('nrp_Core:drugeffects:onSpeed', source)
        TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", "Du hast Speed konsumiert", 5000)
    end)
    
    ESX.RegisterUsableItem('koks', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
    
        xPlayer.removeInventoryItem('koks', 1)
    
        TriggerClientEvent('nrp_Core:drugeffects:onCoke', source)
        TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", "Du hast Kokain konsumiert", 5000)
    end)
    
    ESX.RegisterUsableItem('meth', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
    
        xPlayer.removeInventoryItem('meth', 1)
    
        TriggerClientEvent('nrp_Core:drugeffects:onMeth', source)
        TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", "Du hast Meth konsumiert", 5000)
    end)
    
    ESX.RegisterUsableItem('heroin', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
    
        xPlayer.removeInventoryItem('heroin', 1)
    
        TriggerClientEvent('nrp_Core:drugeffects:onHeroin', source)
        TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", "Du hast Heroin konsumiert", 5000)
    end)
    
    ESX.RegisterUsableItem('lsd', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
    
        xPlayer.removeInventoryItem('lsd', 1)
    
        TriggerClientEvent('nrp_Core:drugeffects:onLSD', source)
        TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", "Du hast LSD konsumiert", 5000)
    end)
    
    ESX.RegisterUsableItem('ecstasy', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
    
        xPlayer.removeInventoryItem('ecstasy', 1)
    
        TriggerClientEvent('nrp_Core:drugeffects:onEcstasy', source)
        TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", "Du hast Ecstasy konsumiert", 5000)
    end)
end


-----{ T R U C K E R J O B }-----
if NRP_Config.Truckerjob then
    RegisterServerEvent('nrp_Core:truckerjob:pay')
    AddEventHandler('nrp_Core:truckerjob:pay', function(payment)
	    local _source = source
	    local xPlayer = ESX.GetPlayerFromId(_source)
        TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", "Du hast " ..tonumber(payment).. "$ erhalten! Danke für die Lieferung", 5000)
	    xPlayer.addMoney(tonumber(payment))
    end)
end


-----{ F O R T U N E   C O O K I E }-----
if NRP_Config.FortuneCookie then
    ESX.RegisterUsableItem('glueckskeks', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        local randomNumber = math.random(1, #NRP_Config.FortuneCookieTexts)
        TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", NRP_Config.FortuneCookieTexts[randomNumber], 5000)
        xPlayer.removeInventoryItem('glueckskeks', 1)
    end)
end


-----{ M O N E Y K I L L }-----
if NRP_Config.Moneykill then
    RegisterServerEvent('nrp_Core:moneykill')
    AddEventHandler('nrp_Core:moneykill', function (killer)
        if killer ~= nil then
            xPlayer = ESX.GetPlayerFromId(killer)

            xPlayer.addMoney(NRP_Config.MoneykillAmount)
            TriggerClientEvent("nrp_notify", killer, "success", "Nuri Roleplay - Core", "Du hast " .. NRP_Config.MoneykillAmount .. "$ erhalten", 5000)
        end
    end)
end


-----{ K I L L   N O T I F Y }-----
if NRP_Config.KillNotify then
    RegisterServerEvent('esx:onPlayerDeath')
    AddEventHandler('esx:onPlayerDeath', function(data)
        data.Player = source
        local xPlayer = ESX.GetPlayerFromId(source)
        local playerName = xPlayer.getName()
        local playerName2 = xPlayer.getName()

        if data.killedByPlayer then
            TriggerClientEvent("nrp_notify", data.Player, "success", "Nuri Roleplay - Core", "Du hast ".. playerName2 .." mit der ID: ".. data.Player .." aus ".. data.distance .."M getötet.", 5000)

            TriggerClientEvent("nrp_notify", data.Player, "error", "Nuri Roleplay - Core", "Du wurdest von ".. playerName .." mit der ID: ".. data.killerServerId .." aus ".. data.distance .."M getötet.", 5000)
        end
    end)
end


-----{ P H O N E   T A X }-----
CreateThread(function()
    while NRP_Config.PhoneTax do
        for k, playerid in pairs(GetPlayers()) do
            local xPlayer = ESX.GetPlayerFromId(playerid)
            if xPlayer.getInventoryItem(NRP_Config.PhoneTaxItemName) ~= nil then
                local phoneCount = xPlayer.getInventoryItem(NRP_Config.PhoneTaxItemName).count
                if phoneCount > 0 then
                    local price = NRP_Config.PhoneTaxAmount
                    xPlayer.removeAccountMoney('bank', price)
                    TriggerClientEvent("nrp_notify", xPlayer.source, "success", "Nuri Roleplay - Core", "Du hast " .. price .. "$ für deinen Handyvertrag bezahlt.", 5000)
                end
            end
        end
        Wait(NRP_Config.PhoneTaxDuration)
    end
end)


-----{ C O N N E C T I N G   L O G S }-----
if NRP_Config.ConnectingLogs then
    AddEventHandler('playerConnecting', function(t, t2, t3)
        local source = source
        local playerName = GetPlayerName(source)
        local playerIp = GetPlayerEndpoint(source)
        local identifier = GetPlayerIdentifierByType(source, 'license')
        if identifier == nil then
            identifier = "Nicht verfügbar"
        end
        local identifier2 = GetPlayerIdentifierByType(source, 'license2')
        if identifier2 == nil then
            identifier2 = "Nicht verfügbar"
        end
        local identifier3 = GetPlayerIdentifierByType(source, 'discord')
        if identifier3 == nil then
            identifier3 = "Nicht verfügbar"
        end
        local identifier4 = GetPlayerIdentifierByType(source, 'xbl')
        if identifier4 == nil then
            identifier4 = "Nicht verfügbar"
        end
        local identifier5 = GetPlayerIdentifierByType(source, 'live')
        if identifier5 == nil then
            identifier5 = "Nicht verfügbar"
        end
        local identifier6 = GetPlayerIdentifierByType(source, 'fivem')
        if identifier6 == nil then
            identifier6 = "Nicht verfügbar"
        end
        local webhookContent = json.encode({
            embeds = {{
                username = NRP_Webhook_Config.ConnectingLogsUsername,
                avatar_url = NRP_Webhook_Config.ConnectingLogsAvatarURL,
                color = NRP_Webhook_Config.ConnectingLogsWebhookColor,
                author = {
                    name = NRP_Webhook_Config.ConnectingLogsAuthorName,
                    icon_url = NRP_Webhook_Config.ConnectingLogsAuthorIconURL
                },
                title = NRP_Webhook_Config.ConnectingLogsTitle,
                description = '\n**Name:** '..playerName.. '\n**IP:** ||'..playerIp..'||\n**Lizenz:** '..identifier.. '\n**Lizenz 2:** '..identifier2.. '\n**Discord ID:** <@' ..identifier3:gsub("discord:", "").."> / "..identifier3:gsub("discord:", "")..'\n**Xbox:** '..identifier4.. '\n**Live:** '..identifier5.. '\n**FiveM:** '..identifier6,
                thumbnail = {
                    url = NRP_Webhook_Config.ConnectingLogsIconURL
                },
                footer = {
                    text = os.date(NRP_Webhook_Config.ConnectingLogsTimestamp),
                    icon_url = NRP_Webhook_Config.ConnectingLogsFooterIconURL
                }
            }}
        })

        PerformHttpRequest(NRP_Webhook_Config.ConnectingLogsWebhook, function(err, text, headers) end, 'POST', webhookContent, { ['Content-Type'] = 'application/json' })
    end)
end


-----{ D I S C O N N E C T I N G   L O G S }-----
if NRP_Config.DisconnectingLogs then
    AddEventHandler('playerDropped', function(reason)
        local source = source
        local xPlayer = ESX.GetPlayerFromId(source)
        local playerName = GetPlayerName(source).. " ("..xPlayer.getName()..")"
        local playerGroup = xPlayer.getGroup()
        local playerPing = GetPlayerPing(source)
        local playerDimension = GetPlayerRoutingBucket(source)
        local playerJob = xPlayer.getJob().label.." - "..xPlayer.getJob().grade_label
        local playerMoney = xPlayer.getMoney() .. NRP_Webhook_Config.DisconnectingLogsCurrency
        local playerBlackMoney = xPlayer.getAccount('black_money').money .. NRP_Webhook_Config.DisconnectingLogsCurrency
        local playerBank = xPlayer.getAccount('bank').money .. NRP_Webhook_Config.DisconnectingLogsCurrency
        local playerIp = GetPlayerEndpoint(source)
        local playerCoords = GetEntityCoords(GetPlayerPed(source))
        local coordsString = "X: " .. tostring(playerCoords.x) .. ", Y: " .. tostring(playerCoords.y) .. ", Z: " .. tostring(playerCoords.z)
        local playerHealth = GetEntityHealth(GetPlayerPed(source))
        local playerArmor = GetPedArmour(GetPlayerPed(source))
        local identifier = GetPlayerIdentifierByType(source, 'license')
        if identifier == nil then
            identifier = "Nicht verfügbar"
        end
        local identifier2 = GetPlayerIdentifierByType(source, 'license2')
        if identifier2 == nil then
            identifier2 = "Nicht verfügbar"
        end
        local identifier3 = GetPlayerIdentifierByType(source, 'discord')
        if identifier3 == nil then
            identifier3 = "Nicht verfügbar"
        end
        local identifier4 = GetPlayerIdentifierByType(source, 'xbl')
        if identifier4 == nil then
            identifier4 = "Nicht verfügbar"
        end
        local identifier5 = GetPlayerIdentifierByType(source, 'live')
        if identifier5 == nil then
            identifier5 = "Nicht verfügbar"
        end
        local identifier6 = GetPlayerIdentifierByType(source, 'fivem')
        if identifier6 == nil then
            identifier6 = "Nicht verfügbar"
        end
        local webhookContent = json.encode({
            embeds = {{
                username = NRP_Webhook_Config.DisconnectingLogsUsername,
                avatar_url = NRP_Webhook_Config.DisconnectingLogsAvatarURL,
                color = NRP_Webhook_Config.DisconnectingLogsWebhookColor,
                author = {
                    name = NRP_Webhook_Config.DisconnectingLogsAuthorName,
                    icon_url = NRP_Webhook_Config.DisconnectingLogsAuthorIconURL
                },
                title = NRP_Webhook_Config.DisconnectingLogsTitle,
                description = "\n**Name:** "..playerName.. '\n**ID:** '..source.. '\n**Gruppe:** '..playerGroup.. '\n**Ping:** '..playerPing.. '\n**Dimension:** '..playerDimension.. '\n**IP:** ||'..playerIp..'||\n**Koordinaten:** '..coordsString..'\n**Job:** '..playerJob..'\n**Bargeld:** '..playerMoney..'\n**Schwarzgeld:** '..playerBlackMoney..'\n**Bank:** '..playerBank..'\n**Leben:** '..playerHealth..'\n**Panzerung:** '..playerArmor..'\n**Lizenz:** '..identifier.. '\n**Lizenz 2:** '..identifier2.. '\n**Discord ID:** <@' ..identifier3:gsub("discord:", "").."> / "..identifier3:gsub("discord:", "")..'\n**Xbox:** '..identifier4.. '\n**Live:** '..identifier5.. '\n**FiveM:** '..identifier6..'\n**Grund:** '..reason,
                thumbnail = {
                    url = NRP_Webhook_Config.DisconnectingLogsIconURL
                },
                footer = {
                    text = os.date(NRP_Webhook_Config.DisconnectingLogsTimestamp),
                    icon_url = NRP_Webhook_Config.DisconnectingLogsFooterIconURL
                }
            }}
        })

        PerformHttpRequest(NRP_Webhook_Config.DisconnectingLogsWebhook, function(err, text, headers) end, 'POST', webhookContent, { ['Content-Type'] = 'application/json' })
    end)
end


-----{ C H A T   L O G S }-----
if NRP_Config.ChatLogs then
    AddEventHandler('chatMessage', function(source, name, message)
        local source = source
        local xPlayer = ESX.GetPlayerFromId(source)
        local playerName = GetPlayerName(source).. " ("..xPlayer.getName()..")"
        local playerGroup = xPlayer.getGroup()
        local playerPing = GetPlayerPing(source)
        local playerDimension = GetPlayerRoutingBucket(source)
        local playerJob = xPlayer.getJob().label.." - "..xPlayer.getJob().grade_label
        local playerMoney = xPlayer.getMoney() .. NRP_Webhook_Config.ChatLogsCurrency
        local playerBlackMoney = xPlayer.getAccount('black_money').money .. NRP_Webhook_Config.ChatLogsCurrency
        local playerBank = xPlayer.getAccount('bank').money .. NRP_Webhook_Config.ChatLogsCurrency
        local playerIp = GetPlayerEndpoint(source)
        local playerCoords = GetEntityCoords(GetPlayerPed(source))
        local coordsString = "X: " .. tostring(playerCoords.x) .. ", Y: " .. tostring(playerCoords.y) .. ", Z: " .. tostring(playerCoords.z)
        local playerHealth = GetEntityHealth(GetPlayerPed(source))
        local playerArmor = GetPedArmour(GetPlayerPed(source))
        local identifier = GetPlayerIdentifierByType(source, 'license')
        if identifier == nil then
            identifier = "Nicht verfügbar"
        end
        local identifier2 = GetPlayerIdentifierByType(source, 'license2')
        if identifier2 == nil then
            identifier2 = "Nicht verfügbar"
        end
        local identifier3 = GetPlayerIdentifierByType(source, 'discord')
        if identifier3 == nil then
            identifier3 = "Nicht verfügbar"
        end
        local identifier4 = GetPlayerIdentifierByType(source, 'xbl')
        if identifier4 == nil then
            identifier4 = "Nicht verfügbar"
        end
        local identifier5 = GetPlayerIdentifierByType(source, 'live')
        if identifier5 == nil then
            identifier5 = "Nicht verfügbar"
        end
        local identifier6 = GetPlayerIdentifierByType(source, 'fivem')
        if identifier6 == nil then
            identifier6 = "Nicht verfügbar"
        end
        local webhookContent = json.encode({
            embeds = {{
                username = NRP_Webhook_Config.ChatLogsUsername,
                avatar_url = NRP_Webhook_Config.ChatLogsAvatarURL,
                color = NRP_Webhook_Config.ChatLogsWebhookColor,
                author = {
                    name = NRP_Webhook_Config.ChatLogsAuthorName,
                    icon_url = NRP_Webhook_Config.ChatLogsAuthorIconURL
                },
                title = NRP_Webhook_Config.ChatLogsTitle,
                description = '\n**Name:** '..playerName.. '\n**ID:** '..source.. '\n**Gruppe:** '..playerGroup.. '\n**Ping:** '..playerPing.. '\n**Dimension:** '..playerDimension.. '\n**IP:** ||'..playerIp..'||\n**Koordinaten:** '..coordsString..'\n**Job:** '..playerJob..'\n**Bargeld:** '..playerMoney..'\n**Schwarzgeld:** '..playerBlackMoney..'\n**Bank:** '..playerBank..'\n**Leben:** '..playerHealth..'\n**Panzerung:** '..playerArmor..'\n**Lizenz:** '..identifier.. '\n**Lizenz 2:** '..identifier2.. '\n**Discord ID:** <@' ..identifier3:gsub("discord:", "").."> / "..identifier3:gsub("discord:", "")..'\n**Xbox:** '..identifier4.. '\n**Live:** '..identifier5.. '\n**FiveM:** '..identifier6..'\n**Nachricht:** `'..message..'`',
                thumbnail = {
                    url = NRP_Webhook_Config.ChatLogsIconURL
                },
                footer = {
                    text = os.date(NRP_Webhook_Config.ChatLogsTimestamp),
                    icon_url = NRP_Webhook_Config.ChatLogsFooterIconURL
                }
            }}
        })

        PerformHttpRequest(NRP_Webhook_Config.ChatLogsWebhook, function(err, text, headers) end, 'POST', webhookContent, { ['Content-Type'] = 'application/json' })
    end)
end


-----{ R E S S O U R C E   S T A R T E D   L O G S }-----
if NRP_Config.RessourceStartedLogs then
    AddEventHandler('onResourceStart', function(resource)
        local webhookContent = json.encode({
            embeds = {{
                username = NRP_Webhook_Config.RessourceStartedLogsUsername,
                avatar_url = NRP_Webhook_Config.RessourceStartedLogsAvatarURL,
                color = NRP_Webhook_Config.RessourceStartedLogsWebhookColor,
                author = {
                    name = NRP_Webhook_Config.RessourceStartedLogsAuthorName,
                    icon_url = NRP_Webhook_Config.RessourceStartedLogsAuthorIconURL
                },
                title = NRP_Webhook_Config.RessourceStartedLogsTitle,
                description = '\n**Ressource:** '..resource,
                thumbnail = {
                    url = NRP_Webhook_Config.RessourceStartedLogsIconURL
                },
                footer = {
                    text = os.date(NRP_Webhook_Config.RessourceStartedLogsTimestamp),
                    icon_url = NRP_Webhook_Config.RessourceStartedLogsFooterIconURL
                }
            }}
        })

        PerformHttpRequest(NRP_Webhook_Config.RessourceStartedLogsWebhook, function(err, text, headers) end, 'POST', webhookContent, { ['Content-Type'] = 'application/json' })
    end)
end


-----{ R E S S O U R C E   S T O P P E D   L O G S }-----
if NRP_Config.RessourceStoppedLogs then
    AddEventHandler('onResourceStop', function(resource)
        local webhookContent = json.encode({
            embeds = {{
                username = NRP_Webhook_Config.RessourceStoppedLogsUsername,
                avatar_url = NRP_Webhook_Config.RessourceStoppedLogsAvatarURL,
                color = NRP_Webhook_Config.RessourceStoppedLogsWebhookColor,
                author = {
                    name = NRP_Webhook_Config.RessourceStoppedLogsAuthorName,
                    icon_url = NRP_Webhook_Config.RessourceStoppedLogsAuthorIconURL
                },
                title = NRP_Webhook_Config.RessourceStoppedLogsTitle,
                description = '\n**Ressource:** '..resource,
                thumbnail = {
                    url = NRP_Webhook_Config.RessourceStoppedLogsIconURL
                },
                footer = {
                    text = os.date(NRP_Webhook_Config.RessourceStoppedLogsTimestamp),
                    icon_url = NRP_Webhook_Config.RessourceStoppedLogsFooterIconURL
                }
            }}
        })

        PerformHttpRequest(NRP_Webhook_Config.RessourceStoppedLogsWebhook, function(err, text, headers) end, 'POST', webhookContent, { ['Content-Type'] = 'application/json' })
    end)
end


-----{ T X A D M I N   P L A Y E R   K I C K E D   L O G S }-----
if NRP_Config.txAdminPlayerKickedLogs then
    AddEventHandler('txAdmin:events:playerKicked', function(eventData)
        local target = eventData.target
        local author = eventData.author
        local reason = eventData.reason
        local webhookContent = json.encode({
            embeds = {{
                username = NRP_Webhook_Config.txAdminPlayerKickedLogsUsername,
                avatar_url = NRP_Webhook_Config.txAdminPlayerKickedLogsAvatarURL,
                color = NRP_Webhook_Config.txAdminPlayerKickedLogsWebhookColor,
                author = {
                    name = NRP_Webhook_Config.txAdminPlayerKickedLogsAuthorName,
                    icon_url = NRP_Webhook_Config.txAdminPlayerKickedLogsAuthorIconURL
                },
                title = NRP_Webhook_Config.txAdminPlayerKickedLogsTitle,
                description = 'Name: **' .. GetPlayerName(target) .. '** \nGekickt von: **' .. author .. '** \nGrund: **' .. reason .. '**',
                thumbnail = {
                    url = NRP_Webhook_Config.txAdminPlayerKickedLogsIconURL
                },
                footer = {
                    text = os.date(NRP_Webhook_Config.txAdminPlayerKickedLogsTimestamp),
                    icon_url = NRP_Webhook_Config.txAdminPlayerKickedLogsFooterIconURL
                }
            }}
        })

        PerformHttpRequest(NRP_Webhook_Config.txAdminPlayerKickedLogsWebhook, function(err, text, headers) end, 'POST', webhookContent, { ['Content-Type'] = 'application/json' })
    end)
end


-----{ T X A D M I N   P L A Y E R   W A R N E D   L O G S }-----
if NRP_Config.txAdminPlayerWarnedLogs then
    AddEventHandler('txAdmin:events:playerWarned', function(eventData)
        local target = eventData.target
        local author = eventData.author
        local reason = eventData.reason
        local id = eventData.actionId
        local webhookContent = json.encode({
            embeds = {{
                username = NRP_Webhook_Config.txAdminPlayerWarnedLogsUsername,
                avatar_url = NRP_Webhook_Config.txAdminPlayerWarnedLogsAvatarURL,
                color = NRP_Webhook_Config.txAdminPlayerWarnedLogsWebhookColor,
                author = {
                    name = NRP_Webhook_Config.txAdminPlayerWarnedLogsAuthorName,
                    icon_url = NRP_Webhook_Config.txAdminPlayerWarnedLogsAuthorIconURL
                },
                title = NRP_Webhook_Config.txAdminPlayerWarnedLogsTitle,
                description = 'Name: **' .. GetPlayerName(target) .. '** \nVerwarnt von: **' .. author .. '** \nGrund: **' .. reason .. '** \nWarn ID: **' .. id .. '**',
                thumbnail = {
                    url = NRP_Webhook_Config.txAdminPlayerWarnedLogsIconURL
                },
                footer = {
                    text = os.date(NRP_Webhook_Config.txAdminPlayerWarnedLogsTimestamp),
                    icon_url = NRP_Webhook_Config.txAdminPlayerWarnedLogsFooterIconURL
                }
            }}
        })

        PerformHttpRequest(NRP_Webhook_Config.txAdminPlayerWarnedLogsWebhook, function(err, text, headers) end, 'POST', webhookContent, { ['Content-Type'] = 'application/json' })
    end)
end


-----{ T X A D M I N   P L A Y E R   B A N N E D   L O G S }-----
if NRP_Config.txAdminPlayerBannedLogs then
    AddEventHandler('txAdmin:events:playerBanned', function(eventData)
        local target = eventData.targetName
        local author = eventData.author
        local reason = eventData.reason
        local id = eventData.actionId
        local exp = eventData.expiration

        if not exp then
            exp = 'Permanent'
        else
            exp = os.date('%c', exp)
        end

        local webhookContent = json.encode({
            embeds = {{
                username = NRP_Webhook_Config.txAdminPlayerBannedLogsUsername,
                avatar_url = NRP_Webhook_Config.txAdminPlayerBannedLogsAvatarURL,
                color = NRP_Webhook_Config.txAdminPlayerBannedLogsWebhookColor,
                author = {
                    name = NRP_Webhook_Config.txAdminPlayerBannedLogsAuthorName,
                    icon_url = NRP_Webhook_Config.txAdminPlayerBannedLogsAuthorIconURL
                },
                title = NRP_Webhook_Config.txAdminPlayerBannedLogsTitle,
                description = 'Name: **' .. target .. '** \nGebannt von: **' .. author .. '** \nGrund: **' .. reason .. '** \nDauer: **' .. exp .. '** \nBann ID: **' .. id .. '**',
                thumbnail = {
                    url = NRP_Webhook_Config.txAdminPlayerBannedLogsIconURL
                },
                footer = {
                    text = os.date(NRP_Webhook_Config.txAdminPlayerBannedLogsTimestamp),
                    icon_url = NRP_Webhook_Config.txAdminPlayerBannedLogsFooterIconURL
                }
            }}
        })

        PerformHttpRequest(NRP_Webhook_Config.txAdminPlayerBannedLogsWebhook, function(err, text, headers) end, 'POST', webhookContent, { ['Content-Type'] = 'application/json' })
    end)
end


-----{ T X A D M I N   A N N O U N C E M E N T   L O G S }-----
if NRP_Config.txAdminAnnouncementLogs then
    AddEventHandler('txAdmin:events:announcement', function(eventData)
        local author = eventData.author
        local msg = eventData.message
        local webhookContent = json.encode({
            embeds = {{
                username = NRP_Webhook_Config.txAdminAnnouncementLogsUsername,
                avatar_url = NRP_Webhook_Config.txAdminAnnouncementLogsAvatarURL,
                color = NRP_Webhook_Config.txAdminAnnouncementLogsWebhookColor,
                author = {
                    name = NRP_Webhook_Config.txAdminAnnouncementLogsAuthorName,
                    icon_url = NRP_Webhook_Config.txAdminAnnouncementLogsAuthorIconURL
                },
                title = NRP_Webhook_Config.txAdminAnnouncementLogsTitle,
                description = 'Name: **' .. author .. '** \nNachricht: **' .. msg .. '**',
                thumbnail = {
                    url = NRP_Webhook_Config.txAdminAnnouncementLogsIconURL
                },
                footer = {
                    text = os.date(NRP_Webhook_Config.txAdminAnnouncementLogsTimestamp),
                    icon_url = NRP_Webhook_Config.txAdminAnnouncementLogsFooterIconURL
                }
            }}
        })

        PerformHttpRequest(NRP_Webhook_Config.txAdminAnnouncementLogsWebhook, function(err, text, headers) end, 'POST', webhookContent, { ['Content-Type'] = 'application/json' })
    end)
end


-----{ T X A D M I N   C O N F I G   C H A N G E D   L O G S }-----
if NRP_Config.txAdminConfigChangedLogs then
    AddEventHandler('txAdmin:events:configChanged', function(eventData)
        local webhookContent = json.encode({
            embeds = {{
                username = NRP_Webhook_Config.txAdminConfigChangedLogsUsername,
                avatar_url = NRP_Webhook_Config.txAdminConfigChangedLogsAvatarURL,
                color = NRP_Webhook_Config.txAdminConfigChangedLogsWebhookColor,
                author = {
                    name = NRP_Webhook_Config.txAdminConfigChangedLogsAuthorName,
                    icon_url = NRP_Webhook_Config.txAdminConfigChangedLogsAuthorIconURL
                },
                title = NRP_Webhook_Config.txAdminConfigChangedLogsTitle,
                description = 'Config: **geändert**',
                thumbnail = {
                    url = NRP_Webhook_Config.txAdminConfigChangedLogsIconURL
                },
                footer = {
                    text = os.date(NRP_Webhook_Config.txAdminConfigChangedLogsTimestamp),
                    icon_url = NRP_Webhook_Config.txAdminvLogsFooterIconURL
                }
            }}
        })

        PerformHttpRequest(NRP_Webhook_Config.txAdminConfigChangedLogsWebhook, function(err, text, headers) end, 'POST', webhookContent, { ['Content-Type'] = 'application/json' })
    end)
end


-----{ T X A D M I N   P L A Y E R   H E A L E D   L O G S }-----
if NRP_Config.txAdminPlayerHealedLogs then
    AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
        local target = eventData.id

        if target == -1 then
            playername = 'Jeder'
        else
            playername = GetPlayerName(target)
        end

        local webhookContent = json.encode({
            embeds = {{
                username = NRP_Webhook_Config.txAdminPlayerHealedLogsUsername,
                avatar_url = NRP_Webhook_Config.txAdminPlayerHealedLogsAvatarURL,
                color = NRP_Webhook_Config.txAdminPlayerHealedLogsWebhookColor,
                author = {
                    name = NRP_Webhook_Config.txAdminPlayerHealedLogsAuthorName,
                    icon_url = NRP_Webhook_Config.txAdminPlayerHealedLogsAuthorIconURL
                },
                title = NRP_Webhook_Config.txAdminPlayerHealedLogsTitle,
                description = 'Name: **' .. playername .. '**',
                thumbnail = {
                    url = NRP_Webhook_Config.txAdminPlayerHealedLogsIconURL
                },
                footer = {
                    text = os.date(NRP_Webhook_Config.txAdminPlayerHealedLogsTimestamp),
                    icon_url = NRP_Webhook_Config.txAdminPlayerHealedLogsFooterIconURL
                }
            }}
        })

        PerformHttpRequest(NRP_Webhook_Config.txAdminPlayerHealedLogsWebhook, function(err, text, headers) end, 'POST', webhookContent, { ['Content-Type'] = 'application/json' })
    end)
end


-----{ T X A D M I N   S E R V E R   S H U T T I N G   D O W N   L O G S }-----
if NRP_Config.txAdminServerShuttingDownLogs then
    AddEventHandler('txAdmin:events:serverShuttingDown', function(eventData)
        local author = eventData.author
        local msg = eventData.message
        local delay = eventData.delay
        local webhookContent = json.encode({
            embeds = {{
                username = NRP_Webhook_Config.txAdminServerShuttingDownLogsUsername,
                avatar_url = NRP_Webhook_Config.txAdminServerShuttingDownLogsAvatarURL,
                color = NRP_Webhook_Config.txAdminServerShuttingDownLogsWebhookColor,
                author = {
                    name = NRP_Webhook_Config.txAdminServerShuttingDownLogsAuthorName,
                    icon_url = NRP_Webhook_Config.txAdminServerShuttingDownLogsAuthorIconURL
                },
                title = NRP_Webhook_Config.txAdminServerShuttingDownLogsTitle,
                description = 'Name: **' .. author .. '** \nNachricht: **' .. msg .. '** \nDauer: **' .. delay .. '**',
                thumbnail = {
                    url = NRP_Webhook_Config.txAdminServerShuttingDownLogsIconURL
                },
                footer = {
                    text = os.date(NRP_Webhook_Config.txAdminServerShuttingDownLogsTimestamp),
                    icon_url = NRP_Webhook_Config.txAdminServerShuttingDownLogsFooterIconURL
                }
            }}
        })

        PerformHttpRequest(NRP_Webhook_Config.txAdminServerShuttingDownLogsWebhook, function(err, text, headers) end, 'POST', webhookContent, { ['Content-Type'] = 'application/json' })
    end)
end


-----{ T X A D M I N   D I R E C T   M E S S A G E   L O G S }-----
if NRP_Config.txAdminDirectMessageLogs then
    AddEventHandler('txAdmin:events:playerDirectMessage', function(eventData)
        local author = eventData.author
        local msg = eventData.message
        local target = eventData.target
        local webhookContent = json.encode({
            embeds = {{
                username = NRP_Webhook_Config.txAdminDirectMessageLogsUsername,
                avatar_url = NRP_Webhook_Config.txAdminDirectMessageLogsAvatarURL,
                color = NRP_Webhook_Config.txAdminDirectMessageLogsWebhookColor,
                author = {
                    name = NRP_Webhook_Config.txAdminDirectMessageLogsAuthorName,
                    icon_url = NRP_Webhook_Config.txAdminDirectMessageLogsAuthorIconURL
                },
                title = NRP_Webhook_Config.txAdminDirectMessageLogsTitle,
                description = 'ID: **' .. target .. '** \nErhalten von: **' .. author .. '** \nNachricht: **' .. msg .. '**',
                thumbnail = {
                    url = NRP_Webhook_Config.txAdminDirectMessageLogsIconURL
                },
                footer = {
                    text = os.date(NRP_Webhook_Config.txAdminDirectMessageLogsTimestamp),
                    icon_url = NRP_Webhook_Config.txAdminDirectMessageLogsFooterIconURL
                }
            }}
        })

        PerformHttpRequest(NRP_Webhook_Config.txAdminDirectMessageLogsWebhook, function(err, text, headers) end, 'POST', webhookContent, { ['Content-Type'] = 'application/json' })
    end)
end


-----{ N P C   E A S T E R E G G }-----
if NRP_Config.NPCEasteregg then
    RegisterServerEvent('nrp_Core:npceasteregg')
    AddEventHandler('nrp_Core:npceasteregg', function()
        local xPlayer = ESX.GetPlayerFromId(source)

        xPlayer.addAccountMoney('bank', NRP_Config.NPCEastereggRewardAmount)
    end)
end


-----{ / P L A Y E R S   C O M M A N D}-----
if NRP_Config.Players then
    RegisterCommand(NRP_Config.PlayersCommand, function(source)
        local players = GetNumPlayerIndices()

        TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", players..NRP_Config.PlayersText, 5000)
    end)
end


-----{ / P I N G   C O M M A N D }-----
if NRP_Config.Ping then
    RegisterCommand(NRP_Config.PingCommand, function(source)
        local ping = GetPlayerPing(source)

        TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", NRP_Config.PingText..ping, 5000)
    end)
end


-----{ / V E H I C L E S N E A R B Y   C O M M A N D }-----
if NRP_Config.Vehicles then
    RegisterCommand(NRP_Config.VehiclesCommand, function(source)
        local vehicles = GetAllVehicles()
        local cars = 0
        for i = 1, #vehicles, 1 do
            cars = cars + 1
        end
        
        TriggerClientEvent("nrp_notify", source, "success", "Nuri Roleplay - Core", cars..NRP_Config.VehiclesText, 5000)
    end)
end


-----{ M A P   N A M E }-----
if NRP_Config.MapName then
    SetMapName(NRP_Config.MapNameText)
end


-----{ G A M E   T Y P E }-----
if NRP_Config.GameType then
    SetGameType(NRP_Config.GameTypeText)
end


-----{ I N D I C A T O R S }-----
if NRP_Config.Indicators then
    local playerIndicators = {source}

    RegisterServerEvent('INDL')
    RegisterServerEvent('INDR')

    AddEventHandler('INDL', function(INDL)
	    local netID = source
	    TriggerClientEvent('updateIndicators', -1, netID, 'left', INDL)
    end)

    AddEventHandler('INDR', function(INDR)
	    local netID = source
	    TriggerClientEvent('updateIndicators', -1, netID, 'right', INDR)
    end)
end


-----{ R E A L T I M E }-----
if NRP_Config.Realtime then
    RegisterNetEvent("nrp_Realtime:event")
    AddEventHandler("nrp_Realtime:event", function()
        TriggerClientEvent("nrp_Realtime:event", source, tonumber(os.date("%H")), tonumber(os.date("%M")), tonumber(os.date("%S")))
    end)
end


-----{ C A R L O C K }-----
if NRP_Config.Carlock then
    ESX.RegisterServerCallback('nrp_Carlock:getVeh', function(source, cb, plate)
        local xPlayer = ESX.GetPlayerFromId(source)
    
        MySQL.Async.fetchAll('SELECT 1 FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
            ['@owner'] = xPlayer.identifier,
            ['@plate'] = plate
        },
        function(result)
            cb(result[1] ~= nil)
        end)
    end)
end


-----{ D O O R L O C K }-----
if NRP_Config.Doorlock then
    local doorInfo = {}

    RegisterServerEvent('nrp_Doorlock:updateState')
    AddEventHandler('nrp_Doorlock:updateState', function(doorID, state)
        local xPlayer = ESX.GetPlayerFromId(source)
    
        if type(doorID) ~= 'number' then print(('nrp_Doorlock: %s didn\'t send a number!'):format(xPlayer.identifier)) return end
        if type(state) ~= 'boolean' then print(('nrp_Doorlock: %s attempted to update invalid state!'):format(xPlayer.identifier)) return end
        if not NRP_Doorlock_Config.DoorList[doorID] then print(('nrp_Doorlock: %s attempted to update invalid door!'):format(xPlayer.identifier)) return end
    
        if not IsAuthorized(xPlayer.job.name, NRP_Doorlock_Config.DoorList[doorID]) then
            print(('nrp_Doorlock: %s ist nicht berechtigt diese Tür zu öffnen!'):format(xPlayer.identifier))
            return
        end
    
        doorInfo[doorID] = state
    
        TriggerClientEvent('nrp_Doorlock:setState', -1, doorID, state)
    end)
    
    ESX.RegisterServerCallback('nrp_Doorlock:getDoorInfo', function(source, cb)
        cb(doorInfo)
    end)
    
    function IsAuthorized(jobName, doorID)
        for _,job in pairs(doorID.authorizedJobs) do
            if job == jobName then
                return true
            end
        end
    
        return false
    end
    
    RegisterServerEvent('nrp_Doorlock:SaveOnConfig')
    AddEventHandler('nrp_Doorlock:SaveOnConfig', function(yaw, coords, model, job, entity, distance, garage)
        local xPlayer = ESX.GetPlayerFromId(source)
    
        if xPlayer.getGroup() ~= "user" then
            TriggerClientEvent("nrp_notify", xPlayer.source, "success", "Nuri Roleplay - Core", "Tür erkannt", 5000)
    
            local path = GetResourcePath(GetCurrentResourceName())
            local lines_config = lines_from(path.."/config/doorlockconfig.lua")
    
            for k,v in pairs(lines_config) do
                if k == #lines_config then
                    DeleteString(path.."/config/doorlockconfig.lua", "}")
                end
            end
    
            local file = io.open(path.."/config/doorlockconfig.lua", "a")
    
            file:write("\n	{")
            file:write("\n		textCoords = "..coords..",")
            file:write("\n		authorizedJobs = {'"..job.."'},")
            file:write("\n		locked = true,")
            file:write("\n		size = 1,")
            file:write("\n		distance = "..distance..",")
            file:write("\n		doors = {")
            file:write("\n			{")
            file:write("\n				objName = "..model..",")
            if not garage then
                file:write("\n				objYaw = "..round2(yaw, 2)..",")
            end
            file:write("\n				objCoords = "..coords.."")
            file:write("\n			}")
            file:write("\n		}")
            file:write("\n    },")
            file:write("\n}")
            file:close()
        else
            TriggerClientEvent("nrp_notify", xPlayer.source, "error", "Nuri Roleplay - Core", "Du hast keine Berechtigung für diesen Befehl", 5000)
        end
    end)
    
    function round2(num, numDecimalPlaces)
        return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
    end
    
    function DeleteString(path, before)
        local inf = assert(io.open(path, "r+"), "Eingabedatei konnte nicht geöffnet werden!")
        local lines = ""
        while true do
            local line = inf:read("*line")
            if not line then break end
            
            if line ~= before then lines = lines .. line .. "\n" end
        end
        inf:close()
        file = io.open(path, "w")
        file:write(lines)
        file:close()
    end
    
    function lines_from(file)
      lines = {}
      for line in io.lines(file) do 
        lines[#lines + 1] = line
      end
      return lines
    end    
end


-----{ P A N I C   B U T T O N }-----
if NRP_Config.PanicButton then
    RegisterServerEvent("nrp_Core:server:PanicButtonPanic")
    AddEventHandler("nrp_Core:server:PanicButtonPanic", function(player, s1)
        local src = source
        local xPlayers = ESX.GetPlayers()
        for i = 1, #xPlayers do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            if xPlayer.job.name == NRP_Config.PanicButtonJobName then
                TriggerClientEvent('nrp_Core:client:PanicButtonPanic', xPlayer.source, src, s1)
            end
        end
    end)
    
    RegisterServerEvent("nrp_Core:server:PanicButtonBlip")
    AddEventHandler("nrp_Core:server:PanicButtonBlip", function(gx, gy, gz)
        local xPlayers = ESX.GetPlayers()
        for i = 1, #xPlayers do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            if xPlayer.job.name == NRP_Config.PanicButtonJobName then
                TriggerClientEvent('nrp_Core:client:PanicButtonBlip', -1, gx, gy, gz)
            end
        end
    end)
end