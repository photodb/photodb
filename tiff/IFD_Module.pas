unit IFD_Module;

interface
uses  Windows,SysUtils,Graphics, Classes;
type TTag = record
                   TagType:Word;
                   DataType:Word;
                   DataLength:DWord;
                   DataOrPointer:DWord;
             end;
       TTagSet = array[0..0] of TTag;
       PTagSet = ^TTagSet;
  TOffSets = array [0..0] of DWord;
  POffsets =^TOffSets;
  PByteCounts = POffsets;
  TIFD = class(TObject)
         private
         {private declarations}
          VirtualPalette:Pointer;
          PaletteCreated:Boolean;
          PaletteVolume:DWord;
          function IncAddress(Addr:Pointer; Shift:LongInt):Pointer; pascal;
          Function TagType(TagIndex:Byte):Word;
          Function TagData(TagIndex:Byte):DWord;
          Function TagPointer(TagIndex:Byte):DWord;
          Function DataType(TagIndex:Byte):Word;
          Function DataFieldLength(TagIndex:Byte):DWord;
          Function GetTagIndex(TagCode:Word):Byte;
          Function GetStripeCount:Word;
         public
         {public declarations}
         FileHead:Pointer;
         PTags:PTagSet;
         TagCount:Word;
         NextIFD:DWord;
         Width:Word;
         Lenght:Word;
         BitsPerSample:Word;
         BitsPerPixel:Word;
         StripOffSet:DWord;
         Compression:Word;
         StripeCount:Word;
         RowsPerStrip:Word;
         SamplesPerPixel:Word;
         DataPointerSize:Byte;
         FillOrder:Byte;
         Orientation:Byte;
         PlanarConfiguration:Word;
         ColorMap:DWord;
         StripeByteCounts:DWord;
         PhotometricInterpretation:Byte;
         CompBits:Byte;
         OffSets:POffSets;
         ByteCounts:PByteCounts;
         Prediction:Boolean;
         Function GetColor(ClrInd:Word;RGBFlag:Byte):Byte;
         procedure ReadInit(VirtFile:Pointer;Shift:Longint);
         Constructor ReadCreate(VirtFile:pointer;Shift:Longint);
         procedure WriteInit(Source:TBitmap;Compressing:Boolean);
         Constructor WriteCreate(Source:TBitmap;Compressing:Boolean);
         procedure InitFromStream(inStream:TStream);
         Procedure InitFromFile(hFile:Thandle);
         Constructor CreateFromFile(hFile:Thandle);
         Constructor CreateFromStream(inStream:TStream);
         Destructor Destroy;override;
         published
         {published declarations}

         end;

implementation

function TIFD.IncAddress(Addr:Pointer; Shift:LongInt):Pointer; pascal;
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

function TIFD.TagType(TagIndex:Byte):Word;
Begin
     if (TagIndex<0)and(TagIndex>TagCount-1) then result:=0
     else
         result:=PTags^[TagIndex].TagType;
end;

function TIFD.TagData(TagIndex:Byte):DWord;
Var PDWord:^DWord;
Begin
     if (TagIndex<0)and(TagIndex>TagCount-1) then result:=DWord(0)
     else
         begin
              Result:=PTags^[TagIndex].DataOrPointer;
              If DataFieldLength(TagIndex)>1 Then
                 Begin
                      PDWord:=IncAddress(FileHead,Result);
                      Result:=PDWord^;
                 End;
              Case DataType(TagIndex) of
                   $1: Result:=Byte(Result);
                   $3: Result:=Word(Result);
              end;
         end;
End;

function TIFD.TagPointer(TagIndex:Byte):DWORD;
begin
     if (TagIndex<0)and(TagIndex>TagCount-1) then result:=DWord(0)
     else
         begin
              Result:=PTags^[TagIndex].DataOrPointer;
         end;
end;

function TIFD.DataType(TagIndex:Byte):Word;
begin
     if (TagIndex<0)and(TagIndex>TagCount-1) then result:=Word(0)
     else
         begin
              Result:=PTags^[TagIndex].DataType;
         end;
end;

Function TIFD.DataFieldLength(TagIndex:Byte):DWord;
begin
     if (TagIndex<0)and(TagIndex>TagCount-1) then result:=DWord(0)
     else
         begin
              Result:=PTags^[TagIndex].DataLength;
         end;
end;

Function TIFD.GetTagIndex(TagCode:Word):Byte;
var i:byte;
Begin
     Result:=TagCount;
     i:=0;
     While (TagType(i)<>TagCode)and(i<TagCount-1) do inc(i);
     If TagType(i) = TagCode Then Result:=i;
End;

Function TIFD.GetStripeCount:Word;
Var TInd:Byte;
Begin
     TInd:=GetTagIndex($111);
     If TInd<TagCount Then Result:=DataFieldLength(TInd)
     Else Result:=0;
End;

Function TIFD.GetColor(ClrInd:Word;RGBFlag:Byte):Byte;
var MaxItensivity:Word;
    PWord:^Word;
Begin
     MaxItensivity:=256;
     PWord:=IncAddress(VirtualPalette,2*RGBFlag*MaxItensivity+2*ClrInd);
     Result:=Round(Sqrt(PWord^+1))-1;
End;

procedure TIFD.ReadInit(VirtFile:Pointer;Shift:Longint);
var PTagCount:^Word;
    PTag:^TTag;
    PLong:^DWord;
    i:word;
begin
     FileHead:=VirtFile;
     PTagCount:=IncAddress(FileHead,Shift);
     TagCount:=PTagCount^;
     GetMem(PTags,12*TagCount);
     PTag:=IncAddress(PTagCount,2);
     for i:=0 to TagCount-1 do
         Begin
              PTags^[i]:=PTag^;
              PTag:=IncAddress(PTag,12);
              Case TagType(i) of
                   $100: Width:=TagData(i);
                   $101: Lenght:=TagData(i);
                   $102: BitsPerSample:=TagData(i);
                   $103: Compression:=TagData(i);
                   $106: PhotometricInterpretation:=TagData(i);
                   $10A: FillOrder:=TagData(i);
                   $111: StripOffSet:=TagPointer(i);
                   $112: Orientation:=TagData(i);
                   $115: SamplesPerPixel:=TagData(i);
                   $116: RowsPerStrip:=TagData(i);
                   $117: StripeByteCounts:=TagPointer(i);
                   $11C: PlanarConfiguration:=TagData(i);
                   $13D: Prediction:=TagData(i) = 2;
                   $140: begin
                              ColorMap:=TagPointer(i);
                              VirtualPalette:=IncAddress(FileHead,ColorMap);
                         end;
              end;
         end;
     Pointer(PLong):=Pointer(PTag);
     NextIFD:=PLong^;
     If Orientation = 0 then Orientation:=1;
     If FillOrder = 0 then FillOrder:=1;
     BitsPerPixel:=SamplesPerPixel*BitsPerSample;
     StripeCount:=GetStripeCount;
     GetMem(OffSets,StripeCount*SizeOf(TOffSets));
     GetMem(ByteCounts,StripeCount*SizeOf(TOffSets));
     If StripeCount>1 Then
        For i:=0 To StripeCount-1 do
            Begin
                 PLong:=IncAddress(FileHead,StripOffSet+i*SizeOf(TOffSets));
                 OffSets^[i]:=PLong^;
                 PLong:=IncAddress(FileHead,StripeByteCounts+i*SizeOf(TOffSets));
                 ByteCounts^[i]:=PLong^;
            end
        else
            begin
                 OffSets^[0]:=StripOffSet;
                 ByteCounts^[0]:=StripeByteCounts;
            end;
     StripOffSet:=OffSets^[0];
     StripeByteCounts:=ByteCounts^[0];
     CompBits:=(Width*BitsPerSample) mod 8;
     FreeMem(PTags,12*TagCount);
     TagCount:=0;
end;

Constructor TIFD.ReadCreate(VirtFile:pointer;Shift:Longint);
Begin
     inherited Create;
     TagCount:=0;
     ReadInit(VirtFile,Shift);
     PaletteCreated:=False;
end;

procedure TIFD.WriteInit(Source:TBitmap;Compressing:Boolean);
var i:Word;
    ImageSize:DWord;
    StripeSize:DWord;
begin
     TagCount:=14;
     GetMem(PTags,12*TagCount);
     i:=0;
     With PTags^[i] do
          begin
               TagType:=$0FE;
               DataType:=4;
               DataLength:=1;
               DataOrPointer:=0;
          end;
     i:=1;
     With PTags^[i] do
          begin
               TagType:=$100;
               DataType:=3;
               DataLength:=1;
               DataOrPointer:=Source.Width;
               Width:=DataOrPointer;
          end;
     i:=2;
     With PTags^[i] do
          begin
               TagType:=$101;
               DataType:=3;
               DataLength:=1;
               DataOrPointer:=Source.Height;
               Lenght:=DataOrPointer;
          end;
     i:=3;
     With PTags^[i] do
          begin
               TagType:=$102;
               DataType:=3;
               DataLength:=1;
               Case Source.PixelFormat of
                    pf1bit: begin
                                 DataOrPointer:=1;
                                 BitsPerSample:=1;
                            end;
                    pf4bit: begin
                                 DataOrPointer:=4;
                                 BitsPerSample:=4;
                            end;
                    pf8bit,pf16bit,
                    pf24bit
                          : begin
                                 DataOrPointer:=8;
                                 BitsPerSample:=8;
                            end;
               end;
          end;
     i:=4;
     With PTags^[i] do
          begin
               TagType:=$103;
               DataType:=3;
               DataLength:=1;
               If Compressing then
                  begin
                       DataOrPointer:=5;
                       Compression:=5;
                  end
               else
                   begin
                        DataOrPointer:=1;
                        Compression:=1;
                   end;
          end;
     i:=5;
     With PTags^[i] do
          begin
               TagType:=$106;
               DataType:=3;
               DataLength:=1;
               Case Source.PixelFormat of
                  pf1bit: begin
                               DataOrPointer:=0;
                               PhotometricInterpretation:=1;
                          end;
                  pf4bit,pf8bit: begin
                                      DataOrPointer:=1;
                                      PhotometricInterpretation:=1;
                                 end;
                  else
                      begin
                           DataOrPointer:=2;
                           PhotometricInterpretation:=2;
                      end;
               end;
          end;
     if (PhotometricInterpretation = 0) or  (PhotometricInterpretation = 1) then
        BitsPerPixel:=BitsPerSample
     else BitsPerPixel:=3*BitsPerSample;
     ImageSize:=((Width*BitsPerPixel+7) div 8)*Lenght;
     StripeSize:=($8000 div ((Width*BitsPerPixel+7) div 8))*((Width*BitsPerPixel+7) div 8);
     if StripeSize < ((Width*BitsPerPixel+7) div 8) then StripeSize:=((Width*BitsPerPixel+7) div 8);
     If StripeSize > ImageSize then StripeSize:=ImageSize;
     i:=6;
     With PTags^[i] do
          begin
               TagType:=$10A;
               DataType:=3;
               DataLength:=1;
               DataOrPointer:=1;
               FillOrder:=1;
          end;
     i:=7;
     With PTags^[i] do
          begin
               TagType:=$111;
               DataType:=4;
               DataLength:=(ImageSize div StripeSize)+1;
               If ((ImageSize mod StripeSize) = 0)
               then DataLength:=DataLength-1;
               StripeCount:=DataLength;
               DataOrPointer:=182;
               StripOffSet:=182;
          end;
     i:=8;
     With PTags^[i] do
          begin
               TagType:=$112;
               DataType:=3;
               DataLength:=1;
               DataOrPointer:=1;
               Orientation:=1;
          end;
     i:=9;
     With PTags^[i] do
          begin
               TagType:=$115;
               DataType:=3;
               DataLength:=1;
               if (PhotometricInterpretation = 0)
                  or  (PhotometricInterpretation = 1) then
                  begin
                       DataOrPointer:=1;
                       SamplesPerPixel:=1;
                  end
               else
                   begin
                       DataOrPointer:=3;
                       SamplesPerPixel:=3;
                   end;
          end;
     i:=10;
     With PTags^[i] do
          begin
               TagType:=$116;
               DataType:=3;
               DataLength:=1;
               DataOrPointer:=StripeSize div ((Width*BitsPerPixel+7) div 8);
               If DataOrPointer > Source.Height then DataOrPointer:=Source.Height;
               RowsPerStrip:=DataOrPointer;
          end;
     i:=11;
     With PTags^[i] do
          begin
               TagType:=$117;
               DataType:=4;
               DataLength:=StripeCount;
               If DataLength > 1 then
                  begin
                       DataOrPointer:=182+4*StripeCount;
                       StripeByteCounts:=DataOrPointer;
                  end
               else
                   begin
                        DataOrPointer:=StripeSize;
                        StripeByteCounts:=DataOrPointer;
                   end;
          end;
     i:=12;
     With PTags^[i] do
          begin
               TagType:=$11C;
               DataType:=3;
               DataLength:=1;
               DataOrPointer:=1;
               PlanarConfiguration:=1;
          end;
     i:=13;
     With PTags^[i] do
          begin
               TagType:=$13D;
               DataType:=3;
               DataLength:=1;
               DataOrPointer:=1;
               Prediction:=false;
          end;
     GetMem(OffSets,StripeCount*SizeOf(TOffSets));
     GetMem(ByteCounts,StripeCount*SizeOf(TOffSets));
     if StripeCount > 1 then
        begin
             for i:=0 to StripeCount-2 do
                 begin
                      OffSets^[i]:=182+8*StripeCount+i*StripeSize;
                      ByteCounts^[i]:=StripeSize;
                 end;
             i:=StripeCount-1;
             OffSets^[i]:=182+8*StripeCount+i*StripeSize;
             ByteCounts^[i]:=ImageSize-StripeSize*(StripeCount-1);
        end
     else
         begin
              OffSets^[0]:=182;
              ByteCounts^[0]:=ImageSize;
         end;
end;

Constructor TIFD.WriteCreate(Source:TBitMap;Compressing:Boolean);
begin
     inherited Create;
     WriteInit(Source,Compressing);
     PaletteCreated:=False;
end;

procedure TIFD.InitFromStream(inStream:TStream);
var PTagCount,PalItem:^Word;
    PLong:^DWord;
    Shift:Dword;
    i,j:word;
begin
     PaletteCreated:=False;
     inStream.Position:=4;
     New(PLong);
     inStream.ReadBuffer(PLong^,4);
     Shift:=PLong^;
     Dispose(PLong);
     inStream.Position:=Shift;
     New(PTagCount);
     inStream.ReadBuffer(PTagCount^,2);
     TagCount:=PTagCount^;
     Dispose(PTagCount);
     GetMem(PTags,12*TagCount);
     inStream.Position:=Shift+2;
     inStream.ReadBuffer(PTags^,12*TagCount);
     for i:=0 to TagCount-1 do
         Begin
              Case TagType(i) of
                   $100: Width:=TagData(i);
                   $101: Lenght:=TagData(i);
                   $102: begin
                              If PTags^[i].DataLength>1 Then
                                 Begin
                                      inStream.Position:=PTags^[i].DataOrPointer;
                                      New(PLong);
                                      inStream.ReadBuffer(PLong^,4);
                                      BitsPerSample:=Word(PLong^);
                                      Dispose(PLong);
                                 End
                              else
                              BitsPerSample:=Word(PTags^[i].DataOrPointer);
                         end;
                   $103: Compression:=TagData(i);
                   $106: PhotometricInterpretation:=TagData(i);
                   $10A: FillOrder:=TagData(i);
                   $111: StripOffSet:=TagPointer(i);
                   $112: Orientation:=TagData(i);
                   $115: SamplesPerPixel:=TagData(i);
                   $116: RowsPerStrip:=TagData(i);
                   $117: StripeByteCounts:=TagPointer(i);
                   $11C: PlanarConfiguration:=TagData(i);
                   $13D: Prediction:=TagData(i) = 2;
                   $140: begin
                              ColorMap:=TagPointer(i);
                              PaletteVolume:=DataFieldLength(i);
                              GetMem(VirtualPalette,2*PaletteVolume);
                              PalItem:=VirtualPalette;
                              inStream.Position:=ColorMap;
                              inStream.ReadBuffer(VirtualPalette^,2*PaletteVolume);
                              PaletteCreated:=True;
                         end;
              end;
         end;
     inStream.Position:=Shift+2+12*TagCount;
     New(PLong);
     inStream.ReadBuffer(PLong^,4);
     NextIFD:=PLong^;
     Dispose(PLong);
     If Orientation = 0 then Orientation:=1;
     If FillOrder = 0 then FillOrder:=1;
     BitsPerPixel:=SamplesPerPixel*BitsPerSample;
     StripeCount:=GetStripeCount;
     GetMem(OffSets,StripeCount*SizeOf(TOffSets));
     GetMem(ByteCounts,StripeCount*SizeOf(TOffSets));
     If StripeCount>1 Then
        begin
             inStream.Position:=StripOffSet;
             inStream.ReadBuffer(OffSets^,4*StripeCount);
             inStream.Position:=StripeByteCounts;
             inStream.ReadBuffer(ByteCounts^,4*StripeCount);
        end
     else
         begin
              OffSets^[0]:=StripOffSet;
              ByteCounts^[0]:=StripeByteCounts;
         end;
     StripOffSet:=OffSets^[0];
     StripeByteCounts:=ByteCounts^[0];
     CompBits:=(Width*BitsPerSample) mod 8;
     FreeMem(PTags,12*TagCount);
     TagCount:=0;
end;


procedure TIFD.InitFromFile(hFile:Thandle);
var PTagCount:^Word;
    PLong:^DWord;
    Shift:Dword;
    ipOverLapped:TOverLapped;
    i:word;
begin
     PaletteCreated:=False;
     ipOverLapped.Internal:=0;
     ipOverLapped.InternalHigh:=0;
     ipOverLapped.Offset:=4;
     ipOverLapped.OffsetHigh:=0;
     ipOverLapped.hEvent:=0;
     ReadFileEx(hFile,@Shift,4,@ipOverLapped,Nil);
     ipOverLapped.Offset:=Shift;
     New(PTagCount);
     ReadFileEx(hFile,PTagCount,2,@ipOverLapped,Nil);
     TagCount:=PTagCount^;
     Dispose(PTagCount);
     GetMem(PTags,12*TagCount);
     ipOverLapped.Offset:=Shift+2;
     ReadFileEx(hFile,PTags,12*TagCount,@ipOverLapped,Nil);
     for i:=0 to TagCount-1 do
         Begin
              Case TagType(i) of
                   $100: Width:=TagData(i);
                   $101: Lenght:=TagData(i);
                   $102: begin
                              If PTags^[i].DataLength>1 Then
                                 Begin
                                      ipOverLapped.Offset:=PTags^[i].DataOrPointer;
                                      New(PLong);
                                      ReadFileEx(hFile,PLong,4,@ipOverLapped,Nil);
                                      BitsPerSample:=Word(PLong^);
                                      Dispose(PLong);
                                 End
                              else
                              BitsPerSample:=Word(PTags^[i].DataOrPointer);
                         end;
                   $103: Compression:=TagData(i);
                   $106: PhotometricInterpretation:=TagData(i);
                   $10A: FillOrder:=TagData(i);
                   $111: StripOffSet:=TagPointer(i);
                   $112: Orientation:=TagData(i);
                   $115: SamplesPerPixel:=TagData(i);
                   $116: RowsPerStrip:=TagData(i);
                   $117: StripeByteCounts:=TagPointer(i);
                   $11C: PlanarConfiguration:=TagData(i);
                   $13D: Prediction:=TagData(i) = 2;
                   $140: begin
                              ColorMap:=TagPointer(i);
                              PaletteVolume:=DataFieldLength(i);
                              GetMem(VirtualPalette,2*PaletteVolume);
                              ipOverLapped.Offset:=ColorMap;
                              ReadFileEx(hFile,VirtualPalette,2*PaletteVolume,@ipOverLapped,Nil);
                              PaletteCreated:=True;
                         end;
              end;
         end;
     ipOverLapped.Offset:=Shift+2+12*TagCount;
     New(PLong);
     ReadFileEx(hFile,PLong,4,@ipOverLapped,Nil);
     NextIFD:=PLong^;
     Dispose(PLong);
     If Orientation = 0 then Orientation:=1;
     If FillOrder = 0 then FillOrder:=1;
     BitsPerPixel:=SamplesPerPixel*BitsPerSample;
     StripeCount:=GetStripeCount;
     GetMem(OffSets,StripeCount*SizeOf(TOffSets));
     GetMem(ByteCounts,StripeCount*SizeOf(TOffSets));
     If StripeCount>1 Then
        begin
             ipOverLapped.Offset:=StripOffSet;
             ReadFileEx(hFile,OffSets,4*StripeCount,@ipOverLapped,Nil);
             ipOverLapped.Offset:=StripeByteCounts;
             ReadFileEx(hFile,ByteCounts,4*StripeCount,@ipOverLapped,Nil);
        end
     else
         begin
              OffSets^[0]:=StripOffSet;
              ByteCounts^[0]:=StripeByteCounts;
         end;
     StripOffSet:=OffSets^[0];
     StripeByteCounts:=ByteCounts^[0];
     CompBits:=(Width*BitsPerSample) mod 8;
     FreeMem(PTags,12*TagCount);
     TagCount:=0;
end;

constructor TIFD.CreateFromFile(hFile:THandle);
begin
     inherited Create;
     InitFromFile(hFile);
end;

constructor TIFD.CreateFromStream(inStream:TStream);
begin
     inherited Create;
     InitFromStream(inStream);
end;

Destructor TIFD.Destroy;
Begin
     If TagCount>0 then FreeMem(PTags,12*TagCount);
     begin
          FreeMem(OffSets,StripeCount*SizeOf(TOffSets));
          FreeMem(ByteCounts,StripeCount*SizeOf(TOffSets));
     end;
     if PaletteCreated then FreeMem(VirtualPalette,2*PaletteVolume);
     Inherited Destroy;
End;
end.
