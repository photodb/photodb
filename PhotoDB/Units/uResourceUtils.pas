unit uResourceUtils;

interface

uses
  Windows, Classes, Graphics, acWorkRes, UnitDBFileDialogs, uTranslate,
  uFileUtils, uShellIntegration, uConstants, Forms, uShellUtils, uMemory;

function GetRCDATAResourceStream(ResName : string) : TMemoryStream;
function ReplaceIcon(ExeFileName: string; IcoTempNameW: PWideChar): Boolean;
function GetIconForFile(Ico: TIcon; out IcoTempName: string; out Language: Integer): Boolean;
function LoadFileResourceFromStream(Update: dword; Section, Name: PWideChar; MS: TMemoryStream) : Bool;

implementation

function GetRCDATAResourceStream(ResName : string) : TMemoryStream;
var
  MyRes  : Integer;
  MyResP : Pointer;
  MyResS : Integer;
begin
  Result := nil;
  MyRes := FindResource(HInstance, PWideChar(ResName), RT_RCDATA);
  if MyRes <> 0 then begin
    MyResS := SizeOfResource(HInstance,MyRes);
    MyRes := LoadResource(HInstance,MyRes);
    if MyRes <> 0 then begin
      MyResP := LockResource(MyRes);
      if MyResP <> nil then begin
        Result := TMemoryStream.Create;
        with Result do begin
          Write(MyResP^, MyResS);
          Seek(0, soFromBeginning);
        end;
        UnLockResource(MyRes);
      end;
      FreeResource(MyRes);
    end
  end;
end;

function LoadFileResourceFromStream(Update: dword; Section, Name: PWideChar; MS: TMemoryStream) : Bool;
begin
  MS.Seek(0, soFromBeginning);
  Result := UpdateResourceW(Update, Section, Name, 0, MS.Memory, MS.Size);
end;

function GetIconLanguage(Update:Integer; Index: Integer): DWORD;
var
  Ig: TPIconGroup;
  ResIcoNameW: PWideChar;
  I: Integer;
begin
  ResIcoNameW := GetNameIcon(Update, index);
  Result := 0;
  for I := 0 to $FFFFF do
  begin
    if GetIconGroupResourceW(Update, ResIcoNameW, I, Ig) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function ReplaceIcon(ExeFileName: string; IcoTempNameW: PWideChar): Boolean;
var
  Update: DWORD;
  ResIcoNameW: PWideChar;
  IconLanguage: Integer;
begin
  Result := False;
  Update := BeginUpdateResourceW(PChar(ExeFileName), False);
  if Update = 0 then
    Exit;
  try
    ResIcoNameW := GetNameIcon(Update, 0);
    IconLanguage := GetIconLanguage(Update, 0);
    DeleteIconGroupResourceW(Update, ResIcoNameW, IconLanguage);
    Result := LoadIconGroupResourceW(Update, ResIcoNameW, 0, IcoTempNameW);
  finally
    EndUpdateResourceW(Update, False);
  end;
end;

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
