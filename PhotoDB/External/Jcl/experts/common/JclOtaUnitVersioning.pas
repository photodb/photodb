{**************************************************************************************************}
{                                                                                                  }
{ Project JEDI Code Library (JCL)                                                                  }
{                                                                                                  }
{ The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License"); }
{ you may not use this file except in compliance with the License. You may obtain a copy of the    }
{ License at http://www.mozilla.org/MPL/                                                           }
{                                                                                                  }
{ Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF   }
{ ANY KIND, either express or implied. See the License for the specific language governing rights  }
{ and limitations under the License.                                                               }
{                                                                                                  }
{ The Original Code is JclOtaUtils.pas.                                                            }
{                                                                                                  }
{ The Initial Developer of the Original Code is Petr Vones.                                        }
{ Portions created by Petr Vones are Copyright (C) of Petr Vones.                                  }
{                                                                                                  }
{ Contributors:                                                                                    }
{   Florent Ouchet (outchy)                                                                        }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Last modified: $Date:: 2012-01-23 21:45:41 +0100 (Mon, 23 Jan 2012)                            $ }
{ Revision:      $Rev:: 3703                                                                     $ }
{ Author:        $Author:: outchy                                                                $ }
{                                                                                                  }
{**************************************************************************************************}

unit JclOtaUnitVersioning;

interface

{$I jcl.inc}
{$I crossplatform.inc}

uses
  SysUtils, Classes, Windows,
  Controls, Forms,
  JclBase,
  {$IFDEF UNITVERSIONING}
  JclUnitVersioning,
  {$ENDIF UNITVERSIONING}
  JclOTAUtils;

type
  TJclOTAUnitVersioningExpert = class(TJclOTAExpert)
  public
    constructor Create; reintroduce;

    function GetPageName: string; override;
    function GetFrameClass: TCustomFrameClass; override;
  end;

{$IFDEF UNITVERSIONING}
const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL: https://jcl.svn.sourceforge.net/svnroot/jcl/tags/JCL-2.4-Build4571/jcl/experts/common/JclOtaUnitVersioning.pas $';
    Revision: '$Revision: 3703 $';
    Date: '$Date: 2012-01-23 21:45:41 +0100 (Mon, 23 Jan 2012) $';
    LogPath: 'JCL\experts\common';
    Extra: '';
    Data: nil
    );
{$ENDIF UNITVERSIONING}

implementation

uses
  JclOtaConsts, JclOtaResources,
  JclOtaUnitVersioningSheet;

//=== { TJclOTAUnitVersioningExpert } ========================================

constructor TJclOTAUnitVersioningExpert.Create;
begin
  inherited Create(JclUnitVersioningExpertName);
end;

function TJclOTAUnitVersioningExpert.GetFrameClass: TCustomFrameClass;
begin
  Result := TJclOtaUnitVersioningFrame;
end;

function TJclOTAUnitVersioningExpert.GetPageName: string;
begin
  Result := LoadResString(@RsUnitVersioningSheet);
end;

{$IFDEF UNITVERSIONING}
initialization
  RegisterUnitVersion(HInstance, UnitVersioning);

finalization
  UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}

end.
