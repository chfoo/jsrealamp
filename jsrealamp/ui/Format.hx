package jsrealamp.ui;

using StringTools;

class Format {
    public static function toTimeCode(milliseconds:Int):String {
        var seconds = Std.int(milliseconds / 1000);
        var minutes = Std.int(seconds / 60);
        seconds %= 60;
        var secondsString = Std.string(seconds).lpad("0", 2);
        return '$minutes:$secondsString';
    }
}
