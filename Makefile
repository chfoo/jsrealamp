.PHONY: jsmusicplayer gme milkyplay openmpt jslib

all: gme jslib jsui

jsui:
	haxe -main jsrealamp.Main -cp src -js ui.js -lib hxColorToolkit

gme:
	cd game-music-emu && emconfigure cmake
	cd game-music-emu && emmake make

milkyplay:
	cd milkytracker && emconfigure autoreconf -i
	cd milkytracker && emconfigure ./configure --without-alsa --without-jack --disable-sdltest
	cd milkytracker/src/milkyplay/ && emmake make

openmpt:
	ln -s patch/openmpt/Makefile.config.jsrealamp openmpt/build/make/
	cd openmpt && make CONFIG=jsrealamp

jslib:
	emcc -v \
		-O1 \
		game-music-emu/gme/libgme.so \
		openmpt/bin/libopenmpt.so \
		wrappers/gme_wrap.cpp -I game-music-emu/ \
		wrappers/openmpt_wrap.cpp -I openmpt/ \
		-o lib.js \
		-s DEMANGLE_SUPPORT=1 \
		-s EXPORTED_FUNCTIONS="[ \
			'_GMEWrapper_is_supported', \
			'_GMEWrapper_open', \
			'_GMEWrapper_close', \
			'_GMEWrapper_get_error', \
			'_GMEWrapper_get_track_count', \
			'_GMEWrapper_set_track_index', \
			'_GMEWrapper_render', \
			'_GMEWrapper_get_track_title', \
			'_GMEWrapper_get_track_author', \
			'_GMEWrapper_get_track_album', \
			'_GMEWrapper_get_track_length', \
			'_OpenMPTWrapper_is_supported', \
			'_OpenMPTWrapper_open', \
			'_OpenMPTWrapper_close', \
			'_OpenMPTWrapper_get_error', \
			'_OpenMPTWrapper_render', \
			'_OpenMPTWrapper_get_track_title', \
			'_OpenMPTWrapper_get_track_author', \
			'_OpenMPTWrapper_get_track_length', \
		]"

		# milkytracker/src/milkyplay/.libs/libmilkyplay.so \
		# wrappers/milkyplay_wrap.cpp -I milkytracker/src/ \
		# '_MilkyPlayWrapper_open', \
		# '_MilkyPlayWrapper_close', \
		# '_MilkyPlayWrapper_get_error', \
