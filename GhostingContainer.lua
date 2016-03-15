-- ghosting container shit

require 'GhostingSprite'

GhostingContainer = {}

GhostingContainer._inactiveGhostingSpritesPool = {}
GhostingContainer.spawnRate = 0
GhostingContainer.nextSpawnTime = 0
GhostingContainer.trailLength = 1

--GhostingContainer.sortingLayer = 0

GhostingContainer.desiredAlpha = .8*255
GhostingContainer._ghostingSpritesQueue = {}
-- table.getn(t)
GhostingContainer.hasStarted = false

GhostingContainer.effectDuration = 1
GhostingContainer.refSpriteAnimator = nil
GhostingContainer.ghostingReference = nil

function GhostingContainer._inactiveGhostingSpritesPool:get()
end

function GhostingContainer:new(o)
	o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function GhostingContainer:init(maxGhosts,spawnRate,sprite,effectDuration,ghostingReference)
	self.trailLength = maxGhosts
	self.spawnRate = spawnRate
	self.effectDuration = maxGhosts * spawnRate * .95
	self.refSpriteAnimator = sprite
	self.nextSpawnTime = love.timer.getTime() + spawnRate
	--self.sortingLayer = refSprite
	self.hasStarted = true
	self.ghostingReference = ghostingReference
end

function GhostingContainer:StopEffect()
	self.hasStarted = false
end

function GhostingContainer:StartEffect()
	self.hasStarted = true
end

function GetCurrentSprite(animator)
	local frame = animator.action[animator.actual]
	return frame.img[frame.position]
end

function GhostingContainer:InitializeGhost(ghost)
	ghost:init(self.effectDuration,self.desiredAlpha,GetCurrentSprite(self.refSpriteAnimator),0,self.ghostingReference,0,0) -- offset might be player.y and player.x
end

function GhostingContainer:GetNextGhost()
	for _,ghost in ipairs(self._inactiveGhostingSpritesPool) do
		if ghost.canBeReused then
			self:InitializeGhost(ghost)
			return ghost
		end
	end
	return GhostingSprite:new()
	-- body
end


function GhostingContainer:update()
	for _,ghost in ipairs(self._ghostingSpritesQueue) do
		ghost:update()
		if ghost.a <= 0 then
			local newGhost = table.remove(self._ghostingSpritesQueue,_) 
			--table.insert(self._inactiveGhostingSpritesPool,newGhost)
		end
	end
	if self.hasStarted then
		if love.timer.getTime() >= self.nextSpawnTime then

			if table.getn(self._ghostingSpritesQueue) == self.trailLength then
				local peekedGhostingSprite = self._ghostingSpritesQueue[1]
				local canBeReused = peekedGhostingSprite.canBeReused
				--if canBeReused then
					-- initialize the new ghosting sprite
					--peekedGhostingSprite = GhostingSprite:new()
					table.remove(self._ghostingSpritesQueue,1) -- dequeue
					self:InitializeGhost(peekedGhostingSprite)
					table.insert(self._ghostingSpritesQueue,peekedGhostingSprite) -- enqueue
					self.nextSpawnTime = self.nextSpawnTime + self.spawnRate
				--else
				--end
			end

			-- if count is less than length, we need to create a new ghosting sprite
			if table.getn(self._ghostingSpritesQueue) < self.trailLength then
				local newGhostSprite = self:GetNextGhost()
				self:InitializeGhost(newGhostSprite)
				table.insert(self._ghostingSpritesQueue, newGhostSprite)
				self.nextSpawnTime = self.nextSpawnTime + self.spawnRate
			end

			--if greater than dequeue items off the queue, they aren't needed
			if table.getn(self._ghostingSpritesQueue) > self.trailLength then
				local difference = table.getn(self._ghostingSpritesQueue) - self.trailLength
				for i = 1,difference do
					local inactiveGhost = table.remove(self._ghostingSpritesQueue,1) -- pop off the queue
					table.insert(self._inactiveGhostingSpritesPool, inactiveGhost)
				end
				return
			end
		end
	--elseif (love.timer.getTime() >= self.nextSpawnTime) and self._ghostingSpritesQueue[1] ~= nil then
	elseif (love.timer.getTime()>= self.nextSpawnTime) then
		--table.remove(self._ghostingSpritesQueue,1)
		self.nextSpawnTime = self.nextSpawnTime + self.spawnRate
	end
end

function GhostingContainer:draw()
	--if self.hasStarted then
		for _,ghost in ipairs(self._ghostingSpritesQueue) do
			ghost:draw()
		end
	--end
end