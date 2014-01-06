local meta = FindMetaTable("Player")
if not meta then return end

--[[---------------------------------------------------------
    Name: IsAdmin
    Desc: Returns if a player is an admin.
-----------------------------------------------------------]]
function meta:IsAdmin()
	-- Admin SteamID need to be fully authenticated by Steam!
	if self.IsFullyAuthenticated and not self:IsFullyAuthenticated() then return false end
	
	if self:IsSuperAdmin() then return true end
	if self:IsUserGroup("admin") then return true end

	return false
end

--[[---------------------------------------------------------
    Name: IsSuperAdmin
    Desc: Returns if a player is a superadmin.
-----------------------------------------------------------]]
function meta:IsSuperAdmin()
	-- Admin SteamID need to be fully authenticated by Steam!
	if self.IsFullyAuthenticated and not self:IsFullyAuthenticated() then return false end

	return self:IsUserGroup("superadmin")
end

--[[---------------------------------------------------------
    Name: IsUserGroup
    Desc: Returns if a player is in the specified usergroup.
-----------------------------------------------------------]]
function meta:IsUserGroup(name)
	if not self:IsValid() then return false end

	return self:GetNetworkedString("UserGroup") == name
end

--[[---------------------------------------------------------
    Name: SetUserGroup
    Desc: Sets the player's usergroup. ( Serverside Only )
-----------------------------------------------------------]]
function meta:SetUserGroup(name)
	self:SetNetworkedString("UserGroup", name)
end

--[[---------------------------------------------------------
    Name: GetUserGroup
    Desc: Returns the player's usergroup.
-----------------------------------------------------------]]
function meta:GetUserGroup()
	return self:GetNetworkedString("UserGroup", "user")
end


--[[---------------------------------------------------------
    This is the meat and spunk of the player auth system
-----------------------------------------------------------]]

if not SERVER then return end

-- SteamIds table..
-- STEAM_0:1:7099:
--	 	 name	=	garry
--	 	 group	=	superadmin
local SteamIDs = {}

-- Load the users file
local UsersKV = util.KeyValuesToTable( file.Read( "settings/users.txt", "GAME" ) )

-- Extract the data into the SteamIDs table
for key, tab in pairs( UsersKV ) do
	for name, steamid in pairs( tab ) do
		SteamIDs[ steamid ] = {}
		SteamIDs[ steamid ].name = name
		SteamIDs[ steamid ].group = key
	end
end

hook.Add("PlayerInitialSpawn", "PlayerAuthSpawn", function(ply)
	local steamid = ply:SteamID()
	
	if game.SinglePlayer() or ply:IsListenServerHost() then
		ply:SetUserGroup("superadmin")
		return
	end
	
	if SteamIDs[steamid] == nil then
		ply:SetUserGroup("user")
		return
	end

	ply:SetUserGroup(SteamIDs[steamid].group)
	ply:ChatPrint(string.format("Hey '%s' - You're in the '%s' group on this server.",
		SteamIDs[steamid].name, SteamIDs[steamid].group))
end)