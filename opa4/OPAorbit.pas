//TO DO

{July 2018
beim verlassen fragen ob misal auf null zurueckgesetzt werden sollen oder nicht - oder reset all button.
(manchmal will man mit misal weitermachen, manchmal stoeren sie)
}


{July 2017
Problem: responsematrix muss ohne cor und misal berechnet werden, aber das scheint nicht immer zu funktionieren? warum?
da fehlt irgendeine initialisierung, denn manuell geht es gut erst mal linear zu korrigieren.
}



{
Nov.13,2013
- wenn BPM include, muessen auch ihre read outs enstprechend korrigiert werden
- spalten fuer girder & joint inaktiv machen, falls keine girder/joints vorhanden
- (joints plotten? -> variable joint global machen)
}


                         
unit OPAorbit;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  opticPlot, OPAglobal, StdCtrls,  knobframe, ASfigure, Opticstart, asaux, mathlib, Math,
  ExtCtrls;

type

  { TOrbit }

  TOrbit = class(TForm)
    ButSync: TButton;
    butps: TButton;
    butzoi: TButton;
    butzol: TButton;
    butzot: TButton;
    butzor: TButton;
//    p: TPaintBox;
    plotox: TFigure;
    plotoy: TFigure;
    LabCName: TLabel;
    panbpm: TPanel;
    Edbpmx: TEdit;
    Edbpmxp: TEdit;
    Edbpmy: TEdit;
    Edbpmyp: TEdit;
    labx: TLabel;
    labxp: TLabel;
    laby: TLabel;
    labyp: TLabel;
    labbpm: TLabel;
    panmis: TPanel;
    EdEldx: TEdit;
    EdEldy: TEdit;
    EdEldT: TEdit;
    EdSeed: TEdit;
    butmis: TButton;
    Label1: TLabel;
    Labdy: TLabel;
    Labdt: TLabel;
    Labseed: TLabel;
    Edncut: TEdit;
    LabNcut: TLabel;
    butzero: TButton;
    butcor: TButton;
    butbpmref: TButton;
    butbpmmode: TButton;
    laborbstat: TLabel;
    panctr: TPanel;
    butsta: TButton;
    chkSext: TCheckBox;
    LabLost: TLabel;
    LabPer: TLabel;
    panplo: TPanel;
    ButplotOC: TButton;
    chkKeepMax: TCheckBox;
    butex: TButton;
    butcorzero: TButton;
    butsetagain: TButton;
    panstat: TPanel;
    labstatx: TLabel;
    labstaty: TLabel;
    labmean: TLabel;
    labrms: TLabel;
    labmax: TLabel;
    labymax: TLabel;
    labxmax: TLabel;
    Labxrms: TLabel;
    labxmean: TLabel;
    labymean: TLabel;
    labyrms: TLabel;
    butcodstat: TButton;
    labplottitle: TLabel;
    labcortitle: TLabel;
    labtitctrl: TLabel;
    butbpmzero: TButton;
    plotw: TFigure;
    butocowplot: TButton;
    sliderw: TScrollBar;
    panzoo: TPanel;
    EdGidx: TEdit;
    EdGidy: TEdit;
    EdGidt: TEdit;
    EdJodx: TEdit;
    EdJody: TEdit;
    labmicron: TLabel;
    labmicrad: TLabel;
    Label4: TLabel;
    Edgelatt: TEdit;
    ButMonAbs: TButton;
    labgelatt: TLabel;
    pankick: TPanel;
    Label5: TLabel;
    butkick: TButton;
    Label6: TLabel;
    Edkickturns: TEdit;
    butkicktp: TButton;
    butkicktm: TButton;
    butloop: TButton;
    butcopy: TButton;
    procedure butpsClick(Sender: TObject);
    procedure butzooClick(Sender: TObject);
    procedure butexClick(Sender: TObject);
    procedure ButSyncClick(Sender: TObject);
//    procedure eddppChange(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure butstaClick(Sender: TObject);
    procedure chkSextClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure BoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure plotoxpPaint(Sender: TObject);
    procedure EdElKeyPress(Sender: TObject; var Key: Char);
    procedure EdElExit(Sender: TObject);
    procedure EdNcutKeyPress(Sender: TObject; var Key: Char);
    procedure EdNcutExit(Sender: TObject);
    procedure butmisClick(Sender: TObject);
    procedure butzeroClick(Sender: TObject);
    procedure butcorClick(Sender: TObject);
    procedure butcodstatClick(Sender: TObject);
    procedure butbpmrefClick(Sender: TObject);
    procedure butbpmmodeClick(Sender: TObject);
    procedure ButplotOCClick(Sender: TObject);
    procedure plotoypPaint(Sender: TObject);
    procedure chkKeepMaxClick(Sender: TObject);
    procedure butcorzeroClick(Sender: TObject);
    procedure butbpmzeroClick(Sender: TObject);
    procedure butocowplotClick(Sender: TObject);
    procedure sliderwChange(Sender: TObject);
    procedure plotwpPaint(Sender: TObject);
    procedure butsetagainClick(Sender: TObject);
//    procedure eddppExit(Sender: TObject);
//    procedure eddppKeyPress(Sender: TObject; var Key: Char);
    procedure ButMonAbsClick(Sender: TObject);
    procedure butkickClick(Sender: TObject);
    procedure butkicktmClick(Sender: TObject);
    procedure butkicktpClick(Sender: TObject);
    procedure EdkickturnsKeyPress(Sender: TObject; var Key: Char);
    procedure EdkickturnsExit(Sender: TObject);
    procedure butloopClick(Sender: TObject);
    procedure butcopyClick(Sender: TObject);
  private
    orbmax, cormax, mismax, circ, sposini, sposfin, dsmin, CODpenalty: real;
    knobF: TKnob;
    bpmrect, knobrect: TRect;
    nturns, nkick, ncorx, ncory, nbpm, nocox, nocoy, nocom, knobwidth, nknobs, bpmindex: integer;
    dx_ransig, dy_ransig, dt_ransig, gdx_ransig, gdy_ransig, gdt_ransig,
      jdx_ransig, jdy_ransig, gelatt, sigcut: real;
    codstatmode, ocoWplot, iMisal_seed: integer;
    keepMaxVal, bpmrefmode, ocoSVDdone, BPMinclude, LoopBreak: boolean;
    plotOCM, NLoop, loopstatus: integer;
    oimode: integer;
    procedure ResizeAll;
    procedure LabelShow;
    procedure BPMshow;
    procedure GetOrbitMax;
    procedure GetCorMax;
    procedure GetMisMax;
    procedure MisAlPlotXY(ploto:TFigure);
    procedure CorPlotXY(ploto:TFigure);
    procedure OrbitPlotXY (ploto: TFigure);
    procedure PlotX;
    procedure PlotY;
    procedure WeightPlot;
    procedure MakePlot;
    procedure GetResponseMatrix;
    procedure PrepOrbCorr;
    procedure OrbitCorrection;
    procedure CodstatCalc(mode: integer; var xmean, xrms, xmax, ymean, yrms, ymax: double);
    procedure LoopstatCalc(mode: integer; var xmean, xrms, xmax, ymean, yrms, ymax: double);
    function Codstat: boolean;
    procedure setMisalignments(xrms, yrms, trms, gxrms, gyrms, gtrms, jxrms, jyrms: real);
    procedure readMisalParam;
    procedure LoopAction;
 public
//   function Start (oco_inj_mode:integer): boolean;
   procedure Start (oco_inj_mode:integer);
  end;

var
  Orbit: TOrbit;

implementation

{$R *.lfm}

type
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


const
  codeps = 1e-9; // 1 nm for corrected cod rms
  ncodit = 30;   // 20 iterations for orbit correction

  hv_torb: array[0..1] of string[6]=('X [mm]','Y [mm]');
  hv_tcor: array[0..1] of string[12]=('dX''[mrad]','dY''[mrad]');
  hv_tmis: array[0..1] of string[12]=('dX [mic]','dY [mic]');
  hv_col: array[0..1] of TColor=(clBlue,clRed);
  hv_axmo: array[0..1] of integer =(2,0);
  hv_tspo: array[0..1] of string[12]=('Spos [m]','Spos [m]');

  clseedloop=clFuchsia;

var
  cor: array of cortype;
  bpm: array of bpmtype;
  kick: array of kicktype;
  ikick, icorx, icory, iocox, iocoy, iocom: array of integer;
  ocoAux, ocoWx, ocoWxuse, ocoVx, ocoAUy, ocoWy, ocoWyuse, ocoVy: array of real;
  ocoNwx, ocoNwy: integer;
  OrbLoop: array of OrbLoopType;

// start, resize and close procedures -----------------------------------------

//function TOrbit.Start (oco_inj_mode:integer): boolean;
procedure TOrbit.Start (oco_inj_mode:integer);
var
  i, j: integer;
  boxF: TShape;
//  done: boolean;
  sposh, sposv: real;

begin

  oimode:=oco_inj_mode;

//  plotox.passFormHandle(self);
  plotox.assignScreen;
//  plotoy.passFormHandle(self);
  plotoy.assignScreen;
//  plotw.PassFormHandle(self);
  plotw.assignScreen;
  setOrbitHandle(self);

  if oimode=0 then begin
    PanMis.Visible:=True;
    PanKick.Visible:=False;
  end;
  if oimode=1 then begin
    PanMis.Visible:=False;
    PanKick.Visible:=True;
  end;

  GirderSetup;

//  setOrbitHandles (ploto, edbpmx, edbpmxp, edbpmy, edbpmyp, labper, lablost);
//  setBPMIndex(-1);

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
end;

  ncorx:=Length(icorx); ncory:=Length(icory); nbpm:=Length(bpm);
  nocox:=Length(iocox); nocoy:=Length(iocoy); nocom:=length(iocom);
  nkick:=Length(ikick);
  for i:=0 to High(cor) do begin
    boxF:=TShape(FindComponent('box_'+IntToStr(i)));
    if boxF = nil then begin
      boxF:=TShape.Create(self);
      boxF.name:= 'box_'+IntToStr(i);
    end;
    boxF.parent:=Self;
    with BoxF do begin
      if cor[i].hv then Brush.Color:=cv_col else Brush.Color:=ch_col;
      Tag:=i+1;
      Shape:=stRectangle;
      Pen.Color:=clYellow; Pen.Style:=psClear;
      OnMouseDown:=BoxMouseDown;
      OnMouseUp  :=BoxMouseUp;
    end;
  end;
  for i:=0 to High(bpm) do begin
    boxF:=TShape(FindComponent('box_'+IntToStr(i+ncorx+ncory)));
    if boxF = nil then begin
      boxF:=TShape.Create(self);
      boxF.name:= 'box_'+IntToStr(i+ncorx+ncory);
    end;
    boxF.parent:=Self;
    with BoxF do begin
      Brush.Color:=mo_col; //clGreen;
      Tag:=-(i+1);
      Shape:=stEllipse;
      Pen.Color:=clYellow; Pen.Style:=psClear;
      OnMouseDown:=BoxMouseDown;
      OnMouseUp  :=BoxMouseUp;
    end;
  end;
  for i:=0 to High(kick) do begin
    boxF:=TShape(FindComponent('box_'+IntToStr(i+ncorx+ncory+nbpm)));
    if boxF = nil then begin
      boxF:=TShape.Create(self);
      boxF.name:= 'box_'+IntToStr(i+ncorx+ncory+nbpm);
    end;
    boxF.parent:=Self;
    with BoxF do begin
      if kick[i].hv then Brush.Color:=k_col else Brush.Color:=k_col;
      Tag:=i+1001;
      Shape:=stRectangle;
      Pen.Color:=clYellow; Pen.Style:=psClear;
      OnMouseDown:=BoxMouseDown;
      OnMouseUp  :=BoxMouseUp;
    end;
  end;

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

  EdEldx.Text:=InttoStr(Round( dx_ransig*1e6));
  EdEldy.Text:=InttoStr(Round( dy_ransig*1e6));
  EdEldt.Text:=InttoStr(Round( dt_ransig*1e6));
  EdGidx.Text:=InttoStr(Round(gdx_ransig*1e6));
  EdGidy.Text:=InttoStr(Round(gdy_ransig*1e6));
  EdGidt.Text:=InttoStr(Round(gdt_ransig*1e6));
  EdJodx.Text:=InttoStr(Round(jdx_ransig*1e6));
  EdJody.Text:=InttoStr(Round(jdy_ransig*1e6));
  Edncut.Text:=IntToStr(round(sigcut));

  ResizeAll;
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
  UseSext:=chkSext.Checked;
  UsePulsed:=False;
  nturns:=1;
  PlotOCM:=0;
  ButPlotOC.Caption:='Orbit+BPMs';
  BPMinclude:=true;
  ButMonAbs.Caption:='include BPM';
  Edkickturns.Text:=InttoStr(nturns);
  loopstatus:=0;

  sposini:=0;
  sposfin:=circ;

  if StartSel= nil then StartSel:=TStartSel.Create(Application); //ist niemals nil, warum nicht? 26.10.2020
  StartSel.Load (oimode+1{+10}, self); {1,2 for oco, inj}
//  StartSel.ShowModal;
  StartSel.Show;
//writeln('cancel start ',startsel.cancel_start); does not work, cancel button does not act on this if not showmodal
//  if startsel.cancel_start then Orbit.Close;
//  Start:=not Startsel.cancel_start;
end;

procedure TOrbit.FormClose(Sender: TObject; var Action: TCloseAction);
// close the form
var
  i:integer;
  knobF: TKnob;
  boxF: TShape;
begin
// reset all misalignments  - no!
//  setMisalignments(0,0,0,0,0,0,0,0);
// reset the energy
  glob.dpp:=0.0;
// free all components I created
  for i:=0 to High(cor) do begin
    boxF:=TShape(FindComponent('box_'+IntToStr(i)));
    if boxF<>nil then boxF.free;
  end;
  for i:=0 to High(bpm) do begin
    boxF:=TShape(FindComponent('box_'+IntToStr(i+ncorx+ncory)));
    if boxF<>nil then boxF.free;
  end;
  for i:=0 to High(kick) do begin
    boxF:=TShape(FindComponent('box_'+IntToStr(i+ncorx+ncory+nbpm)));
    if boxF<>nil then boxF.free;
  end;
  for i:=1 to 10 do begin
    knobF:=TKnob(FindComponent('kn_'+IntToStr(i)));
    if knobF <> nil then knobF.free;
  end;
  kick:=nil; ikick:=nil;
  cor:=nil; bpm:=nil; icorx:=nil; icory:=nil; iocox:=nil; iocoy:=nil; iocom:=nil;
  ocoAUx:=nil; ocoAUy:=nil; ocoVx:=nil; ocoVy:=nil;
  ocoWx:=nil; ocoWy:=nil; ocoWxuse:=nil; ocoWyuse:=nil;
  ClearOpval;
  if Startsel<>nil then Startsel.Exit;
end;

procedure TOrbit.ResizeAll;
const
  space=10;
  mspace=2;
  orbleft=60; orbup=40; orbspac=10;
  yhbox=10; yhsl=15;
  knobheight=100; bpmwidth=240; dppwidth=57;
  yhc=180;
var
  yline, i, yhwin, xwin, xkoff, xkwid, xkibox: integer;
  pxl, pyt, pxw, pyh: integer;
  xlbox, ytbox, xwbox: integer;
  boxF: TShape;
  slength: real;
begin
  if clientwidth<640 then clientwidth:=640;
  yline:=space;
  yhwin:=yhc+orbup-orbspac;
  xwin:= ClientWidth-2*space;
  plotox.SetSize(space, yline, xwin, yhwin);
  Inc(yline,yhwin);
  plotoy.SetSize(space, yline, xwin, yhwin);
  Inc(yline,yhwin);
  plotox.forceMarginX(orbleft, orbspac);
  plotox.forceMarginY(orbspac, orbup);
  plotoy.forceMarginX(orbleft, orbspac);
  plotoy.forceMarginY(orbspac, orbup);

  plotox.getPlotPos(pxl, pyt, pxw, pyh);
  LabCName.setBounds(space,yline+5,pxl,20);
  xwbox:=21; // scale shapes to not overlap:

  if StartSel.orb_plot_enabled then slength:=sposfin-sposini else slength:=circ;
  if slength=0 then slength:=circ; // for safety, not always caught by orb_plot flag (why?)

  if round(dsmin/slength*pxw) < xwbox then xwbox :=round(dsmin/slength*pxw);
  Dec(xwbox);
  if xwbox<2 then xwbox:=2;
  ytbox:=yline;
  for i:=0 to High(cor) do begin
    boxF:=TShape(FindComponent('box_'+IntToStr(i)));
    if boxF <> nil then with BoxF do begin
      if (cor[i].spos-sposini)*(cor[i].spos-sposini-slength) < 0 then begin
        xlbox:=round(pxl+(cor[i].spos-sposini)/slength*pxw-0.5*xwbox);
        if cor[i].hv then begin      //vert
          setBounds(xlbox, ytbox, xwbox, yhbox);
        end else begin
          setBounds(xlbox, ytbox+yhbox+mspace, xwbox, yhbox);
        end;
        Visible:=true;
      end else Visible:=false;
    end;
  end;

  for i:=0 to High(bpm) do begin
    boxF:=TShape(FindComponent('box_'+IntToStr(i+Length(cor))));
    if boxF <> nil then with BoxF do begin
      if (bpm[i].sposb-sposini)*(bpm[i].sposb-sposini-slength) < 0 then begin
        xlbox:=round(pxl+(bpm[i].sposb-sposini)/slength*pxw-0.5*xwbox);
        setBounds(xlbox, ytbox+2*(yhbox+mspace), xwbox, yhbox);
        Visible:=true;
      end else Visible:=false;
    end;
  end;

  for i:=0 to High(kick) do begin
    boxF:=TShape(FindComponent('box_'+IntToStr(i+Length(cor)+Length(bpm))));
    if boxF <> nil then with BoxF do begin
      if (kick[i].spos-sposini)*(kick[i].spos-sposini-slength) < 0 then begin
        if Ella[kick[i].jella].l>0 then begin
           xkibox:=round(Ella[kick[i].jella].l/slength*pxw);
           if xkibox < 2 then xkibox:=2;
           xlbox:=round(pxl+(kick[i].spos-sposini)/slength*pxw-xkibox);
        end else begin
          xkibox:=xwbox;
          xlbox:=round(pxl+(kick[i].spos-sposini)/slength*pxw-0.5*xkibox);
        end;
        if kick[i].hv then setBounds(xlbox, ytbox, xkibox, yhbox)
                      else setBounds(xlbox, ytbox+yhbox+mspace, xkibox, yhbox);
        Visible:=true;
      end else Visible:=false;
    end;
  end;

  Inc(yline,3*(mspace+yhbox));

  panzoo.setBounds(space, yline, dppwidth, knobheight);
  xkoff:=dppwidth+2*space;
{
  if nkick > 0 then begin
    pankick.Visible:=True;
    pankick.setBounds(xkoff, yline, kickwidth, knobheight);
    inc(xkoff, kickwidth+space);
  end else pankick.Visible:=False;
}
  panbpm.setBounds(xkoff, yline,bpmwidth, knobheight);
  inc(xkoff, bpmwidth+space);
{create as many knobs as fit into the form:}
  xkwid:=ClientWidth-space-xkoff;
  nknobs:=round(xkwid/200);
  if nknobs>9 then nknobs:=9;
  knobwidth:=trunc(xkwid/nknobs);
  {knobs are named kn_1,2,3...}
  for i:=1 to nknobs do begin
    knobF:=TKnob(FindComponent('kn_'+IntToStr(i)));
    if knobF = nil then begin
      knobF:=TKnob.Create(self);
      knobF.parent:=Self;
      KnobF.Init(i); // also assigns the name 'kn_'+IntToStr(i)
    end;
    knobF.setSize(xkoff+(i-1)*knobwidth, yline, knobwidth, knobheight);
  end;
  for i:=nknobs+1 to 10 do begin
    knobF:=TKnob(FindComponent('kn_'+IntToStr(i)));
    if knobF <> nil then knobF.free;
  end;
// rectangel containing all the knobs
  knobrect:=Rect(xkoff, yline, xkoff+xkwid, knobheight+yline);
  with panbpm do bpmrect:=Rect(left,top,left+width,top+height);

  Inc(yline,knobheight+space);
  yhwin:=panctr.Height;
  xwin:=panctr.Width;
  panctr.setbounds(space, yline, xwin, yhwin);
  xkoff:= space+xwin+space;
  xwin:=panplo.width;
  butex.setbounds(clientwidth-space-xwin,yline+yhwin-butex.height,xwin,25);
  panplo.setbounds(clientwidth-space-xwin,yline,xwin,yhwin-space-butex.height);
  xwin:=Clientwidth-xkoff-xwin-2*space;
  panmis.setbounds(xkoff, yline, xwin, yhwin);
  pankick.setbounds(xkoff, yline, xwin, yhwin); {use same space on panel}
  xkoff:=butcor.left+butcor.width+space;
  xwin:=xwin-xkoff-space;
  plotw.SetSize(xkoff, space, xwin, yhwin-yhsl-2*space-5);
  butocowplot.setbounds(xkoff,yhwin-yhsl-space,yhsl,yhsl);
  sliderw.setbounds(xkoff+yhsl+space, yhwin-yhsl-space,xwin-space-yhsl,yhsl);
  Inc(yline,yhwin+space);
  Clientheight:=yline;
end;


// procedure to update GUI with data --------------------------------

procedure TOrbit.BPMshow;
// update the BPM fields
begin
  if bpmindex > -1 then with BPM[bpmindex] do begin
    if bpmrefmode then begin
      EdbpmX.Text:=FtoS(1000*ref[0],8,4);  EdbpmXp.Text:='';
      EdbpmY.Text:=FtoS(1000*ref[1],8,4);  EdbpmYp.Text:='';
    end else with Opval[nturns-1,ilatb] do begin
      EdbpmX.Text:=FtoS(1000*orb[1],8,4);  EdbpmXp.Text:=FtoS(1000*orb[2],8,4);
      EdbpmY.Text:=FtoS(1000*orb[3],8,4);  EdbpmYp.Text:=FtoS(1000*orb[4],8,4);
    end;
  end;
end;

procedure TOrbit.LabelShow;
  // update all the status labels
begin
  with LabPer do begin
    if (PerMode or SymMode) then if status.PerOrbit then begin
      Font.Color:=clGreen;
      Caption:='periodic'
    end else begin
      Font.Color:=clRed;
      Caption:='not periodic!'
    end else begin
      Font.Color:=clGray;
      Caption:='single pass';
    end;
  end;
  with LabLost do if BeamLost then Caption:='beam lost !' else Caption:='';
  with LabOrbStat do case COCorrstatus of
    1: begin Font.Color:=clGreen; Caption:='zeroed!'; end;
    2: begin Font.Color:=clBlue; Caption:='minimized'; end;
    3: begin Font.Color:=clmaroon; Caption:='too many it.'; end;
    4: begin Font.Color:=clRed; Caption:='failed!'; end;
    else begin Font.Color:=clBlack; Caption:=' COD '; end;
  end;
  with butocowplot do case ocoWplot of
    0: caption:='X'; 1: caption:='Y'; else Caption:=' ';
  end;
end;



// plot procedures -----------------------------------------------

procedure TOrbit.GetOrbitMax;
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

procedure TOrbit.GetCorMax;
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

procedure TOrbit.GetMisMax;
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


procedure TOrbit.MisAlPlotXY(ploto: TFigure);
// plot X or Y misalignments
var
  ihv, i: integer;
begin
  with ploto do begin
    ihv:=ploto.Tag; //0,1 = h,v
    Init(sposini,-mismax,sposfin,mismax,1,1,hv_tspo[ihv],hv_tmis[ihv],3,false);
    with plot do begin
      setStyle(psSolid);
      setColor(dimcol(hv_col[ihv],clWhite,0.2));
      if ihv=0 then begin
        setColor(dimcol(hv_col[ihv],clWhite,0.3));
        for i:=0 to NGirderLevel[1]-1 do with Girder[i] do Line(gsp[0], gdx[0]*1e6, gsp[1], gdx[1]*1e6);
        setColor(dimcol(hv_col[ihv],clWhite,0.6));
        for i:=NGirderLevel[1] to NGirderLevel[2]-1 do with Girder[i] do Line(gsp[0], gdx[0]*1e6, gsp[1], gdx[1]*1e6);
        setColor(dimcol(hv_col[ihv],clBlack,0.5));
        for i:=NGirderLevel[2] to High(Girder) do with Girder[i] do Line(gsp[0], gdx[0]*1e6, gsp[1], gdx[1]*1e6);
        setSymbol(1,2,hv_col[0]);
        for i:=1 to Glob.NLatt do with Lattice[i] do if misal then Symbol(smid, dx*1e6);
        setSymbol(2,2,clGreen);
        for i:=0 to High(bpm) do with Lattice[bpm[i].ilatb] do Symbol(smid, dx*1e6);
      end else begin
        setColor(dimcol(hv_col[ihv],clWhite,0.3));
        for i:=0 to NGirderLevel[1]-1 do with Girder[i] do Line(gsp[0], gdy[0]*1e6, gsp[1], gdy[1]*1e6);
        setColor(dimcol(hv_col[ihv],clWhite,0.6));
        for i:=NGirderLevel[1] to NGirderLevel[2]-1 do with Girder[i] do Line(gsp[0], gdy[0]*1e6, gsp[1], gdy[1]*1e6);
        setColor(dimcol(hv_col[ihv],clBlack,0.5));
        for i:=NGirderLevel[2] to High(Girder) do with Girder[i] do Line(gsp[0], gdy[0]*1e6, gsp[1], gdy[1]*1e6);
        setSymbol(1,2,hv_col[1]);
        for i:=1 to Glob.NLatt do with Lattice[i] do if misal then Symbol(smid, dy*1e6);
        setSymbol(2,2,clGreen);
        for i:=0 to High(bpm) do with Lattice[bpm[i].ilatb] do Symbol(smid, dy*1e6);
      end;
    end;
  end;
end;




procedure TOrbit.CorPlotXY(ploto: TFigure);
// plot X or Y correctors
var
  ihv, i: integer;
begin
  with ploto do begin
    ihv:=ploto.Tag; //0,1 = h,v
    Init(sposini,-cormax,sposfin,cormax,1,1,hv_tspo[ihv],hv_tcor[ihv],3,false);
    with plot do begin
      setStyle(psSolid);
      setColor(dimcol(hv_col[ihv],clWhite,0.2));
      if ihv=0 then begin
        for i:=0 to ncorx-1 do with cor[icorx[i]] do Line(spos,-cormax,spos,cormax);
        setColor(hv_col[0]);
        for i:=0 to ncorx-1 do with cor[icorx[i]] do Line(spos,0,spos,Ella[jella].dxp*1000)
      end else begin
        for i:=0 to ncory-1 do with cor[icory[i]] do Line(spos,-cormax,spos,cormax);
        setColor(hv_col[1]);
        for i:=0 to ncory-1 do with cor[icory[i]] do Line(spos,0,spos,Ella[jella].dyp*1000);
      end;
    end;
  end;
end;


procedure TOrbit.OrbitPlotXY (ploto: TFigure);
// plot X or Y orbits and BPMs incl. references
const
 corrcod: array[0..1] of integer=(ccorh,ccorv);
var
  ihvo, ihv, i,j,jt: integer;
  col, colm, colturn: TColor;
begin
  colm:=dimcol(clGreen,clWhite,0.2);
  with ploto do begin
    ihv:=ploto.Tag;   //0,1 = hor, vert
    Init(sposini,-orbmax,sposfin,orbmax,1,1, hv_tspo[ihv] ,hv_torb[ihv],3,false);
    col:=dimcol(hv_col[ihv],clWhite,0.2);
    with plot do begin
      setStyle(psSolid);
      for i:=1 to Glob.NLatt do begin
        j:=Findel(i);
        if i=ilaststart then  begin
          setColor(clYellow);
          with opval[0,i] do line(spos,-orbmax,spos,orbmax);
        end;
        if Ella[j].cod = corrcod[ihv] then begin
          if Ella[j].tag >-1 then setColor(hv_col[ihv]) else setColor(col);
          with opval[0,i] do line(spos,-orbmax,spos,0);
        end;
        if Ella[j].cod = cmoni then begin
          setColor(colm);
          if bpmindex > -1 then if i=BPM[bpmindex].ilatb then setColor(clGreen);
          with opval[0,i] do line(spos,0,spos, orbmax);
        end;
      end;
      ihvo:=2*ihv+1;
      for jt:=0 to nturns-1 do begin
        colturn:=dimcol(hv_col[ihv],hv_col[1-ihv],1-jt/nturns);
        setcolor(colturn);
        with opval[jt,0] do moveto(spos, orb[ihvo]*1000);
        for i:=1 to Glob.NLatt do with opval[jt,i] do lineto(spos,orb[ihvo]*1000);  stroke;
      end;

      setSymbol(3,2,clFuchsia);//clWhite);
      for i:=0 to nbpm-1 do with bpm[i] do Symbol(sposb,1000*Opval[nturns-1,ilatb].orb[ihvo]);
      setSymbol(2,2,colturn);
      for i:=0 to nbpm-1 do with bpm[i] do Symbol(sposb,1000*Opval[nturns-1,ilatb].orb[ihvo]);
      setSymbol(4,2,clLime);
      for i:=0 to nbpm-1 do with bpm[i] do  Symbol(sposb,1000*ref[ihv]);
      setSymbol(2,2,colturn);
      for i:=0 to nbpm-1 do with bpm[i] do  Symbol(sposb,1000*ref[ihv]);
    end;
  end;
end;

procedure TOrbit.plotX;
// plot X orbit or correctors
begin
  case plotOCM of
    0: OrbitPlotXY(plotox);
    1: CorPlotXY(plotox);
    2: MisAlPlotXY(plotox);
  end;
end;

procedure TOrbit.plotY;
// plot Y orbit or correctors
begin
  case plotOCM of
    0: OrbitPlotXY(plotoy);
    1: CorPlotXY(plotoy);
    2: MisAlPlotXY(plotoy);
  end;
end;

procedure TOrbit.WeightPlot;
//plot the svd weight vectors, X or Y
  procedure wplot (w, u:array of real);
  const
    tit: array[0..1] of string[6]=('Log Wx','Log Wy');
  var
    wmin, wmax, wlogmin, wlogmax: real;
    i: integer;
    wlog, ulog: array of real;
  begin
    wmin:=1e12; wmax:=1e-12;
    setlength(wlog, length(w));
    setlength(ulog, length(w));
    for i:=1 to High(w) do begin
      if (wmin>w[i]) and (w[i]>0) then wmin:=w[i];
      if wmax<w[i] then wmax:=w[i];
    end;
    wlogmin:=Log10(wmin)-0.5;
    wlogmax:=Log10(wmax)+0.5;
    for i:=1 to High(w) do if w[i]>0 then wlog[i]:=Log10(w[i]) else wlog[i]:=wlogmin;
    for i:=1 to High(u) do if u[i]>0 then ulog[i]:=Log10(u[i]) else ulog[i]:=wlogmin;
    plotw.Init(0,wlogmin,High(w),wlogmax,1,1,'',tit[ocoWPlot],0,false);
    with plotw.plot do begin
      for i:=1 to High(w) do begin
        if ocoWPlot=0 then setcolor(clNavy) else setcolor(clMaroon);
        Line(i-0.5,wlogmin,i-0.5,wlog[i]);
        if ocoWPlot=0 then setcolor(clBlue) else setcolor(clred);
        Line(i-0.5,wlogmin,i-0.5,ulog[i]);
      end;
    end;
    wlog:=nil;
  end;

begin
  if ocoWplot > -1 then begin
    if ocoWplot=0 then wplot(ocoWx, ocoWxuse) else wplot(ocoWy, ocoWyuse);
  end;
end;

procedure TOrbit.MakePlot;
// plot all and update fields: called on repaint and after each change of data
begin
  GetCorMax;
  GetOrbitMax;
  GetMisMax;
  plotX;
  plotY;
  weightPlot;
  BPMshow;
  LabelShow;
  CodStat;
end;


//eps export
procedure TOrbit.butpsClick(Sender: TObject);
const plmod: array[0..2] of string[5]=('_orb_','_cor_','_mis_');
var
  errmsg1, errmsg2, epsfile1, epsfile2: string;
  fail: boolean;
begin
  GetCorMax;
  GetOrbitMax;
  GetMisMax;
  epsfile1:=ExtractFileName(FileName);
  epsfile1:=work_dir+Copy(epsfile1,0,Pos('.',epsfile1)-1)+plmod[PlotOCM];
  epsfile2:=epsfile1+'y'+'.eps';
  epsfile1:=epsfile1+'x'+'.eps';
  plotox.plot.PS_start(epsfile1,OPAversion, errmsg1);
  fail:=(length(errmsg1)>0);
  if not fail then begin
    plotX;
    plotox.plot.PS_stop;
  end;
  plotoy.plot.PS_start(epsfile2,OPAversion, errmsg2);
  fail:=fail or (length(errmsg2)>0);
  if not fail then begin
    plotY;
    plotoy.plot.PS_stop;
  end;
  if fail
  then  MessageDlg('PS export failed: '+errmsg1+' '+errmsg2, MtError, [mbOK],0)
  else  MessageDlg('Graphics exported to '+sLineBreak+epsfile1+sLineBreak+epsfile2, MtInformation, [mbOK],0);
end;


procedure TOrbit.FormResize(Sender: TObject);
begin
  ResizeAll;
end;


// repaint procedures for whole form and for the figures  --------------------

procedure TOrbit.FormPaint(Sender: TObject);
begin
  if StartSel.orb_plot_enabled then MakePlot;
end;

procedure TOrbit.plotoxpPaint(Sender: TObject);
begin
  if StartSel.orb_plot_enabled then   plotX;
end;

procedure TOrbit.plotoypPaint(Sender: TObject);
begin
  if StartSel.orb_plot_enabled then   PlotY;
end;

procedure TOrbit.plotwpPaint(Sender: TObject);
begin
  if StartSel.orb_plot_enabled then   WeightPlot;
end;


// eventhandlers for GUI components ----------------------------------------

procedure TOrbit.butzooClick(Sender: TObject);
var
  slen, smid: real;
begin
  slen:=sposfin-sposini;
  smid:=(sposfin+sposini)/2;
  with Sender as TButton do begin
    case Tag of
      1: slen:=slen/3;
      2: slen:=slen*3;
      3: smid:=smid+slen/6;
      4: smid:=smid-slen/6;
    end;
  end;
  if slen> circ then slen:=circ;
  sposini:=smid-slen/2;
  sposfin:=smid+slen/2;
  if sposini < 0    then begin sposini:=0;    sposfin:=sposini+slen; end;
  if sposfin > circ then begin sposfin:=circ; sposini:=sposfin-slen; end;
  Resizeall;
  MakePlot;
end;


// .... for the control panel...
procedure TOrbit.butstaClick(Sender: TObject);
// change the starting point
begin
  PerMode:=false;
  SymMode:=false;
//  OpticStartMode:=-1; {undefined to start without selection}
  if StartSel= nil then StartSel:=TStartSel.Create(Application);
  StartSel.Load (oimode+1,self);
  StartSel.Show;
//  StartSel.ShowModal;
  ocoSVDdone:=false;
end;

procedure TOrbit.chkSextClick(Sender: TObject);
// switch on/off nonlinear elements
begin
  UseSext:=chkSext.Checked;
  OrbitReCalc;
  MakePlot;
end;

procedure TOrbit.butcodstatClick(Sender: TObject);
// change the display of cod statistics between bpm, all, cor
begin
  Inc(codstatmode);
  if codstatmode=3 then codstatmode:=0;
  case codstatmode of
    0: begin
        butcodstat.Caption:='BPM';
        labstatx.Caption:='dX [mm]';    labstaty.Caption:='dY [mm]';
       end;
    1: begin
         butcodstat.Caption:='all';
         labstatx.Caption:='X [mm]';    labstaty.Caption:='Y [mm]';
       end;
    2: begin
         butcodstat.Caption:='Corr';
         labstatx.Caption:='dX''[mr]';    labstaty.Caption:='dY''[mr]';
       end;
  end;
  CODstat;
end;

{procedure TOrbit.eddppExit(Sender: TObject);
var
  v: real;
begin
  TEReadVal(eddpp, v, 5, 2);
end;

procedure TOrbit.eddppKeyPress(Sender: TObject; var Key: Char);
var
  dppnew, v: real;
begin
  if TEKeyVal(eddpp, Key, v, 5,2) then begin
    dppnew:=v/100.0;
    if Glob.dpp <> dppnew then begin
      Glob.dpp:=dppnew;
      OrbitRecalc;
      PlotOrbit;
    end else eddpp.Text:=FtoS(Glob.dpp*100.,5,2);
  end;
end;
}

//... for the misalignments & OCO panel .....

procedure TOrbit.EdElKeyPress(Sender: TObject; var Key: Char);
// generic for entering something in one of the edit fields
var
  v: real;
begin
  TEKeyVal(sender as TEdit, Key, v, 5,0);
end;

procedure TOrbit.EdElExit(Sender: TObject);
// generic for leaving one of the edit fields
var
  v: real;
begin
  TEReadVal(sender as TEdit, v, 5, 0);
end;

procedure TOrbit.EdncutKeyPress(Sender: TObject; var Key: Char);
var
  v: real;
begin
  TEKeyVal(sender as TEdit, Key, v, 5,1);
end;

procedure TOrbit.EdncutExit(Sender: TObject);
var
  v: real;
begin
  TEReadVal(sender as TEdit, v, 5, 1);
end;

procedure TOrbit.readMisalParam;
var
  v: real;
begin
  TEReadVal(EdEldx, v, 5, 0); dx_ransig:=1e-6*v;
  TEReadVal(EdEldy, v, 5, 0); dy_ransig:=1e-6*v;
  TEReadVal(EdEldt, v, 5, 0); dt_ransig:=1e-6*v;
  TEReadVal(EdGidx, v, 5, 0); gdx_ransig:=1e-6*v;
  TEReadVal(EdGidy, v, 5, 0); gdy_ransig:=1e-6*v;
  TEReadVal(EdGidt, v, 5, 0); gdt_ransig:=1e-6*v;
  TEReadVal(EdJodx, v, 5, 0); jdx_ransig:=1e-6*v;
  TEReadVal(EdJody, v, 5, 0); jdy_ransig:=1e-6*v;
  TEReadVal(EdGelatt, v, 5, 0); gelatt:=1e-2*v;
  TEReadVal(EdNcut, v,5, 1); if v < 1 then sigcut:=1.0 else sigcut:=v;
end;

procedure TOrbit.butmisClick(Sender: TObject);
// set the misalignments
var
  v: real;
begin
  ReadMisalParam;
  TEReadVal(Edseed, v, 5, 0); iMisal_seed:=Round(v);
  setMisalignments(dx_ransig, dy_ransig, dt_ransig, gdx_ransig, gdy_ransig, gdt_ransig, jdx_ransig, jdy_ransig);
  OrbitRecalc;
  MakePlot;
  setStatusLabel(stlab_mis,status_light);
end;

procedure TOrbit.butzeroClick(Sender: TObject);
// zero the misalignments
begin
  EdEldx.Text:='0';  EdEldy.Text:='0';  EdEldt.Text:='0';
  EdGidx.Text:='0';  EdGidy.Text:='0';  EdGidt.Text:='0';
  EdJodx.Text:='0';  EdJody.Text:='0';
  setMisalignments(0, 0, 0, 0, 0, 0, 0, 0);
  OrbitRecalc;
  MakePlot;
  setStatusLabel(stlab_mis,status_off);
end;

procedure TOrbit.butsetagainClick(Sender: TObject);
// set again the misalignments we had before
var
  cut, rseed: real;
begin
  TEReadVal(Edseed, rseed, 5, 0);
  TEReadVal(EdNcut, cut,5, 1); if cut < 1 then cut:=1.0;
  EdEldx.Text:=Ftos(dx_ransig*1e6,5,0);
  EdEldy.Text:=Ftos(dy_ransig*1e6,5,0);
  EdEldt.Text:=Ftos(dt_ransig*1e6,5,0);
  EdGidx.Text:=Ftos(gdx_ransig*1e6,5,0);
  EdGidy.Text:=Ftos(gdy_ransig*1e6,5,0);
  EdGidt.Text:=Ftos(gdt_ransig*1e6,5,0);
  EdJodx.Text:=Ftos(jdx_ransig*1e6,5,0);
  EdJody.Text:=Ftos(jdy_ransig*1e6,5,0);
  EdGelatt.Text:=Ftos(gelatt*1e2,4,0);
  setMisalignments(dx_ransig, dy_ransig, dt_ransig, gdx_ransig, gdy_ransig, gdt_ransig, jdx_ransig, jdy_ransig);
  OrbitRecalc;
  MakePlot;
end;

procedure TOrbit.prepOrbCorr;
//var i: integer;
begin
// setup the svd if this was not done before
  if not ocoSVDdone then begin
// get responsematrix in any case for the ideal lattice -- but still crash!
//?    for i:=0 to ncorx-1 do with Ella[Cor[icorx[i]].jella] do dxp:=0.0;
//?    for i:=0 to ncory-1 do with Ella[Cor[icory[i]].jella] do dyp:=0.0;
//?    setMisalignments(0,0,0,0,0,0,0,0);
    GetResponseMatrix;
//    opamessage(0,'RM');
//?    setMisalignments(dx_ransig, dy_ransig, dt_ransig, gdx_ransig, gdy_ransig, gdt_ransig, jdx_ransig, jdy_ransig);

    if ocoWplot=0
    then sliderw.SetParams(ocoNwx,1,ocoNwx)
    else sliderw.SetParams(ocoNwy,1,ocoNwy);
  end;
end;

procedure TOrbit.butcorClick(Sender: TObject);
// correct the orbit
begin
  PrepOrbCorr;
  OrbitCorrection;
  setStatusLabel(stlab_cor,status_light);
end;

procedure TOrbit.butcorzeroClick(Sender: TObject);
// set all correctors to zero
var i:integer;
begin
  for i:=0 to ncorx-1 do with Ella[Cor[icorx[i]].jella] do dxp:=0.0;
  for i:=0 to ncory-1 do with Ella[Cor[icory[i]].jella] do dyp:=0.0;
  OrbitReCalc;
  MakePlot;
  setStatusLabel(stlab_cor,status_off);
end;

procedure TOrbit.butbpmzeroClick(Sender: TObject);
// set all BPM references to zero
var i: integer;
begin
  for i:=0 to nbpm-1 do with bpm[i] do begin
    ref[0]:=0.0; ref[1]:=0.0;
  end;
  MakePlot;
end;

procedure TOrbit.butocowplotClick(Sender: TObject);
// toggle x/y the weight factor plot
begin
  case ocoWplot of
    0: begin
      ocoWplot:=1;
      Sliderw.setParams(ocoNwy,1,nocoy);
    end;
    1: begin
      ocoWplot:=0;
      Sliderw.setParams(ocoNwx,1,nocox);
    end;
  else;
  end;
  WeightPlot;
  Labelshow;
end;

procedure TOrbit.sliderwChange(Sender: TObject);
// change the number of weight factors to be used
//  to do:
// !! weight from svdcmp are not well sorted: select the ocoNw LARGEST values
//
var
  i: integer;
begin
//opamessage(0,'slpos '+inttostr(sliderw.Position));
  if ocowplot=0 then begin
    ocoNwx:=sliderw.Position;
    for i:=1 to ocoNwx do ocoWxuse[i]:=ocoWx[i];
    for i:=ocoNwx+1 to High(ocoWxuse) do ocoWxuse[i]:=0.0;
  end;
  if ocowplot=1 then begin
    ocoNwy:=sliderw.Position;
    for i:=1 to ocoNwy do ocoWyuse[i]:=ocoWy[i];
    for i:=ocoNwy+1 to High(ocoWyuse) do ocoWyuse[i]:=0.0;
  end;
  WeightPlot;
  laborbstat.Caption:='';
end;

// ... for the plot panel .....................

procedure TOrbit.ButplotOCClick(Sender: TObject);
// change the plot mode orbit <-> correctors
begin
  PlotOCM:=PlotOCM+1;
  if PlotOCM = 3 then PlotOCM:=0;
  with ButPlotOC do case PlotOCM of
    0: Caption:='Orbit+BPMs';
    1: Caption:='Correctors';
    2: Caption:='Misalignments';
  end;
  MakePlot;
end;

procedure TOrbit.chkKeepMaxClick(Sender: TObject);
// on/off constant scaling to maximum
begin
  KeepMaxVal:=chkKeepMax.Checked;
  if not KeepMaxVal then Makeplot;
end;

// ... for the BPM field ......................

procedure TOrbit.butbpmrefClick(Sender: TObject);
// write a reference value to the BPM
var
  val: real;
begin
  with BPM[bpmindex] do begin
    TEReadval(Edbpmx,val,5,2); ref[0]:=val/1000;
    TEReadval(Edbpmy,val,5,2); ref[1]:=val/1000;
  end;
  MakePlot;
end;

procedure TOrbit.butbpmmodeClick(Sender: TObject);
// toggle BPM mode between orbit show and reference edit
begin
  bpmrefmode:= not bpmrefmode;
  if bpmrefmode then begin
    Edbpmx.Color:=clLightYellow;   Edbpmy.Color:=clLightYellow;
    Edbpmxp.enabled:=false;   Edbpmyp.enabled:=false;
    butbpmmode.Caption:='Reference';
    butbpmref.enabled:=true;
  end else begin
    Edbpmx.Color:=clWhite;    Edbpmy.Color:=clWhite;
    Edbpmxp.enabled:=true;    Edbpmyp.enabled:=true;
    butbpmmode.Caption:='   Orbit';
    butbpmref.enabled:=false;
  end;
  BPMShow;
end;

// ... and the exit button:

procedure TOrbit.butexClick(Sender: TObject);
// regular exit (button pressed, not Form closed)
var
//  mr: word;
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
  //??? mr
  //if mr<>mrCancel then
  Close;

end;





// mouse event handlers ----------------------------------------

procedure TOrbit.BoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
// identify the shape which has been clicked
var
  BoxF: TShape;
begin
  BoxF:=sender as TShape;
  BoxF.Pen.Style:=psSolid;
  if  BoxF.tag>0 then if BoxF.tag < 1000 then LabCname.Caption:=Ella[cor[ BoxF.tag-1].jella].Nam
                 else LabCname.Caption:=Ella[kick[BoxF.tag-1001].jella].Nam
                 else LabCname.Caption:=Ella[bpm[-BoxF.tag-1].jellab].Nam;
//  iselectedElem:=cor[BoxF.tag].jella;
//  opamessage(0,Ella[iselectedElem].nam+'  x,y= '+inttostr(x)+' '+inttostr(y));
end;

procedure TOrbit.BoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
// connect knob or bpm if the mouse was dragged from the shape to the corresponding rectangle
var
  iel,iknob, xa, ya: integer;
  kn: TKnob;
  found: boolean;
  BoxF: TShape;
begin
  BoxF:=sender as TShape;
  BoxF.Pen.Style:=psclear;
  if BoxF.tag>0 then if BoxF.Tag<1000 then iel:=cor[BoxF.tag-1].jella else iel:=kick[BoxF.Tag-1001].jella else iel:=bpm[-BoxF.tag-1].jellab;
  LabCname.Caption:='';
  xa:=BoxF.left+x; ya:=BoxF.top+y;
  if Ella[iel].cod =cmoni then begin
    if  insideRect(xa,ya,bpmrect) then begin
      labbpm.Caption:=Ella[iel].nam;
      bpmindex:=-BoxF.tag-1;
      //allow reference only for bpms with oco flag
      if bpm[bpmindex].oco then begin

      end else begin

      end;
      MakePlot;
    end;
  end else begin
    if  insideRect(xa,ya,knobrect) then begin
      found:=false;
      for iknob:=1 to nknobs do begin
        kn:=TKnob(FindComponent('kn_'+IntToStr(iknob)));
//        found:=found or (kn.Tag=iel);
          found:=found or (kn.getElla = iel);
      end;
      if found then  MessageDlg(ella[iel].nam+' is already connected.', mtWarning, [mbok],0)
      else begin
        iknob:=(xa-knobrect.left) div knobwidth+1;
        kn:=TKnob(FindComponent('kn_'+IntToStr(iknob)));
        kn.Load(iel, plotox.GetPaintBox); //basically don't need to pass a paintbox for orbit
        MakePlot;
      end;
    end;
  end;
end;


// beam dynamics procedure ---------------------------------------------

procedure Torbit.setMisalignments(xrms, yrms, trms, gxrms, gyrms, gtrms, jxrms, jyrms: real);
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


procedure TOrbit.GetResponseMatrix;
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
  if PerMode then begin
    status.periodic :=false;
    status.symmetric:=false;
    ClosedOrbit(FailFlag, do_twiss, 0); // close orbit with NO errors
    if not FailFlag then Periodic(FailFlag);
    if Failflag then begin
      LabPer.Caption:='optics not periodic';
      LabPer.Font.Color:=clRed;
    end;
  end else begin
    FailFlag:=false; //single pass
  end;
  if not FailFlag then begin
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

      if PerMode then begin // periodic (per.sol. exists otherwise we would not be here)
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

      else begin // single pass
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

  end;
end;

procedure TOrbit.CodstatCalc(mode: integer; var xmean, xrms, xmax, ymean, yrms, ymax: double);
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

procedure TOrbit.LoopstatCalc(mode: integer; var xmean, xrms, xmax, ymean, yrms, ymax: double);
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
  Edseed.text:=inttostr(nval);
end;

function TOrbit.Codstat: boolean;
// orbit statistics: return true if the xrms orbit is the same like in step before
var
  xmean, ymean, xrms, yrms, xmax, ymax, cp: double;
begin
  if loopstatus=4
  then begin
    LoopStatCalc(codstatmode, xmean, xrms, xmax, ymean, yrms, ymax);
    CodStat:=true;
  end else begin
    CodStatCalc(codstatmode,xmean, xrms, xmax, ymean, yrms, ymax);
    cp:=sqrt(sqr(xrms)+sqr(yrms));
    Codstat:=abs(cp-CODpenalty)<codeps;
    CODpenalty:=cp;
  end;
// write the fields
  labxmean.Caption:=FtoS(xmean*1000,7,3);
  labymean.Caption:=FtoS(ymean*1000,7,3);
  labxrms.Caption:=FtoS(xrms*1000,7,3);
  labyrms.Caption:=FtoS(yrms*1000,7,3);
  labxmax.Caption:=FtoS(xmax*1000,7,3);
  labymax.Caption:=FtoS(ymax*1000,7,3);
end;


procedure TOrbit.orbitCorrection;
// peform the orbit correction
var
  bvecx, bvecy,  cvecx, cvecy: array of real;
  i, iter: integer;
  knobF: Tknob;
begin
  setlength(bvecx,nocom+1);
  setlength(bvecy,nocom+1);
  setlength(cvecx,nocox+1);
  setlength(cvecy,nocoy+1);
  OrbitReCalc;
  iter:=0;
  COCorrstatus:=0;
  CODpenalty:=0;
  codstatmode:=0;
  butcodstat.Caption:='BPM';
  repeat
    Inc(iter);
    for i:=0 to nocom-1 do with bpm[iocom[i]] do begin
      bvecx[i+1]:=Opval[0,ilatb].orb[1]-Lattice[ilatb].dx-ref[0];
      bvecy[i+1]:=Opval[0,ilatb].orb[3]-Lattice[ilatb].dy-ref[1];
    end;
    SVBKSB(ocoAUx,ocoWxuse,ocoVx,nocom,nocox,bvecx,cvecx);
    SVBKSB(ocoAUy,ocoWyuse,ocoVy,nocom,nocoy,bvecy,cvecy);
    for i:=0 to nocox-1 do with cor[iocox[i]] do with Ella[jella] do dxp:=dxp-cvecx[i+1];
    for i:=0 to nocoy-1 do with cor[iocoy[i]] do with Ella[jella] do dyp:=dyp-cvecy[i+1];

{
    writeln(diagfil,'oco loop, nmon, nch, ncv: ',iter, ' ', nocom, ' ', nocox, ' ', nocoy);
    for i:=0 to nocom-1 do with bpm[iocom[i]] do begin
      writeln(diagfil, i, ' ', ref[0], ' ', ref[1]);
    end;
    for i:=0 to nocox-1 do with cor[iocox[i]] do with Ella[jella] do
      writeln(diagfil,i,' ', dxp,' | ', nam, ' ', Ella[Findel(ilat-1)].nam);
    for i:=0 to nocoy-1 do with cor[iocoy[i]] do with Ella[jella] do
      writeln(diagfil,i,' ', dyp,' | ', nam, ' ', Ella[Findel(ilat-1)].nam);
}

    OrbitReCalc;
    if Codstat then begin
      if CODpenalty<CODeps then COCorrstatus:=1 else  COCorrStatus:=2;
    end else begin
      if (iter>ncodit) then COCorrstatus:=3;
      if BeamLost then COCorrstatus:=4;
    end;
    MakePlot;
  until (COCorrStatus>0);

  bvecx:=nil; bvecy:=nil; cvecx:=nil; cvecy:=nil;
  for i:=1 to nknobs do begin
    knobF:=TKnob(FindComponent('kn_'+IntToStr(i)));

    if knobF.getElla > -1 then begin
      KnobF.KUpdate(getkval(knobF.getElla,0),false);
    end;
//    if knobF <> nil then begin
//      iel:=knobF.Tag;
//opamessage(0,'knobs i, iel '+inttostr(i)+' '+inttostr(iel));
//      if iel > -1 then KnobF.Kupdate(getkval(iel,0),false);
//    end;
  end;
end;

procedure TOrbit.ButMonAbsClick(Sender: TObject);
begin
  BPMinclude:=not BPMinclude;
  with ButMonAbs do if BPMinclude then caption:='include BPM' else caption:='exclude BPM';
  setMisalignments(dx_ransig, dy_ransig, dt_ransig, gdx_ransig, gdy_ransig, gdt_ransig, jdx_ransig, jdy_ransig);
  OrbitRecalc;
  MakePlot;
end;

procedure TOrbit.butkickClick(Sender: TObject);
begin
  UsePulsed:=not UsePulsed;
  butkicktm.enabled:=false;
  butkicktp.enabled:=false;
  edkickturns.enabled:=false;
  butsync.enabled:=false;
  if UsePulsed then begin
    butkick.Caption:=' ON ';
    butsync.enabled:=true;
    if status.Circular then begin
      butkicktm.enabled:=true;
      butkicktp.enabled:=true;
      edkickturns.enabled:=true;
    end;
  end else begin
    butkick.Caption:='OFF';
  end;
  OrbitRecalc;
  MakePlot;
end;

procedure TOrbit.ButSyncClick(Sender: TObject);
//set kicker delays to beam time of flight, to be exactly on pulse peak
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
  OrbitRecalc;
  MakePlot;
end;


procedure TOrbit.butkicktmClick(Sender: TObject);
begin
  Dec(nturns);
  if nturns<1 then nturns:=1;
  Edkickturns.Text:=InttoStr(nturns);
  Orbitcalc(-nturns);
  PlotOrbit;
end;

procedure TOrbit.butkicktpClick(Sender: TObject);
begin
  Inc(nturns);
  if nturns>ncurvesmax then nturns:=ncurvesmax;
  Edkickturns.Text:=InttoStr(nturns);
  Orbitcalc(-nturns);
  PlotOrbit;
end;

procedure TOrbit.EdkickturnsKeyPress(Sender: TObject; var Key: Char);
var
  v: real;
begin
  if TEKeyVal(edkickturns, Key, v, 2,0) then begin
    nturns:=round(v);
    if nturns<1 then nturns:=1;
    if nturns>ncurvesmax then nturns:=ncurvesmax;
    Edkickturns.Text:=InttoStr(nturns);
    Orbitcalc(-nturns);
    PlotOrbit;
  end else Edkickturns.Text:=InttoStr(nturns);
end;

procedure TOrbit.EdkickturnsExit(Sender: TObject);
begin
  Edkickturns.Text:=InttoStr(nturns);
end;

procedure TOrbit.loopAction;
var
  i, iloop: integer;
  fname: string;
  forb: textfile;

  procedure getbpmdata;
  var xm, xs, xx, ym, ys, yx: double;
  begin
    CodStatCalc(0,xm,xs,xx, ym, ys, yx);
    with OrbLoop[iloop] do begin
      xbpm[0]:=xm; xbpm[1]:=xs; xbpm[2]:=xx;
      ybpm[0]:=ym; ybpm[1]:=ys; ybpm[2]:=yx;
    end;
  end;

  procedure getelcodata;
  var xm, xs, xx, ym, ys, yx: double;
  begin
    CodStatCalc(1,xm,xs,xx, ym, ys, yx);
    with OrbLoop[iloop] do begin
      xele[0]:=xm; xele[1]:=xs; xele[2]:=xx;
      yele[0]:=ym; yele[1]:=ys; yele[2]:=yx;
    end;
    CodStatCalc(2,xm,xs,xx, ym, ys, yx);
    with OrbLoop[iloop] do begin
      xcor[0]:=xm; xcor[1]:=xs; xcor[2]:=xx;
      ycor[0]:=ym; ycor[1]:=ys; ycor[2]:=yx;
    end;
  end;
{orbloop results =orb + cor
orb = 00 nonlinear orbit found.
orb = 10 nonlinear orbit found but correction failed, correct linear orbit first, switch on non-linear and correct again.
orb = 20 nonlinear orbit NOT found, linear found and corrected, swicth on non-linear and correct again.
orb = 30 nonlinear orbit NOT found, linear found and corrected, but lost after switch on non-linear -> failure.
orb = 40 even linear orbit NOT found -> failure

cor = 0 successfull correction, zero at BPMs
cor = 1 almost successful, not zero in all BPMs
cor = 2 correction didn't converge, too many iterations -> failed
cor = 3 complete failure, lost in correction
}


begin
  iloop:=0;
  iMisAl_seed:=0;
  while (iloop < Nloop) and (loopstatus =2) do begin
    Edseed.Text:=InttoStr(iMisal_seed);
    setMisalignments(dx_ransig, dy_ransig, dt_ransig, gdx_ransig, gdy_ransig, gdt_ransig, jdx_ransig, jdy_ransig);
    for i:=0 to ncorx-1 do with Ella[Cor[icorx[i]].jella] do dxp:=0.0;
    for i:=0 to ncory-1 do with Ella[Cor[icory[i]].jella] do dyp:=0.0;
    orbmax:=1e-6;
    UseSext:=True;
    OrbitRecalc;
    MakePlot;
    if status.PerOrbit then begin // nonlinear orbit exists
      getbpmdata;
      OrbitCorrection;
      if COCorrstatus =1 then OrbLoop[iloop].result:=0 // perfect correction of nonlin orbit
      else begin // problems in correction, try linear first; add 10 to result
        UseSext:=False;
        OrbitReCalc;
        OrbitCorrection; // should always work in linear
        UseSext:=True;
        OrbitReCalc; // get non-lin orbit after linear correction, should exist in any case, since uncorr nonlin orb exists
        OrbitCorrection; //... and try again
        OrbLoop[iloop].result:=10+(COCorrstatus-1);
      end;
    end else begin // noninear orbit does not exist
      UseSext:=False;
      OrbitReCalc;
      if status.perOrbit then  begin // linear orb exists
        getbpmdata;
        OrbitCorrection; // if linear orb exists, it can be corrected (always true?)
        UseSext:=True;
        OrbitReCalc; // get non-lin orbit after linear correction...
        if status.perOrbit then begin // non-lin corrected orbit exists..
          OrbitCorrection; // correct again
          OrbLoop[iloop].result:=20+(COCorrstatus-1);
        end else begin // non-linear orbit after correction does not exist -> failure
          OrbLoop[iloop].result:=30;
        end;
      end else begin
        OrbLoop[iloop].result:=40; // even linear orb does not exist (possible for |Trace| >=2)
      end;
    end;
    getelcodata;
    MakePlot; // protect against overflow crash in plotting in case of very weird orbit?
    opaLog(0,inttostr(iloop)+' '+ inttostr(orbLoop[iloop].result));
    Inc(iMisal_seed);
    Inc(iloop); // iloop=iMisal_seed for now, but perhaps later use differently...
    Application.ProcessMessages;
  end; //while

  // evaluation of results
  if (loopstatus =2) then begin       // regular termination; write data to file

    fname:=ExtractFileName(FileName);
    fname:=work_dir+Copy(fname,0,Pos('.',fname)-1);
  //write data to file
    fname:=fname+'_orb.txt';
    assignFile(forb,fname);
{$I-}
    rewrite(forb);
{$I+}
    if IOResult =0 then begin
      for i:=0 to nloop-1 do with OrbLoop[i] do begin
        writeln(forb, i:5, result:5);
        writeln(forb, ' ', xbpm[0],' ', xbpm[1],' ', xbpm[2],' ', ybpm[0], ' ',ybpm[1], ' ',ybpm[2]);
        writeln(forb, ' ', xele[0],' ', xele[1],' ', xele[2],' ', yele[0], ' ',yele[1], ' ',yele[2]);
        writeln(forb, ' ', xcor[0],' ', xcor[1],' ', xcor[2], ' ',ycor[0], ' ',ycor[1], ' ',ycor[2]);
      end;
    end;
    CloseFile(forb);


    loopstatus:=4;
    butloop.Caption:='Done';

  end else begin // break termination, loopstatus=3: reset all
    loopstatus:=0;
    butloop.Caption:='Loop';
    Edseed.Text:=InttoStr(0);
    Edseed.Font.Color:=clBlack;
    OrbLoop:=nil;
  end;

{ in any case, reset all:  [why?]
  setMisalignments(0, 0, 0, 0, 0, 0, 0, 0);
  for i:=0 to ncorx-1 do with Ella[Cor[icorx[i]].jella] do dxp:=0.0;
  for i:=0 to ncory-1 do with Ella[Cor[icory[i]].jella] do dyp:=0.0;
  OrbitRecalc;
  MakePlot;
}

end;

procedure TOrbit.butloopClick(Sender: TObject);
var
  v: real;
begin
  case loopstatus of
    0: begin
      LabSeed.Caption:='Nseed';
      Edseed.Text:=InttoStr(Nloop);
      butloop.Caption:='Run';
      LabSeed.Font.Color:=clseedloop;
      Edseed.Font.Color:=clseedloop;
      chksext.Checked:=True;
      PrepOrbCorr;
      loopstatus:=1;
    end;

    1: begin // ready to start -> Run
      Edseed.Text;
      TEReadVal(Edseed, v, 5, 0); NLoop:=Round(v);
      SetLength(OrbLoop,NLoop);
      ReadMisalParam;
      butloop.Caption:='Break';
      LabSeed.Caption:='Seed';
      LabSeed.Font.Color:=clBlack;
      loopstatus:=2; // running
      LoopBreak:=False;
      LoopAction;
    end;

    2: begin // running -> Break
      LoopBreak:=True;
      loopstatus:=4; //tell LoopAction that break button was hit
    end;

    3: begin // must not happen
    end;

    4: begin // terminated with run -> Done, reset
      loopstatus:=0;
      butloop.Caption:='Loop';
      Edseed.Text:=InttoStr(0);
      Edseed.Font.Color:=clBlack;
      OrbLoop:=nil;
    end;
  end;
end;

procedure TOrbit.butcopyClick(Sender: TObject);
var v: real;
begin
  TEReadVal(EdEldx, v, 5, 0); EdEldy.Text:=Inttostr(round(v));
  TEReadVal(EdGidx, v, 5, 0); EdGidy.Text:=Inttostr(round(v));
  TEReadVal(EdJodx, v, 5, 0); EdJody.Text:=Inttostr(round(v));
end;


end.
