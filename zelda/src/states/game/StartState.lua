--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

require 'lib/love-js-api-player/js'

local dbg = require('debugger')
dbg.auto_where = 4

StartState = Class{__includes = BaseState}

function StartState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('play')
	--JS.callJS(JS.stringFunc(
	--    [[
	--     multiplayerInit();
	--  ]]
	--))
    end
end

function StartState:render()
    love.graphics.draw(gTextures['background'], 0, 0, 0, 1, 1)
    --[[love.graphics.draw(gTextures['background'], 0, 0, 0, 
        VIRTUAL_WIDTH / gTextures['background']:getWidth(),
        VIRTUAL_HEIGHT / gTextures['background']:getHeight())]]

    -- love.graphics.setFont(gFonts['gothic-medium'])
    -- love.graphics.printf('Legend of', 0, VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, 'center')

    -- love.graphics.setFont(gFonts['gothic-large'])
    -- love.graphics.printf('50', 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(love.graphics.newFont(64))
    --love.graphics.setFont(gFonts['zelda'])
    --love.graphics.setColor(34/255, 34/255, 34/255, 1)
    love.graphics.setColor(0/255, 0/255, 0/255, 1)
    love.graphics.printf('The Legend of Kevin and Zach', 2, WINDOW_HEIGHT / 2 - 32, WINDOW_WIDTH, 'center')

    --love.graphics.setColor(175/255, 53/255, 42/255, 1)
    love.graphics.setColor(0/255, 0/255, 0/255, 1)
    love.graphics.printf('The Legend of Kevin and Zach', 0, WINDOW_HEIGHT / 2 - 32, WINDOW_WIDTH, 'center')

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    --love.graphics.setFont(gFonts['zelda-small'])
    love.graphics.printf('Press Enter', 0, WINDOW_HEIGHT / 2 + 64, WINDOW_WIDTH, 'center')
end
