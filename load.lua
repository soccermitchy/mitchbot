dofile'commandEngine.lua'
dofile'plugins/users.lua'
dofile'plugins/admin.lua'
dofile'plugins/lua_sandbox.lua'
dofile'plugins/bluevm.lua'
dofile'timers.lua'
sha256=dofile'sha256.lua'
if started then dofile("config.lua") end
