local HIDDEN_ALPHA = 45
local HIDDEN_COLOR = Color( 255, 255, 255, HIDDEN_ALPHA )

local disabledTabs = {
    ["#spawnmenu.category.dupes"] = true,
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

hook.Add( "OnSpawnMenuOpen", "CFC_SpawnMenuWhitelist", function()
    hook.Remove( "OnSpawnMenuOpen", "CFC_SpawnMenuWhitelist" )
    if LocalPlayer():IsAdmin() then return end

    hideTabs()
    -- This extra pass ensures that all tabs are removed.
    -- The Saves tab seems to be loaded in async so it wouldn't disappear until the second menu load
    timer.Simple( 0, hideTabs )
end )

local emptyResults = function() return {} end
local noop = function() end

hook.Add( "InitPostEntity", "CFC_SpawnMenuWhitelist", function()
    if LocalPlayer():IsAdmin() then return end

    -- Remove NPCs from the search provider
    local _, searchProviders = debug.getupvalue( search.AddProvider, 1 )
    searchProviders.npcs.func = emptyResults

    -- Disable Dupes entirely
    ws_dupe._Arm = ws_dupe._Arm or ws_dupe.Arm
    ws_dupe.Arm = noop

    ws_dupe._DownloadAndArm = ws_dupe._DownloadAndArm or ws_dupe.DownloadAndArm
    ws_dupe.DownloadAndArm = noop
end )

