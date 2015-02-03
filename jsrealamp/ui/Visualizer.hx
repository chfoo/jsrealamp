package jsrealamp.ui;

import hxColorToolkit.spaces.HSB;
import js.html.CanvasElement;
import js.html.Uint8Array;
import js.html.Element;
import js.html.audio.AnalyserNode;

class Visualizer extends Widget {
    public var analyserNode(default, set):AnalyserNode;
    var dataArray:Uint8Array;
    var canvas:CanvasElement;

    public function new(container:Element) {
        super(container);
//        canvas = cast(getHtmlElement("visualizer_canvas"), CanvasElement);
        canvas = cast getHtmlElement("visualizer_canvas");
        canvas.width = 128;
        canvas.height = 64;
    }

    public function set_analyserNode(newNode:AnalyserNode):AnalyserNode {
        analyserNode = newNode;
        analyserNode.smoothingTimeConstant = 0.2;
        analyserNode.fftSize = 256;
        dataArray = new Uint8Array(newNode.frequencyBinCount);
        return newNode;
    }

    public function draw() {
        if (analyserNode == null) {
            return;
        }

        analyserNode.getByteFrequencyData(dataArray);
        var context = canvas.getContext2d();
        var barWidth = canvas.width / dataArray.length;

        var imageData = context.getImageData(0, 0, 128, 64);
        context.putImageData(imageData, 0, -1);

        for (index in 0...dataArray.length) {
            var freqValue = dataArray[index] / 255;
            // Convert to range from cyan (180 deg) to red (0 deg).
            var hue = 180 - freqValue * 180;
            var value = 100 * Math.log(freqValue * 100 + 1) / Math.log(100);
            var rgb = new HSB(hue, 100, value).toRGB();
            var red = Std.int(rgb.red);
            var green = Std.int(rgb.green);
            var blue = Std.int(rgb.blue);

            context.fillStyle = 'rgb($red, $green, $blue)';
            context.fillRect(index * barWidth, 63, barWidth, 1);
        }
    }
}
