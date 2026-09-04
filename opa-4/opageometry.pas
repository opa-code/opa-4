{
21.11.2019
}


unit opageometry;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, comfigureframe, Buttons, Grids, globlib, georblib, comauxlib, varlib, MathLib, Math, linoplib,
  ExtCtrls;

type

  { TGeometry }

  TGeometry = class(TForm)
    butmatch: TButton;
    butreset: TButton;
    buteps: TButton;
    geo: TFigure;
    Butex: TButton;
    ButZoomFull: TBitBtn;
    ButSForward: TBitBtn;
    ButSBackward: TBitBtn;
    butlist: TButton;
    chkOrbit: TCheckBox;
    chkAsprat: TCheckBox;
    ButRead: TButton;
    OpenDialogLoad: TOpenDialog;
    ButLeft: TBitBtn;
    ButRight: TBitBtn;
    ButUp: TBitBtn;
    ButDown: TBitBtn;
    PanParam: TPanel;
    PanGeo: TPanel;
    GridParam: TStringGrid;
    PanMat: TPanel;
    rgdraw: TGroupBox;
    rbcenter: TRadioButton;
    rbinifin: TRadioButton;
    rbfinini: TRadioButton;
    butgoal: TButton;
    procedure butepsClick(Sender: TObject);
    procedure butresetClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormPaint(Sender: TObject);
//    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
//    procedure ButRedoClick(Sender: TObject);
    procedure ButZoomFullClick(Sender: TObject);
    procedure ButSForwardClick(Sender: TObject);
    procedure ButSBackwardClick(Sender: TObject);
    procedure ButLeftClick(Sender: TObject);
    procedure ButRightClick(Sender: TObject);
    procedure ButUpClick(Sender: TObject);
    procedure ButDownClick(Sender: TObject);
//    procedure FormShow(Sender: TObject);
    procedure geopPaint(Sender: TObject);    //called by OnPaint event of geo.p
    procedure chkOrbitClick(Sender: TObject);
    procedure chkAspratClick(Sender: TObject);
    procedure GridParamKeyPress(Sender: TObject; var Key: Char);
    procedure butlistClick(Sender: TObject);
    procedure ButReadClick(Sender: TObject);

    procedure rbdrawClick(Sender: TObject);
    procedure butgoalClick(Sender: TObject);
    procedure chkg_Click(Sender: TObject);
    procedure chkgvar_Click(Sender: TObject);
    procedure butmatchClick(Sender: TObject);

    procedure ButexClick(Sender: TObject);

  private
    procedure edvar_KeyPress(Sender: TObject; var Key: Char);
    procedure edvar_Exit(Sender: TObject);
    procedure edg_KeyPress(Sender: TObject; var Key: Char);
    procedure edg_Exit(Sender: TObject);
    procedure ResizeAll;
    procedure SetDrawMode (iedfoc: integer);
    procedure MakePlot;
    procedure Zoom;
    procedure RenewPlot;
    procedure FindSpos;
    procedure SposShift;
    procedure edg_enable;
    procedure edg_setgoal (i: integer);
    procedure matchenable;

  public
    procedure Start;
  end;

var
  Geometry: TGeometry;

implementation

{$R *.lfm}


const
  DefaultClientWidth =1000;
  DefaultClientHeight=400;

  //zoombase=0.7;
//  maxzoomfac=20;


var
  edg : array[0..NGEdit] of TEdit;
  labg: array[0..NGEdit] of TLabel;
  chkg: array[0..NGEdit] of TCheckbox;
  edvar :array of TEdit;
  labvar: array of TLabel;
  chkgvar: array of TCheckbox;

procedure TGeometry.ButexClick(Sender: TObject);
var
  i:integer;
begin
  GeoExit;
  DefSet('tgeom/lef',Left);
  DefSet('tgeom/top',Top);
  DefSet('tgeom/wid',clientWidth);
  DefSet('tgeom/hei',clientHeight);
  Close;
end;

procedure TGeometry.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if edvar <> nil then edvar :=nil;
  if labvar <> nil then labvar :=nil;
  geo.closeplot; //only free vplot, because this is created again
  GeoClose;
end;

procedure TGeometry.FormPaint(Sender: TObject);
begin
  if geo.newplotrange then MakePlot;
  geo.plot.btmshow;
end;



procedure TGeometry.Start;
var
  twid, ip, i, igv :integer;
  edummy: TEdit; ldummy: TLabel; cdummy: TCheckBox;

begin
  GeoInit;    //will set ngeovar

  geo.passFormHandle(self);
  geo.openPlot;
  geo.plot.setCanvasBitmap; //plot to bitmap
  left    :=IDefGet('tgeom/lef'); if left<0 then left:=50;
  top     :=IDefGet('tgeom/top'); if top< 0 then top:=50;
  clientwidth   :=IDefGet('tgeom/wid');
  if (clientwidth<0) or (clientwidth>screen.width) then clientwidth:=DefaultClientWidth;
  clientheight  :=IDefGet('tgeom/hei');
  if (clientheight<0) or (clientheight>screen.height) then clientheight:=DefaultClientHeight;
  for ip:=0 to NParam-1 do Param[ip]:=FDefGet('tgeom/'+ParamName[ip]);
  rbcenter.enabled:=false;
  rbcenter.checked:=false;
  rbinifin.checked:=false;
  rbfinini.checked:=false;

  drawmode:=-1; //from zero
  GridParam.FixedRows:=0;
  with GridParam do begin
    RowCount:=NParam;
    for ip:=0 to NParam-1 do begin
      Cells[0,ip]:=ParamTitle[ip];
      Cells[1,ip]:=FtoS(Param[ip],ParamWid[ip], ParamDec[ip]);
      twid:=canvas.TextWidth(ParamTitle[ip])+10;
      if twid > ColWidths[0] then Colwidths[0]:=twid;
    end;
    ColWidths[1]:=canvas.TextWidth('8888.88');
  end;

  //dynamically create my labels and edit fields
  for i:=0 to NGEdit do begin
    edg[i] :=TEdit (FindComponent( 'edg_'+IntToStr(i)));
    labg[i]:=TLabel(FindComponent('labg_'+IntToStr(i)));
    chkg[i]:=TCheckBox(FindComponent('chkg_'+IntToStr(i)));
    if edg[i] = nil then begin
      edg[i]:=TEdit.Create(self);
      edg[i].name:= 'edg_'+IntToStr(i);
      edg[i].parent:=pangeo;
      edg[i].Tag:=i;
      edg[i].OnKeyPress:=edg_KeyPress;
      edg[i].OnExit    :=edg_Exit;
    end;
    edg[i].enabled:=false;
    edg[i].text:= Ftos(edg_val[i],edgwid,edgdec);
    if labg[i] = nil then begin
      labg[i]:=TLabel.Create(self);
      labg[i].name:= 'labg_'+IntToStr(i);
      labg[i].parent:=pangeo;
    end;
    labg[i].caption:= labg_Text[i];
    if chkg[i] = nil then begin
      chkg[i]:=TCheckBox.Create(self);
      chkg[i].name:='chkg_'+InttoStr(i);
      chkg[i].parent:=pangeo;
      chkg[i].caption:='';
      chkg[i].Tag:=i;
      chkg[i].OnClick:=chkg_Click;
    end;
    chkg[i].enabled:=false;
    chkg[i].Checked:=false;
  end;

  edvar:=nil; labvar:=nil;
  if ngeovar>0 then begin
    setLength(edvar,  ngeovar+1);
    setLength(labvar, ngeovar+1);
    setLength(chkgvar,ngeovar+1);
    igv:=0;
    for i:=0 to High(Variable) do if Variable[i].use then begin
      edvar[igv] :=TEdit (FindComponent( 'edvar_'+IntToStr(igv)));
      labvar[igv]:=TLabel(FindComponent('labvar_'+IntToStr(igv)));
      chkgvar[igv]:=TCheckBox(FindComponent('chkgvar_'+IntToStr(igv)));
      if edvar[igv] = nil then begin
        edvar[igv]:=TEdit.Create(self);
        edvar[igv].name:= 'edvar_'+IntToStr(igv);
        edvar[igv].parent:=panmat;
        edvar[igv].OnKeyPress:=edvar_KeyPress;
        edvar[igv].OnExit    :=edvar_Exit;
      end;
      edvar[igv].visible   :=true;
      edvar[igv].text:= Ftos(Variable[i].val ,edgwid,edgdec);
      edvar[igv].Tag:=i;
      if labvar[igv] = nil then begin
        labvar[igv]:=TLabel.Create(self);
        labvar[igv].name:= 'labvar_'+IntToStr(igv);
        labvar[igv].parent:=panmat;
      end;
      labvar[igv].caption:= Variable[i].nam;
      labvar[igv].visible:=true;
      if chkgvar[igv] = nil then begin
        chkgvar[igv]:=TCheckBox.Create(self);
        chkgvar[igv].name:='chkgvar_'+InttoStr(igv);
        chkgvar[igv].parent:=panmat;
        chkgvar[igv].caption:='';
        chkgvar[igv].Tag:=igv;
        chkgvar[igv].OnClick:=chkgvar_Click;
      end;
      chkgvar[igv].Checked:=false;
      chkgvar[igv].enabled:=false;
      chkgvar[igv].Tag:=igv;
//    chkgvar[igv].OnClick:=chkgvar_Click;
      Inc(igv);
    end;
  end;

// remove components previously created and not needed anymore
// (a previous call to opageometry may have used more variables, certainly less than 20,
// which we don't want to see on the GUI)
  for i:=ngeovar to 20 do begin
    edummy :=TEdit (FindComponent( 'edvar_'+IntToStr(i)));
    ldummy :=TLabel (FindComponent( 'labvar_'+IntToStr(i)));
    cdummy :=TCheckBox (FindComponent( 'chkgvar_'+IntToStr(i)));
    if edummy <> nil then FreeAndNil(edummy);
    if ldummy <> nil then FreeAndNil(ldummy);
    if cdummy <> nil then FreeAndNil(cdummy)
  end;

  OpenDialogLoad.InitialDir:=work_dir;
  resizeAll;

  rbcenter.enabled:=CalcOrbit;
  CalcFaces;
  TransPoly;
  geoMinMax;

  xmid:=xcenter; xwidth:=xfullwidth;
  ymid:=ycenter; ywidth:=yfullwidth;
  Sposition:=0.0;
  MakePlot;       //req'd to set proper plot range on restart
  geo.newplotrange:=true;
end;


procedure TGeometry.ResizeAll;
const
  margin=7;
  edwid=75;

var
  edhgt, panwid, hpangeo, hpanmat, gridwid, buthgt, butwid, chkhgt, xpos, ypos, dist, i: integer;

begin

  if clientwidth<DefaultClientWidth then clientwidth:=DefaultClientWidth;
  if clientheight<DefaultClientHeight then clientheight:=DefaultClientHeight;
//  writeln(clientwidth,'  ', clientheight);
  butwid:=ButZoomFull.Width;
  buthgt:=ButZoomFull.Height;
  chkhgt:=chkOrbit.Height;
  ypos:=margin; xpos:=margin;
  dist:=margin+butwid;
  ButSForward.Left :=xpos       ; ButSForward.Top :=ypos;
  ButSBackward.Left:=xpos+  dist; ButSBackward.Top:=ypos;
  ButZoomFull.Left :=xpos+2*dist; ButZoomFull.Top :=ypos;
//  ButRedo.Left     :=xpos+3*dist; ButRedo.Top     :=ypos;
  ButEx.setbounds(xpos+3*dist,ypos,butwid,buthgt);
  ypos:=ypos+margin+buthgt;
  ButLeft.setbounds (xpos       ,ypos,butwid,buthgt);
  ButRight.setbounds(xpos+  dist,ypos,butwid,buthgt);
  ButUp.setbounds   (xpos+2*dist,ypos,butwid,buthgt);
  ButDown.setbounds (xpos+3*dist,ypos,butwid,buthgt);

  gridwid:=GridParam.Width;
  xpos:=5*margin+4*butwid;
  if xpos < gridwid+2*margin then xpos:=gridwid+2*margin else gridwid:=xpos-2*margin;
  Panwid:=GridParam.Width+8;

  ypos:=ypos+margin+buthgt;
  chkOrbit.SetBounds(margin,ypos,gridwid,chkhgt);
  ypos:=ypos+margin+chkhgt;
  chkAspRat.SetBounds(margin,ypos,gridwid,chkhgt);
  ypos:=ypos+margin+chkhgt;

  geo.SetSize(xpos, margin, ClientWidth-3*margin-xpos-Panwid, ClientHeight-2*margin);
  butwid:=(gridwid-2*margin) div 3;
  dist:=butwid+margin;
  buthgt:=24;
  Buteps.setbounds(margin,ypos, butwid,buthgt);
  ButList.setbounds(margin+dist,ypos, butwid,buthgt);
  ButRead.setbounds(margin+2*dist,ypos, butwid,buthgt);
  ypos:=ypos+buthgt+margin;
  PanParam.SetBounds(margin, ypos, Panwid, ClientHeight-margin-ypos);
  GridParam.SetBounds(margin, margin, gridwid, PanParam.Height-2*margin);

  edhgt:=20;
  HPanGeo:=40+2*margin+(NGEdit+1)*(edhgt+margin);
  HPanMat:=2+NGeoVar*(edhgt+margin)+buthgt+margin;
  if HPanGeo+HPanMat+3*margin > ClientHeight then begin
    HPanGeo:= (ClientHeight - 3*margin) div 2;
    HPanMat:= HPanGeo;
  end;
  PanGeo.SetBounds  (Clientwidth-margin-Panwid,           margin, Panwid, HPanGeo);
  PanMat.SetBounds  (Clientwidth-margin-Panwid, HPanGeo+2*margin, Panwid, HPanMat);
  ypos:=margin;
  xpos:=Panwid-margin-edwid;
  rgdraw.setbounds(margin, ypos, Panwid-2*margin,40);
  ypos:=ypos+margin+40;
  for i:=0 to NGEdit do begin
    if labg[i]<> nil then labg[i].setbounds(2,ypos+2, xpos-22,edhgt);
    if edg[i] <> nil then edg[i].setbounds(xpos,ypos, edwid,edhgt);
    if chkg[i]<> nil then chkg[i].setbounds(xpos-22,ypos, 20,19);
    inc(ypos, edhgt+margin);
  end;
  ypos:=2;
  for i:=0 to NGeoVar-1 do begin
    if labvar[i]<> nil then labvar[i].setbounds(2,ypos+2, xpos-2,edhgt);
    if edvar[i] <> nil then edvar[i].setbounds(xpos,ypos, edwid,edhgt);
    if chkgvar[i]<> nil then chkgvar[i].setbounds(xpos-22,ypos, 20,19);
    inc(ypos, edhgt+margin);
  end;
  if NGeoVar >0 then begin
    butgoal.Visible:=true;
    butmatch.Visible:=true;
    butreset.Visible:=true;
    butgoal.setBounds(xpos, ypos, butwid, buthgt);
    butmatch.setBounds(2, ypos, butwid, buthgt);
    butreset.setBounds(4+butwid, ypos, butwid, buthgt);
  end;
end;


procedure TGeometry.MakePlot;
var
  i:integer;
begin
//update grid to know the params
  with GridParam do  for i:=0 to NParam-1 do Cells[1,i]:=FtoS(Param[i],ParamWid[i], ParamDec[i]);
//call zoom function to calculate plot range
  Zoom;
  geo.plot.SetDefaultDrawPen;
  geo.Init(xmin, ymin, xmax, ymax, 1, 1, 'X[m]', 'Y[m]', 3, chkAsprat.Checked);
  geo.EnableMark;

  for i:=0 to High(FPoly) do  with FPoly[i] do begin
    geo.plot.Polygon(ptx, pty, isp, npp, c, cf);
  end;

  geo.plot.setStyle(psSolid);
  geo.plot.setThick(1);
  if chkOrbit.Checked then begin
    geo.plot.setThick(1);
    geo.plot.setColor(clBlack);
    geo.plot.moveto(inipt.vm[1],inipt.vm[2]);
    for i:=0 to High(midpt) do with midpt[i] do begin
      geo.plot.lineto(v0[1],v0[2]);
      geo.plot.lineto(vm[1],vm[2]);
      geo.plot.lineto(v1[1],v1[2]);
    end;
    geo.plot.lineto(finpt.vm[1],finpt.vm[2]);
    geo.plot.SetSymbol(3,2,clBlack);
    for i:=0 to High(midpt) do with midpt[i] do begin
      geo.plot.Symbol(vm[1],vm[2]);
    end;
  end;
//  geo.plot.btmcopy;
//  geo.plot.btmshow;
  geo.newplotrange:=false; // --> geoppaint will show the bitmap
  geo.Invalidate(); // --> force geoopaint to be called
end;

{
procedure TGeometry.FormPaint(Sender: TObject);
var
  xmin, ymin, xmax, ymax: integer;
begin
  writeln('geo received formpaint event');
//  MakePlot;
  geo.plot.btmshow;
//  if geo.getIRange(xmin,ymin,xmax,ymax) then geo.plot.IRectangle(xmin, ymin, xmax, ymax);
end;
}

procedure TGeometry.FormResize(Sender: TObject);
begin
  ResizeAll;
  MakePlot;
end;

procedure TGeometry.GridParamKeyPress(Sender: TObject; var Key: Char);
var
  x: Real;
  s: String;
  errcode:Integer;
begin
  if key=',' then key:='.';
  if key=#13 then key:=#0;  //beep suppression
  if key=#0 then begin
    with GridParam do begin
      s:=Cells[col,row];
{$R-}
        Val(s,x,errcode);
{$R+}
      if errcode=0 then begin
        Param[row]:=x;
//        if row <3 then ReNewPlot else begin
        CalcFaces;   //calc faces from current, transformed orbit, no recalc of orbit
        CalcPoly;
        ReadGeoFiles;
        geoMinMax;
        MakePlot;
//        end;
      end;
      s:=  FtoS(Param[row],ParamWid[row],ParamDec[row]);
      Cells[col,row]:=s;
    end;
  end;
end;

procedure TGeometry.Zoom;
var
  axmin, aymin, axmax, aymax: real;
begin
  if geo.getRange(axmin,aymin,axmax,aymax) then begin
// zoom to mouse selection of figure
    xwidth:=abs(axmax-axmin); ywidth:=abs(aymax-aymin);
    xmid:=(axmin+axmax)/2; ymid:=(aymin+aymax)/2;
    FindSpos;
  end;
  xmin:=xmid-xwidth/2;
  xmax:=xmid+xwidth/2;
  ymin:=ymid-ywidth/2;
  ymax:=ymid+ywidth/2;
  geo.resetmarkbox; //new, reset markbox when done
end;

procedure TGeometry.RenewPlot;
begin
  ReadGeoFiles;
  geoMinMax;
  MakePlot;
end;

procedure TGeometry.ButZoomFullClick(Sender: TObject);
begin
  xwidth:=xfullwidth;  ywidth:=yfullwidth;
  xmid:=xcenter;       ymid:=ycenter;
  MakePlot;
end;


procedure TGeometry.FindSpos;
{find the sposition of the marker next to the  midpoint of
 the currently set window (inverse to SposShift) }
var
  ds, dsmin: real;
  i,im: integer;
begin
  dsmin:=1e8;
  for i:=0 to high(midpt) do begin
    ds:= sqr(midpt[i].vm[1] - xmid)+sqr(midpt[i].vm[2]-ymid);
    if ds < dsmin then begin
      dsmin:=ds;
      im:=i;
    end;
  end;
  Sposition:=midpt[im].s;
end;

procedure TGeometry.SposShift;
var
  ds, dsmin: real;
  i,im: integer;
begin
  dsmin:=1e8;
  for i:=0 to high(midpt) do begin
    ds:= sqr(midpt[i].s - sposition);
    if ds < dsmin then begin
      dsmin:=ds;
      im:=i;
    end;
  end;
  xmid:=midpt[im].vm[1];
  ymid:=midpt[im].vm[2];
  MakePlot;
end;

procedure TGeometry.ButSForwardClick(Sender: TObject);
begin
  sposition:=sposition+sqrt(sqr(xwidth)+sqr(ywidth))/2;
  if sposition > sfulllength then sposition:=sposition-sfulllength;
  SposShift;
end;

procedure TGeometry.ButSBackwardClick(Sender: TObject);
begin
  sposition:=sposition-sqrt(sqr(xwidth)+sqr(ywidth))/2;
  if sposition < 0 then sposition:=sposition+sfulllength;
  SposShift;
end;

procedure TGeometry.butlistClick(Sender: TObject);
var
  fresult:string;
begin
  WriteGeoFiles (fresult);
  if length(fresult)>0 then MessageDlg('Geometry data written to '+fresult, MtInformation, [mbOK],0)
  else MessageDlg('Writing geometry files failed', MtError, [mbOk],0);
end;


procedure TGeometry.chkOrbitClick(Sender: TObject);
begin
  MakePlot;
end;

procedure TGeometry.chkAspratClick(Sender: TObject);
begin
  MakePlot;
end;

procedure TGeometry.geopPaint(Sender: TObject);
var
  x1, x2, y1, y2: integer;
begin
//create a new plot in bitmap if range has changed.
//then show bitmap in any case.
//overplot on screen by dragging rectangle if mouse is moving (getIrange true)
  if geo.newplotrange then MakePlot;
  geo.plot.btmshow;
  if geo.getIRange(x1,y1,x2,y2) then geo.plot.IRectangle(x1,y1,x2,y2);
end;

procedure TGeometry.ButReadClick(Sender: TObject);

var
  gfile: string;
  found: boolean;
  i: integer;
begin
  if OpenDialogLoad.Execute then begin
    gfile:= OpenDialogLoad.FileName;
    if FileExists(gfile) then begin
      found:=false; for i:=0 to High(geofiles) do if gfile=geofiles[i] then found:=true;
      if not found then begin
        setLength(geofiles, Length(geofiles)+1);
        geofiles[high(geofiles)]:=gfile;
      end;
    end;
  end;
//  opaLog(0,'butread '+inttostr(length(geofiles)));
  Renewplot;
end;


procedure TGeometry.ButLeftClick(Sender: TObject);
begin
  xmid:=xmid-xwidth/3;
  MakePlot;
end;

procedure TGeometry.ButRightClick(Sender: TObject);
begin
  xmid:=xmid+xwidth/3;
  MakePlot;
end;

procedure TGeometry.ButUpClick(Sender: TObject);
begin
  ymid:=ymid-ywidth/3;
  MakePlot;
end;

procedure TGeometry.ButDownClick(Sender: TObject);
begin
  ymid:=ymid+ywidth/3;
  MakePlot;
end;

procedure TGeometry.edg_KeyPress(Sender: TObject; var Key: Char);
var
  x:real;
  edg: TEdit;
begin
  edg:=Sender as TEdit;   x:=0;
  if TEKeyVal(edg, Key, x, edgwid, edgdec) then begin
    if not matchfunc[edg.Tag] then begin
      edg_val[edg.Tag]:=x;
      SetDrawMode (edg.Tag);
    end else begin // zielwert abspeichern
      edg_goal[edg.Tag]:=x;
    end;
  end;
end;

procedure TGeometry.edg_Exit(Sender: TObject);
var
  x:real;
  edg: TEdit;
begin
  edg:=Sender as TEdit;   x:=0;
  TEReadVal(edg, x, edgwid, edgdec);
end;

procedure TGeometry.edvar_KeyPress(Sender: TObject; var Key: Char);
var
  x:real;
  edv: TEdit;
  j: integer;
begin
  edv:=Sender as TEdit;  x:=0;
  if TEKeyVal(edv, Key, x, edgwid, edgdec) then begin
    Variable[edv.Tag].val:=x;
    for j:=1 to Glob.NElla do Ella_Eval(j);
    rbcenter.enabled:=CalcOrbit;//always from zero
    CalcFaces;
    SetDrawMode(0); // will calc new start trafo: viniact, morini
    Renewplot;
  end;
end;

procedure TGeometry.edvar_Exit(Sender: TObject);
var
  x:real;
  edv: TEdit;
begin
  edv:=Sender as TEdit;  x:=0;
  TEReadVal(edv, x, edgwid, edgdec);
end;

// enable manual edit of ini angles only (0), of all ini params (1) or all final params (2)
procedure TGeometry.edg_enable;
var i: integer;
begin
  for i:=0 to 12 do edg_actena[i]:=false;
  case drawmode of
    0: for i:=4 to  6 do edg_actena[i]:=true;
    1: for i:=1 to  6 do edg_actena[i]:=true;
    2: for i:=7 to 12 do edg_actena[i]:=true;
    else
  end;
  for i:=0 to 12 do begin
    edg[i].enabled:=edg_actena[i];
    edg[i].color:=clWhite;
    edg[i].Text:=FtoS(edg_val[i],edgwid,edgdec);
  end;
end;

procedure TGeometry.matchenable;
var
  i: integer;
begin
  Nmatchfunc:=0; Nmatchknob:=0;
  for i:=0 to ngedit do if matchfunc[i] then inc(Nmatchfunc);
  for i:=0 to High(matchknob) do if matchknob[i] then inc(Nmatchknob);
  butmatch.enabled := (Nmatchfunc>=1) and (Nmatchknob>=Nmatchfunc);
  butreset.enabled:=false;
end;


procedure TGeometry.SetDrawMode (iedfoc: integer);
var
  i: integer;

begin
  TransRot;

  for i:=0 to nGedit do edg[i].enabled:=false;
  case drawmode of
    0: for i:=4 to 6 do edg[i].enabled:=true;
    1: for i:=1 to 6 do edg[i].enabled:=true;
    2: for i:=7 to 12 do edg[i].enabled:=true;
    else  {3...n: later, start from any point geomarker, opticsmarker?}
  end;

  gsetedgval;

  for i:=0 to NGedit do if not matchfunc[i] then edg[i].Text:=FtoS(edg_val[i],edgwid, edgdec);

  if (iedfoc>0) and (iedfoc <= ngedit) then edg[iedfoc].setFocus;

  // use negative iedfoc to suppress plot
  if iedfoc>=0 then begin
    TransPoly;
    Renewplot;
  end;

end;




procedure TGeometry.rbdrawClick(Sender: TObject);
var
  rbd: TRadioButton;
  i: integer;
begin
  rbd:=Sender as TRadioButton;
  drawmode:=rbd.Tag;
  setDrawMode(0);
  showgoal:=false;
  butgoal.Caption:='actual';
  butgoal.enabled:=false;
  edg_enable;

  // if we have geo knobs (ngv>0):
  // enable goal selection of final params (1) or of initial params (2); length is always possible to select.
  for i:=0 to 12 do begin
    chkg[i].enabled:=false;
//    chkg[i].checked:=false;
  end;
  if ngeovar > 0 then begin
    butgoal.enabled:=true;
    chkg[0].enabled:=true;
    if drawmode = 1 then for i:=7 to 12 do chkg[i].enabled:=true;
    if drawmode = 2 then for i:=1 to  6 do chkg[i].enabled:=true;
  end;
  matchenable;
end;

procedure TGeometry.edg_setgoal (i: integer);
begin
  if chkg[i].enabled then begin
    if chkg[i].checked then begin
      edg[i].color:=clYellow;
      edg[i].enabled:=true;
      edg[i].Text:=FtoS(edg_goal[i],edgwid,edgdec);
      matchfunc[i]:=true;
    end else begin
      edg[i].color:=clWhite;
      edg[i].enabled:=edg_actena[i];
      edg[i].Text:=FtoS(edg_val[i],edgwid,edgdec);
      matchfunc[i]:=false;
    end;
  end;
end;

procedure TGeometry.butgoalClick(Sender: TObject);
var
  i: integer;
begin
  showgoal:=not showgoal;
  if showgoal then begin
    butgoal.Caption:='target';
    for i:=0 to ngedit do edg_setgoal (i);
    for i:=0 to ngeovar-1 do chkgvar[i].enabled:=true;
  end else begin
    butgoal.Caption:='actual';
    edg_enable;
    for i:=0 to ngeovar-1 do chkgvar[i].enabled:=false;
    for i:=0 to ngedit do matchfunc[i]:=false;
  end;
  matchenable;
end;

procedure TGeometry.chkg_Click(Sender: TObject);
var
  chk: TCheckBox;
begin
  chk:=Sender as TCheckBox;
  if showgoal then edg_setgoal(chk.Tag);
  matchenable;
end;

procedure TGeometry.chkgvar_Click(Sender: TObject);
var
  chk: TCheckBox;
begin
  chk:=Sender as TCheckBox;
  matchknob[chk.Tag]:=chk.Checked;
  matchenable;
end;


{improvised geo matching
to be checked:
- reverse matching from final, does not work properly
- test more DoFs
what could be added:
- show iter, penalty etc.
- filtering of wvec
- ! only allow primary variable to be used (plain values)
} //
procedure TGeometry.butmatchClick(Sender: TObject);

var
  jk, jf, i, j: integer;


begin
  gmat_ini;

  jf:=0;
  for i:=0 to NGEdit do if matchfunc[i] then begin ifunc[jf]:=i; inc(jf); end;

  jk:=0;
  for i:=0 to ngeovar-1  do if matchknob[i] then begin
    iknob[jk]:=edvar[i].Tag;
    iedvar[jk]:=i;
    inc(jk); //index of Variable controlled by edvar field i
  end;

  penal0:=0;
  for jf:=0 to Nmatchfunc-1 do begin
    funct[jf]:= edg_goal[ifunc[jf]]; // target values
    func0[jf]:= edg_val [ifunc[jf]]; // initial values
    penal0:=penal0+sqr(funct[jf]-func0[jf]);
    func[jf]:=func0[jf];
  end;

  for jk:=0 to Nmatchknob-1 do begin
    knob0[jk]:=Variable[iknob[jk]].val; // initial knobs
    knob[jk]:=knob0[jk];
  end;

  niter:=0;
  penal:=1.0;
  failed:=false;
  while (not failed) and (penal>penaleps) do begin
    gmat_step;
  end;

  if failed then gmat_reset;

  //write latest known values, recalc orb in any case, replot and rewrite edit fields with actual values
  for jk:=0 to Nmatchknob-1 do edvar[iedvar[jk]].Text:=FtoS(Variable[iknob[jk]].val,edgwid, edgdec);

  //reset display from target to actual
  showgoal:=false;
  butgoal.Caption:='actual';
  edg_enable;
  for i:=0 to ngeovar-1 do chkgvar[i].enabled:=false;
  for i:=0 to ngedit do matchfunc[i]:=false;
  rbcenter.Enabled:=CalcOrbit;
  CalcFaces;
  SetDrawMode(0);
  if not failed then butreset.enabled:=true;

  if failed then OPALog(2, 'geo match failed:     Nstep = '+inttostr(niter)+' pen = '+ftos(penal,-6,2))
            else OPALog(0, 'geo match successful: Nstep = '+inttostr(niter)+' pen = '+ftos(penal,-6,2))  ;

end;

procedure TGeometry.butresetClick(Sender: TObject);
var
  jk:integer;
begin
  gmat_reset;
  for jk:=0 to Nmatchknob-1 do edvar[iedvar[jk]].Text:=FtoS(Variable[iknob[jk]].val,edgwid, edgdec);

  rbcenter.Enabled:=CalcOrbit;
  CalcFaces;
  SetDrawMode(0);
  butreset.enabled:=false;
end;

procedure TGeometry.butepsClick(Sender: TObject);
var
  errmsg, epsfile: string;
begin
  epsfile:=ExtractFileName(FileName);
  epsfile:=work_dir+Copy(epsfile,0,Pos('.',epsfile)-1);
  epsfile:=epsfile+'_geo.eps';
  geo.plot.PS_start(epsfile,OPAversion, errmsg);
  if length(errmsg)>0 then begin
    MessageDlg('PS export failed: '+errmsg, MtError, [mbOK],0);
  end else begin
    MakePlot;
    geo.plot.PS_stop;
    MessageDlg('Graphics exported to '+epsfile, MtInformation, [mbOK],0);
    MakePlot;
  end;
end;


end.
