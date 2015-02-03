package jsrealamp.ui;

import js.Browser;
import js.html.OptionElement;
import js.html.SelectElement;
import js.html.Element;
import js.html.InputElement;

typedef FileSelection = {
    source:String,
    file:Dynamic
}

class OpenFileDialog extends DialogWindow {
    var fileInput:InputElement;
    var urlInput:InputElement;
    var exampleSelect:SelectElement;

    public function new(parentWindow:Window, container:Element) {
        super(parentWindow, container);
//        fileInput = cast(getHtmlElement("file_input"), InputElement);
        fileInput = cast getHtmlElement("file_input");
        urlInput = cast getHtmlElement("url_input");
//        exampleSelect = cast(getHtmlElement("example_select"), SelectElement);
        exampleSelect = cast getHtmlElement("example_select");

    }

    public function getSelection():FileSelection {
        if (fileInput.files.length != 0) {
            return {
                source: "file_input",
                file: fileInput.files[0]
            }
        } else if (urlInput.value.length > 0) {
            return {
                source: "url",
                file: urlInput.value
            }
        } else if (exampleSelect.selectedIndex > 0) {
//            var optionElement:OptionElement = cast(exampleSelect.options[exampleSelect.selectedIndex], OptionElement);
            var optionElement:OptionElement = cast exampleSelect.options[exampleSelect.selectedIndex];
            return {
                source: "url",
                file: optionElement.value
            }
        } else {
            return null;
        }
    }

    public function populateExampleFiles(filenames:Array<String>) {
        for (filename in filenames) {
            var opt = Browser.document.createOptionElement();
            opt.value = filename;
            opt.textContent = filename;
            exampleSelect.appendChild(opt);
        }
    }
}
