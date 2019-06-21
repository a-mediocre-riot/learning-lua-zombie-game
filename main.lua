--[[
Button Clicking Game
Created for "Lua Programming and Game Development with LOVE" course on Udemy.
Additional features and improvements made by Gina Ribniscky.

Udemy Course: https://www.udemy.com/lua-love/
]]

function love.load()
	constants = {};
	constants.GAME_STATE_MAIN_MENU = 1;
	constants.GAME_STATE_RUNNING = 2;
	constants.FONT_SIZE = 40;
	constants.FONT = love.graphics.newFont(constants.FONT_SIZE);

	constants.keybinds = {};
	constants.keybinds.MOVE_UP = "w";
	constants.keybinds.MOVE_DOWN = "s";
	constants.keybinds.MOVE_LEFT = "a";
	constants.keybinds.MOVE_RIGHT = "d";

	defaults = {};
	defaults.PLAYER_X = love.graphics.getWidth() / 2;
	defaults.PLAYER_Y = love.graphics.getHeight() / 2;
	defaults.PLAYER_SPEED = 180;

	sprites = {};
	sprites.player = love.graphics.newImage("sprites/player.png");
	sprites.bullet = love.graphics.newImage("sprites/bullet.png");
	sprites.zombie = love.graphics.newImage("sprites/zombie.png");
	sprites.background = love.graphics.newImage("sprites/background.png");

	player = {};
	player.x = defaults.PLAYER_X;
	player.y = defaults.PLAYER_Y;
	player.offsetX = sprites.player:getWidth() / 2;
	player.offsetY = sprites.player:getHeight() / 2;
	player.speed = defaults.PLAYER_SPEED;

	zombies = {};
	bullets = {};

	gameState = constants.GAME_STATE_MAIN_MENU;
	maxTime = 2;
	timer = maxTime;
	score = 0;
end

function love.update(dt)
	if gameState == constants.GAME_STATE_RUNNING then
		if love.keyboard.isDown(constants.keybinds.MOVE_DOWN) and player.y < love.graphics.getHeight() then
			player.y = player.y + player.speed * dt;
		end

		if love.keyboard.isDown(constants.keybinds.MOVE_UP) and player.y > 0 then
			player.y = player.y - player.speed * dt;
		end

		if love.keyboard.isDown(constants.keybinds.MOVE_LEFT) and player.x > 0 then
			player.x = player.x - player.speed * dt;
		end

		if love.keyboard.isDown(constants.keybinds.MOVE_RIGHT) and player.x < love.graphics.getWidth() then
			player.x = player.x + player.speed * dt;
		end
	end

	for i, z in ipairs(zombies) do
		z.x = z.x + math.cos(zombiePlayerAngle(z)) * z.speed * dt;
		z.y = z.y + math.sin(zombiePlayerAngle(z)) * z.speed * dt;

		if distanceBetween(z.x, z.y, player.x, player.y) < 30 then
			for i, z in ipairs(zombies) do
				zombies[i] = nil;
				gameState = constants.GAME_STATE_MAIN_MENU;
				player.x = love.graphics.getWidth() / 2;
				player.y = love.graphics.getHeight() / 2;
			end
		end
	end

	for i, b in ipairs(bullets) do
		b.x = b.x + math.cos(b.direction) * b.speed * dt;
		b.y = b.y + math.sin(b.direction) * b.speed * dt;
	end

	for i=#bullets, 1, -1 do
		local b = bullets[i];

		if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
			table.remove(bullets, i);
		end
	end

	for i,z in ipairs(zombies) do
		for j,b in ipairs(bullets) do
			if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
				z.dead = true;
				b.dead = true;
				score = score + 1;
			end
		end
	end

	for i=#zombies, 1, -1 do
		local z = zombies[i];

		if z.dead == true then
			table.remove(zombies, i);
		end
	end

	for i=#bullets, 1, -1 do
		local b = bullets[i];

		if b.dead == true then
			table.remove(bullets, i);
		end
	end

	if gameState == constants.GAME_STATE_RUNNING then
		timer = timer - dt;
		if timer <= 0 then
			spawnZombie();
			maxTime = maxTime * 0.95;
			timer = maxTime;
		end
	end
end

function love.draw()
	love.graphics.draw(sprites.background, 0, 0);
	love.graphics.setFont(constants.FONT);

	if gameState == constants.GAME_STATE_MAIN_MENU then
		love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center");
	end

	love.graphics.printf("Score: " .. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center");

	love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(), nil, nil, player.offsetX, player.offsetY);

	for i, z in ipairs(zombies) do
		love.graphics.draw(sprites.zombie, z.x, z.y, zombiePlayerAngle(z), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2);
	end

	for i, b in ipairs(bullets) do
		love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5, 0.5, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2);
	end
end

function playerMouseAngle()
	return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi;
end

function zombiePlayerAngle(enemy)
	return math.atan2(player.y - enemy.y, player.x - enemy.x);
end

function distanceBetween(x1, y1, x2, y2)
	return math.sqrt((y2-y1)^2 + (x2-x1)^2);
end

function spawnZombie()
	zombie = {};
	zombie.x = 0;
	zombie.y = 0;
	zombie.speed = 100;
	zombie.dead = false;

	local side = math.random(1, 4);

	if side == 1 then
		zombie.x = -30;
		zombie.y = math.random(0, love.graphics.getHeight());
	elseif side == 2 then
		zombie.x = math.random(0, love.graphics.getWidth());
		zombie.y = -30;
	elseif side == 3 then
		zombie.x = love.graphics.getWidth() + 30;
		zombie.y = math.random(0, love.graphics.getHeight());
	else
		zombie.x = math.random(0, love.graphics.getWidth());
		zombie.y = love.graphics.getHeight() + 30;
	end

	table.insert(zombies, zombie);
end

function spawnBullet()
	bullet = {};
	bullet.x = player.x;
	bullet.y = player.y;
	bullet.speed = 500;
	bullet.direction = playerMouseAngle();
	bullet.dead = false;

	table.insert(bullets, bullet);
end

function love.mousepressed(x, y, b, istouch)
	if b == 1 and gameState == constants.GAME_STATE_RUNNING then
		spawnBullet();
	end

	if gameState == constants.GAME_STATE_MAIN_MENU then
		gameState = 2;
		maxTime = 2;
		score = 0;
	end
end
