unit UnitPackingTable;

interface

uses
  Classes, DBTables, Dolphin_DB, Windows, Sysutils, UnitGroupsWork,
  ComObj, ActiveX, UnitDBDeclare;

type
  PackingTable = class(TThread)
  private
  FText : String;
  fOptions : TPackingTableThreadOptions;
    { Private declarations }
  protected
    procedure AddTextLine;
    procedure DoExit;
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: Boolean;
            Options : TPackingTableThreadOptions);
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

constructor PackingTable.Create(CreateSuspennded: Boolean;
  Options: TPackingTableThreadOptions);
begin
 inherited create(true);
 fOptions:=Options;
 if not CreateSuspennded then Resume;
end;

end.
