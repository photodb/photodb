unit uAnimatedJPEG;

interface

uses
  Generics.Collections,
  Windows,
  SysUtils,
  uSysUtils,
  uMemory,
  Classes,
  Graphics,
  uBitmapUtils,
  uJpegUtils,
  StrUtils,
  jpeg;

type
  TAnimatedJPEG = class(TBitmap)
  private
    FImages: TList<TBitmap>;
    function GetCount: Integer;
    function GetImageByIndex(Index: Integer): TBitmap;
  protected
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure ResizeTo(Width, Height: Integer);
    property Count: Integer read GetCount;        
    property Images[Index: Integer]: TBitmap read GetImageByIndex;
  end;

implementation

{ TAnimatedJPEG }

constructor TAnimatedJPEG.Create;
begin
  FImages := TList<TBitmap>.Create;
end;

destructor TAnimatedJPEG.Destroy;
begin
  FreeList(FImages);
  inherited;
end;

function TAnimatedJPEG.GetCount: Integer;
begin
  Result := FImages.Count;
end;

function TAnimatedJPEG.GetImageByIndex(Index: Integer): TBitmap;
begin
  Result := FImages[Index];
end;

function AnsiPosEx(const SubStr, S: AnsiString; Offset: Integer): Integer;
var
  I, LIterCnt, L, J: Integer;
  PSubStr, PS: PAnsiChar;
begin
  if SubStr = '' then
    Exit(0);

  { Calculate the number of possible iterations. Not valid if Offset < 1. }
  LIterCnt := Length(S) - Offset - Length(SubStr) + 1;

  { Only continue if the number of iterations is positive or zero (there is space to check) }
  if (Offset > 0) and (LIterCnt >= 0) then
  begin
    L := Length(SubStr);
    PSubStr := PAnsiChar(SubStr);
    PS := PAnsiChar(S);
    Inc(PS, Offset - 1);

    for I := 0 to LIterCnt do
    begin
      J := 0;
      while (J >= 0) and (J < L) do
      begin
        if (PS + I + J)^ = (PSubStr + J)^ then
          Inc(J)
        else
          J := -1;
      end;
      if J >= L then
        Exit(I + Offset);
    end;
  end;

  Result := 0;
end;

procedure TAnimatedJPEG.LoadFromStream(Stream: TStream);
const
  JPEG_START: AnsiString = AnsiChar($FF) + AnsiChar($D8);
  JPEG_END: AnsiString = AnsiChar($FF) + AnsiChar($D9);
var
  I: Integer;
  P, Pos: Int64;
  J: TJpegImage;
  B, BHalf: TBitmap;
  PosList: TList<Integer>;
  S: AnsiString;
begin
  FreeList(FImages, False);
  Pos := Stream.Position;

  PosList := TList<Integer>.Create;
  try

    if Stream.Size > 0 then
    begin
      SetLength(S, Stream.Size);
      Stream.Read(Pointer(S)^, Stream.Size);
    end;

    P := 0;
    repeat
      P := AnsiPosEx(IIF(P = 0, JPEG_START, JPEG_END + JPEG_START), S, P + 1);
      if P > 0 then
        PosList.Add(IIF(PosList.Count = 0, P, P + 2));
    until P = 0;
    
    for I := 0 to PosList.Count - 1 do
    begin
      Stream.Seek(Pos + PosList[I] - 1, soFromBeginning);
      
      J := TJpegImage.Create;
      try
        try
          J.LoadFromStream(Stream);
          
          B := TBitmap.Create;
          try
            AssignJpeg(B, J);
            FImages.Add(B);
            B := nil;
            if FImages.Count = 2 then
              Break;
          finally
            F(B);
          end;
        except
          //failed to load image
          //don't throw any exceptions if this is not first image
          if FImages.Count = 0 then
            raise;
        end;
      finally
        F(J);
      end;
    end;
      
  finally
    F(PosList);
  end;
  
  Stream.Seek(Pos, soFromBeginning);
  if FImages.Count > 1 then
  begin
    Assign(FImages[0]);
  end else if FImages.Count = 1 then
  begin
    B := FImages[0];
    BHalf := TBitmap.Create;
    try
      if B.Width > 2 then
      begin
        BHalf.PixelFormat := pf24Bit;
        BHalf.SetSize(B.Width div 2, B.Height);
        DrawImageExRect(BHalf, B, 0, 0, B.Width div 2, B.Height, 0, 0);
        Assign(BHalf);
        FImages.Add(BHalf);
        
        BHalf := nil;
        BHalf := TBitmap.Create;
        
        BHalf.PixelFormat := pf24Bit;
        BHalf.SetSize(B.Width div 2, B.Height);
        DrawImageExRect(BHalf, B, B.Width div 2, 0, B.Width div 2, B.Height, 0, 0);
        FImages.Add(BHalf);

        FImages[0].Free;
        FImages.Delete(0);
        BHalf := nil;
      end;
    finally
      F(BHalf);
    end;
  end;
end;

procedure TAnimatedJPEG.ResizeTo(Width, Height: Integer);
var
  B, BI: TBitmap;
  I: Integer;
begin
  B := TBitmap.Create;
  try
    B.Assign(Self);
    uBitmapUtils.KeepProportions(B, 500, 500);
    Assign(B);
    for I := 0 to Count - 1 do
    begin
      BI := FImages[I];
      uBitmapUtils.KeepProportions(B, 500, 500);
      FImages[I] := BI;
    end;
  finally
    F(B);
  end;
end;

end.
