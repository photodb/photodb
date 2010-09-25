unit UnitConvertImagesThread;

interface

uses
  Windows, Messages, Classes, Dolphin_DB, Forms, Graphics, GraphicCrypt,
  Jpeg, RAWImage, PngImage, TiffImageUnit, ImageConverting, GIFImage, GraphicEx,
  SysUtils, Language, UnitDBKernel, UnitPropeccedFilesSupport, uVistaFuncs,
  UnitDBDeclare, uFileUtils;

type
  TConvertThreadOptions = record
   ImageList : TArStrings;
   IDList : TArInteger;
   ConvertableImageClassIndex : integer;
   EndDirectory : String;
   UseOtherFolder : Boolean;
   ReplaceImages : Boolean;
  end;

type
  TConvertImagesThread = class(TThread)
  private
    fSender : TForm;
    FSID : string;
    fOnDone : TNotifyEvent;
    fOptions : TConvertThreadOptions;
    IntParam : integer;
    StrParam : String;
    BoolParam : Boolean;
    EventInfo : TEventValues;
    EventParams : TEventFields;
    ProgressWindow : TForm;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: Boolean;
                      Sender: TForm; SID: string; OnDone: TNotifyEvent;
                      Options: TConvertThreadOptions);
    procedure SetProgressPosition(Position : integer);
    procedure SetProgressPositionSynch;
    procedure ShowErrorWindow;
    procedure ShowWriteErrorWindow;
    procedure DoDBKernelEvent;
    procedure DoOnDone;
    procedure InitializeProgress;
    procedure DestroyProgress;
    procedure IfBreakOperation;
    procedure DoDBkernelEventRefreshList;
    procedure RemoveFileFromUpdatingList;
  end;

implementation

uses UnitImageConverter, ProgressActionUnit;

{ TConvertImagesThread }

constructor TConvertImagesThread.Create(CreateSuspennded: Boolean;
  Sender: TForm; SID: string; OnDone: TNotifyEvent;
  Options: TConvertThreadOptions);
var
  I: Integer;
begin
  inherited Create(False);
  FSender := Sender;
  FSID := SID;
  FOnDone := OnDone;
  FOptions := Options;

  for I := 0 to Length(Options.ImageList) - 1 do
    ProcessedFilesCollection.AddFile(Options.ImageList[I]);
end;

procedure TConvertImagesThread.DestroyProgress;
begin
 (ProgressWindow as TProgressActionForm).WindowCanClose:=true;
 ProgressWindow.Release;
end;

procedure TConvertImagesThread.DoDBKernelEvent;
begin
 DBKernel.DoIDEvent(self,IntParam,EventParams,EventInfo);
end;

procedure TConvertImagesThread.DoDBkernelEventRefreshList;
var
  EventInfo : TEventValues;
begin
 DBKernel.DoIDEvent(Self,IntParam,[EventID_Repaint_ImageList],EventInfo);
end;

procedure TConvertImagesThread.DoOnDone;
begin
 if Assigned(fOnDone) then fOnDone(self);
end;

procedure TConvertImagesThread.Execute;
var
  OldGraphic, NewGraphic : TGraphic;
  TempBitmap : TBitmap;
  Password, NewEXT, FileName, FileDir, EndDir : string;
  NewGraphicClass : TGraphicClass;
  i, j : integer;
  b : boolean;
begin
 FreeOnTerminate:=true;

 Synchronize(InitializeProgress);

 NewGraphic:=nil;
 OldGraphic:=nil;
 TempBitmap:=nil;
 if GetConvertableImageClasses[fOptions.ConvertableImageClassIndex]=TBitmap then
 NewEXT:='bmp' else
 if GetConvertableImageClasses[fOptions.ConvertableImageClassIndex]=TJpegImage then
 NewEXT:='jpg' else
 if GetConvertableImageClasses[fOptions.ConvertableImageClassIndex]=TTIFFGraphic then
 NewEXT:='tiff' else
 NewEXT:=GraphicExtension(GetConvertableImageClasses[fOptions.ConvertableImageClassIndex]);
 NewGraphicClass:=GetGraphicClass(NewEXT,true);
 for i:=0 to Length(FOptions.ImageList)-1 do
 begin
  Synchronize(IfBreakOperation);
  if BoolParam then
  begin
   for j:=i to Length(FOptions.ImageList)-1 do
   begin
    StrParam:=fOptions.ImageList[j];
    Synchronize(RemoveFileFromUpdatingList);
   end;
   Synchronize(DoDBkernelEventRefreshList);
   Break;
  end;
  SetProgressPosition(i+1);

  Password:='';
  if ValidCryptGraphicFile(FOptions.ImageList[i]) then
  begin
   Password:=DBkernel.FindPasswordForCryptImageFile(FOptions.ImageList[i]);
   if Password='' then Continue;
  end;
  NewGraphic:=NewGraphicClass.Create;
  try
   if Password='' then
   begin
    OldGraphic:=GetGraphicClass(GetExt(FOptions.ImageList[i]),false).Create;
    if OldGraphic is TRAWImage then
    (OldGraphic as TRAWImage).LoadHalfSize:=false;
    OldGraphic.LoadFromFile(FOptions.ImageList[i])
   end else
   OldGraphic:=DeCryptGraphicFile(FOptions.ImageList[i],Password,true);
   if (OldGraphic is TGIFImage) or (NewGraphic is PngImage.TPngGraphic) then
   begin
    TempBitmap:=nil;
    TempBitmap := TBitmap.Create;
    TempBitmap.Assign(OldGraphic);
    NewGraphic.Assign(TempBitmap);
    TempBitmap.Free;
   end else
   NewGraphic.Assign(OldGraphic);
  except
   BoolParam:=not ((i=Length(FOptions.ImageList)-1) or (Length(FOptions.ImageList)=1));
   StrParam:=FOptions.ImageList[i];
   Synchronize(ShowErrorWindow);
   if ID_YES=IntParam then
   begin
    if OldGraphic<>nil then begin OldGraphic.Free; OldGraphic:=nil; end;
    if TempBitmap<>nil then begin TempBitmap.Free; TempBitmap:=nil; end;
    if NewGraphic<>nil then begin NewGraphic.Free; NewGraphic:=nil; end;
    Continue;
   end else
   begin
    if OldGraphic<>nil then begin OldGraphic.Free; OldGraphic:=nil; end;
    if TempBitmap<>nil then begin TempBitmap.Free; TempBitmap:=nil; end;
    if NewGraphic<>nil then begin NewGraphic.Free; NewGraphic:=nil; end;

    for j:=i to Length(FOptions.ImageList)-1 do
    begin
     StrParam:=FOptions.ImageList[j];
     Synchronize(RemoveFileFromUpdatingList);
    end;

    Synchronize(DestroyProgress);
    Synchronize(DoOnDone);
    exit;
   end;
  end;
  OldGraphic.Free;

  FileDir:=GetDirectory(fOptions.ImageList[i]);
  EndDir:=fOptions.EndDirectory;
  FormatDir(EndDir);

  if (AnsiLowerCase(FileDir)=AnsiLowerCase(EndDir)) or not fOptions.UseOtherFolder then
  begin
   try
    FileName:=GetConvertedFileName(fOptions.ImageList[i],NewEXT);
    if NewGraphic is TJPEGImage then
    begin
     (NewGraphic as TJPEGImage).CompressionQuality:=DBKernel.ReadInteger('','JPEGCompression',75);
     (NewGraphic as TJPEGImage).ProgressiveEncoding:=DBKernel.ReadBool('','JPEGProgressiveMode',false);
    end;

    Repeat
     j:=1;
     try
      SetLastError(0);

      if fOptions.ReplaceImages and (GetExt(fOptions.ImageList[i])=GetExt(FileName)) then
      NewGraphic.SaveToFile(fOptions.ImageList[i]) else
      NewGraphic.SaveToFile(FileName);

      if (GetLastError<>0) and (GetLastError<>183) and (GetLastError<>6) then
      raise Exception.Create('Error code = '+IntToStr(GetLastError));
     except
      on e : Exception do
      begin
       StrParam:=e.Message;
       Synchronize(ShowWriteErrorWindow);

       if IntParam=IDABORT then
       begin
        NewGraphic.free;
        Synchronize(DoOnDone);
        exit;
       end;
       if IntParam=IDRETRY then j:=0;
       if IntParam=IDIGNORE then
       begin
        NewGraphic.free;
        break;
       end;
      end;
     end;
    until j=1;

    NewGraphic.free;
    if Password<>'' then
    if fOptions.ReplaceImages and (GetExt(fOptions.ImageList[i])=GetExt(FileName)) then
    CryptGraphicFileV2(fOptions.ImageList[i],Password,0) else
    CryptGraphicFileV2(FileName,Password,0);
   except
   end;
   if fOptions.ReplaceImages then
   begin
    try
     if (GetExt(fOptions.ImageList[i])=GetExt(FileName)) then
     DeleteFile(FileName) else
     DeleteFile(fOptions.ImageList[i]);
    except
    end;
    if (GetExt(fOptions.ImageList[i])=GetExt(FileName)) then
    begin
     UpdateImageRecord(fOptions.ImageList[i],fOptions.IDList[i]);
     EventInfo.Name:=fOptions.ImageList[i];
     EventInfo.NewName:=fOptions.ImageList[i];

     IntParam:=fOptions.IDList[i];
     EventParams:=[EventID_Param_Image];
     Synchronize(DoDBKernelEvent);
     //DBKernel.DoIDEvent(self,fOptions.IDList[i],[EventID_Param_Image],EventInfo);
    end else
    begin
     UpdateMovedDBRecord(fOptions.IDList[i],FileName);
     UpdateImageRecord(FileName,fOptions.IDList[i]);
     EventInfo.Name:=fOptions.ImageList[i];
     EventInfo.NewName:=FileName;

     IntParam:=fOptions.IDList[i];
     EventParams:=[EventID_Param_Name];
     Synchronize(DoDBKernelEvent);
     //DBKernel.DoIDEvent(self,fOptions.IDList[i],[EventID_Param_Name],EventInfo);
     EventInfo.Name:=FileName;
     EventInfo.NewName:=FileName;
     EventParams:=[EventID_Param_Image];
     Synchronize(DoDBKernelEvent);
     //DBKernel.DoIDEvent(self,fOptions.IDList[i],[EventID_Param_Image],EventInfo);
    end;
   end
  end else
  begin
   if fOptions.ReplaceImages then
   FileName:=EndDir+GetFileNameWithoutExt(fOptions.ImageList[i])+'.'+NewEXT else
   FileName:=GetConvertedFileNameWithDir(fOptions.ImageList[i],EndDir,NewEXT);
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
       Synchronize(ShowWriteErrorWindow);
       if IntParam=IDABORT then
       begin
        NewGraphic.free;
        Synchronize(DoOnDone);
        exit;
       end;
       if IntParam=IDRETRY then j:=0;
       if IntParam=IDIGNORE then
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
    CryptGraphicFileV2(FileName,Password,0);
   except
   end;
  end;

  StrParam:=FOptions.ImageList[i];
  Synchronize(RemoveFileFromUpdatingList);
  Synchronize(DoDBkernelEventRefreshList);
 end;

 DBkernel.WriteBool('Resizer','Replace',fOptions.ReplaceImages);
 DBkernel.WriteBool('Resizer','Make New',not fOptions.ReplaceImages);

 Synchronize(DestroyProgress);
 Synchronize(DoOnDone);
end;

procedure TConvertImagesThread.IfBreakOperation;
begin
 BoolParam:=(ProgressWindow as TProgressActionForm).Closed;
end;

procedure TConvertImagesThread.InitializeProgress;
begin
 ProgressWindow:=GetProgressWindow(true);
 With ProgressWindow as TProgressActionForm do
 begin
  CanClosedByUser:=True;
  OneOperation:=false;
  OperationCount:=1;
  OperationPosition:=1;
  MaxPosCurrentOperation:=Length(fOptions.ImageList);
  xPosition:=0;
  Show;
 end;
end;

procedure TConvertImagesThread.RemoveFileFromUpdatingList;
begin
 ProcessedFilesCollection.RemoveFile(StrParam);
end;

procedure TConvertImagesThread.SetProgressPosition(Position: integer);
begin
 IntParam:=Position;
 Synchronize(SetProgressPositionSynch);
end;

procedure TConvertImagesThread.SetProgressPositionSynch;
begin
 (ProgressWindow as TProgressActionForm).xPosition:=IntParam;
end;

procedure TConvertImagesThread.ShowErrorWindow;
var
  Text : String;
begin
 if BoolParam then
 Text:=TEXT_MES_ERROR_DURING_CONVERTING_IMAGE_F_DO_NEXT else
 Text:=TEXT_MES_ERROR_DURING_CONVERTING_IMAGE_F;

 IntParam:=MessageBoxDB(Dolphin_DB.GetActiveFormHandle, Format(Text,[StrParam]),TEXT_MES_ERROR,TD_BUTTON_YESNO,TD_ICON_ERROR);
end;

procedure TConvertImagesThread.ShowWriteErrorWindow;
begin
 //TODO: IntParam:=MessageBoxDB(FSender.Handle,TEXT_MES_ERROR,Format(TEXT_MES_WRITE_ERROR_F,[StrParam]),'', TD_BUTTON_ABORT_RETRY_IGNORE,TD_ICON_ERROR);
 IntParam:=Application.MessageBox(PWideChar(Format(TEXT_MES_WRITE_ERROR_F,[StrParam])),TEXT_MES_ERROR, MB_ICONERROR or MB_ABORTRETRYIGNORE);
end;

end.
