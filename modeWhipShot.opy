#!mainFile "main.opy"

subroutine createWhipShotBots

playervar forwardBackState
playervar leftRightEnabled

rule "Whip Shot mode setup":
    @Condition gameState == GS_WHIP_SHOT
    player.teleport(vect(0,0,0))
    player.setFacing(vect(1,0,0), Relativity.TO_WORLD)
    player.setPrimaryFireEnabled(false)
    player.setSecondaryFireEnabled(false)
    player.setAbility1Enabled(true)
    player.setAbility2Enabled(false)
    createWhipShotBots()
    modeActive = true

rule "Cleanup whip shot mode":
    @Condition gameState != GS_WHIP_SHOT
    player.setPrimaryFireEnabled(true)
    player.setSecondaryFireEnabled(true)
    player.setAbility1Enabled(true)
    player.setAbility2Enabled(true)
    destroyAllDummies()

def createWhipShotBots():
    createDummy(Hero.TRACER, Team.2, -1, vect(10,0.5,random.uniform(-5,5)), vect(-1, 0, 0))
    wait(0.1)
    createDummy(Hero.ROADHOG, Team.2, -1, vect(10,0.5,random.uniform(-5,5)), vect(-1, 0, 0))
    wait(0.1)
    createDummy(Hero.PHARAH, Team.2, -1, vect(10,0.5,random.uniform(-5,5)), vect(-1, 0, 0))
    wait(0.1)
    createDummy(Hero.MCCREE, Team.2, -1, vect(10,0.5,random.uniform(-5,5)), vect(-1, 0, 0))

rule "Handle Bot Creation/Respawn":
    @Event eachPlayer
    isModeActive("GS_WHIP_SHOT")
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.isAlive()
    eventPlayer.teleport(vect(10, 0.5, random.uniform(-8,8)))
    eventPlayer.setFacing(vect(-1, 0, 0), Relativity.TO_WORLD)

rule "Instantly respawn dummy bots":
    @Event playerDied
    isModeActive("GS_WHIP_SHOT")
    @Condition victim.isDummy()
    wait()
    victim.respawn()

rule "Recharge Whip Shot instantly":
    @Event eachPlayer
    @Team 1
    @Hero brigitte
    isModeActive("GS_WHIP_SHOT")
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_1) > 0
    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)

rule "If Real Player hits dummy bot, give feedback":
    @Event playerDealtDamage
    isModeActive("GS_WHIP_SHOT")
    @Condition not attacker.isDummy()
    kill(victim, attacker)
    playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.YELLOW, victim, 0.8)
    playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, attacker, 200)
    
rule "move all bots":
    @Event eachPlayer
    isModeActive("GS_WHIP_SHOT")
    @Condition eventPlayer.isDummy()
    do:
        #Set back/forward movement
        eventPlayer.forwardBackState = (1 if random.randint(0,15) > eventPlayer.getPosition().x else -1) if random.randint(0,4) > 0 else 0
        #Set left/right movement
        eventPlayer.leftRightEnabled = random.randint(0,4)
        #Move left?
        if random.uniform(-15, 15) >= eventPlayer.getPosition().z:
            eventPlayer.startThrottleInDirection(vect(eventPlayer.forwardBackState, 0, 1 if eventPlayer.leftRightEnabled > 0 else 0), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
        #Move right?
        else:
            eventPlayer.startThrottleInDirection(vect(eventPlayer.forwardBackState, 0, -1 if eventPlayer.leftRightEnabled > 0 else 0), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
        wait(random.uniform(0.1, 0.9))
    while RULE_CONDITION

rule "hover for pharah bot":
    @Event eachPlayer
    isModeActive("GS_WHIP_SHOT")
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.isAlive()
    @Condition eventPlayer.getCurrentHero() == Hero.PHARAH
    do:
        #If too low to ground, start holding space
        if random.uniform(2, 17) > eventPlayer.getPosition().y:
            eventPlayer.startForcingButton(Button.JUMP)
        else:
            eventPlayer.stopForcingButton(Button.JUMP)
        wait(random.uniform(0.1, 0.5)) 
    while RULE_CONDITION

rule "jump jet for pharah bot":
    @Event eachPlayer
    isModeActive("GS_WHIP_SHOT")
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.isAlive()
    @Condition eventPlayer.getCurrentHero() == Hero.PHARAH
    @Condition eventPlayer.isOnGround() or eventPlayer.getPosition().y < 2
    do:
        eventPlayer.startForcingButton(Button.ABILITY_1)
        wait(0.1)
    while RULE_CONDITION
    eventPlayer.stopForcingButton(Button.ABILITY_1)

rule "tracer blinks :)":
    @Event eachPlayer
    isModeActive("GS_WHIP_SHOT")
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.isAlive()
    @Condition eventPlayer.getCurrentHero() == Hero.TRACER
    do:
        wait(random.uniform(0.7,3))
        eventPlayer.forceButtonPress(Button.ABILITY_1)
    while RULE_CONDITION

rule "mccree rolls":
    @Event eachPlayer
    isModeActive("GS_WHIP_SHOT")
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.isAlive()
    @Condition eventPlayer.getCurrentHero() == Hero.MCCREE
    do:
        wait(random.uniform(2,4))
        eventPlayer.forceButtonPress(Button.ABILITY_1)
    while RULE_CONDITION