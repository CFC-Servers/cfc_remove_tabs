# Remove Tabs (util)
- Disables Saves/Postprocessing/NPCs tabs in the Q menu
- Removes NPCs from the Q menu search results
- Limits Dupes to only be spawnable by the player that created them _(no public dupes)_

This is great for Sandbox servers that don't want players seeing or using these tabs.

This is a fully clientside addon, and its behavior is configurable through hooks.

By default, this only applies its limits for non-admins. If this is fine for you, you don't have to do anything extra.

If you need more control, read the [Config](#Config) section.

## Installation
Clone or download into your server's `addons/` directory


## Config
You can use the available hooks to modify this addon's behavior.

### `CFC_RemoveTabs_ShouldBlockNPCs`
- Sends `LocalPlayer()`
- Return `false` to not block NPCs _(allowing them access to the NPC tabs and get search results for them)_
- Return `true` to block NPCs _(hiding the tabs, preventing them from accessing the tab or getting NPCs in search results)_
- Default behavior is to block NPCs for non-admins

#### Example
```lua
local allowed = {
    moderator = true,
    admin = true,
    superadmin = true
}

-- Allow `moderator`, `admin`, and `superadmin` access to the NPCs tab
hook.Add( "CFC_RemoveTabs_ShouldBlockNPCs", "MyRankAllower", function( ply )
    if allowed[ply:GetUserGroup()] then return false end
end )
```

### `CFC_RemoveTabs_ShouldBlockDupes`
- Sends `LocalPlayer()`
- Return `false` to not block dupes _(allowing players to spawn any Dupes from the Dupes tab)_
- Return `true` to block dupes _(allowing players to only spawn dupes they created)_
- Default behavior is to limit non-admins to only spawning dupes they created

#### Example
```lua
local allowed = {
    moderator = true,
    admin = true,
    superadmin = true
}

-- Allow `moderator`, `admin`, and `superadmin` unrestricted access to the Dupes tab
hook.Add( "CFC_RemoveTabs_ShouldBlockDupes", "MyRankAllower", function( ply )
    if allowed[ply:GetUserGroup()] then return false end
end )
```
