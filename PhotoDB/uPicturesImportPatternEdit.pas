unit uPicturesImportPatternEdit;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  uDBForm,
  uSettings,
  uConstants,
  WatermarkedMemo;

type
  TPicturesImportPatternEdit = class(TDBForm)
    WmPatterns: TWatermarkedMemo;
    ImInfo: TImage;
    LbInfo: TLabel;
    BtnOk: TButton;
    BtnCancel: TButton;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure WmPatternsChange(Sender: TObject);
  private
    { Private declarations }
    procedure LoadLanguage;
  protected
    { Protected declarations }
    function GetFormID: string; override;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

{ TPicturesImportPatternEdit }

procedure TPicturesImportPatternEdit.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TPicturesImportPatternEdit.BtnOkClick(Sender: TObject);
begin
  if WmPatterns.Lines.Count > 0 then
  begin
    Settings.WriteString('ImportPictures', 'PatternList', WmPatterns.Text);
    Close;
    ModalResult := mrOk;
  end;
end;

procedure TPicturesImportPatternEdit.FormCreate(Sender: TObject);
begin
  LoadLanguage;
  WmPatterns.Lines.Text := Settings.ReadString('ImportPictures', 'PatternList', DefaultImportPatternList);
end;

function TPicturesImportPatternEdit.GetFormID: string;
begin
  Result := 'ImportPictures';
end;

procedure TPicturesImportPatternEdit.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Edit directory fotmats');
    BtnOk.Caption := L('Ok');
    BtnCancel.Caption := L('Cancel');

  finally
    EndTranslate;
  end;
end;

procedure TPicturesImportPatternEdit.WmPatternsChange(Sender: TObject);
begin
  BtnOk.Enabled := WmPatterns.Lines.Count > 0;
end;

end.
