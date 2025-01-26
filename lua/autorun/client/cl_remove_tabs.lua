local HIDDEN_ALPHA = 45
local HIDDEN_COLOR = Color( 255, 255, 255, HIDDEN_ALPHA )


--- Visibly disables the given tab element and hides its panel
local function hide( item )
    local tab = item.Tab
    tab:SetEnabled( false )
    tab:SetCursor( "no" )
    tab:SetTextColor( HIDDEN_COLOR )

    local icon = tab:GetChildren()[1]
    icon:SetAlpha( HIDDEN_ALPHA )

    tab:InvalidateLayout( true )
    tab:InvalidateChildren( true )

    local panel = item.Panel
    panel:SetVisible( false )
end

--- Hides a specific tab by name
--- @param name string
local function hideTab( name )
    for _, item in ipairs( g_SpawnMenu.CreateMenu.Items ) do
        if item.Name == name then
            hide( item )
        end
    end
end

--- Rejects the action and notifies the player
local function reject( message )
    LocalPlayer():ChatPrint( message )
    surface.PlaySound( "buttons/button2.wav" )

    return false
end

--- Remove NPCs from the search provider
local function removeNPCSearching()
    local _, searchProviders = debug.getupvalue( search.AddProvider, 1 )
    searchProviders.npcs.func = function() return {} end
end

--- Wrap the Duplicator to reject non-owner (or banned) dupes
local function wrapDuplicator()
    ws_dupe._DownloadAndArm = ws_dupe._DownloadAndArm or ws_dupe.DownloadAndArm

    ws_dupe.DownloadAndArm = function( self, id )
        -- Exploit fix?
        if not IsValid( LocalPlayer() ) then return end

        -- Reject banned or non-owner dupes
        steamworks.FileInfo( id, function( result )
            local banned = result.banned
            if banned then return reject( "ERROR: Unable to spawn banned workshop items!" ) end

            local ownerSteamID64 = result.owner
            if ownerSteamID64 ~= LocalPlayer():SteamID64() then
                return reject( "ERROR: You can only spawn your own Dupes!" )
            end

            return ws_dupe._DownloadAndArm( self, id )
        end )
    end
end

--- Hides the Saves and Post-Processing tabs
local function hideCommonTabs()
    hideTab( "#spawnmenu.category.saves" )
end

local function setup()
    local me = LocalPlayer()
    local isAdmin = me:IsAdmin()

    -- Always block common tabs from non-admins
    if not isAdmin then
        hideCommonTabs()
        hook.Add( "SpawnMenuCreated", "CFC_RemoveTabs_HideCommonTabs", hideCommonTabs )
    end

    -- NPCs specifically
    do
        local shouldBlock = hook.Run( "CFC_RemoveTabs_ShouldBlockNPCs", me )

        -- Return false to not block them
        if shouldBlock == false then return end

        -- Return nothing to rely on default behavior (admin only)
        if shouldBlock == nil and isAdmin then return end

        removeNPCSearching()
        hideTab( "#spawnmenu.category.npcs" )
        hook.Add( "SpawnMenuCreated", "CFC_RemoveTabs_HideNPCs", function()
            hideTab( "#spawnmenu.category.npcs" )
        end )
    end

    -- Duplicator
    do
        local shouldLimit = hook.Run( "CFC_RemoveTabs_ShouldBlockDupes", me )

        -- Return false to allow them full access
        if shouldLimit == false then return end

        -- If no return, then limit dupes for non-admins (default behavior)
        if shouldLimit == nil and isAdmin then return end

        wrapDuplicator()
    end
end

hook.Add( "InitPostEntity", "CFC_RemoveTabs", setup )
