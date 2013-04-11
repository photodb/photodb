unit uShareImagesThread;

interface

uses
  Winapi.Windows,
  Winapi.ActiveX,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Imaging.Jpeg,
  Vcl.Imaging.pngImage,
  Vcl.ComCtrls,

  Dmitry.Utils.System,

  CCR.Exif,

  UnitDBDeclare,
  RAWImage,

  uConstants,
  uRuntime,
  uMemory,
  uLogger,
  uThreadEx,
  uThreadForm,
  uAssociations,
  uShellThumbnails,
  uAssociatedIcons,
  uPhotoShareInterfaces,
  uShellIntegration,
  uShareUtils,
  uImageLoader,
  uDBEntities;

type
  TShareImagesThread = class;

  TItemUploadProgress = class(TInterfacedObject, IUploadProgress)
  private
    FThread: TShareImagesThread;
    FItem: TMediaItem;
  public
    constructor Create(Thread: TShareImagesThread; Item: TMediaItem);
    procedure OnProgress(Sender: IPhotoShareProvider; Max, Position: Int64);
  end;

  TShareImagesThread = class(TThreadEx)
  private
    FData: TMediaItem;
    FIsPreview: Boolean;
    FAlbum: IPhotoServiceAlbum;
    FProvider: IPhotoShareProvider;
    FIsAlbumCreated: Boolean;
    procedure ShowError(ErrorText: string);
    procedure CreateAlbum;
    procedure ProcessItem(Data: TMediaItem);
    procedure ProcessImage(Data: TMediaItem);
    procedure ProcessVideo(Data: TMediaItem);
    procedure NotifyProgress(Data: TMediaItem; Max, Position: Int64);
  protected
    procedure Execute; override;
    function GetThreadID: string; override;
  public
    constructor Create(AOwnerForm: TThreadForm; Provider: IPhotoShareProvider; IsPreview: Boolean);
    destructor Destroy; override;
  end;

implementation

uses
  uFormSharePhotos;

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

              if not FIsPreview or (ErrorMessage <> '') then
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

procedure TShareImagesThread.NotifyProgress(Data: TMediaItem; Max, Position: Int64);
begin
  SynchronizeEx(
    procedure
    begin
      TFormSharePhotos(OwnerForm).NotifyItemProgress(Data, Max, Position);
    end
  );
end;

procedure TShareImagesThread.ProcessItem(Data: TMediaItem);
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
        TFormSharePhotos(OwnerForm).HideAlbumCreation;
        TFormSharePhotos(OwnerForm).ReloadAlbums;
      end
    );
    FIsAlbumCreated := False;
  end;
end;

procedure TShareImagesThread.ProcessImage(Data: TMediaItem);
var
  PhotoItem: IPhotoServiceItem;
  ItemProgress: IUploadProgress;
begin
  ProcessImageForSharing(Data, FIsPreview,
    procedure(Data: TMediaItem; Preview: TGraphic)
    begin
      SynchronizeEx(
        procedure
        begin
          TFormSharePhotos(OwnerForm).UpdatePreview(Data, Preview);
        end
      );
    end,
    procedure(Data: TMediaItem; S: TStream; ContentType: string)
    begin
      ItemProgress := TItemUploadProgress.Create(Self, Data);
      try
        FAlbum.UploadItem(ExtractFileName(Data.FileName), ExtractFileName(Data.FileName),
          Data.Comment, Data.Date, ContentType, S, ItemProgress, PhotoItem);
      finally
        ItemProgress := nil;
      end;
    end
  );

end;

procedure TShareImagesThread.ProcessVideo(Data: TMediaItem);
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
    ContentType := GetFileMIMEType(Data.FileName);

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
  Item: TMediaItem);
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
