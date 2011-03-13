unit replaceform;

interface

uses
  UnitDBKernel, DBCMenu, dolphin_db, Windows, Messages, SysUtils, Variants,
  Classes, Graphics, Controls, Forms, GraphicCrypt, uVistaFuncs, UnitDBDeclare,
  DropTarget, DragDropFile, DragDrop, DropSource, Menus, ImgList, StdCtrls,
  ExtCtrls, ComCtrls,  Dialogs, DB, CommCtrl, JPEG, Math,
  ActiveX, UnitBitmapImageList, CommonDBSupport, UnitDBCommon,
  UnitDBCommonGraphics, uLogger, uDBDrawing, uFileUtils, uGraphicUtils,
  uConstants, uDBPopupMenuInfo, uShellIntegration, uDBTypes, uDBForm,
  uSettings;

type
  TDBReplaceForm = class(TDBForm)
    ListView1: TListView;
    SizeImageList: TImageList;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button5: TButton;
    Button6: TButton;
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
    DB_PATCH: TEdit;
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
    Button4: TButton;
    PopupMenu1: TPopupMenu;
    Delete1: TMenuItem;
    Button7: TButton;
    Button8: TButton;
    DropFileSource1: TDropFileSource;
    DropFileTarget1: TDropFileTarget;
    DragImageList: TImageList;
    F_PATCH: TMemo;
    procedure ExecuteToAdd(Filename : string; _ID : integer; thimg : string; addr_res, AddrSelID : pinteger; rec_ : TImageDBRecordA);
    procedure readDBInfoByID(id : integer);
    procedure additem(caption_ : string; ID : integer; fbit_ : tbitmap);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;Selected: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure ReadFileInfo(FileName : string);
    procedure Image2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
        procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure Image2ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure ListView1CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Delete1Click(Sender: TObject);
    procedure ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Image1DblClick(Sender: TObject);
  private
    { Private declarations }
    FBitmapImageList: TBitmapImageList;
    WorkQuery: TDataSet;
    procedure LoadLanguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure ReallignControls;
  end;

var
  // TODO: review!
  DBReplaceForm: TDBReplaceForm;
  Res_Address, ResIDAddress: Pinteger;
  Current_id_show: Integer;
  CurrentFileName: string;

implementation

uses
  Searching, ExplorerUnit, UnitPasswordForm, SlideShow;

{$R *.dfm}

procedure TDBReplaceForm.Additem(caption_: string; ID: integer; fbit_: tbitmap);
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
  New := ListView1.Items.Add;
  New.Indent := ID;
  New.Caption := Caption_;
  Bit := TBitmap.Create;
  Bit.PixelFormat := Pf24bit;
  Bit.Width := ListItemPreviewSize;
  Bit.Height := ListItemPreviewSize;
  if TBlobField(WorkQuery.FieldByName('thum')) = nil then
  begin
    Bit.Free;
    Exit;
  end;
  J := nil;
  if ValidCryptBlobStreamJPG(WorkQuery.FieldByName('thum')) then
  begin
    Password := DBkernel.FindPasswordForCryptBlobStream(WorkQuery.FieldByName('thum'));
    if Password = '' then
    begin
      Password := GetImagePasswordFromUserBlob(WorkQuery.FieldByName('thum'),
        WorkQuery.FieldByName('FFileName').AsString);
    end;
    if Password <> '' then
    begin
      J := TJpegImage.Create;
      DeCryptBlobStreamJPG(WorkQuery.FieldByName('thum'), Password, J)
    end else
    begin
      Bit.Free;
      Exit;
    end;
  end else
  begin
    BS := GetBlobStream(WorkQuery.FieldByName('thum'), BmRead);
    try
      J := TJpegImage.Create;
      if BS.Size <> 0 then
        J.LoadFromStream(BS) except
    end;
    BS.Free;
  end;
  FillColorEx(Bit, ClWindow);
  if (J.Width > ListItemPreviewSize) or (J.Height > ListItemPreviewSize) then
  begin
    TempBitmap := TBitmap.Create;
    TempBitmap.PixelFormat := Pf24bit;
    FBit := TBitmap.Create;
    FBit.PixelFormat := Pf24bit;
    FBit.Assign(J);
    W := FBit.Width;
    H := FBit.Height;
    ProportionalSize(ListItemPreviewSize, ListItemPreviewSize, W, H);
    DoResize(W, H, FBit, TempBitmap);
    FBit.Free;
    Bit.Canvas.Draw(ListItemPreviewSize div 2 - TempBitmap.Width div 2,
      ListItemPreviewSize div 2 - TempBitmap.Height div 2, TempBitmap);
    TempBitmap.Free;
  end
  else
  begin
    Bit.Canvas.Draw(ListItemPreviewSize div 2 - J.Width div 2, ListItemPreviewSize div 2 - J.Height div 2, J);
  end;
  ApplyRotate(Bit, WorkQuery.FieldByName('Rotated').AsInteger);
  Exists := 0;
  DrawAttributes(Bit, ListItemPreviewSize, WorkQuery.FieldByName('Rating').AsInteger,
    WorkQuery.FieldByName('Rotated').AsInteger, WorkQuery.FieldByName('Access').AsInteger,
    WorkQuery.FieldByName('FFileName').AsString, False, Exists, WorkQuery.FieldByName('ID').AsInteger);
  J.Free;
  FBitmapImageList.AddBitmap(Bit);
  New.ImageIndex := FBitmapImageList.Count - 1;
  ListView1.Refresh;
end;

procedure TDBReplaceForm.ExecuteToAdd(FileName: string; _ID: Integer; Thimg: string; Addr_Res, AddrSelID: PInteger;
  Rec_: TImageDBRecordA);
var
  I: Integer;
begin
  FBitmapImageList.Clear;
  if Thimg = '' then
    Exit;
  ResIDAddress := AddrSelID;
  Res_address := Addr_res;
  Res_address^ := Result_invalid;
  AddrSelID^ := 0;
  Listview1.Clear;
  CurrentFileName := Filename;
  WorkQuery.Active := False;
  SetSQL(WorkQuery, 'SELECT * FROM $DB$ WHERE StrTh = :str ');
  SetStrParam(WorkQuery, 0, Thimg);
  WorkQuery.Active := True;
  if WorkQuery.RecordCount = 0 then
  begin
    EventLog(Format('TDBReplaceForm::ExecuteToAdd() not found any db record for file %s and strth "%s"',
        [FileName, Thimg]));
    Exit;
  end;
  if WorkQuery.RecordCount = 1 then
  begin
    Listview1.Visible := False;
    Panel2.Left := Listview1.Left;
    Panel1.Left := 0;
    Width := Panel3.Width + Panel2.Width + (Width - ClientWidth);
    Button2.Enabled := True;
    Button7.Enabled := False;
    Button5.Enabled := True;
  end
  else
  begin
    Listview1.Visible := True;
    Button2.Enabled := False;
    Button5.Enabled := True;
    Button7.Enabled := False;
  end;
  WorkQuery.First;
  ReadFileInfo(Filename);
  for I := 1 to WorkQuery.RecordCount do
  begin
    AddItem(Trim(WorkQuery.FieldByName('Name').AsString), WorkQuery.FieldByName('ID').AsInteger, nil);
    WorkQuery.Next;
  end;
  ReadDBInfoByID(WorkQuery.FieldByName('ID').AsInteger);
  ShowModal;
end;

procedure TDBReplaceForm.ReadDBInfoByID(Id: Integer);
var
  Bit: TBitmap;
  Bs: TStream;
  Pic: TPicture;
  Password: string;
  FQuery: TDataSet;
  Exists, W, H: Integer;
  TempBitmap, FBit: TBitmap;
  JPEG: TJpegImage;
const
  ListItemPreviewSize = 100;
begin
  FQuery := GetQuery;
  FQuery.Active := False;
  SetSQl(FQuery, 'SELECT * FROM $DB$ WHERE ID=' + IntToStr(ID));
  FQuery.Active := True;
  Current_id_show := FQuery.FieldByName('ID').AsInteger;
  DB_ID.Text := IntToStr(ID);
  DB_NAME.Text := Trim(FQuery.FieldByName('Name').AsString);
  DB_RATING.Text := Inttostr(FQuery.FieldByName('Rating').AsInteger);
  DB_WIDTH.Text := Format(L('%dpx.'), [FQuery.FieldByName('Width').AsInteger]);
  DB_HEIGHT.Text := Format(L('%dpx.'), [FQuery.FieldByName('Height').AsInteger]);
  DB_SIZE.Text := SizeInText(FQuery.FieldByName('FileSize').AsInteger);
  DB_PATCH.Text := FQuery.FieldByName('FFileName').AsString;
  Pic := TPicture.Create;
  Pic.Graphic := TJPEGImage.Create;
  Bit := Tbitmap.Create;
  Bit.PixelFormat := Pf24bit;
  Bit.Width := ListItemPreviewSize;
  Bit.Height := ListItemPreviewSize;
  Bit.Canvas.Brush.Color := ClBtnFace;
  Bit.Canvas.Pen.Color := ClBtnFace;
  if TBlobField(FQuery.FieldByName('thum')) = nil then
  begin
    Bit.Free;
    Pic.Free;
    EventLog('TDBReplaceForm::ReadDBInfoByID()/FieldByName(thum)==null --> exit');
    Exit;
  end;
  if ValidCryptBlobStreamJPG(FQuery.FieldByName('thum')) then
  begin
    Password := DBkernel.FindPasswordForCryptBlobStream(FQuery.FieldByName('thum'));
    if Password = '' then
    begin
      Password := GetImagePasswordFromUserBlob(FQuery.FieldByName('thum'), FQuery.FieldByName('FFileName').AsString);
    end;
    if Password <> '' then
    begin
      JPEG := TJpegImage.Create;
      try
        DeCryptBlobStreamJPG(FQuery.FieldByName('thum'), Password, JPEG);
        Pic.Graphic := JPEG;
      finally
        JPEG.Free;
      end;
    end else
    begin
      EventLog('TDBReplaceForm::ReadDBInfoByID()/Password==null --> exit');
      Bit.Free;
      Pic.Free;
      Exit;
    end;
  end else
  begin
  BS := GetBlobStream(FQuery.FieldByName('thum'), BmRead);
  try
    if BS.Size <> 0 then
      Pic.Graphic.LoadfromStream(BS)
      except
      end;
    BS.Free;
  end;
  Bit.Canvas.Rectangle(0, 0, ListItemPreviewSize, ListItemPreviewSize);

  if (Pic.Width > ListItemPreviewSize) or (Pic.Height > ListItemPreviewSize) then
  begin
    TempBitmap := TBitmap.Create;
    TempBitmap.PixelFormat := Pf24bit;
    FBit := TBitmap.Create;
    FBit.PixelFormat := Pf24bit;
    FBit.Assign(Pic.Graphic);
    W := FBit.Width;
    H := FBit.Height;
    ProportionalSize(ListItemPreviewSize, ListItemPreviewSize, W, H);
    DoResize(W, H, FBit, TempBitmap);
    FBit.Free;
    Bit.Canvas.Draw(ListItemPreviewSize div 2 - TempBitmap.Width div 2,
      ListItemPreviewSize div 2 - TempBitmap.Height div 2, TempBitmap);
    TempBitmap.Free;
  end else
  begin
    Bit.Canvas.Draw(ListItemPreviewSize div 2 - Pic.Graphic.Width div 2,
      ListItemPreviewSize div 2 - Pic.Graphic.Height div 2, Pic.Graphic);
  end;
  ApplyRotate(Bit, FQuery.FieldByName('Rotated').AsInteger);
  Exists := 0;
  DrawAttributes(Bit, ListItemPreviewSize, FQuery.FieldByName('Rating').AsInteger,
    FQuery.FieldByName('Rotated').AsInteger, FQuery.FieldByName('Access').AsInteger,
    FQuery.FieldByName('FFileName').AsString, False, Exists, FQuery.FieldByName('ID').AsInteger);
  Pic.Free;
  if Image2.Picture.Bitmap = nil then
    Image2.Picture.Bitmap := Tbitmap.Create;
  Image2.Picture.Bitmap.Assign(Bit);
  Image2.Refresh;
  Bit.Free;
  FreeDS(FQuery);
end;

procedure TDBReplaceForm.ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Item <> nil then
  begin
    ReadDBInfoByID(Item.Indent);
  end;
  Button5.Enabled := Selected;
  Button7.Enabled := Selected;
end;

procedure TDBReplaceForm.FormCreate(Sender: TObject);
begin
  DisableWindowCloseButton(Handle);
  WorkQuery := GetQuery;
  DropFileTarget1.register(Self);
  FBitmapImageList := TBitmapImageList.Create;
  ListView1.HotTrack := Settings.Readbool('Options', 'UseHotSelect', True);
  Listview1.DoubleBuffered := True;
  ListView1SelectItem(Sender, nil, False);
  DBKernel.RegisterChangesID(Self, Self.ChangedDBDataByID);
  LoadLanguage;
  ReallignControls;
end;

procedure TDBReplaceForm.Button1Click(Sender: TObject);
begin
  Res_address^ := Result_add;
  ResIDAddress^ := StrToInt(DB_ID.Text);
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.Button2Click(Sender: TObject);
begin
  Res_address^ := Result_replace_all;
  ResIDAddress^ := StrToInt(DB_ID.Text);
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.Button5Click(Sender: TObject);
begin
  Res_address^ := Result_replace;
  ResIDAddress^ := StrToInt(DB_ID.Text);
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.Button3Click(Sender: TObject);
begin
  Res_address^ := Result_skip_all;
  ResIDAddress^ := StrToInt(DB_ID.Text);
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.Button6Click(Sender: TObject);
begin
  Res_Address^ := Result_skip;
  ResIDAddress^ := StrToInt(DB_ID.Text);
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.ReadFileInfo(FileName: string);
var
  Pic: TPicture;
  Fb, Fb1: Graphics.Tbitmap;
  Filesize_, I: Integer;
  Password: string;
const
  FilePreviewSize = 100;
begin
  Filesize_ := GetFileSizeByName(FileName);
  F_NAME.Text := ExtractFileName(FileName);
  F_SIZE.Text := SizeInText(FileSize_);
  F_PATCH.Text := FileName;
  for I := Length(FileName) downto 1 do
    if FileName[I] = #0 then
      Delete(FileName, I, 1);
  Pic := TPicture.Create;
  if ValidCryptGraphicFile(FileName) then
  begin
    Password := DBkernel.FindPasswordForCryptImageFile(FileName);
    if Password <> '' then
      Pic.Graphic := DeCryptGraphicFile(FileName, Password)
    else
    begin
      MessageBoxDB(Handle, Format(L('Unable to load image from file: %s'), [FileName]), L('Warning'), TD_BUTTON_OK,
        TD_ICON_INFORMATION);
      Exit;
    end;
  end else
  begin
    try
      Pic.LoadFromFile(FileName);
    except
      MessageBoxDB(Handle, Format(L('Unable to load image from file: %s'), [FileName]), L('Warning'), TD_BUTTON_OK,
        TD_ICON_INFORMATION);
      Pic.Free;
      Exit;
    end;
  end;
  F_WIDTH.Text := Format(L('%dpx.'), [Pic.Width]);
  F_HEIGHT.Text := Format(L('%dpx.'), [Pic.Height]);
  JPEGScale(Pic.Graphic, FilePreviewSize, FilePreviewSize);
  Fb := Graphics.TBitmap.Create;
  Fb.PixelFormat := Pf24bit;
  Fb1 := Graphics.Tbitmap.Create;
  Fb1.PixelFormat := Pf24bit;
  Fb1.Width := FilePreviewSize;
  Fb1.Height := FilePreviewSize;
  Fb1.Canvas.Brush.Color := ClBtnFace;
  Fb1.Canvas.Pen.Color := ClBtnFace;
  Fb1.Canvas.Rectangle(0, 0, FilePreviewSize, FilePreviewSize);
  if Pic.Width > Pic.Height then
  begin
    Fb.Width := FilePreviewSize;
    Fb.Height := Round(FilePreviewSize * (Pic.Height / Pic.Width));
  end else
  begin
    Fb.Width := Round(FilePreviewSize * (Pic.Width / Pic.Height));
    Fb.Height := FilePreviewSize;
  end;
  Fb.Canvas.StretchDraw(Rect(0, 0, Fb.Width, Fb.Height), Pic.Graphic);
  Fb1.Canvas.Draw(FilePreviewSize div 2 - Fb.Width div 2, FilePreviewSize div 2 - Fb.Height div 2, Fb);
  if not(Image1.Picture.Graphic is Graphics.Tbitmap) then
  begin
    if Image1.Picture.Graphic <> nil then
      Image1.Picture.Graphic.Free
    else
      Image1.Picture.Bitmap := Graphics.Tbitmap.Create;
  end;
  Image1.Picture.Bitmap.Assign(Fb1);
  Image1.Refresh;
  Fb1.Free;
  Pic.Free;
  Fb.Free;
end;

procedure TDBReplaceForm.Image2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  DragImage: TBitmap;
begin
  if (Button = MbLeft) and FileExistsSafe(DB_PATCH.Text) then
  begin
    DragImageList.Clear;
    DropFileSource1.Files.Clear;
    DropFileSource1.Files.Add(DB_PATCH.Text);
    DragImage := TBitmap.Create;
    DragImage.PixelFormat := Pf24bit;
    DragImage.Assign(Image2.Picture.Bitmap);
    DragImageList.Width := DragImage.Width;
    DragImageList.Height := DragImage.Height;
    DragImageList.Add(DragImage, nil);
    DragImage.Free;
    DropFileSource1.ImageIndex := 0;
    DropFileSource1.Execute;
  end;
end;

procedure TDBReplaceForm.ListView1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  DragImage: TBitmap;
  Item: TListItem;
begin
  if (Button = MbLeft) and (ListView1.GetItemAt(X, Y) <> nil) and FileExistsSafe(DB_PATCH.Text) then
  begin
    Item := ListView1.GetItemAt(X, Y);
    DragImageList.Clear;
    DropFileSource1.Files.Clear;
    DropFileSource1.Files.Add(DB_PATCH.Text);
    DragImage := TBitmap.Create;
    DragImage.PixelFormat := Pf24bit;
    DragImage.Assign(FBitmapImageList[Item.ImageIndex].Bitmap);
    DragImageList.Width := DragImage.Width;
    DragImageList.Height := DragImage.Height;
    DragImageList.Add(DragImage, nil);
    DragImage.Free;
    DropFileSource1.ImageIndex := 0;
    DropFileSource1.Execute;
  end;
end;

procedure TDBReplaceForm.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  DragImage : TBitmap;
begin
  if (Button = mbLeft) and FileExistsSafe(CurrentFileName) then
  begin
   DragImageList.Clear;
   DropFileSource1.Files.Clear;
   DropFileSource1.Files.Add(CurrentFileName);
   DragImage:=TBitmap.Create;
   DragImage.PixelFormat:=pf24bit;
   DragImage.Assign(Image1.Picture.Bitmap);
   DragImageList.Width:=DragImage.Width;
   DragImageList.Height:=DragImage.Height;
   DragImageList.Add(DragImage,nil);
   DragImage.free;
   DropFileSource1.ImageIndex := 0;
   DropFileSource1.Execute;
  end;
end;

procedure TDBReplaceForm.ChangedDBDataByID(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);
begin
  if ID = Current_id_show then
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
    if WorkQuery.FieldByName('ID').AsInteger = StrToInt(DB_ID.Text) then
      Break;
    WorkQuery.Next;
  end;
  MenuInfo := TDBPopupMenuInfo.Create;
  MenuRecord := TDBPopupMenuInfoRecord.CreateFromDS(WorkQuery);
  MenuInfo.Add(MenuRecord);
  MenuInfo.AttrExists := False;
  TDBPopupMenu.Instance.Execute(Self, Image2.ClientToScreen(MousePos).X, Image2.ClientToScreen(MousePos).Y, MenuInfo);
end;


procedure TDBReplaceForm.ListView1CustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
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
  B.PixelFormat := Pf24bit;
  B.Assign(FBitmapImageList[Item.ImageIndex].Bitmap);
  if not(Sender.IsEditing and (Sender.ItemFocused = Item)) then
  begin
    if Item.Selected then
    begin
      SelectedColor(B, MakeDarken(ClWindow, 0.5));
      Sender.Canvas.Pen.Color := MakeDarken(ClWindow, 0.9);
      Sender.Canvas.Brush.Color := MakeDarken(ClWindow, 0.9);
      Sender.Canvas.FillRect(R2);
    end else
    begin
      Sender.Canvas.Pen.Color := ClWindow;
      Sender.Canvas.Brush.Color := ClWindow;
      Sender.Canvas.FillRect(R2);
    end;
    Sender.Canvas.Font.Color := ClWindowText;
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
  B.Free;
  DefaultDraw := False;
end;

procedure TDBReplaceForm.FormDestroy(Sender: TObject);
begin
  FreeDS(WorkQuery);
  DropFileTarget1.Unregister;
  FBitmapImageList.Free;
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
  for I := 1 to ListView1.Items.Count do
    if ListView1.Items[I - 1].Indent = PopupMenu1.Tag then
    begin
      if ID_OK = MessageBoxDB(Handle, L('Do you really want to delete this information from the collection?'), L('Confirm'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING)
        then
      begin
        FQuery := GetQuery;
        FQuery.Active := False;
        SQL_ := 'DELETE FROM $DB$ WHERE (ID = ' + IntToStr(PopupMenu1.Tag) + ')';
        SetSQL(FQuery, SQL_);
        try
          ExecSQL(FQuery);
          DBKernel.DoIDEvent(Self, PopupMenu1.Tag, [EventID_Param_Delete], EventInfo);
          FreeDS(FQuery);
          ListView1.Items.Delete(I - 1);
        except
        end;
        Break;
      end;
    end;
end;

procedure TDBReplaceForm.ListView1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Item: TListItem;
begin
  Item := ListView1.GetItemAt(MousePos.X, MousePos.Y);
  if Item = nil then
    Exit;
  PopupMenu1.Tag := Item.Indent;
  PopupMenu1.Popup(ListView1.ClientTOScreen(MousePos).X, ListView1.ClientTOScreen(MousePos).Y);
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
    Button1.Caption := L('Add');
    Button2.Caption := L('Replace for all');
    Button3.Caption := L('Skip for all');
    Button4.Caption := L('Add for all');
    Button5.Caption := L('Replace');
    Button6.Caption := L('Skip');
    Button7.Caption := L('Replace and delete duplicates');
    Button8.Caption := L('Delete file');
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

procedure TDBReplaceForm.Button7Click(Sender: TObject);
begin
  Res_Address^ := Result_Replace_And_Del_Dublicates;
  ResIDAddress^ := StrToInt(DB_ID.Text);
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.Button8Click(Sender: TObject);
begin
  if ID_OK <> MessageBoxDB(Handle, L('Do you really want to delete this file?'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
    Exit;
  Res_Address^ := Result_Delete_File;
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.Button4Click(Sender: TObject);
begin
  Res_address^ := Result_add_all;
  ResIDAddress^ := StrToInt(DB_ID.Text);
  OnCloseQuery := nil;
  Close;
end;

procedure TDBReplaceForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Release;
  DBReplaceForm := nil;
end;

procedure TDBReplaceForm.ReallignControls;
var
  FontHeight: Integer;
const
  PixelsBeetwinControls = 2;
  InfoLeft = 60;
  InfoWidth = 110;
begin
  LabelCurrentInfo.Width := 169;

  FontHeight := Abs(F_NAME.Font.Height) + 2;
  LabelCurrentInfo.Height := FontHeight * 2;

  LabelFName.Top := LabelCurrentInfo.Top + LabelCurrentInfo.Height + PixelsBeetwinControls;

  F_NAME.Top := LabelFName.Top;
  F_NAME.Height := FontHeight;
  F_NAME.Width := InfoWidth;
  F_NAME.Left := InfoLeft;

  LabelFSize.Top := F_NAME.Top + F_NAME.Height + PixelsBeetwinControls;
  F_SIZE.Height := FontHeight;
  F_SIZE.Top := LabelFSize.Top;
  F_SIZE.Width := InfoWidth;
  F_SIZE.Left := InfoLeft;

  LabelFWidth.Top := F_SIZE.Top + F_SIZE.Height + PixelsBeetwinControls;
  F_WIDTH.Height := FontHeight;
  F_WIDTH.Top := LabelFWidth.Top;
  F_WIDTH.Width := InfoWidth;
  F_WIDTH.Left := InfoLeft;

  LabelFHeight.Top := F_WIDTH.Top + F_WIDTH.Height + PixelsBeetwinControls;
  F_HEIGHT.Height := FontHeight;
  F_HEIGHT.Top := LabelFHeight.Top;
  F_HEIGHT.Width := InfoWidth;
  F_HEIGHT.Left := InfoLeft;

  LabelFPath.Top := F_HEIGHT.Top + F_HEIGHT.Height + PixelsBeetwinControls;

  F_PATCH.Top := LabelFPath.Top + LabelFPath.Height + PixelsBeetwinControls;
  F_PATCH.Width := Panel3.Width - F_PATCH.Left;

  Panel3.Height := F_PATCH.Top + F_PATCH.Height + 2;
  // Right panel allinment

  LabelDBInfo.Width := 169;
  LabelDBInfo.Height := FontHeight;

  DbLabel_id.Top := LabelDBInfo.Top + LabelDBInfo.Height + PixelsBeetwinControls;
  DB_ID.Top := DbLabel_id.Top;
  DB_ID.Height := FontHeight;
  DB_ID.Width := InfoWidth;
  DB_ID.Left := InfoLeft;

  LabelDBName.Top := DB_ID.Top + DB_ID.Height + PixelsBeetwinControls;
  DB_NAME.Top := LabelDBName.Top;
  DB_NAME.Height := FontHeight;
  DB_NAME.Width := InfoWidth;
  DB_NAME.Left := InfoLeft;

  LabelDBRating.Top := DB_NAME.Top + DB_NAME.Height + PixelsBeetwinControls;
  DB_RATING.Top := LabelDBRating.Top;
  DB_RATING.Height := FontHeight;
  DB_RATING.Width := InfoWidth;
  DB_RATING.Left := InfoLeft;

  LabelDBWidth.Top := DB_RATING.Top + DB_RATING.Height + PixelsBeetwinControls;
  DB_WIDTH.Top := LabelDBWidth.Top;
  DB_WIDTH.Height := FontHeight;
  DB_WIDTH.Width := InfoWidth;
  DB_WIDTH.Left := InfoLeft;

  LabelDBHeight.Top := DB_WIDTH.Top + DB_WIDTH.Height + PixelsBeetwinControls;
  DB_HEIGHT.Top := LabelDBHeight.Top;
  DB_HEIGHT.Height := FontHeight;
  DB_HEIGHT.Width := InfoWidth;
  DB_HEIGHT.Left := InfoLeft;

  LabelDBSize.Top := DB_HEIGHT.Top + DB_HEIGHT.Height + PixelsBeetwinControls;
  DB_SIZE.Top := LabelDBSize.Top;
  DB_SIZE.Height := FontHeight;
  DB_SIZE.Width := InfoWidth;
  DB_SIZE.Left := InfoLeft;

  LabelDBPath.Top := DB_SIZE.Top + DB_SIZE.Height + PixelsBeetwinControls;

  DB_PATCH.Top := LabelDBPath.Top + LabelDBPath.Height + PixelsBeetwinControls;
  DB_PATCH.Height := FontHeight;
  DB_PATCH.Width := Panel2.Width - DB_PATCH.Left;
  DB_PATCH.Left := 0;

  Panel2.Height := DB_PATCH.Top + DB_PATCH.Height + 2;

  Panel1.Top := Max(Panel2.Height + Panel2.Top, Panel3.Height + Panel3.Top);
  ListView1.Height := Max(Panel2.Height, Panel3.Height);

  ClientHeight := Panel1.Top + Panel1.Height + 3;
end;

procedure TDBReplaceForm.Image1DblClick(Sender: TObject);
begin
  if Viewer = nil then
    Application.CreateForm(TViewer, Viewer);
  Viewer.ShowFile(CurrentFileName);
end;

end.
