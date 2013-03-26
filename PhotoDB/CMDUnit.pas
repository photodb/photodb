unit CMDUnit;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.AppEvnts,
  Vcl.Clipbrd,

  Dmitry.Utils.System,
  Dmitry.Controls.DmProgress,

  UnitPasswordKeeper,
  UnitDBDeclare,
  UnitDBCommonGraphics,

  uGraphicUtils,
  uConstants,
  uRuntime,
  uShellIntegration,
  uDBBaseTypes,
  uDBForm,
  uMemory;

type
  TCMDForm = class(TDBForm)
    Label1: TLabel;
    Timer1: TTimer;
    ApplicationEvents1: TApplicationEvents;
    PasswordTimer: TTimer;
    InfoListBox: TListBox;
    TempProgress: TDmProgress;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure PasswordTimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure InfoListBoxMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure InfoListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    PasswordKeeper: TPasswordKeeper;
    ItemsData: TList;
    Infos: TStrings;
    FInfo: String;
    FProgressEnabled: Boolean;
    Icons: array of TIcon;
    TopRecords: Integer;
    CurrentWideIndex: Integer;
    LineS: string;
    LineN: Integer;
    PointN: Integer;
    Working: Boolean;
    Recreating: Boolean;
    FCreation: Boolean;
  protected
    function GetFormID: string; override;
  public
    { Public declarations }
    procedure PackPhotoTable;
    procedure OnEnd(Sender: TObject);
    procedure LoadLanguage;
    procedure RestoreTable(FileName: string);
    procedure BackUpTable;
    procedure WriteLine(Sender: TObject; Line: string; Info: Integer);
    procedure WriteLnLine(Sender: TObject; Line: string; Info: Integer);
    procedure LoadToolBarIcons;
    procedure ProgressCallBack(Sender: TObject; var Info: TProgressCallBackInfo);
    procedure SetWideIndex;
  end;

var
  CMDForm: TCMDForm;
  CMD_Command_Break: Boolean = False;

implementation

uses
  UnitPackingTable,
  UnitRestoreTableThread,
  UnitBackUpTableInCMD;

{$R *.dfm}

procedure TCMDForm.FormCreate(Sender: TObject);
begin
  FCreation := True;
  CurrentWideIndex := -1;
  Working := False;
  FProgressEnabled := False;
  FInfo := '';
  PointN := 0;
  DoubleBuffered := True;
  Infos := TStringList.Create;
  ItemsData := TList.Create;
  InfoListBox.ItemHeight := InfoListBox.Canvas.TextHeight('Iy') * 3 + 5;
  InfoListBox.Clear;
  LoadToolBarIcons;

  PasswordKeeper := nil;
  Recreating := False;
  WriteLnLine(Self, Format(L('Welcome to %s!'), [ProductName]), LINE_INFO_INFO);
  WriteLnLine(Self, '', LINE_INFO_GREETING);

  LoadLanguage;
end;

procedure TCMDForm.OnEnd(Sender: TObject);
begin
  Recreating := False;
  Working := False;
  Close;
end;

procedure TCMDForm.PackPhotoTable;
var
  Options: TPackingTableThreadOptions;
begin
  TopRecords := 0;
  WriteLnLine(Self, L('Packing table:'), LINE_INFO_INFO);
  WriteLnLine(Self, '[' + dbname + ']', LINE_INFO_DB);
  WriteLnLine(Self, L('Packing table:'), LINE_INFO_OK);
  SetWideIndex;
  Timer1.Enabled := True;
  Options.OwnerForm := Self;
  Options.FileName := DBName;
  Options.OnEnd := OnEnd;
  Options.WriteLineProc := WriteLine;
  PackingTable.Create(Options);
  Working := True;
  CMDForm.ShowModal;
end;

procedure TCMDForm.Timer1Timer(Sender: TObject);
var
  I: Integer;
  S: string;
begin
  if Working then
  begin
    if PointN = 0 then
    begin
      LineN := InfoListBox.Items.Count;
      LineS := InfoListBox.Items[LineN - 1];
    end;
    Inc(PointN);
    if PointN > 10 then
      PointN := 0;
    S := LineS;
    for I := 1 to PointN do
      S := S + '.';
    InfoListBox.Items[LineN - 1] := S;
  end;
end;

procedure TCMDForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  If Working then
    CanClose := False;

  if Recreating then
    if ID_OK = MessageBoxDB(Handle, L(
        'Do you really want to cancel current action?'), L('Warning'),
      TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
    begin
      CMD_Command_Break := True;
    end;
end;

procedure TCMDForm.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Commands window');
    Label1.Caption := L('Please wait until the program completes the operation...');
  finally
    EndTranslate;
  end;
end;

procedure TCMDForm.RestoreTable(FileName : String);
var
  Options: TRestoreThreadOptions;
begin

  WriteLnLine(Self, L('Restoring collection:'), LINE_INFO_INFO);
  WriteLnLine(Self, '[' + FileName + ']', LINE_INFO_DB);
  WriteLnLine(Self, L('Restoring'), LINE_INFO_INFO);
  WriteLnLine(Self, L('Starting restoring of collection. Please wait...'), LINE_INFO_OK);
  SetWideIndex;

  Timer1.Enabled := True;
  Options.OwnerForm := Self;
  Options.WriteLineProc := WriteLine;
  Options.OnEnd := OnEnd;
  Options.FileName := FileName;

  ThreadRestoreTable.Create(Options);
  Working := True;
  Recreating := True;
  CMDForm.ShowModal;
end;

procedure TCMDForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if not Active then
    Exit;
  if Msg.message = 256 then
  begin
    if (Msg.wParam = Byte('B')) and CtrlKeyDown then
      CMD_Command_Break := true;
  end;
  if Msg.hwnd = InfoListBox.Handle then
    if Msg.message = WM_MOUSEWHEEL then
      Msg.message := 0;
end;

procedure TCMDForm.BackUpTable;
var
  Options: TBackUpTableThreadOptions;
begin

  WriteLnLine(Self, L('Backing up the collection'), LINE_INFO_INFO);
  WriteLnLine(Self, '[' + dbname + ']', LINE_INFO_DB);
  WriteLnLine(Self, L('Performing:'), LINE_INFO_OK);
  SetWideIndex;
  TopRecords := 0;

  Options.OwnerForm := Self;
  Options.WriteLineProc := WriteLine;
  Options.WriteLnLineProc := WriteLnLine;
  Options.OnEnd := OnEnd;
  Options.FileName := DBName;

  Timer1.Enabled := False;
  BackUpTableInCMD.Create(Options);
  Working := True;
  Recreating := True;
  CMDForm.ShowModal;
end;

procedure TCMDForm.WriteLine(Sender: TObject; Line: string; Info: Integer);
begin
  BeginScreenUpdate(Handle);
  try
    ItemsData[0] := Pointer(Info);
    InfoListBox.Items[0] := Line;
  finally
    EndScreenUpdate(Handle, False);
  end;
end;

procedure TCMDForm.WriteLnLine(Sender: TObject; Line: string; Info : integer);
begin
  if Info = LINE_INFO_INFO then
  begin
    FInfo := Line;
    Exit;
  end;

  if not FCreation then
    BeginScreenUpdate(Handle);
  try
    Infos.Insert(0, FInfo);

    ItemsData.Insert(TopRecords, Pointer(Info));
    InfoListBox.Items.Insert(TopRecords, Line);

    FInfo := '';
  finally
    if not FCreation then
      EndScreenUpdate(Handle, False);
  end;
end;

procedure TCMDForm.PasswordTimerTimer(Sender: TObject);
var
  PasswordList: TArCardinal;
  I: Integer;
begin
  PasswordList := nil;
  if PasswordKeeper = nil then
    Exit;
  if PasswordKeeper.Count > 0 then
  begin
    PasswordTimer.Enabled := False;
    PasswordList := PasswordKeeper.GetPasswords;
    for I := 0 to Length(PasswordList) - 1 do
      PasswordKeeper.TryGetPasswordFromUser(PasswordList[I]);

    PasswordTimer.Enabled := True;
  end;
end;

procedure TCMDForm.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to Length(Icons) - 1 do
    Icons[I].Free;
  F(ItemsData);
  F(Infos);
end;

procedure TCMDForm.FormShow(Sender: TObject);
begin
  FCreation := False;
end;

function TCMDForm.GetFormID: string;
begin
  Result := 'CMD';
end;

procedure TCMDForm.LoadToolBarIcons;
var
  Index : Integer;

  procedure AddIcon(Name : String);
  begin
    Icons[index] := TIcon.Create;
    Icons[index].Handle := LoadIcon(HInstance, PWideChar(Name));
    Inc(index);
  end;

begin
  Index := 0;
  SetLength(Icons, 7);
  AddIcon('CMD_OK');
  AddIcon('CMD_ERROR');
  AddIcon('CMD_WARNING');
  AddIcon('CMD_PLUS');
  AddIcon('CMD_PROGRESS');
  AddIcon('CMD_DB');
  AddIcon('ADMINTOOLS');
end;

procedure TCMDForm.ProgressCallBack(Sender: TObject; var Info: TProgressCallBackInfo);
begin
  if TempProgress.MaxValue <> Info.MaxValue then
    TempProgress.MaxValue := Info.MaxValue;
  TempProgress.Position := Info.Position;
end;

procedure TCMDForm.InfoListBoxMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
begin
  if index = CurrentWideIndex then
  begin
    Height := InfoListBox.Canvas.TextHeight('Iy') * 5 + 5
  end else
    Height := InfoListBox.Canvas.TextHeight('Iy') * 3 + 5;
end;

procedure TCMDForm.SetWideIndex;
begin
  CurrentWideIndex := InfoListBox.Items.Count - 2;
end;

procedure TCMDForm.InfoListBoxDrawItem(Control: TWinControl; index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  DoInfoListBoxDrawItem(Control as TListBox, index, Rect, State, ItemsData, Icons, FProgressEnabled, TempProgress,
    Infos);
end;

end.
