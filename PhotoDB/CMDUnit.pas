unit CMDUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, dolphin_db, ComCtrls, ExtCtrls, AppEvnts, Clipbrd,
  uVistaFuncs, CommonDBSupport, UnitPasswordKeeper, ImgList,
  UnitDBDeclare, DmProgress, UnitDBCommonGraphics;

type
  TCMDForm = class(TForm)
    Label1: TLabel;
    Timer1: TTimer;
    ApplicationEvents1: TApplicationEvents;
    PasswordTimer: TTimer;
    InfoListBox: TListBox;
    TempProgress: TDmProgress;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure PasswordTimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure InfoListBoxMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure InfoListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private    
   PasswordKeeper : TPasswordKeeper;
   ItemsData : TList;
   Infos : TArStrings;
   FInfo : String;
   FProgressEnabled : boolean;
   Icons : array of TIcon;
   TopRecords : integer;
   CurrentWideIndex : integer;
    { Private declarations }
  public
  procedure PackPhotoTable;
  procedure ShowBadLinks;
  procedure RecreateImThInPhotoTable;  
  procedure OptimizeDublicates;
  procedure OnEnd(Sender : TObject);
  Procedure LoadLanguage;
  Procedure RestoreTable(FileName : String);
  Procedure BackUpTable;
  procedure WriteLine(Sender : TObject; Line : string; Info : integer);
  procedure WriteLnLine(Sender : TObject; Line : string; Info : integer);
  procedure LoadToolBarIcons;
  procedure ProgressCallBack(Sender : TObject; var Info : TProgressCallBackInfo); 
  procedure SetWideIndex;
    { Public declarations }
  end;

var
  CMDForm: TCMDForm;
  Working : Boolean = false;
  Recreating : Boolean;
  LineS : String;
  LineN : Integer;
  PointN : Integer = 0;
  CMD_Command_Break : boolean = false;


implementation

uses UnitRecreatingThInTable, UnitPackingTable, Language,
      UnitRestoreTableThread, UnitThreadShowBadLinks,
      UnitBackUpTableInCMD, UnitOptimizeDublicatesThread;

{$R *.dfm}

procedure TCMDForm.FormCreate(Sender: TObject);
begin
 CurrentWideIndex:=-1;
 FProgressEnabled:=false;
 FInfo:='';
 DoubleBuffered:=true;
 SetLength(Infos,0);
 ItemsData:=TList.Create;
 InfoListBox.DoubleBuffered:=true;
 InfoListBox.ItemHeight:=InfoListBox.Canvas.TextHeight('Iy')*3+5;
 InfoListBox.Clear;
 LoadToolBarIcons;
                     
 PasswordKeeper:=nil;
 Recreating:=false;
 WriteLnLine(Self,Format(TEXT_MES_WELCOME_FORMAT,[ProductName]),LINE_INFO_INFO);
 WriteLnLine(Self,'',LINE_INFO_GREETING);

 LoadLanguage;
end;

procedure TCMDForm.OnEnd(Sender: TObject);
begin
 Recreating:=false;
 Working:=false;
 Delay(1000);
 Close;
end;

procedure TCMDForm.PackPhotoTable;
var
  Options : TPackingTableThreadOptions;
begin
 TopRecords:=0;
 WriteLnLine(Self,TEXT_MES_PACKING_TABLE,LINE_INFO_INFO);
 WriteLnLine(Self,'['+dbname+']',LINE_INFO_DB);
 WriteLnLine(Self,TEXT_MES_PACKING_TABLE,LINE_INFO_OK);
 SetWideIndex;
 Timer1.Enabled:=True;
 Options.FileName:=DBName;
 Options.OnEnd:=OnEnd;
 Options.WriteLineProc:=WriteLine;
 PackingTable.Create(False,Options);
 Working:=True;
 CMDForm.ShowModal;
end;

procedure TCMDForm.Timer1Timer(Sender: TObject);
var
  i : integer;
  S : String;
begin
 If Working then
 begin
  if PointN=0 then
  begin
   LineN:=InfoListBox.Items.Count;
   LineS:=InfoListBox.Items[LineN-1];
  end;
  inc(PointN);
  If PointN>10 then PointN:=0;
  S:=LineS;
  For i:=1 to PointN do
  s:=s+'.';
  InfoListBox.Items[LineN-1]:=s;
 end;
end;

procedure TCMDForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 If Working then CanClose:=false;
 if Recreating then
 if ID_OK=MessageBoxDB(Handle,TEXT_MES_BREAK_RECREATING_TH,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
 begin
  CMD_Command_Break:=true;
 end;
end;

procedure TCMDForm.LoadLanguage;
begin
 Caption:=TEXT_MES_CMD_CAPTION;
 Label1.Caption:=TEXT_MES_CMD_TEXT;
end;

procedure TCMDForm.RecreateImThInPhotoTable;
var
 Options : TRecreatingThInTableOptions;
begin
 PasswordKeeper := TPasswordKeeper.Create;

 WriteLnLine(Self,TEXT_MES_RECREATING_TH_TABLE,LINE_INFO_INFO);
 WriteLnLine(Self,'['+dbname+']',LINE_INFO_DB);
 SetWideIndex;
 WriteLnLine(Self,TEXT_MES_RECREATING,LINE_INFO_INFO);
 WriteLnLine(Self,TEXT_MES_BEGIN_RECREATING_TH_TABLE,LINE_INFO_OK);

 TopRecords:=2;

 Timer1.Enabled:=false;
 Options.WriteLineProc:=WriteLine;
 Options.WriteLnLineProc:=WriteLnLine;
 Options.OnEndProcedure:=OnEnd;
 Options.FileName:=DBName;
 Options.GetFilesWithoutPassProc:=PasswordKeeper.GetActiveFiles;
 Options.AddCryptFileToListProc:=PasswordKeeper.AddCryptFileToListProc;
 Options.GetAvaliableCryptFileList:=PasswordKeeper.GetAvaliableCryptFileList;
 Options.OnProgress:=ProgressCallBack;
 FProgressEnabled:=true;
 RecreatingThInTable.Create(False,Options);
 Working:=True;
 Recreating:=True;
 CMDForm.ShowModal;
 PasswordKeeper.Free;
end;

procedure TCMDForm.RestoreTable(FileName : String);
var
  Options : TRestoreThreadOptions;
begin

 WriteLnLine(Self,TEXT_MES_RESTORING_TABLE,LINE_INFO_INFO);
 WriteLnLine(Self,'['+FileName+']',LINE_INFO_DB);
 WriteLnLine(Self,TEXT_MES_RESTORING,LINE_INFO_INFO);
 WriteLnLine(Self,TEXT_MES_BEGIN_RESTORING_TABLE,LINE_INFO_OK);
 SetWideIndex;

 Timer1.Enabled:=true;
 Options.WriteLineProc:=WriteLine;
 Options.OnEnd:=OnEnd;
 Options.FileName:=FileName;

 ThreadRestoreTable.Create(False,Options);
 Working:=True;
 Recreating:=True;
 CMDForm.ShowModal;
end;

procedure TCMDForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
 if not Active then Exit;
 if Msg.message=256 then
 begin
  if (Msg.wParam=Byte('B')) and CtrlKeyDown then CMD_Command_Break:=true;
 end;
 if Msg.hwnd=InfoListBox.Handle then
 if Msg.message<>15 then
 if Msg.message<>512 then
 if Msg.message<>160 then  
 if Msg.message<>161 then
 if Msg.message=522 then
 begin
  Msg.message:=0;
//  ShowMessage(IntToStr(Msg.message));
 end;
end;

procedure TCMDForm.ShowBadLinks;
var
   Options: TShowBadLinksThreadOptions;
begin
 WriteLnLine(Self,TEXT_MES_BAD_LINKS_TABLE,LINE_INFO_INFO);
 WriteLnLine(Self,'['+dbname+']',LINE_INFO_DB);
 SetWideIndex;
 WriteLnLine(Self,TEXT_MES_BAD_LINKS_TABLE_WORKING_1,LINE_INFO_INFO);
 WriteLnLine(Self,TEXT_MES_BAD_LINKS_TABLE_WORKING,LINE_INFO_OK);
 TopRecords:=2;

 Timer1.Enabled:=false;

 Options.WriteLineProc:=WriteLine;
 Options.WriteLnLineProc:=WriteLnLine;
 Options.OnEnd:=OnEnd;
 Options.FileName:=DBName;
 Options.OnProgress:=ProgressCallBack;
 FProgressEnabled:=true;

 TThreadShowBadLinks.Create(False, Options);
 Working:=True;
 Recreating:=true;
 CMDForm.ShowModal;
 TextToClipboard(InfoListBox.Items.Text);
end;

procedure TCMDForm.BackUpTable;
var
   Options: TBackUpTableThreadOptions;
begin

 WriteLnLine(Self,TEXT_MES_BACK_UP_TABLE,LINE_INFO_INFO);
 WriteLnLine(Self,'['+dbname+']',LINE_INFO_DB);
 WriteLnLine(Self,TEXT_MES_PROSESSING_,LINE_INFO_OK);
 SetWideIndex;
 TopRecords:=0;

 Options.WriteLineProc:=WriteLine;
 Options.WriteLnLineProc:=WriteLnLine;
 Options.OnEnd:=OnEnd;
 Options.FileName:=DBName;

 Timer1.Enabled:=false;
 BackUpTableInCMD.Create(False, Options);
 Working:=True;
 Recreating:=True;
 CMDForm.ShowModal;
end;

procedure TCMDForm.OptimizeDublicates;
var
   Options: TOptimizeDublicatesThreadOptions;
begin
 WriteLnLine(Self,TEXT_MES_OPTIMIZANG_DUBLICATES,LINE_INFO_INFO);
 WriteLnLine(Self,'['+dbname+']',LINE_INFO_DB);      
 SetWideIndex;
 WriteLnLine(Self,TEXT_MES_OPTIMIZANG_DUBLICATES_WORKING_1,LINE_INFO_INFO);
 WriteLnLine(Self,TEXT_MES_OPTIMIZANG_DUBLICATES_WORKING,LINE_INFO_OK);
 TopRecords:=2;
 
 Options.WriteLineProc:=WriteLine;
 Options.WriteLnLineProc:=WriteLnLine;
 Options.OnEnd:=OnEnd;
 Options.FileName:=DBName;
 Options.OnProgress:=ProgressCallBack;
 FProgressEnabled:=true;

 Timer1.Enabled:=false;
 TThreadOptimizeDublicates.Create(False,Options);
 Working:=True;
 Recreating:=true;
 CMDForm.ShowModal;
 TextToClipboard(InfoListBox.Items.Text);
end;

procedure TCMDForm.WriteLine(Sender: TObject; Line: string; Info : integer);
begin
 BeginScreenUpdate(Handle);
 PInteger(ItemsData[0])^:=Info;
 InfoListBox.Items[0]:=Line;
 EndScreenUpdate(Handle,false);
end;

procedure TCMDForm.WriteLnLine(Sender: TObject; Line: string; Info : integer);
var
  p : PInteger;
  i : integer;
begin
 if Info=LINE_INFO_INFO then
 begin
  FInfo:=Line;
  exit;
 end;
 LockWindowUpdate(Handle);
 SetLength(Infos,Length(Infos)+1);
 for i:=length(Infos)-2 downto TopRecords do
 begin
  Infos[i+1]:=Infos[i];
 end;
 Infos[ TopRecords]:=FInfo;

 GetMem(p,SizeOf(integer));
 p^:=Info;
 ItemsData.Insert( TopRecords,p);
 InfoListBox.Items.Insert( TopRecords,Line);

 FInfo:='';

 LockWindowUpdate(0);
end;

procedure TCMDForm.PasswordTimerTimer(Sender: TObject);
var
  PasswordList : TArCardinal;
  i : integer;
begin
 PasswordList:=nil;
 if PasswordKeeper=nil then exit;
 if PasswordKeeper.Count>0 then
 begin
  PasswordTimer.Enabled:=false;
  PasswordList:=PasswordKeeper.GetPasswords;
  for i:=0 to Length(PasswordList)-1 do
  begin
   PasswordKeeper.TryGetPasswordFromUser(PasswordList[i]);
  end;
  PasswordTimer.Enabled:=true;
 end;
end;

procedure TCMDForm.FormDestroy(Sender: TObject);
begin
 ItemsData.Free;
end;

procedure TCMDForm.LoadToolBarIcons;
var
  index : integer;

  procedure AddIcon(Name : String);
  begin
   Icons[index]:=TIcon.Create;
   Icons[index].Handle:=LoadIcon(DBKernel.IconDllInstance,PChar(Name));
   Inc(index);
  end;

begin
 index:=0;
 SetLength(Icons,7);
 AddIcon('CMD_OK');
 AddIcon('CMD_ERROR');
 AddIcon('CMD_WARNING');
 AddIcon('CMD_PLUS');
 AddIcon('CMD_PROGRESS');
 AddIcon('CMD_DB');
 AddIcon('ADMINTOOLS');
end;

procedure TCMDForm.ProgressCallBack(Sender: TObject;
  var Info: TProgressCallBackInfo);
begin
 if TempProgress.MaxValue<>Info.MaxValue then
 TempProgress.MaxValue:=Info.MaxValue;
 TempProgress.Position:=Info.Position;
end;

procedure TCMDForm.InfoListBoxMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
begin
 if Index=CurrentWideIndex then
 begin
//  CurrentWideIndex:=-1;
  Height:=InfoListBox.Canvas.TextHeight('Iy')*5+5
 end else
 Height:=InfoListBox.Canvas.TextHeight('Iy')*3+5;
end;

procedure TCMDForm.SetWideIndex;
begin
 CurrentWideIndex:=InfoListBox.Items.Count-2;
end;

procedure TCMDForm.InfoListBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
 DoInfoListBoxDrawItem(Control as TListBox,Index,Rect,State,
 ItemsData,Icons,FProgressEnabled,TempProgress,Infos);
end;

end.
