local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('nb-doctor:server:checkMoney', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then 
        cb(false)
        return
    end
    
    local cash = Player.Functions.GetMoney('cash')
    local bank = Player.Functions.GetMoney('bank')
    
    if cash >= Config.HealPrice then
        cb(true)
    elseif bank >= Config.HealPrice then
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('nb-doctor:server:getEMSCount', function(source, cb)
    local emsCount = 0
    local Players = QBCore.Functions.GetPlayers()
    
    for i = 1, #Players do
        local Player = QBCore.Functions.GetPlayer(Players[i])
        if Player and Player.PlayerData.job and Player.PlayerData.job.name == 'ambulance' and Player.PlayerData.job.onduty then
            emsCount = emsCount + 1
        end
    end
    
    cb(emsCount)
end)

RegisterNetEvent('nb-doctor:server:heal', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local cash = Player.Functions.GetMoney('cash')
    
    if cash >= Config.HealPrice then
        Player.Functions.RemoveMoney('cash', Config.HealPrice, 'npc-doctor-heal')
    else
        Player.Functions.RemoveMoney('bank', Config.HealPrice, 'npc-doctor-heal')
    end
    
    TriggerClientEvent('hospital:client:Revive', src)
    
    if Config.EnableLogs then
        TriggerEvent('qb-log:server:CreateLog', 'npcdoctor', 'NPC Doctor', 'green', 
            '**' .. GetPlayerName(src) .. '** (citizenid: *' .. Player.PlayerData.citizenid .. '* | id: *' .. src .. '*) fue curado por el NPC Doctor por $' .. Config.HealPrice)
    end
end)

QBCore.Commands.Add('reloadnpcdoctors', 'Recargar NPCs médicos', {}, false, function(source, args)
    TriggerClientEvent('nb-doctor:client:reload', -1)
end, 'admin')

CreateThread(function()
    local resourceName = GetCurrentResourceName()
    local currentVersion = GetResourceMetadata(resourceName, 'version', 0)
    
    if currentVersion then
        print('^2[' .. resourceName .. ']^0 Versión ^2' .. currentVersion .. '^0 iniciada correctamente')
    end
end)