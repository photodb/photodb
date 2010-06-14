unit ImgCtrlsReg;

interface

uses
  BitmapContainers,
  ScrollingImage,
  ScrollingImageAddons,
  TexturePanel;

procedure Register;

implementation

{$R *.res}

uses Windows, SysUtils, Consts, Classes, DesignIntf, DesignEditors, VCLEditors;

{ TImgCtrlsStretchModeProperty }

type
  TImgCtrlsStretchModeProperty = class(TIntegerProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;

const
  STRETCH_MODE: array[1..MAXSTRETCHBLTMODE] of PChar =
    ('BLACKONWHITE',
     'WHITEONBLACK',
     'COLORONCOLOR',
     'HALFTONE');  

function TImgCtrlsStretchModeProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList];
end;

function TImgCtrlsStretchModeProperty.GetValue: string;
var
  Value: Integer;
begin
  Value := GetOrdValue;

  if (Value >= 1) and (Value <= MAXSTRETCHBLTMODE) then
    Result := STRETCH_MODE[Value]
  else
    Result := '';
end;

procedure TImgCtrlsStretchModeProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
begin
  for I := Low(STRETCH_MODE) to High(STRETCH_MODE) do Proc(STRETCH_MODE[I]);
end;

procedure TImgCtrlsStretchModeProperty.SetValue(const Value: string);
var
  I: Integer;
begin
  for I := Low(STRETCH_MODE) to High(STRETCH_MODE) do
    if AnsiCompareText(Value, STRETCH_MODE[I]) = 0 then
    begin
      SetOrdValue(I);
      Exit;
    end;
  raise Exception.Create(SInvalidNumber);
end;

procedure Register;
begin
  RegisterComponents(
    'Image Controls',
    [TBitmapContainer,
     TBitmapPanel,

     TScrollingImage,
     TFastScrollingImage,
     TSBScrollingImage,
     
     TScrollingImageNavigator,

     TTexturePanel]);

  RegisterPropertyEditor(TypeInfo(TStretchMode), TCustomScrollingImage, '', TImgCtrlsStretchModeProperty);     
end;

end.