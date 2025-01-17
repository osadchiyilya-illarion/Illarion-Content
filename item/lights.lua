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
-- script to put lights on and off
-- off items: save old wear value in data (+1000)
--                if data is <1000, set to default wear or keep current (if there's no requirement, e.g. for a torch)
-- on items: save old wear value in data (+500)
--                if data is <500, set wear to 255 or default portable wear

local common = require("base.common")
local lookat = require("base.lookat")
local tutorial = require("content.tutorial")

local M = {}

-- UPDATE items SET itm_script='item.lights' WHERE itm_id IN (92, 397, 393, 394, 2856, 2855, 391, 392, 401, 402, 403, 404, 2851, 2852, 2853, 2854, 399, 400, 395, 396);

local PORTABLE_WEAR = 10 -- default wear value for portable items, when put off
local DEFAULT_WEAR = 10 -- default wear value for light sources, when put on

local LightsOff = {}
local LightsOn = {}
-- torch
LightsOff[391] = { on = 392 }
LightsOn[392] = { off = 391, portable = true }
-- torch holder
LightsOff[401] = { on = 402, req = { id = 392, num = 1 } } -- facing south
LightsOn[402] = { off = 401, back = 392 }
LightsOff[403] = { on = 404, req = { id = 392, num = 1 } } -- facing west
LightsOn[404] = { off = 403, back = 392 }
-- candles
LightsOff[2853] = { on = 2851, req = { id = 43, num = 3 } } -- facing south
LightsOn[2851] = { off = 2853 }
LightsOff[2854] = { on = 2852, req = { id = 43, num = 3 } } -- facing west
LightsOn[2852] = { off = 2854 }
-- candle
LightsOff[399] = { on = 400, req = { id = 43, num = 1 } }
LightsOn[400] = { off = 399, portable = true }
-- oil lamp
LightsOff[92] = { on = 397, req = { id = 469, num = 1, remnant = 390} }
LightsOn[397] = { off = 92, portable = true }
-- oil lamp holder
LightsOff[395] = { on = 396, req = { id = 469, num = 1, remnant = 390 } }
LightsOn[396] = { off = 395 }
-- lantern
LightsOff[393] = { on = 394, req = { id = 43, num = 1 } } -- black, portable
LightsOn[394] = { off = 393, portable = true }
LightsOff[2856] = { on = 2855, req = { id = 43, num = 1 } } -- grey, static
LightsOn[2855] = { off = 2856 }

local ReqTexts = {}
ReqTexts.german = { [392] = "Fackeln", [43] = "Kerzen", [469] = "Lampen�l" }
ReqTexts.english = { [392] = "torches", [43] = "candles", [469] = "lamp oil" }

local checkReq
local putOn
local getLightData
local setLightData

function M.UseItem(User, SourceItem, ltstate)
    if SourceItem.id == Item.torch and SourceItem:getType() ~= scriptItem.inventory then
        common.InformNLS(User,
            "Nimm die Lichtquelle in die Hand.",
            "Take the light source into your hand.")
        return
    end
    if SourceItem:getType() == scriptItem.container then
        common.InformNLS(User,
            "Nimm die Lichtquelle in die Hand oder lege sie am G�rtel ab.",
            "Take the light source into your hand or put it on your belt.")
        return
    end

    if SourceItem.number > 1 then
        User:inform("Du kannst immer nur eine Lichtquelle auf einmal anz�nden. Um einen Stapel aufzuteilen, halte die Umschalttaste, w�hrend du den Stapel auf ein freies Inventarfeld ziehst.",
                    "You can only light up one light source at once. To split a stack, hold shift while dragging the item stack to a free inventory slot.")
        return
    end

    local this = LightsOff[SourceItem.id]
    if this then
        local ok, wear = checkReq(User,SourceItem,this)
        if ok then
            --Noobia Quest 330: Lighting a torch with NPC Henry Cunnigan
            if User:getQuestProgress(330) == 2 and SourceItem.id == 391 and User:isInRangeToPosition((position (703,290,0)),20) then -- Only invoked if the user has the quest, has a torch and is in range of the NPC
                User:setQuestProgress(330,3) -- Quest advanced when torch lit
                common.InformNLS(User, tutorial.getTutorialInformDE("lights"), tutorial.getTutorialInformEN("lights"))
                local Henry = common.getNpc(position(703,290,0),1,"Henry Cunnigan")
                common.TalkNLS(Henry, Character.say, tutorial.getTutorialTalkDE("lights"), tutorial.getTutorialTalkEN("lights"))
            end
            --Noobia end

            --Quest 105: NPC Gregor Remethar "A light at the end of the tunnel"
            if SourceItem.id == 395 and (SourceItem.pos == position (873, 796, -3) or SourceItem.pos == position (873, 798, -3) ) and User:getQuestProgress(105) == 1 then
                common.InformNLS(User, "[Queststatus] Du entfachst die Ehrenfeuer von Runewick. Kehre zu Gregor Remethar zur�ck, um deine Belohnung einzufordern.", "[Quest status] You lit the lights of honour of Runewick. Return to Gregor Remethar to claim your reward.")
                User:setQuestProgress(105,2)
                putOn(SourceItem,math.random(20,60),false) --these lights burn quite long
            else
            --Quest end, default below
                putOn(SourceItem,wear,false)
            end

        elseif this.req then
            common.InformNLS(User,
                "Daf�r brauchst du ".. ReqTexts.german[this.req.id] .. " in der Hand oder im G�rtel.",
                "You need ".. ReqTexts.english[this.req.id] .. " in your belt or hands to do that.")
        end
    elseif LightsOn[SourceItem.id] then
        common.InformNLS(User,"Du verbrennst dir die Finger beim Versuch, das Feuer zu ersticken.","You burn your fingers while trying to extinguish the flames.")
    end
end

function checkReq(User, Item, this)
    local wear = -1
    if getLightData(Item)>=1000 then
        -- item has already been used and old wear is saved in data
        wear = getLightData(Item)-1000

    elseif this.req then
        -- there's a requirement, check on body and belt
        if ( User:countItemAt("body", this.req.id) + User:countItemAt("belt", this.req.id) >= this.req.num ) then
            wear = 0
            local myItem
            local itemRest = this.req.num
            for i=1,17 do
                myItem = User:getItemAt( i )
                if ( myItem.id == this.req.id ) then
                    wear = wear + myItem.wear -- save wear for torches
                    world:erase( myItem, math.min( itemRest, myItem.number ) )
                    itemRest = itemRest - math.min( itemRest, myItem.number )
                    if itemRest == 0 then
                        break
                    end
                end
            end
            if this.req.remnant then
                common.CreateItem(User, this.req.remnant, this.req.num, 333, nil)
            end
            if this.req.id~=392 then
                -- use default wear for all non-torch-requirements
                wear = DEFAULT_WEAR
            end
        end
    else
        -- no requirement
        wear = Item.wear
    end
    return (wear>=0), wear
end

function putOn(Item, newWear, noBack)

    if noBack then
        setLightData(Item, 2) -- give nothing back
    else
        setLightData(Item, newWear + 500) -- save old wear value
    end
    Item.id = LightsOff[Item.id].on
    Item.wear = newWear
    world:changeItem(Item)
end

function M.MoveItemAfterMove(User,SourceItem,TargetItem)

    -- Quest 305: we burn a tobacco plantation
    if User:getQuestProgress(305) == 2 then
        if (TargetItem.pos.x >= 3) and (TargetItem.pos.x <= 6) and (TargetItem.pos.y >= 565) and (TargetItem.pos.y <= 571) and (TargetItem.pos.z <= 0) then
            if LightsOn[SourceItem.id] then
                local spawnFire = function(posi)
                    world:createItemFromId(359,1,posi,true,333,nil)
                end
                world:makeSound(7,position(5,568,0))
                world:createItemFromId(359,1,position(5,568,0),true,333,nil)
                common.CreateCircle(position(5,568,0), 1, spawnFire)
                common.CreateCircle(position(5,568,0), 2, spawnFire)
                User:setQuestProgress(305,3)
                User:inform("Du hast das Tabakfeld zerst�rt. Gut gemacht. Spreche nun mit Tobis Vunu.","You destroyed the tobacco field. Well done. Talk to Tobis Vunu now.")
            else
                User:inform("Du kannst das Feld vermutlich mit brennenden Dingen besser abfackeln.","It's much easier to burn down a field if you are using fire.")
            end
        end
    end

    --Noobia Quest 330: Equipping a torch with NPC Henry Cunnigan
    if User:getQuestProgress(330)==1 and TargetItem.id==391 and User:isInRangeToPosition((position (703,290,0)),20) and TargetItem:getType() == 4 then -- Only invoked if the user has the quest, has a torch and is in range of the NPC
        User:setQuestProgress(330,2) --Quest advancement when torch equipped
        local NPCList=world:getNPCSInRangeOf(position(703,290,0),1) --Let's be tolerant, the NPC might move a tile.
        common.InformNLS(User, tutorial.getTutorialInformDE("lightsStart"), tutorial.getTutorialInformEN("lightsStart"))
        for i, Henry in pairs(NPCList) do
            common.TalkNLS(Henry, Character.say, tutorial.getTutorialTalkDE("lightsStart"), tutorial.getTutorialTalkEN("lightsStart"))
        end
    end
    --Noobia end

    return true --leave safely
end

function M.LookAtItem(User, Item)

    if(LightsOn[Item.id]) then
        local TimeLeftI = Item.wear
        if(TimeLeftI == 255) then
            lookat.SetSpecialDescription(Item, "Sie wird nie ausbrennen.", "It will never burn down.")
        elseif (TimeLeftI == 0) then
            lookat.SetSpecialDescription(Item, "Sie wird sofort ausbrennen.", "It will burn down immediately.")
        elseif (TimeLeftI == 1) then
            lookat.SetSpecialDescription(Item, "Sie wird demn�chst ausbrennen.", "It will burn down anytime soon.")
        elseif (TimeLeftI == 2) then
            lookat.SetSpecialDescription(Item, "Sie wird bald ausbrennen.", "It will burn down soon.")
        elseif (TimeLeftI <= 4) then
            lookat.SetSpecialDescription(Item, "Sie wird nach einer Weile ausbrennen.", "It will burn down in a while.")
        elseif (TimeLeftI <= PORTABLE_WEAR) then
            lookat.SetSpecialDescription(Item, "Sie wird nicht allzu bald ausbrennen.", "It will not burn down anytime soon.")
        elseif (TimeLeftI > PORTABLE_WEAR) then
            lookat.SetSpecialDescription(Item, "Sie wird nach langer Zeit ausbrennen.", "It will burn down in a long time.")
        end
    elseif (LightsOff[Item.id]) then
        lookat.SetSpecialDescription(Item, "Sie ist nicht angez�ndet.", "It is not lit, yet.")
    end

    return lookat.GenerateLookAt(User, Item, lookat.NONE)
end

-- dirty quick fix for old data
function getLightData(Item)
  local str = Item:getData("lightData")
  if (str == "") then
    setLightData(Item, 0)
    return 0
  end
  return tonumber(str)
end

function setLightData(Item, Num)
  Item:setData("lightData", "" .. Num)
end

return M
