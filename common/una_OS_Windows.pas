
{$I una_def.inc }


unit
    una_OS_Windows;

interface

implementation

uses
{$IFDEF WINDOWS }
    Windows,
{$ELSE }
    //-- this unit will not compile for non-windows targets!
{$ENDIF WINDOWS }
    una_types,
    una_OS;

// --  --
function wait_for(obj: handle; timeout: uint): bool;
begin
    result := (WaitForSingleObject(obj, timeout) = WAIT_OBJECT_0);
end;

type
    una_OS_API_Windows = class(una_OS_API)
    private
        f_sleep_ev: handle;
    public
        function locked_inc(var v: int32): int32; override;
        function locked_dec(var v: int32): int32; override;

        procedure sleep(timeout: uint = 100); override;
        procedure wakeup(); override;
        function  tick_count(): uint; override;

        function  ev_new(manualReset: bool = true): handle; override;
        procedure ev_flag(ev: handle; doSet: bool = true); override;
        function  ev_wait(ev: handle; timeout: uint = INFINITE): bool; override;
        procedure ev_release(var ev: handle); override;

        function  thread_new(code: una_OS_API.proc_thread; param: pointer): handle; override;
        function  thread_wait(th: handle; timeout: uint = INFINITE): bool; override;
        procedure thread_abort(th: handle; exit_code: uint = Cardinal(-1)); override;
        procedure thread_release(var th: handle; timeout: uint = 30000); override;
        function  thread_currentId(): uint; override;

        function  mx_create(): handle; override;
        function  mx_enter(mx: handle; timeout: uint = INFINITE): bool; override;
        procedure mx_leave(mx: handle); override;
        procedure mx_release(var mx: handle); override;

        function  sm_create(maxCount: int = 1000; initialCount: int = 1000): handle; override;
        function  sm_enter(sm: handle; timeout: uint = INFINITE): bool; override;
        function  sm_leave(sm: handle): int; override;
        procedure sm_release(var sm: handle); override;

        function  file_open(const name: string; mode: uint = una_OS_API.FM_READ or una_OS_API.FM_SHARE_OK; createAlways: bool = false): handle; override;
        function  file_size(const name: string): int64; overload; override;
        function  file_delete(const name: string): bool; overload; override;
        function  file_size(f: handle): int64; overload; override;
        function  file_seek(f: handle; ofs: int64): bool; override;
        function  file_read(f: handle; buf: pointer; size: int): int; override;
        function  file_write(f: handle; buf: pointer; size: int): int; override;
        procedure file_release(var f: handle); override;

        function locale_getChar(flags: int): char; override;

        procedure  AfterConstruction(); override;
        destructor Destroy(); override;
    end;


// --  --
procedure una_OS_API_Windows.AfterConstruction();
begin
    f_sleep_ev := ev_new();
end;

// --  --
function una_OS_API_Windows.mx_create(): handle;
begin
    Exit( CreateMutex(nil, false, nil) );
end;

// --  --
function una_OS_API_Windows.mx_enter(mx: handle; timeout: uint): bool;
begin
    Exit( wait_for(mx, timeout) );
end;

// --  --
procedure una_OS_API_Windows.mx_leave(mx: handle);
begin
    ReleaseMutex(mx);
end;

// --  --
procedure una_OS_API_Windows.mx_release(var mx: handle);
begin
    CloseHandle(mx);

    inherited;
end;

// --  --
destructor una_OS_API_Windows.Destroy();
begin
	wakeup();
    ev_release(f_sleep_ev);
    f_sleep_ev := 0;
end;

// --  --
function una_OS_API_Windows.locale_getChar(flags: int): char;
var
    buf: array[0..1] of char;
begin
    case (flags) of

        LOCALE_THOUSAND_SEPARATOR: flags := LOCALE_STHOUSAND;

        else
            Exit(' ');
    end;

    if (GetLocaleInfo(GetThreadLocale(), flags, @buf, 2) > 0) then
        Exit( buf[0] )
    else
        Exit( ' ' );
end;

// --  --
function una_OS_API_Windows.locked_inc(var v: int32): int32;
begin
    Exit( InterlockedIncrement(v) );
end;

// --  --
function una_OS_API_Windows.locked_dec(var v: int32): int32;
begin
    Exit( InterlockedDecrement(v) );
end;

// --  --
procedure una_OS_API_Windows.sleep(timeout: uint);
begin
    if (ev_wait(f_sleep_ev, 0)) then
        ev_flag(f_sleep_ev, false);

    ev_wait(f_sleep_ev, timeout);
end;

// --  --
function una_OS_API_Windows.sm_create(maxCount, initialCount: int): handle;
begin
    Exit( CreateSemaphore(nil, initialCount, maxCount, nil) );
end;

// --  --
function una_OS_API_Windows.sm_enter(sm: handle; timeout: uint): bool;
begin
    Exit( wait_for(sm, timeout) );
end;

// --  --
function una_OS_API_Windows.sm_leave(sm: handle): int;
var
    L: ULONG;
begin
    L := ULONG(-1);
    ReleaseSemaphore(sm, 1, @L);
    Exit( L );
end;

// --  --
procedure una_OS_API_Windows.sm_release(var sm: handle);
begin
    CloseHandle(sm);

    inherited;
end;

// --  --
procedure una_OS_API_Windows.wakeup();
begin
    ev_flag(f_sleep_ev);
end;

// --  --
function una_OS_API_Windows.ev_new(manualReset: bool): handle;
begin
    Exit( CreateEvent(nil, manualReset, false, nil) );
end;

// --  --
procedure una_OS_API_Windows.ev_flag(ev: handle; doSet: bool);
begin
    if (doSet) then SetEvent(ev)
               else ResetEvent(ev);
end;

// --  --
function una_OS_API_Windows.ev_wait(ev: handle; timeout: uint): bool;
begin
    Exit( wait_for(ev, timeout) );
end;

// --  --
function una_OS_API_Windows.file_delete(const name: string): bool;
begin
    Exit( DeleteFile( pchar(name) ) );
end;

// --  --
function una_OS_API_Windows.file_open(const name: string; mode: uint; createAlways: bool): handle;
var
    wmode,
    wshare,
    wcreate: DWORD;
begin
    wmode  := 0;
    wshare := 0;

    if (0 <> mode and FM_READ) then
    begin
        wmode  := wmode  or GENERIC_READ;
        wshare := wshare or FILE_SHARE_READ;
    end;

    if (0 <> mode and FM_WRITE) then
    begin
        wmode  := wmode  or GENERIC_WRITE;
        wshare := wshare or FILE_SHARE_WRITE;
    end;

    if (0 = mode and FM_SHARE_OK) then wshare := 0;

    if createAlways then
    begin
        wcreate := CREATE_ALWAYS;
        if (0 <= file_size(name)) then
            file_delete(name);
    end
    else
        if (0 > file_size(name)) then wcreate := CREATE_ALWAYS
                                 else wcreate := OPEN_EXISTING;

    Exit( CreateFile(pchar(name), wmode, wshare, nil, wcreate, FILE_ATTRIBUTE_NORMAL, 0) );
end;

// --  --
function una_OS_API_Windows.file_read(f: handle; buf: pointer; size: int): int;
var
    bytesRead: cardinal;
begin
    if (ReadFile(f, buf^, size, bytesRead, nil)) then Exit(bytesRead)
                                                 else Exit(-1);
end;

// --  --
procedure una_OS_API_Windows.file_release(var f: handle);
begin
    CloseHandle(f);

    inherited;
end;

const
    INVALID_SET_FILE_POINTER    = DWORD(-1);

// --  --
function una_OS_API_Windows.file_seek(f: handle; ofs: int64): bool;
var
    distanceHigh: ULONG;
begin
    distanceHigh := 0;
    Exit( INVALID_SET_FILE_POINTER <> SetFilePointer(f, ofs, @distanceHigh, FILE_BEGIN) );
end;

// --  --
function una_OS_API_Windows.file_size(const name: string): int64;
var
    f: handle;
{$IFDEF FPC }
const
     INVALID_FILE_ATTRIBUTES             = DWORD($FFFFFFFF);
{$ENDIF FPC }
begin
    if (INVALID_FILE_ATTRIBUTES <> GetFileAttributes(pchar(name))) then
    begin
        // cannot use file_open() here, it will call file_size()
        f := CreateFile(pchar(name), 0, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
        if (INVALID_HANDLE_VALUE <> f) then
        begin
            result := file_size(f);
            CloseHandle(f);
        end
        else
            Exit(-1);
    end
    else
        Exit(-1);
end;

// --  --
type
    PLARGE_INTEGER = ^int64;

function GetFileSizeEx(hFile: HANDLE; lpFileSize: PLARGE_INTEGER): Windows.BOOL; stdcall; external kernel32 name 'GetFileSizeEx';

// --  --
function una_OS_API_Windows.file_size(f: handle): int64;
begin
    if (not GetFileSizeEx(f, @result)) then
        Exit(-1);
end;

// --  --
function una_OS_API_Windows.file_write(f: handle; buf: pointer; size: int): int;
var
    bytesWritten: Cardinal;
begin
    if (WriteFile(f, buf^, size, bytesWritten, nil)) then Exit(bytesWritten)
                                                     else Exit(-1);
end;

// --  --
procedure una_OS_API_Windows.ev_release(var ev: handle);
begin
    CloseHandle(ev);

    inherited;
end;


type
    pthread_param = ^thread_param;
    thread_param = record
        r_code: una_OS_API_Windows.proc_thread;
        r_param: pointer;
    end;

// --  --
function thread_proc(params: pthread_param): DWORD; stdcall;
var
    local_params: thread_param;
begin
    local_params := params^;
    dispose(params);    // release the memory, so it will not hang around until thread returns
    Exit( local_params.r_code(local_params.r_param) );
end;

// --  --
function una_OS_API_Windows.thread_new(code: una_OS_API_Windows.proc_thread; param: pointer): handle;
var
    id: Cardinal;
    params: pthread_param;
begin
    result := 0;

    new(params);
    try
        params.r_code := code;
        params.r_param := param;
        result := CreateThread(nil, 0, @thread_proc, params, 0, id);
    finally
        if (0 = result) then
            dispose(params);
    end;
end;

// --  --
function una_OS_API_Windows.thread_wait(th: handle; timeout: uint): bool;
begin
    Exit( wait_for(th, timeout) );
end;

// --  --
function una_OS_API_Windows.tick_count(): uint;
begin
    Exit( GetTickCount() );
end;

// --  --
procedure una_OS_API_Windows.thread_abort(th: handle; exit_code: uint);
begin
    TerminateThread(th, exit_code);
end;

// --  --
function una_OS_API_Windows.thread_currentId(): uint;
begin
    Exit( GetCurrentThreadId() );
end;

// --  --
procedure una_OS_API_Windows.thread_release(var th: handle; timeout: uint);
begin
    if (not thread_wait(th, timeout)) then
        thread_abort(th);

    CloseHandle(th);

    inherited;
end;


initialization
    os := una_OS_API_Windows.Create();

finalization
    os.free();

end.

