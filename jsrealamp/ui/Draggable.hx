package jsrealamp.ui;

import js.html.Touch;
import js.html.MouseEvent;
import js.html.TouchEvent;
import js.Browser;
import js.html.Element;

class Draggable extends Widget {
    public var target:Element;
    public var minX:Int;
    public var maxX:Int;
    public var minY:Int;
    public var maxY:Int;
    public var dragX = true;
    public var dragY = true;
    var originClickX:Float;
    var originClickY:Float;
    var originTouchId:Int;
    public var changeCallback:Float->Float->Void;

    public function new(container:Element) {
        super(container);
        target = container;

        container.onmousedown = mouseDownListener;
        container.ontouchstart = touchStartLisenter;
    }

    function mouseDownListener(event:MouseEvent) {
        originClickX = event.pageX - target.offsetLeft;
        originClickY = event.pageY - target.offsetTop;
        Browser.document.addEventListener("mouseup", mouseUpListener);
        Browser.document.addEventListener("mousemove", moveListener);
    }

    function mouseUpListener(event:MouseEvent) {
        Browser.document.removeEventListener("mouseup", mouseUpListener);
        Browser.document.removeEventListener("mousemove", moveListener);
    }

    function moveListener(event:MouseEvent) {
        var x = event.pageX - originClickX;
        var y = event.pageY - originClickY;

        applyPosition(x, y);
    }

    function touchStartLisenter(event:TouchEvent) {
        trace('touch start $event');
        var touch:Touch = event.targetTouches[0];
        originTouchId = touch.identifier;
        originClickX = touch.pageX;
        originClickY = touch.pageY;
        Browser.document.addEventListener("touchend", touchEndListener);
        Browser.document.addEventListener("touchcancel", touchEndListener);
        Browser.document.addEventListener("touchmove", touchMoveListener);
        event.preventDefault();
    }

    function touchEndListener(event:TouchEvent) {
        trace('touch end $event');
        Browser.document.removeEventListener("touchend", touchEndListener);
        Browser.document.removeEventListener("touchcancel", touchEndListener);
        Browser.document.removeEventListener("touchmove", touchMoveListener);
        originTouchId = null;
    }

    function touchMoveListener(event:TouchEvent) {
        trace('touch move $event');
        for (item in event.changedTouches) {
            var touch:Touch = item;
            if (touch.identifier == originTouchId) {
                var x = touch.pageX - originClickX;
                var y = touch.pageY - originClickY;

                event.preventDefault();
                applyPosition(x, y);
            }
        }
    }

    function applyPosition(x:Float, y:Float) {
        if (minX != null) {
            x = Math.max(minX, x);
        }

        if (minY != null) {
            y = Math.max(minY, y);
        }

        if (maxX != null) {
            x = Math.min(maxX, x);
        }

        if (maxY != null) {
            y = Math.min(maxY, y);
        }

        if (dragX) {
            target.style.left = '${x}px';
        }

        if (dragY) {
            target.style.top = '${y}px';
        }

        if (changeCallback != null) {
            changeCallback(x, y);
        }
    }

}
