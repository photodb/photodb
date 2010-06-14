unit LZW_Module;

interface
uses
  Windows,SysUtils;
  const
       ClearCode:Word = 256;
       EoiCode = 257;
  type TTableEntry = record
                           index:Word;
                           prefix:Word;
                           suffix,firstbyte:byte;
                     end;
       PCluster = ^TCluster;
       TCluster = record
                        indx:word;
                        next:PCluster;
                  end;
       TByteStream = array[0..0] of Byte;
       PByteStream = ^TByteStream;
       TSmoothRange = 0..4;
       TLZW = Class(TObject)
              private
              {private declarations}
                       CodeAdress,Destination:Pointer;
                       CodeLength,BorrowedBits:Byte;
                       Code,OldCode,LastEntry:Word;
                       BytesHaveBeenReaden:DWord;
                       Table:  Array[0..4095] of TTableEntry;
                       Clusters: array[0..4095] of PCluster;
                       function GetNextCode:Word;
                       procedure Initialize;
                       procedure ReleaseClusters;
                       procedure WriteBytes(Entry:TTableEntry);
                       procedure AddEntry(Entry:TTableEntry);
                       function Concatention(PPrefix:word;LastByte:Byte;Indx:Word):TTableEntry;
                       procedure AddTableEntry(Entry:TTableEntry);
                       procedure WriteCodeToStream(Code:Word);
                       function CodeFromString(Str:TTableEntry):Word;
              public
              {public declarations}
                 procedure DecodeLZW(Sourse,Dest:Pointer);
                 procedure EncodeLZW(Sourse,Dest:Pointer;var ByteCounts:DWord);
                 procedure SmoothEncodeLZW(Sourse,Dest:Pointer;SmoothRange:TSmoothRange;var ByteCounts:DWord);
              end;

implementation


function TLZW.Concatention(PPrefix:Word;LastByte:Byte;Indx:Word):TTableEntry;
begin
     If PPrefix = ClearCode then
        begin
             Result.index:=LastByte;
             Result.firstbyte:=LastByte;
             Result.prefix:=PPrefix;
             Result.suffix:=LastByte;
        end
     else
         begin
              Result.index:=Indx;
              Result.firstbyte:=Table[PPrefix].firstbyte;
              Result.prefix:=Table[PPrefix].index;
              Result.suffix:=LastByte;
         end;
end;

Procedure TLZW.Initialize;
    var i:Word;
begin
     For i:=0 to 255 do
         with Table[i] do
                   Begin
                        Index:=i;
                        Prefix:=256;
                        suffix:=i;
                        firstbyte:=i;
                   end;
     with Table[256] do
          Begin
               Index:=256;
               Prefix:=256;
               suffix:=0;
               firstbyte:=0;
          end;
     With Table[257] do
          Begin
               Index:=257;
               Prefix:=256;
               suffix:=0;
               firstbyte:=0;
          end;
     For i:=258 to 4095 do
         with Table[i] do
              Begin
                   Index:=i;
                   Prefix:=256;
                   suffix:=0;
                   firstbyte:=0;
              end;
     LastEntry:=257;
     CodeLength:=9;
end;

procedure TLZW.ReleaseClusters;
var i:word;
    WorkCluster:PCluster;
begin
     for i:=0 to 4095 do
         begin
              if Assigned(Clusters[i]) then
                 begin
                      While Clusters[i]^.Next<>Nil do
                            begin
                                 WorkCluster:=Clusters[i];
                                 While Assigned(WorkCluster^.next^.next) do
                                       WorkCluster:=WorkCluster^.next;
                                       Dispose(WorkCluster^.next);
                                       WorkCluster^.next:=Nil;
                            end;
                      Dispose(Clusters[i]);
                      Clusters[i]:=Nil;
                 end;
         end;
end;

procedure TLZW.WriteBytes(Entry:TTableEntry);
var PByte:^Byte;
begin
     if Entry.prefix = ClearCode then
        begin
             PByte:=Destination;
             PByte^:=Entry.suffix;
             Inc(DWord(Destination));
        end
     else
         begin
              WriteBytes(Table[Entry.prefix]);
              PByte:=Destination;
              PByte^:=Entry.suffix;
              Inc(DWord(Destination));
         end;
end;

procedure TLZW.AddEntry(Entry:TTableEntry);
begin
     Table[Entry.index]:=Entry;
     LastEntry:=Entry.index;
     Case LastEntry of
          510,1022,2046: Begin
                                   inc(CodeLength);
                         end;
          4093: Begin
                     CodeLength:=9;
                end;

     end;
end;

function TLZW.GetNextCode:Word;
Var Adr:Pointer;
    BBits,Len:Byte;
label TWO_BYTES_CODE,THREE_BYTES_CODE,RESULT_POINT;
begin
     Adr:=CodeAdress;
     BBits:=BorrowedBits;
     Len:=CodeLength;
     asm
                             PUSH    EAX
                             PUSH    EBX
                             PUSH    ECX
                             PUSH    EDX
                             MOV     EBX, Adr
                             MOV      CH,16
                             ADD      CH,BBits
                             SUB      CH,Len
                             CMP      CH,8
                             JG       TWO_BYTES_CODE
                             JMP      THREE_BYTES_CODE
           TWO_BYTES_CODE:   MOV      AH,BYTE PTR [EBX]
                             MOV      AL,BYTE PTR [EBX+1]
                             MOV      CL,8
                             SUB      CL,BBits
                             SHL      AH,CL
                             SHR      AH,CL
                             MOV      CL, BBits
                             ADD      CL,8
                             SUB      CL,Len
                             SHR      AL,CL
                             SHL      AL,CL
                             SHR      AX,CL
                             MOV      BBits,CL
                             INC      Adr
                             JMP      RESULT_POINT
           THREE_BYTES_CODE: MOV      AH,BYTE PTR [EBX]
                             MOV      AL,BYTE PTR [EBX+1]
                             MOV      DL,BYTE PTR [EBX+2]
                             MOV      CL,8
                             SUB      CL,BBits
                             SHL      AX,CL
                             SHR      AX,CL
                             MOV      CL,CH
                             SHR      DL,CL
                             MOV      CH,8
                             SUB      CH,CL
                             XCHG     CL,CH
                             SHL      AX,CL
                             MOV      DH,0
                             OR      AX,DX
                             MOV      BBits,CH
                             INC      Adr
                             INC      Adr
                             JMP      RESULT_POINT
           RESULT_POINT:     MOV      @Result,AX
                             POP    EDX
                             POP    ECX
                             POP    EBX
                             POP    EAX
     end;
     BorrowedBits:=BBits;
     CodeAdress:=Adr;
end;

procedure TLZW.DecodeLZW(Sourse,Dest:Pointer);
begin
     Destination:=Dest;
     BorrowedBits:=8;
     CodeLength:=9;
     BytesHaveBeenReaden:=0;
     CodeAdress:=Sourse;
     Initialize;
     OldCode:=256;
     Code:=GetnextCode;
     While (Code<>EoiCode) do
           Begin
                if Code = ClearCode then
                   Begin
                        Initialize;
                        Code:=GetnextCode;
                        If Code = EoiCode then Break;
                        WriteBytes(Table[Code]);
                        OldCode:=Code;
                   end
                else
                    Begin
                         if Code<=LastEntry then
                            begin
                                 WriteBytes(Table[Code]);
                                 AddEntry(Concatention(OldCode,Table[Code].firstbyte,LastEntry+1));
                                 OldCode:=Code;
                            end
                         else
                             begin
                                  If Code>LastEntry+1 Then
                                     begin
                                          Break;
                                     end
                                  else
                                  begin
                                       WriteBytes(Concatention(OldCode,Table[OldCode].firstbyte,LastEntry+1));
                                       AddEntry(Concatention(OldCode,Table[OldCode].firstbyte,LastEntry+1));
                                       OldCode:=Code;
                                  end;
                             end;
                    end;
                Code:=GetnextCode;
           end;
end;


procedure TLZW.WriteCodeToStream(Code:Word);
label TWO_BYTES_CODE,THREE_BYTES_CODE,EXIT_POINT;
var BBits,CLength:Byte;
    vCode:Word;
    Adr:pointer;
begin
     Adr:=Destination;
     BBits:=BorrowedBits;
     CLength:=CodeLength;
     vCode:=Code;
     asm
                             PUSH    EAX
                             PUSH    EBX
                             PUSH    ECX
                             PUSH    EDX
                             MOV      CH,CLength
                             SUB      CH,BBits
                             CMP      CH,8
                             JGE      THREE_BYTES_CODE
                             JMP      TWO_BYTES_CODE
           TWO_BYTES_CODE:   MOV      EBX,Adr
                             MOV      AX,vCode
                             MOV      CL,8
                             ADD      CL,BBits
                             SUB      CL,CLength
                             SHL      AX,CL
                             OR       BYTE PTR [EBX],AH
                             INC      EBX
                             OR       BYTE PTR [EBX],AL
                             MOV      Adr,EBX
                             MOV      BBits,CL
                             JMP      EXIT_POINT
           THREE_BYTES_CODE: MOV      EBX,Adr
                             MOV      AX,vCode
                             MOV      DX,AX
                             MOV      CL,CLength
                             SUB      CL,8
                             SUB      CL,BBits
                             SHR      AX,CL
                             SHL      AX,CL
                             SUB      DX,AX
                             SHR      AX,CL
                             OR       BYTE PTR [EBX],AH
                             INC      EBX
                             OR       BYTE PTR [EBX],AL
                             INC      EBX
                             MOV      CH,8
                             SUB      CH,CL
                             XCHG     CH,CL
                             SHL      DL,CL
                             OR       BYTE PTR [EBX],DL
                             MOV      Adr,EBX
                             MOV      BBits,CL
                             JMP      EXIT_POINT
           EXIT_POINT:       POP    EDX
                             POP    ECX
                             POP    EBX
                             POP    EAX
     end;
     Destination:=Adr;
     BorrowedBits:=BBits;
end;

function TLZW.CodeFromString(Str:TTableEntry):Word;
var WorkCluster:PCluster;
begin
     If STR.prefix = 256 then Result:=Str.index
     else
         begin
              WorkCluster:=Clusters[Str.prefix];
              if not Assigned(WorkCluster) then Result:=4095
              else
                  begin
                       While Assigned(WorkCluster^.next) do
                             if (Str.suffix <> Table[WorkCluster^.indx].suffix) then
                                WorkCluster:=WorkCluster^.next
                             else break;
                       if Str.suffix = Table[WorkCluster^.indx].suffix then
                          Result:= WorkCluster^.indx
                       else Result:=4095;
                  end;
         end;
end;

procedure TLZW.AddTableEntry(Entry:TTableEntry);
var WorkCluster:PCluster;
begin
     Table[Entry.index]:=Entry;
     LastEntry:=Entry.index;
     if not Assigned(Clusters[Table[LastEntry].prefix]) Then
        begin
             New(Clusters[Table[LastEntry].prefix]);
             Clusters[Table[LastEntry].prefix]^.indx:=LastEntry;
             Clusters[Table[LastEntry].prefix]^.next:=Nil;
        end
     else
         begin
              WorkCluster:=Clusters[Table[LastEntry].prefix];
              While Assigned(WorkCluster^.next) do WorkCluster:=WorkCluster^.next;
              New(WorkCluster^.next);
              WorkCluster^.next^.indx:=LastEntry;
              WorkCluster^.next^.next:=Nil;
         end;
end;

procedure TLZW.EncodeLZW(Sourse,Dest:Pointer;var ByteCounts:DWord);
var //PByte:^Byte;
    vPrefix:TTableEntry;
    CurrEntry:TTableEntry;
    CurrCode:Word;
    i:DWord;
    InputStream:PByteStream;
begin
     Destination:=Dest;
     Initialize;
     For i:=0 to 4095 do Clusters[i]:=Nil;
     //ReleaseClusters;
     BorrowedBits:=8;
     WriteCodeToStream(ClearCode);
     CodeAdress:=Sourse;
     InputStream:=Sourse;
     BytesHaveBeenReaden:=0;
     vPrefix:=Table[ClearCode];
     for  i:=0 to  ByteCounts-1 do
          begin
                CurrEntry:=Concatention(vPrefix.index,InputStream^[i],LastEntry+1);
                CurrCode:=CodeFromString(CurrEntry);
                If CurrCode<=LastEntry Then vPrefix:=Table[CurrCode]
                Else
                    begin
                         WriteCodeToStream(vPrefix.index);
                         AddTableEntry(CurrEntry);
                         vPrefix:=Table[InputStream^[i]];
                         Case LastEntry of
                              511,1023,2047: Begin
                                                  inc(CodeLength);
                                             end;
                                       4093: Begin
                                                  WriteCodeToStream(ClearCode);
                                                  CodeLength:=9;
                                                  ReleaseClusters;
                                                  LastEntry:=EoiCode;
                                             end;

                         end;
                    end;
          end;
     WriteCodeToStream(CodeFromString(vPrefix));
     WriteCodeToStream(EoiCode);
     ReleaseClusters;
     ByteCounts:=1+DWORD(Destination)-DWORD(Dest);
end;

procedure TLZW.SmoothEncodeLZW(Sourse,Dest:Pointer;SmoothRange:TSmoothRange;var ByteCounts:DWord);
var CByte,ByteMask:Byte;
    vPrefix:TTableEntry;
    CurrEntry:TTableEntry;
    CurrCode:Word;
    i:DWord;
    InputStream:PByteStream;
begin
     ByteMask:=($FF shr SmoothRange) shl SmoothRange;
     Destination:=Dest;
     Initialize;
     For i:=0 to 4095 do Clusters[i]:=Nil;
     //ReleaseClusters;
     BorrowedBits:=8;
     WriteCodeToStream(ClearCode);
     CodeAdress:=Sourse;
     InputStream:=Sourse;
     BytesHaveBeenReaden:=0;
     vPrefix:=Table[ClearCode];
     for  i:=0 to  ByteCounts-1 do
          begin
                CByte:=InputStream^[i] and ByteMask;
                CurrEntry:=Concatention(vPrefix.index,CByte,LastEntry+1);
                CurrCode:=CodeFromString(CurrEntry);
                If CurrCode<=LastEntry Then vPrefix:=Table[CurrCode]
                Else
                    begin
                         WriteCodeToStream(vPrefix.index);
                         AddTableEntry(CurrEntry);
                         vPrefix:=Table[CByte];
                         Case LastEntry of
                              511,1023,2047: Begin
                                                  inc(CodeLength);
                                             end;
                                       4093: Begin
                                                  WriteCodeToStream(ClearCode);
                                                  CodeLength:=9;
                                                  ReleaseClusters;
                                                  LastEntry:=EoiCode;
                                             end;

                         end;
                    end;
          end;
     WriteCodeToStream(CodeFromString(vPrefix));
     WriteCodeToStream(EoiCode);
     ReleaseClusters;
     ByteCounts:=1+DWORD(Destination)-DWORD(Dest);
end;

end.

