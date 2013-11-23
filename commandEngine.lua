commands={}
function sendChat(net,target,msg)
  print("[MESSAGE] ["..os.date().."] ["..target.."] <"..networks[net].nick.."/"..net.."> "..msg)
	networks[net]:sendChat(target,msg)
end
function checkPerms(cmdperms,usrhost)
	for k,v in pairs(cmdperms) do
		if users[usrhost].perms[k]==true then
			return true
		end
	end
	if users[usrhost].perms.owner or cmdperms[1]=="" or not cmdperms[1] then
		return true
	end
	return false
end
function addcommand(commandName,commandFunc,commandPerms)
	if not commandPerms then commandPerms={""} end
	if not commandName then error "Command name not given!" end
	if not commandFunc then error "Command function not given!" end
	commands[commandName]={}
	commands[commandName].func=commandFunc
	commands[commandName].level=commandPerms
end
function commandEngine(network,usr,chan,msg)
	if chan:sub(1,1)=="#" then target=chan else target=usr.nick end
	if not users[usr.host] then 
		users[usr.host]={ 
			identified=false,
			perms={}
		} 
		users[usr.host].perms[""]=true
	end
	print(string.format("[MESSAGE]\t[%s][%s]<%s> %s",os.date(),chan,usr.nick.."/"..network,msg))
	local called=false
	if msg:sub(1,#config.cmdchar)==config.cmdchar and (users[usr.host].ignore==false or users[usr.host].ignore==nil) then
		pre,cmd,rest = msg:match("^("..config.cmdchar..")([^%s]+)%s?(.*)$") -- thanks to cracker64
		if not cmd then return end
		args=split(rest," ")
		print(string.format("[COMMAND]\t[%s][%s][%s]",usr.nick.."/"..network,cmd,rest))
		if commands[cmd] then
			if checkPerms(commands[cmd].level,usr.host) then
				status,target,send=pcall(commands[cmd].func,usr,chan,msg,args,network)
				if not status then 
					print(string.format("[ERROR]\t\t%s",split(target,"\n")[1]))
					if chan:sub(1,1)=="#" then sendChat(network,chan,split(target,"\n")[1]) else sendChat(network,usr.nick,split(target,"\n")[1]) end
				else
					if target=="usr" then sendChat(network,usr.nick,send) elseif target=="chan" then sendChat(network,chan,send) end
				end
			else
		      sendChat(network,target,string.format("%s, you do not have the required permissions for the command %q. You need one of the following capabilities to use this: %s",usr.nick,cmd,table.concat(commands[cmd].level," ")))
			end
		--[[else
				sendChat(target,string.format("%s, the command %q does not exist.",usr.nick,cmd))]]
		end
	end
	called,pre,cmd,rest,args=nil
end
