unit UnitListOfKeyWords;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, Dolphin_DB, ProgressActionUnit, Language, uVistaFuncs,
  CmpUnit, ExtCtrls, ClipBrd, Menus, UnitDBkernel, CommonDBSupport;

type
  Item=String;   {This defines the objects being sorted.}
  List=array of Item; {This is an array of objects to be sorted.}

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
    procedure DBOpened(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
   DBInOpening: boolean;
    { Private declarations }
  public
  procedure Execute;
    { Public declarations }
  end;

procedure GetListOfKeyWords;

implementation

uses Searching,
     UnitOpenQueryThread;

{$R *.dfm}

function L_Less_Than_R(L,R:Item):boolean;
begin
 Result:=CompareStr(L,R)<0;
end;

procedure Swap(var X:List;I,J:integer);
var
 Temp:Item;
begin
 Temp:=X[I];
 X[I]:=X[J];
 X[J]:=Temp;
end;

procedure Qsort(var X:List;Left,Right:integer);
label
   Again;
var
   Pivot:Item;
   P,Q:integer;

   begin
      P:=Left;
      Q:=Right;
      Pivot:=X [(Left+Right) div 2];

      while P<=Q do
      begin
         while L_Less_Than_R(X[P],Pivot) do inc(P);
         while L_Less_Than_R(Pivot,X[Q]) do dec(Q);
         if P>Q then goto Again;
         Swap(X,P,Q);
         inc(P);dec(Q);
      end;

      Again:
      if Left<Q  then Qsort(X,Left,Q);
      if P<Right then Qsort(X,P,Right);
   end;

procedure QuickSort(var X:List;N:integer);
begin
 Qsort(X,0,N-1);
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
 if GetDBType=DB_TYPE_BDE then
 begin
  FTable := GetTable;
 end else
 begin
  FTable:=GetQuery;
  SetSQL(FTable,'Select ID, Access, KeyWords from '+GetDefDBName+' order by ID desc');
 end;
 ProgressForm:=GetProgressWindow;
 ProgressForm.OneOperation:=true;
 ProgressForm.OperationPosition:=0;
 ProgressForm.OneOperation:=true;
 ProgressForm.CanClosedByUser:=true;
 ProgressForm.SetAlternativeText(TEXT_MES_LOADING_KEYWORDS);
 try
  if GetDBType=DB_TYPE_BDE then FTable.Open else
  begin

   TOpenQueryThread.Create(false,FTable,DBOpened);
   OpenProgress:=GetProgressWindow;
   OpenProgress.OneOperation:=true;
   OpenProgress.OperationCounter.Inverse:=true;
   OpenProgress.OperationCounter.Text:='';
   OpenProgress.OperationProgress.Inverse:=true;
   OpenProgress.OperationProgress.Text:='';
   OpenProgress.SetAlternativeText(TEXT_MES_WAINT_OPENING_QUERY);

   c:=0;
   i:=0;
   OpenProgress.Show;
   Repeat
    OpenProgress.MaxPosCurrentOperation:=100;
    inc(i);
    if i mod 50=0 then
    begin
     inc(c);
     if c>100 then c:=0;
     OpenProgress.xPosition:=c;
    end;
    Application.ProcessMessages;
    Application.ProcessMessages;
    Application.ProcessMessages;
   Until not DBInOpening;  
   OpenProgress.Release;
   if UseFreeAfterRelease then
   OpenProgress.Free;
   FTable.First;
  end;

 except
  FreeDS(FTable);
  ProgressForm.Release;
  if UseFreeAfterRelease then ProgressForm.Free;
  MessageBoxDB(Handle,Format(TEXT_MES_OPEN_TABLE_ERROR_F,[dbname]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
  exit;
 end;
 ProgressForm.MaxPosCurrentOperation:=FTable.RecordCount;
 ProgressForm.xPosition:=0;
 ProgressForm.CanClosedByUser:=true;
 ProgressForm.DoShow;
 FTable.First;
 AllList:=TStringList.Create;
 Words:=TStringList.Create;
 FTable.Last;
 for i:=FTable.RecordCount downto 1 do
 begin
  ProgressForm.xPosition:=FTable.RecordCount-FTable.RecNo;
  Application.ProcessMessages;
  SpilitWords(FTable.FieldByName('KeyWords').AsString,Words);
  if (FTable.FieldByName('Access').AsInteger=db_access_private) and (not DBkernel.UserRights.ShowPrivate) then
  begin
   FTable.Prior;
   if ProgressForm.Closed then Break;
   Continue;
  end;
  AddWordsB(Words,AllList);
  FTable.Prior;
 if ProgressForm.Closed then Break;
 end;
 SetLength(X,AllList.Count);
 for i := 0 to AllList.Count - 1 do
 X[i] := AllList.Strings[i];
 if Length(X)>1 then
 QuickSort(X,Length(X));

 for i := 0 to AllList.Count - 1 do
 AllList.Strings[i] := X[i];

 for i := AllList.Count-2 downto 0 do
 begin
  if AllList[i]=AllList[i+1] then AllList.Delete(i);
 end;

 ListBox1.Items:=AllList;
 ProgressForm.Release;
 if UseFreeAfterRelease then ProgressForm.Free;
 FTable.Close;
 FreeDS(FTable);
 Show;
end;

procedure TFormListOfKeyWords.FormCreate(Sender: TObject);
begin
 DBInOpening:=true;
 ListBox1.Color:=Theme_ListColor;
 ListBox1.Font.Color:=Theme_ListFontColor;
 DBKernel.RecreateThemeToForm(self);
 Caption:=TEXT_MES_LIST_OF_KEYWORDS_CAPTION;
 label1.Caption:=TEXT_MES_LIST_OF_KEYWORDS_TEXT;
 Button1.Caption:=TEXT_MES_OK;
 Copy1.Caption:=TEXT_MES_COPY;
 Search1.Caption:=TEXT_MES_SEARCH;
 PopupMenu1.Images:=DBkernel.ImageList;
 Copy1.ImageIndex:=DB_IC_COPY;
 Search1.ImageIndex:=DB_IC_SEARCH;
end;

procedure TFormListOfKeyWords.DestroyTimerTimer(Sender: TObject);
begin
 DestroyTimer.Enabled:=false;
 Release;
 if UseFreeAfterRelease then Free;
end;

procedure TFormListOfKeyWords.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 DestroyTimer.Enabled:=true;
end;

procedure TFormListOfKeyWords.ListBox1DblClick(Sender: TObject);
var
  P : TPoint;
  n : integer;
begin
 GetCursorPos(P);
 P:=ListBox1.ScreenToClient(P);
 n:=ListBox1.ItemAtPos(P,true);
 if n>-1 then ClipBoard.AsText:=ListBox1.Items[n];
end;

procedure TFormListOfKeyWords.Button1Click(Sender: TObject);
begin
 Close;
end;

procedure TFormListOfKeyWords.Copy1Click(Sender: TObject);
begin
 ClipBoard.AsText:=ListBox1.Items[PopupMenu1.Tag];
end;

procedure TFormListOfKeyWords.ListBox1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  i : integer;
  ItemNo : Integer;
begin
 ItemNo:=ListBox1.ItemAtPos(MousePos,True);
 If ItemNo<>-1 then
 begin
  if not ListBox1.Selected[ItemNo] then
  begin
   ListBox1.Selected[ItemNo]:=True;
  end;
  PopupMenu1.Tag:=ItemNo;
  PopupMenu1.Popup(ListBox1.ClientToScreen(MousePos).X,ListBox1.ClientToScreen(MousePos).Y);
 end else
 begin
  for i:=0 to ListBox1.Items.Count-1 do
  ListBox1.Selected[i]:=false;
 end;
end;

procedure TFormListOfKeyWords.Search1Click(Sender: TObject);
begin
 With SearchManager.NewSearch do
 begin
  Show;
  SearchEdit.Text:=':KeyWord('+ListBox1.Items[Self.PopupMenu1.Tag]+'):';
  DoSearchNow(nil);
 end;
end;

procedure TFormListOfKeyWords.DBOpened(Sender: TObject);
begin
 DBInOpening:=false;
end;

procedure TFormListOfKeyWords.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 //ESC
 if Key = 27 then Close();
end;

end.
