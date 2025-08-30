unit linoplib;

{$MODE Delphi}

// plots and calculations

                                                             
interface

uses Vgraph, Graphics, elemlib, globlib, opatunediag, ASaux, mathLib, grids, sysutils, stdctrls, forms;

const
  ncurvesmax=3;
//  show_betanorm=1; show_betaproj=2; show_propper=4;
  betplot=0; envplot=1; magplot=2;

type
  MatchScanType = record
    nam: string;
    nstep: integer;
    val, minval, maxval: real;
    act: boolean;
  end;

var
   vp: VPlot;

   OOMode, PerMode, SymMode, MomMode, UseEqEmi, ExchangeModes, dppmode : boolean;
   BetaMax, DispMax, OrbMax, EnvelMaxX, EnvelMaxY, CdetMax, BfieldMin, BfieldMax: Real;
   xautoscale {, Disp_Orb}: boolean;
   BeamLost: boolean; //check for too large apertures
   COCorrStatus, OpticStartMode, ilaststart: integer;
   //COCorrstatus 0 nothing, 1 corr to zero, 2 corr to saturation, 3 too many iteration, 4 beam loss
   OpticPlotMode, ibetamark: integer;
   dPmult: real;
   env_sdpp, env_emix, env_emiy, env_erat, env_rref: Real;
   opval: array of array of opvaltype;
   obeam: array[0..ncurvesmax-1] of BeamParType;
   ncurves: integer;
   ibetatab: integer;
   tabRowCol: array[0..50] of integer;
   csaveaction: integer;
   scanpar: array[1..nMatchFunc] of MatchScanType;
   iscan, iscanfunc: integer;
   fload_dir: string;
   ShowBetas: array[1..3] of Boolean;
   ShowDisp: integer;


procedure Ella_Eval(j: integer);
procedure closeTuneDiagram;

procedure clearOpval;
procedure allocOpval;
procedure shiftOpval;

procedure setTabHandle(tab:TStringGrid);
procedure setTunePlotHandle(TP: TtunePlot);

//procedure setOrbitHandles (OP: TFigure; edx, edxp, edy, edyp: TEdit; lper, lloss: TLabel);
procedure setOrbitHandle (OP: TForm);

procedure OptInit;

procedure PrintLatticeData (fnam0: string);
procedure PrintHTMLData;
procedure PrintCurve (fnam0: string);
procedure printMagnets(fnam0: string);
procedure printRadiation(fnam0: string);

procedure PlotOrbit;
procedure PlotBeta;
procedure PlotEnv;
procedure PlotMag;
procedure PlotApertures (ixy: integer);

procedure StoVar(jcu,i: word);

procedure SliceCalcN (jcu: word);

procedure Lattel (i: word; var j: word; mode: shortint; dpp: real);

function MatchValues (iini, ifin, imid: integer): MatchFuncType;

procedure LinOp (jcu: word; istart, latmode: integer; dpp: real);

procedure   FillBeamTab;
procedure   FillBetaTab (ilatpos:integer);
procedure   InitBeamTab;
procedure   InitBetaTab;
procedure   AdjustBeamTab;

//procedure SetBPMIndex(ibpm:integer);

procedure ClosedOrbit (VAR fail: Boolean; latmode: shortint; dpp: real);
procedure FlatPeriodic  (var FFlag : Boolean);
procedure NormalMode (var fail: boolean);
procedure Periodic  (var FFlag : Boolean);
procedure Symmetric (var FFlag : Boolean);
procedure OpticReCalc;
procedure OpticCalc(istart: integer);
procedure OrbitReCalc;
procedure OrbitCalc(istart: integer);


implementation

type    { TriBeta = array[1..3] of Vektor_4;
         TriVek5 = array[1..3] of Vektor_5;
         TriVek2 = array[1..3,1..2] of real;
         TriBool = array[1..3] of Boolean;}
         csavetype = record
           spos, beta, betb, betxa, betyb, betxb, betya, disx, disy: real;
         end;

var      dPact : real;
         {ilastStart, }MaxMom: integer;
         tabhandle: TStringGrid;
         tuneplothandle: TtunePlot;
{
         orbitplothandle: Tfigure;
         orbitBPMHandle: array[1..4] of TEdit;
         orbitLabPerHandle, orbitLabLossHandle: TLabel;
         orbitBPMindex: integer;
}
         orbitHandle: TForm;

         csave: array of csavetype;

{temp only}



function SigNafromOp(Op: OpvalType): Matrix_2;
var
  s: matrix_2;
begin
  with Op do begin
    s[1,1]:=beta;
    s[1,2]:=-alfa; s[2,1]:=s[1,2];
    s[2,2]:=(1+Sqr(alfa))/beta;
  end;
  SigNafromOp:=s;
end;
function SigNbfromOp(Op: OpvalType): Matrix_2;
var
  s: matrix_2;
begin
  with Op do begin
    s[1,1]:=betb;
    s[1,2]:=-alfb; s[2,1]:=s[1,2];
    s[2,2]:=(1+Sqr(alfb))/betb;
  end;
  SigNbfromOp:=s;
end;

function DisperfromOp(Op: OpvalType): Vektor_4;
var
  d: Vektor_4;
begin
  with Op do begin
    d[1]:=disx; d[2]:=dipx; d[3]:=disy; d[4]:=dipy;
  end;
  DisperfromOp:=d;
end;

function N2SfromOp(Op:OpvalType): Matrix_5;
// get the transformation matrix emittance --> local sigma
var
  vv, gginv: Matrix_4;
  gamma: real;
  m: Matrix_5;
begin
  with Op do begin
    gamma:=sqrt(1-MatDet2(cmat));
    vv   :=MatCmp24( MatSet2(gamma,0,0,gamma),cmat, MatSca2(-1,MatSyc2(cmat)), MatSet2(gamma,0,0,gamma));
    gginv:=MatCmp24 ( MatSca2(sqrt(1/beta),MatSet2(beta,0,-alfa,1)), MatNul2,
             MatNul2, MatSca2(sqrt(1/betb),MatSet2(betb,0,-alfb,1)));
    m:=MatCpy45(MatMul4(vv,gginv));
    m[1,5]:=disx; m[2,5]:=dipx; m[3,5]:=disy; m[4,5]:=dipy;
    N2SfromOp:=m;
  end;
end;

function OrbitfromOp(Op: OpvalType): Vektor_4;
var
  o: Vektor_4; i: integer;
begin
  with Op do begin
    for i:=1 to 4 do o[i]:=orb[i];
  end;
  OrbitfromOp:=o;
end;



// evaluate the expression for variable element properties
procedure Ella_Eval(j: integer);
var
  err: boolean;
begin
  with Ella[j] do begin
    err:=false;
    if l_exp <> nil then l:=Eval_Exp(l_exp^,err);
    if rot_exp <> nil then rot:=raddeg*Eval_Exp(rot_exp^,err);
    case cod of
      cquad: begin
        if kq_exp <> nil then kq:=Eval_Exp(kq_exp^,err);
      end;
      cbend: begin
        if  kb_exp <> nil then kb :=Eval_Exp( kb_exp^,err);
        if phi_exp <> nil then phi:=raddeg*Eval_Exp(phi_exp^,err);
        if tin_exp <> nil then tin:=raddeg*Eval_Exp(tin_exp^,err);
        if tex_exp <> nil then tex:=raddeg*Eval_Exp(tex_exp^,err);
      end;
      ccomb: begin
        if   ckq_exp <> nil then ckq  :=Eval_Exp(  ckq_exp^,err);
        if  cphi_exp <> nil then cphi :=raddeg*Eval_Exp( cphi_exp^,err);
        if cerin_exp <> nil then cerin:=raddeg*Eval_Exp(cerin_exp^,err);
        if cerex_exp <> nil then cerex:=raddeg*Eval_Exp(cerex_exp^,err);
      end;
      else
    end;
    if err then opaLog(2,'linoplib>Ella_val expression evaluation error for '+ nam);
  end;
end;

procedure closeTuneDiagram;
begin
  tuneplothandle.close;
end;

procedure clearOpval;
// free mem for global optic value dyn arr
begin
  if length(opval  )>0 then Opval  :=nil;
end;


procedure allocOpval;
begin
  clearOpval;
  setLength(Opval  ,ncurvesmax, Glob.NLatt+1);
end;

// shift opval curves down (history)
procedure shiftOpval;
var jcu,i: integer;
begin
  for jcu:=ncurves-1 downto 1 do begin
    for i:=1 to Glob.NLatt do begin
      opval[jcu,i]:=opval[jcu-1,i];
    end;
    oBeam[jcu]:=oBeam[jcu-1];
  end;
end;

procedure setTabHandle(tab:TStringGrid);
begin
  tabhandle:=tab;
end;

procedure setTunePlotHandle(TP: TtunePlot);
begin
  tuneplothandle:=TP;
end;

procedure GetNorm2Sigma;
{get real sigma matrix from normal mode, see S&R 48 and 53: x = V G-1 a
 N2S = V G-1   (4x4)
 fifth column = real dispersions (Dx, Dx', Dy, Dy', 0)
 sigma =  N2S sigma_norm N2S^T
 sigma_norm = diagonalmatrix (emit_a, emit_a, emit_b, emit_b, sig_E^2)
}
var
  vv, gginv: Matrix_4;
  i: integer;
  gamma: real;
begin
  gamma:=sqrt(1-MatDet2(CoupMatrix2));
  vv   :=MatCmp24( MatSca2(gamma,MatUni2),CoupMatrix2, MatSca2(-1,MatSyc2(CoupMatrix2)), MatSca2(gamma,MatUni2));
  gginv:=MatCmp24 ( MatSca2(sqrt(1/SigNa2[1,1]),MatSet2(SigNa2[1,1],0,SigNa2[1,2],1)), MatNul2,
           MatNul2, MatSca2(sqrt(1/SigNb2[1,1]),MatSet2(SigNb2[1,1],0,SigNb2[1,2],1)));
  Norm2Sigma:=MatCpy45(MatMul4(vv,gginv));
  for i:=1 to 4 do Norm2Sigma[i,5]:=Disper2[i];
end;


procedure OptInit;{call after periodic!}

begin
  ModeFlip:=False; // basically lattice may start flipped?
  SigNa0:=SigNafromOp(Glob.Op0);  SigNb0:=SigNbfromOp(Glob.Op0);
  Disper0:=DisperfromOp(Glob.Op0);
  Orbit0:=OrbitfromOp(Glob.Op0);
  CoupMatrix0:=Glob.Op0.cmat;
  Orbit1:=Orbit0; Orbit2:=Orbit1;
  SigNa1:=SigNa0; SigNa2:=SigNa0;
  SigNb1:=SigNb0; SigNb2:=SigNb0;
  Disper1:=Disper0; Disper2:=Disper0;
  CoupMatrix1:=CoupMatrix0; CoupMatrix2:=CoupMatrix0;
  Amat1:=Amat0; Amat2:=Amat0;
  Bmat1:=Bmat0; Bmat2:=Bmat0;
  GetNorm2Sigma;
  TransferMatrix :=Unit_Matrix_5;
  TransferMatrix0:=Unit_Matrix_5;
  MisalignVector:=VecNul4;
  TmatStack:=nil; ElenStack:=nil;
  SPosition:=0; Deflection:=0; AbsDeflection:=0; PathDiff:=0;
  SPosEL:=0;
  MF_save:=nil;
  TimeOfFlight:=0;
  Beam.Qa:=0; Beam.Qb:=0;
//***
  Beam.ChromX:=0; Beam.Chromy:=0;
  SnapSave.xbcount:=0;
end;

function CheckBeamPos: boolean;
const
  apermax=1e3;
begin
  CheckBeamPos:=abs(Orbit1[1])+abs(Orbit1[3])>apermax;
end;

{-------------------------------------------------------------------------}
procedure SliceCalcN (jcu: word);
{recalcs lattice from each elements entry and produces intermediate
points in Curve variable if element is visible in plot window.
requires, that LinOp was done before and a solution exists.}
var
  j, i: integer;
  Opi, Opo: OpvalType;
  dpp: real;
begin
  CurvePlot.ncurve:=0;
  Curve:=New(CurvePt);
  Curve.nex:=nil;
//  CurvePlot.ini:=Curve;

  Sposition:=0.0; TimeOfFlight:=0;
  dpp:=oBeam[jcu].dppset*0.01;
  ModeFlip:=false;


  for i:=1 to Glob.NLatt do begin
    j:=FindEl(i);
    Opi:=Opval[jcu,i-1];
    OpO:=Opval[jcu,i];
    SPosEl:=Opi.spos;
    with Ella[j] do begin

      case cod of
        cdrif: SliceDriftN (Opi, Opo, l, 0);
        cquad: SliceQuadN  (Opi, Opo, l, kq, rot, dpp);
        csext: SliceSextN  (Opi, Opo, l, ms, dpp, sslice);
        csole: SliceSolN   (Opi, Opo, l, ks, dpp);
        cbend: SliceBendN  (Opi, Opo, l, phi, kb, tin, tex, gap, k1in, k1ex, k2in, k2ex, rot, dpp, Lattice[i].inv, 0);
        cundu: SliceUnduN  (Opi, Opo, l, bmax, lam, ugap, fill1, fill2, fill3, rot, dpp, halfu, Lattice[i].inv);
        ccomb: SliceCombN  (Opi, Opo, l, cphi, cerin, cerex, cek1in, cek1ex, cgap, ckq, cms, rot, dpp, cslice, Lattice[i].inv);
      end;
    //  SPosition:=SPosition+l;
    end;
  end;
end;
{-------------------------------------------------------------------------}

procedure Lattel (i: word; var j: word; mode: shortint; dpp: real);
var sway, heave, roll: real;
begin
  Fliphashappened:=false;
  j:=FindEl(i);
  beamLost:=CheckBeamPos;
  with Lattice[i] do begin sway:=dx; heave:=dy; roll:=dt; end;
  if not beamLost then begin
    with Ella[j] do begin
      case cod of
        cdrif : DriftSpace  (l,mode);
        cquad : Quadrupole  (l, kq, rot, dpp, Lattice[i].inv, mode, sway, heave, roll);
        cbend : begin
          Bending     (l, phi, kb, tin, tex, gap, k1in, k1ex, k2in, k2ex, rot, dpp, Lattice[i].inv, mode, sway, heave, roll);
          Deflection:=Deflection+phi;  AbsDeflection:=AbsDeflection+Abs(phi);
        end;
        csext : Sextupole   (l, ms, rot, dpp, sslice, Lattice[i].inv, mode, sway, heave, roll);
        ckick : Kicker      (l, rot, mpol, kslice, amp, xoff, tau, delay, TimeOfFlight, dpp, mode, sway, heave, roll);
        csole : Solenoid    (l, ks, dpp, Lattice[i].inv, mode, sway, heave, roll);
        cundu : Undulator   (l, bmax, lam, ugap, fill1, fill2, fill3, rot, dpp, Lattice[i].inv, mode, halfu, sway, heave, roll);
        ccomb : begin
          Combined    (l, cphi, cerin, cerex, cek1in, cek1ex, cgap, ckq, cms, rot, dpp, cslice, Lattice[i].inv, mode, sway, heave, roll);
          Deflection:=Deflection+cphi;  AbsDeflection:=AbsDeflection+Abs(cphi);
        end;
        cxmrk : XBwrite     (nam, snap, mode);
        cmpol : Multipole   (nord, bnl, rot, dpp, Lattice[i].inv, mode, sway, heave, roll);
        ccorh : HCorr       (dxp, dpp, Lattice[i].inv, mode, rot, sway, heave, roll);
        ccorv : VCorr       (dyp, dpp, Lattice[i].inv, mode, rot, sway, heave, roll);
        crota : Rotation    (rot, Lattice[i].inv, mode);
        cmoni : Monitor     (Lattice[i].inv, mode, rot, sway, heave, roll); // to avoid switching to default drift, because we may have assigned a misalignment
        else    DriftSpace(l,mode);
      end;
    end; //with
  end;
  SPosition:=SPosition+Ella[j].l;
  TimeOfFlight:=TimeOfFlight+Ella[j].l/speed_of_light;
end;

{-------------------------------------------------------------------------}

procedure Inival (istart: integer; direc: shortint; var jom: Word);
// prepare for forward calculation: get optics parameters from stored Op value

var
  b,e,o: Vektor_4;
begin


  if istart=0 then begin
    SigNa0:=SigNafromOp(Glob.Op0);
    SigNb0:=SigNbfromOp(Glob.Op0);
    Disper0:=DisperfromOp(Glob.Op0);
    Orbit0:=OrbitfromOp(Glob.Op0);
    CoupMatrix0:=Glob.Op0.cmat;
    AMat0:=Glob.Op0.am;
    BMat0:=Glob.Op0.bm;
//    GetNorm2Sigma;
    SPosEL:=0;

  end else if istart=Glob.NLatt then begin // backwards //incomplete
    SigNa0:=SigNafromOp(Glob.OpE);
    SigNb0:=SigNbfromOp(Glob.OpE);
    Disper0:=DisperfromOp(Glob.OpE);
    Orbit0:=OrbitfromOp(Glob.OpE);
    CoupMatrix0:=Glob.OpE.cmat;
    AMat0:=Glob.OpE.am;
    BMat0:=Glob.OpE.bm;

  end else begin // from OM
    jom:=Findel(istart);
    b:=ella[jom].om^.bet;
    e:=ella[jom].om^.eta;
    o:=ella[jom].om^.orb;
{    dpp:=ella[jom].om^.dpp;}
//    dpp:=Glob.dpp;
    CoupMatrix0:=ella[jom].om^.cma;
    {change sign if opticsmarker is installed inverted as-191097}
    b[2]:=Lattice[istart].inv*b[2]; b[4]:=Lattice[istart].inv*b[4];
    e[2]:=Lattice[istart].inv*e[2]; e[4]:=Lattice[istart].inv*e[4];
    o[2]:=Lattice[istart].inv*o[2]; o[4]:=Lattice[istart].inv*o[4];
    CoupMatrix0[1,2]:=Lattice[istart].inv*CoupMatrix0[1,2];
    CoupMatrix0[2,1]:=Lattice[istart].inv*CoupMatrix0[2,1];
    SigNa0:=SigNfromBeta(b[1], b[2]);
    SigNb0:=SigNfromBeta(b[3], b[4]);
    Disper0:=e;
    Orbit0:=o;
  end;

  if direc=gobackward then begin
    SigNa0[1,2]:=-SigNa0[1,2];  SigNb0[1,2]:=-SigNb0[1,2];
    Disper0[2]:=-Disper0[2];    Disper0[4]:=-Disper0[4];
    Orbit0[2] :=-Orbit0[2];     Orbit0[4] :=-Orbit0[4];
    CoupMatrix0[1,2]:=-CoupMatrix0[1,2];
    CoupMatrix0[2,1]:=-CoupMatrix0[2,1];
  end;
  SigNa0[2,1]:=SigNa0[1,2]; SigNb0[2,1]:=SigNb0[1,2];

  TransferMatrix :=Unit_Matrix_5;
  TransferMatrix0:=Unit_Matrix_5;
  SigNa1:=SigNa0;   SigNa2:=SigNa0;  SigNb1:=SigNb0;   SigNb2:=SigNb0;
  CoupMatrix1:=CoupMatrix0;  CoupMatrix2:=CoupMatrix0;
  Disper1:=Disper0; Orbit1:=Orbit0;
  Disper2:=Disper0; Orbit2:=Orbit0;
  ModeFlip:=False;  //??
  AMat1:=AMat0; AMat2:=Amat0;
  BMat1:=BMat0; BMat2:=Bmat0;
  Tmatstack:=nil;
  Beam.Qx:=0.0; Beam.Qy:=0.0;
  Beam.Qa:=0.0; Beam.Qb:=0.0;
end;

{---------------------------------------------------}

function MatchValues (iini, ifin, imid: integer): MatchFuncType;
{ calculates values at initial, final and mid point for Matching}

var
  jom, j,k,i :Word;
  func: MatchFuncType;
begin


  SPosition:=0.0; TimeOfFlight:=0; Deflection:=0.0; AbsDeflection:=0.0;
  PathDiff:=0.0; beamLost:=false; jom:=0; j:=0;
// final before initial: calculate backwards
  if ifin < iini then begin
    IniVal(iini, goBackward, jom);
    Stovar(0,iini);
    for i:=iini downto ifin+1 do begin
      Lattice[i].inv:=-Lattice[i].inv;
      Lattel (i, j, do_twiss, 0.0);
      Lattice[i].inv:=-Lattice[i].inv;
      StoVar(0,i-1);
    end;
{?????}
    for i:=iini downto ifin do begin
      with Opval[0,i] do begin
        {alfx:=-alfx; alfy:=-alfy; }dipx:=-dipx; dipy:=-dipy;
        alfa:=-alfa; alfb:=-alfb; dipx:=-dipx; dipy:=-dipy;
        orb[2]:=-orb[2]; orb[4]:=-orb[4];
        spos:=SPosition-spos;
        path:=PathDiff-path;
        phia:=Beam.Qa-phia;
        phib:=Beam.Qb-phib;
      end;
    end;
// calculate forward:
  end else begin
    IniVal(iini, goForward, jom);
    StoVar(0,iini);
    for i:=iini+1 to ifin do begin
      Lattel (i, j, do_twiss, 0.0);
      StoVar(0,i);
    end;
  end;

//  OptInit;

{  func[1]:=Opval[0,ifin].betx;
  func[2]:=Opval[0,ifin].alfx;
  func[3]:=Opval[0,ifin].bety;
  func[4]:=Opval[0,ifin].alfy;
}
  func[1]:=Opval[0,ifin].beta;
  func[2]:=Opval[0,ifin].alfa;
  func[3]:=Opval[0,ifin].betb;
  func[4]:=Opval[0,ifin].alfb;
  func[5]:=Opval[0,ifin].disx;
  func[6]:=Opval[0,ifin].dipx;
  func[7]:=Opval[0,ifin].orb[1]*1000;
  func[8]:=Opval[0,ifin].orb[2]*1000;
  func[9]:=abs(Opval[0,ifin].phia-Opval[0,iini].phia);
  func[10]:=abs(Opval[0,ifin].phib-Opval[0,iini].phib);

  if imid >0 then begin
{
    func[11]:=Opval[0,imid].betx;
    func[12]:=Opval[0,imid].alfx;
    func[13]:=Opval[0,imid].bety;
    func[14]:=Opval[0,imid].alfy;
}
    func[11]:=Opval[0,imid].beta;
    func[12]:=Opval[0,imid].alfa;
    func[13]:=Opval[0,imid].betb;
    func[14]:=Opval[0,imid].alfb;
    func[15]:=Opval[0,imid].disx;
    func[16]:=Opval[0,imid].dipx;
    func[17]:=abs(Opval[0,imid].phia-Opval[0,iini].phia);
    func[18]:=abs(Opval[0,imid].phib-Opval[0,iini].phib);
  end else for k:=11 to 18 do func[k]:=0.0;


//?   Status.Betas:=True;
  MatchValues:=func;

end;

{---------------------------------------------------}

procedure StoVar(jcu,i: word);
begin
  with opval[jcu,i] do begin
    spos:=SPosition; path:=PathDiff;
    orb:=Orbit1;//2;

// subtraction of shifts is already done by Misalign, don't do it here.
//    orb[1]:=orb[1]+Lattice[i].dx;
//    orb[3]:=orb[3]+Lattice[i].dy;

//del    xdpp:=Orbit2[1]; //*** ???
    beta:= SigNa2[1,1]; betb:= SigNb2[1,1];
    alfa:=-SigNa2[1,2]; alfb:=-SigNb2[1,2];
    disx:=Disper2[1];    disy:=Disper2[3];
    dipx:=Disper2[2];    dipy:=Disper2[4];
    phia:=Beam.Qa;  phib:=Beam.Qb;
    cmat:=CoupMatrix2;
  end;
end;

procedure PropPer;
{ 27.6.2016
test procedure: propagation of betas by doing normal form analysis after each element
(or sub-element like rotation).
get's out of sync with Opval data, since an element may do several calls to Tmat.
}
{tried to form transfermatrix  T = R1 M R1-1 R2-1 M R2 with M mirror matrix.
Then any structure becomes periodic? But doesn't work....}
const
   ppdiag=-1;
var
  {mirror,} R1, R2, T: matrix_4;
  i, k: integer;
  fail:boolean;
  TMsave: Matrix_5;
  position:double;
begin
  opalog(ppdiag, 'Periodic solution from one turn matrix after each element:');
  fail:=false;
  R1:=MatUni4;
  opaLog(-2, 'linoplib>PropPer stacksize '+inttostr(Length(Tmatstack))+' '+inttostr(Length(Elenstack)));

  for i:=0 to High(TmatStack) do R1:=MatMul4(TmatStack[i],R1);
//  writeln(ppfile, 'transfermatrix R1 :');
//  printmat4(R1);
//  writeln(ppfile, 'TransferMatrix for comparison :');
//  printmat5(Transfermatrix);
  TMsave:=Transfermatrix;
  for i:=0 to High(TmatStack) do begin
    R1:=MatUni4;
    R2:=MatUni4;
    for k:= 0 to i-1             do R1:= Matmul4(TmatStack[k],R1);
    for k:= i to High(TmatStack) do R2:= Matmul4(TmatStack[k],R2);
    position:=0;
    for k:= 0 to i-1             do position:= position+ElenStack[k].elen;
    T:=R2;
    T:=MatMul4(R1,T);
    Transfermatrix:=MatCpy45(T); // temp, ignore dispersion
    OpaLog(ppdiag,'element '+inttostr(i)+', position = '+ftos(position,8,3)+' m');
    NormalMode (fail);

    if not fail then begin
      with ElenStack[i] do begin
        pos:=position;
        beta:=Signa0[1,1];
        betb:=SigNb0[1,1];
        cdet:=matdet2(CoupMatrix0);
        betaf:=Signa0_flip[1,1];
        betbf:=SigNb0_flip[1,1];
        cdetf:=matdet2(CoupMatrix0_flip);
      end;
    end;
    Transfermatrix:=TMsave;
  end;
  OpaLog(ppdiag, 'ProPerTest done.');
  PropperDone:=true;
  PropperTest:=false;
end;


{---------------------------------------------------}

procedure LinOp (jcu: word; istart, latmode: integer; dpp: real);

var
  i: integer;
  j, jom: word;
  x, Energy : real;
  Dx, Dy: real;

begin

// save old curves (works only for mom mode off)
  ShiftOpval;

  SPosition:=0;  TimeOfFlight:=0; PathDiff:=0; Deflection:=0.0; AbsDeflection:=0.0;
  beamLost:=false; jom:=0; j:=0;
  with Beam do begin
    dppset:=dpp*100;
//***
    ChromX:=0; ChromY:=0;
    Qa:=0; Qb:=0;
    RadInt1:=0; RadInt2:=0; RadInt3:=0; RadInt4a:=0; RadInt4b:=0; RadInt5a:=0; RadInt5b:=0;
  end;

  if istart>0 then begin {backwards from istart to begin of lattice}
    Inival(istart, goBackward, jom);
    Stovar(jcu,istart);
    for i:=istart downto 1 do begin
      Lattice[i].inv:=-Lattice[i].inv;
      Lattel (i, j, latmode, dpp);
      Lattice[i].inv:=-Lattice[i].inv;
      StoVar(jcu,i-1);
    end;
{invert results from backward calculation, i.e. all signs of angles, and
subtract position and phases from their final values:}
    for i:=0 to istart do begin
      with opval[jcu,i] do begin
        dipx:=-dipx; dipy:=-dipy;
        alfa:=-alfa; alfb:=-alfb;
        orb[2]:=-orb[2]; orb[4]:=-orb[4];
        cmat[1,2]:=-cmat[1,2]; cmat[2,1]:=-cmat[2,1];
        spos:=SPosition-spos;
        path:=PathDiff-path;
        phia:=Beam.Qa-phia;
        phib:=Beam.Qb-phib;
      end;
    end;
    Glob.Op0:=Opval[jcu, 0];
{    with Glob.Op0 do begin
      beta   := SigNa2[1,1];    alfa  := SigNa2[1,2];
      betb   := SigNb2[1,1];    alfb  := SigNb2[1,2];
      disx   := Disper2[1];    dipx  :=-Disper2[2];
      disy   := Disper2[3];    dipy  :=-Disper2[4];
      orb[1] := Orbit2[1];     orb[2]:=-Orbit2[2];
      orb[3] := Orbit2[3];     orb[4]:=-Orbit2[4];
    end;
}
  end;

  if istart<Glob.NLatt then begin {forward from istart to end of lattice}
    IniVal(istart, goForward, jom);
    StoVar(jcu,istart);
    for i:=istart{+1} to Glob.NLatt do begin
      Lattel (i, j, latmode, dpp);
      StoVar(jcu,i);
    end;
    Glob.OpE:=Opval[jcu,Glob.NLatt];



//propper test analysis element by element
    if PropPerTest then PropPer else PropperDone:=false;

//?    SigNE:=SigN2; DisperE:=Disper2; DisperNE:=DisperN2; OrbitE:=Orbit2;
  end;

  PathDiff :=Glob.NPer*PathDiff;
  Beam.Circ:=Glob.NPer*SPosition;
  Beam.Angle:=Glob.NPer*Deflection*degrad;
  Beam.AbsAngle:=Glob.NPer*AbsDeflection*degrad;
  Energy   :=Glob.Energy*(1+Glob.dpp);

  if Beam.RadInt2>Glob.Energy*1E-9 then begin // at least 1 eV loss at 1 GeV !
    with Beam do begin
      U0:=Erad_factor*1E-9*Glob.NPer*RadInt2;
      Dx:=RadInt4a/RadInt2; Dy:=RadInt4b/RadInt2;

{   Jx:=1-Dx; Jz:=1-Dz; Je:=2+Dx+Dz; = original,    }
{   changed sign on Dx :   Lenny Rivkin, Stefan Adam}
{   Jx:=1+Dx; Jz:=1-Dz; Je:=2-Dx+Dz;}
{   back to original, because error was in I4 (proc. DipolMit) assuming }
{   a wrong sign of gradient (see above)  Andreas Streun 210694   }

      Ja:=1-Dx; Jb:=1-Dy; Je:=2+Dx+Dy;
      x:=2*Circ/(U0*speed_of_light)*PowI(Energy,-3);
      Ta:=x/Ja;
      Tb:=x/Jb;
      Te:=x/Je;
      Alfa:=RadInt1/SPosition;

{    EmittanzX:=1.4675E-6*Ix[5]/I2; EmittanzZ:=1.4675E-6*Iz[5]/I2;  = orig.,
    changed to 'former'(X and Z)/Jx  : Lenny Rivkin, Stefan Adam }

      Emita:=RadCq_factor*RadInt5a/RadInt2/Ja*Sqr(Energy);
      Emitb:=RadCq_factor*RadInt5b/RadInt2/Jb*Sqr(Energy);
//  add the direct radiation emittance 061207 --> reactivate for flat lattice only
//!!      EmitY:= EmitY+13/55*3.84E-13*Iy[6]/I2/Jy;
      U0:=1E6*U0*PowI(Energy,4);
      sigmaE:=Sqrt(RadCq_factor*RadInt3/Abs(Je)/RadInt2)*Energy;
//get initial sigma matrix
      sigmaNorm:=MatUni5;
      sigmaNorm[1,1]:=Emita; sigmaNorm[2,2]:=Emita;
      sigmaNorm[3,3]:=Emitb; sigmaNorm[4,4]:=Emitb;
      sigmaNorm[5,5]:=sqr(sigmaE);
      sigmaPhys:=MatMul5(Norm2Sigma, Matmul5(sigmaNorm, MatTra5(Norm2Sigma)));
//      PrintMat5(sigmaPhys);
//      writeln(diagfil, sqrt(sigmaPhys[1,1]), sqrt(sigmaPhys[3,3]));
    end;
  end
  else begin { dummy settings for lattice without dipoles:}
    with Beam do begin
      U0:=0; Ja:=1; Jb:=1; Ta:=0; Tb:=0; Te:=0; Alfa:=0; Emita:=0; Emitb:=0; sigmaE:=0;
    end;
  end;
  with Beam do begin
    Qa:=Glob.NPer*Qa;         Qb:=Glob.NPer*Qb;
    //*** temp only:
    Qx:=Qa; Qy:=Qb;
    //***
    ChromX:=Glob.NPer*ChromX; ChromY:=Glob.NPer*ChromY;
  end;
  oBeam[jcu]:=Beam;
  Status.Betas:=True;
  Status.Circular:=abs(oBeam[0].angle-360) < 0.01
  //be generous with closing the ring: better check in geometry if endpoint meets start 13.5.2020

 // if CurvePlot.enable then SliceCalc(jcu, dpp);
end;

//--------------------------------------------------------


procedure PrintLatticeData (fnam0: string);
const
  iunit: array[1..5] of string[6] =('[m]   ','[1/m] ','[1/m2]','[1/m] ','[1/m] ');
var
  fname: string;
  outfi: textfile;
  i,j:integer;      x:real;
begin
  fname:=fnam0+'_data.txt';
  assignFile(outfi,fname);
{$I-}
  rewrite(outfi);
{$I+}
  if IOResult =0 then begin
    writeln(outfi,'Lattice Parameters');
    writeln(outfi);
    writeln(outfi,FileName+':'+ActSeg^.nam);
    writeln(outfi);
    with Beam do begin
      writeln(outfi,'Circumference          '+' [m]    ',ftos(Circ,12,6));
      writeln(outfi,'Horizontal Tune        '+'        ',ftos(Qa,12,6));
      writeln(outfi,'Vertical   Tune        '+'        ',ftos(Qb,12,6));
      writeln(outfi,'Nat. hor. Chromaticity '+'        ',ftos(ChromX,12,6));
      writeln(outfi,'Nat. vert.Chromaticity '+'        ',ftos(ChromY,12,6));
      writeln(outfi,'Momentum compaction    '+'        ',ftos(alfa,-8,2));
      writeln(outfi,'a-mode damping Ja      '+'        ',ftos(Ja,12,6));
      writeln(outfi,'b-mode damping Jb      '+'        ',ftos(Jb,12,6));
      writeln(outfi);
      writeln(outfi,'Energy                 '+' [GeV]  ',ftos(Glob.Energy,12,6));
      writeln(outfi,'Radiated energy/turn   '+' [MeV]  ',ftos(U0/1000,12,6));
      writeln(outfi,'a-mode Emittance       '+' [nm]   ',ftos(Emita*1e9,12,6));
      writeln(outfi,'b-mode Emittance       '+' [nm]   ',ftos(Emitb*1e9,12,6));
      writeln(outfi,'Natural energy spread  '+'        ',ftos(sigmaE,-8,2));
      writeln(outfi,'a-mode damping time    '+' [ms]   ',ftos(1000*Ta,12,6));
      writeln(outfi,'b-mode damping time    '+' [ms]   ',ftos(1000*Tb,12,6));
      writeln(outfi,'Long. damping time     '+' [ms]   ',ftos(1000*Te,12,6));
      writeln(outfi);
      writeln(outfi,'Radiation Integrals (for one period):');
      writeln(outfi,'      I1    '+iunit[1]+'   '+ftos(RadInt1,-8,2));
      writeln(outfi,'      I2    '+iunit[2]+'   '+ftos(RadInt2,-8,2));
      writeln(outfi,'      I3    '+iunit[3]+'   '+ftos(RadInt3,-8,2));
      writeln(outfi,'      I4a/b '+iunit[4]+'   '+ftos(RadInt4a,-8,2)+'   '+ftos(RadInt4b,-8,2));
      writeln(outfi,'      I5a/b '+iunit[5]+'   '+ftos(RadInt5a,-8,2)+'   '+ftos(RadInt5b,-8,2));
      writeln(outfi);
      writeln(outfi,'Transfer Matrix (x,x'',y,y'',dp/p):');
      for i:=1 to 4 do begin
        for j:=1 to 5 do begin
           x:=TransferMatrix[i,j];
           if x<0 then write(outfi,' ',ftos(x,-7,2)) else write(outfi,'  ',ftos(x,-7,2));
        end;
        writeln(outfi);
      end;
      writeln(outfi);


//      PrintHTMLData;     disabled, was once included to establish a lattice repository

    end;
    CloseFile(outfi);

  end else begin
    OPALog(2,'PrintLatticeData: could not write '+fname);
    fnam0:='';
  end;

end;

{-------------------------------------------------------------------------}

procedure PrintHTMLData;
const
  hci='<tr><th colspan=3>';
  hcf='</th></tr>';
  rci='<tr><td class="datnam">';
  rcf='</td></tr>';
  col='</td><td class="datval">';
  col2='</td><td class="datnam">';

var
  fname, latname: string;
  outfi: textfile;
begin
  latname:=ExtractFileName(FileName);
  latname:=Copy(latname,0,Pos('.',latname)-1);
  fname:=work_dir+latname+'_data.html';
  assignFile(outfi,fname);
{$I-}
  rewrite(outfi);
{$I+}
  if IOResult =0 then begin
//    writeln(outfi,'<head><LINK href="opadat.css" type=text/css rel=stylesheet></head><body>');
    writeln(outfi,'<table>');
    writeln(outfi,hci+'Lattice:Segment = '+latname+':'+ActSeg^.nam+hcf);
    with Beam do begin
      writeln(outfi,rci+'Periodicity'+col+inttostr(Glob.Nper)+col2+rcf);
      writeln(outfi,rci+'Circumference'+col+ftos(Circ,8,2)+col2+'m'+rcf);
      writeln(outfi,rci+'Working point Qx/Qy'+col+ftos(Qa,7,2)+'/'+ftos(Qb,7,2)+col2+rcf);
      writeln(outfi,rci+'Natural chromaticities'+col+ftos(ChromX,7,1)+'/'+ftos(ChromY,7,1)+col2+rcf);
      writeln(outfi,rci+'Momentum compaction'+col+ftos(alfa,-3,2)+col2+rcf);
      writeln(outfi,rci+'Horizontal damping Jx'+col+ftos(Ja,6,3)+col2+rcf);
      writeln(outfi,rci+'Beam energy'+col+ftos(Glob.Energy,7,2)+col2+'GeV'+rcf);
      writeln(outfi,rci+'Radiated energy/turn'+col+ftos(U0,6,1)+col2+'keV'+rcf);
      writeln(outfi,rci+'Natural emittance'+col+ftos(Emita*1e9,7,3)+col2+'nm.rad'+rcf);
      writeln(outfi,rci+'Natural energy spread'+col+ftos(sigmaE,-3,2)+col2+rcf);
      writeln(outfi,rci+'Damping times x/y/E'+col+ftos(1000*Ta,6,2)+'/'+ftos(1000*Tb,6,2)+'/'+ftos(1000*Te,6,2)+col2+'ms'+rcf);
    end;
    writeln(outfi,'</table>');
    CloseFile(outfi);
  end;
end;

{-------------------------------------------------------------------------}

procedure PrintCurve (fnam0: string);
var
  c: CurvePt;
  fname: string;
  outfi: textfile;
  s: real;
  i,j: integer;
begin
//write plotted data to file
  fname:=fnam0+'_beta.txt';
  assignFile(outfi,fname);
{$I-}
  rewrite(outfi);
{$I+}
  if IOResult =0 then begin
    writeln(outfi,Glob.NLatt);
    writeln(outfi,'# ^ this is the number of lattice points.');
    writeln(outfi,'# now follows this number of lines with start/end-position, magnet type and name.');
    writeln(outfi,'# types: 0=Drift,1=Marker,2=Quadrupole,3=Bending,4=Sextupole,5=Solenoid');
    writeln(outfi,'#  6=Undulator,7=Septum,8=Kicker,9=OpticsMarker,10=Combined,11=PhotonBeam');
    writeln(outfi,'#  12=PhaseKick,13=Matrix,14=Octupole,15=Decapole,16=LongGradBend');
    writeln(outfi,'#  17=Monitor,18=H-Corrector,19=V-Corrector');
    s:=0.0;
    for i:=1 to Glob.NLatt do begin
      j:=FindEl(i);
      writeln(outfi, s:12:6, s+Ella[j].l:12:6, ella[j].cod:8, '    ', ella[j].nam);
      s:=s+Ella[j].l;
    end; {for}
    writeln(outfi,'# Done with magnet listing.');
    writeln(outfi,'# Number of lattice points.');
    writeln(outfi,'# Optics parameters after each element:');
    writeln(outfi,'#          s,     beta-a,     beta-b,     alfa-a,     alfa-b,      eta-x,     eta`-x,      eta-y,     eta`-y,   mu-x/2pi,   mu-y/2pi,   Name');
    writeln(outfi, Glob.NLatt);
    for i:=0 to Glob.NLatt do with Opval[0,i] do begin
       j:=Findel(i);
       writeln(outfi, spos:12:6, beta:12:6, betb:12:6, alfa:12:6, alfb:12:6, disx:12:6, dipx:12:6, disy:12:6, dipy:12:6, phia:12:6, phib:12:6, Ella[j].ax:9:3, Ella[j].ay:9:3, Ella[j].cod:3, ' ', Ella[Findel(i)].nam);
    end; {for}
    SliceCalcN(0);
    writeln(outfi,'# Startt,end and resolution of the beta data:');
    writeln(outfi,'# Data for curves: spos, beta-xa, beta-yb, disp-x:');
    writeln(outfi,CurvePlot.sini:12:6, CurvePlot.sfin:12:6, CurvePlot.slice:12:8);
    c:=CurvePlot.ini;
    writeln(outfi, c^.spos:12:6, c^.betxa:12:6, c^.betyb:12:6, c^.disx:12:6);
    while c^.nex <> nil do begin
      c:=c^.nex;
      writeln(outfi, c^.spos:12:6, c^.betxa:12:6, c^.betyb:12:6, c^.disx:12:6);
    end;
    writeln(outfi,'# end of file.');
    ClearCurve;
    CloseFile(outfi);
  end else begin
    OPALog(2,'PrintCurve: could not write '+fname);
  end;

end;


procedure PrintRadiation (fnam0:string);
const
  k=',';
var
  fname: string;
  outfi: textfile;
  ang, bfield, s: real;
  i,j: integer;
  isbend, wasbend:boolean;
begin
  fname:=fnam0+'_rad.txt';
  assignFile(outfi,fname);
{$I-}
  rewrite(outfi);
{$I+}
  if IOResult =0 then begin
    writeln(outfi,'# Data for radiation calculation');
    writeln(outfi,'# Beam energy [GeV], Emittance x and y [nm.rad] and energy spread');
    writeln(outfi, Glob.Energy:12:6,k, Beam.Emita*1e9:12:6,k, Beam.Emitb*1e9:12:6,k, Beam.sigmaE:12:9);
    writeln(outfi,'# Following lines give for each bending magnet');
    writeln(outfi,'#   position and beam parameters at ENTRY to magnet; field [T], Name');
    writeln(outfi,'#   "exit" is an additional line to give parameters at EXIT of magnet');
    writeln(outfi,'#   (this line is omitted if the next element is another bending magnet)');
    writeln(outfi,'# Note that these data do NOT (yet) include coupled beam parameters, only emittances!');
    writeln(outfi,'#  if Emittancy y is zero, it has to be inserted manually before further processing.');
    wasbend:=false;
    writeln(outfi,'#          s,      beta-x,      beta-y,      alfa-x,      alfa-y,      disp-x,     disp`-x,     B-field');
    s:=0;
    for i:=1 to Glob.NLatt do begin
      j:=FindEl(i);
      ang:=0;
      if ella[j].cod = cbend then ang:=ella[j].phi;
      if ella[j].cod = ccomb then ang:=ella[j].cphi;
      if (abs(ang)>0) and (abs(ella[j].l)>0) then begin
        isbend:=true;
        bfield:=Glob.Energy*1e9/speed_of_light * ang/ella[j].l;
        with Opval[0,i-1] do write(outfi, spos:12:6,k, beta:12:6,k, betb:12:6,k, alfa:12:6,k, alfb:12:6,k, disx:12:6,k, dipx:12:6,k);
        writeln(outfi, bfield:12:6,k,'   ', ella[j].nam);
        wasbend:=isbend;
      end else begin
        isbend:=false;
        if wasbend then begin
          wasbend:=false;
          with Opval[0,i-1] do write(outfi, spos:12:6,k, beta:12:6,k, betb:12:6,k, alfa:12:6,k, alfb:12:6,k, disx:12:6,k, dipx:12:6,k);
          writeln(outfi, '    0.000000',k,'   exit');
        end;
      end;
      s:=s+Ella[j].l;
    end; {for}
    writeln(outfi,'# END');
    CloseFile(outfi);
  end;
end;

procedure printMagnets(fnam0: string);
var
  fname: string;
  outfi: textfile;
  s: real;
  i,j: integer;
begin
  fname:=fnam0+'_mag.txt';
  assignFile(outfi,fname);

{$I-}
  rewrite(outfi);
{$I+}
  if IOResult =0 then begin
    s:=0.0;
    writeln(outfi, Glob.Energy:12:6);
    for i:=1 to Glob.NLatt do begin
      j:=FindEl(i);
      with Ella[j] do begin
        case cod of
          cquad: writeln(outfi,'q ', nam,' ', s:12:6, l:12:6, kq:12:6);
          cbend: writeln(outfi,'b ', nam,' ', s:12:6, l:12:6, phi:12:6, tin:12:6, tex:12:6, kb:12:6);
          csext: writeln(outfi,'s ', nam,' ', s:12:6, l:12:6, ms:12:6);
          ccomb: writeln(outfi,'c ', nam,' ', s:12:6, l:12:6, cphi:12:6, cerin:12:6, cerex:12:6, ckq:12:6, cms:12:6);
          cmpol: writeln(outfi,'p ', nam,' ', s:12:6, nord:4, bnl:12:3);
        end;
        s:=s + l;
      end;
    end; {for}
    writeln(outfi, 'x ', 'end', s:12:6);
    CloseFile(outfi);
  end;
end;


{----------------------------------------------}

procedure setOrbitHandle (OP: TForm);
begin
  orbitHandle:=OP;
end;

{
procedure setOrbitHandles (OP: TFigure; edx, edxp, edy, edyp: TEdit; lper, lloss: TLabel);
begin
  orbitPlotHandle:=OP;
  orbitBPMHandle[1]:=edx;
  orbitBPMHandle[2]:=edxp;
  orbitBPMHandle[3]:=edy;
  orbitBPMHandle[4]:=edyp;
  orbitLabPerHandle:=lper;
  orbitLabLossHandle:=lloss;
  orbitBPMindex:=-1;
end;
}

{
procedure SetBPMIndex(ibpm:integer);
begin
  orbitBPMindex:=ibpm;
end;
}

procedure PlotOrbit;
begin
  OrbitHandle.Repaint;
end;


procedure PlotBeta;
var
  i, jcu, jcumax: integer;
  startpos, dispfac, orbfac: real;

procedure BetaCurveN (jcu:word; HCol, VCol, DCol, DyCol: TColor);
var
  i: integer;
  c: CurvePt;
//  dpp: real;
begin
//    dpp:=oBeam[jcu].dppset*0.01;
    SliceCalcN(jcu);

    if csaveaction=2 then csave:=nil;

    case ShowDisp of
      1: with vp do begin
        SetRangeY(-2*dispmax,dispmax);
// plot saved curve if available
        Line(CurvePlot.sini,0,CurvePlot.sfin,0);
        if Length(csave)>0 then begin
          setColor(dimcol(clBlack,DCol,0.5));
          moveto(csave[0].spos, csave[0].disx*dispfac);
          for i:=1 to High(csave) do lineto(csave[i].spos, csave[i].disx*dispfac); stroke;
          setColor(dimcol(clBlack,DyCol,0.5));
          moveto(csave[0].spos, csave[0].disy*dispfac);
          for i:=1 to High(csave) do lineto(csave[i].spos, csave[i].disy*dispfac); stroke;
        end;
        setColor(DCol);
        setStyle(psSolid); setThick(1);
        c:=CurvePlot.ini;

        moveto(c^.spos, c^.disx*dispfac);
        while c^.nex <> nil do begin
          c:=c^.nex;
          lineto(c^.spos, c^.disx*dispfac);
        end;
        stroke;
        if not status.Uncoupled then begin
          setColor(DyCol);
          setstyle(psSolid);
          c:=CurvePlot.ini;
          moveto(c^.spos, c^.disy*dispfac);
          while c^.nex <> nil do begin
            c:=c^.nex;
            lineto(c^.spos, c^.disy*dispfac);
          end;
          stroke;
        end;
      end;
      2: with vp do begin
        SetRangeY(-2*orbmax, orbmax);
        Line(CurvePlot.sini,0,CurvePlot.sfin,0);
        // plot saved curve if available
        setColor(DCol);
         setstyle(psDash); setThick(1);
         c:=CurvePlot.ini;
         moveto(c^.spos, c^.xpos*orbfac);
        while c^.nex <> nil do begin
          c:=c^.nex;
          lineto(c^.spos, c^.xpos*orbfac);
        end;
        stroke;
        if not status.Uncoupled then begin
          setColor(DyCol);
          setstyle(psDash);
          c:=CurvePlot.ini;
          moveto(c^.spos, c^.ypos*orbfac);
          while c^.nex <> nil do begin
            c:=c^.nex;
            lineto(c^.spos, c^.ypos*orbfac);
          end;
          stroke;
        end;
      end;
      3: with vp do begin
        SetRangeY(-2*cdetmax, cdetmax);
        Line(CurvePlot.sini,0,CurvePlot.sfin,0);
        if propperdone and showBetas[3] then begin //propperplot test
          setstyle(psSolid); setThick(1);
          setcolor(clOlive);
          with Elenstack[0] do moveto(pos, cdet*dispfac);
          for i:=1 to High(TMatStack) do with Elenstack[i] do lineto(pos, cdet*dispfac);
          with Elenstack[High(Elenstack)] do lineto(pos+elen, Elenstack[0].cdet*dispfac);
          stroke;

          setcolor($000080FF);
          with Elenstack[0] do moveto(pos, cdetf*dispfac);
          for i:=1 to High(TMatStack) do with Elenstack[i] do lineto(pos, cdetf*dispfac);
          with Elenstack[High(Elenstack)] do lineto(pos+elen, Elenstack[0].cdetf*dispfac);
          stroke;
        end;
        if showBetas[1] or showBetas[2] then begin
          setColor(clTeal);
          setstyle(psSolid);
          c:=CurvePlot.ini;
          moveto(c^.spos, c^.cdet*dispfac);
          while c^.nex <> nil do begin
            c:=c^.nex;
            lineto(c^.spos, c^.cdet*dispfac);
          end;
          stroke;
        end;
      end;
    end; //case



    vp.SetRangeY(0,1.5*betamax);

 // plot saved curve if available
    if Length(csave)>0 then begin
      if ShowBetas[2] then with vp do begin
        setColor(dimcol(clBlack,HCol,0.3));
        setStyle(psDash); setThick(1);
        moveto(csave[0].spos, csave[0].betxa);
        for i:=1 to High(csave) do lineto(csave[i].spos, csave[i].betxa); stroke;
        setStyle(psDot);
        moveto(csave[0].spos, csave[0].betxb);
        for i:=1 to High(csave) do lineto(csave[i].spos, csave[i].betxb); stroke;
        setColor(dimcol(clBlack,VCol,0.5));
        setStyle(psDash);
        moveto(csave[0].spos, csave[0].betyb);
        for i:=1 to High(csave) do lineto(csave[i].spos, csave[i].betyb); stroke;
        setStyle(psDot);
        moveto(csave[0].spos, csave[0].betya);
        for i:=1 to High(csave) do lineto(csave[i].spos, csave[i].betya); stroke;
      end;
      if ShowBetas[1] then with vp do begin
        setStyle(psSolid); setThick(1);
        setColor(dimcol(clBlack,HCol,0.3));
        moveto(csave[0].spos, csave[0].beta);
        for i:=1 to High(csave) do lineto(csave[i].spos, csave[i].beta); stroke;
        setColor(dimcol(clBlack,VCol,0.5));
        moveto(csave[0].spos, csave[0].betb);
        for i:=1 to High(csave) do lineto(csave[i].spos, csave[i].betb); stroke;
      end;
    end;

    vp.setcolor(HCol);
    if ShowBetas[1] then with vp do begin
      setStyle(psSolid); setThick(1);
      c:=CurvePlot.ini;
      moveto(c^.spos, c^.beta);
      while c^.nex <> nil do begin
        c:=c^.nex;
        lineto(c^.spos, c^.beta);
      end;
      stroke;
    end;

    vp.setcolor(HCol);
    if ShowBetas[2] then with vp do begin
      setStyle(psDash); setThick(1);
      c:=CurvePlot.ini;
      moveto(c^.spos, c^.betxa);
      while c^.nex <> nil do begin
        c:=c^.nex;
        lineto(c^.spos, c^.betxa);
      end;
      stroke;
      setStyle(psDot);
      c:=CurvePlot.ini;
      moveto(c^.spos, c^.betxb);
      while c^.nex <> nil do begin
        c:=c^.nex;
        lineto(c^.spos, c^.betxb);
      end;
      stroke;
    end;

    vp.setcolor(VCol);
    if ShowBetas[1] then with vp do begin
      setStyle(psSolid); setThick(1);
      c:=CurvePlot.ini;
      moveto(c^.spos, c^.betb);
      while c^.nex <> nil do begin
        c:=c^.nex;
        lineto(c^.spos, c^.betb);
      end;
      stroke;
    end;

    vp.setcolor(VCol);
    if ShowBetas[2] then with vp do begin
      setStyle(psDash); setThick(1);
      c:=CurvePlot.ini;
      moveto(c^.spos, c^.betyb);
      while c^.nex <> nil do begin
        c:=c^.nex;
        lineto(c^.spos, c^.betyb);
      end;
      stroke;
      setStyle(psDot);
      c:=CurvePlot.ini;
      moveto(c^.spos, c^.betya);
      while c^.nex <> nil do begin
        c:=c^.nex;
        lineto(c^.spos, c^.betya);
      end;
      stroke;
    end;

// save data from the visible curve for overplotting
    if csaveaction=1 then begin
      c:=CurvePlot.ini;
      setlength(csave,1);
      with csave[0] do begin
        spos:=c^.spos; betxa:=c^.betxa; betyb:=c^.betyb; disx:=c^.disx;
                       betxb:=c^.betxb; betya:=c^.betya; disy:=c^.disy;
      end;
      while c^.nex <> nil do begin
        c:=c^.nex;
        setlength(csave,length(csave)+1);
        with csave[High(csave)] do begin
        spos:=c^.spos; beta:=c^.beta; betxa:=c^.betxa; betyb:=c^.betyb; disx:=c^.disx;
                       betb:=c^.betb; betxb:=c^.betxb; betya:=c^.betya; disy:=c^.disy;
        end;
      end;
    end;
    ClearCurve;

    if ShowBetas[3] and PropperDone then with vp do begin //propperplot test

      setstyle(psSolid); setThick(1);
      setcolor(dimcol(HCol, clblack, 0.5));
      with Elenstack[0] do moveto(pos, beta);
      for i:=1 to High(TMatStack) do with Elenstack[i] do lineto(pos, beta);
      with Elenstack[High(Elenstack)] do lineto(pos+elen, Elenstack[0].beta);
      stroke;

      setcolor(dimcol(vCol, clblack, 0.5));
      with Elenstack[0] do moveto(pos, betb);
      for i:=1 to High(TMatStack) do with Elenstack[i] do lineto(pos, betb);
      with Elenstack[High(Elenstack)] do lineto(pos+elen, Elenstack[0].betb);
      stroke;

      setcolor(dimcol(HCol, clwhite, 0.5));
      with Elenstack[0] do moveto(pos, betaf);
      for i:=1 to High(TMatStack) do with Elenstack[i] do lineto(pos, betaf);
      with Elenstack[High(Elenstack)] do lineto(pos+elen, Elenstack[0].betaf);
      stroke;

      setcolor(dimcol(vCol, clwhite, 0.5));
      with Elenstack[0] do moveto(pos, betbf);
      for i:=1 to High(TMatStack) do with Elenstack[i] do lineto(pos, betbf);
      with Elenstack[High(Elenstack)] do lineto(pos+elen, Elenstack[0].betbf);
      stroke;

    end;
  end;


begin
  if xautoscale then begin
    if Maxmom=1 then jcumax:=0 else jcumax:=2;
    betamax:=0.001; dispmax:=0.0; orbmax:=0.0; cdetmax:=0.0;
    for i:=1 to Glob.NLatt do for jcu:=0 to jcumax do begin
      with Opval[jcu,i] do begin
        if beta>betamax then betamax:=beta;
        if betb>betamax then betamax:=betb;
        if abs(disx)>dispmax then dispmax:=abs(disx);
        if abs(disy)>dispmax then dispmax:=abs(disy);
        if abs(orb[1])>orbmax then orbmax:=abs(orb[1]);
        if abs(orb[3])>orbmax then orbmax:=abs(orb[3]);
        if abs(matdet2(cmat))>cdetmax then cdetmax:=abs(matdet2(cmat));
      end;
    end;
    cdetmax:=cdetmax*1.05;
    if dispmax < 1e-4 then dispmax:=1E-4;
    if orbmax < 1e-6 then orbmax:=1e-6;
    if cdetmax< 1e-4 then cdetmax:=1e-4;
    orbmax:=orbmax*1000;
  end;

  vp.ClearView(true,true,true,false, clWhite);

  vp.SetColor(clblack);

  vp.SetRangeY(0, 1.5*betamax);
  vp.Axis(2,clBlack,'Betafunctions [m]');
  case ShowDisp of
    1: begin
      dispfac:=1.0; orbfac:=1000*dispmax/orbmax;
      vp.SetRangeY(-2*dispmax,dispmax);
      vp.Axis(4,clblack,'Dispersion [m]');
    end;
    2: begin
      orbfac:=1000.0; dispfac:=orbmax/dispmax;
      vp.SetRangeY(-2*orbmax,orbmax);
      vp.Axis(4,clblack,'Orbit [mm]');
    end;
    3: begin
      dispfac:=1.0;
      vp.SetRangeY(-2*cdetmax, cdetmax);
      vp.Axis(4,clblack,'det C');
    end;
  end;

  if Maxmom=1 then begin
    BetaCurveN (0, betax_col, betay_col, dispx_col, dispy_col);

  end else begin
    csaveaction:=2; // clear saved curves
    BetaCurveN(1, betax_col_m, betay_col_m, dispx_col_m, dispy_col_m);
    BetaCurveN(2, betax_col_p, betay_col_p, dispx_col_p, dispy_col_p);
    BetaCurveN(0, betax_col, betay_col, dispx_col, dispy_col);
  end;
  csaveaction:=0; // reset csave to not saving new but keeping saved curve
  with vp do begin
    SetColor(clYellow);
    startpos:=Opval[0,ilaststart].spos;
    moveto(startpos,0.0); lineto(startpos,betamax*1.5);
//?  FSetColor(clWhite);
    SetColor(clblack);
    SetStyle(psDot); setThick(1);
    startpos:=Opval[0,ibetamark].spos;
    Line(startpos,0.0,startpos,betamax*1.5);
    setcolor(clfuchsia);
    for i:=0 to High(MF_save) do with MF_save[i] do begin
      if act=2 then begin
        setstyle(psdot);
        Line(spos,0.0,spos, betamax*1.0);
      end else begin
        setstyle(pssolid);
        Line(spos,betamax, spos, betamax*1.5);
      end;
    end;
    SetColor(clblack);  SetStyle(psSolid);
  end;
end;


{----------------------------------------------}

procedure PlotEnv;
const
  dxy=0.02;
var
  i: integer;
  ss, sx, sy, sxb, sya, sex, sey, sox, soy: array of Real;
  startpos, emix, emiy, esprd: real;
  c: CurvePt;
  xcent, ycent, icent, plumi: integer;
  x1,y1,x2,y2: real;
begin
  startpos:=Opval[0,ibetamark].spos;

  SliceCalcN(0);
  setlength(ss,CurvePlot.ncurve);
  setlength(sx,CurvePlot.ncurve);
  setlength(sy,CurvePlot.ncurve);
  setlength(sxb,CurvePlot.ncurve);
  setlength(sya,CurvePlot.ncurve);
  setlength(sex,CurvePlot.ncurve);
  setlength(sey,CurvePlot.ncurve);
  setlength(sox,CurvePlot.ncurve);
  setlength(soy,CurvePlot.ncurve);

  if useEqEmi then begin
    if status.uncoupled then begin
      emix:=Beam.Emita/(1+env_erat*Beam.Jb/Beam.Ja); emiy:=env_erat*emix;
    end else begin
      emix:=Beam.Emita; emiy:=Beam.Emitb;
    end;
    esprd:=Beam.sigmae;
  end else begin
    emix:=env_emix; emiy:=env_emiy; esprd:=env_sdpp;
  end;

  c:=CurvePlot.ini; i:=0;
  while c^.nex <> nil do begin
    Inc(i);
    c:=c^.nex;
    ss[i]:=c^.spos;
    sex[i]:=abs(esprd*c^.disx);
    sey[i]:=abs(esprd*c^.disy);
    sox[i]:=c^.xpos*1000;
    soy[i]:=c^.ypos*1000;
    sxb[i]:=sqrt(emiy*c^.betxb)*1000;
    sya[i]:=sqrt(emix*c^.betya)*1000;
    sx[i]:=sqrt(emix*c^.betxa + emiy*c^.betxb + sqr(sex[i]))*1000;
    sy[i]:=sqrt(emiy*c^.betyb + emix*c^.betya + sqr(sey[i]))*1000;
    sex[i]:=sex[i]*1000;
    sey[i]:=sey[i]*1000;
  end;

  xcent:=0; // do one-sided plot if there is no offset ... to be ctn'd
  ycent:=0;
  if xautoscale then begin
    envelmaxx:=0.001;
    envelmaxy:=0.001;
    for i:=1 to CurvePlot.ncurve do begin
      if sx[i]+abs(sox[i]) > envelmaxx then envelmaxx:=sx[i]+abs(sox[i]);
      if sy[i]+abs(soy[i]) > envelmaxy then envelmaxy:=sy[i]+abs(soy[i]);
    end;
//    if envelmaxx > envelmaxy then envelmaxy:=envelmaxx else envelmaxx:=envelmaxy;
  end;
  for i:=1 to CurvePlot.ncurve do begin
    if (abs(sox[i]) > 0.001) then xcent:=1;
    if (abs(soy[i]) > 0.001) then ycent:=1;
  end;


  x1:=0; y2:=1;
  if xcent=1 then begin
    if ycent=1 then x2:=0.500 else x2:=0.667;
  end else begin
    if ycent=1 then x2:=0.333 else x2:=0.500;
  end;
  y1:=x2+dxy;
  x2:=x2-dxy;

  vp.ClearView(true, true, true, false, clWhite);

  vp.SetRangeY(-xcent*envelmaxx, envelmaxx);
  vp.AxisPart(2,x1,x2, clBlack,'sigma-X [mm]');

  if xcent=1 then vp.SetRangeY(-(x2+x1)/(x2-x1)*envelmaxx, (2-x2-x1)/(x2-x1)*envelmaxx)
             else vp.SetRangeY(     -x1/(x2-x1)*envelmaxx,    (1-x1)/(x2-x1)*envelmaxx);

  PlotApertures(2);
  if xcent=1 then PlotApertures(0);
  with vp do begin
    for icent:=0 to xcent do begin
      plumi:=1-2*icent;
      setcolor(dispx_col);
      setstyle(psSolid); setThick(1);
      moveto(ss[1], sox[i]+plumi*sex[1]);
      for i:=2 to High(ss) do begin
        lineto(ss[i], sox[i]+plumi*sex[i]);
      end;
      stroke;
      setcolor(betax_col);
      setstyle(psSolid);
      moveto(ss[1], sox[i]+plumi*sx[1]);
      for i:=2 to High(ss) do begin
        lineto(ss[i], sox[i]+plumi*sx[i]);
      end;
      stroke;
      setstyle(psDot);
      moveto(ss[1], sox[i]+plumi*sxb[1]);
      for i:=2 to High(ss) do begin
        lineto(ss[i], sox[i]+plumi*sxb[i]);
      end;
      stroke;
    end;
    setstyle(psDash);
    moveto(ss[1], sox[1]);
    for i:=2 to High(ss) do begin
      lineto(ss[i], sox[i]);
    end;
    stroke;
    SetColor(clblack);  SetStyle(psDot);
    line(startpos,0.0,startpos,envelmaxx);
    SetStyle(psSolid);
    Line(CurvePlot.sini, 0.0,CurvePlot.sfin,0.0);
  end;

   vp.SetRangeY(-ycent*envelmaxy, envelmaxy);
   vp.AxisPart(2,y1, y2, clBlack,'sigma-Y [mm]');

  if ycent=1 then vp.SetRangeY(-(y2+y1)/(y2-y1)*envelmaxy, (2-y2-y1)/(y2-y1)*envelmaxy)
             else vp.SetRangeY(     -y1/(y2-y1)*envelmaxy,    (1-y1)/(y2-y1)*envelmaxy);

  PlotApertures(3);
  if ycent=1 then PlotApertures(1);
  with vp do begin
    for icent:=0 to ycent do begin
      plumi:=1-2*icent;
      setcolor(dispy_col);
      setstyle(psSolid); setThick(1);
      moveto(ss[1], soy[i]+plumi*sey[1]);
      for i:=2 to High(ss) do begin
        lineto(ss[i], soy[i]+plumi*sey[i]);
      end;
      stroke;
      setcolor(betay_col);
      setstyle(psSolid);
      moveto(ss[1], soy[i]+plumi*sy[1]);
      for i:=2 to High(ss) do begin
        lineto(ss[i], soy[i]+plumi*sy[i]);
      end;
      stroke;
      setstyle(psDot);
      moveto(ss[1], soy[i]+plumi*sya[1]);
      for i:=2 to High(ss) do begin
        lineto(ss[i], soy[i]+plumi*sya[i]);
      end;
      stroke;
    end;
    setstyle(psDash);
    moveto(ss[1], soy[1]);
    for i:=2 to High(ss) do begin
      lineto(ss[i], soy[i]);
    end;
    stroke;
    SetColor(clblack);  SetStyle(psDot);
    line(startpos,0.0,startpos,envelmaxy);
    SetStyle(psSolid);
    Line(CurvePlot.sini, 0.0,CurvePlot.sfin,0.0);
  end;
  sx:=nil; sy:=nil; sex:=nil; sey:=nil; sox:=nil; soy:=nil;
  ClearCurve;
end;

{----------------------------------------------}

procedure PlotApertures (ixy: integer);
var
  i, j: integer;
  ai, af, bi, bf: boolean;
  spos, sell, s1, s2, ap, apm, apmax: real;
  apercol, linecol: TColor;
begin
  if ixy mod 2 = 0 then begin
    linecol:=dimcol(clBlue, clBlack,0.5);
    apercol:=dimcol(clBlue, clWhite,0.1);
//    fsetfillstyle(bsSolid, dimcol(clBlue, clWhite,0.1));
    if ixy=0 then apmax:=-envelmaxx else apmax:=envelmaxx;
  end else begin
    linecol:=dimcol(clred , clBlack,0.5);
    apercol:=dimcol(clRed, clWhite,0.1);
//    fsetfillstyle(bsSolid, dimcol(clRed, clWhite,0.1));
    if ixy=1 then apmax:=-envelmaxy else apmax:=envelmaxy;
  end;
  with CurvePlot do begin
    spos:=0.0;
    apm:=0;
    for i:=1 to Glob.NLatt do begin
      j:=FindEl(i);
      sell:=spos+Ella[j].l;
      af := spos > sfin;
      ai := sell < sini;
      if ai or af then              // outside
      else begin
        bi:=spos  > sini;
        bf:=sell  < sfin;
        if bi then begin
          if bf then begin
            s1:=spos; s2:=sell;     // inside
          end else begin
            s1:=spos; s2:=sfin;     // exit
          end;
        end else begin
          if bf then begin
            s1:=sini; s2:=sell;     // enter
          end else begin
            s1:=sini; s2:=sfin;     // cover
          end;
        end;
        case ixy of
        0: ap:=-ella[j].ax;
        1: ap:=-ella[j].ay;
        2: ap:= ella[j].ax;
        3: ap:= ella[j].ay;
        end;
        if ella[j].cod = csept then begin
          case ixy of
          0: if ella[j].dis < 0 then ap:=ella[j].dis;
          1:;
          2: if ella[j].dis > 0 then ap:=ella[j].dis;
          end;
        end;
        if abs(ap) < abs(apmax) then begin
          vp.SetStyle(psClear);
          vp.Solid(s1,ap,s2,apmax, apercol);
          vp.SetStyle(psSolid);
          vp.SetColor(linecol);
          vp.Line(s1, ap, s2, ap);
        end;
        if bi then if (i>1) then begin //connect to previous element
          if abs(ap) < abs(apmax) then begin
            if abs(apm) < abs(apmax) then vp.line(s1, apm, s1, ap) else vp.line(s1, apmax, s1, ap);
          end else if abs(apm) < abs(apmax) then vp.line(s1,apm,s1,apmax);
        end;
      end;
      spos:=sell;
      apm:=ap; //index of previous element
    end; // for i
  end; // with
  vp.SetStyle(psSolid);
end;
{----------------------------------------------}
procedure PlotMag;
const
  nmp=4;
  BmagCol: array[1..nmp] of TColor=(b_col, q_col, s_col, oc_col);
var
  b: array[0..nmp] of array of double;
  bcomb: array of double;
  k, i, j, loop: integer;
  sell, s1, s2, bmin, bmax, brho, sini, sfin, spos, del, del2: double;
  ai, af, bi, bf: boolean;

  procedure ibar(x1,x2,y: double);
  begin
    with vp do begin
      moveto(x1,0); lineto(x1,y); lineto(x2,y); lineto(x2,0); stroke;
    end;
  end;

begin
  brho:=Glob.Energy*1e9/speed_of_light;
  for k:=0 to nmp do setlength(b[k],Glob.NElla);
  setlength(bcomb,Glob.NElla);
  for j:=0 to Glob.NElla-1 do begin
    for k:=0 to nmp do b[k,j]:=0; bcomb[j]:=0;
    with Ella[j+1] do begin
      if abs(l)>0 then begin
        case cod of
          cquad: b[2,j]:=brho*kq*env_rref;
          cbend: begin
                   b[1,j]:=brho*phi/l;
                   b[2,j]:=brho*kb*env_rref;
                 end;
          csole: b[4,j]:=2*brho*ks; //actually, is longitudinal field not By
          csext: b[3,j]:=brho*ms*sqr(env_rref);
          ccomb: begin
                   b[1,j]:=brho*cphi/l;
                   b[2,j]:=brho*ckq*env_rref;
                   b[3,j]:=brho*cms*sqr(env_rref);
                   // for the moment use only linear part
                   if ckq<>0 then begin
                     del:=abs(cphi/l/ckq)/env_rref; // =|B/B'|/r
                     del2:=sqr(del);
                     bcomb[j]:=brho*abs(ckq)*env_rref*sqrt(sqrt((8+20*del2-sqr(del2)+del*sqrt(powi(8+del2,3)))/8));
                   end else bcomb[j]:=0;
                 end;
          else;
        end;
      end else begin
        if cod=cmpol then if lmpol>0 then b[4,j]:=brho*bnl/lmpol*PowI(env_rref,nord-1);
      end;
    end;  //with
  end;

  if xautoscale then begin
    bmin:=1e10; bmax:=-1e10;
    for j:=0 to Glob.NElla-1 do begin
      for k:=1 to nmp do begin
        b[0,j]:=b[0,j]+abs(b[k,j]);
        if b[k,j] < bmin then bmin:=b[k,j];
      end;
      if b[0,j] > bmax then bmax:=b[0,j];
    end;
    bmin:=1.03*bmin; bmax:=1.03*bmax;
  end else begin
    bmin:=bfieldmin; bmax:=bfieldmax;
  end;
//  FClearViewPort(true, true, true, false);
  vp.ClearView(true, true, true, false,clWhite);
  vp.SetColor(clblack);
  vp.SetRangeY(bmin, bmax);

//  fAxPlot(bmin, bmax,0,1,7,2,clblack,'Magnetic field [T]');
  vp.Axis(2,clBlack,'Magnetic field [T]');
  vp.Line(CurvePlot.sini,0,CurvePlot.sfin,0);

  sini:=CurvePlot.sini;
  sfin:=CurvePlot.sfin;
  vp.SetStyle(psSolid);

//  FSetFillStyle(bsSolid,clSilver);
  for loop:=0 to 1 do begin
    spos:=0;
    for i:=1 to Glob.NLatt do begin
      j:=FindEl(i);
      sell:=spos+Ella[j].l;
      af := spos > sfin;    ai := sell < sini;
      if ai or af then              // outside
      else begin
        bi:=spos  > sini;      bf:=sell  < sfin;
        if bi then begin
          if bf then begin
            s1:=spos; s2:=sell;     // inside
          end else begin
            s1:=spos; s2:=sfin;     // exit
          end;
        end else begin
          if bf then begin
            s1:=sini; s2:=sell;     // enter
          end else begin
            s1:=sini; s2:=sfin;     // cover
          end;
        end;
        if loop=0 then begin
 //         fsetColor(clSilver); fbar(s1,0,s2,b[0,j-1]);
//          fsetColor(clPurple); ibar(s1,s2,bcomb[j-1]);
        end else begin
          for k:=1 to nmp do begin vp.SetColor(BmagCol[k]); ibar(s1,s2,b[k,j-1]); end;
        end;
      end;
      spos:=sell;
    end;
  end;
end;
{----------------------------------------------}

procedure FillBeamTab;
var
  i, c, jcu, ncu: integer;
begin
  InitBeamTab;

  if MomMode then ncu:=MaxMom else ncu:=1;
  tabhandle.ColCount:=ncu+2;

  for jcu:=0 to ncu-1 do begin
    i:=0;
    c:=jcu+2;
    with oBeam[jcu] do begin
      with tabhandle do begin
        if PerMode or SymMode then begin
          if persym then begin
            Cells[c,i]:='  ok  ';
          end else begin
            Cells[c,i]:='FAILED';
          end;
        end else Cells[c,i]:='';
        inc(i);
        if MomMode then  Cells[c,i]:=FtoS(dppset,5,2) else Cells[c,i]:=IntToStr(Glob.Nper);
        inc(i);Cells[c,i]:=FtoS(Circ,9,3);
        inc(i);Cells[c,i]:=FtoS(Angle,9,3);
        inc(i);Cells[c,i]:=FtoS(AbsAngle,9,3);
        inc(i);Cells[c,i]:=FtoS(Qa,9,5);
        inc(i);Cells[c,i]:=FtoS(Qb,9,5);
        inc(i);Cells[c,i]:=FtoS(Chromx,9,3);
        inc(i);Cells[c,i]:=FtoS(Chromy,9,3);
        inc(i);Cells[c,i]:=FtoS(alfa*1E3,9,3);
        inc(i);Cells[c,i]:=FtoS(Ja,9,5);
        inc(i);Cells[c,i]:=FtoS(Jb,9,5);
        inc(i);Cells[c,i]:=FtoS(Glob.Energy,9,3);
        inc(i);Cells[c,i]:=FtoS(Emita*1E9,9,3);
        inc(i);Cells[c,i]:=FtoS(Emitb*1E9,9,4);
        inc(i);Cells[c,i]:=FtoS(U0,9,1);
        inc(i);Cells[c,i]:=FtoS(sigmaE*1E3,9,3);
        inc(i);Cells[c,i]:=FtoS(1000*Ta,9,3);
        inc(i);Cells[c,i]:=FtoS(1000*Tb,9,3);
        inc(i);Cells[c,i]:=FtoS(1000*Te,9,3);
      end;
    end;
  end;
  AdjustBeamTab;
end;

procedure FillBetaTab (ilatpos:integer);
const
  tiny=1e-20;
var
  i, ie, c, jcu, ncu: integer;
  sloc: string;
  n2s, sign, sigma: matrix_5;
  emitx, emity, sigE2: real;

begin
  if ilatpos <=0 then begin
    ie:=0; sloc:='START'
  end else  if ilatpos >=Glob.NLatt then  begin
    ie:=Glob.NLatt; sloc:='END';
  end else begin
    ie:=ilatpos; sloc:=Ella[FindEl(ie)].nam;
  end;
  ibetamark:=ie;
  if OpticPlotMode=EnvPlot then begin
    n2s:=N2SfromOp(Opval[0,ie]);
    sign:=MatUni5;
    if UseEqEmi then begin
    //first round without sigmaE to calc the projected emittances (could be done more efficient...)
      if status.uncoupled then begin
        with oBeam[0] do begin
          EmitX:=  Emita/(1+env_erat*Jb/Ja); Emity:=env_erat*EmitX;
          sign[1,1]:= EmitX; sign[2,2]:=EmitX;  sign[3,3]:=EmitY; sign[4,4]:=EmitY; sign[5,5]:=0;
          sigE2:=sqr(sigmaE);
        end;
      end else begin
        with oBeam[0] do begin
          sign[1,1]:=Emita; sign[2,2]:=Emita; sign[3,3]:=Emitb; sign[4,4]:=Emitb; sign[5,5]:=0;
          sigE2:=sqr(sigmaE);
        end;
      end;
    end else begin
      //for manual input of emittances, take these for the normal modes
      sign[1,1]:=env_emix; sign[2,2]:=env_emix; sign[3,3]:=env_emiy; sign[4,4]:=env_emiy; sign[5,5]:=0;
      sigE2:=sqr(env_sdpp);
    end;
    sigma:=MatMul5(n2s, Matmul5(sign, MatTra5(n2s)));
    Emitx:=sqrt(MatDet2(MatCut52(sigma,1,1)));
    Emity:=sqrt(MatDet2(MatCut52(sigma,3,3)));
    sign[5,5]:=sigE2;
    sigma:=MatMul5(n2s, Matmul5(sign, MatTra5(n2s)));
//    printmat5(sigma);

    tabhandle.ColCount:=3;
    i:=ibetatab;  c:=2;
    with tabhandle do begin
      inc(i);Cells[c,i]:=sloc;
      inc(i);Cells[c,i]:=FtoS(Opval[0,ie].spos,9,3);
      inc(i);if sigma[1,1]>0 then Cells[c,i]:=FtoS(sqrt(sigma[1,1])*1e3,9,6) else Cells[c,i]:=' - '; //s(x) mm
      inc(i);if sigma[2,2]>0 then Cells[c,i]:=FtoS(sqrt(sigma[2,2])*1e3,9,6) else Cells[c,i]:=' - '; ; //s(x') mrad
      inc(i);if sigma[1,1]>tiny then Cells[c,i]:=FtoS(sigma[1,2]*1e6/sqrt(sigma[1,1]),9,6) else Cells[c,i]:=' - '; //(sx)' mrad);
      inc(i);if sigma[3,3]>0 then Cells[c,i]:=FtoS(sqrt(sigma[3,3])*1e3,9,6) else Cells[c,i]:=' - ';; //s(y) mm
      inc(i);if sigma[4,4]>0 then Cells[c,i]:=FtoS(sqrt(sigma[4,4])*1e3,9,6) else Cells[c,i]:=' - ';; //s(y') mrad
      inc(i);if sigma[3,3]>tiny then Cells[c,i]:=FtoS(sigma[3,4]*1e6/sqrt(sigma[3,3]),9,6) else Cells[c,i]:=' - '; //(sy)' mrad);
      inc(i);Cells[c,i]:=FtoS(degrad*(qarctan2(sigma[1,1]-sigma[3,3],2*sigma[1,3])/2),9,6); //theta (x,y) deg
      inc(i);Cells[c,i]:=FtoS(degrad*(qarctan2(sigma[2,2]-sigma[4,4],2*sigma[2,4])/2),9,6); //theta (x',y')  deg
      inc(i);Cells[c,i]:=FtoS(sigma[1,4]*1e6,9,6); // <xy'> mm mrad
      inc(i);Cells[c,i]:=FtoS(sigma[3,2]*1e6,9,6); // <yx'> mm mrad
      inc(i);Cells[c,i]:=FtoS(emitx*1e9,9,3); // nm
      inc(i);Cells[c,i]:=FtoS(emity*1e9,9,3); // nm
    end;
  end;

  if OpticPlotMode=BetPlot then begin
    if MomMode then ncu:=MaxMom else ncu:=1;
    tabhandle.ColCount:=ncu+2;
    for jcu:=0 to ncu-1 do begin
      i:=ibetatab;
      c:=jcu+2;
      with Opval[jcu,ie] do begin
        with tabhandle do begin
          inc(i);Cells[c,i]:=sloc;
          inc(i);Cells[c,i]:=FtoS(spos,9,3);
          inc(i);Cells[c,i]:=FtoS(beta,9,3);
          inc(i);Cells[c,i]:=FtoS(alfa,9,4);
          inc(i);Cells[c,i]:=FtoS(betb,9,3);
          inc(i);Cells[c,i]:=FtoS(alfb,9,4);
          inc(i);Cells[c,i]:=FtoS(disx,9,4);
          inc(i);Cells[c,i]:=FtoS(dipx,9,4);
          inc(i);Cells[c,i]:=FtoS(disy,9,4);
          inc(i);Cells[c,i]:=FtoS(dipy,9,4);
          inc(i);Cells[c,i]:=FtoS(phia,9,4);
          inc(i);Cells[c,i]:=FtoS(phib,9,4);
//        inc(i);Cells[c,i]:=FtoS(betx*dipx*dipx+2*alfx*disx*dipx+(1+alfx*alfx)/betx*disx*disx,9,6);
          inc(i);Cells[c,i]:='(to do)';
          inc(i);Cells[c,i]:=FtoS(orb[1]*1000,9,4);
          inc(i);Cells[c,i]:=FtoS(orb[2]*1000,9,4);
        end;
      end;
    end;
  end;
end;



procedure InitBeamTab;
var i: integer;
begin
  i:=0;
  with tabhandle do begin
    RowCount:=20;
    if PerMode then begin
      Cells[0,i]:='periodic';
    end else if SymMode  then begin
      Cells[0,i]:='symmetric';
    end else Cells[0,i]:='forward';
    inc(i);
    if MomMode then begin
      Cells[0,i]:='dp/p'; Cells[1,i]:='[%]'
    end else begin
      Cells[0,i]:='Periods'; Cells[1,i]:='';
    end;
                                                         tabrowCol[i]:=4;
    inc(i); Cells[0,i]:='Length'; Cells[1,i]:='[m]';     tabRowCol[i]:=0;
    inc(i); Cells[0,i]:='Angle'; Cells[1,i]:='[deg]';    tabRowCol[i]:=0;
    inc(i); Cells[0,i]:='AbsAngle'; Cells[1,i]:='[deg]'; tabRowCol[i]:=0;
    inc(i); Cells[0,i]:='TuneA'; Cells[1,i]:='';         tabRowCol[i]:=1;
    inc(i); Cells[0,i]:='TuneB'; Cells[1,i]:='';         tabRowCol[i]:=2;
    inc(i); Cells[0,i]:='ChromA'; Cells[1,i]:='';        tabRowCol[i]:=1;
    inc(i); Cells[0,i]:='ChromB'; Cells[1,i]:='';        tabRowCol[i]:=2;
    inc(i); Cells[0,i]:='Alpha'; Cells[1,i]:='[xE-3]';   tabRowCol[i]:=0;
    inc(i); Cells[0,i]:='JA'; Cells[1,i]:='';            tabRowCol[i]:=1;
    inc(i); Cells[0,i]:='JB'; Cells[1,i]:='';            tabRowCol[i]:=2;
    inc(i); Cells[0,i]:='Energy'; Cells[1,i]:='[GeV]';   tabRowCol[i]:=0;
    inc(i); Cells[0,i]:='EmitA'; Cells[1,i]:='[nm rd]'; tabRowCol[i]:=1;
    inc(i); Cells[0,i]:='EmitB'; Cells[1,i]:='[nm rd]'; tabRowCol[i]:=2;
    inc(i); Cells[0,i]:='dE/turn'; Cells[1,i]:='[keV]';  tabRowCol[i]:=0;
    inc(i); Cells[0,i]:='Espread'; Cells[1,i]:='[xE-3]'; tabRowCol[i]:=3;
    inc(i); Cells[0,i]:='TauA'; Cells[1,i]:='[ms]';      tabRowCol[i]:=1;
    inc(i); Cells[0,i]:='TauB'; Cells[1,i]:='[ms]';      tabRowCol[i]:=2;
    inc(i); Cells[0,i]:='TauE'; Cells[1,i]:='[ms]';      tabRowCol[i]:=3;
    ibetatab:=i;
    InitBetaTab;
  end;
end;

procedure InitBetaTab;
var
  i: integer;
begin
  i:=ibetatab;
  with tabhandle do begin
    RowCount:=ibetatab+16;
    inc(i); Cells[0,i]:='Location'; Cells[1,i]:='';      tabRowCol[i]:=0;
    inc(i); Cells[0,i]:='Position'; Cells[1,i]:='m';     tabRowCol[i]:=0;
    if OpticPlotMode=BetPlot then begin
      inc(i); Cells[0,i]:='BetaA'; Cells[1,i]:='m';        tabRowCol[i]:=1;
      inc(i); Cells[0,i]:='AlphaA'; Cells[1,i]:='';        tabRowCol[i]:=1;
      inc(i); Cells[0,i]:='BetaB'; Cells[1,i]:='m';        tabRowCol[i]:=2;
      inc(i); Cells[0,i]:='AlphaB'; Cells[1,i]:='';        tabRowCol[i]:=2;
      inc(i); Cells[0,i]:='Disp X'; Cells[1,i]:='m';       tabRowCol[i]:=3;
      inc(i); Cells[0,i]:='Disp'' X'; Cells[1,i]:='rad';   tabRowCol[i]:=3;
      inc(i); Cells[0,i]:='Disp Y.'; Cells[1,i]:='m';      tabRowCol[i]:=5;
      inc(i); Cells[0,i]:='Disp'' Y'; Cells[1,i]:='rad';   tabRowCol[i]:=5;
      inc(i); Cells[0,i]:='PhiA/2pi'; Cells[1,i]:='';      tabRowCol[i]:=1;
      inc(i); Cells[0,i]:='PhiB/2pi'; Cells[1,i]:='';      tabRowCol[i]:=2;
      inc(i); Cells[0,i]:='curly H'; Cells[1,i]:='m';      tabRowCol[i]:=3;
      inc(i); Cells[0,i]:='Orbit X'; Cells[1,i]:='mm';     tabRowCol[i]:=1;
      inc(i); Cells[0,i]:='Orbit X'''; Cells[1,i]:='mrad';     tabRowCol[i]:=1;
    end;
    if OpticPlotMode=EnvPlot then begin
      inc(i); Cells[0,i]:='SigX';     Cells[1,i]:='mm';        tabRowCol[i]:=1;
      inc(i); Cells[0,i]:='SigX''';   Cells[1,i]:='mrad';        tabRowCol[i]:=1;
      inc(i); Cells[0,i]:='(SigX)'''; Cells[1,i]:='mrad';        tabRowCol[i]:=1;
      inc(i); Cells[0,i]:='SigY';     Cells[1,i]:='mm';        tabRowCol[i]:=2;
      inc(i); Cells[0,i]:='SigY''';   Cells[1,i]:='mrad';        tabRowCol[i]:=2;
      inc(i); Cells[0,i]:='(SigY)'''; Cells[1,i]:='mrad';        tabRowCol[i]:=2;
      inc(i); Cells[0,i]:='TiltXY'; Cells[1,i]:='deg';      tabRowCol[i]:=5;
      inc(i); Cells[0,i]:='TiltX''Y'''; Cells[1,i]:='deg';   tabRowCol[i]:=5;
      inc(i); Cells[0,i]:='<XY''>'; Cells[1,i]:='um';      tabRowCol[i]:=4;
      inc(i); Cells[0,i]:='<YX''>'; Cells[1,i]:='um';      tabRowCol[i]:=4;
      inc(i); Cells[0,i]:='EmitX'; Cells[1,i]:='nm';     tabRowCol[i]:=1;
      inc(i); Cells[0,i]:='EmitY'; Cells[1,i]:='nm';     tabRowCol[i]:=1;
      inc(i); Cells[0,i]:=''; Cells[1,i]:='';     tabRowCol[i]:=1;
    end;
  end;
  AdjustBeamTab;
end;

procedure AdjustBeamTab;
const
  minwid=10; dx=10;
var
  i, c, max, tmp: integer;
begin
  with tabhandle do begin
    for c:=0 to ColCount-1 do begin
      max:=0;
      for i:=0 to RowCount-1 do begin
        tmp:=canvas.textwidth(Cells[c,i]);
        if tmp>max then max:=tmp;
      end;
      if max > minwid then ColWidths[c]:=max + GridLineWidth+dx;
    end;
  end;
end;

{-------------------------------------------------------------------------}

procedure ShowTuneDiagram;
var
  i: integer;
begin
  with oBeam[0] do begin
    if persym then TunePlotHandle.Diagram(Qx,Qy) else TunePlotHandle.Close;
    if persym then TunePlotHandle.AddTunePoint (Qa, Qb, 1, 2, false)
  end;
  if (oBeam[0].persym and MomMode) then for i:=1 to MaxMom-1 do begin
    with oBeam[i] do if persym then TunePlotHandle.AddTunePoint (Qx, Qy, dppset, abs(dppset), true)
  end;
end;

{-------------------------------------------------------------------------}

procedure ClosedOrbit (VAR fail: Boolean; latmode: shortint; dpp: real);
{latmode do_misal  includes corrector magnets as-280709/130710}

{Newton-Raphson root finder, based upon Numerical Recipes, sect. 9.4:
 To solve: F(X)=0.  Root finding step:   X := X-dX with dX=F/F'
 Here: F(X) =Transfer(X)-X=(R-ME)*X  (R=TransferMatrix, ME=UnitMatrix)
       F'(X)=(R-ME) Root finding step:   X: = X-dX with dX=Inv(R-ME)*F(X)
       thanks to j.bengtsson, as 220196}

const eps   = 1E-12;
//?      errmax= 1000.0;   {= 1km - to prevent Orbit explosion}
      itmax = 50;
//      nv    = 4;

var   A            : matrix_4;
      x0, x, dx, f : vektor_4;
      k, i, it     : integer;
      j            : word;
      mfail        : boolean;
//testmat: matrix_4;

begin
  fail:=false;
  beamLost:=False;  mfail:=false; j:=0;
  for i:=1 to 4 do dx[i]:=0;
  for k:=1 to 4 do x[k]:=Glob.Op0.orb[k];
//writeln(diagfil, 'CO init : ', x[1], x[2], x[3], x[4]);
  it:=0;
  repeat
    inc(it);
    OptInit;        {initializes transfermatrix etc., also o'writes Orbit1,2}
    Orbit1:=x; Orbit2:=Orbit1;        {overwrites this setting}
    x0:=Orbit1;
    i:=0;
    repeat
      Inc(i);
      Lattel(i, j, latmode, dpp);
    until (i=Glob.NLatt) or BeamLost;
//if beamlost then writeln(diagfil,'CO beam lost!');
    x :=Orbit2;
    f:=VecSub4(x, x0);        {f:=x-x0}
    A:=MatCut54(TransferMatrix);                    {A=4x4 matrix, ignore Dispersion}
//writeln(diagfil,'closed orbit iteration ',it);
//printmat5(transfermatrix0);
    for i:=1 to 4 do A[i,i]:=A[i,i]-1.0;
//    testmat:=a;
    A:=MatInv4(A, mfail);
//    testmat:=matmul4(A,testmat); printmat4(testmat); // inversion ok, residues <1e-16
    fail :=BeamLost or mfail;
    dx:=LinTra4(A, f);
    x:=VecSub4 (x0, dx);
    fail:=fail or (it=itmax);
//writeln(diagfil, 'CO it=',it:2,' : ', x[1], x[2], x[3], x[4], vecabs4(dx));
  until (VecAbs4(dx) < eps) or fail;
  if not fail then begin
    for k:=1 to 4 do Glob.Op0.orb[k]:=x[k];
    Glob.OpE.orb:=Glob.Op0.orb;
    for k:=1 to 4 do Orbit0[k]:=x[k];
    OrbitE:=Orbit0;
  end else begin
//writeln(diagfil,'C.O. failed. dpp =', dpp:14:9);
  end;
//writeln(diagfil, 'CO exit: dpp =',dpp:14:9, ' X orb 0 =',glob.op0.orb[1]*1000:14:9);
end;

{---------------------------------------------------------}
procedure FlatPeriodic(var FFlag : Boolean);

// old routine: periodic solution for uncoupled lattice

var
  a, b, betax, alfax, betay, alfay, eta, etap: double;

begin
  FFlag:=false;
  a:=2-sqr(TransferMatrix[1,1])-sqr(TransferMatrix[2,2])-2*TransferMatrix[2,1]*TransferMatrix[1,2]; //sin^2 Q
  b:=2-sqr(TransferMatrix[3,3])-sqr(TransferMatrix[4,4])-2*TransferMatrix[4,3]*TransferMatrix[3,4];
  if (a>0) and (TransferMatrix[1,2]<>0) then begin
    betax:=2*Abs(TransferMatrix[1,2])/Sqrt(a);
    alfax:=(TransferMatrix[1,1]-TransferMatrix[2,2])*betax/2/TransferMatrix[1,2];
  end else FFlag:=true;
  if (b>0) and (TransferMatrix[3,4]<>0) then begin
    betay:=2*Abs(TransferMatrix[3,4])/Sqrt(b);
    alfay:=(TransferMatrix[3,3]-TransferMatrix[4,4])*betay/2/TransferMatrix[3,4];
  end else FFlag:=true;

  AMat0:=MatCut52(Transfermatrix,1,1);
  BMat0:=MatCut52(Transfermatrix,3,3);


// only horiz disp in flat lattice
  a:=(2.0-TransferMatrix[1,1]-TransferMatrix[2,2]);
  b:=(1.0-TransferMatrix[1,1]);
  if a*b <>0 then begin
    etap:=(TransferMatrix[2,1]*TransferMatrix[1,5]+TransferMatrix[2,5]*(1.0-TransferMatrix[1,1]))/a;
    eta :=(TransferMatrix[1,2]*etap+TransferMatrix[1,5])/b;
  end
// correct, but complicated: eta:=[(1-T22)*T15+T12*T25]/a
  else FFlag:=true;

  if not FFlag then begin
    SigNa0:=MatSet2(betax, -alfax, -alfax, (1+sqr(alfax))/betax);
    SigNb0:=MatSet2(betay, -alfay, -alfay, (1+sqr(alfay))/betay);
    Disper0[1]:=eta; Disper0[2]:=etap;  Disper0[3]:=0; Disper0[4]:=0;

    with Glob.Op0 do begin
      beta:=betax; alfa:=alfax; betb:=betay; alfb:=alfay;
      cmat:=MatNul2;
      disx:=eta;      dipx:=etap;      disy:=0;      dipy:=0;
      am:=Amat0; bm:= Bmat0
    end;
  end;
  CoupMatrix0:=MatNul2;
//  writeln(diagfil, 'flatperiodic transfermatrix:');
//  printmat5(Transfermatrix);

end;

{------------------------------------------------------------------}


procedure NormalMode (var fail: boolean);
{ normal mode transformation following Sagan & Rubin, PRSTAB 2, 074001 (1999)
  reads :  Transfermatrix 5x5
  writes: NormMatrix 4x4 blockdiagonal
          BetaNorm0 4x4 blockdiagonal betas local
          CoupMatrix 2x2  coupling matrix
          CoupAngle       coupling angle; gamma=Cos(coupAngle)
}

const
  zero=1e-20; // avoid crash for almost zero values of |H| in uncoupled case
  nmdiag=3; nmdiag1=2;
var
  mm, n, m, nn, cc, hh, ccp, aa, bb, cc2, ccp2, aa2, bb2: matrix_2;
  trmn, gamma, den, hhdet, gamma2, tmp: double;
  sgn: integer;
  tt, dd, ddinv, {uu,} vvinv: matrix_4;
  dpern, dprod, dper: vektor_4;
  i: integer;
  dispfail, normfail: boolean;
  fractunea, fractuneb, betaa, betab, alfaa, alfab: double;
  fractunea2, fractuneb2, betaa2, betab2, alfaa2, alfab2: double;

  Function GetBAT (m: Matrix_2; var be, al, tu: double): boolean;
// only for periodic structure
// get beta, alfa, tune from 2x2 matrix; return true if failed
  var
    co, si: double;
  begin
    co:=MatTra2(m)/2;
    if abs(co) < 1 then begin
      tu:=ArcCos(co)/2/Pi;
      si:=sqrt(1-sqr(co));
      if m[1,2]<0 then begin
        si:=-si;
        tu:=-tu;
      end;
      be:=m[1,2]/si;
      al:=(m[1,1]-m[2,2])/2/si;
//      tu:=arcsin(si)/2/Pi;
      GetBat:=false;
    end else begin
      be:=1.0; al:=0.0; tu:=0.0;
      GetBAT:=true;
    end;
  end;



begin

  //+ comment: valid stuff, temp disabled to keep overview...
  normfail:=false;
  dispfail:=false;

  MatMV54(TransferMatrix,tt,dprod);
  mm:=MatCut42(tt,1,1);
  m :=MatCut42(tt,1,3);
  n :=MatCut42(tt,3,1);
  nn:=MatCut42(tt,3,3);

  opalog(-3, 'Determinants of sub-matrices M, N and m, n:|>'+
    ftos(matdet2(mm),10,6)+' '+ftos(matdet2(nn),10,6)+' '+ftos(matdet2(m),10,6)+' '+ftos(matdet2(n),10,6));

  trmn:=MatTra2( MatSub2(mm,nn));
  hh:=MatAdd2(m, MatSyc2(n));
  hhdet:=MatDet2(hh);
  den:=sqr(trmn)+4*hhdet;

  if den>zero then begin // has to exist otherwise no per solution
    den:=sqrt(den);
    gamma:=sqrt(0.5+0.5*abs(trmn)/den);
    if trmn >= 0 then sgn:=1 else sgn:=-1;
    cc:=MatSca2( -sgn/(gamma*den), hh);
    if abs(gamma-1) < 1e-12 then cc:=MatNul2; // set to zero to avoid round-off problems in uncoupled case

    ccp:=MatSyc2(cc);
{    if diag(nmdiag) then begin
      writeln(diagfil,'Transfer Matrix');
      printmat5(TransferMatrix);
      writeln(diagfil, '|H|, Tr(M-N), Tr(M-N)^2+4|H| : ', hhdet, trmn, den); writeln(diagfil);
      writeln(diagfil, 'gamma, angle: ', gamma, 0.5*arccos(gamma));
    end;
}

    if hhdet>zero then begin // only then 2nd sol exists
      gamma2:=sqrt(0.5-0.5*abs(trmn)/den);
{      if diag(nmdiag) then begin
        writeln(diagfil);
        writeln(diagfil,'second solution: ');
        writeln(diagfil, 'gamma2, angle: ', gamma2, 0.5*arccos(gamma2));
        writeln(diagfil);
      end;
}

//        if gamma2 < gamma then begin // choose smaller gamma as principal mode
      if ExchangeModes then begin
//writeln(diagfil,'exchanged solutions', gamma, gamma2);
        tmp:=gamma;  gamma:=gamma2; gamma2:=tmp;
        cc2 :=cc;
        ccp2:=ccp;
        cc  :=MatSca2(sgn/(gamma *den),hh);
        ccp :=MatSyc2(cc );
      end else begin
        cc2 :=MatSca2(sgn/(gamma2*den),hh);
        ccp2:=MatSyc2(cc2);
      end;

    end else gamma2:=0;



    vvinv:=MatCmp24( MatSca2(gamma,MatUni2),MatSca2(-1,cc), ccp, MatSca2(gamma,MatUni2));
//    vv   :=MatCmp24( MatSca2(gamma,MatUni2),cc, MatSca2(-1,ccp), MatSca2(gamma,MatUni2));

//    if diag(nmdiag) then begin
//      writeln(diagfil, 'VV-1 transformation matrix'); printmat4(vvinv);
//    end;

//  A=gamma^2 M - gamma*(C n + m C+) + C N C+
    aa:=MatAdd2(   MatSub2(   MatSca2(sqr(gamma),mm),  MatSca2(gamma,MatAdd2( MatMul2(cc,n), MatMul2(m, ccp)))),    MatMul2(cc , MatMul2(nn,ccp)));
    bb:=MatAdd2(   MatAdd2(   MatSca2(sqr(gamma),nn),  MatSca2(gamma,MatAdd2( MatMul2(n,cc), MatMul2(ccp, m)))),    matMul2(ccp, MatMul2(mm,cc )));
//+    uu:=MatCmp24 (aa, MatNul2, MatNul2, bb);

{ get normal mode beta functions}

    Amat0:=aa;
    Bmat0:=bb;

    fractunea:=0; fractuneb:=0;
    normfail:=normfail or GetBAT (aa, betaa, alfaa, fractunea);
    normfail:=normfail or GetBAT (bb, betab, alfab, fractuneb);

    //    writeln(diagfil,'NM tunes a/b, g, |C| ', fractunea:10:5,fractuneb:10:5, gamma:10:5, (1-sqr(gamma)):10:5);
//circle transformations --> normalize normalmode and coupling matrices:
{+
    sq:=sqrt(betaa);    ggainv := MatSet2(sq, 0, -alfaa/sq, 1/sq);
    sq:=sqrt(betab);    ggbinv := MatSet2(sq, 0, -alfab/sq, 1/sq);
    gginv:=MatCmp24 (ggainv, MatNul2, MatNul2, ggbinv);
}

{   aa:=MatMul2(gga,MatMul2(aa,MatSyc2(gga)));
    bb:=MatMul2(ggb,MatMul2(bb,MatSyc2(ggb)));
    uu:=MatCmp24 (aa, MatNul2, MatNul2, bb);
    writeln(diagfil, 'test for normalized normalmode matrix UU: from gg matrix:');
    printmat4(uu);
                --> cheaper this way:
}
{+
   uubar:=MatCmp24 (MatSet2(ca, sa, -sa, ca), MatNul2, MatNul2, MatSet2(cb, sb, -sb, cb));
   ccbar:=MatMul2(gga,MatMul2(cc,MatSyc2(ggb)));

    if diag then begin
      writeln(diagfil);
      writeln(diagfil, 'test for normalized normalmode matrix UUbar:');
      printmat4(uubar);
      writeln(diagfil, 'test gamma = sqrt(1- |C|) :', gamma, ' = ', sqrt(1-MatDet2(cc)));
    end;
}

//+    NormMatrix0:=uu;

{+
    BetaNorm0 :=MatCmp24(MatSet2(betaa, -alfaa, -alfaa, (1+sqr(alfaa))/betaa), MatNul2,
                MatNul2, MatSet2(betab, -alfab, -alfab, (1+sqr(alfab))/betab));
+}

    if not normfail then begin
      CoupMatrix0:= cc;
//      CoupGamma0 := gamma; // redundant since given by cc, but faster for propagation
      SigNa0:=MatSet2(betaa, -alfaa, -alfaa, (1+sqr(alfaa))/betaa);
      SigNb0:=MatSet2(betab, -alfab, -alfab, (1+sqr(alfab))/betab);
      with Glob.Op0 do begin
        beta:=betaa; alfa:=alfaa; betb:=betab; alfb:=alfab;
        cmat:=cc; am:=Amat0; bm:=Bmat0;
        OPALog(-nmdiag1,'normal mode start tunes and gamma:|>'+ftos(fractunea,10,5)+' '+ ftos(fractuneb,10,5)+' '+ftos(gamma,10,5));
        OPALog(-nmdiag1,'beta/b, alfa/b: '+ftos(beta,10,4)+' '+ftos(betb,10,4)+' '+ftos(alfa,10,4)+' '+ftos(alfb,10,4));
        OPALog(-nmdiag1,'coup  matrix  : '+ftos(cmat[1,1],10,4)+' '+ftos(cmat[1,2],10,4)+' '+ftos(cmat[2,1],10,4)+' '+ftos(cmat[2,2],10,4));
      end;
      FractionalTuneA:=fractunea;
      FractionalTuneB:=fractuneb;
      if hhdet>zero then begin
        aa2:=MatAdd2(   MatSub2(   MatSca2(sqr(gamma2),mm),  MatSca2(gamma2,MatAdd2( MatMul2(cc2,n), MatMul2(m, ccp2)))),    MatMul2(cc2 , MatMul2(nn,ccp2)));
        bb2:=MatAdd2(   MatAdd2(   MatSca2(sqr(gamma2),nn),  MatSca2(gamma2,MatAdd2( MatMul2(n,cc2), MatMul2(ccp2, m)))),    matMul2(ccp2, MatMul2(mm,cc2 )));
        CoupMatrix0_flip:= cc2;
        GetBAT (aa2, betaa2, alfaa2, fractunea2);
        GetBAT (bb2, betab2, alfab2, fractuneb2);
        FractionalTuneA2:=fractunea2;
        FractionalTuneB2:=fractuneb2;
        SigNa0_flip:=MatSet2(betaa2, -alfaa2, -alfaa2, (1+sqr(alfaa2))/betaa2);
        SigNb0_flip:=MatSet2(betab2, -alfab2, -alfab2, (1+sqr(alfab2))/betab2);
        OPALog(-nmdiag1,'flipped solution  tunes and gamma:|>'+ ftos(fractunea2,10,5)+' '+ ftos(fractuneb2,10,5)+' '+ftos(gamma2,10,5));
        OPALog(-nmdiag1,'beta/b, alfa/b: '+ftos(betaa2,10,4)+' '+ftos(betab2,10,4)+' '+ftos(alfaa2,10,4)+' '+ftos(alfab2,10,4));
        OPALog(-nmdiag1,'coup  matrix  : '+ftos(cc2[1,1],10,4)+' '+ftos(cc2[1,2],10,4)+' '+ftos(cc2[2,1],10,4)+' '+ftos(cc2[2,2],10,4));

      end else begin
        CoupMatrix0_flip:=MatNul2;
        SigNa0_flip:=MatNul2;
        SigNb0_flip:=MatNul2;
        FractionalTuneA2:=0;
        FractionalTuneB2:=0;
        OPALog(-nmdiag1,'flipped solution does not exist.');
      end;

    end;
  end else normfail:=true; // tr(mm-nn)^2+4|hh| > 0
  if normfail then begin // set some values to avoid crash
    CoupMatrix0:=MatNul2;
    SigNa0:=MatUni2; SigNb0:=MatUni2;
  end;


  {get periodic dispersion: Dper = tt * Dper + dprod --> Dper = (I-tt)^-1 * dprod
  }

  dd:=MatSub4(MatUni4,tt);
  ddinv:=Matinv4(dd, dispfail);

{    if dispfail then writeln(diagfil, 'Inversion DD failed') else begin
      writeln(diagfil,'inverse DD matrix:');
      printmat4(ddinv);
      writeln(diagfil, 'test on inverse');
      printmat4(matmul4(ddinv, dd));
    end;
}

  if not dispfail then begin
    dper:=LinTra4(ddinv, dprod);
{    if diag(nmdiag) then begin
      writeln(diagfil, 'periodic dispersion:');
      for i:=1 to 4 do write(diagfil, dper[i]); writeln(diagfil);
    end;
}
    with Glob.Op0 do begin
      disx:=dper[1];      dipx:=dper[2];      disy:=dper[3];      dipy:=dper[4];
    end;



    for i:=1 to 4 do Disper0[i]:=dper[i];
//transformation of dispersion to normal mode system: (not used, done locally later as needed)
    if not normfail then begin
      dpern:=LinTra4(vvinv, dper);
      with Glob.Op0 do begin
//        disa:=dpern[1];      dipa:=dpern[2];      disb:=dpern[3];      dipb:=dpern[4];

      end;
{      if diag(nmdiag) then begin
        writeln(diagfil, 'normal mode dispersion:');
        for i:=1 to 4 do write(diagfil, dpern[i]); writeln(diagfil);
      end;
}
    end;
  end;
  fail:=normfail or dispfail;

  {now in OptInit <--
   if not fail then begin
// create a matrix to transform emittances in sigma matrix
    Norm2Sigma:=matcpy45(matmul4(vv,gginv));
    for i:=1 to 4 do Norm2Sigma[i,5]:=dper[i];
  end;}

end;

{---------------------------------------------------------}

procedure Periodic(var FFlag : Boolean);
begin
  if status.Uncoupled then FlatPeriodic(fflag) else NormalMode(fflag);
  if not FFlag then Glob.OpE:=Glob.Op0;
  status.periodic:=not FFlag;
  if FFlag then setStatusLabel(stlab_per,status_failure) else setStatusLabel(stlab_per,status_success);
end;

{---------------------------------------------------------------}

procedure Symmetric (var FFlag : Boolean);

var      a, b, betax0, betaxE, betay0, betayE, eta0, etaE : double;

begin
{ works only for flat lattice, to be disabled in case of coupling - not important,
rarely used anyway as-12.2.18}
  if status.Uncoupled then begin
    FFlag:=false;
    a:=TransferMatrix[1,1]*TransferMatrix[2,1]; b:=TransferMatrix[3,3]*TransferMatrix[4,3];
    if (a=0) or (b=0) then FFlag:=true;
    if not FFlag then begin
      a:=-TransferMatrix[2,2]*TransferMatrix[1,2]/a;
      b:=-TransferMatrix[4,4]*TransferMatrix[3,4]/b;
      if (a>0) and (TransferMatrix[2,2]<>0) then  begin
        betax0:=Sqrt(a);
        betaxE:=betax0*TransferMatrix[1,1]/TransferMatrix[2,2];
      end
      else FFlag:=true;
      if (b>0) and (TransferMatrix[4,4]<>0) then begin
        betay0:=Sqrt(b);
        betayE:=betay0*TransferMatrix[3,3]/TransferMatrix[4,4];
      end
      else FFlag:=true;
      eta0:=-TransferMatrix[2,5]/TransferMatrix[2,1];
      etaE:= eta0*TransferMatrix[1,1]+TransferMatrix[1,5];
    end;
    SigNa0:=MatSet2(betax0, 0, 0, 1/betax0);
    SigNb0:=MatSet2(betay0, 0, 0, 1/betay0);
    Disper0:=VecNul4; Disper0[1]:=eta0;
    with Glob.Op0 do begin
      beta:=betax0; alfa:=0; betb:=betay0; alfb:=0;
      cmat:=MatNul2;
      disx:=eta0;      dipx:=0;      disy:=0;      dipy:=0;
    end;
    with Glob.OpE do begin
      beta:=betaxE; alfa:=0; betb:=betayE; alfb:=0;
      cmat:=MatNul2;
      disx:=etaE;      dipx:=0;      disy:=0;      dipy:=0;
    end;
    status.symmetric:=not FFlag;
    CoupMatrix0:=MatNul2;
  end;
  if FFlag then setStatusLabel(stlab_per,status_failure) else setStatusLabel(stlab_per,status_success);
end;

{------------------------------------------------------------------}

procedure OpticReCalc;
begin
  OpticCalc(ilaststart);
end;

procedure OrbitReCalc;
begin
  OrbitCalc(ilaststart);
end;

procedure OrbitCalc(istart:integer);
var
         i, j, jcu, jom: Word;
         iistart, iturns, nturns: integer;
         FailFlag: Boolean;
         dPP: real;
         latmode:shortint;

begin

//*  status.betas:=false;

//beta status get's lost in orbit calc, because orbit may be coupled,
//but betas are only defined without coupling.

//* no longer true, therefore keep betas ?

  ilaststart:=istart;
  if istart < 0 then begin //cheap trick to enable multi-turn and restrict this to calc from 0
    nturns:=-istart;
    iistart:=0;
  end else begin
    iistart:=istart;
    nturns:=1;
  end;

  allocOpval;


//  OffMom    :=Glob.dpp<>0;

  latmode:=do_misal;

  MaxMom:=1;

//  if OffMom then dPact:=dPmult else dPact:= 0;
//  dPP:=dPact*0.01;
//  Glob.dpp:=dpp;

  if dppmode then dpp:=Glob.dpp else dpp:=0;

  FailFlag:=false;
  BeamLost:=false;
  status.perOrbit :=false;
  status.periodic :=false;
  status.symmetric:=false;
  if PerMode or SymMode then begin
// as initial guess use dispersive orbit in case dpp<>0
    if dpp<>0.0 then begin
      with Glob.Op0 do  for i:=1 to 4 do orb[i]:=Eta_ref[i]*dpp;
      Glob.dpp:=dpp;
    end else begin
      for i:=1 to 4 do Glob.Op0.orb[i]:=0.0;
//*      Glob.dpp:=0.0;
    end;
// use the linear solution as starting value
    if UseSext then begin
      UseSext:=false;
      ClosedOrbit(FailFlag, latmode, dpp);
      if FailFlag then Beep;
      UseSext:=True;
    end;
    ClosedOrbit(FailFlag, latmode, dpp);
    if FailFlag then  Beep;
    status.PerOrbit:= not Failflag;
   if FailFlag then setStatusLabel(stlab_orb,status_failure) else setStatusLabel(stlab_orb,status_success);
  end else setStatusLabel(stlab_orb,status_forward);

//  with Glob.Op0 do writeln(diagfil,'after c.o.',' ',orb[1], orb[3]);


  latmode:=do_misal+do_lpath;
  OptInit;
  jcu:=0;
  if iistart>0 then begin {backwards from istart to begin of lattice}
    Inival(iistart, goBackward, jom);
    Stovar(jcu,istart);
    for i:=iistart downto 1 do begin
      Lattice[i].inv:=-Lattice[i].inv;
      Lattel (i, j, latmode, dpp);
      Lattice[i].inv:=-Lattice[i].inv;
      StoVar(jcu,i-1);
    end;

    for i:=0 to iistart do begin
      with opval[jcu,i] do begin
        orb[2]:=-orb[2]; orb[4]:=-orb[4];
        spos:=SPosition-spos;
        path:=PathDiff-path;
      end;
    end;
    Glob.Op0.orb[1]  := Orbit2[1];   Glob.Op0.orb[2]  :=-Orbit2[2];
    Glob.Op0.orb[3]  := Orbit2[3];   Glob.Op0.orb[4]  :=-Orbit2[4];
  end;



  if iistart<Glob.NLatt then begin {forward from istart to end of lattice}
    IniVal(iistart, goForward, jom);
    TimeOfFlight:=0;
    for iturns:=1 to nturns do begin
      jcu:=iturns-1;
      Sposition:=0;
      StoVar(jcu,iistart);
      for i:=iistart+1 to Glob.NLatt do begin
        Lattel (i, j, latmode, dpp);
        StoVar(jcu,i);
      end;
      Orbit0:=Orbit2; Orbit1:=Orbit2; //only for multiturn mode, in all other cases Inival will reset Orbit0
    end;
    Glob.OpE.orb[1]  := Orbit2[1];   Glob.OpE.orb[2]  := Orbit2[2];
    Glob.OpE.orb[3]  := Orbit2[3];   Glob.OpE.orb[4]  := Orbit2[4];
  end;
  COCorrstatus:=0;

end;

procedure OpticCalc(istart: integer);
{OptikEntwurf; Programm zur graphischen Optikentwicklung }


{ -> to lazarus 2016...}
{ -> to delphi Sep-04 as}
{ completely tidied up jan-96 as}

var
         i: Word;
         FailFlag: Boolean;
{Momentum-Mode:          as 210492
shifted to optictart, opticmom removed again, as-18.11.2021}
         dPP: real;
         CountMom: Integer;
         latmode: shortint;

begin
  ilaststart:=istart;

//  OffMom    :=Glob.dpp<>0;

  latmode:= do_twiss+do_chrom+do_radin+do_misal; //include misal

  if dppmode and MomMode then begin
    MaxMom:=3;
    ncurves:=1;
  end else begin
    MaxMom:=1;
    inc(ncurves);
    if ncurves > ncurvesmax then ncurves:=ncurvesmax;
  end;

  tabhandle.ColCount:=MaxMom+2;

{*** why that.... Op0 was set by startsel, don't overwrite!
    BetaToOp(Beta_ref,Glob.Op0);
    DispToOp(Eta_ref,Glob.Op0);
    OrbToOp (Orbi_ref, Glob.Op0);
}


{ begin CountMom................}

    FOR CountMom:=1 to MaxMom do begin

      case CountMom of
//      1:begin if OffMom then dPact:=dPmult else dPact:= 0; end;

// 1 means either only 1 curve - or 1st of 3, then MomMode=true
// if have only 1 curve in dppmode, we set dpact to dpumlt, else dpact=0
        1:begin
            if dppmode then begin
              if MomMode then dPact:=0 else dpact:=dPmult;
            end else dPact:=0;
          end;
        2:dPact:=-dPmult;
        3:dPact:= dPmult;
      end;

      dPP:=dPact*0.01;

      if CountMom > 1 then for i:=1 to 4 do Glob.Op0.orb[i]:=Eta_ref[i]*dpp;
      Glob.dpp:=dpp;

      FailFlag:=false; BeamLost:=false;
      status.periodic :=false;
      status.symmetric:=false;
      if PerMode or SymMode then begin // always check for closed orbit!
//!      if (CountMom>1)or OffMom  then begin
          ClosedOrbit(FailFlag, do_lpath+do_misal, dpp);  //also returns the transfermatrix required by periodic
          if FailFlag then setStatusLabel(stlab_orb,status_failure) else setStatusLabel(stlab_orb,status_success);
          if not FailFlag then if PerMode then Periodic(FailFlag) else Symmetric(FailFlag);
          if FailFlag then setStatusLabel(stlab_per,status_failure) else setStatusLabel(stlab_per,status_success);
//!        end
//!        else begin
//??      OptInit;     //needed here???  // crash if periodic failed ?
//          for i:=1 to Glob.NLatt do Lattel (i, j, latmode, dpp);
//!          for i:=1 to Glob.NLatt do Lattel (i, j, 0, dpp); // get only the matrix
//          for i:=1 to Glob.NLatt do Lattel (i, j, 2, dpp);
            status.betas:=True; //? even in case of failure ?
//!          if PerMode then Periodic(FailFlag) else Symmetric(FailFlag);

//!        end;
      end else begin

        setStatusLabel(stlab_orb,status_forward);
        setStatusLabel(stlab_per,status_forward);
      end;


      if (CountMom=1)and not dppmode then begin {save [periodic] dp=0 values}
        Beta_ref[1] :=Glob.Op0.beta;        Beta_ref[2] :=Glob.Op0.alfa;
        Beta_ref[3] :=Glob.Op0.betb;        Beta_ref[4] :=Glob.Op0.alfb;
        Eta_ref[1]  :=Glob.Op0.disx;        Eta_ref[2]  :=Glob.Op0.dipx;
        Eta_ref[3]  :=Glob.Op0.disy;        Eta_ref[4]  :=Glob.Op0.dipy;
        for i:=1 to 4 do Orbi_ref[i]:=Glob.Op0.orb[i];
      end;

      if FailFlag then begin   {reset to saved initial values}
        with Glob.Op0 do begin
          beta:= Beta_ref[1];         alfa:= Beta_ref[2];         betb:= Beta_ref[3];         alfb:= Beta_ref[4];
          disx:= Eta_ref[1];          dipx:= Eta_ref[2];          disy:= Eta_ref[3];          dipy:= Eta_ref[4];
          cmat:=matnul2;
          for i:=1 to 4 do orb[i]:= Orbi_ref[i];
        end;
        Glob.dpp     := 0.0;
        Beep;
      end;

      OptInit; //better place for optinit

      Beam.persym:=(not Failflag) and (PerMode or SymMode); //i.e. per/sym sol was found
      LINOP (CountMom-1, istart,  latmode,  dpp);//incl. misal always (is zero if no misal)
 //     LINOP (CountMom-1, istart,  do_lpath+do_twiss+do_chrom+do_radin+do_misal, dpp);//incl. misal always (is zero if no misal)

    end;

{ end CountMom................}

// set periodic flag to dpp=0 beam persym flag
  if PerMode then status.periodic:=oBeam[0].Persym else status.symmetric:=oBeam[0].persym;

  ShowTuneDiagram;

  FillBeamTab;
  FillBetaTab(ibetamark);
  if status.circular then setStatusLabel(stlab_cir, status_flag) else setStatusLabel(stlab_cir, status_void);

  //?
  if dppmode and MomMode then begin  // rstore dpp=0 values
    with Glob.Op0 do begin
      beta :=Beta_ref[1];     alfa :=Beta_ref[2];     betb :=Beta_ref[3];     alfb :=Beta_ref[4];
      disx :=Eta_ref[1];      dipx :=Eta_ref[2];      disy :=Eta_ref[3];      dipy :=Eta_ref[4];
      for i:=1 to 4 do orb[i]:=Orbi_ref[i];
    end;
    Glob.dpp    :=0.0;
  end;

end;

{-------------------------------------------------------------------------}



end.
