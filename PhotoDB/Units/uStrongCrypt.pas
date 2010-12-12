unit uStrongCrypt;

interface

uses
  Classes,
  Windows,
  SysUtils,
  TypInfo,
  CPU,
  CRC,
  DECUtil,
  DECFmt,
  DECHash,
  DECCipher,
  DECRandom,
  Consts;

procedure CryptStreamV2(Source, Dest : TStream; Password : string; Seed: Binary;
                        ACipher: TDECCipherClass = nil; AMode: TCipherMode = cmCTSx;
                        AHash: TDECHashClass = nil);
procedure DeCryptStreamV2(Source, Dest : TStream; Password : string; Seed: Binary;
                        DataSize : Int64;
                        ACipher: TDECCipherClass; AMode: TCipherMode = cmCTSx;
                        AHash: TDECHashClass = nil);
procedure StrongCryptInit;

implementation

var
  StrongCryptInitFinished : Boolean = False;

procedure StrongCryptInit;
begin
  if StrongCryptInitFinished then
    Exit;

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

procedure CryptStreamV2(Source, Dest : TStream; Password : string; Seed: Binary;
                        ACipher: TDECCipherClass = nil; AMode: TCipherMode = cmCTSx;
                        AHash: TDECHashClass = nil);
var
  APassword : AnsiString;
  Bytes : TBytes;
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
    EncodeStream(Source, Dest, Source.Size);
  finally
    Free;
  end;
end;

procedure DeCryptStreamV2(Source, Dest : TStream; Password : string; Seed: Binary;
                        DataSize : Int64;
                        ACipher: TDECCipherClass; AMode: TCipherMode = cmCTSx;
                        AHash: TDECHashClass = nil);
var
  APassword : AnsiString;
  Bytes : TBytes;
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

initialization

  SetDefaultCipherClass(TCipher_Blowfish);
  SetDefaultHashClass(THash_SHA1);

end.
