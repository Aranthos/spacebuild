-- Copyright 2016 SB Dev Team (http://github.com/spacebuild)
--
--    Licensed under the Apache License, Version 2.0 (the "License");
--    you may not use this file except in compliance with the License.
--    You may obtain a copy of the License at
--
--        http://www.apache.org/licenses/LICENSE-2.0
--
--    Unless required by applicable law or agreed to in writing, software
--    distributed under the License is distributed on an "AS IS" BASIS,
--    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--    See the License for the specific language governing permissions and
--    limitations under the License.


--
-- Created by IntelliJ IDEA.
-- User: Stijn
-- Date: 22/05/2016
-- Time: 11:13
-- To change this template use File | Settings | File Templates.
--

local print = print
local class = SPACEBUILD.class

require("luaunit")
local lu = luaunit

TestRD = {} --class
local TestRD = TestRD
function TestRD:setUp()
    self.resourceRegistry = class.new("rd/ResourceRegistry")
    self.resourceRegistry:registerResourceInfo(1, "energy", "Energy", { "ENERGY" })
    self.resourceRegistry:registerResourceInfo(2, "oxygen", "Oxygen", { "GAS" })
    self.resourceRegistry:registerResourceInfo(3, "water", "Water", { "LIQUID", "COOLANT" })
    self.resourceRegistry:registerResourceInfo(4, "hydrogen", "Hydrogen", { "GAS", "FLAMABLE" })
    self.resourceRegistry:registerResourceInfo(5, "nitrogen", "Nitrogen", { "GAS", "COOLANT" })
    self.resourceRegistry:registerResourceInfo(6, "co2", "Carbon Dioxide", { "GAS" })
end

function TestRD:tearDown()
    self.resourceRegistry = nil
end

function TestRD:testResource()
    local resource = class.new("rd/Resource", "resource_name", 0, 0, self.resourceRegistry)
    lu.assert(resource)
    lu.assertEquals(resource:getName(), "resource_name")
    lu.assertEquals(resource:getAmount(), 0)
    lu.assertEquals(resource:getMaxAmount(), 0)
    lu.assertNil(resource:getResourceInfo()) --Resource doesn't exist!

    resource = class.new("rd/Resource", "energy", 200, 100, self.resourceRegistry)
    lu.assert(resource)
    lu.assertEquals(resource:getName(), "energy")
    lu.assertEquals(resource:getAmount(), 100)
    lu.assertEquals(resource:getMaxAmount(), 200)
    lu.assertNotNil(resource:getResourceInfo()) --Resource does exist
    lu.assertEquals(resource:getDisplayName(), "Energy")

    resource = class.new("rd/Resource", "energy", 200, 300, self.resourceRegistry)
    lu.assert(resource)
    lu.assertEquals(resource:getName(), "energy")
    lu.assertEquals(resource:getAmount(), 200) -- capped @ max amount
    lu.assertEquals(resource:getMaxAmount(), 200)
    lu.assertNotNil(resource:getResourceInfo()) --Resource does exist
    lu.assertEquals(resource:getDisplayName(), "Energy")

    local result = resource:supply(100)

    lu.assertEquals(result, 100) -- couldn't add this amount
    lu.assertEquals(resource:getAmount(), 200) -- capped @ max amount
    lu.assertEquals(resource:getMaxAmount(), 200)

    result = resource:consume(100)
    lu.assertEquals(result, 0) -- couldn't remove this amount
    lu.assertEquals(resource:getAmount(), 100) -- capped @ max amount
    lu.assertEquals(resource:getMaxAmount(), 200)
end

function TestRD:testResourceEntity()
    local ent = class.new("rd/ResourceEntity", 10, self.resourceRegistry)

    lu.assertEquals(ent:getMaxResourceAmount("energy"), 0)
    lu.assertEquals(ent:getResourceAmount("energy"), 0)
    lu.assertEquals(ent:getMaxResourceAmount("water"), 0)
    lu.assertEquals(ent:getResourceAmount("water"), 0)
    lu.assertEquals(ent:getMaxResourceAmount("oxygen"), 0)
    lu.assertEquals(ent:getResourceAmount("oxygen"), 0)

    ent:addResource("energy", 10000)
    ent:addResource("water", 8000, 1000)
    ent:addResource("oxygen", 1000)

    lu.assertEquals(ent:getMaxResourceAmount("energy"), 10000)
    lu.assertEquals(ent:getResourceAmount("energy"), 0)
    lu.assertEquals(ent:getMaxResourceAmount("water"), 8000)
    lu.assertEquals(ent:getResourceAmount("water"), 1000)
    lu.assertEquals(ent:getMaxResourceAmount("oxygen"), 1000)
    lu.assertEquals(ent:getResourceAmount("oxygen"), 0)

    local result = ent:supplyResource("energy", 9000)

    lu.assertEquals(result, 0) -- couldn't add this amount
    lu.assertEquals(ent:getMaxResourceAmount("energy"), 10000)
    lu.assertEquals(ent:getResourceAmount("energy"), 9000)
    lu.assertEquals(ent:getMaxResourceAmount("water"), 8000)
    lu.assertEquals(ent:getResourceAmount("water"), 1000)
    lu.assertEquals(ent:getMaxResourceAmount("oxygen"), 1000)
    lu.assertEquals(ent:getResourceAmount("oxygen"), 0)

    result = ent:consumeResource("energy", 9000)

    lu.assertEquals(result, 0) -- couldn't use this amount
    lu.assertEquals(ent:getMaxResourceAmount("energy"), 10000)
    lu.assertEquals(ent:getResourceAmount("energy"), 0)
    lu.assertEquals(ent:getMaxResourceAmount("water"), 8000)
    lu.assertEquals(ent:getResourceAmount("water"), 1000)
    lu.assertEquals(ent:getMaxResourceAmount("oxygen"), 1000)
    lu.assertEquals(ent:getResourceAmount("oxygen"), 0)

    result = ent:consumeResource("energy", 9000)

    lu.assertEquals(result, 9000) -- couldn't use this amount
    lu.assertEquals(ent:getMaxResourceAmount("energy"), 10000)
    lu.assertEquals(ent:getResourceAmount("energy"), 0)
    lu.assertEquals(ent:getMaxResourceAmount("water"), 8000)
    lu.assertEquals(ent:getResourceAmount("water"), 1000)
    lu.assertEquals(ent:getMaxResourceAmount("oxygen"), 1000)
    lu.assertEquals(ent:getResourceAmount("oxygen"), 0)

    result = ent:supplyResource("energy", 11000)

    lu.assertEquals(result, 1000) -- couldn't add this amount
    lu.assertEquals(ent:getMaxResourceAmount("energy"), 10000)
    lu.assertEquals(ent:getResourceAmount("energy"), 10000)
    lu.assertEquals(ent:getMaxResourceAmount("water"), 8000)
    lu.assertEquals(ent:getResourceAmount("water"), 1000)
    lu.assertEquals(ent:getMaxResourceAmount("oxygen"), 1000)
    lu.assertEquals(ent:getResourceAmount("oxygen"), 0)

end

function TestRD:testNetworks()
    local resourceRegistry = self.resourceRegistry
    local obj = class.new("rd/Resource", "resource_name", 0, 0, resourceRegistry)
    lu.assert(obj)
    lu.assertTrue(obj:isA("Resource"))
    lu.assertEquals(obj:getName(), "resource_name")

    local network1 = class.new("rd/ResourceNetwork", 1, resourceRegistry)
    local network2 = class.new("rd/ResourceNetwork", 2, resourceRegistry)
    local network3 = class.new("rd/ResourceNetwork", 3, resourceRegistry)
    local ent1 = class.new("rd/ResourceEntity", 10, resourceRegistry)
    local ent2 = class.new("rd/ResourceEntity", 11, resourceRegistry)
    local ent3 = class.new("rd/ResourceEntity", 12, resourceRegistry)
    local ent4 = class.new("rd/ResourceEntity", 13, resourceRegistry)
    local ent5 = class.new("rd/ResourceEntity", 14, resourceRegistry)
    local ent6 = class.new("rd/ResourceEntity", 15, resourceRegistry)

    --Test entity 1
    ent1:addResource("energy", 10000)
    ent1:addResource("water", 8000, 1000)
    ent1:addResource("oxygen", 1000)

    lu.assertEquals(ent1:getMaxResourceAmount("energy"), 10000)
    lu.assertEquals(ent1:getResourceAmount("energy"), 0)
    lu.assertEquals(ent1:getMaxResourceAmount("water"), 8000)
    lu.assertEquals(ent1:getResourceAmount("water"), 1000)
    lu.assertEquals(ent1:getMaxResourceAmount("oxygen"), 1000)
    lu.assertEquals(ent1:getResourceAmount("oxygen"), 0)

    -- Test network 1
    lu.assertEquals(network1:getMaxResourceAmount("energy"), 0)
    lu.assertEquals(network1:getResourceAmount("energy"), 0)
    lu.assertEquals(network1:getMaxResourceAmount("water"), 0)
    lu.assertEquals(network1:getResourceAmount("water"), 0)
    lu.assertEquals(network1:getMaxResourceAmount("oxygen"), 0)
    lu.assertEquals(network1:getResourceAmount("oxygen"), 0)

    -- Connect ent1 to network 1

    network1:link(ent1)
    lu.assertEquals(network1:getMaxResourceAmount("energy"), 10000)
    lu.assertEquals(network1:getResourceAmount("energy"), 0)
    lu.assertEquals(network1:getMaxResourceAmount("water"), 8000)
    lu.assertEquals(network1:getResourceAmount("water"), 1000)
    lu.assertEquals(network1:getMaxResourceAmount("oxygen"), 1000)
    lu.assertEquals(network1:getResourceAmount("oxygen"), 0)

    -- Store more energy in ent1

    ent1:addResource("energy", 10000, 2000)
    lu.assertEquals(ent1:getMaxResourceAmount("energy"), 20000)
    lu.assertEquals(ent1:getResourceAmount("energy"), 2000)
    lu.assertEquals(network1:getMaxResourceAmount("energy"), 20000)
    lu.assertEquals(network1:getResourceAmount("energy"), 2000)

    -- Connect entity 3 and 4 to network 1

    network1:link(ent3)
    network1:link(ent4)

    lu.assertEquals(ent3:getMaxResourceAmount("energy"), 20000)
    lu.assertEquals(ent3:getResourceAmount("energy"), 2000)
    lu.assertEquals(ent4:getMaxResourceAmount("energy"), 20000)
    lu.assertEquals(ent4:getResourceAmount("energy"), 2000)

    --Test entity 2 and network2
    ent2:addResource("energy", 10000)
    ent2:addResource("water", 8000, 1000)
    ent2:addResource("oxygen", 1000)

    lu.assertEquals(ent2:getMaxResourceAmount("energy"), 10000)
    lu.assertEquals(ent2:getResourceAmount("energy"), 0)
    lu.assertEquals(ent2:getMaxResourceAmount("water"), 8000)
    lu.assertEquals(ent2:getResourceAmount("water"), 1000)
    lu.assertEquals(ent2:getMaxResourceAmount("oxygen"), 1000)
    lu.assertEquals(ent2:getResourceAmount("oxygen"), 0)

    network2:link(ent2)
    network2:link(ent5)

    lu.assertEquals(network2:getMaxResourceAmount("energy"), 10000)
    lu.assertEquals(network2:getResourceAmount("energy"), 0)
    lu.assertEquals(ent5:getMaxResourceAmount("energy"), 10000)
    lu.assertEquals(ent5:getResourceAmount("energy"), 0)

    -- Connect network 1 and 2
    -- Connect network 2 and 3

    network1:link(network2)
    network2:link(network3)
    network3:link(ent6)

    lu.assertEquals(network1:getMaxResourceAmount("energy"), 30000)
    lu.assertEquals(network1:getResourceAmount("energy"), 2000)

    lu.assertEquals(network2:getMaxResourceAmount("energy"), 30000)
    lu.assertEquals(network2:getResourceAmount("energy"), 2000)

    lu.assertEquals(network2:getMaxResourceAmount("energy"), 30000)
    lu.assertEquals(network2:getResourceAmount("energy"), 2000)

    lu.assertEquals(ent6:getMaxResourceAmount("energy"), 30000)
    lu.assertEquals(ent5:getResourceAmount("energy"), 2000)

    -- Remove some resources

    ent1:removeResource("energy", 5000)

    lu.assertEquals(network1:getMaxResourceAmount("energy"), 25000)
    lu.assertEquals(network1:getResourceAmount("energy"), 2000)

    lu.assertEquals(network2:getMaxResourceAmount("energy"), 25000)
    lu.assertEquals(network2:getResourceAmount("energy"), 2000)

    lu.assertEquals(network2:getMaxResourceAmount("energy"), 25000)
    lu.assertEquals(network2:getResourceAmount("energy"), 2000)

    lu.assertEquals(ent1:getMaxResourceAmount("energy"), 25000)
    lu.assertEquals(ent1:getResourceAmount("energy"), 2000)

    network3:unlink()

    lu.assertEquals(network1:getMaxResourceAmount("energy"), 25000)
    lu.assertEquals(network1:getResourceAmount("energy"), 2000)

    lu.assertEquals(network2:getMaxResourceAmount("energy"), 25000)
    lu.assertEquals(network2:getResourceAmount("energy"), 2000)

    lu.assertEquals(network2:getMaxResourceAmount("energy"), 25000)
    lu.assertEquals(network2:getResourceAmount("energy"), 2000)

    lu.assertEquals(ent1:getMaxResourceAmount("energy"), 25000)
    lu.assertEquals(ent1:getResourceAmount("energy"), 2000)

    lu.assertEquals(ent6:getMaxResourceAmount("energy"), 0)
    lu.assertEquals(ent6:getResourceAmount("energy"), 0)

    lu.assertEquals(network3:getMaxResourceAmount("energy"), 0)
    lu.assertEquals(network3:getResourceAmount("energy"), 0)


end

