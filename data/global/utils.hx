//

import dustin.DustinUtil;
import hscript.TemplateClass;
import Reflect;

static var DustinUtil = DustinUtil;

public static var forceUpdate:Array<(elapsed:Float)-> Void> = [];

static function scriptObject(script:Script):TemplateClass {
    var scriptClass:TemplateClass = new TemplateClass();
    Reflect.setField(scriptClass, "__interp", script.interp);

    return scriptClass;
}

static function textCrispy(target_text) {
    target_text.textField.antiAliasType = 0/*ADVANCED*/;
    target_text.textField.sharpness = 400/*MAX ON OPENFL*/;
    target_text.antialiasing = false;
    return target_text;
}

function postUpdate(elapsed) {
    for(func in forceUpdate) {
        func(elapsed);
    }
}