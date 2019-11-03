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

local monstermagic = require("monster.base.monstermagic")
local blackImps = require("monster.race_90_black_imp.base")

local magic = monstermagic()

magic.addWarping{probability = 0.05, usage = magic.ONLY_NEAR_ENEMY}

magic.addSummon{probability = 0.055, monsters = {592, 982, 594, 622, 623}} -- Angry chicken, Crazy Chicken, and beetles
magic.addSummon{probability = 0.010, monsters = {981, 983}} -- beetles
magic.addSummon{probability = 0.0001, monsters = {984}} -- bonescraper beetle

local M = blackImps.generateCallbacks()
return magic.addCallbacks(M)