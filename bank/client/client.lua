local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
func = Tunnel.getInterface("bank")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIÁVEL
-----------------------------------------------------------------------------------------------------------------------------------------
local bank_cds = {
  ['bank'] = { 
      {['x'] = 149.95, ['y'] = -1040.76, ['z'] = 29.37},
      {['x'] = 148.54, ['y'] = -1040.32, ['z'] = 29.37},
      {['x'] = -1212.980, ['y'] = -330.841, ['z'] = 37.787},
      {['x'] = -2962.582, ['y'] = 482.627, ['z'] = 15.703},
      {['x'] = -112.202, ['y'] = 6469.295, ['z'] = 31.626},
      {['x'] = 314.187, ['y'] = -278.621, ['z'] = 54.170},
      {['x'] = -351.534, ['y'] = -49.529, ['z'] = 49.042},
      {['x'] = 241.727, ['y'] = 220.706, ['z'] = 106.286},
      {['x'] = 1174.74, ['y'] = 2706.75, ['z'] = 38.1 }
    },
  ['props'] = {
    {"prop_atm_01"},
    {"prop_atm_02"},
    {"prop_atm_03"},
    {"prop_fleeca_atm"}
  }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENBANK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('openBank',function()
    local ped = PlayerPedId()
    local crds = GetEntityCoords(ped)
    for k,v in pairs(bank_cds) do	
      if k == 'bank' then
          for k2,v2 in pairs(bank_cds[k]) do
            local distance = GetDistanceBetweenCoords(crds,v2.x,v2.y,v2.z,true)
            if distance <= 3 then	             
              if func.checkSearch() then
                SetNuiFocus(true, true)
                SendNUIMessage({ action = 'open'})          
                return                 
              end				
            end
          end
      elseif k == 'props' then
        for k2,v2 in pairs(bank_cds[k]) do
          if DoesObjectOfTypeExistAtCoords(crds,0.6,GetHashKey(v2[1]),true) then
            if func.checkSearch() then
              SetNuiFocus(true, true)
              SendNUIMessage({ action = 'open'})
              return   
            end 
          end
        end            
      end
    end
end)

RegisterKeyMapping("openBank","Abrir banco","keyboard","e")
-----------------------------------------------------------------------------------------------------------------------------------------
-- WITHDRAW - SAQUE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("withdraw", function(data,cb)    
    local withdraw = func.efetuarSaque(data.valor)
    if withdraw then
      cb({ withdraw = withdraw})
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRANSFER - TRANSFERENCIA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("transfer", function(data,cb)    
    local transfer = func.efetuarTransferencia(data.valor, data.pessoa)
    if transfer then
      cb({ transfer = transfer})
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEPOSIT - DEPOSITO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("deposit", function(data,cb)
    local deposit = func.efetuarDeposito(data.valor)
    if deposit then
      cb({ deposit = deposit})
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- IDENTITY - INFOS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("getInfos", function(data, cb)
    local result = func.getInfos()
    if result then
        cb({ result = result })
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETFINES - PEGAR AS MULTAS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("getFines", function(data, cb)
  local result = func.getMultas()
  if result then
      cb({ result = result })
  end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETINVOICES OPEN - PEGAR AS FATURAS ABERTAS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("getInvoices", function(data, cb)
    local result = func.getInvoices()
    if result then
        cb({ result = result })
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETINVOICES2 PAID - PEGAR AS FATURAS PAGAS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("getInvoicesPaid", function(data, cb)
    local result = func.getInvoicesPaid()
    if result then
        cb({ result = result })
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETINVOICES3 SENDER- PEGAR AS FATURAS ENVIADAS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("getInvoicesSender", function(data, cb)
    local result = func.getFaturasSender()
    if result then
        cb({ result = result })
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTION NOTIFY - FUNÇÃO DE MENSAGEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("notify", function(data)
  TriggerEvent("Notify",data.type,data.msg,5000)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PAYMENT FINE - PAGAMENTO DE MULTA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("finePayment", function(data,cb)
    local paid = func.finePayment(data.valor, data.id)
    if paid then
        cb({paid = paid})
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PAYMENT INVOICE - PAGAMENTO DE FATURAS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("invoicePayment", function(data,cb)
    local payment = func.pagarFaturas(data.valor, data.id)
    if payment then
      cb({payment = payment})
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETMONEY FINE -SACAR PAGAMENTO DA FATURA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("getMoneyMyInv", function(data,cb)
    local withdraw = func.sacarFaturas(data.id)
    if withdraw then
      cb({withdraw = withdraw})
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI OF
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("exit", function(data)
  SetNuiFocus(false, false)
  SendNUIMessage({ action = 'close'})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLOCK BUTTONS DURING NUI
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while display do
        Citizen.Wait(0)
        DisableControlAction(0, 1, display)
        DisableControlAction(0, 2, display)
        DisableControlAction(0, 142, display)
        DisableControlAction(0, 18, display)
        DisableControlAction(0, 322, display)
        DisableControlAction(0, 106, display)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT
-----------------------------------------------------------------------------------------------------------------------------------------
function chat(str, color)
    TriggerEvent(
        'chat:addMessage',
        {
            color = color,
            multiline = true,
            args = {str}
        }
    )
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFICATION - NOTIFICAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
function notification(title, description, type, returnHome)
    if returnHome == true then
      SendNUIMessage({open = true})
    end
    SendNUIMessage(
      {
        notification = true,
        notification_title = title,
        notification_desc = description,
        notification_type = type
      }
    )
end
-----------------------------------------------------------------------------------------------------------------------------------------
--TRIGGER EVENT NOTIFICATION
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("bank:notifyTrueOrFalse")
AddEventHandler("bank:notifyTrueOrFalse", function(res, msg1, msg2)
  Citizen.Wait(100)
  SendNUIMessage({open = true})
  if res == true then    
    notification(msg1, msg2, "success")    
  else
    notification(msg1, msg2, "error")
  end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INSERT TABLE HOVERFY
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
  local innerTable = {}
  for k,v in pairs(bank_cds['bank']) do
      table.insert(innerTable,{ v.x,v.y,v.z,3,"E","Banco Fleeca","Pressione para abrir" })
  end

  TriggerEvent("hoverfy:insertTable",innerTable)
end)