ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('nb-doctor:server:checkMoney', function(source, cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then 
        cb(false)
        return
    end
    
    local cash = xPlayer.getMoney()
    local bank = xPlayer.getAccount('bank').money
    
    if cash >= Config.HealPrice then
        cb(true)
    elseif bank >= Config.HealPrice then
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('nb-doctor:server:getEMSCount', function(source, cb)
    local emsCount = 0
    local xPlayers = ESX.GetPlayers()
    
    for i = 1, #xPlayers do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer and xPlayer.job.name == 'ambulance' then
            emsCount = emsCount + 1
        end
    end
    
    cb(emsCount)
end)

RegisterNetEvent('nb-doctor:server:heal', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local cash = xPlayer.getMoney()
    
    if cash >= Config.HealPrice then
        xPlayer.removeMoney(Config.HealPrice)
    else
        xPlayer.removeAccountMoney('bank', Config.HealPrice)
    end
    
    TriggerClientEvent('esx_ambulancejob:revive', src)
    
    if Config.EnableLogs then
        print('[nb-doctor] ' .. GetPlayerName(src) .. ' (ID: ' .. src .. ') fue curado por el NPC Doctor por $' .. Config.HealPrice)
    end
end)

ESX.RegisterCommand('reloadnpcdoctors', 'admin', function(xPlayer, args, showError)
    TriggerClientEvent('nb-doctor:client:reload', -1)
end, true, {help = 'Recargar NPCs médicos'})

CreateThread(function()
    local resourceName = GetCurrentResourceName()
    local currentVersion = GetResourceMetadata(resourceName, 'version', 0)
    
    if currentVersion then
        print('^2[' .. resourceName .. ']^0 Versión ^2' .. currentVersion .. '^0 iniciada correctamente (ESX)')
    end
end)
