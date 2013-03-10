unit uLinkListEditorFolders;

interface

uses
  Generics.Collections,
  Winapi.Windows,
  System.SysUtils,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Graphics,

  Dmitry.Controls.WatermarkedEdit,
  Dmitry.Controls.WebLink,
  Dmitry.PathProviders,

  UnitDBDeclare,

  uMemory,
  uDBForm,
  uVCLHelpers,
  uFormInterfaces,
  uShellIntegration,
  uIconUtils;

type
  TLinkInfo = class(TDataObject)
  public
    Title: string;
    Path: string;
    Icon: string;
    constructor Create(Title: string; Path: string; Icon: string);
    function Clone: TDataObject; override;
    procedure Assign(Source: TDataObject); override;
  end;

  TLinkListEditorFolder = class(TInterfacedObject, ILinkEditor)
  private
    FOwner: TDBForm;
    FCurrentPath: string;
    procedure LoadIconForLink(Link: TWebLink; Path, Icon: string);
    procedure OnPlaceIconClick(Sender: TObject);
    procedure OnChangePlaceClick(Sender: TObject);
  public
    constructor Create(Owner: TDBForm; CurrentPath: string);
    procedure CreateNewItem(Sender: ILinkItemSelectForm; var Data: TDataObject; Verb: string; Elements: TListElements);
    procedure CreateEditorForItem(Sender: ILinkItemSelectForm; Data: TDataObject; Editor: TPanel);
    procedure UpdateItemFromEditor(Sender: ILinkItemSelectForm; Data: TDataObject; Editor: TPanel);
    procedure FillActions(Sender: ILinkItemSelectForm; AddActionProc: TAddActionProcedure);
    function OnDelete(Sender: ILinkItemSelectForm; Data: TDataObject; Editor: TPanel): Boolean;
    function OnApply(Sender: ILinkItemSelectForm): Boolean;
  end;

implementation

const
  CHANGE_PLACE_ICON        = 1;
  CHANGE_PLACE_EDIT        = 2;
  CHANGE_PLACE_CHANGE_PATH = 3;
  CHANGE_PLACE_INFO        = 4;

{ TLinkInfo }

procedure TLinkInfo.Assign(Source: TDataObject);
var
  SI: TLinkInfo;
begin
  SI := Source as TLinkInfo;
  if SI <> nil then
  begin
    Title := SI.Title;
    Path := SI.Path;
    Icon := SI.Icon;
  end;
end;

function TLinkInfo.Clone: TDataObject;
begin
  Result := TLinkInfo.Create(Title, Path, Icon);
end;

constructor TLinkInfo.Create(Title, Path, Icon: string);
begin
  Self.Title := Title;
  Self.Path := Path;
  Self.Icon := Icon;
end;

{ TLinkListEditorFolder }

constructor TLinkListEditorFolder.Create(Owner: TDBForm; CurrentPath: string);
begin
  FOwner := Owner;
  FCurrentPath := CurrentPath;
end;

procedure TLinkListEditorFolder.CreateEditorForItem(Sender: ILinkItemSelectForm;
  Data: TDataObject; Editor: TPanel);
var
  LI: TLinkInfo;
  WlIcon: TWebLink;
  WlChangeLocation: TWebLink;
  WedCaption: TWatermarkedEdit;
  LbInfo: TLabel;
begin
  LI := TLinkInfo(Data);

  WlIcon := Editor.FindChildByTag<TWebLink>(CHANGE_PLACE_ICON);
  WedCaption :=  Editor.FindChildByTag<TWatermarkedEdit>(CHANGE_PLACE_EDIT);
  WlChangeLocation := Editor.FindChildByTag<TWebLink>(CHANGE_PLACE_CHANGE_PATH);
  LbInfo := Editor.FindChildByTag<TLabel>(CHANGE_PLACE_INFO);

  if WedCaption = nil then
  begin
    WedCaption := TWatermarkedEdit.Create(Editor);
    WedCaption.Parent := Editor;
    WedCaption.Tag := CHANGE_PLACE_EDIT;
    WedCaption.Top := 8;
    WedCaption.Left := 35;
    WedCaption.Width := 200;
  end;

  if WlIcon = nil then
  begin
    WlIcon := TWebLink.Create(Editor);
    WlIcon.Parent := Editor;
    WlIcon.Tag := CHANGE_PLACE_ICON;
    WlIcon.Width := 16;
    WlIcon.Height := 16;
    WlIcon.Left := 8;
    WlIcon.Top := 8 + WedCaption.Height div 2 - WlIcon.Height div 2;
    WlIcon.OnClick := OnPlaceIconClick;
  end;

  if WlChangeLocation = nil then
  begin
    WlChangeLocation := TWebLink.Create(Editor);
    WlChangeLocation.Parent := Editor;
    WlChangeLocation.Tag := CHANGE_PLACE_CHANGE_PATH;
    WlChangeLocation.Height := 26;
    WlChangeLocation.Text := FOwner.L('Change location');
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
    LbInfo.Tag := CHANGE_PLACE_INFO;
    LbInfo.Left := 35;
    LbInfo.Top := 35;
  end;

  LoadIconForLink(WlIcon, LI.Path, LI.Icon);

  WedCaption.Text := LI.Title;
  LbInfo.Caption := LI.Path;
end;

procedure TLinkListEditorFolder.CreateNewItem(Sender: ILinkItemSelectForm;
  var Data: TDataObject; Verb: string; Elements: TListElements);
var
  LI: TLinkInfo;
  PI: TPathItem;
  Link: TWebLink;
  Info: TLabel;
begin
  if Data = nil then
  begin

    PI := nil;
    try
      if Verb = 'Add' then
      begin
        if SelectLocationForm.Execute(FOwner.L('Select a directory'), '', PI) then
          Data := TLinkInfo.Create(PI.DisplayName, PI.Path, '');
      end else
      begin
        PI := PathProviderManager.CreatePathItem(FCurrentPath);
        if PI <> nil then
          Data := TLinkInfo.Create(PI.DisplayName, PI.Path, '');
      end;
    finally
      F(PI);
    end;

    Exit;
  end;
  LI := TLinkInfo(Data);

  Link := TWebLink(Elements[leWebLink]);
  Info := TLabel(Elements[leInfoLabel]);

  Link.Text := LI.Title;
  Info.Caption := LI.Path;
  Info.EllipsisPosition := epPathEllipsis;

  LoadIconForLink(Link, LI.Path, LI.Icon);
end;

procedure TLinkListEditorFolder.FillActions(Sender: ILinkItemSelectForm;
  AddActionProc: TAddActionProcedure);
var
  PI: TPathItem;
begin
  AddActionProc(['Add', 'CurrentDirectory'],
    procedure(Action: string; WebLink: TWebLink)
    begin
      if Action = 'Add' then
      begin
        WebLink.Text := FOwner.L('Add directory');
        WebLink.LoadFromResource('SERIES_EXPAND');
      end;

      if Action = 'CurrentDirectory' then
      begin
        WebLink.Text := FOwner.L('Current directory');
        PI := PathProviderManager.CreatePathItem(FCurrentPath);
        try
          if (PI <> nil) and PI.LoadImage(PATH_LOAD_FOR_IMAGE_LIST, 16) then
            WebLink.LoadFromPathImage(PI.Image)
          else
            WebLink.LoadFromResource('DIRECTORY');
        finally
          F(PI);
        end;
      end;
    end
  );
end;

procedure TLinkListEditorFolder.LoadIconForLink(Link: TWebLink; Path, Icon: string);
var
  Ico: HIcon;
  PI: TPathItem;
begin
  if Icon <> '' then
  begin
    Ico := ExtractSmallIconByPath(Icon);
    try
      Link.LoadFromHIcon(Ico);
    finally
      DestroyIcon(Ico);
    end;
  end else
  begin
    PI := PathProviderManager.CreatePathItem(Path);
    try
      if (PI <> nil) and PI.LoadImage(PATH_LOAD_NORMAL or PATH_LOAD_FAST or PATH_LOAD_FOR_IMAGE_LIST, 16) and (PI.Image <> nil) then
        Link.LoadFromPathImage(PI.Image);

    finally
      F(PI);
    end;
  end;
end;

procedure TLinkListEditorFolder.UpdateItemFromEditor(
  Sender: ILinkItemSelectForm; Data: TDataObject; Editor: TPanel);
var
  LI: TLinkInfo;
  WedCaption: TWatermarkedEdit;
begin
  LI := TLinkInfo(Data);

  WedCaption := Editor.FindChildByTag<TWatermarkedEdit>(CHANGE_PLACE_EDIT);

  LI.Assign(Sender.EditorData);
  LI.Title := WedCaption.Text;
end;

function TLinkListEditorFolder.OnApply(Sender: ILinkItemSelectForm): Boolean;
begin
  Result := True;
end;

procedure TLinkListEditorFolder.OnChangePlaceClick(Sender: TObject);
var
  LI: TLinkInfo;
  LbInfo: TLabel;
  Editor: TPanel;
  PI: TPathItem;
begin
  Editor := TPanel(TControl(Sender).Parent);
  LI := TLinkInfo(Editor.Tag);

  PI := nil;
  try
    if SelectLocationForm.Execute('Select a directory', LI.Path, PI) then
    begin
      LbInfo := Editor.FindChildByTag<TLabel>(CHANGE_PLACE_INFO);
      LbInfo.Caption := PI.Path;
      LI.Path := PI.Path;
    end;
  finally
    F(PI);
  end;
end;

function TLinkListEditorFolder.OnDelete(Sender: ILinkItemSelectForm;
  Data: TDataObject; Editor: TPanel): Boolean;
begin
  Result := True;
end;

procedure TLinkListEditorFolder.OnPlaceIconClick(Sender: TObject);
var
  LI: TLinkInfo;
  Icon: string;
  Editor: TPanel;
  WlIcon: TWebLink;
begin
  Editor := TPanel(TControl(Sender).Parent);
  LI := TLinkInfo(Editor.Tag);

  Icon := LI.Icon;
  if ChangeIconDialog(0, Icon) then
  begin
    LI.Icon := Icon;
    WlIcon := Editor.FindChildByTag<TWebLink>(CHANGE_PLACE_ICON);
    LoadIconForLink(WlIcon, LI.Path, LI.Icon);
  end;
end;

end.
