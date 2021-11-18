local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
vRP = Proxy.getInterface('vRP')
vRPclient = Tunnel.getInterface('vRP')

func = {}
Tunnel.bindInterface('bank',func)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIÁVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local bank = ""

local movimento = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- GET MULTAS
-----------------------------------------------------------------------------------------------------------------------------------------
function func.getMultas()
	local source = source
	local user_id = vRP.getUserId(source)
	local tableFines = {}
	local multas = vRP.getFines(user_id) 
	for k,v in pairs(multas) do
		if v.nuser_id == 0 then
			table.insert(tableFines,{ id = v.id, user_id = parseInt(v.user_id), nuser_id = "GOV UDG", date = os.date("%d/%m/%Y",v.date), price = parseInt(v.price), text = tostring(v.text) })
		else
			local identity = vRP.getUserIdentity(v.nuser_id)
			table.insert(tableFines,{ id = v.id, user_id = parseInt(v.user_id), nuser_id = tostring(identity.name.." "..identity.name2), date = os.date("%d/%m/%Y",v.date), price = parseInt(v.price), text = tostring(v.text) })
		end
	end
	return tableFines
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GET FATURAS
-----------------------------------------------------------------------------------------------------------------------------------------
function func.getInvoices()
	local source = source
	local user_id = vRP.getUserId(source)
    local myTable = {}
    
	local total = vRP.getInvoice(user_id)
	for k,v in pairs(total) do
        table.insert(myTable,{ sender = v.sender, valor = v.valor, motivo = v.motivo, descricao = v.descricao, dia = v.data, pago = v.pago, id = v.id })
	end

	return myTable
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GET FATURAS PAGAS
-----------------------------------------------------------------------------------------------------------------------------------------
function func.getInvoicesPaid()
	local source = source
	local user_id = vRP.getUserId(source)
    local myTable = {}
    
	local total = vRP.getInvoicePaid(user_id)
	for k,v in pairs(total) do
        table.insert(myTable,{ valor = v.valor, motivo = v.motivo, descricao = v.descricao, dia = v.data, pago = v.pago, id = v.id })
	end

	return myTable
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GET FATURAS ENVIADAS
-----------------------------------------------------------------------------------------------------------------------------------------
function func.getFaturasSender()
	local source = source
	local user_id = vRP.getUserId(source)
    local myTable = {}
    
	local total = vRP.getMyInvoice(user_id)
	for k,v in pairs(total) do
        table.insert(myTable,{ identidade = vRP.getUserIdentity(v.user_id), valor = v.valor, motivo = v.motivo, descricao = v.descricao, dia = v.data, pago = v.pago, recebido = v.recebido, id = v.id })
	end
	return myTable
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TODAS AS INFOS
-----------------------------------------------------------------------------------------------------------------------------------------
function func.getInfos()
	local source = source
    local user_id = vRP.getUserId(source)
    local data = {}

    local identity = vRP.getUserIdentity(user_id)
    local saldo = vRP.getBank(user_id)    
    local data = {
        nome = identity.name,
        sobrenome = identity.name2,
        saldo = saldo,
    }
	return data
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAQUE - WITHDRAW
-----------------------------------------------------------------------------------------------------------------------------------------
function func.efetuarSaque(valorSaque)
	local source = source
    local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
    if user_id then

		local getInvoice = vRP.getInvoice(user_id)
		if getInvoice[1] ~= nil then
			--TriggerClientEvent('bank:notifyTrueOrFalse', source, false, 'Erro', 'Encontramos faturas pendentes')  
			TriggerClientEvent("Notify",source,"vermelho","Encontramos faturas pendentes.",8000)
			return
		end

		local getFines = vRP.getFines(user_id)
		if getFines[1] ~= nil then
			TriggerClientEvent("Notify",source,"vermelho","Encontramos multas pendentes.",8000)
			--TriggerClientEvent('bank:notifyTrueOrFalse', source, false, 'Erro', 'Encontramos multas pendentes')  
			return
		end

    	if movimento[parseInt(user_id)] == 0 or not movimento[parseInt(user_id)] then
    		movimento[parseInt(user_id)] = 5
	        if vRP.withdrawCash(user_id,parseInt(valorSaque)) then
				--TriggerClientEvent('bank:notifyTrueOrFalse', source, true, 'Sucesso', 'Você sacou $'..vRP.format(parseInt(valorSaque)))
				TriggerClientEvent("Notify",source,"verde","Você sacou $"..vRP.format(parseInt(valorSaque))..".",8000)				
				vRP._createWebHook(bank,"```[ID]: "..identity.name.." "..identity.name2.." "..identity.id.."\n[SACOU]: "..valorSaque.."\n[CONTA PÓS-OPERAÇÃO]: "..parseInt(vRP.getBank(user_id))..""..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."```")
				return true
	        else
	            --TriggerClientEvent('bank:notifyTrueOrFalse', source, false, 'Erro', 'Saldo insuficiente')  
				TriggerClientEvent("Notify",source,"vermelho","Saldo insuficiente.",8000)
				return false
	        end
	    end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEPOSIT - DEPOSITO
-----------------------------------------------------------------------------------------------------------------------------------------
function func.efetuarDeposito(valorDeposito)
	local source = source
    local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
    if user_id then	
    	if movimento[parseInt(user_id)] == 0 or not movimento[parseInt(user_id)] then
    		movimento[parseInt(user_id)] = 5
	        if vRP.paymentInv(user_id,parseInt(valorDeposito)) then
				vRP.addBank(user_id,parseInt(valorDeposito))
				--TriggerClientEvent('bank:notifyTrueOrFalse', source, true, 'Sucesso', 'Você depositou $'..vRP.format(parseInt(valorDeposito)))
				TriggerClientEvent("Notify",source,"verde","Você depositou $"..vRP.format(parseInt(valorDeposito))..".",8000)
				vRP.createWeebHook(bank,"```[ID]: "..identity.name.." "..identity.name2.." "..identity.id.."\n[DEPOSITOU]: "..valorDeposito.."\n[CONTA PÓS-OPERAÇÃO]: "..parseInt(vRP.getBank(user_id))..""..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."```")
				return true
	        else
	            --TriggerClientEvent('bank:notifyTrueOrFalse', source, false, 'Erro', 'Dinheiro insuficiente')  
				TriggerClientEvent("Notify",source,"vermelho","Saldo insuficiente.",8000)
				return false
	        end
	    end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRANSFER - TRANSFERÊNCIAS
-----------------------------------------------------------------------------------------------------------------------------------------
function func.efetuarTransferencia(valorTransferencia, alvo)
	local source = source
    local user_id = vRP.getUserId(source)
    local targetPlayer = vRP.getUserSource(parseInt(alvo))
    local identity = vRP.getUserIdentity(user_id)
	
	if targetPlayer ~= nil and user_id ~= nil then

		local getInvoice = vRP.getInvoice(user_id)
		if getInvoice[1] ~= nil then
			--TriggerClientEvent('bank:notifyTrueOrFalse', source, false, 'Erro', 'Encontramos faturas pendentes')  
			TriggerClientEvent("Notify",source,"vermelho","Encontramos faturas pendentes.",8000)
			return
		end

		local getFines = vRP.getFines(user_id)
		if getFines[1] ~= nil then
			TriggerClientEvent("Notify",source,"vermelho","Encontramos multas pendentes.",8000)
			--TriggerClientEvent('bank:notifyTrueOrFalse', source, false, 'Erro', 'Encontramos multas pendentes')  
			return
		end

		local nuser_id = vRP.getUserId(targetPlayer)
		local identity2 = vRP.getUserIdentity(nuser_id)
    	if movimento[parseInt(user_id)] == 0 or not movimento[parseInt(user_id)] then
			movimento[parseInt(user_id)] = 5
	        if vRP.paymentBank(user_id,parseInt(valorTransferencia)) then	         
	            vRP.addBank(parseInt(alvo), parseInt(valorTransferencia))
	            TriggerClientEvent('Notify',targetPlayer,'verde','Você recebeu $' .. valorTransferencia ..' de '  ..identity.name,8000)
				TriggerClientEvent('Notify',source,'verde','Transferencia realizada com sucesso.',8000)
				--TriggerClientEvent('bank:notifyTrueOrFalse', source, true, 'Sucesso', 'Transferência realizada com sucesso')   
				vRP.createWeebHook(bank,"```[ID]: "..identity.name.." "..identity.name2.." "..identity.id.."\n[TRANSFERIU]: "..valorTransferencia.."\n[PARA]: "..identity2.name.." "..identity2.name2.." "..identity2.id.."[CONTA REMETENTE PÓS-OPERAÇÃO]: "..parseInt(vRP.getBank(user_id)).."\n[CONTA DESTINATÁRIO PÓS-OPERAÇÃO]: "..parseInt(vRP.getBank(nuser_id))..""..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."```")
	        else
	            --TriggerClientEvent('bank:notifyTrueOrFalse', source, false, 'Erro', 'Dinheiro insuficiente')
				TriggerClientEvent("Notify",source,"vermelho","Saldo insuficiente.",8000)
	        end
	    end
    else
    	--TriggerClientEvent('bank:notifyTrueOrFalse', source, false, 'Erro', 'A pessoa não se encontra na cidade neste momento')
		TriggerClientEvent("Notify",source,"vermelho","O Destinatário não se encontra na cidade.",8000)
        return 
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINE PAYMENT
-----------------------------------------------------------------------------------------------------------------------------------------
function func.finePayment(pagamento, id)
	local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if id then
        	if movimento[parseInt(user_id)] == 0 or not movimento[parseInt(user_id)] then
        		movimento[parseInt(user_id)] = 5
				local multas = vRP.query("vRP/get_fines2",{ id = parseInt(id) })
	            local myBank = parseInt(vRP.getBank(user_id))
				if parseInt(math.ceil(multas[1].price)) > 0 and myBank >= parseInt(math.ceil(multas[1].price)) then
					vRP.setBank(user_id, myBank - parseInt(pagamento))
					local payFine = vRP.execute("vRP/del_fines", {id = id, user_id = user_id})
					TriggerClientEvent('Notify',source,'verde','Multa paga com sucesso.',8000)
					--TriggerClientEvent('bank:notifyTrueOrFalse', source, true, 'Sucesso', 'Multa paga com sucesso')
					return true		
				else
					TriggerClientEvent("Notify",source,"vermelho","Saldo indisponível.",8000)
					return false
					--TriggerClientEvent('bank:notifyTrueOrFalse', source, false, 'Falha no pagamento', 'Confira as informações do pagamento')
				end
	        end
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAQUE - WITHDRAW
-----------------------------------------------------------------------------------------------------------------------------------------
function func.pagarFaturas(pagamento, id)
	local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if id then
        	if movimento[parseInt(user_id)] == 0 or not movimento[parseInt(user_id)] then
        		movimento[parseInt(user_id)] = 5
	            local fatura = vRP.query("vRP/getFaturas",{ user_id = parseInt(user_id) })
	            local myBank = parseInt(vRP.getBank(user_id))	            
				if parseInt(math.ceil(fatura[1].valor)) > 0 and vRP.paymentBank(user_id,parseInt(pagamento)) then
					local pagarFatura = vRP.query("vRP/PagarFatura",{ user_id = parseInt(user_id), id = parseInt(id) })
					TriggerClientEvent("Notify",source,"verde","Fatura paga com sucesso.",8000)
					return true					
				else
					TriggerClientEvent("Notify",source,"vermelho","Saldo indisponível.",8000)
					return false
				end
	           
	        end
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- WITHDRAW INVOICES - SACAR FATURAS
-----------------------------------------------------------------------------------------------------------------------------------------
function func.sacarFaturas(id)
	local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if id then
        	if movimento[parseInt(user_id)] == 0 or not movimento[parseInt(user_id)] then
        		movimento[parseInt(user_id)] = 5
	            local fatura = vRP.query("vRP/getFaturasDate",{ sender = parseInt(user_id), id = parseInt(id) })
	            local dinheiro = fatura[1].valor
	            local sacarFatura = vRP.query("vRP/remFaturasSender",{ sender = parseInt(user_id), id = parseInt(id) })
	            vRP.addBank(parseInt(user_id), parseInt(dinheiro))
				TriggerClientEvent("Notify",source,"verde","Pagamento recolhido com sucesso.",8000)
				return true
				--TriggerClientEvent('bank:notifyTrueOrFalse', source, true, 'Sucesso', 'O dinheiro foi transferido para a sua conta!')		
	        end
        end
		return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREAD TO NOT FLOOD
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		for k,v in pairs(movimento) do
			if v > 0 then
				movimento[k] = v - 1
			end
		end
		Citizen.Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKSEARCH
-----------------------------------------------------------------------------------------------------------------------------------------
function func.checkSearch()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if not vRP.searchReturn(source,user_id) then
			return true
		end
		return false
	end
end
