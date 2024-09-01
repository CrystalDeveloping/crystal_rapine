ESX = exports.es_extended:getSharedObject()

ESX.RegisterServerCallback('checkPolice', function(source, cb)
    local cops = 0
    local xPlayers = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == CrystalDDeev.jobPolice then
            cops = cops + 1
        end
    end
    cb(cops)
end)

RegisterNetEvent('crystal:daiSoldi')
AddEventHandler('crystal:daiSoldi', function (soldiRapina)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addAccountMoney(CrystalDDeev.soldi, soldiRapina)
end)