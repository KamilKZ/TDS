
local wall = {}
wall.size = 32
wall.walls = {}
wall.types = {}
wall.types.concrete = {health = 100, color = {127,127,127,255}}

function wall.load()
	
end

function wall.create( x, y, t )
	local _wall = {}
	
	_wall.pos = {x = x, y = y}
	_wall.type = t
	_wall.health = wall.types[t].health
	_wall.damage = function(self, dmg)
		self.health = self.health - dmg
	end
	
	table.insert(wall.walls, _wall)
end

function wall.clear()
	wall.walls = {}
end

function wall.intersects(x,y)
	for k,v in pairs(wall.walls) do
		if math.inRect(x,y, v.pos.x, v.pos.y, wall.size, wall.size) then
			return v
		end
	end
end

function wall.keypressed(k)
	if k=="w" then
		local mousex, mousey = love.mouse.getPosition()
		
		coordX = math.floor(mousex/wall.size)*wall.size
		coordY = math.floor(mousey/wall.size)*wall.size
		
		for k,v in pairs(wall.walls)do
			if v.pos.x == coordX and v.pos.y == coordY then
				return
			end
		end
		wall.create(coordX,coordY,"concrete")
	end
end
		

function wall.update(dt)
	for k,v in pairs(wall.walls) do
		if v.health<1 then
			wall.walls[k] = nil
		end
	end
end

function wall.draw()
	local height = love.window.getHeight()
	local width = love.window.getWidth()
	love.graphics.setColor(255,255,255,255)
	for k,v in pairs( wall.walls ) do
		if not _G.DEBUG then
			love.graphics.setColor(wall.types[v.type].color)
			love.graphics.rectangle("fill", v.pos.x, v.pos.y, wall.size, wall.size )
		else
			love.graphics.setColor(0,0,255,150)
			love.graphics.rectangle("fill", v.pos.x, v.pos.y, wall.size, wall.size )
			
			love.graphics.setFont(_G.DEBUG_FONT)
			love.graphics.setColor(255,0,0,150)
			love.graphics.rectangle("fill", v.pos.x-2, v.pos.y-2, 4, 4)
			love.graphics.print(k, v.pos.x, v.pos.y)
		end
	end
	if _G.DEBUG then 
		local mousex, mousey = love.mouse.getPosition()
		coordX = math.floor(mousex/wall.size)*wall.size
		coordY = math.floor(mousey/wall.size)*wall.size
		love.graphics.setColor(0,255,0,150)
		love.graphics.rectangle("fill", coordX, coordY, wall.size, wall.size )
	end
end

return wall