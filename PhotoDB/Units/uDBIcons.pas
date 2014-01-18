unit uDBIcons;

interface

uses
  System.Generics.Collections,
  System.SyncObjs,
  Winapi.Windows,
  Winapi.CommCtrl,
  Vcl.ImgList,

  Dmitry.Graphics.LayeredBitmap,

  uMemory,
  uVCLHelpers,
  uImageListUtils;

const
  IconsCount = 133;
const
  IconsVersion = '1_5';

type
  TDbKernelArrayIcons = array [1 .. IconsCount] of THandle;

type
  TIconEx = class
  private
    FIcon: TLayeredBitmap;
    FGrayIcon: TLayeredBitmap;
    FIconIndex: Integer;
    function GetGrayIcon: TLayeredBitmap;
  public
    constructor Create(AIconIndex: Integer);
    destructor Destroy; override;
    property IconIndex: Integer read FIconIndex;
    property GrayIcon: TLayeredBitmap read GetGrayIcon;
    property Icon: TLayeredBitmap read FIcon;
  end;

  TDBIcons = class(TObject)
  private
    FIcons: TList<TIconEx>;
    FSync: TCriticalSection;
    FImageList: TCustomImageList;
    FDisabledImageList: TCustomImageList;
    FHIcons: TDbKernelArrayIcons;
    function GetIconByIndex(Index: Integer): HIcon;
    function IconsExByIndex(Index: Integer): TIconEx;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadIcons;
    property ImageList: TCustomImageList read FImageList;
    property DisabledImageList: TCustomImageList read FDisabledImageList;
    property Icons[Index: Integer]: HIcon read GetIconByIndex; default;
    property IconsEx[index: Integer]: TIconEx read IconsExByIndex;
  end;

function Icons: TDBIcons;

implementation

var
  FIcons: TDBIcons = nil;

function Icons: TDBIcons;
begin
  if FIcons = nil then
    FIcons := TDBIcons.Create;

  Result := FIcons;
end;

{ TIconEx }

constructor TIconEx.Create(AIconIndex: Integer);
begin
  FIconIndex := AIconIndex;
  FGrayIcon := nil;
  FIcon := TLayeredBitmap.Create;
  FIcon.LoadFromHIcon(Icons[AIconIndex]);
end;

destructor TIconEx.Destroy;
begin
  F(FIcon);
  F(FGrayIcon);
  inherited;
end;

function TIconEx.GetGrayIcon: TLayeredBitmap;
begin
  if FGrayIcon = nil then
  begin
    FGrayIcon := TLayeredBitmap.Create;
    FGrayIcon.Load(FIcon);
    FGrayIcon.GrayScale;
  end;
  Result := FGrayIcon;
end;

{ TDBIcons }

constructor TDBIcons.Create;
var
  I: Integer;
begin
  FImageList := nil;
  FDisabledImageList := nil;

  FSync := TCriticalSection.Create;
  FIcons := TList<TIconEx>.Create;

  for I := 1 to IconsCount do
    FHIcons[I] := 0;
end;

destructor TDBIcons.Destroy;
var
  I: Integer;
begin
  for I := 1 to IconsCount do
    DestroyIcon(FHIcons[I]);

  F(FSync);
  FreeList(FIcons);
  F(FImageList);
  F(FDisabledImageList);
  inherited;
end;

function TDBIcons.GetIconByIndex(Index: Integer): HIcon;
begin
   if FHIcons[Index + 1] <> 0 then
    Exit(FHIcons[Index + 1]);

  FHIcons[Index + 1] := ImageList_GetIcon(FImageList.Handle, Index, 0);
  Result := FHIcons[Index + 1];
end;

function TDBIcons.IconsExByIndex(Index: Integer): TIconEx;
var
  I: Integer;
  Item: TIconEx;
begin
  FSync.Enter;
  try
    for I := 0 to FIcons.Count - 1 do
    begin
      Item := FIcons[I];
      if Item.IconIndex = Index then
      begin
        Result := Item;
        Exit;
      end;
    end;
    Item := TIconEx.Create(Index);
    FIcons.Add(Item);
    Result := Item;
  finally
    FSync.Leave;
  end;
end;

procedure TDBIcons.LoadIcons;
var
  I: Integer;
  Icons: TDbKernelArrayIcons;
  LB: TLayeredBitmap;

  function LoadIcon(Instance: HINST; ResName: string): HIcon;
  begin
    Result := LoadImage(Instance, PWideChar(ResName), IMAGE_ICON, 16, 16, 0);
  end;

begin
  FImageList := TSIImageList.Create(nil);
  FImageList.Width := 16;
  FImageList.Height := 16;
  FImageList.ColorDepth := cd32Bit;

  FDisabledImageList := TSIImageList.Create(nil);
  FDisabledImageList.Width := 16;
  FDisabledImageList.Height := 16;
  FDisabledImageList.ColorDepth := cd32Bit;

  if not FImageList.LoadFromCache('Images' + IconsVersion) or not FDisabledImageList.LoadFromCache('ImGray' + IconsVersion) then
  begin
    Icons[1] := LoadIcon(HInstance,'SHELL');
    Icons[2] := LoadIcon(HInstance,'SLIDE_SHOW');
    Icons[3] := LoadIcon(HInstance,'REFRESH_THUM');
    Icons[4] := LoadIcon(HInstance,'RATING_STAR');
    Icons[5] := LoadIcon(HInstance,'DELETE_INFO');
    Icons[6] := LoadIcon(HInstance,'DELETE_FILE');
    Icons[7] := LoadIcon(HInstance,'COPY_ITEM');
    Icons[8] := LoadIcon(HInstance,'PROPERTIES');
    Icons[9] := LoadIcon(HInstance,'PRIVATE');
    Icons[10] := LoadIcon(HInstance,'COMMON');
    Icons[11] := LoadIcon(HInstance,'SEARCH');
    Icons[12] := LoadIcon(HInstance,'EXIT');
    Icons[13] := LoadIcon(HInstance,'FAVORITE');
    Icons[14] := LoadIcon(HInstance,'DESKTOP');
    Icons[15] := LoadIcon(HInstance,'RELOAD');
    Icons[16] := LoadIcon(HInstance,'NOTES');
    Icons[17] := LoadIcon(HInstance,'NOTEPAD');
    Icons[18] := LoadIcon(HInstance,'TRATING_1');
    Icons[19] := LoadIcon(HInstance,'TRATING_2');
    Icons[20] := LoadIcon(HInstance,'TRATING_3');
    Icons[21] := LoadIcon(HInstance,'TRATING_4');
    Icons[22] := LoadIcon(HInstance,'TRATING_5');
    Icons[23] := LoadIcon(HInstance,'Z_NEXT_NORM'); //NEXT //TODO: delete icon 'NEXT'
    Icons[24] := LoadIcon(HInstance,'Z_PREVIOUS_NORM'); //PREVIOUS //TODO: delete icon 'PREVIOUS'
    Icons[25] := LoadIcon(HInstance,'TH_NEW');
    Icons[26] := LoadIcon(HInstance,'ROTATE_0');
    Icons[27] := LoadIcon(HInstance,'ROTATE_90');
    Icons[28] := LoadIcon(HInstance,'ROTATE_180');
    Icons[29] := LoadIcon(HInstance,'ROTATE_270');
    Icons[30] := LoadIcon(HInstance,'PLAY');
    Icons[31] := LoadIcon(HInstance,'PAUSE');
    Icons[32] := LoadIcon(HInstance,'COPY');
    Icons[33] := LoadIcon(HInstance,'PASTE');
    Icons[34] := LoadIcon(HInstance,'LOADFROMFILE');
    Icons[35] := LoadIcon(HInstance,'SAVETOFILE');
    Icons[36] := LoadIcon(HInstance,'PANEL');
    Icons[37] := LoadIcon(HInstance,'SELECTALL');
    Icons[38] := LoadIcon(HInstance,'OPTIONS');
    Icons[39] := LoadIcon(HInstance,'ADMINTOOLS');
    Icons[40] := LoadIcon(HInstance,'ADDTODB');
    Icons[41] := LoadIcon(HInstance,'HELP');
    Icons[42] := LoadIcon(HInstance,'RENAME');
    Icons[43] := LoadIcon(HInstance,'EXPLORER');
    Icons[44] := LoadIcon(HInstance,'SEND');
    Icons[45] := LoadIcon(HInstance,'SENDTO');
    Icons[46] := LoadIcon(HInstance,'NEW');
    Icons[47] := LoadIcon(HInstance,'NEWDIRECTORY');
    Icons[48] := LoadIcon(HInstance,'SHELLPREVIOUS');
    Icons[49] := LoadIcon(HInstance,'SHELLNEXT');
    Icons[50] := LoadIcon(HInstance,'SHELLUP');
    Icons[51] := LoadIcon(HInstance,'KEY');
    Icons[52] := LoadIcon(HInstance,'FOLDER');
    Icons[53] := LoadIcon(HInstance,'ADDFOLDER');
    Icons[54] := LoadIcon(HInstance,'BOX');
    Icons[55] := LoadIcon(HInstance,'DIRECTORY');
    Icons[56] := LoadIcon(HInstance,'THFOLDER');
    Icons[57] := LoadIcon(HInstance,'CUT');
    Icons[58] := LoadIcon(HInstance,'NEWWINDOW');
    Icons[59] := LoadIcon(HInstance,'ADDSINGLEFILE');
    Icons[60] := LoadIcon(HInstance,'MANYFILES');
    Icons[61] := LoadIcon(HInstance,'MYCOMPUTER');
    Icons[62] := LoadIcon(HInstance,'EXPLORERPANEL');
    Icons[63] := LoadIcon(HInstance,'INFOPANEL');
    Icons[64] := LoadIcon(HInstance,'SAVEASTABLE');
    Icons[65] := LoadIcon(HInstance,'EDITDATE');
    Icons[66] := LoadIcon(HInstance,'GROUPS');
    Icons[67] := LoadIcon(HInstance,'WALLPAPER');
    Icons[68] := LoadIcon(HInstance,'NETWORK');
    Icons[69] := LoadIcon(HInstance,'WORKGROUP');
    Icons[70] := LoadIcon(HInstance,'COMPUTER');
    Icons[71] := LoadIcon(HInstance,'SHARE');
    Icons[72] := LoadIcon(HInstance,'Z_ZOOMIN_NORM');
    Icons[73] := LoadIcon(HInstance,'Z_ZOOMOUT_NORM');
    Icons[74] := LoadIcon(HInstance,'Z_FULLSIZE_NORM');
    Icons[75] := LoadIcon(HInstance,'Z_BESTSIZE_NORM');
    Icons[76] := LoadIcon(HInstance,'E_MAIL');
    Icons[77] := LoadIcon(HInstance,'CRYPTFILE');
    Icons[78] := LoadIcon(HInstance,'DECRYPTFILE');
    Icons[79] := LoadIcon(HInstance,'PASSWORD');
    Icons[80] := LoadIcon(HInstance,'EXEFILE');
    Icons[81] := LoadIcon(HInstance,'SIMPLEFILE');
    Icons[82] := LoadIcon(HInstance,'CONVERT');
    Icons[83] := LoadIcon(HInstance,'RESIZE');
    Icons[84] := LoadIcon(HInstance,'REFRESHID');
    Icons[85] := LoadIcon(HInstance,'DUPLICAT');
    Icons[86] := LoadIcon(HInstance,'DELDUPLICAT');
    Icons[87] := LoadIcon(HInstance,'UPDATING');
    Icons[88] := LoadIcon(HInstance,'Z_FULLSCREEN_NORM');
    Icons[89] := LoadIcon(HInstance,'MYDOCUMENTS');
    Icons[90] := LoadIcon(HInstance,'MYPICTURES');
    Icons[91] := LoadIcon(HInstance,'DESKTOPLINK');
    Icons[92] := LoadIcon(HInstance,'IMEDITOR');
    Icons[93] := LoadIcon(HInstance,'OTHER_TOOLS');
    Icons[94] := LoadIcon(HInstance,'EXPORT_IMAGES');
    Icons[95] := LoadIcon(HInstance,'PRINTER');
    Icons[96] := LoadIcon(HInstance,'EXIF');
    Icons[97] := LoadIcon(HInstance,'GET_USB');
    Icons[98] := LoadIcon(HInstance,'USB');
    Icons[99] := LoadIcon(HInstance,'TXTFILE');
    Icons[100] := LoadIcon(HInstance,'DOWN');
    Icons[101] := LoadIcon(HInstance,'UP');
    Icons[102] := LoadIcon(HInstance,'CDROM');
    Icons[103] := LoadIcon(HInstance,'TREE');
    Icons[104] := LoadIcon(HInstance,'CANCELACTION');
    Icons[105] := LoadIcon(HInstance,'XDB');
    Icons[106] := LoadIcon(HInstance,'XMDB');
    Icons[107] := LoadIcon(HInstance,'SORT');
    Icons[108] := LoadIcon(HInstance,'FILTER');
    Icons[109] := LoadIcon(HInstance,'CLOCK');
    Icons[110] := LoadIcon(HInstance,'ATYPE');
    Icons[111] := LoadIcon(HInstance,'MAINICON');
    Icons[112] := LoadIcon(HInstance,'APPLY_ACTION');
    Icons[113] := LoadIcon(HInstance,'RELOADING');
    Icons[114] := LoadIcon(HInstance,'STENO');
    Icons[115] := LoadIcon(HInstance,'DESTENO');
    Icons[116] := LoadIcon(HInstance,'SPLIT');
    Icons[117] := LoadIcon(HInstance,'CD_EXPORT');
    Icons[118] := LoadIcon(HInstance,'CD_MAPPING');
    Icons[119] := LoadIcon(HInstance,'CD_IMAGE');
    Icons[120] := LoadIcon(HInstance,'MAGIC_ROTATE');
    Icons[121] := LoadIcon(HInstance,'PERSONS');
    Icons[122] := LoadIcon(HInstance,'CAMERA');
    Icons[123] := LoadIcon(HInstance,'CROP');
    Icons[124] := LoadIcon(HInstance,'PIC_IMPORT');
    Icons[125] := LoadIcon(HInstance,'BACKUP');
    Icons[126] := LoadIcon(HInstance,'MAP_MARKER');
    Icons[127] := LoadIcon(HInstance,'SHELF');
    Icons[128] := LoadIcon(HInstance,'PHOTO_SHARE');
    Icons[129] := LoadIcon(HInstance,'EDIT_PROFILE');
    Icons[130] := LoadIcon(HInstance,'AAA');
    Icons[131] := LoadIcon(HInstance,'LINK');
    Icons[132] := LoadIcon(HInstance,'VIEW_COUNT');
    Icons[133] := LoadIcon(HInstance,'TRAIN');

    //disabled items are bad
    for I := 1 to IconsCount do
      ImageList_ReplaceIcon(FImageList.Handle, -1, Icons[I]);

    for I := 1 to IconsCount do
    begin
      LB := TLayeredBitmap.Create;
      try
        LB.LoadFromHIcon(Icons[I]);
        LB.GrayScale;

        ImageList_Add(FDisabledImageList.Handle, LB.Handle, 0);
      finally
        F(LB);
      end;
    end;

    FImageList.SaveToCache('Images' + IconsVersion);
    FDisabledImageList.SaveToCache('ImGray' + IconsVersion);
  end;
end;

initialization
finalization
  F(FIcons);

end.
