unit uFormInterfaces;

interface

uses
  uMemory,
  Generics.Collections,
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  Winapi.Windows,
  Vcl.Graphics,
  Vcl.Forms,
  uRuntime,
  UnitDBDeclare,
  uDBPopupMenuInfo;

type
  IFormInterface = interface
    ['{24769E47-FE80-4FF7-81CC-F8E6C8AA77EC}']
    procedure Show;
  end;

  IViewerForm = interface(IFormInterface)
    ['{951665C9-EDA5-44BD-B833-B5543B58DF04}']
    function ShowImage(Sender: TObject; FileName: string): Boolean;
    function ShowImages(Sender: TObject; Info: TDBPopupMenuInfo): Boolean;
    function ShowImageInDirectory(FileName: string; ShowPrivate: Boolean): Boolean;
    function ShowImageInDirectoryEx(FileName: string): Boolean;
    function NextImage: Boolean;
    function PreviousImage: Boolean;
    function Pause: Boolean;
    function TogglePause: Boolean;
    function CloseActiveView: Boolean;

    function CurrentFullImage: TBitmap;
    procedure DrawTo(Canvas: TCanvas; X, Y: Integer);
    function ShowPopup(X, Y: Integer): Boolean;

    function GetImagesCount: Integer;
    function GetIsFullScreenNow: Boolean;
    function GetIsSlideShowNow: Boolean;
    function GetImageIndex: Integer;
    procedure SetImageIndex(Value: Integer);
    function GetImageByIndex(Index: Integer): TDBPopupMenuInfoRecord;
    procedure UpdateImageInfo(Info: TDBPopupMenuInfoRecord);

    property ImagesCount: Integer read GetImagesCount;
    property ImageIndex: Integer read GetImageIndex write SetImageIndex;
    property IsFullScreenNow: Boolean read GetIsFullScreenNow;
    property IsSlideShowNow: Boolean read GetIsSlideShowNow;
    property Images[Index: Integer]: TDBPopupMenuInfoRecord read GetImageByIndex;
  end;

  IAboutForm = interface(IFormInterface)
    ['{319D1068-3734-4229-9264-8922123F31C0}']
    procedure Execute;
  end;

  IActivationForm = interface(IFormInterface)
    ['{B2742B2F-4210-4A48-B45E-54AEAD63062F}']
    procedure Execute;
  end;

type
  TFormInterfaces = class(TObject)
  private
    FFormInterfaces: TDictionary<TGUID, TComponentClass>;
    FFormInstances: TDictionary<TGUID, TForm>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterFormInterface(Intf: TGUID; FormClass: TComponentClass);
    function GetForm<T: IInterface>(): T;
    function GetSingleForm<T: IInterface>(CreateNew: Boolean): T;
    function GetSingleFormInstance<TFormClass: TForm>(Intf: TGUID; CreateNew: Boolean): TFormClass;
    procedure RemoveSingleInstance(FormInstance: TForm);
  end;

function FormInterfaces: TFormInterfaces;

function Viewer: IViewerForm;
function CurrentViewer: IViewerForm;
function AboutForm: IAboutForm;
function ActivationForm: IActivationForm;

implementation

var
  FFormInterfaces: TFormInterfaces = nil;

function FormInterfaces: TFormInterfaces;
begin
  if FFormInterfaces = nil then
    FFormInterfaces := TFormInterfaces.Create;

  Result := FFormInterfaces;
end;

function Viewer: IViewerForm;
begin
  Result := FormInterfaces.GetSingleForm<IViewerForm>(True);
end;

function CurrentViewer: IViewerForm;
begin
  Result := FormInterfaces.GetSingleForm<IViewerForm>(False);
end;

function AboutForm: IAboutForm;
begin
  Result := FormInterfaces.GetSingleForm<IAboutForm>(True);
end;

function ActivationForm: IActivationForm;
begin
  Result := FormInterfaces.GetSingleForm<IActivationForm>(True);
end;

{ TFormInterfaces }

constructor TFormInterfaces.Create;
begin
  FFormInterfaces := TDictionary<TGUID, TComponentClass>.Create;
  FFormInstances := TDictionary<TGUID, TForm>.Create;
end;

destructor TFormInterfaces.Destroy;
begin
  F(FFormInterfaces);
  F(FFormInstances);
  inherited;
end;

function TFormInterfaces.GetForm<T>: T;
var
  G: TGUID;
begin
  G := GetTypeData(TypeInfo(T))^.Guid;
  Application.CreateForm(FFormInterfaces[G], Result);
end;

function TFormInterfaces.GetSingleFormInstance<TFormClass>(Intf: TGUID; CreateNew: Boolean): TFormClass;
begin
  if FFormInstances.ContainsKey(Intf) then
    Exit(FFormInstances[Intf] as TFormClass);

  if not CreateNew then
    Exit(nil);

  if GetCurrentThreadId <> MainThreadID then
    raise Exception.Create('Can''t create form using child thread!');

  Application.CreateForm(FFormInterfaces[Intf], Result);
  FFormInstances.Add(Intf, Result);
end;

function TFormInterfaces.GetSingleForm<T>(CreateNew: Boolean): T;
var
  G: TGUID;
  Form: TForm;
begin
  G := GetTypeData(TypeInfo(T))^.Guid;

  if not FFormInstances.ContainsKey(G) then
  begin
    if not CreateNew then
      Exit(nil);

    if GetCurrentThreadId <> MainThreadID then
      raise Exception.Create('Can''t create form using child thread!');

    Application.CreateForm(FFormInterfaces[G], Form);
    FFormInstances.Add(G, Form);
  end;

  FFormInstances[G].GetInterface(G, Result);
end;

procedure TFormInterfaces.RegisterFormInterface(Intf: TGUID; FormClass: TComponentClass);
begin
  FFormInterfaces.Add(Intf, FormClass);
end;

procedure TFormInterfaces.RemoveSingleInstance(FormInstance: TForm);
var
  Pair: TPair<TGUID, TForm>;
begin
  for Pair in FFormInstances do
    if Pair.Value = FormInstance then
    begin
      FFormInstances.Remove(Pair.Key);
      Break;
    end;
end;

initialization
finalization
  F(FFormInterfaces);

end.
