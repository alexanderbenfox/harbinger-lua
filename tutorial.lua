--lua/love notes:

function love.load()
	image = love.graphics.newImage("cake.jpg")
	love.graphics.setNewFont(12)
	love.graphics.setColor(0,0,0)
	love.graphics.setBackgroundColor(255,255,255)
end

function love.update(dt)
	if love.keyboad.isDown("up") then
		num = num + 100*dt -- this would increment num by 100 per second
	end
end

function love.draw()
	love.graphics.draw(image,imgx,imgy)
	love.graphics.print("Click and drag the cake around of use the arrow keys.", 10, 10)
end
-- called continuously

function love.mousepressed(x,y,button)
	if button == 'l' then
		imgx = x -- move image to where mouse clicked
		imgy = y -- move image to where mouse clicked
	end
end

function love.mousereleased(x,y,button)
	if button == 'l' then
		fireSlingshot(x,y) -- this would be defined somewhere else
	end
end

function love.keypressed(key)
	if key == 'b' then
		text = "the B key was pressed."
	elseif key == 'a' then
		a_down = true
	end
end

function love.keyreleased(key)
	if key == 'b' then
		text = "the B key was released."
	elseif key == 'a' then
		a_down = false
	end
end

function love.focus(f)
	if not f then
		print("Lost focus")
	else
		print("GAINED FOCUS")
	end
end

--f is true when the player is focused on the LOVE window and not, say the internet browser

function love.quit()
	print("THANKS FOR PLAYING!")
end
--called when the window is closed by the player
