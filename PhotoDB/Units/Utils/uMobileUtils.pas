unit uMobileUtils;

interface

uses
  Windows,
  uLogger,
  Graphics,
  SysUtils,
  uResourceUtils,
  Dmitry.Utils.Files,
  uMemory,
  Registry,
  uGUIDUtils,
  uTranslate,
  uConstants,
  acWorkRes,
  uTime,
  Classes,
  Dmitry.Utils.System,
  uResources;

const
  FSLanguageFileName = 'Language.xml';
  FSLicenseFileName = 'License.txt';

type
  TInternalFSHeader = record
    Name: string[255];
    Size: Int64;
  end;

function CreateMobileDBFilesInDirectory(DestinationName: string): Boolean;
procedure UpdateExeResources(ExeFileName: string);
function ReadInternalFSContent(Name: string): string;
procedure LoadLanguageFromMobileFS(var Language: TLanguage; var LanguageCode: string);
procedure AddStyleToMobileEXE(Update: Cardinal);

implementation

function CreateMobileDBFilesInDirectory(DestinationName: string): Boolean;
begin
  CopyFile(PChar(ParamStr(0)), PChar(DestinationName), False);
  UpdateExeResources(DestinationName);
  Result := True;
end;

procedure UpdateExeResources(ExeFileName: string);
var
  MS: TMemoryStream;
  ScriptsDirectory, FileName,
  LanguageXMLFileName, LicenseTxtFileName: string;
  Header: TInternalFSHeader;
  Files: TStrings;
  Counter: Integer;
  Update: DWORD;

  procedure AddFileToStream(FileName: string; Name: string = ''; Content: string = '');
  var
    FS: TFileStream;
    SW: TStreamWriter;
    TMS: TMemoryStream;
  begin
    TW.I.Check('AddFileToStream: ' + FileName);
    if Name = '' then
      Name := ExtractFileName(FileName);

    if Content <> '' then
    begin
      TMS := TMemoryStream.Create;
      try
        SW := TStreamWriter.Create(TMS, TEncoding.UTF8);
        try
          SW.Write(Content);
          TMS.Seek(0, soFromBeginning);

          FillChar(Header, SizeOf(Header), #0);
          Header.Name := AnsiString(Name);
          Header.Size := TMS.Size;
          MS.Write(Header, SizeOf(Header));
          MS.CopyFrom(TMS, TMS.Size);
        finally
          F(SW);
        end;
      finally
        F(TMS);
      end;
      Exit;
    end;

    FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      FillChar(Header, SizeOf(Header), #0);
      Header.Name := AnsiString(Name);
      Header.Size := FS.Size;
      FS.Seek(0, soFromBeginning);
      MS.Write(Header, SizeOf(Header));
      MS.CopyFrom(FS, FS.Size);
    finally
      F(FS);
    end;
    TW.I.Check('AddFileToStream - END: ' + FileName);
  end;

begin
  TW.I.Check('UpdateExeResources start: ' + ExeFileName);
  MS := TMemoryStream.Create;
  Files := TStringList.Create;
  try
    AddFileToStream('', 'ID', GUIDToString(GetGUID));

    LanguageXMLFileName := ExtractFilePath(ParamStr(0)) + Format('Languages\%s%s.xml', [LanguageFileMask, TTranslateManager.Instance.Language]);
    AddFileToStream(LanguageXMLFileName, FSLanguageFileName);

    LicenseTxtFileName := ExtractFilePath(ParamStr(0)) + Format('Licenses\License%s.txt', [TTranslateManager.Instance.Language]);
    AddFileToStream(LicenseTxtFileName, FSLicenseFileName);

    ScriptsDirectory := ExtractFilePath(ParamStr(0)) + ScriptsFolder;
    GetFilesOfPath(ScriptsDirectory, Files);
    for FileName in Files do
      AddFileToStream(FileName);

    TW.I.Check('BeginUpdateResourceW');
    Counter := 0;
    Update := 0;
    repeat
      if Counter > 100 then
        Break;

      Update := BeginUpdateResourceW(PChar(ExeFileName), False);
      //in some cases file can be busy (IO error 32), just wait 10sec...
      if Update = 0 then
      begin
        Inc(Counter);
        Sleep(100);
      end;
    until Update <> 0;

    if Update = 0 then
    begin
      MessageBox(0, PChar(Format('An unexpected error occurred: %s', ['I/O Error: ' + IntToStr(GetLastError)])), PChar(TA('Error')), MB_OK + MB_ICONERROR);
      Exit;
    end;

    try
      TW.I.Check('LoadFileResourceFromStream');
      LoadFileResourceFromStream(Update, RT_RCDATA, 'MOBILE_FS', MS);
      AddStyleToMobileEXE(Update);
    finally
      TW.I.Check('EndUpdateResourceW');
      EndUpdateResourceW(Update, False);
    end;
  finally
    F(Files);
    F(MS);
  end;
  TW.I.Check('END');
end;

procedure AddStyleToMobileEXE(Update: Cardinal);
var
  StyleFileName: string;
  Reg: TRegistry;
  FS: TFileStream;
  MS: TMemoryStream;
begin
  TW.I.Start('LoadLanguageFromFile - START');

  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := Windows.HKEY_CURRENT_USER;
    Reg.OpenKey(RegRoot + cUserData + 'Style', False);
    StyleFileName := Reg.ReadString('FileName');
    if StyleFileName = '' then
      StyleFileName := DefaultThemeName;
  finally
    F(Reg);
  end;
  if StyleFileName <> '' then
  begin
    if Pos(':', StyleFileName) = 0 then
      StyleFileName := ExtractFilePath(ParamStr(0)) + StylesFolder + StyleFileName;
    try
      FS := TFileStream.Create(StyleFileName, fmOpenRead, fmShareDenyNone);
      try
        MS := TMemoryStream.Create;
        try
          MS.CopyFrom(FS, FS.Size);
          MS.Seek(0, soFromBeginning);
          LoadFileResourceFromStream(Update, PChar(StyleResourceSection), 'MOBILE_STYLE', MS);
        finally
          F(MS);
        end;
      finally
        F(FS);
      end;

    except
      on e: Exception do
        EventLog(e);
    end;
  end;
end;

function ReadInternalFSContent(Name: string): string;
var
  MS: TMemoryStream;
  Header: TInternalFSHeader;
  SR: TStringStream;
begin
  Result := '';
  MS := GetRCDATAResourceStream('MOBILE_FS');
  if MS = nil then
    Exit;
  try
    MS.Seek(0, soFromBeginning);
    while MS.Position <> MS.Size do
    begin
      MS.Read(Header, SizeOf(Header));
      if AnsiLowerCase(Name) = AnsiLowerCase(string(Header.Name)) then
      begin
        SR := TStringStream.Create(Result, TEncoding.UTF8);
        try
          SR.CopyFrom(MS, Header.Size);
          Result := SR.DataString;
          //Delete UTF8 marker
          if Result <> '' then
            Delete(Result, 1, 1);
          Break;
        finally
          F(SR);
        end;
      end;
      MS.Seek(Header.Size, soFromCurrent);
    end;
  finally
    F(MS);
  end;
end;

procedure LoadLanguageFromMobileFS(var Language : TLanguage; var LanguageCode : string);
begin
  Language := TLanguage.CreateFromXML(ReadInternalFSContent(FSLanguageFileName));
  LanguageCode := Language.Code;
end;

end.
