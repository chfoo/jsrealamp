#include <memory.h>
#include <libopenmpt/libopenmpt.hpp>

typedef struct OpenMPTWrapperState {
    openmpt::module* module;
    const char* error;
} OpenMPTWrapper;

extern "C" {

const char* OpenMPTWrapper_is_supported(const char * extension) {
    try {
        bool result = openmpt::is_extension_supported(extension);
        return "yes";
    } catch (openmpt::exception& error) {
        return "error";
    }
    return "no";
}

OpenMPTWrapper* OpenMPTWrapper_open(uint8_t* data, long size) {
    OpenMPTWrapper* wrapper = (OpenMPTWrapper*) malloc(sizeof(OpenMPTWrapper));

    if (!wrapper) {
        return 0;
    }
    memset(wrapper, 0, sizeof(OpenMPTWrapper));

    try {
        wrapper->module = new openmpt::module(data, size);
    } catch (openmpt::exception& error) {
        wrapper->error = error.what();
    }

    return wrapper;
}

void OpenMPTWrapper_close(OpenMPTWrapper* wrapper) {
    delete wrapper->module;
    free(wrapper);
}

const char* OpenMPTWrapper_get_error(OpenMPTWrapper* wrapper) {
    return wrapper->error;
}

int OpenMPTWrapper_render(OpenMPTWrapper* wrapper, int16_t* leftBuffer, int16_t* rightBuffer, int numSamples) {
    int framesRendered = wrapper->module->read(44100, numSamples, leftBuffer, rightBuffer);
    return framesRendered;
}

const char* OpenMPTWrapper_get_track_title(OpenMPTWrapper* wrapper) {
    return wrapper->module->get_metadata("title").c_str();
}

const char* OpenMPTWrapper_get_track_author(OpenMPTWrapper* wrapper) {
    return wrapper->module->get_metadata("artist").c_str();
}

unsigned int OpenMPTWrapper_get_track_length(OpenMPTWrapper* wrapper) {
    return wrapper->module->get_duration_seconds() * 1000;
}

}
