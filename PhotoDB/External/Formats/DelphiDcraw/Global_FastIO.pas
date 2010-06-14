unit Global_FastIO;

interface

Uses
  Windows,Graphics,Dialogs,Forms,SysUtils,Messages, ExtCtrls,
  Menus, Classes, StdCtrls, ComCtrls, Buttons, Controls,
  GlobalTypes
  ;

Const
   Const4096=16*1024;

Type
  TFastFileIO = class(TPersistent)
  private
    { Private declarations }
    Procedure FileGetMore;
  Protected
    {Variables go here}
    PictureFile:File;
  public
    { Availalble methods}
    IndexData:Array[0..Const4096-1] Of Byte;
    FError:Boolean;
    IndexLeft:Integer;
    IndexMain:Word;
    (*
    constructor Create; override;
    Destructor Destroy; override;
    *)
    Procedure OpenFile(Var FileName:String;Var FileOk:Boolean);
    Procedure FastGetBytes(Var Ptr1;NumBytes:Word);
    Function  FastGetByte:Byte;
    Function  FastGetWord:Word;
    Function  FastGetLong:LongInt;
    Procedure FileIoReset;
    Procedure CloseFile;
    Function  FastFilePos:Int64;
    Function  FastFilePos_Real:Int64;
    Function  SizeOfIndexData:LongInt;
    Function  GetIndex1:LongInt;
    Procedure FastSeek(SeekTo:Int64);
    Function  FastGetFileSize:Int64;
  end;




Const
   fio_Const4096=4*1024;
   fmReadTextFileOnly=$8000;
   fmCreateFileNow   =$4000;

Type
  TFastFile = class(TPersistent)
  private
    { Private declarations }
    Procedure FileGetMore;

  Protected
    {Variables go here}
    FPictureFile:File;
    FNumRead:DWORD;
    FInitMem:Boolean;
    FUseMem:Boolean;
    FStreamNoClose:Boolean;
    FFileName:String;
    FFileMode:Integer;
    FOpened:Boolean;
    FReadTextFileOnly:Boolean;
    FCreateFileNow:Boolean;
    FFileSize:Int64;
    IndexLeft:Integer;
    IndexMain:Word;
    IndexData:Array[0..fio_Const4096-1] Of Byte;
    OutBuff:Array[0..1023] Of Byte;
    OutBuffIndex:Integer;
    FFileNo:Integer;

    Procedure FileIoReset;
    Function  FastFilePos:Int64;
    Function  GetPosition:Int64;
    Procedure SetPosition(Val:Int64);
    Procedure SetRealPosition(Val:Int64);
    Procedure OpenFast(Var FError:Integer);
    Procedure FlushOutput;
    Function  FlushOutBuff(Var Ptr;NumBytes:Integer):Integer;
  public
    { Availalble methods}
    FError:Integer;
    FStream:TStream;

    Procedure OpenFile(Var FileName:String;fmMode:Integer;Var FError:Integer);
    Procedure SetStream(Const Stream:TStream);
    Procedure CloseFile(Force:Boolean);
    constructor Create(FileName:String;fmMode:Integer;Var FError:Integer);
    Destructor Destroy; override;
    Function  Seek(SeekTo:Int64;origin:Integer):Int64;
    Function  Size:Int64;
    Function  BufferSize:LongInt;
    Function  GetEOF:Boolean;

    Function  Write(Var Ptr1;NumBytes:Integer):Integer;
    Function  Read(Var Ptr1;NumBytes:Integer):Integer;
    Function  GetBytes(Var Ptr1;NumBytes:Integer):Integer;
    Function  GetByte:Byte;
    Function  GetWord:Word;
    Function  GetLong:LongInt;
    Function  GetChar:Char;

    Function  IoResult:Integer;
    Procedure Reset;
    Property  EOF:Boolean read GetEOF;
    Property  Position:Int64 read GetPosition write SetPosition;
    Property  RealPosition:Int64 write SetRealPosition;
    Property  FileName:String read FFileName write FFileName;
    Property  FileNo:Integer read FFileNo;

  end;



Implementation
{$I-}
Function TFastFileIO.FastGetFileSize:Int64;
Begin
Result:=FileSize(PictureFile);
If IoResult<>0 Then;
End;

Procedure TFastFileIO.FastSeek(SeekTo:Int64);
Begin
FError:=False;
Seek(PictureFile,SeekTo);
If IoResult<>0 Then
   FError:=True;
End;

Function  TFastFileIO.GetIndex1:LongInt;
Begin
Result:=IndexLeft;
End;

Function  TFastFileIO.SizeOfIndexData:LongInt;
Begin
Result:=SizeOf(IndexData);
If IoResult<>0 Then;
End;

Procedure TFastFileIO.CloseFile;
Begin
Close(PictureFile);
If IoResult<>0 Then;
End;

Function TFastFileIO.FastFilePos:Int64;
Begin
Result:=FilePos(PictureFile);
If IoResult<>0 Then;
End;

Function TFastFileIO.FastFilePos_Real:Int64;
Begin
Result:=FastFilePos-IndexLeft;
If IoResult<>0 Then;
End;

Procedure TFastFileIO.FileGetMore;
Var
  NumRead:Integer;
Begin
FillChar(IndexData,Const4096,0);
BlockRead(PictureFile,IndexData,Const4096,NumRead);
IndexLeft:=NumRead;
IndexMain:=0;
If IoResult<>0 Then;
If NumRead=0 Then
   FError:=True;
End;

Procedure TFastFileIO.FastGetBytes(Var Ptr1;NumBytes:Word);
Var
  X:Integer;
Begin
{
{ If we have enough the block it!
{ Otherwise do one at a time!
}
If IndexLeft<NumBytes Then
   Begin
   If IndexLeft=0 Then
      Begin
      FileGetMore;
      End;
   For X:=0 To NumBytes-1 Do
       Begin
       DataLineArray(Ptr1)[X]:=IndexData[IndexMain];
       Inc(IndexMain);
       Dec(IndexLeft);
       If IndexLeft=0 Then
          FileGetMore;
       End;
   End
Else
   Begin
   {
   { Block it fast!
   }
   Move(IndexData[IndexMain],DataLineArray(Ptr1)[0],NumBytes);
   Inc(IndexMain,Numbytes);
   Dec(IndexLeft,NumBytes);
   End;
End;

Function TFastFileIO.FastGetByte:Byte;
Begin
If IndexLeft=0 Then
   Begin
   FileGetMore;
   End;
FastGetByte:=IndexData[IndexMain];
Inc(IndexMain);
Dec(IndexLeft);
End;

Function TFastFileIO.FastGetWord:Word;
Begin
FastGetWord:=Word(FastGetByte)+Word(FastGetByte)*256;
End;

Function  TFastFileIO.FastGetLong:LongInt;
Begin
FastGetLong:=LongInt(FastGetWord)+LongInt(FastGetWord)*65536;
End;

Procedure TFastFileIO.FileIoReset;
Begin
IndexLeft:=0;
IndexMain:=0;
End;

Procedure TFastFileIO.OpenFile(Var FileName:String;Var FileOk:Boolean);
Var
  Io:Integer;
  OldFileMode:Word;
Begin
FileIoReset;
If IoResult<>0 Then;
OldFileMode:=FileMode;
FileMode:=0;
AssignFile(PictureFile,FileName);
ReSet(PictureFile,1);
Io:=IoResult;
If Io<>0 Then
   Begin
   FileOk:=False;
   End;
FileMode:=OldFileMode;
FError:=False;
End;









{****************************************************************
{ This is a more generic file io system with buffing
****************************************************************}
Var
  FileNoVar:Integer;
Constructor TFastFile.Create(FileName:String;fmMode:Integer;Var FError:Integer);
Begin
FOpened:=False;
FInitMem:=False;
FStream:=Nil;
FStreamNoClose:=False;
FFileNo:=0;
IndexLeft:=0;
IndexMain:=0;
OutBuffIndex:=0;
OpenFile(FileName,fmMode,FError);
End;

Destructor TFastFile.Destroy;
Begin
CloseFile(True);
If System.IoResult<>0 Then;
Inherited;
End;

Function TFastFile.GetEOF:Boolean;
Var
  FSize:Int64;
Begin
Result:=False;
If FReadTextFileOnly Then
   Begin
   Result:=FError<>0;
   Exit;
   End;
If (FFileMode And $0F)=fmOpenRead Then
   FSize:=FFileSize
Else
   FSize:=-1;
If FUseMem Then
   Begin
   If FSize=-1 Then
      FSize:=FStream.Size;
   If FStream.Position>=FSize Then
      Result:=True;
   End
Else
   Begin
   If FSize=-1 Then
      FSize:=FileSize(FPictureFile);
   If IoResult<>0 Then;
   If GetPosition>=FSize Then
      Result:=True;
   If IoResult<>0 Then;
   End;
End;

Function TFastFile.Size:Int64;
Begin
If FUseMem Then
   Begin
   Result:=FStream.Size;
   End
Else
   Begin
   Result:=FileSize(FPictureFile);
   If IoResult<>0 Then;
   End;
End;

Const
 f_SEEK_SET=0;
 f_SEEK_CUR=1;
 f_SEEK_END=2;

Function TFastFile.Seek(SeekTo:Int64;origin:Integer):Int64;
Var
  CurrFilePos:Int64;
Procedure RawSeek(Var SeekTo:Int64);
Begin
FlushOutput;
If System.IoResult<>0 Then;
If SeekTo<0 Then SeekTo:=0;
If FUseMem Then
   FStream.Position:=SeekTo
Else
   System.Seek(FPictureFile,SeekTo);
FError:=System.IoResult;
{
{ Force a read
}
IndexLeft:=0;
IndexMain:=0;
End;
Begin
   Begin
   {
   origin of
   SEEK_SET = From begining of file
   SEEK_CUR = From the current position
   SEEK_END = From END of the file
   }
   Case Origin Of
     f_SEEK_SET:Begin
                SeekTo:=SeekTo;
                End;
     f_SEEK_CUR:Begin
                SeekTo:=Position+SeekTo;
                End;
     f_SEEK_END:Begin
                SeekTo:=Size+SeekTo;
                End;
     End;
   {
   { Let's be intelligent about the seek
   }
   CurrFilePos:=FastFilePos;
   If SeekTo>=CurrFilePos Then
      Begin
      {Start over}
      RawSeek(SeekTo);
      End
   Else
      Begin
      If (SeekTo>=CurrFilePos-FNumRead)
          And
         ((IndexLeft<>0) Or (IndexMain<>0))
         Then
         Begin
         {DO NOT READ}
         {
         { FastFilePos=800
         { FNumRead=100
         { SeekTo=701
         }
         FError:=0;
         IndexMain:=SeekTo-(CurrFilePos-FNumRead);
         IndexLeft:=FNumRead-IndexMain;
         End
      Else
         Begin
         {Start Over}
         RawSeek(SeekTo);
         End;
      End;
   Result:=SeekTo;
   End;
End;

Procedure TFastFile.SetStream(Const Stream:TStream);
Begin
If FStream<>Nil Then
   Begin
   FStream.Free;
   End;
FStream:=Stream;
FStreamNoClose:=True;
FUseMem:=True;
FStream.Position:=0;
FileIoReset;
End;

Procedure TFastFile.OpenFast(Var FError:Integer);
Var
  OldFileMode:Word;
Begin
If FOpened Then CloseFile(True);
FileIoReset;
If System.IoResult<>0 Then;
If FFileName='' Then
   FUseMem:=True
Else
   FUseMem:=False;
If FUseMem=False Then
   Begin
   OldFileMode:=FileMode;
   FileMode:=FFileMode;
   AssignFile(FPictureFile,FFileName);
   If FCreateFileNow Then
      System.ReWRite(FPictureFile,1)
   Else
      System.ReSet(FPictureFile,1);
   FError:=System.IoResult;
   FFileSize:=FileSize(FPictureFile);
   If System.IoResult<>0 Then;
   FileMode:=OldFileMode;
   FOpened:=True;
   End
Else
   Begin
   FStream:=TMemoryStream.Create;
   FOpened:=True;
   End;
End;

Procedure TFastFile.OpenFile(Var FileName:String;fmMode:Integer;Var FError:Integer);
Begin
FFileName:=FileName;
FFileNo:=FileNoVar;
If FileNoVar=MAXINT Then
   FileNoVar:=10
Else
   Inc(FileNoVar);
FReadTextFileOnly:=False;
FCreateFileNow:=False;
If (fmMode And fmReadTextFileOnly)<>0 Then
   Begin
   fmMode:=(fmMode And $7FF0) Or fmOpenRead;
   FReadTextFileOnly:=True;
   End;
If (fmMode And fmCreateFileNow)<>0 Then
   Begin
   fmMode:=(fmMode And $BFFF);
   FCreateFileNow:=True;
   End;
FFileMode:=fmMode;
OpenFast(FError);
End;

Function  TFastFile.BufferSize:LongInt;
Begin
Result:=SizeOf(IndexData);
If System.IoResult<>0 Then;
End;

Procedure TFastFile.CloseFile(Force:Boolean);
Begin
FlushOutput;
If FUseMem Then
   Begin
   If FStream<>Nil Then
      Begin
      If (FStreamNoClose=False) Or Force Then
         FStream.Free;
      End;
   FStream:=Nil;
   End
Else
   Begin
   Close(FPictureFile);
   If System.IoResult<>0 Then;
   End;
FOpened:=False;
End;

Function TFastFile.FastFilePos:Int64;
Begin
If FUseMem Then
   Begin
   Result:=FStream.Position;
   End
Else
   Begin
   Result:=FilePos(FPictureFile);
   If System.IoResult<>0 then;
   End;
End;

Function TFastFile.GetPosition:Int64;
Var
  FFilePos:Int64;
Begin
{
If (FFileMode And $0F)=fmOpenRead Then
   FFilePos:=FFileSize;
}
FFilePos:=FastFilePos;
Result:=FFilePos-IndexLeft;
If System.IoResult<>0 Then;
End;

Procedure TFastFile.SetPosition(Val:Int64);
Begin
Seek(Val,soFromBeginning);
End;

Procedure TFastFile.SetRealPosition(Val:Int64);
Begin
FlushOutput;
If FUseMem Then
   Begin
   FStream.Position:=Val;
   FileIoReset;
   End
Else
   Begin
   System.Seek(FPictureFile,Val);
   FileIoReset;
   End;
End;

Procedure TFastFile.FileGetMore;
Begin
FlushOutput;
If FInitMem Then
   FillChar(IndexData,fio_Const4096,0);
If System.IoResult<>0 Then;
If FUseMem Then
   FNumRead:=FStream.Read(IndexData,fio_Const4096)
Else
   BlockRead(FPictureFile,IndexData,fio_Const4096,FNumRead);
IndexLeft:=FNumRead;
IndexMain:=0;
FError:=System.IoResult;
If FNumRead=0 Then
   FError:=-1;
End;

Procedure TFastFile.FlushOutput;
Begin
If OutBuffIndex>0 Then
   FlushOutBuff(OutBuff,OutBuffIndex);
End;

Function TFastFile.FlushOutBuff(Var Ptr;NumBytes:Integer):Integer;
Begin
If FUseMem Then
   Begin
   FStream.Position:=Position;
   Result:=FStream.Write(Ptr,NumBytes);
   End
Else
   Begin
   System.Seek(FPictureFile,Position);
   BlockWrite(FPictureFile,Ptr,NumBytes,Result);
   End;
If Result<>NumBytes Then
   FError:=-1;
IndexLeft:=0;
IndexMain:=0;
OutBuffIndex:=0;
End;

Function TFastFile.Write(Var Ptr1;NumBytes:Integer):Integer;
Var
  X:Integer;
  BytesOut:Integer;
Type
  Bytes1=Array[1..999999] Of Byte;
Begin
Result:=NumBytes;

For X:=1 To NumBytes Do
    Begin

    OutBuff[OutBuffIndex]:=Bytes1(Ptr1)[X];
    Inc(OutBuffIndex);
    If OutBuffIndex>=SizeOf(OutBuff) Then
       Begin
       BytesOut:=FlushOutBuff(OutBuff,SizeOf(OutBuff));
       If BytesOut<>SizeOf(OutBuff) Then
          Result:=0;
       End;
    End;

End;

Function TFastFile.Read(Var Ptr1;NumBytes:Integer):Integer;
Begin
Result:=GetBytes(Ptr1,NumBytes);
End;

Function TFastFile.GetBytes(Var Ptr1;NumBytes:Integer):Integer;
Type
   DataLineArray=Array[0..High(Integer)-1] Of Byte;
Var
  Count,Offset:Integer;
Begin
{
{ If we have enough the block it!
{ Otherwise do one at a time!
}
FlushOutput;
   Begin
   If IndexLeft<NumBytes Then
      Begin
      Offset:=0;
      Result:=0;
      Repeat
          Begin
          If IndexLeft=0 Then
             Begin
             FileGetMore;
             If FError<>0 Then
                Break;
             End;
          If IndexLeft<=0 Then
             Begin
             Result:=0;
             IndexMain:=0;
             End;
          If IndexLeft>=NumBytes Then
             Count:=NumBytes
          Else
             Count:=IndexLeft;
          {
          { Block it fast!
          }
          Move(IndexData[IndexMain],DataLineArray(Ptr1)[Offset],Count);
          Inc(IndexMain,Count);
          Dec(IndexLeft,Count);
          Dec(NumBytes,Count);
          Inc(Result,Count);
          Inc(Offset,Count);
          End;
      Until NumBytes<=0;
      End
   Else
      Begin
      {
      { Block it fast!
      }
      Result:=NumBytes;
      Move(IndexData[IndexMain],DataLineArray(Ptr1)[0],NumBytes);
      Inc(IndexMain,NumBytes);
      Dec(IndexLeft,NumBytes);
      End;
   End;
End;

Function TFastFile.GetByte:Byte;
Begin
FlushOutput;
   Begin
   If IndexLeft<=0 Then
      Begin
      FileGetMore;
      End;
   GetByte:=IndexData[IndexMain];
   Inc(IndexMain);
   Dec(IndexLeft);
   End;
End;

Function TFastFile.GetChar:Char;
Begin
FlushOutput;
   Begin
   If IndexLeft=0 Then
      Begin
      FileGetMore;
      End;
   GetChar:=Char(IndexData[IndexMain]);
   Inc(IndexMain);
   Dec(IndexLeft);
   End;
End;

Function TFastFile.GetWord:Word;
Begin
GetWord:=Word(GetByte)+Word(GetByte)*256;
End;

Function  TFastFile.GetLong:LongInt;
Begin
GetLong:=LongInt(GetWord)+LongInt(GetWord)*65536;
End;

Procedure TFastFile.FileIoReset;
Begin
FlushOutput;
IndexLeft:=0;
IndexMain:=0;
End;

Procedure TFastFile.Reset;
Var
  FError:Integer;
Begin
FlushOutput;
OpenFast(FError);
Position:=0;;
End;

Function TFastFile.IoResult:Integer;
Begin
Result:=FError;
End;

Initialization
FileNoVar:=10;
end.
