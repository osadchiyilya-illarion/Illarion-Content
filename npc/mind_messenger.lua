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

local common = require("base.common")
local money = require("base.money")
local globalvar = require("base.globalvar")

local M = {}

local init = {}

local saidText = {}

local npcTalk = {
  --{{said},{answersDe},{answersEn}}
    {   {"hello","greet","hail","good day","good morning","good evening","good night","grüß","gruß","guten morgen","guten tag","guten abend","gute nacht","mahlzeit","tach","moin","mohltied","hiho","hallo","hey","greeb"},
        {"Grüßt euch!","Hallo wieder etwas gewachsen?","Hallo, lange nicht gesehen!"},
        {"Be greeted!","Hello my friend!","Hello, I haven't seen you for a while!"} },
    {   {"farewell","bye","fare well","see you","tschüß","tschüss","wiedersehen","gehab wohl","ciao","adieu","au revoir","farebba"},
        {"Auf Wiedersehen!","Man sieht sich!","Passt auf Eure Haare auf!"},
        {"Goodbye!","Goodbye and good luck!","Take care of your hair!"} },
    {   {"how are you","how feel","how do you do","wie geht","wie fühlst","wie ist es ergangen","wie befind"},
        {"Danke und Euch?","Ich kann nicht klagen aber Ihr solltest das.","Mir ging es nie besser."},
        {"Good, thank you, and yourself?","I can't complain, but you should.","Never better than today."} },
    {   {"your name","who are you","who art thou","ihr name","dein name","wer bist du","wer seid ihr","wie heißt"},
        {"Die schnellste Schere Illarions.","Meister der Haarkunst Erza, und Ihr?","Ich bin Erza."},
        {"The fastest scissors in Illarion.","Master of hair art, Erza, and you?","I am Erza."} },
    {   {"besser","better","improve"},
        {"Man kann immer besser aussehen. Man muss nur wollen.","Es gibt immer was abzuschneiden, packen wir es an.","Wer will schon bleiben wie er ist?"},
        {"You can always make yourself look better, if you want.","There is always something to cut. Let's start.","Do you really want to stay as you are?"} },
    {   {"god","gott","gött"},
        {"Wenn ich Euch unter meine Fittiche nehme, lächeln die Götter.","Die Götter werden Euch immer wiedererkennen, bei allen anderen bin ich mir nicht sicher.","Gleich hinter dem Haus findet Ihr Adrons Altar."},
        {"Be assured, as I work on you the gods will smile.","Gods will recognise you, however, I'm not that sure about everybody else.","Right behind the house is an altar to Adron."} },
    {   {"quest","task","mission","auftrag","aufgabe"},
        {"Ich vergebe keine Aufgaben.","Ich hätte eine unentwirrbare Aufgabe, aber die ist fest auf Eurem Kopf.","Nein ich habe für Euch nichts zu tun, außer still sitzen."},
        {"I don't have a quest for you.","There is an inextricable mission, but it is located on your head.","No I don't have a quest for you, but you could keep still."} },
    {   {"zahl","pay","coins","münze"},
        {"Pünktlich zahlen zahlt sich immer aus.","Nichts ist umsonst zu haben."},
        {"Paying on time always pays off.","There is nothing for free."} }
}

local cycleText = {
{"Schnapp, schnipp und ab!", "Snip snip here! Snip snip there! And a couple of tra-la-las!"},
{"#me schaut einen Vorbeigehenden an und ruft: 'Lange nicht mehr geschnitten, oder?'", "#me eyes a passerby and shouts, 'Get a haircut!'"},
{"#me bürstet ihre Schürze aus.", "#me brushes off her apron."},
{"#me pflückt Haare aus dem Kamm.", "#me plucks hairs from her comb."},
{"#me prüft die Schärfe ihrer Schere. ", "#me checks the blade of her scissors."},
{"#me schaut ihr Spiegelbild lächelnd an.", "#me smiles looking at her reflection."},
{"#me starrt auf eine Rasierklinge.", "#me stares at her razor."},
{"#me haucht den Spiegel an und putzt ihn mit dem Ärmel.", "#me exhales on her mirror, producing a damp mist and cleaning it with her sleeve."},
{"Haare schneiden fast im Vorbeigehen.", "Hair one moment. Gone the next!"},
{"Einige Krieger kommen und wollen 'Aim the for the flat-top'. Was immer das sein soll.", "Some warrior once told me, 'Aim the for the flat-top!' Whatever that means."},
{"Zeit Euch zu rasieren!?", "Time for a shave yes?"},
{"Oh Götter, da ist eine tote Ratte auf Eurem Kopf.", "Oh my gods! There's a dead rat on your head!."},
{"Ich schneid dem Nächsten die Kehle durch, der mir mit .. Oh Hallo, braucht Ihr eine Rasur?", "I'll kill the next fella that.. Oh hello there, care for a shave?"}
}

local function initNpc(npc)
    for i, textLine in pairs (npcTalk) do
        for _, said in pairs (textLine[1]) do
            table.insert(saidText, {said, i})
        end
    end
    npc:createAtPos(3, 849, 1) --dress
--    npc:createAtPos(9, 826, 1) --trousers
--    npc:createAtPos(0, 1415, 1) --hat
--    npc:createAtPos(11, 2384, 1) --coat
    npc:createAtPos(10, 369, 1) -- shoes
    init[npc.id] = true
end

--Definitions
local MAX_RECEPIENTS_TO_OFFER = 20
local COST_SILVER = 10

local function start_message(user,npc)
    title = "Choose the recipient"
    infoText = "This will cost you "..COST_SILVER.." silver coins. Whom do you want to send a message to?"

    local onlineChars = world:getPlayersOnline()
    local n = math.min(#onlineChars, MAX_RECEPIENTS_TO_OFFER)
    local charNamesToSuggest = {}
    -- FIXME remove the user himself from the list
    -- permute the list, so that for number of players above MAX_RECEPIENTS_TO_OFFER we see different options
    for i = 1, n do
        local j = math.random(i, n)
        onlineChars[i], onlineChars[j] = onlineChars[j], onlineChars[i]
        charNamesToSuggest[i] = onlineChars[i].name
    end



    local callback = function(dialog)
        if not dialog:getSuccess() then
            return
        else
            local targetName = dialog:getInput()

        end
    end
    local dialog = InputDialog(title, infoText, false, 255, callback)
    User:requestInputDialog(dialog)
end

function M.useNPC(npc, user)
    M.receiveText(npc, nil, "help", user)
end

function M.receiveText(npc, ttype, text, user)
    if not npc:isInRange(user, 2) then
        return
    end

    text = string.lower(text)

    if string.match(text, "hilf") or string.match(text, "help") then
        common.InformNLS(user,"[Hilfe] Dieser NPC ist eine Friseuse. Bitte sie, dir die Haare oder den Bart zu machen. Schlüsselwörter: schneid, rasier, färb, polier, zahlen",
                              "[Help] This NPC is a hair dresser. Ask her to change your hair style (cut), beard style (shave) or hair colour (dye). Keywords: cut, shave, dye, polish, pay")
        return
    end

    if string.match(text, "FIXGERMAN message") or string.match(text, "message" --[[FIXENGLISH]]) then
        start_message(user, npc)
    end


    for i=1,#saidText do
        if string.match(text, saidText[i][1]) then
            local answerId = saidText[i][2]
            local answerDe = npcTalk[answerId][2][math.random(1,#npcTalk[answerId][2])]
            local answerEn = npcTalk[answerId][3][math.random(1,#npcTalk[answerId][3])]
            if not common.IsNilOrEmpty(answerDe) and not common.IsNilOrEmpty(answerEn) then
                common.TalkNLS(npc, Character.say, answerDe, answerEn)
                return
            end
        end
    end
end

function M.nextCycle(npc)
    if math.random(4000) == 1 then
        local textNo = math.random(#cycleText)
        common.TalkNLS(npc,Character.say,cycleText[textNo][1],cycleText[textNo][2])
    end
    if not init[npc.id] then
        initNpc(npc)
    end
end

return M
