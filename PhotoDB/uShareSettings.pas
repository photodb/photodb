unit uShareSettings;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  uMemoryEx,
  uDBForm,
  Vcl.StdCtrls,
  uBaseWinControl,
  WebLink,
  uAssociations,
  uTranslate;

type
  TFormShareSettings = class(TDBForm)
    BtnOk: TButton;
    BtnCancel: TButton;
    CbOutputFormat: TComboBox;
    LbOutputFormat: TLabel;
    WlJpegSettings: TWebLink;
    CbPreviewForRAW: TCheckBox;
    LbImageSize: TLabel;
    ComboBox1: TComboBox;
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure LoadLanguage;
  protected
    { Protected declarations }
    function GetFormID: string; override;
  public
    { Public declarations }
  end;

function ShowShareSettings: Boolean;

implementation

{$R *.dfm}

function ShowShareSettings: Boolean;
var
  FormShareSettings: TFormShareSettings;
begin
  FormShareSettings := TFormShareSettings.Create(Screen.ActiveForm);
  try
    FormShareSettings.ShowModal;
    Result := FormShareSettings.ModalResult = mrOk;
  finally
    R(FormShareSettings);
  end;
end;

procedure TFormShareSettings.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormShareSettings.BtnOkClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;

procedure TFormShareSettings.FormCreate(Sender: TObject);
begin
  LoadLanguage;
  CbOutputFormat.Items.Add(TA(TFileAssociations.Instance.Exts['.jpg'].Description, 'Associations'));
  CbOutputFormat.Items.Add(TA(TFileAssociations.Instance.Exts['.png'].Description, 'Associations'));
  CbOutputFormat.ItemIndex := 0;
end;

function TFormShareSettings.GetFormID: string;
begin
  Result := 'PhotoShare';
end;

procedure TFormShareSettings.LoadLanguage;
begin
  BeginTranslate;
  try
    BtnOk.Caption := L('Ok');
    BtnCancel.Caption := L('Cancel');
  finally
    EndTranslate;
  end;
end;

end.
