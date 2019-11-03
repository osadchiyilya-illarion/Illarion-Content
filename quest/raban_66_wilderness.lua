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
-- INSERT INTO "quests" ("qst_id", "qst_script") VALUES (66, 'quest.raban_66_wilderness');

local common = require("base.common")
local M = {}

local GERMAN = Player.german
local ENGLISH = Player.english

-- Insert the quest title here, in both languages
local Title = {}
Title[GERMAN] = "Rabans Hain"
Title[ENGLISH] = "Raban's Grove"

-- Insert an extensive description of each status here, in both languages
-- Make sure that the player knows exactly where to go and what to do
local Description = {}
Description[GERMAN] = {}
Description[ENGLISH] = {}
Description[GERMAN][1] = "Sammel zehn Tannenspr�sslinge und bringe diese Raban. Nimm eine Sichel in die Hand und benutzt sie, w�hrend du vor einer Tanne stehst."
Description[ENGLISH][1] = "Collect ten fir tree sprouts and bring them back to Raban. Use a sickle in your hand while standing in front of a fir tree."
Description[GERMAN][2] = "Geh zu Raban in Rabans Hain. Er hat bestimmt noch eine Aufgabe f�r dich."
Description[ENGLISH][2] = "Go back to Raban in Raban's Grove, he certainly has another task for you."
Description[GERMAN][3] = "Sammel zwanzig Brombeeren und bringe diese Raban. Brombeeren wachsen an B�schen im Wald."
Description[ENGLISH][3] = "Find twenty blackberries and bring them back to Raban. You can collect blackberries from blackberry bushes in the forest."
Description[GERMAN][4] = "Geh zu Raban in Rabans Hain. Er hat bestimmt noch eine Aufgabe f�r dich."
Description[ENGLISH][4] = "Go back to Raban in Raban's Grove, he certainly has another task for you."
Description[GERMAN][5] = "Sammel f�nf Champignons und bringe diese Raban. Nimm eine Sichel in die Hand und benutzt sie, w�hrend du vor einem Pilzkreis stehst."
Description[ENGLISH][5] = "Collect five champignons and bring them back to Raban. Use a sickle in your hand while standing in front of a mushroom circle."
Description[GERMAN][6] = "Geh zu Raban in Rabans Hain. Er hat bestimmt noch eine Aufgabe f�r dich."
Description[ENGLISH][6] = "Go back to Raban in Raban's Grove, he certainly has another task for you."
Description[GERMAN][7] = "Besorge zehn Schaufeln voll groben Sand und bringe sie Raban. Nimm eine Schaufel in die Hand und benutze sie, w�hrend du vor einer Sandgrube stehst."
Description[ENGLISH][7] = "Gather ten piles of coarse sand and bring them to Raban. Use a shovel in your hand while standing in front of a sand pit."
Description[GERMAN][8] = "Du hast alle Aufgaben von Raban erf�llt."
Description[ENGLISH][8] = "You have fulfilled all the tasks for Raban."


-- Insert the position of the quest start here (probably the position of an NPC or item)
local Start = {819, 104, 0}


-- For each status insert a list of positions where the quest will continue, i.e. a new status can be reached there
local QuestTarget = {}
QuestTarget[1] = {position(819, 104, 0), position(822, 103, 0)} -- Tanne
QuestTarget[2] = {position(819, 104, 0)} 
QuestTarget[3] = {position(819, 104, 0), position(813, 100, 0)} -- Hecke
QuestTarget[4] = {position(819, 104, 0)} 
QuestTarget[5] = {position(819, 104, 0), position(812, 102, 0)} -- Pilzkreis
QuestTarget[6] = {position(819, 104, 0)} 
QuestTarget[7] = {position(819, 104, 0), position(352, 678, 0)} -- stone
QuestTarget[8] = {position(819, 104, 0)} 

-- Insert the quest status which is reached at the end of the quest
local FINAL_QUEST_STATUS = 8


function M.QuestTitle(user)
    return common.GetNLS(user, Title[GERMAN], Title[ENGLISH])
end

function M.QuestDescription(user, status)
    local german = Description[GERMAN][status] or ""
    local english = Description[ENGLISH][status] or ""

    return common.GetNLS(user, german, english)
end

function M.QuestStart()
    return Start
end

function M.QuestTargets(user, status)
    return QuestTarget[status]
end

function M.QuestFinalStatus()
    return FINAL_QUEST_STATUS
end

return M
