unit georblib;

{$mode Delphi}

interface

uses
  Classes, SysUtils, Math, graphics, linoplib, elemlib, globlib, mathlib, comauxlib;


const
  //orbit/injection:
  codeps = 1e-9; // 1 nm for corrected cod rms
  ncodit = 30;   // 20 iterations for orbit correction

  hv_torb: array[0..1] of string[6]=('X [mm]','Y [mm]');
  hv_tcor: array[0..1] of string[12]=('dX''[mrad]','dY''[mrad]');
  hv_tmis: array[0..1] of string[12]=('dX [mic]','dY [mic]');
  hv_col:  array[0..1] of TColor=(clBlue,clRed);
  hv_axmo: array[0..1] of integer =(2,0);
  hv_tspo: array[0..1] of string[12]=('Spos [m]','Spos [m]');

  clseedloop=clFuchsia;

  //geometry
  nParam=14;
  ParamName: array[0..nParam-1] of string[4]=
  ('beyw', 'quyw', 'mpyw','mpyl','unyw','xrbl',
  'driw', 'monw','corw','corl','marl','gwd1','gwd2','gwd3');
  ParamTitle: array[0..nParam-1] of string[25]=('Bending width [m]','Quadrupole width [m]',
    'Multipole width [m]','Multipole length [m]','Undulator width [m]','X-ray beam stretch [x]',
    'Chamber width [m]','Monitor size [m]','Corrector width [m]','Corrector length [m]',
    'Marker length [m]', 'Girder-1 width [m]', 'Girder-2 width [m]', 'Girder-3 width [m]');
  ParamWid: array[0..NParam-1] of integer = (5,5,5,5,5,5,5,5,5,5,5,5,5,5);
  ParamDec: array[0..NParam-1] of integer = (2,2,2,2,2,1,3,2,2,2,3,2,2,2);
  ElemDrawOrder: array[0..NElemKind] of integer =   //drawing order
   (Cxmrk, Cdrif, Cbend, Ccomb, Cquad, CSole, Cundu,
    CSept, Ckick, CSext, Cmpol, Ccorh, Ccorv, Cmoni, Cgird, Cmark, Comrk, Crota);

  NGEdit=12;
  edgwid=11; edgdec=6;
  ileng=0; ixini=1; iyini=2; izini=3; ianzi= 4; ianxi= 5; iansi= 6;
           ixfin=7; iyfin=8; izfin=9; ianzf=10; ianxf=11; iansf=12;
  labg_Text: array[0..NGEdit] of string[18]=('Length [m]',
            'Initial X [m]','Initial Y [m]','Initial Z [m]',
            'Ini.Z-rot [°]', 'Ini.X-rot [°]', 'Ini.S-rot [°]',
            'Final X [m]','Final Y [m]','Final Z [m]',
            'Fin.Z-rot [°]', 'Fin.X-rot [°]', 'Fin.S-rot [°]');
  edparname: array[0..nGEdit] of string[4]=('leng',
            'xini', 'yini', 'zini','anzi','anxi','ansi',
            'xfin', 'yfin', 'zfin','anzf','anxf','ansf');

  kndiff=1e-4; //num diff for sensitivity matrix
  nitermax=50; // max no interations
  penalmax=10.0; // max value of penalty to indicate failure
  penaleps=1e-6 ; // = 1 micron. target value of penalty


type
  // orbit and geometry
  // girder to set correlated misalignments
  Girdertype =record
    gsp, gang, {gxpos, gypos,} gshft, gdx, gdy: array[0..1] of real; //pos, angle, shift; sway, heave of feet
    gdt: real; //roll
    ilat, igir, gco: array[0..1] of integer; //lattice start/end and type of connection to adjacent girder:
    level: integer;
    //gco: 0 nothing, 1 joint (train link), 2 1-point support, 3 2-point support
  end;

  //orbit/injection

  cortype = record
  {name and strength known from jella}
    ilat, jella: integer; //ilat in lattice, Ella index
    hv, oco: boolean; //hv false=H true=V
    spos, beta, mu: real;
  end;

  bpmtype = record
    ilatb, jellab: integer;
    oco: boolean;
    sposb, betax, betay, mux, muy: real;
    ref: array[0..1] of real;
  end;

  kicktype = record
    ilat, jella: integer;
    hv: boolean;
    spos, beta, mu: real;
  end;

  OrbLoopType = record
    result: integer;
    xbpm, ybpm, xele, yele, xcor, ycor: array[0..2] of real;
  end;

   //geometry

  fpolyType = record
    isp, npp: integer; //start index in ptx, pty arrays and number of points
    c, cf: Tcolor; //draw and fill color
  end;

  faceType = record
    ist, npt: integer; //ist = start in vpt array, npt = points, 0=normal, 1..npt=corners
    vis: integer; {0,1,2 both sides, only from normal, invisible}
    col: TColor;
  end;

  midptType = record
    mor: Matrix_3; // orientation matrix: rotation local sxy -> global XYZ
    cur, s, s0, s1, ang, ang0, ang1: real; // ini,fin
    v0, v1, vm: Vektor_3;
    jel, cod, igir: integer;
    inv, skp: boolean;
    nam: string_25;
  end;



var
  // girders
  Girder      : array of GirderType;
  NGirderLevel: array[1..3] of integer;

  // orbit/injection
  cor: array of cortype;
  bpm: array of bpmtype;
  kick: array of kicktype;
  ikick, icorx, icory, iocox, iocoy, iocom: array of integer;
  OrbLoop: array of OrbLoopType;
  loopstatus: integer;
  orbmax, cormax, mismax, circ, sposini, sposfin, dsmin, CODpenalty: real;
  nturns, nkick, ncorx, ncory, nbpm, nocox, nocoy, nocom, knobwidth, nknobs, bpmindex: integer;
  dx_ransig, dy_ransig, dt_ransig, gdx_ransig, gdy_ransig, gdt_ransig,
    jdx_ransig, jdy_ransig, gelatt, sigcut: real;
  codstatmode, ocoWplot, iMisal_seed: integer;
  keepMaxVal, bpmrefmode, ocoSVDdone, BPMinclude, LoopBreak: boolean;
  plotOCM, NLoop: integer;
  oimode: integer;
  ocoWx, ocoWxuse, ocoWy, ocoWyuse: array of real;
  ocoNwx, ocoNwy: integer;


  // geometry
  Param: array[0..NParam-1] of real;
  edg_val, edg_goal : array[0..NGEdit] of Real;
  edg_actena, matchfunc: array[0..ngedit] of boolean;
  ptx, pty: array of real;
  vpt: array of Vektor_3;
  fpoly : array of fpolyType;
  midpt: array of midptType;
  face : array of faceType;
  inipt, finpt: midptType;
  drawmode, ngeovar: integer;
  viniact, vinipre, vini0, vfin, vfin0, vcenter0, angvi, angvf: Vektor_3; //angv only to store angles
  moriact, moripre, morini0, morfin0: Matrix_3;
  angini0, angfin0, angbendoffset: double;
  showgoal: boolean;
  xmin, xmax, ymin, ymax, xmid, ymid, xwidth, ywidth,
    xfullwidth, yfullwidth, xcenter, ycenter, sposition, sfulllength: real;
  ncentermark: integer;
  matchknob: array of boolean;
  nmatchfunc, nmatchknob: integer;
  geofiles: array of string;
  knob0, knob, dknob, func0, func, funct: array of real;
  iknob, ifunc, iedvar: array of integer;
  penal, penal0: real;
  niter:integer;
  failed:boolean;





procedure GirderSetup;

// orbit & injection

procedure OrbitInit;
procedure OrbitExit;
procedure OrbitClose;

procedure GetOrbitMax;
procedure GetCorMax;
procedure GetMisMax;

procedure setMisalignments(xrms, yrms, trms, gxrms, gyrms, gtrms, jxrms, jyrms: real);
function GetResponseMatrix: Boolean;
procedure CodstatCalc(mode: integer; var xmean, xrms, xmax, ymean, yrms, ymax: double);
function LoopstatCalc(mode: integer; var xmean, xrms, xmax, ymean, yrms, ymax: double): integer;

procedure oco_init;
procedure oco_step;
procedure oco_term;

procedure SyncKickers;

// geometry

procedure GeoInit;
procedure GeoExit;
procedure GeoClose;

function  CalcOrbit: boolean; //calc geo orbit starting from 0,0,0 direction X
procedure CalcFaces; //calc faces (tiles) defining the objects from current orbit
procedure CalcPoly;  //calc 2D polygons from 3D faces
procedure TransPoly; //transform orbit and faces (translation and rotation)
                     // includes a call to CalcPoly
procedure TransRot;
procedure geoMinMax;

procedure WriteGeoFiles;
procedure ReadGeoFiles;

procedure gsetedgval;

procedure gmat_ini;
procedure gmat_step;
procedure gmat_reset;

implementation

var
  ocoAux, ocoVx, ocoAUy, ocoVy: array of real;
  bvecx, bvecy,  cvecx, cvecy: array of real;


//------------------------------------------------------------
// girder setup, used by opaorbit and by opageometry
//------------------------------------------------------------

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

//------------------------------------------------------------
// procs for opaorbit only
//------------------------------------------------------------


procedure OrbitInit;
var
  i, j:integer;
  sposh, sposv: real;

begin

  circ:=0; sposh:=-1e3; sposv:=-1e3; dsmin:=1e3; sposini:=0; sposfin:=0;
//also get the minimum distance between cors of same kind for plotting the shapels
  cor:=nil; bpm:=nil; icorx:=nil; icory:=nil; iocox:=nil; iocoy:=nil; iocom:=nil;
  for i:=1 to Glob.NLatt do begin
    j:=findel(i);
    circ:=circ+Ella[j].l;
    if Ella[j].cod = cmoni then with Ella[j] do begin
      setlength(bpm,length(bpm)+1);
      with bpm[High(bpm)] do begin
        ilatb:=i; jellab:=j;
        oco:=Ella[jellab].ocom;
        if oco then begin
          setlength(iocom, length(iocom)+1);
          iocom[High(iocom)]:=High(bpm);
        end;
        sposb:=circ;
        ref[0]:=0; ref[1]:=0;
      end;
    end;

    if oimode=0 then begin
      if Ella[j].cod in [ccorh,ccorv] then with Ella[j] do begin
        setlength(cor,length(cor)+1);
        with cor[High(cor)] do begin
          ilat:=i; jella:=j;
          spos:=circ;
//         oco, enabled
          if cod = ccorh then begin
            setlength(icorx,length(icorx)+1);
            icorx[High(icorx)]:=High(cor);
            hv:=false;
            oco:=Ella[jella].ocox;
            if oco then begin
              setlength(iocox,length(iocox)+1);
              iocox[High(iocox)]:=High(cor);
            end;
            if (circ-sposh) < dsmin then dsmin:=circ-sposh;
            sposh:=circ;
          end else begin
            setlength(icory,length(icory)+1);
            icory[High(icory)]:=High(cor);
            hv:=true;
            oco:=Ella[jella].ocoy;
            if oco then begin
              setlength(iocoy,length(iocoy)+1);
              iocoy[High(iocoy)]:=High(cor);
            end;
            if (circ-sposv) < dsmin then dsmin:=circ-sposv;
            sposv:=circ;
          end;
        end;
      end;
    end;

    if oimode=1 then begin
      if Ella[j].cod = ckick then with Ella[j] do begin
        setlength(kick,length(kick)+1);
        with kick[High(kick)] do begin
          ilat:=i; jella:=j;
          spos:=circ;
          setlength(ikick,length(ikick)+1);
          ikick[High(ikick)]:=High(kick);
          if mpol > 0 then begin
            hv:=false;
            if (circ-sposh) < dsmin then dsmin:=circ-sposh;
            sposh:=circ;
          end else begin
            hv:=true;
            if (circ-sposv) < dsmin then dsmin:=circ-sposv;
            sposv:=circ;
          end;
        end;
      end;
    end;
  end; //lattice i

  ncorx:=Length(icorx); ncory:=Length(icory); nbpm:=Length(bpm);
  nocox:=Length(iocox); nocoy:=Length(iocoy); nocom:=length(iocom);
  nkick:=Length(ikick);

  dx_ransig :=FDefGet('orbit/xelem')*1e-6;
  dy_ransig :=FDefGet('orbit/yelem')*1e-6;
  dt_ransig :=FDefGet('orbit/telem')*1e-6;
  gdx_ransig:=FDefGet('orbit/xgird')*1e-6;
  gdy_ransig:=FDefGet('orbit/ygird')*1e-6;
  gdt_ransig:=FDefGet('orbit/tgird')*1e-6;
  jdx_ransig:=FDefGet('orbit/xjoin')*1e-6;
  jdy_ransig:=FDefGet('orbit/yjoin')*1e-6;
  sigcut    :=FDefGet('orbit/sicut');
  NLoop     :=IDefGet('orbit/nloop');

  codstatmode:=0;
  COCorrstatus:=0;
  bpmrefmode:=false;
  keepMaxVal:=false;
  ocoSVDdone:=false;
  ocoWplot:=-1;
  cormax:=1e-6; orbmax:=1e-6;
  bpmindex:=-1;
  dppmode:=false; MomMode:=false;
  OOMode:=true;
  PerMode:=false;
  SymMode:=false;
//  OpticStartMode:=-1; {undefined to start without selection}
  OpticStartMode:=0; {nervt sonst}
  UsePulsed:=False;
  nturns:=1;
  PlotOCM:=0;
  BPMinclude:=true;
  loopstatus:=0;

  sposini:=0;
  sposfin:=circ;


end;

procedure OrbitExit;
var
  stat, i: integer;
begin
  stat:=status_off;
  for i:=0 to High(cor) do if ( abs(getkval(cor[i].jella,0)) > 1E-6) then stat:=status_light;
  setStatusLabel(stlab_cor,stat);
  DefSet('orbit/xelem', dx_ransig*1e6);
  DefSet('orbit/yelem', dy_ransig*1e6);
  DefSet('orbit/telem', dt_ransig*1e6);
  DefSet('orbit/xgird',gdx_ransig*1e6);
  DefSet('orbit/ygird',gdy_ransig*1e6);
  DefSet('orbit/tgird',gdt_ransig*1e6);
  DefSet('orbit/xjoin',jdx_ransig*1e6);
  DefSet('orbit/yjoin',jdy_ransig*1e6);
  DefSet('orbit/sicut',sigcut);
  DefSet('orbit/nloop',nloop);
  EllaSave;
end;

procedure OrbitClose;
begin
  kick:=nil; ikick:=nil;
  cor:=nil; bpm:=nil; icorx:=nil; icory:=nil; iocox:=nil; iocoy:=nil; iocom:=nil;
  ocoAUx:=nil; ocoAUy:=nil; ocoVx:=nil; ocoVy:=nil;
  ocoWx:=nil; ocoWy:=nil; ocoWxuse:=nil; ocoWyuse:=nil;
  ClearOpval;
end;

procedure GetOrbitMax;
// get the maximum orbit (basically included in codstat already...)
var
  i:integer;
begin
  if keepMaxVal then orbmax:=orbmax/1050 else orbmax:=1E-6; {1 micron}
  for i:=1 to Glob.NLatt do with Opval[0,i] do begin
    if abs(orb[1])>orbmax then orbmax:=abs(orb[1]);
    if abs(orb[3])>orbmax then orbmax:=abs(orb[3]);
  end;
  for i:=1 to nbpm-1 do with bpm[i] do begin
    if abs(ref[0])>orbmax then orbmax:=abs(ref[0]);
    if abs(ref[1])>orbmax then orbmax:=abs(ref[1]);
  end;
  orbmax:=orbmax*1050;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// procs for orbit mode
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure GetCorMax;
// get the maximum corrector strength
var
  i: integer;
begin
  if keepMaxVal then cormax:=cormax/1050 else cormax:=1E-6;
  for i:=0 to ncorx-1 do with cor[icorx[i]] do
  with Ella[jella] do if abs(dxp)>cormax then cormax:=abs(dxp);
  for i:=0 to ncory-1 do with cor[icory[i]] do
  with Ella[jella] do if abs(dyp)>cormax then cormax:=abs(dyp);
  cormax:=cormax*1050;
end;

procedure GetMisMax;
// get the maximum misalignment
var
  i: integer;
  gmismax: real;
begin
  mismax:=1e-6; // 1 micron
  gmismax:=0.0;
{  for i:=1 to High(Girder) do with Girder[i] do for j:=0 to 1 do begin
    if abs(gdx[j])>gmismax then gmismax:=abs(gdx[j]);
    if abs(gdy[j])>gmismax then gmismax:=abs(gdy[j]);
  end;
}  for i:=1 to Glob.NLatt do with Lattice[i] do begin
    if abs(dx)>mismax then mismax:=abs(dx);
    if abs(dy)>mismax then mismax:=abs(dy);
  end;
  mismax:=(gmismax+mismax)*1.05e6; // to micron, +5%
end;



procedure setMisalignments(xrms, yrms, trms, gxrms, gyrms, gtrms, jxrms, jyrms: real);
// apply misalignments to elements
const
  maxdis=3;
  gminleng=0.05; //[m] minimum girder length -> perhaps make input variable

type
  jointType = record
    sjoint, jdx, jdy: real;
  end;

var
  i,j: integer;
  r: real;
  roundtrip, jfnd: boolean;
  iu, io, idis: integer;
  joint: array of jointType;
  girju, girjo: array of integer;
  s0, s1, att, g3dx, g3dy, g3dt: real;
  dx, dy: array[0..1] of real;

  function inex(i:integer):integer;
  begin
    if i=NGirderLevel[1] then begin
      roundtrip:=true;
      inex:=0;
    end else inex:=i+1;
  end;

{  function ipre(i:integer):integer;
  begin
    if i=0 then ipre:=High(Girder) else ipre:=i-1;
  end;
}
begin
  RandSeed:=imisal_seed;

// set misalignments to girder ends:
  for i:=0 to NGirderLevel[1]-1 do with Girder[i] do begin
    for j:=0 to 1 do begin
      gdx[j]:=gxrms*gaussran(sigcut);
      gdy[j]:=gyrms*gaussran(sigcut);
    end;
    gdt:=gtrms*gaussran(sigcut);
  end;

//find joints between girders
  if NGirderLevel[1]>1 then begin
    iu:=0;
    roundtrip:=false;
    setlength(girju,NGirderLevel[1]);
    setlength(girjo,NGirderLevel[1]);
    setlength(joint,0);
    repeat
      if Girder[iu].gco[1]=1 then begin //downstream end looking for joint...
        io:=iu;
        idis:=0;
        jfnd:=false;
        repeat
          io:=inex(io); // go to next girder around ring
          idis:=idis+1; // count distance, how many girders
          if Girder[io].gco[0]=1 then begin // matching upstream jointed girder - create joint
            jfnd:=true;
            setlength(joint,length(joint)+1);
            with joint[High(joint)] do begin
              jdx:= gxrms*gaussran(sigcut); // set joint misalignments
              jdy:= gyrms*gaussran(sigcut);
              sjoint:=(Girder[iu].gsp[1]+Girder[io].gsp[0])/2; // assmume joint in middle between
              sjoint:=sjoint+(Girder[iu].gshft[1]+Girder[io].gshft[0])/2; // shift joint, take mean of girder end shifts
              girjo[iu]:=High(joint); girju[io]:=High(joint); // assign joint to connected girders
            end;
          end;
        until jfnd or (idis = maxdis); // allow only maxdis girder to go downstream
        if jfnd then iu:=io else iu:=inex(iu); // if fnd continue with matching girder, else take next
      end else iu:=inex(iu);
    until roundtrip and (iu>=0); // stop if we arrive at start after one roundtrip

//overwrite the girder end misalignments with joint values
//if no joint, the calculation will not change the initially given misalignment
    for i:=0 to NGirderLevel[1]-1 do with Girder[i] do begin
      if gco[0]=1 then begin
        with joint[girju[i]] do begin
          dx[0]:=jdx + jxrms*gaussran(sigcut);
          dy[0]:=jdy + jyrms*gaussran(sigcut);
          s0:=sjoint;
        end;
      end else begin
        dx[0]:=gdx[0];  dy[0]:=gdy[0]; s0:=gsp[0];
      end;
      if gco[1]=1 then begin
        with joint[girjo[i]] do begin
          dx[1]:=jdx + jxrms*gaussran(sigcut);
          dy[1]:=jdy + jyrms*gaussran(sigcut);
          s1:=sjoint;
        end;
      end else begin
        dx[1]:=gdx[1];  dy[1]:=gdy[1]; s1:=gsp[1];
      end;
      for j:=0 to 1 do begin
        r:=(gsp[j]-s0)/(s1-s0);
        gdx[j]:=dx[0]*(1-r)+dx[1]*r;
        gdy[j]:=dy[0]*(1-r)+dy[1]*r;
      end;
    end;
  end; // level 1 girders

{set misalignment for level 2 girder, which are supported by other girder.
no, use joint play for connection of level 2 girder to level 1 girder
[no further error applied for level 2, since the error is given by the supporting girders,
and elements may receive additional individual errors later]}
  for i:=NGirderLevel[1] to NGirderLevel[2]-1 do begin
    if Girder[i].igir[0] > -1 then begin
      with Girder[Girder[i].igir[0]] do begin
        r:=(Girder[i].gsp[0]-gsp[0])/(gsp[1]-gsp[0]);
        Girder[i].gdx[0]:=gdx[0]*(1-r)+gdx[1]*r + jxrms*gaussran(sigcut);
        Girder[i].gdy[0]:=gdy[0]*(1-r)+gdy[1]*r + jyrms*gaussran(sigcut);
        if Girder[i].gco[0]=3 then Girder[i].gdt:=gdt else Girder[i].gdt:=gtrms*gaussran(sigcut);
{ contact 3 (2-point) transmits roll error from supporting girder, contact 2 (1-point) is free.
 if contact 2 -> set gdt, but will be overwritten if other end is contact 3
 if other end is also contact 2, this value is taken, because gdt then is arbitrary
 if ends are free, treat like contact 0
 if end 1 only is free, then check if gdt may have been set at end 0
}
      end;
    end else begin
      Girder[i].gdx[0]:=gxrms*gaussran(sigcut);
      Girder[i].gdy[0]:=gyrms*gaussran(sigcut);
      Girder[i].gdt:=gtrms*gaussran(sigcut);
    end;
    if Girder[i].igir[1] > -1 then begin
      with Girder[Girder[i].igir[1]] do begin
        r:=(Girder[i].gsp[1]-gsp[0])/(gsp[1]-gsp[0]);
        Girder[i].gdx[1]:=gdx[0]*(1-r)+gdx[1]*r + jxrms*gaussran(sigcut);
        Girder[i].gdy[1]:=gdy[0]*(1-r)+gdy[1]*r + jyrms*gaussran(sigcut);
        if Girder[i].gco[1]=3 then Girder[i].gdt:=gdt;
      end;
    end else begin
      Girder[i].gdx[1]:=gxrms*gaussran(sigcut);
      Girder[i].gdy[1]:=gyrms*gaussran(sigcut);
      if Girder[i].igir[0]=-1 then Girder[i].gdt:=gtrms*gaussran(sigcut);
    end;
  end;

 // set misalignment for level 3 girder, which are compound elements,
 // which have common element displacement error.
  for i:=NGirderLevel[2] to NGirderLevel[3]-1 do begin
    g3dx:=xrms*gaussran(sigcut)*gelatt;
    g3dy:=yrms*gaussran(sigcut)*gelatt;
    g3dt:=trms*gaussran(sigcut)*gelatt;
    if Girder[i].igir[0] > -1 then begin
      with Girder[Girder[i].igir[0]] do begin
        r:=(Girder[i].gsp[0]-gsp[0])/(gsp[1]-gsp[0]);
        Girder[i].gdx[0]:=gdx[0]*(1-r)+gdx[1]*r + g3dx;
        Girder[i].gdy[0]:=gdy[0]*(1-r)+gdy[1]*r + g3dy;
        Girder[i].gdt:=gdt+g3dt; //presume contact 3, rigid connection
      end;
    end else begin
      Girder[i].gdx[0]:=xrms*gaussran(sigcut);
      Girder[i].gdy[0]:=yrms*gaussran(sigcut);
      Girder[i].gdt:=trms*gaussran(sigcut);
    end;
    if Girder[i].igir[1] > -1 then begin
      with Girder[Girder[i].igir[1]] do begin
        r:=(Girder[i].gsp[1]-gsp[0])/(gsp[1]-gsp[0]);
        Girder[i].gdx[1]:=gdx[0]*(1-r)+gdx[1]*r + g3dx;
        Girder[i].gdy[1]:=gdy[0]*(1-r)+gdy[1]*r + g3dy;
        Girder[i].gdt:=gdt+g3dt; //should be on same girder and give same result
      end;
    end else begin
      Girder[i].gdx[1]:=xrms*gaussran(sigcut);
      Girder[i].gdy[1]:=yrms*gaussran(sigcut);
      if Girder[i].igir[0]=-1 then Girder[i].gdt:=trms*gaussran(sigcut);
    end;
  end;


// set misalignments of elements on girders:
  for i:=1 to Glob.NLatt do begin
    j:=FindEl(i);
    if Ella[j].cod in cMisalign then with Lattice[i] do begin
//    with Lattice[i] do if Misal then begin
      dx :=xrms*gaussran(sigcut);
      dy :=yrms*gaussran(sigcut);
      dt :=trms*gaussran(sigcut);
      if igir > -1 then with Girder[igir] do begin
        if level>=2 then att:=0 else att:=gelatt;
// level 3 girders may have zero length. Use a minimum length to treat as one element:
        if gsp[1]-gsp[0] < gminleng then r:=0.5 else r:=(smid-gsp[0])/(gsp[1]-gsp[0]);
        dx:=dx*att+gdx[0]*(1-r)+gdx[1]*r;
        dy:=dy*att+gdy[0]*(1-r)+gdy[1]*r;
        dt:=dt*att+gdt;
      end;
      dx:=dx*misamp; dy:=dy*misamp; dt:=dt*misamp;
    end;
  end;

  if not BPMinclude then begin // absolute monitor values if not included
    for j:=0 to High(bpm) do with Lattice[bpm[j].ilatb] do begin
      dx:=0; dy:=0; dt:=0;
    end;
  end;

{  for i:=1 to Glob.NLatt do with Lattice[i] do begin
    j:=Findel(i);
    writeln(diagfil, i, ' dx =', ftos(dx*1e6,12,2), ' dy =',ftos(dy*1e6,12,2),' dt =', ftos(dt*1e6,12,2), ' ', ella[j].nam);
  end;
}
end;


function GetResponseMatrix: Boolean;
// calculate the responsematrix and setup the SVD
var
  i, j: integer; jel: word;
  FailFlag: boolean;
  m, pinux, pinuy, facx, facy: real;
  latmode: shortint;

  procedure Op2BpmCor(jel: word);
//get and store optics params at ALL bpms and corrs
  var j: integer;
  begin
    case Ella[jel].cod of
      cmoni: begin
        for j:=0 to High(bpm) do if bpm[j].jellab=jel then with bpm[j] do begin
          betax:= SigNa2[1,1]; betay:= SigNb2[1,1]; mux:=2*Pi*Beam.Qa;  muy:=2*Pi*Beam.Qb;
        end;
      end;
      ccorh: begin
        for j:=0 to High(cor) do if cor[j].jella=jel then with cor[j] do begin
          beta:= SigNa2[1,1];  mu:=2*Pi*Beam.Qa;
        end;
      end;
      ccorv: begin
        for j:=0 to High(cor) do if cor[j].jella=jel then with cor[j] do begin
          beta:= SigNb2[1,1];  mu:=2*Pi*Beam.Qb;
        end;
      end;
      else begin end;
    end;
  end;


begin
  ocoAux:=nil; ocoWx:=nil; ocoWxuse:=nil; ocoVx:=nil;
  ocoAUy:=nil; ocoWy:=nil; ocoWyuse:=nil; ocoVy:=nil;
  latmode:=do_twiss;//  +do_chrom;
  status.periodic :=false;
  status.symmetric:=false;
  if PerMode then begin
    ClosedOrbit(FailFlag, do_twiss, 0); // close orbit with NO errors  // will set status.perorbit if successful
    if not FailFlag then Periodic(FailFlag); //will set status.periodic if successful
  end else begin
    FailFlag:=false; //single pass, no failure
  end;
{  if not FailFlag then begin} // do it anyway, if periodic failed, do single pass
// calc optics and save phase and betas in bpm and cor arrays
      OptInit;
      for i:=1 to Glob.NLatt do begin
        Lattel (i, jel, latmode, 0.0); //why calc with chroma...?
        Op2BpmCor(jel);
      end;
{
      for i:=0 to High(bpm) do with bpm[i] do writeln(diagfil,ilat,' ',ella[jella].nam,spos,betax,betay,mux,muy);
      for i:=0 to High(icorx) do with cor[icorx[i]] do writeln(diagfil,'H ',ilat,' ',ella[jella].nam, spos, beta, mu);
      for i:=0 to High(icory) do with cor[icory[i]] do writeln(diagfil,'V ',ilat,' ',ella[jella].nam, spos, beta, mu);
}
      setlength(ocoAUx,nocom*nocox);
      setlength(ocoWx,nocox+1);
      setlength(ocoWxuse,nocox+1);
      setlength(ocoVx,nocox*nocox);
      setlength(ocoAUy,nocom*nocoy);
      setlength(ocoWy,nocoy+1);
      setlength(ocoWyuse,nocoy+1);
      setlength(ocoVy,nocoy*nocoy);

{status.perorbit und .periodic besagt ob per orbit und per loesung existiert.
 orbit kann ex aber loesung nicht, dann ist korrektur immernoch moeglich, aber
 wir haben nur betas von single pass.
 Das muss noch korrigiert werden.
}

  //  if PerMode then begin // periodic (per.sol. exists otherwise we would not be here)
  if status.periodic then begin // use betas from per solution
        pinux:=Pi*Beam.Qa; pinuy:=Pi*Beam.Qb;
        facx:=0.5/sin(pinux);
        facy:=0.5/sin(pinuy);

        for i:=0 to nocom-1 do with bpm[iocom[i]] do begin
          for j:=0 to nocox-1 do with cor[iocox[j]] do begin
            if ilatb<ilat then m:=mux-mu+pinux else m:=mux-mu-pinux;
            ocoAUx[i*nocox+j]:=sqrt(beta*betax)*cos(m)*facx;
          end;
          for j:=0 to nocoy-1 do with cor[iocoy[j]] do begin
            if ilatb<ilat then m:=muy-mu+pinuy else m:=muy-mu-pinuy;
            ocoAUy[i*nocoy+j]:=sqrt(beta*betay)*cos(m)*facy;
          end;
        end;
      end

  else begin // single pass betas
        for i:=0 to nocom-1 do with bpm[iocom[i]] do begin
          for j:=0 to nocox-1 do with cor[iocox[j]] do begin
            if ilatb<ilat then ocoAUx[i*nocox+j]:=0.0
//            if sposb<=spos then ocoAUx[i*nocox+j]:=0.0
                          else ocoAUx[i*nocox+j]:=sqrt(beta*betax)*sin(mux-mu);
          end;
          for j:=0 to nocoy-1 do with cor[iocoy[j]] do begin
            if ilatb<ilat then ocoAUy[i*nocoy+j]:=0.0
//            if sposb<=spos then ocoAUy[i*nocoy+j]:=0.0
                          else ocoAUy[i*nocoy+j]:=sqrt(beta*betay)*sin(muy-mu);
          end;
        end;
      end;

{
// test: show that linear CO agrees with RM*cor !
      for i:=0 to nocom-1 do with bpm[iocom[i]] do begin
        xbeam:=0; ybeam:=0;
        for j:=0 to nocox-1 do with cor[iocox[j]] do begin
          xbeam:=xbeam+ocoAUx[i*nocox+j]*Ella[jella].dxp;
        end;
        for j:=0 to nocoy-1 do with cor[iocoy[j]] do begin
          ybeam:=ybeam+ocoAUy[i*nocoy+j]*Ella[jella].dyp;
        end;
        plotox.plot.Symbol0(sposb,xbeam*1000,4,2,clblue);
        plotoy.plot.Symbol0(sposb,ybeam*1000,4,2,clred);
      end;
      if messagedlg('halt?', mtconfirmation, [mbyes,mbno], 0)=mryes then Halt;
}

      SVDCMP(ocoAUx, nocom, nocox, ocoWx, ocoVx);
      SVDCMP(ocoAUy, nocom, nocoy, ocoWy, ocoVy);

      for i:=0 to High(ocoWx) do ocoWxuse[i]:=ocoWx[i];
      for i:=0 to High(ocoWy) do ocoWyuse[i]:=ocoWy[i];

      ocoNwx:=High(ocoWx); ocoNWy:=High(ocoWy);
      ocoSVDdone:=true; // check for success...?
      if ocowPlot=-1 then ocowplot:=0;

//      for i:=0 to High(ocoWx) do writeln(diagfil,'H ',i,'   ',ocoWx[i]);
//      for i:=0 to High(ocoWy) do writeln(diagfil,'V ',i,'   ',ocoWy[i]);

{  end; }
  GetResponseMatrix:=status.perOrbit;       //return true per orbit exists
  //writeln('getresponsematrix periodic orb,beta,mode = ', status.perOrbit, ' ', status.periodic, ' ', permode)
end;

procedure CodstatCalc(mode: integer; var xmean, xrms, xmax, ymean, yrms, ymax: double);
var
  i: integer;
  sprev, ds, dx, dy: real;
begin
  xmean:=0; ymean:=0; xmax:=0; ymax:=0; xrms:=0; yrms:=0;
  case mode of
    0: begin // oco bpm only
      for i:=0 to nocom-1 do with bpm[iocom[i]] do with Opval[0,ilatb] do begin
        dx:=orb[1]-Lattice[ilatb].dx-ref[0]; dy:=orb[3]-Lattice[ilatb].dy-ref[1];
        xmean:=xmean+dx;  xrms :=xrms+sqr(dx);
        if abs(dx) > xmax then xmax:=abs(dx);
        ymean:=ymean+dy;  yrms :=yrms+sqr(dy);
        if abs(dy) > ymax then ymax:=abs(dy);
      end;
      xmean:=xmean/nbpm;   xrms:=sqrt(abs(xrms/nbpm-sqr(xmean))); //insert abs to avoid crash for zero-roundoff
      ymean:=ymean/nbpm;   yrms:=sqrt(abs(yrms/nbpm-sqr(ymean)));
    end;
    1: begin // all elements, length-weightened average
      sprev:=0.0;
      for i:=1 to Glob.NLatt do with Opval[0,i] do begin
        ds:=spos-sprev;
        xmean:=xmean+orb[1]*ds;  xrms :=xrms+sqr(orb[1])*ds;
        if abs(orb[1]) > xmax then xmax:=abs(orb[1]);
        ymean:=ymean+orb[3]*ds;  yrms :=yrms+sqr(orb[3])*ds;
        if abs(orb[3]) > ymax then ymax:=abs(orb[3]);
        sprev:=spos;
      end;
      xmean:=xmean/sprev;   xrms:=sqrt(abs(xrms/sprev-sqr(xmean)));
      ymean:=ymean/sprev;   yrms:=sqrt(abs(yrms/sprev-sqr(ymean)));
    end;
    2: begin // corrector kicks: oco only
      for i:=0 to nocox-1 do with Ella[Cor[iocox[i]].jella] do begin
        xmean:=xmean+dxp;  xrms :=xrms+sqr(dxp);
        if abs(dxp) > xmax then xmax:=abs(dxp);
      end;
      for i:=0 to nocoy-1 do with Ella[Cor[iocoy[i]].jella] do begin
        ymean:=ymean+dyp;  yrms :=yrms+sqr(dyp);
        if abs(dyp) > ymax then ymax:=abs(dyp);
      end;
      xmean:=xmean/ncorx;   xrms:=sqrt(xrms/ncorx-sqr(xmean));
      ymean:=ymean/ncory;   yrms:=sqrt(yrms/ncory-sqr(ymean));
    end;
  end;
end;

 

function LoopstatCalc(mode: integer; var xmean, xrms, xmax, ymean, yrms, ymax: double): integer;
var
  i, nval: integer;
begin
  xmean:=0; ymean:=0; xmax:=0; ymax:=0; xrms:=0; yrms:=0;   nval:=0;
  case mode of
    0: begin
      for i:=0 to nloop-1 do with OrbLoop[i] do if (result < 40) then begin //exclude non-ex ini orbits
        Inc(nval);
        xmean:=xmean+xbpm[1];  //xrms :=xrms+sqr(xbpm[1]); //mean(sigma) and rms(sigma)
        if xbpm[2] > xmax then xmax:=xbpm[2];      // max(max)
        ymean:=ymean+ybpm[1];  //yrms :=yrms+sqr(ybpm[1]);
        if ybpm[2] > ymax then ymax:=ybpm[2];
        if xbpm[1] > xrms then xrms:=xbpm[1]; //max rms
        if ybpm[1] > yrms then yrms:=ybpm[1];
      end;
    end;
    1: begin // all elements, length-weightened average
      for i:=0 to nloop-1 do with OrbLoop[i] do if (result < 30) then begin //exclude non-ex corr orbits
        Inc(nval);
        xmean:=xmean+xele[1];  //xrms :=xrms+sqr(xele[1]); //mean(sigma) and rms(sigma)
        if xele[2] > xmax then xmax:=xele[2];      // max(max)
        ymean:=ymean+yele[1];  //yrms :=yrms+sqr(yele[1]);
        if yele[2] > ymax then ymax:=yele[2];
        if xele[1] > xrms then xrms:=xele[1]; //max rms
        if yele[1] > yrms then yrms:=yele[1];
      end;
    end;
    2: begin // corrector kicks: oco only
      for i:=0 to nloop-1 do with OrbLoop[i] do if (result < 30) then begin //exclude non-ex corr orbits
        Inc(nval);
        xmean:=xmean+xcor[1];  //xrms :=xrms+sqr(xcor[1]); //mean(sigma) and rms(sigma)
        if xcor[2] > xmax then xmax:=xcor[2];      // max(max)
        ymean:=ymean+ycor[1];  //yrms :=yrms+sqr(ycor[1]);
        if ycor[2] > ymax then ymax:=ycor[2];
        if xcor[1] > xrms then xrms:=xcor[1]; //max rms
        if ycor[1] > yrms then yrms:=ycor[1];
      end;
    end;
  end;
  if nval>0 then begin
    xmean:=xmean/nval;  // xrms:=sqrt(abs(xrms/nval-sqr(xmean))); //insert abs to avoid crash for zero-roundoff
    ymean:=ymean/nval;  // yrms:=sqrt(abs(yrms/nval-sqr(ymean)));
  end;
  LoopStatCalc:=nval;
end;

procedure oco_init;
begin
  setlength(bvecx,nocom+1);
  setlength(bvecy,nocom+1);
  setlength(cvecx,nocox+1);
  setlength(cvecy,nocoy+1);
  OrbitReCalc;
  COCorrstatus:=0;
  CODpenalty:=0;
  codstatmode:=0;
end;

procedure oco_step;
var
  i: integer;
begin
  for i:=0 to nocom-1 do with bpm[iocom[i]] do begin
    bvecx[i+1]:=Opval[0,ilatb].orb[1]-Lattice[ilatb].dx-ref[0];
    bvecy[i+1]:=Opval[0,ilatb].orb[3]-Lattice[ilatb].dy-ref[1];
  end;
  SVBKSB(ocoAUx,ocoWxuse,ocoVx,nocom,nocox,bvecx,cvecx);
  SVBKSB(ocoAUy,ocoWyuse,ocoVy,nocom,nocoy,bvecy,cvecy);
  for i:=0 to nocox-1 do with cor[iocox[i]] do with Ella[jella] do dxp:=dxp-cvecx[i+1];
  for i:=0 to nocoy-1 do with cor[iocoy[i]] do with Ella[jella] do dyp:=dyp-cvecy[i+1];
  OrbitReCalc;
end;

procedure oco_term;
begin
  bvecx:=nil; bvecy:=nil; cvecx:=nil; cvecy:=nil;
end;



//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// procs for injection  mode
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure SyncKickers;
var
  tof: real;
  i, j: integer;
begin
  tof:=0;
  for i:= 1 to Glob.NLatt do begin
    j:=FindEl(i);
    with Ella[j] do begin
      if cod = ckick then begin
        delay:=tof; //time at entry to kicker
      end;
      tof:=tof+Ella[j].l/speed_of_light;
    end; //with
  end;
end;

//-----------------------------------------------------------
// used by opageometry only
//-----------------------------------------------------------

procedure GeoInit;
var
  i: integer;
begin
   GirderSetup;
  // find variables staring wiht 'G' to be used for geo matching
   // to do: check that the variables used are primary, i.e. plain values, otherwise it will not work.
  ngeovar:=0;
  for i:=0 to High(Variable) do Variable[i].use:=false;
  for i:=1 to Glob.NElla do if Ella[i].cod in [cdrif,cbend, ccomb,crota] then Ella_Eval(i); //just to set the use flag of variable
  for i:=0 to High(Variable) do if Pos('G',Variable[i].nam)<>1 then Variable[i].use:=false else inc(ngeovar); //use only G... variables

  for i:=0 to NGEdit do begin
    edg_val[i] :=FDefGet('tgeom/'+edparname[i]);
    edg_goal[i]:=FDefGet('tgeom/'+edparname[i]+'g');
  end;

  for i:=0 to ngedit do matchfunc[i]:=false;
  setlength(matchknob,ngeovar);
  for i:=0 to ngeovar-1 do matchknob[i]:=false;

  geofiles:=nil;

end;

procedure GeoExit;  // called at regular exit
var
  i: integer;
begin
  for i:=0 to NParam-1 do DefSet('tgeom/'+ParamName[i],Param[i]);
  for i:=0 to NGEdit do DefSet('tgeom/'+edparname[i],edg_val[i]);
  for i:=0 to NGEdit do DefSet('tgeom/'+edparname[i]+'g',edg_goal[i] );

end;

procedure GeoClose;   //called onClose of Form
begin
  if fpoly  <> nil then fpoly  :=nil;
  if ptx    <> nil then ptx    :=nil;
  if pty    <> nil then pty    :=nil;
  if midpt  <> nil then midpt  :=nil;
  if vpt    <> nil then vpt    :=nil;
  if iknob  <> nil then iknob  :=nil;
  if knob   <> nil then knob   :=nil;
  if dknob  <> nil then dknob  :=nil;
  if knob0  <> nil then knob0  :=nil;
  if ifunc  <> nil then ifunc  :=nil;
  if func   <> nil then func   :=nil;
  if funct  <> nil then funct  :=nil;
  if func0  <> nil then func0  :=nil;
end;




function CalcOrbit: boolean;
// calc orbit from zerovec/unitmat and never change it.
// all later translations are rotations are in viniact, moriact

var
  xpos, ypos, zpos, angy, angs, angx, angle, curv, rad, ds, leng, alc: real;
  i, j: integer;
  vpsi, vpsm, vpsx, tram, trax: Vektor_3;
  mori, morm, morx, mlcm, mlcx, mrin, mrex: Matrix_3;


begin
  if midpt <> nil then midpt :=nil;
  Xpos :=0; Ypos :=0; Zpos :=0; // start at zero position, because later shifts cheap
  angy:=0; angx:=0; angs:=0;
  // hall coordinates XYZ, beam coordinates sxy start direction 1,0,0
  morini0:=MatMul3(RotMat3(1,angs), MatMul3(RotMat3(2,angx), RotMat3(3,angy)));
  vini0:=VecSet3(Xpos, Ypos, Zpos);
// morini0 is unitmat, vini0 is zerovec, this never changes but keep it for generality
  moriact:=morini0;
  viniact:=vini0;
  moripre:=moriact;
  vinipre:=viniact;
  leng :=0.0;
  angini0:=0;
  angbendoffset:=0;

  angle:=angy; // for compatibility: accumulated bend angle, not taking into rotations etc.

  {  **  uncomment for test
  fnam:=ExtractFileName(FileName);
  fnam:=work_dir+Copy(fnam,0,Pos('.',fnam)-1);
  fnam:=fnam+'_lineup.txt';
  AssignFile(fot,fnam);}
{$I-}
//  rewrite(fot);
{$I+}

  with inipt do begin
    vm:=vini0; s:=0.0; ang:=angle; cur:=0.0; mor:=morini0;
  end;

  vpsi:=vini0;
  mori:=morini0;
  for i:=1 to Glob.Nlatt do begin
    j:=Findel(i);
    alc:=0; curv:=0; ds:=0; //tmp
    tram:=VecSet3(0,0,0); trax:=tram;
    morm:=mori; morx:=mori; vpsm:=vpsi; vpsx:=vpsi;
    with Ella[j] do begin
      if l<>0 then begin
        tram[1]:=l/2;
        trax[1]:=l;
        ds:=l/2;
        if cod in [cbend, ccomb] then begin
// bend = rotation around y
          if cod=cbend then alc:= -phi else alc:= -cphi; //pos angle CCW, but pos bend angle is CW
          if alc <> 0 then begin
            rad:=l/alc;
            tram:=VecSet3(sin(alc/2)*rad, (1-cos(alc/2))*rad, 0);
            trax:=VecSet3(sin(alc  )*rad, (1-cos(alc  ))*rad, 0);
            mlcm:=RotMat3(3,alc/2);
            mlcx:=RotMat3(3,alc  );
            if rot<>0 then begin
              mrin:=RotMat3(1,rot); mrex:=RotMat3(1,-rot);
              mlcm:=MatMul3(mrin, mlcm);
              mlcx:=MatMul3(MatMul3(mrin, mlcx),mrex);
              tram:=LinTra3(mrin, tram);
              trax:=LinTra3(mrin, trax);
            end;
            morm:=MatMul3(mori,mlcm);
            morx:=MatMul3(mori,mlcx);
            curv:= 1/rad; //tmp
          end;
        end; // bend
        vpsm:=VecAdd3(Lintra3(mori,tram),vpsi); //translation to midpoint of element
        vpsx:=VecAdd3(Lintra3(mori,trax),vpsi); //translation to end of element
// 2do: all elements (long or short): if rot<>0 apply +rot/-rot to get orientation of midpt
      end else begin
        if cod = crota then begin
          if rot<>0 then begin
// rotation around s
            mlcm:=RotMat3(1,rot/2);
            mlcx:=RotMat3(1,rot  );
            morm:=MatMul3(mori,mlcm); //orientation mid
            morx:=MatMul3(mori,mlcx); //orientation exit
          end;
        end;
      end; //l=0
     end; //with

     setLength(midpt, Length(midpt)+1);
     with midpt[High(midpt)] do begin
       jel:=j;
       cod:=Ella[j].cod;
       nam:=Ella[j].nam;
       inv:= Lattice[i].inv < 0;
       igir:=Lattice[i].igir;
       skp:=false;

       mor:=morm; //midpoint orientation and position
       v0:=vpsi; v1:=vpsx; vm:=vpsm;

//       x:=vpsm[1]; y:=vpsm[2]; z:=vpsm[3];
//       x0:=vpsi[1]; y0:=vpsi[2]; z0:=vpsi[3];
//       x1:=vpsx[1]; y1:=vpsx[2]; z1:=vpsx[3];

       ang:=angle+alc/2; //tmp, why angle? (midpoint angle ? ever used?)

       cur:=curv; //tmp
       ang0:=angle;
       ang1:=angle+alc;
       s:=leng+ds; s0:=leng; s1:=leng+2*ds;
     end;

//travelling local direction (beam direction)

{ **
     locdir:=Lintra3(morx,vecset3(1,0,0));
     writeln(fot,ella[j].cod, vpsx[1]:15:8,vpsx[2]:15:8, vpsx[3]:15:8, locdir[1]:15:8, locdir[2]:15:8, locdir[3]:15:8, RadToDeg(angle+alc/2):15:8, RadToDeg(qarctan2(Midpt[High(midpt)].mor[1,1], Midpt[High(midpt)].mor[2,1])):15:8, Ella[j].l:10:3, leng:15:6, '  ', Ella[j].nam);
     writeln(fot, '           ', morx[1,1]:15:8,morx[1,2]:15:8,morx[1,3]:15:8);
     writeln(fot, '           ', morx[2,1]:15:8,morx[2,2]:15:8,morx[2,3]:15:8);
     writeln(fot, '           ', morx[3,1]:15:8,morx[3,2]:15:8,morx[3,3]:15:8);
}

     mori:=morx;
     vpsi:=vpsx;
     leng:=leng+2*ds;
     angle:=angle+alc; //tmp
  end; //lattice i

  morfin0:=morx;
  vfin0:=vpsx;
  angfin0:=angle;

  with finpt do begin
    vm:=vpsx; s:=leng; ang:=angle; cur:=0.0; mor:=morx;
  end;

  sfulllength:=leng;

//  closefile(fot);

  // check for markers for automatic centering, determine 'center of mass'
  ncentermark:=0;
  vcenter0:=VecSet3(0,0,0);
  for i:=0 to High(midpt) do with midpt[i] do
  if (CompareText(nam, 'center')=0) and (cod=cmark) then begin
    vcenter0:=VecAdd3(vm, vcenter0);
    Inc(ncentermark);
  end;
  if ncentermark > 0 then begin
    vcenter0:=VecSca3(vcenter0, 1./ncentermark);
    calcorbit:=True;
  end else calcorbit:=False;
end;



procedure TransPoly;
var
  i: integer;
  mortra: matrix_3; vectra: Vektor_3;
begin
  mortra:=matmul3(moriact, matinv3(moripre));
  vectra:=vecsub3(viniact, LinTra3(mortra, vinipre));
  for i:=0 to High(midpt) do with midpt[i] do begin
    vm:=VecAdd3(vectra, Lintra3(mortra, vm));
    v0:=VecAdd3(vectra, Lintra3(mortra, v0));
    v1:=VecAdd3(vectra, Lintra3(mortra, v1));
    ang:=ang+angbendoffset;
    ang0:=ang0+angbendoffset;
    ang1:=ang1+angbendoffset;
    mor:=MatMul3(mortra, mor);
  end;
  with inipt do begin
    vm:=VecAdd3(vectra, Lintra3(mortra, vm));
    mor:=MatMul3(mortra, mor);
    ang:=ang+angbendoffset;
  end;
  with finpt do begin
    vm:=VecAdd3(vectra, Lintra3(mortra, vm));
    mor:=MatMul3(mortra, mor);
    ang:=ang+angbendoffset;
  end;

//transform all points of faces
  for i:=0 to High(vpt) do begin
    vpt[i]:=VecAdd3(vectra, LinTra3( mortra, vpt[i]));
  end;
  CalcPoly;
end;


procedure CalcPoly; // from faces (3D, vpt, face) to polygons (poly, ptx/y)
// later: 3D and clip
var
  iface, k: integer;
begin
  fpoly:=nil; ptx:=nil; pty:=nil;
  for iface:=0 to High(face) do with face[iface] do begin
    // later: eliminate all non visible tiles
    setLength(fpoly, length(fpoly)+1);
    with fpoly[High(fpoly)] do begin
      npp:=npt;
      isp:=Length(ptx);
      setlength(ptx,isp+npp); setlength(pty,isp+npp);
      for k:=0 to npp-1 do begin
        ptx[isp+k]:=vpt[ist+k+1][1]; pty[isp+k]:=vpt[ist+k+1][2];
      end;
      c:=col; cf:=dimcol(col, clwhite,0.5);
    end;
  end;
end;



procedure CalcFaces;
{create a list of polygons (poly) and points (vpt) }
var
  woff, minphi, beyw, quyw,mpyw, mpyl, unyw, xmrl,driw, monw, corw, corl, osml, osmw, marl, gwid1, gwid2, gwid3: real;
  ipm, iphi, nphi, ip,i, ikind, im, icod, igi, iface, k, nface: integer;
  hlen, hwid, hhgt, ang: real;
//  px, py: array of real;
  tmp: real;
  rho, phi, dphi, edge1, edge2,
    p1inner, p2inner, p1outer, p2outer, pinner, pouter,
    cang_p, cang_m, xorb, yorb, angedge: real;
  gcol: TColor;
//  globvecs: Vektor_3;
  xinner, yinner, xouter, youter: array of Real;
  col: TColor;
  glenvec, gmidvec: Vektor_3;
  gmorang: Matrix_3;


  procedure makesolid (color: TColor; hlen, hwid, hhgt: real);
  begin
    nface:=1;
    setLength(face, Length(face)+nface);   //writeln(diagfil, 'high ',High(face), ' ', nface)
    // for the moment, only top face of magnet:
    with face[High(face)] do begin
      npt:=4;
      col:=color;
      vis:=0;
      ist:=Length(vpt);
      setLength(vpt,Length(vpt)+npt+1);
      vpt[ist  ]:=VecSet3(0,0,1);
      vpt[ist+1]:=VecSet3(-hlen,-hwid, hhgt);
      vpt[ist+2]:=VecSet3( hlen,-hwid, hhgt);
      vpt[ist+3]:=VecSet3( hlen, hwid, hhgt);
      vpt[ist+4]:=VecSet3(-hlen, hwid, hhgt);
    end;
  end;


begin
//  if ptx  <> nil then ptx :=nil;
//  if pty  <> nil then pty :=nil;
  if vpt  <> nil then vpt:=nil;
  if face  <> nil then face:=nil;
//  if fpoly <> nil then fpoly:=nil;

  ip:=0;  beyw:=Param[ip]/2;
  Inc(ip);quyw:=Param[ip]/2;
  Inc(ip);mpyw:=Param[ip]/2;
  Inc(ip);mpyl:=Param[ip]/2;
  Inc(ip);unyw:=Param[ip]/2;
  Inc(ip);xmrl:=Param[ip]  ;
  Inc(ip);driw:=Param[ip]/2;
  Inc(ip);monw:=Param[ip]/2;
  Inc(ip);corw:=Param[ip]  ;
  Inc(ip);corl:=Param[ip]/2;
  Inc(ip);marl:=Param[ip]/2;
  Inc(ip);gwid1:=Param[ip]/2;
  Inc(ip);gwid2:=Param[ip]/2;
  Inc(ip);gwid3:=Param[ip]/2;

//tmp
  osml:=monw; osmw:=2*osml;

// midpt starts at 0, Lattice at 1 !  (not very nice, to do better...  oct 2017)
  for igi:=0 to NGirderLevel[3]-1 do with Girder[igi] do begin
    if igi >= NGirderLevel[2] then begin
      hwid:=gwid3; gcol:=clBlack;
    end else if igi>=NGirderLevel[1] then begin
      hwid:=gwid2; gcol:=clGray;
    end else begin
      hwid:=gwid1;  gcol:=clSilver;
    end;

    glenvec:=vecsub3(midpt[ilat[1]-1].v1, midpt[ilat[0]-1].v0);
    hlen:=vecabs3(glenvec)/2;
    gmidvec:=vecsca3(vecadd3(midpt[ilat[1]-1].v1, midpt[ilat[0]-1].v0), 0.5); //midpt of girder

    // temp only flat girders, later for 3D...
    makesolid(gcol, hlen, hwid, 0);

    ang:=arctan2(glenvec[2],glenvec[1]);
    gmorang:=RotMat3(3,ang);

    // nface is set in makesolid !
    for iface:=High(face)-nface+1 to High(face) do with face[iface] do begin
      for k:=0 to npt do vpt[ist+k]:=VecAdd3(gmidvec, LinTra3(gmorang, vpt[ist+k]));
    end;


//    ang:=(midpt[ilat[0]-1].ang+midpt[ilat[1]-1].ang)/2;
{
    cc:=cos(ang); ss:=sin(ang);
    x0:=(midpt[ilat[1]-1].x+midpt[ilat[0]-1].x)/2;      // not precise, gives shift if first/last elements have different length
    y0:=(midpt[ilat[1]-1].y+midpt[ilat[0]-1].y)/2;      // to be improved
}
{    for i:=0 to n-1 do begin
      dx:=px[i]; dy:=py[i];
      px[i]:=dx*cc-dy*ss+x0;
      py[i]:=dy*cc+dx*ss+y0;
    end;

    noff:=Length(gptx);
    setlength(gptx,noff+n);
    setlength(gpty,noff+n);
    for i:=0 to n-1 do begin
      ig:=noff+i;
      gptx[ig]:=px[i]; gpty[ig]:=py[i];
    end;
    setLength(poly,Length(poly)+1);
    with poly[High(poly)] do begin
      ist:=noff; npt:=n; col:=gcol;
    end;
    px:=nil; py:=nil;
}
  end;

  for ikind:=0 to NElemKind do begin
    icod:=ElemDrawOrder[ikind];
    for im:=0 to High(midpt) do if midpt[im].cod = icod then begin
      if ella[midpt[im].jel].l<>0 then hlen:=ella[midpt[im].jel].l/2 else hlen:=marl;
      hhgt:=hwid;
      hhgt:=0;
      nface:=0;
      col:=elemcol[icod];

      case icod of
        cdrif: begin
          if ella[midpt[im].jel].block then begin
            hwid:=2*driw; col:=dimcol(ElemCol[icod],clBlack,0.5) end else hwid:=driw;
          makesolid(col, hlen, hwid, hhgt);
        end;
        cquad, csole, ckick: begin
          hwid:=quyw;
          makesolid(col, hlen, hwid, hhgt);
        end;
        cundu: begin
          hwid:=unyw;
          makesolid(col, hlen, hwid, hhgt);
        end;
        csext: begin
          hwid:=mpyw; if ella[midpt[im].jel].l=0 then hlen:=mpyl; // else was set to l
          makesolid(col, hlen, hwid, hhgt);
        end;
        cmpol: begin
          hwid:=mpyw; hlen:=mpyl;
          makesolid(col, hlen, hwid, hhgt);
        end;
        cbend,ccomb: begin
          hwid:=beyw;
          if abs(midpt[im].cur)>0 then begin
            minphi:=0.17; //170 mrad ~ 10 deg //test     --> make editable
            phi:=-midpt[im].cur*2*hlen;
            nphi:= round(int(abs(phi)/minphi))+1;
            dphi:= phi/nphi;
            case icod of
              cbend: begin
                edge1:=ella[midpt[im].jel].tin;
                edge2:=ella[midpt[im].jel].tex;
              end;
              ccomb: begin
                edge1:=ella[midpt[im].jel].cerin;
                edge2:=ella[midpt[im].jel].cerex;
              end;
              else begin edge1:=0; edge2:=0; end;
            end;
            if midpt[im].inv then begin
              tmp:=edge1; edge1:=edge2; edge2:=tmp;
            end;
            nface:=nphi;
            setlength(face, length(face)+nface);    //writeln(diagfil, 'high ',High(face), ' ', nface);
            rho:=-1.0/midpt[im].cur;
            //entry point
            yorb:=-rho*sin(phi/2); xorb:=rho*(1-cos(phi/2)); angedge:=phi/2-edge1;
            if IntersectLineCircle(xorb,yorb,angedge,  rho,0,rho+hwid, cang_p, cang_m)=2
            then p1outer:=Pi-cang_m else p1outer:=-phi/2;
            if IntersectLineCircle(xorb,yorb,angedge,  rho,0,rho-hwid, cang_p, cang_m)=2
            then p1inner:=Pi-cang_m else p1inner:=-phi/2;
            yorb:= rho*sin(phi/2); xorb:=rho*(1-cos(phi/2)); angedge:=-phi/2+edge2;
            if IntersectLineCircle(xorb,yorb,angedge,  rho,0,rho+hwid, cang_p, cang_m)=2
            then p2outer:=Pi-cang_m else p2outer:= phi/2;
            if IntersectLineCircle(xorb,yorb,angedge,  rho,0,rho-hwid, cang_p, cang_m)=2
            then p2inner:=Pi-cang_m else p2inner:= phi/2;
            iface:=High(face)-nface+1;       //writeln(diagfil, '    iface ', iface, nphi);
            setlength(xinner,nphi+1);   setlength(yinner,nphi+1);
            setlength(xouter,nphi+1);   setlength(youter,nphi+1);
            for iphi:=0 to nphi do begin
              pouter:=p1outer+iphi*(p2outer-p1outer)/nphi;
              pinner:=p1inner+iphi*(p2inner-p1inner)/nphi;
              xouter[iphi]  :=Sin(pouter)*(rho+hwid);
              youter[iphi]  :=Cos(pouter)*(rho+hwid)-rho;
              xinner[iphi]  :=Sin(pinner)*(rho-hwid);
              yinner[iphi]  :=Cos(pinner)*(rho-hwid)-rho;
            end;
            for iphi:=0 to nphi-1 do with face[iface+iphi] do begin // sector wise
              npt:=4;
              ist:=Length(vpt);
              setLength(vpt,Length(vpt)+npt+1);
              vpt[ist  ]:=VecSet3(0,0,1); //normal
              vpt[ist+1]:=VecSet3(xinner[iphi  ],yinner[iphi  ],hhgt);
              vpt[ist+2]:=VecSet3(xinner[iphi+1],yinner[iphi+1],hhgt);
              vpt[ist+3]:=VecSet3(xouter[iphi+1],youter[iphi+1],hhgt);
              vpt[ist+4]:=VecSet3(xouter[iphi  ],youter[iphi  ],hhgt);
              col:=ElemCol[icod];
              vis:=0;
            end;
          end else makesolid(icod, hlen, hwid, hhgt);
        end;
        cxmrk: begin
          hlen:=xmrl*ella[midpt[im].jel].xl;
          nface:=1;
          setLength(face, Length(face)+nface);
          with face[High(face)] do begin
            npt:=3;
            col:=ElemCol[icod];
            vis:=0;
            ist:=Length(vpt);
            setLength(vpt,Length(vpt)+npt+1);
            vpt[ist  ]:=VecSet3(0,0,1);
            vpt[ist+1]:=VecSet3(0,0, hhgt);
            vpt[ist+2]:=VecSet3(hlen, driw, hhgt);
            vpt[ist+3]:=VecSet3(hlen,-driw, hhgt);
          end;
        end;
        comrk: if ella[midpt[im].jel].screen then begin
          nface:=1;
          setLength(face, Length(face)+nface);
          with face[High(face)] do begin
            npt:=3;
            col:=ElemCol[icod];
            vis:=0;
            ist:=Length(vpt);
            setLength(vpt,Length(vpt)+npt+1);
            vpt[ist  ]:=VecSet3(0,0,1);
            vpt[ist+1]:=VecSet3(-osml,-osmw, hhgt);
            vpt[ist+2]:=VecSet3( osml, osmw, hhgt);
            vpt[ist+3]:=VecSet3( osml,-osmw, hhgt);
          end;
        end;
        cmoni: begin
          nface:=2;
          setLength(face, Length(face)+nface);   //writeln(diagfil, 'high ',High(face), ' ', nface)
          for i:=0 to 1 do with face[High(face)-i] do begin
            ipm:=1-2*i;
            npt:=3;
            col:=ElemCol[icod];
            vis:=0;
            ist:=Length(vpt);
            setLength(vpt,Length(vpt)+npt+1);
            vpt[ist  ]:=VecSet3(0,0,1);
            vpt[ist+1]:=VecSet3(-monw/2,2*ipm*driw, hhgt);
            vpt[ist+2]:=VecSet3( monw/2,2*ipm*driw, hhgt);
            vpt[ist+3]:=VecSet3( 0, ipm*(2*driw+monw), hhgt);
          end;
        end;
        ccorh: begin
//          woff:=mpyw+driw;
          nface:=1;
          setLength(face, Length(face)+nface);
          with face[High(face)] do begin
            npt:=4;
            col:=ElemCol[icod];
            vis:=0;
            ist:=Length(vpt);
            setLength(vpt,Length(vpt)+npt+1);
            vpt[ist  ]:=VecSet3(0,0,1);
            vpt[ist+1]:=VecSet3(-corl,-corw, hhgt);
            vpt[ist+2]:=VecSet3( corl,-corw, hhgt);
            vpt[ist+3]:=VecSet3( corl, corw, hhgt);
            vpt[ist+4]:=VecSet3(-corl, corw, hhgt);
          end;
        end;
        ccorv: begin
          woff:=mpyw+driw;
          nface:=2;
          setLength(face, Length(face)+nface);
          for i:=0 to 1 do with face[High(face)-i] do begin
            ipm:=1-2*i;
            npt:=4;
            col:=ElemCol[icod];
            vis:=0;
            ist:=Length(vpt);
            setLength(vpt,Length(vpt)+npt+1);
            vpt[ist  ]:=VecSet3(0,0,1);
            vpt[ist+1]:=VecSet3(-corl,ipm*(woff), hhgt);
            vpt[ist+2]:=VecSet3( corl,ipm*(woff), hhgt);
            vpt[ist+3]:=VecSet3( corl,ipm*(woff+2*corw), hhgt);
            vpt[ist+4]:=VecSet3(-corl,ipm*(woff+2*corw), hhgt);
          end;
        end;
        else
      end; // case icod
      if nface>0 then begin
        for iface:=High(face)-nface+1 to High(face) do with face[iface] do begin
          for k:=0 to npt do vpt[ist+k]:=VecAdd3(midpt[im].vm, LinTra3(midpt[im].mor, vpt[ist+k]));
        end;
      end;
    end; //midpt
  end; //draworder
end;

procedure TransRot;
// translation and rotation of orbit etc. as stored in midpt
var
  xpos, ypos, zpos, angy, angx, angs: double;
  i: integer;
  morf, r: Matrix_3;
begin
  xpos:=0; ypos:=0; zpos:=0; angy:=0; angx:=0; angs:=0;
  moripre:=moriact; vinipre:=viniact;

  case drawmode of

   -1: begin // zero point
      moriact:=morini0; morf:=morfin0;
      viniact:=vini0;   vfin:=vfin0;
    end;

    0: begin //center
      angy:=DegToRad(edg_val[ianzi]); //first rot around Z(y) in XY plane
      angx:=DegToRad(edg_val[ianxi]); //second rot around X'(x) in ZS' plane
      angs:=DegToRad(edg_val[iansi]); //third rot around S''(s) in X''Y'' plane

      moriact:=MatMul3(RotMat3(1,angs), MatMul3(RotMat3(2,angx), RotMat3(3,angy)));

      Viniact:=LinTra3(moriact, VecSub3(vini0, vcenter0)); // Mact* (-(vc-xi0))

      vfin:=VecAdd3 (viniact, LinTra3(moriact, VecSub3(vfin0,vini0)));
      morf:=MatMul3(moriact, morfin0);

      angbendoffset:=angy-angini0; // offset for accumulated bending angle

    end;

    1: begin
      Xpos :=edg_val[ixini];
      Ypos :=edg_val[iyini];
      Zpos :=edg_val[izini];
      angy:=DegToRad(edg_val[ianzi]); //first rot around Z(y) in XY plane
      angx:=DegToRad(edg_val[ianxi]); //second rot around X'(x) in ZS' plane
      angs:=DegToRad(edg_val[iansi]); //third rot around S''(s) in X''Y'' plane

      moriact:=MatMul3(RotMat3(1,angs), MatMul3(RotMat3(2,angx), RotMat3(3,angy)));
      viniact:=VecSet3(Xpos, Ypos, Zpos);
      vfin:=VecAdd3 (viniact, LinTra3(moriact, VecSub3(vfin0,vini0)));
      morf:=MatMul3(moriact, morfin0);

      angbendoffset:=angy-angini0; // offset for accumulated bending angle
//      writeln(diagfil, 'setdrawmode angy angbendoffset ',degrad*angy, degrad*angbendoffset);
    end;

    2: begin
      Xpos :=edg_val[ixfin];
      Ypos :=edg_val[iyfin];
      Zpos :=edg_val[izfin];
      angy:=DegToRad(edg_val[ianzf]); //first rot around Z(y) in XY plane
      angx:=DegToRad(edg_val[ianxf]); //second rot around X'(x) in ZS' plane
      angs:=DegToRad(edg_val[iansf]); //third rot around S''(s) in X''Y'' plane

      morf:=MatMul3(RotMat3(1,angs), MatMul3(RotMat3(2,angx), RotMat3(3,angy)));
      vfin:=VecSet3(Xpos, Ypos, Zpos);

      r:=MatMul3(morf, MatInv3(morfin0));
      viniact:=VecSub3(vfin, LinTra3(r, VecSub3(vfin0,vini0)));
      moriact:=matMul3(r, morini0);

      angbendoffset:=angy-angfin0; // offset for accumulated bending angle
    end;

    {3...n: later, start from any point geomarker, opticsmarker?}

  end;
  Eulerang(moriact, angy, angx, angs, false);
  angvi:=VecSet3(angx,angy,angs);
  Eulerang(morf,    angy, angx, angs, false);
  angvf:=VecSet3(angx,angy,angs);
end;




procedure GeoMinMax;
var
  k,i: integer;

begin
  xmin:=1e6; xmax:=-1e6; ymin:=1e6; ymax:=-1e6;
  for i:=0 to High(fpoly) do with fpoly[i] do for k:=isp to isp+npp-1 do begin
    if xmax < ptx[k] then xmax:=ptx[k];
    if xmin > ptx[k] then xmin:=ptx[k]; // beg... imin:=i; end;
    if ymax < pty[k] then ymax:=pty[k];
    if ymin > pty[k] then ymin:=pty[k];
  end;
  xfullwidth:=(xmax-xmin)*1.0;
  yfullwidth:=(ymax-ymin)*1.0;
  xcenter:=(xmin+xmax)/2;
  ycenter:=(ymin+ymax)/2;
end;

procedure WriteGeoFiles;
const
  i2stop=999999;
  null=0.0;
var
  i,k,j,ipospipe: integer;
  f, fr: TextFile;
  i1, i2, ico, igt: integer;
  sini, sfin, aini, afin, xini, yini, xfin, yfin, radius, xvert, yvert, dvert1, dvert2, curv, erad, ecri: real;
  np: NameListpt;
  realname, typename:string;
  gmode: boolean;
  gt3list: array of integer;
  fname: string;
  El: elementtype;
  dang, ein, eot, kv: real;

begin
  fname:=ExtractFileName(FileName);
  fname:=Copy(fname,0,Pos('.',fname)-1);
  fname:=work_dir+fname;

//Positions file, list of elements and positions from start to end
  AssignFile(f,fname+'_pos.txt');
{$I-}
  rewrite(f);
{$I+}
  if IOResult =0 then begin
    writeln(f,'# Table of elements and orbit coordinates');
    writeln(f,'#  Name                  X0[mm]      Y0[mm]      S0[mm]     W0[deg]         X1[mm]      Y1[mm]      S1[mm]     W1[deg]      1/R[1/m]');
    writeln(f,'#-----------------------------------------------------------------------------------------------------------------------------------');
    for i:=0 to High(midpt) do with midpt[i] do begin
      write(f,ElemShortName[cod]+' '+nam); for k:=length(nam) to 15 do write(f,' ');
      writeln(f, v0[1]:12:6, v0[2]:12:6, s0:12:6, radtodeg(ang0):12:6, '   ', v1[1]:12:6, v1[2]:12:6, s1:12:6, radtodeg(ang1):12:6,'  ', cur:12:9);
    end;
    closefile(f);
  end;

//Temporary output of positions and element parameters (for cross-check with other code)
AssignFile(f,fname+'_mpo.txt');
{$I-}
rewrite(f);
{$I+}
if IOResult =0 then begin
  writeln(f,'# Table of elements and orbit coordinates');
  writeln(f,'#c Name                  L[m]     dW[deg]  GL[Tm^(2-n)]   W1[deg]     W2[deg]     Spos[m]       XV[m]       YV[m]');
  writeln(f,'#----------------------------------------------------------------------------------------------------------------');
  for i:=0 to High(midpt) do with midpt[i] do begin
    El:=Ella[jel];
    if El.cod in [Cquad, Cbend, Csext, Csole, Cundu, Ccomb, Cmpol, Ccorh,  Ccorv] then begin
      write(f,ElemShortName[el.cod]+' '+El.nam); for k:=length(El.nam) to 15 do write(f,' ');
      case El.cod of
        cbend: begin if inv then begin ein:=el.tex; eot:=el.tin; end else begin ein:=el.tin; eot:=el.tex; end; dang:=-el.phi; end;
        ccomb: begin if inv then begin ein:=el.cerex; eot:=el.cerin; end else begin ein:=el.cerin; eot:=el.cerex; end; dang:=-el.cphi; end;
        else begin ein:=0; eot:=0; dang:=0; end;
      end;
      kv:=-getkval(jel,0)*glob.energy*1e9/speed_of_light;
      if not (el.cod in [cmpol,csext]) then kv:=kv*el.l;

      if abs(ang0-ang1)>1e-6 then begin
        InterSectLines(v0[1], v0[2], ang0, v1[1], v1[2], ang1, xvert, yvert, dvert1, dvert2);
      end else begin
        xvert:=vm[1]; yvert:=vm[2];
      end;
      writeln(f,el.l:10:6, radtodeg(dang):12:6, kv:12:4, radtodeg(ang0-ein):12:6, radtodeg(ang1+eot):12:6, s:12:6, xvert:12:6, yvert:12:6);
    end;
  end;
  closefile(f);
end;

//Geometry file of polygons, to be read again to combine/compare lattices
  AssignFile(f,fname+'_geo.txt');
{$I-}
  rewrite(f);
{$I+}
  if IOResult =0 then begin
    writeln(f,'# Table of polygons');
    for i:=0 to High(fPoly) do with fPoly[i] do begin
      writeln( f, isp, ' ', npp, ' ', c, ' ',cf);
      for k:=0 to npp-1 do writeln(f, ptx[isp+k]:12:6, pty[isp+k]:12:6);
    end;
    closefile(f);
  end;

{"Holy List" and radiation files to construct excel table of devices
 combines compound devices (i.e. element line-up with either zero drift spaces between) or
   bracketed by girder type 3 markers.
 output sorted by element type.
 radiation file lists all bends (compound bends in slices) with their radiated energy
}
  AssignFile(f,fname+'_holy.txt');
  AssignFile(fr,fname+'_srad.txt');
{$I-}
  rewrite(f);
  rewrite(fr);
{$I+}
  if IOResult =0 then begin
    writeln(f,'  #Holy List');
    writeln(f,'#C     Name         Type    MidPos[mm]  ArcLen[mm]    Angle[°]    P1PV[mm]    PVP2[mm]	      X1[mm]      Y1[mm]      X2[mm]      Y2[mm]   Ang1[deg]   Ang2[deg]');
    writeln(f,'#---------------------------------------------------------------------------------------------------------------------------------------------------------------');
    writeln(fr,'  #Synchrotron Radiation Power List');
    writeln(fr,'#C     Name         Type    MidPos[mm]  ArcLen[mm]    Angle[°]    P1PV[mm]    PVP2[mm]	      X1[mm]      Y1[mm]      X2[mm]      Y2[mm]   Ang1[deg]   Ang2[deg]  E_rad[keV]  E_cri[keV]');
    writeln(fr,'#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
// merge split elements
// new allocation of realnames (if available), since they were wrongly assigned to split elements before

     dvert1:=0; dvert2:=0;
     realname:='HL-Start';
     write(f,'GM '+realname); for k:=length(realname) to 16 do write(f,' ');  write(f,'void ');
     with inipt do writeln(f, s*1000:12:3, null:12:3, null:12:6, null:12:3, null:12:3, '  ',
          vm[1]*1000:12:3, vm[2]*1000:12:3, vm[1]*1000:12:3, vm[2]*1000:12:3, radtodeg(ang):12:6, radtodeg(ang):12:6);
     realname:='HL-End';
     write(f,'GM '+realname); for k:=length(realname) to 16 do write(f,' ');  write(f,'void ');
     with finpt do writeln(f, s*1000:12:3, null:12:3, null:12:6, null:12:3, null:12:3, '  ',
          vm[1]*1000:12:3, vm[2]*1000:12:3, vm[1]*1000:12:3, vm[2]*1000:12:3, radtodeg(ang):12:6, radtodeg(ang):12:6);

// first select all compound elements, defined by bracket of type 3 girders:
    gt3list:=nil;
    for j:=1 to Glob.NElla do if Ella[j].cod=cgird then if Ella[j].gtyp=3 then begin
      setlength(gt3list,length(gt3list)+1);
      gt3list[High(gt3list)]:=j;
    end;

    for i:=0 to High(midpt) do midpt[i].skp:=false;
    gmode:=false;
    i1:=0;
    for igt:=0 to High(gt3list) do begin
      j:=gt3list[igt];
      np:=Ella[j].nl;
      for i:=0 to High(midpt) do begin
        if midpt[i].jel=j then begin
          if gmode then begin
            if Ella[j].nam=Ella[midpt[i1].jel].nam then begin
              i2:=i;
              for k:=i1+1 to i2-1 do midpt[k].skp:=true;
              if np<>nil then begin
                realname:=np.realname;
                typename:=np.typ_name;
                np:=np^.nex;
              end else begin
                realname:=Ella[j].nam;
                typename:=Ella[j].TypNam;
              end;
              ipospipe:=Pos('|',typename);
              if ipospipe >0 then begin
                if midpt[i].inv then typename:=Copy(typename,ipospipe+1,10) else typename:=Copy(typename,1,ipospipe-1);
              end;
              write(f,'MM '+realname); for k:=length(realname) to 16 do write(f,' ');
              write(f,typename);  for k:=length(typename) to 5 do write(f,' ');
              sini:=midpt[i1].s0;   sfin:=midpt[i2].s1;
              aini:=midpt[i1].ang0; afin:=midpt[i2].ang1;


              if abs(aini-afin)>1e-6 then begin
                InterSectLines(midpt[i1].v0[1], midpt[i1].v0[2], aini, midpt[i2].v1[1], midpt[i2].v1[2], afin, xvert, yvert, dvert1, dvert2);
                dvert2:=-dvert2;
              end else begin
                dvert1:=(sfin-sini)/2; dvert2:=dvert1;
              end;
              writeln(f, (sini+sfin)*500:12:3, (sfin-sini)*1000:12:3, radtodeg(afin-aini):12:6, dvert1*1000:12:3, dvert2*1000:12:3, '  ',
                 midpt[i1].v0[1]*1000:12:3, midpt[i1].v0[2]*1000:12:3, midpt[i2].v1[1]*1000:12:3, midpt[i2].v1[2]*1000:12:3,radtodeg(aini):12:6, radtodeg(afin):12:6);
            end;
            gmode:=false;
          end else begin
            gmode:=true;
            i1:=i;
          end;
        end;
      end;
    end;
    gt3list:=nil;

    for ico:=0 to NElemKind do
    if ico in [Cquad,Cbend,Csext,Csole,Cundu,Csept,Ckick,Ccomb,Cxmrk,Cmpol,Cmoni,Ccorh,Ccorv] then
    for j:=1 to Glob.NElla do begin
      if Ella[j].cod=ico then begin
        np:=Ella[j].nl;
        i1:=0;
        while i1 <= High(midpt) do begin
          if (j=midpt[i1].jel) {and ((not midpt[i1].skp) or (ico=Cxmrk)) } then begin
            i2:=i1;
            sini:=midpt[i1].s0;    aini:=midpt[i1].ang0;
            sfin:=midpt[i1].s1;    afin:=midpt[i1].ang1; // exit from midpt i1
            xini:=midpt[i1].v0[1];    yini:=midpt[i1].v0[2];
            xfin:=midpt[i1].v1[1];    yfin:=midpt[i1].v1[2];

// if another midpt is same element but no distance between, then merge:
//            while i2 <= High(midpt) do begin
            while i2 < High(midpt) do begin
              inc(i2);
// merge, if contact and same element. If only contact: continue searching, if other element: stop.
              if (abs(midpt[i2].s0 - sfin) < 1e-6) then begin
                if (midpt[i2].jel = midpt[i1].jel) then begin
                  sfin:=midpt[i2].s1; afin:=midpt[i2].ang1;
                  xfin:=midpt[i2].v1[1]; yfin:=midpt[i2].v1[2];
                  i1:=i2;
                end;
              end else i2:=i2stop; //terminate while loop
            end;
            if abs(aini-afin)>1e-6 then begin
              InterSectLines(xini, yini, aini, xfin, yfin, afin, xvert, yvert, dvert1, dvert2);
              dvert2:=-dvert2;
//              radius:=(sfin-sini)/(afin-aini);
            end else begin
              dvert1:=(sfin-sini)/2; dvert2:=dvert1;
//              radius:=0;
            end;
            if np<> nil then begin
              realname:=np.realname;
              np:=np^.nex;
            end else begin
              realname:=Ella[j].nam;
            end;
            typename:=Ella[j].TypNam;
            if (not midpt[i1].skp) or (ico=Cxmrk) then begin
              ipospipe:=Pos('|',typename);
              if ipospipe >0 then begin
                if midpt[i1].inv then typename:=Copy(typename,ipospipe+1,10) else typename:=Copy(typename,1,ipospipe-1);
              end;
              write(f,ElemShortName[ico]+' '+realname); for k:=length(realname) to 16 do write(f,' ');
              write(f,typename);  for k:=length(typename) to 5 do write(f,' ');
              writeln(f, (sini+sfin)*500:12:3, (sfin-sini)*1000:12:3, radtodeg(afin-aini):12:6, dvert1*1000:12:3, dvert2*1000:12:3, '  ',
                         xini*1000:12:3, yini*1000:12:3, xfin*1000:12:3, yfin*1000:12:3, radtodeg(aini):12:6, radtodeg(afin):12:6);
            end;
            if (ico=cbend) or (ico=ccomb) then begin
              if abs(sfin-sini)>1e-6 then begin
                curv:=abs(afin-aini)/(sfin-sini);
                erad:=1E-3*erad_factor*curv*abs(afin-aini)*powi(Glob.Energy,4); // = h*angle *E^4
                ecri:=1E-3*ecrit_factor*curv*sqr(Glob.Energy)*(glob.Energy*1e9/speed_of_light); // = E^2 B
                write(fr,ElemShortName[ico]+' '+realname); for k:=length(realname) to 16 do write(fr,' ');
                write(fr,typename);  for k:=length(typename) to 5 do write(fr,' ');
                writeln(fr, (sini+sfin)*500:12:3, (sfin-sini)*1000:12:3, radtodeg(afin-aini):12:6, dvert1*1000:12:3, dvert2*1000:12:3, '  ',
                         xini*1000:12:3, yini*1000:12:3, xfin*1000:12:3, yfin*1000:12:3, radtodeg(aini):12:6, radtodeg(afin):12:3, erad:12:3, ecri:12:3);
              end;
            end;
          end; // if j
          inc(i1);
        end; // while
      end; // ico
    end; //for...if etc.
    closefile(f);
    closefile(fr);
  end; //IOResult
end;

procedure ReadGeoFiles;
var
  igf: integer;

  procedure AddGeoData(gfile: string);
  var
    f: TextFile;
//    sty, sna, line: string;
//    xva: array[0..8] of real;
//    ibl, errcode, sumerr: integer;
    k ,noff, ist_dummy: integer;
  begin
    AssignFile(f,gfile);
{$I-}
    reset(f);
{$I+}
    if IOResult =0 then begin

{
      while not Eof(f) do begin
        readln(f,line);
        if Pos('#',line)=0 then begin
          ibl:=Pos(' ',line);
          sty:=trim(Copy(line,1,ibl));
          sna:=trim(Copy(line,ibl,15));
          line:=trim(Copy(line, ibl+15,1000));
$R-
          for i:=0 to 7 do begin
            ibl:=  Pos(' ',line);
            Val(trim(copy(line, 1,ibl)),xva[i],errcode);
            sumerr:=sumerr+errcode;
            line:=trim(Copy(line, ibl,1000));
          end;
          Val(line,xva[8],errcode);
          sumerr:=sumerr+errcode;
$R+
          if sumerr = 0 then begin
            setLength(midpt, Length(midpt)+1);
            with midpt[High(midpt)] do begin
              cod:=0; for k:=0 to NElemKind do if Pos(ElemShortName[k],sty)=1 then cod:=k;
              nam:=sna;
              x0  :=xva[0]/1000;              x1  :=xva[4]/1000;
              y0  :=xva[1]/1000;              y1  :=xva[5]/1000;
              s0  :=xva[2]/1000;              s1  :=xva[6]/1000;
              ang0:=degtorad(xva[3]);         ang1:=degtorad(xva[7]);
              cur :=xva[8];
            end;
          end;
           opamessage(0,inttostr(sumerr)+' '+inttostr(Length(midpt))+' '+ftos(xva[0],12,6));
        end;
}

      noff:=Length(ptx);
      readln(f); // skip 1st line comment
      while not eof(f) do begin
        setLength(fPoly, Length(fPoly)+1);
        with fPoly[High(fPoly)] do begin
          readln(f, ist_dummy, npp, c, cf);
          setLength(ptx, noff+npp);
          setLength(pty, noff+npp);
          for k:=0 to npp-1 do readln(f, ptx[noff+k], pty[noff+k]);
          isp:=noff; // new starting point for polygon
          Inc(noff, npp);
        end;
      end;
      closefile(f);
    end;
  end;

begin
  for igf:=0 to High(geofiles) do begin
    AddGeoData(geofiles[igf]);
  end;
end;

//geo matching

procedure gsetedgval;
begin
  Edg_Val[ixini]:=viniact[1];  Edg_Val[iyini]:=viniact[2];  Edg_Val[izini]:=viniact[3];
  Edg_Val[ixfin]:=vfin[1];     Edg_Val[iyfin]:=vfin[2];     Edg_Val[izfin]:=vfin[3];
  Edg_Val[ianzi]:=degrad*angvi[2];    Edg_Val[ianxi]:=degrad*angvi[1];    Edg_Val[iansi]:=degrad*angvi[3];
  Edg_Val[ianzf]:=degrad*angvf[2];    Edg_Val[ianxf]:=degrad*angvf[1];    Edg_Val[iansf]:=degrad*angvf[3];
  Edg_Val[ileng]:=finpt.s;
end;

procedure gmat_ini;
var
  i:integer;
begin
  setlength(iknob, Nmatchknob);
  setlength(knob , Nmatchknob);
  setlength(knob0, Nmatchknob);
  setlength(dknob, Nmatchknob);
  setlength(iedvar,Nmatchknob);

  setlength(ifunc, Nmatchfunc);
  setlength(func,  Nmatchfunc);
  setlength(funct, Nmatchfunc);
  setlength(func0, Nmatchfunc);

end;

procedure gmat_step;
{ONE step of geometry matching calculates the response matrix for changing variables,
sets up the SVD, applies it to the target vector and calculates a penalty function.
So the SVD matrices are only used locally here.
}
const
  kfrac=1.0; // could become var, <1 for partial application of result; not used.

var
  bvec, cvec, aumat, wvec, wvecu, vmat: array of real;
  jk,jf,j:integer;

begin
  setlength(aumat, Nmatchfunc*Nmatchknob);
  setlength(wvec,  Nmatchknob+1);
  setlength(wvecu, Nmatchknob+1);
  setlength(vmat,  NMatchknob*Nmatchknob);
  setlength(bvec, Nmatchfunc+1);
  setlength(cvec, Nmatchknob+1);

  // get current func and knob and calc (local) response (sensitivity) matrix by num. diff.:

  for jk:=0 to Nmatchknob-1 do begin
    knob[jk]:=Variable[iknob[jk]].val; // current knobs
    if abs(knob[jk]) > 1 then dknob[jk]:=kndiff*knob[jk] else dknob[jk]:=kndiff;
  end;

  for jk:=0 to Nmatchknob-1 do begin
    variable[iknob[jk]].val:=knob[jk]+dknob[jk];
    for j:=1 to Glob.NElla do Ella_Eval(j);
    CalcOrbit; //starts at zero
    TransRot;
    gsetedgval;
    for jf:=0 to Nmatchfunc-1 do  aumat[jf*Nmatchknob+jk] := (edg_val[ifunc[jf]]-func[jf])/dknob[jk]; //
    variable[iknob[jk]].val:=knob[jk];
  end;

  SVDCMP(AUmat, Nmatchfunc, Nmatchknob, Wvec, Vmat);

{   writeln(diagfil, 'weight factors'); // leading zero value
    for jk:=1 to Nmatchknob do write(diagfil, wvec[jk]); writeln(diagfil); writeln(diagfil);
}

  for jk:=0 to Nmatchknob do wvecu[jk]:=wvec[jk];  //filter here if needed
  for jf:=0 to Nmatchfunc-1 do bvec[jf+1]:=func[jf]-funct[jf]; bvec[0]:=0;

  SVBKSB(aumat,Wvecu,Vmat,Nmatchfunc, Nmatchknob, bvec, cvec);

  for jk:=0 to Nmatchknob-1 do knob[jk]:=knob[jk]-kfrac*cvec[jk+1];

  for jk:=0 to Nmatchknob-1 do begin
    variable[iknob[jk]].val:=knob[jk];
    for j:=1 to Glob.NElla do Ella_Eval(j);
    CalcOrbit;
    TransRot;
    gsetedgval;
  end;

  penal:=0;
  for jf:=0 to Nmatchfunc-1 do begin
    func[jf]:= edg_val [ifunc[jf]]; // current values
    penal:=penal+sqr(funct[jf]-func[jf]);
  end;
  penal:=sqrt(penal/penal0);
  inc(niter);
  failed:=(penal > penalmax) or (niter > nitermax);

  aumat:=nil; wvec:=nil; wvecu:=nil; vmat:=nil;
  bvec:=nil; cvec:=nil;
end;

procedure gmat_reset;
var
  jk, j: integer;
begin
  //reset in case of failure
  for jk:=0 to Nmatchknob-1 do variable[iknob[jk]].val:=knob0[jk];
  for j:=1 to Glob.NElla do Ella_Eval(j);
end;


end.

