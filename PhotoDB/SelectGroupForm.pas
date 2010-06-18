unit SelectGroupForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Dolphin_DB, StdCtrls, ComCtrls, Language, UnitGroupsWork,
  ImgList, UnitDBkernel, UnitDBCommonGraphics;

type
  TFormSelectGroup = class(TForm)
    Label1: TLabel;
    ComboBoxEx1: TComboBoxEx;
    Button1: TButton;
    Button2: TButton;
    GroupsImageList: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
  ShowResult : Boolean;
  Groups : TGroups;
  procedure LoadLanguage;
  function Execute(out Group : TGroup) : Boolean;
  procedure RecreateGroupsList;
    { Public declarations }
  end;

  function SelectGroup(out Group : TGroup) : Boolean;

implementation

{$R *.dfm}

function SelectGroup(out Group : TGroup) : Boolean;
var
  FormSelectGroup: TFormSelectGroup;
begin
  Application.CreateForm(TFormSelectGroup, FormSelectGroup);
  Result:=FormSelectGroup.Execute(Group);
  FormSelectGroup.Release;
  if UseFreeAfterRelease then FormSelectGroup.Free;
end;

procedure TFormSelectGroup.FormCreate(Sender: TObject);
begin
 Groups:=UnitGroupsWork.GetRegisterGroupList(true,true);
 RecreateGroupsList;
 ShowResult:=false;
 DBKernel.RecreateThemeToForm(Self);
 LoadLanguage;
end;

procedure TFormSelectGroup.LoadLanguage;
begin
 Caption:=TEXT_MES_SELECT_GROUP;
 Label1.Caption:=TEXT_MES_SELECT_GROUP_TEXT+':';
 Button2.Caption:=TEXT_MES_CANCEL;
 Button1.Caption:=TEXT_MES_OK;
end;

procedure TFormSelectGroup.Button2Click(Sender: TObject);
begin
 Close;
end;

function TFormSelectGroup.Execute(out Group: TGroup): Boolean;
begin
 ShowModal;
 if ShowResult then
 begin
  if ComboBoxEx1.ItemIndex<>-1 then
  begin
   Group:=CopyGroup(Groups[ComboBoxEx1.ItemIndex]);
   Result:=true;
  end else Result:=false;
 end else Result:=false;
end;

procedure TFormSelectGroup.Button1Click(Sender: TObject);
begin
 ShowResult:=True;
 Close;
end;

procedure TFormSelectGroup.FormDestroy(Sender: TObject);
begin
 FreeGroups(Groups);
end;

procedure TFormSelectGroup.RecreateGroupsList;
var
  i : integer;
  SmallB, B : TBitmap;
  GroupImageValud : Boolean;
begin
 GroupsImageList.Clear;
 SmallB := TBitmap.Create;
 SmallB.PixelFormat:=pf24bit;
 SmallB.Width:=16;
 SmallB.Height:=18;
 SmallB.Canvas.Pen.Color:=Theme_MainColor;
 SmallB.Canvas.Brush.Color:=Theme_MainColor;
 SmallB.Canvas.Rectangle(0,0,16,18);
 DrawIconEx(SmallB.Canvas.Handle,0,0,UnitDBKernel.icons[DB_IC_GROUPS+1],16,16,0,0,DI_NORMAL);
 GroupsImageList.Add(SmallB,nil);
 SmallB.Free;
 ComboBoxEx1.Clear;
 for i:=0 to Length(Groups)-1 do
 begin
  SmallB := TBitmap.Create;
  SmallB.PixelFormat:=pf24bit;
  SmallB.Canvas.Brush.Color:=Theme_MainColor;
  GroupImageValud:=false;
  if Groups[i].GroupImage<>nil then
  if not Groups[i].GroupImage.Empty then
  begin
   B := TBitmap.Create;
   B.PixelFormat:=pf24bit;
   GroupImageValud:=true;
   B.Assign(Groups[i].GroupImage);
   DoResize(16,16,B,SmallB);
   B.Free;
   SmallB.Height:=18;
  end;
  GroupsImageList.Add(SmallB,nil);
  SmallB.Free;
  With ComboBoxEx1.ItemsEx.Add do
  begin
   if GroupImageValud then
   ImageIndex:=i+1 else ImageIndex:=0;
   Caption:=Groups[i].GroupName;
  end;
 end;
 ComboBoxEx1.ItemIndex:=0;
end;

end.
