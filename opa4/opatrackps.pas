unit opatrackps;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
//  linoplib, // test
  StdCtrls, ExtCtrls, ASfigure, globlib, ASaux, opatunediag, mathlib, tracklib, Math, Grids, Vgraph;

type

  { Ttrackp }

  Ttrackp = class(TForm)
    butParam: TButton;
    labParam: TLabel;
    psx: TFigure;
    psy: TFigure;
    ftx: TFigure;
    fty: TFigure;
    PanParam: TPanel;
    PanCtrl: TPanel;
    PanFFT: TPanel;
    butexit: TButton;
    comTurns: TComboBox;
    edixaper: TEdit;
    ediyaper: TEdit;
    labturns: TLabel;
    labcoord: TLabel;
    edixini: TEdit;
    ediyini: TEdit;
    edipxini: TEdit;
    edipyini: TEdit;
    Labx: TLabel;
    labpx: TLabel;
    labY: TLabel;
    labpy: TLabel;
    edidpp: TEdit;
    Labdpp: TLabel;
    butrun: TButton;
    butmore: TButton;
    butclear: TButton;
    labax: TLabel;
    labay: TLabel;
    labtune: TLabel;
    labpident: TLabel;
    labdisplay: TLabel;
    editune: TEdit;
    edipident: TEdit;
    edidisplay: TEdit;
    cbxElaper: TCheckBox;
    labdone: TLabel;
    labt: TLabel;
    PanRes: TPanel;
    edirelf: TEdit;
    Labrelf: TLabel;
    PanTush: TPanel;
    ediSteps: TEdit;
    LabSteps: TLabel;
    butTush: TButton;
    LabTush: TLabel;
    butBreak: TButton;
    edistartpos: TEdit;
    labstartpos: TLabel;
    butexport: TButton;
    labelaper1: TLabel;
    Labelaper2: TLabel;
    buttxt: TButton;
    resgrid: TStringGrid;
    tsplotbut: TButton;
    labtprog: TLabel;
    panBeam: TPanel;
    butBeam: TButton;
    labBeamBeta: TLabel;
    LabBeamAlfa: TLabel;
    LabBeamEmit: TLabel;
    LabBeamNpar: TLabel;
    ButBeamXY: TButton;
    EdiBeamBeta: TEdit;
    EdiBeamAlfa: TEdit;
    EdiBeamEmit: TEdit;
    EdiBeamNpar: TEdit;
    ButBeamShow: TButton;
    ButBeamRun: TButton;
    ButBeamBreak: TButton;
    LabBeamNshow: TLabel;
    ediBeamNshow: TEdit;
    butT6: TButton;
    procedure butexitClick(Sender: TObject);
    procedure comTurnsChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure butclearClick(Sender: TObject);
    procedure cbxElaperClick(Sender: TObject);
    procedure ediKeyPress(Sender: TObject; var Key: Char);
    procedure ediExit(Sender: TObject);
    procedure ediAction(edi: TEdit; kv:real);
    procedure pPaint(Sender: TObject);
    function  Track: boolean;
    function  TrackBeam: boolean;
    procedure butrunClick(Sender: TObject);
    procedure butmoreClick(Sender: TObject);
    procedure butParamClick(Sender: TObject);
    procedure resgridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure rbpingClick(Sender: TObject);
    procedure rbspecClick(Sender: TObject);
    procedure butTushClick(Sender: TObject);
    procedure ediIExit(Sender: TObject);
    procedure ediIKeyPress(Sender: TObject; var Key: Char);
    procedure butBreakClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure butexportClick(Sender: TObject);
    procedure buttxtClick(Sender: TObject);
    procedure tsplotbutClick(Sender: TObject);
    procedure butBeamClick(Sender: TObject);
    procedure ButBeamXYClick(Sender: TObject);
    procedure StartEnsemble;
    procedure ButBeamShowClick(Sender: TObject);
    procedure ButBeamRunClick(Sender: TObject);
    procedure ButBeamBreakClick(Sender: TObject);
    procedure butT6Click(Sender: TObject);

  private
    beambreak, tushbreak:boolean;
    mindqx, maxdqx, mindqy, maxdqy, tjxmax, tjymax: real;
    dqx, dqy, tjx, tjy: array of real;
    ntush, iturns, Nturns, tsplotmode: integer;
    startPosition, dpp, GeoAccX, GeoAccY, ApertureX, ApertureY, xenvel, pxenvel, yenvel, pyenvel:real;
    xini, yini, pxini, pyini: real;
    xtrack: Vektor_5;
    pident, dthresh, deltune, relfilter: real;
    rBeamNpar, nShowFirstTurns: integer;
    rBeamXY: boolean;
    rBeamBetax, rBeamAlfax, rBeamEmitx, rBeamBetay, rBeamAlfay, rBeamEmity: real;
    procedure Exit;
    procedure UpdateApertures;
    procedure PSinit;
    procedure resizeAll;
//    procedure setLabRes(x0, y0, a,b,c: integer);
    procedure Spectrum;
    procedure FFTplot;
    procedure TushPlot (mode, doxy: integer);
  public
    procedure Start(TP:TtunePlot);
  end;

const
  edwid=6; eddec=2;
  exportcom: array[0..2] of string[23]=('# horizontal excitation',
                                  '# coupled excitation   ',
                                  '# vertical excitation  ');

var
  TrackP: Ttrackp;

implementation

{$R *.lfm}

var
  tuneplothandle: TtunePlot;


procedure Ttrackp.Start(TP:TtunePlot);
var
  k, minturnexp,maxturnexp: integer;
begin
  tuneplothandle:=TP;
  comTurns.Items.Clear;
  minturnexp:=Round(Log2(minturns));
  maxturnexp:=Round(Log2(maxturns));
  for k:=0 to maxturnexp-minturnexp do begin
    comTurns.Items.Add(InttoStr( Round(PowI(2,k+minturnexp)) ));
  end;
  comTurns.ItemIndex:=IDefget('trackp/texp');
  deltune  :=FDefget('trackp/delq');
  pident   :=FDefget('trackp/pid');
  dthresh  :=FDefget('trackp/dthr');
  relfilter:=FDefget('trackp/relf');
  ntush    :=IDefGet('trackp/ntush');
  ApertureX:=FDefGet('trackp/aperx');
  ApertureY:=FDefGet('trackp/apery');
  Nturns:=Round(PowI(2,(comTurns.ItemIndex+minturnexp)));
  rBeamBetaX:=FDefGet('trackp/bbetx');
  rBeamAlfaX:=FDefGet('trackp/balfx');
  rBeamEmitX:=FDefGet('trackp/bemix');
  rBeamBetaY:=FDefGet('trackp/bbety');
  rBeamAlfaY:=FDefGet('trackp/balfy');
  rBeamEmitY:=FDefGet('trackp/bemiy');
  rBeamNpar :=IDefGet('trackp/bnpar');
  nShowFirstTurns:=0;
  resgridXY[1,0]:=0;
  with resgrid do begin
    Cells[1,0]:='Guess'; Cells[2,0]:='Tune'; Cells[3,0]:='Amp.'
  end;

  psx.assignScreen;
  psy.assignScreen;
  ftx.assignScreen;
  fty.assignScreen;

// tell the figures into which fields to write data
  psx.passEditHandleX(edixini,  edwid, eddec);
  psx.passEditHandleY(edipxini, edwid, eddec);
  psy.passEditHandleX(ediyini,  edwid, eddec);
  psy.passEditHandleY(edipyini, edwid, eddec);

// initialize tracking:
  TrackInit;
  dpp:=0;
  startPosition:=0.0;
  ftx.Init(0,0,0.5,1, 1, 0,'','',0,false);
  fty.Init(0,0,0.5,1, 1, 0,'','',0,false);
  edixaper.text:=ftos(ApertureX, edwid, eddec);
  ediyaper.text:=ftos(ApertureY, edwid, eddec);
  edixaper.enabled:=not cbxElaper.Checked;
  ediyaper.enabled:=not cbxElaper.Checked;
  edisteps.text:=inttoStr(ntush);
  editune.text   := FtoS(deltune, 7, 4);
  edipident.text := FtoS(pident, 7,4);
  edirelf.text   := FtoS(relfilter, -2,2);
  edidisplay.text:= FtoS(dthresh, -2,2);
  edistartpos.text:=FtoS(startPosition,8,3);
  rBeamXY:=false;
  ediBeamBeta.text:=FtoS(rBeamBetaX,edwid,eddec);
  ediBeamAlfa.text:=FtoS(rBeamAlfaX,edwid,eddec);
  ediBeamEmit.text:=FtoS(rBeamEmitX,edwid,eddec);
  ediBeamNPar.text:=FtoS(rBeamNPar,4,0);
  ediBeamNshow.text:=FtoS(nShowFirstTurns,4,0);
  Initdpp(dpp, GeoAccX, GeoAccY, ApertureX, ApertureY, startPosition, cbxElaper.Checked, true);
  PanRes.Visible:=false;
  panBeam.Visible:=false;
  labParam.Caption:='';
  labtprog.caption:='';
  Tushbreak:=false;
  ButBreak.enabled:=Tushbreak;
  TunePlotHandle.Diagram(LinTune[1], LinTune[2]);
  tsplotmode:=0;
  tsplotbut.Caption:=' Amplitude ';
  TrackMode6:=false;
end;

{ [re-]initialize phase space plots and draw empty ellipses
  calculate max plot range from element apertures, draw acceptance ellipses:}
procedure Ttrackp.PSinit;
begin
  psx.plot.setcolor(clBlack);
  psy.plot.setcolor(clBlack);
// calculate plotrange from acceptance and betas
  with Opstart do begin
    xenvel  :=(Sqrt(GeoAccX*beta)+abs(orb[1]))*1000;
    pxenvel :=(Sqrt(GeoAccX*(1+Sqr(alfa))/beta)+abs(orb[2]))*1000;
    yenvel  :=(Sqrt(GeoAccY*betb)+abs(orb[3]))*1000;
    pyenvel :=(Sqrt(GeoAccY*(1+Sqr(alfb))/betb)+abs(orb[4]))*1000;
// initialize figures with plot range:
    psx.Init(-xenvel,-pxenvel, xenvel, pxenvel, 1, 1, 'X [mm]','Px [mrad]', 3,false);
    psy.Init(-yenvel,-pyenvel, yenvel, pyenvel, 1, 1, 'Y [mm]','Py [mrad]', 3,false);
// draw ellipses marking the available aperture
    psx.plot.Ellipse(beta, alfa, GeoAccX, orb[1], orb[2], 1000, 1000, clNavy);
    psy.plot.Ellipse(betb, alfb, GeoAccY, orb[3], orb[4], 1000, 1000, clNavy);
  end;
  butmore.enabled:=false;
  panRes.Visible:=true;
  panFFT.Visible:=false;
  labParam.Caption:='Resonance guess';
end;

procedure Ttrackp.resizeAll;
const
  spc=10; pspc=6;
var
  i, panw, panh, picfh, spp, spf, picwh, grw, grh, rgwid: integer;
  grx, gry: array[0..4] of integer;
begin
  if (width<800) then width:=800;
  if (width>screen.width) then width:=screen.width;
  if ((left+width)>screen.width) then left:=screen.width-width;
  picwh:=round(0.35*clientwidth);
  spf:=picwh+2*spc;
  picfh:=round(0.6*picwh);

  psx.setsize(  spc, spc, picwh, picwh);
//  psy.setsize(  spf, spc, picwh, picwh);
  psy.setsize(  clientwidth-picwh-spc, spc, picwh, picwh);
  ftx.setsize(  spc, spf, picwh, picfh);
//  fty.setsize(  spf, spf, picwh, picfh);
  fty.setsize(  clientwidth-picwh-spc, spf, picwh, picfh);

  panw:=clientwidth-4*spc-2*picwh;
  panh:=(picwh-2*spc) div 3;
//  spp:=3*spc+2*picwh;
  spp:=spf;
    grw:=(panw-5*pspc) div 4;
    grh:=(panh-5*pspc) div 4;
    if grh > 36 then grh:=36;
    for i:=0 to 3 do begin grx[i]:=i*(pspc+grw)+pspc; gry[i]:=i*(pspc+grh)+pspc; end;
    grh:=21;

  panparam.setbounds (spp, spc      , panw, panh);
    labturns.setbounds(grx[0], gry[0]+2, grw, grh);
    comturns.setbounds(grx[1], gry[0], grw+15, grh);
    labdone.setbounds (grx[2]+15, gry[0]+2, grw-15, grh);
    labt.setbounds    (grx[3], gry[0]+2, grw, grh);
    labax.setbounds   (grx[0], gry[1]+2, grw, grh);
    edixaper.setbounds(grx[1], gry[1], grw, grh);
    labay.setbounds   (grx[2], gry[1]+2, grw, grh);
    ediyaper.setbounds(grx[3], gry[1], grw, grh);
{
    cbxelaper.setbounds(grx[0], gry[2], round(grw*2.5), grh);
    labstartpos.setbounds((grx[3]+grx[2])div 2 ,gry[2]+3,round(1.5*grw),grh);
    edistartpos.setbounds(grx[3],gry[3],grw,grh);
}
    cbxelaper.setbounds(grx[1], gry[2]-2, grw, grh);
    labelaper1.setbounds(grx[1], gry[2]+18, grw, 13);
    labelaper2.setbounds(grx[1], gry[2]+32, grw, 13);
    labstartpos.setbounds(grx[2],gry[2]+3,round(1.5*grw),grh);
    edistartpos.setbounds(grx[2],gry[3],grw,grh);
    butT6.setbounds(grx[3],gry[3],grw, grh);

  panctrl.setbounds  (spp, spc+panh+spc, panw, panh);
    labcoord.setbounds(grx[0], gry[0]+2, grw, grh);
    butBeam.setbounds (grx[1], gry[0]   , grw, grh);
    labdpp.setbounds  (grx[2], gry[0]+2, grw, grh);
    edidpp.setbounds  (grx[3], gry[0], grw, grh);
    labx.setbounds    (grx[0], gry[1]+2, grw, grh);
    edixini.setbounds (grx[1], gry[1], grw, grh);
    laby.setbounds    (grx[2], gry[1]+2, grw, grh);
    ediyini.setbounds (grx[3], gry[1], grw, grh);
    labpx.setbounds   (grx[0], gry[2]+2, grw, grh);
    edipxini.setbounds(grx[1], gry[2], grw, grh);
    labpy.setbounds   (grx[2], gry[2]+2, grw, grh);
    edipyini.setbounds(grx[3], gry[2], grw, grh);
    butrun.setbounds  (grx[0], gry[3], grw, grh);
    butmore.setbounds (grx[1], gry[3], grw, grh);
    butclear.setbounds(grx[2], gry[3], grw, grh);
    butexit.setbounds (grx[3], gry[3], grw, grh);

  panBeam.setbounds(spp, spc+2*panh+2*spc, panw, panh);
    labBeamBeta.setbounds(grx[0], gry[0]+2, grw, grh);
    labBeamAlfa.setbounds(grx[0], gry[1]+2, grw, grh);
    labBeamEmit.setbounds(grx[0], gry[2]+2, grw, grh);
    labBeamNpar.setbounds(grx[0], gry[3]+2, grw, grh);
    ediBeamBeta.setbounds(grx[1], gry[0], grw, grh);
    ediBeamAlfa.setbounds(grx[1], gry[1], grw, grh);
    ediBeamEmit.setbounds(grx[1], gry[2], grw, grh);
    ediBeamNpar.setbounds(grx[1], gry[3], grw, grh);
    butBeamXY.setbounds  (grx[2], gry[0], grw, grh);
    butBeamShow.setbounds(grx[2], gry[1], grw, grh);
    butBeamRun.setbounds(grx[2], gry[2], grw, grh);
    butBeamBreak.setbounds(grx[2], gry[3], grw, grh);
    labBeamNshow.setbounds(grx[3], gry[2]+2, grw, grh);
    ediBeamNshow.setbounds(grx[3], gry[3], grw, grh);

  panTush.setbounds (spp, spc+2*panh+2*spc, panw, panh);
    labtush.setbounds  (grx[0], gry[0]+2, grw*3, grh);
    labsteps.setbounds (grx[0], gry[1]+2, grw, grh);
    edisteps.setbounds (grx[1], gry[1], grw, grh);
    labtprog.setbounds (grx[1], gry[2], 2*grw, grh);
    tsplotbut.setbounds (grx[2], gry[1], 2*grw+pspc, grh );
    buttush.setbounds  (grx[0], gry[3], grw, grh);
    butbreak.setbounds  (grx[1], gry[3], grw, grh);
    butexport.setbounds (grx[2], gry[3], grw, grh);
    buttxt.setbounds (grx[3], gry[3], grw, grh);

  grh:=(picfh-6*pspc) div 5;
  if grh > 24 then grh:=24;
  for i:=0 to 4 do begin gry[i]:=i*(pspc+grh)+pspc; end;

  butParam.setbounds (spp+grx[2], spf-2, grw*2, grh);
  labParam.setbounds (spp+grx[0], spf+2, grw*2, grh);

//  panRes.setbounds   (spp, spf, panw, picfh); //same pos as panFFT
  panRes.setbounds   (spp, spf+grh, panw, picfh-grh); //same pos as panFFT
//    butParam.setbounds (grx[3], gry[0], grw, grh);
    resgrid.setbounds (grx[0], gry[0], panw-2*pspc, picfh-3*pspc-grh);
    with resgrid do begin
      rgwid:=panw-2*pspc-5*GridLineWidth-30;
      ColWidths[0]:=20;
      ColWidths[1]:=trunc(0.5*rgwid)-1;
      ColWidths[2]:=trunc(0.25*rgwid)-1;
      ColWidths[3]:=trunc(0.25*rgwid)-1;
    end;

//    panFFT.setbounds   (spp, spf, panw, picfh);
    panFFT.setbounds   (spp, spf+grh, panw, picfh-grh);
//    labParam.setbounds   (grx[0], gry[0]+2, grw*3, grh);
    labtune.setbounds    (grx[0], gry[0]+2, grw*3, grh);
    editune.setbounds    (grx[3], gry[0], grw, grh);
    labpident.setbounds  (grx[0], gry[1]+2, grw*3, grh);
    edipident.setbounds  (grx[3], gry[1], grw, grh);
    labrelf.setbounds    (grx[0], gry[2]+2, grw*3, grh);
    edirelf.setbounds    (grx[3], gry[2], grw, grh);
    labdisplay.setbounds (grx[0], gry[3]+2, grw*3, grh);
    edidisplay.setbounds (grx[3], gry[3], grw, grh);

  clientheight:=3*spc+picwh+picfh;
  PSInit;

end;

{procedure Ttrackp.setLabRes(x0, y0, a,b,c: integer);
var
  x:integer;
begin
  x:=x0;
  if (a>0) then begin
    labResA.caption:=InttoStr(a);
    labResA.left:=x; labResA.top:=y0;
    Inc(x,labResA.width);
    labResQx.left:=x; labResQx.top:=y0;
    Inc(x,labResQx.width);
  end;
  if (b<>0) then begin
    if (b<0) then labRespm.caption:=' - '
    else if (a>0) then labRespm.caption:=' + '
    else labRespm.caption:='';
    labRespm.Left:=x; labRespm.Top:=y0;
    Inc(x,labRespm.Width);
    labResB.caption:=InttoStr(abs(b));
    labResB.left:=x; labResB.Top:=y0;
    Inc(x,labResB.width);
    labResQy.left:=x; labResQy.top:=y0;
    Inc(x,labResQy.width);
  end;
  labReseq.left:=x; labReseq.top:=y0;
  Inc(x,labReseq.width);
  labResC.caption:=InttoStr(c);
  labResC.left:=x; labResC.top:=y0;
end;
}

procedure Ttrackp.Exit;
begin
  tuneplothandle.close;
  dqx:=nil; dqy:=nil; tjx:=nil; tjy:=nil;
  TrackExit;
end;

procedure Ttrackp.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Exit;
end;

procedure Ttrackp.butexitClick(Sender: TObject);
begin
  DefSet('trackp/texp',Round(Log2(Nturns))-Round(Log2(minturns)));
  DefSet('trackp/delq',deltune);
  DefSet('trackp/pid',pident);
  DefSet('trackp/dthr',dthresh);
  DefSet('trackp/relf',relfilter);
  DefSet('trackp/ntush',ntush);
  DefSet('trackp/aperx',ApertureX);
  DefSet('trackp/apery',ApertureY);
  DefSet('trackp/bbetx',rBeamBetaX);
  DefSet('trackp/balfx',rBeamAlfaX);
  DefSet('trackp/bemix',rBeamEmitX);
  DefSet('trackp/bbety',rBeamBetaY);
  DefSet('trackp/balfy',rBeamAlfaY);
  DefSet('trackp/bemiy',rBeamEmitY);
  DefSet('trackp/bnpar',rBeamNpar);
  Close; // calls FormClose
  TrackP:=nil;
  Release;
end;

procedure Ttrackp.comTurnsChange(Sender: TObject);
begin
  Nturns:=Round(PowI(2,(comTurns.ItemIndex+Round(Log2(minturns)))));
end;

procedure Ttrackp.FormResize(Sender: TObject);
begin
  ResizeAll;
end;

procedure Ttrackp.butclearClick(Sender: TObject);
begin
  PSInit;
  TunePlotHandle.Refresh;
end;

procedure Ttrackp.cbxElaperClick(Sender: TObject);
begin
  if cbxElaper.checked then begin
    edixaper.Enabled:=false;
    ediyaper.Enabled:=false;
  end else begin
    edixaper.Enabled:=true;
    ediyaper.Enabled:=true;
    TEReadVal(edixaper,ApertureX, edwid, eddec);
    TEReadVal(ediyaper,ApertureY, edwid, eddec);
  end;
  Acceptances(GeoAccX, GeoAccY, ApertureX, ApertureY, dpp, cbxElaper.checked);
  PSInit;
end;

procedure TtrackP.UpdateApertures;
begin
  edixaper.Text:=FtoS(ApertureX, edwid, eddec);
  ediyaper.Text:=FtoS(ApertureY, edwid, eddec);
  Acceptances(GeoAccX, GeoAccY, ApertureX, ApertureY, dpp, cbxElaper.checked);
  PSInit;
end;

// general handler for keypress events on all edit fields
procedure Ttrackp.ediKeyPress(Sender: TObject; var Key: Char);
var
  kv: real;
  edi: TEdit;
begin
  edi := Sender as TEdit;
// successful reading number from edi will give value kv and set upflag true
  if TEKeyVal(edi, Key, kv, edwid, eddec) then if(Key=#0 ) then EdiAction(edi, kv);
end;

procedure Ttrackp.ediExit(Sender: TObject);
var
  kv: real;
  edi: TEdit;
begin
  edi := Sender as TEdit;
  if TEReadVal(edi, kv, edwid, eddec) then EdiAction(edi, kv);
end;

{common handler for all edit fields [to keep code compact]:
- dpp change causes reinit, incl. apertures and tracking matrix
- aper changes cause only new apertures
- ini val changes have no effect, becuas fields are read when pressing run button
  only, but are included here only to ensure valid numerical formats}
procedure Ttrackp.ediAction(edi:TEdit; kv: real);
begin
 if edi=edidpp then begin
    dpp:=kv/100.0;
    if Initdpp(dpp, GeoAccX, GeoAccY, ApertureX, ApertureY, startPosition, cbxElaper.Checked, true)
    then begin MessageDlg(('Closed orbit or periodic solution not found.'+
      'Momentum deviation of dp/p ='+ftos(kv,edwid,eddec)+' % is too large.  '+
      'Try another value or track anyway using dp/p=0 acceptances.'),
      mtWarning, [mbOK],0);
      setfocus;
    end;
    PSInit;
  end else if edi=edixaper then begin
    ApertureX:=kv;
    UpdateApertures;
  end else if edi=ediyaper then begin
    ApertureY:=kv;
    UpdateApertures;
  end else if edi=edistartpos then begin
    if kv<0 then kv:=0.0;
    if kv>Beam.Circ/Glob.NPer then kv:=Beam.Circ/Glob.NPer;
    startPosition:=kv;
    edistartpos.text:=FtoS(startPosition,8,3);
    Initdpp(dpp, GeoAccX, GeoAccY, ApertureX, ApertureY, startPosition, cbxElaper.checked, true);
    PSInit;
  end else if edi=ediBeamBeta then begin
    if rBeamXY then rBeamBetaY:=abs(kv) else rBeamBetaX:=abs(kv);
    ediBeamBeta.text:=FtoS(abs(kv),edwid,eddec);
  end else if edi=ediBeamAlfa then begin
    if rBeamXY then rBeamAlfaY:=kv else rBeamAlfaX:=kv;
  end else if edi=ediBeamEmit then begin
    if rBeamXY then rBeamEmitY:=abs(kv) else rBeamEmitX:=abs(kv);
    ediBeamEmit.text:=FtoS(abs(kv),edwid,eddec);
  end;
end;

procedure Ttrackp.pPaint(Sender: TObject);
begin
  PSInit;
end;

{track Nturns turns}
function Ttrackp.Track: boolean;
var
  Lost: boolean;
  kturns: integer;
begin
  kturns:=0;
  repeat
//writeln(diagfil, kturns, '  ', xtrack[1], ' ', xtrack[2], ' ', xtrack[3], ' ', xtrack[4], ' ', xtrack[5], ' ', nphi_sy);
    inc(kturns);
    if TrackMode6 then Lost:=Oneturn_S(xtrack) else Lost:=Oneturn(xtrack);
    savePStrackData(kturns, xtrack);
    if Lost then begin
      labt.font.color:=clRed;
      Labt.caption:=inttostr(iturns);
    end else begin
      psx.plot.Symbol(xtrack[1]*1000, xtrack[2]*1000);
      psy.plot.Symbol(xtrack[3]*1000, xtrack[4]*1000);
      Labt.caption:=inttostr(kturns+iturns);
    end;
//    TimeTracked:=TimeTracked+TimeRevol;

    // to do: calc real track time (element length) not only turns!!!

    Application.ProcessMessages;
  until (kturns = Nturns) or Lost or TushBreak;
  Inc(iturns,kturns);
  Track:=Lost;
end;

function Ttrackp.TrackBeam: boolean;
var
  AllLost: boolean;
  i, Npar, kturns: integer;
  Timeturns: real;
begin
  kturns:=0;
  AllLost:=false;
  Npar:=Length(parLost);
  for i:=0 to High(parLost) do if parLost[i] then Dec(NPar);
  TimeTurns:=0;
  repeat
    inc(kturns);
    for i:=0 to High(Particle) do if not parLost[i] then begin
      xtrack:=Particle[i];
      Timetracked:=TimeTurns; // set for each particle because oneturn counts up again
      parLost[i]:=Oneturn(xtrack);
      if parLost[i] then begin
        Dec(Npar);
      end else begin
        Particle[i]:=xtrack;
      end;
    end;
    if Npar = Length(parLost) then labt.font.color:=clGreen else labt.font.color:=clRed;
    if (kturns+iturns) <= nShowFirstTurns then begin
      psx.plot.SetSymbol( 1, 1, dimcol(clBlue, clYellow, (kturns+iturns)/(nshowfirstturns+1)));
      psy.plot.SetSymbol( 1, 1, dimcol(clBlue, clYellow, (kturns+iturns)/(nshowfirstturns+1)));
      for i:=0 to High(Particle) do if not parLost[i] then begin
        psx.plot.Symbol( particle[i,1]*1000, particle[i,2]*1000);
        psy.plot.Symbol( particle[i,3]*1000, particle[i,4]*1000);
      end;
    end;
    Timeturns:=TimeTurns+TimeRevol;
    AllLost:=(Npar=0);
    Labt.caption:=inttostr(iturns+kturns)+' '+inttostr(Npar);
    Application.ProcessMessages;
  until (kturns = Nturns) or AllLost or BeamBreak;
  Inc(iturns,kturns);
  TrackBeam:=AllLost;
end;

procedure Ttrackp.butrunClick(Sender: TObject);
var
  amp, ampx, ampy, kap: real;
{test
  i, j, k: word;
  cx0, cxp0, cy0, cyp0,  cx1, cxp1, cy1, cyp1, qx, qy, dq: double;
  bx, ax, by, ay: array of double;
test}
begin
// result should never become false, because edit fields are checked on input
  if  TEReadVal(edixini,  xini,  edwid, eddec)
  and TEReadVal(edipxini, pxini, edwid, eddec)
  and TEReadVal(ediyini,  yini,  edwid, eddec)
  and TEReadVal(edipyini, pyini, edwid, eddec)
  then begin
    butmore.enabled:=false;
  // turn from mm, mrad to m, rad :
    xtrack[1]:=xini/1000; xtrack[2]:=pxini/1000;
    xtrack[3]:=yini/1000; xtrack[4]:=pyini/1000;
    xtrack[5]:=dpp;
    nphi_sy:=0;
    with Opstart do begin
      ampx:=(1+sqr(alfa))/beta*sqr(xtrack[1]-orb[1])+
        2*alfa*(xtrack[1]-orb[1])*(xtrack[2]-orb[2])+beta*sqr(xtrack[2]-orb[2]);
      ampy:=(1+sqr(alfb))/betb*sqr(xtrack[3]-orb[3])+
        2*alfb*(xtrack[3]-orb[3])*(xtrack[4]-orb[4])+betb*sqr(xtrack[4]-orb[4]);
      kap:=ampy/(ampy+ampx+1e-12); // avoid crash for 0/0
      if not cbxElaper.checked then begin
        //if larger apertures are used, still plot the ellipse for phys aper 13.1.2021
        amp:=AmpKappa(kap, ApertureX, ApertureY, dpp, true);
        if amp > 0 then begin
          ampx:=(1-kap)*amp; ampy:=kap*amp;
          psx.plot.Ellipse(beta, alfa, ampx, orb[1], orb[2], 1000, 1000, clGreen);
          psy.plot.Ellipse(betb, alfb, ampy, orb[3], orb[4], 1000, 1000, clGreen);
        end;
      end;
      amp:=AmpKappa(kap, ApertureX, ApertureY, dpp, cbxElaper.checked);
      ampx:=(1-kap)*amp; ampy:=kap*amp;
      psx.plot.Ellipse(beta, alfa, ampx, orb[1], orb[2], 1000, 1000, clGray);
      psy.plot.Ellipse(betb, alfb, ampy, orb[3], orb[4], 1000, 1000, clGray);
    end;
  // start the tracking here:
    labt.font.color:=clGreen;
    ftx.plot.clear(clWhite); fty.plot.clear(clWhite);
    psx.plot.SetSymbol( 4, 1, clRed); // MU only
    psx.plot.Symbol( xtrack[1]*1000, xtrack[2]*1000);
    psx.plot.SetSymbol( 1, 1, clBlue);
    psy.plot.SetSymbol( 1, 1, clred);
    psy.plot.Symbol( xtrack[3]*1000, xtrack[4]*1000);
    iturns:=0;
    TimeTracked:=0;
    if not Track then begin
      butmore.enabled:=true;
      Spectrum;
      TunePlot.AddTunePoint(TuneR[1],TuneR[2],1,1,false);
    end;
    psx.unfreezeEdit;
    psy.unfreezeEdit;
  end;
end;

procedure Ttrackp.butmoreClick(Sender: TObject);
begin
  if Track then begin
    butmore.enabled:=false;
  end else begin
    Spectrum;
  end;
end;

procedure Ttrackp.Spectrum;
begin
// apply sine window, do the fft, get amplitudes (power spectrum)
  SineWindow (Nturns);
  TwoFFT   (Nturns);
  FFTtoAmp (Nturns);
  FFTplot;
end;


procedure Ttrackp.FFTplot;
var
  nH, i, ii, ixy, ix, iy: integer;
  fmin, fmax: double;
  dox, doy: boolean;

  procedure plotspectrum(ft: TFigure; ixy:integer);
  var
    i: integer;
    fraclintune, ppx,ppy: double;
  begin
    with ft.plot do begin
      for i:=0 to nH do begin
       ppx:=i/Nturns;
        ppy:=getFT(ixy,i);
        if (ppy > dthresh) then begin
          ppy:=Log10(ppy);
          Line(ppx,fmin,ppx,ppy);
        end;
      end;
      fracLinTune:=Frac(LinTune[ixy]);
      if (fracLinTune>0.5) then fracLinTune:=1-fracLinTune;
      setcolor(clBlack); setstyle(psDot);
      Line(fracLinTune,fmin,fracLinTune,fmax);
      setstyle(psSolid);
    end;
  end;

  procedure plotpeaks(ft: TFigure; ixy:integer);
  var
    i: integer;
    ppy: double;
    c: TColor;
  begin
    with ft.plot do begin
      c:=GetColor;
      if Npeaks[ixy]>0 then begin
        setcolor(clBlack);
        setstyle(psDot);
        ppy:=Log10(Relfilter*Peak[ixy,1]);
        Line(0, ppy,0.5, ppy);
        setstyle(psSolid);
      end;
      setcolor(c);
      for i:=1 to Npeaks[ixy] do begin
        if (Peak[ixy,i] > dthresh) then begin
          Line(Tune[ixy,i],fmin, Tune[ixy,i], Log10(Peak[ixy,i]));
          TextAlign (PeakChar[ixy,i],Tune[ixy,i],Log10(Peak[ixy,i]),0,1,c);
        end;
      end;
    end;
  end;

begin

// guess the peaks
  FindPeaks (Nturns, relfilter);
  ResoGuess (Nturns, deltune, pident);

// ???? no spektrum / no lines in table !!!

  //merge sorted lists by descending amplitudes when filling the grid
  resgrid.RowCount:=Npeaks[1]+Npeaks[2]+1;
  if resgrid.RowCount > 1 then begin
    ix:=1; iy:=1; i:=0;
    repeat
      doy:= (ix > Npeaks[1]); // finished writing x -> write left y
      dox:= (iy > Npeaks[2]); // and vice versa
    // both true: finished, one true: write , none true: find larger peak
      if not (dox or doy) then begin //none case
        dox:= (peak[1,ix]>peak[2,iy]); doy:=not dox;
      end;
      if dox and not doy then begin
        ixy:=1; ii:=ix; inc(ix); inc(i);
      end;
      if doy and not dox then begin
        ixy:=2; ii:=iy; inc(iy); inc(i);
      end;
  {    dox:= (peak[1,ix]>peak[2,iy]);
    doy:= (ix = Npeaks[1]) or (not dox);
    dox:= (iy = Npeaks[2]) or dox;

    if dox and not doy then begin
      ixy:=1; ii:=ix; inc(ix); inc(i);
    end;
    if doy and not dox then begin
      ixy:=2; ii:=iy; inc(iy); inc(i);
    end;
}
      resGridXY[1,i]:=ixy;
      resGridXY[2,i]:=ResTyp(kpar[ixy,ii], kpbr[ixy,ii], kpcr[ixy,ii]);
      resgrid.Cells[0,i]:=PeakChar[ixy,ii];
      resgrid.Cells[1,i]:=ResLabel [ixy,ii];
      resgrid.Cells[2,i]:=FtoS(tune[ixy,ii],6,4);
      resgrid.Cells[3,i]:=FtoS(peak[ixy,ii],6,3);
//      writeln(i,' ',ix,' ',iy, ' ',Npeaks[1], ' ',Npeaks[2]);

    until dox and doy;
  end;

  nH:=Nturns div 2;
  fmax:=getFTmax(nH)*10;
  if (fmax > dthresh) then begin
    fmax:=Log10(fmax);
    fmin:=Log10(dthresh);

    with ftx do begin
      plot.SetColor(clblack);
      Init(0,fmin,0.5,fmax, 1, 0,'frac(Qx)','log(Amp)',0,false);
      plot.Setcolor(dimcol(clblue,clwhite,0.3));
      plotSpectrum(ftx,1);
      plot.SetColor(clBlue);
      plotPeaks(ftx,1);
    end;

    with fty do begin
      plot.SetColor(clblack);
      Init(0,fmin,0.5,fmax, 1, 0,'frac(Qy)','log(Amp)',0,false);
      plot.Setcolor(dimcol(clred, clwhite, 0.3));
      plotSpectrum(fty,2);
      plot.SetColor(clRed);
      plotPeaks(fty,2);
    end;

  end;
end;

procedure Ttrackp.butParamClick(Sender: TObject);
begin
  if PanFFT.Visible then begin //fft parameters are visible and to be updated
    if TEReadVal(editune,  deltune,  7, 4)
    and TEREadVal(edipident, pident, 7,4)
    and TEREadVal(edirelf, relfilter, -2,2)
    and TEReadVal(edidisplay, dthresh, -2,2) then begin
      if dthresh < 1e-20 then begin
        dthresh:=1e-20;
        edidisplay.text:=FtoS(dthresh,-2,2);
      end;
      PanFFT.Visible:=false;
      PanRes.Visible:=true; //switch back to resonance panel
      labParam.Caption:='Resonance guess';
      butParam.Caption:='Parameters';
      FindPeaks(nturns, relfilter);
      FFTplot;
    end; //else do nothing, conditions to switch back not fulfilled
  end

  else if PanRes.Visible then begin // if resonance panel visible, switch to parameters
    PanFFT.Visible:=true;
    PanRes.Visible:=false;
    labParam.Caption:='FFT parameters';
    butParam.Caption:='Update';
  end;

end;


procedure Ttrackp.resgridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  with resgrid.Canvas do begin
    if ACol>0 then Font.Color:=clBlack else begin
      case resgridXY[1,ARow] of
        1: Font.Color:=clBlue;
        2: Font.Color:=clRed;
        else Font.Color:=clBlack;
      end;
    end;
    case resgridXY[2,ARow] of
      0: Font.Style:= [fsBold];
      1: Font.Style :=[fsItalic,fsBold];
      2: Font.Style :=[ ];
      3: Font.Style :=[fsItalic];
    end;
    TextOut(Rect.Left+2,Rect.Top+2, resgrid.Cells[ACol, ARow]);
  end;
end;


procedure Ttrackp.rbpingClick(Sender: TObject);
begin
  TushPlot(tsplotmode,0);
end;

procedure Ttrackp.rbspecClick(Sender: TObject);
begin
  TushPlot(tsplotmode,0);
end;

procedure Ttrackp.ediIKeyPress(Sender: TObject; var Key: Char);
var
  kv: real;
  edi: TEdit;
begin
  edi := Sender as TEdit;
  TEKeyVal(edi, Key, kv, 4, 0);
end;

procedure Ttrackp.ediIExit(Sender: TObject);
var
  kv: real;
  edi: TEdit;
begin
  edi := Sender as TEdit;
  TEReadVal(edi, kv, 4, 0);
end;

procedure Ttrackp.butTushClick(Sender: TObject);
label 99;
var
  xping, yping, temp: real;
  ntu, iq, nq, itu, ico, k, outflag: integer;
  OriginalTune, sign, {intTune,} fracTune, changeTune: TwoTuneType;
  tempTune, mirrTune, kap, amp, ampx, ampy, ampphys: real;
const
//  xcoup: array[0..2] of real = (1.0, 1.0, 1e-4);
//  ycoup: array[0..2] of real = (1e-4, 1.0, 1.0);
  xcoup: array[0..2] of real = (1.0, 1.0, 1e-3);
  ycoup: array[0..2] of real = (1e-3, 1.0, 1.0);
  tinfo: array[0..2] of string_4 =('Qxx ','Qxy ','Qyy ');
begin
  if  TEReadVal(edisteps, temp, 4, 0) then begin
    TushBreak:=False;
    ButBreak.enabled:=True;
    ntush:=round(temp);
    butmore.enabled:=false;
{ save the lattice tune that is in LinTune and use LinTune
 for tracking the tune shifts, because LinTune is used for guessing
 the fundamental by ResoGuess }
    OriginalTune:=LinTune;
{*
    for k:=1 to 2 do begin
      fracTune[k]:=Frac(OriginalTune[k]);
      if (fracTune[k]>0.5) then begin
        fracTune[k]:=1-fracTune[k];
        sign[k]:=-1;
      end else sign[k]:=1;
    end;
}
    nq:=3*(ntush+1);
    setlength(dqx,nq); setlength(dqy,nq);
    setlength(tjx,nq); setlength(tjy,nq);
    mindqx:=0.0; maxdqx:=0.0;  mindqy:=0.0; maxdqy:=0.0;
    tjxmax:=0; tjymax:=0;
    for ico:=0 to 2 do begin
//*
      for k:=1 to 2 do begin
        fracTune[k]:=Frac(OriginalTune[k]);
//        intTune[k]:=Int(OriginalTune[k]);
        if (fracTune[k]>0.5) then begin
          fracTune[k]:=1-fracTune[k];
          sign[k]:=-1;
        end else sign[k]:=1;
        LinTune[k]:=OriginalTune[k] ;
        changeTune[k]:=0;
      end;

// reduce points on last run if vertical acceptance much lower than
// horizontal (light source!), otherwise too boring...
      ntu:=ntush;
      if (ico=2) and (GeoAccy < 0.3* GeoAccX) then ntu:=round(ntu*sqrt(GeoAccY/GeoAccX));
      PSInit;
//show max amplitude for coupled
      kap:=ycoup[ico]*geoAccY/(ycoup[ico]*GeoAccY+xcoup[ico]*GeoAccX);
      ampphys:=1; // 1m
      if not cbxElaper.checked then begin
        //if larger apertures are used, still plot the ellipse for phys aper 13.1.2021
        //(in principole I should use another kappa with and without aperture limits)
        ampphys:=AmpKappa(kap, ApertureX, ApertureY, dpp, true);
        if ampphys > 0 then begin
          ampx:=(1-kap)*ampphys; ampy:=kap*ampphys;
          with Opstart do begin
            psx.plot.Ellipse(beta, alfa, ampx, orb[1], orb[2], 1000, 1000, clGreen);
            psy.plot.Ellipse(betb, alfb, ampy, orb[3], orb[4], 1000, 1000, clGreen);
          end;
        end;
      end;
      amp:=AmpKappa(kap, ApertureX, ApertureY, dpp, cbxElaper.checked);
      ampx:=(1-kap)*amp; ampy:=kap*amp;
      with Opstart do begin
        psx.plot.Ellipse(beta, alfa, ampx, orb[1], orb[2], 1000, 1000, clGray);
        psy.plot.Ellipse(betb, alfb, ampy, orb[3], orb[4], 1000, 1000, clGray);
      end;
      iq:=ico*(ntush+1); dqx[iq]:=0.0; dqy[iq]:=0.0; tjx[iq]:=0.0; tjy[iq]:=0.0;
      for k:=1 to 2 do LinTune:=OriginalTune;
      for itu:=1 to ntu do begin
        labtprog.caption:=tinfo[ico]+inttostr(itu)+'/'+inttostr(ntu);
        iq:=ico*(ntush+1)+itu;
        tjx[iq]:=ampx*itu/ntu;
        tjy[iq]:=ampy*itu/ntu;
//        tjx[iq]:=xcoup[ico]*GeoAccX*itu/ntu;
//        tjy[iq]:=ycoup[ico]*GeoAccY*itu/ntu;
        if amp*itu/ntu > ampphys then outflag:=-1 else outflag:=1; //out of phys ap limit
//Opamessage(0,ftos(amp*itu/ntu,10,7)+' '+ftos(ampphys,10,7));
        xping:=sqrt(tjx[iq]/OpStart.beta);
        yping:=sqrt(tjy[iq]/OpStart.betb);
        xtrack[1]:=1e-8; xtrack[2]:=xping;
        xtrack[3]:=1e-8; xtrack[4]:=yping;
        xtrack[5]:=dpp;
        for k:=1 to 4 do xtrack[k]:=xtrack[k]+OpStart.Orb[k];
        edixini.Text :=FtoS(xtrack[1]*1000,edwid,eddec);
        edipxini.Text:=FtoS(xtrack[2]*1000,edwid,eddec);
        ediyini.Text :=FtoS(xtrack[3]*1000,edwid,eddec);
        edipyini.Text:=FtoS(xtrack[4]*1000,edwid,eddec);
        iturns:=0;
        labt.font.color:=clGreen;
        psx.plot.SetSymbol( 1, 1, clBlue);
        psx.plot.Symbol( xtrack[1]*1000, xtrack[2]*1000);
        psy.plot.SetSymbol( 1, 1, clred);
        psy.plot.Symbol( xtrack[3]*1000, xtrack[4]*1000);
        if not Track  then begin
          ftx.plot.clear(clWhite); fty.plot.clear(clWhite);
          Spectrum;
//*          TunePlot.AddTushPoint(ico,Tuner[1],Tuner[2]);
//*          for k:=1 to 2 do LinTune[k]:=round(originaltune[k])+sign[k]*FundaTune[k];
          for k:=1 to 2 do begin
            tempTune:=round(Lintune[k])+sign[k]*FundaTune[k];
            if abs(FundaTune[k]-0.5) < 0.1 then begin // near half integer
            mirrTune:=2*Int(tempTune)+1-tempTune; // tune + mirror = 2 *int(tune)+1
              if abs(mirrTune-LinTune[k]-changeTune[k]) < abs(tempTune-LinTune[k]-changeTune[k]) then begin // mirr tune fits besser to prediction
                tempTune:=mirrTune;
                sign[k]:=-sign[k];
                fracTune[k]:=1-fracTune[k];
              end;
{not so trivial, since particles get trapped on resonance, so change=0 for a while and direction unclear

           end else if abs(FundaTune[k])<0.1 then begin // near integer
              mirrTune:=2*Int(tempTune)-2*sign[k]-tempTune; // e.g. 10.1/9.9 or 10.9/11.1
              if abs(mirrTune-LinTune[k]-changeTune[k]) < abs(tempTune-LinTune[k]-changeTune[k]) then begin // mirr tune fits besser to prediction
                tempTune:=mirrTune;
                sign[k]:=-sign[k];
                fracTune[k]:=1-fracTune[k];
              end;
}
            end;
            changeTune[k]:=tempTune-LinTune[k];
            LinTune[k]:=tempTune;
          end;
          TunePlot.AddTushPoint((ico+1)*outflag,LinTune[1],LinTune[2]);
          //was guessed as fundamental
          dqx[iq]:=sign[1]*(FundaTune[1]-FracTune[1]);
          dqy[iq]:=sign[2]*(FundaTune[2]-FracTune[2]);
          if dqx[iq] < mindqx then mindqx:=dqx[iq];
          if dqx[iq] > maxdqx then maxdqx:=dqx[iq];
          if dqy[iq] < mindqy then mindqy:=dqy[iq];
          if dqy[iq] > maxdqy then maxdqy:=dqy[iq];
          if tjx[iq] > tjxmax then tjxmax:=tjx[iq];
          if tjy[iq] > tjymax then tjymax:=tjy[iq];
          if TushBreak then goto 99;
        end else begin
          dqx[iq]:=999; dqy[iq]:=999;
        end
      end;
// set unused tunes to invalid, not zero
      for itu:=ntu+1 to ntush do begin
        iq:=ico*(ntush+1)+itu;
        dqx[iq]:=999; dqy[iq]:=999;
      end;
    end;
{qx, qy contain each 3x(ntush+1) values for Jx/0, Jx/Jy, 0/Jy
+ the same again for theoretical values if available}

// showtheoretical tunes if data available from chroma
    if status.tuneshifts then begin
      setlength(dqx,2*nq); setlength(dqy,2*nq);
      for ico:=0 to 2 do begin
        for itu:=0 to ntush do begin
          iq:=ico*(ntush+1)+itu;
          dqx[nq+iq]:=snapsave.qxx*tjx[iq]+snapsave.qxy*tjy[iq];
          dqy[nq+iq]:=snapsave.qxy*tjx[iq]+snapsave.qyy*tjy[iq];
        end;
      end;
    end;

{
    if status.tuneshifts then writeln(diagfil, snapsave.qxx, snapsave.qxy, snapsave.qyy);
    for ico:=0 to 2 do for k:=0 to ntush do begin
      iq:=ico*(ntush+1)+k;
      writeln(diagfil, ico,' ',k,' ',iq,' ', tjx[iq],tjy[iq],dqx[iq],dqy[iq], dqx[nq+iq], dqy[nq+iq]);
    end;
}

// use same max for both:
    if tjxmax > tjymax then tjymax:=tjxmax;
    if tjymax > tjxmax then tjxmax:=tjymax;


    TushPlot(tsplotmode,0);

99: TushBreak:=false;
    ButBreak.enabled:=false;
    psx.unfreezeEdit;
    psy.unfreezeEdit;
    labtprog.caption:='';
    LinTune:=OriginalTune;
    butexport.Enabled:=True;
    buttxt.Enabled:=True;
  end;
end;

procedure Ttrackp.TushPlot (mode, doxy: integer);
//doxy 0 plot both 1 only x 2 only y
var
  fx, fy, rt: real;
  iq, nq: integer;

  procedure subplot(plot: Vplot; ic:integer; p, q :array of real; f,r:real);
  var
    t,tm:real;
    k:integer;
  begin
    plot.Symbol(0, 1e3*q[ic*(ntush+1)]);
    tm:=0;
    for k:=1 to ntush do begin
      iq:=ic*(ntush+1)+k;
      t:=powr(f*p[iq],r);
      if q[iq]<1 then begin
        plot.Symbol(t, 1e3*q[iq]);
        if q[iq-1]<1 then plot.Line(tm,1e3*q[iq-1],t,1e3*q[iq]);
      end;
      tm:=t;
    end;
    if status.tuneshifts then begin
      nq:=3*(ntush+1);
      tm:=0;
      plot.setStyle(psdot);
      for k:=1 to ntush do begin
        iq:=ic*(ntush+1)+k;
        t:=powr(f*p[iq],r);
        plot.Line(tm, 1e3*q[nq+iq-1],t,1e3*q[nq+iq]);
        tm:=t;
      end;
      plot.setStyle(pssolid);
    end;
  end;

begin
  if tjx<>nil then begin
    case mode of
      0: begin
        fx:=1e6; fy:=1e6; rt:=1;
      end;
      1: begin
        rt:=0.5;
        fx:=1e6/OpStart.beta;
        fy:=1e6/OpStart.betb;
       end;
      2: begin
        rt:=0.5;
        fx:=1e6*OpStart.beta;
        fy:=1e6*OpStart.betb;
       end;
    end;

    if doxy in [0,1] then with psx do begin
      plot.setcolor(clBlack);
      case mode of
        0: Init(0,1e3*mindqx, powr(fx*tjxmax,rt), 1e3*maxdqx, 1, 1, '2Jx/y [mm mrad]','dQx [1/1000]', 3,false);
        1: Init(0,1e3*mindqx, powr(fx*tjxmax,rt), 1e3*maxdqx, 1, 1, 'x/y-ping [mrad]','dQx [1/1000]', 3,false);
        2: Init(0,1e3*mindqx, powr(fx*tjxmax,rt), 1e3*maxdqx, 1, 1, 'x/y-position [mm]','dQx [1/1000]', 3,false);
      end;
      plot.SetSymbol( 3, 0, clBlue);
      subplot(plot,0,tjx,dqx,fx,rt);
      plot.SetSymbol( 3, 0, dimcol(clBlue, clRed, 0.7));
      subplot(plot,1,tjx,dqx,fx,rt);
      plot.SetSymbol( 3, 3, dimcol(clBlue, clRed, 0.3));
      subplot(plot,2,tjy,dqx,fy,rt);
    end;

    if doxy in [0,2] then with psy do begin
      plot.setcolor(clBlack);
      case mode of
        0: Init(0,1e3*mindqy, powr(fy*tjymax,rt), 1e3*maxdqy, 1, 1, '2Jy/x [mm mrad]','dQy [1/1000]', 3,false);
        1: Init(0,1e3*mindqy, powr(fy*tjymax,rt), 1e3*maxdqy, 1, 1, 'y/x-ping [mrad]','dQy [1/1000]', 3,false);
        2: Init(0,1e3*mindqy, powr(fy*tjymax,rt), 1e3*maxdqy, 1, 1, 'y/x-position [mm]','dQy [1/1000]', 3,false);
      end;
      plot.SetSymbol( 3, 3, clRed);
      subplot(plot,2,tjy,dqy,fy,rt);
      plot.SetSymbol( 3, 3, dimcol(clRed, clBlue, 0.7));
      subplot(plot,1,tjy,dqy,fy,rt);
      plot.SetSymbol( 3, 0, dimcol(clRed, clBlue, 0.3));
      subplot(plot,0,tjx,dqy,fx,rt);
    end;

  end;
end;

procedure Ttrackp.butBreakClick(Sender: TObject);
begin
  TushBreak:=True;
end;





procedure Ttrackp.butexportClick(Sender: TObject);
var
  errmsg1, errmsg2, epsfile1, epsfile2: string;
  fail: boolean;
begin
  epsfile1:=ExtractFileName(FileName);
  epsfile1:=work_dir+Copy(epsfile1,0,Pos('.',epsfile1)-1);
  epsfile2:=epsfile1+'_adts_y'+'.eps';
  epsfile1:=epsfile1+'_adts_x'+'.eps';
  psx.plot.PS_start(epsfile1,OPAversion, errmsg1);
  fail:=(length(errmsg1)>0);
  if not fail then begin
    TushPlot(tsplotmode,1);
    psx.plot.PS_stop;
  end;
  psy.plot.PS_start(epsfile2,OPAversion, errmsg2);
  fail:=fail or (length(errmsg2)>0);
  if not fail then begin
    TushPlot(tsplotmode,2);
    psy.plot.PS_stop;
  end;
  if fail
  then  MessageDlg('PS export failed: '+errmsg1+' '+errmsg2, MtError, [mbOK],0)
  else  MessageDlg('Graphics exported to '+sLineBreak+epsfile1+sLineBreak+epsfile2, MtInformation, [mbOK],0);
end;



procedure Ttrackp.buttxtClick(Sender: TObject);
var
  ic, k, iq: integer;
  mfname: string;
  outfi: textfile;
begin
  mfname:=ExtractFileName(FileName);
  mfname:=work_dir+Copy(mfname,0,Pos('.',mfname)-1);
//write plotted data to file
  mfname:=mfname+'_adts.txt';
  assignFile(outfi,mfname);
{$I-}
  rewrite(outfi);
{$I+}
  if IOResult =0 then begin
    writeln(outfi,'# amplitude dependant tune shifts');
    writeln(outfi,'# betas at trackpoint and tunes:');
    writeln(outfi, ftos(Opstart.beta,12,6), ' ',ftos(Opstart.betb,12,6),' ', ftos(LinTune[1],12,8),' ', ftos(LinTune[2],12,8));
    writeln(outfi,'# X-amp [rad m]   Y-amp [rad m]   dQx              dQy');
    for ic:=0 to 2 do begin
      writeln(outfi,exportcom[ic]);
      for k:=1 to ntush do begin
        iq:=ic*(ntush+1)+k;
        if dqx[iq]<1 then writeln(outfi, ftos(tjx[iq],-10,2), ' ',ftos(tjy[iq],-10,2),' ', ftos(dqx[iq],-10,2), ' ',ftos(dqy[iq],-10,2))
                     else writeln(outfi, ftos(tjx[iq],-10,2), ' ',ftos(tjy[iq],-10,2));
      end;
    end;
    CloseFile(outfi);
    MessageDlg('Data saved to text file '+mfname, MtInformation, [mbOK],0);
  end else begin
    OPALog(1,'could not write '+mfname);
  end;
end;

procedure Ttrackp.tsplotbutClick(Sender: TObject);
begin
  tsplotmode:=tsplotmode+1;
  if tsplotmode > 2 then tsplotmode:=0;
  case tsplotmode of
    0: tsplotbut.Caption:='   Amplitude   ';
    1: tsplotbut.Caption:=' Pinger [mrad] ';
    2: tsplotbut.Caption:=' Position [mm] ';
  end;
  TuShplot(tsplotmode,0);
end;

procedure Ttrackp.butBeamClick(Sender: TObject);
begin
  panBeam.visible:=not panBeam.Visible;
end;

procedure Ttrackp.ButBeamXYClick(Sender: TObject);
begin
  rBeamXY:=not rBeamXY;
  if rBeamXY then begin
    ButBeamXY.caption:='Y';
    ediBeamBeta.text:=FtoS(rBeamBetaY,edwid,eddec);
    ediBeamAlfa.text:=FtoS(rBeamAlfaY,edwid,eddec);
    ediBeamEmit.text:=FtoS(rBeamEmitY,edwid,eddec);
  end else begin
    ButBeamXY.caption:='X';
    ediBeamBeta.text:=FtoS(rBeamBetaX,edwid,eddec);
    ediBeamAlfa.text:=FtoS(rBeamAlfaX,edwid,eddec);
    ediBeamEmit.text:=FtoS(rBeamEmitX,edwid,eddec);
  end;
end;

procedure Ttrackp.StartEnsemble;
var
  temp, x, px, y, py, xi, yi, p, dp, sb, sa, se, b, a, e: real;
  n, ix, ip, i: integer;
begin
  TEReadVal(edixini,  x,  edwid, eddec); x:=x/1000;
  TEReadVal(edipxini, px, edwid, eddec); px:=px/1000;
  TEReadVal(ediyini,  y,  edwid, eddec); y:=y/1000;
  TEReadVal(edipyini, py, edwid, eddec); py:=py/1000;
  TEReadVal(ediBeamBeta, b, edwid, eddec);
  TEReadVal(ediBeamAlfa, a, edwid, eddec);
  TEReadVal(ediBeamEmit, e, edwid, eddec); e:=e*1E-9;
  TEReadVal(ediBeamNpar, temp, 4, 0); n:=round(temp);
  particle:=nil;
  parLost:=nil;
  if n > 0 then begin
    setLength(particle, n);
    setLength(parLost, n);
    for i:=0 to n-1 do begin
      particle[i,1]:=x;
      particle[i,2]:=px;
      particle[i,3]:=y;
      particle[i,4]:=py;
      particle[i,5]:=0; //preliminary
      parLost[i]:=false;
    end;
    if rBeamXY then ix:=3 else ix:=1; ip:=ix+1;
    dp:=2*Pi/n;
    sb:=Sqrt(abs(b));
    sa:=-a/sb;
    se:=Sqrt(abs(e));
    for i:=0 to n-1 do begin
      p := i*dp;
      xi:= se*Cos(p); yi:=se*Sin(p);
      particle[i,ix] :=  particle[i,ix] + sb*xi;
      particle[i,ip] :=  particle[i,ip]+ sa*xi+yi/sb;
    end;
    if rBeamXY then begin
      psy.plot.SetSymbol( 1, 1, clGreen);
      for i:=0 to n-1 do psy.plot.Symbol( particle[i,ix]*1000, particle[i,ip]*1000);
    end else begin
      psx.plot.SetSymbol( 1, 1, clGreen);
      for i:=0 to n-1 do psx.plot.Symbol( particle[i,ix]*1000, particle[i,ip]*1000);
    end;
  end;

end;

procedure Ttrackp.ButBeamShowClick(Sender: TObject);
begin
  StartEnsemble;
  ButBeamRun.Enabled:=true;
  ButBeamBreak.Enabled:=false;
  ButBeamRun.caption:='Run';
  iturns:=0;
  TimeTracked:=0;
end;

procedure Ttrackp.ButBeamRunClick(Sender: TObject);
var
  i: integer;
  temp: real;
begin
  ButBeamShow.enabled:=false;
  ButBeamBreak.enabled:=true;
  BeamBreak:=False;
  TEReadVal(ediBeamNshow, temp, 4, 0); nShowFirstTurns:=round(temp);
  if Length(Particle)>0 then begin
  // start the tracking here:
    labt.font.color:=clGreen;
    ftx.plot.clear(clWhite); fty.plot.clear(clWhite);
    psx.plot.SetSymbol( 1, 1, clSilver);
    psy.plot.SetSymbol( 1, 1, clSilver);
    if not TrackBeam then  ButBeamRun.caption:='More' else begin
      ButBeamRun.caption:='Run';
      ButBeamRun.enabled:=False;
    end;
    psx.unfreezeEdit;
    psy.unfreezeEdit;
    psx.plot.SetSymbol( 1, 1, clFuchsia);
    psy.plot.SetSymbol( 1, 1, clFuchsia);
    if not BeamBreak then begin
      for i:=0 to High(Particle) do if not parLost[i] then begin
        psx.plot.Symbol( particle[i,1]*1000, particle[i,2]*1000);
        psy.plot.Symbol( particle[i,3]*1000, particle[i,4]*1000);
      end;
    end;
    ButBeamShow.enabled:=true;
  end;
end;


procedure Ttrackp.ButBeamBreakClick(Sender: TObject);
begin
  BeamBreak:=True;
end;

procedure Ttrackp.butT6Click(Sender: TObject);
begin
  TrackMode6:=not TrackMode6;
  if TrackMode6 then begin
    butT6.caption:='! 6D !';
  end else begin
    butT6.caption:='  4D  ';
  end;
end;

end.
