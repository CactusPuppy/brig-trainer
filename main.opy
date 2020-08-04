#Global variables
# Current game state for FSM
globalvar gameState
# Helper iterator
globalvar i

# Lobby vars
globalvar buttonLocations
globalvar buttonEffects
globalvar buttonText

#!define GS_LOBBY 0
#!define GS_WHIP_SHOT 1
#!define GS_ULT_DENIAL 2
#!define GS_ESCAPE_BASH 3
#!define GS_COUNTER_CHARGE 4
#!define GS_MIXED 5
#!define buttonRadius 1

#!define lobbyButtons() __script__('lobbyGenButtons.js')
#!define player getPlayersInSlot(0, Team.1)

settings {
    "lobby": {
        "team1Slots": 1,
        "team2Slots": 0
    },
    "gamemodes": {
        "skirmish": {
            "enabledMaps": [
                "workshopChamber"
            ]
        }
    },
    "heroes": {
        "team1": {
            "brigitte": {
                "ability1Cooldown%": 0
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
            }
        }
    }
}

rule "Global Setup":
    @Event global
    gameState = GS_LOBBY
    buttonLocations = []
    buttonText = []
    #Debugging
    disableInspector()

rule "Player Setup":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()
    eventPlayer.teleport(vect(0,0,0))
    eventPlayer.setFacing(vect(1,0.3,0), Relativity.TO_WORLD)

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

rule "==== ULT DENIAL ====":
    @Disabled
    @Event global
    gameState = false

#!include "modeUltDenial.opy"

rule "==== DEBUG ====":
    @Disabled
    @Event global
    gameState = false

#!include "debug.opy"