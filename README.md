# Farming Simulator 19: Basic Needs mod
Basic Needs for your farmer in FS19. Sleep and eat or you won't be able to work!

## How does this mod work?
This mod gives your farmer an energy level he has to deal with. Just like everyone has in real life. No longer can you just drive vehicles all day. Instead you'll have to take regular breaks and eat some food every now and then. Because if you don't, you'll no longer be able to drive anything! So plan your (food) breaks ahead of time!

## So what are the rules here?
- You get 3 meals per day (reset every night at 00:00)
- Driving a vehicle (engine on) takes double the amount of energy of walking
- Walking is also considered resting though
- To rest you need to be outside an active vehicle for at least 1 in-game hour
- Every in-game hour of resting ups your energy bar a little again
- About 7 hours of resting should get you back up to 100% (so sleeping works great ;-))
- Every meal you take (remember, max 3 per day!) ups your energy bar a little as well
- Every meal does take 30 minutes to complete (time is fast forwarded automatically)
- Energy down to 0? You can no longer move any vehicle. Take a break and/or eat something!

## Is this for multi-player?
No. I wrote this mod for role playing in single player. I might look at making it multi-player compatible in the future, but no promises.

## What if I want different values (meals per day, energy costs, etc)?
Simply change the BasicNeeds.xml file in your savegame folder. It looks like this

```xml
<BasicNeeds VERSION="190718">
    <player>
        <energyLevel>65.949997</energyLevel> <!-- your current energy level -->
        <mealsLeft>0.000000</mealsLeft> <!-- amount of meals you have left for this day -->
    </player>
    <energy>
        <costPerMinute>0.150000</costPerMinute> <!-- subtracted from your energy level per in-game minute -->
        <costPerMinuteInVehicle>0.300000</costPerMinuteInVehicle> <!-- same as above, but while driving a vehicle -->
        <regainPerHourResting>15.000000</regainPerHourResting> <!-- what you get back per in-game hour for "resting" (= not driving) -->
    </energy>
    <meal>
        <perDay>3.000000</perDay> <!-- amount of meals you get every day at midnight -->
        <energy>10.000000</energy> <!-- amount of energy every meal gives you -->
        <durationInMinutes>30.000000</durationInMinutes> <!-- how long it takes to finish a meal (automatically fast forwarded) -->
    </meal>
</BasicNeeds>
```

Next time you load the game, these values will be used instead. Happy farming!
