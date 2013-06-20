unit uFormLinkItemEditor;

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
  Vcl.ExtCtrls,

  Dmitry.Utils.System,

  UnitDBDeclare,

  uMemory,
  uDBForm,
  uFormInterfaces;

type
  TFormLinkItemEditor = class(TDBForm, IFormLinkItemEditor, IFormLinkItemEditorData)
    PnEditorPanel: TPanel;
    BtnSave: TButton;
    BtnClose: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    FEditor: ILinkEditor;
    FData: TDataObject;
    procedure LoadEditControl;
  protected
    function GetFormID: string; override;
    procedure InterfaceDestroyed; override;
  public
    { Public declarations }
    function Execute(Title: string; Data: TDataObject; Editor: ILinkEditor): Boolean;
    function GetEditorData: TDataObject;
    function GetEditorPanel: TPanel;
    function GetTopPanel: TPanel;
    procedure ApplyChanges;
  end;

implementation

{$R *.dfm}

{ TFormLinkItemEditor }

procedure TFormLinkItemEditor.ApplyChanges;
begin
  Close;
  FEditor.UpdateItemFromEditor(nil, FData, Self);
  ModalResult := mrOk;
end;

procedure TFormLinkItemEditor.BtnCloseClick(Sender: TObject);
begin
  Close;
  ModalResult := mrCancel;
end;

procedure TFormLinkItemEditor.BtnSaveClick(Sender: TObject);
begin
  ApplyChanges;
end;

function TFormLinkItemEditor.Execute(Title: string; Data: TDataObject; Editor: ILinkEditor): Boolean;
begin
  Caption := Title;
  FEditor := Editor;
  FData := Data;

  FEditor.SetForm(Self);
  LoadEditControl;

  Result := ModalResult = mrOk;
end;

procedure TFormLinkItemEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FEditor.SetForm(nil);
  Action := caHide;
end;

procedure TFormLinkItemEditor.FormCreate(Sender: TObject);
begin
  if IsWindowsVista then
    Font.Name := 'MyriadPro-Regular';

  BtnClose.Caption := L('Cancel', '');
  BtnSave.Caption := L('Save', '');
end;

procedure TFormLinkItemEditor.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

function TFormLinkItemEditor.GetEditorData: TDataObject;
begin
  Result := FData;
end;

function TFormLinkItemEditor.GetEditorPanel: TPanel;
begin
  Result := PnEditorPanel;
end;

function TFormLinkItemEditor.GetFormID: string;
begin
  Result := 'FormLinkItemEditor';
end;

function TFormLinkItemEditor.GetTopPanel: TPanel;
begin
  Result := nil;
end;

procedure TFormLinkItemEditor.InterfaceDestroyed;
begin
  inherited;
  Release;
end;

procedure TFormLinkItemEditor.LoadEditControl;
const
  PaddingTop = 8;
var
  ToWidth, ToHeight: Integer;
begin
  PnEditorPanel.Tag := NativeInt(FData);
  PnEditorPanel.HandleNeeded;
  PnEditorPanel.AutoSize := True;
  FEditor.CreateEditorForItem(nil, FData, Self);
  PnEditorPanel.Left := 8;
  PnEditorPanel.Top := 8;

  ToWidth := PnEditorPanel.Left + PnEditorPanel.Width + PaddingTop * 2;
  ToHeight := PnEditorPanel.Top + PnEditorPanel.Height + PaddingTop + BtnClose.Height + PaddingTop;

  ClientWidth := ToWidth;
  ClientHeight := ToHeight;

  PnEditorPanel.Show;

  ShowModal;
end;

initialization
  FormInterfaces.RegisterFormInterface(IFormLinkItemEditor, TFormLinkItemEditor);

end.
