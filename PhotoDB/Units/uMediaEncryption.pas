unit uMediaEncryption;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.Win.Registry,

  uConstants,
  uTransparentEncryption,
  uFormInterfaces,
  uSettings,
  uRuntime,
  uMediaPlayers,
  uTranslate,
  uShellIntegration,
  uAssociations,
  uSessionPasswords;

type
  TMachineType = (mtUnknown, mt32Bit, mt64Bit, mtOther);

function ShellPlayEncryptedMediaFile(const FileName: string): Boolean;
function GetLibMachineType(const AFileName: string): TMachineType;
function GetFileBindings(FileName: string): string;

implementation

function GetFileBindings(FileName: string): string;
var
  Extension: string;
begin
  Extension := ExtractFileExt(FileName);
  Result := Settings.ReadString(cMediaAssociationsData + '\' + Extension, '');
  if Result = cMediaPlayerDefaultId then
    Result := GetPlayerInternalPath;
end;

function ExpandEnvironment(const strValue: string): string;
var
  chrResult: array[0..1023] of Char;
  wrdReturn: DWORD;
begin
  wrdReturn := ExpandEnvironmentStrings(PChar(strValue), chrResult, 1024);
  if wrdReturn = 0 then
    Result := strValue
  else
  begin
    Result := Trim(chrResult);
  end;
end;

function ShellPlayEncryptedMediaFile(const FileName: string): Boolean;
var
  Executable,
  TransparentDecryptor,
  Password: string;
  ExecutableType: TMachineType;
  Si: TStartupInfo;
  P: TProcessInformation;
begin
  Result := False;

  if ValidEnryptFileEx(FileName) then
  begin
    Password := SessionPasswords.FindForFile(FileName);

    if (Password = '') then
      Password := RequestPasswordForm.ForImage(FileName);
    if Password = '' then
      //play started but user don't know password - it's OK
      Exit(True);
  end;

  if FolderView then
  begin
    if not IsGraphicFile(FileName) then
      MessageBoxDB(0, TA('Transparent encryption isn''t available on mobile verison.', 'System'), TA('Information'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;

  Executable := GetFileBindings(FileName);
  if Executable = '' then
    Executable := GetShellPlayerForFile(FileName);

  if Executable <> '' then
  begin
    Executable := ExpandEnvironment(Executable);

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
