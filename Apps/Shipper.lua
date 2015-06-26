os.loadAPI("art")
 
if type(art) ~= "table" then
    print("Installing ART API")
    shell.run("pastebin get ERf5QAkK art")
end
 
local timer
 
local tick = 0
 
local interval = 0.2
 
local background
local function genBackground()
 
        local maxx, maxy = term.getSize()
 
        local cols = {colors.white, colors.yellow, colors.gray, colors.black, colors.orange}
 
        local pixels = {}
        for i = 1, math.random(30, 110) do
                pixels[#pixels + 1] = art.setPixel(math.random(maxx), math.random(maxy), nil, cols[math.random(#cols)], "*")
        end
        local pixarr = art.createPixelArray(pixels)
       
        return pixarr
end
 
local function getBackground()
        local maxx, maxy = term.getSize()
       
        if background == nil then background = genBackground() end
        for i=1,#background.pixs do
                local pixel = background.pixs[i]
                local x = pixel:getX()
                local y = pixel:getY()+1
                while y > maxy do
                        y = y - maxy
                end
                pixel:setX(x)
                pixel:setY(y)
        end
       
        return background
end
 
local sc = 0
 
local function drawBackground()
        local maxx, maxy = term.getSize()
       
        term.clear()
        term.setCursorPos(1,1)
        local back = getBackground()
        back:draw()
end
 
local bon = true
local function doBackground(pixarr)
        local btim = os.startTimer(0)
       
        background = nil
       
        for i=1,#pixarr.pixs do
                local pixel = pixarr.pixs[i]
                pixel:setX(pixel:getX() + 19)
                pixel:setY(pixel:getY() + 6)
        end
       
        local bint = 0.025
        while bon do
                local event, p1 = os.pullEvent()
                if event == "timer" and p1 == btim then
                        btim = os.startTimer(bint)
                        drawBackground()
                        pixarr:draw()
                elseif event == "key" then
                        local key = p1
                        if key == 28 then
                                bon = false
                        end
                end
        end
       
        for i=1,#pixarr.pixs do
                local pixel = pixarr.pixs[i]
                pixel:setX(pixel:getX() - 19)
                pixel:setY(pixel:getY() - 6)
        end
        bon = true
       
        timer = os.startTimer(interval)
       
       
        return true
end
 
 
 
 
 
 
 
 
 
 
 
local function split(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    if str ~= nil then
           local fpat = "(.-)" .. pat
           local last_end = 1
           local s, e, cap = str:find(fpat, 1)
           while s do
                  if s ~= 1 or cap ~= "" then
                 table.insert(t,cap)
                  end
                  last_end = e+1
                  s, e, cap = str:find(fpat, last_end)
           end
           if last_end <= #str then
                  cap = str:sub(last_end)
                  table.insert(t, cap)
           end
        else
                print("##SHIPPER ERROR failed to split ["..str.."] by:"..pat)
    end
    return t
end
 
-- 1: = repair (1)
-- 2: = repair (all)
-- 3: = upgrade armour (1)
-- 4: = upgrade damage (1)
-- 5: = upgrade accuracy (1)
-- 6: = upgrade speed (1)
-- 7: = upgrade wep-speed (1)
-- 8: = upgrade health (1)
-- 9: = updrade evasivness (1)
-- 10: = buy crew (1)
local maxSel = 10
 
--function to get the choice, price and pixelarray based off the current selection
--sel = selection
--shp = ship being used by the shop
local function getShop(sel, shp)
        local choices = {}
        choices = {
                                 {"|=============|",
                                  "| REPAIR 1 (1)|",
                                  "|=============|"},
                                 {"|============|",
                                  "| REPAIR ALL |",
                                  "|============|"},
                                 {"|====================|",
                                  "|UPGRADE ARMOUR (175)|",
                                  "|====================|"},
                                 {"|====================|",
                                  "|UPGRADE DAMAGE (200)|",
                                  "|====================|"},
                                 {"|======================|",
                                  "|UPGRADE ACCURACY (375)|",
                                  "|======================|"},
                                 {"|===================|",
                                  "|UPGRADE SPEED (225)|",
                                  "|===================|"},
                                 {"|=======================|",
                                  "|UPGRADE WEP-SPEED (300)|",
                                  "|=======================|"},
                                 {"|====================|",
                                  "|UPGRADE HEALTH (175)|",
                                  "|====================|"},
                                 {"|=========================|",
                                  "|UPGRADE EVASIVENESS (375)|",
                                  "|=========================|"},
                                 {"|==============|",
                                  "|BUY CREW (300)|",
                                  "|==============|"}
                          }
        prices = {
                                1,
                                shp.stats.maxhealth - shp.stats.health,
                                175,
                                200,
                                375,
                                225,
                                300,
                                175,
                                375,
                                300
                         }
       
        local pixels = {}
        local choice = choices[sel]
        local price = prices[sel]
        for y=1,#choice do
                local l = choice[y]
                for x=1,string.len(l) do
                        local ch = string.sub(l, x, x)
                        pixels[#pixels + 1] = art.setPixel(x+1, y+1, nil, colors.blue, ch)
                end
        end    
        local pixarr = art.createPixelArray(pixels)
        return choice, price, pixarr
end
 
--boolean to determine if the game is on
local on = true
 
--increases as the game progresses, makes the game harder but the loot better
local progress = 1
--the current location of your ship.
local loc = {1, 1}
--the destination of your ship
local dest = nil
--the distance between your destination and you
local dist = 0
--the tile that you are traveling to
local target = "+"
 
--the amount of ship blueprints there are
local ship_types = 5
--the colors that the blueprint builder uses
local ship_colors = {colors.white, colors.red, colors.lime, colors.orange}
 
--the map height & width
local mwidth = 10
local mheight = 11
 
--returns the symbol found at x, y
local function getTarget(x, y)
        local blup = {}
        blup = {"+-------------------+",
                        "|+++++++++++@+++++++|",
                        "|++@+++++++++++++@++|",
                        "|+++++++@+++++++++++|",
                        "|+@+++++++++++@+++++|",
                        "|+++++++++@+++++++++|",
                        "|++++@++++++++++++++|",
                        "|++++++++++@+++++@++|",
                        "|+@+++++++++++++++++|",
                        "|++++++@++++++++@+++|",
                        "+-------------------+"}
        return string.sub(blup[y], x, x)
end
 
--returns a pixelarray containing the spacemap
local function getSpaceMap()
        local blup = {}
        blup = {"+-------------------+",
                        "|+++++++++++@+++++++|",
                        "|++@+++++++++++++@++|",
                        "|+++++++@+++++++++++|",
                        "|+@+++++++++++@+++++|",
                        "|+++++++++@+++++++++|",
                        "|++++@++++++++++++++|",
                        "|++++++++++@+++++@++|",
                        "|+@+++++++++++++++++|",
                        "|++++++@++++++++@+++|",
                        "+-------------------+"}
       
        mwidth = string.len(blup[1])
        mheight = #blup
                       
        local pixels = {}
        for y=1,#blup do
                local l = blup[y]
                for x=1,string.len(l) do
                        local ch = string.sub(l, x, x)
                        local color = colors.blue
                        if ch == "#" then color = colors.blue
                        elseif ch == "+" then color = colors.white
                        elseif ch == "@" then color = colors.red end
                        pixels[#pixels + 1] = art.setPixel(x, y, nil, color, ch)
                end
        end
        local smap = art.createPixelArray(pixels)
        return smap
end
 
--creates the appropriate ship at the x, y coordinates with those colors based off the given type
local function createShip(x, y, colors, type)
        local cur = colors[1]
        local blup = {}
        local weapons = {}
        local stats = {}
        if type == 1 then
                blup = {"    _    ",
                                "   /3^1\\   ",
                                "  2_1|4=1|2_1 ",
                                " /4=1@3+1@4=1\\ ",
                                "  \\@@@/  ",
                                "   |4:1|  ",
                                "   \\_/",
                                "    2V"}
                weapons = {{3+x, 3+y}, {7+x, 3+y}}
                stats = {
                        ["armour"] = 60,
                        ["damage"] = {80, 100},
                        ["wepspeed"] = 3.5,
                        ["speed"] = 10,
                        ["accuracy"] = 60,
                        ["evasivness"] = 15,
                        ["health"] = 700,
                        ["maxhealth"] = 700,
                        ["type"] = type
                }
        elseif type == 2 then
                blup = {"",
                                "  /3^1\\   ",
                                " 2_1|@|2_1 ",
                                "|4=1@3+1@4=1|",
                                " \\_@_/ ",
                                "   2V1    "}
                weapons = {{2+x, 2+y}, {6+x, 2+y}}
                stats = {
                        ["armour"] = 45,
                        ["damage"] = {55, 75},
                        ["wepspeed"] = 2.5,
                        ["speed"] = 15,
                        ["accuracy"] = 50,
                        ["evasivness"] = 25,
                        ["health"] = 575,
                        ["maxhealth"] = 575,
                        ["type"] = type
                }
        elseif type == 3 then
                blup = {"        ",
                                "  /2^1\\",
                                " 2_1|3:1|2_1",
                                "|4=1@_@4=1|",
                                "|3:1| |3:1|",
                                " 2V1   2V1"}
                --weapons = {{4+x, 1+y}, {2+x, 3+y}, {6+x, 3+y}}
                weapons = {{4+x, 1+y}}
                stats = {
                        ["armour"] = 35,
                        ["damage"] = {50, 65},
                        ["wepspeed"] = 1.5,
                        ["speed"] = 30,
                        ["accuracy"] = 40,
                        ["evasivness"] = 35,
                        ["health"] = 500,
                        ["maxhealth"] = 500,
                        ["type"] = type
                }
        elseif type == 4 then
                blup = {"",
                                "    2_1     ",
                                "   /3^1\\    ",
                                "   |=|   ",
                                "  /4:2+4:1\\  ",
                                " /2_1|4=1|2_1\\ ",
                                "    2V1     "}
                weapons = {{5+x, 2+y}}
                stats = {
                        ["armour"] = 50,
                        ["damage"] = {45, 60},
                        ["wepspeed"] = 2,
                        ["speed"] = 25,
                        ["accuracy"] = 45,
                        ["evasivness"] = 35,
                        ["health"] = 500,
                        ["maxhealth"] = 500,
                        ["type"] = type
                }
        elseif type == 5 then
                blup = {"        ",
                                "   /3^1\\   ",
                                "   |4:1|   ",
                                " 2_1/4=1 4=1\\2_1 ",
                                " \\_ 3+1 _/ ",
                                "   \\2_1/  ",
                                "    2V1    "}
                weapons = {{2+x, 5+y}, {8+x, 5+y}}
                stats = {
                        ["armour"] = 35,
                        ["damage"] = {90, 110},
                        ["wepspeed"] = 4,
                        ["speed"] = 15,
                        ["accuracy"] = 70,
                        ["evasivness"] = 10,
                        ["health"] = 600,
                        ["maxhealth"] = 600,
                        ["type"] = type
                }
        end
        local pixels = {}
        for i=1,#blup do
                local l = blup[i]
                local off = 0
                for j=1,string.len(l) do
                        local ch = string.sub(l, j, j)
                        if ch ~= " " and ch ~= "" and ch ~= nil then
                                local n = tonumber(ch)
                                if n ~= nil then
                                        cur = colors[n]
                                        off = off + 1
                                else
                                        ch = string.gsub(ch, "@", " ")
                                        local pixel = art.setPixel(x+j-1-off, y+i-1, nil, cur, ch)
                                        pixels[#pixels + 1] = pixel
                                end
                        end
                end
        end
        local parr = art.createPixelArray(pixels)
        return parr, weapons, stats
end
 
local mtype = 1
local curship, rrw, rrs = createShip(2, 2, ship_colors, mtype)
 
local data = {
        ["name"] = "Your",
        ["crew"] = 5,
        ["money"] = 500,
        ["stats"] = rrs,
        ["dmg_boost"] = 0,
        ["armour_boost"] = 0,
}
 
--writes the stats at the screen dependant on x, y and the gap is the gap imbetween the double lines information
function writeStats(sx, sy, gap)
        term.setCursorPos(sx, sy)
        term.write("HP: "..data.stats.health)
        term.setCursorPos(sx+gap, sy)
        term.write("Crew: "..data.crew)
        term.setCursorPos(sx, sy+1)
        term.write("Money: "..data.money)
        term.setCursorPos(sx+gap, sy+1)
        term.write("SPD: "..data.stats.speed)
        term.setCursorPos(sx, sy+2)
        term.write("ACC: "..data.stats.accuracy)
        term.setCursorPos(sx+gap, sy+2)
        term.write("WEP_SPD: "..data.stats.wepspeed)
        term.setCursorPos(sx, sy+3)
        term.write("EVS: "..data.stats.evasivness)
        term.setCursorPos(sx+gap, sy+3)
        term.write("ARM: "..data.stats.armour)
        term.setCursorPos(sx, sy+4)
        term.write("DMG: "..data.stats.damage[1].." TO "..data.stats.damage[2])
        term.setCursorPos(sx, sy+5)
        term.write("TARGET: "..target)
        if dest ~= nil then
                term.setCursorPos(sx, sy+6)
                term.write("DEST: "..dest[1]..","..dest[2])
                term.setCursorPos(sx+gap, sy+5)
                term.write("DIST: "..dist)
        end
       
       
end
 
--sets the current type of ship selected to a valid one
local function checkType()
        if mtype < 1 then mtype = ship_types end
        if mtype > ship_types then mtype = 1 end
end
 
local con = true
 
local ctim = os.startTimer(0)
 
local interv = 0.5
--ship selection loop
while con do
        local event, p1 = os.pullEvent()
        if event == "timer" and p1 == ctim then
                term.clear()
                term.setCursorPos(1, 1)
                print("Choose your ship:")
                curship:draw()
                writeStats(2, 13, 15)
                ctim = os.startTimer(interv)
        elseif event == "key" then
                local key = p1
                if key == 203 then --left
                        mtype = mtype - 1
                        checkType()
                        local cursh, rw, rs = createShip(2, 2, ship_colors, mtype)
                        rrs = rs
                        rrw = rw
                        curship = cursh
                        data = {
                                                        ["name"] = "Your",
                                                        ["crew"] = 5,
                                                        ["money"] = 500,
                                                        ["stats"] = rs,
                                                        ["dmg_boost"] = 0,
                                                        ["armour_boost"] = 0,
                                                }
                elseif key == 205 then --right
                        mtype = mtype + 1
                        checkType()
                        local cursh, rw, rs = createShip(2, 2, ship_colors, mtype)
                        rrs = rs
                        rrw = rw
                        curship = cursh
                        data = {
                                                        ["name"] = "Your",
                                                        ["crew"] = 5,
                                                        ["money"] = 500,
                                                        ["stats"] = rs,
                                                        ["dmg_boost"] = 0,
                                                        ["armour_boost"] = 0,
                                                }
                elseif key == 28 then
                        con = false
                elseif key == 29 then
                        on = false
                        con = false
                end
        end
end
 
 
local ship, weapons, stats = createShip(2, 2, ship_colors, mtype)
 
data = {
        ["name"] = "Your",
        ["crew"] = 5,
        ["money"] = 500,
        ["stats"] = stats,
        ["dmg_boost"] = 0,
        ["armour_boost"] = 0,
}
 
local wep_array = nil
--returns a pixel array of the ships weapons.
local function getFire(weparray)
        local pixels = {}
        for i=1,#weparray do
                local weapon = weparray[i]
                local x = weapon[1]-1
                local y = weapon[2]-1
                while y >= 1 do
                        pixel = art.setPixel(x, y, nil, colors.red, "|")
                        pixels[#pixels + 1] = pixel
                        y = y-1
                end
        end
        local pixarr = art.createPixelArray(pixels)
        return pixarr
end
 
--used to improve the stats of an enemy ship
local function improveStats(csts)
        local sts = csts
        local amt = ((progress-5) * 2)
        if amt > 0 then
                amt = amt + math.random(progress)
                for i=1,amt do
                        local type = math.random(7)
                        if type == 1 then sts.armour = sts.armour + 1 end
                        if type == 2 then
                                sts.damage[1] = sts.damage[1] + 1
                                sts.damage[2] = sts.damage[2] + 1
                        end
                        if type == 3 then
                                if sts.wepspeed > 0.1 then
                                        sts.wepspeed = sts.wepspeed - 0.1
                                end
                        end
                        if type == 4 then
                                sts.speed = sts.speed + 1
                        end
                        if type == 5 then
                                if sts.accuracy < 90 then
                                        sts.accuracy = sts.accuracy + 1
                                end
                        end
                        if type == 6 then
                                if sts.evasivness < 90 then
                                        sts.evasivness = sts.evasivness
                                end
                        end
                        if type == 7 then
                                sts.health = sts.health + 1
                                sts.maxhealth = sts.maxhealth + 1
                        end
                end
        end
        return sts
end
 
 
--fighting ship data
local f_weps = nil
local f_ship = nil
local fighting = nil
local isfighting = false
 
local canfire = true
local e_canfire = true
 
local canrepair = true
local e_canrepair = true
 
local cancharge = true
local e_cancharge = true
 
local e_wdraw = false
 
--weapon timer
local wtimer
local e_wtimer
 
--canfire timers
local cftimer
local e_cftimer
 
--repair timers
local rtimer
local e_rtimer
 
--charge timers
local ctimer
local e_ctimer
 
local msg = "Game started"
 
--shoots from ship "from" to ship "to"
local function shoot(from, to)
        if math.random(100) >= to.stats.evasivness then
                if math.random(100) <= from.stats.accuracy then
                        local dmg = math.random(from.stats.damage[1], from.stats.damage[2]) + from.dmg_boost
                        from.dmg_boost = 0
                        local armour = to.stats.armour + to.armour_boost
                        to.armour_boost = to.armour_boost - 1
                        fdmg = dmg - ((dmg / 100) * armour)
                        to.stats.health = to.stats.health - dmg
                        msg = from.name.." ship hit "..to.name.." ship for "..dmg.. " damage!"
                end
        end
end
 
--repairs "from"
local function repair(from, to)
        from.armour_boost = from.armour_boost + 1
end
 
--charge "from"
local function charge(from, to)
        from.dmg_boost = from.dmg_boost + 1
end
 
local function fleeFight(from, to)
        shoot(from, to)
        msg = from.name.." ship is tring to flee from the fight!"
        local n = 20
        while math.random(60) > from.stats.speed and on and n >= 0 do
                shoot(to, from)
                checkFight()
               
                if from.stats.health > 0 then
                        msg = from.name.." ship was hit while fleeing!"
                end
        end
        checkFight()
        if from.stats.health > 0 then
                msg = from.name.." ship fled the fight without dying!"
                isfighting = false
        else
                isfighting = false
        end    
end
 
local function enemyMove(from, to)
        local move = math.random(3)    
        if from.stats.health < 100 and math.random(100) < 20 then move = 4 end
        if move == 1 then --fire
                if e_canfire then
                        e_wdraw = true
                        e_wtimer = os.startTimer(from.stats.wepspeed)
               
                        shoot(from, to)
                        e_canfire = false
                        e_cftimer = os.startTimer(from.stats.wepspeed)
                end
        elseif move == 2 then --repair
                if e_canrepair then
                        repair(from, to)
                       
                        e_canrepair = false
                        e_rtimer = os.startTimer(((100-fighting.crew) / 10)*2)
                end
        elseif move == 3 then --charge
                if e_cancharge then
                                charge(from, to)
                               
                                e_cancharge = false
                                e_ctimer = os.startTimer(((100-fighting.crew) / 10)*4)
                end
        elseif move == 4 then --flee
                fleeFight(from, to)
        end
end
 
function checkFight()
        if fighting ~= nil and isfighting then
                if data.stats.health <= 0 then
                        on = false
                        term.clear()
                        term.setCursorPos(1,1)
                        print(" --- GAME OVER --- ")
                        sleep(2)
                elseif fighting.stats.health <= 0 then
                        isfighting = false
                        local loot = {math.random(fighting.money), math.random(fighting.crew)-1}
                        msg = fighting.name.." ship was shot down, looted: £"..loot[1].." and found "..loot[2].." crew-members!"
                        data.money = data.money + loot[1]
                        data.crew = data.crew + loot[2]
                        if data.crew > 99 then data.crew = 99 end
                end
        end
end
 
local function fire(bypass)
        if (isfighting or bypass == true) and fighting ~= nil then
                if wep_array == nil then
                        wep_array = getFire(weapons)
                        if canfire then
                                weparray:draw()
                        end
                        wtimer = os.startTimer(2)
                else
                        if canfire then
                                wep_array:draw()
                        end
                        wtimer = os.startTimer(2)
                end
                if canfire then
               
                        shoot(data, fighting)
               
                        canfire = false
                        cftimer = os.startTimer(data.stats.wepspeed)
                end
        end
end
 
local function printFightStats()
        term.setCursorPos(2, 13)
        term.write("HP: "..data.stats.health)
        term.setCursorPos(13, 13)
        term.write("HP: "..fighting.stats.health)
        term.setCursorPos(2, 13)
        term.write("DMG: "..data.dmg_boost)
        term.setCursorPos(13, 13)
        term.write("DMG: "..fighting.dmg_boost)
        term.setCursorPos(2, 13)
        term.write("ARM: "..data.armour_boost)
        term.setCursorPos(13, 13)
        term.write("ARM: "..fighting.armour_boost)
end
 
function save(dir)
        local finfo = nil
        if isfighting then
                finfo = {"isfight=true",
                                 "fship=money~"..fighting.money..":crew~"..fighting.crew..":name~"..fighting.name..":dmgb~"..fighting.dmg_boost..":armb~"..fighting.armour_boost..":stats~hp,"..fighting.stats.health.."~arm,"..fighting.stats.armour.."~dmg,"..fighting.stats.damage[1]..";"..fighting.stats.damage[2].."~wepspd,"..fighting.stats.wepspeed.."~spd,"..fighting.stats.speed.."~acc,"..fighting.stats.accuracy.."~evs,"..fighting.stats.evasivness.."~type,"..fighting.stats.type.."~maxhp,"..fighting.stats.maxhealth,
                                 }
        end
        sinfo = {"ship=money~"..data.money..":crew~"..data.crew..":name~"..data.name..":dmgb~"..data.dmg_boost..":armb~"..data.armour_boost..":stats~hp,"..data.stats.health.."~arm,"..data.stats.armour.."~dmg,"..data.stats.damage[1]..";"..data.stats.damage[2].."~wepspd,"..data.stats.wepspeed.."~spd,"..data.stats.speed.."~acc,"..data.stats.accuracy.."~evs,"..data.stats.evasivness.."~type,"..data.stats.type.."~maxhp,"..data.stats.maxhealth,
                         }
        local data = {"prog="..progress, "dist="..dist, "loc="..loc[1]..","..loc[2], "target="..target}
        if dest ~= nil then
                data[#data + 1] = "dest="..dest[1]..","..dest[2]
        end
        for i=1,#sinfo do data[#data + 1] = sinfo[i] end
        if finfo ~= nil then
                for i=1,#finfo do data[#data + 1] = finfo[i] end
        end
       
        if fs.exists(dir) then fs.delete(dir) end
        local file = fs.open(dir, "a")
        for i=1,#data do
                file.writeLine(data[i])
        end
        file.close()
end
 
function loadGame(dir)
        local lns = {}
        if fs.exists(dir) then
                local file = fs.open(dir, "r")
                local line = file.readLine()
                while line ~= nil do
                        lns[#lns + 1] = line
                        line = file.readLine()
                end
                file.close()
        end
        local isf = false
        local shp = nil
        local fshp = nil
        local prog = 1
        local lc = {1, 1}
        local dis = 0
        local des = nil
        term.clear()
        term.setCursorPos(1,1)
        for i=1,#lns do
                local splt1 = split(lns[i], "=")
                if splt1[1] == "isfight" then
                        if splt1[2] == "true" then isfighting = true end
                        print("READ ISFIGHT")
                elseif splt1[1] == "prog" then
                        prog = tonumber(splt1[2])
                elseif splt1[1] == "dist" then
                        dis = tonumber(splt1[2])
                elseif splt1[1] == "loc" then
                        local lsplt = split(splt1[2], ",")
                        lc = {tonumber(lsplt[1]), tonumber(lsplt[2])}
                elseif splt1[1] == "dest" then
                        local lsplt = split(splt1[2], ",")
                        des = {tonumber(lsplt[1]), tonumber(lsplt[2])}
                elseif splt1[1] == "target" then
                        target = splt1[2]
                elseif splt1[1] == "fship" or splt1[1] == "ship" then
                        print("LOADING SHIP")
                        local dat = {}
                        local splt2 = split(splt1[2], ":")
                        for j=1,#splt2 do
                                local part = splt2[j]
                                local splt = split(part, "~")
                                if splt[1] == "money" then
                                        print("LOADING MONEY")
                                        dat["money"] = tonumber(splt[2])
                                elseif splt[1] == "crew" then
                                        dat["crew"] = tonumber(splt[2])
                                elseif splt[1] == "name" then
                                        dat["name"] = splt[2]
                                elseif splt[1] == "dmgb" then
                                        dat["dmg_boost"] = tonumber(splt[2])
                                elseif splt[1] == "armb" then
                                        dat["armour_boost"] = tonumber(splt[2])
                                elseif splt[1] == "stats" then
                                        print("LOADING STATS")
                                        local stat = {}
                                        for i=2,#splt do
                                                local spl = split(splt[i], ",")
                                                if spl[1] == "hp" then
                                                        stat["health"] = tonumber(spl[2])
                                                elseif spl[1] == "arm" then
                                                        stat["armour"] = tonumber(spl[2])
                                                elseif spl[1] == "dmg" then
                                                        local spll = split(spl[2], ";")
                                                        local dmg = {tonumber(spll[1]), tonumber(spll[2])}
                                                        stat["damage"] = dmg
                                                elseif spl[1] == "wepspd" then
                                                        stat["wepspeed"] = tonumber(spl[2])
                                                elseif spl[1] == "spd" then
                                                        stat["speed"] = tonumber(spl[2])
                                                elseif spl[1] == "acc" then
                                                        stat["accuracy"] = tonumber(spl[2])
                                                elseif spl[1] == "evs" then
                                                        stat["evasivness"] = tonumber(spl[2])
                                                elseif spl[1] == "maxhp" then
                                                        stat["maxhealth"] = tonumber(spl[2])
                                                elseif spl[1] == "type" then
                                                        stat["type"] = tonumber(spl[2])
                                                end
                                        end
                                        print(stat.health.."!")
                                        dat["stats"] = stat
                                        print(dat.stats.health.."!")
                                end
                        end
                        print(dat.stats.health.."!")
                        --dat["stats"] = {
                        --      ["health"] = stat.health,
                        --      ["armour"] = stat.armour,
                        --      ["damage"] = stat.damage,
                        --      ["wepspeed"] = stat.wepspeed,
                        --      ["speed"] = stat.speed,
                        --      ["accuracy"] = stat.accuracy,
                        --      ["evasivness"] = stat.evasivness,
                        --      ["type"] = stat.type
                        --}
                        if splt1[1] == "fship" then
                                fshp = dat
                        elseif splt1[1] == "ship" then
                                shp = dat
                        end
                end
        end
        print(shp.stats.health.."!")
        return isf, fshp, shp, prog, lc, des, dis
end
 
 
 
wep_array = getFire(weapons)
 
local sel = 1
-- 1: = repair (1)
-- 2: = repair (all)
-- 3: = upgrade armour (1)
-- 4: = upgrade damage (1)
-- 5: = upgrade accuracy (1)
-- 6: = upgrade speed (1)
-- 7: = upgrade wep-speed (1)
-- 8: = upgrade health (1)
-- 9: = updrade evasivness (1)
 
local function doShop(selc)
        local choice, price, pixarr = getShop(selc, data)
        if data.money - price < 0 then
                msg = "Not enough money!"
        else
                data.money = data.money - price
                if selc == 1 then
                        if data.stats.health + 1 > data.stats.maxhealth then
                                data.money = data.money + price
                                msg = "Already max health"
                        else
                                data.stats.health = data.stats.health + 1
                        end
                elseif selc == 2 then
                        data.stats.health = data.stats.maxhealth
                elseif selc == 3 then
                        if data.stats.armour >= 90 then
                                data.money = data.money + price
                                msg = "Already max armour"
                        else
                                data.stats.armour = data.stats.armour + 1
                        end
                elseif selc == 4 then
                        data.stats.damage[1] = data.stats.damage[1] + 1
                        data.stats.damage[2] = data.stats.damage[2] + 1
                elseif selc == 5 then
                        if data.stats.accuracy >= 90 then
                                data.money = data.money + price
                                msg = "Already max accuracy"
                        else
                                data.stats.accuracy = data.stats.accuracy + 1
                        end
                elseif selc == 6 then data.stats.speed = data.stats.speed + 1
                elseif selc == 7 then
                if data.stats.wepspeed <= 0.1 then
                        data.money = data.money + price
                        msg = "Already max wepspeed"
                else
                        data.stats.wepspeed = data.stats.wepspeed - 0.1
                end
                elseif selc == 8 then
                        data.stats.health = data.stats.health + 1
                        data.stats.maxhealth = data.stats.maxhealth + 1
                elseif selc == 9 then
                        if data.stats.evasivness >= 90 then
                                data.money = data.money + price
                                msg = "Already max evasivness"
                        else
                                data.stats.evasivness = data.stats.evasivness + 1
                        end
                elseif selc == 10 then
                        if data.stats.crew >= 99 then
                                data.money = data.money + price
                                msg = "Already max crew"
                        else
                                data.stats.crew = data.stats.crew + 1
                        end
                end
                msg = "Spent £"..price.."!"
                progress = progress + 1
        end
end
local function updateSelection()
        if sel < 1 then sel = maxSel end
        if sel > maxSel then sel = 1 end
end
 
local cshop = nil
 
local pause = false
local iswriting = false
local isloading = false
local ismap = false
local isshop = false
local curdir = ""
 
local playerl = {2, 2}
local oplayerl = nil
local function checkPlayer()
        if playerl[1] < 2 then playerl[1] = 2 end
        if playerl[1] > mwidth - 1 then playerl[1] = mwidth - 1 end
        if playerl[2] < 2 then playerl[2] = 2 end
        if playerl[2] > mheight - 1 then playerl[2] = mheight - 1 end
end
 
local smap = nil
 
local firing = true
 
timer = os.startTimer(0)
while on do
        local event, p1, p2 = os.pullEvent()
        if event == "timer" and p1 == timer then
       
                term.scroll(-1)
                term.clear()
                term.setCursorPos(1,1)
                timer = os.startTimer(interval)
                if ismap then
                        if smap == nil then
                                smap = getSpaceMap()
                        end
                        smap:draw()
                       
                        local pixel1 = art.createPixel(oplayerl[1], oplayerl[2], nil, colors.blue, "^")
                        local pixel2 = art.createPixel(playerl[1], playerl[2], nil, colors.yellow, "=")
                        pixel1:draw()
                        pixel2:draw()
                else
                        if isshop then
                                if cshop == nil then
                                        local choice, price, pixs = getShop(sel, data)
                                        cshop = pixs
                                end
                                cshop:draw()
                                term.setTextColor(colors.red)
                                writeStats(2, 8, 15)
                                term.setCursorPos(2, 6)
                                term.write(msg)
                        else
                                ship:draw()
                                if firing then fire() end
                                if iswriting then
                                        local tx, ty = term.getSize()
                                        term.setCursorPos(1, ty)
                                        term.write("Enter save directory: "..curdir)
                                end
                                if isloading then
                                        local tx, ty = term.getSize()
                                        term.setCursorPos(1, ty)
                                        term.write("Enter load directory: "..curdir)
                                end
                                if isfighting == false then
                                        if not pause then
                                                tick = tick + 1
                                                if math.random(100) <= 2 and tick >= 7 then
                                                        tick = 0
                                                        isfighting = true
                                                        local f_stats = {}
                                                        f_ship, f_weps, f_stats = createShip(14, 2, ship_colors, math.random(ship_types))
                                                        f_stats = improveStats(f_stats)
                                                        f_weps = getFire(f_weps)
                                                        local cre = progress+9
                                                        if cre > 99 then cre = 99 end
                                                        fighting = {
                                                                ["name"] = "Enemy",
                                                                ["crew"] = math.random(3, cre),
                                                                ["money"] = math.random(5*progress, 250*progress),
                                                                ["stats"] = f_stats,
                                                                ["dmg_boost"] = 0,
                                                                ["armour_boost"] = 0,
                                                        }
                                                        local m_f_h = ((fighting.crew*100) + fighting.money) * 3
                                                        m_f_h = m_f_h / 200
                                                        local chance = fighting.money + fighting.crew
                                                        while chance > 100 do
                                                                chance = chance / math.random(2, 30)
                                                        end
                                                        if chance < 10 then change = 10 end
                                                        if math.random(100) < chance then
                                                                fighting.stats.health = fighting.stats.health - m_f_h
                                                        end
                                                        msg = "Started fighting with "..fighting.name.." ship!"
                                                end
                                        end
                                        writeStats(2, 13, 15)
                                        if dest ~= nil and not iswriting and not isloading and not pause then
                                                dist = dist - data.stats.speed
                                        end
                                        if dist <= 0 and dest ~= nil then
                                                loc = dest
                                                dest = nil
                                        end
                                else
                                                checkFight()
                                                if e_wdraw then
                                                        f_weps:draw()
                                                end
                                                f_ship:draw()
                                                if not pause then
                                                        enemyMove(fighting, data)
                                                end
                                                term.setCursorPos(2, 13)
                                                term.write("HP: "..data.stats.health)
                                                term.setCursorPos(13, 13)
                                                term.write("HP: "..fighting.stats.health)
                                       
                                end
                                if pause then
                                        term.setCursorPos(1, 1)
                                        term.write("-GAME PAUSED-")
                                end
                        term.setCursorPos(2, 11)
                        term.write(msg)
                        end
                end
        elseif event == "timer" and p1 == wtimer then
                fire()
                firing = false
        elseif event == "timer" and p1 == cftimer then
                canfire = true
        elseif event == "timer" and p1 == rtimer then
                canrepair = true
        elseif event == "timer" and p1 == ctimer then
                cancharge = true
        elseif event == "timer" and p1 == e_cftimer then
                e_canfire = true
        elseif event == "timer" and p1 == e_rtimer then
                e_canrepair = true
        elseif event == "timer" and p1 == e_ctimer then
                e_cancharge = true
        elseif event == "timer" and p1 == e_wtimer then
                e_wdraw = false
        elseif event == "char" and (iswriting or isloading or pause) then
                local ch = p1
                curdir = curdir..ch
        elseif event == "key" then
                local key = p1
               
                if iswriting or isloading or pause or dest ~= nil then else
                        if key == 41 then
                                doBackground(ship)
                        end
                        if key == 50 then
                                if ismap then ismap = false
                                elseif not isfighting then
                                        oplayerl = {playerl[1], playerl[2]}
                                        ismap = true
                                end
                        end
                        if key == 16 then
                                if isshop then isshop = false
                                elseif not isfighting and target == "@" then
                                        isshop = true
                                end
                        end
                end
                if ismap then
                        if key == 200 then --up
                                playerl[2] = playerl[2] - 1
                        elseif key == 203 then --left
                                playerl[1] = playerl[1] - 1
                        elseif key == 208 then --down
                                playerl[2] = playerl[2] + 1
                        elseif key == 205 then --right
                                playerl[1] = playerl[1] + 1
                        elseif key == 28 then
                                ismap = false
                                dest = {playerl[1], playerl[2]}
                                local difx, dify = 0
                                difx = oplayerl[1] - playerl[1]
                                if difx < 0 then difx = difx * -1 end
                                dify = oplayerl[2] - playerl[2]
                                if dify < 0 then dify = dify * -1 end
                                dist = difx + dify * 1000
                               
                                target = getTarget(playerl[1], playerl[2])
                                progress = progress + 1
                        elseif key == 29 then
                                on = false
                        end
                        checkPlayer()
                else
                        if isshop then
                                if key == 203 then --left
                                        sel = sel - 1
                                        updateSelection()
                                        local choice, price, pixs = getShop(sel, data)
                                        cshop = pixs
                                elseif key == 205 then --right
                                        sel = sel + 1
                                        updateSelection()
                                        local choice, price, pixs = getShop(sel, data)
                                        cshop = pixs
                                elseif key == 28 then --enter
                                        doShop(sel)
                                end
                        else
                                if key == 29 then
                                        on = false
                               
                                elseif key == 57 then
                                        if isfighting and not (iswriting or isloading or pause) then
                                                firing = true
                                                fire()
                                        end
                               
                                elseif key == 14 then
                                        if isfighting and not (iswriting or isloading or pause) then
                                                fleeFight(data, fighting)
                                        end
                                        if (iswriting or isloading) then
                                                if curdir ~= "" then
                                                        if string.len(curdir) > 1 then
                                                                curdir = string.sub(curdir, 1, -2)
                                                        else
                                                                curdir = ""
                                                        end
                                                end
                                        end
                                elseif key == 44 then
                                        if isfighting and not (iswriting or isloading or pause) then
                                                if canrepair then
                                                        repair(data, fighting)
                                                       
                                                        canrepair = false
                                                        rtimer = os.startTimer(((100-data.crew) / 10)*2)
                                                end
                                        end
                                elseif key == 45 then
                                        if cancharge and isfighting and not (iswriting or isloading or pause) then
                                                charge(data, fighting)
                                               
                                                cancharge = false
                                                ctimer = os.startTimer(((100-data.crew) / 10)*4)
                                        end
                                elseif key == 25 then
                                        if not (iswriting or isloading) then
                                                if pause then
                                                        pause = false
                                                else
                                                        pause = true
                                                end
                                        end
                                elseif key == 31 then
                                        if not iswriting and not isloading then
                                                local tx, ty = term.getSize()
                                                term.setCursorPos(1, ty-1)
                                                term.write("Enter save directory:")
                                                pause = true
                                                iswriting = true
                                        else
                                                --if curdir ~= "" and string.gsub(curdir, " ", "") ~= "" and curdir ~= nil then
                                                --      save(curdir)
                                                --end
                                                --iswriting = false
                                                --curdir = ""
                                        end
                                elseif key == 38 then
                                        if not isloading and not iswriting then
                                                term.write("Enter load directory:")
                                                isloading = true
                                                pause = true
                                        end
                                elseif key == 28 then
                                        if iswriting then
                                                if curdir ~= "" and string.gsub(curdir, " ", "") ~= "" and curdir ~= nil then
                                                        save(curdir)
                                                end
                                                iswriting = false
                                                pause = false
                                                curdir = ""
                                               
                                                msg = "Game saved!"
                                        end
                                        if isloading then
                                                if curdir ~= "" and string.gsub(curdir, " ", "") ~= "" and curdir ~= nil then
                                                        local isf, fshp, shp, prog, lc, des, dis = loadGame(curdir)
                                                        if shp ~= nil then
                                                                progress = prog
                                                                loc = lc
                                                                dest = des
                                                                dist = dis
                                                                isfighting = isf
                                                                fighting = fsh
                                                                if fighting ~= nil then
                                                                        f_ship, f_weps, f_stats = createShip(14, 2, ship_colors, fighting.stats.type)
                                                                        f_weps = getFire(f_weps)
                                                                end
                                                               
                                                                msg = shp.name
                                                                data = shp
                                                                local tshp, weapos, stas = createShip(2, 2, ship_colors, data["stats"].type)
                                                                ship = tshp
                                                                wep_array = getFire(weapos)
                                                                msg = "Game loaded!"
                                                                isloading = false
                                                                pause = false
                                                        else
                                                                msg = "Failed to load game!"
                                                                isloading = false
                                                                pause = false
                                                        end
                                                end
                                        end
                                end
                        end
                end
        end
       
end
term.clear()
term.setCursorPos(1,1)
