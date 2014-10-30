unit UnitScriptsMath;

interface

uses        
  Math, SysUtils, UnitScripts, uScript;

  type
    Tfunc = set of (Fplus,Fminus,Fmultiply,Fdivide,Fnone,Fpower,F_AND,F_OR,F_XOR,F_RAVNO,F_BOLSHE,F_MENSHE);
    TZnak = set of (Zravno,ZBolhe,Zmenhe,ZBolheRavno,ZMenheRavno,ZneRavno);
    Tresult = record
    Nofunction : integer;
    Typefunction : Tfunc;
  end;
  type
    TFindFuncion = record
    Name : String;
    FirstChar : integer;
    Width : integer;
    firstcharname : integer;
  end;

  const
   znaki : set of AnsiChar = ['+','-','*','/','^','~','|','&','>','<','='];
   logicznaki : set of AnsiChar = ['>','<','='];
   BukviF : set of AnsiChar = ['A'..'Z','a'..'z'];
   zifri : set of AnsiChar = ['0'..'9'];

   Function StringToFloatScript(const fstr : string; const Script : TScript) : real;
   Function findexpression(const str : String):boolean;

implementation

Function FindpreviosChar(s : string; i : integer; no : integer): char;
var j:integer;
begin
 result:=#0;
 For j:=i downto 1 do
 If s[j]<>' ' then begin
 dec(no);
 If no<=0 then
 begin
 result:=s[j];
 break;
 end;
 end;
end;

Function FindNextCharNo(s : string; i : integer; var no : integer): char;
var j:integer;
begin
 result:=#0;
 For j:=i to length(s) do
 If s[j]<>' ' then begin
 result:=s[j];
 no:=j;
 break;
 end;
end;

Function DeleteProbeli(S : String) : String;
 var i:integer;
begin
 for i:=length(s) downto 1 do
 If s[i]=' ' then delete(s,i,1);
 Result:=s;
end;

function Upcaseall(s : string):string;
var i : integer;
begin
result:=s;
for i:=1 to length(s) do
result[i]:=Upcase(result[i]);
end;

function LoadFloat(str: string; Script : TScript): real;
var
  s : string;
  minusi,i : integer;
  Value : Extended;
begin
 minusi:=0;
 If str='' then begin result:=0; exit; end;
 s:=str;
 If s[1]='(' then
 begin
  For i:=1 to length(s) div 2 do
  If (s[i]='-') then inc(minusi);
  For i:=length(s) div 2 downto 1 do
  If (s[i]='-') then delete(s,i,1);
 end;
 result:=0;
 If s='' then exit;
 Repeat
  If s[1]='(' then
  begin
   delete(s,length(s),1);
   delete(s,1,1);
   If s='' then exit;
  end;
 until s[1]<>'(';
 if IsVariable(s) then
   Value := GetNamedValueFloat(Script, s)
 else
   Value := StrToFloatDef(s, 0);

 If not odd(minusi) then result:=Value else result:=-Value;
end;

function findnextf(strfunction:string):Tresult;
var i:integer;
find : boolean;
begin
find:=false;
result.nofunction:=-1;
result.typefunction:=[fnone];

If not find then
for i:=1 to length(strfunction) do
If strfunction[i]='=' then begin find:=true; result.nofunction:=i; result.typefunction:=[F_RAVNO]; break; end;
If not find then
for i:=1 to length(strfunction) do
If strfunction[i]='>' then begin find:=true; result.nofunction:=i; result.typefunction:=[F_BOLSHE]; break; end;
If not find then
for i:=1 to length(strfunction) do
If strfunction[i]='<' then begin find:=true; result.nofunction:=i; result.typefunction:=[F_MENSHE]; break; end;


If not find then
for i:=1 to length(strfunction) do
If strfunction[i]='~' then begin find:=true; result.nofunction:=i; result.typefunction:=[F_XOR]; break; end;
If not find then
for i:=1 to length(strfunction) do
If strfunction[i]='&' then begin find:=true; result.nofunction:=i; result.typefunction:=[F_AND]; break; end;
If not find then
for i:=1 to length(strfunction) do
If strfunction[i]='|' then begin find:=true; result.nofunction:=i; result.typefunction:=[F_OR]; break; end;


If not find then
for i:=1 to length(strfunction) do
If strfunction[i]='^' then begin find:=true; result.nofunction:=i; result.typefunction:=[Fpower]; break; end;
If not find then
for i:=1 to length(strfunction) do
If strfunction[i]='*' then begin find:=true; result.nofunction:=i; result.typefunction:=[Fmultiply]; break; end;
If not find then
for i:=1 to length(strfunction) do
If strfunction[i]='/' then begin find:=true; result.nofunction:=i; result.typefunction:=[Fdivide]; break; end;
If not find then
for i:=1 to length(strfunction) do
If strfunction[i]='-' then If (i<>1) and (strfunction[i-1]<>'(') and (strfunction[i-1]<>'E') then begin find:=true; result.nofunction:=i; result.typefunction:=[Fminus]; break; end;
If not find then
for i:=1 to length(strfunction) do
If strfunction[i]='+' then begin result.nofunction:=i; result.typefunction:=[Fplus]; break; end;
end;

function findnextr(nofunction:integer;s:string):integer;
var i:integer;
begin
result:=length(s)+1;
for i:=nofunction+1 to length(s) do
begin
If (s[i]='+') or (s[i]='*') or (s[i]='/') or (s[i]='^') or (s[i]='~') or (s[i]='&') or (s[i]='|') or (s[i]='=') or (s[i]='>') or (s[i]='<') then begin result:=i; break; end;
If (s[i]='-') and (s[i-1]<>'(') and (s[i-1]<>'E') then begin result:=i; break; end;
end;
end;

function findnextl(nofunction:integer;s:string):integer;
var i:integer;
begin
result:=0;
for i:=nofunction-1 downto 1 do
begin
If (s[i]='+') or (s[i]='*') or (s[i]='/') or (s[i]='^') or (s[i]='~') or (s[i]='&') or (s[i]='|') or (s[i]='=') or (s[i]='>') or (s[i]='<') then  begin result:=i; break; end;
If (s[i]='-') and (s[i-1]<>'(') and (s[i-1]<>'E') then begin result:=i; break; end;
end;
end;

Function Replacefunctionstoresult(const str:string; const Script : TScript):string;
var i,j,ns,sc,nv1,z,y,endif:integer;
s,s1,sv1,sv2,ysl1,ysl2:string;
znak: TZnak;
r,temp,temp_,temp__,sr1,sr2:real;
none:boolean;
noneNo:integer;
begin
noneno:=1;
s:=str;
repeat
none:=true;
for i:=noneNo to length(s) do
begin
ns:=0;
If (s[i]='A') then if (s[i+1]='b') and (s[i+2]='s') and (s[i+3]='(') then
         begin
         sc:=1;
         noneno:=i+1;
         none:=false;
         for j:=i+4 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then
         begin
         sc:=sc-1;
         If sc=0 then begin
         ns:=j;
         break;
         end;
         end;
         end;
         s1:=copy(s,i+4,ns-i-4);
         r:=abs(LoadFloat(s1,Script));
         s1:='('+floattostr(r)+')';
         delete(s,i,ns-i+1);
         insert(s1,s,i);
         end;
         
If (s[i]='R') then if (s[i+1]='a') and (s[i+2]='d') and (s[i+3]='(') then
         begin
         sc:=1;
         noneno:=i+1;
         none:=false;
         for j:=i+4 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then
         begin
         sc:=sc-1;
         If sc=0 then begin
         ns:=j;
         break;
         end;
         end;
         end;
         s1:=copy(s,i+4,ns-i-4);
         r:=pi*2*(LoadFloat(s1,Script))/360;
         s1:='('+floattostr(r)+')';
         delete(s,i,ns-i+1);
         insert(s1,s,i);
         end;

If (s[i]='S') then if (s[i+1]='q') and (s[i+2]='r') and (s[i+3]='t') and (s[i+4]='(') then
         begin
         sc:=1;
         noneno:=i+1;
         none:=false;
         for j:=i+5 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then
         begin
         sc:=sc-1;
         If sc=0 then begin
         ns:=j;
         break;
         end;
         end;
         end;
         s1:=copy(s,i+5,ns-i-5);
         temp:=LoadFloat(s1,Script);
         If temp>=0 then
         r:=sqrt(temp) else raise Ematherror.Create('Invalid Floating Operator. Exception On SQRT needs >= 0');
         s1:='('+floattostr(r)+')';
         delete(s,i,ns-i+1);
         insert(s1,s,i);
         end;

If (s[i]='L') then if (s[i+1]='o') and (s[i+2]='g') and (s[i+3]='N') and (s[i+4]='(') then
         begin
         sc:=0;
         noneno:=i+1;
         nv1:=0;
         none:=false;
         For j:=i+5 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then sc:=sc-1;
         If (s[j]=';') and (sc=0) then
         begin
         nv1:=j;
         break;
         end;
         end;
         sc:=1;
         sv1:=copy(s,i+5,nv1-i-5);
         sv1:=floattostr(StringToFloatScript(sv1,Script));
         for j:=nv1 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then
         begin
         sc:=sc-1;
         If sc=0 then begin
         ns:=j;
         break;
         end;
         end;
         end;
         s1:=copy(s,nv1+1,ns-nv1-1);
         s1:=Floattostr(StringToFloatScript(s1,Script));
         temp:=LoadFloat(s1,Script);
         temp_:=LoadFloat(sv1,Script);
         r:=0;
         If (temp>0) and (temp_>0) and (temp_<>1) then
         r:=logn(temp,temp_) else begin
         If temp<0 then raise Ematherror.Create('Invalid Floating Operator. Base on LOGN needs >0');
         If temp_<0 then raise Ematherror.Create('Invalid Floating Operator. Value on LOGN needs >0');
         If temp_=0 then raise Ematherror.Create('Invalid Floating Operator. Value on LOGN needs <>0');
         end;
         s1:='('+floattostr(r)+')';
         delete(s,i,ns-i+1);
         insert(s1,s,i);
         end;

If (s[i]='C') then if (s[i+1]='c') and (s[i+2]='s') and (s[i+3]='(') then
         begin
         sc:=1;
         noneno:=i+1;
         none:=false;
         for j:=i+4 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then
         begin
         sc:=sc-1;
         If sc=0 then begin
         ns:=j;
         break;
         end;
         end;
         end;
         s1:=copy(s,i+4,ns-i-4);
         r:=cos(LoadFloat(s1,Script));
         s1:='('+floattostr(r)+')';
         delete(s,i,ns-i+1);
         insert(s1,s,i);
         end;

If (s[i]='R') then if (s[i+1]='o') and (s[i+2]='u') and (s[i+3]='n') and (s[i+4]='d') and (s[i+5]='(') then
         begin
         sc:=1;
         noneno:=i+1;
         none:=false;
         for j:=i+6 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then
         begin
         sc:=sc-1;
         If sc=0 then begin
         ns:=j;
         break;
         end;
         end;
         end;
         s1:=copy(s,i+6,ns-i-6);
         r:=floor(LoadFloat(s1,Script));
         s1:='('+floattostr(r)+')';
         delete(s,i,ns-i+1);
         insert(s1,s,i);
         end;

If (s[i]='S') then if (s[i+1]='i') and (s[i+2]='n') and (s[i+3]='(') then
         begin
         sc:=1;
         noneno:=i+1;
         none:=false;
         for j:=i+4 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then
         begin
         sc:=sc-1;
         If sc=0 then begin
         ns:=j;
         break;
         end;
         end;
         end;
         s1:=copy(s,i+4,ns-i-4);
         r:=sin(LoadFloat(s1,Script));
         s1:='('+floattostr(r)+')';
         delete(s,i,ns-i+1);
         insert(s1,s,i);
         end;
if i>1 then
If (s[i-1]<>'o') and (s[i]='T') and (s[i+1]='a') and (s[i+2]='n') and (s[i+3]='(') then
         begin
         sc:=1;
         noneno:=i+1;
         none:=false;
         for j:=i+4 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then
         begin
         sc:=sc-1;
         If sc=0 then begin
         ns:=j;
         break;
         end;
         end;
         end;
         s1:=copy(s,i+4,ns-i-4);
         temp:=LoadFloat(s1,Script);
         If cos(temp)<>0 then
         r:=tan(temp) else raise Ematherror.Create('Invalid Floating Operator. TAN needs value <> pi/2 +p*n, n <- Z');
         s1:='('+floattostr(r)+')';
         delete(s,i,ns-i+1);
         insert(s1,s,i);
         end;

If (s[i]='C') then if (s[i+1]='o') and (s[i+2]='T') and (s[i+3]='a') and (s[i+4]='n') and (s[i+5]='(') then
         begin
         sc:=1;
         noneno:=i+1;
         none:=false;
         for j:=i+6 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then
         begin
         sc:=sc-1;
         If sc=0 then begin
         ns:=j;
         break;
         end;
         end;
         end;
         s1:=copy(s,i+6,ns-i-6);
         temp:=LoadFloat(s1,Script);
         If sin(temp)<>0 then
         r:=cotan(temp) else raise Ematherror.Create('Invalid Floating Operator. COTAN needs value <> p*n, n <- Z');
         s1:='('+floattostr(r)+')';
         delete(s,i,ns-i+1);
         insert(s1,s,i);
         end;

If (s[i]='A') then if (s[i+1]='r') and (s[i+2]='c') and (s[i+3]='S') and (s[i+4]='i') and (s[i+5]='n') and (s[i+6]='(') then
         begin
         sc:=1;
         noneno:=i+1;
         none:=false;
         for j:=i+7 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then
         begin
         sc:=sc-1;
         If sc=0 then begin
         ns:=j;
         break;
         end;
         end;
         end;
         s1:=copy(s,i+7,ns-i-7);
         temp:=LoadFloat(s1,Script);
         If abs(temp)<=1 then
         r:=arcsin(temp) else raise Ematherror.Create('Invalid Floating Operator. ARCSIN needs value <- [-1;1]');
         s1:='('+floattostr(r)+')';
         delete(s,i,ns-i+1);
         insert(s1,s,i);
         end;

If (s[i]='A') then if (s[i+1]='r') and (s[i+2]='c') and (s[i+3]='C') and (s[i+4]='o') and (s[i+5]='s') and (s[i+6]='(') then
         begin
         sc:=1;
         noneno:=i+1;
         none:=false;
         for j:=i+7 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then
         begin
         sc:=sc-1;
         If sc=0 then begin
         ns:=j;
         break;
         end;
         end;
         end;
         s1:=copy(s,i+7,ns-i-7);
         temp:=LoadFloat(s1,Script);
         If abs(temp)<=1 then
         r:=arccos(temp) else raise Ematherror.Create('Invalid Floating Operator. ARCCOS needs value <- [-1;1]');
         s1:='('+floattostr(r)+')';
         delete(s,i,ns-i+1);
         insert(s1,s,i);
         end;

If (s[i]='A') then if (s[i+1]='r') and (s[i+2]='c') and (s[i+3]='T') and (s[i+4]='a') and (s[i+5]='n') and (s[i+6]='(') then
         begin
         sc:=1;
         noneno:=i+1;
         none:=false;
         for j:=i+7 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then
         begin
         sc:=sc-1;
         If sc=0 then begin
         ns:=j;
         break;
         end;
         end;
         end;
         s1:=copy(s,i+7,ns-i-7);
         r:=arctan(LoadFloat(s1,Script));
         s1:='('+floattostr(r)+')';
         delete(s,i,ns-i+1);
         insert(s1,s,i);
         end;

If (s[i]='A') then if (s[i+1]='r') and (s[i+2]='c') and (s[i+3]='C') and (s[i+4]='c') and (s[i+5]='t') and (s[i+6]='a') and (s[i+7]='n') and (s[i+8]='(') then
         begin
         sc:=1;
         noneno:=i+1;
         none:=false;
         for j:=i+9 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then
         begin
         sc:=sc-1;
         If sc=0 then begin
         ns:=j;
         break;
         end;
         end;
         end;
         s1:=copy(s,i+9,ns-i-9);
         r:=-arctan(LoadFloat(s1,Script))+pi/2;
         s1:='('+floattostr(r)+')';
         delete(s,i,ns-i+1);
         insert(s1,s,i);
         end;

If (s[i]='E') then if (s[i+1]='e') and (s[i+2]='p') and (s[i+3]='(') then
         begin
         sc:=1;
         noneno:=i+1;
         none:=false;
         for j:=i+4 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then
         begin
         sc:=sc-1;
         If sc=0 then begin
         ns:=j;
         break;
         end;
         end;
         end;
         s1:=copy(s,i+4,ns-i-4);
         r:=exp(LoadFloat(s1,Script));
         s1:='('+floattostr(r)+')';
         delete(s,i,ns-i+1);
         insert(s1,s,i);
         end;

If (s[i]='L') then if (s[i+1]='n') and (s[i+2]='(') then
         begin
         sc:=1;
         none:=false;
         noneno:=i+1;
         for j:=i+3 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then
         begin
         sc:=sc-1;
         If sc=0 then begin
         ns:=j;
         break;
         end;
         end;
         end;
         s1:=copy(s,i+3,ns-i-3);
         temp:=LoadFloat(s1,Script);
         If temp>0 then
         r:=ln(temp) else raise
         Ematherror.Create('Invalid Floating Operator. LN needs value >0');
         s1:='('+floattostr(r)+')';
         delete(s,i,ns-i+1);
         insert(s1,s,i);
         end;

If (s[i]='L') then if (s[i+1]='g') and (s[i+2]='(') then
         begin
         sc:=1;
         none:=false;
         noneno:=i+1;
         for j:=i+3 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then
         begin
         sc:=sc-1;
         If sc=0 then begin
         ns:=j;
         break;
         end;
         end;
         end;
         s1:=copy(s,i+3,ns-i-3);
         temp:=LoadFloat(s1,Script);
         If temp>0 then
         r:=ln(temp)/ln(10) else raise Ematherror.Create('Invalid Floating Operator. LG needs value >0');
         s1:='('+floattostr(r)+')';
         delete(s,i,ns-i+1);
         insert(s1,s,i);
         end;

If (s[i]='I') then if (s[i+1]='F') and (s[i+2]='(') then
         begin
         sc:=0;
         noneno:=i+1;
         nv1:=0;
         none:=false;
         endif:=length(s);
         for j:=i+2 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then sc:=sc-1;
         If sc=0 then
         begin
          endif:=j;
          break;
         end;
         end;
         sc:=0;
         For j:=i+3 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then sc:=sc-1;
         If (s[j]=';') and (sc=0) then
         begin
         nv1:=j;
         break;
         end;
         end;
         sc:=1;
         sv1:=copy(s,i+3,nv1-i-3);
         for j:=nv1+1 to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then sc:=sc-1;
         If (s[j]=';') and (sc=1) then
         begin
         ns:=j;
         break;
         end;
         end;
         s1:=copy(s,nv1+1,ns-nv1-1);
         
         for j:=ns to length(s) do
         begin
         If s[j]='(' then sc:=sc+1;
         If s[j]=')' then
         begin
         sc:=sc-1;
         If sc=0 then begin
         nv1:=j;
         break;
         end;
         end;
         end;
         sv2:=copy(s,ns+1,nv1-ns-1);
         y:=0;
         for z:=1 to length(sv1) do
         begin
         If (sv1[z]='>') and (sv1[z+1]<>'=') then
         begin
         znak:=[ZBolhe];
         y:=z;
         break;
         end;
         If (sv1[z]='<') and (sv1[z+1]<>'=') and (sv1[z+1]<>'>') then
         begin
         znak:=[ZMenhe];
         y:=z;
         break;
         end;
         If sv1[z]='=' then
         begin
         znak:=[ZRavno];
         y:=z;
         break;
         end;
         If (sv1[z]='>') and (sv1[z+1]='=') then
         begin
         znak:=[ZBolheRavno];
         y:=z;
         break;
         end;
         If (sv1[z]='<') and (sv1[z+1]='=') then
         begin
         znak:=[ZMenheRavno];
         y:=z;
         break;
         end;
         If (sv1[z]='<') and (sv1[z+1]='>') then
         begin
         znak:=[ZNeRavno];
         y:=z;
         break;
         end;
         end;
         If (znak=[Zbolhe]) or (znak=[ZMenhe]) or (znak=[ZRavno]) then
         begin
         ysl1:=copy(sv1,1,y-1);
         ysl2:=copy(sv1,y+1,length(sv1)-y);
         end else begin
         ysl1:=copy(sv1,1,y-1);
         ysl2:=copy(sv1,y+2,length(sv1)-y-1);
         end;
         znak:=znak;
         temp:=0;
         If znak=[ZRavno] then
         begin                   
         If StringToFloatScript(ysl1,Script)=StringToFloatScript(ysl2,Script) then temp:=StringToFloatScript(s1,Script) else temp:=StringToFloatScript(sv2,Script);
         end;
         If znak=[ZNeRavno] then
         begin
         If StringToFloatScript(ysl1,Script)<>StringToFloatScript(ysl2,Script) then temp:=StringToFloatScript(s1,Script) else temp:=StringToFloatScript(sv2,Script);
         end;
         If znak=[ZBolhe] then
         begin
         If StringToFloatScript(ysl1,Script)>StringToFloatScript(ysl2,Script) then temp:=StringToFloatScript(s1,Script) else temp:=StringToFloatScript(sv2,Script);
         end;
         If znak=[ZMenhe] then
         begin
         If StringToFloatScript(ysl1,Script)<StringToFloatScript(ysl2,Script) then temp:=StringToFloatScript(s1,Script) else temp:=StringToFloatScript(sv2,Script);
         end;
         If znak=[ZMenheRavno] then
         begin
         If StringToFloatScript(ysl1,Script)<=StringToFloatScript(ysl2,Script) then temp:=StringToFloatScript(s1,Script) else temp:=StringToFloatScript(sv2,Script);
         end;
         If znak=[ZBolheRavno] then
         begin
         If StringToFloatScript(ysl1,Script)>=StringToFloatScript(ysl2,Script) then temp:=StringToFloatScript(s1,Script) else temp:=StringToFloatScript(sv2,Script);
         end;
         r:=temp;
         s1:='('+floattostr(r)+')';
         delete(s,i,endif-i+1);
         insert(s1,s,i);
         break;
         end;
end;
Until none;
result:=s;
end;

Function StringToFloatScript(const fstr : string; const Script : TScript) : real;
var s,s1,s2,s3,s4:string;
breakzikl : boolean;
plus,i,a,b,sc,j:integer;
lr:real;
f : Tfunc;
begin
result:=0;
s:=fstr;
If s='' then exit;
If s[1]<>'-' then
s:='0+'+s else s:='0'+s;
s:=DeleteProbeli(s);

 Repeat
  breakzikl:=true;
  for i:=1 to length(s) do
  If (s[i]='(') then
  If findprevioschar(s,i-1,1)<>'F' then
  if findprevioschar(s,i-1,2)<>'G' then
  begin
   sc:=0;
   for j:=i to length(s) do
   begin
    If s[j]='(' then sc:=sc+1;
    If s[j]=')' then
    begin
     sc:=sc-1;
     If sc=0 then
     If findexpression(copy(s,i+1,j-i-1))=true then
     begin
      s4:=copy(s,i+1,j-i-1);
      try
       s4:=floattostr(StringToFloatScript(s4,Script));
       delete(s,i+1,j-i-1);
       insert(s4,s,i+1);
       breakzikl:=false;
       break;
       except
      end;
     end;
    end;
   end;
  end;
 Until breakzikl=true;

s:=replacefunctionstoresult(s,Script);
 try
repeat
plus:=findnextf(s).Nofunction;
f:=findnextf(s).Typefunction;
s1:=copy(s,findnextl(plus,s)+1,plus-findnextl(plus,s)-1);
s2:=copy(s,plus+1,findnextr(plus,s)-plus-1);
a:=findnextl(plus,s);
b:=findnextr(plus,s);
system.delete(s,a+1,b-a-1);
lr:=0;
If f=[fnone] then break;
If f=[Fpower] then lr:=power(LoadFloat(s1,Script),LoadFloat(s2,Script));
If f=[fplus] then lr:=LoadFloat(s1,Script)+LoadFloat(s2,Script);
If f=[fminus] then lr:=LoadFloat(s1,Script)-LoadFloat(s2,Script);
If f=[fdivide] then
begin
If LoadFloat(s2,Script)<>0 then
lr:=LoadFloat(s1,Script)/LoadFloat(s2,Script) else lr:=MaxExtended//raise EMathError.create('Error by devisiot on zerro');//lr:=MaxExtended;
end;
If f=[fmultiply] then lr:=LoadFloat(s1,Script)*LoadFloat(s2,Script);

If f=[F_OR] then
begin
 if (LoadFloat(s1,Script)<>0) or (LoadFloat(s2,Script)<>0) then lr:=1 else lr:=0;
end;

If f=[F_AND] then
begin
 if (LoadFloat(s1,Script)<>0) and (LoadFloat(s2,Script)<>0) then lr:=1 else lr:=0;
end;

If f=[F_XOR] then
begin
 if (LoadFloat(s1,Script)<>0) xor (LoadFloat(s2,Script)<>0) then lr:=1 else lr:=0;
end;

If f=[F_BOLSHE] then
begin
 if LoadFloat(s1,Script) > LoadFloat(s2,Script) then lr:=1 else lr:=0;
end;

If f=[F_MENSHE] then
begin
 if LoadFloat(s1,Script) < LoadFloat(s2,Script) then lr:=1 else lr:=0;
end;

If f=[F_RAVNO] then
begin
 if s1 = s2 then lr:=1 else lr:=0;
end;

If lr>=0 then s3:=floattostr(lr) else s3:='('+floattostr(lr)+')';
insert(s3,s,a+1);
until findnextf(s).Typefunction=[fnone];
  except
  raise EMathError.create('Error');
  end;

result:=LoadFloat(s,Script);
end;

Function findexpression(const str : String):boolean;
var i,sc:integer;
pass:boolean;
begin
result:=false;
pass:=true;
sc:=0;
for i:=1 to length(str) do begin
If (str[i]='(') then sc:=sc+1;
If (str[i]=')') then sc:=sc-1;
If sc<0 then pass:=false;
end;
for i:=length(str) downto 1 do begin
If (str[i]=')') then sc:=sc+1;
If (str[i]='(') then sc:=sc-1;
If sc<0 then pass:=false;
end;
If pass then
for i:=1 to length(str) do begin
If (((str[i]='+') or (str[i]='-')) and (i<>1) and (str[i-1]<>'E')) or (str[i]='/') or (str[i]='*') or (str[i]='^') or (str[i]='~') or (str[i]='|') or (str[i]='&') or (str[i]='>') or (str[i]='<') or (str[i]='=') or (str[i]='S') or (str[i]='N') or ((str[i]='E') and (str[i+1]='X')) or (str[i]='I') or (str[i]='R') then
begin
result:=true;
break;
end;
end;
end;

end.
