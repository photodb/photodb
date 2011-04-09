unit replaceform;

interface

uses
  UnitDBKernel, DBCMenu, dolphin_db, Windows, Messages, SysUtils, Variants,
  Classes, Graphics, Controls, Forms, GraphicCrypt, uVistaFuncs, UnitDBDeclare,
  DropTarget, DragDropFile, DragDrop, DropSource, Menus, ImgList, StdCtrls,
  ExtCtrls, ComCtrls,  Dialogs, DB, CommCtrl, JPEG, Math, uMemory,
  ActiveX, UnitBitmapImageList, CommonDBSupport, UnitDBCommon,
  UnitDBCommonGraphics, uLogger, uDBDrawing, uFileUtils, uGraphicUtils,
  uConstants, uDBPopupMenuInfo, uShellIntegration, uDBTypes, uDBForm,
  uSettings, uListViewUtils, uAssociations, uDBAdapter;

type
  TDBReplaceForm = class(TDBForm)
    LvMain: TListView;
    SizeImageList: TImageList;
    Panel2: TPanel;
    LabelDBRating: TLabel;
    LabelDBWidth: TLabel;
    LabelDBHeight: TLabel;
    Image2: TImage;
    LabelDBInfo: TLabel;
    DbLabel_id: TLabel;
    LabelDBName: TLabel;
    LabelDBSize: TLabel;
    LabelDBPath: TLabel;
    DB_ID: TEdit;
    DB_NAME: TEdit;
    DB_RATING: TEdit;
    DB_WIDTH: TEdit;
    DB_HEIGHT: TEdit;
    DB_SIZE: TEdit;
    DB_PATH: TEdit;
    Panel3: TPanel;
    Image1: TImage;
    LabelCurrentInfo: TLabel;
    LabelFName: TLabel;
    LabelFSize: TLabel;
    LabelFWidth: TLabel;
    LabelFHeight: TLabel;
    LabelFPath: TLabel;
    F_NAME: TEdit;
    F_SIZE: TEdit;
    F_WIDTH: TEdit;
    F_HEIGHT: TEdit;
    PopupMenu1: TPopupMenu;
    Delete1: TMenuItem;
    DropFileSource1: TDropFileSource;
    DropFileTarget1: TDropFileTarget;
    DragImageList: TImageList;
    F_PATH: TMemo;
    BtnReplaceAndDeleteDuplicates: TButton;
    BtnAdd: TButton;
    BtnReplace: TButton;
    BtnSkip: TButton;
    BtnDeleteFile: TButton;
    BtnSkipAll: TButton;
    BtnReplaceAll: TButton;
    BtnAddAll: TButton;
    procedure ExecuteToAdd(Filename : string; LongImageID : AnsiString; var ResultAction: Integer; var SelectedID: Integer; rec_ : TImageDBRecordA);
    procedure readDBInfoByID(id : integer);
    procedure AddItem(Text : string; ID : integer; fbit_ : tbitmap);
    procedure LvMainSelectItem(Sender: TObject; Item: TListItem;Selected: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnReplaceAllClick(Sender: TObject);
    procedure BtnReplaceClick(Sender: TObject);
    procedure BtnSkipAllClick(Sender: TObject);
    procedure BtnSkipClick(Sender: TObject);
    procedure ReadFileInfo(FileName : string);
    procedure Image2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LvMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
        procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure Image2ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure LvMainCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Delete1Click(Sender: TObject);
    procedure LvMainContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure BtnReplaceAndDeleteDuplicatesClick(Sender: TObject);
    procedure BtnDeleteFileClick(Sender: TObject);
    procedure BtnAddAllClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Image1DblClick(Sender: TObject);
  private
    { Private declarations }
    FBitmapImageList: TBitmapImageList;
    WorkQuery: TDataSet;
    WDA: TDBAdapter;
    FCurrentFileName: string;
    FCurrentID: Integer;
    FSelectedMode,
    FSelectedID: Integer;
    procedure LoadLanguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
  end;

implementation

uses
  Searching,
  ExplorerUnit,
  UnitPasswordForm,
  SlideShow;

{$R *.dfm}

procedure TDBReplaceForm.Additem(Text: string; ID: integer; fbit_: tbitmap);
var
  New: TListItem;
  Bit: TBitmap;
  TempBitmap, FBit: TBitmap;
  Bs: TStream;
  J: TJpegImage;
  Password: string;
  Exists, W, H: Integer;
const
  ListItemPreviewSize = 102;
begin
  New := LvMain.Items.Add;
  New.Indent := ID;
  New.Caption := Text;
  Bit := TBitmap.Create;
  try
    Bit.PixelFormat := pf24bit;
    Bit.Width := ListItemPreviewSize;
    Bit.Height := ListItemPreviewSize;
    if WDA.Thumb = nil then
      Exit;

    J := TJpegImage.Create;
    try
      if ValidCryptBlobStreamJPG(WDA.Thumb) then
      begin
        Password := DBkernel.FindPasswordForCryptBlobStream(WDA.Thumb);
        if Password = '' then
          Password := GetImagePasswordFromUserBlob(WDA.Thumb, WDA.FileName);

        if Password <> '' then
        begin
          DeCryptBlobStreamJPG(WDA.Thumb, Password, J)
        end else
          Exit;
      end else
      begin
        BS := GetBlobStream(WDA.Thumb, BmRead);
        try
          J.LoadFromStream(BS);
        finally
          F(BS);
        end;
      end;
      FillColorEx(Bit, clWindow);
      if (J.Width > ListItemPreviewSize) or (J.Height > ListItemPreviewSize) then
      begin
        TempBitmap := TBitmap.Create;
        try
          TempBitmap.PixelFormat := pf24bit;
          FBit := TBitmap.Create;
          try
            FBit.PixelFormat := pf24bit;
            FBit.Assign(J);
            W := FBit.Width;
            H := FBit.Height;
            ProportionalSize(ListItemPreviewSize, ListItemPreviewSize, W, H);
            DoResize(W, H, FBit, TempBitmap);
          finally
            F(FBit);
          end;
          Bit.Canvas.Draw(ListItemPreviewSize div 2 - TempBitmap.Width div 2,
            ListItemPreviewSize div 2 - TempBitmap.Height div 2, TempBitmap);
        finally
          F(TempBitmap);
        end;
      end else
        Bit.Canvas.Draw(ListItemPreviewSize div 2 - J.Width div 2, ListItemPreviewSize div 2 - J.Height div 2, J);

      ApplyRotate(Bit, WDA.Rotation);
      Exists := 0;
      DrawAttributes(Bit, ListItemPreviewSize, WDA.Rating,
        WDA.Rotation, WDA.Access, WDA.FileName, False, Exists, WDA.ID);
    finally
      F(J);
    end;
    FBitmapImageList.AddBitmap(Bit);
    Bit := nil;
  finally
    F(Bit);
  end;
  New.ImageIndex := FBitmapImageList.Count - 1;
  LvMain.Refresh;
end;

procedure TDBReplaceForm.ExecuteToAdd(FileName: string; LongImageID: AnsiString; var ResultAction: Integer; var SelectedID: Integer;
  Rec_: TImageDBRecordA);
var
  I: Integer;
begin
  FBitmapImageList.Clear;
  if LongImageID = '' then
    Exit;
  FSelectedMode := Result_invalid;
  FSelectedID := 0;

  LvMain.Clear;
  FCurrentFileName := Filename;
  WorkQuery.Active := False;
  SetSQL(WorkQuery, 'SELECT * FROM $DB$ WHERE StrTh = :str ');
  SetAnsiStrParam(WorkQuery, 0, LongImageID);
  WorkQuery.Active := True;
  if WorkQuery.RecordCount = 0 then
  begin
    EventLog(Format('TDBReplaceForm::ExecuteToAdd() not found any db record for file %s and strth "%s"',
        [FileName, LongImageID]));
    Exit;
  end;
  if WorkQuery.RecordCount = 1 then
  begin
    LvMain.Visible := False;
    Width := Panel3.Width + Panel2.Width + 10;
    BtnReplaceAll.Enabled := True;
    BtnReplaceAndDeleteDuplicates.Enabled := False;
    BtnReplace.Enabled := True;
  end else
  begin
    LvMain.Visible := True;
    BtnReplaceAll.Enabled := False;
    BtnReplace.Enabled := True;
    BtnReplaceAndDeleteDuplicates.Enabled := False;
  end;
  WorkQuery.First;
  ReadFileInfo(Filename);
  for I := 1 to WorkQuery.RecordCount do
  begin
    AddItem(WDA.Name, WDA.ID, nil);
    WorkQuery.Next;
  end;
  ReadDBInfoByID(WDA.ID);
  ShowModal;
  ResultAction := FSelectedMode;
  SelectedID := FSelectedID;
end;

procedure TDBReplaceForm.ReadDBInfoByID(ID: Integer);
var
  Bit: TBitmap;
  Bs: TStream;
  Password: string;
  FQuery: TDataSet;
  Exists, W, H: Integer;
  TempBitmap, FBit: TBitmap;
  JPEG: TJpegImage;
  DA: TDBAdapter;
const
  ListItemPreviewSize = 100;

begin
  FQuery := GetQuery;
  DA := TDBAdapter.Create(FQuery);
  try
    SetSQl(FQuery, 'SELECT * FROM $DB$ WHERE ID=' + IntToStr(ID));
    FQuery.Active := True;
    FCurrentID := DA.ID;
    DB_ID.Text := IntToStr(ID);
    DB_NAME.Text := DA.Name;
    DB_RATING.Text := IntToStr(DA.Rating);
    DB_WIDTH.Text := Format(L('%dpx.'), [DA.Width]);
    DB_HEIGHT.Text := Format(L('%dpx.'), [DA.Height]);
    DB_SIZE.Text := SizeInText(DA.FileSize);
    DB_PATH.Text := DA.FileName;

    JPEG := TJpegImage.Create;
    try
      Bit := Tbitmap.Create;
      try
        Bit.PixelFormat := pf24bit;
        Bit.SetSize(ListItemPreviewSize, ListItemPreviewSize);
        Bit.Canvas.Brush.Color := clBtnFace;
        Bit.Canvas.Pen.Color := clBtnFace;
        if DA.Thumb = nil then
          Exit;

        if ValidCryptBlobStreamJPG(DA.Thumb) then
        begin
          Password := DBkernel.FindPasswordForCryptBlobStream(DA.Thumb);
          if Password = '' then
            Password := GetImagePasswordFromUserBlob(DA.Thumb, DA.FileName);

          if Password <> '' then
          begin
            DeCryptBlobStreamJPG(DA.Thumb, Password, JPEG);
          end else
            Exit;

        end else
        begin
          BS := GetBlobStream(DA.Thumb, BmRead);
          try
            JPEG.LoadfromStream(BS)
          finally
            F(BS);
          end;
        end;
        Bit.Canvas.Rectangle(0, 0, ListItemPreviewSize, ListItemPreviewSize);

        if (JPEG.Width > ListItemPreviewSize) or (JPEG.Height > ListItemPreviewSize) then
        begin
          TempBitmap := TBitmap.Create;
          try
            TempBitmap.PixelFormat := pf24bit;
            FBit := TBitmap.Create;
            try
              FBit.PixelFormat := pf24bit;
              FBit.Assign(JPEG);
              W := FBit.Width;
              H := FBit.Height;
              ProportionalSize(ListItemPreviewSize, ListItemPreviewSize, W, H);
              DoResize(W, H, FBit, TempBitmap);
            finally
              F(FBit);
            end;
            Bit.Canvas.Draw(ListItemPreviewSize div 2 - TempBitmap.Width div 2,
              ListItemPreviewSize div 2 - TempBitmap.Height div 2, TempBitmap);
          finally
            F(TempBitmap);
          end;
        end else
        begin
          Bit.Canvas.Draw(ListItemPreviewSize div 2 - JPEG.Width div 2,
            ListItemPreviewSize div 2 - JPEG.Height div 2, JPEG);
        end;
        ApplyRotate(Bit, DA.Rotation);
        Exists := 0;
        DrawAttributes(Bit, ListItemPreviewSize, DA.Rating,
          DA.Rotation, DA.Access, DA.FileName, False, Exists, DA.ID);

        Image2.Picture.Graphic := Bit;

      finally
        F(Bit);
      end;
    finally
      F(JPEG)
    end;
  finally
    FreeDS(FQuery);
    F(DA);
  end;
end;

procedure TDBReplaceForm.LvMainSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Item <> nil then
    ReadDBInfoByID(Item.Indent);

  BtnReplace.Enabled := Selected;
  BtnReplaceAndDeleteDuplicates.Enabled := Selected;
end;

procedure TDBReplaceForm.FormCreate(Sender: TObject);
begin
  DisableWindowCloseButton(Handle);
  WorkQuery := GetQuery;
  WDA := TDBAdapter.Create(WorkQuery);
  DropFileTarget1.register(Self);
  FBitmapImageList := TBitmapImageList.Create;
  LvMain.HotTrack := Settings.Readbool('Options', 'UseHotSelect', True);
  LvMain.DoubleBuffered := True;
  LvMainSelectItem(Sender, nil, False);
  DBKernel.RegisterChangesID(Self, Self.ChangedDBDataByID);
  LoadLanguage;
end;

procedure TDBReplaceForm.BtnAddClick(Sender: TObject);
begin
  FSelectedMode := Result_add;
  FSelectedID := StrToInt(DB_ID.Text);
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.BtnReplaceAllClick(Sender: TObject);
begin
  FSelectedMode := Result_replace_all;
  FSelectedID := StrToInt(DB_ID.Text);
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.BtnReplaceClick(Sender: TObject);
begin
  FSelectedMode := Result_replace;
  FSelectedID := StrToInt(DB_ID.Text);
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.BtnSkipAllClick(Sender: TObject);
begin
  FSelectedMode := Result_skip_all;
  FSelectedID := StrToInt(DB_ID.Text);
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.BtnSkipClick(Sender: TObject);
begin
  FSelectedMode := Result_skip;
  FSelectedID := StrToInt(DB_ID.Text);
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.ReadFileInfo(FileName: string);
var
  G: TGraphic;
  Fb, Fb1: TBitmap;
  Filesize_, I: Integer;
  Password: string;
  GraphicClass : TGraphicClass;
const
  FilePreviewSize = 100;
begin
  Filesize_ := GetFileSizeByName(FileName);
  F_NAME.Text := ExtractFileName(FileName);
  F_SIZE.Text := SizeInText(FileSize_);
  F_PATH.Text := FileName;
  for I := Length(FileName) downto 1 do
    if FileName[I] = #0 then
      Delete(FileName, I, 1);

  GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName));
  if GraphicClass = nil then
    Exit;

  G := nil;
  try
    if ValidCryptGraphicFile(FileName) then
    begin
      Password := DBkernel.FindPasswordForCryptImageFile(FileName);
      if Password <> '' then
        G := DeCryptGraphicFile(FileName, Password)
      else
      begin
        MessageBoxDB(Handle, Format(L('Unable to load image from file: %s'), [FileName]), L('Warning'), TD_BUTTON_OK,
          TD_ICON_INFORMATION);
        Exit;
      end;
    end else
    begin
      try
        G := GraphicClass.Create;
        G.LoadFromFile(FileName);
      except
        MessageBoxDB(Handle, Format(L('Unable to load image from file: %s'), [FileName]), L('Warning'), TD_BUTTON_OK,
          TD_ICON_INFORMATION);
        Exit;
      end;
    end;
    F_WIDTH.Text := Format(L('%dpx.'), [G.Width]);
    F_HEIGHT.Text := Format(L('%dpx.'), [G.Height]);
    JPEGScale(G, FilePreviewSize, FilePreviewSize);
    Fb := TBitmap.Create;
    try
      Fb.PixelFormat := pf24bit;
      Fb1 := Tbitmap.Create;
      try
        Fb1.PixelFormat := pf24bit;
        Fb1.Width := FilePreviewSize;
        Fb1.Height := FilePreviewSize;
        Fb1.Canvas.Brush.Color := ClBtnFace;
        Fb1.Canvas.Pen.Color := ClBtnFace;
        Fb1.Canvas.Rectangle(0, 0, FilePreviewSize, FilePreviewSize);
        if G.Width > G.Height then
        begin
          Fb.Width := FilePreviewSize;
          Fb.Height := Round(FilePreviewSize * (G.Height / G.Width));
        end else
        begin
          Fb.Width := Round(FilePreviewSize * (G.Width / G.Height));
          Fb.Height := FilePreviewSize;
        end;
        Fb.Canvas.StretchDraw(Rect(0, 0, Fb.Width, Fb.Height), G);
        Fb1.Canvas.Draw(FilePreviewSize div 2 - Fb.Width div 2, FilePreviewSize div 2 - Fb.Height div 2, Fb);
        Image1.Picture.Graphic := Fb1;
      finally
        F(Fb1);
      end;
    finally
      F(Fb);
    end;
  finally
    F(G);
  end;
end;

procedure TDBReplaceForm.Image2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = MbLeft) and FileExistsSafe(DB_PATH.Text) then
  begin
    DragImageList.Clear;
    DropFileSource1.Files.Clear;
    DropFileSource1.Files.Add(DB_PATH.Text);

    CreateDragImage(Image2.Picture.Bitmap, DragImageList, Font, DB_PATH.Text);

    DropFileSource1.ImageIndex := 0;
    DropFileSource1.Execute;
  end;
end;

procedure TDBReplaceForm.LvMainMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Item: TListItem;
begin
  if (Button = MbLeft) and (LvMain.GetItemAt(X, Y) <> nil) and FileExistsSafe(DB_PATH.Text) then
  begin
    Item := LvMain.GetItemAt(X, Y);
    DragImageList.Clear;
    DropFileSource1.Files.Clear;
    DropFileSource1.Files.Add(DB_PATH.Text);

    CreateDragImage(FBitmapImageList[Item.ImageIndex].Bitmap, DragImageList, Font, DropFileSource1.Files[0]);

    DropFileSource1.ImageIndex := 0;
    DropFileSource1.Execute;
  end;
end;

procedure TDBReplaceForm.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and FileExistsSafe(FCurrentFileName) then
  begin
   DragImageList.Clear;
   DropFileSource1.Files.Clear;
   DropFileSource1.Files.Add(FCurrentFileName);

   CreateDragImage(Image1.Picture.Bitmap, DragImageList, Font, FCurrentFileName);

   DropFileSource1.ImageIndex := 0;
   DropFileSource1.Execute;
  end;
end;

procedure TDBReplaceForm.ChangedDBDataByID(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);
begin
  if ID = FCurrentID then
    ReadDBInfoByID(ID);
end;

procedure TDBReplaceForm.Image2ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  MenuInfo: TDBPopupMenuInfo;
  MenuRecord: TDBPopupMenuInfoRecord;
  I: Integer;
begin
  WorkQuery.First;
  for I := 1 to WorkQuery.RecordCount do
  begin
    if WDA.ID = StrToInt(DB_ID.Text) then
      Break;
    WorkQuery.Next;
  end;
  MenuInfo := TDBPopupMenuInfo.Create;
  MenuRecord := TDBPopupMenuInfoRecord.CreateFromDS(WorkQuery);
  MenuInfo.Add(MenuRecord);
  MenuInfo.AttrExists := False;
  TDBPopupMenu.Instance.Execute(Self, Image2.ClientToScreen(MousePos).X, Image2.ClientToScreen(MousePos).Y, MenuInfo);
end;

procedure TDBReplaceForm.LvMainCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
var
  R, R1, R2: TRect;
  B: TBitmap;
const
  DrawTextOpt = DT_NOPREFIX + DT_CENTER + DT_WORDBREAK + DT_EDITCONTROL;
  ListItemPreviewSize = 102;
begin
  if FBitmapImageList.Count = 0 then
    Exit;
  R := Item.DisplayRect(DrBounds);
  if not RectInRect(Sender.ClientRect, R) then
    Exit;

  R1 := Item.DisplayRect(DrIcon);
  R2 := Item.DisplayRect(DrLabel);
  B := TBitmap.Create;
  try
    B.PixelFormat := pf24bit;
    B.Assign(FBitmapImageList[Item.ImageIndex].Bitmap);
    if not(Sender.IsEditing and (Sender.ItemFocused = Item)) then
    begin
      if Item.Selected then
      begin
        SelectedColor(B, MakeDarken(ClWindow, 0.5));
        Sender.Canvas.Pen.Color := MakeDarken(clWindow, 0.9);
        Sender.Canvas.Brush.Color := MakeDarken(clWindow, 0.9);
        Sender.Canvas.FillRect(R2);
      end else
      begin
        Sender.Canvas.Pen.Color := clWindow;
        Sender.Canvas.Brush.Color := clWindow;
        Sender.Canvas.FillRect(R2);
      end;
      Sender.Canvas.Font.Color := clWindowText;
      if CdsHot in State then
      begin
        Sender.Canvas.Font.Style := [FsUnderline];
        DrawText(Sender.Canvas.Handle, PWideChar(Item.Caption), Length(Item.Caption), R2, DrawTextOpt);
      end else
      begin
        Sender.Canvas.Font.Style := [];
        DrawText(Sender.Canvas.Handle, PWideChar(Item.Caption), Length(Item.Caption), R2, DrawTextOpt);
      end;
    end;
    Sender.Canvas.Draw(R1.Left + ((R1.Right - R1.Left) div 2 - ListItemPreviewSize div 2), R1.Top, B);
  finally
    F(B);
  end;
  DefaultDraw := False;
end;

procedure TDBReplaceForm.FormDestroy(Sender: TObject);
begin
  F(WDA);
  FreeDS(WorkQuery);
  DropFileTarget1.Unregister;
  F(FBitmapImageList);
  DBKernel.UnRegisterChangesID(Self, Self.ChangedDBDataByID);
end;

function TDBReplaceForm.GetFormID: string;
begin
  Result := 'ReplaceDBItem';
end;

procedure TDBReplaceForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
end;

procedure TDBReplaceForm.Delete1Click(Sender: TObject);
var
  I: Integer;
  FQuery: TDataSet;
  EventInfo: TEventValues;
  SQL_: string;
begin
  for I := 1 to LvMain.Items.Count do
    if LvMain.Items[I - 1].Indent = PopupMenu1.Tag then
    begin
      if ID_OK = MessageBoxDB(Handle, L('Do you really want to delete this information from the collection?'), L('Confirm'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING)
        then
      begin
        FQuery := GetQuery;
        try
          FQuery.Active := False;
          SQL_ := 'DELETE FROM $DB$ WHERE (ID = ' + IntToStr(PopupMenu1.Tag) + ')';
          SetSQL(FQuery, SQL_);
          try
            ExecSQL(FQuery);
            DBKernel.DoIDEvent(Self, PopupMenu1.Tag, [EventID_Param_Delete], EventInfo);
            LvMain.Items.Delete(I - 1);
          except
          end;
        finally
          FreeDS(FQuery);
        end;
        Break;
      end;
    end;
end;

procedure TDBReplaceForm.LvMainContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Item: TListItem;
begin
  Item := LvMain.GetItemAt(MousePos.X, MousePos.Y);
  if Item = nil then
    Exit;
  PopupMenu1.Tag := Item.Indent;
  PopupMenu1.Popup(LvMain.ClientTOScreen(MousePos).X, LvMain.ClientTOScreen(MousePos).Y);
end;

procedure TDBReplaceForm.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Please select necessary action');
    Delete1.Caption := L('Delete');
    LabelFName.Caption := L('Name');
    LabelFSize.Caption := L('Size');
    LabelFWidth.Caption := L('Width');
    LabelFHeight.Caption := L('Height');
    LabelFPath.Caption := L('Path');
    LabelCurrentInfo.Caption := L('Current information from file') + ':';
    BtnAdd.Caption := L('Add');
    BtnReplaceAll.Caption := L('Replace for all');
    BtnSkipAll.Caption := L('Skip for all');
    BtnAddAll.Caption := L('Add for all');
    BtnReplace.Caption := L('Replace');
    BtnSkip.Caption := L('Skip');
    BtnReplaceAndDeleteDuplicates.Caption := L('Replace and delete duplicates');
    BtnDeleteFile.Caption := L('Delete file');
    LabelDBInfo.Caption := L('Current information from collection') + ':';
    DbLabel_id.Caption := L('ID');
    LabelDBName.Caption := L('Name');
    LabelDBRating.Caption := L('Rating');
    LabelDBWidth.Caption := L('Width');
    LabelDBHeight.Caption := L('Height');
    LabelDBSize.Caption := L('Size');
    LabelDBPath.Caption := L('Path');
  finally
    EndTranslate;
  end;
end;

procedure TDBReplaceForm.BtnReplaceAndDeleteDuplicatesClick(Sender: TObject);
begin
  FSelectedMode := Result_Replace_And_Del_Dublicates;
  FSelectedID := StrToInt(DB_ID.Text);
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.BtnDeleteFileClick(Sender: TObject);
begin
  if ID_OK <> MessageBoxDB(Handle, L('Do you really want to delete this file?'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
    Exit;
  FSelectedMode := Result_Delete_File;
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.BtnAddAllClick(Sender: TObject);
begin
  FSelectedMode := Result_add_all;
  FSelectedID := StrToInt(DB_ID.Text);
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Release;
end;

procedure TDBReplaceForm.Image1DblClick(Sender: TObject);
begin
  if Viewer = nil then
    Application.CreateForm(TViewer, Viewer);
  Viewer.ShowFile(FCurrentFileName);
  Viewer.Show;
end;

end.
