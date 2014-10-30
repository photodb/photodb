unit GraphicSelectEx;

interface

uses
  Windows, Forms, Graphics, Messages, SysUtils, Classes, Controls,
  Dmitry.Graphics.Types, Math, JPEG, Dmitry.Memory;

const
  Coolfill_plus = 0;
  Coolfill_replace = 1;

type
  TImageSelectEvent = procedure(Sender: TObject; Bitmap: TBitmap) of object;

type
  TJPEGContainerHeader = record
    ID: string[5];
    Version: Byte;
    Count: Byte;
    name: string[255];
  end;

type
  TGraphicSelectEx = class(Tcomponent)
  private
    { Private declarations }
    FArBit: array of TBitmap;
    FIcon: TIcon;
    Form: TForm;
    FWidthCount: Integer;
    FHeightCount: Integer;
    FColor: TColor;
    FPicture: TBitmap;
    FThHeight: Integer;
    FThWidth: Integer;
    Fselpic: Integer;
    Fcountpic: Integer;
    FSelColor: Tcolor;
    FOnImageSelect: TImageSelectEvent;
    FShowGaleries: Boolean;
    FGaleries: TStrings;
    Ftextcolor: TColor;
    FOldSelgal: Integer;
    FGaleryNumber: Integer;
    FRealSizes: Boolean;
    FAutoSizeGaleries: Boolean;
    GalerySm: Integer;
    FSelCanMoveColor: Tcolor;
    procedure DrawGal(FForm : Boolean; Canvas: TCanvas; NumberOfGalery : Integer; State : Boolean;  var Bitmap : TBitmap);
    procedure Onformdeactivate(Sender : TObject);
    procedure OnFormKeyPress(Sender: TObject; var Key: Char);
    procedure SetHeightCount(const Value: integer);
    procedure SetWidthCount(const Value: integer);
    procedure SetColor(const Value: Tcolor);
    procedure OnFormPaint(Sender : TObject);
    procedure OnFormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
    procedure OnFormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
    procedure SetThHeight(const Value: integer);
    procedure SetThWidth(const Value: integer);
    procedure SetSelColor(const Value: Tcolor);
    procedure SetOnImageSelect(const Value: TImageSelectEvent);
    procedure SetGaleries(const Value: TStrings);
    procedure SetShowGaleries(const Value: Boolean);
    procedure SetAutoSizeGaleries(const Value: Boolean);
    procedure SetRealSizes(const Value: Boolean);
    procedure SetTextColor(const Value: Tcolor);
    procedure RecreateBitmaps;
    procedure SetGaleryNumber(const Value: Integer);
    procedure SetSelCanMoveColor(const Value: Tcolor);
  protected
    { Protected declarations }
  public
    { Public declarations }
    procedure CreateFPicture;
    constructor Create(AOwner: Tcomponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    procedure RequestPicture(X, Y: Integer);
    property ThWidth: Integer read FThWidth write SetThWidth;
    property ThHeight: Integer read FThHeight write SetThHeight;
    property WidthCount: Integer read FWidthCount write SetWidthCount;
    property HeightCount: Integer read FHeightCount write SetHeightCount;
    property Color: Tcolor read FColor write SetColor;
    property SelCanMoveColor: Tcolor read FSelCanMoveColor write SetSelCanMoveColor;
    property SelColor: Tcolor read FSelColor write SetSelColor;
    property OnImageSelect: TImageSelectEvent read FOnImageSelect write SetOnImageSelect;
    property Galeries: TStrings read FGaleries write SetGaleries;
    property ShowGaleries: Boolean read FShowGaleries write SetShowGaleries;
    property TextColor: Tcolor read FTextColor write SetTextColor;
    property GaleryNumber: Integer read FGaleryNumber write SetGaleryNumber;
    property RealSizes: Boolean read FRealSizes write SetRealSizes;
    property AutoSizeGaleries: Boolean read FAutoSizeGaleries write SetAutoSizeGaleries;
  end;

function ValidJPEGContainer(FileName: string): Boolean;
function SavePicturesToJPEGContainer(Directory, IcoFileName, FileName, name: string): Boolean;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Dm', [TGraphicSelectEx]);
end;

function ValidJPEGContainer(FileName: string): Boolean;
var
  Header: TJPEGContainerHeader;
  FS: TFileStream;
begin
  Result := False;
  try
    FS := TFileStream.Create(FileName, FmOpenRead);
  except
    Exit;
  end;
  try
    FS.read(Header, SizeOf(Header));
  finally
    F(FS);
  end;
  Result := Header.ID = 'JPGCT';
end;

function SavePicturesToJPEGContainer(Directory, IcoFileName, FileName, Name : String) : boolean;
var
  Header: TJPEGContainerHeader;
  FS: TFileStream;
  MS: TMemoryStream;
  JPEG: TJPEGImage;
  Ico: TIcon;
  Size: Integer;
  I, N: Integer;
begin
  Result := False;
  Header.ID := 'JPGCT';
  Header.Version := 1;
  N := 0;
  Directory := IncludeTrailingBackslash(Directory);
  for I := 1 to 26 do
    if not FileExists(Directory + IntToStr(I) + '.jpg') then
    begin
      N := I - 1;
    end;
  if N = 0 then
    Exit;
  Header.Count := N;
  Header.Name := ShortString(Name);
  FS := TFileStream.Create(FileName, FmOpenWrite or FmCreate);
  try
    FS.Write(Header, SizeOf(Header));
    MS := TMemoryStream.Create;
    try
      Ico := TIcon.Create;
      try
        Ico.LoadFromFile(IcoFileName);
        Ico.SaveToStream(MS);
      finally
        F(Ico);
      end;
      MS.Seek(0, SoFromBeginning);
      Size := MS.Size;
      FS.Write(Size, SizeOf(Size));
      FS.CopyFrom(MS, MS.Size);
    finally
      F(MS);
    end;

    for I := 1 to 25 do
    begin
      MS := TMemoryStream.Create;
      try
        JPEG := TJPEGImage.Create;
        try
          if FileExists(Directory + IntToStr(I) + '.jpg') then
            JPEG.LoadFromFile(Directory + IntToStr(I) + '.jpg');
          JPEG.SaveToStream(MS);
          MS.Seek(0, SoFromBeginning);
        finally
          F(JPEG);
        end;
        Size := MS.Size;
        FS.write(Size, SizeOf(Size));
        FS.CopyFrom(MS, MS.Size);
      finally
        F(MS);
      end;
    end;
  finally
    F(FS);
  end;
  Result := True;
end;

function PlusValue(I: Integer): Integer;
begin
  if I < 0 then
    Result := 0
  else
    Result := I;
end;

procedure Fillcool(Bitmap: Tbitmap; Rect: Trect; Color: Tcolor; Steeps: Integer; Options: Integer); // overload;
var
  I, J: Integer;
  T: Integer;
  P: Pargb;
begin
  if Steeps = 0 then
    Exit;
  if Rect.Top <= 0 then
    Rect.Top := 1;
  if Rect.Left <= 0 then
    Rect.Left := 1;
  for I := Rect.Top - 1 to Rect.Bottom - 1 do
  begin
    P := Bitmap.ScanLine[I];
    for J := Rect.Left - 1 to Rect.Right - 1 do
    begin

      if Options = Coolfill_plus then
      begin
        /// //////////////////////////
        // LEFT
        T := P[J].R + Round(Plusvalue(Steeps - (Rect.Right - J)) * Getrvalue(Color) / Steeps);
        // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].R := 255
        else
          P[J].R := T;
        T := P[J].G + Round(Plusvalue(Steeps - (Rect.Right - J)) * Getgvalue(Color) / Steeps);
        // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].G := 255
        else
          P[J].G := T;
        T := P[J].B + Round(Plusvalue(Steeps - (Rect.Right - J)) * Getbvalue(Color) / Steeps);
        // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].B := 255
        else
          P[J].B := T;
        /// /////////////////////////
        // RIGHT
        T := P[J].R + Round(Plusvalue(Steeps - J) * Getrvalue(Color) / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].R := 255
        else
          P[J].R := T;
        T := P[J].G + Round(Plusvalue(Steeps - J) * Getgvalue(Color) / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].G := 255
        else
          P[J].G := T;
        T := P[J].B + Round(Plusvalue(Steeps - J) * Getbvalue(Color) / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].B := 255
        else
          P[J].B := T;
        /// //////////////////////////
        // UP
        T := P[J].R + Round(Plusvalue(Steeps - (Rect.Bottom - I)) * Getrvalue(Color) / Steeps);
        // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].R := 255
        else
          P[J].R := T;
        T := P[J].G + Round(Plusvalue(Steeps - (Rect.Bottom - I)) * Getgvalue(Color) / Steeps);
        // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].G := 255
        else
          P[J].G := T;
        T := P[J].B + Round(Plusvalue(Steeps - (Rect.Bottom - I)) * Getbvalue(Color) / Steeps);
        // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].B := 255
        else
          P[J].B := T;
        /// /////////////////////////
        // DOWN
        T := P[J].R + Round(Plusvalue(Steeps - I) * Getrvalue(Color) / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].R := 255
        else
          P[J].R := T;
        T := P[J].G + Round(Plusvalue(Steeps - I) * Getgvalue(Color) / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].G := 255
        else
          P[J].G := T;
        T := P[J].B + Round(Plusvalue(Steeps - I) * Getbvalue(Color) / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].B := 255
        else
          P[J].B := T;
      end;

      if Options = Coolfill_replace then
      begin
        /// //////////////////////////
        // LEFT
        T := Round(P[J].R * (Steeps - Plusvalue(Steeps - J)) / Steeps + Plusvalue(Steeps - J) * Getrvalue(Color)
            / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].R := 255
        else
          P[J].R := T;
        T := Round(P[J].G * (Steeps - Plusvalue(Steeps - J)) / Steeps + Plusvalue(Steeps - J) * Getgvalue(Color)
            / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].G := 255
        else
          P[J].G := T;
        T := Round(P[J].B * (Steeps - Plusvalue(Steeps - J)) / Steeps + Plusvalue(Steeps - J) * Getbvalue(Color)
            / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].B := 255
        else
          P[J].B := T;
        /// /////////////////////////
        // RIGHT
        T := Round(P[J].R * (Steeps - Plusvalue(J - Rect.Right + Steeps)) / Steeps + Plusvalue(J - Rect.Right + Steeps)
            * Getrvalue(Color) / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].R := 255
        else
          P[J].R := T;
        T := Round(P[J].G * (Steeps - Plusvalue(J - Rect.Right + Steeps)) / Steeps + Plusvalue(J - Rect.Right + Steeps)
            * Getgvalue(Color) / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].G := 255
        else
          P[J].G := T;
        T := Round(P[J].B * (Steeps - Plusvalue(J - Rect.Right + Steeps)) / Steeps + Plusvalue(J - Rect.Right + Steeps)
            * Getbvalue(Color) / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].B := 255
        else
          P[J].B := T;
        /// //////////////////////////
        // LEFT
        T := Round(P[J].R * (Steeps - Plusvalue(Steeps - I)) / Steeps + Plusvalue(Steeps - I) * Getrvalue(Color)
            / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].R := 255
        else
          P[J].R := T;
        T := Round(P[J].G * (Steeps - Plusvalue(Steeps - I)) / Steeps + Plusvalue(Steeps - I) * Getgvalue(Color)
            / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].G := 255
        else
          P[J].G := T;
        T := Round(P[J].B * (Steeps - Plusvalue(Steeps - I)) / Steeps + Plusvalue(Steeps - I) * Getbvalue(Color)
            / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].B := 255
        else
          P[J].B := T;
        /// /////////////////////////
        // RIGHT
        T := Round(P[J].R * (Steeps - Plusvalue(I - Rect.Bottom + Steeps)) / Steeps + Plusvalue
            (I - Rect.Bottom + Steeps) * Getrvalue(Color) / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].R := 255
        else
          P[J].R := T;
        T := Round(P[J].G * (Steeps - Plusvalue(I - Rect.Bottom + Steeps)) / Steeps + Plusvalue
            (I - Rect.Bottom + Steeps) * Getgvalue(Color) / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].G := 255
        else
          P[J].G := T;
        T := Round(P[J].B * (Steeps - Plusvalue(I - Rect.Bottom + Steeps)) / Steeps + Plusvalue
            (I - Rect.Bottom + Steeps) * Getbvalue(Color) / Steeps); // round(plusvalue(rect.Right-rect.Left-j)*255/(255/abs(rect.Left - rect.Right)));
        if T > 255 then
          P[J].B := 255
        else
          P[J].B := T;
      end;
    end;
  end;
end;

procedure StretchCool(Width, Height: Integer; Src, Dest: TBitmap); overload;
var
  I, J, K, P: Integer;
  P2, P1: Pargb;
  Col, R, G, B, Dobx, Doby, T1, T2: Integer;
begin
  Src.PixelFormat := pf24bit;
  Dest.PixelFormat := pf24bit;
  Dest.Width := Width;
  Dest.Height := Height;
  P2 := nil;
  if Src.Width >= Width then
    Dobx := -1
  else
    Dobx := 0;
  if Src.Height >= Height then
    Doby := -1
  else
    Doby := 0;
  for I := 0 to Height - 1 do
  begin
    P1 := Dest.ScanLine[I];
    for J := 0 to Width - 1 do
    begin
      Col := 0;
      R := 0;
      G := 0;
      B := 0;
      if Doby <> 0 then
        T1 := Round((Src.Height / Height) * (I + 1)) + Doby
      else
        T1 := Floor((Src.Height / Height) * (I + 1));
      for K := Round((Src.Height / Height) * (I)) to T1 do
      begin
        if K < Src.Height then
          P2 := Src.ScanLine[K]
        else
          Continue;
        if Dobx <> 0 then
          T2 := Round((Src.Width / Width) * (J + 1)) + Doby
        else
          T2 := Floor((Src.Width / Width) * (J + 1));
        for P := Round((Src.Width / Width) * (J)) to T2 do
        begin
          if P < Src.Width then
          begin
            Inc(Col);
            Inc(R, P2[P].R);
            Inc(G, P2[P].G);
            Inc(B, P2[P].B);
          end;
        end;
      end;
      if Col <> 0 then
      begin
        P1[J].R := Round((R / Col));
        P1[J].G := Round((G / Col));
        P1[J].B := Round((B / Col));
      end;
    end;
  end;
end;

procedure StretchCool(Width, Height: Integer; var Image: TBitmap); overload;
var
  TmpBitmap: TBitmap;
begin
  TmpBitmap := TBitmap.Create;
  try
    StretchCool(Width, Height, Image, TmpBitmap);
    F(Image);
    Image := TmpBitmap;
    TmpBitmap := nil;
  finally
    F(TmpBitmap);
  end;
end;

{ TGraphicSelectEx }

procedure TGraphicSelectEx.RecreateBitmaps;
var
  I: Integer;
  Header: TJPEGContainerHeader;
  FS: TFileStream;
begin
  if Galeries.Count = 0 then
    Exit;
  for I := 0 to Length(FArBit) - 1 do
    FArBit[I].Free;
  SetLength(FArBit, 0);
  try
    FS := TFileStream.Create(Galeries[FGaleryNumber + GalerySm - 1], FmOpenRead);
  except
    Exit;
  end;
  try
    FS.Read(Header, SizeOf(Header));
  finally
    F(FS);
  end;
  FCountPic := Header.Count + 1;
  SetLength(FArBit, FCountPic);
  for I := 0 to FCountPic - 1 do
    FArBit[I] := TBitmap.Create;
end;

procedure TGraphicSelectEx.CreateFPicture;
var
  I, J: Integer;
  Temp: TBitmap;
  H, W, H0, W0, Size: Integer;
  Header: TJPEGContainerHeader;
  FS: TFileStream;
  MS: TmemoryStream;
  JPEG: TJPEGImage;
  X: array of Byte;
begin
  if Galeries.Count = 0 then
    Exit;
  RecreateBitmaps;
  Temp := TBitmap.Create;
  try
    FPicture.Width := 0;
    FPicture.Height := 0;
    FPicture.Width := (Fthwidth + 2) * Fwidthcount + 2;
    if FShowGaleries then
      FPicture.Width := FPicture.Width + Fthwidth + 2;
    FPicture.Height := (FthHeight + 2) * FHeightcount + 2;
    FPicture.Canvas.Pen.Color := Fcolor;
    FPicture.Canvas.Brush.Color := Fcolor;
    FPicture.Canvas.Rectangle(0, 0, Fpicture.Width, Fpicture.Height);
    Form.Width := FPicture.Width;
    Form.Height := FPicture.Height;
    try
      FS := TFileStream.Create(Galeries[FGaleryNumber + GalerySm - 1], FmOpenRead);
    except
      Exit;
    end;
    try
      FS.read(Header, SizeOf(Header));
      if Header.ID <> 'JPGCT' then
        Exit;

      F(FIcon);

      FS.read(Size, SizeOf(Size));
      SetLength(X, Size);
      FS.Read(Pointer(X)^, Size);
      MS := TMemoryStream.Create;
      try
        MS.Write(Pointer(X)^, Size);
        SetLength(X, 0);
        FIcon := TIcon.Create;
        MS.Seek(0, SoFromBeginning);
        FIcon.LoadFromStream(MS);
      finally
        F(MS);
      end;

      for I := 1 to HeightCount do
        for J := 1 to WidthCount do
        begin
          if (I - 1) * WidthCount + J >= FCountpic then
            Break;
          FS.Read(Size, SizeOf(Size));
          SetLength(X, Size);
          FS.Read(Pointer(X)^, Size);
          MS := TMemoryStream.Create;
          try
            MS.write(Pointer(X)^, Size);
            SetLength(X, 0);
            JPEG := TJPEGImage.Create;
            try
              MS.Seek(0, SoFromBeginning);
              JPEG.LoadFromStream(MS);
              Temp.Assign(JPEG);
            finally
              F(JPEG);
            end;
          finally
            F(MS);
          end;

          if FRealsizes then
          begin
            FArbit[(I - 1) * WidthCount + J - 1].Canvas.Brush.Color := Color;
            FArbit[(I - 1) * WidthCount + J - 1].Canvas.Pen.Color := Color;
            FArbit[(I - 1) * WidthCount + J - 1].Canvas.Rectangle(0, 0, Fthwidth, Fthheight);
            H := Temp.Height;
            W := Temp.Width;
            W0 := Fthwidth;
            H0 := Fthheight;
            if (H / W) * (Fthwidth / Fthheight) <= 1 then
              H0 := Round(Fthheight * (H / W) * (Fthwidth / Fthheight))
            else
              W0 := Round(Fthwidth * (W / H) * (Fthheight / Fthwidth));
            StretchCool(W0, H0, Temp);
            FArbit[(I - 1) * WidthCount + J - 1].Width := Fthwidth;
            FArbit[(I - 1) * WidthCount + J - 1].Height := Fthheight;
            FArbit[(I - 1) * WidthCount + J - 1].Canvas.Draw(Fthwidth div 2 - Temp.Width div 2,
              Fthheight div 2 - Temp.Height div 2, Temp);
          end else
            StretchCool(Fthwidth, Fthheight, Temp, FArbit[(I - 1) * WidthCount + J - 1]);

        end;
    finally
      F(FS);
    end;

    for I := 1 to HeightCount do
      for J := 1 to WidthCount do
      begin
        if (I - 1) * WidthCount + J >= Fcountpic then
          Break;
        Fpicture.Canvas.Draw(2 + (J - 1) * (2 + FthWidth), 2 + (I - 1) * (2 + Fthheight),
          FArbit[(I - 1) * WidthCount + J - 1]);
      end;
    for I := 1 to Min(5, FGaleries.Count) do
      DrawGal(True, FPicture.Canvas, I, False, Temp);
  finally
    F(Temp);
  end;
end;

constructor TGraphicSelectEx.Create(AOwner: Tcomponent);
begin
  inherited;
  GalerySm := 0;
  SetLength(FArbit, 0);
  FIcon := nil;
  FAutoSizeGaleries := False;
  FRealSizes := True;
  Foldselgal := 0;
  FWidthCount := 5;
  FHeightCount := 5;
  FthWidth := 48;
  FthHeight := 48;
  FSelPic := 1;
  FColor := $FFFFFF;
  FSelcolor := $FF3333;
  FSelCanMoveColor := $8833AA;
  FGaleryNumber := 1;
  FGaleries := TStringList.Create;
  FPicture := TBitmap.Create;
  Form := TForm.Create(nil);
  Form.FormStyle := Fsstayontop;
  Form.OnDeactivate := Onformdeactivate;
  Form.BorderStyle := Bsnone;
  Form.OnPaint := Onformpaint;
  Form.OnMouseMove := OnformMouseMove;
  Form.OnMouseDown := OnformMouseDown;
  Form.Onkeypress := Onformkeypress;
  FCountPic := 1;
  CreateFPicture;
end;

procedure TGraphicSelectEx.OnFormMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I, Selgal: Integer;
begin
  if (X div (FThWidth + 2) >= WidthCount) then
  begin
    Selgal := Y div (FThheight + 2) + 1;
    if Selgal > Galeries.Count then
      Exit;

    FGaleryNumber := Selgal;
    if (Selgal = 1) and (FGaleries.Count > 5) and (GalerySm > 0) then
    begin
      Inc(FGaleryNumber);
      Dec(GalerySm);
    end;
    if (Selgal = 5) and (FGaleries.Count > 5) and (GalerySm + Selgal < FGaleries.Count) then
    begin
      Dec(FGaleryNumber);
      Inc(GalerySm);
    end;
    for I := 0 to Length(FArbit) - 1 do
      FArbit[I].Free;
    SetLength(FArbit, 0);
    Fcountpic := 1;
    Fselpic := 0;
    Foldselgal := 0;
    CreateFPicture;
    Form.Canvas.Draw(0, 0, FPicture);
  end else
  begin
    Form.Hide;
    if Button = MbRight then
      Exit;
    if X div (FThWidth + 2) > WidthCount then
      Exit;
    Fselpic := (X div (FThWidth + 2)) + (Y div (FThheight + 2)) * WidthCount;
    if Assigned(FOnImageSelect) then
      FOnImageSelect(Self, FArbit[FSelPic]);
  end;
end;

procedure TGraphicSelectEx.DrawGal(FForm: Boolean; Canvas: TCanvas; NumberOfGalery: Integer; State: Boolean;
  var Bitmap: Tbitmap);
var
  Drawrect: TRect;
  S: string;
  Header: TJPEGContainerHeader;
  FS: TFileStream;
  MS: TmemoryStream;
  X: array of Byte;
  Color: TColor;
  Ic: TIcon;
  Size: Integer;
begin

  try
    FS := TFileStream.Create(Galeries[NumberOfGalery + GalerySm - 1], FmOpenRead);
  except
    Exit;
  end;
  try
    FS.Read(Header, SizeOf(Header));
    if Header.ID <> 'JPGCT' then
      Exit;

    FS.Read(Size, SizeOf(Size));
    SetLength(X, Size);
    FS.Read(Pointer(X)^, Size);
    MS := TMemoryStream.Create;
    try
      MS.Write(Pointer(X)^, Size);
      SetLength(X, 0);
      Ic := TIcon.Create;
      try
        MS.Seek(0, SoFromBeginning);
        Ic.LoadFromStream(MS);
        Bitmap.Width := Fthwidth;
        Bitmap.Height := Fthheight;
        Bitmap.Canvas.Brush.Color := Fcolor;
        Bitmap.Canvas.Pen.Color := Fcolor;
        Bitmap.Canvas.Rectangle(0, 0, Bitmap.Width, Bitmap.Height);
        Bitmap.PixelFormat := pf24bit;
        Bitmap.Canvas.Draw(10, 5, Ic);
      finally
        F(Ic);
      end;
    finally
      F(MS);
    end;
  finally
    F(FS);
  end;
  if State then
  begin
    if ((NumberOfGalery = 1) and (FGaleries.Count > 5) and (GalerySm > 0)) or
      ((NumberOfGalery = 5) and (FGaleries.Count > 5) and (GalerySm + NumberOfGalery < FGaleries.Count)) then
    begin
      Fillcool(Bitmap, Rect(1, 1, Bitmap.Width, Bitmap.Height), FSelCanMoveColor, 7, 1);
    end else
    begin
      Fillcool(Bitmap, Rect(1, 1, Bitmap.Width, Bitmap.Height), FSelcolor, 7, 1);
    end;
  end;
  Bitmap.Canvas.Brush.Style := BsClear;
  Color := ColorToRGB(Form.Color);
  Color := RGB(255 - GetRValue(Color), 255 - GetGValue(Color), 255 - GetBValue(Color));
  Bitmap.Canvas.Font.Color := Color;
  S := string(Header.name);
  Drawrect.Left := 48 div 2 - Bitmap.Canvas.TextWidth(S) div 2;
  Drawrect.Top := Round(48 * 32 / 48);
  Drawrect.Bottom := 48;
  Drawrect.Right := 48;
  DrawText(Bitmap.Canvas.Handle, PChar(S), Length(S), Drawrect, DT_NOCLIP );

  StretchCool(Fthwidth, Fthheight, Bitmap);
  if not FForm then
    Form.Canvas.Draw(2 + (2 + FthWidth) * FWidthCount, 2 + (2 + FthHeight) * (NumberOfGalery - 1), Bitmap)
  else
    Canvas.Draw(2 + (2 + FthWidth) * FWidthCount, 2 + (2 + FthHeight) * (NumberOfGalery - 1), Bitmap);
end;

procedure TGraphicSelectEx.onFormMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  Bit1, B, Bold: TBitmap;
  Foldselpic, T, Selgal: Integer;
begin
  T := Fselpic;
  Foldselpic := Fselpic;
  if (X div (FThWidth + 2) >= WidthCount) then
  begin
    if Y div (FThheight + 2) + 1 = Foldselgal then
      Exit;
    if Y div (FThheight + 2) + 1 > Galeries.Count then
      Exit;
    Selgal := Y div (FThheight + 2) + 1;
    if not FGaleries.Count > 0 then
      Exit;
    Bit1 := TBitmap.Create;
    try
      DrawGal(False, nil, Selgal, True, Bit1);
      if FOldSelGal >= 1 then
        DrawGal(False, nil, Foldselgal, False, Bit1);
      FOldSelGal := Selgal;
    finally
      F(Bit1);
    end;
    Exit;
  end;
  Fselpic := (X div (FThWidth + 2)) + (Y div (FThheight + 2)) * WidthCount;
  if Foldselpic = Fselpic then
  begin
    Fselpic := T;
    Exit;
  end;
  B := TBitmap.Create;
  try
    B.Width := Fthwidth + 4;
    B.Height := Fthheight + 4;

    Bold := TBitmap.Create;
    try
      Bold.Width := Fthwidth + 4;
      Bold.Height := Fthheight + 4;
      Bold.Canvas.Brush.Color := Fcolor;
      Bold.Canvas.Pen.Color := Fcolor;
      Bold.Canvas.Rectangle(0, 0, FthWidth + 4, Fthheight + 4);

      B.Canvas.Brush.Color := Fselcolor;
      B.Canvas.Pen.Color := Fselcolor;
      B.Canvas.Rectangle(0, 0, FthWidth + 4, Fthheight + 4);
      if (Fselpic < Fcountpic - 1) and (Fselpic >= 0) then
      begin
        B.Canvas.Draw(2, 2, Farbit[Fselpic]);
        if (Foldselpic <= Fcountpic - 1) and (Foldselpic >= 0) then
        begin
          Bold.Canvas.Draw(2, 2, Farbit[Foldselpic]);
          Form.Canvas.Draw((Foldselpic mod WidthCount) * (2 + FthWidth), (Foldselpic div WidthCount) * (2 + Fthheight),
            Bold);
        end else
          Fselpic := T;
        Form.Canvas.Draw((Fselpic mod WidthCount) * (2 + FthWidth), (Fselpic div WidthCount) * (2 + Fthheight), B);
      end else
        Fselpic := T;
    finally
      F(Bold);
    end;
  finally
    F(B);
  end;
end;

procedure TGraphicSelectEx.OnFormPaint(Sender: TObject);
begin
  Form.Canvas.Draw(0, 0, FPicture);
end;

procedure TGraphicSelectEx.RequestPicture(X, Y: Integer);
begin
  if FGaleries.Count <> 0 then
  begin
    Form.Top := Y;
    Form.Left := X;
    Form.Show;
  end;
end;

procedure TGraphicSelectEx.SetColor(const Value: Tcolor);
begin
  FColor := Value;
  Form.Color := Fcolor;
  CreateFPicture;
end;

procedure TGraphicSelectEx.SetHeightCount(const Value: Integer);
begin
  FHeightCount := Value;
  CreateFPicture;
end;

procedure TGraphicSelectEx.SetOnImageSelect(const Value: TImageSelectEvent);
begin
  FOnImageSelect := Value;
end;

procedure TGraphicSelectEx.SetSelColor(const Value: Tcolor);
begin
  FSelColor := Value;
end;

procedure TGraphicSelectEx.SetThHeight(const Value: Integer);
begin
  FThHeight := Value;
  CreateFPicture;
end;

procedure TGraphicSelectEx.SetRealSizes(const Value: Boolean);
begin
  FRealSizes := Value;
  CreateFPicture;
end;

procedure TGraphicSelectEx.SetAutoSizeGaleries(const Value: Boolean);
begin
  FAutoSizeGaleries := Value;
end;

procedure TGraphicSelectEx.SetThWidth(const Value: Integer);
begin
  FThWidth := Value;
  CreateFPicture;
end;

procedure TGraphicSelectEx.SetWidthCount(const Value: Integer);
begin
  FWidthCount := Value;
  CreateFPicture;
end;

procedure TGraphicSelectEx.OnFormDeactivate(Sender : TObject);
begin
  if Form.CanFocus and Form.Visible then
    Form.SetFocus;
end;

procedure TGraphicSelectEx.OnFormKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_ESCAPE then
    Form.Hide;
end;

procedure TGraphicSelectEx.SetGaleries(const Value: TStrings);
begin
  FGaleries.Assign(Value);
  FGaleryNumber := 1;
  FOldSelGal := 1;
  if FGaleries.Count = 0 then
    Form.Visible := False
  else begin
    CreateFPicture;
    Form.Canvas.Draw(0, 0, FPicture);
  end;
end;

procedure TGraphicSelectEx.SetShowGaleries(const Value: Boolean);
begin
  FShowGaleries := Value;
  FGaleryNumber := 1;
  FOldSelGal := 1;
  if FGaleries.Count = 0 then
    Form.Visible := False
  else begin
    CreateFPicture;
    Form.Canvas.Draw(0, 0, FPicture);
  end;
end;

procedure TGraphicSelectEx.SetTextColor(const Value: Tcolor);
begin
  FTextColor := Value;
  CreateFPicture;
end;

procedure TGraphicSelectEx.SetGaleryNumber(const Value: Integer);
begin
  FGaleryNumber := Value;
  CreateFPicture;
end;

destructor TGraphicSelectEx.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(FArBit) - 1 do
    FArBit[I].Free;
  SetLength(FArBit, 0);
  F(FGaleries);
  F(FPicture);
  F(FIcon);
  Form.Release;
  inherited;
end;

procedure TGraphicSelectEx.SetSelCanMoveColor(const Value: Tcolor);
begin
  FSelCanMoveColor := Value;
end;

end.
