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
  Data.DB,
  uRuntime
  {$IFDEF PHOTODB}
  ,UnitDBDeclare,
  uDBPopupMenuInfo
  {$ENDIF}
  ;

type
  IFormInterface = interface
    ['{24769E47-FE80-4FF7-81CC-F8E6C8AA77EC}']
    procedure Show;
  end;

  {$IFDEF PHOTODB}

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

  IOptionsForm = interface(IFormInterface)
    ['{5B8A57BA-3FCB-489C-A849-753BDA0D1356}']
  end;

  IRequestPasswordForm = interface(IFormInterface)
    ['{7710EB12-321A-44B1-B72A-FD238C450ACD}']
    function ForImage(FileName: string): string;
    function ForImageEx(FileName: string; out AskAgain: Boolean): string;
    function ForBlob(DF: TField; FileName: string): string;
    function ForSteganoraphyFile(FileName: string; CRC: Cardinal) : string;
    function ForManyFiles(FileList: TStrings; CRC: Cardinal; var Skip: Boolean): string;
  end;

  IBatchProcessingForm = interface(IFormInterface)
    ['{DEF35564-F0E4-46DD-A323-8FC6ABF19E3D}']
    procedure ExportImages(Owner: TForm; List: TDBPopupMenuInfo);
    procedure ResizeImages(Owner: TForm; List: TDBPopupMenuInfo);
    procedure ConvertImages(Owner: TForm; List: TDBPopupMenuInfo);
    procedure RotateImages(Owner: TForm; List: TDBPopupMenuInfo; DefaultRotate: Integer; StartImmediately: Boolean);
  end;

  IJpegOptionsForm = interface(IFormInterface)
    ['{C1F4BB58-77A8-4AF0-A9FD-196470D5AD7D}']
    procedure Execute(Section: string = '');
  end;

  IImportForm = interface(IFormInterface)
    ['{64D665EF-5407-410D-8B4B-E18CE9F35FC3}']
    procedure FromDevice(DeviceName: string);
    procedure FromDrive(DriveLetter: Char);
    procedure FromFolder(Folder: string);
  end;

  {$ENDIF}

type
  TFormInterfaces = class(TObject)
  private
    FFormInterfaces: TDictionary<TGUID, TComponentClass>;
    FFormInstances: TDictionary<TGUID, TForm>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterFormInterface(Intf: TGUID; FormClass: TComponentClass);
    function CreateForm<T: IInterface>(): T;
    function GetSingleForm<T: IInterface>(CreateNew: Boolean): T;
    function GetSingleFormInstance<TFormClass: TForm>(Intf: TGUID; CreateNew: Boolean): TFormClass;
    procedure RemoveSingleInstance(FormInstance: TForm);
  end;

function FormInterfaces: TFormInterfaces;

{$IFDEF PHOTODB}
function Viewer: IViewerForm;
function CurrentViewer: IViewerForm;
function AboutForm: IAboutForm;
function ActivationForm: IActivationForm;
function OptionsForm: IOptionsForm;
function RequestPasswordForm: IRequestPasswordForm;
function BatchProcessingForm: IBatchProcessingForm;
function JpegOptionsForm: IJpegOptionsForm;
function ImportForm: IImportForm;
{$ENDIF}

implementation

var
  FFormInterfaces: TFormInterfaces = nil;

function FormInterfaces: TFormInterfaces;
begin
  if FFormInterfaces = nil then
    FFormInterfaces := TFormInterfaces.Create;

  Result := FFormInterfaces;
end;

{$IFDEF PHOTODB}
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

function OptionsForm: IOptionsForm;
begin
  Result := FormInterfaces.GetSingleForm<IOptionsForm>(True);
end;

function RequestPasswordForm: IRequestPasswordForm;
begin
  Result := FormInterfaces.CreateForm<IRequestPasswordForm>();
end;

function BatchProcessingForm: IBatchProcessingForm;
begin
  Result := FormInterfaces.CreateForm<IBatchProcessingForm>();
end;

function JpegOptionsForm: IJpegOptionsForm;
begin
  Result := FormInterfaces.GetSingleForm<IJpegOptionsForm>(True);
end;

function ImportForm: IImportForm;
begin
  Result := FormInterfaces.CreateForm<IImportForm>();
end;
{$ENDIF}

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

function TFormInterfaces.CreateForm<T>: T;
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
