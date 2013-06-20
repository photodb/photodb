unit uUninstallUtils;

interface

uses
  System.Classes,
  System.Win.Registry,
  Winapi.Windows,

  Dmitry.Utils.Files,

  uAppUtils,
  uMemory,
  uConstants,
  uConfiguration,
  uDBConnection;

procedure CleanUpUserSettings;

implementation

procedure CleanUpUserSettings;
var
  Reg: TRegistry;
  I: Integer;
  Dbs: TStrings;
  DBKeyName, FileName: string;
begin
  //delete user cache
  DeleteDirectoryWithFiles(GetAppDataDirectory);

  if GetParamStrDBBool('/uninstall_collections') then
  begin
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey(RegRoot + cDatabasesSubKey, False) then
      begin
        Dbs := TStringList.Create;
        try
          Reg.GetKeyNames(Dbs);
          Reg.CloseKey;
          for I := 0 to Dbs.Count - 1 do
          begin
            DBKeyName := RegRoot + cDatabasesSubKey + '\' + Dbs[I];
            if Reg.OpenKey(DBKeyName, False) then
            begin
              FileName := Reg.ReadString('FileName');
              TryRemoveConnection(FileName, True);
              SilentDeleteFile(0, FileName, True);
            end;
          end;
        finally
          F(Dbs);
        end;
      end;
    finally
      F(Reg);
    end;
  end;

  if GetParamStrDBBool('/uninstall_settings') then
  begin
    Reg := TRegistry.Create;
    try
      Reg.RootKey := Winapi.Windows.HKEY_CURRENT_USER;
      Reg.DeleteKey(RegRoot);
    finally
      F(Reg);
    end;
  end;
end;

end.
