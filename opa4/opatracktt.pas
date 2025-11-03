{
TO DO
Anpassung an 4D:
emittances (getan, coupling feld nur aktiv falls uncoupled)
normal mode curly H und dispersion, normal mode sigmas auch - oder besser in x und y rechnen, wegen aperturen
pos und neg RF-MA, Verbdindung zu RF bucket (status.rfaccep...) OK
Coulumb: hor und vert aperturen testen
}


unit opatracktt;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, asfigure, globlib, asaux, mathlib, tracklib,
  linoplib, Math, vgraph;

type

  { TtrackT }

  TtrackT = class(TForm)
    butt_F: TButton;
    butvzin: TBitBtn;
    butvzot: TBitBtn;
    fig: TFigure;
    butex: TButton;
    flofig: TFigure;
    p: TPaintBox;
    rbapr: TRadioButton;
    rbbeta: TRadioButton;
    rbhcy: TRadioButton;
    rbinvt: TRadioButton;
    rbinvtlog: TRadioButton;
    rbma: TRadioButton;
    rbsigma: TRadioButton;
    rbvol: TRadioButton;
    rbzeta: TRadioButton;
    rgshow: TRadioGroup;
    panin: TPanel;
    panot: TPanel;
    butt: TButton;
    butbreak: TButton;
    labtlincap: TLabel;
    labtlin: TLabel;
    labtdyncap: TLabel;
    labdyn: TLabel;
    butps: TButton;
    Butfile: TButton;
    butt_S: TButton;
    butplotleft: TButton;
    butplotzomin: TButton;
    butplotzomot: TButton;
    butplotright: TButton;
    chkRFL: TCheckBox;
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure rbClicked(Sender:TObject);
    procedure figpPaint(Sender: TObject);
    procedure butplotzoomClick(Sender: TObject);
    procedure butplotvzoomClick(Sender: TObject);
    procedure butpsClick(Sender: TObject);
    procedure ButfileClick(Sender: TObject);
    procedure buttClick(Sender: TObject);
    procedure butt_SClick(Sender: TObject);
    procedure butt_FClick(Sender: TObject);
    procedure butbreakClick(Sender: TObject);
    procedure butexClick(Sender: TObject);
  private
    plotmode, Nturns, my_width: integer;
    // beam values scaled by energy and coupling in SI units:
    Stune, E_E, U0_E, sigmaE_E, EmitX_EC, EmitY_EC, Qbunch, sigmaS, MA_rfp, MA_rfn, TT_lin, TT_dyn, dppRes: real;
    Tgasbsdyn, TgasBSlin, Tgasel, gasp, Tgaselacc: real;
    gasz, gasn: integer;
    TrackDone, TrackBreak, SyncMode: boolean;
    procedure edin_KeyPress(Sender: TObject; var Key: Char);
    procedure edin_Exit(Sender: TObject);
    procedure edin_Action(ed: TEdit);
    procedure Output(inp:integer);
    procedure ResizeAll;
    procedure CalcBeta (delta_s: real);
    procedure InitSigma;
    procedure CalcSigma;
    procedure CalcVolume;
    procedure CalcMAlin;
    procedure CalcAccEL;
    procedure CalcLifetime;
    function  TrackLat_0 (dpp, startPos: real): boolean;
    function  TrackLat_S (dpp, startPos: real): boolean;
    function  TrackLat   (dpp, startPos: real): boolean;
    function  Trackdbins (startPos, dini: real): real;
    procedure beforeTracking;
    procedure afterTracking;
    procedure TrackMAdyn;
    procedure TrackMA_FTT;
    procedure FloFigPlot (gray: boolean);
    procedure MakePlot;
    procedure SaveDefaults;
    procedure Exit;
  public
    procedure Start;    { Public-Deklarationen }
  end;

var
  trackT: TtrackT;

implementation

{$R *.lfm}

const
  min_width=800;
//  loinf =-1e20;
  hiinf = 1e20;
  lozero= 1e-12;
  nedit=12;
  iiall=0; iiener=1; iicoup=2; iiitot=3; iinbun=4; iivolt=5; iiharm=6; iidels=7; iidelp=8; iintur=9;
  iigasz=10; iigasn=11; iigasp=12;
  labin_cap: array[1..nedit] of string=('Energy [GeV]','Coupling [%]','Total beam current [mA]',
                                        'Number of bunches','Total cavity voltage [MV]','Harmonic number',
                                        'Longitudinal resolution ds [m]','Momentum resolution dp/p [%]',
                                        'Number of turns to track','Gas atomic number Z',
                                        'Gas atoms/molecule N ','Gas partial pressure [pbar]');
  formin_wid: array[1..nedit] of integer=(6,6,6,6,6,6,6,-2,6,2,2,6);
  formin_dec: array[1..nedit] of integer=(3,3,1,0,2,0,4, 1,0,0,0,3);

  loin_val: array[1..nedit] of real=(1e-6,0 ,lozero,1    ,lozero,1    ,lozero,1e-6,1.0,1,1,lozero);
  hiin_val: array[1..nedit] of real=(1e6,100,hiinf ,hiinf,hiinf ,hiinf,hiinf ,1   ,1e4,99,99,1e12);

  nout=13;
  ionper=1; iocirc=2; ioloss=3; iosige=4; ioemix=5; ioemiy=6; ioqbun=7; iosigs=8; iomarf=9; iostun=10;
  iotgel=11; iotgbs=12; iottou=13;
  labot_cap: array[1..nout] of string=('Periodicity','Circumference','Energy loss per turn [MeV]',
                                        'rms energy spread [%]','Horizontal emittance [nm rad]','Vertical emittance [nm rad]',
                                        'Charge per bunch [nC]','rms bunch length [mm]',
                                        'Momentum acceptance [%]','Synch. Tune (linear w/o HC)',
                                        'Gas elastic scattering T [h]','Gas bremsstrahlung T [h]',
                                        'Touschek scattering T [h]');
  formot_wid: array[1..nout] of integer=(6,8,6,6,8,8,6,6,6,7,7,7,7);
  formot_dec: array[1..nout] of integer=(0,3,3,4,6,6,3,2,3,5,3,3,3);

  ipbet=0; iphcy=1; ipenv=2; ipapr=3; ipvol=4; ipmac=5; ipzet=6; iptou=7; iplog=8;
  nplotmax=8;

type
  sigma_data = record
    s, bx, by, eta, x, y, vol, h, d, l, malin, mapos, maneg, zetalinneg, zetalinpos, zetaneg, zetapos, lrdyn, lrlin, fx, fw, mapos_f, maneg_f: real;
    act: boolean;
  end;

  apert_type = record s, x, y: real;  end;


  Rangetype = record
    betamin, betamax, dispfac: real; betastr: string;
    sigmamax, sigmayfac: real; sigmastr: string;
    malinmax, mamax: real; mastr: string;
    zetamax, lrmin, lrmax, volmax, hmax, apertmax: real;
    zoomfac: array[0..nplotmax] of real;
  end;

var
  edin_val: array[1..nedit] of real;
  edot_val: array[1..nout] of real;

  tsig: array of sigma_data;
  Range: Rangetype;
  apert: array of apert_type;
  splotmin, splotmax, splotminmin, splotmaxmax, swidmin, swidmax: real;
  warn_coup_done: boolean; //flag to show zero emit warning only once

// start procedures ---------------------------------------------

procedure Ttrackt.Start;
var
  labin, labot: TLabel;
  edin, edot: TEdit;
  bmax, dmin, dmax, dfac, spos: real;
  str: string;
  i, j: integer;
begin
// restore defaults
  fig.assignScreen;
  flofig.assignScreen;
  flofig.Visible:=status.FloPoly;
  butt_F.enabled:=true; //tmp status.FloPoly;
  edin_val[iiener]:=Glob.Energy;
  edin_val[iicoup]:=FDefGet('trackt/coup');
  edin_val[iiitot]:=FDefGet('trackt/itot');
  edin_val[iinbun]:=FDefGet('trackt/nbun');
  edin_val[iivolt]:=FDefGet('trackt/volt');
  edin_val[iiharm]:=FDefGet('trackt/harm');
  edin_val[iidels]:=FDefGet('trackt/dels');
  edin_val[iidelp]:=FDefGet('trackt/delp');
  edin_val[iintur]:=FDefGet('trackt/ntur');
  edin_val[iigasz]:=IDefGet('trackt/gasz');
  edin_val[iigasn]:=FDefGet('trackt/gasn');
  edin_val[iigasp]:=FDefGet('trackt/gasp');
  my_width:=IDefGet('trackt/wid');

//dynamically create my labels and edit fields
  for i:=1 to nedit do begin
    edin :=TEdit (FindComponent( 'edin_'+IntToStr(i)));
    labin:=TLabel(FindComponent('labin_'+IntToStr(i)));
    if edin = nil then begin
      edin:=TEdit.Create(self);
      edin.name:= 'edin_'+IntToStr(i);
      edin.parent:=panin;
      edin.text:= Ftos(edin_val[i],formin_wid[i],formin_dec[i]);
      edin.Tag:=i;
      edin.OnKeyPress:=edin_KeyPress;
      edin.OnExit    :=edin_Exit;
    end;
    if labin = nil then begin
      labin:=TLabel.Create(self);
      labin.name:= 'labin_'+IntToStr(i);
      labin.parent:=panin;
      labin.caption:= labin_cap[i];
    end;
  end;
  for i:=1 to nout do begin
    edot :=TEdit (FindComponent( 'edot_'+IntToStr(i)));
    labot:=TLabel(FindComponent('labot_'+IntToStr(i)));
    if edot = nil then begin
      edot:=TEdit.Create(self);
      edot.name:= 'edot_'+IntToStr(i);
      edot.parent:=panot;
      edot.text:= Ftos(edot_val[i],formot_wid[i],formot_dec[i]);
      edot.Tag:=i;
      edot.Enabled:=false;
    end;
    if labot = nil then begin
      labot:=TLabel.Create(self);
      labot.name:= 'labot_'+IntToStr(i);
      labot.parent:=panot;
      labot.caption:= labot_cap[i];
    end;
  end;

  edin :=TEdit (FindComponent( 'edin_'+IntToStr(iicoup)));
  edin.enabled:=status.uncoupled;
  edin :=TEdit (FindComponent( 'edin_'+IntToStr(iivolt)));
  edin.enabled:=not status.rfaccept;
  edin :=TEdit (FindComponent( 'edin_'+IntToStr(iiharm)));
  edin.enabled:=not status.rfaccept;


  AllocOpval;
  MomMode:=False;
  ncurves:=0;
// solution has to be periodic otherwise we could not launch trackt at all.
  Permode:=True;
  Linop(0,0,do_twiss+do_chrom+do_radin, 0.0);

// get max betas etc. for plotting (will never change)
  bmax:=-1e10; dmax:=-1e10; dmin:=1e10;
  for i:=0 to Glob.NLatt do with OpVal[0,i] do begin
    if beta > bmax then bmax:=beta;
    if betb > bmax then bmax:=betb;
    if disx > dmax then dmax:=disx;
    if disx < dmin then dmin:=disx;
  end;
  bmax:=1.1*bmax;
  if -dmin > dmax then dmax:=-dmin;
  if dmin>0 then dmin:=0;
  if dmax > 1e-6 then dfac:=Power(10,Trunc(Log10(bmax/dmax))) else dfac:=1.0;
  if dfac > 1 then str:=Inttostr(round(dfac))+'.D'
  else if dfac<1 then str:='D/'+inttostr(round(1/dfac)) else str:='D';
  str:='Beta x/y, '+str+' [m]';
  Range.betamax:=bmax; Range.betamin:=dmin*dfac; Range.dispfac:=dfac; Range.betastr:=str;

// get the aperture data for plotting (never change)
  apert:=nil;
  spos:=0; setlength(apert,Glob.NLatt*2);
  Range.apertmax:=0;
  for i:=0 to nplotmax do Range.zoomfac[i]:=1.0;
  for i:=1 to Glob.NLatt do begin
    j:=FindEl(i);
    with apert[2*i-2] do begin s:=spos; x:=Ella[j].ax; y:=Ella[j].ay; end;
    spos:=spos+Ella[j].l;
    with apert[2*i-1] do begin s:=spos; x:=Ella[j].ax; y:=Ella[j].ay; end;
    if Ella[j].ax > Range.apertmax then Range.apertmax:=Ella[j].ax;
    if Ella[j].ay > Range.apertmax then Range.apertmax:=Ella[j].ay;
  end;
// tell tracklib, to use element apertures for loss check:
  UseElAper:=TRUE;
  edot_val[ionper]:=Glob.NPer; //never changes
  edot_val[iocirc]:=Beam.Circ;
  PlotMode:=ipbet;
  warn_coup_done:= false; //flag to show zero emit warning only once
  OutPut(0);
  chkRFL.checked:=True;
// have to wait with set widht until all components have been created:
  if my_width < min_width then my_width:=min_width;
  if my_width > Screen.Width then my_width:=Screen.Width-10;
  Width:=my_width;
end;

// Exit procedures --------------------------------------------------

procedure TtrackT.SaveDefaults;
// save the default values that may have been changed
begin
  DefSet('trackt/coup', edin_val[iicoup]);
  DefSet('trackt/itot', edin_val[iiitot]);
  DefSet('trackt/nbun', edin_val[iinbun]);
  DefSet('trackt/volt', edin_val[iivolt]);
  DefSet('trackt/harm', edin_val[iiharm]);
  DefSet('trackt/dels', edin_val[iidels]);
  DefSet('trackt/delp', edin_val[iidelp]);
  DefSet('trackt/ntur', edin_val[iintur]);
  DefSet('trackt/gasz', edin_val[iigasz]);
  DefSet('trackt/gasn', edin_val[iigasn]);
  DefSet('trackt/gasp', edin_val[iigasp]);
  DefSet('trackt/wid',  my_width);
end;

procedure Ttrackt.Exit;
begin
  ClearOpval;
  CurvePlot.enable:=False;
  SaveDefaults;
  Close;
  TrackT:=nil;
end;

// calculations ------------------------------------------------------

procedure Ttrackt.CalcBeta (delta_s: real);
{calculate the beta function curve, and also the linear momentum acceptance
for every point of the curve}
begin
  CurvePlot.enable:=true;
  CurvePlot.sini:=0.0;
  CurvePlot.sfin:=Beam.Circ/Glob.NPer;
  CurvePlot.slice:=delta_s;
  splotminmin:=0.0;
  splotmaxmax:=Beam.Circ/Glob.NPer;
  splotmin:=splotminmin;
  splotmax:=splotmaxmax;
  swidmax:=splotmaxmax-splotminmin;
  swidmin:=10*delta_s;
  SliceCalcN(0); // don't call makeplot, this is done by OnPaint event
  InitSigma;
  CalcMalin; // depends ONLY on betas and slice length
  CalcAccEL;
end;


procedure TtrackT.InitSigma;
{creates array tsig, one point for every NONzero length element of Curve,
 writes spos, betas and curly h values}
const
  seps=1e-12;
  heps=1e-3;
var
  c: CurvePt;
  sold, hmax: real;
  i: integer;
begin
  tsig:=nil;
  c:=CurvePlot.ini;
  sold:=-1.0;
  hmax:=0.0;
  while c <> nil do begin
    if (c^.spos -sold) > seps then begin
      setlength(tsig, length(tsig)+1);
      with tsig[High(tsig)] do begin
//! temp use normal mode betas --> change Touschek calc for coupled beam LATER
        bx  :=c^.beta;
        by  :=c^.betb;
        eta :=c^.disx;
        h   :=c^.beta*sqr(c^.disxp)+2*c^.alfa*c^.disx*c^.disxp+(1+sqr(c^.alfa))/c^.beta*sqr(c^.disx);
        if abs(h)>hmax then hmax:=h;
        s   :=c^.spos;
        sold:=s;
      end;
    end;
    c:=c^.nex;
  end;
{ take action later only if H changed significantly:
    same H gives same dp/p-acc even in the nonlinear case.
    to avoid action at every undulator pole, allow some little H-variation. }
  tsig[0].act:=true;
  for i:=1 to High(tsig) do tsig[i].act:= (abs(tsig[i].h-tsig[i-1].h)> heps*hmax);
end;

procedure TtrackT.CalcSigma;
var
  i: integer;
  sigmax, sigmay, hmax, fac: real;
  str: string;
begin
// TO DO get correct sigmas from normal modes, use proc in optic plot
// - or take sigmas in NM system, but then we need normal mode dispersion too (for curly H anyway...)
  sigmax:=0.0; sigmay:=0.0; hmax:=0.0;
  for i:=0 to High(tsig) do with tsig[i] do begin
    x:=sqrt(EmitX_EC*bx +sqr(SigmaE_E*eta));
    y:=sqrt(EmitY_EC*by);
    d:=Sqrt(Sqr(EmitX_EC)+EmitX_EC*h*Sqr(SigmaE_E))/x;
    if x>sigmax then sigmax:=x;
    if y>sigmay then sigmay:=y;
    if h>hmax then hmax:=h;
  end;
  if sigmay > 0 then fac:=Power(10,Trunc(Log10(sigmax/sigmay))) else fac:=1;
  if fac > 1 then str:=Inttostr(round(fac))+'.sigmaY'
  else if fac<1 then str:='sigmaY/'+inttostr(round(1/fac)) else str:='sigmaY';
  str:='SigmaX, '+str+' [micron]';
  Range.sigmamax:=sigmax; Range.sigmayfac:=fac; Range.sigmastr:=str;
  Range.hmax:=hmax;
  CalcVolume;
end;

procedure TtrackT.CalcVolume;
var
  i: integer;
begin
  Range.volmax:=0;
  for i:=0 to High(tsig) do with tsig[i] do begin
    vol:=x*y*SigmaS;
    if vol>Range.volmax then Range.volmax:=vol;
  end;
end;


procedure TtrackT.CalcMAlin;
//const
//  heps=1e-9;
var
  k: integer;

  function GetMAlin(h:real):real;
  var
    ma, tmp: real;
    i,j : integer;
  begin
    ma:=1e6;
    for i:=1 to Glob.NLatt do begin
      j:=findel(i);
      tmp:=Ella[j].ax/(sqrt(h*Opval[0,i].beta)+abs(Opval[0,i].disx)+1e-20);
      // add 1e-20 to avoid div zero if h and disx are 0 (possible)
      if tmp < ma then ma:=tmp;
    end;
    getmalin:=ma/1000.0;
  end;

begin
  tsig[0].malin:=GetMAlin(tsig[0].h);
  for k:=1 to High(tsig) do begin
    if tsig[k].act then  tsig[k].malin:=GetMAlin(tsig[k].h) else  tsig[k].malin:=tsig[k-1].malin;
    tsig[k].maneg:=0.0 ; tsig[k].mapos:=0.0;
  end;
  Range.MAlinmax:=0;
  for k:=0 to High(tsig) do if tsig[k].malin>Range.MAlinmax then Range.MAlinmax:=tsig[k].malin;
  Range.mastr:='Momentum acceptance [%]';
end;


procedure TtrackT.CalcAccEL;
//calculate the term <betay>/acceptY as relevant for eleastic scattering
//used only once at the beginning, since params can't be changed later

var
  sbx, sby, tmp, accx, accy {, rho}: real;
  i,j:integer;
begin
  sbx:=0; sby:=0.0;
  for i:=1 to High(tsig) do begin
    sby:=sby+(tsig[i].by+tsig[i-1].by)/2*(tsig[i].s-tsig[i-1].s);
    sbx:=sbx+(tsig[i].bx+tsig[i-1].bx)/2*(tsig[i].s-tsig[i-1].s);
  end;
  sby:=sby/tsig[high(tsig)].s; // = <beta_y>
  sbx:=sbx/tsig[high(tsig)].s; // = <beta_x>
  // writeln(diagfil, sbx, sby, ' average betas');
  accx:=1e6;     accy:=1e6;
  // how valid is this with coupling?
  for i:=1 to Glob.NLatt do begin
    j:=findel(i);
    tmp:=sqr(Ella[j].ay)/Opval[0,i].betb;
    if tmp < accy then accy:=tmp;
    tmp:=sqr(Ella[j].ax)/Opval[0,i].beta;
    if tmp < accx then accx:=tmp;
  end;
  accy:=accy*1e-6;
  accx:=accx*1e-6;
  if accx*accy>0 then begin
    Tgaselacc:=(sbx/accx+sby/accy)/2;
  { don't use Wiedemann for rectangular aperture, too optimistic and complicated averaging,
    better assume only elliptic apertures. Later: include dynamic limits.
    10.3.2020
        rho:=sqrt(accy*sbx/(accx*sby));
        Tgaselacc:=sby/accy* (pi+(1+sqr(rho))*sin(2*ArcTan(rho))+(2*sqr(rho)-2)*ArcTan(rho))/pi;
  }
  end else Tgaselacc:=1e20; // almost infinity
//  writeln(diagfil,'avg beta x/y and accx/accy rho f =',sbx, sby, accx, accy, rho, f);
//  writeln(diagfil,'tgaselacc, bx/ax, by/ay',tgaselacc, sbx/accx, sby/accy);
end;


procedure TtrackT.CalcLifetime;
const
  maeps=1e-10;
  tkelvin=300.0; // temperature of residual gas
var
  gamma, tconst, maln, malp, man, map, sold, deltas, lrold: real;
  tgaselconst, tgasbsconst, ipTgasBS, ibs: real;
  bslin, bstra: array of real;
  itt: extended;
  i: integer;
  edot: TEdit;
begin
  Screen.Cursor:=crHourGlass;
  gamma:=E_E/electron_mc2;
//simple 1-D model for gas scattering like ZAP, see SLS-TME-TA-2001-0191 p.2
// corrected missing factor 2 in tagselconst 10.3.2020
  tgaselconst:=4*pi*sqr(electron_radius)*speed_of_light*avogadro_number/(gas_constant*sqr(gamma));
  tgasbsconst:=16/3*sqr(electron_radius)*speed_of_light*avogadro_number/(137*gas_constant);
//  ma:=(MA_rfp+abs(MA_rfn))/2.;
//  if (ma > 0)  // take mean loss of pos and neg MA_RF
//    then TgasBS:=2./((LN(1.0/MA_rfp-0.625)+LN(1.0/abs(MA_rfn)-0.625))*Tgasbsconst*4/3*LN(183/Power(gasz,0.3333))*sqr(gasz)*gasn/tkelvin*gasp)
// then TgasBS:=2./((LN(1.0/MA_rfp)+LN(1.0/abs(MA_rfn)))*Tgasbsconst*4/3*(LN(183/Power(gasz,0.3333))+1/18)*sqr(gasz)*gasn/tkelvin*gasp)
  ipTgasBS:=Tgasbsconst*(LN(183/Power(gasz,0.3333))+1/18)*sqr(gasz)*gasn/tkelvin*gasp;
//    else TgasBS:=lozero;
  TgasEL:=1./(Tgaselconst*TgasElacc*sqr(gasz)*gasn/tkelvin*gasp);
//touschek constant
  tconst:=sqr(electron_radius)*speed_of_light*Qbunch/(8*PI*electron_charge*Power(gamma,3));
  Range.zetamax:=0.0; Range.lrmax:=-1e12; Range.lrmin:=1e12;
  setlength(bslin, Length(tsig));
  setlength(bstra, Length(tsig));
  for i:=0 to High(tsig) do with tsig[i] do begin
    if  MA_rfp  < malin then malp:=    MA_rfp else malp:=malin;
    if -MA_rfn  < malin then maln:=   -MA_rfn else maln:=malin;
    zetalinneg:= sqr(maln/(gamma*d));
    zetalinpos:= sqr(malp/(gamma*d));
    if (maln< maeps) or (malp<maeps) then begin
      lrlin:=1000.0;
      bslin[i]:=1000.0;
    end else begin
          // why ma here in denom?!! - was war damit gemeint?
      lrlin:=tconst*(Ctouschek_pol(zetalinneg)/sqr(maln) + Ctouschek_pol(zetalinpos)/sqr(malp))/(2*vol*d)+1e-20;
      bslin[i]:=ipTgasBS*Ln(1/maln);
    end;
    if TrackDone then begin
      if -MA_rfn < -maneg then man:=-MA_rfn else man:=-maneg;
      zetaneg:= sqr(man/(gamma*d));
      if  MA_rfp < mapos then map:= MA_rfp else map:= mapos;
      zetapos:= sqr(map/(gamma*d));
      if (man < maeps) or (map < maeps) then begin
        lrdyn:=1000.0;
        bstra[i]:=1000.0;
      end else begin
        lrdyn:=tconst*(Ctouschek_pol(zetaneg)/sqr(man)+Ctouschek_pol(zetapos)/sqr(map))/(2*vol*d)+1e-20;
        bstra[i]:= ipTgasBS*Ln(1/man);
      end;
    end;
    with Range do begin
      if zetamax < zetalinpos then zetamax:=zetalinpos;
      if zetamax < zetalinneg then zetamax:=zetalinneg;
      if lrmax < lrlin then lrmax:=lrlin;
      if lrmin > lrlin then lrmin:=lrlin;
    end;
    if TrackDone then with Range do begin
      if zetamax < zetaneg then zetamax:=zetaneg;
      if zetamax < zetapos then zetamax:=zetapos;
      if lrmax < lrdyn then lrmax:=lrdyn;
      if lrmin > lrdyn then lrmin:=lrdyn;
    end;
  end;
  if Range.zetamax=0 then Range.zetamax:=1.0;
  sold:=0.0; lrold:=tsig[0].lrlin; itt:=0.0; ibs:=0.0;
  for i:=1 to High(tsig) do with tsig[i] do begin
    deltas:=s-sold;
    ibs:=ibs+deltas*(bslin[i]+bslin[i-1])/2;
    itt:=itt+deltas*(lrlin+lrold)/2;
    lrold:=lrlin; sold:=s;
  end;
  TT_lin:= 1.0/(itt/(Beam.Circ/Glob.NPer));
  TgasBSlin:=1.0/(ibs/(Beam.Circ/Glob.NPer));
  edot :=TEdit (FindComponent( 'edot_'+IntToStr(iotgel)));
  edot.text:=Ftos(TgasEL/3600,formot_wid[iotgel],formot_dec[iotgel]);
  labtlin.caption:=FtoS(1/(1/TgasEL+1/TgasBSlin+1/TT_lin)/3600,8,3); //hrs
  if TrackDone then begin
    sold:=0.0; lrold:=tsig[0].lrdyn; itt:=0.0; ibs:=0.0;
    for i:=1 to High(tsig) do with tsig[i] do begin
      deltas:=s-sold;
      ibs:=ibs+deltas*(bstra[i]+bstra[i-1])/2;
      itt:=itt+deltas*(lrdyn + lrold)/2;
      lrold:=lrdyn; sold:=s;
    end;
    TT_dyn:= 1.0/(itt/(Beam.Circ/Glob.NPer));
    TgasBSdyn:=1.0/(ibs/(Beam.Circ/Glob.NPer));
    labdyn.caption:=FtoS(1/(1/TgasEL+1/TgasBSdyn+1/TT_dyn)/3600,8,3); //hrs
    edot :=TEdit (FindComponent( 'edot_'+IntToStr(iotgbs)));
    edot.text:=Ftos(TgasBSlin/3600,formot_wid[iotgbs],formot_dec[iotgbs])+' / '+Ftos(TgasBSdyn/3600,formot_wid[iotgbs],formot_dec[iotgbs]);
    edot :=TEdit (FindComponent( 'edot_'+IntToStr(iottou)));
    edot.text:=Ftos(TT_lin/3600,formot_wid[iottou],formot_dec[iottou])+' / '+Ftos(TT_dyn/3600,formot_wid[iottou],formot_dec[iottou]);
  end else begin
    edot :=TEdit (FindComponent( 'edot_'+IntToStr(iotgbs)));
    edot.text:=Ftos(TgasBSlin/3600,formot_wid[iotgbs],formot_dec[iotgbs]);
    edot :=TEdit (FindComponent( 'edot_'+IntToStr(iottou)));
    edot.text:=Ftos(TT_lin/3600,formot_wid[iottou],formot_dec[iottou]);
  end;
  bslin:=nil; bstra:=nil;
  Screen.Cursor:=crDefault;
end;

procedure TtrackT.Output(inp:integer);
var
  escal, phase, volt, harm, arg, coup: real;
  i: integer;
  edin, edot: TEdit; labin: TLabel;
begin
// select actions depending on which inp was done
  if inp in [iiall, iidels] then CalcBeta (edin_val[iidels]);
// CalcBeta also inits tsig arrays and recalcs malin
  E_E  :=edin_val[iiener]*1E9;
  escal:=edin_val[iiener]/Glob.Energy;
  coup :=edin_val[iicoup]*0.01;
  volt :=edin_val[iivolt]*1e6;
  harm :=edin_val[iiharm];
  Nturns:=round(edin_val[iintur]);
  dppRes:=edin_val[iidelp];
  gasz:=round(edin_val[iigasz]);
  gasn:=round(edin_val[iigasn]);
  gasp:=edin_val[iigasp]*1E-7; //convert picobar to Pascal
  with Beam do begin
  //calc quantities in SI units, convert to practical in edot only
    U0_E:=U0*Power(escal,4)*1e3;
    sigmaE_E:=sigmaE*escal;

{careful: implies that coupling contrib to Emity = zero;
 direct divergence contribution does not scale with energy!
 also see linoplib
xxx forget that, Q-emitt irrelevant, use coupled emittances as-3.5.2018
    EmitX_EC:=(     sqr(escal)*Emita+ coup*Emitb)/(1+coup);
    EmitY_EC:=(coup*sqr(escal)*Emita+      Emitb)/(1+coup);
}
    if status.uncoupled or warn_coup_done then begin //emitb=0, Jb=1
      EmitX_EC:=sqr(escal)*Emita/(1+coup*Jb/Ja);
      EmitY_EC:=coup*EmitX_EC;
    end else begin
      EmitX_EC:=sqr(escal)*Emita;
      EmitY_EC:=sqr(escal)*Emitb;
    end;
{if lattice contains coupling but inactive elements, or if coupling itself was set to zero,
 vertical is zero and will lead to div/0 error, check and warn and switch to uncoupled emit input}
    if EmitY_EC<1e-20 then begin
      //message
      coup:=1e-3;
      edin_val[iicoup]:=coup*100;
      edin:=TEdit (FindComponent( 'edin_'+IntToStr(iicoup)));
      edin.Text:=FtoS(edin_val[iicoup],formin_wid[iicoup], formin_dec[iicoup]);
      edin.Enabled:=True;
      labin:=TLabel(FindComponent('labin_'+IntToStr(iicoup)));
      labin.Color:=clBtnFace;     labin.paint;
      EmitY_EC:=coup*Emita;
      if not warn_coup_done then MessageDlg('Zero vertical emittance set to 0.1% of horizontal',mtWarning, [mbOK],0);
      warn_coup_done:=true;
    end;


// it is correct to use normal mode emitt for Touschek, but careful: need curly H in normal form! TO DO

    Qbunch  :=(1e-3*edin_val[3])/edin_val[4]*Circ/speed_of_light;

//use asymmetric MA_RF calculated in bucket; if this was successful, it is |sin(phase)|<1
    if status.RFaccept then begin
      MA_rfp:=snapsave.rfaccp;
      MA_rfn:=snapsave.rfaccm;
      volt:=snapsave.voltRF[0];
      sigmaS:=snapsave.sigmas;
    end;
    arg   := U0_E/volt;
    if arg < 1 then begin
      phase:=ArcSin(arg);
      if alfa < 0 then phase:=Pi-phase; {should  take care of neg alfa, anyway use ABS for safety...}
      Stune :=Sqrt( ABS( Alfa*harm*Volt*Cos(phase)/(2*Pi*E_E))); // get from MA_rflin !!!
      if not status.RFaccept then begin
        MA_rfp :=Sqrt( ABS (2*U0_E/(Pi*E_E*Alfa*harm)*(1/Tan(phase)+phase-Pi/2)));
        MA_rfn:=-MA_rfp;
        sigmaS:=sigmaE_E*Sqrt( ABS (alfa*Sqr(Circ)/(2*Pi)*E_E/harm/U0_E*Tan(phase)));
      end;
    end else begin
      sigmaS:=Circ;
      MA_rfp:=0.0; MA_rfn:=0.0;
      Stune:=0.0;
    end;
  end;

  if  MA_rfp > Range.MAlinmax then Range.MAmax := MA_rfp else Range.MAmax:=Range.MAlinmax;
  if -MA_rfn > Range.MAlinmax then Range.MAmax :=-MA_rfn else Range.MAmax:=Range.MAlinmax;

  if inp in [iiall, iiener, iicoup, iidels] then CalcSigma;//implies calcvolume
  if inp in [iivolt, iiharm] then CalcVolume;

  if inp in [iiall, iiener, iicoup, iidels, iidelp, iintur] then TrackDone:=false;

  if inp in [iiall, iiener, iicoup, iiitot, iinbun, iivolt, iiharm, iidels, iigasz, iigasn, iigasp] then CalcLifetime;

// update edot fields
  edot_val[ioloss]:=U0_E     /1E6; //MeV
  edot_val[iosige]:=sigmaE_E *100; //%
  edot_val[ioemix]:=EmitX_EC* 1E9; //nm
  edot_val[ioemiy]:=EmitY_EC* 1E9;
  edot_val[ioqbun]:=Qbunch   *1E9; //nC
  edot_val[iosigs]:=sigmaS   *1E3; // mm
  edot_val[iomarf]:=MA_rfp    *100; //% //change here for neg marf
  edot_val[iostun]:=Stune; //%

  // leave lifetime results to calclifetime
  for i:=1 to nout-3 do begin
    edot :=TEdit (FindComponent( 'edot_'+IntToStr(i)));
    edot.text:= Ftos(edot_val[i],formot_wid[i],formot_dec[i]);
  end;
  if status.rfaccept then begin
    edot :=TEdit (FindComponent( 'edot_'+IntToStr(iomarf)));
    edot.text:=Ftos(MA_rfn,formot_wid[iomarf],formot_dec[iomarf])+'/+'+Ftos(MA_rfp,formot_wid[iomarf],formot_dec[iomarf]);
  end;
  MakePlot;
end;

{------------------------------------------------------------------------}


function TtrackT.TrackLat_0 (dpp, startPos: real): boolean;

//  tracks a particle starting at spos, with momentum dpp and
// x,x',y,y'=0. returns false if lost, true if survived ntu turns

var
  Lost: boolean;
  kturns: integer;
  x: Vektor_5;
begin
  TrackingMatrix(dpp, startPos);
  kturns:=0;
  x   :=VecNul5;
  x[5]:=dpp;
  repeat
    inc(kturns);
    Lost:=Oneturn(x);
    Application.ProcessMessages;
  until (kturns = Nturns) or Lost or TrackBreak;
  TrackLat_0:=Lost;
  if Lost then fig.plot.SetSymbol( 1, 1, clRed) else fig.plot.SetSymbol(1,1,clGreen);
  fig.plot.Symbol( startPos, dpp*100);
end;


function TtrackT.TrackLat_S (dpp, startPos: real): boolean;

// same, but with sync tune: change of dpp every turn
// quick & dirty: very inefficient to recalc trackingMatrix for every turn!

var
  Lost: boolean;
  kturns: integer;
  x: Vektor_5;
  dppturn: real;
begin
  kturns:=0;
  x   :=VecNul5;
  repeat
    dppturn:=dpp*Cos(2*Pi*kturns*STune);
    x[5]:=dppturn;
    TrackingMatrix(dppturn, startPos {+1.234e-5});
    inc(kturns);
    Lost:=Oneturn(x);
    Application.ProcessMessages;
  until (kturns = Nturns) or Lost or TrackBreak;
  TrackLat_S:=Lost;
  if Lost then fig.plot.SetSymbol( 1, 1, clRed) else fig.plot.SetSymbol(1,1,clGreen);
  fig.plot.Symbol( startPos, dpp*100);
end;

function TtrackT.TrackLat (dpp, startPos: real): boolean;
begin
  if SyncMode then TrackLat:=TrackLat_S (dpp, startpos)
              else TrackLat:=TrackLat_0 (dpp, startpos);
end;

function TtrackT.Trackdbins (startPos, dini: real): real;
// binary search for max stable momentum
//????? 2do: asymmetric to speed up
var
  dd, d: real;
begin
  dd:=dini;
//dd:=dmax;
  d :=0;
  repeat
    d:=d+dd;
    if TrackLat(d, startPos) then begin
      d:=d-dd;
      dd:=dd/2;
    end;
  until abs(dd)<dppRes;
//  until (abs(dd)<dppRes) or (abs(d)>dmax);
  Trackdbins:=d;
end;

procedure TtrackT.TrackMAdyn;
var
  k: integer;

  procedure checkma (ip: integer; sp: real);
  begin
    if chkRFL.checked then begin
      if TrackLat( ma_rfp, sp) then tsig[ip].mapos:=Trackdbins(sp, 0.5*ma_rfp) else tsig[ip].mapos:= ma_rfp;
      if TrackLat( ma_rfn, sp) then tsig[ip].maneg:=Trackdbins(sp, 0.5*ma_rfn) else tsig[ip].maneg:= ma_rfn;
    end else begin
      tsig[ip].maneg:=Trackdbins(sp, -tsig[ip].malin);
      tsig[ip].mapos:=Trackdbins(sp,  tsig[ip].malin);
    end;
  end;

begin
  Screen.Cursor:=crHourGlass;
  PlotMode:=ipmac;
  MakePlot;
// if we use the RF limit, then first check at ma_rf. If ok --> done, else start binary search starting at ma_rfp/2
// ma_rfn is a negative number!
  CheckMA(0,0.0);
  for k:=1 to High(tsig) do if not TrackBreak then begin
    if tsig[k].act then begin
      CheckMA(k,tsig[k].s);
    end else begin
      tsig[k].maneg:=tsig[k-1].maneg;
      tsig[k].mapos:=tsig[k-1].mapos;
    end;
  end;

  TrackDone:=not TrackBreak;
  CalcLifetime;
  MakePlot;
  Screen.Cursor:=crDefault;
end;

procedure TtrackT.TrackMA_FTT;
//Fast Touschek Tracking, Feb.2023
var
  ip, nfp, nfa, i, j, idpp, ndpp, nact, nacc0, nacc1, nlos0, nlos1, nacc2, nlos2, its: integer;
  dpp, dpp100, dppmin, dppmax, asprat, dppfull: real;
  fpxo, fpwo: real;
  fpx, fpw: array of real;
  iacc0, ilos0, iacc1, ilos1, iacc2, ilos2: array of integer;

  function getFloPdpp: boolean;
  {interpolation of polygons for dpp: this way makes sure,that the interpolated
   points x,w are under same angles like in the tabulated FloP data}
  var
      i, j1, j2, ia, ip: integer;
      lam: real;
  begin
    if (dpp<dppmin) or (dpp>dppmax) then getFloPdpp:=false else begin
      for i:=0 to High(FloPdpp)-1 do if (dpp-FloPdpp[i])*(dpp-FloPdpp[i+1])<=0 then ip:=i;
      lam:=(dpp-FloPdpp[ip])/(FloPdpp[ip+1]-FloPdpp[ip]);
      fpxo:=(1-lam)*FloPxo[ip]+lam*FloPxo[ip+1];
      fpwo:=(1-lam)*FloPwo[ip]+lam*FloPwo[ip+1];
      for ia:=0 to nfa-1 do begin
        j1:=ip*nfa+ia; j2:=(ip+1)*nfa+ia;
        fpx[ia]:=(1-lam)*FloPx[j1]+lam*FloPx[j2];
        fpw[ia]:=(1-lam)*FloPw[j1]+lam*FloPw[j2];
//        writeln('angle test ', degrad*MyArcTan2(fpx[ia], fpw[ia]):12:6,' ',degrad*MyArcTan2(fpx[ia], fpw[ia]/asprat):12:6);
      end;
      fpx[nfa]:=fpx[0];  fpw[nfa]:=fpw[0];
      getFloPdpp:=true;
    end;
  end;

  //discriminate points
  function CheckFlop(x, w: real): boolean;
  var
    ang, dx, dw, dfx, dfw: real; ia: integer;
  begin
    // find the edge of polygon (two points) which is intersected by prolongation of dx,dw
    dx:=x-fpxo; dw:=w-fpwo; // relative to orbit (fpx,w are offsets to orbit too)
    ang:=MyArcTan2(dx, dw/asprat);
    ia:=Trunc(ang/(2*Pi)*nfa);
    dfx:=fpx[ia+1]-fpx[ia]; dfw:=fpw[ia+1]-fpw[ia];
    //(dx,dw)*n > (fpx,fpw)*n with normal n =(-dfw,dfx) -> inside polygon, i.e has to be stretched to reach edge
    CheckFlop:= (dw*dfx-dx*dfw) > (fpw[ia]*dfx-fpx[ia]*dfw);
  end;

  function getdpp: real;
  begin
    getdpp:=dppmin+dppfull*idpp/4/ndpp;
  end;

  function setupdpp: boolean;
  begin
    Application.ProcessMessages;
    dpp100:=100*dpp;
    Trackingmatrix(dpp,0);
    setupdpp:=GetFloPdpp;
  end;

  procedure plotacclos (isho: integer);
  //shwo results in both plot windows
  var
     sizac,sizlo, thkac, thklo, i,j: integer;
  begin
    if nacc1+nlos1>0 then begin
      sizlo:=2; sizac:=2; thklo:=1; thkac:=1;
      if isho=1 then begin
        sizlo:=5; thklo:=2;
      end;
      if isho=-1 then begin
        sizac:=5; thkac:=2;
      end;

      FloFigPlot(true);
      with flofig.Plot do begin
        setColor(clFuchsia);
        moveto(fpx[0]+fpxo, fpw[0]+fpwo);
        for j:=0 to nfa do lineto(fpx[j]+fpxo, fpw[j]+fpwo);
        SetSymbol( 2, 1, clFuchsia); Symbol(fpxo, fpwo);
      end;

      with flofig.plot do begin
        SetSymbol( sizac, 1, clGReen); setThick(thkac);
        for i:=0 to nacc1-1 do with tsig[iacc1[i]] do Symbol(fx, fw);
        SetSymbol( sizlo, 1, clRed); setThick(thklo);
        for i:=0 to nlos1-1 do with tsig[ilos1[i]] do Symbol(fx, fw);
        setThick(1);
      end;

      with fig.plot do begin
        SetSymbol( 2, 1, clGReen);
        for i:=0 to nacc1-1 do Symbol(tsig[iacc1[i]].s, dpp100);
        SetSymbol( 2, 1, clRed);
        for i:=0 to nlos1-1 do Symbol(tsig[ilos1[i]].s, dpp100);
      end;

    end;
  end;

begin
  Screen.Cursor:=crHourGlass;
  nfp:=length(FloPdpp);
  nfa:=length(Flops);
  setlength(fpx, nfa+1); setlength(fpw, nfa+1);
  asprat:=(FloPwmax-FloPwmin)/(FloPxmax-FloPxmin);
  //aspect ratio of w,x plot --> figure is square, so bring coordinate to same size w -> w/asprat,
  //otherwise interpolation by equidistant azimuth angle will be wrong

  setlength(slatt, Glob.NLatt+1);
  slatt[0]:=0;
  for i:=1 to Glob.NLatt do begin
    slatt[i]:=slatt[i-1]+Ella[Lattice[i].jel].l;
  end;

  nact:=0;
  for i:=0 to High(tsig) do if tsig[i].act then Inc(nact);
  setlength(iacc0,nact); setlength(ilos0,nact);
  setlength(iacc1,nact); setlength(ilos1,nact);
  setlength(iacc2,nact); setlength(ilos2,nact);

  dppmin:=FloPdpp[0]; dppmax:=FloPdpp[nfp-1]; dppfull:=dppmax-dppmin;
  ndpp:=Round(dppfull/dppRes/4);

  //start at +p/2, get index arrays i***0 where particles are accepted or lost
  idpp:=3*ndpp; dpp:=getdpp;
  nacc0:=0; nlos0:=0;
  setupdpp; // no test here, if no data available, something is wrong --> to be caught
  for i:=0 to High(tsig) do with tsig[i] do if act then begin
    TrackToEnd (s, dpp, fx, fw);
    if checkFloP(fx, fw) then begin iacc0[nacc0]:=i; inc(nacc0); mapos:=dpp+dppres/2; end
                         else begin ilos0[nlos0]:=i; inc(nlos0); mapos:=dpp-dppres/2; end;
  end;
  //for plotting (i***1)
  nacc1:=nacc0; nlos1:=nlos0;
//writeln(nact,' ', nacc0,' ', nlos0,' ', nacc1,' ', nlos1);
  for i:=0 to nacc1-1 do iacc1[i]:=iacc0[i];  for i:=0 to nlos1-1 do ilos1[i]:=ilos0[i];
  plotacclos(0);

  //start from +p/2 upwards with only particles accepted at +p/2 (iacc0)
  idpp:=3*ndpp;
  nacc1:=nacc0;
  for i:=0 to nacc1-1 do iacc1[i]:=iacc0[i];
  repeat
    Inc(idpp); dpp:=getdpp;
    if nacc1>0 then if setupdpp then begin //avoid matrix recalc if no particles are left over
      nacc2:=0; nlos2:=0;
      if chkRFL.Checked and (dpp>ma_rfp) then begin
        for i:=0 to nacc1-1 do begin
          its:=iacc1[i];
          ilos2[nlos2]:=its; inc(nlos2); tsig[its].mapos:=ma_rfp; // all lost at RF MA
        end;
      end else begin
        for i:=0 to nacc1-1 do begin
          its:=iacc1[i];
          with tsig[its] do begin
            TrackToEnd (s, dpp, fx, fw);
            if checkFloP(fx, fw) then begin iacc2[nacc2]:=its; inc(nacc2); mapos:=dpp+dppres/2; end
                                 else begin ilos2[nlos2]:=its; inc(nlos2); mapos:=dpp-dppres/2; end;
          end;
        end;
      end;
      nacc1:=nacc2; nlos1:=nlos2;
      for i:=0 to nacc1-1 do iacc1[i]:=iacc2[i];   for i:=0 to nlos1-1 do ilos1[i]:=ilos2[i];
      plotacclos(1);
    end;  //else do nothing, if no Polygon available, then tsig freezes at last used dpp, nothing to plot.
  until TrackBreak or (idpp=4*ndpp);


  //start from +p/2 downwards with particles lost at +p/2
  nlos1:=nlos0;
  for i:=0 to nlos1-1 do ilos1[i]:=ilos0[i];
  idpp:=3*ndpp;
  repeat
    Dec(idpp); dpp:=getdpp;
    if nlos1>0 then if setupdpp then begin
      nacc2:=0; nlos2:=0;
      for i:=0 to nlos1-1 do begin
        its:=ilos1[i];
        with tsig[its] do begin
          TrackToEnd (s, dpp, fx, fw);
          if checkFloP(fx, fw) then begin iacc2[nacc2]:=its; inc(nacc2); mapos:=dpp+dppres/2; end
                               else begin ilos2[nlos2]:=its; inc(nlos2); mapos:=dpp-dppres/2; end;
        end;
      end;
      nacc1:=nacc2; nlos1:=nlos2;
      for i:=0 to nacc1-1 do iacc1[i]:=iacc2[i];   for i:=0 to nlos1-1 do ilos1[i]:=ilos2[i];
      plotacclos(-1);
    end;
  until TrackBreak or (idpp=2*ndpp);

// get acc/los at -p/2
  idpp:=ndpp; dpp:=getdpp;
  nacc0:=0; nlos0:=0;
  setupdpp;
  for i:=0 to High(tsig) do with tsig[i] do if act then begin
    TrackToEnd (s, dpp, fx, fw);
    if checkFloP(fx, fw) then begin iacc0[nacc0]:=i; inc(nacc0); maneg:=dpp-dppres/2; end
                         else begin ilos0[nlos0]:=i; inc(nlos0); maneg:=dpp+dppres/2; end;
  end;
  for i:=0 to nacc0-1 do iacc1[i]:=iacc0[i];     for i:=0 to nlos0-1 do ilos1[i]:=ilos0[i];
  plotacclos(0);

  //start from -p/2 downwards with particles accepted at -p/2
  nacc1:=nacc0;
  for i:=0 to nacc1-1 do iacc1[i]:=iacc0[i];
  idpp:=ndpp;
  repeat
    Dec(idpp); dpp:=getdpp;
    if nacc1>0 then if setupdpp then begin;
      nacc2:=0; nlos2:=0;
      if chkRFL.Checked and (dpp<ma_rfn) then begin
        for i:=0 to nacc1-1 do begin
          its:=iacc1[i];
          ilos2[nlos2]:=its; inc(nlos2); tsig[its].maneg:=ma_rfn; // all lost at RF MA
        end;
      end else begin
        for i:=0 to nacc1-1 do begin
          its:=iacc1[i];
          with tsig[its] do begin
            TrackToEnd (s, dpp, fx, fw);
            if checkFloP(fx, fw) then begin iacc2[nacc2]:=its; inc(nacc2); maneg:=dpp-dppres/2; end
                                 else begin ilos2[nlos2]:=its; inc(nlos2); maneg:=dpp+dppres/2; end;
          end;
        end;
      end;
      nacc1:=nacc2; nlos1:=nlos2;
      for i:=0 to nacc1-1 do iacc1[i]:=iacc2[i];  for i:=0 to nlos1-1 do ilos1[i]:=ilos2[i];
      plotacclos(1);
    end;
  until TrackBreak or (idpp=0);

    //start from -p/2 upwards with particles lost at -p/2
  nlos1:=nlos0;
  for i:=0 to nlos1-1 do ilos1[i]:=ilos0[i];
  idpp:=ndpp;
  repeat
    Inc(idpp); dpp:=getdpp;
    if nlos1>0 then if setupdpp then begin
      nacc2:=0; nlos2:=0;
      for i:=0 to nlos1-1 do begin
        its:=ilos1[i];
        with tsig[its] do begin
          TrackToEnd (s, dpp, fx, fw);
          if checkFloP(fx, fw) then begin iacc2[nacc2]:=its; inc(nacc2); maneg:=dpp-dppres/2; end
                             else begin ilos2[nlos2]:=its; inc(nlos2); maneg:=dpp+dppres/2; end;
        end;
      end;
      nacc1:=nacc2; nlos1:=nlos2;
      for i:=0 to nacc1-1 do iacc1[i]:=iacc2[i];  for i:=0 to nlos1-1 do ilos1[i]:=ilos2[i];
      plotacclos(-1);
    end;
  until TrackBreak or (idpp=2*ndpp);

  for i:=1 to High(tsig) do with tsig[i] do begin
    if not act then begin
      maneg:=tsig[i-1].maneg; mapos:=tsig[i-1].mapos;
    end;
  end;

  for i:=0 to High(tsig) do with tsig[i] do begin
    maneg_f:=maneg; mapos_f:=mapos; //tmp for comparison only
  end;

  TrackDone:=not TrackBreak;
  CalcLifetime;
  MakePlot;
  Screen.Cursor:=crDefault;
end;



// Graphics -----------------------------------------


procedure Ttrackt.FloFigPlot (gray: boolean);
var
  i, j, np, na: integer;
  elcol: TColor;
begin
  flofig.plot.setcolor(clBlack);
  flofig.plot.clear(clWhite);
  flofig.Init(FloPxmin,FloPwmin,FloPxmax,FloPwmax,1,1,'x [mm]','x'' [mrad]',3,false);
  with flofig.plot do begin
    MarkOriginX; MarkOriginY;
    np:=Length(FloPxo); na:=Length(FloPc);
    for i:=0 to np-1 do begin
      if gray then elcol:=clSilver else begin
        if i < np div 2 then elcol:=dimcol(clGray,clRed, i/(np div 2)) else elcol:=dimcol(clGray,clBlue, (np-i-1)/(np div 2));
      end;
      setColor(elcol);
      moveto(Flopx[i*na+na-1]+FloPxo[i], FloPw[i*na+na-1]+FloPwo[i]);
      for j:=0 to na-1 do lineto(FloPx[i*na+j]+FloPxo[i], FloPw[i*na+j]+FloPwo[i]);
      SetSymbol( 2, 1, elcol); Symbol(FloPxo[i], FloPwo[i]);
    end;
  end;
end;

procedure Ttrackt.MakePlot;
var
  i, its1, its2:integer;
  c: CurvePt;
  zoom:real;

begin

  if flofig.Visible then FloFigPlot(false);

  fig.plot.setcolor(clBlack);
  fig.plot.clear(clWhite);

  i:=-1;
  repeat
    Inc(i);
    if tsig[i].s <= splotmin then its1:=i;
  until (i=high(tsig)) or (tsig[i].s >= splotmax);
  its2:=i;

  zoom:=Range.zoomfac[plotmode];
  case plotmode of

    iphcy: begin // Lattice invariant curly-H
      fig.Init(splotmin,0,splotmax, 1.1*zoom*Range.hmax*1e3, 1, 1, 's [m]','H-invariant [mm.rad]', 3,false);
      with fig.plot do begin
        setColor(dispx_col); moveto(tsig[its1].s, tsig[its1].h*1e3);
        for i:=its1+1 to its2 do lineto(tsig[i].s, tsig[i].h*1e3); stroke;
      end;
    end;

    ipenv: begin // envelopes
      fig.Init(splotmin,0,splotmax, zoom*Range.sigmamax*1e6, 1, 1, 's [m]',Range.sigmastr, 3,false);
      with fig.plot do begin
        setColor(betax_col); moveto(tsig[its1].s, tsig[its1].x*1e6);
        for i:=its1+1 to its2 do lineto(tsig[i].s, tsig[i].x*1e6); stroke;
        setColor(betay_col); moveto(tsig[its1].s, Range.sigmayfac*tsig[0].y*1e6);
        for i:=its1+1 to its2 do lineto(tsig[i].s, Range.sigmayfac*tsig[i].y*1e6);stroke;
      end;
    end;

    ipapr: begin // apertures (step plot)
      fig.Init(splotmin,0,splotmax, 1.1*zoom*Range.apertmax, 1, 1, 's [m]','Apertures [mm]', 3,false);
      with fig.plot do begin
        setColor(betax_col); moveto(apert[0].s, apert[0].x);
        for i:=1 to High(apert) do lineto(apert[i].s, apert[i].x);    stroke;
        setColor(betay_col); moveto(apert[0].s, apert[0].y);
        for i:=1 to High(apert) do lineto(apert[i].s, apert[i].y);   stroke;
      end;

    end;

    ipvol: begin // volume
      fig.Init(splotmin,0, splotmax, zoom*Range.volmax*1e9, 1, 1, 's [m]','rms bunch volume [mm^3]', 3,false);
      with fig.plot do begin
        setColor(clTeal);
        moveto(tsig[its1].s, tsig[its1].vol*1e9);
        for i:=its1+1 to its2 do lineto(tsig[i].s, tsig[i].vol*1e9);stroke;
      end;
    end;

    ipmac: begin // momentum acceptances
      fig.Init(splotmin,-110*zoom*Range.Mamax, splotmax, 110*zoom*Range.Mamax, 1, 1, 's [m]',Range.mastr, 3,false);
      with fig.plot do begin
        setColor(clBlack);  moveto(tsig[its1].s, 0); lineto(tsig[its2].s, 0);
        setColor(clBlue); moveto(tsig[its1].s, tsig[its1].malin*100);
        for i:=its1+1 to its2 do lineto(tsig[i].s, tsig[i].malin*100); stroke;
        moveto(tsig[its1].s, -tsig[its1].malin*100);
        for i:=its1+1 to its2 do lineto(tsig[i].s, -tsig[i].malin*100); stroke;
        setColor(clBlue); setStyle(psDash);
        moveto(tsig[its1].s, MA_rfp*100); lineto(tsig[its2].s, MA_rfp*100); stroke;
        moveto(tsig[its1].s, MA_rfn*100); lineto(tsig[its2].s, MA_rfn*100); stroke;
        setStyle(psSolid);
        if TrackDone then begin
//tmp for comparison
          setColor(clGreen); moveto(tsig[its1].s, tsig[its1].maneg_f*100);
          for i:=its1+1 to its2 do lineto(tsig[i].s, tsig[i].maneg_f*100); stroke;
          moveto(tsig[its1].s, tsig[its1].mapos_f*100);
          for i:=its1+1 to its2 do lineto(tsig[i].s, tsig[i].mapos_f*100); stroke;

          setColor(clRed); moveto(tsig[its1].s, tsig[its1].maneg*100);
          for i:=its1+1 to its2 do lineto(tsig[i].s, tsig[i].maneg*100); stroke;
          moveto(tsig[its1].s, tsig[its1].mapos*100);
          for i:=its1+1 to its2 do lineto(tsig[i].s, tsig[i].mapos*100); stroke;
        end;
      end;
    end;

    ipzet: begin // zeta
      fig.Init(splotmin,0, splotmax, zoom*Range.zetamax, 1, 1, 's [m]','zeta = ( dpp_acc/px(x=o) )^2', 3,false);
      with fig.plot do begin
        setColor(dimcol(clAqua, clBlack,0.5));
        moveto(tsig[its1].s, tsig[its1].zetalinneg);
        for i:=its1+1 to its2 do lineto(tsig[i].s, tsig[i].zetalinneg); stroke;
        setColor(dimcol(clFuchsia, clBlack,0.5));
        moveto(tsig[its1].s, tsig[its1].zetalinpos);
        for i:=its1+1 to its2 do lineto(tsig[i].s, tsig[i].zetalinpos); stroke;
        if TrackDone then begin
          setColor(clAqua);
          moveto(tsig[its1].s, tsig[its1].zetaneg);
          for i:=its1+1 to its2 do lineto(tsig[i].s, tsig[i].zetaneg); stroke;
          setColor(clFuchsia);
          moveto(tsig[its1].s, tsig[its1].zetapos);
          for i:=its1+1 to its2 do lineto(tsig[i].s, tsig[i].zetapos); stroke;
        end;
      end;
    end;

    iptou: begin // 1/T
      fig.Init(splotmin,0, splotmax, zoom*Range.lrmax, 1, 1, 's [m]','Loss rate [1/(s m)]', 3,false);
      with fig.plot do begin
        setColor(dimcol(clRed, clBlack,0.5));
        moveto(tsig[its1].s, tsig[its1].lrlin);
        for i:=its1+1 to its2 do lineto(tsig[i].s, tsig[i].lrlin);  stroke;
        if TrackDone then begin
          setColor(clRed);
          moveto(tsig[its1].s, tsig[its1].lrdyn);
          for i:=its1+1 to its2 do lineto(tsig[i].s, tsig[i].lrdyn); stroke;
        end;
      end;
    end;

    iplog: begin // 1/T log
      fig.Init(splotmin, Log10(Range.lrmin), splotmax, Log10(zoom*Range.lrmax), 1, 1, 's [m]','Log (loss rate)', 3,false);
      with fig.plot do begin
        setColor(dimcol(clRed, clBlack,0.5));
        moveto(tsig[its1].s, Log10(tsig[its1].lrlin));
        for i:=its1+1 to its2 do lineto(tsig[i].s, Log10(tsig[i].lrlin)); stroke;
        if TrackDone then begin
          setColor(clRed);
          moveto(tsig[its1].s, Log10(tsig[its1].lrdyn));
          for i:=its1+1 to its2 do lineto(tsig[i].s, Log10(tsig[i].lrdyn));  stroke;
        end;
      end;
    end;

    else begin //=0, default beta plot
      fig.Init(splotmin,zoom*Range.Betamin,splotmax, zoom*Range.Betamax, 1, 1, 's [m]',Range.betastr, 3,false);
      with fig.plot do begin
        setColor(betax_col); c:=CurvePlot.ini; moveto(c^.spos, c^.beta);
        while c^.nex <> nil do begin c:=c^.nex; lineto(c^.spos, c^.beta); end; stroke;
        setColor(betay_col); c:=CurvePlot.ini; moveto(c^.spos, c^.betb);
        while c^.nex <> nil do begin c:=c^.nex; lineto(c^.spos, c^.betb); end; stroke;
        setColor(dispx_col); c:=CurvePlot.ini; moveto(c^.spos, Range.dispfac*c^.disx);
        while c^.nex <> nil do begin c:=c^.nex; lineto(c^.spos, Range.dispfac*c^.disx); end; stroke;
      end;
    end; // else

  end; //case
end;

procedure TtrackT.ResizeAll;
const
  dsr  =10; //dist to outside
  ds   =6; // space
  dyb  =30; //but height
var
  i, x, y, wid, hgt, drby, dx, dy, yed, ylb, ytab, xlb, xed, xtab, nrows, colwid, drbx, colwh: integer;
  labin, labot: TLabel;
  edin, edot: TEdit;
  tmp:boolean;
begin
  if Width < min_width then Width:=min_width;
  if Width>Screen.Width then Width:=Screen.Width-10;
  my_width:=Width;
  Height:=Round(0.7*Width);
  if Left+Width > Screen.Width then Left:=Screen.Width-Width;
  x:=dsr;
  y:=dsr;
  wid:=ClientWidth-2*dsr;
  hgt:=Round(0.3*wid);

  if flofig.Visible then begin
    fig.SetSize(x,y,wid-hgt-dsr,hgt);
    flofig.SetSize(x+wid-hgt,y,hgt,hgt);
  end else begin
    fig.SetSize(x,y,wid,hgt);
  end;

  xtab:=(wid - 2*dsr) div 3;
//  ytab:=ClientHeight-hgt-4*dsr;
  ytab:=ClientHeight-hgt-4*dsr-dyb;
  colwid:=xtab div 2 - dsr;
  drbx:=colwid-2*ds;
  x:=dsr;
//  y:=hgt+2*dsr;
  y:=hgt+2*dsr;
//  dx:=(colwid-3*ds) div 4;
  dx:=(colwid-5*ds-34) div 4;
  dy:=20;
  butplotleft.SetBounds (x          ,y,dx,dy);
  butplotzomin.SetBounds(x+  (dx+ds),y,dx,dy);
  butplotzomot.SetBounds(x+2*(dx+ds),y,dx,dy);
  butplotright.SetBounds(x+3*(dx+ds),y,dx,dy);
  butvzin.left:=x+4*(dx+ds); butvzin.top:=y;
  butvzot.left:=x+4*(dx+ds)+ds+17; butvzot.top:=y;
  y:=hgt+2*dsr+dyb;
  rgshow.SetBounds(x,y,colwid,ytab-dy);
  drby:=ytab div 11;
  x:=x+ds;
  Inc(y, drby); rbbeta.setbounds(x,y,drbx, drby);
  Inc(y, drby); rbhcy.setbounds(x,y,drbx, drby);
  Inc(y, drby); rbsigma.setbounds(x,y,drbx, drby);
  Inc(y, drby); rbapr.setbounds(x,y,drbx, drby);
  Inc(y, drby); rbvol.setbounds(x,y,drbx, drby);
  Inc(y, drby); rbma.setbounds(x,y,drbx, drby);
  Inc(y, drby); rbzeta.setbounds(x,y,drbx, drby);
  Inc(y, drby); rbinvt.setbounds(x,y,drbx, drby);
  Inc(y, drby); rbinvtlog.setbounds(x,y,drbx, drby);

  x:=colwid+2*xtab+4*dsr;
  y:=hgt+2*dsr;
  drby:=ytab div 10;
  dy:=drby-ds;
  colwh:=(colwid -ds) div 2;
               labtlincap.setbounds(x,y+2,colwid,dy);
  inc(y,drby); labtlin.setbounds(x,y-2,colwid,dy);
  inc(y,drby); labtdyncap.setbounds(x,y+2,colwid,dy);
  inc(y,drby); labdyn.setbounds(x,y-2,colwid,dy);
  inc(y,drby); butt.setbounds(x,y,colwh, dy); chkRFL.setbounds(x+colwh+ds,y,colwh, dy);
  inc(y,drby); butt_S.setbounds(x,y,colwh, dy); butt_F.setbounds(x+colwh+ds,y,colwh, dy);
  inc(y,drby); butbreak.setbounds(x,y,colwid, dy);
  inc(y,drby); butps.setbounds(x,y,colwid, dy);
  inc(y,drby); butfile.setbounds(x,y,colwh, dy); //butzap.setbounds(x+colwh+ds,y,colwh, dy);
  inc(y,drby); butex.setbounds(x,y,colwid, dy);

  y:=hgt+2*dsr;
  nrows:=nedit;
  if nout > nedit then nrows:=nout;
  panin.setBounds(colwid+2*dsr,y, xtab, ytab);
  panot.setBounds(colwid+xtab+3*dsr,y, xtab, ytab);
  x:=dsr;
  yed:=(panin.Height-(nrows+1)*ds) div nrows;
  ylb:=yed-4;
  xlb:=round(0.6*xtab);
  xed:=xtab-3*dsr-xlb;
  y:=ds;
  for i:=1 to nedit do begin
    edin :=TEdit (FindComponent( 'edin_'+IntToStr(i)));
    labin:=TLabel(FindComponent('labin_'+IntToStr(i)));
    labin.setbounds(x,y+2,xlb,ylb);
    edin.setbounds(x+xlb+dsr,y,xed,yed);
    inc(y, yed+ds);
  end;
  y:=ds;
  for i:=1 to nout do begin
    edot :=TEdit (FindComponent( 'edot_'+IntToStr(i)));
    labot:=TLabel(FindComponent('labot_'+IntToStr(i)));
    labot.setbounds(x,y+2,xlb,ylb);
    edot.setbounds(x+xlb+dsr,y,xed,yed);
    inc(y, yed+ds);
  end;
  labin:=TLabel(FindComponent('labin_'+IntToStr(iicoup)));
  if not (status.uncoupled or warn_coup_done) then labin.Color:=clSkyBlue else labin.Color:=clBtnFace;
  labin:=TLabel(FindComponent('labin_'+IntToStr(iiharm)));
  if status.rfaccept then labin.Color:=clSkyBlue else labin.Color:=clBtnFace;
  labin:=TLabel(FindComponent('labin_'+IntToStr(iivolt)));
  if status.rfaccept then begin
    labin.Color:=clSkyBlue;
    tmp:=false; for i:=1 to 4 do if snapsave.voltRF[i]<>0 then tmp:=true;
    if tmp then labin.caption:=labin_cap[iivolt]+' + HC !' else labin.caption:=labin_cap[iivolt];
  end else begin
    labin.Color:=clBtnFace;
    labin.Caption:=labin_cap[iivolt];
  end;
end;

//-------------------------------




// Event Handlers ------------------------------------------------

procedure TtrackT.FormPaint(Sender: TObject);
begin
//  MakePlot;
end;

procedure TtrackT.FormResize(Sender: TObject);
begin
  ResizeAll;
end;

procedure TtrackT.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TrackBreak:=true;
  ClearOpval;
  CurvePlot.enable:=False;
  TrackT:=nil;
end;

procedure TtrackT.butexClick(Sender: TObject);
begin
  Exit;
end;

procedure TtrackT.edin_KeyPress(Sender: TObject; var Key: Char);
var
  x:real;
  ed: TEdit;
begin
  ed:=Sender as TEdit; x:=0;
  if TEKeyVal(ed, Key, x, formin_wid[ed.tag], formin_dec[ed.Tag]) then edin_Action(ed);
end;

procedure TtrackT.edin_Exit(Sender: TObject);
var
  x:real;
  ed: TEdit;
begin
  ed:=Sender as TEdit; x:=0;
  if TEReadVal(ed, x, formin_wid[ed.tag], formin_dec[ed.Tag]) then edin_Action(ed);
end;

procedure TtrackT.edin_Action(Ed: TEdit);
var
  i: integer;   x: real;
  Ed2: TEdit;
begin
  i:=Ed.Tag; x:=0;
  TEREadVal(Ed,x,formin_wid[ed.tag], formin_dec[ed.Tag]);
  if x<>edin_val[i] then begin
    if x<loin_val[i] then x:=loin_val[i];
    if x>hiin_val[i] then x:=hiin_val[i];
//special tests:
  // not more bunches than buckets:
    if (i=iinbun) and (x>edin_val[iiharm]) then x:=edin_val[iiharm];
    if (i=iiharm) and (edin_val[iinbun]>x) then begin
      edin_val[iinbun]:=x;
      Ed2:=TEdit (FindComponent( 'edin_'+IntToStr(iinbun)));
      Ed2.Text:=FtoS(x,formin_wid[iinbun], formin_dec[iinbun]);
    end;
  // long resolution not too fine, max. 50000 lattice points
    if (i=iidels) and (x<Beam.Circ/5E4) then x:=Beam.Circ/5e4;
    edin_val[i]:=x;
    Ed.Text:=FtoS(x,formin_wid[i], formin_dec[i]);
    OutPut(i);
    // set turns to track depending on nu_s?
  end;
end;

procedure TtrackT.rbClicked(Sender: TObject);
var
  rb:TRadioButton;
begin
  rb:=Sender as TRadioButton;
  plotmode:=rb.Tag;
  MakePlot;
end;


procedure TtrackT.beforeTracking;
begin
  TrackBreak:=False;
  butBreak.Enabled:=True;
  butt.Enabled  :=false;
  butt_S.Enabled:=false;
  butt_F.Enabled:=false;
  rgShow.enabled:=false;
  butex.enabled:=false;
  panin.enabled:=false;
  rbma.Checked:=True;
end;

procedure TtrackT.afterTracking;
begin
  panin.enabled:=true;
  butex.enabled:=true;
  rgShow.enabled:=true;
  butBreak.Enabled:=False;
  butt.Enabled:=True;
  butt_S.Enabled:=True;
  butt_F.Enabled:=True;
end;

procedure TtrackT.buttClick(Sender: TObject);
begin
  SyncMode:=False;
  beforeTracking;
  TrackMAdyn;
  afterTracking;
end;


procedure TtrackT.butt_FClick(Sender: TObject);
begin
  if length(FloPdpp) = 0 then
    MessageDlg( 'Please run the xx''p DA calculation first.'+sLineBreak+'DA slices required for FTT.', MtWarning, [mbOK],0)
  else begin
    SyncMode:=False;
    beforeTracking;
    TrackMA_FTT;
    aftertracking;
  end;
end;

procedure TtrackT.butt_SClick(Sender: TObject);
begin
  SyncMode:=(Stune > 0.0);
  beforeTracking;
  TrackMAdyn;
  afterTracking;
end;

procedure TtrackT.butbreakClick(Sender: TObject);
begin
  TrackBreak:=True;
end;

procedure TtrackT.butpsClick(Sender: TObject);
const mfmode: array[0..3] of string_2 =('xy','xp','py','ft');
var
  errmsg, epsfile: string;
begin
  epsfile:=ExtractFileName(FileName);
  epsfile:=work_dir+Copy(epsfile,0,Pos('.',epsfile)-1);
  epsfile:=epsfile+'_tt_'+inttostr(plotmode)+'.eps';
  fig.plot.PS_start(epsfile,OPAversion, errmsg);
  if length(errmsg)>0 then begin
    MessageDlg('PS export failed: '+errmsg, MtError, [mbOK],0);
  end else begin
    MakePlot;
    fig.plot.PS_stop;
    MessageDlg('Graphics exported to '+epsfile, MtInformation, [mbOK],0);
    MakePlot;
  end;
end;

procedure TtrackT.ButfileClick(Sender: TObject);
const
  b=' ';
var
  fname: string;
  outfi: textfile;
  i: integer;
begin
  fname:=ExtractFileName(FileName);
  fname:=work_dir+Copy(fname,0,Pos('.',fname)-1);
//write data to file
  fname:=fname+'_touschek.txt';
  assignFile(outfi,fname);
{$I-}
  rewrite(outfi);
{$I+}
  if IOResult =0 then begin
    writeln(outfi, '#     s      betax      betay        disp     curlyH     sigmax     sigmay     Volume     divX_0     MA_lin     MA_pos      MA_neg   Zeta_lin   Zeta_pos   Zeta_neg    LossRates: lin dyn');
    writeln(outfi, '# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
    for i:=0 to High(tsig) do with tsig[i] do begin
      writeln(outfi, ftos(s,-5,2), b, ftos(bx,-5,2), b, ftos(by,-5,2), b, ftos(eta,-5,2), b,
        ftos(h,-5,2), b, ftos(x,-5,2), b, ftos(y,-5,2), b, ftos(vol,-5,2), b, ftos(d,-5,2), b,
        ftos(malin,-5,2), b, ftos(mapos,-5,2), b, ftos(maneg,-5,2), b,
        ftos(zetalinpos,-5,2), b, ftos(zetaneg,-5,2), b, ftos(zetapos,-5,2), // zetalinneg missing !!!
        b, ftos(lrlin,-5,2), b, ftos(lrdyn,-5,2));
    end;
    writeln(outfi, '# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
    CloseFile(outfi);
    MessageDlg('Data saved to text file '+fname, MtInformation, [mbOK],0);
  end else begin
    OPALog(1,'could not write '+fname);
  end;
end;



procedure TtrackT.figpPaint(Sender: TObject);
begin
   MakePlot;
end;


procedure TtrackT.butplotzoomClick(Sender: TObject);
var
  smid, swid: real;
begin
  smid:=(splotmin + splotmax)/2;
  swid:= splotmax-splotmin;
  case (Sender as TButton).Tag of
    0: begin {<}
         smid:=smid-swid/3;
       end;
    1: begin {+}
         swid:=swid/3;
       end;
    2: begin {-}
         swid:=swid*3;
       end;
    3: begin {>}
         smid:=smid+swid/3;
       end;
  end;
  if swid < swidmin then swid:=swidmin;
  if swid > swidmax then swid:=swidmax;
  splotmin:=smid-swid/2;
  splotmax:=smid+swid/2;
  if splotmin < splotminmin then begin
    splotmin:=splotminmin;
    splotmax:=splotmin+swid;
  end;
  if splotmax > splotmaxmax then begin
    splotmax:=splotmaxmax;
    splotmin:=splotmax-swid;
  end;
  MakePlot;
end;

procedure TtrackT.butplotvzoomClick(Sender: TObject);
begin
  case (Sender as TBitBtn).Tag of
    0: begin {zot<}
         Range.zoomfac[Plotmode]:=Range.zoomfac[plotmode]/1.5;
       end;
    1: begin {zin}
         Range.zoomfac[Plotmode]:=Range.zoomfac[plotmode]*1.5;
       end;
  end;
  MakePlot;
end;

end.
