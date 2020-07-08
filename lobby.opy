#!mainFile "main.opy"

lobbyButtons()

rule "Lobby Cleanup":
    @Condition gameState != GS_LOBBY
    #Clean up effects
    for i in range(0, len(buttonEffects)):
        destroyEffect(buttonEffects[i])
    buttonEffects = []
    #Clean up in-world text
    for i in range(0, len(buttonText)):
        destroyInWorldText(buttonText[i])
    buttonText = []