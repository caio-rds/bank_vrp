local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

func = Tunnel.getInterface("invoice")

local display = false

RegisterCommand('faturas', function()
    SetDisplay(not display)
end)

function ToggleActionMenu()
    local data = func.talvezTudo()
	SetDisplay(not display, data)
end

RegisterNUICallback("enviarFatura", function(data)
    func.addFaturas(data.passaporte, data.valor, data.motivo, data.description)
end)

RegisterNUICallback("values", function(data, cb)
    local result = func.talvezTudo()
    if result then
        cb({ result = result })
    end
end)

RegisterNUICallback("exit", function()
    SetDisplay(false)
end)

function SetDisplay(bool)
  display = bool
  SetNuiFocus(bool, bool)
  SendNUIMessage({
      type = "ui",
      status = bool
  })
end

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

RegisterNetEvent("skid_bank:notifyTrueOrFalse")
AddEventHandler("skid_bank:notifyTrueOrFalse", function(res, msg1, msg2)
  Citizen.Wait(1000)
  SendNUIMessage({open = true})
  if res == true then    
    notification(msg1, msg2, "success")    
  else
    notification(msg1, msg2, "error")
  end
end)