fx_version 'adamant'
game 'gta5'

author 'Alguém que estava cuidando da própria vida'
description 'Nãoti'
version '1.0.0'

ui_page "nui/index.html"
client_scripts {
	"@vrp/lib/utils.lua",
	"client/client.lua"
}

server_scripts {
	"@vrp/lib/utils.lua",
	"server/server.lua"
}

files {
	"nui/*"
}