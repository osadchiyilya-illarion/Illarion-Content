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
--[[
Effect to keep track of the arena monster.

lte ID = 18

author: Lillian
]]

local common = require("base.common")
local arena = require("base.arena")


local M = {}

function M.addEffect(arenaEffect, User)
    found, level=arenaEffect:findValue("level");
	found, arena=arenaEffect:findValue("arenaID");
    if not found then
        return false;
    end
	if isValidChar(User) then
		arena.spawnMonster(User, level, arena);
		return true;
	end
end

function M.callEffect(arenaEffect, User)
    if (User:increaseAttrib("hitpoints",0) == 0) then
        common.InformNLS( User,
        "Ihr habt den Kampf verloren. Ihr bekommt keine Punkte.",
        "You lost the fight. You gained no points.");
        return false;
    end

    arenaEffect.nextCalled = 30;

    local found;
    local arena;
	local level;

	found, arena = arenaEffect:findValue("arenaID");
	found, level = arenaEffect:findValue("level");

    if not found then
        return false;      -- no monster
    end

    if arena.checkMonster( User ) then
        common.InformNLS( User,
        "Ihr habt Euren Gegner geschlagen und Punkte verdient.",
        "You defeated your enemy and gained points for it.");
		arena.setArenastats(User, arena, arena.monsterIDsByLevel[level].points);
		local quest = arena.arenaInformation[arena].quest;
		arena.getReward(User, quest)
		local town = arena.arenaInformation[arena].town;
		local arenaListName = "ArenaList"..town;
		local points = User:getQuestProgress(quest);
		base.ranklist.setRanklist(User, arenaListName, points);


		if arena.arenaInformation[arena].newPlayerPos ~= nil then
			User:warp(arena.arenaInformation[arena].newPlayerPos);
		end
        return false;
    end

	if arenaEffect.numberCalled==300 then
        common.InformNLS( User,
        "Ihr habt zulange gebraucht, um das Monster zu besiegen.",
        "It took you too long to defeat the monster.");
        return false;
    end

    return true;
end

function M.removeEffect(arenaEffect, User)
    arena.killMonster( User );
    return false;
end

function M.loadEffect(arenaEffect, User)
    return false;
end

return M
