-- animation controller

require 'charactercontroller'

animationController = {}
local playerState


function animationController:load()
	animationContoller = {attacking = false, moving = false, shooting = false, idle = true, state = nil}
	playerState = player.bools
end

function animationController:update()
	animationContoller = {attacking = false, moving = false, shooting = false, idle = true, state = nil}
	playerState = player.bools
	if playerState.shooting then 
		animationController.shooting = true
		animationController.state = "Shooting2"
	end
	if playerState.attacking then
		animationController.attacking = true
		animationController.state = "SwordAttack1"
	end
	if playerState.moving then
		animationController.moving = true
		animationController.state = "Walk"
	end
	if not animationController.moving and not animationController.attacking and not animationController.shooting then
		animationController.idle = true
		animationController.state = "Idle"
	end

end

function animationController:getState()
end

