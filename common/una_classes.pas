
{$I una_def.inc }

{-- --

    some classes

    by Lake

-- --}

unit
    una_classes;

interface

uses
    una_types,
    una_interfaces;

const
    C_DEF_LOCK_TIMEOUT  = -1;

type
    {
        instance
    }
    T_unaInstance = class(TInterfacedObject, I_unaInstance)
    private
        f_mt: bool;
        f_wlock: handle;
        f_wlockCnt: int32;
        f_rlock: handle;
        f_wLockID: uint;    // 0 = no lock
        f_rLockID: uint;    // 0 = no lock
    const
        C_MAX_RLOCK = 1000;

        procedure setMT(value: bool);
    protected
        // I_unaInstance
        function getRefCount(): int;
    public
        procedure AfterConstruction(); override;
        procedure BeforeDestruction(); override;

        function lock(onwrite: bool = false; timeout: int = C_DEF_LOCK_TIMEOUT): bool;
        procedure unlock();
        function checkLock(onwrite: bool = false): bool;

        property multiThreaded: bool read f_mt write setMT;
    end;

    {
        memory chunk
    }
    T_unaMem = class(T_unaInstance, I_unaMemory)
    private
        f_ptr : pointer;
        f_size: memoffset;
    protected
        // I_unaMemory
        procedure fill(const ofs: memoffset = 0; value: byte = 0);
        function getSize(): memoffset;
        procedure realloc(const newsize: memoffset = 0);
        function getPtrAt(const ofs: memoffset): pointer;
        function getPtr(): pointer;
        procedure assign(const value: I_unaMemory);

        property size   : memoffset read getSize write realloc;
        property ptr    : pointer read f_ptr;
        property at[const ofs: memoffset]: pointer read getPtrAt; default;
    public
        constructor Create(const size: memoffset = 0; fill: bool = false; fillValue: byte = 0);
        destructor Destroy(); override;
    end;

{$IFDEF FPC_BEFORE_2_7 }
{$ELSE }
    {
        array of T
    }
    T_unaArray<T> = class(T_unaInstance, I_unaArray<T>)
    private
        f_mem: I_unaMemory;
        f_initialCount: tindex;
    type
        T_unaArrayEnum = class(T_unaInstance, I_unaEnumerator<T>)
        private
            f_array: T_unaArray<T>;
            f_index: tindex;
        protected
            // I_unaEnumerator<T>
            function getCurrent(): T;
            function MoveNext(): bool;
        public
            constructor Create(const a: T_unaArray<T>);
            destructor Destroy(); override;
        end;
    protected
        class function compareV(const value1, value2: T): int; virtual;
        class function i2o(index: tindex): memoffset;
        function i2p(index: tindex): pointer;
        function initItem(): T; virtual;
        procedure releaseItem(index: tindex); virtual;

        // I_unaEnumerable<T>
        function GetEnumerator(): I_unaEnumerator<T>;

        // I_unaArray<T>
        function getLast(): T;
        procedure setLast(const value: T);
        function getFirst(): T;
        procedure setFirst(const value: T);
        function add(const value: T): tindex;
        procedure remove(index: tindex);
        function getItem(index: tindex): T;
        procedure setItem(index: tindex; const value: T);
        function indexOf(const value: T): tindex;
        function getCount(): tindex;
        procedure assign(const value: I_unaArray<T>);
        function resize(newCount: tindex): tindex;
        function compare(const a: I_unaArray<T>): bool;
        function fill(const value: T): tindex;

        property item[index: tindex]: T read getItem write setItem; default;
        property count: tindex read getCount;
        property first: T read getFirst write setFirst;
        property last: T read getLast write setLast;
    public
        constructor Create(initialCount: tindex = 0);
        procedure AfterConstruction(); override;
    end;

    {
        2D matrix
    }
    T_unaMatrix2D<T> = class(T_unaInstance, I_unaMatrix<T>)
    private
    type
        T_unaMatrixRow = T_unaArray< T >;

        { matrix }
        T_unaMatrix = class(T_unaArray< T_unaMatrixRow >)
        private
            f_X: tindex;
        protected
            function initItem(): T_unaMatrixRow; override;
        public
            constructor Create(X, Y: tindex);
        end;

        { enum }
        T_unaMatrixEnum = class(T_unaInstance, I_unaEnumerator<T>)
        private
            f_matrix: T_unaMatrix2D<T>;
            f_indexX, f_indexY: tindex;
        protected
            // I_unaEnumerator<T>
            function getCurrent(): T;
            function MoveNext(): bool;
        public
            constructor Create(const m: T_unaMatrix2D<T>);
            destructor Destroy(); override;
        end;
    private
        f_X : tindex;
        f_Y : tindex;
        f_m : I_unaArray< T_unaMatrixRow >;
    public
        constructor Create(X, Y: tindex);

        // I_unaEnumerable<T>
        function GetEnumerator(): I_unaEnumerator<T>;

        // I_unaMatrix<T>
        function getItem(x, y: tindex): T;
        procedure setItem(x, y: tindex; const Value: T);

        property item[x, y: tindex]: T read getItem write setItem; default;
    end;

{$ENDIF FPC_BEFORE_2_7 }

    {
        byte stream
    }
    T_unaStream = class(T_unaInstance, I_unaStream)
    private
        f_isFIFO: bool;
        f_size  : memoffset;
        f_rofs,
        f_eofs  : memoffset;
        f_dataEv: I_unaEvent;
        f_buf   : I_unaMemory;
        //
        procedure checkmove(from, _to: pointer; sz: uint; write: bool);
        function  getCap(): memoffset;
        procedure setCap(value: memoffset);
        function  getBufOfs(value: memoffset): pointer;
        function  isWrapped(): bool;
        procedure ensureFit(sz: int);

        property rof: memoffset read f_rofs write f_rofs;
        property eof: memoffset read f_eofs write f_eofs;
        property buf[ofs: memoffset]: pointer read getBufOfs;
    protected
        // I_unaStream
        function  getSize(): memoffset;
        function  getIsFifo(): bool;
        procedure setIsFifo(value: bool);

        function  write(in_buf: pointer; sz: int): int;
        function  read(sz: int; out_buf: pointer): int;
        function  wait(timeout: uint = INFINITE): bool;      // wait for data event
        procedure flush();

        property  size: memoffset read getSize;
        property  capacity: memoffset read getCap write setCap;
    public
        constructor Create(isFIFO: bool = true);
        procedure BeforeDestruction(); override;
    end;

    {
        an event
    }
    T_unaEvent = class(T_unaInstance, I_unaEvent)
    private
        f_ev: handle;
    protected
        // I_unaEvent
        procedure flag();
        procedure unflag();
        function  wait(timeout: uint = INFINITE): bool;
    public
        constructor Create(manualReset: bool = true);
        procedure BeforeDestruction(); override;

        property ev: handle read f_ev;
    end;


implementation


uses
    una_utils,
    una_os,
    una_cf
{$IFDEF FPC }
    ;
{$ELSE }
    , Generics.Defaults;
{$ENDIF FPC }


{ T_unaInstance }

// --  --
procedure T_unaInstance.AfterConstruction();
begin
    inherited;

    multiThreaded := IsMultiThread;
    f_wlock := os.mx_create();
    f_rlock := os.sm_create(C_MAX_RLOCK, C_MAX_RLOCK);
end;

// --  --
procedure T_unaInstance.BeforeDestruction();
begin
    os.mx_release(f_wlock);
    os.sm_release(f_rlock);

    inherited;
end;

// --  --
function T_unaInstance.checkLock(onwrite: bool): bool;
begin
    if (not multiThreaded) then
        exit(true)
    else
    begin
        if (onwrite) then Exit( (f_wLockID = os.thread_currentId()) )
                     else Exit( (f_wlockID = 0) and (f_rlockID <> 0) );
    end;
end;

// --  --
function T_unaInstance.getRefCount(): int;
begin
    Exit( RefCount );
end;

// --  --
function T_unaInstance.lock(onwrite: bool; timeout: int): bool;
begin
    result := false;

    if (not multiThreaded) then
        Exit( true )
    else
    begin
        if (onwrite) then
        begin
            // WRITE access

            if (not os.mx_enter(f_wlock, timeout)) then Exit( false );  // could not acquire "write" mutex, panic

            try
                // wait for all read locks to be released
                while (f_rlockID <> 0) do
                    if (not os.sleep(timeout, 10)) then break;

                if (f_rlockID <> 0) then
                begin
                    // could not gain exclusive access, panic
                    f_wlockID := 0;
                    Exit( false );
                end
                else
                begin
                    f_wlockID := os.thread_currentId();
                    Exit( true );
                end;
            finally
//writeln('  lock WRITE: ', result);

if (not result) then
    writeln('  error ');

                if (not result) then
                    os.mx_leave(f_wlock)
                else
                    os.locked_inc(f_wlockCnt);
            end;
        end
        else
        begin
            // READ access

            if (not os.sm_enter(f_rlock, timeout)) then Exit( false );  // could pass the semaphore, panic

            try
                // if there is no read lock master, try to be one
                if ( (0 = f_rlockID) and os.mx_enter(f_wlock, timeout) ) then
                try
                    // mark read lock master presence
                    f_rlockID := os.thread_currentId();
                finally
                    os.mx_leave(f_wlock);
                end;

                // wait for "master" to finish the lock process
                while (f_rlockID = 0) do
                    os.sleep(timeout, 10);

                Exit( f_rlockID <> 0 );
            finally
//writeln('  lock READ: ', result);

                if (not result) then
                    os.sm_leave(f_rlock);
            end;
        end;
    end;
end;

// --  --
procedure T_unaInstance.setMT(value: bool);
begin
    f_mt := value;
end;

// --  --
procedure T_unaInstance.unlock();
var
    c : int;
    rr: bool;
    rm, wm: bool;
begin
    if (not multiThreaded) then
    else
    begin
        rm := (f_rlockID = os.thread_currentId());
        wm := (f_wlockID = os.thread_currentId());

if (f_wlockCnt > 0) and not wm then
    writeln('  error ');


        rr := (not wm or rm);
        if (rr) then
        begin
//writeln('  unlock READ ');
            c := os.sm_leave(f_rlock);
            if (c = C_MAX_RLOCK - 1) then
                // last read lock was released
                f_rlockID := 0;
        end
        else
        begin
//writeln('  unlock WRITE ');
if (f_wlockCnt < 1) then
    writeln('  error ');

            if (os.locked_dec(f_wlockCnt) < 1) then
                f_wlockID := 0;
            os.mx_leave(f_wlock);
        end;
    end;
end;


{ T_unaMem }

// --  --
procedure T_unaMem.assign(const value: I_unaMemory);
begin
    if (Assigned(value)) then
    begin
        size := value.size;
        if (size > 0) then
            move(value.ptr^, ptr^, size);
    end;
end;

// --  --
constructor T_unaMem.Create(const size: memoffset; fill: bool; fillValue: byte);
begin
    inherited Create();

    if (size > 0) then
    begin
        realloc(size);

        if (fill) then
            self.fill(0, fillValue);
    end;
end;

// --  --
destructor T_unaMem.Destroy();
begin
    realloc();

    inherited;
end;

// --  --
procedure T_unaMem.fill(const ofs: memoffset; value: byte);
begin
    if (lock(true)) then
    try
        if (size > ofs) then
            FillChar(ptr^, size - ofs, value);
    finally
        unlock();
    end;
end;

// --  --
function T_unaMem.getPtr(): pointer;
begin
    Exit( f_ptr );
end;

// --  --
function T_unaMem.getPtrAt(const ofs: memoffset): pointer;
begin
    Exit( pointer(memoffset(f_ptr) + ofs) );
end;

// --  --
function T_unaMem.getSize(): memoffset;
begin
    Exit( f_size );
end;

// --  --
procedure T_unaMem.realloc(const newsize: memoffset);
begin
    if (lock(true)) then
    try
        ReallocMem(f_ptr, newsize);
        f_size := newsize;
    finally
        unlock();
    end;
end;

{$IFDEF FPC_BEFORE_2_7 }
{$ELSE }

{ T_unaArray<T> }

// --  --
function T_unaArray<T>.add(const value: T): tindex;
begin
    if lock(true) then
    try
        f_mem.size := f_mem.size + sizeof(T);

        last := value;
        Exit( count - 1 );
    finally
        unlock();
    end;
end;

// --  --
procedure T_unaArray<T>.AfterConstruction();
begin
    resize(f_initialCount);

    inherited;
end;

// --  --
procedure T_unaArray<T>.assign(const value: I_unaArray<T>);
var
    V: T;
begin
    resize(0);

    for V in value do
        add(V);
end;

// --  --
function T_unaArray<T>.compare(const a: I_unaArray<T>): bool;
var
    i: tindex;
begin
    if (count <> a.count) then
        exit(false);

    for i := 0 to count - 1 do
        if (0 <> compareV(item[i], a[i])) then
            exit(false);

    Exit( true );
end;

// --  --
class function T_unaArray<T>.compareV(const value1, value2: T): int;
begin
{$IFDEF FPC }
    if (value1 = value2) then
        result := 0
    else
        result := 1;    // sort will not work in general case
{$ELSE }
    Exit( TComparer<T>.Default.Compare(value1, value2) );
{$ENDIF FPC }
end;

// --  --
constructor T_unaArray<T>.Create(initialCount: tindex);
begin
    inherited Create();

    f_mem := T_unaMem.Create();
    f_initialCount := initialCount;
end;

// --  --
function T_unaArray<T>.fill(const value: T): tindex;
var
    i: tindex;
begin
    if (lock()) then
    try
        for i := 0 to count - 1 do
            item[i] := value;
    finally
        unlock();
    end;

    Exit( count );
end;

// --  --
function T_unaArray<T>.getCount(): tindex;
begin
    Exit( f_mem.size div sizeof(T) );
end;

// --  --
function T_unaArray<T>.GetEnumerator(): I_unaEnumerator<T>;
begin
    if (checkLock()) then
        Exit( T_unaArrayEnum.Create(self) )
    else
        Exit( nil );
end;

// --  --
function T_unaArray<T>.getFirst(): T;
begin
    Exit( item[0] );
end;

// --  --
function T_unaArray<T>.getItem(index: tindex): T;
var
    V: ^T;
begin
    if (checkLock()) then
    begin
        V := i2p(index);
        Exit( V^ );
    end;
end;

// --  --
function T_unaArray<T>.getLast(): T;
begin
    Exit( item[count - 1] );
end;

// --  --
class function T_unaArray<T>.i2o(index: tindex): memoffset;
begin
    Exit( index * sizeof(T) );
end;

// --  --
function T_unaArray<T>.i2p(index: tindex): pointer;
begin
    Exit( f_mem[i2o(index)] );
end;

// --  --
function T_unaArray<T>.indexOf(const value: T): tindex;
var
    R: tindex;
begin
    if (checkLock()) then
    begin
        for R := 0 to count - 1 do
            if (0 = compareV(item[R], value)) then
                exit(R);
    end;

    Exit( -1 );
end;

// --  --
function T_unaArray<T>.initItem(): T;
begin
    Exit( Default(T) );
end;

// --  --
procedure T_unaArray<T>.releaseItem(index: tindex);
begin
    item[index] := Default(T);
end;

// --  --
procedure T_unaArray<T>.remove(index: tindex);
begin
    if (lock(true)) then
    try
        releaseItem(index);

        if (index < count - 1) then
            move(i2p(index + 1)^, i2p(index)^, i2o(count - index - 1));

        resize(count - 1);
    finally
        unlock();
    end;
end;

// --  --
function T_unaArray<T>.resize(newCount: tindex): tindex;
var
    i: tindex;
    oldCount: tindex;
begin
    if (lock(true)) then
    try
        oldCount := count;
        if (newCount < count) then
        begin
            for i := newCount to count - 1 do
                releaseItem(i);
        end;

        // resize, will change the count property
        f_mem.size := i2o(newCount);

        if (count > oldCount) then
        begin
            f_mem.fill(i2o(oldCount));

            for i := oldCount to count - 1 do
                item[i] := initItem();
        end;
    finally
        unlock();
    end;

    Exit( count );
end;

// --  --
procedure T_unaArray<T>.setFirst(const value: T);
begin
    item[0] := value;
end;

// --  --
procedure T_unaArray<T>.setItem(index: tindex; const value: T);
var
    V: ^T;
begin
    if (checklock(true)) then
    begin
        V := i2p(index);
        V^ := value;
    end;
end;

// --  --
procedure T_unaArray<T>.setLast(const value: T);
begin
    item[count - 1] := value;
end;


{ T_unaArray<T>.T_unaArrayEnum }

// --  --
constructor T_unaArray<T>.T_unaArrayEnum.Create(const a: T_unaArray<T>);
begin
    inherited Create();

    f_array := a;

    f_array.lock();
    f_index := -1;
end;

// --  --
destructor T_unaArray<T>.T_unaArrayEnum.Destroy();
begin
    f_array.unlock();

    inherited;
end;

// --  --
function T_unaArray<T>.T_unaArrayEnum.getCurrent(): T;
begin
    Exit( f_array[f_index] );
end;

// --  --
function T_unaArray<T>.T_unaArrayEnum.MoveNext(): bool;
begin
    inc(f_index);
    Exit( f_index < f_array.count );
end;


{ T_unaMatrix2D<T> }

// --  --
constructor T_unaMatrix2D<T>.Create(X, Y: tindex);
begin
    inherited Create();

    f_m := T_unaMatrix.Create(X, Y);
    f_X := X;
    f_Y := Y;
end;

// --  --
function T_unaMatrix2D<T>.GetEnumerator(): I_unaEnumerator<T>;
begin
    Exit( T_unaMatrixEnum.Create(self) );
end;

// --  --
function T_unaMatrix2D<T>.getItem(x, y: tindex): T;
var
    row : T_unaMatrixRow;
begin
    row := f_m[y];
    Exit( row[x] );
end;

// --  --
procedure T_unaMatrix2D<T>.setItem(x, y: tindex; const Value: T);
var
    row : T_unaMatrixRow;
begin
    row := f_m[y];
    row[x] := value;
end;


{ T_unaMatrix2D<T>.T_unaMatrixRow }

// --  --
constructor T_unaMatrix2D<T>.T_unaMatrix.Create(X, Y: tindex);
begin
    inherited Create(Y);

    f_X := X;
end;

// --  --
function T_unaMatrix2D<T>.T_unaMatrix.initItem(): T_unaMatrixRow;
begin
    Exit( T_unaMatrixRow.Create(f_X) );
end;


{ T_unaMatrix2D<T>.T_unaMatrixEnum }

// --  --
constructor T_unaMatrix2D<T>.T_unaMatrixEnum.Create(const m: T_unaMatrix2D<T>);
begin
    inherited Create();

    f_matrix := m;

    f_matrix.lock();
    f_indexX := -1;
    f_indexY := 0;
end;

// --  --
destructor T_unaMatrix2D<T>.T_unaMatrixEnum.Destroy();
begin
    f_matrix.unlock();

    inherited;
end;

// --  --
function T_unaMatrix2D<T>.T_unaMatrixEnum.getCurrent(): T;
begin
    Exit( f_matrix[f_indexX, f_indexY] );
end;

// --  --
function T_unaMatrix2D<T>.T_unaMatrixEnum.MoveNext(): bool;
begin
    inc(f_indexX);
    if (f_indexX >= f_matrix.f_X) then
    begin
        f_indexX := 0;
        inc(f_indexY);
    end;

    Exit( f_indexY < f_matrix.f_Y );
end;

{$ENDIF FPC_BEFORE_2_7 }


{ T_unaStream }

// --  --
constructor T_unaStream.Create(isFIFO: bool);
begin
    inherited Create();

    f_dataEv := cf.new_event();
    f_buf    := cf.new_memory();

    f_isFIFO := true;//isFIFO;

    flush();
end;

// --  --
procedure T_unaStream.ensureFit(sz: int);
var
    tail: memoffset;
begin
    if (0 < sz) and (uint(sz) + size > capacity) then
    begin
        if (isWrapped()) then
        begin
            // data was wrapped, need to unwrap it first
            tail := capacity;

            capacity := tail + eof + uint(sz);

            if (0 < eof) then
                checkmove(buf[0], buf[tail], eof, true);

            eof := eof + tail;  // set new EOF position to tail + size of data which was wrapped around
        end
        else
        begin
            // data is not wrapped, but we cannot fit sz bytes inplace, need to allocate more space
            capacity := uint(sz) + eof - rof;
        end;
    end;
end;

// --  --
procedure T_unaStream.flush();
begin
    rof := 0;
    eof := 0;
    capacity := 0;
    f_size := 0;
    f_dataEv.unflag();
end;

// --  --
procedure T_unaStream.BeforeDestruction();
begin
    inherited;
end;

// --  --
function T_unaStream.getBufOfs(value: memoffset): pointer;
begin
    result := f_buf[value];
end;

// --  --
function T_unaStream.getCap(): memoffset;
begin
    result := f_buf.size;
end;

procedure T_unaStream.checkmove(from, _to: pointer; sz: uint; write: bool);
{$IFDEF DEBUG }
var
    p: UIntPtr;
{$ENDIF DEBUG }
begin
{$IFDEF DEBUG }
    if (write) then p := UintPtr(_to)
               else p := UintPtr(from);

    assert( (p >= UIntPtr(buf[0])) and (p + sz <= UIntPtr(buf[capacity])) );
{$ENDIF DEBUG }

    move(from^, _to^, sz)
end;

// --  --
function T_unaStream.getIsFifo(): bool;
begin
    Exit( f_isFIFO );
end;

// --  --
function T_unaStream.getSize(): memoffset;
begin
    Exit( f_size );
end;

// --  --
function T_unaStream.isWrapped(): bool;
begin
    Exit( (0 < size) and (eof <= rof) );
end;

// --  --
function T_unaStream.read(sz: int; out_buf: pointer): int;
var
    tailSize,
    maxRead: memoffset;
begin
    if (out_buf <> nil) and (0 < sz) and (lock(true)) then
    try
        if (1 > size) then Exit( 0 );

        maxRead := min(size, uint(sz));

        if (isWrapped()) then
        begin
            tailSize := min(maxRead, capacity - rof);
            if (0 < tailSize) then
            begin
                checkmove(buf[rof], out_buf, tailSize, false);
                dec(maxRead, tailSize);
                out_buf := ptr_inc(out_buf, tailSize);

                rof := rof + tailSize;
                if (rof >= capacity) then
                    // since we have read everything from tail, move read pos to zero
                    rof := 0;
            end;

            if (0 < maxRead) then
            begin
                checkmove(buf[0], out_buf, maxRead, false);
                rof := maxRead;
            end;

            // restore maxRead
            inc(maxRead, tailSize);
        end
        else
        begin
            // can read all data inplace
            checkmove(buf[rof], out_buf, maxRead, false);
            rof := rof + maxRead;
            if (rof >= capacity) then
            begin
                // no more data left, reset head and tail
                rof := 0;
                eof := 0;
            end;
        end;

        dec(f_size, maxRead);
        if (1 > size) then
            f_dataEv.unflag();

        Exit( int(maxRead) );
    finally
        unlock();
    end
    else
        Exit( -1 );
end;

// --  --
procedure T_unaStream.setCap(value: memoffset);
begin
    f_buf.size := value;
end;

// --  --
procedure T_unaStream.setIsFifo(value: bool);
begin
    // todo
end;

// --  --
function T_unaStream.wait(timeout: uint): bool;
begin
    result := f_dataEv.wait(timeout);
end;

// --  --
function T_unaStream.write(in_buf: pointer; sz: int): int;
var
    tailSize: memoffset;
begin
    if (in_buf <> nil) and (0 < sz) and (lock(true)) then
    try
        ensureFit(sz);

        if (isWrapped()) then
        begin
            // already wrapped, must fit as is
            checkmove(in_buf, buf[eof], sz, true);
            eof := eof + uint(sz);
        end
        else
        begin
            // first fill the tail
            tailSize := min(uint(sz), capacity - eof);
            if (0 < tailSize) then
            begin
                checkmove(in_buf, buf[eof], tailSize, true);
                in_buf := ptr_inc(in_buf, tailSize);
                dec(sz, tailSize);
                eof := eof + tailSize;
            end;

            // wrap around
            if (0 < sz) then
            begin
                checkmove(in_buf, buf[0], sz, true);
                eof := sz;
            end;

            // restore sz
            inc(sz, tailSize);
        end;

        inc(f_size, sz);
        f_dataEv.flag();

        Exit(sz);
    finally
        unlock();
    end
    else
        Exit( -1 );
end;


{ T_unaEvent }

// --  --
procedure T_unaEvent.BeforeDestruction();
begin
    os.ev_release(f_ev);

    inherited;
end;

// --  --
constructor T_unaEvent.Create(manualReset: bool);
begin
    inherited Create();

    f_ev := os.ev_new(manualReset);
end;

// --  --
procedure T_unaEvent.flag();
begin
    os.ev_flag(f_ev);
end;

// --  --
procedure T_unaEvent.unflag();
begin
    os.ev_flag(f_ev, false);
end;

// --  --
function T_unaEvent.wait(timeout: uint): bool;
begin
    result := os.ev_wait(f_ev, timeout);
end;


end.

