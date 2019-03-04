

{$I una_def.inc }

{-- --

    class factory

    by Lake

-- --}

unit
    una_cf;

interface

uses
    una_types,
    una_interfaces;

type
    {
        class factory
    }
    T_unaClassFactory = class
    public
        class function new_memory(const size: memoffset = 0; fill: bool = false; fillValue: byte = 0): I_unaMemory;
{$IFDEF FPC_BEFORE_2_7 }
{$ELSE }
        class function new_array<T>(initialCount: tindex = 0): I_unaArray<T>;
        class function new_matrix<T>(X, Y: tindex): I_unaMatrix<T>;
{$ENDIF FPC_BEFORE_2_7 }
        class function new_stream(isFIFO: bool = true): I_unaStream;
        class function new_event(manualReset: bool = true): I_unaEvent;
    end;
    cf = T_unaClassFactory;


implementation


uses
    una_classes;


{ T_unaClassesFactory }

{$IFDEF FPC }
{$ELSE }

// --  --
class function T_unaClassFactory.new_array<T>(initialCount: tindex): I_unaArray<T>;
begin
    Exit( T_unaArray<T>.Create(initialCount) );
end;

{$ENDIF FPC
}
// --  --
class function T_unaClassFactory.new_event(manualReset: bool): I_unaEvent;
begin
    Exit( T_unaEvent.Create(manualReset) );
end;

{$IFDEF FPC }
{$ELSE }

// --  --
class function T_unaClassFactory.new_matrix<T>(X, Y: tindex): I_unaMatrix<T>;
begin
    Exit( T_unaMatrix2D<T>.Create(X, Y) );
end;

{$ENDIF FPC}

// --  --
class function T_unaClassFactory.new_memory(const size: memoffset; fill: bool; fillValue: byte): I_unaMemory;
begin
    Exit( T_unaMem.Create(size, fill, fillValue) );
end;

// --  --
class function T_unaClassFactory.new_stream(isFIFO: bool): I_unaStream;
begin
    Exit( T_unaStream.Create() );
end;


end.

