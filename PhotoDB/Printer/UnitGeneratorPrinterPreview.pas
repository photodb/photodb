unit UnitGeneratorPrinterPreview;

interface

uses
  Classes, Graphics, UnitPrinterTypes, Printers, PrinterProgress, Language;

type

 TOnEndGeneratePrinterPreviewEvent = procedure(Bitmap : TBitmap; SID : String) of object;

type
  TGeneratorPrinterPreview = class(TThread)
  private
  FSID : String;
  FFiles : TStrings;
  BitmapPreview : TBitmap;
  FOnEndProc : TOnEndGeneratePrinterPreviewEvent;
  FSampleType : TPrintSampleSizeOne;
  FDoPrint : Boolean;
  FPrintImagePerPage : integer;
  Pages : integer;
  IntParam : integer;
  StringParam : String;
  FSender : TObject;
  FormProgress : TFormPrinterProgress;
  FTerminating : Boolean;
  FOptions : TGenerateImageOptions;
  FVirtualBitmaped : Boolean;
  FVirtualBitmap : TBitmap;
  FDestroyBitmap : Boolean;
    { Private declarations }
  protected
    procedure Execute; override;
  public
   procedure SetImage;
   procedure PrintImage;
   constructor Create(CreateSuspennded: Boolean; Sender : TObject; SID : String; SampleType : TPrintSampleSizeOne; Files : TStrings; OnEndProc : TOnEndGeneratePrinterPreviewEvent;
   DoPrint : Boolean; Options : TGenerateImageOptions; PrintImagePerPage : integer; VirtualBitmaped : Boolean; VirtualBitmap : TBitmap; DestroyBitmap : Boolean);
   destructor Destroy; override;
   procedure SetMax(i : integer);
   procedure SetMaxSynch;
   procedure SetValue(i : integer);
   procedure SetValueSynch;
   procedure SetText(text : string);
   procedure SetCommentText(text : string);
   procedure SetTextSynch;
   Procedure CallBack(Progress : byte; var Terminate : boolean);
   procedure ShowProgress;
   procedure HideProgress;
   procedure SetProgress;
   procedure SetCommentTextCynch;
   procedure CallBackFull(Progress : byte; var Terminate : boolean);
   procedure ShowProgressWindow;
   procedure HideProgressWindow;
   procedure SetProgressWindowMax(Value : integer);
   procedure SetProgressWindowMaxSynch;
   procedure SetProgressWindowValue(Value : integer);
   procedure SetProgressWindowValueSynch;
  end;

implementation

uses PrintMainForm;

procedure TGeneratorPrinterPreview.Execute;
var
  j, i, Incr : integer;
  Files : TStrings;
begin
 if not FDoPrint then
 begin
  SetCommentText(TEXT_MES_GENERATING_PRINTER_PREVIEW);
  Synchronize(ShowProgress);
  FOptions.VirtualImage:=FVirtualBitmaped;
  FOptions.Image:=FVirtualBitmap;
  BitmapPreview:=GenerateImage(true,Printer.PageWidth,Printer.PageHeight,nil,FFiles,FSampleType,FOptions,CallBack);
  Synchronize(SetImage);
  Synchronize(HideProgress);
  SetCommentText('');
 end else
 begin
  Synchronize(ShowProgressWindow);
  if FOptions.FreeCenterSize then FPrintImagePerPage:=1;
  Pages:=(FFiles.Count div FPrintImagePerPage);
  if (FFiles.Count-Pages*FPrintImagePerPage)>0 then inc(Pages);
  Files := TStringList.Create;
  SetProgressWindowMax(Pages);
  if FVirtualBitmaped then Pages:=1;
  for i:=1 to Pages do
  begin
   if FTerminating then
   begin
    Break;
   end;
   SetProgressWindowValue(i);
   Files.Clear;
   Incr:=(i-1)*FPrintImagePerPage;
   for j:=1 to FPrintImagePerPage do
   if FFiles.Count>=j+Incr then
   Files.Add(FFiles[j+Incr-1]);
   FOptions.VirtualImage:=FVirtualBitmaped;
   FOptions.Image:=FVirtualBitmap;
   BitmapPreview:=GenerateImage(true,Printer.PageWidth,Printer.PageHeight,nil,Files,FSampleType,FOptions);
   if FDestroyBitmap then FOptions.Image.Free;
   if FTerminating then
   begin
    BitmapPreview.Free;
    Break;
   end;
   Synchronize(PrintImage);
   BitmapPreview.free;
  end;
  Synchronize(HideProgressWindow);
  Files.free;
 end;
end;

constructor TGeneratorPrinterPreview.Create(CreateSuspennded: Boolean; Sender : TObject; SID : String; SampleType : TPrintSampleSizeOne; Files : TStrings; OnEndProc : TOnEndGeneratePrinterPreviewEvent;
DoPrint : Boolean; Options : TGenerateImageOptions; PrintImagePerPage : integer; VirtualBitmaped : Boolean; VirtualBitmap : TBitmap; DestroyBitmap : Boolean);
begin
  inherited Create(False);
  FSID := SID;
  FSender := Sender;
  FFiles := TStringList.Create;
  FFiles.Assign(Files);
  FOnEndProc := OnEndProc;
  FSampleType := SampleType;
  FDoPrint := DoPrint;
  FPrintImagePerPage := PrintImagePerPage;
  FTerminating := False;
  FOptions := Options;
  FVirtualBitmaped := VirtualBitmaped;
  FVirtualBitmap := VirtualBitmap;
  FDestroyBitmap := DestroyBitmap;
end;

destructor TGeneratorPrinterPreview.Destroy;
begin
 FFiles.Free;
 inherited;
end;

procedure TGeneratorPrinterPreview.SetImage;
begin
 if PrintFormExists then
 begin
  If Assigned(FOnEndProc) then FOnEndProc(BitmapPreview,FSID) else BitmapPreview.Free;
 end else
 begin
  BitmapPreview.Free;
 end;
end;

procedure TGeneratorPrinterPreview.PrintImage;
begin
 Printer.BeginDoc;
 Printer.Canvas.Draw(0,0,BitmapPreview);
 Printer.EndDoc;
end;

procedure TGeneratorPrinterPreview.SetMax(i: integer);
begin
 IntParam := i;
 Synchronize(SetMaxSynch)
end;

procedure TGeneratorPrinterPreview.SetMaxSynch;
begin
//
end;

procedure TGeneratorPrinterPreview.SetText(text: string);
begin
//
end;

procedure TGeneratorPrinterPreview.SetTextSynch;
begin

end;

procedure TGeneratorPrinterPreview.SetValue(i: integer);
begin

end;

procedure TGeneratorPrinterPreview.SetValueSynch;
begin

end;

procedure TGeneratorPrinterPreview.CallBack(Progress: byte;
  var Terminate: boolean);
begin
 IntParam:=Progress;
 Synchronize(SetProgress);
 Terminate:= not PrintFormExists;
end;

procedure TGeneratorPrinterPreview.HideProgress;
begin
 if PrintFormExists then
 (FSender as TPrintForm).FStatusProgress.Hide;
end;

procedure TGeneratorPrinterPreview.ShowProgress;
begin
 if PrintFormExists then
 begin
  (FSender as TPrintForm).FStatusProgress.Position:=0;
  (FSender as TPrintForm).FStatusProgress.Max:=100;
  (FSender as TPrintForm).FStatusProgress.Show;
 end;
end;

procedure TGeneratorPrinterPreview.SetProgress;
begin
 if PrintFormExists then
 (FSender as TPrintForm).FStatusProgress.Position:=IntParam;
end;

procedure TGeneratorPrinterPreview.SetCommentText(text: string);
begin
 StringParam:=text;
 Synchronize(SetCommentTextCynch);
end;

procedure TGeneratorPrinterPreview.SetCommentTextCynch;
begin
 if PrintFormExists then
 (FSender as TPrintForm).StatusBar1.Panels[1].Text:=StringParam;
end;

procedure TGeneratorPrinterPreview.CallBackFull(Progress: byte;
  var Terminate: boolean);
begin
//
end;

procedure TGeneratorPrinterPreview.ShowProgressWindow;
begin
 FormProgress:=GetFormPrinterProgress;
 FormProgress.PValue:=@FTerminating;
 FormProgress.Show;
end;

procedure TGeneratorPrinterPreview.HideProgressWindow;
begin
 FormProgress.FCanClose:=true;
 FormProgress.Release;
 FormProgress.Free;
end;

procedure TGeneratorPrinterPreview.SetProgressWindowMax(Value: integer);
begin
 IntParam:=Value;
 Synchronize(SetProgressWindowMaxSynch);
end;

procedure TGeneratorPrinterPreview.SetProgressWindowMaxSynch;
begin
 FormProgress.PbPrinterProgress.MaxValue:=IntParam;
end;

procedure TGeneratorPrinterPreview.SetProgressWindowValue(Value: integer);
begin
 IntParam:=Value;
 Synchronize(SetProgressWindowValueSynch);
end;

procedure TGeneratorPrinterPreview.SetProgressWindowValueSynch;
begin
 FormProgress.PbPrinterProgress.Position:=IntParam;
end;

end.
