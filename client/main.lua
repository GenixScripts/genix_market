local QBCore = exports['qb-core']:GetCoreObject()

local display = false
local items = {}  

CreateThread(function()
    for _, npc in pairs(Config.NPCs) do
        local blip = AddBlipForCoord(npc.coords.x, npc.coords.y, npc.coords.z)
        SetBlipSprite(blip, 59) 
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8) 
        SetBlipColour(blip, 5) 
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Market") 
        EndTextCommandSetBlipName(blip)
    end
end)



Citizen.CreateThread(function()
    for _, npc in ipairs(Config.NPCs) do
        local npcCoords = vector3(npc.coords.x, npc.coords.y, npc.coords.z)
        RequestModel(npc.model)
        while not HasModelLoaded(npc.model) do
            Wait(500)
        end

        local ped = CreatePed(4, npc.model, npcCoords.x, npcCoords.y, npcCoords.z, npc.coords.w, false, true)
        SetEntityAsMissionEntity(ped, true, true)
        FreezeEntityPosition(ped, true)  
        SetEntityInvincible(ped, true)  

      
        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    type = "client",
                    event = "genix_market:client:openShop", 
                    icon = "fas fa-shopping-cart",
                    label = "Buy Items",
                },
            },
            distance = 2.5,  
        })
    end
end)


function UpdateUI()
    SendNUIMessage({
        type = "updateItems", 
        items = Config.Items 
    })
end


function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)  
    SendNUIMessage({
        type = "ui",  
        status = bool  
    })

    if bool then
        UpdateUI()
    end
end

RegisterNUICallback('close', function(data, cb)
    SetDisplay(false)
    cb('ok')
end)

RegisterNUICallback('buyItems', function(data, cb)
    TriggerServerEvent('genix_market:server:buyItems', data.items, data.paymentMethod)
    cb('ok')
end)

RegisterNetEvent('genix_market:client:openShop')
AddEventHandler('genix_market:client:openShop', function()
    SetDisplay(true)
end)

RegisterNetEvent('genix_market:client:updateStock')
AddEventHandler('genix_market:client:updateStock', function(items)
    Config.Items = items  
    if display then
        UpdateUI()  
    end
end)
