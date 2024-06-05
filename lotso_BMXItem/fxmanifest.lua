fx_version 'adamant'
game 'gta5'
lua54 "yes"

version '1.0.5'

author 'l.osto'
Contributions '#l.osto'

shared_scripts {
    "config.lua",
    "@es_extended/imports.lua"
}

client_scripts {
    "client/*.lua",
}

server_scripts {
    "server/*.lua"
}

escrow_ignore {
    'client/*.lua',
    'server/*.lua',
    'config.lua'
}
dependency '/assetpacks'