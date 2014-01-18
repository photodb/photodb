unit OpenCV.Core;

interface

uses
  OpenCV.Lib,
  Windows;

{$IFDEF DEBUG}
{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O-,P+,Q+,R+,S-,T-,U-,V+,W+,X+,Y+,Z1}
{$ELSE}
{$A8,B-,C-,D-,E-,F-,G+,H+,I+,J+,K-,L-,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y-,Z1}
{$ENDIF}
{$WARN SYMBOL_DEPRECATED OFF}
{$WARN SYMBOL_PLATFORM OFF}
{$WARN UNIT_PLATFORM OFF}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}
{$POINTERMATH ON}

const
  // Ќаименьшее число дл€ которого выполн€етс€ условие 1.0+DBL_EPSILON <> 1.0
  DBL_EPSILON = 2.2204460492503131E-016;
  DBL_MAX     = 1.7976931348623157E+308;
  FLT_EPSILON = 1.19209290E-07;
  FLT_MAX     = 1E+37;

Type

  Float   = Single;
  pFloat  = ^Float;
  ppFloat = ^pFloat;

  TSingleArray1D = array [0 .. 1] of Single;
  pSingleArray1D = ^TSingleArray1D;
  TSingleArray2D = array [0 .. 1] of pSingleArray1D;
  pSingleArray2D = ^TSingleArray2D;

  TCVChar       = AnsiChar;
  pCVChar       = pAnsiChar;
  TpCVCharArray = array [0 .. 1] of pCVChar;
  ppCVChar      = ^TpCVCharArray;
  CVChar        = AnsiChar;

type
  uchar = Byte;
{$EXTERNALSYM uchar}
  ushort = Word;
{$EXTERNALSYM ushort}
  schar = ShortInt;
{$EXTERNALSYM schar}
  pschar = ^schar;
{$EXTERNALSYM pschar}
  unsigned = longint;
{$EXTERNALSYM unsigned}
  punsigned = ^longint;
{$EXTERNALSYM punsigned}

type
  pIplImage       = ^TIplImage;
  pIplROI         = ^TIplROI;
  pIplTileInfo    = ^TIplTileInfo;

  pCvArr = Pointer;

  TIplROI = packed record
    coi: Integer; (* 0 - no COI (all channels are selected), 1 - 0th channel is selected ... *)
    xOffset: Integer;
    yOffset: Integer;
    width: Integer;
    height: Integer;
  end;

  TiplCallBack = procedure(img: pIplImage; xIndex: Integer; yIndex: Integer; mode: Integer);

  TIplTileInfo = packed record
    callBack: TiplCallBack;
    id: Pointer;
    tileData: pCVChar;
    width: Integer;
    height: Integer;
  end;

  TA4CVChar = array [0 .. 3] of CVChar;

  TIplImage = packed record
    nSize: Integer;        (* sizeof(IplImage) *)
    id: Integer;           (* version (=0) *)
    nChannels: Integer;    (* Most of OpenCV functions support 1,2,3 or 4 channels *)
    alphaChannel: Integer; (* Ignored by OpenCV *)
    depth: Integer; (* Pixel depth in bits: Pixel depth in bits: IPL_DEPTH_8U, IPL_DEPTH_8S, IPL_DEPTH_16S,
      IPL_DEPTH_32S, IPL_DEPTH_32F and IPL_DEPTH_64F are supported. *)
    colorModel: TA4CVChar;   (* Ignored by OpenCV *)
    channelSeq: TA4CVChar;   (* ditto *)
    dataOrder: Integer;                     (* 0 - interleaved color channels, 1 - separate color channels. *)
    origin: Integer;                        (* 0 - top-left origin, *)
    align: Integer;                         (* Alignment of image rows (4 or 8). *)
    width: Integer;                         (* Image width in pixels. *)
    height: Integer;                        (* Image height in pixels. *)
    roi: pIplROI;                           (* Image ROI. If NULL, the whole image is selected. *)
    maskROI: pIplImage;                     (* Must be NULL. *)
    imageId: Pointer;                       (* "           " *)
    tileInfo: pIplTileInfo;                 (* "           " *)
    imageSize: Integer;                     (* Image data size in bytes *)
    imageData: pByte;                       (* Pointer to aligned image data. *)
    widthStep: Integer;                     (* Size of aligned image row in bytes. *)
    BorderMode: array [0 .. 3] of Integer;  (* Ignored by OpenCV. *)
    BorderConst: array [0 .. 3] of Integer; (* Ditto. *)
    imageDataOrigin: pByte;                 (* Pointer to very origin of image data *)
  end;

type
  pCvMemBlock = ^TCvMemBlock;

  TCvMemBlock = packed record
    prev: pCvMemBlock;
    next: pCvMemBlock;
  end;

type
  pCvMemStorage = ^TCvMemStorage;

  TCvMemStorage = packed record
    signature: Integer;
    bottom: pCvMemBlock;
    top: pCvMemBlock; (* First allocated block. *)
    parent: pCvMemStorage;
    (* Current memory block - top of the stack. *)    (* We get new blocks from parent as needed. *)
    block_size: Integer;                              (* Block size. *)
    free_space: Integer;                              (* Remaining free space in current block. *)
  end;

type
  pCvMemStoragePos = ^TCvMemStoragePos;

  TCvMemStoragePos = packed record
    top: pCvMemBlock;
    free_space: Integer;
  end;

  (* ********************************** Sequence ****************************************** *)
type
  pCvSeqBlock = ^TCvSeqBlock;

  TCvSeqBlock = packed record
    prev: pCvSeqBlock;    (* Previous sequence block. *)
    next: pCvSeqBlock;    (* Next sequence block. *)
    start_index: Integer; (* Index of the first element in the block + *)
    count: Integer;       (* Number of elements in the block. *)
    data: Pointer;        (* Pointer to the first element of the block. *)
  end;

  pCvSeq      = ^TCvSeq;
  pCvSeqArray = array [0 .. 1] of pCvSeq;
  ppCvSeq     = ^pCvSeqArray;

  TCvSeq = packed record
    flags: Integer;           (* Miscellaneous flags. *)
    header_size: Integer;     (* Size of sequence header. *)
    h_prev: pCvSeq;           (* Previous sequence. *)
    h_next: pCvSeq;           (* Next sequence. *)
    v_prev: pCvSeq;           (* 2nd previous sequence. *)
    v_next: pCvSeq;           (* 2nd next sequence. *)
    total: Integer;           (* Total number of elements. *)
    elem_size: Integer;       (* Size of sequence element in bytes. *)
    block_max: Pointer;       (* Maximal bound of the last block. *)
    ptr: pschar;              (* Current write pointer. *)
    delta_elems: Integer;     (* Grow seq this many at a time. *)
    storage: pCvMemStorage;   (* Where the seq is stored. *)
    free_blocks: pCvSeqBlock; (* Free blocks list. *)
    first: pCvSeqBlock;       (* Pointer to the first sequence block. *)
  end;

  (* ****************************** CvPoint and variants ********************************** *)

type
  pCvPoint = ^TCvPoint;

  TCvPoint = packed record
    x: Integer;
    y: Integer;
  end;

  TCvPointArray = array [0 .. 100] of TCvPoint;
  pCvPointArray = ^TCvPointArray;

  pCvPoint2D32f = ^TCvPoint2D32f;

  TCvPoint2D32f = packed record
    x: Single;
    y: Single;
  end;

  pCvPoint3D32f = ^TCvPoint3D32f;

  TCvPoint3D32f = packed record
    x: Single;
    y: Single;
    z: Single;
  end;

function cvPoint3D32f(const x, y, z: Double): TCvPoint3D32f; inline;

Type
  TCvPoint2D64f = packed record
    x: Double;
    y: Double;
  end;

  TCvPoint3D64f = packed record
    x: Double;
    y: Double;
    z: Double;
  end;

Const
  cvZeroPoint: TCvPoint = (x: 0; y: 0);

type
  pCvSize = ^TCvSize;

  TCvSize = packed record
    width: Integer;
    height: Integer;
  end;

type
  pCvRect = ^TCvRect;

  TCvRect = packed record
    x: Integer;
    y: Integer;
    width: Integer;
    height: Integer;
  end;

type
  pCvMat  = ^TCvMat;
  ppCvMat = ^pCvMat;

  TCvMat = packed record
    _type: Integer;
    step: Integer;

    refcount: PInteger;
    hdr_refcount: Integer;

    data: Pointer;

    rows: Integer;
    cols: Integer;
  end;

  { ************** Random number generation ****************** }
type
  TCvRNG = uint64;
  pCvRNG = ^TCvRNG;
  { EXTERNALSYM CvRNG }

  (* ********************************** CvTermCriteria ************************************ *)

const
  CV_TERMCRIT_ITER = 1;
{$EXTERNALSYM CV_TERMCRIT_ITER}
  CV_TERMCRIT_NUMBER = CV_TERMCRIT_ITER;
{$EXTERNALSYM CV_TERMCRIT_NUMBER}
  CV_TERMCRIT_EPS = 2;
{$EXTERNALSYM CV_TERMCRIT_EPS}

type
  pCvTermCriteria = ^TCvTermCriteria;

  TCvTermCriteria = packed record
    cType: Integer; (* may be combination of *)
    max_iter: Integer;
    epsilon: Double;
  end;

type
  pCvScalar = ^TCvScalar;

  TCvScalar = packed record
    val: array [0 .. 3] of Double;
  end;

(*
  * The following definitions (until #endif)'
  * is an extract from IPL headers.
  * Copyright (c) 1995 Intel Corporation.
*)
const
  IPL_DEPTH_SIGN = $80000000;
{$EXTERNALSYM IPL_DEPTH_SIGN}
  IPL_DEPTH_1U = 1;
{$EXTERNALSYM IPL_DEPTH_1U}
  IPL_DEPTH_8U = 8;
{$EXTERNALSYM IPL_DEPTH_8U}
  IPL_DEPTH_16U = 16;
{$EXTERNALSYM IPL_DEPTH_16U}
  IPL_DEPTH_32F = 32;
{$EXTERNALSYM IPL_DEPTH_32F}
  { for storing double-precision
    floating point data in IplImage's }
  IPL_DEPTH_64F = 64;
{$EXTERNALSYM IPL_DEPTH_64F}
  IPL_DEPTH_8S: TCvRNG = (IPL_DEPTH_SIGN or 8);
{$EXTERNALSYM IPL_DEPTH_8S}
  IPL_DEPTH_16S = (IPL_DEPTH_SIGN or 16);
{$EXTERNALSYM IPL_DEPTH_16S}
  IPL_DEPTH_32S = (IPL_DEPTH_SIGN or 32);
{$EXTERNALSYM IPL_DEPTH_32S}
  IPL_DATA_ORDER_PIXEL = 0;
{$EXTERNALSYM IPL_DATA_ORDER_PIXEL}
  IPL_DATA_ORDER_PLANE = 1;
{$EXTERNALSYM IPL_DATA_ORDER_PLANE}
  IPL_ORIGIN_TL = 0;
{$EXTERNALSYM IPL_ORIGIN_TL}
  IPL_ORIGIN_BL = 1;
{$EXTERNALSYM IPL_ORIGIN_BL}
  IPL_ALIGN_4BYTES = 4;
{$EXTERNALSYM IPL_ALIGN_4BYTES}
  IPL_ALIGN_8BYTES = 8;
{$EXTERNALSYM IPL_ALIGN_8BYTES}
  IPL_ALIGN_16BYTES = 16;
{$EXTERNALSYM IPL_ALIGN_16BYTES}
  IPL_ALIGN_32BYTES = 32;
{$EXTERNALSYM IPL_ALIGN_32BYTES}
  IPL_ALIGN_DWORD = IPL_ALIGN_4BYTES;
{$EXTERNALSYM IPL_ALIGN_DWORD}
  IPL_ALIGN_QWORD = IPL_ALIGN_8BYTES;
{$EXTERNALSYM IPL_ALIGN_QWORD}
  IPL_BORDER_CONSTANT = 0;
{$EXTERNALSYM IPL_BORDER_CONSTANT}
  IPL_BORDER_REPLICATE = 1;
{$EXTERNALSYM IPL_BORDER_REPLICATE}
  IPL_BORDER_REFLECT = 2;
{$EXTERNALSYM IPL_BORDER_REFLECT}
  IPL_BORDER_WRAP = 3;
{$EXTERNALSYM IPL_BORDER_WRAP}
  // * Sub-pixel interpolation methods */

  CV_INTER_NN       = 0;
  CV_INTER_LINEAR   = 1;
  CV_INTER_CUBIC    = 2;
  CV_INTER_AREA     = 3;
  CV_INTER_LANCZOS4 = 4;

  (* ***************************************************************************************
    *                                 Matrix cType (CvMat)                                *
    ************************************************************************************** *)

const
  CV_CN_MAX = 512;
{$EXTERNALSYM CV_CN_MAX}
  CV_CN_SHIFT = 3;
{$EXTERNALSYM CV_CN_SHIFT}
  CV_DEPTH_MAX = (1 shl CV_CN_SHIFT);
{$EXTERNALSYM CV_DEPTH_MAX}
  CV_8U = 0; // byte - 1-byte unsigned
{$EXTERNALSYM CV_8U}
  CV_8S = 1; // ShortInt - 1-byte signed
{$EXTERNALSYM CV_8S}
  CV_16U = 2; // word - 2-byte unsigned
{$EXTERNALSYM CV_16U}
  CV_16S = 3; // SmallInt - 2-byte signed
{$EXTERNALSYM CV_16S}
  CV_32S = 4; // integer - 4-byte signed integer
{$EXTERNALSYM CV_32S}
  CV_32F = 5; // single - 4-byte floating point
{$EXTERNALSYM CV_32F}
  CV_64F = 6; // double - 8-byte floating point
{$EXTERNALSYM CV_64F}
  CV_USRTYPE1 = 7;
{$EXTERNALSYM CV_USRTYPE1}
  CV_MAT_DEPTH_MASK = (CV_DEPTH_MAX - 1);
{$EXTERNALSYM CV_MAT_DEPTH_MASK}

function CV_MAKETYPE(depth, cn: Integer): Integer; inline;
function CV_32FC1: Integer; inline;
function CV_MAT_DEPTH(const flags: Integer): Integer;
function cvScalarAll(val0123: Double): TCvScalar; inline;
function CvSize(const width, height: Integer): TCvSize; inline;

type
  TOpenCVPrecent = (ocvUndevined, ocvAvailable, ocvUnavailable);

function CvLoadCoreLib: Boolean;

var
{ Creates IPL image (header and data
  CVAPI(IplImage*)  cvCreateImage( CvSize size, int depth, int channels );
}
  cvCreateImage: function(size: TCvSize; depth, channels: Integer): pIplImage; cdecl = nil;

{ Creates new memory storage.
  block_size == 0 means that default,
  somewhat optimal size, is used (currently, it is 64K)
  CVAPI(CvMemStorage*)  cvCreateMemStorage( int block_size CV_DEFAULT(0));
}
  cvCreateMemStorage: function(block_size: Integer = 0): pCvMemStorage; cdecl = nil;

{ Retrieves pointer to specified sequence element.
  Negative indices are supported and mean counting from the end
  (e.g -1 means the last sequence element)
  CVAPI(schar*)  cvGetSeqElem( const CvSeq* seq, int index );
}
  cvGetSeqElem: function(const seq: pCvSeq; index: Integer): Pointer; cdecl = nil;

{ Releases IPL image header and data
  CVAPI(void)  cvReleaseImage( IplImage** image );
}
  cvReleaseImage: procedure(var image: pIplImage); cdecl = nil;

{ Resets image ROI and COI
  CVAPI(void)  cvResetImageROI( IplImage* image );
}
  cvResetImageROI: procedure(image: pIplImage); cdecl = nil;

{ simple API for reading data
  CVAPI(void*) cvLoad( const char* filename,
  CvMemStorage* memstorage CV_DEFAULT(NULL),
  const char* name CV_DEFAULT(NULL),
  const char** real_name CV_DEFAULT(NULL) );
}
  cvLoad: function(const filename: pCvChar; memstorage: pCvMemStorage = Nil; const name: pCvChar = nil;
                   const real_name: ppChar = nil): Pointer; cdecl = nil;

{ Splits a multi-channel array into the set of single-channel arrays or
  extracts particular [color] plane */
  CVAPI(void)  cvSplit( const pCvArr* src, pCvArr* dst0, pCvArr* dst1,
  pCvArr* dst2, pCvArr* dst3 );
}
  cvSplit: procedure(const src: pCvArr; dst0: pCvArr; dst1: pCvArr; dst2: pCvArr; dst3: pCvArr); cdecl = nil;

{ Allocates and initializes CvMat header and allocates data
  CVAPI(CvMat*)  cvCreateMat( int rows, int cols, int type );
}
  cvCreateMat: function(rows, cols, cType: Integer): pCvMat; cdecl = nil;

{ Releases CvMat header and deallocates matrix data
  (reference counting is used for data)
  CVAPI(void)  cvReleaseMat( CvMat** mat );
}
  cvReleaseMat: procedure (var mat: pCvMat); cdecl = nil;

implementation

var
  FCoreLib: THandle = 0;

function CvLoadCoreLib: Boolean;
begin
  Result := False;
  FCoreLib := LoadLibrary(Core_Dll);
  if FCoreLib > 0 then
  begin
    Result := True;
    cvCreateImage := GetProcAddress(FCoreLib, 'cvCreateImage');
    cvCreateMemStorage := GetProcAddress(FCoreLib, 'cvCreateMemStorage');
    cvGetSeqElem := GetProcAddress(FCoreLib, 'cvGetSeqElem');
    cvReleaseImage := GetProcAddress(FCoreLib, 'cvReleaseImage');
    cvResetImageROI := GetProcAddress(FCoreLib, 'cvResetImageROI');
    cvLoad := GetProcAddress(FCoreLib, 'cvLoad');
    cvSplit := GetProcAddress(FCoreLib, 'cvSplit');
    cvCreateMat := GetProcAddress(FCoreLib, 'cvCreateMat');
    cvReleaseMat := GetProcAddress(FCoreLib, 'cvReleaseMat');
  end;
end;

function CvSize(const width, height: Integer): TCvSize; inline;
begin
  Result.width  := width;
  Result.height := height;
end;

function cvPoint3D32f(const x, y, z: Double): TCvPoint3D32f; inline;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function CV_MAT_DEPTH;
begin
  Result := flags and CV_MAT_DEPTH_MASK;
end;

function CV_32FC1: Integer;
begin
  Result := CV_MAKETYPE(
    CV_32F,
    1);
end;

function CV_MAKETYPE(depth, cn: Integer): Integer;
begin
  Result := (CV_MAT_DEPTH(depth) + (((cn) - 1) shl CV_CN_SHIFT));
end;

function cvScalarAll;
begin
  Result.val[0] := val0123;
  Result.val[1] := val0123;
  Result.val[2] := val0123;
  Result.val[3] := val0123;
end;

initialization
finalization
  if FCoreLib > 0 then
    FreeLibrary(FCoreLib);

end.
