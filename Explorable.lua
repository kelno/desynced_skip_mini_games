-- function dump(o, indent)
--   indent = indent or ""
--   if type(o) == "table" then
--     for k, v in pairs(o) do
--       local key = tostring(k)
--       if type(v) == "table" then
--         print(indent .. key .. " = {")
--         dump(v, indent .. "  ")
--         print(indent .. "}")
--       else
--         print(indent .. key .. " = " .. tostring(v))
--       end
--     end
--   else
--     print(indent .. tostring(o))
--   end
-- end

local logPrefix = "[mod:kelno_skipminigames] "

local function modPrint(message)
  print(logPrefix .. message)
end

local function modError(message)
  print(logPrefix .. "Error: " .. message)
end

-- End helper functions

-- Don't do anything if minigames are already disabled in this save
if Map.GetSettings().disable_minigames then
  return
end

--[[
Just overriding Map.GetSettings().disable_minigames seem to work!
-- Map.GetSettings().disable_minigames = true
This triggers an error in the console but then disable minigames in the save anyway.
But this is not the cleanest, as this stays even if the mod is disabled. (I didn't manage to remove it at all after running it)
So we'll take the longer route and override ExplorablePuzzle:construct function to mimic the map setting behavior.
--]]

local explorablePuzzle = UI.GetRegisteredLayoutClass("ExplorablePuzzle")

if not explorablePuzzle then
  modError("Couldn't override ExplorablePuzzle — registered class not found")
  return
end

if not type(explorablePuzzle.construct) == "function" then
  modError(logPrefix .. "Couldn't override ExplorablePuzzle:construct — not a function")
  return
end

-- Alter explorablePuzzle construction to mimic Map.GetSettings().disable_minigames being set
local old_construct = explorablePuzzle.construct
explorablePuzzle.construct = function(self, ...)
  old_construct(self, ...)

  self.on_button = function(btn)
    Action.SendForLocalFaction("ExplorableSolvePuzzle", { comp = self.comp })
  end
end
modPrint("Override ExplorablePuzzle:construct successful")
