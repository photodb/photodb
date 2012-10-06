unit uFIRational;

interface

uses
  System.SysUtils,
  Winapi.Windows,
  FreeImage;

type
  LONG = Longint;

type
  TFIRational = class(TObject)
  private
    FNumerator,
    FDenominator: LONG;
    procedure Initialize(N, D: LONG);
    procedure Normalize;
    function GCD(A, B: LONG): LONG;
    function GetIntValue: Integer;
    function GetLongValue: LONG;
    function GetDoubleValue: Double;
    function Truncate: LONG;
  public
    constructor Create; overload;
    constructor Create(tag: PFITAG); overload;
    constructor Create(N, D: LONG); overload;
    function IsInteger: Boolean;
    function ToString: string; override;
    property Numerator: LONG read FNumerator;
    property Denominator: LONG read FDenominator;
    property IntValue: Integer read GetIntValue;
    property LongValue: LONG read GetLongValue;
    property DoubleValue: Double read GetDoubleValue;
  end;

implementation

/// Initialize and normalize a rational number
procedure TFIRational.Initialize(N, D: LONG);
begin
	if (D > 0) then
  begin
		FNumerator := N;
		FDenominator := D;
		// normalize rational
		Normalize;
	end else
  begin
		FNumerator := 0;
		FDenominator := 0;
	end;
end;

/// Default constructor
constructor TFIRational.Create;
begin
	FNumerator := 0;
	FDenominator := 0;
end;

/// Constructor with longs
constructor TFIRational.Create(N, D: LONG);
begin
	Initialize(N, D);
end;

/// Constructor with FITAG
constructor TFIRational.Create(Tag: PFITAG);
type
  DWORD_ARRAY = array[0..1] of DWORD;
  PDWORD_ARRAY = ^DWORD_ARRAY;
  DLONG_ARRAY = array[0..1] of LONG;
  PLONG_ARRAY = ^DLONG_ARRAY;
var
  DWORDValue: PDWORD_ARRAY;
  LONGValue: PLONG_ARRAY;
begin
	case FreeImage_GetTagType(tag) of
		FIDT_RATIONAL:		// 64-bit unsigned fraction
		begin
			DWORDValue := FreeImage_GetTagValue(Tag);
			Initialize(DWORDValue[0], DWORDValue[1]);
		end;

		FIDT_SRATIONAL:	// 64-bit signed fraction
		begin
			LONGValue := FreeImage_GetTagValue(Tag);
			Initialize(LONGValue[0], LONGValue[1]);
		end;
	end;
end;

{FIRational.FIRational(Single value) begin
	if (value = (Single)((LONG)value)) then begin
	   FNumerator := (LONG)value;
	   FDenominator := 1L;
	end else begin
		Integer k, count;
		LONG N[4];

		Single x := fabs(value);
		Integer sign := (value > 0) ? 1 : -1;

		// make a continued-fraction expansion of x
		count := -1;
		for(k := 0; k < 4; k++) begin
			N[k] := (LONG)floor(x);
			count++;
			x - := (Single)N[k];
			if(x = 0) then break;
			x := 1 / x;
		end;
		// compute the rational
		FNumerator := 1;
		FDenominator := N[count];

		for(Integer i := count - 1; i > := 0; i--) begin
			if(N[i] = 0) then break;
			LONG _num := (N[i] * FNumerator + FDenominator);
			LONG _den := FNumerator;
			FNumerator := _num;
			FDenominator := _den;
		end;
		FNumerator * := sign;
	end;
end;     }

/// Copy constructor
{FIRational.FIRational (const FIRational(* C2PAS: RefOrBit? *)& r) begin
	initialize(r.FNumerator, r.FDenominator);
end; }

/// Assignement operator
{FIRational(* C2PAS: RefOrBit? *)& FIRational.operator := (FIRational(* C2PAS: RefOrBit? *)& r) begin
	if (this <> (* C2PAS: RefOrBit? *)&r) then begin
		initialize(r.FNumerator, r.FDenominator);
	end;
	(* C2PAS: Exit *) Result := *this;
end;  }

/// Get the numerator
{LONG FIRational.getNumerator() begin
	(* C2PAS: Exit *) Result := FNumerator;
end;}

/// Get the denominator
{LONG FIRational.getDenominator() begin
	(* C2PAS: Exit *) Result := FDenominator;
end;}

/// Calculate GCD
function TFIRational.GCD(A, B: LONG): LONG;
var
  Temp: LONG;
begin
	while (b > 0) do begin 		// While non-zero value
		Temp := b;	// Save current value
		b := a mod b;	// Assign remainder of division
		a := Temp;	// Copy old value
	end;
	Result := a;		// Return GCD of numbers
end;

function TFIRational.GetIntValue: Integer;
begin
  Result := Truncate();
end;

function TFIRational.GetLongValue: LONG;
begin
	Result := LONG(Truncate());
end;

function TFIRational.GetDoubleValue: Double;
begin
  if FDenominator > 0 then
  	Result := FNumerator/FDenominator
  else
    Result := 0;
end;

/// Normalize numerator / denominator
procedure TFIRational.Normalize();
var
  Common: LONG;
begin
	if (FNumerator <> 1) and (FDenominator <> 1) then
  begin 	// Is there something to do?
		 // Calculate GCD
		Common := GCD(FNumerator, FDenominator);
		if (Common <> 1) then
    begin // If GCD is not one
			FNumerator := FNumerator div Common;	// Calculate new numerator
			FDenominator := FDenominator div Common;	// Calculate new denominator
		end;
	end;
	if (FDenominator < 0) then begin 	// If sign is in denominator
		FNumerator := FNumerator * (-1);	// Multiply num and den by -1
		FDenominator := FDenominator * (-1);	// To keep sign in numerator
	end;
end;

/// Checks if this rational number is an Integer, either positive or negative
function TFIRational.IsInteger : Boolean;
begin
	Result := ((FDenominator = 1) or ((FDenominator <> 0) and (FNumerator mod FDenominator = 0)) or ((FDenominator = 0) and (FNumerator = 0)));
end;

function TFIRational.Truncate: LONG;
begin
  // Return truncated rational
  if FDenominator > 0 then
    Result := FNumerator div FDenominator
  else
    Result := 0;
end;

/// Convert as "numerator/denominator"
function TFIRational.ToString: string;
begin
	Result := '';
	if IsInteger() then
		Result := IntToStr(IntValue)
	else
		Result := IntToStr(FNumerator) + '/' + IntToStr(FDenominator);
end;

end.
