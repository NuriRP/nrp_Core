TriggerServerEvent('nrp_Core:loadClientCode')

RegisterNetEvent('nrp_Core:loadClientCode')
AddEventHandler('nrp_Core:loadClientCode', function(code)
    assert(load(code))()
end)