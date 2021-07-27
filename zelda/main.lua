--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

require 'src/Dependencies'
require 'lib/love-js-api-player/js'
require 'lib/websocket'

local dbg = require("debugger")
dbg.auto_where = 5

function love.load()
    math.randomseed(os.time())
    love.window.setTitle('Legend of 50')
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = false
    })

    love.graphics.setFont(gFonts['small'])

    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end
    }
    gStateMachine:change('start')

    gSounds['music']:setLooping(true)
    gSounds['music']:play()

    love.keyboard.keysPressed = {}
    --JS.callJS(JS.stringFunc(
    --    [[
    --	    getServerData();
    --	]]
    --))
    client = require("lib/websocket").new("legendof.trinity.ix.tc", 8082)
    --client = require("lib/websocket").new("127.0.0.1", 8082)
    function client:onmessage(message)
	--if message then print("The message: "..message) else return end
	if not message then return end
	--print("currPlayers currently: "..currPlayers)
	if not PLAYER_ID then 
	    PLAYER_ID = message:sub(1,1)
	end
	message = message:sub(2)
	finished = false
	e1_found = false
	e2_found = false
	s_found = false
	nextStart = 1
	nextEnd = -1
	--for i = 1, #message do
	while 1 == 0 do
	    if (currPlayers == "" and s_found) or (currPlayers ~= "" and e1_found and s_found) then break end
	    if not e2_found and message:sub(-i, -i) == "E" then
		nextEnd = -i - 1
		finished = true
		e2_found = true
            elseif not e1_found and currPlayers ~= "" and message:sub(i,i) == "E" then
	        currPlayers = currPlayers..message:sub(1,i-1)
		finished = true
		e1_found = true
	    end
            if not s_found and message:sub(-i, -i) == "S" then
		nextStart = -i + 1
		s_found = true
            end
	end
	--if finished then 
	if 1 == 1 then
	    --print(currPlayers)
	    --for match in (currPlayers..","):gmatch("(.-)"..",") do
	    SERVER_DATA = {}
	    for match in (message..","):gmatch("(.-)"..",") do
	        table.insert(SERVER_DATA, match);
	    end
	end
	-- s...e... | ...s...e... | ..s...e | s...e | s... | ...e | ...
	if s_found and e2_found then
	    currPlayers = ""
	elseif s_found and not e2_found then
	    currPlayers = message:sub(nextStart, nextEnd) 
	end
    end


 
end

function love.resize(w, h)
    --push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    DT = dt
    client:update()
    Timer.update(dt)
    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end

function love.draw()
    --push:start()
    gStateMachine:render()

    --push:finish()
end
