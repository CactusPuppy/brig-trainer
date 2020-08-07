#!mainFile "main.opy"

rule "Escape mode setup":
    @Condition gameState == GS_ESCAPE_BASH
    player.teleport(vect(0,0,0))
    player.setFacing(vect(1,0,0), Relativity.TO_WORLD)
    player.setPrimaryFireEnabled(true)
    player.setSecondaryFireEnabled(true)
    player.setAbility1Enabled(false)
    player.setAbility2Enabled(false)

rule "Escape mode cleanup":
    @Condition gameState != GS_ESCAPE_BASH