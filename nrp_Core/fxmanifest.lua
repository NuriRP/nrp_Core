fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Erson Pelmeni #1'
description 'Core system based on ESX.'
version '1.0.0'

client_scripts {
    'config/config.lua',
    'client/client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config/config.lua',
    'config/webhookconfig.lua',
    'server/clientcode.lua',
    'server/server.lua'
}

ui_page 'html/index.html'

files {
    'html/**/*.*',
    'weapon_connect/*.meta'
}

data_file 'WEAPONINFO_FILE_PATCH' 'weapon_connect/*.meta'
