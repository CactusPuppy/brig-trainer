#!mainFile "main.opy"

globalvar currentEscapeBot
globalvar currentEscapeHero
globalvar escapeInteractText
globalvar nextBagEscapes

subroutine resetEscapeMode

def resetEscapeMode():
    destroyDummy(currentEscapeBot.getTeam(), currentEscapeBot.getSlot())
    modeActive = false
    currentEscapeHero = null
    wait()
    hudHeader(getAllPlayers(), "Press Interact ({0}) when Ready".format(buttonString(Button.INTERACT)), HudPosition.TOP, 1, Color.GREEN, HudReeval.VISIBILITY_AND_STRING)
    escapeInteractText = getLastCreatedText()

rule "Escape mode setup":
    @Condition gameState == GS_ESCAPE_BASH
    player.teleport(vect(0,0,0))
    player.setFacing(vect(1,0,0), Relativity.TO_WORLD)
    player.setPrimaryFireEnabled(false)
    player.setSecondaryFireEnabled(true)
    player.setAbility1Enabled(false)
    player.setAbility2Enabled(false)
    nextBagEscapes = []
    resetEscapeMode()

rule "Escape mode cleanup":
    @Condition gameState != GS_ESCAPE_BASH
    destroyDummy(currentEscapeBot.getTeam(), currentEscapeBot.getSlot())
    destroyHudText(escapeInteractText)
    player.setPrimaryFireEnabled(true)
    player.setSecondaryFireEnabled(true)
    player.setAbility1Enabled(true)
    player.setAbility2Enabled(true)

rule "Player Ready":
    @Event eachPlayer
    @Hero brigitte
    @Condition gameState == GS_ESCAPE_BASH
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    destroyHudText(escapeInteractText)
    #Start
    if not modeActive:
        eventPlayer.communicate(Comms.COUNTDOWN)
        bigMessage(getAllPlayers(), "Get Ready!")
        wait(0.3)
        smallMessage(getAllPlayers(), "3")
        wait(1)
        smallMessage(getAllPlayers(), "2")
        wait(1)
        smallMessage(getAllPlayers(), "1")
        wait(1)
        smallMessage(getAllPlayers(), "Escape!")
        hudHeader(getAllPlayers(), "Press interact ({0}) to stop".format(buttonString(Button.INTERACT)), HudPosition.TOP, 1, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        escapeInteractText = getLastCreatedText()
        modeActive = true
    #Stop
    else:
        player.setHealth(player.getMaxHealth())
        resetEscapeMode()
        smallMessage(getAllPlayers(), "Halted Mode")
        #Prevent spam
        wait(1)

rule "If player loses shield, grant back faster":
    @Event eachPlayer
    @Hero brigitte
    @Condition gameState == GS_ESCAPE_BASH
    @Condition eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE) > 0
    eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 2)

rule "Handle Player Respawn":
    @Event eachPlayer
    @Hero brigitte
    @Condition gameState == GS_ESCAPE_BASH
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isAlive()
    eventPlayer.teleport(vect(0,0,0))
    eventPlayer.setFacing(vect(1,0,0), Relativity.TO_WORLD)
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)

rule "Kill Player on Failure":
    @Event eachPlayer
    @Hero brigitte
    isModeActive("GS_ESCAPE_BASH")
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) or eventPlayer.getAltitude() > 4

    kill(eventPlayer, currentEscapeBot)

rule "Spawn enemy":
    isModeActive("GS_ESCAPE_BASH")
    @Condition currentEscapeHero == null
    @Condition player.isAlive()

    player.clearStatusEffect(Status.PHASED_OUT)
    player.setHealth(player.getMaxHealth())
    player.setAbilityCooldown(Button.PRIMARY_FIRE, 0)
    if nextBagEscapes == []:
        nextBagEscapes = [Hero.SIGMA, Hero.MEI, Hero.HAMMOND]
    currentEscapeHero = random.choice(nextBagEscapes)
    nextBagEscapes.remove(currentEscapeHero)
    createDummy(currentEscapeHero, Team.2, 0, vect(0,42,0), vect(0,-1,0))
    currentEscapeBot = getLastCreatedEntity()
    currentEscapeBot.setUltCharge(100)

rule "Sigma behavior":
    @Event eachPlayer
    @Hero sigma
    isModeActive("GS_ESCAPE_BASH")
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()

    currentEscapeBot.teleport(vect(0,10,0))
    currentEscapeBot.startFacing(directionTowards(currentEscapeBot.getEyePosition(), player.getPosition() + 0.5 * player.getVelocity()), 9001, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    wait(0.1)
    currentEscapeBot.forceButtonPress(Button.ULTIMATE)
    wait(random.uniform(0.5,5))
    eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
    wait(2)
    destroyDummy(currentEscapeBot.getTeam(), currentEscapeBot.getSlot())
    currentEscapeHero = null

rule "Mei behavior":
    @Event eachPlayer
    @Hero mei
    isModeActive("GS_ESCAPE_BASH")
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()

    eventPlayer.attachTo(player, vect(0,5,0))
    eventPlayer.setInvisibility(Invis.ENEMIES)
    wait()
    eventPlayer.setFacing(vect(0,-1,0) + 0.1 * player.getVelocity(), Relativity.TO_WORLD)
    wait(0.1)
    eventPlayer.forceButtonPress(Button.ULTIMATE)
    wait(5)
    if (currentEscapeHero != Hero.MEI):
        return
    destroyDummy(currentEscapeBot.getTeam(), currentEscapeBot.getSlot())
    currentEscapeHero = null

rule "Wrecking Ball behavior":
    @Event eachPlayer
    @Hero hammond
    isModeActive("GS_ESCAPE_BASH")
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()

    wait(0.3)
    eventPlayer.teleport(player.getPosition() + vect(0, random.uniform(8,10), 0) + angleToDirection(random.uniform(0,360), 0))
    eventPlayer.startFacing(directionTowards(currentEscapeBot.getEyePosition(), player.getPosition()), 9001, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    eventPlayer.startThrottleInDirection(Vector.FORWARD, 1, Relativity.TO_PLAYER, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
    eventPlayer.forceButtonPress(Button.ULTIMATE)
    wait(0.5)
    eventPlayer.startForcingButton(Button.CROUCH)
    while not eventPlayer.isOnGround():
        wait(0.1)
    eventPlayer.stopForcingButton(Button.CROUCH)
    eventPlayer.stopThrottleInDirection()
    wait(3.5)
    destroyDummy(currentEscapeBot.getTeam(), currentEscapeBot.getSlot())
    currentEscapeHero = null