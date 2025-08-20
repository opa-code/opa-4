{
Status sync.osc. 25.3.19
bis jetzt nur von trackP aus in 6D mode
funktioniert gut, korrekter Synctune
bedingt dass bucket zuvor berechnet wurde
to do:
- sicherstellen dass korrekt geprüft wird, ggf. track6 entriegeln
- trackpoint - slice element anfang ende, für touschek
- touschek track6 ersetzen
- color code dpp in trackP
- wie lässt sich tune bestimmen? keine sidebands sichtbar. warum nicht?
- ausweiten auf trackDA
- testen für harmonic cavities und pos und neg alfa

andere Baustelle:
Probleme gibt es noch mit misalignments, referenz orbit etc.
in trackingmatrix ist was faul mit den correctors
}


unit tracklib;

{$MODE Delphi}

interface

uses
  Dialogs, OPAglobal, OpticPlot, OPAElements, mathlib;

const
  minturns=16;
  maxturns=2048;
  FTkpmaxC=20;
type
  TwoTuneType = array[1..2] of double;
  geodpp_type = record
    dpp, xorb, yorb, worb, xamp, yamp, beta, alfa, betb, alfb: real;
    perstat: integer;
  end;
var
  TuneR   : array[1..2] of double;
  Peak, Tune: array[1..2] of array[1..FTkpmaxC] of double;
  kpar, kpbr, kpcr : array[1..2] of array[1..FTkpmaxC] of Integer;
  Reslabel: array[1..2] of array[1..FTkpmaxC] of String[18];
  Npeaks: array[1..2] of integer;
  Peakmax, LinTune, FundaTune: TwoTuneType;
  resgridXY: array[1..2] of array[0..2*FTkpmaxC] of integer;
  PeakChar: array[1..2] of array[1..FTkpmaxC] of char;
  OpStart: OpvalType;
  geodpp: array of geodpp_type;
  TrackMode6, UseElAper: boolean;
  TimeTracked, TimeRevol: double;
  particle: array of Vektor_5;
  parLost: array of Boolean;
  nphi_sy: real; //phase of sync.osc.
  lambda, phisyn, sinphisyn: real; // sync phase

  //flood fill x x' to polygon data: sin, cos of angle, radii, x x' orbits
  FloPc, FloPs, FloPx, FloPw, FloPxo, FloPwo, FloPdpp: array of real;
  FloPxmin, FloPxmax, FloPwmin, FloPwmax: real;
  slatt: array of real;


procedure TrackInit;
procedure TrackExit;
procedure Acc_dpp (dpprange, aperx, apery: real; np: integer; elaper: boolean);
function Initdpp (var dpp, GeoAccX, geoAccY: real;
  aperx, apery, startpos: real; elaper, updateaper: boolean):boolean;
function AmpKappa(kappa, aperx, apery, dpp: real; elaper: boolean): real;
procedure Acceptances (var geoAccx, geoAccy: real; aperx, apery, dpp: real; elaper: boolean);
procedure TrackingMatrix (dpp, startpos: real);
procedure TrackPoint;
procedure TrackToEnd (stest, dpp: real; var xend, wend: real);
procedure TMatKick(var x: Vektor_5; n: integer; kl: real; jk: integer);
function OneTurn(var xx1: Vektor_5): boolean;
function OneTurn_S(var xx1: Vektor_5): boolean;
procedure savePStrackData(kturns: integer; x: vektor_5);
Procedure SineWindow (n: Integer);
Procedure TwoFFT (n:integer);
Procedure FFTtoAmp (n: Integer);
function getFTmax(n:integer): double;
function getFT(ixy, i: integer): double;
Procedure FindPeaks(n: integer; relfilter: double);
Procedure ResoGuess ( n : Integer; deltune, pident: double );
Function ResTyp (kx, ky, kc : Integer) :Integer;

implementation

type
//  TrackMatrixPointer=^TrackMatrixType;
  TrackMatrixType = record
    M: matrix_5; // matrix for linear section of lattice
    S: Vektor_4; // accumulated misalignments vector
    kl, mrot, apx, apy, time: real; // multipole strength, apertures, time(length) of segment
    nord: integer; // multipole order
    jkick: integer; // element index in case of kicker
    sleng: real; //sposition
   end;

  FFTarrayPointer =^FFTarrayType;
  FFTarrayType    = array[1..maxturns * 2  ] of double;
  DataArrayPointer=^DataArrayType;
  DataArrayType   = array[1..maxturns      ] of double;
  FFTarrayH       = array[0..maxturns div 2] of double;

var
  Tmat: array of TrackMatrixType;
  {NTCell,} iTMstartPosition: integer;
  FFT1, FFT2: FFTarrayPointer;
  Data1, Data2: DataArrayPointer;
  FT : array[1..2] of FFTarrayH;
  iaperx, iapery: integer; // set by acceptances to find element (lattice index) defining acceptances
  aperXglobal, aperYglobal, aperxmin, aperymin: real;
  dvoltrf: array[0..4] of real; // voltage/E0/T0


procedure TrackInit;
var
  i: integer;
begin
// save dpp=0 values
  with Glob.Op0 do begin
    Beta_ref[1]:=beta;      Beta_ref[2]:=alfa;      Beta_ref[3]:=betb;      Beta_ref[4]:=alfb;
    Eta_ref[1] :=disx;      Eta_ref[2] :=dipx;      Eta_ref[3] :=disy;      Eta_ref[4] :=dipy;
    for i:=1 to 4 do Orbi_ref[i]:=orb[i];
  end;
// set number of tracking matrix pointers = 0
//  NTcell:=0;
// allocate FFT arrays
  New(FFT1); New(FFT2);
  New(Data1); New(Data2);

// check if we have data for sync osc; beam data have to exist, otherwise tracking was not enabled at all.
  if status.RFaccept then begin
    for i:=0 to 4 do dvoltrf[i]:=snapsave.voltrf[i]/(Glob.Energy*1e9);
    if Beam.alfa < 0 then for i:=1 to 4 do dvoltrf[i]:=-dvoltrf[i];
    sinphisyn:=Beam.U0*1e3/snapsave.voltrf[0];
    phisyn:=ArcSin(sinphisyn);
    lambda:=snapsave.lambdaRF;
//    for i:=0 to 4 do writeln(diagfil, '         ',i,' ',dvoltrf[i], snapsave.voltrf[i]);
//    writeln(diagfil, sinphisyn, phisyn, lambda, snapsave.rfaccm, snapsave.rfaccp);
  end;

end;

procedure TrackExit;
var
  i: integer;
begin
  Tmat:=nil; geodpp:=nil;
  particle:=nil;   parLost:=nil;
  Dispose(FFT1); Dispose(FFT2);
  Dispose(Data1); Dispose(Data2);
// restore the periodic solution for dpp=0
  Glob.dpp:=0;
  with Glob.Op0 do begin
    beta :=Beta_ref[1];     alfa :=Beta_ref[2];     betb :=Beta_ref[3];     alfb :=Beta_ref[4];
    disx :=Eta_ref[1];      dipx :=Eta_ref[2];      disy :=Eta_ref[3];      dipy :=Eta_ref[4];
    for i:=1 to 4 do orb[i]:=Orbi_ref[i];
  end;
//close TuneDiagram
end;

procedure Acc_dpp (dpprange, aperx, apery: real; np: integer; elaper: boolean);
var
  i, np0: integer;
  LinDisp: Vektor_4;

  procedure Nextdpp(ipp: integer);
  var
    accx, accy: real;
    nop: boolean;
    k: integer;
  begin
    nop:=false; accx:=0; accy:=0; //init to make compiler happy
    glob.dpp:=geodpp[ipp].dpp;
    ClosedOrbit(nop, 0, geodpp[ipp].dpp);
    if nop then begin
      geodpp[ipp].perstat:=2;
      for k:=0 to 4 do Glob.Op0.orb[k]:=LinDisp[k]*geodpp[ipp].dpp;
    end else begin
      geodpp[ipp].xorb:=Glob.Op0.orb[1];
      geodpp[ipp].yorb:=Glob.Op0.orb[3];
      geodpp[ipp].worb:=Glob.Op0.orb[2];
      Periodic(nop);
      if nop then  with geodpp[ipp] do begin
        perstat:=1;
        xamp:=0; yamp:=0;
      end else begin
//     always get geo acc with element apertures for plot...
        Acceptances(accX, accY, aperx, apery, geodpp[ipp].dpp, true);
        with geodpp[ipp] do begin
          perstat:=0;
//          xamp:=sqrt(accX*Glob.Op0.beta); //!
//          yamp:=sqrt(accY*Glob.Op0.betb); //!
          xamp:=accX;
          yamp:=accY;
          beta:=Glob.Op0.beta;          alfa:=Glob.Op0.alfa; //only needed for xx'p 2.2.23
          betb:=Glob.Op0.betb;          alfb:=Glob.Op0.alfb; //not needed yet
        end;
//  ... but if element apertures are not to be used, then recalc accX excluding them
//          if not elaper then  Acceptances(accX, accY, aperx, apery, geodpp[ipp].dpp, false);
        Acceptances(accX, accY, aperx, apery, geodpp[ipp].dpp, elaper);
      end;
    end;
  end;

begin
// np has to be odd, order values -dpprange....0....dpprange
  UseSext:=True;
  setlength(geodpp,np);
  np0:=np div 2;
  for i:=0 to np-1 do geodpp[i].dpp:=(i-np0)/np0*dpprange;
  Nextdpp(np0);
  LinDisp:=OpToDisp(Glob.Op0);
  for i:=np0-1 downto 0 do Nextdpp(i);
  for i:=1 to 5 do OrbToOp(VecNul4, Glob.Op0); // reset orbit to zero
  Nextdpp(np0);
  for i:=np0+1 to np-1 do Nextdpp(i);
  for i:=1 to 5 do OrbToOp(VecNul4, Glob.Op0); // reset orbit to zero
  Nextdpp(np0); // otherwise undefined status afterwards
//  for i:=0 to np-1 do with geodpp[i] do writeln(diagfil,i,dpp,' ',perstat,' ',xorb,xamp,yamp);
end;




{initialize tracking: set up tracking matrix for dp/p and calculate acceptances
check if periodic solution exists. if not, do set up for dp/p=0 and return false}
function Initdpp (var dpp, GeoAccX, geoAccY: real;
  aperx, apery, startpos: real; elaper, updateaper: boolean):boolean;
var
  dummy, noper: boolean;
  i: integer;
begin
  UseSext:=True;
  noper:=false; dummy:=false;
  if dpp <> 0.0 then for i:=1 to 4 do glob.Op0.orb[i]:=Eta_ref[i]*dpp;
  glob.dpp:=dpp;
//  ClosedOrbit(noper, 0, dpp);
//opalog(0, 'bef clo');
  ClosedOrbit(noper, do_twiss+do_misal, dpp);
//if noper then opalog(0, 'clo false') else opamessage(0, 'clo true');
  if not noper then Periodic(noper);
//if noper then opalog(0, 'per false') else opamessage(0, 'per true') ;
  if noper then begin
//    Glob.Orbit0:=orbi_ref;
    OrbToOp(VecNul4, glob.Op0);
    glob.dpp:=0.0;
    ClosedOrbit(dummy, 0, 0.0);
    Periodic(dummy);
    if updateaper then Acceptances( GeoAccX, GeoAccY, aperx, apery, 0.0, elaper);
    for i:=1 to 4 do glob.Op0.orb[i]:=Eta_ref[i]*dpp;
    glob.dpp:=dpp;
  end
  else if updateaper then Acceptances(GeoAccX, GeoAccY, aperx, apery, dpp, elaper);
  LinTune[1]:=  Glob.Nper*Beam.Qa;  LinTune[2]:=  Glob.NPer*Beam.Qb;
  TrackingMatrix(dpp, startpos);
  TrackPoint;
  Initdpp:=noper;
end;

{-------------------------------------------------------------------------}
{get the max total betatron amplitude amp=ampx+ampy for a coupling kappa=ampy/amp}
// inefficient - better pass list of kappa values and do twiss only once ?
function AmpKappa(kappa, aperx, apery, dpp: real; elaper: boolean): real;
var
  ax, ay, nk, pk, qk, radk, sqampk, sqampkmin: real;
  i, j: integer;
  latmode: shortint;
begin
  sqampkmin:=1e10;
  latmode:=do_twiss;
  OptInit;
  for i:=1 to Glob.NLatt do begin
    j:=FindEl(i);
    with Ella[j] do begin
      case cod of
        cdrif : DriftSpace(l,latmode);
        cquad : Quadrupole  (l, kq, rot, dpp, Lattice[i].inv, latmode, 0,0,0);
        cbend : Bending     (l, phi, kb, tin, tex, gap, k1in, k1ex, k2in, k2ex, rot, dpp, Lattice[i].inv,latmode, 0,0,0);
        csext : Sextupole   (l,ms, 0, dpp, sslice, Lattice[i].inv, latmode, 0,0,0);
        csole : Solenoid    (l, ks, dpp, Lattice[i].inv, latmode, 0,0,0);
        cundu : Undulator   (l, bmax, lam, ugap, fill1, fill2, fill3, rot, dpp, Lattice[i].inv,latmode, halfu,0,0,0);
        ccomb : Combined  (l, cphi, cerin, cerex, cek1in, cek1ex, cgap, ckq, cms, rot, dpp, cslice, Lattice[i].inv, latmode, 0,0,0);
        cmpol : Multipole(nord, bnl, rot, dpp, Lattice[i].inv,latmode, 0,0,0);
        ccorh : HCorr       (dxp, dpp, Lattice[i].inv,latmode, 0,0,0,0);
//        ccorv : VCorr       (dyp, dpp, Lattice[i].inv, latmode);  // why excluded?
        else    DriftSpace(l,latmode);
      end;
    end;//with
    ax:=aperx;
    ay:=apery;
    if elaper then begin
 //   if true then begin
      if Ella[j].ax>0 then ax:=Ella[j].ax;
      if Ella[j].ay>0 then ay:=Ella[j].ay;
    end;
    ax:=ax/1000.0; ay:=ay/1000.0;
    nk :=sqr(ay)*SigNa2[1,1]*(1-kappa)+sqr(ax)*SigNb2[1,1]*kappa;
    pk :=( sqr(ay)*abs(Orbit2[1])*sqrt(1-kappa)*sqrt(SigNa2[1,1])+
           sqr(ax)*abs(Orbit2[3])*sqrt(  kappa)*sqrt(SigNb2[1,1]) )/nk;
    qk :=(sqr(ay*Orbit2[1])+Sqr(ax*Orbit2[3])-sqr(ax*ay))/nk;
    radk:=sqr(pk)-qk;
    if radk <0 then sqampk:=0.0 else sqampk:=-pk+sqrt(radk);
    if sqampk<sqampkmin then sqampkmin:=sqampk;
  end;
  AmpKappa:=sqr(sqampkmin);
//  writeln(diagfil, 'kappa=',kappa, '  ampx=', ampKappa*(1-kappa), '   ampy=',ampKappa*kappa);
end;

{assumes that off energy closed orbit was found and stored in glob,.orbit0}
procedure Acceptances (var geoAccx, geoAccy: real; aperx, apery, dpp: real; elaper: boolean);
Var
  a, a1, a2, ax, ay, ra, delx, betx, bety, sway, heave, roll : real;
  i,j: integer;
  latmode: shortint;
begin
  latmode:=do_twiss+do_misal;
  OptInit;
  geoAccX:=1.0; geoAccY:=1.0; iaperx:=0; iapery:=0;
  for i:=1 to Glob.NLatt do begin
    j:=FindEl(i);
//    with Lattice[i] do begin sway:=dx; heave:=dy; roll:=dt; end;
    with Ella[j] do begin
      case cod of
        cdrif : DriftSpace(l,latmode);
        cquad : Quadrupole  (l, kq, rot, dpp, Lattice[i].inv, latmode, 0,0,0);
        cbend : Bending     (l, phi, kb, tin, tex, gap, k1in, k1ex, k2in, k2ex, rot, dpp, Lattice[i].inv,latmode, 0,0,0);
        csext : Sextupole   (l,ms, 0, dpp, sslice, Lattice[i].inv,latmode, 0,0,0);
        csole : Solenoid    (l, ks, dpp, Lattice[i].inv, latmode, 0,0,0);
        cundu : Undulator   (l, bmax, lam, ugap, fill1, fill2, fill3, rot, dpp, Lattice[i].inv,latmode, halfu,0,0,0);
        ccomb : Combined  (l, cphi, cerin, cerex, cek1in, cek1ex, cgap, ckq, cms, rot, dpp, cslice, Lattice[i].inv, latmode, 0,0,0);
        cmpol : Multipole(nord, bnl, rot,dpp,Lattice[i].inv,latmode, 0,0,0);
        ccorh : HCorr       (dxp, dpp, Lattice[i].inv, latmode,0, 0,0,0);
        ccorv : VCorr       (dyp, dpp, Lattice[i].inv, latmode,0, 0,0,0);
        else    DriftSpace(l,latmode);
      end;
    end;//with
    if elaper then begin
      if Ella[j].ax>0 then ax:=Ella[j].ax;
      if Ella[j].ay>0 then ay:=Ella[j].ay;
// to do : include septum but only on one side!
    end else begin
      ax:=aperx;
      ay:=apery;
    end;
    ra:=ax/1000;
    betx:=SigNa2[1,1]; bety:=SigNb2[1,1];
    delx:=ra-Orbit2[1];  if delx > 0 then a1:=sqr(delx)/betx else a1:=0;
    delx:=ra+Orbit2[1];  if delx > 0 then a2:=sqr(delx)/betx else a2:=0;
    if a1<a2 then a:=a1 else a:=a2;
    if a < GeoAccX then begin GeoAccX:=a; iaperx:=i; aperxmin:=ax; end;
    ra:=ay/1000;
    a1:=sqr(ra-Orbit2[3])/bety;
    a2:=sqr(ra+Orbit2[3])/bety;
    if a1<a2 then a:=a1 else a:=a2;
    if a < GeoAccY then begin GeoAccY:=a; iapery:=i; aperymin:=ay; end;
  end; //i =1..NLatt
  UseElAper:=elaper;
  aperXglobal:=aperx/1000; aperYglobal:=apery/1000;
end;

procedure TrackingMatrix (dpp, startpos: real);
{
concatenation of linear elements. T[i] is a matrix followed by a NL-kick.
assumes that off energy closed orbit was found and stored in glob.orbit0

upgrade for touschek (110708):
select arbitrary starting position startpos, maybe inside an element!
calc betas for trackpoint?

adding time of travel, but not correct for cut elements - is only needed for injection, irrelevant for cut elements 9/5/2019
}
const
  seps=1e-6; // 1 micron
Var
  i, j, isl, nsl, itmstart, inv: integer;
  terin, terex, tk1in, tk1ex, dri, dml, dphi, sini, spos, dl1, dl2, roti, sposprev, sumlen: real;
  sendflag, smidflag: boolean;
  icotm: integer;
  sway, heave, roll: real;
  latmode: shortint;
  tmp: matrix_5;   tmpvec:vektor_4;

  procedure appendTmat(n: integer; k, rot, axmm, aymm: real; j:integer);
  begin
    setlength(Tmat,length(Tmat)+1);
    with Tmat[High(Tmat)] do begin
    //append also the rotation at the multipole entry

      M:=MatMul5(Rotation_Matrix(rot),TransferMatrix0);
      S:=MisalignVector; //how incl. rot in misal?
      nord:=n;
      kl:=k;
      mrot:=rot;
      apx:=axmm/1000; apy:=aymm/1000; jkick:=j;
      time:=(spos-sposprev)/speed_of_light;
      sleng:=sumlen; //sleng keeps exact position of end of TMat (--> should replace spos, sposprev and time ?)
//writeln('appendtmat: high, nord, k, sposprev, spos, sleng', High(tmat):4,' ',nord:4, ' ',kl:12:3, ' ',sposprev:12:6, ' ',spos:12:6, ' ', sleng:12:6);
      sposprev:=spos;
    end;
//writeln(diagfil, MisalignVector[1],MisalignVector[2],MisalignVector[3],MisalignVector[4]);
    TransferMatrix0:=Rotation_Matrix(-rot);
    MisalignVector:=VecNul4;
  end;

{to be tested, changes R--> TransferMatrix done without checking ! 27.6.2016}

  //...........................................................................
  {procedures for cutting lattice at any point inside an element}

  procedure BendCut(sini, l, phi, kb, tin, tex, gap, k1in, k1ex, k2in, k2ex, rot, dpp, ax, ay: real;  dir: integer; latmode: shortint; sway, heave, roll: real);
 {if startpos is between sini and sini+l, the bend is cut into two pieces,
  and a new Tmat created at cut. Bends do not like l=0 therefore check first
  if cut coincides with exit pos.}
  var
    l1, l2: real;
  begin
    if abs(sini+l-startpos)<seps then begin
       Bending (l, phi, kb, tin, tex, gap, k1in, k1ex, k2in, k2ex, rot, dpp, dir, latmode, sway, heave, roll);
       sumlen:=sumlen+l;
       appendTmat(0,0,0,ax,ay,0); itmstart:=High(Tmat); inc(icotm);
    end else if (startpos-sini)*(startpos-(sini+l)) < 0  then begin
      l1:=startpos-sini; l2:=sini+l-startpos;
      if dir=1
      then Bending (l1, phi*l1/l, kb, tin, 0, gap, k1in, 0, k2in, 0,  rot, dpp, 1, latmode, sway, heave, roll)
      else Bending (l1, phi*l1/l, kb, tex, 0, gap, k1ex, 0, k2ex, 0, -rot, dpp, 1, latmode, sway, heave, roll);
      sumlen:=sumlen+l1;
      appendTmat(0,0,0,ax,ay,0); itmstart:=High(Tmat); inc(icotm);
      if dir=1
      then Bending (l2, phi*l2/l, kb, 0, tex, gap, 0, k1ex, 0, k2ex,  rot, dpp, 1, latmode, sway, heave, roll)
      else Bending (l2, phi*l2/l, kb, 0, tin, gap, 0, k1in, 0, k2in, -rot, dpp, 1, latmode, sway, heave, roll);
      sumlen:=sumlen+l2;
//opamessage(0,'cut bend leng, l1, l2 : '+ftos(l,8,4)+' '+ftos(l1,8,4)+' '+ftos(l2,8,4));
    end else begin
      Bending (l, phi, kb, tin, tex, gap, k1in, k1ex, k2in, k2ex, rot, dpp, dir, latmode, sway, heave, roll);
      sumlen:=sumlen+l;
    end;
  end;

  procedure DriftCut(sini, l, ax, ay: real);
  var
    l1, l2: real;
  begin
    if abs(sini+l-startpos)<seps then begin
      DriftSpace(l,0); sumlen:=sumlen+l;
      appendTmat(0,0,0,ax,ay,0); itmstart:=High(Tmat);   inc(icotm);
    end else if (startpos-sini)*(startpos-(sini+l)) < 0  then begin
      l1:=startpos-sini; l2:=sini+l-startpos;
      DriftSpace(l1,0); sumlen:=sumlen+l1;
      appendTmat(0,0,0,ax,ay,0); itmstart:=High(Tmat);   inc(icotm);
      DriftSpace(l2,0); sumlen:=sumlen+l2;
    end else begin
      DriftSpace(l,0);  sumlen:=sumlen+l;
    end;
  end;

  {   misalignments for UncuCut not yet implemented! --> To Do !}
  procedure UnduCut  (sposin, l, B, lam, gap, fill1, fill2, rot, d, axmm, aymm : real; half: boolean; idir: shortint);
  {shortcut of OPAelements/undulator}
  var
    sini, phi, drsh, drb, irho0, sumphi, polphi, kedge : real;
    Nuper, iph, ip: integer;
    polfac: array of real;

  begin
    sini:=sposin;
    irho0 := B/(Glob.Energy/(speed_of_light/1E9)); {=B/Brho = 1/rho}
    phi  :=irho0*lam/2*fill1;
    kedge:=lam/4/gap*(fill1-fill2);
    Nuper:=Round(l/lam);
    setlength(polfac,2*nuper);
    polfac[0]:=-1/4; polfac[1]:=3/4;
    for ip:=2 to nuper-1 do begin
      polfac[2*ip-2]:=-1; polfac[2*ip-1]:=1;
    end;
    polfac[2*nuper-2]:=-3/4; polfac[2*nuper-1]:=1/4;
    drb   :=    fill1*lam/2;
    drsh  :=(1-fill1)*lam/4;
    sumphi:=0.0;
    for iph:=0 to High(polfac) do begin
      DriftCut (sini, drsh, axmm, aymm);
      sini:=sini+drsh;
      polphi:=phi*polfac[iph];
      BendCut   (sini, drb, polphi, 0, -sumphi, sumphi+polphi, gap, kedge, kedge, 0, 0, rot, d,  axmm, aymm,1,0,0,0,0);
      sini:=sini+drb;
      sumphi:=sumphi+polphi;
      DriftCut (sini, drsh, axmm, aymm);
      sini:=sini+drsh;
    end;
    polfac:=nil;
  end;
  //...........................................................................

//insert thinquad instead of n=2 multipole, since it is linear -> no mpole kicks for thin [skew] quads required
  procedure ThinQuad (b2l, ran: real);
  var
   tm: matrix_5;
  begin
    tm:=Unit_Matrix_5; tm[2,1]:=-b2l; tm[4,3]:= b2l;
    TransferMatrix0:=MatMul5(MatMul5(Rotation_matrix(-ran),MatMul5(tm, Rotation_matrix(ran))),TransferMatrix0);
  end;

begin
//writeln(diagfil,'*********************** tracklib *****************************');
  icotm:=0;
  Tmat:=nil;
  itmstart:=-1;
  OptInit;
  spos:=0;
  latmode:=do_misal;
  sposprev:=0;
  sumlen:=0;
  for i:=1 to Glob.NLatt do begin
    j:=FindEl(i);
    with Ella[j] do begin
      smidflag:=false; sendflag:=false;
//first check if we hit the element EXIT... BUT exclude zero length elements!
      if abs(spos+l-startpos)< l*seps then begin
        sendflag:=true;
        if diag(3) then writeln(diagfil,'TrackLib/TrackingMatrix: sendflag! i j nam, l, starpos, spos',i:4, j:4, ' ', nam, l, startpos, spos);
//..else check if we are inside an element:
      end else if (startpos-spos)*(startpos-(spos+l)) < 0  then begin
        smidflag:=true;
        dl1:=startpos-spos; dl2:=spos+l-startpos;
        if diag(3) then writeln(diagfil,'TrackLib/TrackingMatrix: smidflag! i j nam, l, starpos, spos',i:4, j:4, ' ', nam, l, startpos, spos);
      end;

      inv:=Lattice[i].inv;
      sway:=Lattice[i].dx; heave:=Lattice[i].dy; roll:=0;
//      writeln(diagfil, i,' > ', sway, heave, ella[j].nam);

//writeln(diagfil,'Latt =', i, ', nam = ',nam,', cod = ', cod,' flags ',sendflag, smidflag);
      case cod of

        cdrif : if smidflag then DriftCut(spos,l,ax,ay) else begin DriftSpace(l,latmode); sumlen:=sumlen+l; end;


// not checked yet if cutting works properly with inversion/rotation -- perhaps abandon cutting: complicated and not really needed.
        cquad : if smidflag then begin
                  Quadrupole  (dl1, kq, rot, dpp, inv, latmode, sway, heave, roll); sumlen:=sumlen+dl1;
                  appendTmat(0,0,0,ax,ay,0); itmstart:=High(Tmat);  inc(icotm);
                  Quadrupole  (dl2, kq, rot, dpp, Lattice[i].inv, latmode, sway, heave, roll); sumlen:=sumlen+dl2;
                end else begin
                  Quadrupole  (l, kq, rot, dpp, inv, latmode, sway, heave, roll); sumlen:=sumlen+l;
                end;

        cbend : if smidflag
                then BendCut (spos, l, phi, kb, tin, tex, gap, k1in, k1ex, k2in, k2ex, rot, dpp, ax, ay, inv, latmode, sway, heave, roll)
                else begin
                  Bending (      l, phi, kb, tin, tex, gap, k1in, k1ex, k2in, k2ex, rot, dpp, inv, latmode, sway, heave, roll);
                  sumlen:=sumlen+l;
                end;

        csext : begin
                  if l=0 then begin dri:=0; nsl:=1; dml:=ms; end //thin, integr.
                         else begin dri:=l/sslice/2; nsl:=sslice; dml:=ms*2*dri; end;
                  if smidflag then begin
                    sini:=spos;
                    for isl:=1 to nsl do begin
                      DriftCut(sini,dri,ax,ay);
                      sini:=sini+dri;
                      appendTmat(3, dml/(1+dpp), inv*rot, ax, ay,0);
                      DriftCut(sini,dri,ax,ay);
                      sini:=sini+dri;
                    end;
                  end else begin
                    for isl:=1 to nsl do begin
                      Driftspace(dri,latmode); sumlen:=sumlen+dri;
                      appendTmat(3, dml/(1+dpp), inv*rot,ax, ay,0);
                      Driftspace(dri,latmode); sumlen:=sumlen+dri;
                    end;
                  end;
                end;

        csole : if smidflag then begin
                  Solenoid (dl1, ks, dpp, inv, latmode, sway, heave, roll); sumlen:=sumlen+dl1;
                  appendTmat(0,0,0,ax,ay,0); itmstart:=High(Tmat);inc(icotm);
                  Solenoid (dl2, ks, dpp, inv, latmode, sway, heave, roll); sumlen:=sumlen+dl2;
                end else begin
                  Solenoid  (l, ks, dpp,  inv, latmode, sway, heave, roll);
                  sumlen:=sumlen+l;
                end;

        cundu : if smidflag
                then UnduCut(spos, l, bmax, lam, ugap, fill1, fill2, rot, dpp, ax, ay, halfu, inv)
                else begin
                  Undulator (l, bmax, lam, ugap, fill1, fill2, fill3, rot, dpp, inv, latmode, halfu, sway, heave, roll);
                  sumlen:=sumlen+l;
                end;


//! check for rotation change if inversion done explicitly!
        ccomb : begin
                  nsl:=cslice;
                  dri :=l/(2*nsl);
                  dphi:=cphi/(2*nsl);
                  dml :=cms*2*dri; //integrated sextupole of slice
                  if Lattice[i].inv=1
                  then begin terin:=cerin; tk1in:=cek1in; terex:=cerex; tk1ex:=cek1ex; roti:= rot; end
                  else begin terin:=cerex; tk1in:=cek1ex; terex:=cerin; tk1ex:=cek1in; roti:=-rot; end;
                  if smidflag then begin
                    sini:=spos;
                    for isl:=1 to nsl do begin
                      if isl=1   then BendCut (sini, dri, dphi, ckq, terin, 0, cgap, tk1in, 0, 0, 0, roti, dpp, ax, ay, 1, latmode, sway, heave, roll)
                                 else BendCut (sini, dri, dphi, ckq,     0, 0,    0,     0, 0, 0, 0, roti, dpp, ax, ay, 1, latmode, sway, heave, roll);
                      sini:=sini+dri;
                      appendTmat(3, dml/(1+dpp), rot,ax, ay,0);
                      if isl=nsl then BendCut (sini, dri, dphi, ckq, 0, terex, cgap, 0, tk1ex, 0, 0, roti, dpp, ax, ay, 1, latmode, sway, heave, roll)
                                 else BendCut (sini, dri, dphi, ckq, 0,     0,    0, 0,     0, 0, 0, roti, dpp, ax, ay, 1, latmode, sway, heave, roll);
                      sini:=sini+dri;
                    end;
                  end else begin
                    for isl:=1 to nsl do begin
                      if isl=1   then Bending (dri, dphi, ckq, terin, 0, cgap, tk1in, 0, 0, 0, roti, dpp, 1, latmode, sway, heave, roll)
                                 else Bending (dri, dphi, ckq,     0, 0,    0,     0, 0, 0, 0, roti, dpp, 1, latmode, sway, heave, roll);
                      sumlen:=sumlen+dri;
                      appendTmat(3, dml/(1+dpp), rot,ax, ay,0);
                      if isl=nsl then Bending (dri, dphi, ckq, 0, terex, cgap, 0, tk1ex, 0, 0, roti, dpp, 1, latmode, sway, heave, roll)
                                 else Bending (dri, dphi, ckq, 0,     0,    0, 0,     0, 0, 0, roti, dpp, 1, latmode, sway, heave, roll);
                      sumlen:=sumlen+dri;
                    end;
                  end;
                end;

        cmpol : if nord=2 then ThinQuad(bnl/(1+dpp), inv*rot) else appendTmat(nord, bnl/(1+dpp), inv*rot, ax, ay,0);

// handle corr as mpoles
        ccorh: if abs(dxp) > 1e-10 then appendTmat( 1, dxp/(1+dpp), inv*rot, ax, ay,0);
        ccorv: if abs(dyp) > 1e-10 then appendTmat(-1, dyp/(1+dpp), inv*rot, ax, ay,0);

        crota: Rotation(rot,inv,0);

        ckick: begin
                 Driftspace(l/2,latmode); sumlen:=sumlen+l/2;
                 appendTmat(mpol,amp/(1+dpp), inv*rot, ax,ay, j);
                 Driftspace(l/2,latmode); sumlen:=sumlen+l/2;
//writeln(diagfil, 'apendtmat', amp, spos, sposprev);
               end

        else if smidflag then Driftcut(spos,l,ax,ay) else begin
          DriftSpace(l,latmode);
          sumlen:=sumlen+l;
        end;
      end; //case
      if sendflag then begin
        appendTmat(0,0,0,ax,ay,0); itmstart:=High(Tmat); inc(icotm);
      end;

// test at max. excursion for aperture in x or y

      if i=iaperx then begin appendTmat(0,0,0,aperxmin,1E4,0);
//        writeln('iaperx, aperxmin, elem, spos :', iaperx,' ',aperxmin:10:3,' ', ella[j].nam,' ', spos:12:3);
      end;
      if i=iapery then appendTmat(0,0,0,1E4,aperymin,0);

      spos:=spos+l;   //counts full elements only
    end; //with
  end;
  appendTmat(0,0, 0,Ella[j].ax, Ella[j].ay,0);
//  NTcell:=High(Tmat);
  TimeRevol:=spos/speed_of_light; 
//  spos:=0; for i:= 0 to High(Tmat) do spos:=sposprev+Tmat[i].time*speed_of_light; writeln(diagfil,'test spos = ', spos);
  iTMstartPosition:=itmstart;

  if diag(3) then begin
     writeln(diagfil, 'TrackLib/TrackingMatrix: itmstart, icot, s:',itmstart:10,icotm:10, startpos:12:6);
     for i:=0 to High(Tmat) do with Tmat[i] do begin
       writeln(diagfil, 'Tmat ', i ,' ----------------------------------------');
       PrintMat5(M);
       writeln(diagfil,nord,' ',kl,' ', apx, ' ', apy, ' ',jkick, sleng);
     end;
  end;

  if diag(3) then begin
    tmp:=Unit_Matrix_5;
    for i:=0 to High(Tmat) do with Tmat[i] do tmp:=MatMul5(M,tmp);
    writeln(diagfil, 'tracklib product Tmat:');
    PrintMat5(tmp);
    writeln(diagfil,'orbit start x, xp, dpp =', Glob.Op0.orb[1], Glob.Op0.orb[2], dpp);
    tmpvec:=Lintra54(tmp,Glob.Op0.orb,dpp);
    writeln(diagfil,'orbit end   x, xp      =', tmpvec[1], tmpvec[2]);
  end;

end;

{------------------------------------------------------------------------}

procedure TrackPoint;
// calculate betas and orbit at the location of the trackpoint
var
  i: integer;
  orb5: vektor_5;

  procedure ccprop (var siga, sigb, cc: matrix_2; var d: vektor_4; tmt: matrix_5);
  // short version of opaElements/mcc_prop, since tmt may be coupling; updates in place
  var
    arg, g1, gT, cdet: double;
    sigat, sigbt, mm, m, n, nn, e1T, f1T, CCT: matrix_2;
    DT : Vektor_4;
  begin
    mm:=MatCut52(tmT,1,1); nn:=MatCut52(tmT,3,3);
    m :=MatCut52(tmT,1,3); n :=MatCut52(tmT,3,1);
    cdet:=MatDet2(CC);
    g1:=sqrt(1-cdet);
    arg := MatDet2(MatAdd2(MatMul2(n,CC),MatSca2(g1,nn))); // = g2^2, Eq.27
    if arg>0 then begin // propagation without flip - this is the normal case and works well.
      gT:=sqrt(arg);
      e1T :=MatSca2(1./gT, MatSub2( MatSca2(g1,mm),MatMul2(m,MatSyc2(CC)))); //eq.28
      f1T :=MatSca2(1./gT, MatAdd2( MatSca2(g1,nn),MatMul2(n,        CC )));// eq.29
      CCT :=MatMul2(MatAdd2( MatSca2(g1,m), MatMul2(mm,CC)),MatSyc2(f1t)); //eq.30
      SigaT:=MatSig2(e1T,siga);
      SigbT:=MatSig2(f1T,sigb);
    end; { else problem}
    DT :=LinTra54(tmt,D,1);
    siga:=sigaT; sigb:=sigbT; D:=DT; CC:=CCT;
  end;

  function Mlocthin(var orb: vektor_5; nord: integer; bnl: real): matrix_5;
  // get matrix from thin multipole, and its effect on orbit
  // multipole rotation included in adjacent matrices
  var
    ocmplx, kcmplx, gcmplx: complex;
    tm: Matrix_5;
  begin
{
MisAlign(Orbit1, 0, sway, heave, roll, mode, 1);
}
    tm:=Unit_Matrix_5;
    case nord of
      0: begin
        // do nothing
      end;
      1: begin  // CH
         Orb[2]:=Orb[2]+bnl; // bnl>0 -> kick to ring outside
         tm[2,5]:=-bnl;     // thin dipole: only dispersion production, no focusing
      end;
      -1: begin  // CV
         Orb[4]:=Orb[4]+bnl;
         tm[4,5]:=-bnl;
      end;
      2: begin // n=2, short quad, contributes to matrix also for x=y=0
        Orb[2]:=Orb[2]-bnl*Orb[1];  // dx'
        Orb[4]:=Orb[4]+bnl*Orb[3];  // dy'
        tm[2,1]:=-bnl;
        tm[4,3]:= bnl;
      end
      else begin
 // - dx' + i dy' = bn L (x + iy)^(n-1)
 //quad + skew quad downfeed from multipole, note as-19.4.2016
        ocmplx:=c_get(Orb[1],Orb[3]);  // x+iy
        gcmplx:=c_pow(ocmplx,nord-2) ;  // (x+iy)^(n-2)
        kcmplx:=c_sca(c_mul(gcmplx,ocmplx),bnl);            // (x+iy)^(n-1) * bn L
        gcmplx:=c_sca(gcmplx,bnl*(nord-1)) ;  // (n-1)*(x+iy)^(n-2) *bn L
        Orb[2]:=Orb[2]-kcmplx.re;  // dx'
        Orb[4]:=Orb[4]+kcmplx.im;  // dy'
        tm[2,1]:=-gcmplx.re;
        tm[4,3]:=-tm[2,1];
        tm[2,3]:= gcmplx.im;
        tm[4,1]:= tm[2,3];
      end;
    end;

{
    MisAlign(Orbit1, 0, sway, heave, roll, mode,-1);
}
    Mlocthin:=tm;
  end;

begin
  // get betas at trackpoint
  Optinit;
  for i:=0 to iTMstartPosition do with TMat[i] do begin
    ccprop(signa2, signb2, coupmatrix2, disper2, M);
    orb5:=Vektor45(LinTra54(M, Orbit2, glob.dpp),0);
    ccprop(signa2, signb2, coupmatrix2, disper2, MLocThin(orb5, nord, kl));
    Orbit2:=Vektor54(orb5);
  end;

{ old
**** update with coupling ! M may couple
    MatSigS (P2, M, P1);
    LinTraS (D2, M, D1);
    LinTraS (O2, M, O1);
    TMatKick (O2, nord, kl);
    TMatSext (P2, D2, nord, kl, O2[1]);
    D1:=D2; P1:=P2; O1:=O2;
}

//  Opstart.spos:=spos;
  with OpStart do begin
    beta:= sigNa2[1,1]; betb:= sigNb2[1,1];
    alfa:=-sigNa2[1,2]; alfb:=-sigNb2[1,2];
    disx:=Disper2[1];    disy:=Disper2[3];
    dipx:=Disper2[2];    dipy:=Disper2[4];
    cmat:=coupmatrix2;
    phia:=0.0;  phib:=0.0;
    orb:=Orbit2;
  end;
end;

{------------------------------------------------------------------------}

procedure TrackToEnd (stest, dpp: real; var xend, wend: real);
{
track from any position stest to the end, using single element matrices until
reaching the first TMAT kick, then continue with TMAT. Elements have to be cut
if TMAT ends inside an element, or depending on stest, and in case of bends
edge treatment has to be switched off.

NOT FULLY IMPEMENTED YET: solenoid and undulator treated as drifts
Assumes zero referene orbit, no misalignments
(Touschek particles always start with dpp offset but on dpp=0 orbit.)

as 18.2.2023
}

const seps=1e-8; //10 nm

var
  itm, i, ilat1, ilat2: integer;
  stm, dl1, dl2, dsum: real;
  termtm: boolean;
  doin1, doin2, doex1, doex2: integer;
  xvec: Vektor_5;

  procedure Mpart (ilat: integer; luse, dpp: real; doin, doex: integer);
  const
    mode=0; // could be changed to do_misal to include misalignments, and get misal:  with Lattice[i] do begin sway:=dx; heave:=dy; roll:=dt; end;
  var
    t1, t2, k11, k12, dphi, dl: real;

  begin
    with Ella[Lattice[ilat].jel] do begin
// only length>0 are valid, because all thin elements (except rotation) are nonlin, kicker or corr and thus interrupt tmat
      if l>0 then begin
        if luse<0 then dl:=l else dl:=luse; //< 0 = switch to use elem length
        if dl>0 then begin
//          write('{',ilat:2,' ',nam,' ',dl:8:4, ' ',doin:1,' ',doex:1);
          case cod of
            cquad : Quadrupole  (dl, kq, rot, dpp, Lattice[ilat].inv, mode, 0,0,0);
            cbend : begin
              dphi:=phi*dl/l;
              if Lattice[ilat].inv >0 then begin
                t1:=tin*doin; t2:=tex*doex; k11:=k1in*doin; k12:=k1ex*doex; //drop k2, never used
              end else begin
                t2:=tin*doin; t1:=tex*doex; k12:=k1in*doin; k11:=k1ex*doex; //drop k2, never used
              end;
              Bending     (dl, dphi, kb, t1, t2, gap, k11, k12, 0, 0, rot, dpp, 1, mode, 0,0,0);
            end;
//            csole : Solenoid    (l, ks, dpp, Lattice[i].inv, mode, sway, heave, roll);
//            cundu : Undulator   (l, bmax, lam, ugap, fill1, fill2, fill3, rot, dpp, Lattice[i].inv, mode, halfu, sway, heave, roll);
            ccomb : begin
              dphi:=cphi*dl/l;
              if Lattice[ilat].inv >0 then begin
                t1:=cerin*doin; t2:=cerex*doex; k11:=cek1in*doin; k12:=cek1ex*doex;
              end else begin
                t2:=cerin*doin; t1:=cerex*doex; k12:=cek1in*doin; k11:=cek1ex*doex;
              end;
              Bending     (dl, dphi, ckq, t1, t2, cgap, k11, k12, 0, 0, rot, dpp, 1, mode, 0,0,0);
            end;
            else    DriftSpace(dl,mode);
          end;
        end;
      end else if cod=crota then begin //rotation only
        Rotation    (rot, Lattice[i].inv, mode);
      end;
    end;
  end;


begin
  // Tmat exec kick only of itm and start from itm+1, except s=0 then start 0
  xvec:=VecNul5;
  xvec[5]:=dpp;

  if stest=0 then begin
    itm:=0;
    xvec:=LinTra5 (Tmat[0].M, xvec); // first matrix
  end else begin

//get TMat where stest is inside
    stm:=0.0;
    itm:=0;  termtm:=false;
    repeat
      stm:=tmat[itm].sleng;
 //     writeln('tmat: ',itm, ' ',ltm:12:6, ' ',stm:12:6);
      termtm:=(stm >= stest);
      if termtm then Dec(itm); //undo inc itm
      Inc(itm);
    until termtm or (itm>High(TMat));
    if not termtm then begin
      writeln(' tmat not found: stest stm ',stest:15:9,' ', stm:15:9);
      itm:=High(TMat); //maybe only due to round off, so set to last TMAT even if not correct
    end;

//get lattice element where stest is located inside
    ilat1:=0; repeat  Inc(ilat1) until (slatt[ilat1]>=stest) or (ilat1>=Glob.NLatt);

// get lattice element where end of tmat[itm] is located inside
    ilat2:=0; repeat Inc(ilat2); until (slatt[ilat2]>=stm) or (ilat2>=Glob.NLatt);

//    write('stest ',stest:12:6,' Tmat  (', stm:12:6,' ) ' );

    // elem ilat1 dl1, ilat1+1...ilat2-1 full, ilat2 dl2; then switch to tmatkick
    // may happen that ilat1=ilat2, then use only dl2


    OptInit; //initialize transfermatrix;

    doin1:=0; doin2:=0; doex1:=0; doex2:=0;
    if ilat1=ilat2 then begin //stest and stm are inside the same element
      dl1:=0;
      dl2:=stm-stest; //distance from stest to end
      if abs(slatt[ilat2-1]-stest)<seps then doin2:=1; //first=last elem entry treatment if stest is at entry edge
      if abs(slatt[ilat2]-stm)<seps then doex2:=1; //last elem exit treatment if end coincides with Tmat (i.e. nonlin kick attached to exit edge)
      MPart(ilat2, dl2, dpp, doin2, doex2);

//      write(ilat2:2,' ',ella[lattice[ilat2].jel].nam,' ',dl2:10:4);
//      if doin2 then write(' x') else write (' o');   if doex2 then write('x ') else write ('o ');
    end else begin
      dl1:=slatt[ilat1]-stest; // eff. length of first element: from stest to its end
      if abs(slatt[ilat1-1]-stest)<seps then doin1:=1; //first elem entry treatment if stest is at entry edge i.e. end of previous element
      doex1:=1; //first element exit treatment always if there is an element behind
      Mpart(ilat1, dl1, dpp, doin1, doex1);

      for i:=ilat1+1 to ilat2-1 do begin
//        write(i:2,' ',Ella[lattice[i].jel].nam,' ', Ella[lattice[i].jel].l:8:4,' > ');
        MPart(i, -1, dpp, 1, 1); //dl <0 switch to use ella length
      end;

      dl2:=stm-slatt[ilat2-1]; //eff. length of last element is distance of end of previous element
      doin2:=1; //last element entry treatment always req'd if there is at least one element before
      if abs(slatt[ilat2]-stm)<seps then doex2:=1; //last elem exit treatment if end coincides with Tmat (i.e. nonlin kick attached to exit edge)
//      write(ilat1:2,' ',ella[lattice[ilat1].jel].nam, ' ',dl1:8:4);
      MPart(ilat2, dl2, dpp, doin2, doex2);
//      write(ilat2:2,' ',ella[lattice[ilat2].jel].nam, ' ',dl2:8:4);
    end;
    xvec:=LinTra5(TransferMatrix,xvec);
  end; //stest>0
  TMatKick(xvec, TMat[itm].nord, TMat[itm].kl, TMat[itm].jkick);
  for i:=itm+1 to High(TMat) do begin
    xvec:=LinTra5 (Tmat[i].M, xvec);
    TMatKick(xvec, TMat[i].nord, TMat[i].kl, TMat[i].jkick);
//+  perhaps check apertures to avoid overflow if particle gets lost quickly even in one turn
  end;
//  writeln(xvec[1]*1000:8:3,' ',xvec[2]*1000:8:3,' ',xvec[3]*1000:8:3,' ',xvec[4]*1000:8:3);
  xend:=xvec[1]*1000; wend:=xvec[2]*1000;
end;

procedure TMatKick(var x: Vektor_5; n: integer; kl: real; jk: integer);
var
  complexkick: complex;
  kick, kx: real;
begin
  if jk=0 then begin
    case n of
      0: begin //do nothing, only aperture check
      end;
      1: begin
         X[2]:=X[2]+kl;
      end;
      -1: begin // vcorr
       X[4]:=X[4]+kl;
      end;

// ever needed to do quad?
      2: begin // quadrupole
        X[2]:=X[2]- kl*X[1];
        X[4]:=X[4]+ kl*X[3];
      end;

      3: begin // sextupole
         X[2]:=X[2]-  kl*(sqr(X[1])-sqr(X[3]));
         X[4]:=X[4]+2*kl*X[1]*X[3];
      end;

      4: begin // octupole
         X[2]:=X[2]+  kl*X[1]*(3*sqr(X[3])-sqr(X[1]));
         X[4]:=X[4]+  kl*X[3]*(3*sqr(X[1])-sqr(X[3]));
      end;

      5: begin // decapole
         X[2]:=X[2]-  kl*(PowI(X[1],4)-6*sqr(X[1]*X[3])+PowI(X[3],4));
         X[4]:=X[4]+  kl*4*X[1]*X[3]*(sqr(X[1])-sqr(X[3]));
      end;
      else begin
// complex kick executes much slower, therefore sext-deca are done explicitly
// - dx' + i dy' = bn L (x + iy)^(n-1)
        complexKick:=c_sca(c_pow(c_get(X[1],X[3]),n-1),kl);
        X[2]:=X[2]-complexKick.re;
        X[4]:=X[4]+complexKick.im;
      end;
    end; // case

  end else begin //jk kicker, time dependent

    with Ella[jk] do begin
 //     writeln(diagfil, 'TMatKick ',jk,' ', ella[jk].nam, timetracked, delay, tau);
      if abs(TimeTracked-delay)<tau/2 then begin
        kick:=kl*cos(Pi*(TimeTracked-delay)/tau);
        if mpol>1 then begin
          if Xoff=0 then begin // treat as pure multipole, then amp = b_mpol
            if l>0 then kick:=kick*l;   //*l to get integrated multipole strength
            complexKick:=c_sca(c_pow(c_get(X[1],X[3]),mpol-1),kick);
            X[2]:=X[2]-complexKick.re;
            X[4]:=X[4]+complexKick.im;
//            writeln(diagfil, kl, timetracked, delay, tau, kick,  complexKick.re);
          end else begin // xoff <>0 ; sinusoidal kicker [sin(pi*x/(2*xo))]^(mpol-1)

// check calculations!
            kick:=kick/1000; //because stored in [mrad]
            kx:=Pi/(2*xoff);
            case mpol of
//              1: begin // dipole
//                 X[2]:=X[2]+kick;
//              end;
              2: begin //quad
                 X[2]:=X[2]+kick*sin(kx*X[1])*cosh(kx*X[3]);
                 X[4]:=X[4]-kick*cos(kx*X[1])*sinh(kx*X[3]);
              end;
              3: begin //sext
                 X[2]:=X[2]+kick*(1-cos(2*kx*X[1])*cosh(2*kx*X[3]))/2;
                 X[4]:=X[4]-kick*(  sin(2*kx*X[1])*sinh(2*kx*X[3]))/2;
              end;
              4: begin // oct
                 X[2]:=X[2]+kick*(3*sin(kx*X[1])*cosh(kx*X[3])-sin(3*kx*X[1])*cosh(3*kx*X[3]))/4;
                 X[4]:=X[4]-kick*(3*cos(kx*X[1])*sinh(kx*X[3])-cos(3*kx*X[1])*sinh(3*kx*X[3]))/4;
              end;
              else begin // nothing
              end;
            end; //case
          end; //sinusoidal
        end else begin //dipole
          X[2]:=X[2]+kick/1000;
//          writeln(diagfil,'kick', timetracked, kick);
        end;
      end; //time
    end; // with
  end; //jk
end;

{------------------------------------------------------------------------}

function OneTurn(var xx1: Vektor_5): boolean;
var
  xx2: Vektor_5;
  iper, ii, k: integer;
  Lost: boolean;

begin
  iper:=0;
  repeat
    ii:=iTMstartPosition;
//    writeln(diagfil, 'oneturn trackstart at ', ii);
    repeat
      Inc(ii);
//      LinTra (5, XX2, Tmat[ii].M, XX1);
//writeln(diagfil, 'calling Tmat index ',ii);
      XX2:=LinTra5 (Tmat[ii].M, XX1);
      TimeTracked:=TimeTracked+Tmat[ii].time;
      for k:=1 to 4 do XX2[k]:=Tmat[ii].S[k]+XX2[k]; // add misal vec
//writeln(diagfil, ii,' misvec ',tmat[ii].s[1],tmat[ii].s[2],tmat[ii].s[3],tmat[ii].s[4]);
      TMatKick(XX2, TMat[ii].nord, TMat[ii].kl, TMat[ii].jkick);
//writeln(diagfil, ii,' tmakic ',xx2[1], xx2[2], xx2[3], xx2[4], xx2[5]);
      if UseElAper
        then Lost:= (sqr(XX2[1]/Tmat[ii].apx)+sqr(XX2[3]/Tmat[ii].apy))>1
        else Lost:= (sqr(XX2[1]/aperXglobal) +sqr(XX2[3]/aperYglobal))>1;
//      then Lost:= (Abs(XX2[1])>Tmat[ii].apx) or (Abs(XX2[3])>Tmat[ii].apy)
//      else Lost:= (Abs(XX2[1])>aperXglobal) or (Abs(XX2[3])>aperYglobal);
      XX1:=XX2;
      if ii=High(Tmat) then ii:=-1;
    until (ii=iTMstartPosition) or Lost;
    Inc(iper);
  until (iper=Glob.NPer) or Lost;
//  writeln(diagfil, ' oneturn ',xx2[1], xx2[2], xx2[3], xx2[4], xx2[5]);
  OneTurn:=Lost;
end;

{--------------------------------------------------------------}

function OneTurn_S  (var xx1: Vektor_5): boolean;
// 1.8.2024
// to do: testmode mit misalignments und korrektoren; dazu beamloss auch bei apertureclipping
// von trackDA als testmode aufrufen, nicht nur trackP
// beschraenkung auf s=0 ok
// spaeter erweiterung auf dpp, ggf. drittes fenster fuer echte synch motion

// simple, slow tracking by single elements
// to be used for testing, and for tracking with synchrotron oscillation
// to do: add first/last element and set i in case of cutting

// hier fehlt noch ein Update von Timetracked - wichtig fuer kicker; pathdiff ok nur fuer RF 9/5/19
var
  i, jel: word;
  latmode: shortint;
  iper: integer;
  dpp: real;
begin
  latmode:=do_misal+do_lpath;
  beamLost:=False;
  OptInit;        {nicht noetig? evtl. um overflow trackingmatrix zu vermeiden?}
  for i:=1 to 4 do Orbit1[i]:=xx1[i];
  iper:=0; jel:=0;
  pathdiff:=0.0;
  repeat
    i:=0;
    repeat
      Inc(i);
//      dpp:=xx1[5];
      dpp:=0;
      Lattel(i, jel, latmode, dpp);
    until (i=Glob.NLatt) or BeamLost;
  Inc(iper);
  until (iper=Glob.NPer) or BeamLost;
{//tmp disabled for test
  nphi_sy:=nphi_sy+pathdiff/lambda;
  nphi_sy:=nphi_sy-Round(nphi_sy); //only frac relevant
  dpp:=dpp+dvoltrf[0]*(sin(phisyn+2*Pi*nphi_sy)-sinphisyn);
  for i:=1 to 4 do dpp:=dpp+dvoltrf[i]*sin((i+1)*2*Pi*nphi_sy);}
  for i:=1 to 4 do xx1[i]:=Orbit2[i];
{  BeamLost:=BeamLost or ((dpp > snapsave.rfaccp) or (dpp < snapsave.rfaccm));
  xx1[5]:=dpp;
}
Oneturn_S:=BeamLost;
end;


{--------------------------------------------------------------}

procedure savePStrackData(kturns: integer; x: vektor_5);
begin
  Data1[kturns]:=X[1]; Data2[kturns]:=X[3];
end;

{--------------------------------------------------------------}

Procedure SineWindow (n: Integer);
var i: Integer; Window: real;
begin
  for i:=1 to n do begin
    Window:= Sin(Pi*(i-0.5)/n);
    Data1^[i] := Data1^[i]*Window;
    Data2^[i] := Data2^[i]*Window;
  end;
end;

{-------------------------------------------------------------------------}

Procedure FOUR1 (var data: FFTarrayType; nn,isign: integer);
                                                  {aus "Numerical Recipes" }
var    ii,jj,n,mmax,m,j,istep,i: integer;
       wtemp,wr,wpr,wpi,wi,theta,tempr,tempi,zweipi: real;

begin
  zweipi:=2*pi; n :=nn*2; j:=1;
  for ii:=1 to nn do begin
    i:=2*ii-1;
    if j>i then begin
      tempr:= data[j]; tempi:= data[j+1]; data[j]:= data[i];
      data[j+1]:= data[i+1]; data[i]:=tempr; data[i+1]:= tempi;
    end;
    m := n div 2;
    while (m>=2) and (j>m) do begin
      j:= j-m; m:= m div 2;
    end;
    j:= j+m;
  end;
  mmax:=2;
  while (n>mmax) do begin
    istep:=2*mmax; theta:= zweipi/(isign*mmax);
    wpr:= -2*sqr(sin(0.5*theta)); wpi:= sin(theta); wr:= 1.0; wi:=0.0;
    for ii:= 1 to (mmax div 2) do begin
      m:= 2*ii-1;
      for jj:= 0 to ((n-m) div istep) do begin
        i:= m+jj*istep; j:= i+mmax;
        tempr := wr*data[j]-wi*data[j+1]; tempi := wr*data[j+1]+wi*data[j];
        data[j]:= data[i]-tempr; data[j+1]:= data[i+1]-tempi;
        data[i]:= data[i]+tempr; data[i+1]:= data[i+1]+tempi;
      end;
      wtemp:= wr; wr:= wr*wpr-wi*wpi+wr; wi:= wi*wpr+wtemp*wpi+wi;
    end;
    mmax:= istep;
  end;
end;

{------------------------------------------------------------------------}

Procedure TwoFFT (n:integer);  {from "Numerical Recipes" }

var
  nn3,nn2,nn,jj,j:integer;
  rep, rem, aip, aim: real;

begin
  nn:=n+n; nn2:=nn+2; nn3:=nn+3;
  for j:= 1 to n do begin
    jj:=j+j; FFT1^[jj-1]:=Data1^[j]; FFT1^[jj]:=Data2^[j];
  end;

  FOUR1 (FFT1^,n,1);

  FFT2^[1]:=FFT1^[2]; FFT1^[2]:=0; FFT2^[2]:=0;
  for jj:= 1 to (n div 2) do begin
    j:= 2*jj+1; rep:= 0.5*(FFT1^[j]+FFT1^[nn2-j]);
    rem:= 0.5*(FFT1^[j  ]-FFT1^[nn2-j]);
    aip:= 0.5*(FFT1^[j+1]+FFT1^[nn3-j]);
    aim:= 0.5*(FFT1^[j+1]-FFT1^[nn3-j]);
    FFT1^[j  ]  := rep;
    FFT1^[j+1]  := aim;
    FFT1^[nn2-j]:= rep;
    FFT1^[nn3-j]:=-aim;
    FFT2^[j]    := aip;
    FFT2^[j+1]  :=-rem;
    FFT2^[nn2-j]:= aip;
    FFT2^[nn3-j]:= rem;
  end;
end;

{--------------------------------------------------------------}

Procedure FFTtoAmp (n: Integer);
{  Fouriertransformierte in reelle Amplituden umrechnen}
var
  ymmfak: real;
  k,n2,nh: Integer;
begin
  n2:=2*n; nh:=n div 2;
  ymmfak:=Sqrt(2)*1000/n;
  for k:= 1 to nh-1 do begin
    FT[1,k]  := Sqr(FFT1^[2*k+1   ])+Sqr(FFT1^[2*k+2   ])
              + Sqr(FFT1^[n2+1-2*k])+Sqr(FFT1^[n2+2-2*k]);
    FT[2,k]  := Sqr(FFT2^[2*k+1   ])+Sqr(FFT2^[2*k+2   ])
              + Sqr(FFT2^[n2+1-2*k])+Sqr(FFT2^[n2+2-2*k]);
  end;
  FT[1,0]    := (Sqr(FFT1^[1  ])+Sqr(FFT1^[2  ]));
  FT[1,nH]   := (Sqr(FFT1^[n+1])+Sqr(FFT1^[n+2]));
  FT[2,0]    := (Sqr(FFT2^[1  ])+Sqr(FFT2^[2  ]));
  FT[2,nH]   := (Sqr(FFT2^[n+1])+Sqr(FFT2^[n+2]));

  for k:=0 to nh do begin
    FT[1,k]:=ymmfak*Sqrt(FT[1,k]);
    FT[2,k]:=ymmfak*Sqrt(FT[2,k]);
  end;
end;

{--------------------------------------------------------------}

function getFTmax(n:integer): double;
var
  i, j: integer;
  fmax: double;
begin
  fmax:=0.0;
  for j:=1 to 2 do for i:=0 to n do if (fmax < FT[j,i]) then fmax:=FT[j,i];
  getFTmax:=fmax;
end;
{--------------------------------------------------------------}

function getFT(ixy, i: integer): double;
begin
  getFT:=FT[ixy,i];
end;

{--------------------------------------------------------------}

procedure Getiuio(n,k:Integer; var iu,io: Integer); {J.Bengtsson}
begin
  if k=0 then begin
    iu:=1; io:=iu;
  end
  else begin
    if k=n then begin
      iu:=n-1; io:=iu;
    end
    else begin
      iu:=k-1; io:=k+1;
    end;
  end;
end;

{-------------------------------------------------------------------------}

Procedure FindPeaks (n: Integer; relfilter: double);

var
  ipeak: array[1..2] of array[1..FTkpmaxC] of Integer;
  j,kp,k,iu,io,ksh,ih,nh : Integer;
  a1,a2,nu,peaky : double;
begin
  nh:=n div 2;
  for j:=1 to 2 do begin
    for kp:=1 to FTkpmaxC do begin
      peak[j,kp]:=0;
      ipeak[j,kp]:=0;
    end;
    iu:=0; io:=0;
    for k:=0 to nH do begin
      Getiuio(nH,k,iu,io);
      if (FT[j,k]>FT[j,iu])and(FT[j,k]>FT[j,io]) then begin
        peaky:=FT[j,k];
        for kp:=1 to FTkpmaxC do begin
          if peaky>peak[j,kp] then begin
            for ksh:=FTkpmaxC downto kp+1 do begin
              peak[j,ksh] := peak[j,ksh-1];
              ipeak[j,ksh]:=ipeak[j,ksh-1];
            end;
            peak[j,kp]:=peaky; peaky:=0; ipeak[j,kp]:=k;
          end;
        end;
      end;
    end; {k}
    Npeaks[j]:=FTkpmaxC;
    if peak[j,1]=0 then Npeaks[j]:=0 else begin
      for kp:=FTkpmaxC downto 2 do
        if peak[j,kp] < RelFilter*peak[j,1] then Npeaks[j]:=kp-1;
      for kp:=1 to Npeaks[j] do begin
        k:=ipeak[j,kp];
        Getiuio(nH,k,iu,io);
       if FT[j,io] > FT[j,iu] then begin
          a1:=FT[j,k]; a2:=FT[j,io]; ih:=k;
        end else begin
          a1:=FT[j,iu]; a2:=FT[j,k]; ih:=iu;
          if k=0 then ih:=-1 else ih:=iu;
        end;
        nu:=(ih+2*a2/(a1+a2)-0.5);
        peak[j,kp]:=2*peak[j,kp]/(Sinxx(Pi*(k+0.5-nu))+Sinxx(Pi*(k-0.5-nu)));
        tune[j,kp]:=nu/n;
      end;
      peakmax[j]:=peak[j,1];
    end;
  end;
end;


{-------------------------------------------------------------------------}

Procedure GuessRes (var k1, k2: Integer; j: Integer);
{Versuch der Resonanz-Zuordnung nach Bengtsson, CERN 88-05, p.55}
var
  p1,p2: real;
  Tausch: Boolean;
  ip1, ip2: Integer;
begin
  Tausch:= k1<0;
  if Tausch then begin k1:=-k1; k2:=-k2; end;
  if k2=0 then begin
    if k1>1 then Inc(k1)
    else begin
      k1:=0; k2:=0;
    end;
  end else begin
    if k1>0 then Inc(k1)
    else begin
      p1:=(k1+1)*TuneR[j]+k2*TuneR[3-j];
      p2:=(k1-1)*TuneR[j]+k2*TuneR[3-j];
      ip1:=Round(p1/Glob.NPer)*Glob.NPer;
      ip2:=Round(p2/Glob.NPer)*Glob.NPer;
      if Abs(p1-ip1) < Abs(p2-ip2) then Inc(k1) else Dec(k1);
    end;
  end;
  Tausch:=Tausch xor ((k1<0) and (j=1));
  if Tausch then begin k1:=-k1; k2:=-k2; end;
end;

{-------------------------------------------------------------------------}

Function MakeStr(kx,ky: Integer): String_12;
var
  sx, sy: string;
begin
  if kx=0 then sx:='' else begin
    if kx=1 then sx:=' Qx' else begin
      Str (kx:1,sx); sx:=sx+' Qx';
    end;
  end;
  if ky=0 then if kx=0 then sy:='Offset' else sy:='' else begin
    if Abs(ky)=1 then sy:=' Qy' else begin
      Str (Abs(ky):1,sy); sy:=sy+' Qy';
    end;
    if ky<0 then sy:=' - '+sy else if kx>0 then sy:=' + '+sy;
  end;
  MakeStr:=sx+sy;
end;

{-------------------------------------------------------------------------}

Procedure ResoGuess ( n : Integer; deltune, pident: double );
const
  TolerOff=0.001;
  maxres1=10;
  maxChar=23;
  CharArray: array[0..maxChar] of char
    = ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','P','Q','R','S','T','U','V','W','Z','|');
var
  kp, kx, ky, ind, i, ih, j, isig : Integer;
  ktuner : array[1..2] of integer;
  dmin, TestTune: double;
  Reso: boolean;
begin
  Reso:=True;
// identify fundamental tune
  for j:=1 to 2 do begin
    ih:=1;  {um ggf. hohen Offset nicht als Tune zu identifizieren:}
    if (Tune[j,1]<1/n) and (peak[j,2]>0.1*peak[j,1]) then ih:=2;
    if frac(LinTune[j])<0.5
    then TuneR[j]:=Int(LinTune[j])+  Tune[j,ih]
    else TuneR[j]:=Int(LinTune[j])+1-Tune[j,ih];
    ktuner[j]:=ih;
    if Abs(LinTune[j]-TuneR[j])>deltune then Reso:=False;
  end;

{ Gefundene Peaks Harmonischen und Koppelschwingungen zuordnen :}
  for j:=1 to 2 do for kp:=1 to FTkpmaxC do ResLabel[j,kp]:='  ?  ';
  if Reso then begin
    for j:=1 to 2 do begin
      for kp:=1 to Npeaks[j] do begin
        kpar[j,kp]:=0; kpbr[j,kp]:=0;
      end;
      for kx:=maxres1 downto 0 do begin
        for ky:= maxres1-kx downto 0 do begin
          if (kx=0)and(ky=0) then dmin:=TolerOff
                             else dmin:=pident/(kx+ky);
          for i:=0 to 1 do begin
            isig:=2*i-1;
            TestTune:=kx*TuneR[1]+isig*ky*TuneR[2];
            TestTune:=Frac(TestTune);
            if TestTune<0   then TestTune:=1+TestTune;
            if TestTune>0.5 then TestTune:=1-TestTune;
            for kp:=1 to Npeaks[j] do begin
              if Abs(Tune[j,kp]-TestTune)<dmin then begin
                if (kp=ktuner[j]) then begin
                  if j=1 then begin
                    ResLabel[1,kp]:=MakeStr(1,0);
                    kpar[1,kp]:=1; kpbr[1,kp]:=0;
                  end
                  else begin
                    ResLabel[2,kp]:=MakeStr(0,1);
                    kpar[2,kp]:=0; kpbr[2,kp]:=1;
                  end;
                end else begin
                  ResLabel[j,kp]:=MakeStr(kx,isig*ky);
                  kpar[j,kp]:=kx; kpbr[j,kp]:=ky*isig;
                end;
              end;  {if ...<dmin}
            end;    {kp}
          end;      {i}
        end;        {ky}
      end;          {kx}
    end;            {j}


    {  Die den Harmonischen zugrundeliegenden Resonanzen "raten" : }

    for kp:=1 to Npeaks[1] do GuessRes(kpar[1,kp],kpbr[1,kp],1);
    for kp:=1 to Npeaks[2] do GuessRes(kpbr[2,kp],kpar[2,kp],2);
    for j:=1 to 2 do begin
      for kp:=1 to Npeaks[j] do begin
        if ((kpar[j,kp]<>0) or (kpbr[j,kp]<>0)) and (kp<>ktuner[j]) then begin
          kpcr[j,kp]:= Round((kpar[j,kp]*TuneR[1]+kpbr[j,kp]*TuneR[2])/Glob.NPer)*Glob.NPer;
          Str(kpcr[j,kp]:2,ResLabel[j,kp]);
          ResLabel[j,kp]:=MakeStr(kpar[j,kp],kpbr[j,kp])+' = '+ResLabel[j,kp];
        end;
      end;
    end;

// assign letter to mark peaks in plot and table
    for j:=1 to 2 do begin
      ind:=0;
      for i:=1 to Npeaks[j] do begin
        if i=ktuner[j] then begin
          if j=1 then PeakChar[j,i]:='X' else PeakChar[j,i]:='Y';
          FundaTune[j]:=Tune[j,i]; //save fundamental 100408
        end else if abs(tune[j,i])>TolerOff then begin
          if ind>maxChar then ind:=maxChar;
          PeakChar[j,i]:=CharArray[ind];
          inc(ind);
        end else PeakChar[j,i]:='O';
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------}

Function ResTyp (kx, ky, kc : Integer) :Integer;
{Resonanz-Typ: 0=regular, 1=skew, 2= not superperiodic, 3 both}
var a: Integer;
begin
  a:=0;
  if (kx+ky)>1 then begin
    if Odd(ky) then Inc(a);
    if ( (kc div Glob.NPer)*Glob.NPer <> kc ) and ((kx+ky)>2) then inc(a,2);
  end;
  ResTyp:=a;
end;

{-------------------------------------------------------------------------}

end.

