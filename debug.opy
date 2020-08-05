#!mainFile "main.opy"

rule "On holding crouch, reset to lobby":
    @Event global
    @Condition hostPlayer.isHoldingButton(Button.CROUCH)
    wait(0.3, Wait.ABORT_WHEN_FALSE)
    smallMessage(getAllPlayers(), "Returning to lobby in 3...")
    wait(1, Wait.ABORT_WHEN_FALSE)
    smallMessage(getAllPlayers(), "Returning to lobby in 2...")
    wait(1, Wait.ABORT_WHEN_FALSE)
    smallMessage(getAllPlayers(), "Returning to lobby in 1...")
    wait(1, Wait.ABORT_WHEN_FALSE)
    gameState = GS_LOBBY
    smallMessage(getAllPlayers(), "Returned to Lobby")