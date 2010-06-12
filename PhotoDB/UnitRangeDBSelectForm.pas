unit UnitRangeDBSelectForm;

interface


uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, CommonDBSupport,ExtCtrls, WebLink, DateUtils,
  Dolphin_DB, AppEvnts, EasyListview, uVistaFuncs,
  MPCommonUtilities, MPCommonObjects;

type

  TSetSearchDateRangeProcedure = procedure(Sender : TObject; DateFrom, DateTo, LastDate : TDateTime; ByLastDate: boolean) of object;

type
  TFormDateRangeSelectDB = class(TForm)
    EasyListview1: TEasyListview;
    ApplicationEvent1: TApplicationEvents;
    Panel1: TPanel;
    StartTimer: TTimer;
    ImageBackGround: TImage;
    Panel2: TPanel;
    CloseLink: TWebLink;
    procedure DBOpened(Sender: TObject);
    procedure EasyListview1ItemClick(Sender: TCustomEasyListview;
  Item: TEasyItem; KeyStates: TCommonKeyStates;
  HitInfo: TEasyItemHitTestInfoSet);
    procedure Execute(DateFrom, DateTo, LastDate : TDateTime; ByLastDate: boolean; Proc : TSetSearchDateRangeProcedure);
    procedure ApplicationEvent1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure EasyListview1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EasyListview1ItemSelectionChanged(
      Sender: TCustomEasyListview; Item: TEasyItem);
    Function ItemAtPos(X,Y : integer): TEasyItem;
    procedure FormCreate(Sender: TObject);
    procedure CloseLinkClick(Sender: TObject);
    procedure StartTimerTimer(Sender: TObject);
    procedure ApplyLinkClick(Sender: TObject);
    procedure DoSelect;
    procedure EasyListview1Resize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure EasyListview1GroupCollapse(Sender: TCustomEasyListview;
      Group: TEasyGroup);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    procedure LoadLanguage;
    procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;
    procedure WMSyscommand(var Message: TWmSysCommand); message WM_SYSCOMMAND;
    procedure CreateParams(var Params: TCreateParams); override;
    { Private declarations }
  public
    DS : TDataSet;
    DBInOpening : boolean;
    FDateFrom, FDateTo, FLastDate: TDateTime;
    FByLastDate: boolean;
    FProc : TSetSearchDateRangeProcedure;
    Loaded : Boolean;             
    Selecting : boolean;
    IsVisible : boolean;
    procedure UpdateTheme(Sender: TObject);
    { Public declarations }
  end;



implementation

uses UnitOpenQueryThread, Language;

{$R *.dfm}

procedure TFormDateRangeSelectDB.DBOpened(Sender: TObject);
begin
 DBInOpening:=false;
end;

procedure TFormDateRangeSelectDB.EasyListview1ItemClick(Sender: TCustomEasyListview;
  Item: TEasyItem; KeyStates: TCommonKeyStates;
  HitInfo: TEasyItemHitTestInfoSet);
var
  i : integer;
begin
 if not Item.Selected or ((EasyListview1.Selection.Count>1) and CtrlKeyDown) then
 begin
  if EasyListview1.Selection.First<>nil then
  begin
   for i:=0 to EasyListview1.Items.Count-1 do
   if EasyListview1.Items[i].Selected then
   EasyListview1.Items[i].Selected:=false;

  end
 end;
end;

procedure TFormDateRangeSelectDB.Execute(DateFrom, DateTo,
  LastDate: TDateTime; ByLastDate: boolean; Proc : TSetSearchDateRangeProcedure);
begin
 FDateFrom := DateFrom;
 FDateTo := DateTo;
 FLastDate := LastDate;
 FByLastDate := ByLastDate;
 FProc := Proc;
 if Loaded then DoSelect;   
 ShowWindow(Handle,SW_SHOWNOACTIVATE);
 Show;
 IsVisible:=true;
end;

procedure TFormDateRangeSelectDB.ApplicationEvent1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
 if msg.message=256 then
 if msg.wParam=17 then msg.message:=0;
end;
        
Function TFormDateRangeSelectDB.ItemAtPos(X,Y : integer): TEasyItem;
var
  r : TRect;
  i : integer;
begin
 Result:=nil;
 r :=  EasyListview1.Scrollbars.ViewableViewportRect;
 for i:=0 to EasyListview1.Groups.Count-1 do
 begin
  Result:=EasyListview1.Groups[0].ItemByPoint(Point(r.left+x,r.top+y));
  if Result<>nil then exit;
 end;
end;

procedure TFormDateRangeSelectDB.EasyListview1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Item : TEasyItem;
  i : integer;
begin
 if CtrlKeyDown then
 begin
  Item:=ItemAtPos(x,y);
  if not Item.Selected or ((EasyListview1.Selection.Count>1) and CtrlKeyDown) then
  begin
   if EasyListview1.Selection.First<>nil then
   begin
    for i:=0 to EasyListview1.Items.Count-1 do
    if EasyListview1.Items[i].Selected then
    EasyListview1.Items[i].Selected:=false;
   end;
  end;
 end;
end;

procedure TFormDateRangeSelectDB.FormCreate(Sender: TObject);
var
  IcoCancel : TIcon;
begin
 IsVisible:=false;
 Loaded:=false;
 Color:=Theme_ListColor;
 Panel1.Color:=Theme_ListColor;
 LoadLanguage;
 IcoCancel:=TIcon.Create;
 IcoCancel.Handle:=LoadIcon(HInstance,'CANCELACTION');
 CloseLink.Icon:=IcoCancel;
 IcoCancel.free;
 Selecting:=false;
 DBkernel.RecreateThemeToForm(self);

 EasyListview1.BackGround.Enabled:=true;
 EasyListview1.BackGround.Tile:=false;
 EasyListview1.BackGround.AlphaBlend:=true;
 EasyListview1.BackGround.OffsetTrack:=true;
 EasyListview1.BackGround.BlendAlpha:=220;
 EasyListview1.BackGround.Image:=TBitmap.create;
 EasyListview1.BackGround.Image.PixelFormat:=pf24bit;
 EasyListview1.BackGround.Image.Width:=100;
 EasyListview1.BackGround.Image.Height:=100;
 EasyListview1.BackGround.Image.Canvas.Brush.Color:=Theme_ListColor;
 EasyListview1.BackGround.Image.Canvas.Pen.Color:=Theme_ListColor;
 EasyListview1.BackGround.Image.Canvas.Rectangle(0,0,100,100);
 EasyListview1.BackGround.Image.Canvas.Draw(0,0,ImageBackGround.Picture.Graphic);
 DBKernel.RegisterForm(self);
 DBKernel.RegisterProcUpdateTheme(UpdateTheme,self);
end;

procedure TFormDateRangeSelectDB.EasyListview1ItemSelectionChanged(
      Sender: TCustomEasyListview; Item: TEasyItem);
begin
 if IsVisible then
 ApplyLinkClick(Sender);
end;

procedure TFormDateRangeSelectDB.LoadLanguage;
begin
 Caption:=TEXT_MES_CHOOSE_DATE_RANGE;

 CloseLink.Text:=TEXT_MES_CLOSE;
end;

procedure TFormDateRangeSelectDB.CloseLinkClick(Sender: TObject);
begin 
 ShowWindow(Handle,SW_HIDE);
 IsVisible:=false;
end;

procedure TFormDateRangeSelectDB.StartTimerTimer(Sender: TObject);
var
  i : integer;
  Date : TDateTime;
  CurrentYear : integer;
  CurrentMonth : integer;
begin
 StartTimer.Enabled:=false;
 DS:=GetQuery;
 SetSQL(DS,'Select distinct  DateToAdd from '+GetDefDBname+' where IsDate=true order by DateToAdd desc');
 DBInOpening:=true;
 TOpenQueryThread.Create(false,DS,DBOpened);
 Repeat
  Application.ProcessMessages;
  Application.ProcessMessages;
  Application.ProcessMessages;
  Application.ProcessMessages;
  Application.ProcessMessages;
  Application.ProcessMessages;
 Until not DBInOpening;
 DS.First;
 CurrentYear:=0;
 CurrentMonth:=0;

 EasyListview1.Header.Columns.Add.Width := 150;
 EasyListview1.Groups.BeginUpdate(false);
 for i:=1 to DS.RecordCount do
 begin
  Date:=DS.FieldByName('DAteToAdd').AsDateTime;
  if YearOf(Date)<>CurrentYear then
  begin         
   CurrentYear:=YearOf(Date);
   With EasyListview1.Groups.Add do
   begin
    Caption:=FormatDateTime('yyyy',Date);
    Visible:=true;
    Tag:=CurrentYear;
   end;
  end;

  Date:=DS.FieldByName('DateToAdd').AsDateTime;
  if MonthOf(Date)<>CurrentMonth then
  begin
   CurrentMonth:=MonthOf(Date);
   With EasyListview1.Items.Add do
   begin
    Caption:=FormatDateTime('mmmm',Date);
    Tag:=CurrentMonth;
   end;
  end;
  DS.Next;
 end;

 EasyListview1.Groups.EndUpdate;
 FreeDS(DS);
 Loaded:=true;
 DoSelect;
end;

procedure TFormDateRangeSelectDB.DoSelect;
var
  i, j : integer;
  Date : TDateTime;
begin
 Selecting:=true;
 for i:=0 to EasyListview1.Items.Count-1 do
 if EasyListview1.Items[i].Selected then
 EasyListview1.Items[i].Selected:=false;
 for i:=0 to EasyListview1.Groups.Count-1 do
 for j:=0 to EasyListview1.Groups[i].ItemCount-1 do
 if FByLastDate then
 begin
  Date:=EncodeDateTime(EasyListview1.Groups[i].Tag,EasyListview1.Groups[i].Item[j].Tag,1,0,0,0,0);
  if Date>=FLastDate then EasyListview1.Groups[i].Item[j].Selected:=true;
 end else
 begin
  Date:=EncodeDateTime(EasyListview1.Groups[i].Tag,EasyListview1.Groups[i].Item[j].Tag,1,0,0,0,0);
  if (Date>=Trunc(FDateFrom)) and (Date<Trunc(FDateTo)) then
  EasyListview1.Groups[i].Item[j].Selected:=true;
 end;
 Selecting:=false;
end;

procedure TFormDateRangeSelectDB.ApplyLinkClick(Sender: TObject);
var
  i,j : integer;
begin
 if Selecting then exit;
 FDateFrom:=0;
 FDateTo:=0;
 FByLastDate:=false;
 if EasyListview1.Selection.Count>1 then
 for i:=0 to EasyListview1.Groups.Count-1 do
 for j:=0 to EasyListview1.Groups[i].ItemCount-1 do
 begin
  if EasyListview1.Groups[i].Items[j].Selected then
  begin
   if FDateFrom=0 then

   if EasyListview1.Groups[i].Item[j].Tag<12 then
   FDateFrom:=EncodeDateTime(EasyListview1.Groups[i].Tag,EasyListview1.Groups[i].Item[j].Tag+1,1,0,0,0,0) else
   FDateFrom:=EncodeDateTime(EasyListview1.Groups[i].Tag+1,1,1,0,0,0,0);

  end;
  if not EasyListview1.Groups[i].Items[j].Selected then
  if FDateFrom<>0 then
  if FDateTo=0 then
  begin
   if EasyListview1.Groups[i].Item[j].Tag<12 then
   FDateTo:=EncodeDateTime(EasyListview1.Groups[i].Tag,EasyListview1.Groups[i].Item[j].Tag+1,1,0,0,0,0) else
   FDateTo:=EncodeDateTime(EasyListview1.Groups[i].Tag+1,1,1,0,0,0,0);
  end;
 end;
 if EasyListview1.Selection.Count=1 then
 begin
  FDateFrom:=EncodeDateTime(EasyListview1.Selection.First.OwnerGroup.Tag,EasyListview1.Selection.First.Tag,1,0,0,0,0);
   if EasyListview1.Selection.First.Tag<12 then
   FDateTo:=EncodeDateTime(EasyListview1.Selection.First.OwnerGroup.Tag,EasyListview1.Selection.First.Tag+1,1,0,0,0,0) else
   FDateTo:=EncodeDateTime(EasyListview1.Selection.First.OwnerGroup.Tag+1,1,1,0,0,0,0);
 end;
 if EasyListview1.Selection.Count=0 then
 begin
  FDateFrom:=EncodeDateTime(1990,1,1,0,0,0,0);
  FDateTo:=now;
 end;

 if EasyListview1.Groups.Count>0 then
 if EasyListview1.Groups[0].ItemCount>0 then
 if EasyListview1.Groups[0].Item[0].Selected then
 begin
  FByLastDate:=true;
                                                      
  for i:=0 to EasyListview1.Groups.Count-1 do
  for j:=0 to EasyListview1.Groups[i].ItemCount-1 do
  if EasyListview1.Groups[i].Item[j].Selected then
  FLastDate:=EncodeDateTime(EasyListview1.Groups[i].Item[j].OwnerGroup.Tag,EasyListview1.Groups[i].Item[j].Tag,1,0,0,0,0);
 end;
 FProc(Self,FDateFrom,FDateTo,FLastDate,FByLastDate);

end;

procedure TFormDateRangeSelectDB.EasyListview1Resize(Sender: TObject);
begin
 EasyListview1.BackGround.OffsetX:=EasyListview1.Width-EasyListview1.BackGround.Image.Width;
 EasyListview1.BackGround.OffsetY:=EasyListview1.Height-EasyListview1.BackGround.Image.Height;
end;

procedure TFormDateRangeSelectDB.UpdateTheme(Sender: TObject);
var
  b : TBitmap;
begin
  if EasyListview1<>nil then
  begin
   if EasyListview1.BackGround.Image<>nil then
   EasyListview1.BackGround.Image:=nil;
   b:=TBitmap.create;
   b.PixelFormat:=pf24bit;
   b.Width:=100;
   b.Height:=100;
   b.Canvas.Brush.Color:=EasyListview1.Color;
   b.Canvas.Pen.Color:=EasyListview1.Color;
   b.Canvas.Rectangle(0,0,100,100);
   b.Canvas.Draw(0,0,ImageBackGround.Picture.Graphic);
   EasyListview1.BackGround.Image:=b;
   b.Free;
  end;
end;

procedure TFormDateRangeSelectDB.FormDestroy(Sender: TObject);
begin
 DBKernel.UnRegisterProcUpdateTheme(UpdateTheme,self);  
 DBkernel.UnRegisterForm(self);
 try
  FreeDS(DS);
 except
 end;
end;

procedure TFormDateRangeSelectDB.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 IsVisible:=false;
end;

procedure TFormDateRangeSelectDB.EasyListview1GroupCollapse(
  Sender: TCustomEasyListview; Group: TEasyGroup);
begin
 Sender.Realign;
end;

procedure TFormDateRangeSelectDB.CreateParams(var Params: TCreateParams);
begin
 inherited CreateParams(Params);
 if IsWindowsVista then
 Params.ExStyle := Params.ExStyle and not WS_EX_TOOLWINDOW or WS_EX_APPWINDOW;
end;

procedure TFormDateRangeSelectDB.WMActivate(var Message: TWMActivate);
begin
 if (Message.Active = WA_ACTIVE) and not IsWindowEnabled(Handle) and IsWindowsVista then
 begin
  SetActiveWindow(Application.Handle);
  Message.Result := 0;
 end else
  inherited;
end;

procedure TFormDateRangeSelectDB.WMSyscommand(var Message: TWmSysCommand);
begin
  case (Message.CmdType and $FFF0) of
    SC_MINIMIZE:
    begin
      ShowWindow(Handle, SW_MINIMIZE);
      Message.Result := 0;
    end;
    SC_RESTORE:
    begin
      ShowWindow(Handle, SW_RESTORE);
      Message.Result := 0;
    end;
  else
    inherited;
  end;
end;

procedure TFormDateRangeSelectDB.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
 if Key = 27 then Close;
end;

end.
