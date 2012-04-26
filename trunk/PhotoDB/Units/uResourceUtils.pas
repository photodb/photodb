unit uResourceUtils;

interface

uses
  Windows,
  Classes,
  Graphics,
  acWorkRes,
  uTranslate,
  uFileUtils,
  uConstants,
  uMemory,
  uTime;

function ReplaceIcon(ExeFileName: string; IcoTempNameW: PWideChar): Boolean;
function LoadFileResourceFromStream(Update: dword; Section, Name: PWideChar; MS: TMemoryStream) : Bool;
function GetIconLanguage(Update:Integer; Index: Integer): DWORD;

implementation

function LoadFileResourceFromStream(Update: dword; Section, Name: PWideChar; MS: TMemoryStream) : Bool;
begin
  TW.I.Check('LoadFileResourceFromStream - START');
  MS.Seek(0, soFromBeginning);
  TW.I.Check('SEEK');
  Result := UpdateResourceW(Update, Section, Name, 0, MS.Memory, MS.Size);
  TW.I.Check('LoadFileResourceFromStream - END');
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


end.
