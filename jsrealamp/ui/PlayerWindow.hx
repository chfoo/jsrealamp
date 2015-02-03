package jsrealamp.ui;

import jsrealamp.ui.OpenFileDialog.FileSelection;
import js.html.EventListener;
import js.html.TableSectionElement;
import js.html.TableRowElement;
import js.html.TableElement;
import js.html.TableElement;
import jsrealamp.engines.Engine.TrackMetadata;
import js.html.Element;


class PlayerWindow extends Window {
    public var filesSelectedCallback:FileSelection->Void;
    public var controlButtonCallback:String->Void;
    public var volumeChangeCallback:Int->Void;

    var openDialog:OpenFileDialog;
    var aboutDialog:DialogWindow;

    public var visualizer(default, null):Visualizer;
    var seekBar:Slider;
    var volumeSlider:Slider;

    public function new(container:Element) {
        super(container);

        initOpenDialog();
        initControls();
        initVolumeSlider();
        initAboutDialog();

        visualizer = new Visualizer(getHtmlElement("visualizer"));
        seekBar = new Slider(getHtmlElement("seek_bar"));
    }

    function initOpenDialog() {
        openDialog = new OpenFileDialog(this, getHtmlElement("open_dialog"));
        openDialog.actionCallback = openDialogCallback;

        var openButton = getHtmlElement("open_button");
        openButton.onclick = function (event:Dynamic) {
            showDialog(openDialog);
        };
    }

    function openDialogCallback(dialog:DialogWindow, buttonValue:String) {
        hideDialog();

        if (buttonValue == "open") {
            filesSelectedCallback(openDialog.getSelection());
        }
    }

    function initControls() {
        for (elementId in ["previous_button", "next_button", "play_button", "pause_button"]) {
            var element = getHtmlElement(elementId);

            element.onclick = function (event:EventListener) {
                controlButtonCallback(elementId);
            }
        }
    }

    function initVolumeSlider() {
        volumeSlider = new Slider(getHtmlElement("volume_slider"));
        volumeSlider.max = 100;
        volumeSlider.value = 100;

        volumeSlider.draw();

        volumeSlider.changeCallback = function (newValue:Int) {
            if (volumeChangeCallback != null) {
                volumeChangeCallback(newValue);
            }
        }
    }

    function initAboutDialog() {
        aboutDialog = new DialogWindow(this, getHtmlElement("about_dialog"));
        aboutDialog.actionCallback = function (dialog:DialogWindow, buttonValue:String) {
            hideDialog();
        }

        var aboutButton = getHtmlElement("about_button");
        aboutButton.onclick = function (event:Dynamic) {
            showDialog(aboutDialog);
        }
    }

    public function populateTracks(tracks:Array<TrackMetadata>) {
        var count = tracks.length;
        getHtmlElement("track_count").textContent = '$count';

//        var table = cast(getHtmlElement("playlist_table"), TableElement);
//        var tableBody = cast(getHtmlElement("playlist_table_body"), TableSectionElement);
        var table:TableElement = cast getHtmlElement("playlist_table");
        var tableBody:TableSectionElement = cast getHtmlElement("playlist_table_body");

        while (tableBody.childNodes.length > 0) {
            tableBody.removeChild(tableBody.childNodes.item(0));
        };

        for (index in 0...count) {
            var track = tracks[index];
//            var row = cast(tableBody.insertRow(-1), TableRowElement);
            var row:TableRowElement = cast tableBody.insertRow(-1);

            var trackCell = row.insertCell(-1);
            var titleCell = row.insertCell(-1);
            var lengthCell = row.insertCell(-1);

            trackCell.textContent = '${index + 1}';
            trackCell.classList.add("numeric");
            titleCell.textContent = track.title;
            lengthCell.textContent = Format.toTimeCode(Std.int(track.length));
            lengthCell.classList.add("numeric");

            row.appendChild(trackCell);
            row.appendChild(titleCell);
            row.appendChild(lengthCell);
            tableBody.appendChild(row);
        }
    }

    public function populateCurrentTrack(duration:Int, track:TrackMetadata) {
        getHtmlElement("track_index").textContent = '${track.index + 1}';
        getHtmlElement("track_title").textContent = track.title;
        getHtmlElement("track_author").textContent = track.author;
        getHtmlElement("track_album").textContent = track.album;
        getHtmlElement("track_length").textContent = Format.toTimeCode(Std.int(track.length));
        getHtmlElement("duration").textContent = Format.toTimeCode(Std.int(duration));
        seekBar.max = track.length;
        seekBar.value = duration;
    }

    public function setControlButtonDisabled(elementId:String, disabled:Bool) {
        var element = getHtmlElement(elementId);

        if (disabled) {
            element.setAttribute("disabled", "disabled");
        } else {
            element.removeAttribute("disabled");
        }
    }

    public function draw() {
        seekBar.draw();
        visualizer.draw();
    }

    public function populateExampleFiles(filenames:Array<String>) {
        openDialog.populateExampleFiles(filenames);
    }
}
