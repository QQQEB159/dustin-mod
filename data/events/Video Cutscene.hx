//
import hxvlc.flixel.FlxVideoSprite;

import funkin.editors.charter.Charter;
import haxe.MainLoop;

public var videoCam:FlxCamera;
public var curVideo:FlxVideoSprite;
public var preloadedVideos:Map<String, FlxVideoSprite> = [];

var camVisible:Bool = true;

function getCamVisible() return camVisible;

function onStartCountdown(countdown) {
    for(video in preloadedVideos.keys()) {
        if(preloadedVideos[video].ID == 0) {
            if (camGame.visible)
                camVisible = null;
            else
                camVisible = camGame.visible;
            camGame.visible = false;
        }
    }
}

function create() {
    videoCam = new FlxCamera(0, 0);
    videoCam.bgColor = 0x00000000;
    insert_camera(videoCam, FlxG.cameras.list.indexOf(camHUD) - 1, false);

    MainLoop.runInMainThread(function() {

    for (event in PlayState.SONG.events) {
        if (event.name == "Video Cutscene" && !preloadedVideos.exists(event.params[0])) {
            var vid:FlxVideoSprite = new FlxVideoSprite();
            vid.ID = event.time;
            vid.autoVolumeHandle = false;
            vid.bitmap.onFormatSetup.add(function() {
                    final width = vid.bitmap.bitmapData.width;
                    final height = vid.bitmap.bitmapData.height;
                    final scale:Float = Math.min(videoCam.width / width, videoCam.height / height);
                    vid.setGraphicSize(Std.int(width * scale), Std.int(height * scale));
                    vid.updateHitbox();
                    vid.screenCenter();
            });
            // Wrap this in a try catch for future CNE versions
            try { vid.autoPause = false; } catch (e:Any) {}
            vid.load(Assets.getPath(Paths.video(event.params[0], event.params[1])));
            vid.cameras = [videoCam]; vid.antialiasing = Options.antialiasing; vid.alpha = 0.0001;

            vid.moves = false;
            preloadedVideos.set(event.params[0], vid);

        }
    }

        for(video in preloadedVideos.keys()) {
            var vid = preloadedVideos[video];
            vid.play();
        }

        new FlxTimer().start(0.0005, () -> {
            for(video in preloadedVideos.keys()) {
                var vid = preloadedVideos[video];
                vid.pause();
                vid.alpha = 1;
                vid.visible = false;
                vid.bitmap.position = 0;

                vid.bitmap.onEndReached.add(function () {
                    curVideo = null;
                    vid.visible = false;
                    remove(vid);
                    vid.destroy();
                    var camVis = getCamVisible();
                    camGame.visible = (camVis == null ? true : camVis);
                });
            }
        });
    });
}

function getCalculatedVolume() {
    return (FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume;
}

function update(elapsed:Float) {
    persistentUpdate = false;
    if (curVideo != null && !curVideo.autoVolumeHandle) {
        curVideo?.bitmap.volume = Math.floor(FlxMath.bound(getCalculatedVolume() * 1.5, 0, 1) * (100));
    }
}


function onEvent(_) {
    var params:Array = _.event.params;
    if (_.event.name == "Video Cutscene") {
        if(PlayState.chartingMode && Charter.startHere && _.event.time < Charter.startTime)
            return;
        curVideo = preloadedVideos.get(params[0]);
        if (curVideo?.visible) return;

        curVideo.visible = true;
        insert(99999, curVideo);
        curVideo.resume();
        if (camVisible == null)
            camVisible = true;
        else
            camVisible = camGame.visible;
        camGame.visible = false;
    }
}

function onGamePause(event) {
    for (name => vid in preloadedVideos) 
        if (vid.visible) vid.pause();
}

function onSubstateClose(event) {
    for (name => vid in preloadedVideos) 
        if (vid.visible) vid.resume();
}

function onFocus() {
    if (!Options.autoPause || paused) return;
    for (name => vid in preloadedVideos) 
        if (vid.visible) vid.resume();
}

function onFocusLost() {
    if (!Options.autoPause || paused) return;
    for (name => vid in preloadedVideos) 
        if (vid.visible) vid.pause();
}

function destroyVideos() {
    for (name => vid in preloadedVideos) {
        if (vid != null) {
            vid.bitmap?.dispose();
            vid.destroy();
            curVideo = null;
        }
    }
    FlxG.signals.preStateSwitch.remove(destroyVideos);
}

FlxG.signals.preStateSwitch.add(destroyVideos); // destroy doesn't get called in event scripts