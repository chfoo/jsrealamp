JSRealAmp
=========

Music player in pure JavaScript.


Quick Start
===========

Quick start instructions for Unix-like system.

Requirements
++++++++++++

Tools:

* `Emscripten <http://emscripten.org/>`_ (1.29)
* `Haxe <http://haxe.org/>`_ (3.1.3)

Music engines:

* `Game Music Emu <https://code.google.com/p/game-music-emu/>`_ (r48)
* `OpenMPT <http://lib.openmpt.org/libopenmpt/>`_ (libopenmpt-0.2.4667-beta9.tar.gz)


Build
+++++

Simply run::

    make

This will generate ``lib.js`` and ``ui.js``.

To quickly start a web server use: ``python -m SimpleHTTPServer`` or ``python3 -m http.server``.


TODO
====

* Better track and playlist management
* MilkyTracker
* Something to read USF files
* Unrar for RSN files containg SPC files
* SoX


Credits
=======

Copyright 2015 by Christoper Foo <chris.foo@gmail.com>. Licensed under GPL v3

