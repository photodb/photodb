unit uInstallCloseRelatedApplications;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  System.Classes,
  System.SysUtils,

  Dmitry.Utils.System,

  uMemory,
  uMemoryEx,
  uActions,
  uInstallUtils,
  uInstallScope;

const
  InstallPoints_Related_Apps = 1024 * 1024;

type
  TInstallCloseRelatedApplications = class(TInstallAction)
  private
    function NotifyUserAboutClosingApplication(AppList: TStrings): Boolean;
  public
    function CalculateTotalPoints: Int64; override;
    procedure Execute(Callback: TActionCallback); override;
  end;

implementation

uses
  uFormBusyApplications;

{ TInstallCloseRelatedApplications }

function TInstallCloseRelatedApplications.CalculateTotalPoints: Int64;
begin
  Result := InstallPoints_Related_Apps;
end;

procedure TInstallCloseRelatedApplications.Execute(Callback: TActionCallback);
var
  I: Integer;
  DiskObject: TDiskObject;
  ObjectPath: string;
  Dlls, Applications: TStrings;
begin
  Dlls := TStringList.Create;
  Applications := TStringList.Create;
  try
    for I := 0 to CurrentInstall.Files.Count - 1 do
    begin
      DiskObject := CurrentInstall.Files[I];

      ObjectPath := ResolveInstallPath(IncludeTrailingBackslash(DiskObject.FinalDestination) + DiskObject.Name);
      if AnsiLowerCase(ExtractFileExt(ObjectPath)) = '.dll' then
        Dlls.Add(ObjectPath);
    end;

    FindModuleUsages(Dlls, Applications);
    while Applications.Count > 0 do
    begin
      if not NotifyUserAboutClosingApplication(Applications) then
      begin
        Terminate;
        Break;
      end;
      FindModuleUsages(Dlls, Applications);
    end;
  finally
    F(Dlls);
    F(Applications);
  end;
end;

function TInstallCloseRelatedApplications.NotifyUserAboutClosingApplication(
  AppList: TStrings): Boolean;
var
  ApplicationForm: TFormBusyApplications;
begin
  ApplicationForm := TFormBusyApplications.Create(nil);
  try
    Result := ApplicationForm.Execute(AppList);
  finally
    R(ApplicationForm);
  end;
end;

end.
