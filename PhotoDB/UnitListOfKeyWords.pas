unit UnitListOfKeyWords;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, Dolphin_DB, ProgressActionUnit, Language, uVistaFuncs,
  CmpUnit, ExtCtrls, ClipBrd, Menus, UnitDBkernel, CommonDBSupport, uMemory;

type
  Item = string; { This defines the objects being sorted. }
  List = array of Item; { This is an array of objects to be sorted. }

type
  TFormListOfKeyWords = class(TForm)
    ListBox1: TListBox;
    DestroyTimer: TTimer;
    PopupMenu1: TPopupMenu;
    Copy1: TMenuItem;
    N1: TMenuItem;
    Search1: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    Panel3: TPanel;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBox1DblClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure ListBox1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Search1Click(Sender: TObject);
    procedure DBOpened(Sender : TObject; DS : TDataSet);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    DBInOpening: Boolean;
  public
    { Public declarations }
    procedure Execute;
  end;

procedure GetListOfKeyWords;

implementation

uses Searching,
     UnitOpenQueryThread;

{$R *.dfm}

function L_Less_Than_R(L, R: Item): Boolean;
begin
  Result := CompareStr(L, R) < 0;
end;

procedure Swap(var X: List; I, J: Integer);
var
  Temp: Item;
begin
  Temp := X[I];
  X[I] := X[J];
  X[J] := Temp;
end;

procedure Qsort(var X: List; Left, Right: Integer);
label Again;
var
  Pivot: Item;
  P, Q: Integer;

begin
  P := Left;
  Q := Right;
  Pivot := X[(Left + Right) div 2];

  while P <= Q do
  begin
    while L_Less_Than_R(X[P], Pivot) do
      Inc(P);
    while L_Less_Than_R(Pivot, X[Q]) do
      Dec(Q);
    if P > Q then
      goto Again;
    Swap(X, P, Q);
    Inc(P);
    Dec(Q);
  end;

Again :
  if Left < Q then
    Qsort(X, Left, Q);
  if P < Right then
    Qsort(X, P, Right);
end;

procedure QuickSort(var X: List; N: Integer);
begin
  Qsort(X, 0, N - 1);
end;

procedure GetListOfKeyWords;
var
  FormListOfKeyWords: TFormListOfKeyWords;
begin
  Application.CreateForm(TFormListOfKeyWords, FormListOfKeyWords);
  FormListOfKeyWords.Execute;
end;

{ TFormListOfKeyWords }

procedure TFormListOfKeyWords.Execute;
var
  FTable : TDataSet;
  ProgressForm, OpenProgress : TProgressActionForm;
  i, c : integer;
  AllList, Words : TStrings;
  X : List;

begin

  FTable := GetQuery;
  try
    SetSQL(FTable, 'Select ID, Access, KeyWords from $DB$ order by ID desc');

    ProgressForm := GetProgressWindow;
    try
      ProgressForm.OneOperation := True;
      ProgressForm.OperationPosition := 0;
      ProgressForm.OneOperation := True;
      ProgressForm.CanClosedByUser := True;
      ProgressForm.SetAlternativeText(TEXT_MES_LOADING_KEYWORDS);
      try
        begin

          TOpenQueryThread.Create(FTable, DBOpened);
          OpenProgress := GetProgressWindow;
          OpenProgress.OneOperation := True;
          OpenProgress.OperationCounter.Inverse := True;
          OpenProgress.OperationCounter.Text := '';
          OpenProgress.OperationProgress.Inverse := True;
          OpenProgress.OperationProgress.Text := '';
          OpenProgress.SetAlternativeText(TEXT_MES_WAINT_OPENING_QUERY);

          C := 0;
          I := 0;
          OpenProgress.Show;
          repeat
            OpenProgress.MaxPosCurrentOperation := 100;
            Inc(I);
            if I mod 50 = 0 then
            begin
              Inc(C);
              if C > 100 then
                C := 0;
              OpenProgress.XPosition := C;
            end;
            Application.ProcessMessages;
            Application.ProcessMessages;
            Application.ProcessMessages;
          until not DBInOpening;
          OpenProgress.Release;
          FTable.First;
        end;

      except
        MessageBoxDB(Handle, Format(TEXT_MES_OPEN_TABLE_ERROR_F, [Dbname]), TEXT_MES_ERROR, TD_BUTTON_OK, TD_ICON_ERROR);
        Exit;
      end;
      ProgressForm.MaxPosCurrentOperation := FTable.RecordCount;
      ProgressForm.XPosition := 0;
      ProgressForm.CanClosedByUser := True;
      ProgressForm.DoShow;
      FTable.First;
      AllList := TStringList.Create;
      Words := TStringList.Create;
      FTable.Last;
      for I := FTable.RecordCount downto 1 do
      begin
        ProgressForm.XPosition := FTable.RecordCount - FTable.RecNo;
        Application.ProcessMessages;
        SpilitWords(FTable.FieldByName('KeyWords').AsString, Words);

        AddWordsB(Words, AllList);
        FTable.Prior;
        if ProgressForm.Closed then
          Break;
      end;
      SetLength(X, AllList.Count);
      for I := 0 to AllList.Count - 1 do
        X[I] := AllList.Strings[I];
      if Length(X) > 1 then
        QuickSort(X, Length(X));

      for I := 0 to AllList.Count - 1 do
        AllList.Strings[I] := X[I];

      for I := AllList.Count - 2 downto 0 do
      begin
        if AllList[I] = AllList[I + 1] then
          AllList.Delete(I);
      end;

      ListBox1.Items := AllList;
    finally
      R(ProgressForm);
    end;
  finally
    FreeDS(FTable);
  end;
  Show;
end;

procedure TFormListOfKeyWords.FormCreate(Sender: TObject);
begin
  DBInOpening := True;
  ListBox1.Color := Theme_ListColor;
  ListBox1.Font.Color := Theme_ListFontColor;
  DBKernel.RecreateThemeToForm(Self);
  Caption := TEXT_MES_LIST_OF_KEYWORDS_CAPTION;
  Label1.Caption := TEXT_MES_LIST_OF_KEYWORDS_TEXT;
  Button1.Caption := TEXT_MES_OK;
  Copy1.Caption := TEXT_MES_COPY;
  Search1.Caption := TEXT_MES_SEARCH;
  PopupMenu1.Images := DBkernel.ImageList;
  Copy1.ImageIndex := DB_IC_COPY;
  Search1.ImageIndex := DB_IC_SEARCH;
end;

procedure TFormListOfKeyWords.DestroyTimerTimer(Sender: TObject);
begin
  DestroyTimer.Enabled := False;
  Release;
end;

procedure TFormListOfKeyWords.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DestroyTimer.Enabled := True;
end;

procedure TFormListOfKeyWords.ListBox1DblClick(Sender: TObject);
var
  P: TPoint;
  N: Integer;
begin
  GetCursorPos(P);
  P := ListBox1.ScreenToClient(P);
  N := ListBox1.ItemAtPos(P, True);
  if N > -1 then
    ClipBoard.AsText := ListBox1.Items[N];
end;

procedure TFormListOfKeyWords.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TFormListOfKeyWords.Copy1Click(Sender: TObject);
begin
  ClipBoard.AsText := ListBox1.Items[PopupMenu1.Tag];
end;

procedure TFormListOfKeyWords.ListBox1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  I: Integer;
  ItemNo: Integer;
begin
  ItemNo := ListBox1.ItemAtPos(MousePos, True);
  if ItemNo <> -1 then
  begin
    if not ListBox1.Selected[ItemNo] then
    begin
      ListBox1.Selected[ItemNo] := True;
    end;
    PopupMenu1.Tag := ItemNo;
    PopupMenu1.Popup(ListBox1.ClientToScreen(MousePos).X, ListBox1.ClientToScreen(MousePos).Y);
  end else
  begin
    for I := 0 to ListBox1.Items.Count - 1 do
      ListBox1.Selected[I] := False;
  end;
end;

procedure TFormListOfKeyWords.Search1Click(Sender: TObject);
begin
  with SearchManager.NewSearch do
  begin
    Show;
    SearchEdit.Text := ':KeyWord(' + ListBox1.Items[Self.PopupMenu1.Tag] + '):';
    DoSearchNow(nil);
  end;
end;

procedure TFormListOfKeyWords.DBOpened(Sender : TObject; DS : TDataSet);
begin
  DBInOpening := False;
end;

procedure TFormListOfKeyWords.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

end.
