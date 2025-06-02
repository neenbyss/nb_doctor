fx_version 'cerulean'
game 'gta5'

name 'nb-doctor'
description 'NPC Doctor for QBCore'
author 'NeenByss'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

lua54 'yes'