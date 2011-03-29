unit uMobileUtils;

interface

uses
  Windows, Graphics, SysUtils, Forms, uResourceUtils, uFileUtils, uMemory,
  Dolphin_DB, uTranslate, uShellIntegration, uConstants, acWorkRes,
  Classes;

const
  FSLanguageFileName = 'Language.xml';

type
  TInternalFSHeader = record
    Name: string[255];
    Size: Int64;
  end;

function CreateMobileDBFilesInDirectory(Directory, SaveToDBName  : string) : Boolean;
procedure UpdateExeResources(ExeFileName: string);
function ReadInternalFSContent(Name: string): string;
procedure LoadLanguageFromMobileFS(var Language : TLanguage; var LanguageCode : string);

implementation

function CreateMobileDBFilesInDirectory(Directory, SaveToDBName  : string) : Boolean;
var
  NewIcon : TIcon;
  IcoTempName, ExeFileName : string;
  Language : integer;
begin
  Directory := IncludeTrailingBackslash(Directory);
  ExeFileName := Directory + SaveToDBName + '.exe';
  CopyFile(PChar(Application.Exename), PChar(ExeFileName), False);
  UpdateExeResources(ExeFileName);
  if ID_YES = MessageBoxDB(GetActiveFormHandle, TA('Do you want to change the icon for the final collection?', 'Mobile'), TA('Question'),
    TD_BUTTON_YESNO, TD_ICON_QUESTION) then
  begin
    NewIcon := TIcon.Create;
    try
      if GetIconForFile(NewIcon, IcoTempName, Language) then
      begin
        NewIcon.SaveToFile(IcoTempName);

        ReplaceIcon(ExeFileName, PChar(IcoTempName));

        if FileExistsSafe(IcoTempName) then
          DeleteFile(IcoTempName);

      end;
    finally
      F(NewIcon);
    end;
  end;
  Result := True;
end;

procedure UpdateExeResources(ExeFileName: string);
var
  MS: TMemoryStream;
  ScriptsDirectory, FileName,
  LanguageXMLFileName: string;
  Header: TInternalFSHeader;
  Files: TStrings;
  Update: Integer;

  procedure AddFileToStream(FileName: string; Name: string = '');
  var
    FS: TFileStream;
  begin
    if Name = '' then
      Name := ExtractFileName(FileName);
    FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      Header.Name := AnsiString(Name);
      Header.Size := FS.Size;
      FS.Seek(0, soFromBeginning);
      MS.Write(Header, SizeOf(Header));
      MS.CopyFrom(FS, FS.Size);
    finally
      F(FS);
    end;
  end;

begin
  MS := TMemoryStream.Create;
  Files := TStringList.Create;
  try
    LanguageXMLFileName := ExtractFilePath(ParamStr(0)) + Format('Languages\%s%s.xml', [LanguageFileMask, TTranslateManager.Instance.Language]);
    AddFileToStream(LanguageXMLFileName, FSLanguageFileName);

    ScriptsDirectory := ExtractFilePath(ParamStr(0)) + ScriptsFolder;
    GetFilesOfPath(ScriptsDirectory, Files);
    for FileName in Files do
      AddFileToStream(FileName);

    Update := BeginUpdateResourceW(PChar(ExeFileName), False);
    if Update = 0 then
      Exit;
    try
      LoadFileResourceFromStream(Update, RT_RCDATA, 'MOBILE_FS', MS);
    finally
      EndUpdateResourceW(Update, False);
    end;
  finally
    F(Files);
    F(MS);
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
        //delete UTF8 marker
        if Result <> '' then
          Delete(Result, 1, 1);
        Break;
      finally
        F(SR);
      end;
    end;
    MS.Seek(Header.Size, soFromCurrent);
  end;
end;

procedure LoadLanguageFromMobileFS(var Language : TLanguage; var LanguageCode : string);
begin
  Language := TLanguage.CreateFromXML(ReadInternalFSContent(FSLanguageFileName));
end;

end.
