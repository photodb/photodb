unit uImportScanThread;

interface

uses
  Generics.Collections,
  System.Classes,
  uPathProviders,
  uMemory,
  SysUtils,
  CCR.Exif,
  RAWImage,
  DateUtils,
  uThreadForm,
  uExplorerFSProviders,
  uExplorerPortableDeviceProvider,
  uAssociations,
  uThreadEx;

type
  TImportScanThread = class(TThreadEx)
  private
    { Private declarations }
    FDirectory: TPathItem;
    FNextLevel: TList<TPathItem>;
    procedure LoadCallBack(Sender: TObject; Item: TPathItem; CurrentItems: TPathItemCollection; var Break: Boolean);
  protected
    procedure Execute; override;
  public
    constructor Create(OwnerForm: TThreadForm; Directory: TPathItem);
    destructor Destroy; override;
  end;

implementation

uses
  uFormImportImages;

{ TImportScanThread }

constructor TImportScanThread.Create(OwnerForm: TThreadForm; Directory: TPathItem);
begin
  FDirectory := Directory.Copy;
  inherited Create(OwnerForm, OwnerForm.StateID);
end;

destructor TImportScanThread.Destroy;
begin
  F(FDirectory);
  inherited;
end;

procedure TImportScanThread.Execute;
var
  I: Integer;
  LevelItems: TList<TPathItem>;
  Childs: TPathItemCollection;
begin
  FreeOnTerminate := True;

  LevelItems := TList<TPathItem>.Create;
  FNextLevel := TList<TPathItem>.Create;
  try

    FNextLevel.Add(FDirectory.Copy);

    while FNextLevel.Count > 0 do
    begin
      FreeList(LevelItems, False);
      LevelItems.AddRange(FNextLevel);
      FNextLevel.Clear;

      for I := 0 to LevelItems.Count - 1 do
      begin
        Childs := TPathItemCollection.Create;
        try
          LevelItems[I].Provider.FillChildList(Self, LevelItems[I], Childs, PATH_LOAD_NO_IMAGE or PATH_LOAD_FAST, 0, 10, LoadCallBack);
        finally
          F(Childs);
        end;
      end;
    end;
  finally
    FreeList(LevelItems);
    FreeList(FNextLevel);
  end;
end;

procedure TImportScanThread.LoadCallBack(Sender: TObject; Item: TPathItem;
  CurrentItems: TPathItemCollection; var Break: Boolean);
var
  I: Integer;
  FileSize: Integer;
  PI: TPathItem;
  ExifData: TExifData;
  RAWExif: TRAWExif;
  Date: TDateTime;
  Packet: TList<TScanItem>;
begin
  Packet := TList<TScanItem>.Create;
  try

    for I := 0 to CurrentItems.Count - 1 do
    begin
      FileSize := 0;
      Date := MinDateTime;

      PI := CurrentItems[I];
      if PI.IsDirectoty then
        FNextLevel.Add(PI.Copy)
      else
      begin
        if PI is TPortableFSItem and not PI.IsDirectoty then
        begin
          FileSize := TPortableImageItem(PI).FileSize;
          Date := TPortableImageItem(PI).Date;
        end else if PI is TFileItem then
        begin
          FileSize := PI.FileSize;
          Date := TFileItem(PI).TimeStamp;
          if IsGraphicFile(PI.Path) then
          begin
            if IsRAWImageFile(PI.Path) then
            begin
              RAWExif := ReadRAWExif(PI.Path);
              try
                if RAWExif.IsEXIF then
                begin
                  Date := DateOf(RAWExif.TimeStamp);
                  FileSize := PI.FileSize;
                end;
              finally
                F(RAWExif);
              end;
            end else
            begin
              ExifData := TExifData.Create;
              try
                ExifData.LoadFromGraphic(PI.Path);
                if not ExifData.Empty and (ExifData.DateTimeOriginal > 0) and (YearOf(ExifData.DateTimeOriginal) > 1900) then
                begin
                  Date := DateOf(ExifData.DateTimeOriginal);
                  FileSize := PI.FileSize;
                end;
              finally
                F(ExifData);
              end;
            end;
          end;
        end;

        if FileSize > 0 then
          Packet.Add(TScanItem.Create(PI, Date, FileSize));
      end;
    end;

    SynchronizeEx(
      procedure
      begin
        TFormImportImages(OwnerForm).AddItems(Packet);
      end
    );

  finally
    FreeList(Packet);
  end;

  CurrentItems.FreeItems;
  //
  Break := IsTerminated;
end;

end.
