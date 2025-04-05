fx_version 'bodacious'
game 'gta5'

name 'daDatabaseCharset'
author 'DaBurnerGermany'
version '1.0.4'

lua54 'yes'


escrow_ignore {
	'config.lua',
	'sv.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'sv.lua'
}
