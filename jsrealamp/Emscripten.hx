package jsrealamp;

import js.html.Uint8Array;

class Emscripten {
    public static inline function HEAPU8():Uint8Array {
        return untyped __js__("Module").HEAPU8;
    }

    public static inline function cwrap(func:String, returnType:String, parameters:Array<String>):Dynamic {
        return untyped __js__("Module").cwrap(func, returnType, parameters);
    }

    public static inline function malloc(bytes:Int):Int {
        return untyped __js__("Module")._malloc(bytes);
    }

    public static inline function free(buffer:Int):Int {
        return untyped __js__("Module")._free(buffer);
    }

    public static inline function getValue(pointer:Int, type:String):Int {
        return untyped __js__("Module").getValue(pointer, type);
    }

    public static inline function setValue(pointer:Int, value:Int, type:String):Void {
        untyped __js__("Module").setValue(pointer, value, type);
    }
}
