unit globlib;

{$MODE Delphi}
INTERFACE  { Definition der globalen Typen, Konstanten und Variablen}

uses
  sysutils, stdctrls, graphics, mathlib, menus, dialogs, controls, asaux; //, OPAWinConsole;

const

  ValidNumbers   =['0'..'9'];                         
  ValidCharacters=['a'..'z','A'..'Z','_'];

  speed_of_light =2.99792458E08; // m/s
  electron_mc2   =511003.37;     // eV
  electron_charge=1.6021892E-19; // C
  electron_radius=2.8179380E-15; // m
  avogadro_number=6.0223E23;     // 1
  planck_constant=6.626070040E-34;//Js
  gas_constant   =8.314;         // J/mol/K

  Cdrif=0;
  Cmark=1;
  Cquad=2;
  Cbend=3;
  Csext=4;
  Csole=5;
  Cundu=6;
  Csept=7;
  Ckick=8;
  Comrk=9;
  Ccomb=10;
  Cxmrk=11;
  Cgird=12;
  Cmpol=13;
  Cmoni=14;
  Ccorh=15;
  Ccorv=16;
  Crota=17;
//  Cgmag=20; // extinct
  Nelemkind=17;
  {Cbrot, Cphak etc. shades from the past}

  Cmisalign: Set of 0..NElemKind =   // elem types which can be misaligned
    [Cquad,Cbend,Csext,Csole,Cundu,Ccomb,Cmpol,Cmoni,Ccorh, Ccorv];

//drawing order for opageometry
  ElemDrawOrder: array[0..NElemKind] of integer =
   (Cxmrk, Cdrif, Cbend, Ccomb, Cquad, CSole, Cundu,
    CSept, Ckick, CSext, Cmpol, Ccorh, Ccorv, Cmoni, Cgird, Cmark, Comrk, Crota);

  strkparam: array[0..NElemKind] of string[13]= ('L [m]', '', 'k [1/m2]',
   'k [1/m2]', 'mL [1/m2]', 'ks [1/m]','', '', 'BnL[1/m(n-1)]', '', 'factor','','',
   'BnL[1/m(n-1)]','','dx'' [mrad]', 'dy'' [mrad]', 'rot [deg]');
  ElemName: array[0..Nelemkind] of string[12] = ('Drift','Marker',
    'Quadrupole','Bending','Sextupole','Solenoid','Undulator',
    'Septum','Kicker','OpticsMarker','Combined','PhotonBeam','Girder',
    'Multipole','Monitor','H-Corrector','V-Corrector','Rotation');
  ElemShortName: array[0..Nelemkind] of string[2] = ('DR','MK',
    'QU','BE','SX','SO','UN','SP','KI','OM','CO','XB','GD','MP','MO','CH','CV','RO');

  ElemThick: array[0..Nelemkind] of boolean =
  (TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE,
   FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE);


  clLightYellow=$0088eeff;

  d_col    =$00999999;
  m_col    =$00555555;
  q_col    =$000000ff;
  b_col    =$00ff0000;
  s_col    =$0000ff00;
  so_col   =$00ffff00;
  u_col    =$0077ff00;
  sp_col   =$0095afcd;
  k_col    =$000361ff;
  om_col   =$0000ffff;
  c_col    =$00ff0077;
  xm_col   =$00ffff00;
  oc_col   =$00005588;
  de_col   =$00558800;
  mo_col   =clGreen;
  ch_col   =$00ff0000;
  cv_col   =$000000ff;
  else_col =$00ffffff;
  betay_col=$000000ff;
  betax_col=$00ff0000;
  dispx_col=$0000ff00;
  dispy_col=$00ff00ff;
  dpp_col  =$000077aa;
  dpm_col  =$00aa7700;
  ro_col   =clFuchsia;

  mp_col   =oc_col;

  ElemCol: array[0..NElemKind] of TColor = (d_col, m_col, q_col, b_col,
  s_col, so_col, u_col, sp_col, k_col, om_col, c_col, xm_col, m_col,
  mp_col, mo_col, ch_col, cv_col, ro_col);
  ElemTextCol: array[0..NElemKind] of TColor = (clWhite, clBlack, clBlack, clWhite,
  clBlack, clBlack, clBlack, clBlack, clBlack, clBlack, clWhite, clBlack, clBlack,
  clWhite, clBlack, clWhite, clWhite, clBlack);


  // for mode witching on/off in element calculations
  do_twiss=1; do_chrom=2; do_radin=4; do_lpath=8; do_misal=16;




  nMatchFunc=18;
  MatchFuncName: array[1..nMatchFunc] of string[4] =('bxf','axf','byf','ayf',
     'disf','dipf','oxf','oxpf','qx','qy',  'bxi','axi','byi','ayi','disi','dipi','oxi','oxpi');


  NElemMax=6000; NSegmMax=500; NSegLMax=1000;
  NLattMax=15000;
//  NCurveMax=1500;

  goForward=1; goBackward=-1;

  OPA_inipath_name='opa4_path.ini';
  OPA_glob_name   ='opa4_glob.ini';
  OPA_def_name    ='opa4_set.ini';
  delimiter='\';

  maxLastUsedFiles=10;

  ElemStrLength =16;
//  ElemStrLength =20;
  xbcountmax=20; //max entries in snapsave photon beams

  oco_chname= 'CH'; oco_cvname='CV'; oco_bpmname='MON';
  oco_csname='CS'; oco_qaname='QAC'; nomisal_markername='NOMIS';

  nMomFit_order=12;
  nMomFit_param=3;
  MomFit_param: array[1..nMomFit_param] of string[6]=('qx','qy','dpath');

  nStatusLabels=14;
  stlab_orb=0; stlab_per=1; stlab_cir=2;
  stlab_cop=3; stlab_cor=5; stlab_kik=4;
  stlab_mis=6; stlab_tsh=7; stlab_chr=8;
  stlab_tmx=9; stlab_cmx=10;stlab_alf=11;
  stlab_rfm=12; stlab_flo=13;
  StatusLabNcap: array[0..nStatusLabels-1] of String =(
    'closed orbit','periodic','(circular)',
    'coupling', 'kickers','active correctors',
    'active misalignments','tune shifts','chromaticities',
    'tuning matrix', 'chroma matrix','pathlength',
    'RF bucket','3D Acc xx''p');
  nStatusType=7;
  status_void=0; status_success=1; status_failure=2; status_forward=3; status_off=4; status_light=5; status_flag=6;
  StatusResCap: array[0..nstatustype] of string=(' ','o','x','>',' ','!','*',' ');
  StatusChrInd: array[0..nStatusType] of Integer=(32,74,78,70,{161}32,173,79,77);
//  StatusChrInd: array[0..nStatusType] of Integer=(32,252,251,240,{161}32,173,79,77);
  StatusColor: array[0..nStatusType] of TColor=(clblack,clgreen,clred,clblue,clgray,clred,clblue, clfuchsia);


type

  String_2   = string[2];
  ElemStr    = string[ElemStrLength];
  string_4   = string[4];
  String_12  = string[12];
  String_25  = string[25];
  String_40  = string[40];
  String_70  = string[70];
  FileString = string[100];
  LineString = string[80];

  LineBufpt=^LineBuf;
  LineBuf  = record
    line: LineString;
    nex:  LineBufpt;
  end;

  CharBufpt=^CharBuf;
  CharBuf  = record
    ch:  Char;
    nex: CharBufpt;
  end;

//  EArr_2     = array[1..2]    of real;    IArr_2   = array[1..2] of integer;

  Vektor_10  = array[1..10]   of real;
  Vektor_6  = array[1..6]   of real;
  PlotWert   = array[0..16]   of real;

  Omarkpt = ^OmarkType;
  OmarkType = record
    bet, eta, orb: Vektor_4;
    cma: matrix_2;
//    dpp: real;
  end;

  OpvalType = record
    spos: real;
    disx, dipx, disy, dipy{, phix, phiy} : double; //phix ?
    beta, betb, alfa, alfb, phia, phib, betaf, betbf: double;
    path: double;
    orb: Vektor_4; //xdpp: real;
    cmat, cmatf, am, bm: Matrix_2;
  end;

  BeamParType = record
    persym: boolean; //flag true = success of periodic/symetric
    dppset, Circ, Angle, AbsAngle, ChromX, ChromY, Emita, Emitb, U0,
    Ja, Jb, Je, Ta, Tb, Te, alfa, sigmaE: Real;
    RadInt1, RadInt2, RadInt3, RadInt4a, RadInt4b, RadInt5a, RadInt5b: double;
    tmfx, tmfy, tmdx, tmdy: real;
    Qa, Qb: extended;
    Qx, Qy: extended; //historical... to be removed
  end;

  XB_SnapSaveType = record
    nam: ElemStr;
    betax, betay, dispx: real;
  end;

// snapsave is used for exporting lattice parameter (in additon to currents) to .snap and SLS control system
// it is also used to "remember" temporarily previously calculated data between units
// --> should be disentangled, new variable "Memory" or something like that. as-30.1.18
  SnapSaveType = record
    // export: tunes, chromas, elements of tuning and chroma matrices
    Qx, Qy, ChromX, ChromY: real;
    tmfx, tmfy, tmdx, tmdy: real;
    cmfx, cmfy, cmdx, cmdy: real;
    //remember: adts and chromas from Chroma for overplotting in Momentum and TrackP:
    qxx, qxy, qyy, cx2, cy2, cx3, cy3: real;
    // remember: alpha*Circ up to 5.Ord from Momentum, for using in Bucket:
    alfaC, voltRF: array[0..4] of real;
    rfaccm, rfaccp, sigmas, lambdaRF: real;
    // export: beam parameters at X-ray cameras, to be used by IDL camera viewer cam.pro
    xbcount: integer;
    xb: array[0..xbcountmax-1] of XB_SnapSaveType;
  end;

  MatchFuncType = array[1..nMatchFunc] of Real;

{ INTERNAL element units: m and rad, mm for apertures
  Tesla for undulator peak field
  mrad for kick angles, mm for septum thickness and distance}

  calibrationType = record
    typename:string_12;
    leng, imax, bres, tlin, isat, aexp, nexp: real;
    mpol, sfac:integer;
  end;


  nameListpt =^nameListType;
  nameListType = record
    realname, psname: string_25;
    typ_name: string_12;
{type also saved in Elem.TypNam -> available for opageometry even if no calibration exists;
 further avoid loss of typename when creating monitor, corrector arrays 22.2.2018}
    typeindex, polarity, topology: integer;
    nex: nameListpt;
  end;

  Elem_Exp_pt =^string;

  Elementpt   = ^ElementType;
  ElementType = record
    Nam: ElemStr; TypNam: string_12;
    l, ax, ay, rot: real;
    l_exp, rot_exp: Elem_Exp_pt;
    nl: namelistpt;
    tag: integer;
    case cod: integer of
      cdrif: (block: boolean);
      cquad: (kq: real; kq_exp: Elem_Exp_pt);
      cbend: (phi, tin, tex, kb, gap, k1in, k1ex, k2in, k2ex: real;
              phi_exp, tin_exp, tex_exp, kb_exp: Elem_Exp_pt);
      csext: (ms: real; sslice: shortint);
      csole: (ks: real);
      cundu: (lam, bmax, ugap, fill1, fill2, fill3: real; halfu: boolean);
      ckick: (amp, xoff, tau, delay: real; mpol, kslice: integer);
      csept: (ang, dis, thk: real);
      comrk: (om: omarkpt; screen: boolean);
      ccomb: (cphi, cerin, cerex, cek1in, cek1ex, cgap, ckq, cms: real; cslice: shortint;
              cphi_exp, cerin_exp, cerex_exp, ckq_exp: Elem_Exp_pt);
      cxmrk: (xl: real; nstyle: shortint; snap: shortint);
      cgird: (gtyp: integer; shift: real);
      cmpol: (bnl, lmpol:real; nord: integer);
      cmoni: ({xpos,ypos: real;} ocom:boolean);
      ccorh: (dxp: real; ocox: boolean);
      ccorv: (dyp: real; ocoy: boolean);
  end;

  AEpt = ^AbstractEleType;
  AbstractEleType = record
    nam: ElemStr;
    kin: (seg,ele);
    inv: boolean;
    rep: byte;
    pre, nex: AEpt;
  end;

  SegmentType = record
    nam: ElemStr;
    ini, fin: AEpt;
    nper: integer;
  end;

  ElemArr   = array[1..NElemMax] of ElementType;
  ElemArrpt = ^ElemArr;
  SegmArr = array[1..NSegmMax] of SegmentType;


  GlobType = record
    Energy, Ax, Ay : real;
    NPer, NLatt, NElem, NElla, NSegm, Method, Nqkick, Nbkick: word;
    Text : string;
    Op0, OpE: OpvalType;
    dpp: real;
    rot_inv: boolean;
  end;

  StatusType = record
    Elements, Segments, Undulators, Lattice, UnCoupled, Betas, TuneShifts, Chromas, Monitors, Kickers,
    PerOrbit, Periodic, Symmetric, Circular, Currents, Tmatrix, Cmatrix, Alphas, RFaccept, FloPoly: Boolean;
  end;

  CurvePt=^CurveType;
  CurveType = record
    spos, beta, betb, disa, disb, alfa, alfb, xpos, ypos,  betxa, betya, betxb,
      betyb, disx, disy, disxp, disyp, cdet, betaf, betbf, cdetf: real;
    nex: CurvePt;
  end;

  CurvePlotType = record
    enable: Boolean;
    sini, sfin, slice: real;
    ncurve: integer;
    ini: CurvePt;
  end;

  LatticeType = record
    elnam: ElemStr;
    jel, inv, igir: integer; //element, direction +/-1, girder
    dx, dy, dt, smid, angmid, misamp: real; // sway, heave, roll, midpoint, mid angle, misal scaling
    coupl, misal: boolean; // coupling element with non-blockdiag matrix, misalignment set
  end;

  Girdertype =record
    gsp, gang, {gxpos, gypos,} gshft, gdx, gdy: array[0..1] of real; //pos, angle, shift; sway, heave of feet
    gdt: real; //roll
    ilat, igir, gco: array[0..1] of integer; //lattice start/end and type of connection to adjacent girder:
    level: integer;
    //gco: 0 nothing, 1 joint (train link), 2 1-point support, 3 2-point support
  end;

{  TrackModeType = record
    twiss, chrom, radeq, corr, path: boolean;
  end;
}
  DefaultType = record
    nam: String[12];
    val: real;
  end;

  MainButtonHandlesType = record
    fi_new, fi_open, fi_save, fi_svas, fi_expo, ed_text, ed_oped,
    ds_opti,ds_dppo, ds_sext,ds_lgbo, ds_orbc, ds_injc, ds_rfbu,
    tr_phsp, tr_dyna, tr_ttau, tm_geo, tm_cur: TMenuItem;
  end;

  variable_type = record
    nam: elemstr;
    val: real;
    exp: string;
    use: boolean;
    tag: integer;
  end;

  ProPtype = record
    elen, pos, beta, betb, cdet, betaf, betbf, cdetf: double;
  end;

  MF_savetype=record          // test only
    spos: real; act: integer;
  end;


Var
  MF_save: array of MF_savetype; // test only

// TextBuffer is a linked list of characters for storing the complete input file
//   in one char array (forward link only, term. by nil)
  TextBuffer: pointer;
// LineBuffer is a linked list of 80char-lines for storing a file in formatted output
//  LineBuffer: pointer; REMOVED 13.2.2019, see junk/latwrite_et_al.pas

//  ErrorLog: TMemo;

  Glob        : GlobType;
  Elem, Ella  : ElemArr;
  Segm        : SegmArr;
  Lattice     : array of LatticeType;
  Girder      : array of GirderType;
  NGirderLevel: array[1..3] of integer;
  Status      : StatusType;
  CurvePlot   : CurvePlotType;
//  Curve       : array[1..NCurveMax] of CurveType;
  Curve: CurvePt;
  variable: array of variable_type;

//  trackmode: trackmodetype;

  Calibration: array of CalibrationType;

  allocationFile: filestring;  allocationFlag: boolean;
  calibrationFile: filestring;  calibrationFlag: boolean;

  ActSeg: AEpt;  iActSeg: word;

  Beam: BeamParType;
  Snapsave: SnapSaveType;

// diese variablen anderswo hin
    SPosEl, SPosition, TimeOfFlight, Deflection, AbsDeflection,
    BetaX_A, AlfaX_A, BetaZ_A, AlfaZ_A, DispX_A, DispSX_A,
    DispZ_A, DispSZ_A, BetaX_B, AlfaX_B, BetaZ_B, AlfaZ_B,
    DispX_B, DispSX_B, DispZ_B, DispSZ_B, OldKFactor,
    Ln10, degrad, raddeg : real;
    PathDiff: double;

  Unit_Matrix_5, TransferMatrix, Transfermatrix0: Matrix_5;
  MisalignVector: Vektor_4;

  FractionalTuneA, FractionalTuneB, FractionalTuneA2, FractionalTuneB2: double;
  TmatStack: array of Matrix_4; // propper test only
  ElenStack: array of ProPtype;   // propper test only

  Amat0, Amat1, Amat2, Bmat0, Bmat1, Bmat2,
  CoupMatrix0, CoupMatrix1, CoupMatrix2, CoupMatrix0_flip, CoupMatrix1_flip, CoupMatrix2_flip, // coupling matrix
  SigNa0, SigNa1, SigNa2, SigNb0, SigNb1, SigNb2,
  SigNa0_flip, SigNa1_flip, SigNa2_flip, SigNb0_flip, SigNb1_flip, SigNb2_flip: Matrix_2;  //normal mode normalized sigma matrics

  ModeFlip, Fliphashappened: Boolean;
  Disper0, Disper1, Disper2, DisperE, Orbit0, Orbit1, Orbit2, OrbitE: Vektor_4;

  Norm2Sigma, SigmaNorm, SigmaPhys: Matrix_5;

  Beta_ref, Eta_ref, Orbi_ref: Vektor_4;

  UseSext, UsePulsed: Boolean;
  PropperTest, PropperDone: Boolean;

  Txtstr : FileString;
  FileName: String;
  diagfil : text;
  diaglevel: integer;


 // Zeiger : Pointer;
  BtMxMem, DsMxMem: real;
  mem: text;
  MerkName: String_12;
  ExitFlag: Boolean; {AS 060492}
  RLinCh: array[1..2] of Char;

  meth_mat, meth_si4: Boolean;
  k4c1, k4c2, k4d1, k4d2: real;

{pub}  Def: array of DefaultType;
       DefFile: string;
       GlobDef: array of DefaultType;

// OPA's working directory
   OPA_dir, work_dir: string;
   LastUsedFiles: array[1..maxLastUsedFiles] of String;
   countLastUsedFiles:integer;
   OPAversion: string;

   MainButtonHandles: MainButtonHandlesType;
   StatusLabels: array[0..nStatusLabels] of TLabel;

   betax_col_m, betay_col_m, dispx_col_m, dispy_col_m, betax_col_p, betay_col_p, dispx_col_p, dispy_col_p: TColor;

   ErrLogHandle: TMemo;
   OPALogBuffer: string;

   Erad_factor, Ecrit_factor, RadCq_factor: double; //derived from constants in OpaInit

function switch (mode, im: shortint): boolean;

procedure BetaToOp(b: Vektor_4; var Op: OpvalType);
procedure DispToOp(d: Vektor_4; var Op: OpvalType);
procedure OrbToOp(o: Vektor_4; var Op: OpvalType);

function OpToBeta(Op: OpvalType): Vektor_4;
function OpToDisp(Op: OpvalType): Vektor_4;
function OpToOrb(Op: OpvalType): Vektor_4;


{calculator:}
function Eval_Exp (expression: string; var err: boolean): real;
function Get_Eval_exp_errmess: string;


{---------------------------------------------}
// still writing to diagfil?
  procedure printmat5(t: matrix_5);
  procedure printmat4(t: matrix_4);
  procedure printmat3(t: matrix_3);
  procedure printmat2(m: matrix_2);


  function diag(lev: integer):boolean;

  {###### Access to elements and segments ##################################}
function Elcompare(a, b: ElementType):boolean;
function EllaSave: word;
procedure PassMainButtonHandles(fnew, fopen, fsave, fsvas, fexpo,
    etext, eoped, dopti, ddppo, dsext, dlgbo, dorbc, dinjc, drfbu,
    tphsp, tdyna, tttau, tgeo, tcur: TMenuItem);
procedure passErrLogHandle(errlog: TMemo);
procedure MainButtonEnable;
procedure SetStatusLabel(ilab, istat: integer);
procedure OPALog(typ: integer; messageText:string);
procedure FillComboSeg (var comboseg: TComboBox);
function ShortName(name: String): String;

function getkval (j: word; jpar: word): real;
procedure putkval (k: real; j: word; jpar: word);
function getSexkval (j: word): real;
procedure putSexkval (k: real; j: word);

function NameCheck(s: String): Boolean;

function AppendChar(var a: CharBufpt; ch: Char): CharBufpt;
//function AppendLine(var a: LineBufpt; line: String): LineBufpt;
function AppendCurveN (var a: CurvePt; s, x, y, bxa, bxb, bya, byb, dx, dy, dxp, dyp, cdet, ba,bb, aa, ab, da,db: real): CurvePt;
procedure ClearCurve;
function  FindEl  (ilattice:integer): integer;
procedure DeleteElem(name: ElemStr);
function  FindKind(ckind:integer): boolean;
function  AppendAE(var a: AEpt; name: ElemStr): AEpt;
function  Exist(nele, nseg: word; name: ElemStr): boolean;
//procedure ClearLineBuffer; // REMOVED 13.2.2019, saved in
procedure ClearTextBuffer (var TextBuf: pointer);
//procedure UpdateTextBuffer; // REMOVED 13.2.2019
//function  CheckForChanges: boolean; // REMOVED 13.2.2019
procedure ClearSeg  (iseg: word);
procedure ClearSegAll;
function  NAESeg (i: word; var ne, ns: word): word;
procedure IniElem (j: word);
function  VariableToStr(i: integer): String;
function  ElemToStr (i: integer): String;
function  SegmToStr(i: integer): string;
procedure GirderSetup;   //used by orbit and geo only
procedure MakeLattice (var success: boolean);
procedure ShowLattice (log: TMemo);

{##### Path, filename and default values #################################}
procedure DefReadFile;
procedure DefWriteFile;
function DefFindEl(s: string): integer;
function FDefGet(s: string): real;
function IDefGet(s: string): integer;
procedure DefSet(s: string; val: real);

procedure GlobDefReadFile;
procedure GlobDefWriteFile;
function GlobDefFindEl(s: string): integer;
function GlobDefGet(s: string): integer;
procedure GlobDefSet(s: string; val: real);

{####### Global initialization ###########################################}
Procedure OPAInit;
Procedure GlobInit;

IMPLEMENTATION

function diag(lev: integer):boolean;
// control of output, switch to become true if lev <= diaglevel
begin
  diag:=(lev <= diaglevel);
end;

function switch (mode, im: shortint): boolean;
// extracts if 2^(im-1) is set in mode
begin
  switch:=(mode div im) mod 2 = 1;
end;


procedure BetaToOp(b: Vektor_4; var Op: OpvalType);
begin
  with Op do begin
    beta:=b[1]; alfa:=b[2]; betb:=b[3]; alfb:=b[4];
  end;
end;


procedure DispToOp(d: Vektor_4; var Op: OpvalType);
begin
  with Op do begin
    disx:=d[1]; dipx:=d[2]; disy:=d[3]; dipy:=d[4];
  end;
end;

procedure OrbToOp(o: Vektor_4; var Op: OpvalType);
var i: integer;
begin
  with Op do for i:=1 to 4 do orb[i]:=o[i];
end;

function OpToBeta(Op: OpvalType): Vektor_4;
var
  b: Vektor_4;
begin
  with Op do begin
    b[1]:=beta; b[2]:=alfa; b[3]:=betb; b[4]:=alfb;
  end;
  OpToBeta:=b;
end;


function OpToDisp(Op: OpvalType): Vektor_4;
var d: Vektor_4;
begin
  with Op do begin
    d[1]:=disx; d[2]:=dipx; d[3]:=disy; d[4]:=dipy;
  end;
  OpToDisp:=d;
end;

function OpToOrb(Op: OpvalType): Vektor_4;
var o: Vektor_4; i: integer;
begin
  with Op do for i:=1 to 4 do o[i]:=orb[i];
  OpToOrb:=o;
end;







{ ===================== Calculator  ============================================}
{
Evaluation of expressions containing real numbers, variable names and +-*/ operators.

Calculator from http://rosettacode.org/wiki/Arithmetic_Evaluator/Pascal
and adjusted to Delphi, basically by replacing
text --> PChar
get --> Inc
eoln(f) --> (f^<>#0)
as-14.10.2015

extended to take real numbers, including exponents and variable names, e.g.
A111=32.05
B=5E-2
C=2.48
1.2E-3*(3.5E+1+A111)*(B+C)/B

as-20.10.2015

Problem! Vorzeichen gefolgt von Variable wurde nicht erkannt, z.B. (-C), es sei denn eine
irrelevante Zeile mehr wurde in den code eingefuegt - das verweist auf einen verborgenen Pointer-Fehler!
Nun geht es, aber moeglicherweise gibt es einen Fehler --> Delphi-Hilfe: "PChar in String Konvertierung"
}

type
  NodeType = (binop, number, error);

  pAstNode = ^tAstNode;
  tAstNode = record
    case typ: NodeType of
              binop:
              (
                operation: char;
                first, second: pAstNode;
              );
              number:
               (value: real);
              error:
               ();
             end;
var
  Eval_exp_errmess: string;

function newBinOp(op: char; left: pAstNode): pAstNode;
var
  node: pAstNode;
begin
  new(node);
  node^.typ:=binop;
  node^.operation := op;
  node^.first := left;
  node^.second := nil;
  newBinOp := node;
end;

procedure disposeTree(tree: pAstNode);
 begin
  if tree^.typ = binop
   then
    begin
     if (tree^.first <> nil)
      then
       disposeTree(tree^.first);
     if (tree^.second <> nil)
      then
       disposeTree(tree^.second)
    end;
  dispose(tree);
 end;

function parseAddSub(var f: PChar): pAstNode; forward;
function parseMulDiv(var f: PChar): pAstNode; forward;
function parseValue(var f: PChar): pAstNode; forward;

function parseAddSub;
var
  node1, node2: pAstNode;
  continue: boolean;
begin
  node1 := parseMulDiv(f);
  if node1^.typ <> error then begin
    continue := true;
    while continue and (f <> #0) do begin
      if f^ in ['+', '-'] then begin
        node1 := newBinop(f^,node1);
        Inc(f);
        node2 := parseMulDiv(f);
        if (node2^.typ = error) then begin
          disposeTree(node1);
          node1 := node2;
          continue := false
        end else
          node1^.second := node2
        end else
         continue := false
      end;
    end;
  parseAddSub := node1;
end;

function parseMulDiv;
var
  node1, node2: pAstNode;
  continue: boolean;
begin
  node1 := parseValue(f);
  if node1^.typ <> error then begin
    continue := true;
    while continue and (f<>#0) do begin
      if f^ in ['*', '/'] then begin
        node1 := newBinop(f^,node1);
        Inc(f);
        node2 := parseValue(f);
        if (node2^.typ = error) then begin
          disposeTree(node1);
          node1 := node2;
          continue := false
        end else
          node1^.second := node2
        end else
         continue := false
      end;
    end;
  parseMulDiv := node1;
 end;

function parseValue;
var
  node:  pAstNode;
  value: real;
  neg:   boolean;
  valst: string;
  errint, isy: integer;
  errboo: boolean;
begin
  node := nil;
  if f^ = '('  then begin
    Inc(f);
    node := parseAddSub(f);
    if node^.typ <> error  then  begin
      if f^ = ')' then Inc(f) else begin
        disposeTree(node);
        new(node); node^.typ:=error;
      end; //else
    end; //<> error
  end // bracket '('

  // check if it is any alphanumeric character (only uppercase allowed) or sign or comma
  else begin
    if f^ in [ '+', '-', '.', '0' .. '9', 'A' .. 'Z', '_' ] then begin
      valst:='';
// first char may be a minus (or +)
      neg := (f^ = '-');
      if f^ in ['+', '-'] then Inc(f);


// test next character to distinguish a number and a variable name
      if f^ in ['.', '0' .. '9'] then begin
//is a number probably, so we expect only digits, comma and perhaps an E for exponents.
//don't accept any +/- since this would be the next operator
        while f^ in ['E', '0' .. '9', '.'] do begin
          valst:=valst+f^;
// special treatment for a sign following an exponent like 1.3E-05
          if f^='E' then begin
            Inc(f); //peep one char ahead, if it is + or - (if it is last char, it will be #0)
            if f^ in ['+', '-'] then valst:=valst+f^ else Dec(f);
          end;
          Inc(f);
        end; //while
// try conversion into a number
{$R-}
        Val(valst,value,errint);
{$R+}

        if errint=0 then begin
          new(node); node^.typ:=number;
          if neg then  node^.value:=-value else node^.value:=value;
// if this failed, then check if it is a variable we know and get its value
        end;
        if node = nil then begin
          new(node); node^.typ:=error;
          Eval_exp_errmess:=Eval_exp_errmess+'invalid numeric format: "'+valst+'".';
        end;
      end // is a number

      else if f^ in ['A' .. 'Z', '_'] then begin
//probably it is a variable, so we expect chars and digits but no comma.
//don't accept any +/- since this would be the next operator
        while f^ in ['0' .. '9', 'A' .. 'Z', '_'] do begin
          valst:=valst+f^;
          Inc(f);
        end; //while
//look for a variable with same name
        for isy:=0 to High(Variable) do with Variable[isy] do begin
          if compareText(nam,valst)=0 then begin
// Alternatives: take the value stored in variable or re-evaluate its expression
// if exp=nil, then we have a constant, i.e. a pure number
            value:=val;   errboo:=false;
            if (exp <>'') then value:=Eval_Exp(exp, errboo);
            use:=true;    // this variable was used
            new(node); node^.typ:=number;
            if neg then node^.value:=-value else node^.value:=value;
          end;
        end; //for
        if node = nil then begin
          new(node); node^.typ:=error;
          Eval_exp_errmess:=Eval_exp_errmess+'variable "'+valst+'" does not exist.';
        end;
      end; // is a variable
    end; // test on valid initial character for number or variable

    // if it was neither a number nor a variable, the input was invalid --> error
    if node = nil then begin
      new(node); node^.typ:=error;
      if ord(f^)=0 then Eval_exp_errmess:=Eval_exp_errmess+'line incomplete.' else Eval_exp_errmess:=Eval_exp_errmess+'invalid character "'+f^+'" (#'+inttostr(ord(f^))+').';
     end;
  end; // not a bracket '('
  parseValue := node
end;

function eval(ast: pAstNode): real;
begin
  with ast^ do begin
    case typ of
      number: eval := value;
      binop:
        case operation of
        '+': eval := eval(first) + eval(second);
        '-': eval := eval(first) - eval(second);
        '*': eval := eval(first) * eval(second);
        '/': eval := eval(first) / eval(second);
        end;
      error: begin      // can never happen, since eval only called if no error?
        opalog(1,'Error in eval procedure!');
        eval:=0.0;
      end;
    end;
  end;
end;

function Eval_Exp (expression: string; var err: boolean): real;
// evaluate an expression: get a string containing an expression and calculate the result
var
  ast: pAstnode;
  res: real;
  pline: PChar;
begin
  pline:=PChar(expression);
  Eval_exp_errmess:='';
  ast := parseAddSub(pline);
  err:= (ast^.typ = error);
  if err then res:=0 else res:=eval(ast);
  disposeTree(ast);
  Eval_Exp:=res;
end;

function Get_Eval_exp_errmess: string;
begin
  Get_Eval_Exp_errmess:=Eval_Exp_errmess;
end;

{==========================================================================================}

  procedure printmat5(t: matrix_5);
  var
    i,j: integer;
  begin
    for i:=1 to 4 do begin
      for j:=1 to 5 do write(diagfil,t[i,j]); writeln(diagfil);
    end;
    writeln(diagfil);
  end;

  procedure printmat4(t: matrix_4);
  var
    i,j: integer;
  begin
    for i:=1 to 4 do begin
      for j:=1 to 4 do write(diagfil,t[i,j]); writeln(diagfil);
    end;
    writeln(diagfil);
  end;

  procedure printmat3(t: matrix_3);
  var
    i,j: integer;
  begin
    for i:=1 to 3 do begin
      for j:=1 to 3 do write(diagfil,t[i,j]); writeln(diagfil);
    end;
    writeln(diagfil);
  end;

  procedure printmat2(m: matrix_2);
  begin
    writeln(diagfil, '[ ',m[1,1], m[1,2],'  ]');
    writeln(diagfil, '[ ',m[2,1], m[2,2],'  ]');
    writeln(diagfil);
  end;


{
  compare two elements and return false if there is a difference
  the expressions are NOT compared, because Ella and Elem have the same pointers,
  which refer to the same expression. Instead changing expression outside Editor is blocked.
}
function Elcompare(a, b: ElementType):boolean;
var
  check: boolean;

  procedure chk(x1,x2: real);
  const
    epsi=1e-10;
  begin
    check:=check and (abs(x1-x2)<epsi);
  end;

begin
  check:=(a.cod=b.cod);
  if check then begin
    chk(a.l,b.l);  chk(a.ax, b.ax);  chk(a.ay,b.ay);
    case a.cod of
      cdrif: check:=check and (a.block = b.block);
      cquad: begin
        chk(a.kq,b.kq);
        check:=check and (a.kq_exp = b.kq_exp);
      end;
      cbend: begin
        chk(a.phi,b.phi); chk(a.tin,b.tin); chk(a.tex,b.tex); chk(a.kb,b.kb);
        chk(a.k1in,b.k1in); chk(a.k1ex,b.k1ex); chk(a.k2in,a.k2ex);
      end;
      csext: begin
        chk(a.ms, b.ms); chk(a.sslice, b.sslice);
      end;
      csole: begin
        chk(a.ks, b.ks);
      end;
      cundu: begin
      end;
      ckick: begin
        chk(a.amp, b.amp);
        chk(a.xoff, b.xoff);
        chk(a.tau, b.tau);
        chk(a.delay, b.delay);
      end;
      csept: begin
        chk(a.ang, b.ang); chk(a.dis, b.dis); chk(a.thk, b.thk);
      end;
      ccomb: begin
        chk(a.cphi,b.cphi); chk(a.cerin,b.cerin); chk(a.cerex,b.cerex);
        chk(a.cek1in, b.cek1in); chk(a.cek1ex, b.cek1ex); chk(a.cgap, b.cgap);
        chk(a.ckq,b.ckq); chk(a.cms,b.cms); chk(a.cslice,b.cslice);
      end;
      cmpol: begin
        chk(a.bnl, b.bnl);
        chk(a.lmpol, b.lmpol);
        chk(a.nord, b.nord);
      end;
      ccorh: begin
        chk(a.dxp,b.dxp);
      end;
      ccorv:begin
        chk(a.dyp,b.dyp);
      end;
      else begin
      // cdrif, comrk, cxmrk, cgird, cmtrx, cmoni
      end;
    end;
  end;
  ElCompare:= check;
end;

function EllaSave: word;
{compares ella to corresponding elem (identified by name)
 if any of the ella properties has been changed compared to ella,
 it asks, if to save the changed ella values into elem, else to
 reset ella by elem values.
 special treatment required for oco-corrs, which exist only as ellas.
 as-300709}

var
  ia, i, iel: integer;
  check: boolean;
  mresult: word;
begin

  check:=True;
  for ia:=1 to glob.NElla do begin
    iel:=-1;
    for i:=1 to glob.NElem do if (elem[i].nam=ella[ia].nam) then iel:=i;
    if iel > -1 then check:=check and ElCompare(elem[iel],ella[ia]);
  end;

// save: write ella to elem; no save: reset ella to elem
// (because only MakeLattice copies elem to ella)
// it doesn't matter if elem/ella have expressions, because expression will override value

  if not check then begin
    mresult:=MessageDlg('Save changes ?', MtConfirmation, mbYesNoCancel,0);
    case mresult of
      mrCancel: begin
// do nothing
      end;
      mrYes: begin
// copy ella to elem
        for ia:=1 to glob.NElla do begin
          iel:=-1;
          for i:=1 to glob.NElem do if (elem[i].nam=ella[ia].nam) then iel:=i;
          if iel > -1 then elem[iel]:=ella[ia];
        end;
// reset status because things have changed.
        setStatusLabel(stlab_alf,status_void);
        setStatusLabel(stlab_chr,status_void);
        setStatusLabel(stlab_tsh,status_void);
        setStatusLabel(stlab_rfm,status_void);
        setStatusLabel(stlab_flo,status_void);
      end;
      mrNo: begin
// reset ella with elem
        for ia:=1 to glob.NElla do begin
          iel:=-1;
          for i:=1 to glob.NElem do if (elem[i].nam=ella[ia].nam) then iel:=i;
          if iel > -1 then ella[ia]:=elem[iel];
        end;
      end;
    end; //case
// if elements have not been changed, reply mrYes to enable storing results like tune shifts from chroma
  end else mresult:=mrYes;
  ellaSave:=mresult;
end;

// pass handles for main menu buttons to this global structure, that other
// forms can disable/enable them
procedure PassMainButtonHandles(fnew, fopen, fsave, fsvas, fexpo,
    etext, eoped, dopti, ddppo, dsext, dlgbo, dorbc, dinjc, drfbu,
    tphsp, tdyna, tttau, tgeo, tcur: TMenuItem);
begin
  with MainButtonHandles do begin
    fi_new:=fnew; fi_open:=fopen; fi_save:=fsave; fi_svas:=fsvas; fi_expo:=fexpo;
    ed_text:=etext; ed_oped:=eoped;
    ds_opti:=dopti; ds_dppo:=ddppo; ds_sext:=dsext; ds_lgbo:=dlgbo; ds_orbc:=dorbc; ds_injc:=dinjc; ds_rfbu:=drfbu;
    tr_phsp:=tphsp; tr_dyna:=tdyna; tr_ttau:=tttau;
    tm_geo:=tgeo; tm_cur:=tcur;
  end;
end;


procedure passErrLogHandle(errlog: TMemo);
begin
  ErrLogHandle:=errlog;
end;

// disable/enable main menue buttons depending on status flags
procedure MainButtonEnable;
begin
  with MainButtonHandles do begin
    fi_new.Enabled:=true;
    fi_open.Enabled:=true;
    fi_save.Enabled:=true;
    fi_svas.Enabled:=true;
    fi_expo.Enabled:=true;
    ed_text.Enabled:=true;
    ed_oped.Enabled:=true;
    ds_opti.Enabled:=status.Lattice;
    ds_dppo.Enabled:=status.Lattice;
    ds_sext.Enabled:=status.Periodic;
    ds_lgbo.Enabled:=True;
    ds_orbc.Enabled:=status.Lattice and status.Monitors;
    ds_injc.Enabled:=status.Lattice and status.Kickers;
    tr_phsp.Enabled:=status.Periodic;
    tr_dyna.Enabled:=status.Periodic;
    tr_ttau.Enabled:=status.Periodic;
    tm_geo.Enabled:=status.Lattice;
    tm_cur.Enabled:=status.Currents;
  end;
end;

procedure SetStatusLabel(ilab, istat: integer);
begin
  with StatusLabels[ilab] do begin
    if (istat >=0) and (istat < nStatusType) then begin
//      Caption:=Chr(statusChrInd[istat]);
      Caption:=statusResCap[istat];
      Font.Color:=statusColor[istat];
    end else begin
//      Caption:=Chr(statusChrInd[nstatusType]);
      Caption:=statusResCap[nstatustype];
      Font.Color:=statusColor[nStatusType];
    end;
  end;
end;

// writes messages to OPA main panel window
// if window is not available (e.g. at start), messages are buffered
// and written at next occasion
procedure OPALog(typ: integer; messageText: string);
const
  cutter='$$$';
  maxtyp=6;
  styp: array[0..maxtyp] of string[7] =('[INFO] ','[ERRO] ','[WARN] ','------ ','[DLV1] ','[DLV2] ','[DLV3] ');
var
  line: string;
  ind,icut:integer;

  procedure applin (line:string);
  const
    space='       ';
  var
    s: string;
    ibr: integer;
  begin
    s:=line;
    ibr:=Pos('|>',s);
    while ibr>0 do begin
      ErrlogHandle.Lines.append(Copy(s,1,ibr-1));
      s:=space+copy(s,ibr+2,999);
      ibr:=Pos('|>',s);
    end;
    ErrlogHandle.Lines.append(s);
  end;

begin
// typ  0, 1, 2, 3 --> ind 0,1,2,3: info,err,warn,head
// typ -1,-2,-3 --> ind 4,5,6: dlv1,2,3 if |typ|<=diaglevel
  ind:=-1;
  if typ < 0 then begin
    if -typ <= diaglevel then ind:=maxtyp-3-typ;
  end else if (typ <= 3) then ind:=typ;
  if (ind>=0) and (ind<=maxtyp) then begin
    if ErrLogHandle = nil then begin
      OPALogBuffer:=OPALogBuffer+styp[ind]+messageText+'$$$';
    end else begin
      icut:= Pos(cutter,OPALogBuffer);
      while icut > 0 do begin
        line:=Copy(OPALogBuffer,1,icut-1);
        applin(line);
        OPALogBuffer:=Copy(OPALogBuffer,icut+3, Length(OPALogBuffer));
        icut:= Pos(cutter,OPALogBuffer);
      end;
      applin(styp[ind]+messageText);
//      if typ=-1 then ErrLogHandle.Clear;
      ErrLogHandle.Show;
      ErrlogHandle.SelStart:=Length(ErrLogHandle.Text);
    end;
  end;
end;


procedure FillComboSeg (var comboseg: TComboBox);
var i: integer;
begin
  with comboseg do begin
    Clear;
    Text:='select!' ;
    for i:=1 to Glob.NSegm do begin
      {index:=}Items.Add(Segm[i].nam);
    end;
  end;
end;

function ShortName(name: String): String;
begin
  ShortName:=Copy(name,Length(ExtractFilePath(name))+1,1000);
end;

{-------------------------------------------------------------------------}

// for sextupoles, the FULL INTEGRATED strength is used
function getkval (j: word; jpar: word): real;
var x: real;
begin
  with Ella[j] do begin
   case cod of
    cquad: x:=kq;
    csole: x:=ks;
    cbend: x:=kb;
    csext: begin if l=0 then x:=ms else x:=ms*l; end;
//    csext: x:=ms;
    ckick: x:=amp;
    cdrif: x:=l;
    ccomb: begin if jpar=1 then x:=cphi else x:=ckq; end;
    cmpol: x:=bnl;
//    cdeca: x:=sl;
    ccorh: x:=dxp*1000;
    ccorv: x:=dyp*1000;
    crota: x:=rot*degrad;
    else x:=0.0;
   end;
  end;
  getkval:=x;
end;

{-------------------------------------------------------------------------}

procedure putkval (k: real; j: word; jpar: word);
begin
  with Ella[j] do begin
   case cod of
    cquad: kq:=k;
    csole: ks:=k;
    cbend: kb:=k;
    csext: begin if l=0 then ms:=k else ms:=k/l; end;
//    csext: ms:=k;
    cdrif: l :=k;
    ckick: amp:=k;
    ccomb: begin if jpar=0 then ckq:=k else cphi:=k; end;
    cmpol: bnl:=k;
//    cdeca: sl:=k;
    ccorh: dxp:=k/1000;
    ccorv: dyp:=k/1000;
    crota: rot:=k*raddeg;
    else opalog(1,'PutKval - unknown element code!');
   end;
  end;
end;

{-------------------------------------------------------------------------}

// these function always return/accept the INTEGRATED sext strength of the SUB-sextupole
// of the element, i.e. the value depends on slicing
function getSexkval (j: word): real;
var x: real;
begin
  with Ella[j] do if cod =csext then begin
    if l=0 then x :=ms else x:=ms*l/sslice;
  end else if cod=ccomb then x:=cms*l/cslice;
  getSexkval:=x;
end;

procedure putSexkval (k: real; j: word);
begin
  with Ella[j] do if cod =csext then begin
    if l=0 then ms:=k else ms :=k/l*sslice;
  end else if cod=ccomb then cms:=k/l*cslice;
end;


{-------------------------------------------------------------------------}

function NameCheck(s: String): Boolean;
var
  f: boolean;
  i: integer;
begin
  f:=length(s)>0;
  if f then f:= s[1] in ValidCharacters;
  if f then
    for i:=1 to length(s) do f:=f and ((s[i] in ValidCharacters) or (s[i] in ValidNumbers));
  if not f then begin
 //     MessageBeep(mb_ok);
      MessageDlg('Invalid element/variable/segment name: '+s,mtError, [mbOK],0);
  end;
  NameCheck:=f;
end;

{-------------------------------------------------------------------------}

{construct linked list of characters}
function AppendChar(var a: CharBufpt; ch: Char): CharBufpt;
//appends a char to the text buffer
var
  b: CharBufpt;
begin
  New(b);
  a^.nex:=b;
  b^.ch:=ch;
  b^.nex:=nil;
  AppendChar:=b;
end;

{-------------------------------------------------------------------------}

{
//construct linked list of line-strings
function AppendLine(var a: LineBufpt; line: String): LineBufpt;
//appends a line to the line buffer
var
  b: LineBufpt;
begin
  New(b);
  a^.nex:=b;
  b^.line:=line;
  b^.nex:=nil;
  AppendLine:=b;
end;

function AppendText(var a: LineBufpt; text: String; cbrk: char; indent: integer): LineBufpt;
//breaks a text at character cbrk and appends it to the buffer line by line.
// indent all lines but first one by indent blanks.f

var
  ibrk, i: integer;
  t, sind, sind0: string;
begin
  sind:=''; sind0:='';
  for i:=0 to indent-1 do sind0:=sind0+' ';
  t:=WrapText(text,'|',[cbrk],78-indent);
  ibrk:=Pos('|',t);
  while ibrk>0 do begin
    a:=AppendLine(a, sind+Copy(t,1,ibrk-1));
    sind:=sind0;
    t:=Copy(t,ibrk+1,length(t));
    ibrk:=Pos('|',t);
  end;
  AppendText:=AppendLine(a,sind+t);
end;
}

{###### Access to elements and segments ##################################}

function AppendCurveN (var a: CurvePt; s, x, y, bxa, bxb, bya, byb, dx, dy, dxp, dyp,
      cdet, ba,bb, aa, ab, da,db: real): CurvePt;
var
  b: CurvePt;
begin
  New(b);
  a^.nex:=b;
  b^.spos:=s;
// quantities in normal mode space a,b (to be renamed)
  b^.beta:=ba;
  b^.betb:=bb;
  b^.alfa:=aa;
  b^.alfb:=ab;
  b^.disa:=da;
  b^.disb:=db;

  b^.xpos:=x;
  b^.ypos:=y;
// quantities in x,y space
  b^.betxa:=bxa;
  b^.betxb:=bxb;
  b^.betyb:=byb;
  b^.betya:=bya;
  b^.disx:=dx;
  b^.disy:=dy;
  b^.disxp:=dxp;
  b^.disyp:=dyp;

  b^.cdet:=cdet;
  b^.nex:=nil;
  AppendCurveN:=b;
  if CurvePlot.ncurve=0 then CurvePlot.ini:=b;
  Inc(CurvePlot.ncurve);
end;

procedure ClearCurve;
var
  a: CurvePt;
begin
  with CurvePlot do begin
    while ini<>nil do begin
      a:=ini;
      ini:=a^.nex;
      dispose(a);
    end;
  end;
  CurvePlot.ncurve:=0;
end;

{-------------------------------------------------------------------------}
function FindEl(ilattice:integer): integer;
begin
  Findel:=Lattice[ilattice].jel;
end;

{-------------------------------------------------------------------------}
procedure DeleteElem(name: ElemStr);
var
  i, j: word;
begin
  j:=0;
  for i:=1 to Glob.NElem do if name=elem[i].nam then j:=i;
  if j>0 then begin
    for i:=j to Glob.NElem-1 do elem[i]:=elem[i+1];
    Dec(Glob.NElem);
  end;
end;

{-------------------------------------------------------------------------}
function FindKind(ckind: integer): boolean;
var flag: boolean; j: integer;
begin
  j:=0; flag:=false;
  repeat
    Inc(j);
    flag:=flag or (elem[j].Cod=Ckind);
  until (j=Glob.NElem);
  FindKind:=flag;
end;

{------------------------------------------------------------------------}
function AppendAE(var a: AEpt; name: ElemStr): AEpt;
{appends an abstract element to the current segment}
var
  b: AEpt;
  fnd: boolean;
  j, imul, impos: word;
//  valerrcod: integer;
begin
  New(b);
  a^.nex:=b;
  b^.pre:=a;
  impos:=Pos('-',name);
  if impos>0 then begin
    name:=Copy(name,impos+1,length(name)-impos);
    b^.inv:=true;
  end
  else b^.inv:=false;
  imul:=Pos('*',name);
  if imul=0 then b^.rep:=1
  else begin
    Val(Copy(name,1,imul-1),b^.rep);
//    Val(Copy(name,1,imul-1),b^.rep,valerrcod);
    name:=Copy(name,imul+1,length(name));
  end;
  b^.nam:=name;
  fnd:=false; for j:=1 to Glob.NElem do fnd:=fnd or (name=Elem[j].nam);
  if fnd then b^.kin:=ele else b^.kin:=seg;
  b^.nex:=nil;
  AppendAE:=b;
end;

{---------------------------------------------------------------------------}
function Exist(nele, nseg: word; name: ElemStr): boolean;
var
  fnd: boolean;
  j: word;
begin
  fnd:=false;
  name:=Copy(name,Pos('*',name)+1, length(name));
  name:=Copy(name,Pos('-',name)+1, length(name));
  for j:=1 to nele do fnd:=fnd or (name=elem[j].nam);
  for j:=1 to nseg do fnd:=fnd or (name=segm[j].nam);
  if not fnd then begin
    ErrLogHandle.Lines.Append('LATTICE ERROR > element or segment '+name+' is undefined and will be skipped!');
  end;
  exist:=fnd;
end;




procedure ClearTextBuffer (var TextBuf: pointer);
var
  a: CharBufpt;
begin
  while TextBuf<>nil do begin
    a:=TextBuf;
    TextBuf:=a^.nex;
    dispose(a);
  end;
end;

{-----------------------------------------------------------------------}

procedure ClearSeg (iseg: word);
var
  a: AEpt;
begin
  with Segm[iseg] do begin
    while ini<>nil do begin
      a:=ini;
      ini:=a^.nex;
      dispose(a);
    end;
  end;
end;

{-----------------------------------------------------------------------}

procedure ClearSegAll;
var i: integer;
begin
  for i:=1 to Glob.NSegm do ClearSeg(i);
end;

{-----------------------------------------------------------------------}

function NAESeg(i:word; var ne, ns: word): word;
var
  n: word;
  x: AEpt;
begin
  x:=segm[i].ini;
  n:=0; ne:=0; ns:=0;
  repeat
    inc(n);
    if x^.kin=ele then inc(ne) else inc(ns);
    x:=x^.nex;
  until x=nil;
  NAESeg:=n;
end;

{-----------------------------------------------------------------------}

procedure IniElem (j: word);
var i: integer;
begin
  with elem[j] do begin
    l:=0.0; ax:=glob.ax; ay:=glob.ay; tag:=-1; rot:=0;
    l_exp:= nil; rot_exp:=nil;
    nl:=nil;  TypNam:='void';
    case cod of
      cdrif: block:=false;
      cquad: begin
               kq:=0;
               kq_exp:=nil;
             end;
      csole: ks:=0;
      csext: begin
               ms:=0; sslice:=1;
             end;
      cbend: begin
              kb:=0; phi:=0; tin:=0; tex:=0; gap:=0;
              k1in:=0; k1ex:=0; k2in:=0; k2ex:=0;
              kb_exp:=nil; phi_exp:=nil; tin_exp:=nil; tex_exp:=nil;
             end;
      cundu: begin
               lam:=0; bmax:=0; ugap:=1.0;
               // init undu with sinusoidal field params
               fill1:=2/pi; fill2:=0.5; fill3:=4/3/pi;
               halfu:=false;
             end;
      ckick: begin
               amp:=0;
               xoff:=0;
               mpol:=1;
               tau:=0;
               delay:=0;
               kslice:=1;
             end;
      csept: begin thk:=0; dis:=0; end;
      comrk: begin
               New(om);
               for i:=1 to 4 do begin
                 om^.bet[i]:=0.0; om^.eta[i]:=0.0; om^.orb[i]:=0.0;
               end;
               om^.bet[1]:=1.0; om^.bet[3]:=1.0; //om^.dpp:=0.0;
               om^.cma:=matnul2;
               screen:=false;
             end;
      ccomb: begin
               cphi:=0; cerin:=0; cerex:=0; cek1in:=0; cek1ex:=0; cgap:=0;
               ckq:=0; cms:=0; cslice:=1;
               cphi_exp:=nil; cerin_exp:=nil; cerex_exp:=nil; ckq_exp:=nil;
             end;
      cxmrk: begin xl:=20; nstyle:=0; snap:=0; end;
      cgird: begin gtyp:=0; shift:=0.0; end;
      cmpol: begin bnl:=0; lmpol:=0; nord:=1; end;
      ccorh: begin dxp:=0; ocox:=false; end;
      ccorv: begin dyp:=0; ocoy:=false; end;
      cmoni: ocom:=false;
    end;
  end;
end;

{-------------------------------------------------------------------}
function VariableToStr(i: integer): String;
var s: string;
begin
  with Variable[i] do begin
    s:='VAR '+ nam+' = ';
    if exp='' then s:=s+Ftos(val,10,4) else s:=s+exp;
  end;
  VariableToStr:=s;
end;

function ElemToStr (i: integer): String;
{short string representation of element}
var
  i8: integer;
  s: String;
begin
  s:= ElemShortName[elem[i].cod]+' '+ Elem[i].nam;
  for i8:=Length(Elem[i].nam)+1 to ElemStrLength do s:=s+' ';
  with elem[i] do case cod of
    cdrif: begin
             s:=s+' L  = ';
             if l_exp=nil then s:=s + FtoS(elem[i].l,5,2) else s:=s + l_exp^;
           end;
    cquad: begin
             s:=s+' Kq = ';
             if kq_exp=nil then s:=s + FToS(elem[i].kq, 5,2) else s:=s + kq_exp^;
           end;
    csole: begin
             s:=s+' Ks = '+FToS(elem[i].ks,5,2);
           end;
    csext: begin
             s:=s+' MS = '+FToS(elem[i].ms, 5,2);
           end;
    cbend: begin
             s:=s+' Ph = ';
             if phi_exp=nil then s:=s + FToS(elem[i].phi*degrad,6,3) else s:=s + phi_exp^;
           end;
    cundu: begin
             s:=s+' Lb = '+FtoS(1000*elem[i].lam, 5,1);
           end;
    ckick: begin
             s:=s+' K = '+FToS(elem[i].amp, 8,3);
           end;
    csept: begin
             s:=s+' Ds = '+FtoS(elem[i].dis, 4,1);
           end;
    comrk: begin
           end;
    ccomb: begin
            s:=s+' Ph = ';
            if cphi_exp=nil then s:=s +FToS(elem[i].cphi*degrad,6,3) else s:=s + cphi_exp^;
           end;
    cxmrk: begin
             s:=s+' Lx = '+FtoS(elem[i].xl, 5,1)+' m';
           end;
    cgird: begin
             s:=s+' typ = '+inttostr(elem[i].gtyp);
           end;
    cmpol: begin
             s:=s+' K = '+FToSv(elem[i].bnl, 8,3 );
           end;
    ccorh: begin
             s:=s+' dxp  = '+ FtoS(elem[i].dxp*1000,7,3);
           end;
    ccorv: begin
             s:=s+' dyp  = '+ FtoS(elem[i].dyp*1000,7,3);
           end;
  end;
  ElemToStr:=s;
end;

{-----------------------------------------------------------------------}

function SegmToStr(i: integer): string;
var
   s: string;
   ne, ns {, dummy}: word;
begin
  s:=segm[i].nam+' ';
  ne:=0; ns:=0;
  NAESeg(i,ne,ns);
//  dummy:=NAESeg(i,ne,ns);
  s:=s+'('+ IntToStr(ne)+'/'+IntToStr(ns)+')';
  SegmToStr:=s;
end;

{-----------------------------------------------------------------------}
procedure GirderSetup;
const
  seps=1e-6;
var
  giropen, ismag, iskip, errenable: boolean;
  s0, s1, s2, dangle, angle, circ {, x0, x1, y0, y1}: real;
  i0, ic, i, j, countmag, ilastmag: integer;
begin
// allocate the girders (if any)
// also enter mid pos and angle in lattice structure
  circ:=0; angle:=0; giropen:=false;  girder:=nil;
//  x0:=0; y0:=0;
  for i:=1 to Glob.NLatt do begin
    Lattice[i].igir:=-1;
    Lattice[i].misal:=false;
    Lattice[i].misamp:=1.0;
    j:=findel(i);
    with Ella[j] do begin
      circ:=circ+l;
      case cod of
        cbend: dangle:= phi;
        ccomb: dangle:=cphi;
        else dangle:=0.0;
      end;
{      if dangle=0 then begin
        x1:=x0+l*cos(angle);
        y1:=y0+l*sin(angle);
      end else begin
        rho:=l/dangle;
        x1:=x0+rho*(sin(angle+dangle)-sin(angle));
        y1:=y0-rho*(cos(angle+dangle)-cos(angle));
      end;
}
      angle:=angle+dangle;
    end;

    if (Ella[j].cod = cgird) and (Ella[j].gtyp <= 1) then begin
        if giropen then begin
// if girder is open, close it, assign data to endpoint [1]
          giropen:=false;
          with girder[High(girder)] do begin
            gco[1]:=Ella[j].gtyp;
            gshft[1]:=Ella[j].shift;
            gsp[1]:=circ;  gang[1]:=angle;
            ilat[1]:=i;
//            gxpos[1]:=x1; gypos[1]:=y1;
          end;
        end else begin
// if girder is not open, open a new girder, assign data to startpoint [0]
          setlength(girder, length(girder)+1);
          giropen:=true;
          with girder[High(girder)] do begin
            gdx[0]:=0; gdx[1]:=0; gdy[0]:=0; gdy[1]:=0; gdt:=0;
            gco[0]:=Ella[j].gtyp;
            gshft[0]:=Ella[j].shift;
            gsp[0]:=circ;  gang[0]:=angle;
            ilat[0]:=i;
//            gxpos[0]:=x1; gypos[0]:=y1;
            igir[0]:=-1; igir[1]:=-1;
            level:=1;
          end;
        end;
    end; //girder
    Lattice[i].smid  :=circ-Ella[j].l/2;
    Lattice[i].angmid:=angle-dangle/2;
  end;//for

  for i:=0 to High(Girder) do with Girder[i] do begin
    for ic:=ilat[0] to ilat[1] do Lattice[ic].igir:=i;
  end;

  NGirderLevel[1]:=Length(Girder);

// find compounds, i.e. elements which are to be treated as one block w.r.t. misalignment
// two types: bracketed by girder type 2,3 or series of magnets w/o space between.
//   first select all compound elements, defined by bracket of type 2,3 girders:

  s1:=0; s2:=0;
  for i:=1 to Glob.NLatt do begin
    j:=findel(i);
    s2:=s1+Ella[j].l;

    if (Ella[j].cod = cgird) and (Ella[j].gtyp >=2) then begin
      if giropen then begin
// if compound is open, close it:
        giropen:=false;
        with Girder[High(Girder)]do begin
          gsp[1]:=s2;
          gshft[1]:=0;
          ilat[1]:=i;
          igir[1]:=Lattice[i].igir; //? needed?
        end;
      end else begin
// if compound is not open, open a new one:
        setlength(Girder, length(Girder)+1);
        giropen:=true;
        with Girder[High(Girder)] do begin
          gsp[0]:=s2;
          gshft[0]:=0;
          ilat[0]:=i;
          igir[0]:=Lattice[i].igir; //? needed?
          level:=2;
        end;
      end;
    end;
    s1:=s2;
  end;//for

  for i:=NGirderLevel[1] to High(Girder) do with Girder[i] do begin
    for ic:=ilat[0] to ilat[1] do Lattice[ic].igir:=i;
  end;
  NGirderLevel[2]:=Length(Girder);

// make a compound element if we have a series of magnets with no gap between, i.e. sext|ch|cv|sext
  s0:=0; s1:=0; s2:=0; i0:=0;
  ilastmag:=-1;
  giropen:=false;
  countmag:=0;
  for i:=1 to Glob.NLatt do begin
    j:=findel(i);
    s2:=s1+Ella[j].l;
    ismag:= (Ella[j].cod in [Cquad,Cbend,Csext,Csole,Cundu,Csept,Ckick,Ccomb,Cmpol,Ccorh,Ccorv]);
    iskip:= (abs(Ella[j].l)<seps); // and not (Ella[j].cod=cgird);
    if giropen then begin
      // keep s0, was set when merging started
      if (ismag or iskip) then begin //continue merge
        if ismag then begin
          Inc(countmag);
          ilastmag:=i;      // remember lattice index of last multipole appended
        end;
      end else begin // stop merge, create new compound if we got more than one multipole
 //       if (((s2-s0)>seps) and (i>i0+1)) then begin
        if (countmag > 1) then begin
          setlength(Girder, length(Girder)+1);
          with Girder[High(Girder)] do begin
            gsp[0]:=s0;
            ilat[0]:=i0;
            igir[0]:=Lattice[i0].igir;
            gsp[1]:=s1;
            ilat[1]:=ilastmag; //i-1;
            igir[1]:=Lattice[ilastmag].igir; //i-1].igir;
            gshft[0]:=0; gshft[1]:=0;
            level:=3;
          end;
        end;
        countmag:=0;
        giropen:=false;
      end;
    end else begin
      if ismag then begin
        giropen:=true; //start collecing for a new compound
        countmag:=1;
        s0:=s1; i0:=i;
      end;
    end;

    s1:=s2;
  end;//for

  for i:=NGirderLevel[2] to High(Girder) do with Girder[i] do begin
    for ic:=ilat[0] to ilat[1] do Lattice[ic].igir:=i;
  end;

  NGirderLevel[3]:=Length(Girder);

  errenable:=true;
  for i:=1 to Glob.NLatt do begin
    j:=findel(i);
    errenable:=errenable xor ((Ella[j].cod = cmark) and (Ella[j].nam=nomisal_markername));
    if not(Ella[j].cod in Cmisalign) then begin
      Lattice[i].misal:=false;
      Lattice[i].igir:=-1;
    end else begin
      Lattice[i].misal:=true;
      if not errenable then Lattice[i].misamp:=0.0;
    end;
  end;


//  if true then begin
  if diag(3) then begin
    writeln(diagfil,'# Girder Setup ############################################################');
    writeln(diagfil,'#Name of girder (generated)');
    writeln(diagfil,'#type : 1 primary, 2 secondary, 3 container');
    writeln(diagfil,'#supporting girder[2] : -1 for primary girder / supporting girder number for secondary');
    writeln(diagfil,'#termination type[2]: 0 monument, 1 link to previous, 2,3 2-point and 3-point support');
    writeln(diagfil,'#sposition[2]: start/end');
    writeln(diagfil,'#lattice element[2]: start/end'); writeln(diagfil,'#');
    if girder<>nil then begin
      for i:=0 to High(girder) do with Girder[i] do writeln(diagfil,'gir',i,' ',level,' ', igir[0],' ',igir[1],' ',gco[0],' ',gco[1],' ',gsp[0],' ',gsp[1], ' ',ilat[0],' ', ilat[1]);
    end;
    for i:=1 to Glob.NLatt do begin
      with lattice[i] do begin
        if igir> -1          then writeln(diagfil, 'pos',i,' ',elnam,' GIR ', igir:4, ' lev ',Girder[igir].level) else
                                  writeln(diagfil, 'pos',i,' ',elnam,' --- ----');
      end
    end;
  end;


end;

{----------------------------------------------------------------------}

procedure MakeLattice (var success: boolean);
{circular reference check:
 the segment index (imaster) is appended to istack if seglat calls
 itself for the next level. there it checks the stack if it contains
 already the next segment. this would be a circular reference.
 when seglat returns to the previous level, the imaster is removed.
 so the stack contains always seglat's recursive calling sequence.
 as-060808
}

var
  fnd, invmod: boolean;
  il, i, j, ji: word;
  nch, ncv, nbpm, ncs, nqa, NElla0: integer;
  SegLatFail: byte;
  istack, elemindex: array of integer;
  imaster: integer;
  np: NameListpt;

  function getNewName(var n: integer; basname: String): ElemStr;
// find a new name like CH001, which does NOT yet exist
  var sn: ElemStr; k:integer; fnd:boolean;
  begin
    repeat
      Inc(n);
      sn:=basname+copy(inttostr(1000+n),2,3);
      fnd:=false;
      for k:=1 to Glob.NElem do fnd:=fnd or (Elem[k].nam = sn);
    until not fnd;
    getNewName:=sn;
  end;


  procedure SegStack_in (i:integer);
  begin
    setlength(istack,length(istack)+1);
    istack[high(istack)]:=i;
  end;

  procedure SegStack_out;
  begin
    setlength(istack,high(istack));
  end;

  function Segstack_Show(ic: integer): string;
  var i: integer; s: string;
  begin
    s:=' ';
//    for i:=0 to ic-1 do s:=s+'('+Segm[istack[i]].nam+') ';
    for i:=ic to High(istack) do s:=s+Segm[istack[i]].nam+' -> ';
    SegStack_show:=s;
  end;

{.....................................................................}

  procedure SegLat (ae: AEpt);
    {Expands the lattice from the active segment by recursive call:
     proceeds forward or backwards along segment starting from ini or fin
     terminates list when .pre or .nex of AEpt is nil
     checks for undefinded segments in order to avoid system crashes from
     undefined pointers - but this should never happen.
     thanks to Johan Bengtsson for the recursive call concept!}

  var
    name: ElemStr;
    i, irep, iam, its, icirc: integer;
    fnd, locinv: boolean;
  begin
    iam:=imaster;  // I am the master, i.e. the calling segment
    locinv:=invmod;
    while (ae<>nil) and (SegLatFail=0)do begin
      name:=ae^.nam;
      for irep:=1 to ae^.rep do begin
         if ae^.kin=ele then begin
          if Glob.NLatt<NLattmax then begin
            setlength(Lattice, length(Lattice)+1);
            Glob.NLatt:=High(Lattice);
            with Lattice[Glob.NLatt] do begin
              elnam:=name;
              if locinv xor ae^.inv then inv:=-1 else inv:= 1;
            end;
          end
          else SegLatFail:=2;
        end
        else begin
          i:=0;
          fnd:=false; {warum war das auskommentiert?}
          repeat
            Inc(i);
            fnd:=(Segm[i].nam=name);
          until fnd or (i=Glob.NSegm);
          if fnd then begin
          // check for circular reference
            icirc:=-1;
            for its:=High(istack) downto 0 do if (istack[its]=i) then icirc:=its;
            if icirc >= 0 then begin
              SegLatFail:=3;
//              ErrLogHandle.Lines.Append('LATTICE ERROR > circular reference for segments '+
              OpaLog(1,'Lattice: circular reference for segments '+
                SegStack_show(icirc)+Segm[iam].nam);
            end else begin
              invmod:=locinv xor ae^.inv;
              imaster:=i;  //the next segment will become the master
              SegStack_in(iam);  // add ME (the present master) to istack
              if invmod then SegLat(Segm[i].fin) else SegLat(Segm[i].ini); // recursive call
              SegStack_out;  // remove ME from istack
            end;
          end  else begin
            SegLatFail:=1;
            opalog(1,'Lattice: undefinded entry '+name+' in segment '+Segm[iam].nam);
//            ErrLogHandle.Lines.Append('LATTICE ERROR > undefinded entry '+name+' in segment '+Segm[iam].nam);
          end;
        end;

      end;
      if locinv then ae:=ae^.pre else ae:=ae^.nex;
    end;
  end;

{.....................................................................}

begin
  if Glob.Nsegm>0 then begin
    iactseg:=0;
    repeat inc(iactseg)
    until (actseg^.nam=segm[iactseg].nam) or (iactseg>=glob.nsegm);
    if iactseg>0 then begin
      ActSeg^.nam:=Segm[iactseg].nam;
      ActSeg^.kin:=seg;
      ActSeg^.nex:=Segm[iactseg].ini;
      Glob.NLatt:=0;
      Lattice:=nil;
      setlength(Lattice,1); // historical, 0 never used
      Glob.Nper:=Segm[iactseg].nper;
      SegLatFail:=0;
      InvMod:=False;
      istack:=nil;
      imaster:=iactseg;  //the active segment is the first master
      SegLat(ActSeg^.nex);
      if SegLatFail>0 then begin
//        if SegLatFail=2 then ErrLogHandle.Lines.Append('LATTICE ERROR > too many elements (max.'+IntToStr(NLattMax)+') OR circular segment reference!');
//        ErrLogHandle.Lines.Append('Lattice expansion failed.');
        if SegLatFail=2 then OpaLog(1,'Lattice: too many elements (max.'+IntToStr(NLattMax)+') OR circular segment reference!');
        OpaLog(1,'Lattice expansion failed.');
        {output this message here, in seglat it would come many times}
        Glob.NLatt:=0;
      end
      else begin
// built the table uf USED elements, Ella as subset of ALL elements, Elem
        Glob.NElla:=0;
        setlength(elemindex,Glob.NElem+1); //counting from 1 like Ella
        for i:=1 to glob.nelem do begin
          fnd:=false;
          il:=0;
          repeat
            Inc(il);
            fnd:= (Lattice[il].elnam=elem[i].nam);
          until fnd or (il=glob.nlatt);
          if fnd then begin
            Inc(Glob.NElla);  Ella[Glob.NElla]:=Elem[i];
            elemindex[Glob.NElla]:=i;
// copy copies also the pointer variable %_exp, so the string, where the pointer is pointing to, is the same!
// in order to become independent, a new pointer would have to be created for Ella and the string copied.
// but changing expressions should be reserved to Elem only in Editor.
// save original elem index?
          end;
        end;
      end;
      success:=Glob.NLatt>0;
      istack:=nil;
    end
    else success:=false;
  end
  else begin
//    ErrLogHandle.Lines.Append('LATTICE ERROR > there are no segments to build a lattice !');
    OpaLog(1,'There no segments to build a lattice !');
    success:=false;
  end;

  status.periodic :=false;
  status.symmetric:=false;
  status.betas:=false;
  status.tuneshifts:=false;
  status.chromas:=false;
  status.alphas:=false;
  status.rfaccept:=false;
  status.flopoly:=false;

  for i:=0 to nStatusLabels-1 do setStatusLabel(i,status_void);

  if success then begin

  // find the Ella by name and save its index (has historical roots...)
    for i:=1 to Glob.NLatt do begin
      j:=0;
      repeat Inc(j); until Ella[j].nam = Lattice[i].elnam;
      Lattice[i].jel:=j;
    end;

 { check for potentially coupling elments. This is the case if there are
   - element rotations (i.e. V-bend, skew quad), or
   - explicit rotations [may be edited in optics design], or
   - solenoids
 }
  status.uncoupled:=true;
  for i:=1 to Glob.NLatt do begin
    with Ella[Lattice[i].jel] do begin
      if (rot<>0) or (cod = crota) or (cod = csole) then status.uncoupled:=false;
    end;
  end;


{for a given lattice, successfully created, the element of family with protected
 names as defined by oco_chname, oco_cvname are expanded to individual elements
 to address them separately in orbit correction}

{ give Ella Names as real names if available:}
    nch:=0; ncv:=0; nbpm:=0; ncs:=0; nqa:=0;
    Nella0:=Glob.NElla;
    for j:=1 to Nella0 do begin

      if Ella[j].cod=ckick then status.Kickers:=true;

      if (Ella[j].cod=cmoni) then begin
        status.Monitors:=true;
        if (Ella[j].nam=oco_bpmname) then begin
          np:=Elem[elemindex[j]].nl;
          for i:=1 to Glob.NLatt do begin
            ji:=findel(i);
            if ji=j then begin
              if np<> nil then begin
                Lattice[i].elnam:=np.realname;
                np:=np^.nex;
              end else Lattice[i].elnam:=getNewName(nbpm, oco_bpmname);
              Inc(Glob.Nella); Ella[Glob.Nella]:=Ella[j];
              Ella[Glob.Nella].nam:=Lattice[i].elnam;
              Ella[Glob.Nella].ocom:=true;
              Ella[Glob.Nella].nl:=nil; // remove namelist to force use of ella name
              Lattice[i].jel:=Glob.NElla;
            end;
          end;
        end;
      end;

      if (Ella[j].cod = ccorh) and (Ella[j].nam=oco_chname) then begin
        np:=Elem[elemindex[j]].nl;
        for i:=1 to Glob.NLatt do begin
          ji:=findel(i);
          if ji=j then begin
            if np<> nil then begin
              Lattice[i].elnam:=np.realname;
              np:=np^.nex;
            end else Lattice[i].elnam:=getNewName(nch, oco_chname);
            Inc(Glob.Nella); Ella[Glob.Nella]:=Ella[j];
            Ella[Glob.Nella].nam:=Lattice[i].elnam;
            Ella[Glob.Nella].ocox:=true;
            Ella[Glob.Nella].nl:=nil; // remove namelist to force use of ella name
            Lattice[i].jel:=Glob.NElla;
          end;
        end;
      end;

      if (Ella[j].cod = ccorv) and (Ella[j].nam=oco_cvname) then begin
        np:=Elem[elemindex[j]].nl;
        for i:=1 to Glob.NLatt do begin
          ji:=findel(i);
          if ji=j then begin
            if np<> nil then begin
              Lattice[i].elnam:=np.realname;
              np:=np^.nex;
            end else Lattice[i].elnam:=getNewName(ncv, oco_cvname);
            Inc(Glob.Nella); Ella[Glob.Nella]:=Ella[j];
            Ella[Glob.Nella].nam:=Lattice[i].elnam;
            Ella[Glob.Nella].ocoy:=true;
            Ella[Glob.Nella].nl:=nil; // remove namelist to force use of ella name
            Lattice[i].jel:=Glob.NElla;
          end;
        end;
      end;

      if (Ella[j].cod = cquad) and (Ella[j].nam=oco_csname) then begin
        np:=Elem[elemindex[j]].nl;
        for i:=1 to Glob.NLatt do begin
          ji:=findel(i);
          if ji=j then begin
            if np<> nil then begin
              Lattice[i].elnam:=np.realname;
              np:=np^.nex;
            end else Lattice[i].elnam:=getNewName(ncs, oco_csname);
            Inc(Glob.Nella); Ella[Glob.Nella]:=Ella[j];
            Ella[Glob.Nella].nam:=Lattice[i].elnam;
//          Ella[Glob.Nella].ocoy:=true;
            Ella[Glob.Nella].nl:=nil; // remove namelist to force use of ella name
            Lattice[i].jel:=Glob.NElla;
          end;
        end;
      end;

      if (Ella[j].cod = cquad) and (Ella[j].nam=oco_qaname) then begin
        np:=Elem[elemindex[j]].nl;
        for i:=1 to Glob.NLatt do begin
          ji:=findel(i);
          if ji=j then begin
            if np<> nil then begin
              Lattice[i].elnam:=np.realname;
              np:=np^.nex;
            end else Lattice[i].elnam:=getNewName(nqa, oco_qaname);
            Inc(Glob.Nella); Ella[Glob.Nella]:=Ella[j];
            Ella[Glob.Nella].nam:=Lattice[i].elnam;
//          Ella[Glob.Nella].ocoy:=true;
            Ella[Glob.Nella].nl:=nil; // remove namelist to force use of ella name
            Lattice[i].jel:=Glob.NElla;
          end;
        end;
      end;
    end;

    for i:=1 to Glob.NLatt do begin
      with Lattice[i] do begin
        dx:=0; dy:=0; dt:=0;
      end;
    end;

  //  GirderSetup;     // why do this here? --> should be done in opaorbit!

  end; //success to expand lattice

  if status.lattice then begin
    if not status.uncoupled then setStatusLabel(stlab_cop,status_light) else setStatusLabel(stlab_cop,status_off);
    if status.kickers then setStatusLabel(stlab_kik,status_light) else setStatusLabel(stlab_kik,status_off);
    setStatusLabel(stlab_mis,status_off);
    setStatusLabel(stlab_cor,status_off);
    //undulators, monitors
  end;


end;

//---------------------------------------------------------------

procedure ShowLattice (log: TMemo);
var
  i, ilin, irow: word;
  s: string;
begin
  log.clear;
  log.Lines.Append('--------------------------------------------------------');
  log.Lines.Append('Expanded Lattice structure: ');
  ilin:=0; irow:=0;
  s:='';
  for i:=1 to Glob.NLatt do begin
    if Lattice[i].inv<0 then s:=s+' -' else s:=s+' ';
    s:=s+Lattice[i].elnam;
//    for i8:=length(Latt[i]) to ElemStrLength-1 do s:=s+' ';
    inc(irow); if irow=ElemStrLength then begin
//      ErrLogHandle.Lines.Append(s); s:='';
      irow:=0;
      inc(ilin);
    end;
  end;
  log.Lines.Append(s);
  log.Lines.Append('--- ('+inttostr(glob.nlatt)+' elements) ---------------------------');
end;


{####### Global initialization ###########################################}

{-------------------------------------------------------------------------}
Procedure OPAInit;
//initialize settings which are never changed in execution

begin                         { Initial settings of global variables:     }

  Ln10        := Ln(10);
  degrad      :=180/Pi;
  raddeg      :=Pi/180;
  Erad_factor :=electron_charge*Sqr(speed_of_light)*2E-7/3.*sqr(sqr(1E9/electron_mc2));
  //energy loss factor [eV]  = e/6pi/eps0/(mc2/e)[GeV]^4; eps0=1/c^2/mu0; mu0 = 4pi E-7
  Ecrit_factor:=3E18*planck_constant*sqr(speed_of_light)/4/Pi/electron_charge*PowI(1./electron_mc2,3);
  //critical energy factor [eV]  = 3hc^2/4/Pi/e*(1/(mc2/e))^3
  RadCq_factor:=55E18*planck_constant*speed_of_light/(64*Pi*sqrt(3)*PowI(electron_mc2,3)*electron_charge);
  //factor for radiation equilibrium, emittance and espread Cq [m] =  55 h/2pi c e /(32 sqrt3 (mc2/e)^3)
  Unit_Matrix_5:=MatUni5;

// gehoert nicht hier hin:
// mix colors for off energy beta curves
// dp<0 cool color
  betax_col_m:=Dimcol(betax_col,clFuchsia,0.5);
  betay_col_m:=Dimcol(betay_col,clFuchsia,0.5);
  dispx_col_m:=Dimcol(dispx_col,clAqua   ,0.6);
  dispy_col_m:=Dimcol(dispy_col,clAqua   ,0.6);
// dp> 0 warm color
  betax_col_p:=Dimcol(betax_col,clAqua   ,0.5);
  betay_col_p:=Dimcol(betay_col,clYellow ,0.4);
  dispx_col_p:=Dimcol(dispx_col,clYellow ,0.5);
  dispy_col_p:=Dimcol(dispy_col,clYellow ,0.5);
end;

{--------------------------------------------------------------------------}
procedure GlobInit;
//initialize settings which are to be reset for a new file
begin
  UseSext    :=False;              {              Sextupoles not used.   }
  UsePulsed  :=False;              {    pulsed elements not used.   }
  Glob.NElem :=0;                  { Initial values for the lattice      }
  Glob.NElla :=0;
  Glob.NSegm :=0;
  Glob.NLatt :=0;                  {   record variable                   }
  Glob.NPer  :=1;
  Glob.Text :='';
  with Glob.Op0 do begin
//    betx:=1; alfx:=0; bety:=1; alfy:=0;
    beta:=1; alfa:=0; betb:=1; alfb:=0;
    disx:=0; dipx:=0; disy:=0; dipy:=0;
//    disa:=0; dipa:=0; disb:=0; dipb:=0;
    {phix:=0; phiy:=0; } phia:=0; phib:=0;
    cmat:=MatNul2;
  end;
  Glob.OpE:=Glob.Op0;
  Glob.dPP   := 0.0;
  Glob.rot_inv:=false;

{
  Glob.Beta0[1]:=1; Glob.Beta0[2]:=0;
  Glob.Beta0[3]:=1; Glob.Beta0[4]:=0;
  for i:=1 to 4 do Glob.Eta0[i] :=0;
  for i:=1 to 4 do Glob.Orbit0[i]:=0.0;
  Glob.EtaE  :=Glob.Eta0;
  Glob.BetaE :=Glob.Beta0;
  Glob.OrbitE:=Glob.Orbit0;
}

  Glob.Energy:=1.0;
  Glob.Ax:=50.0; Glob.Ay:=50.0;
  IActSeg:=0;             {active segment undefined}
// ? brauchts das ?
  New(ActSeg);
  ActSeg^.nam:=' ';
  ActSeg^.kin:=seg;
  ActSeg^.nex:=nil;
  Variable:=nil;
  Status.Elements  :=False;
  Status.Segments  :=False;
  Status.Undulators:=False;
  Status.Lattice   :=False;
  Status.Betas     :=False;
  Status.Periodic  :=False;
  Status.Symmetric :=False;
  Status.Tuneshifts:=False;
  Status.Chromas   :=False;
  Status.Currents  :=False;
  Status.Circular  :=False;
  Status.Tmatrix   :=False;
  Status.Cmatrix   :=False;
  Status.Alphas    :=False;
  Status.RFaccept  :=False;
  Status.FloPoly   :=False;
  CurvePlot.enable :=False;
  allocationFlag   :=False;
  calibrationFlag  :=False;
end;

{###### Colors, Sound, Time, Frames, etc.#################################}


{########################################################################}

// (private) find a Default element by Name
function DefFindEl(s: string): integer;
var idef, i: integer;
begin
  idef:=-1;
  for i:=0 to High(Def) do begin
    if s=Def[i].nam then idef:=i;
  end;
  DefFindEl:=idef;
end;

{..........................................................................................}

// (private) initialize a default element, all fields
procedure DefIniSet(s: string;  x: real);
begin
  setlength(Def,length(Def)+1);
  with Def[High(Def)] do begin
    nam  :=s;
    val  :=x;
  end;
end;

{... same for global defaults---------------------}
function GlobDefFindEl(s: string): integer;
var i: integer;
begin
  for i:=0 to High(GlobDef) do if s=GlobDef[i].nam then GlobDefFindEl:=i;
end;

procedure GlobDefIniSet(s: string;  x: real);
begin
  setlength(GlobDef,length(GlobDef)+1);
  with GlobDef[High(GlobDef)] do begin
    nam  :=s; val  :=x;
  end;
end;

{..........................................................................................}

// (create) initialize all defaults to OPA-hardwired values
procedure DefInitAll;
var
  i, j: integer;
begin
  Def:=nil;
  DefIniSet('optic/width', 0.0);
  DefIniSet('optic/height',0.0);
  DefIniSet('optic/left', -1.0);
  DefIniSet('optic/top',  -1.0);
  DefIniSet('optic/dpmult',1.0); //dp/p in %

  DefIniSet('envel/erat',  10.0);//%
  DefIniSet('envel/emix',  1.0); //nm
  DefIniSet('envel/emiy',  1.0); //nm
  DefIniSet('envel/sdpp',  1.0); //%
  DefIniSet('envel/rref', 25.0); //mm
  DefIniSet('envel/bfix', 20.0); //m
  DefIniSet('envel/dfix',  0.5); //m
  DefIniSet('envel/bmax',  2.0); //T
  DefIniSet('envel/bmin',  0.0); //T

  DefIniSet('chrom/kmax', 10.0);
  DefIniSet('chrom/kstp',  0.01);
  DefIniSet('chrom/omax', 100.0);
  DefIniSet('chrom/ostp',  0.1);
  DefIniSet('chrom/dmax', 1000.0);
  DefIniSet('chrom/dstp',  1.0);
  DefIniSet('chrom/2jx' , 30.0);
  DefIniSet('chrom/2jy' , 30.0);
  DefIniSet('chrom/dpp' ,  3.0);
  DefIniSet('chrom/rfac' , 4.0);
  DefIniSet('chrom/dpnd', 0.001);
  DefIniSet('chrom/mamp',  1.0);
  DefIniSet('chrom/tarc1x',  0.0);
  DefIniSet('chrom/tarc1y',  0.0);
  DefIniSet('chrom/tarc2x',  0.0);
  DefIniSet('chrom/tarc2y',  0.0);
  DefIniSet('chrom/tarc3x',  0.0);
  DefIniSet('chrom/tarc3y',  0.0);
  DefIniSet('chrom/tarqxx',  0.0);
  DefIniSet('chrom/tarqxy',  0.0);
  DefIniSet('chrom/tarqyy',  0.0);
  for i:=0 to  1 do DefIniSet('chrom/hw'+Copy(InttoStr(i+100),2,2),0.0);
  for i:=2 to 25 do DefIniSet('chrom/hw'+Copy(InttoStr(i+100),2,2),1.0);
  DefIniSet('chrom/inc2q' , 1.0);
  DefIniSet('chrom/incqxx', 1.0);
  DefIniSet('chrom/inccr2', 0.0);
  DefIniSet('chrom/incoct', 0.0);
  DefIniSet('chrom/inccom', 1.0);
  DefIniSet('match/'+MatchFuncName[ 1], 1.0);
  DefIniSet('match/'+MatchFuncName[ 2], 0.0);
  DefIniSet('match/'+MatchFuncName[ 3], 1.0);
  DefIniSet('match/'+MatchFuncName[ 4], 0.0);
  DefIniSet('match/'+MatchFuncName[ 5], 0.0);
  DefIniSet('match/'+MatchFuncName[ 6], 0.0);
  DefIniSet('match/'+MatchFuncName[ 7], 0.0);
  DefIniSet('match/'+MatchFuncName[ 8], 0.0);
  DefIniSet('match/'+MatchFuncName[ 9], 0.0);
  DefIniSet('match/'+MatchFuncName[10], 0.0);
  DefIniSet('match/'+MatchFuncName[11], 1.0);
  DefIniSet('match/'+MatchFuncName[12], 0.0);
  DefIniSet('match/'+MatchFuncName[13], 1.0);
  DefIniSet('match/'+MatchFuncName[14], 0.0);
  DefIniSet('match/'+MatchFuncName[15], 0.0);
  DefIniSet('match/'+MatchFuncName[16], 0.0);
  DefIniSet('match/'+MatchFuncName[17], 0.0);
  DefIniSet('match/'+MatchFuncName[18], 0.0);
  DefIniSet('match/c'+MatchFuncName[ 1], 1.0);
  DefIniSet('match/c'+MatchFuncName[ 2], 0.0);
  DefIniSet('match/c'+MatchFuncName[ 3], 1.0);
  DefIniSet('match/c'+MatchFuncName[ 4], 0.0);
  DefIniSet('match/c'+MatchFuncName[ 5], 0.0);
  DefIniSet('match/c'+MatchFuncName[ 6], 0.0);
  DefIniSet('match/c'+MatchFuncName[ 7], 0.0);
  DefIniSet('match/c'+MatchFuncName[ 8], 0.0);
  DefIniSet('match/c'+MatchFuncName[ 9], 0.0);
  DefIniSet('match/c'+MatchFuncName[10], 0.0);
  DefIniSet('match/c'+MatchFuncName[11], 1.0);
  DefIniSet('match/c'+MatchFuncName[12], 0.0);
  DefIniSet('match/c'+MatchFuncName[13], 1.0);
  DefIniSet('match/c'+MatchFuncName[14], 0.0);
  DefIniSet('match/c'+MatchFuncName[15], 0.0);
  DefIniSet('match/c'+MatchFuncName[16], 0.0);
  DefIniSet('match/c'+MatchFuncName[17], 0.0);
  DefIniSet('match/c'+MatchFuncName[18], 0.0);
  for i:=1 to 20 do DefIniSet('match/kn_'+inttostr(i),  0);
  DefIniSet('match/iini',  0);
  DefIniSet('match/imat',  1);
  DefIniSet('match/imid',  0);
  DefIniSet('match/step',  200.0);
  DefIniSet('match/prec',  1E-6);
  DefIniSet('match/frac',  1.0);

  DefIniSet('trackp/texp',3);
  DefIniSet('trackp/delq',0.05);
  DefIniSet('trackp/dthr',1e-7);
  DefIniSet('trackp/pid',0.001);
  DefIniSet('trackp/relf',1E-6);

  DefIniSet('tshift/range',3.0);
  DefIniSet('tshift/steps',50.0);
  DefIniSet('tshift/lef',0);
  DefIniSet('tshift/top',0);
  DefIniSet('tshift/wid',0);
  DefIniSet('tshift/hei',0);
  DefIniSet('tshift/nford',2.0);
  DefIniSet('tshift/pmode',0);
  DefIniSet('tshift/tmode',0);

  //tmom: set defaults for fit coefficients for some parameters one
  //perhaps would like to fit to <>0 in opamomentum
  for j:=1 to nMomFit_param do for i:=1 to nMomFit_order do
    DefIniSet('tmom/'+MomFit_param[j]+Inttostr(i),0.0);

  DefIniSet('tgeom/lef',0);
  DefIniSet('tgeom/top',0);
  DefIniSet('tgeom/wid',0);
  DefIniSet('tgeom/hei',0);
  DefIniSet('tgeom/leng',0.0);
  DefIniSet('tgeom/xini',0.0);
  DefIniSet('tgeom/yini',0.0);
  DefIniSet('tgeom/zini',0.0);
  DefIniSet('tgeom/anzi',0.0);
  DefIniSet('tgeom/anxi',0.0);
  DefIniSet('tgeom/ansi',0.0);
  DefIniSet('tgeom/xfin',0.0);
  DefIniSet('tgeom/yfin',0.0);
  DefIniSet('tgeom/zfin',0.0);
  DefIniSet('tgeom/anzf',0.0);
  DefIniSet('tgeom/anxf',0.0);
  DefIniSet('tgeom/ansf',0.0);
  DefIniSet('tgeom/lengg',0.0);
  DefIniSet('tgeom/xinig',0.0);
  DefIniSet('tgeom/yinig',0.0);
  DefIniSet('tgeom/zinig',0.0);
  DefIniSet('tgeom/anzig',0.0);
  DefIniSet('tgeom/anxig',0.0);
  DefIniSet('tgeom/ansig',0.0);
  DefIniSet('tgeom/xfing',0.0);
  DefIniSet('tgeom/yfing',0.0);
  DefIniSet('tgeom/zfing',0.0);
  DefIniSet('tgeom/anzfg',0.0);
  DefIniSet('tgeom/anxfg',0.0);
  DefIniSet('tgeom/ansfg',0.0);
  DefIniSet('tgeom/beyw',0.5);
  DefIniSet('tgeom/quyw',0.7);
  DefIniSet('tgeom/mpyw',0.6);
  DefIniSet('tgeom/mpyl',0.2);
  DefIniSet('tgeom/unyw',0.2);
  DefIniSet('tgeom/xrbl',1.0);
  DefIniSet('tgeom/driw',0.06);
  DefIniSet('tgeom/monw',0.15);
  DefIniSet('tgeom/corw',0.1);
  DefIniSet('tgeom/corl',0.1);
  DefIniSet('tgeom/marl',0.01);
  DefIniSet('tgeom/gwd1',0.5);
  DefIniSet('tgeom/gwd2',0.45);
  DefIniSet('tgeom/gwd3',0.4);

  DefIniSet('trackp/ntush',50);
  DefIniSet('trackp/tcoup',10.0);
  DefIniSet('trackp/aperx',30.0);
  DefIniSet('trackp/apery',30.0);
  DefIniSet('trackp/bbetx',1.0);
  DefIniSet('trackp/balfx',0.0);
  DefIniSet('trackp/bemix',1.0);
  DefIniSet('trackp/bbety',1.0);
  DefIniSet('trackp/balfy',0.0);
  DefIniSet('trackp/bemiy',1.0);
  DefIniSet('trackp/bnpar',100);

  DefIniSet('tdiag/size',300);
  DefIniSet('tdiag/qrang',0.5);
  DefIniSet('tdiag/order',3);
  DefIniSet('tdiag/skew',0);
  DefIniSet('tdiag/nsys',0);

  DefIniSet('trackt/coup',1.0);
  DefIniSet('trackt/itot',1.0);
  DefIniSet('trackt/nbun',1);
  DefIniSet('trackt/volt',1.0);
  DefIniSet('trackt/harm',100);
  DefIniSet('trackt/dels',0.1);
  DefIniSet('trackt/delp',1e-4);
  DefIniSet('trackt/ntur',100.0);
  DefIniSet('trackt/gasz',1.0);
  DefIniSet('trackt/gasn',1.0);
  DefIniSet('trackt/gasp',1.0);

  DefIniSet('trackt/wid',1000);

  DefIniSet('trackd/dppr',0.03);
  DefIniSet('trackd/ntur',100);
  DefIniSet('trackd/nray',3);
  DefIniSet('trackd/reso',1e-5);
  DefIniSet('trackd/ngrx',5);
  DefIniSet('trackd/ngry',4);
  DefIniSet('trackd/ngrp',3);
  DefIniSet('trackd/ngrs',3);
  DefIniSet('trackd/dmode',0);
  DefIniSet('trackd/dmeth',0);
  DefIniSet('trackd/wid',800);
  DefIniSet('trackd/hgt',450);
  DefIniSet('trackd/psty',0);

  DefIniSet('svect/size',300);

  DefIniSet('lgbed/angle',5);
  DefIniSet('lgbed/lengt',1);
  DefIniSet('lgbed/nslic',8);
  DefIniSet('lgbed/bpeak',2);
  DefIniSet('lgbed/betax',0.2);
  DefIniSet('lgbed/hpolw',0.05);

  DefIniSet('orbit/xelem',30);
  DefIniSet('orbit/yelem',30);
  DefIniSet('orbit/telem',100);
  DefIniSet('orbit/xgird',60);
  DefIniSet('orbit/ygird',60);
  DefIniSet('orbit/tgird',100);
  DefIniSet('orbit/xjoin',20);
  DefIniSet('orbit/yjoin',20);
  DefIniSet('orbit/sicut',2);
  DefIniSet('orbit/nloop',10);

//buckt shares defaults for harmonic and voltage with trackt
  DefIniSet('buckt/circ',300);
  DefIniSet('buckt/ener',3.0);
  DefIniSet('buckt/erad',500.0);
  DefIniSet('buckt/alfa',1.0);
  DefIniSet('buckt/dmax',0.1);
  DefIniSet('buckt/nham',50);
  DefIniSet('buckt/ncon',25);
  DefIniSet('buckt/volt2',0);
  DefIniSet('buckt/volt3',0);
  DefIniSet('buckt/volt4',0);
  DefIniSet('buckt/volt5',0);
end;

procedure GlobDefInitAll;
begin
  GlobDef:=nil;
//  GlobDefIniSet('console', 0);
  GlobDefIniSet('diaglev', 1);
end;

{..........................................................................................}
{default file syntax:
>name1< value1
....
eof.
}


// (public) read Defaults from a file and overwrite Init values
procedure DefReadFile;
var
  i1, i2, idef, err: integer;
  def_file, line, name, test: string;
  df: textfile;
  x: real;
begin
  def_file:= work_dir+OPA_def_name;
  assignFile(df, def_file);
  {$I-}
  reset(df);
  {$I+}
  if IOResult=0 then begin
    OPALog(0,'read settings from |>'+def_file);
    while not EOF(df) do begin
 //   read a line, split at delimiters, read strings
      readln(df,line);
      i1:=Pos('>',line);   i2:=Pos('<  ',line);
      if ((i1=1) and (i2>2)) then begin
        name:=Copy(line,2,i2-2);
        idef:=DefFindEl(name);
        if idef>=0 then begin
          test:=Copy(line,i2+3,length(line)-i2-2);
          try Val(test, x, err) except end;
          if err=0 then Def[idef].val:=x;
//          writeln('def read: idef, nam, val:',idef, def[idef].nam, def[idef].val);
        end else OPALog(2,'no data in settings file '+name+', use default values.');
      end;
    end;
    closeFile(df);
  end else OPALog(2,'settings file '+name+' not found, use default values.') ;
end;

procedure GlobDefReadFile;
var
  i1, i2, idef, err: integer;
  gdef_file, line, name, test: string;
  gf: textfile;
  x: real;
begin
  gdef_file:= opa_dir+OPA_glob_name;
  assignFile(gf, gdef_file);
  {$I-}
  reset(gf);
  {$I+}
  if IOResult=0 then begin
    OPALog(0,'Read global settings from |>'+gdef_file);
    while not EOF(gf) do begin
 //   read a line, split at delimiters, read strings
      readln(gf,line);
      i1:=Pos('>',line);   i2:=Pos('<  ',line);
      if ((i1=1) and (i2>2)) then begin
        name:=Copy(line,2,i2-2);
        idef:=GlobDefFindEl(name);
        if idef>=0 then begin
          test:=Copy(line,i2+3,length(line)-i2-2);
          try Val(test, x, err) except end;
          if err=0 then GlobDef[idef].val:=x;
        end else OPALog(2,'no data in global settings '+name+', use default.');
      end;
    end;
    closeFile(gf);
  end else OPALog(2,'global settings file '+gdef_file+' not found.') ;
end;


{..........................................................................................}

// (public) save Defaults to a file
procedure DefWriteFile;
var
  i: integer;
  line: string;
  df: textfile;
begin
  assignFile(df,work_dir+OPA_def_name);
  {$I-}
  rewrite(df);
  {$I+}
  if IOResult=0 then begin
    for i:=0 to High(Def) do begin
      line:= '>'+Def[i].nam+'<  '+UsNumber(FloatToStr(Def[i].val));
      writeln(df, line);
    end;
    closeFile(df);
    OPALog(0,' Wrote settings to '+work_dir);
  end else begin
  OPALog(2,' could not write parameter file to '+work_dir);
  end;
end;


procedure GlobDefWriteFile;
var
  i: integer;
  line: string;
  gf: textfile;
begin


  assignFile(gf,opa_dir+OPA_glob_name);
  {$I-}
  rewrite(gf);
  {$I+}
  if IOResult=0 then begin
    for i:=0 to High(GlobDef) do begin
      line:= '>'+GlobDef[i].nam+'<  '+UsNumber(FloatToStr(GlobDef[i].val));
      writeln(gf, line);
    end;
    closeFile(gf);
  end else begin
  end;
end;

{..........................................................................................}

// (public) get a default value, return real
function FDefGet(s: string): real;
var i: integer;
begin
  i:=DefFindEl(s);
  if i>=0 then FDefGet:=Def[i].val else FDefGet:=0.0;
end;

{..........................................................................................}

// (public) ... return integer (internally: always real )
function IDefGet(s: string): integer;
begin
  IDefGet:=Round(FDefGet(s));
end;

function GlobDefGet(s: string): integer; //globdefs are all integers (up to now)
var i: integer;
begin
  i:=GlobDefFindEl(s);
  if i>=0 then GlobDefGet:=round(GlobDef[i].val) else GlobDefGet:=0;
end;


{..........................................................................................}

//  (public) set a Default value
procedure DefSet(s: string; val: real);
var i: integer;
begin
  i:=DefFindEl(s);
  if i>=0 then Def[i].val:=val;
end;

procedure GlobDefSet(s: string; val: real);
var i: integer;
begin
  i:=GlobDefFindEl(s);
  if i>=0 then GlobDef[i].val:=val;
end;
{..........................................................................................}


procedure Inipath;
{find the working directory :
- get the OPA directory by expanding a file name without path info
- look for the file OPA_Path.ini
- if it exists: read it, there should be 1 line with the name of the last used subdir
- look if this subdir exists, if yes, set work_dir to this dir's full name
- if not, use the OPA directory as work_dir
}
var
  f: TextFile;
  IniFileName, name, FullFileName: string;
begin
  IniFileName:=OPA_inipath_name;
  FullFileName:=ExpandFileName(IniFileName);
  OPA_dir:=Copy(FullFileName, 1, Pos(IniFileName, FullFileName)-1);
  work_dir:=OPA_dir;

// writeln('inipath');
  OPALog(0,'OPA home directory is|>'+OPA_dir);
  GlobDefReadFile; // do this here before opening and first call to diagfil

//  ShowConsole(GlobDefGet('console'));

//  if GlobDefGet('console')=1 then begin
//    AssignFile(diagfil,'');
//    OPALog(0,'Writing output to console');
//  end else begin
    AssignFile(diagfil,OPA_dir+'diagopa.txt');
    OPALog(0,'Writing output to |>'+OPA_dir+'diagopa.txt');
//  end;
  rewrite(diagfil);
  diaglevel:=GlobDefGet('diaglev');
  if diaglevel < 0 then diaglevel:=0; if diaglevel>3 then diaglevel:=3;

  AssignFile(f,IniFileName);
  {$I-}
  reset(f);
  {$I+}
  if IOResult=0 then begin
    countLastUsedFiles:=0;
    while (not Eof(f)) and (countLastUsedFiles < maxLastUsedFiles) do begin
      readln(f, name);
      if FileExists(name) then begin
        Inc(countLastUsedFiles);
        LastUsedFiles[countLastUsedFiles]:=name;
      end;
    end;
    closeFile(f);
    if (countLastUsedFiles>0) then work_dir:=ExtractFilePath(LastUsedFiles[1]);
  end;
  OPALog(0,'OPA working directory is |>'+work_dir);
end;

{########################################################################}


Initialization
  OPALog(3,'Welcome to OPA');
  OPAinit;
  GlobInit;
  GlobDefInitAll;
  DefInitAll;
  IniPath; //contains GlobDefReadFile
  DefReadFile;

end.
