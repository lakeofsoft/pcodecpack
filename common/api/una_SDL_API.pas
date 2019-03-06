
{$I una_def.inc }

unit
    una_SDL_API;

interface

uses
    una_types;


(*
  Simple DirectMedia Layer
  Copyright (C) 1997-2019 Sam Lantinga <slouken@libsdl.org>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*)

(**
 *  \file SDL_audio.h
 *
 *  Access to the raw audio mixing buffer for the SDL library.
 *)


//#include "SDL_stdinc.h"
//#include "SDL_error.h"
//#include "SDL_endian.h"
//#include "SDL_mutex.h"
//#include "SDL_thread.h"
//#include "SDL_rwops.h"

(**
 *  \file SDL_rwops.h
 *
 *  This file provides a general interface for SDL to read and write
 *  data streams.  It can easily be extended to files, memory, etc.
 *)

//#ifndef SDL_rwops_h_
//#define SDL_rwops_h_

//#include "SDL_stdinc.h"
//#include "SDL_error.h"

//#include "begin_code.h"
//* Set up for C function definitions, even when using C++ */
//#ifdef __cplusplus
//extern "C" {
//#endif

const
//* RWops Types */
SDL_RWOPS_UNKNOWN   = 0;  //**< Unknown stream type */
SDL_RWOPS_WINFILE   = 1;  //**< Win32 file */
SDL_RWOPS_STDFILE   = 2;  //**< Stdio file */
SDL_RWOPS_JNIFILE   = 3;  //**< Android asset */
SDL_RWOPS_MEMORY    = 4;  //**< Memory stream */
SDL_RWOPS_MEMORY_RO = 5;  //**< Read-Only memory stream */

type
    Sint64 = int64;
    SDL_bool = LongBool;
    pSDL_RWops = ^SDL_RWops;
    size_t = IntPtr;
    int = LongInt;

fnsize  = function (context: pSDL_RWops): Sint64; cdecl;
fnseek  = function (context: pSDL_RWops; offset: Sint64; whence: int): Sint64; cdecl;
fnread  = function (context: pSDL_RWops; ptr: pointer; size: size_t; maxnum: size_t): size_t; cdecl;
fnwrite = function (context: pSDL_RWops; ptr: pointer; size: size_t; num: size_t): size_t; cdecl;
fnclose = function (context: pSDL_RWops): int; cdecl;

    twindowsio = packed record
        flag: SDL_bool;
        h: pointer;
        //struct

        data: pointer;
        size: size_t;
        left: size_t;
        // buffer;
    end;


(**
 * This is the read/write operation structure -- very basic.
 *)
    SDL_RWops = packed record
    (**
     *  Return the size of the file in this rwops, or -1 if unknown
     *)
    size: fnsize;

    (**
     *  Seek to \c offset relative to \c whence, one of stdio's whence values:
     *  RW_SEEK_SET, RW_SEEK_CUR, RW_SEEK_END
     *
     *  \return the final offset in the data stream, or -1 on error.
     *)
    seek: fnseek;

    (**
     *  Read up to \c maxnum objects each of size \c size from the data
     *  stream to the area pointed at by \c ptr.
     *
     *  \return the number of objects read, or 0 at error or end of file.
     *)
    read: fnread;

    (**
     *  Write exactly \c num objects each of size \c size from the area
     *  pointed at by \c ptr to data stream.
     *
     *  \return the number of objects written, or 0 at error or end of file.
     *)
    write: fnwrite;

    (**
     *  Close and free an allocated SDL_RWops structure.
     *
     *  \return 0 if successful or -1 on write error when flushing data.
     *)
    close: fnclose;

    case _type: Uint32 of

    //union
    (*
#if defined(__ANDROID__)
        struct
        {
            void *fileNameRef;
            void *inputStreamRef;
            void *readableByteChannelRef;
            void *readMethod;
            void *assetFileDescriptorRef;
            long position;
            long size;
            long offset;
            int fd;
        } androidio;
    *)
//#elif defined(__WIN32__)
        0: (windowsio: twindowsio);
//#endif

//#ifdef HAVE_STDIO_H
        1: (
            autoclose: SDL_bool;
            fp: pointer;
        );
//#endif
        2:
        (
            base: pbyte;
            here: pbyte;
            stop: pbyte;
        );

        3:
        (
            data1: pointer;
            data2: pointer;
        );
    end;


(**
 *  \name RWFrom functions
 *
 *  Functions to create SDL_RWops structures from various data streams.
 */
/* @{ *)

//extern DECLSPEC SDL_RWops *SDLCALL SDL_RWFromFile(const char *file,
//                                                  const char *mode);
SDL_RWFromFile = function(_file: pchar; mode: pchar): pSDL_RWops; cdecl;

//#ifdef HAVE_STDIO_H
//extern DECLSPEC SDL_RWops *SDLCALL SDL_RWFromFP(FILE * fp,
//                                                SDL_bool autoclose);
//#else
//extern DECLSPEC SDL_RWops *SDLCALL SDL_RWFromFP(void * fp,
//                                                SDL_bool autoclose);
//#endif
SDL_RWFromFP = function(fp: pointer; autoclose: SDL_bool): pSDL_RWops; cdecl;

//extern DECLSPEC SDL_RWops *SDLCALL SDL_RWFromMem(void *mem, int size);
//extern DECLSPEC SDL_RWops *SDLCALL SDL_RWFromConstMem(const void *mem,
//                                                      int size);
SDL_RWFromMem = function(mem: pointer; size: int): pSDL_RWops; cdecl;

//* @} *//* RWFrom functions */


//extern DECLSPEC SDL_RWops *SDLCALL SDL_AllocRW(void);
//extern DECLSPEC void SDLCALL SDL_FreeRW(SDL_RWops * area);
SDL_AllocRW = function(): pSDL_RWops; cdecl;
SDL_FreeRW = procedure(area: pSDL_RWops); cdecl;

const
    RW_SEEK_SET = 0;       //**< Seek from the beginning of data */
    RW_SEEK_CUR = 1;       //**< Seek relative to current read point */
    RW_SEEK_END = 2;       //**< Seek relative to the end of data */

(**
 *  \name Read/write macros
 *
 *  Macros to easily read and write from an SDL_RWops structure.
 */
/* @{ *)
// #define SDL_RWsize(ctx)         (ctx)->size(ctx)
// #define SDL_RWseek(ctx, offset, whence) (ctx)->seek(ctx, offset, whence)
// #define SDL_RWtell(ctx)         (ctx)->seek(ctx, 0, RW_SEEK_CUR)
// #define SDL_RWread(ctx, ptr, size, n)   (ctx)->read(ctx, ptr, size, n)
// #define SDL_RWwrite(ctx, ptr, size, n)  (ctx)->write(ctx, ptr, size, n)
// #define SDL_RWclose(ctx)        (ctx)->close(ctx)
//* @} *//* Read/write macros */

type
(**
 *  Load all the data from an SDL data stream.
 *
 *  The data is allocated with a zero byte at the end (null terminated)
 *
 *  If \c datasize is not NULL, it is filled with the size of the data read.
 *
 *  If \c freesrc is non-zero, the stream will be closed after being read.
 *
 *  The data should be freed with SDL_free().
 *
 *  \return the data, or NULL if there was an error.
 *)
//extern DECLSPEC void *SDLCALL SDL_LoadFile_RW(SDL_RWops * src, size_t *datasize,
//                                                    int freesrc);
SDL_LoadFile_RW = function(src: pSDL_RWops; var datasize: size_t; freesrc: int): pointer; cdecl;


(**
 *  Load an entire file.
 *
 *  Convenience macro.
 *)
//#define SDL_LoadFile(file, datasize)   SDL_LoadFile_RW(SDL_RWFromFile(file, "rb"), datasize, 1)

(**
 *  \name Read endian functions
 *
 *  Read an item of the specified endianness and return in native format.
 */
/* @{ *)
// extern DECLSPEC Uint8 SDLCALL SDL_ReadU8(SDL_RWops * src);
// extern DECLSPEC Uint16 SDLCALL SDL_ReadLE16(SDL_RWops * src);
// extern DECLSPEC Uint16 SDLCALL SDL_ReadBE16(SDL_RWops * src);
// extern DECLSPEC Uint32 SDLCALL SDL_ReadLE32(SDL_RWops * src);
// extern DECLSPEC Uint32 SDLCALL SDL_ReadBE32(SDL_RWops * src);
// extern DECLSPEC Uint64 SDLCALL SDL_ReadLE64(SDL_RWops * src);
// extern DECLSPEC Uint64 SDLCALL SDL_ReadBE64(SDL_RWops * src);
//* @} *//* Read endian functions */
SDL_ReadU8   = function(src: pSDL_RWops): Uint8;  cdecl;
SDL_ReadLE16 = function(src: pSDL_RWops): Uint16; cdecl;
SDL_ReadBE16 = function(src: pSDL_RWops): Uint16; cdecl;
SDL_ReadLE32 = function(src: pSDL_RWops): Uint32; cdecl;
SDL_ReadBE32 = function(src: pSDL_RWops): Uint32; cdecl;
SDL_ReadLE64 = function(src: pSDL_RWops): Uint64; cdecl;
SDL_ReadBE64 = function(src: pSDL_RWops): Uint64; cdecl;

(**
 *  \name Write endian functions
 *
 *  Write an item of native format to the specified endianness.
 */
/* @{ *)
// extern DECLSPEC size_t SDLCALL SDL_WriteU8(SDL_RWops * dst, Uint8 value);
// extern DECLSPEC size_t SDLCALL SDL_WriteLE16(SDL_RWops * dst, Uint16 value);
// extern DECLSPEC size_t SDLCALL SDL_WriteBE16(SDL_RWops * dst, Uint16 value);
// extern DECLSPEC size_t SDLCALL SDL_WriteLE32(SDL_RWops * dst, Uint32 value);
// extern DECLSPEC size_t SDLCALL SDL_WriteBE32(SDL_RWops * dst, Uint32 value);
// extern DECLSPEC size_t SDLCALL SDL_WriteLE64(SDL_RWops * dst, Uint64 value);
// extern DECLSPEC size_t SDLCALL SDL_WriteBE64(SDL_RWops * dst, Uint64 value);
//* @} *//* Write endian functions */
SDL_WriteU8   = function(dst: pSDL_RWops; value: Uint8 ): size_t; cdecl;
SDL_WriteLE16 = function(dst: pSDL_RWops; value: Uint16): size_t; cdecl;
SDL_WriteBE16 = function(dst: pSDL_RWops; value: Uint16): size_t; cdecl;
SDL_WriteLE32 = function(dst: pSDL_RWops; value: Uint32): size_t; cdecl;
SDL_WriteBE32 = function(dst: pSDL_RWops; value: Uint32): size_t; cdecl;
SDL_WriteLE64 = function(dst: pSDL_RWops; value: Uint64): size_t; cdecl;
SDL_WriteBE64 = function(dst: pSDL_RWops; value: Uint64): size_t; cdecl;

///* Ends C function definitions when using C++ */
//#ifdef __cplusplus
//}
//#endif
//#include "close_code.h"

//#endif /* SDL_rwops_h_ */

//* vi: set ts=4 sw=4 expandtab: */



//#include "begin_code.h"

//* Set up for C function definitions, even when using C++ */
//#ifdef __cplusplus
//extern "C" {
//#endif

(**
 *  \brief Audio format flags.
 *
 *  These are what the 16 bits in SDL_AudioFormat currently mean...
 *  (Unspecified bits are always zero).
 *
 *  \verbatim
    ++-----------------------sample is signed if set
    ||
    ||       ++-----------sample is bigendian if set
    ||       ||
    ||       ||          ++---sample is float if set
    ||       ||          ||
    ||       ||          || +---sample bit size---+
    ||       ||          || |                     |
    15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
    \endverbatim
 *
 *  There are macros in SDL 2.0 and later to query these bits.
 *)
type SDL_AudioFormat = uint16;

(**
 *  \name Audio flags
 */
/* @{ *)

const
    SDL_AUDIO_MASK_BITSIZE  = $FF;
    SDL_AUDIO_MASK_DATATYPE = 1 shl 8;
    SDL_AUDIO_MASK_ENDIAN   = 1 shl 12;
    SDL_AUDIO_MASK_SIGNED   = 1 shl 15;

(**
 *  \name Audio format flags
 *
 *  Defaults to LSB byte order.
 */
/* @{ *)
    AUDIO_U8        = $0008;  //**< Unsigned 8-bit samples */
    AUDIO_S8        = $8008;  //**< Signed 8-bit samples */
    AUDIO_U16LSB    = $0010;  //**< Unsigned 16-bit samples */
    AUDIO_S16LSB    = $8010;  //**< Signed 16-bit samples */
    AUDIO_U16MSB    = $1010;  //**< As above, but big-endian byte order */
    AUDIO_S16MSB    = $9010;  //**< As above, but big-endian byte order */
    AUDIO_U16       = AUDIO_U16LSB;
    AUDIO_S16       = AUDIO_S16LSB;
//* @} */

(**
 *  \name int32 support
 */
/* @{ *)
    AUDIO_S32LSB    = $8020;  //**< 32-bit integer samples */
    AUDIO_S32MSB    = $9020;  //**< As above, but big-endian byte order */
    AUDIO_S32       = AUDIO_S32LSB;
//* @} */

(**
 *  \name float32 support
 */
/* @{ *)
    AUDIO_F32LSB    = $8120;  //**< 32-bit floating point samples */
    AUDIO_F32MSB    = $9120;  //**< As above, but big-endian byte order */
    AUDIO_F32       = AUDIO_F32LSB;
//* @} */

(**
 *  \name Native audio byte ordering
 */
/* @{ *)
//#if SDL_BYTEORDER == SDL_LIL_ENDIAN
    AUDIO_U16SYS    = AUDIO_U16LSB;
    AUDIO_S16SYS    = AUDIO_S16LSB;
    AUDIO_S32SYS    = AUDIO_S32LSB;
    AUDIO_F32SYS    = AUDIO_F32LSB;
//#else
//#define AUDIO_U16SYS    AUDIO_U16MSB
//#define AUDIO_S16SYS    AUDIO_S16MSB
//#define AUDIO_S32SYS    AUDIO_S32MSB
//#define AUDIO_F32SYS    AUDIO_F32MSB
//#endif
//* @} */

(**
 *  \name Allow change flags
 *
 *  Which audio format changes are allowed when opening a device.
 */
/* @{ *)
    SDL_AUDIO_ALLOW_FREQUENCY_CHANGE    = $00000001;
    SDL_AUDIO_ALLOW_FORMAT_CHANGE       = $00000002;
    SDL_AUDIO_ALLOW_CHANNELS_CHANGE     = $00000004;
    SDL_AUDIO_ALLOW_SAMPLES_CHANGE      = $00000008;
    SDL_AUDIO_ALLOW_ANY_CHANGE          = (SDL_AUDIO_ALLOW_FREQUENCY_CHANGE or SDL_AUDIO_ALLOW_FORMAT_CHANGE or SDL_AUDIO_ALLOW_CHANNELS_CHANGE or SDL_AUDIO_ALLOW_SAMPLES_CHANGE);
//* @} */

//* @} *//* Audio flags */

const
(**
 *  \brief Upper limit of filters in SDL_AudioCVT
 *
 *  The maximum number of SDL_AudioFilter functions in SDL_AudioCVT is
 *  currently limited to 9. The SDL_AudioCVT.filters array has 10 pointers,
 *  one of which is the terminating NULL pointer.
 *)
    SDL_AUDIOCVT_MAX_FILTERS = 9;

type
(**
 *  This function is called when the audio device needs more data.
 *
 *  \param userdata An application-specific parameter saved in
 *                  the SDL_AudioSpec structure
 *  \param stream A pointer to the audio data buffer.
 *  \param len    The length of that buffer in bytes.
 *
 *  Once the callback returns, the buffer will no longer be valid.
 *  Stereo samples are stored in a LRLRLR ordering.
 *
 *  You can choose to avoid callbacks and use SDL_QueueAudio() instead, if
 *  you like. Just open your audio device with a NULL callback.
 *)
//typedef void (SDLCALL * SDL_AudioCallback) (void *userdata, Uint8 * stream, int len);
SDL_AudioCallback = procedure (userdata: pointer; stream: pointer; len: int); cdecl;


(**
 *  The calculated values in this structure are calculated by SDL_OpenAudio().
 *
 *  For multi-channel audio, the default SDL channel mapping is:
 *  2:  FL FR                       (stereo)
 *  3:  FL FR LFE                   (2.1 surround)
 *  4:  FL FR BL BR                 (quad)
 *  5:  FL FR FC BL BR              (quad + center)
 *  6:  FL FR FC LFE SL SR          (5.1 surround - last two can also be BL BR)
 *  7:  FL FR FC LFE BC SL SR       (6.1 surround)
 *  8:  FL FR FC LFE BL BR SL SR    (7.1 surround)
 *)
    pSDL_AudioSpec = ^SDL_AudioSpec;
    SDL_AudioSpec = packed record
        freq: int;                   //**< DSP frequency -- samples per second */
        format: SDL_AudioFormat;     //**< Audio data format */
        channels: Uint8;             //**< Number of channels: 1 mono, 2 stereo */
        silence: Uint8;              //**< Audio buffer silence value (calculated) */
        samples: Uint16;             //**< Audio buffer size in sample FRAMES (total samples divided by channel count) */
        padding: Uint16;             //**< Necessary for some compile environments */
        size: Uint32;                //**< Audio buffer size in bytes (calculated) */
        callback: SDL_AudioCallback; //**< Callback that feeds the audio device (NULL to use SDL_QueueAudio()). */
        userdata: pointer;             //**< Userdata passed to callback (ignored for NULL callbacks). */
    end; // SDL_AudioSpec;


    pSDL_AudioCVT = ^SDL_AudioCVT;
//typedef void (SDLCALL * SDL_AudioFilter) (struct SDL_AudioCVT * cvt, SDL_AudioFormat format);
SDL_AudioFilter = procedure (cvt: pSDL_AudioCVT; format: SDL_AudioFormat); cdecl;


(**
 *  \struct SDL_AudioCVT
 *  \brief A structure to hold a set of audio conversion filters and buffers.
 *
 *  Note that various parts of the conversion pipeline can take advantage
 *  of SIMD operations (like SSE2, for example). SDL_AudioCVT doesn't require
 *  you to pass it aligned data, but can possibly run much faster if you
 *  set both its (buf) field to a pointer that is aligned to 16 bytes, and its
 *  (len) field to something that's a multiple of 16, if possible.
 *)
//#ifdef __GNUC__
(* This structure is 84 bytes on 32-bit architectures, make sure GCC doesn't
   pad it out to 88 bytes to guarantee ABI compatibility between compilers.
   vvv
   The next time we rev the ABI, make sure to size the ints and add padding.
*
#define SDL_AUDIOCVT_PACKED __attribute__((packed))
#else
#define SDL_AUDIOCVT_PACKED
#endif
/* *)

    SDL_AudioCVT = packed record
        needed: int;                  //**< Set to 1 if conversion possible */
        src_format: SDL_AudioFormat;    //**< Source audio format */
        dst_format: SDL_AudioFormat;    //**< Target audio format */
        rate_incr: double;              //**< Rate conversion increment */
        buf: pByte;                     //**< Buffer to hold entire audio data */
        len: int;                        //**< Length of original audio buffer */
        len_cvt: int;                    //**< Length of converted audio buffer */
        len_mult: int;                   //**< buffer must be len*len_mult big */
        len_ratio: double;               //**< Given len, final size is len*len_ratio */
        filters: array[0..SDL_AUDIOCVT_MAX_FILTERS] of SDL_AudioFilter; //**< NULL-terminated list of filter functions */
        filter_index: int;            //**< Current audio conversion function */
    end;


//* Function prototypes */

(**
 *  \name Driver discovery functions
 *
 *  These functions return the list of built in audio drivers, in the
 *  order that they are normally initialized by default.
 */
/* @{ *)
//extern DECLSPEC int SDLCALL SDL_GetNumAudioDrivers(void);
//extern DECLSPEC const char *SDLCALL SDL_GetAudioDriver(int index);
//* @} */
SDL_GetNumAudioDrivers = function(): int; cdecl;
SDL_GetAudioDriver = function(index: int): pchar; cdecl;

(**
 *  \name Initialization and cleanup
 *
 *  \internal These functions are used internally, and should not be used unless
 *            you have a specific need to specify the audio driver you want to
 *            use.  You should normally use SDL_Init() or SDL_InitSubSystem().
 */
/* @{ *)
//extern DECLSPEC int SDLCALL SDL_AudioInit(const char *driver_name);
//extern DECLSPEC void SDLCALL SDL_AudioQuit(void);
//* @} */
SDL_AudioInit = function(driver_name: pchar): int; cdecl;
SDL_AudioQuit = procedure(); cdecl;

(**
 *  This function returns the name of the current audio driver, or NULL
 *  if no driver has been initialized.
 *)
//extern DECLSPEC const char *SDLCALL SDL_GetCurrentAudioDriver(void);
SDL_GetCurrentAudioDriver = function(): pchar; cdecl;

(**
 *  This function opens the audio device with the desired parameters, and
 *  returns 0 if successful, placing the actual hardware parameters in the
 *  structure pointed to by \c obtained.  If \c obtained is NULL, the audio
 *  data passed to the callback function will be guaranteed to be in the
 *  requested format, and will be automatically converted to the hardware
 *  audio format if necessary.  This function returns -1 if it failed
 *  to open the audio device, or couldn't set up the audio thread.
 *
 *  When filling in the desired audio spec structure,
 *    - \c desired->freq should be the desired audio frequency in samples-per-
 *      second.
 *    - \c desired->format should be the desired audio format.
 *    - \c desired->samples is the desired size of the audio buffer, in
 *      samples.  This number should be a power of two, and may be adjusted by
 *      the audio driver to a value more suitable for the hardware.  Good values
 *      seem to range between 512 and 8096 inclusive, depending on the
 *      application and CPU speed.  Smaller values yield faster response time,
 *      but can lead to underflow if the application is doing heavy processing
 *      and cannot fill the audio buffer in time.  A stereo sample consists of
 *      both right and left channels in LR ordering.
 *      Note that the number of samples is directly related to time by the
 *      following formula:  \code ms = (samples*1000)/freq \endcode
 *    - \c desired->size is the size in bytes of the audio buffer, and is
 *      calculated by SDL_OpenAudio().
 *    - \c desired->silence is the value used to set the buffer to silence,
 *      and is calculated by SDL_OpenAudio().
 *    - \c desired->callback should be set to a function that will be called
 *      when the audio device is ready for more data.  It is passed a pointer
 *      to the audio buffer, and the length in bytes of the audio buffer.
 *      This function usually runs in a separate thread, and so you should
 *      protect data structures that it accesses by calling SDL_LockAudio()
 *      and SDL_UnlockAudio() in your code. Alternately, you may pass a NULL
 *      pointer here, and call SDL_QueueAudio() with some frequency, to queue
 *      more audio samples to be played (or for capture devices, call
 *      SDL_DequeueAudio() with some frequency, to obtain audio samples).
 *    - \c desired->userdata is passed as the first parameter to your callback
 *      function. If you passed a NULL callback, this value is ignored.
 *
 *  The audio device starts out playing silence when it's opened, and should
 *  be enabled for playing by calling \c SDL_PauseAudio(0) when you are ready
 *  for your audio callback function to be called.  Since the audio driver
 *  may modify the requested size of the audio buffer, you should allocate
 *  any local mixing buffers after you open the audio device.
 *)
//extern DECLSPEC int SDLCALL SDL_OpenAudio(SDL_AudioSpec * desired,
//                                          SDL_AudioSpec * obtained);
SDL_OpenAudio = function(desired: pSDL_AudioSpec; obtained: pSDL_AudioSpec): int; cdecl;

(**
 *  SDL Audio Device IDs.
 *
 *  A successful call to SDL_OpenAudio() is always device id 1, and legacy
 *  SDL audio APIs assume you want this device ID. SDL_OpenAudioDevice() calls
 *  always returns devices >= 2 on success. The legacy calls are good both
 *  for backwards compatibility and when you don't care about multiple,
 *  specific, or capture devices.
 *)
    SDL_AudioDeviceID = Uint32;

(**
 *  Get the number of available devices exposed by the current driver.
 *  Only valid after a successfully initializing the audio subsystem.
 *  Returns -1 if an explicit list of devices can't be determined; this is
 *  not an error. For example, if SDL is set up to talk to a remote audio
 *  server, it can't list every one available on the Internet, but it will
 *  still allow a specific host to be specified to SDL_OpenAudioDevice().
 *
 *  In many common cases, when this function returns a value <= 0, it can still
 *  successfully open the default device (NULL for first argument of
 *  SDL_OpenAudioDevice()).
 *)
//extern DECLSPEC int SDLCALL SDL_GetNumAudioDevices(int iscapture);
SDL_GetNumAudioDevices = function(iscapture: int): int; cdecl;

(**
 *  Get the human-readable name of a specific audio device.
 *  Must be a value between 0 and (number of audio devices-1).
 *  Only valid after a successfully initializing the audio subsystem.
 *  The values returned by this function reflect the latest call to
 *  SDL_GetNumAudioDevices(); recall that function to redetect available
 *  hardware.
 *
 *  The string returned by this function is UTF-8 encoded, read-only, and
 *  managed internally. You are not to free it. If you need to keep the
 *  string for any length of time, you should make your own copy of it, as it
 *  will be invalid next time any of several other SDL functions is called.
 *)
//extern DECLSPEC const char *SDLCALL SDL_GetAudioDeviceName(int index,
//                                                           int iscapture);
SDL_GetAudioDeviceName = function(index: int; iscapture: int): pchar; cdecl;


(**
 *  Open a specific audio device. Passing in a device name of NULL requests
 *  the most reasonable default (and is equivalent to calling SDL_OpenAudio()).
 *
 *  The device name is a UTF-8 string reported by SDL_GetAudioDeviceName(), but
 *  some drivers allow arbitrary and driver-specific strings, such as a
 *  hostname/IP address for a remote audio server, or a filename in the
 *  diskaudio driver.
 *
 *  \return 0 on error, a valid device ID that is >= 2 on success.
 *
 *  SDL_OpenAudio(), unlike this function, always acts on device ID 1.
 *)
//extern DECLSPEC SDL_AudioDeviceID SDLCALL SDL_OpenAudioDevice(const char
//                                                              *device,
//                                                              int iscapture,
//                                                              const
//                                                              SDL_AudioSpec *
//                                                              desired,
//                                                              SDL_AudioSpec *
//                                                              obtained,
//                                                              int
//                                                              allowed_changes);
SDL_OpenAudioDevice = function(device: pchar;
                        iscapture: int;
                        desired: pSDL_AudioSpec;
                        obtained: pSDL_AudioSpec;
                        allowed_changes: int): SDL_AudioDeviceID; cdecl;


(**
 *  \name Audio state
 *
 *  Get the current audio state.
 */
/* @{ *)
SDL_AudioStatus = (
    SDL_AUDIO_STOPPED = 0,
    SDL_AUDIO_PLAYING,
    SDL_AUDIO_PAUSED
);
//extern DECLSPEC SDL_AudioStatus SDLCALL SDL_GetAudioStatus(void);
SDL_GetAudioStatus = function(): SDL_AudioStatus; cdecl;

//extern DECLSPEC SDL_AudioStatus SDLCALL
//SDL_GetAudioDeviceStatus(SDL_AudioDeviceID dev);
SDL_GetAudioDeviceStatus = function(dev: SDL_AudioDeviceID): SDL_AudioStatus; cdecl;

//* @} *//* Audio State */

(**
 *  \name Pause audio functions
 *
 *  These functions pause and unpause the audio callback processing.
 *  They should be called with a parameter of 0 after opening the audio
 *  device to start playing sound.  This is so you can safely initialize
 *  data for your callback function after opening the audio device.
 *  Silence will be written to the audio device during the pause.
 */
/* @{ *)
//extern DECLSPEC void SDLCALL SDL_PauseAudio(int pause_on);
//extern DECLSPEC void SDLCALL SDL_PauseAudioDevice(SDL_AudioDeviceID dev,
//                                                  int pause_on);
//* @} *//* Pause audio functions */
SDL_PauseAudio = procedure(pause_on: int); cdecl;
SDL_PauseAudioDevice = procedure(dev: SDL_AudioDeviceID; pause_on: int); cdecl;

(**
 *  This function loads a WAVE from the data source, automatically freeing
 *  that source if \c freesrc is non-zero.  For example, to load a WAVE file,
 *  you could do:
 *  \code
 *      SDL_LoadWAV_RW(SDL_RWFromFile("sample.wav", "rb"), 1, ...);
 *  \endcode
 *
 *  If this function succeeds, it returns the given SDL_AudioSpec,
 *  filled with the audio data format of the wave data, and sets
 *  \c *audio_buf to a malloc()'d buffer containing the audio data,
 *  and sets \c *audio_len to the length of that audio buffer, in bytes.
 *  You need to free the audio buffer with SDL_FreeWAV() when you are
 *  done with it.
 *
 *  This function returns NULL and sets the SDL error message if the
 *  wave file cannot be opened, uses an unknown data format, or is
 *  corrupt.  Currently raw and MS-ADPCM WAVE files are supported.
 *)
//extern DECLSPEC SDL_AudioSpec *SDLCALL SDL_LoadWAV_RW(SDL_RWops * src,
//                                                      int freesrc,
//                                                      SDL_AudioSpec * spec,
//                                                      Uint8 ** audio_buf,
//                                                      Uint32 * audio_len);
SDL_LoadWAV_RW = function(src: pSDL_RWops;
                    freesrc: int;
                    spec: pSDL_AudioSpec;
                    audio_buf: pbyte;
                    var audio_len: uint32): pSDL_AudioSpec; cdecl;

(**
 *  Loads a WAV from a file.
 *  Compatibility convenience function.
 *)
//#define SDL_LoadWAV(file, spec, audio_buf, audio_len) \
//    SDL_LoadWAV_RW(SDL_RWFromFile(file, "rb"),1, spec,audio_buf,audio_len)


(**
 *  This function frees data previously allocated with SDL_LoadWAV_RW()
 *)
//extern DECLSPEC void SDLCALL SDL_FreeWAV(Uint8 * audio_buf);
SDL_FreeWAV = procedure(audio_buf: pbyte); cdecl;

(**
 *  This function takes a source format and rate and a destination format
 *  and rate, and initializes the \c cvt structure with information needed
 *  by SDL_ConvertAudio() to convert a buffer of audio data from one format
 *  to the other. An unsupported format causes an error and -1 will be returned.
 *
 *  \return 0 if no conversion is needed, 1 if the audio filter is set up,
 *  or -1 on error.
 *)
//extern DECLSPEC int SDLCALL SDL_BuildAudioCVT(SDL_AudioCVT * cvt,
//                                              SDL_AudioFormat src_format,
//                                              Uint8 src_channels,
//                                              int src_rate,
//                                              SDL_AudioFormat dst_format,
//                                              Uint8 dst_channels,
//                                              int dst_rate);
SDL_BuildAudioCVT = function(
                        cvt: pSDL_AudioCVT;
                        src_format: SDL_AudioFormat;
                        src_channels: Uint8;
                        src_rate: int;
                        dst_format: SDL_AudioFormat;
                        dst_channels: Uint8;
                        dst_rate: int): int; cdecl;

(**
 *  Once you have initialized the \c cvt structure using SDL_BuildAudioCVT(),
 *  created an audio buffer \c cvt->buf, and filled it with \c cvt->len bytes of
 *  audio data in the source format, this function will convert it in-place
 *  to the desired format.
 *
 *  The data conversion may expand the size of the audio data, so the buffer
 *  \c cvt->buf should be allocated after the \c cvt structure is initialized by
 *  SDL_BuildAudioCVT(), and should be \c cvt->len*cvt->len_mult bytes long.
 *
 *  \return 0 on success or -1 if \c cvt->buf is NULL.
 *)
//extern DECLSPEC int SDLCALL SDL_ConvertAudio(SDL_AudioCVT * cvt);
SDL_ConvertAudio = function(cvt: pSDL_AudioCVT): int; cdecl;


(* SDL_AudioStream is a new audio conversion interface.
   The benefits vs SDL_AudioCVT:
    - it can handle resampling data in chunks without generating
      artifacts, when it doesn't have the complete buffer available.
    - it can handle incoming data in any variable size.
    - You push data as you have it, and pull it when you need it
 *)
//* this is opaque to the outside world. */
//struct _SDL_AudioStream;
//typedef struct _SDL_AudioStream SDL_AudioStream;
    pSDL_AudioStream = ^SDL_AudioStream;
    SDL_AudioStream = packed record
    end;

(**
 *  Create a new audio stream
 *
 *  \param src_format The format of the source audio
 *  \param src_channels The number of channels of the source audio
 *  \param src_rate The sampling rate of the source audio
 *  \param dst_format The format of the desired audio output
 *  \param dst_channels The number of channels of the desired audio output
 *  \param dst_rate The sampling rate of the desired audio output
 *  \return 0 on success, or -1 on error.
 *
 *  \sa SDL_AudioStreamPut
 *  \sa SDL_AudioStreamGet
 *  \sa SDL_AudioStreamAvailable
 *  \sa SDL_AudioStreamFlush
 *  \sa SDL_AudioStreamClear
 *  \sa SDL_FreeAudioStream
 *)
//extern DECLSPEC SDL_AudioStream * SDLCALL SDL_NewAudioStream(const SDL_AudioFormat src_format,
//                                           const Uint8 src_channels,
//                                           const int src_rate,
//                                           const SDL_AudioFormat dst_format,
//                                           const Uint8 dst_channels,
//                                           const int dst_rate);
SDL_NewAudioStream = function(
                           src_format: SDL_AudioFormat;
                           src_channels: Uint8;
                           src_rate: int;
                           dst_format: SDL_AudioFormat;
                           dst_channels: Uint8;
                           dst_rate: int): pSDL_AudioStream; cdecl;

(**
 *  Add data to be converted/resampled to the stream
 *
 *  \param stream The stream the audio data is being added to
 *  \param buf A pointer to the audio data to add
 *  \param len The number of bytes to write to the stream
 *  \return 0 on success, or -1 on error.
 *
 *  \sa SDL_NewAudioStream
 *  \sa SDL_AudioStreamGet
 *  \sa SDL_AudioStreamAvailable
 *  \sa SDL_AudioStreamFlush
 *  \sa SDL_AudioStreamClear
 *  \sa SDL_FreeAudioStream
 *)
//extern DECLSPEC int SDLCALL SDL_AudioStreamPut(SDL_AudioStream *stream, const void *buf, int len);
SDL_AudioStreamPut = function(stream: pSDL_AudioStream; buf: pointer; len: int): int; cdecl;

(**
 *  Get converted/resampled data from the stream
 *
 *  \param stream The stream the audio is being requested from
 *  \param buf A buffer to fill with audio data
 *  \param len The maximum number of bytes to fill
 *  \return The number of bytes read from the stream, or -1 on error
 *
 *  \sa SDL_NewAudioStream
 *  \sa SDL_AudioStreamPut
 *  \sa SDL_AudioStreamAvailable
 *  \sa SDL_AudioStreamFlush
 *  \sa SDL_AudioStreamClear
 *  \sa SDL_FreeAudioStream
 *)
//extern DECLSPEC int SDLCALL SDL_AudioStreamGet(SDL_AudioStream *stream, void *buf, int len);
SDL_AudioStreamGet = function(stream: pSDL_AudioStream; buf: pointer; len: int): int; cdecl;

(**
 * Get the number of converted/resampled bytes available. The stream may be
 *  buffering data behind the scenes until it has enough to resample
 *  correctly, so this number might be lower than what you expect, or even
 *  be zero. Add more data or flush the stream if you need the data now.
 *
 *  \sa SDL_NewAudioStream
 *  \sa SDL_AudioStreamPut
 *  \sa SDL_AudioStreamGet
 *  \sa SDL_AudioStreamFlush
 *  \sa SDL_AudioStreamClear
 *  \sa SDL_FreeAudioStream
 *)
//extern DECLSPEC int SDLCALL SDL_AudioStreamAvailable(SDL_AudioStream *stream);
SDL_AudioStreamAvailable = function(stream: pSDL_AudioStream): int; cdecl;

(**
 * Tell the stream that you're done sending data, and anything being buffered
 *  should be converted/resampled and made available immediately.
 *
 * It is legal to add more data to a stream after flushing, but there will
 *  be audio gaps in the output. Generally this is intended to signal the
 *  end of input, so the complete output becomes available.
 *
 *  \sa SDL_NewAudioStream
 *  \sa SDL_AudioStreamPut
 *  \sa SDL_AudioStreamGet
 *  \sa SDL_AudioStreamAvailable
 *  \sa SDL_AudioStreamClear
 *  \sa SDL_FreeAudioStream
 *)
//extern DECLSPEC int SDLCALL SDL_AudioStreamFlush(SDL_AudioStream *stream);
SDL_AudioStreamFlush = function(stream: pSDL_AudioStream): int; cdecl;

(**
 *  Clear any pending data in the stream without converting it
 *
 *  \sa SDL_NewAudioStream
 *  \sa SDL_AudioStreamPut
 *  \sa SDL_AudioStreamGet
 *  \sa SDL_AudioStreamAvailable
 *  \sa SDL_AudioStreamFlush
 *  \sa SDL_FreeAudioStream
 *)
//extern DECLSPEC void SDLCALL SDL_AudioStreamClear(SDL_AudioStream *stream);
SDL_AudioStreamClear = procedure(stream: pSDL_AudioStream); cdecl;

(**
 * Free an audio stream
 *
 *  \sa SDL_NewAudioStream
 *  \sa SDL_AudioStreamPut
 *  \sa SDL_AudioStreamGet
 *  \sa SDL_AudioStreamAvailable
 *  \sa SDL_AudioStreamFlush
 *  \sa SDL_AudioStreamClear
 *)
//extern DECLSPEC void SDLCALL SDL_FreeAudioStream(SDL_AudioStream *stream);
SDL_FreeAudioStream = procedure(stream: pSDL_AudioStream); cdecl;

const
    SDL_MIX_MAXVOLUME = 128;

type
(**
 *  This takes two audio buffers of the playing audio format and mixes
 *  them, performing addition, volume adjustment, and overflow clipping.
 *  The volume ranges from 0 - 128, and should be set to ::SDL_MIX_MAXVOLUME
 *  for full audio volume.  Note this does not change hardware volume.
 *  This is provided for convenience -- you can mix your own audio data.
 *)
//extern DECLSPEC void SDLCALL SDL_MixAudio(Uint8 * dst, const Uint8 * src,
//                                          Uint32 len, int volume);
SDL_MixAudio = procedure(dst: pbyte; src: pbyte; len: Uint32; volume: int); cdecl;

(**
 *  This works like SDL_MixAudio(), but you specify the audio format instead of
 *  using the format of audio device 1. Thus it can be used when no audio
 *  device is open at all.
 *)
//extern DECLSPEC void SDLCALL SDL_MixAudioFormat(Uint8 * dst,
//                                                const Uint8 * src,
//                                                SDL_AudioFormat format,
//                                                Uint32 len, int volume);
SDL_MixAudioFormat = procedure(dst: pbyte; src: pbyte; format: SDL_AudioFormat; len: Uint32; volume: int); cdecl;

(**
 *  Queue more audio on non-callback devices.
 *
 *  (If you are looking to retrieve queued audio from a non-callback capture
 *  device, you want SDL_DequeueAudio() instead. This will return -1 to
 *  signify an error if you use it with capture devices.)
 *
 *  SDL offers two ways to feed audio to the device: you can either supply a
 *  callback that SDL triggers with some frequency to obtain more audio
 *  (pull method), or you can supply no callback, and then SDL will expect
 *  you to supply data at regular intervals (push method) with this function.
 *
 *  There are no limits on the amount of data you can queue, short of
 *  exhaustion of address space. Queued data will drain to the device as
 *  necessary without further intervention from you. If the device needs
 *  audio but there is not enough queued, it will play silence to make up
 *  the difference. This means you will have skips in your audio playback
 *  if you aren't routinely queueing sufficient data.
 *
 *  This function copies the supplied data, so you are safe to free it when
 *  the function returns. This function is thread-safe, but queueing to the
 *  same device from two threads at once does not promise which buffer will
 *  be queued first.
 *
 *  You may not queue audio on a device that is using an application-supplied
 *  callback; doing so returns an error. You have to use the audio callback
 *  or queue audio with this function, but not both.
 *
 *  You should not call SDL_LockAudio() on the device before queueing; SDL
 *  handles locking internally for this function.
 *
 *  \param dev The device ID to which we will queue audio.
 *  \param data The data to queue to the device for later playback.
 *  \param len The number of bytes (not samples!) to which (data) points.
 *  \return 0 on success, or -1 on error.
 *
 *  \sa SDL_GetQueuedAudioSize
 *  \sa SDL_ClearQueuedAudio
 *)
//extern DECLSPEC int SDLCALL SDL_QueueAudio(SDL_AudioDeviceID dev, const void *data, Uint32 len);
SDL_QueueAudio = function (dev: SDL_AudioDeviceID; data: pointer; len: Uint32): int; cdecl;

(**
 *  Dequeue more audio on non-callback devices.
 *
 *  (If you are looking to queue audio for output on a non-callback playback
 *  device, you want SDL_QueueAudio() instead. This will always return 0
 *  if you use it with playback devices.)
 *
 *  SDL offers two ways to retrieve audio from a capture device: you can
 *  either supply a callback that SDL triggers with some frequency as the
 *  device records more audio data, (push method), or you can supply no
 *  callback, and then SDL will expect you to retrieve data at regular
 *  intervals (pull method) with this function.
 *
 *  There are no limits on the amount of data you can queue, short of
 *  exhaustion of address space. Data from the device will keep queuing as
 *  necessary without further intervention from you. This means you will
 *  eventually run out of memory if you aren't routinely dequeueing data.
 *
 *  Capture devices will not queue data when paused; if you are expecting
 *  to not need captured audio for some length of time, use
 *  SDL_PauseAudioDevice() to stop the capture device from queueing more
 *  data. This can be useful during, say, level loading times. When
 *  unpaused, capture devices will start queueing data from that point,
 *  having flushed any capturable data available while paused.
 *
 *  This function is thread-safe, but dequeueing from the same device from
 *  two threads at once does not promise which thread will dequeued data
 *  first.
 *
 *  You may not dequeue audio from a device that is using an
 *  application-supplied callback; doing so returns an error. You have to use
 *  the audio callback, or dequeue audio with this function, but not both.
 *
 *  You should not call SDL_LockAudio() on the device before queueing; SDL
 *  handles locking internally for this function.
 *
 *  \param dev The device ID from which we will dequeue audio.
 *  \param data A pointer into where audio data should be copied.
 *  \param len The number of bytes (not samples!) to which (data) points.
 *  \return number of bytes dequeued, which could be less than requested.
 *
 *  \sa SDL_GetQueuedAudioSize
 *  \sa SDL_ClearQueuedAudio
 *)
//extern DECLSPEC Uint32 SDLCALL SDL_DequeueAudio(SDL_AudioDeviceID dev, void *data, Uint32 len);
SDL_DequeueAudio = function(dev: SDL_AudioDeviceID; data: pointer; len: Uint32): Uint32; cdecl;

(**
 *  Get the number of bytes of still-queued audio.
 *
 *  For playback device:
 *
 *    This is the number of bytes that have been queued for playback with
 *    SDL_QueueAudio(), but have not yet been sent to the hardware. This
 *    number may shrink at any time, so this only informs of pending data.
 *
 *    Once we've sent it to the hardware, this function can not decide the
 *    exact byte boundary of what has been played. It's possible that we just
 *    gave the hardware several kilobytes right before you called this
 *    function, but it hasn't played any of it yet, or maybe half of it, etc.
 *
 *  For capture devices:
 *
 *    This is the number of bytes that have been captured by the device and
 *    are waiting for you to dequeue. This number may grow at any time, so
 *    this only informs of the lower-bound of available data.
 *
 *  You may not queue audio on a device that is using an application-supplied
 *  callback; calling this function on such a device always returns 0.
 *  You have to queue audio with SDL_QueueAudio()/SDL_DequeueAudio(), or use
 *  the audio callback, but not both.
 *
 *  You should not call SDL_LockAudio() on the device before querying; SDL
 *  handles locking internally for this function.
 *
 *  \param dev The device ID of which we will query queued audio size.
 *  \return Number of bytes (not samples!) of queued audio.
 *
 *  \sa SDL_QueueAudio
 *  \sa SDL_ClearQueuedAudio
 *)
//extern DECLSPEC Uint32 SDLCALL SDL_GetQueuedAudioSize(SDL_AudioDeviceID dev);
SDL_GetQueuedAudioSize = function(dev: SDL_AudioDeviceID): Uint32; cdecl;

(**
 *  Drop any queued audio data. For playback devices, this is any queued data
 *  still waiting to be submitted to the hardware. For capture devices, this
 *  is any data that was queued by the device that hasn't yet been dequeued by
 *  the application.
 *
 *  Immediately after this call, SDL_GetQueuedAudioSize() will return 0. For
 *  playback devices, the hardware will start playing silence if more audio
 *  isn't queued. Unpaused capture devices will start filling the queue again
 *  as soon as they have more data available (which, depending on the state
 *  of the hardware and the thread, could be before this function call
 *  returns!).
 *
 *  This will not prevent playback of queued audio that's already been sent
 *  to the hardware, as we can not undo that, so expect there to be some
 *  fraction of a second of audio that might still be heard. This can be
 *  useful if you want to, say, drop any pending music during a level change
 *  in your game.
 *
 *  You may not queue audio on a device that is using an application-supplied
 *  callback; calling this function on such a device is always a no-op.
 *  You have to queue audio with SDL_QueueAudio()/SDL_DequeueAudio(), or use
 *  the audio callback, but not both.
 *
 *  You should not call SDL_LockAudio() on the device before clearing the
 *  queue; SDL handles locking internally for this function.
 *
 *  This function always succeeds and thus returns void.
 *
 *  \param dev The device ID of which to clear the audio queue.
 *
 *  \sa SDL_QueueAudio
 *  \sa SDL_GetQueuedAudioSize
 *)
//extern DECLSPEC void SDLCALL SDL_ClearQueuedAudio(SDL_AudioDeviceID dev);
SDL_ClearQueuedAudio = procedure(dev: SDL_AudioDeviceID); cdecl;

(**
 *  \name Audio lock functions
 *
 *  The lock manipulated by these functions protects the callback function.
 *  During a SDL_LockAudio()/SDL_UnlockAudio() pair, you can be guaranteed that
 *  the callback function is not running.  Do not call these from the callback
 *  function or you will cause deadlock.
 */
/* @{ *)
//extern DECLSPEC void SDLCALL SDL_LockAudio(void);
//extern DECLSPEC void SDLCALL SDL_LockAudioDevice(SDL_AudioDeviceID dev);
//extern DECLSPEC void SDLCALL SDL_UnlockAudio(void);
//extern DECLSPEC void SDLCALL SDL_UnlockAudioDevice(SDL_AudioDeviceID dev);
///* @} *//* Audio lock functions */
SDL_LockAudio = procedure(); cdecl;
SDL_LockAudioDevice = procedure(dev: SDL_AudioDeviceID); cdecl;
SDL_UnlockAudio = procedure(); cdecl;
SDL_UnlockAudioDevice = procedure(dev: SDL_AudioDeviceID); cdecl;

(**
 *  This function shuts down audio processing and closes the audio device.
 *)
//extern DECLSPEC void SDLCALL SDL_CloseAudio(void);
//extern DECLSPEC void SDLCALL SDL_CloseAudioDevice(SDL_AudioDeviceID dev);
SDL_CloseAudio = procedure(); cdecl;
SDL_CloseAudioDevice = procedure(dev: SDL_AudioDeviceID); cdecl;

(* Ends C function definitions when using C++ */
#ifdef __cplusplus
}
#endif
#include "close_code.h"

#endif /* SDL_audio_h_ *)

//* vi: set ts=4 sw=4 expandtab: */



implementation


function SDL_AUDIO_BITSIZE       (x: int) : int; inline; begin Exit(x and SDL_AUDIO_MASK_BITSIZE) end;
function SDL_AUDIO_ISFLOAT       (x: int) : int; inline; begin Exit(x and SDL_AUDIO_MASK_DATATYPE) end;
function SDL_AUDIO_ISBIGENDIAN   (x: int) : int; inline; begin Exit(x and SDL_AUDIO_MASK_ENDIAN) end;
function SDL_AUDIO_ISSIGNED      (x: int) : int; inline; begin Exit(x and SDL_AUDIO_MASK_SIGNED) end;
function SDL_AUDIO_ISINT         (x: int) : int; inline; begin Exit(not SDL_AUDIO_ISFLOAT(x)) end;
function SDL_AUDIO_ISLITTLEENDIAN(x: int) : int; inline; begin Exit(not SDL_AUDIO_ISBIGENDIAN(x)) end;
function SDL_AUDIO_ISUNSIGNED    (x: int) : int; inline; begin Exit(not SDL_AUDIO_ISSIGNED(x)) end;

end.

