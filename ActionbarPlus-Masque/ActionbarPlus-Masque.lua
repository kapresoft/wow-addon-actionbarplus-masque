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
  t(MasqueLib, 'WARN', 'Masque is not available'); return
end

-- group definition
local group = Masque:Group('ActionbarPlus', 'Buttons')

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

function ns:OpenMasqueSettings()
  if not self:IsEnabled() then return end

  local ACD = LibStub('AceConfigDialog-3.0', true)
  if not ACD then return end

  if SlashCmdList and SlashCmdList[MASQUE] then
    SlashCmdList[MASQUE]('')  -- forces Setup('LoD'), opens to Skins/Global
    if ACD.OpenFrames[m] then ACD:Close(MASQUE) end
  end

  C_Timer.After(0.01, function()
      ACD:Open(MasqueLib)
      local ok, err = pcall(function()
        ACD:SelectGroup(MasqueLib, 'Skins', 'ActionbarPlus', 'ActionbarPlus_Buttons')
      end)
      if not ok then t('OpenMasqueSettings', 'SelectGroup failed. err=', err) end
  end)
end