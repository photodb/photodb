program GraphicToJNG;

uses
  System.Classes,
  System.SysUtils,
  Vcl.Graphics,
  Dmitry.Graphics.Utils in 'C:\DmitryDPK\Dmitry.Graphics.Utils.pas',
  Dmitry.Memory in 'C:\DmitryDPK\Dmitry.Memory.pas',
  Dmitry.Graphics.Types in 'C:\DmitryDPK\Dmitry.Graphics.Types.pas',
  Dmitry.Imaging.JngImage in 'C:\DmitryDPK\Dmitry.Imaging.JngImage.pas';

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
