unit UnitBitmapImageList;

interface

uses Graphics;

type
 TBitmapImageListImage = record
  Bitmap : TBitmap;
  IsBitmap : Boolean;
  Icon : TIcon;
  SelfReleased : Boolean;
  Ext : string;
 end;

type
 TBitmapImageList = Class(TObject)
 Private

 Public
 Constructor Create;
 Destructor Destroy; override;
  public
   FImages : array of TBitmapImageListImage;
   Procedure AddBitmap(Bitmap : TBitmap);
   Procedure AddIcon(Icon : TIcon; SelfReleased : Boolean; Ext : string = '');
   Procedure Clear;
   Function Count : Integer;
   Procedure Delete(Index : Integer);
 end;

implementation

{ BitmapImageList }

procedure TBitmapImageList.AddBitmap(Bitmap: TBitmap);
begin
 SetLength(FImages,Length(FImages)+1);
 if Bitmap<>nil then
 begin
  Pointer(FImages[Length(FImages)-1].Bitmap):=Pointer(Bitmap);
  FImages[Length(FImages)-1].Icon:=nil;
  FImages[Length(FImages)-1].IsBitmap:=true;
  FImages[Length(FImages)-1].SelfReleased:=true;
  FImages[Length(FImages)-1].Ext:='';
 end else
 begin
  FImages[Length(FImages)-1].Bitmap:=nil;
  FImages[Length(FImages)-1].Icon:=nil;
  FImages[Length(FImages)-1].IsBitmap:=true;
  FImages[Length(FImages)-1].SelfReleased:=false;
  FImages[Length(FImages)-1].Ext:='';
 end;
end;

procedure TBitmapImageList.AddIcon(Icon: TIcon; SelfReleased : Boolean; Ext : string = '');
begin
 SetLength(FImages,Length(FImages)+1);
 FImages[Length(FImages)-1].Bitmap:=nil;
 FImages[Length(FImages)-1].Icon:=Icon;
 FImages[Length(FImages)-1].IsBitmap:=false;
 FImages[Length(FImages)-1].SelfReleased:=SelfReleased;
 FImages[Length(FImages)-1].Ext:=Ext;
end;

procedure TBitmapImageList.Clear;
var
  i : integer;
begin
 For i:=0 to Length(FImages)-1 do
 begin
  try
  if FImages[i].SelfReleased then
  begin
   if FImages[i].Bitmap<>nil then
   FImages[i].Bitmap.Free;
  end else
  begin
   if FImages[i].Icon<>nil then
   FImages[i].Icon.Free;
  end;
  except
  end;
 end;
 SetLength(FImages,0);
end;

function TBitmapImageList.Count: Integer;
begin
 Result:=Length(FImages);
end;

constructor TBitmapImageList.Create;
begin
 inherited;
 SetLength(FImages,0);
end;

procedure TBitmapImageList.Delete(Index: Integer);
var
  i : integer;
begin
 if length(FImages)=0 then exit;
 FImages[Index].Bitmap.Free;
 if FImages[Index].SelfReleased then
 if FImages[Index].Icon<>nil then
 FImages[Index].Icon.Free;
 For i:=Index to length(FImages)-2 do
 FImages[i]:=FImages[i+1];
 SetLength(FImages,Length(FImages)-1);
end;

destructor TBitmapImageList.Destroy;
begin
 Clear;
 Inherited;
end;

end.
