unit UnitBackUpTableThread;

interface

uses
  Classes, DB, Dolphin_DB, Forms, SysUtils, uFileUtils, uConstants;

type
  BackUpTableThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

  var Active : Boolean;

implementation

uses UnitGroupsWork, CommonDBSupport;

{ BackUpTableThread }

procedure BackUpTableThread.Execute;
var
  s : String;
//  FTable : TTable;
begin
 Active:=True;
 FreeOnTerminate:=True;
 if not fileexists(dbname) then exit;
 s:=GetDirectory(Application.ExeName);
 FormatDir(S);
 CreateDirA(GetAppDataDirectory+BackUpFolder);
 if (GetDBType(dbname)=DB_TYPE_MDB) then
 begin
{  Can't do it because table is locked!}
 end;
 DBkernel.WriteDateTime('Options','BackUpDateTime',Now);
end;

initialization

Active:=False;

end.
