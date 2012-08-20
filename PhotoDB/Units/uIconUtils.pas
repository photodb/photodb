unit uIconUtils;

interface

uses
  Windows, Graphics, ShellApi, SysUtils;

function ExtractSmallIconByPath(IconPath: string; Big: Boolean = False): HIcon;
function ImageSizeToIconSize16_32_48(ImageSize: Integer): Integer;

implementation

function ImageSizeToIconSize16_32_48(ImageSize: Integer): Integer;
begin
  if ImageSize >= 48 then
    ImageSize := 48
  else if ImageSize >= 32 then
    ImageSize := 32
  else if ImageSize >= 16 then
    ImageSize := 16;

  Result := ImageSize;
end;

function ExtractSmallIconByPath(IconPath: string; Big: Boolean = False): HIcon;
var
  Path, Icon: string;
  IconIndex, I: Integer;
  Ico1, Ico2: HIcon;
begin
  I := Pos(',', IconPath);
  if I = 0 then
    I := Length(IconPath) + 1;
  Path := Copy(IconPath, 1, I - 1);
  Icon := Copy(IconPath, I + 1, Length(IconPath) - I);
  IconIndex := StrToIntDef(Icon, 0);
  Ico1 := 0;

  ExtractIconEx(PWideChar(Path), IconIndex, Ico1, Ico2, 1);

  if Big then
  begin
    Result := Ico1;
    if Ico2 <> 0 then
      DestroyIcon(Ico2);
  end else
  begin
    Result := Ico2;
    if Ico1 <> 0 then
      DestroyIcon(Ico1);
  end;
end;

end.
