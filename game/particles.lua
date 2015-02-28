
particles = {}

particles.particles = {}
particles.particles.explosionBig = {spin = {0, 0}, size_variation = 1, gravity = {0, 0}, radial_acc = {0, 0}, emission_rate = 1000, sizes = {0.7, 2.2}, lifetime = 0.1, speed = {0, 250}, spread = 360, offset = {50, 50}, buffer_size = 250, rotation = {0, 0}, colors = {{255, 0, 0, 255}, {255, 255, 0, 100}, {50, 50, 50, 100}, {50, 50, 50, 50}, {0, 0, 0, 1}}, tangent_acc = {0, 0}, direction = 360, spin_variation = 0.09, particle_life = {1, 1},}
particles.particles.explosionSmall = {spin = {0, 0}, size_variation = 1, gravity = {0, 0}, radial_acc = {0, 0}, emission_rate = 1000, sizes = {0.2, 1}, lifetime = 0.1, speed = {0, 140}, spread = 360, offset = {50, 50}, buffer_size = 250, rotation = {0, 0}, colors = {{255, 0, 0, 255}, {255, 255, 0, 100}, {50, 50, 50, 100}, {50, 50, 50, 50}, {0, 0, 0, 1}}, tangent_acc = {0, 0}, direction = 360, spin_variation = 0.09, particle_life = {1, 1},}


particles.systems = {}

function particles.createParticle( particlename, x, y )
	if particles.particles[particlename] then
		template = particles.particles[particlename]
		local sprite = love.graphics.newImage('sprites/particles/iku.png') 
        local ps = love.graphics.newParticleSystem(sprite, template.buffer_size)
        ps:setBufferSize(template.buffer_size)
        local colors = {}
        for i = 1, 8 do
            if template.colors[i] then
                table.insert(colors, template.colors[i][1])
                table.insert(colors, template.colors[i][2])
                table.insert(colors, template.colors[i][3])
                table.insert(colors, template.colors[i][4])
            end
        end
		local degToRad = math.rad
        ps:setColors(unpack(colors))
        ps:setDirection(degToRad(template.direction))
        ps:setEmissionRate(template.emission_rate)
        ps:setLinearAcceleration(template.gravity[1], template.gravity[2])
        ps:setEmitterLifetime(template.lifetime)
        ps:setOffset(template.offset[1], template.offset[2])
        ps:setParticleLifetime(template.particle_life[1], template.particle_life[2])
        ps:setRadialAcceleration(template.radial_acc[1], template.radial_acc[2])
        ps:setRotation(degToRad(template.rotation[1]), degToRad(template.rotation[2]))
        ps:setSizeVariation(template.size_variation)
        ps:setSizes(unpack(template.sizes))
        ps:setSpeed(template.speed[1], template.speed[2])
        ps:setSpin(degToRad(template.spin[1]), degToRad(template.spin[2]))
        ps:setSpinVariation(template.spin_variation)
        ps:setSpread(degToRad(template.spread))
        ps:setTangentialAcceleration(template.tangent_acc[1], template.tangent_acc[2])
		ps:setPosition(x,y)
        
		table.insert(particles.systems, ps)
		return particles.systems[#particles.systems]
	end
end

function particles.draw()
	for k,v in pairs(particles.systems) do
		love.graphics.draw( v, 0, 0 )
	end
end

function particles.update(dt)
	for k,v in pairs(particles.systems) do
		v:update(dt)
	end
end

return particles
	