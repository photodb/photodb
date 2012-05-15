unit uPathProvideTreeView;

interface

uses
  Generics.Collections,
  Windows,
  SysUtils,
  Forms,
  Dialogs,
  Controls,
  Graphics,
  Classes,
  VirtualTrees,
  Themes,
  Vcl.ImgList,
  ActiveX,
  uMemory,
  uThreadForm,
  GraphicsBaseTypes,
  uPathProviders,
  uGOM,
  uThreadTask,
  uMachMask,
  {$IFDEF PHOTODB}
  uThemesUtils,
  {$ENDIF}
  uExplorerNetworkProviders,
  uExplorerMyComputerProvider;

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
    procedure LoadBitmaps;
    procedure StartControl;
    procedure InternalSelectNode(Node: PVirtualNode);
  protected
    procedure DoPaintNode(var PaintInfo: TVTPaintInfo); override;
    procedure DoInitNode(Parent, Node: PVirtualNode; var InitStates: TVirtualNodeInitStates); override;
    function DoGetNodeWidth(Node: PVirtualNode; Column: TColumnIndex; Canvas: TCanvas = nil): Integer; override;
    procedure DoFreeNode(Node: PVirtualNode); override;
    procedure AddToSelection(Node: PVirtualNode); override;
    procedure DoInitChildren(Node: PVirtualNode; var ChildCount: Cardinal); override;
    function DoGetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var Index: Integer): TCustomImageList; override;
    function InitControl: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadHomeDirectory(Form: TThreadForm);
    procedure SelectPathItem(PathItem: TPathItem);
    procedure SelectPath(Path: string);
    procedure DeletePath(Path: string);
    procedure SetFilter(Filter: string; Match: Boolean);
    procedure Reload;
    property OnSelectPathItem: TOnSelectPathItem read FOnSelectPathItem write FOnSelectPathItem;
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
  repeat
    if ( Node.ChildCount > 0 ) and ( Tree.GetFirstChild( Node ) <> nil ) then
       Result := FindPathInTree( Tree, Tree.GetFirstChild( Node ), Path);

    Data := Tree.GetNodeData(Node);
    if (Data <> nil) and (Data.Data <> nil) and (AnsiLowerCase(ExcludeTrailingPathDelimiter(Data.Data.Path)) = Path) then
      Result := Node;

    Node := Node.NextSibling;
  until Node = nil;
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

  FOnSelectPathItem := nil;
  FStartPathItem := nil;
  FNodesToDelete := TList<TPathItem>.Create;

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

  if (Data.Data <> nil) and (Data.Data.Image <> nil) then
    Data.Data.Image.AddToImageList(FImTreeImages);

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
    TreeData.Data := FHomeItems[Node.Index].Copy;

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
    begin
      CoInitialize(nil);
      try
        Home := THomeItem.Create;
        try
          Roots := TPathItemCollection.Create;
          try
            Home.Provider.FillChildList(Thread, Home, Roots, PATH_LOAD_DIRECTORIES_ONLY or PATH_LOAD_FOR_IMAGE_LIST or PATH_LOAD_CHECK_CHILDREN, 16, 2,
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
    begin
      CoInitialize(nil);
      try
        Inc(FWaitOperationCount);
        Info := TLoadChildsInfo(Data);
        IsFirstItem := True;
        try
          Roots := TPathItemCollection.Create;
          try
            ParentItem := Info.Data.Data;
            ParentItem.Provider.FillChildList(Thread, ParentItem, Roots, PATH_LOAD_DIRECTORIES_ONLY or PATH_LOAD_FOR_IMAGE_LIST or PATH_LOAD_CHECK_CHILDREN, 16, 10,
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

                            TopNode := GetFirstSelected;
                          end else
                          begin
                            ChildData.Data := CurrentItems[I];
                            AddChild(Info.Node, Pointer(ChildData));
                            ValidateNode(Info.Node, False);
                          end;
                        end;

                        if IsFirstItem then
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
