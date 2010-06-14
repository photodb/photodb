unit BitmapDB;

interface

uses Graphics;

type
 TBitmap24 = Class(TBitmap)
 private
  fInfo : string;
 public
   constructor Create(Info : string); reintroduce;
 end;


implementation

{ TBitmap24 }

constructor TBitmap24.Create(Info : string);
begin
 inherited Create;
 fInfo:=Info;
 PixelFormat:=pf24bit;
end;


end.
