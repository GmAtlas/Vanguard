PLUGIN.Title = "Chat Commands"
PLUGIN.Description = "Provides chat commands to run plugins."


function PLUGIN:Levenshtein( s, t )
	local d, sn, tn = {}, #s, #t
	local byte, min = string.byte, math.min
	for i = 0, sn do d[i * tn] = i end
	for j = 0, tn do d[j] = j end
	for i = 1, sn do
		local si = byte(s, i)
		for j = 1, tn do
d[i*tn+j] = min(d[(i-1)*tn+j]+1, d[i*tn+j-1]+1, d[(i-1)*tn+j-1]+(si == byte(t,j) and 0 or 1))
		end
	end
	return d[#d]
end

function PLUGIN:GetCommand( msg )
	print(( string.match( msg, "%w+" ) or "" ):lower())
	return ( string.match( msg, "%w+" ) or "" ):lower()
end

function PLUGIN:GetArguments( msg )
	local args = {}
	local first = true
	
	for match in string.gmatch( msg, "[^ ]+" ) do
		if ( first ) then first = false else
			table.insert( args, match )
		end
	end
	
	return args
end

function PLUGIN:PlayerSay( ply, msg )

	if ( string.Left( msg, 1 ) == "!" or string.Left( msg, 1 ) == "@" ) then
		local command = self:GetCommand( msg )
		local args = self:GetArguments( msg )
		local closest = { dist = 99, plugin = "" }
		
		if ( #command > 0 ) then
			
			for _, plugin in pairs( Vanguard.Plugins ) do
		
				if ( plugin.ChatCommand == command  ) then
				
						res, ret = pcall( plugin.Call, plugin, ply, args, string.sub( msg, #command + 3 ), command )
					if ( !res ) then
	
					end
					
					return ""
				elseif ( plugin.ChatCommand ) then					
					local dist = self:Levenshtein( command, type( plugin.ChatCommand ) == "table" and plugin.ChatCommand[1] or plugin.ChatCommand )
					if ( dist < closest.dist ) then
						closest.dist = dist
						closest.plugin = plugin
					end
				end
			end
		end
	end
end