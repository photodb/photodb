unit uRawExif;

interface

uses
  Classes,
  Windows,
  Math,
  SysUtils,

  FreeImage, 
  FreeBitmap,
  GraphicCrypt,

  Dmitry.Utils.System,

  uFreeImageIO,
  uMemory,
  uExifUtils,
  uFIRational,
  uTranslate,
  uSessionPasswords;

type
  TRAWExifRecord = class(TObject)
  private
    FDescription: string;
    FKey: string;
    FValue: string;
  public
    property Key: string read FKey write FKey;
    property Value: string read FValue write FValue;
    property Description: string read FDescription write FDescription;
  end;

  TRAWExif = class(TObject)
  private
    FExifList: TList;
    function GetCount: Integer;
    function GetValueByIndex(Index: Integer): TRAWExifRecord;
    function GetTimeStamp: TDateTime;
    procedure LoadFromFreeImage(Image: TFreeWinBitmap);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(FileName: string);
    procedure LoadFromStream(Stream: TStream);
    function Add(Description, Key, Value: string): TRAWExifRecord;
    function IsEXIF: Boolean;
    property TimeStamp: TDateTime read GetTimeStamp;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TRAWExifRecord read GetValueByIndex; default;
  end;

implementation

uses
  UnitDBKernel;

function L(S: string): string;
begin
  Result := TTranslateManager.Instance.TA(S, 'EXIF');
end;


(**
Convert a tag to a C string
*)
function ConvertAnyTag(tag: PFITAG): string;
const
  MAX_TEXT_EXTENT	= 512;
var
  Buffer: AnsiString;
  I: Integer;
  tag_type: FREE_IMAGE_MDTYPE;
  tag_count: Cardinal;

  max_size: Integer;
  TagValue: Pointer;
begin
	if (tag = nil) then
		Exit('');

	buffer := '';

	// convert the tag value to a string buffer
  tag_type := FreeImage_GetTagType(tag);
	tag_count := FreeImage_GetTagCount(tag);

	case (tag_type) of
		FIDT_BYTE:		// N x 8-bit unsigned integer
		begin
			{BYTE *pvalue := (BYTE*)FreeImage_GetTagValue(tag);

			sprintf(format, '%ld',	(LONG) pvalue[0]);
			buffer + := format;
			for(i := 1; i < tag_count; i++) begin
				sprintf(format, ' %ld',	(LONG) pvalue[i]);
				buffer + := format;
			end;
			break; }
		end;
		FIDT_SHORT:	// N x 16-bit unsigned integer
		begin
			{unsigned SmallInt *pvalue := (unsigned SmallInt *)FreeImage_GetTagValue(tag);

			sprintf(format, '%hu', pvalue[0]);
			buffer + := format;
			for(i := 1; i < tag_count; i++) begin
				sprintf(format, ' %hu',	pvalue[i]);
				buffer + := format;
			end;
			break;  }
		end;
		FIDT_LONG:		// N x 32-bit unsigned integer
		begin
			{DWORD *pvalue := (DWORD *)FreeImage_GetTagValue(tag);

			sprintf(format, '%lu', pvalue[0]);
			buffer + := format;
			for(i := 1; i < tag_count; i++) begin
				sprintf(format, ' %lu',	pvalue[i]);
				buffer + := format;
			end;
			break; }
		end;
		FIDT_RATIONAL: // N x 64-bit unsigned fraction
		begin
			{DWORD *pvalue := (DWORD*)FreeImage_GetTagValue(tag);

			sprintf(format, '%ld/%ld', pvalue[0], pvalue[1]);
			buffer + := format;
			for(i := 1; i < tag_count; i++) begin
				sprintf(format, ' %ld/%ld', pvalue[2*i], pvalue[2*i+1]);
				buffer + := format;
			end;
			break;  }
		end;
		FIDT_SBYTE:	// N x 8-bit signed integer
		begin
			{char *pvalue := (char*)FreeImage_GetTagValue(tag);

			sprintf(format, '%ld',	(LONG) pvalue[0]);
			buffer + := format;
			for(i := 1; i < tag_count; i++) begin
				sprintf(format, ' %ld',	(LONG) pvalue[i]);
				buffer + := format;
			end;
			break;}
		end;
		FIDT_SSHORT:	// N x 16-bit signed integer
		begin
			{SmallInt *pvalue := (SmallInt *)FreeImage_GetTagValue(tag);

			sprintf(format, '%hd', pvalue[0]);
			buffer + := format;
			for(i := 1; i < tag_count; i++) begin
				sprintf(format, ' %hd',	pvalue[i]);
				buffer + := format;
			end;
			break;}
		end;
		FIDT_SLONG:	// N x 32-bit signed integer
		begin
			{LONG *pvalue := (LONG *)FreeImage_GetTagValue(tag);

			sprintf(format, '%ld', pvalue[0]);
			buffer + := format;
			for(i := 1; i < tag_count; i++) begin
				sprintf(format, ' %ld',	pvalue[i]);
				buffer + := format;
			end;
			break;  }
		end;
		FIDT_SRATIONAL:// N x 64-bit signed fraction
		begin
			{LONG *pvalue := (LONG*)FreeImage_GetTagValue(tag);

			sprintf(format, '%ld/%ld', pvalue[0], pvalue[1]);
			buffer + := format;
			for(i := 1; i < tag_count; i++) begin
				sprintf(format, ' %ld/%ld', pvalue[2*i], pvalue[2*i+1]);
				buffer + := format;
			end;
			break; }
		end;
		FIDT_FLOAT:	// N x 32-bit IEEE floating point
		begin
			{Single *pvalue := (Single *)FreeImage_GetTagValue(tag);

			sprintf(format, '%f', (Double) pvalue[0]);
			buffer + := format;
			for(i := 1; i < tag_count; i++) begin
				sprintf(format, '%f', (Double) pvalue[i]);
				buffer + := format;
			end;
			break; }
		end;
		FIDT_DOUBLE:	// N x 64-bit IEEE floating point
		begin
			{Double *pvalue := (Double *)FreeImage_GetTagValue(tag);

			sprintf(format, '%f', pvalue[0]);
			buffer + := format;
			for(i := 1; i < tag_count; i++) begin
				sprintf(format, '%f', pvalue[i]);
				buffer + := format;
			end;
			break; }
		end;
		FIDT_IFD:		// N x 32-bit unsigned integer (offset)
		begin
			{DWORD *pvalue := (DWORD *)FreeImage_GetTagValue(tag);

			sprintf(format, '%X', pvalue[0]);
			buffer + := format;
			for(i := 1; i < tag_count; i++) begin
				sprintf(format, ' %X',	pvalue[i]);
				buffer + := format;
			end;
			break; }
		end;
		FIDT_PALETTE:	// N x 32-bit RGBQUAD
		begin
			{RGBQUAD *pvalue := (RGBQUAD *)FreeImage_GetTagValue(tag);

			sprintf(format, '(%d,%d,%d,%d)', pvalue[0].rgbRed, pvalue[0].rgbGreen, pvalue[0].rgbBlue, pvalue[0].rgbReserved);
			buffer + := format;
			for(i := 1; i < tag_count; i++) begin
				sprintf(format, ' (%d,%d,%d,%d)', pvalue[i].rgbRed, pvalue[i].rgbGreen, pvalue[i].rgbBlue, pvalue[i].rgbReserved);
				buffer + := format;
			end;
			break;}
		end;

		FIDT_LONG8:	// N x 64-bit unsigned integer
		begin
			{UINT64 *pvalue := (UINT64 *)FreeImage_GetTagValue(tag);

			sprintf(format, '%ld', pvalue[0]);
			buffer + := format;
			for(i := 1; i < tag_count; i++) begin
				sprintf(format, '%ld', pvalue[i]);
				buffer + := format;
			end;
			break; }
		end;

		FIDT_IFD8:		// N x 64-bit unsigned integer (offset)
		begin
			{UINT64 *pvalue := (UINT64 *)FreeImage_GetTagValue(tag);

			sprintf(format, '%X', pvalue[0]);
			buffer + := format;
			for(i := 1; i < tag_count; i++) begin
				sprintf(format, '%X', pvalue[i]);
				buffer + := format;
			end;
			break; }
		end;

		FIDT_SLONG8:	// N x 64-bit signed integer
		begin
			{INT64 *pvalue := (INT64 *)FreeImage_GetTagValue(tag);

			sprintf(format, '%ld', pvalue[0]);
			buffer + := format;
			for(i := 1; i < tag_count; i++) begin
				sprintf(format, '%ld', pvalue[i]);
				buffer + := format;
			end;
			break; }
		end;

		//FIDT_ASCII,	// 8-bit bytes w/ last byte null
		//FIDT_UNDEFINED:// 8-bit untyped data
		else
    begin
      max_size := Min(FreeImage_GetTagLength(tag), MAX_TEXT_EXTENT);
      if max_size > 0 then
      begin
        SetLength(Buffer, max_size);

        TagValue := FreeImage_GetTagValue(tag);
        CopyMemory(PAnsiChar(Buffer), TagValue, max_size);

        if buffer[Length(buffer)] = #0 then
          SetLength(buffer, Length(buffer) - 1);
      end;
		end;
	end;

	Result := string(buffer);
end;

//
//Convert a Exif tag to a string
//*/
function ConvertExifTag(tag: PFITAG): string;
const
  ComponentStrings: array[0..6] of string = ('', 'Y', 'Cb', 'Cr', 'R', 'G', 'B' );
var
  Orienation,
  ColorSpace,
  ResolutionUnit,
  dFocalLength,
  YCbCrPosition,
  flash,
  meteringMode,
  lightSource,
  sensingMethod,
  ExposureProgram,
  customRendered,
  exposureMode,
  whiteBalance,
  sceneType,
  gainControl,
  contrast,
  saturation,
  sharpness,
  distanceRange,
  isoEquiv,
  compression: DWORD;
  apexValue,
  apexPower: LONG;
  I, J: Integer;
  PByteValue: PByte;
  Buffer: string;
  R: TFIRational;
  userComment: PByte;

  apertureApex, rootTwo, fStop,
  fnumber,
  focalLength,
  distance: Double;
begin
  Result := '';

	if tag = nil then
		Exit;

  Buffer := '';

	// convert the tag value to a string buffer
	case (FreeImage_GetTagID(tag)) of
		TAG_ORIENTATION:
		begin
			Orienation := PWORD(FreeImage_GetTagValue(tag))^;
			case Orienation of
				1:
				  Result := 'top, left side';
				2:
					Result := 'top, right side'; 
				3:
					Result := 'bottom, right side'; 
				4:
					Result := 'bottom, left side';
				5:
					Result := 'left side, top'; 
				6:
					Result := 'right side, top';
				7:
					Result := 'right side, bottom'; 
				8:
					Result := 'left side, bottom';
			end;
      Result := L(Result);

      Exit;
		end;

{		TAG_REFERENCE_BLACK_WHITE:
		begin
			DWORD *pvalue := (DWORD*)FreeImage_GetTagValue(tag);
			if (FreeImage_GetTagLength(tag) = 48) then begin
				// reference black point value and reference white point value (ReferenceBlackWhite)
				Integer blackR := 0, whiteR := 0, blackG := 0, whiteG := 0, blackB := 0, whiteB := 0;
				if (pvalue[1]) then
					blackR := (Integer)(pvalue[0] / pvalue[1]);
				if (pvalue[3]) then
					whiteR := (Integer)(pvalue[2] / pvalue[3]);
				if (pvalue[5]) then
					blackG := (Integer)(pvalue[4] / pvalue[5]);
				if (pvalue[7]) then
					whiteG := (Integer)(pvalue[6] / pvalue[7]);
				if (pvalue[9]) then
					blackB := (Integer)(pvalue[8] / pvalue[9]);
				if (pvalue[11]) then
					whiteB := (Integer)(pvalue[10] / pvalue[11]);

				sprintf(format, '[%d,%d,%d] [%d,%d,%d]', blackR, blackG, blackB, whiteR, whiteG, whiteB);
				buffer + := format;
				(* C2PAS: Exit *) Result := buffer.c_str();
			end;
		end;}

		TAG_COLOR_SPACE:
		begin
			ColorSpace := PWORD(FreeImage_GetTagValue(tag))^;
			if (colorSpace = 1) then begin
				Result := 'sRGB';
			end else if (colorSpace = 65535) then begin
				Result := 'Undefined';
			end else begin
				Result := 'Unknown';
			end;

      Exit;
		end;

		TAG_COMPONENTS_CONFIGURATION:
		begin
  	  PByteValue := PByte(FreeImage_GetTagValue(tag));
			for I := 0 to Min(4, FreeImage_GetTagCount(tag)) - 1 do
      begin
				j := PByteValue[I];
				if (j > 0) and (j < 7) then
					Result := Result + componentStrings[j];
			end;

      Exit;
		end;

		TAG_COMPRESSED_BITS_PER_PIXEL:
		begin
      R := TFIRational.Create(tag);
			try
        Result := R.ToString();
        if (Result = '1') then
          Result := Result + ' ' + L('bit/pixel')
        else
          Result := Result + ' ' + L('bits/pixel');
        Exit;
      finally
        F(R);
      end;
		end;

		TAG_X_RESOLUTION,
		TAG_Y_RESOLUTION,
		TAG_FOCAL_PLANE_X_RES,
		TAG_FOCAL_PLANE_Y_RES,
		TAG_BRIGHTNESS_VALUE,
		TAG_EXPOSURE_BIAS_VALUE:
		begin
      R := TFIRational.Create(tag);
			try
        Result := R.ToString();
      finally
        F(R);
      end;

      Exit;
		end;

		TAG_RESOLUTION_UNIT,
		TAG_FOCAL_PLANE_UNIT:
		begin
			ResolutionUnit := PWORD(FreeImage_GetTagValue(tag))^;
			case (resolutionUnit) of
				1:
					Result := L('(No unit)');
				2:
				  Result := L('inches');
				3:
					Result := L('cm');
			end;

      Exit;
		end;

		{TAG_YCBCR_POSITIONING:
		begin
			YCbCrPosition := PWORD(FreeImage_GetTagValue(tag))^;
			case (yCbCrPosition) of
				1:
					Result := 'Center of pixel array';
				2:
					Result := 'Datum point';
			end;
		end;}

		TAG_EXPOSURE_TIME:
		begin
      R := TFIRational.Create(tag);
			try
        Result := R.ToString() + ' ' + L('sec');

        Exit;
      finally
        F(R);
      end;
		end;

		TAG_SHUTTER_SPEED_VALUE:
		begin
      R := TFIRational.Create(tag);
			try
        apexValue := r.longValue;
        apexPower := 1 shl apexValue;
			  Result := FormatEx(L('1/{0} sec'), [Integer(apexPower)]);

        Exit;
      finally
        F(R);
      end;
		end;

		TAG_APERTURE_VALUE,
		TAG_MAX_APERTURE_VALUE:
		begin
      R := TFIRational.Create(tag);
			try
        apertureApex := r.doubleValue;
        rootTwo := sqrt(2);
        fStop := Power(rootTwo, apertureApex);
        Result := FormatEx(L('F{0:0.#}'), [fStop]);

        Exit;
      finally
        F(R);
      end;
		end;

	TAG_FNUMBER:
		begin
      R := TFIRational.Create(tag);
			try
        fnumber := r.doubleValue;
        Result := FormatEx(L('F{0:0.#}'), [fnumber]);
        Exit;
      finally
        F(R);
      end;
		end;

	TAG_FOCAL_LENGTH:
		begin
      R := TFIRational.Create(tag);
			try
        focalLength := r.doubleValue;
			  Result := FormatEx(L('{0:0.#} mm'), [focalLength]);
        Exit;
      finally
        F(R);
      end;
		end;


  TAG_FOCAL_LENGTH_IN_35MM_FILM:
		begin
      dFocalLength := PWORD(FreeImage_GetTagValue(tag))^;
      Result := FormatEx(L('{0} mm'), [dFocalLength]);
      Exit;
		end;

  TAG_FLASH:
		begin
			flash := PWORD(FreeImage_GetTagValue(tag))^;
			case (flash) of
				$0000:
					(* C2PAS: Exit *) Result := 'Flash did not fire';
				$0001:
					(* C2PAS: Exit *) Result := 'Flash fired';
				$0005:
					(* C2PAS: Exit *) Result := 'Strobe return light not detected';
				$0007:
					(* C2PAS: Exit *) Result := 'Strobe return light detected';
				$0009:
					(* C2PAS: Exit *) Result := 'Flash fired, compulsory flash mode';
				$000D:
					(* C2PAS: Exit *) Result := 'Flash fired, compulsory flash mode, return light not detected';
				$000F:
					(* C2PAS: Exit *) Result := 'Flash fired, compulsory flash mode, return light detected';
				$0010:
					(* C2PAS: Exit *) Result := 'Flash did not fire, compulsory flash mode';
				$0018:
					(* C2PAS: Exit *) Result := 'Flash did not fire, auto mode';
				$0019:
					(* C2PAS: Exit *) Result := 'Flash fired, auto mode';
				$001D:
					(* C2PAS: Exit *) Result := 'Flash fired, auto mode, return light not detected';
				$001F:
					(* C2PAS: Exit *) Result := 'Flash fired, auto mode, return light detected';
				$0020:
					(* C2PAS: Exit *) Result := 'No flash function';
				$0041:
					(* C2PAS: Exit *) Result := 'Flash fired, red-eye reduction mode';
				$0045:
					(* C2PAS: Exit *) Result := 'Flash fired, red-eye reduction mode, return light not detected';
				$0047:
					(* C2PAS: Exit *) Result := 'Flash fired, red-eye reduction mode, return light detected';
				$0049:
					(* C2PAS: Exit *) Result := 'Flash fired, compulsory flash mode, red-eye reduction mode';
				$004D:
					(* C2PAS: Exit *) Result := 'Flash fired, compulsory flash mode, red-eye reduction mode, return light not detected';
				$004F:
					(* C2PAS: Exit *) Result := 'Flash fired, compulsory flash mode, red-eye reduction mode, return light detected';
				$0059:
					(* C2PAS: Exit *) Result := 'Flash fired, auto mode, red-eye reduction mode';
				$005D:
					(* C2PAS: Exit *) Result := 'Flash fired, auto mode, return light not detected, red-eye reduction mode';
				$005F:
					(* C2PAS: Exit *) Result := 'Flash fired, auto mode, return light detected, red-eye reduction mode';
				else
					Result := FormatEx(L('Unknown ({0})'), [flash]);
			end;
      Result := L(Result);

      Exit;
		end;

{		TAG_SCENE_TYPE:
		begin
			BYTE sceneType := *((BYTE*)FreeImage_GetTagValue(tag));
			if (sceneType = 1) then begin
				(* C2PAS: Exit *) Result := 'Directly photographed image';
			end else begin
				sprintf(format, 'Unknown (%d)', sceneType);
				buffer + := format;
				(* C2PAS: Exit *) Result := buffer.c_str();
			end;
		end; }

		TAG_SUBJECT_DISTANCE:
		begin
      R := TFIRational.Create(tag);
			try
        if (DWORD(r.Numerator) = $FFFFFFFF) then begin
          (* C2PAS: Exit *) Result := L('Infinity');
        end else if(r.Numerator = 0) then begin
          (* C2PAS: Exit *) Result := L('Distance unknown');
        end else begin
          distance := r.doubleValue;
          Result := FormatEx(L('{0:###} meters'), [distance]);
        end;
      finally
        F(R);
      end;

      Exit;
		end;

		TAG_METERING_MODE:
		begin
			meteringMode := PWORD(FreeImage_GetTagValue(tag))^;
			case (meteringMode) of
				0:
					(* C2PAS: Exit *) Result := 'Unknown';
				1:
					(* C2PAS: Exit *) Result := 'Average';
				2:
					(* C2PAS: Exit *) Result := 'Center weighted average';
				3:
					(* C2PAS: Exit *) Result := 'Spot';
				4:
					(* C2PAS: Exit *) Result := 'Multi-spot';
				5:
					(* C2PAS: Exit *) Result := 'Multi-segment';
				6:
					(* C2PAS: Exit *) Result := 'Partial';
				255:
					(* C2PAS: Exit *) Result := '(Other)';
				else
					(* C2PAS: Exit *) Result := '';
			end;   
      Result := L(Result);

      Exit;
		end;

		TAG_LIGHT_SOURCE:
		begin
			lightSource := PWORD(FreeImage_GetTagValue(tag))^;
			case (lightSource) of
				0:
					(* C2PAS: Exit *) Result := 'Unknown';
				1:
					(* C2PAS: Exit *) Result := 'Daylight';
				2:
					(* C2PAS: Exit *) Result := 'Fluorescent';
				3:
					(* C2PAS: Exit *) Result := 'Tungsten (incandescent light)';
				4:
					(* C2PAS: Exit *) Result := 'Flash';
				9:
					(* C2PAS: Exit *) Result := 'Fine weather';
				10:
					(* C2PAS: Exit *) Result := 'Cloudy weather';
				11:
					(* C2PAS: Exit *) Result := 'Shade';
				12:
					(* C2PAS: Exit *) Result := 'Daylight fluorescent (D 5700 - 7100K)';
				13:
					(* C2PAS: Exit *) Result := 'Day white fluorescent (N 4600 - 5400K)';
				14:
					(* C2PAS: Exit *) Result := 'Cool white fluorescent (W 3900 - 4500K)';
				15:
					(* C2PAS: Exit *) Result := 'White fluorescent (WW 3200 - 3700K)';
				17:
					(* C2PAS: Exit *) Result := 'Standard light A';
				18:
					(* C2PAS: Exit *) Result := 'Standard light B';
				19:
					(* C2PAS: Exit *) Result := 'Standard light C';
				20:
					(* C2PAS: Exit *) Result := 'D55';
				21:
					(* C2PAS: Exit *) Result := 'D65';
				22:
					(* C2PAS: Exit *) Result := 'D75';
				23:
					(* C2PAS: Exit *) Result := 'D50';
				24:
					(* C2PAS: Exit *) Result := 'ISO studio tungsten';
				255:
					(* C2PAS: Exit *) Result := '(Other)';
				else
					(* C2PAS: Exit *) Result := '';
			end;  
      Result := L(Result);

      Exit;
		end;

{		TAG_SENSING_METHOD:
		begin
			sensingMethod := PWORD(FreeImage_GetTagValue(tag))^;

			case (sensingMethod) of
				1:
					(* C2PAS: Exit *) Result := '(Not defined)';
				2:
					(* C2PAS: Exit *) Result := 'One-chip color area sensor';
				3:
					(* C2PAS: Exit *) Result := 'Two-chip color area sensor';
				4:
					(* C2PAS: Exit *) Result := 'Three-chip color area sensor';
				5:
					(* C2PAS: Exit *) Result := 'Color sequential area sensor';
				7:
					(* C2PAS: Exit *) Result := 'Trilinear sensor';
				8:
					(* C2PAS: Exit *) Result := 'Color sequential linear sensor';
				else
					(* C2PAS: Exit *) Result := '';
			end;
		end;   }
{
		TAG_FILE_SOURCE:
		begin
			BYTE fileSource := *((BYTE*)FreeImage_GetTagValue(tag));
			if (fileSource = 3) then begin
				(* C2PAS: Exit *) Result := 'Digital Still Camera (DSC)';
			end else begin
				sprintf(format, 'Unknown (%d)', fileSource);
				buffer + := format;
				(* C2PAS: Exit *) Result := buffer.c_str();
			end;
        end;
		break; }

		TAG_EXPOSURE_PROGRAM:
		begin
			ExposureProgram := PWORD(FreeImage_GetTagValue(tag))^;

			case (ExposureProgram) of
				1:
					Result := 'Manual control';
				2:
					Result := 'Program normal';
				3:
				  Result := 'Aperture priority';
				4:
					Result := 'Shutter priority';
				5:
					Result := 'Program creative (slow program)';
				6:
					Result := 'Program action (high-speed program)';
				7:
					Result := 'Portrait mode';
				8:
					Result := 'Landscape mode';
				else
					Result := FormatEx(L('Unknown program ({0})'), [ExposureProgram]);
			end;
      Result := L(Result);

      Exit;
		end;

(*		TAG_CUSTOM_RENDERED:
		begin
			customRendered := PWORD(FreeImage_GetTagValue(tag))^;

			case (customRendered) of
				0:
					Result := 'Normal process';
				1:
					Result := 'Custom process';
				else
					Result := FormatEx('Unknown rendering ({0})', [customRendered]);
			end;
		end; *)

		TAG_EXPOSURE_MODE:
		begin
			exposureMode := PWORD(FreeImage_GetTagValue(tag))^;

			case (exposureMode) of
				0:
					(* C2PAS: Exit *) Result := 'Auto exposure';
				1:
					(* C2PAS: Exit *) Result := 'Manual exposure';
				2:
					(* C2PAS: Exit *) Result := 'Auto bracket';
				else
					Result := FormatEx('Unknown mode ({0})', [exposureMode]);
			end; 
      Result := L(Result);

      Exit;
		end;

		TAG_WHITE_BALANCE:
		begin
			whiteBalance := PWORD(FreeImage_GetTagValue(tag))^;

			case (whiteBalance) of
				0:
					(* C2PAS: Exit *) Result := 'Auto white balance';
				1:
					(* C2PAS: Exit *) Result := 'Manual white balance';
				else
					Result := FormatEx('Unknown ({0})', [whiteBalance]);
			end; 
      Result := L(Result);

      Exit;
		end;

		TAG_SCENE_CAPTURE_TYPE:
		begin
			sceneType := PWORD(FreeImage_GetTagValue(tag))^;

			case (sceneType) of
				0:
					(* C2PAS: Exit *) Result := 'Standard';
				1:
					(* C2PAS: Exit *) Result := 'Landscape';
				2:
					(* C2PAS: Exit *) Result := 'Portrait';
				3:
					(* C2PAS: Exit *) Result := 'Night scene';
				else
					Result := FormatEx('Unknown ({0})', [sceneType]);
			end;  
      Result := L(Result);

      Exit;
		end;

(*	TAG_GAIN_CONTROL:
		begin
			gainControl := PWORD(FreeImage_GetTagValue(tag))^;

			case (gainControl) of
				0:
					Result := 'None';
				1:
					Result := 'Low gain up';
				2:
					Result := 'High gain up';
				3:
					Result := 'Low gain down';
				4:
					Result := 'High gain down';
				else
					Result := FormatEx('Unknown ({0})', [gainControl]);
			end;
		end;  *)

		TAG_CONTRAST:
		begin
			contrast := PWORD(FreeImage_GetTagValue(tag))^;

			case (contrast) of
				0:
					(* C2PAS: Exit *) Result := 'Normal';
				1:
					(* C2PAS: Exit *) Result := 'Soft';
				2:
					(* C2PAS: Exit *) Result := 'Hard';
				else
					Result := FormatEx('Unknown ({0})', [contrast]);
			end;
      Result := L(Result);

      Exit;
		end;

		TAG_SATURATION:
		begin
			saturation := PWORD(FreeImage_GetTagValue(tag))^;

			case (saturation) of
				0:
					(* C2PAS: Exit *) Result := 'Normal';
				1:
					(* C2PAS: Exit *) Result := 'Low saturation';
				2:
					(* C2PAS: Exit *) Result := 'High saturation';
				else
          Result := FormatEx('Unknown ({0})', [saturation]);
			end;
      Result := L(Result);

      Exit;
		end;

		TAG_SHARPNESS:
		begin
			sharpness := PWORD(FreeImage_GetTagValue(tag))^;

			case (sharpness) of
				0:
					(* C2PAS: Exit *) Result := 'Normal';
				1:
					(* C2PAS: Exit *) Result := 'Soft';
				2:
					(* C2PAS: Exit *) Result := 'Hard';
				else
					Result := FormatEx('Unknown ({0})', [sharpness]);
			end;  
      Result := L(Result);

      Exit;
		end;

		TAG_SUBJECT_DISTANCE_RANGE:
		begin
			distanceRange := PWORD(FreeImage_GetTagValue(tag))^;

			case (distanceRange) of
				0:
					(* C2PAS: Exit *) Result := 'unknown';
				1:
					(* C2PAS: Exit *) Result := 'Macro';
				2:
					(* C2PAS: Exit *) Result := 'Close view';
				3:
					(* C2PAS: Exit *) Result := 'Distant view';
				else
					Result := FormatEx('Unknown ({0})', [distanceRange]);
			end;
      Result := L(Result);

      Exit;
		end;

		TAG_ISO_SPEED_RATINGS:
		begin
			isoEquiv := PWORD(FreeImage_GetTagValue(tag))^;
			if (isoEquiv < 50) then
				isoEquiv := isoEquiv * 200;

			Result := IntToStr(isoEquiv);

      Exit;
		end;

		TAG_USER_COMMENT:
		begin
			// first 8 bytes are used to define an ID code
			// we assume this is an ASCII string
			userComment := FreeImage_GetTagValue(tag);
			for I := 8 to FreeImage_GetTagLength(tag) - 1 do
				Result := Result + string(AnsiChar(userComment[I]));
      Exit;
		end;

		TAG_COMPRESSION:
		begin
			compression := PWORD(FreeImage_GetTagValue(tag))^;
			case (compression) of
				TAG_COMPRESSION_NONE:
					Result := FormatEx('dump mode ({0})', [compression]);
				TAG_COMPRESSION_CCITTRLE:
					Result := FormatEx('CCITT modified Huffman RLE ({0})', [compression]);
				TAG_COMPRESSION_CCITTFAX3:
					Result := FormatEx('CCITT Group 3 fax encoding ({0})', [compression]);
				(*
				case TAG_COMPRESSION_CCITT_T4:
					Result := FormatEx("CCITT T.4 (TIFF 6 name) ({0})", [compression]);
					break;
				*)
				TAG_COMPRESSION_CCITTFAX4:
					Result := FormatEx('CCITT Group 4 fax encoding ({0})', [compression]);
				(*
				case TAG_COMPRESSION_CCITT_T6:
					Result := FormatEx("CCITT T.6 (TIFF 6 name) ({0})", [compression]);
					break;
				*)
				TAG_COMPRESSION_LZW:
					Result := FormatEx('LZW ({0})', [compression]);
				TAG_COMPRESSION_OJPEG:
					Result := FormatEx('!6.0 JPEG ({0})', [compression]);
				TAG_COMPRESSION_JPEG:
					Result := FormatEx('JPEG ({0})', [compression]);
				TAG_COMPRESSION_NEXT:
					Result := FormatEx('NeXT 2-bit RLE ({0})', [compression]);
				TAG_COMPRESSION_CCITTRLEW:
					Result := FormatEx('CCITTRLEW ({0})', [compression]);
				TAG_COMPRESSION_PACKBITS:
					Result := FormatEx('PackBits Macintosh RLE ({0})', [compression]);
				TAG_COMPRESSION_THUNDERSCAN:
					Result := FormatEx('ThunderScan RLE ({0})', [compression]);
				TAG_COMPRESSION_PIXARFILM:
					Result := FormatEx('Pixar companded 10bit LZW ({0})', [compression]);
				TAG_COMPRESSION_PIXARLOG:
					Result := FormatEx('Pixar companded 11bit ZIP ({0})', [compression]);
				TAG_COMPRESSION_DEFLATE:
					Result := FormatEx('Deflate [compression] ({0})', [compression]);
				TAG_COMPRESSION_ADOBE_DEFLATE:
					Result := FormatEx('Adobe Deflate [compression] ({0})', [compression]);
				TAG_COMPRESSION_DCS:
					Result := FormatEx('Kodak DCS encoding ({0})', [compression]);
				TAG_COMPRESSION_JBIG:
					Result := FormatEx('ISO JBIG ({0})', [compression]);
				TAG_COMPRESSION_SGILOG:
					Result := FormatEx('SGI Log Luminance RLE ({0})', [compression]);
				TAG_COMPRESSION_SGILOG24:
					Result := FormatEx('SGI Log 24-bit packed ({0})', [compression]);
				TAG_COMPRESSION_JP2000:
					Result := FormatEx('Leadtools JPEG2000 ({0})', [compression]);
				TAG_COMPRESSION_LZMA:
					Result := FormatEx('LZMA2 ({0})', [compression]);
				else
					Result := FormatEx('Unknown type ({0})', [compression]);
			end;
      Exit;
		end;
	end;

  Result := ConvertAnyTag(tag);
end;


///**
//Convert a Exif GPS tag to a C string
//*/
function ConvertExifGPSTag(tag: PFITAG): string;
type
  DWORD_ARRAY = array[0..5] of DWORD;
  PDWORD_ARRAY = ^DWORD_ARRAY;
var
  pvalue: PDWORD_ARRAY;
  dd, mm: Integer;
  ss: Double;
begin 
  Result := '';
	if (tag = nil) then
		 Exit;

	// convert the tag value to a string buffer
	case (FreeImage_GetTagID(tag)) of 
		TAG_GPS_LATITUDE,
		TAG_GPS_LONGITUDE,
		TAG_GPS_TIME_STAMP:
		begin
			pvalue := FreeImage_GetTagValue(tag);
			if (FreeImage_GetTagLength(tag) = 24) then 
      begin 
				// dd:mm:ss or hh:mm:ss
				ss := 0;

				// convert to seconds
				if (pvalue[1] > 0) then
					ss := ss + (pvalue[0] / pvalue[1]) * 3600;
				if (pvalue[3] > 0) then 
					ss := ss + (pvalue[2] / pvalue[3]) * 60;
				if(pvalue[5] > 0) then 
					ss := ss + (pvalue[4] / pvalue[5]);

				// convert to dd:mm:ss.ss
				dd := Round(ss / 3600);
				mm := Round(ss / 60) - dd * 60;
				ss := ss - dd * 3600 - mm * 60;

				Result := FormatEx('{0}:{1}:{2:0.##}', [dd, mm, ss]);
			end; 
		end; 
	end;
end; 

//from FreeImage\Source\Metadata\TagConversion.cpp
function FreeImageTagToString(model: FREE_IMAGE_MDMODEL; tag: PFITAG): string;
begin
  Result := '';
	case (model) of
		FIMD_EXIF_MAIN,
		FIMD_EXIF_EXIF:
			Exit(ConvertExifTag(tag));

	 	FIMD_EXIF_GPS:
	 		Exit(ConvertExifGPSTag(tag));
	end;

	Exit(ConvertAnyTag(tag));
end;

{ TRAWExif }

function TRAWExif.Add(Description, Key, Value: string): TRAWExifRecord;
begin
  Result := TRAWExifRecord.Create;
  Result.Description := Description;
  Result.Key := Key;
  Result.Value := Value;
  FExifList.Add(Result);
end;

constructor TRAWExif.Create;
begin
  FreeImageInit;
  FExifList := TList.Create;
end;

destructor TRAWExif.Destroy;
begin
  FreeList(FExifList);
  inherited;
end;

function TRAWExif.GetCount: Integer;
begin
  Result:= FExifList.Count;
end;

function TRAWExif.GetTimeStamp: TDateTime;
var
  I : Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    if Self[I].Key = 'DateTime' then
      Result := EXIFDateToDate(Self[I].Value) + EXIFDateToTime(Self[I].Value);
end;

function TRAWExif.GetValueByIndex(Index: Integer): TRAWExifRecord;
begin
  Result := FExifList[Index];
end;

function TRAWExif.IsEXIF: Boolean;
begin
  Result := Count > 0;
end;

procedure TRAWExif.LoadFromFile(FileName: string);
var
  RawBitmap: TFreeWinBitmap;
  Stream: TMemoryStream;
  Password: string;
begin
  RawBitmap := TFreeWinBitmap.Create;
  try
    if ValidCryptGraphicFile(FileName) then
    begin
      Stream := TMemoryStream.Create;
      try
        Password := SessionPasswords.FindForFile(FileName);
        if Password <> '' then
        begin
          if DecryptFileToStream(FileName, Password, Stream) then
            RawBitmap.LoadFromMemoryStream(Stream, FIF_LOAD_NOPIXELS);
        end;
      finally
        F(Stream);
      end;
    end else
      RawBitmap.LoadU(FileName, FIF_LOAD_NOPIXELS);

    LoadFromFreeImage(RawBitmap);
  finally
    F(RawBitmap);
  end;
end;

procedure TRAWExif.LoadFromStream(Stream: TStream);
var
  RawBitmap: TFreeWinBitmap;
  IO: FreeImageIO;
begin
  RawBitmap := TFreeWinBitmap.Create;
  try
    SetStreamFreeImageIO(IO);
    RawBitmap.LoadFromHandle(@IO, Stream, FIF_LOAD_NOPIXELS);
    LoadFromFreeImage(RawBitmap);
  finally
    F(RawBitmap);
  end;
end;

procedure TRAWExif.LoadFromFreeImage(Image: TFreeWinBitmap);
var
  TagData: PFITAG;
  I: Integer;
  FindMetaData: PFIMETADATA;

  procedure AddTag;
  var
    Description, Key: PAnsiChar;
    Value: string;
  begin
    Description := FreeImage_GetTagDescription(TagData);
    Key := FreeImage_GetTagKey(TagData);

    Value := FreeImageTagToString(I, TagData);
    if Description <> nil then
    begin
      Add(string(Description), string(Key), string(Value));
    end;
  end;

begin
  TagData := nil;
  for I := FIMD_NODATA to FIMD_EXIF_RAW do
  begin
    FindMetaData := FreeImage_FindFirstMetadata(I, Image.Dib, TagData);
    try
      if FindMetaData <> nil then
      begin
        AddTag;

        while FreeImage_FindNextMetadata(FindMetaData, TagData) do
          AddTag;
      end;
    finally
      Image.FindCloseMetadata(FindMetaData);
    end;
  end;
end;

end.
