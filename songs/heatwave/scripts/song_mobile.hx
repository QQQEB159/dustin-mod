import flixel.math.FlxPoint;

public var joystickBg:FunkinSprite;
public var joystickStick:FunkinSprite;
public var joystickTouchID:Int = -1;
public var joystickRadius:Float = 60;

public var leftPressed:Bool = false;
public var rightPressed:Bool = false;
public var upPressed:Bool = false;
public var downPressed:Bool = false;

public var joystickX:Float = 0;
public var joystickY:Float = 0;

public var zButton:FunkinSprite;
public var zPressed:Bool = false;
public var zTouchID:Int = -1;

function postCreate() {
	joystickBg = new FunkinSprite(80, FlxG.height - 310).loadGraphic(Paths.image("mobile/joystick"));
	joystickBg.cameras = [camUndertale];
	joystickBg.updateHitbox();
	add(joystickBg);

	joystickStick = new FunkinSprite(joystickBg.x + joystickBg.width/2 - 30, joystickBg.y + joystickBg.height/2 - 30).loadGraphic(Paths.image("mobile/joystick2"));
	joystickStick.cameras = [camUndertale];
	joystickStick.updateHitbox();
	add(joystickStick);

	zButton = new FunkinSprite(FlxG.width - 200, FlxG.height - 240).loadGraphic(Paths.image("mobile/z"));
	zButton.cameras = [camUndertale];
	zButton.updateHitbox();
	add(zButton);
}

function update(elapsed:Float) {
	var cx = joystickBg.x + joystickBg.width / 2;
	var cy = joystickBg.y + joystickBg.height / 2;

	leftPressed = rightPressed = upPressed = downPressed = false;
	joystickX = joystickY = 0;

	var touching = false;
	var tx:Float = 0, ty:Float = 0;

	for (touch in FlxG.touches.list) {
		var p = touch.getWorldPosition(camUndertale, null);
		if (touch.justPressed && p.x >= joystickBg.x && p.x <= joystickBg.x + joystickBg.width &&
			p.y >= joystickBg.y && p.y <= joystickBg.y + joystickBg.height) {
			joystickTouchID = touch.touchPointID;
		}
		if (touch.touchPointID == joystickTouchID && touch.pressed) {
			touching = true; tx = p.x; ty = p.y;
		}

		if (p.x >= zButton.x && p.x <= zButton.x + zButton.width &&
			p.y >= zButton.y && p.y <= zButton.y + zButton.height) {
			if (touch.justPressed) zTouchID = touch.touchPointID;
			if (touch.touchPointID == zTouchID && touch.pressed) zPressed = true;
		}
	}
	if (!touching) joystickTouchID = -1;
	if (zTouchID != -1) {
		var found = false;
		for (touch in FlxG.touches.list) {
			if (touch.touchPointID == zTouchID && touch.pressed) { found = true; break; }
		}
		if (!found) { zTouchID = -1; zPressed = false; }
	}

	var p = FlxG.mouse.getWorldPosition(camUndertale, null);
	if (FlxG.mouse.pressed && p.x >= joystickBg.x && p.x <= joystickBg.x + joystickBg.width &&
		p.y >= joystickBg.y && p.y <= joystickBg.y + joystickBg.height) {
		touching = true; tx = p.x; ty = p.y;
	}
	if (FlxG.mouse.justPressed && p.x >= zButton.x && p.x <= zButton.x + zButton.width &&
		p.y >= zButton.y && p.y <= zButton.y + zButton.height) {
		zPressed = true;
	}
	if (FlxG.mouse.justReleased) zPressed = false;

	if (touching) {
		var dx = tx - cx;
		var dy = ty - cy;
		var dist = Math.sqrt(dx * dx + dy * dy);
		if (dist > joystickRadius) { dx = dx / dist * joystickRadius; dy = dy / dist * joystickRadius; }

		joystickStick.x = cx + dx - joystickStick.width/2;
		joystickStick.y = cy + dy - joystickStick.height/2;

		joystickX = dx / joystickRadius;
		joystickY = dy / joystickRadius;

		if (joystickX < -0.2) leftPressed = true;
		if (joystickX > 0.2) rightPressed = true;
		if (joystickY < -0.2) upPressed = true;
		if (joystickY > 0.2) downPressed = true;
	} else {
		joystickStick.x = cx - joystickStick.width/2;
		joystickStick.y = cy - joystickStick.height/2;
	}
}

public function getJoystickX():Float return joystickX;
public function getJoystickY():Float return joystickY;
public function getJoystickInput():String {
	if (leftPressed) return "LEFT";
	if (rightPressed) return "RIGHT";
	if (upPressed) return "UP";
	if (downPressed) return "DOWN";
	return "";
}
public function isJoystickActive():Bool return leftPressed || rightPressed || upPressed || downPressed;
public function getJoystickLeft():Bool return leftPressed;
public function getJoystickRight():Bool return rightPressed;
public function getJoystickUp():Bool return upPressed;
public function getJoystickDown():Bool return downPressed;
public function getZPressed():Bool return zPressed;