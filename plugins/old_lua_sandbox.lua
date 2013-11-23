env = {
	assert=assert,
	error=error,
	ipairs=ipairs,
	next=next,
	pairs=pairs,
	pcall=pcall,
	select=select,
	tonumber=tonumber,
	tostring=tostring,
	type=type,
	unpack=unpack,
	_VERSION=_VERSION,
	xpcall=xpcall,
	coroutine=coroutine,
	string={
		byte=string.byte,
		char=string.char,
		find=string.find,
		format=string.format,
		gmatch=string.gmatch,
		gsub=string.gsub,
		len=string.len,
		reverse=string.reverse,
		sub=string.sub,
		upper=string.upper,
	},
	table=table,
	math=math,
	io={
		type=type,
	},
	debug={
		setmetatable=setmetatable,
	},
	os={
		clock=clock,
		time=time,
		date=date,
	},
	setmetatable=setmetatable
}
env["_G"]=env
function emptyStringMt()
	local f=loadstring"debug.setmetatable('',{})"
	setfenv(f,env)
	return pcall(f)
end
if not emptyStringMt() then
	print'Could not empty sandbox string metable. Not continuing.'
	return
else
	env.setmetable=nil
	env.debug=nil
end
function sbaddcommand(commandName,commandFunc)
	commandName=commandName or error "command name not given!"
	commandFunc=commandFunc or error "command function not given!"
	commands[commandName]={}
	commands[commandName].level={""}
	commands[commandName].sbData={}
	commands[commandName].sbData.func=commandFunc
	commands[commandName].func=(function(...) run=commands[commandName].sbData.func return sandboxnls(run,...) end)
end
env.addcommand=sbaddcommand
steps=0
function infhook() -- Based off cracker64's debug hook for catching infinite loops.	
	debug.sethook()
	error"Fuck, infinite loops."
end
local sandboxRunning=false
function sandbox(code)
	if code:sub(1,1)=="\27" then return "no bytecode for you." end
	local f,err=loadstring(code)
	if err then return err end
	setfenv(f,env)
	debug.sethook(infhook,"",100001)
	local asdf,ret=pcall(f)
	debug.sethook()
	if not ret then return "No data." else return ret end
end
function sandboxnls(func,...)
	setfenv(func,env)
	debug.sethook(infhook,"",100001)
	local _,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z=pcall(func,...)
	debug.sethook()
	return a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
end

function sandboxcmd(usr,chan,msg,args)
	if chan:sub(1,1)=="#" then target="chan" else target="usr" end
	return target,usr.nick..": "..tostring(sandbox(table.concat(args," "))):gsub("\n","\\n"):gsub("\r","\\r")
end
addcommand("lua",sandboxcmd)
