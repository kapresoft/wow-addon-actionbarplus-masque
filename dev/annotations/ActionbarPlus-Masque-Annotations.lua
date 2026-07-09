--- @meta

--[[-----------------------------------------------------------------------------
ActionbarPlus-Masque Annotations

EmmyLua annotations for the ABP_MASQUE_NS namespace defined in
ActionbarPlus-Masque/ActionbarPlus-Masque.lua. `Button_ABP_2_0_X` is an
external type defined in ActionbarPlus-Core.
-------------------------------------------------------------------------------]]

--- @class Namespace_ABP_Masque_2_0
--- @field name string
local Namespace_ABP_Masque_2_0 = {}

--- @return boolean
function Namespace_ABP_Masque_2_0:IsEnabled() end

--- Adds a button to the Masque skin group.
--- @param btn Button_ABP_2_0_X
function Namespace_ABP_Masque_2_0:AddButton(btn) end

--- Removes a button from the Masque skin group.
--- @param btn Button_ABP_2_0_X
function Namespace_ABP_Masque_2_0:RemoveButton(btn) end

--- Re-applies the current skin to a single button (or all buttons if omitted).
--- @param btn? Button_ABP_2_0_X
function Namespace_ABP_Masque_2_0:ReSkin(btn) end

--- @type Namespace_ABP_Masque_2_0
ABP_MASQUE_NS = nil