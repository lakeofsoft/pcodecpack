
{$I una_def.inc }

{-- --

    some utility

    by Lake

-- --}

unit
    una_utils;

interface

uses
    una_types;

// --  --
function mscanp(buf: pointer; value: pointer; count: int): pointer; overload;
function mscanp(buf: pointer; value: pointer; lastValidPtr: pointer): pointer; overload;
// --  --
function ptr_inc(ptr: pointer; delta: uint): pointer;
function ptr_dec(ptr: pointer; delta: uint): pointer;
//
function max(a, b: int): int;       overload;
function max(a, b: uint): uint;     overload;
{$IFDEF CPU64 }
{$ELSE }
function max(a, b: int64): int64;   overload;
function max(a, b: uint64): uint64; overload;
{$ENDIF CPU64 }
function min(a, b: int): int;       overload;
function min(a, b: uint): uint;     overload; inline;
{$IFDEF CPU64 }
{$ELSE }
function min(a, b: int64): int64;   overload;
function min(a, b: uint64): uint64; overload;
{$ENDIF CPU64 }

// --  --
type
    // --  --
{$IFDEF NO_CLOSURES }
    proc_yield  = function (timeout: uint = 100): bool;
    proc_code   = procedure(y: proc_yield);
{$ELSE }
    proc_yield  = reference to function (timeout: uint = 100): bool;
    proc_code   = reference to procedure(y: proc_yield);
{$ENDIF NO_CLOSURES }

    // --  --
    P_unaFork = ^T_unaForkRec;
    T_unaForkRec = record
    private
        f_handle    : handle;
        f_code      : proc_code;
        f_evStart   : handle;
        f_evYield   : handle;
        f_copy      : P_unaFork;

        procedure release(timeout: uint);
    public
        procedure fork(const code: proc_code);
        procedure poke(timeout: uint = INFINITE);
        function wait(timeout: uint = INFINITE): bool;
        procedure drop(sleep: uint = 0; timeout: uint = INFINITE);
        procedure abandon();

        property h: handle read f_handle;
    end;

    {
        int <-> string
    }
    T_unaIntStr = record
    private
        procedure default(v: uint = 0);
        function getAsString(pad: int): string;
        procedure assign(const v: T_unaIntStr);
    public
        value: uint;
        base: uint;
        split: uint;
        splitChar: char;
        padChar: char;

        class operator Implicit(a: int): T_unaIntStr;
        class operator Implicit(a: uint): T_unaIntStr;
        class operator Implicit(a: pointer): T_unaIntStr;
        class operator Implicit(const a: T_unaIntStr): string;
        class operator Implicit(const a: string): T_unaIntStr;
        class operator Implicit(const a: T_unaIntStr): uint;
{$IFDEF FPC }
        class operator Implicit(const a: T_unaIntStr): byte;
        class operator Implicit(const a: T_unaIntStr): int64;
{$ENDIF FPC }
        class operator Add(const a, b: T_unaIntStr): T_unaIntStr;
        class operator Add(const a: string; const b: T_unaIntStr): string;
        class operator Multiply(const a, b: T_unaIntStr): T_unaIntStr;
        class operator Subtract(const a, b: T_unaIntStr): T_unaIntStr;
        class operator Equal(const a, b: T_unaIntStr): boolean;
        class operator NotEqual(const a, b: T_unaIntStr): boolean;

        class function init(const v: T_unaIntStr; abase: int = 10; asplit: uint = 0; asplitChar: char = ' '; apadChar: char = '0'): T_unaIntStr; static;

        property s[pad: int]: string read getAsString; default;
    end;
    i2s = T_unaIntStr;

// --  --
function fork(const code: proc_code; abandoned: bool = true): T_unaForkRec; overload;
function fork(const code: proc_code; queue: T_unaForkRec; abandoned: bool = true): T_unaForkRec; overload;

procedure catchup_abandoned();


implementation


uses
    una_OS;

// --  --
function mscanp(buf: pointer; value: pointer; count: int): pointer;
var
    a: ^pointer absolute buf;
begin
    result := nil;
    //
    while (count > 0) do
    begin
        if (a^ = value) then exit(a);
        //
        inc(a);
        dec(count);
    end;
end;

// --  --
function mscanp(buf: pointer; value: pointer; lastValidPtr: pointer): pointer;
var
    F: UIntPtr absolute buf;
    L: UIntPtr absolute lastValidPtr;
begin
    if (F <= L) then
        result := mscanp( buf, value, 1 + (L - F) div (sizeof(pointer)) )
    else
        result := nil;
end;

// --  --
function ptr_inc(ptr: pointer; delta: uint): pointer;
begin
    Exit( pointer(UIntPtr(ptr) + delta) );
end;

// --  --
function ptr_dec(ptr: pointer; delta: uint): pointer;
begin
    Exit( pointer(UIntPtr(ptr) - delta) );
end;

// --  --
function max(a, b: int): int; inline;
begin
    if (a > b) then Exit( a ) else Exit( b );
end;
// --  --
function max(a, b: uint): uint; inline;
begin
    if (a > b) then Exit( a ) else Exit( b );
end;
{$IFDEF CPU64 }
{$ELSE }
// --  --
function max(a, b: int64): int64; inline;
begin
    if (a > b) then Exit( a ) else Exit( b );
end;
// --  --
function max(a, b: uint64): uint64; inline;
begin
    if (a > b) then Exit( a ) else Exit( b );
end;
{$ENDIF CPU64 }
// --  --
function min(a, b: int): int; inline;
begin
    if (a < b) then Exit( a ) else Exit( b );
end;
// --  --
function min(a, b: uint): uint; inline;
begin
    if (a < b) then Exit( a ) else Exit( b );
end;
{$IFDEF CPU64 }
{$ELSE }
// --  --
function min(a, b: int64): int64; inline;
begin
    if (a < b) then Exit( a ) else Exit( b );
end;
// --  --
function min(a, b: uint64): uint64; inline;
begin
    if (a < b) then Exit( a ) else Exit( b );
end;
{$ENDIF CPU64 }


{$IFDEF NO_CLOSURES }
function y(): bool;
begin
    Exit( true );
end;

{$ENDIF NO_CLOSURES }

// --  --
function thread_code(param: pointer): uint;
var
    fork : P_unaFork absolute param;
begin
    // flag we have started
    os.ev_flag(fork.f_evStart);

    // run code
    fork.f_code(
{$IFDEF NO_CLOSURES }
        @y
{$ELSE }
        function (timeout: uint): bool
        begin
            result := os.ev_wait(fork.f_evYield, timeout);
        end
{$ENDIF NO_CLOSURES }
    );

    // flag we are done
    os.ev_flag(fork.f_evYield);

    result := 0;
end;


var
    g_abandonedRef      : int32;
    g_abandoned_thread  : T_unaForkRec;
    g_abandoned_list    : array[0..1023] of T_unaForkRec;  // ~40 KB
    g_abandoned_listCnt : int32 = 0;
    g_abandoned_clean   : bool;

procedure catchup_abandoned();
begin
    g_abandoned_thread.drop(100);
    g_abandoned_listCnt := 0;
end;


{ T_unaFork }


procedure abanboned_monitor(y: proc_yield);
var
    lastCheckIndex: int;
begin
    lastCheckIndex := 0;
    g_abandoned_clean := (lastCheckIndex = g_abandoned_listCnt);

    while (not g_abandoned_clean or not y()) do
    begin
        if (lastCheckIndex < g_abandoned_listCnt) then
        begin
            g_abandoned_clean := false;
            inc(lastCheckIndex);
            g_abandoned_list[lastCheckIndex mod high(g_abandoned_list)].drop();
        end
        else
            g_abandoned_clean := true;
    end;
end;

// --  --
procedure T_unaForkRec.abandon();
var
    r, i: int32;
begin
    if (g_abandoned_thread.h = 0) then
    begin
        r := os.locked_inc(g_abandonedRef);
        try
            case (r) of

                1: begin
                    g_abandoned_thread := una_utils.fork(
                    {$IFDEF NO_CLOSURES }
                        @abanboned_monitor,
                    {$ELSE }
                        procedure (y: proc_yield)
                        begin
                             abanboned_monitor(y);
                        end,
                    {$ENDIF NO_CLOSURES }
                        false   // do not add g_abandoned_thread to abandoned list
                    );

                    os.wakeup();
                end;

                else
                    while (g_abandoned_thread.h = 0) do os.sleep(100); // wait till someone else creates the global thread

            end;
        finally
            os.locked_dec(g_abandonedRef);
        end;
    end;

    i := os.locked_inc(g_abandoned_listCnt) mod high(g_abandoned_list);
    g_abandoned_list[i] := self;
end;

// --  --
procedure T_unaForkRec.drop(sleep: uint; timeout: uint);
begin
    if (h = 0) then exit;

    if (sleep <> 0) then
        os.ev_wait(f_evYield, sleep);

    wait(timeout);

    dispose(f_copy);
    f_copy := nil;

    release(1); // no reason to wait any longer
end;

// --  --
procedure T_unaForkRec.fork(const code: proc_code);
begin
    f_code    := code;
    f_evStart := os.ev_new();
    f_evYield := os.ev_new();

    new(f_copy);
    f_copy.f_code    := code;
    f_copy.f_evStart := f_evStart;
    f_copy.f_evYield := f_evYield;

    f_handle := os.thread_new(thread_code, f_copy);
end;

// --  --
procedure T_unaForkRec.poke(timeout: uint);
begin
    os.ev_wait(f_evStart, timeout);
end;

// --  --
procedure T_unaForkRec.release(timeout: uint);
begin
    os.ev_wait(f_evStart);
    os.ev_wait(f_evYield);

    os.thread_release(f_handle, timeout);
    os.ev_release(f_evStart);
    os.ev_release(f_evYield);

    f_code := nil;
end;

// --  --
function T_unaForkRec.wait(timeout: uint): bool;
begin
    os.ev_flag(f_evYield);
    poke(timeout);

    result := os.thread_wait(h, timeout);
end;

// --  --
function fork(const code: proc_code; abandoned: bool): T_unaForkRec; overload;
begin
    result.fork(code);
    if (abandoned) then
        result.abandon();
end;

// --  --
function fork(const code: proc_code; queue: T_unaForkRec; abandoned: bool): T_unaForkRec; overload;
begin
    queue.drop();

    exit(fork(code, abandoned));
end;


{ T_unaIntStr }

// --  --
class operator T_unaIntStr.Add(const a, b: T_unaIntStr): T_unaIntStr;
begin
    result.assign(a);
    inc(result.value, b.value);
end;

// --  --
class operator T_unaIntStr.Multiply(const a, b: T_unaIntStr): T_unaIntStr;
begin
    result.assign(a);
    result.value := result.value * b.value;
end;

// --  --
class operator T_unaIntStr.Equal(const a, b: T_unaIntStr): boolean;
begin
    result := (a.value = b.value);
end;

// --  --
class operator T_unaIntStr.NotEqual(const a, b: T_unaIntStr): boolean;
begin
    result := (a.value <> b.value);
end;

// --  --
function T_unaIntStr.getAsString(pad: int): string;
var
    i, l, d: tindex;
begin
    result := self;
    l := length(result);
    if (pad > l) then
    begin
        d := pad - l;
        setLength(result, pad);
        for i := l downto 1 do
            result[i + d] := result[i];

        for i := 1 to d do
            result[i] := padChar;
    end;
end;

// --  --
class operator T_unaIntStr.Subtract(const a, b: T_unaIntStr): T_unaIntStr;
begin
    result.assign(a);
    dec(result.value, b.value);
end;

// --  --
class operator T_unaIntStr.Implicit(a: int): T_unaIntStr;
begin
    result.default(uint(a));
end;

// --  --
class operator T_unaIntStr.Implicit(a: uint): T_unaIntStr;
begin
    result.default(a);
end;

// --  --
class operator T_unaIntStr.Implicit(a: pointer): T_unaIntStr;
begin
    result.default(uintptr(a));
end;

// --  --
class operator T_unaIntStr.Implicit(const a: T_unaIntStr): uint;
begin
    result := a.value;
end;

{$IFDEF FPC }

// --  --
class operator T_unaIntStr.Implicit(const a: T_unaIntStr): byte;
begin
    result := byte(a.value);
end;

// --  --
class operator T_unaIntStr.Implicit(const a: T_unaIntStr): int64;
begin
    result := int64(a.value);
end;

{$ENDIF FPC }

// --  --
class function T_unaIntStr.init(const v: T_unaIntStr; abase: int; asplit: uint; asplitChar, apadChar: char): T_unaIntStr;
begin
    result.value := v.value;
    result.base := abase;
    result.split := asplit;
    result.splitChar := asplitChar;
    result.padChar := apadChar;
end;

// --  --
class operator T_unaIntStr.Add(const a: string; const b: T_unaIntStr): string;
begin
    result := a + string(b);
end;

procedure T_unaIntStr.assign(const v: T_unaIntStr);
begin
    value := v.value;
    base := v.base;
    split := v.split;
    splitChar := v.splitChar;
end;

// --  --
procedure T_unaIntStr.default(v: uint);
begin
    value := v;
    base := 10;
    split := 0;
    splitChar := ' ';
end;

const
    c_base_str = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz[]<>&$#';
var
    g_thousandSeparator: char = '`';

// --  --
class operator T_unaIntStr.Implicit(const a: T_unaIntStr): string;
var
  i: int;
  v: uint64;
  c: char;
begin
    if (0 = a.value) then result := '0'
                     else result := '';

    if ((1 < a.base) and (uint(length(c_base_str)) > a.base)) then
    begin
        v := a.value;

        while (0 <> v) do
        begin
            result := c_base_str[v mod a.base + 1] + result;
            v := v div a.base;
        end;
    end;

    if (a.split > 0) then
    begin
        if (' ' = a.splitchar) then c := g_thousandSeparator
                               else c := a.splitChar;

        i := length(result) - int(a.split) + 1;
        while (i > 1) do
        begin
            insert(c, result, i);
            dec(i, a.split);
        end;
    end;
end;

// --  --
function str2intInt64(value: pChar; maxLen: int; defValue: int64; base: uint; ignoreTrails: bool): int64;

    function charInAZ19(c: char): bool;
    begin
        result :=
            ((c >= '1') and (c <= '9')) or
            ((c >= 'A') and (c <= 'Z')) or
            ((c >= 'a') and (c <= 'z'));
    end;

var
    negative: bool;
    ok: bool;
    b: byte;
    ofs: uint64;
    c: char;
    v: uint64;
begin
    if ((nil <> value) and (#0 <> value) and (0 < maxLen) and (1 < base) and (36 >= base)) then
    else
        exit(defValue);

    // trim leading spaces
    while ((0 < maxLen) and (' ' = value^)) do
    begin
        inc(value);
        dec(maxLen);
    end;

    // trim trailing spaces
    while ((0 < maxLen) and (' ' = value[maxLen - 1])) do
        dec(maxLen);

    if ( ((16 = base) or (10 = base)) and
        (
            ('$' = value^) or
            ('h' = value[maxLen - 1]) or
            ('H' = value[maxLen - 1]) or
            ( ('0' = value^) and (('x' = value[1]) or ('X' = value[1])) )
        )
       ) then
    begin
        base := 16;

        case (value^) of

            '$': begin
                inc(value);
                dec(maxLen);
            end;

            '0': begin
                inc(value, 2);
                dec(maxLen, 2);
            end;

            else
                dec(maxLen);	// ignore trailing 'H'

        end; // case
    end;

    // get sign
    ok := true;
    negative := false;
    while ((16 >= base) and (0 < maxLen) and not charInAZ19(value^)) do
    begin
        case (value^) of

            '-': negative := true;
            '+': negative := false;
            '0': ;	// skip leading zeroes

            else
            begin
                ok := false;	// have found some invalid character
                break;
            end;

        end;    // case

        inc(value);
        dec(maxLen);
    end;

    if (ok) then
    else
        exit(defValue);

    v := 0;
    ofs := 1;
    b := 0;
    while (0 < maxLen) do
    begin
        c := value[maxLen - 1];
        case (c) of

            '0'..'9': b := ord(c) - ord('0');
            'A'..'Z': b := ord(c) - ord('A') + 10;
            'a'..'z': b := ord(c) - ord('a') + 10;
            else
                ok := false;

        end;	// case

        if (b >= base) then
            ok := false;

        if (ok or ignoreTrails) then
        begin
            if (ok) then
            begin
                v := v + ofs * b;
                ofs := ofs * base;
            end
            else begin
                ofs := 1;
                v := 0;
                ok := true;	// try from next char
            end;

            dec(maxLen);
        end
        else
            break;
    end;    // while

    if (ok) then
    begin
        if (negative) then
        begin
            v := not v;
            inc(v);
            result := int64(v);
        end
        else
            result := int64(v);
    end
    else
        result := defValue;
end;

// --  --
class operator T_unaIntStr.Implicit(const a: string): T_unaIntStr;
begin
    result.default();

    result.value := uint(str2intInt64( pchar(a), length(a), result.value, result.base, false));
end;


// --  --
procedure fillLocale();
begin
    g_thousandSeparator := os.locale_getChar(os.LOCALE_THOUSAND_SEPARATOR);
end;


initialization
    fillLocale();

finalization
    catchup_abandoned();

end.

