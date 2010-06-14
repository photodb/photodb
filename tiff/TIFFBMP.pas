unit TIFFBMP;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtDlgs, ExtCtrls, ToolWin, ComCtrls,IFD_Module,LZW_Module,
  DB, DBTables;//, GraphicStrings;
type
  PBitMapInfo = ^TBitMapInfo;
  TTIFFBitMap = class(TBitMap)
  private
    { Private declarations }
    IFD:TIFD;
    RGB_Palette:Integer;
    function IncAddress(Addr:Pointer; Shift:LongInt):Pointer; pascal;
    procedure RearrangeBytes(P:Pointer;PixelCount:DWord);
    procedure RearrangeBytes32(P:Pointer;PixelCount:DWord);
    procedure Depredict1(StartPtr:Pointer;PixelNumber:DWord);
    procedure Depredict3(StartPtr:Pointer;PixelNumber:DWord);
    procedure Depredict4(StartPtr:Pointer;PixelNumber:DWord);
    procedure ScrambleBitmapPalette(BPS:Byte;Mode:Integer;BMPInfo:PBitMapInfo);
    procedure ScramblePalette(BPS:Byte;Mode:Integer);
    procedure LoadFromFile(FileName: String);
  public
    { Public declarations }
    constructor Create;override;
    destructor Destroy;override;
    procedure LoadFromTifFile(FileName:String);
    procedure LoadFromStream(TiffStream:TStream); override;  
    procedure SaveToStream(TiffStream:TStream); override;
    procedure LoadFromTifFileEx(FileName:String);
    procedure SaveToTifFile(FileName:String;Compressing:Boolean);
    procedure SaveToTifFileSLZW(FileName:String;SmoothRange:TSmoothRange);
    procedure LoadTiffFromStream(TiffStream:TStream);
    procedure SaveTiffToStream(TiffStream:TStream;Compressing:Boolean);
    procedure LoadTiffFromBLOB(Source:TBlobField);
    procedure SaveTiffToBLOB(Destination:TBlobField;Compressing:Boolean);
  end;

  type
  TTIFFGraphic = TTIFFBitMap;

implementation


function TTIFFBitMap.IncAddress(Addr:Pointer; Shift:LongInt):Pointer; pascal;
var Adr:Pointer;
    Shft:LongInt;
begin
Adr:=Addr;
Shft:=Shift;
 asm
   PUSH    EAX
   MOV     EAX,Adr
   ADD     EAX,Shft
   MOV     @Result,EAX
   POP     EAX
 end;
end;

procedure TTIFFBitMap.RearrangeBytes(P:Pointer;PixelCount:DWord);
label START_POINT;
var PBuffer:Pointer;
    PCount:DWord;
begin
     PBuffer:=P;
     PCount:=PixelCount;
 asm
              PUSH ECX
              PUSH EBX
              PUSH EAX
              PUSH EDX
              MOV  ECX,PCount
              MOV  EBX,PBuffer
 START_POINT: MOV  EDX,EBX
              ADD  EDX,2
              MOV  AL,BYTE PTR [EBX]
              XCHG AL,BYTE PTR [EDX]
              MOV  BYTE PTR [EBX],AL
              ADD  EBX,3
              LOOP START_POINT
              POP EDX
              POP EAX
              POP EBX
              POP ECX
 end;
end;

procedure TTIFFBitMap.RearrangeBytes32(P:Pointer;PixelCount:DWord);
label START_POINT;
var PBuffer:Pointer;
    PCount:DWord;
begin
     PBuffer:=P;
     PCount:=PixelCount;
 asm
              PUSH ECX
              PUSH EBX
              PUSH EAX
              PUSH EDX
              MOV  ECX,PCount
              MOV  EBX,PBuffer
 START_POINT: MOV  EDX,EBX
              ADD  EDX,2
              MOV  AL,BYTE PTR [EBX]
              XCHG AL,BYTE PTR [EDX]
              MOV  BYTE PTR [EBX],AL
              ADD  EBX,4
              LOOP START_POINT
              POP EDX
              POP EAX
              POP EBX
              POP ECX
 end;
end;

procedure TTIFFBitMap.Depredict1(StartPtr:Pointer;PixelNumber:DWord);
label START_POINT;
var PBuffer:Pointer;
    PCount:DWord;
begin
     PBuffer:=StartPtr;
     PCount:=PixelNumber;
 asm
                  PUSH EAX
                  PUSH EBX
                  PUSH ECX
                  MOV  ECX,PCount
                  MOV  EBX,PBuffer
    START_POINT:  MOV  AL,BYTE PTR [EBX]
                  ADD  BYTE PTR [EBX+1],AL
                  INC  EBX
                  LOOP START_POINT
                  POP  ECX
                  POP  EBX
                  POP  EAX
 end;
end;

procedure TTIFFBitMap.Depredict3(StartPtr:Pointer;PixelNumber:DWord);
label START_POINT;
var PixNum:DWord;
    PBuffer:Pointer;
begin
     PixNum:=3*PixelNumber;
     PBuffer:=StartPtr;
 asm
                  PUSH EAX
                  PUSH EBX
                  PUSH ECX
                  MOV  ECX,PixNum
                  MOV  EBX,PBuffer
     START_POINT: MOV  AL,BYTE PTR [EBX]
                  ADD  BYTE PTR [EBX+3],AL
                  INC  EBX
                  LOOP START_POINT
                  POP  ECX
                  POP  EBX
                  POP  EAX
 end;
end;

procedure TTIFFBitMap.Depredict4(StartPtr:Pointer;PixelNumber:DWord);
label START_POINT;
var PixNum:DWord;
    PBuffer:Pointer;
begin
     PixNum:=4*PixelNumber;
     PBuffer:=StartPtr;
 asm
                  PUSH EAX
                  PUSH EBX
                  PUSH ECX
                  MOV  ECX,PixNum
                  MOV  EBX,PBuffer
     START_POINT: MOV  AL,BYTE PTR [EBX]
                  ADD  BYTE PTR [EBX+4],AL
                  INC  EBX
                  LOOP START_POINT
                  POP  ECX
                  POP  EBX
                  POP  EAX
 end;
end;

constructor TTIFFBitMap.Create;
begin
     inherited Create;
     Self.PixelFormat:=pf24bit;
     RGB_Palette:=Palette;
end;

Destructor TTIFFBitMap.Destroy;
begin
     inherited destroy;
end;

procedure TTIFFBitMap.ScrambleBitmapPalette(BPS:Byte;Mode:Integer;BMPInfo:PBitMapInfo);
var
  pal: PLogPalette;
  hpal: HPALETTE;
  i: Integer;
  EntryCount:Word;
begin
  pal := nil;
  Case BPS of
       1: EntryCount:=1;
       4: EntryCount:=15;
       8: EntryCount:=255;
       32: EntryCount:=3;
  end;
  try
    GetMem(pal, sizeof(TLogPalette) + sizeof(TPaletteEntry) * EntryCount);
    pal.palVersion := $300;
    pal.palNumEntries := 1+EntryCount;
    Case BPS of
         1: begin
                 Case Mode of
                      0: begin
                              for i := 0 to EntryCount do
                                  begin
                                       pal.palPalEntry[i].peRed := 255*(i);
                                       pal.palPalEntry[i].peGreen :=255*(i);
                                       pal.palPalEntry[i].peBlue := 255*(i);
                                       pal.palPalEntry[i].peFlags:=0;
                                  end;
                              i:=0;
                              BMPInfo^.bmiColors[i].rgbBlue:=255;
                              BMPInfo^.bmiColors[i].rgbGreen:=255;
                              BMPInfo^.bmiColors[i].rgbRed:=255;
                              BMPInfo^.bmiColors[i].rgbReserved:=0;
                              i:=1;
                              BMPInfo^.bmiColors[i].rgbBlue:=0;
                              BMPInfo^.bmiColors[i].rgbGreen:=0;
                              BMPInfo^.bmiColors[i].rgbRed:=0;
                              BMPInfo^.bmiColors[i].rgbReserved:=0;
                         end;
                      else
                          begin
                              for i := 0 to EntryCount do
                                  begin
                                       pal.palPalEntry[i].peRed := 255*(1-i);
                                       pal.palPalEntry[i].peGreen :=255*(1-i);
                                       pal.palPalEntry[i].peBlue := 255*(1-i);
                                       pal.palPalEntry[i].peFlags:=0;
                                  end;
                              i:=1;
                              BMPInfo^.bmiColors[i].rgbBlue:=255;
                              BMPInfo^.bmiColors[i].rgbGreen:=255;
                              BMPInfo^.bmiColors[i].rgbRed:=255;
                              BMPInfo^.bmiColors[i].rgbReserved:=0;
                              i:=0;
                              BMPInfo^.bmiColors[i].rgbBlue:=0;
                              BMPInfo^.bmiColors[i].rgbGreen:=0;
                              BMPInfo^.bmiColors[i].rgbRed:=0;
                              BMPInfo^.bmiColors[i].rgbReserved:=0;
                         end;
                 end;
            end;
         4: begin
                 case Mode of
                      0: begin
                              for i := 0 to EntryCount do
                                  begin
                                       pal.palPalEntry[EntryCount-i].peRed :=16*i;
                                       pal.palPalEntry[EntryCount-i].peGreen :=16*i;
                                       pal.palPalEntry[EntryCount-i].peBlue :=16*i;
                                       pal.palPalEntry[EntryCount-i].peFlags:=0;
                                       With BMPInfo^.bmiColors[EntryCount-i] do
                                            begin
                                                 rgbBlue:=16*(i+1)-1;
                                                 rgbGreen:=16*(i+1)-1;
                                                 rgbRed:=16*(i+1)-1;
                                                 rgbReserved:=0;
                                            end;
                                  end;
                         end;
                      1: begin
                              for i := 0 to EntryCount do
                                  begin
                                       pal.palPalEntry[i].peRed :=16*i;
                                       pal.palPalEntry[i].peGreen :=16*i;
                                       pal.palPalEntry[i].peBlue :=16*i;
                                       pal.palPalEntry[i].peFlags:=0;
                                       With BMPInfo^.bmiColors[i] do
                                            begin
                                                 rgbBlue:=16*(i+1)-1;
                                                 rgbGreen:=16*(i+1)-1;
                                                 rgbRed:=16*(i+1)-1;
                                                 rgbReserved:=0;
                                            end;
                                  end;
                         end;
                 end;
            end;
         8: begin
                 Case Mode  of
                      0: Begin
                              for i:= 0 to EntryCount do
                                  begin
                                       pal.palPalEntry[EntryCount-i].peRed := i;
                                       pal.palPalEntry[EntryCount-i].peGreen :=i;
                                       pal.palPalEntry[EntryCount-i].peBlue :=i;
                                       pal.palPalEntry[EntryCount-i].peFlags:=0;
                                       With BMPInfo^.bmiColors[EntryCount-i] do
                                            begin
                                                 rgbBlue:=i;
                                                 rgbGreen:=i;
                                                 rgbRed:=i;
                                                 rgbReserved:=0;
                                            end;
                                  end;
                          end;
                      1: Begin
                              for i:= 0 to EntryCount do
                                  begin
                                       pal.palPalEntry[i].peRed := i;
                                       pal.palPalEntry[i].peGreen :=i;
                                       pal.palPalEntry[i].peBlue :=i;
                                       pal.palPalEntry[i].peFlags:=0;
                                       With BMPInfo^.bmiColors[i] do
                                            begin
                                                 rgbBlue:=i;
                                                 rgbGreen:=i;
                                                 rgbRed:=i;
                                                 rgbReserved:=0;
                                            end;
                                  end;
                          end;
                      3: begin
                              for i := 0 to EntryCount do
                                  begin
                                       pal.palPalEntry[i].peRed :=  IFD.GetColor(i,0);
                                       pal.palPalEntry[i].peGreen := IFD.GetColor(i,1);
                                       pal.palPalEntry[i].peBlue :=  IFD.GetColor(i,2);
                                       pal.palPalEntry[i].peFlags:=0;
                                       With BMPInfo^.bmiColors[i] do
                                            begin
                                                 rgbBlue:=pal.palPalEntry[i].peBlue;
                                                 rgbGreen:=pal.palPalEntry[i].peGreen;
                                                 rgbRed:=pal.palPalEntry[i].peRed;
                                                 rgbReserved:=0;
                                            end;
                                  end;
                         end;
                 end;
            end;
         32 : begin
                   i:=0;
                   DWord(BMPInfo^.bmiColors[i]):=$FF;
                   i:=1;
                   DWord(BMPInfo^.bmiColors[i]):=$FF00;
                   i:=2;
                   DWord(BMPInfo^.bmiColors[i]):=$FF0000;
              end;
    end;
    If BPS<>32 then
       begin
            hpal := CreatePalette(pal^);
            if hpal <> 0 then Palette := hpal;
       end;
  finally
    FreeMem(pal, sizeof(TLogPalette) + sizeof(TPaletteEntry) * EntryCount);
  end;
end;

procedure TTIFFBitMap.ScramblePalette(BPS:Byte;Mode:Integer);
var
  pal: PLogPalette;
  hpal: HPALETTE;
  i: Integer;
  EntryCount:Word;
begin
  pal := nil;
  Case BPS of
       1: EntryCount:=1;
       4: EntryCount:=15;
       8: EntryCount:=255;
       32: EntryCount:=3;
  end;
  try
    GetMem(pal, sizeof(TLogPalette) + sizeof(TPaletteEntry) * EntryCount);
    pal.palVersion := $300;
    pal.palNumEntries := 1+EntryCount;
    Case BPS of
         1: begin
                 Case Mode of
                      0: begin
                              for i := 0 to EntryCount do
                                  begin
                                       pal.palPalEntry[i].peRed := 255*(i);
                                       pal.palPalEntry[i].peGreen :=255*(i);
                                       pal.palPalEntry[i].peBlue := 255*(i);
                                       pal.palPalEntry[i].peFlags:=0;
                                  end;
                         end;
                      else
                          begin
                              for i := 0 to EntryCount do
                                  begin
                                       pal.palPalEntry[i].peRed := 255*(1-i);
                                       pal.palPalEntry[i].peGreen :=255*(1-i);
                                       pal.palPalEntry[i].peBlue := 255*(1-i);
                                       pal.palPalEntry[i].peFlags:=0;
                                  end;
                         end;
                 end;
            end;
         4: begin
                 case Mode of
                      0: begin
                              for i := 0 to EntryCount do
                                  begin
                                       pal.palPalEntry[EntryCount-i].peRed :=16*i;
                                       pal.palPalEntry[EntryCount-i].peGreen :=16*i;
                                       pal.palPalEntry[EntryCount-i].peBlue :=16*i;
                                       pal.palPalEntry[EntryCount-i].peFlags:=0;
                                  end;
                         end;
                      1: begin
                              for i := 0 to EntryCount do
                                  begin
                                       pal.palPalEntry[i].peRed :=16*i;
                                       pal.palPalEntry[i].peGreen :=16*i;
                                       pal.palPalEntry[i].peBlue :=16*i;
                                       pal.palPalEntry[i].peFlags:=0;
                                  end;
                         end;
                 end;
            end;
         8: begin
                 Case Mode  of
                      0: Begin
                              for i:= 0 to EntryCount do
                                  begin
                                       pal.palPalEntry[EntryCount-i].peRed := i;
                                       pal.palPalEntry[EntryCount-i].peGreen :=i;
                                       pal.palPalEntry[EntryCount-i].peBlue :=i;
                                       pal.palPalEntry[EntryCount-i].peFlags:=0;
                                  end;
                          end;
                      1: Begin
                              for i:= 0 to EntryCount do
                                  begin
                                       pal.palPalEntry[i].peRed := i;
                                       pal.palPalEntry[i].peGreen :=i;
                                       pal.palPalEntry[i].peBlue :=i;
                                       pal.palPalEntry[i].peFlags:=0;
                                  end;
                          end;
                      3: begin
                              for i := 0 to EntryCount do
                                  begin
                                       pal.palPalEntry[i].peRed :=  IFD.GetColor(i,0);
                                       pal.palPalEntry[i].peGreen := IFD.GetColor(i,1);
                                       pal.palPalEntry[i].peBlue :=  IFD.GetColor(i,2);
                                       pal.palPalEntry[i].peFlags:=0;
                                  end;
                         end;
                 end;
            end;
    end;
    If BPS<>32 then
       begin
            hpal := CreatePalette(pal^);
            if hpal <> 0 then Palette := hpal;
       end;
  finally
    FreeMem(pal, sizeof(TLogPalette) + sizeof(TPaletteEntry) * EntryCount);
  end;
end;


Procedure TTIFFBitMap.LoadFromTifFile(FileName:String);
var FsizeB:DWord;
    VirtImage:pointer;
    PShift:^LongInt;
    Shift:LongInt;
    i,j,PalVolume:DWord;
    hFile:THandle;
    Error,ScanLines,RowSize:DWord;
    BMPInfo:PBitMapInfo;
    ppBitMapBits,StartData,CurrDecoding:Pointer;
    Decoder:TLZW;
Begin
     Height:=1;
     Width:=1;
     Self.FreeImage;
     hFile:=FileOpen(FileName,fmOpenRead or fmShareDenyNone);
     FSizeB:=GetFileSize(hFile,Nil);
     Error:=GetLastError;
     If Error<>0 Then MessageBeep(0)
     Else
         Begin
              GetMem(VirtImage,FSizeB);
              If FileRead(hFile,VirtImage^,FSizeB)<FSizeB then
                 MessageBox(0,'File not quite readed','Error!',0);;
              CloseHandle(hFile);
              PShift:=IncAddress(VirtImage,4);
              Shift:=PShift^;
              IFD:=TIFD.ReadCreate(VirtImage,Shift);
              self.Monochrome:=IFD.PhotometricInterpretation in [0,1]; //(IFD.BitsPerPixel=1);
              Case IFD.BitsPerPixel of
                   1: PalVolume:=2;
                   4: PalVolume:=16;
                   8: PalVolume:=256;
               16,32: PalVolume:=3;
                   else PalVolume:=0;
              end;
              GetMem(BMPInfo,SizeOf(TBitMapInfoHeader)+PalVolume*SizeOf(TRGBQuad));
              with IFD do
                   begin
                        BMPInfo^.bmiHeader.biSize:=SizeOf(TBitMapInfoHeader);
                        BMPInfo^.bmiHeader.biWidth:=IFD.Width;
                        BMPInfo^.bmiHeader.biHeight:=-IFD.Lenght;
                        BMPInfo^.bmiHeader.biPlanes:=1;
                        BMPInfo^.bmiHeader.biCompression:=0;
                        //if IFD.BitsPerPixel = 32 then BMPInfo^.bmiHeader.biCompression:=BI_BITFIELDS;
                        BMPInfo^.bmiHeader.biSizeImage:=0;
                        BMPInfo^.bmiHeader.biXPelsPerMeter:=0;
                        BMPInfo^.bmiHeader.biYPelsPerMeter:=0;
                        BMPInfo^.bmiHeader.biBitCount:=BitsPerPixel;
                        BMPInfo^.bmiHeader.biClrUsed:=0;
                        BMPInfo^.bmiHeader.biClrImportant:=0;
                   end;
              Case IFD.BitsPerPixel of
                   1: Begin
                           PixelFormat:= pf1bit;
                           ScrambleBitmapPalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation,BMPInfo);
                     end;
                   4: Begin
                           PixelFormat:= pf4bit;
                           ScrambleBitmapPalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation,BMPInfo);
                      end;
                   8: Begin
                           PixelFormat:= pf8bit;
                           ScrambleBitmapPalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation,BMPInfo);
                      end;
                   24: Begin
                            PixelFormat:= pf24bit;
                       end;
                   32: PixelFormat:= pf32bit;
              end;
              Self.Width:=IFD.Width;
              Self.Height:=IFD.Lenght;
              RowSize:=(IFD.BitsPerPixel*Width+7) div 8;
              case IFD.Compression of
                   1: begin
                           ScanLines:=0;
                           for j:=0 to IFD.StripeCount-1 do
                               begin
                                    ppBitMapBits:=IncAddress(IFD.FileHead,IFD.OffSets^[j]);
                                    case IFD.BitsPerPixel of
                                         24: Begin
                                                  if j<IFD.StripeCount-1 then
                                                     RearrangeBytes(ppBitMapBits,Width*IFD.RowsPerStrip)
                                                  else
                                                      RearrangeBytes(ppBitMapBits,Width*(Height-IFD.RowsPerStrip*(IFD.StripeCount-1)));
                                                  i:=IFD.RowsPerStrip*j;
                                                  While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                                                        begin
                                                             ScanLines:= ScanLines + SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                                                     ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);
                                                             ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                                             inc(i);
                                                        end;
                                             end;
                                         32: Begin
                                                  if j<IFD.StripeCount-1 then
                                                     RearrangeBytes32(ppBitMapBits,Width*IFD.RowsPerStrip)
                                                  else
                                                      RearrangeBytes32(ppBitMapBits,Width*(Height-IFD.RowsPerStrip*(IFD.StripeCount-1)));
                                                  i:=IFD.RowsPerStrip*j;
                                                  While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                                                        begin
                                                             ScanLines:= ScanLines + SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                                                     ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);
                                                             ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                                             inc(i);
                                                        end;
                                             end;
                                         else
                                             Begin
                                                  i:=IFD.RowsPerStrip*j;
                                                  While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                                                        begin
                                                             ScanLines:= ScanLines + SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                                                     ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);

                                                             ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                                             inc(i);
                                                        end;
                                             end;
                                    end;
                               end;
                      end;
                   5: begin
                           Decoder:=TLZW.Create;
                           GetMem(ppBitMapBits,Height*RowSize);
                           CurrDecoding:=ppBitMapBits;
                           for i:=0 to IFD.StripeCount-1 do
                               begin
                                    StartData:=IncAddress(IFD.FileHead,IFD.OffSets^[i]);
                                    Decoder.DecodeLZW(StartData,CurrDecoding);
                                    CurrDecoding:=IncAddress(CurrDecoding,RowSize*IFD.RowsPerStrip);
                               end;
                           StartData:=ppBitMapBits;
                           Case IFD.BitsPerPixel of
                           24:Begin
                                   RearrangeBytes(ppBitMapBits,Width*Height);
                                   for i:=0 to Height-1 do
                                       begin
                                            if IFD.Prediction then Depredict3(ppBitMapBits,Width-1);
                                            ScanLines:=ScanLines+SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                              ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);
                                            ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                       end;
                              end;
                           32:Begin
                                   RearrangeBytes32(ppBitMapBits,Width*Height);
                                   for i:=0 to Height-1 do
                                       begin
                                            if IFD.Prediction then Depredict4(ppBitMapBits,Width-1);
                                            ScanLines:=ScanLines+SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                              ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);
                                            ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                       end;
                              end;
                           else
                               Begin
                                    for i:=0 to Height-1 do
                                        Begin
                                             if IFD.Prediction then
                                                Case IFD.BitsPerPixel of
                                                     8: Depredict1(ppBitMapBits,Width-1);
                                                end;
                                             ScanLines:=ScanLines+SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                              ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);
                                             ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                        end;
                               end;
                           end;
                           FreeMem(StartData,Height*((IFD.BitsPerPixel*Width+7) div 8));
                           Decoder.Destroy;
                      end;
              end;
              If (IFD.PhotometricInterpretation  = 3) or (IFD.BitsPerPixel = 32) then
                 begin
                      PixelFormat:=pf24bit;
                      Palette:=RGB_Palette;
                 end;
              If ScanLines<Height Then MessageBox(0,'Picture reading failed!','Error',0);
              FreeMem(BMPInfo,SizeOf(TBitMapInfoHeader)+PalVolume*SizeOf(TRGBQuad));
              FreeMem(VirtImage,FSizeB);
              IFD.Destroy;
         End;
end;

Procedure TTIFFBitMap.LoadFromTifFileEx(FileName:String);
var FsizeB,StripeSize,RowSize:DWord;
    PShift:^LongInt;
    Shift:LongInt;
    i,j,PalVolume:DWord;
    hFile:THandle;
    Error,ScanLines:DWord;
    BMPInfo:PBitMapInfo;
    ppBitMapBits,StartData,CurrDecoding:Pointer;
    Decoder:TLZW;
    ipOverLapped:TOverLapped;
Begin
     Height:=1;
     Width:=1;
     Self.FreeImage;
     hFile:=FileOpen(FileName,fmOpenRead or fmShareDenyNone);
     FSizeB:=GetFileSize(hFile,Nil);
     Error:=GetLastError;
     If Error<>0 Then MessageBeep(0)
     Else
         Begin
              IFD:=TIFD.CreateFromFile(hFile);
              self.Monochrome:=IFD.PhotometricInterpretation in [0,1]; //(IFD.BitsPerPixel=1);
              Case IFD.BitsPerPixel of
                   1: PalVolume:=2;
                   4: PalVolume:=16;
                   8: PalVolume:=256;
               16,32: PalVolume:=3;
                   else PalVolume:=0;
              end;
              GetMem(BMPInfo,SizeOf(TBitMapInfoHeader)+PalVolume*SizeOf(TRGBQuad));
              with IFD do
                   begin
                        BMPInfo^.bmiHeader.biSize:=SizeOf(TBitMapInfoHeader);
                        BMPInfo^.bmiHeader.biWidth:=IFD.Width;
                        BMPInfo^.bmiHeader.biHeight:=-IFD.Lenght;
                        BMPInfo^.bmiHeader.biPlanes:=1;
                        BMPInfo^.bmiHeader.biCompression:=0;
                        //if IFD.BitsPerPixel = 32 then BMPInfo^.bmiHeader.biCompression:=BI_BITFIELDS;
                        BMPInfo^.bmiHeader.biSizeImage:=0;
                        BMPInfo^.bmiHeader.biXPelsPerMeter:=0;
                        BMPInfo^.bmiHeader.biYPelsPerMeter:=0;
                        BMPInfo^.bmiHeader.biBitCount:=BitsPerPixel;
                        BMPInfo^.bmiHeader.biClrUsed:=0;
                        BMPInfo^.bmiHeader.biClrImportant:=0;
                   end;
              Case IFD.BitsPerPixel of
                   1: Begin
                           PixelFormat:= pf1bit;
                           ScrambleBitmapPalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation,BMPInfo);
                     end;
                   4: Begin
                           PixelFormat:= pf4bit;
                           ScrambleBitmapPalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation,BMPInfo);
                      end;
                   8: Begin
                           PixelFormat:= pf8bit;
                           ScrambleBitmapPalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation,BMPInfo);
                      end;
                   24: Begin
                            PixelFormat:= pf24bit;
                       end;
                   32: PixelFormat:= pf32bit;
              end;
              ipOverlapped.Internal:=0;
              ipOverlapped.InternalHigh:=0;
              ipOverlapped.Offset:=0;
              ipOverlapped.OffsetHigh:=0;
              ipOverlapped.hEvent:=0;
              Self.Width:=IFD.Width;
              Self.Height:=IFD.Lenght;
              RowSize:=(IFD.BitsPerPixel*Width+7) div 8;
              case IFD.Compression of
                   1: begin
                           ScanLines:=0;
                           for j:=0 to IFD.StripeCount-1 do
                               begin
                                    If j<IFD.StripeCount-1 then StripeSize:=IFD.RowsPerStrip*RowSize
                                    else StripeSize:=(Height-IFD.RowsPerStrip*(IFD.StripeCount-1))*RowSize;
                                    GetMem(ppBitMapBits,StripeSize);
                                    StartData:=ppBitMapBits;
                                    ipOverlapped.Offset:=IFD.OffSets^[j];
                                    ReadFileEx(hFile,ppBitMapBits,StripeSize,@ipOverLapped,Nil);
                                    case IFD.BitsPerPixel of
                                         24: Begin
                                                  if j<IFD.StripeCount-1 then
                                                     RearrangeBytes(ppBitMapBits,Width*IFD.RowsPerStrip)
                                                  else
                                                      RearrangeBytes(ppBitMapBits,Width*(Height-IFD.RowsPerStrip*(IFD.StripeCount-1)));
                                                  i:=IFD.RowsPerStrip*j;
                                                  While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                                                        begin
                                                             ScanLines:= ScanLines + SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                                                     ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);
                                                             ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                                             inc(i);
                                                        end;
                                             end;
                                         32: Begin
                                                  if j<IFD.StripeCount-1 then
                                                     RearrangeBytes32(ppBitMapBits,Width*IFD.RowsPerStrip)
                                                  else
                                                      RearrangeBytes32(ppBitMapBits,Width*(Height-IFD.RowsPerStrip*(IFD.StripeCount-1)));
                                                  i:=IFD.RowsPerStrip*j;
                                                  While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                                                        begin
                                                             ScanLines:= ScanLines + SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                                                     ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);
                                                             ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                                             inc(i);
                                                        end;
                                             end;
                                         else
                                             Begin
                                                  i:=IFD.RowsPerStrip*j;
                                                  While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                                                        begin
                                                             ScanLines:= ScanLines + SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                                                     ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);
                                                             ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                                             inc(i);
                                                        end;
                                             end;
                                    end;
                                    FreeMem(StartData,StripeSize);
                               end;
                      end;
                   5: begin
                           ScanLines:=0;
                           Decoder:=TLZW.Create;
                           for j:=0 to IFD.StripeCount-1 do
                               begin
                                    if j<IFD.StripeCount-1 then GetMem(ppBitMapBits,IFD.RowsPerStrip*RowSize)
                                    else GetMem(ppBitMapBits,(Height-IFD.RowsPerStrip*(IFD.StripeCount-1))*RowSize);
                                    CurrDecoding:=ppBitMapBits;
                                    GetMem(StartData,IFD.ByteCounts^[j]);
                                    ipOverlapped.Offset:=IFD.OffSets^[j];
                                    ReadFileEx(hFile,StartData,IFD.ByteCounts^[j],@ipOverLapped,Nil);
                                    Decoder.DecodeLZW(StartData,CurrDecoding);
                                    //CurrDecoding:=IncAddress(CurrDecoding,RowSize*IFD.RowsPerStrip);
                                    FreeMem(StartData,IFD.ByteCounts^[j]);
                                    StartData:=ppBitMapBits;
                                    case IFD.BitsPerPixel of
                                         24: Begin
                                                  if j<IFD.StripeCount-1 then
                                                     RearrangeBytes(ppBitMapBits,Width*IFD.RowsPerStrip)
                                                  else
                                                      RearrangeBytes(ppBitMapBits,Width*(Height-IFD.RowsPerStrip*(IFD.StripeCount-1)));
                                                  i:=IFD.RowsPerStrip*j;
                                                  While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                                                        begin
                                                             if IFD.Prediction then Depredict3(ppBitMapBits,Width-1);
                                                             ScanLines:= ScanLines + SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                                                     ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);
                                                             ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                                             inc(i);
                                                        end;
                                             end;
                                         32: Begin
                                                  if j<IFD.StripeCount-1 then
                                                     RearrangeBytes32(ppBitMapBits,Width*IFD.RowsPerStrip)
                                                  else
                                                      RearrangeBytes32(ppBitMapBits,Width*(Height-IFD.RowsPerStrip*(j)));
                                                  i:=IFD.RowsPerStrip*j;
                                                  While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                                                        begin
                                                             if IFD.Prediction then Depredict4(ppBitMapBits,Width-1);
                                                             ScanLines:= ScanLines + SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                                                     ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);
                                                             ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                                             inc(i);
                                                        end;
                                             end;
                                         else
                                             Begin
                                                  i:=IFD.RowsPerStrip*j;
                                                  While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                                                        begin
                                                             if IFD.Prediction then Depredict1(ppBitMapBits,Width-1);
                                                             ScanLines:= ScanLines +  SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                                                      ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);
                                                             ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                                             inc(i);
                                                        end;
                                             end;
                                    end;
                                    if j<IFD.StripeCount-1 then FreeMem(StartData,IFD.RowsPerStrip*(RowSize))
                                    else FreeMem(StartData,(Height-IFD.RowsPerStrip*(IFD.StripeCount))*(RowSize));
                               end;
                           Decoder.Destroy;
                      end;
              end;
              If (IFD.PhotometricInterpretation  = 3) or (IFD.BitsPerPixel = 32) then
                 begin
                      PixelFormat:=pf24bit;
                      Palette:=RGB_Palette;
                 end;
              If ScanLines<Height Then MessageBox(0,'Picture reading failed!','Error',0);
              CloseHandle(hFile);
              FreeMem(BMPInfo,SizeOf(TBitMapInfoHeader)+PalVolume*SizeOf(TRGBQuad));
              IFD.Destroy;
         End;
end;
//

Procedure TTIFFBitMap.LoadTiffFromStream(TiffStream:TStream);
var FsizeB,StripeSize,RowSize:DWord;
    PShift:^LongInt;
    Shift:LongInt;
    i,j,k,PalVolume:DWord;
    Error,ScanLines:DWord;
    BMPInfo:PBitMapInfo;
    ppBitMapBits,StartData,CurrDecoding:Pointer;
    Decoder:TLZW;
    PByte:^Byte;
Begin
     Height:=1;
     Width:=1;
     Self.FreeImage;
     FSizeB:=TiffStream.Size;
     Error:=GetLastError;
     If Error<>0 Then MessageBeep(0)
     Else
         Begin
              IFD:=TIFD.CreateFromStream(TiffStream);
              self.Monochrome:=IFD.PhotometricInterpretation in [0,1]; //(IFD.BitsPerPixel=1);
              Case IFD.BitsPerPixel of
                   1: PalVolume:=2;
                   4: PalVolume:=16;
                   8: PalVolume:=256;
               16,24,32: PalVolume:=3;
                   else PalVolume:=0;
              end;
              GetMem(BMPInfo,SizeOf(TBitMapInfoHeader)+PalVolume*SizeOf(TRGBQuad));
              with IFD do
                   begin
                        BMPInfo^.bmiHeader.biSize:=SizeOf(TBitMapInfoHeader);
                        BMPInfo^.bmiHeader.biWidth:=IFD.Width;
                        BMPInfo^.bmiHeader.biHeight:=-IFD.Lenght;
                        BMPInfo^.bmiHeader.biPlanes:=1;
                        BMPInfo^.bmiHeader.biCompression:=0;
                        //if IFD.BitsPerPixel = 32 then BMPInfo^.bmiHeader.biCompression:=BI_BITFIELDS;
                        BMPInfo^.bmiHeader.biSizeImage:=0;
                        BMPInfo^.bmiHeader.biXPelsPerMeter:=0;
                        BMPInfo^.bmiHeader.biYPelsPerMeter:=0;
                        BMPInfo^.bmiHeader.biBitCount:=BitsPerPixel;
                        BMPInfo^.bmiHeader.biClrUsed:=0;
                        BMPInfo^.bmiHeader.biClrImportant:=0;
                   end;
              Case IFD.BitsPerPixel of
                   1: Begin
                           PixelFormat:= pf1bit;
                           ScrambleBitmapPalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation,BMPInfo);
                     end;
                   4: Begin
                           PixelFormat:= pf4bit;
                           ScrambleBitmapPalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation,BMPInfo);
                      end;
                   8: Begin
                           PixelFormat:= pf8bit;
                           ScrambleBitmapPalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation,BMPInfo);
                      end;
                   24: Begin
                            PixelFormat:= pf24bit;
                       end;
                   32: PixelFormat:= pf32bit;
              end;
              Self.Width:=IFD.Width;
              Self.Height:=IFD.Lenght;
              RowSize:=(IFD.BitsPerPixel*Width+7) div 8;
              case IFD.Compression of
                   1: begin
                           ScanLines:=0;
                           for j:=0 to IFD.StripeCount-1 do
                               begin
                                    If j<IFD.StripeCount-1 then StripeSize:=IFD.RowsPerStrip*RowSize
                                    else StripeSize:=(Height-IFD.RowsPerStrip*(IFD.StripeCount-1))*RowSize;
                                    GetMem(ppBitMapBits,StripeSize);
                                    StartData:=ppBitMapBits;
                                    TiffStream.Position:=IFD.OffSets^[j];
                                    TiffStream.ReadBuffer(ppBitMapBits^,StripeSize);
                                    case IFD.BitsPerPixel of
                                         24: Begin
                                                  if j<IFD.StripeCount-1 then
                                                     RearrangeBytes(ppBitMapBits,Width*IFD.RowsPerStrip)
                                                  else
                                                      RearrangeBytes(ppBitMapBits,Width*(Height-IFD.RowsPerStrip*(IFD.StripeCount-1)));
                                                  i:=IFD.RowsPerStrip*j;
                                                  While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                                                        begin
                                                             ScanLines:= ScanLines + SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                                                     ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);
                                                             ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                                             inc(i);
                                                        end;
                                             end;
                                         32: Begin
                                                  if j<IFD.StripeCount-1 then
                                                     RearrangeBytes32(ppBitMapBits,Width*IFD.RowsPerStrip)
                                                  else
                                                      RearrangeBytes32(ppBitMapBits,Width*(Height-IFD.RowsPerStrip*(IFD.StripeCount-1)));
                                                  i:=IFD.RowsPerStrip*j;
                                                  While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                                                        begin
                                                             ScanLines:= ScanLines + SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                                                     ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);
                                                             ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                                             inc(i);
                                                        end;
                                             end;
                                         else
                                             Begin
                                                  i:=IFD.RowsPerStrip*j;
                                                  While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                                                        begin
                                                             ScanLines:= ScanLines + SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                                                     ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);
                                                             ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                                             inc(i);
                                                        end;
                                             end;
                                    end;
                                    FreeMem(StartData,StripeSize);
                               end;
                      end;
                   5: begin
                           ScanLines:=0;
                           Decoder:=TLZW.Create;
                           for j:=0 to IFD.StripeCount-1 do
                               begin
                                    if j<IFD.StripeCount-1 then GetMem(ppBitMapBits,IFD.RowsPerStrip*RowSize)
                                    else GetMem(ppBitMapBits,(Height-IFD.RowsPerStrip*(IFD.StripeCount-1))*RowSize);
                                    CurrDecoding:=ppBitMapBits;
                                    GetMem(StartData,IFD.ByteCounts^[j]);
                                    TiffStream.Position:=IFD.OffSets^[j];
                                    TiffStream.ReadBuffer(StartData^,IFD.ByteCounts^[j]);
                                    Decoder.DecodeLZW(StartData,CurrDecoding);
                                    //CurrDecoding:=IncAddress(CurrDecoding,RowSize*IFD.RowsPerStrip);
                                    FreeMem(StartData,IFD.ByteCounts^[j]);
                                    StartData:=ppBitMapBits;
                                    case IFD.BitsPerPixel of
                                         24: Begin
                                                  if j<IFD.StripeCount-1 then
                                                     RearrangeBytes(ppBitMapBits,Width*IFD.RowsPerStrip)
                                                  else
                                                      RearrangeBytes(ppBitMapBits,Width*(Height-IFD.RowsPerStrip*(IFD.StripeCount-1)));
                                                  i:=IFD.RowsPerStrip*j;
                                                  While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                                                        begin
                                                             if IFD.Prediction then Depredict3(ppBitMapBits,Width-1);
                                                             ScanLines:= ScanLines + SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                                                     ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);
                                                             ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                                             inc(i);
                                                        end;
                                             end;
                                         32: Begin
                                                  if j<IFD.StripeCount-1 then
                                                     RearrangeBytes32(ppBitMapBits,Width*IFD.RowsPerStrip)
                                                  else
                                                      RearrangeBytes32(ppBitMapBits,Width*(Height-IFD.RowsPerStrip*(j)));
                                                  i:=IFD.RowsPerStrip*j;
                                                  While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                                                        begin
                                                             if IFD.Prediction then Depredict4(ppBitMapBits,Width-1);
                                                             ScanLines:= ScanLines + SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                                                     ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);
                                                             ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                                             inc(i);
                                                        end;
                                             end;
                                         else
                                             Begin
                                                  i:=IFD.RowsPerStrip*j;
                                                  While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                                                        begin
                                                             if IFD.Prediction then Depredict1(ppBitMapBits,Width-1);
                                                             ScanLines:= ScanLines +  SetDIBitsToDevice(Canvas.Handle,0,i,Width,1,0,1,1,1,
                                                                                      ppBitMapBits,BMPInfo^,DIB_RGB_COLORS);
                                                             ppBitMapBits:=IncAddress(ppBitMapBits,RowSize);
                                                             inc(i);
                                                        end;
                                             end;
                                    end;
                                    if j<IFD.StripeCount-1 then FreeMem(StartData,IFD.RowsPerStrip*(RowSize))
                                    else FreeMem(StartData,(Height-IFD.RowsPerStrip*(IFD.StripeCount))*(RowSize));
                               end;
                           Decoder.Destroy;
                      end;
              end;
              If (IFD.PhotometricInterpretation  = 3) or (IFD.BitsPerPixel = 32) then
                 begin
                      PixelFormat:=pf24bit;
                      Palette:=RGB_Palette;
                 end;
              If ScanLines<Height Then MessageBox(0,'Picture reading failed!','Error',0);
              FreeMem(BMPInfo,SizeOf(TBitMapInfoHeader)+PalVolume*SizeOf(TRGBQuad));
              IFD.Destroy;
         End;
end;

//
procedure TTIFFBitMap.SaveToTifFile(FileName:String;Compressing:Boolean);
var PByte:^Byte;
    PWord:^Word;
    PDWord:^DWord;
    OutFile:THandle;
    i,j:Word;
    FName:PChar;
    ipOverlapped:TOverLapped;
    OffSet:DWord;
    BMPInfo:PBitMapInfo;
    Buffer,BufHead,CodeBuffer:Pointer;
    ScanLines,vFileSize:DWord;
    PalVolume:Word;
    Error,Usage:Integer;
    Encoder:TLZW;
    BCounts:DWord;
    offOffset,bcOffset,tgOffset,RowSize:DWord;
begin
     New(PByte);New(PWord);New(PDWord);
     IFD:=TIFD.WriteCreate(Self,Compressing);
     GetMem(FName,Length(Filename)+1);
     FName:=StrPCopy(FName,FileName);
     OutFile:=CreateFile(FName,Generic_Write,File_Share_Read,Nil,TRUNCATE_EXISTING,File_Attribute_Normal,0);
     Error:=GetLastError;
     if Error<>0 Then
        begin
             OutFile:=CreateFile(FName,Generic_Write,File_Share_Read,Nil,CREATE_NEW,File_Attribute_Normal,0);
        end;
     FreeMem(FName,Length(Filename)+1);
     ipOverlapped.Internal:=0;
     ipOverlapped.InternalHigh:=0;
     ipOverlapped.Offset:=0;
     ipOverlapped.OffsetHigh:=0;
     ipOverlapped.hEvent:=0;
     OffSet:=0;
     PByte^:=$49;
     WriteFileEx(OutFile,PByte,1,ipOverLapped,Nil);
     OffSet:=OffSet+1;
     ipOverlapped.Offset:=OffSet;
     WriteFileEx(OutFile,PByte,1,ipOverLapped,Nil);
     OffSet:=OffSet+1;
     ipOverlapped.Offset:=OffSet;
     PWord^:=$2A;
     WriteFileEx(OutFile,PWord,2,ipOverLapped,Nil);
     OffSet:=OffSet+2;
     ipOverlapped.Offset:=OffSet;
     PDWord^:=$8;
     WriteFileEx(OutFile,PDWord,4,ipOverLapped,Nil);
     OffSet:=OffSet+4;
     ipOverlapped.Offset:=OffSet;
     PWord^:=IFD.TagCount;
     WriteFileEx(OutFile,PWord,2,ipOverLapped,Nil);
     OffSet:=OffSet+2;
     ipOverlapped.Offset:=OffSet;
     tgOffset:=OffSet;
     WriteFileEx(OutFile,IFD.PTags,12*IFD.TagCount,ipOverLapped,Nil);
     OffSet:=OffSet+12*IFD.TagCount;
     ipOverlapped.OffSet:=OffSet;
     PDWord^:=0;
     WriteFileEx(OutFile,PDWord,4,ipOverLapped,Nil);
     OffSet:=OffSet+4;
     ipOverlapped.OffSet:=OffSet;
     If IFD.StripeCount>1 Then
        begin
             offOffset:=OffSet;
             WriteFileEx(OutFile,IFD.OffSets,4*IFD.StripeCount,ipOverLapped,Nil);
             OffSet:=OffSet+4*IFD.StripeCount;
             ipOverlapped.OffSet:=OffSet;
             bcOffSet:=OffSet;
             WriteFileEx(OutFile,IFD.ByteCounts,4*IFD.StripeCount,ipOverLapped,Nil);
             OffSet:=OffSet+4*IFD.StripeCount;
             ipOverlapped.OffSet:=OffSet;
        end;
     Case IFD.BitsPerPixel of
          1: PalVolume:=2;
          4: PalVolume:=16;
          8: PalVolume:=256;
          16,32: PalVolume:=3;
          else PalVolume:=0;
     end;
     if IFD.BitsPerPixel = 1 then GetMem(BMPInfo,SizeOf(TBitMapInfoHeader)+PalVolume*SizeOf(TRGBQuad))
     else
     GetMem(BMPInfo,SizeOf(TBitMapInfoHeader)+2*PalVolume );
     with IFD do
          begin
               BMPInfo^.bmiHeader.biSize:=SizeOf(TBitMapInfoHeader);
               BMPInfo^.bmiHeader.biWidth:=Width;
               BMPInfo^.bmiHeader.biHeight:=-Lenght;
               BMPInfo^.bmiHeader.biPlanes:=1;
               BMPInfo^.bmiHeader.biCompression:=0;
               BMPInfo^.bmiHeader.biSizeImage:=0;
               BMPInfo^.bmiHeader.biXPelsPerMeter:=0;
               BMPInfo^.bmiHeader.biYPelsPerMeter:=0;
               BMPInfo^.bmiHeader.biBitCount:=BitsPerPixel;
               BMPInfo^.bmiHeader.biClrUsed:=0;
               BMPInfo^.bmiHeader.biClrImportant:=0;
          end;
     Case IFD.BitsPerPixel of
          1: ScrambleBitmapPalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation,BMPInfo);
          4: ScramblePalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation);
          8: ScramblePalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation);
     end;
     ScanLines:=0;
     if IFD.BitsPerPixel in [1,24] then Usage:=DIB_RGB_COLORS
     else Usage:=DIB_PAL_COLORS;
     RowSize:=(IFD.BitsPerPixel*Width+7) div 8;
     for j:=0 to IFD.StripeCount-1 do
         begin
              i:=IFD.RowsPerStrip*j;
              BCounts:=IFD.ByteCounts^[j];
              Buffer:=AllocMem(BCounts);
              Error:=GetLastError;
              if Error<>0 Then ShowMessage(SysErrorMessage(Error));
              BufHead:=Buffer;
              While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                    begin
                         ScanLines:=ScanLines+GetDIBits(Canvas.Handle,Handle,Height-i-1,1,Buffer,BMPInfo^,Usage);
                         Error:=GetLastError;
                         if Error<>0 Then ShowMessage(SysErrorMessage(Error));
                         Buffer:=IncAddress(Buffer,RowSize);
                         inc(i);
                    end;
              Buffer:=BufHead;
              if IFD.BitsPerPixel = 24 then
                 Begin
                      if j<IFD.StripeCount-1 then
                         RearrangeBytes(Buffer,Width*IFD.RowsPerStrip)
                      else
                          RearrangeBytes(Buffer,Width*(Height-IFD.RowsPerStrip*(IFD.StripeCount-1)));
                 end;
              if Compressing then
                 begin
                      Encoder:=TLZW.Create;
                      BCounts:=IFD.ByteCounts^[j];
                      CodeBuffer:=AllocMem((3*BCounts) div 2);
                      Encoder.EncodeLZW(Buffer,CodeBuffer,IFD.ByteCounts^[j]);
                      If j<IFD.StripeCount-1 then
                         IFD.OffSets^[j+1]:= IFD.OffSets^[j]+IFD.ByteCounts^[j]+
                                             (IFD.OffSets^[j]+IFD.ByteCounts^[j]) mod 2;
                      ipOverlapped.OffSet:=IFD.OffSets^[j];
                      WriteFileEx(OutFile,CodeBuffer,IFD.ByteCounts^[j],ipOverLapped,Nil);
                      FreeMem(CodeBuffer,(3*BCounts) div 2);
                      Encoder.Destroy;
                 end
              else
                  begin
                       ipOverlapped.OffSet:=IFD.OffSets^[j];
                       WriteFileEx(OutFile,Buffer,IFD.ByteCounts^[j],ipOverLapped,Nil);
                       OffSet:=OffSet+IFD.ByteCounts^[j];
                       ipOverlapped.OffSet:=OffSet;
                  end;
              FreeMem(Buffer,BCounts);
         end;
     If Compressing then
        begin
             If IFD.StripeCount>1 Then
                begin
                     ipOverlapped.Offset:=offOffset;
                     WriteFileEx(OutFile,IFD.OffSets,4*IFD.StripeCount,ipOverLapped,Nil);
                     ipOverlapped.OffSet:=bcOffSet;
                     WriteFileEx(OutFile,IFD.ByteCounts,4*IFD.StripeCount,ipOverLapped,Nil);
                end
             else
                 begin
                      i:=11;
                      IFD.PTags^[i].DataOrPointer:=IFD.ByteCounts^[0];
                      ipOverlapped.Offset:=tgOffset;
                      WriteFileEx(OutFile,IFD.PTags,12*IFD.TagCount,ipOverLapped,Nil);
                 end;
        end;
     If ScanLines<Height then MessageBox(0,'Picture Write Failed','Error',0);
     if IFD.BitsPerPixel = 1 then FreeMem(BMPInfo,SizeOf(TBitMapInfoHeader)+PalVolume*SizeOf(TRGBQuad))
     else
         FreeMem(BMPInfo,SizeOf(TBitMapInfoHeader)+2*PalVolume);
     CloseHandle(OutFile);
     IFD.Destroy;
     Dispose(PByte);Dispose(PWord);Dispose(PDWord);
end;

procedure TTIFFBitMap.SaveToTifFileSLZW(FileName:String;SmoothRange:TSmoothRange);
var PByte:^Byte;
    PWord:^Word;
    PDWord:^DWord;
    OutFile:THandle;
    i,j:Word;
    FName:PChar;
    ipOverlapped:TOverLapped;
    OffSet:DWord;
    BMPInfo:PBitMapInfo;
    Buffer,BufHead,CodeBuffer:Pointer;
    ScanLines,vFileSize:DWord;
    PalVolume:Word;
    Error,Usage:Integer;
    Encoder:TLZW;
    BCounts:DWord;
    offOffset,bcOffset,tgOffset,RowSize:DWord;
begin
     New(PByte);New(PWord);New(PDWord);
     IFD:=TIFD.WriteCreate(Self,True);
     GetMem(FName,Length(Filename)+1);
     FName:=StrPCopy(FName,FileName);
     OutFile:=CreateFile(FName,Generic_Write,File_Share_Read,Nil,TRUNCATE_EXISTING,File_Attribute_Normal,0);
     Error:=GetLastError;
     if Error<>0 Then
        begin
             OutFile:=CreateFile(FName,Generic_Write,File_Share_Read,Nil,CREATE_NEW,File_Attribute_Normal,0);
        end;
     FreeMem(FName,Length(Filename)+1);
     ipOverlapped.Internal:=0;
     ipOverlapped.InternalHigh:=0;
     ipOverlapped.Offset:=0;
     ipOverlapped.OffsetHigh:=0;
     ipOverlapped.hEvent:=0;
     OffSet:=0;
     PByte^:=$49;
     WriteFileEx(OutFile,PByte,1,ipOverLapped,Nil);
     OffSet:=OffSet+1;
     ipOverlapped.Offset:=OffSet;
     WriteFileEx(OutFile,PByte,1,ipOverLapped,Nil);
     OffSet:=OffSet+1;
     ipOverlapped.Offset:=OffSet;
     PWord^:=$2A;
     WriteFileEx(OutFile,PWord,2,ipOverLapped,Nil);
     OffSet:=OffSet+2;
     ipOverlapped.Offset:=OffSet;
     PDWord^:=$8;
     WriteFileEx(OutFile,PDWord,4,ipOverLapped,Nil);
     OffSet:=OffSet+4;
     ipOverlapped.Offset:=OffSet;
     PWord^:=IFD.TagCount;
     WriteFileEx(OutFile,PWord,2,ipOverLapped,Nil);
     OffSet:=OffSet+2;
     ipOverlapped.Offset:=OffSet;
     tgOffset:=OffSet;
     WriteFileEx(OutFile,IFD.PTags,12*IFD.TagCount,ipOverLapped,Nil);
     OffSet:=OffSet+12*IFD.TagCount;
     ipOverlapped.OffSet:=OffSet;
     PDWord^:=0;
     WriteFileEx(OutFile,PDWord,4,ipOverLapped,Nil);
     OffSet:=OffSet+4;
     ipOverlapped.OffSet:=OffSet;
     If IFD.StripeCount>1 Then
        begin
             offOffset:=OffSet;
             WriteFileEx(OutFile,IFD.OffSets,4*IFD.StripeCount,ipOverLapped,Nil);
             OffSet:=OffSet+4*IFD.StripeCount;
             ipOverlapped.OffSet:=OffSet;
             bcOffSet:=OffSet;
             WriteFileEx(OutFile,IFD.ByteCounts,4*IFD.StripeCount,ipOverLapped,Nil);
             OffSet:=OffSet+4*IFD.StripeCount;
             ipOverlapped.OffSet:=OffSet;
        end;
     Case IFD.BitsPerPixel of
          1: PalVolume:=2;
          4: PalVolume:=16;
          8: PalVolume:=256;
          16,32: PalVolume:=3;
          else PalVolume:=0;
     end;
     if IFD.BitsPerPixel = 1 then GetMem(BMPInfo,SizeOf(TBitMapInfoHeader)+PalVolume*SizeOf(TRGBQuad))
     else
     GetMem(BMPInfo,SizeOf(TBitMapInfoHeader)+2*PalVolume );
     with IFD do
          begin
               BMPInfo^.bmiHeader.biSize:=SizeOf(TBitMapInfoHeader);
               BMPInfo^.bmiHeader.biWidth:=Width;
               BMPInfo^.bmiHeader.biHeight:=-Lenght;
               BMPInfo^.bmiHeader.biPlanes:=1;
               BMPInfo^.bmiHeader.biCompression:=0;
               BMPInfo^.bmiHeader.biSizeImage:=0;
               BMPInfo^.bmiHeader.biXPelsPerMeter:=0;
               BMPInfo^.bmiHeader.biYPelsPerMeter:=0;
               BMPInfo^.bmiHeader.biBitCount:=BitsPerPixel;
               BMPInfo^.bmiHeader.biClrUsed:=0;
               BMPInfo^.bmiHeader.biClrImportant:=0;
          end;
     Case IFD.BitsPerPixel of
          1: ScrambleBitmapPalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation,BMPInfo);
          4: ScramblePalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation);
          8: ScramblePalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation);
     end;
     ScanLines:=0;
     if IFD.BitsPerPixel in [1,24] then Usage:=DIB_RGB_COLORS
     else Usage:=DIB_PAL_COLORS;
     RowSize:=(IFD.BitsPerPixel*Width+7) div 8;
     for j:=0 to IFD.StripeCount-1 do
         begin
              i:=IFD.RowsPerStrip*j;
              BCounts:=IFD.ByteCounts^[j];
              Buffer:=AllocMem(BCounts);
              Error:=GetLastError;
              if Error<>0 Then ShowMessage(SysErrorMessage(Error));
              BufHead:=Buffer;
              While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                    begin
                         ScanLines:=ScanLines+GetDIBits(Canvas.Handle,Handle,Height-i-1,1,Buffer,BMPInfo^,Usage);
                         Error:=GetLastError;
                         if Error<>0 Then ShowMessage(SysErrorMessage(Error));
                         Buffer:=IncAddress(Buffer,RowSize);
                         inc(i);
                    end;
              Buffer:=BufHead;
              if IFD.BitsPerPixel = 24 then
                 Begin
                      if j<IFD.StripeCount-1 then
                         RearrangeBytes(Buffer,Width*IFD.RowsPerStrip)
                      else
                          RearrangeBytes(Buffer,Width*(Height-IFD.RowsPerStrip*(IFD.StripeCount-1)));
                 end;
              Encoder:=TLZW.Create;
              BCounts:=IFD.ByteCounts^[j];
              CodeBuffer:=AllocMem((3*BCounts) div 2);
              Encoder.SmoothEncodeLZW(Buffer,CodeBuffer,SmoothRange,IFD.ByteCounts^[j]);
              If j<IFD.StripeCount-1 then
                 IFD.OffSets^[j+1]:= IFD.OffSets^[j]+IFD.ByteCounts^[j]+
                                             (IFD.OffSets^[j]+IFD.ByteCounts^[j]) mod 2;
              ipOverlapped.OffSet:=IFD.OffSets^[j];
              WriteFileEx(OutFile,CodeBuffer,IFD.ByteCounts^[j],ipOverLapped,Nil);
              FreeMem(CodeBuffer,(3*BCounts) div 2);
              Encoder.Destroy;
              FreeMem(Buffer,BCounts);
         end;
     If IFD.StripeCount>1 Then
        begin
             ipOverlapped.Offset:=offOffset;
             WriteFileEx(OutFile,IFD.OffSets,4*IFD.StripeCount,ipOverLapped,Nil);
             ipOverlapped.OffSet:=bcOffSet;
             WriteFileEx(OutFile,IFD.ByteCounts,4*IFD.StripeCount,ipOverLapped,Nil);
        end
     else
         begin
              i:=11;
              IFD.PTags^[i].DataOrPointer:=IFD.ByteCounts^[0];
              ipOverlapped.Offset:=tgOffset;
              WriteFileEx(OutFile,IFD.PTags,12*IFD.TagCount,ipOverLapped,Nil);
         end;
     If ScanLines<Height then MessageBox(0,'Picture Write Failed','Error',0);
     if IFD.BitsPerPixel = 1 then FreeMem(BMPInfo,SizeOf(TBitMapInfoHeader)+PalVolume*SizeOf(TRGBQuad))
     else
         FreeMem(BMPInfo,SizeOf(TBitMapInfoHeader)+2*PalVolume);
     CloseHandle(OutFile);
     IFD.Destroy;
     Dispose(PByte);Dispose(PWord);Dispose(PDWord);
end;

procedure TTIFFBitMap.SaveTiffToStream(TiffStream:TStream;Compressing:Boolean);
var PByte,BufByte:^Byte;
    PWord:^Word;
    PDWord:^DWord;
    i,j,k:Word;
    OffSet:DWord;
    BMPInfo:PBitMapInfo;
    Buffer,BufHead,CodeBuffer:Pointer;
    ScanLines,vFileSize:DWord;
    PalVolume:Word;
    Error,Usage:Integer;
    Encoder:TLZW;
    BCounts:DWord;
    offOffset,bcOffset,tgOffset,RowSize:DWord;
begin
     OffSet:=0;
     New(PByte);New(PWord);New(PDWord);
     IFD:=TIFD.WriteCreate(Self,Compressing);
     TiffStream.Position:=0;
     PByte^:=$49;
     TiffStream.WriteBuffer(PByte^,1);
     OffSet:=OffSet+1;
     TiffStream.Position:=OffSet;
     TiffStream.WriteBuffer(PByte^,1);
     OffSet:=OffSet+1;
     TiffStream.Position:=OffSet;
     PWord^:=$2A;
     TiffStream.WriteBuffer(PWord^,2);
     OffSet:=OffSet+2;
     TiffStream.Position:=OffSet;
     PDWord^:=$8;
     TiffStream.WriteBuffer(PDWord^,4);
     OffSet:=OffSet+4;
     TiffStream.Position:=OffSet;
     PWord^:=IFD.TagCount;
     TiffStream.WriteBuffer(PWord^,2);
     OffSet:=OffSet+2;
     TiffStream.Position:=OffSet;
     tgOffset:=OffSet;
     TiffStream.WriteBuffer(IFD.PTags^,12*IFD.TagCount);
     OffSet:=OffSet+12*IFD.TagCount;
     PDWord^:=0;
     TiffStream.WriteBuffer(PDWord,4);
     OffSet:=OffSet+4;
     If IFD.StripeCount>1 Then
        begin
             offOffset:=OffSet;
             TiffStream.WriteBuffer(IFD.OffSets^,4*IFD.StripeCount);
             OffSet:=OffSet+4*IFD.StripeCount;
             bcOffSet:=OffSet;
             TiffStream.WriteBuffer(IFD.ByteCounts^,4*IFD.StripeCount);
             OffSet:=OffSet+4*IFD.StripeCount;
        end;
     Case IFD.BitsPerPixel of
          1: PalVolume:=2;
          4: PalVolume:=16;
          8: PalVolume:=256;
          16,32: PalVolume:=3;
          else PalVolume:=0;
     end;
     if IFD.BitsPerPixel = 1 then GetMem(BMPInfo,SizeOf(TBitMapInfoHeader)+PalVolume*SizeOf(TRGBQuad))
     else
     GetMem(BMPInfo,SizeOf(TBitMapInfoHeader)+2*PalVolume );
     with IFD do
          begin
               BMPInfo^.bmiHeader.biSize:=SizeOf(TBitMapInfoHeader);
               BMPInfo^.bmiHeader.biWidth:=Width;
               BMPInfo^.bmiHeader.biHeight:=-Lenght;
               BMPInfo^.bmiHeader.biPlanes:=1;
               BMPInfo^.bmiHeader.biCompression:=0;
               BMPInfo^.bmiHeader.biSizeImage:=0;
               BMPInfo^.bmiHeader.biXPelsPerMeter:=0;
               BMPInfo^.bmiHeader.biYPelsPerMeter:=0;
               BMPInfo^.bmiHeader.biBitCount:=BitsPerPixel;
               BMPInfo^.bmiHeader.biClrUsed:=0;
               BMPInfo^.bmiHeader.biClrImportant:=0;
          end;
     Case IFD.BitsPerPixel of
          1: ScrambleBitmapPalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation,BMPInfo);
          4: ScramblePalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation);
          8: ScramblePalette(IFD.BitsPerPixel,IFD.PhotometricInterpretation);
     end;
     ScanLines:=0;
     if IFD.BitsPerPixel in [1,24] then Usage:=DIB_RGB_COLORS
     else Usage:=DIB_PAL_COLORS;
     RowSize:=(IFD.BitsPerPixel*Width+7) div 8;
     for j:=0 to IFD.StripeCount-1 do
         begin
              i:=IFD.RowsPerStrip*j;
              BCounts:=IFD.ByteCounts^[j];
              Buffer:=AllocMem(BCounts);
              Error:=GetLastError;
              if Error<>0 Then ShowMessage(SysErrorMessage(Error));
              BufHead:=Buffer;
              While (i<=Height-1) and (i div IFD.RowsPerStrip <=j) do
                    begin
                         ScanLines:=ScanLines+GetDIBits(Canvas.Handle,Handle,Height-i-1,1,Buffer,BMPInfo^,Usage);
                         Error:=GetLastError;
                         if Error<>0 Then ShowMessage(SysErrorMessage(Error));
                         Buffer:=IncAddress(Buffer,RowSize);
                         inc(i);
                    end;
              Buffer:=BufHead;
              if IFD.BitsPerPixel = 24 then
                 Begin
                      if j<IFD.StripeCount-1 then
                         RearrangeBytes(Buffer,Width*IFD.RowsPerStrip)
                      else
                          RearrangeBytes(Buffer,Width*(Height-IFD.RowsPerStrip*(IFD.StripeCount-1)));
                 end;
              if Compressing then
                 begin
                      Encoder:=TLZW.Create;
                      BCounts:=IFD.ByteCounts^[j];
                      CodeBuffer:=AllocMem((3*BCounts) div 2);
                      Encoder.EncodeLZW(Buffer,CodeBuffer,IFD.ByteCounts^[j]);
                      If j < IFD.StripeCount-1 then
                         IFD.OffSets^[j+1]:= IFD.OffSets^[j]+IFD.ByteCounts^[j];
                      TiffStream.Position:=IFD.OffSets^[j];
                      TiffStream.WriteBuffer(CodeBuffer^,IFD.ByteCounts^[j]);
                      if Odd(IFD.OffSets^[j]+IFD.ByteCounts^[j]) then
                         begin
                              TiffStream.WriteBuffer(PByte^,1);
                              If j < IFD.StripeCount-1 then
                                 IFD.OffSets^[j+1]:= IFD.OffSets^[j+1]+1;
                         end;
                      OffSet:=OffSet+IFD.ByteCounts^[j];
                      FreeMem(CodeBuffer,(3*BCounts) div 2);
                      Encoder.Destroy;
                 end
              else
                  begin
                       TiffStream.Position:=IFD.OffSets^[j];
                       TiffStream.WriteBuffer(Buffer^,IFD.ByteCounts^[j]);
                       OffSet:=OffSet+IFD.ByteCounts^[j];
                  end;
              FreeMem(Buffer,BCounts);
         end;
     If Compressing then
        begin
             If IFD.StripeCount>1 Then
                begin
                     TiffStream.Position:=offOffset;
                     TiffStream.WriteBuffer(IFD.OffSets^,4*IFD.StripeCount);
                     TiffStream.Position:=bcOffSet;
                     TiffStream.WriteBuffer(IFD.ByteCounts^,4*IFD.StripeCount);
                end
             else
                 begin
                      i:=11;
                      IFD.PTags^[i].DataOrPointer:=IFD.ByteCounts^[0];
                      TiffStream.Position:=tgOffset;
                      TiffStream.WriteBuffer(IFD.PTags^,12*IFD.TagCount);
                 end;
        end;
     If ScanLines<Height then MessageBox(0,'Picture Write Failed','Error',0);
     if IFD.BitsPerPixel = 1 then FreeMem(BMPInfo,SizeOf(TBitMapInfoHeader)+PalVolume*SizeOf(TRGBQuad))
     else
         FreeMem(BMPInfo,SizeOf(TBitMapInfoHeader)+2*PalVolume);
     IFD.Destroy;
     Dispose(PByte);Dispose(PWord);Dispose(PDWord);
end;

procedure TTIffBitMap.LoadTiffFromBLOB(Source:TBlobField);
var BlobStream:TBlobStream;
begin
     BlobStream:=TBlobStream.Create(Source,bmRead);
     LoadTiffFromStream(BlobStream);
     BlobStream.Free;
end;

procedure TTIffBitMap.SaveTiffToBLOB(Destination:TBlobField;Compressing:Boolean);
var BlobStream:TBlobStream;
begin
     BlobStream:=TBlobStream.Create(Destination,bmWrite);
     SaveTiffToStream(BlobStream,Compressing);
     BlobStream.Free;
end;

procedure TTIFFBitMap.LoadFromFile(FileName: String);
begin

end;

procedure TTIFFBitMap.LoadFromStream(TiffStream: TStream);
begin
 LoadTiffFromStream(TiffStream);
end;

procedure TTIFFBitMap.SaveToStream(TiffStream: TStream);
begin
  inherited;
 SaveTiffToStream(TiffStream,false);
end;

initialization

    TPicture.RegisterFileFormat( 'tiff',''{ gesMacTIFF}, TTIFFGraphic);
    TPicture.RegisterFileFormat('tif',''{ gesPCTIF}, TTIFFGraphic);
    TPicture.RegisterFileFormat('fax','' {gesGFIFax}, TTIFFGraphic);

finalization
   TPicture.UnregisterGraphicClass(TTIFFGraphic);

end.

