package jsrealamp.engines;

import jsrealamp.engines.Engine.TrackMetadata;
import js.html.Float32Array;
import js.html.Uint8Array;
import jsrealamp.engines.Engine.EngineError;

class MilkyPlay implements Engine {
    static var wrapOpen = Emscripten.cwrap("MilkyPlayWrapper_open", "number", ["array", "number"]);
    static var wrapClose = Emscripten.cwrap("MilkyPlayWrapper_close", null, ["number"]);
    static var wrapGetError = Emscripten.cwrap("MilkyPlayWrapper_get_error", "number", ["number"]);

    var milkyPlayWrapper:Int;

    public function new() {
    }

    public function isSupported(extension:String, data:Uint8Array):Bool {
        return false;
    }

    public function open(data:Uint8Array, numBufferSamples:Int) {
        milkyPlayWrapper = wrapOpen(data, data.byteLength);
        checkError();
    }

    public function close() {
        wrapClose(milkyPlayWrapper);
    }

    public function trackCount():Int {
        return 1;
    }

    public function setTrack(index:Int) {
        if (index != 0) {
            throw new EngineError("Track selection not supported.");
        }
    }
    public function render(buffers:Array<Float32Array>) {

    }

    public function tracks():Array<TrackMetadata> {
        return null;
    }

    function checkError() {
        var error:Int = wrapGetError(milkyPlayWrapper);

        if (error != 0) {
            throw new EngineError('MilkyPlay error $error');
        }
    }
}
