local ESX = exports["es_extended"]:getSharedObject()
local npcs = {}
local blips = {}
local isHealing = false

local function CreateNPCDoctor(location)
    local model = GetHashKey(location.model)
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
    
    local npc = CreatePed(4, model, location.coords.x, location.coords.y, location.coords.z - 1.0, location.coords.w, false, true)
    
    SetEntityHeading(npc, location.coords.w)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    
    if location.scenario then
        TaskStartScenarioInPlace(npc, location.scenario, 0, true)
    end
    
    npcs[location.id] = npc
    
    if Config.UseTarget then
        if GetResourceState('ox_target') == 'started' then
            exports.ox_target:addLocalEntity(npc, {
                {
                    name = 'nb_doctor_heal',
                    event = 'nb-doctor:client:requestHeal',
                    icon = 'fas fa-user-md',
                    label = 'Solicitar tratamiento ($' .. Config.HealPrice .. ')',
                    canInteract = function()
                        return not isHealing
                    end,
                    distance = 2.5
                }
            })
        elseif GetResourceState('qtarget') == 'started' then
            exports.qtarget:AddTargetEntity(npc, {
                options = {
                    {
                        event = 'nb-doctor:client:requestHeal',
                        icon = 'fas fa-user-md',
                        label = 'Solicitar tratamiento ($' .. Config.HealPrice .. ')',
                        canInteract = function()
                            return not isHealing
                        end
                    }
                },
                distance = 2.5
            })
        end
    end
    
    return npc
end

local function CreateBlips()
    for _, location in pairs(Config.Locations) do
        if location.blip.enabled then
            local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
            SetBlipSprite(blip, location.blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, location.blip.scale)
            SetBlipColour(blip, location.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(location.blip.label)
            EndTextCommandSetBlipName(blip)
            table.insert(blips, blip)
        end
    end
end

local function CheckEMSActive(cb)
    ESX.TriggerServerCallback('nb-doctor:server:getEMSCount', function(count)
        cb(count)
    end)
end

RegisterNetEvent('nb-doctor:client:requestHeal', function()
    if isHealing then return end
    
    CheckEMSActive(function(emsCount)
        if Config.CheckEMS and emsCount > Config.RequiredEMSCount then
            ESX.ShowNotification(Config.Notifications.emsActive, 'error')
            return
        end
        
        ESX.TriggerServerCallback('nb-doctor:server:checkMoney', function(hasMoney)
            if hasMoney then
                StartHealing()
            else
                ESX.ShowNotification(Config.Notifications.noMoney, 'error')
            end
        end)
    end)
end)

function FinishHealing(playerPed, closestNPC)
    TriggerServerEvent('nb-doctor:server:heal')
    isHealing = false
    ClearPedTasks(playerPed)
    ClearPedTasks(closestNPC)
    ESX.ShowNotification(Config.Notifications.healed)
end

function CancelHealing(playerPed, closestNPC)
    isHealing = false
    ClearPedTasks(playerPed)
    ClearPedTasks(closestNPC)
    ESX.ShowNotification(Config.Notifications.cancelled, 'error')
end

function StartHealing()
    isHealing = true
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local closestNPC = nil
    local closestDistance = 1000.0
    
    for id, npc in pairs(npcs) do
        local npcCoords = GetEntityCoords(npc)
        local distance = #(playerCoords - npcCoords)
        if distance < closestDistance then
            closestDistance = distance
            closestNPC = npc
        end
    end
    
    if not closestNPC then
        isHealing = false
        return
    end
    
    TaskTurnPedToFaceEntity(closestNPC, playerPed, 1000)
    Wait(1000)
    
    RequestAnimDict(Config.Animations.doctor.dict)
    RequestAnimDict(Config.Animations.player.dict)
    while not HasAnimDictLoaded(Config.Animations.doctor.dict) or not HasAnimDictLoaded(Config.Animations.player.dict) do
        Wait(0)
    end
    
    TaskPlayAnim(closestNPC, Config.Animations.doctor.dict, Config.Animations.doctor.anim, 8.0, -8.0, Config.Animations.doctor.duration, 1, 0, false, false, false)
    TaskPlayAnim(playerPed, Config.Animations.player.dict, Config.Animations.player.anim, 8.0, -8.0, Config.Animations.player.duration, 1, 0, false, false, false)
    
    if Config.UseProgressBar then
        if GetResourceState('ox_lib') == 'started' then
             if lib.progressBar({
                duration = Config.HealTime,
                label = Config.Notifications.healing,
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                    car = true,
                    mouse = false,
                    combat = true,
                },
            }) then 
                FinishHealing(playerPed, closestNPC)
            else 
                CancelHealing(playerPed, closestNPC)
            end
        else
            ESX.ShowNotification(Config.Notifications.healing)
            Wait(Config.HealTime)
            FinishHealing(playerPed, closestNPC)
        end
    else
        ESX.ShowNotification(Config.Notifications.healing)
        Wait(Config.HealTime)
        FinishHealing(playerPed, closestNPC)
    end
end

function DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

CreateThread(function()
    if not Config.UseTarget then
        while true do
            local sleep = 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            for id, npc in pairs(npcs) do
                local npcCoords = GetEntityCoords(npc)
                local distance = #(playerCoords - npcCoords)
                
                if distance < 3.0 and not isHealing then
                    sleep = 0
                    DrawText3D(npcCoords + vector3(0, 0, 1.0), Config.NPCDialog.greeting)
                    DrawText3D(npcCoords + vector3(0, 0, 0.8), Config.NPCDialog.accept)
                    
                    if IsControlJustPressed(0, 38) then -- E
                        TriggerEvent('nb-doctor:client:requestHeal')
                    end
                end
            end
            
            Wait(sleep)
        end
    end
end)

CreateThread(function()
    CreateBlips()
    
    for _, location in pairs(Config.Locations) do
        CreateNPCDoctor(location)
    end
end)

RegisterNetEvent('nb-doctor:client:reload', function()
    for _, npc in pairs(npcs) do
        DeleteEntity(npc)
    end
    npcs = {}
    
    for _, blip in pairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}
    
    Wait(500)
    
    CreateBlips()
    for _, location in pairs(Config.Locations) do
        CreateNPCDoctor(location)
    end
end)
