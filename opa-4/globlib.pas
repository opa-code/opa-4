unit globlib;

{$MODE Delphi}
INTERFACE

uses
  LazFileUtils,
  sysutils, stdctrls, graphics, mathlib, menus, dialogs, controls, comauxlib;

//------------------------------------------------------------------------------

const

//user settings
  // file names where to save user setting
  OPA_inipath_name='opa4_path.ini';
  OPA_glob_name   ='opa4_glob.ini';
  OPA_def_name    ='opa4_set.ini';
  //max number of file names to rememeber
  maxLastUsedFiles=10;

//physics
  speed_of_light =2.99792458E08; // m/s
  electron_mc2   =511003.37;     // eV
  electron_charge=1.6021892E-19; // C
  electron_radius=2.8179380E-15; // m
  avogadro_number=6.0223E23;     // 1
  planck_constant=6.626070040E-34;//Js
  gas_constant   =8.314;         // J/mol/K

// max array sizes (should become dynamic)
  NElemMax=6000; NSegmMax=500; NSegLMax=1000;  NLattMax=15000;

//elements
  //max length of var/elem/segm name
  ElemStrLength =16;  //  ElemStrLength =20;
  //number of element types
  Nelemkind=17;
  // type index
  Cdrif=0;   Cmark=1;  Cquad=2;  Cbend=3;  Csext=4;  Csole=5;
  Cundu=6;   Csept=7;  Ckick=8;  Comrk=9;  Ccomb=10; Cxmrk=11;
  Cgird=12;  Cmpol=13; Cmoni=14; Ccorh=15; Ccorv=16; Crota=17;
  // name
  ElemName: array[0..Nelemkind] of string[12] =
    ('Drift','Marker', 'Quadrupole','Bending','Sextupole','Solenoid',
     'Undulator','Septum','Kicker','OpticsMarker','Combined','PhotonBeam',
     'Girder', 'Multipole','Monitor','H-Corrector','V-Corrector','Rotation');
  //short name
  ElemShortName: array[0..Nelemkind] of string[2] =
    ('DR','MK','QU','BE','SX','SO',
     'UN','SP','KI','OM','CO','XB',
     'GD','MP','MO','CH','CV','RO');
  //thick and thin elements
  ElemThick: array[0..Nelemkind] of boolean =
    (TRUE, FALSE, TRUE, TRUE, TRUE, TRUE,
     TRUE, TRUE, TRUE, FALSE, TRUE, FALSE,
     FALSE, FALSE, FALSE, FALSE, FALSE, FALSE);
  // caption for knobframe and omatching if element is selected:
  strkparam: array[0..NElemKind] of string[13]=
    ('L [m]', '', 'k [1/m2]', 'k [1/m2]', 'mL [1/m2]', 'ks [1/m]',
     'Bp [T]', '', 'BnL[1/m(n-1)]', '', 'factor','',
     '','BnL[1/m(n-1)]','','dx'' [mrad]', 'dy'' [mrad]', 'rot [deg]');
  // colors how to draw elements
  d_col    =$00999999;  m_col    =$00555555;  q_col    =$000000ff;
  b_col    =$00ff0000;  s_col    =$0000ff00;  so_col   =$00ffff00;
  u_col    =$0077ff00;  sp_col   =$0095afcd;  k_col    =$000361ff;
  om_col   =$0000ffff;  c_col    =$00ff0077;  xm_col   =$00ffff00;
  oc_col   =$00005588;  de_col   =$00558800;  mo_col   =clGreen;
  ch_col   =$00ff0000;  cv_col   =$000000ff;  ro_col   =clFuchsia;
  // color for segment editor osegedit and for plots in opalinop and opageometry
  ElemCol: array[0..NElemKind] of TColor =
    (d_col, m_col, q_col, b_col, s_col, so_col,
     u_col, sp_col, k_col, om_col, c_col, xm_col,
     m_col, oc_col, mo_col, ch_col, cv_col, ro_col);
  // color for knobframe caption
  ElemTextCol: array[0..NElemKind] of TColor = (clWhite, clBlack, clBlack, clWhite,
  clBlack, clBlack, clBlack, clBlack, clBlack, clBlack, clWhite, clBlack, clBlack,
  clWhite, clBlack, clWhite, clWhite, clBlack);
  // elem types which can be misaligned
  Cmisalign: Set of 0..NElemKind =
    [Cquad,Cbend,Csext,Csole,Cundu,Ccomb,Cmpol,Cmoni,Ccorh, Ccorv];
  //special names of elements which will be expanded to individuals (lattlib and testcode)
  oco_chname= 'CH'; oco_cvname='CV'; oco_bpmname='MON';
  oco_csname='CS'; oco_qaname='QAC'; nomisal_markername='NOMIS';

//beam optics function
  //colors for plot
  betay_col=$000000ff;  betax_col=$00ff0000;  dispx_col=$0000ff00;  dispy_col=$00ff00ff;
  dpp_col  =$000077aa;  dpm_col  =$00aa7700;
  //functions to be selected in matching
  nMatchFunc=18;
  MatchFuncName: array[1..nMatchFunc] of string[4] =
    ('bxf','axf','byf','ayf', 'disf','dipf','oxf','oxpf',
     'qx','qy',  'bxi','axi','byi','ayi','disi','dipi','oxi','oxpi');

//control flags
  // for mode witching on/off in element calculations
  do_twiss=1; do_chrom=2; do_radin=4; do_lpath=8; do_misal=16;

//status information
  nStatusLabels=14;
    stlab_orb=0; stlab_per=1; stlab_cir=2;
    stlab_cop=3; stlab_cor=5; stlab_kik=4;
    stlab_mis=6; stlab_tsh=7; stlab_chr=8;
    stlab_tmx=9; stlab_cmx=10;stlab_alf=11;
    stlab_rfm=12; stlab_flo=13;
  //status labels for opamenu
  StatusLabNcap: array[0..nStatusLabels-1] of String =(
    'closed orbit','periodic','(circular)',
    'coupling', 'kickers','active correctors',
    'active misalignments','tune shifts','chromaticities',
    'tuning matrix', 'chroma matrix','pathlength',
    'RF bucket','3D Acc xx''p');
  //indicators on status (success, warnings etc.)
  nStatusType=7;
    status_void=0; status_success=1; status_failure=2; status_forward=3;
    status_off=4; status_light=5; status_flag=6;
  //indicator symbol for opamenu, char and ascii code and color
  StatusResCap: array[0..nstatustype] of string=
    (' ','o','x','>',' ','!','*',' ');
  StatusChrInd: array[0..nStatusType] of Integer=
    (32,74,78,70,{161}32,173,79,77);
//  StatusChrInd: array[0..nStatusType] of Integer=(32,252,251,240,{161}32,173,79,77);
  StatusColor: array[0..nStatusType] of TColor=
    (clblack,clgreen,clred,clblue,clgray,clred,clblue, clfuchsia);


// left overs, to be fixed
  clLightYellow=$0088eeff;
  // old NLBC fit in opamomentum
  nMomFit_order=12;
  nMomFit_param=3;
  MomFit_param: array[1..nMomFit_param] of string[6]=('qx','qy','dpath');
  //max entries in snapsave photon beams
  xbcountmax=20;

//------------------------------------------------------------------------------

type

//elementary types (more declarations in mathlib)

  String_2   = string[2];
  ElemStr    = string[ElemStrLength];
  string_4   = string[4];
  String_12  = string[12];
  String_25  = string[25];
  FileString = string[100];
  LineString = string[80];


//data types for lattice data

  // entry for segments defined as linked list, can be an element or a segment
  AEpt = ^AbstractEleType;
  AbstractEleType = record
    nam: ElemStr;
    kin: (seg,ele);
    inv: boolean;
    rep: byte;
    pre, nex: AEpt;
  end;

  // segment defined by start and end pointer of linked list
  SegmentType = record
    nam: string; //ElemStr;
    ini, fin: AEpt;
    nper: integer;
  end;

  // element containing different parameters depending on type
    { INTERNAL element units: m and rad, mm for apertures
      Tesla for undulator peak field
      mrad for kick angles, mm for septum thickness and distance}
    // some parameters may be arithmetic expressions (strings):
    Elem_Exp_pt =^string;
    // a list of individual names may be given (opageometry and opacurrents)
    nameListpt =^nameListType;
    nameListType = record
      realname, psname: string_25;
      typ_name: string_12;
     {type also saved in Elem.TypNam -> available for opageometry even if no calibration exists;
     further avoid loss of typename when creating monitor, corrector arrays 22.2.2018}
      typeindex, polarity, topology: integer;
      nex: nameListpt;
    end;
   //type optics marker chas a pointer to this record of optical paramters
    Omarkpt = ^OmarkType;
    OmarkType = record
      bet, eta, orb: Vektor_4;
      cma: matrix_2;  //    dpp: real;
    end;
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

  // variable containing an arithmetic expression or a value
  Variable_type = record
    nam: elemstr;
    val: real;
    exp: string;
    use: boolean;
    tag: integer;
  end;

  // magnet calibration data to calculate currents in opacurrents
  calibrationType = record
    typename:string_12;
    leng, imax, bres, tlin, isat, aexp, nexp: real;
    mpol, sfac:integer;
  end;

  // lattice element (after expansion of nested segment structure)
  LatticeType = record
    elnam: ElemStr;
    jel, inv, igir: integer; //element, direction +/-1, girder
    dx, dy, dt, smid, angmid, misamp: real; // sway, heave, roll, midpoint, mid angle, misal scaling
    coupl, misal: boolean; // coupling element with non-blockdiag matrix, misalignment set
  end;


//Beam optics
  //Local optical functions
  OpvalType = record
    spos: real;          //location
    disx, dipx, disy, dipy {, phix, phiy} : double; //dispersion
    beta, betb, alfa, alfb, phia, phib, betaf, betbf: double;   //normal mode betas
    path: double; //acculated path
    orb: Vektor_4; //xdpp: real;  //orbit
    cmat, cmatf, am, bm: Matrix_2;  //coupling matrix and n.m. matrices A,B
  end;

  //Equilibrium beam parameters
  BeamParType = record
    persym: boolean; //flag true = success of periodic/symetric
    dppset, Circ, Angle, AbsAngle, ChromX, ChromY, Emita, Emitb, U0,
    Ja, Jb, Je, Ta, Tb, Te, alfa, sigmaE: Real;
    RadInt1, RadInt2, RadInt3, RadInt4a, RadInt4b, RadInt5a, RadInt5b: double;
    Qa, Qb: extended;  //tunes
    Qx, Qy: extended; //historical... to be removed
  end;


// ==> /status should also include validity of results in snapsave - or merge both types? 27.3.2026

  // status flags either indicate special elements present in the lattice
  // or achivements, e.g. a periodic solution exists
  StatusType = record
    Elements, Segments, Undulators, Lattice, UnCoupled, Betas, TuneShifts, Chromas, Monitors, Kickers,
    PerOrbit, Periodic, Symmetric, Circular, Currents, Tmatrix, Cmatrix, Alphas, RFaccept, FloPoly: Boolean;
  end;

  // snapsave is used to remember results to be used in other units
  // historically it was for exporting lattice parameter (in additon to currents)
  // to an EPICS .snap file in opacurrents
    //beta functions at X-ray source point (is it really used?)
    XB_SnapSaveType = record
       nam: ElemStr;
       betax, betay, dispx, dispy: real;
    end;
  SnapSaveType = record
    //save tunes, chromas, elements of tuning and chroma matrices for export in opacurrents
    Qx, Qy, ChromX, ChromY: real;
    tmfx, tmfy, tmdx, tmdy: real; // from otunematrix
    cmfx, cmfy, cmdx, cmdy: real; // from chromlib
    //save adts and chromas from opachroma for overplotting in opamomentum and opatrackps:
    qxx, qxy, qyy, cx2, cy2, cx3, cy3: real;
    //save alpha*Circ up to 5.Ord from opamomentum, for using in opabucket:
    alfaC, voltRF: array[0..4] of real;
    // save RF acceptance and bunch length guess and also wavelength from opabuckte for using in opatracktt
    rfaccm, rfaccp, sigmas, lambdaRF: real;
    // save beam parameters at X-ray source points for export (?)
    xbcount: integer;
    xb: array[0..xbcountmax-1] of XB_SnapSaveType;
  end;

  // save and restore user settings to/from *.ini file, also used to set default values
  DefaultType = record
    nam: String[12];
    val: real;
  end;

  //Curves for plotting optical functions (opalinop mainly) as linked list
    //single element of curve
    CurvePt=^CurveType;
    CurveType = record
      spos, beta, betb, disa, disb, alfa, alfb, xpos, ypos,  betxa, betya, betxb,
      betyb, disx, disy, disxp, disyp, cdet, betaf, betbf, cdetf: real;
      nex: CurvePt;
    end;
  CurvePlotType = record
    enable: Boolean;
    sini, sfin, slice: real; //start, stop and spacing
    ncurve: integer;
    ini: CurvePt; //start point of linked list
  end;

  //handles to the main menu items
  MainButtonHandlesType = record
    fi_new, fi_open, fi_save, fi_svas, fi_expo, ed_text, ed_oped,
    ds_opti,ds_dppo, ds_sext,ds_lgbo, ds_orbc, ds_injc, ds_rfbu,
    tr_phsp, tr_dyna, tr_ttau, tm_geo, tm_cur: TMenuItem;
  end;

  //global control
  GlobType = record
    Energy, Ax, Ay : real; //energy and default apertures
    NPer, NLatt, NElem, NElla, NSegm, Method, Nqkick, Nbkick: word; //count elemetns etc.
    Text : string; //comment in lattice file
    Op0, OpE: OpvalType; //initial and final optics values
    dpp: real;
    rot_inv: boolean; //flag if explicit rotations are inverted too when inverting segments
  end;

//temporary stuff, for testing only

  MF_savetype=record          // test for modeflips
    spos: real; act: integer;
  end;

  ProPtype = record   // test for PropPer (periodic at each element)
    elen, pos, beta, betb, cdet, betaf, betbf, cdetf: double;
  end;

//------------------------------------------------------------------------------

Var      //global, public variables

  OPAversion: string;
  Glob        : GlobType;

  //elements, segments and lattice
  Elem, Ella  : array[1..NElemMax] of ElementType;
  Segm        : array[1..NSegmMax] of SegmentType;
  ActSeg: AEpt;  iActSeg: word;
  Variable    : array of variable_type;
  Lattice     : array of LatticeType;

  //calibration and allocation
  Calibration : array of CalibrationType;
  calibrationFile: filestring;  calibrationFlag: boolean;
  allocationFile: filestring;  allocationFlag: boolean;


  //beam optics
  Beam        : BeamParType;

  //status and results
  Status      : StatusType;
  Snapsave    : SnapSaveType;

  //user settings
  Def         : array of DefaultType;
  GlobDef     : array of DefaultType;
  DefFile     : string;

  //file names
  config_dir, OPA_dir, work_dir: string;
  FileName: String;
  LastUsedFiles: array[1..maxLastUsedFiles] of String;
  countLastUsedFiles:integer;

  // TextBuffer is a linked list of characters for storing the complete input file
  //   in one char array (forward link only, term. by nil)
  //  LineBuffer REMOVED 13.2.2019, see junk/latwrite_et_al.pas
  TextBuffer: pointer;

  // curves
  CurvePlot   : CurvePlotType;
  Curve: CurvePt;

  //opamenu GUI components, to be adressed from various places
  StatusLabels: array[0..nStatusLabels] of TLabel;
  MainButtonHandles: MainButtonHandlesType;
  ErrLogHandle: TMemo;

  //diagnostics output
  diaglevel: integer;
  OPALogBuffer: string;
  //==> diag file to be removed , all goes to OPALog (or to terminal via writeln)

  //public variables, used by many units
  SPosition, PathDiff: double;
  TransferMatrix, Transfermatrix0: Matrix_5;
  MisalignVector: Vektor_4;
  UseSext, UsePulsed: Boolean;

  // derived constants (opainit)
  Ln10, degrad, raddeg : real;
  Erad_factor, Ecrit_factor, RadCq_factor: double;

 //temp. tests
  PropperTest, PropperDone: Boolean;
  TmatStack: array of Matrix_4; // propper test only
  ElenStack: array of ProPtype;   // propper test only
  MF_save: array of MF_savetype; // test only


//------------------------------------------------------------------------------


  //procs for opamenu, to be called from different units, to enable main buttons and set status
 procedure PassMainButtonHandles(fnew, fopen, fsave, fsvas, fexpo,
    etext, eoped, dopti, ddppo, dsext, dlgbo, dorbc, dinjc, drfbu,
    tphsp, tdyna, tttau, tgeo, tcur: TMenuItem);
 procedure passErrLogHandle(errlog: TMemo);
 procedure MainButtonEnable;
 procedure SetStatusLabel(ilab, istat: integer);
 function diag(lev: integer):boolean;
 procedure OPALog(typ: integer; messageText:string);

 //conversion of optics value type from/to beam vectors
 procedure BetaToOp(b: Vektor_4; var Op: OpvalType);
 procedure DispToOp(d: Vektor_4; var Op: OpvalType);
 procedure OrbToOp(o: Vektor_4; var Op: OpvalType);
 function OpToBeta(Op: OpvalType): Vektor_4;
 function OpToDisp(Op: OpvalType): Vektor_4;
 function OpToOrb(Op: OpvalType): Vektor_4;

  {###### Access to elements and segments ##################################}
 function  FindEl  (ilattice:integer): integer;
 function  getkval (j: word; jpar: word): real;
 procedure putkval (k: real; j: word; jpar: word);
 function  getSexkval (j: word): real;
 procedure putSexkval (k: real; j: word);
 function  EllaSave: word;

 function  AppendCurveN (var a: CurvePt; s, x, y, bxa, bxb, bya, byb, dx, dy, dxp, dyp, cdet, ba,bb, aa, ab, da,db: real): CurvePt;
 procedure ClearCurve;


{##### Path, filename and default values #################################}
 procedure DefReadFile;
 procedure DefWriteFile;
 function  DefFindEl(s: string): integer;
 function  FDefGet(s: string): real;
 function  IDefGet(s: string): integer;
 procedure DefSet(s: string; val: real);
 procedure GlobDefReadFile;
 procedure GlobDefWriteFile;
 function  GlobDefFindEl(s: string): integer;
 function  GlobDefGet(s: string): integer;
 procedure GlobDefSet(s: string; val: real);

{####### Global initialization ###########################################}
 Procedure OPAInit;
 Procedure GlobInit;

IMPLEMENTATION

{------------------------------------------------------------------------------}

//assign a text window for error reports, used by opamenu and opatexteditor
procedure passErrLogHandle(errlog: TMemo);
begin
  ErrLogHandle:=errlog;
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
  styp: array[0..maxtyp] of string[7] =('','[ERRO] ','[WARN] ','------ ','[DLV1] ','[DLV2] ','[DLV3] ');
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

function diag(lev: integer):boolean;
// control of output, switch to become true if lev <= diaglevel
begin
  diag:=(lev <= diaglevel);
end;


{-----------------------------------------------------------------------------}
//conversion of beam data to optics valus and back

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


{----------------------------------------------------------------------------}

// find element index in lattice
function FindEl(ilattice:integer): integer;
begin
  Findel:=Lattice[ilattice].jel;
end;

// get strength value, for sextupoles, the FULL INTEGRATED strength is used
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
    cundu: x:=bmax;
    else x:=0.0;
   end;
  end;
  getkval:=x;
end;

//set strength value
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
    cundu: bmax:=k;
    else opalog(1,'PutKval - unknown element code!');
   end;
  end;
end;

// get int. strength of sextupole kick inside a thick sextupole or combined magnet
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

// set int. strength of sextupole kick inside a thick sextupole or combined magnet
procedure putSexkval (k: real; j: word);
begin
  with Ella[j] do if cod =csext then begin
    if l=0 then ms:=k else ms :=k/l*sslice;
  end else if cod=ccomb then cms:=k/l*cslice;
end;



{ (private)
  compare two elements and return false if there is a difference
  the expressions are NOT compared, because Ella and Elem have the same pointers,
  which refer to the same expression. Instead changing expression outside Editor is blocked. }
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

{compares ella to corresponding elem (identified by name)
 if any of the ella properties has been changed compared to ella,
 it asks, if to save the changed ella values into elem, else to
 reset ella by elem values.
 special treatment required for oco-corrs, which exist only as ellas.
 as-300709}
function EllaSave: word;
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


//append a point to a curve
//==> only used by elemlib -- move?
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

//release a curve
//==> only used by linoplib
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

{-----------------------------------------------------------------------}

Procedure OPAInit;
//initialize settings which are never changed in execution
begin
  Ln10        := Ln(10);
  degrad      :=180/Pi;
  raddeg      :=Pi/180;
  Erad_factor :=electron_charge*Sqr(speed_of_light)*2E-7/3.*sqr(sqr(1E9/electron_mc2));
  //energy loss factor [eV]  = e/6pi/eps0/(mc2/e)[GeV]^4; eps0=1/c^2/mu0; mu0 = 4pi E-7
  Ecrit_factor:=3E18*planck_constant*sqr(speed_of_light)/4/Pi/electron_charge*PowI(1./electron_mc2,3);
  //critical energy factor [eV]  = 3hc^2/4/Pi/e*(1/(mc2/e))^3
  RadCq_factor:=55E18*planck_constant*speed_of_light/(64*Pi*sqrt(3)*PowI(electron_mc2,3)*electron_charge);
  //factor for radiation equilibrium, emittance and espread Cq [m] =  55 h/2pi c e /(32 sqrt3 (mc2/e)^3)
end;

procedure GlobInit;
//initialize settings which are to be reset for a new file
begin
  UseSext    :=False;              { Sextupoles not used.   }
  UsePulsed  :=False;              { pulsed elements not used.   }
  Glob.NElem :=0;                  { Initial values for the lattice      }
  Glob.NElla :=0;
  Glob.NSegm :=0;
  Glob.NLatt :=0;                  { record variable                   }
  Glob.NPer  :=1;
  Glob.Text :='';
  with Glob.Op0 do begin
    beta:=1; alfa:=0; betb:=1; alfb:=0;
    disx:=0; dipx:=0; disy:=0; dipy:=0;
    phia:=0; phib:=0;
    cmat:=MatNul2;
  end;
  Glob.OpE:=Glob.Op0;
  Glob.dPP   := 0.0;
  Glob.rot_inv:=false;
  Glob.Energy:=1.0;
  Glob.Ax:=20.0; Glob.Ay:=20.0;
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

// (private) find a Default by Name
function DefFindEl(s: string): integer;
var idef, i: integer;
begin
  idef:=-1;
  for i:=0 to High(Def) do begin
    if s=Def[i].nam then idef:=i;
  end;
  DefFindEl:=idef;
end;

// (private) initialize a default, all fields
procedure DefIniSet(s: string;  x: real);
begin
  setlength(Def,length(Def)+1);
  with Def[High(Def)] do begin
    nam  :=s;
    val  :=x;
  end;
end;

//  same for global defaults
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

// create and initialize all defaults
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

//opabucket shares defaults for harmonic and voltage with opatracktt
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
  GlobDefIniSet('diaglev', 1);
end;

{
default file syntax:
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
    OPALog(0,'reading user settings from |>'+def_file);
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
        end else OPALog(2,'no data in settings file |>'+work_dir+OPA_def_name+'|>--> using defaults.');
      end;
    end;
    closeFile(df);
  end else OPALog(2,'couldn''t find settings file |>'+work_dir+OPA_def_name+'|>--> using defaults.') ;
end;

procedure GlobDefReadFile;
var
  i1, i2, idef, err: integer;
  gdef_file, line, name, test: string;
  gf: textfile;
  x: real;
begin
  gdef_file:= config_dir+OPA_glob_name;
  assignFile(gf, gdef_file);
  {$I-}
  reset(gf);
  {$I+}
  if IOResult=0 then begin
    OPALog(0,'reading global settings from |>'+gdef_file);
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
        end else OPALog(2,'no data in global settings |>'+name+'|>--> using defaults.');
      end;
    end;
    closeFile(gf);
  end else OPALog(2,'couldn''t find global settings file |>'+gdef_file+'|>--> using defaults.') ;
end;

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
    OPALog(0,'User settings saved to |>'+work_dir+OPA_def_name);
  end else begin
  OPALog(2,'couldn''t write settings file to |>'+work_dir+OPA_def_name);
  end;
end;

procedure GlobDefWriteFile;
var
  i: integer;
  line: string;
  gf: textfile;
begin
  assignFile(gf,config_dir+OPA_glob_name);
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

// (public) get a default value, return real
function FDefGet(s: string): real;
var i: integer;
begin
  i:=DefFindEl(s);
  if i>=0 then FDefGet:=Def[i].val else FDefGet:=0.0;
end;

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


  function GetOPADataDir: string;
  //from chatgpt: set default dir for user data op-system independently:
  //create it if is does not exist
  begin
    Result := IncludeTrailingPathDelimiter(GetUserDir) + 'opadata';
    Result := IncludeTrailingPathDelimiter(Result);
    if not DirectoryExistsUTF8(Result) then
    ForceDirectoriesUTF8(Result);
  end;

begin
  //set or create the configuration dir to save opa4_inipath.ini and opa4_glob.ini
  config_dir:=GetAppConfigDirUTF8(False, True);

  IniFileName:=config_dir+OPA_inipath_name;

  OPA_Dir:= ExpandFileName('');

  OPALog(0,'program code  directory: |>'+OPA_dir);
  OPALog(0,'configuration directory: |>'+config_dir);


  GlobDefReadFile; // do this here before opening a

//  ShowConsole(GlobDefGet('console'));
//  if GlobDefGet('console')=1 then begin
//    AssignFile(diagfil,'');
//    OPALog(0,'Writing output to console');
//  end else begin
{ diag file removed, all goes to OpaLog or to console (in develpment only), Aug.2026
    AssignFile(diagfil,OPA_dir+'diagopa.txt');
    OPALog(0,'Writing output to |>'+OPA_dir+'diagopa.txt');
//  end;
  rewrite(diagfil);
}

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
    if (countLastUsedFiles>0) then begin
      work_dir:=ExtractFilePath(LastUsedFiles[1]);
    end;
  end else work_dir:=  GetOPADataDir;
  OPALog(0,'Present user  directory: |>'+work_dir);
end;

{------------------------------------------------------------------------------}


Initialization
  OPALog(3,'Welcome to OPA');
  OPAinit;
  GlobInit;
  GlobDefInitAll;
  DefInitAll;
  IniPath; //contains GlobDefReadFile
  DefReadFile;

end.
