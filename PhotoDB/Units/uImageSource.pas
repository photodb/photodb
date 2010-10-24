unit uImageSource;

interface

uses
  Graphics;

type
  IImageSource = interface(IInterface)
  ['{382D130E-5746-4A6D-9C15-B2EEEF089F44}']
    function GetImage(FileName : string; Bitmap : TBitmap) : Boolean;
  end;

implementation

end.
