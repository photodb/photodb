unit uImportSeriesPreview;

interface

uses
  Generics.Collections,
  uThreadEx,
  uMemory,
  Graphics,
  uThreadForm,
  uPathProviders,
  System.Classes;

type
  TImportSeriesPreview = class(TThreadEx)
  private
    { Private declarations }
    FData: TList<TPathItem>;
    FSize: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(OwnerForm: TThreadForm; Items: TList<TPathItem>; Size: Integer);
    destructor Destroy; override;
  end;

implementation

{ TImportSeriesPreview }

constructor TImportSeriesPreview.Create(OwnerForm: TThreadForm;
  Items: TList<TPathItem>; Size: Integer);
begin
  inherited Create(OwnerForm, OwnerForm.StateID);
  FData := Items;
  FSize := Size;
end;

destructor TImportSeriesPreview.Destroy;
begin
  FreeList(FData);
  inherited;
end;

procedure TImportSeriesPreview.Execute;
var
  I: Integer;
  B: TBitmap;
  Data: TObject;
begin
  FreeOnTerminate := True;
  for I := 0 to FData.Count - 1 do
  begin
    B := TBitmap.Create;
    try
      Data := nil;
      FData[I].Provider.ExtractPreview(FData[I], FSize, FSize, B, Data);
    finally
      F(B);
    end;
  end;
end;

end.
