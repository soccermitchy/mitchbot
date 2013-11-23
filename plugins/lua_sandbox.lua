if not string.find(package.cpath,"%;%./plugins/%?%.so") then
	package.cpath=package.cpath..';./plugins/?.so' -- so we can load sandbox
end
sandbox=require'luasandbox'
sandboxPreexecCode=[[
json=dofile'json.lua'
bluevm={}
metatable={}
metatable.__index=function(t,k)
  local data=io_popen('timeout -s 9 10 curl -s http://'..k..'.bluevm.com/uptime.php -o /dev/stdout'):read'*a'
  if data:sub(1,1)=="<" then return 'script not found' end
  return json:decode(data)
end
local io_popen=io.popen
setmetatable(bluevm,metatable)
math.randomseed(os.time())debug,loadfile,module,require,dofile,package,os.remove,os.tmpname,os.rename,os.execute,os.exit,string.dump=nil io={write=io.write}
]]
function sandboxExec(code)
	if code:sub(1,1)=="\27" then return "no bytecode for you" end
	return sandbox(sandboxPreexecCode,code,52428800)
end
function sandboxcmd(usr,chan,msg,args)
	if chan:sub(1,1)=="#" then target="chan" else target="usr" end
	code=table.concat(args," ")
	if code:sub(1,1)=='=' then code='return '..code:sub(2,#code) end
	out=sandboxExec(code) or 'wat, no output'
	out=out:match('(.+)\n$') or out or ''
	out=out:gsub('\n','\\n'):gsub('\r','\\r')
	return target,usr.nick..": "..out
end
addcommand("lua",sandboxcmd)
