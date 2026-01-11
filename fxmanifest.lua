fx_version 'cerulean'
game 'gta5'

name 'nb-doctor'
description 'NPC Doctor for ESX'
author 'NeenByss'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

lua54 'yes'