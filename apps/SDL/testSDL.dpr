
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
    libName = 'D:\_my\_src\~3pt\_cpp\opus\win32\VS2015\x64\ReleaseDLL\opus.dll';
{$ELSE}
    libName = 'D:\_my\_src\~3pt\_cpp\opus\win32\VS2015\Win32\ReleaseDLL\opus.dll';
{$ENDIF CPU64 }

    source_wav = '../../data/Mourning Day by SadMe.wav';
    dest_enc   = '../../data/Mourning Day by SadMe.enc';
    dest_pcm   = '../../data/Mourning Day by SadMe.pcm';

// --  --
procedure e();
var
    api: T_unaOpusAPI;
    enc: T_unaOpusEncoder;
    fileSrc,
    fileDst: THandle;
    frame_size: int;
    fileSize,
    ofs: int64;
    readSize : int;
    enc_size : int;
    src_buf: array[word] of byte;
    dst_buf: array[word] of byte;
begin
    api := T_unaOpusAPI.create(libname);
    try
        WriteLn('Encoding, API Version: ', api.ver_string() + ' ..');
        //
        enc := T_unaOpusEncoder.Create(api);
        try
            enc.open(48000, 2, false);
            enc.bandwidth := OPUS_BANDWIDTH_FULLBAND;
            enc.bitrate := 1024 * 64;

            WriteLn('Complexity: ', enc.complexity);
            //
            WriteLn('Bitrate: ',    enc.bitrate);
            WriteLn('VBR: ',        enc.vbr);
            WriteLn('VBR_Const: ',  enc.vbr_constraint);
            WriteLn('Force_Ch: ',   enc.force_channels);
            WriteLn('Max.bandw: ',  enc.max_bandwidth);
            WriteLn('Bandwidth: ',  enc.bandwidth);
            WriteLn('Signal: ',     enc.signal);
            WriteLn('Application: ',enc.application);
            WriteLn('Lookahead: ',  enc.lookahead);
            WriteLn('Inband FEC: ', enc.inband_fec);
            WriteLn('PacketLoss%: ',enc.packet_loss_perc);
            WriteLn('DXT: ',        enc.dxt);
            //
            WriteLn('LSB Depth: ',  enc.lsb_depth);
            WriteLn('Frame Duration: ', enc.frame_duration);
            WriteLn('Pred. Disabled: ', enc.prediction_disabled);
            WriteLn('Sample Rate: ', enc.sample_rate);

            fileSrc := os.file_open(source_wav);
            fileDst := os.file_open(dest_enc, os.FM_WRITE, true);
            try
                fileSize := os.file_size(fileSrc);
                frame_size := (48000 div 1000) * 60;  // 60 ms of 48000
                ofs := 44;
                os.file_seek(fileSrc, ofs);
                while (ofs < fileSize) do
                begin
                    readSize := os.file_read(fileSrc, @src_buf, frame_size shl 2);
                    if (readSize > 0) then
                    begin
                        if (readSize = frame_size shl 2) then
                            enc_size := enc.encode(@src_buf, readSize shr 2, @dst_buf[2], sizeof(dst_buf) - 2)
                        else
                            enc_size := 0;
                        //
                        if (0 < enc_size) then
                        begin
                            move(enc_size, dst_buf[0], 2);
                            os.file_write(fileDst, @dst_buf, enc_size + 2);
                        end;
                        //
                        inc(ofs, readSize);
                    end
                    else
                        break;
                end;
            finally
                os.file_release(fileSrc);
                os.file_release(fileDst);
            end;
        finally
            enc.Free();
        end;
    finally
        api.Free();
    end;
end;


// --  --
procedure d();
var
    api: T_unaOpusAPI;
    dec: T_unaOpusDecoder;
    fileSrc,
    fileDst: THandle;
    ofs: int64;
    maxLen: int;
    readSize : int;
    dec_size : int;
    src_buf: array[word] of byte;
    dst_buf: array[word] of byte;
    blockSize: word;
begin
    api := T_unaOpusAPI.create(libName);
    try
        WriteLn('Decoding, API Version: ', api.ver_string(), ' ..');
        //
        dec := T_unaOpusDecoder.Create(api);
        try
            dec.open(48000, 2);
            //
            WriteLn('Bandwidth: ',  dec.bandwidth);
            WriteLn('Gain: ', dec.gain);
            WriteLn('Packet Dur: ', dec.packet_duration);
            WriteLn('Pitch: ', dec.pitch);
            WriteLn('Sample Rate: ', dec.sample_rate);
            //
            fileSrc := os.file_open(dest_enc);
            fileDst := os.file_open(dest_pcm, os.FM_WRITE, true);
            try
                maxLen := os.file_size(fileSrc) - 2;
                ofs := 0;
                while (ofs < maxLen) do
                begin
                    if (os.file_read(fileSrc, @blockSize, 2) = 2) and (blockSize > 0) then
                    begin
                        readSize := os.file_read(fileSrc, @src_buf, blockSize);
                        if (readSize = blockSize) then
                        begin
                            dec_size := dec.decode(@src_buf, blockSize, @dst_buf, sizeof(dst_buf)) shl 2;
                            if (0 < dec_size) then
                                os.file_write(fileDst, @dst_buf, dec_size);
                            //
                            inc(ofs, blockSize + 2);
                        end
                        else
                            break;
                    end
                    else
                        break;
                end;
            finally
                os.file_release(fileSrc);
                os.file_release(fileDst);
            end;
        finally
            dec.Free();
        end;
    finally
        api.Free();
    end;
end;


// -- main --

begin
    IsMultiThread := true;
    try
        e();
        d();
    except
        on E: Exception do
            Writeln(E.ClassName, ': ', E.Message);
    end;
end.
