unit uShareUtils;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Imaging.Jpeg,
  Vcl.Imaging.pngimage,

  UnitDBDeclare,

  uMemory,
  uGraphicUtils,
  uJpegUtils,
  uAssociatedIcons,
  uImageLoader,
  uDBRepository,
  uSettings;

type
  TShareLinkData = record
    Url: string;
    Tag: string;
  end;

type
  TUpdatePreviewProc = reference to procedure(Data: TMediaItem; Preview: TGraphic);
  TUpdateStreamProc = reference to procedure(Data: TMediaItem; S: TStream; ContentType: string);

procedure ProcessImageForSharing(Data: TMediaItem; IsPreview: Boolean;
  UpdatePreviewProc: TUpdatePreviewProc;
  UpdateStreamProc: TUpdateStreamProc);
function GetShareLinkForDBItem(Data: TMediaItem): TShareLinkData;
procedure UpdateDBItemLink(Data: TMediaItem; LinkData: TShareLinkData);

implementation

procedure ProcessImageForSharing(Data: TMediaItem; IsPreview: Boolean;
  UpdatePreviewProc: TUpdatePreviewProc;
  UpdateStreamProc: TUpdateStreamProc);
var
  ContentType: string;
  UsePreviewForRAW: Boolean;
  NewGraphic: TGraphic;
  Original: TBitmap;
  Width, Height: Integer;
  IsJpegImageFormat,
  ResizeImage: Boolean;
  MS: TMemoryStream;
  Ico: TIcon;

  Flags: TImageLoadFlags;
  ImageInfo: ILoadImageInfo;
begin
  try
    Width := 0;
    Height := 0;
    ResizeImage := AppSettings.ReadBool('Share', 'ResizeImage', True);
    if ResizeImage then
    begin
      Width := AppSettings.ReadInteger('Share', 'ImageWidth', 1920);
      Height := AppSettings.ReadInteger('Share', 'ImageWidth', 1920);
    end;
    if IsPreview then
    begin
      Width := 32;
      Height := 32;
    end;

    UsePreviewForRAW := AppSettings.ReadBool('Share', 'RAWPreview', True);
    IsJpegImageFormat := AppSettings.ReadInteger('Share', 'ImageFormat', 0) = 0;

    Flags := [ilfGraphic, ilfICCProfile, ilfEXIF, ilfPassword, ilfAskUserPassword, ilfThrowError];
    if not (UsePreviewForRAW or IsPreview) then
      Flags := Flags + [ilfFullRAW];

    if LoadImageFromPath(Data, -1, '', Flags, ImageInfo, Width, Height) then
    begin
      Original := ImageInfo.GenerateBitmap(Data, Width, Height, pf24Bit, clWhite,
        [ilboFreeGraphic, ilboRotate, ilboApplyICCProfile, ilboQualityResize]);
      try
        if Original <> nil then
        begin
          if IsPreview then
          begin
            UpdatePreviewProc(Data, Original);
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

                if IsJpegImageFormat then
                  ImageInfo.TryUpdateExif(MS, NewGraphic);

                MS.Seek(0, soFromBeginning);

                if IsJpegImageFormat then
                  ContentType := 'image/jpeg'
                else
                  ContentType := 'image/png';

                 UpdateStreamProc(Data, MS, ContentType);
              finally
                F(MS);
              end;
            finally
              F(NewGraphic);
            end;
          end;

        end;
      finally
        F(Original);
      end;
    end;
  except
    on e: Exception do
    begin
      Ico := TAIcons.Instance.GetIconByExt(Data.FileName, False, 32, False);
      try
        UpdatePreviewProc(Data, Ico);
      finally
        F(Ico);
      end;
      raise;
    end;
  end;
end;

function GetShareLinkForDBItem(Data: TMediaItem): TShareLinkData;
var
  DBItem: TDBItem;
  DBItemRepository: TDBitemRepository;
  DBGroupsRepository: TDBGroupsRepository;
begin
  DBItem := DBItemRepository.WithKey().Add(DBItemFields.Links).Table()
    .Join<TDBGroupItem>(DBGroupsRepository.AllFields.Table()).Onn(DBGroupFields.GroupId).Eq(DBItemFields.GroupId)
    .SelectItem()
    .ById(Data.Id)
    .OrderByDesc(DBItemFields.Links)
    .FirstOrDefault();

  DBItem := DBItemRepository.WithKey().Add(DBItemFields.Links).Table()
    .SelectItem()
    .ById(Data.ID)
    .FirstOrDefault();

  //DBItem := DBItemRepository.TextFields.Select().ById(Data.ID);
  //DBItem := DBItemRepository.AllFields.Select().ById(Data.ID);

  //if DBItem <> nil then
  //  Result.Url := DBItem.Links;
end;

procedure UpdateDBItemLink(Data: TMediaItem; LinkData: TShareLinkData);
begin

end;

end.
