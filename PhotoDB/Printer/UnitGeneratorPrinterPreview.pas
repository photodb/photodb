unit UnitGeneratorPrinterPreview;

interface

uses
  Classes,
  Graphics,
  UnitPrinterTypes,
  Printers,
  PrinterProgress,
  uTranslate,
  uMemory,
  uDBThread,
  uDBForm;

type
  TOnEndGeneratePrinterPreviewEvent = procedure(Bitmap: TBitmap; SID: string) of object;

type
  TGeneratorPrinterPreview = class(TDBThread)
  private
    { Private declarations }
    FSID: string;
    FFiles: TStrings;
    BitmapPreview: TBitmap;
    FOnEndProc: TOnEndGeneratePrinterPreviewEvent;
    FSampleType: TPrintSampleSizeOne;
    FDoPrint: Boolean;
    FPrintImagePerPage: Integer;
    Pages: Integer;
    IntParam: Integer;
    StringParam: string;
    FSender: TDBForm;
    FormProgress: TFormPrinterProgress;
    FTerminating: Boolean;
    FOptions: TGenerateImageOptions;
    FVirtualBitmaped: Boolean;
    FVirtualBitmap: TBitmap;
    FDestroyBitmap: Boolean;
  protected
    { Protected declarations }
    procedure Execute; override;
    function GetThreadID : string; override;
  public
    { Public declarations }
    procedure SetImage;
    procedure PrintImage;
    constructor Create(CreateSuspennded: Boolean; Sender: TDBForm; SID: string; SampleType: TPrintSampleSizeOne;
      Files: TStrings; OnEndProc: TOnEndGeneratePrinterPreviewEvent; DoPrint: Boolean; Options: TGenerateImageOptions;
      PrintImagePerPage: Integer; VirtualBitmaped: Boolean; VirtualBitmap: TBitmap; DestroyBitmap: Boolean);
    destructor Destroy; override;
    procedure SetMax(I: Integer);
    procedure SetMaxSynch;
    procedure SetValue(I: Integer);
    procedure SetValueSynch;
    procedure SetText(Text: string);
    procedure SetCommentText(Text: string);
    procedure SetTextSynch;
    procedure CallBack(Progress: Byte; var Terminate: Boolean);
    procedure ShowProgress;
    procedure HideProgress;
    procedure SetProgress;
    procedure SetCommentTextCynch;
    procedure CallBackFull(Progress: Byte; var Terminate: Boolean);
    procedure ShowProgressWindow;
    procedure HideProgressWindow;
    procedure SetProgressWindowMax(Value: Integer);
    procedure SetProgressWindowMaxSynch;
    procedure SetProgressWindowValue(Value: Integer);
    procedure SetProgressWindowValueSynch;
  end;

implementation

uses
  PrintMainForm;

procedure TGeneratorPrinterPreview.Execute;
var
  J, I, Incr: Integer;
  Files: TStrings;
begin
  inherited;
  FreeOnTerminate := True;
  if not FDoPrint then
  begin
    SetCommentText(L('Generating preview') + '...');
    SynchronizeEx(ShowProgress);
    FOptions.VirtualImage := FVirtualBitmaped;
    FOptions.Image := FVirtualBitmap;
    BitmapPreview := GenerateImage(True, Printer.PageWidth, Printer.PageHeight, nil, FFiles, FSampleType, FOptions,
      CallBack);
    SynchronizeEx(SetImage);
    SynchronizeEx(HideProgress);
    SetCommentText('');
  end else
  begin
    SynchronizeEx(ShowProgressWindow);
    if FOptions.FreeCenterSize then
      FPrintImagePerPage := 1;
    Pages := (FFiles.Count div FPrintImagePerPage);
    if (FFiles.Count - Pages * FPrintImagePerPage) > 0 then
      Inc(Pages);
    Files := TStringList.Create;
    try
      SetProgressWindowMax(Pages);
      if FVirtualBitmaped then
        Pages := 1;
      for I := 1 to Pages do
      begin
        if FTerminating then
          Break;

        SetProgressWindowValue(I);
        Incr := (I - 1) * FPrintImagePerPage;
        for J := 1 to FPrintImagePerPage do
          if FFiles.Count >= J + Incr then
            Files.Add(FFiles[J + Incr - 1]);
        FOptions.VirtualImage := FVirtualBitmaped;
        FOptions.Image := FVirtualBitmap;
        BitmapPreview := GenerateImage(True, Printer.PageWidth, Printer.PageHeight, nil, Files, FSampleType, FOptions);
        try
          if FDestroyBitmap then
            FOptions.Image.Free;
          if FTerminating then
            Break;

          SynchronizeEx(PrintImage);
        finally
          F(BitmapPreview);
        end;
      end;
      SynchronizeEx(HideProgressWindow);
    finally
      F(Files);
    end;
  end;
end;

function TGeneratorPrinterPreview.GetThreadID: string;
begin
  Result := 'Printer';
end;

constructor TGeneratorPrinterPreview.Create(CreateSuspennded: Boolean; Sender: TDBForm; SID: string;
  SampleType: TPrintSampleSizeOne; Files: TStrings; OnEndProc: TOnEndGeneratePrinterPreviewEvent; DoPrint: Boolean;
  Options: TGenerateImageOptions; PrintImagePerPage: Integer; VirtualBitmaped: Boolean; VirtualBitmap: TBitmap;
  DestroyBitmap: Boolean);
begin
  inherited Create(Sender, False);
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
  F(FFiles);
  inherited;
end;

procedure TGeneratorPrinterPreview.SetImage;
begin
  if Assigned(FOnEndProc) then
    FOnEndProc(BitmapPreview, FSID)
  else
    F(BitmapPreview);
end;

procedure TGeneratorPrinterPreview.PrintImage;
begin
  Printer.BeginDoc;
  Printer.Canvas.Draw(0, 0, BitmapPreview);
  Printer.EndDoc;
end;

procedure TGeneratorPrinterPreview.SetMax(I: Integer);
begin
  IntParam := I;
  SynchronizeEx(SetMaxSynch)
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

procedure TGeneratorPrinterPreview.CallBack(Progress: Byte; var Terminate: Boolean);
begin
  IntParam := Progress;
  SynchronizeEx(SetProgress);
end;

procedure TGeneratorPrinterPreview.HideProgress;
begin
  (FSender as TPrintForm).FStatusProgress.Hide;
end;

procedure TGeneratorPrinterPreview.ShowProgress;
begin
  (FSender as TPrintForm).FStatusProgress.Position := 0;
  (FSender as TPrintForm).FStatusProgress.Max := 100;
  (FSender as TPrintForm).FStatusProgress.Show;
end;

procedure TGeneratorPrinterPreview.SetProgress;
begin
  (FSender as TPrintForm).FStatusProgress.Position:=IntParam;
end;

procedure TGeneratorPrinterPreview.SetCommentText(Text: string);
begin
  StringParam := Text;
  SynchronizeEx(SetCommentTextCynch);
end;

procedure TGeneratorPrinterPreview.SetCommentTextCynch;
begin
  (FSender as TPrintForm).StatusBar1.Panels[1].Text := StringParam;
end;

procedure TGeneratorPrinterPreview.CallBackFull(Progress: byte;
  var Terminate: boolean);
begin
//
end;

procedure TGeneratorPrinterPreview.ShowProgressWindow;
begin
  FormProgress := GetFormPrinterProgress;
  FormProgress.PValue := @FTerminating;
  FormProgress.Show;
end;

procedure TGeneratorPrinterPreview.HideProgressWindow;
begin
  FormProgress.FCanClose := True;
  FormProgress.Release;
  FormProgress.Free;
end;

procedure TGeneratorPrinterPreview.SetProgressWindowMax(Value: Integer);
begin
  IntParam := Value;
  SynchronizeEx(SetProgressWindowMaxSynch);
end;

procedure TGeneratorPrinterPreview.SetProgressWindowMaxSynch;
begin
  FormProgress.PbPrinterProgress.MaxValue := IntParam;
end;

procedure TGeneratorPrinterPreview.SetProgressWindowValue(Value: Integer);
begin
  IntParam := Value;
  SynchronizeEx(SetProgressWindowValueSynch);
end;

procedure TGeneratorPrinterPreview.SetProgressWindowValueSynch;
begin
  FormProgress.PbPrinterProgress.Position := IntParam;
end;

end.
