unit uFrmConvertationProgress;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, uFrameWizardBase, AppEvnts, StdCtrls, DmProgress, uMemory,
  UnitDBCommonGraphics, UnitDBDeclare, uDBBaseTypes, UnitPasswordKeeper,
  ExtCtrls, uConstants, uSHellIntegration, uInterfaces;

type
  TFrmConvertationProgress = class(TFrameWizardBase)
    LbInfo: TLabel;
    LbCurrentAction: TLabel;
    LbAction: TLabel;
    Progress: TDmProgress;
    InfoListBox: TListBox;
    Label5: TLabel;
    TempProgress: TDmProgress;
    ApplicationEvents1: TApplicationEvents;
    PasswordTimer: TTimer;
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure InfoListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure PasswordTimerTimer(Sender: TObject);
  private
    { Private declarations }
    ItemsData: TList;
    FInfo: string;
    Infos: TStrings;
    TopRecords: Integer;
    Icons: array of TIcon;
    PasswordKeeper: TPasswordKeeper;
    FWorking: Boolean;
    procedure LoadIconList;
    procedure DoFormExit(Sender: TObject);
    function GetImageOptions: TImageDBOptions;
  protected
    { Protected declarations }
    procedure LoadLanguage; override;
    function GetOperationInProgress: Boolean; override;
  public
    { Public declarations }
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    procedure Unload; override;
    procedure Execute; override;
    function IsFinal: Boolean; override;
    procedure BreakOperation; override;
    //thread call-backs
    procedure WriteLine(Sender: TObject; Line: string; Info: Integer);
    procedure WriteLnLine(Sender: TObject; Line: string; Info : integer);
    procedure ProgressCallBack(Sender: TObject; var Info: TProgressCallBackInfo);
    procedure OnConvertingStructureEnd(Sender: TObject; NewFileName: string;
      Result: Boolean);
    property ImageOptions: TImageDBOptions read GetImageOptions;
  end;

implementation

{$R *.dfm}

uses
  UnitConvertDBForm, ConvertDBThreadUnit, UnitRecreatingThInTable;

procedure TFrmConvertationProgress.LoadIconList;
var
  Index: Integer;

  procedure AddIcon(name: string);
  begin
    Icons[Index] := TIcon.Create;
    Icons[Index].Handle := LoadIcon(HInstance, PWideChar(name));
    Inc(Index);
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

procedure TFrmConvertationProgress.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if Msg.Hwnd = InfoListBox.Handle then
    if Msg.message = 522 then
      Msg.message := 0;
end;

procedure TFrmConvertationProgress.InfoListBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  DoInfoListBoxDrawItem(Control as TListBox, Index, Rect, State, ItemsData,
    Icons, True, TempProgress, Infos);
end;

procedure TFrmConvertationProgress.Init(Manager: TWizardManagerBase;
  FirstInitialization: Boolean);
begin
  inherited;
  if FirstInitialization then
  begin
    FWorking := False;
    FInfo := '';
    Infos := TStringList.Create;
    ItemsData := TList.Create;
    InfoListBox.ItemHeight := InfoListBox.Canvas.TextHeight('Iy') * 3 + 5;
    InfoListBox.Clear;
    LoadIconList;
    PasswordKeeper := TPasswordKeeper.Create;
  end;
end;

function TFrmConvertationProgress.IsFinal: Boolean;
begin
  Result := True;
end;

procedure TFrmConvertationProgress.Unload;
var
  I: Integer;
begin
  inherited;
  F(PasswordKeeper);
  F(Infos);
  F(ItemsData);
  for I := 0 to Length(Icons) - 1 do
    TIcon(Icons[I]).Free;
  SetLength(Icons, 0);
end;

procedure TFrmConvertationProgress.LoadLanguage;
begin
  inherited;
  LbAction.Caption := L('Waiting');
  LbInfo.Caption := L('Please wait until convertation is in progress. This can take some time to complete...');
  LbCurrentAction.Caption := L('Current action') + ':';
  Progress.Text := L('Progress... (&%%)');
end;

procedure TFrmConvertationProgress.WriteLine(Sender: TObject; Line: string;
  Info: Integer);
begin
  BeginScreenUpdate(InfoListBox.Handle);
  try
    ItemsData[0] := Pointer(Info);
    InfoListBox.Items[0] := Line;
  finally
    EndScreenUpdate(InfoListBox.Handle, False);
  end;
end;

procedure TFrmConvertationProgress.WriteLnLine(Sender: TObject; Line: string; Info : integer);
begin
  if Info = LINE_INFO_INFO then
  begin
    FInfo := Line;
    Exit;
  end;
  BeginScreenUpdate(InfoListBox.Handle);
  try
    Infos.Insert(0, FInfo);

    ItemsData.Insert(TopRecords, Pointer(Info));
    InfoListBox.Items.Insert(TopRecords, Line);

    FInfo := '';

  finally
    EndScreenUpdate(InfoListBox.Handle, False);
  end;
end;

procedure TFrmConvertationProgress.PasswordTimerTimer(Sender: TObject);
var
  PasswordList: TArCardinal;
  I: Integer;
begin
  if PasswordKeeper.Count > 0 then
  begin
    PasswordTimer.Enabled := False;
    PasswordList := PasswordKeeper.GetPasswords;
    for I := 0 to Length(PasswordList) - 1 do
      PasswordKeeper.TryGetPasswordFromUser(PasswordList[I]);

    PasswordTimer.Enabled := true;
  end;
end;

procedure TFrmConvertationProgress.ProgressCallBack(Sender: TObject;
  var Info: TProgressCallBackInfo);
begin
  if Info.MaxValue <> Progress.MaxValue then
  begin
    Progress.MaxValue := Info.MaxValue;
    TempProgress.MaxValue := Info.MaxValue;
  end;
  Progress.Position := Info.Position;
  TempProgress.Position := Info.Position;

  Progress.Text := Info.Information + ' (&%%)';
end;

procedure TFrmConvertationProgress.BreakOperation;
begin
  inherited;
  BreakConverting := True;
end;

procedure TFrmConvertationProgress.DoFormExit(Sender: TObject);
begin
  FWorking := False;
  IsStepComplete := True;
  TFormConvertingDB(Manager.Owner).SilentClose := True;
  MessageBoxDB(Handle, L('Convertation of the collection is completed!'), L('Information'),
    TD_BUTTON_OK, TD_ICON_INFORMATION);
  Changed;
end;

procedure TFrmConvertationProgress.Execute;
begin
  inherited;
  FWorking := True;
  Changed;
  TConvertDBThread.Create(TFormConvertingDB(Manager.Owner), Self,
    TFormConvertingDB(Manager.Owner).FileName,
    ImageOptions.Copy);
end;

function TFrmConvertationProgress.GetImageOptions: TImageDBOptions;
begin
  Result := (Manager.Owner as IDBImageSettings).GetImageOptions;
end;

function TFrmConvertationProgress.GetOperationInProgress: Boolean;
begin
  Result := FWorking;
end;

procedure TFrmConvertationProgress.OnConvertingStructureEnd(Sender: TObject;
  NewFileName: string; Result: Boolean);
var
  Options: TRecreatingThInTableOptions;
begin
  if Result then
  begin
    Options.OwnerForm := Manager.Owner;
    Options.WriteLineProc := WriteLine;
    Options.WriteLnLineProc := WriteLnLine;
    Options.OnEndProcedure := DoFormExit;
    Options.FileName := NewFileName;
    Options.GetFilesWithoutPassProc := PasswordKeeper.GetActiveFiles;
    Options.AddCryptFileToListProc := PasswordKeeper.AddCryptFileToListProc;
    Options.GetAvaliableCryptFileList := PasswordKeeper.GetAvaliableCryptFileList;
    Options.OnProgress := ProgressCallBack;
    RecreatingThInTable.Create(Options);
  end else
    DoFormExit(Self);
end;

end.
