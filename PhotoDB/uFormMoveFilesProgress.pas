unit uFormMoveFilesProgress;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  LoadingSign,
  Vcl.ExtCtrls,
  Generics.Collections,
  uDBForm,
  uMemory,
  uW7TaskBar,
  uVistaFuncs,
  Vcl.AppEvnts;

type
  TProgressOption = class(TObject)
  private
    FName: string;
    FValue: string;
    FIsImportant: Boolean;
    //FImportantValue: string;
    //procedure SetImportantValue(const Value: string);
    procedure SetValue(const Value: string);
    procedure SetIsImportant(const Value: Boolean);
  public
    property Name: string read FName;
    property Value: string read FValue write SetValue;
    property IsImportant: Boolean read FIsImportant write SetIsImportant;
    //property ImportantValue: string read FImportantValue write SetImportantValue;
  end;

  TProgressOptions = class(TObject)
  private
    FList: TList<TProgressOption>;
    function GetItem(Index: string): TProgressOption;
    function GetCount: Integer;
    function GetItemByIndex(Index: Integer): TProgressOption;
  public
    constructor Create;
    destructor Destroy; override;
    property Items[Index: string]: TProgressOption read GetItem; default;
    property Count: Integer read GetCount;
  end;

type
  TFormMoveFilesProgress = class(TDBForm)
    BtnCancel: TButton;
    BtnPause: TButton;
    PnInfo: TPanel;
    PbMain: TProgressBar;
    PnCaption: TPanel;
    LbTitle: TLabel;
    LoadingSign1: TLoadingSign;
    AeMain: TApplicationEvents;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
  private
    FOptions: TProgressOptions;
    FW7TaskBar: ITaskbarList3;
    FProgressMessage: Cardinal;
    FProgressValue: Int64;
    FIsError: Boolean;
    FIsCalculating: Boolean;
    FProgressMax: Int64;
    function GetTitle: string;
    procedure SetTitle(const Value: string);
    procedure SetIsCalculating(const Value: Boolean);
    procedure SetIsError(const Value: Boolean);
    procedure SetProgressMax(const Value: Int64);
    procedure SetProgressValue(const Value: Int64);
    { Private declarations }
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID: string; override;
    procedure LoadLanguage;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateOptions;
    procedure RefreshOptionList;
    property Title: string read GetTitle write SetTitle;
    property Options: TProgressOptions read FOptions;
    property ProgressMax: Int64 read FProgressMax write SetProgressMax;
    property ProgressValue: Int64 read FProgressValue write SetProgressValue;
    property IsCalculating: Boolean read FIsCalculating write SetIsCalculating;
    property IsError: Boolean read FIsError write SetIsError;
  end;

var
  FormMoveFilesProgress: TFormMoveFilesProgress;

implementation

{$R *.dfm}

{ TProgressOption }

{procedure TProgressOption.SetImportantValue(const Value: string);
begin
  FImportantValue := Value;
end;}

procedure TProgressOption.SetIsImportant(const Value: Boolean);
begin
  FIsImportant := Value;
end;

procedure TProgressOption.SetValue(const Value: string);
begin
  FValue := Value;
end;

{ TProgressOptions }

constructor TProgressOptions.Create;
begin
  FList := TList<TProgressOption>.Create;
end;

destructor TProgressOptions.Destroy;
begin
  FreeList(FList);
  inherited;
end;

function TProgressOptions.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TProgressOptions.GetItem(Index: string): TProgressOption;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    if AnsiLowerCase(FList[I].Name) = AnsiLowerCase(Index) then
    begin
      Result := FList[I];
      Exit;
    end;

  Result := TProgressOption.Create;
  FList.Add(Result);
  Result.FName := Index;
end;

function TProgressOptions.GetItemByIndex(Index: Integer): TProgressOption;
begin
  Result := FList[Index];
end;

{ TFormMoveFilesProgress }

procedure TFormMoveFilesProgress.AeMainMessage(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if Msg.message = FProgressMessage then
    FW7TaskBar := CreateTaskBarInstance;
end;

constructor TFormMoveFilesProgress.Create(AOwner: TComponent);
begin
  inherited;
  FOptions := TProgressOptions.Create;
end;

procedure TFormMoveFilesProgress.CreateParams(var Params: TCreateParams);
begin
  Inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

destructor TFormMoveFilesProgress.Destroy;
begin
  F(FOptions);
  inherited;
end;

procedure TFormMoveFilesProgress.FormCreate(Sender: TObject);
begin
  FProgressMessage := RegisterWindowMessage('PHOTODB_PROGRESS_MOVE');
  PostMessage(Handle, FProgressMessage, 0, 0);
  LoadLanguage;
end;

function TFormMoveFilesProgress.GetFormID: string;
begin
  Result := 'FileMoveDialog';
end;

function TFormMoveFilesProgress.GetTitle: string;
begin
  Result := LbTitle.Caption;
end;

procedure TFormMoveFilesProgress.LoadLanguage;
begin
  BeginTranslate;
  try
    BtnCancel.Caption := L('Cancel');
    BtnPause.Caption := L('Pause');
  finally
    EndTranslate;
  end;
end;

procedure TFormMoveFilesProgress.SetIsCalculating(const Value: Boolean);
begin
  FIsCalculating := Value;
end;

procedure TFormMoveFilesProgress.SetIsError(const Value: Boolean);
begin
  FIsError := Value;
end;

procedure TFormMoveFilesProgress.SetProgressMax(const Value: Int64);
begin
  FProgressMax := Value;
end;

procedure TFormMoveFilesProgress.SetProgressValue(const Value: Int64);
begin
  FProgressValue := Value;
end;

procedure TFormMoveFilesProgress.SetTitle(const Value: string);
begin
  LbTitle.Caption := Value;
  Caption := Value;
end;

procedure TFormMoveFilesProgress.RefreshOptionList;
const
  PaddingTop = 7;
var
  I: Integer;
  L: TLabel;
  PaddingLeft, Top, NameWidth: Integer;
begin
  PaddingLeft := PbMain.Left;

  for I := PnInfo.ControlCount - 1 downto 0 do
    if PnInfo.Controls[I] is TLabel then
      PnInfo.Controls[I].Free;

  Top := PaddingTop;
  NameWidth := 10;
  for I := 0 to FOptions.Count - 1 do
  begin
    L := TLabel.Create(Self);
    L.Parent := PnInfo;
    L.Top := Top;
    L.Left := PaddingLeft;
    L.Font.Size := 9;
    L.Caption := FOptions.GetItemByIndex(I).Name + ':';
    if NameWidth < L.Width then
      NameWidth := L.Width;

    Top := Top + 3 + L.Height;
  end;

  Top := PaddingTop;
  for I := 0 to FOptions.Count - 1 do
  begin
    L := TLabel.Create(Self);
    L.Parent := PnInfo;
    L.Top := Top;
    L.Left := NameWidth + 20;
    L.Font.Size := 9;
    L.Caption := FOptions.GetItemByIndex(I).Value;
    L.Tag := NativeInt(FOptions.GetItemByIndex(I));
    if FOptions.GetItemByIndex(I).IsImportant then
      L.Font.Style := [fsBold];

    Top := Top + 3 + L.Height;
  end;

  ClientHeight := 120 + Top;
  Constraints.MaxHeight := Height;
  Constraints.MinHeight := Height;
end;

procedure TFormMoveFilesProgress.UpdateOptions;
var
  I: Integer;
  L: TLabel;
begin
  for I := PnInfo.ControlCount - 1 downto 0 do
    if PnInfo.Controls[I] is TLabel then
    begin
      L := TLabel(PnInfo.Controls[I]);
      if L.Tag > 0 then
        L.Caption := TProgressOption(L.Tag).Value;
    end;
end;

end.
