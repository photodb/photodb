unit uImportScanThread;

interface

uses
  Generics.Collections,
  System.Classes,
  Winapi.ActiveX,
  System.SysUtils,
  System.DateUtils,

  Dmitry.PathProviders,
  Dmitry.PathProviders.FileSystem,

  CCR.Exif,

  RAWImage,

  uThreadForm,
  uMemory,
  uExplorerPortableDeviceProvider,
  uAssociations,
  uImportPicturesUtils,
  uLogger,
  uThreadEx;

type
  TImportScanThread = class(TThreadEx)
  private
    { Private declarations }
    FOnlySupportedImages: Boolean;
    FDirectory: TPathItem;
    FNextLevel: TList<TPathItem>;
    procedure LoadCallBack(Sender: TObject; Item: TPathItem; CurrentItems: TPathItemCollection; var Break: Boolean);
  protected
    procedure Execute; override;
  public
    constructor Create(OwnerForm: TThreadForm; Directory: TPathItem; OnlySupportedImages: Boolean);
    destructor Destroy; override;
  end;

implementation

uses
  uFormImportImages;

{ TImportScanThread }

constructor TImportScanThread.Create(OwnerForm: TThreadForm; Directory: TPathItem; OnlySupportedImages: Boolean);
begin
  FDirectory := Directory.Copy;
  FOnlySupportedImages := OnlySupportedImages;
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
  try
    CoInitializeEx(nil, COINIT_MULTITHREADED);
    try

      LevelItems := TList<TPathItem>.Create;
      FNextLevel := TList<TPathItem>.Create;
      try
        SynchronizeEx(procedure
        begin
          TFormImportImages(OwnerForm).ShowLoadingSign;
        end
        );

        FNextLevel.Add(FDirectory.Copy);
        try
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
                Childs.FreeItems;
                F(Childs);
              end;
            end;
          end;
        finally
          SynchronizeEx(procedure
          begin
            TFormImportImages(OwnerForm).FinishScan;
          end
          );
        end;
      finally
        FreeList(LevelItems);
        FreeList(FNextLevel);
      end;
    finally
      CoUninitialize;
    end;
  except
    on e: Exception do
      EventLog(e);
  end;
end;

procedure TImportScanThread.LoadCallBack(Sender: TObject; Item: TPathItem;
  CurrentItems: TPathItemCollection; var Break: Boolean);
var
  I: Integer;
  FileSize: Int64;
  PI: TPathItem;
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
      if PI.IsDirectory then
        FNextLevel.Add(PI.Copy)
      else
      begin
        if IsGraphicFile(PI.Path) or not FOnlySupportedImages then
        begin
          Date := GetImageDate(PI);
          if PI is TPortableFSItem then
            FileSize := TPortableImageItem(PI).FileSize
          else if PI is TFileItem then
            FileSize := PI.FileSize;

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
