unit uDBForm;

interface

uses
  Forms, Classes, uTranslate, Graphics, SyncObjs,
  uVistaFuncs, uMemory;

type
  TDBForm = class(TForm)
  private
  protected
    function GetFormID : string; virtual; abstract;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    function L(StringToTranslate : string) : string; overload;
    function L(StringToTranslate : string; Scope : string) : string; overload;
    procedure BeginTranslate;
    procedure EndTranslate;
  end;

type
  TFormCollection = class(TObject)
  private
    FSync : TCriticalSection;
    FForms : TList;
    constructor Create;
  public
    destructor Destroy; override;
    class function Instance : TFormCollection;
    procedure UnRegisterForm(Form: TDBForm);
    procedure RegisterForm(Form: TDBForm);
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
  TFormCollection.Instance.RegisterForm(Self);
end;

destructor TDBForm.Destroy;
begin
  TFormCollection.Instance.UnRegisterForm(Self);
  inherited;
end;

procedure TDBForm.EndTranslate;
begin
  TTranslateManager.Instance.EndTranslate;
end;

function TDBForm.L(StringToTranslate : string; Scope : string) : string;
begin
  Result := TTranslateManager.Instance.SmartTranslate(StringToTranslate, Scope)
end;

function TDBForm.L(StringToTranslate : string) : string;
begin
  Result := TTranslateManager.Instance.SmartTranslate(StringToTranslate, GetFormID)
end;


var
  FInstance : TFormCollection = nil;

{ TFormManager }

constructor TFormCollection.Create;
begin
  FSync := TCriticalSection.Create;
  FForms := TList.Create;
end;

destructor TFormCollection.Destroy;
begin
  F(FSync);
  F(FForms);
  inherited;
end;

class function TFormCollection.Instance: TFormCollection;
begin
  if FInstance = nil then
    FInstance := TFormCollection.Create;

  Result := FInstance;
end;

procedure TFormCollection.RegisterForm(Form: TDBForm);
begin
  if FForms.IndexOf(Form) > -1 then
    Exit;

  FForms.Add(Form);

  if IsWindowsVista then
    SetVistaFonts(Form);
end;

procedure TFormCollection.UnRegisterForm(Form: TDBForm);
begin
  FForms.Remove(Form);
end;

initialization

finalization
  F(FInstance);

end.

