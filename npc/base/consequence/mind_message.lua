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
local class = require("base.class")
local consequence = require("npc.base.consequence.consequence")
local money = require("base.money")
local common = require("base.common")

local _mind_message_helper

local mind_message = class(consequence,
function(
    self,
    messageTailDe, messageTailEn,
    msgNotEnoughMoneyDe, msgNotEnoughMoneyEn,
    msgUserCalcelDe, msgUserCalcelEn,
    msgNoRecepientsDe, msgNoRecepientsEn,
    msgContactFailedDe, msgContactFailedEn,
    msgSuccessDe, msgSuccessEn,
    costSilver)

    consequence:init(self)

    self["_messageTailDe"] = messageTailDe
    self["_messageTailEn"] = messageTailEn
    self["_msgNotEnoughMoneyDe"] = msgNotEnoughMoneyDe
    self["_msgNotEnoughMoneyEn"] = msgNotEnoughMoneyEn
    self["_msgUserCalcelDe"] = msgUserCalcelDe
    self["_msgUserCalcelEn"] = msgUserCalcelEn
    self["_msgNoRecepientsDe"] = msgNoRecepientsDe
    self["_msgNoRecepientsEn"] = msgNoRecepientsEn
    self["_msgContactFailedDe"] = msgContactFailedDe
    self["_msgContactFailedEn"] = msgContactFailedEn
    self["_msgSuccessDe"] = msgSuccessDe
    self["_msgSuccessEn"] = msgSuccessEn
    self["_costSilver"] = costSilver

    self["perform"] = _mind_message_helper
end)

local MAX_RECEPIENTS_TO_OFFER = 10

function mind_message:start_message(sender, messenger)

    local onlineChars = world:getPlayersOnline()
    if #onlineChars == 1 then
        messenger:talk(Character.say, self._msgNoRecepientsDe, self._msgNoRecepientsEn)
        return
    end

    if not money.CharHasMoney(sender, money.CoinsToMoney(0, self._costSilver, 0)) then
        messenger:talk(Character.say, self._msgNotEnoughMoneyDe, self._msgNotEnoughMoneyEn)
        return
    end

    -- remove the sender himself from the list
    for i = 1, #onlineChars do
        if onlineChars[i].id == sender.id then
            table.remove(onlineChars, i)
            break
        end
    end

    local n = math.min(#onlineChars, MAX_RECEPIENTS_TO_OFFER)
    -- permute the list, so that for number of players above MAX_RECEPIENTS_TO_OFFER we see different options
    for i = 1, n do
        local j = math.random(i, n)
        onlineChars[i], onlineChars[j] = onlineChars[j], onlineChars[i]
    end

    local title = common.getNLS(sender, "FIXGERMAN", "Mind message")
    local infoText = common.getNLS(sender, "FIXGERMAN", "Choose recepient")
    local dialogOptions = {}
    for i = 1, n do
        table.insert(dialogOptions,
            {text = onlineChars[i].name, func = self:requireSignature, args = { sender, onlineChars[i], messenger } }
        )
    end
    local onclose = {func = messenger:talk, self._msgUserCalcelDe, self._msgUserCalcelEn}

    common.selectionDialogWrapper(sender, title, infoText, dialogOptions, onclose)

end

function mind_message:requireSignature(sender, recepient, messenger)

    local signatureDialog = function (dialog)
        if (not dialog:getSuccess()) then
            messenger:talk(Character.say, self._msgUserCalcelDe, self._msgUserCalcelEn)
            return
        end
        local senderSignature = dialog:getInput()
        if senderSignature == "" then
            senderSignature = common.getNLS(recepient, "FIXGERMAN", "Someone")
        end

        self:deliver_message(sender, recepient, messenger, senderSignature)
    end

    local title = common.getNLS(sender, "FIXGERMAN", "Mind message")
    local infoText = common.getNLS(sender, "FIXGERMAN", "Your name in the message")
    local signatureDiaog = InputDialog(title, infoText, false, 255, signatureDialog)
    User:requestInputDialog(signatureDiaog)
end

function mind_message:deliver_message(sender, recepient, messenger, senderSignature)
    local cost = money.CoinsToMoney(0, self._costSilver, 0)
    if not money.CharHasMoney(sender, cost) then
        messenger:talk(Character.say, self._msgNotEnoughMoneyDe, self._msgNotEnoughMoneyEn)
        return
    end

    if not isValidChar(recepient) then
        messenger:talk(Character.say, self._msgContactFailedDe, self._msgContactFailedEn)
        return
    end

    common.informNLS(recepient, senderSignature.." "..self._messageTailDe, senderSignature.." "..self._messageTailEn)

    money.TakeMoneyFromChar(sender, cost)

    messenger:talk(Character.say, self._msgSuccessDe, self._msgSuccessEn)
end


function _mind_message_helper(self, npcChar, player)
    self:start_message(player, npcChar)
end

return mind_message