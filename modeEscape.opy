#!mainFile "main.opy"

globalvar currentEscapeBot
globalvar currentEscapeHero
globalvar escapeInteractText

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
        resetEscapeMode()
        smallMessage(getAllPlayers(), "Halted Mode")
        #Prevent spam
        wait(1)

rule "Handle Player Respawn":
    @Event eachPlayer
    @Hero brigitte
    isModeActive("GS_ESCAPE_BASH")
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isAlive()
    eventPlayer.teleport(vect(0,0,0))
    eventPlayer.setFacing(vect(1,0,0), Relativity.TO_WORLD)
    wait(0.032)
    destroyDummy(currentEscapeBot.getTeam(), currentEscapeBot.getSlot())
    currentEscapeHero = null

rule "Kill Player on Failure":
    @Event eachPlayer
    @Hero brigitte
    isModeActive("GS_ESCAPE_BASH")
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) or eventPlayer.getAltitude() > 3

    kill(eventPlayer, currentEscapeBot)

rule "Spawn enemy":
    isModeActive("GS_ESCAPE_BASH")
    @Condition currentEscapeHero == null
    @Condition player.isAlive()

    player.setHealth(player.getMaxHealth())
    player.setAbilityCooldown(Button.PRIMARY_FIRE, 0)
    currentEscapeHero = random.choice([Hero.SIGMA, Hero.MEI, Hero.HAMMOND])
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
    currentEscapeBot.startFacing(directionTowards(currentEscapeBot.getEyePosition(), player.getPosition()), 9001, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    wait(0.1)
    currentEscapeBot.forceButtonPress(Button.ULTIMATE)
    wait(random.uniform(0.5,2.5))
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
    wait()
    eventPlayer.setFacing(vect(0,-1,0), Relativity.TO_WORLD)
    wait(0.1)
    eventPlayer.forceButtonPress(Button.ULTIMATE)
    wait(5)
    destroyDummy(currentEscapeBot.getTeam(), currentEscapeBot.getSlot())
    currentEscapeHero = null

rule "Wrecking Ball behavior":
    @Event eachPlayer
    @Hero hammond
    isModeActive("GS_ESCAPE_BASH")
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()

    wait(0.3)
    eventPlayer.teleport(player.getPosition() + vect(0, random.uniform(8,15), 0))
    eventPlayer.forceButtonPress(Button.ULTIMATE)
    wait(0.3)
    eventPlayer.startForcingButton(Button.CROUCH)
    while not eventPlayer.isOnGround():
        wait(0.1)
    eventPlayer.stopForcingButton(Button.CROUCH)
    wait(2)
    destroyDummy(currentEscapeBot.getTeam(), currentEscapeBot.getSlot())
    currentEscapeHero = null