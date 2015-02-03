package jsrealamp.ui;

import js.html.Element;

class Window extends Widget {
    var content:Element;
    var currentDialogWindow:DialogWindow;
    var titlebarDraggable:Draggable;

    public function new(container:Element) {
        super(container);
        content = getHtmlElement("content");
        titlebarDraggable = new Draggable(getHtmlElement("titlebar"));
        titlebarDraggable.target = container;
        titlebarDraggable.minX = 0;
        titlebarDraggable.minY = 0;
    }

    function showDialog(dialogWindow:DialogWindow) {
        currentDialogWindow = dialogWindow;
        currentDialogWindow.show();
        disableContents();
    }

    function hideDialog() {
        currentDialogWindow.hide();
        enableContents();
    }

    function disableContents() {
        content.style.opacity = "0.5";
    }

    function enableContents() {
        content.style.opacity = "1";
    }

    public function showMessageDialog(message:String, ?secondaryMessage:String) {
        var dialog = new MessageDialog(
            this, getHtmlElement("message_dialog"), message, secondaryMessage
        );
        showDialog(dialog);

        dialog.actionCallback = function (dialog:DialogWindow, buttonValue:String) {
            hideDialog();
        }
    }
}
