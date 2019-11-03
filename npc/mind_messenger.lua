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

--  INSERT INTO npc (npc_type,npc_posx,npc_posy,npc_posz,npc_faceto,npc_is_healer,npc_name, npc_script,npc_sex,npc_hair,npc_beard,npc_hairred,npc_hairgreen,npc_hairblue,npc_skinred,npc_skingreen,npc_skinblue,npc_hairalpha,npc_skinalpha) VALUES(0,682,316,0,4,FALSE,'Telepath','npc.mind_messenger',1,7,0,238,118,0,245,180,137,255,255);

local baseNPC = require("npc.base.basic")
local condition_item = require("npc.base.condition.item")
--require("npc.base.condition.language")
--require("npc.base.condition.quest")
--require("npc.base.condition.skill")
--require("npc.base.consequence.deleteitem")
local consequence_inform_nls = require("npc.base.consequence.inform_nls")
local consequence_mind_message = require("npc.base.consequence.mind_message")
--require("npc.base.consequence.item")
--require("npc.base.consequence.money")
--require("npc.base.consequence.quest")
--require("npc.base.consequence.skill")
local talkNPC = require("npc.base.talk")
--module("npc.test_pure", package.seeall)

local common = require("base.common")
local globalvar = require("base.globalvar")

local M = {}


local function initNpc()
    local mainNPC = baseNPC();
    mainNPC:setAffiliation(0);
    mainNPC:addLanguage(0);
    mainNPC:addLanguage(1);
    mainNPC:setDefaultLanguage(0);
    mainNPC:setLookat("Dieser NPC ist der Einsiedler Raban.", "This NPC is the hermit Raban.");
    mainNPC:setUseMessage("Fass mich nicht an!", "Do not touch me!");
    mainNPC:setConfusedMessage("#me schaut dich verwirrt an.", "#me looks at you confused.");
    mainNPC:setEquipment(1, 829);
    mainNPC:setEquipment(3, 365);
    mainNPC:setEquipment(11, 2419);
    mainNPC:setEquipment(5, 207);
    mainNPC:setEquipment(6, 0);
    mainNPC:setEquipment(4, 48);
    mainNPC:setEquipment(9, 34);
    mainNPC:setEquipment(10, 369);
    mainNPC:setAutoIntroduceMode(true);
    local talkingNPC = talkNPC(mainNPC);

    talkingNPC:addTalkingEntryNLS(
        {"Hilfe"},
        {"Help"},
        nil,
        nil,
        nil,
        {consequence_inform_nls(
            "[Spielhilfe] Dieser NPC ist der Einsiedler Raban. Schlüsselwörter: Hallo, Quest, Sichel, Kräuter.",
            "[Game Help] This NPC is the hermit Raban. Keywords: Hello, quest, sickle, herbs."
        )}
    )

    talkingNPC:addTalkingEntryNLS(
        {"Grüß", "Gruß"},
        {"Hello", "Greet"},
        nil,
        {
            "Ach ja, wieder eine rastlose Seele. Willkommen in meinem Hain.",
            "Wer ist da! Entschuldigt, ich bin es nicht gewohnt, Besucher zu empfangen."
        },
        {
            "Ah, yes, an unsettled soul. Welcome to my grove.",
            "Who's there? Pardon me, I am not used to visitors.",
            "So, after all these summers, somebody comes here. I hope your intentions are good.",
        },
        nil
    )

    talkingNPC:addTalkingEntryNLS(
        {"FIXGERMAN message"},
        {"message"},
        nil,
        {
            "FIXGERMAN",
        },
        {
            "FIXME",
        },
        {consequence_mind_message(
            "FIXGERMAN", "waits for you at Hemp Necktie inn.", -- messageTailDe, messageTailEn,
            "FIXGERMAN", "The service costs 10 silver coins, no barganing.", -- msgNotEnoughMoneyDe, msgNotEnoughMoneyEn,
            "FIXGERMAN", "Maybe another time then.", -- msgUserCalcelDe, msgUserCalcelEn,
            "FIXGERMAN", "I don't feel anyone that I could contact right now.", -- msgNoRecepientsDe, msgNoRecepientsEn,
            "FIXGERMAN", "This mind was out of my reach, I won't charge you for the attempt.", -- msgContactFailedDe, msgContactFailedEn,
            "FIXGERMAN", "Your message was delivered.", -- msgSuccessDe, msgSuccessEn,
            10 -- costSilver
        )}
    )

    talkingNPC:addCycleText("#me klopft die Erde um einen frisch gepflanzten Setzling glatt.", "#me flattens the soil around a newly planted seedling.");
    talkingNPC:addCycleText("Wachst und gedeiht, meine Kinder.", "Grow and prosper, my children.");
    talkingNPC:addCycleText("#me streicht sachte über die Blätter eines Strauches und seufzt.", "#me gently strokes the leaves of a bush and sighs.");
    talkingNPC:addCycleText("#me flüstert kaum hörbar zu einer Fichte. Man kann sich einbilden, die Äste des Baumes würden antwortend im Wind rauschen.", "#me whispers, barely audibly, to a fir tree. One could imagine the branches of the tree rustling in the wind in response.");
    talkingNPC:addCycleText("Waren wir noch längst nicht geboren, saht ihr auf alles herab. Sind wir längst gegangen, gehört euch das Land erneut.", "When we weren't even born, you could look down and behold it all. When we are long gone, the land will be yours again.");
    talkingNPC:addCycleText("Ich habe etwas gehört.", "I heard something.");
    talkingNPC:addCycleText("Shh! Wenn ihr ganz still seid, könnt ihr dem Klang der Stille lauschen.", "Shh! If you're quiet, you can listen to the sound of silence.");
    talkingNPC:addCycleText("#me schaut sich um und nickt zufrieden.", "#me looks around and nods with satisfaction.");
    talkingNPC:addCycleText("Wer wagt es, meine Ruhe zu stören?", "Who dares to disturb me?");
    talkingNPC:addCycleText("Willkommen in meinem Hain.", "Welcome to my grove.");

    mainNPC:initDone();

    M.mainNPC = mainNPC
end;

initNpc();

function M.receiveText(npcChar, texttype, message, speaker) M.mainNPC:receiveText(npcChar, texttype, speaker, message); end;
function M.nextCycle(npcChar) M.mainNPC:nextCycle(npcChar); end;
function M.lookAtNpc(npcChar, char, mode) M.mainNPC:lookAt(npcChar, char, mode); end;
function M.useNPC(npcChar, char, counter, param) M.mainNPC:use(npcChar, char); end;

return M

