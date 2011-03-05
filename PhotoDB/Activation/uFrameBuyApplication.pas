unit uFrameBuyApplication;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, uFrameWizardBase;

type
  TFrameBuyApplication = class(TFrameWizardBase)
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Execute; override;
    function IsFinal: Boolean; override;
  end;

implementation

{$R *.dfm}

{ TFrameBuyApplication }

procedure TFrameBuyApplication.Execute;
begin
  inherited;
  IsStepComplete := True;
end;

function TFrameBuyApplication.IsFinal: Boolean;
begin
  Result := True;
end;

end.
