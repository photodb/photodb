unit ToolsUnit;

interface

uses
  ExtCtrls, Classes, Graphics, ImageHistoryUnit, ComCtrls, Menus, Controls,
  GraphicsBaseTypes, Forms, StrUtils, SysUtils;

type
  TToolsPanelClass = class(TPanel)
  private
    { Private declarations }
    FOnClose: TNotifyEvent;
    FImage: TBitmap;
    FSetImagePointer: TSetPointerToNewImage;
    FCancelTempImage: TCancelTemporaryImage;
    FSetTempImage: TSetPointerToNewImage;
    FImageHistory: TBitmapHistory;
    FProgress: TProgressBar;
    FEditor: TForm;
    procedure SetOnClose(const Value: TNotifyEvent);
    procedure SetImage(const Value: TBitmap);
    procedure SetSetImagePointer(const Value: TSetPointerToNewImage);
    procedure SetCancelTempImage(const Value: TCancelTemporaryImage);
    procedure SetSetTempImage(const Value: TSetPointerToNewImage);
    procedure SetImageHistory(const Value: TBitmapHistory);
    procedure SetProgress(const Value: TProgressBar);
    procedure SetEditor(const Value: TForm);
  public
    { Public declarations }
    class function ID: string; virtual;
    function GetProperties: string; virtual; abstract;
    procedure SetProperties(Properties: string); virtual; abstract;
    function GetValueByName(Properties, name: string): string;
    function GetBoolValueByName(Properties, name: string; default: Boolean = False): Boolean;
    function GetIntValueByName(Properties, name: string; default: Integer = 0): Integer;
    procedure ExecuteProperties(Properties: string; OnDone: TNotifyEvent); virtual; abstract;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClosePanel; virtual;
  published
    property OnClosePanel: TNotifyEvent read FOnClose write SetOnClose;
    property Image: TBitmap read FImage write SetImage;
    procedure MakeTransform; virtual;
    property SetImagePointer: TSetPointerToNewImage read FSetImagePointer write SetSetImagePointer;
    property SetTempImage: TSetPointerToNewImage read FSetTempImage write SetSetTempImage;
    property CancelTempImage: TCancelTemporaryImage read FCancelTempImage write SetCancelTempImage;
    property ImageHistory: TBitmapHistory read FImageHistory write SetImageHistory;
    property Progress: TProgressBar read FProgress write SetProgress;
    property Editor: TForm read FEditor write SetEditor;
  end;

implementation

{ TToolsPanelClass }

procedure TToolsPanelClass.ClosePanel;
begin
  Free;
end;

constructor TToolsPanelClass.Create(AOwner: TComponent);
begin
  inherited;
  FOnClose := nil;
  FImage := nil;
  FSetImagePointer := nil;
  FProgress := nil;
  Parent := AOwner as TWinControl;
end;

destructor TToolsPanelClass.Destroy;
begin
  inherited;
end;

function TToolsPanelClass.GetBoolValueByName(Properties, name: string; default: Boolean): Boolean;
var
  Val: string;
begin
  Val := GetValueByName(Properties, name);
  Result := default;
  Result := AnsiUpperCase(Val) = 'TRUE';
end;

function TToolsPanelClass.GetIntValueByName(Properties, name: string; default: Integer): Integer;
var
  Val: string;
begin
  Val := GetValueByName(Properties, name);
  Result := StrToIntDef(Val, default);
end;

function TToolsPanelClass.GetValueByName(Properties, name: string): string;
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
  //
end;

class function TToolsPanelClass.ID: string;
begin
  Result := '{73899C26-6964-494E-B5F6-46E65BD50DB7}';
end;

procedure TToolsPanelClass.MakeTransform;
begin
  //
end;

procedure TToolsPanelClass.SetCancelTempImage(const Value: TCancelTemporaryImage);
begin
  FCancelTempImage := Value;
end;

procedure TToolsPanelClass.SetEditor(const Value: TForm);
begin
  FEditor := Value;
end;

procedure TToolsPanelClass.SetImage(const Value: TBitmap);
begin
  FImage := Value;
end;

procedure TToolsPanelClass.SetImageHistory(const Value: TBitmapHistory);
begin
  FImageHistory := Value;
end;

procedure TToolsPanelClass.SetOnClose(const Value: TNotifyEvent);
begin
  FOnClose := Value;
end;

procedure TToolsPanelClass.SetProgress(const Value: TProgressBar);
begin
  FProgress := Value;
end;

procedure TToolsPanelClass.SetSetImagePointer(const Value: TSetPointerToNewImage);
begin
  FSetImagePointer := Value;
end;

procedure TToolsPanelClass.SetSetTempImage(const Value: TSetPointerToNewImage);
begin
  FSetTempImage := Value;
end;

end.
