unit Dmitry.Graphics.BitmapCache;

interface

uses
  Generics.Collections,
  System.Classes,
  System.SysUtils,
  Vcl.Graphics,
  Dmitry.Memory;

type
  TGraphicCachedObject = class(TObject)
  protected
    procedure SaveToCache; virtual; abstract;
    procedure LoadFromCache; virtual; abstract;
  end;

  TCachedGraphic<T: TGraphic, constructor> = class(TGraphicCachedObject)
  private
    FGraphic: T;
    FMemory: TMemoryStream;
    FGraphicInMemory: Boolean;
    function GetGraphic: T;
    procedure SetGraphic(const Value: T);
  protected
    procedure SaveToCache; override;
    procedure LoadFromCache; override;
  public
    constructor Create;
    destructor Destroy; override;
    property Graphic: T read GetGraphic write SetGraphic;
  end;

  TGraphicCacheManager = class(TObject)
  private
    FUseList: TList<TGraphicCachedObject>;
  protected
    procedure UsedItem(Item: TGraphicCachedObject);
    procedure RemoveItem(Item: TGraphicCachedObject);
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  GraphicObjectsLimit: Integer = 100;
  GraphicsSwapAtTime: Integer = 10;

function GraphicCacheManager: TGraphicCacheManager;

implementation

var
  FGraphicCacheManager: TGraphicCacheManager = nil;

function GraphicCacheManager: TGraphicCacheManager;
begin
  if FGraphicCacheManager = nil then
    FGraphicCacheManager := TGraphicCacheManager.Create;

  Result := FGraphicCacheManager;
end;

{ TCachedGraphic }

constructor TCachedGraphic<T>.Create;
begin
  FGraphic := nil;
  FMemory := nil;
  FGraphicInMemory := False;
end;

destructor TCachedGraphic<T>.Destroy;
begin
  F(FGraphic);
  F(FMemory);
  inherited;
end;

function TCachedGraphic<T>.GetGraphic: T;
begin
  GraphicCacheManager.UsedItem(Self);
  LoadFromCache;
  Result := FGraphic;
end;

procedure TCachedGraphic<T>.LoadFromCache;
begin
  if FMemory = nil then
    Exit;

  FMemory.Seek(0, soFromBeginning);

  FGraphic := T.Create;
  FGraphic.LoadFromStream(FMemory);

  F(FMemory);
end;

procedure TCachedGraphic<T>.SaveToCache;
begin
  if (FGraphic = nil) then
    Exit;

  if FMemory <> nil then
    Exit;

  FMemory := TMemoryStream.Create;

  if FGraphic <> nil then
    FGraphic.SaveToStream(FMemory);

  F(FGraphic);
end;

procedure TCachedGraphic<T>.SetGraphic(const Value: T);
begin
  LoadFromCache;
  F(FGraphic);

  FGraphic := Value;
end;

{ TGraphicCacheManager }

constructor TGraphicCacheManager.Create;
begin
  FUseList := TList<TGraphicCachedObject>.Create;
end;

destructor TGraphicCacheManager.Destroy;
begin
  F(FUseList);
  inherited;
end;

procedure TGraphicCacheManager.RemoveItem(Item: TGraphicCachedObject);
begin
  FUseList.Remove(Item);
end;

procedure TGraphicCacheManager.UsedItem(Item: TGraphicCachedObject);
var
  I: Integer;
begin
  RemoveItem(Item);
  FUseList.Add(Item);
  if FUseList.Count > GraphicObjectsLimit then
  begin
    for I := GraphicsSwapAtTime - 1 downto 0 do
    begin
      FUseList[I].SaveToCache;
      FUseList.Delete(I);
    end;
  end;
end;

initialization

finalization
  F(FGraphicCacheManager);

end.
