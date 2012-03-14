unit replaceform;

interface

uses
  UnitDBKernel,
  DBCMenu,
  dolphin_db,
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  GraphicCrypt,
  UnitDBDeclare,
  DropTarget,
  DragDropFile,
  DragDrop,
  DropSource,
  Menus,
  ImgList,
  StdCtrls,
  ExtCtrls,
  ComCtrls,
  Dialogs,
  DB,
  JPEG,
  Math,
  uMemory,
  ActiveX,
  UnitBitmapImageList,
  CommonDBSupport,
  uJpegUtils,
  uBitmapUtils,
  uLogger,
  uDBDrawing,
  uFileUtils,
  uGraphicUtils,
  Types,
  uConstants,
  uDBPopupMenuInfo,
  uShellIntegration,
  uDBTypes,
  uDBForm,
  uSettings,
  uListViewUtils,
  uAssociations,
  uDBAdapter,
  MPCommonObjects,
  EasyListview,
  MPCommonUtilities,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  uThemesUtils,
  RAWImage;

type
  TDBReplaceForm = class(TDBForm)
    SizeImageList: TImageList;
    PnDBInfo: TPanel;
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
    PnFileInfo: TPanel;
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
    PmListView: TPopupActionBar;
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
    CbForAll: TCheckBox;
    LvMain: TEasyListview;
    procedure ExecuteToAdd(Filename: string; LongImageID: string;
      var ResultAction: Integer; var SelectedID: Integer; rec_: TImageDBRecordA);
    procedure readDBInfoByID(id: Integer);
    procedure AddItem(Text: string; id: Integer; fbit_: TBitmap);
    procedure FormCreate(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnReplaceClick(Sender: TObject);
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
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Delete1Click(Sender: TObject);
    procedure LvMainContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure BtnReplaceAndDeleteDuplicatesClick(Sender: TObject);
    procedure BtnDeleteFileClick(Sender: TObject);
    procedure BtnAddAllClick(Sender: TObject);
    procedure Image1DblClick(Sender: TObject);
    procedure LvMainItemThumbnailDraw(Sender: TCustomEasyListview;
      Item: TEasyItem; ACanvas: TCanvas; ARect: TRect;
      AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
    procedure LvMainItemSelectionChanged(Sender: TCustomEasyListview;
      Item: TEasyItem);
    procedure LvMainMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LvMainMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
    FBitmapImageList: TBitmapImageList;
    WorkQuery: TDataSet;
    WDA: TDBAdapter;
    FCurrentFileName: string;
    FCurrentID: Integer;
    FSelectedMode,
    FSelectedID: Integer;
    FListViewMouseDown: Boolean;
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

procedure TDBReplaceForm.Additem(Text: string; ID: integer; fbit_: TBitmap);
var
  New: TEasyItem;
  Bit: TBitmap;
  FBit: TBitmap;
  Bs: TStream;
  J: TJpegImage;
  Password: string;
  W, H: Integer;
const
  ListItemPreviewSize = 102;
begin
  New := LvMain.Items.Add;
  New.Data := TDBPopupMenuInfoRecord.CreateFromDS(WorkQuery);
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

      if (J.Width > ListItemPreviewSize) or (J.Height > ListItemPreviewSize) then
      begin
        FBit := TBitmap.Create;
        try
          FBit.PixelFormat := pf24bit;
          FBit.Assign(J);
          W := FBit.Width;
          H := FBit.Height;
          ProportionalSize(ListItemPreviewSize, ListItemPreviewSize, W, H);
          DoResize(W, H, FBit, Bit);
        finally
          F(FBit);
        end;
      end else
        Bit.Assign(J);

      ApplyRotate(Bit, WDA.Rotation);
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

procedure TDBReplaceForm.ExecuteToAdd(FileName: string; LongImageID: string; var ResultAction: Integer; var SelectedID: Integer;
  Rec_: TImageDBRecordA);
var
  I: Integer;
begin
  FBitmapImageList.Clear;
  if LongImageID = '' then
    Exit;
  FSelectedMode := Result_invalid;
  FSelectedID := 0;

  FCurrentFileName := Filename;
  WorkQuery.Active := False;
  SetSQL(WorkQuery, 'SELECT * FROM $DB$ WHERE StrTh = :str ');
  SetStrParam(WorkQuery, 0, LongImageID);
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
    Width := PnFileInfo.Left + PnFileInfo.Width + PnDBInfo.Width + 25;
    CbForAll.Enabled := True;
    BtnReplaceAndDeleteDuplicates.Enabled := False;
    BtnReplace.Enabled := True;
  end else
  begin
    LvMain.Visible := True;
    CbForAll.Enabled := False;
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
  if LvMain.Items.Count > 0 then
    LvMain.Items[0].Selected := True;

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
        Bit.Canvas.Brush.Color := Theme.PanelColor;
        Bit.Canvas.Pen.Color := Theme.PanelColor;
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

procedure TDBReplaceForm.LvMainItemSelectionChanged(Sender: TCustomEasyListview;
  Item: TEasyItem);
begin
  if Item <> nil then
    ReadDBInfoByID(TDBPopupMenuInfoRecord(Item.Data).ID);

  BtnReplace.Enabled := Item.Selected;
  BtnReplaceAndDeleteDuplicates.Enabled := Item.Selected;
end;

procedure TDBReplaceForm.FormCreate(Sender: TObject);
begin
  DisableWindowCloseButton(Handle);
  FListViewMouseDown := False;
  WorkQuery := GetQuery;
  WDA := TDBAdapter.Create(WorkQuery);
  DropFileTarget1.register(Self);
  FBitmapImageList := TBitmapImageList.Create;
  LvMain.DoubleBuffered := True;
  DBKernel.RegisterChangesID(Self, Self.ChangedDBDataByID);
  LoadLanguage;
  SetLVSelection(LvMain, False, [cmbLeft]);
end;

procedure TDBReplaceForm.BtnAddClick(Sender: TObject);
begin
  if not CbForAll.Checked then
    FSelectedMode := Result_Add
  else
    FSelectedMode := Result_Add_All;
  FSelectedID := StrToInt(DB_ID.Text);
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.BtnReplaceClick(Sender: TObject);
begin
  if not CbForAll.Checked then
    FSelectedMode := Result_replace
  else
    FSelectedMode := Result_replace_all;
  FSelectedID := StrToInt(DB_ID.Text);
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.BtnSkipClick(Sender: TObject);
begin
  if not CbForAll.Checked then
    FSelectedMode := Result_skip
  else
    FSelectedMode := Result_skip_all;
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
        if G is TRAWImage then
          TRAWImage(G).IsPreview := True;
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
        Fb1.Canvas.Brush.Color := Theme.PanelColor;
        Fb1.Canvas.Pen.Color := Theme.PanelColor;
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
  Item: TEasyItem;
begin
  Item := ItemByPointImage(LvMain, Point(X, Y));
  if (Button = MbLeft) and (Item <> nil) and FileExistsSafe(DB_PATH.Text) then
    FListViewMouseDown := True;
end;

procedure TDBReplaceForm.LvMainMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if FListViewMouseDown and (LvMain.Selection.Count = 1) then
  begin
    FListViewMouseDown := False;
    DragImageList.Clear;
    DropFileSource1.Files.Clear;
    DropFileSource1.Files.Add(DB_PATH.Text);

    CreateDragImage(FBitmapImageList[LvMain.Selection.First.ImageIndex].Bitmap, DragImageList, Font, DropFileSource1.Files[0]);

    DropFileSource1.ImageIndex := 0;
    DropFileSource1.Execute;
  end;
end;

procedure TDBReplaceForm.LvMainMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FListViewMouseDown := False;
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
  TDBPopupMenu.Instance.Execute(Self, Image2.ClientToScreen(MousePos).X, Image2.ClientToScreen(MousePos).Y, MenuInfo);
end;

procedure TDBReplaceForm.LvMainItemThumbnailDraw(Sender: TCustomEasyListview;
  Item: TEasyItem; ACanvas: TCanvas; ARect: TRect;
  AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
var
  Y: Integer;
  Data: TDBPopupMenuInfoRecord;
begin
  Data := TDBPopupMenuInfoRecord(Item.Data);
  DrawDBListViewItem(TEasyListview(Sender), ACanvas, Item, ARect,
                     FBitmapImageList, Y,
                     True, Data.ID, Data.ExistedFileName, Data.Rating, Data.Rotation,
                     Data.Access, Data.Crypted, Data.Include, Data.Exists, False);
end;

procedure TDBReplaceForm.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to LvMain.Items.Count - 1 do
    LvMain.Items[I].Data.Free;

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
    if TDBPopupMenuInfoRecord(LvMain.Items[I - 1]).ID = PmListView.Tag then
    begin
      if ID_OK = MessageBoxDB(Handle, L('Do you really want to delete this information from the collection?'), L('Confirm'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING)
        then
      begin
        FQuery := GetQuery;
        try
          FQuery.Active := False;
          SQL_ := 'DELETE FROM $DB$ WHERE (ID = ' + IntToStr(PmListView.Tag) + ')';
          SetSQL(FQuery, SQL_);
          try
            ExecSQL(FQuery);
            DBKernel.DoIDEvent(Self, PmListView.Tag, [EventID_Param_Delete], EventInfo);
            LvMain.Items[I - 1].Data.Free;
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
  Item: TEasyItem;
begin
  Item := ItemByPointImage(LvMain, MousePos);
  if Item = nil then
    Exit;
  Item.Selected := True;
  PmListView.Tag := TDBPopupMenuInfoRecord(Item.Data).ID;
  PmListView.Popup(LvMain.ClientTOScreen(MousePos).X, LvMain.ClientTOScreen(MousePos).Y);
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
    LabelCurrentInfo.Caption := L('Information from file') + ':';
    BtnAdd.Caption := L('Add');
    CbForAll.Caption := L('Do this action for all conflicts');
    BtnReplace.Caption := L('Replace');
    BtnSkip.Caption := L('Skip');
    BtnReplaceAndDeleteDuplicates.Caption := L('Replace and delete duplicates');
    BtnDeleteFile.Caption := L('Delete file');
    LabelDBInfo.Caption := L('Information from collection') + ':';
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
  FSelectedMode := Result_Replace_And_Del_Duplicates;
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

procedure TDBReplaceForm.Image1DblClick(Sender: TObject);
begin
  if Viewer = nil then
    Application.CreateForm(TViewer, Viewer);
  Viewer.ShowFile(FCurrentFileName);
  Viewer.Show;
end;

end.
