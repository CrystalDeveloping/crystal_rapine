ESX = exports.es_extended:getSharedObject()

local timerAschermo = false
local tempoRestante = 0
local rapinaAttiva = {}
local soldiRapina = 0
local rapinaK = nil
local rapinaV = nil
local rapinaLoc = nil

Citizen.CreateThread(function ()
    while true do
        Wait(5000)
        for k, v in pairs(CrystalDDeev.rapine) do
            TriggerEvent('crystal:updateMarker', {
                id = 'rapina' .. k,
                pos = v.posrapina,
                rot = vector3(90.0, 90.0, 90.0),
                scale = vector3(1.0, 1.0, 1.0),
                textureName = 'marker',
                saltaggio = true,
                msg = 'Premi [E] per iniziare una rapina',
                action = function()
                    if IsPedArmed(PlayerPedId(), 4) then
                        startaRapina(k, v)
                    else
                        ESX.ShowNotification('Devi essere armato per fare una rapina')
                    end
                end
            })
        end
    end
end)

function startaRapina(k, v)
    ESX.TriggerServerCallback('checkPolice', function(cops) 
        if cops >= v.minPolice then
            if rapinaAttiva[k] then
                ESX.ShowNotification('Una rapina già è attiva in questa zona')
                return
            end
            soldiRapina = v.guadagno
            rapinaK = k
            rapinaV = v
            rapinaLoc = v.posrapina
            rapinaAttiva[k] = true
            startTimer(v.tempoRapina)
            CrystalDDeev.mandaSegnalazione()
        else
            ESX.ShowNotification('Non c\'è abbastanza polizia per fare una rapina')
        end
    end)
end

function startTimer(tempo)
    tempoRestante = tempo
    timerAschermo = true
end

Citizen.CreateThread(function()
    while true do
        Wait(1000)
        if timerAschermo then
            if tempoRestante > 0 then
                tempoRestante = tempoRestante - 1
            else
                timerAschermo = false
                if rapinaK then
                    rapinaAttiva[rapinaK] = false
                    rapinaK = nil
                    rapinaLoc = nil
                end
                TriggerServerEvent('crystal:daiSoldi', soldiRapina)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(500)
        if timerAschermo and rapinaLoc then
            local pCoords = GetEntityCoords(PlayerPedId())
            local dist = Vdist(pCoords, rapinaLoc)

            if dist > rapinaV.maxDistance then
                timerAschermo = false
                rapinaAttiva[rapinaK] = false
                rapinaK = nil
                rapinaLoc = nil
                ESX.ShowNotification('Rapina annullata, ti sei allontanato troppo')
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if timerAschermo then
            local x, y = 0.5, 0.95
            local scale = 0.6

            SetTextFont(0)
            SetTextProportional(1)
            SetTextScale(scale, scale)
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentString("Tempo rimanente: " .. tempoRestante .. " secondi")
            DrawText(x, y)

            local factor = (string.len("Tempo rimanente: " .. tempoRestante .. " secondi")) / 0
            DrawRect(x, y + 0.02, 0.15 + factor, 0.03, 0, 0, 0, 150)
        end
    end
end)