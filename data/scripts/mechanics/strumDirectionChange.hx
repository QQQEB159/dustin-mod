
//
import flixel.util.FlxSort;
import funkin.editors.charter.Charter;
import openfl.Lib;

public var directionStrums:Array<Strumline> = [playerStrums];
public function applyDirectionStrum(strumline:Strumline) {
    if(!directionStrums.contains(strumline)) {
        for(s in strumline.members)
            s.onDraw = strumDraw;
        directionStrums.push(strumline);
        negMultY -= 1;
        negMultY += 1;
    }
}
public function removeDirectionStrum(strumline:Strumline) {
    if(directionStrums.contains(strumline)) {
        for(s in strumline.members)
            s.onDraw = null;
        directionStrums.remove(strumline);
        if(strumline.onNoteUpdate.has(onNoteDirectionUpdate))
            strumline.onNoteUpdate.remove(onNoteDirectionUpdate);
    }
}

public var onDirectionChangePost:Array<(direc:Bool)-> Void> = [];
public var onDirectionChange:Array<(direc:Bool)-> Void> = [];

public var updateNotes(default, set):Bool = true;
public var changeNoteColors:Bool = true;
function set_updateNotes(value:Bool) {
    updateNotes = value;
    if(!value && negMultY != 1)
        negMultY = negMultY;
    return value;
}


var strumSpin:Float = 0;
public var strumOffset:FlxPoint = FlxPoint.get();
public var strumOffsetLerp:FlxPoint = FlxPoint.get();
public var strumDraw:FlxSprite->Void = (spr) -> {
    if(spr.camera.alpha > 0 || spr.alpha > 0) {
        spr.angle += strumSpin;
        spr.y += strumOffsetLerp.y + downscrollOffsetLerp + forcedScrollOffset;
        spr.x += strumOffsetLerp.x;
        spr.draw();
        spr.y -= strumOffsetLerp.y + downscrollOffsetLerp + forcedScrollOffset;
        spr.x -= strumOffsetLerp.x;
        spr.angle -= strumSpin;
    }
};

function postCreate() {
    for(strumline in directionStrums) {
        for(s in strumline.members)
            s.onDraw = strumDraw;
    }
}

public var directionalPluey:Float = 0;
public var hudOffY:Float = 0;

var hudX:Float = 283.5;
var desiredHudX:Float = 283.5;
var hudY:Float = 564;
var hudTween:FlxTween;
var monitorTween:FlxTween;
var windowTweenRunning:Bool;

public var ignoreHUDScroll:Bool = false;

function update(elapsed:Float) {
    negMultY = lerp(negMultY, desiredMultY, FlxEase.circInOut(.35));

    downscrollOffsetLerp = Math.min(0, downscrollOffset * negMultY);

    strumOffsetLerp.x = lerp(strumOffsetLerp.x, strumOffset.x, FlxEase.circInOut(.27));
    strumOffsetLerp.y = lerp(strumOffsetLerp.y, strumOffset.y, FlxEase.circInOut(.27));

    if(!ignoreHUDScroll) {
        hudX = lerp(hudX, desiredHudX, FlxEase.sineInOut(.2));
        moveHUD(hudX, hudY + hudOffY);
    }
    
    if (directionalPluey != -1 && changeNoteColors) {
        var strumColor:FlxColor = FlxColor.interpolate(0xFFFFFFFF, 0xFF83A2FF, directionalPluey);
        for (i=>strum in strumLines.members[1].members)
            strum.color = strumColor;
        strumLines.members[1].notes.forEach(function (note) {
            note.color = strumColor;
        });
    }

    for(spr in ratingsGroup.members) {
        spr.onDraw = strumDraw;
    }

    if (windowTweenRunning) monitorTween.active = true;
}

function onGamePause(e) {
    if (windowTweenRunning) {
        monitorTween.active = false;
        FlxG.stage.window.__backend.move(
            (FlxG.stage.window.displayMode.width - FlxG.stage.window.width) * 0.5,
            (FlxG.stage.window.displayMode.height - FlxG.stage.window.height) * 0.5
        );
    }
}

function doWindowShit(invert:Bool) {
    windowTweenRunning = true;
    final toDownscroll = downscroll != invert, window = FlxG.stage.window;

    monitorTween = FlxTween.num(0.5, toDownscroll ? -.35 : 1.35,
            Conductor.stepCrochet * 0.00175, {ease: FlxEase.cubeIn}, (val:Float) -> {
        DustinUtil.window.boundsY = val;
    }).then(FlxTween.num(toDownscroll ? 1.35 : -.35, 0.5,
            Conductor.stepCrochet * 0.00325, {ease: FlxEase.circOut, onComplete: (_) -> windowTweenRunning = false}, (val:Float) ->  {
        DustinUtil.window.boundsY = val;
    }));
}

// i rather have my strums flashed when this mechanic enabled, thanks. -ralty
function flashCamera(camera:FlxCamera) {
    var colorTransform = FlxG.renderBlit ? camera._flashBitmap.transform.__colorTransform : camera.canvas.transform.__colorTransform;
    colorTransform.redOffset = colorTransform.greenOffset = colorTransform.blueOffset = 255;
    FlxTween.tween(colorTransform, {redOffset: 0, greenOffset: 0, blueOffset: 0}, 0.5, {ease: FlxEase.auintInOut});
}

public var downscrollOffset:Float = 120;
public var downscrollOffsetLerp:Float = 0;
public var forcedScrollOffset:Float = 0;
public function goDownScroll() {
    if (!FlxG.save.data.mechanics || (PlayState.chartingMode && Charter.startHere && FlxG.sound.music.time < Charter.startTime)) return;
    pluOUT();

    for(fun in onDirectionChange) fun(true);

    desiredHudX = 283.5;
    desiredMultY = -1;

    if (hudTween != null) hudTween.cancelChain();
    if (monitorTween != null) monitorTween.cancelChain();
    for (i in 0...4) {
        (new FlxTimer()).start(i*.06, (_) -> {
            strumOffset.set(0,camHUD.height - (strumLines.members[1].members[0].y) - (strumLines.members[1].members[i].height / 2));
            FlxTween.cancelTweensOf(strumLines.members[1].members[i]);
            FlxTween.num(0, -360, (Conductor.stepCrochet / 1000) * 4, {
                ease: FlxEase.circOut,
                onComplete: (_) -> {
                    strumSpin = 0;
                }
            },
            (num) -> {
                strumSpin = num;
            });
        });
    }

    new FlxTimer().start((Conductor.stepCrochet / 1000) * 4.5, ()->{ for(fun in onDirectionChangePost) fun(true); });

    //if (FlxG.save.data.mWindow) doWindowShit(false);
    flashCamera(camHUD);

    hudTween = FlxTween.num(hudY, 564+300, (Conductor.stepCrochet / 1000) * 4.5, {ease: FlxEase.circInOut}, (val:Float) -> {
        hudY = val;
    }).then(FlxTween.num(-400, 50, (Conductor.stepCrochet / 1000) * 4.5, {ease: FlxEase.circInOut}, (val:Float) -> {
        hudY = val;
    }));
}

function pluSFX() {
    if (!FlxG.save.data.mechanics) return;
    // camHUD.shake(0.002, 0.3);
    FlxG.sound.play(Paths.sound('undertale/snd_break2'), .67);
    FlxG.sound.play(Paths.sound('undertale/snd_noise'), .8);
    FlxG.sound.play(Paths.sound('undertale/snd_impact'), .2);
}

var doingPLU:Bool = false;
function pluOUT() {
    pluSFX();
    if (doingPLU) return;
    doingPLU = true;

    FlxTween.num(0, .9, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.sineInOut, startDelay: (Conductor.stepCrochet / 1000) * 1}, (val:Float) -> {directionalPluey = val;});
    (new FlxTimer()).start((Conductor.stepCrochet / 1000) * 16, function (_) {
        FlxTween.num(.9, 0, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.sineInOut, startDelay: (Conductor.stepCrochet / 1000) * 1}, (val:Float) -> {directionalPluey = val;});
        (new FlxTimer()).start((Conductor.stepCrochet / 1000) * 4, function (_) {
            doingPLU = false;
        });
    });
}

public function goUpScroll() {
    if (!FlxG.save.data.mechanics || (PlayState.chartingMode && Charter.startHere && FlxG.sound.music.time < Charter.startTime)) return;
    pluOUT();

    for(fun in onDirectionChange) fun(false);

    desiredHudX = 283.5;
    desiredMultY = 1;
    if (hudTween != null) hudTween.cancelChain();
    if (monitorTween != null) monitorTween.cancelChain();
    for (i in 0...4) {
        (new FlxTimer()).start(i*.06, (_) -> {
            strumOffset.set(0,0);
            FlxTween.cancelTweensOf(strumLines.members[1].members[i]);
            FlxTween.num(0, 360, (Conductor.stepCrochet / 1000) * 4, {
                ease: FlxEase.circOut,
                onComplete: (_) -> {
                    strumSpin = 0;
                }
            },
            (num) -> {
                strumSpin = num;
            });
        });
    }
    
    new FlxTimer().start((Conductor.stepCrochet / 1000) * 4.5, ()->{ for(fun in onDirectionChangePost) fun(false); });

    //if (FlxG.save.data.mWindow) doWindowShit(true);
    flashCamera(camHUD);

    hudTween = FlxTween.num(hudY, -400, (Conductor.stepCrochet / 1000) * 4.5, {ease: FlxEase.circInOut}, (val:Float) -> {
        hudY = val;
    }).then(FlxTween.num(564+300, 564, (Conductor.stepCrochet / 1000) * 4.5, {ease: FlxEase.circInOut}, (val:Float) -> {
         hudY = val;
    }));
}

function moveHUD(hudx:Float, hudy:Float) {
    dustinHealthBG.x = hudx; dustinHealthBG.y = hudy;
    dustinHealthBar.x = hudx + 46;  dustinHealthBar.y = hudy+(camHUD.downscroll ? 25 : 32);
    timeBarBG.x = hudx + 77; timeBarBG.y = hudy + 74;
    timeBar.x = timeBarBG.x; timeBar.y = timeBarBG.y;
    scoreTxt.x = dustinHealthBG.x + 56; scoreTxt.y = dustinHealthBG.y + 114;
    missesTxt.x = dustinHealthBG.x + 116; missesTxt.y = dustinHealthBG.y + 114;
    accuracyTxt.x = dustinHealthBG.x + 116; accuracyTxt.y = dustinHealthBG.y + 114;
}

public var desiredMultY:Float = 1;
public var negMultY(default, set):Float = 1;
function set_negMultY(value:Float) {
    if(!updateNotes)
        value = 1;
    if(negMultY == value)
        return;
    if(value != 1 && updateNotes) {
        for(strumline in directionStrums) {
            if(!strumline.onNoteUpdate.has(onNoteDirectionUpdate))
                strumline.onNoteUpdate.add(onNoteDirectionUpdate);
        }
    } else {
        for(strumline in directionStrums) {
            if(strumline.onNoteUpdate.has(onNoteDirectionUpdate))
                strumline.onNoteUpdate.remove(onNoteDirectionUpdate);
        }
    }
    return negMultY = value;
}

public function onNoteDirectionUpdate(e:NoteUpdateEvent) {
    e.__reposNote = camHUD.alpha != 0 && negMultY == 1;
    if(camHUD.alpha > 0) {
        if(e.__reposNote)
            return;

        var note:Note = e.note;
        note.strumRelativePos = true;
        var strum:Strum = e.strum;

        strum.updateNotePosition(note);
        updateNoteDirection(e);
    }
}

public function updateNoteDirection(e:NoteUpdateEvent) {
    var note:Note = e.note;
    var strum:Strum = e.strum;
    var speed:Float = strum.getScrollSpeed(note);

    note.y -= downscrollOffsetLerp;
    note.y = Math.max(0, note.camera.height * (negMultY * -1)) - (note.y * (negMultY * -1)) - Math.max(0, note.height * (negMultY * -1));
    note.y += forcedScrollOffset;
    if (note.isSustainNote) {
        note.angle = 0; 
        if (note.nextSustain != null) {
            note.scale.y = ((note.sustainLength * 0.45 * speed) / note.frameHeight) * negMultY;
            note.updateHitbox();
            note.scale.y += (note.gapFix / note.frameHeight) * negMultY;
        } else {
            note.scale.y = finalNotesScale * negMultY;
        }
    }
}