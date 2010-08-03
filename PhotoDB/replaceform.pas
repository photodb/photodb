unit replaceform;

interface

uses
  UnitDBKernel, DBCMenu, dolphin_db, Windows, Messages, SysUtils, Variants,
  Classes, Graphics, Controls, Forms, GraphicCrypt, uVistaFuncs, UnitDBDeclare,
  DropTarget, DragDropFile, DragDrop, DropSource, Menus, ImgList, StdCtrls,
  ExtCtrls, ComCtrls,  Dialogs, DB, CommCtrl, jpeg, math,
  ActiveX, UnitBitmapImageList, CommonDBSupport, UnitDBCommon,
  UnitDBCommonGraphics, uLogger, uDBDrawing;

type
  TDBReplaceForm = class(TForm)
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
  FBitmapImageList : TBitmapImageList;
  WorkQuery : TDataSet;
    { Private declarations }
  public
  procedure LoadLanguage;
  procedure ReallignControls;
    { Public declarations }
  end;

var
  //TODO: review!
  DBReplaceForm: TDBReplaceForm;
  Res_Address, ResIDAddress : pinteger;
  current_id_show : integer;
  CurrentFileName : string;

implementation

uses Searching, Language, ExplorerUnit, UnitPasswordForm,
     SlideShow;

{$R *.dfm}

{ TForm9 }

procedure TDBReplaceForm.Additem(caption_: string; ID: integer; fbit_: tbitmap);
var
  new : TListItem;
  bit : TBitmap;
  TempBitmap, fBit : TBitmap;
  bs : TStream;
  J : TJpegImage;
  Password : String;
  Exists, w,h : integer;
const
  ListItemPreviewSize = 102;
begin
 new := ListView1.Items.Add;
 new.Indent:=ID;
 new.Caption:=caption_;
 bit:=TBitmap.Create;
 bit.PixelFormat:=pf24bit;
 bit.Width:=ListItemPreviewSize;
 bit.Height:=ListItemPreviewSize;
 if TBlobField(WorkQuery.FieldByName('thum'))=nil then
 begin
  bit.free;
  exit;
 end;
 J:=nil;
 if ValidCryptBlobStreamJPG(WorkQuery.FieldByName('thum')) then
 begin
  Password:=DBkernel.FindPasswordForCryptBlobStream(WorkQuery.FieldByName('thum'));
  if Password='' then
  begin
   Password:=GetImagePasswordFromUserBlob(WorkQuery.FieldByName('thum'),WorkQuery.FieldByName('FFileName').AsString);
  end;
  if Password<>'' then
  J:=TJpegImage(DeCryptBlobStreamJPG(WorkQuery.FieldByName('thum'),Password)) else
  begin
   bit.free;
   exit;
  end;
 end else
 begin
  BS:=GetBlobStream(WorkQuery.FieldByName('thum'),bmRead);
  try
   J:=TJpegImage.Create;
   if BS.Size<>0 then
   J.LoadFromStream(BS) else
   except
  end;
  BS.Free;
 end;
 FillColorEx(bit, Theme_ListColor);
 if (J.Width>ListItemPreviewSize) or (J.Height>ListItemPreviewSize) then
 begin
  TempBitmap:=TBitmap.Create;
  TempBitmap.PixelFormat:=pf24bit;
  fBit:=TBitmap.Create;
  fBit.PixelFormat:=pf24bit;
  fBit.Assign(J);
  w:=fBit.Width;
  h:=fBit.Height;
  ProportionalSize(ListItemPreviewSize,ListItemPreviewSize,w,h);
  DoResize(w,h,fBit,TempBitmap);
  fBit.Free;
  Bit.Canvas.Draw(ListItemPreviewSize div 2 - TempBitmap.Width div 2,ListItemPreviewSize div 2 - TempBitmap.height div 2,TempBitmap);
  TempBitmap.Free;
 end else
 begin
  Bit.canvas.Draw(ListItemPreviewSize div 2 - J.Width div 2,ListItemPreviewSize div 2 - J.height div 2,J);
 end;
 ApplyRotate(bit, WorkQuery.FieldByName('Rotated').AsInteger);
 Exists:=0;
 DrawAttributes(bit,ListItemPreviewSize,WorkQuery.FieldByName('Rating').AsInteger,WorkQuery.FieldByName('Rotated').AsInteger,WorkQuery.FieldByName('Access').AsInteger,WorkQuery.FieldByName('FFileName').AsString,false,Exists,WorkQuery.FieldByName('ID').AsInteger);
 J.free;
 FBitmapImageList.AddBitmap(bit);
 new.ImageIndex:=FBitmapImageList.Count-1;
 ListView1.Refresh;
end;

procedure TDBReplaceForm.ExecuteToAdd(FileName: string; _ID: integer;
  thimg: string; Addr_Res, AddrSelID : PInteger;  Rec_ : TImageDBRecordA);
var
  i : integer;
begin
 FBitmapImageList.Clear;
 if thimg='' then exit;
 ResIDAddress:=AddrSelID;
 res_address:=addr_res;
 res_address^:=Result_invalid;
 AddrSelID^:=0;
 listview1.Clear;
 CurrentFileName:= Filename;
 WorkQuery.Active:=false;
 SetSQL(WorkQuery,'SELECT * FROM '+GetDefDBName+' WHERE StrTh = :str ');
 SetStrParam(WorkQuery,0,thimg);
 WorkQuery.active:=true;
 if WorkQuery.RecordCount=0 then
 begin
  EventLog(Format('TDBReplaceForm::ExecuteToAdd() not found any db record for file %s and strth "%s"',[FileName,thimg]));
  exit;
 end;
 if WorkQuery.RecordCount=1 then
 begin
  listview1.Visible:=false;
  panel2.Left:=listview1.Left;
  panel1.Left:=0;
  Width:=Panel3.Width+Panel2.Width+(Width-ClientWidth);
  Button2.Enabled:=True;
  Button7.Enabled:=False;
  Button5.Enabled:=True;
 end else
 begin
  listview1.Visible:=true;
  //Panel2.Left:=296;
  //Panel1.Left:=160;
  //Width:=422;
  Button2.Enabled:=False;
  Button5.Enabled:=True;
  Button7.Enabled:=False;
 end;
 WorkQuery.First;
 ReadFileInfo(Filename);
 for i:=1 to WorkQuery.RecordCount do
 begin
  AddItem(Trim(WorkQuery.FieldByName('Name').AsString),WorkQuery.FieldByName('ID').AsInteger,nil);
  WorkQuery.Next;
 end;
 ReadDBInfoByID(WorkQuery.FieldByName('ID').AsInteger);
 ShowModal;
end;

procedure TDBReplaceForm.ReadDBInfoByID(id: integer);
var
  Bit : TBitmap;
  bs : TStream;
  pic : TPicture;
  Password : String;
  fQuery : TDataSet;
  Exists, w,h : integer;
  TempBitmap, fBit : TBitmap;
const
  ListItemPreviewSize = 100;
begin
 fQuery:=GetQuery;
 fQuery.Active:=false;
 SetSQl(fQuery,'SELECT * FROM '+GetDefDBname+' WHERE ID='+IntToStr(ID));
 fQuery.Active:=true;
 current_id_show:=fQuery.FieldByName('ID').AsInteger;
 DB_ID.text:=IntToStr(ID);
 DB_NAME.text:=Trim(fQuery.FieldByName('Name').AsString);
 DB_RATING.text:=inttostr(fQuery.FieldByName('Rating').AsInteger);
 DB_WIDTH.text:=Format(TEXT_MES_PIXEL_FORMAT_D,[fQuery.FieldByName('Width').AsInteger]);
 DB_HEIGHT.text:=Format(TEXT_MES_PIXEL_FORMAT_D,[fQuery.FieldByName('Height').AsInteger]);
 DB_SIZE.text:=SizeInTextA(fQuery.FieldByName('FileSize').AsInteger);
 DB_PATCH.text:=fQuery.FieldByName('FFileName').AsString;
 pic:=TPicture.create;
 pic.Graphic:=TJPEGImage.Create;
 bit:=Tbitmap.Create;
 bit.PixelFormat:=pf24bit;
 bit.Width:=ListItemPreviewSize;
 bit.Height:=ListItemPreviewSize;
 bit.Canvas.Brush.color:=Theme_MainColor;
 bit.Canvas.pen.color:=Theme_MainColor;
 if TBlobField(fQuery.FieldByName('thum'))=nil then
 begin
  bit.free;
  pic.free;
  EventLog('TDBReplaceForm::ReadDBInfoByID()/FieldByName(thum)==null --> exit');
  exit;
 end;
 if ValidCryptBlobStreamJPG(fQuery.FieldByName('thum')) then
 begin
  Password:=DBkernel.FindPasswordForCryptBlobStream(fQuery.FieldByName('thum'));
  if Password='' then
  begin
   Password:=GetImagePasswordFromUserBlob(fQuery.FieldByName('thum'),fQuery.FieldByName('FFileName').AsString);
  end;
  if Password<>'' then
  pic.Graphic:=DeCryptBlobStreamJPG(fQuery.FieldByName('thum'),Password) else
  begin   
   EventLog('TDBReplaceForm::ReadDBInfoByID()/Password==null --> exit');
   bit.free;
   pic.free;
   exit;
  end;
 end else
 begin
  BS:=GetBlobStream(fQuery.FieldByName('thum'),bmRead);
  try
   if BS.Size<>0 then
   pic.Graphic.loadfromStream(BS) else
   except
  end;
  BS.Free;
 end;
 bit.canvas.Rectangle(0,0,ListItemPreviewSize,ListItemPreviewSize);


 if (Pic.Width>ListItemPreviewSize) or (Pic.Height>ListItemPreviewSize) then
 begin
  TempBitmap:=TBitmap.Create;
  TempBitmap.PixelFormat:=pf24bit;
  fBit:=TBitmap.Create;
  fBit.PixelFormat:=pf24bit;
  fBit.Assign(Pic.Graphic);
  w:=fBit.Width;
  h:=fBit.Height;
  ProportionalSize(ListItemPreviewSize,ListItemPreviewSize,w,h);
  DoResize(w,h,fBit,TempBitmap);
  fBit.Free;
  Bit.canvas.Draw(ListItemPreviewSize div 2 - TempBitmap.Width div 2,ListItemPreviewSize div 2 - TempBitmap.height div 2,TempBitmap);
  TempBitmap.Free;
 end else
 begin
  Bit.canvas.Draw(ListItemPreviewSize div 2 - pic.Graphic.Width div 2,ListItemPreviewSize div 2 - pic.Graphic.height div 2,pic.Graphic);
 end;
 ApplyRotate(bit, fQuery.FieldByName('Rotated').AsInteger);
 Exists:=0;
 DrawAttributes(bit,ListItemPreviewSize,fQuery.FieldByName('Rating').AsInteger,fQuery.FieldByName('Rotated').AsInteger,fQuery.FieldByName('Access').AsInteger,fQuery.FieldByName('FFileName').AsString,false,Exists,fQuery.FieldByName('ID').AsInteger);
 pic.free;
 if image2.Picture.Bitmap=nil then
 image2.Picture.Bitmap:=Tbitmap.create;
 image2.Picture.Bitmap.Assign(bit);
 image2.Refresh;
 bit.free;
 FreeDS(fQuery);
end;

procedure TDBReplaceForm.ListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin   
 if Item<>nil then
 begin
  ReadDBInfoByID(item.Indent);
 end;
 If Selected=False then Button5.Enabled:=False else Button5.Enabled:=True;
 Button7.Enabled:=Button5.Enabled;
end;

procedure TDBReplaceForm.FormCreate(Sender: TObject);
begin
 Dolphin_DB.Del_Close_btn(Handle);
 WorkQuery:=GetQuery;
 DropFileTarget1.Register(self);
 FBitmapImageList := TBitmapImageList.Create;
 DBKernel.RegisterForm(self);
 DBKernel.RecreateThemeToForm(self);
 ListView1.HotTrack:=DBKernel.Readbool('Options','UseHotSelect',true);
 listview1.DoubleBuffered:=true;
 ListView1SelectItem(Sender, nil, false);
 DBKernel.RegisterChangesID(self,self.ChangedDBDataByID);
 LoadLanguage;
 ReallignControls;
end;

procedure TDBReplaceForm.Button1Click(Sender: TObject);
begin
 res_address^:=Result_add;
 ResIDAddress^:=StrToInt(DB_ID.Text);
 OnCloseQuery:=nil;
 Close;
end;

procedure TDBReplaceForm.Button2Click(Sender: TObject);
begin
 res_address^:=Result_replace_all;
 ResIDAddress^:=StrToInt(DB_ID.Text);
 OnCloseQuery:=nil;
 Close;
end;

procedure TDBReplaceForm.Button5Click(Sender: TObject);
begin
 res_address^:=Result_replace;
 ResIDAddress^:=StrToInt(DB_ID.Text);
 OnCloseQuery:=nil;
 Close;
end;

procedure TDBReplaceForm.Button3Click(Sender: TObject);
begin
 res_address^:=Result_skip_all;
 ResIDAddress^:=StrToInt(DB_ID.Text);
 OnCloseQuery:=nil;
 Close;
end;

procedure TDBReplaceForm.Button6Click(Sender: TObject);
begin
 Res_Address^:=Result_skip;
 ResIDAddress^:=StrToInt(DB_ID.Text);
 OnCloseQuery:=nil;
 Close;
end;

procedure TDBReplaceForm.ReadFileInfo(FileName: string);
var
  pic : TPicture;
  fb,fb1 : Graphics.Tbitmap;
  filesize_, i : integer;
  Password : string;
const
  FilePreviewSize = 100;
begin
 filesize_:=GetFileSizeByName(FileName);
 F_NAME.Text:=ExtractFileName(FileName);
 F_SIZE.Text:=SizeInTextA(FileSize_);
 F_PATCH.text:=FileName;
 for i:=length(FileName) downto 1 do
 if FileName[i]=#0 then delete(FileName,i,1);
 pic:=TPicture.Create;
 if ValidCryptGraphicFile(FileName) then
 begin
  Password:=DBkernel.FindPasswordForCryptImageFile(FileName);
  if Password<>'' then
  pic.Graphic:=DeCryptGraphicFile(FileName,Password) else
  begin
   MessageBoxDB(Handle,Format(TEXT_MES_CANT_LOAD_IMAGE,[FileName]),TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_INFORMATION);
   exit;
  end;
 end else
 begin
 try
  pic.LoadFromFile(FileName);
  except
   MessageBoxDB(Handle,Format(TEXT_MES_CANT_LOAD_IMAGE,[FileName]),TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_INFORMATION);
   pic.free;
   exit;
  end;
 end;
 F_WIDTH.text:=Format(TEXT_MES_PIXEL_FORMAT_D,[pic.Width]);
 F_HEIGHT.text:=Format(TEXT_MES_PIXEL_FORMAT_D,[pic.Height]);
 JPEGScale(pic.Graphic,FilePreviewSize,FilePreviewSize);
 fb:=Graphics.TBitmap.create;
 fb.PixelFormat:=pf24bit;
 fb1:=Graphics.Tbitmap.create;
 fb1.PixelFormat:=pf24bit;
 fb1.Width:=FilePreviewSize;
 fb1.Height:=FilePreviewSize;
 fb1.Canvas.Brush.color:=Theme_MainColor;
 fb1.Canvas.pen.color:=Theme_MainColor;
 fb1.Canvas.Rectangle(0,0,FilePreviewSize,FilePreviewSize);
 if pic.Width>pic.Height then
 begin
  fb.Width:=FilePreviewSize;
  fb.Height:=Round(FilePreviewSize*(pic.Height/pic.Width));
 end else
 begin
  fb.Width:=Round(FilePreviewSize*(pic.Width/pic.Height));
  fb.Height:=FilePreviewSize;
 end;
 fb.Canvas.StretchDraw(rect(0,0,fb.Width,fb.Height),pic.Graphic);
 fb1.Canvas.Draw(FilePreviewSize div 2-fb.Width div 2,FilePreviewSize div 2- fb.Height div 2,fb);
 if not (image1.Picture.Graphic is Graphics.tbitmap) then
 begin
  if image1.Picture.Graphic<>nil then image1.Picture.Graphic.free else
  image1.Picture.bitmap:=Graphics.Tbitmap.Create;
 end;
 image1.Picture.bitmap.Assign(fb1);
 image1.Refresh;
 fb1.Free;
 pic.Free;
 fb.free;
end;

procedure TDBReplaceForm.Image2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  DragImage : TBitmap;
begin
 if (Button = mbLeft) and FileExists(DB_PATCH.Text) then
 begin
   DragImageList.Clear;
   DropFileSource1.Files.Clear;
   DropFileSource1.Files.Add(DB_PATCH.Text);
   DragImage:=TBitmap.Create;
   DragImage.PixelFormat:=pf24bit;
   DragImage.Assign(Image2.Picture.Bitmap);
   DragImageList.Width:=DragImage.Width;
   DragImageList.Height:=DragImage.Height;
   DragImageList.Add(DragImage,nil);
   DragImage.free;
   DropFileSource1.Execute;
 end;
end;

procedure TDBReplaceForm.ListView1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  DragImage : TBitmap;
  item : TListItem;
begin
 if (Button = mbLeft) and (ListView1.GetItemAt(x,y)<>nil) and FileExists(DB_PATCH.Text) then
 begin
  item:=ListView1.GetItemAt(x,y);
  DragImageList.Clear;
  DropFileSource1.Files.Clear;
  DropFileSource1.Files.Add(DB_PATCH.Text);
  DragImage:=TBitmap.Create;
  DragImage.PixelFormat:=pf24bit;
  DragImage.Assign(FBitmapImageList[item.ImageIndex].Bitmap);
  DragImageList.Width:=DragImage.Width;
  DragImageList.Height:=DragImage.Height;
  DragImageList.Add(DragImage,nil);
  DragImage.free;
  DropFileSource1.Execute;
 end;
end;

procedure TDBReplaceForm.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  DragImage : TBitmap;
begin
  if (Button = mbLeft) and FileExists(CurrentFileName) then
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
   DropFileSource1.Execute;
  end;
end;

procedure TDBReplaceForm.ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
begin
 if ID=Current_id_show then
 ReadDBInfoByID(ID);
end;

procedure TDBReplaceForm.Image2ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  MenuInfo : TDBPopupMenuInfo;
  MenuRecord : TDBPopupMenuInfoRecord;
  i : integer;
begin
 WorkQuery.First;
 For i:=1 to WorkQuery.RecordCount do
 begin
  if WorkQuery.FieldByName('ID').AsInteger=StrToInt(DB_ID.Text) then Break;
  WorkQuery.Next;
 end;
  MenuInfo := TDBPopupMenuInfo.Create;
  MenuRecord := TDBPopupMenuInfoRecord.CreateFromDS(WorkQuery);
  MenuInfo.Add(MenuRecord);
  MenuInfo.AttrExists:=false;
  TDBPopupMenu.Instance.Execute(Image2.ClientToScreen(MousePos).x, Image2.ClientToScreen(MousePos).y, MenuInfo);
end;

procedure TDBReplaceForm.ListView1CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  r, r1, r2 : TRect;
  b : TBitmap;
Const
  DrawTextOpt = DT_NOPREFIX+DT_CENTER+DT_WORDBREAK+DT_EDITCONTROL;
  ListItemPreviewSize = 102;
begin
 if FBitmapImageList.Count=0 then Exit;
 r := Item.DisplayRect(drBounds);
 if not RectInRect(Sender.ClientRect,r) then exit;
 r1 := Item.DisplayRect(drIcon);
 r2 := Item.DisplayRect(drLabel);
 b := TBitmap.create;
 b.PixelFormat:=pf24bit;
 b.Assign(FBitmapImageList[Item.ImageIndex].Bitmap);
 if not (Sender.IsEditing and (Sender.ItemFocused=Item)) then
 begin
 if Item.Selected then
 begin
  SelectedColor(b,RGB(Round(GetRValue(Theme_ListColor)*0.5),Round(GetGValue(Theme_ListColor)*0.5),Round(GetBValue(Theme_ListColor)*0.5)));
  Sender.Canvas.Pen.Color:=RGB(Round(GetRValue(Theme_ListColor)*0.9),Round(GetGValue(Theme_ListColor)*0.9),Round(GetBValue(Theme_ListColor)*0.9));//$aa8888;
  Sender.Canvas.Brush.Color:=RGB(Round(GetRValue(Theme_ListColor)*0.9),Round(GetGValue(Theme_ListColor)*0.9),Round(GetBValue(Theme_ListColor)*0.9));//$aa8888;
  Sender.Canvas.FillRect(r2);
 end else
 begin
  Sender.Canvas.Pen.Color:=Theme_ListColor;
  Sender.Canvas.Brush.Color:=Theme_ListColor;
  Sender.Canvas.FillRect(r2);
 end;
 Sender.Canvas.Font.Color:=Theme_ListFontColor;
 if cdsHot in State then
 begin
  Sender.Canvas.Font.Style:=[fsUnderline];
  DrawText(Sender.Canvas.Handle, PChar(Item.Caption), Length(Item.Caption), r2, DrawTextOpt);
 end else
 begin
  Sender.Canvas.Font.Style:=[];
  DrawText(Sender.Canvas.Handle, PChar(Item.Caption), Length(Item.Caption), r2, DrawTextOpt);
 end;
 end;
 Sender.Canvas.Draw(r1.Left+((r1.Right-r1.Left) div 2 - ListItemPreviewSize div 2),r1.Top,b);
 b.free;
 DefaultDraw := false;
end;

procedure TDBReplaceForm.FormDestroy(Sender: TObject);
begin
 FreeDS(WorkQuery);
 DropFileTarget1.Unregister;
 FBitmapImageList.Free;
 DBKernel.UnRegisterForm(self);
 DBKernel.UnRegisterChangesID(self,self.ChangedDBDataByID);
end;

procedure TDBReplaceForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 CanClose:=false;
end;

procedure TDBReplaceForm.Delete1Click(Sender: TObject);
var
  i : integer;
  fQuery : TDataSet;
  EventInfo : TEventValues;
  SQL_ : string;
begin
 For i:=1 to ListView1.Items.Count do
 if ListView1.Items[i-1].Indent=PopupMenu1.Tag then
 begin
  If ID_OK=MessageBoxDB(Handle,TEXT_MES_DEL_FROM_DB_CONFIRM,TEXT_MES_CONFIRM,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
  begin
   fQuery:=GetQuery;
   fQuery.active:=false;
   SQL_:='DELETE FROM '+GetDefDBname+' WHERE (ID = '+IntToStr(PopupMenu1.Tag)+')';
   SetSQL(fQuery,SQL_);
   try
    ExecSQL(fQuery);
    DBKernel.DoIDEvent(nil,PopupMenu1.Tag,[EventID_Param_Delete],EventInfo);
    FreeDS(fQuery);
    ListView1.Items.Delete(i-1);
   except
   end;
   Break;
  end;
 end;
end;

procedure TDBReplaceForm.ListView1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  item : TListItem;
begin
 item:=ListView1.GetItemAt(MousePos.X,MousePos.Y);
 if item=nil then exit;
 PopupMenu1.Tag:=Item.Indent;
 PopupMenu1.Popup(ListView1.ClientTOScreen(MousePos).X,ListView1.ClientTOScreen(MousePos).Y);
end;

procedure TDBReplaceForm.LoadLanguage;
begin
 Caption := TEXT_MES_CHOOSE_ACTION;
 Delete1.Caption:=TEXT_MES_DELETE;
 LabelFName.Caption:=TEXT_MES_NAME;
 LabelFSize.Caption:=TEXT_MES_SIZE;
 LabelFWidth.Caption:=TEXT_MES_WIDTH;
 LabelFHeight.Caption:=TEXT_MES_HEIGHT;
 LabelFPath.Caption:=TEXT_MES_PATH;
 LabelCurrentInfo.Caption:=TEXT_MES_CURRENT_FILE_INFO+':';
 Button1.Caption:=TEXT_MES_ADD;
 Button2.Caption:=TEXT_MES_REPLACE_FOR_ALL;
 Button3.Caption:=TEXT_MES_SKIP_FOR_ALL;
 Button4.Caption:=TEXT_MES_ADD_FOR_ALL;
 Button5.Caption:=TEXT_MES_REPLACE;
 Button6.Caption:=TEXT_MES_SKIP;
 Button7.Caption:=TEXT_MES_REPLACE_AND_DELETE_DUBLICATES;
 Button8.Caption:=TEXT_MES_DELETE_FILE;
 LabelDBInfo.Caption:=TEXT_MES_DB_FILE_INFO+':';
 DbLabel_id.Caption:=TEXT_MES_ID;
 LabelDBName.Caption:=TEXT_MES_NAME;
 LabelDBRating.Caption:=TEXT_MES_RATING;
 LabelDBWidth.Caption:=TEXT_MES_WIDTH;
 LabelDBHeight.Caption:=TEXT_MES_HEIGHT;
 LabelDBSize.Caption:=TEXT_MES_SIZE;
 LabelDBPath.Caption:=TEXT_MES_PATH;
end;

procedure TDBReplaceForm.Button7Click(Sender: TObject);
begin
 Res_Address^:=Result_Replace_And_Del_Dublicates;
 ResIDAddress^:=StrToInt(DB_ID.Text);
 OnCloseQuery:=nil;
 Close;
end;

procedure TDBReplaceForm.Button8Click(Sender: TObject);
begin
 if ID_OK<>MessageBoxDB(Handle,TEXT_MES_DELETE_FILE_CONFIRM,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;
 Res_Address^:=Result_Delete_File;
 OnCloseQuery:=nil;
 Close;
end;

procedure TDBReplaceForm.Button4Click(Sender: TObject);
begin
 res_address^:=Result_add_all;
 ResIDAddress^:=StrToInt(DB_ID.Text);
 OnCloseQuery:=nil;
 Close;
end;

procedure TDBReplaceForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 Release;
 DBReplaceForm:=nil;
end;

procedure TDBReplaceForm.ReallignControls;
var
  FontHeight : integer;
const
  PixelsBeetwinControls = 2;
  InfoLeft = 60;
  InfoWidth = 110;
begin
 LabelCurrentInfo.Width:=169;

 FontHeight:=Abs(F_NAME.Font.Height)+2;
 LabelCurrentInfo.Height:=FontHeight*2;

 LabelFName.Top:=LabelCurrentInfo.Top+LabelCurrentInfo.Height+PixelsBeetwinControls;

 F_NAME.Top:=LabelFName.Top;
 F_NAME.Height:=FontHeight;
 F_NAME.Width:=InfoWidth;
 F_NAME.Left:=InfoLeft;

 LabelFSize.Top:=F_NAME.Top+F_NAME.Height+PixelsBeetwinControls;
 F_SIZE.Height:=FontHeight;
 F_SIZE.Top:=LabelFSize.Top;
 F_SIZE.Width:=InfoWidth;
 F_SIZE.Left:=InfoLeft;

 LabelFWidth.Top:=F_SIZE.Top+F_SIZE.Height+PixelsBeetwinControls;
 F_WIDTH.Height:=FontHeight;
 F_WIDTH.Top:=LabelFWidth.Top;
 F_WIDTH.Width:=InfoWidth;
 F_WIDTH.Left:=InfoLeft;

 LabelFHeight.Top:=F_WIDTH.Top+F_WIDTH.Height+PixelsBeetwinControls;
 F_HEIGHT.Height:=FontHeight;
 F_HEIGHT.Top:=LabelFHeight.Top;
 F_HEIGHT.Width:=InfoWidth;
 F_HEIGHT.Left:=InfoLeft;

 LabelFPath.Top:=F_HEIGHT.Top+F_HEIGHT.Height+PixelsBeetwinControls;

 F_PATCH.Top:=LabelFPath.Top+LabelFPath.Height+PixelsBeetwinControls;
 F_PATCH.Width:=Panel3.Width-F_PATCH.left;

 Panel3.Height:=F_PATCH.Top+F_PATCH.Height+2;

 //Right panel allinment

 LabelDBInfo.Width:=169;
 LabelDBInfo.Height:=FontHeight;

 DbLabel_id.Top:=LabelDBInfo.Top+LabelDBInfo.Height+PixelsBeetwinControls;
 DB_ID.Top:=DbLabel_id.Top;
 DB_ID.Height:=FontHeight;
 DB_ID.Width:=InfoWidth;
 DB_ID.Left:=InfoLeft;

 LabelDBName.Top:=DB_ID.Top+DB_ID.Height+PixelsBeetwinControls;
 DB_NAME.Top:=LabelDBName.Top;
 DB_NAME.Height:=FontHeight;
 DB_NAME.Width:=InfoWidth;
 DB_NAME.Left:=InfoLeft;

 LabelDBRating.Top:=DB_NAME.Top+DB_NAME.Height+PixelsBeetwinControls;
 DB_RATING.Top:=LabelDBRating.Top;
 DB_RATING.Height:=FontHeight;
 DB_RATING.Width:=InfoWidth;
 DB_RATING.Left:=InfoLeft;

 LabelDBWidth.Top:=DB_RATING.Top+DB_RATING.Height+PixelsBeetwinControls;
 DB_WIDTH.Top:=LabelDBWidth.Top;
 DB_WIDTH.Height:=FontHeight;
 DB_WIDTH.Width:=InfoWidth;
 DB_WIDTH.Left:=InfoLeft;

 LabelDBHeight.Top:=DB_WIDTH.Top+DB_WIDTH.Height+PixelsBeetwinControls;
 DB_HEIGHT.Top:=LabelDBHeight.Top;
 DB_HEIGHT.Height:=FontHeight;
 DB_HEIGHT.Width:=InfoWidth;
 DB_HEIGHT.Left:=InfoLeft;

 LabelDBSize.Top:=DB_HEIGHT.Top+DB_HEIGHT.Height+PixelsBeetwinControls;
 DB_SIZE.Top:=LabelDBSize.Top;
 DB_SIZE.Height:=FontHeight;
 DB_SIZE.Width:=InfoWidth;
 DB_SIZE.Left:=InfoLeft;

 LabelDBPath.Top:=DB_SIZE.Top+DB_SIZE.Height+PixelsBeetwinControls;

 DB_PATCH.Top:=LabelDBPath.Top+LabelDBPath.Height+PixelsBeetwinControls;
 DB_PATCH.Height:=FontHeight;
 DB_PATCH.Width:=Panel2.Width-DB_PATCH.left;
 DB_PATCH.Left:=0;

 Panel2.Height:=DB_PATCH.Top+DB_PATCH.Height+2;

 Panel1.Top:=Max(Panel2.Height+Panel2.Top,Panel3.Height+Panel3.Top);
 ListView1.Height:=Max(Panel2.Height,Panel3.Height);

 ClientHeight:=Panel1.Top+Panel1.Height+3;
end;

procedure TDBReplaceForm.Image1DblClick(Sender: TObject);
begin
 if Viewer=nil then Application.CreateForm(TViewer, Viewer);
 Viewer.ShowFile(CurrentFileName);
end;

end.
