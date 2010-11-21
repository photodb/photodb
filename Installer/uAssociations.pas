unit uAssociations;

interface

uses
  Classes, uMemory;

type
  TAssociation = class(TObject)

  end;

  TFileAssociation = class(TAssociation)
  public
    Extension : string;
    ExeParams : string;
  end;

  TFileAssociations = class(TObject)
  private
    FAssociations : TList;
    constructor Create;
    procedure AddFileExtension(Extension : string); overload;
    procedure AddFileExtension(Extension, ExeParams : string); overload;
    procedure FillList;
    function GetAssociations(Index: Integer): TFileAssociation;
    function GetCount: Integer;
  public
    class function Instance : TFileAssociations;
    destructor Destroy; override;
    property Associations[Index : Integer] : TFileAssociation read GetAssociations; default;
    property Count : Integer read GetCount;
  end;

implementation

var
  Instance : TFileAssociations = nil;

{ TFileAssociations }

class function TFileAssociations.Instance: TFileAssociations;
begin
  if Instance = nil then
    Instance := TFileAssociations.Create;

  Result := Instance;
end;

procedure TFileAssociations.AddFileExtension(Extension, ExeParams: string);
var
  Ext : TFileAssociation;
begin
  Ext := TFileAssociation.Create;
  Ext.Extension := Extension;
  Ext.ExeParams := ExeParams;
  FAssociations.Add(Ext);
end;

procedure TFileAssociations.AddFileExtension(Extension: string);
begin
  AddFileExtension(Extension, '');
end;

constructor TFileAssociations.Create;
begin
  FAssociations := TList.Create;
  FillList;
end;

destructor TFileAssociations.Destroy;
begin
  FreeList(FAssociations);
  inherited;
end;

procedure TFileAssociations.FillList;
begin
  AddFileExtension('.jfif');
  AddFileExtension('.jpg');
  AddFileExtension('.jpe');
  AddFileExtension('.jpeg');
  AddFileExtension('.tiff');
  AddFileExtension('.tif');
  AddFileExtension('.psd');
  AddFileExtension('.gif');
  AddFileExtension('.png');
  AddFileExtension('.bmp');
  AddFileExtension('.thm');

  AddFileExtension('.crw');
  AddFileExtension('.cr2');
  AddFileExtension('.nef');
  AddFileExtension('.raf');
  AddFileExtension('.dng');
  AddFileExtension('.mos');
  AddFileExtension('.kdc');
  AddFileExtension('.dcr');

  AddFileExtension('.pic');
  AddFileExtension('.pdd');
  AddFileExtension('.ppm');
  AddFileExtension('.pgm');
  AddFileExtension('.pbm');
  AddFileExtension('.fax');
  AddFileExtension('.rle');
  AddFileExtension('.rla');
  AddFileExtension('.tga');
  AddFileExtension('.dib');
  AddFileExtension('.win');
  AddFileExtension('.vst');
  AddFileExtension('.vda');
  AddFileExtension('.icb');
  AddFileExtension('.eps');
  AddFileExtension('.pcc');
  AddFileExtension('.pcx');
  AddFileExtension('.rpf');
  AddFileExtension('.sgi');
  AddFileExtension('.rgba');
  AddFileExtension('.rgb');
  AddFileExtension('.bw');
  AddFileExtension('.cel');
  AddFileExtension('.pcd');
  AddFileExtension('.psp');
  AddFileExtension('.cut');
end;

function TFileAssociations.GetAssociations(Index: Integer): TFileAssociation;
begin
  Result := FAssociations[Index];
end;

function TFileAssociations.GetCount: Integer;
begin
  Result := FAssociations.Count;
end;

initialization

finalization

  F(Instance);

end.
