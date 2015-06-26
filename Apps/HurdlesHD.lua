term.setBackgroundColour(colours.lightBlue)
hurdle = { x = 1, y = 16 }
player = { y = 16, x = 3, c = 1, dead = false, jumps = 0, hurdles = 0 }
x, y = term.getSize()
function clear()
        term.clear()
        term.setCursorPos(1,1)
end
function clearLine(ln)
        term.setCursorPos(1,ln)
        term.clearLine()
end
function CheckCollision()
        if ((player.x == hurdle.x) or (player.x == hurdle.x + 1)) then
                if player.y == hurdle.y then
                        return true
                else
                        player.hurdles = player.hurdles + 1
                        return false
                end
        end
        return false
end
function draw()
        term.setCursorPos(1,1)
        print("Hurdles: ".. math.ceil(player.hurdles/2))
        print("Jumps: ".. player.jumps)
        clearLine(15) -- Faster clearing, less lag!
        clearLine(16)
        term.setCursorPos(1, hurdle.y)
        write(string.rep("_", x-1))
        term.setCursorPos(hurdle.x, hurdle.y)
        write("/\\")
        term.setCursorPos(player.x, player.y)
        write("&")
end
-- Update, handles collision, player jumping, etc.
function update()
        player.c = player.c + 1
        hurdle.x = hurdle.x - 1
        if player.y > 1 and player.c >= 5 then
                player.y = 16
                player.c = 1
        end
        if hurdle.x <= 1 then
                hurdle.x = 48
        end
        if CheckCollision() then
                player.dead = true
        end
end
 
clear()
os.startTimer(.2)
while not player.dead do
        event, p1 = os.pullEvent()
        if event == "key" then
                if p1 == 57 then
                        if player.y == 16 then
                                player.y = player.y - 1
                                player.jumps = player.jumps + 1
                        end
                end
        end
        if event == "timer" then
                update()
                draw()
                os.startTimer(.2)
        end
end
term.setBackgroundColour(colours.blue)
clear()
print("Player Died!")
print("Scores ")
print("Hurdles: ".. player.hurdles)
print("Jumps: ".. player.jumps)
sleep(2)
shell.run("Rogue/GamesApps")
