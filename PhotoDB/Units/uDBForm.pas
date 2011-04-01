unit uDBForm;

interface

uses
  Forms, Classes, uTranslate, Graphics, SyncObjs,
  uVistaFuncs, uMemory, uGOM, uImageSource, SysUtils;

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
    function GetImage(BaseForm: TDBForm; FileName : string; Bitmap : TBitmap; var Width: Integer; var Height: Integer) : Boolean;
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
  GOM.AddObj(Self);
end;

destructor TDBForm.Destroy;
begin
  TFormCollection.Instance.UnRegisterForm(Self);
  GOM.RemoveObj(Self);
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

function TFormCollection.GetImage(BaseForm: TDBForm; FileName: string;
  Bitmap: TBitmap; var Width, Height: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  if GOM.IsObj(BaseForm) and Supports(BaseForm, IImageSource) then
    Result := (BaseForm as IImageSource).GetImage(FileName, Bitmap, Width, Height);

  if Result then
    Exit;

  for I := 0 to FForms.Count - 1 do
  begin
    if Supports(FForms[I], IImageSource) then
      Result := (TDBForm(FForms[I]) as IImageSource).GetImage(FileName, Bitmap, Width, Height);
    if Result then
      Exit;

  end;
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

