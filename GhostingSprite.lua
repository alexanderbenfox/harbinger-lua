-- Ghosting sprite class

GhostingSprite = {}
GhostingSprite.x = 0
GhostingSprite.y = 0
GhostingSprite.dissapearTimer = 0 -- float
GhostingSprite.startingAlpha = 0 -- float
GhostingSprite.sprite = nil -- img
GhostingSprite.sortingID = 0 -- int
GhostingSprite.sortingOrder = 0 -- int
GhostingSprite.referencedTransform = player
GhostingSprite.offset_x = 0
GhostingSprite.offset_y = 0
GhostingSprite.original_x = 0
GhostingSprite.original_y = 0
GhostingSprite.color = {r = 0, g = 0, b = 0, a = 0}
GhostingSprite.a = 0
GhostingSprite.canBeReused = false
GhostingSprite.savedDirection = 1
function GhostingSprite.color:setColor(r,g,b,a)
	self.r = r
	self.g = g
	self.b = b
	self.a = a
end
function GhostingSprite.color:getColor()
	return self.r, self.g, self.b, self.a
end

GhostingSprite.hasBeenInitiated = false
GhostingSprite.canBeReused = false

GhostingSprite.beganLerping = false
GhostingSprite.finishedLerping = false
GhostingSprite.startLerpTime = 0

function GhostingSprite:StartDisappearing()
	if not self.beganLerping then
		self.finishedLerping = false
		self.startLerpTime = love.timer.getTime()
		self.beganLerping = true
	end
	--local original_color = self.original_color
	--local blackWithZeroAlpha = 0,0,0,0
	if not self.finishedLerping then

		local timeSinceLerpStart = love.timer.getTime() - self.startLerpTime
		local percentComplete = timeSinceLerpStart/self.dissapearTimer
		if percentComplete >= 1 then
			self.finishedLerping = true
			self.color:setColor(self.color.r,self.color.g,self.color.b,0)
			self.a = 0
		end
		local r,g,b,currentAlpha = self.color:getColor()
		--local newAlphaValue = lerp(currentAlpha,0,percentComplete*255)
		local newAlphaValue = self.startingAlpha*(1-percentComplete)
		self.color:setColor(self.color.r,self.color.g,self.color.b,newAlphaValue)
		self.a = newAlphaValue
	else
		self.canBeReused = true
		self.hasBeenInitiated = false
		self.beganLerping = false
	end

end




function GhostingSprite:new(o)
	o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function GhostingSprite:init(dissapearTimer,startingAlpha,sprite,sortingOrder,referencedTransform,offset_y,offset_x)
	self.dissapearTimer = dissapearTimer
	self.startingAlpha = startingAlpha
	self.sprite = sprite
	self.startLerpTime = love.timer.getTime()
--	self.sortingID = sortingID
	self.sortingOrder = sortingOrder
	self.referencedTransform = referencedTransform
	self.offset_x = offset_x
	self.offset_y = offset_y
	self.original_x = referencedTransform.render_x
	self.original_y = referencedTransform.render_y
	self.hasBeenInitiated = true
	self.color = self.color:setColor(255,255,255,255)
	self.savedDirection = direction
	self.beganLerping = false
end

function GhostingSprite:update(dt)
	if self.hasBeenInitiated then

		self.x = self.original_x+self.offset_x
		self.y = self.original_y+self.offset_y
		self:StartDisappearing()
	end

	-- body
end

function GhostingSprite:draw()
	love.graphics.setColor(self.color.r,self.color.g,self.color.b,self.a)
	love.graphics.draw(self.sprite,self.x,self.y,0,self.savedDirection,1)
	love.graphics.setColor(255,255,255,255)
end

function lerp(a,b,t) return (1-t)*a + t*b end