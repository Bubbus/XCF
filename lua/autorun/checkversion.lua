local fetch_url = "https://api.github.com/repos/Bubbus/XCF/commits?per_page=1"
local fetch_reg = "\"sha\":\"(%w+)\","

local c_hash


timer.Simple( 1, function()
	-- Update Check
	http.Fetch( fetch_url, function( fetch_str )
		local g_hash = string.match( fetch_str, fetch_reg )
		
		if not g_hash then
			print("XCF Version check failed!  Couldn't retrieve the online version!")
			return;
		end
		
		if not c_hash then
			chat.AddText( Color(225,225,255), "XCF is not installed (or incorrectly installed)!" )
		elseif c_hash != g_hash then
			chat.AddText( Color(225,225,255), "XCF is out of date!" )
		end
	end)
end)


local versionfile = file.Read( ".git/FETCH_HEAD", "GAME" )

local lines = string.Explode(versionfile, "\n")
local masterline, isXCF
for k, line in pairs(lines) do
	if string.find(line, "XCF_VCHECK") then
		isXCF = true
	elseif not masterline and string.find(line, "master") then
		masterline = line
	end
end

if isXCF then
	c_hash = string.Left( masterline, 40 )
end
 