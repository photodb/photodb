unit uShellUtils;

interface

uses
  Windows, Classes, Forms, UnitINI, uConstants, Registry, SysUtils, uLogger,
  uMemory, uInstallTypes, uInstallScope, uTranslate, uDBBaseTypes;

function RegInstallApplication(Filename, DBName, UserName: string): Boolean;
function ExtInstallApplication(Filename: string): Boolean;
function ExtInstallApplicationW(Exts: TInstallExts; Filename: string): Boolean;
function ExtUnInstallApplicationW: Boolean;
function IsNewVersion: Boolean;
function DeleteRegistryEntries: Boolean;
function InstalledDirectory: string;
function InstalledFileName: string;
function FileRegisteredOnInstalledApplication(Value: string): Boolean;
function GetDefaultDBName: string;

implementation

function InstalledDirectory: string;
begin
  Result := ExtractFileDir(InstalledFileName);
end;

function InstalledFileName: string;
var
  FReg: TBDRegistry;
begin
  Result := '';
  FReg := TBDRegistry.Create(REGISTRY_ALL_USERS, True);
  try
    FReg.OpenKey(RegRoot, True);
    Result := FReg.ReadString('DataBase');
    if PortableWork then
      if Result <> '' then
        Result[1] := Application.Exename[1];
  except
  end;
  FReg.Free;
end;

function IsNewVersion: Boolean;
var
  FReg: TBDRegistry;
  Func: TIntegerFunction;
  H: Thandle;
  ProcH: Pointer;
  FileName: string;
begin
  Result := False;
  Freg := TBDRegistry.Create(REGISTRY_ALL_USERS, True);
  try
    FReg.OpenKey(RegRoot, True);
    FileName := FReg.ReadString('DataBase');
    if FileExists(FileName) then
    begin
      H := LoadLibrary(PWideChar(FileName));
      if H <> 0 then
      begin
        ProcH := GetProcAddress(H, 'FileVersion');
        if ProcH <> nil then
        begin
          @Func := ProcH;
          if Func > ReleaseNumber then
            Result := True;
        end;
        FreeLibrary(H);
      end;
    end;
  except
    on e : Exception do
      EventLog(e.Message);
  end;
  F(FReg);
end;

function DeleteRegistryEntries: Boolean;
var
  Freg: TRegistry;
begin
  Result := False;
  Freg := Tregistry.Create;
  try
    Freg.RootKey := Windows.HKEY_CLASSES_ROOT;
    Freg.DeleteKey('\.photodb');
    Freg.DeleteKey('\PhotoDB.PhotodbFile\');
    Freg.DeleteKey('\.ids');
    Freg.DeleteKey('\PhotoDB.IdsFile\');
    Freg.DeleteKey('\.dbl');
    Freg.DeleteKey('\PhotoDB.DblFile\');
    Freg.DeleteKey('\.ith');
    Freg.DeleteKey('\PhotoDB.IthFile\');
    Freg.DeleteKey('\Directory\Shell\PhDBBrowse\');
    Freg.DeleteKey('\Drive\Shell\PhDBBrowse\');
  except
    on E: Exception do
    begin
      EventLog(':DeleteRegistryEntries() throw exception: ' + E.message);
      Freg.Free;
    end;
  end;
  FReg.Free;
  FReg := Tregistry.Create;
  try
    FReg.RootKey := HKEY_INSTALL;
    FReg.DeleteKey(RegRoot);
  except
    on E: Exception do
    begin
      EventLog(':DeleteRegistryEntries()/HKEY_INSTALL throw exception: ' + E.message);
      FReg.Free;
    end;
  end;
  FReg.Free;
  FReg := TRegistry.Create;
  try
    FReg.RootKey := HKEY_USER_WORK;
    FReg.DeleteKey(RegRoot);
  except
    on E: Exception do
    begin
      EventLog(':DeleteRegistryEntries()/HKEY_USER_WORK throw exception: ' + E.message);
      FReg.Free;
    end;
  end;
  FReg.Free;
  FReg := Tregistry.Create;
  try
    FReg.RootKey := Windows.HKEY_LOCAL_MACHINE;
    FReg.DeleteKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Photo DataBase');
    Result := True;
  except
    on E: Exception do
      EventLog(':DeleteRegistryEntries() throw exception: ' + E.message);
  end;
  FReg.Free;
  FReg := TRegistry.Create;
  try
    FReg.RootKey := Windows.HKEY_LOCAL_MACHINE;
    FReg.DeleteKey(
      '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\PhotoDBGetPhotosHandler');
    FReg.DeleteKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler');
    FReg.OpenKey(
      '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlers\ShowPicturesOnArrival', True);
    FReg.DeleteValue('PhotoDBgetPhotosHandler');
    Result := True;
  except
    on E: Exception do
      EventLog(':DeleteRegistryEntries() throw exception: ' + E.message);
  end;
  FReg.Free;
end;

function GetDefaultDBName: string;
var
  Reg: TBDRegistry;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(RegRoot, True);
    Result := Reg.ReadString('DBDefaultName');
  except
  end;
  Reg.Free;
end;

function RegInstallApplication(FileName, DBName, UserName: string): Boolean;
var
  Freg: TBDRegistry;
begin
  Result := True;
  Freg := TBDRegistry.Create(REGISTRY_ALL_USERS);
  try
    Freg.OpenKey(RegRoot, True);
    Freg.WriteString('ReleaseNumber', IntToStr(ReleaseNumber));
    Freg.WriteString('DataBase', Filename);
    Freg.WriteString('Folder', ExtractFileDir(Filename));
    Freg.WriteString('DBDefaultName', DBName);
    Freg.WriteString('DBUserName', UserName);
  except
    on E: Exception do
    begin
      Result := False;
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Freg.Free;
      Exit;
    end;
  end;
  Freg.Free;

  if PortableWork then
    Exit;

  Freg := TBDRegistry.Create(REGISTRY_ALL_USERS);
  try
    Freg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Photo DataBase', True);
    Freg.WriteString('UninstallString', '"' + Filename + '"' + ' /uninstall');
    Freg.WriteString('DisplayName', 'Photo DataBase');
    Freg.WriteString('DisplayVersion', ProductVersion);
    Freg.WriteString('HelpLink', HomeURL);
    Freg.WriteString('Publisher', CopyRightString);
    Freg.WriteString('URLInfoAbout', 'MailTo:' + ProgramMail);
  except
    on E: Exception do
    begin
      Result := False;
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Freg.Free;
      Exit;
    end;
  end;
  Freg.Free;

  Freg := TBDRegistry.Create(REGISTRY_CLASSES);
  try
    Freg.OpenKey('\.photodb', True);
    Freg.WriteString('', 'PhotoDB.PhotodbFile');
    Freg.CloseKey;
    Freg.OpenKey('\PhotoDB.PhotodbFile', True);
    Freg.OpenKey('\PhotoDB.PhotodbFile\DefaultIcon', True);
    Freg.WriteString('', FileName + ',0');
    Freg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;
  Freg.Free;

  Freg := TBDRegistry.Create(REGISTRY_CLASSES);
  try
    Freg.OpenKey('\.ids', True);
    Freg.WriteString('', 'PhotoDB.IdsFile');
    Freg.CloseKey;
    Freg.OpenKey('\PhotoDB.IdsFile', True);
    Freg.OpenKey('\PhotoDB.IdsFile\DefaultIcon', True);
    Freg.WriteString('', FileName + ',0');
    Freg.OpenKey('\PhotoDB.IdsFile\Shell\Open\Command', True);
    Freg.WriteString('', Format('"%s" "%1"', [FileName]));
    Freg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;
  Freg.Free;

  Freg := TBDRegistry.Create(REGISTRY_CLASSES);
  try
    Freg.CloseKey;
    Freg.OpenKey('\.dbl', True);
    Freg.WriteString('', 'PhotoDB.dblFile');
    Freg.CloseKey;
    Freg.OpenKey('\PhotoDB.dblFile', True);
    Freg.OpenKey('\PhotoDB.dblFile\DefaultIcon', True);
    Freg.WriteString('', FileName + ',0');
    Freg.OpenKey('\PhotoDB.dblFile\Shell\Open\Command', True);
    Freg.WriteString('', Format('"%s" "%1"', [FileName]));
    Freg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;
  Freg.Free;

  Freg := TBDRegistry.Create(REGISTRY_CLASSES);
  try
    Freg.CloseKey;
    Freg.OpenKey('\.ith', True);
    Freg.Writestring('', 'PhotoDB.IthFile');
    Freg.CloseKey;
    Freg.OpenKey('\PhotoDB.IthFile', True);
    Freg.OpenKey('\PhotoDB.IthFile\DefaultIcon', True);
    Freg.Writestring('', FileName + ',0');
    Freg.OpenKey('\PhotoDB.IthFile\Shell\Open\Command', True);
    Freg.WriteString('', Format('"%s" "%1"', [FileName]));
    Freg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;

  Freg.Free;
  // Adding Handler for removable drives
  Freg := TBDRegistry.Create(REGISTRY_ALL_USERS);
  try
    Freg.OpenKey
      ('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\PhotoDBGetPhotosHandler', True);
    Freg.WriteString('Action', TA('Get photos', 'System'));
    Freg.WriteString('DefaultIcon', FileName + ',0');
    Freg.WriteString('InvokeProgID', 'PhotoDB.AutoPlayHandler');
    Freg.WriteString('InvokeVerb', 'Open');
    Freg.WriteString('Provider', 'Photo DataBase ' + ProductVersion);
    Freg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;
  Freg.Free;

  Freg := TBDRegistry.Create(REGISTRY_ALL_USERS);
  try
    Freg.OpenKey(
      '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlers\ShowPicturesOnArrival', True);
    Freg.WriteString('PhotoDBGetPhotosHandler', '');
    Freg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;
  Freg.Free;

  Freg := TBDRegistry.Create(REGISTRY_ALL_USERS);
  try
    Freg.OpenKey('\SOFTWARE\Classes', True);
    Freg.CloseKey;
    Freg.OpenKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler', True);
    Freg.CloseKey;
    Freg.OpenKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler\Shell', True);
    Freg.CloseKey;
    Freg.OpenKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler\Shell\Open', True);
    Freg.CloseKey;
    Freg.OpenKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler\Shell\Open\Command', True);
    Freg.WriteString('', Format('"%s" "/GETPHOTOS" "%1"', [Filename]));
    Freg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;
  Freg.Free;
end;

function FileRegisteredOnInstalledApplication(Value: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Length(Value) downto 2 do
    if (Value[I - 1] = '%') and (Value[I] = '1') then
    begin
      Delete(Value, I - 1, 2);
    end;
  for I := Length(Value) downto 1 do
    if Value[I] = '"' then
      Delete(Value, I, 1);
  for I := Length(Value) downto 1 do
    if Value[I] = ' ' then
      Delete(Value, I, 1)
    else
      Break;
  if AnsiLowerCase(Value) = AnsiLowerCase(ExtractFileDir(InstalledFileName) + 'PhotoDB.exe') then
    Result := True;
end;

function ExtInstallApplicationW(Exts: TInstallExts; Filename: string): Boolean;
var
  Reg: TRegistry;
  I: Integer;
  S: string;
  B, C: Boolean;

  procedure DeleteExtInfo(Ext: string);
  var
    FReg: TRegistry;
  begin
    FReg := TRegistry.Create;
    try
      FReg.RootKey := Windows.HKEY_CURRENT_USER;
      FReg.DeleteKey('Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.' + Ext);
    finally
      FReg.Free;
    end;
  end;

begin
  Reg := TRegistry.Create;
  Reg.RootKey := Windows.HKEY_CLASSES_ROOT;
  for I := 0 to Exts.Count - 1 do
  begin
    case Exts[I].State of
      TES_IGNORE:
        begin
          Reg.OpenKey('\.' + Exts[I].Ext, True);
          S := Reg.ReadString('');
          Reg.CloseKey;
          B := False;
          if S = '' then
            B := True;
          if not B then
          begin
            Reg.OpenKey('\' + S + '\Shell\Open\Command', False);
            if Reg.ReadString('') <> '' then
              B := False
            else
              B := True;
            Reg.CloseKey;
          end;
          if B then
          begin
            Reg.OpenKey('\.' + Exts[I].Ext, True);
            Reg.WriteString('', 'PhotoDB.' + Exts[I].Ext);
            Reg.CloseKey;
            Reg.OpenKey('\PhotoDB.' + Exts[I].Ext + '\Shell\Open\Command', True);
            Reg.WriteString('', Format('"%s" "%1"', [FileName]));
            Reg.CloseKey;
            Reg.OpenKey('\PhotoDB.' + Exts[I].Ext + '\DefaultIcon', True);
            Reg.WriteString('', Filename + ',0');
            Reg.CloseKey;
            DeleteExtInfo(Exts[I].Ext);
          end else
          begin
            Reg.OpenKey('\.' + Exts[I].Ext, True);
            S := Reg.ReadString('');
            Reg.WriteString('PhotoDB_PreviousAssociation', S);
            Reg.WriteString('', 'PhotoDB.' + Exts[I].Ext);
            Reg.CloseKey;
            Reg.OpenKey('\PhotoDB.' + Exts[I].Ext + '\Shell\Open\Command', True);
            Reg.WriteString('', Format('"%s" "%1"', [Filename]));
            Reg.CloseKey;
            Reg.OpenKey('\PhotoDB.' + Exts[I].Ext + '\DefaultIcon', True);
            Reg.WriteString('', Filename + ',0');
            Reg.CloseKey;
            DeleteExtInfo(Exts[I].Ext);
          end;
        end;
      TES_ADD_HANDLER:
        begin
          Reg.OpenKey('\.' + Exts[I].Ext, True);
          S := Reg.ReadString('');
          Reg.CloseKey;
          C := False;
          B := True;
          if S = '' then
            C := True;
          if not C then
          begin
            Reg.OpenKey('\' + S + '\Shell\Open\Command', False);
            if Reg.ReadString('') <> '' then
              B := False
            else
              B := True;
            Reg.CloseKey;
          end;
          if B then
          begin
            Reg.OpenKey('\.' + Exts[I].Ext, True);
            Reg.WriteString('', 'PhotoDB.' + Exts[I].Ext);
            Reg.CloseKey;
          end;
          if B then
            Reg.OpenKey('\PhotoDB.' + Exts[I].Ext + '\Shell\PhotoDBView', True)
          else
            Reg.OpenKey('\' + S + '\Shell\PhotoDBView', True);
          Reg.WriteString('', TA('View with PhotoDB', 'System'));
          Reg.CloseKey;
          if B then
            Reg.OpenKey('\PhotoDB.' + Exts[I].Ext + '\Shell\PhotoDBView\Command', True)
          else
            Reg.OpenKey('\' + S + '\Shell\PhotoDBView\Command', True);
          Reg.WriteString('', Format('"%s" "%1"', [Filename]));
          if B then
          begin
            Reg.OpenKey('\PhotoDB.' + Exts[I].Ext + '\DefaultIcon', True);
            Reg.WriteString('', Filename + ',0');
          end;
          Reg.CloseKey;
        end;
    end;
  end;
  Reg.Free;
  Result := True;
end;

function ExtUnInstallApplicationW: Boolean;
{var
  I, J: Integer;
  Reg: TRegistry;
  S: string;
  PrExt: Boolean; }
begin
 {  Result := False;
  Reg := TRegistry.Create;
  Reg.RootKey := Windows.HKEY_CLASSES_ROOT;
 for I := 1 to Length(SupportedExt) do
  begin
    if SupportedExt[I] = '|' then
      for J := I to Length(SupportedExt) do
      begin
        if SupportedExt[J] = '|' then
          if (J - I - 1 > 0) and (I + 1 < Length(SupportedExt)) then
            if (AnsiLowerCase(Copy(SupportedExt, I + 1, J - I - 1)) <> '') then
            begin
              Reg.OpenKey('\.' + Copy(SupportedExt, I + 1, J - I - 1), True);
              S := Reg.ReadString('');
              Reg.CloseKey;
              if AnsiLowerCase(S) = AnsiLowerCase('PhotoDB.' + Copy(SupportedExt, I + 1, J - I - 1)) then
                PrExt := True
              else
                PrExt := False;
              if PrExt then
                Reg.DeleteKey('\' + S);
              Reg.DeleteKey('\' + S + '\Shell\PhotoDBView\Command');
              Reg.DeleteKey('\' + S + '\Shell\PhotoDBView');
              Reg.OpenKey('\.' + Copy(SupportedExt, I + 1, J - I - 1), True);
              S := Reg.ReadString('PhotoDB_PreviousAssociation');
              Reg.CloseKey;
              if S <> '' then
              begin
                Reg.OpenKey('\.' + Copy(SupportedExt, I + 1, J - I - 1), True);
                Reg.DeleteValue('PhotoDB_PreviousAssociation');
                Reg.WriteString('', S);
                Reg.CloseKey;
              end
              else
              begin
                if PrExt then
                  Reg.DeleteKey('\.' + Copy(SupportedExt, I + 1, J - I - 1));
              end;
              Break;
            end;
      end;
  end;
  Reg.Free;          }
  Result := True;
end;

function ExtInstallApplication(Filename: string): Boolean;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  Result := True;
  try
    Reg.Rootkey := Windows.HKEY_CLASSES_ROOT;
    Reg.OpenKey('\Directory\Shell\PhDBBrowse', True);
    Reg.Writestring('', TA('Browse with PhotoDB', 'System'));
    Reg.CloseKey;
    Reg.OpenKey('\Directory\Shell\PhDBBrowse\Command', True);
    Reg.Writestring('', Format('"%s" "/EXPLORER" "%1"', [Filename]));
  except
    on E: Exception do
    begin
      EventLog(':ExtInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;
  Reg.Free;
  Reg := Tregistry.Create;
  try
    Reg.Rootkey := Windows.HKEY_CLASSES_ROOT;
    Reg.OpenKey('\Drive\Shell\PhDBBrowse', True);
    Reg.Writestring('', TA('Browse with PhotoDB', 'System'));
    Reg.CloseKey;
    Reg.OpenKey('\Drive\Shell\PhDBBrowse\Command', True);
    Reg.Writestring('', Format('"%s" "/EXPLORER" "%1"', [Filename]));
  except
    on E: Exception do
    begin
      EventLog(':ExtInstallApplication() throw exception: ' + E.message);
      Result := False;
    end;
  end;
  Reg.Free;
end;

end.
