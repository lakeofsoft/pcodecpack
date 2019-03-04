
{$I una_def.inc }

{-- --

    OS abstractions

    by Lake

-- --}

unit
    una_OS;

interface

uses
    una_types;

type
    una_OS_API = class
    protected
    type
        proc_thread = function (param: pointer): uint;
    public
        function  locked_inc(var v: int32): int32; virtual; abstract;
        function  locked_dec(var v: int32): int32; virtual; abstract;

        procedure sleep(timeout: uint = 100); overload; virtual; abstract;
        function  sleep(var totalTimeout: int; timeout: uint): bool; overload;    // returns true if totalTimeout still > 0
        procedure wakeup(); virtual; abstract;
        function  tick_count(): uint; virtual; abstract;

        function  ev_new(manualReset: bool = true): handle; virtual; abstract;
        procedure ev_flag(ev: handle; doSet: bool = true); virtual; abstract;
        function  ev_wait(ev: handle; timeout: uint = INFINITE): bool; virtual; abstract;
        procedure ev_release(var ev: handle); virtual;

        function  thread_new(code: proc_thread; param: pointer): handle; virtual; abstract;
        function  thread_wait(th: handle; timeout: uint = INFINITE): bool; virtual; abstract;
        // forcibly terminates the thread
        procedure thread_abort(th: handle; exit_code: uint = Cardinal(-1)); virtual; abstract;
        // wait up to timeout ms before killing the thread
        procedure thread_release(var th: handle; timeout: uint = 30000); virtual;
        function  thread_currentId(): uint; virtual; abstract;
        //
        function  mx_create(): handle; virtual; abstract;
        function  mx_enter(mx: handle; timeout: uint = INFINITE): bool; virtual; abstract;
        procedure mx_leave(mx: handle); virtual; abstract;
        procedure mx_release(var mx: handle); virtual;
        //
        function  sm_create(maxCount: int = 1000; initialCount: int = 1000): handle; virtual; abstract;
        function  sm_enter(sm: handle; timeout: uint = INFINITE): bool; virtual; abstract;
        function  sm_leave(sm: handle): int; virtual; abstract;
        procedure sm_release(var sm: handle); virtual;
        //
        function locale_getChar(flags: int): char; virtual; abstract;
    const
        FM_READ = 1;
        FM_WRITE = 2;
        FM_SHARE_OK = 8;
        //
        LOCALE_THOUSAND_SEPARATOR    = 1;
        //
        function  file_open(const name: string; mode: uint = FM_READ or FM_SHARE_OK; createAlways: bool = false): handle; virtual; abstract;
        function  file_size(const name: string): int64; overload; virtual; abstract;  // -1 if does not exists
        function  file_size(f: handle): int64; overload; virtual; abstract;
        function  file_delete(const name: string): bool; virtual; abstract;
        function  file_seek(f: handle; ofs: int64): bool; virtual; abstract;
        function  file_read(f: handle; buf: pointer; size: int): int; virtual; abstract;
        function  file_write(f: handle; buf: pointer; size: int): int; virtual; abstract;
        procedure file_release(var f: handle); virtual;
    end;

var
    os: una_OS_API;

implementation


{$IFDEF WINDOWS }
uses
    una_OS_Windows;
{$ENDIF WINDOWS }


{ una_OS_API }

// --  --
procedure una_OS_API.mx_release(var mx: handle);
begin
    mx := 0;
end;

// --  --
function una_OS_API.sleep(var totalTimeout: int; timeout: uint): bool;
begin
    if (totalTimeout < 0) then
    begin
        // INFINITE
        sleep(timeout);
        Exit( true );
    end;

    if (int(timeout) < totalTimeout) then
    begin
        sleep(timeout);
        dec(totalTimeout, timeout);
    end
    else
    begin
        sleep(totalTimeout);
        totalTimeout := 0;
    end;

    Exit( totalTimeout > 0 );
end;

// --  --
procedure una_OS_API.sm_release(var sm: handle);
begin
    sm := 0;
end;

// --  --
procedure una_OS_API.ev_release(var ev: handle);
begin
    ev := 0;
end;

// --  --
procedure una_OS_API.file_release(var f: handle);
begin
    f := 0;
end;

// --  --
procedure una_OS_API.thread_release(var th: handle; timeout: uint);
begin
    th := 0;
end;


end.

