{ The following 3 functions are the ones that allow you to control RAW digital images
{
{ FromRawToPSD  This reads in the RAW file and any brightness, gamms, shrink values are also applied
{  Status:=FromRawToPSD(@FilePtrs,@ExifRecord,@ProgressInfo,IFileName,RAWSettings,ScanLines,IWidth,IHeight,ITrim);
{          RAWSettings is a record that contains the brightness and appearance variables
{
{ RawInfo   This gets information about the file without loading it. It's to tell you the dimensions and make and model
{  Status:=RawInfo(@FilePtrs,@ExifRecord,IFileName,IShrink,IWidth,IHeight,ITrim,IFilters,@PMake,@PModel);
{
{ Extract_Thumbnail   This extracts the thumbnail and stores it to a disk file that you can load
{  Status:=Extract_Thumbnail(@FilePtrs,IFileName,ThumbName,ThumbnailType);
{  NOTE: Not all RAW files have thumbnails built into them
{  NOTE: Although MOST thumbails are in JPG, there are quite a few that are in PPM format.
{
{ The following code is slapped together to show you how to use the PHOTOJOCKEY.DLL file that reads the RAW images.
}
unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ExtDlgs, Spin, ComCtrls, Jpeg, FileCtrl, GraphicEX    ;

type

  TForm1 = class(TForm)
    Button1: TButton;
    Panel1: TPanel;
    ScrollBox1: TScrollBox;
    Image1: TImage;
    Edit1: TEdit;
    OpenDialog1: TOpenDialog;
    Button5: TButton;
    OpenPictureDialog1: TOpenPictureDialog;
    Panel2: TPanel;
    ImageThumb: TImage;
    Button4: TButton;
    Panel3: TPanel;
    Image2: TImage;
    Button2: TButton;
    Panel5: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    Button3: TButton;
    RGShrink: TRadioGroup;
    CBAutoWB: TCheckBox;
    CBCameraWB: TCheckBox;
    CBFourColor: TCheckBox;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    TGamma: TEdit;
    TBright: TEdit;
    TScale1: TEdit;
    TScale2: TEdit;
    Button8: TButton;
    Label3: TLabel;
    CBHighlights: TComboBox;
    TScale3: TEdit;
    TScale4: TEdit;
    CBColors: TComboBox;
    Label9: TLabel;
    CBQuality: TComboBox;
    ProgressBar1: TProgressBar;
    LStage: TLabel;
    SEBlack: TSpinEdit;
    Label10: TLabel;
    CBBlack: TCheckBox;
    LDim: TLabel;
    BAbort: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Button6: TButton;
    CBRawColors: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure BAbortClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure CBRawColorsClick(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
  private
    { Private declarations }
    FBatch:Boolean;
    FLastThumbnail:String;
    FAbort:Boolean;
  public
    { Public declarations }
    FAbortBatch:Boolean;
  end;

var
  Form1: TForm1;

implementation
Uses
//  RAW,
  Global_FastIO;

{$R *.DFM}
(* Not used
{$R MYDLLS.RES}
*)

Type
  PPChar=^PChar;
  PLine=Pointer;
  ALines=Array[0..20000] Of PLine;
  PLongInt=^LongInt;


{$I CSTDIO.PAS}


Var
  FileName:String;
  OutFileName:String;

procedure TForm1.Button1Click(Sender: TObject);
begin
If FileExists(OpenDialog1.FileName) Then
   OpenDialog1.InitialDir:=ExtractFilePath(OpenDialog1.FileName);
If OpenDialog1.Execute Then
   Begin
   Edit1.Text:=ExtractFileName(OpenDialog1.FileName);
   ChDir(ExtractFilePath(OpenDialog1.FileName));
   FileName:=(ExtractFileName(OpenDialog1.FileName));
   messagedlg('Click IDENTIFY or LOAD-RAW now...',mtinformation,[mbok],0);
   End;
end;

Procedure MakeImageSmaller(Const I1:TPicture; Const I2:TImage);
Var
  ImageTmp:TPicture;
  W,H:Integer;
  hDC1:hDC;
Begin
If I1.Graphic Is TJPEGImage Then
   Begin
   W:=TJPEGImage(I1.Graphic).Width;
   H:=TJPEGImage(I1.Graphic).Height;
   If W>1000 Then
      TJPEGImage(I1.Graphic).Scale:=jsEighth;
   TJPEGImage(I1.Graphic).DIBNeeded;
   End;
      ImageTmp:=TPicture.Create;
      ImageTmp.Bitmap.PixelFormat:=pf24Bit;
      ImageTmp.Bitmap.Width:=I1.Width;
      ImageTmp.Bitmap.Height:=I1.Height;
      ImageTmp.Bitmap.Canvas.Draw(0,0,I1.Graphic);
      I1.Bitmap.Width:=ImageTmp.Width;
      I1.Bitmap.Height:=ImageTmp.Height;
      I1.Bitmap.Canvas.Draw(0,0,ImageTmp.Graphic);
      If I1.Width>1000 Then
         Begin
         ImageTmp.Bitmap.Width:=I1.Width Div 10;
         ImageTmp.Bitmap.Height:=I1.Height Div 10;
         End
      Else
         Begin
         ImageTmp.Bitmap.Width:=I1.Width;
         ImageTmp.Bitmap.Height:=I1.Height;
         End;
      ImageTmp.Bitmap.Canvas.StretchDraw(Rect(0,0,ImageTmp.Bitmap.Width,ImageTmp.Bitmap.Height),I1.Bitmap);
      I2.Picture.Bitmap.Assign(ImageTmp.Bitmap);
      ImageTmp.Free;
End;

Function RValue(Text:String):Single;
Var
  Code:Integer;
  Y:Single;
Begin
Val(Text,Y,Code);
Result:=Y;
End;

Procedure RawProgress(Stage:Integer;Height:Integer;CurrLine:Integer;Context:Pointer;Msg:PChar); cdecl;
Var
  MyForm:TForm1;
  SFPU:Word;
  DoAbort:Boolean;
  Msg1:TMsg;
Begin
_SaveFPU(SFPU);
{
{ Stage values
{   0: Starting
{   1: Loading
{   2: Processing (color balancing, smoothing, rotating, auto contrasting, interpolation, etc...)
{  -1: Done
}
If Context<>Nil Then
   Begin
   MyForm:=Context;
   If Height<>0 Then
      MyForm.ProgressBar1.Position:=Round((CurrLine/Height)*100)
   Else
      MyForm.ProgressBar1.Position:=0;
   If Stage=-1 Then
      MyForm.ProgressBar1.Position:=100;
   MyForm.ProgressBar1.Update;
   MyForm.LStage.Caption:=Msg;
   MyForm.LStage.Update;
   MyForm.Update;
   DoAbort:=False;
   If PeekMessage(Msg1,MyForm.BAbort.Handle,WM_LBUTTONDOWN,WM_LBUTTONDOWN,PM_NOREMOVE) Then
      Begin
      DoAbort:=True;
      MyForm.FAbortBatch:=True;
      End;
   If DoAbort Then
      Abort;
   End;
_RestFPU(SFPU);
End;


procedure TForm1.Button2Click(Sender: TObject);
Var
  Buffer:PChar;
  Buffer2:PChar;
  Buffer3:PChar;
  Buffer4:PChar;
  PBuffer:Array[0..6] Of PChar;
  ScanLines:ALines;
  X:Integer;
  IWidth:LongInt;
  IHeight:LongInt;
  PMake:Array[0..1000] Of Char;
  PModel:Array[0..1000] Of Char;
  PTimeStamp:Array[0..1000] Of Char;
  IFileName:PChar;
  ThumbFileName:PChar;
  Status:Integer;
  TmpBmp:TBitMap;
  IShrink:Integer;
  DummyShrink,NWidth,NHeight:Integer;
  FilePtrs:TRawFilePointers;
  MyStream:TRawFileStream;
  MyStreamOut:TRawFileStream;
  StreamIn:TFastFile;
  StreamOut:TFastFile;
  StreamInMemory:TMemoryStream;
  ExifRecord:TExifRecord;
  ExifEssentials:TExifEssentials;
  ProgressInfo:TProgress;
  RAWSettings:TRAWSettings;
  ErrorVal:Integer;
  ImageTmp:TPicture;
  C:Char;
begin
FAbort:=False;
{GetMem(Buffer,1000);
StrCopy(Buffer,PChar('dcraw.exe -2 -v -q -a '+FileName+'  '));
PBuffer[0]:=Buffer;
PBuffer[1]:=Pointer(LongInt(Buffer)+10);
PBuffer[2]:=Pointer(LongInt(Buffer)+13);
PBuffer[3]:=Pointer(LongInt(Buffer)+16);
PBuffer[4]:=Pointer(LongInt(Buffer)+19);
PBuffer[5]:=Pointer(LongInt(Buffer)+22);
PBuffer[6]:=Pointer(LongInt(Buffer)+22+Length(FileName)+1);  }

IFileName:=PChar(FileName);
OutFileName:=FileName+'.thm';
ThumbFileName:=PChar(OutFileName);
raw_settings_init(RAWSettings);
RAWSettings.iGamma_Val:=RValue(TGamma.Text);
RAWSettings.iBright:=RValue(TBright.Text);
RAWSettings.iScale1:=RValue(TScale1.Text);
RAWSettings.iScale2:=RValue(TScale2.Text);
RAWSettings.iScale3:=RValue(TScale3.Text);
RAWSettings.iScale4:=RValue(TScale4.Text);
If CBBlack.Checked Then
   RAWSettings.iBlack_Level:=SEBlack.Value
Else
   RAWSettings.iBlack_Level:=-1;
Case CBFourColor.Checked Of
     True:RAWSettings.IFour_Color_RGB:=1;
     False:RAWSettings.IFour_Color_RGB:=0;
     End;
RAWSettings.IQuality:=CBQuality.ItemIndex;
RAWSettings.IShrink:=RGShrink.ItemIndex;
Case CBAutoWB.Checked Of
     True:RAWSettings.IUse_Auto_WB:=1;
     False:RAWSettings.IUse_Auto_WB:=0;
     End;
Case CBCameraWB.Checked Of
     True:RAWSettings.IUse_Camera_WB:=1;
     False:RAWSettings.IUse_Camera_WB:=0;
     End;
Case CBRAWCOlors.Checked Of
     True:RAWSettings.IRAWColors:=1;
     False:RAWSettings.IRAWColors:=0;
     End;
RAWSettings.IHighLight:=CBHighLights.ItemIndex;
RAWSettings.IRGB_Colors:=CBColors.ItemIndex;
IShrink:=RAWSettings.IShrink;

raw_fileio_init_Pointers(FilePtrs);
raw_fileio_init_stream(MyStream);
StreamIn:=TFastFile.Create(IFileName,fmOpenRead,ErrorVal);
StreamIn.Position:=0;
MyStream.FFile:=StreamIn;
FilePtrs.IFile:=@MyStream;
raw_exif_init(ExifRecord);
try
Status:=RawInfo(@FilePtrs,
                @ExifRecord,
                @ExifEssentials,
                IFileName,
                IShrink,
                IWidth,IHeight,
                @PMake,
                @PModel,
                @PTimeStamp);
If Status=0 Then
   Begin
   Image1.Picture.Bitmap.Width:=IWidth;
   Image1.Picture.Bitmap.PixelFormat:=pf24bit;
   Image1.Picture.Bitmap.Height:=IHeight;
 {!}  For X:=0 To Image1.Picture.Bitmap.Height-1 Do
 {!}      ScanLines[X]:=Image1.Picture.Bitmap.Scanline[X];
   MyStream.FFile.Position:=0;
   raw_exif_init(ExifRecord);
   raw_progress_init(ProgressInfo,0);
   ProgressInfo.Progress:=@RawProgress;
   ProgressInfo.Context:=Self;
   Status:=FromRawToPSD(@FilePtrs,@ExifRecord,@ExifEssentials,@ProgressInfo,IFileName,ThumbFileName,RAWSettings,ScanLines,IWidth,IHeight,PMake,PModel,PTimeStamp);
   If Status=0 Then
      Begin
      Image1.RePaint;
      ScrollBox1.Width:=IWidth;
      ScrollBox1.Height:=IHeight;
      LDim.Caption:='Resolution: '+IntToStr(IWidth)+'x'+IntToStr(IHeight);
      MakeImageSmaller(Image1.Picture,Image2);
      If FBatch Then
         Image1.Picture.SaveToFile(Edit1.Text+'.batch.bmp');
      End
   Else
      Begin
      If FBatch=False Then
         Begin
         If Status=7 Then
            MessageDlg('LOADING WAS ABORTED!',mtInformation,[mbok],0)
         Else
            MessageDlg('Error in decoding RAW image. Error code='+IntToStr(Status),mtInformation,[mbok],0);
         End;
      End;
   End
Else
  Begin
  If FBatch=False Then
      MessageDlg('Error in decoding RAW image. Error code='+IntToStr(Status),mtInformation,[mbok],0);
  End;
except
end;
StreamIn.Free;
//FreeMem(Buffer,1000);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
Image1.Picture.SaveToFile(Edit1.Text+'.saved.bmp');
MessageDlg('Saving image as "'+Edit1.Text+'.Saved.Bmp".',mtInformation,[mbOk],0);
end;

procedure TForm1.Button3Click(Sender: TObject);
Var
  Buffer:PChar;
  Buffer2:PChar;
  Buffer3:PChar;
  Buffer4:PChar;
  PBuffer:Array[0..5] Of PChar;
  PMake:Array[0..1000] Of Char;
  PModel:Array[0..1000] Of Char;
  PTimeStamp:Array[0..1000] Of Char;
  ScanLines:ALines;
  X:Integer;
  IWidth:LongInt;
  IHeight:LongInt;
  IFileName:PChar;
  Status:Integer;
  FilePtrs:TRawFilePointers;
  MyStream:TRawFileStream;
  StreamIn:TFastFile;
  ExifRecord:TExifRecord;
  ExifEssentials:TExifEssentials;
  IShrink:Integer;
  Dummy:Integer;
begin
{GetMem(Buffer,1000);
StrCopy(Buffer,PChar('dcraw.exe -2 -v -q '+FileName+'  '));
PBuffer[0]:=Buffer;
PBuffer[1]:=Pointer(LongInt(Buffer)+10);
PBuffer[2]:=Pointer(LongInt(Buffer)+13);
PBuffer[3]:=Pointer(LongInt(Buffer)+16);
PBuffer[4]:=Pointer(LongInt(Buffer)+19);
PBuffer[5]:=Pointer(LongInt(Buffer)+25);
      }
FillChar(PMake,1000,1);
FillChar(PModel,1000,2);

IFileName:=PChar(FileName);
raw_fileio_init_Pointers(FilePtrs);
raw_fileio_init_stream(MyStream);
Try
StreamIn:=TFastFile.Create(IFileName,0,Dummy);
Except
End;
MyStream.FFile:=StreamIn;
FilePtrs.IFile:=@MyStream;
raw_exif_init(ExifRecord);

IShrink:=RGShrink.ItemIndex;
Status:=RawInfo(@FilePtrs,@ExifRecord,@ExifEssentials,IFileName,IShrink,IWidth,IHeight,@PMake,@PModel,@PTimeStamp);
If Status=0 Then
   Begin              
   ShowMessage('ISO = '+IntToStr(ExifEssentials.ISO_Speed)+#13+
              'Shutter Speed = '+Format('%1.5f',[ExifEssentials.Shutter_Speed])+' second.'+#13+
              'Aperture = '+Format('%6f',[ExifEssentials.Aperture])+#13+
              'Focal Length = '+Format('%6f',[ExifEssentials.Focal_Length])+#13+
              'Rotate Image '+IntToStr(ExifEssentials.Rotation)+' degress');
   messagedlg('Remember, the photo is NOT loaded by this button, only the file info...'+#13+#13+
           'Click LOAD RAW to show the photo.',mtinformation,[mbok],0);
   LDim.Caption:='Resolution: '+IntToStr(IWidth)+'x'+IntToStr(IHeight);
   Label4.Caption:='Make='+PMake;
   Label5.Caption:='Model='+PModel;
   End
Else
   MessageDlg('Error in getting RAW info. Error code='+IntToStr(Status),mtInformation,[mbok],0);
StreamIn.Free;
//FreeMem(Buffer,1000);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  pic : TPicture;
begin
  pic := TPicture.Create;
  pic.LoadFromFile('C:\Documents and Settings\dolphin.MINSK\Desktop\IMG_5707.CR2');
  pic.SaveToFile('c:\1.bmp');
exit;
OpenDialog1.InitialDir:=ExtractFilePath(Application.EXEName);
CBHighlights.ItemIndex:=0;
CBColors.ItemIndex:=1;
CBQuality.ItemIndex:=1;
FBatch:=False;
FLastThumbnail:='';
end;

procedure TForm1.Button4Click(Sender: TObject);
Var
 iFileName:PChar;
 ThumbName:Array[0..MAX_PATH] Of Char;
 ThumbNailType:Integer;
 OldThumbName:String;
 NewThumbName:String;
 Status:Integer;
 FilePtrs:TRAWFilePointers;
 S1:String;
 ImageTmp:TPicture;
begin
IFileName:=PChar(FileName);
ThumbNailType:=100;
ForceDirectories('C:\Temp\');

If FBatch=False Then
   ThumbName:='C:\Temp\thumb.tmp.jpg'
Else
   Begin
   S1:=Edit1.Text+'.batch.thumb';
   StrPCopy(ThumbName,S1);
   End;
raw_fileio_init_Pointers(FilePtrs);

try
Status:=Extract_Thumbnail(Self,@FilePtrs,IFileName,ThumbName,ThumbnailType);
// 0=Thumbnail not found
// 1=Thumbnail made
// 2=Source file error probably doesn't exist
// 3=Dest file error probably path doesn't exist
// 4=I/O Pointers invalid probably didn't setup parameters correctly
// 5=Some memory allocation problems
except
  on EZeroDivide do Begin
                    End;
  on EDivByZero do Begin
                    End;
end;

Case Status Of
  0:Begin
      DeleteFile(ThumbName);
    End;
  1,-1:
    Begin
      If Status=-1 Then
      Begin
        If FBatch=False Then MessageDlg('Thumbnail data has some corruption.',mtError,[mbok],0);
      End;

      Begin
        Try
          Case ThumbNailType Of
            RAW_THUMB_BAD:
            Begin
                            If FBatch=False Then
                            MessageDlg('Thumbnail was thought to be created, but it wasn''t useful :('+#13+#13+
                                       'Please email me the RAW file, so that I may look at it.   smatters@smatters.com',
                                       mtError,[mbok],0);
                            DeleteFile(ThumbName);
            End;
           RAW_THUMB_NOTAVAIL:
           Begin
                         If FBatch=False Then
                            MessageDlg('No thumbnail created!',mtinformation,[mbok],0);
                         DeleteFile(ThumbName);
           End;
           RAW_THUMB_JPG:
           Begin
                         If FBatch=False Then
                            MessageDlg('JPG thumbnail created!',mtinformation,[mbok],0);
                         OldThumbName:=ThumbName;
                         NewThumbName:=ThumbName+'.jpg';
                         FileSetAttr(NewThumbName,0);
                         DeleteFile(NewThumbName);
                         RenameFile(PChar(OldThumbName),PChar(NewThumbName));
           End;
           RAW_THUMB_PPM:
           Begin
                         If FBatch=False Then
                            MessageDlg('PPM thumbnail created!',mtinformation,[mbok],0);
                         OldThumbName:=ThumbName;
                         NewThumbName:=ThumbName+'.ppm';
                         FileSetAttr(NewThumbName,0);
                         DeleteFile(NewThumbName);
                         RenameFile(PChar(OldThumbName),PChar(NewThumbName));
           End;
           RAW_THUMB_TIFF:
           Begin
                         If FBatch=False Then
                            MessageDlg('TIFF thumbnail created!',mtinformation,[mbok],0);
                         OldThumbName:=ThumbName;
                         NewThumbName:=ThumbName+'.tiff';
                         FileSetAttr(NewThumbName,0);
                         DeleteFile(NewThumbName);
                         RenameFile(PChar(OldThumbName),PChar(NewThumbName));
           End;
        End;

      Case ThumbNailType Of
           RAW_THUMB_JPG,
           RAW_THUMB_PPM,
           RAW_THUMB_TIFF:Begin
                          FLastThumbnail:=NewThumbName;
                          ImageTmp:=TPicture.Create;
                          ImageTmp.LoadFromFile(NewThumbName);
                          MakeImageSmaller(ImageTmp,ImageThumb);
                          ImageTmp.Free;
                          End;
           End;
      Except
      End;
      End;






   If FBatch=False Then
      MessageDlg('Keep in mind that most RAW files have thumbnails, BUT NOT ALL. Also keep in mind that most thumbnails are stored in the JPG format, BUT NOT ALL. The other format that the thumbnail can be stored in is call PPM.',mtInformation,[mbOk],0);
   End;
  2:Begin
    If FBatch=False Then
       MessageDlg('Source file not found :( <should be impossible>.',mtError,[mbok],0);
    End;
  3:Begin
    If FBatch=False Then
       MessageDlg('Destination thumbnail could not be created :( <should be impossible, unless disk full or disk protected>.',mtError,[mbok],0);
    End;
  4:Begin
    If FBatch=False Then
       MessageDlg('FilePtrs <I/O Pointers> invalid probably didn''t call "raw_fileio_init_Pointers".',
                   mtError,[mbok],0);
    End;
  5:Begin
    If FBatch=False Then
       MessageDlg('Some kind of INTERNAL error in the DCRAW code, mayne memory allocation or other problems :(.',
                   mtError,[mbok],0);
    End;
  End;
end;





Type
  TProcedureRawInfo=Function(filename:pchar;Var IWidth:LongInt;Var IHeight:LongInt;iMake:PChar;iModel:PChar):Integer; cdecl;
procedure TForm1.Button5Click(Sender: TObject);
Var
  H:THandle;
  FarCall:TProcedureRawInfo;
  FarCallPtr:Pointer;
  iWidth,iHeight,iTrim:Integer;
  iMake,iModel:Array[0..1000] Of Char;
  Path:String;
  S:TSearchRec;
  OldIndex,X:Integer;
  List:TStringList;
  Images:Boolean;
  Thumbs:Boolean;
  Dir:String;
Procedure ReEnable;
Begin
BringToFront;
Self.Enabled:=True;
End;
begin
FBatch:=False;
Dir:=ExtractFilePath(OpenPictureDialog1.FileName);
Self.Enabled:=False;
If SelectDirectory('Select folder to batch process','\',Dir) Then
   Begin
   ReEnable;
   Edit1.Text:='';
   ChDir(ExtractFilePath(Dir+'\'));
   OpenPictureDialog1.FileName:=Dir+'\Crap.txt';
   FileName:='';
   messagedlg('Click IDENTIFY or LOAD-RAW now...',mtinformation,[mbok],0);
   If messagedlg('This BATCH mode will process all files in the current folder and produce BITMAP files of the RAW images. In addition, it will create THUMBNAIL files of each RAW image as well.'+#13+#13+
                 'Do you want to process the entire folder in batch mode?',mtInformation,[mbyes,mbno],0)=mrYes Then
      FBatch:=True;
   End;
ReEnable;
If FBatch Then
   Begin
   List:=TStringList.Create;
   List.Duplicates:=DupIgnore;
   List.Sorted:=True;
   Path:=ExtractFilePath(OpenPictureDialog1.FileName);
   X:=FindFirst(Path+'*.*',$FFFFFFFF,S);
   If X=0 Then
      Begin
      While (X=0) Do
         Begin
         List.Add(S.Name);
         X:=FindNext(S);
         End;
      FindClose(S);
      End;
   OldIndex:=RGShrink.ItemIndex;
   RGShrink.ItemIndex:=1;
   Images:=False;
   Thumbs:=False;
   If MessageDlg('BATCH process RAW files into BMP files and also extract out thumbnails?'+#13+#13+
              'Do you wish to do both?',mtInformation,[mbYes,mbNo],0)=mrYes Then
      Begin
      Images:=True;
      Thumbs:=True;
      End
   Else
      Begin
      If MessageDlg('You can choose which process you want. You can choose either extract only IMAGES or extract only THUMBNAILS.'+#13+#13+
                    'Do you wish extract only IMAGES?',mtInformation,[mbYes,mbNo],0)=mrYes Then
         Images:=True
      Else
         Thumbs:=True;
      End;
   FAbortBatch:=False;
   For X:=0 To List.Count-1 Do
      Begin
      Edit1.Text:=List[X];
      FileName:=List[X];
      If Images Then
         Begin
         writeln('EXTRACT IMAGE:',filename);
         Button2Click(Nil);
         End;
      If Thumbs Then
         Begin
         writeln('EXTRACT THUMBNAIL:',filename);
         Button4Click(Nil);
         End;
      Application.Processmessages;
      If FAbortBatch Then Break;
      End;
   RGShrink.ItemIndex:=OldIndex;
   List.Free;
   End;
FBatch:=False;
Exit;







(* Not used
If OpenPictureDialog1.Execute Then
   Begin
   ImageThumb.Picture.LoadFromFile(OpenPictureDialog1.FileName);
   End;
Exit;
H:=LoadLibrary('MYDLL');
If H<>0 Then
   Begin
   FarCallPtr:=GetProcAddress(H,'RawInfo');
   If FarCallPtr<>Nil Then
      Begin
      FarCall:=FarCallPtr;
      FarCall('1.crw',iWidth,iHeight,iTrim,iMake,iModel)
      End
   Else
      MessageDlg('PROCEDURE NOT FOUND',mtinformation,[mbok],0);
   FreeLibrary(h);
   End
Else
   MessageDlg('DLL not found',mtinformation,[mbok],0);
*)
end;

procedure TForm1.Button8Click(Sender: TObject);
Var
  ImageTmp:TPicture;
begin
ImageTmp:=TPicture.Create;
ImageTmp.LoadFromFile(FLastThumbnail);
MakeImageSmaller(ImageTmp,ImageThumb);
ImageTmp.Free;
end;

procedure TForm1.BAbortClick(Sender: TObject);
begin
FAbortBatch:=True;
Abort;
end;

procedure TForm1.CBRawColorsClick(Sender: TObject);
begin
If CBRawColors.Checked Then
   messagedlg('When RAW COLORS is checked, msdcraw will NOT PERFORM ANY COLOR BALANCING. Only the true colors from the camera are used.'+#13+#13+
              'NOTE: For most cameras a GREEN TINT is noticable, for Foveon chips like some SIGMA cameras, you will not notice any difference at all.',
              mtinformation,[mbok],0);
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
FileName:=Edit1.Text;
end;

end.
