unit uPathProvideTreeView;

interface

uses
  Generics.Collections,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ActiveX,
  System.SysUtils,
  System.Classes,
  System.DateUtils,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Controls,
  Vcl.Graphics,
  VirtualTrees,
  Vcl.Themes,
  Vcl.ImgList,
  uMemory,

  Dmitry.Graphics.Types,
  Dmitry.PathProviders,
  Dmitry.PathProviders.MyComputer,
  Dmitry.PathProviders.Network,

  UnitBitmapImageList,

  uThreadForm,
  uGOM,
  uThreadTask,
  uMachMask,
  uConstants,
  {$IFDEF PHOTODB}
  uThemesUtils,
  uExplorerDateStackProviders,
  {$ENDIF}
  uVCLHelpers;

type
  PData = ^TData;
  TData = record
    Data: TPathItem;
  end;

  TOnSelectPathItem = procedure(Sender: TCustomVirtualDrawTree; PathItem: TPathItem) of object;

  TPathProvideTreeView = class(TCustomVirtualDrawTree)
  private
    FHomeItems: TPathItemCollection;
    FWaitOperationCount: Integer;
    FImTreeImages: TImageList;
    FImImages: TImageList;
    FForm: TThreadForm;
    FStartPathItem: TPathItem;
    FOnSelectPathItem: TOnSelectPathItem;
    FIsStarted: Boolean;
    FIsInitialized: Boolean;
    FIsInternalSelection: Boolean;
    FNodesToDelete: TList<TPathItem>;
    FImageList: TBitmapImageList;
    FBlockMouseMove: Boolean;
    FPopupItem: TPathItem;
    FOnlyFileSystem: Boolean;
    procedure LoadBitmaps;
    procedure StartControl;
    procedure InternalSelectNode(Node: PVirtualNode);
  protected
    procedure WndProc(var Message: TMessage); override;
    procedure DoPaintNode(var PaintInfo: TVTPaintInfo); override;
    procedure DoInitNode(Parent, Node: PVirtualNode; var InitStates: TVirtualNodeInitStates); override;
    function DoGetNodeWidth(Node: PVirtualNode; Column: TColumnIndex; Canvas: TCanvas = nil): Integer; override;
    procedure DoFreeNode(Node: PVirtualNode); override;
    procedure AddToSelection(Node: PVirtualNode); override;
    procedure DoInitChildren(Node: PVirtualNode; var ChildCount: Cardinal); override;
    function DoGetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var Index: Integer): TCustomImageList; override;
    function InitControl: Boolean;
    procedure DoPopupMenu(Node: PVirtualNode; Column: TColumnIndex; Position: TPoint); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadHomeDirectory(Form: TThreadForm);
    procedure SelectPathItem(PathItem: TPathItem);
    procedure SelectPath(Path: string);
    procedure DeletePath(Path: string);
    procedure AddItemToCalendar(Date: TDateTime);
    procedure SetFilter(Filter: string; Match: Boolean);
    procedure Reload;
    procedure RefreshPathItem(PathItem: TPathItem);
    property OnSelectPathItem: TOnSelectPathItem read FOnSelectPathItem write FOnSelectPathItem;
    property OnGetPopupMenu;
    property OnKeyAction;
    property PopupItem: TPathItem read FPopupItem;
    property OnlyFileSystem: Boolean read FOnlyFileSystem write FOnlyFileSystem default False;
  end;

{$R TreeView.res}

implementation

{ TPathProvideTreeView }

function FilterTree(Tree: TCustomVirtualDrawTree; Node: PVirtualNode;
  const Filter: string; Match: Boolean): Boolean;
var
  Data: PData;
  S: string;
  HideNode: Boolean;
begin
  Result := False;
  repeat

    Data := Tree.GetNodeData(Node);
    if Assigned(Data) and Assigned(Data.Data) then
    begin
      HideNode := True;
      S := Data.Data.DisplayName;
      if not Match then
        S := AnsiLowerCase(S);
      if (Filter = '') or IsMatchMask(S, Filter, False) then
      begin
        Result := True;
        HideNode := False;
      end;

      if (Node.ChildCount > 0) and (Tree.GetFirstChild(Node) <> nil) then
      begin
        if FilterTree(Tree, Tree.GetFirstChild(Node), Filter, Match) then
        begin
          Result := True;
          HideNode := False;
        end;
      end;
      Tree.IsFiltered[Node] := HideNode;

      Node := Node.NextSibling;
    end;
  until Node = nil;
end;

procedure TPathProvideTreeView.SetFilter(Filter: string; Match: Boolean);
begin
  BeginUpdate;
  try
    if not Match then
      Filter := AnsiLowerCase(Filter);

    FilterTree(Self, GetFirstChild(nil), Filter, Match);
  finally
    EndUpdate;
  end;
end;

function FindPathInTree(Tree: TCustomVirtualDrawTree; Node: PVirtualNode; Path: string): PVirtualNode;
var
  Data: PData;
begin
  Result := nil;
  if Node = nil then
    Exit(Result);

  repeat
    if ( Node.ChildCount > 0 ) and ( Tree.GetFirstChild( Node ) <> nil ) then
    begin
       Result := FindPathInTree( Tree, Tree.GetFirstChild( Node ), Path);
       if Result <> nil then
         Exit;
    end;

    Data := Tree.GetNodeData(Node);
    if (Data <> nil) and (Data.Data <> nil) and (AnsiLowerCase(ExcludeTrailingPathDelimiter(Data.Data.Path)) = Path) then
    begin
      Result := Node;
      Exit;
    end;

    Node := Node.NextSibling;
  until Node = nil;
end;

function FindInsertPlace(Tree: TCustomVirtualDrawTree; Node: PVirtualNode; PI: TPathItem): PVirtualNode;
var
  Data: PData;

  function FirstPathItemBiggerThenSecond(Item1, Item2: TPathItem): Boolean;
  begin
    Result := False;
    if (Item1 is TCalendarItem) and (Item2 is TCalendarItem) then
      Result := TCalendarItem(Item1).Order > TCalendarItem(Item2).Order;
  end;

begin
  Result := nil;

  repeat
    Data := Tree.GetNodeData(Node);

    if (Data <> nil) and (Data.Data <> nil) then
    begin
      if FirstPathItemBiggerThenSecond(PI, TPathItem(Data.Data)) then
        Exit;
    end;

    Result := Node;

    if Node <> nil then
      Node := Node.NextSibling;
  until Node = nil;
end;

procedure TPathProvideTreeView.AddItemToCalendar(Date: TDateTime);
var
  NeedRepainting: Boolean;
  Calendar: PVirtualNode;
  PrevNode: PVirtualNode;
  PI: TPathItem;

  function UpdateNode(Path: string): Boolean;
  var
    InsertPlaceNode,
    Node: PVirtualNode;
    Data: PData;
    ChildData: TData;
  begin
    Result := False;
    Node := FindPathInTree(Self, GetFirstChild( nil ), AnsiLowerCase(Path));
    if Node <> nil then
    begin
      Data := GetNodeData(Node);
      TCalendarItem(Data.Data).IntCount;
      NeedRepainting := True;
      Result := (vsHasChildren in Node.States) and (Node.ChildCount > 0);
      PrevNode := Node;
    end else
    begin
      PI := PathProviderManager.CreatePathItem(Path);
      if PI <> nil then
      begin
        TCalendarItem(PI).SetCount(1);

        ChildData.Data := PI;
        //image is required
        ChildData.Data.LoadImage(PATH_LOAD_FOR_IMAGE_LIST, 16);
        ChildData.Data.Tag := FImageList.AddPathImage(ChildData.Data.ExtractImage, True);

        InsertPlaceNode := FindInsertPlace(Self, GetFirstChild( PrevNode ), PI);
        if InsertPlaceNode = nil then
          Node := AddChild(PrevNode, Pointer(ChildData))
        else
          Node := InsertNode(InsertPlaceNode, amInsertAfter, Pointer(ChildData));

        ValidateNode(PrevNode, False);

        PrevNode := Node;
      end;
    end;
  end;

begin
  NeedRepainting := False;

  Calendar := FindPathInTree(Self, GetFirstChild( nil ), AnsiLowerCase(cDatesPath));
  if Calendar = nil then
    Exit;

  PrevNode := Calendar;
  if ((vsHasChildren in Calendar.States) and (Calendar.ChildCount > 0)) or (not (vsHasChildren in Calendar.States) and (Calendar.ChildCount = 0)) then
  begin
    if UpdateNode(cDatesPath + '\' + IntToStr(YearOf(Date))) then
    begin
      if UpdateNode(cDatesPath + '\' + IntToStr(YearOf(Date)) + '\' + IntToStr(MonthOf(Date))) then
      begin
        UpdateNode(cDatesPath + '\' + IntToStr(YearOf(Date)) + '\' + IntToStr(MonthOf(Date)) + '\' + IntToStr(DayOf(Date)));
      end;
    end;
  end;

  if NeedRepainting then
    Repaint;
end;

procedure TPathProvideTreeView.AddToSelection(Node: PVirtualNode);
var
  Data: PData;
begin
  inherited;

  Expanded[Node] := True;
  Repaint;
  if not FIsInternalSelection and Assigned(FOnSelectPathItem) then
  begin
    Data := GetNodeData(Node);
    FOnSelectPathItem(Self, Data.Data);
  end;
end;

type
  TCustomVirtualTreeOptionsEx = class(TCustomVirtualTreeOptions);

constructor TPathProvideTreeView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FOnlyFileSystem := False;
  FPopupItem := nil;
  FOnSelectPathItem := nil;
  FStartPathItem := nil;
  FNodesToDelete := TList<TPathItem>.Create;
  FImageList := TBitmapImageList.Create;

  AnimationDuration := 0;
  FIsStarted := False;
  FIsInitialized := False;
  FIsInternalSelection := False;

  {$IFDEF PHOTODB}
  Color := Theme.ListViewColor;
  Font.Color :=  StyleServices.GetStyleFontColor(sfListItemTextNormal);
  Colors.BorderColor := StyleServices.GetSystemColor(clBtnFace);
  Colors.DisabledColor := StyleServices.GetSystemColor(clBtnShadow);
  Colors.DropMarkColor := StyleServices.GetSystemColor(clHighlight);
  Colors.FocusedSelectionBorderColor := Theme.GradientToColor;
  Colors.FocusedSelectionColor := Theme.GradientFromColor;
  Colors.GridLineColor := StyleServices.GetSystemColor(clBtnFace);
  Colors.HotColor := StyleServices.GetSystemColor(clWindowText);
  Colors.SelectionRectangleBlendColor := StyleServices.GetSystemColor(clHighlight);
  Colors.SelectionRectangleBorderColor := StyleServices.GetSystemColor(clHighlight);
  Colors.SelectionTextColor := Theme.GradientText;
  Colors.TreeLineColor := StyleServices.GetSystemColor(clBtnShadow);
  Colors.UnfocusedSelectionBorderColor := Theme.GradientToColor;
  Colors.UnfocusedSelectionColor := Theme.GradientFromColor;
  {$ENDIF}
  {$IFNDEF PHOTODB}
  Color := StyleServices.GetStyleColor(scTreeView);
  Font.Color :=  StyleServices.GetStyleFontColor(sfTreeItemTextNormal);
  Colors.BorderColor := StyleServices.GetSystemColor(clBtnFace);
  Colors.DisabledColor := StyleServices.GetSystemColor(clBtnShadow);
  Colors.DropMarkColor := StyleServices.GetSystemColor(clHighlight);
  Colors.FocusedSelectionBorderColor := StyleServices.GetSystemColor(clHighlight);
  Colors.FocusedSelectionColor := StyleServices.GetSystemColor(clHighlight);
  Colors.GridLineColor := StyleServices.GetSystemColor(clBtnFace);
  Colors.HotColor := StyleServices.GetSystemColor(clWindowText);
  Colors.SelectionRectangleBlendColor := StyleServices.GetSystemColor(clHighlight);
  Colors.SelectionRectangleBorderColor := StyleServices.GetSystemColor(clHighlight);
  Colors.SelectionTextColor := StyleServices.GetStyleFontColor(sfTreeItemTextSelected);
  Colors.TreeLineColor := StyleServices.GetSystemColor(clBtnShadow);
  Colors.UnfocusedSelectionColor := StyleServices.GetSystemColor(clBtnFace);
  Colors.UnfocusedSelectionBorderColor := StyleServices.GetSystemColor(clBtnFace);
  {$ENDIF}

  FWaitOperationCount := 0;
  FHomeItems := TPathItemCollection.Create;

  FImImages := TImageList.Create(nil);
  FImTreeImages := TImageList.Create(nil);
  FImTreeImages.ColorDepth := cd32Bit;
  Images := FImImages;
end;

procedure TPathProvideTreeView.DeletePath(Path: string);
var
  Node: PVirtualNode;
begin
  Path := AnsiLowerCase(ExcludeTrailingPathDelimiter(Path));
  Node := FindPathInTree(Self, GetFirstChild( nil ), Path);
  if Node <> nil then
    DeleteNode(Node);
end;

destructor TPathProvideTreeView.Destroy;
begin
  Clear;
  FHomeItems.FreeItems;
  F(FHomeItems);
  F(FStartPathItem);
  F(FImTreeImages);
  F(FImImages);
  FreeList(FNodesToDelete);
  F(FImageList);
  F(FPopupItem);
  inherited;
end;

type
  TLoadChildsInfo = class
    Node: PVirtualNode;
    Data: PData;
  end;

procedure TPathProvideTreeView.DoFreeNode(Node: PVirtualNode);
var
  Data: PData;
begin
  Data := GetNodeData(Node);
  Data.Data.Free;
  inherited;
end;

function TPathProvideTreeView.DoGetImageIndex(Node: PVirtualNode;
  Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
  var Index: Integer): TCustomImageList;
var
  Data: PData;
begin
  Result := inherited DoGetImageIndex(Node, Kind, Column, Ghosted, Index);
  if Result <> nil then
    Exit;

  Data := GetNodeData(Node);

  FImTreeImages.Clear;
  Result := FImTreeImages;

  if (Data.Data <> nil) and (Data.Data.Tag > -1) and (Data.Data.Tag < FImageList.Count) then
    FImageList[Data.Data.Tag].AddToImageList(FImTreeImages);

  Index := FImTreeImages.Count - 1;
end;

function TPathProvideTreeView.DoGetNodeWidth(Node: PVirtualNode;
  Column: TColumnIndex; Canvas: TCanvas): Integer;
var
  Data: PData;
  AMargin: Integer;
begin
  AMargin := TextMargin;
  Data := GetNodeData(Node);
  Result := Self.Canvas.TextWidth(Data.Data.DisplayName) + 2 * AMargin;
end;

procedure TPathProvideTreeView.DoInitNode(Parent, Node: PVirtualNode;
  var InitStates: TVirtualNodeInitStates);
var
  TreeData: PData;
begin
  inherited;
  TreeData := GetNodeData(Node);
  if Parent = nil then
  begin
    if Node.Index < FHomeItems.Count then
    begin
      TreeData.Data := FHomeItems[Node.Index].Copy;
      TreeData.Data.Tag := FImageList.AddPathImage(TreeData.Data.ExtractImage, True);
    end;
  end;

  if TreeData.Data.IsDirectory and TreeData.Data.CanHaveChildren then
    Include(InitStates, ivsHasChildren);
end;

procedure TPathProvideTreeView.DoPaintNode(var PaintInfo: TVTPaintInfo);
var
  Data: PData;
  S: string;
  R: TRect;
begin
  inherited;
  with PaintInfo do
  begin
    Data := GetNodeData(Node);
    if (Column = FocusedColumn) and (Node = FocusedNode) then
      Canvas.Font.Color := Theme.GradientText
    else
      Canvas.Font.Color := Theme.ListViewFontColor;

    SetBKMode(Canvas.Handle, TRANSPARENT);

    R := ContentRect;
    InflateRect(R, -TextMargin, 0);
    Dec(R.Right);
    Dec(R.Bottom);

    S := Data.Data.DisplayName;
    if Length(S) > 0 then
    begin
      with R do
      begin
        if (NodeWidth - 2 * Margin) > (Right - Left) then
          S := ShortenString(Canvas.Handle, S, Right - Left);
      end;
      DrawTextW(Canvas.Handle, PWideChar(S), Length(S), R, DT_TOP or DT_LEFT or DT_VCENTER or DT_SINGLELINE);
    end;

  end;
end;

procedure TPathProvideTreeView.DoPopupMenu(Node: PVirtualNode;
  Column: TColumnIndex; Position: TPoint);
var
  Data: PData;
begin
  FBlockMouseMove := True;
  try
    Data := GetNodeData(Node);
    F(FPopupItem);
    if Data <> nil then
      FPopupItem := Data.Data.Copy;
    inherited;
  finally
    FBlockMouseMove := False;
  end;
end;

function TPathProvideTreeView.InitControl: Boolean;
begin
  Result := not FIsInitialized;
  if FIsInitialized then
    Exit;
  FIsInitialized := True;
  NodeDataSize := SizeOf(TData);
  DrawSelectionMode := smBlendedRectangle;
  LineMode := lmBands;
  TCustomVirtualTreeOptionsEx(TreeOptions).AnimationOptions := [toAnimatedToggle, toAdvancedAnimatedToggle];
  TCustomVirtualTreeOptionsEx(TreeOptions).PaintOptions := [toHotTrack, toShowButtons, toShowDropmark, toShowRoot, toUseBlendedImages, toUseBlendedSelection, toStaticBackground, toHideTreeLinesIfThemed];
  TCustomVirtualTreeOptionsEx(TreeOptions).SelectionOptions := [toExtendedFocus, toFullRowSelect];
  LoadBitmaps;
end;

procedure TPathProvideTreeView.InternalSelectNode(Node: PVirtualNode);
begin
  FIsInternalSelection := True;
  try
    Selected[Node] := True;
  finally
    FIsInternalSelection := False;
  end;
end;

procedure TPathProvideTreeView.LoadBitmaps;

  procedure ApplyColor(Bitmap: TBitmap; Color: TColor);
  var
    I, J: Integer;
    P: PARGB32;
    R, G, B: Byte;
  begin
    Color := ColorToRGB(Color);
    R := GetRValue(Color);
    G := GetGValue(Color);
    B := GetBValue(Color);
    for I := 0 to Bitmap.Height - 1 do
    begin
      P := Bitmap.ScanLine[I];
      for J := 0 to Bitmap.Width - 1 do
      begin
        P[J].R := R;
        P[J].G := G;
        P[J].B := B;
      end;
    end;
  end;

  procedure LoadFromRes(Bitmap: TBitmap; Name: string; Color: TColor);
  begin
    Bitmap.AlphaFormat := afIgnored;
    Bitmap.LoadFromResourceName(hInstance, Name);
    ApplyColor(Bitmap, Color);
    Bitmap.AlphaFormat := afDefined;
  end;

begin
  LoadFromRes(HotMinusBM, 'TREE_VIEW_OPEN_HOT', StyleServices.GetSystemColor(clHighlight));
  LoadFromRes(HotPlusBM, 'TREE_VIEW_CLOSE_HOT', StyleServices.GetSystemColor(clHighlight));

  LoadFromRes(MinusBM, 'TREE_VIEW_OPEN', StyleServices.GetStyleFontColor(sfTreeItemTextNormal));
  LoadFromRes(PlusBM, 'TREE_VIEW_CLOSE', StyleServices.GetStyleFontColor(sfTreeItemTextNormal));
end;

procedure TPathProvideTreeView.SelectPath(Path: string);
var
  PI: TPathItem;
begin
  PI := PathProviderManager.CreatePathItem(Path);
  try
    if PI <> nil then
      SelectPathItem(PI);
  finally
    F(PI);
  end;
end;

procedure TPathProvideTreeView.SelectPathItem(PathItem: TPathItem);
var
  Data: PData;
  PathParts: TList<TPathItem>;
  PathPart: TPathItem;
  I: Integer;
  R: TRect;
  Node, ChildNode, SelectedNode: PVirtualNode;
  ChildData: TData;

  function FindChild(Node: PVirtualNode; PathItem: TPathItem): PVirtualNode;
  var
    Data: PData;
    S: string;
  begin
    Result := nil;
    S := ExcludeTrailingPathDelimiter(AnsiLowerCase(PathItem.Path));
    Node := Node.FirstChild;
    while Node <> nil do
    begin
      Data := GetNodeData(Node);
      if ExcludeTrailingPathDelimiter(AnsiLowerCase(Data.Data.Path)) = S then
        Exit(Node);

      Node := Node.NextSibling;
    end;
  end;

begin
  if not FIsStarted then
  begin
    F(FStartPathItem);
    FStartPathItem := PathItem.Copy;
    Exit;
  end;

  SelectedNode := GetFirstSelected;
  if SelectedNode <> nil then
  begin
    Data := GetNodeData(SelectedNode);
    if ExcludeTrailingPathDelimiter(AnsiLowerCase(Data.Data.Path)) = ExcludeTrailingPathDelimiter(AnsiLowerCase(PathItem.Path)) then
      Exit;
  end;

  if PathItem is THomeItem then
  begin
    ClearSelection;
    Exit;
  end;

  PathPart := PathItem;
  PathParts := TList<TPathItem>.Create;
  try
    while (PathPart <> nil) do
    begin
      PathParts.Insert(0, PathPart.Copy);
      PathPart := PathPart.Parent;
    end;

    Node := RootNode;

    BeginUpdate;
    try
      //skip home item
      for I := 1 to PathParts.Count - 1 do
      begin
        ChildNode := FindChild(Node, PathParts[I]);
        if ChildNode <> nil then
        begin
          Expanded[ChildNode] := True;
          if I = PathParts.Count - 1 then
          begin
            InternalSelectNode(ChildNode);
            R := GetDisplayRect(ChildNode, -1, False);
            InflateRect(R, -1, -1);
            if not (PtInRect(ClientRect, R.TopLeft) and PtInRect(ClientRect, R.BottomRight)) then
              TopNode := ChildNode;
          end;
        end else
        begin
          ChildData.Data := PathParts[I].Copy;
          ChildData.Data.Tag := FImageList.AddPathImage(ChildData.Data.ExtractImage, True);
          ChildNode := AddChild(Node, Pointer(ChildData));
          ValidateNode(Node, False);
          InternalSelectNode(ChildNode);
        end;
        Node := ChildNode;
      end;
    finally
      EndUpdate;
    end;
  finally
    FreeList(PathParts);
  end;
end;

procedure TPathProvideTreeView.StartControl;
begin
  if FStartPathItem <> nil then
  begin
    FIsStarted := True;
    SelectPathItem(FStartPathItem);
    F(FStartPathItem);
  end;
end;

procedure TPathProvideTreeView.WndProc(var Message: TMessage);
begin
  if FBlockMouseMove then
  begin
    //popup hover fix
    if (Message.Msg = WM_ENABLE)
      or (Message.Msg = WM_SETFOCUS)
      or (Message.Msg = WM_KILLFOCUS)
      or (Message.Msg = WM_MOUSEMOVE)
      or (Message.Msg = WM_RBUTTONDOWN)
      or (Message.Msg = WM_RBUTTONUP)
      or (Message.Msg = WM_MOUSELEAVE) then
      Message.Msg := 0;
  end;
  inherited;
end;

procedure TPathProvideTreeView.LoadHomeDirectory(Form: TThreadForm);
begin
  if not InitControl then
    Exit;

  FForm := Form;
  TThreadTask.Create(FForm, Pointer(nil),
    procedure(Thread: TThreadTask; Data: Pointer)
    var
      Home: THomeItem;
      Roots: TPathItemCollection;
      Options: Integer;
    begin
      CoInitialize(nil);
      try
        Home := THomeItem.Create;
        try
          Roots := TPathItemCollection.Create;
          try
            Options := PATH_LOAD_DIRECTORIES_ONLY or PATH_LOAD_FOR_IMAGE_LIST or PATH_LOAD_CHECK_CHILDREN;
            if FOnlyFileSystem then
              Options := Options or PATH_LOAD_ONLY_FILE_SYSTEM;

            Home.Provider.FillChildList(Thread, Home, Roots, Options, 16, 2,
              procedure(Sender: TObject; Item: TPathItem; CurrentItems: TPathItemCollection; var Break: Boolean)
              begin
                TThread.Synchronize(nil,
                  procedure
                  var
                    I: Integer;
                  begin
                    if GOM.IsObj(Thread.ThreadForm) then
                    begin
                      for I := 0 to CurrentItems.Count - 1 do
                        FHomeItems.Add(CurrentItems[I]);

                      RootNodeCount := FHomeItems.Count;
                    end;
                  end
                );
                CurrentItems.Clear;
              end
            );
            TThread.Synchronize(nil,
              procedure
              begin
                if GOM.IsObj(Thread.ThreadForm) then
                  StartControl;
              end
            );
          finally
            F(Roots);
          end;
        finally
          F(Home);
        end;
      finally
        CoUninitialize;
      end;
    end
  );
end;

procedure TPathProvideTreeView.RefreshPathItem(PathItem: TPathItem);
var
  Node: PVirtualNode;
begin
  Node := FindPathInTree(Self, GetFirstChild( nil ), AnsiLowerCase(ExcludeTrailingPathDelimiter(PathItem.Path)));
  if Node <> nil then
  begin
    DeleteChildren(Node, True);
    ReinitNode(Node, False);
    Expanded[Node] := True;
  end;
end;

procedure TPathProvideTreeView.Reload;
begin
  FIsStarted := False;
  FIsInitialized := False;
  Clear;
  RootNodeCount := 0;
  FHomeItems.FreeItems;
  FreeList(FNodesToDelete, False);
  LoadHomeDirectory(FForm);
end;

procedure TPathProvideTreeView.DoInitChildren(Node: PVirtualNode;
  var ChildCount: Cardinal);
var
  AInfo: TLoadChildsInfo;
begin
  inherited;
  AInfo := TLoadChildsInfo.Create;
  AInfo.Node := Node;
  AInfo.Data := GetNodeData(Node);
  Cursor := crAppStart;

  TThreadTask.Create(FForm, AInfo,
    procedure(Thread: TThreadTask; Data: Pointer)
    var
      Roots: TPathItemCollection;
      Info: TLoadChildsInfo;
      ParentItem: TPathItem;
      IsFirstItem: Boolean;
      Options: Integer;
    begin
      CoInitialize(nil);
      try
        Inc(FWaitOperationCount);
        Info := TLoadChildsInfo(Data);
        IsFirstItem := True;
        try
          Roots := TPathItemCollection.Create;
          try
            //copy item because this item could be freed on form close
            ParentItem := Info.Data.Data.Copy;
            try

              Options := PATH_LOAD_DIRECTORIES_ONLY or PATH_LOAD_FOR_IMAGE_LIST or PATH_LOAD_CHECK_CHILDREN;
              if FOnlyFileSystem then
                Options := Options or PATH_LOAD_ONLY_FILE_SYSTEM;

              ParentItem.Provider.FillChildList(Thread, ParentItem, Roots, Options, 16, 10,
                procedure(Sender: TObject; Item: TPathItem; CurrentItems: TPathItemCollection; var Break: Boolean)
                begin
                  Thread.Synchronize(nil,
                    procedure
                    var
                      I: Integer;
                      ChildData: TData;
                      SearchPath: string;
                      NodeData: PData;
                    begin
                      if GOM.IsObj(Thread.ThreadForm) then
                      begin
                        SearchPath := '';
                        if Info.Node.ChildCount > 0 then
                          SearchPath := ExcludeTrailingPathDelimiter(AnsiLowerCase(PData(GetNodeData(Info.Node.FirstChild)).Data.Path));

                        InterruptValidation;
                        BeginUpdate;
                        try
                          for I := 0 to CurrentItems.Count - 1 do
                          begin

                            if SearchPath = ExcludeTrailingPathDelimiter(AnsiLowerCase(CurrentItems[I].Path)) then
                            begin
                              MoveTo(Info.Node.FirstChild, Info.Node, amAddChildLast, False);
                              ValidateCache;

                              NodeData := GetNodeData(Info.Node.LastChild);

                              //node without image, shouldn't affect to GDI counter
                              //this list will be deleted on destroy
                              //without this line will be AV :(
                              FNodesToDelete.Add(NodeData.Data);

                              NodeData.Data := CurrentItems[I];
                              //image is required
                              NodeData.Data.Image;
                              NodeData.Data.Tag := FImageList.AddPathImage(NodeData.Data.ExtractImage, True);

                              TopNode := GetFirstSelected;
                            end else
                            begin
                              ChildData.Data := CurrentItems[I];
                              //image is required
                              ChildData.Data.Image;
                              ChildData.Data.Tag := FImageList.AddPathImage(ChildData.Data.ExtractImage, True);
                              AddChild(Info.Node, Pointer(ChildData));
                              ValidateNode(Info.Node, False);
                            end;
                          end;

                          if (CurrentItems.Count > 0) and IsFirstItem then
                          begin
                            IsFirstItem := False;
                            Expanded[Node] := True;
                          end;
                        finally
                          EndUpdate;
                        end;
                      end;
                    end
                  );
                  CurrentItems.Clear;
                end
              );
            finally
              F(ParentItem);
            end;
          finally
            F(Roots);
          end;
        finally
          F(Info);

          TThread.Synchronize(nil,
            procedure
            begin
              if GOM.IsObj(Thread.ThreadForm) then
              begin
                Dec(FWaitOperationCount);
                if FWaitOperationCount = 0 then
                  Cursor := crDefault;
              end;
            end
          );
        end;
      finally
        CoUninitialize;
      end;
    end
  );
end;

initialization
  TCustomStyleEngine.RegisterStyleHook(TPathProvideTreeView, TScrollingStyleHook);

end.
