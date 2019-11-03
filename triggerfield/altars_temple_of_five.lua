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
-- Quest: A spark to a flame (113)/(114)
-- For triggerfield sql see triggerfield/altars.lua
local common = require("base.common")
local tgf_altars = require("triggerfield.altars")

local M = {}

local altar = {} --a list with positions
altar[1] = position(551,133,0) --1: Ushara Goddess of earth
altar[2] = position(551,143,0) --2: Br�gon God of fire
altar[3] = position(556,141,0) --3: Eldan God of spirit
altar[4] = position(549,138,0) --4: Tanora/Zelphia Goddess of water
altar[5] = position(556,135,0) --5: Findari Goddess of air

local messageG = {}
messageG[1] = "[Queststatus] Du n�herst dich dem Altar Usharas. Eine beruhigende Stille umgibt dich."
messageG[2] = "[Queststatus] Du n�herst dich dem Altar Br�gons. Hitze schl�gt dir ins Gesicht."
messageG[3] = "[Queststatus] Du n�herst dich dem Altar Eldans. Nachdenklich betrachtest du den Schrein."
messageG[4] = "[Queststatus] Du n�herst dich dem Altar Tanoras. T�uscht du dich oder liegt hier Nebel in der Luft?"
messageG[5] = "[Queststatus] Du n�herst dich dem Altar Findaris. Eine Winb�e streift durch deine Kleidung."

local messageE = {}
messageE[1] = "[Quest status] You approach the altar of Ushara - the silence is comforting."
messageE[2] = "[Quest status] You approach the altar of Br�gon as a wave of heat engulfs you."
messageE[3] = "[Quest status] You approach the altar of Eldan, and you are overwhelmed by thoughtful contemplation."
messageE[4] = "[Quest status] You approach the altar of Tanora shrouded in a dense fog."
messageE[5] = "[Quest status] You approach the altar of Findari and swirling gusts of wind billow around you."

function M.MoveToField(User)
    if (User:getQuestProgress(113) == 1) then --OK, the player does the quest
        local queststatus = User:getQuestProgress(114) --here, we save which fields were visited
        local queststatuslist = {}
        queststatuslist = common.Split_number(queststatus, 5) --reading the digits of the queststatus as table

        for i = 1, 5 do
            if User:isInRangeToPosition(altar[i], 1) and queststatuslist[i] == 0 then
                queststatuslist[i] = 1 --found it!
                common.InformNLS(User, messageG[i], messageE[i])
                User:setQuestProgress(114, queststatuslist[1] * 10000 + queststatuslist[2] * 1000 + queststatuslist[3] * 100 + queststatuslist[4] * 10 + queststatuslist[5] * 1) --saving the new queststatus
                queststatus = User:getQuestProgress(114) --and reading it again
                if queststatus==11111 then --found all altars
                    User:setQuestProgress(113, 2) --Quest solved!
                    common.InformNLS(User, "[Queststatus] Du hast nun alle Altare der F�nf besucht.", "[Quest status] You have visited all the altars of the Five.")
                    return --more than solving isn't possible, bailing out
                end
            end
        end
    end
end


function M.PutItemOnField(Item, User)
    -- for sacrifice use regular triggerfield script
    return tgf_altars.PutItemOnField(Item, User)
end


return M
