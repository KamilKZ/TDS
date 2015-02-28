
local tank = {}
tank.tanks = {}
tank.types = {}
tank.types.medium = {image = "sprites/tank_medium.png"}

function tank.load()
	for k,v in pairs(tank.types) do
		tank.types[k].imageO = love.graphics.newImage(v.image)
	end
end

function tank.create( x, y, angle, vel, armor )
	local _tank = {}
	
	_tank.pos = {x = x, y = y}
	_tank.angle = angle
	_tank.speed = vel
	_tank.health = armor
	_tank.healthMax = armor
	_tank.size = "medium"
	_tank.damage = function(self, dmg)
		self.health = self.health - dmg
	end
	
	_tank.lastFire = 0
	_tank.nextFire = 0
	
	table.insert(tank.tanks, _tank)
end

function tank.update(dt)
	local curTime = love.timer.getTime()
	for k,v in pairs(tank.tanks) do
		if v.health<1 then 
			explosion(v, v.pos.x,v.pos.y,0,true)
			tank.tanks[k] = nil
			score = score + 1
		elseif v.destroyWall then
			local x2 = v.pos.x + math.sin( v.angle ) * 64
			local y2 = v.pos.y - math.cos( v.angle ) * 64
			local _wall = wall.intersects(x2, y2)
			if not _wall then
				v.destroyWall = false
			end
			
			if curTime>v.nextFire then
				v.lastFire = curTime
				v.nextFire = curTime+1
				local _bullet = {
					size = "medium", vel = 5, damage = 25, projectile = "AP", enemy=true,
					tracer = function( self, x, y ) end,
					onHit = function( self, hit, x, y )
						hit.damage(hit, self.data.damage)
					end
				}
				bullet.create( _bullet, v.pos.x, v.pos.y, v.angle + (math.random(-10, 10) / 100) )
			end
				
		else
			local x = v.pos.x + math.sin( v.angle ) * v.speed
			local y = v.pos.y - math.cos( v.angle ) * v.speed
			
			v.pos = {x=x,y=y}
			
			
			local x2 = v.pos.x + math.sin( v.angle ) * 64
			local y2 = v.pos.y - math.cos( v.angle ) * 64
			local _wall = wall.intersects(x2, y2)
			if _wall then
				v.destroyWall = true
			end
			
			if math.dist(640, 360, x, y) < 70 then
				gameOver()
			end
		end
	end
	if math.random(1, 100) > 99 then
		local angle = math.random(1,360)
		local pos = {x = -math.sin( math.rad( angle ) ) * 800 + 640, y = math.cos( math.rad( angle ) ) * 800 + 360}
		local health = math.max(score/20 +0.5, 1) * 100
		tank.create( pos.x, pos.y, math.rad(angle), math.random( 2, 5 )/2, health)
	end
end

local mask_effect = love.graphics.newShader [[
   vec4 effect ( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
      // a discarded fragment will fail the stencil test.
      if (Texel(texture, texture_coords).a == 0.0)
         discard;
	  else
		 return color;
   }
]]

function tank.draw()
	local height = love.window.getHeight()
	local width = love.window.getWidth()
	love.graphics.setColor(255,255,255,255)
	for k,v in pairs( tank.tanks ) do
		love.graphics.setColor(255,255,255,255)
		if not _G.DEBUG then
			love.graphics.draw( tank.types[v.size].imageO, v.pos.x, v.pos.y, v.angle, 1, 1, tank.types[v.size].imageO:getWidth()/2, tank.types[v.size].imageO:getHeight()/2 )
		else
			love.graphics.setShader(mask_effect)
			love.graphics.setColor(0,255,0,150)
			love.graphics.draw( tank.types[v.size].imageO, v.pos.x, v.pos.y, v.angle, 1, 1, tank.types[v.size].imageO:getWidth()/2, tank.types[v.size].imageO:getHeight()/2 )
			love.graphics.setShader()
			
			love.graphics.setFont(_G.DEBUG_FONT)
			love.graphics.setColor(255,0,0,150)
			love.graphics.rectangle("fill", v.pos.x-2, v.pos.y-2, 4, 4)
			love.graphics.print(k, v.pos.x, v.pos.y)
		end
		love.graphics.setColor(255,0,0,100)
		love.graphics.rectangle( "fill", v.pos.x - 25, v.pos.y - 35, 50*v.health/v.healthMax, 5 )
	end
end

return tank