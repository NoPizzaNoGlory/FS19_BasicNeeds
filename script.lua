BasicNeeds = {
	VERSION = 190719,
	configFile = nil,
	color = {
		normal = {1.0, 1.0, 1.0, 1.0},
		warning = {1.0, 1.0, 0.0, 1.0},
		urgent = {1.0, 0.0, 0.0, 1.0}
	},
	pos = {0.86, 0.90},
	font = {
		size = 0.014,
		line = 1.2
	},
	player = {
		energyLevel = 100.0,
		mealsLeft = 3,
		isDriving = false,
		isEating = false,
		isEatingMinutesLeft = nil,
		nextMealMinutes = 0,
		restingMinutes = 0,
		restingHours = 0
	},
	energy = {
		costPerMinute = 0.2,
		costPerMinuteInVehicle = 0.4,
		regainPerHourResting = 20
	},
	meal = {
		perDay = 3,
		energy = 14,
		durationInMinutes = 30,
		timeBetweenMealsInMinutes = 180
	},
	notifications = {
		notHungry = 0,
		eating = 0,
		tooTired = 0
	}
};

local modDir = g_currentModDirectory;

function BasicNeeds:loadMap(name)

	-- find config file in save game (if it has been saved already)
	BasicNeeds:getConfigFilePath();

	-- only load or save if we have an actual savegameDirectory
	if BasicNeeds.configFile ~= nil then
		if fileExists(BasicNeeds.configFile) then
			BasicNeeds:loadConfig();
		else
			BasicNeeds:saveConfig();
		end
	end	
		
	g_currentMission.environment:addDayChangeListener(BasicNeeds);
	g_currentMission.environment:addMinuteChangeListener(BasicNeeds);
	
	BasicNeeds.batteryOL = createImageOverlay(modDir .. "battery.png");
	BasicNeeds.foodOL = createImageOverlay(modDir .. "food2.png");
end

function BasicNeeds:getConfigFilePath()

	if g_currentMission.missionInfo.savegameDirectory == nil then
		print("SavegameDirectory empty, can't load or save config file!");
		return;
	end

	BasicNeeds.configFile = Utils.getFilename("BasicNeeds.xml", g_currentMission.missionInfo.savegameDirectory.."/");
	
	print("Using this config file: " .. BasicNeeds.configFile);
end

function BasicNeeds:loadConfig()

	print("Loading config" .. BasicNeeds.configFile);

	if BasicNeeds.configFile == nil then
		return;
	end
	local xml = loadXMLFile("BasicNeeds_XML", BasicNeeds.configFile, "BasicNeeds");
	local xmlVersion = Utils.getNoNil(getXMLInt(xml, "BasicNeeds#VERSION"), 0);
	if xmlVersion > 0 then
	
		-- get config values (compatible with older versions)
		if xmlVersion >= 190719 and xmlVersion <= BasicNeeds.VERSION then
			BasicNeeds.player.nextMealMinutes = Utils.getNoNil(getXMLFloat(xml, "BasicNeeds.player.nextMealMinutes"), BasicNeeds.player.nextMealMinutes);
			BasicNeeds.meal.timeBetweenMealsInMinutes = Utils.getNoNil(getXMLFloat(xml, "BasicNeeds.meal.timeBetweenMealsInMinutes"), BasicNeeds.meal.timeBetweenMealsInMinutes);
		end
		
		if xmlVersion >= 190718 and xmlVersion <= BasicNeeds.VERSION then
			BasicNeeds.energy.costPerMinute = Utils.getNoNil(getXMLFloat(xml, "BasicNeeds.energy.costPerMinute"), BasicNeeds.energy.costPerMinute);		
			BasicNeeds.energy.costPerMinuteInVehicle = Utils.getNoNil(getXMLFloat(xml, "BasicNeeds.energy.costPerMinuteInVehicle"), BasicNeeds.energy.costPerMinuteInVehicle);		
			BasicNeeds.energy.regainPerHourResting = Utils.getNoNil(getXMLFloat(xml, "BasicNeeds.energy.regainPerHourResting"), BasicNeeds.energy.regainPerHourResting);		

			BasicNeeds.meal.perDay = Utils.getNoNil(getXMLFloat(xml, "BasicNeeds.meal.perDay"), BasicNeeds.meal.perDay);		
			BasicNeeds.meal.energy = Utils.getNoNil(getXMLFloat(xml, "BasicNeeds.meal.energy"), BasicNeeds.meal.energy);		
			BasicNeeds.meal.durationInMinutes = Utils.getNoNil(getXMLFloat(xml, "BasicNeeds.meal.durationInMinutes"), BasicNeeds.meal.durationInMinutes);		
		end
	
		if xmlVersion >= 190717 and xmlVersion <= BasicNeeds.VERSION then
			BasicNeeds.player.energyLevel = Utils.getNoNil(getXMLFloat(xml, "BasicNeeds.player.energyLevel"), BasicNeeds.player.energyLevel);		
			BasicNeeds.player.mealsLeft = Utils.getNoNil(getXMLFloat(xml, "BasicNeeds.player.mealsLeft"), BasicNeeds.player.mealsLeft);		
		end
	end
	if delete ~= nil then
		delete(xml);
	end
	if xmlVersion ~= BasicNeeds.VERSION then
		BasicNeeds:saveConfig();
	end
	
end

function BasicNeeds:saveConfig()

	-- again as it might have been a new save game
	BasicNeeds:getConfigFilePath();

	if BasicNeeds.configFile == nil then
		return;
	end
	
	local xml = createXMLFile("BasicNeeds_XML", BasicNeeds.configFile, "BasicNeeds");
	setXMLInt(xml, "BasicNeeds#VERSION", BasicNeeds.VERSION);
	setXMLFloat(xml, "BasicNeeds.player.energyLevel", BasicNeeds.player.energyLevel);
	setXMLInt(xml, "BasicNeeds.player.mealsLeft", BasicNeeds.player.mealsLeft);
	
	-- added in version 190718
	setXMLFloat(xml, "BasicNeeds.energy.costPerMinute", BasicNeeds.energy.costPerMinute);
	setXMLFloat(xml, "BasicNeeds.energy.costPerMinuteInVehicle", BasicNeeds.energy.costPerMinuteInVehicle);
	setXMLFloat(xml, "BasicNeeds.energy.regainPerHourResting", BasicNeeds.energy.regainPerHourResting);
	setXMLInt(xml, "BasicNeeds.meal.perDay", BasicNeeds.meal.perDay);
	setXMLFloat(xml, "BasicNeeds.meal.energy", BasicNeeds.meal.energy);
	setXMLInt(xml, "BasicNeeds.meal.durationInMinutes", BasicNeeds.meal.durationInMinutes);
	
	-- added in version 190719
	setXMLInt(xml, "BasicNeeds.player.nextMealMinutes", BasicNeeds.player.nextMealMinutes);
	setXMLInt(xml, "BasicNeeds.meal.timeBetweenMealsInMinutes", BasicNeeds.meal.timeBetweenMealsInMinutes);
	
	saveXMLFile(xml);
	if delete ~= nil then
		delete(xml);
	end
end

function BasicNeeds:mouseEvent(posX, posY, isDown, isUp, button)
end

function BasicNeeds:keyEvent(unicode, sym, modifier, isDown)	
end

function BasicNeeds:update(dt)
end

function BasicNeeds:registerActionEvents()
	local r2, eventName1 = g_inputBinding:registerActionEvent('BasicNeeds_reload_xml', self, BasicNeeds.actionReloadXML, false, true, false, true)
	g_inputBinding.events[eventName1].displayIsVisible = false;
	local r2, eventName2 = g_inputBinding:registerActionEvent('BasicNeeds_have_meal', self, BasicNeeds.actionHaveMeal, false, true, false, true)
	g_inputBinding.events[eventName2].displayIsVisible = false;	
end

function BasicNeeds.registerEventListeners(vehicleType)	
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", BasicNeeds);
end

function BasicNeeds:actionReloadXML()
	BasicNeeds:loadConfig();
end

function BasicNeeds:actionHaveMeal()
	BasicNeeds:haveMeal();
end

function BasicNeeds:draw(dt)
	if not g_currentMission.isLoaded or g_currentMission.player == nil then
		return;
	end

	BasicNeeds:drawText();
	
	BasicNeeds:showNotifcations();
	
	--respect settings for other mods
	setTextAlignment(0);
	setTextColor(1, 1, 1, 1);
	setTextBold(false);
end

function BasicNeeds:drawText()
	setTextAlignment(RenderText.ALIGN_LEFT);
	setTextBold(false);
	
	renderOverlay(BasicNeeds.batteryOL, BasicNeeds.pos[1] - 0.015, BasicNeeds.pos[2] - 0.006, 0.012, 0.022);
	renderOverlay(BasicNeeds.foodOL, BasicNeeds.pos[1] + 0.02, BasicNeeds.pos[2] - 0.006, 0.012, 0.022);
	
	setTextColor(1, 1, 1, 1);
	if BasicNeeds.player.energyLevel < 30 then
		setTextColor(unpack(BasicNeeds.color.warning));
	end
	if BasicNeeds.player.energyLevel < 10 then
		setTextColor(unpack(BasicNeeds.color.urgent));
	end
	renderText(BasicNeeds.pos[1], BasicNeeds.pos[2], BasicNeeds.font.size, string.format("%d", BasicNeeds.player.energyLevel) .. "%");
	
	setTextColor(1, 1, 1, 1);
	renderText(BasicNeeds.pos[1] + 0.035, BasicNeeds.pos[2], BasicNeeds.font.size, "" .. BasicNeeds.player.mealsLeft);
end

function BasicNeeds:showNotifcations()
	if BasicNeeds.notifications.notHungry > 0 then
		BasicNeeds:drawNotifcation("ingameNotification_notHungry");
		BasicNeeds.notifications.notHungry = BasicNeeds.notifications.notHungry - 1;
	elseif BasicNeeds.notifications.eating > 0 then
		BasicNeeds:drawNotifcation("ingameNotification_havingMeal");
		BasicNeeds.notifications.eating = BasicNeeds.notifications.eating - 1;
	elseif BasicNeeds.notifications.tooTired > 0 then
		BasicNeeds:drawNotifcation("ingameNotification_tooTiredToDrive");
		BasicNeeds.notifications.tooTired = BasicNeeds.notifications.tooTired - 1;
	end
end

function BasicNeeds:drawNotifcation(message)
	setTextBold(false);
	setTextAlignment(RenderText.ALIGN_CENTER);
	renderText(0.5, 0.5, BasicNeeds.font.size * 3, g_i18n:getText(message));
end

function BasicNeeds:updateEnergyLevel()

	-- Skip while player is eating
	if BasicNeeds.player.isEating then
		return;
	end

	-- driving uses more energy than other activities
	if BasicNeeds.player.isDriving then
		BasicNeeds.player.energyLevel = BasicNeeds.player.energyLevel - BasicNeeds.energy.costPerMinuteInVehicle;
	else	
		BasicNeeds.player.energyLevel = BasicNeeds.player.energyLevel - BasicNeeds.energy.costPerMinute;
	end

	-- prevent going below 0
	if BasicNeeds.player.energyLevel < 0 then
		BasicNeeds.player.energyLevel = 0;
	end	
end

function BasicNeeds:haveMeal()

	if BasicNeeds.player.nextMealMinutes > 0 then
		BasicNeeds.notifications.notHungry = 120;
		return;
	end

	if BasicNeeds.player.mealsLeft > 0 then
		BasicNeeds.player.nextMealMinutes = BasicNeeds.meal.timeBetweenMealsInMinutes;
		BasicNeeds.player.mealsLeft = BasicNeeds.player.mealsLeft - 1;
		BasicNeeds.player.energyLevel = BasicNeeds.player.energyLevel + BasicNeeds.meal.energy;
		
		BasicNeeds.notifications.eating = 120;
				
		-- energy can't go over 100
		if BasicNeeds.player.energyLevel > 100 then
			BasicNeeds.player.energyLevel = 100;
		end
		
		BasicNeeds.player.isEating = true;
		
		-- speed up time for the next 30 minutes while the player is eating his meal
		BasicNeeds:handleEating();
	end	
end

function BasicNeeds:handleEating()
	if BasicNeeds.player.isEating == true then
		
		if BasicNeeds.player.isEatingMinutesLeft == nil then
			BasicNeeds.player.isEatingMinutesLeft = BasicNeeds.meal.durationInMinutes;
			g_currentMission:setTimeScale(600);			
		else
			if BasicNeeds.player.isEatingMinutesLeft <= 0 then
				g_currentMission:setTimeScale(1);
				BasicNeeds.player.isEating = false;
				BasicNeeds.player.isEatingMinutesLeft = nil;
				return;
			end
		end
		
		-- called every in-game minute, so substract one
		BasicNeeds.player.isEatingMinutesLeft = BasicNeeds.player.isEatingMinutesLeft - 1;
	else
		BasicNeeds.player.nextMealMinutes = BasicNeeds.player.nextMealMinutes - 1;
	end
end

-- called every minute, ups energy level after resting for every whole hour
function BasicNeeds.handleResting()
	-- player is resting (not driving) in this minute
	if BasicNeeds.player.isDriving == false then
		BasicNeeds.player.restingMinutes = BasicNeeds.player.restingMinutes + 1;
		if BasicNeeds.player.restingMinutes >= 60 then
			-- new hour, so back to 0 for the next one
			BasicNeeds.player.restingMinutes = 0;
			BasicNeeds.player.restingHours = BasicNeeds.player.restingHours + 1;
			
			-- regain some energy every full resting hour
			BasicNeeds.player.energyLevel = BasicNeeds.player.energyLevel + BasicNeeds.energy.regainPerHourResting;
			
			-- did we sleep for 7 hours without interuption? Then set energy to 100%
			if BasicNeeds.player.restingHours >= 7 then
				BasicNeeds.player.energyLevel = 100;
			end
		
			-- don't go over 100% though
			if BasicNeeds.player.energyLevel > 100 then
				BasicNeeds.player.energyLevel = 100;
			end					
		end
	-- player is not resting, so reset counters to 0
	else
		BasicNeeds.player.restingMinutes = 0;
		BasicNeeds.player.restingHours = 0;
	end
end

-- vehicle onUpdate event
function BasicNeeds:onUpdate(dt)
	if self.spec_enterable.isEntered and self.spec_drivable.isActive then
		
		-- we are driving a vehicle
		BasicNeeds.player.isDriving = true;
				
		-- stop vehicle when player is too tired to drive or is eating his meal
		if BasicNeeds.player.energyLevel == 0 or BasicNeeds.player.isEating then
			self:setBrakeLightsVisibility(true);
    
			for k, wheel in pairs(self:getWheels()) do
				setWheelShapeProps(wheel.node, wheel.wheelShape, 0, 999, wheel.steeringAngle, wheel.rotationDamping)
			end
			
			if BasicNeeds.player.isEating == false then
				BasicNeeds.notifications.tooTired = 10;
			end
		end
	else
		-- not driving (or engine off)
		BasicNeeds.player.isDriving = false;
	end
end

function BasicNeeds:dayChanged()
	-- new day, so 3 new meals
	BasicNeeds.player.mealsLeft = BasicNeeds.meal.perDay;
end

function BasicNeeds:minuteChanged()
	-- update energy level every in-game minute
	BasicNeeds.updateEnergyLevel();
	
	-- handle eating every in-game minute
	BasicNeeds.handleEating();
	
	-- handle resting
	BasicNeeds.handleResting();
end

if g_client ~= nil then
	-- client side mod only
	addModEventListener(BasicNeeds);
	FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, BasicNeeds.registerActionEvents);	
	AIVehicle.registerEventListeners = Utils.appendedFunction(AIVehicle.registerEventListeners, BasicNeeds.registerEventListeners);
	FSCareerMissionInfo.saveToXMLFile = Utils.appendedFunction(FSCareerMissionInfo.saveToXMLFile, BasicNeeds.saveConfig);
end