unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, win32crc, ComCtrls, ComboBoxExDB, DragDrop, UnitCDMappingSupport,
  DropTarget, DragDropFile, dm, ImgList, XPMan;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    ComboBoxExDB1: TComboBoxExDB;
    Button3: TButton;
    Edit1: TEdit;
    Button4: TButton;
    DropFileTarget1: TDropFileTarget;
    Button5: TButton;
    Edit2: TEdit;
    Button6: TButton;
    Edit3: TEdit;
    Label1: TLabel;
    Button7: TButton;
    Edit4: TEdit;
    Button8: TButton;
    ListView1: TListView;
    ImageList1: TImageList;
    XPManifest1: TXPManifest;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure DropFileTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      APoint: TPoint; var Effect: Integer);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
   procedure DrawCurrentDirectory(ListView : TListView);
    { Public declarations }
  end;

var
  Form1: TForm1;

var
  Mapping : TCDIndexMapping;

implementation

{$R *.dfm}

function SizeInTextA(Size : int64) : String;

function FloatToStrA(Value: Extended; round : integer): string;
var
  Buffer: array[0..63] of Char;
begin
  SetString(Result, Buffer, FloatToText(Buffer, Value, fvExtended, ffGeneral, round, 0));
end;

const
  TEXT_MES_BYTES = 'b';
  TEXT_MES_KB = 'kb';
  TEXT_MES_MB = 'mb';
  TEXT_MES_GB = 'gb';
begin
 if size<=1024 then result:=inttostr(size)+' '+TEXT_MES_BYTES;
 if (size>1024) and (size<=1024*999) then result:=FloatToStrA(size/1024,3)+' '+TEXT_MES_KB;
 if (size>1024*999) and (size<=1024*1024*999) then result:=FloatToStrA(size/(1024*1024),3)+' '+TEXT_MES_MB;
 if (size>1024*1024*999) then result:=FloatToStrA(size/(1024*1024*1024),3)+' '+TEXT_MES_GB;
end;

Procedure DDir(dir : String; Files : TStrings);
Var
 Found  : integer;
 SearchRec : TSearchRec;
begin
 Found := FindFirst(dir+'*.*', faAnyFile, SearchRec);
 while Found = 0 do
 begin
  if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
  begin
   If FileExists(dir+SearchRec.Name) then
   Files.Add(dir+SearchRec.Name);
  end else If DirectoryExists(dir+SearchRec.Name) then DDir(dir+SearchRec.Name, Files);
  Found := sysutils.FindNext(SearchRec);
 end;
 SysUtils.FindClose(SearchRec);
end;

//D:\Dmitry\My Pictures

procedure TForm1.Button1Click(Sender: TObject);
var
  FileList : TStrings;
begin
  FileList:= TStringList.Create;
  ddir('D:\Dmitry\My Pictures\',FileList);
  memo1.Lines.Assign(FileList);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 Mapping := TCDIndexMapping.Create;
 Mapping.CDLabel:='DISK';

 DrawCurrentDirectory(ListView1);

 DropFileTarget1.Register(ListView1);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
 Mapping.GoUp;                 
 Edit2.Text:=Mapping.GetCurrentPath;
 DrawCurrentDirectory(ListView1);
end;

procedure WriteCDIndexFile(FileName : string; Data : TCDDataArray);
var
  FS : TFileStream;
  Header : TCDIndexFileHeader;
  HeaderV1 : TCDIndexFileHeaderV1;
  CDRecord : TCDIndexFileRecordV1;
  i : integer;
begin
 FS:=TFileStream.Create(FileName,fmOpenWrite or fmCreate);
 Header.ID:='PHOTODB_INDEX';
 Header.Version:=1;
 Header.DBVersion:=0;
 FS.Write(Header,SizeOf(Header));    
 FillChar(HeaderV1,SizeOf(HeaderV1),#0);
 HeaderV1.Records:=Length(Data.Data);
 HeaderV1.CDLabel:=Data.CDName;
 FS.Write(HeaderV1,SizeOf(HeaderV1));
 for i:=0 to Length(Data.Data)-1 do
 begin
  CDRecord.Name:=Data.Data[i].Name;
  //CalcStringCRC32(Data.Data[i].CDRelativePath, Data.Data[i].OriginalPathCRC);
  //CDRecord.OriginalPathCRC:=Data.Data[i].OriginalPathCRC;
  CDRecord.CDRelativePathLength:=Length(Data.Data[i].CDRelativePath);
  FS.Write(CDRecord,SizeOf(CDRecord));
  FS.Write(Data.Data[i].CDRelativePath[1],SizeOf(CDRecord));
 end;
 FS.Free;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
 Data : TCDDataArray;
 FileList : TStrings;
begin
 FileList:= TStringList.Create;
 DDir('D:\Dmitry\My Pictures\',FileList);
 data.CDName:='My New CD with Photos!';

 WriteCDIndexFile('C:\1.cdindex',data);
end;      

procedure TForm1.Button3Click(Sender: TObject);
begin
 Mapping.CreateDirectory(Edit1.Text);
 DrawCurrentDirectory(ListView1);
end;

procedure TForm1.DropFileTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; APoint: TPoint; var Effect: Integer);
begin
 Mapping.AddRealItemsToCurrentDirectory(DropFileTarget1.Files);
 DrawCurrentDirectory(ListView1);
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  i : integer;
  Item : PCDIndexMappingDirectory;
begin
 for i:=ListView1.Items.Count-1 downto 0 do
 if ListView1.Items[i].Selected then
 begin
  Item:=ListView1.Items[i].Data;
  if Item.IsFile then
  Mapping.DeleteFile(Item.Name) else
  Mapping.DeleteDirectory(Item.Name);
 end;
 DrawCurrentDirectory(ListView1);
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
 Edit3.Text:=IntToStr((Mapping.GetCDSize div 1024) div 1024)+'Mb';
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
 Mapping.CreateStructureToDirectory(Edit4.Text);
end;

procedure TForm1.DrawCurrentDirectory(ListView : TListView);
var
  Level : PCDIndexMappingDirectory;
  i, Index : integer;
  Item : TListItem;
  Size : int64;
begin
 ListView.Items.BeginUpdate;
 ListView.Items.Clear;
 ImageList1.Clear;
 Level:=Mapping.CurrentLevel;
 if Level.Parent<>nil then
 begin
  Item:=ListView.Items.Add;
  Item.Caption:='[..]';
  Item.Data:=nil;
  Item.ImageIndex:=ImageList1.AddIcon(nil);
 end;
 for i:=0 to Level.Files.Count-1 do
 begin
  Item:=ListView.Items.Add;
  Item.Caption:=PCDIndexMappingDirectory(Level.Files[i]).Name;
  Item.Data:=Level.Files[i];
  Size:=Mapping.GetCDSizeWithDirectory(Level.Files[i]);
  if Size>0 then
  Item.SubItems.Add(SizeInTextA(Size));  
  Item.ImageIndex:=ImageList1.AddIcon(nil);
 end;
 ListView.Items.EndUpdate;
end;

procedure TForm1.ListView1DblClick(Sender: TObject);
var
  Level : PCDIndexMappingDirectory;
  Item : TListItem;
begin
 Item:=ListView1.Selected;
 if Item=nil then exit;

 if Item.Data=nil then
 begin
  Mapping.GoUp;    
  DrawCurrentDirectory(ListView1);
  exit;
 end;

 if Item.Data<>nil then
 if not PCDIndexMappingDirectory(Item.Data).IsFile then
 begin
  Mapping.SelectDirectory(PCDIndexMappingDirectory(Item.Data).Name);
  DrawCurrentDirectory(ListView1);
 end;
end;

end.
