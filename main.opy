#Global variables
# Current game state for FSM
globalvar gameState
# Helper iterator
globalvar i

# Lobby vars
globalvar buttonLocations
globalvar buttonEffects
globalvar buttonText

# Universal vars
globalvar modeActive

#!define GS_LOBBY 0
#!define GS_WHIP_SHOT 1
#!define GS_DIVE_DENIAL 2
#!define GS_ESCAPE_BASH 3
#!define GS_COUNTER_CHARGE 4
#!define GS_MIXED 5
#!define buttonRadius 1

#!define lobbyButtons() __script__('lobbyGenButtons.js')
#!define player getPlayersInSlot(0, Team.1)
#!define diveModeCenter vect(-7,0,0)
#!define isModeActive(mode) __script__('isModeActive.js')

settings {
    "main": {
        "description": "=== BRIG TRAINING FACILITY v0.5 ===            By @Cactus_Puppy https://workshop.codes/R5HER                      Dive Denial mode adapted from Kevlar_OW's mode [392TH]"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "team1Slots": 1,
        "team2Slots": 0,
        "swapTeamsAfterMatch": false
    },
    "gamemodes": {
        "skirmish": {
            "enabledMaps": [
                "workshopChamber"
            ]
        },
        "general": {
            "enableHeroSwitching": false,
            "heroLimit": "off",
            "enableKillCam": false,
            "enableKillFeed": false,
            "enableRandomHeroes": true,
            "respawnTime%": 10
        }
    },
    "heroes": {
        "team1": {
            "brigitte": {
                "ability1Cooldown%": 50,
                "secondaryFireRechargeRate%": 500,
                "shieldBashCooldown%": 50,
                "enableUlt": false
            },
            "enabledHeroes": [
                "brigitte"
            ]
        },
        "team2": {
            "pharah": {
                "enableSecondaryFireUnlimitedFuel": true,
                "ability1Cooldown%": 0
            },
            "tracer": {
                "ability1Cooldown%": 25
            },
            "mccree": {
                "ability1Cooldown%": 0
            },
            "doomfist": {
                "damageDealt%": 500
            },
            "winston": {
                "damageDealt%": 450
            }
        }
    }
}

rule "Global Setup":
    @Event global
    #Debugging
    if not createWorkshopSetting(bool, "Debug Mode", "Enabled", false):
        disableInspector()
    hudHeader(getAllPlayers() if gameState != GS_LOBBY else [], "Hold [{0}] to Return to Lobby".format(buttonString(Button.CROUCH)), HudPosition.LEFT, 1, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING)
    gameState = GS_LOBBY
    buttonLocations = []
    buttonText = []
    #Stop timer
    setMatchTime(817.5)
    wait()
    pauseMatchTime()

rule "Player Setup":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()
    eventPlayer.teleport(vect(0,0,0))
    eventPlayer.setFacing(vect(-1,0.3,0), Relativity.TO_WORLD)

rule "==== LOBBY ====":
    @Disabled
    @Event global
    gameState = false

#!include "lobby.opy"

rule "==== WHIP SHOT ====":
    @Disabled
    @Event global
    gameState = false

#!include "modeWhipShot.opy"

rule "==== DIVE DENIAL ====":
    @Disabled
    @Event global
    gameState = false

#!include "modeDiveDenial.opy"

rule "==== DEBUG ====":
    @Disabled
    @Event global
    gameState = false

#!include "debug.opy"