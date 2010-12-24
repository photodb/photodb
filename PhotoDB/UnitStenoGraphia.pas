unit UnitStenoGraphia;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, ExtDlgs, ExtCtrls, SaveInfoToImage, ShlObj, UnitDBKernel,
  Dolphin_DB, Math, ImageConverting, PngImage, GraphicEx, uVistaFuncs,
  GraphicCrypt, UnitDBFileDialogs, UnitCDMappingSupport, uFileUtils, uMemory,
  uShellIntegration, uDBForm;

type
  TFormSteno = class(TDBForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Panel1: TPanel;
    Image1: TImage;
    Memo1: TMemo;
    PopupMenu1: TPopupMenu;
    LoadFromFile1: TMenuItem;
    AddInfo1: TMenuItem;
    OpenDialog1: TOpenDialog;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label6: TLabel;
    ComboBox1: TComboBox;
    Label7: TLabel;
    procedure Button3Click(Sender: TObject);
    procedure OpenDialog1IncludeItem(const OFN: TOFNotifyEx;
      var Include: Boolean);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    function LoadInfoFromFile(FileName: String) : boolean;
    procedure LoadImage(FileName: String; CloseIfOk : boolean = false);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    PictureFileName, FileName: string;
    ImagePassword: string;
    MaxFileSize: Integer;
    NormalFileSize: Integer;
    GoodFileSize: Integer;
    function GetMaxFileSize: Integer;
    procedure LoadLanguage;
  public
    { Public declarations }
    ImageSaved: Boolean;
  end;

procedure DoDesteno(InitialFileName: string);
procedure DoSteno(InitialFileName: string);

implementation

uses UnitPasswordForm, UnitCryptImageForm, Language;

{$R *.dfm}

procedure DoDesteno(InitialFileName : string);
var
  FormSteno: TFormSteno;
begin
  Application.CreateForm(TFormSteno, FormSteno);
  try
    FormSteno.LoadInfoFromFile(ProcessPath(InitialFileName));
  finally
    FormSteno.Release;
  end;
end;

procedure DoSteno(InitialFileName : string);
var
  FormSteno: TFormSteno;
begin
  Application.CreateForm(TFormSteno, FormSteno);
  try
    FormSteno.LoadImage(ProcessPath(InitialFileName), True);
    if not FormSteno.ImageSaved then
      FormSteno.ShowModal;
  finally
    FormSteno.Release;
  end;
end;

procedure TFormSteno.Button3Click(Sender: TObject);
var
  OpenPictureDialog: DBOpenPictureDialog;
begin
  OpenPictureDialog := DBOpenPictureDialog.Create;
  try

    OpenPictureDialog.Filter := 'PNG Images (*.png)|*.png|Bitmaps (*.bmp)|*.bmp';
    OpenPictureDialog.FilterIndex := 1;

    if OpenPictureDialog.Execute then
      LoadInfoFromFile(OpenPictureDialog.FileName);

  finally
    OpenPictureDialog.Free;
  end;
end;

function TFormSteno.LoadInfoFromFile(FileName: String) : boolean;
var
  Bitmap : TBitmap;
  PNG : TPngImage;
  info : TArByte;
  Header : InfoHeader;
  Password : String;
  CRC : Cardinal;
  SaveDialog : DBSaveDialog;

  function LoadCryptFile(FileName : string; _class : TGraphicClass) : TGraphic;
  var
    Password : string;
  begin
   Result:=nil;
   if ValidCryptGraphicFile(FileName) then
   begin
    Password:=DBkernel.FindPasswordForCryptImageFile(FileName);
    if Password='' then
    Password:=GetImagePasswordFromUser(FileName);

    if Password<>'' then
    Result:=DeCryptGraphicFile(FileName,Password) else
    begin
     MessageBoxDB(Handle,Format(TEXT_MES_CANT_LOAD_IMAGE,[FileName]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
     exit;
    end;
   end else
   begin
    Result:=_class.Create;
    Result.LoadFromFile(FileName);
   end;
  end;

begin
 Result:=false;
 Bitmap:=nil;
 SaveDialog:=nil;
 PNG:=nil;
 try
  if GetExt(FileName)<>'BMP' then
  begin
   try
    PNG:=TPngImage(LoadCryptFile(FileName,TPngImage));
    Bitmap:=TBitmap.Create;
    Bitmap.Assign(PNG);
   finally
    if PNG<>nil then PNG.Free;
   end;
  end else
  begin
   Bitmap:=TBitmap(LoadCryptFile(FileName,TBitmap));
  end;
  SetLength(info,0);
  LoadInfoFromBitmap(info, Bitmap);
  if Length(info)=0 then
  begin
   Bitmap.Free;
   Bitmap:=nil;
   MessageBoxDB(GetActiveFormHandle,TEXT_MES_STENO_IMAGE_IS_NOT_VALID,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
   Exit;
  end;
  Header:=GetHeaderFromInfo(info);
  if Header.OK then
  if Header.Crypted then
  begin
   Password:=GetImagePasswordFromUserStenoraphy(Header.FileName,Header.CRC);
   if Password='' then
   begin
    Result:=false;
    if Bitmap<>nil then Bitmap.Free;
    Bitmap:=nil;
    SetLength(info,0);
    exit;
   end;
   DeCryptArray(info,Password);
  end;
  if not Header.OK then
  begin
   Result:=false;
   if Bitmap<>nil then begin Bitmap.Free; Bitmap:=nil; end;
   SetLength(info,0);
   MessageBoxDB(GetActiveFormHandle,TEXT_MES_STENO_IMAGE_IS_NOT_VALID,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
   exit;
  end;
  CRC:=InfoCRC(info);
  if CRC<>Header.DataCRC then
  MessageBoxDB(GetActiveFormHandle,TEXT_MES_FILE_INFO_NOT_VERIFYED,TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_WARNING);

  SaveDialog := DBSaveDialog.Create;
  SaveDialog.SetFileName(Header.FileName);
  try
   if SaveDialog.Execute then
   begin
    SaveInfoToImage.SaveInfoToFile(info,SaveDialog.FileName);
    Result:=true;
   end;
  finally
   SaveDialog.Free;
  end;
 finally
  SetLength(info,0);
  if Bitmap<>nil then Bitmap.Free;
 end;
end;

function FileExists(const EFile: string; var SHigh, SLow: Cardinal): Integer;
var
  Sf: string;
  Fesr: TSearchRec;
  SfAttr: Integer;
begin
  Sf := Trim(EFile);
  Result := 3;
  if (Length(Sf) = 0) or (Sf[Length(Sf)] = '\') then
    Exit;
  SfAttr := $FFE7;
  Result := FindFirst(Sf, SfAttr, Fesr);
  if Result = 0 then
  begin
    Result := 2;
    repeat
      if (((Fesr.Attr and $10) <> $10) and ((Fesr.Attr and $8) <> $8)) then
      begin
        Result := 0;
        SHigh := Fesr.FindData.NFileSizeHigh;
        SLow := Fesr.FindData.NFileSizeLow;
      end;
    until (Result = 0) or (FindNext(Fesr) <> 0);
    FindClose(Fesr);
  end;
end;

procedure TFormSteno.OpenDialog1IncludeItem(const OFN: TOFNotifyEx;
  var Include: Boolean);
var
  FileName: string;
  Sr: TStrRet;
  SHigh, SLow: Cardinal;
  IDL: PItemIDList;
begin
  Include := True; // На всяк пожарный
  Ofn.Psf.GetDisplayNameOf(Ofn.Pidl, SHGDN_FORPARSING, Sr);
  case Sr.UType of
    STRRET_CSTR:
      FileName := Sr.CStr;
    STRRET_WSTR:
      FileName := Sr.POleStr;
    STRRET_OFFSET:
      FileName := PChar(Cardinal(Ofn.Pidl) + Sr.UOffset);
  end;
  IDL := Ofn.Pidl;
  if (FileExists(FileName, SHigh, SLow) = 0) and ((SHigh > 0) or (SLow > GetMaxFileSize)) then
  begin
    Include := False; // На всяк пожарный
    try
      // IDL^.mkid.cb:=0; //приводит к утечкам
      IDL^.Mkid.AbID[0] := 0;
    except // На всяк пожарный - а то вдруг и вправду привелегий не будет
    end;
  end;
end;

procedure TFormSteno.Button2Click(Sender: TObject);
var
  Size: Integer;
  Info: TArByte;
  Bitmap : TBitmap;
  n : integer;
  o : TOpenOptions;
  s : string;
  DialogFileSize : Integer;
  PNG : TPngImage;
  Opt : TCryptImageOptions;
  SavePictureDialog : DBSavePictureDialog;
  FileName : string;
begin
 if Image1.Picture.Graphic=nil then
 begin
  Button1Click(Sender);
  If Image1.Picture.Graphic=nil then exit;
 end;
 DialogFileSize:=GetMaxFileSize;//MaxSizeInfoInGraphic(Image1.Picture.Graphic,2)-255;
 if MaxFileSize<0 then exit;
 o:=OpenDialog1.Options;
 Include(o,ofEnableIncludeNotify);
 Exclude(o,ofOldStyleDialog);
 OpenDialog1.Options:=o;
 OpenDialog1.Filter:=Format(TEXT_MES_FILE_FILTER_FILES_LESS_THAN,[SizeInTextA(DialogFileSize)]);
 OpenDialog1.OnIncludeItem:=OpenDialog1IncludeItem;
 if OpenDialog1.Execute then
 begin
  FileName:=OpenDialog1.FileName;
  Size:=GetFileSizeByName(FileName);
  Memo1.Text:=FileName;
  Label5.Caption:=Format(TEXT_MES_FILE_SIZE_F,[SizeInTextA(Size)]);
  S:=GetFileName(PictureFileName);

  SavePictureDialog := DBSavePictureDialog.Create;

  SavePictureDialog.Filter:='PNG Images (*.png)|*.png|Bitmaps (*.bmp)|*.bmp';
  SavePictureDialog.FilterIndex := 1;
    S := ExtractFilePath(PictureFileName) + GetFileNameWithoutExt(S) + '.png';

    SavePictureDialog.SetFileName(S);
    if SavePictureDialog.Execute then
    begin
      if SavePictureDialog.GetFilterIndex=0 then
   begin
    if GetExt(SavePictureDialog.FileName)<>'BMP' then
    SavePictureDialog.SetFileName(SavePictureDialog.FileName+'.bmp');
   end;
   if SavePictureDialog.GetFilterIndex=1 then
   begin
    if GetExt(SavePictureDialog.FileName)<>'PNG' then
    SavePictureDialog.SetFileName(SavePictureDialog.FileName+'.png');
   end;
   Opt:=GetPassForCryptImageFile(FileName);
   if Opt.Password='' then
   MessageBoxDB(Handle,TEXT_MES_FILE_INFO_NOT_CRYPTED,TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_WARNING);

   info:=SaveFileToInfo(FileName,Opt.Password);
   n:=GetMaxPixelsInSquare(FileName,Image1.Picture.Graphic);
   if n<0 then
   begin
    MessageBoxDB(Handle,TEXT_MES_FILE_IS_TOO_BIG,TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_WARNING);
    SavePictureDialog.Free;
    exit;
   end;
   Bitmap:=SaveInfoToBmpFile(Image1.Picture.Graphic,info,n);
   if Bitmap=nil then
   begin
    SavePictureDialog.Free;
    exit;
   end;

   if SavePictureDialog.GetFilterIndex=0 then
   begin
    Bitmap.SaveToFile(SavePictureDialog.FileName);
    if ImagePassword<>'' then
    CryptGraphicFileV2(SavePictureDialog.FileName,ImagePassword,CRYPT_OPTIONS_NORMAL);
    ImageSaved:=true;
   end else
   begin
     PNG := TPngImage.Create;
     try
      PNG.Assign(Bitmap);
      PNG.SaveToFile(SavePictureDialog.FileName);
       if ImagePassword<>'' then
       CryptGraphicFileV2(SavePictureDialog.FileName,ImagePassword,CRYPT_OPTIONS_NORMAL);
       ImageSaved:=true;
      finally
       PNG.Free;
      end;
   end;
   Bitmap.Free;
  end;
 SavePictureDialog.Free;
 end;
end;

procedure TFormSteno.Button1Click(Sender: TObject);
var
  OpenPicturDialog : DBOpenPictureDialog;
begin
  OpenPicturDialog := DBOpenPictureDialog.Create;
  try
    OpenPicturDialog.Filter := Dolphin_DB.GetGraphicFilter;
    OpenPicturDialog.FilterIndex := 1;

    if OpenPicturDialog.Execute then
      LoadImage(OpenPicturDialog.FileName);

  finally
    OpenPicturDialog.Free;
  end;
end;

procedure TFormSteno.LoadImage(FileName: string; CloseIfOk: Boolean = False);
var
  Password : string;
  Graphic : TGraphic;
begin

 if ValidCryptGraphicFile(FileName) then
  begin
    Password := DBkernel.FindPasswordForCryptImageFile(FileName);
    if Password = '' then
      Password := GetImagePasswordFromUser(FileName);

    if Password <> '' then
    begin
      Graphic := DeCryptGraphicFile(FileName, Password);
      try
        Image1.Picture.Graphic := Graphic;
      finally
        F(Graphic);
      end;
      ImagePassword := Password;
    end
    else
    begin
      MessageBoxDB(Handle, Format(TEXT_MES_CANT_LOAD_IMAGE, [FileName]), TEXT_MES_ERROR, TD_BUTTON_OK, TD_ICON_ERROR);
      Exit;
    end;
  end
  else
  begin
    Image1.Picture.LoadFromFile(FileName);
  end;

  MaxFileSize := MaxSizeInfoInGraphic(Image1.Picture.Graphic, 2) - 255;
  NormalFileSize := MaxSizeInfoInGraphic(Image1.Picture.Graphic, 5) - 255;
  GoodFileSize := MaxSizeInfoInGraphic(Image1.Picture.Graphic, 8) - 255;
  PictureFileName := FileName;

  Label1.Caption := Format(TEXT_MES_MAX_FILE_SIZE_F,
    [SizeInTextA(Max(0, MaxSizeInfoInGraphic(Image1.Picture.Graphic, 2) - 255))]);
  Label2.Caption := Format(TEXT_MES_FILE_NAME_F, [GetFileName(FileName)]);
  Label3.Caption := Format(TEXT_MES_NORMAL_FILE_SIZE_F,
    [SizeInTextA(Max(0, MaxSizeInfoInGraphic(Image1.Picture.Graphic, 5) - 255))]);
  Label7.Caption := Format(TEXT_MES_GOOD_FILE_SIZE_F,
    [SizeInTextA(Max(0, MaxSizeInfoInGraphic(Image1.Picture.Graphic, 8) - 255))]);
  if MaxFileSize > 0 then
    Button2Click(Self);
end;

procedure TFormSteno.FormCreate(Sender: TObject);
begin
  ImagePassword := '';
  ImageSaved := False;
  PictureFileName := '';
  FileName := '';
  MaxFileSize := 0;
  NormalFileSize := 0;
  LoadLanguage;
end;

procedure TFormSteno.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := TEXT_MES_STENOGRAPHIA;
    Label1.Caption:=Format(TEXT_MES_MAX_FILE_SIZE_F, [SizeInTextA(0)]);
    Label2.Caption := Format(TEXT_MES_FILE_NAME_F, ['']);
    Label3.Caption := Format(TEXT_MES_NORMAL_FILE_SIZE_F, [SizeInTextA(0)]);
    Label7.Caption := Format(TEXT_MES_GOOD_FILE_SIZE_F, [SizeInTextA(0)]);
    Label4.Caption := TEXT_MES_INFORMATION_FILE_NAME;
    Label5.Caption := Format(TEXT_MES_FILE_SIZE_F, [SizeInTextA(0)]);
    Label6.Caption := TEXT_MES_STENO_USE_FILTER;
    ComboBox1.Items[0] := TEXT_MES_STENO_USE_FILTER_MAX;
    ComboBox1.Items[1] := TEXT_MES_STENO_USE_FILTER_NORMAL;
    ComboBox1.Items[2] := TEXT_MES_STENO_USE_FILTER_GOOD;
    Button1.Caption := TEXT_MES_OPEN_IMAGE;
    Button2.Caption := TEXT_MES_ADD_INFO_AND_SAVE_IMAGE;
    Button3.Caption := TEXT_MES_DESTENO_IMAGE;
    LoadFromFile1.Caption := TEXT_MES_OPEN_IMAGE;
    AddInfo1.Caption := TEXT_MES_ADD_INFO_AND_SAVE_IMAGE;
    ComboBox1.ItemIndex := 1;
  finally
    EndTranslate;
  end;
end;

function TFormSteno.GetMaxFileSize: Integer;
begin
  if ComboBox1.ItemIndex = 0 then
 begin
    Result := MaxFileSize;
  end else
  begin
    if ComboBox1.ItemIndex = 1 then
      Result := NormalFileSize
    else
    begin
      Result := GoodFileSize;
    end;
  end;
end;

end.
