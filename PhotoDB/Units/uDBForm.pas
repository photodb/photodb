unit uDBForm;

interface

uses
  Forms, Classes, uTranslate;

type
  TDBForm = class(TForm)
  private
    FIsTranslating: Boolean;
  protected
    function GetFormID : string; virtual; abstract;
  public
    constructor Create(AOwner : TComponent); override;
    function L(StringToTranslate : string) : string;
    procedure BeginTranslate;
    procedure EndTranslate;
  end;

implementation

{ TDBForm }

procedure TDBForm.BeginTranslate;
begin
  TTranslateManager.Instance.BeginTranslate;
  FIsTranslating := True;
end;

constructor TDBForm.Create(AOwner: TComponent);
begin
  FIsTranslating := False;
  inherited;
end;

procedure TDBForm.EndTranslate;
begin
  FIsTranslating := False;
  TTranslateManager.Instance.EndTranslate;
end;

function TDBForm.L(StringToTranslate: string): string;
begin
  if FIsTranslating then
    Result := TTranslateManager.Instance.Translate(StringToTranslate, GetFormID)
  else
    Result := TTranslateManager.Instance.TA(StringToTranslate, GetFormID);
end;

end.
