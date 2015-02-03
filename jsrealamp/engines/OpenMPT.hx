package jsrealamp.engines;

import js.html.Int16Array;
import js.html.Float32Array;
import js.html.Uint8Array;
import jsrealamp.engines.Engine.EngineError;
import jsrealamp.engines.Engine.TrackMetadata;

class OpenMPT implements Engine {
    static var wrapIsSupported = Emscripten.cwrap("OpenMPTWrapper_is_supported", "string", ["string"]);
    static var wrapOpen = Emscripten.cwrap("OpenMPTWrapper_open", "number", ["array", "number"]);
    static var wrapClose = Emscripten.cwrap("OpenMPTWrapper_close", null, ["number"]);
    static var wrapGetError = Emscripten.cwrap("OpenMPTWrapper_get_error", "string", ["number"]);
    static var wrapRender = Emscripten.cwrap("OpenMPTWrapper_render", "number", ["number", "number", "number", "number"]);
    static var wrapGetTrackTitle = Emscripten.cwrap("OpenMPTWrapper_get_track_title", "string", ["number"]);
    static var wrapGetTrackAuthor = Emscripten.cwrap("OpenMPTWrapper_get_track_author", "string", ["number"]);
    static var wrapGetTrackLength = Emscripten.cwrap("OpenMPTWrapper_get_track_length", "number", ["number"]);

    static inline var BYTES_PER_SAMPLE = 2;

    var numBufferSamples:Int;
    var openMptWrapper:Int;
    var emscriptenLeftBufferPointer:Int;
    var emscriptenRightBufferPointer:Int;

    public function new() {
    }

    public function isSupported(extension:String, data:Uint8Array):Bool {
        var result:String = wrapIsSupported(extension);

        if (result == "error") {
            throw new EngineError("Error identifying the file.");
        }

        return result == "yes";
    }

    public function open(data:Uint8Array, numBufferSamples:Int) {
        openMptWrapper = wrapOpen(data, data.byteLength);

        if (openMptWrapper == 0) {
            throw new EngineError("Out of memory.");
        }

        checkError();

        this.numBufferSamples = numBufferSamples;
        emscriptenLeftBufferPointer = Emscripten.malloc(numBufferSamples * BYTES_PER_SAMPLE);
        emscriptenRightBufferPointer = Emscripten.malloc(numBufferSamples * BYTES_PER_SAMPLE);
    }

    public function close() {
        wrapClose(openMptWrapper);
        Emscripten.free(emscriptenLeftBufferPointer);
        Emscripten.free(emscriptenRightBufferPointer);
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
        var framesRendered = wrapRender(
            openMptWrapper,
            emscriptenLeftBufferPointer, emscriptenRightBufferPointer,
            numBufferSamples
        );

        var leftRenderBuffer = new Int16Array(Emscripten.HEAPU8().buffer, emscriptenLeftBufferPointer, numBufferSamples);
        var rightRenderBuffer = new Int16Array(Emscripten.HEAPU8().buffer, emscriptenRightBufferPointer, numBufferSamples);

        var leftBuffer = buffers[0];
        var rightBuffer = buffers[1];

        for (index in 0...numBufferSamples) {
            leftBuffer[index] = leftRenderBuffer[index] / 32768;
            rightBuffer[index] = rightRenderBuffer[index] / 32768;
        }
    }

    public function tracks():Array<TrackMetadata> {
        var track = new TrackMetadata();
        track.index = 0;
        track.title = wrapGetTrackTitle(openMptWrapper);
        track.author = wrapGetTrackAuthor(openMptWrapper);
        track.length = wrapGetTrackLength(openMptWrapper);

        return [track];
    }

    function checkError() {
        var error:String = wrapGetError(openMptWrapper);

        if (error != null && error.length > 0) {
            throw new EngineError(error);
        }
    }
}
