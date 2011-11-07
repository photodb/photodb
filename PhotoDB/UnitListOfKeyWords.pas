unit UnitListOfKeyWords;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, Dolphin_DB, ProgressActionUnit, uVistaFuncs,
  CmpUnit, ExtCtrls, ClipBrd, Menus, UnitDBkernel, CommonDBSupport, uMemory,
  uDBForm, uShellIntegration, uConstants, uMemoryEx, uRuntime;

type
  Item = string; { This defines the objects being sorted. }
  List = array of Item; { This is an array of objects to be sorted. }

type
  TFormListOfKeyWords = class(TDBForm)
    LstKeywords: TListBox;
    PmKeywords: TPopupMenu;
    Copy1: TMenuItem;
    N1: TMenuItem;
    Search1: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    BtnOk: TButton;
    Panel3: TPanel;
    LbInfo: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LstKeywordsDblClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure LstKeywordsContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Search1Click(Sender: TObject);
    procedure DBOpened(Sender : TObject; DS : TDataSet);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    DBInOpening: Boolean;
    procedure LoadLanguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure Execute;
  end;

procedure GetListOfKeyWords;

implementation

uses
  uSearchTypes, UnitOpenQueryThread;

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
      ProgressForm.SetAlternativeText(L('Loading list. Please, wait...'));
      try
        begin

          TOpenQueryThread.Create(Self, FTable, DBOpened);
          OpenProgress := GetProgressWindow;
          OpenProgress.OneOperation := True;
          OpenProgress.OperationCounter.Inverse := True;
          OpenProgress.OperationCounter.Text := '';
          OpenProgress.OperationProgress.Inverse := True;
          OpenProgress.OperationProgress.Text := '';
          OpenProgress.SetAlternativeText(L('Executing query. Please, wait...'));

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
          until not DBInOpening;
          OpenProgress.Release;
          FTable.First;
        end;

      except
        MessageBoxDB(Handle, Format(L('Error executing query on collection "%s"'), [Dbname]), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
        Exit;
      end;
      ProgressForm.MaxPosCurrentOperation := FTable.RecordCount;
      ProgressForm.XPosition := 0;
      ProgressForm.CanClosedByUser := True;
      ProgressForm.DoFormShow;
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

      LstKeywords.Items := AllList;
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
  LoadLanguage;
  PmKeywords.Images := DBkernel.ImageList;
  Copy1.ImageIndex := DB_IC_COPY;
  Search1.ImageIndex := DB_IC_SEARCH;
end;

procedure TFormListOfKeyWords.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Release;
end;

procedure TFormListOfKeyWords.LstKeywordsDblClick(Sender: TObject);
var
  P: TPoint;
  N: Integer;
begin
  GetCursorPos(P);
  P := LstKeywords.ScreenToClient(P);
  N := LstKeywords.ItemAtPos(P, True);
  if N > -1 then
    ClipBoard.AsText := LstKeywords.Items[N];
end;

procedure TFormListOfKeyWords.BtnOkClick(Sender: TObject);
begin
  Close;
end;

procedure TFormListOfKeyWords.Copy1Click(Sender: TObject);
begin
  ClipBoard.AsText := LstKeywords.Items[PmKeywords.Tag];
end;

procedure TFormListOfKeyWords.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('List of keywords');
    LbInfo.Caption := L('This is a list of all keywords in collection. Double click to copy item to clipboard.');
    BtnOk.Caption := L('Ok');
    Copy1.Caption := L('Copy');
    Search1.Caption := L('Search');
  finally
    EndTranslate;
  end;
end;

procedure TFormListOfKeyWords.LstKeywordsContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  I: Integer;
  ItemNo: Integer;
begin
  ItemNo := LstKeywords.ItemAtPos(MousePos, True);
  if ItemNo <> -1 then
  begin
    if not LstKeywords.Selected[ItemNo] then
    begin
      LstKeywords.Selected[ItemNo] := True;
    end;
    PmKeywords.Tag := ItemNo;
    PmKeywords.Popup(LstKeywords.ClientToScreen(MousePos).X, LstKeywords.ClientToScreen(MousePos).Y);
  end else
  begin
    for I := 0 to LstKeywords.Items.Count - 1 do
      LstKeywords.Selected[I] := False;
  end;
end;

procedure TFormListOfKeyWords.Search1Click(Sender: TObject);
begin
  SearchManager.NewSearch.StartSearch(':KeyWord(' + LstKeywords.Items[PmKeywords.Tag] + '):');
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

function TFormListOfKeyWords.GetFormID: string;
begin
  Result := 'KeywordList';
end;

end.
