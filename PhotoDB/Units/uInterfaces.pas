unit uInterfaces;

interface

uses
  UnitDBDeclare;

type
  IDBImageSettings = interface(IInterface)
  ['{97343698-242E-4EB5-8972-5C443A97E1EA}']
    function GetImageOptions : TImageDBOptions;
  end;

implementation

end.
