
{$I una_def.inc }

{-- --

    some types

    by Lake

-- --}

unit
    una_types;

interface

type
    i_8     = shortint;
    i_16    = smallint;
    i_32    = integer;
    i_64    = int64;

    u_8     = byte;
    u_16    = word;
    u_32    = cardinal;
    u_64    = uint64;

    f_32    = single;
    f_64    = double;

    b_32    = longbool;

    float   = f_32;
    tresult = i_32;
    bool    = b_32;
    handle  = NativeUInt;

    memoffset = NativeUInt;

{$IFDEF NO_NATIVE_PTR_TYPES }
    UIntPtr = u_32;
{$ENDIF NO_NATIVE_PTR_TYPES }

    {$IFDEF CPU32 }
    tindex = int32;
    int = int32;
    uint = uint32;
    {$ELSE }
        {$IFDEF CPU64 }

        {$IFDEF FPC }
            tindex = int64;
        {$ELSE }
            tindex = int32; // delphi does not allow 64-bits for loop vars
        {$ENDIF FPC }

        int = int64;
        uint = uint64;
        {$ELSE }
            {$IFDEF CPUX128 }
                // yet to come
            {$ELSE }
                // 256!
            {$ENDIF CPUX128 }
        {$ENDIF CPU64 }
    {$ENDIF CPU32 }

const
    R_OK    : tresult =  0;
    R_ERROR : tresult = -1;
{$IFDEF FPC }
    INFINITE = Cardinal(-1);
{$ENDIF FPC }


implementation


end.

