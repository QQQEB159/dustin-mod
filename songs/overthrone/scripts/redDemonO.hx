// funny script that makes Red Demon O unlockable  - Nex
import funkin.backend.MusicBeatState;
import funkin.backend.chart.Chart;
import mobile.funkin.backend.utils.TouchUtil;

var step = 0;

var keyboard:FunkinSprite;
var curCode:String = '';

function handleCode(str:String)
{
	curCode += str.toLowerCase();
	
	if (curCode == "17")
	{
		var diffs = Chart.loadChartMeta("red-demon-o").difficulties;
        PlayState.loadSong("red-demon-o", diffs[diffs.length - 1]);
        MusicBeatState.skipTransIn = MusicBeatState.skipTransOut = true;
        FlxG.switchState(new PlayState());
		curCode = '';
	}
}

function postCreate() {
    keyboard = new FunkinSprite(-400, 1000, Paths.image("keyboard"));
	keyboard.scale.set(0.5, 0.5);
	keyboard.updateHitbox();
	keyboard.scrollFactor.set(0, 0);
	add(keyboard);
	//keyboard.camera = camHUD;
	FlxG.stage.window.onTextInput.add(handleCode);
}

function postUpdate() {  // To finish this once we have the freeplay ready  - Nex
    if (TouchUtil.overlaps(keyboard) && TouchUtil.justPressed && keyboard.visible)
	{
        FlxG.stage.window.textInputEnabled = true;
		curCode = '';
	}
    
    var one = FlxG.keys.justPressed.ONE;
    var seven = FlxG.keys.justPressed.SEVEN;
    if (!one && !seven) return;

    if (step < 2 ? one : seven) {
        trace(step < 2 ? "one" : "seven");
        step++;

        if (step == 3) {
            var diffs = Chart.loadChartMeta("red-demon-o").difficulties;
            PlayState.loadSong("red-demon-o", diffs[diffs.length - 1]);
            MusicBeatState.skipTransIn = MusicBeatState.skipTransOut = true;
            FlxG.switchState(new PlayState());
        }
    } else {
        trace("wrong:kys:");
        step = 0;
    }
}

function stepHit(step:Int) {
    if (step == 100) keyboard.visible = false;
}

function destroy() FlxG.stage.window.onTextInput.remove(handleCode);