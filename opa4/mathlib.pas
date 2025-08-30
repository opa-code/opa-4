unit mathlib;

{$MODE Delphi}

{collection of mathematical functions}


INTERFACE


//uses Math;

const
  Powellncom_max=32;

type
  complex = record
    re, im: double;
  end;

  Vektor_2 = array[1..2] of real;
  Vektor_3 = array[1..3] of real;
  Vektor_4 = array[1..4] of real;
  Vektor_5 = array[1..5] of real;
  Index_5  = array[1..5] of integer;

  Matrixpt = ^Matrix_5;
  Matrix_5 = array[1..5] of Vektor_5;
  Matrix_4 = array[1..4] of Vektor_4;
  Matrix_2 = array[1..2] of Vektor_2;
  Matrix_3 = array[1..3] of Vektor_3;

  IArr_20  = array[1..20] of integer;

// test fuer funktion als parameter
//  Tmathintfunction= function (x,y: integer): integer;

// types and vars for Powell's Minimizer

  PowellMatrix  =  ARRAY [1..Powellncom_max,1..Powellncom_max] OF real;
  PowellVector  =  ARRAY [1..Powellncom_max] OF real;
  PowellFunction=  Function(var pk: PowellVector): real;

const
  VecNul2: Vektor_2 =(0,0);
  VecNul3: Vektor_3 =(0,0,0);
  VecNul4: Vektor_4 =(0,0,0,0);
  VecNul5: Vektor_5 =(0,0,0,0,0);
  MatNul2: Matrix_2 =((0,0),(0,0));
  MatNul3: Matrix_3 =((0,0,0),(0,0,0),(0,0,0));
  MatNul4: Matrix_4 =((0,0,0,0),(0,0,0,0),(0,0,0,0),(0,0,0,0));
  MatNul5: Matrix_5 =((0,0,0,0,0),(0,0,0,0,0),(0,0,0,0,0),(0,0,0,0,0),(0,0,0,0,0));
  MatUni2: Matrix_2 =((1,0),(0,1));
  MatUni3: Matrix_3 =((1,0,0),(0,1,0),(0,0,1));
  MatUni4: Matrix_4 =((1,0,0,0),(0,1,0,0),(0,0,1,0),(0,0,0,1));
  MatUni5: Matrix_5 =((1,0,0,0,0),(0,1,0,0,0),(0,0,1,0,0),(0,0,0,1,0),(0,0,0,0,1));

VAR

  PowellFNC: PowellFunction; //procedural variable

  Powellncom:                 integer;
  Powellpcom, Powellxicom:    PowellVector;
  PowellLinMinstep:           real;
  PowellBreak, PowellBreakMN: boolean;
  PowellStatus:               integer;

  powdiag: text;




//function SigNfromBeta(b, a: real): Matrix_2;

function gaussran (ncut: real): real;

function factorial(n:integer): integer;
//function combination(n,k: integer): double;

function c_mir(a: complex): complex;
function c_add(a,b: complex): complex;
function c_sub(a,b: complex): complex;
function c_abs(a: complex): double;
function c_ang(a: complex): double;
function c_exp(r, phi: double): complex;
function c_get(re, im: double): complex;
function c_mul(a, b: complex): complex;
function c_pow(a: complex; p: double): complex;
function c_sca(a: complex; s: double): complex;
function c_re(a: complex): double;
function c_im(a: complex): double;

function IntersectLineCircle(ax,ay,alfa, kx,ky,rad:real; var wp,wm:real):integer;
function IntersectLines(x0,y0,a0,x1,y1,a1: real; var xv, yv, dis0, dis1: real): boolean;

function RoundUp (x: double): double;
procedure SplitPow10 (var  x: double; var expo: Integer);
Function PowI        ( x : double; n: Integer ) : double;
Function PowR        ( x, p : double) : double;
Function CosH        ( x : double ) : double;
Function SinH        ( x : double ) : double;
Function Tan         ( x : double ) : double;
Function Sinxx       ( x : double ) : double;
Function ArcSin      ( x : double ) : double;
Function ArcCos      ( x : double ) : double;
Function myArcTan2   ( x, y : double) : double;
Function qArcTan2   ( x, y : double) : double;

Function Ctouschek_pol (x: double): double;
Function CTouschek     ( x: double)   : double;

Procedure Primefacs  ( za: Integer; var k: Integer; var f:Iarr_20);

PROCEDURE LUDCMP  (n: integer; VAR a: Matrix_5;
                   VAR indx: Index_5; VAR d: double; VAR Flag: Boolean);

PROCEDURE LUBKSB  (n: integer; VAR a: Matrix_5;
                   VAR indx: Index_5; VAR b: Vektor_5);

Procedure EulerAng (r: Matrix_3; var angy, angx, angs: double; altsol:boolean);

//Function MatNul2: Matrix_2;
//Function MatUni2: Matrix_2;
Function MatSet2 (m11, m12, m21, m22: double): Matrix_2;
Function MatSub2(a,b: Matrix_2): Matrix_2;
Function MatAdd2(a,b: Matrix_2): Matrix_2;
Function MatMul2 (A: matrix_2; B: matrix_2): Matrix_2;
Function MatDet2(a: Matrix_2): double;
Function MatSyc2(a: Matrix_2): Matrix_2;
Function MatSca2(s: double; a: Matrix_2): Matrix_2;
Function MatTra2(a: Matrix_2): double;
Function MatSig2 (m, a: Matrix_2): Matrix_2;
//Function MatStr2(m: Matrix_2): string;

//Function MatUni3: Matrix_3;
function RotMat3 (iax: integer; ang: real): Matrix_3;
Function MatInv3 (m: Matrix_3): Matrix_3;
Function MatMul3 (A: Matrix_3; B: Matrix_3): Matrix_3;
Function LinTra3 (a: Matrix_3; v: Vektor_3): Vektor_3;
Function VecAdd3 (a,b: Vektor_3): Vektor_3;
Function VecSub3 (a,b: Vektor_3): Vektor_3;
Function VecSet3(x,y,z: real): Vektor_3;
Function VecAbs3 (a: Vektor_3): real;
Function VecSca3 (a: Vektor_3; r: real): Vektor_3;
Function VecScp3 (a, b: Vektor_3): real;
Function VecPro3 (a, b: Vektor_3): Vektor_3;


//function MatUni4: Matrix_4;
Function MatSub4(a,b: Matrix_4): Matrix_4;
Function MatAdd4(a,b: Matrix_4): Matrix_4;
Function MatSca4(s: double; a: Matrix_4): Matrix_4;
Function MatMul4  (A: matrix_4; B: matrix_4): Matrix_4;
Function LinTra4 (a: Matrix_4; v: Vektor_4): Vektor_4;
Function MatTra4 (a: Matrix_4): Matrix_4;
Function MatInv4 (a: Matrix_4; var fail: boolean): Matrix_4;
Function VecAdd4 (a, b: Vektor_4): Vektor_4;
Function VecSub4 (a, b: Vektor_4): Vektor_4;
Function VecAbs4 (a: Vektor_4): double;

//Function MatNul5: Matrix_5;
//Function MatUni5: Matrix_5;
Function MatMul5   (A, B: matrix_5): Matrix_5;
Function MatMul5_S (A, B: matrix_5): Matrix_5;
Function MatTra5 (a: Matrix_5): Matrix_5;
function LinTra5  (m: matrix_5; v: vektor_5): Vektor_5;
function BlockDiag5 (m: matrix_5): boolean;
function InvRot5 (m:Matrix_5): Matrix_5;
function MatSig5_S(m, a: Matrix_5): Matrix_5;
Function LinTra5_S (m: matrix_5; a: vektor_5): Vektor_5;

Function LinTra244 (m,n: matrix_2; v: vektor_4): vektor_4;
Function MatCut42(M: Matrix_4; irow, icol: integer): matrix_2;
Function MatCut52(M: Matrix_5; irow, icol: integer): matrix_2;
Function MatCmp24 (m11,m12,m21,m22: Matrix_2): matrix_4;
Function MatCpy45 (m: Matrix_4): Matrix_5;
Procedure MatMV54 (m: Matrix_5; var t: Matrix_4; var v: Vektor_4);
Function MatCut54(M: Matrix_5): matrix_4;
Function LinTra54 (a: Matrix_5; v: Vektor_4; v5: double): Vektor_4;


Function Vektor45(e: Vektor_4; e5:real): Vektor_5;
Function Vektor54(e: Vektor_5): Vektor_4;

PROCEDURE svdcmp(VAR apack: array of real; //MxN
                   m,n: integer;
                 VAR w: array of real;     //N
                 VAR vpack: array of real);//NxN

PROCEDURE svbksb(VAR upack: array of real; //MxN
                 VAR w: array of real;     //N
                 VAR vpack: array of real; //NxN
                   m,n: integer;
                     b: array of real;     //M
                 VAR x: array of real);    //N

Procedure Poly_Fit (x, y: array of real; n: integer; var a: array of real);

// test only
//function mathtestproc (a,b: integer; afunc: Tmathintfunction): integer;

PROCEDURE powell(VAR p: PowellVector; n: integer; ftol: real; myfunc: Powellfunction);


IMPLEMENTATION

{consecutive calls provide a seris of gaussian distributed
 random numbers with stddev=1, mean=0, cutoff at n sigma.
 RandSeed has to be called first!}
function gaussran (ncut: real): real;
var
  x: real;
begin
  repeat
    x:=sqrt(-2*Ln(1-Random))*Cos(2*Pi*Random);
  until abs(x)<=ncut;
  gaussran:=x;
end;

function factorial(n:integer): integer;
var
  f,i:integer;
begin
 //(for multipoles)  f=(n-1)!
 f:=1;
 for i:=2 to n-1 do f:=f*i;
 factorial:=f;
end;


function c_mir(a: complex): complex;
// a+Ib -> b+Ia
var
  c: complex;
begin
  c.re:=a.im; c.im:=a.re;
  c_mir:=c;
end;

{--------------------------------------------------------------------}

function c_add(a,b: complex): complex;
// c = a + b
var
  c: complex;
begin
  c.re:=a.re+b.re;
  c.im:=a.im+b.im;
  c_add:=c;
end;

{-------------------------------------------------------------------}

function c_sub(a,b: complex): complex;
// c = a - b
var
  c: complex;
begin
  c.re:=a.re-b.re;
  c.im:=a.im-b.im;
  c_sub:=c;
end;

{-------------------------------------------------------------------}

function c_abs(a: complex): double;
// abs=sqrt(re^2+im^2)
begin
  c_abs:=sqrt(sqr(a.re)+sqr(a.im));
end;

{-------------------------------------------------------------------}

function c_ang(a: complex): double;
// phi = arctan(im/re)
begin
  c_ang:=myarctan2(a.re, a.im);
end;

{-------------------------------------------------------------------}

function c_exp(r, phi: double): complex;
// c = r * exp(I*phi)
var
  c: complex;
begin
  c.re:=r*cos(phi);
  c.im:=r*sin(phi);
  c_exp:=c;
end;

{-------------------------------------------------------------------}

function c_get(re, im: double): complex;
// a = re + I * im
var
  c: complex;
begin
  c.re:=re; c.im:=im;
  c_get:=c;
end;

{-------------------------------------------------------------------}

function c_mul(a, b: complex): complex;
// a*b
var
  c: complex;
begin
  c.re:=a.re*b.re-a.im*b.im;
  c.im:=a.re*b.im+a.im*b.re;
  c_mul:=c;
end;

{-------------------------------------------------------------------}

function c_pow(a: complex; p: double): complex;
// a^p
begin
  c_pow:=c_exp(PowR(c_abs(a),p), p*c_ang(a));
end;

{-------------------------------------------------------------------}

function c_sca(a: complex; s: double): complex;
// a*s
var
  c: complex;
begin
  c.re:=s*a.re;
  c.im:=s*a.im;
  c_sca:=c;
end;

{-------------------------------------------------------------------}

function c_re(a: complex): double;
begin
  c_re:=a.re;
end;

{-------------------------------------------------------------------}

function c_im(a: complex): double;
begin
  c_im:=a.im;
end;

{-------------------------------------------------------------------}

function IntersectLineCircle(ax,ay,alfa, kx,ky,rad:real; var wp,wm:real):integer;
{intersection of circle at kx,ky radius rad with
line through ax,ay, slope angle alfa.
returns var p1,p2 angles on circle and number of solutions}
var
  nx,ny,aa,rt: real;
  n:integer;
begin
  nx:=cos(alfa); ny:=sin(alfa);
  aa:=((kx-ax)*ny-(ky-ay)*nx)/rad;
  rt:=1-aa*aa;
  wp:=0; wm:=0;
  rt:=1-aa*aa;
  if rt < 0 then n:=0 else begin
    rt:=sqrt(rt);
    if rt=0 then begin
      wp:=myArcTan2(-aa*ny,aa*nx);
      n:=1;
    end else begin
      wp:=myArcTan2(-aa*ny+nx*rt,aa*nx+ny*rt);
      wm:=myArcTan2(-aa*ny-nx*rt,aa*nx-ny*rt);
      n:=2;
    end;
  end;
  IntersectLineCircle:=n;
end;

{-------------------------------------------------------------------}

function IntersectLines(x0,y0,a0,x1,y1,a1: real; var xv, yv, dis0, dis1: real): boolean;
{intersection of two lines through points x*, y* with slope angle a*
returns xv, yv vertex coordinates and distances dis* from (x*,y*) to vertex
result true if intersection exists, false for parallel lines}
var
  c0, c1, s0, s1, denom: real;
begin
// direction unit vectors
  c0:=cos(a0); s0:=sin(a0); c1:= cos(a1); s1:=sin(a1);
  denom:=c1*s0-c0*s1;
  if abs(denom) < 1e-12 then IntersectLines:=false else begin
    dis0:=((x0-x1)*s1-(y0-y1)*c1)/denom;
    dis1:=((x0-x1)*s0-(y0-y1)*c0)/denom;
    xv:=x0+dis0*c0;
    yv:=y0+dis0*s0;
    IntersectLines:=true;
  end;
end;

{-------------------------------------------------------------------}

function RoundUp (x: double): double;
const
  nxr=3;
  xr: array[1..nxr] of double =(2,5,10);
var
  xm, xmm: double;
  xe, i:integer;
begin
  xm:=abs(x);
  splitpow10 (xm, xe);
  // 1 <= xm < 10
  xmm:=xr[1];
  for i:=1 to nxr-1 do if xm>xr[i] then xmm:=xr[i+1];
  xmm:=PowI(10,xe)*xmm;
  if x<0 then xmm:=-xmm;
  Roundup:=xmm;
end;

procedure SplitPow10 (var  x: double; var expo: Integer);

{ split power of 10: x = mant * 10^expo; x:=mant}

var      mant : double;

begin
  if x<>0 then begin
    expo:=Round(Int(Ln(abs(x))/Ln(10)));
    mant:=x/exp(Ln(10)*expo);
    if abs(x)<1 then begin
      Dec(expo);
      mant:=10*mant;
    end;
    x:=mant;
  end
  else expo:=0;
end;

{-------------------------------------------------------------------}

Function PowI    ( x : double; n: Integer) : double;
var a: double; i: integer;
begin
  a:=1;
  for i:=1 to abs(n) do a:=a*x;
  if n>0 then PowI:=a else PowI:=1.0/a;
end;

{--------------------------------------------------------------------}

Function PowR    ( x, p : double) : double;
begin
  if x>0 then PowR:=Exp(Ln(x)*p)
  else if x=0 then begin
    if p=0 then PowR:=1 else PowR:=0; //corrected 0^0=1 not 0, 11.2.2025
  end
//  else if Abs(p-Round(p))<eps then PowR:=PowI(x,Round(p)) else
  {x<0 should not be entered into this function, because the result will
   be complex. So return at least the real part of the result.
   If p is integer, this is correct and gives PowI(x,Round(p))}
  else PowR:=Exp(Ln(Abs(x))*p)*Cos(p*Pi); //not a good idea...
end;

{--------------------------------------------------------------------}

Function CosH    ( x : double ) : double;
var      a : double;
begin
  a:=exp(x); a:=(a+1/a);
  cosh:=a/2;
end;

{-------------------------------------------------------------------------}

Function SinH    ( x : double ) : double;
var   a : double;
begin
  a:=exp(x); a:=(a-1/a);
  sinh:=a/2;
end;

{--------------------------------------------------------------------}

Function Tan     ( x: double ) : double;
begin
  Tan:=Sin(x)/Cos(x);
end;

{--------------------------------------------------------------------}

Function Sinxx   ( x : double ) : double;
begin
  if Abs(x)<1E-10 then Sinxx:=1 else Sinxx:=Sin(x)/x;
end;

{-------------------------------------------------------------------------}

Function ArcSin  ( x : double ) : double;
// returns angle in interval [-pi/2,+pi/2]
var
  tmp, root: double;
begin
  tmp:=1-Sqr(x); //protect against round off:
  if abs(tmp)<1e-12 then begin // close to +1 or -1
    if x>0 then ArcSin:=Pi/2 else ArcSin:=-Pi/2;
  end else begin
    root:=sqrt(tmp); //let it crash here if |x|>1, don't return a fake result!
    ArcSin:=ArcTan(x/root);
  end;
end;

{-------------------------------------------------------------------------}

Function ArcCos  ( x : double ) : double;
// returns angle in interval [0,pi]
var
  tmp,root: double;
begin
  tmp:=1-Sqr(x); //protect against round off:
//  if abs(tmp)<1e-12 then ArcCos:=0 else if abs(x)>1e-16 then begin
  if tmp<1e-12 then ArcCos:=0 else if abs(x)>1e-16 then begin
    root:=sqrt(tmp);
    tmp:=ArcTan(root/abs(x));
    if x<0 then ArcCos:=Pi-tmp else ArcCos:=tmp;
  end else ArcCos:=PI/2;
end;

{-------------------------------------------------------------------------}

Function MyArcTan2  ( x, y : double) : double; // returns angle in [0..2pi]
var  a: double;
const eps=1E-16;
begin
  if Abs(x)<Eps then if y>0 then a:=Pi/2 else a:=3*Pi/2
  else begin
    a:=ArcTan(Abs(y/x));
    if x<0 then if y>0 then a:=Pi-a else a:=a+Pi
    else if y<0 then a:=2*pi-a;
  end;
  myArcTan2:=a;
end;

{-------------------------------------------------------------------------}

Function qArcTan2  ( x, y : double) : double; //returns angle in [-pi..+pi]
var  a: double;
const eps=1E-16;
begin
  if Abs(x)<Eps then if y>0 then a:=Pi/2 else a:=-Pi/2
  else begin
    a:=ArcTan(Abs(y/x));
    if y<0 then a:=-a;
    if x<0 then if y>0 then a:=Pi-a else a:=-Pi-a;
  end;
  qArcTan2:=a;
end;

{-------------------------------------------------------------------------}

function Ctouschek_pol (x: double): double;
{
 polynomial approximation for the touschek function to avoid
 numerical integration. agrees within +/-2.5 % over a range from
 1e-7 < x < 10.0
 switch to asymptotic expression for x < 0.0013
 switch to integration for x > 10 (never happens...)
}
const
  a: array[0..7] of double =(-3.10811  , -2.19156  , -0.615641  , -0.160444,
                             -0.0460054, -0.0105172, -0.00131192, -6.38980e-05);
  xswitch=0.0013;
var
  s, u: double;
  k:integer;
begin
  if x < xswitch then s:=Ln(0.5772/x)-1.5 else
  if x > 10.0 then s:=Ctouschek(x) else begin
    s:=0.0;
    u:=Ln(x);
    for k:=1 to 8 do s:=u*s+a[8-k];
    s:=exp(s);
  end;
  Ctouschek_pol:=s;
end;

Function Ctouschek (x: double): double;

{calculates the Touschek function C(ea) by simpson integration:
 C = integral (1 to inf) (2u-ln(u)-2)*exp(-ea*u)/(2u^2) du
 as given in ZAP manual eq. IV.10.5 or Bruck, eq. 30.10.
 Asymptotic expression used for ea<0.001 (Bruck eq 30.13), err<1e-3.
 Integration procedures from Numerical Recipes.
 Not much precision (qsimpeps) required.
 Substitution u=1/u gives better stability.   as-221097}

const
  qsimpeps=1e-5; qsimpjmax=20;
  uzero=0.0434; {=1/(10*Ln10) limit for exp(..)=1e-10}
  xswitch=0.001; {switch to asymptotic expression}
  xtoobig=22.8; {integration does not converge anymore, set result to ~0 (1e-16)}
var
  glit: integer; s: double;

Function Targ (u: double): double;
begin
  Targ:=(1/u-ln(1/u)/2-1)*exp(-x/u);
end;

PROCEDURE trapzd(a,b: double; VAR s: double; n: integer);
VAR   j: integer;  x,tnm,sum,del: double;
BEGIN
   IF (n = 1) THEN BEGIN
      s := 0.5*(b-a)*(targ(a)+targ(b));
      glit := 1
   END
   ELSE BEGIN
      tnm := glit;
      del := (b-a)/tnm;
      x := a+0.5*del;
      sum := 0.0;
      FOR j := 1 to glit DO BEGIN
         sum := sum+targ(x);
         x := x+del
      END;
      s := 0.5*(s+(b-a)*sum/tnm);
      glit := 2*glit
   END
END;

PROCEDURE qsimp(a,b: double; VAR s: double);
LABEL 99;
VAR    j: integer;   st,ost,os: double;
BEGIN
   ost := -1.0e20;
   os := -1.0e20;
   FOR j := 1 to qsimpjmax DO BEGIN
      trapzd(a,b,st,j);
      s := (4.0*st-ost)/3.0;
      IF (abs(s-os) < qsimpeps*abs(os)) THEN GOTO 99;
      os := s;
      ost := st;
   END;
//   writeln ('pause in QSIMP - too many steps');
99:   END;

begin
  if x < xswitch then s:=ln(0.5772/x)-1.5 else if x > xtoobig then s:=1e-16 else Qsimp (uzero*x,1,s);
  Ctouschek:=s;
end;

{-------------------------------------------------------------------------}

Procedure Primefacs (za: Integer; var k: Integer; var f:Iarr_20);

var z, t, r: Integer;

begin
  z:=za;
  t:=2;
  k:=0;
  repeat;
    repeat;
      r:= z mod t;
      if r=0 then begin
        z:=z div t;
        Inc(k);
        f[k]:=t;
      end;
    until r<>0;
    Inc(t);
  until t>z;
end;

{-----------------------------------------------------------------------}

PROCEDURE LUDCMP (n: integer; VAR a: Matrix_5; VAR indx: Index_5;
                  VAR d: double; VAR Flag: Boolean);
{a black box from Numerical Recipes}
CONST
   tiny=1.0e-20;
VAR
   k,j,imax,i: integer;
   sum,dum,big: double;
   vv: Vektor_5;
BEGIN
   d := 1.0;
   Flag:=False;
   FOR i := 1 to n DO BEGIN
      big := 0.0;
      FOR j := 1 to n DO IF (abs(a[i,j]) > big) THEN big := abs(a[i,j]);
      IF (big = 0.0) THEN
         Flag:=True
      ELSE
        vv[i] := 1.0/big
   END;
{*}if not Flag then begin
     FOR j := 1 to n DO BEGIN
        IF (j > 1) THEN BEGIN
           FOR i := 1 to j-1 DO BEGIN
              sum := a[i,j];
              IF (i > 1) THEN BEGIN
                 FOR k := 1 to i-1 DO BEGIN
                    sum := sum-a[i,k]*a[k,j]
                 END;
                 a[i,j] := sum
              END
           END
        END;
        big := 0.0;
        FOR i := j to n DO BEGIN
           sum := a[i,j];
           IF (j > 1) THEN BEGIN
              FOR k := 1 to j-1 DO BEGIN
                 sum := sum-a[i,k]*a[k,j]
              END;
              a[i,j] := sum
           END;
           dum := vv[i]*abs(sum);
           IF (dum > big) THEN BEGIN
              big := dum;
              imax := i
           END
        END;
        IF (j <> imax) THEN BEGIN
           FOR k := 1 to n DO BEGIN
              dum := a[imax,k];
              a[imax,k] := a[j,k];
              a[j,k] := dum
           END;
           d := -d;
           vv[imax] := vv[j]
        END;
        indx[j] := imax;
        IF (j <> n) THEN BEGIN
           IF (a[j,j] = 0.0) THEN a[j,j] := tiny;
           dum := 1.0/a[j,j];
           FOR i := j+1 to n DO BEGIN
              a[i,j] := a[i,j]*dum
           END
        END
     END;
     IF (a[n,n] = 0.0) THEN a[n,n] := tiny;
{*}end;
END;

{---------------------------------------------------------------------}

PROCEDURE LUBKSB  (n: integer; VAR a: matrix_5;
                                VAR indx: Index_5; VAR b: Vektor_5);
{another black box from Numerical Recipes}
{CONST
   tiny=1.0e-20;
}
VAR
   j,i,ip,ii: integer;
   sum: double;
BEGIN
   ii := 0;
   FOR i := 1 to n DO BEGIN
      ip := indx[i];
      sum := b[ip];
      b[ip] := b[i];
      IF  (ii <> 0) THEN BEGIN
         FOR j := ii to i-1 DO BEGIN
            sum := sum-a[i,j]*b[j]
         END
      END ELSE IF (sum <> 0.0) THEN BEGIN
         ii := i
      END;
      b[i] := sum
   END;
   FOR i := n DOWNTO 1 DO BEGIN
      sum := b[i];
      IF (i < n) THEN BEGIN
         FOR j := i+1 to n DO BEGIN
            sum := sum-a[i,j]*b[j]
         END
      END;
      b[i] := sum/a[i,i]
   END
END;

{-------------------------------------------------------------------------}

Procedure MatInv  (n: integer; VAR a: Matrix_5; VAR Failure: Boolean);
//inversion of nxn matrix, n<=5
var indx: Index_5;
    col : Vektor_5;
    b   : Matrix_5;
    d   : double;
    i, j: integer;

begin
  LUDCMP (n, a, indx, d, Failure);
  if not Failure then begin
    for j:=1 to n do begin
      for i:=1 to n do col[i]:=0.0;
      col[j]:=1.0;
      LUBKSB (n, a, indx, col);
      for i:=1 to n do b[i,j]:=col[i];
    end;
    a:=b;
  end;
end;
{-------------------------------------------------------------------------}

function MatDet  (n: integer; b: Matrix_5): double;

var indx: Index_5;
    d   : double;
    j: integer;
    a: matrix_5;
    Failure: boolean;

begin
  a:=b;
  LUDCMP (n, a, indx, d, Failure);
  if not Failure then begin
    for j:=1 to n do d:=d*a[j,j];
    matdet:=d;
  end else matdet:=999.999;
end;

{-----------------------------------------------------------------}

{ shortcut for  beam matrix without coupling
procedure MatInvS (var a: Matrix_5);

var i,j: integer; b: matrix_5; det: double;

begin
  for i:=1 to 4 do for j:=1 to 4 do b[i,j]:=0;
  det:=a[1,1]*a[2,2]-a[1,2]*a[2,1];
  b[1,1]:= a[2,2]/det;
  b[1,2]:=-a[1,2]/det;
  b[2,1]:=-a[2,1]/det;
  b[2,2]:= a[1,1]/det;
  det:=a[3,3]*a[4,4]-a[3,4]*a[4,3];
  b[3,3]:= a[4,4]/det;
  b[3,4]:=-a[3,4]/det;
  b[4,3]:=-a[4,3]/det;
  b[4,4]:= a[3,3]/det;
  a:=b;
end;
}

{---------------------------------------------------------------------------}

Procedure EulerAng (r: Matrix_3; var angy, angx, angs: double; altsol:boolean);
{Calculation of rotation angles from rotation matrix. 21.11.2019
modification of https://eecs.qmul.ac.uk/~gslabaugh/publications/euler.pdf
with opposite orders of multiplications.
Here:
  in beam system: first y (XZ plane), then x (up/down), then s (roll)
  in hall system: first Z (XY plane), then Y (up/down), then X
There: first X, then Y, then Z
angy, angx, angs = phi, theta, psi
altsol=true select the other of the two solutions
}
const
  eps=1e-10;
var
  cth: double;
begin
  if  1-abs(r[1,3]) > eps then begin
    if altsol then  angx:=Pi-arcsin(r[1,3]) else  angx:=arcsin(r[1,3]);
    cth:=cos(angx);
    angy:=-qArcTan2(r[1,1]/cth, r[1,2]/cth);
    angs:=-qArcTan2(r[3,3]/cth, r[2,3]/cth);
//    angy:=-ArcTan2(r[1,2]/cth, r[1,1]/cth);
//    angs:=-ArcTan2(r[2,3]/cth, r[3,3]/cth);
  end else begin
    if r[1,3] > 0 then begin
      angx:=Pi/2;
      if altsol then begin
        angy:=0; angs:=qArcTan2(r[2,2],r[2,1]);
      end else begin
        angs:=0; angy:=qArcTan2(r[2,2],r[2,1]);
      end;
    end else begin
      angx:=-Pi/2;
      if altsol then begin
        angy:=0; angs:=-qArcTan2(r[2,2],r[2,1]);
      end else begin
        angs:=0; angy:= qArcTan2(r[2,2],r[2,1]);
      end;
    end;
  end;
end;

{Function MatUni3: Matrix_3;
var
  x: matrix_3;
  i,j: integer;
begin
  x:=MatNul3;
  for i:=1 to 3 do x[i,i]:=1;
  MatUni3:=x;
end;
}
function RotMat3 (iax: integer; ang:real): Matrix_3;
var
  x: matrix_3; c,s: real;
begin
  c:=Cos(ang); s:=Sin(ang);
  x:=MatUni3;
  case iax of
  1: begin x[2,2]:=c; x[3,3]:=c; x[2,3]:=-s; x[3,2]:= s; end;
  2: begin x[1,1]:=c; x[3,3]:=c; x[1,3]:= s; x[3,1]:=-s; end; //changed sign here  http://www.gregslabaugh.net/publications/euler.pdf
  3: begin x[1,1]:=c; x[2,2]:=c; x[1,2]:=-s; x[2,1]:= s; end;
  end;
  RotMat3:=x;
end;

function MatInv3 (m: Matrix_3) : Matrix_3;
// inverse of matrix3 with |m|=1 (used for rotations only)
// M-1_ij=(-1)^(i+j)*|Adj(j,i)|
const
  a: array[1..3] of integer = (2,1,1);
  b: array[1..3] of integer = (3,3,2);
var
  mi: Matrix_3;
  ad: Matrix_2;
  sig, i, j: integer;
begin
  sig:=-1;
  for i:=1 to 3 do for j:=1 to 3 do begin
    ad:=Matset2(m[a[j],a[i]], m[a[j],b[i]],m[b[j],a[i]],m[b[j],b[i]]);
    sig:=-sig;
    mi[i,j]:=sig*MatDet2(ad);
  end;
  MatInv3:=mi;
end;

Function MatMul3 (A: matrix_3; B: matrix_3): Matrix_3;
var
  i, j, k : integer;
  C: matrix_3;
begin
  for i:=1 to 3 do for j:=1 to 3 do begin
    C[i,j]:=0;
    for k:=1 to 3 do C[i,j]:=C[i,j]+A[i,k]*B[k,j];
  end;
  MatMul3:=C;
end;

Function LinTra3 (a: Matrix_3; v: Vektor_3): Vektor_3;
var x: Vektor_3; i,j: integer;
begin
  for i:=1 to 3 do begin
    x[i]:=0; for j:=1 to 3 do x[i]:=x[i]+a[i,j]*v[j];
  end;
  LinTra3:=x;
end;

Function VecAdd3 (a,b: Vektor_3): Vektor_3;
var c: Vektor_3; i:integer;
begin
  for i:=1 to 3 do c[i]:=a[i]+b[i];
  VecAdd3:=c;
end;

Function VecSub3 (a,b: Vektor_3): Vektor_3;
var c: Vektor_3; i:integer;
begin
  for i:=1 to 3 do c[i]:=a[i]-b[i];
  VecSub3:=c;
end;

Function VecSet3(x,y,z: real): Vektor_3;
  var v: vektor_3;
begin
  v[1]:=x; v[2]:=y; v[3]:=z;
  VecSet3:=v;
end;

Function VecAbs3 (a: Vektor_3): real;
var
  r: real; i: integer;
begin
  r:=0;
  for i:=1 to 3 do r:=r+sqr(a[i]);
  VecAbs3:=sqrt(r);
end;

Function VecSca3 (a: Vektor_3; r: real): Vektor_3;
var
  x: Vektor_3; i: integer;
begin
  for i:=1 to 3 do x[i]:=a[i]*r;
  VecSca3:=x;
end;

Function VecScp3 (a, b: Vektor_3): real;
//scalar product
begin
  VecScp3:=a[1]*b[1]+a[2]*b[2]+a[3]*b[3];
end;

Function VecPro3 (a, b: Vektor_3): Vektor_3;
//vector product
var
  c: Vektor_3;
begin
  c[1]:= a[2]*b[3]-a[3]*b[2];
  c[2]:= a[3]*b[1]-a[1]*b[3];
  c[3]:= a[1]*b[2]-a[2]*b[1];
  VecPro3:=c;
end;

{ - - - - 2x2 matrices}
{
function MatNul2: Matrix_2;
var  x: matrix_2;
begin
  x[1,1]:=0; x[2,2]:=0; x[1,2]:=0; x[2,1]:=0;
  MatNul2:=x;
end;
}
{function MatUni2: Matrix_2;
var  x: matrix_2;
begin
  x:=MatNul2;
  x[1,1]:=1; x[2,2]:=1;
  MatUni2:=x;
end;
}
Function MatSet2 (m11, m12, m21, m22: double): Matrix_2;
var x: matrix_2;
begin
  x[1,1]:=m11; x[1,2]:=m12; x[2,1]:=m21; x[2,2]:=m22;
  MatSet2:=x;
end;

function MatSub2(a,b: Matrix_2): Matrix_2;
  // subtraction
var  x: Matrix_2; i,j: integer;
begin
  for i:=1 to 2 do for j:=1 to 2 do x[i,j]:=a[i,j]-b[i,j];
  MatSub2:=x;
end;

function MatAdd2(a,b: Matrix_2): Matrix_2;
  // addition
var  x: Matrix_2; i,j: integer;
begin
  for i:=1 to 2 do for j:=1 to 2 do x[i,j]:=a[i,j]+b[i,j];
  MatAdd2:=x;
end;

Function MatMul2 (A: matrix_2; B: matrix_2): Matrix_2;
var
  i, j, k : integer;
  C: matrix_2;
begin
  for i:=1 to 2 do for j:=1 to 2 do begin
    C[i,j]:=0;
    for k:=1 to 2 do C[i,j]:=C[i,j]+A[i,k]*B[k,j];
  end;
  MatMul2:=C;
end;

Function MatDet2(a: Matrix_2): double;
  // determinant
begin
  MatDet2:=a[1,1]*a[2,2]-a[1,2]*a[2,1];
end;

Function MatSyc2(a: Matrix_2): Matrix_2;
  //symplectic conjugate = inverse if |a|=1
var x: Matrix_2;
begin
  x[1,1]:= a[2,2];  x[1,2]:=-a[1,2];
  x[2,1]:=-a[2,1];  x[2,2]:= a[1,1];
  MatSyc2:=x;
end;

Function MatSca2(s: double; a: Matrix_2): Matrix_2;
  // scalar multiplication
var  x: Matrix_2;  i,j: integer;
begin
  for i:=1 to 2 do for j:=1 to 2 do x[i,j]:=s*a[i,j];
  MatSca2:=x;
end;

Function MatTra2(a: Matrix_2): double;
  // get trace
begin
  MatTra2:=a[1,1]+a[2,2];
end;

Function MatSig2 (m, a: Matrix_2): Matrix_2;
 //  M * A * M^T (Transposed(M))
var T11, T12, T21, T22: double; B: Matrix_2;
begin
  T11   :=A[1,1]*M[1,1]+A[1,2]*M[1,2];
  T12   :=A[1,1]*M[2,1]+A[1,2]*M[2,2];
  T21   :=A[2,1]*M[1,1]+A[2,2]*M[1,2];
  T22   :=A[2,1]*M[2,1]+A[2,2]*M[2,2];
  B[1,1]:=M[1,1]*T11+M[1,2]*T21;
  B[1,2]:=M[1,1]*T12+M[1,2]*T22;
  B[2,1]:=M[2,1]*T11+M[2,2]*T21;
  B[2,2]:=M[2,1]*T12+M[2,2]*T22;
  MatSig2:=B;
end;



{
Function MatStr2(m: Matrix_2): string;
var
  s: string;
begin
  s:='[ '+FloattoStr(m[1,1])+' '+FloattoStr(m[1,2]+'  ]'+#10#13+'[ '+floattostr(m[2,1])+' '+floattostr(m[2,2])+'  ]');
  MatStr2:=s;
end;
}
{ - - - - 4x4 matrices}

{function MatUni4: Matrix_4;
var  x: Matrix_4; i,j: integer;
begin
  for i:=1 to 4 do begin for j:=1 to 4 do x[i,j]:=0; x[i,i]:=1; end;
  MatUni4:=x;
end;
}
Function MatSub4(a,b: Matrix_4): Matrix_4;
var  x: Matrix_4; i,j: integer;
begin
  for i:=1 to 4 do for j:=1 to 4 do x[i,j]:=a[i,j]-b[i,j];
  MatSub4:=x;
end;

Function MatAdd4(a,b: Matrix_4): Matrix_4;
var  x: Matrix_4; i,j: integer;
begin
  for i:=1 to 4 do for j:=1 to 4 do x[i,j]:=a[i,j]+b[i,j];
  MatAdd4:=x;
end;

Function MatSca4(s: double; a: Matrix_4): Matrix_4;
  // scalar multiplication
var  x: Matrix_4;  i,j: integer;
begin
  for i:=1 to 4 do for j:=1 to 4 do x[i,j]:=s*a[i,j];
  MatSca4:=x;
end;

Function MatMul4  (A: matrix_4; B: matrix_4): Matrix_4;
var
  i, j, k : integer;
  C: matrix_4;
begin
  for i:=1 to 4 do for j:=1 to 4 do begin
    C[i,j]:=0; for k:=1 to 4 do C[i,j]:=C[i,j]+A[i,k]*B[k,j];
  end;
  MatMul4:=C;
end;

Function LinTra4 (a: Matrix_4; v: Vektor_4): Vektor_4;
var x: Vektor_4; i,j: integer;
begin
  for i:=1 to 4 do begin
    x[i]:=0; for j:=1 to 4 do x[i]:=x[i]+a[i,j]*v[j];
  end;
  LinTra4:=x;
end;

Function MatTra4 (a: Matrix_4): Matrix_4;
// transpose
var x: Matrix_4; i,j: integer;
begin
  for i:=1 to 4 do for j:=1 to 4 do x[i,j]:=a[j,i];
  MatTra4:=x;
end;

Function MatInv4 (a: Matrix_4; var fail: boolean): Matrix_4;
var x: Matrix_5;
begin
  x:=MatCpy45(a);
  MatInv(4,x,fail);
  MatInv4:=MatCut54(x);
end;


Function VecAdd4  (a,b: Vektor_4): Vektor_4;
var
  x: Vektor_4;
  i: Integer;
begin
  for i:=1 to 4 do x[i]:=a[i]+b[i];
  VecAdd4:=x;
end;

Function VecSub4  (a,b: Vektor_4): Vektor_4;
var
  x: Vektor_4;
  i: Integer;
begin
  for i:=1 to 4 do x[i]:=a[i]-b[i];
  VecSub4:=x;
end;

Function VecAbs4 (a: Vektor_4): double;
var
  r: double; i: integer;
begin
  r:=0;
  for i:=1 to 4 do r:=r+sqr(a[i]);
  VecAbs4:=sqrt(r);
end;

{Function VecNul4: Vektor_4;
var
  x: Vektor_4; i: integer;
begin
  for i:=1 to 4 do x[i]:=0;
  VecNul4:=x;
end;
}

{ - - - - 5x5 matrices}
{
function MatNul5: Matrix_5;
var  x: Matrix_5; i,j: integer;
begin
  for i:=1 to 5 do for j:=1 to 5 do x[i,j]:=0;
  MatNul5:=x;
end;
}
{
function MatUni5: Matrix_5;
var  x: Matrix_5; i,j: integer;
begin
  for i:=1 to 5 do begin for j:=1 to 5 do x[i,j]:=0; x[i,i]:=1; end;
  MatUni5:=x;
end;
}

Function MatMul5  (A, B: matrix_5): Matrix_5;
var
  i, j, k : integer;
  C: matrix_5;
begin
  for i:=1 to 5 do for j:=1 to 5 do begin
    C[i,j]:=0;
    for k:=1 to 5 do C[i,j]:=C[i,j]+A[i,k]*B[k,j];
  end;
  MatMul5:=C;
end;


Function MatMul5_S (A, B: matrix_5): Matrix_5;
//fast version for blockdiagonal and no V-disp production
var
  C: matrix_5;
begin
  C:=MatUni5;
  C[1,1]:=A[1,1]*B[1,1]+A[1,2]*B[2,1];
  C[1,2]:=A[1,1]*B[1,2]+A[1,2]*B[2,2];
  C[2,1]:=A[2,1]*B[1,1]+A[2,2]*B[2,1];
  C[2,2]:=A[2,1]*B[1,2]+A[2,2]*B[2,2];
  C[3,3]:=A[3,3]*B[3,3]+A[3,4]*B[4,3];
  C[3,4]:=A[3,3]*B[3,4]+A[3,4]*B[4,4];
  C[4,3]:=A[4,3]*B[3,3]+A[4,4]*B[4,3];
  C[4,4]:=A[4,3]*B[3,4]+A[4,4]*B[4,4];
  C[1,5]:=A[1,1]*B[1,5]+A[1,2]*B[2,5]+A[1,5]; // B[5,5]=1
  C[2,5]:=A[2,1]*B[1,5]+A[2,2]*B[2,5]+A[2,5];
  MatMul5_S:=C;
end;


Function MatTra5 (a: Matrix_5): Matrix_5;
var x: Matrix_5; i,j: integer;
begin
  for i:=1 to 5 do for j:=1 to 5 do x[i,j]:=a[j,i];
  MatTra5:=x;
end;


function LinTra5  (m: matrix_5; v: vektor_5): Vektor_5;
var x: Vektor_5; i,j: integer;
begin
  for i:=1 to 5 do begin
    x[i]:=0;  for j:=1 to 5 do x[i]:=x[i]+m[i,j]*v[j];
  end;
  LinTra5:=x;
end;

Function LinTra54 (a: Matrix_5; v: Vektor_4; v5: double): Vektor_4;
var x: Vektor_4; i,j: integer;
// special for dispersion vektor, where 5th element =1 (or orbit dp/p ?)
begin
  for i:=1 to 4 do begin
    x[i]:=a[i,5]*v5;
    for j:=1 to 4 do x[i]:=x[i]+a[i,j]*v[j];
  end;
  LinTra54:=x;
end;


function BlockDiag5 (m: matrix_5): boolean;
// check if the elemetn matrix is blockdiag, i.e. no x,y coupling
var
  sum: double; i,j: integer;
begin
  sum:=0;
  for i:=1 to 2 do for j:=1 to 2 do sum:=sum+abs(m[i+2,j])+abs(m[i,j+2]);
  BlockDiag5:= sum < 1e-12;
end;

function InvRot5 (m:Matrix_5): Matrix_5;
// quick inversion of rotation matrix by inversion of off-block signs
//(c 0 s 0 0, 0 c 0 s 0, -s 0 c 0 0, 0 -s 0 c 0, 0 0 0 0 1)
var
  r: matrix_5;
begin
  r:=m;
  r[1,3]:=-r[1,3];  r[2,4]:=-r[2,4]; r[3,1]:=-r[3,1]; r[4,2]:=-r[4,2];
  InvRot5:=r;
end;



function MatSig5_S(m, a: Matrix_5): Matrix_5;
{  B = M * A * Transposed(M)
   special version for propagation of blockdiagonal matrices (only 4x4 used)
   sigma-matrix of Twiss parameters given by:   (beta  -alfa)
                                                (-alfa gamma)
}
var B: matrix_5; t11, t12, t21,t22: double;

begin
  B:=MatUni5;
  T11:=A[1,1]*M[1,1]+A[1,2]*M[1,2];
  T12:=A[1,1]*M[2,1]+A[1,2]*M[2,2];
  T21:=A[2,1]*M[1,1]+A[2,2]*M[1,2];
  T22:=A[2,1]*M[2,1]+A[2,2]*M[2,2];
  B[1,1]:=M[1,1]*T11+M[1,2]*T21;
  B[1,2]:=M[1,1]*T12+M[1,2]*T22;
  B[2,1]:=M[2,1]*T11+M[2,2]*T21;
  B[2,2]:=M[2,1]*T12+M[2,2]*T22;
  T11:=A[3,3]*M[3,3]+A[3,4]*M[3,4];
  T12:=A[3,3]*M[4,3]+A[3,4]*M[4,4];
  T21:=A[4,3]*M[3,3]+A[4,4]*M[3,4];
  T22:=A[4,3]*M[4,3]+A[4,4]*M[4,4];
  B[3,3]:=M[3,3]*T11+M[3,4]*T21;
  B[3,4]:=M[3,3]*T12+M[3,4]*T22;
  B[4,3]:=M[4,3]*T11+M[4,4]*T21;
  B[4,4]:=M[4,3]*T12+M[4,4]*T22;
  MatSig5_S:=B;
end;

Function LinTra5_S (m: matrix_5; a: vektor_5): Vektor_5;
// lin trafo without coupling - but inc. vertical disp!
var
  b: Vektor_5;
begin
  b[1]:=m[1,1]*a[1]+m[1,2]*a[2]+m[1,5]*a[5];
  b[2]:=m[2,1]*a[1]+m[2,2]*a[2]+m[2,5]*a[5];
  b[3]:=m[3,3]*a[3]+m[3,4]*a[4]+m[3,5]*a[5];
  b[4]:=m[4,3]*a[3]+m[4,4]*a[4]+m[4,5]*a[5];
  b[5]:=a[5];
  LinTra5_S:=b;
end;


{conversions between matrix types}
Function LinTra244 (m,n: matrix_2; v: vektor_4): vektor_4;
// multiply vektor v with 2 x (2x2) block matrix
var a: vektor_4;
begin
  a[1]:=m[1,1]*v[1]+m[1,2]*v[2];
  a[2]:=m[2,1]*v[1]+m[2,2]*v[2];
  a[3]:=n[1,1]*v[3]+n[1,2]*v[4];
  a[4]:=n[2,1]*v[3]+n[2,2]*v[4];
  LinTra244:=a;
end;

Function MatCut42(M: Matrix_4; irow, icol: integer): matrix_2;
  // submatrix: irow, icol offsets
var  a: Matrix_2; ir, ic: integer;
begin
  for ir:=1 to 2 do for ic:=1 to 2 do a[ir,ic]:=m[irow-1+ir, icol-1+ic];
  MatCut42:=a;
end;

Function MatCut52(M: Matrix_5; irow, icol: integer): matrix_2;
  // submatrix: irow, icol offsets
var  a: Matrix_2; ir, ic: integer;
begin
  for ir:=1 to 2 do for ic:=1 to 2 do a[ir,ic]:=m[irow-1+ir, icol-1+ic];
  MatCut52:=a;
end;


Function MatCmp24 (m11,m12,m21,m22: Matrix_2): matrix_4;
// combine 4 2x2matrices into one 4x4 matrix
var x: Matrix_4; i,j: integer;
begin
  for i:=1 to 2 do for j:=1 to 2 do begin
    x[i  ,j  ]:=m11[i,j];
    x[i  ,j+2]:=m12[i,j];
    x[i+2,j  ]:=m21[i,j];
    x[i+2,j+2]:=m22[i,j];
  end;
  MatCmp24:=x;
end;

Function MatCpy45 (m: Matrix_4): Matrix_5;
// write a 4x4 matrix into a 5x5 unit matrix
var x: Matrix_5; i,j: integer;
begin
  x:=MatUni5;
  for i:=1 to 4 do for j:=1 to 4 do x[i,j]:=m[i,j];
  MatCpy45:=x;
end;

Procedure MatMV54 (m: Matrix_5; var t: Matrix_4; var v: Vektor_4);
// split 5x5 matrix into 4x4 matrix and vector: M = ( T | V ), ignore 5th row
var i, j: integer;
begin
  for i:=1 to 4 do begin
    for j:=1 to 4 do t[i,j]:=m[i,j];
    v[i]:=m[i,5];
  end;
end;

Function MatCut54 (m: Matrix_5): matrix_4;
//cut 4x4 from 5x5 matrix, dump last row and col
var  a: Matrix_4; i, j: integer;
begin
  for i:=1 to 4 do for j:=1 to 4 do a[i,j]:=m[i,j];
  MatCut54:=a;
end;

function Vektor45(e: Vektor_4; e5:real): Vektor_5;
var
  d: Vektor_5; i: integer;
begin
  for i:=1 to 4 do d[i]:=e[i];
  d[5]:=e5;
  Vektor45:=d;
end;

Function Vektor54(e: Vektor_5): Vektor_4;
var
  d: Vektor_4; i: integer;
begin
  for i:=1 to 4 do d[i]:=e[i];
  Vektor54:=d;
end;



{ SVD procedures from NumRec, modified for variable array size}

PROCEDURE svdcmp(VAR apack: array of real;    //MxN
                   m,n: integer;
                 VAR w: array of real;        //N
                 VAR vpack: array of real);   //NxN
LABEL 1,2,3;
VAR
   nm,l,k,j,jj,its,i,mnmin: integer;
   z,y,x,scale,s,h,g,f,c,anorm: real;
   rv1: array of real; //^RealArrayNP;
   a, v: array of array of real;

FUNCTION sign(a,b: real): real;
BEGIN
   IF b >= 0.0 THEN sign := abs(a) ELSE sign := -abs(a)
END;

FUNCTION max(a,b: real): real;
BEGIN
   IF a > b THEN max := a ELSE max := b
END;

FUNCTION pythag(a,b: real): real;
VAR
   at,bt: real;
BEGIN
   at := abs(a);
   bt := abs(b);
   IF at > bt THEN
      pythag := at*sqrt(1.0+sqr(bt/at))
   ELSE
      IF bt = 0.0 THEN
         pythag := 0.0
      ELSE
         pythag := bt*sqrt(1.0+sqr(at/bt))
END;

BEGIN
// define local arrays
   setlength(rv1,n+1);
   setlength(a,m+1,n+1);
   setlength(v,n+1,n+1);
// pack incoming 1-D arrays starting at 0 into 2D arrays starting at 1

   for i:=1 to m do for j:=1 to n do a[i,j]:=apack[(i-1)*n+j-1];
   for i:=1 to n do for j:=1 to n do v[i,j]:=vpack[(i-1)*n+j-1];


   g := 0.0;
   scale := 0.0;
   anorm := 0.0;
   FOR i := 1 TO n DO BEGIN
      l := i+1;
      rv1[i] := scale*g;
      g := 0.0;
      s := 0.0;
      scale := 0.0;
      IF i <= m THEN BEGIN
         FOR k := i TO m DO
            scale := scale+abs(a[k,i]);
         IF scale <> 0.0 THEN BEGIN
            FOR k := i TO m DO BEGIN
               a[k,i] := a[k,i]/scale;
               s := s+a[k,i]*a[k,i]
            END;
            f := a[i,i];
            g := -sign(sqrt(s),f);
            h := f*g-s;
            a[i,i] := f-g;
            FOR j := l TO n DO BEGIN
               s := 0.0;
               FOR k := i TO m DO
                  s := s+a[k,i]*a[k,j];
               f := s/h;
               FOR k := i TO m DO
                  a[k,j] := a[k,j]+ f*a[k,i]
            END;
            FOR k := i TO m DO
               a[k,i] := scale*a[k,i]
         END
      END;
      w[i] := scale*g;
      g := 0.0;
      s := 0.0;
      scale := 0.0;
      IF (i <= m) AND (i <> n) THEN BEGIN
         FOR k := l TO n DO
            scale := scale+abs(a[i,k]);
         IF scale <> 0.0 THEN BEGIN
            FOR k := l TO n DO BEGIN
               a[i,k] := a[i,k]/scale;
               s := s+a[i,k]*a[i,k]
            END;
            f := a[i,l];
            g := -sign(sqrt(s),f);
            h := f*g-s;
            a[i,l] := f-g;
            FOR k := l TO n DO
               rv1[k] := a[i,k]/h;
            FOR j := l TO m DO BEGIN
               s := 0.0;
               FOR k := l TO n DO
                  s := s+a[j,k]*a[i,k];
               FOR k := l TO n DO
                  a[j,k] := a[j,k] +s*rv1[k]
            END;
            FOR k := l TO n DO
               a[i,k] := scale*a[i,k]
         END
      END;
      anorm := max(anorm,(abs(w[i])+abs(rv1[i])))
   END;
   FOR i := n DOWNTO 1 DO BEGIN
      IF i < n THEN BEGIN
         IF g <> 0.0 THEN BEGIN
            FOR j := l TO n DO
               v[j,i] := (a[i,j]/a[i,l])/g;
            FOR j := l TO n DO BEGIN
               s := 0.0;
               FOR k := l TO n DO
                  s := s+a[i,k]*v[k,j];
               FOR k := l TO n DO
                  v[k,j] := v[k,j]+s*v[k,i]
            END
         END;
         FOR j := l TO n DO BEGIN
            v[i,j] := 0.0;
            v[j,i] := 0.0
         END
      END;
      v[i,i] := 1.0;
      g := rv1[i];
      l := i
   END;
   IF m < n THEN
      mnmin := m
   ELSE
      mnmin := n;
   FOR i := mnmin DOWNTO 1 DO BEGIN
      l := i+1;
      g := w[i];
      FOR j := l TO n DO a[i,j] := 0.0;
      IF g <> 0.0 THEN BEGIN
         g := 1.0/g;
         FOR j := l TO n DO BEGIN
            s := 0.0;
            FOR k := l TO m DO
               s := s+a[k,i]*a[k,j];
            f := (s/a[i,i])*g;
            FOR k := i TO m DO
               a[k,j] := a[k,j]+f*a[k,i]
         END;
         FOR j := i TO m DO
            a[j,i] := a[j,i]*g
      END
      ELSE
         FOR j := i TO m DO a[j,i] := 0.0;
      a[i,i] := a[i,i]+1.0
   END;
   FOR k := n DOWNTO 1 DO BEGIN
      FOR its := 1 TO 30 DO BEGIN
         FOR l := k DOWNTO 1 DO BEGIN
            nm := l-1;
            IF abs(rv1[l])+anorm = anorm THEN GOTO 2;
            IF nm > 0 THEN
               IF abs(w[nm])+anorm = anorm THEN GOTO 1
         END;
1:       c := 0.0;
         s := 1.0;
         FOR i := l TO k DO BEGIN
            f := s*rv1[i];
            rv1[i] := c*rv1[i];
            IF abs(f)+anorm = anorm THEN GOTO 2;
            g := w[i];
            h := pythag(f,g);
            w[i] := h;
            h := 1.0/h;
            c := (g*h);
            s := -(f*h);
            FOR j := 1 TO m DO BEGIN
               y := a[j,nm];
               z := a[j,i];
               a[j,nm] := (y*c)+(z*s);
               a[j,i] := -(y*s)+(z*c)
            END
         END;
2:       z := w[k];
         IF l = k THEN BEGIN
            IF z < 0.0 THEN BEGIN
               w[k] := -z;
               FOR j := 1 TO n DO v[j,k] := -v[j,k]
            END;
            GOTO 3
         END;
         IF its = 30 THEN BEGIN
  //          writeln ('no convergence in 30 SVDCMP iterations');
  // other error message ...
         END;
         x := w[l];
         nm := k-1;
         y := w[nm];
         g := rv1[nm];
         h := rv1[k];
         f := ((y-z)*(y+z)+(g-h)*(g+h))/(2.0*h*y);
         g := pythag(f,1.0);
         f := ((x-z)*(x+z)+h*((y/(f+sign(g,f)))-h))/x;
         c := 1.0;
         s := 1.0;
         FOR j := l TO nm DO BEGIN
            i := j+1;
            g := rv1[i];
            y := w[i];
            h := s*g;
            g := c*g;
            z := pythag(f,h);
            rv1[j] := z;
            c := f/z;
            s := h/z;
            f := (x*c)+(g*s);
            g := -(x*s)+(g*c);
            h := y*s;
            y := y*c;
            FOR jj := 1 TO n DO BEGIN
               x := v[jj,j];
               z := v[jj,i];
               v[jj,j] := (x*c)+(z*s);
               v[jj,i] := -(x*s)+(z*c)
            END;
            z := pythag(f,h);
            w[j] := z;
            IF z <> 0.0 THEN BEGIN
               z := 1.0/z;
               c := f*z;
               s := h*z
            END;
            f := (c*g)+(s*y);
            x := -(s*g)+(c*y);
            FOR jj := 1 TO m DO BEGIN
               y := a[jj,j];
               z := a[jj,i];
               a[jj,j] := (y*c)+(z*s);
               a[jj,i] := -(y*s)+(z*c)
            END
         END;
         rv1[l] := 0.0;
         rv1[k] := f;
         w[k] := x
      END;
3: END;
// pack arrays in 1-D open array:
   for i:=1 to m do for j:=1 to n do apack[(i-1)*n+j-1]:=a[i,j];
   for i:=1 to n do for j:=1 to n do vpack[(i-1)*n+j-1]:=v[i,j];
   rv1:=nil;
   a:=nil;
   v:=nil;
END;


PROCEDURE svbksb(VAR upack: array of real; //MxN
                 VAR w: array of real;     //N
                 VAR vpack: array of real; //NxN
                   m,n: integer;
                     b: array of real;     //M
                 VAR x: array of real);    //N
VAR
   jj,j,i: integer;
   s: real;
   tmp: array of real;
   u, v: array of array of real;
BEGIN
   setlength(tmp,n+1);
   setlength(u,m+1,n+1);
   setlength(v,n+1,n+1);
   for i:=1 to m do for j:=1 to n do u[i,j]:=upack[(i-1)*n+j-1];
   for i:=1 to n do for j:=1 to n do v[i,j]:=vpack[(i-1)*n+j-1];
   FOR j := 1 TO n DO BEGIN
      s := 0.0;
      IF w[j] <> 0.0 THEN BEGIN
         FOR i := 1 TO m DO
            s := s+u[i,j]*b[i];
         s := s/w[j]
      END;
      tmp[j] := s
   END;
   FOR j := 1 TO n DO BEGIN
      s := 0.0;
      FOR jj := 1 TO n DO
         s := s+v[j,jj]*tmp[jj];
      x[j] := s
   END;
   tmp:=nil;
   u:=nil;
   v:=nil;
END;


Procedure Poly_Fit (x, y: array of real; n: integer; var a: array of real);
{
  peform a polynomial least square fit Y = Sum_0^N a_k x^k using SVD
  n=order, matrix a:(n+1)x(n+1), vector b:(n+1)
  use 1-d packed matrix apack
}
var
  xsum, bvec, resvec, aupack, vpack, wvec: array of real;
  ndat, i, m, k: integer;
  tmp: real;
begin
  ndat:=length(x);
  setlength(xsum,2*n+1);
  setlength(aupack,(n+1)*(n+1)); setlength(vpack,(n+1)*(n+1));
  setlength(wvec,n+2); setlength(bvec,n+2); setlength(resvec,n+2);
  //add +1 (svd numbers from 1), element 0 is never used
  for k:=0 to n+1 do bvec[k]:=0; for k:=0 to 2*n do xsum[k]:=0;
  for i:=0 to ndat-1 do begin
    tmp:=1.0;
    for k:=0 to 2*n do begin
      xsum[k]:=xsum[k]+tmp;
      tmp:=tmp*x[i]
    end;
    tmp:=y[i];
    for k:=0 to n do begin
      bvec[k+1]:=bvec[k+1]+tmp;
      tmp:=tmp*x[i];
    end;
  end;
  for m:=0 to n do for k:=0 to n do aupack[m*(n+1)+k]:=xsum[m+k];
  xsum:=nil;
  SVDCMP(aupack,n+1,n+1,wvec,vpack);
  SVBKSB(aupack,wvec,vpack,n+1,n+1,bvec,resvec);
  for k:=0 to n do a[k]:=resvec[k+1];
  aupack:=nil; bvec:=nil; resvec:=nil; wvec:=nil; vpack:=nil;
end;

//test only...
{function mathtestproc (a,b: integer; afunc: Tmathintfunction): integer;
var
  c:integer;
begin
  c:=afunc(a,b);
  mathtestproc:=c;
end;
}

{========================= Powell =====================================}

 { Programs for Powell's minimisation procedure, taken as black
  boxes from Numerical Recipes,
  modified to accept the penalty function as parameter, as-9.3.11}

FUNCTION func(x: real): real;//f1dim
VAR
   j: integer;
   xt: PowellVector;
BEGIN                                        {define vector for steepest gradient}
   FOR j := 1 to Powellncom DO BEGIN         {as linear combination of base}
      xt[j] := Powellpcom[j]+x*Powellxicom[j]{vector set of input parameters}
   END;
   func := PowellFNC(xt);
END;

{----------------------------------------------------------------------}

PROCEDURE mnbrak(VAR ax,bx,cx,fa,fb,fc: real);
LABEL 1, 99;
CONST
   gold=1.618034;
   glimit=100.0;
   tiny=1.0e-20;
VAR
   ulim,u,r,q,fu,dum: real;
FUNCTION max(a,b: real): real;
   BEGIN
      IF (a > b) THEN max := a ELSE max := b
   END;
FUNCTION sign(a,b: real): real;
   BEGIN
      IF (b > 0.0) THEN sign := abs(a) ELSE sign := -abs(a)
   END;
BEGIN
   fa := func(ax);
   fb := func(bx);
   IF (fb > fa) THEN BEGIN
      dum := ax;
      ax := bx;
      bx := dum;
      dum := fb;
      fb := fa;
      fa := dum
   END;
   cx := bx+gold*(bx-ax);
   fc := func(cx);
1:   IF (fb >= fc) THEN BEGIN
      if powellbreakMN then begin
        powellbreak:=true;
        goto 99; //hard stop to avoid run-away for asymptotic knobs
      end;
      r := (bx-ax)*(fb-fc);
      q := (bx-cx)*(fb-fa);
      u := bx-((bx-cx)*q-(bx-ax)*r)/
         (2.0*sign(max(abs(q-r),tiny),q-r));
      ulim := bx+glimit*(cx-bx); {* crash overflow occured here}
      IF ((bx-u)*(u-cx) > 0.0) THEN BEGIN
         fu := func(u);
         IF (fu < fc) THEN BEGIN
            ax := bx;
            fa := fb;
            bx := u;
            fb := fu;
            GOTO 1 END
         ELSE IF (fu > fb) THEN BEGIN
            cx := u;
            fc := fu;
            GOTO 1
         END;
         u := cx+gold*(cx-bx);
         fu := func(u)
      END ELSE IF  ((cx-u)*(u-ulim) > 0.0) THEN BEGIN
         fu := func(u);
         IF (fu < fc) THEN BEGIN
            bx := cx;
            cx := u;
            u := cx+gold*(cx-bx);
            fb := fc;
            fc := fu;
            fu := func(u)
         END
      END ELSE IF  ((u-ulim)*(ulim-cx) >= 0.0) THEN BEGIN
         u := ulim;
         fu := func(u)
      END ELSE BEGIN
         u := cx+gold*(cx-bx);
         fu := func(u)
      END;
      ax := bx;
      bx := cx;
      cx := u;
      fa := fb;
      fb := fc;
      fc := fu;
      GOTO 1
   END;
99: END;

{----------------------------------------------------------------------}

FUNCTION brent(ax,bx,cx,tol: real; VAR xmin: real): real;
LABEL 1,2,3;
CONST
   itmax=100;
   cgold=0.3819660;
   zeps=1.0e-10;
VAR
   a,b,d,e,etemp: real;
   fu,fv,fw,fx: real;
   iter: integer;
   p,q,r,tol1,tol2: real;
   u,v,w,x,xm: real;
FUNCTION sign(a,b: real): real;
   BEGIN
      IF (b > 0.0) THEN sign := abs(a) ELSE sign := -abs(a)
   END;
BEGIN
   IF ax < cx THEN a := ax ELSE a := cx;
   IF ax > cx THEN b := ax ELSE b := cx;
   v := bx;
   w := v;
   x := v;
   e := 0.0;
   fx := func(x);
   fv := fx;
   fw := fx;
   d:=0; //dummy init, although d cannot be referenced in first iter since e=0
   FOR iter := 1 to itmax DO BEGIN
      xm := 0.5*(a+b);
      tol1 := tol*abs(x)+zeps;
      tol2 := 2.0*tol1;
      IF (abs(x-xm) <= (tol2-0.5*(b-a))) THEN GOTO 3;
      IF (abs(e) > tol1) THEN BEGIN
         r := (x-w)*(fx-fv);
         q := (x-v)*(fx-fw);
         p := (x-v)*q-(x-w)*r;
         q := 2.0*(q-r);
         IF (q > 0.0) THEN  p := -p;
         q := abs(q);
         etemp := e;
         e := d;
         IF((abs(p) >= abs(0.5*q*etemp)) OR (p <= q*(a-x))
            OR (p >= q*(b-x))) THEN GOTO 1;
         d := p/q;
         u := x+d;
         IF (((u-a) < tol2) OR ((b-u) < tol2)) THEN d := sign(tol1,xm-x);
         GOTO 2
      END;
1:      IF (x >= xm)  THEN e := a-x ELSE e := b-x;
      d := cgold*e;
2:      IF (abs(d) >= tol1)  THEN u := x+d ELSE u := x+sign(tol1,d);
      fu := func(u);
      IF (fu <= fx)  THEN BEGIN
         IF (u >= x)  THEN a := x ELSE b := x;
         v := w;
         fv := fw;
         w := x;
         fw := fx;
         x := u;
         fx := fu
      END ELSE BEGIN
         IF (u < x)  THEN a := u ELSE b := u;
         IF ((fu <= fw) OR (w = x))  THEN BEGIN
            v := w;
            fv := fw;
            w := u;
            fw := fu
         END ELSE IF ((fu <= fv) OR (v = x) OR (v = 2)) THEN BEGIN
            v := u;
            fv := fu
         END
      END
   END;
3:   xmin := x;
   brent := fx
END;

{----------------------------------------------------------------------}

PROCEDURE linmin(VAR p, xi: PowellVector; n: integer; VAR fret: real);
CONST
   tol=1.0e-4;
VAR
   j: integer;
   xx,xmin,fx,fb,fa,bx,ax: real;
BEGIN
   Powellncom := n;
   FOR j := 1 to n DO BEGIN
      Powellpcom[j]  := p[j];
      Powellxicom[j] := xi[j]
   END;
   ax := 0.0;
   xx := 1.0*PowellLinminstep;
   bx := 2.0*PowellLinminstep;
   mnbrak(ax,xx,bx,fa,fx,fb);
   fret := brent(ax,xx,bx,tol,xmin);
   FOR j := 1 to n DO BEGIN
      xi[j] := xmin*xi[j];
      p[j] := p[j]+xi[j]
   END
END;

{----------------------------------------------------------------------}

PROCEDURE powell(VAR p: PowellVector; n: integer; ftol: real; myfunc: Powellfunction);
LABEL 1,99;
{CONST
   itmax=200;
}
VAR
   j,ibig,i,iter: integer;
   t,fptt,fp,del,fret: real;
   pt,ptt,xit: PowellVector;
   xi: PowellMatrix;


BEGIN

//  assign(powdiag,'powdiag.txt');
//  rewrite(powdiag);
   PowellBreakMN:=False;
   PowellBreak  :=False;
   PowellFNC    :=myfunc;

// added: initialization of direction matrix
   for i:=1 to Powellncom do begin
     for j:=1 to Powellncom do xi[i,j]:=0.0;
     xi[i,i]:=1.0;
   end;

   fret := PowellFNC(p);
   FOR j := 1 to n DO BEGIN
      pt[j] := p[j]
   END;
   iter := 0;
1:   iter := iter+1;
   fp := fret;
   ibig := 0;
   del := 0.0;
   FOR i := 1 to n DO BEGIN
      FOR j := 1 to n DO BEGIN
         xit[j] := xi[j,i]
      END;
      linmin(p,xit,n,fret);
      if PowellBreak then goto 99;
      IF (abs(fp-fret) > del) THEN BEGIN
         del := abs(fp-fret);
         ibig := i
      END
   END;
   IF (2.0*abs(fp-fret) <= ftol*(abs(fp)+abs(fret))) THEN GOTO 99;
   FOR j := 1 to n DO BEGIN
      ptt[j] := 2.0*p[j]-pt[j];
      xit[j] := p[j]-pt[j];
      pt[j] := p[j]
   END;
   fptt := PowellFNC(ptt);
   IF (fptt >= fp) THEN GOTO 1;
   t := 2.0*(fp-2.0*fret+fptt)*sqr(fp-fret-del)-del*sqr(fp-fptt);
   IF (t >= 0.0) THEN GOTO 1;
   linmin(p,xit,n,fret);
   FOR j := 1 to n DO BEGIN
      xi[j,ibig] := xit[j]
   END;
   if PowellBreak then Goto 99;
   GOTO 1;
99:
//  close(powdiag);
  END;

{========================================================================}



end.
