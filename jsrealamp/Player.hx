package jsrealamp;

import jsrealamp.FileLoader.FileLoaderStatus;
import jsrealamp.FileLoader.FileLoaderStatus;
import jsrealamp.engines.OpenMPT;
import jsrealamp.Audio.NoAudioContextError;
import jsrealamp.ui.OpenFileDialog.FileSelection;
import js.Browser;
import js.html.Uint8Array;
import js.html.ArrayBuffer;
import jsrealamp.engines.GME;
import jsrealamp.engines.Engine;
import jsrealamp.ui.PlayerWindow;
import js.html.File;

class Player {
    static var ENGINES:Array<Class<Engine>> = [GME, OpenMPT];

    var window:PlayerWindow;
    var engine:Engine;
    var audio:Audio;
    var currentTrackIndex:Int;
    var tracks:Array<TrackMetadata>;

    public function new(elementId:String) {
        var container = Browser.document.getElementById(elementId);
        window = new PlayerWindow(container);

        window.filesSelectedCallback = filesSelectedCallback;
        window.controlButtonCallback = controlButtonCallback;

        populateExamplesManifest();
    }

    function populateExamplesManifest() {
        FileLoader.openUrl("examples.json", "json", function (status:FileLoaderStatus) {
            if (status.ok) {
                window.populateExampleFiles(status.data);
            }
        });
    }

    function filesSelectedCallback(fileSelection:FileSelection) {
        if (fileSelection == null) {
            window.showMessageDialog("Please select a file.");
            return;
        }

        if (fileSelection.source == "file_input") {
            var file:js.html.File = fileSelection.file;

            FileLoader.openFile(file, function (status:FileLoaderStatus) {
                if (status.ok) {
                    setUpAudio(file.name, status.data);
                } else {
                    window.showMessageDialog("Unable to open the file.");
                }
            });
        } else if (fileSelection.source == "url") {
            FileLoader.openUrl(fileSelection.file, "arraybuffer", function (status:FileLoaderStatus) {
                if (status.ok) {
                    setUpAudio(fileSelection.file, status.data);
                } else {
                    window.showMessageDialog("Unable to open the file.");
                }
            });
        }
    }

    function controlButtonCallback(elementId:String) {
        switch (elementId) {
        case "play_button":
            play();
        case "pause_button":
            pause();
        case "next_button":
            nextTrack();
        case "previous_button":
            previousTrack();
        }
    }

    function play() {
        audio.start();
        window.visualizer.analyserNode = audio.newAnalyser();
        window.setControlButtonDisabled("play_button", true);
        window.setControlButtonDisabled("pause_button", false);
    }

    function pause() {
        audio.stop();
        window.setControlButtonDisabled("play_button", false);
        window.setControlButtonDisabled("pause_button", true);
    }

    function nextTrack() {
        if (currentTrackIndex == tracks.length - 1) {
            currentTrackIndex = 0;
        } else {
            currentTrackIndex += 1;
        }

        playTrack(currentTrackIndex);
    }

    function previousTrack() {
        if (currentTrackIndex == 0) {
            currentTrackIndex = tracks.length - 1;
        } else {
            currentTrackIndex -= 1;
        }

        playTrack(currentTrackIndex);
    }

    function playTrack(index:Int) {
        currentTrackIndex = index;
        engine.setTrack(currentTrackIndex);
        audio.resetCounters();
    }

    function setUpAudio(filename:String, fileData:ArrayBuffer) {
        if (audio != null) {
            audio.close();
        }

        if (engine != null) {
            engine.close();
        }

        try {
            engine = getEngine(filename, fileData);
            audio = new Audio(engine, fileData);
        } catch (error:EngineError) {
            window.showMessageDialog("Unable to start music engine.", error.message);
            return;
        } catch (error:NoAudioContextError) {
            window.showMessageDialog("Your browser does not support Web Audio.");
            return;
        }

        populatePlayer();
        play();
    }

    function getEngine(filename:String, fileData:ArrayBuffer):Engine {
        var extension = filename.substr(filename.lastIndexOf("."), 6).toLowerCase();

        trace(extension);

        for (engineClass in ENGINES) {
            trace('checking ${Type.getClassName(engineClass)}');
            var engine:Engine = Type.createInstance(engineClass, []);

            if (engine.isSupported(extension, new Uint8Array(fileData))) {
                return engine;
            }
        }

        throw new EngineError("File is not supported.");
    }

    function populatePlayer() {
        engine.setTrack(0);
        currentTrackIndex = 0;
        tracks = engine.tracks();

        window.populateTracks(tracks);

        audio.updateCallback = function() {
            var duration = Std.int(audio.samplesPlayed / 44100 * 1000);
            var track = tracks[currentTrackIndex];

            window.populateCurrentTrack(duration, track);

            if (duration >= track.length) {
                if (currentTrackIndex == tracks.length - 1) {
                    playTrack(0);
                } else {
                    nextTrack();
                }
            }

            Browser.window.requestAnimationFrame(function (timestamp:Float):Bool {
                window.draw();
                return true;
            });
        }

        window.setControlButtonDisabled("previous_button", false);
        window.setControlButtonDisabled("next_button", false);

        window.volumeChangeCallback = function (newValue:Int) {
            audio.volume = newValue / 100;
        }
    }
}
