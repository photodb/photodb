unit OpenCV.HighGUI;

interface

uses
  Winapi.Windows,
  OpenCV.Lib,
  OpenCV.Core;

// ---------  YV ---------
// These 3 flags are used by cvSet/GetWindowProperty;
const
  CV_WND_PROP_FULLSCREEN = 0; // to change/get window's fullscreen property
  CV_WND_PROP_AUTOSIZE = 1; // to change/get window's autosize property
  CV_WND_PROP_ASPECTRATIO = 2; // to change/get window's aspectratio property
  CV_WND_PROP_OPENGL = 3; // to change/get window's opengl support
  // These 2 flags are used by cvNamedWindow and cvSet/GetWindowProperty;
  CV_WINDOW_NORMAL = $00000000;
  // the user can resize the window (no raint)  / also use to switch a fullscreen window to a normal size
  CV_WINDOW_AUTOSIZE = $00000001;
  // the user cannot resize the window; the size is rainted by the image displayed
  CV_WINDOW_OPENGL = $00001000; // window with opengl support
  // Those flags are only for Qt;
  CV_GUI_EXPANDED = $00000000; // status bar and tool bar
  CV_GUI_NORMAL = $00000010; // old fashious way
  // These 3 flags are used by cvNamedWindow and cvSet/GetWindowProperty;
  CV_WINDOW_FULLSCREEN = 1; // change the window to fullscreen
  CV_WINDOW_FREERATIO = $00000100; // the image expends as much as it can (no ratio raint)
  CV_WINDOW_KEEPRATIO = $00000000; // the ration image is respected.;

var
  (* create window *)
  cvNamedWindow: function(const name: pCVChar; flags: Integer = CV_WINDOW_AUTOSIZE): Integer; cdecl = nil;
{
  //display image within window (highgui windows remember their content)
  CVAPI(void) cvShowImage( const char* name, const CvArr* image );
}
  cvShowImage: procedure(const name: pCVChar; const image: pCvArr); cdecl = nil;

(* wait for key event infinitely (delay<=0) or for "delay" milliseconds *)
  cvWaitKey: function (delay: Integer = 0): Integer; cdecl = nil;

function CvLoadHighGUILib: Boolean;

implementation

var
  FHighGUILib: THandle = 0;

function CvLoadHighGUILib: Boolean;
begin
  Result := False;
  FHighGUILib := LoadLibrary(highgui_Dll);
  if FHighGUILib > 0 then
  begin
    Result := True;
    cvNamedWindow := GetProcAddress(FHighGUILib, 'cvNamedWindow');
    cvShowImage := GetProcAddress(FHighGUILib, 'cvShowImage');
    cvWaitKey := GetProcAddress(FHighGUILib, 'cvWaitKey');
  end;
end;

end.
