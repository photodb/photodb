unit uFrmLanguage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uDBForm, uInstallUtils, uMemory, uConstants, uInstallTypes,
  StrUtils, uTranslate, uLogger;

type
  TLangageItem = class(TObject)
  public
    Name : string;
    Code : string;
  end;

  TFormLanguage = class(TDBForm)
    LbLanguages: TListBox;
    BtnOk: TButton;
    LbInfo: TLabel;
    procedure LbLanguagesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure LoadLanguage;
    procedure LoadLanguageList;
  protected
    { Protected declarations }
    function GetFormID : string; override;
  public
    { Public declarations }
  end;

var
  FormLanguage: TFormLanguage;

implementation

{$R *.dfm}

procedure LoadLanguageFromSetupData(var Language : TLanguage; LanguageCode : string);
var
  LanguageFileName : string;
  MS : TMemoryStream;
begin
  if LanguageCode = '--' then
    LanguageCode := 'EN';

  LanguageFileName := Format('%s%s.xml', [LanguageFileMask, LanguageCode]);
  try
    MS := TMemoryStream.Create;
    try
      GetRCDATAResourceStream(SetupDataName, MS);
      Language := TLanguage.CreateFromXML(ReadFileContent(MS, LanguageFileName));
    finally
      F(MS);
    end;
  except
    on e : Exception do
      EventLog(e.Message);
  end;
end;

{ TFormLanguage }

procedure TFormLanguage.FormCreate(Sender: TObject);
begin
  LanguageInitCallBack := LoadLanguageFromSetupData;
  LoadLanguageList;
  LoadLanguage;
end;

function TFormLanguage.GetFormID: string;
begin
  Result := 'InstallLanguage';
end;

procedure TFormLanguage.LbLanguagesClick(Sender: TObject);
var
  I : Integer;
  SelectedIndex : Integer;
begin
  SelectedIndex := -1;
  for I := 0 to LbLanguages.Count - 1 do
    if LbLanguages.Selected[I] then
      SelectedIndex := I;

  if (SelectedIndex > -1) then
  begin
    TTranslateManager.Instance.Language := TLangageItem(LbLanguages.Items.Objects[SelectedIndex]).Code;
    LoadLanguage;
  end;
end;

procedure TFormLanguage.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Select language');
    BtnOk.Caption := L('Ok');
    LbInfo.Caption := L('Please, select language of PhotoDB install') + ':';
  finally
    EndTranslate;
  end;
end;

procedure TFormLanguage.LoadLanguageList;
var
  MS : TMemoryStream;
  FileList : TStrings;
  Size : Int64;
  I : Integer;
  Language : TLanguage;
  LangItem : TLangageItem;
begin
  LbLanguages.Clear;
  MS := TMemoryStream.Create;
  try
    GetRCDATAResourceStream(SetupDataName, MS);
    FileList := TStringList.Create;
    try
      FillFileList(MS, FileList, Size);
      //try to find language xml files
      for I := 0 to FileList.Count - 1 do
      begin
        if StartsStr(LanguageFileMask, FileList[I]) and EndsStr('.xml', FileList[I]) then
        begin
          Language := TLanguage.CreateFromXML(ReadFileContent(MS, FileList[I]));
          try
            LangItem := TLangageItem.Create;
            LangItem.Name := Language.Name;
            LangItem.Code := StringReplace(StringReplace(FileList[I], LanguageFileMask, '', []), ExtractFileExt(FileList[I]), '', []);
            LbLanguages.Items.AddObject(Language.Name, LangItem);
          finally
            F(Language);
          end;
        end;
      end;
    finally
      F(FileList);
    end;
  finally
    F(MS);
  end;
  LoadLanguage;
end;

end.
