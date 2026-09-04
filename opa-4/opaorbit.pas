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


                         
unit opaorbit;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  linoplib, globlib, elemlib, georblib, StdCtrls,  knobframe, comfigureframe, ostartmenu, comauxlib, mathlib, Math,
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
    knobF: TKnob;
    bpmrect, knobrect: TRect;
    procedure ResizeAll;
    procedure LabelShow;
    procedure BPMshow;
    procedure MisAlPlotXY(ploto:TFigure);
    procedure CorPlotXY(ploto:TFigure);
    procedure OrbitPlotXY (ploto: TFigure);
    procedure PlotX;
    procedure PlotY;
    procedure WeightPlot;
    procedure MakePlot;
    procedure PrepOrbCorr;
    procedure OrbitCorrection;
    function Codstat: boolean;
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



// start, resize and close procedures -----------------------------------------

procedure TOrbit.Start (oco_inj_mode:integer);
var
  i: integer;
  boxF: TShape;
//  done: boolean;

begin

  oimode:=oco_inj_mode;

//  plotox.passFormHandle(self);
  plotox.openPlot;
//  plotoy.passFormHandle(self);
  plotoy.openPlot;
//  plotw.PassFormHandle(self);
  plotw.openPlot;
  setOrbitHandle(self);

  if oimode=0 then begin
    PanMis.Visible:=True;
    PanKick.Visible:=False;
  end;
  if oimode=1 then begin
    PanMis.Visible:=False;
    PanKick.Visible:=True;
  end;

  GirderSetup;   // set up the girders
  OrbitInit;     // initialize all for orbit correction

//  setOrbitHandles (ploto, edbpmx, edbpmxp, edbpmy, edbpmyp, labper, lablost);
//  setBPMIndex(-1);

// create GUI components for correctors and BPMs
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

  //set edit fields with default values
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
  UseSext:=chkSext.Checked;
  ButPlotOC.Caption:='Orbit+BPMs';
  ButMonAbs.Caption:='include BPM';
  Edkickturns.Text:=InttoStr(nturns);

  keepmaxval:=chkKeepMax.checked;
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
  OrbitClose;
  plotox.closePlot;
  plotoy.closePlot;
  plotw.closePlot;
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


// procedures to update GUI with data --------------------------------

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

procedure TOrbit.butcopyClick(Sender: TObject);
var v: real;
begin
  TEReadVal(EdEldx, v, 5, 0); EdEldy.Text:=Inttostr(round(v));
  TEReadVal(EdGidx, v, 5, 0); EdGidy.Text:=Inttostr(round(v));
  TEReadVal(EdJodx, v, 5, 0); EdJody.Text:=Inttostr(round(v));
end;

procedure TOrbit.ButMonAbsClick(Sender: TObject);
begin
  BPMinclude:=not BPMinclude;
  with ButMonAbs do if BPMinclude then caption:='include BPM' else caption:='exclude BPM';
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

    //will be overwritten immediately by orb correction:
    if GetResponseMatrix then begin
      LabPer.Caption:='orbit periodic';
      LabPer.Font.Color:=clGreen;
    end else begin
      LabPer.Caption:='orbit not periodic';
      LabPer.Font.Color:=clRed;
    end;

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
begin
  OrbitExit;
  Close; //will call OrbitClose on closing form
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

// orbit procedures

function TOrbit.Codstat: boolean;
// orbit statistics: return true if the xrms orbit is the same like in step before
var
  xmean, ymean, xrms, yrms, xmax, ymax, cp: double;
begin
  if loopstatus=4
  then begin
    Edseed.text:=inttostr(LoopStatCalc(codstatmode, xmean, xrms, xmax, ymean, yrms, ymax));
    Edseed.font.color:=clBlue;
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
  i, iter: integer;
  knobF: Tknob;
begin
  oco_init;
  iter:=0;
  butcodstat.Caption:='BPM';
  repeat
    Inc(iter);
    oco_step;
    if Codstat then begin
      if CODpenalty<CODeps then COCorrstatus:=1 else  COCorrStatus:=2;
    end else begin
      if (iter>ncodit) then COCorrstatus:=3;
      if BeamLost then COCorrstatus:=4;
    end;
    MakePlot;
  until (COCorrStatus>0);
  oco_term;
  for i:=1 to nknobs do begin
    knobF:=TKnob(FindComponent('kn_'+IntToStr(i)));

    if knobF.getElla > -1 then begin
      KnobF.KUpdate(getkval(knobF.getElla,0),false);
    end;
  end;
end;



// orbit correction loop
// procs are here and not in georblib because MakePlot is called in the loop

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

// injection simulation


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
begin
  SyncKickers;
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



end.
