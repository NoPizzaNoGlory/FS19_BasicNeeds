BasicNeeds = {
	VERSION = 190717,
	configFile = nil,
	color = {
		normal = {1.0, 1.0, 1.0, 1.0},
		warning = {1.0, 1.0, 0.0, 1.0},
		urgent = {1.0, 0.0, 0.0, 1.0}
	},
	pos = {0.86, 0.90},
	stringLength = 40,
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
		restingMinutes = 0
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
	setXMLFloat(xml, "BasicNeeds.player.mealsLeft", BasicNeeds.player.mealsLeft);
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
	
	--respect settings for other mods
	setTextAlignment(0);
	setTextColor(1, 1, 1, 1);
	setTextBold(false);
end

function BasicNeeds:drawText()
	setTextAlignment(RenderText.ALIGN_LEFT);

	renderOverlay(BasicNeeds.batteryOL, BasicNeeds.pos[1] - 0.015, BasicNeeds.pos[2] - 0.006, 0.012, 0.022);
	renderText(BasicNeeds.pos[1], BasicNeeds.pos[2], BasicNeeds.font.size, string.format("%02d", BasicNeeds.player.energyLevel));
	
	renderOverlay(BasicNeeds.foodOL, BasicNeeds.pos[1] + 0.02, BasicNeeds.pos[2] - 0.006, 0.012, 0.022);
	renderText(BasicNeeds.pos[1] + 0.035, BasicNeeds.pos[2], BasicNeeds.font.size, "" .. BasicNeeds.player.mealsLeft);
	
end

function BasicNeeds:updateEnergyLevel()

	-- Skip while player is eating
	if BasicNeeds.player.isEating then
		return;
	end

	-- driving uses more energy than other activities
	if BasicNeeds.player.isDriving then
		BasicNeeds.player.energyLevel = BasicNeeds.player.energyLevel - 0.3;
	else	
		BasicNeeds.player.energyLevel = BasicNeeds.player.energyLevel - 0.15;
	end

	-- prevent going below 0
	if BasicNeeds.player.energyLevel < 0 then
		BasicNeeds.player.energyLevel = 0;
	end	
end

function BasicNeeds:haveMeal()
	if BasicNeeds.player.mealsLeft > 0 then
		BasicNeeds.player.mealsLeft = BasicNeeds.player.mealsLeft - 1;
		BasicNeeds.player.energyLevel = BasicNeeds.player.energyLevel + 20;
		
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
			BasicNeeds.player.isEatingMinutesLeft = 30;
			g_currentMission:setTimeScale(600);
		else
			if BasicNeeds.player.isEatingMinutesLeft <= 0 then
				g_currentMission:setTimeScale(1);
				BasicNeeds.player.isEating = false;
				BasicNeeds.player.isEatingMinutesLeft = nil;
			end
		end
		
		-- called every in-game minute, so substract one
		BasicNeeds.player.isEatingMinutesLeft = BasicNeeds.player.isEatingMinutesLeft - 1;
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
			
			-- regain some energy (we assume 7 hours of "sleep" gets you back to 100%)
			BasicNeeds.player.energyLevel = BasicNeeds.player.energyLevel + 15;
		
			-- don't go over 100% though
			if BasicNeeds.player.energyLevel > 100 then
				BasicNeeds.player.energyLevel = 100;
			end					
		end
	-- player is not resting, so reset counter to 0
	else
		BasicNeeds.player.restingMinutes = 0;
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
			
			if BasicNeeds.player.isEating then
				setTextAlignment(RenderText.ALIGN_CENTER);
				-- renderText(0.5, 0.5, BasicNeeds.font.size * 3, "Enjoying some great food. Please wait for you to finish your meal.");
				renderText(0.5, 0.5, BasicNeeds.font.size * 3, g_i18n:getText("ingameNotification_havingMeal"));
			else
				setTextAlignment(RenderText.ALIGN_CENTER);
				-- renderText(0.5, 0.5, BasicNeeds.font.size * 3, "You are too tired to drive. Rest (don't drive) for at least 1 hour or have some food.");
				renderText(0.5, 0.5, BasicNeeds.font.size * 3, g_i18n:getText("ingameNotification_tooTiredToDrive"));
			end
		end
	else
		-- not driving (or engine off)
		BasicNeeds.player.isDriving = false;
	end
end

function BasicNeeds:dayChanged()
	-- new day, so 3 new meals
	BasicNeeds.player.mealsLeft = 3;
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