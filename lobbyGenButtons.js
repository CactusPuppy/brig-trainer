var result = `rule "Lobby Mode Setup":
    @Event global
    @Condition gameState == GS_LOBBY`;
let buttons = [
    {
        "location": "vect(20, 10, -5)",
        "mode": "GS_WHIP_SHOT"
    },
    {
        "location": "vect(20, 10, 5)",
        "mode": "GS_BASH_CANCEL"
    },

]
let buttonModes = ["GS_WHIP_SHOT", "GS_ULT_DENIAL", "GS_ESCAPE_BASH", "GS_COUNTER_CHARGE", "GS_MIXED"];
let buttonNames = ["Whip Shot Practice", "Ult Denial Practice", "Escape Bash Practice", "Counter Bash Practice", "Mixed Mode"]
let topY = 10;
let leftZ = -2.5;
let ySep = 5;
let zSep = 5;
let butPerRow = 2;
let curY = topY;
let curZ = leftZ;
let curRowInd = 0;
let x = 20;

buttonModes.forEach(function (mode, i) {
    if (i + 1 == buttonModes.length) {
        curZ = 0;
        curY = 1;
    }
    let butLoc = `vect(${x}, ${curY}, ${curZ})`;
    result += `
    #${mode} button
    buttonLocations.append(${butLoc})
    createEffect(getAllPlayers(), Effect.SPHERE, Color.BLUE, ${butLoc}, buttonRadius, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    buttonEffects.append(getLastCreatedEntity())
    createInWorldText(getAllPlayers(), "${buttonNames[i]}", ${butLoc}, 1, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.ALWAYS)
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
buttonModes.forEach(function (button, i) {
    let t = `dotProduct(buttonLocations[${curModeInd}] - eventPlayer.getEyePosition(), eventPlayer.getFacingDirection())`;
    result += `
rule "${button} mode detection":
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
    gameState = ${button}
    smallMessage(getAllPlayers(), "Loading ${buttonNames[i]}...")`
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