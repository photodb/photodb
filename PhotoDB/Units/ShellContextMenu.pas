unit ShellContextMenu;

interface

uses
  Windows, SysUtils, Messages, StdCtrls, ComCtrls, ShlObj, ActiveX, ShellCtrls,
  Classes, Controls, Math, Forms, uMemory, uFileUtils;

procedure GetProperties(Files : TStrings; MP : TPoint; WC : TWinControl);
procedure GetPropertiesWindows(Files : TStrings; WC : TWinControl);

implementation

uses Searching;

procedure ICMError(Error : String);
begin
  // Searching.SearchManager.GetAnySearch.Caption:=Error;
  // Application.MessageBox(PChar(Error), TA('Error'), MB_OK + MB_ICONERROR);
end;

procedure FormatDir(var S: string);
begin
  if S = '' then
    Exit;
  if S[Length(S)] <> '\' then
    S := S + '\';
end;

function GetCommonDir(Dir1 { Common  dir } , Dir2 { Compare dir } : string): string;
var
  I, C: Integer;
begin
  if IsDrive(Dir1) or IsDrive(Dir2) then
    Exit('');

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
        SetWindowLong(Wnd, GWL_USERDATA, Longint(ContextMenu2));
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
  Windows.RegisterClass(WndClass);
  Result := CreateWindow(IcmCallbackWnd, IcmCallbackWnd, WS_POPUPWINDOW, 0,
    0, 0, 0, 0, 0, HInstance, Pointer(ContextMenu));
end;

procedure GetProperties(Files : TStrings; MP : TPoint; WC : TWinControl);
var
  DISF, ISF: IShellFolder;
  ICMenu: IContextMenu;
  ICMenu2: IContextMenu2;
  CMD: TCMInvokeCommandInfo;
  PathPIDL: PItemIDList;
  FilePIDLs: array of PItemIDList;
  CIE, HR: HResult;
  M: IMAlloc;
  PMenu: HMenu;
  FPath: PWideChar;
  SFP, SFN: string;
  Attr, L: Cardinal;
  FPM: LongBool;
  ICmd: Integer;
  ZVerb: array [0 .. 1023] of Ansichar;
  S, Verb: string;
  Handled: Boolean;
  SCV: IShellCommandVerb;
  I, Len: Integer;
  CallbackWindow: HWND;
  R_H: Byte;
begin
  PMenu := 0;
  Attr := 0;
  CallbackWindow := 0;
  PathPIDL := nil;
  CIE := CoInitializeEx(nil, COINIT_MULTITHREADED);
  try
    SFP := GetCommonDirectory(Files);
    Len := Length(SFP);
    SFN := Files[0];
    Delete(SFN, 1, Length(SFP));
    if SHGetDesktopFolder(DISF) <> S_OK then
      Exit;
    ICMError('x.1');
    begin
      L := Length(SFP);
      if SFP = '' then
        SFP := '::' + GuidToString(CLSID_MyComputer);
      FPath := StringToOleStr(SFP);
      SetLength(FilePIDLs, Files.Count + 1);
      FillChar(FilePIDLs[Files.Count], Sizeof(PItemIDList), #0);
      for I := 0 to Files.Count - 1 do
        FilePIDLs[I] := nil;
      if (DISF.ParseDisplayName(WC.Handle, nil, FPath, L, PathPIDL, Attr) <> S_OK) or (DISF.BindToObject(PathPIDL, nil,
          IID_IShellFolder, Pointer(ISF)) <> S_OK) then
        Exit;
      for I := 0 to Files.Count - 1 do
      begin
        S := Files[I];
        Delete(S, 1, Len);
        FPath := StringToOleStr(S);
        L := Length(S);
        ISF.ParseDisplayName(WC.Handle, nil, FPath, L, FilePIDLs[I], Attr);
      end;
      ICMError('x.2');
      HR := ISF.GetUIObjectOf(WC.Handle, Files.Count, FilePIDLs[0], IID_IContextMenu, nil, Pointer(ICMenu));
      ICMError('x.3');
    end;
    if Succeeded(HR) then
    begin
      ICMenu2 := nil;
      Windows.ClientToScreen(WC.Handle, MP);
      PMenu := CreatePopupMenu;
      ICMError('x.3.1');
      if Succeeded(ICMenu.QueryContextMenu(PMenu, 0, 1, $7FFF, CMF_NORMAL)) then
        CallbackWindow := 0;
      ICMError('x.4');
      if Succeeded(ICMenu.QueryInterface(IContextMenu2, ICMenu2)) then
      begin
        CallbackWindow := CreateMenuCallbackWnd(ICMenu2);
        ICMError('x.5');
      end else
        ICMError('4');
      try
        ICMError('x.6');
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
          SCV.CommandCompleted(Verb, HR = S_OK)
        else
          ICMError('2');
      end else
        ICMError('x.3.2');
    end else
      ICMError('1');
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
    if PMenu <> 0 then
      DestroyMenu(PMenu);
    if CallbackWindow <> 0 then
      DestroyWindow(CallbackWindow);
    ICMenu := nil;
    ISF := nil;
    DISF := nil;
    if CIE = S_OK then
      CoUninitialize;
  end;
end;

procedure GetPropertiesWindows(Files: TStrings; WC: TWinControl);
var
  DISF, ISF: IShellFolder;
  ICMenu: IContextMenu;
  CMD: TCMInvokeCommandInfo;
  PathPIDL: PItemIDList;
  FilePIDLs: array of PItemIDList;
  CIE, HR: HResult;
  M: IMAlloc;
  PMenu: HMenu;
  FPath: PWideChar;
  SFP, SFN: string;
  Attr, L: Cardinal;
  S, Verb: string;
  SCV: IShellCommandVerb;
  I, Len: Integer;
begin
  Attr := 0;
  PathPIDL := nil;
  CIE := CoInitializeEx(nil, COINIT_MULTITHREADED);
  try
    SFP := GetCommonDirectory(Files);
    Len := Length(SFP);
    SFN := Files[0];
    Delete(SFN, 1, Length(SFP));
    if SHGetDesktopFolder(DISF) <> S_OK then
      Exit;
    if SFN = '' then
    begin
      SFN := SFP;
      FPath := StringToOleStr(SFN);
      L := Length(SFN);
      if (SHGetSpecialFolderLocation(0, CSIDL_DRIVES, PathPIDL) <> S_OK) or (DISF.BindToObject(PathPIDL, nil,
          IID_IShellFolder, Pointer(ISF)) <> S_OK) then
        Exit;
      SetLength(FilePIDLs, 1);
      ISF.ParseDisplayName(WC.Handle, nil, FPath, L, FilePIDLs[0], Attr);
      HR := ISF.GetUIObjectOf(WC.Handle, 1, FilePIDLs[0], IID_IContextMenu, nil, Pointer(ICMenu));
    end else
    begin
      FPath := StringToOleStr(SFP);
      L := Length(SFP);
      SetLength(FilePIDLs, Files.Count + 1);
      FillChar(FilePIDLs[Files.Count], SizeOf(PItemIDList), #0);
      for I := 0 to Files.Count - 1 do
        FilePIDLs[I] := nil;
      if (DISF.ParseDisplayName(WC.Handle, nil, FPath, L, PathPIDL, Attr) <> S_OK) or (DISF.BindToObject(PathPIDL, nil,
          IID_IShellFolder, Pointer(ISF)) <> S_OK) then
        Exit;
      for I := 0 to Files.Count - 1 do
      begin
        S := Files[I];
        Delete(S, 1, Len);
        FPath := StringToOleStr(S);
        L := Length(S);
        ISF.ParseDisplayName(WC.Handle, nil, FPath, L, FilePIDLs[I], Attr);
      end;
      HR := ISF.GetUIObjectOf(WC.Handle, Files.Count, FilePIDLs[0], IID_IContextMenu, nil, Pointer(ICMenu));
    end;
    if Succeeded(HR) then
    begin
      PMenu := CreatePopupMenu;
      if Succeeded(ICMenu.QueryContextMenu(PMenu, 0, 1, $7FFF, CMF_EXPLORE)) then
        FillChar(CMD, SizeOf(CMD), #0);
      with CMD do
      begin
        CbSize := SizeOf(CMD);
        HWND := WC.Handle;
        LpVerb := 'Properties';
        NShow := SW_SHOWNORMAL;
      end;
      HR := ICMenu.InvokeCommand(CMD);
      if Assigned(SCV) then
        SCV.CommandCompleted(Verb, HR = S_OK);
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
    DISF := nil;
    if CIE = S_OK then
      CoUninitialize;
  end;
end;

end.
