function commandEngine(usr,chan,msg)
	if chan:sub(1,1)=="#" then target=chan else target=usr.nick end
	if not users[usr.host] then 
		users[usr.host]={ 
			identified=false,
			perms={}
		} 
		users[usr.host].perms[""]=true
	end
	print(string.format("[MESSAGE]\t[%s][%s]<%s> %s",os.date(),chan,usr.nick,msg))
	called=false
	if msg:sub(1,#config.cmdchar)==config.cmdchar and (users[usr.host].ignore==false or users[usr.host].ignore==nil) then
		pre,cmd,rest = msg:match("^("..config.cmdchar..")([^%s]+)%s?(.*)$") -- thanks to cracker64
		if not cmd then return end
		args=split(rest," ")
		print(string.format("[COMMAND]\t[%s][%s][%s]",usr.nick,cmd,rest))
		if commands[cmd] then
			if checkPerms(commands[cmd].level,usr.host) then
				status,target,send=pcall(commands[cmd].func,usr,chan,msg,args)
				if not status then 
					print(string.format("[ERROR]\t\t%s",split(target,"\n")[1]))
					if chan:sub(1,1)=="#" then sendChat(chan,split(target,"\n")[1]) else sendChat(usr.nick,split(target,"\n")[1]) end
				else
					for k,v in pairs(activePatterns) do
						send=send:gsub(k,v)
					end
					if target=="usr" then sendChat(usr.nick,send) elseif target=="chan" then sendChat(chan,send) end
				end
			else
				sendChat(target,string.format("%s, you do not have the required permissions for the command %q. You need one of the following capabilities to use this: %s",usr.nick,cmd,table.concat(commands[cmd].level," ")))
			end
		--[[else
				sendChat(target,string.format("%s, the command %q does not exist.",usr.nick,cmd))]]
		end
	end
end
filtersLocked=false
activePatterns={}
function patterns(usr,chan,msg,args)
	if chan:sub(1,1)=="#" then target=chan else target=usr.nick end
	if args[1]=="clear" then
		if not filtersLocked then
			activePatterns={}
			return target,"Filters cleared."
		else
			return target,"Filters locked."
		end
	elseif args[1]=="add" then
		if not filtersLocked then
			activePatterns[args[2]]=args[3]
			return target,"Filter applied."
		else
			return target,"Filters locked."
		end
	elseif args[1]=="lock" then
		if checkPerms({"filters"},usr.host) then
			filtersLocked=true
			return target,"filters locked"
		else
			return target,"No perms to lock filters."
		end
	elseif args[1]=="unlock" then
		if checkPerms({"filters"},usr.host) then
			filtersLocked=false
			return target,"filters unlocked"
		else
			return target,"No perms to unlock filters."
		end
	else
		return target,"syntax: filter [clear|add|lock|unlock]"
	end
end
addcommand("filter",patterns)
