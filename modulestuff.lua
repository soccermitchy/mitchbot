function addplugin(pluginName,hidden,pluginDesc,displayName)
	pluginName=pluginName or error'Plugin name not given'
	hidden=hidden or false
	plugins[pluginName]={}
	plugins[pluginName].commands={}
	plugins[pluginName].hidden=hidden
	plugins[pluginName].desc=pluginDesc
	plugins[pluginName].displayName=displayName
end

function addcommand(commandName,commandFunc,commandPerms,plugin,help)
  if not commandPerms then commandPerms={""} end
  if not commandName then error "Command name not given!" end
  if not commandFunc then error "Command function not given!" end
  if not plugin then error'Plugin name not given'
  help=help or error'No help given'
  commands[commandName]={}
  commands[commandName].func=commandFunc
  commands[commandName].level=commandPerms
	commands[commandName].plugin=plugin
	commands[commandName].help=help
	table.insert(plugins[plugin].commands,commandName)
end
local function modUnload(file)
	plugins[pluginName]=nil
end

function moduleLoadDir()
	for file in require'lfs'.dir'modules' do
		s,ret=pcall(function() dofile(file) end)
		if ret and not s then 
			print('[MODULE_ERR] '..file..': '..ret)
			modunload(file)
		end
  end
end

moduleLoadDir()
