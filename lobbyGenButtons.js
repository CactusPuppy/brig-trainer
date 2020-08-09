var result = `rule "Lobby Mode Setup":
    @Event global
    @Condition gameState == GS_LOBBY
    player.teleport(vect(0,0,0))
    player.setFacing(vect(-1,0.3,0), Relativity.TO_WORLD)`;
let buttons = [
    {
        "mode": "GS_WHIP_SHOT",
        "name": "Whip Shot Practice"
    },
    {
        "mode": "GS_DIVE_DENIAL",
        "name": "Dive Denial Practice"
    },
    {
        "mode": "GS_ESCAPE_BASH",
        "name": "Ultimate Escape"
    },
    {
        "mode": "GS_COUNTER_CHARGE",
        "name": "Counter Charging"
    },
    {
        "mode": "GS_MIXED",
        "name": "Coming Soon!"
    }
]
let topY = 10;
let leftZ = 2.5;
let ySep = 5;
let zSep = -5;
let butPerRow = 2;
let curY = topY;
let curZ = leftZ;
let curRowInd = 0;
let x = -20;

buttons.forEach(function (button) {
    if (button.mode == "GS_MIXED") {
        curZ = 0;
        curY = 1;
    }
    let butLoc = `vect(${x}, ${curY}, ${curZ})`;
    result += `
    #${button.mode} button
    buttonLocations.append(${butLoc})
    createEffect(getAllPlayers(), Effect.SPHERE, ${button.name == "Coming Soon!" ? 'Color.RED' : 'Color.BLUE'}, ${butLoc}, buttonRadius, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    buttonEffects.append(getLastCreatedEntity())
    createInWorldText(getAllPlayers(), "${button.name}", ${butLoc}, 1, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.ALWAYS)
    buttonText.append(getLastCreatedText())`;
    curRowInd++;
    curZ += zSep;
    if (curRowInd == butPerRow) {
        curRowInd = 0;
        curY -= ySep;
        curZ = leftZ;
    }
})

let curModeInd = 0;
buttons.forEach(function (button) {
    if (button.name == "Coming Soon!") {
        return;
    }
    let t = `dotProduct(buttonLocations[${curModeInd}] - eventPlayer.getEyePosition(), eventPlayer.getFacingDirection())`;
    result += `
rule "${button.name} mode detection":
    @Event eachPlayer
    @Condition gameState == GS_LOBBY
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isUsingAbility1()
    # Ensure button is in front of the player
    @Condition ${t} >= 0
    # Check that the closest point along ray is within the sphere
    @Condition distance(eventPlayer.getEyePosition() + ${t} * eventPlayer.getFacingDirection(), buttonLocations[${curModeInd}]) <= buttonRadius
    # Check that the closest point along ray is within the player's line of sight
    @Condition isInLoS(eventPlayer.getEyePosition() + ${t} * eventPlayer.getFacingDirection(), buttonLocations[${curModeInd}], BarrierLos.PASS_THROUGH_BARRIERS)
    gameState = ${button.mode}
    smallMessage(getAllPlayers(), "Loading ${button.name}...")`
    curModeInd++;
})

// buttons.forEach(function(button) {
//     result += `
//     buttonLocations.append(${button.location})
//     buttonGameModes.append(${button.mode})
//     createEffect(getAllPlayers(), Effect.SPHERE, Color.BLUE, ${button.location}, buttonRadius, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)`
// })
console.log(result);
result;