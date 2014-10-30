unit Dmitry.Utils.Dialogs;

interface

uses
  Windows;

function SelectDirPlus(hWnd: HWND; const Caption: string; const SelRot: String = ''; const Root: WideString = ''): String;
// Диалог выбора директории с кнопкой "Создать папку"

function SelectDir(hWnd: HWND; const Caption: String; const SelRot: String = ''): String;
// Диалог выбора директории

function ChangeIconDialog(hOwner :tHandle; var FileName: string; var IconIndex: Integer): Boolean;
// Диалог выбора иконки

implementation

uses
  SysUtils , ShlObj, ActiveX, Forms, SysConst;
// -----------------------------------------------------------------
threadvar
  MyDir: string;

function BrowseCallbackProc(Hwnd: HWND; UMsg: UINT; LParam: LPARAM; LpData: LPARAM): Integer; stdcall;
begin
  Result := 0;
  if UMsg = BFFM_INITIALIZED then
    SendMessage(Hwnd, BFFM_SETSELECTION, 1, LongInt(PChar(MyDir)));
end;

function SelectDirPlus(HWnd: HWND; const Caption: string; const SelRot: string = ''; const Root: WideString = ''): String;
// Диалог выбора директории с кнопкой "Создать папку"
var
 WindowList: Pointer;
 BrowseInfo : TBrowseInfo;
 Buffer: PChar;
 RootItemIDList, ItemIDList: PItemIDList;
 ShellMalloc: IMalloc;
 IDesktopFolder: IShellFolder;
 Eaten, Flags: LongWord;
 Cmd: Boolean;
begin
 Result:= SelRot;
 FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
 if DirectoryExists(SelRot) then myDir:= SelRot;
 if (ShGetMalloc(ShellMalloc) = S_OK) and (ShellMalloc <> nil) then begin
   Buffer := ShellMalloc.Alloc(MAX_PATH);
   try
     RootItemIDList := nil;
     if Root <> '' then begin
       SHGetDesktopFolder(IDesktopFolder);
       IDesktopFolder.ParseDisplayName(hWnd, nil, POleStr(Root),
                                       Eaten, RootItemIDList, Flags);
     end;
     with BrowseInfo do begin
       hwndOwner:=       hWnd;
       pidlRoot:=        RootItemIDList;
       pszDisplayName:=  Buffer;
       lpfn:=            @BrowseCallbackProc;
       lpszTitle:=       PChar(Caption);
       ulFlags:=         BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE or
                         BIF_EDITBOX or BIF_STATUSTEXT;
     end;
     WindowList:= DisableTaskWindows(0);
     try
       ItemIDList:= ShBrowseForFolder(BrowseInfo);
     finally
       EnableTaskWindows(WindowList);
     end;
     Cmd:= ItemIDList <> nil;
     if Cmd then begin
       ShGetPathFromIDList(ItemIDList, Buffer);
       ShellMalloc.Free(ItemIDList);
       if Length(Buffer) <> 0 then
         Result:= IncludeTrailingPathDelimiter(Buffer)
       else
         Result:= '';
     end;
   finally
     ShellMalloc.Free(Buffer);
   end;
 end;
end;
// -----------------------------------------------------------------
function SelectDir(hWnd: HWND; const Caption: String; const SelRot: String = ''): String;
// Диалог выбора директории
var
 lpItemID:    PItemIDList;
 BrowseInfo:  TBrowseInfo;
 TempPath:    array[0..MAX_PATH] of char;
begin
 Result:= SelRot;
 FillChar(BrowseInfo, sizeof(TBrowseInfo), 0);
 if DirectoryExists(SelRot) then myDir:= SelRot;
 with BrowseInfo do begin
   hwndOwner:= hWnd;
   lpszTitle:= PChar(Caption);
   lpfn:=      @BrowseCallbackProc;
   ulFlags:=   BIF_RETURNONLYFSDIRS;
 end;
 lpItemID:= SHBrowseForFolder(BrowseInfo);
 if lpItemId <> nil then begin
   SHGetPathFromIDList(lpItemID, TempPath);
   Result:= IncludeTrailingPathDelimiter(TempPath);
 end;
 GlobalFreePtr(lpItemID);
end;
// -----------------------------------------------------------------
function ChangeIconDialog(hOwner :tHandle; var FileName: string; var IconIndex: Integer): Boolean;
// Диалог выбора иконки
type
 SHChangeIconProc = function(Wnd: HWND; szFileName: PChar; Reserved: Integer;
   var lpIconIndex: Integer): DWORD; stdcall;
 SHChangeIconProcW = function(Wnd: HWND; szFileName: PWideChar;
   Reserved: Integer; var lpIconIndex: Integer): DWORD; stdcall;
const
 Shell32 = 'shell32.dll';
var
 ShellHandle: THandle;
 SHChangeIcon: SHChangeIconProc;
 SHChangeIconW: SHChangeIconProcW;
 Buf:  array [0..MAX_PATH] of Char;
 BufW: array [0..MAX_PATH] of WideChar;
begin
 Result:= False;
 SHChangeIcon:= nil;
 SHChangeIconW:= nil;

 ShellHandle:= Windows.LoadLibrary(PChar(Shell32));
 try
   if ShellHandle <> 0 then begin
     if Win32Platform = VER_PLATFORM_WIN32_NT then
       SHChangeIconW:= GetProcAddress(ShellHandle, PChar(62))
     else
       SHChangeIcon:=  GetProcAddress(ShellHandle, PChar(62));
   end;

   if Assigned(SHChangeIconW) then begin
     StringToWideChar(FileName, BufW, SizeOf(BufW));
     Result:= SHChangeIconW(hOwner, BufW, SizeOf(BufW), IconIndex) = 1;
     if Result then
       FileName:= BufW;
   end
   else if Assigned(SHChangeIcon) then begin
     StrPCopy(Buf, FileName);
     Result:= SHChangeIcon(hOwner, Buf, SizeOf(Buf), IconIndex) = 1;
     if Result then FileName:= Buf;
   end
   else
     raise Exception.Create(SUnkOSError);
 finally
   if ShellHandle <> 0 then FreeLibrary(ShellHandle);
 end;
end;
// -----------------------------------------------------------------
end.
