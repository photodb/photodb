unit uMediaEncryption;

interface

uses
  Windows,
  SysUtils,
  Classes,
  Registry,
  uMemory,
  uAppUtils,
  uStrongCrypt,
  uTransparentEncryption,
  uFormInterfaces,
  UnitDBKernel;

type
  TMachineType = (mtUnknown, mt32Bit, mt64Bit, mtOther);

function ShellPlayEncryptedMediaFile(FileName: string): Boolean;
function GetLibMachineType(const AFileName: string): TMachineType;

implementation

function ShellPlayEncryptedMediaFile(FileName: string): Boolean;
var
  Handler,
  CommandLine,
  Executable,
  TransparentDecryptor, Password: string;
  ExecutableType: TMachineType;
  Reg: TRegistry;
  Si: TStartupInfo;
  P: TProcessInformation;
begin
  Result := False;

  if ValidEnryptFileEx(FileName) then
  begin
    Password := DBKernel.FindPasswordForCryptImageFile(FileName);

    if (Password = '') then
      Password := RequestPasswordForm.ForImage(FileName);
    if Password = '' then
      //play started but user don't know password - it's OK
      Exit(True);
  end;

  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    if Reg.OpenKey(ExtractFileExt(FileName), False) then
    begin
      Handler := Reg.ReadString('');
      if Handler <> '' then
      begin
        if Reg.OpenKey('\' + Handler + '\shell\open\command', False) then
        begin
          CommandLine := Reg.ReadString('');
          if CommandLine <> '' then
          begin
            Executable := ParamStrEx(CommandLine, -1);
            if Executable <> '' then
            begin
              ExecutableType := GetLibMachineType(Executable);
              if ExecutableType in [mt32Bit, mt64Bit] then
              begin
                TransparentDecryptor := ExtractFilePath(ParamStr(0)) + 'PlayEncryptedMedia';
                if ExecutableType = mt64Bit  then
                  TransparentDecryptor := TransparentDecryptor + '64';

                TransparentDecryptor := TransparentDecryptor + '.exe';

                FillChar(Si, SizeOf(Si), 0);
                with Si do
                begin
                  Cb := SizeOf(Si);
                  DwFlags := STARTF_USESHOWWINDOW;
                  WShowWindow := SW_SHOW;
                end;
                if CreateProcess(PChar(TransparentDecryptor), PWideChar('"' + TransparentDecryptor + '" "' + Executable + '" "' + FileName + '"'), nil, nil, False,
                  CREATE_DEFAULT_ERROR_MODE, nil, nil, Si, P) then
                  Result := True;
              end;
            end;
          end;
        end;
      end;
    end;
  finally
    F(Reg);
  end;
end;

function GetLibMachineType(const AFileName: string): TMachineType;
var
  oFS: TFileStream;
  iPeOffset: Integer;
  iPeHead: LongWord;
  iMachineType: Word;
begin
  Result := mtUnknown;
  // http://download.microsoft.com/download/9/c/5/9c5b2167-8017-4bae-9fde-d599bac8184a/pecoff_v8.doc
  // Offset to PE header is always at 0x3C.
  // PE header starts with "PE\0\0" = 0x50 0x45 0x00 0x00,
  // followed by 2-byte machine type field (see document above for enum).
  try
    oFS := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
    try
      oFS.Seek($3C, soFromBeginning);
      oFS.Read(iPeOffset, SizeOf(iPeOffset));
      oFS.Seek(iPeOffset, soFromBeginning);
      oFS.Read(iPeHead, SizeOf(iPeHead));
      // "PE\0\0", little-endian then
      if iPeHead <> $00004550 then
        Exit;
      oFS.Read(iMachineType, SizeOf(iMachineType));
      case iMachineType of
      $8664, // AMD64
      $0200: // IA64
        Result := mt64Bit;
      $014C: // I386
        Result := mt32Bit;
      else
        Result := mtOther;
      end;
    finally
      oFS.Free;
    end;
  except
    // none
  end;
end;

end.
