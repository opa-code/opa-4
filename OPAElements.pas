{to do (Apr.2022)
  - phase advance in mode flip to be calculated and implemented !
    Presently tunes are wrong with mode flip.
  - improve manangement of modeflips (MF_save variable)
  - remove propagation of amat, bmat periodic matrices, was implemented only for diagnostics
  - check path length calculation, seems there are deviations from tracy/elegant
  - complete Solenoid procedure
}


unit OPAElements;

//{$MODE Delphi}

INTERFACE

uses OPAglobal, MathLib, sysutils;

Function SigNfromBeta(b, a: real): Matrix_2;
//function DRtoDN (dr: vektor_4; c: matrix_2; g: real): vektor_4;
//function DNtoDS (dn: vektor_4; sa,sb: matrix_2): vektor_4;

//procedure MisAlign (var OV: Vektor_4; phi, dx, dy, roll: real; mode, inot: shortint);
//procedure PhaseAdvance (sa1, sb1, sa2, sb2, e12, f12: Matrix_2);
//function getdTune (tm: matrix_5; sa, sb: matrix_2): vektor_2;
//Procedure MCC_prop (tmT: Matrix_5; var siga, sigb, CC: Matrix_2; var D: Vektor_4; gettune: boolean );
//Procedure MBD_prop (tmT: Matrix_5; var siga, sigb, CC: Matrix_2; var D {,O} : Vektor_4; gettune:boolean );

//procedure Propagate (TM: Matrix_5; mode: integer; coupflag: boolean);
//procedure PropForward;
//function Pathlength(l, h0, k0, d: real): double;

function Rotation_Matrix (ang: real): Matrix_5;
//function Drift_Matrix(l: real): Matrix_5;
//function Quad_Matrix(l, k: real): Matrix_5;
//function Sol_Matrix(l, k: real): Matrix_5;
//function Sector_Matrix(l, h, k: real): Matrix_5;
//function EdgeKick_Matrix(h, t, g, k1, k2: real): Matrix_5;
//function Bend_Matrix (l, h, k, tin, tex, g, k1in, k1ex, k2in, k2ex: real): Matrix_5;

//procedure UnduPolFacs (var polfac: array of real; half: boolean; idir: shortint);
procedure XBwrite      ( elemName: ElemStr; snap:integer; mode: shortint);


//procedure OpReadN (Op: OpvalType; var siga, sigb, cc, amat, bmat: Matrix_2; var D, O: Vektor_4);
//procedure OpWriteN (var Op: OpvalType; siga, sigb, cc, amat, bmat: Matrix_2; D, O: Vektor_4; s:real);
procedure OpPrintDiag (Op: OpvalType);
//procedure Tmat(M: matrix_5; Elen: double);
//procedure Tmat0(M0: matrix_5);
//procedure MisVector(M: matrix_5; dx, dy: real; mode:shortint);


//function SliceSet (Op: OpvalType; l: real;  var soff, ds: real; var np: integer): boolean;
//Procedure SlicingN (var Op: OpvalType; min, mof, msl, mex, mof0, msl0: Matrix_5; soff, ds, dpp: real; coup: boolean; np: integer);
//Procedure SkippingN (var Op: OpvalType; msk, msk0: Matrix_5; sskip, dpp: real; coup: boolean);
procedure SliceDriftN (var Opi, Opo: OpvalType; l: real; uflag: shortint);
procedure SliceQuadN  (var Opi, Opo: OpvalType; l, k0, rot, d: real);
procedure SliceSolN   (var Opi, Opo: OpvalType; l, k0, d: real);
procedure SliceBendN  (var Opi, Opo: OpvalType; l, phi, k0, tin0, tex0, g,
                       k1in0, k1ex0, k2in0, k2ex0, rot, d : real; idir, uflag: shortint);
Procedure SliceUnduN  (var Opi, Opo: OpvalType; l, B, lam0, gap, fill1, fill2, fill3, rot, d : real; half: boolean; idir:shortint);
Procedure SliceSextN  (var Opi, Opo: OpvalType; l, m, d: real; nsl: shortint );
Procedure SliceCombN  (var Opi, Opo: OpvalType; l, phi, t1, t2, k11, k12, gap, k, m, rot, d : real;
                       nsl, idir : shortint );

procedure Rotation     (ang: real; idir, mode: shortint);
procedure DriftSpace   ( l: real; mode:shortint );
procedure Quadrupole   (l, k0, rot, d: real; idir, mode: shortint; sway, heave, roll: real);
procedure Solenoid     (l, k0, d: real; idir, mode: shortint; sway, heave, roll: real );
procedure Bending      (L, phi, k0, tin, tex, g, k1in, k1ex, k2in, k2ex, rot, d : real; idir, mode: shortint; sway, heave, roll: real );
procedure Combined     (l, phi, t1, t2, k11, k12, gap, k, m, rot, d : real; nsl, idir, mode: shortint ; sway, heave, roll: real);
procedure ThinSextupole (ml0, d : real; mode: shortint);
procedure Sextupole    (l, m_ml, rot, d : real; nkick, idir, mode: shortint; sway, heave, roll: real);
procedure Multipole    (nord: integer; bnl0, rot, d : real; idir, mode: shortint; sway, heave, roll: real );
procedure Kicker       (l, rot: real; mpol, nkick: integer; kickmax, xoffset, tau, delay, time, d: real; mode: shortint; sway, heave, roll: real);
procedure HCorr(b1l, d: real; idir, mode: shortint; rot, sway, heave, roll: real );
procedure VCorr(a1l, d: real; idir, mode: shortint; rot, sway, heave, roll: real );
procedure Monitor(idir, mode: shortint; rot, sway, heave, roll: real);
procedure Undulator    ( l, B, lam0, gap, fill1, fill2, fill3, rot, d: real; idir, mode: shortint; half: boolean; sway, heave, roll: real );



IMPLEMENTATION

const
  OrbMinHeave=1E-6; //tolerate one micron vertical orbit before considering coupling
  crlf=#13#10; //carriage return and  linefeed

var
  soffset, dslice: real;
  nslice: integer;

  mf_calling:integer; //test only
  smess: string; //message string


{==============================================================================}
function f93(x: real):string;
begin
  f93:=' '+FloatToStrF(x,fffixed,9,3)+' ';
end;

{ Beam transformation routines ------------------------------------------------}
function SigNfromBeta(b, a: real): Matrix_2;
var
  s: matrix_2;
begin
  s[1,1]:=b;
  s[1,2]:=-a; s[2,1]:=s[1,2];
  s[2,2]:=(1+Sqr(a))/b;
  SigNfromBeta:=s;
end;


{------------------------------------------------------------------------------}

procedure GetBeta12 (var bxa, bxb, bya, byb: real; siga, sigb, cc: matrix_2);
// get projections of NM betas to x,y space, see sagan/rubin eq.56 etc.
// we use C instead of \bar(C)
var
  ba, bb, aa, ab, gam2: double;
begin
  ba:=siga[1,1]; bb:=sigb[1,1];  aa:=-siga[1,2];  ab:=-sigb[1,2];
  gam2:=1-MatDet2(cc);
  bxa:=gam2*ba;
  byb:=gam2*bb;
  bxb:=bb*(sqr(cc[1,1]-cc[1,2]*ab/bb) + sqr(cc[1,2]/bb));
  bya:=ba*(sqr(cc[2,2]+cc[1,2]*aa/ba) + sqr(cc[1,2]/ba));
end;


function CirMat (sa: matrix_2): matrix_2;
// set up matrix A for trafo to normalized coordinates
var
  sq: double; a: matrix_2;
begin
  sq:=sqrt(sa[1,1]);
  a :=matset2(1./sq,0,-sa[1,2]/sq,sq);
  Cirmat:=a;
end;


{------------------------------------------------------------------------------}

function DRtoDN (dr: vektor_4; c: matrix_2; g: real): vektor_4;
// get normal mode dispersion from real DN = T*DR
var
  dn: vektor_4;
begin
  dn[1]:=g*dr[1]-c[1,1]*dr[3]-c[1,2]*dr[4];
  dn[2]:=g*dr[2]-c[2,1]*dr[3]-c[2,2]*dr[4];
  dn[3]:=g*dr[3]+c[2,2]*dr[1]-c[1,2]*dr[2];
  dn[4]:=g*dr[4]-c[2,1]*dr[1]+c[1,1]*dr[2];
  DRtoDN:=dn;
end;

{------------------------------------------------------------------------------}

function DNtoDS (dn: vektor_4; sa,sb: matrix_2): vektor_4;
// get normalized NM disp (DS) from normal mode: DS = A*DN
var
  ds: vektor_4;
  sq, al: real;
begin
  sq:=sqrt(sa[1,1]);  al:=-sa[1,2];
  ds[1]:=dn[1]/sq;
  ds[2]:=dn[1]*al/sq+dn[2]*sq;
  sq:=sqrt(sb[1,1]);  al:=-sb[1,2];
  ds[3]:=dn[3]/sq;
  ds[4]:=dn[3]*al/sq+dn[4]*sq;
  DNtoDS:=ds;

  {alternative
  cm:=CirMat(sa);
  ds[1]:=dn[1]*cm[1,1];
  ds[2]:=dn[1]*cm[2,1]+dn[2]*cm[2,2];
  cm:=CirMat(sb);
  ds[3]:=dn[3]*cm[1,1];
  ds[4]:=dn[3]*cm[2,1]+dn[4]*cm[2,2];
  DNtoDS:=ds;
}

end;

{------------------------------------------------------------------------------}

procedure MisAlign (var OV: Vektor_4; phi, dx, dy, roll: real; mode, inot: shortint);
// shift orbit vector when entering/leaving misaligned element
// inot +1 in, -1 out, 0 do nothing
var
  O: Vektor_4;
begin
  if switch(mode,do_misal) then begin
    OV[2]:=OV[2]+inot*sin(phi/2);
    O[1]:=OV[1]-inot*(OV[3]*roll+dx);
    O[2]:=OV[2]-inot* OV[4]*roll;
    O[3]:=OV[3]+inot*(OV[1]*roll-dy);
    O[4]:=OV[4]+inot* OV[2]*roll;
    OV:=O;
    OV[2]:=OV[2]-inot*sin(phi/2);   //?

  end;
end;

{------------------------------------------------------------------------------}

function PhaseAdvance (sa1, sb1, sa2, sb2, e12, f12: Matrix_2): vektor_2;
var
  ga1i, gb1i, ga2, gb2, oa12, ob12: matrix_2;

  function getdQ (m: matrix_2): double;
  var dQ: double;
  begin
    dQ    := arccos(MatTra2(m)/2)/2/Pi;
    if m[1,2]<0 then dQ:=-dQ;
    getdQ:=dQ;
  end;

begin
{not necessary to have extra routine for uncoupled, because the general one
 always is correct for uncoupled too. However may be slower.}

// get the normal tunes matrix for phase advance
// W12 = V2-1 M12 V1  = G2-1 O G1   --> O = G2 W12 G1-1
// 2x2 calc since W12 =(E12 0 | 0 F12)is block diag (not flipped)
  ga1i:=matsyc2(CirMat(sa1));
  gb1i:=matsyc2(CirMat(sb1));
  ga2 :=        CirMat(sa2) ;
  gb2 :=        CirMat(sb2) ;
//works only without modeflip. How to do with ???
  oa12:=matmul2(ga2,matmul2(e12,ga1i));
  ob12:=matmul2(gb2,matmul2(f12,gb1i));
  PhaseAdvance[1]:=getdQ(oa12);
  PhaseAdvance[2]:=getdQ(ob12);
end;

{------------------------------------------------------------------------------}

function getdTune (tm: matrix_5; sa, sb: matrix_2): vektor_2;
// get tune advances from blockdiag matrix
var
  mm, nn, saT, sbT: Matrix_2;
begin
  mm:=MatCut52(tm,1,1);
  nn:=MatCut52(tm,3,3);
  SaT:=MatSig2(mm, sa);
  SbT:=MatSig2(nn, sb);
  getdTune:=PhaseAdvance (sa, sb, saT, sbT, mm, nn);
end;

{------------------------------------------------------------------------------}
{
  get the flipped solution in place, see appendix B in S&R
  however for propagation not useful:
  if we see that g2<0 in NEXT step, we try to switch to flipped solution g1f, but it
  may not exist. Propagation has to zig-zag through a series of modeflips.
  abandoned. 9.11.2021

Procedure FlipModes (var siga, sigb, CC: matrix_2; var arg, g1: double; mm,nn, m, n: matrix_2);
var
  sigaf, sigbf, ccf: matrix_2;
  tmp, argf, g1f: double;
    dQ: vektor_2;
begin
  if g1<1 then begin
    writeln('<<<< FlipModes with g1<1');
    g1f:=sqrt(1-sqr(g1));         //eq.B1
    CCf:=matsca2(-g1/g1f,CC);
    writeln('check for 2nd solution g1 =',g1:9:3,' --> flip solution g1f =',g1f:9:3);
//    writeln('orig betas = ', siga[1,1]:10:3, sigb[1,1]:10:3);
    argf := MatDet2(MatAdd2(MatMul2(n,CCf),MatSca2(g1f,nn))); // = g2^2, Eq.27
    if argf>0 then begin
      sigaf:=matsig2(matsca2(1./g1f,        CC ), sigb);
      sigbf:=matsig2(matsca2(1./g1f,matsyc2(CC)), siga);
//      writeln('flip betas = ', sigaf[1,1]:10:3, sigbf[1,1]:10:3);
      writeln('g2f prediction = ', sqrt(argf):10:4);

      // is there a tune shift in mode flip ?  formally, treating CC like a normal trasfer matrix (bullshit?):
//        dQ:=PhaseAdvance (sigb, siga, sigaf, sigbf, matsca2(1./g1f,   CC ), matsca2(1./g1f,matsyc2(CC)) );
//        writeln('tune advances in mode flip =', dQ[1], dQ[2]);
//        Beam.Qa:=Beam.Qa+dQ[1];  Beam.Qb:=Beam.Qa+dQ[2];

      siga:=sigaf;
      sigb:=sigbf;
      cc:=ccf;
      arg:=argf;
      g1:=g1f;
      ModeFlip:=not ModeFlip;
//exchange tunes (and all integrals ?)
//      tmp:=Beam.Qa; Beam.Qa:=Beam.Qb; Beam.Qb:=tmp;
      writeln('FlipModes done at s =',sposel:8:3,' : g1new =', g1:9:3, '     call ',mf_calling);
      setlength(MF_save, length(MF_save)+1);
      with MF_save[high(MF_save)] do begin spos:=SposEl; act:=1; end;

    end else begin
      writeln ('**** FlipMode fail: 2nd solution does not exist g2f^2 =', argf:10:4);
      writeln ('***  proceed with WRONG g1 =', g1:9:3, ' call ',mf_calling);
    end;
  end else begin
    writeln('>>>> FlipModes with g1>1 at s =',sposel:8:3,' : cannot flip here, g1 =', g1:9:3, ' call ',mf_calling);
    setlength(MF_save, length(MF_save)+1);
    with MF_save[high(MF_save)] do begin spos:=SposEl; act:=2; end;
  end;
end;
}

Procedure MCC_prop (tmT: Matrix_5; var siga, sigb, CC, AM, BM: Matrix_2; var D: Vektor_4; gettune: boolean );
{ propagation through coupling element, with general non-block-diag matrix}
{
  Handling of "mode flip":
    if predicted new g = 1-|C| <0 we HAVE to do the flip in any case.
    If not, but we already are in flip mode (i.e. x~b), we try to get back to standard mode (x~a).
    If this fails, we continue flipped.
    If it suceeds, but the propagation again leads to arg<0, we have to undo the backflip
      and proceed further with flipped solutions.
  Modeflips happen easily at explicit rotation. Problem mitigated by including Rot
    in element instead of explicit rot, (e.g. skew quad in three elements, +Rot Q -Rot,
    caused the problem but taking a matrix M = +R Q -R works.)
}

var
  arg, argf, g1, gT, cdet: double;
  AMT, BMT, sigat, sigbt, mm, m, n, nn, e1T, f1T, CCT: matrix_2;
  DT : Vektor_4;
  dQ: vektor_2;
  FlipNow, FlipPref: boolean;

begin
//  FlipPref:=false; // prefer to flip if possible
  FlipPref:=modeflip;
//  FlipPref:=modeflip xor ExchangeModes; // prefer to flip if possible ?X?

  mm:=MatCut52(tmT,1,1);
  nn:=MatCut52(tmT,3,3);
  m :=MatCut52(tmT,1,3);
  n :=MatCut52(tmT,3,1);
  cdet:=MatDet2(CC);
  //removed check on cdet, because cdet came from previous element and either did
  // not change (no coupling) or was tested there already (coupling)
  g1:=sqrt(1-cdet);

// check if new g is real, otherwise mode flip.
// Eqs. from Sagan & Rubin PRSTAB 074001(1999)
  arg := MatDet2(MatAdd2(MatMul2(n,CC),MatSca2(g1,nn))); // = g2^2, Eq.27

  FlipNow:=(arg <0) or FlipPref;

// as long as we have no intentioanl flip, this block should have no effect,
// because argf has to exist
  if FlipNow then begin
    smess:= ' prepare for modeflip at'+f93(sposel);
    if FlipPref then smess:=smess+ 'because we WANT to flip back now.'+crlf;
    if arg<0 then smess:=smess+'- because g2^2 became negative.'+crlf;
    argf := MatDet2(MatAdd2(MatMul2(mm,CC),MatSca2(g1,m))); // eq.37
    smess:=smess+'g1, arg, argf ='+f93(g1)+f93(arg)+f93(argf)+crlf;
    // take the other mode - if it doesn't exist, cancel the Flip
    // ONE mode HAS to exist, so if we came from here due to arg<0 then argf must exist
    // if we came here in order to flip back, arg has to exist, if not, we can't flip back
    if argf <0 then begin
       FlipNow :=false;
       smess:=smess+' --> cannot flip back here!';
    end
    else begin
       arg:=argf;
       smess:=smess+' --> can flip back! g1f ='+f93(arg);
    end;
    // so, either ct'n flip with new argf or don't and use old arg
    OpaLog(-2,smess);
  end;

  if FlipNow then begin
    gt:=sqrt(arg);
    e1T :=MatSca2(1./gt, MatSub2( MatSca2(g1,n),MatMul2(nn,MatSyc2(CC)))); // eq.38
    f1T :=MatSca2(1./gt, MatAdd2( MatSca2(g1,m),MatMul2(mm,        CC ))); // eq.39
    CCT :=MatMul2(MatSub2(MatSca2(g1,mm),MatMul2( m,MatSyc2(CC))),MatSyc2(e1T)); // eq.40
    SigbT:=MatSig2(e1T,siga);
    SigaT:=MatSig2(f1T,sigb);

    modeflip:=not Modeflip;

// gives correct fractional tunes but not integer: 25.4.2022
     if gettune then begin
      dQ:=PhaseAdvance (siga, sigb, sigbT, sigaT, e1T, f1T);
      if modeflip then begin
         Beam.Qa:=Beam.Qa+dQ[1];     Beam.Qb:=Beam.Qb+dQ[2];
       end else begin
//         if dQ[1]<0 then dQ[1]:=dQ[1]+1; //empirical, does not always work
         Beam.Qa:=Beam.Qa+dQ[2];      Beam.Qb:=Beam.Qb+dQ[1];
      end;
    end else begin
      dQ[1]:=0; dQ[2]:=0;
    end;
    BMT :=MatMul2(e1t, MatMul2(AM, MatSyc2(e1t)));
    AMT :=MatMul2(f1t, MatMul2(BM, MatSyc2(f1t)));

    setlength(MF_save, length(MF_save)+1);
    with MF_save[high(MF_save)] do begin
       spos:=SposEl;
         if modeflip then begin
         act:=1;
         opalog(-3,'mode flip at '+f93(spos)+'mfcall '+inttostr(mf_calling));
         if gettune then opalog(-1,'mode flip: dQ ='+f93(dq[1])+f93(dq[2]));
       end else begin
         act:=2;
         opalog(-3,'back flip at '+f93(spos)+'mfcall '+inttostr(mf_calling));
         if gettune then opalog(-1,'back flip: dQ ='+f93(dq[1])+f93(dq[2]));
       end;
       if not gettune then act:=act+2; //1,2 to indicate true MF (skew quad may do temp)
       if mf_calling>100 then act:=act+10;
    end;
  end

  else if arg>0 then begin // propagation without flip - this is the normal case and works well.
    gt:=sqrt(arg);
    e1T :=MatSca2(1./gT, MatSub2( MatSca2(g1,mm),MatMul2(m,MatSyc2(CC)))); //eq.28
    f1T :=MatSca2(1./gT, MatAdd2( MatSca2(g1,nn),MatMul2(n,        CC )));// eq.29
    CCT :=MatMul2(MatAdd2( MatSca2(g1,m), MatMul2(mm,CC)),MatSyc2(f1T)); //eq.30
    SigaT:=MatSig2(e1T,siga);
    SigbT:=MatSig2(f1T,sigb);
    AMT:=MatMul2(e1t, MatMul2(AM, MatSyc2(e1t)));
    BMT:=MatMul2(f1t, MatMul2(BM, MatSyc2(f1t)));

    if gettune then begin
      dQ:=PhaseAdvance (siga, sigb, sigaT, sigbT, e1T, f1T);
      if modeflip then begin
         Beam.Qa:=Beam.Qa+dQ[2];      Beam.Qb:=Beam.Qb+dQ[1];
       end else begin
         Beam.Qa:=Beam.Qa+dQ[1];      Beam.Qb:=Beam.Qb+dQ[2];
      end;
    end;

  end else opaLog(1,'No solution for g: arg ='+f93(arg)); //cannot happen (?)

  DT :=LinTra54(tmt,D,1);
  siga:=sigaT; sigb:=sigbT; D:=DT; CC:=CCT; AM:=AMT; BM:=BMT;
end;

{------------------------------------------------------------------------------}



Procedure MBD_prop (tmT: Matrix_5; var siga, sigb, CC, AM, BM: Matrix_2; var D {,O} : Vektor_4; gettune:boolean );
// transformations from block-diag matrix
var
  mm, nn, sigaT, sigbT, CCT, AMT, BMT: Matrix_2;
  DT {,OT}: Vektor_4;
  dQ: vektor_2;

begin
  mm:=MatCut52(tmT,1,1);
  nn:=MatCut52(tmT,3,3);

 // flipnow:=false;
  //next: if modeflip then "try" to flip again --> write extra proc to flip if needed, even in MDB_prop

  {no, modes are never forced to flip in BD element, also integrals dont switch.
  Therefore introduce extra rotation
  or use end of lattice for backflip}

{  if modeflip then begin
    // we are in flip mode and want to come back to normal
    g1 :=sqrt(1-matdet2(CC));
    arg:= sqr(g1); //=sqr(g2) can't change without coupling;
    m:=matnul2; n:=m;
    FlipModes(siga, sigb, CC, arg, g1, mm, nn, m, n);
    //don't need arg, g1; g1 should now be g1f
  end;
}

  CCT:=MatMul2(mm,MatMul2(CC, MatSyc2(nn)));
// since mm, nn symplectic, det(CC) cannot change and g neither --> test deleted as-1.2.18
  SigaT:=MatSig2(mm, siga);
  SigbT:=MatSig2(nn, sigb);
  DT:=LinTra54(tmT,D,1);
  if gettune then begin
     dQ:=PhaseAdvance (siga, sigb, sigaT, sigbT, mm, nn);
     if modeflip then begin
       Beam.Qa:=Beam.Qa+dQ[2];      Beam.Qb:=Beam.Qb+dQ[1];
     end else begin
       Beam.Qa:=Beam.Qa+dQ[1];      Beam.Qb:=Beam.Qb+dQ[2];
     end;
{
     writeln('incr tu_BD  ', dq[1]:10:5, ' ', dq[2]:10:5);
     writeln('accu tu_BD  ', beam.qa:10:5, ' ', beam.qb:10:5); writeln;
}
  end;
  AMT:=MatMul2(mm, MatMul2(AM, MatSyc2(mm)));
  BMT:=MatMul2(nn, MatMul2(BM, MatSyc2(nn)));
  siga:=sigaT; sigb:=sigbT; D:=DT; CC:=CCT;
  AM:=AMT; BM:=BMT;
end;

{------------------------------------------------------------------------------}

procedure Propagate (TM: Matrix_5; mode: integer; coupflag: boolean);
//propagate normal mode betas, dispersion, coupling matrix and gamma
begin
  if switch(mode,do_twiss) then begin
    SigNa2:=sigNa1;  SigNb2:=SigNb1; Disper2:=Disper1; {Orbit2:=Orbit1;} CoupMatrix2:=CoupMatrix1;
    if coupflag then begin
      MCC_prop (tm, SigNa2, SigNb2, CoupMatrix2, AMat2, BMat2, Disper2, true);
    end else begin
      MBD_prop (tm, SigNa2, SigNb2, CoupMatrix2, AMat2, BMat2, Disper2, true);
    end;
  end;
end;

{------------------------------------------------------------------------------}

procedure PropForward;
// 2 --> 1
begin
  SigNa1:=SigNa2;
  SigNb1:=SigNb2;
  CoupMatrix1:=CoupMatrix2;
  Disper1:=Disper2;
  Orbit1:=Orbit2;
  AMat1:=AMat2;
  BMat1:=BMat2;
end;

{------------------------------------------------------------------------------}

function Pathlength(l, h0, k0, d: real): double;
{calculation of pathlength relativ to ref orbit in 1+2.order

  L  =  int [ sqrt( x'(s)^2 + y'(s)^2 + (1+hx)^2 ) ] ds
  dL = L-Lo ~ int [ hx + 1/2 * ( x'(s)^2 + y'(s)^2 + (hx)^2) ] ds

  correct in 2.order:
  dL = L-Lo ~ int [ hx + 1/2 * ( x'(s)^2 + y'(s)^2) ] ds


  x  = C xo + S xo' + D *dpp
  x' = C'xo + S'xo' + D'*dpp

input:
  element length l
  curvature h0
  gradient k0 = b2
  delta P/P  d

  nomenclature different than transport: 5<->6 exchanged
  here: x, x', y, y', dpp, path
}

var
  h, k, kx, kb2, kx2, ky, ky2, kxl, kyl,
    x0, xp0, y0, yp0, r61, r62, r65,
    t611, t622, t612, t655, t615, t625, t633, t644, t634,
    h02, {h3,h4,} l2,l3,{l4,l5,} kx3, si,si2, co : real;
  v: integer;
  pathx1, pathx2, pathd2, pathy2:real;
begin
  x0:=Orbit1[1]; xp0:=Orbit1[2]; y0:=Orbit1[3]; yp0:=Orbit1[4];

  h:= h0/(1+d);
 {use h0 for the dispersion but h for the focussing! 281010}

  k:=k0/(1+d);
  kb2:=sqr(h)+k; //ok for h=0 too
  ky2:=-k;
  kx:=sqrt(abs(kb2)); kxl:=kx*l;
  ky:=sqrt(abs(ky2)); kyl:=ky*l;

  r61 :=0; r62 :=0; r65 :=0;
  t611:=0; t622:=0; t612:=0; t615:=0; t625:=0; t655:=0;
  t633:=0; t644:=0; t634:=0;

  h02:=sqr(h0); {h3:=h*h2; h4:=h*h3;} // sign of h powers?
//horizontal
  if abs(kb2)<1e-7  then begin
    t622:=l/2;
    if h0<>0 then begin
      l2:=l*l; l3:=l*l2; {l4:=l*l3; l5:=l*l4;}
{     r65 := h2*l3/6;
      t615:= h3*l3/6;
      t625:= h*l2/2+h3*l4/8;
      t655:= h2*l3/6+h4*l5/40;
      t611:= h2*l/2;
      t622:= t622+h2*l3/6;
      t612:= h2*l2/2;
}
      r65 := h02*l3/6;
      t625:= h0*l2/2;
      t655:= h02*l3/6;

    end;
  end else begin
    kx2:=sqr(kx); kx3:=kx*kx2; {kx4:=kx*kx3; kx5:=kx*kx4;}
    if kb2>0 then begin //trig.
      si:=sin (kxl); si2:=sin (2*kxl); co:=cos (kxl); v:= 1;
    end else begin //hyp
      si:=sinh(kxl); si2:=sinh(2*kxl); co:=cosh(kxl); v:=-1;
    end;
    t611:=v*kx/8*(2*kxl-si2);
    t622:=(2*kxl+si2)/(8*kx);
    t612:=-v*sqr(si)/2;
{
    if h<>0 then begin
      r61 :=h/kx*si;
      r62 :=v*h/kx2*(1-co);
      r65 :=v*h2/kx3*(kxl-si);
      t615:=h*(-2*kxl+si2)/(4*kx)-v*h3*(2*kxl-4*si+si2)/(4*kx3);
      t625:=h*sqr(si)/(2*kx2)+2*h3*powi(sih,4)/kx4;
      t655:=-v*h2*(-2*kxl+si2)/(8*kx3)+h4*(6*kxl-8*si+si2)/(8*kx5);
      t611:=t611+h2*(2*kxl+si2)/(8*kx);
      t622:=t622-v*h2*(-2*kxl+si2)/(8*kx3);
      t612:=t612+h2*sqr(si)/(2*kx2);
    end;
}
    if h0<>0 then begin
      r61 :=h0/kx*si;
      r62 :=v*h0/kx2*(1-co);
      r65 :=v*h02/kx3*(kxl-si);
      t615:=h0*(-2*kxl+si2)/(4*kx);
      t625:=h0*sqr(si)/(2*kx2);
      t655:=-v*h02*(-2*kxl+si2)/(8*kx3);
    end;

  end;

//vertical: h==0
  if abs(ky2)<1e-7 then begin
    t644:=l/2;
  end else begin
    if ky2>0 then begin //trig.
      si:=sin (kyl); si2:=sin (2*kyl); v:= 1;
    end else begin //hyp.
      si:=sinh(kyl); si2:=sinh(2*kyl); v:=-1;
    end;
    t633:=v*ky/8*(2*kyl-si2);
    t644:=(2*kyl+si2)/(8*ky);
    t634:=-v*sqr(si)/2;
  end;

// transformation
  pathx1:= x0*r61 + xp0*r62 + d*r65;
  pathx2:= x0*x0*t611 + xp0*xp0*t622 + x0*xp0*t612;
  pathd2:= x0*d *t615 + xp0* d *t625 +  d* d *t655;
  pathy2:= y0*y0*t633 + yp0*yp0*t644 + y0*yp0*t634;
  pathlength:=pathx1+pathx2+pathd2+pathy2;
{
writeln(diagfil,'R ', r61, r62, r65, ' -> ',pathx1);
writeln(diagfil,'T ',t611,t622,t612, ' -> ',pathx2);
writeln(diagfil,'T ',t615,t625,t655, ' -> ',pathd2);
writeln(diagfil,'T ',t633,t644,t634, ' -> ',pathy2);
writeln(diagfil,'X ',x0,xp0,y0,yp0,d);
writeln(diagfil,'P ',pathx1+pathx2+pathd2+pathy2);
writeln(diagfil);
}
end;


{==============================================================================}
{ Transfer matrices -----------------------------------------------------------}

function Rotation_Matrix (ang: real): Matrix_5;
{ rotation of x/y plane
  counterclockwise around s (forward vector), i.e. 90 deg makes x --> y, y--> -x
  or radial out --> up, up --> radial in
  90 deg rotated dipole (of pos angle) bends beam UP
  as 14.4.2016
}
var
  Co, Si: real; R: Matrix_5;
begin
  R:=Unit_Matrix_5;
  if abs(ang)>1e-12 then begin
    Co:=Cos(ang); Si:=Sin(ang);
    R[1,1]:= Co;              R[1,3]:= Si;
                 R[2,2]:= Co;              R[2,4]:= Si;
    R[3,1]:=-Si;              R[3,3]:= Co;
                 R[4,2]:=-Si;              R[4,4]:= Co;
  end;
  Rotation_Matrix:=R;
end;

{------------------------------------------------------------------------------}

function Drift_Matrix(l: real): Matrix_5;
var
  m: Matrix_5;
begin
  m:=Unit_Matrix_5;
  m[1,2]:=l;
  m[3,4]:=l;
  Drift_Matrix:=m;
end;

{------------------------------------------------------------------------------}

function Quad_Matrix(l, k: real): Matrix_5;
var
  a, b, Co, Si, Ch, Sh: real;
  m: Matrix_5;
begin
  if k=0 then m:=Drift_Matrix(l) else begin
    a:=Sqrt(Abs(k)); b:=a*l;
    Co:=Cos(b); Si:=Sin(b);
    Ch:=cosh(b); Sh:=sinh(b);
    m:=Unit_Matrix_5;
    if k>0 then begin
      m[1,1]:= Co;   m[1,2]:= Si/a;
      m[2,1]:=-Si*a; m[2,2]:= Co;
      m[3,3]:= Ch;   m[3,4]:= Sh/a;
      m[4,3]:= Sh*a; m[4,4]:= Ch;
    end else begin
      m[1,1]:= Ch;   m[1,2]:= Sh/a;
      m[2,1]:= Sh*a; m[2,2]:= Ch;
      m[3,3]:= Co;   m[3,4]:= Si/a;
      m[4,3]:=-Si*a; m[4,4]:= Co;
    end;
  end;
  Quad_Matrix:=m;
end;

{------------------------------------------------------------------------------}

function Sol_Matrix(l, k: real): Matrix_5;
var
  m: Matrix_5;
  b, c, s, cc, ss, sc: double;
//  dum: boolean; minv: matrix_5;
begin
  if abs(k) < 1e-12 then m:=Drift_Matrix(l) else begin
    m:=Unit_Matrix_5;
    b:=k*l;
    c:=cos(b); s:=sin(b); cc:=sqr(c); ss:=sqr(s); sc:=s*c;
    m[1,1]:= cc;    m[1,2]:= sc/k;  m[1,3]:=-sc;    m[1,4]:=-ss/k;
    m[2,1]:=-sc*k;  m[2,2]:= cc;    m[2,3]:= ss*k;  m[2,4]:=-sc;
    m[3,1]:= sc;    m[3,2]:= ss/k;  m[3,3]:= cc;    m[3,4]:= sc/k;
    m[4,1]:=-ss*k;  m[4,2]:= sc;    m[4,3]:=-sc*k;  m[4,4]:= cc;
  end;
  Sol_Matrix:=m;
end;

{------------------------------------------------------------------------------}

function Sector_Matrix(l, h, k, KB: real): Matrix_5;
var
  m: Matrix_5;
  a, b, Co, Si: real;
begin
  if abs(h)<1e-8 then m:=Quad_Matrix(l,k) else begin
    m:=Unit_Matrix_5;
//    KB:=h*h+k;
    a:=Sqrt(Abs(KB)); b:=a*l;
    if Abs(KB)<1E-7 then begin
      m[1,2]:=l;
      m[1,5]:=h*sqr(l)/2;
      m[2,5]:=h*l;
    end else begin
      if KB<0 then begin
        Co:=cosh(b); Si:=sinh(b);
        m[1,1]:=Co; m[1,2]:=Si/a; m[2,1]:= a*Si; m[2,2]:=Co;
        m[1,5]:=-h*(1-Co)/sqr(a); m[2,5]:=h*Si/a;
      end else begin
        Co:=Cos(b); Si:=Sin(b);
        m[1,1]:=Co; m[1,2]:=Si/a; m[2,1]:=-a*Si; m[2,2]:=Co;
        m[1,5]:=h*(1-Co)/sqr(a);  m[2,5]:=h*Si/a;
      end;
    end;
    a:=Sqrt(Abs(k)); b:=a*l;
    if k=0 then  begin
      m[3,4]:=l;
    end else if k<0 then begin
      Co:=Cos(b); Si:=Sin(b);
      m[3,3]:=Co; m[3,4]:=Si/a; m[4,3]:=-a*Si; m[4,4]:=Co;
    end else begin
      Co:=cosh(b); Si:=sinh(b);
      m[3,3]:=Co; m[3,4]:=Si/a; m[4,3]:= a*Si; m[4,4]:=Co;
    end;
  end;
  Sector_Matrix:=m;
end;

{------------------------------------------------------------------------------}

function EdgeKick_Matrix(h, t, g, k1{, k2}: real): Matrix_5;
{h curvature, t edge angle, g gap, k1,k2 transport fringe field params}
var
  m: Matrix_5;
  ax, ay, psi: real;
begin
  ax:=h*Tan(t);
  if k1<>0 then begin
//    psi:=k1*(h*g)*(1+sqr(Sin(t)))/Cos(t)*(1-k1*k2*(h*g)*Tan(t)); //didn't use K2 in 30 years...
    psi:=k1*(h*g)*(1+sqr(Sin(t)))/Cos(t);
    ay:=-h*Tan(t-psi);
  end else ay:=-ax;
  m:=Unit_Matrix_5;
  m[2,1]:=ax;
  m[4,3]:=ay;
  EdgeKick_Matrix:=m;
end;

{------------------------------------------------------------------------------}

function Bend_Matrix (l, h, k, KB, tin, tex, g, k1in, k1ex, k2in, k2ex: real): Matrix_5;
//matrix of bend in its system, i.e. blockdiag and no V-disp prod; uses MatMul5_S
var
  m, me, ms: Matrix_5;
begin
  m:=Unit_Matrix_5;
  if h=0 then m:=Quad_Matrix(l,k) else begin
    me:=EdgeKick_Matrix(h, tin, g, k1in{, k2in});
    ms:=Sector_Matrix(l, h, k, KB);
//    MatMulS(m,ms, me);
    m:=MatMul5_S(ms, me);
    me:=EdgeKick_Matrix(h, tex, g, k1ex{, k2ex});
//    ms:=m;
//    MatMulS(m,me,ms);
    m:=MatMul5_S(me,m);
  end;
  Bend_Matrix:=m;
end;

{------------------------------------------------------------------------------}

{==============================================================================}
{misc little helpers ----------------------------------------------------------}

procedure UnduPolFacs (var polfac: array of real; half: boolean; idir: shortint);
{get factors for field of undulator poles (idl test proc nuper.pro), as-11.11.2020
Examples:
Half undulator (half=true) to get open end
6 poles            -1       3      -4       4      -4       4
Half undulator inverted
6 poles            -4       4      -4       4      -3       1
Full undulator (half=false) or as segment: HalfU, -HalfU;
12 poles           -1       3      -4       4      -4       4      -4       4      -4       4      -3       1
11 poles           -1       3      -4       4      -4       4      -4       4      -4       3      -1
Minimum is 4 poles total, or 2 poles for half undulator, THIS IS NOT CHECKED.
}
var
  npole, npolc, ip: integer;
  tmp: real;
begin
  npole:=Length(polfac);
  polfac[0]:=-1;
  polfac[1]:=3;
  if half then npolc:=npole else npolc:=npole-2;
  for ip:=1 to (npolc-2) div 2 do begin
    polfac[2*ip]:=-4;
    polfac[2*ip+1]:=4;
  end;
  if (npolc mod 2) = 1 then polfac[npolc-1]:=-4;
  if not half then begin
    if (npolc mod 2) =1 then begin
      polfac[npolc]:= 3;
      polfac[npolc+1]:=-1;
    end else begin
      polfac[npolc]:=-3;
      polfac[npolc+1]:=1;
    end;
  end;
  if idir=-1 then begin
    for ip:=0 to (npole-2) div 2 do begin
      tmp:=polfac[ip];
      polfac[ip]:=polfac[npole-1-ip];
      polfac[npole-1-ip]:=tmp;
    end;
  end;
  for ip:=0 to npole-1 do polfac[ip]:=idir*polfac[ip]/4;
end;

{------------------------------------------------------------------------------}

procedure XBwrite      ( elemName: ElemStr; snap:integer; mode: shortint);
{writes photon beam markers name, betas and dispersion to the snapsave
 structure if snap=1. data will be written to snap for evaluation of
 camera data. (SLS special) ** remove ? ** }
begin
//  if (snap=1) and (mode>0) then begin
  if (snap=1) and switch(mode,do_twiss) then begin
    with SnapSave do begin
      if xbcount < xbcountmax then begin
        with xb[xbcount] do begin
          nam:=elemName;
//*** to be updated
{          betax:= SigN2[1,1];
          betay:= SigN2[3,3];
          dispx:= Disper2[1];
}
        end;
        inc(xbcount);
      end;
    end;
  end;
  SigNa1:=SigNa2;   SigNb1:=SigNb2; Disper1:=Disper2; Orbit1:=Orbit2;
end;

{==============================================================================}
{ Data handling ---------------------------------------------------------------}

procedure OpReadN (Op: OpvalType; var siga, sigb, cc, amat, bmat: Matrix_2; var D, O: Vektor_4);
// restore BD data from Opval
begin
  with Op do begin
    siga[1,1]:=beta;
    siga[1,2]:=-alfa;  siga[2,1]:=siga[1,2];
    siga[2,2]:=(1+sqr(alfa))/beta;
    sigb[1,1]:=betb;
    sigb[1,2]:=-alfb;  sigb[2,1]:=sigb[1,2];
    sigb[2,2]:=(1+sqr(alfb))/betb;

    D[1]:=disx;
    D[2]:=dipx;
    D[3]:=disy;
    D[4]:=dipy;
    O   :=orb;
    CC:=cmat;
    am:=amat; bm:= bmat;
  end;
end;

{------------------------------------------------------------------------------}

procedure OpWriteN (var Op: OpvalType; siga, sigb, cc, amat, bmat: Matrix_2; D, O: Vektor_4; s:real);
// save BD data to Opval
begin
  with Op do begin
    spos:=s;
    beta:= siga[1,1];
    alfa:=-siga[1,2];
    betb:= sigb[1,1];
    alfb:=-sigb[1,2];
    disx:= D[1];
    dipx:= D[2];
    disy:= D[3];
    dipy:= D[4];
    orb := O;
    cmat:=CC;
    amat:=am;
    bmat:=bm;
  end;
end;

{------------------------------------------------------------------------------}

procedure OpPrintDiag (Op: OpvalType);
// print opval to diag file, for testing only
begin
  with Op do begin
    writeln(diagfil,'Opval spos, x, x'', y, y'' ',spos, orb[1], orb[2], orb[3], orb[4]);
    writeln(diagfil,'beta, alfa ', beta, alfa, betb, alfb);
    writeln(diagfil,'cc matrix  ', cmat[1,1], cmat[1,2], cmat[2,1], cmat[2,2]);
    writeln(diagfil);
  end;
end;

{-------------------------------------------------------------------------}

procedure Tmat(M: matrix_5; Elen: double);
// update transfermatrix with element  matrix
// and save element matrix in stack
begin
  TransferMatrix:=MatMul5(M, TransferMatrix);
  if PropPerTest then begin
    Setlength(TmatStack, Length(TmatStack)+1);
    TmatStack[High(TmatStack)]:=MatCut54(M);
    Setlength(ElenStack, Length(ElenStack)+1);
    ElenStack[High(ElenStack)].elen:=Elen;
  end;
end;

{------------------------------------------------------------------------------}

procedure Tmat0(M0: matrix_5);
// update transfermatrix0 with element  matrix
begin
  TransferMatrix0:=MatMul5(M0, TransferMatrix0);
end;

{------------------------------------------------------------------------------}

procedure MisVector(M: matrix_5; dx, dy: real; mode:shortint);
//save misalignment in vector for tracking
{ wo ist der roll error? }
var
  t: Vektor_4;
begin
  if switch(mode, do_misal) then begin
    t[1]:=(1-M[1,1])*dx -   M[1,3] *dy;
    t[2]:=  -M[2,1] *dx -   M[2,3] *dy;
    t[3]:=  -M[3,1] *dx +(1-M[3,3])*dy;
    t[4]:=  -M[4,1] *dx -   M[4,3] *dy;
    MisalignVector:=VecAdd4(LinTra54(M, MisalignVector,0),t);
  end;
end;


{==============================================================================}
{- Slicing procs, to calculate matrices corresponding to one pixel length on
screen and skip what is outside screen ----------------------------------------}

function SliceSet (Op: OpvalType; l: real;  var soff, ds: real; var np: integer): boolean;
{interpolation for curves: checks if element is out of zoom region
or inside, or entering, exiting or covering it. Returns number of
points to interpolate, offset to start slicing and slice size 14.2.2005}
var
  ai, af, bi, bf: boolean;
  srest: real;
begin
  with CurvePlot do begin
    if (l>0.0) and (enable) then begin
      af := Op.spos > sfin;
      ai := Op.spos+l < sini;
      if ai or af then begin
        {out}
        np:=0;
      end else begin
        bi:=Op.Spos > sini;
        bf:=Op.Spos+l < sfin;
        if bi then begin
          if bf then begin
            {inside}
            soff:=0.0;
            srest:=l;
          end else begin
            {exit}
            soff:=0;
            srest:=sfin-Op.Spos;
          end;
        end else begin
          if bf then begin
            {enter}
            soff:=sini-Op.Spos;
            srest:=l-soff;
          end else begin
            {cover};
            soff:=sini-Op.Spos;
            srest:=sfin-sini;
          end;
        end;
        np:=Trunc(srest/slice)+1;
        ds:=srest/np;
      end;
    end else np:=0;
  end; // with
  SliceSet:=(np>0);
end;

{------------------------------------------------------------------------------}

Procedure SlicingN (var Op: OpvalType; min, mof, msl, mex, mof0, msl0: Matrix_5; soff, ds, dpp: real; coup: boolean; np: integer);
{interpolation inside a thick element}

// for Orbit propagation, matrices without downfeed should be used.
var
  amat, bmat, siga, sigb, CC: Matrix_2;
  D, Orb: Vektor_4;
  i: integer;
  bxa, bxb, bya, byb, da, db: real;
begin
  MF_calling:=3;
{ load beta matrix with opval at ENTRY to this element:}
  OpReadN(Op,siga, sigb, cc, amat, bmat, D, Orb);
  {apply a matrix for entering the element, e.g. edge kick}
  Orb:=LinTra54(min,Orb,dpp);
  if coup then MCC_prop (min, siga, sigb, CC, amat, bmat, D, false ) else MBD_prop (min, siga, sigb, CC, amat, bmat, D, false);
  {propagate through invisible part of the element:}
  if soff>=0 then begin {>= to get the first point too 070708}
    Orb:=LinTra54(mof0,Orb,dpp);
SposEL:=SposEL+soff;

    if coup then MCC_prop (mof, siga, sigb, CC, amat, bmat, D, false ) else  MBD_prop (mof, siga, sigb, CC, amat, bmat, D, false);
    GetBeta12(bxa, bxb, bya, byb, siga, sigb, CC);

da:=0; db:=0; //later <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    Curve:=AppendCurveN(Curve, Op.Spos+soff, Orb[1], Orb[3], bxa, bxb, bya, byb,
      D[1], D[3], D[2], D[4], MatDet2(cc), siga[1,1], sigb[1,1], -siga[1,2], -sigb[1,2], Da, Db );
  end;
  // extra point after entry (rot/flip may step-change horm betas)
  Curve:=AppendCurveN(Curve, Op.Spos+soff, Orb[1], Orb[3], bxa, bxb, bya, byb,
    D[1], D[3], D[2], D[4], MatDet2(cc), siga[1,1], sigb[1,1], -siga[1,2], -sigb[1,2], Da, Db );
  {iterate slices through element}

  for i:=1 to np do begin
    Orb:=LinTra54(msl0,Orb,dpp);
    if coup then MCC_prop (msl, siga, sigb, CC, amat, bmat, D, false ) else MBD_prop (msl, siga, sigb, CC, amat, bmat, D, false);
SposEL:=SposEL+ds;
    GetBeta12(bxa, bxb, bya, byb, siga, sigb, CC);

da:=0; db:=0;
    Curve:=AppendCurveN(Curve, Op.Spos+soff+ds*i, Orb[1], Orb[3], bxa, bxb, bya, byb,
      D[1], D[3], D[2], D[4], MatDet2(cc), siga[1,1], sigb[1,1], -siga[1,2], -sigb[1,2], Da, Db);
  end;
  {apply a matrix for leaving the element, e.g. edge kick}
  Orb:=LinTra54(mex,Orb,dpp);
  if coup then MCC_prop (mex, siga, sigb, CC, amat, bmat, D, false ) else MBD_prop (mex, siga, sigb, amat, bmat, CC, D, false);
  OpWriteN(Op,siga, sigb, CC, amat, bmat, D, Orb, Op.spos+soff+np*ds);
end;

{------------------------------------------------------------------------------}

Procedure SkippingN (var Op: OpvalType; msk, msk0: Matrix_5; sskip, dpp: real; coup: boolean);
{skip element, only update Op, not add points to curve}
var
  amat, bmat, siga, sigb, CC: Matrix_2;
  D, Orb: Vektor_4;
begin
  MF_calling:=4;
  {apply matrix for not used part of element to get Op correct}
  OpReadN(Op,siga, sigb, CC, amat, bmat, D, Orb);
  Orb:=LinTra54(msk0,Orb,dpp);
SposEL:=SposEL+sskip;
  if coup then MCC_prop (msk, siga, sigb, CC, amat, bmat, D, false ) else MBD_prop (msk, siga, sigb, CC, amat, bmat, D, false);
  OpWriteN (Op, siga, sigb, CC, amat, bmat, D, Orb, Op.spos+sskip);
end;

{------------------------------------------------------------------------------}

procedure SliceDriftN(var Opi, Opo: OpvalType; l: real; uflag: shortint);
var
  moffset, mslice, mskip: Matrix_5;
begin
// interpolation of long elements for better visualization:
  if SliceSet (Opi, l, soffset, dslice, nslice) then begin
    moffset := Drift_Matrix(soffset);
    mslice  := Drift_Matrix(dslice);
    SlicingN (Opi, Unit_Matrix_5, moffset, mslice, Unit_Matrix_5, moffset, mslice, soffset, dslice, 0, false, nslice);
  end else if (uflag=1) then begin
    mskip :=Drift_Matrix(l);
    SkippingN (Opi, mskip, mskip, l, 0, false);
  end;
end;

{------------------------------------------------------------------------------}

procedure SliceQuadN(var Opi, Opo: OpvalType; l, k0, rot, d: real);
var
  k, hlocx, hlocy: real;
  moffset, mslice, moffset0, mslice0, rotap, rotam: Matrix_5;
begin
  if SliceSet (Opi, l, soffset, dslice, nslice) then begin
    k:=k0/(1+d);
//rough approx for disp-prod, perhaps refine later
    hlocx:=(Opi.orb[2]-Opo.orb[2])/l;
    hlocy:=(Opi.orb[4]-Opo.orb[4])/l;
    moffset := Quad_Matrix(soffset, k); moffset0:=moffset; moffset[2,5]:=hlocx*moffset[1,2]; moffset[4,5]:=hlocy*moffset[3,4];
    mslice  := Quad_Matrix(dslice,  k); mslice0 :=mslice;  mslice[2,5] :=hlocx*mslice[1,2];  mslice[4,5] :=hlocy*mslice[3,4];
    if rot<>0 then begin
      rotap:=rotation_Matrix(rot); rotam:=rotation_Matrix(-rot);
      moffset:=MatMul5(rotam,MatMul5(moffset,rotap));
      mslice :=MatMul5(rotam,MatMul5(mslice ,rotap));
      SlicingN (Opi, Unit_Matrix_5, moffset, mslice, Unit_Matrix_5, moffset0, mslice0, soffset, dslice, d, true, nslice);
    end else  begin
      SlicingN (Opi, Unit_Matrix_5, moffset, mslice, Unit_Matrix_5, moffset0, mslice0, soffset, dslice, d, false, nslice);
    end;
  end;
end;

{------------------------------------------------------------------------------}

procedure SliceSolN (var Opi, Opo: OpvalType; l, k0, d: real);
var
  k: real;
  moffset, mslice: Matrix_5;
begin
  if SliceSet (Opi, l, soffset, dslice, nslice) then begin
    k:=k0/(1+d);
    moffset := Sol_Matrix(soffset, k);
    mslice  := Sol_Matrix(dslice,  k);
    SlicingN (Opi, Unit_Matrix_5, moffset, mslice, Unit_Matrix_5, moffset, mslice, soffset, dslice, d, true, nslice);
  end;
end;

{------------------------------------------------------------------------------}

procedure SliceBendN(var Opi, Opo: OpvalType; l, phi, k0, tin0, tex0, g,
                    k1in0, k1ex0, k2in0, k2ex0, rot, d : real; idir, uflag: shortint);

var
  h, h0, hlocy, k, tin, tex, k1in, k2in, k1ex, k2ex, kb: real;
  medgin, medgot, moffset, mslice, moffset0, mslice0, mskip, mskip0, rotap, rotam: Matrix_5;

procedure scaleBendPar;
begin
  h0:=phi/l;
  KB:=(h0*h0+k0)/(1+d);
  h:=h0/(1+d);
  k:=k0/(1+d);
  //ok to use this interpol....?!
  h:=h+ k*((Opi.orb[1]+Opo.orb[1])/2 + L*(Opi.orb[2]-Opo.orb[2])/12);
  hlocy:=(Opi.orb[4]-Opo.orb[4])/L; //like quad
// matrix of entrance edge, depends on bend orientation:
  if idir>0 then begin
    tin :=tin0;  tex :=tex0;
    k1in:=k1in0; k1ex:=k1ex0;
    k2in:=k2in0; k2ex:=k2ex0;
  end else begin
    tin :=tex0;  tex :=tin0;
    k1in:=k1ex0; k1ex:=k1in0;
    k2in:=k2ex0; k2ex:=k2in0;
  end;
end;

begin
  if phi=0 then SliceQuadN(Opi, Opo, l, k0, rot, d) else begin
    if SliceSet (Opi, l, soffset, dslice, nslice) then begin
      scaleBendPar;
      medgin  := EdgeKick_matrix(h, tin, g, k1in{, k2in});
      medgot  := EdgeKick_matrix(h, tex, g, k1ex{, k2ex});
      moffset := Sector_Matrix(soffset, h, k, KB);    moffset[4,5] :=hlocy*moffset[3,4];
      mslice  := Sector_Matrix(dslice,  h, k, KB);    mslice[4,5]  :=hlocy*mslice[3,4];
      moffset0 := Sector_Matrix(soffset, h0, k, KB);  moffset0[4,5]:=hlocy*moffset0[3,4];
      mslice0  := Sector_Matrix(dslice,  h0, k, KB);  mslice0[4,5] :=hlocy*mslice0[3,4];
      if rot<>0 then begin
        rotap:=rotation_Matrix(rot); rotam:=InvRot5(rotap);
        medgin:=MatMul5(rotam,MatMul5(medgin,rotap));
        medgot:=MatMul5(rotam,MatMul5(medgot,rotap));
        moffset:=MatMul5(rotam,MatMul5(moffset,rotap));
        mslice :=MatMul5(rotam,MatMul5(mslice ,rotap));
        moffset0:=MatMul5(rotam,MatMul5(moffset0,rotap));
        mslice0 :=MatMul5(rotam,MatMul5(mslice0 ,rotap));
        SlicingN (Opi, medgin, moffset, mslice, medgot, moffset0, mslice0, soffset, dslice, d, true, nslice);
      end else  begin
        SlicingN (Opi, medgin, moffset, mslice, medgot, moffset0, mslice0, soffset, dslice, d, false, nslice);
      end;
    end else if (uflag=1) then begin
// if bend belongs to undulator:
      scaleBendPar;
      mskip :=Bend_Matrix(l,h ,k, kb, tin,tex,g,k1in,k1ex,k2in,k2ex);
      mskip0:=Bend_Matrix(l,h0,k, kb, tin,tex,g,k1in,k1ex,k2in,k2ex);
      if rot<>0 then begin
        rotap:=rotation_Matrix(rot); rotam:=rotation_Matrix(-rot);
        mskip :=MatMul5(rotam,MatMul5(mskip ,rotap));
        mskip0:=MatMul5(rotam,MatMul5(mskip0,rotap));
        SkippingN(Opi, mskip, mskip0, l, d, true);
      end else begin
        SkippingN(Opi, mskip, mskip0, l, d, false);
      end;
    end;
  end;
end;

{------------------------------------------------------------------------------}

Procedure SliceUnduN( var Opi, Opo: OpvalType; l, B, lam0, gap, fill1, fill2, fill3, rot, d : real; half: boolean; idir:shortint);
{as 230394/100197/150205/090707/24.11.20}

var
  lam, phi, pphi, drs, drb, k1 : real;
  Npole, ip: integer;
  polfac: array of real;

begin
  if (Opi.spos>CurvePlot.sfin) or (Opo.spos < CurvePlot.sini) then begin
  // out of sight, no need to loop over bends: skip all
  end else begin
    Npole:=Round(2*l/lam0);
    lam:=2*l/Npole;
    setlength(polfac,Npole);
    UnduPolFacs(polfac, half, idir);

    // in case undu is partially out of sight calc intermediate Op
    phi  := lam*fill1/2/(Glob.Energy/(speed_of_light/1E9)/B); {=lambda/4 : rho for half fill}
    k1:=lam/4/gap*(fill1-fill2);

    drb  :=    fill1*lam/2;
    drs  :=(1-fill1)*lam/4;

    for ip:=0 to npole-1 do begin
      pphi:=phi*polfac[ip];
      SliceDriftN (Opi, Opo, drs, 1);
      SliceBendN  (Opi, Opo, drb, pphi, 0, pphi/2, pphi/2, gap,k1,k1,0,0, rot,d, 1, 1);
      SliceDriftN (Opi, Opo, drs, 1);
    end;
  end;
end;

{------------------------------------------------------------------------------}

procedure SextKickN (var Opi, Opo: OpvalType; ml0, dpp: real);
//used by slicesext and slicecomb

var
  mqs: Matrix_5;
  D, Orb: Vektor_4;
  ml: real;
  amat, bmat, siga, sigb, cc: matrix_2;

begin
  if UseSext then begin
    ml:=ml0/(1+dpp);
    OpReadN(Opi, siga, sigb, cc, amat, bmat, D, Orb);

//need coupled treatment, if orbit vertically displaced; explicit rotation already handled by Rotation.
    Orb[2]:=Orb[2] - ml*(sqr(Orb[1])-sqr(Orb[3]));
    Orb[4]:=Orb[4] + 2*ml*Orb[1]*Orb[3];
 // quad and skew quad downfeed from thin sextupole, local matrix at Orb
    mqs:=Unit_Matrix_5;
    mqs[2,1]:=-2*ml*Orb[1];
    mqs[4,3]:=-mqs[2,1];
   if abs(Orb[3])>OrbMinHeave then begin
      mqs[2,3]:= 2*ml*Orb[3];
      mqs[4,1]:= mqs[2,3];
      MCC_prop(mqs, siga, sigb, CC, amat, bmat, D, false);
    end else begin
      MBD_prop (mqs, siga, sigb, CC, amat, bmat, D, false);
    end;
    OpWriteN(Opi, siga, sigb, CC, amat, bmat, D, Orb, Opi.spos);
  end;
end;

{------------------------------------------------------------------------------}

Procedure SliceSextN(var Opi, Opo: OpvalType; l, m, d: real; nsl: shortint );
var
  dml, dl: real;
  i: integer;
begin
  if (Opi.spos>CurvePlot.sfin) or (Opo.spos<CurvePlot.sini) then begin
  // out of sight, no need to loop over bends: skip all
  end else begin
    dl :=l/nsl;
    dml:=m*dl; //integrated sextupole of slice
    SliceDriftN (Opi, Opo, dl/2, 1);
    SextKickN  (Opi, Opo, dml, d);
    for i:=1 to nsl-1 do begin
      SliceDriftN  (Opi, Opo, dl, 1);
      SextKickN  (Opi, Opo, dml, d);
    end;
    SliceDriftN (Opi, Opo, dl/2, 1);
  end;
end;

{------------------------------------------------------------------------------}

Procedure SliceCombN(var Opi, Opo: OpvalType; l, phi, t1, t2, k11, k12, gap, k, m, rot, d : real;
                         nsl, idir : shortint );
var
  dphi, dml, dl, tin, tex, k1in, k1ex: real;
  i: integer;
begin
  if (Opi.spos>CurvePlot.sfin) or (Opo.spos<CurvePlot.sini) then begin
  // out of sight, no need to loop over bends: skip all
  end else begin
    dl :=l/(2*nsl);
    dphi:=phi/(2*nsl);
    dml:=m*2*dl; //integrated sextupolell of slice
    if phi<>0 then if idir=1
    then begin tin:=t1; k1in:=k11; tex:=t2; k1ex:=k12 end
    else begin tin:=t2; k1in:=k12; tex:=t1; k1ex:=k11 end;
// setupolkick only reg.quad, skew not included; i.e. only valid for O[3]=0
    SliceBendN (Opi, Opo, dl, dphi, k, tin, 0, gap, k1in, 0, 0, 0, 0, d, 1, 1);
    SextKickN  (Opi, Opo, dml, d);
    for i:=1 to nsl-1 do begin
      SliceBendN  (Opi, Opo, 2*dl, 2*dphi, k, 0, 0, 0, 0, 0, 0, 0, 0, d, 1, 1);
      SextKickN  (Opi, Opo, dml, d);
    end;
    SliceBendN  (Opi, Opo, dl, dphi, k, 0, tex, gap, 0, k1ex, 0, 0, 0, d, 1, 1);
  end;
end;

{==============================================================================}
{ Transfer trough elements incl. radiation-------------------------------------}

Procedure Rotation (ang: real; idir, mode: shortint);
{ explicit rotation of x/y plane }
var
  R: Matrix_5;
begin
  MF_calling:=10+MF_calling;
  if modeflip then MF_calling:=100+MF_calling;
  if (abs(ang)>1e-12) or ModeFlip then begin // use rot=0 to enable backflip if needed
//    writeln('rotation at s=',sposel:10:3, ang:10:5, modeflip);
    if Glob.rot_inv then R:=Rotation_Matrix(idir*ang) else R:=Rotation_Matrix(ang);
    Tmat(R,0);
    Tmat0(R);
    Propagate(R,mode,true);
    Orbit2:=LinTra54(R, Orbit1, 0);
    PropForward;
  end;
end;

{------------------------------------------------------------------------------}

procedure DriftSpace( l : real; mode:shortint );
var
  Rz: matrix_5;
begin
  MF_calling:=1;

  Rz:=Drift_Matrix(l);
  Tmat(Rz,l); Tmat0(Rz);
//  if mode > -1 then begin
  Propagate(Rz, mode, false);
  Orbit2:=LinTra54(Rz, Orbit1, 0);
  if switch(mode, do_lpath) then PathDiff:=PathDiff+Pathlength(l,0,0,0);
  PropForward;

  if switch(mode, do_misal) then MisalignVector:=LinTra54(Rz, MisalignVector,0);

  SposEL:=SposEL+l;

end;

{------------------------------------------------------------------------------}

procedure Quadrupole (l, k0, rot, d: real; idir, mode: shortint; sway, heave, roll: real);
const
  dqmax=0.001;      //make var
var
  AMT, BMT, sigNaT, sigNbT, CoupMT, qmdpox, qmdpoy: matrix_2;
  dq: vektor_2;
  ss, cc, drsl, k, fsimp,
      Gx, Gy, I1, I2, I3, I4a, I4b, I5a, I5b, hx, hy, go, heff2, heff, heff3,
      ci4x, ci4y: double;
  doradin, dochrom :boolean;
  QM0, QM0c, QM, QDP, QMS, Rin, Rex: Matrix_5;
  irsl, nrsl, i: integer;
  DispN, DispS, DisperT, orbitT, DV: vektor_4;
  mflip_mem, coupled: boolean;

{ Special treatment of [rotated] quads:
  use M = Rex QM Rin for propagation (Rex = Rin^-1)
  but successively Rin --> QMslice --> Rex for integrals
  Reason: we often have skew quads (Rin/Rex +/-45 deg) which are weak, so M is
    a weakly coupling matrix. However Rin alone is strongly coupling and causes
    mode flips, which look ugly in beta plot and mix the tunes. But flips don't
    spoil the integrals, because just interchanging a <--> b in flip mode is ok.
    (*** still to do: proper calc of phase advance during mode flip ***)
  For other elements this may not be needed, since rotations are small [?]

  first half of this proc is from v. 4.034, 2nd half from 4.033

  general: propagation of dispersion:  D2 = (Rex.M.Rin).D1 + Rex.V + (Rex.dM/du.Rin).Orb1

  V = on-ax disp prod vector (=0 for quad), u=dp/p

  4.1.2022
}

begin
  MF_calling:=1;

  if k0=0 then DriftSpace(l,mode)
  else begin
    MisAlign(Orbit1, 0, sway, heave, roll, mode, 1);
    if abs(rot)>1e-12 then begin
      if Glob.rot_inv then Rin:=Rotation_Matrix(idir*rot) else Rin:=Rotation_Matrix(rot);
      coupled:=true;
      Rex:=InvRot5(Rin);
    end;
//    Rotation(rot, idir, mode);

    k:=k0/(1+d);

    //get Matrix of quad
    QM0:=Quad_Matrix(l,k);
    QM0c:=QM0;
//    QM:=QM0;
    // dispersion production matrix on orbit
    QDP:=MatNul5;
    if k<>0 then begin // also check for off-axis to skip if on axis?
      SS:=QM0[1,2]; CC:=QM0[1,1];
      QDP[1,1]:=  k*L*SS/2;      QDP[1,2]:=  (SS-L*CC)/2;
      QDP[2,1]:=  k*(SS+L*CC)/2; QDP[2,2]:=  k*L*SS/2;
      SS:=QM0[3,4]; CC:=QM0[3,3];
      QDP[3,3]:= -k*L*SS/2;      QDP[3,4]:= (SS-L*CC)/2;
      QDP[4,3]:= -k*(SS+L*CC)/2; QDP[4,4]:= -k*L*SS/2;
    end;
    // define two transfer matrices for propagation, QM0 for the orbit and QM
    // including orbit dependent dispersion production for calc of periodic dispersion.
    // Both are sandwiched between rotations; if rot<>0 we need coupled propagation:
    coupled:=false;
    if abs(rot)>1e-12 then begin
     coupled:=true;
     if Glob.rot_inv then Rin:=Rotation_Matrix(idir*rot) else Rin:=Rotation_Matrix(rot);
     Rex:=InvRot5(Rin);
     QM0:=MatMul5(Rex,MatMul5(QM0, Rin));
     QDP:=MatMul5(Rex,MatMul5(QDP, Rin));
    end;
    QM:=QM0;
    DV:=LinTra54(QDP,Orbit1,0); //off-axis dispersion production vector
    for i:=1 to 4 do QM[i,5]:=QM[i,5]+DV[i];
//prop orbit and save on-axis transfer matrices
    Orbit2:=LinTra54(QM0, Orbit1, d);
    Propagate(QM, mode, coupled);
    Tmat(QM,l); Tmat0(QM0);

    if switch(mode, do_lpath) then PathDiff:=PathDiff+Pathlength(l,0,k0,d); //check orbit dependence!!!

    dochrom:= switch(mode,do_chrom);
    doradin:= switch(mode,do_radin);

//---------------- calc integrals in quad's local system

    if dochrom or doradin then begin
      mflip_mem:=ModeFlip;

      Gx:=0; Gy:=0;
      I1:=0; I2:=0; I3:=0; I4a:=0; I4b:=0; I5a:=0; I5b:=0;
      sigNaT:=SigNa1; sigNbT:=SigNb1;
      DisperT:=Disper1; OrbitT:=Orbit1; CoupMT:=CoupMatrix1;  AMT:=AMat1; BMT:=BMat1;
//we have to do a rotation into the quad coord system with risk of mode flip
      if coupled then MCC_prop(Rin, sigNaT, sigNbT, CoupMT, AMT, BMT, DisperT, false);
//go does not change further since quad inside is non-coupling
      go:=sqrt(1-MatDet2(CoupMT));

      //estimate phase advance inside quad and determine the number of slices for radiation integrals
      dq:=getdtune (QM0c, SigNaT, SigNbT);
      //      dq:=getdtune (QM0, SigNa1, SigNb1);
      //--> this was wrong, because getdtune assumes blockdiag matrix! QM0c is bl.di., QM0 is not.
      if dq[1] > dq[2] then nrsl:= trunc(dq[1]/dqmax)+1 else nrsl:=trunc(dq[2]/dqmax)+1;
      drsl:=L/nrsl;
      //matrix for slice quad
      QMS:=Quad_Matrix(drsl,k);
      //prepare 2x2 matrices to get coefficients for additional off-axis dispersion production
      if k <>0 then begin
        ss:=QMS[1,2]; cc:=QMS[1,1];
        qmdpox:=matset2(  k*drsl*ss/2,   (ss-drsl*cc)/2,  k*(ss+drsl*cc)/2,   k*drsl*ss/2);
        ss:=QMS[3,4]; cc:=QMS[3,3];
        qmdpoy:=matset2( -k*drsl*ss/2,   (ss-drsl*cc)/2, -k*(ss+drsl*cc)/2,  -k*drsl*ss/2);
      end else begin
        qmdpox:=matnul2;
        qmdpoy:=matnul2;
      end;

      //integrate by simpson's rule 1/2*fo*dL + f1*dL + ... + 1/2*fn*dL
      fsimp:=0.5*drsl;
      for irsl:=0 to nrsl do begin
        //local curvature given by orbit
        hx:= k*OrbitT[1];
        hy:=-k*OrbitT[3];
        heff2:=sqr(hx)+sqr(hy); heff:=sqrt(heff2); heff3:=heff*heff2;
        if irsl > 0 then begin
          //proceed to end of slice
          MBD_prop(QMS, sigNaT, sigNbT, CoupMT, AMT, BMT, DisperT, false);
          // add off-axis dispersion production
          DisperT:=VecAdd4(DisperT, LinTra244(qmdpox, qmdpoy,OrbitT));
          OrbitT:=LinTra54(QMS,OrbitT,d);
          fsimp:=drsl;
          if irsl=nrsl then fsimp:=0.5*drsl;
        end;
        //get normal mode (N) and normalized (S) dispersionss
        DispN:=DRtoDN(DisperT, CoupMT, go);
        DispS:=DNtoDS(DispN, sigNaT, SigNbT);
        //contributions to radiation integrals
        ci4x:=hx*(heff2+2*k); ci4y:=hy*(heff2-2*k);
        I1 :=I1 + (DisperT[1]*hx+DisperT[3]*hy)*fsimp;
        I2 :=I2 + heff2*fsimp;
        I3 :=I3 + heff3*fsimp;
        I4a:=I4a+(ci4x*go*DispN[1]+ci4y*(DisperT[3]-go*DispN[3]))*fsimp;
        I4b:=I4b+(ci4y*go*DispN[3]+ci4x*(DisperT[1]-go*DispN[1]))*fsimp;
        I5a:=I5a+(Sqr(DispS[1])+Sqr(DispS[2]))*heff3*fsimp;
        I5b:=I5b+(Sqr(DispS[3])+Sqr(DispS[4]))*heff3*fsimp;
        //contribution to chromaticities
        Gx:=Gx-SigNaT[1,1]*k*fsimp;
        Gy:=Gy+SigNbT[1,1]*k*fsimp;
      end;

      with Beam do begin
        RadInt1 :=RadInt1 +I1;
        RadInt2 :=RadInt2 +I2;
        RadInt3 :=RadInt3 +I3;
        if modeflip then begin // add to other mode integral if we are flipped
          RadInt4a:=RadInt4a+I4b;
          RadInt4b:=RadInt4b+I4a;
          RadInt5a:=RadInt5a+I5b;
          RadInt5b:=RadInt5b+I5a;
          chromX:=chromX + Gy/4/Pi;
          chromY:=chromY + Gx/4/Pi;
        end else begin
          RadInt4a:=RadInt4a+I4a;
          RadInt4b:=RadInt4b+I4b;
          RadInt5a:=RadInt5a+I5a;
          RadInt5b:=RadInt5b+I5b;
          chromX:=chromX + Gx/4/Pi;
          chromY:=chromY + Gy/4/Pi;
        end;
      end;
      ModeFlip:=mflip_mem; //restore flip status before entering the integration
    end;
//---------------- done with integrals

    PropForward; //transfer 2-->1
    MisVector(QM, sway,heave, mode); // rot to be included ?
    MisAlign(Orbit1, 0, sway, heave, roll, mode, -1);
    SposEL:=SposEL+l;
  end; {k<>0}
end;


{------------------------------------------------------------------------------}

procedure Bending( L, phi, k0, tin, tex, g, k1in, k1ex, k2in, k2ex, rot, d : real; idir, mode: shortint; sway, heave, roll: real );
const
  dqmax=0.001; // max phase advance for radiation integration slice

var
  dochrom, doradin: boolean;
  SM0, SMS, TM, TM0, SM, TMin, TMex, TMin0, TMex0:Matrix_5;
  smdpox, smdpoy, AMT, BMT, AMIn, BMIn, sigNaT, sigNbT, CoupMT, sigNaIn, sigNbIn, CoupMatrixIn: Matrix_2;
  DispN, DispS, DisperT, DisperIn, OrbitT, OrbitIn: Vektor_4;
  h0, h, heff, k, KB, ehx,
    go,  heff2, heff3,  I1, I2, I3, I4a, I4b, I5a, I5b,  ttin, ttex,
    Gx, Gy, hx, hy, ss, cc, drsl, ci4x, ci4y, fsimp: double;
  dq: vektor_2;
  nrsl, irsl: integer;

begin
  MF_calling:=1;

  if phi=0 then Quadrupole (l, k0, rot, d, idir, mode, sway, heave, roll)
  else begin
    MisAlign(Orbit1, phi, sway, heave, roll, mode, 1);
    Rotation(rot, idir, mode);

    dochrom:=switch(mode,do_chrom);
    doradin:=switch(mode,do_radin);

    h0 :=Phi/L;
    h  :=h0/(1+d);
    k  :=k0/(1+d);
    KB :=  (sqr(h0)+k0)/(1+d);

{suffix 1 before bend, 2 after bend, In after entry edge at begin of sector, T temp for slices }

    if idir>0 then begin
      TMin:=EdgeKick_Matrix(h, tin, g, k1in {, k2in});
      TMex:=EdgeKick_Matrix(h, tex, g, k1ex {, k2ex});
      ttin:=Tan(tin); ttex:=Tan(tex);
    end else begin
      TMin:=EdgeKick_Matrix(h, tex, g, k1ex {, k2ex});
      TMex:=EdgeKick_Matrix(h, tin, g, k1in {, k2in});
      ttin:=Tan(tex); ttex:=Tan(tin);
    end;

    TMin0:=TMin; Tmex0:=Tmex; //on axis

    TMin[2,5]:=-TMin[2,1]*Orbit1[1]; //disp production of edge kick from dx/du= -h tan x0
    TMin[4,5]:=-TMin[4,3]*Orbit1[3]; //not exact if k1, gap >   0

    //propagate after entry edge
    sigNaIn:=SigNa1; sigNbIn:=SigNb1; CoupMatrixIn:=CoupMatrix1;  DisperIn:=Disper1; OrbitIn:=Orbit1;
    AMIn:=AMat1; BMIn:=BMat1;

    MBD_prop(TMin, sigNaIn, sigNbIn, CoupMatrixIn, AMIn, BMin, DisperIn, false);
    OrbitIn:=Lintra54(TMin0, OrbitIn, d);

    //get Matrix of sector only
    SM0:=Sector_Matrix(l,h,k, KB);
    // add off-axis dispersion production
    SM:=SM0;

    //previous version 4.035 using kh2=2(sqr(h)+k was [probably] wrong
    if KB<>0 then begin
      SS:=SM[1,2]; CC:=SM[1,1];
      SM[1,5]:=  SM0[1,5] + KB*L*SS     *OrbitIn[1]/2 + (SS-L*CC)*OrbitIn[2]/2;
      SM[2,5]:=  SM0[2,5] + KB*(SS+L*CC)*OrbitIn[1]/2 + KB*L*SS     *OrbitIn[2]/2;
    end;
    if k<>0 then begin
      SS:=SM[3,4]; CC:=SM[3,3];
      SM[3,5]:= SM0[3,5] - k*L*SS     *OrbitIn[3]/2 +(SS-L*CC)*OrbitIn[4]/2;
      SM[4,5]:= SM0[4,5] - k*(SS+L*CC)*OrbitIn[3]/2 - k*L*SS  *OrbitIn[4]/2;
    end;

    TM0 :=MatMul5(Tmex0,MatMul5(SM0, TMin0));

    Orbit2 :=LinTra54(TM0, Orbit1, d);     //includes edges, use on axis matrix for orbit prop
    //once orbit 2 is known, add the disp prod of exit edge:
    TMex[2,5]:=-TMex[2,1]*Orbit2[1]; //orb 1,3 don't change on edge, only orb 2,4
    TMex[4,5]:=-TMex[4,3]*Orbit2[3];

    TM  :=MatMul5(Tmex ,MatMul5(SM , TMin ));

    Tmat(TM,l); TMat0(TM0);

    if switch(mode, do_lpath) then PathDiff:=PathDiff+Pathlength(l,h0,k0,d);

    if dochrom or doradin then begin

    //get phase advance inside sector bend and determine the number of slices for radiation integrals
      dq:=getdtune (SM0, SigNaIn, SigNbIn);
      if dq[1] > dq[2] then nrsl:= trunc(dq[1]/dqmax)+1 else nrsl:=trunc(dq[2]/dqmax)+1;
      drsl:=L/nrsl;
    //matrix for slice sector
      SMS:=Sector_Matrix(drsl,h,k, KB);
      //prepare 2x2 matrices to get coefficients for additional off-axis dispersion production
      ss:=SMS[1,2]; cc:=SMS[1,1];
      if KB<>0
        then smdpox:=matset2(KB*drsl*ss/2, (ss-drsl*cc)/2, KB*(ss+drsl*cc)/2, KB*drsl*ss/2)
        else smdpox:=matnul2;
      ss:=SMS[3,4]; cc:=SMS[3,3];
      if k <>0
        then smdpoy:=matset2( -k*drsl*ss/2,        (ss-drsl*cc)/2,  -k*(ss+drsl*cc)/2,  -k*drsl*ss/2)
        else smdpoy:=matnul2;

      Gx:=0; Gy:=0; // approx for chroma
      I1:=0; I2:=0; I3:=0; I4a:=0; I4b:=0; I5a:=0; I5b:=0;
      sigNaT:=SigNa1; sigNbT:=SigNb1;
      DisperT:=Disper1; OrbitT:=Orbit1; CoupMT:=CoupMatrix1; AMT:=AMat1; BMT:=BMat1;
      // proceed to start of sector, after entry edge
      OrbitT:=LinTra54(TMin0,OrbitT,d);   //<-- done before
      MBD_prop(TMin, sigNaT, sigNbT, CoupMT, AMT, BMT, DisperT, false);  //<-- already done before, call signaIn
      //go does not change since bend is non-coupling
      go:=sqrt(1-MatDet2(CoupMT));
      //integrate by simpson's rule 1/2*fo*dL + f1*dL + ... + 1/2*fn*dL
      for irsl:=0 to nrsl do begin
        //local curvature given by orbit
        hx:=h+k*OrbitT[1];
        hy:= -k*OrbitT[3];
        ehx:=1+h*OrbitT[1];
        heff2:=sqr(hx)+sqr(hy); heff:=sqrt(heff2); heff3:=heff*heff2;
        if irsl=0 then begin
          // contribution of entry edge
          DispN:=DRtoDN(DisperT, CoupMT, go);
          ci4x:=-ttin*heff2;
          ci4y:= 0;
//          ci4x:=-ttin*(2*k*hx*OrbitT[1]+heff2);
//          ci4y:= ttin* 2*k*hy*OrbitT[1];
          I4a:=I4a+(ci4x*go*DispN[1]+ci4y*(DisperT[3]-go*DispN[3]));
          I4b:=I4b+(ci4y*go*DispN[3]+ci4x*(DisperT[1]-go*DispN[1]));
          Gx:=Gx+sigNaT[1,1]*Tmin[2,1];
          Gy:=Gy+sigNbT[1,1]*Tmin[4,3];
          fsimp:=0.5*drsl*ehx-ttin*OrbitT[1]; //path correction for edge
        end else begin
          //proceed to end of slice
          MBD_prop(SMS, sigNaT, sigNbT, CoupMT, AMT, BMT, DisperT, false);
          // add off-axis dispersion production
          DisperT:=VecAdd4(DisperT, LinTra244(smdpox, smdpoy, OrbitT));
          OrbitT:=LinTra54(SMS,OrbitT,d);
          fsimp:=drsl*ehx;
          if irsl=nrsl then begin
            fsimp:=0.5*drsl*ehx-ttex*OrbitT[1];
          end;
        end;
        //get normal mode (N) and normalized (S) dispersionss
        DispN:=DRtoDN(DisperT, CoupMT, go);
        DispS:=DNtoDS(DispN, sigNaT, SigNbT);
        //contributions to radiation integrals
        ci4x:= hx*(heff2+2*k);
        ci4y:= hy*(heff2-2*k);
        //        ci4x:= 2*k*hx*ehx+h*heff2;
        //        ci4y:=-2*k*hy*ehx;
        I1 :=I1 + (DisperT[1]*hx+DisperT[3]*hy)*fsimp;
        I2 :=I2 + heff2*fsimp;
        I3 :=I3 + heff3*fsimp;
        I4a:=I4a+(ci4x*go*DispN[1]+ci4y*(DisperT[3]-go*DispN[3]))*fsimp;
        I4b:=I4b+(ci4y*go*DispN[3]+ci4x*(DisperT[1]-go*DispN[1]))*fsimp;
        I5a:=I5a+(Sqr(DispS[1])+Sqr(DispS[2]))*heff3*fsimp;
        I5b:=I5b+(Sqr(DispS[3])+Sqr(DispS[4]))*heff3*fsimp;
        //contribution to chromaticities
        Gx:=Gx-SigNaT[1,1]*KB*fsimp;
        Gy:=Gy+SigNbT[1,1]*k*fsimp;
      end;
      // contribution of exit edge
      ci4x:=-ttex*heff2;
      ci4y:= 0;
//      ci4x:=-ttex*(2*k*hx*OrbitT[1]+heff2);
//      ci4y:= ttex* 2*k*hy*OrbitT[1];
      I4a:=I4a+(ci4x*go*DispN[1]+ci4y*(DisperT[3]-go*DispN[3]));
      I4b:=I4b+(ci4y*go*DispN[3]+ci4x*(DisperT[1]-go*DispN[1]));
      Gx:=Gx+sigNaT[1,1]*Tmex[2,1];
      Gy:=Gy+sigNbT[1,1]*Tmex[4,3];

      with Beam do begin
        RadInt1 :=RadInt1 +I1;
        RadInt2 :=RadInt2 +I2;
        RadInt3 :=RadInt3 +I3;
        if modeflip then begin // add to other mode integrals if flipped
          RadInt4a:=RadInt4a+I4b;
          RadInt4b:=RadInt4b+I4a;
          RadInt5a:=RadInt5a+I5b;
          RadInt5b:=RadInt5b+I5a;
          chromX:=chromX + Gy/4/Pi;
          chromY:=chromY + Gx/4/Pi;
        end else begin
          RadInt4a:=RadInt4a+I4a;
          RadInt4b:=RadInt4b+I4b;
          RadInt5a:=RadInt5a+I5a;
          RadInt5b:=RadInt5b+I5b;
          chromX:=chromX + Gx/4/Pi;
          chromY:=chromY + Gy/4/Pi;
        end;
      end;

{ The alternative method using explicit analytical integrals was removed with
version 4.021, the code extracted here is saved in  bend_radint_analytic_4.020.pas
The Simpson integration used now is less elegant but can better include off axis
contributions, which would be difficult with the analytic expressions.
27.7.2021 }

    end;

    Propagate(TM, mode, false);
    PropForward;

    SposEL:=SposEL+l;
    Rotation(-rot, idir, mode);
    MisVector(TM,sway,heave, mode);
    MisAlign(Orbit1, phi, sway, heave, roll, mode,-1);
  end; //phi<>0
end;
{------------------------------------------------------------------------------}

procedure Solenoid (l, k0, d: real; idir, mode: shortint; sway, heave, roll: real);
{Solenoid invariant to direction and rotation; opposite rotation req's inverse polarity}
{ 12.5.2016 extended to full 4D treatment.
  New and corret definition of k = B/(2Brho)
}
{ 011294. k = (B/Brho)^2 > 0, beam rotation ignored, i.e. assumption
  of rotation compensated solenoids:   | +B || -B |
  same matrix as quad foc. hor. and vert., chroma(sol)=2*chroma(quad) }

var      k: real;      TM: matrix_5;

begin
  if k0=0 then DriftSpace(l,mode)
  else begin
    MisAlign(Orbit1, 0, sway, heave, roll, mode, 1);
// no Rotation since solenoid is rotationally symmetric

    k:=k0/(1+d);
    TM:=Sol_Matrix(l,k);

//    if mode > 0 then begin
// NOT correct, definition of strength was changed; here a=sqrt(k) (old)
// anyway chroma x,y makes no sense for solenoid
// [ deleted wrong chroma calc here ]

 //  if switch(mode, do_lpath) .... pathlength not included for solenoid - complicated...
 // downfeed not included either

    Tmat(TM,l); Tmat0(TM);

    Propagate(TM, mode, true);
    Orbit2:=LinTra54(tm, Orbit1, 0);
    PropForward;
    MisVector(TM,sway,heave, mode); //???? anwendbar?
    MisAlign(Orbit1, 0, sway, heave, roll, mode,-1);
    SposEL:=SposEL+l;
  end;
end;

{------------------------------------------------------------------------------}

procedure ThinSextupole (ml0, d : real; mode: shortint);
var
  a2l, b2l, b3l0, b3l, dxp, dyp: real;
  tm: Matrix_5;
  coupled: boolean;

begin
  MF_calling:=6;
  b3l0:=ml0;
  coupled:=not status.Uncoupled;
  if UseSext then begin
    b3l:=b3l0/(1+d);
    dxp:=-b3l*(sqr(Orbit1[1])-sqr(Orbit1[3]));
    dyp:=2*b3l*Orbit1[1]*Orbit1[3];
    Orbit2[1]:=Orbit1[1];
    Orbit2[2]:=Orbit1[2]+dxp;
    Orbit2[3]:=Orbit1[3];
    Orbit2[4]:=Orbit1[4]+dyp;

    tm:=Unit_Matrix_5;
    // local gradient
    b2l:=2*b3l*Orbit1[1];
    tm[2,1]:=-b2l;
    tm[4,3]:= b2l;
    // dispersion production
//    tm[5,2]:=-b3l*(sqr(Orbit1[1])-sqr(Orbit1[3]));
//    tm[5,4]:= b3l*2*Orbit1[1]*Orbit1[3];

    tm[5,2]:= -dxp; // disp opposite of kick
    tm[5,4]:= -dyp;

    //need coupled treatment, if orbit vertically displaced; explicit rotation already handled by Rotation.
    if abs(Orbit1[3])> OrbMinHeave then begin
      coupled:=true;
      // skew quad gradient
      a2l:=2*b3l*Orbit1[3];
      tm[2,3]:= a2l;
      tm[4,1]:= a2l;
    end;

    TMat(tm,0); //tm0=unitmat, no update Tmat0

    if switch(mode,do_chrom) then with Beam do begin
      //approx for uncoupled chroma
      ChromX:=ChromX+b3l*SigNa1[1,1]*Disper1[1]/2/Pi;
      ChromY:=ChromY-b3l*SigNb1[1,1]*Disper1[1]/2/Pi;
    end;
    // no calculation of radiation integrals, usually negligible contributions 28.7.2021

    Propagate(tm, mode, coupled);
    PropForward;
  end;
end;

{------------------------------------------------------------------------------}

procedure Sextupole ( l, m_ml, rot, d : real; nkick, idir, mode: shortint; sway, heave, roll: real);
// m_ml is strength if l>0 and int.strength if l=0
var
  dl, dml: double;
  i: integer;

begin
  MisAlign(Orbit1, 0, sway, heave, roll, mode, 1);
  Rotation(rot, idir, mode);
  if l=0 then ThinSextupole(m_ml, d, mode) else begin
    dl:=l/nkick;
    dml:=m_ml*dl;
    Driftspace(dl/2,mode);
    ThinSextupole(dml, d, mode);
    for i:=1 to nkick-1 do begin
      Driftspace(dl,mode);
      ThinSextupole(dml, d, mode);
    end;
    Driftspace(dl/2,mode);
  end;
  Rotation(-rot, idir, mode);
//  MisVector(TM,sway,heave, mode); not used for multipole
  MisAlign(Orbit1, 0,sway, heave, roll, mode,-1);
end;

{------------------------------------------------------------------------------}

procedure Combined  ( l, phi, t1, t2, k11, k12, gap, k, m, rot, d : real;
                     nsl, idir, mode: shortint; sway, heave, roll: real );    {as 230497 / 050408}

var
  dphi, dml, dl, tin, tex, k1in, k1ex: real;
  i: integer;
begin
  dl :=l/(2*nsl);
  dphi:=phi/(2*nsl);
  dml:=m*2*dl; //integrated sextupole of slice
  if idir=1
  then begin tin:=t1; k1in:=k11; tex:=t2; k1ex:=k12 end
  else begin tin:=t2; k1in:=k12; tex:=t1; k1ex:=k11 end;
  MisAlign(Orbit1, phi, sway, heave, roll, mode, 1);
  Rotation(rot, idir, mode);
  Bending (dl, dphi, k, tin, 0, gap, k1in, 0, 0, 0, 0, d, 1, mode,0,0,0);
  ThinSextupole (dml, d, mode);
  for i:=1 to nsl-1 do begin
    Bending  (2*dl, 2*dphi, k, 0, 0, 0, 0, 0, 0, 0, 0, d, 1, mode,0,0,0);
    ThinSextupole (dml, d, mode);
  end;
  Bending (dl, dphi, k, 0, tex, gap, 0, k1ex, 0, 0, 0, d, 1, mode,0,0,0);
  Rotation(-rot, idir, mode);
{ this procedure, Combined, is NOT called by tracklib/TrackingMatrix, and only there we need MisalignVector.
  MisVector(TM,sway,heave, mode);
}
  MisAlign(Orbit1, phi, sway, heave, roll, mode,-1);
end;

{------------------------------------------------------------------------------}

procedure Multipole (nord: integer; bnl0, rot, d : real; idir, mode: shortint; sway, heave, roll: real);

var
  bnl, dxp, dyp, b2l, a2l: real;
  ocmplx, kcmplx, gcmplx: complex;
  tm {, rm, rminv}: Matrix_5;
  OrbLoc1, OrbLoc2: Vektor_4;
  coupled: boolean;

begin
  MF_calling:=7;
  coupled:=not Status.Uncoupled;
  MisAlign(Orbit1, 0, sway, heave, roll, mode, 1);
  Rotation(rot, idir, mode);
{
  if rot<>0 then begin
    if glob_test_idir then RM:=Rotation_Matrix(idir*rot) else RM:=Rotation_Matrix(rot);
    coupled:=true;
    OrbLoc1:=LinTra4(MatCut54(rm), Orbit1);
  end else begin
    coupled:=false;
    OrbLoc1:=Orbit1;
  end;
}
  OrbLoc1:=Orbit1;
  bnl:=bnl0/(1+d);
  tm:=Unit_Matrix_5;
  OrbLoc2:=OrbLoc1;
//  coupled:=false; //only true for n>2 and y<>0
  case nord of
    0: Driftspace (0.0, mode);
    1: begin  // n=1, short dipole
      OrbLoc2[2]:=OrbLoc1[2]-bnl; // bnl>0 -> kick to ring inside
      tm[2,5]:=bnl;     // thin dipole: only dispersion production, no focusing
    end;
    2: begin // n=2, short quad, contributes to matrix also for x=y=0
      OrbLoc2[2]:=OrbLoc1[2]-bnl*OrbLoc1[1];  // dx'
      OrbLoc2[4]:=OrbLoc1[4]+bnl*OrbLoc1[3];  // dy'
      tm[2,1]:=-bnl;
      tm[4,3]:= bnl;
      tm[5,2]:= bnl*OrbLoc1[1];
      tm[5,4]:=-bnl*OrbLoc1[3];
    end;
    3: if usesext then begin //n=3, test for comp with general complex calc
      dxp:= -bnl*(sqr(orbloc1[1])-sqr(orbloc1[3])) ;
      dyp:=  2*bnl*orbloc1[1]*orbloc1[3];
      b2l:= 2*bnl*orbloc1[1];
      a2l:= 2*bnl*orbloc1[3];
      Orbloc2[2]:=orbloc1[2]+dxp;
      Orbloc2[4]:=orbloc1[4]+dyp;
      tm[2,1]:=-b2l; tm[4,3]:=b2l;
      tm[2,5]:=-dxp; tm[4,5]:=-dyp;
      if a2l<>0 then begin  tm[2,3]:=a2l; tm[4,1]:=a2l; coupled:=true; end;
    end;
    4: if usesext then begin //n=4, test for comp with general complex calc
      dxp:=  bnl*orbloc1[1]*(3*sqr(orbloc1[3])-sqr(orbloc1[1])) ;
      dyp:=  bnl*orbloc1[3]*(3*sqr(orbloc1[1])-sqr(orbloc1[3])) ;
      b2l:= 3*bnl*(sqr(orbloc1[1])-sqr(orbloc1[3]));
      a2l:= 6*bnl*orbloc1[1]*orbloc1[3];
      Orbloc2[2]:=orbloc1[2]+dxp;
      Orbloc2[4]:=orbloc1[4]+dyp;
      tm[2,1]:=-b2l; tm[4,3]:=b2l;
      tm[2,5]:=-dxp; tm[4,5]:=-dyp;

      if a2l<>0 then begin  tm[2,3]:=a2l; tm[4,1]:=a2l; coupled:=true; end;
    end;

    else if UseSext then begin
 // - dx' + i dy' = bn L (x + iy)^(n-1)
 //quad + skew quad downfeed from multipole, note as-19.4.2016
      ocmplx:=c_get(OrbLoc1[1],OrbLoc1[3]);  // x+iy
      gcmplx:=c_pow(ocmplx,nord-2) ;  // (x+iy)^(n-2)
      kcmplx:=c_sca(c_mul(gcmplx,ocmplx),bnl);            // (x+iy)^(n-1) * bn L
      gcmplx:=c_sca(gcmplx,bnl*(nord-1)) ;  // (n-1)*(x+iy)^(n-2) *bn L

      OrbLoc2[2]:=OrbLoc1[2]-kcmplx.re;  // dx'
      OrbLoc2[4]:=OrbLoc1[4]+kcmplx.im;  // dy'

      tm[2,1]:=-gcmplx.re;
      tm[4,3]:=-tm[2,1];
      tm[5,2]:= kcmplx.re;
      tm[5,4]:=-kcmplx.im;
//needs coupled treatment even without rotation, if orbit is vertically displaced.
      if coupled or (abs(Orbit1[3])> OrbMinHeave) then begin
        coupled:=true;
        tm[2,3]:= gcmplx.im;
        tm[4,1]:= tm[2,3];
      end;
    end;
  end;
{
  if rot<>0 then begin
    rminv:=InvRot5(rm);
    Orbit2:=LinTra4(MatCut54(rminv), OrbLoc2);
    tm:=MatMul5(MatMul5(rminv,tm),rm);
  end else begin
    Orbit2:=OrbLoc2;
  end;
}
  TMat(tm,0);
  Propagate(tm, mode, coupled);
  Orbit2:=OrbLoc2;
  PropForward;
  Rotation(-rot, idir, mode);

  //  MisVector(TM,sway,heave, mode); not used for multipole
  MisAlign(Orbit1, 0, sway, heave, roll, mode,-1);
end;

{------------------------------------------------------------------------------}

procedure Kicker  (l, rot: real; mpol, nkick: integer; kickmax, xoffset, tau, delay, time, d: real; mode: shortint; sway, heave, roll: real);
var
  amp, dl: real;
  k: integer;

  procedure ThinKicker (l, amp: real; mpol:integer; xoffset: real; mode:shortint);
  //need to transfer length l although kicker is thin in order to integrate strength
  var
     b1l, b2l, Si, Sim1, z, arg: real;
     tm: matrix_5;
  begin
    if (mpol > 1) then begin // mpol=0 or 1 is dipole
      if xoffset=0 then begin // treat as pure multipole, then amp = b_mpol
        if l=0 then z:=amp else z:=amp*l;
        arg:=PowI(Orbit1[1],mpol-2)*z;
        b1l:=arg*Orbit1[1];
        b2l:=(mpol-1)*arg;
      end else begin //sin shaped NLK
        amp:=amp/1000; // because in this case, amp stores max kick in mrad!
        z:=Pi/2/xoffset;
        arg:=Orbit1[1]*z;
        if abs(arg)<=2 then begin
          Si:=Sin(arg);
          Sim1:=PowI(Si,mpol-2);
          b1l:=amp*Si*Sim1; //  A*sin^(m-1);
          b2l:=amp*(mpol-1)*Sim1*Cos(arg)*z; // local gradient = A *(m-1) sin^(m-2)*cos*pi/2/xoffset;
//          writeln(diagfil, 'kicker',kickmax, xoffset, time, tau, '|', amp, b1l, b2l, Orbit1[1]);
        end else begin
          b1l:=0; b2l:=0;
        end;
      end;
    end else begin // mpol=1, dipol
      b1l:=amp/1000;
      b2l:=0;
    end;
    Orbit2[2]:=Orbit1[2]+b1l;
    //Orbit1:=Orbit2;
//    Disper1:=Disper2;
    tm:=Unit_Matrix_5;
    tm[2,1]:=-b2l;
    tm[4,3]:= b2l;
    tm[2,5]:= -b1l; //positive kick is like negative bend (in +x direction)
    TMat(tm,0); TMat0(tm);
    Propagate(Tm, mode, false);
    PropForward;
  //  MisVector(TM,sway,heave, mode);
  end;

begin
  // timing for ENTRY of kicker, same in tracking[?] --> change to center?  14.5.2020
  // stimmen die Polaritaeten ?
  if UsePulsed then if abs(time-delay)<tau/2 then begin
    MisAlign(Orbit1, 0, sway, heave, roll, mode, 1);
    Rotation(rot, 1, mode);
    Orbit2:=Orbit1;

    amp:=kickmax/(1+d)*cos(Pi*(time-delay)/tau);
    if l=0 then ThinKicker(l, amp, mpol, xoffset, mode) else begin
      dl:=l/nkick/2;
      for k:=1 to nkick do begin
        DriftSpace(dl, mode);
        ThinKicker(l, amp/nkick, mpol, xoffset, mode);
        DriftSpace(dl, mode);
      end;
    end;


    Rotation(-rot, 1, mode);
    MisAlign(Orbit1, 0, sway, heave, roll, mode,-1);
    //    PropForward;
  end else DriftSpace(l, mode) else DriftSpace(l, mode);
  {Done in tracking
  but still missing HERE: due to Maxwell's div B=0, kick and gradient are different for y<>0.
  --> find magnetostatic potential to get Bx,y(x,y) and gradient.
  requires many distinctions dep. on multipole order, since terms up to sin^(m-4) appear.
  perhaps use undulator potential? ---  do later...
  Present version is only valid for y=0 (ok for most applications on ideal lattice).
  }
end;

{------------------------------------------------------------------------------}

procedure Undulator  ( l, B, lam0, gap, fill1, fill2, fill3, rot, d : real; idir, mode:shortint; half: boolean; sway, heave, roll: real );
{as 230394/100197/110707/29.7.2021}

var
  h0, h, habs2, habs3, k0, kb, k, lam, {phi,} drsh, drb, sumphi, polphi, kedge, psi,
    tedge, go, I1, I2, I3, I4a, I5a, I4b, I5b, Gx, Gy, ci4x: real;
    Npole, iph: integer;
  polfac: array of real;
  AMT, BMT, CoupMT, SigNaT, SigNbT: matrix_2;
  DisperT, DispN, DispS: vektor_4;
  DM, BM, UM: Matrix_5;
  dochrom, doradin: boolean;

  procedure PolInt;
  begin
    DispN:=DRtoDN(DisperT, CoupMT, go);
    DispS:=DNtoDS(DispN, sigNaT, SigNbT);
    //contributions to radiation integrals
    I1 :=I1 + DisperT[1]*h;
    I2 :=I2 + habs2;
    I3 :=I3 + habs3;
    I4a:=I4a+(ci4x*go*DispN[1]);
    I4b:=I4b+(ci4x*(DisperT[1]-go*DispN[1]));
    I5a:=I5a+(Sqr(DispS[1])+Sqr(DispS[2]))*habs3;
    I5b:=I5b+(Sqr(DispS[3])+Sqr(DispS[4]))*habs3;
    //chroma approx: one half of bend and  edge
    Gx:=Gx-SigNaT[1,1]*((habs2+k)*drb/2 + h* tedge)  ;
    Gy:=Gy+SigNbT[1,1]*(       k *drb/2 - h*(tedge-psi));
  end;



begin
  MisAlign(Orbit1, 0, sway, heave, roll, mode, 1);
  Rotation(rot, idir, mode);
  dochrom:=switch(mode,do_chrom);
  doradin:=switch(mode,do_radin);
  //angle per pole in hard edge model. brel = B/Brho
  // number of poles, has to be integer; period is adjusted then.
  Npole:=Round(2*l/lam0);
  lam:=2*l/Npole;
  h0   := B/(Glob.Energy/(speed_of_light/1E9)); {=B/Brho = 1/rho}
  k0   :=0; // no gradient yet in undulator, but may come later
  //kb dpp scaling not correct, fix later
  h0   :=h0/(1+d);
  k0   :=k0/(1+d);

  //angle per center pole
  //  phi  :=h0*lam/2*fill1;
  //fringe field parameter, integration over sine-shaped field
  kedge:=lam/4/gap*(fill1-fill2);

  //alloc array for relative pole strength
  setlength(polfac,Npole);
  UnduPolFacs(polfac, half, idir);

  //series of rectangular bend, length and half distance between:
  drb   :=    fill1*lam/2;
  drsh  :=(1-fill1)*lam/4;

  sumphi:=0.0;
  Gx:=0; Gy:=0;
  I1:=0; I2:=0; I3:=0; I4a:=0; I4b:=0; I5a:=0; I5b:=0;
  sigNaT:=SigNa1; sigNbT:=SigNb1; DisperT:=Disper1; CoupMT:=CoupMatrix1; AMT:=AMat1; BMT:=BMat1;
  go:=sqrt(1-MatDet2(CoupMT));

  UM:=Matuni5;
  DM:=Drift_Matrix(drsh);


  if dochrom or doradin then begin //with integrals
    //propagate drift/bend/drift and get points for integrals before/after bend
    //possible refinement: use intermediate point in bend center for better sampling?
    for iph:=0 to High(polfac) do begin
      MBD_prop(DM, sigNaT, sigNbT, CoupMT, AMT, BMT, DisperT, false);
      SposEl:=SposEl+drsh;
      UM:=MatMul5(DM,UM);
      h:=polfac[iph]*h0;
      k:=k0*polfac[iph];
      kb:=h*h+k;
      psi:=kedge*gap*h;
      polphi:=h*drb;
      habs2:=sqr(h); habs3:=abs(h)*habs2;
      ci4x:=2*h*k; //approx for small rect bend, includes edge contrib; ci4y=0
      tedge:=-sumphi;
      PolInt;
      BM:= Bend_Matrix (drb, h, k, kb, -sumphi, sumphi+polphi, gap, kedge, kedge, 0, 0);
      SposEl:=SposEl+drb;
      MBD_prop(BM, sigNaT, sigNbT, CoupMT, AMT, BMT, DisperT, false);
      UM:=MatMul5(BM,UM);
      sumphi:=sumphi+polphi;
      tedge:=sumphi;
      PolInt;
      MBD_prop(DM, sigNaT, sigNbT, CoupMT, AMT, BMT, DisperT, false);
      SposEl:=SposEl+drsh;
      UM:=MatMul5(DM,UM);
    end; // loop over poles
    //finally apply fill factors and half pole length to get true integrals:
    with Beam do begin
      RadInt1 :=RadInt1 +I1*lam/4*fill1;
      RadInt2 :=RadInt2 +I2*lam/4*fill2;
      RadInt3 :=RadInt3 +I3*lam/4*fill3;
      RadInt4a:=RadInt4a+I4a*lam/4*fill2;
      RadInt4b:=RadInt4b+I4b*lam/4*fill2;
      RadInt5a:=RadInt5a+I5a*lam/4*fill3;
      RadInt5b:=RadInt5b+I5b*lam/4*fill3;
      ChromX  :=ChromX + Gx/4/Pi;
      ChromY  :=ChromY + Gy/4/Pi;
    end;
//    printmat5(UM);
  end

  //not nice to have the same piece of code twice here --> unite
  else begin //short version without integrals
    for iph:=0 to High(polfac) do begin
      SposEl:=SposEl+drsh;
      UM:=MatMul5(DM,UM);
      h:=polfac[iph]*h0;
      k:=k0*polfac[iph];
      kb:=h*h+k;
      polphi:=h*drb;
      BM:= Bend_Matrix (drb, h, k, kb, -sumphi, sumphi+polphi, gap, kedge, kedge, 0, 0);
      SposEl:=SposEl+drB;
      UM:=MatMul5(BM,UM);
      sumphi:=sumphi+polphi;
      SposEl:=SposEl+drsh;
      UM:=MatMul5(DM,UM);
    end; // loop over poles
//     printmat5(UM);
  end;

  TMat(UM,L); TMat0(UM);
  Orbit2:=LinTra54(UM,Orbit1,d);
  Propagate(UM, mode, false);
  PropForward;

  Rotation(-rot, idir, mode);
//  MisVector(TM,sway,heave, mode); --> do later! get undulator matrix U = TM_afer*TM_before^-1 ?
  MisAlign(Orbit1, 0, sway, heave, roll, mode,-1);
  polfac:=nil;
end;

{------------------------------------------------------------------------------}


procedure HCorr(b1l, d: real; idir, mode: shortint; rot, sway, heave, roll: real );
var
  dxp: real;
  HM: Matrix_5;
begin

//!  if switch(mode,do_misal) then begin
    MisAlign(Orbit1, 0, sway, heave, roll, mode,1);
    Rotation(rot, idir, mode);
    dxp:=b1l/(1+d);
    Orbit2:=Orbit1;
    Orbit2[2]:=Orbit1[2]+dxp; // bnl>0 to ring outside, opposite of dipol
    Orbit1:=Orbit2;
    HM:=MatUni5;
    HM[2,5]:=-dxp;
    TMat(HM,0); TMat0(HM);
    Disper2:=Disper1;
    Disper2[2]:=Disper1[2]-dxp; // bnl > 0 -> decrease of dispersion
    Disper1:=Disper2;
    Rotation(-rot, idir, mode);
//  MisVector(TM,sway,heave, mode); no effect without rotation
    MisAlign(Orbit1, 0, sway, heave, roll, mode,-1);
//!  end;
end;

{------------------------------------------------------------------------------}

procedure VCorr(a1l, d: real; idir, mode: shortint; rot, sway, heave, roll: real );
var
  dyp: real;
  VM: Matrix_5;
begin
//!  if switch(mode,do_misal) then begin
    MisAlign(Orbit1, 0, sway, heave, roll, mode,1);
    Rotation(rot, idir, mode);
    Orbit2:=Orbit1;
    dyp:=+a1l/(1+d);
    Orbit2[4]:=Orbit1[4]+dyp;
    Orbit1:=Orbit2;
    VM:=MatUni5;
    VM[4,5]:=-dyp;
    TMat(VM,0); TMat0(VM);
    Disper2:=Disper1;
    Disper2[4]:=Disper1[4]-dyp;
    Disper1:=Disper2;
    Rotation(-rot, idir, mode);
//  MisVector(TM,sway,heave, mode); no effect without roll
    MisAlign(Orbit1, 0, sway, heave, roll, mode,-1);
//!  end;
end;

{------------------------------------------------------------------------------}

procedure Monitor(idir, mode: shortint; rot, sway, heave, roll: real);
begin
// nothing to do for the moment, just a placeholder for Lattel
{  if switch(mode,do_misal) then begin
    MisAlign(Orbit1, 0, sway, heave, roll, mode,1);
    Rotation(rot, mode);
    Orbit2:=Orbit1;
    Rotation(-rot, mode);
    MisAlign(Orbit1, 0, sway, heave, roll, mode,-1);
  end;
}
end;

{==============================================================================}

end.

