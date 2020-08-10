#!mainFile "main.opy"

globalvar counterInteractText
globalvar currentCounterHero
globalvar currentCounterBot
globalvar counterRingEffect
globalvar nextBagCounters
globalvar counterTimer
globalvar successLock

subroutine resetCounterMode

def resetCounterMode():
    if entityExists(currentCounterBot):
        destroyDummy(currentCounterBot.getTeam(), currentCounterBot.getSlot())
    modeActive = false
    currentCounterHero = null
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
    nextBagCounters = []
    createEffect(getAllPlayers(), Effect.RING, Color.GREEN, vect(0,0,0), 2, EffectReeval.VISIBILITY)
    counterRingEffect = getLastCreatedEntity()
    resetCounterMode()
    successLock = false

rule "Counter bash cleanup":
    @Condition gameState != GS_COUNTER_CHARGE
    destroyDummy(currentCounterBot.getTeam(), currentCounterBot.getSlot())
    destroyHudText(counterInteractText)
    destroyEffect(counterRingEffect)
    player.setPrimaryFireEnabled(true)
    player.setSecondaryFireEnabled(true)
    player.setAbility1Enabled(true)
    player.setAbility2Enabled(true)

rule "Player Ready":
    @Event eachPlayer
    @Hero brigitte
    @Condition gameState == GS_COUNTER_CHARGE
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    destroyHudText(counterInteractText)
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
        counterInteractText = getLastCreatedText()
        modeActive = true
    #Stop
    else:
        resetCounterMode()
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
    currentCounterHero = null

rule "Force Player to remain within ring":
    @Event eachPlayer
    @Hero brigitte
    @Condition gameState == GS_COUNTER_CHARGE
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isAlive()
    @Condition distance(vect(0, eventPlayer.y, 0), eventPlayer.getPosition()) >= 2.5
    @Condition eventPlayer.getThrottle() != vect(0,0,0) or eventPlayer.isFiringSecondaryFire()
    eventPlayer.teleport(vect(0, eventPlayer.getPosition().y, 0) + directionTowards(vect(0, eventPlayer.getPosition().y, 0), eventPlayer.getPosition()) * 2.4)
    wait(0.032)
    if RULE_CONDITION:
        goto RULE_START

rule "Spawn enemy":
    isModeActive("GS_COUNTER_CHARGE")
    @Condition currentCounterHero == null
    @Condition player.isAlive()
    @Condition not successLock

    player.setHealth(player.getMaxHealth())
    player.setAbilityCooldown(Button.PRIMARY_FIRE, 0)
    if nextBagCounters == []:
        nextBagCounters = [Hero.REINHARDT, Hero.DOOMFIST]
    currentCounterHero = random.choice(nextBagCounters)
    createDummy(currentCounterHero, Team.2, 0, vect(0,0,0) + random.uniform(2.7,3.7) * angleToDirection(random.uniform(0,360), 0), vect(0,0,0))
    currentCounterBot = getLastCreatedEntity()
    nextBagCounters.remove(currentCounterHero)
    currentCounterBot.startFacing(directionTowards(currentCounterBot.getEyePosition(), player.getPosition()), 9001, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)

rule "If knockdown, expedite next stage":
    @Event eachPlayer
    @Hero brigitte
    isModeActive("GS_COUNTER_CHARGE")
    @Condition player.isAlive()
    @Condition player.hasStatusEffect(Status.KNOCKED_DOWN) or currentCounterBot.hasStatusEffect(Status.STUNNED)
    stopChasingVariable(counterTimer)
    smallMessage(getAllPlayers(), "Success!")
    playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer.getPosition(), 200)
    successLock = true
    currentCounterHero = null
    wait(2)
    destroyDummy(currentCounterBot.getTeam(), currentCounterBot.getSlot())
    successLock = false

rule "Rein behavior":
    @Event eachPlayer
    @Hero reinhardt
    isModeActive("GS_COUNTER_CHARGE")
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()

    eventPlayer.startForcingButton(Button.SECONDARY_FIRE)
    wait(random.uniform(0.8,2))
    eventPlayer.stopForcingButton(Button.SECONDARY_FIRE)
    eventPlayer.startForcingButton(Button.ABILITY_1)
    counterTimer = 4
    chase(counterTimer, 0, rate=1, ChaseReeval.NONE)
    while currentCounterHero != null:
        wait(0.5)
        if counterTimer == 0:
            break
    if eventPlayer != currentCounterBot or successLock:
        return
    destroyDummy(eventPlayer.getTeam(), eventPlayer.getSlot())
    currentCounterHero = null

rule "Doom behavior":
    @Event eachPlayer
    @Hero doomfist
    isModeActive("GS_COUNTER_CHARGE")
    @Condition eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()

    eventPlayer.teleport(random.uniform(10,14) * directionTowards(vect(0,0,0), eventPlayer.getPosition()))
    wait(random.uniform(1,2))
    eventPlayer.startForcingButton(Button.SECONDARY_FIRE)
    wait(random.uniform(1.4, 2))
    eventPlayer.stopForcingButton(Button.SECONDARY_FIRE)
    wait(1)
    if successLock or successLock:
        return
    destroyDummy(eventPlayer.getTeam(), eventPlayer.getSlot())
    currentCounterHero = null

rule "If damage from Doom, die":
    @Event playerTookDamage
    @Hero brigitte
    isModeActive("GS_COUNTER_CHARGE")
    @Condition attacker.getCurrentHero() == Hero.DOOMFIST
    @Condition eventAbility == Button.SECONDARY_FIRE

    kill(eventPlayer, currentCounterBot)
