#!mainFile "main.opy"

globalvar counterInteractText
globalvar currentCounterHero
globalvar currentCounterBot
globalvar counterRingEffect

subroutine resetCounterMode

def resetCounterMode():
    destroyDummy(currentCounterBot.getTeam(), currentCounterBot.getSlot())
    modeActive = false
    currentCounterBot = null
    wait()
    hudHeader(getAllPlayers(), "Press interact ({0}) when ready".format(buttonString(Button.INTERACT)), HudPosition.TOP, 1, Color.GREEN, HudReeval.VISIBILITY_AND_STRING)
    counterInteractText = getLastCreatedText()

rule "Counter bash mode setup":
    @Condition gameState == GS_COUNTER_CHARGE
    player.teleport(vect(0,0,0))
    player.setPrimaryFireEnabled(false)
    player.setSecondaryFireEnabled(true)
    player.setAbility1Enabled(false)
    player.setAbility2Enabled(false)
    resetCounterMode()

rule "Counter bash cleanup":
    @Condition gameState != GS_COUNTER_CHARGE
    destroyDummy(currentCounterBot.getTeam(), currentCounterBot.getSlot())
    destroyHudText(counterInteractText)
    player.setPrimaryFireEnabled(true)
    player.setSecondaryFireEnabled(true)
    player.setAbility1Enabled(true)
    player.setAbility2Enabled(true)

rule "Player Ready":
    @Event eachPlayer
    @Hero brigitte
    @Condition gameState == GS_COUNTER_CHARGE
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
        smallMessage(getAllPlayers(), "Counter!")
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
    @Condition gameState == GS_COUNTER_CHARGE
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isAlive()
    eventPlayer.teleport(vect(0,0,0))
    eventPlayer.setFacing(vect(1,0,0), Relativity.TO_WORLD)

rule "Spawn enemy":
    isModeActive("GS_COUNTER_CHARGE")
    @Condition currentCounterHero == null
    @Condition player.isAlive()

    player.setHealth(player.getMaxHealth())
    player.setAbilityCooldown(Button.PRIMARY_FIRE, 0)
    currentCounterHero = random.choice([Hero.REINHARDT, Hero.DOOMFIST])
    createDummy(currentCounterHero, Team.2, 0, vect(0,0,0) + angleToDirection(random.uniform(0,360), 0), vect(0,0,0))
    currentCounterBot = getLastCreatedEntity()