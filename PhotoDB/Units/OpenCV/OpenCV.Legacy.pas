unit OpenCV.Legacy;

interface

uses
  OpenCV.Lib,
  OpenCV.Core;

/// ****************************************************************************************\
// *                                  Eigen objects                                         *
// \****************************************************************************************/
//
// typedef int (CV_CDECL * CvCallback)(int index, void* buffer, void* user_data);
// typedef union
// {
// CvCallback callback;
// void* data;
// }
// CvInput;
const
  CV_EIGOBJ_NO_CALLBACK     = 0;
  CV_EIGOBJ_INPUT_CALLBACK  = 1;
  CV_EIGOBJ_OUTPUT_CALLBACK = 2;
  CV_EIGOBJ_BOTH_CALLBACK   = 3;

  /// * Calculates covariation matrix of a set of arrays */
  // CVAPI(void)  cvCalcCovarMatrixEx( int nObjects, void* input, int ioFlags,
  // int ioBufSize, uchar* buffer, void* userData,
  // IplImage* avg, float* covarMatrix );
  //
  // Calculates eigen values and vectors of covariation matrix of a set of arrays
  // CVAPI(void)  cvCalcEigenObjects( int nObjects, void* input, void* output,
  // int ioFlags, int ioBufSize, void* userData,
  // CvTermCriteria* calcLimit, IplImage* avg,
  // float* eigVals );

procedure cvCalcEigenObjects(nObjects: Integer; input: Pointer; output: Pointer; ioFlags: Integer; ioBufSize: Integer;
  userData: Pointer; calcLimit: pCvTermCriteria; avg: pIplImage; eigVals: pFloat); cdecl; external legacy_Dll delayed;

/// * Calculates dot product (obj - avg) * eigObj (i.e. projects image to eigen vector) */
// CVAPI(double)  cvCalcDecompCoeff( IplImage* obj, IplImage* eigObj, IplImage* avg );

// Projects image to eigen space (finds all decomposion coefficients
// CVAPI(void)  cvEigenDecomposite( IplImage* obj, int nEigObjs, void* eigInput,
// int ioFlags, void* userData, IplImage* avg,
// float* coeffs );
procedure cvEigenDecomposite(obj: pIplImage; nEigObjs: Integer; eigInput: Pointer; ioFlags: Integer; userData: Pointer;
  avg: pIplImage; coeffs: pFloat); cdecl; external legacy_Dll delayed;

implementation

end.
