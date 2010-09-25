unit UnitPackingTable;

interface

uses
  Classes, Dolphin_DB, Windows, Sysutils, UnitGroupsWork,
  ComObj, ActiveX, UnitDBDeclare;

type
  PackingTable = class(TThread)
  private
    { Private declarations }
    FText: string;
    FOptions: TPackingTableThreadOptions;
  protected
    procedure AddTextLine;
    procedure DoExit;
    procedure Execute; override;
  public
    constructor Create(Options: TPackingTableThreadOptions);
  end;

implementation

uses Language, CommonDBSupport;

procedure PackingTable.AddTextLine;
begin
 fOptions.WriteLineProc(Self,FText,LINE_INFO_OK);
// CMDForm.RichEdit1.Lines.Add(FText);
end;

procedure PackingTable.Execute;
begin
 FreeOnTerminate:=true;
 FText:=TEXT_MES_PACKING_MAIN_DB_FILE;
 Synchronize(AddTextLine);

 PackTable(fOptions.FileName);

 FText:=TEXT_MES_PACKING_END;
 synchronize(AddTextLine);
 synchronize(DoExit);
end;

procedure PackingTable.DoExit;
begin
 fOptions.OnEnd(Self);
// CMDForm.OnEnd(Self);
end;

constructor PackingTable.Create(Options: TPackingTableThreadOptions);
begin
  inherited Create(False);
  FOptions := Options;
end;

end.
