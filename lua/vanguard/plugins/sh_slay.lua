PLUGIN.Title = "Slap"
PLUGIN.Description = "Slap a player."
PLUGIN.ChatCommand = "slap"
PLUGIN.Usage = "[players] [damage]"
PLUGIN.Privileges = { "Slap" }

function PLUGIN:Call( ply, args )
	if ( ply:HasPrivilege("Slap") ) then
		local players = Vanguard:FindPlayer( args[1], ply, true )
		local dmg = math.abs( tonumber( args[ #args ] ) or 10 )
		
		for _, pl in pairs( players ) do
			pl:SetHealth( pl:Health() - dmg )
			pl:ViewPunch( Angle( -10, 0, 0 ) )
			
			if ( pl:Health() < 1 ) then pl:Kill() end
		end
		
		if ( #players > 0 ) then
			Vanguard:Notify( ply:GetRankColor(), ply:Nick(), color_white, " has slapped ", Color(255,0,0), Vanguard:List(players), color_white, " with " .. 100 .. " damage." )
		else
			Vanguard:Notify( ply, Color(0,0,255),"No players found." )
		end
	else
		Vanguard:Notify( ply, Color(255,0,0),"You're not allowed to use this command!" )
	end

end