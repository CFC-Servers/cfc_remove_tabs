local function cfcRemoveTab( tab )
	g_SpawnMenu.CreateMenu:CloseTab( tab, true )
end

local function cfcShouldRemoveTab( tab )
	local gp = language.GetPhrase
	local tabText = tab:GetText()
	
	if tabText == gp("spawnmenu.category.dupes") then return true end
	if tabText == gp("spawnmenu.category.saves") then return true end	
	if tabText == gp("spawnmenu.category.npcs") and !LocalPlayer():IsAdmin() then return true end

	return false
end

local function cfcCheckTabs()
    for _, v in pairs( g_SpawnMenu.CreateMenu.Items ) do
    	local tab = v.Tab
    	if ( cfcShouldRemoveTab( tab ) ) then cfcRemoveTab( tab ) end
    end
end

hook.Remove("OnSpawnMenuOpen", "cfcSpawnMenuWhitelist")
hook.Add( "OnSpawnMenuOpen", "cfcSpawnMenuWhitelist", cfcCheckTabs)

-- This extra pass ensures that all tabs are removed.
-- The Saves tab seems to be loaded in async so it wouldn't disappear until the second menu load
hook.Remove("OnSpawnMenuOpen", "cfcSpawnMenuWhitelist-delayed")
hook.Add( "OnSpawnMenuOpen", "cfcSpawnMenuWhitelist-delayed", function()
	timer.Simple(0, cfcCheckTabs)
end)
