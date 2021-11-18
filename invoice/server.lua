local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
vRP = Proxy.getInterface('vRP')
vRPclient = Tunnel.getInterface('vRP')

func = {}
Tunnel.bindInterface('invoice',func)

-- vRP.prepare("vRP/addFaturas","INSERT IGNORE INTO vrp_faturas(user_id,sender,valor, motivo, descricao, data) VALUES(@user_id,@sender,@valor,@motivo,@descricao,@data)")
-- vRP.prepare("vRP/getFaturas","SELECT * FROM vrp_faturas WHERE user_id = @user_id AND pago = 0")
-- vRP.prepare("vRP/getFaturas2","SELECT * FROM vrp_faturas WHERE user_id = @user_id AND pago = 1")
-- vRP.prepare("vRP/getFaturasDate","SELECT * FROM vrp_faturas WHERE sender = @sender AND id = @id")
-- vRP.prepare("vRP/PagarFatura","UPDATE vrp_faturas SET pago = 1 WHERE user_id = @user_id AND id = @id")
-- vRP.prepare("vRP/getFaturasSender","SELECT * FROM vrp_faturas WHERE sender = @sender")
-- vRP.prepare("vRP/remFaturasSender","UPDATE vrp_faturas SET recebido = 1 WHERE sender = @sender AND id = @id")

function func.addFaturas(np, value, mot, desc)
	local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local identity = vRP.getUserIdentity(user_id)
        if parseInt(np) then
            local nplayer = vRP.getUserSource(parseInt(np))
            local identity2 = vRP.getUserIdentity(np)
            if parseInt(value) > 0 then
                if nplayer then
                    TriggerClientEvent('Notify',source,"verde","Fatura enviada com sucesso",8000)
                    local ok = vRP.request(nplayer,identity.name..' '..identity.name2..' te enviou uma fatura no valor de '..value..', deseja aceitar?',30)
                    if ok then
                        vRP.execute("vRP/addFaturas",{ user_id = parseInt(np), sender = parseInt(user_id), valor = parseInt(value), motivo = mot, descricao = desc, data = parseInt(os.time()*1000) })
                        TriggerClientEvent('Notify',nplayer,'verde',"Fatura recebida com sucesso",8000)
                        TriggerClientEvent('Notify',source,'amarelo',identity2.name..' '..identity2.name2..' aceitou a fatura',8000)
                    else
                        TriggerClientEvent('Notify',source,'vermelho', identity2.name..' '..identity2.name2..' recusou a fatura',8000)
                    end
                end
            end
        end
    end
end

Citizen.CreateThread(function()
    while true do
        
        local minute = os.date("%M")
        local hour = os.date("%H")
        if parseInt(minute) == 00 and parseInt(hour) == 00 then
            local fatura = vRP.query("vRP/getDateExpire")
            for k,v in pairs(fatura) do
                if parseInt(os.time()*1000) >= parseInt(fatura[k].data + 48*60*60) then
                    --print(parseInt(fatura[k].valor + (fatura[k].valor*0.05)),fatura[k].id)
                    vRP.execute("vRP/IncreaseValue",{valor = parseInt( fatura[k].valor + (fatura[k].valor*0.05)), id = fatura[k].id})
                end
            end
        end
        Citizen.Wait(60000)
    end
end)