unit UnitEditorFullScreenForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, uConstants, uMemory, uDBForm, uBitmapUtils,
  UnitDBKernel, uSysUtils;

type
  TEditorFullScreenForm = class(TDBForm)
    PmMain: TPopupMenu;
    Close1: TMenuItem;
    N1: TMenuItem;
    SelectBackGroundColor1: TMenuItem;
    ColorDialog1: TColorDialog;
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure SelectBackGroundColor1Click(Sender: TObject);
  private
    { Private declarations }
    CurrentImage: TBitmap;
    DrawImage: TBitmap;
    procedure LoadLanguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure SetImage(Image: TBitmap);
    procedure CreateDrawImage;
  end;

var
  EditorFullScreenForm: TEditorFullScreenForm;

implementation

uses ImEditor;

{$R *.dfm}

procedure TEditorFullScreenForm.FormPaint(Sender: TObject);
begin
  Canvas.Draw(ClientWidth div 2 - DrawImage.Width div 2, Clientheight div 2 - DrawImage.Height div 2, DrawImage);
end;

function TEditorFullScreenForm.GetFormID: string;
begin
  Result := 'Editor';
end;

procedure TEditorFullScreenForm.SetImage(Image: TBitmap);
begin
  CurrentImage := Image;
end;

procedure TEditorFullScreenForm.FormCreate(Sender: TObject);
begin
  DrawImage := TBitmap.Create;
  DrawImage.PixelFormat := Pf24bit;
  LoadLanguage;

  PmMain.Images := DBKernel.ImageList;
  Close1.ImageIndex := DB_IC_EXIT;
  SelectBackGroundColor1.ImageIndex := DB_IC_DESKTOP;
end;

procedure TEditorFullScreenForm.FormDestroy(Sender: TObject);
begin
  F(DrawImage);
end;

procedure TEditorFullScreenForm.Close1Click(Sender: TObject);
begin
  Close;
end;

procedure TEditorFullScreenForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Release;
end;

procedure TEditorFullScreenForm.CreateDrawImage;
var
  W, H: Integer;
begin
  W := CurrentImage.Width;
  H := CurrentImage.Height;
  ProportionalSize(Screen.Width, Screen.Height, W, H);
  DoResize(W, H, CurrentImage, DrawImage);
end;

procedure TEditorFullScreenForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_ESCAPE then
    Close;
  if (Key = #10) and CtrlKeyDown and Focused then
    Close;
end;

procedure TEditorFullScreenForm.LoadLanguage;
begin
  BeginTranslate;
  try
    Close1.Caption := L('Close');
    SelectBackGroundColor1.Caption := L('Select background color');
  finally
    EndTranslate;
  end;
end;

procedure TEditorFullScreenForm.SelectBackGroundColor1Click(Sender: TObject);
begin
  ColorDialog1.Color := Color;
  if ColorDialog1.Execute then
    Color := ColorDialog1.Color;
  Refresh;
end;

end.
