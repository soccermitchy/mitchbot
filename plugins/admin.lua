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
addcommand("ignore",ignore,{"trusted"})
addcommand("unignore",unignore,{"trusted"})
addcommand("jumpoffacliff",jumpOffACliff,{"owner"})
addcommand("reload",reload) 
addcommand(config.cmdchar,lua,{"trusted"})
addcommand("botram",botram)
