--[[
	"Tiles!" By Detective_Smith
	A small CC Game I worked up in a hour or so.
	Enjoy the game! Dont cheat! :P
	Game Version 1.2
]]--

local sx, sy = term.getSize()
local tileWidth = 4 --math.ceil(sx / 13)
local tileHeight = 3 --math.floor(sy / 6)
local cHighScore = 0
local zHighScore = 0
local rHighScore = 0
local score = 0
local ox = math.ceil((sx / 4) + tileWidth)
local oex = sx - ox 
local timer = 0.1
local zenTime = 30
local rushTime = 10
local gameOver = false
local showControls = false
local tileColor = colors.black
local bgColor = colors.white
local menuColor = colors.black
local missColor = colors.white
local textColor = colors.white
local subTextColor = colors.white
local buttons = {}

if pocket then
	ox = 5
	oex = sx - ox + 1
end

if term.isColor() then
	menuColor = colors.gray
	missColor = colors.red
	textColor = colors.yellow
end

function saveScore()
	if fs.exists(".tilescore") then
		fs.delete(".tilescore")
	end

	local file = fs.open(".tilescore", "w")
	file.writeLine(cHighScore)
	file.writeLine(zHighScore)
	file.writeLine(rHighScore)
	file.close()
end

function loadScore()
	if fs.exists(".tilescore") then
		local file = fs.open(".tilescore", "r")
		cHighScore = tonumber(file.readLine())
		zHighScore = tonumber(file.readLine())
		rHighScore = tonumber(file.readLine())
		file.close()
	end
end

function drawSquare(x, y, c)
	for i = 1, tileHeight do
		local dX, dY = ox - 3 + (x * tileWidth), sy - (y * 3) + i
		paintutils.drawLine(dX, dY, dX + tileWidth - 1, dY, c)
	end
end

function newTileTable(n)
	tiles = {}
	tiles[9000] = {}
	if n then
		tiles[9000].A = n
		tiles[9000].L = true
	else
		tiles[9000].A = sy / tileHeight
		tiles[9000].L = false
	end
	for i = 1, tiles[9000].A do
		if i ~= tiles[9000].A then
			tiles[i] = {}
			tiles[i].X = math.random(4) 
			tiles[i].Y = i 
			tiles[i].C = tileColor
		else
			tiles[i] = {}
			tiles[i + 1] = {}
			tiles[i + 2] = {}
			tiles[i + 3] = {}
			tiles[i].X = 1
			tiles[i + 1].X = 2
			tiles[i + 2].X = 3
			tiles[i + 3].X = 4
			tiles[i].Y = i
			tiles[i + 1].Y = i 
			tiles[i + 2].Y = i 
			tiles[i + 3].Y = i
			tiles[i].C = tileColor
			tiles[i + 1].C = tileColor
			tiles[i + 2].C = tileColor
			tiles[i + 3].C = tileColor
		end
	end
end

function newTile(n)
	table.remove(tiles, n)
	for i = n, #tiles do
		tiles[i].Y = tiles[i].Y - 1
	end
	if tiles[9000].L then
		tiles[9000].A = tiles[9000].A - 1
	end
	if not tiles[9000].L then
		local newNum = #tiles + 1
		local nX = math.random(4)
		local nY = tiles[newNum - 1].Y + 1
		tiles[newNum] = {}
		tiles[newNum].X = nX
		tiles[newNum].Y = nY
		tiles[newNum].C = tileColor
	end
end

function checkForTile(x, y, bool)
	for i = 1, #tiles do
		if tiles[i].X == x then
			if tiles[i].Y == y then
				newTile(y)
				if bool then
					score = score + 1
					if score > zHighScore then
						zHighScore = score
					end
					if score > rHighScore then
						rHighScore = score
					end
				end
				if tiles[9000].L then
					return true, tiles[9000].A
				else
					return true
				end
			end
		end
	end
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function overlay(highScore, str, bool)
	if bool then
		term.clear()
		drawSquares()
		for i = 1, sy do
			paintutils.drawLine(1, i, ox, i, menuColor)
			paintutils.drawLine(oex, i, sx, i, menuColor)
		end
		paintutils.drawPixel(sx, 1, missColor)
		term.setTextColor(subTextColor)
		term.setCursorPos(sx, 1)
		term.write("X")
		paintutils.drawLine(ox + 1, 1, oex - 1, 1, menuColor)
	end
	term.setBackgroundColor(colors.gray)
	term.setCursorPos(ox + 1, 1)
	term.setTextColor(textColor)
	print(str.. "    ")
	term.setCursorPos(1, 2)
	if not pocket then
		term.write("SCORE: ")
		term.setTextColor(subTextColor) 
		print(score)
		term.setTextColor(textColor)
		term.write("HIGH SCORE: ") 
		term.setTextColor(subTextColor)
		print(highScore)
		if showControls then
			term.setCursorPos(1,5)
			term.setTextColor(textColor)
			print("CONTROLS:")
			term.setTextColor(subTextColor)
			print("CLICK ON A BLACK")
			print("TILE TO REMOVE IT")
			print("OR USE A, S, D, F")
			print("KEYS TO REMOVE")
			print("TILES. DONT CLICK")
			print("THE WHITE ONES!")
			print("PRESS H TO HIDE")
			print("THIS MESSAGE.")
		end
	else
		print("SCORE")
		term.setTextColor(subTextColor)
		print(score)
		print("")
		term.setTextColor(textColor)
		print("HIGH")
		print("SCORE")
		term.setTextColor(subTextColor)
		print(highScore)
		if showControls then
			print("")
			term.setTextColor(textColor)
			print("HOWTO")
			term.setTextColor(subTextColor)
			print("CLICK")
			print("ONLY")
			print("ON")
			print("BLACK")
			print("TILES")
			print("OR")
			print("USE")
			print("A, S")
			print("D, F")
			print("KEYS")
		end
	end
end

function drawSquares()
	for i = 1, oex - ox - 1 do
		paintutils.drawLine(ox + i, 2, ox + i, sy, bgColor)
	end
	for i = 1, sy / tileHeight + 4 do
		if tiles[i] then
			if tiles[i].X and tiles[i].Y and tiles[i].C then
				drawSquare(tiles[i].X, tiles[i].Y, tiles[i].C)
			end
		end
	end
end

function drawScreen(hS, str, b, b2)
	if b2 then
		drawSquares()
		drawSquare(tiles[#tiles].X, tiles[#tiles].Y, tiles[#tiles].C)
	end
	overlay(hS, str, b)
end

function classicMode()
	local exit = false
	newTileTable(30)
	totalTime = 0
	local tLeft = 30
	drawScreen(cHighScore, "TILES LEFT: " ..tLeft, true)

	function gameReset(x, y, bool)
		local newNum = #tiles + 1
		tiles[newNum] = {}
		tiles[newNum].X = x
		tiles[newNum].Y = y
		tiles[newNum].C = missColor
		if bool then
			if cHighScore <= 0 then
				cHighScore = score
			end
			if score <= cHighScore then
				cHighScore = score
			end
		end
		tLeft = tLeft or "LOST"
		drawScreen(cHighScore, "TILES LEFT: " ..tLeft, false, true)
		saveScore()
		sleep(1)
		score = 0
		newTileTable(30)
		totalTime = 0
		tLeft = 30
		drawScreen(cHighScore, "TILES LEFT: " ..tLeft, true, true)
	end

	while true do
		e, p1, p2, p3 = os.pullEventRaw()
		if e == "char" then
			if p1 == "a" or p1 == "s" or p1 == "d" or p1 == "f" then
				cTimer = os.startTimer(timer)
			end
			if p1 == "a" then
				bool, tLeft = checkForTile(1, 1)
				if not bool then gameReset(1,1) end
			elseif p1 == "s" then
				bool, tLeft = checkForTile(2, 1)
				if not bool then gameReset(2,1) end
			elseif p1 == "d" then
				bool, tLeft = checkForTile(3, 1)
				if not bool then gameReset(3,1) end
			elseif p1 == "f" then
				bool, tLeft = checkForTile(4, 1)
				if not bool then gameReset(4,1) end
			elseif p1 == "h" then
				showControls = not showControls
				drawScreen(cHighScore, "TILES LEFT: " ..tLeft, true)
			end
			drawScreen(cHighScore, "TILES LEFT: " ..tLeft, false, true)
		elseif e == "mouse_click" then
			if p2 >= ox + 1 and p2 <= oex -1 and p3 ~= 1 then
				cTimer = os.startTimer(timer)
				local cx = math.ceil((p2 - ox) / tileWidth)
				local cy = math.ceil((p3 - 1) / tileHeight)
				local cy = -cy + 7
				bool, tLeft = checkForTile(cx, cy)
				if not bool then gameReset(cx, cy) end
			elseif p2 == sx and p3 == 1 then
				exit = true
			end
			if exit then
				score = 0
				totalTime = 0
				saveScore()
				break
			end
			drawScreen(cHighScore, "TILES LEFT: " ..tLeft, false, true)
		elseif e == "timer" then
			if p1 == cTimer then
				cTimer = os.startTimer(timer)
				totalTime = totalTime + 0.1
				score = round(totalTime,3)
			end
			drawScreen(cHighScore, "TILES LEFT: " ..tLeft)
		elseif e == "terminate" then
			gameOver = true
			break
		end
		if tLeft then
			if tLeft <= 0 then 
				gameReset(sx, sy, true)
			end
		end
	end
end

function zenMode()
	local exit = false
	newTileTable()
	totalTime = zenTime
	drawScreen(zHighScore, "TIME LEFT: " ..round(totalTime,3), true)

	function gameReset(x, y)
		local newNum = #tiles + 1
		tiles[newNum] = {}
		tiles[newNum].X = x
		tiles[newNum].Y = y
		tiles[newNum].C = missColor
		drawScreen(zHighScore, "TIME LEFT: " ..round(totalTime,3), false, true)
		saveScore()
		sleep(1)
		score = 0
		newTileTable()
		totalTime = zenTime
		drawScreen(zHighScore, "TIME LEFT: " ..round(totalTime,3), true, true)
	end

	while true do
		e, p1, p2, p3 = os.pullEventRaw()
		if e == "char" then
			if p1 == "a" or p1 == "s" or p1 == "d" or p1 == "f" then
				zTimer = os.startTimer(timer)
			end
			if p1 == "a" then
				local bool = checkForTile(1, 1, true)
				if not bool then gameReset(1,1) end
			elseif p1 == "s" then
				local bool = checkForTile(2, 1, true)
				if not bool then gameReset(2,1) end
			elseif p1 == "d" then
				local bool = checkForTile(3, 1, true)
				if not bool then gameReset(3,1) end
			elseif p1 == "f" then
				local bool = checkForTile(4, 1, true)
				if not bool then gameReset(4,1) end
			elseif p1 == "h" then
				showControls = not showControls
				drawScreen(zHighScore, "TIME LEFT: " ..round(totalTime,3), true)
			end
			drawScreen(zHighScore, "TIME LEFT: " ..round(totalTime,3), false, true)
		elseif e == "mouse_click" then
			if p2 >= ox + 1 and p2 <= oex -1 and p3 ~= 1 then
				zTimer = os.startTimer(timer)
				local cx = math.ceil((p2 - ox) / tileWidth)
				local cy = math.ceil((p3 - 1) / tileHeight)
				local cy = -cy + 7
				local bool = checkForTile(cx, cy, true)
				if not bool then gameReset(cx,cy) end
			elseif p2 == sx and p3 == 1 then
				exit = true
			end
			if exit then
				score = 0
				totalTime = zenTime
				saveScore()
				break
			end
			drawScreen(zHighScore, "TIME LEFT: " ..round(totalTime,3), false, true)
		elseif e == "timer" then
			if p1 == zTimer then
				zTimer = os.startTimer(timer)
				totalTime = totalTime - 0.1
				if totalTime <= 0 then
					gameReset(sx, sy)
				end
			end
			drawScreen(zHighScore, "TIME LEFT: " ..round(totalTime,3))
		elseif e == "terminate" then
			gameOver = true
			break
		end
	end
end

function rushMode()
	local exit = false
	local totalTime = rushTime
	local tilesNeeded = 30
	local level = 0
	local totalTilesNeeded = tilesNeeded + level
	newTileTable()
	drawScreen(rHighScore, "TIME LEFT: " ..round(totalTime,3), true)

	function gameReset(x, y)
		local newNum = #tiles + 1
		tiles[newNum] = {}
		tiles[newNum].X = x
		tiles[newNum].Y = y
		tiles[newNum].C = missColor
		drawScreen(rHighScore, "TIME LEFT: " ..round(totalTime,3), false, true)
		saveScore()
		sleep(1)
		score = 0
		newTileTable()
		totalTime = rushTime
		level = 0
		totalTilesNeeded = tilesNeeded + level
		drawScreen(rHighScore, "TIME LEFT: " ..round(totalTime,3), true, true)
	end

	while true do
		e, p1, p2, p3 = os.pullEventRaw()
		if e == "char" then
			if p1 == "a" or p1 == "s" or p1 == "d" or p1 == "f" then
				rTimer = os.startTimer(timer)
			end
			if p1 == "a" then
				local bool = checkForTile(1, 1, true)
				if not bool then gameReset(1,1) end
			elseif p1 == "s" then
				local bool = checkForTile(2, 1, true)
				if not bool then gameReset(2,1) end
			elseif p1 == "d" then
				local bool = checkForTile(3, 1, true)
				if not bool then gameReset(3,1) end
			elseif p1 == "f" then
				local bool = checkForTile(4, 1, true)
				if not bool then gameReset(4,1) end
			elseif p1 == "h" then
				showControls = not showControls
				drawScreen(rHighScore, "TIME LEFT: " ..round(totalTime,3), true)
			end
			totalTilesNeeded = totalTilesNeeded - 1
			if totalTilesNeeded <= 0 then
				level = level + 1
				totalTilesNeeded = tilesNeeded + level
				totalTime = totalTime + 10
			end
			drawScreen(rHighScore, "TIME LEFT: " ..round(totalTime,3), false, true)
		elseif e == "mouse_click" then
			if p2 >= ox + 1 and p2 <= oex -1 and p3 ~= 1 then
				zTimer = os.startTimer(timer)
				local cx = math.ceil((p2 - ox) / tileWidth)
				local cy = math.ceil((p3 - 1) / tileHeight)
				local cy = -cy + 7
				local bool = checkForTile(cx, cy, true)
				if not bool then gameReset(cx,cy) end
			elseif p2 == sx and p3 == 1 then
				exit = true
			end
			if exit then
				score = 0
				totalTime = rushTime
				saveScore()
				break
			end
			drawScreen(rHighScore, "TIME LEFT: " ..round(totalTime,3), false, true)
		elseif e == "timer" then
			if p1 == rTimer then
				rTimer = os.startTimer(timer)
				totalTime = totalTime - 0.1
				if totalTime <= 0 then
					gameReset(sx, sy)
				end
			end
			drawScreen(rHighScore, "TIME LEFT: " ..round(totalTime,3))
		elseif e == "terminate" then
			gameOver = true
			break
		end
	end
end

function exitGame()
	saveScore()
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	term.clear()
	term.setCursorPos(1,1)
	print("Thanks for playing 'Tiles!'. Your score was saved.")
end

function newButton(x,y,str,bColor,tColor,func)
	local w = #str + 1
	local newNumber = #buttons + 1
	buttons[newNumber] = {}
	buttons[newNumber].X = x
	buttons[newNumber].Y = y
	buttons[newNumber].eX = x + w
	buttons[newNumber].eY = y + 3
	buttons[newNumber].W = w
	buttons[newNumber].S = str
	buttons[newNumber].bC = bColor
	buttons[newNumber].tC = tColor
	buttons[newNumber].F = func
end

function checkButton(x,y)
	for i = 1, #buttons do
		if x >= buttons[i].X and x <= buttons[i].eX and y >= buttons[i].Y and y <= buttons[i].eY then
			local func = buttons[i].F
			term.setTextColor(colors.white)
			func()
			return true
		end
	end
end

function drawMenu()
	term.setBackgroundColor(menuColor)
	term.clear()
	term.setCursorPos((sx / 2) - 3,3)
	term.setTextColor(textColor)
	print("Tiles!")
	for i = 1, #buttons do
		for j = 1, 3 do
			paintutils.drawLine(buttons[i].X, (buttons[i].Y - 1) + j, buttons[i].X + buttons[i].W, (buttons[i].Y - 1) + j, buttons[i].bC)
		end
		term.setCursorPos(buttons[i].X + 1, buttons[i].Y + 1)
		term.setTextColor(buttons[i].tC)
		print(buttons[i].S)
	end
	paintutils.drawPixel(sx, 1, missColor)
	term.setTextColor(subTextColor)
	term.setCursorPos(sx, 1)
	term.write("X")
end

function mainMenu()
	newButton((sx/2) - 10, 5, "Classic", colors.white, colors.black, classicMode)
	newButton((sx/2) + 2, 5, "Zen Mode", colors.white, colors.black, zenMode)
	newButton((sx/2) - 10, 9, "Rush Mode", colors.white, colors.black, rushMode)
	drawMenu()
	while true do
		if gameOver then
			exitGame()
			break
		end
		e, p1, p2, p3 = os.pullEvent()
		if p2 and p3 then
			local inGame = checkButton(p2,p3)
			if not inGame then
				if p2 == sx and p3 == 1 then
					exitGame()
					break
				end
			end
		end
		drawMenu()
	end
end

loadScore()
mainMenu()
shell.run("Rogue/Menu")
