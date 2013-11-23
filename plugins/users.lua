-- plugin/users.lua
function hash(pass,salt)
	if not salt then 
		salt=""
		for i=1,math.random(0,5) do
			salt=salt..string.char(math.random(65,122))
			sleep(1)
		end
	end
	hashed=sha256.hash256(pass..salt)
	return hashed,salt
end
function register(usr,chan,msg,args)
	if chan:sub(1,1)=="#" then return "chan",string.format("%s: Are you kidding me? You just sent your password (or were about to send it) in a channel! Try again in PM.",usr.nick) end
	if not args[2] then
		return "usr",string.format("%s: Arguments for command 'register': %s <username> <password>",usr.nick,args[1])
	else
		userdbfile=io.open("users.json","r")
		if userdbfile then
			userdb=json:decode(userdbfile:read'*a')
		else
			userdb={}
		end
		if userdb[args[1]] then return "usr",string.format("%s, that user already exists!",usr.nick) end
		userdb[args[1]]={}
		userdb[args[1]].password,userdb[args[1]].salt=hash(args[2])
		userdb[args[1]].perms={}
		userdb[args[1]].perms[""]=true
		userdb[args[1]].name=args[1]
		userdbjson=json:encode_pretty(userdb)
		userdbfile=io.open("users.json","w")
		userdbfile:write(userdbjson)
		userdbfile:close()
		return "usr","Done!"
	end
end
function login(usr,chan,msg,args)
	if chan:sub(1,1)=="#" then return "chan",string.format("%s: Are you kidding me? You just sent your password in a channel! Try again in PM.") end
	if not args[2] then
		return "usr",string.format("%s: Arguments for command 'login': %s <username> <password>",usr.nick,config.cmdchar.."login")
	else
		userdbfile=io.open("users.json","r")
		userdb=json:decode(userdbfile:read'*a')
		if not userdb[args[1]] then return "usr",string.format("%s: The account %q does not exist!",usr.nick,args[2]) end
		hashpwd=hash(args[2],userdb[args[1]].salt) 
		if hashpwd==userdb[args[1]].password then
			users[usr.host]=userdb[args[1]]
			if not users[usr.host].name then users[usr.host].name=arg[1] end
			return "usr",string.format("%s: Login success!",usr.nick)
		else
			return "usr",string.format("%s: The account %q does not exist!",usr.nick,args[2])
		end
	end
end
function whoami(usr,chan,msg,args)
	if chan:sub(1,1)=="#" then target="chan" else target="usr" end
	if users[usr.host] then	
		hasPerms=""--[[
		for k,v in pairs(users[usr.host].perms) do
			if k~="" or v~=false then hasPerms=hasPerms..", "..k end
		end]]
		if users[usr.host].name then 
			return target,"You are logged in as "..users[usr.host].name
		else
			return target,"You are not logged in."
		end
	else
		return target,"You are not logged in."
	end
end
addcommand("login",login)
addcommand("register",register)
addcommand("whoami",whoami)
