unit opalinop;

{$MODE Delphi}

interface
                                                               
uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, Clipbrd, printers, ExtCtrls, {FGraph,} StdCtrls, Grids,
  globlib, knobframe, linoplib, ostartmenu, {OpticMom,} obetenvmag, otunematrix,
  mathlib, oeleedit, opatunediag, asaux, vgraph;

type

  { Toptic }

  Toptic = class(TForm)
    butex: TButton;
    butnlin: TButton;
    butkick: TButton;
    pw: TPaintBox;
    tab: TStringGrid;
    butgrid: TPanel;
    butexit: TButton;
    butstar: TButton;
    butenvl: TButton;
    butmatc: TButton;
    butwomk: TButton;
    buleftedge: TButton;
    burightedge: TButton;
    buleft: TButton;
    buright: TButton;
    buzoomin: TButton;
    buzoomout: TButton;
    bufullview: TButton;
    buyup: TButton;
    buydown: TButton;
    buyauto: TButton;
    buyDup: TButton;
    buyDdown: TButton;
    buttune: TButton;
    butdata: TButton;
    buteps: TButton;
    bucsave: TButton;
    bucclear: TButton;
    procedure butkickClick(Sender: TObject);
    procedure pwPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure pwMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure butexitClick(Sender: TObject);
    procedure pwMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pwMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    procedure butstarClick(Sender: TObject);
//    procedure butmomtClick(Sender: TObject);
    procedure butenvlClick(Sender: TObject);
    procedure tabDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure buleftedgeClick(Sender: TObject);
    procedure buleftClick(Sender: TObject);
    procedure buzoominClick(Sender: TObject);
    procedure buzoomoutClick(Sender: TObject);
    procedure bufullviewClick(Sender: TObject);
    procedure burightClick(Sender: TObject);
    procedure burightedgeClick(Sender: TObject);
    procedure buyupClick(Sender: TObject);
    procedure buydownClick(Sender: TObject);
    procedure buyautoClick(Sender: TObject);
    procedure buyDupClick(Sender: TObject);
    procedure buyDdownClick(Sender: TObject);
    procedure butmatcClick(Sender: TObject);
    procedure butwomkClick(Sender: TObject);
    procedure buttuneClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var mycloseAction: TCloseAction);
    procedure butdataClick(Sender: TObject);
    procedure butepsClick(Sender: TObject);
    procedure butnlinClick(Sender: TObject);
    procedure bucsaveClick(Sender: TObject);
    procedure bucclearClick(Sender: TObject);
    procedure varbutMouseUp(Sender: TObject; Button: TMouseButton;
       Shift: TShiftState; X, Y: Integer);
    procedure varbutMouseDown(Sender: TObject; Button: TMouseButton;
       Shift: TShiftState; X, Y: Integer);
//    procedure butcokiClick(Sender: TObject);


  private
    tablewidth: integer;
    bts: TBitMap;
    iselectedElem, knobwidth: integer;
    knobrect, pwrect, btsrect: TRect;
    smin, smax, sfull, smid, swidth: real;
    Zoomfac: integer;
    yofffind, ythinfind, ythckfind: integer;
    firstCallMakePlot: boolean;
    xoff_vbpw, yoff_vbpw: array of integer;
    Nvarbut:integer;
    indvarbut: array of integer;
    Variable_Save: array of Variable_Type;
    function  GetElemMouse(x,y: integer): integer;
    procedure FormSize;
    procedure ComPlot;
    procedure MakePlot ;
    procedure Zoom (pixhor: integer);
  public
    procedure Init (TunePlotHandle: TTunePlot);
  end;

var
  optic: Toptic;
  knobF: TKnob;
  nknobs: integer;


implementation

uses omatching, owriteomrk;

{$R *.lfm}



const
  xoff=60{50}; xtop=80;
//  yoff=50; ytop=20;
  yoff=20; ytop=50;
  dythick=10; dythin=20; dyband=25;
  fxcor=0.05; //width for correctors ?????preliminary
  sidespace=6; midspace=10; kgheight=120; twidth=210; pgheight=20;
  fontn='Courier New'; fonts=12; fontc=clBlue;
  ZoomBase=0.7; maxZoomfac=20; betafac=0.7;

var
  pjtk, pjth, pilh, pilk: array of integer;
  butwid, buthgt: integer;
  dyscale: real; //not very elegant scaling of element line up height for printing

procedure Toptic.FormClose(Sender: TObject; var mycloseAction: TCloseAction);
var
  i:integer;
  knobF: TKnob;
  varbut:TLabel;
begin
//  bts.free;
  FreeAndNil(bts);
  pjtk:=nil; pjth:=nil; pilk:=nil; pilh:=nil;

  for i:=1 to 10 do begin
    knobF:=TKnob(FindComponent('kn_'+IntToStr(i)));
    if knobF <> nil then knobF.free;
  end;

  for i:=0 to Nvarbut-1 do begin
    varbut:=TLabel(FindComponent('varbut_'+InttoStr(i)));
    if varbut <> nil then varbut.free;
  end;

  for i:=0 to High(Variable) do Variable[i]:=Variable_Save[i];
  Variable_Save:=nil;

  ClearOpval;
  CurvePlot.enable:=False;

//close tune diagram (in optic plot)
  CloseTuneDiagram;

// enable main menu buttons: sextupoles and tracking if per/sym was found
  MainButtonEnable;
  status.tuneshifts:=false; //have changed most likely
  status.alphas:=false;
  EditElemSet.Exit;
  setEnvel.Exit;
  if startsel<>nil then startsel.Exit;
end;

procedure Toptic.butexitClick(Sender: TObject);
var
//  ia, i, iel: integer;
//  check: boolean;
  i, mr: word;
begin

//on Exit only check for changes ella vs. elem and save defaults
//(if form was closed by close button no check is done)
  mr:=EllaSave;
{
 comparison of Variable vs. Variable_save probably not necessary,
 because any change should cause a change of an element.
// for i:=0 to High(Variable) do writeln(diagfil, Variable[i].exp,' ',Variable_save[i].exp);
 if we want to save the parameters, we overwrite the safety copy of variables with actual values,
 because Close will write the safety copy to the true Variable.
}

// this catch is req'd to avoid error in case of no Variables exist; but makes no sense ???
//                 VVVVVVVVVVVVVVVVVVVVV
// wahrscheinlich nur pseudo Loesung, da error aufgrund von memory leak, hat nichts mit dieser Zeile zu tun
  if mr=mrYes then if Length(Variable)>0 then for i:=0 to High(Variable) do Variable_Save[i]:=Variable[i];

  DefSet('optic/width' ,width );
  DefSet('optic/height',height);
  DefSet('optic/left'  ,left  );
  DefSet('optic/top'   ,top   );
  DefSet('optic/dpmult', dpmult);

  if mr <> mrCancel then Close;
end;



procedure Toptic.FormSize;
var
 i,j,k,kgtop,varhgt,varwid,vartop: integer;
 pgwidth: real;
 varbut: TLabel;
 knobarr, knobbro: array of TKnob;

begin
  tab.width:=tablewidth;

  pw.width :=clientwidth-tab.width-midspace-2*sidespace;
  if pw.width < 200 then pw.width:=200;
  pw.left   :=sidespace;
  tab.top   :=sidespace;
  pw.top    :=tab.top+pgheight;
  tab.left  :=pw.left+pw.width+midspace;
  if nvarbut >0 then varhgt:=16 else  varhgt:=0;
  tab.height:=clientheight-kgheight-midspace-varhgt-2*sidespace;
  pw.height :=tab.height-pgheight;

  vp.SetArea(pw.width, pw.height);

  kgtop:=clientheight-kgheight-sidespace;
  butgrid.setBounds(tab.left, kgtop, tab.width, kgheight);

// keep shift of varbut coord to pw coord, because knobrect is in pw coord
  if NVarbut>0 then begin
    vartop:=kgtop-midspace div 2 -varhgt;
    varwid:=(pw.width-sidespace) div Nvarbut;
    if varwid > 100 then varwid:=100;
    for i:=0 to Nvarbut-1 do begin
      varbut:=TLabel(FindComponent('varbut_'+InttoStr(i)));
      if varbut <> nil then begin
        varbut.setBounds(sidespace+i*varwid, vartop, varwid-sidespace, varhgt);
        xoff_vbpw[i]:=varbut.Left-pw.Left;
        yoff_vbpw[i]:=varbut.Top-pw.Top;
      end;
    end;
  end else varhgt:=0;

{create as many knobs as fit into the form:}
  nknobs:=round(pw.width/200);
  knobwidth:=trunc(pw.width/nknobs);
  {knobs are named kn_1,2,3...}
  setlength(knobarr,nknobs);
  for i:=1 to nknobs do begin
    knobF:=TKnob(FindComponent('kn_'+IntToStr(i)));
    if knobF = nil then begin
      knobF:=TKnob.Create(self);
      knobF.parent:=Self;
//      knobF.name:= 'kn_'+IntToStr(i);
//      knobF.labNam.caption:='Knob '+inttostr(i);
      knobF.Init(i);
    end;
    knobF.setSize(sidespace+(i-1)*knobwidth, kgtop, knobwidth, kgheight);
    knobarr[i-1]:=knobF;
  end;

//provide handles for each knob to all other knobs excluding itself
  setlength(knobbro,nknobs-1);
  for i:=0 to nknobs-1 do begin
//    s:='';
    k:=-1;
    for j:=0 to nknobs-1 do begin
      if j<>i then begin
        inc(k);
        knobbro[k]:=knobarr[j];
//        s:=s+' '+inttostr(j);
      end;
    end;
    knobarr[i].BrotherHandles(knobbro);
  end;

  for i:=nknobs+1 to 10 do begin
    knobF:=TKnob(FindComponent('kn_'+IntToStr(i)));
    if knobF <> nil then knobF.free;
  end;
{rectangle around knobs in pw coordinates;}
  knobrect  :=Rect(0, pw.height+midspace+varhgt, pw.width, pw.height+midspace+varhgt+kgheight);
  butwid:=tab.width div 3;
  buthgt:=kgheight div 3;
  butstar.setbounds(       0,        0, butwid, buthgt);
  butenvl.setbounds(  butwid,        0, butwid, buthgt);
//  butcoki.setbounds(  butwid, buthgt div 2, butwid,  buthgt div 2);
//  butmomt.setbounds(2*butwid,        0, butwid, buthgt);
  buttune.setbounds(       0,   buthgt, butwid, buthgt);
  butmatc.setbounds(  butwid,   buthgt, butwid, buthgt);
  butwomk.setbounds(2*butwid,   buthgt, butwid, buthgt);

  butnlin.setbounds(       0, 2*buthgt, butwid, buthgt div 2);
  butkick.setbounds(       0, 5*buthgt div 2, butwid, buthgt div 2);
  butdata.setbounds(  butwid, 2*buthgt, butwid ,buthgt div 2);
  buteps.setbounds(   butwid, 5*buthgt div 2, butwid , buthgt div 2);
  butexit.setbounds(2*butwid, 2*buthgt, butwid, buthgt);

{small buttons for plotcontrol}
  pgwidth :=pw.width / 14;
  buleftedge.setbounds (sidespace+ round(0*pgwidth),sidespace, round(pgwidth), pgheight);
  buleft.setbounds     (sidespace+ round(1*pgwidth),sidespace, round(pgwidth), pgheight);
  buzoomin.setbounds   (sidespace+ round(2*pgwidth),sidespace, round(pgwidth), pgheight);
  buzoomout.setbounds  (sidespace+ round(3*pgwidth),sidespace, round(pgwidth), pgheight);
  bufullview.setbounds (sidespace+ round(4*pgwidth),sidespace, round(pgwidth), pgheight);
  buright.setbounds    (sidespace+ round(5*pgwidth),sidespace, round(pgwidth), pgheight);
  burightedge.setbounds(sidespace+ round(6*pgwidth),sidespace, round(pgwidth), pgheight);
  buyup.setbounds      (sidespace+ round(7*pgwidth),sidespace, round(pgwidth), pgheight);
  buydown.setbounds    (sidespace+ round(8*pgwidth),sidespace, round(pgwidth), pgheight);
  buyDup.setbounds     (sidespace+ round(9*pgwidth),sidespace, round(pgwidth), pgheight);
  buyDdown.setbounds   (sidespace+round(10*pgwidth),sidespace, round(pgwidth), pgheight);
  buyauto.setbounds    (sidespace+round(11*pgwidth),sidespace, round(pgwidth), pgheight);
  bucsave.setbounds    (sidespace+round(12*pgwidth),sidespace, round(pgwidth), pgheight);
  bucclear.setbounds   (sidespace+round(13*pgwidth),sidespace, round(pgwidth), pgheight);

  //FInit(pw.Canvas, pw.width, pw.height);
end;


{-----------------------------------------------------------------}

procedure Toptic.Init (TunePlotHandle: TTunePlot);
var
  w, h, l, t, i: integer;
  varbut: Tlabel;
begin
  
  vp:=Vplot.Create(pw.Canvas);
//restore form size of get reasonable defs if invalid
  w:=IDefGet('optic/width');
  h:=IDefGet('optic/height');
  l:=IDefGet('optic/left');
  t:=IDefGet('optic/top');
  if (w<300) or (w>screen.width) or (h<300) or (h>screen.height) then begin
    w :=round(0.8*screen.width);
    h :=round(0.8*screen.height);
  end;
  if  (l<0) then l:=(screen.width-w) div 2;
  if  (t<0) then t:=(screen.height-h) div 2;
  setBounds( l,t,w,h);
  tablewidth:=twidth;
  FormSize;

  bts:=TBitmap.create;

// pass table handle to linoplib
  SetTabHandle(tab);
  SetTunePlotHandle(TunePlotHandle);

// allocate mem for global field of optic data:
  allocOpval;

// betas not yet calculated:
  status.betas:=false;

  OpticPlotMode:=BetPlot;
  PerMode:=false;
  SymMode:=false;
  OpticStartMode:=-1; {undefined to start without selection}

// default settings for momentum mode:
  dppmode:=false;
  MomMode:=False;

  UseSext:=False;
  UsePulsed:=False;
  showBetas[1]:=true; ShowBetas[2]:=false; ShowBetas[3]:=false;
  PropperTest:=false; PropperDone:=false;
  butnlin.Caption:=' linear  ';
  butkick.Caption:='Kicker OFF';

  dPMult :=FDefGet('optic/dpmult');

  ncurves:=0;
  firstCallMakePlot:=True;
  Zoomfac:=0;
  xautoscale:=true;
  buyauto.Caption:='auto';
  ShowDisp:=1;
  CurvePlot.enable:=True;
  StartSel:=nil;
  //otherwise MakePlot creates large number of Startsel instances...
  status.tmatrix:=false; status.cmatrix:=false;
  csaveaction:=2;

  setLength(Variable_Save, Length(Variable));
  for i:=0 to High(Variable) do Variable_Save[i]:=Variable[i];
  for i:=0 to High(Variable) do Variable[i].use:=false;
  for i:=1 to Glob.NElla do Ella_Eval(i); //just to set the use flag of variable

  Nvarbut:=0;
  indvarbut:=nil;
   for i:=0 to High(Variable) do if Variable[i].use then begin
    varbut:=TLabel(FindComponent('varbut_'+IntToStr(Nvarbut)));
    if varbut = nil then begin
      varbut:=TLabel.Create(self);
      varbut.parent:=Self;
      varbut.OnMouseDown:=varbutMouseDown;
      varbut.OnMouseUp:=varbutMouseUp;
      with varbut do begin
        name:='varbut_'+InttoStr(nvarbut);
        Caption:=Variable[i].nam;
        Alignment:=taCenter;
        Font.Name:='Courier New'; Font.Size:=12;
//        Font.Style:=[fsbold];
        if Variable[i].exp='' then Color:=clYellow else Color:=clLightYellow;
        Tag:=nvarbut;
      end;
    end;
    setlength(indvarbut,Length(indvarbut)+1);
    indvarbut[High(indvarbut)]:=i;
    inc(Nvarbut);
  end;
{  setlength(xoff_vbpw,Length(Variable));
  setlength(yoff_vbpw,Length(Variable));
}
  setlength(xoff_vbpw,NVarbut);
  setlength(yoff_vbpw,NVarbut);
  //Resize; //to adjust butwomk size

  with pw.canvas.Font do begin
    Color:=clblack;
    Size:=12;
    Name:='Courier New'  ;
  end;

  FormSize;
end;

{-----------------------------------------------------------------}

procedure Toptic.ComPlot;
//common part of MakePlot and PrintPlot;
var
  i, j, jcod, pixhor: integer;
  s, fx1, fx2, fy1, fypos: Real;
  col: TColor;
begin

  with pw.Font do begin
    Size:=fonts; Name:=fontn; Color:=fontc;
  end;
  pixhor:=pw.width;
  vp.Clear (clWhite);
  s:=0.0;
  for i:=1 to Glob.NLatt do begin
    s:=s+Ella[FindEl(i)].l;
  end;
  sfull:=s;
  Zoom (pixhor);
  vp.setRangeX(smin, smax);
  vp.Axis(1,clBlack,'');

  vp.SetRangeY(0,0); //--> forces pixel scale: px=x

  //  FAxPlot(smin,smax,0,1,5,1,clBlack,'');


  fy1:=dyband*dyscale;
  s:=0.0;
  vp.SetStyle(psSolid);  vp.SetThick(1);
  for i:=1 to Glob.NLatt do begin
    j:=FindEl(i);
    jcod:=ella[j].cod;
    fx1:=s;
    fx2:=s+ella[j].l;
    if (fx2 >= smin) and (fx1 <=smax) then begin
      if fx1<smin then fx1:=smin;
      if fx2>smax then fx2:=smax;
      col:=ElemCol[jcod];
      vp.SetColor(col);
      if ella[j].l<>0 then begin
        if (jcod <> cdrif) or (ella[j].block) then vp.Solid(fx1,fy1,fx2,fy1+dythick*dyscale,col);
      end else begin
        case jcod of
//          comrk: FLine(fx1,0,fx1, FGety(0)); // crota too?
          ccorh: begin
            fypos:=fy1+0.25*dythin*dyscale;
            vp.Line(fx1-fxcor,fypos,fx1+fxcor,fypos);
          end;
          ccorv: begin
            fypos:=fy1+0.75*dythin*dyscale;
            vp.Line(fx1-fxcor,fypos,fx1+fxcor,fypos);
          end;
          else vp.Line(fx1,fy1,fx1,fy1+dythin*dyscale);
        end;
      end;
    end; {if }
    s:=s+Ella[j].l;
  end; {for}

end;

//-----------------------------------------------------------------

procedure Toptic.MakePlot ;
var
  i, j, ipix: integer;
  s, fx1, fx2: Real;
begin
  dyscale:=1;

  vp.SetMargin(xoff, xtop, yoff, ytop);
  vp.SetRange(0,1,0,-1);

  ComPlot;

// prepare for mouse operations:
//   set arrays to assign element index to pixel

  setLength(pjtk,pw.width+1);
  setLength(pjth,pw.width+1);
  setLength(pilk,pw.width+1);
  setLength(pilh,pw.width+1);

  for ipix:=0 to pw.width do begin
    pjtk[ipix]:=-1;
    pjth[ipix]:=-1;
    pilk[ipix]:=-1;
    pilh[ipix]:=-1;
  end;

// pass through element line-up (same loop as before used for plotting)

  s:=0.0;
  for i:=1 to Glob.NLatt do begin
    j:=FindEl(i);
    fx1:=s;
    fx2:=s+ella[j].l;

    if (fx2 >= smin) and (fx1 <=smax) then begin
      if fx1<smin then fx1:=smin;
      if fx2>smax then fx2:=smax;
      if ella[j].l<>0 then begin
          for ipix:=vp.GetPx(fx1) to vp.GetPx(fx2) do begin
          pjtk[ipix]:=j;
          pilk[ipix]:=i;
        end;
      end else begin
          for ipix:=vp.GetPx(fx1)-1 to vp.GetPx(fx1)+1 do begin
          pjth[ipix]:=j;
          pilh[ipix]:=i;
        end;
      end;
    end; {if }
    s:=s+Ella[j].l;
  end; {for}

//set range parameters for mouse to grab elements:
  yofffind :=vp.getPy(dyband);
  ythinfind:=vp.GetPy(dyband+dythin);
  ythckfind:=vp.GetPy(dyband+dythick);

// save element line to bitmap to restore after mouse actions

//  bts:=tBitmap.create; //this was created on init already
  bts.height:=ytop; bts.width:=pw.width-xoff-xtop;
  pwrect := Rect(xoff,pw.height-ytop,pw.width-xtop,pw.height);

  btsrect:= Rect(0,0,bts.width,bts.height);
  bts.Canvas.CopyRect(btsrect, pw.canvas, pwrect);

//  iselectedElem:=-1;
// done with preparation for mous
  OOmode:=false;
// special treatment on first call (applies only to interactive mode)
  if firstCallMakePlot then begin
//not very elegant but otherwise start menu will be in the background (?)
    iselectedElem:=-1;
    if StartSel=nil then begin
    // take care to create only 1 instance of startsel
      StartSel:=TStartSel.Create(Application);
      StartSel.Load (0,self);
//      StartSel.ShowModal;
      StartSel.Show;
      firstCallMakePlot:=false;
    end;
    // default: plot betamarker at end
    ibetamark:=Glob.NLatt;
  end;

  vp.setmarginY(yoff,ytop);

// finally, do the plot:
  case OpticPlotMode of
    MagPlot: PlotMag;
    EnvPlot: if status.betas then PlotEnv;
    else if status.betas then PlotBeta;
  end;
end;



procedure Toptic.pwPaint(Sender: TObject);
begin
  MakePlot;
end;



procedure Toptic.FormResize(Sender: TObject);
begin
  FormSize;
end;


function TOptic.GetElemMouse(x,y: integer): integer;
var i: integer;
begin
  i:=-1;
{check x for safety? crashed one here}
// - nein, scheint memory leak zu sein, hat mit diesem code nichts zu tun :-(
  if (y>yofffind) then begin
    if y<ythckfind then i:=pjtk[x] else
    if y<ythinfind then i:=pjth[x];
  end;
  GetElemMouse:=i;
end;

procedure Toptic.pwMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  tsw, tsh: integer;
  isel, xpos, ypos: integer;
begin
  isel:=GetElemMouse(x,y);
  if isel >=0 then begin
    pw.Cursor:=crHandPoint;
    with pw.canvas.TextExtent(ella[isel].nam) do begin
      tsw:=width; tsh:=height;
    end;
    with pw.canvas do begin
      CopyRect(pwrect, bts.canvas, btsrect);
      brush.color:=clwhite;
      font.color:=clblack;
//??      font.color:=clwhite;
      xpos:=x-tsw div 2;
      ypos:=yofffind-tsh-2;
      if xpos<xoff then xpos:=xoff;
      if xpos+tsw >pw.width-xtop then xpos:=pw.width-xtop-tsw;
      TextOut(xpos, ypos, ella[isel].nam);
    end;
  end else begin
    pw.canvas.CopyRect(pwrect, bts.canvas, btsrect);
    pw.Cursor:=crCross;
  end;
end;

procedure Toptic.pwMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  iknob,iel, ilat, id1, id2: integer;
  kn: TKnob;
  pic: TBitmap;
  rec: TRect;

begin
// find element selected by mouseclick
  iselectedElem:=-1;
  if ssLeft in Shift then begin
    iel:=GetElemMouse(x,y);
    if iel > -1 then begin
      if ssDouble in Shift then begin
        // unload knob if element is connected:
        for iknob:=1 to nknobs do begin
          kn:=TKnob(FindComponent('kn_'+IntToStr(iknob)));
          if kn.getella=iel then kn.UnLoad;
        end;
      // double left click: launch element set-up if not drift
        if EditElemSet=nil then EditElemSet:=TEditElemSet.Create(Application);
        EditElemSet.InitO (iel, pw);
        EditElemSet.Show;
      end else begin
      // single left click: keep index of element to connect to knobframe on mouseUp
        iselectedElem:=iel;
      end;
    end else begin
      if ssDouble in Shift then vp.GrabImage
    end;
  end;

  // find lattice pos for mouse to show beta function
  if ssRight in Shift then begin
  // prefer thin element, if nothing there, take thick one
    if pilh[x] = -1 then ilat:=pilk[x] else ilat:=pilh[x];

    if ilat<=0 then begin
  // i.e. out of plot range
  // mouse closer to end than start - set ilat to end else start
      if (pw.width-x) < x then ilat:=glob.NLatt else ilat:=0;
    end else begin
  // in plot range: use closer element as reference
//      id1:=abs(x-FGetPx(Opval[0,ilat-1].spos));
//      id2:=abs(x-FGetPx(Opval[0,ilat  ].spos));
      id1:=abs(x-vp.GetPx(Opval[0,ilat-1].spos));
      id2:=abs(x-vp.GetPx(Opval[0,ilat  ].spos));
      if id1 < id2 then ilat:=ilat-1;
    end;
  // mark with a line and refresh table
    FillBetaTab(ilat);
    MakePlot;
  end;

end;

procedure Toptic.pwMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

var
  iknob: integer;
  kn: TKnob;
  found: boolean;
begin

  if iselectedElem >-1 then begin
    if  insideRect(x,y,knobrect) then begin
      found:=false;
      for iknob:=1 to nknobs do begin
        kn:=TKnob(FindComponent('kn_'+IntToStr(iknob)));
        found:=found or (kn.getElla=iselectedElem);
      end;
      if found then begin
        MessageDlg('Element '+ella[iselectedElem].nam+' is already connected.',
          mtWarning, [mbok],0);
      end else begin
        if EditElemSet<>nil then if (iselectedElem=EditElemSet.getJelem) then EditElemSet.Exit;
        iknob:=x div knobwidth+1;
        kn:=TKnob(FindComponent('kn_'+IntToStr(iknob)));
        kn.Load(iselectedElem, pw);
      end;
    end;
  end;
  iselectedElem:=-1;
  pw.Cursor:=crCross;
end;


procedure Toptic.butstarClick(Sender: TObject);
begin
  if StartSel= nil then StartSel:=TStartSel.Create(Application);
  StartSel.Load (0,self);
//  StartSel.ShowModal;
  StartSel.Show;
end;

procedure Toptic.butnlinClick(Sender: TObject);
begin
  UseSext:=not UseSext;
  if UseSext then begin
    butnlin.Caption:='nonlinear';
  end else begin
    butnlin.Caption:=' linear  ';
  end;
  OpticReCalc;
  case OpticPlotMode of
    MagPlot: PLotMag;
    EnvPlot: PlotEnv;
    else PlotBeta;
  end;
end;

procedure Toptic.butkickClick(Sender: TObject);
begin
  UsePulsed:=not UsePulsed;
  if UsePulsed then begin
    butkick.Caption:='Kicker ON';
  end else begin
    butkick.Caption:='Kicker OFF';
  end;
  OpticReCalc;
  if OpticPlotMode=EnvPlot then PlotEnv else if OpticPlotMode=BetPlot then PlotBeta;
end;


procedure Toptic.butenvlClick(Sender: TObject);
begin
  if setEnvel=nil then setEnvel:= TSetEnvel.Create(Application);
  setEnvel.Load (buyauto);
 // setEnvel.ShowModal;
  setEnvel.Show;
end;

procedure Toptic.tabDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  b, c: TColor;
begin
  if acol>=2 then begin
    if (arow=0) and (PerMode or SymMode) then begin
      if oBeam[acol-2].persym then b:=clLime else b:=clRed;
    end else b:=clWhite;
//    if MomMode then begin
    // color control: acol=3 minus, acol=4 plus tabrowcol 1=x, 2=y, 3=Dx, 5=Dy
      case (TabRowCol[ARow] + 10*ACol) of
        34: c:=dpm_col;
        44: c:=dpp_col;
        21: c:=betax_col;
        31: c:=betax_col_m;
        41: c:=betax_col_p;
        22: c:=betay_col;
        32: c:=betay_col_m;
        42: c:=betay_col_p;
        23: c:=dispx_col;
        33: c:=dispx_col_m;
        43: c:=dispx_col_p;
        25: c:=dispy_col;
        35: c:=dispy_col_m;
        45: c:=dispy_col_p;
        else c:=clBlack;
      end;
//    end else begin
//      if ncurves>0 then c:=dimcol(clWhite, clBlack, (acol-2)/ncurves ) else c:=clBlack;
//    end;
  end else begin
    if ARow > ibetatab then b:=clGray else b:=clLtGray;
    if (ARow=0) and (SymMode or perMode) then b:=clLightYellow;
    c:=clBlack;
  end;

  with tab.Canvas do begin
    Brush.Color:=b; Font.Color:=c;
    FillRect(Rect);
    TextOut(Rect.Left+2, Rect.Top+2, tab.Cells[ACol, ARow]);
  end;
end;

procedure Toptic.Zoom(pixhor:integer);
begin
  swidth:=sfull*PowI(ZoomBase,Zoomfac);
  if smid < swidth/2 then smid:=swidth/2;
  if smid > sfull-swidth/2 then smid:=sfull-swidth/2;
  smin:=smid-swidth/2;
  smax:=smid+swidth/2;
  CurvePlot.sini :=smin;
  CurvePlot.sfin :=smax;
  CurvePlot.slice:=swidth/pixhor; // resolution for plot
end;

procedure Toptic.buleftedgeClick(Sender: TObject);
begin
  smid:=swidth/2;
  MakePlot;
end;

procedure Toptic.buleftClick(Sender: TObject);
begin
  smid:=smid-swidth/3;
  MakePlot;
end;

procedure Toptic.buzoominClick(Sender: TObject);
begin
  Inc(Zoomfac);
  if Zoomfac > maxZoomfac then Zoomfac:=MaxZoomfac;
  MakePlot;
end;

procedure Toptic.buzoomoutClick(Sender: TObject);
begin
  Dec(Zoomfac);
  if Zoomfac < 0 then Zoomfac:=0;
  MakePlot;
end;

procedure Toptic.bufullviewClick(Sender: TObject);
begin
  Zoomfac:=0;
  MakePlot;
end;

procedure Toptic.burightClick(Sender: TObject);
begin
  smid:=smid+swidth/3;
  MakePlot;
end;

procedure Toptic.burightedgeClick(Sender: TObject);
begin
  smid:=sfull-swidth/2;
  MakePlot;
end;

procedure Toptic.buyupClick(Sender: TObject);
begin
  xautoscale:=false;
  buyauto.Caption:='fixed';
  if status.betas then begin
    if OpticPlotMode=EnvPlot then begin
      envelmaxx:=envelmaxx*betafac;
      PlotEnv;
    end;
    if OpticPlotMode=BetPlot then begin
      betamax:=betamax*betafac;
      PlotBeta;
    end;
  end;
end;

procedure Toptic.buydownClick(Sender: TObject);
begin
  xautoscale:=false;
  buyauto.Caption:='fixed';
  if status.betas then begin
    if OpticPlotMode=EnvPlot then begin
      envelmaxx:=envelmaxx/betafac;
      PlotEnv;
    end;
    if OpticPlotMode=BetPlot then begin
      betamax:=betamax/betafac;
      PlotBeta;
    end;
  end;
end;

procedure Toptic.buyautoClick(Sender: TObject);
begin
  xautoscale:=not xautoscale;
  if xautoscale then buyauto.Caption:='auto' else buyauto.Caption:='fixed';
  if status.betas then if OpticPlotMode=EnvPlot then PlotEnv else if OpticPlotMode=BetPlot then PlotBeta;
end;

procedure Toptic.buyDupClick(Sender: TObject);
begin
  if status.betas then begin
    xautoscale:=false;
    buyauto.Caption:='fixed';
    if OpticPlotMode=EnvPlot then begin
      envelmaxy:=envelmaxy*betafac;
      PlotEnv;
    end else if OpticPlotMode=BetPlot then begin
      case ShowDisp of
        1: dispmax:=dispmax*betafac;
        2: orbmax:=orbmax*betafac;
        3: cdetmax:=cdetmax*betafac;
      end;
      PlotBeta;
    end;
  end;
end;

procedure Toptic.buyDdownClick(Sender: TObject);
begin
  if status.betas then begin
    xautoscale:=false;
    buyauto.Caption:='fixed';
    if OpticPlotMode=EnvPlot then begin
      envelmaxy:=envelmaxy/betafac;
      PlotEnv;
    end else if OpticPlotMode=BetPlot then begin
      case ShowDisp of
        1: dispmax:=dispmax/betafac;
        2: orbmax :=orbmax/betafac;
        3: cdetmax:=cdetmax/betafac;
      end;
      PlotBeta;
    end;
  end;
end;

procedure Toptic.bucsaveClick(Sender: TObject);
begin
  if OpticPlotMode=BetPlot then begin
    csaveaction:=1;
    PlotBeta;
  end;
end;

procedure Toptic.bucclearClick(Sender: TObject);
begin
  if OpticPlotMode=BetPlot then begin
    csaveaction:=2;
    PlotBeta;
  end;
end;

procedure Toptic.butmatcClick(Sender: TObject);
var
  knarr: array of TKnob;
  i:integer;
begin
  if Match=nil then begin
    Match:= TMatch.Create(Application);
  end;
  setlength(knarr, nknobs);
  for i:=1 to nknobs do begin
    knarr[i-1]:=TKnob(FindComponent('kn_'+IntToStr(i)));
  end;
  Match.Load(pw,knarr);
  try
    Match.ShowModal;
  finally
    FreeAndNil(Match);
  end;
end;

procedure Toptic.butwomkClick(Sender: TObject);
begin
  // current optic data store in optics marker, select menue
  if womk=nil then womk:=TWOMK.Create(Application);
  womk.Load;
  try
    womk.ShowModal;
  finally
    FreeAndNil(womk);
  end;
end;

{
Tuning Matrix: calc. dk/k vs. dQ for F and D quad groups
set new tunes
enabled only if periodic solution exists and MomMode off
}
procedure Toptic.buttuneClick(Sender: TObject);
begin
  if tuneMatrix= nil then tuneMatrix:=TtuneMatrix.Create(Application);
  tuneMatrix.Load;
  try
    tuneMatrix.ShowModal;
  finally
    FreeAndNil(tuneMatrix);
  end;
end;



procedure Toptic.butdataClick(Sender: TObject);
var
  fnam0: string;
begin
  fnam0:=ExtractFileName(FileName);
  fnam0:=work_dir+Copy(fnam0,0,Pos('.',fnam0)-1);
  PrintLatticeData(fnam0);
  PrintCurve(fnam0);
  PrintRadiation(fnam0);
  PrintMagnets(fnam0);
  if length(fnam0)>0 then
    MessageDlg('Lattice parameters, betas, magnet and SR data written to '+fnam0+'_data/_beta/_mag/_rad.txt', MtInformation, [mbOK],0);
end;
{//tmp
procedure Toptic.butGNUClick(Sender: TObject);
begin
  PrintGNU;
  MessageDlg('Data exported for GNUplot postprocessing (.gp, .out)', MtInformation, [mbOK],0);
end;
}

procedure Toptic.butepsClick(Sender: TObject);
var
  errmsg, epsfile: string;
begin
  epsfile:=ExtractFileName(FileName);
  epsfile:=work_dir+Copy(epsfile,0,Pos('.',epsfile)-1);
  case OpticPlotMode of
    MagPlot: epsfile:=epsfile+'_magfd';
    EnvPlot: epsfile:=epsfile+'_envel';
    else     epsfile:=epsfile+'_betas';
  end;
  epsfile:=epsfile+'.eps';
  vp.PS_start(epsfile,OPAversion, errmsg);
  if length(errmsg)>0 then begin
    MessageDlg('PS export failed: '+errmsg, MtError, [mbOK],0);
  end else begin
    MakePlot;
    vp.PS_stop;
    MessageDlg('Graphics exported to '+epsfile, MtInformation, [mbOK],0);
    MakePlot;
  end;
end;


procedure  Toptic.varbutMouseDown(Sender: TObject; Button: TMouseButton;
       Shift: TShiftState; X, Y: Integer);
var
  iknob, ivar, ivarbut: integer;
  kn: TKnob;
  vb: TLabel;
begin
  if ssDouble in Shift then begin
    vb:=sender as TLabel;
    ivarbut:=vb.Tag;
    ivar:=indvarbut[ivarbut];
    for iknob:=1 to nknobs do begin
      kn:=TKnob(FindComponent('kn_'+IntToStr(iknob)));
      if kn.getvar=ivar then kn.UnLoad;
    end;
    if EditElemSet=nil then EditElemSet:=TEditElemSet.Create(Application);
    EditElemSet.InitOVar (ivar, pw);
    EditElemSet.Show;
  end else Screen.Cursor:=crHandPoint;
end;


procedure Toptic.varbutMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  iknob, ivar, ivarbut: integer;
  kn: TKnob;
  vb: TLabel;
  found: boolean;
begin
  Screen.Cursor:=crDefault;
    vb:=sender as TLabel;
    ivarbut:=vb.Tag;
    ivar:=indvarbut[ivarbut];
    if  insideRect(x+xoff_vbpw[ivarbut],y+yoff_vbpw[ivarbut],knobrect) then begin
      found:=false;

      for iknob:=1 to nknobs do begin
        kn:=TKnob(FindComponent('kn_'+IntToStr(iknob)));
        found:=found or (kn.getVar = ivar);
      end;

      if found then begin
        MessageDlg('Variable '+Variable[ivar].nam+' is already connected.', mtWarning, [mbok],0);
      end else begin
        iknob:=(x+xoff_vbpw[ivarbut]) div knobwidth+1;
        kn:=TKnob(FindComponent('kn_'+IntToStr(iknob)));
        kn.Loadvar(ivar, pw);
      end;
    end;
end;


{procedure Toptic.butcokiClick(Sender: TObject);
begin
  UsePulsed:=not UsePulsed;
  if UsePulsed then begin
    butcoki.Caption:='Kicker ON';
  end else begin
    butcoki.Caption:='Kicker OFF';
  end;
  OpticReCalc;
  if OpticPlotMode=EnvPlot then PlotEnv else if OpticPlotMode=BetPlot then PlotBeta;
end;
}



end.
