unit UnitSizeResizerForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Dolphin_DB, ExtCtrls, ImageConverting, Math, uVistaFuncs,
  JPEG, GIFImage, GraphicEx, Language, UnitDBkernel, GraphicCrypt,
  acDlgSelect, TiffImageUnit, UnitDBDeclare, UnitDBFileDialogs, uFileUtils,
  UnitDBCommon, UnitDBCommonGraphics, ComCtrls, ImgList, uDBForm, LoadingSign,
  DmProgress, uW7TaskBar;

type
  TFormSizeResizer = class(TDBForm)
    BtOk: TButton;
    BtCancel: TButton;
    BtSaveAsDefault: TButton;
    LbInfo: TLabel;
    EdImageName: TEdit;
    ImlWatermarkPatterns: TImageList;
    LsMain: TLoadingSign;
    PrbMain: TDmProgress;
    PnOptions: TPanel;
    CbWatermark: TCheckBox;
    DdeWatermarkPattern: TComboBoxEx;
    CbConvert: TCheckBox;
    DdConvert: TComboBox;
    BtJPEGOptions: TButton;
    DdRotate: TComboBox;
    CbRotate: TCheckBox;
    CbResize: TCheckBox;
    DdResizeAction: TComboBox;
    EdWidth: TEdit;
    LbSizeSeparator: TLabel;
    EdHeight: TEdit;
    CbAspectRatio: TCheckBox;
    CbAddSuffix: TCheckBox;
    EdSavePath: TEdit;
    BtChangeDirectory: TButton;
    procedure BtCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtJPEGOptionsClick(Sender: TObject);
    procedure BtOkClick(Sender: TObject);
    procedure BtSaveAsDefaultClick(Sender: TObject);
    procedure EdWidthExit(Sender: TObject);
    procedure EdHeightKeyPress(Sender: TObject; var Key: Char);
    procedure BtChangeDirectoryClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CbConvertClick(Sender: TObject);
    procedure CbRotateClick(Sender: TObject);
    procedure CbResizeClick(Sender: TObject);
    procedure DdResizeActionChange(Sender: TObject);
    procedure DdConvertChange(Sender: TObject);
    procedure CbWatermarkClick(Sender: TObject);
  private
    FData : TDBPopupMenuInfo;
    FW7TaskBar : ITaskbarList3;
    FDataCount : Integer;
    FProcessingParams : TProcessingParams;
    //My descrioption
    procedure LoadLanguage;
    procedure ProcessImages;
    procedure CheckValidForm;
    { Private declarations }
  protected
    function GetFormID : string; override;
  public
    procedure SetInfo(List : TDBPopupMenuInfo);
    procedure ThreadEnd;
    { Public declarations }
  end;

procedure ResizeImages(List : TDBPopupMenuInfo);

implementation

uses UnitJPEGOptions, uImageConvertThread;

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
  LoadLanguage;
  FData := TDBPopupMenuInfo.Create;
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

  FW7TaskBar := CreateTaskBarInstance;
end;

procedure TFormSizeResizer.FormDestroy(Sender: TObject);
begin
  FData.Free;
end;

function TFormSizeResizer.GetFormID: string;
begin
  Result := 'ConvertImage';
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

const
  Rotations : array[-1..3] of Integer = (DB_IMAGE_ROTATE_UNKNOWN, DB_IMAGE_ROTATE_EXIF, DB_IMAGE_ROTATE_270, DB_IMAGE_ROTATE_90, DB_IMAGE_ROTATE_180);

  function CheckFileTypes : Boolean;
  var
    GraphicClass : TGraphicClass;
    I : Integer;
  begin
    Result := True;
    for I := 0 to FData.Count - 1 do
    begin
      GraphicClass := GetGraphicClass(ExtractFileExt(FData[I].FileName), True);
      Result := Result and ConvertableImageClass(GraphicClass);
    end;
  end;

begin

  if not CheckFileTypes and (DdConvert.ItemIndex < 0) then
  begin
    MessageBoxDB(Handle, TEXT_MES_CHOOSE_FORMAT, TEXT_MES_WARNING, TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;

  //change form state
  PnOptions.Hide;
  BtSaveAsDefault.Hide;
  BtOk.Hide;
  PrbMain.Top := BtCancel.Top - BtCancel.Height - 5;
  PrbMain.Show;
  EdImageName.Top := PrbMain.Top - EdImageName.Height - 5;
  BtCancel.Left := PrbMain.Left + PrbMain.Width - BtCancel.Width;
  ClientHeight := ClientHeight - PnOptions.Height - 5;

  //init progress
  LsMain.Show;
  FDataCount := FData.Count;
  if FW7TaskBar <> nil then
  begin
    FW7TaskBar.SetProgressState(Handle, TBPF_NORMAL);
    FW7TaskBar.SetProgressValue(Handle, FDataCount - FData.Count, FDataCount);
  end;
  PrbMain.MaxValue := FDataCount;

  FProcessingParams.Rotation := Rotations[DdRotate.ItemIndex];

  for I := 1 to Min(FData.Count, ProcessorCount) do
    TImageConvertThread.Create(Self, FData.Extract(0), FProcessingParams);

{
 for i:=0 to Length(FImageList)-1 do
 begin
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
 Close;          }
end;

procedure TFormSizeResizer.SetInfo(List : TDBPopupMenuInfo);
var
  I : Integer;
begin
  for I := 0 to List.Count - 1 do
    FData.Add(List[I].Copy);
end;

procedure TFormSizeResizer.ThreadEnd;
begin
  PrbMain.Position := FDataCount - FData.Count;
  if FW7TaskBar <> nil then
    FW7TaskBar.SetProgressValue(Handle, FDataCount - FData.Count, FDataCount);

  if FData.Count > 0 then
    TImageConvertThread.Create(Self, FData.Extract(0), FProcessingParams)
  else
    Close;
end;

procedure TFormSizeResizer.BtSaveAsDefaultClick(Sender: TObject);
begin
  //TODO: DBKernel.WriteInteger('Convert options','Width',StrToIntDef(Edit1.text,1024));
end;

procedure TFormSizeResizer.CbConvertClick(Sender: TObject);
begin
  DdConvert.Enabled := CbConvert.Checked;
  CheckValidForm;
end;

procedure TFormSizeResizer.CbResizeClick(Sender: TObject);
begin
  DdResizeAction.Enabled := CbResize.Checked;
  CheckValidForm;
end;

procedure TFormSizeResizer.CbRotateClick(Sender: TObject);
begin
  DdRotate.Enabled := CbRotate.Checked;
  CheckValidForm;
end;

procedure TFormSizeResizer.CbWatermarkClick(Sender: TObject);
begin
  DdeWatermarkPattern.Enabled := CbWatermark.Checked;
  CheckValidForm;
end;

procedure TFormSizeResizer.CheckValidForm;
var
  Valid : Boolean;
begin
  Valid := CbConvert.Checked or CbResize.Checked or CbRotate.Checked or CbWatermark.Checked;
  BtOk.Enabled := Valid;
  BtSaveAsDefault.Enabled := Valid;
end;

procedure TFormSizeResizer.DdConvertChange(Sender: TObject);
begin
  BtJPEGOptions.Enabled := DdConvert.Enabled and (DdConvert.ItemIndex = 0);
end;

procedure TFormSizeResizer.DdResizeActionChange(Sender: TObject);
begin
  EdWidth.Enabled := DdResizeAction.Enabled and (DdResizeAction.ItemIndex = DdResizeAction.Items.Count - 1);
  EdHeight.Enabled := EdWidth.Enabled;
  LbSizeSeparator.Enabled := EdWidth.Enabled;
end;

procedure TFormSizeResizer.EdWidthExit(Sender: TObject);
begin
  (Sender as TEdit).Text := IntToStr(Min(Max(StrToIntDef((Sender as TEdit).Text, 100), 5), 5000));
end;

/// <summary>
/// My comment here
/// </summary>
procedure TFormSizeResizer.LoadLanguage;
begin
  Caption := L('Change Image');
  LbInfo.Caption := L('You can change image size, convert image to another format, rotate image and add custom watermark.');

  CbWatermark.Caption := L('Add Watermark');
  CbConvert.Caption := L('Convert');

  CbResize.Caption := L('Resize');
  DdResizeAction.Items.Add(L('Small (640x480)'));
  DdResizeAction.Items.Add(L('Medium (800x600)'));
  DdResizeAction.Items.Add(L('Big (1024x768)'));
  DdResizeAction.Items.Add(L('Thumbnails (128x124)'));
  DdResizeAction.Items.Add(L('Pocket PC (240õ320)'));
  DdResizeAction.Items.Add(Format(L('Size: %d%%'), [25]));
  DdResizeAction.Items.Add(Format(L('Size: %d%%'), [50]));
  DdResizeAction.Items.Add(Format(L('Size: %d%%'), [75]));
  DdResizeAction.Items.Add(Format(L('Size: %d%%'), [150]));
  DdResizeAction.Items.Add(Format(L('Size: %d%%'), [200]));
  DdResizeAction.Items.Add(Format(L('Size: %d%%'), [400]));
  DdResizeAction.Items.Add(L('Custom size:'));

  CbRotate.Caption := L('Rotate');
  DdRotate.Items.Add(L('By EXIF'));
  DdRotate.Items.Add(L('Left'));
  DdRotate.Items.Add(L('Right'));
  DdRotate.Items.Add(L('180 grad'));

  CbAspectRatio.Caption := L('Save aspect ratio');
  CbAddSuffix.Caption := L('Add filename suffix');
  BtJPEGOptions.Caption := L('JPEG Options');
  BtSaveAsDefault.Caption := L('Save settings by default');

  PrbMain.Text := L('Processing... (&%%)');

  BtCancel.Caption := L('Cancel');
  BtOk.Caption := L('Ok');
end;

procedure TFormSizeResizer.ProcessImages;
begin

end;

procedure TFormSizeResizer.EdHeightKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9']) then
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
