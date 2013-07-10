unit uFormMoveFilesProgress;

interface

uses
  Generics.Collections,
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.AppEvnts,
  Vcl.Themes,

  Dmitry.Controls.Base,
  Dmitry.Controls.LoadingSign,

  uDBForm,
  uMemory,
  uW7TaskBar,
  uVistaFuncs;

type
  TProgressOption = class(TObject)
  private
    FName: string;
    FDisplayName: string;
    FValue: string;
    FIsImportant: Boolean;
    FIsVisible: Boolean;
  public
    constructor Create;
    function SetName(Value: string): TProgressOption;
    function SetDisplayName(Value: string): TProgressOption;
    function SetValue(Value: string): TProgressOption;
    function SetImportant(Value: Boolean): TProgressOption;
    function SetVisible(Value: Boolean): TProgressOption;

    property Name: string read FName;
    property Value: string read FValue write FValue;
    property IsImportant: Boolean read FIsImportant write FIsImportant;
    property DisplayName: string read FDisplayName write FDisplayName;
    property IsVisible: Boolean read FIsVisible write FIsVisible;
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
    TmUpdate: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure TmUpdateTimer(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    FOptions: TProgressOptions;
    FW7TaskBar: ITaskbarList3;
    FProgressMessage: Cardinal;
    FProgressValue: Int64;
    FTitle: string;
    FIsError: Boolean;
    FIsCalculating: Boolean;
    FProgressMax: Int64;
    FIsCanceled: Boolean;
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
    procedure UpdateOptions(Full: Boolean);
    procedure RefreshOptionList;
    property Title: string read GetTitle write SetTitle;
    property Options: TProgressOptions read FOptions;
    property ProgressMax: Int64 read FProgressMax write SetProgressMax;
    property ProgressValue: Int64 read FProgressValue write SetProgressValue;
    property IsCalculating: Boolean read FIsCalculating write SetIsCalculating;
    property IsError: Boolean read FIsError write SetIsError;
    property IsCanceled: Boolean read FIsCanceled;
  end;

implementation

uses
  FormManegerUnit;

{$R *.dfm}

{ TProgressOption }

constructor TProgressOption.Create;
begin
  FIsVisible := True;
end;

function TProgressOption.SetDisplayName(Value: string): TProgressOption;
begin
  FDisplayName := Value;
  Result := Self;
end;

function TProgressOption.SetImportant(Value: Boolean): TProgressOption;
begin
  FIsImportant := Value;
  Result := Self;
end;

function TProgressOption.SetName(Value: string): TProgressOption;
begin
  FName := Value;
  Result := Self;
end;

function TProgressOption.SetValue(Value: string): TProgressOption;
begin
  FValue := Value;
  Result := Self;
end;

function TProgressOption.SetVisible(Value: Boolean): TProgressOption;
begin
  FIsVisible := Value;
  Result := Self;
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

procedure TFormMoveFilesProgress.BtnCancelClick(Sender: TObject);
begin
  BtnCancel.Enabled := False;
  FIsCanceled := True;
end;

constructor TFormMoveFilesProgress.Create(AOwner: TComponent);
begin
  inherited;
  FOptions := TProgressOptions.Create;
  FIsCanceled := False;
  RegisterMainForm(Self);
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
  UnRegisterMainForm(Self);
  F(FOptions);
  inherited;
end;

procedure TFormMoveFilesProgress.FormCreate(Sender: TObject);
begin
  FProgressMessage := RegisterWindowMessage('PHOTODB_PROGRESS_MOVE');
  PostMessage(Handle, FProgressMessage, 0, 0);
  LoadLanguage;
end;

procedure TFormMoveFilesProgress.FormResize(Sender: TObject);
begin
  if TStyleManager.IsCustomStyleActive then
    Repaint;
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
  FTitle := Value;
end;

procedure TFormMoveFilesProgress.TmUpdateTimer(Sender: TObject);
begin
  UpdateOptions(True);
end;

procedure TFormMoveFilesProgress.RefreshOptionList;
const
  PaddingTop = 7;
var
  I: Integer;
  L: TLabel;
  PaddingLeft, Top, NameWidth: Integer;
  PO: TProgressOption;
begin
  PaddingLeft := PbMain.Left;

  for I := PnInfo.ControlCount - 1 downto 0 do
    if PnInfo.Controls[I] is TLabel then
      PnInfo.Controls[I].Free;

  Top := PaddingTop;
  NameWidth := 10;
  for I := 0 to FOptions.Count - 1 do
  begin
    PO := FOptions.GetItemByIndex(I);
    if not PO.IsVisible then
      Continue;

    L := TLabel.Create(Self);
    L.Parent := PnInfo;
    L.Top := Top;
    L.Left := PaddingLeft;
    L.Font.Size := 9;
    L.Caption := PO.DisplayName + ':';
    if NameWidth < L.Width then
      NameWidth := L.Width;

    Top := Top + 3 + L.Height;
  end;

  Top := PaddingTop;
  for I := 0 to FOptions.Count - 1 do
  begin
    PO := FOptions.GetItemByIndex(I);
    if not PO.IsVisible then
      Continue;

    L := TLabel.Create(Self);
    L.Parent := PnInfo;
    L.Top := Top;
    L.Left := NameWidth + 20;
    L.Font.Size := 9;
    L.Tag := NativeInt(PO);
    if PO.IsImportant then
      L.Font.Style := [fsBold];

    Top := Top + 3 + L.Height;
  end;

  ClientHeight := 120 + Top;
  Constraints.MaxHeight := Height;
  Constraints.MinHeight := Height;

  UpdateOptions(True);
end;

procedure TFormMoveFilesProgress.UpdateOptions(Full: Boolean);
var
  I: Integer;
  L: TLabel;
begin
  if Full then
  begin
    for I := PnInfo.ControlCount - 1 downto 0 do
      if PnInfo.Controls[I] is TLabel then
      begin
        L := TLabel(PnInfo.Controls[I]);
        if L.Tag <> 0 then
          L.Caption := TProgressOption(L.Tag).Value;
      end;

    LbTitle.Caption := FTitle;
    LbTitle.Repaint;
    Caption := FTitle;
  end;

  if IsCalculating then
  begin
    PbMain.Style := pbstMarquee;
    if FW7TaskBar <> nil then
      FW7TaskBar.SetProgressState(Handle, TBPF_INDETERMINATE);
  end else
  begin
    PbMain.Style := pbstNormal;
    if FW7TaskBar <> nil then
      FW7TaskBar.SetProgressState(Handle, TBPF_NORMAL);
  end;

  if IsError then
  begin
    PbMain.State := pbsError;
    if FW7TaskBar <> nil then
      FW7TaskBar.SetProgressState(Handle, TBPF_ERROR);
  end else
  begin
    PbMain.State := pbsNormal;
    if FW7TaskBar <> nil then
      FW7TaskBar.SetProgressState(Handle, TBPF_NORMAL);
  end;

  if ProgressValue > ProgressMax then
    ProgressValue := ProgressMax;

  PbMain.Max := MAXWORD;
  if ProgressMax > 0 then
    PbMain.Position := Round(MAXWORD * 1.0 * ProgressValue / ProgressMax)
  else
    PbMain.Position := 0;
  if FW7TaskBar <> nil then
    FW7TaskBar.SetProgressValue(Handle, ProgressValue, ProgressMax);

  if TStyleManager.IsCustomStyleActive then
    Repaint;
end;

end.
