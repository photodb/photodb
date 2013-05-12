unit TestCreateCollection;

interface

uses
  TestFramework,

  Generics.Collections,
  System.Math,
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Imaging.Jpeg,

  uDBConnection,
  uShellUtils,
  uDBManager;

type
  TTestCreateCollection = class(TTestCase)
  strict private
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCreateCollection;
  end;

implementation

procedure TTestCreateCollection.SetUp;
begin
  FailsOnMemoryLeak := True;
  FailsOnMemoryRecovery := True;
end;

procedure TTestCreateCollection.TearDown;
begin
end;

procedure TTestCreateCollection.TestCreateCollection;
var
  TempFileName: string;
begin
  TempFileName := GetTempFileName;
  try
    TDBManager.CreateExampleDB(TempFileName);
  finally
    TryRemoveConnection(TempFileName, True);
    DeleteFile(TempFileName);
  end;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TTestCreateCollection.Suite);
end.

