unit uStrongCrypt;

interface

uses
  Classes,
  Windows,
  SysUtils,
  TypInfo,
  DECUtil,
  DECFmt,
  DECHash,
  DECCipher,
  DECRandom,
  Vcl.Consts,
  Dmitry.Utils.System;

const
  PhotoDBFileHeaderID        = '.PHDBCRT';

  ENCRYPT_FILE_VERSION_BASIC       = 1;
  ENCRYPT_FILE_VERSION_STRONG      = 2;
  ENCRYPT_FILE_VERSION_TRANSPARENT = 3;

type
  TSeed = array[1..16] of AnsiChar;
  TFileNameUnicode = array[0..254] of WideChar;

type
  TEncryptedFileHeader = record
    IDSize: Byte;
    ID: array[0..7] of AnsiChar;
    Version: Byte;
    DBVersion: Byte;
  end;

  TMagicByte = array [0 .. 3] of Byte;
  TFileNameAnsi = array[0..254] of AnsiChar;
  TByteArray = array of Byte;

  TGraphicCryptFileHeaderV1 = record
    Version: Byte;
    Magic: Cardinal;
    FileSize: Cardinal;
    PassCRC: Cardinal;
    CRCFileExists: Boolean;
    CRCFile: Cardinal;
    TypeExtract: Byte;
    CryptFileName: Boolean;
    FileNameLength : Byte;
    CFileName: TFileNameAnsi;
    TypeFileNameExtract: Byte;
    FileNameCRC: Cardinal;
    Displacement: Cardinal;
  end;

  TGraphicCryptFileHeaderV2 = record
    Version: Byte;
    Seed: TSeed;
    FileSize: Int64;
    PassCRC: Cardinal;
    Algorith: Cardinal;
    CRCFileExists: Boolean;
    CRCFile: Cardinal;
    TypeExtract: Byte;
    CryptFileName: Boolean;
    FileNameLength: Byte;
    CFileName: TFileNameUnicode;
    TypeFileNameExtract: Byte;
    FileNameCRC: Cardinal;
    Displacement: Cardinal;
    Reserved: Cardinal;
    Reserved2: Cardinal;
  end;

const
  Encrypt32kBlockSize = 32 * 1024;

type
  TEncryptProgress = procedure(BytesTotal, BytesDone: Int64; var BreakOperation: Boolean) of object;
  TSimpleEncryptProgress = reference to procedure(BytesTotal, BytesDone: Int64; var BreakOperation: Boolean);

  TEncryptFileHeaderExV1 = record
    Version: Byte;
    Seed: TSeed;
    FileSize: Int64;
    PassCRC: Cardinal;
    Algorith: Cardinal;
    BlockSize32k: Byte;
    Displacement: Cardinal;
    ProgramVersion: TRelease;
    Reserved: Cardinal;
    Reserved2: Cardinal;
  end;

procedure CryptStreamV2(Source, Dest: TStream; Password: string; Seed: Binary;
                        ACipher: TDECCipherClass = nil; AMode: TCipherMode = cmCTSx;
                        AHash: TDECHashClass = nil; Size: Int64 = 0);
procedure DeCryptStreamV2(Source, Dest: TStream; Password: string; Seed: Binary;
                        DataSize: Int64;
                        ACipher: TDECCipherClass; AMode: TCipherMode = cmCTSx;
                        AHash: TDECHashClass = nil);
procedure StrongCryptInit;
function ConvertSeed(Seed: Binary): TSeed;
function SeedToBinary(Seed: TSeed): Binary;

implementation

var
  StrongCryptInitFinished: Boolean = False;

function ConvertSeed(Seed: Binary) : TSeed;
var
  I: Integer;
begin
  for I := 0 to Length(Seed) - 1 do
    Result[I + 1] := Seed[I + 1];
end;

function SeedToBinary(Seed: TSeed): Binary;
var
  I: Integer;
begin
  SetLength(Result, 16);
  for I := 0 to 16 - 1 do
    Result[I + 1] := Seed[I + 1];
end;

procedure StrongCryptInit;
begin
  if StrongCryptInitFinished then
    Exit;

  SetDefaultCipherClass(TCipher_Blowfish);
  SetDefaultHashClass(THash_SHA1);

  TCipher_Blowfish.Register;
  TCipher_Twofish.Register;
  TCipher_IDEA.Register;
  TCipher_CAST256.Register;
  TCipher_Mars.Register;
  TCipher_RC2.Register;
  TCipher_RC4.Register;
  TCipher_RC5.Register;
  TCipher_RC6.Register;
  TCipher_Rijndael.Register;
  TCipher_Square.Register;
  TCipher_SCOP.Register;
  TCipher_Sapphire.Register;
  TCipher_1DES.Register;
  TCipher_2DES.Register;
  TCipher_3DES.Register;
  TCipher_2DDES.Register;
  TCipher_3DDES.Register;
  TCipher_3TDES.Register;
  TCipher_3Way.Register;
  TCipher_Cast128.Register;
  TCipher_Gost.Register;
  TCipher_Misty.Register;
  TCipher_NewDES.Register;
  TCipher_Q128.Register;
  TCipher_SAFER.Register;
  TCipher_Shark.Register;
  TCipher_Skipjack.Register;
  TCipher_TEA.Register;
  TCipher_TEAN.Register;

  StrongCryptInitFinished := True;
end;

procedure CryptStreamV2(Source, Dest: TStream; Password: string; Seed: Binary;
                        ACipher: TDECCipherClass = nil; AMode: TCipherMode = cmCTSx;
                        AHash: TDECHashClass = nil; Size: Int64 = 0);
var
  APassword: AnsiString;
  Bytes: TBytes;
begin
  ACipher := ValidCipher(ACipher);
  AHash := ValidHash(AHash);

  Bytes := TEncoding.UTF8.GetBytes(Password);
  SetLength(APassword, Length(Bytes));
  Move(Bytes[0], APassword[1], Length(Bytes));

  if Size = 0 then
    Size := Source.Size;

  with ACipher.Create do
  try
    Mode := CmCTSx;
    Init(AHash.KDFx(APassword, Seed, Context.KeySize));
    EncodeStream(Source, Dest, Size);
  finally
    Free;
  end;
end;

procedure DeCryptStreamV2(Source, Dest: TStream; Password: string; Seed: Binary;
                        DataSize: Int64;
                        ACipher: TDECCipherClass; AMode: TCipherMode = cmCTSx;
                        AHash: TDECHashClass = nil);
var
  APassword: AnsiString;
  Bytes: TBytes;
begin
  ACipher := ValidCipher(ACipher);
  AHash := ValidHash(AHash);

  Bytes := TEncoding.UTF8.GetBytes(Password);
  SetLength(APassword, Length(Bytes));
  Move(Bytes[0], APassword[1], Length(Bytes));

  with ACipher.Create do
  try
    Mode := CmCTSx;
    Init(AHash.KDFx(APassword, Seed, Context.KeySize));
    DecodeStream(Source, Dest, DataSize);
  finally
    Free;
  end;
end;

end.
