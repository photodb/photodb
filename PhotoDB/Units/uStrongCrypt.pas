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

implementation

procedure CryptStreamV2(Source, Dest : TStream; Password : string; Seed: Binary;
                        ACipher: TDECCipherClass = nil; AMode: TCipherMode = cmCTSx;
                        AHash: TDECHashClass = nil);
begin
  ACipher := ValidCipher(ACipher);
  AHash := ValidHash(AHash);

  with ACipher.Create do
  try
    Mode := CmCTSx;
    Init(AHash.KDFx(Password, Seed, Context.KeySize));
    EncodeStream(Source, Dest, Source.Size);
  finally
    Free;
  end;
end;

procedure DeCryptStreamV2(Source, Dest : TStream; Password : string; Seed: Binary;
                        DataSize : Int64;
                        ACipher: TDECCipherClass; AMode: TCipherMode = cmCTSx;
                        AHash: TDECHashClass = nil);
begin
  ACipher := ValidCipher(ACipher);
  AHash := ValidHash(AHash);

  with ACipher.Create do
  try
    Mode := CmCTSx;
    Init(AHash.KDFx(Password, Seed, Context.KeySize));
    DecodeStream(Source, Dest, DataSize);
  finally
    Free;
  end;
end;

initialization

    SetDefaultCipherClass(TCipher_Blowfish);
    SetDefaultHashClass(THash_SHA1);

end.
