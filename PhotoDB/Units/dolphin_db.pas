unit Dolphin_db;

interface

uses  Registry, Windows, uVistaFuncs,CommonDBSupport,
      Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
      Dialogs, DB, Grids, DBGrids, Menus, ExtCtrls, StdCtrls,
      ImgList, ComCtrls, JPEG, DmProgress, win32crc,
      SaveWindowPos, ExtDlgs, UnitDBDeclare,
      acDlgSelect, GraphicCrypt, psAPI, ShellApi,
      MAPI, DDraw, Math, DateUtils, GraphicsCool,
      GIFImage, GraphicEx, GraphicsBaseTypes, uLogger, uFileUtils,
      UnitDBFileDialogs, RAWImage, UnitDBCommon, uConstants,
      UnitLinksSupport, EasyListView, ImageConverting, uTranslate,
      uMemory, uDBPopupMenuInfo, uAppUtils, UnitDBCommonGraphics,
      uGraphicUtils, uShellIntegration, uRuntime, uSysUtils;

type
  TInitializeAProc = function(s:PChar) : boolean;

var
  LOGGING_ENABLED: Boolean = True;

type
  THintCheckFunction = function(Info: TDBPopupMenuInfoRecord): Boolean of object;
  TPCharFunctionA = function(S: Pchar): PChar;
  TRemoteCloseFormProc = procedure(Form: TForm; ID: string) of object;
  TFileFoundedEvent = procedure(Owner: TObject; FileName: string; Size: Int64) of object;

const
  InstallType_Checked = 0;
  InstallType_UnChecked = 1;
  InstallType_Grayed = 2;

type
  TInstallExt = record
    Ext: string;
    InstallType: Integer;
  end;

  TInstallExts = array of TInstallExt;

const
  TA_UNKNOWN = 0;
  TA_NEEDS_TERMINATING = 1;
  TA_INFORM = 2;
  TA_INFORM_AND_NT = 3;

type
  TProcTerminating = record
    Proc: TNotifyEvent;
    Owner: TObject;
  end;

  TTemtinatedAction = record
    TerminatedPointer: PBoolean;
    TerminatedVerify: PBoolean;
    Options: Integer;
    Discription: string;
    Owner: TObject;
  end;

  TTemtinatedActions = array of TTemtinatedAction;

type
  TCallbackInfo = record
    Action: Byte;
    ForwardThread: Boolean;
    Direction: Boolean;
  end;

type
  TDirectXSlideShowCreatorCallBackResult = record
    Action: Byte;
    FileName: string;
    Result: Integer;
  end;

type
  TDirectXSlideShowCreatorCallBack = function(CallbackInfo: TCallbackInfo)
    : TDirectXSlideShowCreatorCallBackResult of object;

type
  TByteArr = array [0 .. 0] of Byte;
  PByteArr = ^TByteArr;

type
  TDirectXSlideShowCreatorInfo = record
    FileName: string;
    Rotate: Integer;
    CallBack: TDirectXSlideShowCreatorCallBack;
    FDirectXSlideShowReady: PBoolean;
    FDirectXSlideShowTerminate: PBoolean;
    DirectDraw4: IDirectDraw4;
    PrimarySurface: IDirectDrawSurface4;
    Offscreen: IDirectDrawSurface4;
    Buffer: IDirectDrawSurface4;
    Clpr: IDirectDrawClipper;
    BPP, RBM, GBM, BBM: Integer;
    TransSrc1, TransSrc2, TempSrc: PByteArr;
    SID: TGUID;
    Manager: TObject;
    Form: TForm;
  end;

type
  TUserMenuItem = record
    Caption: string;
    EXEFile: string;
    Params: string;
    Icon: string;
    UseSubMenu: Boolean;
  end;

  TUserMenuItemArray = array of TUserMenuItem;

  // Added in v2.0
type
  TPlaceFolder = record
    name: string;
    FolderName: string;
    Icon: string;
    MyComputer: Boolean;
    MyDocuments: Boolean;
    MyPictures: Boolean;
    OtherFolder: Boolean;
  end;

  TPlaceFolderArray = array of TPlaceFolder;

type
  // Added in 2.2 version

  TCallBackBigSizeProc = procedure(Sender: TObject; SizeX, SizeY: Integer) of object;

  TWatermarkOptions = record
    Text : string;
    BlockCountX : Integer;
    BlockCountY : Integer;
    Transparenty : Byte;
    Color : TColor;
    FontName : string;
    IsBold : Boolean;
    IsItalic : Boolean;
  end;

  TPreviewOptions = record
    GeneratePreview : Boolean;
    PreviewWidth : Integer;
    PreviewHeight : Integer;
  end;

  TProcessingParams = record
    Rotation: Integer;
    ResizeToSize: Boolean;
    Width : Integer;
    Height : Integer;
    Resize : Boolean;
    Rotate : Boolean;
    PercentResize : Integer;
    GraphicClass : TGraphicClass;
    SaveAspectRation : Boolean;
    Preffix : string;
    WorkDirectory : string;
    AddWatermark : Boolean;
    WatermarkOptions : TWatermarkOptions;
    PreviewOptions : TPreviewOptions;
  end;

var
  DBName: string;
  HelpNO: Integer = 0;
  HelpActivationNO: Integer = 0;
  FExtImagesInImageList: Integer;
  GraphicFilterString: string;

function XorStrings(S1, S2: string): string;
function SetStringToLengthWithNoData(S: string; N: Integer): string;

procedure LoadNickJpegImage(Image: TImage);
procedure DoHelp;
procedure DoGetCode(S: string);
procedure DoHomeContactWithAuthor;
procedure DoHomePage;
procedure DBError(ErrorValue, Error: string);

procedure Delay(Msecs: Longint);
function CreateProgressBar(StatusBar: TStatusBar; index: Integer): TProgressBar;

function IsWallpaper(FileName: string): Boolean;
procedure DoUpdateHelp;
function GetDBFileName(FileName, DBName: string): string;

function AnsiCompareTextWithNum(Text1, Text2: string): Integer;

function EXIFDateToDate(DateTime: string): TDateTime;
function EXIFDateToTime(DateTime: string): TDateTime;

function GetActiveFormHandle: Integer;
function GetGraphicFilter: string;

function CenterPos(W1, W2: Integer): Integer;
function ExifOrientationToRatation(Orientation : Integer) : Integer;

function SizeInText(Size: Int64): string;

implementation

function ExifOrientationToRatation(Orientation : Integer) : Integer;
const
  Orientations : array[1..9] of Integer = (
  DB_IMAGE_ROTATE_0,
  DB_IMAGE_ROTATE_0,
  DB_IMAGE_ROTATE_180,
  DB_IMAGE_ROTATE_180,
  DB_IMAGE_ROTATE_90,
  DB_IMAGE_ROTATE_90,
  DB_IMAGE_ROTATE_270,
  DB_IMAGE_ROTATE_270,
  DB_IMAGE_ROTATE_0);

begin
  if Orientation in [1..9] then
    Result := Orientations[Orientation]
  else
    Result := 0;
end;

function CenterPos(W1, W2: Integer): Integer;
begin
  Result := W1 div 2 - W2 div 2;
end;

function GetDBFileName(FileName, DBName: string): string;
begin
  Result := FileName;
  if Length(FileName) > 2 then
    if FileName[2] <> ':' then
      Result := IncludeTrailingBackslash(ExtractFileDir(DBName)) + FileName;
end;

function PixelsToText(Pixels: Integer): string;
begin
  Result := Format(TA('%dpx.'), [IntToStr(Pixels)]);
end;

function SizeInTextA(Size: Int64): string;
begin
  if Size <= 1024 then
    Result := IntToStr(Size) + ' ' + TA('Bytes');
  if (Size > 1024) and (Size <= 1024 * 999) then
    Result := FloatToStrEx(Size / 1024, 3) + ' ' + TA('Kb');
  if (Size > 1024 * 999) and (Size <= 1024 * 1024 * 999) then
    Result := FloatToStrEx(Size / (1024 * 1024), 3) + ' ' + TA('Mb');
  if (Size > 1024 * 1024 * 999) then
    Result := FloatToStrEx(Size / (1024 * 1024 * 1024), 3) + ' ' + TA('Gb');
end;

function Xorstrings(S1, S2: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to 255 do
    Result := Result + ' ';
  for I := 1 to Min(Min(Length(S1), Length(S2)), 255) do
  begin
    Result[I] := Chr(Ord(S1[I]) xor Ord(S2[I]));
  end;
end;

function Setstringtolengthwithnodata(S: string; N: Integer): string;
var
  Cs, I: Integer;
begin
  Cs := 0;
  for I := 1 to Min(Length(S), N) do
    Cs := Cs + Ord(S[I]);
  Result := '';
  for I := 1 to N do
    Result := Result + ' ';
  for I := 1 to N do
    if I <= Length(S) then
      Result[I] := Chr((Ord(S[I]) xor I) xor Cs)
    else
      Result[I] := Chr((I + Cs) xor Cs);
end;

procedure LoadNickJpegImage(Image: TImage);
var
  Pic: Tpicture;
  Bmp, Bitmap: Tbitmap;
  FJPG: TJpegImage;
  OpenPictureDialog: DBOpenPictureDialog;
begin
  OpenPictureDialog := DBOpenPictureDialog.Create;
  try
    OpenPictureDialog.Filter := GetGraphicFilter;
    if OpenPictureDialog.Execute then
    begin
      Pic := TPicture.Create;
      try
        Pic.LoadFromFile(OpenPictureDialog.FileName);
      except
        Pic.Free;
        OpenPictureDialog.Free;
        Exit;
      end;
      JpegScale(Pic.Graphic, 48, 48);
      Bitmap := TBitmap.Create;
      Bitmap.PixelFormat := Pf24Bit;
      Bitmap.Assign(Pic.Graphic);
      Pic.Free;
      Bmp := Tbitmap.Create;
      Bmp.PixelFormat := Pf24bit;
      if Bitmap.Width > Bitmap.Height then
      begin
        if Bitmap.Width > 48 then
          Bmp.Width := 48
        else
          Bmp.Width := Bitmap.Width;
        Bmp.Height := Round(Bmp.Width * (Bitmap.Height / Bitmap.Width));
      end else
      begin
        if Bitmap.Height > 48 then
          Bmp.Height := 48
        else
          Bmp.Height := Bitmap.Height;
        Bmp.Width := Round(Bmp.Height * (Bitmap.Width / Bitmap.Height));
      end;
      DoResize(Bmp.Width, Bmp.Height, Bitmap, Bmp);
      Bitmap.Free;
      Fjpg := TJPegImage.Create;
      Fjpg.CompressionQuality := DBJpegCompressionQuality;
      Fjpg.Assign(Bmp);
      Fjpg.JPEGNeeded;
      if Image.Picture.Graphic = nil then
        Image.Picture.Graphic := TJpegImage.Create;
      Image.Picture.Graphic.Assign(Fjpg);
      Image.Refresh;
      Fjpg.Free;
      Bmp.Free;
    end;
  finally
    OpenPictureDialog.Free;
  end;
end;

procedure DoHelp;
begin
  ShellExecute(GetActiveWindow, 'open', 'http://photodb.illusdolphin.net', nil, nil, SW_NORMAL);
end;

procedure DoUpdateHelp;
begin
  if FileExists(ProgramDir + 'Help\photodb_updating.htm') then
    ShellExecute(GetActiveWindow, 'open', PWideChar(ProgramDir + 'Help\photodb_updating.htm'), nil, nil, SW_NORMAL);
end;

procedure DoHomePage;
begin
  ShellExecute(GetActiveWindow, 'open', PWideChar(ResolveLanguageString(HomePageURL)), nil, nil, SW_NORMAL);
end;

procedure DoHomeContactWithAuthor;
begin
  ShellExecute(GetActiveWindow, 'open', PWideChar('mailto:' + ProgramMail + '?subject=''''' + ProductName + ''''''), nil, nil,
    SW_NORMAL);
end;

procedure DoGetCode(S: string);
begin
  ShellExecute(GetActiveWindow, 'open', PWideChar('mailto:' + ProgramMail + '?subject=''''' + ProductName +
        ''''' REGISTRATION CODE = ''''' + S + ''''''), nil, nil, SW_NORMAL);
end;

function SendMail(const From, Dest, Subject, Text, FileName: PAnsiChar; Outlook: Boolean): Integer;
var
  message: TMapiMessage;
  Recipient, Sender: TMapiRecipDesc;
  File_Attachment: TMapiFileDesc;

  function MakeMessage: TMapiMessage;
  begin
    FillChar(Sender, SizeOf(Sender), 0);
    Sender.UlRecipClass := MAPI_ORIG;
    Sender.LpszAddress := From;

    FillChar(Recipient, SizeOf(Recipient), 0);
    Recipient.UlRecipClass := MAPI_TO;
    Recipient.LpszAddress := Dest;

    FillChar(File_Attachment, SizeOf(File_Attachment), 0);
    File_Attachment.NPosition := Cardinal(-1);
    File_Attachment.LpszPathName := FileName;

    FillChar(Result, SizeOf(Result), 0);
    with message do
    begin
      LpszSubject := Subject;
      LpszNoteText := Text;
      LpOriginator := @Sender;
      NRecipCount := 1;
      LpRecips := @Recipient;
      NFileCount := 1;
      LpFiles := @File_Attachment;
    end;
  end;

var
  SM: TFNMapiSendMail;
  MAPIModule: HModule;
  MAPI_FLAG: Cardinal;
begin
  if Outlook then
    MAPI_FLAG := MAPI_DIALOG
  else
    MAPI_FLAG := 0;
  MAPIModule := LoadLibrary(PWideChar(MAPIDLL));
  if MAPIModule = 0 then
    Result := -1
  else
    try
      @SM := GetProcAddress(MAPIModule, 'MAPISendMail');
      if @SM <> nil then
      begin
        MakeMessage;
        Result := SM(0, Application.Handle, message, MAPI_FLAG, 0);
      end
      else
        Result := 1;
    finally
      FreeLibrary(MAPIModule);
    end;
end;

procedure DBError(ErrorValue, Error: string);
var
  Body: TStrings;
begin
  Body := TStringList.Create;
  Body.Add('Error body:');
  Body.Add(ErrorValue);
  SendMail('', ProgramMail, PAnsiChar(AnsiString('Error in program [' + Error + ']')), PAnsiChar(AnsiString(Body.Text)), '', True);
  Body.Free;
end;

procedure Delay(Msecs: Longint);
var
  FirstTick: Longint;
begin
  FirstTick := GetTickCount;
  repeat
    Application.ProcessMessages; { для того чтобы не "завесить" Windows }
  until (Longint(GetTickCount) - FirstTick) >= Msecs;
end;

function CreateProgressBar(StatusBar: TStatusBar; index: Integer): TProgressBar;
var
  Findleft: Integer;
  I: Integer;
begin
  Result := TProgressBar.Create(Statusbar);
  Result.Parent := Statusbar;
  Result.Visible := True;
  Result.Top := 2;
  FindLeft := 0;
  for I := 0 to index - 1 do
    FindLeft := FindLeft + Statusbar.Panels[I].Width + 1;
  Result.Left := Findleft;
  Result.Width := Statusbar.Panels[index].Width - 4;
  Result.Height := Statusbar.Height - 2;
end;

function IsWallpaper(FileName: string): Boolean;
var
  Str: string;
begin
  Str := AnsiUpperCase(ExtractFileExt(FileName));
  Result := (Str = '.HTML') or (Str = '.HTM') or (Str = '.GIF') or (Str = '.JPG') or (Str = '.JPEG') or (Str = '.JPE') or
    (Str = '.BMP');
  Result := Result and FileExists(FileName);
end;

function AnsiCompareTextWithNum(Text1, Text2: string): Integer;
var
  S1, S2: string;

  function Num(Str: string): Boolean;
  var
    I: Integer;
  begin
    Result := True;
    for I := 1 to Length(Str) do
    begin
      if not CharInSet(Str[I], ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) then
      begin
        Result := False;
        Break;
      end;
    end;
  end;

  function TrimNum(Str: string): string;
  var
    I: Integer;
  begin
    Result := Str;
    if Result <> '' then
      for I := 1 to Length(Result) do
      begin
        if not CharInSet(Result[I], ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) then
        begin
          Delete(Result, 1, I - 1);
          Break;
        end;
      end;
    for I := 1 to Length(Result) do
    begin
      if not CharInSet(Result[I], ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) then
      begin
        Result := Copy(Result, 1, I - 1);
        Break;
      end;
    end;
  end;

begin
  S1 := TrimNum(Text1);
  S2 := TrimNum(Text2);
  if Num(S1) or Num(S2) then
  begin
    Result := StrToIntDef(S1, 0) - StrToIntDef(S2, 0);
    Exit;
  end;
  Result := AnsiCompareStr(Text1, Text2);
end;

function EXIFDateToDate(DateTime: string): TDateTime;
var
  Yyyy, Mm, Dd: Word;
  D: string;
  DT: TDateTime;
begin
  Result := 0;
  if TryStrToDate(DateTime, DT) then
  begin
    Result := DateOf(DT);
  end else
  begin
    D := Copy(DateTime, 1, 10);
    TryStrToDate(D, Result);
    if Result = 0 then
    begin
      Yyyy := StrToIntDef(Copy(DateTime, 1, 4), 0);
      Mm := StrToIntDef(Copy(DateTime, 6, 2), 0);
      Dd := StrToIntDef(Copy(DateTime, 9, 2), 0);
      if (Yyyy > 1990) and (Yyyy < 2050) then
        if (Mm >= 1) and (Mm <= 12) then
          if (Dd >= 1) and (Dd <= 31) then
            Result := EncodeDate(Yyyy, Mm, Dd);
    end;
  end;
end;

function EXIFDateToTime(DateTime: string): TDateTime;
var
  // yyyy,mm,dd : Word;
  T: string;
  DT: TDateTime;
begin
  Result := 0;
  if TryStrToTime(DateTime, DT) then
  begin
    Result := TimeOf(DT);
  end else
  begin
    T := Copy(DateTime, 12, 8);
    TryStrToTime(T, Result);
    Result := TimeOf(Result);
  end;
end;

function GetActiveFormHandle: Integer;
begin
  if Screen.ActiveForm <> nil then
    Result := Screen.ActiveForm.Handle
  else
    Result := 0;
end;

function GetGraphicFilter: string;
var
  AllFormatsString: string;
  FormatsString, StrTemp: string;
  P, I: Integer;
  RAWFormats: string;

  procedure AddGraphicFormat(FormatName: string; Extensions: string; LastExtension: Boolean);
  begin
    FormatsString := FormatsString + FormatName + ' (' + Extensions + ')' + '|' + Extensions;
    if not LastExtension then
      FormatsString := FormatsString + '|';

    AllFormatsString := AllFormatsString + Extensions;
    if not LastExtension then
      AllFormatsString := AllFormatsString + ';';
  end;

begin
  AllFormatsString := '';
  FormatsString := '';
  RAWFormats := '';
  if GraphicFilterString = '' then
  begin
    AddGraphicFormat('JPEG Image File', '*.jpg;*.jpeg;*.jfif;*.jpe;*.thm', False);
    AddGraphicFormat('Tiff images', '*.tiff;*.tif;*.fax', False);
    AddGraphicFormat('Portable network graphic images', '*.png', False);
    AddGraphicFormat('GIF Images', '*.gif', False);

    if IsRAWSupport then
    begin
      P := 1;
      for I := 1 to Length(RAWImages) do
        if (RAWImages[I] = '|') then
        begin
          StrTemp := Copy(RAWImages, P, I - P);

          RAWFormats := RAWFormats + '*.' + AnsiLowerCase(StrTemp);
          if I <> Length(RAWImages) then
            RAWFormats := RAWFormats + ';';
          P := I + 1;
        end;
      AddGraphicFormat('Camera RAW Images', RAWFormats, False);
    end;

    AddGraphicFormat('Bitmaps', '*.bmp;*.rle;*.dib', False);
    AddGraphicFormat('Photoshop images', '*.psd;*.pdd', False);
    AddGraphicFormat('Truevision images', '*.win;*.vst;*.vda;*.tga;*.icb', False);
    AddGraphicFormat('ZSoft Paintbrush images', '*.pcx;*.pcc;*.scr', False);
    AddGraphicFormat('Alias/Wavefront images', '*.rpf;*.rla', False);
    AddGraphicFormat('SGI true color images', '*.sgi;*.rgba;*.rgb;*.bw', False);
    AddGraphicFormat('Portable map images', '*.ppm;*.pgm;*.pbm', False);
    AddGraphicFormat('Autodesk images', '*.cel;*.pic', False);
    AddGraphicFormat('Kodak Photo-CD images', '*.pcd', False);
    AddGraphicFormat('Dr. Halo images', '*.cut', False);
    AddGraphicFormat('Paintshop Pro images', '*.psp', True);

    FormatsString := Format(TA('All formats (%s)'), [AllFormatsString]) + '|' + AllFormatsString + '|' + FormatsString;
    GraphicFilterString := FormatsString;
  end;
  Result := GraphicFilterString;
end;

function SizeInText(Size: Int64): string;
begin
  if Size <= 1024 then
    Result := IntToStr(Size) + ' ' + TA('Bytes');
  if (Size > 1024) and (Size <= 1024 * 999) then
    Result := FloatToStrEx(Size / 1024, 3) + ' ' + TA('Kb');
  if (Size > 1024 * 999) and (Size <= 1024 * 1024 * 999) then
    Result := FloatToStrEx(Size / (1024 * 1024), 3) + ' ' + TA('Mb');
  if (Size > 1024 * 1024 * 999) then
    Result := FloatToStrEx(Size / (1024 * 1024 * 1024), 3) + ' ' + TA('Gb');
end;

initialization

  FExtImagesInImageList := 0;
  LastInseredID := 0;
  GraphicFilterString := '';

finalization

end.
