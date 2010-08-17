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

implementation


  procedure EncodeFile(const AFileName: String; const APassword: Binary;
                       ACipher: TDECCipherClass = nil; AMode: TCipherMode = cmCTSx;
                       AHash: TDECHashClass = nil);
  // Die Datei wird verschlüsselt danach überschrieben und gelöscht.
  // Die verschlüsselte Datei wurde mit einem Session Passwort verschlüsselt das mit Hilfe
  // einer KDF = Key Derivation Funktion und einem Zufallswert erzeugt wurde.
  // Der Zufallswert == Seed ist 128 Bits groß und wird in der verschlüsselten Datei gespeichert.
  // Dieser stellt sicher das es unmöglich wird das Passwort zu knacken und randomisiert zusätzlich
  // die Daten der Vershlüsselung. Am Ende der verschlüsselten Datei wird eine Prüfsumme gespeichert
  // mit Hilfe einer CMAC = Cipher Message Authentication Code.
  // Die verschlüsselte Datei enthält am Anfang zusätzlich noch Informationen zum
  // verwendeten Cipher-/Hash Algorithmus, CipherMode usw. Dies ermöglicht bei der Entschlüsselung der
  // Datei die automatische Auswahl der Algorithmen.
  // Werden für Cipher und oder Hash == nil übergeben so wird der Standard Cipher/Hash benutzt.
  // Das benutze Session Passwort hat immer Zufällige Eigenschaften, es verhält sich wie Zufallsdaten.
  // Nur derjenige der den Zufalls-Seed und APassword kennt kann die Daten korrekt entschlüsseln.
  var
    Dest: TStream;

    procedure Write(const Value; Size: Integer);
    begin
      Dest.WriteBuffer(Value, Size);
    end;

    procedure WriteByte(Value: Byte);
    begin
      Write(Value, SizeOf(Value));
    end;

    procedure WriteLong(Value: LongWord);
    begin
      Value := SwapLong(Value);
      Write(Value, SizeOf(Value));
    end;

    procedure WriteBinary(const Value: Binary);
    begin
      WriteByte(Length(Value));
      Write(Value[1], Length(Value));
    end;

  var
    Source: TStream;
    Seed: Binary;
  begin
    ACipher := ValidCipher(ACipher);
    AHash := ValidHash(AHash);

    Seed := RandomBinary(16);

    Source := TFileStream.Create(AFileName, fmOpenReadWrite);
    try
      Dest := TFileStream.Create(AFileName + '.enc', fmCreate);
      try
        with ACipher.Create do
        try
          Mode := AMode;
          Init(AHash.KDFx(APassword, Seed, Context.KeySize));

          WriteLong(Identity);
          WriteByte(Byte(Mode));
          WriteLong(AHash.Identity);
          WriteBinary(Seed);
          WriteLong(Source.Size);
          EncodeStream(Source, Dest, Source.Size);
          WriteBinary(CalcMAC);
        finally
          Free;
        end;
      finally
        Dest.Free;
      end;
      ProtectStream(Source);
    finally
      Source.Free;
    end;
    DeleteFile(AFileName);
  end;

  procedure DecodeFile(const AFileName: String; const APassword: Binary);
  // entschüssele eine Datei die vorher mit EncodeFile() verschlüsselt wurde.
  var
    Source: TStream;

    procedure Read(var Value; Size: Integer);
    begin
      Source.ReadBuffer(Value, Size);
    end;

    function ReadByte: Byte;
    begin
      Read(Result, SizeOf(Result));
    end;

    function ReadLong: LongWord;
    begin
      Read(Result, SizeOf(Result));
      Result := SwapLong(Result);
    end;

    function ReadBinary: Binary;
    begin
      SetLength(Result, ReadByte);
      Read(Result[1], Length(Result));
    end;

  var
    Dest: TStream;
  begin
    Source := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
    try
      try
        Dest := TFileStream.Create(ChangeFileExt(AFileName, ''), fmCreate);
        try
          try
            with CipherByIdentity(ReadLong).Create do
            try
              Mode := TCipherMode(ReadByte);
              Init(HashByIdentity(ReadLong).KDFx(APassword, ReadBinary, Context.KeySize));
              DecodeStream(Source, Dest, ReadLong);
              if ReadBinary <> CalcMAC then
                raise EDECException.Create('Invalid decryption');
            finally
              Free;
            end;
          except
            ProtectStream(Dest);
            raise;
          end;
        finally
          Dest.Free;
        end;
      except
        DeleteFile(ChangeFileExt(AFileName, ''));
        raise;
      end;
    finally
      Source.Free;
    end;
  end;

{
begin
  RandomSeed; // randomize DEC's own RNG
  AssignFile(Output, ChangeFileExt(ParamStr(0), '.txt'));
  try

    WriteLn(#13#10'File En/Decryption test');

  // stelle Standard Cipher/Hash ein.
    SetDefaultCipherClass(TCipher_Blowfish);
    SetDefaultHashClass(THash_SHA1);
  // Stelle die Basis-Identität der Cipher/Hash Algorithmen auf einen Anwendungsspezifischen Wert ein.
  // Damit ist sichergestellt das nur Dateien die mit dieser Anwendung verschlüsselt wurden auch wieder
  // entschlüselbar sind. Dei Verschlüsselungsfunktion oben speichert ja die Identity des benutzen
  // Ciphers/Hashs in der verschlüsselten Datei ab. Beim Entschlüsseln mit DecodeFile() werden diese
  // Identities geladen und aus den Regstrierten DECClassen geladen.
    IdentityBase := $84485225;
  // alle benutzten und ladbaren Cipher/Hash müssen registriert werden.
    RegisterDECClasses([TCipher_Blowfish, THash_SHA1]);
  // obige Sourcezeilen sollten normalerweise im Startup der Anwendung erfolgen.

    FileName := ChangeFileExt(ParamStr(0), '.test');
    EncodeFile(FileName, 'Password');
    DecodeFile(FileName + '.enc', 'Password');

  except
    on E: Exception do WriteLn(E.Message);
  end;
//  Wait;
end.
}

end.
