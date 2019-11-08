--App Info
local APP = {
	TITLE = "Webicity",
	VERSION = "DEV v0.1.0 (Alpha)",
	VERSIONRAW = {0, 1, 0},
	
	PATHS = {
		APP = "${DIR}/app",
		ASSETS = "${DIR}/assets",
		BIN = "${DIR}/bin",
		CLASS = "${APP}/class",
		CMD = "${APP}/app.lua",
		DATA = "${DIR}/data",
		DIR = "${PATH}/..",
		MODULE = "${APP}/module",
		ROOT = "/",
		
		LOCALE = "en_US",
		
		DEBUGFILE = "${DATA}/debug.log",
		CRASHHANDLER = "${APP}/crash.lua",
		
		PATH = nil,
		RIBBON = "${DIR}/../Ribbon",
	},
	
	PATHRESOLUTIONTRIES = 50,
}

--Configs
--#@Configs

--Glue
local ribbon
local baseError = "App failed to launch!"
local results = {pcall(function(...)
	--Alt require
	local function prequire(file)
		local ok, rtn = pcall(require, file or "")
		if ok then return rtn end
	end
	
    --Check environment
	local shell = shell or prequire("shell")
	local process = process or prequire("process")
	local filesystem = filesystem or prequire("filesystem")
	if not loadfile or not ((shell and fs) or (shell and process and filesystem)) then
		error("Unsupported operating environment\nPlease try the latest version of OpenOS or CraftOS", -1)
	end
	local isOC = not fs
	
	--Load message
	print("Loading, thank you for your patience...")
	
	--Set shell name
	if multishell then
		multishell.setTitle(multishell.getCurrent(), APP.TITLE or "Application")
	end
	
	--Config fallback
	local APP = APP or {}
	APP.PATHS = APP.PATHS or {}
	
	local paths = APP.PATHS

    --Resolve paths
    if not paths["PATH"] then
		paths["PATH"] = "."
		if isOC and process then
    		paths["PATH"] = filesystem.concat(shell.resolve(process.info(1).path), "..")
    	elseif fs then
    		paths["PATH"] = fs.getDir(shell.getRunningProgram())
    	end
    end

	if not paths["RIBBON"] then
        paths["RIBBON"] = paths["PATH"].."/ribbon"
	end
	paths["RIBBON"] = paths["RIBBON"]:gsub("${DIR}", paths["DIR"]:gsub("${PATH}", paths["PATH"]))
	
	--Create environment
	local env = {}
	for k, v in pairs(_G) do
		env[k] = v
	end
	env._ENV = env
	env.shell = env.shell or shell
	env.multishell = env.multishell or multishell
	
	--Load app
	local err
	local corePath = paths["RIBBON"].."/ribbon.lua"
	ribbon, err = loadfile(corePath, env)
	if err then
		baseError = "Corrupt or Missing File!"
		error("FILE: "..corePath.."\nERROR: "..err)
	end
	
	--Setup Ribbon
	baseError = "App failed to launch!"
	ribbon = ribbon()
	
	--Setup App
	ribbon.setAppInfo(APP)
	
	--Setup debug
	pcall(function() ribbon.require("debugger").setDebugFile(APP.PATHS.DEBUGFILE) end)
	
	--Execute app
	baseError = "Application crashed!"
	return ribbon.execute(APP.PATHS.CMD, ...)
end, ...)}

--Error checking
if not results[1] then
    baseError = (type(baseError) == "string" and baseError) or 
        "A fatal error has occurred!"
	local err = results[2] or ""
	local ok = false
	if type(ribbon) == "table" then
		ok = pcall(ribbon.execute, APP.PATHS.CRASHHANDLER, baseError, err)
	end
	if not ok then 
		pcall(function()
			ribbon.require("debugger").error(baseError)
			ribbon.require("debugger").error(err)
		end)
		error(baseError.."\n"..err, -1)
	end
end

--Return results
return (unpack or table.unpack)(results, 2)