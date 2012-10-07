unit uFrmImportImagesLanding;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  uFrameWizardBase,
  StdCtrls,
  ComCtrls,
  ImgList,
  Menus,
  UnitDBDeclare,
  UnitDBKernel,
  uConstants,
  UnitDBCommonGraphics,

  Dmitry.Utils.Files,

  uShellIntegration,
  uShellUtils,
  UnitDBFileDialogs,
  uRuntime,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup;

type
  TFrmImportImagesLanding = class(TFrameWizardBase)
    LvPlaces: TListView;
    BtnAddFolder: TButton;
    BtnRemoveFolder: TButton;
    LbLandingInfo: TLabel;
    PmDeleteItem: TPopupActionBar;
    DeleteItem1: TMenuItem;
    PlacesImageList: TImageList;
    procedure BtnAddFolderClick(Sender: TObject);
    procedure BtnRemoveFolderClick(Sender: TObject);
    procedure LvPlacesContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
  protected
    { Protected declarations }
    procedure LoadLanguage; override;
  public
    { Public declarations }
    procedure AddFolder(NewPlace : string);
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    procedure Unload; override;
    function ValidateStep(Silent: Boolean): Boolean; override;
    function ExtractNextDirectory: string;
    function FirstPath: string;
  end;

const
  DefaultIcon = '%SystemRoot%\system32\shell32.dll,3';

implementation

{$R *.dfm}

{ TFrmImportImagesLanding }

procedure TFrmImportImagesLanding.Init(Manager: TWizardManagerBase;
  FirstInitialization: Boolean);
begin
  inherited;
  if FirstInitialization then
  begin
    PmDeleteItem.Images := DBKernel.ImageList;
    DeleteItem1.ImageIndex := DB_IC_DELETE_INFO;

    AddFolder(GetMyPicturesPath);
  end;
end;

procedure TFrmImportImagesLanding.LoadLanguage;
begin
  inherited;
  LbLandingInfo.Caption := L('Select folders to import images');
  BtnAddFolder.Caption := L('Add folder');
  BtnRemoveFolder.Caption := L('Delete');
  DeleteItem1.Caption := L('Delete');
  LvPlaces.Columns[0].Caption := L('Locations to import');
end;

procedure TFrmImportImagesLanding.Unload;
var
  I: Integer;
begin
  for I := 0 to LvPlaces.Items.Count - 1 do
    TObject(LvPlaces.Items[I].Data).Free;
  LvPlaces.Clear;
  inherited;
end;

function TFrmImportImagesLanding.ValidateStep(Silent: Boolean): Boolean;
begin
  Result := LvPlaces.Items.Count > 0;
  if not Result and not Silent then
  begin
    MessageBoxDB(Handle, L('Please, add any path to import images!'), L('Warning'),
      TD_BUTTON_OK, TD_ICON_WARNING);
  end;
end;

procedure TFrmImportImagesLanding.AddFolder(NewPlace : string);
var
  P: TImportPlace;
begin
  if DirectoryExists(NewPlace) then
  begin
    AddIconToListFromPath(PlacesImageList, DefaultIcon);
    P:= TImportPlace.Create;
    P.Path := NewPlace;
    with LvPlaces.Items.AddItem(nil) do
    begin
      ImageIndex := PlacesImageList.Count - 1;
      Caption := Mince(NewPlace, 30);
      Data := P;
    end;
  end;
end;

procedure TFrmImportImagesLanding.LvPlacesContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Item: TListItem;
begin
  Item := LvPlaces.GetItemAt(MousePos.X, MousePos.Y);
  if Item <> nil then
  begin
    PmDeleteItem.Tag := Item.Index;
    PmDeleteItem.Popup(LvPlaces.ClientToScreen(MousePos).X,
      LvPlaces.ClientToScreen(MousePos).Y);
  end;
end;

procedure TFrmImportImagesLanding.BtnRemoveFolderClick(Sender: TObject);
var
  I: Integer;
begin
  if PmDeleteItem.Tag <> -1 then
    if LvPlaces.Selected <> nil then
      PmDeleteItem.Tag := LvPlaces.Selected.Index;

  if PmDeleteItem.Tag <> -1 then
  begin
    PlacesImageList.Delete(PmDeleteItem.Tag);
    TObject(LvPlaces.Items[PmDeleteItem.Tag].Data).Free;
    LvPlaces.Items.Delete(PmDeleteItem.Tag);
    for I := PmDeleteItem.Tag to LvPlaces.Items.Count - 1 do
      LvPlaces.Items[I].ImageIndex := LvPlaces.Items[I].ImageIndex - 1;
  end;
end;

function TFrmImportImagesLanding.ExtractNextDirectory: string;
begin
  Result := '';
  TObject(LvPlaces.Items[0].Data).Free;
  LvPlaces.Items[0].Delete;
  if LvPlaces.Items.Count > 0 then
    Result := TImportPlace(LvPlaces.Items[0].Data).Path;
end;

function TFrmImportImagesLanding.FirstPath: string;
begin
  Result := TImportPlace(LvPlaces.Items[0].Data).Path;
end;

procedure TFrmImportImagesLanding.BtnAddFolderClick(Sender: TObject);
var
  NewPlace: String;
begin
  NewPlace := UnitDBFileDialogs.DBSelectDir(Handle, L('Please, select a folder'),
    UseSimpleSelectFolderDialog);
  AddFolder(NewPlace);
end;

end.
