#!mainFile "main.opy"

globalvar enemySpawnPositions
globalvar diveRingEffect
globalvar currentDiveHero
globalvar currentDiveBot
globalvar diveInteractText

subroutine resetDiveMode

def resetDiveMode():
    destroyDummy(currentDiveBot.getTeam(), currentDiveBot.getSlot())
    modeActive = false
    currentDiveHero = null
    wait()
    hudHeader(getAllPlayers(), "Press interact ({0}) when ready".format(buttonString(Button.INTERACT)), HudPosition.TOP, 1, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    diveInteractText = getLastCreatedText()

rule "Dive denial mode setup":
    @Condition gameState == GS_DIVE_DENIAL
    player.teleport(diveModeCenter)
    player.setFacing(vect(1,0,0), Relativity.TO_WORLD)
    player.setPrimaryFireEnabled(true)
    player.setSecondaryFireEnabled(true)
    player.setAbility1Enabled(true)
    player.setAbility2Enabled(false)
    createEffect(getAllPlayers(), Effect.RING, Color.GREEN, diveModeCenter, 7.5, EffectReeval.VISIBILITY)
    diveRingEffect = getLastCreatedEntity()
    enemySpawnPositions = [vect(12.228, 7.935, -3.645), vect(16.075, 7.934, 2.513), vect(18.071, 4.926, 10.889), vect(11.717, 5.925, 18.921), vect(4.429, 4.925, 19.4), vect(-4.874, 8.8, 18.7)]
    resetDiveMode()

rule "Dive denial mode cleanup":
    @Condition gameState != GS_DIVE_DENIAL
    destroyHudText(diveInteractText)
    destroyEffect(diveRingEffect)
    player.setPrimaryFireEnabled(true)
    player.setSecondaryFireEnabled(true)
    player.setAbility1Enabled(true)
    player.setAbility2Enabled(true)
    destroyDummy(currentDiveBot.getTeam(), currentDiveBot.getSlot())

rule "Start/Stop Scenario":
    @Event eachPlayer
    @Hero brigitte
    @Condition gameState == GS_DIVE_DENIAL
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    #Start scenario
    if modeActive == false:
        destroyHudText(diveInteractText)
        eventPlayer.communicate(Comms.COUNTDOWN)
        bigMessage(getAllPlayers(), "Get Ready!")
        wait(0.3)
        smallMessage(getAllPlayers(), "3")
        wait(1)
        smallMessage(getAllPlayers(), "2")
        wait(1)
        smallMessage(getAllPlayers(), "1")
        wait(1)
        smallMessage(getAllPlayers(), "Survive!")
        hudHeader(getAllPlayers(), "Press interact ({0}) to stop".format(buttonString(Button.INTERACT)), HudPosition.TOP, 1, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        diveInteractText = getLastCreatedText()
        modeActive = true
    #Stop scenario
    else:
        destroyHudText(diveInteractText)
        resetDiveMode()
        smallMessage(getAllPlayers(), "Halted Mode")
        #Prevent spam
        wait(1)


rule "Handle Player Respawn":
    @Event eachPlayer
    @Hero brigitte
    @Condition gameState == GS_DIVE_DENIAL
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isAlive()
    eventPlayer.teleport(diveModeCenter)
    eventPlayer.setFacing(vect(1,0,0), Relativity.TO_WORLD)

rule "Force Player to remain within ring":
    @Event eachPlayer
    @Hero brigitte
    @Condition gameState == GS_DIVE_DENIAL
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isAlive()
    @Condition distance(vect(diveModeCenter.x, eventPlayer.y, diveModeCenter.z), eventPlayer.getPosition()) >= 7.5
    wait(0.048, Wait.ABORT_WHEN_FALSE)
    eventPlayer.teleport(vect(diveModeCenter.x, eventPlayer.getPosition().y, diveModeCenter.z) + directionTowards(vect(diveModeCenter.x, eventPlayer.getPosition().y, diveModeCenter.z), eventPlayer.getPosition()) * 7.4)
    if RULE_CONDITION:
        goto RULE_START

rule "Spawn enemy":
    isModeActive("GS_DIVE_DENIAL")
    @Condition currentDiveHero == null
    @Condition player.isAlive()
    player.setHealth(player.getMaxHealth())
    player.setAbilityCooldown(Button.ABILITY_1, 0)
    player.setAbilityCooldown(Button.PRIMARY_FIRE, 0)
    currentDiveHero = random.choice([Hero.WINSTON, Hero.GENJI, Hero.DOOMFIST, Hero.SOMBRA])
    createDummy(currentDiveHero, Team.2, 0, random.choice(enemySpawnPositions), vect(0,0,0))
    currentDiveBot = getLastCreatedEntity()
    currentDiveBot.startFacing(directionTowards(currentDiveBot.getEyePosition(), player.getPosition()), 9001, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    currentDiveBot.startThrottleInDirection(Vector.FORWARD, 1, Relativity.TO_PLAYER, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
    currentDiveBot.startForcingPosition(currentDiveBot.getPosition(), false)

rule "Winston behaviour":
    @Event eachPlayer
    @Hero winston
    isModeActive("GS_DIVE_DENIAL")
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.hasSpawned() == true
    
    wait(1)
    eventPlayer.stopForcingPosition()
    eventPlayer.forceButtonPress(Button.ABILITY_1)
    eventPlayer.stopForcingThrottle()
    wait(2)
    eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
    wait(2)
    destroyDummy(currentDiveBot.getTeam(), currentDiveBot.getSlot())
    currentDiveHero = null


rule "Genji behaviour":
    @Event eachPlayer
    @Hero genji
    isModeActive("GS_DIVE_DENIAL")
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.hasSpawned() == true
    
    eventPlayer.setUltCharge(100)
    wait(0.3)
    eventPlayer.stopForcingPosition()
    eventPlayer.stopFacing()
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), player.getPosition() + vect(0, 30, 0)), 9001, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    wait(0.5)
    eventPlayer.forceButtonPress(Button.JUMP)
    wait(0.3)
    eventPlayer.forceButtonPress(Button.ABILITY_1)
    wait(0.3)
    eventPlayer.stopFacing()
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), player.getEyePosition()), 9999, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    eventPlayer.forceButtonPress(Button.ULTIMATE)
    eventPlayer.forceButtonPress(Button.JUMP)
    wait(1.2)
    eventPlayer.forceButtonPress(Button.ABILITY_1)
    eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
    wait(3)
    destroyDummy(currentDiveBot.getTeam(), currentDiveBot.getSlot())
    currentDiveHero = null


rule "Doomfist behaviour":
    @Event eachPlayer
    @Hero doomfist
    isModeActive("GS_DIVE_DENIAL")
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.hasSpawned() == true
    
    wait(0.5)
    eventPlayer.stopForcingPosition()
    eventPlayer.forceButtonPress(Button.SECONDARY_FIRE)
    wait(0.1)
    eventPlayer.startForcingButton(Button.JUMP)
    wait(1)
    eventPlayer.forceButtonPress(Button.ABILITY_2)
    wait(1.3)
    eventPlayer.forceButtonPress(Button.ABILITY_1)
    wait(1)
    destroyDummy(currentDiveBot.getTeam(), currentDiveBot.getSlot())
    currentDiveHero = null


rule "Sombra behaviour":
    @Event eachPlayer
    @Hero sombra
    isModeActive("GS_DIVE_DENIAL")
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.hasSpawned() == true
    
    eventPlayer.setUltCharge(100)
    eventPlayer.stopFacing()
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), player.getPosition() + vect(0, 20, 0)), 9999, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    wait(0.5)
    eventPlayer.stopForcingPosition()
    eventPlayer.forceButtonPress(Button.ABILITY_2)
    wait(0.92)
    eventPlayer.forceButtonPress(Button.ABILITY_2)
    wait(0.6)
    eventPlayer.forceButtonPress(Button.ULTIMATE)
    wait(1)
    destroyDummy(currentDiveBot.getTeam(), currentDiveBot.getSlot())
    currentDiveHero = null

rule "Die on hack":
    @Event eachPlayer
    @Hero brigitte
    isModeActive("GS_DIVE_DENIAL")
    @Condition eventPlayer.hasStatusEffect(Status.HACKED) == true
    
    kill(eventPlayer, currentDiveBot)