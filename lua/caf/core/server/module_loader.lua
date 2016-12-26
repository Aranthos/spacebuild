AddCSLuaFile("includes/modules/ArrayList.lua")
AddCSLuaFile("includes/modules/HashMap.lua")
AddCSLuaFile("includes/modules/cache.lua")

require("ArrayList")
require("HashMap")
require("CustomAttack")
require("CustomArmor")

local meta = FindMetaTable("Entity")

function meta:getCustomArmor()
    return self.caf.custom.armor
end

function meta:setCustomArmor(armor)
    self.caf.custom.armor = armor
end


function meta:WaterLevel2()
    local waterlevel = self:WaterLevel()
    if (self:GetPhysicsObject():IsValid() and self:GetPhysicsObject():IsMoveable()) then
        --Msg("Normal WaterLEvel\n")
        return waterlevel --this doesn't look like it works when ent is welded to world, or not moveable
    else
        --Msg("Special WaterLEvel\n") --Broken in Gmod SVN!!!
        if (waterlevel ~= 0) then
            return waterlevel
        end
        local trace = {}
        trace.start = self:GetPos()
        trace.endpos = self:GetPos()
        trace.filter = { self }
        trace.mask = 16432 -- MASK_WATER
        local tr = util.TraceLine(trace)
        if (tr.Hit) then
            return 3
        end
    end
    return 0
end










