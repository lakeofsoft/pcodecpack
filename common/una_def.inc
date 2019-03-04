
{$I delphi_versions.inc }

{$IFDEF DEBUG }
    {$O- }
{$ELSE }
    {$O+ }
{$ENDIF DEBUG }

{$IFDEF FPC }

    {$IFDEF FPC_BEFORE_2_7 }
        {$mode delphi }
    {$ELSE }
        {$mode delphiunicode }
    {$ENDIF FPC_BEFORE_2_7 }

    {$DEFINE NO_CLOSURES }  // ;(

{$ELSE }
    {$IFDEF MSWINDOWS }
        {$DEFINE WINDOWS }
    {$ENDIF MSWINDOWS }
{$ENDIF FPC }

{$IFDEF CPUAMD64 }
    {$DEFINE CPU64 }
{$ENDIF CPUAMD64 }

{$IFDEF CPUX64 }	// defined by dcc64 only
  {$DEFINE CPU64 }
{$ENDIF CPUX64 }

{$IFDEF WIN64 }		// defined by dcc64 only
  {$DEFINE CPU64 }
{$ENDIF WIN64 }

// ----------------------


{$IFDEF CPU64 }
{$ELSE}
    {$IFDEF CPU16 }
    {$ELSE }
        {$DEFINE CPU32 }
    {$ENDIF CPU16 }
{$ENDIF CPU64 }

{$IFDEF __BEFORE_DE__ }
    {$DEFINE NO_NATIVE_PTR_TYPES }
{$ENDIF __BEFORE_DE__ }



// remove me!
    {x $DEFINE NO_CLOSURES }  // ;(

