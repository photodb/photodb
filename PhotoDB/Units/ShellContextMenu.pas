unit ShellContextMenu;

interface

uses StdCtrls, ComCtrls, ShlObj, ActiveX, ShellCtrls, WIndows, SysUtils, Messages,
     Controls, Math, Language, Forms;
     
procedure GetProperties(fNames : array of string; MP : TPoint; WC : TWinControl);
procedure GetPropertiesWindows(fNames : array of string; WC : TWinControl);

implementation

uses Searching;

procedure ICMError(Error : String);
begin
// Searching.SearchManager.GetAnySearch.Caption:=Error;
// Application.MessageBox(pchar(Error),TEXT_MES_ERROR,MB_OK+MB_ICONERROR);
end;

procedure FormatDir(var s:string);
begin
 if s='' then exit;
 if s[length(s)]<>'\' then s:=s+'\';
end;

Function GetCommonDir(dir1 {Common  dir}, dir2 {Compare dir} : String) : String;
var
  i, c : integer;
begin
 if Dir1=dir2 then
 begin
  Result:=Dir1;
 end else
 begin
  if dir1=Copy(dir2,1,Length(dir1)) then
  begin
   Result:=dir1;
   exit;
  end;
  c:=Min(Length(dir1),Length(dir2));
  for i:=1 to c do
  if dir1[i]<>dir2[i] then
  begin
   c:=i;
   break;
  end;
  Result:=ExtractFilePath(Copy(dir1,1,c-1));
 end;
end;

function GetCommonDirectory(Files : array of string) : String;
var
  i : integer;
  s, temp, d : string;
begin
 Result:='';
 if Length(Files)=0 then exit;
 for i:=0 to Length(Files)-1 do
 begin
  Files[i]:=ExtractFilePath(Files[i])
 end;
 s:=AnsiLowerCase(Copy(Files[0],1,2));
 temp:=AnsiLowerCase(Files[0]);
 for i:=0 to Length(Files)-1 do
 begin
  Files[i]:=AnsiLowerCase(Files[i]);
  If length(Files[i])<2 then exit;
  if s<>Copy(Files[i],1,2) then exit;
  d:=ExtractFilePath(Files[i]);
  if Length(Temp)>Length(d) then
  temp:=d;
 end;
 for i:=0 to Length(Files)-1 do
 begin
  temp:=GetCommonDir(temp,Files[i]);
 end;
 Result:=temp;
end;

function SetErrorShell(Cmd:Byte):Byte;
var ErrOld,Shell32,OP,i:Cardinal;
   SMB_W:Pointer;
   R:Byte;
begin
R:=0;
if Cmd=0 then Cmd:=$C3;
ErrOld:=SetErrorMode(SEM_NOOPENFILEERRORBOX);
Shell32:=LoadLibrary('shell32.dll');
if Shell32<>0 then
 begin
  SMB_W:=GetProcAddress(Shell32,'ShellMessageBoxW');
  if SMB_W<>nil then
   begin
    OP:=OpenProcess(PROCESS_VM_READ or PROCESS_VM_WRITE or PROCESS_VM_OPERATION,false,GetCurrentProcessID);
    if OP<>0 then
     begin
      if not(ReadProcessMemory(OP,SMB_W,@R,SizeOf(R),i)and(i=SizeOf(R))and
             WriteProcessMemory(OP,SMB_W,@Cmd,SizeOf(Cmd),i)and(i=SizeOf(Cmd))) then R:=0;
      CloseHandle(OP);
     end;
   end;
  FreeLibrary(Shell32);
 end;
SetErrorMode(ErrOld);
Result:=R;
end;

function MenuCallback(Wnd: HWND; Msg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT; stdcall;
var
  ContextMenu2: IContextMenu2;
begin
  case Msg of
    WM_CREATE:
      begin
        ContextMenu2 := IContextMenu2(PCreateStruct(lParam).lpCreateParams);
        SetWindowLong(Wnd, GWL_USERDATA, Longint(ContextMenu2));
        Result := DefWindowProc(Wnd, Msg, wParam, lParam);
      end;
    WM_INITMENUPOPUP:
      begin
        ContextMenu2 := IContextMenu2(GetWindowLong(Wnd, GWL_USERDATA));
        ContextMenu2.HandleMenuMsg(Msg, wParam, lParam);
        Result := 0;
      end;
    WM_DRAWITEM, WM_MEASUREITEM:
      begin
        ContextMenu2 := IContextMenu2(GetWindowLong(Wnd, GWL_USERDATA));
        ContextMenu2.HandleMenuMsg(Msg, wParam, lParam);
        Result := 1;
      end;
  else
    Result := DefWindowProc(Wnd, Msg, wParam, lParam);
  end;
end;

function CreateMenuCallbackWnd(const ContextMenu: IContextMenu2): HWND;
const
  IcmCallbackWnd = 'ICMCALLBACKWND';
var
  WndClass: TWndClass;
begin
  FillChar(WndClass, SizeOf(WndClass), #0);
  WndClass.lpszClassName := PChar(IcmCallbackWnd);
  WndClass.lpfnWndProc := @MenuCallback;
  WndClass.hInstance := HInstance;
  Windows.RegisterClass(WndClass);
  Result := CreateWindow(IcmCallbackWnd, IcmCallbackWnd, WS_POPUPWINDOW, 0,
    0, 0, 0, 0, 0, HInstance, Pointer(ContextMenu));
end;

procedure GetProperties(fNames : array of string; MP : TPoint; WC : TWinControl);
var
   dISF,ISF:IShellFolder;
   ICMenu:IContextMenu;
   ICMenu2: IContextMenu2;
   CMD:TCMInvokeCommandInfo;
   PathPIDL:PItemIDList;
   FilePIDLs : array of PItemIDList;
   cIE,HR:HResult;
   M:IMAlloc;
   pMenu:HMenu;
   fPath:PWideChar;
   sFP,sFN:string;
   Attr,L:Cardinal;
   fPM:LongBool;
   ICmd:integer;
   ZVerb: array[0..1023] of char;
   Verb: string;
   Handled:Boolean;
   SCV:IShellCommandVerb;
   i, len : integer;
   CallbackWindow: HWND;
   R_H:Byte;
begin
 pMenu:=0;
 Attr:=0;
 CallbackWindow:=0;
 PathPIDL:=nil;
 cIE:=CoInitializeEx(nil,COINIT_MULTITHREADED);
 try
  sFP:=GetCommonDirectory(fNames);
  len:=length(sFP);
  sFN:=fNames[0];
  Delete(sFN,1,length(sFP));
  if SHGetDesktopFolder(dISF)<>S_OK then exit;
  ICMError('x.1');
  begin
   fPath:=StringToOleStr(sFP);
   L:=Length(sFP);
   SetLength(FilePIDLs,Length(fNames)+1);
   FillChar(FilePIDLs[Length(fNames)],Sizeof(PItemIDList),#0);
   for i:=0 to Length(fNames)-1 do
   FilePIDLs[i]:=nil;
   if (dISF.ParseDisplayName(WC.Handle,nil,fPath,L,PathPIDL,Attr)<>S_OK)or
   (dISF.BindToObject(PathPIDL,nil,IID_IShellFolder,Pointer(ISF))<>S_OK) then exit;
   for i:=0 to Length(fNames)-1 do
   begin
    delete(fNames[i],1,len);
    fPath:=StringToOleStr(fNames[i]);
    L:=Length(fNames[i]);
    ISF.ParseDisplayName(WC.Handle,nil,fPath,L,FilePIDLs[i],Attr);
   end;
   ICMError('x.2');
   HR:=ISF.GetUIObjectOf(WC.Handle,Length(fNames),FilePIDLs[0],IID_IContextMenu,nil,Pointer(ICMenu));
   ICMError('x.3');
  end;
  if Succeeded(HR) then
  begin
   ICMenu2:=nil;
   Windows.ClientToScreen(WC.Handle,MP);
   pMenu:=CreatePopupMenu;
   ICMError('x.3.1');
   if Succeeded(ICMenu.QueryContextMenu(pMenu, 0, 1, $7FFF, {CMF_EXPLORE}CMF_NORMAL)) then
   CallbackWindow := 0;
   ICMError('x.4');
   if Succeeded(ICMenu.QueryInterface(IContextMenu2, ICMenu2)) then
   begin
    CallbackWindow := CreateMenuCallbackWnd(ICMenu2);
    ICMError('x.5');
   end else ICMError('4');
   try
    ICMError('x.6');
    fPM:=TrackPopupMenu(pMenu,TPM_LEFTALIGN or TPM_LEFTBUTTON or TPM_RIGHTBUTTON or TPM_RETURNCMD,MP.X,MP.Y,0,CallbackWindow,nil);
   finally
    ICMenu2:=nil;
   end;
   if fPM then
   begin
    ICmd:=LongInt(fPM)-1;
    HR:=ICMenu.GetCommandString(ICmd,GCS_VERBA,nil,ZVerb,SizeOf(ZVerb));
    Verb:=StrPas(ZVerb);
    Handled:=False;
    if Supports(WC,IShellCommandVerb,SCV) then
    begin
     HR:=0;
     SCV.ExecuteCommand(Verb, Handled);
    end;
    if not(Handled) then
    begin
     FillChar(CMD,SizeOf(CMD),#0);
     with CMD do
     begin
      cbSize:=SizeOf(CMD);
      hWND:=WC.Handle;
      lpVerb:=MakeIntResource(ICmd);
      nShow:=SW_SHOWNORMAL;
     end;
     R_H:=SetErrorShell(0); //Ставим
     HR:=ICMenu.InvokeCommand(CMD);
     if R_H<>0 then SetErrorShell(R_H); //Востанавливаем
    end;
    if Assigned(SCV) then
    SCV.CommandCompleted(Verb,HR=S_OK) else ICMError('2');
   end else ICMError('x.3.2');
  end else
  begin
   ICMError('1');
  end;
 finally
  for i:=0 to Length(fNames)-1 do
  if FilePIDLs[i]<>nil then
  begin
   SHGetMAlloc(M);
   M.Free(FilePIDLs[i]);
   M:=nil;
  end;
  if PathPIDL<>nil then
  begin
   SHGetMAlloc(M);
   M.Free(PathPIDL);
   M:=nil;
  end;
  if pMenu<>0 then DestroyMenu(pMenu);
  if CallbackWindow <> 0 then DestroyWindow(CallbackWindow);
  ICMenu:=nil;
  ISF:=nil;
  dISF:=nil;
  if cIE=S_OK then CoUninitialize;
 end;
end;

procedure GetPropertiesWindows(fNames : array of string; WC : TWinControl);
var
   dISF,ISF:IShellFolder;
   ICMenu:IContextMenu;
   CMD:TCMInvokeCommandInfo;
   PathPIDL:PItemIDList;
   FilePIDLs : array of PItemIDList;
   cIE,HR:HResult;
   M:IMAlloc;
   pMenu:HMenu;
   fPath:PWideChar;
   sFP,sFN:string;
   Attr,L:Cardinal;
   Verb: string;
   SCV:IShellCommandVerb;
   i, len : integer;
begin
 Attr:=0;
 PathPIDL:=nil;
 cIE:=CoInitializeEx(nil,COINIT_MULTITHREADED);
 try
  sFP:=GetCommonDirectory(fNames);
  len:=length(sFP);
  sFN:=fNames[0];
  Delete(sFN,1,length(sFP));
  if SHGetDesktopFolder(dISF)<>S_OK then exit;
  if sFN='' then
  begin
   sFN:=sFP;
   fPath:=StringToOleStr(sFN);
   L:=Length(sFN);
   if (SHGetSpecialFolderLocation(0,CSIDL_DRIVES,PathPIDL)<>S_OK) or
   (dISF.BindToObject(PathPIDL,nil,IID_IShellFolder,Pointer(ISF))<>S_OK) then exit;
   SetLength(FilePIDLs,1);
   ISF.ParseDisplayName(WC.Handle,nil,fPath,L,FilePIDLs[0],Attr);
   HR:=ISF.GetUIObjectOf(WC.Handle,1,FilePIDLs[0],IID_IContextMenu,nil,Pointer(ICMenu));
  end else
  begin
   fPath:=StringToOleStr(sFP);
   L:=Length(sFP);
   SetLength(FilePIDLs,Length(fNames)+1);
   FillChar(FilePIDLs[Length(fNames)],Sizeof(PItemIDList),#0);
   for i:=0 to Length(fNames)-1 do
   FilePIDLs[i]:=nil;
   if (dISF.ParseDisplayName(WC.Handle,nil,fPath,L,PathPIDL,Attr)<>S_OK)or
   (dISF.BindToObject(PathPIDL,nil,IID_IShellFolder,Pointer(ISF))<>S_OK) then exit;
   for i:=0 to Length(fNames)-1 do
   begin
    delete(fNames[i],1,len);
    fPath:=StringToOleStr(fNames[i]);
    L:=Length(fNames[i]);
    ISF.ParseDisplayName(WC.Handle,nil,fPath,L,FilePIDLs[i],Attr);
   end;
   HR:=ISF.GetUIObjectOf(WC.Handle,Length(fNames),FilePIDLs[0],IID_IContextMenu,nil,Pointer(ICMenu));
  end;
  if Succeeded(HR) then
  begin
   pMenu:=CreatePopupMenu;
   if Succeeded(ICMenu.QueryContextMenu(pMenu, 0, 1, $7FFF, CMF_EXPLORE)) then
   FillChar(CMD,SizeOf(CMD),#0);
   with CMD do
   begin
    cbSize:=SizeOf(CMD);
    hWND:=WC.Handle;
    lpVerb:='Properties';
    nShow:=SW_SHOWNORMAL;
   end;
   HR:=ICMenu.InvokeCommand(CMD);
   if Assigned(SCV) then
   SCV.CommandCompleted(Verb,HR=S_OK);
  end;
 finally
  for i:=0 to Length(fNames)-1 do
  if FilePIDLs[i]<>nil then
  begin
   SHGetMAlloc(M);
   M.Free(FilePIDLs[i]);
   M:=nil;
  end;
  if PathPIDL<>nil then
  begin
   SHGetMAlloc(M);
   M.Free(PathPIDL);
   M:=nil;
  end;
  dISF:=nil;
  if cIE=S_OK then CoUninitialize;
 end;
end;




end.
