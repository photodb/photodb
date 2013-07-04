unit uFormSelectDuplicateDirectories;

interface

uses
  Generics.Collections,
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.Imaging.pngimage,
  Vcl.ExtCtrls,

  Dmitry.Utils.Files,
  Dmitry.Utils.System,
  Dmitry.PathProviders,
  Dmitry.PathProviders.MyComputer,

  uDBForm,
  uMemory,
  uFormInterfaces,
  uVCLHelpers;

type
  TFormSelectDuplicateDirectories = class(TDBForm, IFormSelectDuplicateDirectories)
    ImMain: TImage;
    LbInfo: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FSelectedFolder: string;
    procedure SelectDirectoryClick(Sender: TObject);
    procedure CancelDirectoriesSeletion(Sender: TObject);
  protected
    function GetFormID: string; override;
    procedure InterfaceDestroyed; override;
  public
    { Public declarations }
    function Execute(DirectoriesInfo: TList<string>): string;
  end;

var
  FormSelectDuplicateDirectories: TFormSelectDuplicateDirectories;

implementation

{$R *.dfm}

{ TFormSelectDuplicateDirectories }

procedure TFormSelectDuplicateDirectories.CancelDirectoriesSeletion(
  Sender: TObject);
begin
  Close;
end;

function TFormSelectDuplicateDirectories.Execute(
  DirectoriesInfo: TList<string>): string;
const
  Padding = 7;

var
  I: Integer;
  TopHeight: Integer;
  Button: TButton;
  Folder: string;
begin
  FSelectedFolder := '';
  DirectoriesInfo.Add('');
  TopHeight := ImMain.BoundsRect.Bottom + Padding;
  for I := 0 to DirectoriesInfo.Count - 1 do
  begin
    Folder := DirectoriesInfo[I];

    Button := TButton.Create(Self);
    Button.Parent := Self;
    Button.OnClick := SelectDirectoryClick;
    Button.Left := Padding;
    Button.Top := TopHeight;
    Button.Width := ClientWidth - Padding * 2;

    if IsWindowsVista then
    begin
      Button.Style := bsCommandLink;
      Button.Caption := ExtractFileName(Folder);

      if IsDrive(Folder) then
        Button.Caption := GetCDVolumeLabelEx(UpCase(Folder[1])) + ' (' + Folder[1] + ':)';

    end else
    begin
      Button.Style := bsPushButton;
      Button.Caption := Folder;
    end;
    Button.CommandLinkHint := Folder;

    if I = DirectoriesInfo.Count - 1 then
    begin
      if IsWindowsVista then
      begin
        Button.Caption := L('Cancel');
        Button.CommandLinkHint := L('Cancel pending operation');
      end else
      begin
        Button.Caption := L('Cancel pending operation');
        Button.CommandLinkHint := L('');
      end;

      Button.OnClick := CancelDirectoriesSeletion;
    end;

    Button.AdjustButtonHeight;

    Inc(TopHeight, Button.Height + Padding);
  end;

  ClientHeight := TopHeight;

  ShowModal;

  Result := FSelectedFolder;
end;

procedure TFormSelectDuplicateDirectories.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TFormSelectDuplicateDirectories.FormCreate(Sender: TObject);
begin
  Caption := L('Select directory with originals');
  LbInfo.Caption := L('Please select directory with original photos. Duplicate photos from other directories will be deleted.');
end;

procedure TFormSelectDuplicateDirectories.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

function TFormSelectDuplicateDirectories.GetFormID: string;
begin
  Result := 'DuplicatesSelectDirectory';
end;

procedure TFormSelectDuplicateDirectories.InterfaceDestroyed;
begin
  inherited;
  Release;
end;

procedure TFormSelectDuplicateDirectories.SelectDirectoryClick(Sender: TObject);
begin
  FSelectedFolder := TButton(Sender).CommandLinkHint;
  Close;
end;

initialization
  FormInterfaces.RegisterFormInterface(IFormSelectDuplicateDirectories, TFormSelectDuplicateDirectories);

end.
