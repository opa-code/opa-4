unit opabucket;

{$MODE Delphi}
interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  asfigure, asaux, mathlib, globlib, StdCtrls, ExtCtrls, conrect;

type

  { TBucketView }

  TBucketView = class(TForm)
    buteps: TButton;
    fig: TFigure;
    butex: TButton;
    butcon: TButton;
    butmod: TButton;
    p: TPaintBox;
    panVA: TPanel;
    panPar: TPanel;
    labvolt: TLabel;
    labalfa: TLabel;
    labord: TLabel;
    butcopyLat: TButton;
    labdacc: TLabel;
    labsigs: TLabel;
    procedure butepsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure butexClick(Sender: TObject);
    procedure butconClick(Sender: TObject);
    procedure butmodClick(Sender: TObject);
    procedure Ed_KeyPress(Sender: TObject; var Key: Char);
    procedure Ed_Exit(Sender: TObject);
    procedure butcopyLatClick(Sender: TObject);

  private
    procedure MakePlot;
    procedure setmode;
    procedure Layout;
    procedure EdReadAll;
    procedure CalcBucket;

  public
    { Public-Deklarationen }
  end;

var
  BucketView: TBucketView;

implementation

//uses conrect;
const
  nvoal=5;   npara=7;
Var
  CL, CLsep, CLsig: ConLinesArray;
  i: integer;

  nlevco, nhgrid, harm: integer;
  trev, phis, delmax, Hmin, Hmax, circ, erad, ener, circ_f, ener_f, erad_f, alfa_f,
    volt0, daccup, dacclo, sigmas: double;
  volt: array[0..nvoal-1] of double;
  alfa: array[0..nvoal-1] of double;

  phizero, delzero, hphi0, hdel0: array of double;
  sigp0, sigd0: array of integer;
  uselat, copylat, daccfound, sigsfound: boolean;

//using types defined in ConRect
  Ham:  ConMatrix;  // 2D - Datafield
  phi, del, hlev, hpot, hkin:  ConVector;

  ed: array[0..2*nvoal+npara-1] of TEdit;
  labo: array[0..nvoal-1] of TLabel;
  labp: array[0..npara-1] of TLabel;
  edwid, eddec: array[0..2*nvoal+npara-1] of integer;

{$R *.lfm}
procedure TBucketView.FormShow(Sender: TObject);
var
  i: integer;
begin
  for i:=0 to 2*nvoal+4 do begin edwid[i]:=7; eddec[i]:=2; end;
  i:=2*nvoal+3; edwid[i]:=5; eddec[i]:=0;
  i:=2*nvoal+5; edwid[i]:=5; eddec[i]:=0;
  i:=2*nvoal+6; edwid[i]:=5; eddec[i]:=0;

  Layout;

  circ_f  :=FDefGet('buckt/circ');
  ener_f  :=FDefGet('buckt/ener')*1e9;
  erad_f  :=FDefGet('buckt/erad')*1e3;
  alfa_f  :=FDefGet('buckt/alfa')*1e-4;
  harm    :=Round( FDefGet('trackt/harm'));
  volt0   :=FDefGet('trackt/volt')*1E6;
  delmax  :=FDefGet('buckt/dmax');
  nhgrid  :=Round(FDefGet('buckt/nham'));
  nlevco  :=Round(FDefGet('buckt/ncon'));
  for i:=0 to nvoal-1 do volt[i]:=0;
  for i:=0 to nvoal-1 do alfa[i]:=0;
  for i:=1 to nvoal-1 do volt[i]:=FDefGet('buckt/volt'+inttostr(i+1))*1e6;

  for i:=0 to 2*nvoal+4 do ed[i].Text:=FtoS(0.0, edwid[i], eddec[i]);
  ed[0].Text        :=Ftos(volt0/1E6,edwid[0], eddec[0]);
  for i:=1 to nvoal-1 do ed[i].Text:=FtoS(volt[i]/1e6, edwid[i], eddec[i]);

  uselat:=status.Periodic;
  copylat:=false;
  daccfound:=false;
  setmode; // set edit fields nvoal+0,1,2 depending on mode
  i:=2*nvoal+3; ed[i].Text:=FToS(harm,edwid[i],eddec[i]);
  i:=2*nvoal+4; ed[i].Text:=FToS(delmax, edwid[i],eddec[i]);
  i:=2*nvoal+5; ed[i].Text:=FToS(nhgrid, edwid[i],eddec[i]);
  i:=2*nvoal+6; ed[i].Text:=FToS(nlevco, edwid[i],eddec[i]);
  CalcBucket;
  MakePlot;
end;

procedure TBucketView.butepsClick(Sender: TObject);
var
  errmsg, epsfile: string;
begin
  epsfile:=ExtractFileName(FileName);
  epsfile:=work_dir+Copy(epsfile,0,Pos('.',epsfile)-1)+'_bucket.eps';
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




procedure TBucketView.butexClick(Sender: TObject);
begin
  EdReadAll;
  DefSet('trackt/volt', volt0/1e6);
  for i:=1 to nvoal-1 do DefSet('buckt/volt'+inttostr(i+1),volt[i]/1e6);
  DefSet('trackt/harm', harm);
  DefSet('buckt/alfa', alfa_f/1e-4);
  DefSet('buckt/circ', circ_f);
  DefSet('buckt/ener', ener_f/1e9);
  DefSet('buckt/erad', erad_f/1e3);
  DefSet('buckt/dmax', delmax);
  DefSet('buckt/nham', nhgrid);
  DefSet('buckt/ncon', nlevco);
  Close;
end;

procedure TBucketView.FormPaint(Sender: TObject);
begin
  MakePlot;
end;

//not needed, due to paint event handler for figure
procedure TBucketView.butconClick(Sender: TObject);
begin
  CalcBucket;
  MakePlot;
end;

procedure TBucketView.setmode;
var
  j:integer;
begin
  if uselat or CopyLat then begin
    if status.alphas then begin
    // array 0..4 for alphaC def'd in snapsave
      for j:=nvoal to nvoal+4 do
      Ed[j].Text:=Ftos(snapsave.alfaC[j-nvoal]/Beam.Circ/1E-4, edwid[j], eddec[j]);
    end else begin
      j:=nvoal;  Ed[j].Text:=Ftos(Beam.Alfa/1E-4, edwid[j], eddec[j]);
      for j:=nvoal+1 to nvoal+4 do Ed[j].text:=Ftos(0,edwid[j],eddec[j]);
    end;
    j:=2*nvoal; Ed[j].Text:=Ftos(Glob.Energy, edwid[j], eddec[j]);
    Inc(j);   Ed[j].Text:=Ftos(Beam.Circ, edwid[j], eddec[j]);
    Inc(j);   Ed[j].Text:=Ftos(Beam.U0, edwid[j], eddec[j]);
  end else begin
    j:=nvoal; Ed[j].Text:=Ftos(alfa_f/1E-4, edwid[j], eddec[j]);
    j:=2*nvoal; Ed[j].Text:=Ftos(ener_f/1E9, edwid[j], eddec[j]);
    Inc(j);   Ed[j].Text:=Ftos(circ_f,     edwid[j], eddec[j]);
    Inc(j);   Ed[j].Text:=Ftos(erad_f/1e3, edwid[j], eddec[j]);
  end;
  if uselat then butmod.Caption:='Lattice' else butmod.Caption:=' Play ';
  butmod.Enabled:=status.Periodic;
  if uselat then for j:=nvoal to 2*nvoal+2 do begin
    Ed[j].ReadOnly:=true; Ed[j].Color:= clBtnFace;
  end else for j:=nvoal to 2*nvoal+2 do begin
    Ed[j].ReadOnly:=false; Ed[j].Color:= clWhite;
  end;
  butcopyLat.Visible:=butmod.Enabled and (not uselat);
  CopyLat:=False;
end;

procedure TBucketView.butmodClick(Sender: TObject);
begin
  uselat:=not uselat;
  setmode;
  CalcBucket;
  MakePlot;
end;

procedure TBucketView.butcopyLatClick(Sender: TObject);
// copy lattice parameters to play parameters
begin
  CopyLat:=true;
  setmode;
  CalcBucket;
  MakePlot;
end;

procedure TBucketView.Layout;
const
  edwid=75; edhgt=20; owid=25; splin=24;  butwid=50;
  labpcap: array[0..npara-1] of string=('Energy [GeV]','Circumf. [m]', 'Rad.loss [keV]', 'Harmonic', 'dp/p max', 'N.points', 'N.levels');
var
//  edin: TEdit;
  i, y: integer;
begin
  for i:=0 to 2*nvoal+npara-1 do begin
    ed[i]:=TEdit (FindComponent( 'edva_'+IntToStr(i)));
    if ed[i] = nil then begin
      ed[i]:=TEdit.Create(self); ed[i].name:= 'edva_'+IntToStr(i);
      ed[i].Tag:=i;
      ed[i].OnKeyPress:=ed_KeyPress;
      ed[i].OnExit    :=ed_Exit;
      if i<2*nvoal then begin
        ed[i].parent:=panva;
        ed[i].setBounds(owid+5+(i div 5)*(edwid+5), 20+(i mod 5)*splin,edwid,edhgt);
      end else begin
        ed[i].parent:=panpar;
        ed[i].setBounds(edwid+8, 2+(i-2*nvoal)*splin, edwid, edhgt);
      end;
    end;
  end;
  labdacc.setBounds(2,2+npara*splin, 2*edwid, 16);
  labsigs.setBounds(2,2+npara*splin+20, 2*edwid, 16);
  for i:=0 to nvoal-1 do begin
    labo[i]:=TLabel(FindComponent('labo_'+Inttostr(i)));
    if labo[i] = nil then begin
      labo[i]:=TLabel.Create(self); labo[i].name:='labo_'+InttoStr(i);
      labo[i].parent:=panva;
      labo[i].Caption:=inttostr(i+1)+'.';
      labo[i].SetBounds(2,22+i*splin,owid,16);
    end;
  end;
  for i:=0 to npara-1 do begin
    labp[i]:=TLabel(FindComponent('labp_'+Inttostr(i)));
    if labp[i] = nil then begin
      labp[i]:=TLabel.Create(self); labp[i].name:='labp_'+InttoStr(i);
      labp[i].parent:=panpar;
      labp[i].Caption:=labpcap[i];
      labp[i].SetBounds(5,4+i*splin,edwid,16);
    end;
  end;
  labord.SetBounds(2,2,owid,16);
  labvolt.SetBounds(owid+5,2,edwid,16);
  labalfa.SetBounds(owid+10+edwid, 2, edwid,16);
  panva.setBounds(5,2,210,155);
  y:=160;
  butmod.setbounds(12+edwid, y, edwid, 20); butmod.parent:=self;
  butcopylat.setbounds(5, y, edwid, 20); butmod.parent:=self;
  y:=185; panpar.setBounds(5,y,210,210);
  y:=panpar.Top+panpar.height+5;
  butcon.setbounds(5,y,butwid,20);
  buteps.setbounds(12+butwid,y,butwid,20);
  butex.setbounds(19+2*butwid,y,butwid,20);
  fig.assignScreen;
  fig.setsize(220,2,500,420);
  fig.setbounds(220,2,500,420);
  self.Clientwidth:=fig.left+fig.width+5;
  self.Clientheight:=fig.top+fig.height+5;
end;

procedure TBucketView.Ed_KeyPress(Sender: TObject; var Key: Char);
var
  x:real;
  ed: TEdit;
begin
  ed:=Sender as TEdit;
  if TEKeyVal(ed, Key, x, edwid[ed.Tag], eddec[ed.Tag]) then begin
    CalcBucket;
    MakePlot;
  end;
end;

procedure TBucketView.Ed_Exit(Sender: TObject);
var
  x:real;
  ed: TEdit;
begin
  ed:=Sender as TEdit;
  TEReadVal(ed, x, edwid[ed.Tag], eddec[ed.Tag]);
end;


procedure TBucketView.MakePlot;
var
  i, j: integer;
begin
  with fig.Plot do begin
    Clear(clWhite);
    setcolor(clBlack);
    setThick(1);
    fig.Init(-pi, -delmax, pi, delmax, 1,1, 'Phase','dp/p',3,false);
    for i:=0 to High(CL) do with CL[i] do begin
      setcolor(dimcol(clBlue,clRed, ih/nlevco));
      Line(x1,y1,x2,y2);
    end;
    setThick(3);
    setcolor(clTeal);
    for i:=0 to High(CLsep) do with CLsep[i] do begin
      Line(x1,y1,x2,y2);
    end;
    if daccfound then begin
      setcolor(clLime);
      Line(0,dacclo, 0, daccup);
      labdacc.Caption:='Guess dp/p Acc. = [ '+ftos(dacclo*100,6,2)+' , +'+ftos(daccup*100,6,2)+' ] %';
    end else labdacc.Caption:='Guess dp/p Acc. failed.';
    setcolor(clBlack);
    if sigsfound then begin
      labsigs.Caption:='Guess rms bunchlength = '+ftos(sigmas*1000,6,3)+' mm ';
    end else labsigs.Caption:='Guess bunchlength failed';

    for i:=0 to High(phizero) do for j:=0 to High (delzero) do begin
      if sigp0[i]*sigd0[j] > 0 then  setsymbol(3,1,clRed) else setsymbol(3,1,clBlue);
      Symbol(phizero[i],delzero[j]);
    end;
    setThick(1);
    setcolor(clMaroon);
    for i:=0 to High(CLsig) do with CLsig[i] do begin
      Line(x1,y1,x2,y2);
    end;
  end;
end;

procedure TBucketView.EdReadAll;
var
  i, j: integer;   x: real;
begin
  for i:=0 to High(Ed) do begin
    TEREadVal(Ed[i],x,edwid[i], eddec[i]);
    if i<nvoal then volt[i]:=x*1e6
    else if i<2*nvoal then alfa[i-nvoal]:=x*1E-4
    else begin
      j:=i-2*nvoal;
      case j of
        0: ener:=x*1e9; //energy
        1: circ:=x; //circumf.
        2: erad:=x*1e3; //rad.loss
        3: harm:=Round(x); //harmonic
        4: delmax:=x; //dppmax
        5: nhgrid:=round(x); //dppmax
        6: nlevco:=round(x); //dppmax
      end;
    end;
  end;

  if volt[0]<erad then begin
    volt[0]:=erad;
    Ed[0].Text:=FtoS(volt[0]/1e6,edwid[0],eddec[0]);
  end;
  if nlevco<1 then begin
    nlevco:=1;
    Ed[2*nvoal+6].Text:='1';
  end;

  volt0:=volt[0];
  if not uselat then begin
    ener_f:=ener;
    circ_f:=circ;
    erad_f:=erad;
    alfa_f:=alfa[0];
  end;
end;



procedure TBucketView.CalcBucket;
const
  nii=10;
var
  i,j,k, nalfa, nvolt, nphi, ndel, sigh, mindel, minphi, ii: integer;
  tmp, phi0, dddp, del0, dpdd, hk0, hp0, lmin, H00,  phimin, phimax: double;
  seplevel{, hsiglev}: ConVector;  hsiglev: double;
  dhpot, dhkin: array of double;
  hii, phii: array[0..nii] of double;

begin
// plot
  nvolt:=nvoal;  nalfa:=nvoal;
  // --> circ, erad, ener from  lattice
  // --> alfa 0,1,2.... from track/mom or from chroma
  // --> volt 0, harm from/to touschek
  // also get energy accept (min/max of separatrix) and forward to touschek

  EdReadAll;
  nphi:=nhgrid;  ndel:=nhgrid;

  trev:=circ/speed_of_light;
  phis:=ArcSin(erad/volt[0]);
  sigh:=-1 ;//harmonic voltages to be subtracted
  if alfa[0] > 0 then begin
    phis:=PI-phis;
    sigh:=1;
  end;

  setlength(phi,2*nphi);
  for i:=0 to nphi-1 do begin
    tmp:=pi*(i+0.5)/nphi;
    phi[nphi+i]:=tmp; phi[nphi-i-1]:=-tmp;
  end;
  setlength(del,2*ndel);
  for i:=0 to ndel-1 do begin
    tmp:=delmax*(i+0.5)/ndel;
    del[ndel+i]:=tmp; del[ndel-i-1]:=-tmp;
  end;

  nphi:=2*nphi; ndel:=2*ndel;

  setlength(hpot, nphi);
  for i:=0 to nphi-1 do hpot[i]:=volt[0]*(cos(phis+phi[i])+phi[i]*sin(phis));
  for k:=2 to nvolt do for i:=0 to nphi-1 do  hpot[i]:=hpot[i]+sigh*volt[k-1]/k*cos(k*phi[i]);
  for i:=0 to nphi-1 do hpot[i]:=hpot[i]/ener/trev;


  setlength(hkin,ndel);
  for i:=0 to ndel-1 do hkin[i]:=0;
  for k:=1 to nalfa do for i:=0 to ndel-1 do hkin[i]:=hkin[i]+alfa[k-1]*PowI(del[i],(k+1))/(k+1);
  for i:=0 to ndel-1 do hkin[i]:=hkin[i]*2*Pi*harm/trev;

  setlength(ham,nphi);
  For i:=0 to nphi-1 Do Setlength(ham[i],ndel);
  for i:=0 to nphi-1 do for j:=0 to ndel-1 do ham[i,j]:=hkin[j]+hpot[i];

  setlength(hlev,nlevco);
  hmin:=1e16;
  hmax:=-1e16;
  For i:=0 to nphi-1 Do For j:=0 to ndel-1 Do Begin
   if Ham[i,j] < hmin then hmin:=Ham[i,j];
   if Ham[i,j] > hmax then hmax:=Ham[i,j];
  End;

  For i:=0 to nlevco-1 Do hlev[i]:=Hmin+i*(Hmax-Hmin)/(nlevco-1);

  CL:=nil;
  ConRec(Ham, 0, nphi-1, 0, ndel-1, phi , del, nlevco, hlev, CL); // call the contour algorithm

// get derivatives to find fixpoints

  setlength(dhpot, nphi);
  setlength(dhkin, ndel);
  for i:=0 to nphi-1 do dhpot[i]:=volt[0]*(sin(phis+phi[i])-sin(phis));
  for k:=2 to nvolt do for i:=0 to nphi-1 do dhpot[i]:=dhpot[i]+sigh*volt[k-1]*sin(k*phi[i]);
  for i:=0 to ndel-1 do dhkin[i]:=0;
  for k:=1 to nalfa do for i:=0 to ndel-1 do dhkin[i]:=dhkin[i]+alfa[k-1]*PowI(del[i],k);

  phizero:=nil;  sigp0:=nil;  hphi0:=nil;
  delzero:=nil;  sigd0:=nil;  hdel0:=nil;


{ find min/max points of hamiltonian fcts hkin, hpot by checking for zero crossing of  derivatives
 get sign of slopes, because product will dtermine fixpoint characteristics.
 also keep index where phi or del is zero to identify center fixpoint.}
  tmp:=1e10; minphi:=0;
  for i:=1 to nphi-1 do begin
    if dhpot[i]*dhpot[i-1] < 0 then begin
      phi0:=phi[i-1]-(phi[i]-phi[i-1])/(dhpot[i]-dhpot[i-1])*dhpot[i-1];
      dddp:=volt[0]*cos(phis+phi0);
      for k:=2 to nvolt do dddp:=dddp+sigh*k*volt[k-1]*cos(k*phi0);
      setlength(sigp0, Length(sigp0)+1);
      setlength(hphi0, Length(hphi0)+1);
      setlength(phizero, Length(phizero)+1);
      if dddp > 0 then begin
        sigp0[High(sigp0)]:=1;
      end else begin
        sigp0[High(sigp0)]:=-1;
      end;
      hp0:=volt[0]*(cos(phis+phi0)+phi0*sin(phis));
      for k:=2 to nvolt do hp0:=hp0+sigh*volt[k-1]/k*cos(k*phi0);
      hphi0[High(hphi0)]:=hp0/ener/trev;
      phizero[High(phizero)]:=phi0;
      if abs(phi0) < tmp then begin tmp:=abs(phi0); minphi:=High(phizero); end;
    end;
  end;

  tmp:=1e10; mindel:=0;
  for i:=1 to ndel-1 do begin
    if dhkin[i]*dhkin[i-1] < 0 then begin
      del0:=del[i-1]-(del[i]-del[i-1])/(dhkin[i]-dhkin[i-1])*dhkin[i-1];
      dpdd:=0;
      for k:=1 to nalfa do dpdd:=dpdd+alfa[k-1]*PowI(del0,(k-1))*k;
      setlength(sigd0, Length(sigd0)+1);
      setlength(hdel0, Length(hdel0)+1);
      setlength(delzero, Length(delzero)+1);
      if dpdd > 0 then begin
        sigd0[High(sigd0)]:=1;
      end else begin
        sigd0[High(sigd0)]:=-1;
      end;
      hk0:=0.0;
      for k:=1 to nalfa do hk0:=hk0+alfa[k-1]*PowI(del0,(k+1))/(k+1);
      hdel0[High(hdel0)]:=hk0*2*Pi*harm/trev;
      delzero[High(delzero)]:=del0;
      if abs(del0) < tmp then begin tmp:=abs(del0); mindel:=High(delzero); end;
    end;
  end;

{separatrix levels are given by hyperbolic fixpoints}
  daccup:=1e10; dacclo:=-1e10;
  seplevel:=nil;
  for i:=0 to High(phizero) do for j:=0 to High (delzero) do begin
    if sigp0[i]*sigd0[j] > 0 then begin   // hyperbolic?
      setlength(seplevel, Length(seplevel)+1);
      seplevel[High(seplevel)]:=hphi0[i]+hdel0[j];
{check all hyp fix pts near phi=0, they may become the energy acceptance in case of alpha bucket,
 but skip the center fixpoint (mindel).
 Note, check for minphi instead of phizero could be ambigouos if several FPs at phi=0!}
      if abs(phizero[i])<2*Pi/nphi then if j<>mindel then begin
        if delzero[j]<0 then dacclo:=delzero[j];
        if delzero[j]>0 then daccup:=delzero[j];
      end;
    end;
  end;

{sort separatrix levels in ascending order for ConRec to work.
Attention: afterwards ordering does not correspond any longer to delzero etc.!}
  CLsep:=nil;
// --> to do: create proc "simple sort in place" and move to mathlib or asaux
  if length(seplevel)>0 then begin // sort levels
    for j:=0 to High(seplevel)-1 do begin
      lmin:=1e16;
      for i:=j to High(seplevel) do begin
        if seplevel[i] < lmin then begin
          k:=i; lmin:=seplevel[i];
        end;
      end;
      tmp:=seplevel[j]; seplevel[j]:=seplevel[k]; seplevel[k]:=tmp;
    end;
//  for i:=0 to high(seplevel) do writeln(diagfil, i,' seplevel ', seplevel[i]);
    ConRec(Ham, 0, nphi-1, 0, ndel-1, phi , del, Length(seplevel), seplevel, CLsep);
  end;

// guess the energy acceptance, i.e. value of closest separatrix at phi=0
// get Ham at (0,0); no contrbib from kinetic term, only potential
  H00:=volt[0]*cos(phis); for k:=2 to nvolt do H00:=H00+sigh*volt[k-1]/k;
  H00:=H00/ener/trev;

{in case of alpha buckets, the separatrix is only a tangential to hkin and thus may
 not be found when checking for crossing. Therefore, the fixpoints have been tested before.
 (better than adding some "epsilon" in check as-28.1.2018
   HEPS:=abs((Hmax-Hmin)/1000);
}

// find zeros of hkin+H00-seplevel
  for j:=0 to High(SepLevel) do if abs(Seplevel[j]-H00)> 0  then begin
    for i:=1 to ndel-1 do begin
      if (hkin[i]+H00-seplevel[j])*(hkin[i-1]+H00-seplevel[j]) < 0 then begin
        del0:=del[i-1]-(del[i]-del[i-1])/(hkin[i]-hkin[i-1])*(hkin[i-1]+H00-SepLevel[j]);
        if del0>0 then if del0<daccup then daccup:=del0;
        if del0<0 then if del0>dacclo then dacclo:=del0;
      end;
    end;
  end;
  daccfound:=(daccup<100) and (dacclo>-100);

// in case of using Lattice, guess the bunch length, but only if central fixpoint is elliptic,
// otherwise we have overstretched bunches
//  CLsig:=nil;    hsiglev:=nil;
  sigsfound:=false; sigmas:=0;
  if uselat and (sigp0[minphi]*sigd0[mindel]<0) then begin
    //derivatives at origin (phi=delta=0)
    dddp:=volt[0]*cos(phis);
    for k:=2 to nvolt do dddp:=dddp+sigh*k*volt[k-1];
    dddp:=dddp/ener/trev;
    dpdd:=alfa[0]*2*PI*harm/trev;
    tmp:=-dpdd/dddp;
    if tmp>0 then begin
      sigsfound:=true;
      sigmas:=circ/(harm*2*pi)*sqrt(tmp)*Beam.sigmaE;
//      write('bunchlength =', sigmas);
    end;
//    setLength(hsiglev,1);
{    hsiglev:=0;
    for k:=1 to nalfa do hsiglev:=hsiglev+alfa[k-1]*PowI(Beam.sigmaE,(k+1))/(k+1);
    hsiglev:=H00+hsiglev*2*Pi*harm/trev;
// find hphi values which equal amplitude corresponding to energy spread
    phimin:=-1e10; phimax:=1e10;
    for i:=1 to nphi-1 do begin
      if (hpot[i]-hsiglev)*(hpot[i-1]-hsiglev) < 0 then begin
        // use a finer grid for interpolation (not very elegant...)
        for ii:=0 to nii do begin
          phii[ii]:=phi[i-1]+ii*(phi[i]-phi[i-1])/nii;
          hii[ii]:=volt[0]*(cos(phis+phii[ii])+phii[ii]*sin(phis));
          for k:=2 to nvolt do hii[ii]:=hii[ii]+sigh*volt[k-1]/k*cos(k*phii[ii]);
          hii[ii]:=hii[ii]/ener/trev;
        end;
        for ii:=1 to nii do begin
          if (hii[ii]-hsiglev)*(hii[ii-1]-hsiglev) < 0 then begin
             phi0:=phii[ii-1]-(phii[ii]-phii[ii-1])/(hii[ii]-hii[ii-1])*(hii[ii-1]-hsiglev);
//old        phi0:=phi[i-1]-(phi[i]-phi[i-1])/(hpot[i]-hpot[i-1])*(hpot[i-1]-hsiglev);
            if phi0>0 then if phi0<phimax then phimax:=phi0;
            if phi0<0 then if phi0>phimin then phimin:=phi0;
          end;
        end;
      end;
    end;
    sigsfound:=(phimin > -Pi) and (phimax < Pi);
    sigmas:=(phimax-phimin)/4/Pi*Circ/harm;
//    ConRec(Ham, 0, nphi-1, 0, ndel-1, phi , del, 1, hsiglev, CLsig);//too small to be visible
}
  end;

  status.rfaccept:=daccfound and sigsfound; // to be used in touschek

  if status.rfaccept then begin
    SetStatusLabel(stlab_rfm,status_flag);
    snapsave.rfaccm:=dacclo; snapsave.rfaccp:=daccup; snapsave.sigmas:=sigmas;
    for i:=0 to 4 do snapsave.voltRF[i]:=volt[i];
    snapsave.lambdaRF:=Circ/harm;
  end else SetStatusLabel(stlab_rfm,status_void);
end;

end.
