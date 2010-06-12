unit UnitHistoryForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Language, Dolphin_DB, Menus, UnitDBKernel,
  UnitDBCommonGraphics, UnitDBDeclare, GraphicCrypt;

type
  TFormHistory = class(TForm)
    Panel1: TPanel;
    InfoListBox: TListBox;
    Panel2: TPanel;
    Panel3: TPanel;
    Button1: TButton;
    InfoLabel: TLabel;
    PopupMenu1: TPopupMenu;
    View1: TMenuItem;
    Explorer1: TMenuItem;
    ReAddAll1: TMenuItem;
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
   Icons : array of TIcon;
   ItemsData : TList;
   Infos : TArStrings;
   FileList : TStrings;
    { Private declarations }
  public
   Procedure LoadLanguage;
   procedure LoadToolBarIcons;
   procedure SetFilesList(List : TStrings);
   procedure WriteLnLine(Sender: TObject; Line: string; Info : integer);

    { Public declarations }
  end;

procedure ShowHistory(List : TStrings);

implementation

uses ExplorerUnit, SlideShow, UnitUpdateDB;

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
 FileList:=nil;     
// DoubleBuffered:=true;
 SetLength(Infos,0);
 ItemsData:=TList.Create;

 InfoListBox.DoubleBuffered:=true;
 InfoListBox.ItemHeight:=InfoListBox.Canvas.TextHeight('Iy')*3+5;
 InfoListBox.Clear;
 LoadToolBarIcons;

 DBKernel.RecreateThemeToForm(self);
 LoadLanguage;
 PopupMenu1.Images:=DBkernel.ImageList;
 View1.ImageIndex:=DB_IC_SLIDE_SHOW;
 Explorer1.ImageIndex:=DB_IC_FOLDER;
 ReAddAll1.ImageIndex:=DB_IC_NEW;
end;

procedure TFormHistory.LoadLanguage;
begin
 InfoLabel.Caption:=TEXT_MES_HISTORY_INFO;
 Caption:=TEXT_MES_HISTORY;
 Button1.Caption:=TEXT_MES_OK;
 View1.Caption:=TEXT_MES_SLIDE_SHOW;
 Explorer1.Caption:=TEXT_MES_EXPLORER;  
 ReAddAll1.Caption:=TEXT_MES_READD_ALL;
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
  Info : TRecordsInfo;
  P : TPoint;
  n : integer;
  OneInfo : TOneRecordInfo;
begin
 GetCursorPos(P);
 p:=InfoListBox.ScreenToClient(P);
 n:=InfoListBox.ItemAtPos(P,true);
 if n<0 then exit;
 If Viewer=nil then
 Application.CreateForm(TViewer,Viewer);
 OneInfo:=GetInfoByFileNameA(FileList[n],false);
 Info:=GetRecordsFromOne(OneInfo);
 Viewer.Execute(Sender,Info);
end;

procedure TFormHistory.InfoListBoxContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  P, p1 : TPoint;
  n : integer;
begin
 GetCursorPos(P);
 p1:=InfoListBox.ScreenToClient(P);
 n:=InfoListBox.ItemAtPos(P1,true);
 if n<0 then exit;
 PopupMenu1.Tag:=n;
 InfoListBox.Selected[n]:=True;
 PopupMenu1.Popup(P.X,P.Y);
end;

procedure TFormHistory.View1Click(Sender: TObject);
var
  Info : TRecordsInfo;
  OneInfo : TOneRecordInfo;
begin
 If Viewer=nil then
 Application.CreateForm(TViewer,Viewer);
 OneInfo:=GetInfoByFileNameA(FileList[PopupMenu1.Tag],false);
 Info:=GetRecordsFromOne(OneInfo);
 Viewer.Execute(Sender,Info);
end;

procedure TFormHistory.Explorer1Click(Sender: TObject);
begin
 With ExplorerManager.NewExplorer do
 begin
  SetOldPath(InfoListBox.Items[PopupMenu1.Tag]);
  SetPath(GetDirectory(FileList[PopupMenu1.Tag]));
  Show;
 end;
end;

procedure TFormHistory.InfoListBoxMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
begin
 Height:=InfoListBox.Canvas.TextHeight('Iy')*3+5;
end;

procedure TFormHistory.InfoListBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
 DoInfoListBoxDrawItem(Control as TListBox,Index,Rect,State,
 ItemsData,Icons,false,nil,Infos);
end;
         
procedure TFormHistory.SetFilesList(List: TStrings);
var
  i : integer;
  pass : String;
begin
 FileList:=TStringList.Create;
 InfoListBox.Clear;
 for i:=0 to List.Count-1 do
 begin
  FileList.Add(List[i]);
  if FileExists(List[i]) then
  begin
   if GraphicCrypt.ValidCryptGraphicFile(List[i]) then
   begin
    pass:=DBkernel.FindPasswordForCryptImageFile(List[i]);
    if pass='' then
    begin
     WriteLnLine(self,Format(TEXT_MES_UNABLE_TO_FIND_PASS_FOR_FILE_F,[List[i]]),LINE_INFO_WARNING);
    end else
    begin
     WriteLnLine(self,Format(TEXT_MES_UNABLE_TO_ADD_FILE_F,[List[i]]),LINE_INFO_PLUS);
    end;
   end else
   WriteLnLine(self,Format(TEXT_MES_UNABLE_TO_ADD_FILE_F,[List[i]]),LINE_INFO_OK)
  end else
  WriteLnLine(self,Format(TEXT_MES_UNABLE_TO_ADD_FILE_F,[List[i]]),LINE_INFO_ERROR);
 end;
// InfoListBox.Items:=List;
end;

procedure TFormHistory.LoadToolBarIcons;
var
  index : integer;

  procedure AddIcon(Name : String);
  begin
   Icons[index]:=TIcon.Create;
   Icons[index].Handle:=LoadIcon(DBKernel.IconDllInstance,PChar(Name));
   Inc(index);
  end;

begin
 index:=0;
 SetLength(Icons,7);
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
 ItemsData.Free;
end;

procedure TFormHistory.WriteLnLine(Sender: TObject; Line: string; Info : integer);
var
  p : PInteger;
  i : integer;
const
  TopRecords = 0;
begin
 LockWindowUpdate(Handle);
 SetLength(Infos,Length(Infos)+1);
 for i:=length(Infos)-2 downto TopRecords do
 begin
  Infos[i+1]:=Infos[i];
 end;

 GetMem(p,SizeOf(integer));
 p^:=Info;
 ItemsData.Insert( TopRecords,p);
 InfoListBox.Items.Insert( TopRecords,Line);

 LockWindowUpdate(0);
end;

procedure TFormHistory.ReAddAll1Click(Sender: TObject);
var
  i : integer;
begin
 for i:=0 to FileList.Count-1 do
 begin
  if FileExists(FileList[i]) then
  begin
   UpdaterDB.AddFile(FileList[i]);
  end;
 end;
// InfoListBox.Items:=List;
end;

end.
