unit uImportSource;

interface

uses
  Generics.Defaults,
  Generics.Collections,
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Buttons,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Imaging.PngImage,

  Dmitry.Utils.Files,
  Dmitry.Controls.Base,
  Dmitry.Controls.LoadingSign,
  Dmitry.PathProviders,

  UnitDBFileDialogs,

  uConstants,
  uRuntime,
  uMemory,
  uBitmapUtils,
  uGraphicUtils,
  uResources,
  uFormInterfaces,
  uThreadForm,
  uThreadTask,
  uPortableClasses,
  uPortableDeviceManager,
  uVCLHelpers;

type
  TImportType = (itRemovableDevice, itUSB, itHDD, itCD, itDirectory);

  TButtonInfo = class
    Name: string;
    Path: string;
    ImportType: TImportType;
    SortOrder: Integer;
  end;

type
  TFormImportSource = class(TThreadForm, ISelectSourceForm)
    LsLoading: TLoadingSign;
    LbLoadingMessage: TLabel;
    TmrDeviceChanges: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TmrDeviceChangesTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FLoadingCount: Integer;
    FButtons: TList<TSpeedButton>;
    procedure StartLoadingSourceList;
    procedure AddLocation(Name: string; ImportType: TImportType; Path: string; Image: TBitmap);
    procedure LoadLanguage;
    procedure FillDeviceCallBack(Packet: TList<IPDevice>; var Cancel: Boolean; Context: Pointer);
    procedure LoadingThreadFinished;
    procedure ReorderForm;
    procedure SelectSourceClick(Sender: TObject);
    procedure WMDeviceChange(var Msg: TMessage); message WM_DEVICECHANGE;
    procedure PortableEventsCallBack(EventType: TPortableEventType; DeviceID: string; ItemKey: string; ItemPath: string);
  protected
    procedure InterfaceDestroyed; override;
    function GetFormID: string; override;
  public
    { Public declarations }
    procedure Execute;
  end;

implementation

{$R *.dfm}

{$MINENUMSIZE 4}
const
  IOCTL_STORAGE_QUERY_PROPERTY =  $002D1400;

type
  STORAGE_QUERY_TYPE = (PropertyStandardQuery = 0, PropertyExistsQuery, PropertyMaskQuery, PropertyQueryMaxDefined);
  TStorageQueryType = STORAGE_QUERY_TYPE;

  STORAGE_PROPERTY_ID = (StorageDeviceProperty = 0, StorageAdapterProperty);
  TStoragePropertyID = STORAGE_PROPERTY_ID;

  STORAGE_PROPERTY_QUERY = packed record
    PropertyId: STORAGE_PROPERTY_ID;
    QueryType: STORAGE_QUERY_TYPE;
    AdditionalParameters: array [0..9] of AnsiChar;
  end;
  TStoragePropertyQuery = STORAGE_PROPERTY_QUERY;

  STORAGE_BUS_TYPE = (BusTypeUnknown = 0, BusTypeScsi, BusTypeAtapi, BusTypeAta, BusType1394, BusTypeSsa, BusTypeFibre,
    BusTypeUsb, BusTypeRAID, BusTypeiScsi, BusTypeSas, BusTypeSata, BusTypeMaxReserved = $7F);
  TStorageBusType = STORAGE_BUS_TYPE;

  STORAGE_DEVICE_DESCRIPTOR = packed record
    Version: DWORD;
    Size: DWORD;
    DeviceType: Byte;
    DeviceTypeModifier: Byte;
    RemovableMedia: Boolean;
    CommandQueueing: Boolean;
    VendorIdOffset: DWORD;
    ProductIdOffset: DWORD;
    ProductRevisionOffset: DWORD;
    SerialNumberOffset: DWORD;
    BusType: STORAGE_BUS_TYPE;
    RawPropertiesLength: DWORD;
    RawDeviceProperties: array [0..0] of AnsiChar;
  end;
  TStorageDeviceDescriptor = STORAGE_DEVICE_DESCRIPTOR;

function GetBusType(Drive: AnsiChar): TStorageBusType;
var
  H: THandle;
  Query: TStoragePropertyQuery;
  dwBytesReturned: DWORD;
  Buffer: array [0..1023] of Byte;
  sdd: TStorageDeviceDescriptor absolute Buffer;
  OldMode: UINT;
begin
  Result := BusTypeUnknown;

  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    H := CreateFile(PChar(Format('\\.\%s:', [AnsiLowerCase(string(Drive))])), 0, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
    if H <> INVALID_HANDLE_VALUE then
    begin
      try
        dwBytesReturned := 0;
        FillChar(Query, SizeOf(Query), 0);
        FillChar(Buffer, SizeOf(Buffer), 0);
        sdd.Size := SizeOf(Buffer);
        Query.PropertyId := StorageDeviceProperty;
        Query.QueryType := PropertyStandardQuery;
        if DeviceIoControl(H, IOCTL_STORAGE_QUERY_PROPERTY, @Query, SizeOf(Query), @Buffer, SizeOf(Buffer), dwBytesReturned, nil) then
          Result := sdd.BusType;
      finally
        CloseHandle(H);
      end;
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

{procedure GetUsbDrives(List: TStrings);
var
  DriveBits: set of 0..25;
  I: Integer;
  Drive: AnsiChar;
begin
  List.BeginUpdate;
  try
    Cardinal(DriveBits) := GetLogicalDrives;

    for I := 0 to 25 do
      if I in DriveBits then
      begin
        Drive := AnsiChar(Ord('a') + I);
        if GetBusType(Drive) = BusTypeUsb then
          List.Add(string(Drive));
      end;
  finally
    List.EndUpdate;
  end;
end;  }

function CheckDriveItems(Path: string): Boolean;
var
  OldMode: Cardinal;
  Found: Integer;
  SearchRec: TSearchRec;
  Directories: TQueue<string>;
  Dir: string;
begin
  Result := False;
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Directories := TQueue<string>.Create;
    try
      Directories.Enqueue(Path);

      while Directories.Count > 0 do
      begin
        Dir := Directories.Dequeue;

        Dir := IncludeTrailingBackslash(Dir);
        Found := FindFirst(Dir + '*.*', faDirectory, SearchRec);
        try
          while Found = 0 do
          begin
            if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and (faDirectory and SearchRec.Attr = 0) then
              Exit(True);

            if faDirectory and SearchRec.Attr <> 0 then
              Directories.Enqueue(Dir + SearchRec.Name );

            Found := System.SysUtils.FindNext(SearchRec);
          end;
        finally
          FindClose(SearchRec);
        end;
      end;

    finally
      F(Directories);
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

function CheckDeviceItems(Device: IPDevice): Boolean;
var
  Directories: TQueue<TPathItem>;
  PI, Dir: TPathItem;
  Childs: TPathItemCollection;
  Res: Boolean;
begin
  Res := False;
  Directories := TQueue<TPathItem>.Create;
  try
    PI := PathProviderManager.CreatePathItem(cDevicesPath + '\' + Device.Name);

    Directories.Enqueue(PI);

    while Directories.Count > 0 do
    begin
      if Res then
        Break;
      Dir := Directories.Dequeue;
      try
        Childs := TPathItemCollection.Create;
        try
          Dir.Provider.FillChildList(nil, Dir, Childs, PATH_LOAD_NO_IMAGE or PATH_LOAD_FAST, 0, 10,
            procedure(Sender: TObject; Item: TPathItem; CurrentItems: TPathItemCollection; var Break: Boolean)
            var
              I: Integer;
            begin
              for I := 0 to CurrentItems.Count - 1 do
              begin
                if not CurrentItems[I].IsDirectory then
                begin
                  Res := True;
                  Break := True;
                end else
                  Directories.Enqueue(CurrentItems[I].Copy);
              end;
              CurrentItems.FreeItems;
            end
          );
        finally
          Childs.FreeItems;
          F(Childs);
        end;
      finally
        F(Dir);
      end;
    end;

    while Directories.Count > 0 do
      Directories.Dequeue.Free;

  finally
    F(Directories);
  end;
  Result := Res;
end;

{ TFormImportSource }

procedure TFormImportSource.AddLocation(Name: string; ImportType: TImportType; Path: string; Image: TBitmap);
var
  Button: TSpeedButton;
  BI: TButtonInfo;

  procedure UpdateGlyph(Button: TSpeedButton);
  var
    Png: TPngImage;
    B: TBitmap;
    Image: string;
    Font: TFont;
  begin
    case ImportType of
      itCD:
        Image := 'IMPORT_CD';
      itRemovableDevice:
        Image := 'IMPORT_CAMERA';
      itUSB:
        Image := 'IMPORT_USB';
      itHDD:
        Image := 'IMPORT_HDD';
      else
        Image := 'IMPORT_DIRECTORY';
    end;
    Png := TResourceUtils.LoadGraphicFromRES<TPngImage>(Image);
    try
      B := TBitmap.Create;
      try
        AssignGraphic(B, Png);

        Font := TFont.Create;
        try
          Font.Assign(Self.Font);
          Font.Color := Theme.WindowTextColor;
          Font.Style := [fsBold];
          Font.Size := 12;
          B.Height := B.Height + 4 - Font.Height;

          FillTransparentColor(B, Theme.WindowTextColor, 0, B.Height - 4 + Font.Height, B.Width, 4 - Font.Height, 0);

          DrawText32Bit(B, Name, Font, Rect(0, B.Height - 4 + Font.Height, B.Width, B.Height), DT_CENTER or DT_END_ELLIPSIS);

          Button.Glyph := B;
        finally
          F(Font);
        end;
      finally
        F(B);
      end;
    finally
      F(Png);
    end;
  end;

begin
  if Visible then
    BeginScreenUpdate(Handle);
  try
    Button := TSpeedButton.Create(Self);
    Button.Parent := Self;
    Button.Width := 130;
    Button.Height := 130 + 20;
    Button.Top := 5;
    Button.OnClick := SelectSourceClick;

    BI := TButtonInfo.Create;
    BI.Name := Name;
    BI.Path := Path;
    BI.ImportType := ImportType;
    BI.SortOrder := 1000 * Integer(ImportType);
    if (Path.Length > 1) and (Path[2] = ':') then
      BI.SortOrder := BI.SortOrder + Byte(AnsiChar(Path[2]));
    Button.Tag := NativeInt(BI);

    if Image = nil then
      UpdateGlyph(Button)
    else
      Button.Glyph := Image;

    FButtons.Add(Button);

    ReorderForm;
  finally
    if Visible then
      EndScreenUpdate(Handle, True);
  end;
end;

procedure TFormImportSource.Execute;
begin
  StartLoadingSourceList;
  ShowModal;
end;

procedure TFormImportSource.FillDeviceCallBack(Packet: TList<IPDevice>;
  var Cancel: Boolean; Context: Pointer);
var
  I: Integer;
  Thread: TThreadTask;
begin
  Thread := TThreadTask(Context);

  for I := 0 to Packet.Count - 1 do
    if CheckDeviceItems(Packet[I]) then
      Cancel := not Thread.SynchronizeTask(
        procedure
        begin
          TFormImportSource(Thread.ThreadForm).AddLocation(Packet[I].Name, itRemovableDevice, cDevicesPath + '\' + Packet[I].Name, nil);
        end
      );
end;

procedure TFormImportSource.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TFormImportSource.FormCreate(Sender: TObject);
begin
  FLoadingCount := 0;
  FButtons := TList<TSpeedButton>.Create;
  LoadLanguage;

  GetDeviceEventManager.RegisterNotification([peDeviceConnected, peDeviceDisconnected], PortableEventsCallBack);
end;

procedure TFormImportSource.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  GetDeviceEventManager.UnRegisterNotification(PortableEventsCallBack);

  for I := 0 to FButtons.Count - 1 do
    TObject(FButtons[I].Tag).Free;

  F(FButtons);
end;

procedure TFormImportSource.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

function TFormImportSource.GetFormID: string;
begin
  Result := 'ImportSource';
end;

procedure TFormImportSource.InterfaceDestroyed;
begin
  inherited;
  Release;
end;

procedure TFormImportSource.LoadingThreadFinished;
begin
  Dec(FLoadingCount);
  if FLoadingCount = 0 then
    ReorderForm;
end;

procedure TFormImportSource.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Import photos and video');
    LbLoadingMessage.Caption := L('Please wait until program searches for sources with images');
  finally
    EndTranslate;
  end;
end;

procedure TFormImportSource.PortableEventsCallBack(
  EventType: TPortableEventType; DeviceID, ItemKey, ItemPath: string);
begin
  case EventType of
    peDeviceConnected,
    peDeviceDisconnected:
      TmrDeviceChanges.Restart;
  end;
end;

procedure TFormImportSource.ReorderForm;
var
  I,
  CW,
  LoadingWidth: Integer;
begin
  FButtons.Sort(TComparer<TSpeedButton>.Construct(
     function (const L, R: TSpeedButton): Integer
     begin
       Result := TButtonInfo(L.Tag).SortOrder - TButtonInfo(R.Tag).SortOrder;
     end
  ));

  for I := 0 to FButtons.Count - 1 do
    FButtons[I].Left := 5 + FButtons.IndexOf(FButtons[I]) * (130 + 5);

  CW := 5 + FButtons.Count * (130 + 5);

  LockWindowUpdate(Handle);
  try
    if FLoadingCount > 0 then
    begin
      LoadingWidth := 100;
      Inc(CW, LoadingWidth);
      LbLoadingMessage.Left := CW - LoadingWidth + LoadingWidth div 2 - LbLoadingMessage.Width div 2;
      LsLoading.Left := CW - LoadingWidth + LoadingWidth div 2 - LsLoading.Width div 2;
    end else
    begin
      LbLoadingMessage.Hide;
      LsLoading.Hide;
    end;

    ClientWidth := CW;
    Left := Monitor.Left + Monitor.Width div 2 - Width div 2;
  finally
    LockWindowUpdate(0);
  end;
end;

procedure TFormImportSource.SelectSourceClick(Sender: TObject);
var
  BI:  TButtonInfo;
  Path: string;
begin
  BI := TButtonInfo(TControl(Sender).Tag);

  if BI.ImportType = itDirectory then
  begin
    Path := UnitDBFileDialogs.DBSelectDir(Application.Handle, Caption, UseSimpleSelectFolderDialog);
    if Path = '' then
      Exit;

    ImportForm.FromFolder(Path);
    Close;
    Exit;
  end;

  ImportForm.FromFolder(BI.Path);
  Close;
end;

procedure TFormImportSource.StartLoadingSourceList;
begin
  LbLoadingMessage.Show;
  LsLoading.Show;

  //load CDs
  Inc(FLoadingCount);
  TThreadTask.Create(Self, Pointer(nil),
    procedure(Thread: TThreadTask; Data: Pointer)
    var
      I: Integer;
      OldMode: Cardinal;
      VolumeName: string;
    begin
      OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
      try
        for I := Ord('A') to Ord('Z') do
          if (GetDriveType(PChar(Chr(I) + ':\')) = DRIVE_CDROM) and CheckDriveItems(Chr(I) + ':\') then
          begin
            VolumeName := GetDriveVolumeLabel(AnsiChar(I));
            if not Thread.SynchronizeTask(
              procedure
              begin
                TFormImportSource(Thread.ThreadForm).AddLocation(VolumeName, itCD, Chr(I) + ':\', nil);
              end
            ) then Break;
          end;
      finally
        SetErrorMode(OldMode);
        Thread.SynchronizeTask(
          procedure
          begin
            TFormImportSource(Thread.ThreadForm).LoadingThreadFinished;
          end
        );
      end;
    end
  );

  //load HDDs by USB
  Inc(FLoadingCount);
  TThreadTask.Create(Self, Pointer(nil),
    procedure(Thread: TThreadTask; Data: Pointer)
    var
      I: Integer;
      OldMode: Cardinal;
      VolumeName: string;
    begin
      OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
      try
        for I := Ord('A') to Ord('Z') do
          if (GetDriveType(PChar(Chr(I) + ':\')) = DRIVE_FIXED) and (GetBusType(AnsiChar(I)) = BusTypeUsb) and CheckDriveItems(Chr(I) + ':\') then
          begin
            VolumeName := GetDriveVolumeLabel(AnsiChar(I));
            if not Thread.SynchronizeTask(
              procedure
              begin
                TFormImportSource(Thread.ThreadForm).AddLocation(VolumeName, itHDD, Chr(I) + ':\', nil);
              end
            ) then Break;
          end;
      finally
        SetErrorMode(OldMode);
        Thread.SynchronizeTask(
          procedure
          begin
            TFormImportSource(Thread.ThreadForm).LoadingThreadFinished;
          end
        );
      end;
    end
  );

  //load Flash cards
  Inc(FLoadingCount);
  TThreadTask.Create(Self, Pointer(nil),
    procedure(Thread: TThreadTask; Data: Pointer)
    var
      I: Integer;
      OldMode: Cardinal;
      VolumeName: string;
    begin
      OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
      try
        for I := Ord('A') to Ord('Z') do
          if (GetDriveType(PChar(Chr(I) + ':\')) = DRIVE_REMOVABLE) and CheckDriveItems(Chr(I) + ':\') then
          begin
            VolumeName := GetDriveVolumeLabel(AnsiChar(I));
            if not Thread.SynchronizeTask(
              procedure
              begin
                TFormImportSource(Thread.ThreadForm).AddLocation(VolumeName, itUSB, Chr(I) + ':\', nil);
              end
            ) then Break;
          end;
      finally
        SetErrorMode(OldMode);
        Thread.SynchronizeTask(
          procedure
          begin
            TFormImportSource(Thread.ThreadForm).LoadingThreadFinished;
          end
        );
      end;
    end
  );

  //load Devices
  Inc(FLoadingCount);
  TThreadTask.Create(Self, Pointer(nil),
    procedure(Thread: TThreadTask; Data: Pointer)
    var
      Manager: IPManager;
    begin
      Manager := CreateDeviceManagerInstance;
      try
        Manager.FillDevicesWithCallBack(FillDeviceCallBack, Thread);
      finally
        Manager := nil;
        Thread.SynchronizeTask(
          procedure
          begin
            TFormImportSource(Thread.ThreadForm).LoadingThreadFinished;
          end
        );
      end;
    end
  );

  AddLocation(L('Select a folder'), itDirectory, '', nil);
end;

procedure TFormImportSource.TmrDeviceChangesTimer(Sender: TObject);
var
  I: Integer;
begin
  TmrDeviceChanges.Enabled := False;

  BeginScreenUpdate(Handle);
  try
    //Refresh buttons
    for I := 0 to FButtons.Count - 1 do
      TObject(FButtons[I].Tag).Free;
    for I := 0 to FButtons.Count - 1 do
      FButtons[I].Free;

    FButtons.Clear;
    StartLoadingSourceList;
  finally
    EndScreenUpdate(Handle, False);
  end;
end;

procedure TFormImportSource.WMDeviceChange(var Msg: TMessage);
begin
  TmrDeviceChanges.Restart;
end;

initialization
  FormInterfaces.RegisterFormInterface(ISelectSourceForm, TFormImportSource);

end.
