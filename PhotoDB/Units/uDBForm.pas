unit uDBForm;

interface

uses
  Forms, Classes, uTranslate,
  {$IFDEF PHOTODB}
  Dolphin_db,
  {$ENDIF}
  Graphics;

type
  TDBForm = class(TForm)
  private
  protected
    function GetFormID : string; virtual; abstract;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    function L(StringToTranslate : string) : string;
    procedure BeginTranslate;
    procedure EndTranslate;
  end;

implementation

{ TDBForm }

procedure TDBForm.BeginTranslate;
begin
  TTranslateManager.Instance.BeginTranslate;
end;

constructor TDBForm.Create(AOwner: TComponent);
begin
  inherited;
  {$IFDEF PHOTODB}
  DBKernel.RegisterForm(Self);
  {$ENDIF}
end;

destructor TDBForm.Destroy;
begin
  {$IFDEF PHOTODB}
  DBKernel.UnRegisterForm(Self);
  {$ENDIF}
  inherited;
end;

procedure TDBForm.EndTranslate;
begin
  TTranslateManager.Instance.EndTranslate;
end;

function TDBForm.L(StringToTranslate : string) : string;
begin
  Result := TTranslateManager.Instance.SmartTranslate(StringToTranslate, GetFormID)
end;

end.

