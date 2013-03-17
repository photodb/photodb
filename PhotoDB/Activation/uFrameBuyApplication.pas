unit uFrameBuyApplication;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,

  uFrameWizardBase,
  uSiteUtils;

type
  TFrameBuyApplication = class(TFrameWizardBase)
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Execute; override;
    function IsFinal: Boolean; override;
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
  end;

implementation

{$R *.dfm}

{ TFrameBuyApplication }

procedure TFrameBuyApplication.Execute;
begin
  inherited;
  IsStepComplete := True;
end;

procedure TFrameBuyApplication.Init(Manager: TWizardManagerBase; FirstInitialization: Boolean);
begin
  inherited;
  if FirstInitialization then
  begin
    DoBuyApplication;
    IsStepComplete := True;
  end;
end;

function TFrameBuyApplication.IsFinal: Boolean;
begin
  Result := True;
end;

end.
