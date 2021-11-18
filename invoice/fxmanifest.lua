fx_version 'adamant'
game 'gta5'

author 'Alguém que estava cuidando da própria vida'
description 'Nãoti'
version '1.0.0'

ui_page "nui/index.html"
files {
	"nui/index.html",
	"nui/jquery.js",
	"nui/dkm.js",
	"nui/style.css"
}

client_script {
	'@vrp/lib/utils.lua',
	'c/client.lua'
}

server_script {
	"@vrp/lib/utils.lua",
	'server.lua'
}