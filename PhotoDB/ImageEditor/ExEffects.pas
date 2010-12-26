unit ExEffects;

interface

uses
  Effects, StdCtrls, Graphics, GraphicsBaseTypes, Forms, StrUtils, SysUtils,
  uEditorTypes, uTranslate;

type
  TExEffect = class(TObject)
  private
    { Private declarations }
    FSetImageProc: TSetPointerToNewImage;
    FEditor: TImageEditorForm;
    procedure SetSetImageProc(const Value: TSetPointerToNewImage);
    procedure SetEditor(const Value: TImageEditorForm);
  protected
    function L(StringToTranslate : string) : string;
  public
    { Public declarations }
    constructor Create; virtual;
    destructor Destroy; override;
    class function ID: string; virtual;
    function GetProperties: string; virtual;
    procedure SetProperties(Properties: string); virtual;
    function Execute(S, D: TBitmap; Panel: TGroupBox; AMakeImage: Boolean): Boolean; virtual;
    function GetName: string; virtual;
    function GetBestValue: Integer; virtual;
    procedure GetPreview(S, D: TBitmap); virtual;
    property SetImageProc: TSetPointerToNewImage read FSetImageProc write SetSetImageProc;
    property Editor: TImageEditorForm read FEditor write SetEditor;
    function GetValueByName(Properties, name: string): string;
    function GetIntValueByName(Properties, name: string; default: Integer): Integer;
    function GetBoolValueByName(Properties, name: string; default: Boolean): Boolean;
  end;

type
  TExEffectsClass = class of TExEffect;
  TExEffects = array of TExEffectsClass;

implementation

uses ImEditor, Variants;

{ TExEffect }

function TExEffect.GetValueByName(Properties, name: string): string;
var
  Str: string;
  Pbegin, Pend: Integer;
begin
  Pbegin := Pos('[', Properties);
  Pend := PosEx(';]', Properties, Pbegin);
  Str := Copy(Properties, Pbegin, Pend - Pbegin + 1);
  Pbegin := Pos(name + '=', Str) + Length(name) + 1;
  Pend := PosEx(';', Str, Pbegin);
  Result := Copy(Str, Pbegin, Pend - Pbegin);
end;

constructor TExEffect.Create;
begin
end;

function TExEffect.GetBestValue: Integer;
begin
  Result := -1;
end;

function TExEffect.Execute(S, D: TBitmap; Panel: TGroupBox; AMakeImage: Boolean): Boolean;
begin
  Result := False;
end;

function TExEffect.GetName: string;
begin
  Result := '';
end;

procedure TExEffect.GetPreview(S, D: TBitmap);
begin
  D.Assign(S);
end;

procedure TExEffect.SetSetImageProc(const Value: TSetPointerToNewImage);
begin
  FSetImageProc := Value;
end;

procedure TExEffect.SetEditor(const Value: TImageEditorForm);
begin
  FEditor := Value;
end;

destructor TExEffect.Destroy;
begin
  if EditorsManager.IsEditor(FEditor) then
    (FEditor as TImageEditor).StatusBar1.Panels[0].Text := '';
  inherited;
end;

class function TExEffect.ID: string;
begin
  Result := '{005943F7-CD7E-4B79-8D1A-0489C47C85A0}';
end;

function TExEffect.L(StringToTranslate: string): string;
begin
  Result := TTranslateManager.Instance.TA(StringToTranslate, 'Effects')
end;

function TExEffect.GetProperties: string;
begin
  Result := '';
end;

procedure TExEffect.SetProperties(Properties: string);
begin
//
end;

function TExEffect.GetBoolValueByName(Properties, name: string; Default: Boolean): Boolean;
var
  Val: string;
begin
  Val := AnsiUpperCase(GetValueByName(Properties, name));
  if Val = '' then
    Result := Default
  else
    Result := Val = 'TRUE';
end;

function TExEffect.GetIntValueByName(Properties, name: string; Default: Integer): Integer;
begin
  Result := StrToIntDef(GetValueByName(Properties, name), Default);
end;

end.
