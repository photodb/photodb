 // For NT, Win2k, XP: 
//------------------------------------------- 
// Unit to save/restore the positions of desktop icons to/from the registry) 

unit WindowsIconCacheTools;

 interface

 uses
   Windows, CommCtrl, SysUtils, Messages;

 const
   RegSubKeyName = 'Software\LVT\Desktop Item Position Saver';

 procedure RestoreDesktopItemPositions;
 procedure SaveDesktopItemPositions;

 function CreateRemoteBuffer(Pid : DWord; Size: Dword): PByte;
 procedure WriteToRemoteBuffer(Source : PByte;
                                Dest : PByte;
                                Count : Dword);
 function ReadRemoteBuffer (Source : PByte;
                             Dest : PByte;
                             Count : Dword): Dword;
 procedure DestroyRemoteBuffer;
 procedure RebuildIconCacheAndNotifyChanges;

 implementation

 uses
   registry;

 var
   hProcess : THandle;
   RemoteBufferAddr: PByte;
   BuffSize : DWord;

 function CreateRemoteBuffer;
 begin
   RemoteBufferAddr := nil;
   hProcess := OpenProcess(PROCESS_ALL_ACCESS, FALSE, Pid);
   if (hProcess = 0) then
     RaiseLastOSError;

   Result := VirtualAllocEx(hProcess,
                             nil,
                             Size,
                             MEM_COMMIT,
                             PAGE_EXECUTE_READWRITE);

   Win32Check(Result <> nil);
   RemoteBufferAddr := Result;
   BuffSize := Size;
 end;

 procedure WriteToRemoteBuffer;
 var
   BytesWritten: Dword;
 begin
  if hProcess = 0 then
    Exit;
  Win32Check(WriteProcessMemory(hProcess,
                                 Dest,
                                 Source,
                                 Count,
                                 BytesWritten));
 end;

 function ReadRemoteBuffer;
 begin
   Result := 0;
   if hProcess = 0 then
      Exit;

   Win32Check(ReadProcessMemory(hProcess,
                                 Source,
                                 Dest ,
                                 Count,
                                 Result));
 end;

 procedure DestroyRemoteBuffer;
 begin
    if (hProcess > 0)  then
      begin
        if Assigned(RemoteBufferAddr) then
          Win32Check(Boolean(VirtualFreeEx(hProcess,
                                           RemoteBufferAddr,
                                           0,
                                           MEM_RELEASE)));
        CloseHandle(hProcess);
      end;
 end;


 procedure SaveListItemPosition(LVH : THandle; RemoteAddr : Pointer);
 var
   lvi : TLVITEM;
   lenlvi : integer;
   nb : integer;
   buffer : array [0..MAX_PATH] of char;
   Base : Pointer;
   Base2 : PByte;
   i, ItemsCount : integer;
   Apoint : TPoint;
   key : HKEY;
 begin
   ItemsCount := SendMessage(LVH, LVM_GETITEMCOUNT, 0, 0);
   Base := RemoteAddr;
   lenlvi := SizeOf(lvi);
   FillChar(lvi, lenlvi, 0);
   lvi.cchTextMax := 255;
   lvi.pszText := Base;
   inc(lvi.pszText, lenlvi);

   WriteToRemoteBuffer(@lvi, Base, 255);

   Base2 := Base;
   inc(Base2, Lenlvi);

   RegDeleteKey(HKEY_CURRENT_USER, RegSubKeyName);

   RegCreateKeyEx(HKEY_CURRENT_USER,
     PChar(RegSUbKeyName),
     0,
     nil,
     REG_OPTION_NON_VOLATILE,
     KEY_SET_VALUE,
     nil,
     key,
     nil);

   for i := 0 to ItemsCount - 1 do
   begin
     nb := SendMessage(LVH, LVM_GETITEMTEXT, i, LParam(Base));

     ReadRemoteBuffer(Base2, @buffer, nb + 1);
     FillChar(Apoint, SizeOf(Apoint), 0);

     WriteToRemoteBuffer(@APoint, Base2, SizeOf(Apoint));
     SendMessage(LVH, LVM_GETITEMPOSITION, i, LParam(Base) + lenlvi);

     ReadRemoteBuffer(Base2, @Apoint, SizeOf(Apoint));
     RegSetValueEx(key, @buffer, 0, REG_BINARY, @Apoint, SizeOf(APoint));
   end;
   RegCloseKey(key);
 end;


 procedure RestoreListItemPosition(LVH : THandle; RemoteAddr : Pointer);
 type
   TInfo = packed record
     lvfi : TLVFindInfo;
     Name : array [0..MAX_PATH] of char;
   end;
 var
   SaveStyle : Dword;
   Base : Pointer;
   Apoint : TPoint;
   key : HKey;
   idx : DWord;
   info : TInfo;
   atype : Dword;
   cbname, cbData : Dword;
   itemidx : DWord;
 begin
   SaveStyle := GetWindowLong(LVH, GWL_STYLE);
   if (SaveStyle and LVS_AUTOARRANGE) = LVS_AUTOARRANGE then
     SetWindowLong(LVH, GWL_STYLE, SaveStyle xor LVS_AUTOARRANGE);

   RegOpenKeyEx(HKEY_CURRENT_USER, RegSubKeyName, 0, KEY_QUERY_VALUE, key);

   FillChar(info, SizeOf(info), 0);
   Base := RemoteAddr;

   idx := 0;
   cbname := MAX_PATH;
   cbdata := SizeOf(APoint);

   while (RegEnumValue(key, idx, info.Name, cbname, nil, @atype, @Apoint, @cbData) <>
     ERROR_NO_MORE_ITEMS) do
   begin
     if (atype = REG_BINARY) and (cbData = SizeOf(Apoint)) then
     begin
       info.lvfi.flags := LVFI_STRING;
       info.lvfi.psz := Base;
       inc(info.lvfi.psz, SizeOf(info.lvfi));
       WriteToRemoteBuffer(@info, Base, SizeOf(info.lvfi) + cbname + 1);
       itemidx := SendMessage(LVH, LVM_FINDITEM, - 1, LParam(Base));
       if itemidx > -1 then
         SendMessage(LVH, LVM_SETITEMPOSITION, itemidx, MakeLong(Apoint.x, Apoint.y));
     end;
     inc(idx);
     cbname := MAX_PATH;
     cbdata := SizeOf(APoint);
   end;
   RegCloseKey(key);

   SetWindowLong(LVH, GWL_STYLE, SaveStyle);
 end;

 function GetSysListView32: THandle;
 begin
   Result := FindWindow('Progman', nil);
   Result := FindWindowEx(Result, 0, nil, nil);
   Result := FindWindowEx(Result, 0, nil, nil);
 end;

 procedure SaveDesktopItemPositions;
 var
   pid : integer;
   rembuffer : PByte;
   hTarget : THandle;
 begin
   hTarget := GetSysListView32;
   GetWindowThreadProcessId(hTarget, @pid);
   if (hTarget = 0) or (pid = 0) then
     Exit;
   rembuffer := CreateRemoteBuffer(pid, $FFF);
   if Assigned(rembuffer) then
   begin
     SaveListItemPosition(hTarget, rembuffer);
     DestroyRemoteBuffer;
   end;
 end;

 procedure RestoreDesktopItemPositions;
 var
   hTarget : THandle;
   pid : DWord;
   rembuffer : PByte;
 begin
   hTarget := GetSysListView32;
   GetWindowThreadProcessId(hTarget, @pid);
   if (hTarget = 0) or (pid = 0) then
     Exit;
   rembuffer := CreateRemoteBuffer(pid, $FFF);
   if Assigned(rembuffer) then
   begin
     RestoreListItemPosition(hTarget, rembuffer);
     DestroyRemoteBuffer;
   end;
 end;

  procedure BroadcastChanges;
 var
   success: DWORD;
 begin
   SendMessageTimeout(HWND_BROADCAST,
                      WM_SETTINGCHANGE,
                      SPI_SETNONCLIENTMETRICS,
                      0,
                      SMTO_ABORTIFHUNG,
                      3000,
                      success);
 end;

function RefreshScreenIcons : Boolean;
const
  KEY_TYPE = HKEY_CURRENT_USER;
  KEY_NAME = 'Control Panel\Desktop\WindowMetrics';
  KEY_VALUE = 'Shell Icon Size';
var
  Reg: TRegistry;
  strDataRet, strDataRet2: string;
begin
  Result := False;
  Reg := TRegistry.Create;
  try
    Reg.RootKey := KEY_TYPE;
    // 1. open HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics
    if Reg.OpenKey(KEY_NAME, False) then
    begin
      // 2. Get the value for that key
      strDataRet := Reg.ReadString(KEY_VALUE);
      Reg.CloseKey;
      if strDataRet <> '' then
      begin
        // 3. Convert sDataRet to a number and subtract 1,
        //    convert back to a string, and write it to the registry
        strDataRet2 := IntToStr(StrToInt(strDataRet)-1);
        if Reg.OpenKey(KEY_NAME, False) then
        begin
          Reg.WriteString(KEY_VALUE, strDataRet2);
          Reg.CloseKey;
          // 4. because the registry was changed, broadcast
          //    the fact passing SPI_SETNONCLIENTMETRICS,
          //    with a timeout of 10000 milliseconds (10 seconds)
          BroadcastChanges;
          // 5. the desktop will have refreshed with the
          //    new (shrunken) icon size. Now restore things
          //    back to the correct settings by again writing
          //    to the registry and posing another message.
          if Reg.OpenKey(KEY_NAME, False) then
          begin
            Reg.WriteString(KEY_VALUE, strDataRet);
            Reg.CloseKey;
            // 6.  broadcast the change again
            BroadcastChanges;
            Result := True;
          end;
        end;
      end;
    end;
  finally
    Reg.Free;
  end;
end;

 Procedure RebuildIconCacheAndNotifyChanges;
 begin
  SaveDesktopItemPositions;
  RefreshScreenIcons;
  RestoreDesktopItemPositions;
 end;

 end.
