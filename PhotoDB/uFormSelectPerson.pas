unit uFormSelectPerson;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, WatermarkedEdit, ComCtrls, ImgList, uDBForm,
  uPeopleSupport, uBitmapUtils, uMemory, uMachMask, uGraphicUtils, CommCtrl,
  UnitDBDeclare, UnitDBKernel, LoadingSign, WebLink;

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
    LsAdding: TLoadingSign;
    WlCreatePerson: TWebLink;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure WedPersonFilterChange(Sender: TObject);
    procedure TmrSearchTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LvPersonsDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure WedPersonFilterKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LvPersonsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure WlCreatePersonClick(Sender: TObject);
  private
    { Private declarations }
    FPersons: TPersonCollection;
    WndMethod: TWndMethod;
    FInfo: TDBPopupMenuInfoRecord;
    FFormResult: Integer;
    function GetIndex(aNMHdr: pNMHdr): Integer;
    procedure CheckMsg(var aMsg: TMessage);
    procedure LoadList;
    procedure LoadLanguage;
    procedure EnableControls(IsEnabled: Boolean);
  protected
    function GetFormID: string; override;
    procedure CloseForm;
    procedure ChangedDBDataByID(Sender: TObject; ID: Integer; params: TEventFields; Value: TEventValues);
  public
    { Public declarations }
    function Execute(Info: TDBPopupMenuInfoRecord; var Person: TPerson): Integer;
  end;

const
  SELECT_PERSON_CANCEL     = 0;
  SELECT_PERSON_OK         = 1;
  SELECT_PERSON_CREATE_NEW = 2;

implementation

uses
  UnitUpdateDB;

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

procedure TFormFindPerson.CloseForm;
begin
  if (LvPersons.Selected <> nil) and (FInfo.ID = 0) then
  begin
    EnableControls(False);
    FInfo.Include := True;
    UpdaterDB.AddFileEx(FInfo, True, True);
    Exit;
  end;

  FFormResult := SELECT_PERSON_OK;
  Close;
end;

procedure TFormFindPerson.BtnOkClick(Sender: TObject);
begin
  if LvPersons.Selected <> nil then
  begin
    CloseForm;
    Exit;
  end;

  Close;
end;

procedure TFormFindPerson.ChangedDBDataByID(Sender: TObject; ID: Integer;
  params: TEventFields; Value: TEventValues);
begin
  if SetNewIDFileData in Params then
  begin
    if AnsiLowerCase(Value.name) = AnsiLowerCase(FInfo.FileName) then
    begin
      FInfo.ID := Value.ID;
      CloseForm;
    end;

  end;
  if EventID_CancelAddingImage in Params then
  begin
    if AnsiLowerCase(Value.name) = AnsiLowerCase(FInfo.FileName) then
      EnableControls(True);
  end;
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

procedure TFormFindPerson.EnableControls(IsEnabled: Boolean);
begin
  BtnOk.Enabled := IsEnabled;
  BtnCancel.Enabled := IsEnabled;
  LvPersons.Enabled := IsEnabled;
  WedPersonFilter.Enabled := IsEnabled;
  LsAdding.Visible := not IsEnabled;
end;

function TFormFindPerson.Execute(Info: TDBPopupMenuInfoRecord; var Person: TPerson): Integer;
begin
  FFormResult := SELECT_PERSON_CANCEL;
  FInfo := Info.Copy;
  ShowModal;
  if LvPersons.Selected <> nil then
    Person := TPerson(LvPersons.Selected.Data);

  Result := FFormResult;
end;

procedure TFormFindPerson.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LvPersons.WindowProc := WndMethod;
end;

procedure TFormFindPerson.FormCreate(Sender: TObject);
begin
  FInfo := nil;
  FFormResult := SELECT_PERSON_CANCEL;
  WndMethod := LvPersons.WindowProc;
  LvPersons.WindowProc := CheckMsg;
  LoadList;
  TmrSearchTimer(Self);
  LoadLanguage;
  DBKernel.RegisterChangesID(Self, ChangedDBDataByID);
  PersonManager.InitDB;
end;

procedure TFormFindPerson.FormDestroy(Sender: TObject);
begin
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
  F(FInfo);
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
    WlCreatePerson.Text := L('Close window and create new person');
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
  CloseForm;
end;

procedure TFormFindPerson.LvPersonsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  BtnOk.Enabled := (Item <> nil) and Selected;
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
  BtnOk.Enabled := False;

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
        LI.ImageIndex := I;
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

procedure TFormFindPerson.WedPersonFilterKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (LvPersons.Items.Count = 1) then
  begin
    Key := 0;
    LvPersons.Items[0].Selected := True;
    BtnOkClick(Sender);
  end;
end;

procedure TFormFindPerson.WlCreatePersonClick(Sender: TObject);
begin
  FFormResult := SELECT_PERSON_CREATE_NEW;
  Close;
end;

end.
