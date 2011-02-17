unit UnitPackingTable;

interface

uses
  Classes, Dolphin_DB, Windows, Sysutils, UnitGroupsWork,
  ComObj, ActiveX, UnitDBDeclare, uDBThread;

type
  PackingTable = class(TDBThread)
  private
    { Private declarations }
    FText: string;
    FOptions: TPackingTableThreadOptions;
  protected
    function GetThreadID : string; override;
    procedure Execute; override;
  public
   procedure AddTextLine;
    procedure DoExit;
    constructor Create(Options: TPackingTableThreadOptions);
  end;

implementation

uses Language, CommonDBSupport;

procedure PackingTable.AddTextLine;
begin
  FOptions.WriteLineProc(Self, FText, LINE_INFO_OK);
end;

procedure PackingTable.Execute;
begin
  FreeOnTerminate := True;
  try
    FText := L('Packing collection files...');
    Synchronize(AddTextLine);
    PackTable(FOptions.FileName);
    FText := L('Packing completed...');
    Synchronize(AddTextLine);
  finally
    Synchronize(DoExit);
  end;
end;

function PackingTable.GetThreadID: string;
begin
  Result := 'CMD';
end;

procedure PackingTable.DoExit;
begin
  FOptions.OnEnd(Self);
end;

constructor PackingTable.Create(Options: TPackingTableThreadOptions);
begin
  inherited Create(False);
  FOptions := Options;
end;

end.
