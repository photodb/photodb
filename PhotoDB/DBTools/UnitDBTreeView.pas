unit UnitDBTreeView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ImgList, DB, ExtCtrls, JPEG, CommCtrl,
  UnitDBKernel, GraphicCrypt, DBCMenu, Menus,
  AppEvnts, DropSource, DropTarget, CommonDBSupport, DragDropFile, DragDrop,
  UnitDBCommon, UnitDBCommonGraphics, uDBDrawing, uFileUtils,
  uDBPopupMenuInfo, uMemory, uDBForm, uGraphicUtils, uDBUtils,
  Dolphin_DB, uConstants;

type
  TItemData = record
    ID : integer;
    Crypted : Boolean;
  end;

  PItemData = ^TItemData;

type
  TFormCreateDBFileTree = class(TDBForm)
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
  private
    { Private declarations }
    DBInOpening: Boolean;
    FStatusProgress: TProgressBar;
    FID: Integer;
    FPath: string;
    DBCanDrag: Boolean;
    DBDragPoint: TPoint;
    WorkTable, TempTable: TDataSet;
    procedure LoadLanguage;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID : string; override;
  public
    { Public declarations }
    FDBFileName: string;
    FTerminating: Boolean;
    FCanFree: Boolean;
  end;

procedure MakeDBFileTree(DBFileName: string);

implementation

uses ExplorerUnit, Searching, UnitOpenQueryThread, ProgressActionUnit;

{$R *.dfm}

//TODO: create new-look preview and drawg and drop, access to fields via class
procedure MakeDBFileTree(DBFileName: string);
var
  FormCreateDBFileTree: TFormCreateDBFileTree;
begin
  Application.CreateForm(TFormCreateDBFileTree, FormCreateDBFileTree);
  FormCreateDBFileTree.FDBFileName := DBFileName;
  FormCreateDBFileTree.Execute;
end;

procedure TFormCreateDBFileTree.TreeView1GetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
  Node.SelectedIndex := Node.ImageIndex;
end;

procedure TFormCreateDBFileTree.TreeView1GetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  if Node.Data <> nil then
    if TItemData(Node.Data^).Crypted then
    begin
      Node.ImageIndex := 4;
      Exit;
    end;
  if Node.Parent = nil then
  begin
    Node.ImageIndex := 0;
    Exit;
  end;
  if Node.HasChildren then
  begin
    if Node.Expanded then
      Node.ImageIndex := 3
    else
      Node.ImageIndex := 2;
  end
  else
    Node.ImageIndex := 1;
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
  K: Integer;
begin
  Button1.Enabled := False;
  WorkTable.First;
  StatusBar1.Panels[1].Text := L('Building tree of collection');
  TreeView1.Items.Clear;
  TreeView1.Items.Add(nil, ExtractFileName(FDBFileName)).Data := nil;
  FStatusProgress.Max := WorkTable.RecordCount;
  for K := 1 to WorkTable.RecordCount do
  begin
    AddFile(WorkTable.FieldByName('FFileName').AsString, WorkTable.FieldByName('ID').AsInteger,
      ValidCryptBlobStreamJPG(WorkTable.FieldByName('Thum')), False
      { not FileExistsSafe(WorkTable.FieldByName('FFileName').AsString) } );
    WorkTable.Next;
    if K mod 50 = 0 then
      FStatusProgress.Position := K;
    if (K = 1) and (TreeView1.Items.Count < 100) then
      TreeView1.FullExpand;
    Application.ProcessMessages;
    if FTerminating then
    begin
      FCanFree := True;
      Exit;
    end;
  end;
  StatusBar1.Panels[1].Text := '';
  FStatusProgress.Position := 0;
  Button1.Enabled := True;
end;

procedure TFormCreateDBFileTree.AddFile(FileName: String; ID : Integer; Crypted, Deleted : boolean);
var
  I: Integer;
  S: string;
  Sb: Integer;
  N: TTreeNode;
  P: PItemData;

  function GetChildByName(TTN: TTreeNode; S: string; ID: Integer; Crypted: Boolean): TTreeNode;
  var
    FN: TTreeNode;
  begin
    FN := TTN.GetFirstChild;
    if FN = nil then
    begin
      Result := TreeView1.Items.AddChild(TTN, S);
      Result.Text := S;
      GetMem(P, SizeOf(TItemData));
      P^.ID := ID;
      P^.Crypted := Crypted;
      Result.Data := P;
      Exit;
    end
    else
    begin
      if FN.Text = S then
      begin
        Result := FN;
        Exit;
      end;
    end;
    while True do
    begin
      FN := TTN.GetNextChild(FN);
      if FN = nil then
      begin
        Result := TreeView1.Items.AddChild(TTN, S);
        Result.Text := S;
        GetMem(P, SizeOf(TItemData));
        P^.ID := ID;
        P^.Crypted := Crypted;
        Result.Data := P;
        Exit;
      end;
      if FN.Text = S then
      begin
        Result := FN;
        Exit;
      end;
    end;
  end;

begin
  N := TreeView1.Items[0];
  if FileName = '' then
    Exit;
  Sb := 1;
  for I := 1 to Length(FileName) do
  begin
    if FileName[I] = '\' then
    begin
      S := Copy(FileName, Sb, I - Sb);
      Sb := I + 1;
      N := GetChildByName(N, S, ID, False);
    end;
  end;
  S := Copy(FileName, Sb, Length(FileName) - Sb + 1);
  GetChildByName(N, S, ID, Crypted);
end;

procedure TFormCreateDBFileTree.Execute;
var
  OpenProgress: TProgressActionForm;
  C, I: Integer;
begin
  WorkTable := GetQuery;
  TempTable := GetQuery;
  SetSQL(WorkTable, 'Select ID, FFileName, Access, Thum,Rotated,Rating,FFileName from $DB$');
  SetSQL(TempTable, 'Select ID, FFileName, Access, Thum,Rotated,Rating,FFileName from $DB$');
  TOpenQueryThread.Create(WorkTable, DBOpened);
  OpenProgress := GetProgressWindow;
  OpenProgress.OneOperation := True;
  OpenProgress.OperationCounter.Inverse := True;
  OpenProgress.OperationCounter.Text := '';
  OpenProgress.OperationProgress.Inverse := True;
  OpenProgress.OperationProgress.Text := '';
  OpenProgress.SetAlternativeText(L('Please wait while the search is executed'));
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
  WorkTable.First;

  TOpenQueryThread.Create(TempTable, DBOpened);
  DBInOpening := True;
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
  TempTable.First;
  OpenProgress.Release;

  Show;
  Button1Click(Self);
end;

procedure TFormCreateDBFileTree.DestroyTimerTimer(Sender: TObject);
begin
  if FCanFree then
  begin
    DestroyTimer.Enabled := False;
    Release;
  end;
end;

procedure TFormCreateDBFileTree.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DestroyTimer.Enabled := True;
  FTerminating := True;
end;

procedure TFormCreateDBFileTree.FormCreate(Sender: TObject);
begin
  DBInOpening := True;
  DropFileTarget1.Register(Self);
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
  Node: TTreeNode;
  J: TJPEGImage;
  Ico: TIcon;
  B, TempBitmap, Image: TBitmap;
  P: TPoint;
  PassWord: string;
  Exists, W, H: Integer;
begin
  GetCursorPos(P);
  Node := TreeView1.Selected;
  if Node = nil then
    Exit;
  TreeView1.Select(Node);
  if not Node.HasChildren then
  begin
    if Node.Data = nil then
      Exit;
    FID := TItemData(Node.Data^).ID;
    Label1.Show;
    Panel2.Show;
    Label2.Show;
    TempTable.First;
    TempTable.Locate('ID', TItemData(Node.Data^).ID, []);
    if TempTable.FieldByName('ID').AsInteger <> TItemData(Node.Data^).ID then
    begin
      Label2.Caption := L('Unknown file');
      B := TBitmap.Create;
      B.PixelFormat := Pf24bit;
      B.Width := 102;
      B.Height := 102;
      FillColorEx(B, ClWindow);
      Exists := 0;
      DrawAttributes(B, 102, 0, 0, 0, '', False, Exists);
      Image1.Picture.Graphic := B;
      B.Free;
      Exit;
    end;
    Label2.Caption := 'ID = ' + IntToStr(TempTable.FieldByName('ID').AsInteger);
    if TItemData(Node.Data^).Crypted then
    begin
      PassWord := DBkernel.FindPasswordForCryptBlobStream(TempTable.FieldByName('thum'));
      B := TBitmap.Create;
      try
        B.PixelFormat := pf24bit;
        B.Width := 102;
        B.Height := 102;
        FillColorEx(B, ClWindow);

        if PassWord = '' then
        begin
          Ico := TIcon.Create;
          try
            Ico.Handle := LoadIcon(DBKernel.IconDllInstance, 'SLIDE_SHOW');
            B.Canvas.Draw(102 div 2 - Ico.Width div 2, 102 div 2 - Ico.Height div 2, Ico);
          finally
            F(Ico);
          end;
          Exists := 0;
          DrawAttributes(B, 102, 0, 0, 0, TempTable.FieldByName('FFileName').AsString, True, Exists);
        end
        else
        begin
          J := TJpegImage.Create;
          try
            DeCryptBlobStreamJPG(TempTable.FieldByName('thum'), PassWord, J);
            B.Canvas.Draw(50 - J.Width div 2, 50 - J.Height div 2, J);
          finally
            F(J);
          end;
          Exists := 0;
          DrawAttributes(B, 102, TempTable.FieldByName('Rating').AsInteger, TempTable.FieldByName('Rotated').AsInteger,
            TempTable.FieldByName('Access').AsInteger, TempTable.FieldByName('FFileName').AsString,
            ValidCryptBlobStreamJPG(TempTable.FieldByName('thum')), Exists);
        end;
        Image1.Picture.Graphic := B;
      finally
        F(B);
      end;
    end
    else
    begin
      J := TJPEGImage.Create;
      J.Assign(TempTable.FieldByName('Thum'));
      B := TBitmap.Create;
      B.PixelFormat := Pf24bit;
      B.Width := 102;
      B.Height := 102;
      FillColorEx(B, ClWindow);

      if (J.Width > 100) or (J.Height > 100) then
      begin
        TempBitmap := TBitmap.Create;
        TempBitmap.PixelFormat := Pf24bit;
        TempBitmap.Assign(J);
        W := J.Width;
        H := J.Height;
        ProportionalSize(100, 100, W, H);
        Image := TBitmap.Create;
        Image.PixelFormat := Pf24bit;
        DoResize(W, H, TempBitmap, Image);
        TempBitmap.Free;
        B.Canvas.Draw(50 - Image.Width div 2, 50 - Image.Height div 2, Image);
      end
      else
        B.Canvas.Draw(50 - J.Width div 2, 50 - J.Height div 2, J);
      J.Free;
      ApplyRotate(B, TempTable.FieldByName('Rotated').AsInteger);

      Exists := 0;
      DrawAttributes(B, 102, TempTable.FieldByName('Rating').AsInteger, TempTable.FieldByName('Rotated').AsInteger,
        TempTable.FieldByName('Access').AsInteger, TempTable.FieldByName('FFileName').AsString,
        ValidCryptBlobStreamJPG(TempTable.FieldByName('thum')), Exists, TempTable.FieldByName('ID').AsInteger);
      Image1.Picture.Graphic := B;
      B.Free;
    end;
  end
  else
  begin
    Label1.Hide;
    Panel2.Hide;
    Label2.Hide;
  end;
end;

procedure TFormCreateDBFileTree.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('File tree of current collection');
    Button1.Caption := L('Build tree');
    Label1.Caption := L('Information') + ':';
    OpeninExplorer1.Caption := L('Open in explorer');
  finally
    EndTranslate;
  end;
end;

procedure TFormCreateDBFileTree.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with Params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TFormCreateDBFileTree.Image1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Info: TDBPopupMenuInfo;
begin
  Info := GetMenuInfoByID(FID);
  try
    Info.AttrExists := False;
    TDBPopupMenu.Instance.Execute(Self, Image1.ClientToScreen(MousePos).X, Image1.ClientToScreen(MousePos).Y, Info);
  finally
    F(Info);
  end;
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
    FPath := IncludeTrailingBackslash(Path);
    Popupmenu1.Popup(TreeView1.ClientToScreen(MousePos).X, TreeView1.ClientToScreen(MousePos).Y);
  end else
  begin
    FPath := '';
    Node := TreeView1.GetNodeAt(MousePos.X, MousePos.Y);
    if Node <> nil then
    begin
      Info := GetMenuInfoByID(TItemData(Node.Data^).ID);
      try
        Info.AttrExists := False;
        TDBPopupMenu.Instance.Execute(Self, TreeView1.ClientToScreen(MousePos).X, TreeView1.ClientToScreen(MousePos).Y, Info);
      finally
        F(Info);
      end;
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
    SelectTimer.Enabled := False;
    SelectTimer.Enabled := True;
  end;

begin
  if Active then
    if Msg.message = WM_KEYDOWN then
      if Msg.Hwnd = TreeView1.Handle then
      begin
        if Msg.WParam = VK_LEFT then
          DoSelect;
        if Msg.WParam = VK_UP then
          DoSelect;
        if Msg.WParam = VK_RIGHT then
          DoSelect;
        if Msg.WParam = VK_DOWN then
          DoSelect;
      end;
end;

procedure TFormCreateDBFileTree.SelectTimerTimer(Sender: TObject);
begin
  TreeView1Click(Self);
  SelectTimer.Enabled := False;
end;

procedure TFormCreateDBFileTree.Image1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = MbLeft then
  begin
    DBCanDrag := True;
    GetCursorPos(DBDragPoint);
  end;
end;

procedure TFormCreateDBFileTree.Image1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  DBCanDrag := False;
end;

procedure TFormCreateDBFileTree.Image1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
  DragImage: TBitmap;
  Node: TTreeNode;
  Path: string;
begin
  if DBCanDrag then
  begin
    GetCursorPos(P);
    if (Abs(DBDragPoint.X - P.X) > 3) or (Abs(DBDragPoint.Y - P.Y) > 3) then
    begin
      Node := TreeView1.Selected;
      Path := '';
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
      if FileExistsSafe(Path) then
      begin
        DropFileSource1.Files.Clear;
        DropFileSource1.Files.Add(Path);
        DragImage := TBitmap.Create;
        DragImage.PixelFormat := pf24bit;
        DragImage.Assign(Image1.Picture.Graphic);
        DragImageList.Clear;
        DragImageList.Width := DragImage.Width;
        DragImageList.Height := DragImage.Height;
        DragImageList.Add(DragImage, nil);
        DragImage.Free;
        DropFileSource1.ImageIndex := 0;
        DropFileSource1.Execute;
        DBCanDrag := False;
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

function TFormCreateDBFileTree.GetFormID: string;
begin
  Result := 'DBTreeView';
end;

procedure TFormCreateDBFileTree.DBOpened(Sender: TObject; DS: TDataSet);
begin
  DBInOpening := False;
end;

procedure TFormCreateDBFileTree.DropFileSource1Feedback(Sender: TObject; Effect: Integer;
  var UseDefaultCursors: Boolean);
begin
  UseDefaultCursors := False;
end;

end.
