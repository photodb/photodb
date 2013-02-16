unit UnitScriptsFunctions;

interface

uses
  Winapi.Windows,
  Winapi.ShlObj,
  Winapi.ShellAPI,
  System.SysUtils,
  System.Classes,
  System.Win.Registry,
  Vcl.Dialogs,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtDlgs,

  Dmitry.Utils.Files,
  Dmitry.Utils.Dialogs,

  UnitScripts,
  Dolphin_DB,
  UnitDBFileDialogs,
  ReplaseIconsInScript,

  uScript,
  uConstants,
  uLogger,
  uShellIntegration,
  uTime,
  uMemory,
  uTranslate,
  uRuntime;

function GetOpenFileName(InitFile, Filter: string): string;
function GetSaveFileName(InitFile, Filter: string): string;
procedure CreateFile(FileName: string);
procedure WriteToFile(FileName, aString: string);
procedure WriteLnToFile(FileName, aString: string);
function aExtractFileName(FileName: string): string;
function aPos(sub, str: string): integer;
function aStrCopy(s: string; aBegin, aLength: Integer): string;
function aStrToInt(s: string): integer;
function GetDirListing(Dir: String; Mask: string): TArrayOfString;
function SpilitWords(s: string): TArrayOfString;
function SpilitWordsW(s: string; SplitChar: Char): TArrayOfString;
function aIntToStr(Value: integer): string;
procedure Default(const aScript: TScript);
procedure InVisible(const aScript: TScript);
procedure Disabled(const aScript: TScript);
procedure Checked(const aScript: TScript);
function aDirectoryExists(FileName: string): Boolean;
function aDirectoryFileExists(FileName: string): Boolean;
function aPathFormat(aPath, aFile: string): string;
procedure CopyFile(aFile: string);
procedure CutFile(aFile: string);
procedure CopyFiles(Files: TArrayOfString);
procedure CutFiles(Files: TArrayOfString);
function LoadFilesFromClipBoardA: TArrayOfString;
function NowString: String;
function SumInt(int1, int2: Integer): Integer;
function SumStr(str1, str2: string): string;
procedure ExecAndWait(FileName, Params: String);
procedure Run(ExeFile, Params: String);
procedure Exec(FileName: string);
Procedure aCopyFile(FromFile, ToDir: string);
procedure aRenameFile(s, D: String);
function ShowInt(int: Integer): string;
procedure aDeleteFile(s: String);
function AltKeyDown: Boolean;
function CtrlKeyDown: Boolean;
function ShiftKeyDown: Boolean;
procedure ShowString(str: string);
function GetSmallIconByPath(IconPath: String; Big: boolean = False): TIcon;
function AddIcon(Path: string; ImageList: TImageList; var IconsCount: Integer): Integer;
function AddAssociatedIcon(Path: string; ImageList: TImageList; var IconsCount: integer): Integer;
function GetUSBDrives: TArrayOfString;
function GetCDROMDrives: TArrayOfString;
function GetAllDrives: TArrayOfString;
function DriveState(DriveLetter: AnsiChar): TSDriveState;
function GetDriveName(Drive: string; DefString: string): string;
function GetMyPicturesFolder: string;
function GetMyDocumentsFolder: string;
function GetProgramFolder: string;
function GetSaveImageFileName(InitFile, Filter: string): string;
function GetOpenImageFileName(InitFile, Filter: string): string;
procedure CopyFileSynch(s, D: string);
function FileInPath(aFile, aPath: string): Boolean;
function GetOpenDirectory(Caption, Root: string): string;
function FileHasExt(aFile, aExt: string): Boolean;
function ExtractFileDirectory(FileName: string): string;
procedure ExecuteScriptFile(FileName: string; UseDBFunctions: Boolean = False);

implementation

procedure ExecuteScriptFile(FileName: string; UseDBFunctions: Boolean = False);
var
  AScript: TScript;
  I: Integer;
  LoadScript: string;
  AFS: TFileStream;
begin
  AScript := TScript.Create(nil, '');
  try
    LoadScript := '';
    try
      AFS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
      SetLength(LoadScript, AFS.Size);
      AFS.read(LoadScript[1], AFS.Size);
      for I := Length(LoadScript) downto 1 do
      begin
        if LoadScript[I] = #10 then
          LoadScript[I] := ' ';
        if LoadScript[I] = #13 then
          LoadScript[I] := ' ';
      end;
      LoadScript := AddIcons(LoadScript);
      AFS.Free;
    except
    end;
    try
      ExecuteScript(nil, AScript, LoadScript, I, nil);
    except
      on e: Exception do EventLog(':ExecuteScriptFile() throw exception: '+e.Message);
    end;
  finally
    F(AScript);
  end;
end;

function FileHasExt(aFile, aExt : string) : boolean;
begin
  AFile := GetExt(AFile);
  Result := ExtinMask(AExt, AFile);
end;

function GetProgramFolder : string;
begin
  Result := ExtractFilePath(Application.ExeName);
end;

function ExtractFileDirectory(FileName : string) : string;
begin
  Result := ExtractFilePath(FileName);
end;

function GetOpenFileName(InitFile, Filter: string): string;
var
  FD: DBOpenDialog;
begin
  Result := '';
  FD := DBOpenDialog.Create;
  try
    FD.SetFileName(InitFile);
    FD.Filter := Filter;
    if FD.Execute then
      Result := FD.FileName;
  finally
    F(FD);
  end;
end;

function GetOpenDirectory(Caption, Root: string): string;
begin
  Caption := TA(Caption, 'DBMenu');
  if DirectoryExists(Root) then
    Result := UnitDBFileDialogs.DBSelectDir(Application.Handle, Caption, Root, UseSimpleSelectFolderDialog)
  else
    Result := UnitDBFileDialogs.DBSelectDir(Application.Handle, Caption, UseSimpleSelectFolderDialog);
end;

function GetSaveFileName(InitFile, Filter: string): string;
var
  FD: DBSaveDialog;
begin
  Result := '';
  FD := DBSaveDialog.Create;
  try
    FD.SetFileName(InitFile);
    FD.Filter := Filter;
    if FD.Execute then
      Result := FD.FileName;
  finally
    F(FD);
  end;
end;

function GetOpenImageFileName(InitFile, Filter: string): string;
var
  FD: DBOpenPictureDialog;
begin
  Result := '';
  FD := DBOpenPictureDialog.Create;
  try
    FD.SetFileName(InitFile);
    FD.Filter := Filter;
    if FD.Execute then
      Result := FD.FileName;
  finally
    F(FD);
  end;
end;

function GetSaveImageFileName(InitFile, Filter : string) : string;
var
  FD: DBSavePictureDialog;
begin
  Result := '';
  FD := DBSavePictureDialog.Create;
  try
    FD.SetFileName(InitFile);
    FD.Filter := Filter;
    if FD.Execute then
      Result := FD.FileName;
  finally
    F(FD);
  end;
end;

procedure CreateFile(FileName: string);
var
  FS: TFileStream;
begin
  try
    FS := TFileStream.Create(FileName, FmCreate);
  except
    on E: Exception do
      EventLog(':CreateFile() throw exception: ' + E.message);
  end;
  F(FS);
end;

procedure WriteToFile(FileName, AString: string);
var
  FS: TFileStream;
begin
  try
    FS := TFileStream.Create(FileName, fmOpenWrite);
  except
    on E: Exception do
    begin
      EventLog(':WriteToFile() throw exception: ' + E.message);
      Exit;
    end;
  end;
  try
    FS.Seek(0, SoEnd);
    FS.Write(AString[1], Length(AString));
  finally
    F(FS);
  end;
end;

procedure WriteLnToFile(FileName, AString: string);
var
  FS: TFileStream;
  Eof: array [0 .. 1] of Byte;
begin
  try
    FS := TFileStream.Create(FileName, fmOpenWrite);
  except
    on E: Exception do
    begin
      EventLog(':WriteLnToFile() throw exception: ' + E.message);
      Exit;
    end;
  end;
  try
    FS.Seek(0, SoEnd);
    Eof[0] := 13;
    Eof[1] := 10;
    FS.write(AString[1], Length(AString));
    FS.write(Eof[0], 2);
  finally
    F(FS);
  end;
end;

function AExtractFileName(FileName: string): string;
begin
  Result := ExtractFileName(FileName);
end;

function APos(Sub, Str: string): Integer;
begin
  Result := Pos(Sub, Str);
end;

function AStrCopy(S: string; ABegin, ALength: Integer): string;
begin
  Result := Copy(S, ABegin, ALength);
end;

function AStrToInt(S: string): Integer;
begin
  Result := StrToIntDef(S, 0);
end;

function GetDirListing(Dir : String; Mask : string) : TArrayOfString;
var
  Found  : integer;
  SearchRec : TSearchRec;
  oldMode: Cardinal;

  function ExtInMask(Mask: string; Ext: string): Boolean;
  begin
    Result := Pos('|' + Ext + '|', Mask) <> -1;
  end;

  function GetExt(FileName: string): string;
  var
    S: string;
  begin
    S := ExtractFileExt(FileName);
    Result := AnsiUpperCase(Copy(S, 1, Length(S) - 1));
  end;

begin
  TW.I.Start('GetDirListing');
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    SetLength(Result, 0);
    if Dir = '' then
      Exit;
    Dir := IncludeTrailingBackslash(Dir);
    Found := FindFirst(Dir + '*.*', FaAnyFile - FaDirectory, SearchRec);
    try
      while Found = 0 do
      begin
        if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
          if ExtInMask(GetExt(SearchRec.name), Mask) then
          begin
            SetLength(Result, Length(Result) + 1);
            Result[Length(Result) - 1] := Dir + SearchRec.name;
          end;
        Found := System.SysUtils.FindNext(SearchRec);
      end;
    finally
      FindClose(SearchRec);
    end;
  finally
    SetErrorMode(OldMode);
  end;
  TW.I.Start('GetDirListing - END');
end;

function SpilitWords(S : string) : TArrayOfString;
begin
  Result := SpilitWordsW(S, ' ');
end;

function SpilitWordsW(S : string; SplitChar : char) : TArrayOfString;
var
  I: Integer;
  SL: TStrings;
begin
  SL := TStringList.Create;
  try
    SL.Delimiter := SplitChar;
    SL.DelimitedText := S;
    for I := SL.Count - 1 downto 0 do
      if Trim(SL[I]) = '' then
        SL.Delete(I);

    SetLength(Result, SL.Count);
    for I := SL.Count - 1 downto 0 do
      Result[I] := Trim(SL[I]);

  finally
    SL.Free;
  end;
end;

function aIntToStr(Value: integer) : string;
begin
  Result:=IntToStr(Value);
end;

procedure default(const AScript: TScript);
begin
  SetNamedValue(AScript, '$Default', 'true');
end;

procedure InVisible(const AScript: TScript);
begin
  SetNamedValue(AScript, '$Visible', 'false');
end;

procedure Disabled(const AScript: TScript);
begin
  SetNamedValue(AScript, '$Enabled', 'false');
end;

procedure Checked(const AScript: TScript);
begin
  SetNamedValue(AScript, '$Checked', 'true');
end;

function ADirectoryExists(FileName: string): Boolean;
var
  OldMode: Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result := DirectoryExists(FileName);
  finally
    SetErrorMode(OldMode);
  end;
end;

function ADirectoryFileExists(FileName: string): Boolean;
var
  OldMode: Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result := DirectoryExists(ExtractFileDir(FileName));
  finally
    SetErrorMode(OldMode);
  end;
end;

function APathFormat(APath, AFile: string): string;
begin
  Result := StringReplace(APath, '%1', AFile, [RfReplaceAll, RfIgnoreCase]);
end;

procedure CopyFileSynch(S,D: string);
begin
  Winapi.Windows.CopyFile(PChar(S),PChar(D),true);
end;

procedure CopyFile(aFile: string);
var
  AFiles: TStrings;
begin
  AFiles := TStringList.Create;
  try
    AFiles.Add(AFile);
    Copy_Move(Application.Handle, True, AFiles);
  finally
    F(AFiles);
  end;
end;

procedure CutFile(aFile: string);
var
  AFiles: TStrings;
begin
  AFiles := TStringList.Create;
  try
    AFiles.Add(AFile);
    Copy_Move(Application.Handle, False, AFiles);
  finally
    F(AFiles);
  end;
end;

procedure CopyFiles(Files: TArrayOfString);
var
  I: Integer;
  AFiles: TStrings;
begin
  AFiles := TStringList.Create;
  try
    for I := 0 to Length(Files) - 1 do
      AFiles.Add(Files[I]);

    Copy_Move(Application.Handle, True, AFiles);
  finally
    F(AFiles);
  end;
end;

procedure CutFiles(Files: TArrayOfString);
var
  I: Integer;
  AFiles: TStrings;
begin
  AFiles := TStringList.Create;
  try
    for I := 0 to Length(Files) - 1 do
      AFiles.Add(Files[I]);

    Copy_Move(Application.Handle,False, AFiles);
  finally
    F(AFiles);
  end;
end;

function LoadFilesFromClipBoardA: TArrayOfString;
var
  I, Effects: Integer;
  Files: TStrings;
begin
  Files := TStringList.Create;
  try
    LoadFilesFromClipBoard(Effects, Files);
    SetLength(Result, Files.Count);
    for I := 0 to Files.Count - 1 do
      Result[I] := Files[I];
  finally
    F(Files);
  end;
end;

function NowString: string;
begin
  Result := DateTimeToStr(Now);
end;

function SumInt(Int1, Int2: Integer): Integer;
begin
  Result := Int1 + Int2;
end;

function SumStr(Str1, Str2: string): string;
begin
  Result := Str1 + Str2;
end;

procedure ExecAndWait(FileName, Params: String);
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  CmdLine: string;
begin
  { Помещаем имя файла между кавычками, с соблюдением всех пробелов в именах Win9x }
  CmdLine := '"' + Filename + '" ' + Params;
  FillChar(StartInfo, SizeOf(StartInfo), #0);
  with StartInfo do
  begin
    cb := SizeOf(TStartupInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := 4;
  end;
  if CreateProcess(nil, PChar( string( CmdLine ) ), nil, nil, false,
                          CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil,
                          PChar(ExtractFilePath(Filename)), StartInfo,ProcInfo) then
  { Ожидаем завершения приложения }
  begin
    WaitForSingleObject(ProcInfo.hProcess, INFINITE);
    { Free the Handles }
    CloseHandle(ProcInfo.hProcess);
    CloseHandle(ProcInfo.hThread);
  end;
end;

procedure Run(ExeFile, Params : String);
var
  Si : TStartupInfo;
  Dir, CmdLine : string;
  P: TProcessInformation;
begin
  CmdLine := '"' + ExeFile + '" "' + Params + '"';
  Dir := ExtractFilePath(ExeFile);
  FillChar(Si, SizeOf(Si), 0);
  with Si do
  begin
    Cb := SizeOf(Si);
    DwFlags := Startf_UseShowWindow;
    WShowWindow := 4;
  end;
  CreateProcess(nil, PChar(CmdLine), nil, nil, False, CREATE_DEFAULT_ERROR_MODE, nil, PWideChar(Dir), Si, P);
end;

procedure Exec(FileName: string);
begin
  ShellExecute(GetActiveWindow, 'open', PChar(FileName), nil, nil, SW_SHOW)
end;

Procedure aCopyFile(FromFile, ToDir : string);
var
  F : TShFileOpStruct;
begin
  F.Wnd := 0;
  F.WFunc := FO_COPY;
  FromFile := FromFile + #0;
  F.PFrom := Pchar(FromFile);
  ToDir := ToDir + #0;
  F.PTo := Pchar(ToDir);
  F.FFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION;
  ShFileOperation(F);
end;

procedure ARenameFile(S, D: string);
var
  OldMode: Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    RenameFile(PChar(S),PChar(D));
  finally
    SetErrorMode(oldMode);
  end;
end;

function ShowInt(int : integer) : string;
begin
  MessageBoxDB(GetActiveFormHandle, IntToStr(Int), TA('Information'), TD_BUTTON_OK,
    TD_ICON_INFORMATION);
end;

procedure ADeleteFile(S: string);
begin
  FileSetAttr(S, FaHidden);
  DeleteFile(PChar(S));
end;

function AltKeyDown: Boolean;
begin
  Result := (Word(GetKeyState(VK_MENU)) and $8000)<>0;
end;

function CtrlKeyDown: Boolean;
begin
  Result := (Word(GetKeyState(VK_CONTROL)) and $8000) <> 0;
end;

function ShiftKeyDown: Boolean;
begin
  Result := (Word(GetKeyState(VK_SHIFT)) and $8000) <> 0;
end;

procedure ShowString(Str: string);
begin
  MessageBoxDB(GetActiveFormHandle, str, TA('Information') ,TD_BUTTON_OK,TD_ICON_INFORMATION);
end;

function GetSmallIconByPath(IconPath : String; Big : boolean = false) : TIcon;
var
  Path, Icon: string;
  IconIndex, I: Integer;
  Ico1, Ico2: HIcon;
  OldMode: Cardinal;
begin
  I := Pos(',', IconPath);
  Path := Copy(IconPath, 1, I - 1);
  Icon := Copy(IconPath, I + 1, Length(IconPath) - I);
  IconIndex := StrToIntDef(Icon, 0);
  Ico1 := 0;
  Result := TIcon.Create;

  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    ExtractIconEx(Pchar(Path), IconIndex, Ico1, Ico2, 1);
  finally
    SetErrorMode(OldMode);
  end;

  if Big then
  begin
    Result.Handle := Ico1;
    if Ico2 <> 0 then
      DestroyIcon(Ico2);
  end else
  begin
    Result.Handle := Ico2;
    if Ico1 <> 0 then
      DestroyIcon(Ico1);
  end;
end;

function AddIcon(Path: string; ImageList: TImageList; var IconsCount: Integer): integer;
var
  Ico: TIcon;
  I: Integer;
begin
  Result := -1;
  Ico := nil;
  try
    for I := 1 to 20 do
    begin
      try
        Ico := GetSmallIconByPath(Path);
        Break;
      except
        Sleep(10);
      end;
    end;
    if Ico <> nil then
      if not Ico.Empty then
      begin
        ImageList.AddIcon(Ico);
        Inc(IconsCount);
        Result := ImageList.Count - 1;
      end;
  finally
    F(Ico);
  end;
end;

function AddAssociatedIcon(Path: string; ImageList: TImageList; var IconsCount: Integer): Integer;
var
  Ico: TIcon;
  OldMode: Cardinal;

  function ExtractAssociatedIconFixed(FileName: string): HICON;
  var
    I: Word;
    B: array[0 .. 2048] of Char;
  begin
    I := 1;
    Result := ExtractAssociatedIcon(0, StrLCopy(B, PChar(FileName), SizeOf(B) - 1), I);
  end;

begin
  Ico := GetSmallIconByPath(Path, False);
  try
    OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
    try
      Ico.Handle := ExtractAssociatedIconFixed(Path);
    finally
      SetErrorMode(oldMode);
    end;
    if not Ico.Empty then
    begin
      ImageList.AddIcon(ico);
      Inc(IconsCount);
      Result := ImageList.Count - 1;
    end
    else Result := -1;
  finally
    F(Ico);
  end;
end;

function GetUSBDrives : TArrayOfString;
var
  I: Integer;
  OldMode: Cardinal;
begin
  SetLength(Result, 0);
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    for I := Ord('C') to Ord('Z') do
    if (GetDriveType(PChar(Chr(I) + ':\')) = DRIVE_REMOVABLE) then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[Length(Result) - 1] := Chr(I) + ':\';
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

function GetCDROMDrives: TArrayOfString;
var
  I: Integer;
  OldMode: Cardinal;
begin
  SetLength(Result, 0);
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    for I := Ord('C') to Ord('Z') do
    if (GetDriveType(PChar(Chr(I) + ':\')) = DRIVE_CDROM) then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[Length(Result)-1] := Chr(I) + ':\';
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

function GetAllDrives: TArrayOfString;
var
  I: integer;
  OldMode: Cardinal;
begin
  SetLength(Result, 0);
  OldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    for I := ord('C') to ord('Z') do
    if (GetDriveType(PChar(Chr(I)+':\'))=DRIVE_FIXED) or (GetDriveType(PChar(Chr(I)+':\'))=DRIVE_CDROM) or (GetDriveType(PChar(Chr(I)+':\'))=DRIVE_REMOVABLE) then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[Length(Result)-1] := Chr(I) + ':\';
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

function DriveState(DriveLetter: AnsiChar): TSDriveState;
var
  mask: string;
  sRec: TSearchRec;
  oldMode: Cardinal;
  retcode: Integer;
begin
  oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    mask := '?:\*.*';
    mask[1] := Char(driveletter);
  {$I-} { не возбуждаем исключение при неудаче }
    retcode := FindFirst(mask, faAnyfile, SRec);
    FindClose(SRec);
  {$I+}
    case retcode of
      0: Result := DSS_DISK_WITH_FILES; { обнаружен по крайней мере один файл }
      -18: Result := DSS_EMPTY_DISK; { никаких файлов не обнаружено, но ok }
      -21: Result := DSS_NO_DISK; { DOS ERROR_NOT_READY }
    else
      Result := DSS_UNFORMATTED_DISK; { в моей системе значение равно -1785!}
    end;
  finally
    SetErrorMode(oldMode);
  end;
end;

function MrsGetFileType(StrFilename: string): string;
begin
  Result := Dmitry.Utils.Files.MrsGetFileType(StrFilename);
end;

function GetDriveName(Drive: string; DefString: string): string;
var
  DS:  TSDriveState;
  S: string;
  oldMode: Cardinal;
begin
  Result:= string(Drive);
  oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    if Length(Drive)<2 then
      Exit;
    DS := DriveState(AnsiChar(Drive[1]));
    if (DS = DSS_DISK_WITH_FILES) or (DS = DSS_EMPTY_DISK) then
    begin
      S := GetDriveVolumeLabel(AnsiChar(Drive[1]));
      if S <> '' then
        Result := S + ' (' + Drive[1] + ':)'
      else
        Result := DefString + ' (' + Drive[1] + ':)';
    end
    else
      Result := MrsGetFileType(Drive[1] + ':\') + ' (' + Drive[1] + ':)';
  finally
    SetErrorMode(OldMode);
  end;
end;

function GetMyPicturesFolder: string;
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
  try
    Result := Reg.ReadString('Shell Folders', 'My Pictures', '');
  finally
    F(Reg);
  end;
end;

function GetMyDocumentsFolder : string;
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
  try
    Result := Reg.ReadString('Shell Folders', 'Personal', '');
  finally
    F(Reg);
  end;
end;

function FileInPath(aFile, aPath : string) : boolean;
begin
  aPath := AnsiLowerCase(aPath);
  aFile := AnsiLowerCase(aFile);
  Result := Copy(aFile, 1, Length(aPath)) = aPath;
end;

end.
