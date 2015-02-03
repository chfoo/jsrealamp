package jsrealamp.ui;

import js.html.Element;

class MessageDialog extends DialogWindow {

    public function new(parentWindow:Window, container:Element, message:String, ?secondaryMessage:String) {
        super(parentWindow, container);

        getHtmlElement("message").textContent = message;

        if (secondaryMessage != null) {
            getHtmlElement("secondary-message").textContent = secondaryMessage;
        }
    }
}
