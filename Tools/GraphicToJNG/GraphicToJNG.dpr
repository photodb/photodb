program GraphicToJNG;

{ Reduce EXE size by disabling as much of RTTI as possible (delphi 2009/2010) }
{$IF CompilerVersion >= 21.0}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  System.Classes,
  System.SysUtils,
  Vcl.Graphics,
  Dmitry.Graphics.Utils in '..\..\Dmitry\Dmitry.Graphics.Utils.pas',
  Dmitry.Memory in '..\..\Dmitry\Dmitry.Memory.pas',
  Dmitry.Graphics.Types in '..\..\Dmitry\Dmitry.Graphics.Types.pas',
  Dmitry.Imaging.JngImage in '..\..\Dmitry\Dmitry.Imaging.JngImage.pas';

var
  JNG: TJNGImage;
  MS: TMemoryStream;
  Picture: TPicture;

begin
  try
    MS := TMemoryStream.Create;
    try
      Picture := TPicture.Create;
      JNG := TJNGImage.Create;
      try
        Picture.LoadFromFile(ParamStr(1));

        JNG.Assign(Picture.Graphic);

        JNG.SaveToFile(ParamStr(2));
      finally
        JNG.Free;
      end;
    finally
      MS.Free;
    end;
  except
    on e: Exception do
      Writeln(e.ToString);
  end;
end.
