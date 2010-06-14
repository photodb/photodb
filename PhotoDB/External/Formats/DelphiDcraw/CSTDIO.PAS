

{$DEFINE GENERIC}
Const
{$IFDEF GENERIC}
  PhotoJockeyDLL='MSDCRAW.DLL';
{$ELSE}
  PhotoJockeyDLL='PhotoJockey.DLL';
{$ENDIF}

Type
 Size_T=LongInt;
 TRAWFileStream=Packed Record
    FFile:TFastFile;
    Marker:Integer;
    AppendMode:Integer;
    LastWrittenByte:LongInt;
    End;
 PRAWFileStream=^TRAWFileStream;

TRAWFilePointers=Packed Record
             Size:Integer;
             fileno:Pointer;
             fgets:Pointer;
             fopen:Pointer;
             fclose:Pointer;
             ftell:Pointer;
             ferror:Pointer;
             fread:Pointer;
             fgetc:Pointer;
             fwrite:Pointer;
             fputc:Pointer;
             fputs:Pointer;
             feof:Pointer;
             fseek:Pointer;
             IFile:Pointer;
             OFile:Pointer;
             CleanUpFunction:Pointer;
             End;
PRAWFilePointers=^TRAWFilePointers;

TRAWSettings=Packed Record
             cbSize:Integer;
             igamma_val:Single;
	     ibright:Single;
             iBlack_Level:Integer;
	     iscale1:Single;
	     iscale2:Single;
	     iscale3:Single;
	     iscale4:Single;
             iRAWColors:Byte;
	     ifour_color_rgb:byte;
	     iquality:byte;
	     iShrink:byte;
	     iuse_auto_wb:byte;
	     iuse_camera_wb:byte;
	     iRGB_Colors:byte;
             ihighlight:Integer;
             igetthumbnail:byte;
             othumbnail_type:shortint;
             End;

TExifRecord=Packed Record
         ExifLength:Integer;
         ExifStart:Integer;
         End;
PExifRecord=^TExifRecord;



TProgress=Packed Record
         Progress:Pointer;
         Context:Pointer;
         End;
PProgress=^TProgress;

Const
 RAW_THUMB_TIFF     =3;
 RAW_THUMB_PPM      =2;
 RAW_THUMB_JPG      =1;
 RAW_THUMB_BAD     =-2;
 RAW_THUMB_NOTAVAIL=-1;

 RAW_RGB_sRGB=1;

 f_EOF=-1;
 f_SEEK_SET=0;
 f_SEEK_CUR=1;
 f_SEEK_END=2;

 am_NoAppend=0;
 am_YesAppendKeepEOF=1;
 am_YesAppendClearEOF=2;


//Const C_FPU_MASK=$3F;
Const C_FPU_MASK=$10BF;
procedure       _FpuInit;
//const cwDefault: Word = $1332 { $133F};
asm
        Nop
        Nop
        Nop
        Nop
        Nop
        Nop
        FNINIT
        FWAIT
        FLDCW   Default8087CW
end;

procedure _SaveFPU(Var SFPU:Word);
Asm
   push ESI
   nop
   nop
   nop
   WAIT
   FWAIT
   MOV  ESI,SFPU
   FSTCW WORD PTR[ESI]
   pop ESI
End;

procedure _RestFPU(Var SFPU:Word);
Begin
_FPUInit;
Set8087CW(SFPU);
End;


{
{ These functions are not called by the Delphi apps, but instead they are called by the DLL :)
{ These are functionally equivalant to the C+ language versions.
{
{ NOTE: At the bottom of these routines are the 2 main functions that the Delphi program will call to setup
{       the function pointer list that gets passed to the DLL so that it can then in turn call these functions
{       to perform all the file IO.
}
Function fileno(Const stream:TRAWFileStream):Integer cdecl;
Var
  SFPU:Word;
Begin
{
Valid return numbers should be >2 because standard open files are 0,1,2
}
_SaveFPU(SFPU);
If (@Stream<>Nil) And (Stream.Marker=$6969) Then
   Begin
   Result:=Stream.FFile.FileNo;
   End
Else
   Result:=-1;
_RestFPU(SFPU);
End;

Function fgets(InString:PChar;N:Integer;Const stream:TRAWFileStream):PChar cdecl;
Label
  LExit;
Var
  Buffer:PChar;
  Count:Integer;
  SFPU:Word;
Begin
 _SaveFPU(SFPU);
 If (@Stream=Nil) Or (Stream.Marker<>$6969) Then
 Begin
   Result:='';
   Goto LExit;
 End;
 If Stream.FFile.Position=Stream.FFile.Size Then
 Begin
   Result:=Nil;
 End Else
 Begin
   If IoResult<>0 Then;
   Buffer:=InString;
   Count:=0;
   While (Stream.FFile.GetBytes(Buffer^,1)=1) And (Buffer^<>#10) And (Count<N-1) Do
   Begin
     Inc(Buffer);
     Inc(Count);
   End;
   Buffer^:=#00;
   Inc(Buffer);
   Result:=InString;
 End;
{
returns a string
NULL indicates error!
The fgets function reads a string from the input stream argument and stores it in string.
fgets reads characters from the current stream position to and including the first newline character,
to the end of the stream, or until the number of characters read is equal to n -1, whichever comes first.
The result stored in string is appended with a null character.
The newline character, if read, is included in the string.
}
 LExit:
  _RestFPU(SFPU);
End;

Function fopen(const filename:PChar;const mode:PChar ):PRAWFileStream cdecl;
Var
  IMode:Integer;
  MMode:String;
  B:Char;
  Found:Boolean;
  Count:Integer;
  FError:Integer;
  SFPU:Word;
Begin
{
Null return = Invalid open

fmCreate	Create a file with the given name. If a file with the given name exists, open the file in write mode.
fmOpenRead	Open the file for reading only.
fmOpenWrite	Open the file for writing only. Writing to the file completely replaces the current contents.
fmOpenReadWrite	Open the file to modify the current contents rather than replace them.

The share mode must be one of the following values:

Value	Meaning

fmShareCompat	Sharing is compatible with the way FCBs are opened.
fmShareExclusive	Other applications can not open the file for any reason.
fmShareDenyWrite	Other applications can open the file for reading but not for writing.
fmShareDenyRead	Other applications can open the file for writing but not for reading.
fmShareDenyNone	No attempt is made to prevent other applications from reading from or writing to the file.

If the file can not be opened, Create will raise an exception.
}
_SaveFPU(SFPU);
GetMem(Result,SizeOf(TRAWFileStream));
Result.FFile:=Nil;
Try
Result.Marker:=$6969;
Result.AppendMode:=am_NoAppend;
MMode:=Mode;
IMode:=fmOpenRead;
If Pos('r+',MMode)<>0 Then IMode:=fmOpenReadWrite
Else
If Pos('r',MMode)<>0 Then IMode:=fmOpenRead
Else
If Pos('w',MMode)<>0 Then IMode:=fmCreateFileNow Or fmOpenReadWrite
Else
If Pos('w+',MMode)<>0 Then IMode:=fmCreateFileNow Or fmOpenReadWrite
Else
If Pos('wb',MMode)<>0 Then IMode:=fmCreateFileNow Or fmOpenReadWrite
Else
If Pos('a',MMode)<>0 Then Begin
                          IMode:=fmOpenReadWrite;
                          Result.AppendMode:=am_YesAppendKeepEOF;
                          End
Else
If Pos('a+',MMode)<>0 Then Begin
                          IMode:=fmOpenReadWrite;
                          Result.AppendMode:=am_YesAppendClearEOF;
                          End;
IMode:=IMode Or fmShareDenyNone;
If IoResult<>0 Then;
Result.FFile:=TFastFile.Create(FileName,IMode,FError);
If FError=0 Then
   Begin
   If Result.AppendMode In [am_YesAppendKeepEOF,am_YesAppendClearEOF] Then
      Begin
      If Result.AppendMode=am_YesAppendKeepEOF Then
         Begin
         Result.LastWrittenByte:=Result.FFile.Size;
         End
      Else
         Begin
         Count:=-1;
         Found:=False;
         While (Count>-128) And (Found=False) Do
               Begin
               Result.FFile.Seek(Count,SOFROMEND);
               If Result.FFile.GetBytes(B,1)<>1 Then
                  Begin
                  Found:=True;
                  Result.LastWrittenByte:=0;
                  End;
               If B=^Z Then
                  Begin
                  Result.LastWrittenByte:=Result.FFile.Size+Count;
                  Found:=True;
                  End;
               Dec(Count);
               End;
         End;
      End;
   End
Else
   Begin
   Result.FFile.Free;
   FreeMem(Result,SizeOf(TRAWFileStream));
   Result:=Nil;
   End;
Except
If Result.FFile<>Nil Then
   Result.FFile.Free;
FreeMem(Result,SizeOf(TRAWFileStream));
If IoResult<>0 Then;
Result:=Nil;
End;
_RestFPU(SFPU);
End;

Function fclose(Var stream:TRAWFileStream ):Integer cdecl;
Var
  P1:PRAWFileStream;
  SFPU:Word;
Begin
_SaveFPU(SFPU);
P1:=@Stream;
If (P1<>Nil) And (P1.Marker=$6969) Then
   Begin
   If IoResult<>0 Then;
   Stream.FFile.Free;
   Stream.FFile:=Nil;
   FreeMem(P1,SizeOf(TRAWFileStream));
   If IoResult<>0 Then;
   End;
Result:=0;
Try
Except
Result:=f_EOF;
End;
_RestFPU(SFPU);
End;

Function ftell(Const stream:TRAWFileStream):Size_T cdecl;
Label
  LExit;
Var
  SFPU:Word;
Begin
_SaveFPU(SFPU);
If (@Stream=Nil) Or (Stream.Marker<>$6969) Then
   Begin
   Result:=-1;
   Goto LExit;
   End;
If IoResult<>0 Then;
Result:=Stream.FFile.Position;
If IoResult<>0 Then;
LExit:
_RestFPU(SFPU);
End;

Function ferror(Const stream:TStream ):Integer cdecl;
Begin
Result:=0;
End;

Function fread(Var Buffer;Fsize:Size_T; count:Size_T;Const stream:TRAWFileStream ):Size_T cdecl;
Label
  LExit;
Var
  SFPU:Word;
Begin
_SaveFPU(SFPU);
{
fread returns the number of full items actually read, which may be less than count
if an error occurs or if the end of the file is encountered before reaching count.
Use the feof or ferror function to distinguish a read error from an end-of-file condition.
If size or count is 0, fread returns 0 and the buffer contents are unchanged.
}
If (@Stream=Nil) Or (Stream.Marker<>$6969) Then
   Begin
   Result:=-1;
   Goto LExit;
   End;
Result:=Stream.FFile.GetBytes(Buffer,FSize*Count);
LExit:
_RestFPU(SFPU);
End;

Function fgetc(Const stream:TRAWFileStream):Integer cdecl;
Begin
{
Read a char
fgetc and _fgetchar return the character read as an int or return EOF to indicate an error or end of file.
}
If (@Stream=Nil) Then
   Begin
   Result:=f_EOF;
   Exit;
   End;
Result:=Stream.FFile.GetByte;
If Stream.FFile.FError<>0 Then
   Result:=f_EOF;
End;

Function fwrite(Var buffer;size, count:Size_T;Var stream:TRAWFileStream ):Size_T cdecl;
Label
  LExit;
Var
  BCount:Integer;
  SFPU:Word;
Begin
{
fwrite returns the number of full items actually written,
which may be less than count if an error occurs.
Also, if an error occurs, the file-position indicator cannot be determined.
}
_SaveFPU(SFPU);
If (@Stream=Nil) Or (Stream.Marker<>$6969) Then
   Begin
   Result:=-1;
   Goto LExit;
   End;
If IoResult<>0 Then;
If Stream.AppendMode In [am_YesAppendKeepEOF,am_YesAppendClearEOF] Then
   Stream.FFile.Seek(Stream.LastWrittenByte,SOFROMBEGINNING);
BCount:=Stream.FFile.Write(Buffer,Count*Size);
Inc(Stream.LastWrittenByte,BCount);
Result:=BCount Div Size;
If IoResult<>0 Then;
LExit:
_RestFPU(SFPU);
End;

Function fputc(c:Integer;Var stream:TRAWFileStream ):Integer cdecl;
Label
  LExit;
Var
  B:Byte;
  P:Pointer;
  SFPU:Word;
Begin
{
Each of these functions writes the single character c to a file at the position indicated
by the associated file position indicator (if defined) and advances the indicator as appropriate.
In the case of fputc and fputwc, the file is associated with stream.
If the file cannot support positioning requests or was opened in append mode,
the character is appended to the end of the stream. Routine-specific remarks follow.
}
_SaveFPU(SFPU);
P:=@Stream;
If P=Nil Then
   Begin
   Write(Chr(C));
   Result:=C;
   Goto LExit;
   End;
If Stream.Marker<>$6969 Then
   Begin
   Result:=-1;
   Goto LExit;
   End;
If IoResult<>0 Then;
If Stream.AppendMode In [am_YesAppendKeepEOF,am_YesAppendClearEOF] Then
   Stream.FFile.Seek(Stream.LastWrittenByte,SOFROMBEGINNING);
B:=C;
If Stream.FFile.Write(B,1)<>1 Then
   Result:=f_EOF
Else
   Begin
   Result:=B;
   Inc(Stream.LastWrittenByte);
   End;
If IoResult<>0 Then;
LExit:
_RestFPU(SFPU);
End;

Function  fputs(const OutString:PChar;Var stream:TRAWFileStream ):Integer cdecl;
Label
  LExit;
Var
  BWrite:LongInt;
  SFPU:Word;
Begin
{
put a STRING
EOF ON ERROR!
this function copies string to the output stream at the current position. This does NOT copy the terminating null character.
}
_SaveFPU(SFPU);
If (@Stream=Nil) Or (Stream.Marker<>$6969) Then
   Begin
   Result:=-1;
   Goto LExit;
   End;
If IoResult<>0 Then;
If StrLen(OutString)>0 Then
   Begin
   If Stream.AppendMode In [am_YesAppendKeepEOF,am_YesAppendClearEOF] Then
      Stream.FFile.Seek(Stream.LastWrittenByte,SOFROMBEGINNING);
   BWrite:=Stream.FFile.Write(OutString^,StrLen(OutString));
   Inc(Stream.LastWrittenByte,BWrite);
   If BWrite<>StrLen(OutString) Then
      Result:=f_EOF
   Else
      Result:=1;
   End
Else
   Result:=1;
If IoResult<>0 Then;
LExit:
_RestFPU(SFPU);
End;

Function feof(Const stream:TRAWFileStream ):Integer cdecl;
Label
  LExit;
Var
  SFPU:Word;
Begin
{
-1 means EOF and 0=NOT EOF
}
_SaveFPU(SFPU);
If (@Stream=Nil) Or (Stream.Marker<>$6969) Then
   Begin
   Result:=-1;
   Goto LExit;
   End;
If IoResult<>0 Then;
If Stream.FFile.Position=Stream.FFile.Size Then
   Result:=f_EOF
Else
   Result:=0;
If IoResult<>0 Then;
LExit:
_RestFPU(SFPU);
End;

Function fseek(Const stream:TRAWFileStream;offset:Integer;origin:Integer):Integer cdecl;
Label
  LExit;
Var
  CurrPos:Integer;
  SFPU:Word;
Begin
{
origin of
SEEK_SET = From begining of file
SEEK_END = From END of the file
SEEK_CUR = From the current position
}
_SaveFPU(SFPU);
Result:=-1;
If (@Stream=Nil) Or (Stream.Marker<>$6969) Then
   Begin
   Result:=-1;
   Goto LExit;
   End;
Case Origin Of
     f_SEEK_SET:Begin
                CurrPos:=Stream.FFile.Seek(Offset,SOFROMBEGINNING);
                If CurrPos=Offset Then Result:=0;
                End;
     f_SEEK_END:Begin
                Stream.FFile.Seek(Offset,SOFROMEND);
                Result:=0;
                End;
     f_SEEK_CUR:Begin
                Stream.FFile.Seek(Offset,SOFROMCURRENT);
                Result:=0;
                End;
     End;
LExit:
_RestFPU(SFPU);
End;

function CleanUpFunction(leavefilesopen,ofp,ifp,file_fscanf,meta_data,image,ifname,ofname,oprof:Integer):Integer;cdecl;
//Var
//  IStream:PRawFileStream;
//  OStream:PRawFileStream;
//  IFileNum:Integer;
Begin
 Result:=0;
{
{ leavefilesopen is boolean
{ ofp,ifp,file_fscanf   these are PRawFileStreams
{  meta_data,image,ifname,ofname,oprof  are pointers to memory allocation blocks
}
(*
_SaveFPU(SFPU);
IStream:=Pointer(Ifp);
OStream:=Pointer(Ofp);
IFileName:='?';
OFileName:='?';
IFileNum:=-1;
OFileNum:=-1;
If (IStream<>Nil) And (IStream.Marker=$6969) Then
   Begin
   IFileName:=IStream.FFile.FileName;
   IFileNum:=Integer(IStream.FFile);
   End;
If (OStream<>Nil) And (OStream.Marker=$6969) Then
   Begin
   OFileName:=OStream.FFile.FileName;
   OFileNum:=Integer(OStream.FFile);
   End;
writeln(leavefilesopen,',',file_fscanf,',',meta_data,',',image,',',oprof);
write(IFileName,', fileno=',IFileNum,', ');
if ifname<>0 Then
   write(pchar(ifname));
writeln;
write(OFileName,', fileno=',OFileNum,', ');
If ofname<>0 Then
   write(pchar(ofname));
Writeln;
_RestFPU(SFPU);
*)
End;

{
{ Main functions that we call to setup Streamed files so that way we can reference already opened streams as a file,
{ this includes Memory Streams! This is cool if you don't want the output to be saved to disk, but instead
{ saved to YOUR stream you have setup. ALSO, you can force the DLL to read from your STREAM instead of
{ trying to open up a disk file for input.
}
Procedure raw_fileio_init_Stream(Var stream:TRAWFileStream);
Begin
FillChar(Stream,SizeOf(Stream),0);
Stream.Marker:=$6969;
End;

Procedure raw_fileio_init_Pointers(Var Ptrs:TRAWFilePointers);
Begin
FillChar(Ptrs,SizeOf(Ptrs),0);
Ptrs.Size:=SizeOf(Ptrs);
Ptrs.FileNo:=@FileNo;
Ptrs.FGets:=@FGetS;
Ptrs.FOpen:=@FOpen;
Ptrs.FClose:=@FClose;
Ptrs.FTell:=@FTell;
Ptrs.FError:=@FError;
Ptrs.FRead:=@FRead;
Ptrs.FGetC:=@FGetC;
Ptrs.FWrite:=@FWrite;
Ptrs.FPutC:=@FPutC;
Ptrs.FPutS:=@FPutS;
Ptrs.FEOF:=@FEOF;
Ptrs.FSeek:=@FSeek;
Ptrs.CleanUpFunction:=@CleanUpFunction;
End;

Procedure raw_exif_init(Var ExifRecord:TExifRecord);
Begin
ExifRecord.ExifStart:=0;
ExifRecord.ExifLength:=0;
End;


{$IFDEF GENERIC}
Procedure MyProgress(Stage:Integer;Height:Integer;CurrLine:Integer;Context:TForm;Msg:PChar); cdecl;
Var
  SFPU:Word;
//  MyForm:TForm;
Begin
_SaveFPU(SFPU);
{ Perform some kind of progress meter }
//MyForm:=Context;
If Context<>Nil Then
_RestFPU(SFPU);
End;
{$ELSE}
Procedure MyProgress(Stage:Integer;Height:Integer;CurrLine:Integer;Context:TRAWImage;Msg:PChar); cdecl;
Var
  MyRAW:TRAWImage;
  SFPU:Word;
Begin
_SaveFPU(SFPU);
MyRaw:=Context;
If Context<>Nil Then
   MyRaw.DoProgress(Stage,Height,CurrLine,msg);
_RestFPU(SFPU);
End;
{$ENDIF}



Procedure raw_progress_init(Var Progress:TProgress;Context:Pointer);
Begin
Progress.Progress:=@MyProgress;
Progress.Context:=Context;
End;

Procedure raw_settings_init(Var Settings:TRAWSettings);
Begin
FillChar(Settings,SizeOf(Settings),0);
Settings.cbSize:=SizeOf(Settings);
Settings.iRAWColors:=0;
Settings.iBlack_Level:=-1;
End;


{
{ Main functions from the DLL that we use to get the info or image or thumbnail
{ These are the main functions that you will call in order to get the stuff you want.
}

type
 TFromRawToPSD = function(FilePtrs:PRAWFilePointers;
                      PExifPointer:PExifRecord;
                      PEssentials:PExifEssentials;
                      ProgressInfo:PProgress;
                      filename:pchar;
                      ofilename:pchar;
                      Var Settings:TRAWSettings;
                      Var ScanLines:ALines;
                      Var IWidth:LongInt;
                      Var IHeight:LongInt;
                      iMake:PChar;iModel:PChar;
                      iTimeStamp:PChar;
                      oData_Error:PByte):Integer cdecl;
 TRAWInfo = function(FilePtrs:PRAWFilePointers;
                 PExifPointer:PExifRecord;
                 PEssentials:PExifEssentials;
                 filename:pchar;
                 IHalfSize:LongInt;
                 Var IWidth:LongInt;Var IHeight:LongInt;
                 iMake:PChar;iModel:PChar;
                 iTimeStamp:PChar;
                 oData_Error:PByte):Integer cdecl;
 TExtract_Thumbnail = function(FilePtrs:PRAWFilePointers;filename:pchar;
                 thumbfilename:pchar;var thumbnailtype:integer):integer cdecl;



{
function zFromRawToPSD(FilePtrs:PRAWFilePointers;
                      PExifPointer:PExifRecord;
                      PEssentials:PExifEssentials;
                      ProgressInfo:PProgress;
                      filename:pchar;
                      ofilename:pchar;
                      Var Settings:TRAWSettings;
                      Var ScanLines:ALines;
                      Var IWidth:LongInt;
                      Var IHeight:LongInt;
                      iMake:PChar;iModel:PChar;
                      iTimeStamp:PChar;
                      oData_Error:PByte):Integer cdecl; external PHOTOJOCKEYdll name 'FromRawToPSD';
function zRAWInfo(FilePtrs:PRAWFilePointers;
                 PExifPointer:PExifRecord;
                 PEssentials:PExifEssentials;
                 filename:pchar;
                 IHalfSize:LongInt;
                 Var IWidth:LongInt;Var IHeight:LongInt;
                 iMake:PChar;iModel:PChar;
                 iTimeStamp:PChar;
                 oData_Error:PByte):Integer cdecl; external PHOTOJOCKEYdll name 'RawInfo';
function zExtract_Thumbnail(FilePtrs:PRAWFilePointers;filename:pchar;thumbfilename:pchar;var thumbnailtype:integer):integer cdecl; external PHOTOJOCKEYdll name 'ExtractThumbnail';
}
var
  aFromRawToPSD : TFromRawToPSD;
  aRAWInfo : TRAWInfo;
  aExtract_Thumbnail : TExtract_Thumbnail;
  aRAWModuleHandle : THandle;

Function FixEmptyName(FileName,FixFileName:PChar):PChar;
Begin
If (FileName=Nil) Or (StrLen(FileName)=0) Then
   Begin
   StrCopy(FixFileName,'*:\***.***');
   Result:=FixFileName;
   End
Else
   Begin
   Result:=FileName;
   End;
End;

function FromRawToPSD(FilePtrs:PRAWFilePointers;
                      PExifPointer:PExifRecord;
                      PEssentials:PExifEssentials;
                      ProgressInfo:PProgress;
                      Filename:PChar;
                      OutFilename:pchar;
                      Var Settings:TRAWSettings;
                      Var ScanLines:ALines;
                      Var IWidth:LongInt;
                      Var IHeight:LongInt;
                      iMake:PChar;iModel:PChar;
                      iTimeStamp:PChar
                      ):Integer;
Var
  OldStatus:Integer;
  FixFileName:Array [0..MAX_PATH] Of Char;
  UseFileName:PChar;
  OData_Error:Byte;
Begin
// 0=Hunky Dory
// -1=File is corrupted somehow
// 1=Output File couldn't be created
// 2=Input file not found
// 3=Input file NOT A VALID RAW format
// 4=I/O Pointers invalid probably didn't setup parameters correctly
// 5=Some memory allocation problem
// 6=NO VALID THUMBNAIL FOUND
// 7=Exception found, basically loading of file was aborted!
OldStatus:= Default8087CW;
Set8087CW(Default8087CW or C_FPU_MASK);
FixEmptyName(FileName,FixFileName);
OData_Error:=0;
GetMem(UseFileName,255);
Result:=aFromRawToPSD(FilePtrs,PExifPointer,PEssentials,ProgressInfo,UseFileName,OutFileName,Settings,ScanLines,iWidth,iHeight,IMake,IModel,ITimeStamp,@OData_Error);
FreeMem(UseFileName);
_FPUInit;
Set8087CW(OldStatus);
If IoResult<>0 Then;
If OData_Error<>0 Then
   Result:=-1;
{
The return values of
    iMake, iModel, iTimeStamp,iWidth, iHeight are easy to figure out
    PExifPointer contains the location within the file where the EXIF DATA is kept
         ExifStart   = the offest into the file
         ExifLength  = the length of the EXIF data
    Essentials - contains basic info that you would like such as
       ISO, Shutter Speed, Aperture etc.... If any of these values are NOT -1 then the
                                            value is correct.
}
End;

function FromRawToPSDW(_FromRawToPSD : TFromRawToPSD;
                      FilePtrs:PRAWFilePointers;
                      PExifPointer:PExifRecord;
                      PEssentials:PExifEssentials;
                      ProgressInfo:PProgress;
                      Filename:PChar;
                      OutFilename:pchar;
                      Var Settings:TRAWSettings;
                      Var ScanLines:ALines;
                      Var IWidth:LongInt;
                      Var IHeight:LongInt;
                      iMake:PChar;iModel:PChar;
                      iTimeStamp:PChar
                      ):Integer;
Var
  OldStatus:Integer;
  FixFileName:Array [0..MAX_PATH] Of Char;
  UseFileName:PChar;
  OData_Error:Byte;
Begin
// 0=Hunky Dory
// -1=File is corrupted somehow
// 1=Output File couldn't be created
// 2=Input file not found
// 3=Input file NOT A VALID RAW format
// 4=I/O Pointers invalid probably didn't setup parameters correctly
// 5=Some memory allocation problem
// 6=NO VALID THUMBNAIL FOUND
// 7=Exception found, basically loading of file was aborted!
OldStatus:= Default8087CW;
Set8087CW(Default8087CW or C_FPU_MASK);
FixEmptyName(FileName,FixFileName);
OData_Error:=0;
GetMem(UseFileName,255);
Result:=_FromRawToPSD(FilePtrs,PExifPointer,PEssentials,ProgressInfo,UseFileName,OutFileName,Settings,ScanLines,iWidth,iHeight,IMake,IModel,ITimeStamp,@OData_Error);
FreeMem(UseFileName);
_FPUInit;
Set8087CW(OldStatus);
If IoResult<>0 Then;
If OData_Error<>0 Then
   Result:=-1;
{
The return values of
    iMake, iModel, iTimeStamp,iWidth, iHeight are easy to figure out
    PExifPointer contains the location within the file where the EXIF DATA is kept
         ExifStart   = the offest into the file
         ExifLength  = the length of the EXIF data
    Essentials - contains basic info that you would like such as
       ISO, Shutter Speed, Aperture etc.... If any of these values are NOT -1 then the
                                            value is correct.
}
End;

function RAWInfo(FilePtrs:PRAWFilePointers;
                 PExifPointer:PExifRecord;
                 PEssentials:PExifEssentials;
                 filename:pchar;
                 IHalfSize:LongInt;
                 Var IWidth:LongInt;Var IHeight:LongInt;
                 iMake:PChar;iModel:PChar;
                 iTimeStamp:PChar):Integer;
Var
  OldStatus:Integer;
  FixFileName:Array [0..MAX_PATH] Of Char;
  UseFileName:PChar;
  OData_Error:Byte;
Begin
// 0=Hunky Dory
// -1=File is corrupted somehow
// 1=Output File couldn't be created
// 2=Input file not found
OldStatus:= Default8087CW;
Set8087CW(Default8087CW or C_FPU_MASK);
UseFileName:=FixEmptyName(FileName,FixFileName);
OData_Error:=0;
try
Result:=aRawInfo(FilePtrs,PExifPointer,PEssentials,UseFileName,IHalfSize,IWidth,IHeight,iMake,iModel,iTimeStamp,@OData_Error);
except
end;
_FPUInit;
Set8087CW(OldStatus);
If IoResult<>0 Then;
If OData_Error<>0 Then
   Result:=-1;
{
The return values of
    iMake, iModel, iTimeStamp,iWidth, iHeight are easy to figure out
    PExifPointer - contains the location within the file where the EXIF DATA is kept
         ExifStart   = the offest into the file
         ExifLength  = the length of the EXIF data
    Essentials - contains basic info that you would like such as
       ISO, Shutter Speed, Aperture etc.... If any of these values are NOT -1 then the
                                            value is correct.
}
End;

function RAWInfoW(_RawInfo : TRawInfo; FilePtrs:PRAWFilePointers;
                 PExifPointer:PExifRecord;
                 PEssentials:PExifEssentials;
                 filename:pchar;
                 IHalfSize:LongInt;
                 Var IWidth:LongInt;Var IHeight:LongInt;
                 iMake:PChar;iModel:PChar;
                 iTimeStamp:PChar):Integer;
Var
  OldStatus:Integer;
  FixFileName:Array [0..MAX_PATH] Of Char;
  UseFileName:PChar;
  OData_Error:Byte;
Begin
// 0=Hunky Dory
// -1=File is corrupted somehow
// 1=Output File couldn't be created
// 2=Input file not found
OldStatus:= Default8087CW;
Set8087CW(Default8087CW or C_FPU_MASK);
UseFileName:=FixEmptyName(FileName,FixFileName);
OData_Error:=0;
try
Result:=_RawInfo(FilePtrs,PExifPointer,PEssentials,UseFileName,IHalfSize,IWidth,IHeight,iMake,iModel,iTimeStamp,@OData_Error);
except
end;
_FPUInit;
Set8087CW(OldStatus);
If IoResult<>0 Then;
If OData_Error<>0 Then
   Result:=-1;
{
The return values of
    iMake, iModel, iTimeStamp,iWidth, iHeight are easy to figure out
    PExifPointer - contains the location within the file where the EXIF DATA is kept
         ExifStart   = the offest into the file
         ExifLength  = the length of the EXIF data
    Essentials - contains basic info that you would like such as
       ISO, Shutter Speed, Aperture etc.... If any of these values are NOT -1 then the
                                            value is correct.
}
End;

function Extract_Thumbnail(Self:TObject;FilePtrs:PRAWFilePointers;filename:pchar;thumbfilename:pchar;var thumbnailtype:integer):integer;
Var
  OldStatus:Integer;
  FixFileName:Array [0..MAX_PATH] Of Char;
  UseFileName:PChar;
  Progress:TProgress;
  Settings:TRawSettings;
  ExifRecord:TExifRecord;
  Essentials:TExifEssentials;
  Make:Array[0..1000] Of Char;
  IMake,IModel,ITimeStamp:Pointer;
  NoNeed:Integer;
  ScanLines:ALines;
  OData_Error:Byte;
Begin
// 0=Thumbnail not found
// -1=File is corrupted somehow
// 1=Thumbnail made
// 2=Source file error probably doesn't exist
// 3=Dest file error probably path doesn't exist
// 4=I/O Pointers invalid probably didn't setup parameters correctly
// 5=Some memory allocation problems
OldStatus:= Default8087CW;
Set8087CW(Default8087CW or C_FPU_MASK);
UseFileName:=FixEmptyName(FileName,FixFileName);

raw_exif_init(ExifRecord);
raw_progress_init(Progress,Self);
Progress.Context:=Self;
raw_settings_init(Settings);
IMake:=@Make;
IModel:=@Make;
ITimeStamp:=@Make;
Settings.igetthumbnail:=1;
OData_Error:=0;
Result:=aFromRawToPSD(FilePtrs,@ExifRecord,@Essentials,@Progress,UseFileName,Thumbfilename,Settings,ScanLines,NoNeed,NoNeed,IMake,IModel,ITimeStamp,@OData_Error);
If NOT(Settings.othumbnail_type In [RAW_THUMB_JPG,RAW_THUMB_PPM,RAW_THUMB_TIFF]) Then
   Begin
   Result:=0;
{ Don't need anymore becasue the above FromRawToPSD with the iGetThumbNail=1 gets thumbnails now
{ It didn't use to have that option
   Result:=zExtract_Thumbnail(FilePtrs,UseFileName,ThumbFileName,ThumbNailType);
}
   End
Else
   Begin
   ThumbnailType:=Settings.OThumbnail_Type;
   Result:=1;
   End;
_FPUInit;
Set8087CW(OldStatus);
If IoResult<>0 Then;
If OData_Error<>0 Then
   Result:=-1;
End;

function Extract_ThumbnailW(_FromRawToPSD : TFromRawToPSD; Self:TObject;FilePtrs:PRAWFilePointers;filename:pchar;thumbfilename:pchar;var thumbnailtype:integer):integer;
Var
  OldStatus:Integer;
  FixFileName:Array [0..MAX_PATH] Of Char;
  UseFileName:PChar;
  Progress:TProgress;
  Settings:TRawSettings;
  ExifRecord:TExifRecord;
  Essentials:TExifEssentials;
  Make:Array[0..1000] Of Char;
  IMake,IModel,ITimeStamp:Pointer;
  NoNeed:Integer;
  ScanLines:ALines;
  OData_Error:Byte;
Begin
// 0=Thumbnail not found
// -1=File is corrupted somehow
// 1=Thumbnail made
// 2=Source file error probably doesn't exist
// 3=Dest file error probably path doesn't exist
// 4=I/O Pointers invalid probably didn't setup parameters correctly
// 5=Some memory allocation problems
OldStatus:= Default8087CW;
Set8087CW(Default8087CW or C_FPU_MASK);
UseFileName:=FixEmptyName(FileName,FixFileName);

raw_exif_init(ExifRecord);
raw_progress_init(Progress,Self);
Progress.Context:=Self;
raw_settings_init(Settings);
IMake:=@Make;
IModel:=@Make;
ITimeStamp:=@Make;
Settings.igetthumbnail:=1;
OData_Error:=0;
try
Result:=_FromRawToPSD(FilePtrs,@ExifRecord,@Essentials,@Progress,UseFileName,Thumbfilename,Settings,ScanLines,NoNeed,NoNeed,IMake,IModel,ITimeStamp,@OData_Error);
except
 OData_Error:=1;
end;
If NOT(Settings.othumbnail_type In [RAW_THUMB_JPG,RAW_THUMB_PPM,RAW_THUMB_TIFF]) Then
   Begin
   Result:=0;
{ Don't need anymore becasue the above FromRawToPSD with the iGetThumbNail=1 gets thumbnails now
{ It didn't use to have that option
   Result:=zExtract_Thumbnail(FilePtrs,UseFileName,ThumbFileName,ThumbNailType);
}
   End
Else
   Begin
   ThumbnailType:=Settings.OThumbnail_Type;
   Result:=1;
   End;
_FPUInit;
Set8087CW(OldStatus);
If IoResult<>0 Then;
If OData_Error<>0 Then
   Result:=-1;
End;
