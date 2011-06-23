unit uFrmLanguage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uDBForm, uInstallUtils, uMemory, uConstants, uInstallTypes,
  StrUtils, uTranslate, uLogger, pngimage, uInstallZip, uSysUtils, uLangUtils,
  Registry, uInstallRuntime;

type
  TLanguageItem = class(TObject)
  public
    Name: string;
    Code: string;
    Image: TPngImage;
    LangCode: Integer;
    constructor Create;
    destructor Destroy; override;
  end;

  TFormLanguage = class(TDBForm)
    LbLanguages: TListBox;
    BtnOk: TButton;
    LbInfo: TLabel;
    lbVersion: TLabel;
    procedure LbLanguagesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LbLanguagesDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure LbLanguagesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BtnOkClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure LbLanguagesDblClick(Sender: TObject);
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

procedure LoadLanguageFromSetupData(var Language : TLanguage; var LanguageCode : string);
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

procedure TFormLanguage.BtnOkClick(Sender: TObject);
begin
  LbLanguagesClick(Sender);
  ModalResult := idOk;
  Hide;
end;

procedure TFormLanguage.FormCreate(Sender: TObject);
begin
  LanguageInitCallBack := LoadLanguageFromSetupData;
  LoadLanguageList;
  LoadLanguage;
end;

procedure TFormLanguage.FormDestroy(Sender: TObject);
var
  I : Integer;
begin
  for I := 0 to LbLanguages.Count - 1 do
    LbLanguages.Items.Objects[I].Free;
end;

procedure TFormLanguage.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    BtnOkClick(Sender);
  if Key = VK_ESCAPE then
    Close;
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
    TTranslateManager.Instance.Language := TLanguageItem(LbLanguages.Items.Objects[SelectedIndex]).Code;
    LoadLanguage;
  end;
  LbLanguages.Refresh;
end;

procedure TFormLanguage.LbLanguagesDblClick(Sender: TObject);
var
  Pos : TPoint;
  Index : Integer;
begin
  GetCursorPos(Pos);
  Pos := LbLanguages.ScreenToClient(Pos);
  Index := LbLanguages.ItemAtPos(Pos, True);
  if (Index > -1) and (Index < LbLanguages.Count) then
     BtnOkClick(Sender);
end;

procedure TFormLanguage.LbLanguagesDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Language : TLanguageItem;
  Bitmap : TBitmap;
  PngBitmap : TBitmap;
  BackColor : TColor;
begin
  if Index < 0 then
    Exit;

  Language := TLanguageItem(LbLanguages.Items.Objects[Index]);

  Bitmap := TBitmap.Create;
  Bitmap.PixelFormat := pf24Bit;
  try
    Bitmap.Width := Rect.Right - Rect.Left;
    Bitmap.Height := Rect.Bottom - Rect.Top;
    if LbLanguages.Selected[Index] then
      BackColor := clHighlight
    else
      BackColor := clWindow;

    Bitmap.Canvas.Pen.Color := BackColor;
    Bitmap.Canvas.Brush.Color := BackColor;
    Bitmap.Canvas.Rectangle(0, 0, Bitmap.Width, Bitmap.Height);
    if LbLanguages.Selected[Index] then
      Bitmap.Canvas.Font.Color := clHighlightText
    else
      Bitmap.Canvas.Font.Color := clWindowText;

    Bitmap.Canvas.TextOut(Language.Image.Width + 6, Bitmap.Height div 2 - Bitmap.Canvas.TextHeight(Language.Name) div 2, Language.Name);

    PngBitmap := TBitmap.Create;
    try
      PngBitmap.PixelFormat := pf24bit;
      Language.Image.Draw(Bitmap.Canvas, Classes.Rect(2, 2, 2 + Language.Image.Width, 2 + Language.Image.Height));
    finally
      F(PngBitmap);
    end;

    LbLanguages.Canvas.Draw(Rect.Left, Rect.Top, Bitmap);
  finally
    F(Bitmap);
  end;
end;

procedure TFormLanguage.LbLanguagesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  LbLanguages.Refresh;
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
  MS: TMemoryStream;
  FileList: TStrings;
  Size: Int64;
  I: Integer;
  LangCode: Integer;
  Language: TLanguage;
  LangItem: TLanguageItem;
  ImageStream: TMemoryStream;
  PNG: TPNGImage;
  Reg: TRegistry;
  CurentLanguage: string;
begin
  CurentLanguage := '';
  if IsApplicationInstalled then
  begin
    Reg := TRegistry.Create(KEY_READ);
    try
      Reg.RootKey := Windows.HKEY_LOCAL_MACHINE;
      Reg.OpenKey(RegRoot, False);
      CurentLanguage := Reg.ReadString('Language');
    finally
      F(Reg);
    end;
  end;

  LbLanguages.Clear;
  MS := TMemoryStream.Create;
  try
    GetRCDATAResourceStream(SetupDataName, MS);
    InstallVersion := StringToRelease(ReadFileContent(MS, 'VERSION.INFO'));
    lbVersion.Caption := ReleaseToString(InstallVersion);
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
            ImageStream := TMemoryStream.Create;
            try
              LangItem := TLanguageItem.Create;
              ExtractStreamFromStorage(MS, ImageStream, Language.ImageName, nil);
              PNG := TPNGImage.Create;
              try
                ImageStream.Seek(0, soFromBeginning);
                PNG.LoadFromStream(ImageStream);
                LangItem.Image := PNG;
                PNG := nil;
              finally
                F(PNG);
              end;
              LangItem.Name := Language.Name;
              LangItem.Code := StringReplace(StringReplace(FileList[I], LanguageFileMask, '', []), ExtractFileExt(FileList[I]), '', []);
              LangItem.LangCode := Language.LangCode;
              LbLanguages.Items.AddObject(Language.Name, LangItem);
            finally
              F(ImageStream);
            end;
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
  LbLanguages.Selected[0] := True;

  if CurentLanguage = '' then
  begin
    LangCode := PrimaryLangID(GetUserDefaultUILanguage);
    for I := 0 to LbLanguages.Items.Count - 1 do
      if TLanguageItem(LbLanguages.Items.Objects[I]).LangCode = LangCode then
      begin
        LbLanguages.Selected[I] := True;
        LbLanguagesClick(Self);
      end;
  end else
  begin
    for I := 0 to LbLanguages.Items.Count - 1 do
      if AnsiLowerCase(TLanguageItem(LbLanguages.Items.Objects[I]).Code) = AnsiLowerCase(CurentLanguage) then
      begin
        LbLanguages.Selected[I] := True;
        LbLanguagesClick(Self);
      end;
  end;
  LoadLanguage;
end;

{ TLangageItem }

constructor TLanguageItem.Create;
begin
  Image := nil;
end;

destructor TLanguageItem.Destroy;
begin
  F(Image);
  inherited;
end;

end.
