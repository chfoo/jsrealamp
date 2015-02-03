#include <memory.h>
#include <inttypes.h>
#include <milkyplay/MilkyPlay.h>

class MemoryFile: public XMFileBase {
    uint8_t* data;
    mp_uint32 length;
    mp_uint32 position;
public:
    MemoryFile(uint8_t* data, unsigned long length);
    ~MemoryFile();
    virtual mp_sint32 read(void* ptr, mp_sint32 size, mp_sint32 count);
    virtual mp_sint32 write(const void* ptr, mp_sint32 size, mp_sint32 count);
    virtual void seek(mp_uint32 pos, SeekOffsetTypes seekOffsetType =
            SeekOffsetTypeStart);
    virtual mp_uint32 pos();
    virtual mp_uint32 size();
    virtual const SYSCHAR* getFileName();
    virtual const char* getFileNameASCII();
    virtual bool isOpen();
    virtual bool isOpenForWriting();
};

typedef struct MilkyPlayWrapperState {
    XModule* xmodule;
    MemoryFile* file;
    mp_uint32 error;
} MilkyPlayWrapper;

extern "C" {

MilkyPlayWrapper* MilkyPlayWrapper_open(uint8_t* data, unsigned long length) {
    MilkyPlayWrapper* wrapper = (MilkyPlayWrapper*) malloc(
            sizeof(MilkyPlayWrapper));

    if (!wrapper) {
        return 0;
    }
    memset(wrapper, 0, sizeof(MilkyPlayWrapper));

    wrapper->file = new MemoryFile(data, length);
    wrapper->xmodule = new XModule();
    wrapper->error = wrapper->xmodule->loadModule(*wrapper->file);

    return wrapper;
}

void MilkyPlayWrapper_close(MilkyPlayWrapper* wrapper) {
    delete wrapper->file;
    delete wrapper->xmodule;
    free(wrapper);
}

mp_uint32 MilkyPlayWrapper_get_error(MilkyPlayWrapper* wrapper) {
    return wrapper->error;
}

}

MemoryFile::MemoryFile(uint8_t* data, unsigned long length) :
        position(0), length(length) {
    this->data = (uint8_t*) malloc(length);
    memcpy(this->data, data, length);
}

MemoryFile::~MemoryFile() {
    free(data);
}

mp_sint32 MemoryFile::read(void* ptr, mp_sint32 size, mp_sint32 count) {
    mp_sint32 bytes_read = size * count;
    printf("%p %p %p %d\n", ptr, data, data + position, bytes_read);
    memcpy(ptr, data + position, bytes_read);
    position += bytes_read;
    return bytes_read;
}

mp_sint32 MemoryFile::write(const void* ptr, mp_sint32 size, mp_sint32 count) {
    throw "Read only.";
}

void MemoryFile::seek(mp_uint32 pos, SeekOffsetTypes seekOffsetType) {
    switch (seekOffsetType) {
    case SeekOffsetTypeStart:
        position = pos;
        break;
    case SeekOffsetTypeCurrent:
        position += pos;
        break;
    case SeekOffsetTypeEnd:
        position = length + pos;
        break;
    default:
        throw "Unknown seek type.";
    }
}

mp_uint32 MemoryFile::pos() {
    return position;
}

mp_uint32 MemoryFile::size() {
    return length;
}

const SYSCHAR* MemoryFile::getFileName() {
    return "DUMMY";
}

const char* MemoryFile::getFileNameASCII() {
    return "DUMMY";
}

bool MemoryFile::isOpen() {
    return data != 0;
}

bool MemoryFile::isOpenForWriting() {
    return false;
}
