unit UnitHistoryForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, uDBUtils, Menus, UnitDBKernel, uGraphicUtils,
  UnitDBCommonGraphics, UnitDBDeclare, GraphicCrypt, uMemory, uDBForm,
  uConstants, uDBPopupMenuInfo, uFileUtils;

type
  TFormHistory = class(TDBForm)
    Panel1: TPanel;
    InfoListBox: TListBox;
    InfoLabel: TLabel;
    PmActions: TPopupMenu;
    View1: TMenuItem;
    Explorer1: TMenuItem;
    ReAddAll1: TMenuItem;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure InfoListBoxDblClick(Sender: TObject);
    procedure InfoListBoxContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure View1Click(Sender: TObject);
    procedure Explorer1Click(Sender: TObject);
    procedure InfoListBoxMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure InfoListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormDestroy(Sender: TObject);
    procedure ReAddAll1Click(Sender: TObject);
  private
    { Private declarations }
    Icons : array of TIcon;
    ItemsData: TList;
    Infos: TStrings;
    FileList: TStrings;
    procedure LoadLanguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
   procedure LoadToolBarIcons;
   procedure SetFilesList(List : TStrings);
   procedure WriteLnLine(Sender: TObject; Line: string; Info : integer);
  end;

procedure ShowHistory(List : TStrings);

implementation

uses
  uManagerExplorer, SlideShow, UnitUpdateDB;

{$R *.dfm}

procedure ShowHistory(List : TStrings);
var
  FormHistory: TFormHistory;
begin
  Application.CreateForm(TFormHistory, FormHistory);
  FormHistory.SetFilesList(List);
  FormHistory.Show;
end;

procedure TFormHistory.FormCreate(Sender: TObject);
begin
  FileList := TStringList.Create;
  Infos := TStringList.Create;
  ItemsData := TList.Create;

  InfoListBox.DoubleBuffered := True;
  InfoListBox.ItemHeight := InfoListBox.Canvas.TextHeight('Iy') * 3 + 5;
  InfoListBox.Clear;
  LoadToolBarIcons;

  LoadLanguage;
  PmActions.Images := DBKernel.ImageList;
  View1.ImageIndex := DB_IC_SLIDE_SHOW;
  Explorer1.ImageIndex := DB_IC_FOLDER;
  ReAddAll1.ImageIndex := DB_IC_NEW;
end;

procedure TFormHistory.LoadLanguage;
begin
  BeginTranslate;
  try
    InfoLabel.Caption := L('In this list are the files that for whatever reasons, have not been added') + ':';
    Caption := L('Update history');
    Button1.Caption := L('Ok');
    View1.Caption := L('Slide show');
    Explorer1.Caption := L('Explorer');
    ReAddAll1.Caption := L('Add all files again');
  finally
    EndTranslate;
  end;
end;

procedure TFormHistory.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TFormHistory.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Release;
end;

procedure TFormHistory.InfoListBoxDblClick(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
  InfoItem: TDBPopupMenuInfoRecord;
  P: TPoint;
  N: Integer;
begin
  GetCursorPos(P);
  P := InfoListBox.ScreenToClient(P);
  N := InfoListBox.ItemAtPos(P, True);
  if N < 0 then
    Exit;
  if Viewer = nil then
    Application.CreateForm(TViewer, Viewer);

  InfoItem := TDBPopupMenuInfoRecord.Create;
  try
    GetInfoByFileNameA(FileList[N], False, InfoItem);

    Info := TDBPopupMenuInfo.Create;
    try
      Info.Add(InfoItem);
      Viewer.Execute(Sender, Info);
      Viewer.Show;
    finally
      F(Info);
    end;
  finally
    F(InfoItem);
  end;
end;

procedure TFormHistory.InfoListBoxContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  P, P1: TPoint;
  N: Integer;
begin
  GetCursorPos(P);
  P1 := InfoListBox.ScreenToClient(P);
  N := InfoListBox.ItemAtPos(P1, True);
  if N < 0 then
    Exit;
  PmActions.Tag := N;
  InfoListBox.Selected[N] := True;
  PmActions.Popup(P.X, P.Y);
end;

procedure TFormHistory.View1Click(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
  InfoItem: TDBPopupMenuInfoRecord;
begin
  if Viewer = nil then
    Application.CreateForm(TViewer, Viewer);

  InfoItem := TDBPopupMenuInfoRecord.Create;
  try
    Info := TDBPopupMenuInfo.Create;
    try
      GetInfoByFileNameA(FileList[PmActions.Tag], False, InfoItem);

      Info.Add(InfoItem);
      Viewer.Execute(Sender, Info);
      Viewer.Show;
    finally
      F(Info);
    end;
  finally
    F(InfoItem);
  end;
end;

procedure TFormHistory.Explorer1Click(Sender: TObject);
begin
  with ExplorerManager.NewExplorer(False) do
  begin
    SetOldPath(InfoListBox.Items[PmActions.Tag]);
    SetPath(ExtractFileDir(FileList[PmActions.Tag]));
    Show;
  end;
end;

procedure TFormHistory.InfoListBoxMeasureItem(Control: TWinControl; index: Integer; var Height: Integer);
begin
  Height := InfoListBox.Canvas.TextHeight('Iy') * 3 + 5;
end;

procedure TFormHistory.InfoListBoxDrawItem(Control: TWinControl; index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  DoInfoListBoxDrawItem(Control as TListBox, index, Rect, State, ItemsData, Icons, False, nil, Infos);
end;

procedure TFormHistory.SetFilesList(List: TStrings);
var
  I: Integer;
  Pass: string;

  function AddErrorMessage(FileName : string) : string;
  begin
    Result := Format(L('Unable to add file: "%s"'), [FileName]);
  end;

begin
  InfoListBox.Clear;
  for I := 0 to List.Count - 1 do
  begin
    FileList.Add(List[I]);
    if FileExistsSafe(List[I]) then
    begin
      if GraphicCrypt.ValidCryptGraphicFile(List[I]) then
      begin
        Pass := DBkernel.FindPasswordForCryptImageFile(List[I]);
        if Pass = '' then
        begin
          WriteLnLine(Self, Format(L('Unable to find password for file: "%s"'), [List[I]]), LINE_INFO_WARNING);
        end else
        begin
          WriteLnLine(Self, AddErrorMessage(List[I]), LINE_INFO_PLUS);
        end;
      end else
        WriteLnLine(Self, AddErrorMessage(List[I]), LINE_INFO_OK)
    end else
      WriteLnLine(Self, AddErrorMessage(List[I]), LINE_INFO_ERROR);
  end;
end;

procedure TFormHistory.LoadToolBarIcons;
var
  Index : Integer;

  procedure AddIcon(Name : String);
  begin
    Icons[Index] := TIcon.Create;
    Icons[Index].Handle := LoadIcon(HInstance, PWideChar(Name));
    Inc(Index);
  end;

begin
  index := 0;
  SetLength(Icons, 7);
  AddIcon('CMD_OK');
  AddIcon('CMD_ERROR');
  AddIcon('CMD_WARNING');
  AddIcon('CMD_PLUS');
  AddIcon('CMD_PROGRESS');
  AddIcon('CMD_DB');
  AddIcon('ADMINTOOLS');
end;

procedure TFormHistory.FormDestroy(Sender: TObject);
begin
  F(ItemsData);
  F(Infos);
  F(FileList);
end;

function TFormHistory.GetFormID: string;
begin
  Result := 'UpdaterHistory';
end;

procedure TFormHistory.WriteLnLine(Sender: TObject; Line: string; Info: Integer);
const
  TopRecords = 0;

begin
  BeginScreenUpdate(Handle);
  try
    Infos.Insert(0, Line);

    ItemsData.Insert(TopRecords, Pointer(Info));
    InfoListBox.Items.Insert(TopRecords, Line);
  finally
    EndScreenUpdate(Handle, False);
  end;
  LockWindowUpdate(0);
end;

procedure TFormHistory.ReAddAll1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FileList.Count - 1 do
  begin
    if FileExistsSafe(FileList[I]) then
      UpdaterDB.AddFile(FileList[I]);
  end;
end;

end.
