unit SelectGroupForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Dolphin_DB, StdCtrls, ComCtrls, UnitGroupsWork, uMemoryEx,
  ImgList, UnitDBkernel, UnitDBCommonGraphics, uDBForm, uMemory,
  uConstants;

type
  TFormSelectGroup = class(TDBForm)
    LbInfo: TLabel;
    CbeGroupList: TComboBoxEx;
    BtOk: TButton;
    BtCancel: TButton;
    GroupsImageList: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure BtOkClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    ShowResult: Boolean;
    Groups: TGroups;
    procedure LoadLanguage;
    function Execute(out Group: TGroup): Boolean;
    procedure RecreateGroupsList;
  end;

  function SelectGroup(out Group : TGroup) : Boolean;

implementation

{$R *.dfm}

function SelectGroup(out Group : TGroup) : Boolean;
var
  FormSelectGroup: TFormSelectGroup;
begin
  Application.CreateForm(TFormSelectGroup, FormSelectGroup);
  try
    Result := FormSelectGroup.Execute(Group);
  finally
    R(FormSelectGroup);
  end;
end;

procedure TFormSelectGroup.FormCreate(Sender: TObject);
begin
  Groups := UnitGroupsWork.GetRegisterGroupList(True, True);
  RecreateGroupsList;
  ShowResult := False;
  LoadLanguage;
end;

procedure TFormSelectGroup.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Select group');
    LbInfo.Caption := L('Select, please, necessary group') + ':';
    BtCancel.Caption := L('Cancel');
    BtOk.Caption := L('Ok');
  finally
    EndTranslate;
  end;
end;

procedure TFormSelectGroup.BtCancelClick(Sender: TObject);
begin
  Close;
end;

function TFormSelectGroup.Execute(out Group: TGroup): Boolean;
begin
  Result := False;
  ShowModal;
  if ShowResult and (CbeGroupList.ItemIndex > -1) then
  begin
    Group := CopyGroup(Groups[CbeGroupList.ItemIndex]);
    Result := True;
  end;
end;

procedure TFormSelectGroup.BtOkClick(Sender: TObject);
begin
  ShowResult := True;
  Close;
end;

procedure TFormSelectGroup.FormDestroy(Sender: TObject);
begin
  FreeGroups(Groups);
end;

function TFormSelectGroup.GetFormID: string;
begin
  Result := 'SelectGroup';
end;

procedure FillGroupsToImageList(ImageList : TImageList; Groups : TGroups; BackgroundColor : TColor);
var
  I : Integer;
  SmallB, B : TBitmap;
begin
  ImageList.Clear;
  for I := -1 to Length(Groups) - 1 do
  begin
    SmallB := TBitmap.Create;
    try
      SmallB.PixelFormat := Pf24bit;
      SmallB.Width := 16;
      SmallB.Height := 18;
      SmallB.Canvas.Pen.Color := BackgroundColor;
      SmallB.Canvas.Brush.Color := BackgroundColor;
      if I = -1 then
        DrawIconEx(SmallB.Canvas.Handle, 0, 0, UnitDBKernel.Icons[DB_IC_GROUPS + 1], 16, 16, 0, 0, DI_NORMAL)
      else
      begin
        if (Groups[I].GroupImage <> nil) and not Groups[I].GroupImage.Empty then
        begin
          B := TBitmap.Create;
          try
            B.PixelFormat := Pf24bit;
            B.Assign(Groups[I].GroupImage);
            DoResize(16, 16, B, SmallB);
          finally
            F(B);
          end;
        end;
      end;
      ImageList.Add(SmallB, nil);
    finally
      F(SmallB);
    end;
  end;
end;

procedure TFormSelectGroup.RecreateGroupsList;
var
  I : integer;
begin
  CbeGroupList.Clear;
  FillGroupsToImageList(GroupsImageList, Groups, ClBtnFace);

  for I := 0 to Length(Groups) - 1 do
    with CbeGroupList.ItemsEx.Add do
    begin
      ImageIndex := I + 1;
      Caption := Groups[I].GroupName;
    end;

  if CbeGroupList.Items.Count > 0 then
    CbeGroupList.ItemIndex:=0;
end;

end.
