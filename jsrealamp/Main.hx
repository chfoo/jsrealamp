package jsrealamp;

import js.Browser;

class Main {
    var player:Player;

    public function new(elementId:String) {
        player = new Player(elementId);
    }

    public static function main() {
        Reflect.setField(Browser.window, "JSRealAmp", jsrealamp.Main);
        Browser.document.getElementById("loading_message").style.display = "none";
    }
}
