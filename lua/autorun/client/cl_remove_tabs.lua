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

hook.Add( "SpawnMenuCreated", "CFC_SpawnMenuWhitelist", function()
    if LocalPlayer():IsAdmin() then return end
    hideTabs()
end )

local emptyResults = function() return {} end
local errorSound = "buttons/button2.wav"

local function reject( message )
    LocalPlayer():ChatPrint( message )
    surface.PlaySound( errorSound )

    return false
end

local function adjustSearchProfiders()
    -- Remove NPCs from the search provider
    local _, searchProviders = debug.getupvalue( search.AddProvider, 1 )
    searchProviders.npcs.func = emptyResults
end

local function wrapDuplicator()
    ws_dupe._DownloadAndArm = ws_dupe._DownloadAndArm or ws_dupe.DownloadAndArm

    ws_dupe.DownloadAndArm = function( id )
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

            return ws_dupe._DownloadAndArm( id )
        end )
    end
end

hook.Add( "InitPostEntity", "CFC_SpawnMenuWhitelist", function()
    if LocalPlayer():IsAdmin() then return end

    adjustSearchProfiders()
    wrapDuplicator()
end )

