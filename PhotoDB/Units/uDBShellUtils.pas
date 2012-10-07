unit uDBShellUtils;

interface

uses
  Winapi.Windows,
  Vcl.Graphics,
  Vcl.Forms,

  Dmitry.Utils.Files,

  acWorkRes,
  UnitDBFileDialogs,

  uResourceUtils,
  uTranslate,
  uShellUtils,
  uMemory,
  uShellIntegration;

function GetIconForFile(Ico: TIcon; out IcoTempName: string; out Language: Integer): Boolean;

implementation

function GetIconForFile(Ico: TIcon; out IcoTempName: string; out Language: Integer): Boolean;
var
  LoadIconDLG: DBOpenDialog;
  FN: string;
  Index: Integer;
  Update: DWORD;

  function FindIconEx(FileName: string; Index: Integer): Boolean;
  var
    ResIcoNameW: PWideChar;
  begin
    Result := False;

    Update := BeginUpdateResourceW(PChar(FileName), False, False);
    if Update = 0 then
      Exit;

    try
      Language := GetIconLanguage(Update, index);
      ResIcoNameW := GetNameIcon(Update, index);
      SaveIconGroupResourceW(Update, ResIcoNameW, Language, PWideChar(IcoTempName))

    finally
      EndUpdateResourceW(Update, True);
    end;
    Result := True;
  end;

begin
  Result := False;
  Ico.Assign(nil);

  LoadIconDLG := DBOpenDialog.Create;
  try
    LoadIconDLG.Filter := TA('All supported formats|*.exe;*.ico;*.dll;*.ocx;*.scr|Icons (*.ico)|*.ico|Executable files (*.exe)|*.exe|Dll files (*.dll)|*.dll', 'System');
    if LoadIconDLG.Execute then
    begin
      FN := LoadIconDLG.FileName;
      if GetEXT(FN) = 'ICO' then
        Ico.LoadFromFile(FN);

      if (GetEXT(FN) = 'EXE') or (GetEXT(FN) = 'DLL') or (GetEXT(FN) = 'OCX') or (GetEXT(FN) = 'SCR') then
      begin
        if ChangeIconDialog(Application.Handle, FN, index) then
        begin
          IcoTempName := uShellUtils.GetTempFileName;
          FindIconEx(FN, Index);
          Ico.LoadFromFile(IcoTempName);
          DeleteFile(PChar(IcoTempName));
        end;
      end;

      Result := not Ico.Empty;
    end;
  finally
    F(LoadIconDLG);
  end;
end;

end.
