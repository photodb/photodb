unit UnitSizeResizerForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Dolphin_DB, ExtCtrls, ImageConverting, Math,uVistaFuncs,
  JPEG, GIFImage, GraphicEx, Language, UnitDBkernel, GraphicCrypt,
  acDlgSelect, TiffImageUnit, UnitDBDeclare, UnitDBFileDialogs, uFileUtils,
  UnitDBCommon, UnitDBCommonGraphics;

type
  TFormSizeResizer = class(TForm)
    DdConvert: TComboBox;
    BtJPEGOptions: TButton;
    BtOk: TButton;
    BtCancel: TButton;
    BtSaveAsDefault: TButton;
    Label2: TLabel;
    EdSavePath: TEdit;
    BtChangeDirectory: TButton;
    DdResizeAction: TComboBox;
    EdWidth: TEdit;
    EdHeight: TEdit;
    Label4: TLabel;
    CbAspectRatio: TCheckBox;
    CbConvert: TCheckBox;
    CbAddSuffix: TCheckBox;
    CbResize: TCheckBox;
    CbRotate: TCheckBox;
    DdRotate: TComboBox;
    EdImageName: TEdit;
    procedure BtCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtJPEGOptionsClick(Sender: TObject);
    procedure BtOkClick(Sender: TObject);
    procedure BtSaveAsDefaultClick(Sender: TObject);
    procedure EdWidthExit(Sender: TObject);
    procedure EdHeightKeyPress(Sender: TObject; var Key: Char);
    procedure BtChangeDirectoryClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FData : TDBPopupMenuInfo;
    { Private declarations }
  public
    procedure SetInfo(List : TDBPopupMenuInfo);
    procedure LoadLanguage;
    procedure ProcessImages;
    { Public declarations }
  end;

procedure ResizeImages(List : TDBPopupMenuInfo);

implementation

uses UnitJPEGOptions, ProgressActionUnit;

{$R *.dfm}

procedure ResizeImages(List : TDBPopupMenuInfo);
var
  FormSizeResizer: TFormSizeResizer;
begin
  Application.CreateForm(TFormSizeResizer, FormSizeResizer);
  FormSizeResizer.SetInfo(List);
  FormSizeResizer.Show;
end;

procedure TFormSizeResizer.BtCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormSizeResizer.FormCreate(Sender: TObject);
var
  Formats: TArGraphicClass;
  I: Integer;
  Description, Mask: string;
begin
  FData := TDBPopupMenuInfo.Create;
  LoadLanguage;
  DBkernel.RecreateThemeToForm(Self);
  Formats := GetConvertableImageClasses;
  for I := 0 to Length(Formats) - 1 do
  begin
    if Formats[I] <> TGIFImage then
    begin
      if Formats[I] <> TiffImageUnit.TTiffGraphic then
        Description := GraphicEx.FileFormatList.GetDescription(Formats[I])
      else
        Description := 'Tiff Image';
    end
    else
      Description := 'GIF Image';
    if Formats[I] <> TBitmap then
      Mask := GraphicFileMask(Formats[I])
    else
      Mask := '*.bmp;*.dib';
    DdConvert.Items.Add(Description + '  (' + Mask + ')')
  end;

  //TODO: Edit1.Text:=IntToStr(DBKernel.ReadInteger('Convert options','Width',1024));
end;

procedure TFormSizeResizer.FormDestroy(Sender: TObject);
begin
  FData.Free;
end;

procedure TFormSizeResizer.BtJPEGOptionsClick(Sender: TObject);
begin
  SetJPEGOptions;
end;

procedure TFormSizeResizer.BtOkClick(Sender: TObject);
var
  OldGraphic, NewGraphic: TGraphic;
  BitmapGraphic, Temp: TBitmap;
  I, ImageSizeW, ImageSizeH, W, H, J, Res: Integer;
  NewGraphicClass: TGraphicClass;
  Password, NewEXT, FileName, OldEXT, FileDir, EndDir: string;
  EventInfo: TEventValues;
  B: Boolean;
  ProgressWindow: TProgressActionForm;

begin

  if DdConvert.ItemIndex<0 then
  begin
    MessageBoxDB(Handle,TEXT_MES_CHOOSE_FORMAT, TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
    DdConvert.SetFocus;
    Exit;
  end;

{ ProgressWindow:=GetProgressWindow;
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
    NewGraphicClass:=GetGraphicClass(OldEXT,true);
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
// NewEXT:=GraphicExtension(GetConvertableImageClasses[ComboBox2.ItemIndex]);
   if GetConvertableImageClasses[ComboBox2.ItemIndex]=TBitmap then
   NewEXT:='bmp' else
   if GetConvertableImageClasses[ComboBox2.ItemIndex]=TJPEGImage then
   NewEXT:='jpg' else
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
  Temp:=nil;
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
  except
   if OldGraphic<>nil then OldGraphic.Free;
   ProgressWindow.Release;
   ProgressWindow.Free;
   Close;
   exit;
  end;
  OldGraphic.Free;
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
   If (w<ImageSizeW) and (h<ImageSizeH) then BitmapGraphic.Assign(Temp) else
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






    b:=false;
    Repeat
     j:=1;
     try
      SetLastError(0);


     if RadioButton001.Checked and (GetExt(FImageList[i])=GetExt(FileName)) then
     NewGraphic.SaveToFile(FImageList[i]) else
     NewGraphic.SaveToFile(FileName);


      if (GetLastError<>0) and (GetLastError<>183) and (GetLastError<>6) then
      raise Exception.Create('Error code = '+IntToStr(GetLastError));
      //j:=0;
     except
      on e : Exception do
      begin
       res:=Application.MessageBox(PWideChar(Format(TEXT_MES_WRITE_ERROR_F,[e.Message])), PWideChar(TEXT_MES_ERROR), MB_ICONERROR or MB_ABORTRETRYIGNORE);
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
    FileName:=EndDir+GetFileNameWithoutExt(FImageList[i])+'.'+NewEXT else
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
     // j:=0;
     except
      on e : Exception do
      begin
       res:=Application.MessageBox(PWideChar(Format(TEXT_MES_WRITE_ERROR_F,[e.Message])),TEXT_MES_ERROR, MB_ICONERROR or MB_ABORTRETRYIGNORE);
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
 Close;          }
end;

procedure TFormSizeResizer.SetInfo(List : TDBPopupMenuInfo);
var
  I : Integer;
begin
  for I := 0 to List.Count - 1 do
    FData.Add(List[I].Copy);
end;

procedure TFormSizeResizer.BtSaveAsDefaultClick(Sender: TObject);
begin
  //TODO: DBKernel.WriteInteger('Convert options','Width',StrToIntDef(Edit1.text,1024));
end;

procedure TFormSizeResizer.EdWidthExit(Sender: TObject);
begin
  (Sender as TEdit).Text := IntToStr(Min(Max(StrToIntDef((Sender as TEdit).Text,100),5),5000));
end;

procedure TFormSizeResizer.LoadLanguage;
begin
  Caption := TEXT_MES_CHANGE_SIZE_CAPTION;
  Label2.Caption := TEXT_MES_CHANGE_SIZE_INFO;
  CbResize.Caption := TEXT_MES_CHANGE_SIZE;

  DdResizeAction.Items.Add(TEXT_MES_CHANGE_SIZE_SMALL);
  DdResizeAction.Items.Add(TEXT_MES_CHANGE_SIZE_MEDIUM);
  DdResizeAction.Items.Add(TEXT_MES_CHANGE_SIZE_LARGE);
  DdResizeAction.Items.Add(TEXT_MES_CHANGE_SIZE_THUMBNAILS);
  DdResizeAction.Items.Add(TEXT_MES_CHANGE_SIZE_POCKET_PC);
  DdResizeAction.Items.Add(Format(TEXT_MES_CHANGE_SIZE_RESIZE_TO, [25]));
  DdResizeAction.Items.Add(Format(TEXT_MES_CHANGE_SIZE_RESIZE_TO, [50]));
  DdResizeAction.Items.Add(Format(TEXT_MES_CHANGE_SIZE_RESIZE_TO, [75]));
  DdResizeAction.Items.Add(Format(TEXT_MES_CHANGE_SIZE_RESIZE_TO, [150]));
  DdResizeAction.Items.Add(Format(TEXT_MES_CHANGE_SIZE_RESIZE_TO, [200]));
  DdResizeAction.Items.Add(Format(TEXT_MES_CHANGE_SIZE_RESIZE_TO, [400]));
  DdResizeAction.Items.Add(TEXT_MES_CHANGE_SIZE_CUSTOM);

  CbAspectRatio.Caption := TEXT_MES_SAVE_ASPECT_RATIO;
  CbConvert.Caption := TEXT_MES_CONVERT_TO;
  BtJPEGOptions.Caption := TEXT_MES_JPEG_OPTIONS;
  BtSaveAsDefault.Caption := TEXT_MES_SAVE_SETTINGS_BY_DEFAULT;
  BtCancel.Caption := TEXT_MES_CANCEL;
  BtOk.Caption := TEXT_MES_OK;
end;

procedure TFormSizeResizer.ProcessImages;
begin

end;

procedure TFormSizeResizer.EdHeightKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9']) then
    Key := #0;
end;

procedure TFormSizeResizer.BtChangeDirectoryClick(Sender: TObject);
var
  Directory: string;
begin
  Directory := UnitDBFileDialogs.DBSelectDir(Handle, TEXT_MES_SEL_FOLDER_FOR_IMAGES, UseSimpleSelectFolderDialog);
  if DirectoryExists(Directory) then
    EdSavePath.Text := Directory;
end;

end.
