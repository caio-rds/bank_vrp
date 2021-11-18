# bank_vrp
Bank script for FIVEM (cfx.re)

This is the final version of script, the frist has most part of it made by github.com/MichelSchiavo

Made trying to use less processing as possible in client-side. replacing threads.

May you need to make sql part, or ajusts in the server side, but the client side and front-end will work perfectly.

BTW, make a good use and dont sell this shit.

If u have any doubts, please, dont hesitate to look in google or youtube :)


Queries SQL to help

-----------------------------------------------------------------------------------------------------------------------------------------
-- PREPARE NEW BANK
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("vRP/addFaturas","INSERT IGNORE INTO vrp_faturas(user_id,sender,valor, motivo, descricao, data) VALUES(@user_id,@sender,@valor,@motivo,@descricao,@data)")
vRP.prepare("vRP/getFaturas","SELECT * FROM vrp_faturas WHERE user_id = @user_id AND pago = 0")
vRP.prepare("vRP/getFaturas2","SELECT * FROM vrp_faturas WHERE user_id = @user_id AND pago = 1")
vRP.prepare("vRP/get_fines2","SELECT * FROM vrp_fines WHERE id = @id")
vRP.prepare("vRP/getFaturasDate","SELECT * FROM vrp_faturas WHERE sender = @sender AND id = @id")
vRP.prepare("vRP/PagarFatura","UPDATE vrp_faturas SET pago = 1 WHERE user_id = @user_id AND id = @id")
vRP.prepare("vRP/getFaturasSender","SELECT * FROM vrp_faturas WHERE sender = @sender")
vRP.prepare("vRP/remFaturasSender","UPDATE vrp_faturas SET recebido = 1 WHERE sender = @sender AND id = @id")
vRP.prepare("vRP/getDateExpire","SELECT * FROM vrp_faturas WHERE pago = 0")
vRP.prepare("vRP/IncreaseValue","UPDATE vrp_faturas SET valor = @valor WHERE pago = 0 AND id = @id")
