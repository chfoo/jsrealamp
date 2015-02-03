package jsrealamp.ui;

import js.html.ButtonElement;
import js.html.Element;

typedef DialogWindowButtonCallback = DialogWindow->String->Void;


class DialogWindow extends Widget {
    var parent:Window;
    public var actionCallback:DialogWindowButtonCallback;

    public function new(parentWindow:Window, container:Element) {
        super(container);
        parent = parentWindow;

        setUpButtonBarEvents();
    }

    function setUpButtonBarEvents() {
        var buttonBar = getHtmlElement("button_bar");
        var buttons = buttonBar.querySelectorAll("button");

        for (item in buttons) {
//            var button = cast(item, ButtonElement);
            var button:ButtonElement = cast item;
            var buttonValue = button.getAttribute("data-value");
            button.onclick = function (event:Dynamic) {
                actionCallback(this, buttonValue);
            }
        }
    }

    public function show() {
        container.style.display = "block";
    }

    public function hide() {
        container.style.display = "none";
    }
}
