unit UnitExportImagesForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Dolphin_DB, ImageConverting, acDlgSelect,
  JPEG, GraphicEx, GIFImage, Language, UnitJPEGOptions, UnitDBkernel,
  GraphicCrypt, Spin, GraphicsCool, TiffImageUnit, uVistaFuncs,
  UnitDBDeclare, UnitDBFileDialogs, UnitDBCommon, UnitDBCommonGraphics;

type
  TExportImagesForm = class(TForm)
    Image1: TImage;
    Label2: TLabel;
    ComboBox2: TComboBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Width: TLabel;
    RadioButton01: TRadioButton;
    RadioButton03: TRadioButton;
    RadioButton04: TRadioButton;
    RadioButton02: TRadioButton;
    Edit1: TEdit;
    Edit2: TEdit;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    RadioButton05: TRadioButton;
    GroupBox2: TGroupBox;
    RadioButton001: TRadioButton;
    RadioButton002: TRadioButton;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Edit3: TEdit;
    Label3: TLabel;
    Button5: TButton;
    CheckBox4: TCheckBox;
    Edit4: TEdit;
    Button6: TButton;
    FontDialog1: TFontDialog;
    Shape1: TShape;
    Label5: TLabel;
    ColorDialog1: TColorDialog;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ComboBox2Click(Sender: TObject);
  private
    FImageList : TArStrings;
    FIDList : TArInteger;
    FRotateList : TArInteger;
    FFont : TFont;
    { Private declarations }
  public
    procedure LoadLanguage;
    procedure GetFileList(ImageList : TArStrings; IDList, RotateList : TArInteger);
    { Public declarations }
  end;

Procedure ExportImages(ImageList : TArStrings; IDList, RotateList : TArInteger; BeginRotate : Integer);

implementation

uses UnitSizeResizerForm, ProgressActionUnit;

{$R *.dfm}

Procedure ExportImages(ImageList : TArStrings; IDList, RotateList : TArInteger; BeginRotate : Integer);
var
  ExportImagesForm: TExportImagesForm;
begin
  Application.CreateForm(TExportImagesForm, ExportImagesForm);
  ExportImagesForm.GetFileList(ImageList,IDList,RotateList);
  ExportImagesForm.ShowModal;
  ExportImagesForm.Release;
  if UseFreeAfterRelease then ExportImagesForm.Free;
end;

procedure TExportImagesForm.FormCreate(Sender: TObject);
var
  Formats : TArGraphicClass;
  i : integer;
  Description, Mask : String;
  yyyy,mm,dd : Word;
begin
 FFont := TFont.Create;
 LoadLanguage;
 DBkernel.RecreateThemeToForm(Self);
 ComboBox2.Clear;
 Formats:=GetConvertableImageClasses;
 for i:=0 to Length(Formats)-1 do
 begin
  if Formats[i]<>TGIFImage then
  begin
   if Formats[i]<>TiffImageUnit.TTiffGraphic then
   Description:=GraphicEx.FileFormatList.GetDescription(Formats[i]) else
   Description:='Tiff Image';
  end else
  Description:='GIF Image';
  if Formats[i]<>TBitmap then
  Mask:=GraphicFileMask(Formats[i]) else
  Mask:='*.bmp;*.dib';
  ComboBox2.Items.Add(Description+'  ('+Mask+')')
 end;
 Edit1.Text:=IntToStr(DBKernel.ReadInteger('ExportImages options','Width',1024));
 Edit2.Text:=IntToStr(DBKernel.ReadInteger('ExportImages options','Height',768));
 ComboBox2.ItemIndex:=DBKernel.ReadInteger('ExportImages options','Format',0);
 ComboBox1.Text:=DBKernel.ReadString('ExportImages options','Zoom');
 if DBKernel.ReadString('ExportImages options','CopyRight')='' then
 begin
  DecodeDate(Now,yyyy,mm,dd);
  Edit4.Text:='Copyright (c) '+IntToStr(yyyy)+' by '+InstalledUserName;
 end else Edit4.Text:=DBKernel.ReadString('ExportImages options','CopyRight');
 try
  if DBKernel.ReadString('ExportImages options','FontName')<>'' then
  FFont.Name:=DBKernel.ReadString('ExportImages options','FontName');

  FFont.Color:=DBKernel.ReadInteger('ExportImages options','FontColor',$0);
  Edit4.Font.Name:= FFont.Name;
 except
 end;

 RadioButton01.Checked:=DBKernel.ReadBool('ExportImages options','100x100',false);
 RadioButton02.Checked:=DBKernel.ReadBool('ExportImages options','200x200',false);
 RadioButton03.Checked:=DBKernel.ReadBool('ExportImages options','600x800',true);
 RadioButton04.Checked:=DBKernel.ReadBool('ExportImages options','XXXxXXX',false);
 RadioButton05.Checked:=DBKernel.ReadBool('ExportImages options','Use zoom',false);
 CheckBox1.Checked:=DBKernel.ReadBool('ExportImages options','Save Ratio',true);
 RadioButton1.Checked:=DBKernel.ReadBool('ExportImages options','Original Format',true);
 RadioButton2.Checked:=DBKernel.ReadBool('ExportImages options','Convert',false);
 RadioButton001.Checked:=DBKernel.ReadBool('ExportImages options','Replace',false);
 RadioButton002.Checked:=DBKernel.ReadBool('ExportImages options','New',true);
 if DBKernel.ReadInteger('ExportImages options','ShadowColor',-1)=-1 then
 Shape1.Brush.Color:=$FFFFFF else
 Shape1.Brush.Color:=DBKernel.ReadInteger('ExportImages options','ShadowColor',$FFFFFF);
end;

procedure TExportImagesForm.GetFileList(ImageList: TArStrings;
  IDList, RotateList: TArInteger);
begin
 FImageList:=ImageList;
 FIDList:=IDList;
 FRotateList:=RotateList;
end;

procedure TExportImagesForm.LoadLanguage;
begin
 Caption:=TEXT_MES_EXPORT_IMAGES;
 Label2.Caption:=TEXT_MES_EXPORT_IMAGES_INFO;
 GroupBox1.Caption:=TEXT_MES_CHANGE_SIZE;
 RadioButton01.Caption:=TEXT_MES_CHANGE_SIZE_100x100;
 RadioButton02.Caption:=TEXT_MES_CHANGE_SIZE_200x200;
 RadioButton03.Caption:=TEXT_MES_CHANGE_SIZE_600x800;
 RadioButton04.Caption:=TEXT_MES_CHANGE_SIZE_CUSTOM;
 Width.Caption:=TEXT_MES_WIDTH;
 Label1.Caption:=TEXT_MES_HEIGHT;
 CheckBox1.Caption:=TEXT_MES_SAVE_ASPECT_RATIO;
 RadioButton05.Caption:=TEXT_MES_USE_ZOOM;
 RadioButton1.Caption:=TEXT_MES_TRY_KEEP_ORIGINAL_FORMAT;
 RadioButton2.Caption:=TEXT_MES_CONVERT_TO;
 Button1.Caption:=TEXT_MES_JPEG_OPTIONS;
 GroupBox2.Caption:=TEXT_MES_FILE_ACTIONS;
 RadioButton001.Caption:=TEXT_MES_REPLACE_IMAGES;
 RadioButton002.Caption:=TEXT_MES_MAKE_NEW_IMAGES;
 Button4.Caption:=TEXT_MES_SAVE_SETTINGS_BY_DEFAULT;
 Button3.Caption:=TEXT_MES_CANCEL;
 Button2.Caption:=TEXT_MES_OK;
 Button6.Caption:=TEXT_MES_FONT;

 CheckBox2.Caption:=TEXT_MES_APPLY_TRANSFORM;
 Label3.Caption:=TEXT_MES_OUTPUT_FOLDER;
 CheckBox3.Caption:=TEXT_MES_APLY_ROTATE;
 CheckBox4.Caption:=TEXT_MES_ADD_COPYRIGHT_TEXT;

 Label5.Caption:=TEXT_MES_SHADOW_COLOR;
end;

procedure TExportImagesForm.Button1Click(Sender: TObject);
begin
 SetJPEGOptions;
end;

procedure TExportImagesForm.Button3Click(Sender: TObject);
begin
 Close;
end;

procedure TExportImagesForm.Button5Click(Sender: TObject);
var
  Dir : string;
begin
 Dir:=UnitDBFileDialogs.DBSelectDir(Handle,TEXT_MES_SEL_FOLDER_TO_IMAGES,Dolphin_DB.UseSimpleSelectFolderDialog);
 Edit3.Text:=Dir;
end;

procedure TExportImagesForm.Button4Click(Sender: TObject);
begin
 DBKernel.WriteInteger('ExportImages options','Width',StrToIntDef(Edit1.text,1024));
 DBKernel.WriteInteger('ExportImages options','Height',StrToIntDef(Edit2.text,768));
 DBKernel.WriteInteger('ExportImages options','Format',ComboBox2.ItemIndex);
 DBKernel.WriteString('ExportImages options','Zoom',ComboBox1.Text);

 DBKernel.WriteString('ExportImages options','CopyRight',Edit4.Text);
 DBKernel.WriteString('ExportImages options','FontName',FFont.Name);
 DBKernel.WriteInteger('ExportImages options','FontColor',FFont.Color);

 DBKernel.WriteBool('ExportImages options','100x100',RadioButton01.Checked);
 DBKernel.WriteBool('ExportImages options','200x200',RadioButton02.Checked);
 DBKernel.WriteBool('ExportImages options','600x800',RadioButton03.Checked);
 DBKernel.WriteBool('ExportImages options','XXXxXXX',RadioButton04.Checked);
 DBKernel.WriteBool('ExportImages options','Use zoom',RadioButton05.Checked);
 DBKernel.WriteBool('ExportImages options','Save Ratio',CheckBox1.Checked);
 DBKernel.WriteBool('ExportImages options','Original Format',RadioButton1.Checked);
 DBKernel.WriteBool('ExportImages options','Convert',RadioButton2.Checked);
 DBKernel.WriteBool('ExportImages options','Replace',RadioButton001.Checked);
 DBKernel.WriteBool('ExportImages options','New',RadioButton002.Checked);

 DBKernel.WriteInteger('ExportImages options','ShadowColor',Shape1.Brush.Color);
end;

procedure TExportImagesForm.FormDestroy(Sender: TObject);
begin
 FFont.Free;
end;

procedure TExportImagesForm.Button6Click(Sender: TObject);
var
  S : Integer;
begin
 FontDialog1.Font.Assign(FFont);
 if FontDialog1.Execute then
 begin
  FFont.Assign(FontDialog1.Font);
  S:=Edit4.Font.Size;
  Edit4.Font.Assign(FontDialog1.Font);
  Edit4.Font.Size:=S;
 end;
end;

procedure TExportImagesForm.Button2Click(Sender: TObject);
var
  OldGraphic, NewGraphic : TGraphic;
  BitmapGraphic, Temp : TBitmap;
  i, ImageSizeW, ImageSizeH, w, h, j, res : integer;
  NewGraphicClass : TGraphicClass;
  Password, NewEXT, FileName, OldEXT, OutDir, FileDir, EndDir : string;
  b : boolean;
  EventInfo : TEventValues;
  ProgressWindow : TProgressActionForm;

 function GetZoom : real;
 var
   s : string;
   i : integer;
 begin
  s:=ComboBox1.Text;
  for i:=Length(s) downto 1 do
  if not (s[i] in abs_cifr) then delete(s,i,1);
  Result:=StrToFloatDef(s,50)/100;;
 end;

begin
 OutDir:=Edit3.Text;
 FormatDir(OutDir);
 
 if ComboBox2.ItemIndex<0 then
 begin
  MessageBoxDB(Handle,TEXT_MES_CHOOSE_FORMAT,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
  ComboBox2.SetFocus;
  exit;
 end;

 ProgressWindow:=GetProgressWindow;
 ProgressWindow.OneOperation:=false;
 ProgressWindow.OperationCount:=1;
 ProgressWindow.OperationPosition:=1;
 ProgressWindow.MaxPosCurrentOperation:=Length(FImageList);
 ProgressWindow.xPosition:=0;
 ProgressWindow.Show;
 Hide;
 Application.ProcessMessages;
 ImageSizeW:=0;
 ImageSizeH:=0;
 if RadioButton01.Checked then
 begin
  ImageSizeW:=100;
  ImageSizeH:=100;
 end;
 if RadioButton02.Checked then
 begin
  ImageSizeW:=200;
  ImageSizeH:=200;
 end;
 if RadioButton03.Checked then
 begin
  ImageSizeW:=800;
  ImageSizeH:=600;
 end;
 if RadioButton03.Checked then
 begin
  ImageSizeW:=800;
  ImageSizeH:=600;
 end;
 if RadioButton04.Checked then
 begin
  ImageSizeW:=StrToIntDef(Edit1.Text,100);
  ImageSizeH:=StrToIntDef(Edit2.Text,100);
 end;
 if RadioButton05.Checked then
 begin
  ImageSizeW:=0;
  ImageSizeH:=0;
 end;
 for i:=0 to Length(FImageList)-1 do
 begin
  ProgressWindow.xPosition:=i+1;
  Application.ProcessMessages;
  if RadioButton1.Checked then
  begin
   OldEXT:=AnsiLowerCase(GetExt(FImageList[i]));
   if ConvertableImageClass(GetGraphicClass(OldEXT,false)) then
   begin
    NewGraphicClass:=GetGraphicClass(OldEXT,false);
    NewEXT:=OldEXT;
   end else
   begin
    if GetConvertableImageClasses[ComboBox2.ItemIndex]=TBitmap then
    NewEXT:='bmp' else
    if GetConvertableImageClasses[ComboBox2.ItemIndex]=TJPEGImage then
    NewEXT:='jpg' else
    NewEXT:=GraphicExtension(GetConvertableImageClasses[ComboBox2.ItemIndex]);
    NewGraphicClass:=GetGraphicClass(NewEXT,true);
   end;
  end else
  begin
   NewEXT:=GraphicExtension(GetConvertableImageClasses[ComboBox2.ItemIndex]);
   NewGraphicClass:=GetGraphicClass(NewEXT,true);
  end;
  Password:='';
  if ValidCryptGraphicFile(FImageList[i]) then
  begin
   Password:=DBkernel.FindPasswordForCryptImageFile(FImageList[i]);
   if Password='' then Continue;
  end;
  NewGraphic:=NewGraphicClass.Create;
  OldGraphic:=nil;
  try
   if Password='' then
   begin
    OldGraphic:=GetGraphicClass(GetExt(FImageList[i]),false).Create;
    OldGraphic.LoadFromFile(FImageList[i])
   end else
   OldGraphic:=DeCryptGraphicFile(FImageList[i],Password);
   Temp := TBitmap.Create;
   Temp.Assign(OldGraphic);
   Temp.PixelFormat:=pf24bit;
  finally
   if OldGraphic<>nil then
   OldGraphic.Free;
  end;
  try
  BitmapGraphic:= TBitmap.Create;
  BitmapGraphic.PixelFormat:=pf24bit;
  w:=Temp.Width;
  h:=Temp.Height;
  if RadioButton05.Checked then
  begin
   ImageSizeW:=Round(w*GetZoom);
   ImageSizeH:=Round(h*GetZoom);
  end;
  If ((w<ImageSizeW) and (h<ImageSizeH)) or (not CheckBox2.Checked) then BitmapGraphic.Assign(Temp) else
  begin
   if CheckBox1.Checked then
   ProportionalSize(ImageSizeW,ImageSizeH,w,h);
   try
    if not CheckBox1.Checked then
    DoResize(ImageSizeW,ImageSizeH,Temp,BitmapGraphic) else
    DoResize(w,h,Temp,BitmapGraphic);
   except
   end;
  end;
  Temp.free;
  if CheckBox3.Checked then
  begin
   if FRotateList[i]=DB_IMAGE_ROTATED_270 then Rotate270A(BitmapGraphic);
   if FRotateList[i]=DB_IMAGE_ROTATED_90 then Rotate90A(BitmapGraphic);
   if FRotateList[i]=DB_IMAGE_ROTATED_180 then Rotate180A(BitmapGraphic);
  end;
  BitmapGraphic.Canvas.Font.Assign(FFont);
  if CheckBox4.Checked then
  DrawCopyRightA(BitmapGraphic,Shape1.Brush.Color,Edit4.Text);
  NewGraphic.Assign(BitmapGraphic);
  BitmapGraphic.Free;

   FileDir:=GetDirectory(FImageList[i]);
   EndDir:=Edit3.Text;
   FormatDir(EndDir);
   if (AnsiLowerCase(FileDir)=AnsiLowerCase(EndDir)) or not CheckBox2.Checked then
   begin
    FileName:=GetConvertedFileName(FImageList[i],NewEXT);
    if RadioButton001.Checked then
    begin
     RenameFile(FImageList[i],FileName);
    end;
    if NewGraphic is TJPEGImage then
    begin
     (NewGraphic as TJPEGImage).CompressionQuality:=DBKernel.ReadInteger('','JPEGCompression',75);
     (NewGraphic as TJPEGImage).ProgressiveEncoding:=DBKernel.ReadBool('','JPEGProgressiveMode',false);
    end;


    j:=1;
    b:=false;
    Repeat
     try
      SetLastError(0);

      if RadioButton001.Checked and (GetExt(FImageList[i])=GetExt(FileName)) then
      NewGraphic.SaveToFile(FImageList[i]) else
      NewGraphic.SaveToFile(FileName);

      if (GetLastError<>0) and (GetLastError<>183) then
      raise Exception.Create('Error code = '+IntToStr(GetLastError));
      j:=0;
     except
      on e : Exception do
      begin
       res:=Application.MessageBox(PChar(Format(TEXT_MES_WRITE_ERROR_F,[e.Message])),PChar(TEXT_MES_ERROR), MB_ICONERROR or MB_ABORTRETRYIGNORE);
       if res=IDABORT then
       begin
        NewGraphic.free;
        ProgressWindow.Release;
        ProgressWindow.Free;
        Close;
        exit;
       end;
       if res=IDRETRY then j:=0;
       if res=IDIGNORE then
       begin
        b:=true;
        NewGraphic.free;
        break;
       end;
      end;
     end;
    until j=1;
    if b then continue;


    NewGraphic.free;
    try
     if Password<>'' then
     if RadioButton001.Checked and (GetExt(FImageList[i])=GetExt(FileName)) then
     CryptGraphicFileV1(FImageList[i],Password,0) else
     CryptGraphicFileV1(FileName,Password,0);
    except
    end;


    if RadioButton001.Checked then
    begin
     try
      if (GetExt(FImageList[i])=GetExt(FileName)) then
      DeleteFile(FileName) else
      DeleteFile(FImageList[i]);
     except
     end;
     if (GetExt(FImageList[i])=GetExt(FileName)) then
     begin
      UpdateImageRecord(FImageList[i],FIDList[i]);
      EventInfo.Name:=FImageList[i];
      EventInfo.NewName:=FImageList[i];
      DBKernel.DoIDEvent(self,FIDList[i],[EventID_Param_Image],EventInfo);
     end else
     begin
      UpdateMovedDBRecord(FIDList[i],FileName);
      UpdateImageRecord(FileName,FIDList[i]);
      EventInfo.Name:=FImageList[i];
      EventInfo.NewName:=FileName;
      DBKernel.DoIDEvent(self,FIDList[i],[EventID_Param_Name],EventInfo);
      EventInfo.Name:=FileName;
      EventInfo.NewName:=FileName;
      DBKernel.DoIDEvent(self,FIDList[i],[EventID_Param_Image],EventInfo);
     end;
    end
   end else
   begin

    if RadioButton001.Checked then
    FileName:=EndDir+ExtractFileName(FImageList[i]) else
    FileName:=GetConvertedFileNameWithDir(FImageList[i],EndDir,NewEXT);
    if NewGraphic is TJPEGImage then
    begin
     (NewGraphic as TJPEGImage).CompressionQuality:=DBKernel.ReadInteger('','JPEGCompression',75);
     (NewGraphic as TJPEGImage).ProgressiveEncoding:=DBKernel.ReadBool('','JPEGProgressiveMode',false);
    end;




    b:=false;
    Repeat
     j:=1;
     try
      SetLastError(0);

      NewGraphic.SaveToFile(FileName);

      if (GetLastError<>0) and (GetLastError<>183) and (GetLastError<>6) then
      raise Exception.Create('Error code = '+IntToStr(GetLastError));
      //j:=0;
     except
      on e : Exception do
      begin
       //TODO: MessageBoxDB
       res:=Application.MessageBox(PChar(Format(TEXT_MES_WRITE_ERROR_F,[e.Message])),PChar(TEXT_MES_ERROR), MB_ICONERROR or MB_ABORTRETRYIGNORE);
       if res=IDABORT then
       begin
        NewGraphic.free;
        ProgressWindow.Release;
        ProgressWindow.Free;
        Close;
        exit;
       end;
       if res=IDRETRY then j:=0;
       if res=IDIGNORE then
       begin
        b:=true;
        NewGraphic.free;
        break;
       end;
      end;
     end;
    until j=1;
    if b then continue;






    NewGraphic.free;
    try
     if Password<>'' then
     CryptGraphicFileV1(FileName,Password,0);
    except
    end;

   end;

  except
  end;
 end;


 ProgressWindow.Release;
 ProgressWindow.Free;
 Close;
end;

procedure TExportImagesForm.Shape1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 ColorDialog1.Color:=Shape1.Brush.Color;
 if ColorDialog1.Execute then
 begin
  Shape1.Brush.Color:=ColorDialog1.Color;
 end;
end;

procedure TExportImagesForm.ComboBox2Click(Sender: TObject);
begin
 RadioButton2.Checked:=true;
end;

end.
