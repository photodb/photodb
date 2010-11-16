unit UnitDBTreeView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ImgList, DB, ExtCtrls, JPEG, CommCtrl,
  Dolphin_DB, Language, UnitDBKernel, GraphicCrypt, DBCMenu, Menus,
  AppEvnts, DropSource, DropTarget, CommonDBSupport, DragDropFile, DragDrop,
  UnitDBCommon, UnitDBCommonGraphics, uDBDrawing, uFileUtils,
  uDBPopupMenuInfo;

type
  TItemData = record
    ID : integer;
    Crypted : Boolean;
  end;

  PItemData = ^TItemData;

type
  TFormCreateDBFileTree = class(TForm)
    TreeView1: TTreeView;
    ImageList1: TImageList;
    Panel1: TPanel;
    Button1: TButton;
    Label1: TLabel;
    StatusBar1: TStatusBar;
    Panel2: TPanel;
    Image1: TImage;
    PopupMenu1: TPopupMenu;
    OpeninExplorer1: TMenuItem;
    Label2: TLabel;
    ApplicationEvents1: TApplicationEvents;
    SelectTimer: TTimer;
    DropFileSource1: TDropFileSource;
    DragImageList: TImageList;
    DropFileTarget1: TDropFileTarget;
    DestroyTimer: TTimer;
    procedure TreeView1GetSelectedIndex(Sender: TObject; Node: TTreeNode);
    procedure TreeView1GetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure TreeView1Expanded(Sender: TObject; Node: TTreeNode);
    procedure TreeView1Expanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure AddFile(FileName : String; ID : Integer; Crypted, Deleted : boolean);
    procedure Execute;
    procedure DestroyTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure TreeView1Click(Sender: TObject);
    procedure Image1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure TreeView1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure OpeninExplorer1Click(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure SelectTimerTimer(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure DBOpened(Sender : TObject; DS : TDataSet);
    procedure DropFileSource1Feedback(Sender: TObject; Effect: Integer;
      var UseDefaultCursors: Boolean);
  protected
    procedure CreateParams(VAR Params: TCreateParams); override;
  private
  DBInOpening : boolean;
  fStatusProgress : TProgressBar;
  FID : integer;
  FPath : string;
  DBCanDrag : Boolean;
  DBDragPoint : TPoint;
  WorkTable, TempTable : TDataSet;
    { Private declarations }
  public
  FDBFileName : String;
  FTerminating : boolean;
  FCanFree : boolean;
  procedure LoadLanguage;
    { Public declarations }
  end;

Procedure MakeDBFileTree(DBFileName : String);

implementation

uses ExplorerUnit, Searching, UnitOpenQueryThread, ProgressActionUnit;

{$R *.dfm}

Procedure MakeDBFileTree(DBFileName : String);
var
 FormCreateDBFileTree: TFormCreateDBFileTree;
begin
 Application.CreateForm(TFormCreateDBFileTree, FormCreateDBFileTree);
 FormCreateDBFileTree.FDBFileName:=DBFileName;
 FormCreateDBFileTree.Execute;
end;

procedure TFormCreateDBFileTree.TreeView1GetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
 Node.SelectedIndex := Node.ImageIndex;
end;

procedure TFormCreateDBFileTree.TreeView1GetImageIndex(Sender: TObject; Node: TTreeNode);
begin
 if Node.Data<>nil then
 if TItemData(Node.Data^).Crypted then
 begin
  Node.ImageIndex := 4;
  Exit;
 end;
 If Node.Parent=nil then
 begin
  Node.ImageIndex := 0;
  Exit;
 end;
  if Node.HasChildren then
  begin
   if Node.Expanded then Node.ImageIndex := 3  else  Node.ImageIndex := 2;
  end else Node.ImageIndex := 1;
end;

procedure TFormCreateDBFileTree.TreeView1Expanded(Sender: TObject; Node: TTreeNode);
begin
  TreeView1.Repaint;
end;

procedure TFormCreateDBFileTree.TreeView1Expanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
begin
  TreeView1.Repaint;
end;

procedure TFormCreateDBFileTree.Button1Click(Sender: TObject);
var
  k : integer;
begin
  Button1.Enabled:=false;
  WorkTable.First;
  StatusBar1.Panels[1].Text:=TEXT_MES_MAKEING_DB_TREE;
  TreeView1.Items.Clear;
  TreeView1.Items.Add(nil,ExtractFileName(FDBFileName)).Data:=nil;
  fStatusProgress.Max:=WorkTable.RecordCount;
  for k:=1 to WorkTable.RecordCount do
  begin

   AddFile(WorkTable.FieldByName('FFileName').AsString,WorkTable.FieldByName('ID').AsInteger,ValidCryptBlobStreamJPG(WorkTable.FieldByName('Thum')),false{not FileExists(WorkTable.FieldByName('FFileName').AsString)});
   WorkTable.Next;
   if k mod 50 = 0 then
   fStatusProgress.Position:=k;
   if (k=1) and (TreeView1.Items.Count<100) then TreeView1.FullExpand;
   Application.ProcessMessages;
   if FTerminating then
   begin
    FCanFree:=true;
    Exit;
   end;
  end;
  StatusBar1.Panels[1].Text:='';
  fStatusProgress.Position:=0;
  Button1.Enabled:=true;
end;

procedure TFormCreateDBFileTree.AddFile(FileName: String; ID : Integer; Crypted, Deleted : boolean);
var
  i : integer;
  s : String;
  sb : integer;
  N : TTreeNode;
  p : PItemData;

 function GetChildByName(TTN : TTreeNode; S : String; ID : Integer; Crypted : boolean) : TTreeNode;
  var
    FN : TTreeNode;
 begin
  FN:=TTN.getFirstChild;
  if FN=nil then
  begin
   Result:=TreeView1.Items.AddChild(TTN,S);
   Result.Text:=S;
   GetMem(p,SizeOf(TItemData));
   p^.ID:=ID;
   p^.Crypted:=Crypted;
   Result.Data:=p;
   exit;
  end else
  begin
   if FN.Text=S then
   begin
    Result:=FN;
    Exit;
   end;
  end;
  While true do
  begin
   FN:=TTN.GetNextChild(FN);
   if FN=nil then
   begin
    Result:=TreeView1.Items.AddChild(TTN,S);
    Result.Text:=S;
    GetMem(p,SizeOf(TItemData));
    p^.ID:=ID;
    p^.Crypted:=Crypted;
    Result.Data:=p;
    exit;
   end;
   if FN.Text=S then
   begin
    Result:=FN;
    Exit;
   end;
  end;
 end;

begin
 N:=TreeView1.Items[0];
 if FileName='' then exit;
 sb:=1;
 for i:=1 to Length(FileName) do
 begin
  if FileName[i]='\' then
  begin
   s:=Copy(FileName,sb,i-sb);
   sb:=i+1;
   N:=GetChildByName(N,S,ID,false);
  end;
 end;
 s:=Copy(FileName,sb,Length(FileName)-sb+1);
 GetChildByName(N,S,ID,Crypted);
end;

procedure TFormCreateDBFileTree.Execute;
var
  OpenProgress : TProgressActionForm;
  c, i : integer;
begin

  WorkTable:=GetQuery;
  TempTable:=GetQuery;
  SetSQL(WorkTable,'Select ID, FFileName, Access, Thum,Rotated,Rating,FFileName from $DB$');
  SetSQL(TempTable,'Select ID, FFileName, Access, Thum,Rotated,Rating,FFileName from $DB$');
  TOpenQueryThread.Create(WorkTable,DBOpened);
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
  WorkTable.First;

  TOpenQueryThread.Create(TempTable,DBOpened);
  DBInOpening:=true;
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
  TempTable.First;
  OpenProgress.Release;

 Show;
 Button1Click(self);
end;

procedure TFormCreateDBFileTree.DestroyTimerTimer(Sender: TObject);
begin
 if FCanFree then
 begin
  DestroyTimer.Enabled:=false;
  Release;
 end;
end;

procedure TFormCreateDBFileTree.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 DestroyTimer.Enabled:=true;
 FTerminating:=true;
end;

procedure TFormCreateDBFileTree.FormCreate(Sender: TObject);
begin
  DBInOpening := True;
  DropFileTarget1.register(Self);
  FTerminating := False;
  FCanFree := False;
  FStatusProgress := CreateProgressBar(StatusBar1, 0);
  LoadLanguage;
  ImageList1.BkColor := clWindow;
  TreeView1.Color := clWindow;
  TreeView1.Font.Color := clWindowText;

  ImageList_ReplaceIcon(ImageList1.Handle, -1, LoadIcon(HInstance, 'MAINICON'));
  ImageList_ReplaceIcon(ImageList1.Handle, -1, LoadIcon(DBKernel.IconDllInstance, 'PICTURE'));
  ImageList_ReplaceIcon(ImageList1.Handle, -1, UnitDBKernel.Icons[DB_IC_DIRECTORY + 1]);
  ImageList_ReplaceIcon(ImageList1.Handle, -1, UnitDBKernel.Icons[DB_IC_EXPLORER + 1]);
  ImageList_ReplaceIcon(ImageList1.Handle, -1, UnitDBKernel.Icons[DB_IC_KEY + 1]);
  ImageList_ReplaceIcon(ImageList1.Handle, -1, UnitDBKernel.Icons[DB_IC_DELETE_INFO + 1]);

  Label1.Hide;
  Panel2.Hide;
  Label2.Hide;
  PopupMenu1.Images := DBKernel.ImageList;
  OpeninExplorer1.ImageIndex := DB_IC_EXPLORER;
end;

procedure TFormCreateDBFileTree.TreeView1Click(Sender: TObject);
var
  Node : TTreeNode;
  J : TJPEGImage;
  Ico : TIcon;
  B, TempBitmap, Image : TBitmap;
  p : TPoint;
  PassWord : String;
  Exists, w, h : integer;
begin
 GetCursorPos(p);
 Node:=TreeView1.Selected;
 if node=nil then exit;
 TreeView1.Select(Node);
 if not Node.HasChildren then
 begin
  if Node.Data=nil then exit;
  FID:=TItemData(Node.Data^).ID;
  Label1.Show;
  Panel2.Show;
  Label2.Show;
  TempTable.First;
  TempTable.Locate('ID',TItemData(Node.Data^).ID,[]);
  if TempTable.FieldByName('ID').AsInteger<>TItemData(Node.Data^).ID then
  begin
   Label2.Caption:=TEXT_MES_ERROR_ITEM;
   B := TBitmap.Create;
   B.PixelFormat:=pf24bit;
   B.Width:=102;
   B.height:=102;
   FillColorEx(B, clWindow);
   Exists:=0;
   DrawAttributes(B,102,0,0,0,'',false,Exists);
   Image1.Picture.Graphic:=B;
   B.Free;
   exit;
  end;
  Label2.Caption:='ID = '+IntToStr(TempTable.FieldByName('ID').AsInteger);
  if TItemData(Node.Data^).Crypted then
  begin
   PassWord:=DBkernel.FindPasswordForCryptBlobStream(TempTable.FieldByName('thum'));
   B := TBitmap.Create;
   B.PixelFormat:=pf24bit;

   B.Width:=102;
   B.height:=102;
   FillColorEx(B, clWindow);

   if PassWord='' then
   begin
    Ico := TIcon.Create;
    Ico.Handle:=LoadIcon(DBKernel.IconDllInstance,'SLIDE_SHOW');
    B.Canvas.Draw(102 div 2 - Ico.Width div 2,102 div 2 - Ico.height div 2,Ico);
    Ico.Free;
    Exists:=0;
    DrawAttributes(B,102,0,0,0,TempTable.FieldByName('FFileName').AsString,true,Exists);
   end else
   begin
    J:= TJpegImage.Create;
    try
      DeCryptBlobStreamJPG(TempTable.FieldByName('thum'),PassWord,J);
      B.Canvas.Draw(50-J.Width div 2,50 - J.Height div 2,J);
    finally
      J.Free;
    end;
    Exists:=0;
    DrawAttributes(B,102,TempTable.FieldByName('Rating').AsInteger,TempTable.FieldByName('Rotated').AsInteger,TempTable.FieldByName('Access').AsInteger,TempTable.FieldByName('FFileName').AsString,ValidCryptBlobStreamJPG(TempTable.FieldByName('thum')),Exists);
   end;
   Image1.Picture.Graphic:=B;
   B.Free;
  end else
  begin
   J := TJPEGImage.Create;
   J.Assign(TempTable.FieldByName('Thum'));
   B := TBitmap.Create;
   B.PixelFormat:=pf24bit;
   B.Width:=102;
   B.height:=102;
   FillColorEx(B, clWindow);

   if (J.Width>100) or (J.Height>100) then
   begin
    TempBitmap := TBitmap.Create;
    TempBitmap.PixelFormat:=pf24bit;
    TempBitmap.Assign(J);
    w:=J.Width;
    h:=J.Height;
    ProportionalSize(100,100,w,h);
    Image := TBitmap.Create;
    Image.PixelFormat:=pf24bit;
    DoResize(w,h,TempBitmap,Image);
    TempBitmap.Free;
    B.Canvas.Draw(50-Image.Width div 2,50 - Image.Height div 2,Image);
   end else
   B.Canvas.Draw(50-J.Width div 2,50 - J.Height div 2,J);
   J.Free;
   ApplyRotate(B, TempTable.FieldByName('Rotated').AsInteger);

   Exists:=0;
   DrawAttributes(B,102,TempTable.FieldByName('Rating').AsInteger,TempTable.FieldByName('Rotated').AsInteger,TempTable.FieldByName('Access').AsInteger,TempTable.FieldByName('FFileName').AsString,ValidCryptBlobStreamJPG(TempTable.FieldByName('thum')),Exists,TempTable.FieldByName('ID').AsInteger);
   Image1.Picture.Graphic:=B;
   B.Free;
  end;
 end else
 begin
  Label1.Hide;
  Panel2.Hide;
  Label2.Hide;
 end;
end;

procedure TFormCreateDBFileTree.LoadLanguage;
begin
 Caption:=TEXT_MES_MAKE_DB_TREE_CAPTION;
 Button1.Caption:=TEXT_MES_DO_MAKE_DB_TREE;
 Label1.Caption:=TEXT_MES_SELECTED_INFO;
 OpeninExplorer1.Caption:=TEXT_MES_OPEN_IN_EXPLORER;
end;

procedure TFormCreateDBFileTree.CreateParams(var Params: TCreateParams);
begin
 Inherited CreateParams(Params);
 Params.WndParent := GetDesktopWindow;
 with params do
 ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TFormCreateDBFileTree.Image1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  info : TDBPopupMenuInfo;
begin
  info:=GetMenuInfoByID(FID);
  Info.AttrExists:=false;
  TDBPopupMenu.Instance.Execute(Image1.ClientToScreen(MousePos).x,Image1.ClientToScreen(MousePos).y,info);
end;

procedure TFormCreateDBFileTree.TreeView1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Node: TTreeNode;
  Path: string;
  Info: TDBPopupMenuInfo;
begin
  Path := '';
  Node := TreeView1.GetNodeAt(MousePos.X, MousePos.Y);
  if Node = nil then
    Exit;
  if Node.Parent = nil then
    Exit;
  repeat
    Path := Node.Text + Path;
    if Node.Parent.Parent <> nil then
      Path := '\' + Path;
    Node := Node.Parent;
    if Node = nil then
      Break;
    if Node.Parent = nil then
      Break;
  until False;

  if DirectoryExists(Path) then
  begin
    FPath := Path;
    FormatDir(FPath);
    Popupmenu1.Popup(TreeView1.ClientToScreen(MousePos).X, TreeView1.ClientToScreen(MousePos).Y);
  end else
  begin
    FPath := '';
    Node := TreeView1.GetNodeAt(MousePos.X, MousePos.Y);
    if Node <> nil then
    begin
      Info := GetMenuInfoByID(TItemData(Node.Data^).ID);
      Info.AttrExists := False;
      TDBPopupMenu.Instance.Execute(TreeView1.ClientToScreen(MousePos).X, TreeView1.ClientToScreen(MousePos).Y, Info);
    end;
  end;
end;

procedure TFormCreateDBFileTree.OpeninExplorer1Click(Sender: TObject);
begin
  if DirectoryExists(FPath) then
    with ExplorerManager.NewExplorer(False) do
    begin
      SetStringPath(FPath, False);
      Show;
    end;
end;

procedure TFormCreateDBFileTree.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);

 procedure DoSelect;
 begin
  SelectTimer.Enabled:=false;
  SelectTimer.Enabled:=true;
 end;

begin
  if Active then
  if Msg.message=256 then
  if Msg.hwnd=TreeView1.Handle then
  begin
   if Msg.wParam=37 then
   DoSelect;
   if Msg.wParam=38 then
   DoSelect;
   if Msg.wParam=39 then
   DoSelect;
   if Msg.wParam=40 then
   DoSelect;
  end;
end;

procedure TFormCreateDBFileTree.SelectTimerTimer(Sender: TObject);
begin
 TreeView1Click(self);
 SelectTimer.Enabled:=false;
end;

procedure TFormCreateDBFileTree.Image1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 If Button=mbLeft then
 begin
  DBCanDrag:=True;
  GetCursorPos(DBDragPoint);
 end;
end;

procedure TFormCreateDBFileTree.Image1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 DBCanDrag:=false;
end;

procedure TFormCreateDBFileTree.Image1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  p : TPoint;
  DragImage : TBitmap;
  Node : TTreeNode;
  Path : String;
begin
 If DBCanDrag then
 begin
  GetCursorPos(p);
  If (abs(DBDragPoint.x-p.x)>3) or (abs(DBDragPoint.y-p.y)>3) then
  begin
   Node:=TreeView1.Selected;
   Path:='';
   if Node=nil then exit;
   if Node.Parent=nil then exit;
   Repeat
    Path:=Node.Text+Path;
    if Node.Parent.Parent<>nil then Path:='\'+Path;
    Node:=Node.Parent;
    if Node=nil then Break;
    if Node.Parent=nil then Break;
   Until false;
   if FileExists(Path) then
   begin
    DropFileSource1.Files.Clear;
    DropFileSource1.Files.Add(Path);
    DragImage := TBitmap.Create;
    DragImage.PixelFormat:=pf24bit;
    DragImage.Assign(Image1.Picture.Graphic);
    DragImageList.Clear;
    DragImageList.Width:=DragImage.Width;
    DragImageList.Height:=DragImage.Height;
    DragImageList.Add(DragImage,nil);
    DragImage.free;
    DropFileSource1.ImageIndex := 0;
    DropFileSource1.Execute;
    DBCanDrag:=false;
   end;
  end;
 end;
end;

procedure TFormCreateDBFileTree.FormDestroy(Sender: TObject);
begin
 DropFileTarget1.Unregister;
 FreeDS(WorkTable);
 FreeDS(TempTable);
end;

procedure TFormCreateDBFileTree.DBOpened(Sender : TObject; DS : TDataSet);
begin
 DBInOpening:=false;
end;

procedure TFormCreateDBFileTree.DropFileSource1Feedback(Sender: TObject;
  Effect: Integer; var UseDefaultCursors: Boolean);
begin
 UseDefaultCursors:=false;
end;

end.
