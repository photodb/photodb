unit UnitPropertyLoadGistogrammThread;

interface

uses
  Windows, Classes, Messages, Forms, Graphics, SysUtils, RAWImage, 
  Dolphin_DB, UnitDBKernel, GraphicCrypt, JPEG, Effects, GraphicsBaseTypes;

type
  TPropertyLoadGistogrammThreadOptions = record
    FileName : String;
    Owner : TForm;
    SID : TGUID;
    OnDone : TNotifyEvent;
  end;

type
  TPropertyLoadGistogrammThread = class(TThread)
  private   
   fOptions : TPropertyLoadGistogrammThreadOptions;
   fPic : TPicture;
   StrParam : String;
   Password : String;
   Data : TGistogrammData;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: Boolean;
      Options : TPropertyLoadGistogrammThreadOptions);
    procedure GetCurrentpassword;  
    procedure GetPasswordFromUserSynch;
    procedure SetGistogrammData;        
    procedure DoOnDone;
  end;

implementation

uses PropertyForm, UnitPasswordForm;

{ TPropertyLoadGistogrammThread }

constructor TPropertyLoadGistogrammThread.Create(CreateSuspennded: Boolean;
  Options: TPropertyLoadGistogrammThreadOptions);
begin
 inherited Create(true);
 fOptions := Options;
 if not CreateSuspennded then Resume;
end;

function Gistogramma(w,h : integer; S : PARGBArray) : TGistogrammData;
var
  I, j : integer;
  ps : PARGB;
  LGray, LR, LG, LB : byte;
begin
  for I := 0 to 255 do
  begin
    Result.Gray[I] := 0;
    Result.Red[I] := 0;
    Result.Green[I] := 0;
    Result.Blue[I] := 0;
  end;

  for I:=0 to H - 1 do
  begin
    ps := S[i];
    for j:=0 to W-1 do
    begin
      LR := ps[j].r;
      LG := ps[j].g;
      LB := ps[j].b;
      LGray:= (ps[j].R * 77 + ps[j].G * 151 + ps[j].B * 28) shr 8;
      Inc(Result.Gray[LGray]);
      Inc(Result.Red[LR]);
      Inc(Result.Green[LG]);
      Inc(Result.Blue[LB]);
    end;
  end;
end;

procedure TPropertyLoadGistogrammThread.DoOnDone;
begin          
 if PropertyManager.IsPropertyForm(fOptions.Owner) then
 if IsEqualGUID((fOptions.Owner as TPropertiesForm).SID, fOptions.SID) then
 fOptions.OnDone(self);
end;

procedure TPropertyLoadGistogrammThread.Execute;
var
  Bitmap : TBitmap;
  Terminated : Boolean;
  PRGBArr : PARGBArray;
  i : integer;
begin
 FreeOnTerminate:=true;

 fPic := TPicture.Create;
 try
  if ValidCryptGraphicFile(fOptions.FileName) then
  begin
   PassWord:=DBkernel.FindPasswordForCryptImageFile(fOptions.FileName);
   Synchronize(GetCurrentpassword);
   if ValidPassInCryptGraphicFile(fOptions.FileName,StrParam) then
   PassWord:=StrParam;
   if PassWord='' then
   begin
    StrParam:=fOptions.FileName;
    Synchronize(GetPasswordFromUserSynch);
    PassWord:=StrParam;
   end;
   if PassWord<>'' then
   begin
    fPic.Graphic:=DeCryptGraphicFile(fOptions.FileName,PassWord);
   end
   else
   begin
    fPic.free;
    Exit;
   end
  end else
  fPic.LoadFromFile(fOptions.FileName);
 except
  fPic.free;
  Exit;
 End;
 if fPic.Graphic is TJPEGImage then
 begin
  if fPic.Graphic.Width*fPic.Graphic.Height>640*480 then
  JPEGScale(fPic.Graphic,640,480);
 end;
 Bitmap := TBitmap.Create;
 Bitmap.Assign(fPic.Graphic);   
 Bitmap.PixelFormat:=pf24bit;
 fPic.Free;
 SetLength(PRGBArr,Bitmap.Height);
 for i:=0 to Bitmap.Height-1 do
 PRGBArr[i]:=Bitmap.ScanLine[i];
 Data:=Gistogramma(Bitmap.Width,Bitmap.Height,PRGBArr);
 Bitmap.Free;
 Synchronize(SetGistogrammData);
 Synchronize(DoOnDone);
end;

procedure TPropertyLoadGistogrammThread.GetCurrentpassword;
begin
  if PropertyManager.IsPropertyForm(fOptions.Owner) then
    if IsEqualGUID((fOptions.Owner as TPropertiesForm).SID, fOptions.SID) then
      StrParam:=(fOptions.Owner as TPropertiesForm).FCurrentPass;
end;

procedure TPropertyLoadGistogrammThread.GetPasswordFromUserSynch;
begin
  if PropertyManager.IsPropertyForm(fOptions.Owner) then
    if IsEqualGUID((fOptions.Owner as TPropertiesForm).SID, fOptions.SID) then
      StrParam:=GetImagePasswordFromUser(StrParam);
end;

procedure TPropertyLoadGistogrammThread.SetGistogrammData;
begin
  if PropertyManager.IsPropertyForm(fOptions.Owner) then
    if IsEqualGUID((fOptions.Owner as TPropertiesForm).SID, fOptions.SID) then
     (fOptions.Owner as TPropertiesForm).GistogrammData:=Data;
end;

end.
