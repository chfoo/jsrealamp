package jsrealamp.engines;

import jsrealamp.Emscripten;
import js.html.Int16Array;
import js.html.Float32Array;
import js.html.Uint8Array;
import jsrealamp.engines.Engine.EngineError;
import jsrealamp.engines.Engine.TrackMetadata;

class GME implements Engine {
    static var wrapIsSupported = Emscripten.cwrap("GMEWrapper_is_supported", "number", ["string"]);
    static var wrapOpen = Emscripten.cwrap("GMEWrapper_open", "number", ["array", "number"]);
    static var wrapClose = Emscripten.cwrap("GMEWrapper_close", null, ["number"]);
    static var wrapGetError = Emscripten.cwrap("GMEWrapper_get_error", "string", ["number"]);
    static var wrapGetTrackCount = Emscripten.cwrap("GMEWrapper_get_track_count", "number", ["number"]);
    static var wrapSetTrackIndex = Emscripten.cwrap("GMEWrapper_set_track_index", null, ["number", "number"]);
    static var wrapRender = Emscripten.cwrap("GMEWrapper_render", null, ["number", "number", "number"]);
    static var wrapGetTrackTitle = Emscripten.cwrap("GMEWrapper_get_track_title", "string", ["number", "number"]);
    static var wrapGetTrackAuthor = Emscripten.cwrap("GMEWrapper_get_track_author", "string", ["number", "number"]);
    static var wrapGetTrackAlbum = Emscripten.cwrap("GMEWrapper_get_track_album", "string", ["number", "number"]);
    static var wrapGetTrackLength = Emscripten.cwrap("GMEWrapper_get_track_length", "int", ["number", "number"]);

    static inline var BYTES_PER_SAMPLE = 2;
    static inline var CHANNELS = 2;

    var numBufferSamples:Int;
    var gmeWrapper:Int;
    var defaultLength:Int;
    var emscriptenBufferPointer:Int;

    public function new(defaultLength:Int = 3 * 60 * 1000) {
        this.defaultLength = defaultLength;
    }

    public function isSupported(extension:String, data:Uint8Array):Bool {
        return wrapIsSupported(extension) != 0;
    }

    public function open(data:Uint8Array, numBufferSamples:Int) {
        gmeWrapper = wrapOpen(data, data.byteLength);

        if (gmeWrapper == 0) {
            throw new EngineError("Out of memory.");
        }

        checkError();

        this.numBufferSamples = numBufferSamples;
        emscriptenBufferPointer = Emscripten.malloc(numBufferSamples * BYTES_PER_SAMPLE * CHANNELS);
    }

    public function close() {
        wrapClose(gmeWrapper);
        Emscripten.free(emscriptenBufferPointer);
    }

    public function trackCount():Int {
         return wrapGetTrackCount(gmeWrapper);
    }

    public function setTrack(index:Int) {
        wrapSetTrackIndex(gmeWrapper, index);
        checkError();
    }

    public function render(buffers:Array<Float32Array>) {
        var numFrames = numBufferSamples * CHANNELS;
        wrapRender(gmeWrapper, emscriptenBufferPointer, numFrames);
        var renderBuffer = new Int16Array(Emscripten.HEAPU8().buffer, emscriptenBufferPointer, numFrames);

        var leftBuffer = buffers[0];
        var rightBuffer = buffers[1];

        for (index in 0...numBufferSamples) {
            leftBuffer[index] = renderBuffer[index * 2] / 32768;
            rightBuffer[index] = renderBuffer[index * 2 + 1] / 32768;
        }
    }

    public function tracks():Array<TrackMetadata> {
        var tracks = new Array<TrackMetadata>();

        for (index in 0...trackCount()) {
            var meta = new TrackMetadata();
            meta.index = index;
            meta.title = wrapGetTrackTitle(gmeWrapper, index);
            meta.author = wrapGetTrackAuthor(gmeWrapper, index);
            meta.album = wrapGetTrackAlbum(gmeWrapper, index);
            meta.length = wrapGetTrackLength(gmeWrapper, index);

            if (meta.length == 0) {
                meta.length = defaultLength;
            }

            tracks.push(meta);
        }

        return tracks;
    }

    function checkError() {
        var error:String = wrapGetError(gmeWrapper);

        if (error != null && error.length > 0) {
            throw new EngineError(error);
        }
    }
}
