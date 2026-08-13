import flixel.tweens.FlxTweenType;
import flixel.text.FlxTextBorderStyle;

public var botplayTxt:FunkinText;

function postCreate() {
	if (FlxG.save.data.botplay) {
		botplayTxt = new FunkinText(0, 70, FlxG.width, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.cameras = [camHUD];
		botplayTxt.borderSize = 1.25;
		add(botplayTxt);

		FlxTween.tween(botplayTxt, {alpha: 0}, 1, {type: FlxTweenType.PINGPONG, ease: FlxEase.sineInOut});

		for (line in strumLines.members) {
			for (strum in line) {
				strum.cpu = true;
			}
			line.onNoteUpdate.add(function(e) {
				if (e.__autoCPUHit && !e.note.avoid && !e.note.wasGoodHit && e.note.strumTime < line.__updateNote_songPos) {
					goodNoteHit(line, e.note);
				}
			});
		}
	}
}//禁止任何形式的窃取 更改文本等 别被我逮到哟 🤫

/*function onPlayerHit(e) {
	e.countScore = false;
	e.accuracy = null;
}*/

function onInputUpdate(e) {
	if (FlxG.save.data.botplay) {
		e.cancel();
	}
}
