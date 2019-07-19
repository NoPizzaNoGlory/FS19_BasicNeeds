# Farming Simulator 19: Basic Needs mod
Basic Needs for your farmer in FS19. Sleep and eat or you won't be able to work!

## How does this mod work?
This mod gives your farmer an energy level he has to deal with. Just like everyone has in real life. No longer can you just drive vehicles all day. Instead you'll have to take regular breaks and eat some food every now and then. Because if you don't, you'll no longer be able to drive anything! So plan your (food) breaks ahead of time!

## So what are the rules here?
- You get 3 meals per day (reset every night at 00:00)
- Driving a vehicle (engine on) takes more energy than walking
- To rest you need to be outside an active vehicle for at least 1 whole in-game hour (or have the engine off)
- Resting ups your energy bar a little again
- 7 hours of uninterupted resting resets your energy level back to 100% (considered a good night's sleep)
- Every meal you take (remember, max 3 per day!) ups your energy bar a little as well
- Every meal does take 30 minutes to complete (time is fast forwarded automatically)
- You can only take meals every 3 hours
- Energy down to 0? You can no longer move any vehicle. Take a break and/or eat something!

## How do I take a meal?
The default hotkey is left ctrl + e, but you can change that to something else in the game settings.

## Why can I not take a meal again?
You have to wait for at least 3 hours before you can take another meal. Gotta be hungry again first. :-)

## Is this for multi-player?
No. I wrote this mod for role playing in single player. I might look at making it multi-player compatible in the future, but no promises. There are several things that are hard to implement on multi-player, like the sleeping part. You really don't want to fast forward time because you have to sleep, while someone else is driving a vehicle (which would drain their energy real quick).

## What if I want different values (meals per day, energy costs, etc)?
Simply change the BasicNeeds.xml file in your savegame folder. It looks like this

```xml
<BasicNeeds VERSION="190718">
    <player>
        <energyLevel>65.949997</energyLevel> <!-- your current energy level -->
        <mealsLeft>0.000000</mealsLeft> <!-- amount of meals you have left for this day -->
		<nextMealMinutes>180</nextMealMinutes> <!-- how long until you can have your next meal? -->
    </player>
    <energy>
        <costPerMinute>0.200000</costPerMinute> <!-- subtracted from your energy level per in-game minute -->
        <costPerMinuteInVehicle>0.400000</costPerMinuteInVehicle> <!-- same as above, but while driving a vehicle -->
        <regainPerHourResting>20.000000</regainPerHourResting> <!-- what you get back per in-game hour for "resting" (= not driving) -->
    </energy>
    <meal>
        <perDay>3.000000</perDay> <!-- amount of meals you get every day at midnight -->
        <energy>14.000000</energy> <!-- amount of energy every meal gives you -->
        <durationInMinutes>30.000000</durationInMinutes> <!-- how long it takes to finish a meal (automatically fast forwarded) -->
		<timeBetweenMealsInMinutes>180.000000</timeBetweenMealsInMinutes> <!-- minimum required time in minutes between meals (3 hours here) -->
    </meal>
</BasicNeeds>
```

Next time you load the game, these values will be used instead. Happy farming!
