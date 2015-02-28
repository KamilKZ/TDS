
function newGun( slot, name, image, sound, x, y, sx, sy, r, fireType, fireDelay, bulletsPerShot, ammo, reloadDelay, accuracy, projectile, projectileSize, muzzleVel, damage )
	local gun = {
		slot = slot or 1, 
		name = name or "sample", 
		x = x or 0, 
		y = y or 0, 
		image = love.graphics.newImage(image or "sprites/guns/turret_small_1.png"), 
		sound = love.audio.newSource(sound or "sounds/guns/turret_small_1.wav"),
		sx = sx or 1, 
		sy = sy or 1, 
		r = r or 0, 
		fireType = fireType or "full", 
		fireDelay = fireDelay or 0.1, 
		bulletsPerShot = bulletsPerShot or 1, 
		ammo = ammo or 30, 
		clip = ammo or 30, 
		reloadDelay = reloadDelay or 1, 
		accuracy = accuracy or 0.1, 
		projectile = projectile or "AP", 
		muzzleVel = muzzleVel or 5, 
		damage = damage or 25
	}
	
	gun.sound:setVolume(0.1)
	
	gun._bullet = {
		size = projectileSize or "medium",
		vel = gun.muzzleVel,
		damage = damage or 25,
		projectile = projectile or "AP", 
		
		tracer = function( self, x, y )
		end,
		
		onHit = function( self, hit, x, y )
			hit.damage(hit, self.data.damage)
		end
	}
	
	if projectile == "HE" then
		gun._bullet.onHit = function(self, hit, x, y )
			hit.damage(hit, self.data.damage)
			if hit.health > 0 then
				explosion(hit,x,y,5,false)
			end
		end
	end
	
	if projectile == "rocket" then
		gun._bullet.onHit = function(self, hit, x, y )
			hit.damage(hit, self.data.damage)
			if hit.health > 0 then
				explosion(hit,x,y,0,false)
			end
		end
		
		gun._bullet.tracer = function( self, x, y )
		end
	end
	
	gun.lastFire = 0
	gun.nextFire = 0
	
	gun.doFire = function(self)
		if self.ammo > 0 or self.ammo == -1 then
			if self.ammo ~= -1 then
				self.ammo = self.ammo - 1
			end
			
			local dupe = self.sound
			love.audio.play(dupe)
			
			local x = 640 + math.cos( turret.angle )*(self.x) - math.sin( turret.angle )*(-self.image:getHeight()/2 + self.y)
			local y = 360 + math.sin( turret.angle )*(self.x) + math.cos( turret.angle )*(-self.image:getHeight()/2 + self.y)
			
			for i=1, self.bulletsPerShot do
				bullet.create( self._bullet, x, y, turret.angle + (math.random(-self.accuracy, self.accuracy) / 100) )
			end
			
			self.lastFire = love.timer.getTime()
			self.nextFire = self.lastFire + self.fireDelay
		end
	end
	
	gun.reloading = false
	gun.reloadStart = 0
	gun.reloadEnd = 0
	
	gun.reload = function(self)
		self.reloading = true
		self.reloadStart = love.timer.getTime()
		self.reloadEnd = self.reloadStart + self.reloadDelay
	end
	
	gun.doReload = function(self)
		if love.timer.getTime() > self.reloadEnd then
			self.ammo = self.clip
			self.reloading = false
		end
	end
	
	return gun
end

local turret = {}

turret.base = "sprites/turret/turret_base_1.png"
turret.hull = {image="sprites/turret/turret_hull_1.png",angle=math.pi,x=0,y=0}
turret.gunSet = {
	{
		newGun(1, "cannon_1", "sprites/guns/turret_small_1.png", "sounds/guns/turret_small_1.wav", -18, -20, 1, 1, math.pi, "full", 0.1, 1, -1, 1, 5),
		newGun(1, "cannon_2", "sprites/guns/turret_small_1.png", "sounds/guns/turret_small_1.wav",  18, -20, 1, 1, math.pi, "full", 0.1, 1, -1, 1, 5)
	},{
		newGun(1, "heavy_cannon_1", "sprites/guns/turret_big_1.png", 	"sounds/guns/turret_big_1.wav", 	0, -20,   1,   1, math.pi, "full", 0.2, 1, 5, 1, 2, "HE", "medium", 6, 50),
		newGun(2, "coaxmg_1", 		"sprites/guns/turret_small_1.png", 	"sounds/guns/turret_small_1.wav",  10, -20, 0.5, 0.5, math.pi, "full", 0.05, 1, -1, 1, 15, "AP", "small", 7, 15)
	},{
		newGun(1, "heavy_cannon_1", "sprites/guns/turret_big_1.png", 	"sounds/guns/turret_big_1.wav", 	  8, -20,1, 1, math.pi, "full", 0.3, 1, -1, 1, 2, "HE", "large", 6, 35),
		newGun(2, "cannon_1", 		"sprites/guns/turret_small_1.png", 	"sounds/guns/turret_small_1.wav", 	 -8, -20,1, 1, math.pi, "semi", 0.08, 1, 50, 3, 5),
		newGun(3, "rocket_pod_1", 	"sprites/guns/turret_rocket_1.png", "sounds/guns/turret_rocket_1.wav", 	-20, -5, 1, 1, 0, "full", 0.2, 1, 8, 1, 5, "rocket", "rocket", 3, 100),
		newGun(3, "rocket_pod_2", 	"sprites/guns/turret_rocket_1.png", "sounds/guns/turret_rocket_1.wav", 	 20, -5, 1, 1, 0, "full", 0.2, 1, 8, 1, 5, "rocket", "rocket", 3, 100)
	},{
		newGun(1, "shotgun_1", "sprites/guns/turret_big_1.png", "sounds/guns/turret_big_1.wav", 20, -20, 0.5, 1, math.pi, "full", 0.8, 11, -1, 1, 5, "AP", "small", 6, 35),
	},{
		newGun(1, "heavy_cannon_1", "sprites/guns/turret_big_1.png", 	"sounds/guns/turret_big_1.wav", -18, -20,   1,   1, math.pi, "semi", 0.3, 1, -1, 1, 2, "HE", "large", 6, 50),
		newGun(1, "heavy_cannon_2", "sprites/guns/turret_big_1.png", 	"sounds/guns/turret_big_1.wav",  18, -20,   1,   1, math.pi, "semi", 0.3, 1, -1, 1, 2, "HE", "large", 6, 50),
	}
}
turret.gunSetN = 1
turret.angle = 0
function turret.load()
	turret.turretBase = love.graphics.newImage( turret.base )
	turret.turretHull = love.graphics.newImage( turret.hull.image )
	
	love.graphics.setColor(255,255,255,255)
	
	for i, set in pairs(turret.gunSet) do
		turret.gunSet[i].canvas = love.graphics.newCanvas(128,128)
	
		turret.gunSet[i].canvas:renderTo(function()
			love.graphics.draw(turret.turretHull, turret.hull.x + 64, turret.hull.y + 64, turret.hull.angle, 1, 1, turret.turretHull:getWidth()/2, turret.turretHull:getHeight()/2)
			for k,v in ipairs(set) do
				love.graphics.draw(v.image, v.x + 64, v.y + 64, v.r, v.sx, v.sy, v.image:getWidth()/2, v.image:getHeight()/2)
			end
		end)
	end
	
	turret.gunSetN = 1
	turret.guns = turret.gunSet[1]
end

function turret.update(dt)
	local mousex = love.mouse.getX()
	local mousey = love.mouse.getY()
	
	local mouseAngle = math.angle( 640, mousey, mousex, 360 )
	turret.angle = mouseAngle
	
	local mousel, mouser = love.mouse.isDown("l"), love.mouse.isDown("r")
	local curtime = love.timer.getTime()
	for k,v in ipairs(turret.guns) do
		if v.ammo > 0 or v.ammo == -1 then
			if v.fireType == "full" and curtime>v.nextFire then
				if v.slot==1 and mousel then
					v.doFire(v)
				elseif v.slot==2 and mouser then
					v.doFire(v)
				end
			end
		end
	end
	
	for k,set in pairs(turret.gunSet) do
		for i,v in ipairs(set) do
			if v.ammo < 1 and v.ammo ~= -1 then
				if not v.reloading then
					v.reload(v)
				else
					v.doReload(v)
				end
			end
		end
	end
end

function turret.keypressed(k)
	if tonumber(k) and tonumber(k) < #turret.gunSet+1 then
		turret.guns = turret.gunSet[tonumber(k)]
		turret.gunSetN = tonumber(k)
	elseif k=="x" then
		for k,v in pairs(turret.guns) do
			if v.slot == 3 then
				v.doFire(v)
			end
		end
	end
end

function turret.mousepressed(x, y, button) 
	if button == "wd" then
		turret.gunSetN = turret.gunSetN + 1
		if turret.gunSetN > #turret.gunSet then
			turret.gunSetN = 1
		end
		turret.guns = turret.gunSet[turret.gunSetN]
	elseif button == "wu" then
		turret.gunSetN = turret.gunSetN - 1
		if turret.gunSetN < 1 then
			turret.gunSetN = #turret.gunSet
		end
		turret.guns = turret.gunSet[turret.gunSetN]
	else
		for k,v in ipairs(turret.guns) do
			if v.fireType == "semi" then
				if v.slot==1 and button=="l" then
					v.doFire(v)
				elseif v.slot==2 and button=="r" then
					v.doFire(v)
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

function turret.draw()
	local height = love.window.getHeight()
	local width = love.window.getWidth()
	love.graphics.setColor(255,255,255,255)
	
	if not _G.DEBUG then
		love.graphics.draw( turret.turretBase, 0, 0, 0, 1, 1, turret.turretBase:getWidth()/2, turret.turretBase:getHeight()/2)
		love.graphics.draw( turret.guns.canvas, 0, 0, turret.angle, 1, 1, 64, 64)
	else
		love.graphics.setFont(_G.DEBUG_FONT)
		love.graphics.setShader(mask_effect)
		love.graphics.draw( turret.turretBase, 0, 0, 0, 1, 1, turret.turretBase:getWidth()/2, turret.turretBase:getHeight()/2)
		
		--hull
		love.graphics.setColor(100,100,100,255)
		local x = math.cos( turret.angle )*(turret.hull.x) - math.sin( turret.angle )*(turret.hull.y)
		local y = math.sin( turret.angle )*(turret.hull.x) + math.cos( turret.angle )*(turret.hull.y)
		love.graphics.draw(turret.turretHull, x, y, turret.hull.angle+turret.angle, 1, 1, turret.turretHull:getWidth()/2, turret.turretHull:getHeight()/2)
		
		--loop guns
		for k,v in ipairs(turret.guns) do
		
			--gun texture
			x = math.cos( turret.angle )*(v.x) - math.sin( turret.angle )*(v.y)
			y = math.sin( turret.angle )*(v.x) + math.cos( turret.angle )*(v.y)
			love.graphics.setColor(0,255,0,150)
			love.graphics.draw(v.image, x, y, turret.angle+v.r, v.sx,v.sy,v.image:getWidth()/2, v.image:getHeight()/2)
			
			--origin
			love.graphics.setColor(255,0,0,150)
			love.graphics.rectangle("fill", x-2, y-2, 4, 4)
			
			love.graphics.setShader()
			love.graphics.print(v.name, x, y)
			love.graphics.setShader(mask_effect)
			
			--muzzle
			x = math.cos( turret.angle )*(v.x) - math.sin( turret.angle )*(-v.image:getHeight()/2 + v.y)
			y = math.sin( turret.angle )*(v.x) + math.cos( turret.angle )*(-v.image:getHeight()/2 + v.y)
			love.graphics.setColor(0,0,255,150)
			love.graphics.rectangle("fill", x-2, y-2, 4, 4)
			
		end
		love.graphics.setShader()
		love.graphics.setColor(255,255,255,255)
	end
end

return turret