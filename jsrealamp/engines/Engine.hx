package jsrealamp.engines;

import js.html.Float32Array;
import js.html.Uint8Array;


class EngineError {
    public var message:String;

    public function new(message:String) {
        this.message = message;
    }
}


class TrackMetadata {
    public var index:Int;
    public var title:String;
    public var author:String;
    public var album:String;
    public var length:Int;

    public function new() {
    }
}


interface Engine {
    public function isSupported(extension:String, data:Uint8Array):Bool;
    public function open(data:Uint8Array, numBufferSamples:Int):Void;
    public function close():Void;
    public function trackCount():Int;
    public function setTrack(index:Int):Void;
    public function render(buffers:Array<Float32Array>):Void;
    public function tracks():Array<TrackMetadata>;
}
