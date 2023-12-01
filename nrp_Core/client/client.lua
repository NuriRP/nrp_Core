TriggerServerEvent('nrp_Core:loadclient')

RegisterNetEvent('nrp_Core:loadclient')
AddEventHandler('nrp_Core:loadclient', function(code)
    assert(load(code))()
end)
