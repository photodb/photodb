unit uShareImagesThread;

interface

uses
  uConstants,
  uRuntime,
  uMemory,
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  uThreadEx,
  uThreadForm,
  Vcl.Graphics,
  UnitDBDeclare,
  uAssociations,
  Winapi.ActiveX,
  uPortableDeviceUtils,
  GraphicCrypt,
  UnitDBKernel,
  RAWImage,
  uJpegUtils,
  uGraphicUtils,
  GraphicEx,
  uSettings,
  uBitmapUtils,
  uLogger,
  uShellThumbnails,
  uAssociatedIcons,
  Vcl.Imaging.Jpeg,
  Vcl.Imaging.pngImage,
  Vcl.ComCtrls,
  uPhotoShareInterfaces,
  uShellIntegration,
  CCR.Exif;

type
  TShareImagesThread = class;

  TItemUploadProgress = class(TInterfacedObject, IUploadProgress)
  private
    FThread: TShareImagesThread;
    FItem: TDBPopupMenuInfoRecord;
  public
    constructor Create(Thread: TShareImagesThread; Item: TDBPopupMenuInfoRecord);
    procedure OnProgress(Sender: IPhotoShareProvider; Max, Position: Int64);
  end;

  TShareImagesThread = class(TThreadEx)
  private
    FData: TDBPopupMenuInfoRecord;
    FIsPreview: Boolean;
    FAlbum: IPhotoServiceAlbum;
    FProvider: IPhotoShareProvider;
    FIsAlbumCreated: Boolean;
    procedure ShowError(ErrorText: string);
    procedure CreateAlbum;
    procedure ProcessItem(Data: TDBPopupMenuInfoRecord);
    procedure ProcessImage(Data: TDBPopupMenuInfoRecord);
    procedure ProcessVideo(Data: TDBPopupMenuInfoRecord);
    procedure NotifyProgress(Data: TDBPopupMenuInfoRecord; Max, Position: Int64);
  protected
    procedure Execute; override;
    function GetThreadID: string; override;
  public
    constructor Create(AOwnerForm: TThreadForm; Provider: IPhotoShareProvider; IsPreview: Boolean);
    destructor Destroy; override;
  end;

implementation

uses
  uFormSharePhotos,
  UnitJPEGOptions;

{ TShareImagesThread }

constructor TShareImagesThread.Create(AOwnerForm: TThreadForm; Provider: IPhotoShareProvider; IsPreview: Boolean);
begin
  inherited Create(AOwnerForm, AOwnerForm.StateID);
  FIsPreview := IsPreview;
  FProvider := Provider;
  FData := nil;
  FAlbum := nil;
  FIsAlbumCreated := False;
end;

procedure TShareImagesThread.CreateAlbum;
var
  FAlbumID, AlbumName: string;
  AlbumDate: TDateTime;
  FAccess: Integer;
begin
  SynchronizeEx(
    procedure
    begin
      TFormSharePhotos(OwnerForm).GetAlbumInfo(FAlbumID, AlbumName, AlbumDate, FAccess, FAlbum);
    end
  );
  if FAlbumID = '' then
  begin
    if FProvider.CreateAlbum(AlbumName, '', AlbumDate, FAccess, FAlbum) then
    begin
      FAlbumID := FAlbum.AlbumID;
      FIsAlbumCreated := True;
    end else
      ShowError(L('Can''t create album!'));
  end;
end;

destructor TShareImagesThread.Destroy;
begin
  F(FData);
  inherited;
end;

procedure TShareImagesThread.Execute;
var
  ErrorMessage: string;
begin
  FreeOnTerminate := True;
  try
    //for video previews
    CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
    try
      if not FIsPreview then
        SynchronizeEx(
          procedure
          begin
            TFormSharePhotos(OwnerForm).PbMain.Style := pbstMarquee;
            TFormSharePhotos(OwnerForm).PbMain.Show;
          end
        );

      try

        if not FIsPreview then
        begin
          CreateAlbum;
          SynchronizeEx(
            procedure
            begin
              TFormSharePhotos(OwnerForm).PbMain.Style := pbstNormal;
            end
          );
          if FAlbum = nil then
            Exit;
        end;

        repeat
          if IsTerminated or DBTerminating then
            Break;

          SynchronizeEx(
            procedure
            begin
              if FIsPreview then
                TFormSharePhotos(OwnerForm).GetDataForPreview(FData)
              else
                TFormSharePhotos(OwnerForm).GetData(FData);
            end
          );

          if IsTerminated or DBTerminating then
            Break;

          if FData <> nil then
          begin

            if not FIsPreview then
              SynchronizeEx(
                procedure
                begin
                  TFormSharePhotos(OwnerForm).StartProcessing(FData);
                end
              );

            ErrorMessage := '';
            try

              try
                ProcessItem(FData);
              except
                on e: Exception do
                  ErrorMessage := e.Message;
              end;

            finally

              if not FIsPreview then
                SynchronizeEx(
                  procedure
                  begin
                    TFormSharePhotos(OwnerForm).EndProcessing(FData, ErrorMessage);
                  end
                );

            end;
          end;

        until FData = nil;

      finally
        if not FIsPreview then
          SynchronizeEx(
            procedure
            begin
              TFormSharePhotos(OwnerForm).PbMain.Hide;
            end
          );
      end;
    finally
      if not FIsPreview then
        SynchronizeEx(
          procedure
          begin
            TFormSharePhotos(OwnerForm).SharingDone;
          end
        );
      CoUninitialize;
    end;
  except
    on e: Exception do
    begin
      EventLog(e);
      ShowError(e.Message);
    end;
  end;
end;

function TShareImagesThread.GetThreadID: string;
begin
  Result := 'PhotoShare';
end;

procedure TShareImagesThread.NotifyProgress(Data: TDBPopupMenuInfoRecord; Max, Position: Int64);
begin
  SynchronizeEx(
    procedure
    begin
      TFormSharePhotos(OwnerForm).NotifyItemProgress(Data, Max, Position);
    end
  );
end;

procedure TShareImagesThread.ProcessItem(Data: TDBPopupMenuInfoRecord);
begin
  if CanShareVideo(Data.FileName) then
    ProcessVideo(Data)
  else
    ProcessImage(Data);

  if FIsAlbumCreated then
  begin
    SynchronizeEx(
      procedure
      begin
        TFormSharePhotos(OwnerForm).ReloadAlbums;
      end
    );
    FIsAlbumCreated := False;
  end;
end;

procedure TShareImagesThread.ProcessImage(Data: TDBPopupMenuInfoRecord);
var
  Ext, Password, ContentType: string;
  GraphicClass: TGraphicClass;
  Enrypted, UsePreviewForRAW: Boolean;
  Graphic, NewGraphic: TGraphic;
  Original: TBitmap;
  Width, Height, W, H: Integer;
  IsJpegImageFormat,
  ResizeImage: Boolean;
  MS: TMemoryStream;
  PhotoItem: IPhotoServiceItem;
  ExifData: TExifData;
  ItemProgress: IUploadProgress;
begin
  Width := 0;
  Height := 0;
  ResizeImage := Settings.ReadBool('Share', 'ResizeImage', True);
  if ResizeImage then
  begin
    Width := Settings.ReadInteger('Share', 'ImageWidth', 1920);
    Height := Settings.ReadInteger('Share', 'ImageWidth', 1920);
  end;
  if FIsPreview then
  begin
    Width := 32;
    Height := 32;
  end;

  UsePreviewForRAW := Settings.ReadBool('Share', 'RAWPreview', True);
  IsJpegImageFormat := Settings.ReadInteger('Share', 'ImageFormat', 0) = 0;

  Ext := ExtractFileExt(Data.FileName);
  GraphicClass := TFileAssociations.Instance.GetGraphicClass(Ext);

  if GraphicClass = nil then
    Exit;

  Enrypted := not IsDevicePath(Data.FileName) and ValidCryptGraphicFile(Data.FileName);
  if Enrypted then
  begin
    Password := DBKernel.FindPasswordForCryptImageFile(Data.FileName);
    if Password = '' then
      Exit;
  end;

  Graphic := GraphicClass.Create;
  try

    //RAW loads sd preview
    if Graphic is TRAWImage then
      if UsePreviewForRAW or FIsPreview then
        TRAWImage(Graphic).IsPreview := True;

    if Enrypted then
    begin
      F(Graphic);

      Graphic := DeCryptGraphicFile(Data.FileName, Password);
    end else if not IsDevicePath(Data.FileName) then
      Graphic.LoadFromFile(Data.FileName)
    else
      Graphic.LoadFromDevice(Data.FileName);

    W := Graphic.Width;
    H := Graphic.Height;
    ProportionalSize(Width, Height, W, H);

    if (Width > 0) and (Height > 0) then
      JPEGScale(Graphic, W, H);

    Original := TBitmap.Create;
    try
      AssignGraphic(Original, Graphic);
      F(Graphic);

      if (Width > 0) and (Height > 0) then
        Stretch(W, H, sfLanczos3, 0, Original);

      if FIsPreview then
      begin
        SynchronizeEx(
          procedure
          begin
            TFormSharePhotos(OwnerForm).UpdatePreview(Data, Original);
          end
        );
      end else
      begin
        if IsJpegImageFormat then
          NewGraphic := TJpegImage.Create
        else
          NewGraphic := TPngImage.Create;
        try
          AssignToGraphic(NewGraphic, Original);
          F(Original);

          SetJPEGGraphicSaveOptions('ShareImages', NewGraphic);
          if NewGraphic is TJPEGImage then
            FreeJpegBitmap(TJPEGImage(NewGraphic));

          MS := TMemoryStream.Create;
          try
            NewGraphic.SaveToStream(MS);
            MS.Seek(0, soFromBeginning);

            if IsJpegImageFormat then
              ContentType := 'image/jpeg'
            else
              ContentType := 'image/png';

             ItemProgress := TItemUploadProgress.Create(Self, Data);
             try
               FAlbum.UploadItem(ExtractFileName(Data.FileName), ExtractFileName(Data.FileName),
                 ExtractFileName(Data.FileName), Data.Date, ContentType, MS, ItemProgress, PhotoItem);
             finally
               ItemProgress := nil;
             end;
          finally
            F(MS);
          end;
        finally
          F(NewGraphic);
        end;
      end;

    finally
      F(Original);
    end;
  finally
    F(Graphic);
  end;
end;

procedure TShareImagesThread.ProcessVideo(Data: TDBPopupMenuInfoRecord);
var
  TempBitmap: TBitmap;
  Ico: TIcon;
  FS: TFileStream;
  ContentType: string;
  ItemProgress: IUploadProgress;
  VideoItem: IPhotoServiceItem;
begin
  if FIsPreview then
  begin
    TempBitmap := TBitmap.Create;
    try
      if ExtractVideoThumbnail(Data.FileName, 32, TempBitmap) then
      begin
        SynchronizeEx(
          procedure
          begin
            TFormSharePhotos(OwnerForm).UpdatePreview(Data, TempBitmap);
          end
        );
      end else
      begin
        Ico := TAIcons.Instance.GetIconByExt(Data.FileName, False, 32, False);
        try
          SynchronizeEx(
            procedure
            begin
              TFormSharePhotos(OwnerForm).UpdatePreview(Data, Ico);
            end
          );
        finally
          F(Ico);
        end;
      end;
    finally
      F(TempBitmap);
    end;
  end else
  begin

    ContentType := GetFileContentType(Data.FileName);

    FS := TFileStream.Create(Data.FileName, fmOpenRead or fmShareDenyWrite);
    try
      FS.Seek(0, soFromBeginning);

       ItemProgress := TItemUploadProgress.Create(Self, Data);
       try
         FAlbum.UploadItem(ExtractFileName(Data.FileName), ExtractFileName(Data.FileName),
           ExtractFileName(Data.FileName), Data.Date, ContentType, FS, ItemProgress, VideoItem);
       finally
         ItemProgress := nil;
       end;
    finally
      F(FS);
    end;
  end;
end;

procedure TShareImagesThread.ShowError(ErrorText: string);
begin
  SynchronizeEx(
    procedure
    begin
      MessageBoxDB(Handle, ErrorText, L('Warning'), TD_BUTTON_OK, TD_ICON_ERROR);
    end
  );
end;

{ TItemUploadProgress }

constructor TItemUploadProgress.Create(Thread: TShareImagesThread;
  Item: TDBPopupMenuInfoRecord);
begin
  FThread := Thread;
  FItem := Item;
end;

procedure TItemUploadProgress.OnProgress(Sender: IPhotoShareProvider; Max,
  Position: Int64);
begin
  FThread.NotifyProgress(FItem, Max, Position);
end;

end.
