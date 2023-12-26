fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Erson Pelmeni #1'
description 'Core system based on ESX.'
version '1.1.0'
repository 'https://github.com/NuriRP/nrp_Core'

client_scripts {
    'config/config.lua',
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
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

dependencies {
    'es_extended',
    'oxmysql'
}
