
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
function math.angle(x1,y1, x2,y2) return math.atan2(x2-x1, y2-y1) end
function math.inRect(x1,y1, x2,y2,w,h) return not (x1 < x2 or x1 > x2+w or y1 < y2 or y1 > y2+h) end

require 'slam'
bullet 		= require 'bullet'
turret 		= require 'turret'
tank 		= require 'tank'
particles 	= require 'particles'
wall 		= require 'wall'

score = 0
isPlaying = true
isPaused = false
function love.load()
	font_plain = love.graphics.newFont(24)
	
	bullet.load()
	turret.load()
	tank.load()
	wall.load()
	
	explSoundB = love.audio.newSource("sounds/explosion.wav")
	explSoundB:setVolume(0.2)
	explSoundB:setPitch(1.5)
	
	explSoundS = love.audio.newSource("sounds/explosion.wav")
	explSoundS:setVolume(0.1)
	explSoundS:setPitch(2)
	
	grassSprite = love.graphics.newImage("sprites/grass.png")
	grassSprite:setWrap( "repeat", "repeat" )
	
	local height = love.window.getHeight()
	local width = love.window.getWidth()
	quad = love.graphics.newQuad( 0, 0, width, height, 256, 256 )

	love.graphics.setColor(255,255,255,255)
	love.graphics.setBackgroundColor(0,0,0)
end

function love.update(dt)
	if isPlaying and not isPaused then
		bullet.update(dt)
		turret.update(dt)
		tank.update(dt)
		particles.update(dt)
		wall.update(dt)
	end
end

function gameOver()
	isPlaying = false
end

function gameStart()
	tank.tanks = {}
	bullet.bullets = {}
	wall.walls = {}
	turret.guns = turret.gunSet[1]
	score = 0
	isPlaying = true
end

function explosion(hit, x, y, damage, big)
	if big then
		particles.createParticle("explosionBig", x, y)
		explSoundB:play()
	else
		particles.createParticle("explosionSmall", x, y)
		explSoundS:play()
	end
	
	for k,v in pairs(tank.tanks) do
		if math.dist(v.pos.x, v.pos.y, x, y) < damage then
			v.damage(v, damage)
		end
	end
end

function love.keypressed(k)
	if isPlaying then
		if not isPaused then turret.keypressed(k) end
		wall.keypressed(k)
		if k == "f3" then 
			_G.DEBUG = not _G.DEBUG
			if not _G.DEBUG_FONT then
				_G.DEBUG_FONT = love.graphics.newFont(12)
			end
		elseif k == "f4" then 
			isPaused = not isPaused
		end
	elseif k~="x" then
		gameStart()
	end
end

function love.mousepressed(x, y, button) 
	if isPlaying and not isPaused then
		turret.mousepressed(x,y,button)
	end
end


function love.draw()
	local height = love.window.getHeight()
	local width = love.window.getWidth()
	love.graphics.setColor(255,255,255,255)
	
	if isPlaying then
	
		love.graphics.draw( grassSprite, quad, 0, 0, 0)
		
		wall.draw()
		bullet.draw()
		tank.draw()
		
		love.graphics.push()
			love.graphics.translate(640,360)
			turret.draw()
		love.graphics.pop()
		
		particles.draw()
		
		love.graphics.setColor(255,255,255,255)
		love.graphics.setFont(font_plain)
		love.graphics.print("score: "..score,100,36)
		
		if _G.DEBUG then
			love.graphics.print("bullets: "..#bullet.bullets,100,60)
			love.graphics.print("tanks: "..#tank.tanks,100,80)
			love.graphics.print("tank health: "..(math.max(score/20 +0.5, 1) * 100),100,100)
			
			local y = 500
			love.graphics.setFont(_G.DEBUG_FONT)
			for i,set in pairs(turret.gunSet)do
			
				love.graphics.setColor(170,170,170,255)
				local selected = false
				if turret.gunSetN == i then
					selected = true
					love.graphics.setColor(255,0,0,255)
				end
				
				love.graphics.print("#"..i.." ("..#set..")",20,y)
				y = y + 12
				if not selected then love.graphics.setColor(255,255,255,255) end
				for k,gun in ipairs(set) do
					local slot = gun.slot==1 and "primary" or gun.slot==2 and "secondary" or "special"
					love.graphics.print(gun.name.."("..slot..") "..gun.ammo.."/"..gun.clip.." "..gun.damage.."x"..gun.bulletsPerShot.." "..gun.accuracy.." "..gun.projectile.." "..gun.fireType, 40, y)
					y = y + 12
				end
				y = y + 1
			end	
		end
	else
		love.graphics.setColor(255,255,255,255)
		love.graphics.setFont(font_plain)
		love.graphics.print("Your score was: "..score,100,36)
		love.graphics.print("Press any key to play again ",150,100)
	end
end