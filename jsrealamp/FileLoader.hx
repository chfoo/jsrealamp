package jsrealamp;

import js.html.XMLHttpRequest;
import js.html.ProgressEvent;
import js.html.FileReader;

class FileLoaderStatus {
    public var data:Dynamic;
    public var progress:Float;
    public var ok:Bool;
    public var changeCallback:Void->Void;

    public function new() {
    }

    public function callChangedCallback() {
        if (changeCallback != null) {
            changeCallback();
        }
    }
}


class FileLoader {
    public static function openFile(file:js.html.File, callback:FileLoaderStatus->Void):FileLoaderStatus {
        var status = new FileLoaderStatus();
        var fileReader = new FileReader();

        fileReader.onloadend = function (event:Dynamic) {
            status.data = fileReader.result;
            status.ok = true;
            status.callChangedCallback();
            callback(status);
        }

        fileReader.onerror = fileReader.onabort = function (event:Dynamic) {
            status.ok = false;
            status.callChangedCallback();
            callback(status);
        }

        fileReader.onprogress = function (event:ProgressEvent) {
            status.progress = event.loaded / event.total;
            status.callChangedCallback();
        }

        fileReader.readAsArrayBuffer(file);

        return status;
    }

    public static function openUrl(url:String, responseType:String, callback:FileLoaderStatus->Void):FileLoaderStatus {
        var status = new FileLoaderStatus();
        var httpClient = new XMLHttpRequest();

        httpClient.open("GET", url, true);
        httpClient.responseType = responseType;

        httpClient.onreadystatechange = function (event:Dynamic) {
            if (httpClient.readyState != XMLHttpRequest.DONE) {
                return;
            }

            if (httpClient.status == 200) {
                status.data = httpClient.response;
                status.ok = true;
            } else {
                status.ok = false;
            }
            status.callChangedCallback();
            callback(status);
        }

        httpClient.onprogress = function (event:ProgressEvent) {
            status.progress = event.loaded / event.total;
            status.callChangedCallback();
        }

        httpClient.send();

        return status;
    }
}
