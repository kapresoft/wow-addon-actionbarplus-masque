--[[-----------------------------------------------------------------------------
ActionbarPlus-Masque

Optional integration with the Masque addon for ActionbarPlus button skinning.
RequiredDeps ensures this addon only loads when both ActionbarPlus-Core and
Masque are present, so no defensive nil-checks for Masque itself are needed.
-------------------------------------------------------------------------------]]
local addon, xns = ...

--- @type Namespace_ABP_Masque_2_0
local ns = xns; ABP_MASQUE_NS = ns
ns.name = addon

--- @type Namespace_ABP_2_0
local cns = ABP_Core_2_0:ns()

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]

local prefixColor = 'FFA635'
local primary = CreateColorFromRGBHexString(prefixColor)
local TRACE_NAME = primary:WrapTextInColorCode('ABP_MASQUE')

--- @param logName Name
--- @param prefix string
local function __trace(logName, prefix, ...)
  --- @type EventTrace
  local et = EventTrace; if not (et and et.LogEvent) then return end
  local n = primary:WrapTextInColorCode(logName)
  if prefix then n = n .. '::' .. prefix end
  et:LogEvent(n, ...)
end

--- @param prefix Name  @The prefix name
--- @param ... any      @Print any
local function t(prefix, ...) __trace(TRACE_NAME, prefix, ...) end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

local MasqueLib = 'Masque'
local MASQUE = strupper(MasqueLib)

local Masque = LibStub(MasqueLib) --[[@as Masque_API ]]
if not Masque then
  t(MasqueLib, 'WARN', 'Masque is not available')
  return
end

-- group definition
-- Backwards-compatible: falls back to the literal if an older ActionbarPlus-Core
-- (predating MasqueAddonName()) is installed alongside this addon.
local MASQUE_ADDON_NAME = (type(cns.MasqueAddonName) == 'function' and cns:MasqueAddonName())
  or 'ActionbarPlus'
local group = Masque:Group(MASQUE_ADDON_NAME, 'Buttons')
if not group then return end
-- Masque saves settings by the static ID, so renames are safe
local extraGroup = Masque:Group(MASQUE_ADDON_NAME, 'Buttons (Extra)', 'Buttons_Extra')

-- Masque's own Skins UI can enable/disable a group independent of anything
-- ActionbarPlus does. That resets/re-applies Masque's own textures, but leaves
-- ActionbarPlus's own per-button visuals stale until the affected bars re-render --
-- tell BarsUI to do so rather than requiring a /reload.
--- @param toggled Masque_Group
--- @param other Masque_Group
local function ForwardToggle(toggled, other)
  toggled:RegisterCallback(function(_, _, disabled)
    cns:a():SendMessage(cns:msg('OnMasqueGroupToggled'), disabled)
    -- BarsUI restores every button's own art, the other group's too
    if disabled then other:ReSkin() end
  end, 'Disabled')
end
ForwardToggle(group, extraGroup)
ForwardToggle(extraGroup, group)

--- Copies the skin only; backdrop, gloss, colors etc. stay per group
--- @param from Masque_Group
--- @param to Masque_Group
local function CopySkin(from, to)
  if to.db.SkinID == from.db.SkinID then return end
  to.db.SkinID = from.db.SkinID
  to:ReSkin()
end

-- An older ActionbarPlus has no masque table: sync on, nothing saved
--- @type MasqueConfig_ABP_2_0
local LEGACY_MASQUE_CONFIG = { syncExtraButtonsSkin = true, extraSkinSeeded = false }

--- @return MasqueConfig_ABP_2_0
local function MasqueConfig()
  if cns.masque then return cns:masque() end
  return LEGACY_MASQUE_CONFIG
end

--- @param from Masque_Group
--- @param to Masque_Group
local function SyncSkinFrom(from, to)
  -- ReSkin doesn't notify, so syncing both ways can't loop
  from:RegisterCallback(function()
    if MasqueConfig().syncExtraButtonsSkin then CopySkin(from, to) end
  end, 'SkinID')
end
SyncSkinFrom(group, extraGroup)
SyncSkinFrom(extraGroup, group)

-- Once: extra buttons keep the skin they had under Buttons
local function SeedExtraSkin()
  local mc = MasqueConfig()
  if mc.extraSkinSeeded then return end
  mc.extraSkinSeeded = true
  -- A new group copies the ActionbarPlus entry's skin, not Buttons'
  CopySkin(group, extraGroup)
end

if cns:IsDatabaseReady() then
  SeedExtraSkin()
else
  local events = LibStub('AceEvent-3.0'):Embed({})
  events:RegisterMessage(cns:msg('OnDatabaseReady'), SeedExtraSkin)
end

--- @param btn Button_ABP_2_0_X
--- @return Masque_Group
local function GroupOf(btn) return btn.widget.isExtraButton and extraGroup or group end

--- @param btn Button_ABP_2_0_X
local function RestoreTemplateArt(btn)
  if btn.FloatingBG then btn.FloatingBG:Hide() end
  btn.widget:ResetTemplateVisuals()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @return boolean
function ns:IsEnabled() return group ~= nil end

--- Buttons (Extra) takes the Buttons skin; call when sync turns on
function ns:SyncExtraButtonsSkin() CopySkin(group, extraGroup) end

--- Adds a button to its Masque skin group.
--- @param btn Button_ABP_2_0_X
function ns:AddButton(btn)
  local target = GroupOf(btn)
  --- @type table
  local buttonData = {
    Icon = btn.icon,
    Cooldown = btn.cooldown,
    Normal = btn.NormalTexture,
    Pushed = btn.PushedTexture,
    Highlight = btn.HighlightTexture,
    Checked = btn.CheckedTexture,
    HotKey = btn.HotKey,
    Count = btn.Count,
    Name = btn.Name,
    Border = btn.Border,
    AutoCastable = btn.AutoCastable,
  }
  target:AddButton(btn, buttonData)
  -- A button moved into a switched-off group keeps Masque's default art
  if target.db.Disabled then RestoreTemplateArt(btn) end
end

--- Removes a button from Masque; an extra button starts out under Buttons.
--- @param btn Button_ABP_2_0_X
function ns:RemoveButton(btn)
  group:RemoveButton(btn)
  extraGroup:RemoveButton(btn)
end

--- Re-applies the current skin to a single button (or all buttons if omitted).
--- @param btn? Button_ABP_2_0_X
function ns:ReSkin(btn)
  if btn then return GroupOf(btn):ReSkin(btn) end
  group:ReSkin()
  extraGroup:ReSkin()
end

--- @param groupKey? string  -- Masque options-panel group key (Addon.."_"..Group), e.g. from
--- a layout's GetMasqueGroupKey(). Defaults to the shared 'ActionbarPlus_Buttons' group.
function ns:OpenMasqueSettings(groupKey)
  if not self:IsEnabled() then return end

  local ACD = cns:AceConfigDialog()

  SlashCmdList[MASQUE]('') -- forces Setup('LoD'), opens to Skins/Global

  C_Timer.After(0.01, function()
    ACD:Open(MasqueLib)
    local key = groupKey or (MASQUE_ADDON_NAME .. '_Buttons')
    ACD:SelectGroup(MasqueLib, 'Skins', MASQUE_ADDON_NAME, key)
  end)
end
