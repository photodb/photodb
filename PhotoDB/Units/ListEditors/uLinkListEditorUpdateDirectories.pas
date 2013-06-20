unit uLinkListEditorUpdateDirectories;

interface

uses
  Generics.Collections,
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Imaging.PngImage,

  Dmitry.Utils.System,
  Dmitry.Imaging.JngImage,
  Dmitry.Controls.WatermarkedEdit,
  Dmitry.Controls.WebLink,
  Dmitry.PathProviders,

  UnitDBDeclare,

  uMemory,
  uConstants,
  uDBForm,
  uTranslate,
  uFormInterfaces,
  uResources,
  uShellIntegration,
  uCollectionUtils,
  uLinkListEditorFolders,
  uDatabaseDirectoriesUpdater,
  uVCLHelpers,
  uDBManager,
  uCollectionEvents,
  uIconUtils;

type
  TLinkListEditorUpdateDirectories = class(TInterfacedObject, ILinkEditor)
  private
    FForm: IFormLinkItemEditorData;
    function L(StringToTranslate: string): string;
    procedure LoadIconForLink(Link: TWebLink; Path: string);
    procedure OnChangePlaceClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    constructor Create;
    procedure SetForm(Form: IFormLinkItemEditorData); virtual;
    procedure CreateNewItem(Sender: ILinkItemSelectForm; var Data: TDataObject; Verb: string; Elements: TListElements);
    procedure CreateEditorForItem(Sender: ILinkItemSelectForm; Data: TDataObject; EditorData: IFormLinkItemEditorData);
    procedure UpdateItemFromEditor(Sender: ILinkItemSelectForm; Data: TDataObject; EditorData: IFormLinkItemEditorData);
    procedure FillActions(Sender: ILinkItemSelectForm; AddActionProc: TAddActionProcedure);
    function OnDelete(Sender: ILinkItemSelectForm; Data: TDataObject; Editor: TPanel): Boolean;
    function OnApply(Sender: ILinkItemSelectForm): Boolean;
  end;

implementation

uses
  uFormLinkItemSelector;

const
  CHANGE_DIRECTORY_ICON        = 1;
  CHANGE_DIRECTORY_EDIT        = 2;
  CHANGE_DIRECTORY_CHANGE_PATH = 3;
  CHANGE_DIRECTORY_INFO        = 4;

{ TLinkListEditorUpdateDirectories }


constructor TLinkListEditorUpdateDirectories.Create();
begin
end;

procedure TLinkListEditorUpdateDirectories.CreateEditorForItem(Sender: ILinkItemSelectForm;
  Data: TDataObject; EditorData: IFormLinkItemEditorData);
var
  DD: TDatabaseDirectory;
  WlIcon: TWebLink;
  WlChangeLocation: TWebLink;
  WedCaption: TWatermarkedEdit;
  LbInfo: TLabel;
  Editor: TPanel;
begin
  Editor := EditorData.EditorPanel;
  DD := TDatabaseDirectory(Data);

  WlIcon := Editor.FindChildByTag<TWebLink>(CHANGE_DIRECTORY_ICON);
  WedCaption :=  Editor.FindChildByTag<TWatermarkedEdit>(CHANGE_DIRECTORY_EDIT);
  WlChangeLocation := Editor.FindChildByTag<TWebLink>(CHANGE_DIRECTORY_CHANGE_PATH);
  LbInfo := Editor.FindChildByTag<TLabel>(CHANGE_DIRECTORY_INFO);

  if WedCaption = nil then
  begin
    WedCaption := TWatermarkedEdit.Create(Editor);
    WedCaption.Parent := Editor;
    WedCaption.Tag := CHANGE_DIRECTORY_EDIT;
    WedCaption.Top := 8;
    WedCaption.Left := 35;
    WedCaption.Width := 200;
    WedCaption.OnKeyDown := FormKeyDown;
  end;

  if WlIcon = nil then
  begin
    WlIcon := TWebLink.Create(Editor);
    WlIcon.Parent := Editor;
    WlIcon.Tag := CHANGE_DIRECTORY_ICON;
    WlIcon.Width := 16;
    WlIcon.Height := 16;
    WlIcon.Left := 8;
    WlIcon.Top := 8 + WedCaption.Height div 2 - WlIcon.Height div 2;
    WlIcon.CanClick := False;
  end;

  if WlChangeLocation = nil then
  begin
    WlChangeLocation := TWebLink.Create(Editor);
    WlChangeLocation.Parent := Editor;
    WlChangeLocation.Tag := CHANGE_DIRECTORY_CHANGE_PATH;
    WlChangeLocation.Height := 26;
    WlChangeLocation.Text := L('Change location');
    WlChangeLocation.RefreshBuffer(True);
    WlChangeLocation.Top := 8 + WedCaption.Height div 2 - WlChangeLocation.Height div 2;
    WlChangeLocation.Left := 240;
    WlChangeLocation.LoadFromResource('NAVIGATE');
    WlChangeLocation.OnClick := OnChangePlaceClick;
  end;

  if LbInfo = nil then
  begin
    LbInfo := TLabel.Create(Editor);
    LbInfo.Parent := Editor;
    LbInfo.Tag := CHANGE_DIRECTORY_INFO;
    LbInfo.Left := 35;
    LbInfo.Top := 35;
  end;

  LoadIconForLink(WlIcon, DD.Path);

  WedCaption.Text := DD.Name;
  LbInfo.Caption := DD.Path;
end;

procedure TLinkListEditorUpdateDirectories.CreateNewItem(Sender: ILinkItemSelectForm;
  var Data: TDataObject; Verb: string; Elements: TListElements);
var
  DD: TDatabaseDirectory;
  PI: TPathItem;
  Link: TWebLink;
  Info: TLabel;
  I: Integer;
begin
  if Data = nil then
  begin
    if Verb = 'Refresh' then
    begin
      ClearUpdaterCache(DBManager.DBContext);
      RecheckUserDirectories;
      MessageBoxDB(0, L('The cache was cleared and scanning process has been started!'), L('Info'),  TD_BUTTON_OK, TD_ICON_INFORMATION);
      Exit;
    end;

    PI := nil;
    try
      if SelectLocationForm.Execute(L('Select a directory'), '', PI, False) then
      begin

        for I := 0 to Sender.DataList.Count - 1 do
        begin
          DD := TDatabaseDirectory(Sender.DataList[I]);
          if StartsStr(AnsiLowerCase(DD.Path), AnsiLowerCase(PI.Path)) then
          begin
            MessageBoxDB(0, FormatEx(L('Location {0} is already in collection!'), [PI.Path]), L('Info'),  TD_BUTTON_OK, TD_ICON_WARNING);
            Exit;
          end;
        end;

        Data := TDatabaseDirectory.Create(PI.Path, PI.DisplayName, 0);
      end;
    finally
      F(PI);
    end;

    Exit;
  end;
  DD := TDatabaseDirectory(Data);

  Link := TWebLink(Elements[leWebLink]);
  Info := TLabel(Elements[leInfoLabel]);

  Link.Text := DD.Name;
  Info.Caption := DD.Path;
  Info.EllipsisPosition := epPathEllipsis;

  LoadIconForLink(Link, DD.Path);
end;

procedure TLinkListEditorUpdateDirectories.FillActions(Sender: ILinkItemSelectForm;
  AddActionProc: TAddActionProcedure);
begin
  AddActionProc(['Add', 'Refresh'],
    procedure(Action: string; WebLink: TWebLink)
    begin
      if Action = 'Add' then
      begin
        WebLink.Text := L('Add directory');
        WebLink.LoadFromResource('SERIES_EXPAND');
      end;
      if Action = 'Refresh' then
      begin
        WebLink.Text := L('Rescan');
        WebLink.LoadFromResource('SYNC');
      end;
    end
  );
end;

procedure TLinkListEditorUpdateDirectories.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    FForm.ApplyChanges;
end;

function TLinkListEditorUpdateDirectories.L(StringToTranslate: string): string;
begin
  Result := TA(StringToTranslate, 'CollectionSettings');
end;

procedure TLinkListEditorUpdateDirectories.LoadIconForLink(Link: TWebLink; Path: string);
var
  PI: TPathItem;
begin
  PI := PathProviderManager.CreatePathItem(Path);
  try
    if (PI <> nil) and PI.LoadImage(PATH_LOAD_NORMAL or PATH_LOAD_FAST or PATH_LOAD_FOR_IMAGE_LIST, 16) and (PI.Image <> nil) then
      Link.LoadFromPathImage(PI.Image);

  finally
    F(PI);
  end;
end;

procedure TLinkListEditorUpdateDirectories.UpdateItemFromEditor(
  Sender: ILinkItemSelectForm; Data: TDataObject; EditorData: IFormLinkItemEditorData);
var
  DD: TDatabaseDirectory;
  WedCaption: TWatermarkedEdit;
begin
  DD := TDatabaseDirectory(Data);

  WedCaption := EditorData.EditorPanel.FindChildByTag<TWatermarkedEdit>(CHANGE_DIRECTORY_EDIT);

  DD.Assign(EditorData.EditorData);
  DD.Name := WedCaption.Text;
end;

function TLinkListEditorUpdateDirectories.OnApply(Sender: ILinkItemSelectForm): Boolean;
begin
  Result := True;
end;

procedure TLinkListEditorUpdateDirectories.OnChangePlaceClick(Sender: TObject);
var
  DD: TDatabaseDirectory;
  LbInfo: TLabel;
  Editor: TPanel;
  PI: TPathItem;
begin
  Editor := TPanel(TControl(Sender).Parent);
  DD := TDatabaseDirectory(Editor.Tag);

  PI := nil;
  try
    if SelectLocationForm.Execute(L('Select a directory'), DD.Path, PI, False) then
    begin
      LbInfo := Editor.FindChildByTag<TLabel>(CHANGE_DIRECTORY_INFO);
      LbInfo.Caption := PI.Path;
      DD.Path := PI.Path;
    end;
  finally
    F(PI);
  end;
end;

function TLinkListEditorUpdateDirectories.OnDelete(Sender: ILinkItemSelectForm;
  Data: TDataObject; Editor: TPanel): Boolean;
begin
  Result := True;
end;

procedure TLinkListEditorUpdateDirectories.SetForm(Form: IFormLinkItemEditorData);
var
  TopPanel: TPanel;
  Image: TImage;
  LbInfo: TLabel;
  Png: TPngImage;
begin
  FForm := Form;

  if FForm <> nil then
  begin
    TopPanel := Form.TopPanel;

    Image := TImage.Create(TopPanel);
    Image.Parent := TopPanel;

    Png := GetCollectionSyncImage;
    try
      Image.Picture.Graphic := Png;
      Image.Top := 8;
      Image.Left := 8;
      Image.Width := Png.Width;
      Image.Height := Png.Height;
    finally
      F(Png);
    end;

    LbInfo := TLabel.Create(TopPanel);
    LbInfo.Parent := TopPanel;
    LbInfo.Top := Image.Top + Image.Height + 8;
    LbInfo.Left := 8;
    LbInfo.Constraints.MaxWidth := Image.Width;
    LbInfo.Constraints.MinWidth := Image.Width;
    LbInfo.AutoSize := True;
    LbInfo.WordWrap := True;
    LbInfo.Caption := '   ' + L('Choose directories to synchronize with collection. All images in these directories will be automatically included to collection.');

    TopPanel.Height := LbInfo.Top + LbInfo.Height + 8;
  end;
end;

end.
