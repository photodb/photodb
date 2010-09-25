unit ToolsUnit;

interface

uses ExtCtrls, Classes, Graphics, ImageHistoryUnit, ComCtrls, Menus, Controls,
     GraphicsBaseTypes, Forms, StrUtils, SysUtils;

type TToolsPanelClass = class(TPanel)
  private
    FOnClose: TNotifyEvent;
    FImage: TBitmap;
    FSetImagePointer: TSetPointerToNewImage;
    FCancelTempImage: TCancelTemporaryImage;
    FSetTempImage: TSetPointerToNewImage;
    FImageHistory: TBitmapHistory;
    FProgress: TProgressBar;
    FEditor: TForm;
//    FID : string;
    procedure SetOnClose(const Value: TNotifyEvent);
    procedure SetImage(const Value: TBitmap);
    procedure SetSetImagePointer(const Value: TSetPointerToNewImage);
    procedure SetCancelTempImage(const Value: TCancelTemporaryImage);
    procedure SetSetTempImage(const Value: TSetPointerToNewImage);
    procedure SetImageHistory(const Value: TBitmapHistory);
    procedure SetProgress(const Value: TProgressBar);
    procedure SetEditor(const Value: TForm);
    { Private declarations }
  public
  class function ID: string; virtual;
  function GetProperties : string; virtual; abstract;
  Procedure SetProperties(Properties : String); virtual; abstract;
  function GetValueByName(Properties, Name : string) : string;
  function GetBoolValueByName(Properties, Name : string; Default : boolean = false) : boolean;
  function GetIntValueByName(Properties, Name : string; Default : integer = 0) : integer;
  Procedure ExecuteProperties(Properties : String; OnDone : TNotifyEvent); virtual; abstract;
  constructor Create(AOwner : TComponent); override;
  destructor Destroy; override;
  Procedure ClosePanel; virtual;
  published
  property OnClosePanel : TNotifyEvent read FOnClose write SetOnClose;
  property Image : TBitmap read FImage write SetImage;
  Procedure MakeTransform; virtual;
  property SetImagePointer : TSetPointerToNewImage read FSetImagePointer write SetSetImagePointer;
  property SetTempImage  : TSetPointerToNewImage read FSetTempImage write SetSetTempImage;
  property CancelTempImage : TCancelTemporaryImage read FCancelTempImage write SetCancelTempImage;
  property ImageHistory : TBitmapHistory read FImageHistory write SetImageHistory;
  property Progress : TProgressBar read FProgress write SetProgress;
  property Editor : TForm read FEditor write SetEditor;
    { Public declarations }
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
 FOnClose:=nil;
 FImage:=nil;
 FSetImagePointer:=nil;
 FProgress:=nil;
 Parent:=AOwner as TWinControl;
end;

destructor TToolsPanelClass.Destroy;
begin
 inherited;
end;

function TToolsPanelClass.GetBoolValueByName(Properties, Name: string;
  Default: boolean): boolean;
var
  Val : string;
begin
 Val := GetValueByName(Properties,Name);
 Result:=Default;
 if AnsiUpperCase(Val)='TRUE' then Result:=true;
 if AnsiUpperCase(Val)='FALSE' then Result:=false;
end;

function TToolsPanelClass.GetIntValueByName(Properties, Name: string;
  Default: integer): integer;
var
  Val : string;
begin
 Val := GetValueByName(Properties,Name);
 Result:=StrToIntDef(Val,Default);
end;

function TToolsPanelClass.GetValueByName(Properties, Name: string): string;
var
  str : string;
  pbegin, pend : integer;
begin
 pbegin:=Pos('[',Properties);
 pend:=PosEx(';]',Properties,pbegin);

 str:=Copy(Properties,pbegin,pend-pbegin+1);
 pbegin:=Pos(Name+'=',str)+Length(Name)+1;
 pend:=PosEx(';',str,pbegin);

 Result:=Copy(str,pbegin,pend-pbegin);
 //
end;

class function TToolsPanelClass.ID: string;
begin
 Result:='{73899C26-6964-494E-B5F6-46E65BD50DB7}';
end;

procedure TToolsPanelClass.MakeTransform;
begin
//
end;

procedure TToolsPanelClass.SetCancelTempImage(
  const Value: TCancelTemporaryImage);
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

procedure TToolsPanelClass.SetSetImagePointer(
  const Value: TSetPointerToNewImage);
begin
  FSetImagePointer := Value;
end;

procedure TToolsPanelClass.SetSetTempImage(
  const Value: TSetPointerToNewImage);
begin
  FSetTempImage := Value;
end;

end.
