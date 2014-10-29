unit EasyListview;

// Version 1.0.0
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you maynot use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Alternatively, you may redistribute this library, use and/or modify it under the terms of the
// GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
// You may obtain a copy of the LGPL at http://www.gnu.org/copyleft/.
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The initial developer of this code is Jim Kueneman <jimdk@mindspring.com>
//
// Special thanks to the following in no particular order for their help/support/code
//    Danijel Malik, Robert Lee, Werner Lehmann, Alexey Torgashin, Milan Vandrovec
//
//  NOTES:
//   1)  If new properties are added to the TCollectionItems and published they
// need to be manually written/read from the stream.  The items are not automatically
// saved to the DFM file.  This was because mimicing TCollectionItem was not
// practical do to the way the VCL was designed.
//----------------------------------------------------------------------------

interface

{$B-}

{$I Compilers.inc}
{$I ..\Include\Debug.inc}
{$I Options.inc}


{$IFDEF GXDEBUG}
  {$DEFINE LOADGXUNIT}
{$ENDIF}
{$IFDEF GXDEBUG_PAINT}
  {$DEFINE LOADGXUNIT}
{$ENDIF GXDEBUG_PAINT}
{$IFDEF GXDEBUG_HINT}
  {$DEFINE LOADGXUNIT}
{$ENDIF GXDEBUG_HINT}

uses
  {$IFDEF COMPILER_9_UP}
  Types,    // This MUST come before Windows
  {$ENDIF}
  {$IFDEF COMPILER_6_UP}
  Variants, 
  {$ENDIF}
  Windows,  Math,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  {$IFDEF LOADGXUNIT}
  DbugIntf,
  {$ENDIF LOADGXUNIT}
  {$IFDEF COMPILER_7_UP}
  Themes,
  UxTheme,
  {$ELSE}
    {$IFDEF USETHEMES}
    TmSchema,
    UxTheme,
    {$ENDIF}
  {$ENDIF}
  ExtCtrls,
  Forms,
  ImgList,
  CommCtrl,
  ActiveX,
  Menus,
  StdCtrls,
  {$IFDEF COMPILER_6_UP}
    RTLConsts,
  {$ELSE}
    Consts,
  {$ENDIF}
  {$IFDEF SpTBX}
  TBX,
  SpTBXItem,
  {$ENDIF}
  {$IFDEF TNTSUPPORT}
  TntStdCtrls,
  {$ENDIF}
  EasyLVResources,
  MPCommonUtilities,
  MPShellTypes,
  MPCommonObjects,
  MPThreadManager;

{$R EasyRes.res}

const
  EGT_FIRSTLETTER = $FFFF;

  IID_IEasyCellEditor = '{A1686E7E-7F39-4BD4-BE1F-9C20D7BC6EA0}';
  IID_IEasyCellEditorSink = '{C0AAA3C0-AC98-43C8-8D9A-376A3F64FAD2}';

  IID_IEasyCaptions = '{6C838C0E-22A5-48D4-80C6-E266E950D3CF}';
  IID_IEasyCaptionsEditable = '{F1403B00-7163-4FB7-804F-1A5500CD980A}';
  IID_IEasyImageList = '{298932FB-A0AE-4A0A-BE34-A782743A0579}';
  IID_IEasyImages = '{20C419F5-F3DD-40C4-8526-88322E182C49}';
  IID_IEasyImagesEditable = '{DC580B13-1D19-46BB-885F-FC5CE9B2BE66}' ;
  IID_IEasyThumbnail = '{F9CA8297-0CB3-4C47-905F-3D1497C4FC4D}';
  IID_IEasyCustomImage = '{00260055-6915-43B5-9D43-379E7F61EEA9}';
  IID_IEasyDetails = '{AE1D21EB-BA52-4C24-9EB1-B35733299489}';
  IID_IEasyDetailsEditable = '{BBD853F9-D803-4478-B5A8-EE02FF47DC80}';
  IID_IEasyChecks = '{E8820F40-2EE3-4718-B54A-39318D2D1232}';
  IID_IEasyNotficationSink = '{E4F0D3DE-B2BD-4EC0-B24B-8A9B85B23A63}';
  IID_IEasyNotifier = '{F10150F9-17E3-43B6-8C05-33283FF1B14E}';
  IID_IEasyCompare = '{0761D4F5-D451-4A6D-BFDC-B3000FFD0299}';  
  IID_IEasyDividerPersist = '{EE6C3C89-7FAE-46CD-AD30-6954B4308721}';
  IID_IEasyExtractObj = '{7F667930-E47B-4474-BA62-B100D7DBDA70}';
  IID_IEasyGroupKey = '{2B87BB19-A133-4D43-9164-AC456747EB19}';
  IID_IEasyGroupKeyEditable = '{26EFE2C6-2DE2-4795-94E3-0DB0CAA38B09}';

  STREAM_VERSION = 1;

  _AUTOSCROLLDELAY = 500;   // 500 ms
  _AUTOSCROLLTIME = 50;     // ms

  CURSOR_VHEADERSPLIT = 'VEASYHEADERSPLIT';
  BITMAP_DEFAULTGROUPEXPANDED = 'DEFAULTEXPANDED';
  BITMAP_DEFAULTGROUPCOLLAPSED = 'DEFAULTCOLLAPSED';
  BITMAP_SORTARROWUP = 'SORTARROWUP';
  BITMAP_SORTARROWDOWN = 'SORTARROWDOWN';
  BITMAP_DEFAULTColumnGLYPHS = 'ColumnGLYPHS';
  BITMAP_DEFAULTColumnGLYPHSBKGND = $00FF00FF;

  CURRENT_EASYLISTVIEW_STREAM_VERSION = 1;

  SELECTION_OFFSET = 0.15;  // The selection rectangle will select an item +/- x% of the Caption width (like M$ Listview)

  WM_HOOKAPPACTIVATE = WM_APP + 204;
  WM_EDITORRESIZE = WM_APP + 205;
  WM_TABMOVEFOCUS = WM_APP + 206;

  RESIZEHITZONEMARGIN = 4;
//  LABEL_MARGIN = 2;

  crVHeaderSplit = 768;

  DEFAULT_GROUP_NAME = 'Default Group'; // group default name used if a first group is automatically created

  EASYLISTVIEW_HEADER_CLIPFORMAT = 'EasyListview.Header';

// Magic, mystical stuff for CBuilder
(*$HPPEMIT 'namespace Easylistview {'*)
{$HPPEMIT 'class DELPHICLASS TEasyItem;'}
{$HPPEMIT 'class DELPHICLASS TEasyGroup;'}
{$HPPEMIT 'class DELPHICLASS TEasyColumn;'}
{$HPPEMIT 'struct TGroupSortInfoRec;'}
{$HPPEMIT '__interface IEasyNotificationSink;'}
(*$HPPEMIT '}'*)

type
  // This is just a WAG for the size.  I can't imagine it ever needing this
  // many formats
  TeltArray = array[0..255] of TFormatEtc;

type
  TCustomEasyListview = class;
  TEasyItems = class;
  TEasyItem = class;
  TEasyItemInterfaced = class;
  TEasyViewItem = class;
  TEasyGroups = class;
  TEasyGroup = class;
  TEasyViewGroup = class;
  TEasyColumns = class;
  TEasyColumn = class;
  TEasyCollectionItem = class;
  TCustomEasyDragManagerBase = class;
  TEasyCellSize = class;
  TEasyHeader = class;
  TEasyCollection = class;
  TEasyPaintInfoBasic = class;
  TEasyHintInfo = class;
  TEasyOLEDragManager = class;
  TEasyHotTrackManager = class;
  TEasyViewColumn = class;
  TEasyHeaderDragManager = class;
  TEasySortManager = class;
  TEasyAlphaBlender = class;
  TEasyPaintInfoBaseGroup = class;

  TWideStringDynArray = array of WideString;
  TIntegerDynArray = array of Integer;

  TEasyCollectionItemClass = class of TEasyCollectionItem;
  TEasyViewItemClass = class of TEasyViewItem;
  TEasyGridGroupClass = class of TEasyGridGroup;
  TEasyGroupClass = class of TEasyGroup;

  TRectArray = array of TRect;
  TCommonMouseButtons = set of TCommonMouseButton;

  TEasyItemArray = array of TEasyItem;
  TEasyGroupArray = array of TEasyGroup;
  TEasyColumnArray = array of TEasyColumn;

  TEasyFormatEtcArray = array of TFormatEtc;
  TEasyDataObjectInfo = record
    FormatEtc: TFormatEtc;
    StgMedium: TStgMedium;
    OwnedByDataObject: Boolean;
  end;
  TEasyDataObjectInfoArray = array of TEasyDataObjectInfo;

  TEasyQueryDragResult = (
    eqdrContinue,            // The drag drop loop should contine
    eqdrQuit,                // The drag drop loop should end
    eqdrDrop                 // The drag drop loop should drop the object where it is
  );

  TEasyCheckType = (
    ectNone,              // No Checks
    ettNoneWithSpace,     // No Checks but leave the space for the checkbox
    ectBox,               // Square Checkbox type checkbox
    ectRadio              // Round Radio button type checkbox
  );

  TEasyListStyle = (
    elsIcon,          // The Listview's Large Icon Mode
    elsSmallIcon,     // The Listview's Small Icon Mode
    elsList,          // The Listview's List Mode
    elsReport,        // The Listview's Report (Details) Mode
    elsThumbnail,     // The Listview's Thumbnail Mode
    elsTile,          // The Listview's Tile Mode
    elsFilmStrip,     // The Listview's FilmStrip Mode
    elsGrid           // The Listview's Grid Mode
  );

  TEasyGroupMarginEdge = (
    egmeBackground,                   // Background of the entire Group
    egmeTop,                          // Header of a Group
    egmeBottom,                       // Footer of a Group
    egmeLeft,                         // Left Margin area of a Group
    egmeRight,                        // Right Margin area of a Group
    egmeForeground                    // Foreground of the entire Group
  );

  TEasyHeaderType = (
    ehtHeader,         // Report view Header
    ehtFooter          // Report view Footer
  );

  TEasyHeaderButtonStyle = (
    ehbsThick,        // "Normal" raised button
    ehbsFlat,         // Flat style button
    ehbsPlate,        // Plate style button
    ehbsThemed        // Draw using current Activation Context theme
  );

  TEasyHeaderImagePosition = (
    ehpLeft,         // The image is to the left of the Text
    ehpTop,          // The image is to the Top of the Text
    ehpRight,        // The image is to the Right of the Text
    ehpBottom        // The image is to the Bottom of the Text
  );

  TEasySortDirection = (
    esdNone,
    esdAscending,            // The sort is ascending
    esdDescending            // The sort is descending
  );

  TEasySortGlyphAlign = (
    esgaLeft,                // Column SortGlpyh placed to left of Caption
    esgaRight                // Column SortGlpyh placed to right of Caption
  );

  TEasyDragType = (
    edtOLE,                  // OLE Dragging
    edtVCL                   // VCL Dragging
  );

  TEasySelectionType = (
    ecstSelect,         // Select all objects
    ecstUnSelect,       // UnSelect all objects
    ecstInvert          // Invert the selection state of objects
  );

  TEasyColumnHitTestInfo = (
    ectOnCheckbox,         // Hit in the Checkbox
    ectOnIcon,             // Hit the icon
    ectOnLabel,            // Hit the Label
    ectOnText              // Hit in the current text in the label area
  );
  TEasyColumnHitTestInfoSet = set of TEasyColumnHitTestInfo;

  TEasyHitInfoColumn = packed record
    Column: TEasyColumn;  // The object hit
    HitInfo: TEasyColumnHitTestInfoSet; // Details of the hit
  end;

  TEasyGroupHitTestInfo = (
    egtOnBand,             // Hit the colored band
    egtOnCheckbox,         // Hit in the Checkbox
    egtOnExpandButton,     // Hit the ExpandButton
    egtOnIcon,             // Hit the icon
    egtOnLabel,            // Hit the Label
    egtOnText,             // Hit in the current text in the label area
    egtOnHeader,           // Hit in the header of the group
    egtOnFooter,           // Hit in the footer of the group
    egtOnLeftMargin,       // Hit in the Left Margin of the group
    egtOnRightMargin       // Hit in the Right Margin of the group
  );
  TEasyGroupHitTestInfoSet = set of TEasyGroupHitTestInfo;

  TEasyDefaultWheelScroll = (
    edwsHorz,                // Mouse Wheel scrolls horizontal by default, vertical with shift pressed
    edwsVert                 // Mouse Wheel scrolls vertical by default, horizontal with shift pressed
  );

  TEasyHitInfoGroup = packed record
    Group: TEasyGroup;  // The object hit
    HitInfo: TEasyGroupHitTestInfoSet; // Details of the hit
  end;

  TEasyItemHitTestInfo = (
    ehtStateIcon,           // Hit the state icon
    ehtOnIcon,              // Hit the icon
    ehtOnLabel,             // Hit the label, the area available for the Text
    ehtOnClickSelectBounds, // Hit the area defined as a selection area for a click
    ehtOnDragSelectBounds,  // Hit the area defined as a selection area for a drag select
    ehtOnText,          // Hit the area in the label that contains text
    ehtOnCheck,         // Hit the area where the check box is drawn
    ehtOnEdit           // Hit the area where the edit is started for the item
  );
  TEasyItemHitTestInfoSet = set of TEasyItemHitTestInfo;

  TEasyHitInfoItem = packed record
    Item: TEasyItem;
    Group: TEasyGroup;   // The group the object is in
    Column: TEasyColumn; // The the Column hit (if applicable)
    HitInfo: TEasyItemHitTestInfoSet; // Details of the hit
  end;

  TEasyStorageObjectState = (
    esosChecked,        // The object is checked
    esosCheckPending,   // The object has a check pending, the mouse has been pressed in the check area but not yet released
    esosCheckHover,     // The object has the mouse hovering over the checkbox (matters mostly themed)
    esosClicking,       // The object is being "clicked"
    esosCut,            // The object is being "cut"
    esosDestroying,     // The object is being destroyed
    esosHilighted,      // The object is currently hilighted, for an item this mean drop hilighed for a Column this means hot track hilighed
    esosEnabled,        // The object is enabled
    esosFocused,        // The object is focused, i.e. it will take the keyboard input
    esosInitialized,    // The object has been initialized
    esosSelected,       // The object is selected, i.e. it will be included for an operation on it
    esosVisible,        // The object is currently visible
    esosHotTracking,    // The object is currently in a hot track state
    esosBold,           // The object is in a Bold state
    esosDropTarget      // The object is hilighted as a drop target
  );
  TEasyStorageObjectStates = set of TEasyStorageObjectState;

  TEasyGroupsState = (
    egsRebuilding      // GroupManager is rebuild the item layout
  );
  TEasyGroupsStates = set of TEasyGroupsState;

  TEasyVAlignment = (
    evaTop,                            // The vertical alignment of the text is at the top of the object
    evaBottom,                         // The vertical alignment of the text is at the bottom of the object
    evaCenter                          // The vertical alignment of the text is at the center of the object
  );

  TEasySelectHitType = (
    eshtClickSelect,         // Test for a hit based on a mouse click
    eshtDragSelect           // Test for a hit based on a drag rectangle
  );

  TEasyCellRectType = (
    ertBounds,         // The bounds of the item minus the border
    ertIcon,           // The bounds of the icon image
    ertLabel,          // The bounds of the area dedicated to the text (will be static based on grid)
    ertClickSelectBounds, // The bounds of the area dedicated to a click selection (usually the Text area)
    ertDragSelectBounds,  // The bounds of the area dedicated to a drag selection (depends on the view)
    ertText,           // The bounds of the text for the item (will be dynamic based on current text)
    ertFullText        // The bounds of the actual Complete text for the item independant of current state of control/item
  );

  TEasyImageSize = (
    eisSmall,                   // Paint Small Images
    eisLarge,                   // Paint Large Images
    eisExtraLarge               // Paint JumboImages
  );

  TEasyImageKind = (
    eikNormal,                   // Normal image
    eikOverlay,                  // Overlay for the Normal image
    eikState                     // State image
  );

  TEasyDragManagerState = (
    edmsDragging,      // The Drag Manager is in the middle of a drag operation
    edmsAutoScrolling  // The Drag Manager is autoscrolling during a draw operation
  );
  TEasyDragManagerStates = set of TEasyDragManagerState;

  TEasyControlState = (
    ebcsLButtonDown,        // The Left Mouse Button is down
    ebcsRButtonDown,        // The Right Mouse Button is down
    ebcsMButtonDown,        // The Middle Mouse Button is down
    ebcsScrollButtonDown,   // The scroll wheel is down
    ebcsDragPending,        // The mouse is down and we are ready to check for a drag of an object
    ebcsDragging,           // The control is in the middle of a dragging operation
    ebcsVCLDrag,            // The drag operation is a VCL drag
    ebcsDragSelectPending,  // The mouse is down and we are ready to check for a drag select
    ebcsDragSelecting,      // The control is in a drag selecting mode
    ebcsThemesLoaded,       // The control has loaded themes if avaiable
    ebcsCheckboxClickPending, // The mouse is down over a checkbox and the box now has the attention of the mouse
    ebcsGroupExpandPending,  
    ebcsHeaderCapture,       // The Header area has captured the mouse
    ebcsScrolling,           // The control is scrolling
    ebcsOLERegistered,       // Registered for OLE Drag and Drop
    ebcsCancelContextMenu   // A right button drag drop should not show the context menu
  );
  TEasyControlStates = set of TEasyControlState;

  TEasyHeaderState = (
    ehsMouseCaptured,        // The Header captured the mouse (drag column/row; resize column/row)
    ehsResizing,             // One of the columns/headers is resizing
    ehsDragging,             // One of the columns/headers is being dragged
    ehsDragPending,
    ehsClickPending,        // One of the columns/headers was pressed and the mouse is being dragged around
    ehsCheckboxClickPending,
    ehsResizePending,
    ehsLButtonDown,
    ehsRButtonDown,
    ehsMButtonDown
  );
  TEasyHeaderStates = set of TEasyHeaderState;

  TEasyItemState = (
    eisTextRectCached
  );
  TEasyItemStates = set of TEasyItemState;
  
  TEasyRectArrayObject = packed record
    LabelRect,              // The bounds of the area dedicated to the text
                            //   (will be static based on grid)
    IconRect,               // The bounds of the icon image
    TextRect,               // The bounds of the text for the item (will be
                            //   dynamic based on current text)
                            // If TextRects is used then this is the Union of all
                            // the TextRects
                            // It will be calculated from LabelRect -2 pixels so that
                            // a Frame and a Focus Rect may be drawn around it and
                            // not extend past the Label Rect
    CheckRect: TRect;       // The rectangle used for the Checkbox of an item
    BoundsRect,             // The bounds of the item minus the border
    ClickSelectBoundsRect,   // The bounds of the area dedicated to a click
                             //   selection (may be possible the area is not
                             //   definable by a simple rectangle)
    DragSelectBoundsRect,    // The bounds of the area dedicated to a drag
                             //   selection (may be possible the area is not
                             //   definable by a simple rectangle)

    FullTextRect: TRect;     // The bounds of the largest rect of text that
                             //   can be shown (Icon view when item has focus the
                             //   entire text is shown, overlapping other items)
    SelectionRect: TRect;    // The bounds of the area that is painted in the
                             //   hilighted selection color
    FullFocusSelRect: TRect; // The bounds of the largest rect of selection that
                             //   can be shown (Icon view when item has focus the
                             //   entire text is shown, overlapping other items)
    FocusChangeInvalidRect: TRect; // The Rectangle to Invalidate(True) if the item
                                   //   changes focus or selection
    EditRect: TRect;        // The rectangle used for the editor in Edit Mode
    SortRect: TRect;        // The rectangle used for the Sort Glyphs
    StateRect: TRect;       // The rectangle used for state images
    TextRects: TRectArray;  // Text rectangles for Details
    ExpandButtonRect,       // The rectangle available in the group for the Expand Button (Groups Only)
    BandRect: TRect;        // The rectangle available in the group for the Band stripe (Groups Only)
    BackGndRect: TRect;     // The background of the group minus the Margin area, includes the Border (Groups Only)
    GroupRect: TRect;       // The entire space the group occupies (Groups Only)
  end;
  TEasyRectArrayObjectArray = array of TEasyRectArrayObject;

  TEasyMakeVisiblePos = (
    emvTop,      // Make visible with the top of the Client Window
    emvMiddle,   // Make visible with the middle of the Client Window
    emvBottom,  // Make visible with the bottom of the Client Window
    emvAuto     // Make visible and scroll based on if the item is above or below the current client window
  );

  TEasySearchDirection = (
    esdForward,
    esdBackward
  );

  TEasyAdjacentCellDir = (
    acdLeft,            // The cell that is to the left of a particular cell
    acdRight,           // The cell that is to the right of a particular cell
    acdUp,              // The cell that is above a particular cell
    acdDown,            // The cell that is below of a particular cell
    acdPageDown,        // The cell that is a single page down from a particular cell
    acdPageUp           // The cell that is a single page up from a particular cell
  );

  TEasyGridLayout = (
    eglHorz,                           // The Grid is a Horizontal grid (scrolls horz sized to fit vert)
    eglVert,                           // The Grid is a Vertical grid (scrolls vert, sized to fit horz)
    eglGrid                            // The Grid can scroll either way (may not fit client window either way)
  );

  TEasyHintType = (
    ehtText,              // Shows the hint in the passed text parameter
    ehtToolTip,           // Shows entire caption text if it does not fit in the assigned caption area
    ehtCustomDraw         // The hint will callback when it needs drawing
  );

  PEasyHintInfoRec = ^TEasyHintInfoRec;
  TEasyHintInfoRec = record
    HintControl: TControl;
    HintWindowClass: THintWindowClass;
    HintPos: TPoint;
    HintMaxWidth: Integer;
    HintColor: TColor;
    HintType: TEasyHintType;
    CursorRect: TRect;
    CursorPos: TPoint;
    ReshowTimeout: Integer;
    HideTimeout: Integer;
    HintStr: WideString;
    HintData: Pointer;
    Listview: TCustomEasyListview;
    TargetObj: TEasyCollectionItem;  // What the hint is being popped up over (EasyItem, EasyGroup, EasyColumn etc.)
    ToolTipRect: TRect;   // The size of the rect needed for a tool tip hint
  end;

  TEasySortAlgorithm = (
    esaQuickSort,
    esaBubbleSort,
    esaMergeSort
  );

  TEasyIncrementalSearchState = (
    eissTimerRunning,       // The Search timeout timer is running
    eissSearching           // Currently in a Search mode
  );
  TEasyIncrementalSearchStates = set of TEasyIncrementalSearchState;

  TCoolIncrementalSearchStart = (
    eissStartOver,          // Always start a search from the beginning of the list
    eissLastHit,            // Start search from the last node found in the incremental search
    eissFocusedNode         // Start search from current focused node
   );

   TEasyIncrementalSearchItemType = (
     eisiAll,               // Search All items in list
     eisiInitializedOnly,   // Search only items with their initialized property set, this will include collapsed groups but not invisible groups
     eisiVisible            // Search only items with their visible property set, this will include collapsed groups but not invisible groups
   );

   TEasyIncrementalSearchDir = (
     eisdForward,           // Search Forward in the list
     eisdBackward           // Search Backward in the list
   );

   TEasyNextItemType = (
     enitAny,
     enitVisible,
     enitInitialized,
     enitVisibleInExpandedGroup,
     enitEditable // Implies visible
   );  

   TEasyScrollbarDir = (
     esdVertical,
     esdHorizontal,
     esdBoth
   );

   TEasyHotTrackState = (
    ehsEnable,    // object becoming a hot track target
    ehsDisable    // object losing a hot track status
  );

  TEasyHotTrackRectItem = (
    htiIcon,       // Hot track is defined on the image
    htiText,        // Hot track is defined on the Text
    htiAnyWhere     // Hot track is defined on the entire cell
  );
  TEasyHotTrackRectItems = set of TEasyHotTrackRectItem;

  TEasyHotTrackRectGroup = (
    htgIcon,       // Hot track is defined on the image
    htgText,        // Hot track is defined on the Text
    htgTopMargin,   // Hot track is defined on the Top Group Margin
    htgBottomMargin,// Hot track is defined on the Bottom Group Margin
    htgLeftMargin,  // Hot track is defined on the Left Group Margin
    htgRightMargin, // Hot track is defined on the Right Group Margin
    htgAnyWhere     // Hot track is defined on the entire cell
  );
  TEasyHotTrackRectGroups = set of TEasyHotTrackRectGroup;

  TEasyHotTrackRectColumn = (
    htcIcon,       // Hot track is defined on the image
    htcText,        // Hot track is defined on the Text
    htcAnyWhere     // Hot track is defined on the entire cell
  );
  TEasyHotTrackRectColumns = set of TEasyHotTrackRectColumn;

  TEasyScrollManagerState = (
    escsRecalculating  //  In the middle of a Recalulation rebuild of the scrollbars
  );
  TEasyScrollManagerStates = set of TEasyScrollManagerState;

  //  ****************************************************************
  // Intefaces that EasyListview is aware of such that user data may implement these
  // interfaces to present the data necessary for the control
  // ****************************************************************

  // Implements the read only Caption for the Control
  IEasyCaptions = interface(IUnknown)
  [IID_IEasyCaptions]
    function GetCaption(Column: Integer): Variant;

    property Captions[Column: Integer]: Variant read GetCaption;
  end;

  // Implements the Caption for the Control
  IEasyCaptionsEditable = interface(IEasyCaptions)
  [IID_IEasyCaptionsEditable]
    function SetCaption(Column: Integer; const Value: Variant): Boolean;
  end;

  // Implements a custom ImageList on a per item/column basis for the Control
  IEasyImageList = interface(IUnknown)
  [IID_IEasyImageList]
    function GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList;
    property ImageList[Column: Integer; IconSize: TEasyImageSize]: TImageList read GetImageList;
  end;

  // Implements the read only ImageIndex for the Control
  IEasyImages = interface(IUnknown)
  [IID_IEasyImages]
    function GetImageIndex(Column: Integer; ImageKind: TEasyImageKind): Integer;

    property ImageIndexes[Column: Integer; ImageKind: TEasyImageKind]: Integer read GetImageIndex;
  end;

  // Implements the ImageIndex for the Control
  IEasyImagesEditable = interface(IEasyImages)
  [IID_IEasyImagesEditable]
    procedure SetImageIndex(Column: Integer; ImageKind: TEasyImageKind; const Value: Integer);

    property ImageIndexes[Column: Integer; ImageKind: TEasyImageKind]: Integer read GetImageIndex write SetImageIndex;
  end;

  // Implements the Thumbnail (Bitmap) for the Control
  IEasyThumbnail = interface(IUnknown)
  [IID_IEasyThumbnail]
    procedure ThumbnailDraw(ACanvas: TCanvas; ViewportRect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
  end;

  IEasyCustomImage = interface(IUnknown)
  [IID_IEasyCustomImage]
    procedure CustomDrawn(Column: TEasyColumn; var IsCustom: Boolean);
    procedure DrawImage(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
    procedure GetSize(Column: TEasyColumn; var ImageW, ImageH: Integer);
  end;

  // Implements the Tile Details for the Control
  // Points to what Column to get the detail from
  IEasyDetails = interface(IUnknown)
  [IID_IEasyDetails]
    function GetDetailCount: Integer;
    function GetDetail(Line: Integer): Integer; // Return the Column to be used as the detail for the given line

    property Detail[Line: Integer]: Integer read GetDetail;
    property DetailCount: Integer read GetDetailCount;
  end;

  IEasyDetailsEditable = interface(IEasyDetails)
  [IID_IEasyDetailsEditable]
    procedure SetDetail(Line: Integer; Value: Integer);
    procedure SetDetailCount(Value: Integer);

    property Detail[Line: Integer]: Integer read GetDetail write SetDetail;
    property DetailCount: Integer read GetDetailCount write SetDetailCount;
  end;

  // Implements the CheckState for the Control
  IEasyChecks = interface(IUnknown)
  [IID_IEasyChecks]
    function GetChecked(Column: Integer): Boolean;
    procedure SetChecked(Column: Integer; const Value: Boolean);
    property Checked[Column: Integer]: Boolean read GetChecked write SetChecked;
  end;

  IEasyGroupKey = interface(IUnknown)
  [IID_IEasyGroupKey]
    function GetKey(FocusedColumn: Integer): LongWord;

    property Key[FocusedColumn: Integer]: LongWord read GetKey; // Uniquely identifies the item in a particular group
  end;

  IEasyGroupKeyEditable = interface(IEasyGroupKey)
  [IID_IEasyGroupKeyEditable]
    procedure SetKey(FocusedColumn: Integer; Value: LongWord);

    property Key[FocusedColumn: Integer]: LongWord read GetKey write SetKey;
  end;

  IEasyNotificationSink = interface(IUnknown)
  [IID_IEasyNotficationSink]
    procedure InvalidateItem(ImmediateRefresh: Boolean);
    procedure UnRegister;
  end;

  IEasyNotifier = interface(IUnknown)
  [IID_IEasyNotifier]
    procedure OnRegisterNotify(const ANotifier: IEasyNotificationSink);
    procedure OnUnRegisterNotify(const ANotifier: IEasyNotificationSink);
  end;

  IEasyCompare = interface
  [IID_IEasyCompare]
    function Compare(const Data: IUnknown; Column: TEasyColumn): Integer;
  end;

  IEasyExtractObj = interface
  [IID_IEasyExtractObj]
    function GetObj: TObject;
    property Obj: TObject read GetObj;
  end;

  // Interface for the EasyControl to communicate with a Cells Editor
  IEasyCellEditor = interface(IUnknown)
  [IID_IEasyCellEditor]
    function AcceptEdit: Boolean;
    function GetModified: Boolean;
    procedure ControlWndHookProc(var Message: TMessage);
    procedure Hide;
    procedure Initialize(AnItem: TEasyItem; Column: TEasyColumn);
    procedure Finalize;
    function PtInEditControl(WindowPt: TPoint): Boolean;
    procedure SetEditorFocus;
    procedure Show;

    property Modified: Boolean read GetModified;
  end;

  // ***************************************
  // Event callback Definitions
  // ***************************************
  TAutoGroupGetKeyEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; ColumnIndex: Integer; Groups: TEasyGroups; var Key: LongWord) of object;
  TAutoSortGroupCreateEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; ColumnIndex: Integer; Groups: TEasyGroups; var Group: TEasyGroup; var DoDefaultAction: Boolean) of object;
  TEasyClipboardEvent = procedure(Sender: TCustomEasyListview; var Handled: Boolean) of object;
  TEasyClipboardCutEvent = procedure(Sender: TCustomEasyListview; var MarkAsCut, Handled: Boolean) of object;
  TColumnCheckChangeEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn) of object;
  TColumnCheckChangingEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; var Allow: Boolean) of object;
  TColumnClickEvent = procedure(Sender: TCustomEasyListview; Button: TCommonMouseButton; const Column: TEasyColumn) of object;
  TColumnContextMenuEvent = procedure(Sender: TCustomEasyListview; HitInfo: TEasyHitInfoColumn; WindowPoint: TPoint; var Menu: TPopupMenu) of object;
//  TColumnCreatePaintInfoEvent = procedure(Sender: TCustomEasyListview; var PaintInfo: TEasyColumnPaintInfo) of object;
  TColumnDblClickEvent = procedure(Sender: TCustomEasyListview; Button: TCommonMouseButton; MousePos: TPoint; const Column: TEasyColumn) of object;
  TColumnEnableChangeEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn) of object;
  TColumnEnableChangingEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; var Allow: Boolean) of object;
  TColumnFocusChangeEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn) of object;
  TColumnFocusChangingEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; var Allow: Boolean) of object;
  TColumnFreeingEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn) of object;
  TColumnGetCaptionEvent = procedure(Sender: TCustomEasyListview; Line: Integer; var Caption: WideString) of object;
  TColumnGetImageIndexEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; ImageKind: TEasyImageKind; var ImageIndex: Integer) of object;
  TColumnGetImageListEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; var ImageList: TImageList) of object;
  TColumnGetDetailCountEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; var Count: Integer) of object;
  TColumnImageDrawEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender) of object;
  TColumnImageGetSizeEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; var ImageWidth, ImageHeight: Integer) of object;
  TColumnImageDrawIsCustomEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; var IsCustom: Boolean) of object;
  TColumnGetDetailEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; Line: Integer; var Detail: Integer) of object;
  TColumnInitializeEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn) of object;
  TColumnPaintTextEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; ACanvas: TCanvas) of object;
  TEasyColumnLoadFromStreamEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; S: TStream; Version: Integer) of object;
  TEasyColumnSaveToStreamEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; S: TStream; Version: Integer) of object;
  TColumnSelectionChangeEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn) of object;
  TColumnSelectionChangingEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; var Allow: Boolean) of object;
  TColumnSetCaptionEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; Caption: WideString) of object;
  TColumnSetImageIndexEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; ImageKind: TEasyImageKind; ImageIndex: Integer) of object;
  TColumnSetDetailEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; Line: Integer; const Detail: Integer) of object;
  TColumnSizeChangingEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; Width, NewWidth: Integer; var Allow: Boolean) of object;
  TColumnSizeChangedEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn) of object;
  TColumnThumbnailDrawEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; ACanvas: TCanvas; ARect: TRect; var DoDefault: Boolean) of object;
  TColumnVisibilityChangeEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn) of object;
  TColumnVisibilityChangingEvent = procedure(Sender: TCustomEasyListview; Column: TEasyColumn; var Allow: Boolean) of object;
  TContextMenuEvent = procedure(Sender: TCustomEasyListview; MousePt: TPoint; var Handled: Boolean) of object;
  TCustomColumnViewEvent = procedure(Sender: TCustomEasyListview; var View: TEasyViewColumn) of object;
  TCustomGridEvent = procedure(Sender: TCustomEasyListview; ViewStyle: TEasyListStyle; var Grid: TEasyGridGroupClass) of object;
  TCustomViewEvent = procedure(Sender: TCustomEasyListview; ViewStyle: TEasyListStyle; var View: TEasyViewItemClass) of object;
  TDblClickEvent = procedure(Sender: TCustomEasyListview; Button: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState) of object;
  TGetDragImageEvent = procedure(Sender: TCustomEasyListview; Image: TBitmap; DragStartPt: TPoint; var HotSpot: TPoint; var TransparentColor: TColor; var Handled: Boolean) of object;
  TGroupClickEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; KeyStates: TCommonKeyStates; HitTest: TEasyGroupHitTestInfoSet) of object;
  TGroupCollapseEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup) of object;
  TGroupCollapsingEvent = procedure(Sender: TCustomEasyListview;  Group: TEasyGroup; var Allow: Boolean) of object;
  TGroupCompareEvent = function(Sender: TCustomEasyListview; Item1, Item2: TEasyGroup): Integer of object;
  TGroupContextMenuEvent = procedure(Sender: TCustomEasyListview; HitInfo: TEasyHitInfoGroup; WindowPoint: TPoint; var Menu: TPopupMenu; var Handled: Boolean) of object;
  TGroupDblClickEvent = procedure(Sender: TCustomEasyListview; Button: TCommonMouseButton; MousePos: TPoint; HitInfo: TEasyHitInfoGroup) of object;
  TGroupExpandEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup) of object;
  TGroupExpandingEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; var Allow: Boolean) of object;
  TGroupFocusChangeEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup) of object;
  TGroupFocusChangingEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; var Allow: Boolean) of object;
  TGroupFreeingEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup) of object;
  TGroupGetCaptionEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; var Caption: WideString) of object;
  TGroupGetClassEvent = procedure(Sender: TCustomEasyListview; var GroupClass: TEasyCollectionItemClass) of object;
  TGroupGetImageIndexEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; ImageKind: TEasyImageKind; var ImageIndex: Integer) of object;
  TGroupGetImageListEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; var ImageList: TImageList) of object;
  TGroupGetDetailCountEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; var Count: Integer) of object;
  TGroupImageDrawEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender) of object;
  TGroupImageGetSizeEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; var ImageWidth, ImageHeight: Integer) of object;
  TGroupImageDrawIsCustomEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; var IsCustom: Boolean) of object;
  TGroupGetDetailEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; Line: Integer; var Detail: Integer) of object;
  TGroupInitializeEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup) of object;
  TGroupHotTrackEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; State: TEasyHotTrackState; MousePos: TPoint) of object;      
  TGroupLoadFromStreamEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; S: TStream; Version: Integer) of object;
  TGroupPaintTextEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; ACanvas: TCanvas) of object;
  TGroupSaveToStreamEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; S: TStream; Version: Integer) of object;
  TGroupSetCaptionEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; Caption: WideString) of object;
  TGroupSetImageIndexEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; ImageKind: TEasyImageKind; ImageIndex: Integer) of object;
  TGroupSetDetailEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; Line: Integer; const Detail: Integer) of object;
  TGroupSelectionChangeEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup) of object;
  TGroupSelectionChangingEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; var Allow: Boolean) of object;
  TGroupThumbnailDrawEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; ACanvas: TCanvas; ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean) of object;
  TGroupVisibilityChangeEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup) of object;
  TGroupVisibilityChangingEvent = procedure(Sender: TCustomEasyListview; Group: TEasyGroup; var Allow: Boolean) of object;
  THintCustomDrawEvent = procedure(Sender: TCustomEasyListview; TargetObj: TEasyCollectionItem; const Info: TEasyHintInfo) of object;
  THintCustomizeInfoEvent = procedure(Sender: TCustomEasyListview; TargetObj: TEasyCollectionItem; Info: TEasyHintInfo) of object;
  THintPauseTimeEvent = procedure(Sender: TCustomEasyListview; HintWindowShown: Boolean; var PauseDelay: Integer) of object;
  THintPopupEvent = procedure(Sender: TCustomEasyListview; TargetObj: TEasyCollectionItem; HintType: TEasyHintType; MousePos: TPoint; var AText: WideString; var HideTimeout, ReShowTimeout: Integer; var Allow: Boolean) of object;
  THeaderClickEvent = procedure(Sender: TCustomEasyListview; MouseButton: TCommonMouseButton; Column: TEasyColumn) of object;
  THeaderDblClickEvent = procedure(Sender: TCustomEasyListview; MouseButton: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState) of object;
  THeaderMouseEvent = procedure(Sender: TCustomEasyListview; MouseButton: TCommonMouseButton; Shift: TShiftState; X, Y: Integer; Column: TEasyColumn) of object;
  TIncrementalSearchEvent = procedure(Item: TEasyCollectionItem; const SearchBuffer: WideString; var CompareResult: Integer) of object;
  TItemCheckChangeEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem) of object;
  TItemCheckChangingEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; var Allow: Boolean) of object;
  TItemClickEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; KeyStates: TCommonKeyStates; HitInfo: TEasyItemHitTestInfoSet) of object;
  TItemCompareEvent = function(Sender: TCustomEasyListview; Column: TEasyColumn; Group: TEasyGroup; Item1, Item2: TEasyItem): Integer of object;
  TItemContextMenuEvent = procedure(Sender: TCustomEasyListview; HitInfo: TEasyHitInfoItem; WindowPoint: TPoint; var Menu: TPopupMenu; var Handled: Boolean) of object;
  TItemCreateEditorEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; var Editor: IEasyCellEditor) of object;
  TItemLoadFromStreamEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; S: TStream; Version: Integer) of object;
  TItemSaveToStreamEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; S: TStream; Version: Integer) of object;
  TItemDblClickEvent = procedure(Sender: TCustomEasyListview; Button: TCommonMouseButton; MousePos: TPoint; HitInfo: TEasyHitInfoItem) of object;
  TItemEditBegin = procedure(Sender: TCustomEasyListview; Item: TEasyItem; var Column: Integer; var Allow: Boolean) of object;  
  TItemEditedEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; var NewValue: Variant; var Accept: Boolean) of object;
  TItemEditEnd = procedure(Sender: TCustomEasyListview; Item: TEasyItem) of object;
  TItemEnableChangeEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem) of object;
  TItemEnableChangingEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; var Allow: Boolean) of object;
  TItemFreeingEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem) of object;
  TItemFocusChangeEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem) of object;
  TItemFocusChangingEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; var Allow: Boolean) of object;
  TItemGetCaptionEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; Column: Integer; var Caption: WideString) of object;
  TEasyItemGetCaptionEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; Column: TEasyColumn; var Caption: WideString) of object;
  TItemGetClassEvent = procedure(Sender: TCustomEasyListview; var ItemClass: TEasyCollectionItemClass) of object;
  TItemGetGroupKeyEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; FocusedColumn: Integer; var GroupKey: LongWord) of object;
  TItemGetImageIndexEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; Column: Integer; ImageKind: TEasyImageKind; var ImageIndex: Integer) of object;
  TItemGetImageListEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; Column: Integer; var ImageList: TImageList) of object;
  TItemGetTileDetailCountEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; var Count: Integer) of object;
  TItemImageDrawEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender) of object;
  TItemImageGetSizeEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; Column: TEasyColumn; var ImageWidth, ImageHeight: Integer) of object;
  TItemImageDrawIsCustomEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; Column: TEasyColumn; var IsCustom: Boolean) of object;
  TItemGetTileDetailEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; Line: Integer; var Detail: Integer) of object;
  TItemHotTrackEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; State: TEasyHotTrackState; MousePos: TPoint) of object;     
  TItemInitializeEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem) of object;
  TItemMouseDownEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; Button: TCommonMouseButton; var DoDefault: Boolean) of object;
  TItemMouseUpEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; Button: TCommonMouseButton; var DoDefault: Boolean) of object;
  TItemPaintTextEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; Position: Integer; ACanvas: TCanvas) of object;
  TItemSelectionChangeEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem) of object;
  TItemSelectionChangingEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; var Allow: Boolean) of object;
  TEasyItemSelectionsChangedEvent = procedure(Sender: TCustomEasyListview) of object;
  TItemSetCaptionEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; Column: Integer; Caption: WideString) of object;
  TItemSetGroupKeyEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; Column: Integer; Key: LongWord) of object;
  TItemSetImageIndexEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; Column: Integer; ImageKind: TEasyImageKind; ImageIndex: Integer) of object;
  TItemSetTileDetailEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; Line: Integer; const Detail: Integer) of object;
  TItemThumbnailDrawEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas; ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean) of object;
  TItemVisibilityChangeEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem) of object;
  TItemVisibilityChangingEvent = procedure(Sender: TCustomEasyListview; Item: TEasyItem; var Allow: Boolean) of object;

  TEasyKeyActionEvent = procedure(Sender: TCustomEasyListview; var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean) of object;

  TOLEDropSourceDragEndEvent = procedure(Sender: TCustomEasyListview; ADataObject: IDataObject; DragResult: TCommonOLEDragResult; ResultEffect: TCommonDropEffects) of object;
  TOLEDropSourceDragStartEvent = procedure(Sender: TCustomEasyListview; ADataObject: IDataObject; var AvailableEffects: TCommonDropEffects; var AllowDrag: Boolean) of object;
  TOLEDropSourceQueryContineDragEvent = procedure(Sender: TCustomEasyListview; EscapeKeyPressed: Boolean; KeyStates: TCommonKeyStates; var QueryResult: TEasyQueryDragResult) of object;
  TOLEDropSourceGiveFeedbackEvent = procedure(Sender: TCustomEasyListview; Effect: TCommonDropEffects; var UseDefaultCursors: Boolean) of object;
  TOLEDropTargetDragEnterEvent = procedure(Sender: TCustomEasyListview; DataObject: IDataObject; KeyState: TCommonKeyStates; WindowPt: TPoint; AvailableEffects: TCommonDropEffects; var DesiredDropEffect: TCommonDropEffect) of object;
  TOLEDropTargetDragOverEvent = procedure(Sender: TCustomEasyListview; KeyState: TCommonKeyStates; WindowPt: TPoint; AvailableEffects: TCommonDropEffects; var DesiredDropEffect: TCommonDropEffect) of object;
  TOLEDropTargetDragLeaveEvent = procedure(Sender: TCustomEasyListview) of object;
  TOLEDropTargetDragDropEvent = procedure(Sender: TCustomEasyListview; DataObject: IDataObject; KeyState: TCommonKeyStates; WindowPt: TPoint; AvailableEffects: TCommonDropEffects; var DesiredDropEffect: TCommonDropEffect) of object;
  TOLEGetCustomFormatsEvent = procedure(Sender: TCustomEasyListview; var Formats: TEasyFormatEtcArray) of object;
  TOLEGetDataEvent = procedure(Sender: TCustomEasyListview; const FormatEtcIn: TFormatEtc; var Medium: TStgMedium; var Handled: Boolean) of object;
  FOLEGetDataObjectEvent = procedure(Sender: TCustomEasyListview; var DataObject: IDataObject) of object;
  TOLEQueryDataEvent = procedure(Sender: TCustomEasyListview; const FormatEtcIn: TFormatEtc; var FormatAvailable: Boolean; var Handled: Boolean) of object;
  TPaintHeaderBkGndEvent = procedure(Sender: TCustomEasyListview; ACanvas: TCanvas; ARect: TRect; var Handled: Boolean) of object;
  TViewChangingEvent = procedure(Sender: TCustomEasyListview; View: TEasyListStyle; var Allow: Boolean) of object;
  TViewChangedEvent = procedure(Sender: TCustomEasyListview) of object;

  TEasyDoGroupCompare = function(Column: TEasyColumn; Group1, Group2: TEasyGroup): Integer of object;
  TEasyDoItemCompare = function(Column: TEasyColumn; Group: TEasyGroup; Item1, Item2: TEasyItem): Integer of object;

  // **************************************************************************
  // TEasyMemo
  //   A class that uses TntMemo when TNTSUPPORT is defined
  // **************************************************************************
  {$IFDEF TNTSUPPORT}
  TEasyMemo = class(TTntMemo);
  TEasyEdit = class(TTntEdit);
  {$ELSE}
  TEasyMemo = class(TMemo);
  TEasyEdit = class(TEdit);
  {$ENDIF}


  // **************************************************************************
  // TEasyInterfacedPersistent
  //   A class that makes a TPersistent class that is an interfaced object
  // **************************************************************************
  TEasyInterfacedPersistent = class(TPersistent, IUnknown, IEasyExtractObj)
  private
    FRefCount: Integer;
  protected
    // IUnknown
    function _AddRef: Integer; virtual; stdcall;
    function _Release: Integer; virtual; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;

    // IEasyExtractObj
    function GetObj: TObject;
  public

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    class function NewInstance: TObject; override;
    property Obj: TObject read GetObj;
    property RefCount: Integer read FRefCount;
  end;

  // **************************************************************************
  // TEasyOwnedInterfacedPersistent
  //   A class that makes an interfaced object that has knowledge of the
  // TEasyOwnerListview
  // **************************************************************************
  TEasyOwnedInterfacedPersistent = class(TEasyInterfacedPersistent)
  private
    FOwner: TCustomEasyListview;
  public
    constructor Create(AnOwner: TCustomEasyListview); virtual;

    property Owner: TCustomEasyListview read FOwner;
  end;

  // **************************************************************************
  // TEasyPersistent
  // **************************************************************************
  TEasyPersistent = class(TPersistent)
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  end;

  // **************************************************************************
  // TEasyOwnedPersistent
  //    Basis for Managers and objects that need a link back to the Main Window
  // **************************************************************************
  TEasyOwnedPersistent = class(TEasyPersistent)
  private
    FOwnerListview: TCustomEasyListview;
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AnOwner: TCustomEasyListview); reintroduce; virtual;
    procedure LoadFromStream(S: TStream); virtual;
    procedure SaveToStream(S: TStream); virtual;
    property OwnerListview: TCustomEasyListview read FOwnerListview;
  end;

  TEasyCanvasStore = class
  protected
    FBrush: TBrush;
    FFont: TFont;
    FPen: TPen;
  public
    destructor Destroy; override;
    procedure RestoreCanvasState(Canvas: TCanvas);
    procedure StoreCanvasState(Canvas: TCanvas);
    property Brush: TBrush read FBrush write FBrush;
    property Font: TFont read FFont write FFont;
    property Pen: TPen read FPen write FPen;
  end;

  // **************************************************************************
  // TEasyOwnerPersistentView
  //   Basis for any class that will become a view
  // **************************************************************************
  TEasyOwnedPersistentView = class(TEasyOwnedPersistent)
  private
    FCanvasStore: TEasyCanvasStore;
    function GetCanvasStore: TEasyCanvasStore;
  protected
    procedure PaintCheckboxCore(CheckType: TEasyCheckType; OwnerListView: TCustomEasyListView; ACanvas: TCanvas; ARect: TRect; IsEnabled, IsChecked, IsHot, IsFlat, IsHovering, IsPending: Boolean; Obj: TEasyCollectionItem; Size: Integer);
    property CanvasStore: TEasyCanvasStore read GetCanvasStore write FCanvasStore;
  public
    destructor Destroy; override;
  published

  end;

  // **************************************************************************
  // TEasyAlphaBlender
  //   Helper for Alpha blending a canvas
  // **************************************************************************
  TEasyAlphaBlender = class(TEasyPersistent)
  public
    destructor Destroy; override;
    procedure BasicBlend(Listview: TCustomEasyListview; ACanvas: TCanvas; ViewportRect: TRect; Color: TColor; Alpha: Byte = 128); virtual;
    procedure Blend(Listview: TCustomEasyListview; Obj: TEasyCollectionItem; ACanvas: TCanvas; ViewportRect: TRect; Image: TBitmap); virtual;
    procedure GetBlendParams(Listview: TCustomEasyListview; Obj: TEasyCollectionItem; var BlendAlpha: Byte; var BlendColor: TColor; var DoBlend: Boolean);
  end;

  // **************************************************************************
  // TEasyOwnedPersistentGroupItem
  //   Basis for any class property of a TEasyGroup that allows communication
  // back to the TEasyGroups
  // **************************************************************************
  TEasyOwnedPersistentGroupItem = class(TEasyOwnedPersistentView)
  private
    FOwnerGroup: TEasyGroup;
  public
    constructor Create(AnOwner: TEasyGroup); reintroduce;
    property OwnerGroup: TEasyGroup read FOwnerGroup;
  end;

  TEasySelectionGroupList = class
  private
    FDisplayRect: TRect;
    FFirstItem: TEasyItem;
    FList: TList;
    FRefCount: Integer;
  protected
    function GetItems(Index: Integer): TEasyItem;
    procedure SetItems(Index: Integer; Value: TEasyItem);
    property List: TList read FList write FList;
    property RefCount: Integer read FRefCount write FRefCount;
  public
    constructor Create;
    destructor Destroy; override;
    function Count: Integer;
    procedure Add(Item: TEasyItem);
    procedure Clear;
    procedure DecRef;
    procedure IncRef;
    property DisplayRect: TRect read FDisplayRect write FDisplayRect;
    property FirstItem: TEasyItem read FFirstItem write FFirstItem;
    property Items[Index: Integer]: TEasyItem  read GetItems write SetItems; default;
  end;

  // **************************************************************************
  // TEasyMargin
  //   Property for TEasyGroupItem to set the attributes of the Group Margins
  // **************************************************************************
  TEasyMargin = class(TEasyOwnedPersistent)
  private
    FSize: Integer;
    FVisible: Boolean;
    procedure SetSize(Value: Integer);
    procedure SetVisible(Value: Boolean);
  protected
    function RuntimeSize: Integer;
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
  published
    property Size: Integer read FSize write SetSize default 30;
    property Visible: Boolean read FVisible write SetVisible default False;
  end;

  // **************************************************************************
  // TEasyHeaderMargin
  //   Property for TEasyGroupItem to set the attributes of the Header Group Margin
  // **************************************************************************
  TEasyHeaderMargin = class(TEasyMargin)
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
  published
    property Visible default True;
  end;

  // **************************************************************************
  // TCustomEasyFooterMargin
  //   Property for TEasyGroupItem to set the attributes of the Group Margins
  // **************************************************************************
  TCustomEasyFooterMargin = class(TEasyMargin)
  private
    FCaption: WideString;
    FImageIndex: Integer;
    FImageOverlayIndex: Integer;
    FPaintInfo: TEasyPaintInfoBaseGroup;
    function GetAlignment: TAlignment;
    function GetCaptionIndent: Integer;
    function GetCaptionLines: Integer;
    function GetImageIndent: Integer;
    function GetPaintInfo: TEasyPaintInfoBaseGroup;
    function GetVAlignment: TEasyVAlignment;
    procedure SetAlignment(Value: TAlignment);
    procedure SetCaption(Value: WideString);
    procedure SetCaptionIndent(Value: Integer);
    procedure SetCaptionLines(Value: Integer);
    procedure SetImageIndent(Value: Integer);
    procedure SetImageIndex(Value: Integer);
    procedure SetImageOveralyIndex(Value: Integer);
    procedure SetPaintInfo(const Value: TEasyPaintInfoBaseGroup);
    procedure SetVAlignment(Value: TEasyVAlignment);
  protected
    property Alignment: TAlignment read GetAlignment write SetAlignment default taLeftJustify;
    property Caption: WideString read FCaption write SetCaption;
    property CaptionIndent: Integer read GetCaptionIndent write SetCaptionIndent default 2;
    property CaptionLines: Integer read GetCaptionLines write SetCaptionLines default 1;
    property ImageIndent: Integer read GetImageIndent write SetImageIndent default 2;
    property ImageIndex: Integer read FImageIndex write SetImageIndex default -1;
    property ImageOverlayIndex: Integer read FImageOverlayIndex write SetImageOveralyIndex default -1;
    property PaintInfo: TEasyPaintInfoBaseGroup read GetPaintInfo write SetPaintInfo;
    property Size default 30;
    property VAlignment: TEasyVAlignment read GetVAlignment write SetVAlignment default evaCenter;
    
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
  end;
  TEasyFooterMarginCustomClass = class of TCustomEasyFooterMargin;

  // **************************************************************************
  // TEasyFooterMargin
  //   Default Footer Margin PaintInfo that is global to all Groups. Defined under
  // the EasyListview.PaintInfoGroup.MarginBottom property
  // **************************************************************************
  TEasyFooterMargin = class(TCustomEasyFooterMargin)
  published
    property Alignment;
    property Caption;
    property CaptionIndent;
    property CaptionLines;
    property ImageIndent;
    property ImageIndex;
    property ImageOverlayIndex;
    property Size default 30;
    property VAlignment;
  end;

  // **************************************************************************
  // TEasyPaintInfoBasic
  //   Basic information that defines how a particular UI object is Painted
  // **************************************************************************
  TEasyPaintInfoBasic = class(TEasyOwnedPersistent)
  private
    FAlignment: TAlignment;
    FBorder: Integer;
    FCaptionIndent: Integer;
    FCaptionLines: Integer;
    FCheckFlat: Boolean;
    FCheckIndent: Integer;
    FCheckSize: Integer;
    FCheckType: TEasyCheckType;
    FImageIndent: Integer;
    FShowBorder: Boolean;
    FVAlignment: TEasyVAlignment;
    procedure SetAlignment(Value: TAlignment);
    procedure SetBorder(Value: Integer);
    procedure SetBorderColor(Value: TColor);
    procedure SetCaptionIndent(Value: Integer);
    procedure SetCaptionLines(Value: Integer);
    procedure SetCheckFlat(Value: Boolean);
    procedure SetCheckIndent(Value: Integer);
    procedure SetCheckSize(Value: Integer);
    procedure SetCheckType(Value: TEasyCheckType);
    procedure SetImageIndent(Value: Integer);
    procedure SetShowBorder(const Value: Boolean);
    procedure SetVAlignment(Value: TEasyVAlignment);
  public
    FBorderColor: TColor;
  protected
    procedure Invalidate(ImmediateUpdate: Boolean); virtual;

    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Border: Integer read FBorder write SetBorder default 4;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clHighlight;
    property CaptionIndent: Integer read FCaptionIndent write SetCaptionIndent default 4;
    property CaptionLines: Integer read FCaptionLines write SetCaptionLines default 1;
    property CheckFlat: Boolean read FCheckFlat write SetCheckFlat default False;
    property CheckIndent: Integer read FCheckIndent write SetCheckIndent default 2;
    property CheckSize: Integer read FCheckSize write SetCheckSize default 12;
    property CheckType: TEasyCheckType read FCheckType write SetCheckType default ectNone;
    property ImageIndent: Integer read FImageIndent write SetImageIndent default 2;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder default True;
    property VAlignment: TEasyVAlignment read FVAlignment write SetVAlignment default evaCenter;
  public
    constructor Create(AnOwner: TCustomEasyListview); override;

    procedure Assign(Source: TPersistent); override;
  end;
  TEasyPaintInfoBasicClass = class of TEasyPaintInfoBasic;

  // **************************************************************************
  // TEasyPaintInfoBaseItem
  //   Information that defines how an Items UI object is Painted
  // **************************************************************************
  TEasyPaintInfoBaseItem = class(TEasyPaintInfoBasic)
  private
    FGridLineColor: TColor;
    FGridLines: Boolean;
    FTileDetailCount: Integer;
    procedure SetGridLineColor(const Value: TColor);
    procedure SetGridLines(const Value: Boolean);
    procedure SetTileDetailCount(Value: Integer);
  protected
    property GridLineColor: TColor read FGridLineColor write SetGridLineColor default clBtnFace;
    property GridLines: Boolean read FGridLines write SetGridLines default False;
    property TileDetailCount: Integer read FTileDetailCount write SetTileDetailCount default 1;
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
  end;

  TEasyPaintInfoItem = class(TEasyPaintInfoBaseItem)
  published
    property Border;
    property BorderColor;
    property CaptionIndent;
    property CaptionLines;
    property CheckFlat;
    property CheckIndent;
    property CheckSize;
    property CheckType;
    property GridLineColor;
    property GridLines;
    property ImageIndent;
    property ShowBorder;
    property TileDetailCount;
    property VAlignment;
  end;

  TEasyPaintInfoTaskBandItem = class(TEasyPaintInfoBaseItem)
  published
    property CaptionIndent;
    property CheckFlat;
    property CheckIndent;
    property CheckSize;
    property CheckType;
    property VAlignment;
  end;

  // **************************************************************************
  // TEasyPaintInfoBaseColumn
  //   Information that defines how an Column UI object is Painted
  // **************************************************************************
  TEasyPaintInfoBaseColumn = class(TEasyPaintInfoBasic)
  private
    FColor: TColor;
    FHilightFocused: Boolean;
    FHilightFocusedColor: TColor;
    FHotTrack: Boolean;
    FImagePosition: TEasyHeaderImagePosition;
    FSortGlyphAlign: TEasySortGlyphAlign;
    FSortGlyphIndent: Integer;
    FStyle: TEasyHeaderButtonStyle;
    procedure SetColor(Value: TColor);
    procedure SetHilightFocused(const Value: Boolean);
    procedure SetHilightFocusedColor(const Value: TColor);
    procedure SetImagePosition(Value: TEasyHeaderImagePosition);
    procedure SetSortGlpyhAlign(Value: TEasySortGlyphAlign);
    procedure SetSortGlyphIndent(Value: Integer);
    procedure SetStyle(Value: TEasyHeaderButtonStyle);
  protected
    property Color: TColor read FColor write SetColor default clBtnFace;
    property HilightFocused: Boolean read FHilightFocused write SetHilightFocused default False;
    property HilightFocusedColor: TColor read FHilightFocusedColor write SetHilightFocusedColor default $00F7F7F7;
    property HotTrack: Boolean read FHotTrack write FHotTrack default True;
    property ImagePosition: TEasyHeaderImagePosition read FImagePosition write SetImagePosition default ehpLeft;
    property SortGlyphAlign: TEasySortGlyphAlign read FSortGlyphAlign write SetSortGlpyhAlign default esgaRight;
    property SortGlyphIndent: Integer read FSortGlyphIndent write SetSortGlyphIndent default 2;
    property Style: TEasyHeaderButtonStyle read FStyle write SetStyle default ehbsThick;
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
  published
  end;

  TCustomEasyPaintInfoBaseColumn = class(TEasyPaintInfoBaseColumn)
  end;

  TEasyPaintInfoColumn = class(TCustomEasyPaintInfoBaseColumn)
  private
  published
    property Border;
    property BorderColor;
    property CaptionIndent;
    property CaptionLines;
    property CheckFlat;
    property CheckIndent;
    property CheckSize;
    property CheckType;
    property Color;
    property HilightFocused;
    property HilightFocusedColor;
    property HotTrack;
    property ImageIndent;
    property ImagePosition;
    property SortGlyphAlign;
    property SortGlyphIndent;
    property Style;
    property VAlignment;
  end;

  TEasyPaintInfoTaskBandColumn = class(TEasyPaintInfoBaseColumn)
  published
    // Nothing published
  end;

  // **************************************************************************
  // TEasyPaintInfoBasicGroup
  //   Basic information that defines how an Groups UI object is Painted
  // **************************************************************************
  TEasyPaintInfoBaseGroup = class(TEasyPaintInfoBasic)
  private
    FBandBlended: Boolean;
    FBandColor: TColor;
    FBandColorFade: TColor;
    FBandEnabled: Boolean;
    FBandFullWidth: Boolean;
    FBandIndent: Integer;
    FBandLength: Integer;
    FBandMargin: Integer;
    FBandRadius: Byte;
    FBandThickness: Integer;
    FExpandable: Boolean;
    FExpanded: Boolean;
    FExpandImageIndent: Integer;
    FMarginBottom: TCustomEasyFooterMargin;
    FMarginLeft: TEasyMargin;
    FMarginRight: TEasyMargin;
    FMarginTop: TEasyHeaderMargin;
    function GetMarginBottom: TCustomEasyFooterMargin;
    function GetMarginLeft: TEasyMargin;
    function GetMarginRight: TEasyMargin;
    function GetMarginTop: TEasyHeaderMargin;
    procedure SetBandBlended(Value: Boolean);
    procedure SetBandColor(Value: TColor);
    procedure SetBandColorFade(Value: TColor);
    procedure SetBandEnabled(Value: Boolean);
    procedure SetBandFullWidth(Value: Boolean);
    procedure SetBandIndent(Value: Integer);
    procedure SetBandLength(Value: Integer);
    procedure SetBandMargin(Value: Integer);
    procedure SetBandRadius(Value: Byte);
    procedure SetBandThickness(Value: Integer);
    procedure SetExpandable(Value: Boolean);
    procedure SetExpandImageIndent(Value: Integer);
    procedure SetMarginBottom(Value: TCustomEasyFooterMargin);
    procedure SetMarginLeft(Value: TEasyMargin);
    procedure SetMarginRight(Value: TEasyMargin);
    procedure SetMarginTop(Value: TEasyHeaderMargin);
  protected
    property BandBlended: Boolean read FBandBlended write SetBandBlended default True;
    property BandColor: TColor read FBandColor write SetBandColor default clBlue;
    property BandColorFade: TColor read FBandColorFade write SetBandColorFade default clWindow;
    property BandEnabled: Boolean read FBandEnabled write SetBandEnabled default True;
    property BandFullWidth: Boolean read FBandFullWidth write SetBandFullWidth default False;
    property BandIndent: Integer read FBandIndent write SetBandIndent default 0;
    property BandLength: Integer read FBandLength write SetBandLength default 300;
    property BandMargin: Integer read FBandMargin write SetBandMargin default 2;
    property BandRadius: Byte read FBandRadius write SetBandRadius default 4;
    property BandThickness: Integer read FBandThickness write SetBandThickness default 3;
    property Expandable: Boolean read FExpandable write SetExpandable default True;
    property ExpandImageIndent: Integer read FExpandImageIndent write SetExpandImageIndent default 4;
    property MarginBottom: TCustomEasyFooterMargin read GetMarginBottom write SetMarginBottom;
    property MarginLeft: TEasyMargin read GetMarginLeft write SetMarginLeft;
    property MarginRight: TEasyMargin read GetMarginRight write SetMarginRight;
    property MarginTop: TEasyHeaderMargin read GetMarginTop write SetMarginTop;
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
  end;

  // **************************************************************************
  // TEasyPaintInfoGroup
  //   Information that defines how an Groups UI object is Painted
  // **************************************************************************
  TEasyPaintInfoGroup = class(TEasyPaintInfoBaseGroup)
  published
    property Alignment;
    property BandBlended;
    property BandColor;
    property BandColorFade;
    property BandEnabled;
    property BandFullWidth;
    property BandIndent;
    property BandLength;
    property BandMargin;
    property BandRadius;
    property BandThickness;
    property Border;
    property BorderColor;
    property CaptionIndent;
    property CaptionLines;
    property CheckFlat;
    property CheckIndent;
    property CheckSize;
    property CheckType;
    property Expandable;
    property ExpandImageIndent;
    property ImageIndent;
    property MarginBottom;
    property MarginLeft;
    property MarginRight;
    property MarginTop;
    property VAlignment;
  end;

   // **************************************************************************
  // TEasyPaintInfoGroup
  //   Information that defines how an Groups UI object is Painted
  // **************************************************************************
  TEasyPaintInfoTaskbandGroup = class(TEasyPaintInfoBaseGroup)
  published
    property Alignment;
    property CaptionIndent;
    property CheckFlat;
    property CheckIndent;
    property CheckSize;
    property CheckType;
    property Expandable;
    property MarginBottom;
    property MarginLeft;
    property MarginRight;
    property MarginTop;
    property VAlignment;
  end;

  // **************************************************************************
  // TEasyDynamicDataHelper
  //    Helps with multiple captions/image storage for item/groups/columns
  // **************************************************************************
  TEasyDynamicDataHelper = class
  private
    FCaptionArray: TWideStringDynArray;
    FDetailArray: TIntegerDynArray;
    FGroupKeyArray: TIntegerDynArray;
    FImageIndexArray: TIntegerDynArray;
    FOverlayIndexArray: TIntegerDynArray;
    function GetCaptions(Index: Integer): Widestring;
    function GetDetails(Index: Integer): Integer;
    function GetImageIndexes(Index: Integer): Integer;
    function GetImageOverlayIndexes(Index: Integer): Integer;
    procedure LoadIntArrayFromStream(S: TStream; var AnArray: TIntegerDynArray);
    procedure LoadWideStrArrayFromStream(S: TStream; var AnArray: TWideStringDynArray);
    procedure SaveIntArrayToStream(S: TStream; var AnArray: TIntegerDynArray);
    procedure SaveWideStrArrayToStream(S: TStream; var AnArray: TWideStringDynArray);
    procedure SetCaptions(Index: Integer; Value: Widestring);
    procedure SetDetails(Index: Integer; Value: Integer);
    procedure SetImageIndexes(Index: Integer; Value: Integer);
    procedure SetImageOverlayIndexes(Index: Integer; Value: Integer);
    property CaptionArray: TWideStringDynArray read FCaptionArray write FCaptionArray;
    property DetailArray: TIntegerDynArray read FDetailArray write FDetailArray;
    property GroupKeyArray: TIntegerDynArray read FGroupKeyArray write FGroupKeyArray;
    property ImageIndexArray: TIntegerDynArray read FImageIndexArray write FImageIndexArray;
    property OverlayIndexArray: TIntegerDynArray read FOverlayIndexArray write FOverlayIndexArray;
  public
    procedure Clear;
    procedure LoadFromStream(S: TStream); virtual;
    procedure SaveToStream(S: TStream); virtual;
    property Captions[Index: Integer]: Widestring read GetCaptions write SetCaptions;
    property Details[Index: Integer]: Integer read GetDetails write SetDetails;
    property ImageIndexes[Index: Integer]: Integer read GetImageIndexes write SetImageIndexes;
    property ImageOverlayIndexes[Index: Integer]: Integer read GetImageOverlayIndexes write SetImageOverlayIndexes;
  end;

  TEasyItemDynamicDataHelper = class(TEasyDynamicDataHelper)
  private
    function GetGroupKey(Index: Integer): LongWord;
    procedure SetGroupKey(Index: Integer; Value: LongWord);
  public
    procedure LoadFromStream(S: TStream); override;
    procedure SaveToStream(S: TStream); override;
    property GroupKey[Index: Integer]: LongWord read GetGroupKey write SetGroupKey;
  end;

  // **************************************************************************
  // TEasyCollectionItem
  //    Basis for Collection items (, TEasyGroup, TEasyColumn)
  // This Item can access its data through the
  // **************************************************************************
  TEasyCollectionItem = class(TEasyPersistent, IUnknown, IEasyNotificationSink)
  private
    FCollection: TEasyCollection;
    FData: TObject;
    FDataInf: IUnknown;
    FDisplayRect: TRect;               // The viewport coordinates of the object
    FIndex: Integer;                   // Absolute Index of the item within a particular collecton
    FOwnsPaintInfo: Boolean;
    FPaintInfo: TEasyPaintInfoBasic;   // Information to draw the item
    FRefCount: Integer;
    FState: TEasyStorageObjectStates;  // State of the item
    FTag: Integer;
    FVisibleIndex: Integer;            // Index of the item across all collections (flat list across collection in group)
                                       // See TEasyItem.VisibleIndexInGroup
    function GetAlignment: TAlignment;
    function GetBold: Boolean;
    function GetBorder: Integer;
    function GetBorderColor: TColor;
    function GetCaptionIndent: Integer;
    function GetChecked: Boolean;
    function GetCheckFlat: Boolean;
    function GetCheckHovering: Boolean;
    function GetCheckIndent: Integer;
    function GetCheckPending: Boolean;
    function GetCheckSize: Integer;
    function GetCheckType: TEasyCheckType;
    function GetClicking: Boolean;
    function GetCut: Boolean;
    function GetDataInf: IUnknown;
    function GetDestroying: Boolean;
    function GetHilighted: Boolean;
    function GetEnabled: Boolean;
    function GetFocused: Boolean;
    function GetHotTracking(MousePos: TPoint): Boolean;
    function GetImageIndent: Integer;
    function GetInitialized: Boolean;
    function GetOwnerListview: TCustomEasyListview;
    function GetPaintInfo: TEasyPaintInfoBasic;
    function GetSelected: Boolean;
    function GetVAlignment: TEasyVAlignment;
    function GetVisible: Boolean;
    procedure SetAlignment(Value: TAlignment);
    procedure SetBold(const Value: Boolean);
    procedure SetBorder(Value: Integer);
    procedure SetBorderColor(Value: TColor);
    procedure SetCaptionIndent(Value: Integer);
    procedure SetChecked(Value: Boolean);
    procedure SetCheckFlat(Value: Boolean);
    procedure SetCheckHovering(Value: Boolean);
    procedure SetCheckIndent(Value: Integer);
    procedure SetCheckPending(Value: Boolean);
    procedure SetCheckSize(Value: Integer);
    procedure SetCheckType(Value: TEasyCheckType);
    procedure SetClicking(Value: Boolean);
    procedure SetCut(Value: Boolean);
    procedure SetData(Value: TObject); virtual;
    procedure SetDataInf(const Value: IUnknown);
    procedure SetHilighted(Value: Boolean);
    procedure SetEnabled(Value: Boolean);
    procedure SetFocused(Value: Boolean);
    procedure SetHotTracking(MousePos: TPoint; Value: Boolean);
    procedure SetImageIndent(Value: Integer);
    procedure SetInitialized(Value: Boolean);
    procedure SetPaintInfo(Value: TEasyPaintInfoBasic);
    procedure SetSelected(Value: Boolean);
    procedure SetVAlignment(Value: TEasyVAlignment);
    procedure SetVisible(Value: Boolean);
    
  protected
    function AllowDrag(ViewportPt: TPoint): Boolean; virtual;
    // IUnknown
    function _AddRef: Integer; virtual; stdcall;
    function _Release: Integer; virtual; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;

    function CanChangeBold(NewValue: Boolean): Boolean; virtual; abstract;
    function CanChangeCheck(NewValue: Boolean): Boolean; virtual; abstract;
    function CanChangeEnable(NewValue: Boolean): Boolean; virtual; abstract;
    function CanChangeFocus(NewValue: Boolean): Boolean; virtual; abstract;
    function CanChangeHotTracking(NewValue: Boolean): Boolean; virtual; abstract;
    function CanChangeSelection(NewValue: Boolean): Boolean; virtual; abstract;
    function CanChangeVisibility(NewValue: Boolean): Boolean; virtual; abstract;
    function DefaultImageList(ImageSize: TEasyImageSize): TImageList; virtual;
    function GetDisplayName: WideString; virtual;
    function LocalPaintInfo: TEasyPaintInfoBasic; virtual; abstract;
    procedure Freeing; virtual; abstract;
    procedure GainingBold; virtual; abstract;
    procedure GainingCheck; virtual; abstract;
    procedure GainingEnable; virtual; abstract;
    procedure GainingFocus; virtual; abstract;
    procedure GainingHilight; virtual; abstract;
    procedure GainingHotTracking(MousePos: TPoint); virtual; abstract;
    procedure GainingSelection; virtual; abstract;
    procedure GainingVisibility; virtual; abstract;
    function GetCaption: WideString; virtual;
    function GetCaptions(Column: Integer): Widestring; virtual; abstract;
    function GetImageIndex: Integer; virtual;
    function GetImageIndexes(Column: Integer): Integer; virtual; abstract;
    function GetImageOverlayIndex: Integer; virtual;
    function GetImageOverlayIndexes(Column: Integer): Integer; virtual; abstract;
    function GetOwner: TPersistent; override;
    function GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList; virtual; abstract;
    function GetIndex: Integer; virtual;
    function GetDetailCount: Integer; virtual; abstract;
    function GetDetails(Line: Integer): Integer; virtual; abstract;
    procedure ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender); virtual; abstract;
    procedure ImageDrawGetSize(Column: TEasyColumn; var ImageW, ImageH: Integer); virtual; abstract;
    procedure ImageDrawIsCustom(Column: TEasyColumn; var IsCustom: Boolean); virtual; abstract;
    procedure InvalidateItem(ImmediateRefresh: Boolean); // IEasyNotificationSink
    procedure LosingBold; virtual; abstract;
    procedure LosingHotTracking; virtual; abstract;
    procedure ThumbnailDraw(ACanvas: TCanvas; ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean); virtual; abstract;
    procedure Initialize; virtual; abstract;
    procedure LosingCheck; virtual; abstract;
    procedure LosingEnable; virtual; abstract;
    procedure LosingFocus; virtual; abstract;
    procedure LosingHilight; virtual; abstract;
    procedure LosingSelection; virtual; abstract;
    procedure LosingVisibility; virtual; abstract;
    procedure SetCaptions(Column: Integer; Value: Widestring); virtual; abstract;
    procedure SetCaption(Value: WideString); virtual;
    procedure SetDestroyFlags;
    procedure SetDetailCount(Value: Integer); virtual; abstract;
    procedure SetDetails(Line: Integer; Value: Integer); virtual; abstract;
    procedure SetImageIndex(Value: Integer); virtual;
    procedure SetImageIndexes(Column: Integer; Value: Integer); virtual; abstract;
    procedure SetImageOverlayIndex(Value: Integer); virtual;
    procedure SetImageOverlayIndexes(Column: Integer; Value: Integer); virtual; abstract;
    procedure UnRegister; // IEasyNotificationSink
    property Alignment: TAlignment read GetAlignment write SetAlignment default taLeftJustify;
    property Bold: Boolean read GetBold write SetBold default False;
    property Border: Integer read GetBorder write SetBorder default 0;
    property BorderColor: TColor read GetBorderColor write SetBorderColor default clWindow;
    property CaptionIndent: Integer read GetCaptionIndent write SetCaptionIndent default 2;
    property Checked: Boolean read GetChecked write SetChecked default False;
    property CheckFlat: Boolean read GetCheckFlat write SetCheckFlat default False;
    property CheckHovering: Boolean read GetCheckHovering write SetCheckHovering;
    property CheckIndent: Integer read GetCheckIndent write SetCheckIndent default 2;
    property CheckPending: Boolean read GetCheckPending write SetCheckPending;
    property CheckSize: Integer read GetCheckSize write SetCheckSize default 12;
    property CheckType: TEasyCheckType read GetCheckType write SetCheckType default ectNone;
    property Clicking: Boolean read GetClicking write SetClicking default False;
    property Collection: TEasyCollection read FCollection write FCollection;
    property Cut: Boolean read GetCut write SetCut default False;
    property DataInf: IUnknown read GetDataInf write SetDataInf;
    property Destroying: Boolean read GetDestroying;
    property Enabled: Boolean read GetEnabled write SetEnabled default True;
    property Focused: Boolean read GetFocused write SetFocused default False;
    property Hilighted: Boolean read GetHilighted write SetHilighted default False;
    property ImageIndent: Integer read GetImageIndent write SetImageIndent default 2;
    property Initialized: Boolean read GetInitialized write SetInitialized;
    property OwnsPaintInfo: Boolean read FOwnsPaintInfo write FOwnsPaintInfo default False;
    property PaintInfo: TEasyPaintInfoBasic read GetPaintInfo write SetPaintInfo;
    property Selected: Boolean read GetSelected write SetSelected default False;
    property State: TEasyStorageObjectStates read FState write FState;// The State of the object, checked, selected, focused, etc.
    property VAlignment: TEasyVAlignment read GetVAlignment write SetVAlignment;
    property Visible: Boolean read GetVisible write SetVisible default True;
  public
    constructor Create(ACollection: TEasyCollection); reintroduce; virtual;
    destructor Destroy; override;   
                         
    property DisplayRect: TRect read FDisplayRect write FDisplayRect;
    function EditAreaHitPt(ViewportPoint: TPoint): Boolean; virtual; abstract;
    function SelectionHit(SelectViewportRect: TRect; SelectType: TEasySelectHitType): Boolean; virtual; abstract;
    function SelectionHitPt(ViewportPoint: TPoint; SelectType: TEasySelectHitType): Boolean; virtual; abstract;
    procedure Invalidate(ImmediateUpdate: Boolean); virtual; // IEasyNotificationSink
    procedure LoadFromStream(S: TStream; Version: Integer = STREAM_VERSION); virtual;
    procedure MakeVisible(Position: TEasyMakeVisiblePos); virtual;
    procedure SaveToStream(S: TStream; Version: Integer = STREAM_VERSION); virtual;

    property Caption: WideString read GetCaption write SetCaption;
    property Captions[Column: Integer]: Widestring read GetCaptions write SetCaptions;
    property Data: TObject read FData write SetData;
    property DetailCount: Integer read GetDetailCount write SetDetailCount;
    property Details[Line: Integer]: Integer read GetDetails write SetDetails;
    property HotTracking[MousePos: TPoint]: Boolean read GetHotTracking write SetHotTracking;
    property ImageIndex: Integer read GetImageIndex write SetImageIndex default -1;
    property ImageIndexes[Column: Integer]: Integer read GetImageIndexes write SetImageIndexes;
    property ImageList[Column: Integer; IconSize: TEasyImageSize]: TImageList read GetImageList;
    property ImageOverlayIndex: Integer read GetImageOverlayIndex write SetImageOverlayIndex default -1;
    property ImageOverlayIndexes[Column: Integer]: Integer read GetImageOverlayIndexes write SetImageOverlayIndexes;
    property Index: Integer read GetIndex;
    property OwnerListview: TCustomEasyListview read GetOwnerListview;
    property RefCount: Integer read FRefCount;
    property Tag: Integer read FTag write FTag default 0;
    property VisibleIndex: Integer read FVisibleIndex;
  end;

  // **************************************************************************
  // TEasyItemBase
  //    Basis for any object that can be stored in a TEasyGroup.  Implements the
  // basic handling of interaction between the item and the Listview
  // **************************************************************************
  TEasyItem = class(TEasyCollectionItem)
  private
    FSelectionGroup: TEasySelectionGroupList;  // If grouped selection is on this points to the selection group this item belongs to (nil if none)
    FVisibleIndexInGroup: Integer;             // Index of visible item within a group
    function GetColumnPos: Integer;
    function GetOwnerGroup: TEasyGroup;
    function GetOwnerItems: TEasyItems;
    function GetOwnerView: TEasyViewItem;
    function GetPaintInfo: TEasyPaintInfoItem;
    function GetRowPos: Integer;
    function GetView: TEasyViewItem;
    procedure SetPaintInfo(const Value: TEasyPaintInfoItem);
    procedure SetSelectionGroup(Value: TEasySelectionGroupList);
  protected
    function AllowDrag(ViewportPt: TPoint): Boolean; override;
    function CanChangeBold(NewValue: Boolean): Boolean; override;
    function CanChangeCheck(NewValue: Boolean): Boolean; override;
    function CanChangeEnable(NewValue: Boolean): Boolean; override;
    function CanChangeFocus(NewValue: Boolean): Boolean; override;
    function CanChangeHotTracking(NewValue: Boolean): Boolean; override;
    function CanChangeSelection(NewValue: Boolean): Boolean; override;
    function CanChangeVisibility(NewValue: Boolean): Boolean; override;
    function GetGroupKey(FocusedColumn: Integer): LongWord; virtual;
    function GetIndex: Integer; override;
    function LocalPaintInfo: TEasyPaintInfoBasic; override;
    procedure Freeing; override;
    procedure GainingBold; override;
    procedure GainingCheck; override;
    procedure GainingEnable; override;
    procedure GainingFocus; override;
    procedure GainingHilight; override;
    procedure GainingHotTracking(MousePos: TPoint); override;
    procedure GainingSelection; override;
    procedure GainingVisibility; override;
    procedure Initialize; override;
    procedure LosingBold; override;
    procedure LosingCheck; override;
    procedure LosingEnable; override;
    procedure LosingFocus; override;
    procedure LosingHilight; override;
    procedure LosingHotTracking; override;
    procedure LosingSelection; override;
    procedure LosingVisibility; override;
    procedure ReleaseSelectionGroup;
    property SelectionGroup: TEasySelectionGroupList read FSelectionGroup write SetSelectionGroup;
    procedure SetGroupKey(FocusedColumn: Integer; Value: LongWord); virtual;
  public
    constructor Create(ACollection: TEasyCollection); override;
    destructor Destroy; override;
    function EditAreaHitPt(ViewportPoint: TPoint): Boolean; override;
    function HitTestAt(ViewportPoint: TPoint; var HitInfo: TEasyItemHitTestInfoSet): Boolean;
    function SelectionHit(SelectViewportRect: TRect; SelectType: TEasySelectHitType): Boolean; override;
    function SelectionHitPt(ViewportPoint: TPoint; SelectType: TEasySelectHitType): Boolean; override;
    procedure Edit(Column: TEasyColumn = nil);
    procedure Invalidate(ImmediateUpdate: Boolean); override;
    procedure ItemRectArray(Column: TEasyColumn; ACanvas: TCanvas; var RectArray: TEasyRectArrayObject);
    procedure LoadFromStream(S: TStream; Version: Integer = STREAM_VERSION); override;
    procedure MakeVisible(Position: TEasyMakeVisiblePos); override;
    procedure Paint(ACanvas: TCanvas; ViewportClipRect: TRect; Column: TEasyColumn; ForceSelectionRectDraw: Boolean); virtual;
    procedure SaveToStream(S: TStream; Version: Integer = STREAM_VERSION); override;
    property Alignment;
    property Bold;
    property Border;
    property BorderColor;
    property Caption;
    property CaptionIndent;
    property Captions;
    property Checked;
    property CheckFlat;
    property CheckHovering;
    property CheckIndent;
    property CheckPending;
    property CheckSize;
    property CheckType;
    property ColumnPos: Integer read GetColumnPos;
    property Cut;
    property Destroying;
    property DetailCount;
    property Details;
    property Enabled;
    property Focused;
    property GroupKey[FocusedColumn: Integer]: LongWord read GetGroupKey write SetGroupKey;
    property Hilighted;
    property ImageIndent;
    property ImageIndex;
    property ImageIndexes;
    property ImageList;
    property ImageOverlayIndex;
    property ImageOverlayIndexes;
    property Initialized;
    property OwnerGroup: TEasyGroup read GetOwnerGroup;
    property OwnerItems: TEasyItems read GetOwnerItems;
    property OwnerView: TEasyViewItem read GetOwnerView;
    property OwnsPaintInfo;
    property PaintInfo: TEasyPaintInfoItem read GetPaintInfo write SetPaintInfo;
    property RowPos: Integer read GetRowPos;
    property Selected;
    property State;
    property VAlignment;
    property View: TEasyViewItem read GetView;
    property Visible;
    property VisibleIndexInGroup: Integer read FVisibleIndexInGroup;
  published
  end;
  TEasyItemClass = class of TEasyItem;


  // **************************************************************************
  // TEasyItemInterfaced
  //    Uses interfaced based data extraction to extract the data from a data
  // source.  The data source can implement any of the following
  //   IEasyCaptions          // Returns Captions for the control
  //   IEasyCaptionsEditable  // Sets Captions in the data from the Control
  //   IEasyImages            // Returns Images for the control
  //   IEasyImagesEditable    // Sets Images in the data from the Control
  //   IEasyThumbnail         // Returns Thumbnail for the control
  //   IEasyThumbnailEditable // Sets Thumbnail in the data from the Control
  //   IEasyChecks            // Sets/Unsets the Checkbox State for the control
  //   IEasyNotifier          // Returns an Inteterface to allow data to notify Control of changes in the data
  //   IEasyCompareData       // Allows sorting of the data set
  // **************************************************************************
  TEasyItemInterfaced = class(TEasyItem)
  protected
    function GetCaptions(Column: Integer): Widestring; override;
    function GetDetailCount: Integer; override;
    function GetDetails(Line: Integer): Integer; override;
    function GetGroupKey(FocusedColumn: Integer): LongWord; override;
    function GetImageIndexes(Column: Integer): Integer; override;
    function GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList; override;
    function GetImageOverlayIndexes(Column: Integer): Integer; override;
    procedure ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender); override;
    procedure ImageDrawGetSize(Column: TEasyColumn; var ImageW, ImageH: Integer); override;
    procedure ImageDrawIsCustom(Column: TEasyColumn; var IsCustom: Boolean); override;
    procedure SetCaptions(Column: Integer; Value: Widestring); override;
    procedure SetDetailCount(Value: Integer); override;
    procedure SetDetails(Line: Integer; Value: Integer); override;
    procedure SetGroupKey(FocusedColumn: Integer; Value: LongWord); override;
    procedure SetImageIndexes(Column: Integer; Value: Integer); override;
    procedure SetImageOverlayIndexes(Column: Integer; Value: Integer); override;
    procedure ThumbnailDraw(ACanvas: TCanvas; ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean); override;
  public
    property DataInf;
  end;

  // **************************************************************************
  // TEasyItemVirtual
  //    Calls back through the Controls Events for the data to display
  // **************************************************************************
  TEasyItemVirtual = class(TEasyItem)
  protected
    function GetCaptions(Column: Integer): Widestring; override;
    function GetDetailCount: Integer; override;
    function GetDetails(Line: Integer): Integer; override;
    function GetGroupKey(FocusedColumn: Integer): LongWord; override;
    function GetImageIndexes(Column: Integer): Integer; override;
    function GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList; override;
    function GetImageOverlayIndexes(Column: Integer): Integer; override;
    procedure ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender); override;
    procedure ImageDrawGetSize(Column: TEasyColumn; var ImageW: Integer; var ImageH: Integer); override;
    procedure ImageDrawIsCustom(Column: TEasyColumn; var IsCustom: Boolean); override;
    procedure SetCaptions(Column: Integer; Value: Widestring); override;
    procedure SetDetailCount(Value: Integer); override;
    procedure SetDetails(Line: Integer; Value: Integer); override;
    procedure SetGroupKey(FocusedColumn: Integer; Value: LongWord); override;
    procedure SetImageIndexes(Column: Integer; Value: Integer); override;
    procedure SetImageOverlayIndexes(Column: Integer; Value: Integer); override;
    procedure ThumbnailDraw(ACanvas: TCanvas; ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean); override;
  public
  end;

  // **************************************************************************
  // TEasyItemStored
  //    Stores the data local to the Item instance
  // **************************************************************************
  TEasyItemStored = class(TEasyItem)
  private
    FDataHelper: TEasyItemDynamicDataHelper;
  protected
    function GetCaptions(Column: Integer): Widestring; override;
    function GetDetailCount: Integer; override;
    function GetDetails(Line: Integer): Integer; override;
    function GetGroupKey(FocusedColumn: Integer): LongWord; override;
    function GetImageIndexes(Column: Integer): Integer; override;
    function GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList; override;
    function GetImageOverlayIndexes(Column: Integer): Integer; override;
    procedure ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender); override;
    procedure ImageDrawGetSize(Column: TEasyColumn; var ImageW: Integer; var ImageH: Integer); override;
    procedure ImageDrawIsCustom(Column: TEasyColumn; var IsCustom: Boolean); override;
    procedure SetCaptions(Column: Integer; Value: Widestring); override;
    procedure SetDetailCount(Value: Integer); override;
    procedure SetDetails(Column: Integer; Value: Integer); override;
    procedure SetGroupKey(FocusedColumn: Integer; Value: LongWord); override;
    procedure SetImageIndexes(Column: Integer; Value: Integer); override;
    procedure SetImageOverlayIndexes(Column: Integer; Value: Integer); override;
    procedure ThumbnailDraw(ACanvas: TCanvas; ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean); override;
    property DataHelper: TEasyItemDynamicDataHelper read FDataHelper write FDataHelper;
  public
    constructor Create(ACollection: TEasyCollection); override;
    destructor Destroy; override;
    procedure LoadFromStream(S: TStream; Version: Integer = STREAM_VERSION); override;
    procedure SaveToStream(S: TStream; Version: Integer = STREAM_VERSION); override;
  published
    property Bold;
    property Caption;
    property Checked;
    property Enabled;
    property ImageIndex;
    property ImageOverlayIndex;
    property OwnsPaintInfo;
    property Selected;
    property Tag;
    property Visible;
  end;
  TEasyItemStoredClass = class of TEasyItemStored;

  // **************************************************************************
  // TEasyCollection
  //    Basis for Collection (TEasyItems, TEasyGroups, TEasyColumns)
  // **************************************************************************
  TEasyCollection = class(TEasyOwnedPersistent)
  private
    FItemClass: TEasyCollectionItemClass;
    FList: TList;
    FReIndexCount: Integer;
    FStoreInDFM: Boolean;
    FStreamVersion: Integer; // Version of stream to allow proper reading
    FTag: Integer;
    FVisibleList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TEasyCollectionItem;
    function GetOwnerListview: TCustomEasyListview;
    function GetReIndexDisable: Boolean;
    function GetVisibleCount: Integer;
    procedure SetItem(Index: Integer; Value: TEasyCollectionItem);
    procedure SetReIndexDisable(const Value: Boolean);
  protected
    function DoStore: Boolean; dynamic;
    function GetOwner: TPersistent; override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure DoItemAdd(Item: TEasyCollectionItem; Index: Integer); virtual;
    procedure DoStructureChange; virtual;
    property List: TList read FList write FList;
    property ReIndexCount: Integer read FReIndexCount write FReIndexCount;
    property StreamVersion: Integer read FStreamVersion write FStreamVersion;
    property VisibleList: TList read FVisibleList write FVisibleList;
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
    destructor Destroy; override;

    function Add(Data: TObject = nil): TEasyCollectionItem;
    procedure BeginUpdate(ReIndex: Boolean); virtual;
    procedure Clear(FreeItems: Boolean = True); virtual;
    procedure Delete(Index: Integer);
    procedure EndUpdate(Invalidate: Boolean = True); virtual;
    function Insert(Index: Integer; Data: TObject = nil): TEasyCollectionItem;
    procedure Exchange(Index1, Index2: Integer);
    procedure ReadItems(Stream: TStream); virtual;
    procedure ReIndexItems;
    procedure WriteItems(Stream: TStream); virtual;

    property Count: Integer read GetCount;
    property ItemClass: TEasyCollectionItemClass read FItemClass;
    property Items[Index: Integer]: TEasyCollectionItem read GetItem write SetItem; default;
    property OwnerListview: TCustomEasyListview read GetOwnerListview;
    property ReIndexDisable: Boolean read GetReIndexDisable write SetReIndexDisable;
    property StoreInDFM: Boolean read FStoreInDFM write FStoreInDFM default True;
    property VisibleCount: Integer read GetVisibleCount;
  published
    property Tag: Integer read FTag write FTag default 0;
  end;
  TEasyCollectionClass = class of TEasyCollection;

  // **************************************************************************
  // TEasyViewItem
  //    Basis for the UI (drawing, and mouse interaction) for a TEasyItem
  // **************************************************************************
  TEasyViewItem = class(TEasyOwnedPersistentGroupItem)
  protected
    function AllowDrag(Item: TEasyItem; ViewportPoint: TPoint): Boolean; virtual;
  public
    procedure CalculateTextRect(Item: TEasyItem; Column: TEasyColumn; var TextR: TRect; ACanvas: TControlCanvas);
    function EditAreaHitPt(Item: TEasyItem; ViewportPoint: TPoint): Boolean; virtual;
    function ExpandIconR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect; virtual;
    function ExpandTextR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect; virtual;
    function FullRowSelect: Boolean; virtual;
    function ItemRect(Item: TEasyItem; Column: TEasyColumn; RectType: TEasyCellRectType): TRect; virtual;
    function GetImageList(Column: TEasyColumn; Item: TEasyItem): TImageList; virtual;
    procedure GetImageSize(Item: TEasyItem; Column: TEasyColumn; var ImageW, ImageH: Integer);
    procedure ItemRectArray(Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas; const Caption: WideString; var RectArray: TEasyRectArrayObject); virtual;
    procedure LoadTextFont(Item: TEasyItem; Position: Integer; ACanvas: TCanvas; Hilightable: Boolean); virtual;
    function OverlappedFocus: Boolean; virtual;
    procedure Paint(Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas; ViewportClipRect: TRect; ForceSelectionRectDraw: Boolean); virtual;
    procedure PaintAfter(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; ACanvas: TCanvas; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; ACanvas: TCanvas; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintCheckBox(Item: TEasyItem; Column: TEasyColumn; RectArray: TEasyRectArrayObject; ACanvas: TCanvas); virtual;
    procedure PaintFocusRect(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; RectArray: TEasyRectArrayObject; ACanvas: TCanvas); virtual;
    procedure PaintImage(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; RectArray: TEasyRectArrayObject; ImageSize: TEasyImageSize; ACanvas: TCanvas); virtual;
    function PaintImageSize: TEasyImageSize; virtual;
    procedure PaintSelectionRect(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; RectArray: TEasyRectArrayObject; ACanvas: TCanvas; ViewportClipRect: TRect; ForceSelectionRectDraw: Boolean); virtual;
    procedure PaintText(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; RectArray: TEasyRectArrayObject; ACanvas: TCanvas; LinesToDraw: Integer); virtual;
    function PaintTextAlignment(Item: TEasyItem; Column: TEasyColumn): TAlignment; virtual;
    function PaintTextLineCount(Item: TEasyItem; Column: TEasyColumn): Integer; virtual;
    function PaintTextVAlignment(Item: TEasyItem; Column: TEasyColumn): TEasyVAlignment; virtual;
    function PtInRect(Item: TEasyItem; Column: TEasyColumn; Pt: TPoint): Integer; virtual;
    procedure ReSizeRectArray(var RectArray: TEasyRectArrayObjectArray); virtual;
    function SelectionHit(Item: TEasyItem; SelectViewportRect: TRect; SelectType: TEasySelectHitType): Boolean; virtual;
    function SelectionHitPt(Item: TEasyItem; ViewportPoint: TPoint; SelectType: TEasySelectHitType): Boolean; virtual;
    procedure TestAndClipImage(ACanvas: TCanvas; RectArray: TEasyRectArrayObject; var Rgn: HRgn);
    procedure TestAndUnClipImage(ACanvas: TCanvas; RectArray: TEasyRectArrayObject; Rgn: HRgn);
  end;

  // **************************************************************************
  // TEasyViewIconItem
  //    Basis for the UI (drawing, and mouse interaction) for a TEasyItem
  // **************************************************************************
  TEasyViewIconItem = class(TEasyViewItem)
  public
    function ExpandIconR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect; override;
    function OverlappedFocus: Boolean; override;
    function PaintImageSize: TEasyImageSize; override;
    function PaintTextLineCount(Item: TEasyItem; Column: TEasyColumn): Integer; override;
    procedure ItemRectArray(Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas; const Caption: WideString; var RectArray: TEasyRectArrayObject); override;
    procedure PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; ACanvas: TCanvas; RectArray: TEasyRectArrayObject); override;
  end;

  // **************************************************************************
  // TEasyViewSmallIconItem
  //    Basis for the UI (drawing, and mouse interaction) for a TEasyItem
  // **************************************************************************
  TEasyViewSmallIconItem = class(TEasyViewItem)
  public
    function CalculateDisplayRect(Item: TEasyItem; Column: TEasyColumn): TRect; virtual;
    function ExpandIconR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect; override;
    function ExpandTextR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect; override;
    procedure ItemRectArray(Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas; const Caption: WideString; var RectArray: TEasyRectArrayObject); override;
    procedure PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; ACanvas: TCanvas; RectArray: TEasyRectArrayObject); override;
    function PaintTextAlignment(Item: TEasyItem; Column: TEasyColumn): TAlignment; override;
    function PaintTextLineCount(Item: TEasyItem; Column: TEasyColumn): Integer; override;
    function PaintTextVAlignment(Item: TEasyItem; Column: TEasyColumn): TEasyVAlignment; override;
  end;

  // **************************************************************************
  // TEasyViewListItem
  //    Basis for the UI (drawing, and mouse interaction) for a TEasyItem
  // **************************************************************************
  TEasyViewListItem = class(TEasyViewSmallIconItem)
  end;

  // **************************************************************************
  // TEasyViewReportItem
  //    Basis for the UI (drawing, and mouse interaction) for a TEasyItem
  // **************************************************************************
  TEasyViewReportItem = class(TEasyViewSmallIconItem)
  protected
    function AllowDrag(Item: TEasyItem; ViewportPoint: TPoint): Boolean; override;
  public
    function CalculateDisplayRect(Item: TEasyItem; Column: TEasyColumn): TRect; override;
    function ExpandTextR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect; override;
    function FullRowSelect: Boolean; override;
    function SelectionHit(Item: TEasyItem; SelectViewportRect: TRect; SelectType: TEasySelectHitType): Boolean; override;
    function SelectionHitPt(Item: TEasyItem; ViewportPoint: TPoint; SelectType: TEasySelectHitType): Boolean; override;
  end;

  // **************************************************************************
  // TEasyViewGridItem
  //    Basis for the UI (drawing, and mouse interaction) for a TEasyItem
  // **************************************************************************
  TEasyViewGridItem = class(TEasyViewSmallIconItem)
  end;

  // **************************************************************************
  // TEasyViewThumbnailItem
  //    Basis for the UI (drawing, and mouse interaction) for a TEasyItem
  // **************************************************************************
  TEasyViewThumbnailItem = class(TEasyViewItem)
  public
    function ExpandTextR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect; override;
    function GetImageList(Column: TEasyColumn; Item: TEasyItem): TImageList; override;
    function PaintImageSize: TEasyImageSize; override;
    procedure ItemRectArray(Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas; const Caption: WideString; var RectArray: TEasyRectArrayObject); override;
    function OverlappedFocus: Boolean; override;
    procedure PaintAfter(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; ACanvas: TCanvas; RectArray: TEasyRectArrayObject); override;
    procedure PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; ACanvas: TCanvas; RectArray: TEasyRectArrayObject); override;
    function PaintTextLineCount(Item: TEasyItem; Column: TEasyColumn): Integer; override;
    function PaintTextVAlignment(Item: TEasyItem; Column: TEasyColumn): TEasyVAlignment; override;
    function SelectionHit(Item: TEasyItem; SelectViewportRect: TRect; SelectType: TEasySelectHitType): Boolean; override;
    function SelectionHitPt(Item: TEasyItem; ViewportPoint: TPoint; SelectType: TEasySelectHitType): Boolean; override;
  end;

  // **************************************************************************
  // TEasyViewTileItem
  //    Basis for the UI (drawing, and mouse interaction) for a TEasyItem
  // **************************************************************************
  TEasyViewTileItem = class(TEasyViewItem)
  public
    function ExpandIconR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect; override;
    function ExpandTextR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect; override;
    function GetImageList(Column: TEasyColumn; Item: TEasyItem): TImageList; override;
    function PaintImageSize: TEasyImageSize; override;
    function PaintTextAlignment(Item: TEasyItem; Column: TEasyColumn): TAlignment; override;
    procedure ItemRectArray(Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas; const Caption: WideString; var RectArray: TEasyRectArrayObject); override;
    procedure PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; ACanvas: TCanvas; RectArray: TEasyRectArrayObject); override;
    procedure PaintText(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; RectArray: TEasyRectArrayObject; ACanvas: TCanvas; LinesToDraw: Integer); override;
  end;

  // **************************************************************************
  // TEasyViewFilmStripItem
  //    Basis for the UI (drawing, and mouse interaction) for a TEasyItem
  // **************************************************************************
  TEasyViewFilmStripItem = class(TEasyViewThumbnailItem)
  end;

  // **************************************************************************
  // TEasyViewTaskBandItem
  //    Basis for the UI (drawing, and mouse interaction) for a TEasyItem in the
  // Taskband control
  // **************************************************************************
  TEasyViewTaskBandItem = class(TEasyViewSmallIconItem)
  public
  end;

  // **************************************************************************
  // TEasyItems
  //   Collection that contains all the Items within a Group in the control
  // **************************************************************************
  TEasyItems = class(TEasyCollection)
  private
    FOwnerGroup: TEasyGroup;
    function GetItem(Index: Integer): TEasyItem;
    procedure SetItem(Index: Integer; Value: TEasyItem);
  protected
    procedure DoStructureChange; override;
  public
    constructor Create(AnOwner: TCustomEasyListview; AnOwnerGroup: TEasyGroup); reintroduce; virtual;
    destructor Destroy; override;

    function Add(Data: TObject = nil): TEasyItem;
    function AddInterfaced(const DataInf: IUnknown; Data: TObject = nil): TEasyItemInterfaced;
    function AddVirtual(Data: TObject = nil): TEasyItemVirtual;
    function AddCustom(CustomItem: TEasyItemClass; Data: TObject = nil): TEasyItem;
    procedure Clear(FreeItems: Boolean = True); override;
    procedure Delete(Index: Integer); reintroduce;
    procedure Exchange(Index1, Index2: Integer); reintroduce;
    function Insert(Index: Integer; Data: TObject = nil): TEasyItem;
    function InsertCustom(Index: Integer; CustomItem: TEasyItemClass; Data: TObject = nil): TEasyItem;
    function InsertInterfaced(Index: Integer; const DataInf: IUnknown; Data: TObject = nil): TEasyItemInterfaced;
    function InsertVirtual(Index: Integer; Data: TObject = nil): TEasyItemVirtual;
    property Items[Index: Integer]: TEasyItem read GetItem write SetItem; default;
    property OwnerGroup: TEasyGroup read FOwnerGroup;
  end;

  // **************************************************************************
  // TEasyGlobalItems
  //   Convenience TListview migration items
  // **************************************************************************
  TEasyGlobalItems = class
  private
    FOwner: TCustomEasyListview;
    function GetCount: Integer;
    function GetItem(Index: Integer): TEasyItem;
    function GetItemInternal(Index: Integer): TEasyItem;
    function GetLastGroup: TEasyGroup;
    procedure EnsureFirstGroup;
    procedure IndexError(Index: Integer);
    procedure SetItem(Index: Integer; const Value: TEasyItem);
    procedure SetReIndexDisable(const Value: Boolean);
  public
    constructor Create(AnOwner: TCustomEasyListview);

    function Add(Data: TObject = nil): TEasyItem;
    function AddCustom(CustomItem: TEasyItemClass; Data: TObject = nil): TEasyItem;
    function AddInterfaced(const DataInf: IUnknown; Data: TObject = nil): TEasyItemInterfaced;
    function AddVirtual(Data: TObject = nil): TEasyItemVirtual;
    function IndexOf(Item: TEasyItem): Integer;
    function Insert(Index: Integer; Data: TObject = nil): TEasyItem;
    function InsertCustom(Index: Integer; CustomItem: TEasyItemClass; Data: TObject = nil): TEasyItem;
    function InsertInterfaced(Index: Integer; const DataInf: IUnknown; Data: TObject = nil): TEasyItemInterfaced;
    function InsertVirtual(Index: Integer; Data: TObject = nil): TEasyItemVirtual;
    procedure Clear;
    procedure Delete(Index: Integer; ReIndex: Boolean = True);
    procedure Exchange(Index1, Index2: Integer);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TEasyItem read GetItem write SetItem; default;
    property OwnerListview: TCustomEasyListview read FOwner;
    property ReIndexDisable: Boolean write SetReIndexDisable;
  end;

  // **************************************************************************
  // TEasyGlobalImageManager
  //   Manages images and bitmaps that are used in the EasyControl such as
  // expand "+" buttons, etc.
  // **************************************************************************
  TEasyGlobalImageManager = class(TEasyOwnedPersistent)
  private
    FGroupExpandButton: TBitmap;
    FGroupCollapseButton: TBitmap;
    FColumnSortUp: TBitmap;
    FColumnSortDown: TBitmap;
    function GetColumnSortDown: TBitmap;
    function GetColumnSortUp: TBitmap;
    function GetGroupCollapseImage: TBitmap;
    function GetGroupExpandImage: TBitmap;
    procedure SetColumnSortDown(Value: TBitmap);
    procedure SetColumnSortUp(Value: TBitmap);
    procedure SetGroupCollapseImage(const Value: TBitmap);
    procedure SetGroupExpandImage(const Value: TBitmap);
  protected
    procedure MakeTransparent(Bits: TBitmap; TransparentColor: TColor);
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
    destructor Destroy; override;
  published
    property GroupExpandButton: TBitmap read GetGroupExpandImage write SetGroupExpandImage;
    property GroupCollapseButton: TBitmap read GetGroupCollapseImage write SetGroupCollapseImage;
    property ColumnSortUp: TBitmap read GetColumnSortUp write SetColumnSortUp;
    property ColumnSortDown: TBitmap read GetColumnSortDown write SetColumnSortDown;
  end;

  // **************************************************************************
  // TEasyGridGroup
  //   Builds the Grid for the Group, by default the grid fits in the OwnerWindow
  // horizontally and wraps down
  // **************************************************************************
  TEasyGridGroup = class(TEasyOwnedPersistent)
  private
    FColumnCount: Integer;        // Number of Columns in the grid
    FLayout: TEasyGridLayout;
    FOwnerGroup: TEasyGroup;      // The group that the grid is attached to
    FRowCount: Integer;           // The number of Rows in the group
    function GetOwnerGroups: TEasyGroups;
    
  protected
    function AdjacentItem(Item: TEasyItem; Direction: TEasyAdjacentCellDir): TEasyItem; virtual;
    function GetCellSize: TEasyCellSize; virtual; abstract;
    function GetMaxColumns(Group: TEasyGroup; WindowWidth: Integer): Integer; virtual;
    function LastItemInNColumn(Group: TEasyGroup; N: Integer): TEasyItem;
    function NextVisibleGroupWithNItems(StartGroup: TEasyGroup; N: Integer): TEasyGroup;
    function PrevVisibleGroupWithNItems(StartGroup: TEasyGroup; N: Integer): TEasyGroup;
    function SearchForHitRight(ColumnPos: Integer; Pt: TPoint): TEasyItem;
    function StaticTopItemMargin: Integer; virtual;
    function StaticTopMargin: Integer; virtual;
    procedure SetCellSize(Value: TEasyCellSize); virtual; abstract;
  public
    constructor Create(AnOwner: TCustomEasyListview; AnOwnerGroup: TEasyGroup); reintroduce; virtual;
    destructor Destroy; override;
    procedure Rebuild(PrevGroup: TEasyGroup; var NextVisibleItemIndex: Integer); virtual;

    property CellSize: TEasyCellSize read GetCellSize write SetCellSize;
    property ColumnCount: Integer read FColumnCount;
    property Layout: TEasyGridLayout read FLayout;
    property OwnerGroup: TEasyGroup read FOwnerGroup;
    property OwnerGroups: TEasyGroups read GetOwnerGroups;
    property RowCount: Integer read FRowCount;
  end;

  // **************************************************************************
  // TEasyGridIconGroup
  //   Builds the Large Icon Grid for the Group
  // **************************************************************************
  TEasyGridIconGroup = class(TEasyGridGroup)
  protected
    function GetCellSize: TEasyCellSize; override;
    procedure SetCellSize(Value: TEasyCellSize); override;
  end;

  // **************************************************************************
  // TEasyGridSmallIconGroup
  //   Builds the Small Icon Grid for the Group
  // **************************************************************************
  TEasyGridSmallIconGroup = class(TEasyGridGroup)
  protected
    function GetCellSize: TEasyCellSize; override;
    procedure SetCellSize(Value: TEasyCellSize); override;
  end;

  // **************************************************************************
  // TEasyGridListGroup
  //   Builds the List Grid for the Group
  // **************************************************************************
  TEasyGridListGroup = class(TEasyGridGroup)
  protected
    function AdjacentItem(Item: TEasyItem; Direction: TEasyAdjacentCellDir): TEasyItem; override;
    function GetCellSize: TEasyCellSize; override;
    procedure SetCellSize(Value: TEasyCellSize); override;
  public
    constructor Create(AnOwner: TCustomEasyListview; AnOwnerGroup: TEasyGroup); override;
    procedure Rebuild(PrevGroup: TEasyGroup; var NextVisibleItemIndex: Integer); override;
  end;

  // **************************************************************************
  // TEasyGridReportGroup
  //   Builds the Report Grid for the Group
  // **************************************************************************
  TEasyGridReportGroup = class(TEasyGridGroup)
  protected
    function AdjacentItem(Item: TEasyItem; Direction: TEasyAdjacentCellDir): TEasyItem; override;
    function GetCellSize: TEasyCellSize; override;
    procedure SetCellSize(Value: TEasyCellSize); override;
  public
    constructor Create(AnOwner: TCustomEasyListview; AnOwnerGroup: TEasyGroup); override;
    procedure Rebuild(PrevGroup: TEasyGroup; var NextVisibleItemIndex: Integer); override;
  end;

  // **************************************************************************
  // TEasyGridThumbnailGroup
  //   Builds the Thumbnail Grid for the Group
  // **************************************************************************
  TEasyGridThumbnailGroup = class(TEasyGridGroup)
  protected
    function GetCellSize: TEasyCellSize; override;
    procedure SetCellSize(Value: TEasyCellSize); override;
  end;

  // **************************************************************************
  // TEasyGridTileGroup
  //   Builds the Tile Grid for the Group
  // **************************************************************************
  TEasyGridTileGroup = class(TEasyGridGroup)
  protected
    function GetCellSize: TEasyCellSize; override;
    procedure SetCellSize(Value: TEasyCellSize); override;
  end;

  // **************************************************************************
  // TEasyGridFilmStripGroup
  //   Builds the List Grid for the Group
  // **************************************************************************
  TEasyGridFilmStripGroup = class(TEasyGridListGroup)
  protected
    function GetCellSize: TEasyCellSize; override;
    procedure SetCellSize(Value: TEasyCellSize); override;
  end;

  // **************************************************************************
  // TEasyGridGridGroup
  //   Builds the Report Grid for the Group
  // **************************************************************************
  TEasyGridGridGroup = class(TEasyGridGroup)
  protected
    function GetCellSize: TEasyCellSize; override;
    procedure SetCellSize(Value: TEasyCellSize); override;
  public
    constructor Create(AnOwner: TCustomEasyListview; AnOwnerGroup: TEasyGroup); override;
    procedure Rebuild(PrevGroup: TEasyGroup; var NextVisibleItemIndex: Integer); override;
  end;

  TGridSingleColumn = class(TEasyGridGroup)
  protected
    function GetMaxColumns(Group: TEasyGroup; WindowWidth: Integer): Integer; override;
  end;

  // **************************************************************************
  // TGridTaskBandGroup
  //   Builds the Report Grid for the Group in the Taskband control
  // **************************************************************************
  TGridTaskBandGroup = class(TGridSingleColumn)
  private
    FCellSize: TEasyCellSize;
  protected
    function GetCellSize: TEasyCellSize; override;
    function StaticTopItemMargin: Integer; override;
    function StaticTopMargin: Integer; override;
    procedure SetCellSize(Value: TEasyCellSize); override;
    property CellSize: TEasyCellSize read FCellSize write FCellSize;
  public
    constructor Create(AnOwner: TCustomEasyListview; AnOwnerGroup: TEasyGroup); override;
    destructor Destroy; override;
  end;

  // **************************************************************************
  // TEasyGroupBase
  //   Collection Item that represents a single group in the Listview
  // **************************************************************************
  TEasyGroup = class(TEasyCollectionItem)
  private
    FExpanded: Boolean;           // Is the group expanded/collapsed
    FGrid: TEasyGridGroup;        // The UI grid that defines the item positions
    FGroupView: TEasyViewGroup;   // The UI drawing object for the Group
    FItems: TEasyItems;           // The List of Items (TEasyItems) in the group
    FItemView: TEasyViewItem;     // The UI drawing object for each Item in the group
    FKey: LongWord;
    FVisibleItems: TList;
    function GetBandBlended: Boolean;
    function GetBandColor: TColor;
    function GetBandColorFade: TColor;
    function GetBandEnabled: Boolean;
    function GetBandFullWidth: Boolean;
    function GetBandIndent: Integer;
    function GetBandLength: Integer;
    function GetBandMargin: Integer;
    function GetBandRadius: Byte;
    function GetBandThickness: Integer;
    function GetClientRect: TRect;
    function GetExpandable: Boolean;
    function GetExpandImageIndent: Integer;
    function GetItem(Index: Integer): TEasyItem;
    function GetItemCount: Integer;
    function GetMarginBottom: TEasyFooterMargin;
    function GetMarginLeft: TEasyMargin;
    function GetMarginRight: TEasyMargin;
    function GetMarginTop: TEasyHeaderMargin;
    function GetOwnerGroups: TEasyGroups;
    function GetOwnerListview: TCustomEasyListview;
    function GetPaintInfo: TEasyPaintInfoBaseGroup;
    function GetVisibleCount: Integer;
    function GetVisibleItem(Index: Integer): TEasyItem;
    procedure SetBandBlended(Value: Boolean);
    procedure SetBandColor(Value: TColor);
    procedure SetBandColorFade(Value: TColor);
    procedure SetBandEnabled(Value: Boolean);
    procedure SetBandFullWidth(Value: Boolean);
    procedure SetBandIndent(Value: Integer);
    procedure SetBandLength(Value: Integer);
    procedure SetBandMargin(Value: Integer);
    procedure SetBandRadius(Value: Byte);
    procedure SetBandThickness(Value: Integer);
    procedure SetExpandable(Value: Boolean);
    procedure SetExpanded(Value: Boolean);
    procedure SetExpandImageIndent(Value: Integer);
    procedure SetGrid(Value: TEasyGridGroup);
    procedure SetGroupView(Value: TEasyViewGroup);
    procedure SetItem(Index: Integer; Value: TEasyItem);
    procedure SetItemView(Value: TEasyViewItem);
    procedure SetMarginBottom(Value: TEasyFooterMargin);
    procedure SetMarginLeft(Value: TEasyMargin);
    procedure SetMarginRight(Value: TEasyMargin);
    procedure SetMarginTop(Value: TEasyHeaderMargin);
    procedure SetPaintInfo(const Value: TEasyPaintInfoBaseGroup);
  protected
    function CanChangeBold(NewValue: Boolean): Boolean; override;
    function CanChangeCheck(NewValue: Boolean): Boolean; override;
    function CanChangeEnable(NewValue: Boolean): Boolean; override;
    function CanChangeFocus(NewValue: Boolean): Boolean; override;
    function CanChangeHotTracking(NewValue: Boolean): Boolean; override;
    function CanChangeSelection(NewValue: Boolean): Boolean; override;
    function CanChangeVisibility(NewValue: Boolean): Boolean; override;
    function DefaultImageList(ImageSize: TEasyImageSize): TImageList; override;
    function LocalPaintInfo: TEasyPaintInfoBasic; override;
    procedure Freeing; override;
    procedure GainingBold; override;
    procedure GainingCheck; override;
    procedure GainingEnable; override;
    procedure GainingFocus; override;
    procedure GainingHilight; override;
    procedure GainingHotTracking(MousePos: TPoint); override;
    procedure GainingSelection; override;
    procedure GainingVisibility; override;
    procedure Initialize; override;
    procedure LosingBold; override;
    procedure LosingCheck; override;
    procedure LosingEnable; override;
    procedure LosingFocus; override;
    procedure LosingHilight; override;
    procedure LosingHotTracking; override;
    procedure LosingSelection; override;
    procedure LosingVisibility; override;
    property Alignment;
    property BandBlended: Boolean read GetBandBlended write SetBandBlended default True;
    property BandColor: TColor read GetBandColor write SetBandColor default clBlue;
    property BandColorFade: TColor read GetBandColorFade write SetBandColorFade default clWindow;
    property BandEnabled: Boolean read GetBandEnabled write SetBandEnabled default True;
    property BandFullWidth: Boolean read GetBandFullWidth write SetBandFullWidth default False;
    property BandIndent: Integer read GetBandIndent write SetBandIndent default 0;
    property BandLength: Integer read GetBandLength write SetBandLength default 300;
    property BandMargin: Integer read GetBandMargin write SetBandMargin default 2;
    property BandRadius: Byte read GetBandRadius write SetBandRadius default 4;
    property BandThickness: Integer read GetBandThickness write SetBandThickness default 3;
    property CaptionIndent;
    property CheckFlat;
    property CheckIndent;
    property CheckSize;
    property CheckType;
    property Expandable: Boolean read GetExpandable write SetExpandable default True;
    property ExpandImageIndent: Integer read GetExpandImageIndent write SetExpandImageIndent default 4;
    property ImageIndent;
    property Key: LongWord read FKey write FKey;
    property MarginBottom: TEasyFooterMargin read GetMarginBottom write SetMarginBottom;
    property MarginLeft: TEasyMargin read GetMarginLeft write SetMarginLeft;
    property MarginRight: TEasyMargin read GetMarginRight write SetMarginRight;
    property MarginTop: TEasyHeaderMargin read GetMarginTop write SetMarginTop;
    property OwnsPaintInfo;
    property PaintInfo: TEasyPaintInfoBaseGroup read GetPaintInfo write SetPaintInfo;
    property VAlignment default evaCenter;
    property VisibleItem[Index: Integer]: TEasyItem read GetVisibleItem;
    property VisibleItems: TList read FVisibleItems write FVisibleItems;
  public
    constructor Create(ACollection: TEasyCollection); override;
    destructor Destroy; override;

    function BoundsRectBkGnd: TRect;
    function BoundsRectBottomMargin: TRect;
    function BoundsRectLeftMargin: TRect;
    function BoundsRectRightMargin: TRect;
    function BoundsRectTopMargin: TRect;
    function EditAreaHitPt(ViewportPoint: TPoint): Boolean; override;
    function HitTestAt(ViewportPoint: TPoint; var HitInfo: TEasyGroupHitTestInfoSet): Boolean;
    function ItemByPoint(ViewportPoint: TPoint): TEasyItem;
    procedure LoadFromStream(S: TStream; Version: Integer = STREAM_VERSION); override;
    procedure Paint(MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; ACanvas: TCanvas);
    procedure Rebuild(PrevGroup: TEasyGroup; var NextVisibleItemIndex: Integer);
    function SelectionHit(SelectViewportRect: TRect; SelectType: TEasySelectHitType): Boolean; override;
    function SelectionHitPt(ViewportPoint: TPoint; SelectType: TEasySelectHitType): Boolean; override;
    procedure SaveToStream(S: TStream; Version: Integer = STREAM_VERSION); override;
    property Bold;
    property Caption;
    property Checked;
    property ClientRect: TRect read GetClientRect;
    property Cut;
    property Enabled;
    property Expanded: Boolean read FExpanded write SetExpanded default True;
    property Focused;
    property Grid: TEasyGridGroup read FGrid write SetGrid;
    property GroupView: TEasyViewGroup read FGroupView write SetGroupView;
    property ImageIndex;
    property ImageOverlayIndex;
    property Item[Index: Integer]: TEasyItem read GetItem write SetItem; default;
    property ItemCount: Integer read GetItemCount;
    property Items: TEasyItems read FItems write FItems;
    property ItemView: TEasyViewItem read FItemView write SetItemView;
    property OwnerListview: TCustomEasyListview read GetOwnerListview;
    property OwnerGroups: TEasyGroups read GetOwnerGroups;
    property Visible;
    property VisibleCount: Integer read GetVisibleCount;
  end;

  TEasyGroupInterfaced = class(TEasyGroup)
  protected
    function GetCaptions(Line: Integer): Widestring; override;
    function GetDetailCount: Integer; override;
    function GetDetails(Line: Integer): Integer; override;
    function GetImageIndexes(Column: Integer): Integer; override;
    function GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList; override;
    function GetImageOverlayIndexes(Column: Integer): Integer; override;
    procedure ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender); override;
    procedure ImageDrawGetSize(Column: TEasyColumn; var ImageW: Integer; var ImageH: Integer); override;
    procedure ImageDrawIsCustom(Column: TEasyColumn; var IsCustom: Boolean); override;
    procedure SetCaptions(Column: Integer; Value: Widestring); override;
    procedure SetDetailCount(Value: Integer); override;
    procedure SetDetails(Line: Integer; Value: Integer); override;
    procedure SetImageIndexes(Column: Integer; Value: Integer); override;
    procedure SetImageOverlayIndexes(Column: Integer; Value: Integer); override;
    procedure ThumbnailDraw(ACanvas: TCanvas; ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean); override;
  public
    property DataInf;
  end;

  TEasyGroupStored = class(TEasyGroup)
  private
    FDataHelper: TEasyDynamicDataHelper;
  protected
    function GetCaptions(Line: Integer): Widestring; override;
    function GetDetailCount: Integer; override;
    function GetDetails(Line: Integer): Integer; override;
    function GetImageIndexes(Column: Integer): Integer; override;
    function GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList; override;
    function GetImageOverlayIndexes(Column: Integer): Integer; override;
    procedure ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender); override;
    procedure ImageDrawGetSize(Column: TEasyColumn; var ImageW: Integer; var ImageH: Integer); override;
    procedure ImageDrawIsCustom(Column: TEasyColumn; var IsCustom: Boolean); override;
    procedure SetCaptions(Column: Integer; Value: Widestring); override;
    procedure SetDetailCount(Value: Integer); override;
    procedure SetDetails(Line: Integer; Value: Integer); override;
    procedure SetImageIndexes(Column: Integer; Value: Integer); override;
    procedure SetImageOverlayIndexes(Column: Integer; Value: Integer); override;
    procedure ThumbnailDraw(ACanvas: TCanvas; ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean); override;
    property DataHelper: TEasyDynamicDataHelper read FDataHelper write FDataHelper;
  public
    constructor Create(ACollection: TEasyCollection); override;
    destructor Destroy; override;
    procedure LoadFromStream(S: TStream; Version: Integer = STREAM_VERSION); override;
    procedure SaveToStream(S: TStream; Version: Integer = STREAM_VERSION); override;
  published
    property Caption;
    property Bold;
    property Checked;
    property Cut;
    property Enabled;
    property Expanded;
    property ImageIndex;
    property ImageOverlayIndex;
    property Items;
    property OwnsPaintInfo;
    property Tag;
    property Visible;
  end;

  TEasyGroupVirtual = class(TEasyGroup)
  protected
    function GetCaptions(Line: Integer): Widestring; override;
    function GetDetailCount: Integer; override;
    function GetDetails(Line: Integer): Integer; override;
    function GetImageIndexes(Column: Integer): Integer; override;
    function GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList; override;
    function GetImageOverlayIndexes(Column: Integer): Integer; override;
    procedure ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender); override;
    procedure ImageDrawGetSize(Column: TEasyColumn; var ImageW: Integer; var ImageH: Integer); override;
    procedure ImageDrawIsCustom(Column: TEasyColumn; var IsCustom: Boolean); override;
    procedure SetCaptions(Column: Integer; Value: Widestring); override;
    procedure SetDetailCount(Value: Integer); override;
    procedure SetDetails(Line: Integer; Value: Integer); override;
    procedure SetImageIndexes(Column: Integer; Value: Integer); override;
    procedure SetImageOverlayIndexes(Column: Integer; Value: Integer); override;
    procedure ThumbnailDraw(ACanvas: TCanvas; ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean); override;
  end;

  // **************************************************************************
  // TEasyViewGroup
  //    Implements the basis for the UI (drawing, and mouse interaction) for a EasyGroup
  // **************************************************************************
  TEasyViewGroup = class(TEasyOwnedPersistentGroupItem)
  protected
    function CustomExpandImages: Boolean;
    procedure GetCollapseExpandImages(var Expand, Collapse: TBitmap);
  public
    function EditAreaHitPt(Group: TEasyGroup; ViewportPoint: TPoint): Boolean; virtual;
    function GetImageList(Group: TEasyGroup): TImageList;
    procedure GetExpandImageSize(Group: TEasyGroup; var ImageW, ImageH: Integer); virtual;
    procedure GetImageSize(Group: TEasyGroup; var ImageW, ImageH: Integer); virtual;
    procedure GroupRectArray(Group: TEasyGroup; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; var RectArray: TEasyRectArrayObject); virtual;
    procedure LoadTextFont(Group: TEasyGroup; ACanvas: TCanvas); virtual;
    procedure Paint(Group: TEasyGroup; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; ACanvas: TCanvas); virtual;
    procedure PaintAfter(Group: TEasyGroup; ACanvas: TCanvas; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintBackground(Group: TEasyGroup; ACanvas: TCanvas; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintBand(Group: TEasyGroup; ACanvas: TCanvas; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintBefore(Group: TEasyGroup; ACanvas: TCanvas; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintCheckBox(Group: TEasyGroup; ACanvas: TCanvas; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintExpandButton(Group: TEasyGroup; ACanvas: TCanvas; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintFocusRect(Group: TEasyGroup; ACanvas: TCanvas; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintImage(Group: TEasyGroup; ACanvas: TCanvas; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintSelectionRect(Group: TEasyGroup; ACanvas: TCanvas; ObjRect: TRect; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintText(Group: TEasyGroup; MarginEdge: TEasyGroupMarginEdge; ACanvas: TCanvas; ObjRect: TRect; RectArray: TEasyRectArrayObject); virtual;
    function SelectionHit(Group: TEasyGroup; SelectViewportRect: TRect; SelectType: TEasySelectHitType): Boolean; virtual;
    function SelectionHitPt(Group: TEasyGroup; ViewportPoint: TPoint; SelectType: TEasySelectHitType): Boolean; virtual;
  end;
  TEasyViewGroupClass = class of TEasyViewGroup;

  // **************************************************************************
  // TEasyViewTaskBandGroup
  //    Implements the basis for the UI (drawing, and mouse interaction) for a EasyGroup
  // in the TaskBand control
  // **************************************************************************
  TEasyViewTaskBandGroup = class(TEasyViewGroup)
  protected
  public
    procedure GetExpandImageSize(Group: TEasyGroup; var ImageW: Integer; var ImageH: Integer); override;
    procedure GroupRectArray(Group: TEasyGroup; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; var RectArray: TEasyRectArrayObject); override;
    procedure LoadTextFont(Group: TEasyGroup; ACanvas: TCanvas); override;
    procedure PaintBackground(Group: TEasyGroup; ACanvas: TCanvas; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject); override;
    procedure PaintBand(Group: TEasyGroup; ACanvas: TCanvas; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject); override;
    procedure PaintExpandButton(Group: TEasyGroup; ACanvas: TCanvas; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject); override;
    procedure PaintText(Group: TEasyGroup; MarginEdge: TEasyGroupMarginEdge; ACanvas: TCanvas; ObjRect: TRect; RectArray: TEasyRectArrayObject); override;
  end;

  // **************************************************************************
  // TEasyGroups
  //   Collection that contains all the Groups in the control
  // **************************************************************************
  TEasyGroups = class(TEasyCollection)
  private
    FDefaultGrid: TEasyGridGroupClass;
    FDefaultGroupView: TEasyViewGroupClass;
    FDefaultItemView: TEasyViewItemClass;
    FGroupsState: TEasyGroupsStates;
    FStreamGroups: Boolean;
    function GetCellHeight: Integer;
    function GetCellWidth: Integer;
    function GetGroup(Index: Integer): TEasyGroup;
    function GetItemCount: Integer;
    function GetViewRect: TRect;
    function GetVisibleGroup(Index: Integer): TEasyGroup;
    procedure SetCellHeight(Value: Integer);
    procedure SetCellWidth(Value: Integer);
    procedure SetGroup(Index: Integer; Value: TEasyGroup);
  protected
    function FirstGroupInternal(VisibleOnly: Boolean): TEasyGroup;
    function FirstInGroupInternal(Group: TEasyGroup; VisibleOnly: Boolean): TEasyItem;
    function FirstItemInternal(NextItemType: TEasyNextItemType): TEasyItem;
    function LastGroupInternal(VisibleOnly: Boolean): TEasyGroup;
    function LastInGroupInternal(Group: TEasyGroup; VisibleOnly: Boolean): TEasyItem;
    function LastItemInternal(NextItemType: TEasyNextItemType): TEasyItem;
    function NavigateGroupInternal(Group: TEasyGroup; VisibleOnly: Boolean; Direction: TEasySearchDirection): TEasyGroup;
    function NavigateInGroupInternal(Group: TEasyGroup; Item: TEasyItem; VisibleOnly: Boolean; Direction: TEasySearchDirection): TEasyItem;
    function NavigateItemInternal(Item: TEasyItem; NextItemType: TEasyNextItemType; Direction: TEasySearchDirection): TEasyItem;
    procedure DoStructureChange; override;
    property GroupsState: TEasyGroupsStates read FGroupsState write FGroupsState;
    property VisibleGroup[Index: Integer]: TEasyGroup read GetVisibleGroup;
  public
    constructor Create(AnOwner: TCustomEasyListview); reintroduce; virtual;
    destructor Destroy; override;

    function Add(Data: TObject = nil): TEasyGroup;
    function AddInterfaced(const DataInf: IUnknown; Data: TObject = nil): TEasyGroupInterfaced;
    function AddVirtual(Data: TObject = nil): TEasyGroupVirtual;
    function AddCustom(CustomGroup: TEasyGroupClass; Data: TObject = nil): TEasyGroup;
    function AdjacentItem(Item: TEasyItem; Direction: TEasyAdjacentCellDir): TEasyItem; 
    procedure Clear(FreeItems: Boolean = True); override;
    procedure CollapseAll;
    procedure DeleteGroup(Group: TEasyGroup);
    procedure DeleteItem(Item: TEasyItem);
    procedure DeleteItems(ItemArray: TEasyItemArray);
    procedure ExpandAll;
    function FirstGroup: TEasyGroup;
    function FirstGroupInRect(ViewportRect: TRect): TEasyGroup;
    function FirstInGroup(Group: TEasyGroup): TEasyItem;
    function FirstInitializedItem: TEasyItem;
    function FirstItem: TEasyItem;
    function FirstItemInRect(ViewportRect: TRect): TEasyItem;
    function FirstVisibleGroup: TEasyGroup;
    function FirstVisibleInGroup(Group: TEasyGroup): TEasyItem;
    function FirstVisibleItem: TEasyItem;
    function GroupByPoint(ViewportPoint: TPoint): TEasyGroup;
    function Insert(Index: Integer; Data: TObject = nil): TEasyGroup;
    function InsertCustom(Index: Integer; CustomGroup: TEasyGroupClass; Data: TObject = nil): TEasyGroup;
    function InsertInterfaced(Index: Integer; const DataInf: IUnknown; Data: TObject): TEasyGroupInterfaced;
    function InsertVirtual(Index: Integer; Data: TObject = nil): TEasyGroupVirtual;
    procedure InitializeAll;
    procedure InvalidateItem(Item: TEasyCollectionItem; ImmediateUpdate: Boolean);
    function LastGroup: TEasyGroup;
    function LastInGroup(Group: TEasyGroup): TEasyItem;
    function LastInitializedItem: TEasyItem;
    function LastItem: TEasyItem;
    function LastVisibleGroup: TEasyGroup;
    function LastVisibleInGroup(Group: TEasyGroup): TEasyItem;
    function LastVisibleItem: TEasyItem;
    function ItemByPoint(ViewportPoint: TPoint): TEasyItem;
    function NextEditableItem(Item: TEasyItem): TEasyItem;
    function NextGroup(Group: TEasyGroup): TEasyGroup;
    function NextGroupInRect(Group: TEasyGroup; ViewportRect: TRect): TEasyGroup;
    function NextInitializedItem(Item: TEasyItem): TEasyItem;
    function NextInGroup(Group: TEasyGroup; Item: TEasyItem): TEasyItem;
    function NextItem(Item: TEasyItem): TEasyItem;
    function NextItemInRect(Item: TEasyItem; ViewportRect: TRect): TEasyItem;
    function NextVisibleGroup(Group: TEasyGroup): TEasyGroup;
    function NextVisibleGroupWithVisibleItems(Group: TEasyGroup): TEasyGroup;
    function NextVisibleInGroup(Group: TEasyGroup; Item: TEasyItem): TEasyItem;
    function NextVisibleItem(Item: TEasyItem): TEasyItem;
    function PrevEditableItem(Item: TEasyItem): TEasyItem;
    function PrevGroup(Group: TEasyGroup): TEasyGroup;
    function PrevInGroup(Group: TEasyGroup; Item: TEasyItem): TEasyItem;
    function PrevInitializedItem(Item: TEasyItem): TEasyItem;
    function PrevItem(Item: TEasyItem): TEasyItem;
    function PrevVisibleGroup(Group: TEasyGroup): TEasyGroup;
    function PrevVisibleGroupWithVisibleItems(Group: TEasyGroup): TEasyGroup;
    function PrevVisibleInGroup(Group: TEasyGroup; Item: TEasyItem): TEasyItem;
    function PrevVisibleItem(Item: TEasyItem): TEasyItem;
    procedure LoadFromStream(S: TStream); override;
    procedure Move(Item: TEasyItem; NewGroup: TEasyGroup);
    procedure Rebuild(Force: Boolean = False); virtual;
    procedure SaveToStream(S: TStream); override;
//    procedure ReIndexItems(Group: TEasyGroup; Force: Boolean); virtual;
    procedure UnInitializeAll;
    property CellHeight: Integer read GetCellHeight write SetCellHeight;
    property CellWidth: Integer read GetCellWidth write SetCellWidth;
    property DefaultGrid: TEasyGridGroupClass read FDefaultGrid write FDefaultGrid;
    property DefaultGroupView: TEasyViewGroupClass read FDefaultGroupView write FDefaultGroupView;
    property DefaultItemView: TEasyViewItemClass read FDefaultItemView write FDefaultItemView;
    property Groups[Index: Integer]: TEasyGroup read GetGroup write SetGroup; default;
    property ItemCount: Integer read GetItemCount;
    property StreamGroups: Boolean read FStreamGroups write FStreamGroups default True;
    property ViewRect: TRect read GetViewRect;
  end;

  // **************************************************************************
  // TEasyCellSize
  //   Maintains the default sizes for the Cells a single view
  // **************************************************************************
  TEasyCellSize = class(TEasyOwnedPersistent)
  private
    FHeight: Integer;
    FWidth: Integer;
    function GetHeight: Integer;
    function GetWidth: Integer;
    procedure SetHeight(Value: Integer);
    procedure SetWidth(Value: Integer);
  public
    constructor Create(AnOwner: TCustomEasyListview); override;

    procedure Assign(Source: TPersistent); override;
    procedure SetSize(AWidth, AHeight: Integer);
  published
    property Height: Integer read GetHeight write SetHeight default 75;
    property Width: Integer read GetWidth write SetWidth default 75;
  end;

  // **************************************************************************
  // TEasyCellSizeIcon
  //   Maintains the default sizes for the Cells a Icon view
  // **************************************************************************
  TEasyCellSizeIcon = class(TEasyCellSize)
  end;

  // **************************************************************************
  // TEasyCellSizeSmallIcon
  //   Maintains the default sizes for the Cells a Small Icon view
  // **************************************************************************
  TEasyCellSizeSmallIcon = class(TEasyCellSize)
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
  published
    property Width default 200;
    property Height default 17;
  end;

  // **************************************************************************
  // TEasyCellSizeThumbnail
  //   Maintains the default sizes for the Cells a Thumbnail view
  // **************************************************************************
  TEasyCellSizeThumbnail = class(TEasyCellSize)
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
  published
    property Width default 125;
    property Height default 143;
  end;

  // **************************************************************************
  // TEasyCellSizeTile
  //   Maintains the default sizes for the Cells a Tile view
  // **************************************************************************
  TEasyCellSizeTile = class(TEasyCellSize)
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
  published
    property Width default 218;
    property Height default 58;
  end;

  // **************************************************************************
  // TEasyCellSizeList
  //   Maintains the default sizes for the Cells a List view
  // **************************************************************************
  TEasyCellSizeList = class(TEasyCellSize)
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
  published
    property Width default 200;
    property Height default 17;
  end;

  // **************************************************************************
  // TEasyCellSizeReport
  //   Maintains the default sizes for the Cells a Report view
  // **************************************************************************
  TEasyCellSizeReport = class(TEasyCellSize)
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
  published
    property Width default 75;
    property Height default 17;
  end;

  // **************************************************************************
  // TEasyCellSizeFilmStrip
  //   Maintains the default sizes for the Cells a FilmStrip view
  // **************************************************************************
  TEasyCellSizeFilmStrip = class(TEasyCellSizeThumbnail)
  end;

  // **************************************************************************
  // TEasyCellGrid
  //   Maintains the default sizes for the Cells a FilmStrip view
  // **************************************************************************
  TEasyCellGrid = class(TEasyCellSizeReport)
  end;

  // **************************************************************************
  // TEasyCellSizes
  //   Maintains the default sizes for the Cells in each view
  // **************************************************************************
  TEasyCellSizes = class(TEasyOwnedPersistent)
  private
    FFilmStrip: TEasyCellSize;
    FIcon: TEasyCellSize;
    FList: TEasyCellSize;
    FReport: TEasyCellSize;
    FSmallIcon: TEasyCellSize;
    FGrid: TEasyCellSize;
    FThumbnail: TEasyCellSize;
    FTile: TEasyCellSize;
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
    destructor Destroy; override;

  published
    property FilmStrip: TEasyCellSize read FFilmStrip write FFilmStrip;
    property Icon: TEasyCellSize read FIcon write FIcon;
    property SmallIcon: TEasyCellSize read FSmallIcon write FSmallIcon;
    property Grid: TEasyCellSize read FGrid write FGrid;
    property Thumbnail: TEasyCellSize read FThumbnail write FThumbnail;
    property Tile: TEasyCellSize read FTile write FTile;
    property List: TEasyCellSize read FList write FList;
    property Report: TEasyCellSize read FReport write FReport;
  end;

  // **************************************************************************
  // TEasyColumn
  //   Collection Item that represents a single column in the Listview
  // **************************************************************************
  TEasyColumn = class(TEasyCollectionItem)
  private
    FAlignment: TAlignment;
    FAutoSizeOnDblClk: Boolean; // Autosizes column when double clicked in size area
    FAutoSpring: Boolean;       // Sizes column based on width of window
    FAutoToggleSort: Boolean;   // Toggles the Sort Glyph when clicked
    FClickable: Boolean;
    FPosition: Integer;
    FSortDirection: TEasySortDirection;
    FSpringRest: Single;
    FStyle: TEasyHeaderButtonStyle;
    FWidth: Integer;
    function GetAlignment: TAlignment;
    function GetColor: TColor;
    function GetHotTrack: Boolean;
    function GetImagePosition: TEasyHeaderImagePosition;
    function GetOwnerColumns: TEasyColumns;
    function GetOwnerHeader: TEasyHeader;
    function GetPaintInfo: TEasyPaintInfoColumn;
    function GetSortGlyphAlign: TEasySortGlyphAlign;
    function GetSortGlyphIndent: Integer;
    function GetStyle: TEasyHeaderButtonStyle;
    function GetView: TEasyViewColumn;
    procedure SetAlignment(Value: TAlignment);
    procedure SetAutoSpring(const Value: Boolean);
    procedure SetColor(Value: TColor);
    procedure SetHotTrack(Value: Boolean);
    procedure SetImagePosition(Value: TEasyHeaderImagePosition);
    procedure SetPaintInfo(Value: TEasyPaintInfoColumn);
    procedure SetPosition(Value: Integer);
    procedure SetSortDirection(Value: TEasySortDirection);
    procedure SetSortGlpyhAlign(Value: TEasySortGlyphAlign);
    procedure SetSortGlyphIndent(Value: Integer);
    procedure SetStyle(Value: TEasyHeaderButtonStyle);
    procedure SetWidth(Value: Integer);
  protected
    function CanChangeBold(NewValue: Boolean): Boolean; override;
    function CanChangeCheck(NewValue: Boolean): Boolean; override;
    function CanChangeEnable(NewValue: Boolean): Boolean; override;
    function CanChangeFocus(NewValue: Boolean): Boolean; override;
    function CanChangeHotTracking(NewValue: Boolean): Boolean; override;
    function CanChangeSelection(NewValue: Boolean): Boolean; override;
    function CanChangeVisibility(NewValue: Boolean): Boolean; override;
    function DefaultImageList(ImageSize: TEasyImageSize): TImageList; override;
    function LocalPaintInfo: TEasyPaintInfoBasic; override;
    procedure AutoSizeToFit; virtual;
    procedure Freeing; override;
    procedure GainingBold; override;
    procedure GainingCheck; override;
    procedure GainingEnable; override;
    procedure GainingFocus; override;
    procedure GainingHilight; override;
    procedure GainingHotTracking(MousePos: TPoint); override;
    procedure GainingSelection; override;
    procedure GainingVisibility; override;
    procedure Initialize; override;
    procedure LosingBold; override;
    procedure LosingCheck; override;
    procedure LosingEnable; override;
    procedure LosingFocus; override;
    procedure LosingHilight; override;
    procedure LosingHotTracking; override;
    procedure LosingSelection; override;
    procedure LosingVisibility; override;
    property Color: TColor read GetColor write SetColor;
    property HotTrack: Boolean read GetHotTrack write SetHotTrack;
    property ImagePosition: TEasyHeaderImagePosition read GetImagePosition write SetImagePosition;
    property SortGlyphAlign: TEasySortGlyphAlign read GetSortGlyphAlign write SetSortGlpyhAlign;
    property SortGlyphIndent: Integer read GetSortGlyphIndent write SetSortGlyphIndent;
    property SpringRest: Single read FSpringRest write FSpringRest;
    property Style: TEasyHeaderButtonStyle read GetStyle write SetStyle;
  public
    constructor Create(ACollection: TEasyCollection); override;
    destructor Destroy; override;
    function EditAreaHitPt(ViewportPoint: TPoint): Boolean; override;
    function HitTestAt(ViewportPoint: TPoint; var HitInfo: TEasyColumnHitTestInfoSet): Boolean;
    function PaintMouseHovering: Boolean;
    procedure Invalidate(ImmediateUpdate: Boolean); override;
    procedure LoadFromStream(S: TStream; Version: Integer = STREAM_VERSION); override;
    procedure MakeVisible(Position: TEasyMakeVisiblePos); override;
    procedure Paint(ACanvas: TCanvas; HeaderType: TEasyHeaderType);
    function SelectionHit(SelectViewportRect: TRect; SelectType: TEasySelectHitType): Boolean; override;
    function SelectionHitPt(ViewportPoint: TPoint; SelectType: TEasySelectHitType): Boolean; override;
    procedure SaveToStream(S: TStream; Version: Integer = STREAM_VERSION); override;

    property Alignment: TAlignment read GetAlignment write SetAlignment default taLeftJustify;
    property AutoSizeOnDblClk: Boolean read FAutoSizeOnDblClk write FAutoSizeOnDblClk default True;
    property AutoSpring: Boolean read FAutoSpring write SetAutoSpring default False;
    property AutoToggleSort: Boolean read FAutoToggleSort write FAutoToggleSort default True;
    property Bold;
    property Caption;
    property Checked;
    property Clickable: Boolean read FClickable write FClickable default True;
    property Clicking;
    property Enabled;
    property ImageIndex;
    property ImageOverlayIndex;
    property OwnerColumns: TEasyColumns read GetOwnerColumns;
    property OwnerHeader: TEasyHeader read GetOwnerHeader;
    property OwnsPaintInfo;
    property PaintInfo: TEasyPaintInfoColumn read GetPaintInfo write SetPaintInfo;
    property Position: Integer read FPosition write SetPosition;
    property Selected;
    property SortDirection: TEasySortDirection read FSortDirection write SetSortDirection default esdNone;
    property Tag;
    property Width: Integer read FWidth write SetWidth default 50;
    property View: TEasyViewColumn read GetView;
    property Visible;
  end;
  TEasyColumnClass = class of TEasyColumn;

  TEasyColumnInterfaced = class(TEasyColumn)
  protected
    function GetCaptions(Line: Integer): Widestring; override;
    function GetDetailCount: Integer; override;
    function GetDetails(Line: Integer): Integer; override;
    function GetImageIndexes(Column: Integer): Integer; override;
    function GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList; override;
    function GetImageOverlayIndexes(Column: Integer): Integer; override;
    procedure ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender); override;
    procedure ImageDrawGetSize(Column: TEasyColumn; var ImageW: Integer; var ImageH: Integer); override;
    procedure ImageDrawIsCustom(Column: TEasyColumn; var IsCustom: Boolean); override;
    procedure SetCaptions(Column: Integer; Value: Widestring); override;
    procedure SetDetailCount(Value: Integer); override;
    procedure SetDetails(Line: Integer; Value: Integer); override;
    procedure SetImageIndexes(Column: Integer; Value: Integer); override;
    procedure SetImageOverlayIndexes(Column: Integer; Value: Integer); override;
    procedure ThumbnailDraw(ACanvas: TCanvas; ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean); override;
  public
    property DataInf;
  end;

  TEasyColumnStored = class(TEasyColumn)
  private
    FDataHelper: TEasyDynamicDataHelper;
  protected
    function GetCaptions(Line: Integer): Widestring; override;
    function GetDetailCount: Integer; override;
    function GetDetails(Line: Integer): Integer; override;
    function GetImageIndexes(Column: Integer): Integer; override;
    function GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList; override;
    function GetImageOverlayIndexes(Column: Integer): Integer; override;
    procedure ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender); override;
    procedure ImageDrawGetSize(Column: TEasyColumn; var ImageW: Integer; var ImageH: Integer); override;
    procedure ImageDrawIsCustom(Column: TEasyColumn; var IsCustom: Boolean); override;
    procedure SetCaptions(Column: Integer; Value: Widestring); override;
    procedure SetDetailCount(Value: Integer); override;
    procedure SetDetails(Line: Integer; Value: Integer); override;
    procedure SetImageIndexes(Column: Integer; Value: Integer); override;
    procedure SetImageOverlayIndexes(Column: Integer; Value: Integer); override;
    procedure ThumbnailDraw(ACanvas: TCanvas; ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean); override;
    property DataHelper: TEasyDynamicDataHelper read FDataHelper write FDataHelper;
  public
    constructor Create(ACollection: TEasyCollection); override;
    destructor Destroy; override;
    procedure LoadFromStream(S: TStream; Version: Integer = STREAM_VERSION); override;
    procedure SaveToStream(S: TStream; Version: Integer = STREAM_VERSION); override;
  published
    property Alignment;
    property AutoSizeOnDblClk;
    property AutoSpring;
    property AutoToggleSort;
    property Bold;
    property Caption;
    property Checked;
    property Clickable;
    property Enabled;
    property ImageIndex;
    property ImageOverlayIndex;
    property OwnsPaintInfo;
    property Position;
    property Selected;
    property SortDirection;
    property Width;
    property Visible;
  end;

  TEasyColumnVirtual = class(TEasyColumn)
  protected
    function GetCaptions(Line: Integer): Widestring; override;
    function GetDetailCount: Integer; override;
    function GetDetails(Line: Integer): Integer; override;
    function GetImageIndexes(Column: Integer): Integer; override;
    function GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList; override;
    function GetImageOverlayIndexes(Column: Integer): Integer; override;
    procedure ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender); override;
    procedure ImageDrawGetSize(Column: TEasyColumn; var ImageW: Integer; var ImageH: Integer); override;
    procedure ImageDrawIsCustom(Column: TEasyColumn; var IsCustom: Boolean); override;
    procedure SetCaptions(Column: Integer; Value: Widestring); override;
    procedure SetDetailCount(Value: Integer); override;
    procedure SetDetails(Line: Integer; Value: Integer); override;
    procedure SetImageIndexes(Column: Integer; Value: Integer); override;
    procedure SetImageOverlayIndexes(Column: Integer; Value: Integer); override;
    procedure ThumbnailDraw(ACanvas: TCanvas; ARect: TRect;AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean); override;
  end;

  // **************************************************************************
  // TEasyViewColumn
  //   Implements the basis for the UI (drawing, and mouse interaction) for a EasyColumn
  // **************************************************************************
  TEasyViewColumn = class(TEasyOwnedPersistentView)
  public
    function EditAreaHitPt(Column: TEasyColumn; ViewportPoint: TPoint): Boolean; virtual;
    function GetImageList(Column: TEasyColumn): TImageList;
    procedure CalculateTextRect(Column: TEasyColumn; Canvas: TControlCanvas; var TextR: TRect); virtual;
    procedure GetImageSize(Column: TEasyColumn; var ImageW, ImageH: Integer);
    function ItemRect(Column: TEasyColumn; RectType: TEasyCellRectType): TRect; virtual;
    procedure ItemRectArray(Column: TEasyColumn; var RectArray: TEasyRectArrayObject); virtual;
    procedure LoadTextFont(Column: TEasyColumn; ACanvas: TCanvas); virtual;
    procedure Paint(Column: TEasyColumn; ACanvas: TCanvas; HeaderType: TEasyHeaderType); virtual;
    procedure PaintAfter(Column: TEasyColumn; ACanvas: TCanvas; HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintBefore(Column: TEasyColumn; ACanvas: TCanvas; HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintBkGnd(Column: TEasyColumn; ACanvas: TCanvas; HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintCheckBox(Column: TEasyColumn; ACanvas: TCanvas; HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintDropGlyph(Column: TEasyColumn; ACanvas: TCanvas; HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintFocusRect(Column: TEasyColumn; ACanvas: TCanvas; HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintImage(Column: TEasyColumn; ACanvas: TCanvas; HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject; ImageSize: TEasyImageSize); virtual;
    function PaintImageSize(Column: TEasyColumn; HeaderType: TEasyHeaderType): TEasyImageSize; virtual;
    procedure PaintSortGlyph(Column: TEasyColumn; ACanvas: TCanvas; HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject); virtual;
    procedure PaintText(Column: TEasyColumn; ACanvas: TCanvas; HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject; LinesToDraw: Integer); virtual;
    procedure ReSizeRectArray(var RectArray: TEasyRectArrayObjectArray); virtual;
    function SelectionHit(Column: TEasyColumn; SelectViewportRect: TRect; SelectType: TEasySelectHitType): Boolean; virtual;
    function SelectionHitPt(Column: TEasyColumn; ViewportPoint: TPoint; SelectType: TEasySelectHitType): Boolean; virtual;
  end;
  TEasyViewColumnClass = class of TEasyViewColumn;

  // **************************************************************************
  // TEasyGroups
  //   Collection that contains all the Columns in the control
  // **************************************************************************
  TEasyColumns = class(TEasyCollection)
  private
    FView: TEasyViewColumn;
    function GetColumns(Index: Integer): TEasyColumn;
    function GetOwnerHeader: TEasyHeader;
    function GetView: TEasyViewColumn;
    procedure SetColumns(Index: Integer; Value: TEasyColumn);
    procedure SetView(Value: TEasyViewColumn);
  protected
    procedure DoItemAdd(Item: TEasyCollectionItem; Index: Integer); override;
    procedure DoStructureChange; override;
  public
    constructor Create(AnOwner: TCustomEasyListview); reintroduce; virtual;
    destructor Destroy; override;
    function Add(Data: TObject = nil): TEasyColumn;
    function AddInterfaced(const DataInf: IUnknown; Data: TObject): TEasyColumnInterfaced;
    function AddVirtual(Data: TObject = nil): TEasyColumnVirtual;
    function AddCustom(CustomItem: TEasyColumnClass; Data: TObject = nil): TEasyColumn;
    function ColumnByPoint(ViewportPoint: TPoint): TEasyColumn;
    function Insert(Index: Integer; Data: TObject = nil): TEasyColumn;
    function InsertCustom(Index: Integer; CustomColumn: TEasyColumnClass; Data: TObject = nil): TEasyColumn;
    function InsertInterfaced(Index: Integer; const DataInf: IUnknown; Data: TObject = nil): TEasyColumnInterfaced;
    function InsertVirtual(Index: Integer; Data: TObject = nil): TEasyColumnVirtual;
    procedure Clear(FreeItems: Boolean = True); override;
    property Columns[Index: Integer]: TEasyColumn read GetColumns write SetColumns; default;
    property OwnerHeader: TEasyHeader read GetOwnerHeader;
    property View: TEasyViewColumn read GetView write SetView;
  end;

  TColumnPos = class(TList)
  private
    function Get(Index: Integer): TEasyColumn;
    procedure Put(Index: Integer; Item: TEasyColumn);
  public
    property Items[Index: Integer]: TEasyColumn read Get write Put; default;
  end;
  // **************************************************************************
  // TEasyHeader
  //   Header area of the Listview
  // **************************************************************************
  TEasyHeader = class(TEasyOwnedPersistent)
  private
    FCanvasStore: TEasyCanvasStore;
    FColor: TColor;                  // Color of the header
    FColumns: TEasyColumns;          // The columns that define the header
    FDisplayRect: TRect;             // Rectangle occupied in the Client Window of the Listview, clips column not visible due to scrollbar position of LV
    FDragManager: TEasyHeaderDragManager;
    FFixedSingleColumn: Boolean;
    FFont: TFont;                    // The font the header text is drawn in
    FHeight: Integer;                // Height of the header
    FHotTrackedColumn: TEasyColumn;  // the column that is current in a hot tracked state
    FImages: TImageList;             // Images for the header columns
    FLastWidth: Integer;
    FOldFontChange: TNotifyEvent;    // Old Font change notifier address
    FPositions: TColumnPos;
    FPressColumn: TEasyColumn;       // Column that currently pressed
    FResizeColumn: TEasyColumn;      // Column that is currently being resized
    FSizeable: Boolean;              // The column widths are resizeable by the mouse
    FState: TEasyHeaderStates;       // Current state of the header
    FStreamColumns: Boolean;
    FViewRect: TRect;                // The total size of the header including the column not visible in the current window
    FVisible: Boolean;               // Shows/Hides the header in the control
    function GetCanvasStore: TEasyCanvasStore;
    function GetDisplayRect: TRect;
    function GetDraggable: Boolean;
    function GetMouseCaptured: Boolean;
    function GetRuntimeHeight: Integer;
    procedure SetColor(Value: TColor);
    procedure SetDraggable(Value: Boolean);
    procedure SetFixedSingleColumn(const Value: Boolean);
    procedure SetFont(Value: TFont);
    procedure SetHeight(Value: Integer);
    procedure SetImages(Value: TImageList);
    procedure SetVisible(Value: Boolean);
    function GetViewWidth: Integer;
  protected
    function InCheckZone(ViewportPt: TPoint; var Column: TEasyColumn): Boolean;
    function InHotTrackZone(ViewportPt: TPoint; var Column: TEasyColumn): Boolean;
    function InPressZone(ViewportPt: TPoint; var Column: TEasyColumn): Boolean;
    function InResizeZone(ViewportPt: TPoint; var Column: TEasyColumn): Boolean;
    function IsFontStored: Boolean;
    procedure CaptureMouse;
    procedure ClearStates;
    procedure DoMouseDown(var Message: TWMMouse; Button: TCommonMouseButton; Shift: TShiftState; Column: TEasyColumn);
    procedure DoMouseMove(var Message: TWMMouse; Shift: TShiftState);
    procedure DoMouseUp(var Message: TWMMouse; Button: TCommonMouseButton; Shift: TShiftState; Column: TEasyColumn);
    procedure FontChanged(Sender: TObject);
    procedure HandleHotTrack(Msg: TWMMouse; ForceClear: Boolean);
    procedure ReleaseMouse;
    procedure SizeFixedSingleColumn(NewWidth: Integer);
    procedure SpringColumns(NewWidth: Integer);
    procedure WMContextMenu(var Msg: TMessage); message WM_CONTEXTMENU;
    procedure WMLButtonDblClk(var Msg: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMMouseMove(var Msg: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMRButtonDown(var Msg: TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure WMRButtonUp(var Msg: TWMRButtonUp); message WM_RBUTTONUP;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;

    property CanvasStore: TEasyCanvasStore read GetCanvasStore write FCanvasStore;
    property HotTrackedColumn: TEasyColumn read FHotTrackedColumn write FHotTrackedColumn;
    property LastWidth: Integer read FLastWidth write FLastWidth;
    property OldFontChange: TNotifyEvent read FOldFontChange write FOldFontChange;
    property Positions: TColumnPos read FPositions write FPositions;
    property PressColumn: TEasyColumn read FPressColumn write FPressColumn;
    property ResizeColumn: TEasyColumn read FResizeColumn write FResizeColumn;
    property RuntimeHeight: Integer read GetRuntimeHeight;
    property State: TEasyHeaderStates read FState write FState;
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
    destructor Destroy; override;

    function FirstColumn: TEasyColumn;
    function FirstColumnByPosition: TEasyColumn;
    function FirstColumnInRect(ViewportRect: TRect): TEasyColumn;
    function FirstVisibleColumn: TEasyColumn;
    function LastColumn: TEasyColumn;
    function LastVisibleColumn: TEasyColumn;
    function NextColumn(AColumn: TEasyColumn): TEasyColumn;
    function NextColumnByPosition(AColumn: TEasyColumn): TEasyColumn;
    function NextVisibleColumn(Column: TEasyColumn): TEasyColumn;
    function PrevColumn(AColumn: TEasyColumn): TEasyColumn;
    function PrevColumnByPosition(AColumn: TEasyColumn): TEasyColumn;
    function PrevVisibleColumn(Column: TEasyColumn): TEasyColumn;
    procedure Invalidate(ImmediateUpdate: Boolean); virtual;
    procedure InvalidateColumn(Item: TEasyColumn; ImmediateUpdate: Boolean); virtual;
    function LastColumnByPosition: TEasyColumn;
    function NextColumnInRect(Column: TEasyColumn; ViewportRect: TRect): TEasyColumn;
    procedure LoadFromStream(S: TStream); override;
    procedure PaintTo(ACanvas: TCanvas; ARect: TRect); virtual;
    procedure Rebuild(Force: Boolean); virtual;
    procedure SaveToStream(S: TStream); override;
    property DisplayRect: TRect read GetDisplayRect write FDisplayRect;
    property MouseCaptured: Boolean read GetMouseCaptured;
    property StreamColumns: Boolean read FStreamColumns write FStreamColumns default True;
    property ViewRect: TRect read FViewRect;
    property ViewWidth: Integer read GetViewWidth;
  published
    property Color: TColor read FColor write SetColor default clBtnFace;
    property Columns: TEasyColumns read FColumns write FColumns;
    property Draggable: Boolean read GetDraggable write SetDraggable default True;
    property DragManager: TEasyHeaderDragManager read FDragManager write FDragManager;
    property FixedSingleColumn: Boolean read FFixedSingleColumn write SetFixedSingleColumn default False;
    property Font: TFont read FFont write SetFont stored IsFontStored;
    property Height: Integer read FHeight write SetHeight default 21;
    property Images: TImageList read FImages write SetImages;
    property Sizeable: Boolean read FSizeable write FSizeable default True;
    property Visible: Boolean read FVisible write SetVisible default False;
  end;

  // **************************************************************************
  // TEasyEditManager
  //    EasyEditManager defines the base class to edit an item.  The
  // IEasyCellEditorSink allows the Editor to communicate back to the manager for
  // event dispatching without the need for the Editor interface to have knowledge
  // of the TManagerLink object.
  // **************************************************************************
  TEasyEditManager = class(TEasyOwnedPersistent)
  private
    FAutoEditDelayTime: Integer;   // Time (in milliseconds) before the object is edited
    FAutoEditStartClickPt: TPoint; // This is in WINDOW coordinates, the point where the mouse is clicked.  Used to determine if the AutoEdit should begin
    FEditColumn: TEasyColumn;
    FEditFinished: Boolean;        // Set when the edit is done
    FEditing: Boolean;             // Set when the edit is in progress
    FEditItem: TEasyItem;          // The Item that is being edited
    FEditor: IEasyCellEditor;
    FEnabled: Boolean;             // The Edit Manager is enabled
    FTabEditColumns: Boolean;
    FTabMoveFocus: Boolean;        // If an item is begin edited a tab move the focus to the next item and puts it in edit
    FTabMoveFocusColumn: TEasyColumn;
    FTabMoveFocusItem: TEasyItem;
    FTimer: TTimer;                // The timer for auto Edit
    FTimerRunning: Boolean;        // True when the auto Edit is timing out
                                             
    function GetEditing: Boolean;
    procedure SetEnabled(const Value: Boolean);
  protected
    function MainWindowHook(var Message: TMessage): Boolean;
    procedure StartAutoEditTimer;
    procedure StopAutoEditTimer;
    procedure TimerEvent(Sender: TObject);

    property AutoEditStartClickPt: TPoint read FAutoEditStartClickPt write FAutoEditStartClickPt;
    property EditColumn: TEasyColumn read FEditColumn write FEditColumn;
    property TabEditColumns: Boolean read FTabEditColumns write FTabEditColumns default False;
    property TabMoveFocusColumn: TEasyColumn read FTabMoveFocusColumn write FTabMoveFocusColumn;
    property TabMoveFocusItem: TEasyItem read FTabMoveFocusItem write FTabMoveFocusItem;
    property Timer: TTimer read FTimer write FTimer;
    property TimerRunning: Boolean read FTimerRunning;

  public
    constructor Create(AnOwner: TCustomEasyListview); override;
    destructor Destroy; override;

    procedure BeginEdit(Item: TEasyItem; Column: TEasyColumn); virtual;
    procedure EndEdit;

    property Editing: Boolean read GetEditing;
    property EditItem: TEasyItem read FEditItem;

    property Editor: IEasyCellEditor read FEditor write FEditor;
  published
    property AutoEditDelayTime: Integer read FAutoEditDelayTime write FAutoEditDelayTime default 300;
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    property TabMoveFocus: Boolean read FTabMoveFocus write FTabMoveFocus default False;
  end;

  // **************************************************************************
  // TEasyEnumFormatEtcManager
  //   The EnumFormatEtc Manager encapsulates the IEnumFormatEtc interface for
  // use with the IDataObject (below) interface for Drag/Drop and Clipboard
  // operations.
  // **************************************************************************
  TEasyEnumFormatEtcManager = class(TEasyInterfacedPersistent, IEnumFormatEtc)
  private
    FInternalIndex: integer;        // Keeps an internal reference to which format is being enumerated
    FFormats: TEasyFormatEtcArray;  // Keeps a list of all formats that are avaialable in the IDataObject
  protected
    { IEnumFormatEtc }
    function Next(celt: Longint; out elt; pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out Enum: IEnumFormatEtc): HResult; stdcall;

    property InternalIndex: integer read FInternalIndex write FInternalIndex;
  public
    constructor Create;
    destructor Destroy; override;

    property Formats: TEasyFormatEtcArray read FFormats write FFormats;
  end;

  // **************************************************************************
  // TEasyDataObjectManager
  //   The Data Object Manager encapsulates the IDataObject interface into a
  // Delphi class.  It is used for Drag/Drop and Clipboard operations
  // **************************************************************************
  TEasyDataObjectManager = class(TEasyOwnedInterfacedPersistent, IDataObject)
  private
    FAdviseHolder: IDataAdviseHolder; // Reference to an OLE supplied implementation for advising.
  protected
    FFormats: TEasyDataObjectInfoArray;   // Formats that the data object supports

    // IDataObject
    function GetData(const FormatEtcIn: TFormatEtc; out Medium: TStgMedium): HResult; virtual; stdcall;
    function GetDataHere(const formatetc: TFormatEtc; out medium: TStgMedium): HResult; virtual; stdcall;
    function QueryGetData(const formatetc: TFormatEtc): HResult; virtual; stdcall;
    function GetCanonicalFormatEtc(const formatetc: TFormatEtc; out formatetcOut: TFormatEtc): HResult; virtual; stdcall;
    function SetData(const formatetc: TFormatEtc; var medium: TStgMedium; fRelease: BOOL): HResult; virtual; stdcall;
    function EnumFormatEtc(dwDirection: Longint; out enumFormatEtc: IEnumFormatEtc): HResult; virtual; stdcall;
    function DAdvise(const formatetc: TFormatEtc; advf: Longint; const advSink: IAdviseSink; out dwConnection: Longint): HResult; virtual; stdcall;
    function DUnadvise(dwConnection: Longint): HResult; virtual; stdcall;
    function EnumDAdvise(out enumAdvise: IEnumStatData): HResult; virtual; stdcall;

    function CanonicalIUnknown(TestUnknown: IUnknown): IUnknown;
    function EqualFormatEtc(FormatEtc1, FormatEtc2: TFormatEtc): Boolean;
    function FindFormatEtc(TestFormatEtc: TFormatEtc): integer;
    function HGlobalClone(HGlobal: THandle): THandle;
    function RetrieveOwnedStgMedium(Format: TFormatEtc; var StgMedium: TStgMedium): HRESULT;
    function StgMediumIncRef(const InStgMedium: TStgMedium; var OutStgMedium: TStgMedium;
       CopyInMedium: Boolean): HRESULT;

    procedure DoGetCustomFormats(var Formats: TEasyFormatEtcArray); virtual;
    property AdviseHolder: IDataAdviseHolder read FAdviseHolder;
    property Formats: TEasyDataObjectInfoArray read FFormats write FFormats;
  public

    destructor Destroy; override;
    function AssignDragImage(Image: TBitmap; HotSpot: TPoint; TransparentColor: TColor): Boolean;
  end;

  // **************************************************************************
  // TEasyDragManagerBase
  //   Easy Base Drag Manager defines the common actions of the Drag Select
  // and object Drag Manager, including autoscroll
  // **************************************************************************
  TCustomEasyDragManagerBase = class(TEasyOwnedPersistent)
  private
    FAutoScroll: Boolean;
    FAutoScrollDelay: Integer;
    FAutoScrollDelayMet: Boolean;
    FAutoScrollTime: Integer;
    FDataObject: IDataObject;
    FMouseButton: TCommonMouseButtons;   // Defines what mouse buttons are used for a drag
    FRegistered: Boolean;
    FTimer: TTimer;
    FDragState: TEasyDragManagerStates;
    FLastKeyState: TCommonKeyStates;
    FEnabled: Boolean;
    FAutoScrollAccelerator: Byte;
    FAutoScrollMargin: Integer;
    function GetAutoScrolling: Boolean;
    function GetDragging: Boolean;
    function GetTimer: TTimer;
    procedure SetRegistered(Value: Boolean);
  protected
    procedure AutoScrollWindow; virtual;
    procedure DoAfterAutoScroll; virtual;
    procedure DoBeforeAutoScroll; virtual;
    procedure DoAutoScroll(DeltaX, DeltaY: Integer); virtual;
    procedure DoDrag(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect); virtual;
    procedure DoDragBegin(WindowPoint: TPoint; KeyState: TCommonKeyStates); virtual;
    procedure DoDragDrop(WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect); virtual;
    procedure DoDragEnd(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates); virtual;
    procedure DoDragEnter(const DataObject: IDataObject; Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect); virtual;
    procedure DoGetDragImage(Bitmap: TBitmap; DragStartPt: TPoint; var HotSpot: TPoint; var TransparentColor: TColor; var Handled: Boolean); virtual;
    procedure DoOLEDragEnd(const ADataObject: IDataObject; DragResult: TCommonOLEDragResult; ResultEffect: TCommonDropEffects); virtual;
    procedure DoOLEDragStart(const ADataObject: IDataObject; var AvailableEffects: TCommonDropEffects; var AllowDrag: Boolean); virtual;
    function DoPtInAutoScrollDownRegion(WindowPoint: TPoint): Boolean; virtual;
    function DoPtInAutoScrollLeftRegion(WindowPoint: TPoint): Boolean; virtual;
    function DoPtInAutoScrollRightRegion(WindowPoint: TPoint): Boolean; virtual;
    function DoPtInAutoScrollUpRegion(WindowPoint: TPoint): Boolean; virtual;
    procedure DoEnable(Enable: Boolean); virtual;
    function IsWindowDropRegistered: Boolean;
    function PtInAutoScrollDownRegion(WindowPoint: TPoint): Boolean;
    function PtInAutoScrollLeftRegion(WindowPoint: TPoint): Boolean;
    function PtInAutoScrollRegion(WindowPoint: TPoint): Boolean;
    function PtInAutoScrollRightRegion(WindowPoint: TPoint): Boolean;
    function PtInAutoScrollUpRegion(WindowPoint: TPoint): Boolean;
    function ScrollDeltaDown(WindowPoint: TPoint): Integer; virtual;
    function ScrollDeltaLeft(WindowPoint: TPoint): Integer; virtual;
    function ScrollDeltaRight(WindowPoint: TPoint): Integer; virtual;
    function ScrollDeltaUp(WindowPoint: TPoint): Integer; virtual;
    procedure RegisterOLEDragDrop(DoRegister: Boolean);
    procedure SetEnabled(const Value: Boolean); virtual;
    procedure UpdateAfterAutoScroll; virtual;
    procedure VCLDragStart; virtual;
    property DataObject: IDataObject read FDataObject write FDataObject;
    property LastKeyState: TCommonKeyStates read FLastKeyState write FLastKeyState;
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
    destructor Destroy; override;

    procedure BeginDrag(WindowPoint: TPoint; KeyState: TCommonKeyStates); virtual;
    procedure Drag(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect);
    procedure DragEnd(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates);
    procedure DragEnter(const ADataObject: IDataObject; Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect);
    procedure DragDrop(WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect);
    procedure HandleTimer(Sender: TObject); virtual;
    procedure WMKeyDown(var Msg: TWMKeyDown); virtual;

    property AutoScroll: Boolean read FAutoScroll write FAutoScroll default True;
    property AutoScrollAccelerator: Byte read FAutoScrollAccelerator write FAutoScrollAccelerator default 2;
    property AutoScrollDelay: Integer read FAutoScrollDelay write FAutoScrollDelay default _AUTOSCROLLDELAY;
    property AutoScrollDelayMet: Boolean read FAutoScrollDelayMet;
    property AutoScrolling: Boolean read GetAutoScrolling;
    property AutoScrollMargin: Integer read FAutoScrollMargin write FAutoScrollMargin default 15;
    property AutoScrollTime: Integer read FAutoScrollTime write FAutoScrollTime default _AUTOSCROLLTIME;
    property Dragging: Boolean read GetDragging;
    property DragState: TEasyDragManagerStates read FDragState write FDragState;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property MouseButton: TCommonMouseButtons read FMouseButton write FMouseButton default [cmbLeft];
    property Timer: TTimer read GetTimer write FTimer;
    property Registered: Boolean read FRegistered write SetRegistered;
  published
  end;

  // **************************************************************************
  // TEasyHeaderDragManager
  //   Drag Manager is associated with the Header in the EasyListview for
  // dragging columns around
  // **************************************************************************
  TEasyHeaderDragManager = class(TCustomEasyDragManagerBase)
  private
    FAllowDrop: Boolean;
    FColumn: TEasyColumn;
    FDefaultImageEvent: TGetDragImageEvent;
    FDragImageHeight: Integer;
    FDragImageWidth: Integer;
    FDragMode: TDragMode; // VCL Only
    FDragType: TEasyDragType;
    FEnableDragImage: Boolean;
    FHeader: TEasyHeader;
    FTargetColumn: TEasyColumn;
    function GetDragCursor: TCursor;
    function GetDragMode: TDragMode;
    procedure SetDragCursor(Value: TCursor);
    procedure SetDragMode(Value: TDragMode);
    procedure SetDragType(Value: TEasyDragType);
  protected
    procedure DefaultImage(Sender: TCustomEasyListview; Image: TBitmap; DragStartPt: TPoint; var HotSpot: TPoint; var TransparentColor: TColor; var Handled: Boolean); virtual;
    procedure DoDrag(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect); override;
    procedure DoDragBegin(WindowPoint: TPoint; KeyState: TCommonKeyStates); override;
    procedure DoDragDrop(WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect); override;
    procedure DoDragEnd(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates); override;
    procedure DoDragEnter(const DataObject: IDataObject; Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect); override;
    procedure DoOLEDragEnd(const ADataObject: IDataObject; DragResult: TCommonOLEDragResult; ResultEffect: TCommonDropEffects); override;
    procedure DoOLEDragStart(const ADataObject: IDataObject; var AvailableEffects: TCommonDropEffects; var AllowDrag: Boolean); override;
    function DoPtInAutoScrollLeftRegion(WindowPoint: TPoint): Boolean; override;
    function DoPtInAutoScrollRightRegion(WindowPoint: TPoint): Boolean; override;
    procedure ImageSize(var Width, Height: Integer); virtual;
    property AllowDrop: Boolean read FAllowDrop write FAllowDrop;
    property Column: TEasyColumn read FColumn write FColumn;
    property DefaultImageEvent: TGetDragImageEvent read FDefaultImageEvent write FDefaultImageEvent;
    property DragImageHeight: Integer read FDragImageHeight write FDragImageHeight default 300;
    property DragImageWidth: Integer read FDragImageWidth write FDragImageWidth default 200;
    property DragMode: TDragMode read GetDragMode write SetDragMode default dmManual;
    property DragType: TEasyDragType read FDragType write SetDragType default edtOLE;
    property Header: TEasyHeader read FHeader write FHeader;
    property TargetColumn: TEasyColumn read FTargetColumn write FTargetColumn;
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
  published
    property AutoScroll;
    property AutoScrollAccelerator;
    property AutoScrollDelay;
    property AutoScrollMargin;
    property AutoScrollTime;
    property DragCursor: TCursor read GetDragCursor write SetDragCursor default crDrag;
    property EnableDragImage: Boolean read FEnableDragImage write FEnableDragImage default True;
    property MouseButton;
  end;

  // **************************************************************************
  // TEasyDragManager
  //   Easy Drag Manager is associated with a TWinContol to track the
  // dragging of the cells in a Easy Control
  // **************************************************************************
  TEasyOLEDragManager = class(TEasyHeaderDragManager)
  private
    FDragAnchorPt: TPoint;
    FDragItem: TEasyItem;
    FDropTarget: TEasyItem;
    FHilightDropTarget: Boolean;
  protected
    procedure ClearDragItem;
    procedure ClearDropTarget;
    procedure DefaultImage(Sender: TCustomEasyListview; Image: TBitmap; DragStartPt: TPoint; var HotSpot: TPoint; var TransparentColor: TColor; var Handled: Boolean); override;
    procedure DoDrag(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect); override;
    procedure DoDragDrop(WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect); override;
    procedure DoDragEnd(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates); override;
    procedure DoDragEnter(const DataObject: IDataObject; Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect); override;
    procedure DoGetDragImage(Bitmap: TBitmap; DragStartPt: TPoint; var HotSpot: TPoint; var TransparentColor: TColor; var Handled: Boolean); override;
    procedure DoOLEDragEnd(const ADataObject: IDataObject; DragResult: TCommonOLEDragResult; ResultEffect: TCommonDropEffects); override;
    procedure DoOLEDragStart(const ADataObject: IDataObject; var AvailableEffects: TCommonDropEffects; var AllowDrag: Boolean); override;
    function DoPtInAutoScrollDownRegion(WindowPoint: TPoint): Boolean; override;
    function DoPtInAutoScrollUpRegion(WindowPoint: TPoint): Boolean; override;
    procedure ImageSize(var Width: Integer; var Height: Integer); override;
    procedure SetEnabled(const Value: Boolean); override;
    procedure VCLDragStart; override;
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
    destructor Destroy; override;

    procedure FinalizeDrag(KeyState: TCommonKeyStates);
    function InitializeDrag(HitItem: TEasyItem; WindowPoint: TPoint;  KeyState: TCommonKeyStates): Boolean;
    property DragAnchorPt: TPoint read FDragAnchorPt write FDragAnchorPt;
    property DragItem: TEasyItem read FDragItem;
    property DropTarget: TEasyItem read FDropTarget;
  published
    property AutoScroll;
    property AutoScrollAccelerator;
    property AutoScrollDelay;
    property AutoScrollMargin;
    property AutoScrollTime;
    property DragImageHeight;
    property DragImageWidth;
    property DragMode;
    property DragType;
    property Enabled default False;
    property HilightDropTarget: Boolean read FHilightDropTarget write FHilightDropTarget default True;
    property MouseButton;
  end;

  // **************************************************************************
  // TEasySelectionManager
  //   Easy Select Manager is associated with a TWinContol to track the
  // selection and focus of the cells in a Easy Control.
  // **************************************************************************
  TEasySelectionManager = class(TEasyOwnedPersistent)
  private
    FAlphaBlend: Boolean;
    FAlphaBlendSelRect: Boolean;
    FBlendAlphaImage: Byte;
    FBlendAlphaSelRect: Byte;
    FBlendAlphaTextRect: Byte;
    FBlendColorIcon: TColor;
    FBlendColorSelRect: TColor;
    FBlendIcon: Boolean;
    FBorderColor: TColor;
    FBorderColorSelRect: TColor;
    FColor: TColor;
    FCount: Integer;
    FFocusedColumn: TEasyColumn;
    FFocusedItem: TEasyItem;
    FAnchorItem: TEasyItem;
    FFocusedGroup: TEasyGroup;
    FEnabled: Boolean;
    FForceDefaultBlend: Boolean;
    FFullCellPaint: Boolean;
    FFullItemPaint: Boolean;
    FFullRowSelect: Boolean;
    FGroupSelections: Boolean;
    FGroupSelectUpdateCount: Integer;
    FInactiveBorderColor: TColor;
    FInactiveColor: TColor;
    FInactiveTextColor: TColor;
    FItemsToggled: Integer;
    FMouseButton: TCommonMouseButtons;
    FMultiChangeCount: Integer;
    FMultiSelect: Boolean;
    FRectSelect: Boolean; // A Click-Shift Select will use the Rectangle of the click and the Anchor Item vs. Selecting all from the Anchor Item Index to the selected Item index
    FResizeGroupOnFocus: Boolean; // If true and a focused caption will overlap next group, the group is resized to fit focused caption
    FRoundRect: Boolean;
    FRoundRectRadius: Byte;
    FTextColor: TColor;
    FUseFocusRect: Boolean;
    function GetAutoScroll: Boolean;
    function GetAutoScrollAccelerator: Byte;
    function GetAutoScrollDelay: Integer;
    function GetAutoScrollMargin: Integer;
    function GetAutoScrollTime: Integer;
    function GetEnableDragSelect: Boolean;
    function GeTCommonMouseButton: TCommonMouseButtons;
    function GetFocusedColumn: TEasyColumn;
    function GetMouseButtonSelRect: TCommonMouseButtons;
    function GetSelecting: Boolean;
    procedure SetAutoScroll(Value: Boolean);
    procedure SetAutoScrollAccelerator(Value: Byte);
    procedure SetAutoScrollDelay(Value: Integer);
    procedure SetAutoScrollMargin(Value: Integer);
    procedure SetAutoScrollTime(Value: Integer);
    procedure SetBlendIcon(Value: Boolean);
    procedure SetEnableDragSelect(Value: Boolean);
    procedure SetFocusedColumn(Value: TEasyColumn);
    procedure SetFocusedItem(Value: TEasyItem);
    procedure SetFocusedGroup(const Value: TEasyGroup);
    procedure SetEnabled(const Value: Boolean);
    procedure SeTCommonMouseButton(Value: TCommonMouseButtons);
    procedure SetFullCellPaint(Value: Boolean);
    procedure SetFullItemPaint(Value: Boolean);
    procedure SetGroupSelections(Value: Boolean);
    procedure SetMouseButtonSelRect(Value: TCommonMouseButtons);
    procedure SetMultiSelect(const Value: Boolean);
    procedure SetAnchorItem(Value: TEasyItem);
  protected
    procedure ActOnAll(SelectType: TEasySelectionType; ExceptItem: TEasyItem);
    procedure BuildSelectionGroupings(Force: Boolean); virtual;
    procedure DecMultiChangeCount;
    procedure DragSelect(KeyStates: TCommonKeyStates);
    procedure GainingSelection(Item: TEasyItem);
    procedure IncMultiChangeCount;
    procedure LosingSelection(Item: TEasyItem);
    procedure NotifyOwnerListview;
    property ItemsToggled: Integer read FItemsToggled write FItemsToggled;
    property MultiChangeCount: Integer read FMultiChangeCount write FMultiChangeCount;
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
    destructor Destroy; override;

    function SelectedToArray: TEasyItemArray;
    procedure ClearAll;
    procedure ClearAllExcept(Item: TEasyItem);
    function First: TEasyItem;
    function FirstInGroup(Group: TEasyGroup): TEasyItem;
    procedure DeleteSelected;
    procedure GroupSelectBeginUpdate;
    procedure GroupSelectEndUpdate;
    procedure InvalidateVisibleSelected(ValidateWindow: Boolean);
    procedure Invert;
    function Next(Item: TEasyItem): TEasyItem;
    function NextInGroup(Group: TEasyGroup; Item: TEasyItem): TEasyItem;
    procedure SelectAll;
    procedure SelectFirst;
    procedure SelectGroupItems(Group: TEasyGroup; ClearOtherItems: Boolean);
    procedure SelectRange(FromItem, ToItem: TEasyItem; RectSelect: Boolean; ClearFirst: Boolean);
    procedure SelectRect(ViewportSelRect: TRect; ClearFirst: Boolean);

    property AnchorItem: TEasyItem read FAnchorItem write SetAnchorItem;
    property Count: Integer read FCount;
    property FocusedColumn: TEasyColumn read GetFocusedColumn write SetFocusedColumn;
    property FocusedItem: TEasyItem read FFocusedItem write SetFocusedItem;
    property FocusedGroup: TEasyGroup read FFocusedGroup write SetFocusedGroup;
    property Selecting: Boolean read GetSelecting;
  published
    property AlphaBlend: Boolean read FAlphaBlend write FAlphaBlend default False;
    property AlphaBlendSelRect: Boolean read FAlphaBlendSelRect write FAlphaBlendSelRect default False;
    property AutoScroll: Boolean read GetAutoScroll write SetAutoScroll default True;
    property AutoScrollAccelerator: Byte read GetAutoScrollAccelerator write SetAutoScrollAccelerator default 2;
    property AutoScrollDelay: Integer read GetAutoScrollDelay write SetAutoScrollDelay default _AUTOSCROLLDELAY;
    property AutoScrollMargin: Integer read GetAutoScrollMargin write SetAutoScrollMargin default 15;
    property AutoScrollTime: Integer read GetAutoScrollTime write SetAutoScrollTime default _AUTOSCROLLTIME;
    property BlendAlphaImage: Byte read FBlendAlphaImage write FBlendAlphaImage default 128;
    property BlendAlphaSelRect: Byte read FBlendAlphaSelRect write FBlendAlphaSelRect default 70;
    property BlendAlphaTextRect: Byte read FBlendAlphaTextRect write FBlendAlphaTextRect default 128;
    property BlendColorSelRect: TColor read FBlendColorSelRect write FBlendColorSelRect default clHighlight;
    property BlendIcon: Boolean read FBlendIcon write SetBlendIcon default True;
    property BorderColor: TColor read FBorderColor write FBorderColor default clHighlight;
    property BorderColorSelRect: TColor read FBorderColorSelRect write FBorderColorSelRect default clHighlight;
    property Color: TColor read FColor write FColor default clHighlight;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property EnableDragSelect: Boolean read GetEnableDragSelect write SetEnableDragSelect default False;
    property ForceDefaultBlend: Boolean read FForceDefaultBlend write FForceDefaultBlend default False;
    property FullCellPaint: Boolean read FFullCellPaint write SetFullCellPaint default False;
    property FullItemPaint: Boolean read FFullItemPaint write SetFullItemPaint default False;
    property FullRowSelect: Boolean read FFullRowSelect write FFullRowSelect default False;
    property GroupSelections: Boolean read FGroupSelections write SetGroupSelections default False;
    property InactiveBorderColor: TColor read FInactiveBorderColor write FInactiveBorderColor default clInactiveBorder;
    property InactiveColor: TColor read FInactiveColor write FInactiveColor default clInactiveBorder;
    property InactiveTextColor: TColor read FInactiveTextColor write FInactiveTextColor default clBlack;
    property MouseButton: TCommonMouseButtons read GeTCommonMouseButton write SeTCommonMouseButton default [cmbLeft];
    property MouseButtonSelRect: TCommonMouseButtons read GetMouseButtonSelRect write SetMouseButtonSelRect default [cmbLeft, cmbRight];
    property MultiSelect: Boolean read FMultiSelect write SetMultiSelect default False;
    property RectSelect: Boolean read FRectSelect write FRectSelect default False;
    property ResizeGroupOnFocus: Boolean read FResizeGroupOnFocus write FResizeGroupOnFocus default False;
    property RoundRect: Boolean read FRoundRect write FRoundRect default False;
    property RoundRectRadius: Byte read FRoundRectRadius write FRoundRectRadius default 4;
    property TextColor: TColor read FTextColor write FTextColor default clHighlightText;
    property UseFocusRect: Boolean read FUseFocusRect write FUseFocusRect default True;
  end;

  // **************************************************************************
  // TEasyCheckManager
  //    Manages the check state of the items.  The item carries the check state
  // of itself but this manager allows manipulation of multiple items
  // **************************************************************************
  TEasyCheckManager = class(TEasyOwnedPersistent)
  private
    FCount: Integer;              // Number of items with checks set
    FPendingObject: TEasyCollectionItem; // When the mouse button is pressed over an item PendingCheckItem is set to that item
    procedure SetPendingObject(Value: TEasyCollectionItem);
  protected
    property PendingObject: TEasyCollectionItem read FPendingObject write SetPendingObject;
  public
    procedure CheckAll;
    procedure CheckAllInGroup(Group: TEasyGroup);
    function GetFirstChecked: TEasyItem;
    function GetFirstCheckedInGroup(Group: TEasyGroup): TEasyCollectionItem;
    function GetNextChecked(Item: TEasyItem): TEasyItem;
    function GetNextCheckedInGroup(Item: TEasyItem): TEasyItem;
    procedure UnCheckAll;
    procedure UnCheckAllInGroup(Group: TEasyGroup);

    property Count: Integer read FCount;
  end;

  TEasyHotTrackManager = class(TEasyOwnedPersistent)
  private
    FColor: TColor;
    FColumnTrack: TEasyHotTrackRectColumns;
    FEnabled: Boolean;
    FCursor: TCursor;
    FGroupTrack: TEasyHotTrackRectGroups;
    FItemTrack: TEasyHotTrackRectItems;
    FOnlyFocused: Boolean;
    FPendingObject: TEasyCollectionItem;
    FPendingObjectCheck: TEasyCollectionItem;
    FUnderline: Boolean;
    function GetPendingObject(MousePos: TPoint): TEasyCollectionItem;
    procedure SetPendingObject(MousePos: TPoint; Value: TEasyCollectionItem);
    procedure SetPendingObjectCheck(const Value: TEasyCollectionItem);
  protected
    property PendingObject[MousePos: TPoint]: TEasyCollectionItem read GetPendingObject write SetPendingObject;
    property PendingObjectCheck: TEasyCollectionItem read FPendingObjectCheck write SetPendingObjectCheck;
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
  published
    property Color: TColor read FColor write FColor default clHighlight;
//    property ColumnTrack: TEasyHotTrackRectColumns read FColumnTrack write FColumnTrack default [htcImage, htcText];
    property Enabled: Boolean read FEnabled write FEnabled default False;
    property Cursor: TCursor read FCursor write FCursor default crHandPoint;
    property GroupTrack: TEasyHotTrackRectGroups read FGroupTrack write FGroupTrack default [htgIcon, htgText];
    property ItemTrack: TEasyHotTrackRectItems read FItemTrack write FItemTrack default [htiIcon, htiText];
    property OnlyFocused: Boolean read FOnlyFocused write FOnlyFocused default False;
    property Underline: Boolean read FUnderline write FUnderline default True;
  end;

  // **************************************************************************
  // TEasyScrollbarManager
  //   ScrollManager is associated with a TWinContol to handle the
  // controls scrollbars
  // **************************************************************************
  TEasyScrollbarManager = class(TEasyOwnedPersistent)
  private
    FHorzEnabled: Boolean;
    FOffsetX: Integer;
    FOffsetY: Integer;
    FState: TEasyScrollManagerStates;
    FVertEnabled: Boolean;
    FViewRect: TRect;

    function GetHorzBarVisible: Boolean;
    function GetLine: Integer;
    function GetMaxOffsetX: Integer;
    function GetMaxOffsetY: Integer;
    function GetVertBarVisible: Boolean;
    function GetViewHeight: Integer;
    function GetViewWidth: Integer;
    procedure SetHorzEnabled(const Value: Boolean);
    procedure SetOffsetX(const Value: Integer);
    procedure SetOffsetY(const Value: Integer);
    procedure SetVertEnabled(const Value: Boolean);
  protected
    procedure ScrollVisibilityChanged(Scrollbar: TEasyScrollbarDir);
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
    destructor Destroy; override;

    function MapWindowToView(WindowPoint: TPoint; AccountForHeader: Boolean = True): TPoint; overload;
    function MapWindowToView(WindowPoint: TSmallPoint; AccountForHeader: Boolean = True): TPoint; overload;
    function MapWindowRectToViewRect(WindowRect: TRect; AccountForHeader: Boolean = True): TRect;
    function MapViewToWindow(ViewportPoint: TPoint; AccountForHeader: Boolean = True): TPoint; overload;
    function MapViewToWindow(ViewportPoint: TSmallPoint; AccountForHeader: Boolean = True): TPoint; overload;
    function MapViewRectToWindowRect(ViewPortRect: TRect; AccountForHeader: Boolean = True): TRect;
    procedure ReCalculateScrollbars(Redraw: Boolean; Force: Boolean);
    procedure Scroll(DeltaX, DeltaY: Integer);
    procedure SetViewRect(AViewRect: TRect; InvalidateWindow: Boolean);
    procedure ValidateOffsets(var AnOffsetX, AnOffsetY: Integer);
    function ViewableViewportRect: TRect;
    procedure WMHScroll(var Msg: TWMVScroll);
    procedure WMKeyDown(var Msg: TWMKeyDown);
    procedure WMVScroll(var Msg: TWMVScroll);

    property HorzBarVisible: Boolean read GetHorzBarVisible;
    property Line: Integer read GetLine;
    property MaxOffsetX: Integer read GetMaxOffsetX;
    property MaxOffsetY: Integer read GetMaxOffsetY;
    property OffsetX: Integer read FOffsetX write SetOffsetX;
    property OffsetY: Integer read FOffsetY write SetOffsetY;
    property State: TEasyScrollManagerStates read FState write FState;
    property VertBarVisible: Boolean read GetVertBarVisible;
    property ViewHeight: Integer read GetViewHeight;
    property ViewRect: TRect read FViewRect;
    property ViewWidth: Integer read GetViewWidth;
  published
    property HorzEnabled: Boolean read FHorzEnabled write SetHorzEnabled default True;
    property VertEnabled: Boolean read FVertEnabled write SetVertEnabled default True;
  end;

  // **************************************************************************
  // TEasyBackgroundManager
  //   Easy Background handles the drawing of a background in Easy
  // controls.  It is a stand alone component that can be shared
  // **************************************************************************
  TEasyBackgroundManager = class(TEasyOwnedPersistent)
  private
    FAlphaBlend: Boolean;
    FBlendAlpha: Integer;
    FBlendMode: TCommonBlendMode;
    FEnabled: Boolean;
    FImage: TBitmap;
    FOffsetTrack: Boolean;
    FOffsetX: Integer;
    FOffsetY: Integer;
    FTile: Boolean;
    FTransparent: Boolean;
    FAlphaImage: TBitmap;
    procedure SetAlphaBlend(const Value: Boolean);
    procedure SetAlphaImage(const Value: TBitmap);
    procedure SetBlendAlpha(const Value: Integer);
    procedure SeTCommonBlendMode(const Value: TCommonBlendMode);
    procedure SetEnabled(const Value: Boolean);
    procedure SetImage(const Value: TBitmap);
    procedure SetOffsetX(const Value: Integer);
    procedure SetOffsetY(const Value: Integer);
    procedure SetTile(const Value: Boolean);
    procedure SetTransparent(const Value: Boolean);
  protected
    procedure ChangeBitmapBits(Sender: TObject);
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    procedure AssignTo(Target: TPersistent); override;
    procedure PaintTo(ACanvas: TCanvas; ARect: TRect; PaintDefault: Boolean); virtual;
    procedure WMWindowPosChanging(var Msg: TWMWindowPosChanging); virtual;

  published
    property AlphaBlend: Boolean read FAlphaBlend write SetAlphaBlend default False;
    property AlphaImage: TBitmap read FAlphaImage write SetAlphaImage;
    property BlendAlpha: Integer read FBlendAlpha write SetBlendAlpha default 128;
    property BlendMode: TCommonBlendMode read FBlendMode write SeTCommonBlendMode default cbmConstantAlphaAndColor;
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    property Image: TBitmap read FImage write SetImage;
    property OffsetTrack: Boolean read FOffsetTrack write FOffsetTrack default False;
    property OffsetX: Integer read FOffsetX write SetOffsetX default 0;
    property OffsetY: Integer read FOffsetY write SetOffsetY default 0;
    property Tile: Boolean read FTile write SetTile default True;
    property Transparent: Boolean read FTransparent write SetTransparent default False;
  end;

  // **************************************************************************
  // TEasyTaskBandBackgroundManager
  //   Easy Background handles the drawing of a background in Easy
  // controls.  It is a stand alone component that can be shared
  // **************************************************************************
  TEasyTaskBandBackgroundManager = class(TEasyBackgroundManager)
  public
    procedure PaintTo(ACanvas: TCanvas; ARect: TRect; PaintDefault: Boolean); override;
  end;

  // **************************************************************************
  // TEasyDropTargetManager
  //   Implements the IDropTarget inteface to allow for the control to become
  // a drag/drop target and accept drops.
  // **************************************************************************
  TEasyDropTargetManager = class(TEasyOwnedInterfacedPersistent, IDropTarget)
  private
    FDragManager: TCustomEasyDragManagerBase;
    FDropTargetHelper: IDropTargetHelper;   // Win2k and up drag image support built in to Windows
    function GetDropTargetHelper: IDropTargetHelper;
  protected
    function DragEnter(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
    function DragOver(grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
    function DragLeave: HResult; stdcall;
    function Drop(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;

    property DragManager: TCustomEasyDragManagerBase read FDragManager write FDragManager;
    property DropTargetHelper: IDropTargetHelper read GetDropTargetHelper;
  public
  end;

  // **************************************************************************
  // TEasyDropSourceManager
  //   Implements the IDropSource inteface to allow for the control to become
  // a drag/drop source.
  // **************************************************************************
  TEasyDropSourceManager = class(TEasyOwnedInterfacedPersistent, IDropSource)
  protected
    function QueryContinueDrag(fEscapePressed: BOOL; grfKeyState: Longint): HResult; stdcall;
    function GiveFeedback(dwEffect: Longint): HResult; stdcall;     
  end;

  // **************************************************************************
  // Drag TEasyDragRectManager Manager
  //   Easy DragRect Manager is associated with a TWinContol to handle the
  // controls drag selection rectangle
  // **************************************************************************
  TEasyDragRectManager = class(TCustomEasyDragManagerBase)
  private
    FAnchorPoint: TPoint;  // Anchor point in Viewport coordinates
    FDragPoint: TPoint;    // Dragging point in Viewport coordinates
    FOldOffsets: TPoint;
    FPrevRect: TRect;
    function GetSelectionRect: TRect;
    procedure PaintRect(Canvas: TCanvas);
    procedure SetAnchorPoint(ViewportAnchor: TPoint);
    procedure SetDragPoint(const Value: TPoint);
  protected
    procedure DoAfterAutoScroll; override;
    procedure DoAutoScroll(DeltaX, DeltaY: Integer); override;
    procedure DoBeforeAutoScroll; override;
    procedure DoDrag(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect); override;
    procedure DoDragBegin(WindowPoint: TPoint; KeyState: TCommonKeyStates); override;
    procedure DoDragEnd(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates); override;
    procedure DoDragEnter(const DataObject: IDataObject; Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect); override;
    function DoPtInAutoScrollDownRegion(WindowPoint: TPoint): Boolean; override;
    function DoPtInAutoScrollLeftRegion(WindowPoint: TPoint): Boolean; override;
    function DoPtInAutoScrollRightRegion(WindowPoint: TPoint): Boolean; override;
    function DoPtInAutoScrollUpRegion(WindowPoint: TPoint): Boolean; override;
    procedure UpdateAfterAutoScroll; override;
    property OldOffsets: TPoint read FOldOffsets write FOldOffsets;
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
    destructor Destroy; override;

    procedure FinalizeDrag(KeyState: TCommonKeyStates);
    function InitializeDrag(WindowPoint: TPoint; KeyState: TCommonKeyStates): Boolean;
    procedure PaintSelectionRect(Canvas: TCanvas);
    function SelRectInWindowCoords: TRect;
    procedure WMKeyDown(var Msg: TWMKeyDown); override;

    property AnchorPoint: TPoint read FAnchorPoint write SetAnchorPoint;
    property DragPoint: TPoint read FDragPoint write SetDragPoint;
    property PrevRect: TRect read FPrevRect;
    property SelectionRect: TRect read GetSelectionRect;
  end;

  // > 0 (positive)  Item1 is less than Item2
  //  0  Item1 is equal to Item2
  // < 0 (negative)  Item1 is greater than Item2
  TEasySortProc = function(Column: TEasyColumn; Item1, Item2: TEasyCollectionItem): Integer;  

  TEasySorter = class
  private
    FOwner: TEasySortManager;
  public
    constructor Create(AnOwner: TEasySortManager); virtual;
    procedure Sort(Column: TEasyColumn; Collection: TEasyCollection; Min, Max: Integer; GroupCompare: TEasyDoGroupCompare; ItemCompare: TEasyDoItemCompare; UseInterfaces: Boolean); virtual; abstract;
    property Owner: TEasySortManager read FOwner write FOwner;
  end;

  TEasyQuickSort = class(TEasySorter)
  public
    procedure Sort(Column: TEasyColumn; Collection: TEasyCollection; Min, Max: Integer; GroupCompare: TEasyDoGroupCompare; ItemCompare: TEasyDoItemCompare; UseInterfaces: Boolean); override;
  end;

  TEasyBubbleSort = class(TEasySorter)
  public
    procedure Sort(Column: TEasyColumn; Collection: TEasyCollection; Min, Max: Integer; GroupCompare: TEasyDoGroupCompare; ItemCompare: TEasyDoItemCompare; UseInterfaces: Boolean); override;
  end;

  TEasyMergeSort = class(TEasySorter)
  private
    FColumn: TEasyColumn;
    FGroupCompareFunc: TEasyDoGroupCompare;
    FItemCompareFunc: TEasyDoItemCompare;
    FOwnerGroup: TEasyGroup;
  protected
    function CompareInterfaces(i1, i2: TEasyCollectionItem): Boolean;
    function CompareGroup(i1, i2: TEasyCollectionItem): Boolean;
    function CompareItem(i1, i2: TEasyCollectionItem): Boolean;
    function CompareDefault(i1, i2: TEasyCollectionItem): Boolean;
    property Column: TEasyColumn read FColumn write FColumn;
    property GroupCompareFunc: TEasyDoGroupCompare read FGroupCompareFunc write FGroupCompareFunc;
    property ItemCompareFunc: TEasyDoItemCompare read FItemCompareFunc write FItemCompareFunc;
    property OwnerGroup: TEasyGroup read FOwnerGroup write FOwnerGroup;
  public
    procedure Sort(Column: TEasyColumn; Collection: TEasyCollection; Min, Max: Integer; GroupCompare: TEasyDoGroupCompare; ItemCompare: TEasyDoItemCompare; UseInterfaces: Boolean); override;
  end;

  TGroupSortInfoRec = record
    Item: TEasyItem;
    Key: LongWord;
  end;
  TGroupSortInfoArray = array of TGroupSortInfoRec;
  // **************************************************************************
  // TEasySortManager
  //   Manages the sorting of the Listview.  Because of the way EasyListview
  // works it is not feasable to try to add an AutoSort property.  EasyListview
  // can access a caption by a callback, storing it in the control, or through
  // an interface.  Due to the wildly varying ways of storing the caption it was
  // decided to not try to find all the possible places it would be necessary to
  // AutoSort.  There are some scenarios, such as the interface access, where it
  // is not possible to detect when an autosort should be carried out.
  // **************************************************************************
  TEasySortManager = class(TEasyOwnedPersistent)
  private
    FAlgorithm: TEasySortAlgorithm; // The algorithm used when sorting
    FAutoRegroup: Boolean;
    FAutoSort: Boolean;             // Items and groups are resorted when any object is added/inserted
    FLockoutSort: Boolean;
    FSortList: TGroupSortInfoArray;
    FSorter: TEasySorter;           // The algorithm engine for the sort
    FUpdateCount: Integer;
    procedure SetAlgorithm(Value: TEasySortAlgorithm);
    procedure SetAutoRegroup(Value: Boolean);
    procedure SetAutoSort(Value: Boolean);
  protected
    function CollectionSupportsInterfaceSorting(Collection: TEasyCollection): Boolean;
    procedure GroupItem(Item: TEasyItem; ColumnIndex: Integer; Key: LongWord);
    property Sorter: TEasySorter read FSorter write FSorter;
    property SortList: TGroupSortInfoArray read FSortList write FSortList;
    property UpdateCount: Integer read FUpdateCount write FUpdateCount;
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure ReGroup(Column: TEasyColumn); virtual;
    procedure SortAll(Force: Boolean = False);
    property LockoutSort: Boolean read FLockoutSort write FLockoutSort;
  published
    property Algorithm: TEasySortAlgorithm read FAlgorithm write SetAlgorithm default esaMergeSort;
    property AutoRegroup: Boolean read FAutoRegroup write SetAutoRegroup default False;
    property AutoSort: Boolean read FAutoSort write SetAutoSort default False;
  end;

  // **************************************************************************
  // TEasyHintInfo
  //   Custom hint information for the Unicode Hint Window
  // **************************************************************************
  TEasyHintInfo = class(TEasyOwnedPersistent)
  private
    FBounds: TRect;
    FCanvas: TCanvas;
    FColor: TColor;
    FCursorPos: TPoint;
    FHideTimeout: Integer;
    FHintType: TEasyHintType;
    FMaxWidth: Integer;
    FReshowTimeout: Integer;
    FText: WideString;
    FWindowPos: TPoint;
  public
    property Canvas: TCanvas read FCanvas write FCanvas;
    property Color: TColor read FColor write FColor;
    property CursorPos: TPoint read FCursorPos write FCursorPos;
    property Bounds: TRect read FBounds write FBounds;
    property HideTimeout: Integer read FHideTimeout write FHideTimeout;
    property HintType: TEasyHintType read FHintType write FHintType;
    property MaxWidth: Integer read FMaxWidth write FMaxWidth;
    property ReshowTimeout: Integer read FReshowTimeout write FReshowTimeout;
    property Text: WideString read FText write FText;
    property WindowPos: TPoint read FWindowPos write FWindowPos;
  end;

  // **************************************************************************
  // TEasyHintWindow
  //   Custom hint window that supports Unicode and Custom Draw
  // **************************************************************************
  TEasyHintWindow = class(THintWindow)
  protected
    FEasyHintInfo: TEasyHintInfo;
    FHintInfo: PEasyHintInfoRec;

    procedure Paint; override;

    property EasyHintInfo: TEasyHintInfo read FEasyHintInfo write FEasyHintInfo;
    property HintInfo: PEasyHintInfoRec read FHintInfo write FHintInfo;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ActivateHint(ARect: TRect; const AHint: string); override;
    procedure ActivateHintData(ARect: TRect; const AHint: string; AData: Pointer); override;
    function CalcHintRect(MaxWidth: Integer; const AHint: string; AData: Pointer): TRect; override;
    function IsHintMsg(var Msg: TMsg): Boolean; override;
  end;
  TEasyHintWindowClass = class of TEasyHintWindow;


  // **************************************************************************
  // TEasyIncrementalSearchManager
  //   Implements the incremental search of the listview
  // **************************************************************************
  TEasyIncrementalSearchManager = class(TEasyOwnedPersistent)
  private
    FDirection: TEasyIncrementalSearchDir;
    FEnabled: Boolean;
    FhTimer: THandle;
    FItemType: TEasyIncrementalSearchItemType;
    FResetTime: Integer;
    FSearchBuffer: WideString;
    FSearchItem: TEasyItem;
    FStart: TCoolIncrementalSearchStart;
    FState: TEasyIncrementalSearchStates;
    FTimerStub: Pointer;
    procedure SetSearchItem(Value: TEasyItem);
  protected
    procedure EndTimer;
    function IsSearching: Boolean;
    procedure HandleWMChar(var Msg: TWMChar); virtual;
    procedure HandleWMKeyDown(var Msg: TWMKeyDown); virtual;
    procedure ResetTimer;
    procedure StartSearch;
    procedure StartTimer;

    procedure TimerProc(Window: HWnd; uMsg: UINT; idEvent: UINT; dwTime: DWORD); stdcall;

    property hTimer: THandle read FhTimer write FhTimer;
    property SearchBuffer: WideString read FSearchBuffer write FSearchBuffer;
    property SearchItem: TEasyItem read FSearchItem write SetSearchItem;
    property TimerStub: Pointer read FTimerStub write FTimerStub;
  public
    constructor Create(AnOwner: TCustomEasyListview); override;
    destructor Destroy; override; 
    procedure ClearSearch; virtual;
    procedure ResetSearch;
    property State: TEasyIncrementalSearchStates read FState write FState;
  published
    property Direction: TEasyIncrementalSearchDir read FDirection write FDirection default eisdForward;
    property Enabled: Boolean read FEnabled write FEnabled default False;
    property ResetTime: Integer read FResetTime write FResetTime default 2000;
    property StartType: TCoolIncrementalSearchStart read FStart write FStart default eissStartOver;
    property ItemType: TEasyIncrementalSearchItemType read FItemType write FItemType default eisiVisible;
  end;

  // **************************************************************************
  // TCustomEasyListview
  // **************************************************************************
  TCustomEasyListview = class(TCommonCanvasControl)
  private
    FBackBits: TBitmap;
    FBackGround: TEasyBackgroundManager;
    FCacheDoubleBufferBits: Boolean;
    FCellSizes: TEasyCellSizes;
    FCheckManager: TEasyCheckManager;
    FDisabledBlendAlpha: Byte;
    FDisabledBlendColor: TColor;
    FDragManager: TEasyOLEDragManager;
    FDragRect: TEasyDragRectManager;
    FDropTarget: IDropTarget;
    FEditManager: TEasyEditManager;
    FGlobalImages: TEasyGlobalImageManager;
    FGroupCollapseButton: TBitmap;
    FGroupExpandButton: TBitmap;
    FGroupFont: TFont;
    FGroupImageGetSize: TGroupImageGetSizeEvent;
    FGroups: TEasyGroups;
    FHeader: TEasyHeader;
    FHintData: TEasyHintInfoRec;
    FHintInfo: TEasyHintInfo;
    FHotTrack: TEasyHotTrackManager;
    FImagesExLarge: TImageList;
    FImagesGroup: TImageList;
    FImagesLarge: TImageList;
    FImagesSmall: TImageList;
    FIncrementalSearch: TEasyIncrementalSearchManager;
    FItems: TEasyGlobalItems;
    FNCCanvas: TCanvas;
    FOldFontChangeNotify: TNotifyEvent;
    FOldGroupFontChangeNotify: TNotifyEvent;
    FOnAutoGroupGetKey: TAutoGroupGetKeyEvent;
    FOnAutoSortGroupCreate: TAutoSortGroupCreateEvent;
    FOnClipboardCopy: TEasyClipboardEvent;
    FOnClipboardCut: TEasyClipboardCutEvent;
    FOnClipboardPaste: TEasyClipboardEvent;
    FOnColumnCheckChange: TColumnCheckChangeEvent;
    FOnColumnCheckChanging: TColumnCheckChangingEvent;
    FOnColumnClick: TColumnClickEvent;
    FOnColumnContextMenu: TColumnContextMenuEvent;
    FOnColumnDblClick: TColumnDblClickEvent;
    FOnColumnImageDrawIsCustom: TColumnImageDrawIsCustomEvent;
    FOnColumnEnableChange: TColumnEnableChangeEvent;
    FOnColumnEnableChanging: TColumnEnableChangingEvent;
    FOnColumnFocusChanged: TColumnFocusChangeEvent;
    FOnColumnFocusChanging: TColumnFocusChangingEvent;
    FOnColumnFreeing: TColumnFreeingEvent;
    FOnColumnGetCaption: TColumnGetCaptionEvent;
    FOnColumnGetDetail: TColumnGetDetailEvent;
    FOnColumnGetDetailCount: TColumnGetDetailCountEvent;
    FOnColumnGetImageIndex: TColumnGetImageIndexEvent;
    FOnColumnGetImageList: TColumnGetImageListEvent;
    FOnColumnImageDraw: TColumnImageDrawEvent;
    FOnColumnImageGetSize: TColumnImageGetSizeEvent;
    FOnColumnInitialize: TColumnInitializeEvent;
    FOnColumnLoadFromStream: TEasyColumnLoadFromStreamEvent;
    FOnColumnPaintText: TColumnPaintTextEvent;
    FOnColumnSaveToStream: TEasyColumnSaveToStreamEvent;
    FOnColumnSelectionChanged: TColumnSelectionChangeEvent;
    FOnColumnSelectionChanging: TColumnSelectionChangingEvent;
    FOnColumnSetCaption: TColumnSetCaptionEvent;
    FOnColumnSetDetail: TColumnSetDetailEvent;
    FOnColumnSetImageIndex: TColumnSetImageIndexEvent;
    FOnColumnSizeChanged: TColumnSizeChangedEvent;
    FOnColumnSizeChanging: TColumnSizeChangingEvent;
    FOnColumnThumbnailDraw: TColumnThumbnailDrawEvent;
    FOnColumnVisibilityChanged: TColumnVisibilityChangeEvent;
    FOnColumnVisibilityChanging: TColumnVisibilityChangingEvent;
    FOnContextMenu: TContextMenuEvent;
    FOnCustomColumnView: TCustomColumnViewEvent;
    FOnCustomGrid: TCustomGridEvent;
    FOnCustomView: TCustomViewEvent;
    FOnDblClick: TDblClickEvent;
    FOnGetDragImage: TGetDragImageEvent;
    FOnGroupClick: TGroupClickEvent;
    FOnGroupCollapse: TGroupCollapseEvent;
    FOnGroupCollapsing: TGroupCollapsingEvent;
    FOnGroupCompare: TGroupCompareEvent;
    FOnGroupContextMenu: TGroupContextMenuEvent;
    FOnGroupDblClick: TGroupDblClickEvent;
    FOnGroupImageDrawIsCustom: TGroupImageDrawIsCustomEvent;
    FOnGroupExpand: TGroupExpandEvent;
    FOnGroupExpanding: TGroupExpandingEvent;
    FOnGroupFocusChanged: TGroupFocusChangeEvent;
    FOnGroupFocusChanging: TGroupFocusChangingEvent;
    FOnGroupFreeing: TGroupFreeingEvent;
    FOnGroupGetCaption: TGroupGetCaptionEvent;
    FOnGroupGetDetailCount: TGroupGetDetailCountEvent;
    FOnGroupGetDetailIndex: TGroupGetDetailEvent;
    FOnGroupGetImageIndex: TGroupGetImageIndexEvent;
    FOnGroupGetImageList: TGroupGetImageListEvent;
    FOnGroupImageDrawEvent: TGroupImageDrawEvent;
    FOnGroupInitialize: TGroupInitializeEvent;
    FOnGroupHotTrack: TGroupHotTrackEvent;
    FOnGroupLoadFromStream: TGroupLoadFromStreamEvent;
    FOnGroupPaintText: TGroupPaintTextEvent;
    FOnGroupSaveToStream: TGroupSaveToStreamEvent;
    FOnGroupSelectionChanged: TGroupSelectionChangeEvent;
    FOnGroupSelectionChanging: TGroupSelectionChangingEvent;
    FOnGroupSetCaption: TGroupSetCaptionEvent;
    FOnGroupSetImageIndex: TGroupSetImageIndexEvent;
    FOnGroupSetDetail: TGroupSetDetailEvent;
    FOnGroupThumbnailDraw: TGroupThumbnailDrawEvent;
    FOnGroupVisibilityChanged: TGroupVisibilityChangeEvent;
    FOnGroupVisibilityChanging: TGroupVisibilityChangingEvent;
    FOnHeaderDblClick: THeaderDblClickEvent;
    FOnHeaderMouseDown: THeaderMouseEvent;
    FOnHeaderMouseMove: TMouseMoveEvent;
    FOnHeaderMouseUp: THeaderMouseEvent;
    FOnHintCustomDraw: THintCustomDrawEvent;
    FOnHintCustomInfo: THintCustomizeInfoEvent;
    FOnHintPauseTime: THintPauseTimeEvent;
    FOnHintPopup: THintPopupEvent;
    FOnIncrementalSearch: TIncrementalSearchEvent;
    FOnItemCheckChange: TItemCheckChangeEvent;
    FOnItemCheckChanging: TItemCheckChangingEvent;
    FOnItemClick: TItemClickEvent;
    FOnItemCompare: TItemCompareEvent;
    FOnItemContextMenu: TItemContextMenuEvent;
    FOnItemCreateEditor: TItemCreateEditorEvent;
    FOnItemDblClick: TItemDblClickEvent;
    FOnItemGetEditCaption: TEasyItemGetCaptionEvent;
    FOnItemImageDrawIsCustom: TItemImageDrawIsCustomEvent;
    FOnItemEditBegin: TItemEditBegin;
    FOnItemEdited: TItemEditedEvent;
    FOnItemEditEnd: TItemEditEnd;
    FOnItemEnableChange: TItemEnableChangeEvent;
    FOnItemEnableChanging: TItemEnableChangingEvent;
    FOnItemFocusChanged: TItemFocusChangeEvent;
    FOnItemFocusChanging: TItemFocusChangingEvent;
    FOnItemFreeing: TItemFreeingEvent;
    FOnItemGetCaption: TItemGetCaptionEvent;
    FOnItemGetGroupKey: TItemGetGroupKeyEvent;
    FOnItemHotTrack: TItemHotTrackEvent;
    FOnItemGetTileDetailIndex: TItemGetTileDetailEvent;
    FOnItemGetImageIndex: TItemGetImageIndexEvent;
    FOnItemGetImageList: TItemGetImageListEvent;
    FOnItemGetTileDetailCount: TItemGetTileDetailCountEvent;
    FOnItemImageDraw: TItemImageDrawEvent;
    FOnItemImageGetSize: TItemImageGetSizeEvent;
    FOnItemInitialize: TItemInitializeEvent;
    FOnItemLoadFromStream: TItemLoadFromStreamEvent;
    FOnItemMouseDown: TItemMouseDownEvent;
    FOnItemMouseUp: TItemMouseUpEvent;
    FOnItemPaintText: TItemPaintTextEvent;
    FOnItemSaveToStream: TItemSaveToStreamEvent;
    FOnItemSelectionChanged: TItemSelectionChangeEvent;
    FOnItemSelectionChanging: TItemSelectionChangingEvent;
    FOnItemSelectionsChanged: TEasyItemSelectionsChangedEvent;
    FOnItemSetCaption: TItemSetCaptionEvent;
    FOnItemSetGroupKey: TItemSetGroupKeyEvent;
    FOnItemSetImageIndex: TItemSetImageIndexEvent;
    FOnItemSetTileDetail: TItemSetTileDetailEvent;
    FOnItemThumbnailDraw: TItemThumbnailDrawEvent;
    FOnItemVisibilityChanged: TItemVisibilityChangeEvent;
    FOnItemVisibilityChanging: TItemVisibilityChangingEvent;
    FOnKeyAction: TEasyKeyActionEvent;
    FOnOLEDragDrop: TOLEDropTargetDragDropEvent;
    FOnOLEDragEnd: TOLEDropSourceDragEndEvent;
    FOnOLEDragEnter: TOLEDropTargetDragEnterEvent;
    FOnOLEDragLeave: TOLEDropTargetDragLeaveEvent;
    FOnOLEDragOver: TOLEDropTargetDragOverEvent;
    FOnOLEDragStart: TOLEDropSourceDragStartEvent;
    FOnOLEGetCustomFormats: TOLEGetCustomFormatsEvent;
    FOnOLEGetData: TOLEGetDataEvent;
    FOnOLEGetDataObject: FOLEGetDataObjectEvent;
    FOnOLEGiveFeedback: TOLEDropSourceGiveFeedbackEvent;
    FOnOLEQueryContineDrag: TOLEDropSourceQueryContineDragEvent;
    FOnOLEQueryData: TOLEQueryDataEvent;
    FOnPaintHeaderBkGnd: TPaintHeaderBkGndEvent;
    FOnViewChange: TViewChangedEvent;
    FPaintInfoColumn: TEasyPaintInfoBaseColumn;
    FPaintInfoGroup: TEasyPaintInfoBaseGroup;
    FPaintInfoItem: TEasyPaintInfoBaseItem;
    FPopupMenuHeader: TPopupMenu;
    FScratchCanvas: TControlCanvas;
    FScrollbars: TEasyScrollbarManager;
    FSelection: TEasySelectionManager;
    FShowGroupMargins: Boolean;
    FShowInactive: Boolean;
    FShowThemedBorder: Boolean;
    FSort: TEasySortManager;
    FStates: TEasyControlStates;
    FView: TEasyListStyle;
    FWheelMouseDefaultScroll: TEasyDefaultWheelScroll;
    FWheelMouseScrollModifierEnabled: Boolean;
    function GetGroupCollapseImage: TBitmap;
    function GetGroupExpandImage: TBitmap;
    function GetHintType: TEasyHintType;
    function GetPaintInfoColumn: TEasyPaintInfoBaseColumn; virtual;
    function GetPaintInfoGroup: TEasyPaintInfoBaseGroup; virtual;
    function GetPaintInfoItem: TEasyPaintInfoBaseItem; virtual;
    function GetScratchCanvas: TControlCanvas;
    procedure SetBackGround(const Value: TEasyBackgroundManager);
    procedure SetGroupCollapseImage(Value: TBitmap);
    procedure SetGroupExpandImage(Value: TBitmap);
    procedure SetGroupFont(Value: TFont);
    procedure SetHintType(Value: TEasyHintType);
    procedure SetImagesExLarge(Value: TImageList);
    procedure SetImagesGroup(Value: TImageList);
    procedure SetImagesLarge(Value: TImageList);
    procedure SetImagesSmall(Value: TImageList);
    procedure SetPaintInfoColumn(const Value: TEasyPaintInfoBaseColumn); virtual;
    procedure SetPaintInfoGroup(const Value: TEasyPaintInfoBaseGroup); virtual;
    procedure SetPaintInfoItem(const Value: TEasyPaintInfoBaseItem); virtual;
    procedure SetSelection(Value: TEasySelectionManager);
    procedure SetShowInactive(const Value: Boolean);
    procedure SetShowThemedBorder(Value: Boolean);
    procedure SetView(Value: TEasyListStyle);
    procedure SetShowGroupMargins(const Value: Boolean);
  protected
    function CreateColumnPaintInfo: TEasyPaintInfoBaseColumn; virtual;
    function CreateGroupPaintInfo: TEasyPaintInfoBaseGroup; virtual;
    function CreateItemPaintInfo: TEasyPaintInfoBaseItem; virtual;
    function GetSortColumn: TEasyColumn; virtual;
    function GroupTestExpand(HitInfo: TEasyGroupHitTestInfoSet): Boolean; virtual;
    function ToolTipNeeded(TargetObj: TEasyCollectionItem; var TipCaption: WideString): Boolean;
    function ViewSupportsHeader: Boolean;
    procedure CancelCut;
    procedure CheckFocus;
    procedure ClearPendingDrags;
    procedure ClearStates;
    function ClickTestGroup(ViewportPoint: TPoint; KeyStates: TCommonKeyStates; var HitInfo: TEasyGroupHitTestInfoSet): TEasyGroup;
    function ClickTestItem(ViewportPoint: TPoint; Group: TEasyGroup; KeyStates: TCommonKeyStates; var HitInfo: TEasyItemHitTestInfoSet): TEasyItem;
    procedure ClipHeader(ACanvas: TCanvas; ResetClipRgn: Boolean);
    procedure CMDrag(var Msg: TCMDrag); message CM_DRAG;
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
    procedure CMHintShowPause(var Message: TCMHintShow); message CM_HINTSHOWPAUSE;
    procedure CMMouseWheel(var Msg: TWMMouseWheel); message CM_MOUSEWHEEL;
    procedure CMParentFontChanged(var Msg: TMessage); message CM_PARENTFONTCHANGED;  
    procedure CopyToClipboard; virtual;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure CutToClipboard; virtual;
    procedure DoAutoGroupGetKey(Item: TEasyItem; ColumnIndex: Integer; Groups: TEasyGroups; var Key: LongWord); virtual;
    procedure DoAutoSortGroupCreate(Item: TEasyItem; ColumnIndex: Integer; Groups: TEasyGroups; var Group: TEasyGroup; var DoDefaultAction: Boolean); virtual;
    procedure DoClipboardCopy(var Handled: Boolean); virtual;
    procedure DoClipboardCut(var MarkAsCut, Handled: Boolean); virtual;
    procedure DoClipboardPaste(var Handled: Boolean); virtual;
    procedure DoColumnCheckChanged(Column: TEasyColumn); virtual;
    procedure DoColumnCheckChanging(Column: TEasyColumn; var Allow: Boolean); virtual;
    procedure DoColumnClick(Button: TCommonMouseButton; const Column: TEasyColumn); virtual;
    procedure DoColumnContextMenu(HitInfo: TEasyHitInfoColumn; WindowPoint: TPoint; var Menu: TPopupMenu); virtual;
    procedure DoColumnDblClick(Button: TCommonMouseButton; ShiftState: TShiftState; MousePos: TPoint; Column: TEasyColumn); virtual;
    procedure DoColumnEnableChanged(Column: TEasyColumn); virtual;
    procedure DoColumnEnableChanging(Column: TEasyColumn; var Allow: Boolean); virtual;
    procedure DoColumnFocusChanged(Column: TEasyColumn); virtual;
    procedure DoColumnFocusChanging(Column: TEasyColumn; var Allow: Boolean); virtual;
    procedure DoColumnFreeing(Column: TEasyColumn); virtual;
    procedure DoColumnGetCaption(Line: Integer; var Caption: WideString); virtual;
    procedure DoColumnGetImageIndex(Column: TEasyColumn; ImageKind: TEasyImageKind; var ImageIndex: Integer); virtual;
    procedure DoColumnGetImageList(Column: TEasyColumn; var ImageList: TImageList); virtual;
    procedure DoColumnGetDetail(Column: TEasyColumn; Line: Integer; var Detail: Integer); virtual;
    procedure DoColumnGetDetailCount(Column: TEasyColumn; var Count: Integer); virtual;
    procedure DoColumnImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
    procedure DoColumnImageGetSize(Column: TEasyColumn; var ImageWidth, ImageHeight: Integer); virtual;
    procedure DoColumnImageDrawIsCustom(Column: TEasyColumn; var IsCustom: Boolean); virtual;
    procedure DoColumnInitialize(Column: TEasyColumn); virtual;
    procedure DoColumnLoadFromStream(Column: TEasyColumn; S: TStream; Version: Integer = STREAM_VERSION); virtual;
    procedure DoColumnPaintText(Column: TEasyColumn; ACanvas: TCanvas); virtual;
    procedure DoColumnSaveToStream(Column: TEasyColumn; S: TStream; Version: Integer = STREAM_VERSION); virtual;
    procedure DoColumnSelectionChanged(Column: TEasyColumn); virtual;
    procedure DoColumnSelectionChanging(Column: TEasyColumn; var Allow: Boolean); virtual;
    procedure DoColumnSetCaption(Column: TEasyColumn; const Caption: WideString); virtual;
    procedure DoColumnSetImageIndex(Column: TEasyColumn; ImageKind: TEasyImageKind; ImageIndex: Integer); virtual;
    procedure DoColumnSetDetail(Column: TEasyColumn; Line: Integer; Detail: Integer); virtual;
    procedure DoColumnSetDetailCount(Column: TEasyColumn; DetailCount: Integer); virtual;
    procedure DoColumnThumbnailDraw(Column: TEasyColumn; ACanvas: TCanvas; ARect: TRect; var DoDefault: Boolean); virtual;
    procedure DoColumnSizeChanged(Column: TEasyColumn); virtual;
    procedure DoColumnSizeChanging(Column: TEasyColumn; Size, NewSize: Integer; var Allow: Boolean); virtual;
    procedure DoColumnVisibilityChanged(Column: TEasyColumn); virtual;
    procedure DoColumnVisibilityChanging(Column: TEasyColumn; var Allow: Boolean); virtual;
    procedure DoContextMenu(MousePt: TPoint; var Handled: Boolean);
    procedure DoCustomColumnView(var View: TEasyViewColumn);
    procedure DoCustomGrid(ViewStyle: TEasyListStyle; var Grid: TEasyGridGroupClass); virtual;
    procedure DoCustomView(ViewStyle: TEasyListStyle; var View: TEasyViewItemClass); virtual;
    procedure DoDblClick(Button: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState);
    procedure DoGetDragImage(Bitmap: TBitmap; DragStartPt: TPoint; var HotSpot: TPoint; var TransparentColor: TColor; var Handled: Boolean); virtual;
    procedure DoGroupClick(Group: TEasyGroup; KeyStates: TCommonKeyStates; HitTest: TEasyGroupHitTestInfoSet); virtual;
    procedure DoGroupCollapse(Group: TEasyGroup); virtual;
    procedure DoGroupCollapsing(Group: TEasyGroup; var Allow: Boolean); virtual;
    function DoGroupCompare(Column: TEasyColumn; Group1, Group2: TEasyGroup): Integer; virtual;
    procedure DoGroupContextMenu(HitInfo: TEasyHitInfoGroup; WindowPoint: TPoint; var Menu: TPopupMenu; var Handled: Boolean); virtual;
    procedure DoGroupDblClick(Button: TCommonMouseButton; MousePos: TPoint; HitInfo: TEasyHitInfoGroup); virtual;
    procedure DoGroupExpand(Group: TEasyGroup); virtual;
    procedure DoGroupExpanding(Group: TEasyGroup; var Allow: Boolean); virtual;
    procedure DoGroupFreeing(Group: TEasyGroup); virtual;
    procedure DoGroupGetCaption(Group: TEasyGroup; var Caption: WideString); virtual;
    procedure DoGroupGetImageIndex(Group: TEasyGroup; ImageKind: TEasyImageKind; var ImageIndex: Integer); virtual;
    procedure DoGroupGetImageList(Group: TEasyGroup; var ImageList: TImageList); virtual;
    procedure DoGroupGetDetail(Group: TEasyGroup; Line: Integer; var Detail: Integer); virtual;
    procedure DoGroupGetDetailCount(Group: TEasyGroup; var Count: Integer); virtual;
    procedure DoGroupImageDraw(Group: TEasyGroup; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender); virtual;
    procedure DoGroupImageGetSize(Group: TEasyGroup; var ImageWidth, ImageHeight: Integer); virtual;
    procedure DoGroupImageDrawIsCustom(Group: TEasyGroup; var IsCustom: Boolean); virtual;
    procedure DoGroupInitialize(Group: TEasyGroup); virtual;
    procedure DoGroupHotTrack(Group: TEasyGroup; State: TEasyHotTrackState; MousePos: TPoint); virtual;
    procedure DoGroupLoadFromStream(Group: TEasyGroup; S: TStream; Version: Integer = STREAM_VERSION); virtual;
    procedure DoGroupPaintText(Group: TEasyGroup; ACanvas: TCanvas); virtual;
    procedure DoGroupSaveToStream(Group: TEasyGroup; S: TStream; Version: Integer = STREAM_VERSION); virtual;
    procedure DoGroupSelectionChanged(Group: TEasyGroup); virtual;
    procedure DoGroupSelectionChanging(Group: TEasyGroup; var Allow: Boolean); virtual;
    procedure DoGroupSetCaption(Group: TEasyGroup; const Caption: WideString); virtual;
    procedure DoGroupSetImageIndex(Group: TEasyGroup; ImageKind: TEasyImageKind; ImageIndex: Integer); virtual;
    procedure DoGroupSetDetail(Group: TEasyGroup; Line: Integer; Detail: Integer); virtual;
    procedure DoGroupSetDetailCount(Group: TEasyGroup; DetailCount: Integer); virtual;
    procedure DoGroupThumbnailDraw(Group: TEasyGroup; ACanvas: TCanvas; ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean); virtual;
    procedure DoGroupVisibilityChanged(Group: TEasyGroup); virtual;
    procedure DoGroupVisibilityChanging(Group: TEasyGroup; var Allow: Boolean); virtual;
    procedure DoHeaderDblClick(Button: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState); virtual;
    procedure DoHintCustomInfo(TargetObj: TEasyCollectionItem; const Info: TEasyHintInfo); virtual;
    procedure DoHintCustomDraw(TargetObj: TEasyCollectionItem; const Info: TEasyHintInfo); virtual;
    procedure DoHintPopup(TargetObj: TEasyCollectionItem; HintType: TEasyHintType; MousePos: TPoint; var AText: WideString; var HideTimeout, ReshowTimeout: Integer; var Allow: Boolean); virtual;
    procedure DoHintShowPause(HintShowingNow: Boolean; var PauseTime: Integer);
    procedure DoIncrementalSearch(Item: TEasyItem; const SearchBuffer: WideString; var CompareResult: Integer); virtual;
    procedure DoItemCheckChanged(Item: TEasyItem); virtual;
    procedure DoItemCheckChanging(Item: TEasyItem; var Allow: Boolean); virtual;
    procedure DoItemClick(Item: TEasyItem; KeyStates: TCommonKeyStates; HitInfo: TEasyItemHitTestInfoSet); virtual;
    function DoItemCompare(Column: TEasyColumn; Group: TEasyGroup; Item1, Item2: TEasyItem): Integer; virtual;
    procedure DoItemContextMenu(HitInfo: TEasyHitInfoItem; WindowPoint: TPoint; var Menu: TPopupMenu; var Handled: Boolean); virtual;
    procedure DoItemCreateEditor(Item: TEasyItem; var Editor: IEasyCellEditor); virtual;
    procedure DoItemDblClick(Button: TCommonMouseButton; MousePos: TPoint; HitInfo: TEasyHitInfoItem); virtual;
    procedure DoItemEditBegin(Item: TEasyItem; var Column: Integer; var Allow: Boolean); virtual;
    procedure DoItemEdited(Item: TEasyItem; var NewValue: Variant; var Accept: Boolean); virtual;
    procedure DoItemEditEnd(Item: TEasyItem); virtual;
    procedure DoItemEnableChanged(Item: TEasyItem); virtual;
    procedure DoItemEnableChanging(Item: TEasyItem; var Allow: Boolean); virtual;
    procedure DoItemFreeing(Item: TEasyItem); virtual;
    procedure DoItemFocusChanged(Item: TEasyItem); virtual;
    procedure DoItemFocusChanging(Item: TEasyItem; var Allow: Boolean); virtual;
    procedure DoItemGetCaption(Item: TEasyItem; Column: Integer; var Caption: WideString); virtual;
    procedure DoItemGetEditCaption(Item: TEasyItem; Column: TEasyColumn; var Caption: WideString); virtual;
    procedure DoItemGetGroupKey(Item: TEasyItem; FocusedColumn: Integer; var Key: LongWord); virtual;
    procedure DoItemGetImageIndex(Item: TEasyItem; Column: Integer; ImageKind: TEasyImageKind; var ImageIndex: Integer); virtual;
    procedure DoItemGetImageList(Item: TEasyItem; Column: Integer; var ImageList: TImageList); virtual;
    procedure DoItemGetTileDetail(Item: TEasyItem; Line: Integer; var Detail: Integer); virtual;
    procedure DoItemGetTileDetailCount(Item: TEasyItem; var Count: Integer); virtual;
    procedure DoItemHotTrack(Item: TEasyItem; State: TEasyHotTrackState; MousePos: TPoint); virtual;
    procedure DoItemImageDraw(Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender); virtual;
    procedure DoItemImageGetSize(Item: TEasyItem; Column: TEasyColumn; var ImageWidth, ImageHeight: Integer); virtual;
    procedure DoItemImageDrawIsCustom(Column: TEasyColumn; Item: TEasyItem; var IsCustom: Boolean); virtual;
    procedure DoItemInitialize(Item: TEasyItem); virtual;
    procedure DoItemLoadFromStream(Item: TEasyItem; S: TStream; Version: Integer = STREAM_VERSION); virtual;
    procedure DoItemMouseDown(Item: TEasyItem; Button: TCommonMouseButton; var DoDefault: Boolean); virtual;
    procedure DoItemMouseUp(Item: TEasyItem; Button: TCommonMouseButton; var DoDefault: Boolean); virtual;
    procedure DoItemPaintText(Item: TEasyItem; Position: Integer; ACanvas: TCanvas); virtual;
    procedure DoItemSaveToStream(Item: TEasyItem; S: TStream; Version: Integer = STREAM_VERSION); virtual;
    procedure DoItemSelectionChanged(Item: TEasyItem); virtual;
    procedure DoItemSelectionChanging(Item: TEasyItem; var Allow: Boolean); virtual;
    procedure DoItemSelectionsChanged; virtual;
    procedure DoItemSetCaption(Item: TEasyItem; Column: Integer; const Caption: WideString); virtual;
    procedure DoItemSetGroupKey(Item: TEasyItem; FocusedColumn: Integer; Key: LongWord); virtual;
    procedure DoItemSetImageIndex(Item: TEasyItem; Column: Integer; ImageKind: TEasyImageKind; ImageIndex: Integer); virtual;
    procedure DoItemSetTileDetail(Item: TEasyItem; Line: Integer; Detail: Integer); virtual;
    procedure DoItemSetTileDetailCount(Item: TEasyItem; Detail: Integer); virtual;
    procedure DoItemThumbnailDraw(Item: TEasyItem; ACanvas: TCanvas; ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean); virtual;
    procedure DoItemVisibilityChanged(Item: TEasyItem); virtual;
    procedure DoItemVisibilityChanging(Item: TEasyItem; var Allow: Boolean); virtual;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    procedure DoKeyAction(var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean); virtual;
    procedure DoOLEDragEnd(ADataObject: IDataObject; DragResult: TCommonOLEDragResult; ResultEffect: TCommonDropEffects); virtual;
    procedure DoOLEDragStart(ADataObject: IDataObject; var AvailableEffects: TCommonDropEffects; var AllowDrag: Boolean); virtual;
    procedure DoOLEDropSourceQueryContineDrag(EscapeKeyPressed: Boolean; KeyStates: TCommonKeyStates; var QueryResult: TEasyQueryDragResult); virtual;
    procedure DoOLEDropSourceGiveFeedback(Effect: TCommonDropEffects; var UseDefaultCursors: Boolean); virtual;
    procedure DoOLEDropTargetDragEnter(DataObject: IDataObject; KeyState: TCommonKeyStates; WindowPt: TPoint; AvailableEffects: TCommonDropEffects; var DesiredEffect: TCommonDropEffect); virtual;
    procedure DoOLEDropTargetDragOver(KeyState: TCommonKeyStates; WindowPt: TPoint; AvailableEffects: TCommonDropEffects; var DesiredEffect: TCommonDropEffect); virtual;
    procedure DoOLEDropTargetDragLeave; virtual;
    procedure DoOLEDropTargetDragDrop(DataObject: IDataObject; KeyState: TCommonKeyStates; WindowPt: TPoint; AvailableEffects: TCommonDropEffects; var DesiredEffect: TCommonDropEffect); virtual;
    procedure DoOLEGetCustomFormats(var Formats: TEasyFormatEtcArray); virtual;
    procedure DoOLEGetData(const FormatEtcIn: TFormatEtc; var Medium: TStgMedium; var Handled: Boolean); virtual;
    procedure DoOLEGetDataObject(var DataObject: IDataObject); virtual;
    procedure DoPaintHeaderBkGnd(ACanvas: TCanvas; ARect: TRect; var Handled: Boolean); virtual;
    procedure DoPaintRect(ACanvas: TCanvas; WindowClipRect: TRect; SelectedOnly: Boolean); virtual;
    procedure DoQueryOLEData(const FormatEtcIn: TFormatEtc; var FormatAvailable: Boolean; var Handled: Boolean); virtual;
    procedure DoThreadCallback(var Msg: TWMThreadRequest); virtual;
    procedure DoUpdate; override;
    procedure DoViewChange; virtual;

    procedure DestroyWnd; override;
    function DragInitiated: Boolean;
    procedure FinalizeDrag(WindowPoint: TPoint; KeyState: TCommonKeyStates);
    procedure FontChanged(Sender: TObject);
    procedure GroupFontChanged(Sender: TObject);
    procedure HandleDblClick(Button: TCommonMouseButton; Msg: TWMMouse); virtual;
    procedure HandleKeyDown(Msg: TWMKeyDown); virtual;
    procedure HandleMouseDown(Button: TCommonMouseButton; Msg: TWMMouse); virtual;
    procedure HandleMouseUp(Button: TCommonMouseButton; Msg: TWMMouse); virtual;
    procedure InitializeDragPendings(HitItem: TEasyItem; WindowPoint: TPoint; KeyState: TCommonKeyStates; AllowDrag, AllowDragRect: Boolean);
    function IsFontStored: Boolean;
    function IsHeaderMouseMsg(MousePos: TSmallPoint; ForceTest: Boolean = False): Boolean;
    procedure MarkSelectedCut;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure PasteFromClipboard; virtual;
    procedure ResizeBackBits(NewWidth, NewHeight: Integer);
    procedure WMChar(var Msg: TWMChar); message WM_CHAR;
    procedure WMContextMenu(var Msg: TMessage); message WM_CONTEXTMENU;
    procedure WMDestroy(var Msg: TMessage); message WM_DESTROY;
    procedure WMEasyThreadCallback(var Msg: TWMThreadRequest); message WM_COMMONTHREADCALLBACK;
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMHScroll(var Msg: TWMHScroll); message WM_HSCROLL;
    procedure WMKeyDown(var Msg: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMLButtonDblClk(var Msg: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMMButtonDblClk(var Msg: TWMMButtonDblClk); message WM_MBUTTONDBLCLK;
    procedure WMMButtonDown(var Msg: TWMMButtonDown); message WM_MBUTTONDOWN;
    procedure WMMouseActivate(var Msg: TWMMouseActivate); message WM_MOUSEACTIVATE;
    procedure WMMouseMove(var Msg: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMNCCalcSize(var Msg: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCPaint(var Msg: TWMNCPaint); message WM_NCPAINT;
    procedure WMRButtonDblClk(var Msg: TWMRButtonDblClk); message WM_RBUTTONDBLCLK;
    procedure WMRButtonDown(var Msg: TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure WMRButtonUp(var Msg: TWMRButtonUp); message WM_RBUTTONUP;
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure WMTabMoveFocus(var Msg: TMessage); message WM_TABMOVEFOCUS;
    procedure WMVScroll(var Msg: TWMVScroll); message WM_VSCROLL;
    procedure WMWindowPosChanged(var Msg: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure WMWindowPosChanging(var Msg: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;

    property BackBits: TBitmap read FBackBits write FBackBits;
    property BackGround: TEasyBackgroundManager read FBackGround write SetBackGround;
    property BevelInner default bvLowered;
    property CacheDoubleBufferBits: Boolean read FCacheDoubleBufferBits write FCacheDoubleBufferBits;
    property CheckManager: TEasyCheckManager read FCheckManager write FCheckManager;
    property Color default clWindow;
    property CellSizes: TEasyCellSizes read FCellSizes write FCellSizes;
    property DisabledBlendAlpha: Byte read FDisabledBlendAlpha write FDisabledBlendAlpha default 128;
    property DisabledBlendColor: TColor read FDisabledBlendColor write FDisabledBlendColor default clWindow;
    property DragManager: TEasyOLEDragManager read FDragManager write FDragManager;
    property DragRect: TEasyDragRectManager read FDragRect write FDragRect;
    property DropTarget: IDropTarget read FDropTarget write FDropTarget;
    property EditManager: TEasyEditManager read FEditManager write FEditManager;
    property GlobalImages: TEasyGlobalImageManager read FGlobalImages write FGlobalImages;
    property GroupCollapseButton: TBitmap read GetGroupCollapseImage write SetGroupCollapseImage;
    property GroupExpandButton: TBitmap read GetGroupExpandImage write SetGroupExpandImage;
    property GroupFont: TFont read FGroupFont write SetGroupFont stored IsFontStored;
    property Groups: TEasyGroups read FGroups write FGroups;
    property Header: TEasyHeader read FHeader write FHeader;
    property HintData: TEasyHintInfoRec read FHintData write FHintData;
    property HintInfo: TEasyHintInfo read FHintInfo write FHintInfo;
    property HintType: TEasyHintType read GetHintType write SetHintType default ehtText;
    property HotTrack: TEasyHotTrackManager read FHotTrack write FHotTrack;
    property ImagesGroup: TImageList read FImagesGroup write SetImagesGroup;
    property ImagesSmall: TImageList read FImagesSmall write SetImagesSmall;
    property ImagesLarge: TImageList read FImagesLarge write SetImagesLarge;
    property ImagesExLarge: TImageList read FImagesExLarge write SetImagesExLarge;
    property IncrementalSearch: TEasyIncrementalSearchManager read FIncrementalSearch write FIncrementalSearch;
    property Items: TEasyGlobalItems read FItems;
    property NCCanvas: TCanvas read FNCCanvas write FNCCanvas;
    property OnAutoGroupGetKey: TAutoGroupGetKeyEvent read FOnAutoGroupGetKey write FOnAutoGroupGetKey;
    property OnAutoSortGroupCreate: TAutoSortGroupCreateEvent read FOnAutoSortGroupCreate write FOnAutoSortGroupCreate;
    property OnClipboardCopy: TEasyClipboardEvent read FOnClipboardCopy write FOnClipboardCopy;
    property OnClipboardCut: TEasyClipboardCutEvent read FOnClipboardCut write FOnClipboardCut;
    property OnClipboardPaste: TEasyClipboardEvent read FOnClipboardPaste write FOnClipboardPaste;
    property OnColumnCheckChanged: TColumnCheckChangeEvent read FOnColumnCheckChange write FOnColumnCheckChange;
    property OnColumnCheckChanging: TColumnCheckChangingEvent read FOnColumnCheckChanging write FOnColumnCheckChanging;
    property OnColumnClick: TColumnClickEvent read FOnColumnClick write FOnColumnClick;
    property OnColumnContextMenu: TColumnContextMenuEvent read FOnColumnContextMenu write FOnColumnContextMenu;
    property OnColumnDblClick: TColumnDblClickEvent read FOnColumnDblClick write FOnColumnDblClick;
    property OnColumnEnableChanged: TColumnEnableChangeEvent read FOnColumnEnableChange write FOnColumnEnableChange;
    property OnColumnEnableChanging: TColumnEnableChangingEvent read FOnColumnEnableChanging write FOnColumnEnableChanging;
    property OnColumnFocusChanged: TColumnFocusChangeEvent read FOnColumnFocusChanged write FOnColumnFocusChanged;
    property OnColumnFocusChanging: TColumnFocusChangingEvent read FOnColumnFocusChanging write FOnColumnFocusChanging;
    property OnColumnFreeing: TColumnFreeingEvent read FOnColumnFreeing write FOnColumnFreeing;
    property OnColumnGetCaption: TColumnGetCaptionEvent read FOnColumnGetCaption write FOnColumnGetCaption;
    property OnColumnGetImageIndex: TColumnGetImageIndexEvent read FOnColumnGetImageIndex write FOnColumnGetImageIndex;
    property OnColumnGetImageList: TColumnGetImageListEvent read FOnColumnGetImageList write FOnColumnGetImageList;
    property OnColumnGetDetail: TColumnGetDetailEvent read FOnColumnGetDetail write FOnColumnGetDetail;
    property OnColumnGetDetailCount: TColumnGetDetailCountEvent read FOnColumnGetDetailCount write FOnColumnGetDetailCount;
    property OnColumnImageDraw: TColumnImageDrawEvent read FOnColumnImageDraw write FOnColumnImageDraw;
    property OnColumnImageGetSize: TColumnImageGetSizeEvent read FOnColumnImageGetSize write FOnColumnImageGetSize;
    property OnColumnImageDrawIsCustom: TColumnImageDrawIsCustomEvent read FOnColumnImageDrawIsCustom write FOnColumnImageDrawIsCustom;
    property OnColumnInitialize: TColumnInitializeEvent read FOnColumnInitialize write FOnColumnInitialize;
    property OnColumnLoadFromStream: TEasyColumnLoadFromStreamEvent read FOnColumnLoadFromStream write FOnColumnLoadFromStream;
    property OnColumnPaintText: TColumnPaintTextEvent read FOnColumnPaintText write FOnColumnPaintText;
    property OnColumnSaveToStream: TEasyColumnSaveToStreamEvent read FOnColumnSaveToStream write FOnColumnSaveToStream;
    property OnColumnSelectionChanged: TColumnSelectionChangeEvent read FOnColumnSelectionChanged write FOnColumnSelectionChanged;
    property OnColumnSelectionChanging: TColumnSelectionChangingEvent read FOnColumnSelectionChanging write FOnColumnSelectionChanging;
    property OnColumnSetCaption: TColumnSetCaptionEvent read FOnColumnSetCaption write FOnColumnSetCaption;
    property OnColumnSetImageIndex: TColumnSetImageIndexEvent read FOnColumnSetImageIndex write FOnColumnSetImageIndex;
    property OnColumnSetDetail: TColumnSetDetailEvent read FOnColumnSetDetail write FOnColumnSetDetail;
    property OnColumnThumbnailDraw: TColumnThumbnailDrawEvent read FOnColumnThumbnailDraw write FOnColumnThumbnailDraw;
    property OnColumnSizeChanged: TColumnSizeChangedEvent read FOnColumnSizeChanged write FOnColumnSizeChanged;
    property OnColumnSizeChanging: TColumnSizeChangingEvent read FOnColumnSizeChanging write FOnColumnSizeChanging;
    property OnColumnVisibilityChanged: TColumnVisibilityChangeEvent read FOnColumnVisibilityChanged write FOnColumnVisibilityChanged;
    property OnColumnVisibilityChanging: TColumnVisibilityChangingEvent read FOnColumnVisibilityChanging write FOnColumnVisibilityChanging;
    property OnContextMenu: TContextMenuEvent read FOnContextMenu write FOnContextMenu;
    property OnCustomColumnView: TCustomColumnViewEvent read FOnCustomColumnView write FOnCustomColumnView;
    property OnCustomGrid: TCustomGridEvent read FOnCustomGrid write FOnCustomGrid;
    property OnCustomView: TCustomViewEvent read FOnCustomView write FOnCustomView;
    property OnDblClick: TDblClickEvent read FOnDblClick write FOnDblClick;
    property OnGetDragImage: TGetDragImageEvent read FOnGetDragImage write FOnGetDragImage;
    property OnGroupClick: TGroupClickEvent read FOnGroupClick write FOnGroupClick;
    property OnGroupCollapse: TGroupCollapseEvent read FOnGroupCollapse write FOnGroupCollapse;
    property OnGroupCollapsing: TGroupCollapsingEvent read FOnGroupCollapsing write FOnGroupCollapsing;
    property OnGroupCompare: TGroupCompareEvent read FOnGroupCompare write FOnGroupCompare;
    property OnGroupContextMenu: TGroupContextMenuEvent read FOnGroupContextMenu write FOnGroupContextMenu;
    property OnGroupDblClick: TGroupDblClickEvent read FOnGroupDblClick write FOnGroupDblClick;
    property OnGroupExpand: TGroupExpandEvent read FOnGroupExpand write FOnGroupExpand;
    property OnGroupExpanding: TGroupExpandingEvent read FOnGroupExpanding write FOnGroupExpanding;
    property OnGroupFocusChanged: TGroupFocusChangeEvent read FOnGroupFocusChanged write FOnGroupFocusChanged;
    property OnGroupFocusChanging: TGroupFocusChangingEvent read FOnGroupFocusChanging write FOnGroupFocusChanging;
    property OnGroupFreeing: TGroupFreeingEvent read FOnGroupFreeing write FOnGroupFreeing;
    property OnGroupGetCaption: TGroupGetCaptionEvent read FOnGroupGetCaption write FOnGroupGetCaption;
    property OnGroupGetImageIndex: TGroupGetImageIndexEvent read FOnGroupGetImageIndex write FOnGroupGetImageIndex;
    property OnGroupGetImageList: TGroupGetImageListEvent read FOnGroupGetImageList write FOnGroupGetImageList;
    property OnGroupGetDetail: TGroupGetDetailEvent read FOnGroupGetDetailIndex write FOnGroupGetDetailIndex;
    property OnGroupGetDetailCount: TGroupGetDetailCountEvent read FOnGroupGetDetailCount write FOnGroupGetDetailCount;
    property OnGroupHotTrack: TGroupHotTrackEvent read FOnGroupHotTrack write FOnGroupHotTrack;
    property OnGroupImageDraw: TGroupImageDrawEvent read FOnGroupImageDrawEvent write FOnGroupImageDrawEvent;
    property OnGroupImageGetSize: TGroupImageGetSizeEvent read FGroupImageGetSize write FGroupImageGetSize;
    property OnGroupImageDrawIsCustom: TGroupImageDrawIsCustomEvent read FOnGroupImageDrawIsCustom write FOnGroupImageDrawIsCustom;
    property OnGroupInitialize: TGroupInitializeEvent read FOnGroupInitialize write FOnGroupInitialize;
    property OnGroupLoadFromStream: TGroupLoadFromStreamEvent read FOnGroupLoadFromStream write FOnGroupLoadFromStream;
    property OnGroupPaintText: TGroupPaintTextEvent read FOnGroupPaintText write FOnGroupPaintText;
    property OnGroupSaveToStream: TGroupSaveToStreamEvent read FOnGroupSaveToStream write FOnGroupSaveToStream;
    property OnGroupSelectionChanged: TGroupSelectionChangeEvent read FOnGroupSelectionChanged write FOnGroupSelectionChanged;
    property OnGroupSelectionChanging: TGroupSelectionChangingEvent read FOnGroupSelectionChanging write FOnGroupSelectionChanging;
    property OnGroupSetCaption: TGroupSetCaptionEvent read FOnGroupSetCaption write FOnGroupSetCaption;
    property OnGroupSetImageIndex: TGroupSetImageIndexEvent read FOnGroupSetImageIndex write FOnGroupSetImageIndex;
    property OnGroupSetDetail: TGroupSetDetailEvent read FOnGroupSetDetail write FOnGroupSetDetail;
    property OnGroupThumbnailDraw: TGroupThumbnailDrawEvent read FOnGroupThumbnailDraw write FOnGroupThumbnailDraw;
    property OnGroupVisibilityChanged: TGroupVisibilityChangeEvent read FOnGroupVisibilityChanged write FOnGroupVisibilityChanged;
    property OnGroupVisibilityChanging: TGroupVisibilityChangingEvent read FOnGroupVisibilityChanging write FOnGroupVisibilityChanging;
    property OnHeaderDblClick: THeaderDblClickEvent read FOnHeaderDblClick write FOnHeaderDblClick;
    property OnHeaderMouseDown: THeaderMouseEvent read FOnHeaderMouseDown write FOnHeaderMouseDown;
    property OnHeaderMouseMove: TMouseMoveEvent read FOnHeaderMouseMove write FOnHeaderMouseMove;
    property OnHeaderMouseUp: THeaderMouseEvent read FOnHeaderMouseUp write FOnHeaderMouseUp;
    property OnHintCustomDraw: THintCustomDrawEvent read FOnHintCustomDraw write FOnHintCustomDraw;
    property OnHintCustomInfo: THintCustomizeInfoEvent read FOnHintCustomInfo write FOnHintCustomInfo;
    property OnHintPauseTime: THintPauseTimeEvent read FOnHintPauseTime write FOnHintPauseTime;
    property OnHintPopup: THintPopupEvent read FOnHintPopup write FOnHintPopup;
    property OnIncrementalSearch: TIncrementalSearchEvent read FOnIncrementalSearch write FOnIncrementalSearch;
    property OnItemCheckChange: TItemCheckChangeEvent read FOnItemCheckChange write FOnItemCheckChange;
    property OnItemCheckChanging: TItemCheckChangingEvent read FOnItemCheckChanging write FOnItemCheckChanging;
    property OnItemClick: TItemClickEvent read FOnItemClick write FOnItemClick;
    property OnItemCompare: TItemCompareEvent read FOnItemCompare write FOnItemCompare;
    property OnItemContextMenu: TItemContextMenuEvent read FOnItemContextMenu write FOnItemContextMenu;
    property OnItemCreateEditor: TItemCreateEditorEvent read FOnItemCreateEditor write FOnItemCreateEditor;
    property OnItemDblClick: TItemDblClickEvent read FOnItemDblClick write FOnItemDblClick;
    property OnItemEditBegin: TItemEditBegin read FOnItemEditBegin write FOnItemEditBegin;
    property OnItemEdited: TItemEditedEvent read FOnItemEdited write FOnItemEdited;
    property OnItemEditEnd: TItemEditEnd read FOnItemEditEnd write FOnItemEditEnd;
    property OnItemEnableChange: TItemEnableChangeEvent read FOnItemEnableChange write FOnItemEnableChange;
    property OnItemEnableChanging: TItemEnableChangingEvent read FOnItemEnableChanging write FOnItemEnableChanging;
    property OnItemFreeing: TItemFreeingEvent read FOnItemFreeing write FOnItemFreeing;
    property OnItemFocusChanged: TItemFocusChangeEvent read FOnItemFocusChanged write FOnItemFocusChanged;
    property OnItemFocusChanging: TItemFocusChangingEvent read FOnItemFocusChanging write FOnItemFocusChanging;
    property OnItemGetCaption: TItemGetCaptionEvent read FOnItemGetCaption write FOnItemGetCaption;
    property OnItemGetEditCaption: TEasyItemGetCaptionEvent read FOnItemGetEditCaption write FOnItemGetEditCaption;
    property OnItemGetGroupKey: TItemGetGroupKeyEvent read FOnItemGetGroupKey write FOnItemGetGroupKey;
    property OnItemHotTrack: TItemHotTrackEvent read FOnItemHotTrack write FOnItemHotTrack;
    property OnItemGetImageIndex: TItemGetImageIndexEvent read FOnItemGetImageIndex write FOnItemGetImageIndex;
    property OnItemGetImageList: TItemGetImageListEvent read FOnItemGetImageList write FOnItemGetImageList;
    property OnItemGetTileDetail: TItemGetTileDetailEvent read FOnItemGetTileDetailIndex write FOnItemGetTileDetailIndex;
    property OnItemGetTileDetailCount: TItemGetTileDetailCountEvent read FOnItemGetTileDetailCount write FOnItemGetTileDetailCount;
    property OnItemImageDraw: TItemImageDrawEvent read FOnItemImageDraw write FOnItemImageDraw;
    property OnItemImageGetSize: TItemImageGetSizeEvent read FOnItemImageGetSize write FOnItemImageGetSize;
    property OnItemImageDrawIsCustom: TItemImageDrawIsCustomEvent read FOnItemImageDrawIsCustom write FOnItemImageDrawIsCustom;
    property OnItemLoadFromStream: TItemLoadFromStreamEvent read FOnItemLoadFromStream write FOnItemLoadFromStream;
    property OnItemInitialize: TItemInitializeEvent read FOnItemInitialize write FOnItemInitialize;
    property OnItemMouseDown: TItemMouseDownEvent read FOnItemMouseDown write FOnItemMouseDown;
    property OnItemMouseUp: TItemMouseUpEvent read FOnItemMouseUp write FOnItemMouseUp;
    property OnItemPaintText: TItemPaintTextEvent read FOnItemPaintText write FOnItemPaintText;
    property OnItemSaveToStream: TItemSaveToStreamEvent read FOnItemSaveToStream write FOnItemSaveToStream;
    property OnItemSelectionChanged: TItemSelectionChangeEvent read FOnItemSelectionChanged write FOnItemSelectionChanged;
    property OnItemSelectionChanging: TItemSelectionChangingEvent read FOnItemSelectionChanging write FOnItemSelectionChanging;
    property OnItemSelectionsChanged: TEasyItemSelectionsChangedEvent read FOnItemSelectionsChanged write FOnItemSelectionsChanged;
    property OnItemSetCaption: TItemSetCaptionEvent read FOnItemSetCaption write FOnItemSetCaption;
    property OnItemSetGroupKey: TItemSetGroupKeyEvent read FOnItemSetGroupKey write FOnItemSetGroupKey;
    property OnItemSetImageIndex: TItemSetImageIndexEvent read FOnItemSetImageIndex write FOnItemSetImageIndex;
    property OnItemSetTileDetail: TItemSetTileDetailEvent read FOnItemSetTileDetail write FOnItemSetTileDetail;
    property OnItemThumbnailDraw: TItemThumbnailDrawEvent read FOnItemThumbnailDraw write FOnItemThumbnailDraw;
    property OnItemVisibilityChanged: TItemVisibilityChangeEvent read FOnItemVisibilityChanged write FOnItemVisibilityChanged;
    property OnItemVisibilityChanging: TItemVisibilityChangingEvent read FOnItemVisibilityChanging write FOnItemVisibilityChanging;
    property OnKeyAction: TEasyKeyActionEvent read FOnKeyAction write FOnKeyAction;
    property OldGroupFontChangeNotify: TNotifyEvent read FOldGroupFontChangeNotify write FOldGroupFontChangeNotify;
    property OldFontChangeNotify: TNotifyEvent read FOldFontChangeNotify write FOldFontChangeNotify;
    property OnOLEDragEnd: TOLEDropSourceDragEndEvent read FOnOLEDragEnd write FOnOLEDragEnd;
    property OnOLEDragStart: TOLEDropSourceDragStartEvent read FOnOLEDragStart write FOnOLEDragStart;
    property OnOLEDragEnter: TOLEDropTargetDragEnterEvent read FOnOLEDragEnter write FOnOLEDragEnter;
    property OnOLEDragOver: TOLEDropTargetDragOverEvent read FOnOLEDragOver write FOnOLEDragOver;
    property OnOLEDragLeave: TOLEDropTargetDragLeaveEvent read FOnOLEDragLeave write FOnOLEDragLeave;
    property OnOLEDragDrop: TOLEDropTargetDragDropEvent read FOnOLEDragDrop write FOnOLEDragDrop;
    property OnOLEGetCustomFormats: TOLEGetCustomFormatsEvent read FOnOLEGetCustomFormats write FOnOLEGetCustomFormats;
    property OnOLEGetData: TOLEGetDataEvent read FOnOLEGetData write FOnOLEGetData;
    property OnOLEGetDataObject: FOLEGetDataObjectEvent read FOnOLEGetDataObject write FOnOLEGetDataObject;
    property OnOLEQueryContineDrag: TOLEDropSourceQueryContineDragEvent read FOnOLEQueryContineDrag write FOnOLEQueryContineDrag;
    property OnOLEGiveFeedback: TOLEDropSourceGiveFeedbackEvent read FOnOLEGiveFeedback write FOnOLEGiveFeedback;
    property OnOLEQueryData: TOLEQueryDataEvent read FOnOLEQueryData write FOnOLEQueryData;
    property OnPaintHeaderBkGnd: TPaintHeaderBkGndEvent read FOnPaintHeaderBkGnd write FOnPaintHeaderBkGnd;
    property OnViewChange: TViewChangedEvent read FOnViewChange write FOnViewChange;
    property PaintInfoColumn: TEasyPaintInfoBaseColumn read GetPaintInfoColumn write SetPaintInfoColumn;
    property PaintInfoGroup: TEasyPaintInfoBaseGroup read GetPaintInfoGroup write SetPaintInfoGroup;
    property PaintInfoItem: TEasyPaintInfoBaseItem read GetPaintInfoItem write SetPaintInfoItem;
    {$IFDEF COMPILER_7_UP}property ParentBackground default False;{$ENDIF COMPILER_7_UP}
    property ParentColor default False;
    property PopupMenuHeader: TPopupMenu read FPopupMenuHeader write FPopupMenuHeader;
    property ScratchCanvas: TControlCanvas read GetScratchCanvas write FScratchCanvas;
    property Scrollbars: TEasyScrollbarManager read FScrollbars write FScrollbars;
    property Selection: TEasySelectionManager read FSelection write SetSelection;
    property ShowGroupMargins: Boolean read FShowGroupMargins write SetShowGroupMargins default False;
    property ShowInactive: Boolean read FShowInactive write SetShowInactive;
    property ShowThemedBorder: Boolean read FShowThemedBorder write SetShowThemedBorder default True;
    property Sort: TEasySortManager read FSort write FSort;
    property TabStop default True;
    property View: TEasyListStyle read FView write SetView;
    property WheelMouseDefaultScroll: TEasyDefaultWheelScroll read FWheelMouseDefaultScroll write FWheelMouseDefaultScroll default edwsVert;
    property WheelMouseScrollModifierEnabled: Boolean read FWheelMouseScrollModifierEnabled write FWheelMouseScrollModifierEnabled default True;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function ClientInViewportCoords: TRect;
    function IsGrouped: Boolean; virtual;
    function IsThumbnailView: Boolean;
    function IsVertView: Boolean;
    procedure BeginUpdate; override;
    procedure EndUpdate(Invalidate: Boolean = True); override;
    procedure Loaded; override;
    procedure LoadFromFile(FileName: WideString; Mode: Word);
    procedure LoadFromStream(S: TStream); virtual;
    procedure SaveToFile(FileName: WideString; Mode: Word);
    procedure SaveToStream(S: TStream); virtual;
    property States: TEasyControlStates read FStates write FStates;
  published
  end;

  TEasyBaseEditor = class(TEasyInterfacedPersistent, IEasyCellEditor)
  private
    FEditColumn: TEasyColumn;
    FEditor: TWinControl;
    FItem: TEasyItem;
    FModified: Boolean;
    FOldWndProc: TWndMethod;
    FRectArray: TEasyRectArrayObject;
    function GetEditor: TWinControl; virtual;
    function GetListview: TCustomEasyListview;
    procedure SetEditor(const Value: TWinControl); virtual;
  protected
    function EditText(Item: TEasyItem; Column: TEasyColumn): WideString; virtual;
    procedure CalculateEditorRect(NewText: WideString; var NewRect: TRect); virtual; abstract;
    procedure CreateEditor(var AnEditor: TWinControl; Column: TEasyColumn); virtual; abstract;
    function GetEditorFont: TFont; virtual; abstract;

    function GetText: Variant; virtual; abstract;
    procedure ResizeEditor;
    property EditColumn: TEasyColumn read FEditColumn write FEditColumn;
    property Editor: TWinControl read GetEditor write SetEditor;
    property Item: TEasyItem read FItem write FItem;
    property Listview: TCustomEasyListview read GetListview;
    property Modified: Boolean read FModified write FModified;
    property OldWndProc: TWndMethod read FOldWndProc write FOldWndProc;
    property RectArray: TEasyRectArrayObject read FRectArray write FRectArray;
  public
    function AcceptEdit: Boolean;                         {IEasyCellEditor}
    procedure ControlWndHookProc(var Message: TMessage);  {IEasyCellEditor}
    function GetModified: Boolean;                        {IEasyCellEditor}
    function PtInEditControl(WindowPt: TPoint): Boolean;  {IEasyCellEditor}
    procedure Finalize;                                   {IEasyCellEditor}
    procedure Hide;                                       {IEasyCellEditor}
    procedure Initialize(AnItem: TEasyItem; Column: TEasyColumn);  {IEasyCellEditor}
    procedure SetEditorFocus; virtual;                    {IEasyCellEditor}
    procedure Show;                                       {IEasyCellEditor}
  end;

  TEasyStringEditor = class(TEasyBaseEditor)
  protected
    procedure CalculateEditorRect(NewText: WideString; var NewRect: TRect); override;
    procedure CreateEditor(var AnEditor: TWinControl; Column: TEasyColumn); override;
    function GetEditorFont: TFont; override;
    function GetText: Variant; override;
    procedure OnEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    procedure SetEditorFocus; override;
  end;

  TEasyMemoEditor = class(TEasyBaseEditor)
  protected
    procedure CalculateEditorRect(NewText: WideString; var NewRect: TRect); override;
    procedure CreateEditor(var AnEditor: TWinControl; Column: TEasyColumn); override;
    function GetEditorFont: TFont; override;
    function GetText: VAriant; override;
    procedure OnEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    procedure SetEditorFocus; override;
  end;

  TEasyListview = class(TCustomEasyListview)
  private
    function GetPaintInfoColumn: TEasyPaintInfoColumn; reintroduce; virtual;
    function GetPaintInfoGroup: TEasyPaintInfoGroup; reintroduce; virtual;
    function GetPaintInfoItem: TEasyPaintInfoItem; reintroduce; virtual;
    procedure SetPaintInfoColumn(const Value: TEasyPaintInfoColumn); reintroduce; virtual;
    procedure SetPaintInfoGroup(const Value: TEasyPaintInfoGroup); reintroduce; virtual;
    procedure SetPaintInfoItem(const Value: TEasyPaintInfoItem); reintroduce; virtual;
  public
    property CheckManager;
    property GlobalImages;
    property Items;
    property States;
  published
    property Align;
    property Anchors;
    property BackGround;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BiDiMode;
    property BorderWidth;
    property CacheDoubleBufferBits;
    property CellSizes;
    property Color;
    property Constraints;
    property Ctl3D;
    property DisabledBlendAlpha;
    property DisabledBlendColor;
    property EditManager;
    property OnClipboardCopy;
    property OnClipboardCut;
    property OnClipboardPaste;
    property OnColumnLoadFromStream;
    property OnColumnSaveToStream;
    property OnCustomColumnView;
    property OnCustomGrid;
    property OnCustomView;
    property OnGroupLoadFromStream;
    property OnGroupSaveToStream;
    property OnPaintHeaderBkGnd;
    property UseDockManager default True;
    property DragKind;
    property DragManager;
    property Font;
    property GroupCollapseButton;
    property GroupExpandButton;
    property GroupFont;
    property Groups;
    property HintType;
    property Header;
    property HotTrack;
    property IncrementalSearch;
    property ImagesGroup;
    property ImagesSmall;
    property ImagesLarge;
    property ImagesExLarge;
    property PaintInfoColumn: TEasyPaintInfoColumn read GetPaintInfoColumn write SetPaintInfoColumn;
    property PaintInfoGroup: TEasyPaintInfoGroup read GetPaintInfoGroup write SetPaintInfoGroup;
    property PaintInfoItem: TEasyPaintInfoItem read GetPaintInfoItem write SetPaintInfoItem;
    property ParentBiDiMode;
    {$IFDEF COMPILER_7_UP}property ParentBackground;{$ENDIF}
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property PopupMenuHeader;
    property Scrollbars;
    property ShowGroupMargins;
    property ShowThemedBorder;
    property ShowHint;
    property Selection;
    property Sort;
    property TabOrder;
    property TabStop;
    property Themed;
    property View;
    property Visible;
    property WheelMouseDefaultScroll;
    property WheelMouseScrollModifierEnabled;

    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    {$IFDEF COMPILER_5_UP}
    property OnContextPopup;
    {$ENDIF}
    property OnAutoGroupGetKey;
    property OnAutoSortGroupCreate;
    property OnColumnCheckChanged;
    property OnColumnCheckChanging;
    property OnColumnClick;
    property OnColumnContextMenu;
    property OnColumnDblClick;
    property OnColumnEnableChanged;
    property OnColumnEnableChanging;
    property OnColumnFreeing;
    property OnColumnGetCaption;
    property OnColumnGetImageIndex;
    property OnColumnGetImageList;
    property OnColumnGetDetail;
    property OnColumnGetDetailCount;
    property OnColumnImageDraw;
    property OnColumnImageGetSize;
    property OnColumnImageDrawIsCustom;
    property OnColumnInitialize;
    property OnColumnPaintText;
    property OnColumnSelectionChanged;
    property OnColumnSelectionChanging;
    property OnColumnSetCaption;
    property OnColumnSetImageIndex;
    property OnColumnSetDetail;
    property OnColumnSizeChanged;
    property OnColumnSizeChanging;
    property OnColumnVisibilityChanged;
    property OnColumnVisibilityChanging;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDockDrop;
    property OnDockOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEndUpdate;
    property OnEnter;
    property OnExit;
    property OnGetDragImage;
    property OnGetSiteInfo;
    property OnGroupClick;
    property OnGroupCollapse;
    property OnGroupCollapsing;
    property OnGroupCompare;
    property OnGroupContextMenu;
    property OnGroupDblClick;
    property OnGroupExpand;
    property OnGroupExpanding;
    property OnGroupFreeing;
    property OnGroupGetCaption;
    property OnGroupGetImageIndex;
    property OnGroupGetImageList;
    property OnGroupGetDetail;
    property OnGroupGetDetailCount;
    property OnGroupImageDraw;
    property OnGroupImageGetSize;
    property OnGroupImageDrawIsCustom;
    property OnGroupInitialize;
    property OnGroupPaintText;
    property OnGroupHotTrack;
    property OnGroupSetCaption;
    property OnGroupSetImageIndex;
    property OnGroupSetDetail;
    property OnGroupVisibilityChanged;
    property OnGroupVisibilityChanging;
    property OnHeaderDblClick;
    property OnHeaderMouseDown;
    property OnHeaderMouseMove;
    property OnHeaderMouseUp;
    property OnHintCustomInfo;
    property OnHintCustomDraw;
    property OnHintPauseTime;
    property OnHintPopup;
    property OnIncrementalSearch;
    property OnItemCheckChange;
    property OnItemCheckChanging;
    property OnItemClick;
    property OnItemCompare;
    property OnItemContextMenu;
    property OnItemCreateEditor;
    property OnItemDblClick;
    property OnItemEditBegin;
    property OnItemEdited;
    property OnItemEditEnd;
    property OnItemEnableChange;
    property OnItemEnableChanging;
    property OnItemFreeing;
    property OnItemFocusChanged;
    property OnItemFocusChanging;
    property OnItemGetCaption;
    property OnItemGetEditCaption;
    property OnItemGetGroupKey;
    property OnItemGetImageIndex;
    property OnItemGetImageList;
    property OnItemGetTileDetail;
    property OnItemGetTileDetailCount;
    property OnItemHotTrack;
    property OnItemImageDraw;
    property OnItemImageGetSize;
    property OnItemImageDrawIsCustom;
    property OnItemInitialize;
    property OnItemLoadFromStream;
    property OnItemMouseDown;
    property OnItemMouseUp;
    property OnItemPaintText;
    property OnItemSaveToStream;
    property OnItemSelectionChanged;
    property OnItemSelectionChanging;
    property OnItemSelectionsChanged;
    property OnItemSetCaption;
    property OnItemSetGroupKey;
    property OnItemSetImageIndex;
    property OnItemSetTileDetail;
    property OnItemThumbnailDraw;
    property OnItemVisibilityChanged;
    property OnItemVisibilityChanging;
    property OnKeyAction;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnOLEDragEnd;
    property OnOLEDragStart;
    property OnOLEDragEnter;
    property OnOLEDragOver;
    property OnOLEDragLeave;
    property OnOLEDragDrop;
    property OnOLEGetCustomFormats;
    property OnOLEGetData;
    property OnOLEGetDataObject;
    property OnOLEQueryContineDrag;
    property OnOLEGiveFeedback;
    property OnOLEQueryData;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
    property OnViewChange;
  end;

  TEasyTaskBand = class(TCustomEasyListview)
  private
    function GetPaintInfoColumn: TEasyPaintInfoTaskBandColumn; reintroduce; virtual;
    function GetPaintInfoGroup: TEasyPaintInfoTaskbandGroup; reintroduce; virtual;
    function GetPaintInfoItem: TEasyPaintInfoTaskBandItem; reintroduce; virtual;
    procedure SetPaintInfoColumn(const Value: TEasyPaintInfoTaskBandColumn); reintroduce; virtual;
    procedure SetPaintInfoGroup(const Value: TEasyPaintInfoTaskbandGroup); reintroduce; virtual;
    procedure SetPaintInfoItem(const Value: TEasyPaintInfoTaskBandItem); reintroduce; virtual;
  protected
    function CreateColumnPaintInfo: TEasyPaintInfoBaseColumn; override;
    function CreateGroupPaintInfo: TEasyPaintInfoBaseGroup; override;
    function CreateItemPaintInfo: TEasyPaintInfoBaseItem; override;
    function GroupTestExpand(HitInfo: TEasyGroupHitTestInfoSet): Boolean; override;
    property PaintInfoColumn: TEasyPaintInfoTaskBandColumn read GetPaintInfoColumn write SetPaintInfoColumn;
  public
    constructor Create(AOwner: TComponent); override;
    property GlobalImages;
    property Items;
    property States;
    property Scrollbars;
  published
    property Align;
    property Anchors;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BiDiMode;
    property BorderWidth;
    property CellSizes;
    property Color;
    property Constraints;
    property Ctl3D;
    property EditManager;
    property UseDockManager default True;
    property DragKind;
    property DragManager;
    property Font;
    property GroupFont;
    property Groups;
    property HintType;
    property HotTrack;
    property IncrementalSearch;
    property ImagesGroup;
    property ImagesSmall;
    property PaintInfoGroup: TEasyPaintInfoTaskbandGroup read GetPaintInfoGroup write SetPaintInfoGroup;
    property PaintInfoItem: TEasyPaintInfoTaskBandItem read GetPaintInfoItem write SetPaintInfoItem;
    property ParentBiDiMode;
    {$IFDEF COMPILER_7_UP}property ParentBackground;{$ENDIF}
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property PopupMenuHeader;
    property ShowGroupMargins;
    property ShowThemedBorder;
    property ShowHint;
    property Selection;
    property Sort;
    property TabOrder;
    property TabStop;
    property Themed;
    property Visible;
    property WheelMouseDefaultScroll;
    property WheelMouseScrollModifierEnabled;

    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    {$IFDEF COMPILER_5_UP}
    property OnContextPopup;
    {$ENDIF}
    property OnAutoSortGroupCreate;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDockDrop;
    property OnDockOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEndUpdate;
    property OnEnter;
    property OnExit;
    property OnGetDragImage;
    property OnGetSiteInfo;
    property OnGroupClick;
    property OnGroupCollapse;
    property OnGroupCollapsing;
    property OnGroupCompare;
    property OnGroupContextMenu;
    property OnGroupDblClick;
    property OnGroupExpand;
    property OnGroupExpanding;
    property OnGroupFreeing;
    property OnGroupGetCaption;
    property OnGroupGetImageIndex;
    property OnGroupGetImageList;
    property OnGroupImageDraw;
    property OnGroupImageGetSize;
    property OnGroupImageDrawIsCustom;
    property OnGroupInitialize;
    property OnGroupPaintText;
    property OnGroupHotTrack;
    property OnGroupSetCaption;
    property OnGroupSetImageIndex;
    property OnGroupSetDetail;
    property OnGroupVisibilityChanged;
    property OnGroupVisibilityChanging;
    property OnHeaderDblClick;
    property OnHeaderMouseDown;
    property OnHeaderMouseMove;
    property OnHeaderMouseUp;
    property OnHintCustomInfo;
    property OnHintCustomDraw;
    property OnHintPauseTime;
    property OnHintPopup;
    property OnIncrementalSearch;
    property OnItemCheckChange;
    property OnItemCheckChanging;
    property OnItemClick;
    property OnItemCompare;
    property OnItemContextMenu;
    property OnItemCreateEditor;
    property OnItemDblClick;
    property OnItemEditBegin;
    property OnItemEdited;
    property OnItemEditEnd;
    property OnItemEnableChange;
    property OnItemEnableChanging;
    property OnItemFreeing;
    property OnItemFocusChanged;
    property OnItemFocusChanging;
    property OnItemGetCaption;
    property OnItemGetGroupKey;
    property OnItemGetImageIndex;
    property OnItemGetImageList;
    property OnItemHotTrack;
    property OnItemImageDraw;
    property OnItemImageGetSize;
    property OnItemImageDrawIsCustom;
    property OnItemInitialize;
    property OnItemMouseDown;
    property OnItemPaintText;
    property OnItemSelectionChanged;
    property OnItemSelectionChanging;
    property OnItemSetCaption;
    property OnItemSetGroupKey;
    property OnItemSetImageIndex;
    property OnItemVisibilityChanged;
    property OnItemVisibilityChanging;
    property OnKeyAction;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnOLEDragEnd;
    property OnOLEDragStart;
    property OnOLEDragEnter;
    property OnOLEDragOver;
    property OnOLEDragLeave;
    property OnOLEDragDrop;
    property OnOLEGetCustomFormats;
    property OnOLEGetData;
    property OnOLEQueryContineDrag;
    property OnOLEGiveFeedback;
    property OnOLEQueryData;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

const
  EASYLISTSTYLETEXTS: array[TEasyListStyle] of string =
    ('Icon', 'Small Icon', 'List', 'Details', 'Thumbnail', 'Tile', 'FilmStrip', 'Grid');
  EASYSORTALGORITHMS: array[TEasySortAlgorithm] of string =
    ('QuickSort', 'BubbleSort', 'MergeSort');

  HEADERSUPPORTEDVIEWS = [elsReport, elsGrid];
  VERTICALVIEWS = [elsIcon, elsSmallIcon, elsReport, elsThumbnail, elsTile, elsGrid];
  THUMBNAILVIEWS = [elsThumbnail, elsFilmStrip];
  MULTILINEVIEWS = [elsIcon, elsThumbnail, elsFilmStrip, elsTile];

procedure FillStringsWithEasyListStyles(Strings: TStrings);
procedure FillStringsWithEasySortAlgorithms(Strings: TStrings);

var
  AlphaBlender: TEasyAlphaBlender;

implementation

const
  PERSISTENTOBJECTSTATES = [esosSelected, esosEnabled, esosVisible, esosChecked, esosBold]; // States that are stored to a stream for persistance
  H_STRINGEDITORMARGIN = 8;  // Margin for String Editors in the Horz direction
  V_STRINGEDITORMARGIN = 2;  // Margin for String Editors in the Vert direction

var
  HeaderClipboardFormat: TClipFormat;
  

type
  PHeaderClipData = ^THeaderClipData;
  THeaderClipData = record
    Thread: THandle;
    Listview: TCustomEasyListview;
    Column: TEasyColumn;
  end;

  // Very simple implementation for saving/loading the tree to disk with a Unicode
  // filename in NT. Use TnT Uniocode package for a full blown implementation
  TWideFileStream = class(THandleStream)
  public
    constructor Create(const FileName: WideString; Mode: Word);
    destructor Destroy; override;
  end;

  TWinControlCracker = class(TWinControl) end;

function HeaderClipFormat: TFormatEtc;
begin
  Result.cfFormat := HeaderClipboardFormat;
  Result.ptd := nil;
  Result.lindex := -1;
  Result.dwAspect := -1;
  Result.ptd := nil;
  Result.tymed := TYMED_HGLOBAL
end;

function DefaultSort(Column: TEasyColumn; Item1, Item2: TEasyCollectionItem): Integer;
var
  Index: Integer;
begin
  if not Assigned(Column) then
    Index := 0
  else
    Index := Column.Position;

  Result := WideStrIComp(PWideChar(Item1.Captions[Index]), PWideChar( Item2.Captions[Index]));


  if Assigned(Column) and (Column.SortDirection = esdDescending) then
    Result := -Result
end;

procedure FillStringsWithEasyListStyles(Strings: TStrings);
var
  ListStyle: TEasyListStyle;
begin
  Strings.Clear;
  for ListStyle := low(TEasyListStyle) to high(TEasyListStyle) do
    Strings.Add(EASYLISTSTYLETEXTS[ListStyle]);
end;

procedure FillStringsWithEasySortAlgorithms(Strings: TStrings);
var
  ListStyle: TEasySortAlgorithm;
begin
  Strings.Clear;
  for ListStyle := low(TEasySortAlgorithm) to high(TEasySortAlgorithm) do
    Strings.Add(EASYSORTALGORITHMS[ListStyle]);
end;

function WideFileCreate(const FileName: WideString): Integer;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Result := Integer(CreateFileW(PWideChar(FileName), GENERIC_READ or GENERIC_WRITE, 0,
      nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0))
  else
    Result := Integer(CreateFileA(PAnsiChar(AnsiString(PWideChar(FileName))), GENERIC_READ or GENERIC_WRITE, 0,
      nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0));
end;

function WideFileOpen(const FileName: WideString; Mode: LongWord): Integer;
const
  AccessMode: array[0..2] of LongWord = (
    GENERIC_READ,
    GENERIC_WRITE,
    GENERIC_READ or GENERIC_WRITE);
  ShareMode: array[0..4] of LongWord = (
    0,
    0,
    FILE_SHARE_READ,
    FILE_SHARE_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE);
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Result := Integer(CreateFileW(PWideChar(FileName), AccessMode[Mode and 3], ShareMode[(Mode and $F0) shr 4],
      nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0))
  else
    Result := Integer(CreateFileA(PAnsiChar(AnsiString(FileName)), AccessMode[Mode and 3], ShareMode[(Mode and $F0) shr 4],
      nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0));
end;

{ TWideFileStream }

constructor TWideFileStream.Create(const FileName: WideString; Mode: Word);
var
  CreateHandle: Integer;
begin
  if Mode = fmCreate then
  begin
    CreateHandle := WideFileCreate(FileName);
    if CreateHandle < 0 then
     {$IFNDEF COMPILER_5_UP}
      raise EFCreateError.Create('Can not create file: ' + FileName);
     {$ELSE}
     raise EFCreateError.CreateResFmt(PResStringRec(@SFCreateError), [FileName]);
     {$ENDIF COMPILER_5_UP}
  end else
  begin
    CreateHandle := WideFileOpen(FileName, Mode);
    if CreateHandle < 0 then
     {$IFNDEF COMPILER_5_UP}
      raise EFCreateError.Create('Can not create file: ' + FileName);
     {$ELSE}
     raise EFCreateError.CreateResFmt(PResStringRec(@SFCreateError), [FileName]);
     {$ENDIF COMPILER_5_UP}
  end;
  inherited Create(CreateHandle);
end;

destructor TWideFileStream.Destroy;
begin
  if Handle >= 0 then FileClose(Handle);
  inherited Destroy;
end;

{ TEasyGroupItemOwnedPersistent }

constructor TEasyOwnedPersistentGroupItem.Create(AnOwner: TEasyGroup);
begin
  inherited Create(AnOwner.OwnerListview);
  FOwnerGroup := AnOwner
end;

{ TEasyOwnedPersistent}
constructor TEasyOwnedPersistent.Create(AnOwner: TCustomEasyListview);
begin
  inherited Create;
  FOwnerListview := AnOwner;
end;

function TEasyOwnedPersistent.GetOwner: TPersistent;
begin
  Result := FOwnerListview;
end;

procedure TEasyOwnedPersistent.LoadFromStream(S: TStream);
begin

end;

procedure TEasyOwnedPersistent.SaveToStream(S: TStream);
begin

end;

{ TEasyInterfacedPersistent }

function TEasyInterfacedPersistent.GetObj: TObject;
begin
  Result := Self
end;

function TEasyInterfacedPersistent._AddRef: Integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function TEasyInterfacedPersistent._Release: Integer;
begin
  Result := InterlockedDecrement(FRefCount);
  if (Result = 0) then
    Destroy;
end;

function TEasyInterfacedPersistent.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE
end;

procedure TEasyInterfacedPersistent.AfterConstruction;
begin
  // Release the constructor's implicit refcount
  InterlockedDecrement(FRefCount);
end;

procedure TEasyInterfacedPersistent.BeforeDestruction;
begin

end;

class function TEasyInterfacedPersistent.NewInstance: TObject;
begin
  // Set an implicit refcount so that refcounting
  // during construction won't destroy the object.
  Result := inherited NewInstance;
  TEasyInterfacedPersistent(Result).FRefCount := 1;
end;

{ TEasyOwnedInterfacedPersistent }

constructor TEasyOwnedInterfacedPersistent.Create(AnOwner: TCustomEasyListview);
begin
  inherited Create;
  FOwner := AnOwner;
end;

{ TEasyMargins }

constructor TEasyMargin.Create(AnOwner: TCustomEasyListview);
begin
  inherited;
  FSize := 30;
end;

destructor TEasyMargin.Destroy;
begin
  inherited Destroy;
end;

function TEasyMargin.RuntimeSize: Integer;
begin
  if not Visible or not FOwnerListview.ShowGroupMargins then
    Result := 0
  else
    Result := FSize
end;

procedure TEasyMargin.Assign(Source: TPersistent);
var
  Temp: TEasyMargin;
begin
  if Source is TEasyMargin then
  begin
    Temp := TEasyMargin(Source);
    FSize := Temp.Size;
    FVisible := Temp.Visible
  end
end;

procedure TEasyMargin.SetSize(Value: Integer);
begin
  if Value <> FSize then
  begin
    if Value < 0 then
      FSize := 0
    else
      FSize := Value;
    OwnerListview.Groups.Rebuild
  end
end;

procedure TEasyMargin.SetVisible(Value: Boolean);
begin
  if Value <> FVisible then
  begin
    FVisible := Value;
    OwnerListview.Groups.Rebuild
  end
end;

{ TEasyHeaderMargin }

constructor TEasyHeaderMargin.Create(AnOwner: TCustomEasyListview);
begin
  inherited Create(AnOwner);
  FVisible := True;
end;

function TEasyItems.Add(Data: TObject = nil): TEasyItem;
begin
  Result := TEasyItem( inherited Add(Data))
end;

function TEasyItems.AddCustom(CustomItem: TEasyItemClass; Data: TObject = nil): TEasyItem;
begin
  Result := nil;
  if Assigned(CustomItem) then
  begin
    Result := CustomItem.Create(Self);
    FList.Add(Result);
    ReIndexItems;
    DoItemAdd(Result, FList.Count - 1);
    Result.Data := Data;
    DoStructureChange
  end
end;

function TEasyItems.AddInterfaced(const DataInf: IUnknown; Data: TObject = nil): TEasyItemInterfaced;
begin
  Result := nil;
  if Assigned(DataInf) then
  begin
    Result := TEasyItemInterfaced.Create(Self);
    FList.Add(Result);
    ReIndexItems;
    DoItemAdd(Result, FList.Count - 1);
    Result.DataInf := DataInf;
    Result.Data := Data;
    DoStructureChange
  end
end;

function TEasyItems.AddVirtual(Data: TObject = nil): TEasyItemVirtual;
begin
  Result := TEasyItemVirtual.Create(Self);
  FList.Add(Result);
  ReIndexItems;
  DoItemAdd(Result, FList.Count - 1);
  Result.Data := Data;
  DoStructureChange
end;

constructor TEasyItems.Create(AnOwner: TCustomEasyListview; AnOwnerGroup: TEasyGroup);
begin
  inherited Create(AnOwner);
  FOwnerGroup := AnOwnerGroup;
  FItemClass := TEasyItemStored;
end;

function TEasyItems.InsertCustom(Index: Integer; CustomItem: TEasyItemClass; Data: TObject = nil): TEasyItem;
begin
  Result := CustomItem.Create(Self);
  FList.Insert(Index, Result);
  ReIndexItems;
  DoItemAdd(Result, Index);
  Result.Data := Data;
  DoStructureChange
end;

function TEasyItems.InsertInterfaced(Index: Integer; const DataInf: IUnknown; Data: TObject = nil): TEasyItemInterfaced;
begin
  Result := nil;
  if Assigned(DataInf) then
  begin
    Result := TEasyItemInterfaced.Create(Self);
    FList.Insert(Index, Result);
    ReIndexItems;
    DoItemAdd(Result, Index);
    Result.DataInf := DataInf;
    Result.Data := Data;
    DoStructureChange
  end
end;

function TEasyItems.InsertVirtual(Index: Integer; Data: TObject = nil): TEasyItemVirtual;
begin
  Result := TEasyItemVirtual.Create(Self);
  FList.Insert(Index, Result);
  ReIndexItems;
  DoItemAdd(Result, Index);
  Result.Data := Data;
  DoStructureChange
end;

procedure TEasyItems.Clear(FreeItems: Boolean = True);
begin
  OwnerListview.Selection.IncMultiChangeCount;
  OwnerListview.Selection.GroupSelectBeginUpdate;
  inherited Clear(FreeItems);
  OwnerListview.Selection.GroupSelectEndUpdate;
  OwnerListview.Selection.DecMultiChangeCount;
end;

procedure TEasyItems.Delete(Index: Integer);
begin
  inherited;
end;

destructor TEasyItems.Destroy;
begin
  inherited;
end;

procedure TEasyItems.DoStructureChange;
begin
  OwnerListview.IncrementalSearch.ResetSearch;
  OwnerListview.Groups.Rebuild(False);
  if OwnerListview.Sort.AutoSort then
    OwnerListview.Sort.SortAll;
end;

procedure TEasyItems.Exchange(Index1, Index2: Integer);
begin
  inherited;
end;

function TEasyItems.GetItem(Index: Integer): TEasyItem;
begin
  // This is a bottle neck for large data sets.  Do this direct instead of inherited
  Result := ( FList.List[Index])
end;

function TEasyItems.Insert(Index: Integer; Data: TObject = nil): TEasyItem;
begin
  Result := TEasyItem( inherited Insert(Index));
end;

procedure TEasyItems.SetItem(Index: Integer; Value: TEasyItem);
begin
  inherited Items[Index] := Value
end;

{ TEasyGlobalItems}

function TEasyGlobalItems.Add(Data: TObject = nil): TEasyItem;
begin
  EnsureFirstGroup;
  Result := TEasyItem(GetLastGroup.Items.Add(Data));
end;

function TEasyGlobalItems.AddCustom(CustomItem: TEasyItemClass; Data: TObject = nil): TEasyItem;
begin
  EnsureFirstGroup;
  Result := GetLastGroup.Items.AddCustom(CustomItem, Data);
end;

function TEasyGlobalItems.AddInterfaced(const DataInf: IUnknown; Data: TObject = nil): TEasyItemInterfaced;
begin
  EnsureFirstGroup;
  Result := GetLastGroup.Items.AddInterfaced(DataInf, Data);
end;

function TEasyGlobalItems.AddVirtual(Data: TObject = nil): TEasyItemVirtual;
begin
  EnsureFirstGroup;
  Result := GetLastGroup.Items.AddVirtual(Data);
end;

procedure TEasyGlobalItems.Clear;
begin
  FOwner.Groups.Clear;
end;

constructor TEasyGlobalItems.Create(AnOwner: TCustomEasyListview);
begin
  inherited Create;
  FOwner := AnOwner;
end;

procedure TEasyGlobalItems.Delete(Index: Integer; ReIndex: Boolean = True);
var
  Item: TEasyItem;
begin
//  OwnerListview.Groups.Delete(Index);
  Item := Items[Index];
  Item.OwnerGroup.Items.Delete(Item.Index);
//  OwnerListview.Groups.ReIndexItems(nil, ReIndex);
end;

procedure TEasyGlobalItems.EnsureFirstGroup;
begin
  if FOwner.Groups.Count = 0 then
    FOwner.Groups.Add.Caption := DEFAULT_GROUP_NAME;
end;

procedure TEasyGlobalItems.Exchange(Index1, Index2: Integer);
var
  Item1, Item2: TEasyItem;
begin
  Item1 := Items[Index1];
  Item2 := Items[Index2];
  if Item1.OwnerItems = Item2.OwnerItems then
    Item1.OwnerItems.Exchange(Item1.Index, Item2.Index)
  else
    raise Exception.Create('exchange of items between different groups is not yet supported'); // TODO
end;

function TEasyGlobalItems.GetCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := FOwner.Groups.Count - 1 downto 0 do
    Inc(Result, FOwner.Groups[i].Items.Count);
end;

function TEasyGlobalItems.GetItem(Index: Integer): TEasyItem;
begin
  Result := GetItemInternal(Index);
  if Result = nil then // index too big
    IndexError(Index);
end;

function TEasyGlobalItems.GetItemInternal(Index: Integer): TEasyItem;
var
  i: Integer;
  ItemCount: Integer;
begin
  // GetItemInternal translates an absolute index into an item. It simply
  // returns nil if the index is too big but raises an exception for negative
  // indexes.
  if Index < 0 then
    IndexError(Index);

  Result := nil;
  for i := 0 to FOwner.Groups.Count - 1 do
  begin
    ItemCount := FOwner.Groups[i].Items.Count;
    if Index < ItemCount then
    begin
      Result := FOwner.Groups[i].Items[Index];
      break;
    end;
    Dec(Index, ItemCount);
  end;
end;

function TEasyGlobalItems.GetLastGroup: TEasyGroup;
begin
  if FOwner.Groups.Count > 0 then
    Result := FOwner.Groups[FOwner.Groups.Count - 1]
  else
    Result := nil;
end;

procedure TEasyGlobalItems.IndexError(Index: Integer);
begin
  {$IFDEF COMPILER_5_UP}
  TList.Error(SListIndexError, Index);
  {$ELSE}
  TList.Error('List index out of bounds (%d)', Index);
  {$ENDIF}
end;

function TEasyGlobalItems.IndexOf(Item: TEasyItem): Integer;
var
  GroupIndex: Integer;
begin
  Result := Item.Index;
  for GroupIndex := Item.OwnerGroup.Index - 1 downto 0 do
    Inc(Result, OwnerListview.Groups[GroupIndex].Items.Count);
end;

function TEasyGlobalItems.Insert(Index: Integer; Data: TObject = nil): TEasyItem;
var
  Item: TEasyItem;
begin
  Item := GetItemInternal(Index);
  if Item = nil then
    Result := Add
  else
    Result := Item.OwnerItems.Insert(Item.Index, Data);
end;

function TEasyGlobalItems.InsertCustom(Index: Integer; CustomItem: TEasyItemClass; Data: TObject = nil): TEasyItem;
var
  Item: TEasyItem;
begin
  Item := GetItemInternal(Index);
  if Item = nil then
    Result := AddCustom(CustomItem, Data)
  else
    Result := Item.OwnerItems.InsertCustom(Item.Index, CustomItem, Data);
end;

function TEasyGlobalItems.InsertInterfaced(Index: Integer; const DataInf: IUnknown; Data: TObject = nil): TEasyItemInterfaced;
var
  Item: TEasyItem;
begin
  Item := GetItemInternal(Index);
  if Item = nil then
    Result := AddInterfaced(DataInf, Data)
  else
    Result := Item.OwnerItems.InsertInterfaced(Item.Index, DataInf, Data);
end;

function TEasyGlobalItems.InsertVirtual(Index: Integer; Data: TObject = nil): TEasyItemVirtual;
var
  Item: TEasyItem;
begin
  Item := GetItemInternal(Index);
  if Item = nil then
    Result := AddVirtual
  else
    Result := Item.OwnerItems.InsertVirtual(Item.Index, Data);
end;

procedure TEasyGlobalItems.SetItem(Index: Integer; const Value: TEasyItem);
var
  Item: TEasyItem;
begin
  Item := Items[Index];
  Item.OwnerItems[Item.Index] := Value;
end;

procedure TEasyGlobalItems.SetReIndexDisable(const Value: Boolean);
begin
  EnsureFirstGroup;
  FOwner.Groups.ReIndexDisable := Value;
end;

{ TEasyGroups }

constructor TEasyGroups.Create(AnOwner: TCustomEasyListview);
begin
  inherited Create(AnOwner);
  FDefaultItemView := TEasyViewIconItem;
  FDefaultGroupview := TEasyViewGroup;
  FDefaultGrid := TEasyGridIconGroup;
  FItemClass := TEasyGroupStored;
  FStreamGroups := True
end;

destructor TEasyGroups.Destroy;
begin
  inherited Destroy;
end;

function TEasyGroups.Add(Data: TObject = nil): TEasyGroup;
begin
  Result := TEasyGroup( inherited Add(Data));
end;

function TEasyGroups.AddCustom(CustomGroup: TEasyGroupClass; Data: TObject = nil): TEasyGroup;
begin
  Result := nil;
  if Assigned(CustomGroup) then
  begin
    Result := CustomGroup.Create(Self);
    FList.Add(Result);
    ReIndexItems;
    Result.Data := Data;
    DoItemAdd(Result, FList.Count - 1);
    DoStructureChange
  end
end;

function TEasyGroups.AddInterfaced(const DataInf: IUnknown; Data: TObject = nil): TEasyGroupInterfaced;
begin
  Result := nil;
  if Assigned(DataInf) then
  begin
    Result := TEasyGroupInterfaced.Create(Self);
    FList.Add(Result);
    ReIndexItems;
    Result.DataInf := DataInf;
    Result.Data := Data;
    DoItemAdd(Result, FList.Count - 1);
    DoStructureChange
  end
end;

function TEasyGroups.AddVirtual(Data: TObject = nil): TEasyGroupVirtual;
begin
  Result := TEasyGroupVirtual.Create(Self);
  FList.Add(Result);
  ReIndexItems;
  Result.Data := Data;
  DoItemAdd(Result, FList.Count - 1);
  DoStructureChange
end;

function TEasyGroups.AdjacentItem(Item: TEasyItem;
  Direction: TEasyAdjacentCellDir): TEasyItem;
begin
  Result := nil;
  if Assigned(Item) then
    Result := Item.OwnerGroup.Grid.AdjacentItem(Item, Direction);
end;

function TEasyGroups.FirstGroup: TEasyGroup;
begin
  Result := FirstGroupInternal(False)
end;

function TEasyGroups.FirstGroupInRect(ViewportRect: TRect): TEasyGroup;
//
//  Find the first group in the passed rectangle.  It implicitly assumes
// Visible Groups
//
var
  i: Integer;
  R: TRect;
begin
  Result := nil;
  i := 0;
  while (i < Count) and not Assigned(Result) do
  begin
    if Groups[i].Visible then
      if IntersectRect(R, Groups[i].DisplayRect, ViewportRect) then
        Result := Groups[i];
    Inc(i)
  end
end;

function TEasyGroups.FirstGroupInternal(VisibleOnly: Boolean): TEasyGroup;
var
  GroupIndex: Integer;
begin
  Result := nil;
  GroupIndex := 0;
  if Count > 0 then
  begin
    while not Assigned(Result) and (GroupIndex < Count) do
    begin
      if VisibleOnly then
      begin
        if Groups[GroupIndex].Visible then
          Result := Groups[GroupIndex]
      end else
        Result := Groups[GroupIndex];
      Inc(GroupIndex)
    end;
  end
end;

function TEasyGroups.FirstInGroup(Group: TEasyGroup): TEasyItem;
begin
  Result := FirstInGroupInternal(Group, False)
end;

function TEasyGroups.FirstInGroupInternal(Group: TEasyGroup; VisibleOnly: Boolean): TEasyItem;
var
  ItemIndex: Integer;
begin
  Result := nil;
  ItemIndex := 0;
  if Assigned(Group) then
  begin
    if Assigned(Group.Items) then
    begin
      if Group.Items.Count > 0 then
      begin
        if VisibleOnly then
        begin
          while not Assigned(Result) and (ItemIndex < Group.Items.Count) do
          begin
            if Group.Items[ItemIndex].Visible then
              Result := Group.Items[ItemIndex];
            Inc(ItemIndex)
          end
        end else
          Result := Group.Items[ItemIndex]
      end
    end
  end
end;

function TEasyGroups.FirstInitializedItem: TEasyItem;
begin
  Result := FirstItemInternal(enitInitialized)
end;

function TEasyGroups.FirstItem: TEasyItem;
begin
  Result := FirstItemInternal(enitAny)
end;

function TEasyGroups.FirstItemInRect(ViewportRect: TRect): TEasyItem;
//
//  Find the first Item in the passed rectangle.  It implicitly assumes
// Visible Items
//
var
  Group: TEasyGroup;
  i: Integer;
  R, FullDisplayRect: TRect;
begin
  Result := nil;
  i := 0;

  if OwnerListview.View = elsReport then
  begin
    Group := FirstGroupInRect(ViewportRect);
    while not Assigned(Result) and Assigned(Group) do
    begin
      if (Group.Items.Count > 0) and Group.Expanded then
      begin
        while not Assigned(Result) and (i < Group.Items.Count) do
        begin
          FullDisplayRect := OwnerListview.Header.ViewRect;
          FullDisplayRect.Top := Group.Items[i].DisplayRect.Top;
          FullDisplayRect.Bottom := Group.Items[i].DisplayRect.Bottom;

          if  Group.Items[i].Visible and IntersectRect(R, FullDisplayRect, ViewportRect) then
            Result := Group.Items[i]
          else
            Inc(i)
        end
      end;
      i := 0;
      Group := NextGroupInRect(Group, ViewportRect);
    end
  end else
  begin
    Group := FirstGroupInRect(ViewportRect);
    while not Assigned(Result) and Assigned(Group) do
    begin
      if (Group.Items.Count > 0) and Group.Expanded then
      begin
        while not Assigned(Result) and (i < Group.Items.Count) do
        begin
          if  Group.Items[i].Visible and IntersectRect(R, Group.Items[i].DisplayRect, ViewportRect) then
            Result := Group.Items[i]
          else
            Inc(i)
        end
      end;
      i := 0;
      Group := NextGroupInRect(Group, ViewportRect);
    end
  end
end;

function TEasyGroups.FirstItemInternal(NextItemType: TEasyNextItemType): TEasyItem;
var
  GroupIndex, ItemIndex: Integer;
begin
  Result := nil;
  GroupIndex := 0;
  ItemIndex := 0;
  if Count > 0 then
  begin
  while not Assigned(Result) and (GroupIndex < Count) do
    begin
      if Assigned(Groups[GroupIndex].Items) then
      begin
        if Groups[GroupIndex].Items.Count > 0 then
        begin
          case NextItemType of
            enitVisible:
              begin
                while not Assigned(Result) and (ItemIndex < Groups[GroupIndex].Items.Count) do
                begin
                  if Groups[GroupIndex].Items[ItemIndex].Visible then
                    Result := Groups[GroupIndex].Items[ItemIndex];
                  Inc(ItemIndex)
                end
              end;
            enitInitialized:
              begin
                while not Assigned(Result) and (ItemIndex < Groups[GroupIndex].Items.Count) do
                begin
                  if Groups[GroupIndex].Items[ItemIndex].Initialized then
                    Result := Groups[GroupIndex].Items[ItemIndex];
                  Inc(ItemIndex)
                end
              end;
          else
            Result := Groups[GroupIndex].Items[0];
          end
        end;
      end;
      Inc(GroupIndex)
    end
  end
end;

function TEasyGroups.FirstVisibleGroup: TEasyGroup;
begin
  Result := FirstGroupInternal(True)
end;

function TEasyGroups.FirstVisibleInGroup(Group: TEasyGroup): TEasyItem;
begin
  Result := FirstInGroupInternal(Group, True)
end;

function TEasyGroups.FirstVisibleItem: TEasyItem;
begin
  Result := FirstItemInternal(enitVisible)
end;

function TEasyGroups.GetCellHeight: Integer;
begin
  if Count > 0 then
    Result := Groups[0].Grid.CellSize.Height
  else
    Result := 0
end;

function TEasyGroups.GetCellWidth: Integer;
begin
  if Count > 0 then
    Result := Groups[0].Grid.CellSize.Width
  else
    Result := 0
end;

function TEasyGroups.GetGroup(Index: Integer): TEasyGroup;
begin
  // Bottleneck, no inherited call
  Result :=  TEasyGroup( FList.List[Index])
end;

function TEasyGroups.GetItemCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FList.Count - 1 do
    Result := Result + TEasyGroup(FList[i]).ItemCount
end;

function TEasyGroups.GetViewRect: TRect;
begin
  Result := Rect(0, 0, 0, 0);
  if LastVisibleGroup <> nil then
    Result.BottomRight := LastVisibleGroup.DisplayRect.BottomRight;
end;

function TEasyGroups.GetVisibleGroup(Index: Integer): TEasyGroup;
begin
  Result := nil;
  if (Index > -1) and (Index < VisibleCount) then
    Result := TEasyGroup( VisibleList[Index])
end;

function TEasyGroups.GroupByPoint(ViewportPoint: TPoint): TEasyGroup;
var
  i: Integer;
begin
  Result := nil;
  i := 0;
  while (i < Count) and not Assigned(Result) do
  begin
    if Groups[i].Visible and Groups[i].Enabled then
      if PtInRect(Groups[i].DisplayRect, ViewportPoint) then
        Result := Groups[i];
    Inc(i)
  end
end;

function TEasyGroups.Insert(Index: Integer; Data: TObject = nil): TEasyGroup;
begin
  Result := TEasyGroup( inherited Insert(Index, Data))
end;

function TEasyGroups.InsertCustom(Index: Integer; CustomGroup: TEasyGroupClass; Data: TObject = nil): TEasyGroup;
begin
  Result := nil;
  if Assigned(CustomGroup) then
  begin
    Result := CustomGroup.Create(Self);
    FList.Insert(Index, Result);
    ReIndexItems;
    DoItemAdd(Result, Index);
    Result.Data := Data;
    DoStructureChange
  end
end;

function TEasyGroups.InsertInterfaced(Index: Integer; const DataInf: IUnknown; Data: TObject): TEasyGroupInterfaced;
begin
  Result := nil;
  if Assigned(Data) then
  begin
    Result := TEasyGroupInterfaced.Create(Self);
    FList.Insert(Index, Result);
    ReIndexItems;
    DoItemAdd(Result, Index);
    Result.DataInf := DataInf;
    Result.Data := Data;
    DoStructureChange
  end
end;

function TEasyGroups.InsertVirtual(Index: Integer; Data: TObject = nil): TEasyGroupVirtual;
begin
  Result := TEasyGroupVirtual.Create(Self);
  FList.Insert(Index, Result);
  ReIndexItems;
  DoItemAdd(Result, Index);
  Result.Data := Data;
  DoStructureChange
end;

function TEasyGroups.ItemByPoint(ViewportPoint: TPoint): TEasyItem;
var
  i: Integer;
  Group: TEasyGroup;
begin
  Result := nil;
  Group := nil;
  i := 0;           
  while not Assigned(Group) and (i < Count) do
  begin
    if PtInRect(Groups[i].DisplayRect, ViewportPoint) then
      Group := Groups[i];
    Inc(i)
  end;
  if Assigned(Group) then
    Result := Group.ItemByPoint(ViewportPoint)
end;

function TEasyGroups.LastGroup: TEasyGroup;
begin
  Result := LastGroupInternal(False)
end;

function TEasyGroups.LastGroupInternal(VisibleOnly: Boolean): TEasyGroup;
var
  GroupIndex: Integer;
begin
  Result := nil;
  if Count > 0 then
  begin
    if VisibleOnly then
    begin
      GroupIndex := Count - 1;
      while not Assigned(Result) and (GroupIndex > -1) do
      begin
        if Groups[GroupIndex].Visible then
          Result := Groups[GroupIndex]
        else
          Dec(GroupIndex)
      end
    end else
      Result := Groups[Count - 1]
  end
end;

function TEasyGroups.LastInGroup(Group: TEasyGroup): TEasyItem;
begin
  Result := LastInGroupInternal(Group, False)
end;

function TEasyGroups.LastInGroupInternal(Group: TEasyGroup; VisibleOnly: Boolean): TEasyItem;
var
  ItemIndex: Integer;
begin
  Result := nil;
  if Assigned(Group) then
  begin
    if Assigned(Group.Items) then
    begin
      ItemIndex := Group.Items.Count - 1;
      if VisibleOnly then
      begin
        while not Assigned(Result) and (ItemIndex > -1) do
        begin
          if Group.Items[ItemIndex].Visible then
            Result := Group.Items[ItemIndex]
          else
            Dec(ItemIndex)
        end
      end else
        Result := Group.Items[Group.Items.Count - 1]
    end
  end
end;

function TEasyGroups.LastInitializedItem: TEasyItem;
begin
  Result := LastItemInternal(enitInitialized)
end;

function TEasyGroups.LastItem: TEasyItem;
begin
  Result := LastItemInternal(enitAny)
end;

function TEasyGroups.LastItemInternal(NextItemType: TEasyNextItemType): TEasyItem;
var
  ItemIndex, GroupIndex: Integer;
begin
  Result := nil;
  if Count > 0 then
  begin
    GroupIndex := Count - 1;
    while not Assigned(Result) and (GroupIndex > -1) do
    begin
      if Assigned(Groups[GroupIndex].Items) then
      begin
        ItemIndex := Groups[GroupIndex].Items.Count - 1;
        while not Assigned(Result) and (ItemIndex > -1) do
        begin
          case NextItemType of
            enitVisible:
              begin
                if Groups[GroupIndex].Items[ItemIndex].Visible then
                  Result := Groups[GroupIndex].Items[ItemIndex]
                else
                  Dec(ItemIndex)
              end;
            enitInitialized:
              begin
                if Groups[GroupIndex].Items[ItemIndex].Visible then
                  Result := Groups[GroupIndex].Items[ItemIndex]
                else
                  Dec(ItemIndex)
              end
            else
              Result := Groups[GroupIndex].Items[ItemIndex]
          end
        end
      end;
      Dec(GroupIndex);
    end
  end
end;

function TEasyGroups.LastVisibleGroup: TEasyGroup;
begin
  Result := LastGroupInternal(True)
end;

function TEasyGroups.LastVisibleInGroup(Group: TEasyGroup): TEasyItem;
begin
  Result := LastInGroupInternal(Group, True)
end;

function TEasyGroups.LastVisibleItem: TEasyItem;
begin
  Result := LastItemInternal(enitVisible)
end;

function TEasyGroups.NextEditableItem(Item: TEasyItem): TEasyItem;
begin
  Result := NavigateItemInternal(Item, enitEditable, esdForward)
end;

function TEasyGroups.NextGroup(Group: TEasyGroup): TEasyGroup;
begin
  Result := NavigateGroupInternal(Group, False, esdForward)
end;

function TEasyGroups.NextGroupInRect(Group: TEasyGroup; ViewportRect: TRect): TEasyGroup;
//
//  Find the next Groups in the passed rectangle.  It implicitly assumes
// Visible Groups
//
var
  i: Integer;
  ScratchR: TRect;
  Done: Boolean;
begin
  Result := nil;
  Done := False;
  if Assigned(Group) then
  begin
    i := Group.Index + 1;
    while not Assigned(Result) and (i < Count) and not Done do
    begin
      if Groups[i].Visible then
      begin
        if IntersectRect(ScratchR, Groups[i].DisplayRect, ViewportRect) then
          Result := Groups[i]
        else
          Done := True
      end;
      Inc(i)
    end
  end
end;

function TEasyGroups.NavigateGroupInternal(Group: TEasyGroup;
  VisibleOnly: Boolean; Direction: TEasySearchDirection): TEasyGroup;
var
  GroupIndex: Integer;
begin
  Result := nil;
  GroupIndex := Group.Index;
  if Direction = esdForward then
    Inc(GroupIndex)
  else
    Dec(GroupIndex);
  while not Assigned(Result) and (GroupIndex < Count) and (GroupIndex > -1) do
  begin
     if VisibleOnly then
     begin
       if Groups[GroupIndex].Expanded and Groups[GroupIndex].Visible then
         Result := Groups[GroupIndex]
       else begin
         if Direction = esdForward then
           Inc(GroupIndex)
         else
           Dec(GroupIndex);
       end
     end else
       Result := Groups[GroupIndex]
  end
end;

function TEasyGroups.NextInitializedItem(Item: TEasyItem): TEasyItem;
begin
   Result := NavigateItemInternal(Item, enitInitialized, esdForward)
end;

function TEasyGroups.NextVisibleGroupWithVisibleItems(Group: TEasyGroup): TEasyGroup;
//
//  Returns the next Visible Group that has at least one Visible Item
//
var
  Done: Boolean;
begin
  Result := nil;
  if Assigned(Group) then
  begin
    Done := False;
    Result := Group;
    while not Done do
    begin
      Result := NavigateGroupInternal(Result, True, esdForward);
      if Assigned(Result) then
        Done := Result.VisibleCount > 0
      else
        Done := True
    end
  end
end;

function TEasyGroups.NextInGroup(Group: TEasyGroup; Item: TEasyItem): TEasyItem;
begin
  Result := NavigateInGroupInternal(Group, Item, False, esdForward)
end;

function TEasyGroups.NavigateInGroupInternal(Group: TEasyGroup; Item: TEasyItem;
  VisibleOnly: Boolean; Direction: TEasySearchDirection): TEasyItem;
var
  ItemIndex: Integer;
  TempItem: TEasyItem;
  Count: Integer;
begin
  Result := nil;
  if Assigned(Group) and Assigned(Item) then
  begin
    if Assigned(Group.Items) then
    begin
      ItemIndex := Item.FIndex; // Direct access for speed
      if Direction = esdForward then
        Inc(ItemIndex)
      else
        Dec(ItemIndex);
      Count := Group.Items.FList.Count;
      while not Assigned(Result) and (ItemIndex < Count) and (ItemIndex > -1) do
      begin
        // Direct Access for speed
        TempItem := Group.Items.FList.List[ItemIndex];
        if VisibleOnly then
        begin
          // Direct access for speed
          if esosVisible in TempItem.State then
            Result := TempItem
          else begin
            if Direction = esdForward then
              Inc(ItemIndex)
            else
              Dec(ItemIndex)
          end
        end else
          Result := TempItem
      end
    end
  end
end;

function TEasyGroups.NextItem(Item: TEasyItem): TEasyItem;
begin
  Result := NavigateItemInternal(Item, enitAny, esdForward)
end;

function TEasyGroups.NextItemInRect(Item: TEasyItem; ViewportRect: TRect): TEasyItem;
//
//  Find the next Item in the passed rectangle.  It implicitly assumes
// Visible Items
//
var
  Group: TEasyGroup;
  i: Integer;
  R, FullDisplayRect: TRect;
  Done: Boolean;
begin
  Result := nil;
  Done := False;
  Group := Item.OwnerGroup;
  i := Item.Index + 1;

  if OwnerListview.View = elsReport then
  begin
    while not Assigned(Result) and Assigned(Group) and not Done do
    begin
      if (i < Group.Items.Count) and Group.Expanded and not Done then
      begin
        FullDisplayRect := OwnerListview.Header.ViewRect;
        FullDisplayRect.Top := Group.Items[i].DisplayRect.Top;
        FullDisplayRect.Bottom := Group.Items[i].DisplayRect.Bottom;

        if Group.Items[i].Visible then
          if IntersectRect(R, FullDisplayRect, ViewportRect) then
            Result := Group.Items[i]
          else
            Done := True
        else
          Inc(i)
      end else
      begin
       i := 0;
       Group := NextGroupInRect(Group, ViewportRect)
      end
    end
  end else
  begin
    while not Assigned(Result) and Assigned(Group) and not Done do
    begin
      if (i < Group.Items.Count) and Group.Expanded and not Done then
      begin
        if Group.Items[i].Visible then
        begin
          if IntersectRect(R, Group.Items[i].DisplayRect, ViewportRect) then
            Result := Group.Items[i]
          else begin
            if OwnerListview.IsVertView then
              Done := Group.Items[i].DisplayRect.Top > ViewportRect.Bottom
            else
              Done := Group.Items[i].DisplayRect.Left > ViewportRect.Right
          end
        end;
        Inc(i)
      end else
      begin
       i := 0;
       Group := NextGroupInRect(Group, ViewportRect)
      end
    end
  end
end;

function TEasyGroups.NavigateItemInternal(Item: TEasyItem; NextItemType: TEasyNextItemType; Direction: TEasySearchDirection): TEasyItem;
var
  GroupIndex, ItemIndex, Column: Integer;
  Allow: Boolean;
begin
  Result := nil;
  if Assigned(Item) then
  begin
    ItemIndex := Item.Index;
    GroupIndex := Item.OwnerGroup.Index;

    if Direction = esdForward then
      Inc(ItemIndex)
    else
      Dec(ItemIndex);

    while not Assigned(Result) and (GroupIndex < Count) and (GroupIndex > -1) do
    begin
      if Groups[GroupIndex].Expanded and Groups[GroupIndex].Enabled then
      begin
        while not Assigned(Result) and (ItemIndex < Groups[GroupIndex].Items.Count) and (ItemIndex > -1) do
        begin
          if NextItemType in [enitVisible, enitEditable] then
          begin
            if Assigned(Groups[GroupIndex].Items) then
            begin
              if Groups[GroupIndex].Items[ItemIndex].Visible then
              begin
                Result := Groups[GroupIndex].Items[ItemIndex];
                if NextItemType = enitEditable then
                begin
                  Allow := True;
                  OwnerListview.DoItemEditBegin(Result, Column, Allow);
                  if not Allow then
                    Result := nil;
                end
              end
            end;
            if Direction = esdForward then
              Inc(ItemIndex)
            else
              Dec(ItemIndex)
          end else
          if NextItemType = enitInitialized then
          begin
            if Assigned(Groups[GroupIndex].Items) then
            begin
              if Groups[GroupIndex].Items[ItemIndex].Initialized then
                Result := Groups[GroupIndex].Items[ItemIndex]
            end;
            if Direction = esdForward then
              Inc(ItemIndex)
            else
              Dec(ItemIndex)
          end else
            Result := Groups[GroupIndex].Items[ItemIndex];
        end;
        if Direction = esdForward then
        begin
          Inc(GroupIndex);
          ItemIndex := 0
        end else
        begin
          Dec(GroupIndex);
          if (GroupIndex > -1) and Assigned(Groups[GroupIndex].Items) then
            ItemIndex := Groups[GroupIndex].Items.Count - 1;
        end
      end else
      begin
        ItemIndex := 0;
        if Direction = esdForward then
          Inc(GroupIndex)
        else
          Dec(GroupIndex);
      end
    end
  end
end;

function TEasyGroups.NextVisibleGroup(Group: TEasyGroup): TEasyGroup;
begin
  Result := NavigateGroupInternal(Group, True, esdForward)
end;

function TEasyGroups.NextVisibleInGroup(Group: TEasyGroup; Item: TEasyItem): TEasyItem;
begin
  Result := NavigateInGroupInternal(Group, Item, True, esdForward)
end;

function TEasyGroups.NextVisibleItem(Item: TEasyItem): TEasyItem;
begin
  Result := NavigateItemInternal(Item, enitVisible, esdForward)
end;

function TEasyGroups.PrevEditableItem(Item: TEasyItem): TEasyItem;
begin
  Result := NavigateItemInternal(Item, enitEditable, esdBackward)
end;

function TEasyGroups.PrevGroup(Group: TEasyGroup): TEasyGroup;
begin
  Result := NavigateGroupInternal(Group, False, esdBackward)
end;

function TEasyGroups.PrevInitializedItem(Item: TEasyItem): TEasyItem;
begin
  Result := NavigateItemInternal(Item, enitInitialized, esdBackward)
end;

function TEasyGroups.PrevVisibleGroupWithVisibleItems(Group: TEasyGroup): TEasyGroup;
//
//  Returns the prev Visible Group that has at least one Visible Item
//
var
  Done: Boolean;
begin
  Result := nil;
  if Assigned(Group) then
  begin
    Done := False;
    Result := Group;
    while not Done do
    begin
      Result := NavigateGroupInternal(Result, True, esdBackward);
      if Assigned(Result) then
        Done := Result.VisibleCount > 0
      else
        Done := True
    end
  end
end;

function TEasyGroups.PrevInGroup(Group: TEasyGroup; Item: TEasyItem): TEasyItem;
begin
  Result := NavigateInGroupInternal(Group, Item, False, esdBackward)
end;

function TEasyGroups.PrevItem(Item: TEasyItem): TEasyItem;
begin
  Result := NavigateItemInternal(Item, enitAny, esdBackward)
end;

function TEasyGroups.PrevVisibleGroup(Group: TEasyGroup): TEasyGroup;
begin
  Result := NavigateGroupInternal(Group, True, esdBackward)
end;

function TEasyGroups.PrevVisibleInGroup(Group: TEasyGroup; Item: TEasyItem): TEasyItem;
begin
  Result := NavigateInGroupInternal(Group, Item, True, esdBackward)
end;

function TEasyGroups.PrevVisibleItem(Item: TEasyItem): TEasyItem;
begin
  Result := NavigateItemInternal(Item, enitVisible, esdBackward)
end;

procedure TEasyGroups.Clear(FreeItems: Boolean = True);
begin
  if Assigned(OwnerListview.Selection) then
  begin
    OwnerListview.Selection.IncMultiChangeCount;
    OwnerListview.Selection.GroupSelectBeginUpdate;
  end;
  inherited Clear(FreeItems);
  if Assigned(OwnerListview.Selection) then
  begin
    OwnerListview.Selection.DecMultiChangeCount;
    OwnerListview.Selection.GroupSelectEndUpdate;
  end;
end;

procedure TEasyGroups.CollapseAll;
var
  i: Integer;
begin
  OwnerListview.BeginUpdate;
  try
    for i := 0 to Count - 1 do
      Groups[i].Expanded := False
  finally
    OwnerListview.EndUpdate
  end
end;

procedure TEasyGroups.DeleteGroup(Group: TEasyGroup);
var
  Done: Boolean;
  TestGroup: TEasyGroup;
begin
  Done := False;
  TestGroup := FirstGroup;
  while Assigned(TestGroup) and not Done do
  begin
    Done := TestGroup = Group;
    if Done then
      Delete(Group.Index)
    else
      TestGroup := NextGroup(TestGroup)
  end
end;

procedure TEasyGroups.DeleteItem(Item: TEasyItem);
var
  Done: Boolean;
  TestItem: TEasyItem;
  Group: TEasyGroup;
begin
  Done := False;
  TestItem := FirstItem;
  while Assigned(TestItem) and not Done do
  begin
    Done := TestItem = Item;
    if Done then
    begin
      Group := TestItem.OwnerGroup;
      Group.Items.Delete(Item.Index);
    end else
      TestItem := NextItem(TestItem)
  end
end;

procedure TEasyGroups.DeleteItems(ItemArray: TEasyItemArray);
//
// Optimized method of deleting multiple items, the items can be in any group
//
var
  i: Integer;
  Temp: TEasyItem;
begin
  OwnerListview.Selection.IncMultiChangeCount;
  OwnerListview.Selection.GroupSelectBeginUpdate;
  try
    for i := 0 to Length(ItemArray) - 1 do
    begin
      Temp := ItemArray[i].OwnerGroup.FItems[ItemArray[i].Index];
      Temp.Focused := False;
      Temp.Selected := False;
      Temp.Visible := False;
    end;

    for i := 0 to Length(ItemArray) - 1 do
    begin
      Temp := ItemArray[i].OwnerGroup.FItems[ItemArray[i].Index];
      ItemArray[i].OwnerGroup.FItems[ItemArray[i].Index] := nil;
      Temp.Free;
    end;
    for i := 0 to Count - 1 do
    begin
      TEasyGroup( List[i]).FItems.FList.Pack;
      TEasyGroup( List[i]).FItems.ReIndexItems
    end
  finally
    OwnerListview.Selection.GroupSelectEndUpdate;
    OwnerListview.Selection.DecMultiChangeCount
  end
end;

procedure TEasyGroups.DoStructureChange;
begin
  inherited DoStructureChange;
  Rebuild(False)
end;

procedure TEasyGroups.ExpandAll;
var
  i: Integer;
begin
  OwnerListview.BeginUpdate;
  try
    for i := 0 to Count - 1 do
      Groups[i].Expanded := True
  finally
    OwnerListview.EndUpdate
  end
end;

procedure TEasyGroups.InitializeAll;
var
  i, j: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Assigned(Groups[i].Items) then
    begin
      for j := 0 to Groups[i].Items.Count - 1 do
        Groups[i][j].Initialized := True
    end
  end
end;

procedure TEasyGroups.InvalidateItem(Item: TEasyCollectionItem; ImmediateUpdate: Boolean);
begin
  if Assigned(Item) then
    Item.Invalidate(ImmediateUpdate)
end;

{$IFDEF COMPILER_6_UP}
{$ELSE}
{$ENDIF COMPILER_6_UP}

procedure TEasyGroups.LoadFromStream(S: TStream);
begin
  inherited LoadFromStream(S);
  if StreamGroups then
    ReadItems(S);
end;

procedure TEasyGroups.Move(Item: TEasyItem; NewGroup: TEasyGroup);
begin
  if Assigned(Item) and Assigned(NewGroup) then
  begin
    Item.OwnerGroup.Items.Delete(Item.Index);
    NewGroup.Items.Add(Item);
    Item.FCollection := NewGroup.Items;
    DoStructureChange;
  end
end;

procedure TEasyGroups.Rebuild(Force: Boolean = False);
var
  i, VisibleGroupIndex, VisibleItemIndex: Integer;
  ViewRect: TRect;
begin
  if ((OwnerListview.UpdateCount = 0) or Force) and not(csLoading in OwnerListview.ComponentState) and (OwnerListview.HandleAllocated) then
  begin
    Include(FGroupsState, egsRebuilding);

    try
      VisibleList.Clear;
      VisibleList.Capacity := Count;
      VisibleGroupIndex := 0;
      VisibleItemIndex := 0;

      OwnerListview.Header.Rebuild(Force);
      SetRect(ViewRect, 0, 0, 0, 0);
      for i := 0 to Count - 1 do
      begin

        if Groups[i].Visible then
        begin
          VisibleList.Add(Groups[i]);
          Groups[i].FVisibleIndex := VisibleGroupIndex;
          Inc(VisibleGroupIndex);
        end else
          Groups[i].FVisibleIndex := -1;

        if i > 0 then
          Groups[i].Rebuild(Groups[i-1], VisibleItemIndex)
        else
          Groups[i].Rebuild(nil, VisibleItemIndex);

        UnionRect(ViewRect, ViewRect, Groups[i].DisplayRect);
        Groups[i].Items.ReIndexItems
      end;
      if OwnerListview.Selection.GroupSelections then
        OwnerListview.Selection.BuildSelectionGroupings(False);
      OwnerListview.Scrollbars.SetViewRect(ViewRect, True);
    finally
      Exclude(FGroupsState, egsRebuilding);
    end
  end
end;

procedure TEasyGroups.SaveToStream(S: TStream);
begin
  inherited SaveToStream(S);
  if StreamGroups then
    WriteItems(S);
end;

{procedure TEasyGroups.ReIndexItems(Group: TEasyGroup; Force: Boolean);
var
  i, j: Integer;
begin
  if OwnerListview.ReIndexFlag then
  begin
    if Assigned(Group) then
    begin
      for i := 0 to Group.ItemCount - 1 do
        Group.Item[i].FIndex := i;
    end else
    begin
      for i := 0 to Count - 1 do
        for j := 0 to Groups[i].ItemCount - 1 do
          Groups[i].Item[j].FIndex := j;
    end
  end
end;  }

procedure TEasyGroups.SetCellHeight(Value: Integer);
var
  i: Integer;
begin
  OwnerListview.BeginUpdate;
  try
    for i := 0 to Count - 1 do
      Groups[i].Grid.CellSize.Height := Value
  finally
    OwnerListview.EndUpdate
  end
end;

procedure TEasyGroups.SetCellWidth(Value: Integer);
var
  i: Integer;
begin
  OwnerListview.BeginUpdate;
  try
    for i := 0 to Count - 1 do
      Groups[i].Grid.CellSize.Width := Value
  finally
    OwnerListview.EndUpdate
  end
end;

procedure TEasyGroups.SetGroup(Index: Integer; Value: TEasyGroup);
begin
  inherited Items[Index] := Value
end;

procedure TEasyGroups.UnInitializeAll;
var
  i, j: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Assigned(Groups[i].Items) then
    begin
      for j := 0 to Groups[i].Items.Count - 1 do
        Groups[i][j].Initialized := False
    end
  end
end;

{ TEasyColumns }

constructor TEasyColumns.Create(AnOwner: TCustomEasyListview);
begin
  inherited;
  FItemClass := TEasyColumnStored
end;

destructor TEasyColumns.Destroy;
begin
  inherited;
  FreeAndNil(FView);
end;

function TEasyColumns.Add(Data: TObject = nil): TEasyColumn;
begin
  Result := TEasyColumn( inherited Add(Data));
end;

function TEasyColumns.AddCustom(CustomItem: TEasyColumnClass; Data: TObject = nil): TEasyColumn;
begin
  Result := nil;
  if Assigned(CustomItem) then
  begin
    Result := CustomItem.Create(Self);
    FList.Add(Result);
    ReIndexItems;
    Result.Data := Data;
    DoItemAdd(Result, FList.Count - 1);
    DoStructureChange
  end
end;

function TEasyColumns.AddInterfaced(const DataInf: IUnknown; Data: TObject): TEasyColumnInterfaced;
begin
  Result := nil;
  if Assigned(DataInf) then
  begin
    Result := TEasyColumnInterfaced.Create(Self);
    FList.Add(Result);
    ReIndexItems;
    Result.DataInf := DataInf;
    Result.Data := Data;
    DoItemAdd(Result, FList.Count - 1);
    DoStructureChange
  end
end;

function TEasyColumns.AddVirtual(Data: TObject = nil): TEasyColumnVirtual;
begin
  Result := TEasyColumnVirtual.Create(Self);
  FList.Add(Result);
  ReIndexItems;
  Result.Data := Data;
  DoItemAdd(Result, FList.Count - 1);
  DoStructureChange
end;

function TEasyColumns.ColumnByPoint(ViewportPoint: TPoint): TEasyColumn;
var
  i: Integer;
begin
  Result := nil;
  i := 0;
  // Careful with a binary search here are the rectangles increase with Header.Postions not the Columns property
  while not Assigned(Result) and (i < Count) do
  begin
    if PtInRect(Columns[i].DisplayRect, ViewportPoint) then
      Result := Columns[i]
    else
      Inc(i)
  end
end;

function TEasyColumns.GetColumns(Index: Integer): TEasyColumn;
begin
  Result := TEasyColumn( FList.List[Index])
end;

function TEasyColumns.GetOwnerHeader: TEasyHeader;
begin
  Result := OwnerListview.Header
end;

function TEasyColumns.GetView: TEasyViewColumn;
begin
  if not Assigned(FView) then
    OwnerListview.DoCustomColumnView(FView);
  Result := FView;
end;

function TEasyColumns.Insert(Index: Integer; Data: TObject = nil): TEasyColumn;
begin
  Result := TEasyColumn( inherited Insert(Index, Data))
end;

function TEasyColumns.InsertCustom(Index: Integer; CustomColumn: TEasyColumnClass; Data: TObject = nil): TEasyColumn;
begin
  Result := nil;
  if Assigned(CustomColumn) then
  begin
    Result := CustomColumn.Create(Self);
    FList.Insert(Index, Result);
    ReIndexItems;
    DoItemAdd(Result, Index);
    Result.Data := Data;
    DoStructureChange
  end
end;

function TEasyColumns.InsertInterfaced(Index: Integer; const DataInf: IUnknown; Data: TObject = nil): TEasyColumnInterfaced;
begin
  Result := nil;
  if Assigned(DataInf) then
  begin
    Result := TEasyColumnInterfaced.Create(Self);
    FList.Insert(Index, Result);
    ReIndexItems;
    DoItemAdd(Result, Index);
    Result.DataInf := DataInf;
    Result.Data := Data;
    DoStructureChange
  end
end;

function TEasyColumns.InsertVirtual(Index: Integer; Data: TObject = nil): TEasyColumnVirtual;
begin
  Result := TEasyColumnVirtual.Create(Self);
  FList.Insert(Index, Result);
  ReIndexItems;
  DoItemAdd(Result, Index);
  Result.Data := Data;
  DoStructureChange
end;

procedure TEasyColumns.Clear(FreeItems: Boolean = True);
begin
  if Assigned(OwnerHeader) and Assigned(OwnerHeader.Positions) then
    OwnerHeader.Positions.Clear;
  inherited Clear(FreeItems);
end;

procedure TEasyColumns.DoItemAdd(Item: TEasyCollectionItem; Index: Integer);
begin
  inherited DoItemAdd(Item, Index);
end;

procedure TEasyColumns.DoStructureChange;
begin
  inherited DoStructureChange;
  OwnerListview.Header.Rebuild(False)
end;

procedure TEasyColumns.SetColumns(Index: Integer; Value: TEasyColumn);
begin
  inherited Items[Index] := Value
end;

procedure TEasyColumns.SetView(Value: TEasyViewColumn);
begin
  if Value <> FView then
  begin
    FreeAndNil(FView);
    FView := Value
  end
end;

{ TEasyGlobalImageManager }

constructor TEasyGlobalImageManager.Create(AnOwner: TCustomEasyListview);
begin
  inherited;
  FGroupExpandButton := TBitmap.Create;
  FGroupCollapseButton := TBitmap.Create;
  FColumnSortUp := TBitmap.Create;
  FColumnSortDown := TBitmap.Create;
end;

destructor TEasyGlobalImageManager.Destroy;
begin
  inherited;
  FreeAndNil(FGroupExpandButton);
  FreeAndNil(FGroupCollapseButton);
  FreeAndNil(FColumnSortUp);
  FreeAndNil(FColumnSortDown);
end;

function TEasyGlobalImageManager.GetColumnSortDown: TBitmap;
begin
  if FColumnSortDown.Empty then
  begin
    MakeTransparent(FColumnSortDown, clFuchsia);
    FColumnSortDown.LoadFromResourceName(hInstance, BITMAP_SORTARROWDOWN);
  end;
  Result := FColumnSortDown
end;

function TEasyGlobalImageManager.GetColumnSortUp: TBitmap;
begin
  if FColumnSortUp.Empty then
  begin
    MakeTransparent(FColumnSortUp, clFuchsia);
    FColumnSortUp.LoadFromResourceName(hInstance, BITMAP_SORTARROWUP);
  end;
  Result := FColumnSortUp
end;

function TEasyGlobalImageManager.GetGroupCollapseImage: TBitmap;
begin
  if FGroupCollapseButton.Empty then
  begin
    MakeTransparent(FGroupCollapseButton, clFuchsia);
    FGroupCollapseButton.LoadFromResourceName(hInstance, BITMAP_DEFAULTGROUPCOLLAPSED);
  end;
  Result := FGroupCollapseButton
end;

function TEasyGlobalImageManager.GetGroupExpandImage: TBitmap;
begin
  if FGroupExpandButton.Empty then
  begin
    MakeTransparent(FGroupExpandButton, clFuchsia);
    FGroupExpandButton.LoadFromResourceName(hInstance, BITMAP_DEFAULTGROUPEXPANDED);
  end;
  Result := FGroupExpandButton
end;

procedure TEasyGlobalImageManager.MakeTransparent(Bits: TBitmap; TransparentColor: TColor);
begin
  Bits.Transparent := True;
  Bits.TransparentColor := TransparentColor
end;

procedure TEasyGlobalImageManager.SetColumnSortDown(Value: TBitmap);
begin
  FColumnSortDown.Assign(Value)
end;

procedure TEasyGlobalImageManager.SetColumnSortUp(Value: TBitmap);
begin
  FColumnSortUp.Assign(Value)
end;

procedure TEasyGlobalImageManager.SetGroupCollapseImage(const Value: TBitmap);
begin
  FGroupExpandButton.Assign(Value);
end;

procedure TEasyGlobalImageManager.SetGroupExpandImage(const Value: TBitmap);
begin
  GroupCollapseButton.Assign(Value);
end;

{ TEasyGroup }

constructor TEasyGroup.Create(ACollection: TEasyCollection);
begin
  inherited;
  FExpanded := True;
  FItems := TEasyItems.Create(OwnerListview, Self);
  Items.StoreInDFM := OwnerGroups.StoreInDFM;
  FItemView := OwnerGroups.DefaultItemView.Create(Self);
  FGroupView := OwnerGroups.DefaultGroupView.Create(Self);
  FGrid := OwnerGroups.DefaultGrid.Create(OwnerListview, Self);
  FVisibleItems := TList.Create;
end;

destructor TEasyGroup.Destroy;
begin
  SetDestroyFlags;
  Selected := False;
  Focused := False;
  FItems.Free;  // don't nil the reference the items may need it as they are destroyed.
  inherited;
  FreeAndNil(FItemView);
  FreeAndNil(FGroupView);
  FreeAndNil(FGrid);
  FreeAndNil(FVisibleItems);
  
end;

function TEasyGroup.BoundsRectBottomMargin: TRect;
begin
  if MarginBottom.Visible and OwnerListview.ShowGroupMargins then
  begin
    Result := DisplayRect;
    Result.Top := Result.Bottom - MarginBottom.RuntimeSize;
    Result.Right := Result.Right - MarginRight.RuntimeSize;
    Result.Left := Result.Left + MarginLeft.RuntimeSize;
  end else
    Result := Rect(0, 0, 0, 0);
end;

function TEasyGroup.BoundsRectLeftMargin: TRect;
begin
  if MarginLeft.Visible and OwnerListview.ShowGroupMargins then
  begin
    Result := DisplayRect;
    Result.Right := Result.Left + MarginLeft.RuntimeSize
  end else
    Result := Rect(0, 0, 0, 0);
end;

function TEasyGroup.BoundsRectRightMargin: TRect;
begin
  if MarginRight.Visible and OwnerListview.ShowGroupMargins then
  begin
    Result := DisplayRect;
    Result.Left := Result.Right - MarginRight.RuntimeSize
  end else
    Result := Rect(0, 0, 0, 0);
end;

function TEasyGroup.BoundsRectTopMargin: TRect;
begin
  if MarginTop.Visible and OwnerListview.ShowGroupMargins then
  begin
    Result := DisplayRect;
    Result.Bottom := Result.Top + MarginTop.RuntimeSize;
    Result.Right := Result.Right - MarginRight.RuntimeSize;
    Result.Left := Result.Left + MarginLeft.RuntimeSize;
  end else
    Result := Rect(0, 0, 0, 0);
end;

function TEasyGroup.BoundsRectBkGnd: TRect;
begin
  Result := DisplayRect;
  Result.Left := Result.Left + MarginLeft.RuntimeSize;
  Result.Right := Result.Right - MarginRight.RuntimeSize;
  Result.Top := Result.Top + MarginTop.RuntimeSize;
  Result.Bottom := Result.Bottom -  MarginBottom.RuntimeSize;
end;

function TEasyGroup.CanChangeBold(NewValue: Boolean): Boolean;
begin
  Result := True
end;

function TEasyGroup.CanChangeCheck(NewValue: Boolean): Boolean;
begin
  Result := Enabled;
end;

function TEasyGroup.CanChangeEnable(NewValue: Boolean): Boolean;
begin
  Result := True;
end;

function TEasyGroup.CanChangeFocus(NewValue: Boolean): Boolean;
begin
  // Unsupported
  Result := False;
end;

function TEasyGroup.CanChangeHotTracking(NewValue: Boolean): Boolean;
begin
  // Unsupported
  Result := True;
end;

function TEasyGroup.CanChangeSelection(NewValue: Boolean): Boolean;
begin
  Result := True;
  OwnerListview.DoGroupSelectionChanging(Self, Result)
end;

function TEasyGroup.CanChangeVisibility(NewValue: Boolean): Boolean;
begin
  Result := True;
  OwnerListview.DoGroupVisibilityChanging(Self, Result)
end;

function TEasyGroup.DefaultImageList(ImageSize: TEasyImageSize): TImageList;
begin
  Result:= OwnerListview.ImagesGroup
end;

function TEasyGroup.EditAreaHitPt(ViewportPoint: TPoint): Boolean;
begin
  Result := GroupView.EditAreaHitPt(Self, ViewportPoint)
end;

function TEasyGroup.GetBandBlended: Boolean;
begin
  Result := PaintInfo.BandBlended
end;

function TEasyGroup.GetBandColor: TColor;
begin
  Result := PaintInfo.BandColor
end;

function TEasyGroup.GetBandColorFade: TColor;
begin
  Result := PaintInfo.BandColorFade
end;

function TEasyGroup.GetBandEnabled: Boolean;
begin
  Result := PaintInfo.BandEnabled
end;

function TEasyGroup.GetBandFullWidth: Boolean;
begin
  Result := PaintInfo.BandFullWidth
end;

function TEasyGroup.GetBandIndent: Integer;
begin
  Result := PaintInfo.BandIndent
end;

function TEasyGroup.GetBandLength: Integer;
begin
  Result := PaintInfo.BandLength
end;

function TEasyGroup.GetBandMargin: Integer;
begin
  Result := PaintInfo.BandMargin
end;

function TEasyGroup.GetBandRadius: Byte;
begin
  Result := PaintInfo.BandRadius
end;

function TEasyGroup.GetBandThickness: Integer;
begin
  Result := PaintInfo.BandThickness
end;

function TEasyGroup.GetClientRect: TRect;
begin
  Result := Rect( FDisplayRect.Left + MarginLeft.RuntimeSize,
                  FDisplayRect.Top + MarginTop.RuntimeSize,
                  FDisplayRect.Right - MarginRight.RuntimeSize,
                  FDisplayRect.Bottom - MarginBottom.RuntimeSize)
end;

function TEasyGroup.GetExpandable: Boolean;
begin
  Result := PaintInfo.Expandable
end;

function TEasyGroup.GetExpandImageIndent: Integer;
begin
  Result := PaintInfo.ExpandImageIndent
end;

function TEasyGroup.GetItem(Index: Integer): TEasyItem;
begin
  Result := Items[Index]
end;

function TEasyGroup.GetItemCount: Integer;
begin
  Result := Items.Count
end;

function TEasyGroup.GetMarginBottom: TEasyFooterMargin;
begin
  Result := PaintInfo.MarginBottom as TEasyFooterMargin
end;

function TEasyGroup.GetMarginLeft: TEasyMargin;
begin
  Result := PaintInfo.MarginLeft
end;

function TEasyGroup.GetMarginRight: TEasyMargin;
begin
  Result := PaintInfo.MarginRight
end;

function TEasyGroup.GetMarginTop: TEasyHeaderMargin;
begin
  Result := PaintInfo.MarginTop
end;

function TEasyGroup.GetOwnerGroups: TEasyGroups;
begin
  Result := TEasyGroups( Collection)
end;

function TEasyGroup.GetOwnerListview: TCustomEasyListview;
begin
  Result := TEasyGroups( Collection).OwnerListview
end;

function TEasyGroup.GetPaintInfo: TEasyPaintInfoBaseGroup;
begin
  Result := inherited PaintInfo as TEasyPaintInfoBaseGroup
end;

function TEasyGroup.GetVisibleCount: Integer;
begin
  Result := FVisibleItems.Count
end;

function TEasyGroup.GetVisibleItem(Index: Integer): TEasyItem;
begin
  Result := nil;
  if (Index > -1) and (Index < VisibleItems.Count) then
    Result := TEasyItem( VisibleItems[Index])
end;

function TEasyGroup.HitTestAt(ViewportPoint: TPoint;
  var HitInfo: TEasyGroupHitTestInfoSet): Boolean;
///
// Returns information about what, if anything, was hit at the passed point in
// the group.  Returns true if anything was hit.
//
var
  RectArray: TEasyRectArrayObject;
  R: TRect;
begin
  HitInfo := [];

  // First need to see what Frame of the group was hit, and then the individual
  // rectangle for each element in the Frame is retrieved
  if PtInRect(BoundsRectTopMargin, ViewportPoint) then
  begin
    Include(HitInfo, egtOnHeader);
    GroupView.GroupRectArray(Self, egmeTop, BoundsRectTopMargin, RectArray);
  end else
  if PtInRect(BoundsRectBottomMargin, ViewportPoint) then
  begin
    Include(HitInfo, egtOnFooter);
    GroupView.GroupRectArray(Self, egmeBottom, BoundsRectBottomMargin, RectArray);
  end else
  if PtInRect(BoundsRectLeftMargin, ViewportPoint) then
  begin
    Include(HitInfo, egtOnLeftMargin);
    GroupView.GroupRectArray(Self, egmeLeft, BoundsRectLeftMargin, RectArray);
  end else
  if PtInRect(BoundsRectRightMargin, ViewportPoint) then
  begin
    Include(HitInfo, egtOnRightMargin);
    GroupView.GroupRectArray(Self, egmeRight, BoundsRectRightMargin, RectArray);
  end;

  if HitInfo <> [] then
  begin
    R := RectArray.IconRect;
    // Make the blank area between the image and text part of the image
    R.Right := R.Right + OwnerListview.PaintInfoGroup.CaptionIndent;
    if PtInRect(R, ViewportPoint) then
      Include(HitInfo, egtOnIcon)
    else
    if PtInRect(RectArray.TextRect, ViewportPoint) then
      Include(HitInfo, egtOnText)
    else
    if PtInRect(RectArray.LabelRect, ViewportPoint) then
      Include(HitInfo, egtOnLabel)
    else
    if PtInRect(RectArray.ExpandButtonRect, ViewportPoint) then
      Include(HitInfo, egtOnExpandButton)
    else
    if PtInRect(RectArray.BandRect, ViewportPoint) then
      Include(HitInfo, egtOnBand)
    else
    if PtInRect(RectArray.CheckRect, ViewportPoint) then
      Include(HitInfo, egtOnCheckbox);

  end;
  Result := HitInfo <> []
end;

function TEasyGroup.ItemByPoint(ViewportPoint: TPoint): TEasyItem;
var
  i: Integer;
begin
  Result := nil;
  i := 0;
  while not Assigned(Result) and (i < Items.Count) do
  begin
    if PtInRect(Items[i].DisplayRect, ViewportPoint) then
      Result := Items[i];
    Inc(i)
  end
end;

function TEasyGroup.LocalPaintInfo: TEasyPaintInfoBasic;
begin
  Result := OwnerListview.PaintInfoGroup
end;

function TEasyGroup.SelectionHit(SelectViewportRect: TRect;
  SelectType: TEasySelectHitType): Boolean;
begin
  Result := GroupView.SelectionHit(Self, SelectViewPortRect, SelectType)
end;

function TEasyGroup.SelectionHitPt(ViewportPoint: TPoint;
  SelectType: TEasySelectHitType): Boolean;
begin
  Result := GroupView.SelectionHitPt(Self, ViewportPoint, SelectType)
end;

procedure TEasyGroup.Freeing;
begin
  OwnerListview.DoGroupFreeing(Self)
end;

procedure TEasyGroup.GainingBold;
begin
  Invalidate(False)
end;

procedure TEasyGroup.GainingCheck;
var
  i: Integer;
begin
  for i := 0 to Items.Count - 1 do
    if Items[i].Visible then
      Items[i].Checked := True;
  if Visible then
    Include(FState, esosChecked);
  Invalidate(False)
end;

procedure TEasyGroup.GainingEnable;
var
  i: Integer;
begin
  for i := 0 to Items.Count - 1 do
    Items[i].Enabled := True;
  Include(FState, esosEnabled);
  Invalidate(False)
end;

procedure TEasyGroup.GainingFocus;
begin
  // Unsupported
end;

procedure TEasyGroup.GainingHilight;
begin
  // Unsupported
end;

procedure TEasyGroup.GainingHotTracking(MousePos: TPoint);
begin
  OwnerListview.DoGroupHotTrack(Self, ehsEnable, MousePos);
  Invalidate(True)
end;

procedure TEasyGroup.GainingSelection;
begin
  OwnerListview.DoGroupSelectionChanged(Self)
end;

procedure TEasyGroup.GainingVisibility;
var
  i: Integer;
begin
  OwnerListview.DoGroupVisibilityChanged(Self);
  for i := 0 to Items.Count - 1 do
    Items[i].Visible := True
end;

procedure TEasyGroup.Initialize;
begin
  OwnerListview.DoGroupInitialize(Self)
end;

procedure TEasyGroup.LoadFromStream(S: TStream; Version: Integer = STREAM_VERSION);
begin
  inherited LoadFromStream(S);
  if Assigned(GroupView) and Assigned(ItemView) then
  begin
    if not Assigned(Items) then
      Items := TEasyItems.Create(OwnerListview, Self)
    else
      Items.Clear;
    Items.ReadItems(S)
  end;
  OwnerListview.DoGroupLoadFromStream(Self, S);

  // For new objects test the stream version first
  // if Collection.StreamVersion > X then
  // begin
  //   ReadStream....
  // end
end;

procedure TEasyGroup.LosingBold;
begin
  Invalidate(False)
end;

procedure TEasyGroup.LosingCheck;
var
  i: Integer;
begin
  for i := 0 to Items.Count - 1 do
    Items[i].Checked := False;
  Exclude(FState, esosChecked);
  Invalidate(False)
end;

procedure TEasyGroup.LosingEnable;
var
  i: Integer;
begin
  for i := 0 to Items.Count - 1 do
    Items[i].Enabled := False;
  Exclude(FState, esosEnabled);
  Invalidate(False)
end;

procedure TEasyGroup.LosingFocus;
begin
 // Unsupported
end;

procedure TEasyGroup.LosingHilight;
begin
 // Unsupported
end;

procedure TEasyGroup.LosingHotTracking;
begin
  OwnerListview.DoGroupHotTrack(Self, ehsDisable, Point(0, 0));
  Invalidate(True)
end;

procedure TEasyGroup.LosingSelection;
begin
  OwnerListview.DoGroupSelectionChanged(Self)
end;

procedure TEasyGroup.LosingVisibility;
var
  i: Integer;
begin
  for i := 0 to Items.Count - 1 do
    Items[i].Visible := False;
  OwnerListview.DoGroupVisibilityChanged(Self);
end;

procedure TEasyGroup.Paint(MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; ACanvas: TCanvas);
begin
  GroupView.Paint(Self, MarginEdge, ObjRect, ACanvas)
end;

procedure TEasyGroup.Rebuild(PrevGroup: TEasyGroup; var NextVisibleItemIndex: Integer);
begin
  if Assigned(Grid) then
    Grid.Rebuild(PrevGroup, NextVisibleItemIndex)
end;

procedure TEasyGroup.SaveToStream(S: TStream; Version: Integer = STREAM_VERSION);
begin
  inherited SaveToStream(S);
  Items.WriteItems(S);
  OwnerListview.DoGroupSaveToStream(Self, S)
end;

procedure TEasyGroup.SetBandBlended(Value: Boolean);
begin
  if Value <> BandBlended then
  begin
    PaintInfo.BandBlended := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroup.SetBandColor(Value: TColor);
begin
  if Value <> BandColor then
  begin
    PaintInfo.BandColor := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroup.SetBandColorFade(Value: TColor);
begin
  if Value <> BandColorFade then
  begin
    PaintInfo.BandColorFade := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroup.SetBandEnabled(Value: Boolean);
begin
  if Value <> BandEnabled then
  begin
    PaintInfo.BandEnabled := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroup.SetBandFullWidth(Value: Boolean);
begin
  if Value <> BandFullWidth then
  begin
    PaintInfo.BandFullWidth := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroup.SetBandIndent(Value: Integer);
begin
  if Value <> BandIndent then
  begin
    PaintInfo.BandIndent := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroup.SetBandLength(Value: Integer);
begin
  if Value <> BandLength then
  begin
    PaintInfo.BandLength := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroup.SetBandMargin(Value: Integer);
begin
  if Value <> BandMargin then
  begin
    PaintInfo.BandMargin := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroup.SetBandRadius(Value: Byte);
begin
  if Value <> BandRadius then
  begin
    PaintInfo.BandRadius:= Value;
    Invalidate(False)
  end
end;

procedure TEasyGroup.SetBandThickness(Value: Integer);
begin
  if Value <> BandThickness then
  begin
    PaintInfo.BandThickness := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroup.SetExpandable(Value: Boolean);
begin
  if Value <> Expandable then
  begin
    PaintInfo.Expandable := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroup.SetExpanded(Value: Boolean);
begin
  if Value <> FExpanded then
  begin
    OwnerListview.BeginUpdate;
    try
      if Value then
        OwnerListview.DoGroupExpand(Self)
      else
        OwnerListview.DoGroupCollapse(Self);
      FExpanded := Value;
      OwnerListview.Groups.Rebuild(True);
    finally
      OwnerListview.EndUpdate;
    end
  end
end;

procedure TEasyGroup.SetExpandImageIndent(Value: Integer);
begin
  if Value <> ExpandImageIndent then
  begin
    PaintInfo.ExpandImageIndent := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroup.SetGrid(Value: TEasyGridGroup);
begin
  if Value <> FGrid then
  begin
    FreeAndNil(FGrid);
    FGrid := Value
  end
end;

procedure TEasyGroup.SetGroupView(Value: TEasyViewGroup);
begin
  if Value <> FGroupView then
  begin
    if Assigned(FGroupView) then
      FreeAndNil(FGroupView);
    FGroupView := Value
  end
end;

procedure TEasyGroup.SetItem(Index: Integer; Value: TEasyItem);
begin
  if (Index > -1) and (Index < Items.Count) then
    Items[Index] := Value
end;

procedure TEasyGroup.SetItemView(Value: TEasyViewItem);
begin
  if Value <> FItemView then
  begin
    if Assigned(FItemView) then
      FreeAndNil(FItemView);
    FItemView := Value
  end
end;

procedure TEasyGroup.SetMarginBottom(Value: TEasyFooterMargin);
begin
  if Value <> MarginBottom then
  begin
    PaintInfo.MarginBottom := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroup.SetMarginLeft(Value: TEasyMargin);
begin
  if Value <> MarginLeft then
  begin
    PaintInfo.MarginLeft := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroup.SetMarginRight(Value: TEasyMargin);
begin
  if Value <> MarginRight then
  begin
    PaintInfo.MarginRight := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroup.SetMarginTop(Value: TEasyHeaderMargin);
begin
  if Value <> MarginTop then
  begin
    PaintInfo.MarginTop := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroup.SetPaintInfo(const Value: TEasyPaintInfoBaseGroup);
begin
  inherited PaintInfo := Value
end;

function TEasyViewGroup.CustomExpandImages: Boolean;
begin
  Result := not OwnerListview.GroupCollapseButton.Empty  or not OwnerListview.GroupExpandButton.Empty
end;

function TEasyViewGroup.EditAreaHitPt(Group: TEasyGroup; ViewportPoint: TPoint): Boolean;
begin
  Result := False
end;

function TEasyViewGroup.GetImageList(Group: TEasyGroup): TImageList;
begin
  Result := Group.ImageList[-1, eisSmall]
end;

function TEasyViewGroup.SelectionHit(Group: TEasyGroup;
  SelectViewportRect: TRect; SelectType: TEasySelectHitType): Boolean;
begin
  Result := False
end;

function TEasyViewGroup.SelectionHitPt(Group: TEasyGroup; ViewportPoint: TPoint;
  SelectType: TEasySelectHitType): Boolean;
begin
  Result := False
end;

{ TEasyGroupView }

procedure TEasyViewGroup.GetCollapseExpandImages(var Expand, Collapse: TBitmap);
begin
  Expand := nil;
  Collapse := nil;
  if not OwnerListview.GroupCollapseButton.Empty then
    Collapse := OwnerListview.GroupCollapseButton
  else
    Collapse := OwnerListview.GlobalImages.GroupCollapseButton;

  if not OwnerListview.GroupExpandButton.Empty then
    Expand := OwnerListview.GroupExpandButton
  else
    Expand := OwnerListview.GlobalImages.GroupExpandButton;
end;

procedure TEasyViewGroup.GetExpandImageSize(Group: TEasyGroup; var ImageW, ImageH: Integer);
var
  ExpandImage, CollapseImage: TBitmap;
begin
  ImageW := 0;
  ImageH := 0;
  GetCollapseExpandImages(ExpandImage, CollapseImage);
  if Assigned(ExpandImage) and Assigned(CollapseImage) then
  begin
    ImageW := ExpandImage.Width;
    ImageH := ExpandImage.Height;
    if CollapseImage.Width > ImageW then
      ImageW := CollapseImage.Width;
    if CollapseImage.Height > ImageH then
      ImageH := CollapseImage.Height
  end
end;

procedure TEasyViewGroup.GetImageSize(Group: TEasyGroup; var ImageW, ImageH: Integer);
var
  Images: TImageList;
  IsCustom: Boolean;
begin
  ImageW := 0;
  ImageH := 0;
  Group.ImageDrawIsCustom(nil, IsCustom);
  if IsCustom then
    Group.ImageDrawGetSize(nil, ImageW, ImageH)
  else begin
    Images := GetImageList(Group);
    if (Group.ImageIndexes[0] > -1) and Assigned(Images) then
    begin
        ImageW := Images.Width;
        ImageH := Images.Height
    end
  end;
end;

procedure TEasyViewGroup.GroupRectArray(Group: TEasyGroup; MarginEdge: TEasyGroupMarginEdge;
  ObjRect: TRect; var RectArray: TEasyRectArrayObject);
//
// Grabs all the rectangles for the items within a cell in one call
// If PaintInfo is nil then the information is fetched automaticlly
//
var
  TextSize: TSize;
  HeaderBand, FooterBand: TRect;
  TempRectArray: TEasyRectArrayObject;
  ImageW, ImageH, ExpandImageW, ExpandImageH: Integer;
begin
  Group.Initialized := True;
  
  FillChar(RectArray, SizeOf(RectArray), #0);

  RectArray.GroupRect := ObjRect;
  RectArray.BackGndRect :=  Group.BoundsRectBkGnd;

  GetImageSize(Group, ImageW, ImageH);
  GetExpandImageSize(Group, ExpandImageW, ExpandImageH);

  if MarginEdge in [egmeTop, egmeBottom] then
  begin
    // Calculate the Expansion button first for the Header only
    if Group.Expandable and (MarginEdge = egmeTop) then
      RectArray.ExpandButtonRect := Rect(RectArray.GroupRect.Left + Group.ExpandImageIndent,
                      RectArray.GroupRect.Top,
                      RectArray.GroupRect.Left + ExpandImageW + Group.ExpandImageIndent,
                      RectArray.GroupRect.Bottom)
    else   // Make the ExpandButton R a width of 0
      RectArray.ExpandButtonRect := Rect(RectArray.GroupRect.Left,
                      RectArray.GroupRect.Top,
                      RectArray.GroupRect.Left,
                      RectArray.GroupRect.Bottom);

    if (Group.CheckType <> ectNone) and (MarginEdge in [egmeTop]) then
    begin
      RectArray.CheckRect := Checks.Bound[Group.CheckSize];
      OffsetRect(RectArray.CheckRect, RectArray.ExpandButtonRect.Right + Group.CheckIndent, ObjRect.Top + (RectHeight(ObjRect) - RectHeight(RectArray.CheckRect)) div 2);
    end else
    begin
      // CheckRect is a 0 width
      RectArray.CheckRect := ObjRect;
      RectArray.CheckRect.Left := RectArray.ExpandButtonRect.Right;
      RectArray.CheckRect.Right := RectArray.ExpandButtonRect.Right;
    end;


    // Now Calculate the image for the header or the footer
    if Group.ImageIndex > -1 then
      RectArray.IconRect := Rect(RectArray.CheckRect.Right + Group.ImageIndent,
                    RectArray.GroupRect.Top,
                    RectArray.CheckRect.Right + ImageW + Group.ImageIndent,
                    RectArray.GroupRect.Bottom)
    else   // Make the IconR a width of 0
      RectArray.IconRect := Rect(RectArray.CheckRect.Right,
                    RectArray.CheckRect.Top,
                    RectArray.CheckRect.Right,
                    RectArray.CheckRect.Bottom);

    // Now the Label rect may be calculated for the header or footer
    RectArray.LabelRect := Rect(RectArray.IconRect.Right + Group.CaptionIndent,
                   RectArray.ExpandButtonRect.Top,
                   RectArray.GroupRect.Right,
                   RectArray.ExpandButtonRect.Bottom);


    // Calculate the text size for the text based on the above font
    if Assigned(OwnerListview.ScratchCanvas) then
    begin
      LoadTextFont(Group, OwnerListview.ScratchCanvas);
      TextSize := TextExtentW(Group.Caption, OwnerListview.ScratchCanvas.Font);
    end else
    begin
      TextSize.cx := 0;
      TextSize.cy := 0;
    end;
    RectArray.TextRect := Rect(RectArray.LabelRect.Left,
                               RectArray.LabelRect.Top,
                               RectArray.LabelRect.Left + TextSize.cx,
                               RectArray.LabelRect.Top + TextSize.cy);

    if RectArray.TextRect.Right > RectArray.LabelRect.Right then
      RectArray.TextRect.Right := RectArray.LabelRect.Right;
    if RectArray.TextRect.Bottom > RectArray.LabelRect.Bottom then
      RectArray.TextRect.Bottom := RectArray.LabelRect.Bottom;

    case Group.Alignment of
      taLeftJustify:  OffsetRect(RectArray.TextRect, 0, 0);
      taRightJustify: OffsetRect(RectArray.TextRect, RectWidth(RectArray.LabelRect) - (RectWidth(RectArray.TextRect)), 0);
      taCenter: OffsetRect(RectArray.TextRect, (RectWidth(RectArray.LabelRect) - RectWidth(RectArray.TextRect)) div 2, 0);
    end;

    case Group.VAlignment of
      evaBottom: OffsetRect(RectArray.TextRect, 0, RectHeight(RectArray.GroupRect) - (RectHeight(RectArray.TextRect) + Group.BandThickness + Group.BandMargin));
      evaCenter: OffsetRect(RectArray.TextRect, 0, (RectHeight(RectArray.GroupRect) - RectHeight(RectArray.TextRect)) div 2);
    end;
    // Use the calculated label rectangle to position where the text goes


    if Group.BandEnabled then
    begin
      if Group.BandFullWidth then
        RectArray.BandRect := Rect(RectArray.GroupRect.Left,
                           RectArray.GroupRect.Bottom - Group.BandMargin - Group.BandThickness,
                           RectArray.GroupRect.Right,
                           RectArray.GroupRect.Bottom - Group.BandMargin)
      else
        RectArray.BandRect := Rect(RectArray.GroupRect.Left,
                           RectArray.GroupRect.Bottom - Group.BandMargin - Group.BandThickness,
                           RectArray.GroupRect.Left + Group.BandLength,
                           RectArray.GroupRect.Bottom - Group.BandMargin);

      OffsetRect(RectArray.BandRect, Group.BandIndent, 0);
    end;

  end else
  begin  // Calculate the margin rectangles

    // Need to send nil so the user attributes are fetched for the header
    GroupRectArray(Group, egmeTop, Group.BoundsRectTopMargin, TempRectArray);
    HeaderBand := TempRectArray.BandRect;

    // Need to send nil so the user attributes are fetched for the footer
    GroupRectArray(Group, egmeBottom, Group.BoundsRectBottomMargin, TempRectArray);
    FooterBand := TempRectArray.BandRect;

    if MarginEdge  = egmeLeft then
      RectArray.BandRect := Rect(RectArray.GroupRect.Left + (RectWidth(RectArray.GroupRect) - Group.BandThickness) div 2,
                            HeaderBand.Top,
                            RectArray.GroupRect.Right,
                            FooterBand.Bottom - 1);
    if MarginEdge  = egmeRight then
      RectArray.BandRect := Rect(RectArray.GroupRect.Left,
                            HeaderBand.Top,
                            RectArray.GroupRect.Right - (RectWidth(RectArray.GroupRect) - Group.BandThickness) div 2,
                            FooterBand.Bottom - 1)
  end;
end;

procedure TEasyViewGroup.LoadTextFont(Group: TEasyGroup; ACanvas: TCanvas);
begin
  if Assigned(ACanvas) then
  begin
    ACanvas.Font.Assign(OwnerListview.GroupFont);
    ACanvas.Brush.Style := bsClear;
    if Group.Focused then
    begin
      if OwnerListview.Focused then
        ACanvas.Font.Color := clHighlightText;
    end;
    if Group.Bold then
      ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];

    OwnerListview.DoGroupPaintText(Group, ACanvas);
  end
end;

procedure TEasyViewGroup.Paint(Group: TEasyGroup; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; ACanvas: TCanvas);
//
// Calls the sub Paint methods to do a complete Paint cycle for the Group
//
var
  RectArray: TEasyRectArrayObject;
begin
  if not IsRectEmpty(ObjRect) then
  begin
    CanvasStore.StoreCanvasState(ACanvas);
    try
      GroupRectArray(Group, MarginEdge, ObjRect, RectArray);
      PaintBefore(Group, ACanvas, MarginEdge, ObjRect, RectArray);
      PaintBackground(Group, ACanvas, MarginEdge, ObjRect, RectArray);
      if MarginEdge = egmeTop then
        PaintCheckBox(Group, ACanvas, RectArray);
      PaintSelectionRect(Group, ACanvas, ObjRect, RectArray);
      PaintFocusRect(Group, ACanvas, MarginEdge, ObjRect, RectArray);
      PaintText(Group, MarginEdge, ACanvas, ObjRect, RectArray);
      PaintBand(Group, ACanvas, MarginEdge, ObjRect, RectArray);
      PaintExpandButton(Group, ACanvas, MarginEdge, ObjRect, RectArray);
      PaintImage(Group, ACanvas, MarginEdge, ObjRect, RectArray);
      PaintAfter(Group, ACanvas, MarginEdge, ObjRect, RectArray);
    finally
      CanvasStore.RestoreCanvasState(ACanvas)
    end
  end
end;

procedure TEasyViewGroup.PaintAfter(Group: TEasyGroup; ACanvas: TCanvas;
  MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject);
begin

end;

procedure TEasyViewGroup.PaintBackground(Group: TEasyGroup; ACanvas: TCanvas;
  MarginEdge: TEasyGroupMarginEdge;ObjRect: TRect; RectArray: TEasyRectArrayObject);
begin

end;

procedure TEasyViewGroup.PaintBand(Group: TEasyGroup; ACanvas: TCanvas;
   MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject);
//
// Paints the banding in none, one, ..., all margins of the Group
var
  i: Integer;
  Red1, Red2, Green1, Green2, Blue1, Blue2, RC, GC, BC: Integer;
  RStep, GStep, BStep : Double;
  RGBVal, BlendStop: Longword;
  CellR: TRect;
begin
  if Group.BandEnabled and not IsRectEmpty(RectArray.BandRect) then
  begin
    CellR := ObjRect;
    if MarginEdge in [egmeBottom, egmeTop] then
    begin
     // Draw the Banding
      if Group.BandBlended then
      begin
        if (Group.BandLength > 0) then
        begin
          // Calulate the stepping to create the blended banding
          RGBVal := ColorToRGB(Group.BandColor);
          Red1 := GetRValue(RGBVal);
          Green1 := GetGValue(RGBVal);
          Blue1 := GetBValue(RGBVal);

          RGBVal := ColorToRGB(Group.BandColorFade);
          Red2 := GetRValue(RGBVal);
          Green2 := GetGValue(RGBVal);
          Blue2 := GetBValue(RGBVal);


          if Group.BandFullWidth then
            BlendStop := RectWidth(CellR)
          else
            BlendStop := Group.BandLength;

          RStep := (Red2-Red1)/BlendStop;
          GStep := (Green2-Green1)/BlendStop;
          BStep := (Blue2-Blue1)/BlendStop;

          ACanvas.Pen.Color := Group.BandColor;

          // Draw the Banding
          for i := 0 to BlendStop do
          begin
            if Group.BandFullWidth then
            begin
              ACanvas.MoveTo(CellR.Left + i, RectArray.BandRect.Top);
              ACanvas.LineTo(CellR.Left + i, RectArray.BandRect.Top + Group.BandThickness);
            end else
            begin
              ACanvas.MoveTo(RectArray.BandRect.Left + i, RectArray.BandRect.Top);
              ACanvas.LineTo(RectArray.BandRect.Left + i, RectArray.BandRect.Top + Group.BandThickness);
            end;
            RC:=Round(Red1 + i*RStep);
            GC:=Round(Green1 +i*GStep);
            BC:=Round(Blue1 + i*BStep);
            ACanvas.Pen.Color := RGB(RC, GC, BC);
          end
        end
      end else
      begin
        ACanvas.Pen.Color := Group.BandColor;

        if Group.BandFullWidth then
        begin
          for i := 0 to Group.BandThickness - 1 do
          begin
            ACanvas.MoveTo(CellR.Left, RectArray.BandRect.Top + i);
            ACanvas.LineTo(CellR.Right, RectArray.BandRect.Top + i);
          end
        end else
        begin
          for i := 0 to Group.BandThickness - 1 do
          begin
            ACanvas.MoveTo(RectArray.BandRect.Left, RectArray.BandRect.Top + i);
            ACanvas.LineTo(RectArray.BandRect.Left + Group.BandLength, RectArray.BandRect.Top + i);
          end
        end
      end
    end else
    begin
      if (MarginEdge in [egmeRight]) and Group.BandBlended then
        ACanvas.Pen.Color := Group.BandColorFade
      else
        ACanvas.Pen.Color := Group.BandColor;

      if MarginEdge = egmeLeft then
      begin
        // Draw the horizontal stubs on the top and bottom
        for i := 0 to Group.BandThickness - 1 do
        begin
          ACanvas.MoveTo(RectArray.BandRect.Left + Group.BandRadius, RectArray.BandRect.Top + i);
          ACanvas.LineTo(RectArray.BandRect.Right + 1, RectArray.BandRect.Top + i)
        end;
         for i := 0 to Group.BandThickness - 1 do
        begin
          ACanvas.MoveTo(RectArray.BandRect.Left + Group.BandRadius, RectArray.BandRect.Bottom - i);
          ACanvas.LineTo(RectArray.BandRect.Right + 1, RectArray.BandRect.Bottom - i)
        end;
        for i := 0 to Group.BandThickness - 1 do
        begin
          ACanvas.MoveTo(RectArray.BandRect.Left + i, RectArray.BandRect.Top + Group.BandRadius);
          ACanvas.LineTo(RectArray.BandRect.Left + i, RectArray.BandRect.Bottom - Group.BandRadius + 1)
        end;
        for i := 0 to Group.BandThickness - 1 do
        begin
          ACanvas.MoveTo(RectArray.BandRect.Left + Group.BandRadius, RectArray.BandRect.Top);
          AngleArc(ACanvas.Handle,
                   RectArray.BandRect.Left + Group.BandRadius,
                   RectArray.BandRect.Top + Group.BandRadius,
                   Group.BandRadius - i,
                   90,
                   90);

          ACanvas.MoveTo(RectArray.BandRect.Left, RectArray.BandRect.Bottom - Group.BandRadius);
          AngleArc(ACanvas.Handle,
                   RectArray.BandRect.Left + Group.BandRadius,
                   RectArray.BandRect.Bottom - Group.BandRadius,
                   Group.BandRadius - i,
                   180,
                   90);
        end
      end else
      begin
        // Draw the horizontal stubs on the top and bottom
        for i := 0 to Group.BandThickness - 1 do
        begin
          ACanvas.MoveTo(RectArray.BandRect.Left, RectArray.BandRect.Top + i);
          ACanvas.LineTo(RectArray.BandRect.Right - Group.BandRadius + 1, RectArray.BandRect.Top + i)
        end;
         for i := 0 to Group.BandThickness - 1 do
        begin
          ACanvas.MoveTo(RectArray.BandRect.Left, RectArray.BandRect.Bottom - i);
          ACanvas.LineTo(RectArray.BandRect.Right - Group.BandRadius + 1, RectArray.BandRect.Bottom - i)
        end;
        for i := 0 to Group.BandThickness - 1 do
        begin
          ACanvas.MoveTo(RectArray.BandRect.Right - i, RectArray.BandRect.Top + Group.BandRadius);
          ACanvas.LineTo(RectArray.BandRect.Right - i, RectArray.BandRect.Bottom - Group.BandRadius + 1)
        end;
        for i := 0 to Group.BandThickness - 1 do
        begin
          ACanvas.MoveTo(RectArray.BandRect.Right, RectArray.BandRect.Top + Group.BandRadius);
          AngleArc(ACanvas.Handle,
                   RectArray.BandRect.Right - Group.BandRadius,
                   RectArray.BandRect.Top + Group.BandRadius,
                   Group.BandRadius - i,
                   0,
                   90);

          ACanvas.MoveTo(RectArray.BandRect.Right - Group.BandRadius, RectArray.BandRect.Bottom);
          AngleArc(ACanvas.Handle,
                   RectArray.BandRect.Right - Group.BandRadius,
                   RectArray.BandRect.Bottom - Group.BandRadius,
                   Group.BandRadius - i,
                   270,
                   90);
        end
      end
    end
  end
end;

procedure TEasyViewGroup.PaintBefore(Group: TEasyGroup; ACanvas: TCanvas;
  MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject);
begin
end;

procedure TEasyViewGroup.PaintCheckBox(Group: TEasyGroup; ACanvas: TCanvas;
  RectArray: TEasyRectArrayObject);
begin
  if not ((Group.CheckType = ectNone) or (Group.CheckType = ettNoneWithSpace)) then
    PaintCheckboxCore(Group.CheckType,       // TEasyCheckType
                      OwnerListview,        // TCustomEasyListview
                      ACanvas,              // TCanvas
                      RectArray.CheckRect,  // TRect
                      Group.Enabled,         // IsEnabled
                      Group.Checked,         // IsChecked
                      Group.CheckPending and (ebcsCheckboxClickPending in OwnerListview.States), // IsHot
                      Group.CheckFlat,       // IsFlat
                      Group.CheckHovering,   // IsHovering
                      Group.CheckPending,    // IsPending
                      Group,
                      Group.CheckSize);
end;

procedure TEasyViewGroup.PaintExpandButton(Group: TEasyGroup; ACanvas: TCanvas;
  MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject);
//
// Paints the [+] button for collapable groups
//
var
  Image, ExpandImage, CollapseImage: TBitmap;
  {$IFDEF USETHEMES}
  Part, uState: Longword;
  {$ENDIF}
begin
  if MarginEdge in [egmeTop] then
  begin
    GetCollapseExpandImages(ExpandImage, CollapseImage);

    {$IFDEF USETHEMES}
    if Group.OwnerListview.DrawWithThemes and not CustomExpandImages then
    begin
      Part := TVP_GLYPH;
      if Group.Expanded then
        uState := GLPS_OPENED
      else
        uState := GLPS_CLOSED;

      DrawThemeBackground(Group.OwnerListview.Themes.TreeviewTheme, ACanvas.Handle,
        Part, uState, RectArray.ExpandButtonRect, nil);
      Exit;
    end;
    {$ENDIF}

    // If the border is the header and it is expandable then must draw the
    // "+" expand box
    if Group.Expandable and (MarginEdge = egmeTop) then
    begin
      // Choose correct image
      if Group.Expanded then
        Image := CollapseImage
      else
        Image := ExpandImage;

      // Draw the image
      if Assigned(Image) then
        ACanvas.Draw(RectArray.ExpandButtonRect.Left + (RectWidth(RectArray.ExpandButtonRect) - Image.Width) div 2,
                     RectArray.ExpandButtonRect.Top + (RectHeight(RectArray.ExpandButtonRect) - Image.Height) div 2, Image);
    end
  end else
  begin
  end
end;

procedure TEasyViewGroup.PaintFocusRect(Group: TEasyGroup; ACanvas: TCanvas;
  MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject);
//
// Paint the caption area of a group margin for a focused state
//
var
  R: TRect;
begin
  if Group.Focused and (MarginEdge = egmeForeground) and not IsRectEmpty(RectArray.GroupRect) then
  begin
    R := RectArray.GroupRect;
    InflateRect(R, -4, -4);
    ACanvas.Brush.Color := Group.OwnerListview.Color;
    ACanvas.Font.Color := clBlack;
    DrawFocusRect(ACanvas.Handle, R);
  end
end;

procedure TEasyViewGroup.PaintImage(Group: TEasyGroup; ACanvas: TCanvas;
  MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject);
//
// Paints the Icon/Bitmap to the group margin
//
var
  ImageIndex, OverlayIndex, fStyle: Integer;
  Images: TImageList;
  IsCustom: Boolean;
begin
  if MarginEdge in [egmeTop, egmeBottom] then
  begin
    Group.ImageDrawIsCustom(nil, IsCustom);
    if IsCustom then
      Group.ImageDraw(nil, ACanvas, RectArray, AlphaBlender)
    else begin

      Images := GetImageList(Group);

      if MarginEdge = egmeTop then
      begin
        ImageIndex := Group.ImageIndex;
        OverlayIndex := Group.ImageOverlayIndex
      end else
      begin
        ImageIndex := Group.MarginBottom.ImageIndex;
        OverlayIndex := Group.MarginBottom.ImageOverlayIndex
      end;

      // Draw the image in the ImageList if available
      if Assigned(Images) and (Group.ImageIndex > -1) then
      begin
        fStyle := ILD_TRANSPARENT;

        if OverlayIndex > -1 then
        begin
          ImageList_SetOverlayImage(Images.Handle, OverlayIndex, 1);
          fStyle := fStyle or INDEXTOOVERLAYMASK(1)
        end;

        // Get the "normalized" rectangle for the image
        RectArray.IconRect.Left := RectArray.IconRect.Left + (RectWidth(RectArray.IconRect) - Images.Width) div 2;
        RectArray.IconRect.Top := RectArray.IconRect.Top + (RectHeight(RectArray.IconRect) - Images.Height) div 2;
        ImageList_DrawEx(Images.Handle,
          ImageIndex,
          ACanvas.Handle,
          RectArray.IconRect.Left,
          RectArray.IconRect.Top,
          0,
          0,
          CLR_NONE,
          CLR_NONE,
          fStyle);
      end
    end
  end
end;

procedure TEasyViewGroup.PaintSelectionRect(Group: TEasyGroup; ACanvas: TCanvas;
  ObjRect: TRect; RectArray: TEasyRectArrayObject);
//
// Paint the caption area of a group margin for a selected state
//
begin
  if Group.Selected and not IsRectEmpty(RectArray.TextRect) and (Group.Caption <> '') then
  begin
    ACanvas.Brush.Color := clHighlight;
    InflateRect(RectArray.TextRect, 2, 2);
    ACanvas.FillRect(RectArray.TextRect);
    InflateRect(RectArray.TextRect, 2, 2);
  end
end;

procedure TEasyViewGroup.PaintText(Group: TEasyGroup; MarginEdge: TEasyGroupMarginEdge;
  ACanvas: TCanvas; ObjRect: TRect; RectArray: TEasyRectArrayObject);
//
//  Paints the caption within the group margin
//
var
  DrawTextFlags: TCommonDrawTextWFlags;
  Caption: WideString;
  Alignment: TAlignment;
  VAlignment: TEasyVAlignment;
begin
  if not IsRectEmpty(RectArray.TextRect) and (Group.Caption <> '') then
  begin
    LoadTextFont(Group, ACanvas);

    if MarginEdge = egmeTop then
    begin
      Caption := Group.Caption;
      Alignment := Group.Alignment;
      VAlignment := Group.VAlignment;
    end else
    begin
      Caption := Group.MarginBottom.Caption;
      Alignment := Group.MarginBottom.Alignment;
      VAlignment := Group.MarginBottom.VAlignment;
    end;
    DrawTextFlags := [dtEndEllipsis];

 //   if PaintInfo.Caption.RTLReading then
 //     Include(DrawTextFlags, dtRTLReading);

    case Alignment of
      taLeftJustify: Include(DrawTextFlags, dtLeft);
      taRightJustify: Include(DrawTextFlags, dtRight);
      taCenter:  Include(DrawTextFlags, dtCenter);
    end;

    case VAlignment of
      evaTop: Include(DrawTextFlags, dtTop);
      evaCenter: Include(DrawTextFlags, dtVCenter);
      evaBottom:  Include(DrawTextFlags, dtBottom);
    end;

//    if PaintInfo.Caption.RTLReading then
//      Include(DrawTextFlags, dtRTLReading);

    DrawTextFlags := DrawTextFlags + [dtSingleLine];

    DrawTextWEx(ACanvas.Handle, Caption, RectArray.TextRect, DrawTextFlags, 1);
  end
end;

{ TEasyColumn }

constructor TEasyColumn.Create(ACollection: TEasyCollection);
begin
  inherited;
  FSortDirection := esdNone;
  FAutoToggleSort := True;
  FClickable := True;
  FWidth := 50;
  FPosition := OwnerColumns.Count;
  AutoSizeOnDblClk := True;
end;

destructor TEasyColumn.Destroy;
begin
  SetDestroyFlags;
  if OwnerListview.Selection.FFocusedColumn = Self then
     OwnerListview.Selection.FocusedColumn := nil;
  if OwnerListview.Header.HotTrackedColumn = Self then
    OwnerListview.Header.HotTrackedColumn := nil;
  if OwnerListview.EditManager.TabMoveFocusColumn = Self then
      OwnerListview.EditManager.TabMoveFocusColumn := nil;
  inherited Destroy;
end;

function TEasyColumn.CanChangeBold(NewValue: Boolean): Boolean;
begin
  Result := True
end;


function TEasyColumn.CanChangeCheck(NewValue: Boolean): Boolean;
begin
  Result := True;
  OwnerListview.DoColumnCheckChanging(Self, Result)
end;

function TEasyColumn.CanChangeEnable(NewValue: Boolean): Boolean;
begin
  Result := True;
  OwnerListview.DoColumnEnableChanging(Self, Result)
end;

function TEasyColumn.CanChangeFocus(NewValue: Boolean): Boolean;
begin
  Result := True;
  OwnerListview.DoColumnFocusChanging(Self, Result)
end;

function TEasyColumn.CanChangeHotTracking(NewValue: Boolean): Boolean;
begin
  Result := True;
end;

function TEasyColumn.CanChangeSelection(NewValue: Boolean): Boolean;
begin
  Result := True;
  OwnerListview.DoColumnSelectionChanging(Self, Result)
end;

function TEasyColumn.CanChangeVisibility(NewValue: Boolean): Boolean;
begin
  Result := True;
  OwnerListview.DoColumnVisibilityChanging(Self, Result)
end;

function TEasyColumn.DefaultImageList(ImageSize: TEasyImageSize): TImageList;
begin
  Result := OwnerListview.Header.Images
end;

function TEasyColumn.EditAreaHitPt(ViewportPoint: TPoint): Boolean;
begin
  Result := OwnerColumns.View.EditAreaHitPt(Self, ViewportPoint)
end;

function TEasyColumn.GetAlignment: TAlignment;
begin
  Result := FAlignment
end;

function TEasyColumn.GetColor: TColor;
begin
  Result := PaintInfo.Color
end;

function TEasyColumn.GetHotTrack: Boolean;
begin
  Result := PaintInfo.HotTrack
end;

function TEasyColumn.GetImagePosition: TEasyHeaderImagePosition;
begin
  Result := PaintInfo.ImagePosition
end;

function TEasyColumn.GetOwnerColumns: TEasyColumns;
begin
  Result := TEasyColumns(Collection)
end;

function TEasyColumn.GetOwnerHeader: TEasyHeader;
begin
  Result := OwnerListview.Header
end;

function TEasyColumn.GetPaintInfo: TEasyPaintInfoColumn;
begin
  Result := inherited PaintInfo as TEasyPaintInfoColumn
end;

function TEasyColumn.GetSortGlyphAlign: TEasySortGlyphAlign;
begin
  Result := PaintInfo.SortGlyphAlign
end;

function TEasyColumn.GetSortGlyphIndent: Integer;
begin
  Result := PaintInfo.SortGlyphIndent
end;

function TEasyColumn.GetStyle: TEasyHeaderButtonStyle;
begin
  Result := PaintInfo.Style
end;

function TEasyColumn.GetView: TEasyViewColumn;
begin
  if Assigned(OwnerColumns) then
    Result := OwnerColumns.View
  else
    Result := nil
end;

function TEasyColumn.LocalPaintInfo: TEasyPaintInfoBasic;
begin
  Result := OwnerListview.PaintInfoColumn
end;

function TEasyColumn.PaintMouseHovering: Boolean;
begin
  Result := (OwnerListview.Header.HotTrackedColumn = Self) and
      HotTrack and not (OwnerListview.DragManager.Dragging or
      OwnerListview.DragRect.Dragging)
end;

function TEasyColumn.SelectionHit(SelectViewportRect: TRect;
  SelectType: TEasySelectHitType): Boolean;
begin
  Result := OwnerColumns.View.SelectionHit(Self, SelectViewportRect, SelectType)
end;

function TEasyColumn.SelectionHitPt(ViewportPoint: TPoint;
  SelectType: TEasySelectHitType): Boolean;
begin
  Result := OwnerColumns.View.SelectionHitPt(Self, ViewportPoint, SelectType)
end;

procedure TEasyColumn.AutoSizeToFit;
var
  iIndex: Integer;
  W, i, j: Integer;
  Group: TEasyGroup;
  Canvas: TCanvas;
  Item: TEasyItem;
  Caption: WideString;
  Size: TSize;
  ImageW, ImageH: Integer;
begin
  iIndex := Index;
  Canvas := OwnerListview.Canvas;
  W := 0;
  for i := 0 to OwnerListview.Groups.Count - 1 do
    for j := 0 to OwnerListview.Groups[i].ItemCount - 1 do
    begin
      Group := OwnerListview.Groups[i];
      Item := Group.Items[j];
      Group.ItemView.LoadTextFont(Item, iIndex, Canvas, False);
      OwnerListview.DoItemPaintText(Item, Index, Canvas);
      Caption := Item.Captions[iIndex];
      Size := TextExtentW(Caption, Canvas);
      Size.cx := Size.cx + {2 * LABEL_MARGIN +} 8;

      Group.ItemView.GetImageSize(Item, Self, ImageW, ImageH);
      if ImageW > 0 then
        Size.cx := Size.cx + ImageW + ImageIndent;

      if CheckType <> ectNone then
        Size.cx := Size.cx + CheckIndent + RectWidth(Checks.Bound[CheckSize]);
      if Size.cx > W then
        W := Size.cx;
    end;
  Width := W;
end;

procedure TEasyColumn.Freeing;
begin
  OwnerListview.DoColumnFreeing(Self)
end;

procedure TEasyColumn.GainingBold;
begin
  Invalidate(False)
end;

procedure TEasyColumn.GainingCheck;
begin
  OwnerListview.DoColumnCheckChanged(Self)
end;

procedure TEasyColumn.GainingEnable;
begin
  OwnerListview.DoColumnEnableChanged(Self)
end;

procedure TEasyColumn.GainingFocus;
begin
  OwnerListview.DoColumnFocusChanged(Self)
end;

procedure TEasyColumn.GainingHilight;
begin
  // Unsupported
end;

procedure TEasyColumn.GainingHotTracking(MousePos: TPoint);
begin
  // Unsupported
end;

procedure TEasyColumn.GainingSelection;
begin
  OwnerListview.DoColumnSelectionChanged(Self)
end;

procedure TEasyColumn.GainingVisibility;
begin
  OwnerListview.BeginUpdate;
  OwnerListview.DoColumnVisibilityChanged(Self);
  OwnerListview.EndUpdate(False);
end;

function TEasyColumn.HitTestAt(ViewportPoint: TPoint; var HitInfo: TEasyColumnHitTestInfoSet): Boolean;
var
  RectArray: TEasyRectArrayObject;
  R: TRect;
begin
  HitInfo := [];
  if Assigned(View) then
  begin
    View.ItemRectArray(Self, RectArray);
    R := RectArray.IconRect;
    // Make the blank area between the image and text part of the image
    R.Right := R.Right + OwnerListview.PaintInfoColumn.CaptionIndent;
    if PtInRect(R, ViewportPoint) then
      Include(HitInfo, ectOnText);
    if PtInRect(RectArray.IconRect, ViewportPoint) then
      Include(HitInfo, ectOnIcon);
    if PtInRect(RectArray.CheckRect, ViewportPoint) then
      Include(HitInfo, ectOnCheckbox);
    if PtInRect(RectArray.LabelRect, ViewportPoint) then
      Include(HitInfo, ectOnLabel);
  end;
  Result := HitInfo <> [];
end;

procedure TEasyColumn.Initialize;
begin
  OwnerListview.DoColumnInitialize(Self)
end;

procedure TEasyColumn.Invalidate(ImmediateUpdate: Boolean);
var
  R: TRect;
begin
  if OwnerListview.UpdateCount = 0 then
  begin
    if OwnerListview.HandleAllocated then
    begin
      R := Rect(0, 0, OwnerListview.ClientWidth, OwnerHeader.Height);
      OwnerListview.SafeInvalidateRect(@R, ImmediateUpdate);
    end
  end
end;

procedure TEasyColumn.LoadFromStream(S: TStream; Version: Integer = STREAM_VERSION);
begin
  inherited LoadFromStream(S);
  S.ReadBuffer(FAlignment, SizeOf(FAlignment));
  S.ReadBuffer(FAutoSizeOnDblClk, SizeOf(FAutoSizeOnDblClk));
  S.ReadBuffer(FAutoSpring, SizeOf(FAutoSpring));
  S.ReadBuffer(FAutoToggleSort, SizeOf(FAutoToggleSort));
  S.ReadBuffer(FPosition, SizeOf(FPosition));
  S.ReadBuffer(FSortDirection, SizeOf(FSortDirection));
  S.ReadBuffer(FStyle, SizeOf(FStyle));
  S.ReadBuffer(FClickable, SizeOf(FClickable));
  S.ReadBuffer(FWidth, SizeOf(FWidth));
  OwnerListview.DoColumnLoadFromStream(Self, S, Version)
end;

procedure TEasyColumn.LosingBold;
begin
  Invalidate(False)
end;

procedure TEasyColumn.LosingCheck;
begin
  OwnerListview.DoColumnCheckChanged(Self)
end;

procedure TEasyColumn.LosingEnable;
begin
  OwnerListview.DoColumnEnableChanged(Self)
end;

procedure TEasyColumn.LosingFocus;
begin
  OwnerListview.DoColumnFocusChanged(Self)
end;

procedure TEasyColumn.LosingHilight;
begin
  // Unsupported
end;

procedure TEasyColumn.LosingHotTracking;
begin
  // Unsupported
end;

procedure TEasyColumn.LosingSelection;
begin
  OwnerListview.DoColumnSelectionChanged(Self)
end;

procedure TEasyColumn.LosingVisibility;
begin
  OwnerListview.BeginUpdate;
  OwnerListview.DoColumnVisibilityChanged(Self);
  OwnerListview.EndUpdate(False);
end;

procedure TEasyColumn.MakeVisible(Position: TEasyMakeVisiblePos);
var
  RectArray: TEasyRectArrayObject;
  ViewRect: TRect;
  ColumnW, ViewW: Integer;
begin
  if Visible then
  begin
    View.ItemRectArray(Self, RectArray);
    ViewRect := OwnerListview.ClientInViewportCoords;
    ColumnW := RectArray.BoundsRect.Right - RectArray.BoundsRect.Left;
    ViewW := RectWidth(ViewRect);
    if not ((RectArray.BoundsRect.Left >= ViewRect.Left) and ( RectArray.BoundsRect.Right <= ViewRect.Right)) then
    begin
      case Position of
        emvTop:     // or Left
          begin
            if ViewRect.Left < RectArray.BoundsRect.Left then
              OwnerListview.Scrollbars.OffsetX := RectArray.BoundsRect.Left;
          end;
        emvMiddle:
          begin
            if ColumnW < ViewW then
            OwnerListview.Scrollbars.OffsetX := RectArray.BoundsRect.Left - ((ViewW - ColumnW) div 2);
          end;
        emvBottom:  // or right
          begin
            OwnerListview.Scrollbars.OffsetX := RectArray.BoundsRect.Right - ColumnW;
          end;
        emvAuto:
          begin
            if ViewRect.Left < RectArray.BoundsRect.Left then
              OwnerListview.Scrollbars.OffsetX := RectArray.BoundsRect.Left;
          end
      end
    end
  end
end;

procedure TEasyColumn.Paint(ACanvas: TCanvas; HeaderType: TEasyHeaderType);
begin
  OwnerColumns.View.Paint(Self, ACanvas, HeaderType)
end;

procedure TEasyColumn.SaveToStream(S: TStream; Version: Integer = STREAM_VERSION);
begin
  inherited SaveToStream(S);
  S.WriteBuffer(FAlignment, SizeOf(FAlignment));
  S.WriteBuffer(FAutoSizeOnDblClk, SizeOf(FAutoSizeOnDblClk));
  S.WriteBuffer(FAutoSpring, SizeOf(FAutoSpring));
  S.WriteBuffer(FAutoToggleSort, SizeOf(FAutoToggleSort));
  S.WriteBuffer(FPosition, SizeOf(FPosition));
  S.WriteBuffer(FSortDirection, SizeOf(FSortDirection));
  S.WriteBuffer(FStyle, SizeOf(FStyle));
  S.WriteBuffer(FClickable, SizeOf(FClickable));
  S.WriteBuffer(FWidth, SizeOf(FWidth));
  OwnerListview.DoColumnSaveToStream(Self, S)
end;

procedure TEasyColumn.SetAlignment(Value: TAlignment);
begin
  if Value <> FAlignment then
  begin
    FAlignment := Value;
    Invalidate(False);
  end
end;

procedure TEasyColumn.SetAutoSpring(const Value: Boolean);
begin
  FAutoSpring := Value;
end;

procedure TEasyColumn.SetColor(Value: TColor);
begin
  PaintInfo.Color := Value
end;

procedure TEasyColumn.SetHotTrack(Value: Boolean);
begin
  PaintInfo.HotTrack := Value
end;

procedure TEasyColumn.SetImagePosition(Value: TEasyHeaderImagePosition);
begin
  PaintInfo.ImagePosition := Value
end;

procedure TEasyColumn.SetPaintInfo(Value: TEasyPaintInfoColumn);
begin
  inherited PaintInfo := Value
end;

procedure TEasyColumn.SetPosition(Value: Integer);
var
  OldPos, i: Integer;
begin
  if Value > OwnerColumns.Count - 1 then
    Value := OwnerColumns.Count - 1
  else
  if Value < 0 then
    Value := 0;

  if OwnerColumns.Count = 1 then
    FPosition := 0
  else begin
    if Value <> FPosition then
    begin
      OldPos := FPosition;
      if Value > OldPos then
      begin
        for i := 0 to OwnerColumns.Count - 1 do
        begin
          if (OwnerColumns[i].FPosition >= OldPos) and (OwnerColumns[i].FPosition <= Value) then
            Dec(OwnerColumns[i].FPosition)
        end
      end else
      begin
        for i := 0 to OwnerColumns.Count - 1 do
        begin
          if (OwnerColumns[i].FPosition >= Value) and (OwnerColumns[i].FPosition <= OldPos) then
            Inc(OwnerColumns[i].FPosition)
        end
      end;     
      FPosition := Value;
    end;
    OwnerHeader.Rebuild(False);
    OwnerHeader.Invalidate(False)
  end
end;

procedure TEasyColumn.SetSortDirection(Value: TEasySortDirection);
begin
  if Value <> FSortDirection then
  begin
    FSortDirection := Value;
    OwnerHeader.Invalidate(False);
    if FSortDirection <> esdNone then
    begin
      OwnerListview.Selection.FocusedColumn := Self;
      if OwnerListview.Sort.AutoSort then
        OwnerListview.Sort.SortAll 
    end
  end
end;

procedure TEasyColumn.SetSortGlpyhAlign(Value: TEasySortGlyphAlign);
begin
  PaintInfo.SortGlyphAlign := Value
end;

procedure TEasyColumn.SetSortGlyphIndent(Value: Integer);
begin
  PaintInfo.SortGlyphIndent := Value
end;

procedure TEasyColumn.SetStyle(Value: TEasyHeaderButtonStyle);
begin
  if FStyle <> Value then
  begin
    FStyle := Value;
    Invalidate(False)
  end
end;

procedure TEasyColumn.SetWidth(Value: Integer);
begin
  if FWidth <> Value then
  begin
    if Value < 0 then
      Value := 0;
    FWidth := Value;
    OwnerHeader.Rebuild(False);
    OwnerListview.Invalidate
  end
end;

{ TEasyEditManager }

function TEasyEditManager.GetEditing: Boolean;
begin
  Result := FEditing or Assigned(TabMoveFocusItem);
end;

procedure TEasyEditManager.BeginEdit(Item: TEasyItem; Column: TEasyColumn);
//
// Starts an editor within the passed Item
// We create a local message loop and break out of it when any of the normal
// conditions are met to stop the edit, such as: Hitting the Escape key,
// scrolling with the wheel, clicking out side of the editor and switching
// away from the application.
//
var
  Msg: TMSG;
  Pt: TPoint;
  Allow, Dispatch, EditDone: Boolean;
  NCHit: Longword;
  OldFocus: TWinControl;
  iColumn: Integer;

    procedure FinishEdit;
    begin
      if not EditDone then
      begin
        Editor.Hide;
        FEditing := False;
        OwnerListview.DoItemEditEnd(Item);
        Editor.Finalize;
        FEditItem := nil;
        FEditFinished := True;
        EditDone := True
      end
    end;

    function TestAcceptEdit: Boolean;
    begin
      Result := Editor.AcceptEdit;
      if not Result then
        Editor.SetEditorFocus
    end;

begin
  if not Editing then
  begin
    EditDone := False;
    FEditFinished := False;
    if Assigned(Item) and Enabled then
    begin
      Item.MakeVisible(emvAuto);
      FEditItem := Item;
      Application.HookMainWindow(MainWindowHook);
      Allow := True;
      if Assigned(Column) then
        iColumn := Column.Index
      else
        iColumn := 0;
      OwnerListview.DoItemEditBegin(Item, iColumn, Allow);
      if (OwnerListview.View = elsReport) and (iColumn < OwnerListview.Header.Columns.Count) then
      begin
        OwnerListview.Header.Columns[iColumn].MakeVisible(emvAuto);
      end else
        iColumn := 0;
      EditColumn := OwnerListview.Header.Columns[iColumn];
      if Allow then
      begin
        Editor := nil;
        OwnerListview.DoItemCreateEditor(Item, FEditor);
        if Assigned(Editor) then
        begin
          OldFocus := Screen.ActiveControl;
          Editor.Initialize(Item, EditColumn);
          FEditing := True;
          Item.Invalidate(True);
          Editor.Show;
          Editor.SetEditorFocus;
          try
            while not FEditFinished do
            begin
              GetMessage(Msg, 0, 0, 0);

              Dispatch := True;

              if not FEditFinished then
              begin
                if Msg.message = WM_KEYDOWN then
                begin
                  if Msg.wParam = VK_ESCAPE then
                    FinishEdit
                end
              end;

              // Need to pass the tab to the lsitview if TabMoveFocus is enabled
              if Msg.message = WM_KEYDOWN then
              begin
                if (Msg.wParam = VK_TAB) and OwnerListview.EditManager.TabMoveFocus then
                begin
                  if TestAcceptEdit then
                  begin
                    if GetAsyncKeyState(VK_CONTROL) and $8000 <> 0 then
                    begin
                      if OwnerListview.EditManager.TabEditColumns then
                      begin
                        OwnerListview.EditManager.TabMoveFocusColumn := OwnerListview.Header.PrevVisibleColumn(EditColumn);
                        // Stay on the same item if there is another column
                        if Assigned(OwnerListview.EditManager.TabMoveFocusColumn) then
                          OwnerListview.EditManager.TabMoveFocusItem := OwnerListview.EditManager.EditItem
                        else begin
                          OwnerListview.EditManager.TabMoveFocusItem := OwnerListview.Groups.PrevEditableItem(OwnerListview.EditManager.EditItem);
                          OwnerListview.EditManager.TabMoveFocusColumn := OwnerListview.Header.LastColumn;
                        end
                      end else
                        OwnerListview.EditManager.TabMoveFocusItem := OwnerListview.Groups.PrevEditableItem(OwnerListview.EditManager.EditItem);
                    end else
                    begin
                      if OwnerListview.EditManager.TabEditColumns then
                      begin
                        OwnerListview.EditManager.TabMoveFocusColumn := OwnerListview.Header.NextVisibleColumn(EditColumn);
                        // Stay on the same item if there is another column
                        if Assigned(OwnerListview.EditManager.TabMoveFocusColumn) then
                          OwnerListview.EditManager.TabMoveFocusItem := OwnerListview.EditManager.EditItem
                        else
                          OwnerListview.EditManager.TabMoveFocusItem := OwnerListview.Groups.NextEditableItem(OwnerListview.EditManager.EditItem);
                      end else
                        OwnerListview.EditManager.TabMoveFocusItem := OwnerListview.Groups.NextEditableItem(OwnerListview.EditManager.EditItem);
                    end;
                    EndEdit;
                    PostMessage(OwnerListview.Handle, WM_TABMOVEFOCUS, 0, 0);
                    Dispatch := False;
                  end
                end
              end;

              if not FEditFinished then
              if (Msg.message = WM_LBUTTONDOWN) or
                 (Msg.message = WM_MBUTTONDOWN) or
                 (Msg.message = WM_RBUTTONDOWN) then
              begin
                Pt := SmallPointToPoint(TSmallPoint(Msg.lParam));
                ClientToScreen(Msg.hwnd, Pt);
                ScreenToClient(OwnerListview.Handle, Pt);
                if not Editor.PtInEditControl(Pt) then
                begin
                  Dispatch := False;
                  if TestAcceptEdit then
                  begin
                    FinishEdit;
                    if not PtInRect(OwnerListview.ClientRect, Pt) then
                      Dispatch := True
                  end
                end;
              end;

              if not FEditFinished then
              begin
                if (Msg.message = WM_MOUSEWHEEL) or
                   (Msg.message = CM_MOUSEWHEEL) then
                begin
                  FinishEdit
                end
              end;

              if not FEditFinished then
              if (Msg.message = WM_NCLBUTTONDOWN) or
                 (Msg.message = WM_NCMBUTTONDOWN) or
                 (Msg.message = WM_NCRBUTTONDOWN) then
              begin
                NCHit := SendMessage(Msg.hWnd, WM_NCHITTEST, Msg.wParam, Msg.lParam);
                if not (NCHit = HTCAPTION) then
                begin
                   FinishEdit;
                end
              end;

              if not FEditFinished then
              begin
                if (Msg.message = WM_HOOKAPPACTIVATE) then
                begin
                  FinishEdit
                end
              end;

              if Dispatch then
              begin
                TranslateMessage(Msg);
                DispatchMessage(Msg);
              end;
            end
          finally
            Application.UnhookMainWindow(MainWindowHook);
            FinishEdit;
            OldFocus.SetFocus;
            Editor := nil;
            EditColumn := nil;
          end
        end;
      end
    end
  end;
end;

constructor TEasyEditManager.Create(AnOwner: TCustomEasyListview);
begin
  inherited;
  AutoEditDelayTime := 300;
end;

destructor TEasyEditManager.Destroy;
begin
  inherited;
end;

procedure TEasyEditManager.EndEdit;
//
// Flags the Edit Manager to stop editing.  The local message loop in BeginEdit
// alway polls this flag to quit
//
begin
  FEditFinished := True
end;

function TEasyEditManager.MainWindowHook(var Message: TMessage): Boolean;
//
// Need to hook the Main so we can end the edit if the application is switched
// away from
//
begin
  Result := False;
  if (Message.Msg = WM_ACTIVATEAPP) then
    PostMessage(OwnerListview.Handle, WM_HOOKAPPACTIVATE, 0, 0)
end;

procedure TEasyEditManager.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
  EndEdit;
end;

procedure TEasyEditManager.StartAutoEditTimer;
//
// Starts the AutoEditTimer, the timer will be cancelled if the user moves the
// mouse a specified distance before the timer elapses
//
begin
  StopAutoEditTimer;
  if Enabled then
  begin 
    Timer := TTimer.Create(nil);
    Timer.OnTimer := TimerEvent;
    Timer.Interval := AutoEditDelayTime;
    Timer.Enabled := True;
    FTimerRunning := True
  end
end;

procedure TEasyEditManager.TimerEvent(Sender: TObject);
//
// The Timer Event method.  If called the Focused Item will be edited.
//
begin
  StopAutoEditTimer;
  if Assigned(OwnerListview.Selection.FocusedItem) then
    BeginEdit(OwnerListview.Selection.FocusedItem as TEasyItem, nil)
end;

procedure TEasyEditManager.StopAutoEditTimer;
//
// Shuts down the AutoEditTimer
//
begin
  if TimerRunning then
  begin
    if Assigned(Timer) then
      FreeAndNil(FTimer);
    FTimerRunning := False
  end
end;

{ TEasyEnumFormatEtcManager }

function TEasyEnumFormatEtcManager.Clone(out Enum: IEnumFormatEtc): HResult;
// Creates a exact copy of the current object.
var
  EnumFormatEtc: TEasyEnumFormatEtcManager;
begin
  Result := S_OK;                              // Think positive
  EnumFormatEtc := TEasyEnumFormatEtcManager.Create;      // Does not increase COM reference
  if Assigned(EnumFormatEtc) then
  begin
    SetLength(EnumFormatEtc.FFormats, Length(Formats));

    // Make copy of Format info
    Move(FFormats[0], EnumFormatEtc.FFormats[0], Length(Formats) * SizeOf(TFormatEtc));

    // Set COM reference to 1
    Enum := EnumFormatEtc as IEnumFormatEtc;
  end else
    Result := E_UNEXPECTED
end;

constructor TEasyEnumFormatEtcManager.Create;
begin
  inherited Create;
  InternalIndex := 0;
end;

destructor TEasyEnumFormatEtcManager.Destroy;
begin
  inherited;
end;

function TEasyEnumFormatEtcManager.Next(celt: Integer; out elt;
  pceltFetched: PLongint): HResult;
// Another EnumXXXX function.  This function returns the number of objects
// requested by the caller in celt.  The return buffer, elt, is a pointer to an}
// array of, in this case, TFormatEtc structures.  The total number of
// structures returned is placed in pceltFetched.  pceltFetched may be nil if
// celt is only asking for one structure at a time.
var
  i: integer;
begin
  if Assigned(Formats) then
  begin
    i := 0;
    while (i < celt) and (InternalIndex < Length(Formats)) do
    begin
      TeltArray( elt)[i] := Formats[InternalIndex];
      inc(i);
      inc(FInternalIndex);
    end; // while
    if assigned(pceltFetched) then
      pceltFetched^ := i;
    if i = celt then
      Result := S_OK
    else
      Result := S_FALSE
  end else
    Result := E_UNEXPECTED
end;

function TEasyEnumFormatEtcManager.Reset: HResult;
begin
  InternalIndex := 0;
  Result := S_OK
end;

function TEasyEnumFormatEtcManager.Skip(celt: Integer): HResult;
// Allows the caller to skip over unwanted TFormatEtc structures.  Simply adds
// celt to the index as long as it does not skip past the last structure in
// the list.
begin
  if Assigned(Formats) then
  begin
    if InternalIndex + celt < Length(Formats) then
    begin
      InternalIndex := InternalIndex + celt;
      Result := S_OK
    end else
      Result := S_FALSE
  end else
    Result := E_UNEXPECTED
end;

{ TEasyDataObjectManager }

destructor TEasyDataObjectManager.Destroy;
begin
  inherited Destroy;
end;

function TEasyDataObjectManager.AssignDragImage(Image: TBitmap;
  HotSpot: TPoint; TransparentColor: TColor): Boolean;
//
// Stores the Bitmap in the IDataObject to support the IDragSourceHelper drag image
// in Win2K and above.
//
var
  DragSourceHelper: IDragSourceHelper;
  SHDragImage: TSHDragImage;
begin
  Result := False;
  // NT can't swallow this CoCreateInstance call
  if not IsWinNT4 then
  begin
    if Succeeded(CoCreateInstance(CLSID_DragDropHelper, nil, CLSCTX_INPROC_SERVER, IID_IDragSourceHelper, DragSourceHelper)) then
    begin
      FillChar(SHDragImage, SizeOf(SHDragImage), #0);

      SHDragImage.sizeDragImage.cx := Image.Width;
      SHDragImage.sizeDragImage.cy := Image.Height;
      SHDragImage.ptOffset := HotSpot;
      SHDragImage.ColorRef := ColorToRGB(TransparentColor);
      SHDragImage.hbmpDragImage := CopyImage(Image.Handle, IMAGE_BITMAP, Image.Width,
        Image.Height, LR_COPYRETURNORG);
      if SHDragImage.hbmpDragImage <> 0 then
        if Succeeded(DragSourceHelper.InitializeFromBitmap(SHDragImage, Self as IDataObject)) then
          Result := True
        else
          DeleteObject(SHDragImage.hbmpDragImage);
    end
  end
end;

function TEasyDataObjectManager.CanonicalIUnknown(TestUnknown: IUnknown): IUnknown;
//
// Uses COM object identity: An explicit call to the IUnknown::QueryInterface
// method, requesting the IUnknown interface, will always return the same
// pointer.
//
begin
  if Assigned(TestUnknown) then
  begin
    if CommonSupports(TestUnknown, IUnknown, Result) then
      IUnknown(Result)._Release // Don't actually need it just need the pointer value
    else
      Result := TestUnknown
  end else
    Result := TestUnknown
end;

function TEasyDataObjectManager.DAdvise(const formatetc: TFormatEtc;
  advf: Integer; const advSink: IAdviseSink;
  out dwConnection: Integer): HResult;
//
// Called when a client wants to register itself to be notified when something
// has changed within the IDataObject
//
begin
  if not Assigned(AdviseHolder) then
    CreateDataAdviseHolder(FAdviseHolder);
  if Assigned(FAdviseHolder) then
    Result := AdviseHolder.Advise(Self as IDataObject, formatetc, advf, advSink, dwConnection)
  else
    Result := OLE_E_ADVISENOTSUPPORTED;
end;

function TEasyDataObjectManager.DUnadvise(dwConnection: Integer): HResult;
//
// Called when a client wants to unregister itself from being notified when
// something changes in the IDataObject
//
begin
  if Assigned(AdviseHolder) then
    Result := AdviseHolder.Unadvise(dwConnection)
  else
    Result := OLE_E_ADVISENOTSUPPORTED;
end;

function TEasyDataObjectManager.EnumDAdvise(out enumAdvise: IEnumStatData): HResult;
//
// Enumerates all clients that are registered to be advised of changes in the
// IDataObject
//
begin
  if Assigned(AdviseHolder) then
    Result := AdviseHolder.EnumAdvise(enumAdvise)
  else
    Result := OLE_E_ADVISENOTSUPPORTED;
end;

function TEasyDataObjectManager.EnumFormatEtc(dwDirection: Integer;
  out enumFormatEtc: IEnumFormatEtc): HResult;
//
// Called when DoDragDrop wants to know what clipboard formats are supported
// by Enumerating the TFormatEtc array through an IEnumFormatEtc object.
//
var
  LocalEnumFormatEtc: TEasyEnumFormatEtcManager;
  i: integer;
begin
  if dwDirection = DATADIR_GET then
  begin
    // Return an interface even if we don't fill it.  Need it for
    // the Explorer version of ELV
    Result := S_OK;
    LocalEnumFormatEtc := TEasyEnumFormatEtcManager.Create;

    // Copy the internal supported Formats for the EnumFormatEtc
    SetLength(LocalEnumFormatEtc.FFormats, Length(Formats));
    for i := 0 to Length(Formats) - 1 do
      LocalEnumFormatEtc.Formats[i] := Formats[i].FormatEtc;

    // Now copy any custom formats
    DoGetCustomFormats(LocalEnumFormatEtc.FFormats);

    // Get the reference count in sync
    enumFormatEtc := LocalEnumFormatEtc as IEnumFormatEtc;
    if not Assigned(enumFormatEtc) then
      Result := E_OUTOFMEMORY
  end else
  begin
    enumFormatEtc := nil;
    Result := E_NOTIMPL;
  end;
end;

function TEasyDataObjectManager.EqualFormatEtc(FormatEtc1,
  FormatEtc2: TFormatEtc): Boolean;
//
// Checks the two FormatEtc structures and decides if they are the same clipboard
// format.
//
begin
  Result := (FormatEtc1.cfFormat = FormatEtc2.cfFormat) and
            (FormatEtc1.ptd = FormatEtc2.ptd) and
            (FormatEtc1.dwAspect = FormatEtc2.dwAspect) and
            (FormatEtc1.lindex = FormatEtc2.lindex) and
            (FormatEtc1.tymed = FormatEtc2.tymed)
end;

function TEasyDataObjectManager.FindFormatEtc(TestFormatEtc: TFormatEtc): integer;
//
// Searches for the index of a Format in the internal Format list that matches the
// passed TestFormatEtc.  It returns the index of the format in the internal list
//
var
  i: integer;
  Found: Boolean;
begin
  i := 0;
  Found := False;
  Result := -1;
  while (i < Length(FFormats)) and not Found do
  begin
    Found := EqualFormatEtc(Formats[i].FormatEtc, TestFormatEtc);
    if Found then
      Result := i;
    Inc(i);
  end
end;

function TEasyDataObjectManager.GetCanonicalFormatEtc(
  const formatetc: TFormatEtc; out formatetcOut: TFormatEtc): HResult;
//
// If an IDataObject supports more than one format type for the same data this
// method resolves which is the "Cononical Format".  Currently not supported in
// this implementation
//
begin
  formatetcOut.ptd := nil;
  Result := E_NOTIMPL;
end;

function TEasyDataObjectManager.GetData(const FormatEtcIn: TFormatEtc;
  out Medium: TStgMedium): HResult;
//
// This is the workhorse of the functions.  It looks at the clipboard format
// the IDropTarget wants, makes sure we can support it.  If supported then see
// if it is owned by the object or the program will supply the data.
//
var
  Handled: Boolean;
begin
  Result := E_UNEXPECTED;
  Handled := False;
  if Assigned(Owner) then
    Owner.DoOLEGetData(FormatEtcIn, Medium, Handled);
  if not Handled then
  begin
  if Assigned(Formats) then
    begin
      { Do we support this type of Data internally? }
      Result := QueryGetData(FormatEtcIn);
      if Result = S_OK then
      begin
        // If the data is owned by the IDataObject just retrieve and return it.
        if RetrieveOwnedStgMedium(FormatEtcIn, Medium) = E_INVALIDARG then
          Result := E_UNEXPECTED
      end
    end
  end else
    Result := S_OK
end;

function TEasyDataObjectManager.GetDataHere(const formatetc: TFormatEtc;
  out medium: TStgMedium): HResult;
begin
  Result := E_NOTIMPL;
end;

function TEasyDataObjectManager.HGlobalClone(HGlobal: THandle): THandle;
//
// Returns a global memory block that is a copy of the passed memory block.
//
var
  Size: LongWord;
  Data, NewData: PChar;
begin
  Size := GlobalSize(HGlobal);
  Result := GlobalAlloc(GPTR, Size);
  Data := GlobalLock(hGlobal);
  try
    NewData := GlobalLock(Result);
    try
      Move(Data, NewData, Size);
    finally
      GlobalUnLock(Result);
    end
  finally
    GlobalUnLock(hGlobal)
  end
end;


function TEasyDataObjectManager.QueryGetData(const formatetc: TFormatEtc): HResult;
//
// This function allows the IDragTarget to see if we can possibly support some
// type of data transfer.
//
var
  i: integer;
  FormatAvailable, Handled: Boolean;
begin
  Handled := False;
  FormatAvailable := False;
  if Assigned(Owner) then
    Owner.DoQueryOLEData(FormatEtc, FormatAvailable, Handled);
  if Handled then
  begin
    // The event handled the call so return its reply to the caller
    if FormatAvailable then
      Result := S_OK
    else
      Result := DV_E_FORMATETC
  end else
  begin
    if Assigned(Formats) then
    begin
      // The event did not handle the call so see if we can handle it from our
      // internal formats
      i := 0;
      Result := DV_E_FORMATETC;
      while (i < Length(Formats)) and (Result = DV_E_FORMATETC)  do
      begin
        if Formats[i].FormatEtc.cfFormat = formatetc.cfFormat then
        begin
          if (Formats[i].FormatEtc.dwAspect = formatetc.dwAspect) then
          begin
            if (Formats[i].FormatEtc.tymed and formatetc.tymed <> 0) then
              Result := S_OK
            else
              Result := DV_E_TYMED;
          end else
            Result := DV_E_DVASPECT;
        end else
          Result := DV_E_FORMATETC;
        Inc(i)
      end
    end else
      Result := E_UNEXPECTED;
  end
end;

function TEasyDataObjectManager.RetrieveOwnedStgMedium(Format: TFormatEtc;
  var StgMedium: TStgMedium): HRESULT;
//
// Retrieves the Data from any internally stored Format that the object may
// contain (usually from a call to SetData)
//
var
  i: integer;
begin
  Result := E_INVALIDARG;
  i := FindFormatEtc(Format);
  if (i > -1) and Formats[i].OwnedByDataObject then
    Result := StgMediumIncRef(Formats[i].StgMedium, StgMedium, False)
end;

function TEasyDataObjectManager.SetData(const formatetc: TFormatEtc;
  var medium: TStgMedium; fRelease: BOOL): HResult;
//
// Allows dynamic adding of data to the IDataObject during its existance.  Most noteably
// it is used to implement IDropSourceHelper in Win2k and up
//
var
  Index: integer;
begin
  // See if we already have a format of that type available.
  Index := FindFormatEtc(FormatEtc);
  if Index > - 1 then
  begin
    // Yes we already have that format type stored.  Just use the TClipboardFormat
    // in the List after releasing the data
    ReleaseStgMedium(Formats[Index].StgMedium);
    FillChar(Formats[Index].StgMedium, SizeOf(Formats[Index].StgMedium), #0);
  end else
  begin
    // It is a new format so create a new TDataObjectInfo record and store it in
    // the Format array
    SetLength(FFormats, Length(Formats) + 1);
    Formats[Length(Formats) - 1].FormatEtc := FormatEtc;
    Index := Length(Formats) - 1;
  end;
  // The data is owned by the TClipboardFormat object
  Formats[Index].OwnedByDataObject := True;

  if fRelease then
  begin
    // We are simply being given the data and we take control of it.
    Formats[Index].StgMedium := Medium;
    Result := S_OK
  end else
    // We need to reference count or copy the data and keep our own references
    // to it.
    Result := StgMediumIncRef(Medium, Formats[Index].StgMedium, True);

    // Can get a circular reference if the client calls GetData then calls
    // SetData with the same StgMedium.  Because the unkForRelease and for
    // the IDataObject can be marshalled it is necessary to get pointers that
    // can be correctly compared.
    // See the IDragSourceHelper article by Raymond Chen at MSDN.
    if Assigned(Formats[Index].StgMedium.unkForRelease) then
    begin
      if CanonicalIUnknown(Self) =
        CanonicalIUnknown(IUnknown( Formats[Index].StgMedium.unkForRelease)) then
      begin
        IUnknown( Formats[Index].StgMedium.unkForRelease)._Release;
        Formats[Index].StgMedium.unkForRelease := nil
      end;
    end;
  // Tell all registered advice sinks about the data change.
  if Assigned(AdviseHolder) then
    AdviseHolder.SendOnDataChange(Self as IDataObject, 0, 0);
end;

function TEasyDataObjectManager.StgMediumIncRef(
  const InStgMedium: TStgMedium; var OutStgMedium: TStgMedium;
  CopyInMedium: Boolean): HRESULT;
//
// This function increases the reference count of the passed StorageMedium in a
// variety of ways depending on the value of CopyInMedium.
// InStgMedium is the data that is requested a copy of, OutStgMedium is the data that
// we are to return either a copy of or increase the IDataObject's reference and
// send ourselves back as the data (unkForRelease). The InStgMedium is usually
// the result of a call to find a particular FormatEtc that has been stored
// locally through a call to SetData.     If CopyInMedium is not true we
// already have a local copy of the data when the SetData function was called
// (during that call the CopyInMedium must be true).  Then as the caller asks
// for the data through GetData we do not have to make copy of the data for the
// caller only to have them destroy it then need us to copy it again if
// necessary.  This way we increase the reference count to ourselves and pass
// the STGMEDIUM structure initially stored in SetData.  This way when the
// caller frees the structure it sees the unkForRelease is not nil and calls
// Release on the object instead of destroying the actual data.
//
begin
  Result := S_OK;
  // Simply copy all fields to start with.
  OutStgMedium := InStgMedium;
  case InStgMedium.tymed of
    TYMED_HGLOBAL:
      begin
        if CopyInMedium then
        begin
          // Generate a unique copy of the data passed
          OutStgMedium.hGlobal := HGlobalClone(InStgMedium.hGlobal);
          if OutStgMedium.hGlobal = 0 then
            Result := E_OUTOFMEMORY
        end else
          // Don't generate a copy just use ourselves and the copy previoiusly saved
          OutStgMedium.unkForRelease := Pointer(Self as IDataObject) // Does increase RefCount
      end;
    TYMED_FILE:
      begin
        if CopyInMedium then
        begin
          OutStgMedium.lpszFileName := CoTaskMemAlloc(lstrLenW(InStgMedium.lpszFileName));
          StrCopyW(PWideChar(OutStgMedium.lpszFileName), PWideChar(InStgMedium.lpszFileName))
        end else
          OutStgMedium.unkForRelease := Pointer(Self as IDataObject) // Does increase RefCount
      end;
    TYMED_ISTREAM:
      // Simply increase the reference to the stream object
      // Note here stm is a pointer so the auto reference counting won't work and
      // we have to call _AddRef explicitly
      IUnknown( OutStgMedium.stm)._AddRef;
    TYMED_ISTORAGE:
      // Simply increase the reference to the storage object
      // Note here stm is a pointer so the auto reference counting won't work and
      // we have to call _AddRef explicitly
      IUnknown( OutStgMedium.stg)._AddRef;
    TYMED_GDI:
      if not CopyInMedium then
      // Don't generate a copy just use ourselves and the copy previoiusly saved data
        OutStgMedium.unkForRelease := Pointer(Self as IDataObject) // Does not increase RefCount
     else
       Result := DV_E_TYMED; // Don't know how to copy GDI objects right now
    TYMED_MFPICT:
      if not CopyInMedium then
        OutStgMedium.unkForRelease := Pointer(Self as IDataObject) // Does not increase RefCount
      else
        Result := DV_E_TYMED; // Don't know how to copy MetaFile objects right now
    TYMED_ENHMF:
      if not CopyInMedium then
        { Don't generate a copy just use ourselves and the copy previoiusly saved data }
        OutStgMedium.unkForRelease := Pointer(Self as IDataObject) // Does not increase RefCount
      else
        Result := DV_E_TYMED; // Don't know how to copy enhanced metafiles objects right now
  else
    Result := DV_E_TYMED
  end;

  // I still have to do this. The Compiler will call _Release on the above Self as IDataObject
  // casts which is not what is necessary.  The DataObject is released correctly.
  if Assigned(OutStgMedium.unkForRelease) and (Result = S_OK) then
    IUnknown(OutStgMedium.unkForRelease)._AddRef
end;

procedure TEasyDataObjectManager.DoGetCustomFormats(var Formats: TEasyFormatEtcArray);
begin
  Owner.DoOLEGetCustomFormats(Formats);
end;

procedure TEasyOLEDragManager.ClearDragItem;
begin
  FDragItem := nil
end;

procedure TEasyOLEDragManager.ClearDropTarget;
begin
  // Unhilight the current Drop Target
  if Assigned(DropTarget) then
  begin
    DropTarget.Hilighted := False;
    OwnerListview.Groups.InvalidateItem(DropTarget, True);
  end;
  FDropTarget := nil;
end;

constructor TEasyOLEDragManager.Create(AnOwner: TCustomEasyListview);
begin
  inherited;
  HilightDropTarget := True
end;

destructor TEasyOLEDragManager.Destroy;
begin
  Registered := False;
  inherited;
end;

procedure TEasyOLEDragManager.DefaultImage(Sender: TCustomEasyListview; Image: TBitmap; DragStartPt: TPoint; var HotSpot: TPoint; var TransparentColor: TColor; var Handled: Boolean);
var
  R: TRect;
  Bits: TBitmap;
begin
  if Assigned(Image) then
  begin
    TransparentColor := OwnerListview.Color;
    R := Rect(DragStartPt.X - (Image.Width div 2),
              DragStartPt.Y - (Image.Height div 2),
              DragStartPt.X + (Image.Width div 2),
              DragStartPt.Y + (Image.Height div 2));

    HotSpot.X := (R.Right - R.Left) div 2;
    HotSpot.Y := (R.Bottom - R.Top) div 2;

    if R.Left < 0 then
      HotSpot.X := HotSpot.X + R.Left;
    if R.Top < 0 then
      HotSpot.Y := HotSpot.Y + R.Top;

    IntersectRect(R, R, OwnerListview.ClientRect);
    Bits := TBitmap.Create;
    try
      Bits.PixelFormat := pf32Bit;
      Bits.Width := Sender.Width;
      Bits.Height := Sender.Height;
      Bits.Canvas.Brush.Color := OwnerListview.Color;
      Bits.Canvas.FillRect(Rect(0, 0, Sender.Width, Sender.Height));
      OwnerListview.DoPaintRect(Bits.Canvas, R, True);
      BitBlt(Image.Canvas.Handle, 0, 0, Image.Width, Image.Height, Bits.Canvas.Handle, R.Left, R.Top, SRCCOPY);
    finally
      Bits.Free;
    end;
    Handled := True;
  end  
end;

procedure TEasyOLEDragManager.DoDrag(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect);
var
  ViewPortPoint: TPoint;
  Item: TEasyItem;
begin
  if OwnerListview.IsHeaderMouseMsg(PointToSmallPoint(WindowPoint), True) then
    Effects := cdeNone
  else begin
    ViewPortPoint := OwnerListview.Scrollbars.MapWindowToView(WindowPoint);
    Item := OwnerListview.Groups.ItemByPoint(ViewportPoint);
    if Assigned(Item) then
    begin
      if Item.SelectionHitPt(ViewportPoint, eshtClickSelect) then
      begin
        if Item <> DropTarget then
          ClearDropTarget;
        FDropTarget := Item;
        if Assigned(DropTarget) then
        begin
          if HilightDropTarget then
            Item.Hilighted := True;
          OwnerListview.Groups.InvalidateItem(Item, True)
        end
      end else
        ClearDropTarget
    end else
      ClearDropTarget
  end
end;

procedure TEasyOLEDragManager.DoDragDrop(WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect);
begin
  ClearDragItem;
  ClearDropTarget;
end;

procedure TEasyOLEDragManager.DoDragEnd(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates);
begin
  ClearDropTarget
end;

procedure TEasyOLEDragManager.DoDragEnter(const DataObject: IDataObject; Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect);
begin
  
end;

procedure TEasyOLEDragManager.DoGetDragImage(Bitmap: TBitmap; DragStartPt: TPoint; var HotSpot: TPoint; var TransparentColor: TColor; var Handled: Boolean);
begin
  OwnerListview.DoGetDragImage(Bitmap, DragStartPt, HotSpot, TransparentColor, Handled);
end;

procedure TEasyOLEDragManager.DoOLEDragEnd(const ADataObject: IDataObject; DragResult: TCommonOLEDragResult; ResultEffect: TCommonDropEffects);
begin
  OwnerListview.DoOLEDragEnd(ADataObject, DragResult, ResultEffect);
  DataObject := nil;
end;

procedure TEasyOLEDragManager.DoOLEDragStart(const ADataObject: IDataObject; var AvailableEffects: TCommonDropEffects; var AllowDrag: Boolean);
begin
  OwnerListview.DoOLEDragStart(ADataObject, AvailableEffects, AllowDrag);
end;

function TEasyOLEDragManager.DoPtInAutoScrollDownRegion(WindowPoint: TPoint): Boolean;
begin
  Result := WindowPoint.Y > OwnerListview.ClientHeight - AutoScrollMargin
end;

function TEasyOLEDragManager.DoPtInAutoScrollUpRegion(WindowPoint: TPoint): Boolean;
begin
  Result := WindowPoint.Y - OwnerListview.Header.RuntimeHeight < AutoScrollMargin
end;

procedure TEasyOLEDragManager.FinalizeDrag(KeyState: TCommonKeyStates);
// Does not mean the action actually occured it means that InitializeDrag was
// called and this is it matching call.  EndDrag means that the drag actually
// occured
begin
  inherited;
  ClearDragItem;
end;

function TEasyOLEDragManager.InitializeDrag(HitItem: TEasyItem; WindowPoint: TPoint;
  KeyState: TCommonKeyStates): Boolean;
// Does not mean that the action will be a Drag, it just means get ready for one
// just in case.
begin
  Result := False;
  if Enabled then
  begin
    if Assigned(HitItem) and ( ((cksLButton in KeyState) and (cmbLeft in MouseButton)) or
       ((cksMButton in KeyState) and (cmbMiddle in MouseButton)) or
       ((cksRButton in KeyState) and (cmbRight in MouseButton))) then
    begin
      if HitItem.SelectionHitPt(OwnerListview.Scrollbars.MapWindowToView(WindowPoint), eshtClickSelect) then
      begin
        FDragItem := HitItem;
        Result := True
      end
    end else
      FDragItem := nil
  end
end;

procedure TEasyOLEDragManager.ImageSize(var Width: Integer; var Height: Integer);
begin
  Width := DragImageWidth;
  Height := DragImageHeight
end;

procedure TEasyOLEDragManager.SetEnabled(const Value: Boolean);
begin
  inherited;
  Registered := Value;
end;

procedure TEasyOLEDragManager.VCLDragStart;
begin
  FDragItem := OwnerListview.Selection.FocusedItem;
  if DragMode = dmAutomatic then
    OwnerListview.BeginDrag(True);
end;

{ TEasySelectionManager }

function TEasySelectionManager.GetFocusedColumn: TEasyColumn;
begin
  if not Assigned(FFocusedColumn) then
    FFocusedColumn := OwnerListview.Header.FirstColumn;
  Result := FFocusedColumn;
end;

function TEasySelectionManager.SelectedToArray: TEasyItemArray;
var
  Item: TEasyItem;
  i: Integer;
begin
  SetLength(Result, Count);
  Item := First;
  i := 0;
  while Assigned(Item) do
  begin
    Result[i] := Item;
    Inc(i);
    Item := Next(Item)
  end
end;

procedure TEasySelectionManager.ActOnAll(SelectType: TEasySelectionType;
  ExceptItem: TEasyItem);
var
  i, j: Integer;
begin
  if Enabled then
  begin
    IncMultiChangeCount;
    GroupSelectBeginUpdate;
    try
      // If unselecting we can optimize for the more common situation by stopping when
      // there are no more selected items.
      if SelectType = ecstUnSelect then
      begin
        i := 0;
        while (i < OwnerListview.Groups.Count) and (Count > 0) do
        begin
          j := 0;
          while (j < OwnerListview.Groups[i].Items.Count) and (Count > 0) do
          begin
            if ExceptItem <> OwnerListview.Groups[i].Items[j] then
              OwnerListview.Groups[i].Items[j].Selected := False;
            Inc(j)
          end;
          Inc(i)
        end
      end else
      begin
        for i := 0 to OwnerListview.Groups.Count - 1 do
        begin
          case SelectType of
            ecstSelect:
              begin
                j := 0;
                while (j < OwnerListview.Groups[i].Items.Count) do
                begin
                  if ExceptItem <> OwnerListview.Groups[i].Items[j] then
                    OwnerListview.Groups[i].Items[j].Selected := True;
                  Inc(j)
                end;
              end;
            ecstInvert:
              begin
                j := 0;
                while (j < OwnerListview.Groups[i].Items.Count) do
                begin
                  if ExceptItem <> OwnerListview.Groups[i].Items[j] then
                    OwnerListview.Groups[i].Items[j].Selected := not OwnerListview.Groups[i].Items[j].Selected;
                  Inc(j)
                end;
              end;
          end
        end
      end;
      OwnerListview.DragManager.ClearDragItem;
    finally
      GroupSelectEndUpdate;
      DecMultiChangeCount
    end
  end
end;

procedure TEasySelectionManager.BuildSelectionGroupings(Force: Boolean);
//
// Builds the necessary information to group the selections like eMule, called
// for every selection change.  This could get slow with thousands of items.
//
var
  i: Integer;
  GroupList: TEasySelectionGroupList;
  Group: TEasyGroup;
  Item, NextItem: TEasyItem;
begin
  // It is possible that during streaming the items can be created but
  if not (csLoading in OwnerListview.ComponentState) and
    (Force or (GroupSelections and (FGroupSelectUpdateCount = 0){ and (OwnerListview.UpdateCount = 0) won't work with keyboard})) then
  begin
 //   Windows.Beep(5000, 200);
    GroupList := nil;
    for i := 0 to OwnerListview.Groups.Count - 1 do
    begin
      Group := TEasyGroup( OwnerListview.Groups.List[i]);
      Item := OwnerListview.Groups.FirstVisibleInGroup(Group);
      while Assigned(Item) do
      begin
        // Do a ReleaseSelectionGroup directly for speed
        if Assigned(Item) and Assigned(Item.SelectionGroup) then
        begin
          Item.FSelectionGroup.DecRef;
          Item.FSelectionGroup := nil
        end;

        if (esosSelected in Item.State) then
        begin
          NextItem := OwnerListview.Groups.NextVisibleInGroup(Group, Item);

          // Do a ReleaseSelectionGroup directly for speed
          if Assigned(NextItem) and Assigned(NextItem.SelectionGroup) then
          begin
            NextItem.FSelectionGroup.DecRef;
            NextItem.FSelectionGroup := nil
         end;

          // Direct access for speed
          while Assigned(NextItem) and (esosSelected in NextItem.State) do
          begin
            if not Assigned(GroupList) then
            begin
              GroupList := TEasySelectionGroupList.Create;
              GroupList.Add(Item);
              GroupList.IncRef;
              GroupList.DisplayRect := Item.DisplayRect;
              GroupList.FirstItem := Item;
              Item.SelectionGroup := GroupList;
            end;
            GroupList.Add(NextItem);
            UnionRect(Item.SelectionGroup.FDisplayRect, Item.SelectionGroup.DisplayRect, NextItem.DisplayRect);
            GroupList.IncRef;
            NextItem.SelectionGroup := GroupList;
            NextItem := OwnerListview.Groups.NextVisibleInGroup(Group, NextItem);
          end;
          GroupList := nil;
          Item := NextItem;
        end;
        Item := OwnerListview.Groups.NextVisibleInGroup(Group, Item);
      end;
    end
  end
end;

procedure TEasySelectionManager.ClearAll;
begin
  ActOnAll(ecstUnSelect, nil);
end;

procedure TEasySelectionManager.ClearAllExcept(Item: TEasyItem);
begin
  ActOnAll(ecstUnSelect, Item);
  OwnerListview.DragManager.ClearDragItem;
end;

constructor TEasySelectionManager.Create(AnOwner: TCustomEasyListview);
begin
  inherited;
  FEnabled := True;
  FColor := clHighlight;
  FBorderColor := clHighlight;
  FInactiveBorderColor := clInactiveBorder;
  FInactiveColor := clInactiveBorder;
  FInactiveTextColor := clBlack;
  FTextColor := clHighlightText;
  FRoundRectRadius := 4;
  FBlendColorSelRect := clHighlight;
  FBorderColorSelRect := clHighlight;
  FBlendColorIcon := clHighlight;
  BlendAlphaImage := 128;
  BlendAlphaSelRect := 70;
  BlendAlphaTextRect := 128;
  FAlphaBlend := False;
  FUseFocusRect := True;
  FMouseButton := [cmbLeft];
  MouseButtonSelRect := [cmbLeft, cmbRight];
  FBlendIcon := True
end;

destructor TEasySelectionManager.Destroy;
begin
  inherited;
end;

procedure TEasySelectionManager.DecMultiChangeCount;
begin
  Dec(FMultiChangeCount);
  if MultiChangeCount <= 0 then
  begin
    MultiChangeCount := 0;
    if ItemsToggled > 0 then
      OwnerListview.DoItemSelectionsChanged
  end
end;

procedure TEasySelectionManager.DeleteSelected;
var
  Items: TEasyItemArray;
  i: Integer;
begin
  OwnerListview.BeginUpdate;
  try
    Items := SelectedToArray;
    // Set the item in the list to nil and free the item
    try
      for i := 0 to Length(Items) - 1 do
      begin
        Items[i].OwnerGroup.Items[Items[i].Index] := nil;
        Items[i].Free;
      end;
    finally
      // now pack the group lists to elimiate the nil pointers
      for i := 0 to OwnerListview.Groups.Count - 1 do
        OwnerListview.Groups[i].Items.FList.Pack;
    end;
  finally
//    OwnerListview.Groups.ReIndexItems(nil, True);
    OwnerListview.EndUpdate;
  end
end;

procedure TEasySelectionManager.DragSelect(KeyStates: TCommonKeyStates);
// Handles the selection of items during a drag select operation
var
  CoverR: TRect;
  Item: TEasyItem;
begin
  if Enabled and MultiSelect then
  begin
    IncMultiChangeCount;
    GroupSelectBeginUpdate;
    try
      // Get the rectangle that covers any area that need to be tested for change
      UnionRect(CoverR, OwnerListview.DragRect.PrevRect, OwnerListview.DragRect.SelectionRect);

      if not IsRectEmpty(CoverR) then
      begin
        Item := OwnerListview.Groups.FirstItemInRect(CoverR);
        while Assigned(Item) do
        begin
          if cksControl in KeyStates then
          begin
            if Item.SelectionHit( OwnerListview.DragRect.SelectionRect, eshtDragSelect) xor
               Item.SelectionHit(OwnerListview.DragRect.PrevRect, eshtDragSelect)
            then
              Item.Selected := not Item.Selected;
          end else
          begin
            // First see if we need to select an item
            if Item.SelectionHit(OwnerListview.DragRect.SelectionRect, eshtDragSelect) then
              Item.Selected := True
            else begin
              // If we did not select the item see if it is in the Previous rectanagle
              // and it needs to be unselected
              if Item.SelectionHit(OwnerListview.DragRect.PrevRect, eshtDragSelect) then
                Item.Selected := False;
            end
          end;
          Item := OwnerListview.Groups.NextItemInRect(Item, CoverR)
        end
      end
    finally
      GroupSelectEndUpdate;
      DecMultiChangeCount
    end
  end
end;

function TEasySelectionManager.First: TEasyItem;
//
// Gets the first Selected item
//
var
  Item: TEasyItem;
begin
  Result := nil;
  Item := OwnerListview.Groups.FirstVisibleItem;
  while not Assigned(Result) and Assigned(Item) do
  begin
    if Item.Selected then
      Result := Item;
    Item := OwnerListview.Groups.NextVisibleItem(Item)
  end
end;

function TEasySelectionManager.FirstInGroup(Group: TEasyGroup): TEasyItem;
//
// Gets the first Selected item in the specified group from UIObject list
//
var
  Item: TEasyItem;
begin
  Result := nil;
  Item := OwnerListview.Groups.FirstInGroup(Group);
  while not Assigned(Result) and Assigned(Item) do
  begin
    if Item.Selected then
      Result := Item;
    Item := OwnerListview.Groups.NextInGroup(Group, Item)
  end
end;

procedure TEasySelectionManager.GainingSelection(Item: TEasyItem);
begin
  if not MultiSelect then
    ClearAllExcept(Item);
  Inc(OwnerListview.Selection.FCount);
  if not MultiSelect then
    FocusedItem := Item;
  Inc(FItemsToggled);
  NotifyOwnerListview
end;

function TEasySelectionManager.GetAutoScroll: Boolean;
begin
  Result := OwnerListview.DragRect.AutoScroll
end;

function TEasySelectionManager.GetAutoScrollAccelerator: Byte;
begin
  Result := OwnerListview.DragRect.AutoScrollAccelerator
end;

function TEasySelectionManager.GetAutoScrollDelay: Integer;
begin
  Result := OwnerListview.DragRect.AutoScrollDelay
end;

function TEasySelectionManager.GetAutoScrollMargin: Integer;
begin
  Result := OwnerListview.DragRect.AutoScrollMargin
end;

function TEasySelectionManager.GetAutoScrollTime: Integer;
begin
  Result := OwnerListview.DragRect.AutoScrollTime
end;

function TEasySelectionManager.GetEnableDragSelect: Boolean;
begin
  Result := OwnerListview.DragRect.Enabled
end;

function TEasySelectionManager.GeTCommonMouseButton: TCommonMouseButtons;
begin
  Result := FMouseButton
end;

function TEasySelectionManager.GetMouseButtonSelRect: TCommonMouseButtons;
begin
  Result := OwnerListview.DragRect.MouseButton
end;

function TEasySelectionManager.GetSelecting: Boolean;
begin
  Result := OwnerListview.DragRect.Dragging
end;

procedure TEasySelectionManager.GroupSelectBeginUpdate;
begin
  Inc(FGroupSelectUpdateCount)
end;

procedure TEasySelectionManager.GroupSelectEndUpdate;
begin
  Dec(FGroupSelectUpdateCount);
  if FGroupSelectUpdateCount <= 0 then
  begin
    FGroupSelectUpdateCount := 0;
 //   OwnerListview.Groups.ReIndexItems(nil, True);
    BuildSelectionGroupings(False);     
  end
end;

procedure TEasySelectionManager.IncMultiChangeCount;
begin
  if MultiChangeCount = 0 then
    ItemsToggled := 0;
  Inc(FMultiChangeCount)
end;

procedure TEasySelectionManager.InvalidateVisibleSelected(ValidateWindow: Boolean);
var
  Item: TEasyItem;
begin
  if Enabled then
  begin
    Item := OwnerListview.Groups.FirstItemInRect(OwnerListview.ClientRect);
    while Assigned(Item) do
    begin
      if Item.Selected or Item.Focused then
        Item.Invalidate(False);
      Item := OwnerListview.Groups.NextItemInRect(Item, OwnerListview.ClientRect)
    end
  end
end;

procedure TEasySelectionManager.Invert;
begin
  ActOnAll(ecstInvert, nil);
end;

procedure TEasySelectionManager.LosingSelection(Item: TEasyItem);
begin
  Dec(OwnerListview.Selection.FCount);
  Item.ReleaseSelectionGroup;
  Inc(FItemsToggled);
  NotifyOwnerListview
end;

procedure TEasySelectionManager.NotifyOwnerListview;
begin
  if (MultiChangeCount = 0) and (ItemsToggled > 0) then
  begin
    OwnerListview.DoItemSelectionsChanged;
    ItemsToggled := 0
  end
end;

procedure TEasySelectionManager.SelectAll;
begin
  if MultiSelect then
    ActOnAll(ecstSelect, nil);
end;

function TEasySelectionManager.Next(Item: TEasyItem): TEasyItem;
//
// Gets the next Selected item in the UIObject list
//
begin
  Result := nil;
  Item := OwnerListview.Groups.NextVisibleItem(Item);
  while not Assigned(Result) and Assigned(Item) do
  begin
    if Item.Selected then
      Result := Item;
    Item := OwnerListview.Groups.NextVisibleItem(Item)
  end
end;

function TEasySelectionManager.NextInGroup(Group: TEasyGroup;
  Item: TEasyItem): TEasyItem;
  //
// Gets the next Selected item in the specified group from UIObject list
//
begin
  Result := nil;
  Item := OwnerListview.Groups.NextInGroup(Group, Item);
  while not Assigned(Result) and Assigned(Item) do
  begin
    if Item.Selected then
      Result := Item;
    Item := OwnerListview.Groups.NextInGroup(Group, Item)
  end
end;

procedure TEasySelectionManager.SelectFirst;
var
  Item: TEasyItem;
begin
  ClearAll;
  Item := OwnerListview.Groups.FirstItem;
  if Assigned(Item) and Enabled then
  begin
    Item.Focused := True;
    Item.Selected := True
  end
end;

procedure TEasySelectionManager.SelectGroupItems(Group: TEasyGroup; ClearOtherItems: Boolean);
var
  i, j: Integer;
begin
  if Enabled and MultiSelect and Assigned(Group) then
  begin
    IncMultiChangeCount;
    GroupSelectBeginUpdate;
    try
      if ClearOtherItems then
      begin
        for i := 0 to OwnerListview.Groups.Count - 1 do
        begin
          if OwnerListview.Groups[i] <> Group then
          for j := 0 to OwnerListview.Groups[i].Items.Count - 1 do
            OwnerListview.Groups[i].Items[j].Selected := False;
        end;
      end;

      for i := 0 to Group.Items.Count - 1 do
        Group.Items[i].Selected := True
    finally
      GroupSelectEndUpdate;
      DecMultiChangeCount
    end
  end
end;

procedure TEasySelectionManager.SelectRange(FromItem, ToItem: TEasyItem; RectSelect: Boolean; ClearFirst: Boolean);

    procedure SwapItems(var Item1, Item2: TEasyItem);
    var
      Temp: TEasyItem;
    begin
      Temp := Item1;
      Item1 := Item2;
      Item2 := Temp
    end;

var
  R: TRect;
begin
  if Enabled and MultiSelect then
  begin
    IncMultiChangeCount;
    GroupSelectBeginUpdate;
    try
      if ClearFirst then
        ClearAll;
      if Assigned(FromItem) and Assigned(ToItem) then
      begin
        if RectSelect then
        begin
          UnionRect(R, FromItem.DisplayRect, ToItem.DisplayRect);
          SelectRect(R, False);
        end else
        begin
          if FromItem.OwnerGroup = ToItem.OwnerGroup then
          begin
            if FromItem.Index > ToItem.Index then
              SwapItems(FromItem, ToItem)
          end else
          begin
            if FromItem.OwnerGroup.Index > ToItem.OwnerGroup.Index then
              SwapItems(FromItem, ToItem)
          end;

          while Assigned(FromItem) and (FromItem <> ToItem) do
          begin
            FromItem.Selected := True;
            FromItem := OwnerListview.Groups.NextVisibleItem(FromItem)
          end;
          ToItem.Selected := True;
        end
      end
    finally
      GroupSelectEndUpdate;
      DecMultiChangeCount
    end
  end
end;

procedure TEasySelectionManager.SelectRect(ViewportSelRect: TRect; ClearFirst: Boolean);
var
  Temp: TEasyItem;
begin
  if Enabled and MultiSelect then
  begin
    GroupSelectBeginUpdate;
    IncMultiChangeCount;
    try
      if ClearFirst then
        ClearAll;
      Temp := OwnerListview.Groups.FirstItemInRect(ViewportSelRect);
      while Assigned(Temp) do
      begin
        Temp.Selected := True;
        Temp := OwnerListview.Groups.NextItemInRect(Temp, ViewportSelRect);
      end
    finally
      GroupSelectEndUpdate;
      DecMultiChangeCount
    end
  end
end;

procedure TEasySelectionManager.SetAnchorItem(Value: TEasyItem);
begin
  if Assigned(Value) then
  begin
    if Value.Visible and Value.Enabled then
      FAnchorItem := Value;
  end else
    FAnchorItem := nil
end;

procedure TEasySelectionManager.SetAutoScroll(Value: Boolean);
begin
  OwnerListview.DragRect.AutoScroll := Value
end;

procedure TEasySelectionManager.SetAutoScrollAccelerator(Value: Byte);
begin
  OwnerListview.DragRect.AutoScrollAccelerator := Value
end;

procedure TEasySelectionManager.SetAutoScrollDelay(Value: Integer);
begin
  OwnerListview.DragRect.AutoScrollDelay := Value
end;

procedure TEasySelectionManager.SetAutoScrollMargin(Value: Integer);
begin
  OwnerListview.DragRect.AutoScrollMargin := Value
end;

procedure TEasySelectionManager.SetAutoScrollTime(Value: Integer);
begin
  OwnerListview.DragRect.AutoScrollTime := Value
end;

procedure TEasySelectionManager.SetBlendIcon(Value: Boolean);
begin
  if FBlendIcon <> Value then
  begin
    FBlendIcon := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TEasySelectionManager.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    if not Value then
      ClearAll;
    FEnabled := Value;
  end;
end;

procedure TEasySelectionManager.SetEnableDragSelect(Value: Boolean);
begin
  OwnerListview.DragRect.Enabled := Value
end;

procedure TEasySelectionManager.SetFocusedColumn(Value: TEasyColumn);
var
  OldFocused: TEasyColumn;
begin
  if FFocusedColumn <> Value then
  begin
    OldFocused := FFocusedColumn;
    FFocusedColumn := Value;
    if Assigned(FFocusedColumn) then
      FFocusedColumn.Invalidate(True);
    if Assigned(OldFocused) then
      OldFocused.Invalidate(True);
  end
end;

procedure TEasySelectionManager.SetFocusedGroup(const Value: TEasyGroup);
//var
//  ChangeFocus: Boolean;
//  OldGroup: TEasyGroup;
begin
//  OldGroup := FFocusedGroup;
(*  if Assigned(Value) then
  begin
    if Value.Visible and Value.Enabled then
    begin
      if FFocusedGroup <> Value then
      begin
        if Assigned(OldGroup) then
          OldGroup.Focused := False;

        ChangeFocus := True;
        // The user may not have allowed the focus to change
        if Assigned(OldGroup) then
          ChangeFocus := not OldGroup.Focused;

        if ChangeFocus then
        begin
          Value.Focused := True;
          FFocusedGroup := Value
        end
      end
    end
  end else
  begin
    FFocusedGroup := nil;
    if Assigned(OldGroup) then
       OldGroup.Focused := False;
  end *)
end;

procedure TEasySelectionManager.SetFocusedItem(Value: TEasyItem);
var
  ChangeFocus: Boolean;
  OldItem: TEasyCollectionItem;
  RectArray: TEasyRectArrayObject;
begin
  OldItem := FFocusedItem;
  if Assigned(Value) then
  begin
    if Value.Visible and Value.Enabled then
    begin
      if FFocusedItem <> Value then
      begin
        if Assigned(OldItem) then
          OldItem.Focused := False;

        ChangeFocus := True;
        // The user may not have allowed the focus to change
        if Assigned(OldItem) then
          ChangeFocus := not OldItem.Focused;

        if ChangeFocus then
        begin
          FFocusedItem := Value;
          // Resize the Groups in case the full focus text was bigger than
          // the group
          Value.Focused := True;
          // During Deletion this can lead to weird recurssion
          if not Value.Destroying then
          begin
            Value.ItemRectArray(nil, OwnerListview.ScratchCanvas, RectArray);
            // Rebuild the grid if the focused text will overlap the bottom of the
            // group
            if RectArray.FullTextRect.Bottom > Value.OwnerGroup.ClientRect.Bottom then
              Value.OwnerListview.Groups.Rebuild(True);
           end
        end
      end
    end
  end else
  begin
    FFocusedItem := nil;
    if Assigned(OldItem) then
    begin
      if Assigned(OldItem) then
      begin
         OldItem.Focused := False;
         // Resize the Groups in case the full focus text was bigger than
         // the group
         // During Deletion this can lead to weird recurssion
         if not OldItem.Destroying then
         begin
  (*        OwnerListview.Grid.CacheGroupInfo;
           OwnerListview.Scrollbars.SetViewRect(OwnerListview.Grid.ViewRect, True); *)
         end
      end
    end
  end
end;

procedure TEasySelectionManager.SeTCommonMouseButton(Value: TCommonMouseButtons);
begin
  FMouseButton := Value
end;

procedure TEasySelectionManager.SetFullCellPaint(Value: Boolean);
begin
  if Value <> FFullCellPaint then
  begin
    FFullCellPaint := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TEasySelectionManager.SetFullItemPaint(Value: Boolean);
begin
  if Value <> FFullItemPaint then
  begin
    FFullItemPaint := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TEasySelectionManager.SetGroupSelections(Value: Boolean);
begin
  if Value <> FGroupSelections then
  begin
    OwnerListview.BeginUpdate;
    try
      FGroupSelections := Value;
      BuildSelectionGroupings(True)
    finally
      OwnerListview.EndUpdate
    end
  end
end;

procedure TEasySelectionManager.SetMouseButtonSelRect(Value: TCommonMouseButtons);
begin
  OwnerListview.DragRect.MouseButton := Value
end;

procedure TEasySelectionManager.SetMultiSelect(const Value: Boolean);
begin
  if FMultiSelect <> Value then
  begin
    FMultiSelect := Value;
    ClearAll
  end
end;

{ TEasyCheckManager }

procedure TEasyCheckManager.CheckAll;
//
// Checks all the Visible items in the EasyControl
//
var
  i: Integer;
begin
  for i := 0 to OwnerListview.Groups.Count - 1 do
    OwnerListview.Groups.Groups[i].Checked := True
end;

procedure TEasyCheckManager.CheckAllInGroup(Group: TEasyGroup);
//
// Checks all the Visible items in a particular group
//
begin
  Group.Checked := True
end;

function TEasyCheckManager.GetFirstChecked: TEasyItem;
//
// Gets the first checked item in the control and prepares for the GetNext iteration
//
//var
//  Found: Boolean;
//  i: Integer;
begin
//  Found := False;
//  i := 0;
(*  while (i < OwnerListview.UIObjects.ItemCount) and not Found do
  begin
    Result := OwnerListview.UIObjects.Items[i];
    Found := Result.Checked;
    if not Found then
      Inc(i)
  end;
  if not Found then  *)
    Result := nil;
end;

function TEasyCheckManager.GetFirstCheckedInGroup(Group: TEasyGroup): TEasyCollectionItem;
//
// Gets the first checked item in a particular grouip and prepares for the GetNextInGroup iteration
//
var
  Found: Boolean;
  i: Integer;
begin
 Result := nil;
 Exit;

  Found := False;
  i := 0;
  while (i < Group.Items.Count) and not Found do
  begin
    Result := Group.Items[i];
    // By definition if the item is checked is must be visible
    Found := Result.Checked;
    if not Found then
      Inc(i)
  end;
  if not Found then
    Result := nil;
end;

function TEasyCheckManager.GetNextChecked(Item: TEasyItem): TEasyItem;
//
// Gets the next checked item in the control, depends on GetFirst to be called first
//
//var
//  Found: Boolean;
//  i: Integer;
begin
//  Found := False;
(*  i := Item.VisibleIndex;
  Inc(i);
  while (i < OwnerListview.UIObjects.ItemCount) and not Found do
  begin
    Result := OwnerListview.UIObjects.Items[i];
    Found := Result.Checked;
    if not Found then
      Inc(i)
  end;
  if not Found then   *)
    Result := nil;
end;

function TEasyCheckManager.GetNextCheckedInGroup(Item: TEasyItem): TEasyItem;
//
// Gets the next checked item in a particular group, depends on GetFirstInGroup to be called first
//
begin
  Result := nil;
  Assert(True = False, 'TEasyCheckManager.GetNextCheckedInGroup not implemented yet');
  Exit;

end;

procedure TEasyCheckManager.SetPendingObject(Value: TEasyCollectionItem);
begin
  if Value <> FPendingObject then
  begin
    if Assigned(FPendingObject) then
      FPendingObject.CheckPending := False;
    FPendingObject := Value;
    if Assigned(FPendingObject) then
      FPendingObject.CheckPending := True;
  end
end;

procedure TEasyCheckManager.UnCheckAll;
//
// Unchecks all Visible items in the control
//
var
  i: Integer;
begin
  OwnerListview.BeginUpdate;
  try
    for i := 0 to OwnerListview.Groups.Count - 1 do
      OwnerListview.Groups.Groups[i].Checked := False;
  finally
    OwnerListview.EndUpdate;
  end
end;

procedure TEasyCheckManager.UnCheckAllInGroup(Group: TEasyGroup);
//
// Unchecks all Visible items in a particular group
//
begin
  OwnerListview.BeginUpdate;
  try
    Group.Checked := False
  finally
    OwnerListview.EndUpdate;
  end
end;

{ TEasyScrollbarManager }

constructor TEasyScrollbarManager.Create(AnOwner: TCustomEasyListview);
begin
  inherited;
  FHorzEnabled := True;
  FVertEnabled := True;
end;

destructor TEasyScrollbarManager.Destroy;
begin
  inherited;
end;

function TEasyScrollbarManager.GetHorzBarVisible: Boolean;
begin
  if Assigned(OwnerListview) and OwnerListview.HandleAllocated then
    Result := GetWindowLong(OwnerListview.Handle, GWL_STYLE) and WS_HSCROLL <> 0
  else
    Result := False;
end;

function TEasyScrollbarManager.GetLine: Integer;
begin
  Result := OwnerListview.Groups.CellHeight
end;

function TEasyScrollbarManager.GetMaxOffsetX: Integer;
begin
  Result := ViewWidth - OwnerListview.ClientWidth;

  if Result < 0 then
    Result := 0;
end;

function TEasyScrollbarManager.GetMaxOffsetY: Integer;
begin
  Result := ViewHeight -
            OwnerListview.ClientHeight +
            OwnerListview.Header.RuntimeHeight {+
            OwnerListview.Columns.Footer.SizeTotal};

  if Result < 0 then
    Result := 0;
end;

function TEasyScrollbarManager.GetVertBarVisible: Boolean;
begin
  if Assigned(OwnerListview) and OwnerListview.HandleAllocated then
    Result := GetWindowLong(OwnerListview.Handle, GWL_STYLE) and WS_VSCROLL <> 0
  else
    Result := False;
end;

function TEasyScrollbarManager.GetViewHeight: Integer;
begin
  Result := ViewRect.Bottom - ViewRect.Top
end;

function TEasyScrollbarManager.GetViewWidth: Integer;
begin
  Result := ViewRect.Right - ViewRect.Left
end;

function TEasyScrollbarManager.MapViewToWindow(ViewportPoint: TPoint; AccountForHeader: Boolean = True): TPoint;
begin
  Result.X := ViewportPoint.X -
              OffsetX;
  Result.Y := ViewportPoint.Y -
              OffsetY;
  if AccountForHeader then
    Inc(Result.Y, OwnerListview.Header.RuntimeHeight)
end;

function TEasyScrollbarManager.MapViewRectToWindowRect(ViewPortRect: TRect; AccountForHeader: Boolean = True): TRect;
begin
  Result.TopLeft := MapViewToWindow(ViewPortrect.TopLeft, AccountForHeader);
  Result.BottomRight := MapViewToWindow(ViewPortRect.BottomRight, AccountForHeader);
end;

function TEasyScrollbarManager.MapViewToWindow(ViewportPoint: TSmallPoint; AccountForHeader: Boolean = True): TPoint;
begin
  Result := MapViewToWindow(SmallPointToPoint(ViewportPoint), AccountForHeader)
end;

function TEasyScrollbarManager.MapWindowToView(WindowPoint: TPoint; AccountForHeader: Boolean = True): TPoint;
begin
  Result.X := WindowPoint.X + OffsetX;
  Result.Y := WindowPoint.Y + OffsetY;
  if AccountForHeader then
    Dec(Result.Y, OwnerListview.Header.RuntimeHeight)
end;

function TEasyScrollbarManager.MapWindowRectToViewRect(WindowRect: TRect; AccountForHeader: Boolean = True): TRect;
begin
  Result.TopLeft := MapWindowToView(WindowRect.TopLeft, AccountForHeader);
  Result.BottomRight := MapWindowToView(WindowRect.BottomRight, AccountForHeader);
end;

function TEasyScrollbarManager.MapWindowToView(WindowPoint: TSmallPoint; AccountForHeader: Boolean = True): TPoint;
begin
  Result := MapWindowToView(SmallPointToPoint(WindowPoint), AccountForHeader);
end;

procedure TEasyScrollbarManager.ReCalculateScrollbars(Redraw: Boolean;
  Force: Boolean);
const
  ALL_SCROLLFLAGS = SIF_PAGE or SIF_POS or SIF_RANGE;
var
  Info: TScrollInfo;
  ScrollVisible, HorzBarChangedVis, VertBarChangedVis: Boolean;
begin
  // Performance hit if not checking for update.
  if (Assigned(OwnerListview) and OwnerListview.HandleAllocated) and
    ((OwnerListview.UpdateCount = 0) or Force) and not (escsRecalculating in State) then
  begin
    Include(FState, escsRecalculating);
    try
      // If the window is resizing our offset may become invalid and we need to
      // "pull" the offset with the resize
      ValidateOffsets(FOffsetX, FOffsetY);

      ScrollVisible := GetWindowLong(OwnerListview.Handle, GWL_STYLE) and WS_VSCROLL <> 0;

      FillChar(Info, SizeOf(Info), #0);
      Info.cbSize := SizeOf(Info);
      Info.fMask := ALL_SCROLLFLAGS;
      Info.nMin := 0;
      if VertEnabled then
      begin
        Info.nMax := ViewHeight + OwnerListview.Header.RuntimeHeight - 1;
        Info.nPos := Abs(OffsetY);
        if OwnerListview.ClientHeight < 0 then
          Info.nPage := 0
        else
          Info.nPage := OwnerListview.ClientHeight;
      end else
      begin
        Info.nMax := 0;
        Info.nPos := 0;
        Info.nPage := 0;
      end;


      SetScrollInfo(OwnerListview.Handle, SB_VERT, Info, Redraw);

      VertBarChangedVis := ScrollVisible xor (GetWindowLong(OwnerListview.Handle, GWL_STYLE) and WS_VSCROLL <> 0);

      ScrollVisible := GetWindowLong(OwnerListview.Handle, GWL_STYLE) and WS_HSCROLL <> 0;
      FillChar(Info, SizeOf(Info), #0);
      Info.cbSize := SizeOf(Info);
      Info.fMask := ALL_SCROLLFLAGS;
      Info.nMin := 0;

      if HorzEnabled then
      begin
        Info.nMax := ViewWidth - 1;
        Info.nPos := Abs(OffsetX);
        if OwnerListview.ClientWidth < 0 then
          Info.nPage := 0
        else
          Info.nPage := OwnerListview.ClientWidth;
      end else
      begin
        Info.nMax := 0;
        Info.nPos := 0;
        Info.nPage := 0;
      end;
      SetScrollInfo(OwnerListview.Handle, SB_HORZ, Info, Redraw);

      HorzBarChangedVis := ScrollVisible xor (GetWindowLong(OwnerListview.Handle, GWL_STYLE) and WS_HSCROLL <> 0);

      // If the window is resizing our offset may become invalid and we need to
      // "pull" the offset with the resize
      ValidateOffsets(FOffsetX, FOffsetY);

      if HorzBarChangedVis and VertBarChangedVis then
        ScrollVisibilityChanged(esdBoth)
      else
      if HorzBarChangedVis then
        ScrollVisibilityChanged(esdHorizontal)
      else
      if VertBarChangedVis then
        ScrollVisibilityChanged(esdVertical);
    finally
      Exclude(FState, escsRecalculating)
    end
  end
end;

procedure TEasyScrollbarManager.ScrollVisibilityChanged(Scrollbar: TEasyScrollbarDir);
begin
  OwnerListview.SafeInvalidateRect(nil, False);
  OwnerListview.Groups.Rebuild(False)
end;

procedure TEasyScrollbarManager.SetHorzEnabled(
  const Value: Boolean);
begin
  if FHorzEnabled <> Value then
  begin
    FHorzEnabled := Value;
    ReCalculateScrollbars(True, False);
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TEasyScrollbarManager.SetOffsetX(const Value: Integer);
begin
  if FOffsetX <> Value then
    Scroll(Value - OffsetX, 0);
end;

procedure TEasyScrollbarManager.SetOffsetY(const Value: Integer);
begin
  if FOffsetY <> Value then
    Scroll(0, Value - OffsetY);
end;

procedure TEasyScrollbarManager.SetVertEnabled(
  const Value: Boolean);
begin
  if FVertEnabled <> Value then
  begin
    FVertEnabled := Value;
    ReCalculateScrollbars(True, False);
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TEasyScrollbarManager.SetViewRect(AViewRect: TRect; InvalidateWindow: Boolean);
var
  WasX, WasY: Boolean;
begin
  if not EqualRect(AViewRect, FViewRect) then
  begin
    WasX := HorzBarVisible;
    WasY := VertBarVisible;
    FViewRect := AViewRect;
    ReCalculateScrollbars(True, False);
    if (InvalidateWindow or (WasX and not HorzBarVisible) or (WasY and not VertBarVisible)) then
      OwnerListview.SafeInvalidateRect(nil, True);
  end else
    if InvalidateWindow then
      OwnerListview.SafeInvalidateRect(nil, True);
end;

procedure TEasyScrollbarManager.ValidateOffsets(var AnOffsetX, AnOffsetY: Integer);
// "Pulls" the offset to keep in sync with the client window.  This is especially
// for when the window is resizing and the offset is near the bottom of the page.
// Without this the Scroll Manager could detect that the scrollbars are not needed
// any more and hide them leaving the window scrolled to the last known point!
//var
//  Column: Integer;
begin
  if Assigned(OwnerListview) then
  begin
    if AnOffsetY > MaxOffsetY  then
      AnOffsetY := MaxOffsetY;
    if AnOffsetX > MaxOffsetX  then
      AnOffsetX := MaxOffsetX;
    if AnOffsetY < 0 then
      AnOffsetY := 0;
    if AnOffsetX < 0 then
      AnOffsetX := 0;
  end else
  begin
    AnOffsetX := 0;
    AnOffsetY := 0
  end
end;

function TEasyScrollbarManager.ViewableViewportRect: TRect;
//
// Returns, in Viewport Coordinates, the rectangle that is current visible to
// the user in the window.
//
begin
  Result := MapWindowRectToViewRect(OwnerListview.ClientRect)
end;

procedure TEasyScrollbarManager.WMHScroll(var Msg: TWMVScroll);
// Called from the WM_HSCROLL message of the owner window to implement the scroll
var
  Info: TScrollInfo;
  ClientR: TRect;
  DeltaX: Integer;
begin
  if Assigned(OwnerListview) then
  begin
    DeltaX := 0;
    // Get the 32 Bit Position
    FillChar(Info, SizeOf(Info), #0);
    Info.cbSize := SizeOf(Info);
    Info.fMask := SIF_POS or SIF_TRACKPOS;
    GetScrollInfo(OwnerListview.Handle, SB_HORZ, Info);
    ClientR :=OwnerListview.ClientRect;
    case Msg.ScrollCode of
      SB_BOTTOM: DeltaX := (ViewRect.Right - ViewRect.Left) - OffsetX;
      SB_ENDSCROLL: DeltaX := 0;
      SB_LINEDOWN: DeltaX := Line;
      SB_LINEUP: DeltaX := -Line;
      SB_PAGEDOWN: DeltaX := ClientR.Right - ClientR.Left;
      SB_PAGEUP: DeltaX := -(ClientR.Right - ClientR.Left);
      SB_THUMBPOSITION: DeltaX := Info.nTrackPos - OffsetX;
      SB_THUMBTRACK: DeltaX := Info.nTrackPos - OffsetX;
      SB_TOP: DeltaX := -OffsetY
   end;
    Scroll(DeltaX, 0);
  end else
    OffsetX := 0
end;

procedure TEasyScrollbarManager.WMKeyDown(var Msg: TWMKeyDown);
// Call from the WM_KEYDOWN message of the owner window to check for keys that
// are related to scrolling the window
var
  NewMsg: TWMScroll;
  SkipScroll: Boolean;
begin
  FillChar(NewMsg, SizeOf(NewMsg), #0);
  SkipScroll := False;
  case Msg.CharCode of
    VK_HOME:  NewMsg.ScrollCode := SB_TOP;
    VK_END:   NewMsg.ScrollCode := SB_BOTTOM;
    VK_NEXT:  NewMsg.ScrollCode := SB_PAGEDOWN;
    VK_PRIOR: NewMsg.ScrollCode := SB_PAGEUP;
    VK_UP:    NewMsg.ScrollCode := SB_LINEUP;
    VK_DOWN:  NewMsg.ScrollCode := SB_LINEDOWN;
    VK_LEFT:  NewMsg.ScrollCode := SB_LINEUP;
    VK_RIGHT: NewMsg.ScrollCode := SB_LINEDOWN;
  else
    SkipScroll := True;
  end;
  if not SkipScroll then
  begin
    if Msg.CharCode in [VK_LEFT, VK_RIGHT] then
      WMHScroll(NewMsg)
    else
      WMVScroll(NewMsg)
  end
end;

procedure TEasyScrollbarManager.WMVScroll(var Msg: TWMVScroll);
// Call from the WM_VSCROLL message of the owner window to implement the scroll
var
  Info: TScrollInfo;
  ClientR: TRect;
  DeltaY: Integer;
begin
  if Assigned(OwnerListview) then
  begin
    DeltaY := 0;
    // Get the 32 Bit Position
    FillChar(Info, SizeOf(Info), #0);
    Info.cbSize := SizeOf(Info);
    Info.fMask := SIF_TRACKPOS;
    GetScrollInfo(OwnerListview.Handle, SB_VERT, Info);
    ClientR := OwnerListview.ClientRect;
    case Msg.ScrollCode of
      SB_BOTTOM: DeltaY := (ViewRect.Bottom - ViewRect.Top) - OffsetY;
      SB_ENDSCROLL: DeltaY := 0;
      SB_LINEDOWN: DeltaY := Line;
      SB_LINEUP: DeltaY := -Line;
      SB_PAGEDOWN: DeltaY := (ClientR.Bottom - ClientR.Top);
      SB_PAGEUP: DeltaY := -(ClientR.Bottom - ClientR.Top);
      SB_THUMBPOSITION: DeltaY := Info.nTrackPos - OffsetY;
      SB_THUMBTRACK: DeltaY := Info.nTrackPos - OffsetY;
      SB_TOP: DeltaY := -OffsetY;
   end;
    Scroll(0, DeltaY);
  end else
    OffsetY := 0
end;

procedure TEasyScrollbarManager.Scroll(DeltaX, DeltaY: Integer);
var
  OldOffsetX, OldOffsetY: Integer;
begin
  OldOffsetY := OffsetY;
  OldOffsetX := OffsetX;

  FOffsetX := OffsetX + DeltaX;
  FOffsetY := OffsetY + DeltaY;

  ValidateOffsets(FOffsetX, FOffsetY);

  if (OffsetX <> OldOffsetX) or (OffsetY <> OldOffsetY) then
  begin  
    ReCalculateScrollbars(True, True);
    OwnerListview.SafeInvalidateRect(nil, False);
  end
end;

{ TEasyBackgroundManager }

procedure TEasyBackgroundManager.Assign(Source: TPersistent);
var
  ASource: TEasyBackgroundManager;
begin
  if Source is TEasyBackgroundManager then
  begin
    ASource := TEasyBackgroundManager(Source);
    Image.Assign(ASource.Image);
    FEnabled := ASource.Enabled;
    FOffsetX := ASource.OffsetX;
    FOffsetY := ASource.OffsetY;
    FTile := ASource.Tile;
  end
end;

procedure TEasyBackgroundManager.AssignTo(Target: TPersistent);
var
  ATarget: TEasyBackgroundManager;
begin
  if Target is TEasyBackgroundManager then
  begin
    ATarget := TEasyBackgroundManager(Target);
    ATarget.Image.Assign(Image);
    ATarget.FEnabled := Enabled;
    ATarget.FOffsetX := OffsetX;
    ATarget.FOffsetY := OffsetY;
    ATarget.FTile := Tile;
  end
end;

procedure TEasyBackgroundManager.ChangeBitmapBits(Sender: TObject);
begin
  Image.PixelFormat := pf32Bit;
  AlphaImage.PixelFormat := pf32Bit;
  OwnerListview.SafeInvalidateRect(nil, False);
end;

constructor TEasyBackgroundManager.Create(AnOwner: TCustomEasyListview);
begin
  inherited;
  FImage := TBitmap.Create;
  FImage.PixelFormat := pf32Bit;
  FImage.OnChange := ChangeBitmapBits;
  FAlphaImage := TBitmap.Create;
  FAlphaImage.PixelFormat := pf32Bit;
  FAlphaImage.OnChange := ChangeBitmapBits;
  FTile := True;
  FOffsetX := 0;
  FOffsetY := 0;
  FBlendMode := cbmConstantAlphaAndColor;
  FBlendAlpha := 128;
  FAlphaBlend := False;
end;

destructor TEasyBackgroundManager.Destroy;
begin
  FImage.OnChange := nil;
  FreeAndNil(FImage);
  FreeAndNil(FAlphaImage);
  inherited;
end;

procedure TEasyBackgroundManager.PaintTo(ACanvas: TCanvas; ARect: TRect; PaintDefault: Boolean);
var
  Row, Column, X, Y: Integer;
  BkGndR, TempR: TRect;
  OldOrigin: TPoint;
  Bitmap: TBitmap;
begin
  if Assigned(Image) and not Image.Empty and Enabled then
  begin
    ACanvas.Brush.Color := OwnerListview.Color;
    ACanvas.FillRect(ARect);
    if AlphaBlend and HasMMX then
    begin
      Assert((BlendMode = cbmConstantAlphaAndColor) or (Assigned(AlphaImage)
        and not AlphaImage.Empty), STR_BACKGROUNDALPHABLEND);

      Assert(((Image.Width = AlphaImage.Width) and
             (Image.Height = AlphaImage.Height)) or AlphaImage.Empty,
              STR_BACKGROUNDALPHABLEND);

      Bitmap := TBitmap.Create;
      Bitmap.Width := Image.Width;
      Bitmap.Height := Image.Height;
      Bitmap.PixelFormat := pf32Bit;
      Bitmap.Assign(Image);

      if ((Image.Width = AlphaImage.Width) and
          (Image.Height = AlphaImage.Height)) or
           AlphaImage.Empty or
          (BlendMode = cbmConstantAlphaAndColor)
      then
        // AlphaBlend it with the background bitmap
        MPCommonUtilities.AlphaBlend(AlphaImage.Canvas.Handle, Bitmap.Canvas.Handle,
          Rect(0, 0, Bitmap.Width, Bitmap.Height), Point(0, 0),
          BlendMode, BlendAlpha, ColorToRGB(OwnerListview.Color));
    end else
      Bitmap := Image;

    Bitmap.Canvas.Lock;
    try
      // Needed to make IntersectRect work correctly.
      InflateRect(ARect, Bitmap.Width, Bitmap.Height);
      if Tile then
      begin
        // Need to keep BitBlt from needing negative numbers.  It will not work with them
        X := OffsetX mod Bitmap.Width;
        if OffsetX > 0 then
          X := -(Bitmap.Width - X);
        Y := OffsetY mod Bitmap.Height;
        if OffsetY > 0 then
          Y := -(Bitmap.Height - Y);

        SetViewportOrgEx(ACanvas.Handle, X, Y, @OldOrigin);
        try
          BkGndR := Rect(0, 0, Bitmap.Width, Bitmap.Height);
          for Row := 0 to (OwnerListview.ClientHeight div Bitmap.Height + 1) do
          begin
            for Column := 0 to (OwnerListview.ClientWidth div Bitmap.Width + 1) do
            begin
              if IntersectRect(TempR, ARect, BkGndR) then
              begin
                if Transparent then
                  ACanvas.Draw(BkGndR.Left, BkGndR.Top, Bitmap)
                else
                  BitBlt(ACanvas.Handle, BkGndR.Left, BkGndR.Top, BkGndR.Right, BkGndR.Bottom,
                    Bitmap.Canvas.Handle, 0, 0, SRCCOPY)
              end;
              OffsetRect(BkGndR, Bitmap.Width, 0);
            end;
            OffsetRect(BkGndR, -BkGndR.Left, Bitmap.Height);
          end;
        finally
          SetViewportOrgEx(ACanvas.Handle, OldOrigin.X, OldOrigin.Y, nil);
          InflateRect(ARect, -Bitmap.Width, -Bitmap.Height);
        end
      end else
      begin
        SetViewportOrgEx(ACanvas.Handle, OffsetX, OffsetY, @OldOrigin);
        BkGndR := Rect(0, 0, Bitmap.Width, Bitmap.Height);
        if Transparent then
          ACanvas.Draw(BkGndR.Left, BkGndR.Top, Bitmap)
        else
          BitBlt(ACanvas.Handle, BkGndR.Left, BkGndR.Top, BkGndR.Right, BkGndR.Bottom,
            Bitmap.Canvas.Handle, 0, 0, SRCCOPY);
        SetViewportOrgEx(ACanvas.Handle, OldOrigin.X, OldOrigin.Y, nil);
      end
    finally
      Bitmap.Canvas.UnLock;
      if AlphaBlend then
        Bitmap.Free
    end
  end else
  if PaintDefault then
  begin
    ACanvas.Brush.Color := OwnerListview.Color;
    ACanvas.FillRect(ARect);
  end;
end;

procedure TEasyBackgroundManager.SetAlphaBlend(const Value: Boolean);
begin
  if FAlphaBlend <> Value then
  begin
    FAlphaBlend := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TEasyBackgroundManager.SetAlphaImage(const Value: TBitmap);
begin
  FAlphaImage.Assign(Value);
  OwnerListview.SafeInvalidateRect(nil, False)
end;

procedure TEasyBackgroundManager.SetBlendAlpha(const Value: Integer);
begin
  if FBlendAlpha <> Value then
  begin
    FBlendAlpha := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TEasyBackgroundManager.SeTCommonBlendMode(const Value: TCommonBlendMode);
begin
  if FBlendMode <> Value then
  begin
    FBlendMode := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TEasyBackgroundManager.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TEasyBackgroundManager.SetImage(const Value: TBitmap);
begin
  FImage.Assign(Value);
  OwnerListview.SafeInvalidateRect(nil, False)
end;

procedure TEasyBackgroundManager.SetOffsetX(const Value: Integer);
begin
  if FOffsetX <> Value then
  begin
    FOffsetX := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TEasyBackgroundManager.SetOffsetY(const Value: Integer);
begin
  if FOffsetY <> Value then
  begin
    FOffsetY := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TEasyBackgroundManager.SetTile(const Value: Boolean);
begin
  if FTile <> Value then
  begin
    FTile := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TEasyBackgroundManager.SetTransparent(const Value: Boolean);
begin
  if FTransparent <> Value then
  begin
    FTransparent := Value;
    OwnerListview.SafeInvalidateRect(nil, False);
    Image.Transparent := Value;
    Image.TransparentMode := tmAuto;
  end
end;

procedure TEasyBackgroundManager.WMWindowPosChanging(var Msg: TWMWindowPosChanging);
begin
  if OffsetTrack then
  begin
    // If SWP_NOSIZE is in the flags then the cx, cy params can be garbage
    if Msg.WindowPos.flags and SWP_NOSIZE  = 0 then
    begin
      FOffsetX := FOffsetX + (Msg.WindowPos.cx - OwnerListview.Width);
      FOffsetY := FOffsetY + (Msg.WindowPos.cy - OwnerListview.Height);
    end
  end
end;

function TEasyDropTargetManager.DragEnter(const dataObj: IDataObject;
  grfKeyState: Integer; pt: TPoint; var dwEffect: Integer): HResult;
var
  Effect: TCommonDropEffect;
  Effects: TCommonDropEffects;
  Keys: TCommonKeyStates;
  StgMedium: TStgMedium;
begin
  if Assigned(DropTargetHelper) then
    DropTargetHelper.DragEnter(Owner.Handle, dataObj, Pt, dwEffect);

  Keys := KeyToKeyStates(grfKeyState);
  Effects := DropEffectToDropEffectStates(dwEffect);

  // Get the "Windows Style" effect with the key modifiers
  Effect := KeyStateToDropEffect(Keys);

  Owner.DoOLEDropTargetDragEnter(dataObj, KeyToKeyStates(grfKeyState), pt, DropEffectToDropEffectStates(dwEffect), Effect);

  // Decide if this is a Header Drag and Drop or an Item Drag and Drop
  // Note that if we use a Windows supplied IDataObject it will return TRUE for QueryGetData
  // so we must really try to get the data to be sure
  if Succeeded(dataObj.GetData(HeaderClipFormat, StgMedium)) then
    DragManager := Owner.Header.DragManager
  else
    DragManager := Owner.DragManager;

  if Assigned(DragManager) then
    DragManager.DragEnter(dataObj, nil, Owner.ScreenToClient(pt), Keys, Effect);

  dwEffect := DropEffectStateToDropEffect(Effect);
  Result := S_OK;
end;

function TEasyDropTargetManager.DragLeave: HResult;
begin
  if Assigned(DropTargetHelper) then
    DropTargetHelper.DragLeave;

  Owner.DoOLEDropTargetDragLeave;

  // Just pass some dummy parameters as they are not important for OLE drag drop
  if Assigned(DragManager) then
    DragManager.DragEnd(nil, Point(0, 0), []);

  Result := S_OK
end;

function TEasyDropTargetManager.DragOver(grfKeyState: Integer; pt: TPoint;
  var dwEffect: Integer): HResult;
var
  Effect: TCommonDropEffect;
  Effects: TCommonDropEffects;
  Keys: TCommonKeyStates;
begin
  if Assigned(DropTargetHelper) then
    DropTargetHelper.DragOver(Pt, dwEffect);

  Keys := KeyToKeyStates(grfKeyState);
  Effects := DropEffectToDropEffectStates(dwEffect);

  // Get the "Windows Style" effect with the key modifiers
  Effect := KeyStateToDropEffect(Keys);
  Owner.DoOLEDropTargetDragOver(KeyToKeyStates(grfKeyState), pt, Effects, Effect);

  if Assigned(DragManager) then
    DragManager.Drag(nil, Owner.ScreenToClient(pt), Keys, Effect);

  dwEffect := DropEffectStateToDropEffect(Effect);
    
  Result := S_OK
end;

function TEasyDropTargetManager.Drop(const dataObj: IDataObject;
  grfKeyState: Integer; pt: TPoint; var dwEffect: Integer): HResult;
var
  Effect: TCommonDropEffect;
  Effects: TCommonDropEffects;
  Keys: TCommonKeyStates;
begin
  if Assigned(DropTargetHelper) then
    DropTargetHelper.Drop(dataObj, Pt, dwEffect);

  Keys := KeyToKeyStates(grfKeyState);
  Effects := DropEffectToDropEffectStates(dwEffect);

  // Get the "Windows Style" effect with the key modifiers
  Effect := KeyStateToDropEffect(Keys);
  Owner.DoOLEDropTargetDragDrop(dataObj, KeyToKeyStates(grfKeyState), pt, DropEffectToDropEffectStates(dwEffect), Effect);

  if Assigned(DragManager) then
    DragManager.DragDrop(Owner.ScreenToClient(pt), Keys, Effect);

  dwEffect := DropEffectStateToDropEffect(Effect);
  Result := S_OK
end;

function TEasyDropTargetManager.GetDropTargetHelper: IDropTargetHelper;
begin
  if not Assigned(FDropTargetHelper) and IsWin2000 then
    if CoCreateInstance(CLSID_DragDropHelper, nil, CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER, IID_IDropTargetHelper, FDropTargetHelper) <> S_OK then
      FDropTargetHelper := nil;
  Result := FDropTargetHelper
end;

{ TEasyDropSourceManager }

function TEasyDropSourceManager.GiveFeedback(dwEffect: Integer): HResult;
var
  UseDefaultCursors: Boolean;
begin
  Result := DRAGDROP_S_USEDEFAULTCURSORS;
  UseDefaultCursors := True;
  Owner.DoOLEDropSourceGiveFeedback(DropEffectToDropEffectStates(dwEffect), UseDefaultCursors);
  // The application has set the cursor style
  if not UseDefaultCursors then
    Result := S_OK
end;

function TEasyDropSourceManager.QueryContinueDrag(fEscapePressed: BOOL;
  grfKeyState: Integer): HResult;
var
  QueryResult: TEasyQueryDragResult;
  KeyStates: TCommonKeyStates;
begin
  KeyStates := KeyToKeyStates(grfKeyState);
  if fEscapePressed then
    QueryResult := eqdrQuit
  else begin
    if cksButton in KeyStates then
      QueryResult := eqdrContinue
    else
      QueryResult := eqdrQuit
  end;

  // If no buttons are down anymore then the user dropped the objects
  if not(cksButton in KeyStates) then
    QueryResult := eqdrDrop;

  // Allow the application to modify if desired
  Owner.DoOLEDropSourceQueryContineDrag(fEscapePressed, KeyStates, QueryResult);
  if QueryResult = eqdrQuit then
    Result := DRAGDROP_S_CANCEL
  else
  if QueryResult = eqdrContinue then
    Result := S_OK
  else
  if QueryResult = eqdrDrop then
    Result := DRAGDROP_S_DROP
  else
    Result := E_UNEXPECTED
end;

function TCustomEasyDragManagerBase.DoPtInAutoScrollLeftRegion(WindowPoint: TPoint): Boolean;
begin
  Result := False;
end;

function TCustomEasyDragManagerBase.DoPtInAutoScrollRightRegion(WindowPoint: TPoint): Boolean;
begin
  Result := False;
end;

{ TEasyBaseDragManager }

procedure TCustomEasyDragManagerBase.AutoScrollWindow;
// This is called to autoscroll the window
var
  Pt: TPoint;
begin
  if Assigned(OwnerListview.Scrollbars) and OwnerListview.HandleAllocated then
  begin
    // Only scroll after an initial delay is met.  This is defined as the mouse
    // is in constantly the autoscroll area for AutoScrollDelay time
    if AutoScrollDelayMet then
    begin
      // It is just easier to grab the mouse position on the screen to do the
      // autoscroll for various operation (drag drop, drag select, etc.)
      Pt := OwnerListview.ScreenToClient(Mouse.CursorPos);

      if PtInAutoScrollUpRegion(Pt) then
        DoAutoScroll(0, -(ScrollDeltaUp(Pt) * AutoScrollAccelerator))
      else
      if PtInAutoScrollDownRegion(Pt) then
        DoAutoScroll(0, ScrollDeltaDown(Pt) * AutoScrollAccelerator);

      if PtInAutoScrollLeftRegion(Pt) then
        DoAutoScroll(-(ScrollDeltaLeft(Pt) * AutoScrollAccelerator), 0)
      else
      if PtInAutoScrollRightRegion(Pt) then
        DoAutoScroll(ScrollDeltaRight(Pt) * AutoScrollAccelerator, 0)
    end
  end;
end;

procedure TCustomEasyDragManagerBase.BeginDrag(WindowPoint: TPoint; KeyState: TCommonKeyStates);
begin
  DoDragBegin(WindowPoint, KeyState);
end;

constructor TCustomEasyDragManagerBase.Create(AnOwner: TCustomEasyListview);
begin
  inherited;
  FAutoScrollDelay := _AUTOSCROLLDELAY;
  FAutoScrollTime := _AUTOSCROLLTIME;
  FAutoScroll := True;
  FAutoScrollAccelerator := 2;
  FAutoScrollMargin := 15;
  FMouseButton := [cmbLeft];
end;

destructor TCustomEasyDragManagerBase.Destroy;
begin
  inherited;
end;

procedure TCustomEasyDragManagerBase.DoAfterAutoScroll;
begin

end;

procedure TCustomEasyDragManagerBase.DoAutoScroll(DeltaX, DeltaY: Integer);
var
  Msg: TWMMouse;
// Usually called from AutoScrollWindow which calcualate how to do the scroll.
begin
  // Need to flag the controls paint method to not worry about the selection
  // rect as we take care of it in the auto scroll
  DoBeforeAutoScroll;
  Include(FDragState, edmsAutoScrolling);
  OwnerListview.Scrollbars.Scroll(DeltaX, DeltaY);
  UpdateAfterAutoScroll;
  // Need to fake a mouse move to update any drag selection after a scroll
  Msg.Pos := PointToSmallPoint( OwnerListview.ScreenToClient(Mouse.CursorPos));
  Msg.Keys := 0;
  Msg.Msg := WM_MOUSEMOVE;
  OwnerListview.WMMouseMove(Msg);
  Exclude(FDragState, edmsAutoScrolling);
  DoAfterAutoScroll;
end;

procedure TCustomEasyDragManagerBase.DoBeforeAutoScroll;
begin

end;

procedure TCustomEasyDragManagerBase.DoDrag(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect);
begin

end;

procedure TCustomEasyDragManagerBase.DoDragBegin(WindowPoint: TPoint; KeyState: TCommonKeyStates);
begin

end;

procedure TCustomEasyDragManagerBase.DoDragDrop(WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect);
begin

end;

procedure TCustomEasyDragManagerBase.DoDragEnd(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates);
begin

end;

procedure TCustomEasyDragManagerBase.DoDragEnter(const DataObject: IDataObject; Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect);
begin

end;

procedure TCustomEasyDragManagerBase.DoEnable(Enable: Boolean);
begin

end;

procedure TCustomEasyDragManagerBase.DoGetDragImage(Bitmap: TBitmap; DragStartPt: TPoint; var HotSpot: TPoint; var TransparentColor: TColor; var Handled: Boolean);
begin

end;

procedure TCustomEasyDragManagerBase.DoOLEDragEnd(const ADataObject: IDataObject; DragResult: TCommonOLEDragResult; ResultEffect: TCommonDropEffects);
begin
  
end;

procedure TCustomEasyDragManagerBase.DoOLEDragStart(const ADataObject: IDataObject; var AvailableEffects: TCommonDropEffects; var AllowDrag: Boolean);
begin

end;

function TCustomEasyDragManagerBase.DoPtInAutoScrollDownRegion(WindowPoint: TPoint): Boolean;
begin
  Result := False
end;

function TCustomEasyDragManagerBase.DoPtInAutoScrollUpRegion(WindowPoint: TPoint): Boolean;
begin
  Result := False
end;

procedure TCustomEasyDragManagerBase.Drag(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect);
begin
  // Watch for an auto scroll
  if AutoScroll then
  begin
    // If the mouse is not in the window start the timer and prepare for autoscroll
    // If is then reset the flags and wait for the next time the mouse leaves the window
    if PtInAutoScrollRegion(WindowPoint) then
      Timer.Enabled := True
    else begin
      FAutoScrollDelayMet := False;
      Timer.Enabled := False
    end;
  end;
  LastKeyState := KeyState;
  DoDrag(Canvas, WindowPoint, KeyState, Effects)
end;

procedure TCustomEasyDragManagerBase.DragDrop(WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect);
begin
  FreeAndNil(FTimer);
  LastKeyState := [];
  Exclude(FDragState, edmsDragging);
  DoDragDrop(WindowPoint, KeyState, Effects);
  DataObject := nil;
end;

procedure TCustomEasyDragManagerBase.DragEnd(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates);
begin
  FreeAndNil(FTimer);
  LastKeyState := [];
  Exclude(FDragState, edmsDragging);
  DoDragEnd(Canvas, WindowPoint, KeyState);
  DataObject := nil;
end;

procedure TCustomEasyDragManagerBase.DragEnter(const ADataObject: IDataObject; Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect);
begin   
  Include(FDragState, edmsDragging);
  DataObject := ADataObject;
  Timer.Enabled := False;
  Timer.OnTimer := HandleTimer;
  Timer.Interval := AutoScrollDelay;
  FAutoScrollDelayMet := False;
  DoDragEnter(ADataObject, Canvas, WindowPoint, KeyState, Effects)
end;

function TCustomEasyDragManagerBase.GetAutoScrolling: Boolean;
begin
  Result := edmsAutoScrolling in DragState
end;

function TCustomEasyDragManagerBase.GetDragging: Boolean;
begin
  Result := edmsDragging in DragState
end;

function TCustomEasyDragManagerBase.GetTimer: TTimer;
begin
  if not Assigned(FTimer) then
    FTimer := TTimer.Create(nil);
  Result := FTimer;
end;

procedure TCustomEasyDragManagerBase.HandleTimer(Sender: TObject);
begin    
  if AutoScrollDelayMet then
    AutoScrollWindow
  else begin
    FAutoScrollDelayMet := True;
    Timer.Interval := AutoScrollTime;
  end
end;

function TCustomEasyDragManagerBase.IsWindowDropRegistered: Boolean;
var
  RegResult: HResult;
begin
  Result := False;
  if OwnerListview.HandleAllocated then
  begin
    OleInitialize(nil);
    RegResult := RegisterDragDrop(OwnerListview.Handle, OwnerListview.DropTarget);
    case RegResult of
      S_OK: RevokeDragDrop(OwnerListview.Handle);
      DRAGDROP_E_ALREADYREGISTERED: Result := True;
    end;
    OleUninitialize
  end
end;

function TCustomEasyDragManagerBase.PtInAutoScrollDownRegion(WindowPoint: TPoint): Boolean;
begin
  Result := DoPtInAutoScrollDownRegion(WindowPoint)
end;

function TCustomEasyDragManagerBase.PtInAutoScrollLeftRegion(WindowPoint: TPoint): Boolean;
begin
  Result := DoPtInAutoScrollLeftRegion(WindowPoint)
end;

function TCustomEasyDragManagerBase.PtInAutoScrollRegion(WindowPoint: TPoint): Boolean;
begin
  Result := PtInAutoScrollDownRegion(WindowPoint) or PtInAutoScrollLeftRegion(WindowPoint) or
    PtInAutoScrollRightRegion(WindowPoint) or PtInAutoScrollUpRegion(WindowPoint)
end;

function TCustomEasyDragManagerBase.PtInAutoScrollRightRegion(WindowPoint: TPoint): Boolean;
begin
  Result := DoPtInAutoScrollRightRegion(WindowPoint)
end;

function TCustomEasyDragManagerBase.PtInAutoScrollUpRegion(WindowPoint: TPoint): Boolean;
begin
  Result := DoPtInAutoScrollUpRegion(WindowPoint)
end;

function TCustomEasyDragManagerBase.ScrollDeltaDown(WindowPoint: TPoint): Integer;
begin
  Result := Abs(OwnerListview.ClientHeight -  WindowPoint.Y - AutoScrollMargin)
end;

function TCustomEasyDragManagerBase.ScrollDeltaLeft(WindowPoint: TPoint): Integer;
begin
  Result := Abs(WindowPoint.X - AutoScrollMargin)
end;

function TCustomEasyDragManagerBase.ScrollDeltaRight(WindowPoint: TPoint): Integer;
begin
  Result := Abs(OwnerListview.ClientWidth - WindowPoint.X - AutoScrollMargin )
end;

function TCustomEasyDragManagerBase.ScrollDeltaUp(WindowPoint: TPoint): Integer;
begin
  Result := Abs(WindowPoint.Y - OwnerListview.Header.RuntimeHeight - AutoScrollMargin)
end;

procedure TCustomEasyDragManagerBase.RegisterOLEDragDrop(DoRegister: Boolean);
begin
  if OwnerListview.HandleAllocated then
  begin
    if DoRegister then
    begin
      if not (ebcsOLERegistered in OwnerListview.States) then
      begin
        OleInitialize(nil);
        RegisterDragDrop(OwnerListview.Handle, OwnerListview.DropTarget);
        Include(OwnerListview.FStates, ebcsOLERegistered)
      end
    end else
    begin
      if ebcsOLERegistered in OwnerListview.States then
      begin
        RevokeDragDrop(OwnerListview.Handle);
        OleUninitialize;
        Exclude(OwnerListview.FStates, ebcsOLERegistered)
      end
    end;
  end
end;

procedure TCustomEasyDragManagerBase.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    DoEnable(Value);
    FEnabled := Value;
  end
end;

procedure TCustomEasyDragManagerBase.SetRegistered(Value: Boolean);
begin
  if Value <> FRegistered then
  begin
    RegisterOLEDragDrop(Value);
    FRegistered := Value;
  end
end;

procedure TCustomEasyDragManagerBase.UpdateAfterAutoScroll;
begin

end;

procedure TCustomEasyDragManagerBase.VCLDragStart;
begin

end;

procedure TCustomEasyDragManagerBase.WMKeyDown(var Msg: TWMKeyDown);
begin
  case Msg.CharCode of
    VK_HOME:  DoAutoScroll(-OwnerListview.Scrollbars.OffsetX, -OwnerListview.Scrollbars.OffsetY);
    VK_END:   DoAutoScroll(OwnerListview.Scrollbars.ViewWidth-OwnerListview.ClientWidth,
                     OwnerListview.Scrollbars.ViewHeight-OwnerListview.ClientHeight);
    VK_NEXT:  DoAutoScroll(0, OwnerListview.ClientHeight);
    VK_PRIOR: DoAutoScroll(0, -OwnerListview.ClientHeight);
    VK_UP:    DoAutoScroll(0, -OwnerListview.Scrollbars.Line);
    VK_DOWN:  DoAutoScroll(0, OwnerListview.Scrollbars.Line);
    VK_LEFT:  DoAutoScroll(-OwnerListview.Scrollbars.Line, 0);
    VK_RIGHT: DoAutoScroll(OwnerListview.Scrollbars.Line, 0);
  end;
end;

constructor TEasyDragRectManager.Create(AnOwner: TCustomEasyListview);
begin
  inherited;
  FMouseButton := [cmbLeft, cmbRight];
  FEnabled := False;
end;

destructor TEasyDragRectManager.Destroy;
begin
  inherited;
end;

function TEasyDragRectManager.DoPtInAutoScrollDownRegion(WindowPoint: TPoint): Boolean;
begin
  Result := (WindowPoint.Y > OwnerListview.ClientHeight - AutoScrollMargin) and
    (OwnerListview.Scrollbars.OffsetY < OwnerListview.Scrollbars.MaxOffsetY)
end;

function TEasyDragRectManager.DoPtInAutoScrollLeftRegion(WindowPoint: TPoint): Boolean;
begin
  Result := (WindowPoint.X < AutoScrollMargin) and (OwnerListview.Scrollbars.OffsetX > 0)
end;

function TEasyDragRectManager.DoPtInAutoScrollRightRegion(WindowPoint: TPoint): Boolean;
begin
  Result := (WindowPoint.X > (OwnerListview.ClientWidth - AutoScrollMargin)) and
    (OwnerListview.Scrollbars.OffsetX < OwnerListview.Scrollbars.MaxOffsetX)
end;

function TEasyDragRectManager.DoPtInAutoScrollUpRegion(WindowPoint: TPoint): Boolean;
begin
  Result := (WindowPoint.Y - OwnerListview.Header.RuntimeHeight < AutoScrollMargin) and (OwnerListview.Scrollbars.OffsetY > 0)
end;

procedure TEasyDragRectManager.DoAfterAutoScroll;
begin
  inherited;
end;

procedure TEasyDragRectManager.DoAutoScroll(DeltaX, DeltaY: Integer);
// Usually called from AutoScrollWindow which calcualate how to do the scroll.
// This method is usually overridden to perform the scroll in the passed direction
begin
  inherited;
end;

procedure TEasyDragRectManager.DoBeforeAutoScroll;
begin
  inherited;
  // Keep the Dragpoint in sync with the current view
  // Need to map the dragged point to a new point after a scroll
  FOldOffsets.X := OwnerListview.Scrollbars.OffsetX;
  FOldOffsets.Y := OwnerListview.Scrollbars.OffsetY;
end;

procedure TEasyDragRectManager.DoDrag(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect);
var
  ARect: TRect;
begin
  // Update the Selection due to this drag
  OwnerListview.Selection.DragSelect(KeyState);

  // Get the last rectangle
  FPrevRect := SelectionRect;
  inherited;

  // Update the drag point
  DragPoint := OwnerListview.Scrollbars.MapWindowToView(WindowPoint);
  // Map it to the Client window coordinates
  ARect := SelRectInWindowCoords;
  // Make sure it is confined in the visible window
  IntersectRect(ARect, ARect, OwnerListview.ClientRect);

  // May need to update the last rectangle to if the drag rect is getting smaller
  UnionRect(ARect, ARect, OwnerListview.Scrollbars.MapViewRectToWindowRect(PrevRect));

  // Reentrant possibility
  if not(edmsAutoScrolling in DragState) then
    AutoScrollWindow;

  // Always have to update for update the selection rectangle if it gets smaller
  OwnerListview.SafeInvalidateRect(@ARect, True);
end;

procedure TEasyDragRectManager.DoDragBegin(WindowPoint: TPoint; KeyState: TCommonKeyStates);
begin
  inherited;
  FPrevRect := SelectionRect;
end;

procedure TEasyDragRectManager.DoDragEnd(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates);
var
  ARect: TRect;
begin
  // Erase the selection rectangle, mainly for the XOR FocusRect when not DoubleBuffered
  inherited;
  // Get the last rectangle
  ARect := SelRectInWindowCoords;
  // Make sure it is confined in the visible window
  IntersectRect(ARect, ARect, OwnerListview.ClientRect);

  // Redraw the window
  OwnerListview.SafeInvalidateRect(@ARect, True);

  AnchorPoint := Point(0, 0);
  DragPoint := Point(0, 0);
  FPrevRect := Rect(0, 0, 0, 0);
end;

procedure TEasyDragRectManager.DoDragEnter(const DataObject: IDataObject; Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect);
begin
  inherited DoDragEnter(DataObject, Canvas, WindowPoint, KeyState, Effects);
  FDragPoint := WindowPoint
end;

procedure TEasyDragRectManager.FinalizeDrag(KeyState: TCommonKeyStates);
// Does not mean the action actually occured it means that InitializeDrag was
// called and this is it matching call.  EndDrag means that the drag actually
// occured
begin

end;

function TEasyDragRectManager.GetSelectionRect: TRect;
begin
  Result := ProperRect(Rect(AnchorPoint.X, AnchorPoint.Y, DragPoint.X, DragPoint.Y));
  if Result.Top = Result.Bottom then // added
    Inc(Result.Bottom);
  if Result.Left = Result.Right then // added
    Inc(Result.Right);
end;

function TEasyDragRectManager.InitializeDrag(WindowPoint: TPoint; KeyState: TCommonKeyStates): Boolean;
// Does not mean that the action will be a Selection Drag, it just means get
// ready for one just in case.
begin
  Result := False;
  if Enabled then
  begin
    if ((cksLButton in KeyState) and (cmbLeft in MouseButton)) or
       ((cksMButton in KeyState) and (cmbMiddle in MouseButton)) or
       ((cksRButton in KeyState) and (cmbRight in MouseButton))
    then begin
      AnchorPoint := OwnerListview.Scrollbars.MapWindowToView(WindowPoint);
      DragPoint := AnchorPoint;
      Result := True
    end
  end
end;

procedure TEasyDragRectManager.PaintRect(Canvas: TCanvas);
// Paints the selection rectangle to the canvas:
// NOTE:  DO NOT USE THIS METHOD DIRECTLY use the PaintSelectionRect to draw
// the rectangle
// If not DoubleBuffered it is assumed that the Canvas is a Screen DC else it is
// assumed to be a Bitmap Compatiable Memory DC
var
  SelectRect: TRect;
begin
  SelectRect.TopLeft := OwnerListview.Scrollbars.MapViewToWindow(AnchorPoint);
  SelectRect.BottomRight := OwnerListview.Scrollbars.MapViewToWindow(DragPoint);
  SelectRect := ProperRect(SelectRect);
  IntersectRect(SelectRect, SelectRect, OwnerListview.ClientRect);

  if (OwnerListview.ViewSupportsHeader) and (OwnerListview.Header.Visible) then
  begin
    if SelectRect.Top < OwnerListview.Header.Height then
      SelectRect.Top := OwnerListview.Header.Height;
  end;
  
  if OwnerListview.Selection.AlphaBlendSelRect and HasMMX then
  begin
    Canvas.Brush.Color := OwnerListview.Selection.BorderColorSelRect;
    MPCommonUtilities.AlphaBlend(0, Canvas.Handle, SelectRect, Point(0, 0),
      cbmConstantAlphaAndColor, OwnerListview.Selection.BlendAlphaSelRect,
      ColorToRGB(OwnerListview.Selection.BlendColorSelRect));
    Canvas.FrameRect(SelectRect);
  end else
  begin
    Canvas.Font.Assign(OwnerListview.Font);
    Canvas.Brush.Color := OwnerListview.Color;
    Canvas.Font.Color := clBlack;
    DrawFocusRect(Canvas.Handle, SelectRect);
  end
end;

procedure TEasyDragRectManager.PaintSelectionRect(Canvas: TCanvas);
  // Causes the Selection Rectangle to be drawn or "erased" (erased is just redrawn
  // again in the same place so the XOR mode will clear the rectangle)
  // NOTE:  Use this method and not the PaintRect method directly
begin
  PaintRect(Canvas);
end;

function TEasyDragRectManager.SelRectInWindowCoords: TRect;
// Gets the selection rectangle in the current Window coordinates then trims off
// the pieces that do not lie in the current window rectangle
begin
  Result.TopLeft := OwnerListview.Scrollbars.MapViewToWindow(AnchorPoint);
  Result.BottomRight := OwnerListview.Scrollbars.MapViewToWindow(DragPoint);
  Result := ProperRect(Result);
end;

procedure TEasyDragRectManager.SetAnchorPoint(ViewportAnchor: TPoint);
begin
  FAnchorPoint := ViewportAnchor
end;

procedure TEasyDragRectManager.SetDragPoint(const Value: TPoint);
begin
  FDragPoint := Value
end;

procedure TEasyDragRectManager.UpdateAfterAutoScroll;
begin
  inherited UpdateAfterAutoScroll;
  // Keep the Dragpoint in sync with the current view
  // Need to map the dragged point to a new point after a scroll
  FDragPoint.X := DragPoint.X + (OwnerListview.Scrollbars.OffsetX - OldOffsets.X);
  FDragPoint.Y := DragPoint.Y + (OwnerListview.Scrollbars.OffsetY - OldOffsets.Y);
end;

procedure TEasyDragRectManager.WMKeyDown(var Msg: TWMKeyDown);
begin
  inherited;
end;

{ TCustomEasyListview }
constructor TCustomEasyListview.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  NCCanvas := TCanvas.Create;
  FGroupFont := TFont.Create;
  OldGroupFontChangeNotify := Font.OnChange;
  GroupFont.OnChange := GroupFontChanged;
  OldFontChangeNotify := Font.OnChange;
  Font.OnChange := FontChanged;
  FPaintInfoGroup := CreateGroupPaintInfo;
  FPaintInfoItem := CreateItemPaintInfo;
  FPaintInfoColumn := CreateColumnPaintInfo;
  PaintInfoGroup.FMarginBottom.FPaintInfo := TEasyPaintInfoGroup.Create(Self);
  FHotTrack := TEasyHotTrackManager.Create(Self);
  FBackBits := TBitmap.Create;
  BackBits.PixelFormat := pf32Bit;
  BackBits.Canvas.Lock;
  Canvas.Control := Self;
  ParentColor := False;
  Brush.Color := clWindow;
  Color := clWindow;
  BevelInner := bvLowered;
  BevelKind := bkTile;
  ControlStyle := ControlStyle - [csCaptureMouse, csOpaque, csAcceptsControls]; // We will do this ourselves
  FBackGround := TEasyBackgroundManager.Create(Self);
  FScrollbars := TEasyScrollbarManager.Create(Self);
  FDropTarget := TEasyDropTargetManager.Create(Self);
  FDragRect := TEasyDragRectManager.Create(Self);
  FDragManager := TEasyOLEDragManager.Create(Self);
  FCheckManager := TEasyCheckManager.Create(Self);
  FSelection := TEasySelectionManager.Create(Self);
  FGroups := TEasyGroups.Create(Self);
  FHeader := TEasyHeader.Create(Self);
  FEditManager := TEasyEditManager.Create(Self);
  FGlobalImages := TEasyGlobalImageManager.Create(Self);
  HintInfo := TEasyHintInfo.Create(Self);
  FCellSizes := TEasyCellSizes.Create(Self);
  FSort := TEasySortManager.Create(Self);
  TabStop := True;
  FWheelMouseDefaultScroll := edwsVert;
  FWheelMouseScrollModifierEnabled := True;
  FGroupCollapseButton := TBitmap.Create;
  FGroupExpandButton := TBitmap.Create;
  FItems := TEasyGlobalItems.Create(Self);
  FShowGroupMargins := False;
  FShowThemedBorder := True;
  DisabledBlendAlpha := 128;
  DisabledBlendColor := clWindow;
  FIncrementalSearch := TEasyIncrementalSearchManager.Create(Self);
  FScratchCanvas := TControlCanvas.Create;
  FScratchCanvas.Control := Self;
  if IsUnicode then
  begin
    GroupFont.Name := 'MS Shell Dlg 2';
    Font.Name := 'MS Shell Dlg 2';
    Header.Font.Name := 'MS Shell Dlg 2';
  end
end;

destructor TCustomEasyListview.Destroy;
begin
  Groups.Clear; // Clear the items first so there is no chance of trying to draw them after the window is destroyed
  Header.Columns.Clear; // Clear the columns first so there is no chance of trying to draw them after the window is destroyed
  Font.OnChange := OldFontChangeNotify;
  inherited Destroy;
  DropTarget := nil;
  GroupFont.OnChange := OldGroupFontChangeNotify;
  // Don't destroy these objects until the Window is destroyed
  GroupExpandButton.Canvas.Unlock;
  GroupCollapseButton.Canvas.Unlock;
  FreeAndNil(FItems);
  FreeAndNil(FNCCanvas);
  FreeAndNil(FGroupExpandButton);
  FreeAndNil(FGroupCollapseButton);
  FreeAndNil(FBackGround);
  BackBits.Canvas.Unlock;
  FreeAndNil(FBackBits);
  FreeAndNil(FScrollbars);
  FreeAndNil(FDragRect);
  FreeAndNil(FDragManager);
  FreeAndNil(FCheckManager);
  FreeAndNil(FSelection);
  FreeAndNil(FHeader);
  FreeAndNil(FEditManager);
  FreeAndNil(FGlobalImages);
  FreeAndNil(FCellSizes);
  {$IFDEF COMPILER_5_UP}
  FreeAndNil(FGroupFont);   // Bug in D4
  {$ENDIF COMPILER_5_UP}
  FreeAndNil(FPaintInfoGroup);
  FreeAndNil(FPaintInfoItem);
  FreeAndNil(FPaintInfoColumn);
  FreeAndNil(FHotTrack);
  FreeAndNil(FHintInfo);
  FreeAndNil(FSort);
  FreeAndNil(FIncrementalSearch);
  FreeAndNil(FScratchCanvas);
  FreeAndNil(FGroups);  // Always make Last
end;

function TCustomEasyListview.ClickTestGroup(ViewportPoint: TPoint;
  KeyStates: TCommonKeyStates; var HitInfo: TEasyGroupHitTestInfoSet): TEasyGroup;
//
// Handles any default behavior of clicking on a group and returns true if the
// click was on a group object
//
begin
  HitInfo := [];
  Result := Groups.GroupByPoint(ViewportPoint);
  if Assigned(Result) then
    Result.HitTestAt(ViewportPoint, HitInfo);
end;

function TCustomEasyListview.ClickTestItem(ViewportPoint: TPoint;
  Group: TEasyGroup; KeyStates: TCommonKeyStates;
  var HitInfo: TEasyItemHitTestInfoSet): TEasyItem;
begin
  Result := nil;
  HitInfo := [];

  if not Assigned(Group) then
    Group := Groups.GroupByPoint(ViewportPoint);
  if Assigned(Group) then
    Result := Group.ItembyPoint(ViewportPoint);
 //   Result := Groups.ItcmbyPoint(ViewportPoint);

  if Assigned(Result) then
    Result.HitTestAt(ViewportPoint, HitInfo);
end;

function TCustomEasyListview.ClientInViewportCoords: TRect;
begin
  Result := ClientRect;
  Result.Top := Result.Top + Header.RuntimeHeight;
  Result := Scrollbars.MapWindowRectToViewRect(Result)
end;

function TCustomEasyListview.CreateColumnPaintInfo: TEasyPaintInfoBaseColumn;
begin
  Result := TEasyPaintInfoColumn.Create(Self)
end;

function TCustomEasyListview.CreateGroupPaintInfo: TEasyPaintInfoBaseGroup;
begin
  Result := TEasyPaintInfoGroup.Create(Self)
end;

function TCustomEasyListview.CreateItemPaintInfo: TEasyPaintInfoBaseItem;
begin
  Result := TEasyPaintInfoItem.Create(Self);
end;

function TCustomEasyListview.DoMouseWheel(Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint): Boolean;
var
  LocalMouseScroll: TEasyDefaultWheelScroll;
  uiParam, pvParam: UINT;
  IsNeg: Boolean;
begin
  IsNeg := WheelDelta < 0;

  uiParam := 0;
  pvParam := 3;

  if IsWinNT then
    SystemParametersInfo(SPI_GETWHEELSCROLLLINES, uiParam, @pvParam, 0);

  if WheelMouseDefaultScroll = edwsVert then
    WheelDelta := Min(Groups.CellHeight * Integer(pvParam),Round(Height/1.2))
  else
    WheelDelta := Min(Groups.CellWidth * Integer(pvParam),Round(Width/1.2));

  if IsNeg then
    WheelDelta := -WheelDelta;
    
  Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);

  LocalMouseScroll := WheelMouseDefaultScroll;

  if WheelMouseScrollModifierEnabled then
  begin
    if (ssShift in Shift) then
    begin
      if WheelMouseDefaultScroll = edwsVert then
        LocalMouseScroll := edwsHorz
      else
        LocalMouseScroll := edwsVert
    end;
    if ssCtrl in Shift then
    begin
      if LocalMouseScroll = edwsVert then
        WheelDelta := ClientHeight - Header.RuntimeHeight
      else
        WheelDelta := ClientWidth;
      if IsNeg then
        WheelDelta := -WheelDelta;
    end
  end;

  if LocalMouseScroll = edwsVert then
    Scrollbars.Scroll(0, -WheelDelta)
  else
  if LocalMouseScroll = edwsHorz then
    Scrollbars.Scroll(-WheelDelta, 0);

  if not Result then
    Result := True;
end;

function TCustomEasyListview.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := inherited DoMouseWheelDown(Shift, MousePos);
end;

function TCustomEasyListview.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := inherited DoMouseWheelUp(Shift, MousePos);
end;

function TCustomEasyListview.DragInitiated: Boolean;
begin
  Result := [ebcsDragSelecting, ebcsDragging, ebcsDragSelectPending, ebcsDragPending] * States <> []
end;

function TCustomEasyListview.GetGroupCollapseImage: TBitmap;
begin
  Result := FGroupCollapseButton
end;

function TCustomEasyListview.GetGroupExpandImage: TBitmap;
begin
  Result := FGroupExpandButton
end;

function TCustomEasyListview.GetHintType: TEasyHintType;
begin
  Result := HintInfo.HintType
end;

function TCustomEasyListview.GetPaintInfoColumn: TEasyPaintInfoBaseColumn;
begin
  Result := FPaintInfoColumn;
end;

function TCustomEasyListview.GetPaintInfoGroup: TEasyPaintInfoBaseGroup;
begin
  Result := FPaintInfoGroup;
end;

function TCustomEasyListview.GetPaintInfoItem: TEasyPaintInfoBaseItem;
begin
  Result := FPaintInfoItem;
end;

function TCustomEasyListview.GetScratchCanvas: TControlCanvas;
begin
  if HandleAllocated then
    Result := FScratchCanvas
  else
    Result := nil
end;

function TCustomEasyListview.GetSortColumn: TEasyColumn;
begin
  Result := Selection.FocusedColumn
end;

function TCustomEasyListview.GroupTestExpand(HitInfo: TEasyGroupHitTestInfoSet): Boolean;
begin
  Result := egtOnExpandButton in HitInfo
end;

function TCustomEasyListview.IsFontStored: Boolean;
begin
  Result := not ParentFont and not DesktopFont;
end;

function TCustomEasyListview.IsHeaderMouseMsg(MousePos: TSmallPoint; ForceTest: Boolean = False): Boolean;
var
  R: TRect;
begin
  Result := False;
  if not (DragRect.Dragging or DragManager.Dragging or Header.DragManager.Dragging) or ForceTest then
  begin
    R := Header.DisplayRect;
    R.Bottom := Header.RuntimeHeight;
    Result := (ViewSupportsHeader and PtInRect(R, SmallPointToPoint(MousePos))) or
      (ebcsHeaderCapture in States) or Assigned(Header.HotTrackedColumn)
  end
end;

function TCustomEasyListview.IsThumbnailView: Boolean;
begin
  Result := View in THUMBNAILVIEWS
end;

function TCustomEasyListview.IsVertView: Boolean;
begin
  Result := View in VERTICALVIEWS
end;

function TCustomEasyListview.ToolTipNeeded(TargetObj: TEasyCollectionItem;
  var TipCaption: WideString): Boolean;
// Calcuates if the text is being truncated in the current view of the object
// If so the result is true.
var
  TextFlags: TCommonDrawTextWFlags;
  RectArray: TEasyRectArrayObject;
  R: TRect;
  LineCount: Integer;
  Item: TEasyItem;
begin
  Result := False;
  TipCaption := '';
  if TargetObj is TEasyItem then
  begin
    Item := TEasyItem( TargetObj);
    if not Item.Focused then
    begin
      Item.ItemRectArray(nil, Canvas, RectArray);
      TextFlags := [dtLeft, dtCalcRect, dtCalcRectAdjR];

      R := RectArray.LabelRect;
      LineCount := Item.View.PaintTextLineCount(Item, nil);
      Item.View.LoadTextFont(Item, 0, Canvas, False);
      DrawTextWEx(Canvas.Handle, Item.Caption, R, TextFlags, LineCount);


      if (RectWidth(RectArray.TextRect) < RectWidth(R)) or
        (RectHeight(RectArray.TextRect) < RectHeight(R)) then
      begin
        TipCaption := Item.Caption;
        Result := True;
      end
    end
  end
end;

function TCustomEasyListview.ViewSupportsHeader: Boolean;
begin
  Result := View in HEADERSUPPORTEDVIEWS
end;

procedure TCustomEasyListview.BeginUpdate;
begin
  inherited BeginUpdate;
  Sort.BeginUpdate;
end;

procedure TCustomEasyListview.CancelCut;
var
  Item: TEasyItem;
begin
  Item := Groups.FirstItem;
  while Assigned(Item) do
  begin
    Item.Cut := False;
    Item := Groups.NextItem(Item)
  end
end;

procedure TCustomEasyListview.CheckFocus;
begin
  if not Focused then
  begin
    if CanFocus and not (csDesigning in ComponentState) then
      SetFocus;
  end;
end;

procedure TCustomEasyListview.ClearPendingDrags;
begin
  States := States - [ebcsDragPending, ebcsDragSelectPending];
  DragManager.ClearDragItem;
end;

procedure TCustomEasyListview.ClearStates;
begin
  Exclude(FStates, ebcsLButtonDown);
  Exclude(FStates, ebcsMButtonDown);
  Exclude(FStates, ebcsRButtonDown);
  Exclude(FStates, ebcsDragSelecting);
  Exclude(FStates, ebcsDragSelectPending);
  Exclude(FStates, ebcsDragSelecting);
  Exclude(FStates, ebcsDragPending);
  Exclude(FStates, ebcsDragging);
  Exclude(FStates, ebcsScrollButtonDown);
  Exclude(FStates, ebcsVCLDrag);
  Exclude(FStates, ebcsCheckboxClickPending);
  Exclude(FStates, ebcsHeaderCapture);
  Exclude(FStates, ebcsGroupExpandPending); 
  if not Themed then
    CheckManager.PendingObject := nil;
end;

procedure TCustomEasyListview.ClipHeader(ACanvas: TCanvas; ResetClipRgn: Boolean);
var
  OldOrg: TPoint;
begin
  if ResetClipRgn then
    SelectClipRgn(ACanvas.Handle, 0);
  if Header.RuntimeHeight > 0 then
  begin
    SetWindowOrgEx(ACanvas.Handle, 0, 0, @OldOrg);
    if ViewSupportsHeader and (Header.Visible) then
      ExcludeClipRect(ACanvas.Handle, 0, 0, ClientWidth, Header.RuntimeHeight);
    SetWindowOrgEx(ACanvas.Handle, OldOrg.X, OldOrg.Y, nil);
  end
end;

procedure TCustomEasyListview.CMDrag(var Msg: TCMDrag);
// Called during a VCL drag and drop operation
var
  Keys: TCommonKeyStates;
  P: TPoint;
  Effects: TCommonDropEffect;

  {$IFDEF LOG_VCL_CMDRAG}
  F: TFileStream;
  S: string;
  Buffer: array[0..MAX_PATH] of char;
  {$ENDIF}
begin

  {$IFDEF LOG_VCL_CMDRAG}
  FillChar(Buffer, SizeOf(Buffer), #0);
  GetModuleFileName(hInstance, Buffer, MAX_PATH);
  S := ExtractFilePath(Buffer) + 'VCL Drag.log';
  try
    F := TFileStream.Create(S, fmOpenReadWrite or fmShareExclusive);
  except
    F := TFileStream.Create(S, fmCreate   or fmShareExclusive);
  end;
  F.Seek(0, soFromEnd);

  case Msg.DragMessage of
    dmDragEnter:  S := 'dmDragEnter';
    dmDragLeave:  S := 'dmDragLeave';
    dmDragMove:   S := 'dmDragMove';
    dmDragDrop:   S := 'dmDragDrop';
    dmDragCancel: S := 'dmDragCancel';
    dmFindTarget: S := 'dmFindTarget';
  end;
  S := S + #13+#10;
  F.Write(PChar(S)^, Length(S));
  F.Free;
  {$ENDIF}

  Keys := [];
  Effects := cdeNone;
  case Msg.DragMessage of
    dmDragEnter:
      begin
        DragManager.DragEnter(nil, nil, ScreenToClient(Msg.DragRec^.Pos), Keys, Effects);
        inherited;
      end;
    dmDragLeave:
      begin
        // The VCL DD stupidly sends a Drag Leave before the Drag Drop.  This
        // causes problems since I use DragEnd to reset a lot of the DragManagers
        // flags.  Check if the drop was on this window.  If it was skip the
        // Drag end and wait for the Drag Drop
        GetCursorPos(P);
        if WindowFromPoint(P) <> Handle then
        begin
          DragManager.DragEnd(nil, ScreenToClient(Msg.DragRec^.Pos), Keys);
          ClearStates;
        end;
        inherited;
      end;
    dmDragMove:
    begin
      DragManager.Drag(nil, ScreenToClient(Msg.DragRec^.Pos), Keys, Effects);
      inherited;
    end;
    dmDragDrop:
      begin
        inherited;
        DragManager.DragDrop(ScreenToClient(Msg.DragRec^.Pos), Keys, Effects);
        ClearStates;
      end;
    dmDragCancel:
      begin
        DragManager.DragEnd(nil, ScreenToClient(Msg.DragRec^.Pos), Keys);
        inherited;
        ClearStates;
      end;
  else
    inherited;
  end;
end;

procedure TCustomEasyListview.CMHintShow(var Message: TCMHintShow);
var
  Allow: Boolean;
  TargetObj: TEasyCollectionItem;
  ItemHitInfo: TEasyItemHitTestInfoSet;
  GroupHitInfo: TEasyGroupHitTestInfoSet;
  ViewPt: TPoint;
begin
  {$IFDEF GXDEBUG_HINT}
  SendDebug('CMHintShow');
  {$ENDIF GXDEBUG_HINT}

  ViewPt := Scrollbars.MapWindowToView(Message.HintInfo^.CursorPos);

  // See if we have hit any objects of interest
  TargetObj := Groups.ItembyPoint(ViewPt);
  if Assigned(TargetObj) then
  begin
    TEasyItem( TargetObj).HitTestAt(ViewPt, ItemHitInfo);
    if not(ehtOnClickselectBounds in ItemHitInfo) then
      TargetObj := nil
  end;

  if not Assigned(TargetObj) then
  begin
    TargetObj := Groups.GroupByPoint(ViewPt);
    if Assigned(TargetObj) then
      TEasyGroup( TargetObj).HitTestAt(ViewPt, GroupHitInfo);
  end;

  // Default hint type is Text
  FHintData.HintType := HintInfo.HintType;

  FHintData.HintStr := Hint;
  FHintData.ReshowTimeout := Message.HintInfo^.ReshowTimeout;
  FHintData.HideTimeout := Message.HintInfo^.HideTimeout;

  // Allow the application to modify the HintData
  Allow := False;
  DoHintPopup(TargetObj, FHintData.HintType, Message.HintInfo^.CursorPos, FHintData.HintStr, FHintData.HideTimeout, FHintData.ReshowTimeout, Allow);
  if FHintData.HintStr = '' then
    Allow := False;

  Message.HintInfo^.ReshowTimeout := FHintData.ReshowTimeout;
  Message.HintInfo^.HideTimeout := FHintData.HideTimeout;

  SetRect(FHintData.ToolTipRect, 0, 0, Screen.Width, 0);

  // If the type is ToolTip then calculate if it is necessary
  if (FHintData.HintType = ehtToolTip) then
  begin
    if TargetObj is TEasyItem then
      Allow := ToolTipNeeded(TargetObj, FHintData.HintStr)
    else
      Allow := False;
  end;

  if Allow then
  begin
    Message.HintInfo.HintWindowClass := TEasyHintWindow;

    // Send our HintData to the Hint Window through the supplied Data parameter
    Message.HintInfo.HintData := @FHintData;
    if Message.HintInfo.HintStr = '' then
      Message.HintInfo.HintStr := 'Dummy';

    // Area where the tip is defined, once outside the Hint testing will resume
    if TargetObj is TEasyItem then
      Message.HintInfo^.CursorRect := TargetObj.DisplayRect;

    if TargetObj is TEasyGroup then
    begin
      if egtOnRightMargin in GroupHitInfo then
        Message.HintInfo^.CursorRect := TEasyGroup( TargetObj).BoundsRectRightMargin
      else
      if egtOnLeftMargin in GroupHitInfo then
        Message.HintInfo^.CursorRect := TEasyGroup( TargetObj).BoundsRectLeftMargin
      else
      if egtOnHeader in GroupHitInfo then
        Message.HintInfo^.CursorRect := TEasyGroup( TargetObj).BoundsRectTopMargin
      else
      if egtOnFooter in GroupHitInfo then
        Message.HintInfo^.CursorRect := TEasyGroup( TargetObj).BoundsRectBottomMargin;
    end;

    Message.HintInfo^.CursorRect := Scrollbars.MapViewRectToWindowRect(Message.HintInfo^.CursorRect);

    FHintData.Listview := Self;
    FHintData.HintControl := Message.HintInfo^.HintControl;
    FHintData.HintWindowClass := Message.HintInfo^.HintWindowClass;
    FHintData.HintPos := Message.HintInfo^.HintPos;
    FHintData.HintMaxWidth := Message.HintInfo^.HintMaxWidth;
    FHintData.HintColor := Message.HintInfo^.HintColor;
    FHintData.CursorRect := Message.HintInfo^.CursorRect;
    FHintData.CursorPos := Message.HintInfo^.CursorPos;
    FHintData.HintData := nil;
    FHintData.TargetObj := TargetObj;
    inherited;
  end else
    Message.Result := 1;   // Message is handled, don't show the hint
end;

procedure TCustomEasyListview.CMHintShowPause(var Message: TCMHintShow);
var
  HintShowing: Boolean;
  PauseTime: PInteger;
begin
  {$IFDEF GXDEBUG_HINT}
  SendDebug('CMHintShowPause');
  {$ENDIF GXDEBUG_HINT}
  PauseTime := PInteger(TMessage(Message).LParam);
  HintShowing := Boolean( TMessage(Message).wParam);
  DoHintShowPause(HintShowing, PauseTime^);
  inherited
end;

procedure TCustomEasyListview.CMMouseWheel(var Msg: TWMMouseWheel);
begin
  inherited
end;

procedure TCustomEasyListview.CMParentFontChanged(var Msg: TMessage);
begin
  inherited;
  if ParentFont then
  begin
    Font.Assign(TWinControlCracker(Parent).Font);
    GroupFont.Assign(TWinControlCracker(Parent).Font);
    Header.Font.Assign(TWinControlCracker(Parent).Font);
    // Reset the flag as the OnChange events will clear it
    ParentFont := True
  end
end;

procedure TCustomEasyListview.CopyToClipboard;
begin

end;

procedure TCustomEasyListview.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WindowClass.Style := Params.WindowClass.Style or CS_DBLCLKS and not (CS_HREDRAW or CS_VREDRAW);
  Params.Style := Params.Style or WS_CLIPCHILDREN  or WS_CLIPSIBLINGS;
end;

procedure TCustomEasyListview.CreateWnd;
begin
  inherited;
  DoUpdate;
  // The Window Handle is now valid
  DragManager.Registered := DragManager.Enabled;
  Header.DragManager.Registered := false;//Header.DragManager.Enabled;
  ResizeBackBits(ClientWidth, ClientHeight);
end;

procedure TCustomEasyListview.CutToClipboard;
var
  Handled, Mark: Boolean;
begin
  Handled := False;
  Mark := True;
  DoClipboardCut(Handled, Mark);
  if Handled and Mark then
    MarkSelectedCut
end;

procedure TCustomEasyListview.DestroyWnd;
begin
  inherited;
end;

procedure TCustomEasyListview.DoAutoGroupGetKey(Item: TEasyItem; ColumnIndex: Integer; Groups: TEasyGroups; var Key: LongWord);
begin
  if Assigned(OnAutoGroupGetKey) then
    OnAutoGroupGetKey(Self, Item, ColumnIndex, Groups, Key)
end;

procedure TCustomEasyListview.DoAutoSortGroupCreate(Item: TEasyItem; ColumnIndex: Integer; Groups: TEasyGroups; var Group: TEasyGroup; var DoDefaultAction: Boolean);
begin
  if Assigned(OnAutoSortGroupCreate) then
    OnAutoSortGroupCreate(Self, Item, ColumnIndex, Groups, Group, DoDefaultAction);
  if not Assigned(Group) then
    Group := Groups.Add
end;

procedure TCustomEasyListview.DoClipboardCopy(var Handled: Boolean);
begin
  if Assigned(OnClipboardCopy) then
    OnClipboardCopy(Self, Handled);
end;

procedure TCustomEasyListview.DoClipboardCut(var MarkAsCut, Handled: Boolean);
begin
  if Assigned(OnClipboardCut) then
    OnClipboardCut(Self, MarkAsCut, Handled);
end;

procedure TCustomEasyListview.DoClipboardPaste(var Handled: Boolean);
begin
  if Assigned(OnClipboardPaste) then
    OnClipboardPaste(Self, Handled);
end;

procedure TCustomEasyListview.DoColumnCheckChanged(Column: TEasyColumn);
begin
  if Assigned(OnColumnCheckChanged) and not (csDestroying in ComponentState) then
    OnColumnCheckChanged(Self, Column)
end;

procedure TCustomEasyListview.DoColumnCheckChanging(Column: TEasyColumn; var Allow: Boolean);
begin
  if Assigned(OnColumnCheckChanging) and not (csDestroying in ComponentState) then
    OnColumnCheckChanging(Self, Column, Allow)
end;

procedure TCustomEasyListview.DoColumnClick(Button: TCommonMouseButton;
  const Column: TEasyColumn);
begin
  if Assigned(OnColumnClick) then
    OnColumnClick(Self, Button, Column)
end;

procedure TCustomEasyListview.DoColumnContextMenu(HitInfo: TEasyHitInfoColumn; WindowPoint: TPoint; var Menu: TPopupMenu);
begin
  if Assigned(OnColumnContextMenu) then
    OnColumnContextMenu(Self, HitInfo, WindowPoint, Menu);
end;

procedure TCustomEasyListview.DoColumnDblClick(Button: TCommonMouseButton; ShiftState: TShiftState; MousePos: TPoint; Column: TEasyColumn);
begin
  if Assigned(OnColumnDblClick) then
    OnColumnDblClick(Self, Button, MousePos, Column)
end;

procedure TCustomEasyListview.DoColumnEnableChanged(Column: TEasyColumn);
begin
  if Assigned(OnColumnEnableChanged) and not (csDestroying in ComponentState) then
    OnColumnEnableChanged(Self, Column)
end;

procedure TCustomEasyListview.DoColumnEnableChanging(Column: TEasyColumn; var Allow: Boolean);
begin
  if Assigned(OnColumnEnableChanging) and not (csDestroying in ComponentState) then
    OnColumnEnableChanging(Self, Column, Allow)
end;

procedure TCustomEasyListview.DoColumnFocusChanged(Column: TEasyColumn);
begin
  if Assigned(OnColumnFocusChanged) and not (csDestroying in ComponentState) then
    OnColumnFocusChanged(Self, Column)
end;

procedure TCustomEasyListview.DoColumnFocusChanging(Column: TEasyColumn; var Allow: Boolean);
begin
  if Assigned(OnColumnFocusChanging) and not (csDestroying in ComponentState) then
    OnColumnFocusChanging(Self, Column, Allow)
end;

procedure TCustomEasyListview.DoColumnFreeing(Column: TEasyColumn);
begin
  if Assigned(OnColumnFreeing) then
    OnColumnFreeing(Self, Column)
end;

procedure TCustomEasyListview.DoColumnGetCaption(Line: Integer; var Caption: WideString);
begin
  if Assigned(OnColumnGetCaption) then
   OnColumnGetCaption(Self, Line, Caption)
end;

procedure TCustomEasyListview.DoColumnGetDetail(Column: TEasyColumn; Line: Integer; var Detail: Integer);
begin
  if Assigned(OnColumnGetDetail) then
    OnColumnGetDetail(Self, Column, Line, Detail)
end;

procedure TCustomEasyListview.DoColumnGetDetailCount(Column: TEasyColumn; var Count: Integer);
begin
  if Assigned(OnColumnGetDetailCount) then
    OnColumnGetDetailCount(Self, Column, Count)
end;

procedure TCustomEasyListview.DoColumnGetImageIndex(Column: TEasyColumn; ImageKind: TEasyImageKind; var ImageIndex: Integer);
begin
  if Assigned(OnColumnGetImageIndex) then
    OnColumnGetImageIndex(Self, Column, ImageKind, ImageIndex)
end;

procedure TCustomEasyListview.DoColumnGetImageList(Column: TEasyColumn; var ImageList: TImageList);
begin
  if Assigned(OnColumnGetImageList) then
    OnColumnGetImageList(Self, Column, ImageList)
end;

procedure TCustomEasyListview.DoColumnImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
begin
  if Assigned(OnColumnImageDraw) then
    OnColumnImageDraw(Self, Column, ACanvas, RectArray, AlphaBlender)
end;

procedure TCustomEasyListview.DoColumnImageGetSize(Column: TEasyColumn; var ImageWidth, ImageHeight: Integer);
begin
  if Assigned(OnColumnImageGetSize) then
    OnColumnImageGetSize(Self, Column, ImageWidth, ImageHeight)
end;

procedure TCustomEasyListview.DoColumnImageDrawIsCustom(Column: TEasyColumn;
  var IsCustom: Boolean);
begin
  if Assigned(OnColumnImageDrawIsCustom) then
    OnColumnImageDrawIsCustom(Self, Column, IsCustom)
end;

procedure TCustomEasyListview.DoColumnInitialize(Column: TEasyColumn);
begin
  if Assigned(OnColumnInitialize) then
    OnColumnInitialize(Self, Column)
end;

procedure TCustomEasyListview.DoColumnLoadFromStream(Column: TEasyColumn; S: TStream; Version: Integer = STREAM_VERSION);
begin
  if Assigned(OnColumnLoadFromStream) then
    OnColumnLoadFromStream(Self, Column, S, Version);
end;

procedure TCustomEasyListview.DoColumnPaintText(Column: TEasyColumn;
  ACanvas: TCanvas);
begin
  if Assigned(OnColumnPaintText) then
    OnColumnPaintText(Self, Column, ACanvas)
end;

procedure TCustomEasyListview.DoColumnSaveToStream(Column: TEasyColumn; S: TStream; Version: Integer = STREAM_VERSION);
begin
  if Assigned(OnColumnSaveToStream) then
    OnColumnSaveToStream(Self, Column, S, Version);
end;

procedure TCustomEasyListview.DoColumnSelectionChanged(Column: TEasyColumn);
begin
  if Assigned(OnColumnSelectionChanged) and not (csDestroying in ComponentState) then
    OnColumnSelectionChanged(Self, Column)
end;

procedure TCustomEasyListview.DoColumnSelectionChanging(Column: TEasyColumn; var Allow: Boolean);
begin
  if Assigned(OnColumnSelectionChanging) and not (csDestroying in ComponentState) then
    OnColumnSelectionChanging(Self, Column, Allow)
end;

procedure TCustomEasyListview.DoColumnSetCaption(Column: TEasyColumn; const Caption: WideString);
begin
  if Assigned(OnColumnSetCaption) then
    OnColumnSetCaption(Self, Column, Caption)
end;

procedure TCustomEasyListview.DoColumnSetDetail(Column: TEasyColumn; Line: Integer; Detail: Integer);
begin
  if Assigned(OnColumnSetDetail) then
    OnColumnSetDetail(Self, Column, Line, Detail)
end;

procedure TCustomEasyListview.DoColumnSetDetailCount(Column: TEasyColumn; DetailCount: Integer);
begin
  ///
end;

procedure TCustomEasyListview.DoColumnSetImageIndex(Column: TEasyColumn; ImageKind: TEasyImageKind; ImageIndex: Integer);
begin
  if Assigned(OnColumnSetImageIndex) then
    OnColumnSetImageIndex(Self, Column, ImageKind, ImageIndex)
end;

procedure TCustomEasyListview.DoColumnSizeChanged(Column: TEasyColumn);
begin
  if Assigned(OnColumnSizeChanged) and not (csDestroying in ComponentState) then
    OnColumnSizeChanged(Self, Column)
end;

procedure TCustomEasyListview.DoColumnSizeChanging(Column: TEasyColumn; Size, NewSize: Integer; var Allow: Boolean);
begin
  if Assigned(OnColumnSizeChanging) and not (csDestroying in ComponentState) then
    OnColumnSizeChanging(Self, Column, Size, NewSize, Allow)
end;

procedure TCustomEasyListview.DoColumnThumbnailDraw(Column: TEasyColumn; ACanvas: TCanvas; ARect: TRect; var DoDefault: Boolean);
begin

end;

procedure TCustomEasyListview.DoColumnVisibilityChanged(Column: TEasyColumn);
begin
  if Assigned(OnColumnVisibilityChanged) then
    OnColumnVisibilityChanged(Self, Column)
end;

procedure TCustomEasyListview.DoColumnVisibilityChanging(Column: TEasyColumn; var Allow: Boolean);
begin
  if Assigned(OnColumnVisibilityChanging) then
    OnColumnVisibilityChanging(Self, Column, Allow)
end;

procedure TCustomEasyListview.DoContextMenu(MousePt: TPoint; var Handled: Boolean);
begin
  if Assigned(OnContextMenu) then
    OnContextMenu(Self, MousePt, Handled)
end;

procedure TCustomEasyListview.DoCustomColumnView(var View: TEasyViewColumn);
begin
  if Assigned(OnCustomColumnView) then
    OnCustomColumnView(Self, View);
  if not Assigned(View) then
    View := TEasyViewColumn.Create(Self);
end;

procedure TCustomEasyListview.DoCustomGrid(ViewStyle: TEasyListStyle; var Grid: TEasyGridGroupClass);
begin
  if Assigned(OnCustomGrid) then
    OnCustomGrid(Self, ViewStyle, Grid)
end;

procedure TCustomEasyListview.DoCustomView(ViewStyle: TEasyListStyle; var View: TEasyViewItemClass);
begin
  if Assigned(OnCustomView) then
    OnCustomView(Self, ViewStyle, View)
end;

procedure TCustomEasyListview.DoDblClick(Button: TCommonMouseButton; MousePos: TPoint;
  ShiftState: TShiftState);
begin
  if Assigned(OnDblClick) then
    OnDblClick(Self, Button, MousePos, ShiftState)
end;

procedure TCustomEasyListview.DoGetDragImage(Bitmap: TBitmap;
  DragStartPt: TPoint; var HotSpot: TPoint; var TransparentColor: TColor;
  var Handled: Boolean);
begin
  if Assigned(OnGetDragImage) then
    OnGetDragImage(Self, Bitmap, DragStartPt, HotSpot, TransparentColor, Handled);
end;

procedure TCustomEasyListview.DoGroupClick(Group: TEasyGroup; KeyStates: TCommonKeyStates; HitTest: TEasyGroupHitTestInfoSet);
begin
  if Assigned(OnGroupClick) then
    OnGroupClick(Self, Group, KeyStates, HitTest)
end;

procedure TCustomEasyListview.DoGroupCollapse(Group: TEasyGroup);
begin
  if Assigned(OnGroupCollapse) and not (csDestroying in ComponentState) then
    OnGroupCollapse(Self, Group);
end;

procedure TCustomEasyListview.DoGroupCollapsing(Group: TEasyGroup; var Allow: Boolean);
begin
  if Assigned(OnGroupCollapsing) and not (csDestroying in ComponentState) then
    OnGroupCollapsing(Self, Group, Allow);
end;

function TCustomEasyListview.DoGroupCompare(Column: TEasyColumn; Group1,
  Group2: TEasyGroup): Integer;
begin
  if Assigned(OnGroupCompare) then
    Result := OnGroupCompare(Self, Group1, Group2)
  else
    Result := DefaultSort(Column, Group1, Group2)
end;

procedure TCustomEasyListview.DoGroupContextMenu(HitInfo: TEasyHitInfoGroup;
  WindowPoint: TPoint; var Menu: TPopupMenu; var Handled: Boolean);
begin
  if Assigned(OnGroupContextMenu) then
    OnGroupContextMenu(Self, HitInfo, WindowPoint, Menu, Handled);
end;

procedure TCustomEasyListview.DoGroupDblClick(Button: TCommonMouseButton;
  MousePos: TPoint; HitInfo: TEasyHitInfoGroup);
begin
  if Assigned(OnGroupDblClick) then
    OnGroupDblClick(Self, Button, MousePos, HitInfo)
end;

procedure TCustomEasyListview.DoGroupExpand(Group: TEasyGroup);
begin
  Groups.Rebuild;
  if Assigned(OnGroupExpand) then
    OnGroupExpand(Self, Group)
end;

procedure TCustomEasyListview.DoGroupExpanding(Group: TEasyGroup; var Allow: Boolean);
begin
  if Assigned(OnGroupExpanding) then
    OnGroupExpanding(Self, Group, Allow)
end;

procedure TCustomEasyListview.DoGroupHotTrack(Group: TEasyGroup; State: TEasyHotTrackstate; MousePos: TPoint);
begin
  if Assigned(OnGroupHotTrack) then
    OnGroupHotTrack(Self, Group, State, MousePos)
end;

procedure TCustomEasyListview.DoGroupFreeing(Group: TEasyGroup);
begin
  if Assigned(OnGroupFreeing) then
    OnGroupFreeing(Self, Group)
end;

procedure TCustomEasyListview.DoGroupGetCaption(Group: TEasyGroup; var Caption: WideString);
begin
  if Assigned(OnGroupGetCaption) then
   OnGroupGetCaption(Self, Group, Caption)
end;

procedure TCustomEasyListview.DoGroupGetDetail(Group: TEasyGroup; Line: Integer; var Detail: Integer);
begin
  if Assigned(OnGroupGetDetail) then
   OnGroupGetDetail(Self, Group, Line, Detail)
end;

procedure TCustomEasyListview.DoGroupGetDetailCount(Group: TEasyGroup; var Count: Integer);
begin
  if Assigned(OnGroupGetDetailCount) then
   OnGroupGetDetailCount(Self, Group, Count)
end;

procedure TCustomEasyListview.DoGroupGetImageIndex(Group: TEasyGroup; ImageKind: TEasyImageKind; var ImageIndex: Integer);
begin
  if Assigned(OnGroupGetImageIndex) then
    OnGroupGetImageIndex(Self, Group, ImageKind, ImageIndex)
end;

procedure TCustomEasyListview.DoGroupGetImageList(Group: TEasyGroup; var ImageList: TImageList);
begin
  if Assigned(OnGroupGetImageList) then
    OnGroupGetImageList(Self, Group, ImageList)
end;

procedure TCustomEasyListview.DoGroupImageDraw(Group: TEasyGroup; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
begin
  if Assigned(OnGroupImageDraw) then
    OnGroupImageDraw(Self, Group, ACanvas, RectArray, AlphaBlender)
end;

procedure TCustomEasyListview.DoGroupImageGetSize(Group: TEasyGroup; var ImageWidth, ImageHeight: Integer);
begin
  if Assigned(OnGroupImageGetSize) then
    OnGroupImageGetSize(Self, Group, ImageWidth, ImageHeight)
end;

procedure TCustomEasyListview.DoGroupImageDrawIsCustom(Group: TEasyGroup;
  var IsCustom: Boolean);
begin
  if Assigned(OnGroupImageDrawIsCustom) then
    OnGroupImageDrawIsCustom(Self, Group, IsCustom)
end;

procedure TCustomEasyListview.DoGroupInitialize(Group: TEasyGroup);
begin
  if Assigned(OnGroupInitialize) then
    OnGroupInitialize(Self, Group)
end;

procedure TCustomEasyListview.DoGroupLoadFromStream(Group: TEasyGroup; S: TStream; Version: Integer = STREAM_VERSION);
begin
  if Assigned(OnGroupLoadFromStream) then
    OnGroupLoadFromStream(Self, Group, S, Version)
end;

procedure TCustomEasyListview.DoGroupPaintText(Group: TEasyGroup;
  ACanvas: TCanvas);
begin
  if Assigned(OnGroupPaintText) then
    OnGroupPaintText(Self, Group, ACanvas)
end;

procedure TCustomEasyListview.DoGroupSaveToStream(Group: TEasyGroup; S: TStream; Version: Integer = STREAM_VERSION);
begin
  if Assigned(OnGroupSaveToStream) then
    OnGroupSaveToStream(Self, Group, S, Version)
end;

procedure TCustomEasyListview.DoGroupSelectionChanged(Group: TEasyGroup);
begin
  if Assigned(OnGroupSelectionChanged) then
    OnGroupSelectionChanged(Self, Group)
end;

procedure TCustomEasyListview.DoGroupSelectionChanging(Group: TEasyGroup; var Allow: Boolean);
begin
  if Assigned(OnGroupSelectionChanging) then
    OnGroupSelectionChanging(Self, Group, Allow)
end;

procedure TCustomEasyListview.DoGroupSetCaption(Group: TEasyGroup; const Caption: WideString);
begin
  if Assigned(OnGroupSetCaption) then
    OnGroupSetCaption(Self, Group, Caption)
end;

procedure TCustomEasyListview.DoGroupSetDetailCount(Group: TEasyGroup; DetailCount: Integer);
begin
  ///
end;

procedure TCustomEasyListview.DoGroupSetImageIndex(Group: TEasyGroup; ImageKind: TEasyImageKind; ImageIndex: Integer);
begin
  if Assigned(OnGroupSetImageIndex) then
    OnGroupSetImageIndex(Self, Group, ImageKind, ImageIndex)
end;

procedure TCustomEasyListview.DoGroupSetDetail(Group: TEasyGroup; Line: Integer; Detail: Integer);
begin
  if Assigned(OnGroupSetDetail) then
    OnGroupSetDetail(Self, Group, Line, Detail)
end;

procedure TCustomEasyListview.DoGroupThumbnailDraw(Group: TEasyGroup; ACanvas: TCanvas; ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
begin
// not implemented
end;

procedure TCustomEasyListview.DoGroupVisibilityChanged(Group: TEasyGroup);
begin
  if Assigned(OnGroupVisibilityChanged) and not (csDestroying in ComponentState) then
    OnGroupVisibilityChanged(Self, Group)
end;

procedure TCustomEasyListview.DoGroupVisibilityChanging(Group: TEasyGroup; var Allow: Boolean);
begin
  if Assigned(OnGroupVisibilityChanging) and not (csDestroying in ComponentState) then
    OnGroupVisibilityChanging(Self, Group, Allow)
end;

procedure TCustomEasyListview.DoHeaderDblClick(Button: TCommonMouseButton; MousePos: TPoint;
  ShiftState: TShiftState);
begin
  if Assigned(OnHeaderDblClick) then
    OnHeaderDblClick(Self, Button, MousePos, ShiftState)
end;

procedure TCustomEasyListview.DoHintCustomInfo(TargetObj: TEasyCollectionItem; const Info: TEasyHintInfo);
begin
  if Assigned(OnHintCustomInfo) then
    OnHintCustomInfo(Self, TargetObj, Info);
end;

procedure TCustomEasyListview.DoHintCustomDraw(TargetObj: TEasyCollectionItem; const Info: TEasyHintInfo);
begin
  if Assigned(OnHintCustomDraw) then
    OnHintCustomDraw(Self, TargetObj, Info);
end;

procedure TCustomEasyListview.DoHintPopup(TargetObj: TEasyCollectionItem; HintType: TEasyHintType; MousePos: TPoint; var AText: WideString; var HideTimeout, ReshowTimeout: Integer; var Allow: Boolean);
begin
  if Assigned(OnHintPopup) then
    OnHintPopup(Self, TargetObj, HintType, MousePos, AText, HideTimeout, ReshowTimeout, Allow)
end;

procedure TCustomEasyListview.DoHintShowPause(HintShowingNow: Boolean;
  var PauseTime: Integer);
begin
  if Assigned(OnHintPauseTime) then
    OnHintPauseTime(Self, HintShowingNow, PauseTime)
end;

procedure TCustomEasyListview.DoIncrementalSearch(Item: TEasyItem;
  const SearchBuffer: WideString; var CompareResult: Integer);
begin
  CompareResult := 0;
  if Assigned(OnIncrementalSearch) then
    OnIncrementalSearch(Item, SearchBuffer, CompareResult);
end;

procedure TCustomEasyListview.DoItemCheckChanged(Item: TEasyItem);
begin
  if Assigned(OnItemCheckChange) and not (csDestroying in ComponentState) then
    OnItemCheckChange(Self, Item)
end;

procedure TCustomEasyListview.DoItemCheckChanging(Item: TEasyItem;
  var Allow: Boolean);
begin
  if Assigned(OnItemCheckChanging) and not (csDestroying in ComponentState) then
    OnItemCheckChanging(Self, Item, Allow);
end;

procedure TCustomEasyListview.DoItemClick(Item: TEasyItem;
  KeyStates: TCommonKeyStates; HitInfo: TEasyItemHitTestInfoSet);
begin
  if Assigned(OnItemClick) then
    OnItemClick(Self, Item, KeyStates, HitInfo)
end;

function TCustomEasyListview.DoItemCompare(Column: TEasyColumn;
  Group: TEasyGroup; Item1, Item2: TEasyItem): Integer;
begin
  if Assigned(OnItemCompare) then
    Result := OnItemCompare(Self, Column, Group, Item1, Item2)
  else
    Result := DefaultSort(Column, Item1, Item2)
end;

procedure TCustomEasyListview.DoItemContextMenu(HitInfo: TEasyHitInfoItem;
  WindowPoint: TPoint; var Menu: TPopupMenu; var Handled: Boolean);
begin
  Menu := nil;
  if Assigned(OnItemContextMenu) then
    OnItemContextMenu(Self, HitInfo, WindowPoint, Menu, Handled);
end;

procedure TCustomEasyListview.DoItemCreateEditor(Item: TEasyItem;
  var Editor: IEasyCellEditor);
begin
  if Assigned(OnItemCreateEditor) then
    OnItemCreateEditor(Self, Item, Editor);
  if not Assigned(Editor) then
  begin
    if View in MULTILINEVIEWS then
      Editor := TEasyMemoEditor.Create
    else
      Editor := TEasyStringEditor.Create;
  end
end;

procedure TCustomEasyListview.DoItemDblClick(Button: TCommonMouseButton;
  MousePos: TPoint; HitInfo: TEasyHitInfoItem);
begin
  if Assigned(OnItemDblClick) then
    OnItemDblClick(Self, Button, MousePos, HitInfo)
end;

procedure TCustomEasyListview.DoItemEditBegin(Item: TEasyItem; var Column: Integer; var Allow: Boolean);
begin
  if Assigned(OnItemEditBegin) then
    OnItemEditBegin(Self, Item, Column, Allow)
end;

procedure TCustomEasyListview.DoItemEdited(Item: TEasyItem;
  var NewValue: Variant; var Accept: Boolean);
begin
  if Assigned(OnItemEdited) then
    OnItemEdited(Self, Item, NewValue, Accept);
end;

procedure TCustomEasyListview.DoItemEditEnd(Item: TEasyItem);
begin
  if Assigned(OnItemEditEnd) then
    OnItemEditEnd(Self, Item);
end;

procedure TCustomEasyListview.DoItemEnableChanged(Item: TEasyItem);
begin
  if Assigned(OnItemEnableChange) then
    OnItemEnableChange(Self, Item)
end;

procedure TCustomEasyListview.DoItemEnableChanging(Item: TEasyItem;
  var Allow: Boolean);
begin
  if Assigned(OnItemEnableChanging) then
    OnItemEnableChanging(Self, Item, Allow)
end;

procedure TCustomEasyListview.DoItemFocusChanged(Item: TEasyItem);
begin
  if Assigned(OnItemFocusChanged) then
    OnItemFocusChanged(Self, Item)
end;

procedure TCustomEasyListview.DoItemFocusChanging(Item: TEasyItem;
  var Allow: Boolean);
begin
  if Assigned(OnItemFocusChanging) then
    OnItemFocusChanging(Self, Item, Allow)
end;

procedure TCustomEasyListview.DoItemFreeing(Item: TEasyItem);
begin
  if Assigned(OnItemFreeing) then
    OnItemFreeing(Self, Item)
end;

procedure TCustomEasyListview.DoItemGetCaption(Item: TEasyItem; Column: Integer; var Caption: WideString);
begin
  if Assigned(OnItemGetCaption) then
    OnItemGetCaption(Self, Item, Column, Caption)
end;

procedure TCustomEasyListview.DoItemGetEditCaption(Item: TEasyItem; Column: TEasyColumn; var Caption: WideString);
begin
  if Assigned(OnItemGetEditCaption) then
    OnItemGetEditCaption(Self, Item, Column, Caption)
end;

procedure TCustomEasyListview.DoItemGetGroupKey(Item: TEasyItem;
  FocusedColumn: Integer; var Key: LongWord);
begin
  if Assigned(OnItemGetGroupKey) then
    OnItemGetGroupKey(Self, Item, FocusedColumn, Key)
end;

procedure TCustomEasyListview.DoItemGetImageIndex(Item: TEasyItem; Column: Integer; ImageKind: TEasyImageKind; var ImageIndex: Integer);
begin
  if Assigned(OnItemGetImageIndex) then
    OnItemGetImageIndex(Self, Item, Column, ImageKind, ImageIndex)
end;

procedure TCustomEasyListview.DoItemGetImageList(Item: TEasyItem; Column: Integer; var ImageList: TImageList);
begin
  if Assigned(OnItemGetImageList) then
    OnItemGetImageList(Self, Item, Column, ImageList)
end;

procedure TCustomEasyListview.DoItemGetTileDetail(Item: TEasyItem; Line: Integer; var Detail: Integer);
begin
  if Assigned(OnItemGetTileDetail) then
    OnItemGetTileDetail(Self, Item, Line, Detail)
end;

procedure TCustomEasyListview.DoItemGetTileDetailCount(Item: TEasyItem; var Count: Integer);
begin
  if Assigned(OnItemGetTileDetailCount) then
    OnItemGetTileDetailCount(Self, Item, Count)
end;

procedure TCustomEasyListview.DoItemImageDraw(Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
begin
  if Assigned(OnItemImageDraw) then
    OnItemImageDraw(Self, Item, Column, ACanvas, RectArray, AlphaBlender)
end;

procedure TCustomEasyListview.DoItemImageGetSize(Item: TEasyItem; Column: TEasyColumn; var ImageWidth, ImageHeight: Integer);
begin
  if Assigned(OnItemImageGetSize) then
    OnItemImageGetSize(Self, Item, Column, ImageWidth, ImageHeight)
end;

procedure TCustomEasyListview.DoItemImageDrawIsCustom(Column: TEasyColumn;
  Item: TEasyItem; var IsCustom: Boolean);
begin
  if Assigned(OnItemImageDrawIsCustom) then
    OnItemImageDrawIsCustom(Self, Item, Column, IsCustom)
end;

procedure TCustomEasyListview.DoItemHotTrack(Item: TEasyItem; State: TEasyHotTrackstate; MousePos: TPoint);
begin
  if HotTrack.Enabled then
    if Assigned(OnItemHotTrack) then
      OnItemHotTrack(Self, Item, State, MousePos)
end;

procedure TCustomEasyListview.DoItemInitialize(Item: TEasyItem);
begin
  if Assigned(OnItemInitialize) then
    OnItemInitialize(Self, Item)
end;

procedure TCustomEasyListview.DoItemLoadFromStream(Item: TEasyItem; S: TStream; Version: Integer = STREAM_VERSION);
begin
  if Assigned(OnItemLoadFromStream) then
    OnItemLoadFromStream(Self, Item, S, Version)
end;

procedure TCustomEasyListview.DoItemMouseDown(Item: TEasyItem; Button: TCommonMouseButton; var DoDefault: Boolean);
begin
  if Assigned(OnItemMouseDown) then
    OnItemMouseDown(Self, Item, Button, DoDefault)
end;

procedure TCustomEasyListview.DoItemMouseUp(Item: TEasyItem; Button: TCommonMouseButton; var DoDefault: Boolean);
begin
  if Assigned(OnItemMouseUp) then
    OnItemMouseUp(Self, Item, Button, DoDefault)
end;

procedure TCustomEasyListview.DoItemPaintText(Item: TEasyItem; Position: Integer; ACanvas: TCanvas);
begin
  if Assigned(OnItemPaintText) then
    OnItemPaintText(Self, Item, Position, ACanvas)
end;

procedure TCustomEasyListview.DoItemSaveToStream(Item: TEasyItem; S: TStream; Version: Integer = STREAM_VERSION);
begin
  if Assigned(OnItemSaveToStream) then
    OnItemSaveToStream(Self, Item, S, Version)
end;

procedure TCustomEasyListview.DoItemSelectionChanged(Item: TEasyItem);
begin
  if Assigned(OnItemSelectionChanged) and not (csDestroying in ComponentState) then
    OnItemSelectionChanged(Self, Item)
end;

procedure TCustomEasyListview.DoItemSelectionChanging(Item: TEasyItem;
  var Allow: Boolean);
begin
  if Assigned(OnItemSelectionChanging) and not (csDestroying in ComponentState) then
    OnItemSelectionChanging(Self, Item, Allow)
end;

procedure TCustomEasyListview.DoItemSelectionsChanged;
begin
  if Assigned(OnItemSelectionsChanged) and not (csDestroying in ComponentState) then
    OnItemSelectionsChanged(Self)
end;

procedure TCustomEasyListview.DoItemSetCaption(Item: TEasyItem; Column: Integer; const Caption: WideString);
begin
  if Assigned(OnItemSetCaption) then
    OnItemSetCaption(Self, Item, Column, Caption)
end;

procedure TCustomEasyListview.DoItemSetGroupKey(Item: TEasyItem;
  FocusedColumn: Integer; Key: LongWord);
begin
  if Assigned(OnItemSetGroupKey) then
    OnItemSetGroupKey(Self, Item, FocusedColumn, Key)
end;

procedure TCustomEasyListview.DoItemSetImageIndex(Item: TEasyItem; Column: Integer; ImageKind: TEasyImageKind; ImageIndex: Integer);
begin
  if Assigned(OnItemSetImageIndex) then
    OnItemSetImageIndex(Self, Item, Column, ImageKind, ImageIndex)
end;

procedure TCustomEasyListview.DoItemSetTileDetail(Item: TEasyItem; Line: Integer; Detail: Integer);
begin
  if Assigned(OnItemSetTileDetail) then
    OnItemSetTileDetail(Self, Item, Line, Detail)
end;

procedure TCustomEasyListview.DoItemSetTileDetailCount(Item: TEasyItem; Detail: Integer);
begin
  //
end;

procedure TCustomEasyListview.DoItemThumbnailDraw(Item: TEasyItem;
  ACanvas: TCanvas; ARect: TRect; AlphaBlender: TEasyAlphaBlender;
  var DoDefault: Boolean);
begin
  if Assigned(OnItemThumbnailDraw) then
    OnItemThumbnailDraw(Self, Item, ACanvas, ARect, AlphaBlender, DoDefault)
end;

procedure TCustomEasyListview.DoItemVisibilityChanged(Item: TEasyItem);
begin
  if Assigned(OnItemVisibilityChanged) and not (csDestroying in ComponentState) then
    OnItemVisibilityChanged(Self, Item)
end;

procedure TCustomEasyListview.DoItemVisibilityChanging(Item: TEasyItem;
  var Allow: Boolean);
begin
  if Assigned(OnItemVisibilityChanging) and not (csDestroying in ComponentState)then
    OnItemVisibilityChanging(Self, Item, Allow)
end;

procedure TCustomEasyListview.DoKeyAction(var CharCode: Word;
  var Shift: TShiftState; var DoDefault: Boolean);
begin
  if Assigned(OnKeyAction) then
    OnKeyAction(Self, CharCode, Shift, DoDefault)
end;

procedure TCustomEasyListview.DoOLEDragEnd(ADataObject: IDataObject;
  DragResult: TCommonOLEDragResult; ResultEffect: TCommonDropEffects);
begin
  if Assigned(OnOLEDragEnd) then
    OnOLEDragEnd(Self, ADataObject, DragResult, ResultEffect);
end;

procedure TCustomEasyListview.DoOLEDragStart(ADataObject: IDataObject;
  var AvailableEffects: TCommonDropEffects; var AllowDrag: Boolean);
begin
  if Assigned(OnOLEDragStart) then
    OnOLEDragStart(Self, ADataObject, AvailableEffects, AllowDrag);
end;

procedure TCustomEasyListview.DoOLEDropSourceGiveFeedback(
  Effect: TCommonDropEffects; var UseDefaultCursors: Boolean);
// When the control is the OLE Drag source, this is called when OLE subsystem
// wants to display a different drag cursor (different than the drag image).  By
// default the built in cursors are used but the application may set the cursors
// itself in this event
begin
  if Assigned(OnOLEGiveFeedback) then
    OnOLEGiveFeedback(Self, Effect, UseDefaultCursors)
end;

procedure TCustomEasyListview.DoOLEDropSourceQueryContineDrag(
  EscapeKeyPressed: Boolean; KeyStates: TCommonKeyStates;
  var QueryResult: TEasyQueryDragResult);
// When the control is the OLE Drag source the OLE subsystem calls back to the
// source to query if the source would like to contine the drag, quit the drag,
// or drop the object where it is.
begin
  if Assigned(OnOLEQueryContineDrag) then
    OnOLEQueryContineDrag(Self, EscapeKeyPressed, KeyStates, QueryResult)
end;

procedure TCustomEasyListview.DoOLEDropTargetDragDrop(DataObject: IDataObject;
  KeyState: TCommonKeyStates; WindowPt: TPoint; AvailableEffects: TCommonDropEffects;
  var DesiredEffect: TCommonDropEffect);
// When the control is the OLE Drag target this is called when the data object is
// dropped on the control
begin
  if Assigned(OnOLEDragDrop) then
    OnOLEDragDrop(Self, DataObject, KeyState, WindowPt, AvailableEffects, DesiredEffect)
end;

procedure TCustomEasyListview.DoOLEDropTargetDragEnter(DataObject: IDataObject;
  KeyState: TCommonKeyStates; WindowPt: TPoint; AvailableEffects: TCommonDropEffects;
  var DesiredEffect: TCommonDropEffect);
// When the control is the OLE Drag target this is called when the drag object
// first enters the controls client window
begin
  if Assigned(OnOLEDragEnter) then
    OnOLEDragEnter(Self, DataObject, KeyState, WindowPt, AvailableEffects, DesiredEffect)
end;

procedure TCustomEasyListview.DoOLEDropTargetDragLeave;
// When the control is the OLE Drag target this is called when the data object
// leaves the controls client window
begin
  if Assigned(OnOLEDragLeave) then
    OnOLEDragLeave(Self)
end;

procedure TCustomEasyListview.DoOLEDropTargetDragOver(KeyState: TCommonKeyStates;
  WindowPt: TPoint; AvailableEffects: TCommonDropEffects;
  var DesiredEffect: TCommonDropEffect);
// When the control is the OLE Drag target this is called when the data object is
// moving over the controls client window
begin
  if Assigned(OnOLEDragOver) then
    OnOLEDragOver(Self, KeyState, WindowPt, AvailableEffects, DesiredEffect)
end;

procedure TCustomEasyListview.DoOLEGetCustomFormats(var Formats: TEasyFormatEtcArray);
begin
  if Assigned(OnOLEGetCustomFormats) then
    OnOLEGetCustomFormats(Self, Formats)
end;

procedure TCustomEasyListview.DoOLEGetData(const FormatEtcIn: TFormatEtc;
  var Medium: TStgMedium; var Handled: Boolean);
// Called from the IDataObject when a target wants the source (us) to give it the
// OLE data
begin
  FillChar(Medium, SizeOf(Medium), #0);
  Handled := False;
  if Assigned(OnOLEGetData) then
    OnOLEGetData(Self, FormatEtcIn, Medium, Handled);
end;

procedure TCustomEasyListview.DoOLEGetDataObject(var DataObject: IDataObject);
begin
  DataObject := nil;
  if Assigned(OnOLEGetDataObject) then
    OnOLEGetDataObject(Self, DataObject)
end;

procedure TCustomEasyListview.DoPaintHeaderBkGnd(ACanvas: TCanvas; ARect: TRect; var Handled: Boolean);
begin
  if Assigned(OnPaintHeaderBkGnd) then
    OnPaintHeaderBkGnd(Self, ACanvas, ARect, Handled)
end;

procedure TCustomEasyListview.DoPaintRect(ACanvas: TCanvas; WindowClipRect: TRect;
  SelectedOnly: Boolean);
// Paints the control defined by Rect to the passed canvas.  Called from the
// WM_PAINT message or can be called to make a snapshot of the control
// ARect is in Window coordinates.

    procedure PaintAndGetNextColumn(var Column: TEasyColumn; Item: TEasyItem; ItemRect, ViewClipRect: TRect; OrgPt: TPoint; Clip, ForceSelectionRectDraw: Boolean);
    begin
      ClipHeader(ACanvas, True);
      SetWindowOrgEx(ACanvas.Handle, Scrollbars.OffsetX, Scrollbars.OffsetY - Header.RuntimeHeight, nil);
      if Clip then
      begin
        IntersectRect(ItemRect, ItemRect, ViewClipRect);
        IntersectClipRect(ACanvas.Handle, ItemRect.Left, ItemRect.Top, ItemRect.Right, ItemRect.Bottom);
      end;
      Item.Paint(ACanvas, ViewClipRect, Column, ForceSelectionRectDraw);

      Column := Header.NextColumnInRect(Column, ViewClipRect);
    end;

    procedure PaintReportView(Item: TEasyItem; ViewClipRect: TRect; OrgPt: TPoint);
    var
      R: TRect;
      Column: TEasyColumn;
      RectArray: TEasyRectArrayObject;
    begin
      Column := Header.FirstColumnInRect(ViewClipRect);

      if Item.Selected or Item.Hilighted then
      begin
        if Selection.GroupSelections then
          PaintAndGetNextColumn(Column, Item, Item.DisplayRect, ViewClipRect, OrgPt, False, True)
        else
        if Selection.FullRowSelect then
          PaintAndGetNextColumn(Column, Item, Item.DisplayRect, ViewClipRect, OrgPt, True, True);
      end;

      while Assigned(Column) do
        PaintAndGetNextColumn(Column, Item, Item.DisplayRect, ViewClipRect, OrgPt, False, False);

      // Special processing for Full Row Select
      if Selection.FullRowSelect and Focused and Selection.UseFocusRect and Item.Focused and not SelectedOnly then
      begin
        // Draw a Focus Rectangle around focused item
        ClipHeader(ACanvas, True);
        ACanvas.Brush.Color := Color;
        ACanvas.Font.Color := clBlack;
        Item.ItemRectArray(Header.FirstColumnByPosition, ACanvas, RectArray);
        R := Selection.FocusedItem.DisplayRect;
        if not Selection.FullCellPaint then
          if not Selection.FullItemPaint then
            R.Left := RectArray.SelectionRect.Left;
        DrawFocusRect(ACanvas.Handle, R);
      end
    end;

var
  Group, FirstVisibleGroup: TEasyGroup;
  Item: TEasyItem;
  Column: TEasyColumn;
  OrgPt: TPoint;
  ViewClipRect, R: TRect;
begin
  GroupCollapseButton.Canvas.Lock;
  GroupExpandButton.Canvas.Lock;
  GetWindowOrgEx(Canvas.Handle, OrgPt);
  try
    // Header accounted for in the DC Offset
    ViewClipRect := Scrollbars.MapWindowRectToViewRect(WindowClipRect, True);

    if not SelectedOnly then
    begin
      if Assigned(Background) and not SelectedOnly then
        BackGround.PaintTo(ACanvas, WindowClipRect, False);
      SelectClipRgn(Canvas.Handle, 0);
      SetWindowOrgEx(ACanvas.Handle, Scrollbars.OffsetX, 0, nil);

      if ViewSupportsHeader and Header.Visible then
        Header.PaintTo(ACanvas, ViewClipRect);

      ClipHeader(ACanvas, True);

      SetWindowOrgEx(ACanvas.Handle, Scrollbars.OffsetX, Scrollbars.OffsetY - Header.RuntimeHeight, nil);
      Group := Groups.FirstGroupInRect(ViewClipRect);
      while Assigned(Group) do
      begin
        Group.Paint(egmeBackground, Group.DisplayRect, ACanvas);
        Group.Paint(egmeTop, Group.BoundsRectTopMargin, ACanvas);
        Group.Paint(egmeBottom, Group.BoundsRectBottomMargin, ACanvas);
        Group.Paint(egmeLeft, Group.BoundsRectLeftMargin, ACanvas);
        Group.Paint(egmeRight, Group.BoundsRectRightMargin, ACanvas);
        Group.Paint(egmeForeground, Group.DisplayRect, ACanvas);
        Group := Groups.NextGroupInRect(Group, ViewClipRect)
      end;
    end;

    SetWindowOrgEx(ACanvas.Handle, Scrollbars.OffsetX, Scrollbars.OffsetY - Header.RuntimeHeight, nil);
    SelectClipRgn(ACanvas.Handle, 0);

    if (View = elsReport) or (View = elsGrid) then
    begin
      if PaintInfoColumn.HilightFocused and Assigned(Selection.FocusedColumn) then
      begin
        if Selection.FocusedColumn.SortDirection <> esdNone then
        begin
          ACanvas.Brush.Color := PaintInfoColumn.HilightFocusedColor;
          Group := Groups.FirstVisibleGroup;
          while Assigned(Group) do
          begin
            R := Selection.FocusedColumn.DisplayRect;
            R.Top := Scrollbars.OffsetY;
            R.Bottom := Scrollbars.OffsetY + (ClientHeight - Header.RuntimeHeight);
            if IntersectRect(R, ViewClipRect, R) then
              if IntersectRect(R, R, Group.BoundsRectBkGnd) then
                ACanvas.FillRect(R);
            Group := Groups.NextVisibleGroup(Group)
          end
        end
      end;
      // Paint the Grid Lines
      if PaintInfoItem.GridLines then
      begin
        FirstVisibleGroup := Groups.FirstVisibleGroup;
        ACanvas.Pen.Color := PaintInfoItem.GridLineColor;
        Column := Header.FirstColumnInRect(ViewClipRect);
        while Assigned(Column) do
        begin
          Group := FirstVisibleGroup;
          while Assigned(Group) do
          begin
            R := Column.DisplayRect;
            ACanvas.MoveTo(R.Right, Group.BoundsRectBkGnd.Top);
            ACanvas.LineTo(R.Right, Group.BoundsRectBkGnd.Bottom);
            Group := Groups.NextVisibleGroup(Group)
          end;
          Column := Header.NextColumnInRect(Column, ViewClipRect);
        end;
        Item := Groups.FirstItemInRect(ViewClipRect);
        while Assigned(Item) do
        begin
          R := Item.DisplayRect;
          ACanvas.MoveTo(Scrollbars.OffsetX, R.Bottom-1);
          ACanvas.LineTo(Scrollbars.OffsetX + ClientWidth, R.Bottom-1);
          Item := Groups.NextItemInRect(Item, ViewClipRect)
        end
      end
    end;

    Item := Groups.FirstItemInRect(ViewClipRect);
    // If GroupSelection we always need to paint the first item
    if Assigned(Item) and (View = elsReport) and Selection.GroupSelections then
    begin
      // Need to paint the first item in a selection group
      if Assigned(Item.SelectionGroup) then
      begin
        if not SelectedOnly or (SelectedOnly and Item.Selected) then
        begin
          PaintReportView(Item.SelectionGroup.FirstItem, ViewClipRect, OrgPt);
          // Don't Repaint it
          if Item.SelectionGroup.FirstItem = Item then
            Item := Groups.NextItemInRect(Item, ViewClipRect);
        end
      end
    end;
    while Assigned(Item) do
    begin
      // Need to paint the focused item last if its text may overlap another cell when focused
      if not Item.Focused or not Item.View.OverlappedFocus then
      begin
        if not SelectedOnly or (SelectedOnly and Item.Selected) then
        begin
          if View = elsReport then
            PaintReportView(Item, ViewClipRect, OrgPt)
          else
            Item.Paint(ACanvas, ViewClipRect, nil, False);
        end
      end;
      Item := Groups.NextItemInRect(Item, ViewClipRect);
    end;

    if Assigned(Selection.FocusedItem) then
      if Selection.FocusedItem.View.OverlappedFocus then
        Selection.FocusedItem.Paint(ACanvas, ViewClipRect, nil, False);
        
  finally
    SetWindowOrgEx(ACanvas.Handle, OrgPt.X, OrgPt.Y, nil);
    GroupCollapseButton.Canvas.UnLock;
    GroupExpandButton.Canvas.UnLock;
  end
end;

procedure TCustomEasyListview.DoQueryOLEData(const FormatEtcIn: TFormatEtc;
  var FormatAvailable: Boolean; var Handled: Boolean);
// Called from the IDataObject when a target wants the source (us) to tell it
// what formats the DataObject supports
begin
  Handled := False;
  FormatAvailable := False;
  if Assigned(OnOLEQueryData) then
    OnOLEQueryData(Self, FormatEtcIn, FormatAvailable, Handled)
end;

procedure TCustomEasyListview.DoThreadCallback(var Msg: TWMThreadRequest);
begin

end;

procedure TCustomEasyListview.DoUpdate;
begin
  if not(csDestroying in ComponentState) then
  begin
    Groups.Rebuild(True);
    Scrollbars.ReCalculateScrollbars(True, False);
  end;
end;

procedure TCustomEasyListview.DoViewChange;
begin
  if Assigned(OnViewChange) then
    OnViewChange(Self)
end;

procedure TCustomEasyListview.EndUpdate(Invalidate: Boolean = True);
begin
  inherited EndUpdate(Invalidate);
  Sort.EndUpdate
end;

procedure TCustomEasyListview.FinalizeDrag(WindowPoint: TPoint;
  KeyState: TCommonKeyStates);
// Called after the mouse is released and a Drag Selection or a D&D operation
// was completed.  It cleans up and resets the flags.
begin
  // Do these after the flags have been reset in case a resulting operation of
  // these calls checks if the dragging is still occuring
  if ebcsDragging in States then
  begin
    Exclude(FStates, ebcsDragging);
    DragManager.DragEnd(Canvas, WindowPoint, KeyState);
  end;
  if ebcsDragSelecting in States then
  begin
    Exclude(FStates, ebcsDragSelecting);
    DragRect.DragEnd(Canvas, WindowPoint, KeyState);
  end;

  ClearStates;
  Mouse.Capture := 0;
end;

procedure TCustomEasyListview.FontChanged(Sender: TObject);
begin
  SafeInvalidateRect(nil, False);
  ParentFont := False;
  if Assigned(OldFontChangeNotify) then
    OldFontChangeNotify(Sender)
end;

procedure TCustomEasyListview.GroupFontChanged(Sender: TObject);
begin
  SafeInvalidateRect(nil, False);
  ParentFont := False;
  if Assigned(OldGroupFontChangeNotify) then
    OldGroupFontChangeNotify(Sender)
end;

procedure TCustomEasyListview.HandleDblClick(Button: TCommonMouseButton; Msg: TWMMouse);
var
  Group: TEasyGroup;
  Keys: TCommonKeyStates;
  GroupHitInfo: TEasyGroupHitTestInfoSet;
  GroupInfo: TEasyHitInfoGroup;
  Item: TEasyItem;
  ItemHitInfo: TEasyItemHitTestInfoSet;
  ItemInfo: TEasyHitInfoItem;
  ViewPt: TPoint;
begin
  Keys := KeyToKeyStates(Msg.Keys);
  ViewPt := Scrollbars.MapWindowToView(Msg.Pos);
  DoDblClick(Button, SmallPointToPoint(Msg.Pos), KeysToShiftState(Msg.Keys));  
  Item := Groups.ItembyPoint(ViewPt);
  if Assigned(Item) then
  begin
    Item.HitTestAt(ViewPt, ItemHitInfo);
    ItemInfo.Group := Item.OwnerGroup;
    ItemInfo.Item := Item;
    if ViewSupportsHeader then
      ItemInfo.Column := Header.Columns.ColumnByPoint(ViewPt)
    else
      ItemInfo.Column := nil;
    ItemInfo.HitInfo := ItemHitInfo;
    DoItemDblClick(Button, SmallPointToPoint(Msg.Pos), ItemInfo)
  end else
  begin
    Group := Groups.GroupByPoint(ViewPt);
    if Assigned(Group) then
    begin
      Group.HitTestAt(ViewPt, GroupHitInfo);
      GroupInfo.Group := Group;
      GroupInfo.HitInfo := GroupHitInfo;
      DoGroupDblClick(Button, SmallPointToPoint(Msg.Pos), GroupInfo)
    end else
    begin
      if ViewSupportsHeader and (Header.Visible) then
      begin
        if Msg.YPos < Header.Height then
          Header.WMLButtonDblClk(Msg);
      end
    end
  end
end;

procedure TCustomEasyListview.HandleKeyDown(Msg: TWMKeyDown);

    procedure MoveFocus(KeyStates: TShiftState; Item: TEasyItem);
    begin
      if Assigned(Item) then
      begin
        // Do this underhanded so we don't cause a grid rebuild but will keep the
        // window from getting WM_PAINT messages until we are done
        Inc(FUpdateCount);
        try
          if Selection.FocusedItem <> Item then
          begin
            if not Selection.Enabled and Selection.UseFocusRect then
              Selection.FocusedItem := Item
            else
            if ssCtrl in KeyStates then
              Selection.FocusedItem := Item
            else
            if ssShift in KeyStates then
            begin
              if Assigned(Selection.AnchorItem) then
              begin
                Selection.SelectRange(Selection.AnchorItem, Item, Selection.RectSelect, True);
                Selection.FocusedItem := Item;
                Selection.FocusedItem.Selected := True;
              end else
              begin
                Selection.ClearAll;
                Selection.FocusedItem := Item;
                Selection.FocusedItem.Selected := True;
              end
            end else
            begin
              Selection.ClearAll;
              Selection.FocusedItem := Item;
              Selection.FocusedItem.Selected := True;
              Selection.AnchorItem := Selection.FocusedItem;
            end;
          end;
        finally
          if Assigned(Selection.FocusedItem) then
          begin
            if Selection.FocusedItem.DisplayRect.Top < ClientInViewportCoords.Top + (RectHeight(ClientInViewportCoords) div 2) then
              Selection.FocusedItem.MakeVisible(emvAuto {emvTop})
            else
              Selection.FocusedItem.MakeVisible(emvAuto{emvBottom});
          end;
          Dec(FUpdateCount);
          UpdateWindow(Handle);
        end
      end
    end;

    function FocusFirst: Boolean;
    var
      Item: TEasyItem;
    begin
      Result := False;
      if not Assigned(Selection.FocusedItem) then
      begin
        Item := Groups.FirstVisibleItem;
        if Assigned(Item) then
        begin
          Selection.FocusedItem := Item;
          Result := True
        end
      end
    end;

var
  Item: TEasyItem;
  KeyStates: TShiftState;
  Handled, Mark: Boolean;
begin
  KeyStates := KeyDataToShiftState(Msg.KeyData);

  Selection.IncMultiChangeCount;
  try
    case Msg.CharCode of
      VK_RIGHT:
        begin
          if Selection.Enabled or Selection.UseFocusRect then
          begin
            if not FocusFirst then
            begin
              Item := Groups.AdjacentItem(Selection.FocusedItem, acdRight);
              MoveFocus(KeyStates, Item);
            end
          end else
            Scrollbars.OffsetX := Scrollbars.OffsetX + 1;
        end;
      VK_LEFT:
        begin
          if Selection.Enabled or Selection.UseFocusRect then
          begin
            if not FocusFirst then
            begin
              Item := Groups.AdjacentItem(Selection.FocusedItem, acdLeft);
              MoveFocus(KeyStates, Item);
            end
          end else
            Scrollbars.OffsetX := Scrollbars.OffsetX - 1;
        end;
      VK_UP:
        begin
          if Selection.Enabled or Selection.UseFocusRect then
          begin
            if not FocusFirst then
            begin
              Item := Groups.AdjacentItem(Selection.FocusedItem, acdUp);
              MoveFocus(KeyStates, Item);
            end
          end else
            Scrollbars.OffsetY := Scrollbars.OffsetY + 1;
        end;
      VK_DOWN:
        begin
          if Selection.Enabled or Selection.UseFocusRect then
          begin
            if not FocusFirst then
            begin
              Item := Groups.AdjacentItem(Selection.FocusedItem, acdDown);
              // Special case with one item
              if not Assigned(Item) and (Selection.Count = 0) and (Groups.ItemCount = 1) then
              begin
                Selection.FocusedItem := nil;
                Item := Groups.FirstItem;
              end;
              MoveFocus(KeyStates, Item);
            end
          end else
            Scrollbars.OffsetY := Scrollbars.OffsetY + 1;
        end;
      VK_HOME:
        begin
          if Selection.Enabled or Selection.UseFocusRect then
          begin
            if not FocusFirst then
            begin
              Item := Groups.FirstVisibleItem;
              MoveFocus(KeyStates, Item);
            end
          end else
          begin
            Scrollbars.OffsetX := 0;
            Scrollbars.OffsetY := 0;
          end
        end;
      VK_END:
        begin
          if Selection.Enabled or Selection.UseFocusRect then
          begin
            if not FocusFirst then
            begin
              Item := Groups.LastVisibleItem;
              MoveFocus(KeyStates, Item);
            end
          end else
          begin
            Scrollbars.OffsetX := Scrollbars.MaxOffsetX;
            Scrollbars.OffsetY := Scrollbars.MaxOffsetY;
          end
        end;
      VK_NEXT:
        begin
          if Selection.Enabled or Selection.UseFocusRect then
          begin
            if not FocusFirst then
            begin
              Item := Groups.AdjacentItem(Selection.FocusedItem, acdPageDown);
              MoveFocus(KeyStates, Item);
            end
          end else
            Scrollbars.OffsetY := Scrollbars.OffsetY + ClientHeight;
        end;
      VK_PRIOR:
        begin
          if Selection.Enabled or Selection.UseFocusRect then
          begin
            if not FocusFirst then
            begin
              Item := Groups.AdjacentItem(Selection.FocusedItem, acdPageUp);
              MoveFocus(KeyStates, Item);
            end
          end else
            Scrollbars.OffsetY := Scrollbars.OffsetY - ClientHeight;
        end;
      VK_F2:
        begin
          if Assigned(Selection.FocusedItem) then
          begin
            EditManager.BeginEdit(Selection.FocusedItem, nil)
          end;
        end;
      VK_SPACE:
        begin
          if Assigned(Selection.FocusedItem) then
            if Selection.FocusedItem.PaintInfo.CheckType in [ectBox, ectRadio] then
              Selection.FocusedItem.Checked := not Selection.FocusedItem.Checked
        end;
      Ord('A'),
      Ord('a'):
        begin
          if ssCtrl in KeyStates then
            Selection.SelectAll
        end;
      Ord('C'), Ord('c'):   // Ctrl + 'C' Copy
      begin
        if ssCtrl in KeyStates then
        begin
          Handled := False;
          DoClipboardCopy(Handled);
          if not Handled then
            CopyToClipboard;
        end
      end;
      Ord('X'), Ord('x'):  // Ctrl + 'X' Cut
        begin
          if ssCtrl in KeyStates then
          begin
            Handled := False;
            Mark := True;
            DoClipboardCut(Mark, Handled);
            if not Handled then
              CutToClipboard
            else
              if Mark then
                MarkSelectedCut
          end
        end;
      Ord('V'), Ord('v'):   // // Ctrl + 'V' Paste
        begin
          if ssCtrl in KeyStates then
          begin
            Handled := False;
            DoClipboardPaste(Handled);
            if not Handled then
              PasteFromClipboard;
          end
        end;
        VK_ESCAPE:
        begin
          CancelCut;
          Invalidate;
        end;
    end
  finally
    Selection.DecMultiChangeCount
  end
end;

procedure TCustomEasyListview.HandleMouseDown(Button: TCommonMouseButton; Msg: TWMMouse);
var
  WindowPt: TPoint;
  KeyState: TCommonKeyStates;
  Group: TEasyGroup;
  Item: TEasyItem;
  GroupHitInfo: TEasyGroupHitTestInfoSet;
  ItemHitInfo: TEasyItemHitTestInfoSet;
  MouseDown, StartTimer, CtlDown, ShiftDown: Boolean;
  Allow, DoDefaultItemDown: Boolean;
begin
  Item := nil;
  KeyState := KeyToKeyStates(Msg.Keys);
  WindowPt := Scrollbars.MapWindowToView(Msg.Pos);
  MouseDown := KeyState * [cksLButton, cksMButton, cksRButton] <> [];
  CtlDown := cksControl in KeyState;
  ShiftDown := cksShift in KeyState;

  Group := ClickTestGroup(WindowPt, KeyState, GroupHitInfo);
  if Assigned(Group) then
  begin
    // First see if the group expand button or checkbox was hit
    if GroupTestExpand(GroupHitInfo) then
    begin
      // Only the left button can expand
      if Button = cmbLeft then
      begin
        // Deal with the expansion in the mouse down
        Allow := True;
        if Group.Expanded then
          DoGroupCollapsing(Group, Allow)
        else
          DoGroupExpanding(Group, Allow);
        if Allow then
        begin
          BeginUpdate;
          try
            Include(FStates, ebcsGroupExpandPending);
            Group.Expanded := not Group.Expanded;
            // Need to make sure focused item is not in the collapsed group.
            if not Group.Expanded and Assigned(Selection.FocusedItem) then
            begin
              if Selection.FocusedItem.OwnerGroup = Group then
              begin
                Item := Groups.NextVisibleItem(Selection.FocusedItem);
                while Assigned(Item) do
                begin
                  if Item.Enabled then
                    Break
                  else
                    Item := Groups.NextVisibleItem(Item)
                end;
                Selection.FocusedItem := Item;
              end
            end
          finally
            EndUpdate
          end
        end;
      end
    end else
    // Next see if it hit the Group CheckBox
    if egtOnCheckbox in GroupHitInfo then
    begin
       // Only the left button can Check Groups
      if Button = cmbLeft then
      begin
        Include(FStates, ebcsCheckboxClickPending);
        HotTrack.PendingObjectCheck := nil;
        CheckManager.PendingObject := Group;
      end
    end else
    begin
      if Group.Expanded then
      begin
        // Exhausted Group hit tests, move into Item level testing
        Item := ClickTestItem(WindowPt, Group, KeyState, ItemHitInfo);
        if Assigned(Item) then
        begin
          DoDefaultItemDown := True;
          DoItemMouseDown(Item, Button, DoDefaultItemDown);
          if DoDefaultItemDown then
          begin    
            // First see it the hit was on the items check box
            if ehtOnCheck in ItemHitInfo then
            begin
               // Only the left button can Check Items
              if Button = cmbLeft then
              begin
                Include(FStates, ebcsCheckboxClickPending);
                HotTrack.PendingObjectCheck := nil;
                CheckManager.PendingObject := Item;
              end
            end else
            // Next see if Selection is enabled and if so handle item selection
            // through direct hit or drag rectangle
            if Selection.Enabled then
            begin
              Selection.IncMultiChangeCount;
              Selection.GroupSelectBeginUpdate;
              try
                if Item.SelectionHitPt(WindowPt, eshtClickselect) then
                begin
                  if MouseDown and (Button in Selection.MouseButton) then
                  begin
                    // See if the user click on the item a second time, if so get ready for
                    // an edit
                    StartTimer := (Button = cmbLeft) and ((Selection.Count = 1) and ((Selection.FocusedItem = Item) and Item.EditAreaHitPt(WindowPt) and Item.Selected));

                    if Selection.MultiSelect then
                    begin
                      // Multi Selection Mode.........
                      if not Item.Selected and not(CtlDown or ShiftDown) then
                        Selection.ClearAll;
                        
                      // Focus the item if the Ctl key is not down.  It will be done in the ButtonUp event
                      if (Selection.FocusedItem <> Item) and not CtlDown then
                        Selection.FocusedItem := Item;

                      if not( CtlDown or ShiftDown) then
                      begin
                        Selection.AnchorItem := Item;
                      end else
                      begin
                        if not ShiftDown then
                          Selection.AnchorItem := Item
                        else
                          Selection.SelectRange(Selection.AnchorItem, Item, Selection.RectSelect, True);
                      end
                    end else
                    begin
                      // Single Selection Mode.........
                      // Set the Focus to the hit item
                      if (Selection.FocusedItem <> Item) then
                        Selection.FocusedItem := Item;
                      Selection.AnchorItem := Item;
                      Selection.ClearAll;
                    end;

                    // CtlClick then it will be selected in the Mouse Up
                    if not CtlDown then
                      Item.Selected := True;
        //            Update;

                    if Button in DragRect.MouseButton then
                      InitializeDragPendings(Item, SmallPointToPoint(Msg.Pos), KeyToKeyStates(Msg.Keys), Item.AllowDrag(WindowPt), True);

                    if StartTimer then
                    begin
                      EditManager.AutoEditStartClickPt := WindowPt;
                      EditManager.StartAutoEditTimer;
                    end
                  end
                end else
                begin
                  // All mouse button down actions trigger the same events
                  // Since it is unknown what the user is trying to do yet
                  if Button in DragRect.MouseButton then
                    InitializeDragPendings(Item, SmallPointToPoint(Msg.Pos), KeyToKeyStates(Msg.Keys), False, True);
                end
              finally
                Selection.GroupSelectEndUpdate;
                Selection.DecMultiChangeCount
              end
            end else
            if Selection.UseFocusRect then
            begin
              if Item.SelectionHitPt(WindowPt, eshtClickselect) then
                Selection.FocusedItem := Item
            end
          end
        end else
        begin
         // All mouse button down actions trigger the same events
         // Since it is unknown what the user is trying to do yet
          if Button in DragRect.MouseButton then
            InitializeDragPendings(Item, SmallPointToPoint(Msg.Pos), KeyToKeyStates(Msg.Keys), False, True);
        end
      end else
        // Did not hit an anything so get ready for a drag rectangle
        if Button in DragRect.MouseButton then
          InitializeDragPendings(Item, SmallPointToPoint(Msg.Pos), KeyToKeyStates(Msg.Keys), False, True);
    end;
  end else
  begin
    // All mouse button down actions trigger the same events
    // Since it is unknown what the user is trying to do yet
    // Did not hit a group so get ready for a drag rectangle
    if Button in DragRect.MouseButton then
      InitializeDragPendings(Item, SmallPointToPoint(Msg.Pos), KeyToKeyStates(Msg.Keys), False, True);
  end;
end;

procedure TCustomEasyListview.HandleMouseUp(Button: TCommonMouseButton; Msg: TWMMouse);
// Called when the Left Mouse button is released
var
  Pt: TPoint;
  KeyState: TCommonKeyStates;
  GroupHitInfo: TEasyGroupHitTestInfoSet;
  ItemHitInfo: TEasyItemHitTestInfoSet;
  Group: TEasyGroup;
  Item: TEasyItem;
  CtlDown, ShiftDown, DoDefaultItemUp: Boolean;
begin
  Group := nil;
  KeyState := KeyToKeyStates(Msg.Keys);
  CtlDown := cksControl in KeyState;
  ShiftDown := cksShift in KeyState;
  Pt := Scrollbars.MapWindowToView(Msg.Pos);
  // In some cases we can get a mouse up message without a corresponding mouse
  // down message.  For example if we full expand the application if the mouse
  // is over the Easy window after the expand we get a mouse up message
  if ([ebcsLButtonDown, ebcsRButtonDown, ebcsMButtonDown] * States <> []) then
  begin
    if ebcsGroupExpandPending in States then
    begin
      // Don't do any other processing if the group expand button was clicked
    end else
    if ebcsCheckboxClickPending in States then
    begin
      Group := ClickTestGroup(Pt, KeyState, GroupHitInfo);
      if CheckManager.PendingObject is TEasyGroup then
      begin
        if (egtOnCheckbox in GroupHitInfo) and Assigned(Group) then
          Group.Checked := not Group.Checked;
      end else
      if CheckManager.PendingObject is TEasyItem then
      begin
        Item := ClickTestItem(Pt, Group, KeyState, ItemHitInfo);
        if (ehtOnCheck in ItemHitInfo) and Assigned(Item) then
          Item.Checked := not Item.Checked
      end;
      CheckManager.PendingObject.CheckHovering := False;
      CheckManager.PendingObject.CheckPending := False;
      CheckManager.PendingObject := nil;
    end else
    if ebcsDragSelecting in States then
    begin
      FinalizeDrag(SmallPointToPoint(Msg.Pos), KeyToKeyStates(Msg.Keys));
    end else
    if ebcsDragging in States then
    begin
      // The VCL will send us a fake mouse button up when the drag starts.
      // This screws everything.  We will send a mouse up after the drag ends
      // with the cbcsVCLDrag cleared
      if not(ebcsVCLDrag in States) then
        FinalizeDrag(SmallPointToPoint(Msg.Pos), KeyToKeyStates(Msg.Keys));
    end else
    begin
      // If not dragging or drag selecting then check if it is necessary to unselect
      // the items
      Item := ClickTestItem(Pt, Group, KeyState, ItemHitInfo);
      if Assigned(Item) then
      begin
        DoDefaultItemUp := True;
        DoItemMouseUp(Item, Button, DoDefaultItemUp);
        if DoDefaultItemUp then
        begin
          DoItemClick(Item, KeyToKeyStates(Msg.Keys), ItemHitInfo);
          if not Item.SelectionHitPt(Pt, eshtClickselect) then
            Selection.ClearAll
          else begin
            // Allow MultiSelect
            if Selection.MultiSelect then
            begin
              if not (ShiftDown or CtlDown) and (not Item.Selected or (Button = cmbLeft)) then
                Selection.ClearAllExcept(Item)
              {else; begin
                if CtlDown then
                begin
                  EditManager.StopAutoEditTimer;
                  Item.Selected := not Item.Selected;
                  Item.Focused := True;
                end  
              end    }
            end
          end
        end
      end else
      begin
        Group := ClickTestGroup(Pt, KeyToKeyStates(Msg.Keys), GroupHitInfo);
        if Assigned(Group) then
          DoGroupClick(Group, KeyToKeyStates(Msg.Keys), GroupHitInfo);
        if not CtlDown then
        Selection.ClearAll
      end
    end
  end
end;

procedure TCustomEasyListview.InitializeDragPendings(HitItem: TEasyItem; WindowPoint: TPoint; KeyState: TCommonKeyStates; AllowDrag, AllowDragRect: Boolean);
// Called from the mouse down messages.  It initializes the DragManager and the
// DragSelection Manager to prepare for a possible action.  If the click was not
// on an item then it is interperted as a drag select.  If it hit an item it
// is interperted as a D&D action.
var
  StartSelectDrag, StartDrag: Boolean;
  Pt: TPoint;
begin
  // At least NT4 does not set the focus on a mouse click
  if CanFocus then
    SetFocus;

  Mouse.Capture := Handle;

  // Initialize both Drag Select and Drag object just in case
  StartSelectDrag := AllowDragRect and DragRect.InitializeDrag(WindowPoint, KeyState);
  StartDrag := AllowDrag and DragManager.InitializeDrag(HitItem, WindowPoint, KeyState);

  Pt := Scrollbars.MapWindowToView(WindowPoint);

  if Assigned(DragManager.DragItem)  and StartDrag then
  begin
     Include(FStates, ebcsDragPending);
     DragRect.FinalizeDrag(KeyState)
  end else
  if StartSelectDrag then
  begin
    Include(FStates, ebcsDragSelectPending);
    DragManager.FinalizeDrag(KeyState)
  end;
end;

function TCustomEasyListview.IsGrouped: Boolean;
begin
  // Default definition that the control is in grouped mode is if the Top Margin is enabled
  Result := PaintInfoGroup.MarginTop.Visible
end;

procedure TCustomEasyListview.Loaded;
begin
  inherited;
  DoUpdate;
end;

procedure TCustomEasyListview.LoadFromFile(FileName: WideString; Mode: Word);
var
  F: TWideFileStream;
begin
  F := TWideFileStream.Create(FileName, Mode);
  try
    LoadFromStream(F)
  finally
    F.Free
  end
end;

procedure TCustomEasyListview.LoadFromStream(S: TStream);
var
  Version: Integer;
  AView: TEasyListStyle;
begin
  BeginUpdate;
  try
    S.Read(Version, SizeOf(Version));
    if Version > 0 then
    begin
      S.Read(AView, SizeOf(AView));
      View := AView;
      Groups.LoadFromStream(S);
      Header.LoadFromStream(S);
      Groups.Rebuild(True);
    end;
    {  if Version > n then
       begin
       end; }
  finally
    EndUpdate
  end
end;

procedure TCustomEasyListview.MarkSelectedCut;
var
  Item: TEasyItem;
begin
  CancelCut;
  Item := Selection.First;
  while Assigned(Item) do
  begin
    Item.Cut := True;
    Item := Selection.Next(Item)
  end
end;

procedure TCustomEasyListview.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
  begin
    if AComponent = FImagesGroup then
      FImagesGroup := nil;
    if AComponent = FImagesExLarge then
      FImagesExLarge := nil;
    if AComponent = FImagesLarge then
      FImagesLarge := nil;
    if AComponent = FImagesSmall then
      FImagesSmall := nil;
    if AComponent = Header.Images then
      Header.Images := nil;
  end
end;

procedure TCustomEasyListview.PasteFromClipboard;
var
  Handled: Boolean;
begin
  Handled := False;
  DoClipboardPaste(Handled)
end;

procedure TCustomEasyListview.ResizeBackBits(NewWidth, NewHeight: Integer);
// Resizes the Bitmap for the DoubleBuffering.  Called mainly when the window
// is resized.  Note the bitmap only gets larger to maximize speed during dragging
begin
  if CacheDoubleBufferBits then
  begin
    // The Backbits grow to the largest window size
    if (NewWidth > BackBits.Width) then
      BackBits.Width := NewWidth;
    if NewHeight > BackBits.Height then
      BackBits.Height := NewHeight;
  end
end;

procedure TCustomEasyListview.SaveToFile(FileName: WideString; Mode: Word);
var
  F: TWideFileStream;
begin
  F := TWideFileStream.Create(FileName, Mode);
  try
    SaveToStream(F)
  finally
    F.Free
  end  
end;

procedure TCustomEasyListview.SaveToStream(S: TStream);
var
  Version: Integer;
begin
  Version := CURRENT_EASYLISTVIEW_STREAM_VERSION;
  S.Write(Version, SizeOf(Version));
  S.Write(View, SizeOf(View));
  Groups.SaveToStream(S);
  Header.SaveToStream(S)
end;

procedure TCustomEasyListview.SetBackGround(const Value: TEasyBackgroundManager);
begin
  if Assigned(FBackGround) then
    FreeAndNil(FBackGround);
  FBackGround := Value;
end;

procedure TCustomEasyListview.SetGroupCollapseImage(Value: TBitmap);
begin
  FGroupCollapseButton.Assign(Value);
  if Assigned(FGroupCollapseButton) then
    FGroupCollapseButton.PixelFormat := pf32Bit
end;

procedure TCustomEasyListview.SetGroupExpandImage(Value: TBitmap);
begin
  FGroupExpandButton.Assign(Value);
  if Assigned(FGroupExpandButton) then
    FGroupExpandButton.PixelFormat := pf32Bit
end;

procedure TCustomEasyListview.SetGroupFont(Value: TFont);
begin
  FGroupFont.Assign(Value)
end;

procedure TCustomEasyListview.SetHintType(Value: TEasyHintType);
begin
  HintInfo.HintType := Value
end;

procedure TCustomEasyListview.SetImagesExLarge(Value: TImageList);
begin
  if Value <> FImagesExLarge then
  begin
    FImagesExLarge := Value;
    SafeInvalidateRect(nil, False);
  end
end;

procedure TCustomEasyListview.SetImagesGroup(Value: TImageList);
begin
  if Value <> FImagesGroup then
  begin
    FImagesGroup := Value;
    SafeInvalidateRect(nil, False);
  end
end;

procedure TCustomEasyListview.SetImagesLarge(Value: TImageList);
begin
  if Value <> FImagesLarge then
  begin
    FImagesLarge := Value;
    SafeInvalidateRect(nil, False);
  end
end;

procedure TCustomEasyListview.SetImagesSmall(Value: TImageList);
begin
  if Value <> FImagesSmall then
  begin
    FImagesSmall := Value;
    SafeInvalidateRect(nil, False);
  end
end;

procedure TCustomEasyListview.SetPaintInfoColumn(const Value: TEasyPaintInfoBaseColumn);
begin
  if Value <> FPaintInfoColumn then
  begin
    FreeAndNil(FPaintInfoColumn);
    FPaintInfoColumn := Value;
  end
end;

procedure TCustomEasyListview.SetPaintInfoGroup(const Value: TEasyPaintInfoBaseGroup);
begin
   if Value <> FPaintInfoGroup then
  begin
    FreeAndNil(FPaintInfoGroup);
    FPaintInfoGroup := Value;
  end
end;

procedure TCustomEasyListview.SetPaintInfoItem(const Value: TEasyPaintInfoBaseItem);
begin
  if Value <> FPaintInfoItem then
  begin
    FreeAndNil(FPaintInfoItem);
    FPaintInfoItem := Value;
  end
end;

procedure TCustomEasyListview.SetSelection(Value: TEasySelectionManager);
begin
  if Value <> FSelection then
  begin
    FreeAndNil(FSelection);
    FSelection := Value
  end
end;

procedure TCustomEasyListview.SetShowGroupMargins(const Value: Boolean);
begin
  if FShowGroupMargins <> Value then
  begin
    FShowGroupMargins := Value;
    DoUpdate;
  end;
end;

procedure TCustomEasyListview.SetShowInactive(const Value: Boolean);
begin
  if FShowInactive <> Value then
  begin
    FShowInactive := Value;
    SafeInvalidateRect(nil, True)
  end
end;

procedure TCustomEasyListview.SetShowThemedBorder(Value: Boolean);
begin
  if Value <> FShowThemedBorder then
  begin
    FShowThemedBorder := Value;
    // Need to modify the NonClient area
    RecreateWnd;
  end
end;

procedure TCustomEasyListview.SetView(Value: TEasyListStyle);

  procedure SetDefaultView(AStyle: TEasyListStyle; View: TEasyViewItemClass; Grid: TEasyGridGroupClass);
  var
    OldGrid: TEasyGridGroupClass;
    OldView: TEasyViewItemClass;
  begin
    OldGrid := Grid;
    OldView := View;
    Grid := nil;
    View := nil;
    DoCustomView(AStyle, View);
    if not Assigned(View) then
      Groups.DefaultItemView := OldView
    else
      Groups.DefaultItemView := View;
    DoCustomGrid(AStyle, Grid);
    if not Assigned(Grid) then
      Groups.DefaultGrid := OldGrid
    else
      Groups.DefaultGrid := Grid
  end;

  procedure SetAView(Group: TEasyGroup; View: TEasyViewItemClass; CellSize: TEasyCellSize; Grid: TEasyGridGroupClass);
  begin
    Group.ItemView := View.Create(Group);
    Group.Grid := Grid.Create(Self, Group);
    Group.Grid.CellSize.Assign(CellSize);
  end;

var
  i: Integer;
begin
  if FView <> Value then
  begin
    BeginUpdate;
    try
      FView := Value;
      case Value of
        elsIcon:
          begin
            SetDefaultView(elsIcon, TEasyViewIconItem, TEasyGridIconGroup);
            for i := 0 to Groups.Count - 1 do
              SetAView(Groups[i], Groups.DefaultItemView, CellSizes.Icon, Groups.DefaultGrid);
            WheelMouseDefaultScroll := edwsVert
          end;
        elsSmallIcon:
          begin
            SetDefaultView(elsSmallIcon, TEasyViewSmallIconItem, TEasyGridSmallIconGroup);
            for i := 0 to Groups.Count - 1 do
              SetAView(Groups[i], Groups.DefaultItemView, CellSizes.SmallIcon, Groups.DefaultGrid);
            WheelMouseDefaultScroll := edwsVert
          end;
        elsList:
          begin
            SetDefaultView(elsList, TEasyViewListItem, TEasyGridListGroup);
            for i := 0 to Groups.Count - 1 do
              SetAView(Groups[i], Groups.DefaultItemView, CellSizes.List, Groups.DefaultGrid);
            WheelMouseDefaultScroll := edwsHorz
          end;
        elsReport:
          begin
           SetDefaultView(elsReport, TEasyViewReportItem, TEasyGridReportGroup);
           for i := 0 to Groups.Count - 1 do
             SetAView(Groups[i], Groups.DefaultItemView, CellSizes.Report, Groups.DefaultGrid);
           Selection.BuildSelectionGroupings(True);
           WheelMouseDefaultScroll := edwsVert
          end;
        elsThumbnail:
          begin
            SetDefaultView(elsThumbnail, TEasyViewThumbnailItem, TEasyGridThumbnailGroup);
            for i := 0 to Groups.Count - 1 do
              SetAView(Groups[i], Groups.DefaultItemView, CellSizes.Thumbnail, Groups.DefaultGrid);
           WheelMouseDefaultScroll := edwsVert
          end;
        elsTile:
          begin
            SetDefaultView(elsTile, TEasyViewTileItem, TEasyGridTileGroup);
            for i := 0 to Groups.Count - 1 do
              SetAView(Groups[i], Groups.DefaultItemView, CellSizes.Tile, Groups.DefaultGrid);
            WheelMouseDefaultScroll := edwsVert
          end;
        elsFilmStrip:
          begin
            SetDefaultView(elsFilmStrip, TEasyViewFilmStripItem, TEasyGridFilmStripGroup);
            for i := 0 to Groups.Count - 1 do
              SetAView(Groups[i], Groups.DefaultItemView, CellSizes.FilmStrip, Groups.DefaultGrid);
           WheelMouseDefaultScroll := edwsVert
          end;
        elsGrid:
          begin
            SetDefaultView(elsGrid, TEasyViewGridItem, TEasyGridGridGroup);
            for i := 0 to Groups.Count - 1 do
              SetAView(Groups[i], Groups.DefaultItemView, CellSizes.Grid, Groups.DefaultGrid);
           WheelMouseDefaultScroll := edwsVert
          end;
      end;
    finally
      DoViewChange;
      EndUpdate;
      if Assigned(Selection.FocusedItem) then
        Selection.FocusedItem.MakeVisible(emvTop);
    end
  end
end;

procedure TCustomEasyListview.WMChar(var Msg: TWMChar);
begin
  inherited;
  IncrementalSearch.HandleWMChar(Msg);
end;

procedure TCustomEasyListview.WMContextMenu(var Msg: TMessage);
var
  Item: TEasyItem;
  Group: TEasyGroup;
  Pt: TPoint;
  HitInfoGroup: TEasyHitInfoGroup;
  HitInfoItem: TEasyHitInfoItem;
  Menu: TPopupMenu;
  Handled, SkipHitTest: Boolean;
begin
  EditManager.StopAutoEditTimer;
  EditManager.EndEdit;
  if not (ebcsCancelContextMenu in States) then
  begin
    SkipHitTest := False;
    Pt := Point( Msg.LParamLo, Msg.LParamHi);
    if (Pt.X = 65535) and (Pt.Y = 65535) then
    begin
      Pt := ScreenToClient(Mouse.CursorPos);
      if not PtInRect(ClientRect, Pt) or (Selection.Count = 0) then
      begin
        Pt.X := 0;
        Pt.Y := 0;
        SkipHitTest := True;
      end;
      Pt := ClientToScreen(Pt);
    end;

    if not SkipHitTest then
    begin
      if IsHeaderMouseMsg(PointToSmallPoint( ScreenToClient(Pt))) then
      begin
        Pt := ClientToScreen(Pt);
        Header.WMContextMenu(Msg);
        Handled := True;
      end else
      begin
        Menu := nil;
        Exclude(FStates, ebcsDragSelectPending);
        Exclude(FStates, ebcsDragPending);

        Handled := False;
        Group := Groups.GroupByPoint(Scrollbars.MapWindowToView(ScreenToClient(Pt)));
        if Assigned(Group) then
        begin
          // The hit was in a group so now see if it was in an item
          Item := Group.ItembyPoint(Scrollbars.MapWindowToView( ScreenToClient(Pt)));
          if Assigned(Item) then
          begin
            if Item.HitTestAt(Scrollbars.MapWindowToView( ScreenToClient(Pt)), HitInfoItem.HitInfo) then
            begin
              HitInfoItem.Column := nil;
              HitInfoItem.Group := Group;
              HitInfoItem.Item := Item;
              DoItemContextMenu(HitInfoItem, Pt, Menu, Handled)
            end
          end;
          if not Assigned(Menu) and not Handled then
          begin
            HitInfoGroup.Group := Group;
            Group.HitTestAt(Scrollbars.MapWindowToView(ScreenToClient(Pt)), HitInfoGroup.HitInfo);
            DoGroupContextMenu(HitInfoGroup, Pt, Menu, Handled)
          end
        end
      end
    end;
    if not Handled then
      DoContextMenu(Pt, Handled);

    if Assigned(Menu) and not Handled then
    begin
      Menu.Popup(Msg.LParamLo, Msg.LParamHi);
      Msg.Result := 1
    end else
    if not Handled then
      inherited  // Use the PopupMenu property from TControl
  end;
  Exclude(FStates, ebcsCancelContextMenu);
end;

procedure TCustomEasyListview.WMDestroy(var Msg: TMessage);
begin
  DragManager.Registered := False;
  Header.DragManager.Registered := False;
  inherited;
end;

procedure TCustomEasyListview.WMEasyThreadCallback(var Msg: TWMThreadRequest);
begin
  DoThreadCallback(Msg)
end;

procedure TCustomEasyListview.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
begin
  Msg.Result := 1;
end;

procedure TCustomEasyListview.WMGetDlgCode(var Msg: TWMGetDlgCode);
// The VCL forms use the Dialog Window Proc so we need to tell windows we want
// the arrow keys for navigation
begin
  Msg.Result := DLGC_WANTALLKEYS or DLGC_WANTARROWS;
end;

procedure TCustomEasyListview.WMHScroll(var Msg: TWMHScroll);
// Called to scroll the Window, the Window is responsible for actually performing
// the scroll
begin
  inherited;
  if Msg.ScrollCode <> SB_ENDSCROLL then
    Include(FStates, ebcsScrolling)
  else
    Exclude(FStates, ebcsScrolling);
  ScrollBars.WMHScroll(Msg);
  SafeInvalidateRect(nil, False);
end;

procedure TCustomEasyListview.WMKeyDown(var Msg: TWMKeyDown);
// Called when the user pressed a key on the keyboard.  The Scrollbars need to
// know in case the user is scrolling using the keys.
var
  Shift: TShiftState;
  DoDefault: Boolean;
begin
  inherited;
  if (ebcsDragSelecting in States) then
  begin
    DragRect.WMKeyDown(Msg);
  end else
  begin
    IncrementalSearch.HandleWMKeyDown(Msg);

    Shift := KeyDataToShiftState(Msg.KeyData);
    DoDefault := True;
    DoKeyAction(Msg.CharCode, Shift, DoDefault);
    if DoDefault then
      HandleKeyDown(Msg);
  end
end;

procedure TCustomEasyListview.WMKillFocus(var Msg: TWMKillFocus);
begin
  inherited;
  if HotTrack.OnlyFocused then
    HotTrack.PendingObject[Point(0, 0)] := nil;
  SafeInvalidateRect(nil, True);
end;

procedure TCustomEasyListview.WMLButtonDblClk(var Msg: TWMLButtonDblClk);
begin
  inherited;
  HandleDblClick(cmbLeft, Msg)
end;

procedure TCustomEasyListview.WMLButtonDown(var Msg: TWMLButtonDown);
// Called when the Left Mouse button is pressed
begin
  Include(FStates, ebcsLButtonDown);
  CheckFocus;
  if IsHeaderMouseMsg(Msg.Pos) then
  begin
    SetFocus;
    // Should this call a Column manager or a Column?
    if Assigned(Header) then
    begin
      Header.CaptureMouse;
      Header.WMLButtonDown(Msg);
    end
  end else
  begin
    inherited;
    HandleMouseDown(cmbLeft, Msg)
  end
end;

procedure TCustomEasyListview.WMLButtonUp(var Msg: TWMLButtonUp);
// Called when the Left Mouse button is released
begin
  if IsHeaderMouseMsg(Msg.Pos) then
  begin
   // Should this call a Column manager or a Column?
   if Assigned(Header) then
    begin
      Header.WMLButtonUp(Msg);
      // Need to allow HotTracking to finish up.
      Header.WMMouseMove(Msg);
      Header.ReleaseMouse;
    end
  end else
  begin
    // The VCL D&D will "Perform" a Left Button Up when StartDrag is called.  As such
    // a lot of the State Flags get prematurely reset.
    inherited;
    HandleMouseUp(cmbLeft, Msg);
    Mouse.Capture := 0;
  end;
  ClearStates;
end;

procedure TCustomEasyListview.WMMButtonDblClk(var Msg: TWMMButtonDblClk);
begin
  inherited;
  HandleDblClick(cmbMiddle, Msg)
end;

procedure TCustomEasyListview.WMMButtonDown(var Msg: TWMMButtonDown);
begin
  inherited;
  CheckFocus;
end;

procedure TCustomEasyListview.WMMouseActivate(var Msg: TWMMouseActivate);
// Called when the mouse is clicked in a window and the window does not have
// focus.  By responding MA_ACTIVATE the window should recieve focus but this
// does not seem to happen on NT4.  Necded a SetFocus when the mouse is pressed
begin
  inherited;
  CheckFocus;
  Msg.Result := MA_ACTIVATE;
end;

procedure TCustomEasyListview.WMMouseMove(var Msg: TWMMouseMove);
// Called when the mouse is moved
var
  KeyState: TCommonKeyStates;
  GroupHitInfo: TEasyGroupHitTestInfoSet;
  ItemHitInfo: TEasyItemHitTestInfoSet;
  Effects: TCommonDropEffect;
  Group: TEasyGroup;
  HotTrackCheckObj, HotTrackObj: TEasyCollectionItem;
  Item: TEasyItem;
  Pt: TPoint;
begin
  KeyState := KeyToKeyStates(Msg.Keys);
  Pt := Scrollbars.MapWindowToView(Msg.Pos);
  HotTrackCheckObj := nil;

  if IsHeaderMouseMsg(Msg.Pos) then
  begin
    HotTrack.PendingObject[Point(0, 0)] := nil;
    Header.WMMouseMove(Msg)
  end else
  begin
    if not Assigned(HotTrack.PendingObject[Point(0,0)]) then
      Cursor := crDefault;

    // First see if there is any kind of drag operation pending or occuring
    if DragInitiated then
    begin
      // First check for special cases, such as when the drag selection rectangle
      // is active or an item is being dragged in a D&D operation.  If not see if
      // this is the first move after a mouse press and one of the above cases is
      // pending.  If we then detect a drag start then setup the flags and initialize
      // the action with the appropiate mananger.
      if ebcsDragSelecting in States then
        DragRect.Drag(Canvas, SmallPointToPoint(Msg.Pos), KeyState, Effects)
      else
      if ebcsDragging in States then
        // his only works for VCL drag and drop. The System takes the mouse for OLE
        DragManager.Drag(Canvas, SmallPointToPoint(Msg.Pos), KeyState, Effects)
      else
      // We are not drag selecting; check if we have a drag pending
      if [ebcsDragSelectPending, ebcsDragPending] * States <> [] then
      begin
        if DragDetectPlus(Handle, SmallPointToPoint(Msg.Pos)) then
        begin
          // The decision to if the mouse was a drag or a select was made when the
          // mouse was pressed, based on the area of the control the click occured
          if ebcsDragSelectPending in States then
          begin
            // We are now drag selecting so update the states
            Include(FStates, ebcsDragSelecting);
            Exclude(FStates, ebcsDragSelectPending);
            if KeyState * [cksShift, cksControl] = [] then
              Include(FStates, ebcsDragSelecting);
            Exclude(FStates, ebcsDragSelectPending);
            if KeyState * [cksShift, cksControl] = [] then
              Selection.ClearAll;
            EditManager.StopAutoEditTimer;
            DragRect.BeginDrag(SmallPointToPoint(Msg.Pos), KeyState);
            // Since for a selection rect we have the mouse captured we can just
            // call DragEnter once here and be done with it
            DragRect.DragEnter(nil, Canvas, ScreenToClient(Mouse.CursorPos), KeyState, Effects);
          end else
          if ebcsDragPending in States then
          begin
            Item := Groups.ItembyPoint(Scrollbars.MapWindowToView(SmallPointToPoint(Msg.Pos)));
            if Assigned(Item) then
            begin
              // Since we don't select until a MouseUp on Ctl-Click we must do it here just in case
              if cksControl in KeyState then
              begin
                Item.Selected := True;
                Item.Focused := True;
              end;
              Include(FStates, ebcsDragging);
              if edtVCL = DragManager.DragType then
                Include(FStates, ebcsVCLDrag);
              Exclude(FStates, ebcsDragPending);
              EditManager.StopAutoEditTimer;
              try
                DragManager.BeginDrag(SmallPointToPoint(Msg.Pos), KeyState);
              finally
                // If was an OLE drag then the subsystem has taken the mouse and we
                // will never get a mouse up so fake it, the VCL system fakes it on
                // its own but if the drag/drop is not enabled then it never will so
                // fake it for all cases

                if not(ebcsVCLDrag in States) then
                begin
                  if ebcsLButtonDown in States then
                    Perform(WM_LBUTTONUP, TMessage(Msg).wParam, TMessage(Msg).LParam)
                  else
                  if ebcsRButtonDown in States then
                  begin
                    // Don't want to show the context menu after a drag drop with
                    // the right button
                    Include(FStates, ebcsCancelContextMenu);
                    Perform(WM_RBUTTONUP, TMessage(Msg).wParam, TMessage(Msg).LParam)
                  end else
                  if ebcsMButtonDown in States then
                    Perform(WM_MBUTTONUP, TMessage(Msg).wParam, TMessage(Msg).LParam)
                end
              end
            end else
            begin
              Selection.ClearAll;
              // Switch from a DragDrop Pending to a DragSelect Pending
              Exclude(FStates, ebcsDragPending);
              if DragRect.Enabled then
                Include(FStates, ebcsDragSelectPending);
            end
          end
        end
      end
    end else    // Not DragInitiated
    begin
      HotTrackObj := nil;

      Group := Groups.GroupByPoint(Pt);
      if Assigned(Group) then
      begin
        if Group.HitTestAt(Pt, GroupHitInfo) then
          // See if it is in a Group Check box first
          if egtOnCheckbox in GroupHitInfo then
            HotTrackCheckObj := Group
          else begin
            if (htgAnyWhere in HotTrack.GroupTrack) or
            ((htgIcon in HotTrack.GroupTrack) and (egtOnIcon in GroupHitInfo)) or
            ((htgText in HotTrack.GroupTrack) and (egtOnText in GroupHitInfo)) or
            ((htgTopMargin in HotTrack.GroupTrack) and (egtOnHeader in GroupHitInfo)) or
            ((htgBottomMargin in HotTrack.GroupTrack) and (egtOnFooter in GroupHitInfo)) or
            ((htgLeftMargin in HotTrack.GroupTrack) and (egtOnLeftMargin in GroupHitInfo)) or
            ((htgRightMargin in HotTrack.GroupTrack) and (egtOnRightMargin in GroupHitInfo)) then
              HotTrackObj := Group;
          end
        end;

        // Next See if it is in an Item Check box
        if not (Assigned(HotTrackCheckObj) or Assigned(HotTrackObj)) then
        begin
          Item := Groups.ItembyPoint(Pt);
          if Assigned(Item) then
          begin
            if Item.HitTestAt(Pt, ItemHitInfo) then
            begin
              if ehtOnCheck in ItemHitInfo then
                HotTrackCheckObj := Item
              else begin
                 if (htiAnyWhere in HotTrack.ItemTrack) or
                ((htiIcon in HotTrack.ItemTrack) and (ehtOnIcon in ItemHitInfo)) or
                ((htiText in HotTrack.ItemTrack) and (ehtOnText in ItemHitInfo)) then
                  HotTrackObj := Item
              end
            end
          end
        end;

      if (ebcsCheckboxClickPending in States) then
      begin
        if Assigned(HotTrackCheckObj) then
        begin
          if CheckManager.PendingObject <> HotTrackCheckObj then
          begin
            CheckManager.PendingObject.CheckHovering := True;
            HotTrackCheckObj := nil
          end else
            CheckManager.PendingObject.CheckHovering := False;
        end else
        begin
          CheckManager.PendingObject.CheckHovering := True;
        end;
        if HotTrackCheckObj <> nil then
          HotTrackCheckObj := nil;
      end;

      if not Assigned(CheckManager.PendingObject) and (Self.Focused or not HotTrack.OnlyFocused) and
        PtInRect(ClientRect, SmallPointToPoint(Msg.Pos)) then
        HotTrack.PendingObject[SmallPointToPoint(Msg.Pos)] := HotTrackObj
      else
        HotTrack.PendingObject[SmallPointToPoint(Msg.Pos)] := nil;

      HotTrack.PendingObjectCheck := HotTrackCheckObj;

      // We are not drag selecting and do not have a drag pending so it is a normal
      // mouse move
      inherited;
    end
  end
end;

procedure TCustomEasyListview.WMNCCalcSize(var Msg: TWMNCCalcSize);
{$IFDEF USETHEMES}
var
  R: TRect;
{$ENDIF USETHEMES}
begin
  if DrawWithThemes then
  begin
    DefaultHandler(Msg);
    {$IFDEF USETHEMES}
    if ShowThemedBorder and DrawWithThemes then
    begin
      GetThemeBackgroundContentRect(Themes.ListviewTheme, Canvas.Handle, LVP_EMPTYTEXT, LIS_NORMAL, Msg.CalcSize_Params^.rgrc[0], @R);
      InflateRect(R, -1-BorderWidth, -1-BorderWidth);
      Msg.CalcSize_Params^.rgrc[0] := R;
    end
    {$ENDIF USETHEMES}
  end else
  begin
    inherited;
  end
end;

procedure TCustomEasyListview.WMNCPaint(var Msg: TWMNCPaint);
// The VCL screws this up and draws over the scrollbars making them flicker and
// be covered up by backgound painting when dragging the the window from off the
// screen
const
  InnerStyles: array[TBevelCut] of Integer = (0, BDR_SUNKENINNER, BDR_RAISEDINNER, 0);
  OuterStyles: array[TBevelCut] of Integer = (0, BDR_SUNKENOUTER, BDR_RAISEDOUTER, 0);
  EdgeStyles: array[TBevelKind] of Integer = (0, 0, BF_SOFT, BF_FLAT);
  Ctl3DStyles: array[Boolean] of Integer = (BF_MONO, 0);
var
  ClientR, WindowR, WindowROrig, Filler: TRect;
  DC: HDC;
  Style: Longword;
  Pt: TPoint;
  {$IFDEF USETHEMES}
  R: TRect;
  {$ENDIF USETHEMES}
begin
  // Let Windows paint the scrollbars first
  DefaultHandler(Msg);
  if UpdateCount = 0 then
  begin
    DC := GetWindowDC(Handle);
    try
      NCCanvas.Handle := DC;

      if (BevelKind <> bkNone) or (BorderWidth > 0){ or DrawWithThemes} then
      begin
        Windows.GetClientRect(Handle, ClientR);
        Windows.GetWindowRect(Handle, WindowR);
        Pt := WindowR.TopLeft;
        Windows.ScreenToClient(Handle, Pt);
        // Map the screen coordinates of the WindowRect to a 0,0 offset
        OffsetRect(WindowR, -WindowR.Left, -WindowR.Top);
        // Make a copy
        WindowROrig := WindowR;
        // Map the ClientRect to Window coordinates
        OffsetRect(ClientR, -Pt.X, -Pt.Y);
        Style := GetWindowLong(Handle, GWL_STYLE);
        if (Style and WS_VSCROLL) <> 0 then
          Inc(ClientR.Right, GetSystemMetrics(SM_CYVSCROLL));
        if (Style and WS_HSCROLL) <> 0 then
          Inc(ClientR.Bottom, GetSystemMetrics(SM_CYHSCROLL));

        // Paint the little square in the corner made by the scroll bars
        if ((Style and WS_VSCROLL) <> 0) and ((Style and WS_HSCROLL) <> 0) then
        begin
          Filler := ClientR;
          Filler.Left := Filler.Right - GetSystemMetrics(SM_CYVSCROLL);
          Filler.Top := Filler.Bottom - GetSystemMetrics(SM_CYHSCROLL);
          NCCanvas.Brush.Color := clBtnFace;
          NCCanvas.FillRect(Filler);
        end;

   //     if not DrawWithThemes then
          // Punch out the client area and the scroll bar area
          ExcludeClipRect(DC, ClientR.Left, ClientR.Top, ClientR.Right, ClientR.Bottom);

        if DrawWithThemes then
        begin
          {$IFDEF USETHEMES}
          if not ShowThemedBorder then
          begin
            R := Rect(0, 0, 0, 0);
            GetThemeBackgroundExtent(Themes.ListviewTheme, NCCanvas.Handle, LVP_EMPTYTEXT, LIS_NORMAL, ClientRect, R);
            InflateRect(WindowROrig, R.Left - ClientRect.Left, R.Top - ClientRect.Top);
          end;
          DrawThemeBackground(Themes.ListviewTheme, NCCanvas.Handle, LVP_EMPTYTEXT, LIS_NORMAL, WindowROrig, nil);
          {$ENDIF USETHEMES}
        end else
        begin
          Windows.FillRect(DC, WindowR, Brush.Handle);
          DrawEdge(DC, WindowROrig, InnerStyles[BevelInner] or OuterStyles[BevelOuter],
              Byte(BevelEdges) or EdgeStyles[BevelKind] or Ctl3DStyles[Ctl3D] or BF_ADJUST);
        end
      end else
      begin
        Windows.GetWindowRect(Handle, WindowR);
      end;
    finally
      NCCanvas.Handle := 0;
      ReleaseDC(Handle, DC);
    end
  end
end;

procedure TCustomEasyListview.WMPaint(var Msg: TWMPaint);
// The VCL does a poor job at optimizing the paint messages.  It does not look
// to see what rectangle the system actually needs painted.  Sometimes it only
// needs a small slice of the window painted, why paint it all?  This implementation
// also handles DoubleBuffering better
var
  PaintInfo: TPaintStruct;
begin
  if UpdateCount = 0 then
  begin
    BackBits.Canvas.Lock;
    if not CacheDoubleBufferBits then
    begin
      BackBits.Width := ClientWidth;
      BackBits.Height := ClientHeight;
    end;

    BeginPaint(Handle, PaintInfo);
    try
      if not IsRectEmpty(PaintInfo.rcPaint) then
      begin
        // Assign attributes to the Canvas used
        BackBits.Canvas.Font.Assign(Font);
        BackBits.Canvas.Brush.Color := Color;
        BackBits.Canvas.Brush.Assign(Brush);

        SetWindowOrgEx(BackBits.Canvas.Handle, 0, 0, nil);
        SetViewportOrgEx(BackBits.Canvas.Handle, 0, 0, nil);
        FillRect(BackBits.Canvas.Handle, PaintInfo.rcPaint, Brush.Handle);
        SelectClipRgn(BackBits.Canvas.Handle, 0);  // Remove the clipping region we created

        // Paint the rectangle that is necded
        DoPaintRect(BackBits.Canvas, PaintInfo.rcPaint, False);

        // Remove any clipping regions applied by the views.
        SelectClipRgn(BackBits.Canvas.Handle, 0);
        // Redraw the drag selecting rectangle
        if (ebcsDragSelecting in States) then
          DragRect.PaintSelectionRect(BackBits.Canvas);

        // Blast the bits to the screen
        BitBlt(PaintInfo.hdc, PaintInfo.rcPaint.Left, PaintInfo.rcPaint.Top,
          PaintInfo.rcPaint.Right - PaintInfo.rcPaint.Left,
          PaintInfo.rcPaint.Bottom - PaintInfo.rcPaint.Top,
          BackBits.Canvas.Handle, PaintInfo.rcPaint.Left, PaintInfo.rcPaint.Top, SRCCOPY);
      end
    finally
      BackBits.Canvas.Unlock;
      // Release the Handle from the canvas so that EndPaint may dispose of the DC as it sees fit
      EndPaint(Handle, PaintInfo);
    end;

    if not CacheDoubleBufferBits then
    begin
      BackBits.Width := 0;
      BackBits.Height := 0;
    end
  end
end;

procedure TCustomEasyListview.WMRButtonDblClk(var Msg: TWMRButtonDblClk);
begin
  inherited;
  HandleDblClick(cmbRight, Msg)
end;

procedure TCustomEasyListview.WMRButtonDown(var Msg: TWMRButtonDown);
begin
  Include(FStates, ebcsRButtonDown);
  CheckFocus;
  if IsHeaderMouseMsg(Msg.Pos) then
  begin
    // Should this call a Column manager or a Column?
    if Assigned(Header) then
    begin
      Header.WMRButtonDown(Msg);
      Header.ReleaseMouse;
    end
  end else
  begin
    inherited;
    HandleMouseDown(cmbRight, Msg)
  end
end;

procedure TCustomEasyListview.WMRButtonUp(var Msg: TWMRButtonUp);
begin
  if IsHeaderMouseMsg(Msg.Pos) then
  begin
   // Should this call a Column manager or a Column?
    if Assigned(Header) then
    begin
      inherited;
      // ContextMenu handled it
      if Msg.Result = 0 then
        Header.WMRButtonUp(Msg);
      // Need to allow HotTracking to finish up.
      if Assigned(Header.HotTrackedColumn) then
        Header.WMMouseMove(Msg);
      Header.ReleaseMouse;
    end
  end else
  begin
    if Msg.Result = 0 then
      HandleMouseUp(cmbRight, Msg);
    inherited;  // Handles the context menu     
    Mouse.Capture := 0;
  end;
  ClearStates;
end;

procedure TCustomEasyListview.WMSetCursor(var Msg: TWMSetCursor);
begin       
  inherited;
end;

procedure TCustomEasyListview.WMSetFocus(var Msg: TWMSetFocus);
begin
  inherited;
  SafeInvalidateRect(nil, True);
  //Selection.Invalidate(False)VisibleSelected(False);
end;

procedure TCustomEasyListview.WMSize(var Msg: TWMSize);
begin
  Header.WMSize(Msg);  // do it first
  inherited;
end;

procedure TCustomEasyListview.WMTabMoveFocus(var Msg: TMessage);
var
  NextItem: TEasyItem;
  JumpToNextItem: Boolean;
  NextColumn: TEasyColumn;
begin
  JumpToNextItem := True;
  NextItem := EditManager.TabMoveFocusItem;
  if EditManager.TabEditColumns then
  begin
    NextColumn := EditManager.TabMoveFocusColumn;
    if Assigned(NextColumn) then
    begin
      EditManager.TabMoveFocusItem := nil;
      JumpToNextItem := False;
      NextColumn.MakeVisible(emvTop);
      EditManager.BeginEdit(NextItem, NextColumn);
    end
  end;
  if JumpToNextItem then
  begin
    EditManager.TabMoveFocusItem := nil;
    if Assigned(NextItem) then
    begin
      NextItem.Focused := True;
      NextItem.MakeVisible(emvAuto);
      EditManager.BeginEdit(NextItem, nil)
    end;
  end
end;

procedure TCustomEasyListview.WMVScroll(var Msg: TWMVScroll);
// Called to scroll the Window, the Window is responsible for actually performing
// the scroll
begin
  inherited;
  if Msg.ScrollCode <> SB_ENDSCROLL then
    Include(FStates, ebcsScrolling)
  else
    Exclude(FStates, ebcsScrolling);
  ScrollBars.WMVScroll(Msg);
  SafeInvalidateRect(nil, False);
end;

procedure TCustomEasyListview.WMWindowPosChanged(var Msg: TWMWindowPosChanged);
// Called after the window has changed size
var
  YChanged, XChanged: Boolean;
begin
  YChanged := False;
  XChanged := False;
  // Only use cx and cy if NOSIZE is not used
  if Msg.WindowPos^.flags and SWP_NOSIZE = 0 then
  begin
    YChanged := Height <> Msg.WindowPos.cy;
    XChanged := Width <> Msg.WindowPos.cx;
  end;
  inherited;
  if YChanged or XChanged then
  begin
    Groups.Rebuild;
    ScrollBars.ReCalculateScrollbars(True, False);
    ResizeBackBits(Msg.WindowPos.cx, Msg.WindowPos.cy);

 (*   // Need to "Pull" the view with the window if the scrollbars are maxed out
    if ((Scrollbars.OffsetY = Scrollbars.MaxOffsetY) and Scrollbars.VertBarVisible) or
       ((Scrollbars.OffsetX = Scrollbars.MaxOffsetX) and Scrollbars.HorzBarVisible) then
      SafeInvalidateRect(nil, False);

    // Necessary to keep the background image tracking...
    if BackGround.OffsetTrack then
       SafeInvalidateRect(nil, False) *)

       
    SafeInvalidateRect(nil, False);

 (*//   Groups.Rebuild;
    ScrollBars.ReCalculateScrollbars(False, False);
    ResizeBackBits(Msg.WindowPos.cx, Msg.WindowPos.cy); *)
  end
end;

procedure TCustomEasyListview.WMWindowPosChanging(var Msg: TWMWindowPosChanging);
// Called when the window is changing size
var
  YChanged, XChanged: Boolean;
begin
  YChanged := False;
  XChanged := False;
  // Only use cx and cy if NOSIZE is not used
  if Msg.WindowPos^.flags and SWP_NOSIZE = 0 then
  begin
    YChanged := Height <> Msg.WindowPos.cy;
    XChanged := Width <> Msg.WindowPos.cx;
  end;

  // Track the offset of the background image if desired before the control size is updated
  BackGround.WMWindowPosChanging(Msg);
  inherited;
  // Only use cx and cy if NOSIZE is not used
  if YChanged or XChanged then
  begin
 (*   Groups.Rebuild;
    ScrollBars.ReCalculateScrollbars(True, False);
    ResizeBackBits(Msg.WindowPos.cx, Msg.WindowPos.cy);

    // Need to "Pull" the view with the window if the scrollbars are maxed out
    if ((Scrollbars.OffsetY = Scrollbars.MaxOffsetY) and Scrollbars.VertBarVisible) or
       ((Scrollbars.OffsetX = Scrollbars.MaxOffsetX) and Scrollbars.HorzBarVisible) then
      SafeInvalidateRect(nil, False);

    // Necessary to keep the background image tracking...
    if BackGround.OffsetTrack then
       SafeInvalidateRect(nil, False)   *)
  end
end;

{ TEasyItem }

constructor TEasyCollectionItem.Create(ACollection: TEasyCollection);
begin
  inherited Create();
  Collection := ACollection;
  Include(FState, esosVisible);
  Include(FState, esosEnabled);
  FVisibleIndex := -1;
end;

destructor TEasyCollectionItem.Destroy;
begin
  SetDestroyFlags;
  if Assigned(OwnerListview) then
  begin
    if OwnerListview.HotTrack.PendingObjectCheck = Self then
      OwnerListview.HotTrack.PendingObjectCheck := nil;
    if OwnerListview.HotTrack.FPendingObject = Self then
      OwnerListview.HotTrack.FPendingObject := nil;
  end;
  Freeing;
  inherited;
  if OwnsPaintInfo then
    FreeAndNil(FPaintInfo);
end;

function TEasyCollectionItem.AllowDrag(ViewportPt: TPoint): Boolean;
begin
  Result := True
end;

function TEasyCollectionItem.DefaultImageList(ImageSize: TEasyImageSize): TImageList;
begin
  Result := nil;
  case ImageSize of
   eisSmall: Result := OwnerListview.ImagesSmall;
   eisLarge: Result := OwnerListview.ImagesLarge;
   eisExtraLarge: Result := OwnerListview.ImagesExLarge;
  end
end;

function TEasyCollectionItem.GetAlignment: TAlignment;
begin
  Result := PaintInfo.Alignment
end;

function TEasyCollectionItem.GetBold: Boolean;
begin
  Result := esosBold in State
end;

function TEasyCollectionItem.GetBorder: Integer;
begin
  Result := PaintInfo.Border
end;

function TEasyCollectionItem.GetBorderColor: TColor;
begin
  Result := PaintInfo.BorderColor
end;

function TEasyCollectionItem.GetCaption: WideString;
begin
  Result := GetCaptions(0)
end;

function TEasyCollectionItem.GetCaptionIndent: Integer;
begin
  Result := PaintInfo.CaptionIndent
end;

function TEasyCollectionItem.GetChecked: Boolean;
begin
  Result := esosChecked in State
end;

function TEasyCollectionItem.GetCheckFlat: Boolean;
begin
  Result := PaintInfo.CheckFlat
end;

function TEasyCollectionItem.GetCheckHovering: Boolean;
begin
  Result := esosCheckHover in FState
end;

function TEasyCollectionItem.GetCheckIndent: Integer;
begin
  Result := PaintInfo.CheckIndent
end;

function TEasyCollectionItem.GetCheckPending: Boolean;
begin
  Result := esosCheckPending in FState
end;

function TEasyCollectionItem.GetChecksize: Integer;
begin
  Result := PaintInfo.Checksize
end;

function TEasyCollectionItem.GetCheckType: TEasyCheckType;
begin
  Result := PaintInfo.CheckType
end;

function TEasyCollectionItem.GetClicking: Boolean;
begin
  Result := esosClicking in State
end;

function TEasyCollectionItem.GetCut: Boolean;
begin
  Result := esosCut in State
end;

function TEasyCollectionItem.GetDataInf: IUnknown;
begin
  Result := FDataInf;
end;

function TEasyCollectionItem.GetDestroying: Boolean;
begin
  Result := esosDestroying in State
end;

function TEasyCollectionItem.GetDisplayName: WideString;
begin
  if Caption <> '' then
    Result := Caption
  else
    Result:= ClassName;
end;

function TEasyCollectionItem.GetEnabled: Boolean;
begin
  Result := esosEnabled in State
end;

function TEasyCollectionItem.GetFocused: Boolean;
begin
  Result := esosFocused in State
end;

function TEasyCollectionItem.GetHilighted: Boolean;
begin
  Result := esosHilighted in State
end;

function TEasyCollectionItem.GetHotTracking(MousePos: TPoint): Boolean;
begin
  Result := esosHotTracking in State
end;

function TEasyCollectionItem.GetImageIndent: Integer;
begin
  Result := PaintInfo.ImageIndent
end;

function TEasyCollectionItem.GetImageIndex: Integer;
begin
  Result := GetImageIndexes(0)
end;

function TEasyCollectionItem.GetImageOverlayIndex: Integer;
begin
  Result := GetImageOverlayIndexes(0)
end;

function TEasyCollectionItem.GetIndex: Integer;
begin
  Result := Collection.FList.IndexOf(Self)
end;

function TEasyCollectionItem.GetInitialized: Boolean;
begin
  Result := esosInitialized in State
end;

function TEasyCollectionItem.GetOwner: TPersistent;
begin
  Result := FCollection
end;

function TEasyCollectionItem.GetOwnerListview: TCustomEasyListview;
begin
  Result := TEasyCollection( Collection).FOwnerListview
end;

function TEasyCollectionItem.GetPaintInfo: TEasyPaintInfoBasic;
begin
  if Assigned(FPaintInfo) then
    Result := FPaintInfo
  else
    Result := LocalPaintInfo
end;

function TEasyCollectionItem.GetSelected: Boolean;
begin
  Result := esosSelected in State
end;

function TEasyCollectionItem.GetVAlignment: TEasyVAlignment;
begin
  Result := PaintInfo.VAlignment
end;

function TEasyCollectionItem.GetVisible: Boolean;
begin
  Result := esosVisible in State
end;

function TEasyCollectionItem.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := E_NOINTERFACE
end;

function TEasyCollectionItem._AddRef: Integer;
begin
  Result := -1
end;

function TEasyCollectionItem._Release: Integer;
begin
  Result := -1
end;

procedure TEasyCollectionItem.Invalidate(ImmediateUpdate: Boolean);
var
  R: TRect;
begin
  if OwnerListview.UpdateCount = 0 then
  begin
    R := OwnerListview.Scrollbars.MapViewRectToWindowRect(DisplayRect);
    if IntersectRect(R, R, OwnerListview.ClientRect) then
      OwnerListview.SafeInvalidateRect(@R, ImmediateUpdate);
  end
end;

procedure TEasyCollectionItem.InvalidateItem(ImmediateRefresh: Boolean);
begin
  Invalidate(ImmediateRefresh)
end;

procedure TEasyCollectionItem.LoadFromStream(S: TStream; Version: Integer = STREAM_VERSION);
var
  Temp: TEasyStorageObjectStates;
begin
  S.Read(Temp, SizeOf(Temp));
  // Add back in the stored persisted states
  Selected := esosSelected in Temp;
  Enabled := esosEnabled in Temp;
  Visible := esosVisible in Temp;
  Checked := esosChecked in Temp;
  Bold := esosBold in Temp;

  // For new objects test the stream version first
  // if Collection.StreamVersion > X then
  // begin
  //   ReadStream....
  // end
end;

procedure TEasyCollectionItem.MakeVisible(Position: TEasyMakeVisiblePos);
begin

end;

procedure TEasyCollectionItem.SaveToStream(S: TStream; Version: Integer = STREAM_VERSION);
var
  Temp: TEasyStorageObjectStates;
begin
  Temp := State;
  // Only save certin states that should be persistent
  Temp := State * PERSISTENTOBJECTSTATES;
  S.Write(Temp, SizeOf(Temp));
end;

procedure TEasyCollectionItem.SetAlignment(Value: TAlignment);
begin
  if Value <> Alignment then
  begin
    PaintInfo.Alignment := Value;
    Invalidate(False)
  end
end;

procedure TEasyCollectionItem.SetBold(const Value: Boolean);
begin
  if Value xor (esosBold in FState) then
  begin
    if State * [esosDestroying] <> [] then
    begin
      Exclude(FState, esosBold);
      LosingBold
    end else
    begin
      if CanChangeBold(Value) then
      begin
        if Value then
        begin
          Include(FState, esosBold);
          GainingBold
        end else
        begin
          Exclude(FState, esosBold);
          LosingBold
        end
      end
    end
  end
end;

procedure TEasyCollectionItem.SetBorder(Value: Integer);
begin
  if Value <> Border then
  begin
    if Value < 0 then
      PaintInfo.Border := 0
    else
      PaintInfo.Border := Value;
    Invalidate(False)
  end
end;

procedure TEasyCollectionItem.SetBorderColor(Value: TColor);
begin
  if Value <> BorderColor then
  begin
    if Value < 0 then
      PaintInfo.BorderColor := 0
    else
      PaintInfo.BorderColor := Value;
    Invalidate(False)
  end
end;

procedure TEasyCollectionItem.SetCaption(Value: WideString);
begin
  Captions[0] := Value
end;

procedure TEasyCollectionItem.SetCaptionIndent(Value: Integer);
begin
  if Value <> CaptionIndent then
  begin
    if Value < 0 then
      PaintInfo.CaptionIndent := 0
    else
      PaintInfo.CaptionIndent := Value;
    Invalidate(False)
  end
end;

procedure TEasyCollectionItem.SetChecked(Value: Boolean);
begin
  if Value xor (esosChecked in FState) then
  begin
    if State * [esosDestroying] <> [] then
    begin
      Exclude(FState, esosChecked);
      LosingCheck
    end else
    begin
      if CanChangeCheck(Value) then
      begin
        if Value then
        begin
          Include(FState, esosChecked);
          GainingCheck
        end else
        begin
          Exclude(FState, esosChecked);
          LosingCheck
        end
      end
    end
  end
end;

procedure TEasyCollectionItem.SetCheckFlat(Value: Boolean);
begin
  if Value <> CheckFlat then
  begin
    PaintInfo.CheckFlat := Value;
    Invalidate(False)
  end
end;

procedure TEasyCollectionItem.SetCheckHovering(Value: Boolean);
begin
  if Value xor (esosCheckHover in FState) then
  begin
    if Value then
      Include(FState,esosCheckHover)
    else
      Exclude(FState, esosCheckHover);
    Invalidate(False)
  end
end;

procedure TEasyCollectionItem.SetCheckIndent(Value: Integer);
begin
  if Value <> CheckIndent then
  begin
    if Value < 1 then
      PaintInfo.CheckIndent := 0
    else
      PaintInfo.CheckIndent := Value;
    Invalidate(False)
  end;
end;

procedure TEasyCollectionItem.SetCheckPending(Value: Boolean);
begin
  if Value xor (esosCheckPending in FState) then
  begin
    if Value then
      Include(FState,esosCheckPending)
    else
      Exclude(FState, esosCheckPending);
    Invalidate(False)
  end
end;

procedure TEasyCollectionItem.SetChecksize(Value: Integer);
begin
  if Value <> Checksize then
  begin
    if Value < 0 then
      PaintInfo.Checksize := 0
    else
      PaintInfo.Checksize := Value;

    Invalidate(False)
  end
end;

procedure TEasyCollectionItem.SetCheckType(Value: TEasyCheckType);
begin
  if Value <> CheckType then
  begin
    PaintInfo.CheckType := Value;
    Invalidate(False)
  end
end;

procedure TEasyCollectionItem.SetClicking(Value: Boolean);
begin
  if Value then
    Include(FState, esosClicking)
  else
    Exclude(FState, esosClicking)
end;

procedure TEasyCollectionItem.SetCut(Value: Boolean);
begin
  if Value xor (esosCut in State) then
  begin
    if Value then
      Include(FState, esosCut)
    else
      Exclude(FState, esosCut);
    Invalidate(False)
  end
end;

procedure TEasyCollectionItem.SetData(Value: TObject);
begin
  FData := Value
end;

procedure TEasyCollectionItem.SetDataInf(const Value: IUnknown);
var
  Notifier: IEasyNotifier;
begin
  if Value <> FDataInf then
  begin
    if Supports(DataInf, IEasyNotifier, Notifier) then
      Notifier.OnUnRegisterNotify(Self);
    FDataInf := Value;
    if Supports(DataInf, IEasyNotifier, Notifier) then
      Notifier.OnRegisterNotify(Self)
  end
end;

procedure TEasyCollectionItem.SetDestroyFlags;
begin
  Include(FState, esosDestroying);
end;

procedure TEasyCollectionItem.SetEnabled(Value: Boolean);
begin
  if Value xor (esosEnabled in FState) then
  begin
    if State * [esosDestroying] <> [] then
    begin
      // Disabled items can't have the focus or selection
      Focused := False;
      Selected := False;
      Exclude(FState, esosEnabled);
      LosingEnable
    end else
    begin
      if CanChangeEnable(Value) then
      begin
        if Value then
        begin
          Include(FState, esosEnabled);
          GainingEnable
        end else
        begin
          // Disabled items can't have the focus or selection
          Focused := False;
          Selected := False;
          Exclude(FState, esosEnabled);
          LosingEnable
        end
      end
    end
  end
end;

procedure TEasyCollectionItem.SetFocused(Value: Boolean);
begin
  if Visible and Enabled then
  begin
    if Value xor (esosFocused in State) then
    begin
      if State * [esosDestroying] <> [] then
      begin
        Exclude(FState, esosFocused);
        LosingFocus
      end else
      begin
        if CanChangeFocus(Value) then
        begin
          if Value then
          begin
            Include(FState, esosFocused);
            GainingFocus
          end else
          begin
            Exclude(FState, esosFocused);
            LosingFocus
          end
        end
      end
    end
  end
end;

procedure TEasyCollectionItem.SetHilighted(Value: Boolean);
begin
  if Value xor (esosHilighted in FState) then
  begin
    if State * [esosDestroying] <> [] then
    begin
      // Disabled items can't have the focus or selection
      Focused := False;
      Selected := False;
      Exclude(FState, esosHilighted);
      LosingHilight
    end else
    begin
      if Value then
      begin
        Include(FState, esosHilighted);
        GainingHilight
      end else
      begin
        Exclude(FState, esosHilighted);
        LosingHilight
      end
    end
  end
end;

procedure TEasyCollectionItem.SetHotTracking(MousePos: TPoint; Value: Boolean);
begin
  if Value xor (esosHotTracking in FState) then
  begin
    if State * [esosDestroying] <> [] then
    begin
      Exclude(FState, esosHotTracking);
      LosingHotTracking
    end else
    begin
      if CanChangeHotTracking(Value) then
      begin
        if Value then
        begin
          Include(FState, esosHotTracking);
          GainingHotTracking(MousePos)
        end else
        begin
          Exclude(FState, esosHotTracking);
          LosingHotTracking
        end
      end
    end
  end
end;

procedure TEasyCollectionItem.SetImageIndent(Value: Integer);
begin
  if Value <> ImageIndent then
  begin
    if Value < 0 then
      PaintInfo.ImageIndent := 0
    else
      PaintInfo.ImageIndent := Value;
    Invalidate(False)
  end
end;

procedure TEasyCollectionItem.SetImageIndex(Value: Integer);
begin
  ImageIndexes[0] := Value
end;

procedure TEasyCollectionItem.SetImageOverlayIndex(Value: Integer);
begin
  ImageOverlayIndexes[0] := Value
end;

procedure TEasyCollectionItem.SetInitialized(Value: Boolean);
begin
  if Value xor (esosInitialized in State) then
  begin
    if Value then
    begin
      Include(FState, esosInitialized);
      Initialize;
    end else
      Exclude(FState, esosInitialized)
  end
end;

procedure TEasyCollectionItem.SetPaintInfo(Value: TEasyPaintInfoBasic);
begin
  FPaintInfo := Value
end;

procedure TEasyCollectionItem.SetSelected(Value: Boolean);
begin
  if Visible and Enabled then
  begin
    if Value xor (esosSelected in State) then
    begin
      if State * [esosDestroying] <> [] then
      begin
        Exclude(FState, esosSelected);
            LosingSelection
      end else
      begin
        if CanChangeSelection(Value) then
        begin
          if Value then
          begin
            Include(FState, esosSelected);
            GainingSelection
          end else
          begin
            Exclude(FState, esosSelected);
            LosingSelection
          end
        end
      end
    end
  end
end;

procedure TEasyCollectionItem.SetVAlignment(Value: TEasyVAlignment);
begin
  if Value <> VAlignment then
  begin
    PaintInfo.VAlignment := Value;
    Invalidate(False)
  end
end;

procedure TEasyCollectionItem.SetVisible(Value: Boolean);
begin
  if Value xor (esosVisible in State) then
  begin
    if State * [esosDestroying] <> [] then
    begin
      // Invisible Objects can't be focused or selected
      Focused := False;
      Selected := False;
      Checked := False;
      Exclude(FState, esosVisible);
      LosingVisibility;
    end else
    begin
      if CanChangeVisibility(Value) then
      begin
        if Value then
        begin
          Include(FState, esosVisible);
          GainingVisibility
        end else
        begin
          // Invisible Objects can't be focused or selected or Focused
          Focused := False;
          Selected := False;
          Checked := False;
          Exclude(FState, esosVisible);
          LosingVisibility;
        end
      end
    end
  end
end;

procedure TEasyCollectionItem.UnRegister;
begin
  FDataInf := nil
end;

{ TEasyCollection }

constructor TEasyCollection.Create(AnOwner: TCustomEasyListview);
begin
  inherited Create(AnOwner);
  FItemClass := TEasyCollectionItem;
  FList := TList.Create;         
  VisibleList := TList.Create;
  FStoreInDFM := True;
end;

destructor TEasyCollection.Destroy;
begin
  Clear;
  inherited;
  FreeAndNil(FVisibleList);
  FreeAndNil(FList);
end;

function TEasyCollection.Add(Data: TObject = nil): TEasyCollectionItem;
begin
  Result := ItemClass.Create(Self);
  if Assigned(Result) then
  begin
    FList.Add(Result);
    ReIndexItems;
    DoItemAdd(Result, FList.Count - 1);
    Result.Data := Data;
    DoStructureChange
  end
end;

function TEasyCollection.DoStore: Boolean;
begin
  Result := (FList.Count > 0) and StoreInDFM
end;

function TEasyCollection.GetCount: Integer;
begin
  Result := FList.Count
end;

function TEasyCollection.GetItem(Index: Integer): TEasyCollectionItem;
begin
  Result := TEasyCollectionItem(FList.List[Index])
end;

function TEasyCollection.GetOwner: TPersistent;
begin
  Result:= FOwnerListview
end;

function TEasyCollection.GetOwnerListview: TCustomEasyListview;
begin
  Result := FOwnerListview
end;

function TEasyCollection.GetReIndexDisable: Boolean;
begin
  Result := FReIndexCount > 0
end;

function TEasyCollection.GetVisibleCount: Integer;
begin
  Result := FVisibleList.Count
end;

function TEasyCollection.Insert(Index: Integer; Data: TObject = nil): TEasyCollectionItem;
begin
  Result := ItemClass.Create(Self);
  if Assigned(Result) then
  begin
    FList.Insert(Index, Result);
    ReIndexItems;
    DoItemAdd(Result, Index);
    Result.Data := Data;
    DoStructureChange
  end
end;

procedure TEasyCollection.Clear(FreeItems: Boolean = True);
var
  i: Integer;
begin
  if FList.Count > 0 then
  begin
    BeginUpdate(False);
    try
      // Need to make sure all items are valid so nothing unexpected happens in the
      // controls events when the item state changes
      for i := 0 to FList.Count - 1 do
      begin
        TEasyCollectionItem(FList[i]).SetDestroyFlags;
        TEasyCollectionItem(FList[i]).Focused := False;
        TEasyCollectionItem(FList[i]).Selected := False;
      end;

      if FreeItems then
        for i := FList.Count - 1 downto 0 do   // Walk backwords
          TEasyCollectionItem(FList[i]).Free;
    finally
      FList.Clear;
      // The scrollbars do not update correctly on nested BeginUpdate/EndUpdate
      if Assigned(OwnerListview) and OwnerListview.HandleAllocated then
      begin
        OwnerListview.Scrollbars.OffsetX := 0;
        OwnerListview.Scrollbars.OffsetY := 0;
      end;
      EndUpdate;
    end;
  end;
end;

procedure TEasyCollection.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('Items', ReadItems, WriteItems, DoStore);
end;

procedure TEasyCollection.Delete(Index: Integer);
var
  Item: TEasyCollectionItem;
begin
  Item := FList[Index];
  Item.SetDestroyFlags;
  Item.Focused := False;
  Item.Selected := False;
  FList.Delete(Index);
  Item.Free;
  ReIndexItems;
  DoStructureChange
end;

procedure TEasyCollection.DoItemAdd(Item: TEasyCollectionItem; Index: Integer);
begin

end;

procedure TEasyCollection.DoStructureChange;
begin

end;

procedure TEasyCollection.EndUpdate(Invalidate: Boolean = True);
begin
  inherited;
  OwnerListview.EndUpdate(Invalidate);
end;

procedure TEasyCollection.BeginUpdate(ReIndex: Boolean);
begin
  inherited;
  OwnerListview.BeginUpdate;
end;

procedure TEasyCollection.Exchange(Index1, Index2: Integer);
var
  Temp: TEasyCollectionItem;
begin
  Temp := TEasyCollectionItem( FList[Index1]);
  FList[Index1] := FList[Index2];
  FList[Index2] := Temp;
  ReIndexItems;
  DoStructureChange
end;

procedure TEasyCollection.ReadItems(Stream: TStream);
var
  i, ItemCount: Integer;
begin
  Clear;
  StreamVersion := StreamHelper.ReadInteger(Stream);
  ItemCount := StreamHelper.ReadInteger(Stream);
  for i := 0 to ItemCount - 1 do
    Add.LoadFromStream(Stream); // Create a new item and read in data
end;

procedure TEasyCollection.ReIndexItems;
var
  i: Integer;
begin
  if not OwnerListview.Groups.ReIndexDisable then
  begin
    for i := 0 to List.Count - 1 do
      TEasyCollectionItem( List[i]).FIndex := i
  end
end;

procedure TEasyCollection.SetItem(Index: Integer; Value: TEasyCollectionItem);
begin
  FList[Index]  := Value
end;

procedure TEasyCollection.SetReIndexDisable(const Value: Boolean);
begin
  if Value then
  begin
    Inc(FReIndexCount)
  end else
  begin
    Dec(FReIndexCount);
    if ReIndexCount <=0 then
    begin
      ReIndexCount := 0;
      ReIndexItems
    end
  end
end;

procedure TEasyCollection.WriteItems(Stream: TStream);
var
  i: Integer;
begin
  // Write the StreamVersion to the stream
  StreamHelper.WriteInteger(Stream, StreamVersion);
  // Store the number of items we are storing
  StreamHelper.WriteInteger(Stream, FList.Count);
  for i := 0 to FList.Count - 1 do
    TEasyCollectionItem( Items[i]).SaveToStream(Stream); // Write custom data to the stream
end;

{ TEasyHeader }

constructor TEasyHeader.Create(AnOwner: TCustomEasyListview);
begin
  inherited;
  FColumns := TEasyColumns.Create(AnOwner);
  FPositions := TColumnPos.Create;
  FDragManager := TEasyHeaderDragManager.Create(AnOwner);
  DragManager.Header := Self;
  FFont := TFont.Create;
  OldFontChange := Font.OnChange;
  Font.OnChange := FontChanged;
  FHeight := 21;
  FColor := clBtnFace;
  FSizeable := True;
  Draggable := True;
  LastWidth := -1;
  FStreamColumns := True
end;

destructor TEasyHeader.Destroy;
begin
  Columns.Clear;
  Font.OnChange := OldFontChange;
  FreeAndNil(FCanvasStore);
  inherited;
  FreeAndNil(FColumns);
  FreeAndNil(FPositions);
  FreeAndNil(FFont);
  FreeAndNil(FDragManager);
end;

function TEasyHeader.FirstColumn: TEasyColumn;
begin
  if Columns.Count > 0 then
    Result := Columns[0]
  else
    Result := nil
end;

function TEasyHeader.FirstColumnByPosition: TEasyColumn;
begin
  if Positions.Count > 0 then
    Result := Positions[0]
  else
    Result := nil
end;

function TEasyHeader.FirstColumnInRect(ViewportRect: TRect): TEasyColumn;
//
// Always assumes by Position as this is a UI function
//
var
  i: Integer;
  ScratchR: TRect;
begin
  Result := nil;
  i := 0;
  OffsetRect(ViewportRect, 0, -ViewportRect.Top);
  while (i < Positions.Count) and not Assigned(Result) do
  begin
    if Positions[i].Visible then
      if IntersectRect(ScratchR, Positions[i].DisplayRect, ViewportRect) then
        Result := Positions[i];
    Inc(i)
  end
end;

function TEasyHeader.FirstVisibleColumn: TEasyColumn;
var
  i: Integer;
  Column: TEasyColumn;
begin
  Result := nil;
  Column := FirstColumn;
  i := 0;
  while not Assigned(Result) and (i < Columns.Count) do
  begin
    if Assigned(Column) then
    begin
      if Column.Visible then
        Result := Column
      else begin
        Column := NextColumn(Column);
        Inc(i)
      end;
    end
  end
end;

function TEasyHeader.GetCanvasStore: TEasyCanvasStore;
begin
  if not Assigned(FCanvasStore) then
    FCanvasStore := TEasyCanvasStore.Create;
  Result := FCanvasStore
end;

function TEasyHeader.GetDisplayRect: TRect;
begin
  Result := Rect(0, 0, OwnerListview.ClientWidth, RuntimeHeight)
end;

function TEasyHeader.GetDraggable: Boolean;
begin
  Result := DragManager.Enabled
end;

function TEasyHeader.GetMouseCaptured: Boolean;
begin
  Result := (ebcsHeaderCapture in OwnerListview.States) and (ehsMouseCaptured in State)
end;

function TEasyHeader.GetRuntimeHeight: Integer;
begin
  if OwnerListview.ViewSupportsHeader and Visible then
    Result := FHeight
  else
    Result := 0;
end;

function TEasyHeader.InCheckZone(ViewportPt: TPoint; var Column: TEasyColumn): Boolean;
var
  RectArray: TEasyRectArrayObject;
begin
  Result := False;
  Column := Columns.ColumnByPoint(ViewportPt);
  if Assigned(Column) then
  begin
    Columns.View.ItemRectArray(Column, RectArray);
    Result := PtInRect(RectArray.CheckRect, ViewportPt)
  end
end;

function TEasyHeader.InHotTrackZone(ViewportPt: TPoint; var Column: TEasyColumn): Boolean;
var
  i: Integer;
  R, ClientR: TRect;
begin
  Result := False;
  if OwnerListview.PaintInfoColumn.HotTrack then
  begin
    Column := nil;
    ClientR := OwnerListview.ClientRect;
    OffsetRect(ClientR, OwnerListview.Scrollbars.OffsetX, 0);
    i := 0;
    while not Result and (i < OwnerListview.Header.Positions.Count) do
    begin
      R := OwnerListview.Header.Positions[i].DisplayRect;
      // Don't switch hottracking column until done with resize arrow
      Inc(R.Right, RESIZEHITZONEMARGIN + 1);
      IntersectRect(R, R, ClientR);
      if PtInRect(R, ViewportPt) then
      begin
        Column := OwnerListview.Header.Positions[i];
        Result := True
      end;
      Inc(i)
    end;
    if not Result then
      Result := Assigned(HotTrackedColumn);
  end
end;

function TEasyHeader.InPressZone(ViewportPt: TPoint; var Column: TEasyColumn): Boolean;
var
  i: Integer;
  R: TRect;
begin
  Result := False;
  Column := nil;
  i := OwnerListview.Header.Positions.Count - 1;
  while not Result and (i > -1) do
  begin
    R := OwnerListview.Header.Positions[i].DisplayRect;
    if PtInRect(R, ViewportPt) then
    begin
      Column := OwnerListview.Header.Positions[i];
      if Assigned(Column) then
        Result := Column.Clickable
    end;
    Dec(i)
  end
end;

function TEasyHeader.InResizeZone(ViewportPt: TPoint; var Column: TEasyColumn): Boolean;
var
  i: Integer;
  R, ClientR: TRect;
begin
  Result := False;
  if Sizeable then
  begin
    Column := nil;
    i := OwnerListview.Header.Positions.Count - 1;
    ClientR := OwnerListview.ClientRect;
    OffsetRect(ClientR, OwnerListview.Scrollbars.OffsetX, 0);
    while not Result and (i > -1) do
    begin
      if Positions[i].Visible then
      begin
        R := Positions[i].DisplayRect;
        if (ViewportPt.X <= R.Right + RESIZEHITZONEMARGIN) and (ViewportPt.X > R.Right - RESIZEHITZONEMARGIN)
          and (ViewportPt.Y < Height) and (ViewportPt.Y > 0) and (R.Right <= ClientR.Right) then
        begin
          Column := OwnerListview.Header.Positions[i];
          Result := True
        end;
      end;
      Dec(i)
    end
  end
end;

function TEasyHeader.IsFontStored: Boolean;
begin
  Result := not OwnerListview.ParentFont and not OwnerListview.DesktopFont;
end;

function TEasyHeader.LastColumn: TEasyColumn;
begin
  if Columns.Count > 0 then
    Result := Columns[Columns.Count - 1]
  else
    Result := nil
end;

function TEasyHeader.LastColumnByPosition: TEasyColumn;
begin
  if Positions.Count > 0 then
    Result := Positions[Positions.Count - 1]
  else
    Result := nil
end;

function TEasyHeader.LastVisibleColumn: TEasyColumn;
var
  i: Integer;
  Column: TEasyColumn;
begin
  Result := nil;
  Column := LastColumn;
  i := Columns.Count - 1;
  while not Assigned(Result) and (i > -1 ) do
  begin
    if Assigned(Column) then
    begin
      if Column.Visible then
        Result := Column
      else begin
        Column := PrevColumn(Column);
        Dec(i)
      end;
    end
  end
end;

function TEasyHeader.NextColumn(AColumn: TEasyColumn): TEasyColumn;
begin
  Result := nil;
  if AColumn.Index < Columns.Count - 1 then
    Result := Columns[AColumn.Index + 1]
end;

function TEasyHeader.NextColumnByPosition(AColumn: TEasyColumn): TEasyColumn;
begin
  Result := nil;
  if AColumn.Position < Columns.Count - 1 then
    Result := Positions[AColumn.Position + 1]
end;

function TEasyHeader.NextColumnInRect(Column: TEasyColumn; ViewportRect: TRect): TEasyColumn;
//
// Always assumes by Position as this is a UI function
//
var
  i: Integer;
  ScratchR: TRect;
  Done: Boolean;
begin
  Result := nil;
  Done := False;
  if Assigned(Column) then
  begin
    i := Column.Position + 1;
    OffsetRect(ViewportRect, 0, -ViewportRect.Top);
    while not Assigned(Result) and (i < Positions.Count) and not Done do
    begin
      if Positions[i].Visible and (Positions[i].Width > 0) then
      begin
        if IntersectRect(ScratchR, Positions[i].DisplayRect, ViewportRect) then
          Result := Positions[i]
        else
          Done := True
      end;
      Inc(i)
    end
  end
end;

function TEasyHeader.NextVisibleColumn(Column: TEasyColumn): TEasyColumn;
var
  i: Integer;
begin
  Result := nil;
  Column := NextColumn(Column);
  if Assigned(Column) then
  begin
    i := Column.Index;
    while not Assigned(Result) and (i < Columns.Count) do
    begin
      if Column.Visible then
        Result := Column
      else begin
        Column := NextColumn(Column);
        Inc(i)
      end;
    end
  end
end;

function TEasyHeader.PrevColumn(AColumn: TEasyColumn): TEasyColumn;
begin
  Result := nil;
  if AColumn.Index > 0 then
    Result := Columns[AColumn.Index - 1]
end;

function TEasyHeader.PrevColumnByPosition(AColumn: TEasyColumn): TEasyColumn;
begin
  Result := nil;
  if AColumn.Position > 0 then
    Result := Positions[AColumn.Position - 1]
end;

function TEasyHeader.PrevVisibleColumn(Column: TEasyColumn): TEasyColumn;
var
  i: Integer;
begin
  Result := nil;
  Column := PrevColumn(Column);
  if Assigned(Column) then
  begin
    i := Column.Index;
    while not Assigned(Result) and (i > -1 ) do
    begin
      if Column.Visible then
        Result := Column
      else begin
        Column := PrevColumn(Column);
        Dec(i)
      end
    end
  end
end;

procedure TEasyHeader.CaptureMouse;
begin
  Include(OwnerListview.FStates, ebcsHeaderCapture);
  Include(FState, ehsMouseCaptured);
  SetCapture(OwnerListview.Handle);
end;

procedure TEasyHeader.ClearStates;
begin
  Exclude(FState, ehsMouseCaptured);
  Exclude(FState, ehsResizing);
  Exclude(FState, ehsDragging);
  Exclude(FState, ehsDragPending);
  Exclude(FState, ehsClickPending);
  Exclude(FState, ehsResizePending);
  Exclude(FState, ehsLButtonDown);
  Exclude(FState, ehsRButtonDown);
  Exclude(FState, ehsMButtonDown);
  ReleaseMouse;   
end;

procedure TEasyHeader.DoMouseDown(var Message: TWMMouse; Button: TCommonMouseButton;
  Shift: TShiftState; Column: TEasyColumn);
begin
  if Assigned(OwnerListview.OnHeaderMouseDown) then
    OwnerListview.OnHeaderMouseDown(OwnerListview, Button, Shift, Message.XPos, Message.YPos, Column)
end;

procedure TEasyHeader.DoMouseMove(var Message: TWMMouse; Shift: TShiftState);
begin
  if Assigned(OwnerListview.OnHeaderMouseUp) then
    OwnerListview.OnHeaderMouseMove(OwnerListview, Shift, Message.XPos, Message.YPos)
end;

procedure TEasyHeader.DoMouseUp(var Message: TWMMouse; Button: TCommonMouseButton;
  Shift: TShiftState; Column: TEasyColumn);
begin
  if Assigned(OwnerListview.OnHeaderMouseUp) then
    OwnerListview.OnHeaderMouseUp(OwnerListview, Button, Shift, Message.XPos, Message.YPos, Column)
end;

procedure TEasyHeader.FontChanged(Sender: TObject);
begin
  OwnerListview.ParentFont := False;
  Invalidate(False);
  if Assigned(OldFontChange) then
    OldFontChange(Sender);
end;

procedure TEasyHeader.HandleHotTrack(Msg: TWMMouse; ForceClear: Boolean);
var
  TempColumn, OldColumn: TEasyColumn;
begin
  if ForceClear then
  begin
    if Assigned(HotTrackedColumn) then
    begin
      ReleaseMouse;
      OldColumn := HotTrackedColumn;
      HotTrackedColumn := nil;
      OldColumn.Invalidate(True)
    end;
  end else
  begin
    Inc(Msg.Pos.x, OwnerListview.Scrollbars.OffsetX);
    if not ([ehsResizing, ehsResizePending, ehsClickPending, ehsDragging, ehsClickPending] * State <> []) then
      if InHotTrackZone(SmallPointToPoint(Msg.Pos), TempColumn) or Assigned(HotTrackedColumn) then
      begin
        if TempColumn <> HotTrackedColumn then
        begin
          if Assigned(HotTrackedColumn) then
          begin
            ReleaseMouse;
            OldColumn := HotTrackedColumn;
            HotTrackedColumn := nil;
            OldColumn.Invalidate(True)
          end;
          HotTrackedColumn := TempColumn;
          if Assigned(HotTrackedColumn) then
          begin
            CaptureMouse;
            HotTrackedColumn.Invalidate(True)
          end
        end
     end
  end
end;

procedure TEasyHeader.Invalidate(ImmediateUpdate: Boolean);
begin
  if OwnerListview.UpdateCount = 0 then
    OwnerListview.SafeInvalidateRect(nil, ImmediateUpdate)
end;

procedure TEasyHeader.InvalidateColumn(Item: TEasyColumn;
  ImmediateUpdate: Boolean);
begin

end;

procedure TEasyHeader.LoadFromStream(S: TStream);
begin
  inherited LoadFromStream(S);
  if StreamColumns then
    Columns.ReadItems(S)
end;

procedure TEasyHeader.PaintTo(ACanvas: TCanvas; ARect: TRect);
var
  Column: TEasyColumn;
  Handled: Boolean;
  {$IFDEF USETHEMES}
  PartID,
  StateID: LongWord;
  {$ENDIF}
begin
  Handled := False;
  CanvasStore.StoreCanvasState(ACanvas);
  OwnerListview.DoPaintHeaderBkGnd(ACanvas, ViewRect, Handled);
  CanvasStore.RestoreCanvasState(ACanvas);
  if not Handled then
  begin
    {$IFDEF USETHEMES}
    if OwnerListview.DrawWithThemes then
    begin
      PartID := HP_HEADERITEM;
      StateID := HIS_NORMAL;
      DrawThemeBackground(OwnerListview.Themes.HeaderTheme, ACanvas.Handle, PartID, StateID, ViewRect, nil);
    end else
    {$ENDIF USETHEMES}
    begin
      ACanvas.Brush.Color := Color;
      ACanvas.FillRect(DisplayRect);
    end;
  end;
  Column := FirstColumnInRect(ARect);
  while Assigned(Column) do
  begin
    // Reset the clipping region
    SelectClipRgn(ACanvas.Handle, 0);
    Column.Paint(ACanvas, ehtHeader);
    Column := NextColumnInRect(Column, ARect);
  end
end;

procedure TEasyHeader.SaveToStream(S: TStream);
begin
  inherited SaveToStream(S);
  if StreamColumns then
    Columns.WriteItems(S)
end;

procedure TEasyHeader.SetDraggable(Value: Boolean);
begin
  DragManager.Enabled := Value
end;

procedure TEasyHeader.SetFixedSingleColumn(const Value: Boolean);
begin
  Columns.Clear;
  if Value then
  begin
    Columns.Add.Width := OwnerListview.Width;
    OwnerListview.Groups.Rebuild
  end;
  FFixedSingleColumn := Value;
end;

procedure TEasyHeader.SizeFixedSingleColumn(NewWidth: Integer);
begin
  if Columns.Count > 0 then
    Columns[0].Width := NewWidth;
end;

procedure TEasyHeader.SpringColumns(NewWidth: Integer);
//
// Credit goes to VirtualTreeview by Mike Lischke
var
  I: Integer;
  SpringCount: Integer;
  Sign: Integer;
  ChangeBy: Single;
  Difference: Single;
  NewAccumulator: Single;
begin
  ChangeBy := RectWidth(DisplayRect) - FLastWidth;
  if (ChangeBy <> 0) then
  begin
    // Stay positive if downsizing the control.
    if ChangeBy < 0 then
      Sign := -1
    else
      Sign := 1;
    ChangeBy := Abs(ChangeBy);
    // Count how many columns have spring enabled.
    SpringCount := 0;
    for I := 0 to Columns.Count-1 do
      if Columns[i].AutoSpring and Columns[i].Visible then
        Inc(SpringCount);
    if SpringCount > 0 then
    begin
      // Calculate the size to add/sub to each columns.
      Difference := ChangeBy / SpringCount;
      // Adjust the column's size accumulators and resize if the result is >= 1.
      for I := 0 to Columns.Count - 1 do
        if Columns[i].AutoSpring and Columns[i].Visible then
        begin
          // Sum up rest changes from previous runs and the amount from this one and store it in the
          // column. If there is at least one pixel difference then do a resize and reset the accumulator.
          NewAccumulator := Columns[I].FSpringRest + Difference;
          // Set new width if at least one pixel size difference is reached.
          if NewAccumulator >= 1 then
            FColumns[I].SetWidth(FColumns[I].FWidth + (Trunc(NewAccumulator) * Sign));
          FColumns[I].FSpringRest := Frac(NewAccumulator);
          
          // Keep track of the size count.
          ChangeBy := ChangeBy - Difference;
          // Exit loop if resize count drops below freezing point.
          if ChangeBy < 0 then
            Break;
        end;
    end;
  end;
end;

procedure TEasyHeader.WMContextMenu(var Msg: TMessage);
var
  Column: TEasyColumn;
  ViewPt, Pt: TPoint;
  HitInfoColumn: TEasyHitInfoColumn;
  Menu: TPopupMenu;
begin
  Menu := OwnerListview.PopupMenuHeader;
  Pt := OwnerListview.ScreenToClient(Point( Msg.LParamLo, Msg.LParamHi));
  ViewPt := OwnerListview.Scrollbars.MapWindowToView(Pt, False);
  HitInfoColumn.Column := Columns.ColumnByPoint(ViewPt);
  Column := Columns.ColumnByPoint(ViewPt);
  if Assigned(HitInfoColumn.Column) then
    Column.HitTestAt(ViewPt, HitInfoColumn.HitInfo)
  else
    HitInfoColumn.HitInfo := [];
  // HitInfoColumn.Column will be nil if it hits the backgound of the header
  OwnerListview.DoColumnContextMenu(HitInfoColumn, Pt, Menu);
  if Assigned(Menu) then
  begin
    Menu.Popup(Msg.LParamLo, Msg.LParamHi);
    Msg.Result := 1
  end else
    inherited;
end;

procedure TEasyHeader.WMSize(var Msg: TWMSize);
begin
  if LastWidth < 0 then
    LastWidth := RectWidth(DisplayRect);
  if FixedSingleColumn then
    SizeFixedSingleColumn(Msg.Width)
  else
    SpringColumns(Msg.Width);
  LastWidth := RectWidth(DisplayRect)
end;

function SortByPosition(Item1, Item2: Pointer): Integer;
begin
  Result := TEasyColumn(Item1).Position - TEasyColumn(Item2).Position
end;

procedure TEasyHeader.Rebuild(Force: Boolean);
var
  i: Integer;
begin
  if Force or ((OwnerListview.UpdateCount = 0) and not(csLoading in OwnerListview.ComponentState) and (OwnerListview.HandleAllocated)) then
  begin
    Positions.Clear;
    Positions.Capacity := Positions.Count;
    for i := 0 to Columns.Count - 1 do
      Positions.Add(Columns[i]);
    Positions.Sort(SortByPosition);
    for i := 0 to Columns.Count - 1 do
      Positions[i].FPosition := i;


    SetRect(FViewRect, 0, 0, 0, 0);
    for i := 0 to Positions.Count - 1 do
    begin
      if i > 0 then
      begin
        Positions[i].FDisplayRect := Positions[i-1].FDisplayRect;
        Positions[i].FDisplayRect.Left := Positions[i].FDisplayRect.Right;
        if Positions[i].Visible then
          Positions[i].FDisplayRect.Right := Positions[i].FDisplayRect.Left + Positions[i].Width
        else
          Positions[i].FDisplayRect.Right := Positions[i].FDisplayRect.Left;
      end else
      begin
        if Positions[i].Visible then
          Positions[i].FDisplayRect := Rect(0, 0, Positions[i].Width, Height)
        else
          Positions[i].FDisplayRect := Rect(0, 0, 0, Height)
      end;

      UnionRect(FViewRect, ViewRect, Positions[i].DisplayRect);
      if RectWidth(ViewRect) < OwnerListview.Width then
        FViewRect.Right := OwnerListview.Width;
    end
  end
end;

procedure TEasyHeader.ReleaseMouse;
begin
  Exclude(FState, ehsMouseCaptured);
  Exclude(OwnerListview.FStates, ebcsHeaderCapture);
  if GetCapture = OwnerListview.Handle then
    ReleaseCapture
end;

procedure TEasyHeader.SetColor(Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Invalidate(False);
  end
end;

procedure TEasyHeader.SetFont(Value: TFont);
begin
  Font.Assign(Value)
end;

procedure TEasyHeader.SetHeight(Value: Integer);
begin
  if FHeight <> Value then
  begin
    if Value > -1 then
      FHeight := Value
    else
      FHeight := 0;
    OwnerListview.Groups.Rebuild
  end
end;

procedure TEasyHeader.SetImages(Value: TImageList);
begin
  if Value <> FImages then
  begin
    FImages := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TEasyHeader.SetVisible(Value: Boolean);
begin
  if Value <> FVisible then
  begin
    FVisible := Value;
    OwnerListview.Groups.Rebuild
  end;
end;

{ TEasyItemView }

procedure TEasyHeader.WMLButtonDblClk(var Msg: TWMLButtonDblClk);
var
  ViewPt: TPoint;
  Column: TEasyColumn;
  Button: TCommonMouseButton;
begin
  Button := KeyStatesToMouseButton(Msg.Keys);
  ViewPt := SmallPointToPoint(Msg.Pos);
  Inc(ViewPt.X, OwnerListview.Scrollbars.OffsetX);
  if InResizeZone(ViewPt, Column) and (ehsResizePending in State) then
  begin
    if Column.AutoSizeOnDblClk then
       Column.AutoSizeToFit
  end;
  Column := Columns.ColumnByPoint(ViewPt);
  OwnerListview.DoHeaderDblClick(Button, SmallPointToPoint(Msg.Pos), KeysToShiftState(Msg.Keys));
  if Assigned(Column) then
    OwnerListview.DoColumnDblClick(Button, KeysToShiftState(Msg.Keys), SmallPointToPoint(Msg.Pos), Column);
end;

procedure TEasyHeader.WMLButtonDown(var Msg: TWMLButtonDown);
var
  ViewPt: TPoint;
  TempColumn: TEasyColumn;
begin
  ViewPt := SmallPointToPoint(Msg.Pos);
  Inc(ViewPt.X, OwnerListview.Scrollbars.OffsetX);

  Include(FState, ehsLButtonDown);
  if ehsResizePending in State then
  begin
    Exclude(FState, ehsResizePending);
    Include(FState, ehsResizing);
  end else
  if InCheckZone(ViewPt, TempColumn) then
  begin
    Include(FState, ehsCheckboxClickPending);
    OwnerListview.HotTrack.PendingObjectCheck := nil;
    OwnerListview.CheckManager.PendingObject := TempColumn;
  end else
  if InPressZone(ViewPt, FPressColumn) then
  begin
    // Clear the Hottrack item
    if OwnerListview.PaintInfoColumn.HotTrack then
      HandleHotTrack(Msg, True);
    CaptureMouse;
    if PressColumn.Clickable then
    begin
      Include(FState, ehsClickPending);
      Include(PressColumn.FState, esosClicking);
    end;
    if Draggable then
      Include(FState, ehsDragPending);
    PressColumn.Invalidate(True);
  end else
    DoMouseDown(Msg, cmbLeft, KeysToShiftState(Msg.Keys), Columns.ColumnByPoint(ViewPt));
end;

procedure TEasyHeader.WMLButtonUp(var Msg: TWMLButtonUp);
const
  NEXT_SORT_DIRECTION: array[TEasySortDirection] of TEasySortDirection =
    (esdAscending, esdDescending, esdAscending);
var
  ViewPt: TPoint;
  PreviousFocusedColumn: TEasyColumn;
begin
  ViewPt := SmallPointToPoint(Msg.Pos);
  Inc(ViewPt.X, OwnerListview.Scrollbars.OffsetX);

  if ehsCheckboxClickPending in State then
  begin
    if InCheckZone(ViewPt, PreviousFocusedColumn) then
      PreviousFocusedColumn.Checked := not PreviousFocusedColumn.Checked;
    OwnerListview.CheckManager.PendingObject.CheckHovering := False;
    OwnerListview.CheckManager.PendingObject.CheckPending := False;
    OwnerListview.CheckManager.PendingObject := nil;
  end else
  if ehsResizing in State then
  begin
    OwnerListview.DoColumnSizeChanged(ResizeColumn);
  end else
  if Assigned(PressColumn) then
  begin
    if esosClicking in PressColumn.State then
    begin
      Exclude(PressColumn.FState, esosClicking);
      if PressColumn.AutoToggleSort then
      begin
        // If sorting takes a bit it is better to "freeze" the painting
        // so the sort arrows don't show the "wrong" way then change when
        // the sort is done.
        OwnerListview.BeginUpdate;
        try
          PreviousFocusedColumn := OwnerListview.Selection.FocusedColumn;
          OwnerListview.Selection.FocusedColumn := PressColumn;

          // If the column has changed the previous column must forget its
          // sort direction. When it is clicked on next time it will start
          // again with SortDirection = esdAscending.
          if PreviousFocusedColumn <> PressColumn then
            PreviousFocusedColumn.SortDirection := esdNone;

          // Now toggle new column's sort direction and regroup / resort
          // if necded.
          PressColumn.SortDirection := NEXT_SORT_DIRECTION[PressColumn.SortDirection];
          if OwnerListview.Sort.AutoReGroup and OwnerListview.IsGrouped then
            OwnerListview.Sort.ReGroup(PressColumn)
          else if OwnerListview.Sort.AutoSort then
            OwnerListview.Sort.SortAll;
        finally
          OwnerListview.EndUpdate
        end;
      end;

      OwnerListview.DoColumnClick(cmbLeft, PressColumn);
    end else
      PressColumn.Invalidate(True);
  end;
  if [ehsResizing, ehsDragging] * FState = [] then
    DoMouseUp(Msg, cmbLeft, KeysToShiftState(Msg.Keys), Columns.ColumnByPoint(ViewPt));

  Exclude(FState, ehsLButtonDown);
  Exclude(FState, ehsResizing);
  Exclude(FState, ehsClickPending);
  Exclude(FState, ehsDragging);
  Exclude(FState, ehsDragPending);
  Exclude(FState, ehsCheckboxClickPending);
end;

procedure TEasyHeader.WMMouseMove(var Msg: TWMMouseMove);

    procedure Press(Column: TEasyColumn; Pressed: Boolean);
    begin
      if Assigned(Column) then
      begin
        if Pressed then
          Include(Column.FState, esosClicking)
        else
          Exclude(Column.FState, esosClicking);
        Column.Invalidate(True);
      end;
    end;

var
  ViewPt: TPoint;
  Allow: Boolean;
  TempColumn: TEasyColumn;
  ClientR: TRect;
  HotTrackCheckObj: TEasyCollectionItem;
  Effects: TCommonDropEffect;

begin
  ClientR := ViewRect;
  ViewPt := SmallPointToPoint(Msg.Pos);
  ViewPt.X := ViewPt.X + OwnerListview.Scrollbars.OffsetX;
  OffsetRect(ClientR, OwnerListview.Scrollbars.OffsetX, 0);
  if not MouseCaptured and Assigned(Self.HotTrackedColumn) then
    CaptureMouse;

  HotTrackCheckObj := nil;

  if OwnerListview.PaintInfoColumn.HotTrack then
    HandleHotTrack(Msg, False);
                                  
  if ehsResizing in State then
  begin
    Allow := True;
    OwnerListview.DoColumnSizeChanging(ResizeColumn, ResizeColumn.Width, ViewPt.X - ResizeColumn.DisplayRect.Left, Allow);
    if Allow then
    begin
      ResizeColumn.Width := ViewPt.X - ResizeColumn.DisplayRect.Left;
      OwnerListview.Groups.Rebuild(True)
    end
  end else
  if ehsDragging in State then
  begin
    Effects := cdeMove;
    DragManager.Drag(OwnerListview.Canvas, ViewPt, KeyToKeyStates(Msg.Keys), Effects);
  end else
  if ehsResizePending in State then
  begin
    if not InResizeZone(ViewPt, FResizeColumn) then
    begin
      FResizeColumn := nil;
      Exclude(FState, ehsResizePending);
      ReleaseMouse;
      OwnerListview.Cursor := crDefault;
      if Assigned(HotTrackedColumn) then
        CaptureMouse
    end
  end else
  if (ehsDragPending in State) and DragManager.Enabled then
  begin
    if DragDetectPlus(OwnerListview.Handle, SmallPointToPoint(Msg.Pos)) then
    begin
      Exclude(FState, ehsDragPending);
      Exclude(FState, ehsClickPending);
      Include(FState, ehsDragging);
      DragManager.Column := PressColumn;
      Press(PressColumn, False);
      PressColumn := nil;
      DragManager.BeginDrag(ViewPt, KeyToKeyStates(Msg.Keys));
    end
  end else
  if ehsClickPending in State then
  begin
    //
  end else
  if InCheckZone(ViewPt, TempColumn) then
  begin
    HotTrackCheckObj := TempColumn;
  end else
  if InResizeZone(ViewPt, FResizeColumn) then
  begin
    Allow := True;
    OwnerListview.DoColumnSizeChanging(ResizeColumn, ResizeColumn.Width, ResizeColumn.Width, Allow);
    if Allow then
    begin
      // Some other thing may have the mouse captured and the Cursor won't take
      ReleaseCapture;
      Include(FState, ehsResizePending);
      OwnerListview.Cursor := crVHeaderSplit;
      CaptureMouse;
    end
  end else
  begin
    OwnerListview.Cursor := crDefault;
    DoMouseMove(Msg, KeysToShiftState(Msg.Keys));  
  end;

  if (ehsCheckboxClickPending in State) then
  begin
    if Assigned(HotTrackCheckObj) then
    begin
      if OwnerListview.CheckManager.PendingObject <> HotTrackCheckObj then
      begin
        OwnerListview.CheckManager.PendingObject.CheckHovering := True;
        HotTrackCheckObj := nil
      end else
        OwnerListview.CheckManager.PendingObject.CheckHovering := False;
    end else
    begin
      OwnerListview.CheckManager.PendingObject.CheckHovering := True;
    end;
    if HotTrackCheckObj <> nil then
      HotTrackCheckObj := nil;
  end;

  if OwnerListview.CheckManager.PendingObject = HotTrackCheckObj then
    HotTrackCheckObj := nil;

  OwnerListview.HotTrack.PendingObjectCheck := HotTrackCheckObj;
end;

procedure TEasyHeader.WMRButtonDown(var Msg: TWMRButtonDown);
var
  ViewPt: TPoint;
begin
  ViewPt := SmallPointToPoint(Msg.Pos);
  Inc(ViewPt.X, OwnerListview.Scrollbars.OffsetX);

  Include(FState, ehsRButtonDown);
  DoMouseDown(Msg, cmbRight, KeysToShiftState(Msg.Keys), Columns.ColumnByPoint(ViewPt));
end;

procedure TEasyHeader.WMRButtonUp(var Msg: TWMRButtonUp);
var
  ViewPt: TPoint;
begin
  ViewPt := SmallPointToPoint(Msg.Pos);
  Inc(ViewPt.X, OwnerListview.Scrollbars.OffsetX);
  Exclude(FState, ehsRButtonDown);
  Exclude(FState, ehsResizing);
  Exclude(FState, ehsClickPending);
  Exclude(FState, ehsDragging);
  Exclude(FState, ehsDragPending);
  DoMouseUp(Msg, cmbRight, KeysToShiftState(Msg.Keys), Columns.ColumnByPoint(ViewPt));
end;

function TEasyViewItem.AllowDrag(Item: TEasyItem; ViewportPoint: TPoint): Boolean;
begin
  Result := True;
end;

function TEasyViewItem.EditAreaHitPt(Item: TEasyItem; ViewportPoint: TPoint): Boolean;
var
  RectArray: TEasyRectArrayObject;
begin
  Result := False;
  if Item.Enabled then
  begin
    ItemRectArray(Item, OwnerListview.Header.FirstColumn, Item.OwnerListview.ScratchCanvas, '', RectArray);
    Result := Windows.PtInRect(RectArray.TextRect, ViewportPoint);
  end
end;

function TEasyViewItem.ExpandIconR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect;
begin
  Result := RectArray.IconRect
end;

function TEasyViewItem.ExpandTextR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect;
begin
  if Item.Focused and OwnerListview.Focused then
    Result := RectArray.FullTextRect
  else
    Result := RectArray.TextRect;
end;

function TEasyViewItem.FullRowSelect: Boolean;
begin
  Result := False;
end;

function TEasyViewItem.GetImageList(Column: TEasyColumn; Item: TEasyItem): TImageList;
begin
  if Assigned(Column) then
    Result := Item.ImageList[Column.Index, PaintImageSize]
  else
    Result := Item.ImageList[0, PaintImageSize]
end;

function TEasyViewItem.OverlappedFocus: Boolean;
//
// Returns true if the view will overlap another cell when the object has the focus
begin
  Result := False
end;

function TEasyViewItem.PaintImageSize: TEasyImageSize;
begin
  Result := eisSmall
end;

function TEasyViewItem.SelectionHit(Item: TEasyItem; SelectViewportRect: TRect;
  SelectType: TEasySelectHitType): Boolean;
var
  R: TRect;
  RectArray: TEasyRectArrayObject;
begin
  Result := False;
  if Item.Enabled then
  begin
    ItemRectArray(Item, nil, OwnerListview.ScratchCanvas, '', RectArray);
    Result := IntersectRect(R, SelectViewportRect, ExpandTextR(Item, RectArray, SelectType)) or
              IntersectRect(R, SelectViewportRect, ExpandIconR(Item, RectArray, SelectType))
  end
end;

function TEasyViewItem.SelectionHitPt(Item: TEasyItem; ViewportPoint: TPoint;
  SelectType: TEasySelectHitType): Boolean;
var
  RectArray: TEasyRectArrayObject;
begin
  Result := False;
  if Item.Enabled then
  begin
    ItemRectArray(Item, nil, OwnerListview.ScratchCanvas, '', RectArray);
    Result := Windows.PtInRect(ExpandTextR(Item, RectArray, SelectType), ViewportPoint) or
              Windows.PtInRect(ExpandIconR(Item, RectArray, SelectType), ViewportPoint)
  end
end;

procedure TEasyViewItem.CalculateTextRect(Item: TEasyItem; Column: TEasyColumn;
  var TextR: TRect; ACanvas: TControlCanvas);
// Fits the Text in the PaintInfo.Caption.Text field into the TextR based
// on the values in the PaintInfo record.  If Canvas is nil then a temporary
// canvas is created to fit the text based on the Font in the PaintInfo
var
  DrawTextFlags: TCommonDrawTextWFlags;
  LocalCanvas: TControlCanvas;
begin
  case PaintTextAlignment(Item, Column) of
    taLeftJustify:  Include(DrawTextFlags, dtLeft);
    taRightJustify: Include(DrawTextFlags, dtRight);
    taCenter: Include(DrawTextFlags, dtCenter);
  end;

  case PaintTextVAlignment(Item, Column) of
    evaTop: Include(DrawTextFlags, dtTop);
    evaBottom: Include(DrawTextFlags, dtBottom);
    evaCenter: Include(DrawTextFlags, dtVCenter);
  end;

  if not Assigned(ACanvas) then
  begin
    LocalCanvas := TControlCanvas.Create;
    LocalCanvas.Control := OwnerListview
  end else
    LocalCanvas := ACanvas;

  try
    LoadTextFont(Item, 0, LocalCanvas, False);
    DrawTextFlags := DrawTextFlags + [dtCalcRectAdjR, dtCalcRect, dtCalcRectAlign];
    DrawTextWEx(LocalCanvas.Handle, Item.Captions[0], TextR, DrawTextFlags, 1);
  finally
    if not Assigned(ACanvas) then
      LocalCanvas.Free
  end;
end;

function TEasyViewItem.ItemRect(Item: TEasyItem; Column: TEasyColumn;
  RectType: TEasyCellRectType): TRect;
var
  RectArray: TEasyRectArrayObject;
begin
  Result := Rect(0, 0, 0, 0);
  // First look for cached rectangles during a drag
(*  CacheRectangle(Item, RectType, Result, cdrRetrieve); *)

  if IsRectEmpty(Result) then
  begin
    ItemRectArray(Item, Column, OwnerListview.ScratchCanvas, '', RectArray);
    case RectType of
      ertBounds: Result := RectArray.BoundsRect;
      ertIcon: Result := RectArray.IconRect;
      ertLabel: Result := RectArray.LabelRect;
      ertClickselectBounds: Result := RectArray.ClickselectBoundsRect;
      ertDragSelectBounds: Result := RectArray.DragSelectBoundsRect;
      ertText: Result := RectArray.TextRect;
      ertFullText: Result := RectArray.FullTextRect;
    end;
(*    CacheRectangle(Item, RectType, Result, cdrStore);  *)
  end;
end;

procedure TEasyViewItem.GetImageSize(Item: TEasyItem; Column: TEasyColumn; var ImageW, ImageH: Integer);
var
  Images: TImageList;
  ColumnPos: Integer;
  IsCustom: Boolean;
begin
  ImageW := 0;
  ImageH := 0;
  if Assigned(Column) then
    ColumnPos := Column.Index
  else
    ColumnPos := 0;
  if Item.ImageIndexes[ColumnPos] > -1 then
  begin
    Item.ImageDrawIsCustom(Column, IsCustom);
    if IsCustom then
      Item.ImageDrawGetSize(Column, ImageW, ImageH)
    else begin
      Images := GetImageList(Column, Item);  
      if  Assigned(Images) then
      begin
        ImageW := Images.Width;
        ImageH := Images.Height
      end
    end
  end
end;

procedure TEasyViewItem.ItemRectArray(Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas; const Caption: WideString; var RectArray: TEasyRectArrayObject);
//
// Grabs all the rectangles for the items within a cell in one call
//
begin
  Item.Initialized := True;

  FillChar(RectArray, SizeOf(RectArray), #0);

  RectArray.BoundsRect := Item.DisplayRect;
  InflateRect(RectArray.BoundsRect, -Item.Border, -Item.Border);

  RectArray.IconRect := RectArray.BoundsRect;
  RectArray.LabelRect := RectArray.BoundsRect;
  RectArray.ClickselectBoundsRect := RectArray.BoundsRect;
  RectArray.DragSelectBoundsRect := RectArray.BoundsRect;
  RectArray.TextRect := RectArray.BoundsRect;
  RectArray.SelectionRect := RectArray.BoundsRect;
  RectArray.FocusChangeInvalidRect := RectArray.BoundsRect;
  RectArray.EditRect := RectArray.FullTextRect;
  SetRect(RectArray.CheckRect, 0, 0, 0, 0);
end;

procedure TEasyViewItem.LoadTextFont(Item: TEasyItem; Position: Integer; ACanvas: TCanvas; Hilightable: Boolean);
begin
  ACanvas.Font.Assign(OwnerListview.Font);
  ACanvas.Brush.Style := bsClear;
  if not OwnerListview.ShowInactive then
  begin
    if Hilightable then
    begin
      if OwnerListview.Focused or Item.Hilighted then
        ACanvas.Font.Color := OwnerListview.Selection.TextColor
      else
        ACanvas.Font.Color := OwnerListview.Selection.InactiveTextColor
    end;
    if OwnerListview.HotTrack.Enabled and not Item.Hilighted then
    begin
      if (OwnerListview.HotTrack.FPendingObject = Item) and not Item.Selected then
      begin
        ACanvas.Font.Color := OwnerListview.HotTrack.Color;
        if OwnerListview.HotTrack.Underline then
          ACanvas.Font.Style := ACanvas.Font.Style + [fsUnderline]
      end
    end
  end else
    ACanvas.Font.Color := clGrayText;

  if Item.Bold then
    ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
  OwnerListview.DoItemPaintText(Item, Position, ACanvas);
end;

procedure TEasyViewItem.Paint(Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas; ViewportClipRect: TRect; ForceSelectionRectDraw: Boolean);
// The Canvas's DC offset has been shifted on entry so that the viewport coords
// of the item can be use direct within the method
var
  RectArray: TEasyRectArrayObject;
  Caption: WideString;
begin
  if Item.Visible then
  begin
    CanvasStore.StoreCanvasState(ACanvas);
    try
      if Assigned(Column) then
        Caption := Item.Captions[Column.Index]
      else
        Caption := Item.Caption;

      ItemRectArray(Item, Column, ACanvas, Caption, RectArray);

      // First allow decendents a crack at the painting
      PaintBefore(Item, Column, Caption, ACanvas, RectArray);

      // Paint the Selection Rectangle
      // *************************
      if not(OwnerListview.EditManager.Editing and (OwnerListview.EditManager.EditItem = Item)) then
        PaintSelectionRect(Item, Column, Caption, RectArray, ACanvas, ViewportClipRect, ForceSelectionRectDraw);

      // Next Paint the Icon or Bitmap Image
      // *************************
      PaintImage(Item, Column, Caption, RectArray, eisSmall, ACanvas);

      // Now lets paint the Text
      // *************************
      // If focused then show as many lines as necessary
      // Decendents should override PaintText to change the number of lines
      // as necessary
      if not(OwnerListview.EditManager.Editing and (OwnerListview.EditManager.EditItem = Item)) or ((OwnerListview.View = elsReport) and (Column <> OwnerListview.EditManager.EditColumn)) then
      begin
        PaintText(Item, Column, Caption, RectArray, ACanvas, PaintTextLineCount(Item, Column));

        // Now lets paint Focus Rectangle
        // *************************
        if OwnerListview.Selection.UseFocusRect then
          PaintFocusRect(Item, Column, Caption, RectArray, ACanvas);
      end;

      // Now Paint the Checkbox if applicable
      PaintCheckBox(Item, Column, RectArray, ACanvas);

      // Now give decentant a chance to paint anything
      PaintAfter(Item, Column, Caption, ACanvas, RectArray);
    finally
      CanvasStore.RestoreCanvasState(ACanvas)
    end
  end
end;

procedure TEasyViewItem.PaintAfter(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; ACanvas: TCanvas; RectArray: TEasyRectArrayObject);
begin
//
//  Called after all other drawing is done
//
end;

procedure TEasyViewItem.PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; ACanvas: TCanvas; RectArray: TEasyRectArrayObject);
//
//  Called before all other drawing is done
//
begin
  if Item.Border > 0 then
  begin
    ACanvas.Brush.Color := Item.BorderColor;
    ACanvas.FrameRect(RectArray.BoundsRect);
  end
end;

procedure TEasyViewItem.PaintCheckBox(Item: TEasyItem; Column: TEasyColumn;
  RectArray: TEasyRectArrayObject; ACanvas: TCanvas);
var
  PaintCheckBox: Boolean;
  AbsIndex: Integer;
begin
  PaintCheckBox := not ((Item.CheckType = ectNone) or (Item.CheckType = ettNoneWithSpace));

  if Assigned(Column) then
  begin
    AbsIndex := Column.Index;
    if AbsIndex > 0 then
      PaintCheckBox := False;
      // Future inhancement, checkboxes in columns
 //      PaintCheckBox := not ((Item.Details[ColumnIndex].CheckType = ectNone) or (Item.Details[ColumnIndex].CheckType = ettNoneWithSpace));
  end;

  if PaintCheckBox then
    PaintCheckboxCore(Item.CheckType,       // TEasyCheckType
                      OwnerListview,        // TCustomEasyListview
                      ACanvas,              // TCanvas
                      RectArray.CheckRect,  // TRect
                      Item.Enabled,         // IsEnabled
                      Item.Checked,         // IsChecked
                      OwnerListview.CheckManager.PendingObject = Item, // IsHot
                      Item.CheckFlat,       // IsFlat
                      Item.CheckHovering,   // IsHovering
                      Item.CheckPending,    // IsPending
                      Item,
                      Item.Checksize);

end;

procedure TEasyViewItem.PaintFocusRect(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; RectArray: TEasyRectArrayObject; ACanvas: TCanvas);
var
  AbsIndex: Integer;
  LocalFocusRect: TRect;
begin
  if not FullRowSelect then
  begin
    if Assigned(Column) then
      AbsIndex := Column.Index
    else
      AbsIndex := 0;

    // Only draw the focus rect if the window has focus
    if Item.Focused and OwnerListview.Focused and ((AbsIndex < 1)) then
    begin
      if OwnerListview.Selection.FullCellPaint then
      begin
        LocalFocusRect := Item.DisplayRect;
        UnionRect(LocalFocusRect, LocalFocusRect, RectArray.FullFocusSelRect);
        if (OwnerListview.View = elsReport) and (OwnerListview.Header.Columns.Count > 0) then
        begin
           LocalFocusRect.Left := OwnerListview.Header.Columns[0].DisplayRect.Left;
           LocalFocusRect.Right := LocalFocusRect.Left + OwnerListview.Header.Columns[0].Width;
        end
      end else
      begin
        LocalFocusRect := RectArray.FullFocusSelRect;
        if OwnerListview.Selection.FullItemPaint then
          UnionRect(LocalFocusRect, LocalFocusRect, RectArray.IconRect);
      end;
      ACanvas.Brush.Color := OwnerListview.Color;
      ACanvas.Font.Color := clBlack;
      DrawFocusRect(ACanvas.Handle, LocalFocusRect);
    end
  end
end;

procedure TEasyViewItem.PaintImage(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; RectArray: TEasyRectArrayObject; ImageSize: TEasyImageSize; ACanvas: TCanvas);
var
  rgbBk, rgbFg: Longword;
  fStyle: Integer;
  OverlayIndex, ImageIndex, PositionIndex, AbsIndex: Integer;
  Images: TImageList;
  DoDefault, IsCustom: Boolean;
  Rgn: HRgn;
begin
  TestAndClipImage(ACanvas, RectArray, Rgn);
  try
    if Assigned(Column) then
    begin
      AbsIndex := Column.Index;
      PositionIndex := Column.Position
    end else
    begin
      AbsIndex := 0;
      PositionIndex := 0;
    end;
    DoDefault := True;
    Images := GetImageList(Column, Item);
    if OwnerListview.IsThumbnailView then
    begin
      InflateRect(RectArray.IconRect, -Item.Border, -Item.Border);
      Item.ThumbnailDraw(ACanvas, RectArray.IconRect, AlphaBlender, DoDefault);
    end;

    // If not using the thumbnail then get the information for the ImageList Indexes
    if DoDefault then
    begin
      Item.ImageDrawIsCustom(Column, IsCustom);
      if IsCustom then
      begin
        Item.ImageDraw(Column, ACanvas, RectArray, AlphaBlender);
      end else
      if DoDefault then
      begin
        ImageIndex := Item.ImageIndexes[AbsIndex];
        OverlayIndex := Item.ImageOverlayIndexes[AbsIndex];

        if Assigned(Images) and (ImageIndex > -1) then
        begin
          // Set up a normal Imagelist icon
          fStyle := ILD_TRANSPARENT;
          rgbBk := CLR_NONE;
          rgbFg := CLR_NONE;

          // Set up to blend the Imagelist icon
          // The param is to allow Thumbnail view to use this paint method and not blend
          // the image
          if OwnerListview.Selection.BlendIcon and
            ((OwnerListview.Focused and Item.Selected) or Item.Hilighted and
            (PositionIndex < 1)) then
          begin
            fStyle := fStyle or ILD_SELECTED;
            if OwnerListview.Selection.ForceDefaultBlend then
              rgbFg := CLR_DEFAULT
            else
              rgbFg := ColorToRGB(OwnerListview.Selection.Color)
          end;

          if not Item.Enabled or Item.Cut or Item.OwnerListview.ShowInactive then
          begin
            fStyle := fStyle or ILD_SELECTED;
            rgbFg := ColorToRGB(OwnerListview.DisabledBlendColor)
          end;

          if OverlayIndex > -1 then
            fStyle := FStyle or IndexToOverLayMask(OverlayIndex);

          RectArray.IconRect.Left := RectArray.IconRect.Left + (RectWidth(RectArray.IconRect) - Images.Width) div 2;
          RectArray.IconRect.Top := RectArray.IconRect.Top + (RectHeight(RectArray.IconRect) - Images.Height) div 2;
          
          ImageList_DrawEx(Images.Handle, ImageIndex, ACanvas.Handle, RectArray.IconRect.Left,
            RectArray.IconRect.Top, 0, 0, rgbBk, rgbFg, fStyle);
        end
      end
    end
  finally
    TestAndUnClipImage(ACanvas, RectArray, Rgn);
  end
end;

procedure TEasyViewItem.PaintSelectionRect(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; RectArray: TEasyRectArrayObject; ACanvas: TCanvas; ViewportClipRect: TRect; ForceSelectionRectDraw: Boolean);
var
  Bits: TBitmap;
  Rgn: HRGN;
  // All these rectangles are necessary because the AlphaBlend routine does not respect DC origins and clipping regions.
  LocalSelRect,                    // The true Viewpoint Rectangle of the Selection Rectangle, including the Header area if applicable
  LocalSelWindowClippedRect,       // The true Viewpoint Rectangle of the Selection Rectangle, Clipped to the current Physical Window Coordinates
  LocalSelClippedRect,             // The true Viewpoint Rectangle of the Selection Rectangle, excluding the Header area if applicable
  HeaderClippedWindowRect: TRect;  // Rectangle containing the Selection Rectangle that has been translated to Physical Window Coordinates and the Header area clipped off it if necesasry.  This rectangle is also clipped to the ClientWindow rectangle
  AlphaColor: TColor;
  DoDraw: Boolean;
begin
  DoDraw := (Item.Selected and not Item.OwnerListview.ShowInactive) or Item.Hilighted;
  if DoDraw and Assigned(Column) then
    DoDraw := (Column.Index < 1);

  if (DoDraw and not FullRowSelect) or ForceSelectionRectDraw then
  begin
    Rgn := 0;
    // If the Window control is not focused show the selection with innactive colors
    if OwnerListview.Focused or Item.Hilighted then
    begin
      ACanvas.Font.Color := OwnerListview.Selection.TextColor;
      ACanvas.Pen.Color := OwnerListview.Selection.BorderColor;
      ACanvas.Brush.Color := OwnerListview.Selection.Color;
      AlphaColor := OwnerListview.Selection.Color;
    end else
    begin
      ACanvas.Font.Color := OwnerListview.Selection.InactiveTextColor;
      ACanvas.Pen.Color := OwnerListview.Selection.InactiveBorderColor;
      ACanvas.Brush.Color := OwnerListview.Selection.InactiveColor;
      AlphaColor := OwnerListview.Selection.InactiveColor;
    end;

    if OwnerListview.Selection.GroupSelections and (OwnerListview.View = elsReport) and (Item.Selected or Item.Hilighted or Item.Selected) then
    begin
      SetRect(LocalSelRect, 0, 0, 0, 0);
      if Assigned(Item.SelectionGroup) then
      begin
        if Item.Hilighted then
        begin
          LocalSelRect := Item.DisplayRect;
          if not ((OwnerListview.Selection.FullItemPaint) or (OwnerListview.Selection.FullCellPaint) or (OwnerListview.Selection.FullItemPaint)) then
            LocalSelRect.Left := RectArray.TextRect.Left
        end else
        begin
        if Item.SelectionGroup.FirstItem = Item then
          begin
            LocalSelRect := Item.SelectionGroup.DisplayRect;
            if not(OwnerListview.Selection.FullItemPaint or OwnerListview.Selection.FullCellPaint) then
                LocalSelRect.Left := RectArray.SelectionRect.Left
          end
        end
      end else
      begin
        LocalSelRect := Item.DisplayRect;
        if not(OwnerListview.Selection.FullItemPaint or OwnerListview.Selection.FullCellPaint) then
          LocalSelRect.Left := RectArray.SelectionRect.Left
      end
    end else
     // If full row select then the First Column paints the entire row
    if FullRowSelect and (Item.Selected or Item.Hilighted or Item.Selected) then
    begin
      if OwnerListview.Selection.FullCellPaint then
        LocalSelRect := Item.DisplayRect
      else begin
        LocalSelRect := Item.DisplayRect;
        if not OwnerListview.Selection.FullItemPaint then
          LocalSelRect.Left := RectArray.SelectionRect.Left;
      end;
      if Item.Focused and OwnerListview.Focused and OwnerListview.Selection.UseFocusRect then
        InflateRect(LocalSelRect, -1, -1);
    end else
    begin
      if Item.Focused and OwnerListview.Focused then
      begin
        if OwnerListview.Selection.FullCellPaint then
        begin
          LocalSelRect := Item.DisplayRect;
          UnionRect(LocalSelRect, LocalSelRect, RectArray.FullFocusSelRect);
           if (OwnerListview.View = elsReport) and (OwnerListview.Header.Columns.Count > 0) then
           begin
             LocalSelRect.Left := OwnerListview.Header.Columns[0].DisplayRect.Left;
             LocalSelRect.Right := LocalSelRect.Left + OwnerListview.Header.Columns[0].Width;
           end
        end else
        begin
          LocalSelRect := RectArray.FullFocusSelRect;
          // Cover the Icon if FullItemPaint
          if OwnerListview.Selection.FullItemPaint then
            UnionRect(LocalSelRect, LocalSelRect, RectArray.IconRect);
        end;
        if OwnerListview.Selection.UseFocusRect then
          InflateRect(LocalSelRect, -1, -1);
      end else
      begin
        if OwnerListview.Selection.FullCellPaint then
        begin
          LocalSelRect := Item.DisplayRect;
          if (OwnerListview.View = elsReport) and (OwnerListview.Header.Positions.Count > 0) then
          begin
            LocalSelRect.Left := OwnerListview.Header.Columns[0].DisplayRect.Left;
            LocalSelRect.Right := LocalSelRect.Left + OwnerListview.Header.Columns[0].Width;
           end
        end else
        begin
          LocalSelRect := RectArray.SelectionRect;
          // Cover the Icon if FullItemPaint
          if OwnerListview.Selection.FullItemPaint then
            UnionRect(LocalSelRect, LocalSelRect, RectArray.IconRect);
        end
      end
    end;

    // Clip out the header from the Selection Rectangle, don't need to account for Header
    // as the DC is offset to take it into account
    LocalSelClippedRect := LocalSelRect;
    HeaderClippedWindowRect := OwnerListview.Scrollbars.MapViewRectToWindowRect(LocalSelClippedRect);
    LocalSelWindowClippedRect := HeaderClippedWindowRect;
    if HeaderClippedWindowRect.Top < OwnerListview.Header.RuntimeHeight then
    begin
      HeaderClippedWindowRect.Top := OwnerListview.Header.RuntimeHeight;
      // Make it a 0 height rect if it is an improper rect after adjustment
      if HeaderClippedWindowRect.Top > HeaderClippedWindowRect.Bottom then
        HeaderClippedWindowRect.Top := HeaderClippedWindowRect.Bottom;
      LocalSelClippedRect := OwnerListview.Scrollbars.MapViewRectToWindowRect(HeaderClippedWindowRect);
    end;

    IntersectRect(LocalSelWindowClippedRect, LocalSelWindowClippedRect, OwnerListview.ClientRect);
    LocalSelWindowClippedRect := OwnerListview.Scrollbars.MapWindowRectToViewRect(LocalSelWindowClippedRect);
    IntersectRect(HeaderClippedWindowRect, HeaderClippedWindowRect, OwnerListview.ClientRect);

    // Stop right side from having rounded corners if extends past right edge of window,
    // but don't go past the actual width
    Inc(LocalSelWindowClippedRect.Right, OwnerListview.Selection.RoundRectRadius);
    if LocalSelWindowClippedRect.Right > LocalSelRect.Right then
      LocalSelWindowClippedRect.Right := LocalSelRect.Right;

    if not IsRectEmpty(LocalSelRect) then
    begin
      if HasMMX and OwnerListview.Selection.AlphaBlend then
      begin
        // If it is a round rectangle then we need to create a round region
        // to "clip" the square Alpha Blended memory bitmap to the round rectangle
        if OwnerListview.Selection.RoundRect then
        begin
          Bits := TBitmap.Create;
          try
            Bits.PixelFormat := pf32Bit;
            Bits.Width := RectWidth(LocalSelWindowClippedRect);
            Bits.Height := RectHeight(LocalSelWindowClippedRect);

            // Make a copy of the background image behind the square text rect
            BitBlt(Bits.Canvas.Handle, 0, 0, Bits.Width, Bits.Height, ACanvas.Handle,
              LocalSelWindowClippedRect.Left, LocalSelWindowClippedRect.Top, SRCCOPY);

            Bits.Canvas.Pen.Color := ACanvas.Pen.Color;
            // Draw the rectangle to it with a clear center
            Bits.Canvas.Brush.Style := bsClear;
              RoundRect(Bits.Canvas.Handle, 0, 0, Bits.Width, Bits.Height,
                OwnerListview.Selection.RoundRectRadius,
                OwnerListview.Selection.RoundRectRadius);

            // AlphaBlend the memory bitmap
            AlphaBlend(0, Bits.Canvas.Handle, Rect(0, 0, Bits.Width, Bits.Height), Point(0, 0),
              cbmConstantAlphaAndColor, OwnerListview.Selection.BlendAlphaTextRect,
              ColorToRGB(AlphaColor));

            LocalSelWindowClippedRect := OwnerListview.Scrollbars.MapViewRectToWindowRect(LocalSelWindowClippedRect);
            // Create a round rect region in the Canvas DC to blast the alpha
            // blended memory bitmap to.  The Alpha blending also blended the
            // corners where we do not need it so we must only copy the actual
            // round rect area to the Canvas
            Rgn := CreateRoundRectRgn(
              LocalSelWindowClippedRect.Left,
              LocalSelWindowClippedRect.Top,
              LocalSelWindowClippedRect.Right + 1,
              LocalSelWindowClippedRect.Bottom + 1,
              OwnerListview.Selection.RoundRectRadius,
              OwnerListview.Selection.RoundRectRadius);
            LocalSelWindowClippedRect := OwnerListview.Scrollbars.MapWindowRectToViewRect(LocalSelWindowClippedRect);

            // Select the new User round rect region to the DC
            SelectClipRgn(ACanvas.Handle, Rgn);
            OwnerListview.ClipHeader(ACanvas, False);
            BitBlt(ACanvas.Handle,
                   LocalSelWindowClippedRect.Left,
                   LocalSelWindowClippedRect.Top,
                   RectWidth(LocalSelWindowClippedRect),
                   RectHeight(LocalSelWindowClippedRect),
                   Bits.Canvas.Handle,
                   0,
                   0,
                   SRCCOPY);
            OwnerListview.ClipHeader(ACanvas, True);
          finally
            // Remove the User clipping region from the DC
            if Rgn <> 0 then
              DeleteObject(Rgn);
            Bits.Free;
          end
        end else
        begin
          // AlphaBlend does not clip and does not use the DC Origins, must be absolute to physical screen pixels
          AlphaBlend(0, ACanvas.Handle, HeaderClippedWindowRect, Point(0, 0),
            cbmConstantAlphaAndColor, OwnerListview.Selection.BlendAlphaTextRect, ColorToRGB(AlphaColor));
          ACanvas.Brush.Style := bsClear;
          Rectangle(ACanvas.Handle, LocalSelRect.Left, LocalSelRect.Top, LocalSelRect.Right, LocalSelRect.Bottom);
        end
      end else
      begin
        // Not AlphaBlended is much easier
        if OwnerListview.Selection.RoundRect then
          RoundRect(ACanvas.Handle,
                    LocalSelRect.Left,
                    LocalSelRect.Top,
                    LocalSelRect.Right,
                    LocalSelRect.Bottom,
                    OwnerListview.Selection.RoundRectRadius,
                    OwnerListview.Selection.RoundRectRadius)
        else
          Rectangle(ACanvas.Handle,
                    LocalSelRect.Left,
                    LocalSelRect.Top,
                    LocalSelRect.Right,
                    LocalSelRect.Bottom)
      end
    end
  end
end;

procedure TEasyViewItem.PaintText(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; RectArray: TEasyRectArrayObject; ACanvas: TCanvas; LinesToDraw: Integer);
var
  DrawTextFlags: TCommonDrawTextWFlags;
  AbsIndex: Integer;
  Hilightable: Boolean;
begin
  if not IsRectEmpty(RectArray.TextRect) then
  begin
    if Assigned(Column) then
      AbsIndex := Column.Index
    else
      AbsIndex := 0;

    Hilightable := (Item.Selected or Item.Hilighted) and ((AbsIndex = 0) or (FullRowSelect or OwnerListview.Selection.GroupSelections));
    LoadTextFont(Item, AbsIndex, ACanvas, Hilightable);

    DrawTextFlags := [dtEndEllipsis];

    if LinesToDraw = 1 then
      Include(DrawTextFlags, dtSingleLine);

    case PaintTextAlignment(Item, Column) of
      taLeftJustify: Include(DrawTextFlags, dtLeft);
      taRightJustify: Include(DrawTextFlags, dtRight);
      taCenter:  Include(DrawTextFlags, dtCenter);
    end;

    case PaintTextVAlignment(Item, Column) of
      evaTop: Include(DrawTextFlags, dtTop);
      evaCenter: Include(DrawTextFlags, dtVCenter);
      evaBottom:  Include(DrawTextFlags, dtBottom);
    end;

    if Item.Focused and OwnerListview.Focused then
      DrawTextWEx(ACanvas.Handle, Caption, RectArray.TextRect, DrawTextFlags, LinesToDraw)
    else
      DrawTextWEx(ACanvas.Handle, Caption, RectArray.TextRect, DrawTextFlags, LinesToDraw)
  end
end;

function TEasyViewItem.PaintTextAlignment(Item: TEasyItem; Column: TEasyColumn): TAlignment;
begin
  Result := taCenter
end;

function TEasyViewItem.PaintTextLineCount(Item: TEasyItem; Column: TEasyColumn): Integer;
begin
  Result := 2
end;

function TEasyViewItem.PaintTextVAlignment(Item: TEasyItem; Column: TEasyColumn): TEasyVAlignment;
begin
  Result := evaTop
end;

function TEasyViewItem.PtInRect(Item: TEasyItem; Column: TEasyColumn;
  Pt: TPoint): Integer;
// Compares the passed point with the rectangle of the item.
//
//  If Rect > Pt then Result = 1
//  If Rect < Pt then Result = -1
//  If Rect = Pt (i.e. the point is within the rect) then Result = 0
//
// This code works if the layout of the items is vertical with item numbering
// increasing from Left to Right in each Row
var
  CellRect: TRect;
begin
  CellRect := Item.DisplayRect;
  if Pt.y < CellRect.Top then
    Result := 1
  else
  if Pt.y > CellRect.Bottom then
    Result := -1
  else
  if Pt.x < CellRect.Left then
  begin
    Result := 1
  end
  else
  if Pt.x > CellRect.Right then
    Result := -1
  else
    Result := 0
end;

procedure TEasyViewItem.ReSizeRectArray(
  var RectArray: TEasyRectArrayObjectArray);
var
  OldLen, i: Integer;
begin
  if Length(RectArray) < OwnerListview.Header.Positions.Count then
  begin
    OldLen := Length(RectArray);
    SetLength(RectArray, OwnerListview.Header.Positions.Count);
    for i := OldLen to OwnerListview.Header.Positions.Count - 1 do
      FillChar(RectArray[i], SizeOf(RectArray[i]), #0);
  end else
  if Length(RectArray) > OwnerListview.Header.Positions.Count then
    SetLength(RectArray, OwnerListview.Header.Positions.Count);

  if Length(RectArray) = 0 then
  begin
    SetLength(RectArray, 1);
    FillChar(RectArray[0], SizeOf(RectArray[0]), #0);
  end
end;

procedure TEasyViewItem.TestAndClipImage(ACanvas: TCanvas; RectArray: TEasyRectArrayObject; var Rgn: HRgn);
var
  R: TRect;
begin
  Rgn := 0;
  if not ContainsRect(RectArray.BoundsRect, RectArray.IconRect)  then
  begin
    GetClipRgn(ACanvas.Handle, Rgn);
    IntersectRect(R, RectArray.IconRect, RectArray.BoundsRect);
    IntersectClipRect(ACanvas.Handle, R.Left, R.Top, R.Right, R.Bottom);
  end;
end;

procedure TEasyViewItem.TestAndUnClipImage(ACanvas: TCanvas; RectArray: TEasyRectArrayObject; Rgn: HRgn);
begin
  if not ContainsRect(RectArray.BoundsRect, RectArray.IconRect)  then
  begin
    if Rgn <> 0 then
    begin
      SelectClipRgn(ACanvas.Handle, Rgn);
      DeleteObject(Rgn)
    end
    else
      SelectClipRgn(ACanvas.Handle, 0)
  end;
end;

function TEasyHeader.GetViewWidth: Integer;
begin
  if Positions.Count > 0 then
    Result := Positions[Positions.Count - 1].DisplayRect.Right
  else
    Result := 0
end;

{ TEasyDefaultCellSize }

constructor TEasyCellSize.Create(AnOwner: TCustomEasyListview);
begin
  inherited Create(AnOwner);
  FWidth := 75;
  FHeight := 75;
end;

function TEasyCellSize.GetHeight: Integer;
begin
  Result := FHeight;
  if Result < 1 then
    Result := 1
end;

function TEasyCellSize.GetWidth: Integer;
begin
  Result := FWidth;
  if Result < 1 then
    Result := 1
end;

procedure TEasyCellSize.Assign(Source: TPersistent);
begin
  if Source is TEasyCellSize then
  begin
    FHeight := TEasyCellSize(Source).Height;
    FWidth := TEasyCellSize(Source).Width;
    OwnerListview.Groups.Rebuild;
  end;
end;

procedure TEasyCellSize.SetSize(AWidth, AHeight: Integer);
begin
  if AWidth < 0 then AWidth := 0;
  if AHeight < 0 then AHeight := 0;

  if (AWidth <> FWidth) or (AHeight <> FHeight) then
  begin
    FWidth := AWidth;
    FHeight := AHeight;
    OwnerListview.Groups.Rebuild;
  end;
end;

procedure TEasyCellSize.SetHeight(Value: Integer);
begin
  SetSize(FWidth, Value);
end;

procedure TEasyCellSize.SetWidth(Value: Integer);
begin
  SetSize(Value, FHeight);
end;

{ TEasyIconItemView}

function TEasyViewIconItem.ExpandIconR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect;
begin
  Result.Left := RectArray.BoundsRect.Left + 2;
  Result.Right := RectArray.BoundsRect.Right - 2;
  Result.Top := RectArray.IconRect.Top;
  Result.Bottom := RectArray.IconRect.Bottom + 4
end;

function TEasyViewIconItem.OverlappedFocus: Boolean;
begin
  Result:= True
end;

function TEasyViewIconItem.PaintImageSize: TEasyImageSize;
begin
  Result := eisLarge
end;

function TEasyViewIconItem.PaintTextLineCount(Item: TEasyItem;
  Column: TEasyColumn): Integer;
begin
  if Item.Focused and OwnerListview.Focused then
    Result := -1
  else
    Result := 2
end;

procedure TEasyViewIconItem.ItemRectArray(Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas; const Caption: WideString; var RectArray: TEasyRectArrayObject);
var
  ImageW, ImageH, Left: Integer;
  DrawTextFlags: TCommonDrawTextWFlags;
  R: TRect;
  PositionIndex, AbsIndex: Integer;
  ACaption: WideString;
begin
  if Assigned(Item) then
  begin
    if not Item.Initialized then
      Item.Initialized := True;

    if Assigned(Column) then
    begin
      AbsIndex := Column.Index;
      PositionIndex := Column.Position
    end else
    begin
      AbsIndex := 0;
      PositionIndex := 0
    end;

    if PositionIndex > -1 then
    begin
      FillChar(RectArray, SizeOf(RectArray), #0);

      GetImageSize(Item, Column, ImageW, ImageH);

      // Calcuate the Bounds of the Cell that is allowed to be drawn in
      // **********
      RectArray.BoundsRect := Item.DisplayRect;
      Inc(RectArray.BoundsRect.Left);

      // Calculate where the Icon is positioned
      // **********
      // Center Icon horziontally and a few pixels from the top of the cell
      Left := RectArray.BoundsRect.Left + ((RectWidth(RectArray.BoundsRect) - ImageW) div 2);

      RectArray.IconRect := Rect(Left,
                              RectArray.BoundsRect.Top + 2,
                              Left + ImageW,
                              RectArray.BoundsRect.Top + 2 + ImageH);

      // Some margin between the Icon and the Text that belongs to the Icon Rect
      Inc(RectArray.IconRect.Bottom, 4);


      // Calculate area that the Checkbox may be drawn
      // **********
      if Item.CheckType <> ectNone then
      begin
        R := Checks.Bound[Item.Checksize];
        RectArray.CheckRect.Top := RectArray.IconRect.Bottom + 1;  // This looks better than centered
        RectArray.CheckRect.Left := RectArray.BoundsRect.Left + Item.CheckIndent;
        RectArray.CheckRect.Bottom := RectArray.CheckRect.Top + R.Bottom;
        RectArray.CheckRect.Right := RectArray.CheckRect.Left + R.Right;
      end else
      begin
        RectArray.CheckRect.Top := RectArray.IconRect.Bottom;
        RectArray.CheckRect.Left := RectArray.BoundsRect.Left;
        RectArray.CheckRect.Bottom := RectArray.BoundsRect.Bottom;
        RectArray.CheckRect.Right := RectArray.BoundsRect.Left;
      end;

      // Calculate area that the label may be drawn
      // **********

      // The Label Rect is the remaining area between the Icon Rect and the Bottom
      // of the Bounds Rect
      RectArray.LabelRect := Rect(RectArray.CheckRect.Right,
                               RectArray.IconRect.Bottom + 1,
                               RectArray.BoundsRect.Right,
                               RectArray.BoundsRect.Bottom);


      // Calculate the portion of the Label Rect that the current Text will use
      // **********
      RectArray.TextRect := RectArray.LabelRect;
      RectArray.FullTextRect := RectArray.LabelRect;
      // Leave room for a small border between edge of the selection rect and text
      InflateRect(RectArray.TextRect, -2, -2);
      InflateRect(RectArray.FullTextRect, -2, -2);

      DrawTextFlags := [dtCalcRect, dtCalcRectAlign];

      DrawTextFlags := DrawTextFlags + [dtCenter];

      case PaintTextAlignment(Item, Column) of
        taCenter: DrawTextFlags := DrawTextFlags + [dtCenter];
        taLeftJustify: DrawTextFlags := DrawTextFlags + [dtLeft];
        taRightJustify: DrawTextFlags := DrawTextFlags + [dtRight];
      end;

      case PaintTextVAlignment(Item, Column) of
        evaCenter: DrawTextFlags := DrawTextFlags + [dtVCenter];
        evaTop: DrawTextFlags := DrawTextFlags + [dtTop];
        evaBottom: DrawTextFlags := DrawTextFlags + [dtBottom];
      end;

      if Assigned(OwnerListview.ScratchCanvas) then
      begin
        ACaption := Item.Captions[AbsIndex];
        if ACaption = '' then
          ACaption := ' ';
        LoadTextFont(Item, PositionIndex, OwnerListview.ScratchCanvas, Item.Selected);
        DrawTextWEx(OwnerListview.ScratchCanvas.Handle, ACaption, RectArray.FullTextRect, DrawTextFlags, -1);
        DrawTextWEx(OwnerListview.ScratchCanvas.Handle, ACaption, RectArray.TextRect, DrawTextFlags, 2);
      end;

      // Calculate Selection rectangle paint box
      // **********
      RectArray.SelectionRect := RectArray.TextRect;
      InflateRect(RectArray.SelectionRect, 2, 2);
      RectArray.FullFocusSelRect := RectArray.FullTextRect;
      InflateRect(RectArray.FullFocusSelRect, 2, 2);

      UnionRect(RectArray.ClickselectBoundsRect, RectArray.IconRect, RectArray.TextRect);
      RectArray.DragSelectBoundsRect := RectArray.ClickselectBoundsRect;
      UnionRect(RectArray.FocusChangeInvalidRect, RectArray.IconRect, RectArray.FullFocusSelRect);

      RectArray.EditRect := RectArray.FullTextRect;
    end
  end
end;

procedure TEasyViewIconItem.PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; ACanvas: TCanvas; RectArray: TEasyRectArrayObject);
begin
 // Skip inherited
end;

{ TEasySmallIconItemView }

function TEasyViewSmallIconItem.CalculateDisplayRect(Item: TEasyItem;
  Column: TEasyColumn): TRect;
begin
  Result := Item.DisplayRect
end;

function TEasyViewSmallIconItem.ExpandIconR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect;
begin
  Result := Rect(0, 0, 0, 0)
end;

function TEasyViewSmallIconItem.ExpandTextR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect;
begin
  UnionRect(Result, RectArray.IconRect, RectArray.TextRect);
  Result.Top := RectArray.BoundsRect.Top;
  Result.Bottom := RectArray.BoundsRect.Bottom;
end;

procedure TEasyViewSmallIconItem.ItemRectArray(Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas; const Caption: WideString; var RectArray: TEasyRectArrayObject);
var
  TextSize: TSize;
  SelectW, BoundsH, CheckH: Integer;
  CheckType: TEasyCheckType;
  R: TRect;
  CheckIndent, CaptionIndent, Checksize, ImageIndex, ImageIndent, PositionIndex, AbsIndex: Integer;
  ImageW, ImageH: Integer;
  ACaption: WideString;
begin
  if Assigned(Item) then
  begin
    // This is faster
    if not Item.Initialized then
      Item.Initialized := True;
    if Assigned(Column) then
    begin
      AbsIndex := Column.Index;
      PositionIndex := Column.Position
    end else
    begin
      AbsIndex := 0;
      PositionIndex := 0
    end;

    if PositionIndex > -1 then
    begin
      FillChar(RectArray, SizeOf(RectArray), #0);

      // Calcuate the Bounds of the Cell that is allowed to be drawn in
      // **********
      // Report view is based on this class so take care if that possibility too.

      GetImageSize(Item, Column, ImageW, ImageH);

      if not Assigned(Column) and (OwnerListview.Header.Positions.Count > 0) then
        RectArray.BoundsRect := CalculateDisplayRect(Item, OwnerListview.Header.Positions[0])
      else
        RectArray.BoundsRect := CalculateDisplayRect(Item, Column);
        
      CheckType := Item.CheckType;
      Checksize := Item.Checksize;
      ImageIndex := Item.ImageIndexes[AbsIndex];
      CaptionIndent := Item.CaptionIndent;
      CheckIndent := Item.CheckIndent;
      ImageIndent := Item.ImageIndent;

      // Calculate the space necded for the CheckBox, if enabled
      if (CheckType <> ectNone) and (AbsIndex = 0) then
      begin
        R := Checks.Bound[Checksize];
        BoundsH := RectHeight(RectArray.BoundsRect);
        CheckH := RectHeight(R);
        RectArray.CheckRect := Rect(RectArray.BoundsRect.Left + CheckIndent,
                                    RectArray.BoundsRect.Top + (BoundsH - CheckH) div 2,
                                    RectArray.BoundsRect.Left + CheckIndent + R.Right,
                                    RectArray.BoundsRect.Top + CheckH + (BoundsH - CheckH) div 2)
      end else
        RectArray.CheckRect := Rect(RectArray.BoundsRect.Left,
                                    RectArray.BoundsRect.Top,
                                    RectArray.BoundsRect.Left,
                                    RectArray.BoundsRect.Bottom); // Check Rect has a width of 0

      // Set the rectangle of the Image if avaialable, note Bitmap is not supported
      if (ImageIndex > -1) then
      begin
        RectArray.IconRect.Top := RectArray.BoundsRect.Top + (RectHeight(RectArray.BoundsRect) - ImageH) div 2;
        RectArray.IconRect.Left := RectArray.CheckRect.Right + ImageIndent;
        RectArray.IconRect.Bottom := RectArray.IconRect.Top + ImageH;
        RectArray.IconRect.Right := RectArray.IconRect.Left + ImageW;
      end else
        RectArray.IconRect := Rect(RectArray.CheckRect.Right,
                                RectArray.CheckRect.Top,
                                RectArray.CheckRect.Right,
                                RectArray.CheckRect.Bottom);

      // Calculate where the Label is positioned
      // **********
      // The Cell may be narrow enough that only the image will fit. If that is
      // the case leave the LabelR a Zero sized rect
      if RectArray.BoundsRect.Right - 1 > RectArray.IconRect.Right + CaptionIndent {+ (2*LABEL_MARGIN) }then
        RectArray.LabelRect := Rect(RectArray.IconRect.Right + CaptionIndent {+ LABEL_MARGIN},
                                 RectArray.BoundsRect.Top,
                                 RectArray.BoundsRect.Right {- 2*LABEL_MARGIN},
                                 RectArray.BoundsRect.Bottom);

      // Calculate Text based rectangles
      // **********
      if Assigned(OwnerListview.ScratchCanvas) then
      begin
        LoadTextFont(Item, PositionIndex, OwnerListview.ScratchCanvas, Item.Selected);
        ACaption := Item.Captions[AbsIndex];
        if ACaption = '' then
          ACaption := ' ';
        TextSize := TextExtentW(ACaption, OwnerListview.ScratchCanvas);
      end else
      begin
       TextSize.cx := 0;
       TextSize.cy := 0
      end;

      // Calculate Text Rectangle
      // **********
      RectArray.TextRect := RectArray.LabelRect;
      InflateRect(RectArray.TextRect, -2, -2);

      // Center it horz and vert to start with
      // This will also clip the text rect to to size of the Label if necessary
      RectArray.TextRect := CenterRectInRect(RectArray.TextRect, Rect(0, 0, TextSize.cx, TextSize.cy));

      case PaintTextAlignment(Item, Column) of
        taLeftJustify:  OffsetRect(RectArray.TextRect, -(RectArray.TextRect.Left - RectArray.LabelRect.Left){ + LABEL_MARGIN}, 0);
        taRightJustify: OffsetRect(RectArray.TextRect, (RectArray.LabelRect.Right - RectArray.TextRect.Right){ - LABEL_MARGIN}, 0);
      end;

      // Calculate Focus Text Rectangle
      // **********
      RectArray.FullTextRect := RectArray.TextRect;

      // Calculate Selection Rectangle
      // **********
      RectArray.SelectionRect := RectArray.TextRect;
      InflateRect(RectArray.SelectionRect, 2, 2);
      RectArray.FullFocusSelRect := RectArray.SelectionRect;

      // Calculate Rectangle used for Clickselecting
      // **********
      UnionRect(RectArray.ClickselectBoundsRect, RectArray.IconRect, RectArray.SelectionRect);

      // Calculate Rectangle used for DragSelecting
      // **********
      // During a drag selection the hit area is only a fraction of the Click bounds
      RectArray.DragSelectBoundsRect := RectArray.ClickselectBoundsRect;
      SelectW := Round(RectWidth(RectArray.DragSelectBoundsRect) * SELECTION_OFFSET);
      InflateRect(RectArray.DragSelectBoundsRect, -SelectW, 0);

      UnionRect(RectArray.FocusChangeInvalidRect, RectArray.IconRect, RectArray.FullTextRect);

      RectArray.EditRect := RectArray.FullTextRect;
    end
  end
end;

procedure TEasyViewSmallIconItem.PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; ACanvas: TCanvas; RectArray: TEasyRectArrayObject);
begin
  // Don't do default
end;

function TEasyViewSmallIconItem.PaintTextAlignment(Item: TEasyItem; Column: TEasyColumn): TAlignment;
begin
  if Assigned(Column) then
    Result := Column.Alignment
  else
    Result := taLeftJustify
end;

function TEasyViewSmallIconItem.PaintTextLineCount(Item: TEasyItem; Column: TEasyColumn): Integer;
begin
  Result := 1
end;

function TEasyViewSmallIconItem.PaintTextVAlignment(Item: TEasyItem; Column: TEasyColumn): TEasyVAlignment;
begin
  if Assigned(Column) then
    Result := Column.VAlignment
  else
    Result := evaCenter
end;

{ TEasyDefaultCellSizes }

constructor TEasyCellSizes.Create(AnOwner: TCustomEasyListview);
begin
  inherited Create(AnOwner);
  FIcon := TEasyCellSizeIcon.Create(AnOwner);
  FSmallIcon := TEasyCellSizeSmallIcon.Create(AnOwner);
  FThumbnail := TEasyCellSizeThumbnail.Create(AnOwner);
  FTile := TEasyCellSizeTile.Create(AnOwner);
  FList := TEasyCellSizeList.Create(AnOwner);
  FReport := TEasyCellSizeReport.Create(AnOwner);
  FFilmStrip := TEasyCellSizeFilmStrip.Create(AnOwner);
  FGrid := TEasyCellGrid.Create(AnOwner);
end;

destructor TEasyCellSizes.Destroy;
begin
  FreeAndNil(FIcon);
  FreeAndNil(FSmallIcon);
  FreeAndNil(FThumbnail);
  FreeAndNil(FTile);
  FreeAndNil(FList);
  FreeAndNil(FReport);
  FreeAndNil(FFilmStrip);
  FreeAndNil(FGrid);
  inherited Destroy;
end;

{ TEasyDefaultSmallIconCellSize }

constructor TEasyCellSizeSmallIcon.Create(
  AnOwner: TCustomEasyListview);
begin
  inherited Create(AnOwner);
  FWidth := 200;
  FHeight := 17
end;

{ TEasyDefaultThumbnailCellSize }

constructor TEasyCellSizeThumbnail.Create(
  AnOwner: TCustomEasyListview);
begin
  inherited Create(AnOwner);
  FWidth := 125;
  FHeight := 143
end;

{ TEasyDefaultTileCellSize }

constructor TEasyCellSizeTile.Create(
  AnOwner: TCustomEasyListview);
begin
  inherited Create(AnOwner);
  FWidth := 218;
  FHeight := 58
end;

{ TEasyDefaultListCellSize }

constructor TEasyCellSizeList.Create(
  AnOwner: TCustomEasyListview);
begin
  inherited Create(AnOwner);
  FWidth := 200;
  FHeight := 17
end;

{ TEasyDefaultReportCellSize }

constructor TEasyCellSizeReport.Create(
  AnOwner: TCustomEasyListview);
begin
  inherited Create(AnOwner);
  FWidth := 75;
  FHeight := 17
end;

function TEasyViewTileItem.ExpandIconR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect;
begin
  Result := Rect(0, 0, 0, 0)
end;

function TEasyViewTileItem.ExpandTextR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect;
begin
  UnionRect(Result, RectArray.IconRect, RectArray.TextRect);
  Result.Top := RectArray.BoundsRect.Top + 2;
  Result.Bottom := RectArray.BoundsRect.Bottom - 2;
end;

function TEasyViewTileItem.GetImageList(Column: TEasyColumn; Item: TEasyItem): TImageList;
begin
  Result := inherited GetImageList(Column, Item);
  if not Assigned(Result) then
  begin
    if Assigned(Column) then
      Result := Item.ImageList[Column.Index, eisLarge]
    else
      Result := Item.ImageList[0, eisLarge]
  end
end;

function TEasyViewTileItem.PaintImageSize: TEasyImageSize;
begin
  Result := eisExtraLarge
end;

function TEasyViewTileItem.PaintTextAlignment(Item: TEasyItem;
  Column: TEasyColumn): TAlignment;
begin
  Result := taLeftJustify
end;

procedure TEasyViewTileItem.ItemRectArray(Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas; const Caption: WideString; var RectArray: TEasyRectArrayObject);
var
  ACaption: WideString;
  PositionIndex, i, YOffset, ImageW, ImageH, DetailCount: Integer;
  DrawTextFlags: TCommonDrawTextWFlags;
  R: TRect;
  Done: Boolean;
begin
  if Assigned(Item) then
  begin
    if not Item.Initialized then
      Item.Initialized := True;

    if Assigned(Column) then
      PositionIndex := Column.Position
    else
      PositionIndex := 0;

    if PositionIndex > -1 then
    begin
      FillChar(RectArray, SizeOf(RectArray), #0);

      GetImageSize(Item, Column, ImageW, ImageH);

      // Get the cell size for the main caption, aligned with the top
      case PaintTextAlignment(Item, Column) of
        taLeftJustify: Include(DrawTextFlags, dtLeft);
        taRightJustify: Include(DrawTextFlags, dtRight);
        taCenter:  Include(DrawTextFlags, dtCenter);
      end;
      DrawTextFlags := [dtCalcRect, dtCalcRectAlign, dtEndEllipsis, dtTop];

      // Calcuate the Bounds of the Cell that is allowed to be drawn in
      // **********
      RectArray.BoundsRect := Item.DisplayRect;
      InflateRect(RectArray.BoundsRect, -Item.Border, -Item.Border);

      // Calculate where the Checkbox is positioned
      // **********
      if Item.CheckType <> ectNone then
      begin
        R := Checks.Bound[Item.Checksize];
        RectArray.CheckRect.Left := RectArray.BoundsRect.Left + Item.CheckIndent;
        RectArray.CheckRect.Top := RectArray.BoundsRect.Top + (RectHeight(RectArray.BoundsRect) - R.Bottom) div 2;
        RectArray.CheckRect.Right := RectArray.CheckRect.Left + R.Right;
        RectArray.CheckRect.Bottom := RectArray.CheckRect.Top + R.Bottom;
      end else
        SetRect(RectArray.CheckRect, RectArray.BoundsRect.Left,
                                     RectArray.BoundsRect.Top,
                                     RectArray.BoundsRect.Left,
                                     RectArray.BoundsRect.Bottom);

      // Calculate where the Icon is positioned
      // **********
      RectArray.IconRect := Rect(RectArray.CheckRect.Right + Item.ImageIndent,
                              RectArray.BoundsRect.Top,
                              RectArray.CheckRect.Right + Item.ImageIndent + ImageW + 4,
                              RectArray.BoundsRect.Bottom);

      // Calculate where the Label Rect is positioned
      // **********
      RectArray.LabelRect := RectArray.BoundsRect;
      RectArray.LabelRect.Left := RectArray.IconRect.Right + Item.CaptionIndent;
      InflateRect(RectArray.LabelRect, -2, 0);

      // Calculate the Text Rectangles
      // **********

      RectArray.TextRect := RectArray.LabelRect;
      // Leave border for the Selection Painted rectangle around text
      InflateRect(RectArray.TextRect, -2, -2);

      DetailCount := Item.DetailCount;

      // Assume that there is enough room for all the Captions to be show that the user desired
      SetLength(RectArray.TextRects, DetailCount);

      for i := 0 to Length(RectArray.TextRects) - 1 do
        RectArray.TextRects[i] := Rect(0, 0, 0, 0);

      if Length(RectArray.TextRects) > 0 then
      begin
        // Lets work on the Main Caption, it gets the full LabelR to use
        RectArray.TextRects[0] := RectArray.LabelRect;
        // TextRects[0] is the main caption that can fill more then one line if necessary
        // if it does then details are omitted as necded
        ACaption := Item.Captions[Item.Details[0]];
        // Make the first line contain something
        if ACaption = '' then
          ACaption := ' ';
        if Assigned(OwnerListview.ScratchCanvas) then
        begin
          LoadTextFont(Item, PositionIndex, OwnerListview.ScratchCanvas, Item.Selected);
          DrawTextWEx(OwnerListview.ScratchCanvas.Handle, ACaption, RectArray.TextRects[0], DrawTextFlags, PaintTextLineCount(Item, Column));
        end;
        if RectArray.TextRects[0].Bottom > RectArray.LabelRect.Bottom then
          RectArray.TextRects[0] := Rect(0, 0, 0, 0)
        else begin
          // Only fill in as many detail lines that fit based on if the caption
          // necded two lines or not
          Done := False;
          i := 1;
          while not Done and (i < Length(RectArray.TextRects)) do
          begin
            if RectArray.TextRects[i - 1].Bottom < RectArray.LabelRect.Bottom then
            begin
              ACaption := Item.Captions[Item.Details[i]];
              RectArray.TextRects[i] := RectArray.LabelRect;
              RectArray.TextRects[i].Top := RectArray.TextRects[i - 1].Bottom;
              if Assigned(OwnerListview.ScratchCanvas) then
              begin
                LoadTextFont(Item, i, OwnerListview.ScratchCanvas, Item.Selected);
                // Details only get one line
                DrawTextWEx(OwnerListview.ScratchCanvas.Handle, ACaption, RectArray.TextRects[i], DrawTextFlags, 1);
              end;
              if RectArray.TextRects[i].Bottom > RectArray.LabelRect.Bottom then
              begin
                RectArray.TextRects[i] := Rect(0, 0, 0, 0);
                Done := True
              end else
                Inc(i)
            end else
            begin
              RectArray.TextRects[i] := Rect(0, 0, 0, 0);
              Done := True;
            end
          end;
        end;

        RectArray.TextRect := Rect(0, 0, 0, 0);

        Done := False;
        i := 0;
        while not Done and (i < Length(RectArray.TextRects)) do
        begin
          if not IsRectEmpty(RectArray.TextRects[i]) then
          begin
            UnionRect(RectArray.TextRect, RectArray.TextRect, RectArray.TextRects[i]);
            Inc(i)
          end else
            Done := True
        end;
        if Done then
          SetLength(RectArray.TextRects, i);

        YOffset := 0;
        if Item.VAlignment = evaCenter then
          YOffset := (RectHeight(RectArray.LabelRect)-RectHeight(RectArray.TextRect)) div 2
        else
        if Item.VAlignment = evaBottom then
          YOffset := RectArray.LabelRect.Bottom - RectHeight(RectArray.TextRect);

        for i := 0 to Length(RectArray.TextRects) - 1 do
        begin
          if Item.VAlignment = evaCenter then
            OffsetRect(RectArray.TextRects[i], 0, YOffset)
          else
          if Item.VAlignment = evaBottom then
            OffsetRect(RectArray.TextRects[i], 0, YOffset);
        end;

        if Item.VAlignment = evaCenter then
          OffsetRect(RectArray.TextRect, 0, YOffset)
        else
        if Item.VAlignment = evaBottom then
          OffsetRect(RectArray.TextRect, 0, YOffset);
      end;


      RectArray.FullTextRect := RectArray.TextRect;
      RectArray.SelectionRect := RectArray.TextRect;
      InflateRect(RectArray.SelectionRect, 2, 2);
      RectArray.FullFocusSelRect := RectArray.SelectionRect;

      RectArray.ClickselectBoundsRect := RectArray.IconRect;
      RectArray.ClickselectBoundsRect.Right := RectArray.TextRect.Right;

      RectArray.DragSelectBoundsRect := RectArray.TextRect;
      RectArray.DragSelectBoundsRect.Right := RectArray.DragSelectBoundsRect.Right - Round(RectWidth(RectArray.DragSelectBoundsRect)*0.20);

      UnionRect(RectArray.FocusChangeInvalidRect, RectArray.IconRect, RectArray.FullTextRect);

      RectArray.EditRect := RectArray.FullTextRect;
    end
  end
end;


procedure TEasyViewTileItem.PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; ACanvas: TCanvas; RectArray: TEasyRectArrayObject);
begin

end;

procedure TEasyViewTileItem.PaintText(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; RectArray: TEasyRectArrayObject; ACanvas: TCanvas; LinesToDraw: Integer);
//
//  Need to handle this paint directly
//
var
  DrawTextFlags: TCommonDrawTextWFlags;
  i: Integer;
begin
  DrawTextFlags := [dtEndEllipsis, dtTop];

  case PaintTextAlignment(Item, Column) of
    taLeftJustify: Include(DrawTextFlags, dtLeft);
    taRightJustify: Include(DrawTextFlags, dtRight);
    taCenter:  Include(DrawTextFlags, dtCenter);
  end;

  if Length(RectArray.TextRects) > 0 then
  begin
    LoadTextFont(Item, 0, ACanvas, Item.Selected);
    DrawTextWEx(ACanvas.Handle, Item.Captions[Item.Details[0]], RectArray.TextRects[0], DrawTextFlags, PaintTextLineCount(Item, Column));
    for i := 1 to Length(RectArray.TextRects) - 1 do
    begin
      LoadTextFont(Item, i, ACanvas, Item.Selected);
      DrawTextWEx(ACanvas.Handle, Item.Captions[Item.Details[i]], RectArray.TextRects[i], DrawTextFlags, 1);
    end
  end
end;

function TEasyViewThumbnailItem.ExpandTextR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect;
begin
  Result := inherited ExpandTextR(Item, RectArray, SelectType);
  Result.Top := RectArray.IconRect.Bottom
end;

function TEasyViewThumbnailItem.GetImageList(Column: TEasyColumn; Item: TEasyItem): TImageList;
begin
  Result := inherited GetImageList(Column, Item);
  if not Assigned(Result) then
  begin
    if Assigned(Column) then
      Result := Item.ImageList[Column.Index, eisLarge]
    else
      Result := Item.ImageList[0, eisLarge]
  end
end;

{ TEasyThumbnailItemView}

function TEasyViewThumbnailItem.OverlappedFocus: Boolean;
begin
  Result := True
end;

function TEasyViewThumbnailItem.PaintImageSize: TEasyImageSize;
begin
  Result := eisExtraLarge
end;

function TEasyViewThumbnailItem.SelectionHit(Item: TEasyItem; SelectViewportRect: TRect; SelectType: TEasySelectHitType): Boolean;
var
  R: TRect;
  RectArray: TEasyRectArrayObject;
  SelectMargin: Integer;
begin
  Result := False;
  if Item.Enabled then
  begin
    ItemRectArray(Item, nil, OwnerListview.ScratchCanvas,'', RectArray);
    if SelectType = eshtClickselect then
      Result := IntersectRect(R, SelectViewportRect, ExpandTextR(Item, RectArray, SelectType)) or
                IntersectRect(R, SelectViewportRect, ExpandIconR(Item, RectArray, SelectType))
    else begin
      R := ExpandIconR(Item, RectArray, SelectType);
      SelectMargin := Round( RectWidth(R) * 0.10);
      InflateRect(R, -SelectMargin, -SelectMargin);
      Result := IntersectRect(R, SelectViewportRect, R)
    end
  end
end;

function TEasyViewThumbnailItem.SelectionHitPt(Item: TEasyItem; ViewportPoint: TPoint; SelectType: TEasySelectHitType): Boolean;
var
  RectArray: TEasyRectArrayObject;
  R: TRect;
  SelectMargin: Integer;
begin
  Result := False;
  if Item.Enabled then
  begin
    ItemRectArray(Item, nil, OwnerListview.ScratchCanvas, '', RectArray);
    if SelectType = eshtClickselect then
      Result := Windows.PtInRect(ExpandTextR(Item, RectArray, SelectType), ViewportPoint) or
                Windows.PtInRect(ExpandIconR(Item, RectArray, SelectType), ViewportPoint)
    else
    begin
      R := ExpandIconR(Item, RectArray, SelectType);
      SelectMargin := Round( RectWidth(R) * 0.10);
      InflateRect(R, -SelectMargin, -SelectMargin);
       Result := Windows.PtInRect(R, ViewportPoint)
    end
  end
end;

procedure TEasyViewThumbnailItem.ItemRectArray(Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas; const Caption: WideString; var RectArray: TEasyRectArrayObject);
var
  DrawTextFlags: TCommonDrawTextWFlags;
  Canvas: TControlCanvas;
  R: TRect;
  PositionIndex, AbsIndex: Integer;
  Metrics: TTextMetric;
  ACaption: WideString;
begin
  if Assigned(Item) then
  begin
    if not Item.Initialized then
      Item.Initialized := True;

    if Assigned(Column) then
    begin
      AbsIndex := Column.Index;
      PositionIndex := Column.Position
    end else
    begin
      AbsIndex := 0;
      PositionIndex := 0
    end;

    if PositionIndex > -1 then
    begin
      FillChar(RectArray, SizeOf(RectArray), #0);

      Canvas := TControlCanvas.Create;
      try
        Canvas.Control := OwnerListview;
        Canvas.Lock;

        // Calcuate the Bounds of the Cell that is allowed to be drawn in
        // **********
        RectArray.BoundsRect := Item.DisplayRect;
        InflateRect(RectArray.BoundsRect, -Item.Border, -Item.Border);

        // Calcuate the Bounds of the Cell that is allowed to be drawn in
        // **********
        RectArray.IconRect := RectArray.BoundsRect;
        GetTextMetrics(Canvas.Handle, Metrics);
        RectArray.IconRect.Bottom := RectArray.IconRect.Bottom - Metrics.tmHeight * 2;

        // Calculate area that the Checkbox may be drawn
        // **********
        if Item.CheckType <> ectNone then
        begin
          R := Checks.Bound[Item.Checksize];
          RectArray.CheckRect.Top := RectArray.IconRect.Bottom + 1; // Looks best here not centered
          RectArray.CheckRect.Left := RectArray.BoundsRect.Left + Item.CheckIndent;
          RectArray.CheckRect.Bottom := RectArray.CheckRect.Top + R.Bottom;
          RectArray.CheckRect.Right := RectArray.CheckRect.Left + R.Right;
        end else
        begin
          RectArray.CheckRect.Top := RectArray.IconRect.Bottom;
          RectArray.CheckRect.Left := RectArray.BoundsRect.Left;
          RectArray.CheckRect.Bottom := RectArray.BoundsRect.Bottom;
          RectArray.CheckRect.Right := RectArray.CheckRect.Left;
        end;

        // Calcuate the Bounds of the Cell that is allowed to be drawn in
        // **********
        RectArray.LabelRect.Left := RectArray.CheckRect.Right + Item.CaptionIndent;
        RectArray.LabelRect.Top := RectArray.IconRect.Bottom + 1;
        RectArray.LabelRect.Right := RectArray.BoundsRect.Right;
        RectArray.LabelRect.Bottom := RectArray.BoundsRect.Bottom;


        // Calcuate the Text rectangle based on the current text
        // **********
        RectArray.TextRect := RectArray.LabelRect;
        RectArray.FullTextRect := RectArray.LabelRect;
        // Leave room for a small border between edge of the selection rect and text
        InflateRect(RectArray.TextRect, -2, -2);
        InflateRect(RectArray.FullTextRect, -2, -2);

        DrawTextFlags := [dtCalcRect, dtCalcRectAlign];

        case PaintTextAlignment(Item, Column) of
          taLeftJustify: Include(DrawTextFlags, dtLeft);
          taRightJustify: Include(DrawTextFlags, dtRight);
          taCenter: Include(DrawTextFlags, dtCenter);
        end;

        case PaintTextVAlignment(Item, Column) of
          evaTop: Include(DrawTextFlags, dtTop);
          evaBottom: Include(DrawTextFlags, dtBottom);
          evaCenter: Include(DrawTextFlags, dtCenter);
        end;

        LoadTextFont(Item, PositionIndex, Canvas, Item.Selected);
        ACaption := Item.Captions[AbsIndex];
        DrawTextWEx(Canvas.Handle, ACaption, RectArray.FullTextRect, DrawTextFlags, -1);
        DrawTextWEx(Canvas.Handle, ACaption, RectArray.TextRect, DrawTextFlags, 2);

        // Calculate Selection rectangle paint box
        // **********
        RectArray.SelectionRect := RectArray.TextRect;
        InflateRect(RectArray.SelectionRect, 2, 2);
        RectArray.FullFocusSelRect := RectArray.FullTextRect;
        InflateRect(RectArray.FullFocusSelRect, 2, 2);

        UnionRect(RectArray.FocusChangeInvalidRect, RectArray.IconRect, RectArray.FullFocusSelRect);

        if Item.Focused then
          UnionRect(RectArray.ClickselectBoundsRect, RectArray.IconRect, RectArray.FullFocusSelRect)
        else
          UnionRect(RectArray.ClickselectBoundsRect, RectArray.IconRect, RectArray.SelectionRect);

        RectArray.ClickselectBoundsRect := RectArray.ClickselectBoundsRect;

        RectArray.DragSelectBoundsRect := RectArray.TextRect;

        RectArray.EditRect := RectArray.FullTextRect;
      finally
        Canvas.UnLock;
        Canvas.Free;
      end;
    end
  end
end;

function TEasyViewThumbnailItem.PaintTextLineCount(Item: TEasyItem; Column: TEasyColumn): Integer;
begin
  if Item.Focused and OwnerListview.Focused then
    Result := -1
  else
    Result := 2
end;

function TEasyViewThumbnailItem.PaintTextVAlignment(Item: TEasyItem; Column: TEasyColumn): TEasyVAlignment;
begin
  Result := evaCenter
end;

procedure TEasyViewThumbnailItem.PaintAfter(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; ACanvas: TCanvas; RectArray: TEasyRectArrayObject);
begin
  if OwnerListview.PaintInfoItem.ShowBorder then
  begin
    // Paint the Frame around the Thumbnail
    if Item.Selected or Item.Hilighted then
    begin
      if OwnerListview.Focused or Item.Hilighted then
        ACanvas.Brush.Color := OwnerListview.Selection.Color
      else
        ACanvas.Brush.Color := OwnerListview.Selection.InactiveColor;
      ACanvas.FrameRect(RectArray.IconRect);
      InflateRect(RectArray.IconRect, -1, -1);
      ACanvas.FrameRect(RectArray.IconRect);
      InflateRect(RectArray.IconRect, -1, -1);
      ACanvas.FrameRect(RectArray.IconRect);
    end else
    begin
      ACanvas.Brush.Color := Item.BorderColor;
      ACanvas.FrameRect(RectArray.IconRect);
    end
  end
end;

procedure TEasyViewThumbnailItem.PaintBefore(Item: TEasyItem; Column: TEasyColumn; const Caption: WideString; ACanvas: TCanvas; RectArray: TEasyRectArrayObject);
begin
  // Skip inherited
end;

{ TColumnView }

function TEasyViewColumn.EditAreaHitPt(Column: TEasyColumn;
  ViewportPoint: TPoint): Boolean;
begin
  Result := False
end;

function TEasyViewColumn.GetImageList(Column: TEasyColumn): TImageList;
begin
  Result := Column.OwnerHeader.Images
end;

function TEasyViewColumn.ItemRect(Column: TEasyColumn; RectType: TEasyCellRectType): TRect;
begin
  Result := Rect(0, 0, 0, 0);
end;

function TEasyViewColumn.PaintImageSize(Column: TEasyColumn;
  HeaderType: TEasyHeaderType): TEasyImageSize;
begin
  Result := eisSmall
end;

function TEasyViewColumn.SelectionHit(Column: TEasyColumn;
  SelectViewportRect: TRect; SelectType: TEasySelectHitType): Boolean;
begin
  Result := False
end;

function TEasyViewColumn.SelectionHitPt(Column: TEasyColumn;
  ViewportPoint: TPoint; SelectType: TEasySelectHitType): Boolean;
begin
  Result := False
end;

procedure TEasyViewColumn.CalculateTextRect(Column: TEasyColumn; Canvas: TControlCanvas;
  var TextR: TRect);
// Fits the Text in the PaintInfo.Caption.Text field into the TextR based
// on the values in the PaintInfo record.  If Canvas is nil then a temporary
// canvas is created to fit the text based on the Font in the PaintInfo
var
  DrawTextFlags: TCommonDrawTextWFlags;
  LocalCanvas: TControlCanvas;
begin
  case Column.Alignment of
    taLeftJustify:  Include(DrawTextFlags, dtLeft);
    taRightJustify: Include(DrawTextFlags, dtRight);
    taCenter: Include(DrawTextFlags, dtCenter);
  end;

  case Column.VAlignment of
    evaTop: Include(DrawTextFlags, dtTop);
    evaBottom: Include(DrawTextFlags, dtBottom);
    evaCenter: Include(DrawTextFlags, dtVCenter);
  end;

  if not Assigned(Canvas) then
  begin
    LocalCanvas := TControlCanvas.Create;
    LocalCanvas.Control := OwnerListview
  end else
    LocalCanvas := Canvas;

  try
    LoadTextFont(Column, LocalCanvas);
    DrawTextFlags := DrawTextFlags + [dtCalcRectAdjR, dtCalcRect, dtCalcRectAlign];
    DrawTextWEx(LocalCanvas.Handle, Column.Caption, TextR, DrawTextFlags, 1);
  finally
    if not Assigned(Canvas) then
      LocalCanvas.Free
  end;
end;

procedure TEasyViewColumn.GetImageSize(Column: TEasyColumn; var ImageW, ImageH: Integer);
var
  Images: TImageList;
  IsCustom: Boolean;
begin
  ImageW := 0;
  ImageH := 0;
  Column.ImageDrawIsCustom(Column, IsCustom);
  if IsCustom then
    Column.ImageDrawGetSize(Column, ImageW, ImageH)
  else begin
    Images := GetImageList(Column);
    if (Column.ImageIndexes[0] > -1) and Assigned(Images) then
    begin
      ImageW := Images.Width;
      ImageH := Images.Height
    end
  end;
end;

procedure TEasyViewColumn.ItemRectArray(Column: TEasyColumn;
  var RectArray: TEasyRectArrayObject);
var
   DrawTextFlags: TCommonDrawTextWFlags;
   i, CaptionLines: integer;
   R: TRect;
   ImageW, ImageH: Integer;
begin
  if Assigned(Column) then
  begin
    if not Column.Initialized then
      Column.Initialized := True;


    FillChar(RectArray, SizeOf(RectArray), #0);

    GetImageSize(Column, ImageW, ImageH);

    RectArray.BoundsRect := Column.DisplayRect;
    InflateRect(RectArray.BoundsRect, -2, -2);

    // Make the CheckRect 0 width to initialize it
    RectArray.CheckRect := RectArray.BoundsRect;
    RectArray.CheckRect.Right := RectArray.CheckRect.Left;

    // First calculate where the CheckRect goes
    if Column.CheckType <> ectNone then
    begin
      R := Checks.Bound[Column.Checksize];
      RectArray.CheckRect.Left := RectArray.CheckRect.Left + Column.CheckIndent;
      RectArray.CheckRect.Top := RectArray.CheckRect.Top + (RectHeight(RectArray.BoundsRect) - RectHeight(R)) div 2;
      RectArray.CheckRect.Right := RectArray.CheckRect.Left + RectWidth(R);
      RectArray.CheckRect.Bottom := RectArray.CheckRect.Top + RectHeight(R);
    end;

    // Initialize IconRect to 0 width
    RectArray.IconRect := RectArray.BoundsRect;
    RectArray.IconRect.Left := RectArray.CheckRect.Right;
    RectArray.IconRect.Right := RectArray.CheckRect.Right;

    // Next comes the Image if enabled
    if Column.ImageIndex > -1 then
    begin
      case Column.ImagePosition of
        ehpLeft:
          begin
            RectArray.IconRect.Left := RectArray.CheckRect.Right + Column.ImageIndent;
            RectArray.IconRect.Right := RectArray.IconRect.Left + ImageW;
            RectArray.IconRect.Top := RectArray.BoundsRect.Top + (RectHeight(RectArray.BoundsRect) - ImageH) div 2;
            RectArray.IconRect.Bottom := RectArray.IconRect.Top + ImageH;
            RectArray.LabelRect := RectArray.BoundsRect;
            RectArray.LabelRect.Left := RectArray.IconRect.Right + Column.CaptionIndent;
          end;
        ehpTop:
          begin
            RectArray.IconRect.Top := RectArray.BoundsRect.Top + Column.ImageIndent;
            RectArray.IconRect.Bottom := RectArray.IconRect.Top + ImageH;
            RectArray.IconRect.Left := RectArray.BoundsRect.Left;
            RectArray.IconRect.Right := RectArray.BoundsRect.Right;
            RectArray.LabelRect := RectArray.BoundsRect;
            RectArray.LabelRect.Left := RectArray.CheckRect.Right;
            RectArray.LabelRect.Top := RectArray.IconRect.Bottom + Column.CaptionIndent;
          end;
        ehpRight:
          begin
            RectArray.IconRect.Right := RectArray.BoundsRect.Right - Column.ImageIndent;
            RectArray.IconRect.Left := RectArray.IconRect.Right - ImageW;
            RectArray.IconRect.Top := RectArray.BoundsRect.Top + (RectHeight(RectArray.BoundsRect) - ImageH) div 2;
            RectArray.IconRect.Bottom := RectArray.IconRect.Top + ImageH;
            RectArray.LabelRect := RectArray.BoundsRect;
            RectArray.LabelRect.Left := RectArray.CheckRect.Right;
            RectArray.LabelRect.Right := RectArray.IconRect.Left - Column.CaptionIndent;
          end;
        ehpBottom:
          begin
            RectArray.IconRect.Bottom := RectArray.BoundsRect.Bottom - Column.ImageIndent;
            RectArray.IconRect.Top := RectArray.IconRect.Bottom - ImageH;
            RectArray.IconRect.Left := RectArray.BoundsRect.Left;
            RectArray.IconRect.Right := RectArray.BoundsRect.Right;
            RectArray.LabelRect := RectArray.BoundsRect;
            RectArray.LabelRect.Left := RectArray.CheckRect.Right;
            RectArray.LabelRect.Bottom := RectArray.IconRect.Top - Column.CaptionIndent;
          end;
      end
    end else
    begin
      RectArray.LabelRect := RectArray.BoundsRect;
      RectArray.LabelRect.Left := RectArray.IconRect.Right;
    end;

    if Column.SortDirection <> esdNone then
    begin
      case Column.SortGlyphAlign of
        esgaLeft:
          begin
            RectArray.SortRect := RectArray.BoundsRect;
            RectArray.SortRect.Left := RectArray.LabelRect.Left;
            RectArray.LabelRect.Left := RectArray.LabelRect.Left + Column.SortGlyphIndent + OwnerListview.GlobalImages.ColumnSortUp.Width;
            RectArray.SortRect.Right := RectArray.SortRect.Left + OwnerListview.GlobalImages.ColumnSortUp.Width;
            RectArray.SortRect.Top := RectArray.SortRect.Top + (RectHeight(RectArray.SortRect) - OwnerListview.GlobalImages.ColumnSortUp.Height) div 2;
            RectArray.SortRect.Bottom := RectArray.SortRect.Top + OwnerListview.GlobalImages.ColumnSortUp.Height
          end;
        esgaRight:
          begin
            RectArray.SortRect := RectArray.BoundsRect;
            RectArray.SortRect.Right := RectArray.LabelRect.Right;
            RectArray.LabelRect.Right := RectArray.LabelRect.Right - Column.SortGlyphIndent - OwnerListview.GlobalImages.ColumnSortUp.Width;
            RectArray.SortRect.Left := RectArray.SortRect.Right - OwnerListview.GlobalImages.ColumnSortUp.Width;
            RectArray.SortRect.Top := RectArray.SortRect.Top + (RectHeight(RectArray.SortRect) - OwnerListview.GlobalImages.ColumnSortUp.Height) div 2;
            RectArray.SortRect.Bottom := RectArray.SortRect.Top + OwnerListview.GlobalImages.ColumnSortUp.Height
          end
      else
        // no Sort Glyph
        RectArray.SortRect := RectArray.LabelRect;
        RectArray.SortRect.Right := RectArray.SortRect.Left;
      end
    end;

    if IsRectProper(RectArray.LabelRect) then
    begin

      RectArray.TextRect := RectArray.LabelRect;

      RectArray.TextRect.Left := RectArray.TextRect.Left + Column.CaptionIndent;

      // Leave room for a small border between edge of the selection rect and text
      InflateRect(RectArray.TextRect, -2, -2);

      DrawTextFlags := [dtCalcRect, dtCalcRectAlign];

      case Column.Alignment of
        taCenter: DrawTextFlags := DrawTextFlags + [dtCenter];
        taLeftJustify: DrawTextFlags := DrawTextFlags + [dtLeft];
        taRightJustify: DrawTextFlags := DrawTextFlags + [dtRight];
      end;

      // Vertical Alignment has no meaning in mulitiple line output need to calculate
      // the entire text block then vert align it
     DrawTextFlags := DrawTextFlags + [dtTop];

     CaptionLines := OwnerListview.PaintInfoColumn.CaptionLines;

     // Make enough room for the Details and the Caption Rect
     SetLength(RectArray.TextRects, CaptionLines + 1);

     // Get the Caption Rect
     RectArray.TextRects[0] := RectArray.TextRect;
     LoadTextFont(Column, OwnerListview.Canvas);
     DrawTextWEx(OwnerListview.Canvas.Handle, Column.Caption, RectArray.TextRects[0], DrawTextFlags, CaptionLines);

     RectArray.TextRect := Rect(0, 0, 0, 0);
     for i := 0 to Length(RectArray.TextRects) - 1 do
       UnionRect(RectArray.TextRect, RectArray.TextRect, RectArray.TextRects[i]);

     case Column.VAlignment of
       evaCenter: OffsetRect(RectArray.TextRect, 0, (RectHeight(RectArray.LabelRect) - RectHeight(RectArray.TextRect)) div 2);
       evaBottom: OffsetRect(RectArray.TextRect, 0, (RectHeight(RectArray.LabelRect) - RectHeight(RectArray.TextRect)));
     end;

     for i := 0 to Length(RectArray.TextRects) - 1 do
     begin
       case Column.VAlignment of
         evaCenter: OffsetRect(RectArray.TextRects[i], 0, ((RectHeight(RectArray.LabelRect) - 4) - RectHeight(RectArray.TextRect)) div 2);
         evaBottom: OffsetRect(RectArray.TextRects[i], 0, ((RectHeight(RectArray.LabelRect) - 4) - RectHeight(RectArray.TextRect)));
       end;
     end;
   end else
     RectArray.TextRect := Rect(0, 0, 0, 0);

    // Put the Sort Arrow right next to the Text
    OffsetRect(RectArray.SortRect, RectArray.TextRect.Right - RectArray.SortRect.Left, 0);

    RectArray.ClickselectBoundsRect := RectArray.BoundsRect;
    RectArray.DragSelectBoundsRect := RectArray.BoundsRect;
    RectArray.SelectionRect := RectArray.BoundsRect;
    RectArray.FullTextRect := RectArray.BoundsRect;
    RectArray.FullTextRect := RectArray.BoundsRect;
    RectArray.FocusChangeInvalidRect := RectArray.BoundsRect;
    RectArray.EditRect := RectArray.BoundsRect;

    InflateRect(RectArray.BoundsRect, 2, 2);
  end
end;

procedure TEasyViewColumn.LoadTextFont(Column: TEasyColumn; ACanvas: TCanvas);
begin
  ACanvas.Font.Assign(OwnerListview.Header.Font)
end;

procedure TEasyViewColumn.Paint(Column: TEasyColumn; ACanvas: TCanvas;
  HeaderType: TEasyHeaderType);

  procedure AlphaBlendColumn(AColor: TColor; R: TRect);
  var
    Bitmap: TBitmap;
  begin
    Bitmap := TBitmap.Create;
    try
      Bitmap.PixelFormat := pf32Bit;
      Bitmap.Width := RectWidth(R);
      Bitmap.Height := RectHeight(R);
      if (Bitmap.Width > 0) and (Bitmap.Height > 0) then
      begin
        BitBlt(Bitmap.Canvas.Handle, 0, 0, Bitmap.Width, Bitmap.Height, ACanvas.Handle, R.Left, R.Top, srcCopy);
        MPCommonUtilities.AlphaBlend(0, Bitmap.Canvas.Handle, Bitmap.Canvas.ClipRect, Point(0, 0),
          cbmConstantAlphaAndColor, 128, ColorToRGB(AColor));
        BitBlt(ACanvas.Handle, R.Left, R.Top, Bitmap.Width, Bitmap.Height, Bitmap.Canvas.Handle, 0, 0, srcCopy);
      end
    finally
      Bitmap.Free
    end
  end;

var
  RectArray: TEasyRectArrayObject;
begin
  ItemRectArray(Column, RectArray);

  with RectArray.BoundsRect do
    IntersectClipRect(ACanvas.Handle, Left, Top, Right, Bottom);

  // First allow decendents a crack at the painting
  PaintBefore(Column, ACanvas, HeaderType, RectArray);

  // Paint the Background button
  PaintBkGnd(Column, ACanvas, HeaderType, RectArray);

  // Paint the Selection Rectangle
  // *************************
//    PaintSelectionRect(Column, RectArray, ACanvas);

  // Next Paint the Icon or Bitmap Image
  // *************************
  PaintImage(Column, ACanvas, HeaderType, RectArray, PaintImageSize(Column, HeaderType));

  // Now lets paint the Text
  // *************************
  // If focused then show as many lines as necessary
  // Decendents should override PaintText to change the number of lines
  // as necessary
  PaintText(Column, ACanvas, HeaderType, RectArray, OwnerListview.PaintInfoColumn.CaptionLines);

  PaintSortGlyph(Column, ACanvas, HeaderType, RectArray);

  // Now lets paint Focus Rectangle
  // *************************
  PaintFocusRect(Column, ACanvas, HeaderType, RectArray);

  // Now Paint the Checkbox if applicable
  PaintCheckBox(Column, ACanvas, HeaderType, RectArray);

  PaintDropGlyph(Column, ACanvas, HeaderType, RectArray);

  // Now give decentant a chance to paint anything
  PaintAfter(Column, ACanvas, HeaderType, RectArray);
end;

procedure TEasyViewColumn.PaintAfter(Column: TEasyColumn; ACanvas: TCanvas;
  HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject);
begin

end;

procedure TEasyViewColumn.PaintBefore(Column: TEasyColumn; ACanvas: TCanvas;
  HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject);
begin

end;

procedure TEasyViewColumn.PaintBkGnd(Column: TEasyColumn; ACanvas: TCanvas;
  HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject);

      procedure SpiegelnHorizontal(Bitmap:TBitmap);
      type
        TRGBArray = array[0..0] OF TRGBQuad;
        pRGBArray = ^TRGBArray;
      var
        i, j, w :  Integer;
        RowIn :  pRGBArray;
        RowOut:  pRGBArray;
      begin
        w := Bitmap.Width*SizeOf(TRGBQuad);
        GetMem(RowIn, w);
        for j := 0 to Bitmap.Height-1 do
        begin
          Move(Bitmap.Scanline[j]^, RowIn^,w);
          RowOut := Bitmap.Scanline[j];
          for i := 0 to Bitmap.Width-1 do
            RowOut[i] := RowIn[Bitmap.Width-1-i];
        end;
        Bitmap.Assign(Bitmap);
        Freemem(RowIn);
      end;

var
  NormalButtonFlags, NormalButtonStyle, PressedButtonStyle, PressedButtonFlags,
  RaisedButtonStyle, RaisedButtonFlags: LongWord;
  R: TRect;
  {$IFDEF USETHEMES}
  PartID,
  StateID: LongWord;
  Bits: TBitmap;
  {$ENDIF}
begin
{$IFDEF USETHEMES}
  if OwnerListview.DrawWithThemes then
  begin
    PartID := HP_HEADERITEM;
    if Column.Clicking then
      StateID := HIS_PRESSED
    else
    if (OwnerListview.Header.HotTrackedColumn = Column) and Column.HotTrack and not (OwnerListview.DragManager.Dragging or OwnerListview.DragRect.Dragging) then
      StateID := HIS_HOT
    else
      StateID := HIS_NORMAL;

    if HeaderType = ehtFooter then
    begin
      Bits := TBitmap.Create;
      try
        Bits.Width := RectWidth(Column.DisplayRect);
        Bits.Height := RectHeight(Column.DisplayRect);
        Bits.PixelFormat := pf32Bit;
        DrawThemeBackground(OwnerListview.Themes.HeaderTheme, Bits.Canvas.Handle, PartID, StateID, Rect(0, 0, Bits.Width, Bits.Height), nil);
        SpiegelnHorizontal(Bits);
        BitBlt(ACanvas.Handle, Column.DisplayRect.Left, Column.DisplayRect.Top, Bits.Width, Bits.Height, Bits.Canvas.Handle, 0, 0, SRCCOPY);
      finally
        Bits.Free
      end;
    end else
      DrawThemeBackground(OwnerListview.Themes.HeaderTheme, ACanvas.Handle, PartID, StateID, Column.DisplayRect, nil);

    Exit;
  end;
  {$ENDIF USETHEMES}

{  if Column.Selected then
  begin
    if OwnerListview.Focused then
      ACanvas.Brush.Color := Column.Selection.Color
    else
      ACanvas.Brush.Color := Column.Selection.InactiveColor
  end else
  if Column.HotTrack and Column.Hilighted then
    ACanvas.Brush.Color := PaintInfo.HotTrack.Color
  else     }
    ACanvas.Brush.Color := Column.Color;

  ACanvas.FillRect(Column.DisplayRect);

  RaisedButtonStyle := 0;
  RaisedButtonFlags := 0;

  case Column.Style of
    ehbsThick:
      begin
        NormalButtonStyle := BDR_RAISEDINNER or BDR_RAISEDOUTER;
        NormalButtonFlags := BF_LEFT or BF_TOP or BF_BOTTOM or BF_RIGHT or BF_SOFT or BF_ADJUST;
        PressedButtonStyle := BDR_RAISEDINNER or BDR_RAISEDOUTER;
        PressedButtonFlags := NormalButtonFlags or BF_RIGHT or BF_FLAT or BF_ADJUST;
      end;
    ehbsFlat:
      begin
        NormalButtonStyle := BDR_RAISEDINNER;
        NormalButtonFlags := BF_LEFT or BF_TOP or BF_BOTTOM or BF_RIGHT or BF_ADJUST;
        PressedButtonStyle := BDR_SUNKENOUTER;
        PressedButtonFlags := BF_RECT or BF_ADJUST;
      end;
    else
      begin
        NormalButtonStyle := BDR_RAISEDINNER;
        NormalButtonFlags := BF_RECT or BF_SOFT or BF_ADJUST;
        PressedButtonStyle := BDR_SUNKENOUTER;
        PressedButtonFlags := BF_RECT or BF_ADJUST;
        RaisedButtonStyle := BDR_RAISEDINNER;
        RaisedButtonFlags := BF_LEFT or BF_TOP or BF_BOTTOM or BF_RIGHT or BF_ADJUST;
      end;
  end;

  R := Column.DisplayRect;
  if Column.Clicking then
    DrawEdge(ACanvas.Handle, R, PressedButtonStyle, PressedButtonFlags)
  else begin
    if (Column.Hilighted) and (Column.Style = ehbsPlate) then
      DrawEdge(ACanvas.Handle, R, RaisedButtonStyle, RaisedButtonFlags)
    else
      DrawEdge(ACanvas.Handle, R, NormalButtonStyle, NormalButtonFlags)
  end
end;

procedure TEasyViewColumn.PaintCheckBox(Column: TEasyColumn; ACanvas: TCanvas;
  HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject);
begin
  if  not ((Column.CheckType = ectNone) or (Column.CheckType = ettNoneWithSpace)) then
    PaintCheckboxCore(Column.CheckType,       // TEasyCheckType
                      OwnerListview,        // TCustomEasyListview
                      ACanvas,              // TCanvas
                      RectArray.CheckRect,  // TRect
                      Column.Enabled,         // IsEnabled
                      Column.Checked,         // IsChecked
                      False,                  // IsHot
                      Column.CheckFlat,       // IsFlat
                      Column.CheckHovering,   // IsHovering
                      Column.CheckPending,    // IsPending
                      Column,
                      Column.Checksize);
end;

procedure TEasyViewColumn.PaintDropGlyph(Column: TEasyColumn; ACanvas: TCanvas;
  HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject);
var
  R: TRect;
begin
  if esosDropTarget in Column.State then
  begin
    ACanvas.Brush.Color := clblue;
    R := Column.DisplayRect;
    R.Left := R.Right - 2;
    ACanvas.FillRect(R); 
  end
end;

procedure TEasyViewColumn.PaintFocusRect(Column: TEasyColumn; ACanvas: TCanvas;
  HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject);
begin

end;

procedure TEasyViewColumn.PaintImage(Column: TEasyColumn; ACanvas: TCanvas;
  HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject;
  ImageSize: TEasyImageSize);
//
// Paints the Icon/Bitmap to the Column
//
var
  fStyle: Integer;
  Images: TImageList;
  IsCustom: Boolean;
begin
  Column.ImageDrawIsCustom(Column, IsCustom);
  if IsCustom then
    Column.ImageDraw(Column, ACanvas, RectArray, AlphaBlender)
  else begin
    Images := GetImageList(Column);
    // Draw the image in the ImageList if available
    if Assigned(Column.OwnerHeader.Images) and (Column.ImageIndex > -1) then
    begin
      fStyle := ILD_TRANSPARENT;
      if Column.ImageOverlayIndex > -1 then
      begin
        ImageList_SetOverlayImage(Images.Handle, Column.ImageOverlayIndex, 1);
        fStyle := fStyle or INDEXTOOVERLAYMASK(1);
      end;

      // Get the "normalized" rectangle for the image
      RectArray.IconRect.Left := RectArray.IconRect.Left + (RectWidth(RectArray.IconRect) - Images.Width) div 2;
      RectArray.IconRect.Top := RectArray.IconRect.Top + (RectHeight(RectArray.IconRect) - Images.Height) div 2;
      ImageList_DrawEx(Images.Handle,
        Column.ImageIndex,
        ACanvas.Handle,
        RectArray.IconRect.Left,
        RectArray.IconRect.Top,
        0,
        0,
        CLR_NONE,
        CLR_NONE,
        fStyle);
    end
  end
end;

procedure TEasyViewColumn.PaintSortGlyph(Column: TEasyColumn; ACanvas: TCanvas;
  HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject);
var
  Image: TBitmap;
begin
  if Column.SortDirection <> esdNone then
  begin
    if Column.SortDirection = esdAscending then
      Image := OwnerListview.GlobalImages.ColumnSortUp
    else
      Image := OwnerListview.GlobalImages.ColumnSortDown;

    ACanvas.Draw(RectArray.SortRect.Left, RectArray.SortRect.Top, Image);
  end
end;

procedure TEasyViewColumn.PaintText(Column: TEasyColumn; ACanvas: TCanvas;
  HeaderType: TEasyHeaderType; RectArray: TEasyRectArrayObject;
  LinesToDraw: Integer);
var
   DrawTextFlags: TCommonDrawTextWFlags;
begin
   if not IsRectEmpty(RectArray.TextRect) then
   begin
     ACanvas.Brush.Style := bsClear;

     DrawTextFlags := [dtEndEllipsis];

     if LinesToDraw = 1 then
       Include(DrawTextFlags, dtSingleLine);

     case Column.Alignment of
       taLeftJustify: Include(DrawTextFlags, dtLeft);
       taRightJustify: Include(DrawTextFlags, dtRight);
       taCenter:  Include(DrawTextFlags, dtCenter);
     end;

     // Vertical Alignment is accounted for in the Text Rects

     LoadTextFont(Column, ACanvas);
     if Column.Bold then
       ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];

     OwnerListview.DoColumnPaintText(Column, ACanvas);
     DrawTextWEx(ACanvas.Handle, Column.Caption, RectArray.TextRects[0], DrawTextFlags, OwnerListview.PaintInfoColumn.CaptionLines);
end;

end;

procedure TEasyViewColumn.ReSizeRectArray(
  var RectArray: TEasyRectArrayObjectArray);
var
  OldLen, i: Integer;
begin
  if Length(RectArray) < OwnerListview.Header.Positions.Count then
  begin
    OldLen := Length(RectArray);
    SetLength(RectArray, OwnerListview.Header.Positions.Count);
    for i := OldLen to OwnerListview.Header.Positions.Count - 1 do
      FillChar(RectArray[i], SizeOf(RectArray[i]), #0);
  end else
  if Length(RectArray) > OwnerListview.Header.Positions.Count then
    SetLength(RectArray, OwnerListview.Header.Positions.Count);

  if Length(RectArray) = 0 then
  begin
    SetLength(RectArray, 1);
    FillChar(RectArray[0], SizeOf(RectArray[0]), #0);
  end
end;

{ TEasyGroupGrid }

constructor TEasyGridGroup.Create(AnOwner: TCustomEasyListview; AnOwnerGroup: TEasyGroup);
begin
  inherited Create(AnOwner);
  FOwnerGroup := AnOwnerGroup;
  FLayout := eglVert  // Default orientation
end;

destructor TEasyGridGroup.Destroy;
begin
  inherited;
end;

function TEasyGridGroup.AdjacentItem(Item: TEasyItem; Direction: TEasyAdjacentCellDir): TEasyItem;
var
  ColumnPos: Integer;
  AdjacentGroup: TEasyGroup;
  TestPt: TPoint;
begin
  Result := nil;
  if Assigned(Item) then
  begin
    Assert(Item.Visible, 'Can not find TEasyGroups.AdjacentItem of an Invisible Item');
    case Direction of
      acdLeft:
        begin
          Result := Item;
          if Item.VisibleIndexInGroup > 0 then
            Result := OwnerGroup.VisibleItem[Item.VisibleIndexInGroup - 1]
          else begin
            AdjacentGroup := PrevVisibleGroupWithNItems(OwnerGroup, 0);
            if Assigned(AdjacentGroup) then
              Result := AdjacentGroup.VisibleItem[AdjacentGroup.VisibleCount - 1]
          end
        end;
      acdRight:
        begin
          Result := Item;
          if Item.VisibleIndexInGroup < OwnerGroup.VisibleCount - 1 then
            Result := OwnerGroup.VisibleItem[Item.VisibleIndexInGroup + 1]
          else begin
            AdjacentGroup := NextVisibleGroupWithNItems(OwnerGroup, 0);
            if Assigned(AdjacentGroup) then
              Result := AdjacentGroup.VisibleItem[0]
          end
        end;
      acdUp:
        begin
          // First see if we can stay in the same group
          if Item.VisibleIndexInGroup - ColumnCount >= 0 then
            Result := OwnerGroup.VisibleItems[Item.VisibleIndexInGroup - ColumnCount]
          else begin
            ColumnPos := Item.ColumnPos;
            while not Assigned(Result) and (ColumnPos > -1) do
            begin
              AdjacentGroup := PrevVisibleGroupWithNItems(OwnerGroup, ColumnPos);
              if Assigned(AdjacentGroup) then
                Result := LastItemInNColumn(AdjacentGroup, ColumnPos);
              Dec(ColumnPos)
            end
          end
        end;
      acdDown:
        begin
          // First see if we can stay in the same group
          if Item.VisibleIndexInGroup + ColumnCount < OwnerGroup.VisibleCount then
            Result := OwnerGroup.VisibleItems[Item.VisibleIndexInGroup + ColumnCount]
          else begin
            ColumnPos := Item.ColumnPos;
            while not Assigned(Result) and (ColumnPos > -1) do
            begin
              AdjacentGroup := NextVisibleGroupWithNItems(OwnerGroup, ColumnPos);
              if Assigned(AdjacentGroup) then
                Result := AdjacentGroup.VisibleItem[ColumnPos];
              Dec(ColumnPos)
            end
          end
        end;
      acdPageUp:
        begin
          TestPt := Item.DisplayRect.BottomRight;
          // The Right is actually the Left of the next object
          Dec(TestPt.X);
          Dec(TestPt.Y, OwnerListview.ClientHeight);

          // Make sure we don't run past the last row of items.
          AdjacentGroup := OwnerGroups.FirstVisibleGroup;
          if Assigned(AdjacentGroup) then
            if TestPt.Y < AdjacentGroup.DisplayRect.Top + OwnerGroup.Grid.StaticTopItemMargin then
              TestPt.Y := AdjacentGroup.BoundsRectBkGnd.Top + OwnerGroup.Grid.StaticTopItemMargin;

          Result := OwnerGroups.ItembyPoint(TestPt);
          if not Assigned(Result) then
          begin
            Result := SearchForHitRight(Item.ColumnPos, TestPt);
            while not Assigned(Result) and (TestPt.Y > OwnerGroups.ViewRect.Top) do
            begin
              Inc(TestPt.Y, CellSize.Height);
              Result := SearchForHitRight(Item.ColumnPos, TestPt);
            end
          end
        end;
      acdPageDown:
        begin
           TestPt := Item.DisplayRect.TopLeft;
           Inc(TestPt.Y, OwnerListview.ClientHeight);

           // Make sure we don't run past the last row of items.
           AdjacentGroup := OwnerGroups.LastVisibleGroup;
           if Assigned(AdjacentGroup) then
             if TestPt.Y > AdjacentGroup.BoundsRectBkGnd.Bottom - OwnerGroup.Grid.StaticTopItemMargin then
               TestPt.Y := AdjacentGroup.BoundsRectBkGnd.Bottom - OwnerGroup.Grid.StaticTopItemMargin - 1;

           Result := OwnerGroups.ItembyPoint(TestPt);
           if not Assigned(Result) then
           begin
             Result := SearchForHitRight(Item.ColumnPos, TestPt);
             while not Assigned(Result) and (TestPt.Y < OwnerGroups.ViewRect.Bottom) do
             begin
               Inc(TestPt.Y, CellSize.Height);
               Result := SearchForHitRight(Item.ColumnPos, TestPt);
             end
           end
        end
    end
  end
end;

function TEasyGridGroup.GetMaxColumns(Group: TEasyGroup; WindowWidth: Integer): Integer;
begin
  Result := (WindowWidth -
            (Group.MarginLeft.RuntimeSize + Group.MarginRight.RuntimeSize)) div CellSize.Width;
  if FColumnCount = 0 then
    Inc(FColumnCount);
end;

function TEasyGridGroup.GetOwnerGroups: TEasyGroups;
begin
  Result := OwnerGroup.OwnerGroups
end;

function TEasyGridGroup.LastItemInNColumn(Group: TEasyGroup; N: Integer): TEasyItem;
//
// Finds the last item in the group in the specified column.  It assumes
// that the item does exist (N >= Group.ItemCount)
//
var
  RowPos: Integer;
begin
  RowPos := Group.VisibleCount div Group.Grid.ColumnCount;
  if RowPos * ColumnCount + N >= Group.VisibleCount then
    Dec(RowPos);
  Result := Group.Items[RowPos * ColumnCount + N]
end;

function TEasyGridGroup.NextVisibleGroupWithNItems(StartGroup: TEasyGroup; N: Integer): TEasyGroup;
  //
  //  Returns the first next group encountered when at least N items in it
  //
var
  i: Integer;
begin
  Result := nil;
  i := StartGroup.VisibleIndex + 1;
  while not Assigned(Result) and (i < OwnerGroups.VisibleCount) do
  begin
    if OwnerGroups.VisibleGroup[i].VisibleCount > N then
      Result := OwnerGroups.VisibleGroup[i];
    Inc(i)
  end
end;

function TEasyGridGroup.PrevVisibleGroupWithNItems(StartGroup: TEasyGroup; N: Integer): TEasyGroup;
//
//  Returns the first prev group encountered when at least N items in it
//
var
  i: Integer;
begin
  Result := nil;
  i := StartGroup.VisibleIndex - 1;
  while not Assigned(Result) and (i >= 0) do
  begin
    if OwnerGroups.VisibleGroup[i].VisibleCount > N then
      Result := OwnerGroups.VisibleGroup[i];
    Dec(i)
  end

end;

function TEasyGridGroup.SearchForHitRight(ColumnPos: Integer; Pt: TPoint): TEasyItem;
begin
  Result := nil;
  while not Assigned(Result) and (ColumnPos >= 0) do
  begin
    Result := OwnerGroups.ItembyPoint(Pt);
    Dec(Pt.X, CellSize.Width);
    Dec(ColumnPos)
  end;
end;

function TEasyGridGroup.StaticTopItemMargin: Integer;
// Distance added between the bottom of the top margin and the first
// item, and the distance between the bottom of the last item and the
// top of the bottom margin
begin
   Result := 0
end;

function TEasyGridGroup.StaticTopMargin: Integer;
// Distance added from top of control to the top of the first group
begin
  Result := 0;
end;

procedure TEasyGridGroup.Rebuild(PrevGroup: TEasyGroup; var NextVisibleItemIndex: Integer);
var
  TopLeft: TPoint;
  i, LeftEdge, BottomEdge, ItemGroupVisibleIndex: Integer;
  RectArray: TEasyRectArrayObject;
  WndWidth, VisibleCount, ItemMargin, GroupMargin: Integer;
  FocusedItem, Item: TEasyItem;
begin
  BottomEdge := 0;
  GroupMargin := StaticTopMargin;
  ItemMargin := StaticTopItemMargin;

  // First calculate the Width of the group box.  The height will be dynamically
  // calculated during the enumeration of the items
  WndWidth := OwnerListview.ClientWidth - 1;
  if not OwnerListview.Scrollbars.VertBarVisible then
    WndWidth := WndWidth - GetSystemMetrics(SM_CYVSCROLL);
  if WndWidth < OwnerGroup.MarginRight.RuntimeSize + OwnerGroup.MarginLeft.RuntimeSize + CellSize.Width then
    WndWidth := OwnerGroup.MarginRight.RuntimeSize + OwnerGroup.MarginLeft.RuntimeSize + CellSize.Width;
  OwnerGroup.FDisplayRect := Rect(0, StaticTopMargin, WndWidth,  GroupMargin);

  VisibleCount := 0;
  FocusedItem := nil;

  // Prepare the VisibleList for the worse case, all are visible
  OwnerGroup.VisibleItems.Clear;
  OwnerGroup.VisibleItems.Capacity := OwnerGroup.Items.Count;
  ItemGroupVisibleIndex := 0;

  if OwnerGroup.Visible then
  begin
    if OwnerGroup.Expanded and (OwnerGroup.Items.Count > 0)  then
    begin
      // First calculate the number of columns we can accommodate
      FColumnCount := GetMaxColumns(OwnerGroup, WndWidth);

      TopLeft := Point(0, 0);
      LeftEdge := ColumnCount * CellSize.Width;

      for i := 0 to OwnerGroup.Items.Count - 1 do
      begin
        if TopLeft.X + CellSize.Width > LeftEdge then
        begin
          TopLeft.X := 0;
          Inc(TopLeft.Y, CellSize.Height);
        end;

        Item := OwnerGroup.Items[i];

        if Item.Visible then
        begin
          Item.FVisibleIndexInGroup := ItemGroupVisibleIndex;
          Item.FVisibleIndex := NextVisibleItemIndex;
          Inc(NextVisibleItemIndex);
          Inc(ItemGroupVisibleIndex);
          OwnerGroup.VisibleItems.Add(Item);
          BottomEdge := TopLeft.Y + CellSize.Height;
          Item.FDisplayRect := Rect(TopLeft.X, TopLeft.Y, TopLeft.X + CellSize.Width, BottomEdge);
          Inc(TopLeft.X, CellSize.Width);
          Inc(VisibleCount);
        end else
        begin
          Item.FDisplayRect := Rect(TopLeft.X, TopLeft.Y, TopLeft.X, TopLeft.Y + CellSize.Height);
          Item.FVisibleIndexInGroup := -1;
        end;

        OffsetRect(Item.FDisplayRect, OwnerGroup.MarginLeft.RuntimeSize, OwnerGroup.MarginTop.RuntimeSize + GroupMargin + ItemMargin);

        if Item.Focused then
          FocusedItem := Item;

        if Assigned(PrevGroup) then
          OffsetRect(Item.FDisplayRect, 0, PrevGroup.DisplayRect.Bottom);
      end
    end else
    begin
      // Collapsed group can't have focused item, move it to the next Visible item
      FocusedItem := OwnerListview.Selection.FocusedItem;
      if Assigned(FocusedItem) then
        if FocusedItem.OwnerGroup = OwnerGroup then
          OwnerListview.Selection.FocusedItem := Self.OwnerGroups.NextVisibleItem(FocusedItem)
    end;

    if ColumnCount > 0 then
      FRowCount := OwnerGroup.Items.Count div ColumnCount
    else
      FRowCount := 0;
    if ColumnCount > 0 then
      if OwnerGroup.Items.Count mod ColumnCount > 0 then
        Inc(FRowCount);

    if OwnerGroup.Expanded then
      Inc(OwnerGroup.FDisplayRect.Bottom, OwnerGroup.MarginBottom.RuntimeSize + OwnerGroup.MarginTop.RuntimeSize + BottomEdge + ItemMargin * 2)
    else
      Inc(OwnerGroup.FDisplayRect.Bottom, OwnerGroup.MarginBottom.RuntimeSize + OwnerGroup.MarginTop.RuntimeSize + BottomEdge)
  end;

  // Take care of the items in groups that are not visible or expanded
  // If the Group's is not visible then its items can not be selected.
  // Current it is allowed to have selected items in collapsed groups
  if not OwnerGroup.Visible then
  begin
    i := 0;
    while (i < OwnerGroup.Items.Count) and (OwnerListview.Selection.Count > 0) do
    begin
      OwnerGroup.Items[i].Selected := False;
      Inc(i)
    end;
    if Assigned(OwnerListview.Selection.FocusedItem) then
      if OwnerListview.Selection.FocusedItem.OwnerGroup = OwnerGroup then
        OwnerListview.Selection.FocusedItem := nil;
  end;

  // Special case if all the items are not visible
  if VisibleCount = 0 then
  begin
    FColumnCount := 0;
    FRowCount := 0;
  end;

  if Assigned(PrevGroup) then
    OffsetRect(OwnerGroup.FDisplayRect, 0, PrevGroup.DisplayRect.Bottom);


  // Always resize the group if on the bottom the the control
  if Assigned(FocusedItem) and (OwnerListview.Selection.ResizeGroupOnFocus or (OwnerGroup.Index + 1  = OwnerGroups.Count))  then
  begin
    FocusedItem.ItemRectArray(nil, OwnerListview.ScratchCanvas, RectArray);
    if RectArray.FullTextRect.Bottom > OwnerGroup.FDisplayRect.Bottom - OwnerGroup.MarginBottom.RuntimeSize then
      Inc(OwnerGroup.FDisplayRect.Bottom, RectArray.FullTextRect.Bottom - FocusedItem.DisplayRect.Bottom);
  end
end;

constructor TEasyGridReportGroup.Create(AnOwner: TCustomEasyListview;
  AnOwnerGroup: TEasyGroup);
begin
  inherited Create(AnOwner, AnOwnerGroup);
  FLayout := eglGrid
end;

function TEasyGridReportGroup.AdjacentItem(Item: TEasyItem;
  Direction: TEasyAdjacentCellDir): TEasyItem;
var
  TestPt: TPoint;
begin
  Result := nil;
  if Assigned(Item) then
  begin
    case Direction of
      acdUp: Result := OwnerGroups.PrevVisibleItem(Item);
      acdDown: Result := OwnerGroups.NextVisibleItem(Item);
      acdPageUp: // WL, 05/01/05
        begin
          // Look for first visible item at top.
          TestPt := Point(0, OwnerListview.ClientInViewportCoords.Top);
          repeat
            Result := OwnerGroups.ItembyPoint(TestPt);
            Inc(TestPt.Y, CellSize.Height);
          until (Result <> nil) or (Result = Item) or (TestPt.Y >= OwnerListview.ClientInViewportCoords.Bottom);

          // If first visible item is the parameter Item already we must look one
          // page further up. Find the furthest item which still allows Result
          // and item to be on one page.
          if (Result <> nil) and (Result = Item) then
          begin
            TestPt := Point(0, Item.DisplayRect.Bottom - RectHeight(OwnerListview.ClientInViewportCoords) - 1);
            repeat
              Result := OwnerGroups.ItembyPoint(TestPt);
              Inc(TestPt.Y, CellSize.Height);
            until Result <> nil; // loop terminates at Item at the latest (which must be below)
            if Result = Item then
              Result := nil; // no adjacent page-down item found, Item was already the first one
          end;
        end;
      acdPageDown: // WL, 05/01/05
        begin
          // Look for last visible item at bottom.
          TestPt := Point(0, OwnerListview.ClientInViewportCoords.Bottom - 1);
          repeat
            Result := OwnerGroups.ItembyPoint(TestPt);
            Dec(TestPt.Y, CellSize.Height);
          until (Result <> nil) or (Result = Item) or (TestPt.Y < OwnerListview.ClientInViewportCoords.Top);

          // If last visible item is the parameter Item already we must look one
          // page further down. Find the furthest item which still allows Result
          // and item to be on one page.
          if (Result <> nil) and (Result = Item) then
          begin
            TestPt := Point(0, Item.DisplayRect.Top + RectHeight(OwnerListview.ClientInViewportCoords) - 1);
            repeat
              Result := OwnerGroups.ItembyPoint(TestPt);
              Dec(TestPt.Y, CellSize.Height);
            until Result <> nil; // loop terminates at Item at the latest (which must be above)
            if Result = Item then
              Result := nil; // no adjacent page-down item found, Item was already the last one
          end;
        end
    else
      //      acdLeft:
      //        begin
      //           Lines := 0;
      //           SystemParametersInfo(SPI_GETWHEELSCROLLLINES, 0, @Lines, 0);
      //           if Lines = 0 then
      //             Lines := 3;
      //           OwnerListview.Scrollbars.Scroll(-Lines, 0);
      //        end;
      //      acdRight:
      //        begin
      //          Lines := 0;
      //           SystemParametersInfo(SPI_GETWHEELSCROLLLINES, 0, @Lines, 0);
      //           if Lines = 0 then
      //             Lines := 3;
      //           OwnerListview.Scrollbars.Scroll(Lines, 0);
      //        end;
      Result := inherited AdjacentItem(Item, Direction);
    end
  end
end;

function TEasyGridReportGroup.GetCellSize: TEasyCellSize;
begin
  Result := OwnerListview.CellSizes.Report
end;

{ TEasyReportGroupGrid }


procedure TEasyGridReportGroup.Rebuild(PrevGroup: TEasyGroup; var NextVisibleItemIndex: Integer);
var
  i, Top, Bottom, Width, Left, Offset, TopMargin,
  BottomMargin, VisibleCount: Integer;
  Item: TEasyItem;
begin
  if Assigned(PrevGroup) then
    Offset := PrevGroup.DisplayRect.Bottom
  else
    Offset := 2;

  OwnerGroup.FDisplayRect := Rect(0, Offset, OwnerListview.Header.ViewWidth, Offset);
  // Prepare the VisibleList for the worse case, all are visible
  OwnerGroup.VisibleItems.Clear;
  OwnerGroup.VisibleItems.Capacity := OwnerGroup.Items.Count;

  Left := OwnerGroup.MarginLeft.RuntimeSize;
  if OwnerListview.Header.LastColumnByPosition <> nil then
  begin
    Width := OwnerListview.Header.LastColumnByPosition.DisplayRect.Right;
    Width := Width - OwnerGroup.MarginRight.RuntimeSize
  end else
    Width := 0;

  TopMargin := OwnerGroup.MarginTop.RuntimeSize;
  BottomMargin := OwnerGroup.MarginBottom.RuntimeSize;
  if OwnerGroup.Visible then
  begin
    if OwnerGroup.Expanded and (OwnerGroup.Items.Count > 0) then
    begin
      VisibleCount := 0;
      Top := Offset + TopMargin;
      Bottom := Offset + CellSize.Height + TopMargin;
      for i := 0 to OwnerGroup.Items.Count - 1 do
      begin
        Item := OwnerGroup.Items.List.List[i]; // Direct Access for Speed
        if Item.Visible then
        begin
          Item.FVisibleIndex := NextVisibleItemIndex;
          Item.FVisibleIndexInGroup := VisibleCount;
          Item.FDisplayRect := Rect(Left, Top, Width, Bottom);
          OwnerGroup.VisibleItems.Add(Item);
          Inc(Top, CellSize.Height);
          Inc(Bottom, CellSize.Height);
          Inc(VisibleCount);
          Inc(NextVisibleItemIndex);
        end else
          Item.FDisplayRect := Rect(Left, Top, Width, Top);
        OwnerGroup.FDisplayRect.Bottom := Item.FDisplayRect.Bottom + BottomMargin;
      end
    end else
      OwnerGroup.FDisplayRect := Rect(0, Offset, OwnerListview.Header.ViewWidth, Offset + TopMargin + BottomMargin);
  end;
  // Column Count does not relate to Report view columns.  It is a more primitive
  // and the Report columns are within the Grid Column
  FColumnCount := 1;
end;

procedure TEasyGridReportGroup.SetCellSize(Value: TEasyCellSize);
begin
  OwnerListview.CellSizes.Report.Assign(Value)
end;

constructor TEasyGridListGroup.Create(AnOwner: TCustomEasyListview; AnOwnerGroup: TEasyGroup);
begin
  inherited Create(AnOwner, AnOwnerGroup);
  FLayout := eglHorz
end;

function TEasyGridListGroup.AdjacentItem(Item: TEasyItem;
  Direction: TEasyAdjacentCellDir): TEasyItem;
  function NextVisibleGroupWithNItems(StartGroup: TEasyGroup; N: Integer): TEasyGroup;
  //
  //  Returns the first next group encountered when at least N items in it
  //
  var
    i: Integer;
  begin
    Result := nil;
    i := StartGroup.VisibleIndex + 1;
    while not Assigned(Result) and (i < OwnerGroups.VisibleCount) do
    begin
      if OwnerGroups.VisibleGroup[i].VisibleCount > N then
        Result := OwnerGroups.VisibleGroup[i];
      Inc(i)
    end
  end;

  function PrevVisibleGroupWithNItems(StartGroup: TEasyGroup; N: Integer): TEasyGroup;
  //
  //  Returns the first prev group encountered when at least N items in it
  //
  var
    i: Integer;
  begin
    Result := nil;
    i := StartGroup.VisibleIndex - 1;
    while not Assigned(Result) and (i >= 0) do
    begin
      if OwnerGroups.VisibleGroup[i].VisibleCount > N then
        Result := OwnerGroups.VisibleGroup[i];
      Dec(i)
    end
  end;

  function LastItemInNRow(Group: TEasyGroup; N: Integer): TEasyItem;
  //
  // Finds the last item in the group in the specified column.  It assumes
  // that the item does exist (N >= Group.ItemCount)
  //
  var
    ColumnPos: Integer;
  begin
    ColumnPos := Group.VisibleCount div Group.Grid.RowCount;
    if ColumnPos * RowCount + N >= Group.VisibleCount then
      Dec(ColumnPos);
    Result := Group.Items[ColumnPos * RowCount + N]
  end;

  function SearchForHitRight(ColumnPos: Integer; Pt: TPoint): TEasyItem;
  begin
    Result := nil;
    while not Assigned(Result) and (ColumnPos >= 0) do
    begin
      Result := OwnerGroups.ItembyPoint(Pt);
      Dec(Pt.X, CellSize.Width);
      Dec(ColumnPos)
    end;
  end;

var
  RowPos, ItemIndex: Integer;
  AdjacentGroup: TEasyGroup;
begin
  Result := nil;
  if Assigned(Item) then
  begin
    Assert(Item.Visible, 'Can not find TEasyGroups.AdjacentItem of an Invisible Item');
    case Direction of
      acdUp:
        begin
          Result := Item;
          if Item.VisibleIndexInGroup > 0 then
            Result := OwnerGroup.VisibleItem[Item.VisibleIndexInGroup - 1]
          else begin
            AdjacentGroup := PrevVisibleGroupWithNItems(OwnerGroup, 0);
            if Assigned(AdjacentGroup) then
              Result := AdjacentGroup.VisibleItem[AdjacentGroup.VisibleCount - 1]
          end
        end;
      acdDown:
        begin
          Result := Item;
          if Item.VisibleIndexInGroup < OwnerGroup.VisibleCount - 1 then
            Result := OwnerGroup.VisibleItem[Item.VisibleIndexInGroup + 1]
          else begin
            AdjacentGroup := NextVisibleGroupWithNItems(OwnerGroup, 0);
            if Assigned(AdjacentGroup) then
              Result := AdjacentGroup.VisibleItem[0]
          end
        end;
      acdLeft:
        begin
          // First see if we can stay in the same group
          if Item.VisibleIndexInGroup - RowCount >= 0 then
            Result := OwnerGroup.VisibleItems[Item.VisibleIndexInGroup - RowCount]
          else begin
            RowPos := Item.RowPos;
            while not Assigned(Result) and (RowPos > -1) do
            begin
              AdjacentGroup := PrevVisibleGroupWithNItems(OwnerGroup, RowPos);
              if Assigned(AdjacentGroup) then
                Result := LastItemInNRow(AdjacentGroup, RowPos);
              Dec(RowPos)
            end
          end
        end;
      acdRight:
        begin
          // First see if we can stay in the same group
          if Item.VisibleIndexInGroup + RowCount < OwnerGroup.VisibleCount then
            Result := OwnerGroup.VisibleItems[Item.VisibleIndexInGroup + RowCount]
          else begin
            RowPos := Item.RowPos;
            while not Assigned(Result) and (RowPos > -1) do
            begin
              AdjacentGroup := NextVisibleGroupWithNItems(OwnerGroup, RowPos);
              if Assigned(AdjacentGroup) then
                Result := AdjacentGroup.VisibleItem[RowPos];
              Dec(RowPos)
            end
          end
        end;
      acdPageUp:
        begin
          ItemIndex := Item.VisibleIndexInGroup;
          while (ItemIndex > 0) and (ItemIndex mod RowCount <> 0) do
            Dec(ItemIndex);
          Result := OwnerGroup.Items[ItemIndex]
        end;
      acdPageDown:
        begin
          ItemIndex := Item.VisibleIndexInGroup;
          while (ItemIndex < Item.OwnerGroup.Items.Count - 1) and (ItemIndex mod RowCount <> RowCount - 1) do
            Inc(ItemIndex);
          Result := OwnerGroup.Items[ItemIndex]
        end
    end
  end
end;

function TEasyGridListGroup.GetCellSize: TEasyCellSize;
begin
  Result := OwnerListview.CellSizes.List
end;

{ TEasyListGroupGrid }

procedure TEasyGridListGroup.Rebuild(PrevGroup: TEasyGroup;
  var NextVisibleItemIndex: Integer);
var
  ScrollSize, ClientHeight: Integer;
  TopLeft: TPoint;
  i, Offset, VisibleCount, Height: Integer;
  RectArray: TEasyRectArrayObject;
  TextSize: TSize;
  R: TRect;
  Item: TEasyItem;
begin
  VisibleCount := 0;
  // Always assume a scroll bar
  ScrollSize := GetSystemMetrics(SM_CXHSCROLL);
  ClientHeight := OwnerListview.ClientHeight;

  if Assigned(PrevGroup) then
    Offset := PrevGroup.DisplayRect.Right
  else
    Offset := 0;

  Height := ClientHeight - ScrollSize;

  // May have to show a vertical scrollbar if the entire thing won't fit in the window
  if Height < OwnerGroup.MarginBottom.RuntimeSize + OwnerGroup.MarginTop.RuntimeSize + CellSize.Height then
    Height := OwnerGroup.MarginBottom.RuntimeSize + OwnerGroup.MarginTop.RuntimeSize + CellSize.Height;

  OwnerGroup.FDisplayRect := Rect(Offset, 0, Offset, Height);
  // Prepare the VisibleList for the worse case, all are visible
  OwnerGroup.VisibleItems.Clear;
  OwnerGroup.VisibleItems.Capacity := OwnerGroup.Items.Count;

  if OwnerGroup.Visible then
  begin
    if OwnerGroup.Expanded and (OwnerGroup.Items.Count > 0) then
    begin
      // First calculate the number of rows we can accommodate
      FRowCount := (ClientHeight - ScrollSize -
        1 - (OwnerGroup.MarginBottom.RuntimeSize + OwnerGroup.MarginTop.RuntimeSize)) div CellSize.Height;
      if FRowCount = 0 then
        Inc(FRowCount);

      FColumnCount := 1;

      TopLeft := Point(Offset + OwnerGroup.MarginLeft.RuntimeSize, OwnerGroup.MarginTop.RuntimeSize);

      for i := 0 to OwnerGroup.Items.Count - 1 do
      begin
        Item := OwnerGroup.Items[i];
        if Item.Visible then
        begin
          Item.FVisibleIndex := NextVisibleItemIndex;
          Item.FVisibleIndexInGroup := VisibleCount;
          OwnerGroup.VisibleItems.Add(Item);
          R := Rect(TopLeft.X, TopLeft.Y, TopLeft.X + CellSize.Width, TopLeft.Y + CellSize.Height);
          Inc(TopLeft.Y, CellSize.Height);
          Inc(VisibleCount)
        end else
          R := Rect(TopLeft.X, TopLeft.Y, TopLeft.X, TopLeft.Y + CellSize.Height);

        if R.Bottom > Height - OwnerGroup.MarginBottom.RuntimeSize then
        begin
          OffsetRect(R, CellSize.Width, -(TopLeft.Y - CellSize.Height - OwnerGroup.MarginTop.RuntimeSize));
          TopLeft.Y := OwnerGroup.MarginTop.RuntimeSize + CellSize.Height;
          Inc(TopLeft.X, CellSize.Width);
          Inc(FColumnCount);
        end;

        OwnerGroup.Items[i].FDisplayRect := R
      end;
      OwnerGroup.FDisplayRect.Right := TopLeft.X + CellSize.Width + OwnerGroup.MarginRight.RuntimeSize;

    end;
    // Special case if all the items are not visible
    if VisibleCount = 0 then
    begin
      TextSize := TextExtentW(OwnerGroup.Caption, OwnerListview.GroupFont);
      OwnerGroup.GroupView.GroupRectArray(OwnerGroup, egmeTop, OwnerGroup.BoundsRectTopMargin, RectArray);
      FColumnCount := 0;
      FRowCount := 0;
      OwnerGroup.FDisplayRect.Right := OwnerGroup.MarginLeft.RuntimeSize +
        OwnerGroup.MarginRight.RuntimeSize + RectArray.IconRect.Right +
        OwnerGroup.CaptionIndent + TextSize.cx;
    end;
  end;
end;

procedure TEasyGridListGroup.SetCellSize(Value: TEasyCellSize);
begin
  OwnerListview.CellSizes.List.Assign(Value)
end;

{ TEasyFooterMargin }

constructor TCustomEasyFooterMargin.Create(AnOwner: TCustomEasyListview);
begin
  inherited;
  FImageIndex := -1;
  FImageOverlayIndex := -1;
  FSize := 30;
end;

destructor TCustomEasyFooterMargin.Destroy;
begin
  FreeAndNil(FPaintInfo);
  inherited;
end;

function TCustomEasyFooterMargin.GetAlignment: TAlignment;
begin
  Result := PaintInfo.Alignment
end;

function TCustomEasyFooterMargin.GetCaptionIndent: Integer;
begin
  Result := PaintInfo.CaptionIndent
end;

function TCustomEasyFooterMargin.GetCaptionLines: Integer;
begin
  Result := PaintInfo.CaptionLines
end;

function TCustomEasyFooterMargin.GetImageIndent: Integer;
begin
  Result := PaintInfo.ImageIndent
end;

function TCustomEasyFooterMargin.GetPaintInfo: TEasyPaintInfoBaseGroup;
begin
  if not Assigned(FPaintInfo) then
    Result := OwnerListview.PaintInfoGroup.MarginBottom.FPaintInfo
  else
    Result := FPaintInfo
end;

function TCustomEasyFooterMargin.GetVAlignment: TEasyVAlignment;
begin
  Result := PaintInfo.VAlignment
end;

procedure TCustomEasyFooterMargin.Assign(Source: TPersistent);
var
  Temp: TCustomEasyFooterMargin;
begin
  inherited Assign(Source);
  if Source is TCustomEasyFooterMargin then
  begin
    Temp := TCustomEasyFooterMargin(Source);
    FCaption := Temp.Caption;
  end
end;

procedure TCustomEasyFooterMargin.SetAlignment(Value: TAlignment);
begin
  if Alignment <> Value then
  begin
    PaintInfo.Alignment := Value;
    OwnerListview.Groups.Rebuild
  end;
end;

procedure TCustomEasyFooterMargin.SetCaption(Value: WideString);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    OwnerListview.Groups.Rebuild
  end;
end;

procedure TCustomEasyFooterMargin.SetCaptionIndent(Value: Integer);
begin
  if CaptionIndent <> Value then
  begin
    PaintInfo.CaptionIndent := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TCustomEasyFooterMargin.SetCaptionLines(Value: Integer);
begin
  if CaptionLines <> Value then
  begin
    PaintInfo.CaptionLines := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TCustomEasyFooterMargin.SetImageIndent(Value: Integer);
begin
  if ImageIndent <> Value then
  begin
    PaintInfo.ImageIndent := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TCustomEasyFooterMargin.SetImageIndex(Value: Integer);
begin
  if FImageIndex <> Value then
  begin
    FImageIndex := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TCustomEasyFooterMargin.SetImageOveralyIndex(Value: Integer);
begin
  if FImageOverlayIndex <> Value then
  begin
    FImageOverlayIndex := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TCustomEasyFooterMargin.SetPaintInfo(const Value: TEasyPaintInfoBaseGroup);
begin
  if not Assigned(FPaintInfo) then
    OwnerListview.PaintInfoGroup.Assign(Value)
  else
    FPaintInfo.Assign(Value)
end;

procedure TCustomEasyFooterMargin.SetVAlignment(
  Value: TEasyVAlignment);
begin
  if VAlignment <> Value then
  begin
    PaintInfo.VAlignment := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end;
end;

{ TEasyBasicItemPaintInfo }

constructor TEasyPaintInfoBasic.Create(AnOwner: TCustomEasyListview);
begin
  inherited Create(AnOwner);
  FImageIndent := 2;
  FCaptionIndent := 4;
  FCaptionLines := 1;
  FBorder := 4;
  FBorderColor := clHighlight;
  FCheckIndent := 2;
  FChecksize := 12;
  FVAlignment := evaCenter;
  FShowBorder := True;
end;

procedure TEasyPaintInfoBasic.Assign(Source: TPersistent);
var
  Temp: TEasyPaintInfoBasic;
begin
  if Source is TEasyPaintInfoBasic then
  begin
    Temp := TEasyPaintInfoBasic(Source);
    FAlignment := Temp.Alignment;
    FBorder := Temp.Border;
    FBorderColor := Temp.BorderColor;
    FCaptionIndent := Temp.CaptionIndent;
    FCaptionLines := Temp.CaptionLines;
    FCheckFlat := Temp.CheckFlat;
    FCheckIndent := Temp.CheckIndent;
    FChecksize := Temp.Checksize;
    FCheckType := Temp.CheckType;
    FImageIndent := Temp.ImageIndent;
    FVAlignment := Temp.VAlignment;
  end
end;

procedure TEasyPaintInfoBasic.Invalidate(ImmediateUpdate: Boolean);
begin
  OwnerListview.SafeInvalidateRect(nil, ImmediateUpdate)
end;

procedure TEasyPaintInfoBasic.SetAlignment(Value: TAlignment);
begin
  if Value <> FAlignment then
  begin
    FAlignment := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBasic.SetBorder(Value: Integer);
begin
  if Value <> FBorder then
  begin
    FBorder := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBasic.SetBorderColor(Value: TColor);
begin
  if Value <> FBorderColor then
  begin
    FBorderColor := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBasic.SetCaptionIndent(Value: Integer);
begin
  if Value <> FCaptionIndent then
  begin
    FCaptionIndent := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBasic.SetCaptionLines(Value: Integer);
begin
  if Value <> FCaptionLines then
  begin
    FCaptionLines := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBasic.SetCheckFlat(Value: Boolean);
begin
  if Value <> FCheckFlat then
  begin
    FCheckFlat := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBasic.SetCheckIndent(Value: Integer);
begin
  if Value <> FCheckIndent then
  begin
    FCheckIndent := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBasic.SetChecksize(Value: Integer);
begin
  if Value <> FChecksize then
  begin
    FChecksize := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBasic.SetCheckType(Value: TEasyCheckType);
begin
   if Value <> FCheckType then
  begin
    FCheckType := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBasic.SetImageIndent(Value: Integer);
begin
  if Value <> FImageIndent then
  begin
    FImageIndent := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBasic.SetShowBorder(const Value: Boolean);
begin
  FShowBorder := Value;
end;

procedure TEasyPaintInfoBasic.SetVAlignment(Value: TEasyVAlignment);
begin
  if Value <> FVAlignment then
  begin
    FVAlignment := Value;
    Invalidate(False)
  end
end;

{ TEasyBasicGroupPaintInfo }
constructor TEasyPaintInfoBaseGroup.Create(AnOwner: TCustomEasyListview);
begin
  inherited Create(AnOwner);
  FBandBlended := True;
  FBandColor := clBlue;
  FBandColorFade := clWindow;
  FBandEnabled := True;
  FBandLength := 300;
  FBandMargin := 2;
  FBandRadius := 4;
  FBandThickness := 3;
  FExpandable := True;
  FExpanded := True;
  FExpandImageIndent := 4;
  FMarginBottom := TEasyFooterMargin.Create(AnOwner);
  FMarginLeft := TEasyMargin.Create(AnOwner);
  FMarginRight := TEasyMargin.Create(AnOwner);
  FMarginTop := TEasyHeaderMargin.Create(AnOwner);
end;

destructor TEasyPaintInfoBaseGroup.Destroy;
begin
  inherited;
  FreeAndNil(FMarginBottom);
  FreeAndNil(FMarginLeft);
  FreeAndNil(FMarginRight);
  FreeAndNil(FMarginTop);
end;

function TEasyPaintInfoBaseGroup.GetMarginBottom: TCustomEasyFooterMargin;
begin
  Result := FMarginBottom
end;

function TEasyPaintInfoBaseGroup.GetMarginLeft: TEasyMargin;
begin
  Result := FMarginLeft
end;

function TEasyPaintInfoBaseGroup.GetMarginRight: TEasyMargin;
begin
  Result := FMarginRight
end;

function TEasyPaintInfoBaseGroup.GetMarginTop: TEasyHeaderMargin;
begin
  Result := FMarginTop
end;

procedure TEasyPaintInfoBaseGroup.Assign(Source: TPersistent);
var
  Temp: TEasyPaintInfoBaseGroup;
begin
  inherited Assign(Source);
  if Source is TEasyPaintInfoBaseGroup then
  begin
    Temp := TEasyPaintInfoBaseGroup(Source);
    FBandBlended := Temp.BandBlended;
    FBandColor := Temp.BandColor;
    FBandColorFade := Temp.BandColorFade;
    FBandEnabled := Temp.BandEnabled;
    FBandFullWidth := Temp.BandFullWidth;
    FBandIndent := Temp.BandIndent;
    FBandLength := Temp.BandLength;
    FBandMargin := Temp.BandMargin;
    FBandRadius := Temp.BandRadius;
    FBandThickness := Temp.BandThickness;
    FExpandable := Temp.Expandable;
    FExpandImageIndent := Temp.ExpandImageIndent;
    MarginBottom.Assign(Temp.MarginBottom);
    MarginLeft.Assign(Temp.MarginLeft);
    MarginRight.Assign(Temp.MarginRight);
    MarginTop.Assign(Temp.MarginTop);
  end
end;

procedure TEasyPaintInfoBaseGroup.SetBandBlended(Value: Boolean);
begin
  if Value <> FBandBlended then
  begin
    FBandBlended := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBaseGroup.SetBandColor(Value: TColor);
begin
  if Value <> FBandColor then
  begin
    FBandColor := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBaseGroup.SetBandColorFade(Value: TColor);
begin
  if Value <> FBandColorFade then
  begin
    FBandColorFade := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBaseGroup.SetBandEnabled(Value: Boolean);
begin
  if Value <> FBandEnabled then
  begin
    FBandEnabled := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBaseGroup.SetBandFullWidth(Value: Boolean);
begin
  if Value <> FBandFullWidth then
  begin
    FBandFullWidth := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBaseGroup.SetBandIndent(Value: Integer);
begin
  if Value <> FBandIndent then
  begin
    FBandIndent := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBaseGroup.SetBandLength(Value: Integer);
begin
  if Value <> FBandLength then
  begin
    FBandLength := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBaseGroup.SetBandMargin(Value: Integer);
begin
  if Value <> FBandMargin then
  begin
    FBandMargin := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBaseGroup.SetBandRadius(Value: Byte);
begin
  if Value <> FBandRadius then
  begin
    FBandRadius := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBaseGroup.SetBandThickness(Value: Integer);
begin
  if Value <> FBandThickness then
  begin
    FBandThickness := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBaseGroup.SetExpandable(Value: Boolean);
begin
  if Value <> FExpandable then
  begin
    FExpandable := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBaseGroup.SetExpandImageIndent(Value: Integer);
begin
  if Value <> FExpandImageIndent then
  begin
    FExpandImageIndent := Value;
    Invalidate(False)
  end
end;

procedure TEasyPaintInfoBaseGroup.SetMarginBottom(
  Value: TCustomEasyFooterMargin);
begin
  if Value <> FMarginBottom then
  begin
    FreeAndNil(FMarginBottom);
    FMarginBottom := Value
  end
end;

procedure TEasyPaintInfoBaseGroup.SetMarginLeft(Value: TEasyMargin);
begin
  if Value <> FMarginLeft then
  begin
    FreeAndNil(FMarginLeft);
    FMarginLeft := Value
  end
end;

procedure TEasyPaintInfoBaseGroup.SetMarginRight(Value: TEasyMargin);
begin
  if Value <> FMarginRight then
  begin
    FreeAndNil(FMarginRight);
    FMarginRight := Value
  end
end;

procedure TEasyPaintInfoBaseGroup.SetMarginTop(Value: TEasyHeaderMargin);
begin
  if Value <> FMarginTop then
  begin
    FreeAndNil(FMarginTop);
    FMarginTop := Value
  end
end;

{ TEasyHotTrackManager}
constructor TEasyHotTrackManager.Create(AnOwner: TCustomEasyListview);
begin
  inherited Create(AnOwner);
  FColor := clHighlight;
  FUnderLine := True;
  FCursor := crHandPoint;
  FGroupTrack := [htgIcon, htgText];
  FItemTrack := [htiIcon, htiText];
  FColumnTrack := [htcIcon, htcText]
end;

function TEasyHotTrackManager.GetPendingObject(MousePos: TPoint): TEasyCollectionItem;
begin
  Result := FPendingObject
end;

procedure TEasyHotTrackManager.SetPendingObject(MousePos: TPoint; Value: TEasyCollectionItem);
var
  TempOldItem: TEasyCollectionItem;
  OldCapture: HWnd;
begin
  if FPendingObject <> Value then
  begin
    TempOldItem := FPendingObject;
    FPendingObject := nil;
    if Enabled or (Value = nil) then
    begin
      if Assigned(OwnerListview) and OwnerListview.HandleAllocated then
      begin
        // Make sure the hot track will end
        if Assigned(Value) then
          Mouse.Capture := OwnerListview.Handle
        else
          if Mouse.Capture = OwnerListview.Handle then
            Mouse.Capture := 0;

        // Cursor only works if no Window is captured
        OldCapture := Mouse.Capture;
        Mouse.Capture := 0;
        if Assigned(Value) then
          OwnerListview.Cursor := Cursor
        else
          OwnerListview.Cursor := crDefault;
        Mouse.Capture := OldCapture;

      end
    end;
    // PendingObject must be nil when this is executed
    // Always fire the event for custom hottracking
    if Assigned(TempOldItem) then
      TempOldItem.HotTracking[MousePos] := False;
    FPendingObject := Value;
    if Assigned(FPendingObject) then
      FPendingObject.HotTracking[MousePos] := True;
  end
end;

procedure TEasyHotTrackManager.SetPendingObjectCheck(const Value: TEasyCollectionItem);
begin
  if Value <> FPendingObjectCheck then
  begin
    if Assigned(FPendingObjectCheck) then
      FPendingObjectCheck.CheckHovering := False;
    FPendingObjectCheck := Value;
    if Assigned(FPendingObjectCheck) then
      FPendingObjectCheck.CheckHovering := True;
  end
end;

{ TEasyPaintInfoBaseColumn }

constructor TEasyPaintInfoBaseColumn.Create(AnOwner: TCustomEasyListview);
begin
  inherited;
  FColor := clBtnFace;
  FSortGlyphAlign := esgaRight;
  FSortGlyphIndent := 2;
  FHotTrack := True;
  FStyle := ehbsThick;
  FImagePosition := ehpLeft;
  FHilightFocusedColor := $00F7F7F7;
end;

procedure TEasyPaintInfoBaseColumn.SetColor(Value: TColor);
begin
  if Value <> FColor then
  begin
    FColor := Value;
    OwnerListview.Header.Invalidate(False);
  end
end;

procedure TEasyPaintInfoBaseColumn.SetHilightFocused(const Value: Boolean);
begin
  if FHilightFocused <> Value then
  begin
    FHilightFocused := Value;
    if Assigned(OwnerListview) then
      OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TEasyPaintInfoBaseColumn.SetHilightFocusedColor(const Value: TColor);
begin
  if FHilightFocusedColor <> Value then
  begin
    FHilightFocusedColor := Value;
    if Assigned(OwnerListview) then
      OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TEasyPaintInfoBaseColumn.SetImagePosition(Value: TEasyHeaderImagePosition);
begin
  if Value <> FImagePosition then
  begin
    FImagePosition := Value;
    OwnerListview.Header.Invalidate(False);
  end
end;

procedure TEasyPaintInfoBaseColumn.SetSortGlpyhAlign(Value: TEasySortGlyphAlign);
begin
  if Value <> FSortGlyphAlign then
  begin
    FSortGlyphAlign := Value;
    OwnerListview.Header.Invalidate(False);
  end
end;

procedure TEasyPaintInfoBaseColumn.SetSortGlyphIndent(Value: Integer);
begin
  if Value <> FSortGlyphIndent then
  begin
    FSortGlyphIndent := Value;
    OwnerListview.Header.Invalidate(False)
  end
end;

procedure TEasyPaintInfoBaseColumn.SetStyle(Value: TEasyHeaderButtonStyle);
begin
  if Value <> FStyle then
  begin
    FStyle := Value;
    OwnerListview.Header.Invalidate(False)
  end
end;

{ TEasyViewReportItem}
function TEasyViewReportItem.AllowDrag(Item: TEasyItem; ViewportPoint: TPoint): Boolean;
var
  RectArray: TEasyRectArrayObject;
  R: TRect;
begin
  if FullRowSelect then
  begin
    ItemRectArray(Item, nil, OwnerListview.ScratchCanvas, Item.Caption, RectArray);
    UnionRect(R, RectArray.TextRect, RectArray.IconRect);
    if Item.Selected and Windows.PtInRect(R, ViewportPoint) then
      Result := True
    else
      Result := False
  end else
    Result := inherited AllowDrag(Item, ViewportPoint);
end;


function TEasyViewReportItem.CalculateDisplayRect(Item: TEasyItem;
  Column: TEasyColumn): TRect;
begin
  Result := Item.DisplayRect;
  if Assigned(Column) then
  begin
    Result.Left := Column.DisplayRect.Left;
    Result.Right := Column.DisplayRect.Right;

    if Column.Position = 0 then
      Result.Left := Item.OwnerGroup.MarginLeft.RuntimeSize;
    if Column.Position = Column.OwnerColumns.Count - 1 then
      Result.Right := Result.Right - Item.OwnerGroup.MarginRight.RuntimeSize
  end
end;

function TEasyViewReportItem.ExpandTextR(Item: TEasyItem; RectArray: TEasyRectArrayObject; SelectType: TEasySelectHitType): TRect;
begin
  Result := inherited ExpandTextR(Item, RectArray, SelectType);
  // If dragging and dropping only concider the basic ReportView item as the drop target.
  if FullRowSelect and not Assigned(OwnerListview.DragManager.DragItem) {and (SelectType = eshtClickselect)} then
  begin
    Result.Left := Item.OwnerGroup.MarginLeft.RunTimeSize;
    Result.Right := Item.DisplayRect.Right;
  end
end;

function TEasyViewReportItem.FullRowSelect: Boolean;
begin
  Result := False;
  if Assigned(OwnerListview) then
    Result := OwnerListview.Selection.FullRowSelect
end;

function TEasyViewReportItem.SelectionHit(Item: TEasyItem; SelectViewportRect: TRect; SelectType: TEasySelectHitType): Boolean;
var
  R: TRect;
  RectArray: TEasyRectArrayObject;
begin
  Result := False;
  if Item.Enabled and not IsRectEmpty(SelectViewportRect) then
  begin
    // Selection is always based on the first column
    ItemRectArray(Item, OwnerListview.Header.FirstColumn, OwnerListview.ScratchCanvas, '', RectArray);
    Result := IntersectRect(R, SelectViewportRect, ExpandTextR(Item, RectArray, SelectType)) or
              IntersectRect(R, SelectViewportRect, ExpandIconR(Item, RectArray, SelectType))
  end
end;

function TEasyViewReportItem.SelectionHitPt(Item: TEasyItem; ViewportPoint: TPoint; SelectType: TEasySelectHitType): Boolean;
var
  RectArray: TEasyRectArrayObject;
begin
  Result := False;
  if Item.Enabled then
  begin
    // Selection is always based on the first column
    ItemRectArray(Item, OwnerListview.Header.FirstColumn, OwnerListview.ScratchCanvas, '', RectArray);
    Result := Windows.PtInRect(ExpandTextR(Item, RectArray, SelectType), ViewportPoint) or
              Windows.PtInRect(ExpandIconR(Item, RectArray, SelectType), ViewportPoint)
  end
end;

{ TEasyHintWindow }
constructor TEasyHintWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {$IFDEF GXDEBUG_HINT}
  SendDebug('TEasyHintWindow.Create');
  {$ENDIF GXDEBUG_HINT}
end;


destructor TEasyHintWindow.Destroy;
begin
  {$IFDEF GXDEBUG_HINT}
  SendDebug('TEasyHintWindow.Destroy');
  {$ENDIF GXDEBUG_HINT}
  inherited Destroy;
end;

procedure TEasyHintWindow.ActivateHint(ARect: TRect; const AHint: string);
begin
  {$IFDEF GXDEBUG_HINT}
  SendDebug('TEasyHintWindow.ActivateHint');
  {$ENDIF GXDEBUG_HINT}
  inherited;
end;

procedure TEasyHintWindow.ActivateHintData(ARect: TRect;
  const AHint: string; AData: Pointer);
begin
  {$IFDEF GXDEBUG_HINT}
  SendDebug('TEasyHintWindow.ActivateHintData');
  {$ENDIF GXDEBUG_HINT}
  inherited;
end;

function TEasyHintWindow.CalcHintRect(MaxWidth: Integer;
  const AHint: string; AData: Pointer): TRect;
var
  TextFlags: TCommonDrawTextWFlags;
begin
  {$IFDEF GXDEBUG_HINT}
  SendDebug('TEasyHintWindow.CalcHintRect');
  {$ENDIF GXDEBUG_HINT}
  // We passed in our HintInfo through the AData parameter
  HintInfo := PEasyHintInfoRec(AData);

  EasyHintInfo := HintInfo.Listview.HintInfo;

  EasyHintInfo.FCanvas := Canvas;
  EasyHintInfo.FHintType := HintInfo.HintType;
  EasyHintInfo.FText := HintInfo.HintStr;
  EasyHintInfo.FColor := HintInfo.HintColor;
  EasyHintInfo.FCursorPos := HintInfo.CursorPos;
  EasyHintInfo.FHideTimeout := HintInfo.HideTimeout;
  EasyHintInfo.FMaxWidth := HintInfo.HintMaxWidth;
  EasyHintInfo.FReshowTimeout := HintInfo.ReshowTimeout;
  EasyHintInfo.FWindowPos := HintInfo.HintPos;

  EasyHintInfo.FBounds := Rect(0, 0, MaxWidth, 0);

  HintInfo.Listview.DoHintCustomInfo(HintInfo.TargetObj, EasyHintInfo);

  HintInfo.HintStr := FEasyHintInfo.Text;
  HintInfo.HintType := EasyHintInfo.FHintType;
  HintInfo.HintColor := EasyHintInfo.FColor;
  HintInfo.CursorPos := EasyHintInfo.FCursorPos;
  HintInfo.HideTimeout := EasyHintInfo.FHideTimeout;
  HintInfo.HintMaxWidth := EasyHintInfo.FMaxWidth;
  HintInfo.ReshowTimeout := EasyHintInfo.FReshowTimeout;
  HintInfo.HintPos := EasyHintInfo.FWindowPos;


  if (HintInfo.HintType = ehtText) or (HintInfo.HintType = ehtToolTip) then
  begin
    TextFlags := [dtLeft, dtCalcRect, dtCalcRectAdjR, dtWordBreak];
    DrawTextWEx(Canvas.Handle, HintInfo.HintStr, EasyHintInfo.FBounds, TextFlags, -1);
    Inc(EasyHintInfo.FBounds.Right, 6);
    Inc(EasyHintInfo.FBounds.Bottom, 2)
  end;

  Result := EasyHintInfo.FBounds;
end;

function TEasyHintWindow.IsHintMsg(var Msg: TMsg): Boolean;
begin
  {$IFDEF GXDEBUG_HINT}
//  SendDebug('TEasyHintWindow.IsHintMsg');
  {$ENDIF GXDEBUG_HINT}
  Result := inherited IsHintMsg(Msg)
end;

procedure TEasyHintWindow.Paint;
var
  TextFlags: TCommonDrawTextWFlags;
  R: TRect;
begin
  {$IFDEF GXDEBUG_HINT}
  SendDebug('TEasyHintWindow.IsHintMsg');
  {$ENDIF GXDEBUG_HINT}
  if HintInfo.HintType <> ehtCustomDraw then
  begin
    TextFlags := [dtCenter, dtVCenter];
    R := FEasyHintInfo.Bounds;
    DrawTextWEx(Canvas.Handle, HintInfo.HintStr, R, TextFlags, -1);
  end else
  begin
    R := ClientRect;
    InflateRect(R, -2, -2);
    HintInfo.Listview.DoHintCustomDraw(HintInfo.TargetObj, FEasyHintInfo)
  end
end;

{ TEasySortManager }

constructor TEasySortManager.Create(AnOwner: TCustomEasyListview);
begin
  inherited Create(AnOwner);
  FAlgorithm := esaMergeSort;
  FSorter := TEasyMergeSort.Create(Self);
end;

destructor TEasySortManager.Destroy;
begin
  FreeAndNil(FSorter);
  inherited Destroy;
end;

function TEasySortManager.CollectionSupportsInterfaceSorting(Collection: TEasyCollection): Boolean;
var
  i: Integer;
begin
  Result := True;
  i := 0;
  while (i < Collection.Count) and Result do
  begin
     Result := CommonSupports(Collection[i].DataInf, IEasyCompare);
     Inc(i)
  end
end;

procedure TEasySortManager.BeginUpdate;
begin
  InterlockedIncrement(FUpdateCount);
end;

procedure TEasySortManager.EndUpdate;
begin
  InterlockedDecrement(FUpdateCount);
  if (UpdateCount <= 0) and AutoSort then
  begin
    UpdateCount := 0;
    SortAll
  end
end;

procedure TEasySortManager.GroupItem(Item: TEasyItem; ColumnIndex: Integer;
  Key: LongWord);
//
// WARNING:  Do not access the items OwnerListview property as it is an orphaned
// item when it is passed to this method (the collection property is nil)
//
var
  i: Integer;
  Done, DefaultAction: Boolean;
  Groups: TEasyGroups;
  Group: TEasyGroup;
begin
  i := 0;
  Done := False;
  Groups := OwnerListview.Groups;
  while not Done and (i < Groups.Count) do
  begin
    if Key = Groups[i].Key then
    begin
      Groups[i].Items.List.Add(Item);
      Item.FCollection := Groups[i].Items;
      Done := True;
    end;
    Inc(i)
  end;
  if not Done then
  begin
    Group := nil;
    DefaultAction := True;
    OwnerListview.DoAutoSortGroupCreate(Item, ColumnIndex, Groups, Group, DefaultAction);

    if DefaultAction then
    begin
      if Key > 0 then
        Group.Caption := UpperCase( WideChar(Key))
    end;

    Group.Key := Key;
    Group.Items.List.Add(Item);
    Item.FCollection := Groups[i].Items;
  end
end;

procedure TEasySortManager.ReGroup(Column: TEasyColumn);
var
  Groups: TEasyGroups;
  Item: TEasyItem;
  i, j, ColumnIndex, Index: Integer;
  Key: Integer;
  Caption: WideString;
begin
  OwnerListview.BeginUpdate;
  try
    if Assigned(Column) then
      ColumnIndex := Column.Index
    else
      ColumnIndex := 0;
    // Move the items into a temporary storage structure
    Groups := OwnerListview.Groups;
    SetLength(FSortList, Groups.ItemCount);
    Index := 0;
    for i := 0 to Groups.Count - 1 do
      for j := 0 to Groups[i].ItemCount - 1 do
      begin
        Item := Groups[i][j];
        if OwnerListview.Sort.AutoRegroup then
        begin
          SortList[Index].Key := $FFFF;
          OwnerListview.DoAutoGroupGetKey(Item, ColumnIndex, Groups, SortList[Index].Key);
          if SortList[Index].Key = $FFFF then
          begin
            Caption := Item.Caption;
            if Length(Caption) = 0 then
              SortList[Index].Key := 0
            else
              SortList[Index].Key := Ord(WideLowerCase(Caption)[1])
          end else
            Item.GroupKey[ColumnIndex] := SortList[Index].Key;
        end;
        SortList[Index].Item := Item;
        Item.FCollection := nil; // Orphan the item from the collection
        Groups[i].Item[j] := nil;
        Inc(Index)
      end;
    for i := 0 to Groups.Count - 1 do
      Groups[i].FItems.FList.Pack;
    // Clear the control of items
    Groups.Clear;

    for i := 0 to Length(SortList) - 1 do
    begin
      Item := TEasyItem( SortList[i].Item);
      Key := SortList[i].Key;
      GroupItem(Item, ColumnIndex, Key);
    end;
    OwnerListview.Sort.SortAll;
  finally
    // done with SortList
    SetLength(FSortList, 0);
    OwnerListview.EndUpdate(True)
  end
end;

procedure TEasySortManager.SetAlgorithm(Value: TEasySortAlgorithm);
begin
  if FAlgorithm <> Value then
  begin
    FreeAndNil(FSorter);
    case Value of
      esaQuicksort: FSorter := TEasyQuicksort.Create(Self);
      esaBubbleSort: FSorter := TEasyBubbleSort.Create(Self);
      esaMergeSort: FSorter := TEasyMergeSort.Create(Self);
    end;
    FAlgorithm := Value
  end
end;

procedure TEasySortManager.SetAutoRegroup(Value: Boolean);
begin
  if Value <> FAutoRegroup then
  begin
    OwnerListview.BeginUpdate;
    try
      OwnerListview.ShowGroupMargins := Value;
      FAutoRegroup := Value;
      ReGroup(OwnerListview.Selection.FocusedColumn);
    finally
      OwnerListview.EndUpdate(True);
    end
  end
end;

procedure TEasySortManager.SetAutoSort(Value: Boolean);
begin
  if Value <> FAutoSort then
  begin
    FAutoSort := Value;
    if not Assigned(OwnerListview.Selection.FocusedColumn) then
      OwnerListview.Selection.FocusedColumn := OwnerListview.Header.FirstColumn;
    if Value then
      SortAll
  end
end;

procedure TEasySortManager.SortAll(Force: Boolean = False);
var
  i: Integer;
  SupportsInterfaces: Boolean;
begin
  if Assigned(Sorter) and Assigned(OwnerListview) and (((OwnerListview.UpdateCount = 0) and (UpdateCount = 0) and not LockoutSort) or Force) then
  begin
    SupportsInterfaces := CollectionSupportsInterfaceSorting(OwnerListview.Groups);
    Sorter.Sort(nil, OwnerListview.Groups, 0, OwnerListview.Groups.Count - 1, OwnerListview.DoGroupCompare, nil, SupportsInterfaces);
    for i := 0 to OwnerListview.Groups.Count - 1 do
    begin
      SupportsInterfaces := CollectionSupportsInterfaceSorting(OwnerListview.Groups[i].Items);
      Sorter.Sort(OwnerListview.GetSortColumn, OwnerListview.Groups[i].Items, 0, OwnerListview.Groups[i].ItemCount - 1, nil, OwnerListview.DoItemCompare, SupportsInterfaces);
    end;
    if not (egsRebuilding in OwnerListview.Groups.GroupsState) then
      OwnerListview.Groups.Rebuild(True)
  end
end;

{ TEasyQuicksort}
procedure TEasyQuicksort.Sort(Column: TEasyColumn; Collection: TEasyCollection; Min, Max: Integer; GroupCompare: TEasyDoGroupCompare; ItemCompare: TEasyDoItemCompare; UseInterfaces: Boolean);
var
 I, J: Integer;
 P, Temp: TEasyCollectionItem;
begin
  // Quicksort is not Stable, i.e. duplicate items may not be in the same
  // order with each pass of the sort.
  if Max > Collection.Count - 1 then
    Max := Collection.Count - 1;

  if Max > Min then
  begin
    repeat
      I := Min;
      J := Max;
      P := Collection.Items[(Min + Max) shr 1];
      repeat
        if UseInterfaces then
        begin
          while (P.DataInf as IEasyCompare).Compare(Collection.Items[I].DataInf, Column) < 0 do
              Inc(I);
          while (P.DataInf as IEasyCompare).Compare(Collection.Items[J].DataInf, Column) > 0 do
              Dec(J);
        end else
        if Assigned(GroupCompare) then
        begin
          while GroupCompare(Column, TEasyGroup(Collection.Items[I]), TEasyGroup(P)) < 0 do
            Inc(I);
          while GroupCompare(Column, TEasyGroup(Collection.Items[J]), TEasyGroup(P)) > 0 do
            Dec(J);
        end else
        if Assigned(ItemCompare) then
        begin
          while ItemCompare(Column, TEasyItems(Collection).OwnerGroup, TEasyItem(Collection.Items[I]), TEasyItem(P)) < 0 do
            Inc(I);
          while ItemCompare(Column, TEasyItems(Collection).OwnerGroup, TEasyItem(Collection.Items[J]), TEasyItem(P)) > 0 do
            Dec(J);
        end else
        begin
          while DefaultSort(Column, Collection.Items[I], P) < 0 do
            Inc(I);
          while DefaultSort(Column, Collection.Items[J], P) > 0 do
            Dec(J);
        end;
        if I <= J then
        begin
          Temp := Collection.Items[I];
          Collection.Items[I] := Collection.Items[J];
          Collection.Items[J] := Temp;
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if Min < J then Sort(Column, Collection, Min, J, GroupCompare, ItemCompare, UseInterfaces);
        Min := I;
    until I >= Max;
  end
end;

{ TEasyBubbleSort}
procedure TEasyBubbleSort.Sort(Column: TEasyColumn; Collection: TEasyCollection; Min, Max: Integer; GroupCompare: TEasyDoGroupCompare; ItemCompare: TEasyDoItemCompare; UseInterfaces: Boolean);
var
  LastSwap, i, j, SortResult : Integer;
  Tmp: TEasyCollectionItem;
begin
  // During this loop, min and max are the smallest and largest
  // indexes of items that might still be out of order.

  // Repeat until we are done.
  while (Min < Max) do
  begin
    // Bubble up.
    LastSwap := Min - 1;
    // for i := min + 1 to max
    i := min + 1;
    while (i <= Max) do
    begin
      // Find a bubble.
      if UseInterfaces then
        SortResult := (Collection.Items[i].DataInf as IEasyCompare).Compare(Collection.Items[i - 1].DataInf, Column)
      else
      if Assigned(GroupCompare) then
        SortResult := GroupCompare(Column, TEasyGroup(Collection.Items[i - 1]), TEasyGroup(Collection.Items[i]))
      else
      if Assigned(ItemCompare) then
        SortResult := ItemCompare(Column, TEasyItems(Collection).OwnerGroup, TEasyItem(Collection.Items[i - 1]), TEasyItem(Collection.Items[i]))
      else
        SortResult := DefaultSort(Column, Collection.Items[i - 1], Collection.Items[i]);

      if SortResult > 0 then
      begin
        // See where to drop the bubble.
        Tmp := Collection.Items[i - 1];
        j := i;
        repeat
          Collection.Items[j - 1] := Collection.Items[j];
          j := j + 1;
          if (j > max) then
            Break;

          if UseInterfaces then
            SortResult := (Tmp.DataInf as IEasyCompare).Compare(Collection.Items[j].DataInf, Column)
          else
          if Assigned(GroupCompare) then
            SortResult := GroupCompare(Column, TEasyGroup(Collection.Items[j]), TEasyGroup(Tmp))
          else
          if Assigned(ItemCompare) then
            SortResult := ItemCompare(Column, TEasyItems(Collection).OwnerGroup, TEasyItem(Collection.Items[j]), TEasyItem(Tmp))
          else
            SortResult := DefaultSort(Column, Collection.Items[j], Tmp);

        until SortResult >= 0;
        Collection.Items[j - 1] := Tmp;
        LastSwap := j - 1;
        i := j + 1;
      end else
        i := i + 1;
    end;
    // End bubbling up.

    // Update max.
    Max := LastSwap - 1;

    // Bubble down.
    LastSwap := Max + 1;
    // for i := max - 1 downto min
    i := Max - 1;
    while (i >= Min) do
    begin
      // Find a bubble.
      if UseInterfaces then
        SortResult := (Collection.Items[i].DataInf as IEasyCompare).Compare(Collection.Items[i + 1].DataInf, Column)
      else
      if Assigned(GroupCompare) then
        SortResult := GroupCompare(Column, TEasyGroup(Collection.Items[i + 1]), TEasyGroup(Collection.Items[i]))
      else
      if Assigned(ItemCompare) then
        SortResult := ItemCompare(Column, TEasyItems(Collection).OwnerGroup, TEasyItem(Collection.Items[i + 1]), TEasyItem(Collection.Items[i]))
      else
        SortResult := DefaultSort(Column, Collection.Items[i + 1], Collection.Items[i]);

      if SortResult < 0 then
      begin
        // See where to drop the bubble.
        Tmp := Collection.Items[i + 1];
        j := i;
        repeat
          Collection.Items[j + 1] := Collection.Items[j];
          j := j - 1;
          if j < Min then
            Break;

          if UseInterfaces then
            SortResult := (Tmp.DataInf as IEasyCompare).Compare(Collection.Items[j].DataInf, Column)
          else
          if Assigned(GroupCompare) then
            SortResult := GroupCompare(Column, TEasyGroup(Collection.Items[j]), TEasyGroup(Tmp))
          else
          if Assigned(ItemCompare) then
            SortResult := ItemCompare(Column, TEasyItems(Collection).OwnerGroup, TEasyItem(Collection.Items[j]), TEasyItem(Tmp))
          else
            SortResult := DefaultSort(Column, Collection.Items[j], Tmp);

        until SortResult <= 0;
        Collection.Items[j + 1] := Tmp;
        LastSwap := j + 1;
        i := j - 1;
      end else
          i := i - 1;
    end;
    // End bubbling down.

    // Update min.
    Min := LastSwap + 1;
  end;
end;

{ TEasyMergeSort }
function TEasyMergeSort.CompareDefault(i1, i2: TEasyCollectionItem): Boolean;
begin
  Result := DefaultSort(Column, i1, i2) <= 0;
end;

function TEasyMergeSort.CompareGroup(i1, i2: TEasyCollectionItem): Boolean;
begin
  Result := GroupCompareFunc(Column, TEasyGroup(i1), TEasyGroup(i2)) <= 0;
end;

function TEasyMergeSort.CompareInterfaces(i1, i2: TEasyCollectionItem): Boolean;
begin
  Result:=(i2.DataInf as IEasyCompare).Compare(i1.DataInf, Column) <= 0;
end;

function TEasyMergeSort.CompareItem(i1, i2: TEasyCollectionItem): Boolean;
begin
  Result := ItemCompareFunc(Column, OwnerGroup, TEasyItem(i1), TEasyItem(i2)) <= 0;
end;

procedure TEasyMergeSort.Sort(Column: TEasyColumn; Collection: TEasyCollection; Min, Max: Integer; GroupCompare: TEasyDoGroupCompare; ItemCompare: TEasyDoItemCompare; UseInterfaces: Boolean);
type
  TEasyMergeSortCompare=function (i1, i2: TEasyCollectionItem): Boolean of object;
var
  CompareFunc: TEasyMergeSortCompare;

  procedure subMerge(dst: TEasyCollection; ld, md, hd: Integer; src: TEasyCollection; ls, ms: Integer);
  { dst    src
  hd
    aa
  md      ms
    xx      bb     bb+aa->xxaa
  ld      ls }
  var
    i, j, d: Integer;
  begin
    i := ls;
    j := md;
    d := ld;
    while i< ms do
      begin
        if (j = hd) or (compareFunc(src[i], dst[j])) then
          begin
            dst[d] := src[i];
            Inc(i);
          end
        else
          begin
            dst[d] := dst[j];
            Inc(j);
          end;
        Inc(d);
      end;
  end;

  procedure subSortM(dst: TEasyCollection; ld, hd: Integer; src: TEasyCollection; ls, hs: Integer); forward;

  procedure subSortI(dst: TEasyCollection; ld, hd: Integer; tmp: TEasyCollection; lt, ht: Integer);
  var
    m2: Integer; //I for Inplace
    x3: Pointer;
  { -  hd
    |     A               inplace AA->AA
    m2    A    ht         move    bbb->ccc
          b       c       merge   ccc+AA->bbbAA
          b       c
       ld b    lt c       ht-lt>=hd-m2-ld !    }
  begin
    if (hd >= ld + 3) then
      begin
        m2 := (hd - ld) div 2;
        subSortI(dst, hd-m2, hd, tmp, lt, lt + m2);             //sort random AA->sorted AA, using cc as scratchpad
        subSortM(tmp, lt, lt+(hd-ld-m2), dst, ld, hd  -m2);     //sort random bbb->sorted ccc
        subMerge(dst, ld, hd - m2, hd, tmp, lt, lt + (hd - ld - m2)); //merge sorted ccc+sorted AA->bbbAA
      end
    else if (hd = ld + 2) then
      begin
        if not compareFunc(dst[ld], dst[ld + 1]) then
          begin
            x3 := dst[ld];
            dst[ld] := dst[ld + 1];
            dst[ld + 1] := x3;
          end;
      end;
  end;

  procedure subSortM(dst: TEasyCollection; ld, hd: Integer; src: TEasyCollection; ls, hs: Integer);
  var m2: Integer; //M for Move
  {  hd      hs                    hd      hs
        c       A                     c       b
        c       A                     c       b
  m2    c       a                  m2 c       A
        d       b                     d       a
     ld d    ls b                  ld d    ls a      }
  begin
    if (hs >= ls + 3) then
      begin
        m2 := (hs - ls) div 2;
        subSortM(dst, ld  +m2, hd, src, ls + m2, hs);     //sort random aAA->sorted ccc
        subSortI(src, ls, ls + m2, dst, ld, ld + m2);     //sort random bb->sorted bb, using dd as scratchpad
        subMerge(dst, ld, ld + m2, hd, src, ls, ls + m2); //merge bb+ccc->ddccc
      end
    else if (hs = ls + 2) then
      begin
        if not compareFunc(src[ls], src[ls+1]) then
          begin
            dst[ld] := src[ls + 1];
            dst[ld+1] := src[ls];
          end
        else
          begin
            dst[ld] := src[ls];
            dst[ld + 1] := src[ls + 1];
          end
      end
    else if (hs = ls + 1) then
      dst[ld] := src[ls];
  end;

var m: Integer;
    TempList: TEasyCollection;
begin
  if Max > Collection.Count - 1 then
    Max := Collection.Count - 1;
  if (Max <= Min) then
    Exit;

  Self.Column := Column;
  OwnerGroup := TEasyItems(Collection).OwnerGroup;
  GroupCompareFunc := GroupCompare;
  ItemCompareFunc := ItemCompare;

  TempList := TEasyCollection.Create(nil);
  m:=(Max - Min + 2) div 2;
  TempList.List.Capacity := m;
  TempList.List.Count := m;

  if (UseInterfaces) then
    CompareFunc := CompareInterfaces
  else if Assigned(GroupCompareFunc) then
    CompareFunc := CompareGroup
  else if Assigned(ItemCompareFunc) then
    CompareFunc := CompareItem
  else
    CompareFunc := CompareDefault;

  subSortI(Collection, Min, Max + 1, TempList, Min, (Min + Max + 2) div 2);

  TempList.List.Count := 0;
  TempList.List.Capacity := 0;
  FreeAndNil(TempList);
end;

{ TEasyStringEditor }

function TEasyBaseEditor.AcceptEdit: Boolean;
var
  WS: Variant;
begin
  Result := True;
  WS := GetText;
  Listview.DoItemEdited(Item, WS, Result);
  if Result then
  begin
    Item.Captions[EditColumn.Index] := WS;
    Listview.EditManager.EndEdit
  end
end;

function TEasyBaseEditor.GetEditor: TWinControl;
begin
  Result := FEditor;
end;

function TEasyBaseEditor.GetListview: TCustomEasyListview;
begin
  Result := nil;
  if Assigned(Item) then
    Result := Item.OwnerListview
end;

function TEasyBaseEditor.GetModified: Boolean;
begin
  Result := Modified
end;

function TEasyBaseEditor.PtInEditControl(WindowPt: TPoint): Boolean;
begin
  Result := PtInRect(Editor.BoundsRect, WindowPt)
end;

procedure TEasyBaseEditor.ControlWndHookProc(var Message: TMessage);
//
// Window procedure hook for the Edit box, allows autosizing of edit during user
// input
//
begin
  case Message.Msg of
  WM_EDITORRESIZE:
    begin
      ResizeEditor;
    end;
    WM_CHAR:
      begin
        if Message.WParam = VK_TAB then
          Message.WParam := Ord(' ');
      end;
  end;
  FOldWndProc(Message)
end;

function TEasyBaseEditor.EditText(Item: TEasyItem; Column: TEasyColumn): WideString;
begin
  Result := '';
  Column.OwnerListview.DoItemGetEditCaption(Item, Column, Result);
  if Result = '' then
    Result := Item.Captions[Column.Index]
end;

procedure TEasyBaseEditor.Finalize;
begin
  EditColumn := nil;
  Editor.WindowProc := OldWndProc;
  Editor.Free
end;

procedure TEasyBaseEditor.Hide;
begin
  Editor.Visible := False
end;

procedure TEasyBaseEditor.Initialize(AnItem: TEasyItem; Column: TEasyColumn);
begin
  FItem := AnItem;
  FEditColumn := Column;
  CreateEditor(FEditor, Column);
  Editor.Visible := False;
  OldWndProc := Editor.WindowProc;
  Editor.WindowProc := ControlWndHookProc;
  Editor.Parent := Listview;
  Editor.DoubleBuffered := True;
  GetEditorFont.Assign(Listview.Font);
  Item.ItemRectArray(Column, AnItem.OwnerListview.ScratchCanvas, FRectArray);
  ResizeEditor;
  SetWindowLong(Editor.Handle, GWL_EXSTYLE, GetWindowLong(Editor.Handle, GWL_EXSTYLE) or WS_EX_TOPMOST);
end;

procedure TEasyBaseEditor.ResizeEditor;
var
  R: TRect;
begin
  CalculateEditorRect(GetText, R);
  Editor.SetBounds(R.Left,
    R.Top,
    RectWidth(R),
    RectHeight(R));
end;

procedure TEasyBaseEditor.SetEditor(const Value: TWinControl);
begin
  FEditor := Value;
end;

procedure TEasyBaseEditor.SetEditorFocus;
begin
  Editor.SetFocus;
end;

procedure TEasyBaseEditor.Show;
begin
  Editor.Visible := True;

end;

{ TEasySelectionGroupList }

constructor TEasySelectionGroupList.Create;
begin
  FList := TList.Create
end;

destructor TEasySelectionGroupList.Destroy;
begin
  FreeAndNil(FList);
  inherited
end;

function TEasySelectionGroupList.Count: Integer;
begin
  Result := List.Count
end;

function TEasySelectionGroupList.GetItems(Index: Integer): TEasyItem;
begin
  Result := TEasyItem( List.Items[Index])
end;

procedure TEasySelectionGroupList.Add(Item: TEasyItem);
begin
  List.Add(Item)
end;

procedure TEasySelectionGroupList.Clear;
begin
  List.Clear
end;

procedure TEasySelectionGroupList.DecRef;
begin
  Dec(FRefCount);
  if FRefCount = 0 then
    Destroy
end;

procedure TEasySelectionGroupList.IncRef;
begin
  Inc(FRefCount)
end;

procedure TEasySelectionGroupList.SetItems(Index: Integer; Value: TEasyItem);
begin
  List.Items[Index] := Value
end;

{ TEasyGridIconGroup }

function TEasyGridIconGroup.GetCellSize: TEasyCellSize;
begin
  Result := OwnerListview.CellSizes.Icon
end;

procedure TEasyGridIconGroup.SetCellSize(Value: TEasyCellSize);
begin
  OwnerListview.CellSizes.Icon.Assign(Value)
end;

{ TEasyGridSmallIconGroup }

function TEasyGridSmallIconGroup.GetCellSize: TEasyCellSize;
begin
  Result := OwnerListview.CellSizes.SmallIcon
end;

procedure TEasyGridSmallIconGroup.SetCellSize(Value: TEasyCellSize);
begin
  OwnerListview.CellSizes.SmallIcon.Assign(Value)
end;

{ TEasyGridThumbnailGroup }

function TEasyGridThumbnailGroup.GetCellSize: TEasyCellSize;
begin
  Result := OwnerListview.CellSizes.Thumbnail
end;

procedure TEasyGridThumbnailGroup.SetCellSize(Value: TEasyCellSize);
begin
  OwnerListview.CellSizes.Thumbnail.Assign(Value)
end;

{ TEasyGridTileGroup }

function TEasyGridTileGroup.GetCellSize: TEasyCellSize;
begin
  Result := OwnerListview.CellSizes.Tile
end;

procedure TEasyGridTileGroup.SetCellSize(Value: TEasyCellSize);
begin
  OwnerListview.CellSizes.Tile.Assign(Value)
end;

{ TEasyItemInterfaced}
function TEasyItemInterfaced.GetCaptions(Column: Integer): Widestring;
var
  CaptionInf: IEasyCaptions;
begin
  CaptionInf := nil;
  if Supports(DataInf, IEasyCaptions, CaptionInf) then
    Result := CaptionInf.Captions[Column]
end;

function TEasyItemInterfaced.GetDetailCount: Integer;
var
  TileInf: IEasyDetails;
begin
  Result := 1;
  TileInf := nil;
  if Supports(DataInf, IEasyDetails, TileInf) then
    Result := TileInf.GetDetailCount
end;

function TEasyItemInterfaced.GetDetails(Line: Integer): Integer;
var
  TileInf: IEasyDetails;
begin
  Result := 0;
  TileInf := nil;
  if Supports(DataInf, IEasyDetails, TileInf) then
    Result := TileInf.Detail[Line]
end;

function TEasyItemInterfaced.GetGroupKey(FocusedColumn: Integer): LongWord;
var
  KeyInf: IEasyGroupKey;
begin
  Result := 0;
  KeyInf := nil;
  if Supports(DataInf, IEasyGroupKey, KeyInf) then
    Result := KeyInf.Key[FocusedColumn]
end;

function TEasyItemInterfaced.GetImageIndexes(Column: Integer): Integer;
var
  ImageInf: IEasyImages;
begin
  Result := -1;
  ImageInf := nil;
  if Supports(DataInf, IEasyImages, ImageInf) then
    Result := ImageInf.ImageIndexes[Column, eikNormal]
end;

function TEasyItemInterfaced.GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList;
var
  ImageList: IEasyImageList;
begin
  Result := nil;
  if Supports(DataInf, IEasyImageList, ImageList) then
    Result := ImageList.ImageList[Column, IconSize];
  if not Assigned(Result) then
    Result := DefaultImageList(IconSize)
end;

function TEasyItemInterfaced.GetImageOverlayIndexes(Column: Integer): Integer;
var
  ImageInf: IEasyImages;
begin
  Result := -1;
  ImageInf := nil;
  if Supports(DataInf, IEasyImages, ImageInf) then
    Result := ImageInf.ImageIndexes[Column, eikOverlay]
end;

procedure TEasyItemInterfaced.ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
var
  ImageInf: IEasyCustomImage;
begin
  if Supports(DataInf, IEasyCustomImage, ImageInf) then
    ImageInf.DrawImage(Column, ACanvas, RectArray, AlphaBlender)
end;

procedure TEasyItemInterfaced.ImageDrawGetSize(Column: TEasyColumn; var ImageW, ImageH: Integer);
var
  ImageInf: IEasyCustomImage;
begin
  if Supports(DataInf, IEasyCustomImage, ImageInf) then
    ImageInf.GetSize(Column, ImageW, ImageH)
end;

procedure TEasyItemInterfaced.ImageDrawIsCustom(Column: TEasyColumn;
  var IsCustom: Boolean);
var
  ImageInf: IEasyCustomImage;
begin
  IsCustom := False;
  if Supports(DataInf, IEasyCustomImage, ImageInf) then
    ImageInf.CustomDrawn(Column, IsCustom)
end;

procedure TEasyItemInterfaced.SetCaptions(Column: Integer; Value: Widestring);
var
  CaptionInf: IEasyCaptionsEditable;
begin
  CaptionInf := nil;
  if Supports(DataInf, IEasyCaptionsEditable, CaptionInf) then
  begin
    CaptionInf.SetCaption(Column, Value);
    Invalidate(False)
  end
end;

procedure TEasyItemInterfaced.SetDetailCount(Value: Integer);
var
  DetailsInf: IEasyDetailsEditable;
begin
  DetailsInf := nil;
  if Supports(DataInf, IEasyDetailsEditable, DetailsInf) then
  begin
    DetailsInf.DetailCount := Value;
    Invalidate(False)
  end
end;

procedure TEasyItemInterfaced.SetDetails(Line: Integer; Value: Integer);
var
  DetailsInf: IEasyDetailsEditable;
begin
  DetailsInf := nil;
  if Supports(DataInf, IEasyDetailsEditable, DetailsInf) then
  begin
    DetailsInf.Detail[Line] := Value;
    Invalidate(False)
  end
end;

procedure TEasyItemInterfaced.SetGroupKey(FocusedColumn: Integer;
  Value: LongWord);
var
  KeyInf: IEasyGroupKeyEditable;
begin
  KeyInf := nil;
  if Supports(DataInf, IEasyGroupKeyEditable, KeyInf) then
    KeyInf.Key[FocusedColumn] := Value;
end;

procedure TEasyItemInterfaced.SetImageIndexes(Column: Integer; Value: Integer);
var
  ImageInf: IEasyImagesEditable;
begin
  ImageInf := nil;
  if Supports(DataInf, IEasyImagesEditable, ImageInf) then
  begin
    ImageInf.ImageIndexes[Column, eikNormal] := Value;
    Invalidate(False)
  end
end;

procedure TEasyItemInterfaced.SetImageOverlayIndexes(Column: Integer; Value: Integer);
var
  ImageInf: IEasyImagesEditable;
begin
  ImageInf := nil;
  if Supports(DataInf, IEasyImagesEditable, ImageInf) then
  begin
    ImageInf.ImageIndexes[Column, eikOverlay] := Value;
    Invalidate(False)
  end
end;

procedure TEasyItemInterfaced.ThumbnailDraw(ACanvas: TCanvas; ARect: TRect;
  AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
var
  ThumbInf: IEasyThumbnail;
begin
  if Supports(DataInf, IEasyThumbnail, ThumbInf) then
    ThumbInf.ThumbnailDraw(ACanvas, ARect, AlphaBlender, DoDefault)
end;

{ TEasyItem }

constructor TEasyItem.Create(ACollection: TEasyCollection);
begin
  inherited Create(ACollection);
  FVisibleIndexInGroup := -1;
end;

destructor TEasyItem.Destroy;
begin
  SetDestroyFlags;
  if Assigned(OwnerListview) then
  begin
    if OwnerListview.EditManager.TabMoveFocusItem = Self then
      OwnerListview.EditManager.TabMoveFocusItem := nil;
  end;
  Visible := False;  // will UnSelect and UnFocus if necessary
  inherited;
  ReleaseSelectionGroup;
end;

function TEasyItem.AllowDrag(ViewportPt: TPoint): Boolean;
begin
  Result := View.AllowDrag(Self, ViewportPt)
end;

function TEasyItem.CanChangeBold(NewValue: Boolean): Boolean;
begin
  Result := True
end;

function TEasyItem.CanChangeCheck(NewValue: Boolean): Boolean;
begin
  if Enabled then
  begin
    Result := True;
    OwnerListview.DoItemCheckChanging(Self, Result);
  end
  else
   Result := False;
end;

function TEasyItem.CanChangeEnable(NewValue: Boolean): Boolean;
begin
  Result := True;
  OwnerListview.DoItemEnableChanging(Self, Result)
end;

function TEasyItem.CanChangeFocus(NewValue: Boolean): Boolean;
begin
  Result := True;
  OwnerListview.DoItemFocusChanging(Self, Result)
end;

function TEasyItem.CanChangeHotTracking(NewValue: Boolean): Boolean;
begin
  Result := True
end;

function TEasyItem.CanChangeSelection(NewValue: Boolean): Boolean;
begin
  Result := True;
  OwnerListview.DoItemSelectionChanging(Self, Result)
end;

function TEasyItem.CanChangeVisibility(NewValue: Boolean): Boolean;
begin
  if OwnerGroup.Visible or not NewValue then
  begin
    Result := True;
    OwnerListview.DoItemVisibilityChanging(Self, Result);
  end else
    Result := False
end;

function TEasyItem.EditAreaHitPt(ViewportPoint: TPoint): Boolean;
// Returns true if the passed point is in an area where the Item conciders it a
// place where inplace editing can be activated.
//
begin
  Result := View.EditAreaHitPt(Self, ViewportPoint)
end;

function TEasyItem.GetColumnPos: Integer;
//
// Returns the current column that the item is in within the grid or -1 if it
// is not visible
//
begin
  Result := -1;
  if Visible then
    Result := VisibleIndexInGroup mod OwnerGroup.Grid.ColumnCount
end;

function TEasyItem.GetGroupKey(FocusedColumn: Integer): LongWord;
begin
  Result := 0
end;

function TEasyItem.GetIndex: Integer;
begin
  Result := FIndex
end;

function TEasyItem.GetOwnerGroup: TEasyGroup;
begin
  Result := OwnerItems.OwnerGroup
end;

function TEasyItem.GetOwnerItems: TEasyItems;
begin
  Result := TEasyItems(Collection)
end;

function TEasyItem.GetOwnerView: TEasyViewItem;
begin
  Result := OwnerItems.OwnerGroup.ItemView
end;

function TEasyItem.GetPaintInfo: TEasyPaintInfoItem;
begin
  Result := TEasyPaintInfoItem( inherited PaintInfo)
end;

function TEasyItem.GetRowPos: Integer;
//
// Returns the current column that the item is in within the grid or -1 if it
// is not visible
//
begin
  Result := -1;
  if Visible then
    Result := VisibleIndexInGroup mod OwnerGroup.Grid.RowCount
end;

function TEasyItem.GetView: TEasyViewItem;
begin
  Result := OwnerItems.OwnerGroup.ItemView
end;

function TEasyItem.HitTestAt(ViewportPoint: TPoint; var HitInfo: TEasyItemHitTestInfoSet): Boolean;
var
  RectArray: TEasyRectArrayObject;
  R: TRect;
begin
  HitInfo := [];
  ItemRectArray(OwnerListview.Header.FirstColumn, OwnerListview.ScratchCanvas, RectArray);
  R := RectArray.IconRect;
  // Make the blank area between the image and text part of the image
  if OwnerListview.IsVertView then
     R.Bottom := R.Bottom + OwnerListview.PaintInfoItem.CaptionIndent
  else
    R.Right := R.Right + OwnerListview.PaintInfoItem.CaptionIndent;

  if PtInRect(R, ViewportPoint) then
    Include(HitInfo, ehtOnIcon);
  if PtInRect(RectArray.CheckRect, ViewportPoint) then
    Include(HitInfo, ehtOnCheck);
  if PtInRect(RectArray.FullFocusSelRect, ViewportPoint) then
    Include(HitInfo, ehtOnText);
  if PtInRect(RectArray.LabelRect, ViewportPoint) then
    Include(HitInfo, ehtOnLabel);
  if PtInRect(RectArray.ClickselectBoundsRect, ViewportPoint) then
    Include(HitInfo, ehtOnClickselectBounds);
  if PtInRect(RectArray.DragSelectBoundsRect, ViewportPoint) then
    Include(HitInfo, ehtOnDragSelectBounds);
  if PtInRect(RectArray.DragSelectBoundsRect, ViewportPoint) then
    Include(HitInfo, ehtOnDragSelectBounds);
  if PtInRect(RectArray.StateRect, ViewportPoint) then
    Include(HitInfo, ehtStateIcon);
  Result := HitInfo <> [];
end;

function TEasyItem.LocalPaintInfo: TEasyPaintInfoBasic;
begin
  Result := OwnerListview.PaintInfoItem
end;

function TEasyItem.SelectionHit(SelectViewportRect: TRect; SelectType: TEasySelectHitType): Boolean;
begin
  Result := View.SelectionHit(Self, SelectViewportRect, SelectType)
end;

function TEasyItem.SelectionHitPt(ViewportPoint: TPoint; SelectType: TEasySelectHitType): Boolean;
begin
  Result := View.SelectionHitPt(Self, ViewportPoint, SelectType)
end;

procedure TEasyItem.Edit(Column: TEasyColumn = nil);
begin
  OwnerListview.EditManager.BeginEdit(Self, Column)
end;

procedure TEasyItem.Freeing;
begin
  OwnerListview.DoItemFreeing(Self)
end;

procedure TEasyItem.GainingBold;
begin
  Invalidate(False)
end;

procedure TEasyItem.GainingCheck;
begin
  Inc(OwnerListview.CheckManager.FCount);
  OwnerListview.DoItemCheckChanged(Self);
  Invalidate(False);
end;

procedure TEasyItem.GainingEnable;
begin
  OwnerListview.DoItemEnableChanged(Self);
  Invalidate(False);
end;

procedure TEasyItem.GainingFocus;
begin
  OwnerListview.DoItemFocusChanged(Self);
  OwnerListview.Selection.FocusedItem := Self;
  Invalidate(False);
  if OwnerListview.Selection.GroupSelections then
  begin
    OwnerListview.Selection.BuildSelectionGroupings(False);
    OwnerListview.SafeInvalidateRect(nil, False);
  end
end;

procedure TEasyItem.GainingHilight;
begin
  Invalidate(True);
end;

procedure TEasyItem.GainingHotTracking(MousePos: TPoint);
begin
  OwnerListview.DoItemHotTrack(Self, ehsEnable, MousePos);
  Invalidate(True)
end;

procedure TEasyItem.GainingSelection;
begin
  OwnerListview.Selection.GainingSelection(Self);
  OwnerListview.DoItemSelectionChanged(Self);
  if OwnerListview.Selection.GroupSelections then
  begin
    OwnerListview.Selection.BuildSelectionGroupings(False);
    OwnerListview.SafeInvalidateRect(nil, False);
  end else
    Invalidate(False);
end;

procedure TEasyItem.GainingVisibility;
begin
//  Inc(OwnerGroup.FVisibleCount);
  OwnerListview.Groups.Rebuild;
  OwnerListview.DoItemVisibilityChanged(Self);
end;

procedure TEasyItem.Initialize;
begin
  OwnerListview.DoItemInitialize(Self);
  Include(FState, esosInitialized);
end;

procedure TEasyItem.Invalidate(ImmediateUpdate: Boolean);
var
  RectArray: TEasyRectArrayObject;
  R: TRect;
  Listview: TCustomEasyListview;
begin
  Listview := TEasyCollection( Collection).FOwnerListview;
  if Listview.HandleAllocated then
  begin
    R := Listview.Scrollbars.MapWindowRectToViewRect(Listview.ClientRect, True);
    // This is a bit odd as a long text caption is scrolled off the top of the window
    if IntersectRect(R, R, DisplayRect) then
    begin
      View.ItemRectArray(Self, nil, OwnerListview.ScratchCanvas, '', RectArray);
      UnionRect(R, RectArray.FocusChangeInvalidRect, DisplayRect);
      R := Listview.Scrollbars.MapViewRectToWindowRect(R, True);
      Listview.SafeInvalidateRect(@R, ImmediateUpdate);
    end
  end
end;

procedure TEasyItem.ItemRectArray(Column: TEasyColumn; ACanvas: TCanvas; var RectArray: TEasyRectArrayObject);
begin
  if Assigned(View) then
    View.ItemRectArray(Self, Column, ACanvas, '', RectArray)
  else
    FillChar(RectArray, SizeOf(RectArray), #0)
end;

procedure TEasyItem.LoadFromStream(S: TStream; Version: Integer = STREAM_VERSION);
begin
  inherited LoadFromStream(S);
  OwnerListview.DoItemLoadFromStream(Self, S)
end;

procedure TEasyItem.LosingBold;
begin
  Invalidate(False)
end;

procedure TEasyItem.LosingCheck;
begin
  Dec(OwnerListview.CheckManager.FCount);
  OwnerListview.DoItemCheckChanged(Self);
  if State * [esosDestroying] = [] then
    Invalidate(False);
end;

procedure TEasyItem.LosingEnable;
begin
  ReleaseSelectionGroup;
  OwnerListview.DoItemEnableChanged(Self);
  if State * [esosDestroying] = [] then
    Invalidate(False);
end;

procedure TEasyItem.LosingFocus;
begin
  if OwnerListview.Selection.FocusedItem = Self then
    OwnerListview.Selection.FocusedItem := nil;
  OwnerListview.DoItemFocusChanged(Self);
  // Need to repaint before Losing the focus
  if State * [esosDestroying] = [] then
  begin
    Include(FState, esosFocused);
    Invalidate(False);
    Exclude(FState, esosFocused);
    if OwnerListview.Selection.GroupSelections then
      OwnerListview.SafeInvalidateRect(nil, False);
  end;
end;

procedure TEasyItem.LosingHilight;
begin
  Invalidate(True);
end;

procedure TEasyItem.LosingHotTracking;
begin
  OwnerListview.DoItemHotTrack(Self, ehsDisable, Point(0, 0));
  Invalidate(True)
end;

procedure TEasyItem.LosingSelection;
begin
  OwnerListview.Selection.LosingSelection(Self);
  OwnerListview.DoItemSelectionChanged(Self);
  // Need to repaint before Losing the focus
  if State * [esosDestroying] = [] then
  begin
    if OwnerListview.Selection.GroupSelections then
    begin
      OwnerListview.Selection.BuildSelectionGroupings(False);
      OwnerListview.SafeInvalidateRect(nil, False);
    end else
      Invalidate(False);
  end
end;

procedure TEasyItem.LosingVisibility;
begin
//  Dec(OwnerGroup.FVisibleCount);
  ReleaseSelectionGroup;
  OwnerListview.Groups.Rebuild;
  OwnerListview.DoItemVisibilityChanged(Self);
end;

procedure TEasyItem.MakeVisible(Position: TEasyMakeVisiblePos);
var
  RectArray: TEasyRectArrayObject;
  R: TRect;
begin
  if Visible then
  begin
    View.ItemRectArray(Self, OwnerListview.Header.FirstColumn, OwnerListview.ScratchCanvas, '', RectArray);
    UnionRect(R, RectArray.FullFocusSelRect, RectArray.IconRect); // WL, 01/10/05: bottom line of focus rect was missing if item was made visible at the bottom of the window
    if not ContainsRect(OwnerListview.ClientInViewportCoords, R) then
    begin
      case Position of
        emvTop:
          begin
            OwnerListview.Scrollbars.OffsetY := R.Top;
            OwnerListview.Scrollbars.OffsetX := R.Left;
          end;
        emvMiddle:
          begin
            OwnerListview.Scrollbars.OffsetY := R.Top + OwnerListview.ClientHeight div 2;
            OwnerListview.Scrollbars.OffsetX := R.Left + OwnerListview.ClientWidth div 2;
          end;
        emvBottom:
          begin
            OwnerListview.Scrollbars.OffsetY := R.Bottom - OwnerListview.ClientHeight + OwnerListview.Header.RuntimeHeight;
            OwnerListview.Scrollbars.OffsetX := R.Right - OwnerListview.ClientWidth;
          end;
        emvAuto:
          begin
            if R.Bottom > OwnerListview.ClientInViewportCoords.Bottom then
              OwnerListview.Scrollbars.OffsetY := R.Bottom - OwnerListview.ClientHeight + OwnerListview.Header.RuntimeHeight
            else
            if R.Top < OwnerListview.ClientInViewportCoords.Top then
              OwnerListview.Scrollbars.OffsetY := R.Top;
            if R.Right > OwnerListview.ClientInViewportCoords.Right then
              OwnerListview.Scrollbars.OffsetX := R.Right - OwnerListview.ClientWidth
            else
            if R.Left < OwnerListview.ClientInViewportCoords.Left then
              OwnerListview.Scrollbars.OffsetX := R.Left;
          end
      end
    end
  end
end;

procedure TEasyItem.Paint(ACanvas: TCanvas; ViewportClipRect: TRect; Column: TEasyColumn; ForceSelectionRectDraw: Boolean);
begin
  View.Paint(Self, Column, ACanvas, ViewportClipRect, ForceSelectionRectDraw)
end;

procedure TEasyItem.ReleaseSelectionGroup;
var
  Temp: TEasySelectionGroupList;
begin
  if Assigned(FSelectionGroup) then
  begin
    Temp := FSelectionGroup;
    FSelectionGroup := nil;
    Temp.DecRef
  end
end;

procedure TEasyItem.SaveToStream(S: TStream; Version: Integer = STREAM_VERSION);
begin
  inherited SaveToStream(S);
  OwnerListview.DoItemSaveToStream(Self, S)
end;

procedure TEasyItem.SetGroupKey(FocusedColumn: Integer; Value: LongWord);
begin

end;

procedure TEasyItem.SetPaintInfo(const Value: TEasyPaintInfoItem);
begin
  inherited PaintInfo := Value
end;

procedure TEasyItem.SetSelectionGroup(Value: TEasySelectionGroupList);
begin
  if Value <> FSelectionGroup then
  begin
    if Assigned(FSelectionGroup) then
      FSelectionGroup.DecRef;
    FSelectionGroup := Value
  end
end;

{ TEasyItemVirtual}
function TEasyItemVirtual.GetCaptions(Column: Integer): Widestring;
begin
  Result := '';
  OwnerListview.DoItemGetCaption(Self, Column, Result)
end;

function TEasyItemVirtual.GetDetailCount: Integer;
begin
  Result := 0;
  OwnerListview.DoItemGetTileDetailCount(Self, Result)
end;

function TEasyItemVirtual.GetDetails(Line: Integer): Integer;
begin
  Result := 0;
  OwnerListview.DoItemGetTileDetail(Self, Line, Result)
end;

function TEasyItemVirtual.GetGroupKey(FocusedColumn: Integer): LongWord;
begin
  Result := 0;
  OwnerListview.DoItemGetGroupKey(Self, FocusedColumn, Result)
end;

function TEasyItemVirtual.GetImageIndexes(Column: Integer): Integer;
begin
  Result := -1;
  OwnerListview.DoItemGetImageIndex(Self, Column, eikNormal, Result)
end;

function TEasyItemVirtual.GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList;
begin
  Result := nil;
  OwnerListview.DoItemGetImageList(Self, Column, Result);
  if not Assigned(Result) then
    Result := DefaultImageList(IconSize)
end;

function TEasyItemVirtual.GetImageOverlayIndexes(Column: Integer): Integer;
begin
  Result := -1;
  OwnerListview.DoItemGetImageIndex(Self, Column, eikOverlay, Result)
end;

procedure TEasyItemVirtual.ImageDrawIsCustom(Column: TEasyColumn; var IsCustom: Boolean);
begin
  IsCustom := False;
  OwnerListview.DoItemImageDrawIsCustom(Column, Self, IsCustom)
end;

procedure TEasyItemVirtual.ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
begin
  OwnerListview.DoItemImageDraw(Self, Column, ACanvas, RectArray, AlphaBlender)
end;

procedure TEasyItemVirtual.ImageDrawGetSize(Column: TEasyColumn; var ImageW: Integer; var ImageH: Integer);
begin
  OwnerListview.DoItemImageGetSize(Self, Column, ImageW, ImageH)
end;

procedure TEasyItemVirtual.SetCaptions(Column: Integer; Value: Widestring);
begin
  OwnerListview.DoItemSetCaption(Self, Column, Value);
  Invalidate(False)
end;

procedure TEasyItemVirtual.SetDetailCount(Value: Integer);
begin
  OwnerListview.DoItemSetTileDetailCount(Self, Value);
  Invalidate(False)
end;

procedure TEasyItemVirtual.SetDetails(Line: Integer; Value: Integer);
begin
  OwnerListview.DoItemSetTileDetail(Self, Line, Value);
  Invalidate(False)
end;

procedure TEasyItemVirtual.SetGroupKey(FocusedColumn: Integer; Value: LongWord);
begin
  OwnerListview.DoItemSetGroupKey(Self, FocusedColumn, Value);
end;

procedure TEasyItemVirtual.SetImageIndexes(Column: Integer; Value: Integer);
begin
  OwnerListview.DoItemSetImageIndex(Self, Column, eikNormal, Value);
  Invalidate(False)
end;

procedure TEasyItemVirtual.SetImageOverlayIndexes(Column: Integer; Value: Integer);
begin
  OwnerListview.DoItemSetImageIndex(Self, Column, eikOverlay, Value);
  Invalidate(False)
end;

procedure TEasyItemVirtual.ThumbnailDraw(ACanvas: TCanvas; ARect: TRect;
  AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
begin
  OwnerListview.DoItemThumbnailDraw(Self, ACanvas, ARect, AlphaBlender, DoDefault)
end;

{ TEasyItemStored }

constructor TEasyItemStored.Create(ACollection: TEasyCollection);
begin
  inherited Create(ACollection);
  FDataHelper := TEasyItemDynamicDataHelper.Create;
end;

destructor TEasyItemStored.Destroy;
begin
  SetDestroyFlags;
  inherited Destroy;
  FreeAndNil(FDataHelper);
end;

function TEasyItemStored.GetCaptions(Column: Integer): Widestring;
begin
  Result := '';
  if Assigned(DataHelper) then
    Result := DataHelper.Captions[Column]
end;

function TEasyItemStored.GetDetailCount: Integer;
begin
  Result := OwnerListview.PaintInfoItem.TileDetailCount
end;

function TEasyItemStored.GetDetails(Line: Integer): Integer;
begin
  Result := 0;
  if Assigned(DataHelper) then
    Result := DataHelper.Details[Line]
end;

function TEasyItemStored.GetGroupKey(FocusedColumn: Integer): LongWord;
begin
   Result := 0;
  if Assigned(DataHelper) then
    Result := DataHelper.GroupKey[FocusedColumn]
end;

function TEasyItemStored.GetImageIndexes(Column: Integer): Integer;
begin
  Result := -1;
  if Assigned(DataHelper) then
    Result := DataHelper.ImageIndexes[Column]
end;

function TEasyItemStored.GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList;
begin
  Result := DefaultImageList(IconSize)
end;

function TEasyItemStored.GetImageOverlayIndexes(Column: Integer): Integer;
begin
  Result := -1;
  if Assigned(DataHelper) then
    Result := DataHelper.ImageOverlayIndexes[Column]
end;

procedure TEasyItemStored.ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
begin
  OwnerListview.DoItemImageDraw(Self, Column, ACanvas, RectArray, AlphaBlender)
end;

procedure TEasyItemStored.ImageDrawGetSize(Column: TEasyColumn; var ImageW: Integer; var ImageH: Integer);
begin
  OwnerListview.DoItemImageGetSize(Self, Column, ImageW, ImageH)
end;

procedure TEasyItemStored.ImageDrawIsCustom(Column: TEasyColumn;
  var IsCustom: Boolean);
begin
  IsCustom := False;
  OwnerListview.DoItemImageDrawIsCustom(Column, Self, IsCustom)
end;

procedure TEasyItemStored.LoadFromStream(S: TStream; Version: Integer = STREAM_VERSION);
begin
  inherited LoadFromStream(S, Version);
  if Assigned(DataHelper) then
    DataHelper.LoadFromStream(S);
end;

procedure TEasyItemStored.SaveToStream(S: TStream; Version: Integer = STREAM_VERSION);
begin
  inherited SaveToStream(S, Version);
  if Assigned(DataHelper) then
    DataHelper.SaveToStream(S);
end;

procedure TEasyItemStored.SetCaptions(Column: Integer; Value: Widestring);
begin
  if Assigned(DataHelper) then
  begin
    DataHelper.Captions[Column] := Value;
    Invalidate(False);
  end;
end;

procedure TEasyItemStored.SetDetailCount(Value: Integer);
begin
  OwnerListview.PaintInfoItem.TileDetailCount := Value
end;

procedure TEasyItemStored.SetDetails(Column: Integer; Value: Integer);
begin
  if Assigned(DataHelper) then
  begin
    DataHelper.Details[Column] := Value;
    Invalidate(False);
  end;
end;

procedure TEasyItemStored.SetGroupKey(FocusedColumn: Integer; Value: LongWord);
begin
  if Assigned(DataHelper) then
    DataHelper.GroupKey[FocusedColumn] := Value;
end;

procedure TEasyItemStored.SetImageIndexes(Column: Integer; Value: Integer);
begin
  if Assigned(DataHelper) then
  begin
    DataHelper.ImageIndexes[Column] := Value;
    Invalidate(False);
  end;
end;

procedure TEasyItemStored.SetImageOverlayIndexes(Column: Integer; Value: Integer);
begin
  if Assigned(DataHelper) then
  begin
    DataHelper.ImageOverlayIndexes[Column] := Value;
    Invalidate(False);
  end;
end;

procedure TEasyItemStored.ThumbnailDraw(ACanvas: TCanvas; ARect: TRect;
  AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
begin
  OwnerListview.DoItemThumbnailDraw(Self, ACanvas, ARect, AlphaBlender, DoDefault)
end;

{ TEasyDynamicDataHelper}

function TEasyDynamicDataHelper.GetCaptions(Index: Integer): Widestring;
begin
  if Index < Length(CaptionArray) then
    Result := CaptionArray[Index]
  else
    Result := ''
end;

function TEasyDynamicDataHelper.GetDetails(Index: Integer): Integer;
begin
  if Index < Length(DetailArray) then
    Result := DetailArray[Index]
  else
    Result := 0
end;

function TEasyDynamicDataHelper.GetImageIndexes(Index: Integer): Integer;
begin
  if Index < Length(ImageIndexArray) then
    Result := ImageIndexArray[Index]
  else
    Result := -1
end;

function TEasyDynamicDataHelper.GetImageOverlayIndexes(Index: Integer): Integer;
begin
  if Index < Length(OverlayIndexArray) then
    Result := OverlayIndexArray[Index]
  else
    Result := -1
end;

procedure TEasyDynamicDataHelper.Clear;
begin
  SetLength(FCaptionArray, 0);
  SetLength(FDetailArray, 0);
  SetLength(FImageIndexArray, 0);
  SetLength(FOverlayIndexArray, 0);
end;

procedure TEasyDynamicDataHelper.LoadFromStream(S: TStream);
begin
  LoadWideStrArrayFromStream(S, FCaptionArray);
  LoadIntArrayFromStream(S, FDetailArray);
  LoadIntArrayFromStream(S, FImageIndexArray);
  LoadIntArrayFromStream(S, FOverlayIndexArray);
end;

procedure TEasyDynamicDataHelper.LoadIntArrayFromStream(S: TStream; var AnArray: TIntegerDynArray);
var
  Len, i: Integer;
begin
  Setlength(AnArray, 0);
  S.ReadBuffer(Len, SizeOf(Len));
  Setlength(AnArray, Len);
  for i := 0 to Len - 1 do
    S.ReadBuffer(AnArray[i], SizeOf(Integer))
end;

procedure TEasyDynamicDataHelper.LoadWideStrArrayFromStream(S: TStream; var AnArray: TWideStringDynArray);
var
  Len, Count, i: Integer;
begin
  Setlength(AnArray, 0);
  S.ReadBuffer(Len, SizeOf(Len));
  Setlength(AnArray, Len);
  for i := 0 to Len - 1 do
  begin
    S.ReadBuffer(Count, SizeOf(Count));
    SetLength(AnArray[i], Count);
    S.ReadBuffer(PWideChar(AnArray[i])^, Count * 2);
  end
end;

procedure TEasyDynamicDataHelper.SaveIntArrayToStream(S: TStream; var AnArray: TIntegerDynArray);
var
  Len, i: Integer;
begin
  Len := Length(AnArray);
  S.WriteBuffer(Len, SizeOf(Len));
  for i := 0 to Len - 1 do
    S.WriteBuffer(AnArray[i], SizeOf(Integer))
end;

procedure TEasyDynamicDataHelper.SaveWideStrArrayToStream(S: TStream; var AnArray: TWideStringDynArray);
var
  Len, i, Count: Integer;
begin
  Len := Length(AnArray);
  S.WriteBuffer(Len, SizeOf(Len));
  for i := 0 to Len - 1 do
  begin
    Count := Length(AnArray[i]);
    S.WriteBuffer(Count, SizeOf(Count));
    S.WriteBuffer(PWideChar(AnArray[i])^, Count * 2);
  end
end;

procedure TEasyDynamicDataHelper.SaveToStream(S: TStream);
begin
  SaveWideStrArrayToStream(S, FCaptionArray);
  SaveIntArrayToStream(S, FDetailArray);
  SaveIntArrayToStream(S, FImageIndexArray);
  SaveIntArrayToStream(S, FOverlayIndexArray);
end;

procedure TEasyDynamicDataHelper.SetCaptions(Index: Integer; Value: Widestring);
var
  OldLen, i: Integer;
begin
  if Index >= Length(CaptionArray) then
  begin
    OldLen := Length(CaptionArray);
    SetLength(FCaptionArray, Index + 1);
    for i := OldLen to Length(CaptionArray) - 1 do
      CaptionArray[i] := ''
  end;
  CaptionArray[Index] := Value
end;

procedure TEasyDynamicDataHelper.SetDetails(Index: Integer; Value: Integer);
var
  OldLen, i: Integer;
begin
  if Index >= Length(DetailArray) then
  begin
    OldLen := Length(DetailArray);
    SetLength(FDetailArray, Index + 1);
    for i := OldLen to Length(DetailArray) - 1 do
      DetailArray[i] := 0
  end;
  DetailArray[Index] := Value
end;

procedure TEasyDynamicDataHelper.SetImageIndexes(Index: Integer; Value: Integer);
var
  OldLen, i: Integer;
begin
  if Index >= Length(ImageIndexArray) then
  begin
    OldLen := Length(ImageIndexArray);
    SetLength(FImageIndexArray, Index + 1);
    for i := OldLen to Length(ImageIndexArray) - 1 do
      ImageIndexArray[i] := -1
  end;
  ImageIndexArray[Index] := Value
end;

procedure TEasyDynamicDataHelper.SetImageOverlayIndexes(Index: Integer; Value: Integer);
var
  OldLen, i: Integer;
begin
  if Index >= Length(OverlayIndexArray) then
  begin
    OldLen := Length(OverlayIndexArray);
    SetLength(FOverlayIndexArray, Index + 1);
    for i := OldLen to Length(OverlayIndexArray) - 1 do
      OverlayIndexArray[i] := -1
  end;
  OverlayIndexArray[Index] := Value
end;

{ TEasyGroupStored }
constructor TEasyGroupStored.Create(ACollection: TEasyCollection);
begin
  inherited Create(ACollection);
  FDataHelper := TEasyDynamicDataHelper.Create;
end;

destructor TEasyGroupStored.Destroy;
begin
  SetDestroyFlags;
  inherited Destroy;
  FreeAndNil(FDataHelper);
end;

function TEasyGroupStored.GetCaptions(Line: Integer): Widestring;
begin
  Result := DataHelper.Captions[Line]
end;

function TEasyGroupStored.GetDetailCount: Integer;
begin
  Result := OwnerListview.PaintInfoGroup.CaptionLines
end;

function TEasyGroupStored.GetDetails(Line: Integer): Integer;
begin
  Result := DataHelper.Details[Line]
end;

function TEasyGroupStored.GetImageIndexes(Column: Integer): Integer;
begin
  Result := DataHelper.ImageIndexes[Column]
end;

function TEasyGroupStored.GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList;
begin
  Result := DefaultImageList(IconSize)
end;

function TEasyGroupStored.GetImageOverlayIndexes(Column: Integer): Integer;
begin
  Result := DataHelper.ImageOverlayIndexes[Column]
end;

procedure TEasyGroupStored.ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
begin
  OwnerListview.DoGroupImageDraw(Self, ACanvas, RectArray, AlphaBlender)
end;

procedure TEasyGroupStored.ImageDrawGetSize(Column: TEasyColumn; var ImageW: Integer; var ImageH: Integer);
begin
  OwnerListview.DoGroupImageGetSize(Self, ImageW, ImageH)
end;

procedure TEasyGroupStored.ImageDrawIsCustom(Column: TEasyColumn;
  var IsCustom: Boolean);
begin
  IsCustom := False;
  OwnerListview.DoGroupImageDrawIsCustom(Self, IsCustom)
end;

procedure TEasyGroupStored.LoadFromStream(S: TStream; Version: Integer = STREAM_VERSION);
begin
  inherited LoadFromStream(S, Version);
  DataHelper.LoadFromStream(S);
end;

procedure TEasyGroupStored.SaveToStream(S: TStream; Version: Integer = STREAM_VERSION);
begin
  inherited SaveToStream(S, Version);
  DataHelper.SaveToStream(S);
end;

procedure TEasyGroupStored.SetCaptions(Column: Integer; Value: Widestring);
begin
  DataHelper.Captions[Column] := Value;
  Invalidate(False)
end;

procedure TEasyGroupStored.SetDetailCount(Value: Integer);
begin
  OwnerListview.PaintInfoGroup.CaptionLines := Value
end;

procedure TEasyGroupStored.SetDetails(Line: Integer; Value: Integer);
begin
  DataHelper.Details[Line] := Value;
  Invalidate(False)
end;

procedure TEasyGroupStored.SetImageIndexes(Column: Integer; Value: Integer);
begin
  DataHelper.ImageIndexes[Column] := Value;
  Invalidate(False)
end;

procedure TEasyGroupStored.SetImageOverlayIndexes(Column: Integer; Value: Integer);
begin
  DataHelper.ImageOverlayIndexes[Column] := Value;
  Invalidate(False)
end;

procedure TEasyGroupStored.ThumbnailDraw(ACanvas: TCanvas; ARect: TRect;
  AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
begin
  // not implemented
end;

{ TEasyGroupVirtual}
function TEasyGroupVirtual.GetCaptions(Line: Integer): Widestring;
begin
  Result := '';
  OwnerListview.DoGroupGetCaption(Self, Result)
end;

function TEasyGroupVirtual.GetDetailCount: Integer;
begin
  Result := 0;
  OwnerListview.DoGroupGetDetailCount(Self, Result)
end;

function TEasyGroupVirtual.GetDetails(Line: Integer): Integer;
begin
  Result := 0;
  OwnerListview.DoGroupGetDetail(Self, Line, Result)
end;

function TEasyGroupVirtual.GetImageIndexes(Column: Integer): Integer;
begin
  Result := -1;
  OwnerListview.DoGroupGetImageIndex(Self, eikNormal, Result)
end;

function TEasyGroupVirtual.GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList;
begin
  Result := nil;
  OwnerListview.DoGroupGetImageList(Self, Result);
  if not Assigned(Result) then
    Result := DefaultImageList(IconSize)
end;

function TEasyGroupVirtual.GetImageOverlayIndexes(Column: Integer): Integer;
begin
  OwnerListview.DoGroupGetImageIndex(Self, eikOverlay, Result)
end;

procedure TEasyGroupVirtual.ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
begin
  OwnerListview.DoGroupImageDraw(Self, ACanvas, RectArray, AlphaBlender)
end;

procedure TEasyGroupVirtual.ImageDrawGetSize(Column: TEasyColumn; var ImageW: Integer; var ImageH: Integer);
begin
  OwnerListview.DoGroupImageGetSize(Self, ImageW, ImageH)
end;

procedure TEasyGroupVirtual.ImageDrawIsCustom(Column: TEasyColumn;
  var IsCustom: Boolean);
begin
  IsCustom := False;
  OwnerListview.DoGroupImageDrawIsCustom(Self, IsCustom)
end;

procedure TEasyGroupVirtual.SetCaptions(Column: Integer; Value: Widestring);
begin
  OwnerListview.DoGroupSetCaption(Self, Value);
  Invalidate(False)
end;

procedure TEasyGroupVirtual.SetDetailCount(Value: Integer);
begin
  OwnerListview.DoGroupSetDetailCount(Self, Value);
  Invalidate(False)
end;

procedure TEasyGroupVirtual.SetDetails(Line: Integer; Value: Integer);
begin
  OwnerListview.DoGroupSetDetail(Self, Line, Value);
  Invalidate(False)
end;

procedure TEasyGroupVirtual.SetImageIndexes(Column: Integer; Value: Integer);
begin
  OwnerListview.DoGroupSetImageIndex(Self, eikNormal, Value);
  Invalidate(False)
end;

procedure TEasyGroupVirtual.SetImageOverlayIndexes(Column: Integer; Value: Integer);
begin
  OwnerListview.DoGroupSetImageIndex(Self, eikOverlay, Value);
  Invalidate(False)
end;

procedure TEasyGroupVirtual.ThumbnailDraw(ACanvas: TCanvas; ARect: TRect;
  AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
begin
  // not Implemented
end;

{ TEasyGroupInterfaced}
function TEasyGroupInterfaced.GetCaptions(Line: Integer): Widestring;
var
  CaptionInf: IEasyCaptions;
begin
  CaptionInf := nil;
  if Supports(DataInf, IEasyCaptions, CaptionInf) then
    Result := CaptionInf.Captions[Line]
end;

function TEasyGroupInterfaced.GetDetailCount: Integer;
var
  DetailInf: IEasyDetails;
begin
  Result := 0;
  DetailInf := nil;
  if Supports(DataInf, IEasyDetails, DetailInf) then
    Result := DetailInf.GetDetailCount
end;

function TEasyGroupInterfaced.GetDetails(Line: Integer): Integer;
var
  DetailInf: IEasyDetails;
begin
  Result := 0;
  DetailInf := nil;
  if Supports(DataInf, IEasyDetails, DetailInf) then
    Result := DetailInf.Detail[Line]
end;

function TEasyGroupInterfaced.GetImageIndexes(Column: Integer): Integer;
var
  ImageInf: IEasyImages;
begin
  Result := -1;
  ImageInf := nil;
  if Supports(DataInf, IEasyImages, ImageInf) then
    Result := ImageInf.ImageIndexes[Column, eikNormal]
end;

function TEasyGroupInterfaced.GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList;
var
  ImageList: IEasyImageList;
begin
  Result := nil;
  if Supports(DataInf, IEasyImageList, ImageList) then
    Result := ImageList.ImageList[Column, IconSize];
  if not Assigned(Result) then
    Result := DefaultImageList(IconSize)
end;

function TEasyGroupInterfaced.GetImageOverlayIndexes(Column: Integer): Integer;
var
  ImageInf: IEasyImages;
begin
  Result := -1;
  ImageInf := nil;
  if Supports(DataInf, IEasyImages, ImageInf) then
    Result := ImageInf.ImageIndexes[Column, eikOverlay]
end;

procedure TEasyGroupInterfaced.ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
var
  ImageInf: IEasyCustomImage;
begin
  if Supports(DataInf, IEasyCustomImage, ImageInf) then
    ImageInf.DrawImage(Column, ACanvas, RectArray, AlphaBlender)
end;

procedure TEasyGroupInterfaced.ImageDrawGetSize(Column: TEasyColumn; var ImageW: Integer; var ImageH: Integer);
var
  ImageInf: IEasyCustomImage;
begin
  if Supports(DataInf, IEasyCustomImage, ImageInf) then
    ImageInf.GetSize(Column, ImageW, ImageH)
end;

procedure TEasyGroupInterfaced.ImageDrawIsCustom(Column: TEasyColumn;
  var IsCustom: Boolean);
var
  ImageInf: IEasyCustomImage;
begin
  IsCustom := False;
  if Supports(DataInf, IEasyCustomImage, ImageInf) then
    ImageInf.CustomDrawn(Column, IsCustom)
end;

procedure TEasyGroupInterfaced.SetCaptions(Column: Integer; Value: Widestring);
var
  CaptionInf: IEasyCaptionsEditable;
begin
  CaptionInf := nil;
  if Supports(DataInf, IEasyCaptionsEditable, CaptionInf) then
  begin
    CaptionInf.SetCaption(Column, Value);
    Invalidate(False)
  end
end;

procedure TEasyGroupInterfaced.SetDetailCount(Value: Integer);
var
  DetailsInf: IEasyDetailsEditable;
begin
  DetailsInf := nil;
  if Supports(DataInf, IEasyDetailsEditable, DetailsInf) then
  begin
    DetailsInf.DetailCount := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroupInterfaced.SetDetails(Line: Integer; Value: Integer);
var
  DetailsInf: IEasyDetailsEditable;
begin
  DetailsInf := nil;
  if Supports(DataInf, IEasyDetailsEditable, DetailsInf) then
  begin
    DetailsInf.Detail[Line] := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroupInterfaced.SetImageIndexes(Column: Integer; Value: Integer);
var
  ImageInf: IEasyImagesEditable;
begin
  ImageInf := nil;
  if Supports(DataInf, IEasyImagesEditable, ImageInf) then
  begin
    ImageInf.ImageIndexes[Column, eikNormal] := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroupInterfaced.SetImageOverlayIndexes(Column: Integer; Value: Integer);
var
  ImageInf: IEasyImagesEditable;
begin
  ImageInf := nil;
  if Supports(DataInf, IEasyImagesEditable, ImageInf) then
  begin
    ImageInf.ImageIndexes[Column, eikOverlay] := Value;
    Invalidate(False)
  end
end;

procedure TEasyGroupInterfaced.ThumbnailDraw(ACanvas: TCanvas; ARect: TRect;
  AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
begin
  // not supported
end;

{ TEasyColumnStored }

constructor TEasyColumnStored.Create(ACollection: TEasyCollection);
begin
  inherited Create(ACollection);
  FDataHelper := TEasyDynamicDataHelper.Create;
end;

destructor TEasyColumnStored.Destroy;
begin
  SetDestroyFlags;
  inherited Destroy;
  FreeAndNil(FDataHelper);
end;

function TEasyColumnStored.GetCaptions(Line: Integer): Widestring;
begin
  Result := DataHelper.Captions[Line]
end;

function TEasyColumnStored.GetDetailCount: Integer;
begin
  Result := OwnerListview.PaintInfoColumn.CaptionLines
end;

function TEasyColumnStored.GetDetails(Line: Integer): Integer;
begin
  Result := DataHelper.Details[Index]
end;

function TEasyColumnStored.GetImageIndexes(Column: Integer): Integer;
begin
  Result := DataHelper.ImageIndexes[Column]
end;

function TEasyColumnStored.GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList;
begin
  Result := DefaultImageList(IconSize)
end;

function TEasyColumnStored.GetImageOverlayIndexes(Column: Integer): Integer;
begin
  Result := DataHelper.ImageOverlayIndexes[Column]
end;

procedure TEasyColumnStored.ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
begin
  OwnerListview.DoColumnImageDraw(Self, ACanvas, RectArray, AlphaBlender)
end;

procedure TEasyColumnStored.ImageDrawGetSize(Column: TEasyColumn; var ImageW: Integer; var ImageH: Integer);
begin
  OwnerListview.DoColumnImageGetSize(Self, ImageW, ImageH)
end;

procedure TEasyColumnStored.ImageDrawIsCustom(Column: TEasyColumn;
  var IsCustom: Boolean);
begin
  IsCustom := False;
  OwnerListview.DoColumnImageDrawIsCustom(Self, IsCustom)
end;

procedure TEasyColumnStored.LoadFromStream(S: TStream; Version: Integer = STREAM_VERSION);
begin
  inherited LoadFromStream(S, Version);
  DataHelper.LoadFromStream(S);
end;

procedure TEasyColumnStored.SaveToStream(S: TStream; Version: Integer = STREAM_VERSION);
begin
  inherited SaveToStream(S, Version);
  DataHelper.SaveToStream(S);
end;

procedure TEasyColumnStored.SetCaptions(Column: Integer; Value: Widestring);
begin
  DataHelper.Captions[Column] := Value;
  Invalidate(False)
end;

procedure TEasyColumnStored.SetDetailCount(Value: Integer);
begin
  OwnerListview.PaintInfoColumn.CaptionLines := Value;
end;

procedure TEasyColumnStored.SetDetails(Line: Integer; Value: Integer);
begin
  DataHelper.Details[Line] := Value;
  Invalidate(False)
end;

procedure TEasyColumnStored.SetImageIndexes(Column: Integer; Value: Integer);
begin
  DataHelper.ImageIndexes[Column] := Value;
  Invalidate(False)
end;

procedure TEasyColumnStored.SetImageOverlayIndexes(Column: Integer; Value: Integer);
begin
  DataHelper.ImageOverlayIndexes[Column] := Value;
  Invalidate(False)
end;

procedure TEasyColumnStored.ThumbnailDraw(ACanvas: TCanvas; ARect: TRect;
  AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
begin
  // not implemented
end;

function TEasyColumnInterfaced.GetCaptions(Line: Integer): Widestring;
var
  CaptionInf: IEasyCaptions;
begin
  CaptionInf := nil;
  if Supports(DataInf, IEasyCaptions, CaptionInf) then
    Result := CaptionInf.Captions[Line]
end;

function TEasyColumnInterfaced.GetDetailCount: Integer;
var
  DetailInf: IEasyDetails;
begin
  Result := 0;
  DetailInf := nil;
  if Supports(DataInf, IEasyDetails, DetailInf) then
    Result := DetailInf.GetDetailCount
end;

function TEasyColumnInterfaced.GetDetails(Line: Integer): Integer;
var
  DetailInf: IEasyDetails;
begin
  Result := 0;
  DetailInf := nil;
  if Supports(DataInf, IEasyDetails, DetailInf) then
    Result := DetailInf.Detail[Line]
end;

function TEasyColumnInterfaced.GetImageIndexes(Column: Integer): Integer;
var
  ImageInf: IEasyImages;
begin
  Result := -1;
  ImageInf := nil;
  if Supports(DataInf, IEasyImages, ImageInf) then
    Result := ImageInf.ImageIndexes[Column, eikNormal]
end;

function TEasyColumnInterfaced.GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList;
var
  ImageList: IEasyImageList;
begin
  Result := nil;
  if Supports(DataInf, IEasyImageList, ImageList) then
    Result := ImageList.ImageList[Column, IconSize];
  if not Assigned(Result) then
    Result := DefaultImageList(IconSize)
end;

function TEasyColumnInterfaced.GetImageOverlayIndexes(Column: Integer): Integer;
var
  ImageInf: IEasyImages;
begin
  Result := -1;
  ImageInf := nil;
  if Supports(DataInf, IEasyImages, ImageInf) then
    Result := ImageInf.ImageIndexes[Column, eikOverlay]
end;

procedure TEasyColumnInterfaced.ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
var
  ImageInf: IEasyCustomImage;
begin
  if Supports(DataInf, IEasyCustomImage, ImageInf) then
    ImageInf.DrawImage(Column, ACanvas, RectArray, AlphaBlender)
end;

procedure TEasyColumnInterfaced.ImageDrawGetSize(Column: TEasyColumn; var ImageW: Integer; var ImageH: Integer);
var
  ImageInf: IEasyCustomImage;
begin
  if Supports(DataInf, IEasyCustomImage, ImageInf) then
    ImageInf.GetSize(Column, ImageW, ImageH)
end;

procedure TEasyColumnInterfaced.ImageDrawIsCustom(Column: TEasyColumn;
  var IsCustom: Boolean);
var
  ImageInf: IEasyCustomImage;
begin
  IsCustom := False;
  if Supports(DataInf, IEasyCustomImage, ImageInf) then
    ImageInf.CustomDrawn(Column, IsCustom)
end;

procedure TEasyColumnInterfaced.SetCaptions(Column: Integer; Value: Widestring);
var
  CaptionInf: IEasyCaptionsEditable;
begin
  CaptionInf := nil;
  if Supports(DataInf, IEasyCaptionsEditable, CaptionInf) then
    CaptionInf.SetCaption(Column, Value);
  Invalidate(False);
end;

procedure TEasyColumnInterfaced.SetDetailCount(Value: Integer);
var
  DetailsInf: IEasyDetailsEditable;
begin
  DetailsInf := nil;
  if Supports(DataInf, IEasyDetailsEditable, DetailsInf) then
  begin
    DetailsInf.DetailCount := Value;
    Invalidate(False)
  end
end;

procedure TEasyColumnInterfaced.SetDetails(Line: Integer; Value: Integer);
var
  DetailsInf: IEasyDetailsEditable;
begin
  DetailsInf := nil;
  if Supports(DataInf, IEasyDetailsEditable, DetailsInf) then
  begin
    DetailsInf.Detail[Line] := Value;
    Invalidate(False)
  end
end;

procedure TEasyColumnInterfaced.SetImageIndexes(Column: Integer; Value: Integer);
var
  ImageInf: IEasyImagesEditable;
begin
  ImageInf := nil;
  if Supports(DataInf, IEasyImagesEditable, ImageInf) then
  begin
    ImageInf.ImageIndexes[Column, eikNormal] := Value;
    Invalidate(False)
  end
end;

procedure TEasyColumnInterfaced.SetImageOverlayIndexes(Column: Integer; Value: Integer);
var
  ImageInf: IEasyImagesEditable;
begin
  ImageInf := nil;
  if Supports(DataInf, IEasyImagesEditable, ImageInf) then
  begin
    ImageInf.ImageIndexes[Column, eikOverlay] := Value;
    Invalidate(False)
  end
end;

procedure TEasyColumnInterfaced.ThumbnailDraw(ACanvas: TCanvas; ARect: TRect;
  AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
begin
  // not implemented
end;

{ TEasyColumnVirtual}
function TEasyColumnVirtual.GetCaptions(Line: Integer): Widestring;
begin
  Result := '';
  OwnerListview.DoColumnGetCaption(Line, Result)
end;

function TEasyColumnVirtual.GetDetailCount: Integer;
begin
  Result := 0;
  OwnerListview.DoColumnGetDetailCount(Self, Result)
end;

function TEasyColumnVirtual.GetDetails(Line: Integer): Integer;
begin
  Result := 0;
  OwnerListview.DoColumnGetDetail(Self, Line, Result)
end;

function TEasyColumnVirtual.GetImageIndexes(Column: Integer): Integer;
begin
  Result := -1;
  OwnerListview.DoColumnGetImageIndex(Self, eikNormal, Result)
end;

function TEasyColumnVirtual.GetImageList(Column: Integer; IconSize: TEasyImageSize): TImageList;
begin
  Result := nil;
  OwnerListview.DoColumnGetImageList(Self, Result);
  if not Assigned(Result) then
    Result := DefaultImageList(IconSize)
end;

function TEasyColumnVirtual.GetImageOverlayIndexes(Column: Integer): Integer;
begin
  Result := -1;
  OwnerListview.DoColumnGetImageIndex(Self, eikOverlay, Result)
end;

procedure TEasyColumnVirtual.ImageDraw(Column: TEasyColumn; ACanvas: TCanvas; const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
begin
  OwnerListview.DoColumnImageDraw(Self, ACanvas, RectArray, AlphaBlender)
end;

procedure TEasyColumnVirtual.ImageDrawGetSize(Column: TEasyColumn; var ImageW: Integer; var ImageH: Integer);
begin
  OwnerListview.DoColumnImageGetSize(Self, ImageW, ImageH)
end;

procedure TEasyColumnVirtual.ImageDrawIsCustom(Column: TEasyColumn;
  var IsCustom: Boolean);
begin
  IsCustom := False;
  OwnerListview.DoColumnImageDrawIsCustom(Self, IsCustom)
end;

procedure TEasyColumnVirtual.SetCaptions(Column: Integer; Value: Widestring);
begin
  OwnerListview.DoColumnSetCaption(Self, Value);
  Invalidate(False)
end;

procedure TEasyColumnVirtual.SetDetailCount(Value: Integer);
begin
  OwnerListview.DoColumnSetDetailCount(Self, Value);
  Invalidate(False)
end;

procedure TEasyColumnVirtual.SetDetails(Line: Integer; Value: Integer);
begin
  OwnerListview.DoColumnSetDetail(Self, Line, Value);
  Invalidate(False)
end;

procedure TEasyColumnVirtual.SetImageIndexes(Column: Integer; Value: Integer);
begin
  OwnerListview.DoColumnSetImageIndex(Self, eikNormal, Value);
  Invalidate(False)
end;

procedure TEasyColumnVirtual.SetImageOverlayIndexes(Column: Integer; Value: Integer);
begin
  OwnerListview.DoColumnSetImageIndex(Self, eikOverlay, Value);
  Invalidate(False)
end;

procedure TEasyColumnVirtual.ThumbnailDraw(ACanvas: TCanvas; ARect: TRect;
  AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
begin
  // not Implemented
end;

{ TEasyPaintInfoBaseItem }

constructor TEasyPaintInfoBaseItem.Create(AnOwner: TCustomEasyListview);
begin
  inherited Create(AnOwner);
  FTileDetailCount := 1;
  FGridLineColor := clBtnFace;
end;

procedure TEasyPaintInfoBaseItem.SetGridLineColor(const Value: TColor);
begin
  if FGridLineColor <> Value then
  begin
    FGridLineColor := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TEasyPaintInfoBaseItem.SetGridLines(const Value: Boolean);
begin
  if FGridLines <> Value then
  begin
    FGridLines := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

procedure TEasyPaintInfoBaseItem.SetTileDetailCount(Value: Integer);
begin
  if Value <> FTileDetailCount then
  begin
    FTileDetailCount := Value;
    OwnerListview.SafeInvalidateRect(nil, False)
  end
end;

{ TColumnPos }

function TColumnPos.Get(Index: Integer): TEasyColumn;
begin
  Result := inherited Get(Index)
end;

procedure TColumnPos.Put(Index: Integer; Item: TEasyColumn);
begin
  inherited Put(Index, Item)
end;

{ TEasyHeaderDragManager }

constructor TEasyHeaderDragManager.Create(AnOwner: TCustomEasyListview);
begin
  inherited Create(AnOwner);
  FEnableDragImage := True;
  FDragImageWidth := 200;
  FDragImageHeight := 300;
  FEnabled := False;
  DefaultImageEvent := DefaultImage;
  DragMode := dmManual;
  DragCursor := crDrag
end;

function TEasyHeaderDragManager.DoPtInAutoScrollLeftRegion(WindowPoint: TPoint): Boolean;
begin
  Result := WindowPoint.X < AutoScrollMargin
end;

function TEasyHeaderDragManager.DoPtInAutoScrollRightRegion(WindowPoint: TPoint): Boolean;
begin
  Result := WindowPoint.X > (OwnerListview.ClientWidth - AutoScrollMargin)
end;

function TEasyHeaderDragManager.GetDragCursor: TCursor;
begin
  Result := OwnerListview.DragCursor
end;


function TEasyHeaderDragManager.GetDragMode: TDragMode;
begin
  Result := FDragMode;
end;


procedure TEasyHeaderDragManager.DefaultImage(Sender: TCustomEasyListview; Image: TBitmap; DragStartPt: TPoint; var HotSpot: TPoint; var TransparentColor: TColor; var Handled: Boolean);
// Generates the drag image for the dragging items from the Easy Control
var
  R, ViewR: TRect;
  Pt: TPoint;
begin
  if Assigned(Image) then
  begin
    TransparentColor := OwnerListview.Color;
    Image.Canvas.Brush.Color := Header.Color;

    Image.Canvas.FillRect(Rect(0, 0, Image.Width, Image.Height));
    R := Column.DisplayRect;

    HotSpot.X := DragStartPt.X - Column.DisplayRect.Left;
    HotSpot.Y := DragStartPt.Y - Column.DisplayRect.Top;

    if R.Left < 0 then
      HotSpot.X := HotSpot.X + R.Left;
    if R.Top < 0 then
      HotSpot.Y := HotSpot.Y + R.Top;

    ViewR := OwnerListview.ClientRect;
    OffsetRect(ViewR, OwnerListview.Scrollbars.OffsetX, 0);
    IntersectRect(R, R, ViewR);
    SetViewPortOrgEx(Image.Canvas.Handle, -R.Left, 0, @Pt);
    Header.PaintTo(Image.Canvas, R);
    SetViewPortOrgEx(Image.Canvas.Handle, Pt.X, Pt.Y, nil);
    Handled := True;
  end
end;

procedure TEasyHeaderDragManager.DoDrag(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect);
var
  Temp: TEasyColumn;
begin
  Effects := cdeNone;
  if AllowDrop then
  begin
    if WindowPoint.Y < Header.Height then
    begin
      Effects := cdeMove;
      Inc(WindowPoint.X, OwnerListview.Scrollbars.OffsetX);
      Temp := Header.Columns.ColumnByPoint(WindowPoint);
      if Temp <> TargetColumn then
      begin
        if Assigned(TargetColumn) then
        begin
          Exclude(TargetColumn.FState, esosDropTarget);
          TargetColumn.Invalidate(True);
        end;
        TargetColumn := Temp;
        if Assigned(TargetColumn) then
        begin
          Include(TargetColumn.FState, esosDropTarget);
          TargetColumn.Invalidate(True);
        end
      end
    end else
    begin
      if Assigned(TargetColumn) then
      begin
        Exclude(TargetColumn.FState, esosDropTarget);
        TargetColumn.Invalidate(True);
        TargetColumn := nil;
      end;
    end
  end
end;

procedure TEasyHeaderDragManager.DoDragBegin(WindowPoint: TPoint; KeyState: TCommonKeyStates);
var
  DropSource: IDropSource;
  DataObject: TEasyDataObjectManager;
  DataObjInf: IEasyExtractObj;
  Image: TBitmap;
  TransparentColor: TColor;
  dwEffect, ImageWidth, ImageHeight: Integer;
  AvailableEffects: TCommonDropEffects;
  DragResultEffect: TCommonOLEDragResult;
  AllowDrag, Handled: Boolean;
  DragResult: HRESULT;
  HotPtOffset: TPoint;
  DataObjectInf: IDataObject;
begin
  if Enabled then
  begin
    inherited;
    if DragType = edtOLE then
    begin
      DataObjectInf := nil;
      DataObject := nil;
      AvailableEffects := [cdeNone];
      dwEffect := 0;
      AllowDrag := False;
      if Self is TEasyOLEDragManager then
        OwnerListview.DoOLEGetDataObject(DataObjectInf);  
      if not Assigned(DataObjectInf) then
      begin
        DataObject := TEasyDataObjectManager.Create(OwnerListview);
        // Get a reference right away so it won't be freed from under us
        DataObjectInf := DataObject as IDataObject;
      end;
      DoOLEDragStart(DataObjectInf, AvailableEffects, AllowDrag);
      if AllowDrag then
      begin
        if (DataObjectInf.QueryInterface(IEasyExtractObj, DataObjInf) = S_OK) then
          DataObject := DataObjInf.GetObj as TEasyDataObjectManager;
        if EnableDragImage and Assigned(DataObject) then
        begin
          Image := TBitmap.Create;
          try
            ImageWidth := 0;
            ImageHeight := 0;
            ImageSize(ImageWidth, ImageHeight);
            Image.Width := ImageWidth;
            Image.Height := ImageHeight;
            Image.PixelFormat := pf32Bit;
            TransparentColor := clWindow;
            Handled := False;
            DoGetDragImage(Image, WindowPoint, HotPtOffset, TransparentColor, Handled);
            if not Handled and Assigned(DefaultImageEvent) then
              DefaultImageEvent(OwnerListview, Image, WindowPoint, HotPtOffset, TransparentColor, Handled);
            if Handled then
              DataObject.AssignDragImage(Image, HotPtOffset, TransparentColor);
          finally
            Image.Free
          end
        end;
        DropSource := TEasyDropSourceManager.Create(OwnerListview);
        DragResult := ActiveX.DoDragDrop(DataObjectInf, DropSource, DropEffectStatesToDropEffect(AvailableEffects), dwEffect);
        if DragResult = DRAGDROP_S_DROP then
          DragResultEffect := cdrDrop
        else
        if DragResult = DRAGDROP_S_CANCEL then
          DragResultEffect := cdrCancel
        else
          DragResultEffect := cdrError;
        // Set it back to the default drag manager to be ready for a drop
        DoOLEDragEnd(DataObjectInf, DragResultEffect, DropEffectToDropEffectStates(dwEffect));
      end
    end else
      VCLDragStart
  end;
  DataObjectInf := nil
end;

procedure TEasyHeaderDragManager.DoDragDrop(WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect);
begin
  if Assigned(TargetColumn) then
    Column.Position :=  TargetColumn.Position;
  DoDragEnd(nil, WindowPoint, KeyState);
end;

procedure TEasyHeaderDragManager.DoDragEnd(Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates);
begin
  if Assigned(TargetColumn) then
  begin
    Exclude(TargetColumn.FState, esosDropTarget);
    TargetColumn.Invalidate(True);
  end;
  TargetColumn := nil; 
end;

procedure TEasyHeaderDragManager.DoDragEnter(const DataObject: IDataObject; Canvas: TCanvas; WindowPoint: TPoint; KeyState: TCommonKeyStates; var Effects: TCommonDropEffect);
var
  Medium: TStgMedium;
  DataPtr: PHeaderClipData;
begin        
  AllowDrop := False;
  Effects := cdeNone;
  if Succeeded(DataObject.GetData(HeaderClipFormat, Medium)) then
  begin
    DataPtr := GlobalLock(Medium.hGlobal);
    try
      AllowDrop := (DataPtr^.Thread = GetCurrentThread) and (DataPtr^.Listview = OwnerListview)
    finally
      GlobalUnlock(Medium.hGlobal);
      ReleaseStgMedium(Medium)
    end
  end;
end;

procedure TEasyHeaderDragManager.DoOLEDragEnd(const ADataObject: IDataObject; DragResult: TCommonOLEDragResult; ResultEffect: TCommonDropEffects);
begin
  Header.ClearStates
end;

procedure TEasyHeaderDragManager.DoOLEDragStart(const ADataObject: IDataObject; var AvailableEffects: TCommonDropEffects; var AllowDrag: Boolean);
var
  Medium: TStgMedium;
  DataPtr: PHeaderClipData;
begin
  AllowDrag := Enabled;
  AvailableEffects := [cdeMove];
  FillChar(Medium, SizeOf(Medium), #0);
  Medium.tymed := TYMED_HGLOBAL;
  Medium.hGlobal := GlobalAlloc(GHND, SizeOf(THeaderClipData));
  try
    DataPtr := GlobalLock(Medium.hGlobal);
    DataPtr^.Column := Column;
    DataPtr^.Listview := Header.OwnerListview;
    DataPtr^.Thread := GetCurrentThread;
  finally
    GlobalUnLock(Medium.hGlobal)
  end;
  // Give the block to the IDataObject to dispose of
  ADataObject.SetData(HeaderClipFormat, Medium, True);
end;

procedure TEasyHeaderDragManager.ImageSize(var Width, Height: Integer);
begin
  Width := Column.Width;
  Height := OwnerListview.Header.Height
end;

procedure TEasyHeaderDragManager.SetDragCursor(Value: TCursor);
begin
  OwnerListview.DragCursor := Value
end;

procedure TEasyHeaderDragManager.SetDragMode(Value: TDragMode);
begin
  FDragMode := Value
end;

procedure TEasyHeaderDragManager.SetDragType(Value: TEasyDragType);
begin
  if FDragType <> Value then
  begin
    if Value = edtVCL then
      Registered := False;
    FDragType := Value;
  end
end;

{ TEasyItemDynamicDataHelper }
function TEasyItemDynamicDataHelper.GetGroupKey(Index: Integer): LongWord;
begin
  if Index < Length(GroupKeyArray) then
    Result := GroupKeyArray[Index]
  else
    Result := EGT_FIRSTLETTER
end;

procedure TEasyItemDynamicDataHelper.LoadFromStream(S: TStream);
begin
  inherited LoadFromStream(S);
  LoadIntArrayFromStream(S, FGroupKeyArray);
end;

procedure TEasyItemDynamicDataHelper.SaveToStream(S: TStream);
begin
  inherited SaveToStream(S);
  SaveIntArrayToStream(S, FGroupKeyArray);
end;

procedure TEasyItemDynamicDataHelper.SetGroupKey(Index: Integer;
  Value: LongWord);
var
  OldLen, i: Integer;
begin
  if Index >= Length(GroupKeyArray) then
  begin
    OldLen := Length(GroupKeyArray);
    SetLength(FGroupKeyArray, Index + 1);
    for i := OldLen to Length(GroupKeyArray) - 1 do
      GroupKeyArray[i] := EGT_FIRSTLETTER
  end;
  GroupKeyArray[Index] := Value
end;

{ TEasySorter}

constructor TEasySorter.Create(AnOwner: TEasySortManager);
begin
  inherited Create;
  FOwner := AnOwner;
end;

destructor TEasyOwnedPersistentView.Destroy;
begin
  FreeAndNil(FCanvasStore);
  inherited Destroy;
end;

function TEasyOwnedPersistentView.GetCanvasStore: TEasyCanvasStore;
begin
  if not Assigned(FCanvasStore) then
    FCanvasStore := TEasyCanvasStore.Create;
  Result := FCanvasStore
end;

procedure TEasyOwnedPersistentView.PaintCheckboxCore(CheckType: TEasyCheckType;
  OwnerListView: TCustomEasyListView; ACanvas: TCanvas; ARect: TRect; IsEnabled,
  IsChecked, IsHot, IsFlat, IsHovering, IsPending: Boolean; Obj: TEasyCollectionItem; Size: Integer);
var
  {$IFDEF SpTBX}
  CheckState: TCheckBoxState;
  {$ENDIF}
  {$IFDEF USETHEMES}
  uState: Longword;
  Part: BUTTONPARTS;
  {$ENDIF}
  Pt: TPoint;
begin
  {$IFDEF SpTBX}
  if not ((CheckType = ectNone) or (CheckType = ettNoneWithSpace)) then
  begin
    if CurrentTheme.Name <> 'Default' then
    begin
      if IsChecked then
        CheckState := cbChecked
      else
        CheckState := cbUnChecked;
      InflateRect(ARect, -1, -1);
      SpDrawXPCheckBoxGlyph(ACanvas, ARect, IsEnabled, CheckState, IsHovering, IsPending, True, thtTBX);
      Exit;
    end
  end;
  {$ENDIF}

  {$IFDEF USETHEMES}
  if OwnerListview.DrawWithThemes then
    begin
      uState := 0;
      Part := 0;
      case CheckType of
      ectBox:
        begin
          Part := BP_CHECKBOX;
          if IsEnabled then
          begin
            if IsHovering then
            begin
              if IsChecked then
                uState := CBS_CHECKEDHOT
              else
                uState := CBS_UNCHECKEDHOT
            end else
            if IsPending then
            begin
              if IsChecked then
                uState := CBS_CHECKEDPRESSED
              else
                uState := CBS_UNCHECKEDPRESSED
            end else
            begin
              if IsChecked then
                uState := CBS_CHECKEDNORMAL
              else
                uState := CBS_UNCHECKEDNORMAL
            end
          end else
          begin
            if IsChecked then
              uState := CBS_CHECKEDDISABLED
            else
              uState := CBS_UNCHECKEDDISABLED
          end
        end;
      ectRadio:
        begin
          Part := BP_RADIOBUTTON;
          if IsEnabled then
          begin
            if IsHovering then
            begin
              if IsChecked then
                uState := RBS_CHECKEDHOT
              else
                uState := RBS_UNCHECKEDHOT
            end else
            if IsPending then
            begin
              if IsChecked then
                uState := RBS_CHECKEDPRESSED
              else
                uState := RBS_UNCHECKEDPRESSED
            end else
            begin
              if IsChecked then
                uState := RBS_CHECKEDNORMAL
              else
                uState := RBS_UNCHECKEDNORMAL
            end
          end else
          begin
            if IsChecked then
              uState := RBS_CHECKEDDISABLED
            else
              uState := RBS_UNCHECKEDDISABLED
          end
        end
    end;

    DrawThemeBackground(OwnerListview.Themes.ButtonTheme, ACanvas.Handle, Part, uState, ARect, nil);
    Exit;
  end;
  {$ENDIF}

  case CheckType of
    ectBox:
      begin
        Pt := ARect.TopLeft;
        if IsEnabled then
        begin
          if IsFlat then
            DrawCheckBox(ACanvas, Pt, Size, clWhite, clBtnFace, clBlack, clBlack, clBlack, clBlack, IsChecked, IsEnabled, IsHot)
          else
            DrawCheckBox(ACanvas, Pt, Size, clWhite, clBtnFace, clBtnShadow, clBtnHighlight, cl3DDkShadow, cl3DLight, IsChecked, IsEnabled, IsHot)
        end else
        begin
          if IsFlat then
            DrawCheckBox(ACanvas, Pt, Size, clBtnFace, clBtnFace, clBtnShadow, clBtnShadow, clBtnShadow, clBtnShadow, IsChecked, IsEnabled, IsHot)
          else
            DrawCheckBox(ACanvas, Pt, Size, clBtnFace, clBtnFace, clBtnShadow, clBtnHighlight, cl3DDkShadow, cl3DLight, IsChecked, IsEnabled, IsHot)
        end;
      end;
    ectRadio:
      begin
        Pt :=ARect.TopLeft;
        if IsEnabled then
        begin
          if IsFlat then
            DrawRadioButton(ACanvas, Pt, Size, clWhite, clBtnFace, clBlack, clBlack, clBlack, clBlack, IsChecked, IsEnabled, IsHot)
          else
            DrawRadioButton(ACanvas, Pt, Size, clWhite, clBtnFace, clBtnShadow, clBtnHighlight, cl3DDkShadow, cl3DLight, IsChecked, IsEnabled, IsHot)
        end else
        begin
          if IsFlat then
            DrawRadioButton(ACanvas, Pt, Size, clBtnFace, clBtnFace, clBtnShadow, clBtnShadow, clBtnShadow, clBtnShadow, IsChecked, IsEnabled, IsHot)
          else
            DrawRadioButton(ACanvas, Pt, Size, clBtnFace, clBtnFace, clBtnShadow, clBtnHighlight, cl3DDkShadow, cl3DLight, IsChecked, IsEnabled, IsHot)
        end;
     end
  end
end;

constructor TEasyIncrementalSearchManager.Create(AnOwner: TCustomEasyListview);
begin
  inherited Create(AnOwner);
  FItemType := eisiVisible;
  FResetTime := 2000;
end;

destructor TEasyIncrementalSearchManager.Destroy;
begin
  EndTimer;
  inherited
end;

function TEasyIncrementalSearchManager.IsSearching: Boolean;
//
// Returns true if the manager is in within a search sequence
//
begin
  Result := eissSearching in State
end;

procedure TEasyIncrementalSearchManager.ClearSearch;
//
// Clears the search item and does any necessary clean up
begin
  FSearchItem := nil
end;

procedure TEasyIncrementalSearchManager.EndTimer;
//
// Kills and destroys the Timer
//
begin
  if eissTimerRunning in State then
  begin
    if KillTimer(0, hTimer) then
    begin
      hTimer := 0;
      Exclude(FState, eissTimerRunning);
      DisposeStub(FTimerStub);
    end else
      Exception.Create('Can not Destroy Incremental Search Timer');
  end
end;

procedure TEasyIncrementalSearchManager.HandleWMChar(var Msg: TWMChar);
//
// The WM_CHAR message is passed to the manager to handle the incremental
// search
//
  function CodePageFromLocale(Language: LCID): Integer;
  var
    Buf: array[0..6] of Char;
  begin
    // Determines the code page for a given locale.
    // Unfortunately there is no easier way than this, currently.
    GetLocaleInfo(Language, LOCALE_IDEFAULTANSICODEPAGE, Buf, 6);
    Result := StrToIntDef(Buf, GetACP);
  end;

  function KeyUnicode(C: Char): WideChar;
  // Converts the given character into its corresponding Unicode character
  // depending on the active keyboard layout.
  begin
    MultiByteToWideChar(CodePageFromLocale(GetKeyboardLayout(0) and $FFFF),
      MB_USEGLYPHCHARS, @C, 1, @Result, 1);
  end;


var
  CompareResult: Integer;
  StartItem: TEasyItem;
begin
  if Enabled and IsSearching then
  begin
   ResetTimer;
   if StartType <> eissStartOver then
      StartItem := SearchItem
    else
      StartItem := nil;

    CompareResult := 0;
    SearchBuffer := SearchBuffer + KeyUnicode(Char( Msg.CharCode));
    // Danger here is that SearchItem may never be nil if we do a rollover
    // type search
    if Assigned(SearchItem) then
    begin
      if SearchBuffer <> #13 then
        OwnerListview.DoIncrementalSearch(SearchItem, SearchBuffer, CompareResult);
      ResetTimer;
      if CompareResult <> 0 then
      begin
        case ItemType of
        eisiAll:               // Search All items in list
          begin
            while (CompareResult <> 0) and Assigned(SearchItem) do
            begin
              case Direction of
                eisdForward: SearchItem := OwnerListview.Groups.NextItem(SearchItem);
                eisdBackward: SearchItem := OwnerListview.Groups.PrevItem(SearchItem);
              end;
              if Assigned(SearchItem) then
                OwnerListview.DoIncrementalSearch(SearchItem, SearchBuffer, CompareResult);
            end
          end;
        eisiInitializedOnly:    // Search only initialized items
          begin
            while (CompareResult <> 0) and Assigned(SearchItem) do
            begin
              case Direction of
                eisdForward: SearchItem := OwnerListview.Groups.NextInitializedItem(SearchItem);
                eisdBackward: SearchItem := OwnerListview.Groups.PrevInitializedItem(SearchItem);
              end;
              if Assigned(SearchItem) then
                  OwnerListview.DoIncrementalSearch(SearchItem, SearchBuffer, CompareResult);
            end
          end;
        eisiVisible:            // Search only visible items
          begin
            while (CompareResult <> 0) and Assigned(SearchItem) do
            begin
              case Direction of
                eisdForward: SearchItem := OwnerListview.Groups.NextVisibleItem(SearchItem);
                eisdBackward: SearchItem := OwnerListview.Groups.PrevVisibleItem(SearchItem);
              end;
              if Assigned(SearchItem) then
                OwnerListview.DoIncrementalSearch(SearchItem, SearchBuffer, CompareResult);
            end
          end
        end;
      end;
      if Assigned(SearchItem) then
      begin
        // Found the item
        OwnerListview.Selection.ClearAll;
        OwnerListview.Selection.FocusedItem := SearchItem;
        if Assigned(SearchItem) then
        begin
          SearchItem.Selected := True;
          SearchItem.MakeVisible(emvAuto)
        end;
      end else
        SearchItem := StartItem;
    end
  end
end;

procedure TEasyIncrementalSearchManager.HandleWMKeyDown(var Msg:
TWMKeyDown);
//
// The WM_KEYDOWN message is passed to the manager to handle the incremental
// search
//
var
  Shift: TShiftState;
begin
  if Enabled then
  begin
    Shift := KeyDataToShiftState(Msg.KeyData);
    if (Shift * [ssCtrl, ssAlt] = []) and ((Msg.CharCode > VK_HELP) and (Msg.CharCode < VK_LWIN)) then
      StartSearch
  end
end;

procedure TEasyIncrementalSearchManager.ResetSearch;
//
// Ends and resets all search criteria
//
begin
  SearchBuffer := '';
  if StartType <> eissLastHit then
    ClearSearch;
  Exclude(FState, eissSearching);
  EndTimer;
end;

procedure TEasyIncrementalSearchManager.ResetTimer;
//
// Resets the timer to another FResetTime interval without stopping the current
// search process
//
begin
  EndTimer;
  StartTimer;
end;

procedure TEasyIncrementalSearchManager.SetSearchItem(Value: TEasyItem);
begin
  if Value <> FSearchItem then
  begin
    ClearSearch;
    FSearchItem := Value
  end
end;

procedure TEasyIncrementalSearchManager.StartSearch;

  procedure SetupStartOver;
  begin
    case ItemType of
      eisiAll:                // Search All items in list
        begin
          if Direction = eisdForward then
            SearchItem := OwnerListview.Groups.FirstItem
          else
            SearchItem := OwnerListview.Groups.LastItem
        end;
      eisiInitializedOnly:   // Search only initialized items
        begin
          if Direction = eisdForward then
            SearchItem := OwnerListview.Groups.FirstInitializedItem
          else
            SearchItem := OwnerListview.Groups.LastInitializedItem
        end;
      eisiVisible:           // Search only visible items
        begin
          if Direction = eisdForward then
            SearchItem := OwnerListview.Groups.FirstVisibleItem
          else
            SearchItem := OwnerListview.Groups.LastVisibleItem
        end;
      end
  end;

//
// Initializes the search called on WMKEYDOWN
//
begin
  // Only call once during a Search Sequence
  if not (eissSearching in State) then
  begin
    case StartType of
      eissStartOver:
        begin
          SetupStartOver;
        end;
      eissLastHit:
        begin
          // The Search Item is already set up, or not
          if not Assigned(SearchItem) then
            SetupStartOver    
        end;
      eissFocusedNode:
        begin
          // By definition the Focused Item is Visible and Initalized so
          // no other checks are necessary
          if Assigned(OwnerListview.Selection.FocusedItem) then
            SearchItem := OwnerListview.Selection.FocusedItem
          else
            SetupStartOver;
        end;
    end;
    StartTimer; // JDK 5.3.05
    Include(FState, eissSearching);
  end;
end;

procedure TEasyIncrementalSearchManager.StartTimer;
//
// Starts the Timer for the search
//
begin
  if Enabled and not(eissTimerRunning in State) then
  begin
    TimerStub := CreateStub(Self, @TEasyIncrementalSearchManager.TimerProc);
    hTimer := SetTimer(0, 0, ResetTime, TimerStub);
    Include(FState, eissTimerRunning);
  end
end;

procedure TEasyIncrementalSearchManager.TimerProc(Window: HWnd; uMsg: UINT;
  idEvent: UINT; dwTime: DWORD);
//
// The callback for the Timer.  A callback is not effected by any blocked message
// handler taking their sweet time.
//
begin
  ResetSearch;
end;

{ TEasyGridFilmStripGroup }
function TEasyGridFilmStripGroup.GetCellSize: TEasyCellSize;
begin
  Result := OwnerListview.CellSizes.FilmStrip
end;

procedure TEasyGridFilmStripGroup.SetCellSize(Value: TEasyCellSize);
begin
  OwnerListview.CellSizes.FilmStrip.Assign(Value)
end;

{ TEasyPersistent }
constructor TEasyPersistent.Create;
begin
  inherited Create;
end;

destructor TEasyPersistent.Destroy;
begin
  inherited Destroy;
end;

procedure TEasyPersistent.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
end;

{ TEasyGridGridGroup }
constructor TEasyGridGridGroup.Create(AnOwner: TCustomEasyListview; AnOwnerGroup: TEasyGroup);
begin
  inherited Create(AnOwner, AnOwnerGroup);
  FLayout := eglGrid
end;

function TEasyGridGridGroup.GetCellSize: TEasyCellSize;
begin
  Result := OwnerListview.CellSizes.Grid
end;

procedure TEasyGridGridGroup.Rebuild(PrevGroup: TEasyGroup; var NextVisibleItemIndex: Integer);
var
  i, Top, Bottom, Left, Offset, TopMargin,
  BottomMargin, VisibleCount, ColumnIndex, ColumnLeft: Integer;
  Item: TEasyItem;
  Columns: TEasyColumns;
begin
  if Assigned(PrevGroup) then
    Offset := PrevGroup.DisplayRect.Bottom
  else
    Offset := 0;

  ColumnIndex := 0;
  Columns := OwnerListview.Header.Columns;
  OwnerGroup.FDisplayRect := Rect(0, Offset, OwnerListview.Header.ViewWidth, Offset);
  // Prepare the VisibleList for the worse case, all are visible
  OwnerGroup.VisibleItems.Clear;
  OwnerGroup.VisibleItems.Capacity := OwnerGroup.Items.Count;

  Left := OwnerGroup.MarginLeft.RuntimeSize;

  TopMargin := OwnerGroup.MarginTop.RuntimeSize;
  BottomMargin := OwnerGroup.MarginBottom.RuntimeSize;
  if OwnerGroup.Visible then
  begin
    if OwnerGroup.Expanded and (OwnerGroup.Items.Count > 0) then
    begin
      VisibleCount := 0;
      Top := Offset + TopMargin;
      Bottom := Offset + CellSize.Height + TopMargin;
      for i := 0 to OwnerGroup.Items.Count - 1 do
      begin
        Item := OwnerGroup.Items.List.List[i]; // Direct Access for Speed
        if Item.Visible then
        begin
          Item.FVisibleIndex := NextVisibleItemIndex;
          Item.FVisibleIndexInGroup := VisibleCount;
          ColumnLeft := Columns[ColumnIndex].DisplayRect.Left;
          Item.FDisplayRect := Rect(Left + ColumnLeft, Top, Left + ColumnLeft + Columns[ColumnIndex].Width, Bottom);
          OwnerGroup.VisibleItems.Add(Item);
          Inc(ColumnIndex);
          if ColumnIndex >= Columns.Count then
          begin
            ColumnIndex := 0;
              Inc(Top, CellSize.Height);
              Inc(Bottom, CellSize.Height);
          end;
          Inc(VisibleCount);
          Inc(NextVisibleItemIndex);
        end else
          Item.FDisplayRect := Rect(Left, Top, Left, Top);
        OwnerGroup.FDisplayRect.Bottom := Item.FDisplayRect.Bottom + BottomMargin;
      end
    end else
      OwnerGroup.FDisplayRect := Rect(0, Offset, OwnerListview.Header.ViewWidth, Offset + TopMargin + BottomMargin);
  end;
  // Column Count does not relate to Report view columns.  It is a more primitive
  // and the Report columns are within the Grid Column
  FColumnCount := Columns.Count;
  if FColumnCount > 0 then
  begin
    FRowCount := OwnerGroup.VisibleItems.Count div FColumnCount;
    if OwnerGroup.VisibleItems.Count mod FColumnCount > 0 then
      Inc(FRowCount)
  end else
    FRowCount := 0
end;

procedure TEasyGridGridGroup.SetCellSize(Value: TEasyCellSize);
begin
  OwnerListview.CellSizes.Grid := Value
end;

{ TEasyAlphaBlender}
destructor TEasyAlphaBlender.Destroy;
begin
  inherited Destroy;
end;

procedure TEasyAlphaBlender.BasicBlend(Listview: TCustomEasyListview; ACanvas: TCanvas; ViewportRect: TRect; Color: TColor; Alpha: Byte = 128);
var
  R: TRect;
  Obj: THandle;
  Bits: Windows.BITMAP;
begin
  if Assigned(ACanvas) and Assigned(Listview) and not IsRectEmpty(ViewportRect) then
  begin
    Obj := GetCurrentObject(ACanvas.Handle, OBJ_BITMAP);
    if Obj <> 0 then
      if GetObject(Obj, SizeOf(Windows.BITMAP), @Bits) > 0 then
      begin
        R := Listview.Scrollbars.MapWindowRectToViewRect(Rect(0, 0, Bits.bmWidth, Bits.bmHeight));
        IntersectRect(R, ViewportRect, R);
        R := Listview.Scrollbars.MapViewRectToWindowRect(R);
        AlphaBlend(0, ACanvas.Handle, R, Point(0, 0), cbmConstantAlphaAndColor, Alpha, ColorToRGB(Color))
      end
  end

end;

procedure TEasyAlphaBlender.Blend(Listview: TCustomEasyListview; Obj: TEasyCollectionItem; ACanvas: TCanvas; ViewportRect: TRect; Image: TBitmap);
var
  BlendColor: TColor;
  BlendAlpha: Byte;
  Scratch: TBitmap;
  DoBlend: Boolean;
begin
  if not IsRectEmpty(ViewportRect) then
  begin
    GetBlendParams(Listview, Obj, BlendAlpha, BlendColor, DoBlend);
    if DoBlend and HasMMX then
    begin
      Scratch := TBitmap.Create;
      try
        Scratch.Width := Image.Width;
        Scratch.Height := Image.Height;
        Scratch.Assign(Image);
        Scratch.PixelFormat := pf32Bit;
        Scratch.TransparentMode := Image.TransparentMode;
        Scratch.TransparentColor := Image.TransparentColor;
        Scratch.Transparent := True;

        // Now force the bitmap to create a mask based on the transparent color
        Scratch.MaskHandle;
        // The AlphaBlend function is low level so TBitmap does not know anything happened to it
        AlphaBlend(0, Scratch.Canvas.Handle, Rect(0, 0, Scratch.Width, Scratch.Height), Point(0, 0), cbmConstantAlphaAndColor, BlendAlpha, ColorToRGB(BlendColor));
        // Since we got the mask before the AlphaBlend occured the original mask is
        // used and all is correct.
        ACanvas.Draw(ViewportRect.Left + (RectWidth(ViewportRect) - Scratch.Width) div 2,
                     ViewportRect.Top + (RectHeight(ViewportRect) - Scratch.Height) div 2,
                     Scratch);

      finally
        Scratch.Free
      end
    end else
      ACanvas.Draw(ViewportRect.Left + (RectWidth(ViewportRect) - Image.Width) div 2,
                     ViewportRect.Top + (RectHeight(ViewportRect) - Image.Height) div 2,
                     Image);
  end
end;

procedure TEasyAlphaBlender.GetBlendParams(Listview: TCustomEasyListview; Obj: TEasyCollectionItem; var BlendAlpha: Byte; var BlendColor: TColor; var DoBlend: Boolean);
begin
  DoBlend := False;
  if Assigned(Listview) then
  begin
    if Listview.Focused then
      begin
        if Obj.Enabled then
        begin
          BlendAlpha := Listview.Selection.BlendAlphaImage;
          BlendColor := Listview.Selection.Color
        end else
        begin
          BlendAlpha := Listview.DisabledBlendAlpha;
          BlendColor := Listview.DisabledBlendColor;
        end
      end else
      begin
        BlendAlpha := Listview.DisabledBlendAlpha;
        BlendColor := Listview.Selection.InactiveColor;
      end;

      DoBlend := Obj.Selected or Obj.Hilighted or (not Obj.Enabled and Listview.Focused)
  end
end;

{ TEasyTaskBand }
constructor TEasyTaskBand.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Groups.DefaultGroupView := TEasyViewTaskBandGroup;
  Groups.DefaultItemView := TEasyViewTaskBandItem;
  Groups.DefaultGrid := TGridTaskBandGroup;
  BackGround := TEasyTaskBandBackgroundManager.Create(Self);
  HotTrack.Enabled := True;
  PaintInfoGroup.CaptionIndent := 9;
  PaintInfoGroup.MarginBottom.Size := 3;
  PaintInfoGroup.MarginBottom.Visible := True;
  PaintInfoGroup.MarginLeft.Size := 11;
  PaintInfoGroup.MarginLeft.Visible := True;
  PaintInfoGroup.MarginRight.Size := 11;
  PaintInfoGroup.MarginRight.Visible := True;
  PaintInfoGroup.MarginTop.Size := 26;
  ShowGroupMargins := True;
  Selection.Enabled := False;
  HotTrack.GroupTrack := HotTrack.GroupTrack + [htgTopMargin]
end;

function TEasyTaskBand.CreateColumnPaintInfo: TEasyPaintInfoBaseColumn;
begin
  Result:= TEasyPaintInfoTaskBandColumn.Create(Self)
end;

function TEasyTaskBand.CreateGroupPaintInfo: TEasyPaintInfoBaseGroup;
begin
  Result := TEasyPaintInfoTaskBandGroup.Create(Self)
end;

function TEasyTaskBand.CreateItemPaintInfo: TEasyPaintInfoBaseItem;
begin
  Result:= TEasyPaintInfoTaskBandItem.Create(Self)
end;

function TEasyTaskBand.GetPaintInfoColumn: TEasyPaintInfoTaskBandColumn;
begin
  Result := inherited PaintInfoColumn as TEasyPaintInfoTaskbandColumn
end;

function TEasyTaskBand.GetPaintInfoGroup: TEasyPaintInfoTaskbandGroup;
begin
  Result := inherited PaintInfoGroup as TEasyPaintInfoTaskbandGroup
end;

function TEasyTaskBand.GetPaintInfoItem: TEasyPaintInfoTaskBandItem;
begin
  Result := inherited PaintInfoItem as TEasyPaintInfoTaskbandItem
end;

function TEasyTaskBand.GroupTestExpand(HitInfo: TEasyGroupHitTestInfoSet): Boolean;
begin
  Result:= egtOnHeader in HitInfo
end;

procedure TEasyTaskBand.SetPaintInfoColumn(const Value: TEasyPaintInfoTaskBandColumn);
begin
  inherited PaintInfoColumn := Value
end;

procedure TEasyTaskBand.SetPaintInfoGroup(const Value: TEasyPaintInfoTaskbandGroup);
begin
  inherited PaintInfoGroup := Value
end;

procedure TEasyTaskBand.SetPaintInfoItem(const Value: TEasyPaintInfoTaskBandItem);
begin
  inherited PaintInfoItem := Value
end;

{ TGridTaskBandGroup }
constructor TGridTaskBandGroup.Create(AnOwner: TCustomEasyListview; AnOwnerGroup: TEasyGroup);
begin
  inherited Create(AnOwner, AnOwnerGroup);
  CellSize := TEasyCellSize.Create(AnOwner)
end;

destructor TGridTaskBandGroup.Destroy;
begin
  inherited Destroy;
  FreeAndNil(FCellSize);
end;

function TGridTaskBandGroup.GetCellSize: TEasyCellSize;
begin
  FCellSize.FWidth := OwnerListview.ClientWidth - 1 - OwnerListview.PaintInfoGroup.MarginLeft.Size - OwnerListview.PaintInfoGroup.MarginRight.Size;
  FCellSize.FHeight := 24;
  Result := FCellSize
end;

function TGridTaskBandGroup.StaticTopItemMargin: Integer;
begin
  Result := 10;
end;

function TGridTaskBandGroup.StaticTopMargin: Integer;
begin
  Result := 11;
end;

procedure TGridTaskBandGroup.SetCellSize(Value: TEasyCellSize);
begin

end;

{ TGridSingleColumn }
function TGridSingleColumn.GetMaxColumns(Group: TEasyGroup; WindowWidth: Integer): Integer;
begin
  Result := 1;
end;

{ TEasyViewTaskBandGroup}
procedure TEasyViewTaskBandGroup.GetExpandImageSize(Group: TEasyGroup; var ImageW: Integer; var ImageH: Integer);
{$IFDEF USETHEMES}
var
  PartID, StateID: LongWord;
  R: TRect;
{$ENDIF}
begin
  ImageW := 0;
  ImageH := 0;
  if Group.Expandable then
  begin
    {$IFDEF USETHEMES}
    if Group.OwnerListview.DrawWithThemes then
    begin
      StateID := EBNGC_NORMAL;
      if Group.Expanded then
        PartID := EBP_NORMALGROUPCOLLAPSE
      else
        PartID := EBP_NORMALGROUPEXPAND;
      if Group.Hilighted then
        StateID := StateID or EBNGC_HOT;
      R := Rect(0, 0, 0, 0);
      // If too small it returns the negative rectangle of the ideal size
      if Succeeded(GetThemeBackgroundExtent(OwnerListview.Themes.ExplorerBarTheme, 0, PartID, StateID, R, R)) then
      begin
        ImageW := Abs(RectWidth(R));
        ImageH := Abs(RectHeight(R));
      end
    end else
    begin
      ImageW := 16;
      ImageH := 16;
    end;
    {$ELSE}
      ImageW := 16;
      ImageH := 16;
    {$ENDIF}
  end;
end;

procedure TEasyViewTaskBandGroup.GroupRectArray(Group: TEasyGroup; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; var RectArray: TEasyRectArrayObject);
//
// Grabs all the rectangles for the items within a cell in one call
// If PaintInfo is nil then the information is fetched automaticlly
//
var
  TextSize: TSize;
  HeaderBand, FooterBand: TRect;
  TempRectArray: TEasyRectArrayObject;
  ImageW, ImageH, ExpandImageW, ExpandImageH: Integer;
begin
  Group.Initialized := True;
  
  FillChar(RectArray, SizeOf(RectArray), #0);

  RectArray.GroupRect := ObjRect;
  RectArray.BackGndRect :=  Group.BoundsRectBkGnd;

  GetExpandImageSize(Group, ExpandImageW, ExpandImageH);
  GetImageSize(Group, ImageW, ImageH);

  if MarginEdge in [egmeTop, egmeBottom] then
  begin
    // Calculate the Expansion button first for the Header only
    if Group.Expandable and (MarginEdge = egmeTop) then
      RectArray.ExpandButtonRect := Rect(RectArray.BackGndRect.Right - Group.ExpandImageIndent - ExpandImageW,
                      RectArray.GroupRect.Top,
                      RectArray.BackGndRect.Right,
                      RectArray.GroupRect.Bottom)
    else   // Make the ExpandButton R a width of 0
      RectArray.ExpandButtonRect := Rect(RectArray.GroupRect.Left,
                      RectArray.GroupRect.Top,
                      RectArray.GroupRect.Left,
                      RectArray.GroupRect.Bottom);

    if (Group.CheckType <> ectNone) and (MarginEdge in [egmeTop]) then
    begin
      RectArray.CheckRect := Checks.Bound[Group.Checksize];
      OffsetRect(RectArray.CheckRect, RectArray.BackGndRect.Left + Group.CheckIndent, ObjRect.Top + (RectHeight(ObjRect) - RectHeight(RectArray.CheckRect)) div 2);
    end else
    begin
      // CheckRect is a 0 width
      RectArray.CheckRect := ObjRect;
      RectArray.CheckRect.Left := RectArray.BackGndRect.Left;
      RectArray.CheckRect.Right := RectArray.BackGndRect.Left;
    end;


    // Now Calculate the image for the header or the footer
    if Group.ImageIndex > -1 then
      RectArray.IconRect := Rect(RectArray.CheckRect.Right + Group.ImageIndent,
                    RectArray.GroupRect.Top,
                    RectArray.CheckRect.Right + ImageW + Group.ImageIndent,
                    RectArray.GroupRect.Bottom)
    else   // Make the IconR a width of 0
      RectArray.IconRect := Rect(RectArray.CheckRect.Right,
                    RectArray.CheckRect.Top,
                    RectArray.CheckRect.Right,
                    RectArray.CheckRect.Bottom);

    // Now the Label rect may be calculated for the header or footer
    RectArray.LabelRect := Rect(RectArray.IconRect.Right + Group.CaptionIndent,
                   RectArray.ExpandButtonRect.Top,
                   RectArray.ExpandButtonRect.Left,
                   RectArray.ExpandButtonRect.Bottom);


    // Calculate the text size for the text based on the above font
    if Assigned(OwnerListview.ScratchCanvas) then
    begin
      LoadTextFont(Group, OwnerListview.ScratchCanvas);
      TextSize := TextExtentW(Group.Caption, OwnerListview.ScratchCanvas.Font);
    end else
    begin
      TextSize.cx := 0;
      TextSize.cy := 0
    end;
    RectArray.TextRect := Rect(RectArray.LabelRect.Left,
                               RectArray.LabelRect.Top,
                               RectArray.LabelRect.Left + TextSize.cx,
                               RectArray.LabelRect.Top + TextSize.cy);

    if RectArray.TextRect.Right > RectArray.LabelRect.Right then
      RectArray.TextRect.Right := RectArray.LabelRect.Right;
    if RectArray.TextRect.Bottom > RectArray.LabelRect.Bottom then
      RectArray.TextRect.Bottom := RectArray.LabelRect.Bottom;

    case Group.Alignment of
      taLeftJustify:  OffsetRect(RectArray.TextRect, 0, 0);
      taRightJustify: OffsetRect(RectArray.TextRect, RectWidth(RectArray.LabelRect) - (RectWidth(RectArray.TextRect)), 0);
      taCenter: OffsetRect(RectArray.TextRect, (RectWidth(RectArray.LabelRect) - RectWidth(RectArray.TextRect)) div 2, 0);
    end;

    case Group.VAlignment of
      evaBottom: OffsetRect(RectArray.TextRect, 0, RectHeight(RectArray.GroupRect) - (RectHeight(RectArray.TextRect) + Group.BandThickness + Group.BandMargin));
      evaCenter: OffsetRect(RectArray.TextRect, 0, (RectHeight(RectArray.GroupRect) - RectHeight(RectArray.TextRect)) div 2);
    end;
    // Use the calculated label rectangle to position where the text goes


    if Group.BandEnabled then
    begin
      if Group.BandFullWidth then
        RectArray.BandRect := Rect(RectArray.GroupRect.Left,
                           RectArray.GroupRect.Bottom - Group.BandMargin - Group.BandThickness,
                           RectArray.GroupRect.Right,
                           RectArray.GroupRect.Bottom - Group.BandMargin)
      else
        RectArray.BandRect := Rect(RectArray.GroupRect.Left,
                           RectArray.GroupRect.Bottom - Group.BandMargin - Group.BandThickness,
                           RectArray.GroupRect.Left + Group.BandLength,
                           RectArray.GroupRect.Bottom - Group.BandMargin);

      OffsetRect(RectArray.BandRect, Group.BandIndent, 0);
    end;

  end else
  begin  // Calculate the margin rectangles

    // Need to send nil so the user attributes are fetched for the header
    GroupRectArray(Group, egmeTop, Group.BoundsRectTopMargin, TempRectArray);
    HeaderBand := TempRectArray.BandRect;

    // Need to send nil so the user attributes are fetched for the footer
    GroupRectArray(Group, egmeBottom, Group.BoundsRectBottomMargin, TempRectArray);
    FooterBand := TempRectArray.BandRect;

    if MarginEdge  = egmeLeft then
      RectArray.BandRect := Rect(RectArray.GroupRect.Left + (RectWidth(RectArray.GroupRect) - Group.BandThickness) div 2,
                            HeaderBand.Top,
                            RectArray.GroupRect.Right,
                            FooterBand.Bottom - 1);
    if MarginEdge  = egmeRight then
      RectArray.BandRect := Rect(RectArray.GroupRect.Left,
                            HeaderBand.Top,
                            RectArray.GroupRect.Right - (RectWidth(RectArray.GroupRect) - Group.BandThickness) div 2,
                            FooterBand.Bottom - 1)
  end;
end;

procedure TEasyViewTaskBandGroup.LoadTextFont(Group: TEasyGroup; ACanvas: TCanvas);
begin
  {$IFDEF USETHEMES}
  inherited LoadTextFont(Group, ACanvas);
  if not(Group.OwnerListview.DrawWithThemes) then
  begin
    if Group.Bold then
      ACanvas.Font.Color := clHighlightText
  end;
  {$ELSE}
  inherited LoadTextFont(Group, ACanvas);
  if Group.Bold then
    ACanvas.Font.Color := clHighlightText
  {$ENDIF}
end;

procedure TEasyViewTaskBandGroup.PaintBackground(Group: TEasyGroup; ACanvas: TCanvas; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject);

  procedure DrawNonThemed;
  begin
    if Group.Bold then
      ACanvas.Brush.Color := clHighlight
    else
      ACanvas.Brush.Color := clBtnFace;
    case MarginEdge of
      egmeBackground: ACanvas.FrameRect(RectArray.BackGndRect);
      egmeTop: ACanvas.FillRect(RectArray.GroupRect);
    end
  end;

{$IFDEF USETHEMES}
var
  PartID, StateID: LongWord;
  R, HeaderR: TRect;
{$ENDIF}
begin
  {$IFDEF USETHEMES}
  if Group.OwnerListview.DrawWithThemes then
  begin
    case MarginEdge of
    egmeBackground:
      begin
        // Draw the group background
        R := RectArray.BackGndRect;
        if Group.Bold then
          PartID := EBP_SPECIALGROUPBACKGROUND
        else
          PartID := EBP_NORMALGROUPBACKGROUND;
        StateID := 0;
        DrawThemeBackground(OwnerListview.Themes.ExplorerBarTheme, ACanvas.Handle, PartID, StateID, R, nil);
     end;
    egmeTop:
      begin
        // Draw the group header
        HeaderR := RectArray.BackGndRect;
        HeaderR.Bottom := HeaderR.Top - 1;
        HeaderR.Top := HeaderR.Top - OwnerListview.PaintInfoGroup.MarginTop.RuntimeSize;
        if Group.Bold then
          PartID := EBP_SPECIALGROUPHEAD
        else
          PartID := EBP_NORMALGROUPHEAD;
        StateID := 0;
        DrawThemeBackground(OwnerListview.Themes.ExplorerBarTheme, ACanvas.Handle, PartID, StateID, HeaderR, nil);
      end
    end
  end else
    DrawNonThemed;
  Exit;
  {$ELSE}
  DrawNonThemed;
  {$ENDIF}
end;

procedure TEasyViewTaskBandGroup.PaintBand(Group: TEasyGroup; ACanvas: TCanvas; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject);
begin
  // Don't do inherited
end;

procedure TEasyViewTaskBandGroup.PaintExpandButton(Group: TEasyGroup; ACanvas: TCanvas; MarginEdge: TEasyGroupMarginEdge; ObjRect: TRect; RectArray: TEasyRectArrayObject);

  procedure DrawNonThemed;
  var
    RCenterX, RCenterY, RCenterY1, RCenterY2: Integer;
    ExpandW, ExpandH: Integer;
    R: TRect;
  begin
    GetExpandImageSize(Group, ExpandW, ExpandH);
    if Group.Bold then
      ACanvas.Pen.Color := clHighlightText
    else
      ACanvas.Pen.Color := clBlack;
    ACanvas.Pen.Width := 1;
    RCenterX := RectArray.ExpandButtonRect.Left + ExpandW div 2;
    RCenterY := RectArray.ExpandButtonRect.Top + ((RectHeight(RectArray.ExpandButtonRect)-ExpandH) div 2) + (ExpandH div 2);
    if Group.Expanded then
    begin
      RCenterY2 := RCenterY;
      RCenterY1 := RCenterY2 - 4;
      ACanvas.MoveTo(RCenterX, RCenterY1);
      ACanvas.LineTo(RCenterX - 4, RCenterY1 + 4);
      ACanvas.MoveTo(RCenterX, RCenterY1);
      ACanvas.LineTo(RCenterX + 4, RCenterY1 + 4);
      ACanvas.MoveTo(RCenterX, RCenterY2);
      ACanvas.LineTo(RCenterX - 4, RCenterY2 + 4);
      ACanvas.MoveTo(RCenterX, RCenterY2);
      ACanvas.LineTo(RCenterX + 4, RCenterY2 + 4);
      Inc(RCenterY1);
      Inc(RCenterY2);
      ACanvas.MoveTo(RCenterX, RCenterY1);
      ACanvas.LineTo(RCenterX - 3, RCenterY1 + 3);
      ACanvas.MoveTo(RCenterX, RCenterY1);
      ACanvas.LineTo(RCenterX + 3, RCenterY1 + 3);
      ACanvas.MoveTo(RCenterX, RCenterY2);
      ACanvas.LineTo(RCenterX - 3, RCenterY2 + 3);
      ACanvas.MoveTo(RCenterX, RCenterY2);
      ACanvas.LineTo(RCenterX + 3, RCenterY2 + 3);
    end else
    begin
      RCenterY2 := RCenterY;
      RCenterY1 := RCenterY2 + 4;
      ACanvas.MoveTo(RCenterX, RCenterY1);
      ACanvas.LineTo(RCenterX - 4, RCenterY1 - 4);
      ACanvas.MoveTo(RCenterX, RCenterY1);
      ACanvas.LineTo(RCenterX + 4, RCenterY1 - 4);
      ACanvas.MoveTo(RCenterX, RCenterY2);
      ACanvas.LineTo(RCenterX - 4, RCenterY2 - 4);
      ACanvas.MoveTo(RCenterX, RCenterY2);
      ACanvas.LineTo(RCenterX + 4, RCenterY2 - 4);
      Dec(RCenterY1);
      Dec(RCenterY2);
      ACanvas.MoveTo(RCenterX, RCenterY1);
      ACanvas.LineTo(RCenterX - 3, RCenterY1 - 3);
      ACanvas.MoveTo(RCenterX, RCenterY1);
      ACanvas.LineTo(RCenterX + 3, RCenterY1 - 3);
      ACanvas.MoveTo(RCenterX, RCenterY2);
      ACanvas.LineTo(RCenterX - 3, RCenterY2 - 3);
      ACanvas.MoveTo(RCenterX, RCenterY2);
      ACanvas.LineTo(RCenterX + 3, RCenterY2 - 3);
    end;

    if Group.Hilighted then
    begin
      R := Rect(RCenterX - ExpandW div 2,
                RCenterY - ExpandH div 2,
                RCenterX + ExpandW div 2,
                RCenterY + ExpandH div 2);
      DrawEdge(ACanvas.Handle, R, BDR_RAISEDOUTER, BF_RECT);
    end
  end;

{$IFDEF USETHEMES}
var
  PartID, StateID: LongWord;
{$ENDIF}
begin
  if (MarginEdge = egmeTop) and Group.Expandable then
  begin
    {$IFDEF USETHEMES}
    if Group.OwnerListview.DrawWithThemes then
    begin
      StateID := EBNGC_NORMAL;
      if Group.Bold then
      begin
        if Group.Expanded then
          PartID := EBP_SPECIALGROUPCOLLAPSE
        else
          PartID := EBP_SPECIALGROUPEXPAND;
      end else
      begin
        if Group.Expanded then
          PartID := EBP_NORMALGROUPCOLLAPSE
        else
          PartID := EBP_NORMALGROUPEXPAND;
      end;
      if Group.Hilighted then
        StateID := StateID or EBNGC_HOT;
      DrawThemeBackground(OwnerListview.Themes.ExplorerBarTheme, ACanvas.Handle, PartID, StateID, RectArray.ExpandButtonRect, nil);
    end else
      DrawNonThemed;
    {$ELSE}
    DrawNonThemed;
    {$ENDIF}
  end
end;

procedure TEasyViewTaskBandGroup.PaintText(Group: TEasyGroup; MarginEdge: TEasyGroupMarginEdge; ACanvas: TCanvas; ObjRect: TRect; RectArray: TEasyRectArrayObject);
{$IFDEF USETHEMES}
var
  PartID, StateID: LongWord;
  Flags, Flags2: DWORD;
{$ENDIF}
begin
  {$IFDEF USETHEMES}
  if (MarginEdge = egmeTop) and Group.OwnerListview.DrawWithThemes then
  begin
    if Group.Bold then
      PartID := EBP_SPECIALGROUPHEAD
    else
      PartID := EBP_NORMALGROUPHEAD;
    StateID := 0;

    Flags := 0;
    case Group.Alignment of
      taLeftJustify: Flags := Flags or DT_LEFT;
      taRightJustify: Flags := Flags or DT_RIGHT;
      taCenter:  Flags := Flags or DT_CENTER;
    end;

    case Group.VAlignment of
      evaTop: Flags := Flags or DT_TOP;
      evaCenter: Flags := Flags or DT_VCENTER;
      evaBottom:  Flags := Flags or DT_BOTTOM;
    end;

    Flags := Flags or DT_SINGLELINE or DT_END_ELLIPSIS;
    if Group.Enabled then
      Flags2 := 0
    else
      Flags2 := 1;
    DrawThemeText(OwnerListview.Themes.ExplorerBarTheme, ACanvas.Handle, PartID, StateID, PWideChar(Group.Caption), -1, Flags, Flags2, RectArray.LabelRect);
  end else
    inherited;
  {$ELSE}
    inherited;
  {$ENDIF}
end;

{ TEasyTaskBandBackgroundManager }
procedure TEasyTaskBandBackgroundManager.PaintTo(ACanvas: TCanvas; ARect: TRect; PaintDefault: Boolean);
{$IFDEF USETHEMES}
var
  PartID, StateID: LongWord;
  R: TRect;
  Theme: HTheme;
{$ENDIF}
begin
  {$IFDEF USETHEMES}
  Theme := OwnerListview.Themes.ExplorerBarTheme;
  if OwnerListview.DrawWithThemes then
  begin
    // Draw the blue background
    R := OwnerListview.ClientRect;
    PartID := 0;
    StateID := 0;
    DrawThemeBackground(Theme, ACanvas.Handle, PartID, StateID, R, nil);
  end
  {$ENDIF}
end;

function TEasyListview.GetPaintInfoColumn: TEasyPaintInfoColumn;
begin
  Result := inherited PaintInfoColumn as TEasyPaintInfoColumn
end;

function TEasyListview.GetPaintInfoGroup: TEasyPaintInfoGroup;
begin
  Result :=  inherited PaintInfoGroup as TEasyPaintInfoGroup
end;

function TEasyListview.GetPaintInfoItem: TEasyPaintInfoItem;
begin
   Result := inherited PaintInfoItem as TEasyPaintInfoItem
end;

procedure TEasyListview.SetPaintInfoColumn(const Value: TEasyPaintInfoColumn);
begin
  inherited PaintInfoColumn := Value
end;

procedure TEasyListview.SetPaintInfoGroup(const Value: TEasyPaintInfoGroup);
begin
  inherited PaintInfoGroup := Value
end;

procedure TEasyListview.SetPaintInfoItem(const Value: TEasyPaintInfoItem);
begin
  inherited PaintInfoItem := Value
end;

{ TCanvasStore }
destructor TEasyCanvasStore.Destroy;
begin
  FreeAndNil(FFont);
  FreeAndNil(FBrush);
  FreeAndNil(FPen);
  inherited Destroy;
end;

procedure TEasyCanvasStore.RestoreCanvasState(Canvas: TCanvas);
begin
  Canvas.Pen.Assign(Pen);
  Canvas.Brush.Assign(Brush);
  Canvas.Font.Assign(Font);
end;

procedure TEasyCanvasStore.StoreCanvasState(Canvas: TCanvas);
begin
  if not Assigned(Pen) then
    Pen := TPen.Create;
  if not Assigned(Brush) then
    Brush := TBrush.Create;
  if not Assigned(Font) then
    Font := TFont.Create;
  Pen.Assign(Canvas.Pen);
  Brush.Assign(Canvas.Brush);
  Font.Assign(Canvas.Font)
end;

procedure TEasyMemoEditor.CalculateEditorRect(NewText: WideString; var NewRect: TRect);
var
  DrawFlags: TCommonDrawTextWFlags;
  DC: HDC;
  Font, OldFont: HFont;
  TextM: TTextMetric;
begin
  OldFont := 0;

  if NewText = '' then
    NewText := ' ';

  Font := GetEditorFont.Handle;
  DrawFlags := [dtCalcRectAdjR, dtCalcRect, dtCalcRectAlign];

  // Center horizontally for multi-line edits
  DrawFlags := DrawFlags + [dtCenter];

  DC := GetDC(Editor.Handle);
  try
    OldFont := SelectObject(DC, Font);

    NewRect := RectArray.LabelRect;
    InflateRect(NewRect, -4, -2);

    NewRect := Listview.Scrollbars.MapViewRectToWindowRect(NewRect);

    DrawTextWEx(DC, NewText, NewRect, DrawFlags, -1);

    InflateRect(NewRect, H_STRINGEDITORMARGIN, V_STRINGEDITORMARGIN * 2);

    GetTextMetrics(DC, TextM);

    if NewRect.Right > Listview.ClientWidth - TextM.tmAveCharWidth + H_STRINGEDITORMARGIN then
      NewRect.Right := Listview.ClientWidth - TextM.tmAveCharWidth + H_STRINGEDITORMARGIN;
    if NewRect.Bottom > Listview.ClientHeight - V_STRINGEDITORMARGIN then
      NewRect.Bottom := Listview.ClientHeight - V_STRINGEDITORMARGIN;

    // Center horizontally for multi-line edits
    NewRect.Right := NewRect.Left + RectWidth(NewRect)
  finally
    if OldFont <> 0 then
      SelectObject(DC, OldFont);
    ReleaseDC(Editor.Handle, DC);
  end
end;

procedure TEasyMemoEditor.CreateEditor(var AnEditor: TWinControl; Column: TEasyColumn);
begin
  AnEditor := TEasyMemo.Create(nil);
  (AnEditor as TEasyMemo).Alignment := taCenter;
  (AnEditor as TEasyMemo).Text := EditText(Item, Column);
  (AnEditor as TEasyMemo).Ctl3D := False;
  (AnEditor as TEasyMemo).BorderStyle := bsSingle;
  (AnEditor as TEasyMemo).OnKeyDown := OnEditKeyDown;
  {$IFDEF COMPILER_6_UP}
  (AnEditor as TEasyMemo).BevelInner := bvNone;
  (AnEditor as TEasyMemo).BevelOuter := bvNone;
  (AnEditor as TEasyMemo).BevelKind := bkNone;
  {$ENDIF}
end;

function TEasyMemoEditor.GetEditorFont: TFont;
begin
  Result := (Editor as TEasyMemo).Font
end;

function TEasyMemoEditor.GetText: VAriant;
begin
  Result := (Editor as TEasyMemo).Text
end;

procedure TEasyMemoEditor.OnEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
//
// Check to see if the user is finished, if not test to see if the edit needs
// to be resized to reflect the new text
//
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    AcceptEdit;
  end else
    PostMessage(Editor.Handle, WM_EDITORRESIZE, 0, 0);
  FModified := True;
end;

procedure TEasyMemoEditor.SetEditorFocus;
begin
  inherited SetEditorFocus;
  (Editor as TEasyMemo).SelectAll;
end;

{ TEasyStringEditor}
procedure TEasyStringEditor.CalculateEditorRect(NewText: WideString; var NewRect: TRect);
var
  DrawFlags: TCommonDrawTextWFlags;
  DC: HDC;
  Font, OldFont: HFont;
  TextM: TTextMetric;
begin
  OldFont := 0;

  if NewText = '' then
    NewText := ' ';

  Font := GetEditorFont.Handle;
  DrawFlags := [dtCalcRectAdjR, dtCalcRect, dtCalcRectAlign];

  DrawFlags := DrawFlags + [dtLeft, dtVCenter];

  DC := GetDC(Editor.Handle);
  try
    OldFont := SelectObject(DC, Font);

    NewRect := RectArray.LabelRect;
    InflateRect(NewRect, -4, -2);

    NewRect := Listview.Scrollbars.MapViewRectToWindowRect(NewRect);

    DrawTextWEx(DC, NewText, NewRect, DrawFlags, 1);

    InflateRect(NewRect, H_STRINGEDITORMARGIN div 2, V_STRINGEDITORMARGIN);

    GetTextMetrics(DC, TextM);

    if NewRect.Right > Listview.ClientWidth - TextM.tmAveCharWidth + H_STRINGEDITORMARGIN then
      NewRect.Right := Listview.ClientWidth - TextM.tmAveCharWidth + H_STRINGEDITORMARGIN;
    if NewRect.Bottom > Listview.ClientHeight - V_STRINGEDITORMARGIN then
      NewRect.Bottom := Listview.ClientHeight - V_STRINGEDITORMARGIN;

    NewRect.Right := NewRect.Left + RectWidth(NewRect) + TextM.tmAveCharWidth;

  finally
    if OldFont <> 0 then
      SelectObject(DC, OldFont);
    ReleaseDC(Editor.Handle, DC);
  end
end;

procedure TEasyStringEditor.CreateEditor(var AnEditor: TWinControl; Column: TEasyColumn);
begin
  AnEditor := TEasyEdit.Create(nil);
  (AnEditor as TEasyEdit).Text := EditText(Item, Column);
  (AnEditor as TEasyEdit).Ctl3D := False;
  (AnEditor as TEasyEdit).BorderStyle := bsSingle;
  (AnEditor as TEasyEdit).OnKeyDown := OnEditKeyDown;
  {$IFDEF COMPILER_6_UP}
  (AnEditor as TEasyEdit).BevelInner := bvNone;
  (AnEditor as TEasyEdit).BevelOuter := bvNone;
  (AnEditor as TEasyEdit).BevelKind := bkNone;
  {$ENDIF}
end;

function TEasyStringEditor.GetEditorFont: TFont;
begin
  Result := (Editor as TEasyEdit).Font
end;

function TEasyStringEditor.GetText: Variant;
begin
  Result := (Editor as TEasyEdit).Text
end;

procedure TEasyStringEditor.OnEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
//
// Check to see if the user is finished, if not test to see if the edit needs
// to be resized to reflect the new text
//
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    AcceptEdit;
  end else
    PostMessage(Editor.Handle, WM_EDITORRESIZE, 0, 0);
  FModified := True;
end;

procedure TEasyStringEditor.SetEditorFocus;
begin
  inherited SetEditorFocus;
  (Editor as TEasyEdit).SelectAll;
end;

initialization
  OleInitialize(nil);
  Screen.Cursors[crVHeaderSplit] := LoadCursor(hInstance, CURSOR_VHEADERSPLIT);
  HeaderClipboardFormat := RegisterClipboardFormat(EASYLISTVIEW_HEADER_CLIPFORMAT);
  AlphaBlender := TEasyAlphaBlender.Create;

finalization
  FreeAndNil(AlphaBlender);
  OleUnInitialize();

end.
