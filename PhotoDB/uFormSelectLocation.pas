unit uFormSelectLocation;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,

  Dmitry.Controls.PathEditor,
  Dmitry.PathProviders,
  Dmitry.PathProviders.MyComputer,

  VirtualTrees,

  uMemory,
  uThreadForm,
  uFormInterfaces,
  uPathProvideTreeView;

type
  TFormSelectLocation = class(TThreadForm, ISelectLocationForm)
    PePath: TPathEditor;
    PnExplorer: TPanel;
    BtnCancel: TButton;
    BtnOk: TButton;
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure PePathChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FShellTreeView: TPathProvideTreeView;
    procedure PathTreeViewChange(Sender: TCustomVirtualDrawTree; PathItem: TPathItem);
  protected
    procedure InterfaceDestroyed; override;
    function GetFormID: string; override;
  public
    { Public declarations }
    function Execute(Title, StartPath: string; out PathItem: TPathItem): Boolean;
  end;

implementation

{$R *.dfm}

{ TFormSelectLocation }

procedure TFormSelectLocation.BtnCancelClick(Sender: TObject);
begin
  Close;
  ModalResult := mrCancel;
end;

procedure TFormSelectLocation.BtnOkClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;

function TFormSelectLocation.Execute(Title, StartPath: string;
  out PathItem: TPathItem): Boolean;
var
  StartItem: TPathItem;
begin
  PathItem := nil;

  StartItem := PathProviderManager.CreatePathItem(StartPath);
  try
    if StartItem <> nil then
      PePath.SetPathEx(Self, StartItem, True)
    else
      PePath.SetPathEx(THomeItem, '');
  finally
    F(StartItem);
  end;

  if Title <> '' then
    Caption := Title;

  ShowModal;

  Result := ModalResult = mrOk;
  if Result then
    PathItem := PePath.PathEx.Copy;

  F(FShellTreeView);
end;

procedure TFormSelectLocation.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TFormSelectLocation.FormCreate(Sender: TObject);
begin
  FShellTreeView := TPathProvideTreeView.Create(Self);
  FShellTreeView.Parent := PnExplorer;
  FShellTreeView.Align := AlClient;
  FShellTreeView.LoadHomeDirectory(Self);
  FShellTreeView.OnSelectPathItem := PathTreeViewChange;

  BtnCancel.Caption := L('Cancel');
  BtnOk.Caption := L('Ok');
end;

procedure TFormSelectLocation.FormDestroy(Sender: TObject);
begin
  F(FShellTreeView);
end;

function TFormSelectLocation.GetFormID: string;
begin
  Result := 'SelectLocation';
end;

procedure TFormSelectLocation.InterfaceDestroyed;
begin
  inherited;
  Release;
end;

procedure TFormSelectLocation.PathTreeViewChange(Sender: TCustomVirtualDrawTree;
  PathItem: TPathItem);
begin
  PePath.SetPathEx(Sender, PathItem, False);
end;

procedure TFormSelectLocation.PePathChange(Sender: TObject);
begin
  FShellTreeView.SelectPathItem(PePath.PathEx);
end;

initialization
  FormInterfaces.RegisterFormInterface(ISelectLocationForm, TFormSelectLocation);

end.
