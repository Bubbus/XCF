-- Git version checker, by Bubbus based on work by Shadowsicon!

local fetch_url = "https://api.github.com/repos/Bubbus/XCF/commits?per_page=1" -- Your repo goes here!
local fetch_reg = "\"sha\":\"(%w+)\"," -- Pattern for finding the internet version
local folder_ID_File = "xcf.txt" -- A file unique to the addon folder, useful for identifying the addon.

local doGitFileCheck = true -- Should we check the integrity of the git FETCH_HEAD? (requires a unique branch name!)
local git_ID_branch = "XCF_VCHECK" -- Find this branch in the FETCH_HEAD file - if it isn't there, we're in the wrong folder!

local addon_printname = "XCF" -- What name do players know your addon by?
local complainAboutSuccess = true -- Print happy text if we're all updated?



local printStatus

if CLIENT then

	printStatus = function(col, text)
		chat.AddText(col, text)
	end
	
elseif SERVER then

	printStatus = function(col, text)
		MsgC(col, text)
	end
	
end




local localhash

timer.Simple( 1, function()

	http.Fetch( fetch_url, function( fetch_str )
	
		if not localhash then
			printStatus( Color(225, 0, 0), addon_printname .. " is not installed (or incorrectly installed)!" )
			return
		end
	
	
		local webhash = string.match( fetch_str, fetch_reg )
		
		if not webhash then
			printStatus( Color(225, 0, 0), addon_printname .. " Version check failed!  Couldn't retrieve the online version!")
			return
		end
		
		
		if localhash ~= webhash then
			printStatus( Color(225, 0, 0), addon_printname .. " is out of date!" )
		else
			if complainAboutSuccess then printStatus( Color(0, 225, 0), "You're running the latest version of " .. addon_printname .. "!" ) end
		end
		
	end)
	
end)




local function VCheck_FindAddonFolder()
	local addonfiles, addonfolders = file.Find("addons/*", "GAME")
	local addonfolder
	--print(addonfiles and (#addonfiles .. " addon files!") or "No addon files!", addonfolders and (#addonfolders .. " addon folders!") or "No addon folders!")

	if not addonfolders or #addonfolders == 0 then return end

	
	for k, folder in pairs(addonfolders) do
	
		local folder = "addons/" .. folder
		addonfiles = file.Find(folder .. "/*.*", "GAME")
		
		for k, afile in pairs(addonfiles) do
		
			if afile == folder_ID_File then
				addonfolder = folder
				break
			end
			
		end	
		
	end
		
		
	--print(addonfolder and ("Got addon folder " .. addonfolder) or "Didn't find the addon folder!")
	return addonfolder
end




local function VCheck_GetLocalVersion_Git()
	
	local addonfolder = VCheck_FindAddonFolder()
	if not addonfolder then return end
	
	local versionfilename = addonfolder .. "/.git/FETCH_HEAD"
	if not file.Exists(versionfilename, "GAME") then return end
	
	local versionfile = file.Read( versionfilename, "GAME" )
	--print(versionfile)

	local lines = string.Explode("\n", versionfile, true)
	
	local masterline
	if doGitFileCheck then
	
		local isCorrectGit = false
		for k, line in pairs(lines) do
		
			if string.find(line, git_ID_branch) then
				isCorrectGit = true
			elseif not masterline and string.find(line, "master") then
				masterline = line
			end
			
			if isCorrectGit and masterline then break end
			
		end
		
		if not isCorrectGit then return end
		
	else
	
		for k, line in pairs(lines) do
		
			if not masterline and string.find(line, "master") then
				masterline = line
				break
			end

		end
	
	end

	if not masterline then return end
	
	localhash = string.Left( masterline, 40 )
	--print("Got local master hash!", localhash)
	
	return localhash
end




localhash = VCheck_GetLocalVersion_Git()



