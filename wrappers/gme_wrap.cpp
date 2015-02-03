#include <stdlib.h>
#include <stdint.h>
#include <memory.h>
#include <gme/gme.h>

typedef struct GMEWrapperState {
    Music_Emu* emu;
    gme_info_t* track_metadata;
    gme_err_t error;
} GMEWrapper;

extern "C" {

bool GMEWrapper_is_supported(const char * extension) {
    return gme_identify_extension(extension) != 0;
}

GMEWrapper* GMEWrapper_open(uint8_t* data, long size) {
    GMEWrapper* wrapper = (GMEWrapper*) malloc(sizeof(GMEWrapper));

    if (!wrapper) {
        return 0;
    }
    memset(wrapper, 0, sizeof(GMEWrapper));

    Music_Emu* emu;
    gme_err_t error = gme_open_data(data, size, &emu, 44100);

    if (error) {
        wrapper->error = error;
    } else {
        wrapper->emu = emu;
        gme_enable_accuracy(wrapper->emu, 1);
    }

    return wrapper;
}

void GMEWrapper_close(GMEWrapper* wrapper) {
    gme_delete(wrapper->emu);
    free(wrapper);
}

const char* GMEWrapper_get_error(GMEWrapper* wrapper) {
    return wrapper->error;
}

int GMEWrapper_get_track_count(GMEWrapper* wrapper) {
    return gme_track_count(wrapper->emu);
}

void GMEWrapper_set_track_index(GMEWrapper* wrapper, int index) {
    wrapper->error = gme_start_track(wrapper->emu, index);
}

void GMEWrapper_render(GMEWrapper* wrapper, int16_t* buffer, int numFrames) {
    wrapper->error = gme_play(wrapper->emu, numFrames, buffer);
}

void GMEWrapper_fill_track_metadata(GMEWrapper* wrapper, int track_index) {
    wrapper->error = gme_track_info(wrapper->emu, &wrapper->track_metadata,
            track_index);
}

const char* GMEWrapper_get_track_title(GMEWrapper* wrapper, int track_index) {
    GMEWrapper_fill_track_metadata(wrapper, track_index);
    return wrapper->track_metadata->song;
}

const char* GMEWrapper_get_track_author(GMEWrapper* wrapper, int track_index) {
    GMEWrapper_fill_track_metadata(wrapper, track_index);
    return wrapper->track_metadata->author;
}

const char* GMEWrapper_get_track_album(GMEWrapper* wrapper, int track_index) {
    GMEWrapper_fill_track_metadata(wrapper, track_index);
    return wrapper->track_metadata->game;
}

unsigned int GMEWrapper_get_track_length(GMEWrapper* wrapper, int track_index) {
    GMEWrapper_fill_track_metadata(wrapper, track_index);

    if (wrapper->track_metadata->length != -1) {
        return wrapper->track_metadata->length;
    } else if (wrapper->track_metadata->intro_length != -1
            && wrapper->track_metadata->loop_length != -1) {
        return wrapper->track_metadata->intro_length
                + wrapper->track_metadata->loop_length * 2;
    } else {
        return 0;
    }
}

}
