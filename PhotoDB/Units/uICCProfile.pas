unit uICCProfile;

interface

uses
  System.Classes,
  System.SyncObjs,
  System.SysUtils,
  Generics.Collections,
  Winapi.Windows,
  Vcl.Graphics,
  Vcl.Imaging.PngImage,

  uMemory,

  lcms2dll;

const
  IS_INPUT = $1;
  IS_DISPLAY = $2;
  IS_COLORSPACE = $4;
  IS_OUTPUT = $8;
  IS_ABSTRACT = $10;

  DEFAULT_ICC_DISPLAY_PROFILE = 'sRGB IEC61966-2.1';

type
  TICCProfileInfo = class(TObject)
    FileName: string;
    Name: string;
  end;

function InSignatures(Signature: cmsProfileClassSignature; dwFlags: DWORD): Boolean;
function ConvertBitmapToDisplayICCProfile(ThreadContext: Pointer; Bitmap: TBitmap; SourceMem: Pointer; MemSize: Cardinal; SourceICCProfileName: string; DisplayProfileName: string = DEFAULT_ICC_DISPLAY_PROFILE): Boolean;
function ConvertPngToDisplayICCProfile(ThreadContext: Pointer; Png: TPngImage; SourceMem: Pointer; MemSize: Cardinal; DestinationICCProfileFile: string = DEFAULT_ICC_DISPLAY_PROFILE): Boolean;
function FillDisplayProfileList(List: TStrings): Boolean;
function GetICCProfileName(ThreadContext: Pointer; SourceMem: Pointer; MemSize: Cardinal): string;

implementation

var
  IntentNames: array [0 .. 20] of PAnsiChar;
  IntentCodes: array [0 .. 20] of cmsUInt32Number;
  InputICCProfileList, OutputICCProfileList: TList<TICCProfileInfo>;
  IsICCInitialized: Boolean = False;
  IsICCEnabled: Boolean = False;
  FSync: TCriticalSection = nil;

function InSignatures(Signature: cmsProfileClassSignature; dwFlags: DWORD): Boolean;
begin
  if (((dwFlags and IS_DISPLAY) <> 0) and (Signature = cmsSigDisplayClass)) then
    InSignatures := TRUE
  else if (((dwFlags and IS_OUTPUT) <> 0) and (Signature = cmsSigOutputClass))
    then
    InSignatures := TRUE
  else if (((dwFlags and IS_INPUT) <> 0) and (Signature = cmsSigInputClass))
    then
    InSignatures := TRUE
  else if (((dwFlags and IS_COLORSPACE) <> 0) and
      (Signature = cmsSigColorSpaceClass)) then
    InSignatures := TRUE
  else if (((dwFlags and IS_ABSTRACT) <> 0) and
      (Signature = cmsSigAbstractClass)) then
    InSignatures := TRUE
  else
    InSignatures := FALSE
end;

function GetICCDisplayProfileFileName(ProfileName: string): string;
var
  I: Integer;
begin
  Result := '';
  ProfileName := AnsiLowerCase(ProfileName);
  for I := 0 to OutputICCProfileList.Count - 1 do
  begin
    if AnsiLowerCase(OutputICCProfileList[I].Name) = ProfileName then
      Exit(OutputICCProfileList[I].FileName);
  end;
end;

procedure FillCCProfileList(var List: TList<TICCProfileInfo>; Signatures: DWORD);
var
  Found: Integer;
  SearchRec: TSearchRec;
  Path, Profile: string;
  Dir: array [0 .. 1024] of Char;
  hProfile: cmsHPROFILE;
  Descrip: array [0 .. 256] of Char;
  Info: TICCProfileInfo;
begin
  GetSystemDirectory(Dir, 1023);
  Path := string(Dir) + '\SPOOL\DRIVERS\COLOR\';
  Found := FindFirst(Path + '*.ic?', faAnyFile, SearchRec);
  while Found = 0 do
  begin
    Profile := Path + SearchRec.Name;
    hProfile := cmsOpenProfileFromFile(PAnsiChar(AnsiString(Profile)), 'r');
    if (hProfile <> nil) then
    begin
      if ((cmsGetColorSpace(hProfile) = cmsSigRgbData) and InSignatures(cmsGetDeviceClass(hProfile), Signatures)) then
      begin
        cmsGetProfileInfo(hProfile, cmsInfoDescription, 'EN', 'us', Descrip,  256);

        Info := TICCProfileInfo.Create;
        Info.FileName := Profile;
        Info.Name := Descrip;
        List.Add(Info);
      end;
      cmsCloseProfile(hProfile);
    end;
    Found := FindNext(SearchRec);
  end;
  System.SysUtils.FindClose(SearchRec);
end;

function InitICCProfiles: Boolean;
var
  SupportedIntents: Integer;
  lcmsHandle: THandle;
begin
  //should be faster for multithreadng, no enter to critical section
  if IsICCInitialized then
    Exit(IsICCEnabled);

  FSync.Enter;
  try
    if IsICCInitialized then
      Exit(IsICCEnabled);

    lcmsHandle := LoadLibrary('lcms2.dll');
    if lcmsHandle = 0 then
    begin
      Exit(False);
    end else
      FreeLibrary(lcmsHandle);

    IsICCEnabled := True;
    cmsSetAdaptationState(0);

    InputICCProfileList := TList<TICCProfileInfo>.Create;
    OutputICCProfileList := TList<TICCProfileInfo>.Create;

    FillCCProfileList(InputICCProfileList, IS_INPUT OR IS_COLORSPACE OR IS_DISPLAY);
    FillCCProfileList(OutputICCProfileList, $FFFF);

    // Get the supported intents
    SupportedIntents := cmsGetSupportedIntents(20, @IntentCodes, @IntentNames);

    //first IntentCode is used, so it should exists
    Result := SupportedIntents > 0;

    IsICCInitialized := True;
  finally
    FSync.Leave;
  end;
end;

function ConvertBitmapICCProfile(ThreadContext: Pointer; Bitmap: TBitmap; SourceMem: Pointer; MemSize: Cardinal; SourceICCProfileName, DestinationICCProfileFile: string): Boolean;
var
  hSrc, hDest: cmsHPROFILE;
  xform: cmsHTRANSFORM;
  I, PicW, PicH: Integer;
  Intent: Integer;
  dwFlags: DWORD;
  Line: Pointer;
  SourceICCProfileFile: string;
  Info: TICCProfileInfo;
begin
  Result := False;

  SourceICCProfileFile := '';
  SourceICCProfileName := AnsiLowerCase(SourceICCProfileName);
  for I := 0 to InputICCProfileList.Count - 1 do
  begin
    Info := InputICCProfileList[I];
    if Info.Name = SourceICCProfileName then
      SourceICCProfileFile := Info.FileName;
  end;

  DestinationICCProfileFile := GetICCDisplayProfileFileName(DestinationICCProfileFile);

  dwFlags := cmsFLAGS_BLACKPOINTCOMPENSATION;

  Intent := IntentCodes[0];

  if ((SourceICCProfileFile <> '') or (SourceMem <> nil)) and (DestinationICCProfileFile <> '') then
  begin
    if SourceMem <> nil then
      hSrc := cmsOpenProfileFromMemTHR(ThreadContext, SourceMem, MemSize)
    else
      hSrc := cmsOpenProfileFromFileTHR(ThreadContext, PAnsiChar(AnsiString(SourceICCProfileFile)), 'r');

    hDest := cmsOpenProfileFromFileTHR(ThreadContext, PAnsiChar(AnsiString(DestinationICCProfileFile)), 'r');

    xform := nil;
    if (hSrc <> nil) and (hDest <> nil) then
      xform := cmsCreateTransformTHR(ThreadContext, hSrc, TYPE_BGR_8, hDest, TYPE_BGR_8, Intent, dwFlags);

    if hSrc <> nil then
      cmsCloseProfile(hSrc);

    if hDest <> nil then
      cmsCloseProfile(hDest);

    if (xform <> nil) then
    begin

      PicW := Bitmap.Width;
      PicH := Bitmap.Height;
      for I := 0 to PicH - 1 do
      begin
        Line := Bitmap.Scanline[I];
        cmsDoTransform(xform, Line, Line, PicW);
      end;
      cmsDeleteTransform(xform);
      Result := True;
    end;
  end
end;

function ConvertPngToDisplayICCProfile(ThreadContext: Pointer; Png: TPngImage; SourceMem: Pointer; MemSize: Cardinal; DestinationICCProfileFile: string = DEFAULT_ICC_DISPLAY_PROFILE): Boolean;
var
  hSrc, hDest: cmsHPROFILE;
  xform: cmsHTRANSFORM;
  I, PicW, PicH: Integer;
  Intent: Integer;
  dwFlags: DWORD;
  Line: Pointer;
begin
  Result := False;
  if not InitICCProfiles then
    Exit;

  if (SourceMem = nil) then
    Exit;

  DestinationICCProfileFile := GetICCDisplayProfileFileName(DestinationICCProfileFile);

  dwFlags := cmsFLAGS_BLACKPOINTCOMPENSATION;

  Intent := IntentCodes[0];

  if (SourceMem <> nil) and (DestinationICCProfileFile <> '') then
  begin
    hSrc := cmsOpenProfileFromMemTHR(ThreadContext, SourceMem, MemSize);

    hDest := cmsOpenProfileFromFileTHR(ThreadContext, PAnsiChar(AnsiString(DestinationICCProfileFile)), 'r');

    xform := nil;
    if (hSrc <> nil) and (hDest <> nil) then
      xform := cmsCreateTransformTHR(ThreadContext, hSrc, TYPE_BGR_8, hDest, TYPE_BGR_8, Intent, dwFlags);

    if hSrc <> nil then
      cmsCloseProfile(hSrc);

    if hDest <> nil then
      cmsCloseProfile(hDest);

    if (xform <> nil) then
    begin

      PicW := Png.Width;
      PicH := Png.Height;
      for I := 0 to PicH - 1 do
      begin
        Line := Png.Scanline[I];
        cmsDoTransform(xform, Line, Line, PicW);
      end;
      cmsDeleteTransform(xform);
      Result := True;
    end;
  end
end;

function FillDisplayProfileList(List: TStrings): Boolean;
var
  ProfileInfo: TICCProfileInfo;
begin
  if not InitICCProfiles then
    Exit(False);

  for ProfileInfo in OutputICCProfileList do
    List.Add(ProfileInfo.Name);

  Result := True;
end;

function ConvertBitmapToDisplayICCProfile(ThreadContext: Pointer; Bitmap: TBitmap; SourceMem: Pointer; MemSize: Cardinal; SourceICCProfileName: string; DisplayProfileName: string = DEFAULT_ICC_DISPLAY_PROFILE): Boolean;
begin
  if DisplayProfileName = '' then
    Exit(False);

  if (SourceICCProfileName = '') and (SourceMem = nil) then
    Exit(False);

  if not InitICCProfiles then
    Exit(False);

  Result := ConvertBitmapICCProfile(ThreadContext, Bitmap, SourceMem, MemSize, SourceICCProfileName, DisplayProfileName);
end;

function GetICCProfileName(ThreadContext: Pointer; SourceMem: Pointer; MemSize: Cardinal): string;
var
  hProfile: cmsHPROFILE;
  Descrip: array [0 .. 256] of Char;
begin
  Result := '';
  if not InitICCProfiles then
    Exit;

  hProfile := cmsOpenProfileFromMemTHR(ThreadContext, SourceMem, MemSize);

  if hProfile <> nil then
  begin
    cmsGetProfileInfo(hProfile, cmsInfoDescription, 'EN', 'us', Descrip,  256);
    Result := Descrip;
  end;

  if hProfile <> nil then
    cmsCloseProfile(hProfile);
end;

initialization
  FSync := TCriticalSection.Create;

finalization
  FreeList(InputICCProfileList);
  FreeList(OutputICCProfileList);
  F(FSync);

end.
