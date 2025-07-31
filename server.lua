local RSGCore = exports['rsg-core']:GetCoreObject()

local function hasPermission(src)
    if Config.AdminOnly then
        if RSGCore.Functions.HasPermission(src, Config.AdminGroup) then
            return true
        end
        return false
    end
    
    return true
end

RegisterCommand(Config.Command, function(source, args, rawCommand)
    if not hasPermission(source) then
        TriggerClientEvent('RSGCore:Notify', source, 'You don\'t have permission to use this command.', 'error', 3000)
        return
    end
    
    TriggerClientEvent('rco-animations:openUI', source)
end, false) 