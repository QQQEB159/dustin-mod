//
import funkin.game.cutscenes.VideoCutscene;

menuType = "default";
var name:String = null;
var script;

function onOpenSubState(e) if (e.substate is VideoCutscene) {
    e.cancelled = true;
    subState = null;

    FULL_VOLUME = true;

    script = importScript("data/scripts/skippableVideoUndertale");
    dustCall = e.substate.__callback;
    name = e.substate.path;
    script.call("startVideo", [name, finishDustin]);
}

function finishDustin() {
    script.destroy();

    if (dustCall != null) dustCall();

    if (name == "assets/videos/the-uprising-end-cutscene.mp4")
        FlxG.switchState(new ModState("EndingCredits", "genocide"));

    else if (name == "assets/videos/you-are-end-cutscene.mp4")
        FlxG.switchState(new ModState("EndingCredits", "pacifist"));
}