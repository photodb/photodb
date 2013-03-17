unit UnitPackingTable;

interface

uses
  Classes,
  Windows, 
  Sysutils,
  ComObj,
  ActiveX,
  UnitDBDeclare,
  uDBThread,
  uDBForm;

type
  TPackingTableThreadOptions = record
    OwnerForm: TDBForm;
    FileName: string;
    OnEnd: TNotifyEvent;
    WriteLineProc: TWriteLineProcedure;
  end;

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

uses
  CommonDBSupport;

procedure PackingTable.AddTextLine;
begin
  FOptions.WriteLineProc(Self, FText, LINE_INFO_OK);
end;

procedure PackingTable.Execute;
begin
  inherited;
  FreeOnTerminate := True;
  try
    FText := L('Packing collection files...');
    SynchronizeEx(AddTextLine);
    PackTable(FOptions.FileName);
    FText := L('Packing completed...');
    SynchronizeEx(AddTextLine);
  finally
    SynchronizeEx(DoExit);
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
  inherited Create(Options.OwnerForm, False);
  FOptions := Options;
end;

end.
