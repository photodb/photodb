unit TestBitmapUtils;

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
  uBitmapUtils,
  uMediaInfo;

type
  TTestBitmapUtils = class(TTestCase)
  strict private
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestImageScale;
  end;

implementation

procedure TTestBitmapUtils.SetUp;
begin
  FailsOnMemoryLeak := True;
  FailsOnMemoryRecovery := True;
end;

procedure TTestBitmapUtils.TearDown;
begin
end;

procedure TTestBitmapUtils.TestImageScale;
var
  FileName: string;
  S, D: TBitmap;
  J: TJpegImage;
  I: Integer;
begin
  FileName := ExtractFileDir(ExtractFileDir(ExtractFileDir(ExtractFileDir(ExtractFileDir(Application.Exename))))) + '\Test Images\IMG_2702_small.jpg';

  J := TJpegImage.Create;
  J.LoadFromFile(FileName);
  S := TBitmap.Create;
  S.Assign(J);

  D := TBitmap.Create;

  for I := 0 to 100 do
    SmoothResize(500, 500, S, D);

  D.Free;
  S.Free;
  J.Free;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TTestBitmapUtils.Suite);
end.

