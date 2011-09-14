unit uFormSelectPerson;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, WatermarkedEdit, ComCtrls, ImgList, uDBForm,
  uPeopleSupport, uBitmapUtils, uMemory, uMachMask, uGraphicUtils, CommCtrl;

type
  TFormFindPerson = class(TDBForm)
    WedPersonFilter: TWatermarkedEdit;
    LbFindPerson: TLabel;
    ImSearch: TImage;
    BtnOk: TButton;
    BtnCancel: TButton;
    LvPersons: TListView;
    TmrSearch: TTimer;
    ImlPersons: TImageList;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure WedPersonFilterChange(Sender: TObject);
    procedure TmrSearchTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOkClick(Sender: TObject);
    procedure LvPersonsDblClick(Sender: TObject);
  protected
    function GetFormID: string; override;
  private
    { Private declarations }
    FPersons: TPersonCollection;
    WndMethod: TWndMethod;
    function GetIndex(aNMHdr: pNMHdr): Integer;
    procedure CheckMsg(var aMsg: TMessage);
    procedure LoadList;
    procedure LoadLanguage;
  public
    { Public declarations }
    function Execute: TPerson;
  end;

implementation

{$R *.dfm}

function TFormFindPerson.GetFormID: string;
begin
  Result := 'SelectPerson';
end;

function TFormFindPerson.GetIndex(aNMHdr: pNMHdr): Integer;
var
  hHWND: HWND;
  HdItem: THdItem;
  iIndex: Integer;
  iResult: Integer;
  iLoop: Integer;
  sCaption: string;
  sText: string;
  Buf: array [0..128] of Char;
begin
  Result := -1;

  hHWND := aNMHdr^.hwndFrom;

  iIndex := pHDNotify(aNMHdr)^.Item;

  FillChar(HdItem, SizeOf(HdItem), 0);
  with HdItem do
  begin
    pszText    := Buf;
    cchTextMax := SizeOf(Buf) - 1;
    Mask       := HDI_TEXT;
  end;

  Header_GetItem(hHWND, iIndex, HdItem);

  with LvPersons do
  begin
    sCaption := Columns[iIndex].Caption;
    sText    := HdItem.pszText;
    iResult  := CompareStr(sCaption, sText);
    if iResult = 0 then
      Result := iIndex
    else
    begin
      iLoop := Columns.Count - 1;
      for iIndex := 0 to iLoop do
      begin
        iResult := CompareStr(sCaption, sText);
        if iResult <> 0 then
          Continue;

        Result := iIndex;
        break;
      end;
    end;
  end;
end;

procedure TFormFindPerson.BtnOkClick(Sender: TObject);
begin
  Close;
end;

procedure TFormFindPerson.CheckMsg(var aMsg: TMessage);
var
  HDNotify: ^THDNotify;
  NMHdr: pNMHdr;
  iCode: Integer;
  iIndex: Integer;
begin
  case aMsg.Msg of
    WM_NOTIFY:
      begin
        HDNotify := Pointer(aMsg.lParam);

        iCode := HDNotify.Hdr.code;
        if (iCode = HDN_BEGINTRACKW) or
          (iCode = HDN_BEGINTRACKA) then
        begin
          NMHdr := TWMNotify(aMsg).NMHdr;
          // chekck column index
          iIndex := GetIndex(NMHdr);
          // prevent resizing of columns if index's less than 3
          if iIndex < 3 then
            aMsg.Result := 1;
        end
        else
          WndMethod(aMsg);
      end;
    else
      WndMethod(aMsg);
  end;
end;


procedure TFormFindPerson.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

function TFormFindPerson.Execute: TPerson;
begin
  Result := nil;
  ShowModal;
  if LvPersons.Selected <> nil then
    Result := TPerson(LvPersons.Selected.Data);
end;

procedure TFormFindPerson.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LvPersons.WindowProc := WndMethod;
end;

procedure TFormFindPerson.FormCreate(Sender: TObject);
begin
  WndMethod := LvPersons.WindowProc;
  LvPersons.WindowProc := CheckMsg;
  LoadList;
  TmrSearchTimer(Self);
  LoadLanguage;
end;

procedure TFormFindPerson.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TFormFindPerson.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Select person');
    BtnOk.Caption := L('Ok');
    BtnCancel.Caption := L('Cancel');
    LvPersons.Column[0].Caption := L('Photo');
    LvPersons.Column[1].Caption := L('Name');
    LbFindPerson.Caption := L('Find person');
    WedPersonFilter.WatermarkText := L('Filter persons');
  finally
    EndTranslate;
  end;
end;

procedure TFormFindPerson.LoadList;
var
  W, H, I: Integer;
  P: TPerson;
  B, B32, SmallB, LB: TBitmap;
begin
  LvPersons.Clear;
  ImlPersons.Clear;

  FPersons := PersonManager.AllPersons;
  for I := 0 to FPersons.Count - 1 do
  begin
    P := FPersons[I];
    B := TBitmap.Create;
    try
      B.Assign(P.Image);
      W := B.Width;
      H := B.Height;
      SmallB := TBitmap.Create;
      try
        ProportionalSize(ImlPersons.Width - 4, ImlPersons.Height - 4, W, H);
        DoResize(W, H, B, SmallB);
        B32 := TBitmap.Create;
        try
          B32.PixelFormat := pf32Bit;
          DrawShadowToImage(B32, SmallB);

          LB := TBitmap.Create;
          try
            LB.PixelFormat := pf32bit;
            LB.SetSize(ImlPersons.Width, ImlPersons.Height);
            FillTransparentColor(LB, clWindow, 0);
            DrawImageEx32To32(LB, B32, ImlPersons.Width div 2 - B32.Width div 2, ImlPersons.Height div 2 - B32.Height div 2);
            ImlPersons.Add(LB, nil);
          finally
            F(LB);
          end;
        finally
          F(B32);
        end;
      finally
        F(SmallB);
      end;
    finally
      F(B);
    end;
  end;
end;

procedure TFormFindPerson.LvPersonsDblClick(Sender: TObject);
begin
  if LvPersons.Selected <> nil then
    Close;
end;

procedure TFormFindPerson.TmrSearchTimer(Sender: TObject);
var
  I: Integer;
  SearchTerm, Key: string;
  LI: TListItem;
  Visible: Boolean;
  P: TPerson;
begin
  TmrSearch.Enabled := False;

  if Sender <> Self then
    BeginScreenUpdate(Handle);
  LvPersons.Items.BeginUpdate;
  try
    LvPersons.Clear;

    SearchTerm := AnsiLowerCase(WedPersonFilter.Text);
    if Pos('*', SearchTerm) = 0 then
      SearchTerm := '*' + SearchTerm + '*';

    for I := 0 to FPersons.Count - 1 do
    begin
      P := FPersons[I];
      Key :=  AnsiLowerCase(P.Name + ' ' + P.Comment);
      Visible := IsMatchMask(Key, SearchTerm);

      if Visible then
      begin
        LI := LvPersons.Items.Add;
        LI.Caption := P.Name;
        LI.ImageIndex := LvPersons.Items.Count - 1;
        LI.SubItems.Add(P.Name + #13 + P.Comment);
        LI.Data := Pointer(P);
      end;
    end;

  finally
    LvPersons.Items.EndUpdate;
    if Sender <> Self then
      EndScreenUpdate(Handle, True);
  end;
end;

procedure TFormFindPerson.WedPersonFilterChange(Sender: TObject);
begin
  TmrSearch.Enabled := False;
  TmrSearch.Enabled := True;
end;

end.
