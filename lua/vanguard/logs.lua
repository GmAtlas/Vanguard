file.CreateDir("vanlogs/")

function Vanguard:Log( str )
	if ( CLIENT ) then return end
	
	local logFile = "vanlogs/" .. os.date( "%d-%m-%Y" ) .. ".txt"
	local files = file.Find( "vanlogs/" .. os.date( "%d-%m-%Y" ) .. "*.txt", "DATA" )
	table.sort( files )
	if ( #files > 0 ) then logFile = "vanlogs/" .. files[math.max(#files-1,1)] end
	
	local src = file.Read( logFile, "DATA" ) or ""
	if ( #src > 200 * 1024 ) then
		logFile = "vanlogs/" .. os.date( "%d-%m-%Y" ) .. " (" .. #files + 1 .. ").txt"
	end
	
	file.Append( logFile, "[" .. os.date() .. "] " .. str .. "\n" )
	print("[" .. os.date() .. "] " .. str)
end