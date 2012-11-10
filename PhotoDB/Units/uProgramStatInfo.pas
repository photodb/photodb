unit uProgramStatInfo;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Math,
  uMemory,
  uSettings;

const
  cStatisticsRegistryKey = 'Stat';

type
  TProgramStatInfo = class(TObject)
  private
    procedure UpdateProperty(PropertyAlias: string);
  public
    procedure ProgramStarted; //S
    procedure ProgramStartedDefault; //D
    procedure ProgramStartedViewer; //V
    procedure ImportUsed; //I
    procedure ShareUsed; //SH
    procedure GeoInfoReadUsed; //GR
    procedure GeoInfoSaveUsed; //GW
    procedure EncryptionImageUsed; //EI
    procedure DecryptionImageUsed; //DI
    procedure EncryptionFileUsed; //EF
    procedure DecryptionFileUsed; //DF
    procedure StegoUsed; //ST
    procedure DeStegoUsed; //DST
    procedure SearchDatabaseUsed; //SD
    procedure SearchImagesUsed; //SI
    procedure SearchFilesUsed; //SF
    procedure EditorUsed; //E
    procedure PrinterUsed; //P
    procedure FaceDetectionUsed; //F
    procedure ConverterUsed; //C
    procedure ShelfUsed; //SHE
    procedure PropertiesUsed; //PRO
    procedure ActionsUsed; //ACT
    procedure Image3dUsed; //DD
    procedure StyleUsed; //STY
    procedure PersonUsed; //PO
    procedure GroupUsed; //GO
    procedure PortableUsed; //PV
    procedure DBUsed; //DB
    function ToString: string; override;
  end;

function ProgramStatistics: TProgramStatInfo;

implementation

var
  FProgramStatistics: TProgramStatInfo = nil;

function ProgramStatistics: TProgramStatInfo;
begin
  if FProgramStatistics = nil then
    FProgramStatistics := TProgramStatInfo.Create;

  Result := FProgramStatistics;
end;

{ TFeatureStatInfo }

procedure TProgramStatInfo.ActionsUsed;
begin
  UpdateProperty('ACT');
end;

procedure TProgramStatInfo.ConverterUsed;
begin
  UpdateProperty('C');
end;

procedure TProgramStatInfo.DBUsed;
begin
  UpdateProperty('DB');
end;

procedure TProgramStatInfo.DecryptionFileUsed;
begin
  UpdateProperty('DF');
end;

procedure TProgramStatInfo.DecryptionImageUsed;
begin
  UpdateProperty('DI');
end;

procedure TProgramStatInfo.DeStegoUsed;
begin
  UpdateProperty('DST');
end;

procedure TProgramStatInfo.EditorUsed;
begin
  UpdateProperty('E');
end;

procedure TProgramStatInfo.EncryptionFileUsed;
begin
  UpdateProperty('EF');
end;

procedure TProgramStatInfo.EncryptionImageUsed;
begin
  UpdateProperty('EI');
end;

procedure TProgramStatInfo.FaceDetectionUsed;
begin
  UpdateProperty('F');
end;

procedure TProgramStatInfo.GeoInfoReadUsed;
begin
  UpdateProperty('GR');
end;

procedure TProgramStatInfo.GeoInfoSaveUsed;
begin
  UpdateProperty('GW');
end;

procedure TProgramStatInfo.GroupUsed;
begin
  UpdateProperty('GO');
end;

procedure TProgramStatInfo.Image3dUsed;
begin
  UpdateProperty('DD');
end;

procedure TProgramStatInfo.ImportUsed;
begin
  UpdateProperty('I');
end;

procedure TProgramStatInfo.PersonUsed;
begin
  UpdateProperty('PO');
end;

procedure TProgramStatInfo.PortableUsed;
begin
  UpdateProperty('PV');
end;

procedure TProgramStatInfo.PrinterUsed;
begin
  UpdateProperty('P');
end;

procedure TProgramStatInfo.ProgramStarted;
begin
  UpdateProperty('S');
end;

procedure TProgramStatInfo.ProgramStartedDefault;
begin
  UpdateProperty('D');
end;

procedure TProgramStatInfo.ProgramStartedViewer;
begin
  UpdateProperty('V');
end;

procedure TProgramStatInfo.PropertiesUsed;
begin
  UpdateProperty('PRO');
end;

procedure TProgramStatInfo.SearchDatabaseUsed;
begin
  UpdateProperty('SD');
end;

procedure TProgramStatInfo.SearchFilesUsed;
begin
  UpdateProperty('SF');
end;

procedure TProgramStatInfo.SearchImagesUsed;
begin
  UpdateProperty('SI');
end;

procedure TProgramStatInfo.ShareUsed;
begin
  UpdateProperty('SH');
end;

procedure TProgramStatInfo.ShelfUsed;
begin
  UpdateProperty('SHE');
end;

procedure TProgramStatInfo.StegoUsed;
begin
  UpdateProperty('ST');
end;

procedure TProgramStatInfo.StyleUsed;
begin
  UpdateProperty('STY');
end;

function ProcessCount(I: Integer): Integer;
begin
  Result := Round(System.Math.Log2(I + 1));
end;

function TProgramStatInfo.ToString: string;
var
  Info: TStrings;
  Key: string;
  Value: Integer;
begin
  //format: PROPNAME1(COUNT)PROPNAME2(COUNT)
  Info := Settings.ReadValues(cStatisticsRegistryKey);
  try
    Result := '';
    for Key in Info do
    begin
      Value := Settings.ReadInteger(cStatisticsRegistryKey, Key, 0);
      if Value > 0 then
      begin
        Value := ProcessCount(Value);
        Result := Result + Key + IntToStr(Value);
      end;
    end;
  finally
    F(Info);
  end;
end;

procedure TProgramStatInfo.UpdateProperty(PropertyAlias: string);
begin
  try
    Settings.IncrementInteger(cStatisticsRegistryKey, PropertyAlias);
  except
    //this is OK, this methoud should never affect program flow
  end;
end;

initialization

finalization
  F(FProgramStatistics);

end.
