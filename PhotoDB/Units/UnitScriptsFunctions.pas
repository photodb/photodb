unit UnitScriptsFunctions;

interface

uses Windows, SysUtils, uScript, UnitScripts, Classes, ShlObj, ShellAPI, Dialogs,
     Graphics, Controls, Registry, ExtDlgs, acDlgSelect, Dolphin_DB,
     UnitDBFileDialogs, Forms, Language, uVistaFuncs, uLogger,
     uFileUtils, uTime;

function GetOpenFileName(InitFile, Filter : string) : string;
function GetSaveFileName(InitFile, Filter : string) : string;
procedure CreateFile(FileName : string);
procedure WriteToFile(FileName, aString : string);
procedure WriteLnToFile(FileName, aString : string);
function aExtractFileName(FileName : string) : string;
function aPos(sub, str : string) : integer;
function aStrCopy(s : string; aBegin, aLength : integer) : string;
function aStrToInt(s : string) : integer;
function GetDirListing(Dir : String; Mask : string) : TArrayOfString;
function SpilitWords(S : string) : TArrayOfString;
function SpilitWordsW(S : string; SplitChar : char) : TArrayOfString;
function aIntToStr(int : integer) : string;
procedure Default(var aScript : TScript);
procedure InVisible(var aScript : TScript);
procedure Disabled(var aScript : TScript);
procedure Checked(var aScript : TScript);
function aDirectoryExists(FileName : string) : boolean;
function aDirectoryFileExists(FileName : string) : boolean;
function aPathFormat(aPath, aFile : string) : string;
//procedure Copy_Move(FCM:Boolean;File_List : TStrings);
procedure CopyFile(aFile : string);
procedure CutFile(aFile : string);
procedure CopyFiles(Files : TArrayOfString);
procedure CutFiles(Files : TArrayOfString);
function LoadFIlesFromClipBoard : TArrayOfString;
function NowString : String;
function SumInt(int1, int2 : integer) : integer;
function SumStr(str1, str2 : string) : string;
procedure UnFormatDir(var s:string);
procedure FormatDir(var s:string);
function GetDirectory(FileName:string):string;
procedure ExecAndWait(FileName, Params: String);
procedure Run(ExeFile, Params : String);
procedure Exec(FileName : string);
Procedure aCopyFile(FromFile, ToDir : string);
procedure aRenameFile(S,D : String);
function ShowInt(int : integer) : string;
procedure aDeleteFile(S : String);
function AltKeyDown : boolean;
function CtrlKeyDown : boolean;
function ShiftKeyDown : boolean;
procedure ShowString(str : string);
function GetSmallIconByPath(IconPath : String; Big : boolean = false) : TIcon;
function AddIcon(Path : string; ImageList : TImageList; var IconsCount : integer) : integer;
function AddAssociatedIcon(Path : string; ImageList : TImageList; var IconsCount : integer) : integer;
function GetUSBDrives : TArrayOfString;
function GetCDROMDrives : TArrayOfString;
function GetAllDrives : TArrayOfString;
function DriveState(driveletter: AnsiChar): TSDriveState;
Function GetCDVolumeLabel(CDName : AnsiChar) : String;
function GetDriveName(Drive : AnsiString; DefString : string) : string;
function GetMyPicturesFolder : string;
function GetMyDocumentsFolder : string;
function GetProgramFolder : string;
//function AnsiDequotedStr(Value : string) : string;
function AnsiQuotedStr(const S: string): string;
function GetSaveImageFileName(InitFile, Filter : string) : string;
function GetOpenImageFileName(InitFile, Filter : string) : string;
procedure CopyFileSynch(S,D : string);
function FileInPath(aFile, aPath : string) : boolean;
function GetOpenDirectory(Caption, Root : string) : string;
function FileHasExt(aFile, aExt : string) : boolean;

implementation

function FileHasExt(aFile, aExt : string) : boolean;
begin
  AFile := Dolphin_DB.GetExt(AFile);
  Result := Dolphin_DB.ExtinMask(AExt, AFile);
end;

function GetProgramFolder : string;
begin
 Result:=GetDirectory(Application.ExeName);
end;

function AnsiQuotedStr(const S: string): string;
var
  P, Src, Dest: PChar;
  AddCount: Integer;
const
  Quote = '"';
begin
  AddCount := 0;
  P := AnsiStrScan(PChar(S), Quote);
  while P <> nil do
  begin
    Inc(P);
    Inc(AddCount);
    P := AnsiStrScan(P, Quote);
  end;
  if AddCount = 0 then
  begin
    Result := S;
    Exit;
  end;
  SetLength(Result, Length(S) + AddCount);
  Dest := Pointer(Result);
  Src := Pointer(S);
  P := AnsiStrScan(Src, Quote);
  repeat
    Inc(P);
    Move(Src^, Dest^, P - Src);
    Inc(Dest, P - Src);
    Dest^ := Quote;
    Inc(Dest);
    Src := P;
    P := AnsiStrScan(Src, Quote);
  until P = nil;
  P := StrEnd(Src);
  Move(Src^, Dest^, P - Src);
  Inc(Dest, P - Src);
  Dest^ := Quote;
end;

function GetOpenFileName(InitFile, Filter : string) : string;
var
  FD : DBOpenDialog;
begin
 Result:='';
 FD:=DBOpenDialog.Create();
 FD.SetFileName(InitFile);
 FD.Filter:=Filter;
 if FD.Execute then
 Result:=FD.FileName;
 FD.Free;
end;

function GetOpenDirectory(Caption, Root : string) : string;
begin
 if DirectoryExists(Root) then
 begin
  Result:=UnitDBFileDialogs.DBSelectDir(Application.Handle,Caption,Root,Dolphin_DB.UseSimpleSelectFolderDialog);
 end else
 begin
  Result:=UnitDBFileDialogs.DBSelectDir(Application.Handle,Caption,Dolphin_DB.UseSimpleSelectFolderDialog);
 end;
end;

function GetSaveFileName(InitFile, Filter : string) : string;
var
  FD : DBSaveDialog;
begin
 Result:='';
 FD:=DBSaveDialog.Create();
 FD.SetFileName(InitFile);
 FD.Filter:=Filter;
 if FD.Execute then
 Result:=FD.FileName;
 FD.Free;
end;

function GetOpenImageFileName(InitFile, Filter : string) : string;
var
  FD : DBOpenPictureDialog;
begin
 Result:='';
 FD:=DBOpenPictureDialog.Create();
// FD.FileName:=InitFile;
 FD.Filter:=Filter;
 if FD.Execute then
 Result:=FD.FileName;
 FD.Free;
end;

function GetSaveImageFileName(InitFile, Filter : string) : string;
var
  FD : DBSavePictureDialog;
begin
 Result:='';
 FD:=DBSavePictureDialog.Create();
// FD.FileName:=InitFile;
 FD.Filter:=Filter;
 if FD.Execute then
 Result:=FD.FileName;
 FD.Free;
end;

procedure CreateFile(FileName : string);
var
  FS : TFileStream;
begin
 try
  FS := TFileStream.Create(FileName,fmCreate);
  FS.Free;
 except
  on e : Exception do EventLog(':CreateFile() throw exception: '+e.Message);
 end;
end;

procedure WriteToFile(FileName, aString : string);
var
  FS : TFileStream;
begin
 try
 FS := TFileStream.Create(FileName,fmOpenWrite);
 FS.Seek(0,soEnd);
 except
  on e : Exception do
  begin
   EventLog(':WriteToFile() throw exception: '+e.Message);
   exit;
  end;
 end;
 FS.Write(aString[1],Length(aString));
 FS.Free;
end;

procedure WriteLnToFile(FileName, aString : string);
var
  FS : TFileStream;
  eof : array[0..1] of byte;
begin
 try
  FS := TFileStream.Create(FileName,fmOpenWrite);
  FS.Seek(0,soEnd);
  eof[0]:=13;
  eof[1]:=10;
  FS.Write(aString[1],Length(aString));
  FS.Write(eof[0],2);
 except
  on e : Exception do
  begin
   EventLog(':WriteLnToFile() throw exception: '+e.Message);
   exit;
  end;
 end;
 FS.Free;
end;

function aExtractFileName(FileName : string) : string;
begin
 Result:=ExtractFileName(FileName);
end;

function aPos(sub, str : string) : integer;
begin
 Result:=Pos(sub,str);
end;

function aStrCopy(s : string; aBegin, aLength : integer) : string;
begin
 Result:=Copy(s,aBegin,aLength);
end;

function aStrToInt(s : string) : integer;
begin
 Result:=StrToIntDef(s,0);
end;

function GetDirListing(Dir : String; Mask : string) : TArrayOfString;
var
  Found  : integer;
  SearchRec : TSearchRec;
  oldMode: Cardinal;

  function ExtInMask(mask : string; ext : string) : boolean;
  begin
   Result:=Pos('|'+ext+'|',mask)<>-1;
  end;

  function GetExt(FileName : string) : string;
  var
    s : string;
  begin
   s:=ExtractFileExt(FileName);
   Result:=AnsiUpperCase(Copy(s,1,Length(s)-1));
  end;

begin
  TW.I.Start('GetDirListing');
  oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
  SetLength(Result,0);
  if dir = '' then exit;
  If dir[length(dir)]<>'\' then dir:=dir+'\';
  Found := FindFirst(dir+'*.*', faAnyFile, SearchRec);
  while Found = 0 do
  begin
   if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
   if ExtInMask(GetExt(SearchRec.Name),Mask) then
   begin
    SetLength(Result,length(Result)+1);
    Result[length(Result)-1]:=dir+SearchRec.Name;
   end;
   Found := sysutils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
  SetErrorMode(oldMode);
  TW.I.Start('GetDirListing - END');
end;

function SpilitWords(S : string) : TArrayOfString;
begin
 Result:=SpilitWordsW(S,' ');
end;

function SpilitWordsW(S : string; SplitChar : char) : TArrayOfString;
var
  I, J: Integer;
  Pi_: PInteger;
  LS: Integer;
begin
  LS := Length(S);
  SetLength(Result, 0);
  S := SplitChar + S + SplitChar;
  Pi_ := @I;
  for I := 1 to LS - 1 do
  begin
    // if i+1>LS-1 then break;
    if (S[I] = SplitChar) and (S[I + 1] <> SplitChar) then
      for J := I + 1 to LS do
        if (S[J] = SplitChar) or (J = LS) then
        begin
          SetLength(Result, Length(Result) + 1);
          Result[Length(Result) - 1] := Copy(S, I + 1, J - I - 1);
          Pi_^ := J - 1;
          Break;
        end;
  end;
  for I := 0 to Length(Result) - 1 do
    Result[I] := Trim(Result[I]);

end;

function aIntToStr(int : integer) : string;
begin
  Result:=IntToStr(int);
end;

procedure Default(var aScript : TScript);
begin
 SetNamedValue(aScript,'$Default','true');
end;

procedure InVisible(var aScript : TScript);
begin
 SetNamedValue(aScript,'$Visible','false');
end;

procedure Disabled(var aScript : TScript);
begin
 SetNamedValue(aScript,'$Enabled','false');
end;

procedure Checked(var aScript : TScript);
begin
 SetNamedValue(aScript,'$Checked','true');
end;

function aDirectoryExists(FileName : string) : boolean;
var
  oldMode: Cardinal;
begin
  oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
  Result:=DirectoryExists(FileName);
  SetErrorMode(oldMode);
end;

function aDirectoryFileExists(FileName : string) : boolean;
var
  oldMode: Cardinal;
begin
  oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
  Result:=DirectoryExists(ExtractFileDir(FileName));
  SetErrorMode(oldMode);
end;

function aPathFormat(aPath, aFile : string) : string;
begin
 Result:=StringReplace(aPath,'%1',aFile,[rfReplaceAll,rfIgnoreCase]);
end;

{procedure Copy_Move(FCM:Boolean;File_List : TStrings);
var hGlobal,shGlobal:THandle;
   DropFiles:PDropFiles;
   REff:Cardinal;
   dwEffect:^Word;
   rSize,i:Integer;
   c:PChar;
begin
i:=File_List.Count;
if (i=0)or(OpenClipboard(0)=false) then exit;
try
 EmptyClipboard();
 rSize:=sizeof(TDropFiles);
 repeat
  dec(i);
  rSize:=rSize+Length(trim(File_List.Strings[i]))+1;
 until (i=0);
 inc(rSize);
 hGlobal:=GlobalAlloc(GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT,rSize);
 if hGlobal<>0 then
  begin
   DropFiles:=GlobalLock(hGlobal);
   DropFiles.pFiles:=sizeof(TDropFiles);
//    DropFiles.pt:=;
   DropFiles.fNC:=false;
   DropFiles.fWide:=False;
   i:=File_List.Count;
   c:=PChar(DropFiles);
   c:=c+DropFiles.pFiles;
   repeat
    dec(i);
    StrCopy(c,PChar(trim(File_List.Strings[i])));
    c:=c+Length(trim(File_List.Strings[i]))+1;
   until (i=0);
   GlobalUnlock(hGlobal);
   shGlobal:=SetClipboardData(CF_HDROP,hGlobal);
   if (shGlobal<>0) then
    begin
     hGlobal:=GlobalAlloc(GMEM_MOVEABLE,sizeof(dwEffect));
     if hGlobal<>0 then
      begin
       dwEffect:=GlobalLock(hGlobal);
       If FCM then dwEffect^:=DROPEFFECT_COPY else
       dwEffect^:=DROPEFFECT_MOVE;
       GlobalUnlock(hGlobal);
       REff:=RegisterClipboardFormat(PChar('Preferred DropEffect'));//'CFSTR_PREFERREDDROPEFFECT'));
       SetClipboardData(REff,hGlobal)
      end;
    end;
  end;
finally
 CloseClipboard();
end;
end;
       }
procedure CopyFileSynch(S,D : string);
begin
 try
  Windows.CopyFileW(PChar(S),PChar(D),true);
 except
 end;
end;

procedure CopyFile(aFile : string);
var
  AFiles: TStrings;
begin
  AFiles := TStringList.Create;
  try
    AFiles.Add(AFile);
    Copy_Move(True, AFiles);
  finally
    AFiles.Free;
  end;
end;

procedure CutFile(aFile : string);
var
  AFiles: TStrings;
begin
  AFiles := TStringList.Create;
  try
    AFiles.Add(AFile);
    Copy_Move(False, AFiles);
  finally
    AFiles.Free;
  end;
end;

procedure CopyFiles(Files : TArrayOfString);
var
  I: Integer;
  AFiles: TStrings;
begin
  AFiles := TStringList.Create;
  try
    for I := 0 to Length(Files) - 1 do
    begin
      AFiles.Add(Files[I])
    end;
    Copy_Move(True, AFiles);
  finally
    AFiles.Free;
  end;
end;

procedure CutFiles(Files : TArrayOfString);
var
  i : integer;
  aFiles : TStrings;
begin
 aFiles:=TStringList.Create;
 for i:=0 to Length(Files)-1 do
 begin
  aFiles.Add(Files[i])
 end;
 Copy_Move(false,aFiles);
 aFiles.Free;
end;

function LoadFIlesFromClipBoard : TArrayOfString;
var
  Hand : THandle;
  Count, Effects : integer;
  pfname : array[0..10023] of char;
  CD : Cardinal;
  s : string;
  dwEffect : ^Word;
begin
Effects:=0;
SetLength(Result,0);
if IsClipboardFormatAvailable(CF_HDROP) then
 begin
  if OpenClipboard(0)=false then exit;
  CD:=0;
  repeat
   CD:=EnumClipboardFormats(CD);
   if (CD<>0)and(GetClipboardFormatName(CD,pfname,1024)<>0) then
    begin
     s:=UpperCase(string(pfname));
     if Pos('DROPEFFECT',s)<>0 then
      begin
       Hand:=GetClipboardData(CD);
       if (Hand<>0) then
        begin
         dwEffect:=GlobalLock(Hand);
         Effects:=dwEffect^;
         GlobalUnlock(Hand);
        end;
       CD:=0;
      end;
    end;
  until (CD=0);
  Hand:=GetClipboardData(CF_HDROP);
  if (Hand<>0) then
   begin
    Count:=DragQueryFile(Hand,$FFFFFFFF,nil,0);
    if Count>0 then
     repeat
      dec(Count);
      DragQueryFile(Hand,Count,pfname,1024);
      SetLength(Result,length(Result)+1);
      Result[length(Result)-1]:=pfname;
     until (Count=0);
   end;
  CloseClipboard();
 end;
end;

function NowString : String;
begin
 Result:=DateTimeToStr(Now);
end;

function SumInt(int1, int2 : integer) : integer;
begin
 Result:=int1+int2;
end;

function SumStr(str1, str2 : string) : string;
begin
 Result:=str1+str2;
end;

procedure UnFormatDir(var s:string);
begin
 if s='' then exit;
 if s[length(s)]='\' then Delete(s,length(s),1);
end;

procedure FormatDir(var s:string);
begin
 if s='' then exit;
 if s[length(s)]<>'\' then s:=s+'\';
end;

function GetDirectory(FileName:string):string;
var
  i, n: integer;
begin
 n:=0;
 for i:=Length(FileName) downto 1 do
 If FileName[i]='\' then
 begin
  n:=i;
  Break;
 end;
 Delete(filename,n,length(filename)-n+1);
 Result:=FileName;
 FormatDir(Result);
end;

procedure ExecAndWait(FileName, Params: String);
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  CmdLine: ShortString;
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
  if CreateProcess(nil, PChar( String( CmdLine ) ), nil, nil, false,
                          CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil,
                          PChar(ExtractFilePath(Filename)),StartInfo,ProcInfo) then
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
  p : TProcessInformation;
begin
  CmdLine := '"' + ExeFile + '" ' + Params;
  Dir:=GetDirectory(ExeFile);
  UnformatDir(Dir);
  FillChar( Si, SizeOf( Si ) , 0 );
  with Si do begin
    cb := SizeOf( Si);
    dwFlags := startf_UseShowWindow;
    wShowWindow := 4;
  end;
  CreateProcess(nil, PWideChar(CmdLine), nil, nil, False, CREATE_DEFAULT_ERROR_MODE, nil, PWideChar(Dir), si, p);
end;

procedure Exec(FileName : string);
begin
 ShellExecute(0, 'open', PWideChar(FileName), nil, nil, SW_SHOW)
end;

Procedure aCopyFile(FromFile, ToDir : string);
var
  F : TShFileOpStruct;
begin
 try
  F.Wnd := 0; F.wFunc := FO_COPY;
  FromFile:=FromFile+#0; F.pFrom:=pchar(FromFile);
  ToDir:=ToDir+#0; F.pTo:=pchar(ToDir);
  F.fFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION;
  ShFileOperation(F);
 except
 end;
end;

procedure aRenameFile(S,D : String);
var
  oldMode: Cardinal;
begin
  oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
  RenameFile(PChar(S),PChar(D));
  SetErrorMode(oldMode);
end;

function ShowInt(int : integer) : string;
begin
 MessageBoxDB(Dolphin_DB.GetActiveFormHandle,IntToStr(int),Language.TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_INFORMATION);
end;

procedure aDeleteFile(S : String);
begin
 FileSetAttr(S,faHidden);
 DeleteFile(PChar(S));
end;

function AltKeyDown : boolean;
begin
 Result:=(Word(GetKeyState(VK_MENU)) and $8000)<>0;
end;

function CtrlKeyDown : boolean;
begin
 Result:=(Word(GetKeyState(VK_CONTROL)) and $8000)<>0;
end;

function ShiftKeyDown : boolean;
begin
 Result:=(Word(GetKeyState(VK_SHIFT)) and $8000)<>0;
end;

procedure ShowString(str : string);
begin
 MessageBoxDB(Dolphin_DB.GetActiveFormHandle,str,Language.TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_INFORMATION);
end;

function GetSmallIconByPath(IconPath : String; Big : boolean = false) : TIcon;
var
  Path, Icon : String;
  IconIndex, i : Integer;
  ico1,ico2 : HIcon;
  oldMode: Cardinal;
begin
 i:=Pos(',',IconPath);
 Path:=Copy(IconPath,1,i-1);
 Icon:=Copy(IconPath,i+1,Length(IconPath)-i);
 IconIndex:=StrToIntDef(Icon,0);
 ico1:=0;
 Result := TIcon.create;
 try
  oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
  ExtractIconEx(Pchar(Path),IconIndex,ico1,ico2,1);
  SetErrorMode(oldMode);
 except
 end;
 if Big then
 begin
  Result.Handle:=ico1;
  if ico2<>0 then
  DestroyIcon(ico2);
 end else
 begin
  Result.Handle:=ico2;
  if ico1<>0 then
  DestroyIcon(ico1);
 end;
end;

function AddIcon(Path : string; ImageList : TImageList; var IconsCount : integer) : integer;
var
  ico : TIcon;
  i : integer;
begin
 Result:=-1;
 ico:=nil;
 for i:=1 to 20 do
 begin
  try
   ico:=GetSmallIconByPath(Path);
   break;
  except
   Sleep(10);
  end;
 end;
 if ico<>nil then
 if not ico.Empty then
 begin
  ImageList.AddIcon(ico);
  inc(IconsCount);
  ico.Free;
  Result:=ImageList.Count-1;
 end;
end;

function AddAssociatedIcon(Path : string; ImageList : TImageList; var IconsCount : integer) : integer;
var
  ico : TIcon;
  oldMode: Cardinal;

 function ExtractAssociatedIcon_(FileName :String) :HICON;
 var
   i : Word;
   b : array[0..2048] of char;
 begin
  i := 1;
  Result := ExtractAssociatedIcon(0, StrLCopy(b,PChar(FileName),SizeOf(b)-1),i);
 end;

begin
 ico := GetSmallIconByPath(Path,false);
 oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
 ico.Handle:=ExtractAssociatedIcon_(Path);
 SetErrorMode(oldMode);
 if not Ico.Empty then
 begin
  ImageList.AddIcon(ico);
  inc(IconsCount);
  Result:=ImageList.Count-1;
 end else Result:=-1;
 ico.Free;
end;

function GetUSBDrives : TArrayOfString;
var
  i : integer;
  oldMode: Cardinal;
begin
 SetLength(Result,0);
 oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
 for i:=ord('C') to ord('Z') do
 If (GetDriveType(PChar(Chr(i)+':\'))=DRIVE_REMOVABLE) then
 begin
  SetLength(Result,Length(Result)+1);
  Result[Length(Result)-1]:=Chr(i)+':\';
 end;
 SetErrorMode(oldMode);
end;

function GetCDROMDrives : TArrayOfString;
var
  i : integer;
  oldMode: Cardinal;
begin
 SetLength(Result,0);
 oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
 for i:=ord('C') to ord('Z') do
 If (GetDriveType(PChar(Chr(i)+':\'))=DRIVE_CDROM) then
 begin
  SetLength(Result,Length(Result)+1);
  Result[Length(Result)-1]:=Chr(i)+':\';
 end;
 SetErrorMode(oldMode);
end;

function GetAllDrives : TArrayOfString;
var
  i : integer;
  oldMode: Cardinal;
begin
 SetLength(Result,0);
 oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
 for i:=ord('C') to ord('Z') do
 If (GetDriveType(PChar(Chr(i)+':\'))=DRIVE_FIXED) or (GetDriveType(PChar(Chr(i)+':\'))=DRIVE_CDROM) or (GetDriveType(PChar(Chr(i)+':\'))=DRIVE_REMOVABLE) then
 begin
  SetLength(Result,Length(Result)+1);
  Result[Length(Result)-1]:=Chr(i)+':\';
 end;
 SetErrorMode(oldMode);
end;

function DriveState(driveletter: AnsiChar): TSDriveState;
var
  mask: string[6];
  sRec: TSearchRec;
  oldMode: Cardinal;
  retcode: Integer;
begin
  oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
  mask := '?:\*.*';
  mask[1] := driveletter;
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
  SetErrorMode(oldMode);
end;

Function GetCDVolumeLabel(CDName : AnsiChar) : String;
var
  VolumeName,
  FileSystemName : array [0..MAX_PATH-1] of Char;
  VolumeSerialNo : DWord;
  MaxComponentLength,FileSystemFlags: Cardinal;
  oldMode: Cardinal;
begin
  GetVolumeInformation(Pchar(CDName+':\'),VolumeName,MAX_PATH,@VolumeSerialNo,
  MaxComponentLength,FileSystemFlags, FileSystemName,MAX_PATH);
  oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
  SetErrorMode(oldMode);
  Result:=VolumeName;
end;

function MrsGetFileType(strFilename: string): string;
var
  FileInfo: TSHFileInfo;
  oldMode: Cardinal;
begin
  FillChar(FileInfo, SizeOf(FileInfo), #0);
  oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
  SHGetFileInfo(PChar(strFilename), 0, FileInfo, SizeOf(FileInfo), SHGFI_TYPENAME);
  Result := FileInfo.szTypeName;
  SetErrorMode(oldMode);
end;

function GetDriveName(Drive : AnsiString; DefString : string) : string;
var
  DS :  TSDriveState;
  S : string;
  oldMode: Cardinal;
begin
 Result:=Drive;
  oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
 if Length(Drive)<2 then exit;
 DS:=DriveState(Drive[1]);
 If (DS=DSS_DISK_WITH_FILES) or (DS=DSS_EMPTY_DISK) then
 begin
  S:=GetCDVolumeLabel(Drive[1]);
  if S<>'' then
  Result:=S+' ('+Drive[1]+':)' else
  Result:=DefString+' ('+Drive[1]+':)';
 end else
 Result:=MrsGetFileType(Drive[1]+':\')+' ('+Drive[1]+':)';
  SetErrorMode(oldMode);
end;

function GetMyPicturesFolder : string;
var
  Reg: TRegIniFile;
begin
 Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
 Result:=Reg.ReadString('Shell Folders', 'My Pictures', '');
 Reg.Free;
end;

function GetMyDocumentsFolder : string;
var
  Reg: TRegIniFile;
begin
 Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
 Result:=Reg.ReadString('Shell Folders', 'Personal', '');
 Reg.Free;
end;

function FileInPath(aFile, aPath : string) : boolean;
begin
 aPath:=AnsiLowerCase(aPath);
 aFile:=AnsiLowerCase(aFile);
 Result:=Copy(aFile,1,Length(aPath))=aPath;
end;

end.
