--[[-----------------------------------------------------------------------------
ActionbarPlus-Masque

Optional integration with the Masque addon for ActionbarPlus button skinning.
RequiredDeps ensures this addon only loads when both ActionbarPlus-Core and
Masque are present, so no defensive nil-checks for Masque itself are needed.
-------------------------------------------------------------------------------]]
local addon, xns = ...

--- @type Namespace_ABP_Masque_2_0
local ns = xns
ns.name = addon
ABP_MASQUE_NS = ns

local Masque = LibStub('Masque') --[[@as Masque_API ]]
local group = Masque:Group('ActionbarPlus', 'Action Bars')

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @return boolean
function ns:IsEnabled() return group ~= nil end

--- Adds a button to the Masque skin group.
--- @param btn Button_ABP_2_0_X
function ns:AddButton(btn)
  --- @type table
  local buttonData = {
    Icon         = btn.icon,
    Cooldown     = btn.cooldown,
    Normal       = btn.NormalTexture,
    Pushed       = btn.PushedTexture,
    Highlight    = btn.HighlightTexture,
    Checked      = btn.CheckedTexture,
    HotKey       = btn.HotKey,
    Count        = btn.Count,
    Name         = btn.Name,
    Border       = btn.Border,
    AutoCastable = btn.AutoCastable,
  }
  group:AddButton(btn, buttonData)
end

--- Removes a button from the Masque skin group.
--- @param btn Button_ABP_2_0_X
function ns:RemoveButton(btn) group:RemoveButton(btn) end

--- Re-applies the current skin to a single button (or all buttons if omitted).
--- @param btn? Button_ABP_2_0_X
function ns:ReSkin(btn) group:ReSkin(btn) end