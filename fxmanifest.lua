fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'rco-animations'
author 'rustico'
description 'Teste de Animações'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/script.js',
    'web/style.css',
    'web/assets/*.png',
    'Scenarios.json'
}

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

