package jsrealamp;

import js.Browser;
import js.html.audio.GainNode;
import js.html.audio.AnalyserNode;
import js.html.ArrayBuffer;
import js.html.Uint8Array;
import js.html.audio.ScriptProcessorNode;
import js.html.audio.AudioBufferSourceNode;
import js.html.audio.AudioBuffer;
import js.html.audio.AudioContext;
import jsrealamp.engines.Engine;

enum State {
    Playing;
    Stopped;
}

class NoAudioContextError {
    public var message:String;

    public function new(message:String) {
        this.message = message;
    }
}

class Audio {
    static inline var NUM_BUFFER_SAMPLES = 4096;

    public var updateCallback:Void->Void;

    var engine:Engine;
    static var audioContext:AudioContext;
    var audioBuffer:AudioBuffer;
    var audioBufferSource:AudioBufferSourceNode;
    var audioScriptNode:ScriptProcessorNode;
    var gainNode:GainNode;
    public var samplesPlayed(default, null) = 0;
    var state = State.Stopped;
    public var volume(get, set):Float;

    public function new(engine:Engine, fileData:ArrayBuffer) {
        this.engine = engine;

        engine.open(new Uint8Array(fileData), NUM_BUFFER_SAMPLES);

        if (audioContext == null) {
            var audioContextClass:Class<AudioContext> = Reflect.field(Browser.window, "AudioContext");

            if (audioContextClass == null) {
                audioContextClass = Reflect.field(Browser.window, "webkitAudioContext");
            }

            if (audioContextClass == null) {
                throw new NoAudioContextError("No AudioContext available");
            }

            audioContext = Type.createInstance(audioContextClass, []);
        }
        audioBuffer = audioContext.createBuffer(2, NUM_BUFFER_SAMPLES, 44100);
    }

    public function close() {
        stop();
        updateCallback = null;
        audioBuffer = null;
    }

    public function start() {
        if (state == State.Stopped) {
            audioBufferSource = audioContext.createBufferSource();
            audioBufferSource.buffer = audioBuffer;
            audioScriptNode = audioContext.createScriptProcessor(NUM_BUFFER_SAMPLES);
            audioScriptNode.onaudioprocess = renderSamples;
            gainNode = audioContext.createGain();

            audioBufferSource.connect(audioScriptNode, 0, 0);
            audioScriptNode.connect(gainNode, 0, 0);
            gainNode.connect(audioContext.destination, 0, 0);
            audioBufferSource.start(0);
        }

        state = State.Playing;
    }

    public function stop() {
        if (state == State.Playing) {
            audioBufferSource.disconnect(0);
            audioScriptNode.disconnect(0);
            gainNode.disconnect(0);
            audioBufferSource.stop(0);
            audioBufferSource = null;
            audioScriptNode = null;
            gainNode = null;
        }

        state = State.Stopped;
    }

    function renderSamples(event:Dynamic) {
        if (state != State.Playing) {
            return;
        }

        engine.render([event.outputBuffer.getChannelData(0), event.outputBuffer.getChannelData(1)]);
        samplesPlayed += NUM_BUFFER_SAMPLES;

        if (updateCallback != null) {
            updateCallback();
        }
    }

    public function resetCounters() {
        samplesPlayed = 0;
    }

    public function newAnalyser():AnalyserNode {
        var node = audioContext.createAnalyser();
        audioScriptNode.connect(node, 0, 0);
        return node;
    }

    function get_volume() {
        return gainNode.gain.value;
    }

    function set_volume(value:Float):Float {
        gainNode.gain.value = value;
        return value;
    }
}
