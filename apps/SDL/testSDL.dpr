
{$I una_def.inc }

program
    testSDL.dpr;

{$APPTYPE CONSOLE}

uses
    SysUtils,
    una_types,
    una_os,
    una_SDL_API;

const
{$IFDEF CPU64}
    libName = 'D:\pcodecpack\bin\x64\opus.dll';
{$ELSE}
    libName = 'D:\pcodecpack\bin\x86\opus.dll';
{$ENDIF CPU64 }

    source_mp3 = '../../data/Mourning Day by SadMe.wav';


procedure p();
begin
end;


// -- main --

begin
    IsMultiThread := true;
    try
        p();
    except
        on E: Exception do
            Writeln(E.ClassName, ': ', E.Message);
    end;
end.
