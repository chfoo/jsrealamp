package jsrealamp.ui;

import js.html.Element;

class Widget {
    var container:Element;

    public function new(container:Element) {
        this.container = container;
    }

    function getHtmlElement(name:String):Element {
        return container.querySelector('[data-id=\'$name\']');
    }
}
