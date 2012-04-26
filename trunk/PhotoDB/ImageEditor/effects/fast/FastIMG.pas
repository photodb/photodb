unit FastIMG;

interface

uses
  Windows, Messages, Forms, Graphics, {DsgnIntf,} Classes, Controls, SysUtils,
  Dialogs, FastRGB, FastBMP, Fast256;

type
  TBMPFilename=type string;
 { TBMPFilenameProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;  }

TDrawStyle=(dsDraw,dsStretch,dsResize,dsTile,dsCenter);
TDataType=(dtFastBMP,dtFast256);

TFastIMG=class(TCustomControl)
  private
    fBmp:       TFastRGB;
    fDrawStyle: TDrawStyle;
    fSmthSize,
    fAutoSize:  Boolean;
    fDataType:  TDataType;
    fCMode:     TConversionMode;
    fFileName:  TBMPFilename;
    procedure   SetBitmap(x:TFastRGB);
    procedure   SetSmthSize(x:Boolean);
    procedure   SetAutoSize(x:Boolean);
    procedure   SetDrawStyle(x:TDrawStyle);
    procedure   SetDataType(x:TDataType);
    procedure   SetConversionMode(x:TConversionMode);
    procedure   SetFileName(const x:TBMPFilename);
    procedure   Erase(var Msg:TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure   Paint(var Msg:TWMPaint); message WM_PAINT;
  public
    constructor Create(AOwner:TComponent); override;
    destructor  Destroy; override;
    procedure   LoadFromFile(x:string);
    property    Bmp:TFastRGB read fBmp write SetBitmap;
  published
    property    AutoSize:Boolean read fAutoSize write SetAutoSize;
    property    BilinearResize:Boolean read fSmthSize write SetSmthSize;
    property    DrawStyle:TDrawStyle read fDrawStyle write SetDrawStyle;
    property    DataType:TDataType read fDataType write SetDataType;
    property    Convert_256:TConversionMode read fCMode write SetConversionMode;
    property    FileName:TBMPFilename read fFileName write SetFileName;
    property    Align;
    property    Color;
    property    DragCursor;
    property    DragMode;
    property    Enabled;
    property    ParentColor;
    property    ParentFont;
    property    ParentShowHint;
    property    PopupMenu;
    property    ShowHint;
    property    Visible;
    property    OnClick;
    property    OnDblClick;
    property    OnDragDrop;
    property    OnDragOver;
    property    OnEndDrag;
    property    OnMouseDown;
    property    OnMouseMove;
    property    OnMouseUp;
    property    OnStartDrag;
  end;

procedure register;
function  IsPalette:Boolean;

implementation

function IsPalette:Boolean;
var
sdc: HDC;
begin
  sdc:=GetDC(0);
  Result:=GetDeviceCaps(sdc,BITSPIXEL)<9;
  ReleaseDC(0,sdc);
end;

procedure register;
begin
  RegisterComponents('Standard',[TFastIMG]);
//  RegisterPropertyEditor(TypeInfo(TBMPFilename),nil,'',TBMPFilenameProperty);
end;

constructor TFastIMG.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetBounds(Left,Top,100,100);
end;

destructor TFastIMG.Destroy;
begin
  fBmp:=nil;
  inherited Destroy;
end;

procedure TFastIMG.Erase(var Msg:TWMEraseBkgnd);
begin

end;

procedure TFastIMG.SetBitmap(x:TFastRGB);
begin
  fBmp:=x;
  if fBmp is TFast256 then fDataType:=dtFast256 else
  if fBmp is TFastBMP then fDataType:=dtFastBMP;
  if fAutoSize then SetBounds(Left,Top,fBmp.Width,fBmp.Height);
end;

procedure TFastIMG.LoadFromFile(x:string);
begin
  if FileExists(x) then
  begin
    if not Assigned(fBmp) then
    begin
      case fDataType of
        dtFastBMP: fBmp:=TFastBMP.Create;
        dtFast256: fBmp:=TFast256.Create;
      end;
    end;
    case fDataType of
      dtFastBMP: TFastBMP(fBmp).LoadFromFile(x);
      dtFast256: TFast256(fBmp).LoadFromFile(x,fCMode);
    end;
    if fAutoSize then SetBounds(Left,Top,fBmp.Width,fBmp.Height);
  end;
end;

procedure TFastIMG.SetAutoSize(x:Boolean);
begin
  fAutoSize:=x;
  if fAutoSize and Assigned(Bmp)then
  begin
    Align:=alNone;
    SetBounds(Left,Top,Bmp.Width,Bmp.Height);
  end;
end;

procedure TFastIMG.SetSmthSize(x:Boolean);
begin
  fSmthSize:=x;
  Refresh;
end;

procedure TFastIMG.SetDrawStyle(x:TDrawStyle);
begin
  fDrawStyle:=x;
  Refresh;
end;

procedure TFastIMG.SetDataType(x:TDataType);
begin
  fDataType:=x;
  if csDesigning in ComponentState then
  begin
    if Assigned(fBmp) then fBmp.Free;
    case fDataType of
      dtFastBMP: fBmp:=TFastBMP.Create;
      dtFast256: fBmp:=TFast256.Create;
    end;
    if fFileName<>'' then LoadFromFile(fFileName);
    Refresh;
  end;
end;

procedure TFastIMG.SetConversionMode(x:TConversionMode);
begin
  fCMode:=x;
  if(csDesigning in ComponentState)and(fFileName<>'')then
    LoadFromFile(fFileName);
  Refresh;
end;

procedure TFastIMG.SetFileName(const x:TBMPFilename);
begin
  if x='' then Bmp:=nil;
  fFileName:=x;
  LoadFromFile(x);
  Refresh;
end;

procedure TFastIMG.Paint(var Msg:TWMPaint);
var
ps:    TPaintStruct;
r1,r2: HRGN;
ax,ay: Single;
iw,ih,
cx,cy: Integer;
Tmp:   TFastRGB;
begin
  BeginPaint(Handle,ps);
  if Assigned(Bmp)then case fDrawStyle of
  dsDraw:
    begin
      if(Width>fBmp.Width)or(Height>fBmp.Height)then
      begin
        r1:=CreateRectRgn(0,0,Width,Height);
        r2:=CreateRectRgn(0,0,fBmp.Width,fBmp.Height);
        CombineRgn(r1,r1,r2,RGN_XOR);
        DeleteObject(r2);
        FillRgn(ps.hdc,r1,Brush.Handle);
        DeleteObject(r1);
      end;
      fBmp.Draw(ps.hdc,0,0);
    end;
  dsStretch:
    begin
      if fSmthSize then
      begin
        case fDataType of
          dtFastBMP: Tmp:=TFastBMP.Create;
          dtFast256:
          begin
            Tmp:=TFast256.Create;
            TFast256(Tmp).Colors^:=TFast256(fBmp).Colors^;
          end;
        end;
        Tmp.SetSize(Width,Height);
        fBmp.SmoothResize(Tmp);
        Tmp.Draw(ps.hdc,0,0);
        Tmp.Free;
      end else
      fBmp.Stretch(ps.hdc,0,0,Width,Height);
    end;
  dsResize:
    begin
      if fBmp.Width=0 then iw:=1 else iw:=fBmp.Width;
      if fBmp.Height=0 then ih:=1 else ih:=fBmp.Height;
      ax:=Width/iw;
      ay:=Height/ih;

      if ax>ay then
      begin
        ax:=fBmp.Width*ay;       ay:=Height;
        cx:=Round((Width-ax)/2); cy:=0;
      end else
      begin
        ay:=fBmp.Height*ax;       ax:=Width;
        cy:=Round((Height-ay)/2); cx:=0;
      end;
      iw:=Round(ax); ih:=Round(ay);
      if(cx<>0)or(cy<>0)then
      begin
        r1:=CreateRectRgn(0,0,Width,Height);
        r2:=CreateRectRgn(cx,cy,iw+cx,ih+cy);
        CombineRgn(r1,r1,r2,RGN_XOR);
        DeleteObject(r2);
        FillRgn(ps.hdc,r1,Brush.Handle);
        DeleteObject(r1);
      end;
      if fSmthSize then
      begin
        case fDataType of
          dtFastBMP:
          begin
            Tmp:=TFastBMP.Create;
            TFastBMP(Tmp).SetSize(iw,ih);
          end;
          dtFast256:
          begin
            Tmp:=TFast256.Create;
            TFast256(Tmp).SetSize(iw,ih);
            TFast256(Tmp).Colors^:=TFast256(fBmp).Colors^;
          end;
        end;
        fBmp.SmoothResize(Tmp);
        Tmp.Draw(ps.hdc,cx,cy);
        Tmp.Free;
      end else
      fBmp.Stretch(ps.hdc,cx,cy,iw,ih);
    end;
    dsTile: fBmp.TileDraw(ps.hdc,0,0,Width,Height);
    dsCenter:
      begin
        cx:=(Width-fBmp.Width)div 2;
        cy:=(Height-fBmp.Height)div 2;
        if(Width>fBmp.Width)or(Height>fBmp.Height)then
        begin
          r1:=CreateRectRgn(0,0,Width,Height);
          r2:=CreateRectRgn(cx,cy,fBmp.Width+cx,fBmp.Height+cy);
          CombineRgn(r1,r1,r2,RGN_XOR);
          DeleteObject(r2);
          FillRgn(ps.hdc,r1,Brush.Handle);
          DeleteObject(r1);
        end;
        fBmp.Draw(ps.hdc,cx,cy);
      end;
    end else //fBmp=nil
  FillRect(ps.hdc,ps.rcPaint,Brush.Handle);

  if(csDesigning in ComponentState)then
  DrawFocusRect(ps.hdc,RECT(0,0,Width,Height));

  EndPaint(Handle,ps);
end;

{TBMPFilenameProperty}

{procedure TBMPFilenameProperty.Edit;
begin
  with TOpenDialog.Create(Application) do
  begin
    FileName:=GetValue;
    Filter:='bitmaps (*.bmp)|*.bmp';
    Options:=Options+[ofPathMustExist,ofFileMustExist,ofHideReadOnly];
    if Execute then SetValue(Filename);
    Free;
  end;
end;

function TBMPFilenameProperty.GetAttributes: TPropertyAttributes;
begin
  Result:=[paDialog,paRevertable];
end;   }

end.
