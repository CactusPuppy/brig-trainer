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
#!define GS_BASH_CANCEL 2
#!define GS_ESCAPE_BASH 3
#!define GS_COUNTER_CHARGE 4
#!define GS_MIXED 5
#!define buttonRadius 1

#!define lobbyButtons() __script__('lobbyGenButtons.js')

rule "Global Setup":
    @Event global
    gameState = GS_LOBBY
    buttonLocations = []
    buttonText = []

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

rule "==== DEBUG ====":
    @Disabled
    @Event global
    gameState = false

#!include "debug.opy"