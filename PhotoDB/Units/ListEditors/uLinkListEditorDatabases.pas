unit uLinkListEditorDatabases;

interface

uses
  Generics.Collections,
  Winapi.Windows,
  System.SysUtils,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,

  Dmitry.Controls.Base,
  Dmitry.Controls.WatermarkedEdit,
  Dmitry.Controls.WebLink,

  UnitDBFileDialogs,

  uMemory,
  uVclHelpers,
  uIconUtils,
  uShellIntegration,
  uFormInterfaces;

type
  TDatabaseInfo = class(TDataObject)
  public
    Title: string;
    Path: string;
    Icon: string;
    Description: string;
    constructor Create(Title, Path, Icon, Description: string);
    function Clone: TDataObject; override;
    procedure Assign(Source: TDataObject); override;
  end;

  TLinkListEditorDatabases = class(TInterfacedObject, ILinkEditor)
  private
    procedure LoadIconForLink(Link: TWebLink; Path, Icon: string);
    procedure OnPlaceIconClick(Sender: TObject);
    procedure OnChangePlaceClick(Sender: TObject);
  public
    procedure CreateNewItem(Sender: ILinkItemSelectForm; var Data: TDataObject; Verb: string; Elements: TListElements);
    procedure CreateEditorForItem(Sender: ILinkItemSelectForm; Data: TDataObject; Editor: TPanel);
    procedure UpdateItemFromEditor(Sender: ILinkItemSelectForm; Data: TDataObject; Editor: TPanel);
    procedure FillActions(Sender: ILinkItemSelectForm; AddActionProc: TAddActionProcedure);
  end;

implementation

const
  CHANGE_DB_ICON          = 1;
  CHANGE_DB_CAPTION_EDIT  = 2;
  CHANGE_DB_CHANGE_PATH   = 3;
  CHANGE_DB_PATH          = 4;
  CHANGE_DB_DESC_EDIT     = 5;
  CHANGE_DB_DESC_LABEL    = 6;

{ TDatabaseInfo }

procedure TDatabaseInfo.Assign(Source: TDataObject);
var
  DI: TDatabaseInfo;
begin
  DI := Source as TDatabaseInfo;
  if DI <> nil then
  begin
    Title := DI.Title;
    Path := DI.Path;
    Icon := DI.Icon;
    Description := DI.Description;
  end;
end;


function TDatabaseInfo.Clone: TDataObject;
begin
  Result := TDatabaseInfo.Create(Title, Path, Icon, Description);
end;

constructor TDatabaseInfo.Create(Title, Path, Icon, Description: string);
begin
  Self.Title := Title;
  Self.Path := Path;
  Self.Icon := Icon;
  Self.Description := Description;
end;

{ TLinkListEditorDatabases }

procedure TLinkListEditorDatabases.CreateEditorForItem(
  Sender: ILinkItemSelectForm; Data: TDataObject; Editor: TPanel);
begin

end;

procedure TLinkListEditorDatabases.CreateNewItem(Sender: ILinkItemSelectForm;
  var Data: TDataObject; Verb: string; Elements: TListElements);
var
  Link: TWebLink;
  Info: TLabel;
  DI: TDatabaseInfo;
  OpenDialog: DBOpenDialog;
begin
  if Data = nil then
  begin

    OpenDialog := DBOpenDialog.Create;
    try
      OpenDialog.Filter := ('Databases (*.photodb)|*.photodb');
      OpenDialog.FilterIndex := 1;
      if OpenDialog.Execute then
        Data := TDatabaseInfo.Create(ExtractFileName(OpenDialog.FileName), OpenDialog.FileName, OpenDialog.FileName + ',0', '%1');

    finally
      F(OpenDialog);
    end;

    Exit;
  end;
  DI := TDatabaseInfo(Data);

  Link := TWebLink(Elements[leWebLink]);
  Info := TLabel(Elements[leInfoLabel]);

  Link.Text := DI.Title;
  Info.Caption := DI.Path;
  Info.EllipsisPosition := epPathEllipsis;

  LoadIconForLink(Link, DI.Path, DI.Icon);
end;

procedure TLinkListEditorDatabases.FillActions(Sender: ILinkItemSelectForm;
  AddActionProc: TAddActionProcedure);
begin
  AddActionProc(['Create', 'Open'],
    procedure(Action: string; WebLink: TWebLink)
    begin
      WebLink.Text := Action;
    end
  );
end;

procedure TLinkListEditorDatabases.LoadIconForLink(Link: TWebLink; Path, Icon: string);
var
  Ico: HIcon;
begin
  if Icon <> '' then
    Ico := ExtractSmallIconByPath(Icon)
  else
    Ico := ExtractAssociatedIconSafe(Path);
  try
    Link.LoadFromHIcon(Ico);
  finally
    DestroyIcon(Ico);
  end;
end;

procedure TLinkListEditorDatabases.OnChangePlaceClick(Sender: TObject);
begin

end;

procedure TLinkListEditorDatabases.OnPlaceIconClick(Sender: TObject);
var
  DI: TDatabaseInfo;
  LbInfo: TLabel;
  Editor: TPanel;
  OpenDialog: DBOpenDialog;
begin
  Editor := TPanel(TControl(Sender).Parent);
  DI := TDatabaseInfo(Editor.Tag);

  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter := ('Programs (*.photodb)|*.photodb');
    OpenDialog.FilterIndex := 1;
    if OpenDialog.Execute then
    begin
      LbInfo := Editor.FindChildByTag<TLabel>(CHANGE_DB_PATH);
      LbInfo.Caption := OpenDialog.FileName;
      DI.Path := OpenDialog.FileName;
    end;

  finally
    F(OpenDialog);
  end;
end;

procedure TLinkListEditorDatabases.UpdateItemFromEditor(
  Sender: ILinkItemSelectForm; Data: TDataObject; Editor: TPanel);
begin

end;

end.
