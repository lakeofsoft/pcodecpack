
{$I una_def.inc }

{-- --

    some interfaces

    by Lake

-- --}

unit
    una_interfaces;

interface

uses
    una_types;

type
    {
        interface
    }
    I_unaInstance = interface
    ['{17B3CD25-CEAD-4EF4-9825-4E8B14424495}']
        function getRefCount(): int;

        property refCount: int read getRefCount;
    end;

    {
        something that can be compared with each other
    }
    I_comparable<T> = interface(I_unaInstance)
    ['{377E75F1-0847-4EBF-B198-ECDB2B88DC49}']
        function compare(const value: T): int;
    end;

    {
        something that enumerates
    }
    I_unaEnumerator<T> = interface(I_unaInstance)
    ['{7EC25048-5538-4623-9363-526B4B96FAD5}']
        function getCurrent(): T;
        function MoveNext(): bool;

        property Current: T read getCurrent;
    end;

    {
        something that can be enumerated
    }
    I_unaEnumerable<T> = interface(I_unaInstance)
    ['{6A785F06-EAB3-433E-8797-4190461BA44E}']
        function GetEnumerator(): I_unaEnumerator<T>;
    end;

    {
        a chunk of memory
    }
    I_unaMemory = interface(I_unaInstance)
    ['{8EE9C3B5-CDCA-45C7-A954-537FE5657B17}']
        procedure fill(const ofs: memoffset = 0; value: Byte = 0);
        function getSize(): memoffset;
        procedure realloc(const newsize: memoffset = 0);
        function getPtrAt(const ofs: memoffset): pointer;
        function getPtr(): pointer;
        procedure assign(const value: I_unaMemory);

        property size   : memoffset read getSize write realloc;
        property ptr    : pointer read getPtr;
        property at[const ofs: memoffset]: pointer read getPtrAt; default;
    end;

    {
        something like an array of something
    }
    I_unaArray<T> = interface(I_unaEnumerable<T>)
    ['{862D0A4C-8721-4C4F-A6FB-F283665F501C}']
        function getItem(index: tindex): T;
        procedure setItem(index: tindex; const value: T);
        function add(const value: T): tindex;
        procedure remove(index: tindex);
        function indexOf(const value: T): tindex;
        function getCount(): tindex;
        procedure assign(const value: I_unaArray<T>);
        function getLast(): T;
        procedure setLast(const value: T);
        function getFirst(): T;
        procedure setFirst(const value: T);
        function resize(newCount: tindex): tindex;
        function compare(const a: I_unaArray<T>): bool;
        function fill(const value: T): tindex;

        property item[index: tindex]: T read getItem write setItem; default;
        property count: tindex read getCount;
        property first: T read getFirst write setFirst;
        property last: T read getLast write setLast;
    end;

    {
        like a matrix
    }
    I_unaMatrix<T> = interface(I_unaEnumerable<T>)
    ['{EF1518C0-4AC3-4B66-AD63-A226EAE59D4B}']
        function getItem(x, y: tindex): T;
        procedure setItem(x, y: tindex; const Value: T);

        property item[x, y: tindex]: T read getItem write setItem; default;
    end;

    {
        something like a FIFO stream
    }
    I_unaStream = interface(I_unaInstance)
    ['{5224C76F-163E-4BB7-AF51-CB788B984B3C}']
        function  getSize(): memoffset;
        function  getIsFifo(): bool;
        procedure setIsFifo(value: bool);

        function  write(in_buf: pointer; sz: int): int;
        function  read(sz: int; out_buf: pointer): int;
        function  wait(timeout: uint = INFINITE): bool; // wait for data event
        procedure flush();

        property  size   : memoffset read getSize;
        property  isFifo : bool read getIsFifo write setIsFifo;
    end;

    {
        something like an event
    }
    I_unaEvent = interface(I_unaInstance)
    ['{5224C76F-163E-4BB7-AF51-CB788B984B3C}']
        procedure flag();
        procedure unflag();
        function  wait(timeout: uint = INFINITE): bool;
    end;

implementation

end.

