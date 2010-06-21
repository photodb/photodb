unit UnitDBThread;

interface

uses
  Classes;

type
  TDBThread = class(TThread)
  private
    function GetIsTerminated: Boolean;
  public
    property IsTerminated : Boolean read GetIsTerminated;
  end;

implementation

{ TDBThread }

function TDBThread.GetIsTerminated: Boolean;
begin
  Result := Terminated;
end;

end.
 