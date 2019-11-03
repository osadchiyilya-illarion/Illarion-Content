--[[
Illarion Server

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
details.

You should have received a copy of the GNU Affero General Public License along
with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

local monsterId = 636

local base = require("monster.base.base")
local monstermagic = require("monster.base.monstermagic")
local boneDragons = require("monster.race_63_bone_dragon.base")
local icefield = require("item.id_360_icefield")
local M = boneDragons.generateCallbacks()

local orgOnSpawn = M.onSpawn
function M.onSpawn(monster)
    if orgOnSpawn ~= nil then
        orgOnSpawn(monster)
    end

    base.setColor{monster = monster, target = base.SKIN_COLOR, red = 120, green = 170, blue = 255}
end

local magic = monstermagic()
magic.addIcecone{probability = 0.13, damage = {from = 1500, to = 1800}, range = 6,
    itemProbability = 0.055, quality = {from = 2, to = 3}}
magic.addIcecone{probability = 0.009, damage = {from = 1700, to = 2000}, range = 6,
    itemProbability = 0.025, quality = {from = 3, to = 4}}
magic.addIcecone{probability = 0.001, damage = {from = 1900, to = 2300}, range = 6,
    itemProbability = 0.012, quality = {from = 4, to = 5}}

icefield.setIceImmunity(monsterId)

return magic.addCallbacks(M)