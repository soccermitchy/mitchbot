require"irc.init"
require"remdebug.engine"
remdebug.engine.start()

config={}
dofile("config.lua")
json=dofile("json.lua")
--[[
--Options:
--	config.server: IRC server to connect to
--	config.port: Port on the IRC server to connect to
-- 	config.servername: Friendly name for the IRC server.
--	config.nickname: Nickname to use on the IRC server. Must be one word.
--	config.username: Username to use on the IRC server. Must be one word.
--	config.realname: Realname to use on the IRC server. Can be multiple words.
--  config.autorun: *RAW* commands to send to the IRC server before joining channels. If this is :::SLEEP:::(sec)::: then we will wait <sec> seconds before continuing.
--	config.channels: Channel names to join.
--	config.cmdchar: Command character to use
]]--

users={}
function split(str, pat) -- from lua-users wiki
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end
function sleep(sec) socket.select(nil,nil,sec) end
function debug_raw(line) print(line) end
function addNetwork(k,v)
    ircuser={}
    ircuser.username=v.username
    ircuser.nick=v.nickname
    ircuser.realname=v.realname
    networks[k]=irc.new(ircuser)
    networks[k]:connect(v.server,v.port,k)
    for _,l in pairs(v.autorun) do
        if string.match(l,':::SLEEP:::(.+):::') then
            socket.select(nil,nil,tonumber(string.match(l,":::SLEEP:::(.+):::")))
        else
            networks[k]:send(l)
        end
    end
    for _,c in pairs(v.channels) do
        networks[k]:join(c)
    end
    for i=1,50 do networks[k]:think() end
    networks[k]:hook("OnChat","[CORE] Main command engine",commandEngine)
end
networks={}
for k,v in pairs(config.networks) do
    print('Starting connection to '..k)
	addNetwork(k,v)
end
    
dofile("load.lua")
for k,v in pairs(networks) do v:hook("OnChat","[CORE] Main command engine",commandEngine) end
started=true
s,apr=pcall(function() return require"apr" end)
function SIGHUP() 
	_,err=pcall(function() dofile"load.lua" end) 
	print("SIGHUP received, reloaded.") 
	if err then 
		print("[ERROR]\t\t"..err) 
	end
end
if s==true then
	print("Apache Portable Runtime loaded, will catch SIGHUP to reload and SIGTERM to exit.")
	apr.signal("SIGHUP",SIGHUP)
	--apr.signal("SIGTERM",function() os.exit() end)
end

while true do
    --if #networks==0 then print'wooks, i accidentally all the connections' break end
    for k,v in pairs(networks) do
		status,out=pcall(function() v:think() debugging=false end)
        if not status then
			print('Connection to '..k..' died with '..out..'. Reconnecting.')
			addNetwork(k,config.networks[k])
			netdata=nil
		end
    end
    sleep(0.1)
    timerStep()
end
