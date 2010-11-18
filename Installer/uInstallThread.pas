unit uInstallThread;

interface

uses
  Classes;

type
  TInstallThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

{ TInstallThread }

procedure TInstallThread.Execute;
begin
  { Place thread code here }
end;

end.
