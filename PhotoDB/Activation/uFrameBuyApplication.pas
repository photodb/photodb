unit uFrameBuyApplication;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uFrameWizardBase, uConstants, Dolphin_DB;

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
