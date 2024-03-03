local HIDDEN_ALPHA = 45
local HIDDEN_COLOR = Color( 255, 255, 255, HIDDEN_ALPHA )

local disabledTabs = {
    ["#spawnmenu.category.saves"] = true,
    ["#spawnmenu.category.npcs"] = true
}

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

local function hideTabs()
    for _, item in ipairs( g_SpawnMenu.CreateMenu.Items ) do
        if disabledTabs[item.Name] then
            hide( item )
        end
    end
end

local emptyResults = function() return {} end
local errorSound = "buttons/button2.wav"

--- Rejects the action and notifies the player
local function reject( message )
    LocalPlayer():ChatPrint( message )
    surface.PlaySound( errorSound )

    return false
end

--- Remove NPCs from the search provider
local function adjustSearchProfiders()
    local _, searchProviders = debug.getupvalue( search.AddProvider, 1 )
    searchProviders.npcs.func = emptyResults
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

--- Blocks NPCs and Saves from the spawn menu
local function blockTabs()
    adjustSearchProfiders()
    hideTabs()

    hook.Add( "SpawnMenuCreated", "CFC_SpawnMenuWhitelist", function()
        hideTabs()
    end )
end

hook.Add( "InitPostEntity", "CFC_SpawnMenuWhitelist", function()
    local me = LocalPlayer()

    -- NPCs/Saves
    do
        local shouldBlock = hook.Run( "CFC_SpawnMenuWhitelist_ShouldBlockTabs", me )

        -- Return false to allow them full access
        if shouldBlock == false then return end

        -- If no return, then restrict the spawn menu for non-admins (default behavior)
        if shouldBlock == nil and me:IsAdmin() then return end

        blockTabs()
    end

    -- Duplicator
    do
        local shouldLimit = hook.Run( "CFC_SpawnMenuWhitelist_ShouldLimitDupes", me )

        -- Return false to allow them full access
        if shouldLimit == false then return end

        -- If no return, then limit dupes for non-admins (default behavior)
        if shouldLimit == nil and me:IsAdmin() then return end

        wrapDuplicator()
    end
end )
