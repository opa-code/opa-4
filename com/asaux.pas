{little helpers needed for all my programs}

unit asaux;

//{$MODE Delphi}

interface

uses sysutils, Classes, LCLIntf, LCLType, Graphics, stdctrls, Dialogs, Math;

//strings
function VarPos(vn, s: string): integer;
function VarReplace(input, s1, s2: string): string;
function Replace(input, s1, s2: string): string;
function FillB (s: string; n, fb:integer): string;
function LastBlank (s: string; nf: integer): integer;
function TB (s: string): string;
function UB (s: string):string;
function USnumber(nums:string):string;
function FtoS (x: double; w, d: integer): string;
function FtoSv (x: double; w, d: integer): string;
function FtoSe (x: double; w, d: integer): string;

//graphics
function insideRect (x,y: integer; r: TRect):Boolean;
function dimcol(col, bcol: TColor; fac:real): TColor;
function colorCircle(xin:real): TColor;

//GUI components
function TEKeyVal(te: TEdit;  var Key: Char; var value: Real; w,d: integer): boolean;
function TEReadVal(te: TEdit; var value: Real; w,d: integer): boolean;

// sort algorithm
procedure indexx(arrin: array of real; var indx: array of integer);

implementation

function VarPos(vn, s: string): integer;
{find a variable name in an expression: works like Pos, but checks if operator signs
are before or after vn (or if these are first/last chars of s), otherwise problems if we
have 2 variables names x and x1 for example}
var
  ipo: integer;
begin
  ipo:=Pos(vn,s);
  if ipo > 0 then begin
    if ipo > 1 then if not (s[ipo-1] in [' ','+','-','*','/','(']) then ipo:=0;
    if ipo+length(vn)-1 < length(s) then if not (s[ipo+length(vn)] in [' ','+','-','*','/',')']) then ipo:=0;
  end;
  VarPos:=ipo;
end;

function VarReplace(input, s1, s2: string): string;
// replace variable name substring s1 by substring s2 in string input
var
  inp, out: string;
  i, n: integer;
begin
  inp:=input;
  out:='';
  n:=Length(s1);
  i:=0;
  repeat
    i:=VarPos(s1,inp);
    if i>0 then begin
      out:=out+Copy(inp,1,i-1)+s2;
      inp:=Copy(inp,i+n,1000);
    end;
  until (i=0);
  out:=out+inp;
  VarReplace:=out;
end;

function Replace(input, s1, s2: string): string;
// replace substring s1 by substring s2 in string input
var
  inp, out: string;
  i, n: integer;
begin
  inp:=input;
  out:='';
  n:=Length(s1);
  i:=0;
  repeat
    i:=Pos(s1,inp);
    if i>0 then begin
      out:=out+Copy(inp,1,i-1)+s2;
      inp:=Copy(inp,i+n,1000);
    end;
  until (i=0);
  out:=out+inp;
  Replace:=out;
end;

function FillB (s: string; n, fb: integer): string;
// fill up string with blanks or truncate if too long
var
  x, b: string;
  k: integer;
begin
  x:=Copy(s,1,n);
  b:='';  for k:=length(s)+1 to n do b:=b+' ';
  if fb=0 then FillB:=x+b else FillB:=b+x;
end;

function LastBlank (s: string; nf: integer): integer;
// return position of LAST blank in string s <= position nf (if nf=0 use full s)
// return 0 if no blank found
var
  t: string;
  ibl, i: integer;
begin
  if nf>0 then t:=copy(s,1,nf) else t:=s;
  i:=Pos(' ',t);
  ibl:=i;
  while i>0 do begin
    t:=Copy(t,i+1);
    i:=Pos(' ',t);
    Inc(ibl,i);
  end;
  LastBlank:=ibl;
end;

function TB (s: string): string;
{removes trailing and preceding blanks}
var
  i: integer;
  a: string;
begin
//??? crash here for empty strings ?
  i:=Length(s);
  if i>0 then begin
    while (s[i]=' ') and (i>0) do Dec(i);
    a:=Copy(s,1,i);
    while Pos(' ',a)=1 do a:=Copy(a,2,length(a));
    TB:=a;
  end else TB:='';
end;

function UB (s: string):string;
begin
  UB:=UpperCase(TB(s));
end;

//convert numbers to US format by replacing , by .
function USnumber(nums:string):string;
begin
  USnumber:=stringreplace(nums,',','.',[]);
end;

// format for values where magnitud is known -> fixed decimals
function FtoS(x: double; w, d: integer): string;
var
  s: string;
begin
  if d=0 then s:=InttoStr(Round(x)) else begin
    if w<0 then s:=  FloatToStrF(x,ffexponent, -w,d)
    else s:=FloatToStrF(x, fffixed, w, d);
  end;
//??  if x>0 then s:=s+' ';
  FtoS:=USnumber(s);
end;

// format for values where the magnitude is not known initially
function FtoSv (x: double; w, d: integer): string;
var
  s: string;
begin
  if d=0 then s:=InttoStr(Round(x)) else begin
    if w<0 then s:=FloatToStrF(x,ffexponent, -w,d)
    else   s:=FloattoStrF(x, ffgeneral,w,3);
  end;
  FtoSv:=USnumber(s);
end;

// format switching to exponential beyond some magnitude (1e6)
function FtoSe (x: double; w, d: integer): string;
const
  lim=5;
var
  s: string;
begin
  if d=0 then s:=InttoStr(Round(x)) else begin
    if (abs(x)>1e-20) then
      if (abs(Log10(abs(x)))>lim) then s:=FloatToStrF(x,ffexponent,6,2)
      else   s:=FloattoStrF(x, fffixed,w,d)
    else   s:=FloattoStrF(x, fffixed,w,d);
  end;
  FtoSe:=USnumber(s);
end;


//detect if a given point is inside a rectangle
function insideRect(x,y: integer; r: TRect):Boolean;
begin
  insideRect:=((r.left-x)*(r.right-x)<0) and ((r.top-y)*(r.bottom-y)<0)
end;


function dimcol(col, bcol: TColor; fac:real): TColor;
// dim a color by factor
const
  c0=$01000000;
  b0=$00010000;
  g0=$00000100;
var
  r, g, b, br, bg, bb: Byte;

procedure rgb(cin:TColor; var cr,cg,cb: Byte);
var
  c: TColor;
begin
  c :=cin mod c0;
  cb:=c div b0;
  c :=c mod b0;
  cg:=c div g0;
  cr:=c mod g0;
end;

begin
  rgb( col,  r,  g,  b);
  rgb(bcol, br, bg, bb);
{  c:=col mod c0;
  b:=round((c div b0)*fac);
  c:=c mod b0;
  g:=round((c div g0)*fac);
  r:=round((c mod g0)*fac);
}
  dimcol:=(col div c0)
           + b0*round(b*fac+(1-fac)*bb)
           + g0*round(g*fac+(1-fac)*bg)
           +    round(r*fac+(1-fac)*br);
end;

function ColorCircle(xin:real): TColor;
// returns a color of brightness FF from color cirlce
// iphi=0: red, iphi=1/3: blue, iphi=2/3 or -1/3: green
var
  dx: real;
  ix, bc1, bc2: byte;
  c1,c2: TColor;

begin
  ix:=trunc(3*xin);
  if xin<0 then ix:=0;
  if xin>1 then ix:=0;  //x=0,1,2
  case ix of
    0: begin c1:=$00000011; c2:=$00001100; end;
    1: begin c1:=$00001100; c2:=$00110000; end;
    2: begin c1:=$00110000; c2:=$00000011; end;
  end;
  dx:=3*xin-ix; {0..1}
  bc1:=Round(255*(1-dx)); bc2:=Round(255*(dx));
  ColorCircle:=c1*bc1+c2*bc2;
end;







function TEKeyVal(te: TEdit;  var Key: Char; var value: Real; w,d: integer): boolean;
var flag: boolean;
begin
  flag:=false;
//  flag:=true;
  if key=',' then key:='.';
  if key=#13 then key:=#0;  {beep suppression}
  if key=#0 then flag:=TEReadVal(te, value, w, d);{return key terminates input}
  TEKeyVal:= flag;
end;

function TEReadVal(te: TEdit; var value: Real; w,d: integer): boolean;
var
  x: Real;
  errcode: integer;
  s: String;
begin
  with te do begin
    if enabled then begin
      s:=text;
{$R-}
      Val(s,x,errcode);
{$R+}
      if errcode=0 then begin
        value:=x;
        s:=  FtoSv(x,w,d);
        text:=s;
      end else begin
        MessageDlg('Invalid numeric format: '+s,mtError, [mbOK],0);
        setfocus;
      end;
    end else errcode:=0;
  end;
  TEReadVal:= errcode=0;
end;

procedure indexx(arrin: array of real; var indx: array of integer);
// indexed heapsort based on INDEXX from Numerical Recipes
// use dynamic arrays, starting at 0
// arrin: real array (is NOT sorted)
// indx: integer array of indices of arrin elements ordered by ascending value
LABEL 99;
VAR
   n,l,j,ir,indxt,i: integer;
   q: real;
BEGIN
   n:=high(arrin);
   FOR j := 0 TO n DO BEGIN
      indx[j] := j
   END;
   l := (n DIV 2) + 1;
   ir := n;
   WHILE true DO BEGIN
      IF (l > 0) THEN BEGIN
            l := l-1;
            indxt := indx[l];
            q := arrin[indxt]
      END ELSE BEGIN
         indxt := indx[ir];
         q := arrin[indxt];
         indx[ir] := indx[0];
         ir := ir-1;
         IF (ir = 0) THEN BEGIN
            indx[0] := indxt;
            GOTO 99
         END
      END;
      i := l;
      j := l+l+1;
      WHILE (j <= ir) DO BEGIN
         IF (j < ir) THEN BEGIN
             IF (arrin[indx[j]] < arrin[indx[j+1]]) THEN j := j+1
         END;
         IF (q < arrin[indx[j]]) THEN BEGIN
            indx[i] := indx[j];
            i := j;
            j := j+j+1
         END ELSE
            j := ir+1
      END;
      indx[i] := indxt
    END;
  99:
  END;


end.
