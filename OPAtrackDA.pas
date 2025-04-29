{
jan 2021
neu: zeige immer silhouette physikalischer apertur, ax/ay Eingabe nur fuer range
to do:
- initialisierung noch nicht korrekt in xp mode
}


{
naechste schritte
- betas im plot notieren
- warum kein orbit gefunden fuer dp=0 und alpha<>0 in acc_dpp ?
- (warum kleiner unterschied zwischen xy(dp) und x(dp), y(dp)? shceint ok, aber check)
- parameter serien machen
ok - acceptance check: warum manchmal zu klein in track obwohl linear lattice?
   --> tracklib/appendmat: muss zentral regeln ob elem aper ueberschrieben werden.
- pruefen ob spos doch moeglich ist und ggf. aktivieren.
}


unit OPAtrackDA;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ASfigure, OPAglobal, ASaux, mathlib, tracklib, Math, Vgraph, StdCtrls, ComCtrls,
  ExtCtrls; //!, generics.Collections;

type

  { TtrackDA }

  TtrackDA = class(TForm)
    butexit: TButton;
    butplotstyle: TButton;
    fig: TFigure;
    butstart: TButton;
    labplotstyle: TLabel;
    p: TPaintBox;
    rbxx: TRadioButton;
    rbmethflo: TRadioButton;
    rbmethgrd: TRadioButton;
    rbmethbin: TRadioButton;
    rgmeth: TRadioGroup;
    rbxp: TRadioButton;
    rbxy: TRadioButton;
    rbyp: TRadioButton;
    rgmode: TRadioGroup;
    eddpp: TEdit;
    labdpp: TLabel;
    edspos: TEdit;
    Labspos: TLabel;
    edturns: TEdit;
    Labturns: TLabel;
    edax: TEdit;
    Labax: TLabel;
    eday: TEdit;
    Labay: TLabel;
    cbxaper: TCheckBox;
    butexport: TButton;
    Pangrid: TPanel;
    PanNray: TPanel;
    LabNy: TLabel;
    butng1m: TButton;
    Labng2: TLabel;
    butng1p: TButton;
    butng2m: TButton;
    LabNg1: TLabel;
    butng2p: TButton;
    LabNrays: TLabel;
    butnrm: TButton;
    Labnr: TLabel;
    butnrp: TButton;
    LabReso: TLabel;
    EdReso: TEdit;
    LabNx: TLabel;
    LabNray: TLabel;
    LabGrid: TLabel;
    procedure butexitClick(Sender: TObject);
    procedure butplotstyleClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure rbClick(Sender: TObject);
    procedure butNgClick(Sender: TObject);
    procedure eddppKeyPress(Sender: TObject; var Key: Char);
    procedure eddppExit(Sender: TObject);
    procedure edturnsKeyPress(Sender: TObject; var Key: Char);
    procedure edturnsExit(Sender: TObject);
    procedure edsposKeyPress(Sender: TObject; var Key: Char);
    procedure edsposExit(Sender: TObject);
    procedure EdResoKeyPress(Sender: TObject; var Key: Char);
    procedure EdResoExit(Sender: TObject);
    procedure cbxaperClick(Sender: TObject);
    procedure edaxKeyPress(Sender: TObject; var Key: Char);
    procedure edayKeyPress(Sender: TObject; var Key: Char);
    procedure edaxExit(Sender: TObject);
    procedure edayExit(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure butnrClick(Sender: TObject);
    procedure butstartClick(Sender: TObject);
    procedure butexportClick(Sender: TObject);
    procedure figpPaint(Sender: TObject);
  private
    dpprange, dppoffset,relreso, aper_X, aper_Y, startpos, GeoAccX, GeoAccY: real;
    ngeodpp, nturns, nnr, nrays, ngrx, ngridx, ngry, ngridy, ngrp, ngrs, ngrang, ngridp, ngrids, da_mode, da_meth, plotstyle: integer;
    my_width, my_height, labg_width: integer;
    gda1, gda2, gamin1, gamin2, gxmin, gxmax, gwmin, gwmax, gymax, gpmin, gpmax, dpp_lastused: real;
    gn1, gn2: integer; //grid dimensions
    TrackDone, TrackBreak : boolean;
    MonitorXXP:integer;
    TotalTurns: Int64;
    procedure rbsetfields;
    procedure eddppAction(kv: real);
    procedure edsposAction(kv: real);
    procedure UpdateGridParams;
    procedure Silhouette;
    procedure UpdateApertures;
    procedure Exit;
    procedure SaveDefaults;
    procedure ResizeAll;
    procedure MakePlot;
    function findIgri(i1: integer; i2: integer): integer;
    procedure DARaySetup;
    procedure DAGridSetup;
    function InitialVektor(vko1: real; vko2: real; dpp: real; ko1: integer; ko2: integer): Vektor_5;
    function DASingleTracking(t1, t2: real; dpp: real; ko1: integer; ko2: integer): integer;
    procedure DATrackingClassicGrid(dpp: real; ko1: integer; ko2: integer);
    procedure DATrackingBinRays    (dpp: real; ko1: integer; ko2: integer);
    function PixelIsUnstable(i1: integer; i2: integer; dpp: real; ko1: integer; ko2: integer): bool;
    procedure DATrackingFillToolGrid(i1start: integer; i2start: integer; dpp: real; ko1: integer; ko2: integer);
    procedure DATracking;
    procedure FloPinit;
    procedure FloPoly (isl: integer);
  public
    procedure Start;
  end;

var
  trackDA: TtrackDA;

implementation

{$R *.lfm}

const
  min_width=600;
  min_height=200;
  ngr_min=1; ngr_max=10;
  nr_min=1; nr_max=8;
  edwid=6; eddec=2;
  nka=40;    //points for silhouette
  ngeodpp0=17; //default points for dpp dependent aperture, fix to show orbit and apertures

type
  dagrid_type = record
    a1, a2: real;
    loss: integer;
    igord: integer; // index in dagord
  end;
  dagord_type = integer;

  darays_type = record //bin search ray
    u1, u2, v1, v2, ur, vr: real; //ini, fin, result
  end;

var
  dagrid: array of dagrid_type;
  dagord: array of dagord_type;
  darays: array of darays_type;
  axk, ayk: array[0..nka] of real;

//!  p_vals: TList<real>;        // compute, store and reuse..
//!  p_opvals: TList<OpvalType>; // ..dpp-dependent opvals on demand

// public --------------------------------------

procedure TtrackDA.Start;
begin
  fig.assignScreen;
// restore defaults
  dpprange:=FDefGet('trackd/dppr');
  nturns  :=IDefGet('trackd/ntur');
  nnr     :=IDefGet('trackd/nray');
  if nnr<nr_min then nnr:=nr_min; if nnr>nr_max then nnr:=nr_max;
  nrays:=Round(Power(2,nnr)+1);
  relreso :=FDefGet('trackd/reso');
  aper_X  :=FDefGet('trackp/aperx');
  aper_Y  :=FDefGet('trackp/apery');
  ngrx    :=IDefGet('trackd/ngrx');
  ngry    :=IDefGet('trackd/ngry');
  ngrp    :=IDefGet('trackd/ngrp');
  ngrs    :=IDefGet('trackd/ngrs');
  da_mode :=IDefGet('trackd/dmode');
  da_meth :=IDefGet('trackd/dmeth');
  //always in grid mode, ray mode not yet defined, flood meth 3 only applies to da_mode 0
  my_width :=IDefGet('trackd/wid');
  my_height:=IDefGet('trackd/hgt');
  plotstyle:=IDefGet('trackd/psty');

  ngrang :=36; //angles for xx'p

  rbmethflo.Enabled:=(da_mode=0);
  if (da_mode in [1,2]) and (da_meth=3) then da_meth:=2;

  TrackDone:=False;
  MonitorXXP:=-1;
  status.FloPoly:=false;


  // select mode and method of tracking; fill the GUI with params
  // click event launched by setting rb.. checked sets dp/p related things
//  opamessage(0,'da mode ='+inttostr(da_mode));
  case da_mode of
    1: rbxp.Checked:=true; 2: rbyp.Checked:=true; 3: rbxx.Checked:=true; else rbxy.Checked:=true;
  end;
  case da_meth of
    1: begin
      PanNray.Visible:=True; PanGrid.Visible:=false;
      rbmethbin.Checked:=true;
    end;
    2, 3: begin
      PanNray.Visible:=False; PanGrid.Visible:=true;
      if da_meth=3 then rbmethflo.Checked:=true else rbmethgrd.Checked:=true;
    end;
  end;
  UpdateGridParams;

  if da_mode=3 then ngeodpp:=ngrids else ngeodpp:=ngeodpp0;

  eddpp.Text:=Ftos(0,edwid, eddec);
  edax.text:=ftos(Aper_X, edwid, eddec);
  eday.text:=ftos(Aper_Y, edwid, eddec);
  edax.enabled:=not cbxaper.Checked;
  eday.enabled:=not cbxaper.Checked;
  edturns.text:=ftos(nturns, edwid,0);
  edspos.text:=ftos( StartPos, edwid, eddec);
  edreso.text:=ftos(relreso,-2, eddec);
  LabNr.caption:=InttoStr(nrays);
  LabNr.Width:=labg_width;
  if plotstyle=0 then labplotstyle.caption:='simple' else labplotstyle.caption:='rich';

  rbsetfields;

  // set initial width and height of form
  if my_width < min_width then my_width:=min_width;
  if my_width > Screen.Width then my_width:=Screen.Width-10;
  if my_height < min_height then my_height:=min_height;
  if my_height > Screen.Height then my_height:=Screen.Height-10;
  SetBounds(left, top, my_width,my_height);



  // initialize tracking
  dpp_lastused:=-1;
  dppoffset:=0.0;
  Startpos :=0.0;
  TrackInit;

  Acc_dpp (dpprange, aper_x, aper_y, ngeodpp, cbxaper.checked);

  Initdpp(dppoffset, GeoAccX, GeoAccY, Aper_X, Aper_Y, startPos, cbxaper.Checked, true);

end;

// event handlers ------------------------------

procedure TtrackDA.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TrackExit;
  dagrid:=nil;
  dagord:=nil;
  TrackDA:=nil;
end;

procedure TtrackDA.butexitClick(Sender: TObject);
begin
  Exit;
end;

procedure TtrackDA.butplotstyleClick(Sender: TObject);
begin
  if plotstyle=1 then plotstyle:=0 else plotstyle:=1;
  if plotstyle=0 then labplotstyle.caption:='simple' else labplotstyle.caption:='rich';
  MakePlot;
end;


procedure TtrackDA.FormPaint(Sender: TObject);
begin
//  MakePlot;
end;

procedure TtrackDA.FormResize(Sender: TObject);
begin
  ResizeAll;
end;

procedure TtrackDA.rbsetfields;
begin
  LabNx.caption:='Cells horizontal';
  LabNy.caption:='Cells vertical';
  if da_mode=0 then begin
    Labdpp.caption:='dp/p offset [%]';
    eddpp.Text:=Ftos(dppoffset*100,edwid, eddec);
  end else begin
    Labdpp.caption:='dp/p range  [%]';
    eddpp.Text:=Ftos(dpprange*100,edwid, eddec);
    case da_mode of
      1: LabNy.caption:='Cells dp/p';
      2: LabNx.caption:='Cells dp/p';
      3: LabNy.caption:='Slices dp/p';
    end;
  end;
end;

procedure TtrackDA.rbClick(Sender: TObject);
var
  rb:TRadioButton;
begin
  rb:=Sender as TRadioButton;
  if rb.Tag < 10 then begin //rgroup mode tag 0,1,2,3
    da_mode:=rb.Tag;
    rbsetfields;
    rbmethflo.Enabled:=(da_mode in [0,3]);
    if (da_mode in [1,2]) and (da_meth=3) then begin
      da_meth:=1; rbmethbin.Checked:=true;
    end;
    if (da_mode=3) and (da_meth<3) then begin
      da_meth:=3; rbmethflo.Checked:=true;
    end;
  end else begin //rgroup meth tag 11,12,13
    da_meth:=rb.Tag-10;
    if da_meth=1 then begin
      PanNray.Visible:=true; PanGrid.Visible:=false;
    end else begin
      PanNray.Visible:=false; PanGrid.Visible:=true;
    end;
  end;
  UpDateGridParams;
  if da_mode=3 then ngeodpp:=ngrids else ngeodpp:=ngeodpp0;
  UpdateApertures;
end;

procedure TtrackDA.butnrClick(Sender: TObject);
var
  but: TButton;
begin
  but:=Sender as TButton;
  if but.Tag =1 then Inc(nnr) else Dec(nnr);
  if nnr<nr_min then nnr:=nr_min;  if nnr>nr_max then nnr:=nr_max;
  nrays:=Round(Power(2,nnr)+1);
  LabNr.caption:=InttoStr(nrays);
  LabNr.Width:=labg_width;
  //Acc_dpp (dpprange, aper_x, aper_y, ngeodpp, cbxaper.checked);
  TrackDone:=false;
  MakePlot;
end;

procedure TtrackDA.butNgClick(Sender: TObject);
var
  but: TButton;
  n1, n2, n: integer;
begin
  case da_mode of
    1:   begin n1:=ngrx; n2:=ngrp; end;
    2:   begin n1:=ngrp; n2:=ngry; end;
    3:   begin n1:=ngrx; n2:=ngrs; end; //xx' mode
    else begin n1:=ngrx; n2:=ngry; end;
  end;
  but:=Sender as TButton;
  if but.Tag <2 then n:=n1 else n:=n2;
  if (but.Tag mod 2) =0 then Dec(n) else Inc(n);
  if but.Tag <2 then n1:=n else n2:=n;
  case da_mode of
    1:   begin ngrx:=n1; ngrp:=n2; end;
    2:   begin ngrp:=n1; ngry:=n2; end;
    3:   begin ngrx:=n1; ngrs:=n2; end;
    else begin ngrx:=n1; ngry:=n2; end;
  end;
  UpdateGridParams;
  if da_mode=3 then if ngrids<>ngeodpp then begin
    ngeodpp:=ngrids;
    Acc_dpp(dpprange, Aper_X, Aper_Y, ngeodpp, cbxaper.checked);
  end;

  MakePlot;
end;

procedure TtrackDA.eddppKeyPress(Sender: TObject; var Key: Char);
var  kv: real;
begin
  if TEKeyVal(eddpp, Key, kv, edwid, eddec) then eddppAction(kv);
end;

procedure TtrackDA.eddppExit(Sender: TObject);
var  kv: real;
begin
  if TEReadVal(eddpp, kv, edwid, eddec) then eddppAction(kv);
end;

procedure TtrackDA.edturnsKeyPress(Sender: TObject; var Key: Char);
var  kv: real;
begin
  if TEKeyVal(edturns, Key, kv, 6, 0) then begin
    nturns:=Round(kv);
    TrackDone:=False;
  end;
end;

procedure TtrackDA.edturnsExit(Sender: TObject);
begin
  edturns.Text:=Ftos(nturns, 6, 0);
end;

procedure TtrackDA.edsposKeyPress(Sender: TObject; var Key: Char);
var  kv: real;
begin
  if TEKeyVal(edspos, Key, kv, edwid, eddec) then edsposAction(kv);
end;

procedure TtrackDA.edsposExit(Sender: TObject);
var  kv: real;
begin
  if TEReadVal(edspos, kv, edwid, eddec) then edsposAction(kv);
end;

procedure TtrackDA.EdResoKeyPress(Sender: TObject; var Key: Char);
var  kv: real;
begin
  if TEKeyVal(edreso, Key, kv, -2, eddec) then relreso:=kv;
  TrackDone:=false;
end;

procedure TtrackDA.EdResoExit(Sender: TObject);
begin
  edreso.text:=Ftos(relreso,-2,eddec);
end;

procedure TtrackDA.cbxaperClick(Sender: TObject);
begin
  if cbxaper.checked then begin
    edax.Enabled:=false; eday.Enabled:=false;
  end else begin
    edax.Enabled:=true;  eday.Enabled:=true;
    TEReadVal(edax,Aper_X, edwid, eddec); TEReadVal(eday,Aper_Y, edwid, eddec);
  end;
  UpdateApertures;
end;

procedure TtrackDA.edaxKeyPress(Sender: TObject; var Key: Char);
var  kv: real;
begin
  if TEKeyVal(edax, Key, kv, edwid, eddec) then begin
    aper_X:=kv;
    UpDateApertures;
  end;
end;

procedure TtrackDA.edayKeyPress(Sender: TObject; var Key: Char);
var  kv: real;
begin
  if TEKeyVal(eday, Key, kv, edwid, eddec) then begin
    aper_Y:=kv;
    UpDateApertures;
  end;
end;

procedure TtrackDA.edaxExit(Sender: TObject);
begin
  edax.text:=Ftos(aper_X,edwid,eddec);
end;

procedure TtrackDA.edayExit(Sender: TObject);
begin
  eday.text:=Ftos(aper_Y,edwid,eddec);
end;

procedure TtrackDA.butstartClick(Sender: TObject);
begin
  if butstart.Tag=0 then begin
    DATracking;
  end else begin
    TrackBreak:=true;
  end;
end;

procedure TtrackDA.butexportClick(Sender: TObject);
const mfmode: array[0..3] of string_2 =('xy','xp','py','ft');
var
  errmsg, epsfile: string;
begin
  epsfile:=ExtractFileName(FileName);
  epsfile:=work_dir+Copy(epsfile,0,Pos('.',epsfile)-1);
  epsfile:=epsfile+'_da_'+mfmode[da_mode]+'.eps';
  fig.plot.PS_start(epsfile,OPAversion, errmsg);
  if length(errmsg)>0 then begin
    MessageDlg('PS export failed: '+errmsg, MtError, [mbOK],0);
  end else begin
    MakePlot;
    fig.plot.PS_stop;
    MessageDlg('Graphics exported to '+epsfile, MtInformation, [mbOK],0);
    if da_mode=3 then MonitorXXP:=-2; //not elegant, suppress geoaper plot after export
    MakePlot;
  end;
end;
// procs which are directly used by the event handlers ----------

procedure TtrackDA.UpDateGridParams;
begin
  if ngrx<ngr_min then ngrx:=ngr_min;  if ngrx>ngr_max then ngrx:=ngr_max;
  if ngry<ngr_min then ngry:=ngr_min;  if ngry>ngr_max then ngry:=ngr_max;
  if ngrp<ngr_min then ngrp:=ngr_min;  if ngrp>ngr_max then ngrp:=ngr_max;
  ngridx:=Round(Power(2,ngrx)+1);
  ngridy:=Round(Power(2,ngry)+1);
  ngridp:=Round(Power(2,ngrp)+1);
  ngrids:=Round(Power(2,ngrs)+1);
  case da_mode of
    1: begin
      LabNg1.caption:=InttoStr(ngridx);
      LabNg2.caption:=InttoStr(ngridp);
    end;
    2: begin
      LabNg1.caption:=InttoStr(ngridp);
      LabNg2.caption:=InttoStr(ngridy);
    end;
    3: begin
      LabNg1.caption:=InttoStr(ngridx);
      LabNg2.caption:=InttoStr(ngrids);
    end;
    else begin
      LabNg1.caption:=InttoStr(ngridx);
      LabNg2.caption:=InttoStr(ngridy);
    end;
  end;
  LabNg1.Width:=labg_width;
  LabNg2.Width:=labg_width;
  TrackDone:=false;
end;

procedure TtrackDA.eddppAction(kv: real);
begin
  if da_mode =0 then begin
    dppoffset:=kv/100.0;
    if Initdpp(dppoffset, GeoAccX, GeoAccY, Aper_X, Aper_Y, startPos, cbxaper.Checked, true)
    then begin MessageDlg(('Closed orbit or periodic solution not found.'+
        'Momentum deviation of dp/p ='+ftos(kv,edwid,eddec)+' % is too large.  '+
        'Reset to dpp=0'),
         mtWarning, [mbOK],0);
      setfocus;
      dppoffset:=0;
      Initdpp(dppoffset, GeoAccX, GeoAccY, Aper_X, Aper_Y, startPos, cbxaper.Checked, true);
      eddpp.text:=ftos(100*dppoffset,edwid,eddec);
    end else begin
      Silhouette;
    end;
  end else begin
    dpprange:=kv/100.0;
    Acc_dpp (dpprange, aper_x, aper_y, ngeodpp, cbxaper.checked);
  end;
  TrackDone:=false;
  MakePlot;
end;

procedure TtrackDA.edsposAction(kv: real);
begin
  if kv<0 then kv:=0.0;
  if kv>Beam.Circ/Glob.NPer then kv:=Beam.Circ/Glob.NPer;
  startPos:=kv;
  edspos.text:=FtoS(startPos,8,3);
  if da_mode=0 then begin
    Initdpp(dppoffset, GeoAccX, GeoAccY, Aper_X, Aper_Y, startPos, cbxaper.checked, true);
  end else begin // get local betas

  end;
  TrackDone:=false;
  MakePlot;
end;

procedure TtrackDA.Silhouette;
var
  ika: integer;
  ka, amp, pka, spka2, cpka2: real;
begin
  // calc Silhouette: intersection of projected apertures to trackpoint
  for ika:=0 to nka do begin
// translate azimual angle pka in x-y plane to betatron coupling ka
    pka:=ika*Pi/2/nka; spka2:=sqr(sin(pka)); cpka2:=sqr(cos(pka));
    if GeoAccX > 0 then ka:=GeoAccY*spka2/(GeoAccY*spka2+Opstart.betb/Opstart.beta*GeoAccX*cpka2) else ka:=0;
//    amp:=AmpKappa(ka, Aper_X, Aper_Y, dppoffset, cbxaper.Checked);
    amp:=AmpKappa(ka, Aper_X, Aper_Y, dppoffset, true);
// contour point of geometric acceptance polygon relative to orbit (--> makeplot)
    axk[ika]:=1000*sqrt(amp*(1-ka)*Opstart.beta);
    ayk[ika]:=1000*sqrt(amp*ka*Opstart.betb);
// writeln(diagfil, 'pka, kappa, amp, ax, ay :', ika,' ',pka*180/Pi, ka, amp, axk[ika], ayk[ika]);
  end;
end;

procedure TtrackDA.UpdateApertures;
var
  dpp: real;
begin
//writeln('update aper aperx,y =', aper_x, aper_y);
  edax.Text:=FtoS(aper_X, edwid, eddec);
  eday.Text:=FtoS(aper_Y, edwid, eddec);
//  Acceptances(GeoAccX, GeoAccY, aper_X, aper_Y, dppoffset, cbxaper.checked);
  if da_mode=0 then begin
    Initdpp(dppoffset, GeoAccX, GeoAccY, Aper_X, Aper_Y, startPos, cbxaper.Checked, true);
    Silhouette;
  end else begin
    dpp:=0.0;
    Initdpp(dpp, GeoAccX, GeoAccY, Aper_X, Aper_Y, startPos, cbxaper.Checked, true);
    Acc_dpp(dpprange, Aper_X, Aper_Y, ngeodpp, cbxaper.checked);
  end;
  TrackDone:=false;
  MakePlot;
end;



// private --------------------------------------

procedure TtrackDA.Exit;
begin
  SaveDefaults;
  Close;
  TrackDA:=nil;
end;

procedure TtrackDA.SaveDefaults;
// save the default values that may have been changed
begin
  DefSet('trackd/dppr' , dpprange);
  DefSet('trackd/ntur' , nturns);
  DefSet('trackd/nray' , nnr);
  DefSet('trackd/reso' , relreso);
  DefSet('trackp/aperx', aper_X);
  DefSet('trackp/apery', aper_Y);
  DefSet('trackd/ngrx' , ngrx);
  DefSet('trackd/ngry' , ngry);
  DefSet('trackd/ngrp' , ngrp);
  DefSet('trackd/ngrs' , ngrs);
  DefSet('trackd/dmode', da_mode);
  DefSet('trackd/dmeth', da_meth);
  DefSet('trackd/wid'  , my_width);
  DefSet('trackd/hgt'  , my_height);
  DefSet('trackd/psty' , plotstyle);
end;

procedure TtrackDA.ResizeAll;
const
  dymin=2;
  buth=25; bpm=17;
  eh=21; lh=15;
  dx=8;
var
  dy, butw, htot, x, y, cwid, colwid, figw, figh, c4: integer;
begin
  if (width<min_width) then width:=min_width;
  if (height<min_height) then height:=min_height;
  if (width>screen.width) then width:=screen.width;

  htot:=3*buth+8*eh+13*dymin;
  if (clientheight<htot) then clientheight:=htot;
  if (height>screen.height) then height:=screen.height;

  if ((left+width)>screen.width) then left:=screen.width-width;
  if ((top+height)>screen.height) then top:=screen.height-height;

  dy:=dymin+(clientheight-htot) div 14;
  cwid:=rgmode.width;
//  cwid:=rbxy.Width+rbxp.Width+rbyp.Width+4*dx;
//  rgmode.setBounds(dx,dy,cwid,2*buth);
// no auto scale of rgmode, since it auto adjusts its content
   rgmode.left:=dx;
   rgmode.top :=dy;
//  rbxy.Left:=2*dx;
//  rbxp.Left:=3*dx+rbxy.Width;
//  rbyp.Left:=dx+rbxp.Left+rbxp.Width;
//y:=dy+rgmode.Height div 3;
  y:=dymin;
  rbxy.Top:=y; rbxp.Top:=y; rbyp.Top:=y;
  y:=dy+rgmode.Height;
  rgmeth.setbounds(dx,y,cwid,rgmode.Height);
  y:=y+dy+rgmode.Height;
  x:=2*dx;
  colwid:=round(0.45*cwid);
  Labdpp.setbounds(x,y+2,colwid,lh);
  Eddpp.setbounds(x+colwid,y,colwid,eh);
  Inc(y,eh+dy);
  LabTurns.setbounds(x,y+2,colwid,lh);
  EdTurns.setbounds(x+colwid,y,colwid,eh);
  Inc(y,eh+dy);
  LabSpos.setbounds(x,y+2,colwid,lh);
  EdSpos.setbounds(x+colwid,y,colwid,eh);
  Inc(y,eh+dy);
  PanGrid.setbounds(dx,y,cwid,3*eh+4*dy);
  PanNray.setbounds(dx,y,cwid,3*eh+4*dy);
  x:=dx;
  y:=dy;
  LabNray.setBounds(x,y+2,cwid-2*dx,lh);
  LabGrid.setBounds(x,y+2,cwid-2*dx,lh);
  Inc(y,dy+eh);
  labg_width:=colwid-2*bpm-10;
  LabNrays.setBounds(x,y+2,colwid,lh);
  LabNr.setBounds (x+colwid+bpm+5,y+1,labg_width,lh);
  Butnrm.setBounds(x+colwid,y,bpm,bpm);
  Butnrp.setBounds(x+colwid+labg_width+bpm+10,y,bpm,bpm);
  LabNx.setBounds(x,y+2,colwid,lh);
  LabNg1.setBounds (x+colwid+bpm+5,y+1,labg_width,lh);
  Butng1m.setBounds(x+colwid,y,bpm,bpm);
  Butng1p.setBounds(x+colwid+labg_width+bpm+10,y,bpm,bpm);
  Inc(y,dy+eh);
  LabReso.setBounds(x,y+2,colwid,lh);
  EdReso.setBounds(x+colwid,y,colwid,eh);
  LabNy.setBounds(x,y+2,colwid,lh);
  LabNg2.setBounds (x+colwid+bpm+5,y+1,labg_width,lh);
  Butng2m.setBounds(x+colwid,y,bpm,bpm);
  Butng2p.setBounds(x+colwid+labg_width+bpm+10,y,bpm,bpm);
  y:=PanGrid.Top+PanGrid.Height+dy;
  x:=2*dx;
  c4:=cwid div 4;
  cbxaper.SetBounds(x,y,2*c4,eh);
  labax.setbounds(x+2*c4,y, c4, lh);
  edax.setbounds(dx+ 3*c4, y, c4, eh);
  Inc(y,dy+eh);
  labay.setbounds(x+2*c4,y, c4, lh);
  eday.setbounds(dx+ 3*c4, y, c4, eh);

  butplotstyle.SetBounds(x,y,c4-2,eh);
  labplotstyle.SetBounds(x+c4+2,y+2,c4,eh);

  Inc(y,dy+eh);
  x:=dx;
  butw:=(cwid-2*dx) div 3;
  butstart.setbounds(x,y,butw, buth);
  butexport.setbounds(x+(cwid-butw) div 2,y,butw, buth);
  butexit.setbounds(x+cwid-butw, y, butw, buth);
  Inc(y,dy+buth);
  figw:=clientwidth-cwid-3*dx;
  figh:=clientheight-2*dy;
  fig.setsize(cwid+2*dx, dy, figw, figh);
  my_width :=Width;
  my_Height:=Height;
//  MakePlot;
end;

procedure TtrackDA.MakePlot;
// proc to get phys acc: ellipse for mode 0, table+curves off mom acc for 1,2
const
  geofac=1.2;
var
  {xmin, xmax,} yrange, xrange, wrange, xorb, worb: real;

  procedure ShowGeoAper;
{  const
    nang=50;
}
  var
    i: integer;
    st1, st2, o1, o2, a1, a2, p1, p2 {, ang, x1, x2, y1, y2}: real;
    elcol: Tcolor;

  begin
    fig.plot.SetColor(clBlue);
    fig.plot.SetSymbol(2,2,clBlue);
    case da_mode of
      0:begin
        with fig.plot do begin
{          rectangle(xmin,0,xmax,ymax);
          moveto(xmin,0);
          for i:=1 to nang do begin
            ang:=i*Pi/nang;
            lineto(xorb-xrange*Cos(ang), ymax*Sin(ang));
          end;
}
          moveto(xorb+axk[0], ayk[0]);
          for i:=1     to   nka do lineto(xorb+axk[i],ayk[i]);
          for i:=nka-1 downto 0 do lineto(xorb-axk[i],ayk[i]);
          stroke;
{
          for i:=1 to nrays-1 do begin
            ang:=i*Pi/(nrays-1); x2:=xorb+xrange*cos(ang); y2:=ymax*sin(ang);
            Line(x1, y1, x2, y2); Symbol(x2, y2);
            x1:=x2; y1:=y2;
          end;
}
        end;
      end;
      1:begin
        with geodpp[0] do begin o1:=xorb*1000; a1:=sqrt(xamp*beta)*1000; p1:=100*dpp; st1:=perstat; end;
        if st1<1 then with fig.plot do begin Symbol(o1,p1); Symbol(o1-a1,p1); Symbol(o1+a1,p1); end;
        for i:=1 to ngeodpp-1 do begin
          with geodpp[i] do begin o2:=xorb*1000; a2:=sqrt(xamp*beta)*1000; p2:=100*dpp; st2:=perstat; end;
          with fig.plot do begin
            if st2<2 then begin
              Symbol(o2,p2); Symbol(o2-a2,p2); Symbol(o2+a2,p2);
              if  st1<2 then begin
                Line(o1,p1,o2 ,p2); Line(o1-a1,p1,o2-a2,p2); Line(o1+a1,p1,o2+a2,p2);
              end;
            end;
          end;
          o1:=o2; a1:=a2; p1:=p2; st1:=st2;
        end;
      end;
      2:begin
        with geodpp[0] do begin a1:=sqrt(yamp*betb)*1000; p1:=100*dpp; st1:=perstat; end;
        if st1<1 then fig.plot.Symbol(p1,a1);
        for i:=1 to ngeodpp-1 do begin
          with geodpp[i] do begin a2:=sqrt(yamp*betb)*1000; p2:=100*dpp; st2:=perstat; end;
          if st2<2 then begin
            fig.plot.Symbol(p2,a2);
            if st1<2 then fig.plot.Line(p1,a1,p2,a2);
          end;
          a1:=a2; p1:=p2; st1:=st2;
        end;
      end;
      3:begin
         for i:=0 to ngeodpp-1 do begin
           if i < ngeodpp div 2 then elcol:=dimcol(clGray,clRed, i/(ngeodpp div 2)) else elcol:=dimcol(clGray,clBlue, (ngeodpp-i-1)/(ngeodpp div 2));
//           with geodpp[i] do begin //note, geodpp contains fixed ngeodpp data, to be changed for real Np...
           with geodpp[i] do fig.plot.Ellipse(beta, alfa, xamp, xorb, worb, 1000, 1000, elcol );
//           with geodpp[            0] do fig.plot.Ellipse(beta, alfa, xamp, xorb, worb, 1000, 1000, clRed );
//           with geodpp[ngeodpp   - 1] do fig.plot.Ellipse(beta, alfa, xamp, xorb, worb, 1000, 1000, clBlue);
//           with geodpp[ngeodpp div 2] do fig.plot.Ellipse(beta, alfa, xamp, xorb, worb, 1000, 1000, clGray);
          end;
      end;
    end;
  end;





  procedure ShowTrackLines;
  var
    ang, ang1, ang2, dppline, dgx, dgy, dgp, dgw, gt: real;
    {nnr,} i: integer;
  begin
    fig.plot.SetColor(clGray);
    if da_meth=1 then begin // sep mode
      case da_mode of
        0: begin
          ang:=Pi/nrays; ang1:=Pi/4; ang2:=3*Pi/4;
          for i:=0 to nrays-1 do begin
            ang:=i*Pi/(nrays-1);
            with fig.plot do begin
              MoveTo(xorb,0);
              if ang>ang2 then Lineto(gxmin, -Tan(ang)*gymax)
              else if ang>ang1 then Lineto((gxmax-xorb)/Tan(ang)+xorb ,gymax)
              else Lineto(gxmax, Tan(ang)*gymax);
            end;
          end;
        end;
        1: begin
          for i:=0 to nrays-1 do begin
            dppline:=gpmin+i*(gpmax-gpmin)/(nrays-1);
            fig.plot.Line(gxmin,dppline,gxmax,dppline);
          end;
        end;
        2: begin
          for i:=0 to nrays-1 do begin
            dppline:=gpmin+i*(gpmax-gpmin)/(nrays-1);
            fig.plot.Line(dppline,0,dppline,gymax);
          end;
        end;
        3: begin
          //incl bin search later
        end;
      end;
    end else begin     // da_meth=2,3
      dgx:=(gxmax-gxmin)/(ngridx);
      dgw:=(gwmax-gwmin)/(ngridx);
      dgy:=gymax/(ngridy);
      dgp:=(gpmax-gpmin)/(ngridp);
      case da_mode of
        0: begin
          with fig.plot do begin
            for i:=0 to ngridx-1 do begin gt:=(i+0.5)*dgx+gxmin; Line(gt,0,gt,gymax); end;
            for i:=0 to ngridy-1 do begin gt:=(i+0.5)*dgy;   Line(gxmin,gt,gxmax,gt); end;
          end;
        end;
        1: begin
          with fig.plot do begin
            for i:=0 to ngridx-1 do begin gt:=(i+0.5)*dgx+gxmin; Line(gt,gpmin,gt,gpmax); end;
            for i:=0 to ngridp-1 do begin gt:=(i+0.5)*dgp+gpmin; Line(gxmin,gt,gxmax,gt); end;
          end;
        end;
        2: begin
          with fig.plot do begin
            for i:=0 to ngridp-1 do begin gt:=(i+0.5)*dgp+gpmin; Line(gt,0,gt,gymax); end;
            for i:=0 to ngridy-1 do begin gt:=(i+0.5)*dgy;   Line(gpmin,gt,gpmax,gt); end;
          end;
        end;
        3: begin
          with fig.plot do begin //square grid in 4 quadrants using same N x and x' --> dgx, gxmin
            for i:=0 to ngridx-1 do begin gt:=(i+0.5)*dgx+gxmin; Line(gt,gwmin,gt,gwmax); end;
            for i:=0 to ngridx-1 do begin gt:=(i+0.5)*dgw+gwmin; Line(gxmin,gt,gxmax,gt); end;
          end;
        end;
      end;

    end;
  end;

  procedure ShowBox;
  begin
    with fig.plot do begin
      setColor(clBlack);
      case da_mode of
        0:begin
          Line(xorb,0,xorb,gymax);
          Rectangle(gxmin, 0, gxmax, gymax);
        end;
        1:begin
          Line(gxmin,0.0,gxmax,0.0); Line(0.0,gpmin,0.0,gpmax);
          Rectangle(gxmin, gpmin, gxmax, gpmax);
        end;
        2:begin
          Line(0,0,0,gymax);
          Rectangle(gpmin, 0, gpmax, gymax);
        end;
        3:begin
          Line(0,gwmin,0,gwmax);
          Line(gxmin,0,gxmax,0);
          Rectangle(gxmin, gwmin, gxmax, gwmax);
        end;
      end;
    end;
  end;

  procedure ShowDynAp;
  var
    i1, i2, i, igr:integer;
    //outfi: textfile;
    xp, yp: array[0..3] of real;
    elcol: TColor;
  begin
    case (da_meth) of
      1: begin
        with fig.plot do begin
          setColor(clred);
          if da_mode=1 then begin
            moveto (darays[0].ur, darays[0].vr);
            for i:=1 to nrays-1 do  Lineto (darays[2*i  ].ur, darays[2*i  ].vr); stroke;
            moveto (darays[1].ur, darays[1].vr);
            for i:=1 to nrays-1 do  Lineto (darays[2*i+1].ur, darays[2*i+1].vr);  stroke;
          end else begin
            moveto (darays[0].ur, darays[0].vr);
            for i:=1 to nrays-1 do  Lineto (darays[i].ur, darays[i].vr);  stroke;
          end;
        end;
      end;
      2, 3: begin
        //assignFile(outfi, work_dir+ExtractFileName(FileName)+'.dynap');
        //rewrite(outfi);
        //writeln('# x[mm]   y[mm]   nturns');
        with fig.plot do begin
{*}      if monitorxxp<>-2 then begin
          if plotstyle=1 then begin
            for i:=0 to High(dagrid) do with dagrid[i] do begin
              xp[0]:=a1-gda1; xp[1]:=a1+gda1; xp[2]:=a1+gda1; xp[3]:=a1-gda1;
              yp[0]:=a2-gda2; yp[1]:=a2-gda2; yp[2]:=a2+gda2; yp[3]:=a2+gda2;
              if loss=-1 then // cell was not tested (flood fill only)
                PSolid(a1-gda1,a2-gda2,a1+gda1,a2+gda2, clSkyBlue)
              else if loss<Nturns then
                PSolid(a1-gda1,a2-gda2,a1+gda1,a2+gda2, dimcol( clWhite, clGray, loss/Nturns) );
            end;
          end;
          setColor(clred);
          for i2:=0 to gn2 do begin
            for i1:=1 to gn1 do begin
              igr:=i1*(gn2+1)+i2;
              if (dagrid[igr].loss<Nturns) xor (dagrid[igr-(gn2+1)].loss<Nturns) then
                  with dagrid[igr] do line(a1-gda1,a2-gda2,a1-gda1,a2+gda2);
            end;
          end;
          for i1:=0 to gn1 do begin
            for i2:=1 to gn2 do begin
              igr:=i1*(gn2+1)+i2;
              if (dagrid[igr].loss<Nturns) xor (dagrid[igr-1].loss<Nturns) then
                with dagrid[igr] do line(a1-gda1,a2-gda2,a1+gda1,a2-gda2);
            end;
          end;
{*}      end;

          if da_meth=3 then begin //overplot boundaries to untested area with different color
{*}        if MonitorXXP<>-2 then begin
            setColor(dimcol(clSkyblue, clBlack, 0.7));//clAqua);
            for i2:=0 to gn2 do begin
              for i1:=1 to gn1 do begin
                igr:=i1*(gn2+1)+i2;
                if (dagrid[igr].loss=-1) xor (dagrid[igr-(gn2+1)].loss=-1) then
                  with dagrid[igr] do line(a1-gda1,a2-gda2,a1-gda1,a2+gda2);
              end;
            end;
            for i1:=0 to gn1 do begin
              for i2:=1 to gn2 do begin
                igr:=i1*(gn2+1)+i2;
                if (dagrid[igr].loss=-1) xor (dagrid[igr-1].loss=-1) then
                  with dagrid[igr] do line(a1-gda1,a2-gda2,a1+gda1,a2-gda2);
              end;
            end;
{*}        end;

            if da_mode=3 then begin
              if MonitorXXP>=0 then begin //show polygon fit to flood map
                setThick(2);
                with geodpp[MonitorXXP] do fig.plot.Ellipse(beta, alfa, xamp, xorb, worb, 1000, 1000, clRed );
                //preview of next
                // (ngeodpp has been set to ngrids in mode 3, i.e. monitorxxp is also the index to the current dpp value)
                setColor(clFuchsia);
                moveto(Flopx[Monitorxxp*ngrang+ngrang-1]+FloPxo[MonitorXXP], FloPw[MonitorXXP*ngrang+ngrang-1]+FloPwo[MonitorXXP]);
                for i:=0 to ngrang-1 do lineto(FloPx[Monitorxxp*ngrang+i]+FloPxo[MonitorXXP], FloPw[MonitorXXP*ngrang+i]+FloPwo[MonitorXXP]);    stroke;
                setthick(1);
                if monitorXXP < ngeodpp-1 then with geodpp[MonitorXXp+1] do fig.plot.Ellipse(beta, alfa, xamp, xorb, worb, 1000, 1000, clGreen);
              end else begin
                for i1:=0 to ngrids-1 do begin
                  if i1 < ngrids div 2 then elcol:=dimcol(clGray,clRed, i1/(ngrids div 2)) else elcol:=dimcol(clGray,clBlue, (ngrids-i1-1)/(ngrids div 2));
                  setColor(elcol);
                  moveto(Flopx[i1*ngrang+ngrang-1]+FloPxo[i1], FloPw[i1*ngrang+ngrang-1]+FloPwo[i1]);
                  for i2:=0 to ngrang-1 do lineto(FloPx[i1*ngrang+i2]+FloPxo[i1], FloPw[i1*ngrang+i2]+FloPwo[i1]);     stroke;
                  SetSymbol( 2, 1, elcol); Symbol(FloPxo[i1], FloPwo[i1]);
                end;
              end;
            end; //da mode 3
          end; //da meth 3
        end; // with figplot
        //CloseFile(outfi);
      end; //case 2,3
    end; // case(da_meth)
  end;

begin
// initialize plot range
  fig.plot.setcolor(clBlack);
  fig.plot.clear(clWhite);
  if MonitorXXP<=-1 then begin

    with Opstart do begin
      xrange:=sqrt(GeoAccX*beta)*1000;
      yrange:=sqrt(GeoAccY*betb)*1000;
      wrange:=sqrt(GeoAccX*(1+sqr(alfa))/beta)*1000;
      xorb:=orb[1]*1000;
      worb:=orb[2]*1000;
{
    xmin  :=-xrange+xorb;
    xmax  := xrange+xorb;
}
    end;
    gxmin:=-geofac*xrange+xorb; gxmax:=geofac*xrange+xorb;
    gymax:= geofac*yrange;
    gwmin:=-geofac*wrange+worb; gwmax:=geofac*wrange+worb;
    gpmin:=-100*dpprange;
    gpmax:= 100*dpprange;
  end;

  case da_mode of
    0: fig.Init(gxmin,0, gxmax, gymax, 1, 1, 'X [mm]','Y [mm]',3,false);
    1: fig.Init(gxmin,gpmin, gxmax, gpmax, 1, 1, 'X [mm]','dp/p [%]',3,false);
    2: fig.Init(gpmin, 0, gpmax, gymax,  1, 1, 'dp/p [%]','Y [mm]',3,false);
    3: fig.Init(gxmin, gwmin, gxmax,gwmax,  1, 1, 'X [mm]','X'' [mrad]',3,false);
  end;
  if not (TrackDone or (MonitorXXP>=0)) then ShowTrackLines else ShowDynap;
  if MonitorXXP=-1 then ShowGeoAper;
  ShowBox;
end;

procedure TtrackDA.DARaySetup;
var
  ang, ang1, ang2, xorb: real;
  i, ipm: integer;
begin
  case da_mode of
    0: begin //uv=xy
      setlength(darays,nrays);
      xorb:=   Opstart.orb[1]*1000;
      ang:=Pi/nrays; ang1:=Pi/4; ang2:=3*Pi/4;
      for i:=0 to nrays-1 do begin
        ang:=i*Pi/(nrays-1);
        with darays[i] do begin
          u1:=xorb; v1:=0;
          ur:=u1; vr:=v1;
          if ang>ang2 then begin
            u2:=gxmin; v2:=-Tan(ang)*gymax;
          end else if ang>ang1 then begin
            u2:=(gxmax-xorb)/Tan(ang)+xorb; v2:=gymax;
          end else begin
            u2:=gxmax; v2:= Tan(ang)*gymax;
          end;
        end;
      end;
    end;
    1: begin //uv=xp
      setlength(darays,2*nrays);
      for i:=0 to nrays-1 do for ipm:=0 to 1 do with darays[2*i+ipm] do begin
        v1:=gpmin+i*(gpmax-gpmin)/(nrays-1); v2:=v1;
        u1:=geodpp[i].xorb*1000;
        u2:=gxmin*(1-ipm)+gxmax*ipm;
        ur:=u1; vr:=v1;
      end;
{
      for i:=0 to nrays-1 do with darays[nrays+i] do begin
        v1:=gpmin+i*(gpmax-gpmin)/(nrays-1); v2:=v1;
        u1:=geodpp[i].xorb*1000;
        u2:=gxmax;
        ur:=u1; vr:=v1;
      end;
}
    end;
    2: begin //uv=py
      setlength(darays,nrays);
      for i:=0 to nrays-1 do with darays[i] do begin
        v1:=0; v2:=gymax; //assume yorb=0 (still for flat lattice only)
        u1:=gpmin+i*(gpmax-gpmin)/(nrays-1); u2:=u1;
        ur:=u1; vr:=v1;
      end;
    end;
    3: begin //uv=xx'
      //later
    end;
  end;
end;


procedure TtrackDA.DAGridSetup;
// see idl/tmp/ngrid.pro
var
  ig1, ig2, igda, i, j, k, im1, im2, jm, im, di, n, nn, m1, m2: integer;
//  da1, da2: real;
  gline: array of integer;

  procedure iadd (k1,k2:integer);
  var
    igri:integer;
  begin
    igri := findIgri(k1,k2);
    dagord[igda]:=igri;
    dagrid[igri].igord:=igda;
    dagrid[igri].loss := -1; //only required for da_meth=3
    Inc(igda);
  end;


begin
  case da_mode of
    1:   begin gn1:=ngridx; gn2:=ngridp; end;
    2:   begin gn1:=ngridp; gn2:=ngridy; end;
    3:   begin gn1:=ngridx; gn2:=ngridx; end;
    else begin gn1:=ngridx; gn2:=ngridy; end;
  end;
  setlength(dagrid,gn1*gn2);
  setlength(dagord,gn1*gn2);
  dec(gn1); dec(gn2);

//  p_vals := TList<real>.Create;
//  p_opvals := TList<OpvalType>.Create;

  case da_mode of // 2D-grid
    0,3: begin
      nn:=1; // find largest power of 2 dividing both nn1 and nn2
      repeat nn:=2*nn until (gn1 mod nn >0) or (gn2 mod nn > 0);
      nn:=nn div 2; n:=round(log2(nn));
      m1:=gn1 div nn; m2:=gn2 div nn;
      igda:=0;
      for im1:=0 to m1-1 do for im2:=0 to m2-1 do iadd(im1*NN,im2*NN);
      for im2:=0 to m2-1 do iadd(gn1,im2*NN);
      for im1:=0 to m1-1 do iadd(im1*NN,gn2);
      iadd(gn1,gn2);
      di:=NN;
      for k:=N downto 1 do begin
        di :=di div 2;
        for j:=0 to gn1 div (2*di) -1 do begin
          jm:=(2*j+1)*di;
          for i:=0 to gn2 div (2*di) -1 do begin
            im:=(2*i+1)*di;
            iadd(jm+di,im);
            iadd(jm,im+di);
            if j=0 then iadd(0, im);
            if i=0 then iadd(jm, 0);
          end;
        end;
        for j:=0 to gn1 div (2*di) -1 do begin
          jm:=(2*j+1)*di;
          for i:=0 to gn2 div (2*di) -1 do begin
            im:=(2*i+1)*di;
            iadd(jm,im);
          end;
        end;
      end;
    end;
    1: begin // 1D grid, slow vary of dp/p coord
      setlength(gline,gn1+1);
      di:=gn1; n:=round(log2(gn1));
      gline[0]:=0; gline[1]:=gn1; j:=2;
      for k:=n downto 1 do begin
        di:=di div 2;
        for i:=0 to gn1 div (2*di)-1 do begin
          gline[j]:=(2*i+1)*di; inc(j);
        end;
      end;
      igda:=0;
      for i:=0 to gn1 do iadd(gline[i],  0);
      for i:=0 to gn1 do iadd(gline[i],gn2);
      di:=gn2; n:=round(log2(gn2));
      for k:=n downto 1 do begin
        di:=di div 2;
        for j:=0 to gn2 div (2*di)-1  do begin
          jm:=(2*j+1)*di;
          for i:=0 to gn1 do iadd(gline[i],jm);
        end;
      end;
      gline:=nil;
    end;
    2: begin
      setlength(gline,gn2+1);
      di:=gn2; n:=round(log2(gn2));
      gline[0]:=0; gline[1]:=gn2; j:=2;
      for k:=n downto 1 do begin
        di:=di div 2;
        for i:=0 to gn2 div (2*di)-1 do begin
          gline[j]:=(2*i+1)*di; inc(j);
        end;
      end;
      igda:=0;
      for i:=0 to gn2 do iadd(0  , gline[i]);
      for i:=0 to gn2 do iadd(gn1, gline[i]);
      di:=gn1; n:=round(log2(gn1));
      for k:=n downto 1 do begin
        di:=di div 2;
        for j:=0 to gn1 div (2*di)-1  do begin
          jm:=(2*j+1)*di;
          for i:=0 to gn2 do iadd(jm,gline[i]);
        end;
      end;
      gline:=nil;
    end;
  end;
  case da_mode of
    1:begin
      gda1:=0.5*(gxmax-gxmin)/ngridx;
      gda2:=0.5*(gpmax-gpmin)/ngridp;
      gamin1:=gxmin; gamin2:=gpmin;
    end;
    2:begin
      gda1:=0.5*(gpmax-gpmin)/ngridp;
      gda2:=0.5*(gymax)/ngridy;
      gamin1:=gpmin; gamin2:=0.0;
    end;
    3:begin
      gda1:=0.5*(gxmax-gxmin)/ngridx;
      gda2:=0.5*(gwmax-gwmin)/ngridx;
      gamin1:=gxmin; gamin2:=gwmin;
    end;
    else begin
      gda1:=0.5*(gxmax-gxmin)/ngridx;
      gda2:=0.5*(gymax)/ngridy;
      gamin1:=gxmin; gamin2:=0.0;
    end;
  end;
  for ig1:=0 to gn1 do for ig2:=0 to gn2 do with dagrid[ig1*(gn2+1)+ig2] do begin
    a1:=(ig1*2+1)*gda1+gamin1;
    a2:=(ig2*2+1)*gda2+gamin2;
  end;
end;


function TTrackDA.findIgri(i1: integer; i2: integer): integer;
begin
  findIgri :=(gn2+1)*i1+i2;
end;

{function getOpvalForDpp(dpp: real): OpvalType;
var
  ix: integer;
begin
  ix := p_vals.IndexOf(dpp);
  if ix = -1 then begin
    TrackingMatrix(dpp,0);
    TrackPoint;
    p_vals.Add(dpp);
    p_opvals.Add(Opstart);
    getOpvalForDpp := Opstart;
  end else
    getOpvalForDpp := p_opvals[ix];
//  writeln(dpp);
end;
}

function TTrackDA.InitialVektor(vko1: real; vko2: real; dpp: real; ko1: integer; ko2: integer): Vektor_5;
const
  tiny = 0.1e-6; // add 0.1 micron/micrad to x,y to excite d.o.f.
  dppeps = 1e-6; // dpp difference to recalc dpp transfermatrix
var
  x0: Vektor_5;
  dppuse: real;
  noper: boolean;
  i: integer;

begin
  x0:=VecNul5;
  x0[5]:=dpp; //might be overwritten by ko1=5 or ko2=5
  x0[ko1]:=vko1;
  x0[ko2]:=vko2;

  dppuse:=x0[5];
  if da_mode>0 then begin
    if abs(dppuse - dpp_lastused) > dppeps then begin

      //need full update incl. closed orbit and periodic to get correct orb and betas
//?      Initdpp(dppuse, GeoAccX, GeoAccY, Aper_X, Aper_Y, startPos, false, false);
      Initdpp(dppuse, GeoAccX, GeoAccY, Aper_X, Aper_Y, startPos, cbxaper.Checked, true);
{
      Trackingmatrix(dppuse,0);
      Trackpoint; // no update of Opstart, needs new periodic solution
}

// writeln('inivek opstart dpp geoaccx, geoaccy betas ', dppuse, ' ',geoaccx, ' ', geoaccy, '  ', opstart.beta, '  ', opstart.betb);
    end;
    dpp_lastused:=dppuse;
  end;

  with Opstart do begin
    if da_mode<3 then begin
//            x0[2]:=alfa*(disx*dppuse-x0[1])/beta+dipx*dppuse; // previous
//            x0[4]:=alfb*(disy*dppuse-x0[3])/betb+dipy*dppuse;
      //      x0[2]:=alfa*(disx*dppuse-(x0[1]-orb[1]))/beta+dipx*dppuse+orb[2]; // wrong, double count of orbit?
      //      x0[4]:=alfb*(disy*dppuse-(x0[3]-orb[3]))/betb+dipy*dppuse+orb[4];
      x0[2]:=alfa*(orb[1]-x0[1])/beta+orb[2]; // orb contains dispersive offset
      x0[4]:=alfb*(orb[3]-x0[3])/betb+orb[4];
    end else begin
      x0[2]:=x0[2]+tiny;
      x0[4]:=x0[4]+tiny;
    end;
    x0[1]:=x0[1]+tiny;
    x0[3]:=x0[3]+tiny;
  end;
  InitialVektor := x0;
end;


function TtrackDA.DASingleTracking(t1, t2: real; dpp: real; ko1: integer; ko2: integer): integer;
const
  scal: array[1..5] of real=(1000,1000,1000,1000,100);    // mm,% --> m,1
var
  kturns: integer;
  Lost: boolean;
  x0,x: Vektor_5; //inloop
begin
  x0 := InitialVektor(t1/scal[ko1], t2/scal[ko2], dpp, ko1, ko2);
  x:=x0;
  kturns:=0;
  repeat
    inc(kturns);
    Lost:=Oneturn(x);
  until (kturns = Nturns) or Lost or TrackBreak;
  if Lost then fig.plot.SetSymbol( 2, 1, clRed) else fig.plot.SetSymbol(2,1,clLime);
  fig.plot.Symbol(x0[ko1]*scal[ko1],x0[ko2]*scal[ko2]);
  Inc(TotalTurns,kturns);
  Application.ProcessMessages;
  if Lost then  DASingleTracking:=kturns-1 else DASingleTracking:=Nturns;
end;

procedure TtrackDA.DATrackingBinRays(dpp: real; ko1: integer; ko2: integer);
var
  iray, nterm: integer; dlam, lam, utest, vtest: real;
begin
  iray:=0;
  if da_mode=1 then nterm:=2*nrays else nterm:=nrays;
  while not (TrackBreak or (iray=nterm) ) do begin
    dlam:=1.0; lam:=0.0;
    with darays[iray] do begin
      repeat
        lam:=lam+dlam;
        utest:=lam*u2+(1-lam)*u1;  vtest:=lam*v2+(1-lam)*v1;
        if (DASingleTracking(utest, vtest, dpp, ko1, ko2) <> nturns) then begin //lost
          lam:=lam-dlam;
          dlam:=dlam/2;
        end;
      until dlam<relreso;
      ur:=utest; vr:=vtest;
// writeln(iray,' ',ur,'  ', vr);
    end;
    Inc(iray);
  end;
end;


{
//test only for ftt-paper: reverse scan
procedure TtrackDA.DATrackingBinRays(dpp: real; ko1: integer; ko2: integer);
var
  iray, nterm: integer; dlam, lam, utest, vtest: real;   lost:boolean;
begin
  iray:=0;
  if da_mode=1 then nterm:=2*nrays else nterm:=nrays;
  while not (TrackBreak or (iray=nterm) ) do begin
    dlam:=relreso; lam:=1.0+dlam;
    with darays[iray] do begin
      repeat
        lam:=lam-dlam;
        utest:=lam*u2+(1-lam)*u1;  vtest:=lam*v2+(1-lam)*v1;
        lost:= DASingleTracking(utest, vtest, dpp, ko1, ko2) <> nturns;
      until (not lost) or (lam<dlam);
      ur:=utest; vr:=vtest;
    end;
    Inc(iray);
  end;
end;
}

procedure TtrackDA.DATrackingClassicGrid(dpp: real; ko1: integer; ko2: integer);
var
  igo, igr: integer;
begin
  igo:=0;
  while not (TrackBreak or (igo>High(dagord)) ) do begin
    igr:=dagord[igo];
//writeln(igo,' ',igr);
    dagrid[igr].loss:=DASingleTracking(dagrid[igr].a1, dagrid[igr].a2, dpp, ko1, ko2);
    Inc(igo);
  end;
end;

type TIndexQueue = class
  private
    i1array: array[1..2048] of integer;
    i2array: array[1..2048] of integer;
    a, b: integer;
  public
    constructor Create; overload;
    procedure push(i1: integer; i2: integer);
    function first_i1(): integer;
    function first_i2(): integer;
    function is_empty(): bool;
    procedure pop();
end;

constructor TIndexQueue.Create;
  begin
    a := 1;
    b := 1;
  end;

  procedure TIndexQueue.push(i1: integer; i2: integer);
  begin
    if (((a=1) and (b=2048)) or ((b+1)=a)) then raise exception.create('queue is full..');
    i1array[b] := i1;
    i2array[b] := i2;
    if b=2048 then b := 1 else Inc(b);
  end;

  function TIndexQueue.first_i1(): integer;
  begin first_i1 := i1array[a]; end;

  function TIndexQueue.first_i2(): integer;
  begin first_i2 := i2array[a]; end;

  function TIndexQueue.is_empty(): bool;
  begin is_empty := (a = b); end;

  procedure TIndexQueue.pop();
  begin if a=2048 then a := 1 else Inc(a); end;


function TtrackDA.PixelIsUnstable(i1: integer; i2: integer; dpp: real; ko1: integer; ko2: integer): bool;
var
  igr: integer;
  is_unstable: bool; //pascal cannot return directly, so we need this intermediate var
begin
  igr := findIgri(i1,i2);
  //outside grid means do not fill pixel
  //loss<>-1 means pixel already computed
  if ((i1<0) or (i2<0) or (i1>gn1) or (i2>gn2) or (dagrid[igr].loss<>-1)) then is_unstable := false
  else begin
    dagrid[igr].loss:=DASingleTracking(dagrid[igr].a1, dagrid[igr].a2, dpp, ko1, ko2);
    is_unstable := dagrid[igr].loss <> Nturns;
  end;
  //application.messagebox(PChar('('+intToStr(i1)+','+intToStr(i2)+')'), PChar('(i1,i2)'));
  PixelIsUnstable := is_unstable;
end;

procedure TtrackDA.DATrackingFillToolGrid(i1start: integer; i2start: integer; dpp: real; ko1: integer; ko2: integer);
var
  i1, i2: integer;
  queue: TIndexQueue;

begin
  queue := TIndexQueue.Create();
  if PixelIsUnstable(i1start,i2start,dpp,ko1,ko2) then queue.push(i1start,i2start);

  while not (TrackBreak or queue.is_empty()) do begin
    i1 := queue.first_i1();
    i2 := queue.first_i2();
    queue.pop();
    //application.messagebox(PChar('('+intToStr(i1)+','+intToStr(i2)+')'), PChar('POPPED'));
    if PixelIsUnstable(i1+1,i2,dpp,ko1,ko2) then queue.push(i1+1,i2);
    if PixelIsUnstable(i1-1,i2,dpp,ko1,ko2) then queue.push(i1-1,i2);
    if PixelIsUnstable(i1,i2+1,dpp,ko1,ko2) then queue.push(i1,i2+1);
    if PixelIsUnstable(i1,i2-1,dpp,ko1,ko2) then queue.push(i1,i2-1);
  end;
  //application.messagebox(PChar('opvals: '+intToStr(p_opvals.Count)), PChar('show opvals'), 0);
end;

procedure TtrackDA.FloPinit;
var
  p: real;
  i, np0: integer;
begin
  setlength(FloPs,ngrang);
  setlength(FloPc,ngrang);
  setlength(FloPx,ngrang*ngrids);
  setlength(FloPw,ngrang*ngrids);
  setlength(FloPxo,ngrids);
  setlength(FloPwo,ngrids);
  setlength(FloPdpp,ngrids);
  np0:=ngrids div 2;
  for i:=0 to ngrids-1 do FloPdpp[i]:=(i-np0)/np0*dpprange;
  for i:=0 to ngrang-1 do begin
    p:=2*i*Pi/ngrang; FloPs[i]:=gda2*Sin(p); FloPc[i]:=gda1*Cos(p);
  end;
  FloPxmin:=gxmin; FloPxmax:=gxmax; FloPwmin:=gwmin; FloPwmax:=gwmax;
end;


procedure TtrackDA.FloPoly (isl: integer);
//get a polygon from flood map
const
  epsilon: real = 0.1;
var
  dx, dw, xo, wo, radius, step: real;
  ia: integer;
  out_of_grid, old_stable, new_stable: bool;
//  s: array of string;

  function PolyPixIsStable: boolean;
  var
    kx, kw, igrd: integer;
    out_of_grid: bool;
  begin
    kx:=Trunc((xo+dx-gxmin)/gda1/2);
    kw:=Trunc((wo+dw-gwmin)/gda2/2);
    out_of_grid := (kx<0) or (kx>=Ngridx) or (kw<0) or (kw>=Ngridx); //Ngridx in both dirs?

    if out_of_grid then PolyPixIsStable := false
    else begin
      igrd:=findIgri(kx,kw);
      PolyPixIsStable := (dagrid[igrd].loss=nturns) or (dagrid[igrd].loss=-1);
    end;
 end;

begin
  xo:=Opstart.orb[1]*1000;
  wo:=Opstart.orb[2]*1000;
  FloPxo[isl]:=xo;
  FloPwo[isl]:=wo;
  for ia:=0 to ngrang-1 do begin
    dx:=0; dw:=0; radius:=0; step:=1;
    old_stable := PolyPixIsStable;
//    s:=nil;
    if old_stable then repeat
      new_stable := PolyPixIsStable;
      if (old_stable <> new_stable) then begin // stability has flipped
        step := -step / 2;
        old_stable := new_stable; //memorize flipped stability for future checks
      end;
      radius := radius + step;
      dx:=radius*FloPc[ia];
      dw:=radius*FloPs[ia];
    until abs(step)<epsilon;

    Flopx[ngrang*isl+ia]:=dx;
    Flopw[ngrang*isl+ia]:=dw;
  end;
end;



procedure TtrackDA.DATracking;
var
  dpp: real;
  ko1, ko2, iloop, nloop, i: integer;


begin
    Screen.Cursor:=crHourGlass;
    TrackDone:=False;
    butstart.Caption:='Stop';
    butstart.Tag:=1;

//!    p_vals := TList<real>.Create;
//!    p_opvals := TList<OpvalType>.Create;

    if da_meth =1 then DARaySetup else DAGridSetup;

    dpp:=0.0; nloop:=1;
    case da_mode of
      0: begin ko1:=1; ko2:=3; dpp:=dppoffset; end;
      1: begin ko1:=1; ko2:=5; end;
      2: begin ko1:=5; ko2:=3; end;
      3: begin ko1:=1; ko2:=2;
           nloop:=ngrids;
           FloPinit;

         end; //xx' --> loop over dp
    end;

    TrackBreak:=False;
    TotalTurns:=0;
    dpp_lastused:=-1;

    for iloop:=0 to nloop-1 do begin //loop only for da_mode 3

      if da_mode=3 then begin
        dpp:=FloPdpp[iloop];     //   dpp:=geodpp[iloop].dpp;        //Initialvektor will set up orbit and TMat for dpp if needed
//writeln(iloop,' dpp =',dpp);
        for i:=0 to High(dagrid) do dagrid[i].loss:=-1;
//        MakePlot; //instead show dpp in plot
      end;

      if (da_meth = 3) and (da_mode in [0,3]) then begin
        DATrackingFillToolGrid(  0, gn2, dpp, ko1, ko2);  //apply tool on upper left
        DATrackingFillToolGrid(gn1, gn2, dpp, ko1, ko2);  //apply tool on upper right
      end else if da_meth=1 then begin
        DATrackingBinRays(dpp, ko1, ko2);
      end else begin
        DATrackingClassicGrid(dpp, ko1, ko2);
      end;

      if (da_mode=3) and (not TrackBreak) then begin
//        FloPdpp[iloop]:=dpp;
        FloPoly (iloop);
        MonitorXXP:=iloop;
        MakePlot;          //only to show result
        MonitorXXP:=-2;
      end;
    end;
    TrackDone:=not TrackBreak;

    OPALog(0,inttostr(TotalTurns)+' turns tracked in total.');
    dpp:=0.0;
    if da_mode>0 then Initdpp(dpp, GeoAccX, GeoAccY, Aper_X, Aper_Y, startPos, cbxaper.Checked, true);
    MakePlot; //mod to show polygons for da mode 3
    MonitorXXP:=-1;
    if TrackDone and (da_mode=3) then status.FloPoly:=True;
    butstart.Caption:='Start';
    butstart.Tag:=0;
    Screen.Cursor:=crDefault;
end;

{plot control status trackdone steuern
grid mode nicht fuer dpp? gibt sonst staending neue dpp berechnungen!
dafuer xy rechnung fuer 0+- werte von dpp
[later upgrade to sync osc] ???}

procedure TtrackDA.figpPaint(Sender: TObject);
begin
  MakePlot;
end;




end.
