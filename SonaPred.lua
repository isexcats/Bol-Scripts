

if myHero.charName ~= "Sona" then return end

local _ScriptName = "SonaPred"
local Version = 1.0
local _ScriptAuthor = "Isexcats"

local AutoUpdate = false
local SrcLibURL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SrcLibPath = LIB_PATH .. "SourceLib.lua"
local SrcLibDownload = false

local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "isexcats/Bol-Scripts/master/SonaPred.lua"

local orbwalker = "SOW"

function SendMessage(msg)

    PrintChat("<font color='#7D1935'><b>[" .. _ScriptName .. " " .. myHero.charName .. "]</b> </font><font color='#FFFFFF'>" .. tostring(msg) .. "</font>")

end

if FileExist(SrcLibPath) then

    require "SourceLib"
    SrcLibDownload = false

else

    SrcLibDownload = true
    DownloadFile(SrcLibURL, SrcLibPath, function() SendMessage("Downloaded SourceLib, please reload. (Double F9)") end)

end

if SrcLibDownload == true then

    SendMessage("SourceLib was not found. Downloading...")
    return

end

if AUTOUPDATE then
    SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/isexcats/Bol-Scripts/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/isexcats/BolScripts/master/VersionFiles/"..SCRIPT_NAME..".version"):CheckUpdate()
end

local libs = Require(_ScriptName .. " Libs")
libs:Add("VPrediction", "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua")
libs:Add("SOW", "https://raw.githubusercontent.com/Hellsing/BoL/master/common/SOW.lua")
if VIP_USER then libs:Add("Prodiction", "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/ec830facccefb3b52212dba5696c08697c3c2854/Test/Prodiction/Prodiction.lua") end

libs:Check()

if libs.downloadNeeded == true then return end

local Recalling

function OnLoad()

    __initVars()
    __load()
    __initLibs()
    __initMenu()
    __initPriorities()
    __initOrbwalkers()

end

function OnTick()

    if not _G.SonaPred_Loaded then return end

    __modes()
    __update()

end 

function OnUnload()

    if not _G.SonaPred_Loaded then return end

end

function OnDraw()

    if not _G.SonaPred_Loaded then return end

    __draw()

end

function OnProcessSpell(unit, spell)

    if not _G.SonaPred_Loaded then return end

end

function OnCreateObj(obj)

    if not _G.SonaPred_Loaded then return end

end

function OnDeleteObj(obj)

    if not _G.SonaPred_Loaded then return end

end

-- INITIALIZE GLOBAL VARIABLES --
function __initVars()

    -- SCRIPT GLOBALS
    _G.SonaPred_Loaded = false
    

    SKILLSHOT_LINEAR, SKILLSHOT_CONE, SKILLSHOT_CIRCULAR, ENEMY_TARGETED, SELF_TARGETED, MULTI_TARGETED, UNIDENTIFIED = 0, 1, 2, 3, 4, 5, -1

local Ranges = { AA = 550 }
    -- TABLE OF HERO SKILLS
    SpellTable = {
    
        [_Q] = {

            id = "q",
            name = myHero:GetSpellData(_Q).name,
            ready = false,
            range = 800,
            width = nil,
            speed = nil,
            delay = nil,
            sType = UNIDENTIFIED
        },


       [_W] = {

            id = "w",
            name = myHero:GetSpellData(_E).name,
            ready = false,
            range = 1000,
            width = nil,
            speed = nil,
            delay = nil,
            sType = UNIDENTIFIED

        },


        [_E] = {

            id = "e",
            name = myHero:GetSpellData(_E).name,
            ready = false,
            range = 360,
            width = 25,
            speed = nil,
            delay = nil,
            sType = UNIDENTIFIED

        },

       [_R] = {

            id = "r",
            name = myHero:GetSpellData(_R).name,
            ready = false,
            range = 980,
            width = 140,
            speed = 2400,
            delay = .5,
            sType = SKILLSHOT_LINEAR

        }


    }

  

    -- TABLE FOR ARRANGING TARGETING PRIORITIES
    PriorityTable = {
        AP = {
            "Annie", "Ahri", "Akali", "Anivia", "Annie", "Azir", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
            "Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
            "Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "Velkoz"
        },

        Support = {
            "Alistar", "Blitzcrank", "Braum", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Sona", "Taric", "Thresh", "Zilean", "Braum"
        },

        Tank = {
            "Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
            "Warwick", "Yorick", "Zac"
        },

        AD_Carry = {
            "Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
            "Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo", "Zed"
        },

        Bruiser = {
            "Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
            "Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao"
        }
    }

end

-- LOAD SEQUENCE -- SCRIPT LOADUP - SEND START MESSAGES AND ARRANGE GLOBALS
function __load()

    SendMessage("SonaPred by Isexcats")
    SendMessage("Script version v" .. Version .. " loaded for " .. myHero.charName)

   

end

-- LIBRARY INITIALIZATION --
function __initLibs()

    VP = VPrediction()
    SOWi = SOW(VP)
    PROD = Prodiction

    enemyMinions = minionManager(MINION_ENEMY, GetMaxRange(), myHero, MINION_SORT_HEALTH_ASC) -- MINION MANAGER FOR LANE CLEAR

end

function __initMenu()

    Menu = scriptConfig("[" .. _ScriptName .. "] " .. myHero.charName, "SonaPred"..myHero.charName)

    Menu:addSubMenu("[" .. myHero.charName.. "] Keybindings", "keys")
        Menu.keys:addParam("carry", "Carry Mode Key:", SCRIPT_PARAM_ONKEYDOWN, false, 32)
        Menu.keys:addParam("harass", "Harass Mode Key:", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))
        Menu.keys:addParam("farm", "Lane Clear Mode Key:", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('V'))


    Menu:addSubMenu("[" .. myHero.charName.. "] Combo", "combo")
        Menu.combo:addParam("useQ", "Enable Q (".. SpellTable[_Q].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.combo:addParam("useE", "Enable E (".. SpellTable[_E].name ..")", SCRIPT_PARAM_ONOFF, true)
				      Menu.combo:addParam("useR", "Enable R (".. SpellTable[_E].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.combo:addParam("autoR", "Automatically use R on X targets (".. SpellTable[_R].name ..")", SCRIPT_PARAM_ONOFF, true)
        Menu.combo:addParam("mana", "Min Mana For Combo", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
        Menu.combo:addParam("minR", "Only use R if it will hit X targets", SCRIPT_PARAM_SLICE, 1, 1, 4, 0)
        Menu.combo:addParam("autoMinR", "automatically use E on R targets", SCRIPT_PARAM_SLICE, 2, 2, 5, 0)

    Menu:addSubMenu("[" .. myHero.charName.. "] Harass", "harass")
        Menu.harass:addParam("useQ", "Enable Q (".. SpellTable[_Q].name ..")", SCRIPT_PARAM_ONOFF, true)
     
        Menu.harass:addParam("mana", "Min Mana For Harass", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)

    
      Menu:addSubMenu("[" .. myHero.charName.. "] Heal", "heal")        
        Menu.heal:addParam("UseHeal", "Auto Heal Allies", SCRIPT_PARAM_ONOFF, true)
        Menu.heal:addParam("HealManager", "Heal allies under", SCRIPT_PARAM_SLICE, 65, 0, 100, 0)

            


 

    Menu:addSubMenu("[" .. myHero.charName.. "] Orbwalk", "orbwalk")
        SOWi:LoadToMenu(Menu.orbwalk)

    Menu:addSubMenu("[" .. myHero.charName .. "] Prediction", "prediction")
        if VIP_USER then
            Menu.prediction:addParam("type", "Prediction:", SCRIPT_PARAM_LIST, 1, {"Prodiction", "VPrediction"})
        else
            Menu.prediction:addParam("type", "Prediction:", SCRIPT_PARAM_INFO, "VPrediction")
        end
        Menu.prediction:addParam("", "", SCRIPT_PARAM_INFO, "")

        for index, skill in pairs(SpellTable) do
            if (skill.sType == SKILLSHOT_LINEAR) or (skill.sType == SKILLSHOT_CONE) or (skill.sType == SKILLSHOT_CIRCULAR) then
                Menu.prediction:addParam(skill.id, string.upper(skill.id) .. " hit chance", SCRIPT_PARAM_SLICE, 2, 1, 3, 0)
            end
        end

  
    Menu:addSubMenu("[" .. myHero.charName.. "] Draw", "draw")
        Menu.draw:addParam("enabled", "Enable All Drawings", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawAA", "Draw AutoAttack Range", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawQ", "Draw ".. SpellTable[_Q].name .." Range", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawW", "Draw ".. SpellTable[_W].name .." Range", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawE", "Draw ".. SpellTable[_E].name .." Range", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("drawTarget", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)
        Menu.draw:addParam("lfc", "Use Lag Free Circles", SCRIPT_PARAM_ONOFF, true)

    Menu:addSubMenu("[" .. myHero.charName.. "] Misc", "misc")
        if VIP_USER then
            Menu.misc:addParam("packet", "Use Packets to Cast Spells", SCRIPT_PARAM_ONOFF, false)
        end
        
    
    TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1250, DAMAGE_MAGIC, true)
    TargetSelector.name = "Swag"
    Menu:addTS(TargetSelector)

end


 --DETECT AND INITIALIZE ORBWALKERS -- USES SIMPLE ORBWALKER IF NONE FOUND
function __initOrbwalkers()

    if _G.Reborn_Loaded then -- SIDA'S AUTO CARRY REBORN LOADED - DISABLE SOW

        SendMessage("SAC:R Detected. Disabling SOW.")
        orbwalker = "SAC"
        Menu.orbwalk.Enabled = false

    elseif _G.MMA_Loaded then -- MARKSMAN'S MIGHTY ASSISTANT LOADED - DISABLE SOW

        SendMessage("MMA Detected. Disabling SOW.")
        orbwalker = "MMA"
        Menu.orbwalk.Enabled = false

    elseif _G.SxOrbMenu then -- SXORBWALK LOADED - DISABLE SOW

        SendMessage("SxOrbwalk Detected. Disabling SOW.")
        orbwalker = "SxOrb"
        Menu.orbwalk.Enabled = false

    end

    if not _G.SonaPred_Loaded then _G.SonaPred_Loaded = true end

end

-- ACTIVATE MODES
function __modes()

    carryKey    = Menu.keys.carry
    harassKey   = Menu.keys.harass
    farmKey     = Menu.keys.farm

    if carryKey     then Combo(Target)  end -- ACTIVATE CARRY MODE
    if harassKey    then Harass(Target) end -- ACTIVATE MIXED MODE
    if farmKey      then Farm()         end -- ACTIVATE CLEAR MODE


    
end

-- TICK UPDATE --
function __update() -- UPDATE VARIABLES ON TICK
if Menu.heal.UseHeal then --ENABLE AUTO HEAL
            AutoHeal()
						
        end

    if Menu.combo.autoR then
        AutoR()
				
    end

    -- SKILLS -- CHECK IF SPELLS ARE READY
    for i in pairs(SpellTable) do
        SpellTable[i].ready = myHero:CanUseSpell(i) == READY
    end
    -- SKILLS --

    

    TargetSelector:update() -- UPDATE TARGETS IN RANGE
    Target = GetTarget() -- GET DESIRED TARGET IN GLOBAL

end


-- SCRIPT FUNCTIONS --

function Combo(target) -- CARRY MODE BEHAVIOUS

    if ValidTarget(target) and target ~= nil and target.type == myHero.type then

        if myManaPct() >= Menu.combo.mana and Menu.combo.useQ then CastQ()  end
        if myManaPct() >= Menu.combo.mana and Menu.combo.useE then CastE() end
         if myManaPct() >= Menu.combo.mana and Menu.combo.useR then CastR(target, Menu.prediction.r) end
        

    end

end

function Harass(target) -- HARASS MODE BEHAVIOUR

    if ValidTarget(target) and target ~= nil and target.type == myHero.type and (myManaPct() >= Menu.harass.mana) then

        if Menu.harass.useQ then CastQ() end

    end

end

function Farm() -- LANE CLEAR

    enemyMinions:update()

   

end

-- SKILL FUNCTIONS --
function CastQ(target) -- CAST W SKILL

   if  myHero:CanUseSpell(_Q) == READY then
                for i=1, heroManager.iCount do
                        local enemy = heroManager:GetHero(i)
                        if enemy.team ~= myHero.team and enemy.visible and enemy.dead == false and myHero:GetDistance(enemy) < SpellTable[_Q].range then
												 if Menu.misc.packet then
                            Packet("S_CAST", {spellId = _Q}):send()
                            return
                        end
                            if not Menu.misc.packet then
                            CastSpell(_Q)
                            return
                        end
                        end
                end
        end
end

function CastE(target, chance) -- CAST W SKILL

    for i, ally in ipairs(GetAllyHeroes()) do
            if SpellTable[_E].ready and Menu.Combo.useE then
                    if GetDistance(ally, myHero) <= SpellTable[_E].range then
                        if Menu.misc.packet then
                            Packet("S_CAST", {spellId = _E}):send()
                            return
                        end

                        if not Menu.misc.packet then
                            CastSpell(_E)
                        end
                    end
                
            end
        end

end

function CastR(target, chance) -- CAST W SKILL
SendMessage("combo")
    chance = chance or 2

    local n = 0

    if target ~= nil and ValidTarget(target) and GetDistance(target) <= SpellTable[_R].range and SpellTable[_R].ready then

        local aoeCastPos, hitChance, castInfo, nTargets
        if VIP_USER and Menu.prediction.type and Menu.prediction.type == 1 then
            aoeCastPos, castInfo = Prodiction.GetLineAOEPrediction(target, SpellTable[_R].range, SpellTable[_R].speed, SpellTable[_R].delay, SpellTable[_R].width, myHero)
            hitChance = tonumber(castInfo.hitchance)
        else
            aoeCastPos, hitChance, nTargets = VP:GetLineAOECastPosition(target, SpellTable[_R].delay, SpellTable[_R].width, SpellTable[_R].range, SpellTable[_R].speed, myHero)
        end

      if GetMode() == 1 then
            n = Menu.combo.minR
        else
            n = Menu.harass.minR
        end


        if GetEnemyCountInPos(aoeCastPos, SpellTable[_R].range) >= n then
            if VIP_USER and Menu.misc.packet then

                local packet = GenericSpellPacket(_R, aoeCastPos.x, aoeCastPos.z)
                Packet("S_CAST", packet):send()

            else

                CastSpell(_R, aoeCastPos.x, aoeCastPos.z)

            end
        end

    end

end


function AutoR(target) -- CAST E Automatically

 if target ~= nil and ValidTarget(target) and GetDistance(target) <= SpellTable[_R].range and SpellTable[_R].ready then

local aoeCastPos, hitChance, castInfo, nTargets
        if VIP_USER and Menu.prediction.type and Menu.prediction.type == 1 then
            aoeCastPos, castInfo = Prodiction.GetLineAOEPrediction(target, SpellTable[_R].range, SpellTable[_R].speed, SpellTable[_R].delay, SpellTable[_R].width, myHero)
            hitChance = tonumber(castInfo.hitchance)
        else
            aoeCastPos, hitChance, nTargets = VP:GetLineAOECastPosition(target, SpellTable[_R].delay, SpellTable[_R].width, SpellTable[_R].range, SpellTable[_R].speed, myHero)
        end
end
if CountEnemyHeroInRange(SpellTable[_R].range) >= Menu.combo.autoMinR then

            if VIP_USER and Menu.misc.packet then

                
                Packet("S_CAST", packet):send()

            else

                CastSpell(_R)

            end

        end



end

function AutoHeal()
        for i, ally in ipairs(GetAllyHeroes()) do
            if SpellTable[_W].ready and Menu.heal.UseHeal then
                if (ally.health / ally.maxHealth < Menu.heal.HealManager /100)  then
                    if GetDistance(ally, myHero) <= SpellTable[_W].range then
                        if Menu.misc.packet then
                            Packet("S_CAST", {spellId = _W}):send()
                            return
                        end

                        if not Menu.misc.packet then
                            CastSpell(_W, ally)
                        end
                    end
                end
            end
        end
    end







    -- MAIN DRAW FUNCTION --
function __draw()

    DrawCircles()
    DrawText()
    DrawMisc()

end
-- MAIN DRAW FUNCION --

-- DRAW FUNCTIONS -- 
function DrawCircles() -- CIRCLE DRAWINGS ON SCREEN

    if Menu and Menu.draw and Menu.draw.enabled then

        if Menu.draw.lfc then -- LAG FREE CIRCLES

            if Menu.draw.drawAA then DrawCircleLFC(myHero.x, myHero.y, myHero.z, GetTrueRange(), ARGB(255,255,255,255)) end -- DRAW AA RANGE

            if Menu.draw.drawQ and SpellTable[_Q].ready then DrawCircleLFC(myHero.x, myHero.y, myHero.z, SpellTable[_Q].range, ARGB(255,255,255,255)) end -- DRAW Q RANGE

            if Menu.draw.drawW and SpellTable[_W].ready then DrawCircleLFC(myHero.x, myHero.y, myHero.z, SpellTable[_W].range, ARGB(255,255,255,255)) end -- DRAW W RANGE

            if Menu.draw.drawE and SpellTable[_E].ready then DrawCircleLFC(myHero.x, myHero.y, myHero.z, SpellTable[_E].range, ARGB(255,255,255,255)) end -- DRAW E RANGE

          

            if Menu.draw.drawTarget and GetTarget() ~= nil then DrawCircleLFC(GetTarget().x, GetTarget().y, GetTarget().z, 150, ARGB(255,255,255,255)) end -- DRAW TARGET

        else -- NORMAL CIRCLES

            if Menu.draw.drawAA then DrawCircle(myHero.x, myHero.y, myHero.z, GetTrueRange(), ARGB(255,255,255,255)) end -- DRAW AA RANGE

            if Menu.draw.drawQ and SpellTable[_Q].ready then DrawCircle(myHero.x, myHero.y, myHero.z, SpellTable[_Q].range, ARGB(255,255,255,255)) end -- DRAW Q RANGE

            if Menu.draw.drawW and SpellTable[_W].ready then DrawCircle(myHero.x, myHero.y, myHero.z, SpellTable[_W].range, ARGB(255,255,255,255)) end -- DRAW W RANGE

            if Menu.draw.drawE and SpellTable[_E].ready then DrawCircle(myHero.x, myHero.y, myHero.z, SpellTable[_E].range, ARGB(255,255,255,255)) end -- DRAW E RANGE

            

            if Menu.draw.drawTarget and GetTarget() ~= nil then DrawCircle(GetTarget().x, GetTarget().y, GetTarget().z, 150, ARGB(255,255,255,255)) end -- DRAW TARGET

        end

    end

end

function DrawText() -- TEXT DRAWINGS ON SCREEN

    if Menu and Menu.draw and Menu.draw.enabled then

    end

end

function DrawMisc() -- MISC DRAWINGS LIKE LINES OR SPRITES ON SCREEN

    if Menu and Menu.draw and Menu.draw.enabled then

    end

end
-- DRAW FUNCTIONS --

function GetBestCircularFarmPos(range, radius, objects) -- RETURN: POSITION AND NUMBER OF BEST POSSIBLE W FARM - pos, number
    local bestPos
    local bestHit = 0
    for _, object in ipairs(objects) do
        local hit = CountObjectsNearPos(objects.visionPos or object, range, radius, objects)
        if hit > bestHit then
            bestHit = hit
            bestPos = Vector(object)
            if bestHit == #objects then
                break
            end
        end
    end
    return bestPos, bestHit
end

function __initPriorities()

    if heroManager.iCount < 10 and (GetGame().map.shortName == "twistedTreeline" or heroManager.iCount < 6) then

        SendMessage("Too few champs to arrange priorities.")

    elseif heroManager.iCount == 6 then

        ArrangePrioritiesTT()

    else

        ArrangePriorities()

    end

end

function SetPriority(table, hero, priority)

    for i = 1, #table, 1 do

        if hero.charName:find(table[i]) ~= nil then
            TS_SetHeroPriority(priority, hero.charName)
        end

    end

end

function ArrangePriorities()

    for _, enemy in ipairs(GetEnemyHeroes()) do

        SetPriority(PriorityTable.AD_Carry, enemy, 1)
        SetPriority(PriorityTable.AP, enemy, 2)
        SetPriority(PriorityTable.Support, enemy, 3)
        SetPriority(PriorityTable.Bruiser, enemy, 4)
        SetPriority(PriorityTable.Tank, enemy, 5)

    end

end

function ArrangePrioritiesTT()

    for _, enemy in ipairs(GetEnemyHeroes()) do

        SetPriority(PriorityTable.AD_Carry, enemy, 1)
        SetPriority(PriorityTable.AP, enemy, 1)
        SetPriority(PriorityTable.Support, enemy, 2)
        SetPriority(PriorityTable.Bruiser, enemy, 2)
        SetPriority(PriorityTable.Tank, enemy, 3)

    end

end

-- SUPP PLOX GLOBAL FUNCTIONS --
function myManaPct() return (myHero.mana * 100) / myHero.maxMana end -- RETURN: HERO MANA PERCENTAGE - %number
function myHealthPct() return (myHero.health * 100) / myHero.maxHealth end -- RETURN: HERO HEALTH PERCENTAGE - %number

function getManaPercent(unit) -- RETURN: TARGET MANA PERCENTAGE - %number

    local obj = unit or myHero
    return (onj.mana / obj.maxMana) * 100

end

function getHealthPercent(unit) -- RETURN: TARGET HEALTH PERCENTAGE - %number

    local obj = unit or myHero
    return (obj.health / obj.maxHealth) * 100

end

function GetMaxRange() -- RETURN: MAX RANGE AMONGST HERO SKILLS - number

    return math.max(myHero.range, SpellTable[_Q].range or 0,  SpellTable[_E].range or 0)

end

function GetTrueRange() -- RETURN: REAL AUTO ATTACK RANGE - number
    return myHero.range + GetDistance(myHero, myHero.minBBox)
end

function GetHitBoxRadius(target) -- RETURN: HITBOX RADIUS OF TARGET - number

    return GetDistance(target.minBBox, target.maxBBox)/2

end

function CheckHeroCollision(pos, spell) -- RETURN: WILL THE SKILL COLLIDE - boolean, unit

    for _, enemy in ipairs(GetEnemyHeroes()) do

        if ValidTarget(enemy) and _GetDistanceSqr(enemy) < math.pow(SpellTable[spell].range * 1.5, 2) then -- TODO ADD TARGET MENU HERE

            local projectile, pointLine, onSegment = VectorPointProjectionOnLineSegment(Vector(player), pos, Vector(enemy))

            if (_GetDistanceSqr(enemy, projectile) <= math.pow(VP:GetHitBox(enemy) * 2 + SpellTable[spell].width, 2)) then

                return true, enemy

            end

        end

    end

    return false

end

function CountObjectsNearPos(pos, range, radius, objects) -- RETURN: NUMBER OF OBJECTS - number
    local n = 0
    for i, object in ipairs(objects) do
        if GetDistanceSqr(pos, object) <= radius * radius then
            n = n + 1
        end
    end
    return n
end

function GetEnemyCountInPos(pos, radius)
    local n = 0
    for _, enemy in ipairs(GetEnemyHeroes()) do
        if GetDistanceSqr(pos, enemy) <= radius * radius then n = n + 1 end 
    end
    return n
end

function AlliesInRange(range, point) -- RETURN: NUMBER OF ALLIES - number
    local n = 0
    for _, ally in ipairs(GetAllyHeroes()) do
        if ValidTarget(ally, math.huge, false) and GetDistanceSqr(point, ally) <= range * range then
            n = n + 1
        end
    end
    return n
end

function GetLowestHealthAlly() -- RETURN: ALLY, HEALTH PERCENT - unit, %number

    local leastHp = myHealthPct()
    local leastHpAlly = myHero

    for _, ally in ipairs(GetAllyHeroes()) do
        local allyHpPct = getHealthPercent(ally)
        if allyHpPct <= leastHp and not ally.dead and _GetDistanceSqr(ally) < 700 * 700 then
            leastHp = allyHpPct
            leastHpAlly = ally
        end
    end

    return leastHpAlly, leastHp

end

-- Lag free circles (by barasia, vadash and viseversa)
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
  quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
  quality = 2 * math.pi / quality
  radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end

function round(num) 
 if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircleLFC(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextLvl(x, y, z, radius, 1, color, 75) 
    end
end

function GetTarget()

    TargetSelector:update()

    if orbwalker == 'SAC' then

        if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then

            return _G.AutoCarry.Attack_Crosshair.target

        end

    end

    if orbwalker == 'MMA' then

        if _G.MMA_Target and _G.MMA_Target.type == myHero.type then

            return _G.MMA_Target

        end

    end

    if orbwalker == 'SxOrb' then

        if SxOrb and SxOrb:GetTarget() and SxOrb:GetTarget().type == myHero.type then

            return SxOrb:GetTarget()

        end

    end

    return TargetSelector.target

end

function GetMode()

    if carryKey then  return 1 end
    if harassKey then return 2 end
    if farmKey then   return 3 end

    return nil

end

-- SPELL PACKET FUNCTIONS --
function TargetedSpellPacket(spell, target)

    return { spellId = spell, targetNetworkId = target.networkID }

end

function GenericSpellPacket(spell, x, y)

    return { spellId = spell, toX = x, toY = y, fromX = x, fromY = y }

end

function SpellPacket(spell)

    return { spellId = spell }

end
