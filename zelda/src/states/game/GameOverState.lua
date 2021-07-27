--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameOverState = Class{__includes = BaseState}

function GameOverState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('start')
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function GameOverState:render()
    --love.graphics.setFont(gFonts['zelda'])
    love.graphics.setFont(love.graphics.newFont(64))
    love.graphics.setColor(175/255, 53/255, 42/255, 1)
    love.graphics.printf('GAME OVER', 0, WINDOW_HEIGHT / 2 - 48, WINDOW_WIDTH, 'center')
    
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf('Press Enter', 0, WINDOW_HEIGHT / 2 + 32, WINDOW_WIDTH, 'center')
end
