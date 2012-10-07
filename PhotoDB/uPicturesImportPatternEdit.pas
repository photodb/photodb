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

  Dmitry.Controls.WatermarkedMemo,

  uDBForm,
  uSettings,
  uConstants;

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
    procedure CustomFormAfterDisplay; override;
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

procedure TPicturesImportPatternEdit.CustomFormAfterDisplay;
begin
  inherited;
  if WmPatterns <> nil then
    WmPatterns.Refresh;
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
var
  InfoText: string;
begin
  BeginTranslate;
  try
    Caption := L('Edit directory fotmats');
    BtnOk.Caption := L('Ok');
    BtnCancel.Caption := L('Cancel');

    InfoText := 'Please use the following format for pattern list:';
    InfoText := InfoText + '$nl$' + '  Each line is a separated pattern';
    InfoText := InfoText + '$nl$' + '  YYYY - year as "2010"';
    InfoText := InfoText + '$nl$' + '  YY - year as "10"';
    InfoText := InfoText + '$nl$' + '  mmmm - month as "january"';
    InfoText := InfoText + '$nl$' + '  MMMM - month as "January"';
    InfoText := InfoText + '$nl$' + '  mmm - month as "january"';
    InfoText := InfoText + '$nl$' + '  MMM - month as "January"';
    InfoText := InfoText + '$nl$' + '  MM - month as "07"';
    InfoText := InfoText + '$nl$' + '  M - month as "7"';
    InfoText := InfoText + '$nl$' + '  ddd - day as "monday"';
    InfoText := InfoText + '$nl$' + '  DDD - day as "Monday"';
    InfoText := InfoText + '$nl$' + '  DD - day as "07"';
    InfoText := InfoText + '$nl$' + '  D - day as "7"';
    LbInfo.Caption := L(InfoText);

    WmPatterns.Top := LbInfo.Top + LbInfo.Height + 10;
    ClientHeight := WmPatterns.Top + 150 + 7 + BtnOk.Height + 5;
    WmPatterns.Height := 150;
  finally
    EndTranslate;
  end;
end;

procedure TPicturesImportPatternEdit.WmPatternsChange(Sender: TObject);
begin
  BtnOk.Enabled := WmPatterns.Lines.Count > 0;
end;

end.
