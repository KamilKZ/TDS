
local bullet = {}
bullet.bullets = {}
bullet.types = {}
bullet.types.small = {image = "sprites/bullets/bullet_small.png"}
bullet.types.medium = {image = "sprites/bullets/bullet_medium.png"}
bullet.types.large = {image = "sprites/bullets/bullet_large.png"}
bullet.types.rocket = {image = "sprites/bullets/bullet_rocket.png"}

function bullet.load()
	for k,v in pairs(bullet.types) do
		bullet.types[k].imageO = love.graphics.newImage(v.image)
	end
end

function bullet.create( bulletData, x, y, angle )
	local _bullet = {}
	
	_bullet.pos = {x = x, y = y}
	_bullet.angle = angle
	_bullet.speed = bulletData.vel
	_bullet.data = bulletData
	_bullet.enemy = bulletData.enemy
	
	table.insert(bullet.bullets, _bullet)
end

function bullet.update(dt)
	for k,v in pairs(bullet.bullets) do
		local x = v.pos.x + math.sin( v.angle ) * v.speed
		local y = v.pos.y - math.cos( v.angle ) * v.speed
		
		v.pos = {x=x,y=y}
		
		if math.dist(640, 360, x, y) > 800 then
			bullet.bullets[k] = nil
		end
		
		if v.enemy then
			local _wall = wall.intersects(v.pos.x,v.pos.y)
			if _wall then
				v.data.onHit(v, _wall, x, y)
				bullet.bullets[k] = nil
			end
		else
			local _wall = wall.intersects(v.pos.x,v.pos.y)
			if _wall then
				bullet.bullets[k] = nil
			end
			for i,tank in pairs(tank.tanks) do
				if math.dist(tank.pos.x, tank.pos.y, x, y) < 24 then
					v.data.onHit(v, tank, x, y)
					bullet.bullets[k] = nil
				end
			end
		end
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

function bullet.draw()
	local height = love.window.getHeight()
	local width = love.window.getWidth()
	love.graphics.setColor(255,255,255,255)
	for k,v in pairs( bullet.bullets ) do
		if not _G.DEBUG then
			love.graphics.draw( bullet.types[v.data.size].imageO, v.pos.x, v.pos.y, v.angle, 1, 1, 2, 4 )
			v.data.tracer( v, v.x, v.y )
		else
			love.graphics.setShader(mask_effect)
			love.graphics.setColor(0,0,255,150)
			love.graphics.draw( bullet.types[v.data.size].imageO, v.pos.x, v.pos.y, v.angle, 1, 1, 2, 4 )
			love.graphics.setShader()
			
			love.graphics.setFont(_G.DEBUG_FONT)
			love.graphics.setColor(255,0,0,150)
			love.graphics.rectangle("fill", v.pos.x-2, v.pos.y-2, 4, 4)
			love.graphics.print(k, v.pos.x, v.pos.y)
		end
	end
end

return bullet