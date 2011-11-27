unit uFormEditObject;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uDBForm, uMemory, uMemoryEx, uFaceDetection,
  WatermarkedMemo;

type
  TImageObject = class(TObject);

  TFormEditObject = class(TDBForm)
    CbColor: TColorBox;
    LbColor: TLabel;
    LbNoteText: TLabel;
    BtnOk: TButton;
    BtnCancel: TButton;
    RgType: TRadioGroup;
    WemText: TWatermarkedMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FIsEditMode: Boolean;
    procedure LoadLanguage;
  protected
    { Protected declarations }
    function GetFormID: string; override;
  public
    { Public declarations }
    procedure EditObject(ObjectID: Integer);
    procedure CreateObject(ImageID: Integer; AreaInfo: TFaceDetectionResultItem; out ImageObject: TImageObject);
  end;

function EditObject(ObjectID: Integer): Boolean;
procedure CreateObject(ImageID: Integer; AreaInfo: TFaceDetectionResultItem; out ImageObject: TImageObject);

implementation

function EditObject(ObjectID: Integer): Boolean;
var
  FormEditObject: TFormEditObject;
begin
  Application.CreateForm(TFormEditObject, FormEditObject);
  try
    FormEditObject.EditObject(ObjectID);
  finally
    R(FormEditObject);
  end;
end;

procedure CreateObject(ImageID: Integer; AreaInfo: TFaceDetectionResultItem; out ImageObject: TImageObject);
var
  FormEditObject: TFormEditObject;
begin
  Application.CreateForm(TFormEditObject, FormEditObject);
  try
    FormEditObject.CreateObject(ImageID, AreaInfo, ImageObject);
  finally
    R(FormEditObject);
  end;
end;

{$R *.dfm}

procedure TFormEditObject.CreateObject(ImageID: Integer;
  AreaInfo: TFaceDetectionResultItem; out ImageObject: TImageObject);
begin
  FIsEditMode := True;
  LoadLanguage;
  ShowModal;
end;

procedure TFormEditObject.EditObject(ObjectID: Integer);
begin
  FIsEditMode := False;
  LoadLanguage;
  ShowModal;
end;

procedure TFormEditObject.FormCreate(Sender: TObject);
const
  ColorCount = 6;
  ColorsTexts: array [1 .. ColorCount] of string = ('Green', 'Red', 'Blue', 'Gray', 'Yellow', 'White');
  Colors: array [1 .. ColorCount] of TColor = (clGreen, clred, clblue, clGray, clYellow, clWhite);
var
  I: Integer;
begin
  FIsEditMode := False;
  for I := 1 to High(Colors) do
    CbColor.AddItem(L(ColorsTexts[I]), TObject(Colors[I]));
end;

function TFormEditObject.GetFormID: string;
begin
  Result := 'EditObject';
end;

procedure TFormEditObject.LoadLanguage;
begin
  BeginTranslate;
  try
    if FIsEditMode then
      Caption := L('Edit text')
    else
      Caption := L('Create note');
    LbNoteText.Caption := L('Text') + ':';
    WemText.WatermarkText := L('Please enter your text');
    LbColor.Caption := L('Color') + ':';
    RgType.Caption := L('Note type');
    RgType.Items[0] := L('Object rect');
    RgType.Items[1] := L('Text');
    BtnCancel.Caption := L('Cancel');
    BtnOk.Caption := L('Ok');
  finally
    EndTranslate;
  end;
end;

end.
