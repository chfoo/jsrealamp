package jsrealamp.ui;

import js.html.KeyboardEvent;
import js.html.MouseEvent;
import js.html.Element;

class Slider extends Widget {
    var thumb:Element;
    var thumbDraggable:Draggable;
    public var min = 0;
    public var max = 1;
    public var value = 0;
    public var changeCallback:Int->Void;

    public function new(container:Element) {
        super(container);
        thumb = getHtmlElement("slider_thumb");
        thumbDraggable = new Draggable(thumb);
        thumbDraggable.dragY = false;
        thumbDraggable.minX = 0;

        thumb.addEventListener("mousedown", function (event:MouseEvent) {
            thumbDraggable.maxX = container.clientWidth - 16;
        });
        thumb.onkeydown = keyPressListener;

        thumbDraggable.changeCallback = function (x:Float, y:Float) {
            if (changeCallback != null) {
                changeCallback(Std.int(x / container.clientWidth * (max - min) + min));
            }
        }
    }

    public function draw() {
        var clientWidth = container.clientWidth - 16;
        var leftPx = value / (max - min) * clientWidth;
        thumb.style.left = '${leftPx}px';
        container.setAttribute("aria-valuemax", Std.string(max));
        container.setAttribute("aria-valuemin", Std.string(min));
        container.setAttribute("aria-valuenow", Std.string(value));
    }

    function keyPressListener(event:KeyboardEvent) {
        var key = event.keyIdentifier;

        if (key == null) {
            key = Reflect.field(event, "key");
        }

        var increment = Std.int((max - min) / 10);

        if (key == "Up" || key == "Right") {
            value += increment;
        } else if (key == "Down" || key == "Left") {
            value -= increment;
        }

        value = Std.int(Math.max(min, value));
        value = Std.int(Math.min(max, value));

        if (changeCallback != null) {
            changeCallback(value);
        }

        draw();
    }
}
