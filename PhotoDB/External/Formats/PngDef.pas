unit PngDef;
{
   Dominique Louis ( Dominique@SavageSoftware.com.au )
   22 Novemebr 2000
   Added $IFDEF so that users can decide at compile time which version of the DLL they wish to use.

   Dominique Louis ( Dominique@SavageSoftware.com.au )
   13 June 2000
   This file has been updated to version 1.0.6 of PNGLIB.
   More data structures and functions within the DLL have been added
   I have also added a few more Delphi style types.

   Uberto Barbini (uberto@usa.net)
   14 Dec 1999.
   This file contains all the Pascal data structures, and declarations of
   the procedures and functions you can call in the DLL.
}

{$DEFINE PNGPX}

interface

uses Windows, SysUtils, uTime;

type
  png_uint_32 = Cardinal;
  png_int_32  = Longint;

  png_uint_16pp = ^png_uint_16p;
  png_uint_16p = ^png_uint_16;
  png_uint_16 = Word;

  png_int_16  = Smallint;

  png_bytepp  = ^png_bytep;
  png_bytep   = ^png_byte;
  png_byte    = Byte;

  png_doublep  = ^png_double;
  png_double   = double;

  png_size_t  = png_uint_32;

  png_charpp  = ^png_charp;
  png_charp   = PChar;

  png_voidp    = pointer;

  float       = single;
  int         = Integer;
  time_t       = Longint;
  png_fixed_point = png_int_32;
  int_gamma = png_fixed_point;

  user_error_ptr  = Pointer;

  png_colorpp = ^png_colorp;
  png_colorp = ^png_color;
  png_color = packed record
    red, green, blue: png_byte;
  end;
  TPngColor = png_color;

  png_color_16pp = ^png_color_16p;
  png_color_16p = ^png_color_16;
  png_color_16 = packed record
    index: png_byte;                 //used for palette files
    red, green, blue: png_uint_16;   //for use in red green blue files
    gray: png_uint_16;               //for use in grayscale files
  end;
  TPngColor16 = png_color_16;

  png_color_8pp = ^png_color_8p;
  png_color_8p = ^png_color_8;
  png_color_8 = packed record
    red, green, blue: png_byte;   //for use in red green blue files
    gray: png_byte;               //for use in grayscale files
    alpha: png_byte;              //for alpha channel files
  end;
  TPngColor8 = png_color_8;

 // The following two structures are used for the in-core representation
 // of sPLT chunks.
  png_sPLT_entrypp = ^png_sPLT_entryp;
  png_sPLT_entryp = ^png_sPLT_entry;
  png_sPLT_entry = packed record
    red       : png_uint_16;
    green     : png_uint_16;
    blue      : png_uint_16;
    alpha     : png_uint_16;
    frequency : png_uint_16;
  end;
  TPngsPLTEntry = png_sPLT_entry;

  png_sPLT_tpp = ^png_sPLT_tp;
  png_sPLT_tp = ^png_sPLT_t;
  png_sPLT_t = packed record
    name : png_charp;                // palette name */
    depth : png_byte;                // depth of palette samples */
    entries : png_sPLT_entryp;       // palette entries */
    nentries : png_int_32;           // number of palette entries */
  end;
  TPngsPLTT = png_sPLT_t;

  png_textpp = ^png_textp;
  png_textp = ^png_text;
  png_text = packed record
    compression: int;            // compression value
    key: png_charp;              // keyword, 1-79 character description of "text"
    text: png_charp;             // comment, may be empty ("")
    text_length: png_size_t;     // length of text field
    itxt_length: png_size_t;     // length of the itxt string
    lang: png_charp;             // language code, 1-79 characters
    lang_key: png_charp;         // keyword translated UTF-8 string, 0 or more
  end;
  TPngText = png_text;

  png_timepp = ^png_timep;
  png_timep = ^png_time;
  png_time = packed record
    year: png_uint_16;           //yyyy
    month: png_byte;             //1..12
    day: png_byte;               //1..31
    hour: png_byte;              //0..23
    minute: png_byte;            //0..59
    second: png_byte;            //0..60 (leap seconds)
  end;
  TPngTime = png_time;

  // png_unknown_chunk is a structure to hold queued chunks for which there is
  // no specific support.  The idea is that we can use this to queue
  // up private chunks for output even though the library doesn't actually
  // know about their semantics.
  png_unknown_chunkpp = ^png_unknown_chunkp;
  png_unknown_chunkp = ^png_unknown_chunk;
  png_unknown_chunk  = packed record
    name : array[0..4] of png_byte;
    data : ^png_byte;
    size : png_size_t ;
    // libpng-using applications should NOT directly modify this byte. */
    location : png_byte ; // mode of operation at read time
  end;
  TPngUnknownChunk = png_unknown_chunk;

  png_infopp = ^png_infop;
  png_infop = Pointer;

  png_row_infopp = ^png_row_infop;
  png_row_infop = ^png_row_info;
  png_row_info = packed record
    width: png_uint_32;          //width of row
    rowbytes: png_size_t;        //number of bytes in row
    color_type: png_byte;        //color type of row
    bit_depth: png_byte;         //bit depth of row
    channels: png_byte;          //number of channels (1, 2, 3, or 4)
    pixel_depth: png_byte;       //bits per pixel (depth * channels)
  end;
  TPngRowInfo = png_row_info;

  png_structpp = ^png_structp;
  png_structp = Pointer;

  // function pointer declarations
  png_error_ptrp = ^png_error_ptr;
  png_error_ptr  = procedure(png_ptr: Pointer; msg: Pointer); stdcall;

  png_rw_ptrp = ^png_rw_ptr;
  png_rw_ptr = procedure(png_ptr: Pointer; var data: Pointer; length: png_size_t); stdcall;

  png_flush_ptrp = ^png_flush_ptr;
  png_flush_ptr = procedure(png_ptr: Pointer); stdcall;

  png_read_status_ptrp = ^png_read_status_ptr;
  png_read_status_ptr = procedure(png_ptr: Pointer; row_number: png_uint_32; pass: int); stdcall;

  png_write_status_ptrp = ^png_write_status_ptr;
  png_write_status_ptr = procedure(png_ptr: Pointer; row_number: png_uint_32; pass: int); stdcall;

  png_progressive_info_ptrp = ^png_progressive_info_ptr;
  png_progressive_info_ptr  = procedure(png_ptr: Pointer; info_ptr: Pointer); stdcall;

  png_progressive_end_ptrp  = ^png_progressive_end_ptr;
  png_progressive_end_ptr   = procedure(png_ptr: Pointer; info_ptr: Pointer); stdcall;

  png_progressive_row_ptrp  = ^png_progressive_row_ptr;
  png_progressive_row_ptr   = procedure(png_ptr: Pointer; data: Pointer; length: png_uint_32; count: int); stdcall;

  png_user_transform_ptrp = ^png_user_transform_ptr;
  png_user_transform_ptr = procedure(png_ptr: Pointer; row_info: Pointer; data: png_bytep); stdcall;

  png_user_chunk_ptrp = ^png_user_chunk_ptr;
  png_user_chunk_ptr = procedure(png_ptr: Pointer; data: png_unknown_chunkp); stdcall;

const
  PNG_LIBPNG_VER_STRING = '1.0.6';
  PNG_LIBPNG_VER        =  10006;
  PNG_HEADER_VERSION_STRING  = ' libpng version 1.0.6 - March 21, 2000 (header)'+#13+#10;

// Supported compression types for text in PNG files (tEXt, and zTXt).
// The values of the PNG_TEXT_COMPRESSION_ defines should NOT be changed.
  PNG_TEXT_COMPRESSION_NONE_WR = -3;
  PNG_TEXT_COMPRESSION_zTXt_WR = -2;
  PNG_TEXT_COMPRESSION_NONE    = -1;
  PNG_TEXT_COMPRESSION_zTXt    = 0;
  PNG_ITXT_COMPRESSION_NONE    = 1;
  PNG_ITXT_COMPRESSION_zTXt    = 2;
  PNG_TEXT_COMPRESSION_LAST    = 3;  // Not a valid value

// Maximum positive integer used in PNG is (2^31)-1
  PNG_MAX_UINT : png_uint_32   = $7FFFFFFF;

// These describe the color_type field in png_info.
// color type masks
  PNG_COLOR_MASK_PALETTE   = 1;
  PNG_COLOR_MASK_COLOR     = 2;
  PNG_COLOR_MASK_ALPHA     = 4;

// color types.  Note that not all combinations are legal
  PNG_COLOR_TYPE_GRAY       = 0;
  PNG_COLOR_TYPE_PALETTE    = PNG_COLOR_MASK_COLOR or
                              PNG_COLOR_MASK_PALETTE;
  PNG_COLOR_TYPE_RGB        = PNG_COLOR_MASK_COLOR;
  PNG_COLOR_TYPE_RGB_ALPHA  = PNG_COLOR_MASK_COLOR or
                              PNG_COLOR_MASK_ALPHA;
  PNG_COLOR_TYPE_GRAY_ALPHA = PNG_COLOR_MASK_ALPHA;

// This is for compression type. PNG 1.0 only defines the single type.
  PNG_COMPRESSION_TYPE_BASE    = 0;   // Deflate method 8, 32K window
  PNG_COMPRESSION_TYPE_DEFAULT = PNG_COMPRESSION_TYPE_BASE;

// This is for filter type. PNG 1.0 only defines the single type.
  PNG_FILTER_TYPE_BASE    = 0;       // Single row per-byte filtering
  PNG_FILTER_TYPE_DEFAULT = PNG_FILTER_TYPE_BASE;

// These are for the interlacing type.  These values should NOT be changed.
  PNG_INTERLACE_NONE  = 0;      // Non-interlaced image
  PNG_INTERLACE_ADAM7 = 1;      // Adam7 interlacing
  PNG_INTERLACE_LAST  = 2;      // Not a valid value

// These are for the oFFs chunk.  These values should NOT be changed.
  PNG_OFFSET_PIXEL      = 0;    // Offset in pixels
  PNG_OFFSET_MICROMETER = 1;    // Offset in micrometers (1/10^6 meter)
  PNG_OFFSET_LAST       = 2;    // Not a valid value

// These are for the pCAL chunk.  These values should NOT be changed.
  PNG_EQUATION_LINEAR     = 0;  // Linear transformation
  PNG_EQUATION_BASE_E     = 1;  // Exponential base e transform
  PNG_EQUATION_ARBITRARY  = 2;  // Arbitrary base exponential transform
  PNG_EQUATION_HYPERBOLIC = 3;  // Hyperbolic sine transformation
  PNG_EQUATION_LAST       = 4;  //  Not a valid value

// These are for the sCAL chunk.  These values should NOT be changed.
  PNG_SCALE_UNKNOWN        = 0; // unknown unit (image scale)
  PNG_SCALE_METER          = 1; // meters per pixel
  PNG_SCALE_RADIAN         = 2; // radians per pixel
  PNG_SCALE_LAST           = 3; // Not a valid value

// These are for the pHYs chunk.  These values should NOT be changed.
  PNG_RESOLUTION_UNKNOWN = 0;   // pixels/unknown unit (aspect ratio)
  PNG_RESOLUTION_METER   = 1;   // pixels/meter
  PNG_RESOLUTION_LAST    = 2;   // Not a valid value

// These are for the sRGB chunk.  These values should NOT be changed.
  PNG_sRGB_INTENT_PERCEPTUAL = 0;
  PNG_sRGB_INTENT_RELATIVE   = 1;
  PNG_sRGB_INTENT_SATURATION = 2;
  PNG_sRGB_INTENT_ABSOLUTE   = 3;
  PNG_sRGB_INTENT_LAST       = 4; // Not a valid value

// This is for text chunks */
  PNG_KEYWORD_MAX_LENGTH     = 79;

// These determine if an ancillary chunk's data has been successfully read
// from the PNG header, or if the application has filled in the corresponding
// data in the info_struct to be written into the output file.  The values
// of the PNG_INFO_<chunk> defines should NOT be changed.
  PNG_INFO_gAMA = $0001;
  PNG_INFO_sBIT = $0002;
  PNG_INFO_cHRM = $0004;
  PNG_INFO_PLTE = $0008;
  PNG_INFO_tRNS = $0010;
  PNG_INFO_bKGD = $0020;
  PNG_INFO_hIST = $0040;
  PNG_INFO_pHYs = $0080;
  PNG_INFO_oFFs = $0100;
  PNG_INFO_tIME = $0200;
  PNG_INFO_pCAL = $0400;
  PNG_INFO_sRGB = $0800;  // GR-P, 0.96a
  PNG_INFO_iCCP = $1000;  // ESR, 1.0.6
  PNG_INFO_sPLT = $2000;  // ESR, 1.0.6
  PNG_INFO_sCAL = $4000;  // ESR, 1.0.6
  PNG_INFO_IDAT = $8000;  // ESR, 1.0.6

// Transform masks for the high-level interface
  PNG_TRANSFORM_IDENTITY       = $0000;    // read and write
  PNG_TRANSFORM_STRIP_16       = $0001;    // read only
  PNG_TRANSFORM_STRIP_ALPHA    = $0002;    // read only
  PNG_TRANSFORM_PACKING        = $0004;    // read and write
  PNG_TRANSFORM_PACKSWAP       = $0008;    // read and write
  PNG_TRANSFORM_EXPAND         = $0010;    // read only
  PNG_TRANSFORM_INVERT_MONO    = $0020;    // read and write
  PNG_TRANSFORM_SHIFT          = $0040;    // read and write
  PNG_TRANSFORM_BGR            = $0080;    // read and write
  PNG_TRANSFORM_SWAP_ALPHA     = $0100;    // read and write
  PNG_TRANSFORM_SWAP_ENDIAN    = $0200;    // read and write
  PNG_TRANSFORM_INVERT_ALPHA   = $0200;    // read and write
  PNG_TRANSFORM_STRIP_FILLER   = $0800;    // WRITE only

// Handle alpha and tRNS by replacing with a background color.
  PNG_BACKGROUND_GAMMA_UNKNOWN = 0;
  PNG_BACKGROUND_GAMMA_SCREEN  = 1;
  PNG_BACKGROUND_GAMMA_FILE    = 2;
  PNG_BACKGROUND_GAMMA_UNIQUE  = 3;

// Values for png_set_crc_action() to say how to handle CRC errors in
// ancillary and critical chunks, and whether to use the data contained
// therein.  Note that it is impossible to "discard" data in a critical
// chunk.  For versions prior to 0.90, the action was always error/quit,
// whereas in version 0.90 and later, the action for CRC errors in ancillary
// chunks is warn/discard.  These values should NOT be changed.

//      value                   action:critical     action:ancillary
  PNG_CRC_DEFAULT      = 0;  // error/quit          warn/discard data
  PNG_CRC_ERROR_QUIT   = 1;  // error/quit          error/quit
  PNG_CRC_WARN_DISCARD = 2;  // (INVALID)           warn/discard data
  PNG_CRC_WARN_USE     = 3;  // warn/use data       warn/use data
  PNG_CRC_QUIET_USE    = 4;  // quiet/use data      quiet/use data
  PNG_CRC_NO_CHANGE    = 5;  // use current value   use current value 

// Flags for png_set_filter() to say which filters to use.  The flags
// are chosen so that they don't conflict with real filter types
// below, in case they are supplied instead of the  d constants.
// These values should NOT be changed.
  PNG_NO_FILTERS   = $00;
  PNG_FILTER_NONE  = $08;
  PNG_FILTER_SUB   = $10;
  PNG_FILTER_UP    = $20;
  PNG_FILTER_AVG   = $40;
  PNG_FILTER_PAETH = $80;
  PNG_ALL_FILTERS  = PNG_FILTER_NONE or PNG_FILTER_SUB or
                     PNG_FILTER_UP   or PNG_FILTER_AVG or
                     PNG_FILTER_PAETH;

  // Filter values (not flags) - used in pngwrite.c, pngwutil.c for now.
  // These defines should NOT be changed.
  PNG_FILTER_VALUE_NONE  = 0;
  PNG_FILTER_VALUE_SUB   = 1;
  PNG_FILTER_VALUE_UP    = 2;
  PNG_FILTER_VALUE_AVG   = 3;
  PNG_FILTER_VALUE_PAETH = 4;
  PNG_FILTER_VALUE_LAST  = 5;

  // Heuristic used for row filter selection.  These defines should NOT be
  // changed.
  PNG_FILTER_HEURISTIC_DEFAULT    = 0;  // Currently "UNWEIGHTED"
  PNG_FILTER_HEURISTIC_UNWEIGHTED = 1;  // Used by libpng < 0.95
  PNG_FILTER_HEURISTIC_WEIGHTED   = 2;  // Experimental feature
  PNG_FILTER_HEURISTIC_LAST       = 3;  // Not a valid value

  // flags for png_ptr->free_me and info_ptr->free_me */
  PNG_FREE_PLTE = $0001;
  PNG_FREE_TRNS = $0002;
  PNG_FREE_TEXT = $0004;
  PNG_FREE_HIST = $0008;
  PNG_FREE_ICCP = $0010;
  PNG_FREE_SPLT = $0020;
  PNG_FREE_ROWS = $0040;
  PNG_FREE_PCAL = $0080;
  PNG_FREE_SCAL = $0100;
  PNG_FREE_UNKN = $0200;
  PNG_FREE_LIST = $0400;
  PNG_FREE_ALL  = $07FF;

type
t_png_build_grayscale_palette = procedure (bit_depth: int; palette: png_colorp); stdcall;

t_png_check_sig = function(sig: png_bytep; num: int): int; stdcall;

t_png_chunk_error = procedure(png_ptr: png_structp; const mess: png_charp); stdcall;

t_png_chunk_warning = procedure(png_ptr: png_structp; const mess: png_charp); stdcall;

t_png_convert_from_time_t = procedure(ptime: png_timep; ttime: time_t); stdcall;

t_png_convert_to_rfc1123 = function(png_ptr: png_structp; ptime: png_timep): png_charp; stdcall;

t_png_create_info_struct = function(png_ptr: png_structp): png_infop; stdcall;

t_png_create_read_struct = function(user_png_ver: png_charp;
             error_ptr: user_error_ptr; error_fn: png_error_ptr;
             warn_fn: png_error_ptr): png_structp;
             stdcall;

{function png_create_read_struct_2(user_png_ver: png_charp;
             error_ptr: user_error_ptr; error_fn: png_error_ptr;
             warn_fn: png_error_ptr): png_structp;
             stdcall;}
             
t_png_get_copyright = function(png_ptr: png_structp): png_charp;
             stdcall;
t_png_get_header_ver = function(png_ptr: png_structp): png_charp;
             stdcall;
t_png_get_header_version = function(png_ptr: png_structp): png_charp;
             stdcall;
t_png_get_libpng_ver = function(png_ptr: png_structp): png_charp;
             stdcall;
t_png_create_write_struct= function(user_png_ver: png_charp;
             error_ptr: user_error_ptr; error_fn: png_error_ptr;
             warn_fn: png_error_ptr): png_structp;
             stdcall;
t_png_destroy_info_struct = procedure(png_ptr: png_structp;
             info_ptr_ptr: png_infopp);
             stdcall;
t_png_destroy_read_struct = procedure(png_ptr_ptr: png_structpp;
             info_ptr_ptr, end_info_ptr_ptr: png_infopp);
             stdcall;

t_png_destroy_write_struct = procedure(png_ptr_ptr: png_structpp; info_ptr_ptr: png_infopp); stdcall;

t_png_error = procedure( png_ptr : png_structp; error : png_charp );  stdcall;

t_png_free = procedure( png_ptr : png_structp; ptr : png_voidp );  stdcall;

t_png_free_data = procedure(png_ptr: png_structp; info_ptr: png_infop; num: int); stdcall;

t_png_free_default = procedure( png_ptr : png_structp; ptr : png_voidp ); stdcall;

t_png_get_IHDR = function(png_ptr: png_structp; info_ptr: png_infop; var width, height: png_uint_32; var bit_depth, color_type, interlace_type, compression_type, filter_type: int): png_uint_32; stdcall;

t_png_get_PLTE = function(png_ptr: png_structp; info_ptr: png_infop; var palette: png_colorp; var num_palette: int): png_uint_32; stdcall;
             
t_png_get_bKGD = function(png_ptr: png_structp; info_ptr: png_infop; var background: png_color_16p): png_uint_32; stdcall;

t_png_get_bit_depth = function(png_ptr: png_structp; info_ptr: png_infop): png_byte; stdcall;

t_png_get_cHRM = function(png_ptr: png_structp; info_ptr: png_infop; var white_x, white_y, red_x, red_y, green_x, green_y, blue_x, blue_y: double): png_uint_32; stdcall;

t_png_get_cHRM_fixed = function(png_ptr : png_structp; info_ptr : png_infop; int_white_x : png_fixed_point; int_white_y : png_fixed_point; int_red_x : png_fixed_point; int_red_y : png_fixed_point; int_green_x : png_fixed_point; int_green_y : png_fixed_point; int_blue_x : png_fixed_point; int_blue_y : png_fixed_point ): png_uint_32; stdcall;

t_png_get_channels = function(png_ptr: png_structp; info_ptr: png_infop): png_byte; stdcall;

t_png_get_color_type = function(png_ptr: png_structp; info_ptr: png_infop): png_byte; stdcall;

t_png_get_compression_type = function(png_ptr: png_structp; info_ptr: png_infop): png_byte; stdcall;

t_png_get_error_ptr = function(png_ptr: png_structp): png_voidp; stdcall;

t_png_get_filter_type = function(png_ptr: png_structp; info_ptr: png_infop): png_byte; stdcall;

t_png_get_gAMA = function(png_ptr: png_structp; info_ptr: png_infop; var file_gamma: double): png_uint_32; stdcall;

t_png_get_gAMA_fixed = function(png_ptr: png_structp; info_ptr: png_infop; var int_file_gamma : png_fixed_point ): png_uint_32; stdcall;

t_png_get_hIST = function(png_ptr: png_structp; info_ptr: png_infop; var hist: png_uint_16p): png_uint_32; stdcall;

t_png_get_iCCP = function(png_ptr: png_structp; info_ptr: png_infop; name: png_charpp; var compression_type: int; profile: png_charpp; proflen: png_int_32): png_uint_32; stdcall;

t_png_get_image_height = function(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

t_png_get_image_width = function(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

t_png_get_interlace_type = function(png_ptr: png_structp; info_ptr: png_infop): png_byte; stdcall;

t_png_get_io_ptr = function(png_ptr: png_structp): png_voidp; stdcall;

t_png_get_oFFs = function(png_ptr: png_structp; info_ptr: png_infop; var offset_x, offset_y: png_uint_32; var unit_type: int): png_uint_32; stdcall;

t_png_get_pCAL = function(png_ptr: png_structp; info_ptr: png_infop; var purpose: png_charp; var X0, X1: png_int_32; var typ, nparams: int; var units: png_charp; var params: png_charpp): png_uint_32; stdcall;

t_png_get_pHYs = function(png_ptr: png_structp; info_ptr: png_infop; var res_x, res_y: png_uint_32; var unit_type: int): png_uint_32; stdcall;

t_png_get_pixel_aspect_ratio = function(png_ptr: png_structp; info_ptr: png_infop): float; stdcall;

t_png_get_pixels_per_meter = function(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

t_png_get_progressive_ptr = function(png_ptr: png_structp): png_voidp; stdcall;

t_png_get_rgb_to_gray_status = function(png_ptr: png_structp) : png_byte; stdcall;

t_png_get_rowbytes = function(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

t_png_get_rows = function(png_ptr: png_structp; info_ptr: png_infop): png_bytepp; stdcall;

t_png_get_sBIT = function(png_ptr: png_structp; info_ptr: png_infop; var sig_bits: png_color_8p): png_uint_32; stdcall;

t_png_get_sCAL = function(png_ptr: png_structp; info_ptr: png_infop; var units:int; var width: png_uint_32; height: png_uint_32): png_uint_32; stdcall;

t_png_get_sCAL_s = function( png_ptr : png_structp; info_ptr : png_infop; var units : int; swidth : png_charpp; sheight : png_charpp ): png_uint_32; stdcall;

t_png_get_sPLT = function(png_ptr: png_structp; info_ptr: png_infop;  entries: png_sPLT_tpp): png_uint_32;stdcall;

t_png_get_sRGB = function(png_ptr: png_structp; info_ptr: png_infop; var file_srgb_intent: int): png_uint_32;             stdcall;

t_png_get_signature = function(png_ptr: png_structp; info_ptr: png_infop): png_bytep; stdcall;

t_png_get_text = function(png_ptr: png_structp; info_ptr: png_infop; var text_ptr: png_textp; var num_text: int): png_uint_32; stdcall;

t_png_get_tIME = function(png_ptr: png_structp; info_ptr: png_infop; var mod_time: png_timep): png_uint_32; stdcall;

t_png_get_tRNS = function(png_ptr: png_structp; info_ptr: png_infop; var trans: png_bytep; var num_trans: int; var trans_values: png_color_16p): png_uint_32; stdcall;

t_png_get_unknown_chunks = function( png_ptr: png_structp; info_ptr: png_infop; entries : png_unknown_chunkpp ): png_uint_32; stdcall;

t_png_get_user_chunk_ptr = function(png_ptr: png_structp): png_voidp; stdcall;

t_png_get_user_transform_ptr = function( png_ptr : png_structp ): png_voidp; stdcall;

t_png_get_valid = function(png_ptr: png_structp; info_ptr: png_infop; flag: png_uint_32): png_uint_32; stdcall;

t_png_get_x_offset_microns = function(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

t_png_get_x_offset_pixels = function(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

t_png_get_x_pixels_per_meter = function(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

t_png_get_y_offset_microns = function(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

t_png_get_y_offset_pixels = function(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

t_png_get_y_pixels_per_meter = function(png_ptr: png_structp; info_ptr: png_infop): png_uint_32; stdcall;

//procedure png_init_io( png_ptr : png_structp; fp : TFile ); stdcall;

t_png_init_io = procedure; stdcall;

t_png_malloc = function( png_ptr : png_structp; size : png_uint_32 ) : png_voidp; stdcall;

t_png_malloc_default = function( png_ptr : png_structp; size : png_uint_32 ) : png_voidp; stdcall;

t_png_memcpy_check = function( png_ptr : png_structp; s1 : png_voidp; s2 : png_voidp; size : png_uint_32 ) : png_voidp; stdcall;

t_png_memset_check = function( png_ptr : png_structp; s1 : png_voidp; value : int; size : png_uint_32 ) : png_voidp; stdcall;

t_png_permit_empty_plte = procedure( png_ptr: png_structp; empty_plte_permitted : int); stdcall;

t_png_process_data = procedure(png_ptr: png_structp; info_ptr: png_infop; buffer: png_bytep; buffer_size: png_size_t); stdcall;

t_png_progressive_combine_row = procedure(png_ptr: png_structp; old_row, new_row: png_bytep); stdcall;

t_png_read_end = procedure(png_ptr: png_structp; info_ptr: png_infop); stdcall;

t_png_read_image = procedure(png_ptr: png_structp; image: png_bytepp); stdcall;

t_png_read_info = procedure(png_ptr: png_structp; info_ptr: png_infop); stdcall;

t_png_read_png = procedure(png_ptr: png_structp; info_ptr: png_infop; transforms : int; params : Pointer ); stdcall;

t_png_read_row = procedure(png_ptr: png_structp; row, dsp_row: png_bytep); stdcall;

t_png_read_rows = procedure(png_ptr: png_structp; row, display_row: png_bytepp; num_rows: png_uint_32); stdcall;

t_png_read_update_info = procedure(png_ptr: png_structp; info_ptr: png_infop); stdcall;

t_png_set_IHDR = procedure(png_ptr: png_structp; info_ptr: png_infop; width, height: png_uint_32; bit_depth, color_type, interlace_type, compression_type, filter_type: int); stdcall;

t_png_set_PLTE = procedure(png_ptr: png_structp; info_ptr: png_infop; palette: png_colorp; num_palette: int); stdcall;

t_png_set_bKGD = procedure(png_ptr: png_structp; info_ptr: png_infop; background: png_color_16p); stdcall;

t_png_set_background = procedure(png_ptr: png_structp; background_color: png_color_16p; background_gamma_code, need_expand: int; background_gamma: double);  stdcall;

t_png_set_bgr = procedure(png_ptr: png_structp); stdcall;

t_png_set_cHRM = procedure(png_ptr: png_structp; info_ptr: png_infop; white_x, white_y, red_x, red_y, green_x, green_y, blue_x, blue_y: double); stdcall;

t_png_set_cHRM_fixed = procedure(png_ptr: png_structp; info_ptr: png_infop; white_x, white_y, red_x, red_y, green_x, green_y, blue_x, blue_y: png_fixed_point); stdcall;

t_png_set_compression_level = procedure(png_ptr: png_structp; level: int); stdcall;

t_png_set_compression_mem_level = procedure(png_ptr: png_structp; mem_level: int); stdcall;

t_png_set_compression_method = procedure(png_ptr: png_structp; method: int); stdcall;

t_png_set_compression_strategy = procedure(png_ptr: png_structp; strategy: int); stdcall;

t_png_set_compression_window_bits = procedure(png_ptr: png_structp; window_bits: int); stdcall;

t_png_set_crc_action = procedure(png_ptr: png_structp; crit_action, ancil_action: int); stdcall;

t_png_set_dither = procedure(png_ptr: png_structp; plaette: png_colorp; num_palette, maximum_colors: int; histogram: png_uint_16p; full_dither: int); stdcall;

t_png_set_error_fn = procedure(png_ptr: png_structp; error_ptr: png_voidp; error_fn, warning_fn: png_error_ptr); stdcall;

t_png_set_expand = procedure(png_ptr: png_structp); stdcall;

t_png_set_filler = procedure(png_ptr: png_structp; filler: png_uint_32; filler_loc: int); stdcall;

t_png_set_filter = procedure(png_ptr: png_structp; method, filters: int); stdcall;

t_png_set_filter_heuristics = procedure (png_ptr: png_structp; heuristic_method, num_weights: int; filter_weights, filter_costs: png_doublep); stdcall;

t_png_set_flush = procedure(png_ptr: png_structp; nrows: int); stdcall;

t_png_set_gAMA = procedure(png_ptr: png_structp; info_ptr: png_infop; file_gamma: double); stdcall;

t_png_set_gAMA_fixed = procedure(png_ptr: png_structp; info_ptr: png_infop; file_gamma: png_fixed_point); stdcall;

t_png_set_gamma = procedure(png_ptr: png_structp; screen_gamma, default_file_gamma: double); stdcall;

t_png_set_gray_1_2_4_to_8 = procedure(png_ptr: png_structp); stdcall;

t_png_set_gray_to_rgb = procedure(png_ptr: png_structp); stdcall;

t_png_set_hIST = procedure(png_ptr: png_structp; info_ptr: png_infop; hist: png_uint_16p); stdcall;

t_png_set_interlace_handling = function(png_ptr: png_structp): int; stdcall;

t_png_set_invert_alpha = procedure(png_ptr: png_structp); stdcall;

t_png_set_invert_mono = procedure(png_ptr: png_structp); stdcall;

t_png_set_itxt = procedure( png_ptr : png_structp; info_ptr : png_infop; text_ptr : png_textp; num_text : int ); stdcall;

t_png_set_keep_unknown_chunks = procedure( png_ptr : png_structp; keep : int; chunk_list : png_bytep; num_chunks : int ); stdcall;

t_png_set_oFFs = procedure(png_ptr: png_structp; info_ptr: png_infop; offset_x, offset_y: png_uint_32; unit_type: int); stdcall;

t_png_set_palette_to_rgb = procedure(png_ptr: png_structp); stdcall;

t_png_set_pCAL = procedure(png_ptr: png_structp; info_ptr: png_infop; purpose: png_charp; X0, X1: png_int_32; typ, nparams: int; units: png_charp; params: png_charpp); stdcall;

t_png_set_pHYs = procedure(png_ptr: png_structp; info_ptr: png_infop; res_x, res_y: png_uint_32; unit_type: int); stdcall;

t_png_set_packing = procedure(png_ptr: png_structp); stdcall;

t_png_set_packswap = procedure(png_ptr: png_structp); stdcall;

t_png_set_progressive_read_fn = procedure(png_ptr: png_structp; progressive_ptr: png_voidp; info_fn: png_progressive_info_ptr;             row_fn: png_progressive_row_ptr; end_fn: png_progressive_end_ptr); stdcall;

t_png_set_read_fn = procedure(png_ptr : png_structp; io_ptr : png_voidp; read_data_fn : png_rw_ptr); stdcall;

t_png_set_read_status_fn = procedure(png_ptr: png_structp; read_row_fn: png_read_status_ptr); stdcall;

t_png_set_read_user_chunk_fn = procedure(png_ptr: png_structp; read_user_chunk_fn: png_user_chunk_ptr); stdcall;

t_png_set_read_user_transform_fn = procedure(png_ptr: png_structp; read_user_transform_fn: png_user_transform_ptr); stdcall;

t_png_set_rgb_to_gray = procedure(png_ptr: png_structp; error_action : int; red_weight, green_weight: double); stdcall;

t_png_set_rgb_to_gray_fixed = procedure(png_ptr: png_structp;  error_action: int; red_weight, green_weight: png_fixed_point); stdcall;

t_png_set_rows = procedure(png_ptr: png_structp; info_ptr: png_infop; row_pointers: png_bytepp); stdcall;

t_png_set_sBIT = procedure(png_ptr: png_structp; info_ptr: png_infop; sig_bits: png_color_8p); stdcall;

t_png_set_sCAL = procedure( png_ptr : png_structp; info_ptr: png_infop; units : int; width : double; height : double ); stdcall;

t_png_set_sCAL_s = procedure( png_ptr : png_structp; info_ptr: png_infop; units : int; width : png_charp; height : png_charp ); stdcall;

t_png_set_sRGB = procedure(png_ptr: png_structp; info_ptr: png_infop; intent: int); stdcall;

t_png_set_sRGB_gAMA_and_cHRM = procedure(png_ptr: png_structp; info_ptr: png_infop; intent: int); stdcall;

t_png_set_shift = procedure(png_ptr: png_structp; true_bits: png_color_8p); stdcall;

t_png_set_sig_bytes = procedure(png_ptr: png_structp; num_bytes: int); stdcall;

t_png_set_strip_16 = procedure(png_ptr: png_structp); stdcall;

t_png_set_strip_alpha = procedure(png_ptr: png_structp); stdcall;

t_png_set_swap = procedure(png_ptr: png_structp); stdcall;

t_png_set_swap_alpha = procedure(png_ptr: png_structp); stdcall;

t_png_set_tIME = procedure(png_ptr: png_structp; info_ptr: png_infop; mod_time: png_timep); stdcall;

t_png_set_tRNS = procedure(png_ptr: png_structp; info_ptr: png_infop; trans: png_bytep; num_trans: int; trans_values: png_color_16p); stdcall;

t_png_set_tRNS_to_alpha = procedure(png_ptr: png_structp); stdcall;

t_png_set_text = procedure(png_ptr: png_structp; info_ptr: png_infop; text_ptr: png_textp; num_text: int); stdcall;

t_png_set_write_fn = procedure(png_ptr: png_structp; io_ptr : png_voidp; write_data_fn : png_rw_ptr; output_flush_fn : png_flush_ptr); stdcall;

t_png_set_write_status_fn = procedure(png_ptr: png_structp; write_row_fn: png_write_status_ptr); stdcall;

t_png_set_write_user_transform_fn = procedure(png_ptr: png_structp; write_user_transform_fn: png_user_transform_ptr); stdcall;

t_png_set_unknown_chunks= procedure( png_ptr: png_structp; info_ptr : png_infop; unknowns : png_unknown_chunkp; num_unknowns : int ) ; stdcall;

t_png_set_user_transform_info = procedure(png_ptr: png_structp; user_transform_ptr : png_voidp; user_transform_depth : int; user_transform_channels : int ); stdcall;

t_png_sig_cmp = function(sig: png_bytep; start, num_to_check: png_size_t): int; stdcall;

t_png_start_read_image = procedure(png_ptr: png_structp); stdcall;

t_png_warning = procedure( png_ptr : png_structp; msg : png_charp ); stdcall;

t_png_write_chunk = procedure(png_ptr: png_structp; chunk_name, data: png_bytep; length: png_size_t); stdcall;

t_png_write_chunk_data = procedure(png_ptr: png_structp; data: png_bytep; length: png_size_t); stdcall;

t_png_write_chunk_end = procedure(png_ptr: png_structp); stdcall;

t_png_write_chunk_start = procedure(png_ptr: png_structp; chunk_name: png_bytep; length: png_uint_32); stdcall;

t_png_write_end = procedure(png_ptr: png_structp; info_ptr: png_infop); stdcall;

t_png_write_flush = procedure(png_ptr: png_structp); stdcall;

t_png_write_image = procedure(png_ptr: png_structp; image: png_bytepp); stdcall;

t_png_write_info = procedure(png_ptr: png_structp; info_ptr: png_infop); stdcall;

t_png_write_info_before_PLTE = procedure(png_ptr: png_structp; info_ptr: png_infop); stdcall;

t_png_write_png = procedure(png_ptr: png_structp; info_ptr: png_infop; transforms : int; params : Pointer ); stdcall;

t_png_write_row = procedure(png_ptr: png_structp; row: png_bytep); stdcall;

t_png_write_rows = procedure(png_ptr: png_structp; row: png_bytepp; num_rows: png_uint_32); stdcall;
             
t_png_set_iCCP = procedure(png_ptr: png_structp; info_ptr: png_infop; name: png_charp; compression_type: int; profile: png_charp; proflen: int); stdcall;

t_png_set_sPLT = procedure(png_ptr: png_structp; info_ptr: png_infop; entries: png_sPLT_tp; nentries: int); stdcall;

// Alpha Macros

t_png_composite = function( Foreground, Alpha, Background: Byte ) : Byte;

t_png_composite_16 = function( Foreground, Alpha, Background: Byte ) : png_uint_32;

t_png_composite_integer = function( Foreground, Alpha, Background: Byte ) : Byte;

t_png_composite_16_integer = function( Foreground, Alpha, Background: Byte ) : png_uint_32;

var
  png_build_grayscale_palette : t_png_build_grayscale_palette;
  png_check_sig : t_png_check_sig;
  png_chunk_error : t_png_chunk_error;
  png_chunk_warning : t_png_chunk_warning;
  png_convert_from_time_t : t_png_convert_from_time_t;
  png_convert_to_rfc1123 : t_png_convert_to_rfc1123;
  png_create_info_struct : t_png_create_info_struct;
  png_create_read_struct : t_png_create_read_struct;
  png_get_copyright : t_png_get_copyright;
  png_get_header_ver : t_png_get_header_ver;
  png_get_header_version : t_png_get_header_version;
  png_get_libpng_ver : t_png_get_libpng_ver;
  png_create_write_struct : t_png_create_write_struct;
  png_destroy_info_struct : t_png_destroy_info_struct;
  png_destroy_read_struct : t_png_destroy_read_struct;
  png_destroy_write_struct : t_png_destroy_write_struct;
  png_error : t_png_error;
  png_free : t_png_free;
  png_free_data : t_png_free_data;
  png_free_default : t_png_free_default;
  png_get_IHDR : t_png_get_IHDR;
  png_get_PLTE : t_png_get_PLTE;
  png_get_bKGD : t_png_get_bKGD;
  png_get_bit_depth : t_png_get_bit_depth;
  png_get_cHRM : t_png_get_cHRM;
  png_get_cHRM_fixed : t_png_get_cHRM_fixed;
  png_get_channels : t_png_get_channels;
  png_get_color_type : t_png_get_color_type;
  png_get_compression_type : t_png_get_compression_type;
  png_get_error_ptr : t_png_get_error_ptr;
  png_get_filter_type : t_png_get_filter_type;
  png_get_gAMA : t_png_get_gAMA;
  png_get_gAMA_fixed : t_png_get_gAMA_fixed;
  png_get_hIST : t_png_get_hIST;
  png_get_image_height : t_png_get_image_height;
  png_get_image_width : t_png_get_image_width;
  png_get_interlace_type : t_png_get_interlace_type;
  png_get_io_ptr : t_png_get_io_ptr;
  png_get_iCCP : t_png_get_iCCP;
  png_get_oFFs : t_png_get_oFFs;
  png_get_sCAL : t_png_get_sCAL;
  png_get_sCAL_s : t_png_get_sCAL_s;
  png_get_sPLT : t_png_get_sPLT;
  png_get_pCAL : t_png_get_pCAL;
  png_get_pHYs : t_png_get_pHYs;
  png_get_pixel_aspect_ratio : t_png_get_pixel_aspect_ratio;
  png_get_pixels_per_meter : t_png_get_pixels_per_meter;
  png_get_progressive_ptr : t_png_get_progressive_ptr;
  png_get_rgb_to_gray_status : t_png_get_rgb_to_gray_status;
  png_get_rowbytes : t_png_get_rowbytes;
  png_get_rows : t_png_get_rows;
  png_get_sBIT : t_png_get_sBIT;
  png_get_sRGB : t_png_get_sRGB;
  png_get_signature : t_png_get_signature;
  png_get_text : t_png_get_text;
  png_get_tIME : t_png_get_tIME;
  png_get_tRNS : t_png_get_tRNS;
  png_get_unknown_chunks : t_png_get_unknown_chunks;
  png_get_user_chunk_ptr : t_png_get_user_chunk_ptr;
  png_get_user_transform_ptr : t_png_get_user_transform_ptr;
  png_get_valid : t_png_get_valid;
  png_get_x_offset_microns : t_png_get_x_offset_microns;
  png_get_x_offset_pixels : t_png_get_x_offset_pixels;
  png_get_x_pixels_per_meter : t_png_get_x_pixels_per_meter;
  png_get_y_offset_microns : t_png_get_y_offset_microns;
  png_get_y_offset_pixels : t_png_get_y_offset_pixels;
  png_get_y_pixels_per_meter : t_png_get_y_pixels_per_meter;
  png_init_io : t_png_init_io;
  png_malloc : t_png_malloc;
  png_malloc_default : t_png_malloc_default;
  png_memcpy_check : t_png_memcpy_check;
  png_memset_check : t_png_memset_check;
  png_permit_empty_plte : t_png_permit_empty_plte;
  png_process_data : t_png_process_data;
  png_progressive_combine_row : t_png_progressive_combine_row;
  png_read_end : t_png_read_end;
  png_read_image : t_png_read_image;
  png_read_info : t_png_read_info;
  png_read_png : t_png_read_png;
  png_read_row : t_png_read_row;
  png_read_rows : t_png_read_rows;
  png_read_update_info : t_png_read_update_info;
  png_set_bKGD : t_png_set_bKGD;
  png_set_background : t_png_set_background;
  png_set_bgr : t_png_set_bgr;
  png_set_cHRM : t_png_set_cHRM;
  png_set_cHRM_fixed : t_png_set_cHRM_fixed;
  png_set_compression_level : t_png_set_compression_level;
  png_set_compression_mem_level : t_png_set_compression_mem_level;
  png_set_compression_method : t_png_set_compression_method;
  png_set_compression_strategy : t_png_set_compression_strategy;
  png_set_compression_window_bits : t_png_set_compression_window_bits;
  png_set_crc_action : t_png_set_crc_action;
  png_set_dither : t_png_set_dither;
  png_set_error_fn : t_png_set_error_fn;
  png_set_expand : t_png_set_expand;
  png_set_filler : t_png_set_filler;
  png_set_filter : t_png_set_filter;
  png_set_filter_heuristics : t_png_set_filter_heuristics;
  png_set_flush : t_png_set_flush;
  png_set_gAMA : t_png_set_gAMA;
  png_set_gAMA_fixed : t_png_set_gAMA_fixed;
  png_set_gamma : t_png_set_gamma;
  png_set_gray_1_2_4_to_8 : t_png_set_gray_1_2_4_to_8;
  png_set_gray_to_rgb : t_png_set_gray_to_rgb;
  png_set_hIST : t_png_set_hIST;
  png_set_iCCP : t_png_set_iCCP;
  png_set_IHDR : t_png_set_IHDR;
  png_set_interlace_handling : t_png_set_interlace_handling;
  png_set_invert_alpha : t_png_set_invert_alpha;
  png_set_invert_mono : t_png_set_invert_mono;
  png_set_itxt : t_png_set_itxt;
  png_set_keep_unknown_chunks : t_png_set_keep_unknown_chunks;
  png_set_oFFs : t_png_set_oFFs;
  png_set_palette_to_rgb : t_png_set_palette_to_rgb;
  png_set_pCAL : t_png_set_pCAL;
  png_set_pHYs : t_png_set_pHYs;
  png_set_PLTE : t_png_set_PLTE;
  png_set_packing : t_png_set_packing;
  png_set_packswap : t_png_set_packswap;
  png_set_progressive_read_fn : t_png_set_progressive_read_fn;
  png_set_read_fn : t_png_set_read_fn;
  png_set_read_status_fn : t_png_set_read_status_fn;
  png_set_read_user_chunk_fn : t_png_set_read_user_chunk_fn;
  png_set_read_user_transform_fn : t_png_set_read_user_transform_fn;
  png_set_rgb_to_gray : t_png_set_rgb_to_gray;
  png_set_rgb_to_gray_fixed : t_png_set_rgb_to_gray_fixed;
  png_set_rows : t_png_set_rows;
  png_set_sBIT : t_png_set_sBIT;
  png_set_sCAL : t_png_set_sCAL;
  png_set_sCAL_s : t_png_set_sCAL_s;
  png_set_sPLT : t_png_set_sPLT;
  png_set_sRGB : t_png_set_sRGB;
  png_set_sRGB_gAMA_and_cHRM : t_png_set_sRGB_gAMA_and_cHRM;
  png_set_shift : t_png_set_shift;
  png_set_sig_bytes : t_png_set_sig_bytes;
  png_set_strip_16 : t_png_set_strip_16;
  png_set_strip_alpha : t_png_set_strip_alpha;
  png_set_swap : t_png_set_swap;
  png_set_swap_alpha : t_png_set_swap_alpha;
  png_set_tIME : t_png_set_tIME;
  png_set_tRNS : t_png_set_tRNS;
  png_set_tRNS_to_alpha : t_png_set_tRNS_to_alpha;
  png_set_text : t_png_set_text;
  png_set_write_fn : t_png_set_write_fn;
  png_set_write_status_fn : t_png_set_write_status_fn;
  png_set_write_user_transform_fn : t_png_set_write_user_transform_fn;
  png_set_unknown_chunks : t_png_set_unknown_chunks;
  png_set_user_transform_info : t_png_set_user_transform_info;
  png_sig_cmp : t_png_sig_cmp;
  png_start_read_image : t_png_start_read_image;
  png_warning : t_png_warning;
  png_write_chunk : t_png_write_chunk;
  png_write_chunk_data : t_png_write_chunk_data;
  png_write_chunk_end : t_png_write_chunk_end;
  png_write_chunk_start : t_png_write_chunk_start;
  png_write_end : t_png_write_end;
  png_write_flush : t_png_write_flush;
  png_write_image : t_png_write_image;
  png_write_info : t_png_write_info;
  png_write_info_before_PLTE : t_png_write_info_before_PLTE;
  png_write_png : t_png_write_png;
  png_write_row : t_png_write_row;
  png_write_rows : t_png_write_rows;
  hngDLL : integer = 0;
  PNG_CAN_SAVE : boolean = false;
               
procedure InitPNG;

implementation

const
{$IFDEF PNGPX}
  pngDLL = 'lpng-px.dll';
{$ELSE}
  pngDLL = 'lpng.dll';
{$ENDIF}





(*
procedure png_build_grayscale_palette; external pngDLL;
function png_check_sig; external pngDLL;
procedure png_chunk_error; external pngDLL;
procedure png_chunk_warning; external pngDLL;
procedure png_convert_from_time_t; external pngDLL;
function png_convert_to_rfc1123; external pngDLL;
function png_create_info_struct; external pngDLL;
function png_create_read_struct; external pngDLL;
function png_get_copyright; external pngDLL;
function png_get_header_ver; external pngDLL;
function png_get_header_version; external pngDLL;
function png_get_libpng_ver; external pngDLL;
function png_create_write_struct; external pngDLL;
procedure png_destroy_info_struct; external pngDLL;
procedure png_destroy_read_struct; external pngDLL;
procedure png_destroy_write_struct; external pngDLL;
procedure png_error; external pngDLL;
procedure png_free; external pngDLL;
procedure png_free_data; external pngDLL;
procedure png_free_default; external pngDLL;
function png_get_IHDR; external pngDLL;
function png_get_PLTE; external pngDLL;
function png_get_bKGD; external pngDLL;
function png_get_bit_depth; external pngDLL;
function png_get_cHRM; external pngDLL;
function png_get_cHRM_fixed; external pngDLL;
function png_get_channels; external pngDLL;
function png_get_color_type; external pngDLL;
function png_get_compression_type; external pngDLL;
function png_get_error_ptr; external pngDLL;
function png_get_filter_type; external pngDLL;
function png_get_gAMA; external pngDLL;
function png_get_gAMA_fixed; external pngDLL;
function png_get_hIST; external pngDLL;
function png_get_image_height; external pngDLL;
function png_get_image_width; external pngDLL;
function png_get_interlace_type; external pngDLL;
function png_get_io_ptr; external pngDLL;

function png_get_iCCP; external pngDLL;
function png_get_oFFs; external pngDLL;
function png_get_sCAL; external pngDLL;
function png_get_sCAL_s; external pngDLL;
function png_get_sPLT; external pngDLL;
function png_get_pCAL; external pngDLL;
function png_get_pHYs; external pngDLL;
function png_get_pixel_aspect_ratio; external pngDLL;
function png_get_pixels_per_meter; external pngDLL;
function png_get_progressive_ptr; external pngDLL;
function png_get_rgb_to_gray_status; external pngDLL;
function png_get_rowbytes; external pngDLL;
function png_get_rows; external pngDLL;
function png_get_sBIT; external pngDLL;
function png_get_sRGB; external pngDLL;
function png_get_signature; external pngDLL;
function png_get_text; external pngDLL;
function png_get_tIME; external pngDLL;
function png_get_tRNS; external pngDLL;
function png_get_unknown_chunks; external pngDLL;
function png_get_user_chunk_ptr; external pngDLL;
function png_get_user_transform_ptr; external pngDLL;
function png_get_valid; external pngDLL;
function png_get_x_offset_microns; external pngDLL;
function png_get_x_offset_pixels; external pngDLL;
function png_get_x_pixels_per_meter; external pngDLL;
function png_get_y_offset_microns; external pngDLL;
function png_get_y_offset_pixels; external pngDLL;
function png_get_y_pixels_per_meter; external pngDLL;
procedure png_init_io; external pngDLL;
function png_malloc; external pngDLL;
function png_malloc_default; external pngDLL;
function png_memcpy_check; external pngDLL;
function png_memset_check; external pngDLL;
procedure png_permit_empty_plte; external pngDLL;
procedure png_process_data; external pngDLL;
procedure png_progressive_combine_row; external pngDLL;
procedure png_read_end; external pngDLL;
procedure png_read_image; external pngDLL;
procedure png_read_info; external pngDLL;
procedure png_read_png; external pngDLL;
procedure png_read_row; external pngDLL;
procedure png_read_rows; external pngDLL;
procedure png_read_update_info; external pngDLL;
procedure png_set_bKGD; external pngDLL;
procedure png_set_background; external pngDLL;
procedure png_set_bgr; external pngDLL;
procedure png_set_cHRM; external pngDLL;
procedure png_set_cHRM_fixed; external pngDLL;
procedure png_set_compression_level; external pngDLL;
procedure png_set_compression_mem_level; external pngDLL;
procedure png_set_compression_method; external pngDLL;
procedure png_set_compression_strategy; external pngDLL;
procedure png_set_compression_window_bits; external pngDLL;
procedure png_set_crc_action; external pngDLL;
procedure png_set_dither; external pngDLL;
procedure png_set_error_fn; external pngDLL;
procedure png_set_expand; external pngDLL;
procedure png_set_filler; external pngDLL;
procedure png_set_filter; external pngDLL;
procedure png_set_filter_heuristics; external pngDLL;
procedure png_set_flush; external pngDLL;
procedure png_set_gAMA; external pngDLL;
procedure png_set_gAMA_fixed; external pngDLL;
procedure png_set_gamma; external pngDLL;
procedure png_set_gray_1_2_4_to_8; external pngDLL;
procedure png_set_gray_to_rgb; external pngDLL;
procedure png_set_hIST; external pngDLL;
procedure png_set_iCCP; external pngDLL;
procedure png_set_IHDR; external pngDLL;
function png_set_interlace_handling; external pngDLL;
procedure png_set_invert_alpha; external pngDLL;
procedure png_set_invert_mono; external pngDLL;
procedure png_set_itxt; external pngDLL;
procedure png_set_keep_unknown_chunks; external pngDLL;
procedure png_set_oFFs; external pngDLL;
procedure png_set_palette_to_rgb; external pngDLL;
procedure png_set_pCAL; external pngDLL;
procedure png_set_pHYs; external pngDLL;
procedure png_set_PLTE; external pngDLL;
procedure png_set_packing; external pngDLL;
procedure png_set_packswap; external pngDLL;
procedure png_set_progressive_read_fn; external pngDLL;
procedure png_set_read_fn; external pngDLL;
procedure png_set_read_status_fn; external pngDLL;
procedure png_set_read_user_chunk_fn; external pngDLL;
procedure png_set_read_user_transform_fn; external pngDLL;
procedure png_set_rgb_to_gray; external pngDLL;
procedure png_set_rgb_to_gray_fixed; external pngDLL;
procedure png_set_rows; external pngDLL;
procedure png_set_sBIT; external pngDLL;
procedure png_set_sCAL; external pngDLL;
procedure png_set_sCAL_s; external pngDLL;
procedure png_set_sPLT; external pngDLL;
procedure png_set_sRGB; external pngDLL;
procedure png_set_sRGB_gAMA_and_cHRM; external pngDLL;
procedure png_set_shift; external pngDLL;
procedure png_set_sig_bytes; external pngDLL;
procedure png_set_strip_16; external pngDLL;
procedure png_set_strip_alpha; external pngDLL;
procedure png_set_swap; external pngDLL;
procedure png_set_swap_alpha; external pngDLL;
procedure png_set_tIME; external pngDLL;
procedure png_set_tRNS; external pngDLL;
procedure png_set_tRNS_to_alpha; external pngDLL;
procedure png_set_text; external pngDLL;
procedure png_set_write_fn; external pngDLL;
procedure png_set_write_status_fn; external pngDLL;
procedure png_set_write_user_transform_fn; external pngDLL;
procedure png_set_unknown_chunks; external pngDLL;
procedure png_set_user_transform_info; external pngDLL;
function png_sig_cmp; external pngDLL;
procedure png_start_read_image; external pngDLL;
procedure png_warning;external pngDLL;
procedure png_write_chunk; external pngDLL;
procedure png_write_chunk_data; external pngDLL;
procedure png_write_chunk_end; external pngDLL;
procedure png_write_chunk_start; external pngDLL;
procedure png_write_end; external pngDLL;
procedure png_write_flush; external pngDLL;
procedure png_write_image; external pngDLL;
procedure png_write_info; external pngDLL;
procedure png_write_info_before_PLTE; external pngDLL;
procedure png_write_png; external pngDLL;
procedure png_write_row; external pngDLL;
procedure png_write_rows; external pngDLL;
 *)

function png_composite( Foreground, Alpha, Background: Byte ) : png_byte;
var
  temp : png_byte;
begin
  temp :=  Foreground * Alpha + Background * ( 255 - Alpha ) + 128;
  result := ( temp + ( temp shr 8 ) ) shr 8;
end;

function png_composite_integer( Foreground, Alpha, Background: Byte ) : png_byte;
begin
  result := png_byte( ( Foreground * Alpha + Background * ( 255 - Alpha ) + 127 ) div 255 );
end;

function png_composite_16( Foreground, Alpha, Background: Byte ) : png_uint_32;
var
  temp : png_uint_32;
begin
  temp :=  Foreground * Alpha + Background * ( 65535 - Alpha ) + 32768;
  result := png_uint_32( ( temp + ( temp shr 16 ) ) shr 16 );
end;

function png_composite_16_integer( Foreground, Alpha, Background: Byte ) : png_uint_32;
begin
  result := png_uint_32( ( Foreground * Alpha + Background * ( 65535 - Alpha ) + 32767 ) div 65535 );
end;

procedure InitPNG;
begin
  if hngDLL = 0 then
  begin
   TW.I.Start('pngDLL');
   If AnsiUpperCase(paramStr(1))<>'/SAFEMODE' then
    If AnsiUpperCase(paramStr(1))<>'/UNINSTALL' then
   hngDLL:=LoadLibrary(pngDLL);

  if hngDLL>0 then
  begin
    png_build_grayscale_palette := GetProcAddress(hngDLL,'png_build_grayscale_palette');
    png_check_sig := GetProcAddress(hngDLL,'png_check_sig');
    png_chunk_error := GetProcAddress(hngDLL,'png_chunk_error');
    png_chunk_warning := GetProcAddress(hngDLL,'png_chunk_warning');
    png_convert_from_time_t := GetProcAddress(hngDLL,'png_convert_from_time_t');
    png_convert_to_rfc1123 := GetProcAddress(hngDLL,'png_convert_to_rfc1123');
    png_create_info_struct := GetProcAddress(hngDLL,'png_create_info_struct');
    png_create_read_struct := GetProcAddress(hngDLL,'png_create_read_struct');
    png_get_copyright := GetProcAddress(hngDLL,'png_get_copyright');
    png_get_header_ver := GetProcAddress(hngDLL,'png_get_header_ver');
    png_get_header_version := GetProcAddress(hngDLL,'png_get_header_version');
    png_get_libpng_ver := GetProcAddress(hngDLL,'png_get_libpng_ver');
    png_create_write_struct := GetProcAddress(hngDLL,'png_create_write_struct');
    png_destroy_info_struct := GetProcAddress(hngDLL,'png_destroy_info_struct');
    png_destroy_read_struct := GetProcAddress(hngDLL,'png_destroy_read_struct');
    png_destroy_write_struct := GetProcAddress(hngDLL,'png_destroy_write_struct');
    png_error := GetProcAddress(hngDLL,'png_error');
    png_free := GetProcAddress(hngDLL,'png_free');
    png_free_data := GetProcAddress(hngDLL,'png_free_data');
    png_free_default := GetProcAddress(hngDLL,'png_free_default');
    png_get_IHDR := GetProcAddress(hngDLL,'png_get_IHDR');
    png_get_PLTE := GetProcAddress(hngDLL,'png_get_PLTE');
    png_get_bKGD := GetProcAddress(hngDLL,'png_get_bKGD');
    png_get_bit_depth := GetProcAddress(hngDLL,'png_get_bit_depth');
    png_get_cHRM := GetProcAddress(hngDLL,'png_get_cHRM');
    png_get_cHRM_fixed := GetProcAddress(hngDLL,'png_get_cHRM_fixed');
    png_get_channels := GetProcAddress(hngDLL,'png_get_channels');
    png_get_color_type := GetProcAddress(hngDLL,'png_get_color_type');
    png_get_compression_type := GetProcAddress(hngDLL,'png_get_compression_type');
    png_get_error_ptr := GetProcAddress(hngDLL,'png_get_error_ptr');
    png_get_filter_type := GetProcAddress(hngDLL,'png_get_filter_type');
    png_get_gAMA := GetProcAddress(hngDLL,'png_get_gAMA');
    png_get_gAMA_fixed := GetProcAddress(hngDLL,'png_get_gAMA_fixed');
    png_get_hIST := GetProcAddress(hngDLL,'png_get_hIST');
    png_get_image_height := GetProcAddress(hngDLL,'png_get_image_height');
    png_get_image_width := GetProcAddress(hngDLL,'png_get_image_width');
    png_get_interlace_type := GetProcAddress(hngDLL,'png_get_interlace_type');
    png_get_io_ptr := GetProcAddress(hngDLL,'png_get_io_ptr');
    png_get_iCCP := GetProcAddress(hngDLL,'png_get_iCCP');
    png_get_oFFs := GetProcAddress(hngDLL,'png_get_oFFs');
    png_get_sCAL := GetProcAddress(hngDLL,'png_get_sCAL');
    png_get_sCAL_s := GetProcAddress(hngDLL,'png_get_sCAL_s');
    png_get_sPLT := GetProcAddress(hngDLL,'png_get_sPLT');
    png_get_pCAL := GetProcAddress(hngDLL,'png_get_pCAL');
    png_get_pHYs := GetProcAddress(hngDLL,'png_get_pHYs');
    png_get_pixel_aspect_ratio := GetProcAddress(hngDLL,'png_get_pixel_aspect_ratio');
    png_get_pixels_per_meter := GetProcAddress(hngDLL,'png_get_pixels_per_meter');
    png_get_progressive_ptr := GetProcAddress(hngDLL,'png_get_progressive_ptr');
    png_get_rgb_to_gray_status := GetProcAddress(hngDLL,'png_get_rgb_to_gray_status');
    png_get_rowbytes := GetProcAddress(hngDLL,'png_get_rowbytes');
    png_get_rows := GetProcAddress(hngDLL,'png_get_rows');
    png_get_sBIT := GetProcAddress(hngDLL,'png_get_sBIT');
    png_get_sRGB := GetProcAddress(hngDLL,'png_get_sRGB');
    png_get_signature := GetProcAddress(hngDLL,'png_get_signature');
    png_get_text := GetProcAddress(hngDLL,'png_get_text');
    png_get_tIME := GetProcAddress(hngDLL,'png_get_tIME');
    png_get_tRNS := GetProcAddress(hngDLL,'png_get_tRNS');
    png_get_unknown_chunks := GetProcAddress(hngDLL,'png_get_unknown_chunks');
    png_get_user_chunk_ptr := GetProcAddress(hngDLL,'png_get_user_chunk_ptr');
    png_get_user_transform_ptr := GetProcAddress(hngDLL,'png_get_user_transform_ptr');
    png_get_valid := GetProcAddress(hngDLL,'png_get_valid');
    png_get_x_offset_microns := GetProcAddress(hngDLL,'png_get_x_offset_microns');
    png_get_x_offset_pixels := GetProcAddress(hngDLL,'png_get_x_offset_pixels');
    png_get_x_pixels_per_meter := GetProcAddress(hngDLL,'png_get_x_pixels_per_meter');
    png_get_y_offset_microns := GetProcAddress(hngDLL,'png_get_y_offset_microns');
    png_get_y_offset_pixels := GetProcAddress(hngDLL,'png_get_y_offset_pixels');
    png_get_y_pixels_per_meter := GetProcAddress(hngDLL,'png_get_y_pixels_per_meter');
    png_init_io := GetProcAddress(hngDLL,'png_init_io');
    png_malloc := GetProcAddress(hngDLL,'png_malloc');
    png_malloc_default := GetProcAddress(hngDLL,'png_malloc_default');
    png_memcpy_check := GetProcAddress(hngDLL,'png_memcpy_check');
    png_memset_check := GetProcAddress(hngDLL,'png_memset_check');
    png_permit_empty_plte := GetProcAddress(hngDLL,'png_permit_empty_plte');
    png_process_data := GetProcAddress(hngDLL,'png_process_data');
    png_progressive_combine_row := GetProcAddress(hngDLL,'png_progressive_combine_row');
    png_read_end := GetProcAddress(hngDLL,'png_read_end');
    png_read_image := GetProcAddress(hngDLL,'png_read_image');
    png_read_info := GetProcAddress(hngDLL,'png_read_info');
    png_read_png := GetProcAddress(hngDLL,'png_read_png');
    png_read_row := GetProcAddress(hngDLL,'png_read_row');
    png_read_rows := GetProcAddress(hngDLL,'png_read_rows');
    png_read_update_info := GetProcAddress(hngDLL,'png_read_update_info');
    png_set_bKGD := GetProcAddress(hngDLL,'png_set_bKGD');
    png_set_background := GetProcAddress(hngDLL,'png_set_background');
    png_set_bgr := GetProcAddress(hngDLL,'png_set_bgr');
    png_set_cHRM := GetProcAddress(hngDLL,'png_set_cHRM');
    png_set_cHRM_fixed := GetProcAddress(hngDLL,'png_set_cHRM_fixed');
    png_set_compression_level := GetProcAddress(hngDLL,'png_set_compression_level');
    png_set_compression_mem_level := GetProcAddress(hngDLL,'png_set_compression_mem_level');
    png_set_compression_method := GetProcAddress(hngDLL,'png_set_compression_method');
    png_set_compression_strategy := GetProcAddress(hngDLL,'png_set_compression_strategy');
    png_set_compression_window_bits := GetProcAddress(hngDLL,'png_set_compression_window_bits');
    png_set_crc_action := GetProcAddress(hngDLL,'png_set_crc_action');
    png_set_dither := GetProcAddress(hngDLL,'png_set_dither');
    png_set_error_fn := GetProcAddress(hngDLL,'png_set_error_fn');
    png_set_expand := GetProcAddress(hngDLL,'png_set_expand');
    png_set_filler := GetProcAddress(hngDLL,'png_set_filler');
    png_set_filter := GetProcAddress(hngDLL,'png_set_filter');
    png_set_filter_heuristics := GetProcAddress(hngDLL,'png_set_filter_heuristics');
    png_set_flush := GetProcAddress(hngDLL,'png_set_flush');
    png_set_gAMA := GetProcAddress(hngDLL,'png_set_gAMA');
    png_set_gAMA_fixed := GetProcAddress(hngDLL,'png_set_gAMA_fixed');
    png_set_gamma := GetProcAddress(hngDLL,'png_set_gamma');
    png_set_gray_1_2_4_to_8 := GetProcAddress(hngDLL,'png_set_gray_1_2_4_to_8');
    png_set_gray_to_rgb := GetProcAddress(hngDLL,'png_set_gray_to_rgb');
    png_set_hIST := GetProcAddress(hngDLL,'png_set_hIST');
    png_set_iCCP := GetProcAddress(hngDLL,'png_set_iCCP');
    png_set_IHDR := GetProcAddress(hngDLL,'png_set_IHDR');
    png_set_interlace_handling := GetProcAddress(hngDLL,'png_set_interlace_handling');
    png_set_invert_alpha := GetProcAddress(hngDLL,'png_set_invert_alpha');
    png_set_invert_mono := GetProcAddress(hngDLL,'png_set_invert_mono');
    png_set_itxt := GetProcAddress(hngDLL,'png_set_itxt');
    png_set_keep_unknown_chunks := GetProcAddress(hngDLL,'png_set_keep_unknown_chunks');
    png_set_oFFs := GetProcAddress(hngDLL,'png_set_oFFs');
    png_set_palette_to_rgb := GetProcAddress(hngDLL,'png_set_palette_to_rgb');
    png_set_pCAL := GetProcAddress(hngDLL,'png_set_pCAL');
    png_set_pHYs := GetProcAddress(hngDLL,'png_set_pHYs');
    png_set_PLTE := GetProcAddress(hngDLL,'png_set_PLTE');
    png_set_packing := GetProcAddress(hngDLL,'png_set_packing');
    png_set_packswap := GetProcAddress(hngDLL,'png_set_packswap');
    png_set_progressive_read_fn := GetProcAddress(hngDLL,'png_set_progressive_read_fn');
    png_set_read_fn := GetProcAddress(hngDLL,'png_set_read_fn');
    png_set_read_status_fn := GetProcAddress(hngDLL,'png_set_read_status_fn');
    png_set_read_user_chunk_fn := GetProcAddress(hngDLL,'png_set_read_user_chunk_fn');
    png_set_read_user_transform_fn := GetProcAddress(hngDLL,'png_set_read_user_transform_fn');
    png_set_rgb_to_gray := GetProcAddress(hngDLL,'png_set_rgb_to_gray');
    png_set_rgb_to_gray_fixed := GetProcAddress(hngDLL,'png_set_rgb_to_gray_fixed');
    png_set_rows := GetProcAddress(hngDLL,'png_set_rows');
    png_set_sBIT := GetProcAddress(hngDLL,'png_set_sBIT');
    png_set_sCAL := GetProcAddress(hngDLL,'png_set_sCAL');
    png_set_sCAL_s := GetProcAddress(hngDLL,'png_set_sCAL_s');
    png_set_sPLT := GetProcAddress(hngDLL,'png_set_sPLT');
    png_set_sRGB := GetProcAddress(hngDLL,'png_set_sRGB');
    png_set_sRGB_gAMA_and_cHRM := GetProcAddress(hngDLL,'png_set_sRGB_gAMA_and_cHRM');
    png_set_shift := GetProcAddress(hngDLL,'png_set_shift');
    png_set_sig_bytes := GetProcAddress(hngDLL,'png_set_sig_bytes');
    png_set_strip_16 := GetProcAddress(hngDLL,'png_set_strip_16');
    png_set_strip_alpha := GetProcAddress(hngDLL,'png_set_strip_alpha');
    png_set_swap := GetProcAddress(hngDLL,'png_set_swap');
    png_set_swap_alpha := GetProcAddress(hngDLL,'png_set_swap_alpha');
    png_set_tIME := GetProcAddress(hngDLL,'png_set_tIME');
    png_set_tRNS := GetProcAddress(hngDLL,'png_set_tRNS');
    png_set_tRNS_to_alpha := GetProcAddress(hngDLL,'png_set_tRNS_to_alpha');
    png_set_text := GetProcAddress(hngDLL,'png_set_text');
    png_set_write_fn := GetProcAddress(hngDLL,'png_set_write_fn');
    png_set_write_status_fn := GetProcAddress(hngDLL,'png_set_write_status_fn');
    png_set_write_user_transform_fn := GetProcAddress(hngDLL,'png_set_write_user_transform_fn');
    png_set_unknown_chunks := GetProcAddress(hngDLL,'png_set_unknown_chunks');
    png_set_user_transform_info := GetProcAddress(hngDLL,'png_set_user_transform_info');
    png_sig_cmp := GetProcAddress(hngDLL,'png_sig_cmp');
    png_start_read_image := GetProcAddress(hngDLL,'png_start_read_image');
    png_warning := GetProcAddress(hngDLL,'png_warning');
    png_write_chunk := GetProcAddress(hngDLL,'png_write_chunk');
    png_write_chunk_data := GetProcAddress(hngDLL,'png_write_chunk_data');
    png_write_chunk_end := GetProcAddress(hngDLL,'png_write_chunk_end');
    png_write_chunk_start := GetProcAddress(hngDLL,'png_write_chunk_start');
    png_write_end := GetProcAddress(hngDLL,'png_write_end');
    png_write_flush := GetProcAddress(hngDLL,'png_write_flush');
    png_write_image := GetProcAddress(hngDLL,'png_write_image');
    png_write_info := GetProcAddress(hngDLL,'png_write_info');
    png_write_info_before_PLTE := GetProcAddress(hngDLL,'png_write_info_before_PLTE');
    png_write_png := GetProcAddress(hngDLL,'png_write_png');
    png_write_row := GetProcAddress(hngDLL,'png_write_row');
    png_write_rows := GetProcAddress(hngDLL,'png_write_rows');
    PNG_CAN_SAVE:=true;
  end;
  TW.I.Start('pngDLL - END');
  end;
end;

initialization

end.

