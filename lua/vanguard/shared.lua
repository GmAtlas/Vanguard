Vanguard = {}
Vanguard.Plugins = {}
Vanguard.StockRanks = {}
Vanguard.Ranks = {}
Vanguard.Players = {}
Vanguard.Privileges = {}

Vanguard.Ranks.Guest = {}
Vanguard.Ranks.Guest.Title = "Guest"
Vanguard.Ranks.Guest.UserGroup = "Guest"
Vanguard.Ranks.Guest.Color = Color(0,255,0)
Vanguard.Ranks.Guest.Immunity = 0
Vanguard.Ranks.Guest.IsAdmin = false
Vanguard.Ranks.Guest.CanTarget = {"Guest"}
Vanguard.Ranks.Guest.Privileges = {}

Vanguard.Ranks.Moderator = {}
Vanguard.Ranks.Moderator.Title = "Moderator"
Vanguard.Ranks.Moderator.UserGroup = "Moderator"
Vanguard.Ranks.Moderator.Color = Color(0,0,255)
Vanguard.Ranks.Moderator.Immunity = 1
Vanguard.Ranks.Moderator.IsAdmin = false
Vanguard.Ranks.Moderator.CanTarget = {"Guest","Moderator"}
Vanguard.Ranks.Moderator.Privileges = {"Slap"}

  

_VG = table.Copy(_G)
if not Vanguard_HOOKCALL then Vanguard_HOOKCALL = hook.Call end

local PMeta = FindMetaTable("Player")

if not file.Exists( "vanguard", "DATA" ) then
	file.CreateDir( "vanguard" )
end


if SERVER then 
include("logs.lua")	

function Vanguard:Notify( ... )
		local arg = { ... }
		
		if ( type( arg[1] ) == "Player" or arg[1] == NULL ) then ply = arg[1] end
		
		if ( ply != NULL ) then
			net.Start( "Vanguard_Message" )
				net.WriteUInt( #arg, 16 )
				for _, v in ipairs( arg ) do
					if ( type( v ) == "string" ) then
						net.WriteBit(false)
						net.WriteString( v )
					elseif ( type ( v ) == "table" ) then
						net.WriteBit(true)
						net.WriteUInt( v.r, 8 )
						net.WriteUInt( v.g, 8 )
						net.WriteUInt( v.b, 8 )
						net.WriteUInt( v.a, 8 )
					end
				end
			if ply ~= nil then
				net.Send(ply)
			else
				net.Broadcast()
			end
		end
		
		local str = ""
		
	end

else

	function Vanguard:Notify( ... )
		local arg = { ... }
		
		args = {}
		for _, v in ipairs( arg ) do
			if ( type( v ) == "string" or type( v ) == "table" ) then table.insert( args, v ) end
		end
		
		chat.AddText( unpack( args ) )
	end
	
	net.Receive( "Vanguard_Message", function( length )
		local argc = net.ReadUInt(16)
		local args = {}
		for i = 1, argc do
			if net.ReadBit() == 1 then
				table.insert( args, Color( net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8) ) )
			else
				table.insert( args, net.ReadString() )
			end
		end
		
		chat.AddText( unpack( args ) )
	end )

end





function Vanguard:LoadPlugins()	

			local files, _ = file.Find('vanguard/plugins/*.lua', 'LUA')
			  
			for _, name in pairs(files) do
print(_,name)
			if name ~= '__category.lua' then
				print(_,name)
					if SERVER then AddCSLuaFile('vanguard/plugins/' .. name) end
					
					PLUGIN = {}
					
					PLUGIN.__index = PLUGIN
					PLUGIN.ID = string.gsub(string.lower(name), '.lua', '')
					PLUGIN.Title = ""
					PLUGIN.Description = ""
					PLUGIN.Usage = ""
					PLUGIN.Privileges = { "" }
				
					include('vanguard/plugins/' .. name)

					local item = PLUGIN
					

					self.Plugins[PLUGIN.ID] = PLUGIN
					
					PLUGIN = nil
				end
			end
		end
		
		
	hook.Call = function( name, gm, ... )
	
	return Vanguard.HookCall( name, gm, ... )
end
		
		local errCount, s = {}, {}
local function sort( a, b ) return a[2] < b[2] end
function Vanguard.HookCall( name, gm, ... )

	s = {}
	for _, plug in pairs( Vanguard.Plugins ) do
	
		if type( plug[ name ] ) == "function"  then
	
			table.insert( s, { plug, 1 } )
		end
	end
	
	table.sort( s, sort )
	for _, d in ipairs( s ) do
		local plug = d[1]
		local data = { pcall( plug[ name ], plug, ... ) }


		if data[1] == true and data[2] != nil then
			table.remove( data, 1 )
			return unpack( data )
		elseif data[1] == false then 
			if not errCount[ name ] then errCount[ name ] = {} end
			if not errCount[ name ][ plug.ID ] then errCount[ name ][ plug.ID ] = 0 end
			
			
		end
	end
	
	return Vanguard_HOOKCALL( name, gm, ... )
end

function Vanguard:IsNameMatch( ply, str )
	if ( str == "*" ) then
		return true
	elseif ( string.match( str, "STEAM_[0-5]:[0-9]:[0-9]+" ) ) then
		return ply:SteamID() == str
	elseif ( string.Left( str, 1 ) == "\"" and string.Right( str, 1 ) == "\"" ) then
		return ( ply:Nick() == string.sub( str, 2, #str - 1 ) )
	else
		return ( string.lower( ply:Nick() ) == string.lower( str ) or string.find( string.lower( ply:Nick() ), string.lower( str ), nil, true ) )
	end
end
		 
function Vanguard:FindPlayer( name, def, nonum, noimmunity )
	local matches = {}
	
	if ( !name or #name == 0 ) then
		matches[1] = def
	else
		if ( type( name ) != "table" ) then name = { name } end
		local name2 = table.Copy( name )
		if ( nonum ) then
			if ( #name2 > 1 and tonumber( name2[ #name2 ] ) ) then table.remove( name2, #name2 ) end
		end
		
		for _, ply in pairs( player.GetAll() ) do
			for _, pm in pairs( name2 ) do
					print(ply,pm,def)
				if ( Vanguard:IsNameMatch( ply, pm ) and !table.HasValue( matches, ply )   ) then table.insert( matches, ply ) end
			end
		end
	end
	
	return matches
end


function PMeta:CanTarget(ply)
	return table.HasValue( Vanguard.Ranks[self:GetRank()].CanTarget, ply:GetRank() )
end
function PMeta:CanTargetOrEqual( ply )
	return ( table.HasValue(Vanguard.Ranks[self:GetRank()].CanTarget,ply:GetRank()) or ( self:GetRank() == ply:GetRank() ) ) 
end

function PMeta:HasPrivilege( pri )
	if ( Vanguard.Ranks[ self:GetRank() ] ) then
		return table.HasValue( Vanguard.Ranks[ self:GetRank() ].Privileges, pri )
	else
		return false
	end
end

function PMeta:SetValue(id,val)
	if not Vanguard.PlayerInfo[self:SteamID()] then Vanguard.PlayerInfo[self:SteamID()] = {} end
		   Vanguard.PlayerInfo[self:SteamID()][id] = val
	
end

function PMeta:GetValue(id,val)
		 return  Vanguard.PlayerInfo[self:SteamID()][id] or val
	
end

function PMeta:IsAdmin()
	return Vanguard.Ranks[self:GetRank()].IsAdmin
end

function PMeta:SetRank( rank )
	if( not Vanguard.Ranks[rank]) then return end
	self:SetValue( "Rank", rank )
	self:SetNWString( "UserGroup", rank )
	self:SetUserGroup(rank)

end

function PMeta:GetRank()
	local rank = self:GetNetworkedString( "UserGroup" )
	
	if rank == "" then return "Guest" end
	if !rank then return "Guest" end
	if !Vanguard.Ranks[rank] then return "Guest" end
	
	return rank
end
function PMeta:GetRankColor()
return self:GetRank().Color or color_white 
end

function Vanguard:List( tbl, notall )
	local lst = ""
	local lword = "and"
	if ( notall ) then lword = "or" end
	
	if ( #tbl == 1 ) then
		lst = tbl[1]:Nick()
	elseif ( #tbl == #player.GetAll() ) then
		lst = "everyone"
	else
		for i = 1, #tbl do
			if ( i == #tbl ) then lst = lst .. " " .. lword .. " " .. tbl[i]:Nick() elseif ( i == 1 ) then lst = tbl[i]:Nick() else lst = lst .. ", " .. tbl[i]:Nick() end
		end
	end
	
	return lst
end

function Vanguard:LoadPlayers()

		if ( file.Exists( "vanguard/playerinfo.txt", "DATA" ) ) then
			debug.sethook()
			self.PlayerInfo = util.JSONToTable( file.Read( "vanguard/playerinfo.txt", "DATA" ) )
			
			for k,v in pairs(player.GetAll()) do
			if(self.PlayerInfo[v:SteamID()]) then 
				v:SetRank(self.PlayerInfo [v:SteamID()] ["Rank"] )
			end
			end 
			
		else
			self.PlayerInfo = {}
		end
end

	function Vanguard:SavePlayerInfo()
		file.Write( "vanguard/playerinfo.txt", util.TableToJSON( self.PlayerInfo ) )
	end

function Vanguard:SaveRanks()
		file.Write( "vanguard/userranks.txt", util.TableToJSON(Vanguard.Ranks) )
end

function Vanguard:LoadRanks()
	if ( file.Exists( "vanguard/userranks.txt", "DATA" ) ) then
		Vanguard.Ranks = util.JSONToTable( file.Read( "vanguard/userranks.txt", "DATA" ) )
	else
		Vanguard:SaveRanks()
	end
end




