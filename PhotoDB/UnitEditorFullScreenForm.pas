unit UnitEditorFullScreenForm;

interface

{$DEFINE PHOTODB}

uses
{$IFNDEF PHOTODB}
// dm,
{$ENDIF}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus,
  {$IFDEF PHOTODB}
 UnitDBKernel, Dolphin_DB,  UnitDBCommon, UnitDBCommonGraphics,
{$ENDIF}
   Language;

type
  TEditorFullScreenForm = class(TForm)
    DestroyTimer: TTimer;
    PopupMenu1: TPopupMenu;
    Close1: TMenuItem;
    N1: TMenuItem;
    SelectBackGroundColor1: TMenuItem;
    ColorDialog1: TColorDialog;
    procedure DestroyTimerTimer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure SelectBackGroundColor1Click(Sender: TObject);
  private
  CurrentImage : TBitmap;
  DrawImage : TBitmap;
    { Private declarations }
  public
  Procedure SetImage(Image : TBitmap);
  Procedure CreateDrawImage;
  Procedure LoadLanguage;
    { Public declarations }
  end;

var
  EditorFullScreenForm: TEditorFullScreenForm;

implementation

uses ImEditor;

{$R *.dfm}

{$IFNDEF PHOTODB}
procedure ProportionalSize(aWidth, aHeight: Integer; var aWidthToSize, aHeightToSize: Integer);
begin
// If Max(aWidthToSize,aHeightToSize)<Min(aWidth,aHeight) then
 If (aWidthToSize<aWidth) and (aHeightToSize<aHeight) then
 begin
  Exit;
 end;
 if (aWidthToSize = 0) or (aHeightToSize = 0) then
 begin
  aHeightToSize := 0;
  aWidthToSize  := 0;
 end else begin
  if (aHeightToSize/aWidthToSize) < (aHeight/aWidth) then
  begin
   aHeightToSize := Round ( (aWidth/aWidthToSize) * aHeightToSize );
   aWidthToSize  := aWidth;
  end else begin
   aWidthToSize  := Round ( (aHeight/aHeightToSize) * aWidthToSize );
   aHeightToSize := aHeight;
  end;
 end;
end;
{$ENDIF}

procedure TEditorFullScreenForm.DestroyTimerTimer(Sender: TObject);
begin
 EditorFullScreenForm.Release;
 EditorFullScreenForm:=nil;
end;

procedure TEditorFullScreenForm.FormPaint(Sender: TObject);
begin
 Canvas.Draw(ClientWidth div 2 - DrawImage.Width div 2,Clientheight div 2 - DrawImage.Height div 2,DrawImage);
end;

procedure TEditorFullScreenForm.SetImage(Image: TBitmap);
begin
 CurrentImage:=Image;
end;

procedure TEditorFullScreenForm.FormCreate(Sender: TObject);
begin
 DrawImage:=TBitmap.Create;
 DrawImage.PixelFormat:=pf24bit;
 LoadLanguage;
 {$IFDEF PHOTODB}
 PopupMenu1.Images:=DBKernel.ImageList;
 Close1.ImageIndex:=DB_IC_EXIT;
 SelectBackGroundColor1.ImageIndex:=DB_IC_DESKTOP;
 {$ENDIF}
end;

procedure TEditorFullScreenForm.FormDestroy(Sender: TObject);
begin
 DrawImage.Free;
end;

procedure TEditorFullScreenForm.Close1Click(Sender: TObject);
begin
 Close;
end;

procedure TEditorFullScreenForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 DestroyTimer.Enabled:=true;
end;

procedure TEditorFullScreenForm.CreateDrawImage;
var
  w, h : integer;
begin
 w:=CurrentImage.Width;
 h:=CurrentImage.Height;
 ProportionalSize(Screen.Width,Screen.Height,w,h);
 DoResize(w,h,CurrentImage,DrawImage);
end;

procedure TEditorFullScreenForm.FormKeyPress(Sender: TObject;
  var Key: Char);
begin
 if Key=#27 then Close;
 {$IFDEF PHOTODB}
 if (Key=#10)  and CtrlKeyDown and Focused then Close;
 {$ENDIF}
end;

procedure TEditorFullScreenForm.LoadLanguage;
begin
 Close1.Caption:=TEXT_MES_CLOSE;
 SelectBackGroundColor1.Caption:=TEXT_MES_SELECT_BK_COLOR;

end;

procedure TEditorFullScreenForm.SelectBackGroundColor1Click(
  Sender: TObject);
begin
 ColorDialog1.Color:=Color;
 if ColorDialog1.Execute then Color:=ColorDialog1.Color;
 Refresh;
end;

end.
