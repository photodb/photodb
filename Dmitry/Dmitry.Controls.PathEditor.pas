unit Dmitry.Controls.PathEditor;

interface

uses
  Generics.Collections,
  System.Types,
  System.SysUtils,
  System.Classes,
  System.SysConst,
  System.StrUtils,
  System.SyncObjs,
  System.Math,
  System.Win.ComObj,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellApi,
  Winapi.CommCtrl,
  Winapi.ActiveX,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Buttons,
  Vcl.Menus,
  Vcl.Forms,
  Vcl.ImgList,
  Vcl.ActnPopup,
  Vcl.ActnMenus,
  Dmitry.Memory,
  Dmitry.Graphics.LayeredBitmap,
  Dmitry.Utils.ShellIcons,
  Dmitry.PathProviders;

const
  PATH_EMPTY          = '{21D84E1B-A7AB-4318-8A99-E603D9E1108F}';
  PATH_LOADING        = '{B1F847E1-DF22-40BD-9527-020EE0E9B22A}';
  PATH_RELOAD         = '{8A0FE330-1F30-4DBC-B439-A6EDD611FCDC}';
  PATH_STOP           = '{24794A3D-2983-4D7F-A85A-62D1C776C296}';
  PATH_EX             = '{07000F3F-50C9-4238-A31B-A7DAC4D4A4B0}';

type
  TGOM = class(TObject)
  private
    FList: TList;
    FSync: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddObj(Obj: TObject);
    procedure RemoveObj(Obj: TObject);
    function IsObj(Obj: TObject): Boolean;
  end;

  TPathEvent = procedure(Sender: TObject; Item: TPathItem) of object;
  TPathListEvent = procedure(Sender: TObject; PathItems: TPathItemCollection) of object;

  TDirectoryListingThread = class;
  TPathEditor = class;

  TThreadNotifyEvent = procedure(Sender: TThread);
  TGetSystemIconEvent = procedure(Sender: TPathEditor; IconType: string; var Image: TPathImage) of object;
  TGetItemIconEvent = procedure(Sender: TPathEditor; Item: TPathItem) of object;

  TIconExtractThread = class(TThread)
  private
    FPath: TPathItem;
    FOwner: TPathEditor;
    FImageParam: TPathImage;
    procedure UpdateIcon;
    procedure GetIcon;
  protected
    procedure Execute; override;
  public
    constructor Create(Owner: TPathEditor; Path: TPathItem);
    destructor Destroy; override;
  end;

  TDirectoryListingThread = class(TThread)
  private
    FPath: TPathItem;
    FNextPath: TPathItem;
    FOwner: TPathEditor;
    FItems: TPathItemCollection;
    FPathParam: TPathItem;
    FOnlyFS: Boolean;
    procedure FillItems;
  protected
    procedure Execute; override;
  public
    constructor Create(Owner: TPathEditor; Path, NextPath: TPathItem; OnlyFS: Boolean);
    destructor Destroy; override;
  end;

  TPathEditor = class(TWinControl)
  private
    { Private declarations }
    FCanvas: TCanvas;
    FPnContainer: TPanel;
    FEditor: TEdit;
    FImage: TImage;
    FIsEditorVisible: Boolean;
    FCurrentPath: string;
    FPmListMenu: TPopupActionBar;
    FBitmap: TBitmap;
    FOnChange: TNotifyEvent;
    FOnUserChange: TNotifyEvent;
    FBuilding: Boolean;
    FParts: TPathItemCollection;
    FTempParts: TPathItemCollection;
    FOnUpdateItem: TPathEvent;
    FClean: Boolean;
    FOnFillLevel: TPathListEvent;
    FOnParsePath: TPathListEvent;
    FTrash: TList<TControl>;
    FImages: TImageList;
    FCurrentState: string;
    FLoadingText: string;
    FCurrentPathEx: TPathItem;
    FGetSystemIcon: TGetSystemIconEvent;
    FGetItemIconEvent: TGetItemIconEvent;
    FCanBreakLoading: Boolean;
    FOnBreakLoading: TNotifyEvent;
    FTrashSender: TObject;
    FOnImageContextPopup: TContextPopupEvent;
    FOnPathPartContextPopup: TNotifyEvent;
    FOnContextPopup: TContextPopupEvent;
    FListPaths: TList<TPathItem>;
    FOnlyFileSystem: Boolean;
    FHideExtendedButton: Boolean;
    FShowBorder: Boolean;
    procedure SetPath(const Value: string);
    procedure SetBitmap(const Value: TBitmap);
    function GetCurrentPathEx: TPathItem;
    procedure SetCurrentPathEx(const Value: TPathItem);
    procedure SetCanBreakLoading(const Value: Boolean);
    procedure ImageContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure ContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure SetHideExtendedButton(const Value: Boolean);
    procedure SetShowBorder(const Value: Boolean);
  protected
    { Protected declarations }
    procedure WMSize(var Message : TSize); message WM_SIZE;
    procedure Erased(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure InitControls;
    procedure BuildPathParts(Sender: TObject; Item: TPathItem);
    procedure OnPathClick(Sender: TObject);
    procedure OnPathListClick(Sender: TObject);
    procedure EditorKeyPress(Sender: TObject; var Key: Char);
    procedure ClearParts;
    procedure PnContainerClick(Sender: TObject);
    procedure PnContainerExit(Sender: TObject);
    procedure FillPathParts(PathEx: TPathItem; PathList: TPathItemCollection);
    procedure SetThreadItems(PathList: TPathItemCollection; Path, NextPath: TPathItem);
    function LoadItemIcon(PathType: string): TPathImage;
    procedure LoadIcon(PathEx: TPathItem);
    procedure OnActionClick(Sender: TObject);
    procedure UpdateActionIcon;
    procedure UpdateIcon(Icon: TPathImage; Path: TPathItem);
    procedure UpdateBorderStyle;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Edit;
    procedure SetPathEx(Sender: TObject; Path: TPathItem; Force: Boolean); overload;
    procedure SetPathEx(PathType: TPathItemClass; Path: string); overload;
  published
    { Published declarations }
    property DoubleBuffered;
    property ParentDoubleBuffered;
    property Align;
    property Anchors;
    property Path: string read FCurrentPath write SetPath;
    property PathEx: TPathItem read FCurrentPathEx;
    property SeparatorImage: TBitmap read FBitmap write SetBitmap;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnUserChange: TNotifyEvent read FOnUserChange write FOnUserChange;
    property OnUpdateItem: TPathEvent read FOnUpdateItem write FOnUpdateItem;
    property OnFillLevel: TPathListEvent read FOnFillLevel write FOnFillLevel;
    property OnParsePath: TPathListEvent read FOnParsePath write FOnParsePath;
    property LoadingText: string read FLoadingText write FLoadingText;
    property GetSystemIcon: TGetSystemIconEvent read FGetSystemIcon write FGetSystemIcon;
    property CurrentPathEx: TPathItem read GetCurrentPathEx write SetCurrentPathEx;
    property CanBreakLoading: Boolean read FCanBreakLoading write SetCanBreakLoading;
    property OnBreakLoading: TNotifyEvent read FOnBreakLoading write FOnBreakLoading;
    property OnImageContextPopup: TContextPopupEvent read FOnImageContextPopup write FOnImageContextPopup;
    property OnPathPartContextPopup: TNotifyEvent read FOnPathPartContextPopup write FOnPathPartContextPopup;
    property OnContextPopup: TContextPopupEvent read FOnContextPopup write FOnContextPopup;
    property GetItemIconEvent: TGetItemIconEvent read FGetItemIconEvent write FGetItemIconEvent;
    property OnlyFileSystem: Boolean read FOnlyFileSystem write FOnlyFileSystem;
    property HideExtendedButton: Boolean read FHideExtendedButton write SetHideExtendedButton;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder;
  end;

var
  PERegisterThreadEvent: TThreadNotifyEvent = nil;
  PEUnRegisterThreadEvent: TThreadNotifyEvent = nil;

procedure Register;

implementation

var
  FGOM: TGOM = nil;

function GOM: TGOM;
begin
  if FGOM = nil then
    FGOM := TGOM.Create;

  Result := FGOM;
end;

procedure Register;
begin
  RegisterComponents('Dm', [TPathEditor]);
end;

procedure BeginScreenUpdate(Hwnd: THandle);
begin
  SendMessage(Hwnd, WM_SETREDRAW, 0, 0);
end;

procedure EndScreenUpdate(Hwnd: THandle; Erase: Boolean);
begin
  SendMessage(Hwnd, WM_SETREDRAW, 1, 0);
  RedrawWindow(Hwnd, nil, 0, { DW_FRAME + } RDW_INVALIDATE + RDW_ALLCHILDREN + RDW_NOINTERNALPAINT);
  if (Erase) then
    InvalidateRect(Hwnd, nil, True);
end;

{$ENDREGION}

{ TPathEditor }

procedure TPathEditor.FillPathParts(PathEx: TPathItem; PathList: TPathItemCollection);
var
  PathPart: TPathItem;

begin
  if PathEx = nil then
    Exit;
  try

    PathPart := PathEx;
    while (PathPart <> nil) do
    begin
      PathList.Insert(0, PathPart.Copy);
      PathPart := PathPart.Parent;
    end;

  finally
    if Assigned(OnParsePath) then
      OnParsePath(Self, PathList);
  end;
end;

function TPathEditor.GetCurrentPathEx: TPathItem;
begin
  Result := FCurrentPathEx;
end;

constructor TPathEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  GOM.AddObj(Self);
  FTrash := TList<TControl>.Create;
  FListPaths := TList<TPathItem>.Create;
  FIsEditorVisible := False;
  FOnlyFileSystem := False;
  FClean := True;
  FOnChange := nil;
  FOnUpdateItem := nil;
  FOnUserChange := nil;
  FOnFillLevel := nil;
  FOnParsePath := nil;
  FCurrentPathEx := nil;
  FGetSystemIcon := nil;
  FOnBreakLoading := nil;
  FOnImageContextPopup := nil;
  FOnPathPartContextPopup := nil;
  FOnContextPopup := nil;

  FTrashSender := nil;
  FLoadingText := 'Loading...';
  FCurrentState := '';
  FBuilding := False;
  FParts := TPathItemCollection.Create;
  FTempParts := TPathItemCollection.Create;

  ControlStyle := ControlStyle - [csDoubleClicks];

  Height := 25;
  FBitmap := TBitmap.Create;

  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;

  InitControls;
end;

destructor TPathEditor.Destroy;
begin
  GOM.RemoveObj(Self);
  ClearParts;
  FreeList(FTrash);
  F(FListPaths);
  F(FCanvas);
  F(FBitmap);
  FParts.FreeItems;
  F(FParts);
  FTempParts.FreeItems;
  F(FTempParts);
  F(FCurrentPathEx);
  inherited;
end;

procedure TPathEditor.ImageContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  if Assigned(FOnImageContextPopup) then
    FOnImageContextPopup(Self, MousePos, Handled);
end;

procedure TPathEditor.InitControls;
var
  Image: TPathImage;
begin
  Color := clWhite;

  FPnContainer := TPanel.Create(Self);
  FPnContainer.Parent := Self;
  FPnContainer.DoubleBuffered := True;
  FPnContainer.ParentBackground := False;
  FPnContainer.Align := alClient;
  FPnContainer.Color := clWindow;
  FPnContainer.OnClick := PnContainerClick;
  FPnContainer.OnExit := PnContainerExit;
  FPnContainer.BevelOuter := bvNone;
  FPnContainer.BorderStyle := bsNone;

  UpdateBorderStyle;

  FPnContainer.OnContextPopup := ContextPopup;

  FImage := TImage.Create(FPnContainer);
  FImage.Parent := FPnContainer;
  FImage.Left := 2;
  FImage.Top := Height div 2 - 16 div 2;
  FImage.Width := 16;
  FImage.Height := 16;
  FImage.Center := True;
  FImage.OnContextPopup := ImageContextPopup;
  Image := LoadItemIcon(PATH_EMPTY);
  try
    if Image <> nil then
      FImage.Picture.Graphic := Image.Graphic;
  finally
    F(Image);
  end;

  FEditor := TEdit.Create(FPnContainer);
  FEditor.Parent := FPnContainer;
  FEditor.Align := alClient;
  FEditor.Visible := False;
  FEditor.OnExit := PnContainerExit;
  FEditor.OnKeyPress := EditorKeyPress;

  FImages := TImageList.Create(Self);
  FImages.ColorDepth := cd32Bit;
  FPmListMenu := TPopupActionBar.Create(Self);
  FPmListMenu.Images := FImages;
end;

procedure TPathEditor.LoadIcon(PathEx: TPathItem);
begin
  if Assigned(GetItemIconEvent) then
    GetItemIconEvent(Self, PathEx);
end;

function TPathEditor.LoadItemIcon(PathType: string): TPathImage;
begin
  Result := nil;
  if Assigned(FGetSystemIcon) then
    FGetSystemIcon(Self, PathType, Result);
end;

function CleanCaptionName(const S: string): string;
var
  I: Integer;
begin
  Result := S;
  for I := Length(Result) downto 1 do
    if Result[I] = '&' then Insert('&', Result, I);
end;

procedure TPathEditor.BuildPathParts(Sender: TObject; Item: TPathItem);
var
  I, P, MaxWidth: Integer;
  PathPart: TPathItem;
  ButtonPath, ButtonList, ButtonListReload: TSpeedButton;
  StartItem, ItemHeight: Integer;

begin
  if FBuilding then
    Exit;

  MaxWidth := Width - 20;
  if Item <> nil then
    Item := Item.Copy;
  try
    if (FTrashSender <> Sender) and (Sender <> nil) then
    begin
      FTrashSender := Sender;
      for I := FTrash.Count - 1 downto 0 do
        if FTrash[I] <> Sender then
        begin
          TControl(FTrash[I]).Free;
          FTrash.Delete(I);
        end;
    end;

    BeginScreenUpdate(Handle);
    FPnContainer.DisableAlign;
    try
      FClean := False;
      FBuilding := True;

      try
        ClearParts;

        FillPathParts(Item, FParts);
        if FParts.Count = 0 then
          Exit;

        P := 22;
        StartItem := FParts.Count - 1;

        for I := FParts.Count - 1 downto 0 do
        begin
          PathPart := FParts[I];
          P := P + FCanvas.TextWidth(PathPart.DisplayName) + 15 - 2;
          P := P + 16;
          P := P + 1;

          if P <= MaxWidth then
            StartItem := I
          else
            Break;
        end;

        ItemHeight := FPnContainer.Height - 1;
        if FShowBorder then
          Dec(ItemHeight, 3);

        P := 22;
        for I := StartItem to FParts.Count - 1 do
        begin
          PathPart := FParts[I];

          ButtonPath := TSpeedButton.Create(FPnContainer);
          ButtonPath.Parent := FPnContainer;
          ButtonPath.Font := FCanvas.Font;
          ButtonList := TSpeedButton.Create(FPnContainer);
          ButtonList.Parent := FPnContainer;
          ButtonList.Font := FCanvas.Font;

          ButtonPath.Top := 0;
          ButtonPath.Left := P;
          ButtonPath.Width := Min(FCanvas.TextWidth(PathPart.DisplayName) + 15, MaxWidth - 16);
          ButtonPath.Height := ItemHeight;
          ButtonPath.Caption := CleanCaptionName(PathPart.DisplayName);
          ButtonPath.Flat := True;
          ButtonPath.Tag := NativeInt(PathPart);
          ButtonPath.OnClick := OnPathClick;
          P := P + ButtonPath.Width - 2;

          ButtonList.Top := 0;
          ButtonList.Left := P;
          ButtonList.Width := 16;
          ButtonList.Height := ItemHeight;
          ButtonList.Tag := NativeInt(PathPart);
          ButtonList.Glyph := FBitmap;
          ButtonList.Flat := True;
          ButtonList.OnClick := OnPathListClick;
          FListPaths.Add(PathPart);
          P := P + ButtonList.Width;

          P := P + 1;
        end;

        if not HideExtendedButton then
        begin
          ButtonListReload := TSpeedButton.Create(FPnContainer);
          ButtonListReload.Parent := FPnContainer;
          ButtonListReload.Top := 0;
          ButtonListReload.Width := 20;
          ButtonListReload.Left := Width - ButtonListReload.Width - 2;
          ButtonListReload.Height := ItemHeight;
          ButtonListReload.OnClick := OnActionClick;
          ButtonListReload.Flat := True;
          ButtonListReload.Tag := 1;
        end;
        UpdateActionIcon;
      finally
        FBuilding := False;
      end;
    finally
      FPnContainer.EnableAlign;
      EndScreenUpdate(Handle, True);
    end;
  finally
    F(Item);
  end;
end;

procedure TPathEditor.ClearParts;
var
  I: Integer;
begin
  FListPaths.Clear;
  for I := FPnContainer.ControlCount - 1 downto 0 do
    if (FPnContainer.Controls[I] <> FEditor) and
      (FPnContainer.Controls[I] <> FImage) then
    begin
      FTrash.Add(FPnContainer.Controls[I]);
      FPnContainer.RemoveControl(FPnContainer.Controls[I]);
    end;

  FParts.FreeItems;
  FClean := True;
end;

procedure TPathEditor.ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  if Assigned(FOnContextPopup) then
    FOnContextPopup(Sender, MousePos, Handled);
end;

procedure TPathEditor.Edit;
begin
  //Clear items and display path editor
  FIsEditorVisible := True;
  FEditor.Text := FCurrentPath;
  FEditor.Show;
  FEditor.SetFocus;
  ClearParts;
end;

procedure TPathEditor.EditorKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_RETURN then
  begin
    Key := #0;
    PnContainerExit(FEditor);

    if Assigned(FOnUserChange) then
      FOnUserChange(Self);
  end;
end;

procedure TPathEditor.Erased(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TPathEditor.OnActionClick(Sender: TObject);
begin
  if FCanBreakLoading and Assigned(FOnBreakLoading) then
  begin
    FOnBreakLoading(Self);
    Exit;
  end else if not FCanBreakLoading then
  begin
    if Assigned(FOnUserChange) then
      FOnUserChange(Self);
  end;
end;

procedure TPathEditor.OnPathClick(Sender: TObject);
var
  PathPart: TPathItem;
begin
  PathPart := TPathItem(TControl(Sender).Tag);

  SetPathEx(Sender, PathPart, False);

  if Assigned(FOnUserChange) then
    FOnUserChange(Self);
end;

procedure TPathEditor.OnPathListClick(Sender: TObject);
var
  MI: TMenuItem;
  ListButton: TSpeedButton;
  P: TPoint;
  Path: string;
  Image: TPathImage;
  I, Index: Integer;
  PathPart, PP, NextPath: TPathItem;
begin
  ListButton := TSpeedButton(Sender);

  PathPart := TPathItem(ListButton.Tag);

  PP := PathPart.Copy;
  FCurrentState := PP.Path;
  try
    Path := PP.Path;

    FPmListMenu.Items.Clear;
    FTempParts.FreeItems;
    FImages.Clear;

    MI := TMenuItem.Create(FPmListMenu);
    MI.Caption := FLoadingText;
    MI.Tag := 0;

    Image := LoadItemIcon(PATH_LOADING);
    try
      if Image <> nil then
      begin
        Image.AddToImageList(FImages);
        MI.ImageIndex := 0;
      end;
    finally
      F(Image);
    end;

    FPmListMenu.Items.Add(MI);

    NextPath := nil;
    Index := -1;
    for I := 0 to FListPaths.Count - 1 do
      if FListPaths[I].Path = PP.Path then
        Index := I;

    if (Index > -1) and (Index < FListPaths.Count - 1) then
      NextPath := FListPaths[Index + 1];
    TDirectoryListingThread.Create(Self, PP, NextPath, FOnlyFileSystem);
    P := Point(ListButton.Left, ListButton.BoundsRect.Bottom);
    P := FPnContainer.ClientToScreen(P);
    FPmListMenu.Popup(P.X, P.Y);
  finally
    F(PP);
  end;
end;

procedure TPathEditor.PnContainerClick(Sender: TObject);
begin
  Edit;
end;

procedure TPathEditor.PnContainerExit(Sender: TObject);
begin
  FIsEditorVisible := False;
  FEditor.Hide;

  if Sender = Self then
    Exit;

  if PathProviderManager.Supports(FEditor.Text) then
    Path := FEditor.Text
  else
    Path := FCurrentPath;

end;

procedure TPathEditor.SetBitmap(const Value: TBitmap);
begin
  FBitmap.Assign(Value);
end;

procedure TPathEditor.SetCanBreakLoading(const Value: Boolean);
begin
  FCanBreakLoading := Value;
  UpdateActionIcon;
end;

procedure TPathEditor.SetCurrentPathEx(const Value: TPathItem);
var
  P: TPathItem;
begin
  P := FCurrentPathEx;
  FCurrentPathEx := Value.Copy;
  F(P);
end;

procedure TPathEditor.SetHideExtendedButton(const Value: Boolean);
begin
  FHideExtendedButton := Value;

end;

procedure TPathEditor.SetPathEx(Sender: TObject; Path: TPathItem; Force: Boolean);
var
  Image: TPathImage;
  ExtractIcon: Boolean;
  P: TPathItem;
begin
  if not Force and (Path.EqualsTo(FCurrentPathEx)) then
    Exit;

  if FIsEditorVisible then
    PnContainerExit(Self);

  CurrentPathEx := Path;
  FCurrentPath := CurrentPathEx.Path;
  BuildPathParts(Sender, CurrentPathEx);

  P := CurrentPathEx.Copy;
  try
    ExtractIcon := not P.IsInternalIcon;
    if not ExtractIcon then
    begin
      P.LoadImage(PATH_LOAD_NORMAL, 16);
      if P.Image <> nil then
        Image := P.Image.Copy;
    end else
      Image := LoadItemIcon(PATH_EMPTY);

    try
      if Image <> nil then
        FImage.Picture.Graphic := Image.Graphic;
    finally
      F(Image);
    end;
    if ExtractIcon then
    begin
      FCurrentState := P.Path;
      TIconExtractThread.Create(Self, P);
    end;
  finally
    F(P);
  end;

  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TPathEditor.SetPath(const Value: string);
var
  PP: TPathItem;
begin
  if (FCurrentPath = Value) and not FClean then
    Exit;

  FCurrentPath := Value;
  PP := PathProviderManager.CreatePathItem(Value);
  try
    if PP <> nil then
      SetPathEx(nil, PP, True);
  finally
    F(PP);
  end;
end;

procedure TPathEditor.SetPathEx(PathType: TPathItemClass; Path: string);
var
  PP: TPathItem;
begin
  PP := PathType.CreateFromPath(Path, PATH_LOAD_NO_IMAGE or PATH_LOAD_FAST, 0);
  try
    SetPathEx(Self, PP, False);
  finally
    F(PP);
  end;
end;

procedure TPathEditor.SetShowBorder(const Value: Boolean);
begin
  FShowBorder := Value;

  UpdateBorderStyle;
end;

type
  TXPStylePopupMenuEx = class(TCustomActionPopupMenu);

procedure TPathEditor.SetThreadItems(PathList: TPathItemCollection; Path, NextPath: TPathItem);
var
  I: Integer;
  MI: TMenuItem;
  PP: TPathItem;
  CurrentPath: string;
begin
  CurrentPath := '';
  if (NextPath <> nil) then
    CurrentPath := ExcludeTrailingPathDelimiter(NextPath.Path);

  if FCurrentState = Path.Path then
  begin
    FImages.Clear;

    for I := 0 to PathList.Count - 1 do
    begin
      PP := PathList[I];
      FTempParts.Add(PP);
      MI := TMenuItem.Create(FPmListMenu);
      MI.Caption := CleanCaptionName(PP.DisplayName);
      MI.Tag := NativeInt(PP);
      MI.OnClick := OnPathClick;
      MI.Default := AnsiLowerCase(ExcludeTrailingPathDelimiter(PP.Path)) = AnsiLowerCase(CurrentPath);
      if PP.Image <> nil then
      begin
        PP.Image.AddToImageList(FImages);
        MI.ImageIndex := FImages.Count - 1;
      end;
      FPmListMenu.Items.Add(MI);
    end;
    PathList.Clear;
    if FPmListMenu.PopupMenu <> nil then
    begin
      if FPmListMenu.Items.Count = 1 then
        //close popup menu
        FPmListMenu.PopupMenu.CloseMenu
      else
      begin
        FPmListMenu.PopupMenu.DisableAlign;
        try
          FPmListMenu.Items.Delete(0);
          FPmListMenu.PopupMenu.LoadMenu(FPmListMenu.PopupMenu.ActionClient.Items, FPmListMenu.Items);
        finally
          FPmListMenu.PopupMenu.EnableAlign;
        end;
        TXPStylePopupMenuEx(FPmListMenu.PopupMenu).PositionPopup(nil, nil);
        FPmListMenu.PopupMenu.ActionClient.Items.Delete(0);
      end;
    end;

    if Assigned(OnFillLevel) then
      OnFillLevel(Self, FTempParts);
  end else
    PathList.Clear;
end;

procedure TPathEditor.UpdateActionIcon;
var
  Image: TPathImage;
  LB: TLayeredBitmap;
  I: Integer;
begin
  if FCanBreakLoading then
    Image := LoadItemIcon(PATH_STOP)
  else
    Image := LoadItemIcon(PATH_RELOAD);
  try
    if Image <> nil then
    begin
      LB := TLayeredBitmap.Create;
      try
        if Image.HIcon <> 0 then
          LB.LoadFromHIcon(Image.HIcon, 16, 16, Color)
        else if Image.Icon <> nil then
          LB.LoadFromHIcon(Image.Icon.Handle, 16, 16, Color)
        else if Image.Bitmap <> nil then
          LB.LoadFromBitmap(Image.Bitmap);

        for I := 0 to FPnContainer.ControlCount - 1 do
          if FPnContainer.Controls[I].Tag = 1 then
             TSpeedButton(FPnContainer.Controls[I]).Glyph := LB;
      finally
        F(LB);
      end;
    end;
  finally
    F(Image);
  end;
end;

procedure TPathEditor.UpdateBorderStyle;
begin
  if FShowBorder then
    FPnContainer.BevelKind := bkFlat
  else
    FPnContainer.BevelKind := bkNone;
end;

procedure TPathEditor.UpdateIcon(Icon: TPathImage; Path: TPathItem);
begin
  if FCurrentState = Path.Path then
  begin
    if Icon <> nil then
      FImage.Picture.Graphic := Icon.Graphic;
  end;
end;

procedure TPathEditor.WMSize(var Message: TSize);
begin
  inherited;

  if (Width <> Message.cx) and Visible then
    BuildPathParts(Self, CurrentPathEx);
end;

{ TIconExtractThread }

constructor TIconExtractThread.Create(Owner: TPathEditor; Path: TPathItem);
begin
  inherited Create(False);
  FOwner := Owner;
  FPath := Path.Copy;
  if Assigned(PERegisterThreadEvent) then
    PERegisterThreadEvent(Self);
end;

destructor TIconExtractThread.Destroy;
begin
  F(FPath);
  if Assigned(PEUnRegisterThreadEvent) then
    PEUnRegisterThreadEvent(Self);
  inherited;
end;

procedure TIconExtractThread.Execute;
begin
  FreeOnTerminate := True;
  CoInitializeEx(nil, COINIT_MULTITHREADED);
  try
    try
      FPath.LoadImage(PATH_LOAD_NORMAL, 16);
      if FPath.Image = nil then
        Synchronize(GetIcon);
      FImageParam := FPath.Image;
    finally
      Synchronize(UpdateIcon);
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TIconExtractThread.GetIcon;
begin
  if GOM.IsObj(FOwner) then
    FOwner.LoadIcon(FPath);
end;

procedure TIconExtractThread.UpdateIcon;
begin
  if GOM.IsObj(FOwner) then
    FOwner.UpdateIcon(FImageParam, FPath);
end;

{ TDirectoryListingThread }

constructor TDirectoryListingThread.Create(Owner: TPathEditor; Path, NextPath: TPathItem; OnlyFS: Boolean);
begin
  inherited Create(False);
  FPath := Path.Copy;
  FNextPath := nil;
  FOnlyFS := OnlyFS;
  if NextPath <> nil then
    FNextPath := NextPath.Copy;
  FOwner := Owner;
  FItems := TPathItemCollection.Create;
  FPathParam := nil;
  if Assigned(PERegisterThreadEvent) then
    PERegisterThreadEvent(Self);
end;

destructor TDirectoryListingThread.Destroy;
begin
  F(FPath);
  F(FNextPath);
  F(FItems);
  if Assigned(PEUnRegisterThreadEvent) then
    PEUnRegisterThreadEvent(Self);
  inherited;
end;

procedure TDirectoryListingThread.Execute;
var
  Item: TPathItem;
  Options: Integer;
begin
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    try
      Item := PathProviderManager.CreatePathItem(FPath.Path);
      try
        Options := PATH_LOAD_DIRECTORIES_ONLY or PATH_LOAD_FOR_IMAGE_LIST;
        if FOnlyFS then
          Options := Options or PATH_LOAD_ONLY_FILE_SYSTEM;

        if Item <> nil then
          Item.Provider.FillChildList(Self, Item, FItems, Options, 16, MaxInt, nil);

      finally
        F(Item);
      end;
    finally
      Synchronize(FillItems);
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TDirectoryListingThread.FillItems;
begin
  if GOM.IsObj(FOwner) then
  begin
    FOwner.SetThreadItems(FItems, FPath, FNextPath);
    FItems.FreeItems;
  end;
end;

{ TGOM }

procedure TGOM.AddObj(Obj: TObject);
begin
  FSync.Enter;
  try
    FList.Add(Obj);
  finally
    FSync.Leave;
  end;
end;

constructor TGOM.Create;
begin
  FList := TList.Create;
  FSync := TCriticalSection.Create;
end;

destructor TGOM.Destroy;
begin
  F(FList);
  F(FSync);
  inherited;
end;

function TGOM.IsObj(Obj: TObject): Boolean;
begin
  FSync.Enter;
  try
    Result := FList.IndexOf(Obj) > -1;
  finally
    FSync.Leave;
  end;
end;

procedure TGOM.RemoveObj(Obj: TObject);
begin
  FSync.Enter;
  try
    FList.Remove(Obj);
  finally
    FSync.Leave;
  end;
end;

initialization

finalization
  F(FGOM);

end.
