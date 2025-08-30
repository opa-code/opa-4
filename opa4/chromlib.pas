 {
Calculation of sext hamiltonians to 2nd order based on J.Bengtsson's equations.
Numerical differentiation for chroma up to 3rd order

also: Chun-xi Wang, Explicit formulas for 2nd-order driving terms due to sextupoles and chromatic effects
of quadrupoles, ANL/APS/LS-330

Improved scaling of Hamiltonians (proc Hamscaling) to make them comparable, as Feb.2025 v.4.061

define consistently Hamiltonians NOT including the factor 2 from (2J),
so the actual term is given by hjklmp*(2Jx)^(j+k)/2 etc. - 7.feb-12 v.3.38

corrected quad sign error, and adjustment to Chun-xi Wangs formulae for 2nd
order sextupole terms by using the negative phase. as-27.feb-12 v.3.39

included H10002 term jul-10

include octupoles nov-08

change to summation over families instead of single sextupoles
as-april-08                                                           

}


unit chromlib;

{$MODE Delphi}
interface

uses stdctrls, globlib, ASaux, Vgraph, graphics, linoplib, elemlib, opatunediag,
      MathLib, Forms, Sysutils, Controls;

const
  nSexColor=12;
  SexColor : array[0..nSexColor-1] of TColor = (
    $009999ff, $00ff9999, $0099ff99, $00ff99ff, $00ffff99, $0099ffff,
    $00ffaa99, $0099ffaa, $00aa99ff, $00ff99aa, $00aaff99, $0099aaff);
  ChromActiveColor = $0000ccff;
  HamResActiveColor = $00ffcc00;

  nCHamilton=26;
  HamCap:array[0..nCHamilton-1] of string[15] =
         ('CrX lin        ', 'CrY lin        ',
          ' Qx     H21000 ', '3Qx     H30000 ', ' Qx     H10110 ',
          ' Qx-2Qy H10020 ', ' Qx+2Qy H10200 ', '2Qx     H20001 ', '2Qy     H00201 ',
          ' Qx     H10002 ', 'CrX sqr        ', 'CrY sqr        ',
          'dQxx           ', 'dQxy,yx        ', 'dQyy           ',
          '2Qx     H31000 ', '4Qx     H40000 ', '2Qx     H20110 ', '2Qy     H11200 ',
          '2Qx-2Qy H20020 ', '2Qx+2Qy H20200 ', '2Qy     H00310 ', '4Qy     H00400 ',
          'CrX cub        ', 'CrY cub        ', 'Sum (b3L)^2    ');

// indices and scaling factors for 1st order sextupole modes:
  ism1: array[0..9] of array[0..4] of shortint=
   ((1,1,0,0,1),(0,0,1,1,1),(2,1,0,0,0),(3,0,0,0,0),(1,0,1,1,0),(1,0,0,2,0),(1,0,2,0,0),(2,0,0,0,1),(0,0,2,0,1),(1,0,0,0,2));
  sclsm1: array [0..9] of real=
   (  1/(4*Pi) , -1/(4*Pi) ,    1/8    ,   1/24    ,  -1/4     ,   -1/8    ,   -1/8    ,   1/4     ,  -1/4,     1/2 );

// indices and scaling factors for 1st order octupole modes: (j,k,l,m,p)
  iom1: array[15..22] of array[0..3] of shortint=
   ((3,1,0,0),(4,0,0,0),(2,0,1,1),(1,1,2,0),(2,0,0,2),(2,0,2,0),(0,0,3,1),(0,0,4,0));
  sclom1: array[15..22] of real=
   ( 1/16     , 1/64    , -3/16    , -3/16    , -3/32   , -3/32   , 1/16     , 1/64    );

  // indices for amplitude dependence
    jklmp: array[0..24] of array[0..4] of shortint=
    ((1,1,0,0,1),(0,0,1,1,1),
     (2,1,0,0,0),(3,0,0,0,0),(1,0,1,1,0),(1,0,0,2,0),(1,0,2,0,0),
     (2,0,0,0,1),(0,0,2,0,1),(1,0,0,0,2),
     (1,1,0,0,2),(0,0,1,1,2),
     (2,2,0,0,0),(1,1,1,1,0),(0,0,2,2,0),
     (3,1,0,0,0),(4,0,0,0,0),(2,0,1,1,0),(1,1,2,0,0),
     (2,0,0,2,0),(2,0,2,0,0),(0,0,3,1,0),(0,0,4,0,0),
     (1,1,0,0,3),(1,1,0,0,3));



//bookkeeping for octupole modes: (mode, 1/scl, j1,k1,l1,m1,  j2,k2,l2,m2)

  ism2: array[0..17] of array[0..9] of shortint=
   ((15, 32, 1,2,0,0, 3,0,0,0),        //  3100, 2Qx
    (16, 64, 2,1,0,0, 3,0,0,0),        //  4000, 4Qx
    (17, 32, 3,0,0,0, 0,1,1,1),        //  2011, 2Qx
    (17, 32, 1,0,1,1, 2,1,0,0),
    (17, 16, 1,0,0,2, 1,0,2,0),
    (18, 32, 1,0,2,0, 1,2,0,0),        //  1120, 2Qy
    (18, 32, 2,1,0,0, 0,1,2,0),
    (18, 16, 0,1,1,1, 1,0,2,0),
    (18, 16, 1,0,1,1, 0,1,2,0),
    (19, 64, 1,0,0,2, 2,1,0,0),        //  2002, 2Qx-2Qy
    (19, 64, 3,0,0,0, 0,1,0,2),
    (19, 16, 1,0,0,2, 1,0,1,1),
    (20, 64, 3,0,0,0, 0,1,2,0),        //  2020, 2Qx+2Qy
    (20, 64, 1,0,2,0, 2,1,0,0),
    (20, 16, 1,0,1,1, 1,0,2,0),
    (21, 32, 0,1,2,0, 1,0,1,1),        //  0031, 2Qy
    (21, 32, 0,1,1,1, 1,0,2,0),
    (22, 64, 0,1,2,0, 1,0,2,0));       //  0040, 4Qy

  HamResonant: array[0..nCHamilton-1] of Boolean = (
    False, False,
    True, True, True, True, True, True, True, True,
    False, False, False, False, False,
    True, True, True, True, True, True, True, True,
    False, False, True);

{indices:
  lin chromas:            0, 1
  1st orders res:         2...9
  sqr chromas:            10,11
  tune shifts:            12,13,14
  2nd order res:          15...22
  cub chromas:            23,24
  sqr bsum of all sext    25
}

type


// single sextupole types:
  SextupolType =  record
    ifam : integer; // family index
//    ipos : integer; // lattice position
    sbx, sby, eta, mux, muy: real; // optics parameters
  end;

// pointer for kidlist
  kidpt = ^kidType;
  kidType = record
    isx: word;
    nex: kidpt;
  end;

// sextupole family type, indices corresping to TCSex family controls
  SexFamType = record
    jel: integer; // Ella-index
    // integrated strength of sextupole SLICE:
    ml, ml0: real; // current strength and save initial strength
    {ml=integrated strength PER sextupole in case of slicing}
    nslice: integer; //number of slices (sub-sextupoles)
    col: TColor; // display color
    chromActive, chromEnabled, locked: boolean;
    kid: kidpt; // start of kids list
  end;

  SM1_row   =array[0..9] of complex;
  SM2_row   =array[12..22] of complex;
  SM2mod_row=array[0..17] of complex;

  OctuFamType = record
    b4L, b4L0, b4Lsave: real;
    omat, omatpre: array[10..14] of real;
    om1, om1pre: array[15..22] of complex;
    jel, n: integer;
    locked: boolean;
    col: TColor;
  end;

  DecaFamType = record
    b5L, b5L0: real;
    dmat: array[23..24] of real;
    jel, n: integer;
    locked: boolean;
    col: TColor;
  end;

var
  labpen_handle:TLabel; //only that for Powell's penaltyfunction can tell

  Sextupol : array of SextupolType;
  SexFam   : array of SexFamType;
  SVector  : array of complex;

  SM1, SM1pre: array of SM1_row;
  SM2: array of SM2_row;
  SM2dif, SM2sum: array of SM2mod_row;

  OctuFam: array of OctuFamType;
  DecaFam: array of DecaFamType;

// packed arrays A/U (m x n) and V(n x n)
// vector of eigenvalues W (n): array[0,1,..n], uses only [1..n] !!!
  osvd_aupack, osvd_vpack, osvd_wuse, osvd_w: array of real;
  osvd_iham, osvd_ifam: array of integer;
  osvd_enable, osvd_active: boolean;
  osvd_null: integer;

// variable and constant parts of Hamiltonian:
// (phase independent terms always Im=0)
  HamV, HamT: array[0..nCHamilton-1] of complex;
// absolute value, target, weight factor and value to be shown
  HamAbs, HamTarg, HamWeight, HamShow, HScal: array[0..nCHamilton] of real;
  HamAbsMax: real;
  H2Qxpre, H2Qypre, HQxPpre, H2Qx, H2Qy, HQxP: complex;

// scaling parameters 2Jx etc.
  scaling: array[0..3] of real;
// dpp to be used for numeric diff.
  dppnumdiff: double;
// range and steps for manual changes
  maxSexK, stepSexK, maxOctK, stepOctK, maxDecK, stepDecK, minAmp: real;

  SFSDFlag: array[0..1] of integer;
  ChromMatrix: array[0..1,0..1] of double;

  AutoChrom, Include2Q, IncludeQxx,IncludeCr2, IncludeOct: Boolean;

  VSelect, VSelectOld, VSelectMax: integer;
  VDPH: VPlot;

  NSexPer, PerScaFac: integer;

  //array for path length coefficients
  path_al: array[0..3] of Extended;

  oc_sx_addmode: boolean;

  osvd_wnull: real;

  fload_dir: string;

  include_combined: boolean;

procedure ChromInit;
procedure ChromSaveDef;
procedure ChromDispose;
procedure DriveTerms_2Q;
procedure DriveTerms_Qxx;
procedure DriveTerms_Oct;
procedure DriveTerms_Cr2;
procedure DriveTerms_Sum;
procedure DriveTerms;
function Penalty: double;
procedure HamScaling;
procedure set_cd_matrix;
procedure UpdateSexFam   (ifam: integer;    val: real);
procedure UpdateSexFamInt(ifam: integer; intval: real);
procedure UpdateOctFamInt(ifam: integer; intval: real);
function  UpdateChromMatrix: Boolean;
procedure getLinChroma (var cx, cy: double);
procedure ChromCorrect;
procedure getSvector (p : integer);
procedure TDiagPlot;
procedure TDiagPlotFull;
procedure S_matrix;
procedure S_Period (nper: integer);
procedure S_TestOut;
procedure closeTuneDiagram;
procedure Oct_svdcmp(keep_osvd_null:boolean);
procedure Oct_svbksb;
procedure setTunePlotHandle(TP: TtunePlot);
procedure setLabPenHandle(LP: Tlabel);


implementation

// "private" vars:
var
  cd_matrix: array[0..3,0..3] of extended;
  Qx_reference, Qy_reference: Extended;
  ChromX_noSex, ChromY_noSex: Double;
  newkid: kidpt;
  firstkid: boolean;

  tuneplothandle: TtunePlot;


//------------------------------------------------------------------------


procedure Oct_SVDCMP (keep_osvd_null:boolean);
var
  iha, mi, m, n, i, j: integer;
  w: real;
begin
  osvd_aupack:=nil;  osvd_vpack:=nil;  osvd_w:=nil;

  m:=0;
  for i:=0 to High(osvd_iham) do if osvd_iham[i]>14 then Inc(m,2) else Inc(m);
// add 2 lines to linear system for resonant terms (re+im)


  osvd_ifam:=nil;
  for i:=0 to High(OctuFam) do if not OctuFam[i].locked then begin
    setlength(osvd_ifam,length(osvd_ifam)+1);
    osvd_ifam[High(osvd_ifam)]:=i;
  end;
  n:=Length(osvd_ifam);

  if (n>1) and (m>1) then begin
    setlength(osvd_aupack, m*n);
    setlength(osvd_vpack,n*n);
    setlength(osvd_w,n+1);
    setlength(osvd_wuse,n+1);

    mi:=0; // counts to m
    for i:=0 to High(osvd_iham) do begin
      iha:=osvd_iham[i];
      w:=Hscal[iha]*(PowR(2,Hamweight[iha])-1);
      if osvd_iham[i]>14 then begin
//        for j:=0 to n-1 do osvd_aupack[mi*n+j]:=OctuFam[osvd_ifam[j]].om1pre[osvd_iham[i]].re;
        for j:=0 to n-1 do osvd_aupack[mi*n+j]:=OctuFam[osvd_ifam[j]].om1[iha].re*w;
        Inc(mi);
//        for j:=0 to n-1 do osvd_aupack[mi*n+j]:=OctuFam[osvd_ifam[j]].om1pre[osvd_iham[i]].im;
        for j:=0 to n-1 do osvd_aupack[mi*n+j]:=OctuFam[osvd_ifam[j]].om1[iha].im*w;
        Inc(mi);
      end else begin
        for j:=0 to n-1 do  osvd_aupack[mi*n+j]:=OctuFam[osvd_ifam[j]].omat[iha]*w;
        Inc(mi);
     end;
    end;

    SVDCMP(osvd_aupack, m, n, osvd_w, osvd_vpack);
    for i:=0 to n do osvd_wuse[i]:=osvd_w[i];
    if not keep_osvd_null then osvd_null:=0; //number of weighting factors set to zero

    osvd_enable:=true;
  end else osvd_enable:=false;
end;

procedure Oct_SVBKSB;
var
  vec, oct: array of real;
  iha, mi, n, m, i, ifam: integer;
  w: real;
begin
  if osvd_enable then begin
    n:=length(osvd_ifam);
    setlength(oct,n+1); //1 more

    m:=0;
    for i:=0 to High(osvd_iham) do if osvd_iham[i]>14 then Inc(m,2) else Inc(m);
    setlength(vec,m+1);

    mi:=0; // counts to m
    for i:=0 to High(osvd_iham) do begin
      iha:=osvd_iham[i];
      w:=Hscal[iha]*(PowR(2,Hamweight[iha])-1);
      if iha>14 then begin
        vec[mi+1]:=-HamV[iha].re*w; Inc(mi);
        vec[mi+1]:=-HamV[iha].im*w; Inc(mi);
      end else begin
//        vec[mi+1]:=-(HamV[osvd_iham[i]].re-HamTarg[osvd_iham[i]])/PerScaFac; Inc(mi);
        vec[mi+1]:=-(HamV[iha].re-HamTarg[iha])*w; Inc(mi);
      end;
    end;

//    for i:=0 to m-1 do vec[i+1]:=-(HamV[osvd_iham[i]].re-HamTarg[osvd_iham[i]])/PerScaFac;
    SVBKSB(osvd_aupack, osvd_wuse, osvd_vpack, m, n, vec, oct);
    for i:=0 to n-1 do begin
      ifam:=osvd_ifam[i];
      UpdateOctFamInt(ifam, OctuFam[ifam].b4L+oct[i+1]);
    end;
    oct:=nil; vec:=nil;
  end;
end;

//------------------------------------------------------------------------


procedure closeTuneDiagram;
begin
  tuneplothandle.close;
end;

procedure setTunePlotHandle(TP: TtunePlot);
begin
  tuneplothandle:=TP;
end;

procedure setLabPenHandle(LP: Tlabel);
begin
  LabPen_Handle:=LP;
end;
//------------------------------------------------------------------------

// scale Hamiltonians with "relevant" amplitudes to make them comparable
// but don't consider the Hamiltonian but its derivative dH/dJ because this
// gives the change of betatron phase, thus more relevant than H itself.
// with regard to coupled motion use
// Jbar^[(j+k+l+m)/2]=Jx^[(j+k)/2]*Jy^[(l+m)/2] and calc dH/dJbar
// Feb-2025

procedure HamScaling;
var
 //  x,y,p,f: real;
  x, y, p, jxpow, jypow, jbar :real;
  i, ijklm:integer;

begin
  x:=scaling[0]*1E-6; // 2Jx
  y:=scaling[1]*1E-6; // 2Jy
  p:=scaling[2]*1E-2; // dpp
//  f:=PowR(10,scaling[3]); // factor,  not to chromaticities (and tune shifts? f^2?}
  for i:=0 to 24 do begin
    ijklm:=jklmp[i,0]+jklmp[i,1]+jklmp[i,2]+jklmp[i,3];
    jxpow:=PowR(x, (jklmp[i,0]+jklmp[i,1])/2);
    jypow:=PowR(y, (jklmp[i,2]+jklmp[i,3])/2);
    jbar:= PowR( jxpow*jypow, 2/ijklm)/ PowR(2,ijklm/2);   //it's J not 2J
    if jbar>0 then HScal[i]:=ijklm/2*jxpow*jypow/jbar*PowI(p,jklmp[i,4]) else HScal[i]:=0;
  //  writeln(i,' ',jxpow, jypow, jbar, Hscal[i])  ;
  end;
  HScal[25]:=1/PowR(10,scaling[3]);
end;

//---------------------------------------------------------------------
// calculate Ham-values to be shown, plotted and added up in Minimizer


function Penalty: double;
var
  i:integer;
  hval: double;
  w: double;
  psum: double;
begin
  HamAbsMax:=0.0;
  psum:=0.0;
  for i:=0 to nCHamilton-1 do HamT[i]:=HamV[i];
  HamT[7]:=c_add(H2Qx, HamT[7]);
  HamT[8]:=c_add(H2Qy, HamT[8]);
  HamT[9]:=c_add(HQxP, HamT[9]);

  for i:=0 to nCHamilton-1 do begin
    w:=PowR(2,HamWeight[i])-1;
//    HamT[i]:=c_add(HamC[i],HamV[i]);
    if HamResonant[i] then begin
      hval:=c_abs(HamT[i]);
      HamAbs[i]:=w*HScal[i]*hval;
    end else begin
      hval:= HamT[i].re;
      HamAbs[i]:=w*HScal[i]*abs(hval-HamTarg[i]);
    end;
    HamShow[i]:=hval;
    if HamAbs[i]>HamAbsMax then HamAbsMax:=HamAbs[i];
    psum:=psum+sqr(HamAbs[i]);
  end;
  Penalty:=psum;
end;

//---------------------------------------------------------------
{
   set up a constant matrix to calculate 3rd order chromaticity
   polymoninals for 4 runs dQx, dQy as fct of [-3/-1/+1/+3] *dppnumdiff
}

procedure set_cd_matrix;
const
  icdmat: array[0..3, 0..3] of integer =
    ( (-3, 27, 27, -3), (1, -27, 27, -1), (3, -3, -3, 3), (-1, 3, -3, 1) );
var
  j, k: integer;
  dp_pow: extended;
begin
  dp_pow:=1.0;
  for j:=0 to 3 do begin
    for k:=0 to 3 do cd_matrix[j,k]:=icdmat[j,k]/dp_pow/48;
    dp_pow:=dp_pow*dppnumdiff/3;
  end;
end;

//-------------------------------------------------------------------------
// Initialization

procedure ChromInit;

{counts sextupole families, sets preliminary jsf,jsd
 Msx = total, Msxav = available Number of Sext.fam.}

//const
//??  dpp=0.0; // preliminary; ok for chroma but not for tune shifts in tracking

var i, ii, j, k, koc, noc: integer;
//    helparr: array[1..20] of integer;
    SjDa: Boolean;
    bx0, bxi, bxf, by0, byi, byf,  et0, eti, etf, mx0, mxi, mxf, my0, myi, myf,
    kl, avbc, avbs, der1, der2, dek11, dek12, dl, dphi, dml: real;
    mfail: boolean;

    nsext, ncomb: integer;
    dh2Qx, dh2Qy, dhQxP: complex;
    latmode: shortint;
//    MX: Matrix_5;


//.............................................................
// build linked list of kids
// isext is number of sextupole
  function AppendKid(var kid: kidpt; isext: word): kidpt;
  var
    nextkid: kidpt;
  begin
    New(nextkid);
    kid.nex:=nextkid;
    nextkid.isx:=isext;
    nextkid.nex:=nil;
    AppendKid:=nextkid;
  end;

//.............................................................

  procedure AppendSext(jelem: integer; b3l: real);
  var
    i:integer;
  begin
    setLength(Sextupol, length(Sextupol)+1);
    ThinSextupole (b3l, 0, 0); {set mode=0 to NOT add chroma!}
    with Sextupol[High(Sextupol)] do begin
      sbx:=sqrt(sigNa2[1,1]); sby:=sqrt(SigNb2[1,1]); eta:=Disper2[1];
      mux:=2*Pi*Beam.Qa; muy:=2*Pi*Beam.Qb;
      // find my family:
      for i:=0 to High(SexFam) do if SexFam[i].jel=jelem then ifam:=i;
    end;
  end;

{  procedure AppendOct(jelem: integer; b4l: real);
  var
    i:integer;
  begin
    setLength(Octupol, length(Octupol)+1);
    Octu (b4l, 0);
    with Octupol[High(Octupol)] do begin
      sbx:=sqrt(P2[1,1]); sby:=sqrt(P2[3,3]); eta:=D2[1];
      mux:=2*Pi*Beam.Qx; muy:=2*Pi*Beam.Qy;
      // find my family:
      for i:=0 to High(OctuFam) do if Octu[i].jel=jelem then ifam:=i;
    end;
  end;
}

//.............................................................

begin
  OPALog(3,' sextupole optimization ');

  setStatusLabel(stlab_chr,status_void);
  setStatusLabel(stlab_cmx,status_void);
  setStatusLabel(stlab_tsh,status_void);

  SexFam:=nil;
  Sextupol:=nil;
  SVector:=nil;
  OctuFam:=nil;
  DecaFam:=nil;

// set scaling par to default
  scaling[0]:=FDefGet('chrom/2jx');
  scaling[1]:=FDefGet('chrom/2jy');
  scaling[2]:=FDefGet('chrom/dpp');
  scaling[3]:=FDefGet('chrom/rfac');
  maxSexK   :=FDefGet('chrom/kmax');
  stepSexK  :=FDefGet('chrom/kstp');
  maxOctK   :=FDefGet('chrom/omax');
  stepOctK  :=FDefGet('chrom/ostp');
  maxDecK   :=FDefGet('chrom/dmax');
  stepDecK  :=FDefGet('chrom/dstp');
  dppnumdiff:=FDefGet('chrom/dpnd');
  minAmp    :=FDefGet('chrom/mamp');

  AutoChrom:=False;
  Include2Q :=IDefGet('chrom/inc2q' )=1;
  IncludeQxx:=IDefGet('chrom/incqxx')=1;
  IncludeCr2:=IDefGet('chrom/inccr2')=1;
  IncludeOct:=IDefGet('chrom/incoct')=1;
  include_combined:=IDefGet('chrom/inccom')=1;
  // initialize the Hamiltonians to complex zeros
  for i:=0 to  nCHamilton-1 do begin
    HamV[i]:=c_get(0.0,0.0);
    HamAbs[i] :=0.0;
    HamShow[i]:=0.0;
    HamTarg[i]:=0.0;
  end;
  H2Qxpre:=c_get(0,0); H2Qypre:=c_get(0,0); HQxPpre:=c_get(0,0);

  //load defaults for target values lin. sqr, cub chroma and amp dep tune shifts
  HamTarg[ 0]:=FDefGet('chrom/tarc1x');
  HamTarg[ 1]:=FDefGet('chrom/tarc1y');
  HamTarg[10]:=FDefGet('chrom/tarc2x');
  HamTarg[11]:=FDefGet('chrom/tarc2y');
  HamTarg[23]:=FDefGet('chrom/tarc3x');
  HamTarg[24]:=FDefGet('chrom/tarc3y');
  HamTarg[12]:=FDefGet('chrom/tarqxx');
  HamTarg[13]:=FDefGet('chrom/tarqxy');
  HamTarg[14]:=FDefGet('chrom/tarqyy');
  for i:=0 to  nCHamilton-1 do begin
    HamWeight[i]:=IDefGet('chrom/hw'+Copy(InttoStr(i+100),2,2));
  end;

// - - - - - - - - - - - - - -

  set_cd_matrix;
  for j:=0 to 1 do SFSDFlag[j]:=-1;

// find the sextupole/combined families:
  nsext:=0;
  ncomb:=0;
  for j:=1 to Glob.NElla  do begin
    if Ella[j].cod in [csext,ccomb] then begin
      SjDa:=False;
      for i:=1 to Glob.NLatt do SjDa:=SjDa or (Lattice[i].elnam=Ella[j].nam);
      if SjDa then begin
        setlength(SexFam  ,length(SexFam)+1);
        with SexFam[High(SexFam)] do begin
          jel:=j;
          with Ella[jel] do begin
            if cod=csext then begin
              if l=0 then nslice:=1 else nslice:=sslice;
              col:=SexColor[nsext mod nSexColor];
              inc(nsext);
            end else begin
              nslice:=cslice;
              col:=dimcol(SexColor[ncomb mod nSexColor],clNavy,0.5);
              inc(ncomb);
            end;
            ml0:=getSexKval(jel)*nslice;
          end;
          // some default settings for the family
          chromEnabled:=true;
          ChromActive:=False;// later:  ChromActive:= (SFSDFlag[0]=i) or (SFSDFlag[1]=i);
          Locked:=False;
        end;
      end;
    end;
  end;

 { also other elements contribute to the Hamiltonian, like Quads to 2Qx/y
   and rigid sextupole components in combined function magnets. But these
   contributions are constant  - ??? what about solenoids ?
}

  // now go around the lattice and gather all the data we need....

  UseSext:=True;
  ClosedOrbit(mfail, do_twiss, 0.0);
  latmode:=do_twiss+do_chrom;

//??? distinguish periodic/symmetric to get asymmetric structures
  Periodic (mfail);
//  Symmetric (mfail);
  if mfail then OPALog(1,'ChromInit found no periodic solution');
  OptInit;
  for i:=1 to Glob.NLatt do begin

    j:=FindEl(i);
    with Ella[j] do begin

      case cod of

        cdrif : DriftSpace(l,latmode);

        cquad, cbend, ccomb: begin

     // get optical funtions at enttry, center and exit of the elements:
          bxi:=sigNa2[1,1]; byi:=SigNb2[1,1]; mxi:=2*pi*Beam.Qa; myi:=2*pi*Beam.Qb;
          eti:=Disper2[1];

          if cod= cquad then begin
            Quadrupole  (l/2, kq, rot, 0, 1, latmode, 0,0,0);
            bx0:=sigNa2[1,1]; by0:=SigNb2[1,1]; mx0:=2*pi*Beam.Qa; my0:=2*pi*Beam.Qb;
            et0:=Disper2[1];
            Quadrupole  (l/2, kq, rot, 0, 1, latmode, 0,0,0);
            kl:=kq*l;
          end

          else if cod= cbend then begin
    //split bend suppressing artificial edge focussing from split plane:
            if Lattice[i].inv>0 then Bending  (l/2, phi/2, kb, tin, 0, gap, k1in, 0, k2in, 0, rot, 0, 1,latmode, 0,0,0)
                                else Bending  (l/2, phi/2, kb, tex, 0, gap, k1ex, 0, k2ex, 0, rot, 0, 1,latmode, 0,0,0);
            bx0:=sigNa2[1,1]; by0:=SigNb2[1,1]; mx0:=2*pi*Beam.Qa; my0:=2*pi*Beam.Qb;
            et0:=Disper2[1];
            if Lattice[i].inv>0 then Bending  (l/2, phi/2, kb, 0, tex, gap, 0, k1ex, 0, k2ex, rot, 0, 1,latmode, 0,0,0)
                                else Bending  (l/2, phi/2, kb, 0, tin, gap, 0, k1in, 0, k2in, rot, 0, 1,latmode, 0,0,0);
            kl:=kb*l;
          end

          else if cod=ccomb then begin
            if Lattice[i].inv>0 then begin
              der1:=cerin; der2:=cerex; dek11:=cek1in; dek12:=cek1ex;
            end else begin
              der1:=cerex; der2:=cerin; dek11:=cek1ex; dek12:=cek1in;
            end;
            dl  :=l/(2*cslice);
            dphi:=cphi/(2*cslice);
            dml :=cms*2*dl; //integrated sextupole of slice
            dh2Qx:=c_get(0,0); dh2Qy:=c_get(0,0); dhQxP:=c_get(0,0);
            for ii:=1 to cslice do begin
              if ii=1      then Bending (dl, dphi, ckq, der1, 0, cgap, dek11, 0, 0, 0, rot, 0, 1, latmode, 0,0,0)
                           else Bending (dl, dphi, ckq,   0,  0,    0,    0,  0, 0, 0, rot, 0, 1, latmode, 0,0,0);
              AppendSext(j, dml);
              dh2Qx:=c_add(dh2Qx,c_exp(  -ckq*dl*SigNa2[1,1]/4,4*pi*Beam.Qa));
              dh2Qy:=c_add(dh2Qy,c_exp(  +ckq*dl*SigNb2[1,1]/4,4*pi*Beam.Qb));
              dhQxP:=c_add(dhQxP,c_exp(  -ckq*dl*sqrt(SigNa2[1,1])*Disper2[1]/2,2*pi*Beam.Qa));
              if ii=cslice then Bending (dl, dphi, ckq, 0, der2, cgap, 0, dek12, 0, 0, rot, 0, 1, latmode, 0,0,0)
                           else Bending (dl, dphi, ckq,   0,  0,    0,    0,  0, 0, 0, rot, 0, 1, latmode, 0,0,0);
            end;
          end;

// get approx. 2Qx/2Qy contribution from all gradients:
// this is ok even for ccomb since for on-momentum sextupole does not affect the betas
// but done separately since ccomb has no center point in case of odd clslice
          if cod=ccomb then begin
            H2Qxpre:=c_add(H2Qxpre, dh2Qx);
            H2Qypre:=c_add(H2Qypre, dh2Qy);
            HQxPpre:=c_add(HQxPpre, dhQxP);
          end else begin {quad, bend}
            bxf:=sigNa2[1,1]; byf:=SigNb2[1,1]; mxf:=2*pi*Beam.Qa; myf:=2*pi*Beam.Qb;
            etf:=Disper2[1];
            avbc:= 1/6*bxi*cos(2*mxi)+4/6*bx0*cos(2*mx0)+1/6*bxf*cos(2*mxf);
            avbs:= 1/6*bxi*sin(2*mxi)+4/6*bx0*sin(2*mx0)+1/6*bxf*sin(2*mxf);
//            H2Qxpre:=c_sub(H2Qxpre, c_sca(c_get(avbc,avbs), 0.5*kl));
            H2Qxpre:=c_add(H2Qxpre, c_sca(c_get(avbc,avbs), -kl/8));
            avbc:= 1/6*byi*cos(2*myi)+4/6*by0*cos(2*my0)+1/6*byf*cos(2*myf);
            avbs:= 1/6*byi*sin(2*myi)+4/6*by0*sin(2*my0)+1/6*byf*sin(2*myf);
//            H2Qypre:=c_sub(H2Qypre, c_sca(c_get(avbc,avbs),-0.5*kl));
            H2Qypre:=c_add(H2Qypre, c_sca(c_get(avbc,avbs), kl/8));
            avbc:= 1/6*sqrt(bxi)*eti*cos(mxi)+4/6*sqrt(bx0)*et0*cos(mx0)+1/6*sqrt(bxf)*etf*cos(mxf);
            avbs:= 1/6*sqrt(bxi)*eti*sin(mxi)+4/6*sqrt(bx0)*et0*sin(mx0)+1/6*sqrt(bxf)*etf*sin(mxf);
//            HQxPpre:=c_sub(HQxPpre, c_sca(c_get(avbc,avbs), 2*kl));
            HQxPpre:=c_add(HQxPpre, c_sca(c_get(avbc,avbs), -kl/2));
          end;
        end;

        csext : begin
          if l=0 then AppendSext(j, ms) else begin
            dl  :=l/(2*sslice);
            dml :=ms*2*dl; //integrated sextupole of slice
            for ii:=1 to sslice do begin
              DriftSpace (dl,latmode);
              AppendSext(j, dml);
              DriftSpace (dl,latmode);
            end;
          end;
        end;

        csole : Solenoid   (l, ks, 0, 1, latmode, 0,0,0);
        cundu : Undulator  (l, bmax, lam, ugap, fill1, fill2, fill3, rot, 0, 1, latmode, halfu,0,0,0);

// Octupoles: get the contributions to non-resonant terms
// actually only tu.sh. needed, since 2nd ord.chrom from num diff (includes octu)
        cmpol : begin
          if nord = 4 then begin // Octupole
            Multipole(nord, bnl, 0.0, 0.0, 1, latmode, 0,0,0);
            noc:=-1;
// check if we have this family already
            for koc:=0 to High(OctuFam) do if OctuFam[koc].jel=j then noc:=koc;
            if noc=-1 then begin
              setlength(OctuFam, Length(OctuFam)+1);
              noc:=High(OctuFam);
              with OctuFam[noc] do begin
                for k:=10 to 14 do omatpre[k]:=0.0;
                for k:=15 to 22 do om1pre[k]:=c_get(0,0);
                jel:=j;
                b4l:=bnl; b4L0:=bnl;
                n:=0;
                Locked:=False;
                col:=dimcol(SexColor[noc mod nSexColor],oc_col,0.5);
              end;
            end;
            with OctuFam[noc] do begin
// oct contrib to 2nd ord. chroma and tune shifts;
// factor 1/2 for tune shifts since here def'd as dQ/(2J)
              omatpre[10]:=omatpre[10]+3/(4*Pi)*SigNa2[1,1]*sqr(Disper2[1]);
              omatpre[11]:=omatpre[11]-3/(4*Pi)*SigNb2[1,1]*sqr(Disper2[1]);
              omatpre[12]:=omatpre[12]+3/(8*Pi)*sqr(SigNa2[1,1])   *0.5;
              omatpre[13]:=omatpre[13]-3/(4*Pi)*SigNa2[1,1]*SigNb2[1,1]*0.5;
              omatpre[14]:=omatpre[14]+3/(8*Pi)*sqr(SigNb2[1,1])   *0.5;
// oct contrib to 1st order oct resonances
              for k:=15 to 22 do begin
                om1pre[k]:=c_add(om1pre[k], c_exp(
                   sclom1[k]*PowI(SigNa2[1,1],(iom1[k,0]+iom1[k,1]) div 2)*PowI(SigNb2[1,1],(iom1[k,2]+iom1[k,3]) div 2),
                   2*Pi*((iom1[k,0]-iom1[k,1])*Beam.Qa+(iom1[k,2]-iom1[k,3])*Beam.Qb)));
              end;
//              writeln(diagfil,'octufam ',noc,' ',n,' ',b4l, b4L0, signa2[1,1],signb2[1,1],Beam.Qa, Beam.Qb);
              Inc(n);
            end;
          end;
          if nord = 5 then begin // Decapole
            Multipole(nord, bnl, 0.0, 0.0, 1, latmode, 0,0,0);
            noc:=-1;
            for koc:=0 to High(DecaFam) do if DecaFam[koc].jel=j then noc:=koc;
            if noc=-1 then begin
              setlength(DecaFam, Length(DecaFam)+1);
              noc:=High(DecaFam);
              with DecaFam[noc] do begin
                for k:=23 to 24 do dmat[k]:=0.0;
                jel:=j;
                b5l:=bnl; b5L0:=bnl;
                n:=0;
                Locked:=False;
                col:=dimcol(SexColor[noc mod nSexColor],de_col,0.5);
              end;
            end;
            with DecaFam[noc] do begin
// deca contrib to 3rd ord. chroma
              dmat[23]:=dmat[23]+1/Pi*SigNa2[1,1]*PowI(Disper2[1],3);
              dmat[24]:=dmat[24]-1/Pi*SigNb2[1,1]*PowI(Disper2[1],3);
              Inc(n);
            end;
          end;
        end;
        ccorh : HCorr (dxp, 0.0, 1, latmode, 0,0,0,0);
        // no VCorr

        else    DriftSpace(l,latmode);
      end;
      SPosition:=SPosition+l;
    end;
  end;

  for i:=0 to High(SexFam) do with SexFam[i] do begin
// list of SextuPol belonging to this family:
    firstkid:=true;
    New(newkid);
    newkid.nex:=nil;
    for j:=0 to High(Sextupol) do begin
      if Sextupol[j].ifam=i then begin
        newkid:=AppendKid(newkid,j);
        if firstkid then begin
          kid     :=newkid;
          firstkid:=false;
        end;
      end;
    end;
  end;

  for i:=0 to High(SexFam) do UpdateSexFam(i, getSexKval(SexFam[i].jel));
  setlength(SVector,Length(Sextupol));

{  writeln(diagfil,'Sextupoles ------------------------------------------------------');
  for i:=0 to high(Sextupol) do with Sextupol[i] do begin
    writeln(diagfil,i:5, ifam:4, Ella[SexFam[ifam].jel].nam, sexfam[ifam].ml:10:2, sexfam[ifam].ml0:10:2, sqr(sbx)/2:10:3, sqr(sby)/2:10:3, mux/2/pi:10:3, muy/2/pi:10:3);
  end;
}
  Qx_reference:=Beam.Qa;
  Qy_reference:=Beam.Qb;

// chroma without sextupoles: --> better chroma from numdiff with usesext=false ! 28.7.2021
  ChromX_noSex:=Beam.ChromX;
  ChromY_noSex:=Beam.ChromY;

// don't add chroma here, because we get it from num diff:
//  HamC[0]:=c_get(Beam.ChromX,0.0);
//  HamC[1]:=c_get(Beam.ChromY,0.0);

  with Glob.Op0 do begin
    Eta_ref[1] :=disx;      Eta_ref[2] :=dipx;      Eta_ref[3] :=disy;      Eta_ref[4] :=dipy;
    for i:=1 to 4 do Orbi_ref[i]:=orb[i];
  end;


  OPALog(0,inttostr(Length(Sextupol))+' sext.kicks from '+inttostr(nsext)+' sextupoles and '+inttostr(ncomb)+
    ' combined families'+#13#10+'       please wait for sextupole matrix calculation...');



// establish 1st and 2nd order matrices for sextupole families
  setlength(SM1   , length(SexFam));   //10xM matrix
  setlength(SM1pre, length(SexFam));   //10xM matrix
  setlength(SM2   , sqr(length(SexFam)));   //8xM^2 matrix
  setlength(SM2dif, sqr(length(SexFam)));   //18 x M^2
  setlength(SM2sum, sqr(length(SexFam)));   //18 x M^2
  S_Matrix; // (time consuming step)
  NSexPer:=Glob.Nper;
  S_Period(NSexPer);
//  S_Testout;
  TunePlotHandle.Diagram(Qx_reference*Glob.NPer,Qy_reference*Glob.NPer);
end;


//----------------------------------------------------------------------

procedure ChromSaveDef;
// save the default values that may have been changed
var i: integer;
begin
  DefSet('chrom/2jx', scaling[0]);
  DefSet('chrom/2jy', scaling[1]);
  DefSet('chrom/dpp', scaling[2]);
  DefSet('chrom/rfac',scaling[3]);
  DefSet('chrom/kmax',maxSexK   );
  DefSet('chrom/kstp',stepSexK  );
  DefSet('chrom/omax',maxOctK   );
  DefSet('chrom/ostp',stepOctK  );
  DefSet('chrom/dmax',maxDecK   );
  DefSet('chrom/dstp',stepDecK  );
  DefSet('chrom/dpnd',dppnumdiff);
  DefSet('chrom/mamp',minAmp    );
  DefSet('chrom/tarc1x', Hamtarg[ 0]);
  DefSet('chrom/tarc1y', Hamtarg[ 1]);
  DefSet('chrom/tarc2x', Hamtarg[10]);
  DefSet('chrom/tarc2y', Hamtarg[11]);
  DefSet('chrom/tarc3x', Hamtarg[23]);
  DefSet('chrom/tarc3y', Hamtarg[24]);
  DefSet('chrom/tarqxx', Hamtarg[12]);
  DefSet('chrom/tarqxy', Hamtarg[13]);
  DefSet('chrom/tarqyy', Hamtarg[14]);
  for i:=0 to  nCHamilton-1 do begin
    DefSet('chrom/hw'+Copy(InttoStr(i+100),2,2),HamWeight[i]);
  end;
  if Include2Q  then DefSet('chrom/inc2q' ,1) else DefSet('chrom/inc2q' ,0);
  if IncludeQxx then DefSet('chrom/incqxx',1) else DefSet('chrom/incqxx',0);
  if IncludeCr2 then DefSet('chrom/inccr2',1) else DefSet('chrom/inccr2',0);
  if IncludeOct then DefSet('chrom/incoct',1) else DefSet('chrom/incoct',0);
  if Include_combined then DefSet('chrom/inccom',1) else DefSet('chrom/inccom',0);
end;

procedure ChromDispose;
var
  kp: kidpt;
  i: integer;
begin
// dispose record arrays when leaving....
  for i:=0 to High(SexFam) do begin
    with SexFam[i] do begin
      while kid<>nil do begin
        kp:=kid;
        kid:=kp^.nex;
        dispose(kp);
      end;
    end;
  end;
  Sextupol:=nil;
  SexFam:=nil;
  SVector:=nil;
  SM1:=nil;
  SM2:=nil;
  OctuFam:=nil;
  DecaFam:=nil;
end;

{-----------------------------------------------------------------------}


procedure UpdateSexFam(ifam: integer; val: real);
{double bookkeeping:
  sext-strength (=int.strength of sub-sext.) is stored
  1. as .ml for fast access in drive terms calculation, and
  2. in the element itself (either as b3*l of thin sextupole or as b3 in
  case of thick sext. and combined) through PutSexKval, in order to get
  chromas from numerical differentiation.
}
begin
  with SexFam[ifam] do begin
    ml:=val;
    PutSexKval(ml,jel);
  end;
end;

{--------------------------------------------------------------------------}

procedure UpdateSexFamInt (ifam: integer; intval: real);
// same but accepts integrated strength for whole magnet as used by CS
begin
  with SexFam[ifam] do begin
    ml:=intval/nslice;
    PutSexKval(ml,jel);
  end;
end;

{--------------------------------------------------------------------------}

procedure UpdateOctFamInt (ifam: integer; intval: real);
// same for cotupoles (use always integrated)
begin
  with OctuFam[ifam] do begin
    b4L:=intval;
    PutKval(b4L,jel,0);
  end;
end;

{--------------------------------------------------------------------------}

procedure ChromDiff;
// get lin/sqr/cub chromas from numerical differentiation
var
  i, j, k: word;
  DumFlag: Boolean;
  lp, vx, vy, cx, cy: array[0..3] of Extended;
  latmode: shortint;

begin
  UseSext:=True;
//writeln(diagfil,'----chromdiff---------------------------------------------------');
  for k:=0 to 3 do begin
    latmode:=do_twiss;
    Glob.dpp:=dppnumdiff*(2*k-3)/3;
   for i:=1 to 4 do Glob.Op0.orb[i]:=Eta_ref[i]*Glob.dpp;
    ClosedOrbit(DumFlag,do_twiss,Glob.dpp);
    if dumflag then opaLog(1,'Orbit lost in chroma num.diff.!'); // no catch yet
    Periodic (DumFlag);
    if dumflag then opaLog(1,'Periodic solution lost for dpp='+Ftos(Glob.dpp*100,8,5)+'%'); // no catch yet
    OptInit;
    latmode:=do_twiss+do_lpath;
//writeln(diagfil,'******************** ',glob.dpp,' *******************');
    for i:=1 to Glob.NLatt do Lattel (i, j, latmode, Glob.dpp);
    vx[k]:=Beam.Qa-Qx_reference; vy[k]:=Beam.Qb-Qy_reference;
    lp[k]:=PathDiff;
  end;
  Glob.dpp:=0.0;  for k:=1 to 4 do Glob.Op0.orb[k]:=0;
  for k:=0 to 3 do begin
    cx[k]:=0.0; cy[k]:=0.0; path_al[k]:=0.0;
    for i:=0 to 3 do begin
      cx[k]:=cx[k]+cd_matrix[k,i]*vx[i];
      cy[k]:=cy[k]+cd_matrix[k,i]*vy[i];
      path_al[k]:=path_al[k]+cd_matrix[k,i]*lp[i];
    end;
//writeln(diagfil, k, 'order  Cx, Cy, Alpha : ', cx[k], cy[k], path_al[k]);
  end;
{ force order 0 to be zero, because using larger dppnumdiff may result in a fit which
  gives better results for higher orders but shifts order 0, however this shift is
  fake since the values on-momentum are known and fixed:}
  cx[0]:=0; cy[0]:=0; path_al[0]:=0;

  for k:=0 to 3 do path_al[k]:=path_al[k]*PerScaFac;
  HamV[ 0].re:=PerScaFac*cx[1]; HamV[ 1].re:=PerScaFac*cy[1];
  HamV[10].re:=PerScaFac*cx[2]; HamV[11].re:=PerScaFac*cy[2];
  HamV[23].re:=PerScaFac*cx[3]; HamV[24].re:=PerScaFac*cy[3];
end;

//.............................................................................

procedure DriveTerms_Geo;
var
  i,j: integer;
  ha: complex;
begin
  for j:=2 to 6 do begin
    ha:=c_get(0,0);
    for i:=0 to High(SexFam) do begin
      ha:=c_add(ha, c_sca(SM1[i,j],SexFam[i].ml));
    end;
    HamV[j]:=ha;
  end;
end;

//.............................................................................

procedure DriveTerms_2Q; // h20001, h00201, h10002
var
  i,j: integer;
  ha: complex;
begin
  if Include2Q then begin
    for j:=7 to 9 do begin
      ha:=c_get(0,0);
      for i:=0 to High(SexFam) do begin
        ha:=c_add(ha, c_sca(SM1[i,j],SexFam[i].ml));
      end;
      HamV[j]:=ha;
    end;
  end else begin
    HamV[7]:=c_get(0,0);
    HamV[8]:=c_get(0,0);
    HamV[9]:=c_get(0,0);
  end;
end;

//.............................................................................

procedure DriveTerms_Qxx;
var
  i,j,k,ij: integer;
  ha: double;
begin
  if IncludeQxx then for k:=12 to 14 do begin
    ha:=0;
    for i:=0 to High(SexFam) do for j:=0 to High(SexFam) do begin
      ij:=i*Length(SexFam)+j;
      ha:=ha+ SM2[ij,k].re * SexFam[i].ml*SexFam[j].ml;
    end;
    for i:=0 to High(OctuFam) do with OctuFam[i] do  ha:=ha+b4l*omatpre[k];

    HamV[k].re:=ha * PerScaFac;
  end else for k:=12 to 14 do HamV[k].re:=HamTarg[k];
end;

//.............................................................................

procedure DriveTerms_Oct;
var
  i,j,k,ij: integer;
  ha, ho: complex;
begin
  for i:=15 to 22 do HamV[i]:=c_get(0,0);
  if IncludeOct then begin
    for k:=15 to 22 do begin
      ha:=c_get(0,0);
      for i:=0 to High(SexFam) do for j:=0 to High(SexFam) do begin
        ij:=i*Length(SexFam)+j;
        ha:=c_add(ha, c_sca(SM2[ij,k],SexFam[i].ml*SexFam[j].ml ));
      end;
      ho:=c_get(0,0);
      for i:=0 to High(OctuFam) do with OctuFam[i] do ho:=c_add(ho, c_sca(om1[k],b4L));
//      HamV[k]:=ha;
      if oc_sx_addmode
       then HamV[k]:=c_add(ha,ho) // add vectors
       else HamV[k]:=c_get(c_abs(ha)+c_abs(ho),0); // maybe safer to ignore the phase ?????
    end;
  end;
end;

//.............................................................................

procedure DriveTerms_Cr2;
var
  cx, cy: double;
  k: integer;
begin
  if IncludeCr2 then begin
    ChromDiff;

  end else begin
    getLinChroma(cx,cy);
    HamV[0].re:=PerScaFac*cx;
    HamV[1].re:=PerScaFac*cy;
    for k:=10 to 11 do HamV[k]:=c_get(HamTarg[k],0);
    for k:=23 to 24 do HamV[k]:=c_get(HamTarg[k],0);
    for k:=0 to 3 do path_al[k]:=0.0;
  end;
end;

//.............................................................................

procedure DriveTerms_Sum;
//simple square sum of all sextupole strength
var	i : integer;
        r: double;
begin
  r:=0.0;
  for i:=0 to High(Sextupol) do with Sextupol[i] do r := r + sqr(SexFam[ifam].ml);
  HamV[25].re:=r*PerScaFac;
end;

//.............................................................................

procedure DriveTerms;
begin
  DriveTerms_geo;
  DriveTerms_2Q;
  DriveTerms_Qxx;
  DriveTerms_Oct;
  DriveTerms_Cr2;
  DriveTerms_Sum;
end;

//-----------------------------------------------------------------

// isn't this already included in SM1 ?
function UpdateChromMatrix: Boolean;
var
  k: integer;
  sumx, sumy, det, temp: double;
  kp: kidpt;
  fail: boolean;
begin
  for k:=0 to 1 do begin
    sumx:=0; sumy:=0;
    kp:=SexFam[SFSDFlag[k]].kid;
    while kp<>nil do begin
      with SextuPol[kp.isx] do begin
//!! also include orbit contribution
        sumx:=sumx + sqr(sbx)*eta;
        sumy:=sumy - sqr(sby)*eta;
      end;
      kp:=kp^.nex;
    end;
    ChromMatrix[0,k]:=sumx/2/Pi;
    ChromMatrix[1,k]:=sumy/2/Pi;
  end;

// inversion of chroma matrix
  det:=Chrommatrix[0,0]*ChromMatrix[1,1]-Chrommatrix[0,1]*ChromMatrix[1,0];
  if abs(det)<1e-6 then fail:=true else begin
    temp:=ChromMatrix[0,0];
    ChromMatrix[0,0]:=  ChromMatrix[1,1]/det;
    ChromMatrix[1,1]:=              temp/det;
    ChromMatrix[0,1]:= -ChromMatrix[0,1]/det;
    ChromMatrix[1,0]:= -ChromMatrix[1,0]/det;
    fail:=false;
  end;
  UpdateChromMatrix:=fail;
end;

//---------------------------------------------------------------

// get linear chroma by summing up all sextupoles and adding
// the initially calculated chroma without sexts (mainly Quads)
procedure getLinChroma (var cx, cy: double);
var
  i: integer;
begin
  cx:=0; cy:=0;
  for i:=0 to High(Sextupol) do begin
    with SextuPol[i] do begin
//!! also include orbit contribution    
      cx:=cx+sqr(sbx)*eta*SexFam[ifam].ml;
      cy:=cy-sqr(sby)*eta*SexFam[ifam].ml;
    end;
  end;
  cx := (cx/2/Pi + ChromX_noSex);
  cy := (cy/2/Pi + ChromY_noSex);
end;

//---------------------------------------------------------------

procedure ChromCorrect;
// correct the chromaticity by adjusting the SFSD families,
// but no recalc of driveterms
var
  kval, dc: array[0..1] of double;
  j,k: integer;
begin
// get the linear chroma first; is alway for one period
  getLinChroma(dc[0],dc[1]);
  for j:=0 to 1 do begin
  // correction to be done:
    dc[j]:=HamTarg[j]/PerScaFac-dc[j];
    kval[j]:=getSexKval(SexFam[SFSDFlag[j]].jel);
  end;
  for j:=0 to 1 do begin
    for k:=0 to 1 do kval[j]:=kval[j]+ChromMatrix[j,k]*dc[k];
//    CS[SFSDFlag[j]].IncVal(dk[j]);
    UpdateSexFam(SFSDFlag[j],kval[j]);
  end;

    SnapSave.ChromX:=Hamtarg[0]/perScaFac;
    SnapSave.ChromY:=Hamtarg[1]/perScaFac;
// matrix depends on the order how the 2 fams where selected... :
    if Pos('SF',Ella[SexFam[SFSDFlag[0]].jel].nam)>0 then begin
      SnapSave.cmfx  := ChromMatrix[0,0]*Ella[SexFam[SFSDFlag[0]].jel].sslice;
      SnapSave.cmfy  := ChromMatrix[0,1]*Ella[SexFam[SFSDFlag[0]].jel].sslice;
      SnapSave.cmdx  :=-ChromMatrix[1,0]*Ella[SexFam[SFSDFlag[1]].jel].sslice;
      SnapSave.cmdy  :=-ChromMatrix[1,1]*Ella[SexFam[SFSDFlag[1]].jel].sslice;
    end else begin
      SnapSave.cmdx  :=-ChromMatrix[0,0]*Ella[SexFam[SFSDFlag[0]].jel].sslice;
      SnapSave.cmdy  :=-ChromMatrix[0,1]*Ella[SexFam[SFSDFlag[0]].jel].sslice;
      SnapSave.cmfx  := ChromMatrix[1,0]*Ella[SexFam[SFSDFlag[1]].jel].sslice;
      SnapSave.cmfy  := ChromMatrix[1,1]*Ella[SexFam[SFSDFlag[1]].jel].sslice;
    end;
    Status.cmatrix :=true;
    setStatusLabel(stlab_chr,status_flag);
end;

//---------------------------------------------------------------

procedure getSvector (p : integer);
//get star of complex sext. vector for mode p
// scale vectors by nslice for showing, otherwise too short
var
  i: integer;
  h: complex;
  r, phi: double;

begin
  for i:=0 to High(Sextupol) do begin
    with Sextupol[i] do begin
      r := SexFam[ifam].nslice*sclsm1[p]*SexFam[ifam].ml*PowI(sbx,ism1[p,0]+ism1[p,1])*PowI(sby,ism1[p,2]+ism1[p,3])*PowI(eta,ism1[p,4]);
      phi := (ism1[p,0]-ism1[p,1])*mux+(ism1[p,2]-ism1[p,3])*muy;
    end;
    h   := c_exp(r, phi);
    SVector[i]:=h;
  end;
end;

//-------------------------------------------------------------------


procedure TDiagPlotFull;
// same like tdiagplot but after changing period numbers: completely new diagram
begin
  TunePlotHandle.Diagram(Qx_reference*PerScaFac, Qy_reference*PerScaFac);
  TDiagPlot;
end;

procedure TDiagPlot;
var
  qxj, qyj: real;
begin
  with TunePlotHandle do begin
    Refresh;
    if IncludeQxx then begin
      qxj:= HamV[12].re*scaling[0]*1e-6 + qx_reference*PerScaFac;
      qyj:= HamV[13].re*scaling[0]*1e-6 + qy_reference*PerScaFac;
      AddTunePoint(qxj, qyj,0,1,true);
      qxj:= HamV[13].re*scaling[1]*1e-6 + qx_reference*PerScaFac;
      qyj:= HamV[14].re*scaling[1]*1e-6 + qy_reference*PerScaFac;
      AddTunePoint(qxj, qyj,0,1,true);
    end;
    if IncludeCr2 then begin
      AddChromLine(HamV[0].re,HamV[1].re,HamV[10].re,HamV[11].re,HamV[23].re,HamV[24].re,scaling[2]*0.01);
    end else begin
      AddChromLine(HamV[0].re,HamV[1].re,0,0,0,0,scaling[2]*0.01);
    end;
  end;
end;

//-------------------------------------------------------------------


procedure S_Matrix;
{calculate the 1st and 2nd order sextupole correction matrices
SM1 = matrix of sexfam   columns x 10 rows of complex values
SM2 = matrix of sexfam^2 columns x 11 rows of complex values
}

  procedure SM2_JBABC (ifam, jfam: integer; var A11, A12, A22: double);

  { contribution of crosstalk ifam,jfam to tune shifts terms, based oon J.Bengtsson's
    formula for real tune shifts using resonant denominators}

  var
    Nux, Nuy, Vij, sc, C10, C30, C1p2, C1m2,
    Pix, Pi3x, Pixp2y, Pixm2y, SPix, SPi3x, SPixp2y, SPixm2y,
    Npm, DPsiX, DPsiY: real;
    i, j : Integer;
    ikid, jkid: kidpt;
    si, sj: SextupolType;
  begin
    Nux:=Qx_reference; Nuy:=Qy_reference;
    Pix     :=Pi*NuX;           SPix     :=Sin(Pix);
    Pi3x    :=3*Pi*NuX;         SPi3x    :=Sin(Pi3x);
    Pixp2y  :=Pi*(NuX+2*NuY);   SPixp2y  :=Sin(Pixp2y);
    Pixm2y  :=Pi*(NuX-2*NuY);   SPixm2y  :=Sin(Pixm2y);
    A11:=0; A12:=0; A22:=0;
//    Sc:=1/256/Pi;
    Sc:=1/32/Pi;
    ikid:=SexFam[ifam].kid;
    while ikid<>nil do begin
      i:=ikid.isx; // sextupole index of kid
      si:=Sextupol[i];
      jkid:=SexFam[jfam].kid;
      while jkid<>nil do begin
        j:=jkid.isx;
        sj:=Sextupol[j];
        if j<i then Npm:=-1.0 else Npm:=+1.0;
        DPsiX:=si.mux - sj.mux;
        DPsiY:=si.muy - sj.muy;

        Vij:=sc*si.sbx*sj.sbx;
        C10 :=Cos(  DPsiX        +Npm*Pix   )/SPix;
        C30 :=Cos(3*DPsiX        +Npm*Pi3x  )/SPi3x;
        C1p2:=Cos(  DPsiX+2*DPsiY+Npm*Pixp2y)/SPixp2y;
        C1m2:=Cos(  DPsiX-2*DPsiY+Npm*Pixm2y)/SPixm2y;
        A11:=A11-Vij*sqr(si.sbx*sj.sbx)*(3*C10+C30);
        A12:=A12+Vij*sqr(si.sby)*(4*sqr(sj.sbx)*C10-2*sqr(sj.sby)*(C1p2-C1m2));
        A22:=A22-Vij*sqr(si.sby*sj.sby)*(4*C10+C1p2+C1m2);
        jkid:=jkid^.nex;
      end;
      ikid:=ikid^.nex;
    end;
  end;

//..................................................................

  procedure sm2_ij (ind, ifam , jfam, ijfam: integer);

  {octupole like terms: contribution from crosstalk of sext.families ifam, ifam}
  {ind is mode 0..17 to be saved for sum and diff}

  var   i, j  : integer;
        j1, k1, l1, m1, j2, k2, l2, m2: integer;
        scl, phi1, r1, r2, phi2: double;
        ds, sd, sp, sm : complex;
        ikid, jkid: kidpt;
        sxi, sxj: SextupolType;

  begin
    scl:=1.0/ism2[ind,1];
    j1 :=ism2[ind,2]; k1 :=ism2[ind,3]; l1 :=ism2[ind,4]; m1 :=ism2[ind,5];
    j2 :=ism2[ind,6]; k2 :=ism2[ind,7]; l2 :=ism2[ind,8]; m2 :=ism2[ind,9];
    sp:=c_get(0.0,0.0); sm:=sp; sd:=sp;
    ikid:=SexFam[ifam].kid;
    while ikid<>nil do begin
      i:=ikid.isx; // sextupole index of kid
      sxi:=Sextupol[i];
      r1    := PowI(sxi.sbx,j1+k1)*PowI(sxi.sby,l1+m1);
      phi1  := (j1-k1)*sxi.mux+(l1-m1)*sxi.muy;
      jkid:=SexFam[jfam].kid;
      while jkid<>nil do begin
        j:=jkid.isx;
        sxj :=Sextupol[j];
        r2  := PowI(sxj.sbx,j2+k2)*PowI(sxj.sby,l2+m2);
        phi2:= (j2-k2)*sxj.mux+(l2-m2)*sxj.muy;
// adjust to Chun-xi Wang\'s formulae: as-27.02.12
// changed sign of phase gives complex conjugate.
// (later multiplication by i makes change in real part.)
        ds:= c_exp( r1*r2, -(phi1+phi2));
        ds:= c_exp(r1*r2,   phi1+phi2);
        if      j > i then sp:=c_add(sp, ds)
        else if j < i then sm:=c_add(sm, ds)
        else sd:=c_add(sd,ds);
        jkid:=jkid^.nex;
      end;
      ikid:=ikid^.nex;
    end;
{
 sdif=i*scl*(sp-sm)   ssum:=i*scl*(sp+sm+sd)
 h_N(m,m´) = SUM_families_ij [sdif * perfac1(-(m+m´)) + ssum * perfac2(m,m´)]
 see note 280703
}
    sm2dif[ijfam, ind]:=c_mul(c_get(0,scl),          c_sub(sp,sm));//= h_1(m,m´) for b3i/j=1
    sm2sum[ijfam, ind]:=c_mul(c_get(0,scl), c_add(sd,c_add(sm,sp)));
  end;

//..................................................................

var
  i, j, k, ij, i2: integer;
  r, phi, qxx, qxy, qyy: double;
begin

  for i:=0 to High(SexFam) do for j:=0 to 9 do SM1pre[i,j]:=c_get(0.0,0.0);
  for i:=0 to High(Sextupol) do begin
    with Sextupol[i] do begin
      for k:=0 to 9 do begin
        r   := sclsm1[k]*PowI(sbx,ism1[k,0]+ism1[k,1])*PowI(sby,ism1[k,2]+ism1[k,3])*PowI(eta,ism1[k,4]);
        phi := (ism1[k,0]-ism1[k,1])*mux+(ism1[k,2]-ism1[k,3])*muy;
        SM1pre[ifam,k]:=c_add(SM1pre[ifam,k],c_exp(r, phi));
      end;
    end;
  end;

  for i:=0 to High(SM2) do for j:=12 to 22 do SM2[i,j]:=c_get(0.0,0.0);

  for i:=0 to High(SexFam) do for j:=0 to High(SexFam) do begin
    ij:=i*Length(SexFam)+j; // column index for SM2 0...Nsexfam^2-1

    SM2_JBABC (i,j, qxx, qxy, qyy);
    SM2[ij,12] := c_get(qxx,0);
    SM2[ij,13] := c_get(qxy,0);
    SM2[ij,14] := c_get(qyy,0);

    for i2:=0 to 17 do sm2_ij (i2, i, j, ij);
  end;


end;

{----------------------------------------------------------------------------}

procedure S_Period (nper: integer);

var
  Nux, Nuy: double;
  i, j, ij, imod, i2, k: integer;

//  tt: array[0..30] of complex;


{calculate complex factors for multiplication of Hamiltonians
 with number of periods. For non resonant terms, like chroma
 and tune shifts, this factor is just (nper,0). For resonant
 terms, it contains a phase due to interference of periods
 and the rsonance appears as denominator.
 nper=0 means infinity, in this case set nper=glob.nper for non-resonant.
 as-280703/130408}

  function PerFac1 (nper, j, k, l, m: integer): complex;
{periodic amplification of resonant terms}
  var
    mx, my: integer;
    psi: double;
    a: complex;
  begin
    if (nper <> 1) then begin
      mx:=j-k; my:=l-m;
      if (mx=0) and (my=0) then begin
{non phase dependant terms: multiply by periods, take 1 period for infinity}
        if (nper=0) then a:=c_get(1,0) else a:=c_get(nper,0);
      end else begin
{phase dependant: calc complex amp. fac. nper=0 means infinity: average only}
        psi:=(mx*Nux+my*Nuy)*Pi;
        if (nper=0) then begin
          a:=c_get(0.5, 0.5/tan(psi));
        end else begin
          a:=c_sca( c_get( sin(psi)+sin((2*nper-1)*psi),
                           cos(psi)-cos((2*nper-1)*psi)),
                    0.5/sin(psi));
        end;
      end;
    end else a:=c_get(1,0);
    Perfac1:=a;
  end;

{.........................................................................}

  function PerFac2(nper, j1, k1, l1, m1, j2, k2, l2, m2: integer): complex;


{
 periodic amplification of resonant terms, 2nd order
 a = b_N (m,m')
}
  var
    mx1, my1, mx2, my2: integer;
    psi1, psi2, denom: double;
    a: complex;

    function scmu (p1,p2: real; n: integer; sincos: boolean): Real;
    var x1,x2,x3,x4,y: real;
    begin
      x1:=2*p1; x2:=-n*2*p1; x3:=(-n+1)*2*p1+2*p2; x4:=-n*2*(p1+p2)+2*p1;
      if sincos then begin
        y:=sin(x1)-sin(x2)+sin(x3)-sin(x4);
      end else begin
        y:=cos(x1)-cos(x2)+cos(x3)-cos(x4);
      end;
      scmu:=y;
    end;

  begin
    if (nper <> 1) then begin
      mx1:=j1-k1; my1:=l1-m1;    mx2:=j2-k2; my2:=l2-m2;
      if (mx1=0) and (my1=0) and (mx2=0) and (my2=0) then begin
  {non phase dependant terms: multiply by periods, take 1 period for infinity}
        if (nper=0) then a:=c_get(1,0.0) else a:=c_get(nper,0.0);
      end else begin
  {phase dependant: calc complex amp. fac. nper=0 means infinity: average only}

// adjust to Chun-xi Wang\'s formulae: as-27.02.12: opposite sign of phase
        psi1:=-(mx1*Nux+my1*Nuy)*Pi;      psi2:=-(mx2*Nux+my2*Nuy)*Pi;
//        psi1:=(mx1*Nux+my1*Nuy)*Pi;      psi2:=(mx2*Nux+my2*Nuy)*Pi;
        denom:=1/(8*sin(psi1)*sin(psi2)*sin(psi1+psi2));
        if (nper=0) then begin
          a:=c_sca(c_get(-sin(2*psi1)+sin(2*psi2),
                          cos(2*psi1)-cos(2*psi2)),
                   denom);
        end else begin
          a:=c_sca(c_get(-scmu(psi1,psi2,nper, true)+scmu(psi2,psi1,nper, true),
                          scmu(psi1,psi2,nper,false)-scmu(psi2,psi1,nper,false)),
                   denom);
        end;
      end;
    end else begin
      a:=c_get(0,0);
    end; {nper = 1: suppress contribution}
    Perfac2:=a;
  end;

  function PF2(nper, ind, ij: integer):complex;
  var
    j1, k1, l1, m1, j2, k2, l2, m2: integer;
  begin
    j1 :=ism2[ind,2]; k1 :=ism2[ind,3]; l1 :=ism2[ind,4]; m1 :=ism2[ind,5];
    j2 :=ism2[ind,6]; k2 :=ism2[ind,7]; l2 :=ism2[ind,8]; m2 :=ism2[ind,9];
// adjust to Chun-xi Wang's formulae: as-27.02.12 : opposite sign of phase in PerFac1 too
//    PF2:=c_add(c_mul(SM2sum[ij,ind],Perfac2(nper, j1, k1, l1, m1, j2, k2, l2, m2)),
//               c_mul(SM2dif[ij,ind],Perfac1(nper,-(j1+j2),-(k1+k2),-(l1+l2),-(m1+m2))));
    PF2:=c_add(c_mul(SM2sum[ij,ind],Perfac2(nper, j1, k1, l1, m1, j2, k2, l2, m2)),
               c_mul(SM2dif[ij,ind],Perfac1(nper, j1+j2, k1+k2, l1+l2, m1+m2)));
  end;

{.........................................................................}

begin
  Nux:=Qx_reference; Nuy:=Qy_reference;
  if nper=0 then PerScaFac:=Glob.Nper else PerScaFac:=nper;

  for i:=0 to High(SexFam) do for k:=0 to 9 do  SM1[i,k]:=c_mul(SM1pre[i,k],PerFac1(nper,ism1[k,0],ism1[k,1],ism1[k,2],ism1[k,3]));

  H2Qx:=c_mul(H2Qxpre,PerFac1(nper,2,0,0,0));
  H2Qy:=c_mul(H2Qypre,PerFac1(nper,0,0,2,0));
  HQxP:=c_mul(HQxPpre,PerFac1(nper,1,0,0,0));

  for ij:=0 to High(SM2) do for imod:=15 to 22 do SM2[ij,imod]:=c_get(0.0,0.0);

  for i:=0 to High(SexFam) do for  j:=0 to High(SexFam) do begin
    ij:=i*Length(SexFam)+j; // column index for SM2 0...Nsexfam^2-1
    for i2:=0 to 17 do begin
      imod:=ism2[i2,0];
      SM2[ij,imod] :=  c_add( SM2[ij,imod], PF2(nper, i2, ij) );
    end;
  end;

  for i:=0 to High(OctuFam) do with OctuFam[i] do begin
    for k:=10 to 14 do omat[k]:=omatpre[k]*PerScaFac;
    for k:=15 to 22 do om1[k]:=c_mul(om1pre[k], PerFac1(nper,iom1[k,0],iom1[k,1],iom1[k,2],iom1[k,3]));
  end;

 {******************************************************


writeln(diagfil);
writeln(diagfil,'Sextupoles 1st order: mode, re, im, abs, phase');

  for k:=0 to 9 do begin
    tmp:=c_get(0,0);
    for i:=0 to High(SexFam) do tmp:=c_add(tmp, c_sca(SM1pre[i,k], SexFam[i].ml));
    tt[10+k]:=tmp;
    writeln(diagfil,hamcap[k],c_re(tmp),'  ', c_im(tmp),'  ',  c_abs(tmp),'  ',  c_ang(tmp));
  end;

writeln(diagfil);
writeln(diagfil,'p=1 modes: quadrupole contributions: mode, re, im, abs, phase');
  tmp:=H2QxPre;
    writeln(diagfil,hamcap[7],c_re(tmp),'  ', c_im(tmp),'  ',  c_abs(tmp),'  ',  c_ang(tmp));
  tmp:=H2Qypre;
    writeln(diagfil,hamcap[8],c_re(tmp),'  ', c_im(tmp),'  ',  c_abs(tmp),'  ',  c_ang(tmp));
  tmp:=HQxPpre;
    writeln(diagfil,hamcap[9],c_re(tmp),'  ', c_im(tmp),'  ',  c_abs(tmp),'  ',  c_ang(tmp));

writeln(diagfil);
writeln(diagfil,'p=1 modes: quadrupole plus sextupole: mode, re, im, abs, phase');
  tmp:=c_add(tt[17], H2QxPre);
    writeln(diagfil,hamcap[7],c_re(tmp),'  ', c_im(tmp),'  ',  c_abs(tmp),'  ',  c_ang(tmp));
  tmp:=c_add(tt[18], H2Qypre);
    writeln(diagfil,hamcap[8],c_re(tmp),'  ', c_im(tmp),'  ',  c_abs(tmp),'  ',  c_ang(tmp));
  tmp:=c_add(tt[19], HQxPpre);
    writeln(diagfil,hamcap[9],c_re(tmp),'  ', c_im(tmp),'  ',  c_abs(tmp),'  ',  c_ang(tmp));

writeln(diagfil);
writeln(diagfil,'Sextupoles 2nd order, single: index, mode, re, im, abs, phase');

  for k:=15 to 22 do tt[k]:=c_get(0,0);
  for i2:=0 to 17 do begin
    tmp:=c_get(0,0);
    for i:=0 to High(SexFam) do for j:=0 to High(SexFam) do tmp:=c_add(tmp, c_sca(Sm2dif[i*Length(SexFam)+j, i2],SexFam[i].ml*SexFam[j].ml) );
    k:=ism2[i2,0];
    tt[k]:=c_add(tt[k], tmp);
    writeln(diagfil, i2:3,'  ', hamcap[k], '  ', c_re(tmp),'  ',  c_im(tmp),'  ',  c_abs(tmp),'  ',  c_ang(tmp));
  end;

writeln(diagfil);
writeln(diagfil,'Sextupoles 2nd order: mode, re, im, abs, phase');

  for k:=15 to 22 do  writeln(diagfil, hamcap[k], '  ', c_re(tt[k]),'  ',  c_im(tt[k]),'  ',  c_abs(tt[k]),'  ',  c_ang(tt[k]));

writeln(diagfil);
writeln(diagfil,'Octupoles 1st order: mode, re, im, abs, phase');

  for k:=15 to 22 do begin
    tmp:=c_get(0,0);
    for i:=0 to High(OctuFam) do tmp:=c_add(tmp, c_sca(octuFam[i].om1pre[k], octuFam[i].b4L));
    writeln(diagfil, hamcap[k], '  ', c_re(tmp),'  ',  c_im(tmp),'  ',  c_abs(tmp),'  ',  c_ang(tmp));
  end;

  writeln(diagfil);
writeln(diagfil,'Sextupoles 2nd order + Octupoles 1st order: mode, re, im, abs, phase');

  for k:=15 to 22 do begin
    tmp:=c_get(0,0);
    for i:=0 to High(OctuFam) do tmp:=c_add(tmp, c_sca(octuFam[i].om1pre[k], octuFam[i].b4L));
    tmp:=c_add(tmp, tt[k]);
    writeln(diagfil, hamcap[k], '  ', c_re(tmp),'  ',  c_im(tmp),'  ',  c_abs(tmp),'  ',  c_ang(tmp));
  end;

}
  
{******************************************************
  alt?

writeln(diagfil);
writeln(diagfil,'Sextupoles 1st order: mode, re, im, abs, phase');

  for k:=0 to 9 do begin
    tmp:=c_get(0,0);
    for i:=0 to High(SexFam) do tmp:=c_add(tmp, c_sca(SM1pre[i,k], SexFam[i].ml));
    tt[10+k]:=tmp;
    writeln(diagfil,ftos(c_re(tmp),15,4));
  end;
writeln(diagfil);
  for k:=0 to 9 do begin
    tmp:=c_get(0,0);
    for i:=0 to High(SexFam) do tmp:=c_add(tmp, c_sca(SM1pre[i,k], SexFam[i].ml));
    tt[10+k]:=tmp;
    writeln(diagfil,ftos(c_im(tmp),15,4));
  end;

writeln(diagfil);
writeln(diagfil,'p=1 modes: quadrupole contributions: re, im');
  tmp:=H2QxPre; writeln(diagfil,ftos(c_re(tmp),15,4));
  tmp:=H2Qypre; writeln(diagfil,ftos(c_re(tmp),15,4));
  tmp:=HQxPpre; writeln(diagfil,ftos(c_re(tmp),15,4));
writeln(diagfil);
  tmp:=H2QxPre; writeln(diagfil,ftos(c_im(tmp),15,4));
  tmp:=H2Qypre; writeln(diagfil,ftos(c_im(tmp),15,4));
  tmp:=HQxPpre; writeln(diagfil,ftos(c_im(tmp),15,4));

writeln(diagfil);
writeln(diagfil,'p=1 modes: quadrupole plus sextupole: re, im');
  tmp:=c_add(tt[17], H2QxPre);writeln(diagfil,ftos(c_re(tmp),15,4));
  tmp:=c_add(tt[18], H2Qypre);writeln(diagfil,ftos(c_re(tmp),15,4));
  tmp:=c_add(tt[19], HQxPpre);writeln(diagfil,ftos(c_re(tmp),15,4));
writeln(diagfil);
  tmp:=c_add(tt[17], H2QxPre);writeln(diagfil,ftos(c_im(tmp),15,4));
  tmp:=c_add(tt[18], H2Qypre);writeln(diagfil,ftos(c_im(tmp),15,4));
  tmp:=c_add(tt[19], HQxPpre);writeln(diagfil,ftos(c_im(tmp),15,4));

  for k:=15 to 22 do tt[k]:=c_get(0,0);
  for i2:=0 to 17 do begin
    tmp:=c_get(0,0);
    for i:=0 to High(SexFam) do for j:=0 to High(SexFam) do tmp:=c_add(tmp, c_sca(Sm2dif[i*Length(SexFam)+j, i2],SexFam[i].ml*SexFam[j].ml) );
    k:=ism2[i2,0];
    tt[k]:=c_add(tt[k], tmp);
  end;

writeln(diagfil);
writeln(diagfil,'Sextupoles 2nd order: re, im ');

  for k:=15 to 22 do  writeln(diagfil, ftos(c_re(tt[k]),14,5));
writeln(diagfil);
  for k:=15 to 22 do  writeln(diagfil, ftos(c_im(tt[k]),14,5));

writeln(diagfil);
writeln(diagfil,'Octupoles 1st order: mode, re, im, abs, phase');

  for k:=15 to 22 do begin
    tmp:=c_get(0,0);
    for i:=0 to High(OctuFam) do tmp:=c_add(tmp, c_sca(octuFam[i].om1pre[k], octuFam[i].b4L));
    writeln(diagfil, ftos(c_re(tmp),14,5));
  end;
writeln(diagfil);
  for k:=15 to 22 do begin
    tmp:=c_get(0,0);
    for i:=0 to High(OctuFam) do tmp:=c_add(tmp, c_sca(octuFam[i].om1pre[k], octuFam[i].b4L));
    writeln(diagfil, ftos(c_im(tmp),14,5));
  end;
}

end;


procedure S_Testout;
var
  SV1: SM1_row;
//  SV2: SM2_row;
  res: complex;
  otf: textfile;
  nkids, nslice, i, j, ij, k:integer;
  ikid: kidpt;
  fname: string;
begin
//quad contributions:
  for j:=0 to 9 do SV1[j]:=c_get(0.0,0.0);
  SV1[0].re:=ChromX_noSex;
  SV1[1].re:=ChromY_noSex;
  SV1[7]:=H2Qxpre;
  SV1[8]:=H2Qypre;
  SV1[9]:=HQxPpre;

// output for testing and for IDL smat.pro
//  if false then begin
  if true then begin
// write matrix and vector to a file
    fname:=ExtractFileName(FileName);
    fname:=work_dir+Copy(fname,0,Pos('.',fname)-1)+'_smatrix.txt';
    assignFile(otf,fname);
{$I-}
    rewrite(otf);
{$I+}
    if IOResult=0 then begin
      writeln(otf,FileName);
      writeln(otf,Beam.Qx:15:8, Beam.Qy:15:8);
      for j:=0 to 9 do writeln(otf,SV1[j].re:15:8, SV1[j].im:15:8);
      writeln(otf,Length(SexFam));
      for i:=0 to High(SexFam) do begin
         if Ella[SexFam[i].jel].cod=csext
         then nslice:=Ella[SexFam[i].jel].sslice
         else nslice:=Ella[SexFam[i].jel].cslice;
         writeln(otf,Ella[SexFam[i].jel].nam);
         ikid:=SexFam[i].kid; nkids:=0;
         while ikid<>nil do begin
           inc(nkids);
           ikid:=ikid^.nex;
         end;
         nkids:=nkids div nslice;
         writeln(otf,getkval(SexFam[i].jel,0):15:8, nkids:8); // full int strength and number of kids
         // divide matrix elements by nslice because they were for slice-(m*l):
         for j:=0 to 9 do  writeln(otf, SM1[i,j].re/nslice:15:8, SM1[i,j].im/nslice:15:8);
      end;
    end;

  // test with current settings
    for j:=0 to 9 do begin
      res:=SV1[j];
      for i:=0 to High(SexFam) do begin
        res:=c_add(res, c_sca(SM1[i,j],SexFam[i].ml));
      end;
      writeln(otf, j:3, ' ', res.re:12:5, res.im:12:5 ,c_abs(res):12:5);
    end;

    for k:=12 to 22 do begin
      res:=c_get(0,0);
      for i:=0 to High(SexFam) do for j:=0 to High(SexFam) do begin
        ij:=i*Length(SexFam)+j;
        res:=c_add(res, c_sca(SM2[ij,k],SexFam[i].ml*SexFam[j].ml ));
      end;
      writeln(otf, k:3, ' ', res.re:12:5, res.im:12:5 ,c_abs(res):12:5);
    end;
    CloseFile(otf);
    OPALog(0,'sextupole matrix was written to '+fname);
  end;

  if true then begin
    fname:=ExtractFileName(FileName);
    fname:=work_dir+Copy(fname,0,Pos('.',fname)-1)+'_sphase.txt';
    assignFile(otf,fname);
{$I-}
    rewrite(otf);
{$I+}
    if IOResult=0 then begin
      writeln(otf,FileName);
      writeln(otf,Glob.NPer:5,' ', Beam.Qx:15:8, Beam.Qy:15:8);
      for i:=0 to High(Sextupol) do with Sextupol[i] do
         writeln(otf, SexFam[ifam].ml:10:6, sqr(sbx):10:6, sqr(sby):10:3,  eta:10:6,
           mux/2/Pi-0.5*Beam.Qx/Glob.NPer:15:6, muy/2/Pi-0.5*Beam.Qy/Glob.NPer:15:6,'   ',
           Ella[SexFam[ifam].jel].nam);
    end;
    CloseFile(otf);
    OPALog(0,'sextupole phases and betas written to '+fname);
  end;
end;

end.

