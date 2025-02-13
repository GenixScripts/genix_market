local QBCore = exports['qb-core']:GetCoreObject()
RegisterNetEvent('genix_market:server:buyItems')
AddEventHandler('genix_market:server:buyItems', function(items, paymentMethod)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local totalPrice = 0
    local itemsToGive = {}

    for _, item in pairs(items) do
        totalPrice = totalPrice + (item.price * item.quantity)
        table.insert(itemsToGive, {
            name = item.name,
            amount = item.quantity
        })
    end

    local money = paymentMethod == 'cash' and Player.PlayerData.money['cash'] or Player.PlayerData.money['bank']
    
    if money >= totalPrice then
        if paymentMethod == 'cash' then
            Player.Functions.RemoveMoney('cash', totalPrice)
        else
            Player.Functions.RemoveMoney('bank', totalPrice)
        end

        for _, item in pairs(itemsToGive) do
            Player.Functions.AddItem(item.name, item.amount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], 'add')
            
            for i, shopItem in pairs(Config.Items) do
                if shopItem.name == item.name then
                    Config.Items[i].stock = Config.Items[i].stock - item.amount
                    break
                end
            end
        end

        TriggerClientEvent('QBCore:Notify', src, 'Purchase successful!', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Not enough money!', 'error')
    end

    TriggerClientEvent('genix_market:client:updateStock', -1, Config.Items)
end)
