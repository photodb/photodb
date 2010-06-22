unit UnitRotatingImagesThread;

interface

uses
  Windows, UnitDBKernel, Classes, UnitPropeccedFilesSupport, Dolphin_DB, Forms,
  Graphics, GDIPlusRotate, SysUtils, GraphicCrypt, ImageConverting, uVistaFuncs,
  JPEG, Language, UnitDBDeclare, UnitDBCommonGraphics;

type
   TRotatingImagesThreadOptions = record
    Files : TArStrings;
    IDs : TArInteger;
    Rotate : TArInteger;
    Action : integer;
    TryKeepOriginalFormat : boolean;
    FormatIndex : integer;
    RotateWithoutPromt : boolean;
    RotateEvenIfFileInDB : boolean;
    RotateCW, RotateCCW, Rotate180 : boolean;
    UseAnotherFolder : boolean;
    EndDir : string;
    IsViewer : Boolean;
    ReplaceImages : boolean;
   end;

type
  TRotatingImagesThread = class(TThread)
  private          
     fOptions:  TRotatingImagesThreadOptions ;
     BoolParam : boolean;
     IntParam : integer; 
     StrParam : string;      
     Count : integer; 
     ProgressWindow : TForm;
     EventInfo : TEventValues;
     Params : TEventFields;
    { Private declarations }
  protected
    procedure Execute; override;
    procedure InitializeProgress;
    procedure DestroyProgress;   
    procedure IfBreakOperation;
    procedure SetProgressPosition(Position : integer);
    procedure SetProgressPositionSynch;
    procedure RemoveFileFromUpdatingList;  
    procedure DoDBkernelEventRefreshList;
    procedure ShowError;                     
    procedure ShowErrorRights;
    procedure DoDBKernelEvent;
  public
     constructor Create(CreateSuspennded: Boolean; Options: TRotatingImagesThreadOptions );
  end;

implementation

uses ProgressActionUnit, ExplorerTypes;

{ TRotatingImagesThread }

constructor TRotatingImagesThread.Create(CreateSuspennded: Boolean;
  Options: TRotatingImagesThreadOptions);
var
  i : integer;
begin
 inherited create(true);
 fOptions:=Options;
 for i:=0 to Length(Options.Files)-1 do
 ProcessedFilesCollection.AddFile(Options.Files[i]);
 DoDBkernelEventRefreshList;
 if not CreateSuspennded then Resume;
end;

procedure TRotatingImagesThread.Execute;
var
  OldGraphic, NewGraphic : TGraphic;
  Temp : TBitmap;
  i, j: integer;
  NewGraphicClass : TGraphicClass;
  Password, NewEXT, FileName, OldEXT, FileDir, EndDir : string;
  oldattr, attr : integer;
  b : boolean;
  RetryCounter : integer;
begin
 InitGDIPlus;
 FreeOnTerminate:=true;
 OldGraphic:=nil;

 Count:=Length(fOptions.Files);
 Synchronize(InitializeProgress);
 for i:=0 to Length(fOptions.Files)-1 do
 begin
  SetProgressPosition(i+1);

  if fOptions.TryKeepOriginalFormat then
  begin
   OldEXT:=AnsiLowerCase(GetExt(fOptions.Files[i]));
   if ConvertableImageClass(GetGraphicClass(OldEXT,false)) then
   begin
    NewGraphicClass:=GetGraphicClass(OldEXT,true);
    NewEXT:=OldEXT;
   end else
   begin
    if GetConvertableImageClasses[fOptions.FormatIndex]=TBitmap then
    NewEXT:='bmp' else
    if GetConvertableImageClasses[fOptions.FormatIndex]=TJPEGImage then
    NewEXT:='jpg' else
    NewEXT:=GraphicExtension(GetConvertableImageClasses[fOptions.FormatIndex]);
    NewGraphicClass:=GetGraphicClass(NewEXT,true);
   end;
  end else
  begin
   NewEXT:=GraphicExtension(GetConvertableImageClasses[fOptions.FormatIndex]);
   NewGraphicClass:=GetGraphicClass(NewEXT,true);
  end;
  if (fOptions.IDs[i]<>0) and not fOptions.RotateEvenIfFileInDB then
  begin
   if fOptions.RotateCCW then RotateDBImage270(fOptions.IDs[i],fOptions.Rotate[i]);
   if fOptions.RotateCW  then RotateDBImage90(fOptions.IDs[i],fOptions.Rotate[i]);
   if fOptions.Rotate180 then RotateDBImage180(fOptions.IDs[i],fOptions.Rotate[i]);
   Continue;
  end;

  if DBKernel.Readbool('Options','UseGDIPlus',GDIPlusPresent) and GDIPlusPresent and (NewEXT='jpg') and (GetGraphicClass(OldEXT,false)=TJPEGImage) then
  begin
   Password:='';
   if ValidCryptGraphicFile(fOptions.Files[i]) then
   begin
    Password:=DBkernel.FindPasswordForCryptImageFile(fOptions.Files[i]);
    if Password='' then Continue else
    ResetPasswordInGraphicFile(fOptions.Files[i],Password);
   end;
   FileDir:=GetDirectory(fOptions.Files[i]);
   EndDir:=fOptions.EndDir;
   FormatDir(EndDir);

   if ((AnsiLowerCase(FileDir)=AnsiLowerCase(EndDir)) or not fOptions.UseAnotherFolder) then
   begin
    ExplorerTypes.LockedFiles[1]:=aGetTempFileName(fOptions.Files[i]);
    ExplorerTypes.LockedFiles[2]:=fOptions.Files[i];
    ExplorerTypes.LockTime:=Now;

    oldattr:=FileGetAttr(fOptions.Files[i]);
    attr:=oldattr;
    if (attr and SysUtils.fahidden)<>0 then attr:=attr-SysUtils.fahidden;
    if (attr and SysUtils.faReadOnly)<>0 then attr:=attr-SysUtils.faReadOnly;
    if (attr and SysUtils.faSysFile)<>0 then attr:=attr-SysUtils.faSysFile;

    FileSetAttr(fOptions.Files[i],attr);

    if fOptions.RotateCCW then  RotateGDIPlusJPEGFile(fOptions.Files[i],EncoderValueTransformRotate270);
    if fOptions.RotateCW then  RotateGDIPlusJPEGFile(fOptions.Files[i],EncoderValueTransformRotate90);
    if fOptions.Rotate180 then  RotateGDIPlusJPEGFile(fOptions.Files[i],EncoderValueTransformRotate180);

    //fixing EXIF

    if Password<>'' then CryptGraphicFileV1(fOptions.Files[i],Password,0);

    FileSetAttr(fOptions.Files[i],oldattr);

    ExplorerTypes.LockTime:=Now;
    UpdateImageRecord(fOptions.Files[i],fOptions.IDs[i]);
    EventInfo.Name:=fOptions.Files[i];
    EventInfo.NewName:=fOptions.Files[i];
    Params:=[EventID_Param_Name];
    IntParam:=fOptions.IDs[i];
    Synchronize(DoDBKernelEvent);
   end else
   begin
    if fOptions.TryKeepOriginalFormat then
    FileName:=EndDir+ExtractFileName(fOptions.Files[i]) else
    FileName:=GetConvertedFileNameWithDir(fOptions.Files[i],EndDir,NewEXT);

    oldattr:=FileGetAttr(fOptions.Files[i]);
    attr:=oldattr;
    if (attr and SysUtils.fahidden)<>0 then attr:=attr-SysUtils.fahidden;
    if (attr and SysUtils.faReadOnly)<>0 then attr:=attr-SysUtils.faReadOnly;
    if (attr and SysUtils.faSysFile)<>0 then attr:=attr-SysUtils.faSysFile;
    FileSetAttr(fOptions.Files[i],attr);
    //
    if fOptions.RotateCCW then RotateGDIPlusJPEGFile(fOptions.Files[i],EncoderValueTransformRotate270,true,FileName);
    if fOptions.RotateCW then RotateGDIPlusJPEGFile(fOptions.Files[i],EncoderValueTransformRotate90,true,FileName);
    if fOptions.Rotate180 then RotateGDIPlusJPEGFile(fOptions.Files[i],EncoderValueTransformRotate180,true,FileName);
    if Password<>'' then CryptGraphicFileV1(FileName,Password,0);
    FileSetAttr(fOptions.Files[i],oldattr);
    //
    EventInfo.Name:=FileName;
    EventInfo.NewName:=FileName;
    IntParam:=0;
    Params:=[EventID_Param_Name];
    Synchronize(DoDBKernelEvent);
   end;
  end else
  begin
  
  Password:='';
  if ValidCryptGraphicFile(fOptions.Files[i]) then
  begin
   Password:=DBkernel.FindPasswordForCryptImageFile(fOptions.Files[i]);
   if Password='' then Continue;
  end;
  NewGraphic:=NewGraphicClass.Create;
  try
   if Password='' then
   begin
    OldGraphic:=GetGraphicClass(GetExt(fOptions.Files[i]),false).Create;
    OldGraphic.LoadFromFile(fOptions.Files[i])
   end else
   OldGraphic:=DeCryptGraphicFile(fOptions.Files[i],Password);
   Temp := TBitmap.Create;
   Temp.Assign(OldGraphic);
   Temp.PixelFormat:=pf24bit;
  finally
   OldGraphic.Free;
  end;
  if fOptions.RotateCCW then Rotate270A(Temp);
  if fOptions.RotateCW then Rotate90A(Temp);
  if fOptions.Rotate180 then Rotate180A(Temp);
  NewGraphic.Assign(Temp);
  Temp.free;
  FileDir:=GetDirectory(fOptions.Files[i]);
  EndDir:=fOptions.EndDir;
  FormatDir(EndDir);
  if (AnsiLowerCase(FileDir)=AnsiLowerCase(EndDir)) or not fOptions.UseAnotherFolder then
  begin
   try
    FileName:=GetConvertedFileName(fOptions.Files[i],NewEXT);
    if NewGraphic is TJPEGImage then
    begin
     if fOptions.IsViewer then
     begin
      (NewGraphic as TJPEGImage).CompressionQuality:=DBKernel.ReadInteger('Viewer','JPEGCompression',75);
      (NewGraphic as TJPEGImage).ProgressiveEncoding:=DBKernel.ReadBool('Viewer','JPEGProgressiveMode',false);
     end else
     begin
      (NewGraphic as TJPEGImage).CompressionQuality:=DBKernel.ReadInteger('','JPEGCompression',75);
      (NewGraphic as TJPEGImage).ProgressiveEncoding:=DBKernel.ReadBool('','JPEGProgressiveMode',false);
     end;
    end;

    b:=false;
    RetryCounter:=0;
    Repeat
     j:=1;
     try
      SetLastError(0);
      Inc(RetryCounter);
      if fOptions.ReplaceImages and (GetExt(fOptions.Files[i])=GetExt(FileName)) then
      NewGraphic.SaveToFile(fOptions.Files[i]) else
      NewGraphic.SaveToFile(FileName);

      if (GetLastError<>0) and (GetLastError<>183) and (GetLastError<>6) then
      raise Exception.Create('Error code = '+IntToStr(GetLastError));
      //j:=0;
     except
      on e : Exception do
      begin
       if RetryCounter<RetryTryCountOnWrite then
       begin
        j:=0;
        Sleep(RetryTryDelayOnWrite);
       end else
      begin
       StrParam:=Format(TEXT_MES_WRITE_ERROR_F,[e.Message]);
       Synchronize(ShowError);
       if IntParam=IDABORT then
       begin
        NewGraphic.free;
        Synchronize(DestroyProgress);
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
     end;
    until j=1;
    if b then continue;

    NewGraphic.free;
    if Password<>'' then
    if fOptions.ReplaceImages and (GetExt(fOptions.Files[i])=GetExt(FileName)) then
    CryptGraphicFileV1(fOptions.Files[i],Password,0) else
    CryptGraphicFileV1(FileName,Password,0);
   except
   end;
   if fOptions.ReplaceImages then
   begin
    try
     if (GetExt(fOptions.Files[i])=GetExt(FileName)) then
     DeleteFile(FileName) else
     DeleteFile(fOptions.Files[i]);
    except
    end;
    if (GetExt(fOptions.Files[i])=GetExt(FileName)) then
    begin
     UpdateImageRecord(fOptions.Files[i],fOptions.IDs[i]);
     EventInfo.Name:=fOptions.Files[i];
     EventInfo.NewName:=fOptions.Files[i];
     Params:=[EventID_Param_Image];
     IntParam:=fOptions.IDs[i];
     Synchronize(DoDBKernelEvent);
    end else
    begin
     UpdateMovedDBRecord(fOptions.IDs[i],FileName);
     UpdateImageRecord(FileName,fOptions.IDs[i]);

     EventInfo.Name:=fOptions.Files[i];
     EventInfo.NewName:=FileName;
     Params:=[EventID_Param_Image,EventID_Param_Name];
     IntParam:=fOptions.IDs[i];
     Synchronize(DoDBKernelEvent);
    end;
   end;
  end else
  begin

   if fOptions.TryKeepOriginalFormat then
   FileName:=EndDir+GetFileNameWithoutExt(fOptions.Files[i])+'.'+NewEXT else
   FileName:=GetConvertedFileNameWithDir(fOptions.Files[i],EndDir,NewEXT);
   if NewGraphic is TJPEGImage then
   begin
    if fOptions.IsViewer then
    begin
     (NewGraphic as TJPEGImage).CompressionQuality:=DBKernel.ReadInteger('Viewer','JPEGCompression',75);
     (NewGraphic as TJPEGImage).ProgressiveEncoding:=DBKernel.ReadBool('Viewer','JPEGProgressiveMode',false);
    end else
    begin
     (NewGraphic as TJPEGImage).CompressionQuality:=DBKernel.ReadInteger('','JPEGCompression',75);
     (NewGraphic as TJPEGImage).ProgressiveEncoding:=DBKernel.ReadBool('','JPEGProgressiveMode',false);
    end;
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
       
       StrParam:=Format(TEXT_MES_WRITE_ERROR_F,[e.Message]);
       Synchronize(ShowError);
       if IntParam=IDABORT then
       begin
        NewGraphic.free;
        Synchronize(DestroyProgress);
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
    CryptGraphicFileV1(FileName,Password,0);
   except
   end;
  end;

  end;
  StrParam:=fOptions.Files[i];
  Synchronize(RemoveFileFromUpdatingList);
 end;
 Synchronize(DestroyProgress);
end;

procedure TRotatingImagesThread.DestroyProgress;
begin
 (ProgressWindow as TProgressActionForm).WindowCanClose:=true;
 ProgressWindow.Release;
 if UseFreeAfterRelease then ProgressWindow.Free;
end;

procedure TRotatingImagesThread.IfBreakOperation;
begin
 BoolParam:=(ProgressWindow as TProgressActionForm).Closed;
end;

procedure TRotatingImagesThread.InitializeProgress;
begin
 ProgressWindow:=GetProgressWindow(true);
 With ProgressWindow as TProgressActionForm do
 begin
  CanClosedByUser:=True;
  OneOperation:=false;
  OperationCount:=1;
  OperationPosition:=1;
  MaxPosCurrentOperation:=Count;
  xPosition:=0;
  FormShow(nil);
  ShowWindow(ProgressWindow.Handle,SW_SHOWNOACTIVATE);
  ProgressWindow.Invalidate;
  ProgressWindow.Refresh;
  ProgressWindow.Repaint;
  (ProgressWindow as TProgressActionForm).OperationProgress.DoPaint;
 end;
end;

procedure TRotatingImagesThread.RemoveFileFromUpdatingList;
begin
 ProcessedFilesCollection.RemoveFile(StrParam);
end;

procedure TRotatingImagesThread.SetProgressPosition(Position: integer);
begin
 IntParam:=Position;
 Synchronize(SetProgressPositionSynch);
end;

procedure TRotatingImagesThread.SetProgressPositionSynch;
begin
 (ProgressWindow as TProgressActionForm).xPosition:=IntParam;
 (ProgressWindow as TProgressActionForm).OnPaint(nil);
end;

procedure TRotatingImagesThread.DoDBkernelEventRefreshList;
var
  EventInfo : TEventValues;
begin
 DBKernel.DoIDEvent(nil,IntParam,[EventID_Repaint_ImageList],EventInfo);
end;

procedure TRotatingImagesThread.ShowError;
begin
 //TODO: MessageBoxDB
 IntParam:=Application.MessageBox(PChar(StrParam),PChar(TEXT_MES_ERROR), MB_ICONERROR or MB_ABORTRETRYIGNORE);
end;

procedure TRotatingImagesThread.DoDBKernelEvent;
begin
 DBKernel.DoIDEvent(self,IntParam,Params,EventInfo);
end;

procedure TRotatingImagesThread.ShowErrorRights;
begin
 IntParam:=MessageBoxDB(GetActiveFormHandle,TEXT_MES_YOU_HAVENT_RIGHTS_FOR_FULL_ACCESS_NEW_IMAGE_WILL_COPIED_IN_NEW_FILE,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING);
end;

end.
