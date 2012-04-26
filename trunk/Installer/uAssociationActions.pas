unit uAssociationActions;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  uActions,
  SysUtils,
  uAssociations,
  uInstallScope,
  uConstants;

const
  InstallPoints_Association = 128 * 1024;

type
  TInstallAssociations = class(TInstallAction)
  private
    FCallback: TActionCallback;
    procedure OnInstallAssociationCallBack(Current, Total: Integer; var Terminate: Boolean);
  public
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback: TActionCallback); override;
  end;

implementation

{ TInstallExtensions }

function TInstallAssociations.CalculateTotalPoints: Int64;
begin
  Result := TFileAssociations.Instance.Count * InstallPoints_Association;
end;

procedure TInstallAssociations.Execute(Callback: TActionCallback);
begin
  FCallback := Callback;
  InstallGraphicFileAssociations(IncludeTrailingBackslash(CurrentInstall.DestinationPath) + PhotoDBFileName, OnInstallAssociationCallBack);
end;

procedure TInstallAssociations.OnInstallAssociationCallBack(Current, Total: Integer;
  var Terminate: Boolean);
begin
  FCallback(Self, InstallPoints_Association * Current, InstallPoints_Association * Total, Terminate);
end;


end.
