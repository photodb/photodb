unit ShellContextMenu;

interface

uses
  System.Types,
  System.Math,
  System.SysUtils,
  System.Classes,
  System.Win.ComObj,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShlObj,
  Winapi.ActiveX,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Shell.ShellCtrls,

  DragDropPIDL,

  Dmitry.Utils.Files,

  uMemory;

procedure GetProperties(Files: TStrings; MP : TPoint; WC : TWinControl);
procedure GetPropertiesWindows(Files: TStrings; WC: TWinControl);
procedure DisplayShellMenu(ICMenu: IContextMenu; MP: TPoint; WC: TWinControl; Verb: string = '');
function GetShellMenu(Handle: THandle; Files: TStrings): IContextMenu;

implementation

function GetCommonDir(Dir1 { Common  dir } , Dir2 { Compare dir } : string): string;
var
  I, C: Integer;
begin
  if Dir1 = Dir2 then
  begin
    Result := Dir1;
  end else
  begin
    if Dir1 = Copy(Dir2, 1, Length(Dir1)) then
    begin
      Result := Dir1;
      Exit;
    end;
    C := Min(Length(Dir1), Length(Dir2));
    for I := 1 to C do
      if Dir1[I] <> Dir2[I] then
      begin
        C := I;
        Break;
      end;
    Result := ExtractFilePath(Copy(Dir1, 1, C - 1));
  end;
end;

function GetCommonDirectory(FileNames: TStrings): string;
var
  I: Integer;
  S, Temp, D: string;
  Files: TStrings;
begin
  Result := '';
  if FileNames.Count = 0 then
    Exit;
  Files := TStringList.Create;
  try
    Files.Assign(FileNames);

    for I := 0 to Files.Count - 1 do
      Files[I] := ExtractFilePath(Files[I]);

    S := AnsiLowerCase(Copy(Files[0], 1, 2));
    Temp := AnsiLowerCase(Files[0]);
    for I := 0 to Files.Count - 1 do
    begin
      Files[I] := AnsiLowerCase(Files[I]);
      if Length(Files[I]) < 2 then
        Exit;
      if S <> Copy(Files[I], 1, 2) then
        Exit;
      D := ExtractFilePath(Files[I]);
      if Length(Temp) > Length(D) then
        Temp := D;
    end;

    for I := 0 to Files.Count - 1 do
      Temp := GetCommonDir(Temp, Files[I]);

    Result := Temp;
  finally
    F(Files);
  end;
end;

function SetErrorShell(Cmd: Byte): Byte;
var
  ErrOld, Shell32: Cardinal;
  OP, I: NativeUInt;
  SMB_W: Pointer;
  R: Byte;
begin
  R := 0;
  if Cmd = 0 then
    Cmd := $C3;

  ErrOld := SetErrorMode(SEM_NOOPENFILEERRORBOX);
  try
    Shell32 := LoadLibrary('shell32.dll');
    if Shell32 <> 0 then
    begin
      SMB_W := GetProcAddress(Shell32, 'ShellMessageBoxW');
      if SMB_W <> nil then
      begin
        OP := OpenProcess(PROCESS_VM_READ or PROCESS_VM_WRITE or PROCESS_VM_OPERATION, False, GetCurrentProcessID);
        if OP <> 0 then
        begin
          if not(ReadProcessMemory(OP, SMB_W, @R, SizeOf(R), I) and (I = SizeOf(R)) and WriteProcessMemory(OP, SMB_W,
              @Cmd, SizeOf(Cmd), I) and (I = SizeOf(Cmd))) then
            R := 0;
          CloseHandle(OP);
        end;
      end;
      FreeLibrary(Shell32);
    end;
  finally
    SetErrorMode(ErrOld);
  end;
  Result := R;
end;

function MenuCallback(Wnd: HWND; Msg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT; stdcall;
var
  ContextMenu2: IContextMenu2;
begin
  case Msg of
    WM_CREATE:
      begin
        ContextMenu2 := IContextMenu2(PCreateStruct(LParam).LpCreateParams);
        SetWindowLong(Wnd, GWL_USERDATA, NativeInt(ContextMenu2));
        Result := DefWindowProc(Wnd, Msg, WParam, LParam);
      end;
    WM_INITMENUPOPUP:
      begin
        ContextMenu2 := IContextMenu2(GetWindowLong(Wnd, GWL_USERDATA));
        ContextMenu2.HandleMenuMsg(Msg, WParam, LParam);
        Result := 0;
      end;
    WM_DRAWITEM, WM_MEASUREITEM:
      begin
        ContextMenu2 := IContextMenu2(GetWindowLong(Wnd, GWL_USERDATA));
        ContextMenu2.HandleMenuMsg(Msg, WParam, LParam);
        Result := 1;
      end;
  else
    Result := DefWindowProc(Wnd, Msg, WParam, LParam);
  end;
end;

function CreateMenuCallbackWnd(const ContextMenu: IContextMenu2): HWND;
const
  IcmCallbackWnd = 'ICMCALLBACKWND';
var
  WndClass: TWndClass;
begin
  FillChar(WndClass, SizeOf(WndClass), #0);
  WndClass.lpszClassName := PWideChar(IcmCallbackWnd);
  WndClass.lpfnWndProc := @MenuCallback;
  WndClass.hInstance := HInstance;
  Winapi.Windows.RegisterClass(WndClass);
  Result := CreateWindow(IcmCallbackWnd, IcmCallbackWnd, WS_POPUPWINDOW, 0,
    0, 0, 0, 0, 0, HInstance, Pointer(ContextMenu));
end;

function GetShellMenu(Handle: THandle; Files: TStrings): IContextMenu;
var
  PathPIDL: PItemIDList;
  DISF, ISF: IShellFolder;
  FilePIDLs: array of PItemIDList;
  M: IMAlloc;
  FPath: PWideChar;
  S, SFP, SFN: string;
  I, Len: Integer;
  Attr, L: Cardinal;

  IsDriveList: Boolean;
  IsMyComputer: Boolean;
begin
  Result := nil;

  if SHGetDesktopFolder(DISF) <> S_OK then
    Exit;

  Attr := 0;
  IsDriveList := False;
  IsMyComputer := False;

  for I := 0 to Files.Count - 1 do
  begin
    if IsDrive(Files[I]) or IsShortDrive(Files[I]) then
      IsDriveList := True;

    if Files[I] = '' then
      IsMyComputer := True;
  end;

  try
    if IsMyComputer then
    begin
      SetLength(FilePIDLs, 1);

      SFP := '::' + GuidToString(CLSID_MyComputer);
      L := Length(SFP);
      FPath := StringToOleStr(SFP);
      if (DISF.ParseDisplayName(Handle, nil, FPath, L, PathPIDL, Attr) <> S_OK) or (DISF.BindToObject(PathPIDL, nil,
          IID_IShellFolder, Pointer(ISF)) <> S_OK) then
        Exit;
      //win200 fails
      FilePIDLs[0] := CopyPIDL(PathPIDL);

      DISF.GetUIObjectOf(Handle, 1, PathPIDL, IID_IContextMenu, nil, Pointer(Result));
    end else if IsDriveList then
    begin
      SetLength(FilePIDLs, Files.Count);

      if (SHGetSpecialFolderLocation(0, CSIDL_DRIVES, PathPIDL) <> S_OK) or (DISF.BindToObject(PathPIDL, nil, IID_IShellFolder, Pointer(ISF)) <> S_OK) then
        Exit;

      for I := 0 to Files.Count - 1 do
      begin
        S := Files[I];
        if IsShortDrive(S) then
          S := S + '\';
        FPath := StringToOleStr(S);
        L := Length(FPath);
        ISF.ParseDisplayName(Handle, nil, FPath, L, FilePIDLs[I], Attr);
      end;

      ISF.GetUIObjectOf(Handle, Files.Count, FilePIDLs[0], IID_IContextMenu, nil, Pointer(Result));
    end else
    begin
      SetLength(FilePIDLs, Files.Count);

      SFP := GetCommonDirectory(Files);
      Len := Length(SFP);
      SFN := Files[0];
      Delete(SFN, 1, Length(SFP));

      L := Length(SFP);
      FPath := StringToOleStr(SFP);
      if (DISF.ParseDisplayName(Handle, nil, FPath, L, PathPIDL, Attr) <> S_OK) or (DISF.BindToObject(PathPIDL, nil,
          IID_IShellFolder, Pointer(ISF)) <> S_OK) then
        Exit;

      for I := 0 to Files.Count - 1 do
      begin
        S := Files[I];
        Delete(S, 1, Len);
        FPath := StringToOleStr(S);
        L := Length(S);
        ISF.ParseDisplayName(Handle, nil, FPath, L, FilePIDLs[I], Attr);
      end;
      ISF.GetUIObjectOf(Handle, Files.Count, FilePIDLs[0], IID_IContextMenu, nil, Pointer(Result));
    end;

  finally
    for I := 0 to Files.Count - 1 do
      if FilePIDLs[I] <> nil then
      begin
        SHGetMAlloc(M);
        M.Free(FilePIDLs[I]);
        M := nil;
      end;
    if PathPIDL <> nil then
    begin
      SHGetMAlloc(M);
      M.Free(PathPIDL);
      M := nil;
    end;
    ISF := nil;
    DISF := nil;
  end;
end;

procedure GetProperties(Files: TStrings; MP: TPoint; WC: TWinControl);
var
  Menu: IContextMenu;
begin
  Menu := GetShellMenu(WC.Handle, Files);
  if Menu <> nil then
    DisplayShellMenu(Menu, MP, WC);
end;

procedure DisplayShellMenu(ICMenu: IContextMenu; MP: TPoint; WC: TWinControl; Verb: string = '');
var
  ICMenu2: IContextMenu2;
  CMD: TCMInvokeCommandInfo;
  CIE, HR: HResult;
  PMenu: HMenu;
  FPM: LongBool;
  ICmd: Integer;
  ZVerb: array [0 .. 1023] of Ansichar;
  Handled: Boolean;
  SCV: IShellCommandVerb;
  CallbackWindow: HWND;
  R_H: Byte;
begin
  PMenu := 0;
  CallbackWindow := 0;
  CIE := CoInitializeEx(nil, COINIT_MULTITHREADED);
  try
    ICMenu2 := nil;
    Winapi.Windows.ClientToScreen(WC.Handle, MP);
    PMenu := CreatePopupMenu;

    if Succeeded(ICMenu.QueryContextMenu(PMenu, 0, 1, $7FFF, CMF_NORMAL)) then
      CallbackWindow := 0;

    if Verb <> '' then
    begin
      with CMD do
      begin
        CbSize := SizeOf(CMD);
        HWND := WC.Handle;
        LpVerb := PAnsiChar(AnsiString(Verb));
        NShow := SW_SHOWNORMAL;
      end;
      HR := ICMenu.InvokeCommand(CMD);
      if Assigned(SCV) then
        SCV.CommandCompleted(Verb, HR = S_OK);

      Exit;
    end;

    if Succeeded(ICMenu.QueryInterface(IContextMenu2, ICMenu2)) then
    begin
      CallbackWindow := CreateMenuCallbackWnd(ICMenu2);
    end;
    try
      FPM := TrackPopupMenu(PMenu, TPM_LEFTALIGN or TPM_LEFTBUTTON or TPM_RIGHTBUTTON or TPM_RETURNCMD, MP.X, MP.Y,
        0, CallbackWindow, nil);
    finally
      ICMenu2 := nil;
    end;
    if FPM then
    begin
      ICmd := LongInt(FPM) - 1;
      HR := ICMenu.GetCommandString(ICmd, GCS_VERBA, nil, ZVerb, SizeOf(ZVerb));
      Verb := string(StrPas(ZVerb));
      Handled := False;
      if Supports(WC, IShellCommandVerb, SCV) then
      begin
        HR := 0;
        SCV.ExecuteCommand(Verb, Handled);
      end;
      if not(Handled) then
      begin
        FillChar(CMD, SizeOf(CMD), #0);
        with CMD do
        begin
          CbSize := SizeOf(CMD);
          HWND := WC.Handle;
          LpVerb := PAnsiChar(MakeIntResource(ICmd));
          NShow := SW_SHOWNORMAL;
        end;
        R_H := SetErrorShell(0); // Ставим
        HR := ICMenu.InvokeCommand(CMD);
        if R_H <> 0 then
          SetErrorShell(R_H); // Востанавливаем
      end;
      if Assigned(SCV) then
        SCV.CommandCompleted(Verb, HR = S_OK);
    end;

  finally
    if PMenu <> 0 then
      DestroyMenu(PMenu);
    if CallbackWindow <> 0 then
      DestroyWindow(CallbackWindow);
    ICMenu := nil;
    if CIE = S_OK then
      CoUninitialize;
  end;
end;

procedure GetPropertiesWindows(Files: TStrings; WC: TWinControl);
var
  Menu: IContextMenu;
begin
  Menu := GetShellMenu(WC.Handle, Files);
  if Menu <> nil then
    DisplayShellMenu(Menu, Point(0, 0), WC, 'Properties');
end;

end.
