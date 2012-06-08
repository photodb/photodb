unit Dolphin_db;

interface

uses
  Windows,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  ExtCtrls,
  ComCtrls,
  JPEG,
  UnitDBDeclare,
  ShellApi,
  MAPI,
  Math,
  DateUtils,
  uLogger,
  uFileUtils,
  UnitDBFileDialogs,
  uConstants,
  uTranslate,
  uMemory,
  uRuntime,
  uSysUtils,
  uAssociations,
  uActivationUtils,
  uImageLoader;

type
  THintCheckFunction = function(Info: TDBPopupMenuInfoRecord): Boolean of object;
  TRemoteCloseFormProc = procedure(Form: TForm; ID: string) of object;
  TFileFoundedEvent = procedure(Owner: TObject; FileName: string; Size: Int64) of object;

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
    Width: Integer;
    Height: Integer;
    Resize: Boolean;
    Rotate: Boolean;
    PercentResize: Integer;
    Convert: Boolean;
    GraphicClass: TGraphicClass;
    SaveAspectRation: Boolean;
    Preffix: string;
    WorkDirectory: string;
    AddWatermark: Boolean;
    WatermarkOptions: TWatermarkOptions;
    PreviewOptions: TPreviewOptions;
  end;

var
  HelpNO: Integer = 0;
  HelpActivationNO: Integer = 0;
  FExtImagesInImageList: Integer;

procedure LoadNickJpegImage(Image: TImage);
procedure DoHelp;
procedure DoHomeContactWithAuthor;
procedure DoHomePage;
procedure DoBuyApplication;
procedure DoDonate;
function SendEMail(Handle: THandle; ToAddress, ToName, Subject, Body: string; Files: TStrings): Cardinal;

procedure Delay(Msecs: Longint);
function CreateProgressBar(StatusBar: TStatusBar; Index: Integer): TProgressBar;

function IsWallpaper(FileName: string): Boolean;
function GetDBFileName(FileName, DBName: string): string;

function AnsiCompareTextWithNum(Text1, Text2: string): Integer;

function EXIFDateToDate(DateTime: string): TDateTime;
function EXIFDateToTime(DateTime: string): TDateTime;

function GetActiveFormHandle: Integer;

function SizeInText(Size: Int64): string;
function SpeedInText(Speed: Extended): string;

function GetImageFromUser(var Bitmap: TBitmap; MaxWidth, MaxHeight: Integer): Boolean;
function DBLoadImage(FileName: string; var Bitmap: TBitmap; MaxWidth, MaxHeight: Integer): Boolean;

function TimeIntervalInString(Time: TTime): string;

implementation

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

function DBLoadImage(FileName: string; var Bitmap: TBitmap; MaxWidth, MaxHeight: Integer): Boolean;
var
  Info: TDBPopupMenuInfoRecord;
  ImageInfo: ILoadImageInfo;
begin
  Result := False;
  Info := TDBPopupMenuInfoRecord.Create;
  try
    if LoadImageFromPath(Info, -1, '', [ilfGraphic, ilfICCProfile, ilfEXIF, ilfPassword, ilfAskUserPassword],
      ImageInfo, MaxWidth, MaxHeight) then
    begin
      Bitmap := ImageInfo.GenerateBitmap(Info, MaxWidth, MaxHeight, pf24Bit, clBlack, [ilboFreeGraphic, ilboRotate, ilboApplyICCProfile, ilboQualityResize]);
      Result := Bitmap <> nil;
    end;
  finally
    F(Info);
  end;
end;

function GetImageFromUser(var Bitmap: TBitmap; MaxWidth, MaxHeight: Integer): Boolean;
var
  OpenPictureDialog: DBOpenPictureDialog;
  FileName: string;
begin
  Result := False;
  OpenPictureDialog := DBOpenPictureDialog.Create;
  try
    OpenPictureDialog.Filter := TFileAssociations.Instance.FullFilter;
    if OpenPictureDialog.Execute then
    begin
      FileName := OpenPictureDialog.FileName;
      Result := DBLoadImage(FileName, Bitmap, MaxWidth, MaxHeight);
    end;
  finally
    F(OpenPictureDialog);
  end;
end;

procedure LoadNickJpegImage(Image: TImage);
var
  Bitmap: TBitmap;
  FJPG: TJpegImage;
begin
  Bitmap := TBitmap.Create;
  try
    if GetImageFromUser(Bitmap, 48, 48) then
    begin
      FJPG := TJPegImage.Create;
      try
        FJPG.CompressionQuality := DBJpegCompressionQuality;
        FJPG.Assign(Bitmap);
        FJPG.JPEGNeeded;
        Image.Picture.Graphic := FJPG;
      finally
        F(FJPG);
      end;
    end;
  finally
    F(Bitmap);
  end;
end;

procedure DoHelp;
begin
  ShellExecute(GetActiveWindow, 'open', PWideChar(ResolveLanguageString(HomePageURL) + '?mode=help'), nil, nil, SW_NORMAL);
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

procedure DoBuyApplication;
var
  BuyUrl: string;
begin
  BuyUrl := ResolveLanguageString(BuyPageURL) + '?v=' + ProductVersion + '&ac=' + TActivationManager.Instance.ApplicationCode;
  ShellExecute(GetActiveWindow, 'open', PWideChar(BuyUrl), nil, nil, SW_NORMAL);
end;

procedure DoDonate;
begin
  ShellExecute(GetActiveWindow, 'open', PWideChar(ResolveLanguageString(DonateURL)), nil, nil, SW_NORMAL);
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
  Result := Result and FileExistsSafe(FileName);
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
        if CharInSet(Result[I], ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) then
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
    if Result = '' then
      Result := Str;
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

function SpeedInText(Speed: Extended): string;
begin
  if Speed > 100 then
    Result := IntToStr(Round(Speed))
  else if Speed > 10 then
    Result := FormatFloat('##.#', Speed)
  else
    Result := FormatFloat('0.##', Speed);
end;

function SizeInText(Size: Int64): string;
begin
  if Size <= 1024 then
    Result := IntToStr(Size) + ' ' + TA('Bytes');
  if (Size > 1024) and (Size <= 1024 * 999) then
    Result := FloatToStrEx(Size / 1024, 3) + ' ' + TA('Kb');
  if (Size > 1024 * 999) and (Size <= 1024 * 1024 * 999) then
    Result := FloatToStrEx(Size / (1024 * 1024), 3) + ' ' + TA('Mb');
  if (Size > 1024 * 1024 * 999) and ((Size div 1024) <= 1024 * 1024 * 999) then
    Result := FloatToStrEx(Size / (1024 * 1024 * 1024), 3) + ' ' + TA('Gb');
  if (Size div 1024 > 1024 * 1024 * 999) then
    Result := FloatToStrEx((Size / (1024 * 1024)) / (1024 * 1024), 3) + ' ' + TA('Tb');
end;

function SendEMail(Handle: THandle; ToAddress, ToName, Subject, Body: string; Files: TStrings): Cardinal;
type
  TAttachAccessArray = array [0..0] of TMapiFileDesc;
  PAttachAccessArray = ^TAttachAccessArray;
var
  MapiMessage: TMapiMessage;
  Receip: TMapiRecipDesc;
  Attachments: PAttachAccessArray;
  i1: integer;
  FileName: string;
  dwRet: Cardinal;
  MAPI_Session: Cardinal;
  WndList: Pointer;
begin
  if ToName = '' then
    ToName := ToAddress;

  dwRet := MapiLogon(Handle,
    PAnsiChar(''),
    PAnsiChar(''),
    MAPI_LOGON_UI or MAPI_NEW_SESSION,
    0, @MAPI_Session);

  if (dwRet <> SUCCESS_SUCCESS) then
  begin
    Result := Cardinal(-1);
    Exit;
  end else
  begin
    FillChar(MapiMessage, SizeOf(MapiMessage), #0);
    Attachments := nil;
    FillChar(Receip, SizeOf(Receip), #0);

    if ToAddress <> '' then
    begin
      Receip.ulReserved := 0;
      Receip.ulRecipClass := MAPI_TO;
      Receip.lpszName := StrNew(PAnsiChar(AnsiString(ToName)));
      Receip.lpszAddress := StrNew(PAnsiChar(AnsiString('SMTP:' + ToAddress)));
      Receip.ulEIDSize := 0;
      MapiMessage.nRecipCount := 1;
      MapiMessage.lpRecips := @Receip;
    end;

    if Files.Count > 0 then
    begin
      GetMem(Attachments, SizeOf(TMapiFileDesc) * Files.Count);

      for i1 := 0 to Files.Count - 1 do
      begin
        FileName := Files[i1];
        Attachments[i1].ulReserved := 0;
        Attachments[i1].flFlags := 0;
        Attachments[i1].nPosition := ULONG($FFFFFFFF);
        Attachments[i1].lpszPathName := StrNew(PAnsiChar(AnsiString(FileName)));
        Attachments[i1].lpszFileName := StrNew(PAnsiChar(AnsiString(ExtractFileName(FileName))));
        Attachments[i1].lpFileType := nil;
      end;
      MapiMessage.nFileCount := Files.Count;
      MapiMessage.lpFiles := @Attachments^;
    end;

    if Subject <> '' then
      MapiMessage.lpszSubject := StrNew(PAnsiChar(AnsiString(Subject)));
    if Body <> '' then
      MapiMessage.lpszNoteText := StrNew(PAnsiChar(AnsiString(Body)));

    WndList := DisableTaskWindows(0);
    try
      Result := MapiSendMail(MAPI_Session, Handle,
        MapiMessage, MAPI_DIALOG, 0);
    finally
      EnableTaskWindows( WndList );
    end;

    for i1 := 0 to Files.Count - 1 do
    begin
      StrDispose(Attachments[i1].lpszPathName);
      StrDispose(Attachments[i1].lpszFileName);
    end;

    if Assigned(MapiMessage.lpszSubject) then
      StrDispose(MapiMessage.lpszSubject);
    if Assigned(MapiMessage.lpszNoteText) then
      StrDispose(MapiMessage.lpszNoteText);
    if Assigned(Receip.lpszAddress) then
      StrDispose(Receip.lpszAddress);
    if Assigned(Receip.lpszName) then
      StrDispose(Receip.lpszName);
    MapiLogOff(MAPI_Session, Handle, 0, 0);
  end;
end;

function TimeIntervalInString(Time: TTime): string;
var
  Y, MM, Days, H, M, S, MS: Word;
  SD, SH, SM, SS: string;

  function RoundSeconds(Sec: Word): Word;
  begin
    Result := Ceil(S / 5) * 5;
  end;

begin
  DecodeDateTime(Time, Y, MM, Days, H, M, S, MS);
  Days := Min(30, (Days - 1) + (Y - 1) * 12 * 365 + (MM - 1) * 30);

  S := RoundSeconds(S);

  SD := IntToStr(Days) + ' ' + IIF(Days <> 1, TA('days', 'Global'), TA('day', 'Global'));
  SH := IntToStr(H) + ' ' + IIF(H <> 1, TA('hours', 'Global'), TA('hour', 'Global'));
  SM := IntToStr(M) + ' ' + IIF(M <> 1, TA('minutes', 'Global'), TA('minute', 'Global'));
  SS := IntToStr(S) + ' ' + IIF(S <> 1, TA('seconds', 'Global'), TA('second', 'Global'));

  if Days > 0 then
    Result := SD + ', ' + SH
  else if H > 0 then
    Result := SH + ', ' + SM
  else if M > 0 then
    Result := SM + ', ' + SS
  else
    Result := SS;

  if Length(Result) > 0 then
    Result[1] := UpCase(Result[1]);
end;

initialization

  FExtImagesInImageList := 0;
  LastInseredID := 0;

end.
