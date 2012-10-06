unit uImageSource;

interface

uses
  Vcl.Graphics;

type
  IImageSource = interface(IInterface)
    ['{382D130E-5746-4A6D-9C15-B2EEEF089F44}']
    function GetImage(FileName: string; Bitmap: TBitmap; var Width: Integer; var Height: Integer): Boolean;
  end;

implementation

end.
