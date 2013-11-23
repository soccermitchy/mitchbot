addmodule('admin.lua',false,'Admin stuff for mitchbot','Admin')
function reload(usr,chan,nick,args)
	dofile"load.lua"
	if chan:sub(1,1)=="#" then target="chan" else target="usr" end
	return target,string.format("%s, done!",usr.nick)
end
function lua(usr,chan,msg,args)
        if chan:sub(1,1)=="#" then target="chan" else target="usr" end
        local code=table.concat(args," ")
        local func,err=loadstring(code)
        if err then return target,usr.nick..": "..err end
        local asdf,ret=pcall(func) asdf=nil
        ret = tostring(ret) or "No output"
        return target,usr.nick..": "..ret 
end 
function jumpOffACliff(usr,chan,msg,args,netname)
	networks[netname]:send("QUIT :My owner told me to jump off a cliff >:O")
    os.exit()
end
function ignore(usr,chan,msg,args)
	hostname=irc:whois(args[1]).userinfo[4]
	if not users[hostname] then users[hostname]={} end
	users[hostname].ignore=true
end
function unignore(usr,chan,msg,args)
	hostname=irc:whois(args[1]).userinfo[4]
	if not users[hostname] then users[hostname]={} end
	users[hostname].ignore=false
end
function botram(user,chan,msg,args)
	if chan:sub(1,1)=="#" then target="chan" else target="usr" end	
	return target,"I am using "..collectgarbage"count".."k ram."
end
function list(usr,chan,msg,args)
	if chan:sub(1,1)=="#" then target="chan" else target="usr" end
	if args[1] then
		if plugins[args[1]] then
			local pluginCmdList={}
			for k,v in pairs(plugins.commands) do
				table.insert(pluginCmdList,k)
	    end
	    local list=table.concat(pluginList,",")
	    return target,"List of commands in "..arg[1]..": "..list
	  else
	  	return target,"That plugin does not exist."
	else
		local pluginList={}
		for k,v in pairs(plugins)do
			table.insert(pluginList,k)
	  end
	  local list=table.concat(pluginList,",")
	  return target,"Plugin list: "..list
	end
end
-- function addcommand(commandName,commandFunc   ,commandPerms,plugin,      help)
addcommand(						 "ignore",   ignore,       {"trusted"}, 'admin.lua', 'Ignore a user.')
addcommand(          "unignore",   unignore,  	 {"trusted"}, 'admin.lua', 'Unignore a user')
addcommand(     "jumpoffacliff",   jumpOffACliff,{"owner"},   'admin.lua', 'Make the bot quit.')
addcommand(            "reload",   reload,       nil,         'admin.lua', 'Reload the bot.') 
addcommand(      config.cmdchar,   lua,          {"trusted"}, 'admin.lua', 'Execute lua code.')
addcommand( 					 "botram",   botram        nil,         'admin.lua', 'Get the amount of ram the botis using')
