{
21.11.2019
}
                                                                                     


unit OPAGeometry;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ASfigure, Buttons, Grids, OPAglobal, ASaux, MathLib, Math, opticplot,
  ExtCtrls;

type

  { TGeometry }

  TGeometry = class(TForm)
    butmatch: TButton;
    geo: TFigure;
    Butex: TButton;
    ButZoomFull: TBitBtn;
    ButSForward: TBitBtn;
    ButSBackward: TBitBtn;
    Butwmf: TButton;
    butlist: TButton;
    chkOrbit: TCheckBox;
    chkAsprat: TCheckBox;
    ButRead: TButton;
    OpenDialogLoad: TOpenDialog;
    ButLeft: TBitBtn;
    ButRight: TBitBtn;
    ButUp: TBitBtn;
    ButDown: TBitBtn;
    p: TPaintBox;
    PanParam: TPanel;
    PanGeo: TPanel;
    GridParam: TStringGrid;
    PanMat: TPanel;
    rgdraw: TGroupBox;
    rbcenter: TRadioButton;
    rbinifin: TRadioButton;
    rbfinini: TRadioButton;
    butgoal: TButton;
    procedure ButexClick(Sender: TObject);
    procedure butmatchClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
//    procedure ButRedoClick(Sender: TObject);
    procedure GridParamKeyPress(Sender: TObject; var Key: Char);
    procedure ButZoomFullClick(Sender: TObject);
    procedure ButSForwardClick(Sender: TObject);
    procedure ButSBackwardClick(Sender: TObject);
    procedure ButwmfClick(Sender: TObject);
    procedure butlistClick(Sender: TObject);
    procedure chkOrbitClick(Sender: TObject);
    procedure chkMarkerClick(Sender: TObject);
    procedure chkAspratClick(Sender: TObject);
    procedure geopPaint(Sender: TObject);
    procedure ButReadClick(Sender: TObject);
    procedure ButLeftClick(Sender: TObject);
    procedure ButRightClick(Sender: TObject);
    procedure ButUpClick(Sender: TObject);
    procedure ButDownClick(Sender: TObject);
    procedure edg_enable;
    procedure rbdrawClick(Sender: TObject);
    procedure butgoalClick(Sender: TObject);
    procedure chkg_Click(Sender: TObject);
    procedure chkgvar_Click(Sender: TObject);

  private
    xmin, xmax, ymin, ymax, xmid, ymid, xwidth, ywidth,
      xfullwidth, yfullwidth, xcenter, ycenter, sposition, sfulllength: real;
    ncentermark: integer;
    // geodir: string;
    procedure edvar_KeyPress(Sender: TObject; var Key: Char);
    procedure edvar_Exit(Sender: TObject);
    procedure edg_KeyPress(Sender: TObject; var Key: Char);
    procedure edg_Exit(Sender: TObject);
//    procedure edg_Action(edg: TEdit);
    function edg_ReadVal(iedg: integer): real;
    procedure edg_SetVal(iedg: integer; x:real);
    procedure ResizeAll;
//    procedure AssignNames;
    procedure CalcOrbit; //calc orbit starting from 0,0,0 direction X
    procedure CalcFaces; //calc faces (tiles) defining the objects from current orbit
    procedure TransPoly; //transform orbit and faces (translation and rotation)
                         // includes a call to CalcPoly
    procedure CalcPoly;  //calc 2D polygons from 3D faces
    procedure SetDrawMode (iedfoc: integer); //switch between centered, initial, final
    procedure getMinMax;
    procedure MakePlot;
    procedure Zoom;
    procedure RenewPlot;
    procedure FindSpos;
    procedure SposShift;
    procedure ReadFiles;
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
  DefaultClientWidth =600;
  DefaultClientHeight=400;
  NParam=14;
  ParamName: array[0..nParam-1] of string[4]=
  ('beyw', 'quyw', 'mpyw','mpyl','unyw','xrbl',
  'driw', 'monw','corw','corl','marl','gwd1','gwd2','gwd3');
  ParamTitle: array[0..nParam-1] of string[25]=('Bending width [m]','Quadrupole width [m]',
    'Multipole width [m]','Multipole length [m]','Undulator width [m]','X-ray beam stretch [x]',
    'Chamber width [m]','Monitor size [m]','Corrector width [m]','Corrector length [m]',
    'Marker length [m]', 'Girder-1 width [m]', 'Girder-2 width [m]', 'Girder-3 width [m]');
  ParamWid: array[0..NParam-1] of integer = (5,5,5,5,5,5,5,5,5,5,5,5,5,5);
  ParamDec: array[0..NParam-1] of integer = (2,2,2,2,2,1,3,2,2,2,3,2,2,2);
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
  //zoombase=0.7;
//  maxzoomfac=20;


type

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
  Param: array[0..NParam-1] of real;
  ptx, pty: array of real;
  vpt: array of Vektor_3;
  fpoly : array of fpolyType;
  midpt: array of midptType;
  face : array of faceType;
  inipt, finpt: midptType;
  geofiles: array of string;
  edg_val, edg_goal : array[0..NGEdit] of Real;
  edg : array[0..NGEdit] of TEdit;
  labg: array[0..NGEdit] of TLabel;
  chkg: array[0..NGEdit] of TCheckbox;
  edvar :array of TEdit;
  labvar: array of TLabel;
  chkgvar: array of TCheckbox;
  drawmode, ngv: integer;
  viniact, vinipre, vini0, vfin0, vcenter0: Vektor_3;
  moriact, moripre, morini0, morfin0: Matrix_3;
  angini0, angfin0, angbendoffset: double;
  showgoal: boolean;
  edg_actena, matchfunc: array[0..ngedit] of boolean;
  matchknob: array of boolean;
  nmatchfunc, nmatchknob: integer;

procedure TGeometry.ButexClick(Sender: TObject);
var
  i:integer;
begin
  if fpoly  <> nil then fpoly  :=nil;
  if ptx  <> nil then ptx  :=nil;
  if pty  <> nil then pty  :=nil;
  if midpt <> nil then midpt :=nil;
  if vpt   <> nil then vpt   :=nil;
  if edvar <> nil then edvar :=nil;
  if labvar <> nil then labvar :=nil;
  DefSet('tgeom/lef',Left);
  DefSet('tgeom/top',Top);
  DefSet('tgeom/wid',clientWidth);
  DefSet('tgeom/hei',clientHeight);
  for i:=0 to NParam-1 do DefSet('tgeom/'+ParamName[i],Param[i]);
  for i:=0 to NGEdit do DefSet('tgeom/'+edparname[i],edg_val[i]);
  for i:=0 to NGEdit do DefSet('tgeom/'+edparname[i]+'g',edg_goal[i] );
  Close;
end;


procedure TGeometry.Start;
var
  twid, ip, i :integer;
  edummy: TEdit; ldummy: TLabel; cdummy: TCheckBox;

begin
  geo.passFormHandle(self);
  geo.assignScreen;
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
    edg_val[i] :=FDefGet('tgeom/'+edparname[i]);
    edg_goal[i]:=FDefGet('tgeom/'+edparname[i]+'g');
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


  // to do: check that the variables used are primary, i.e. plain values, otherwise it will not work.
  for i:=0 to High(Variable) do Variable[i].use:=false;
  for i:=1 to Glob.NElla do if Ella[i].cod in [cdrif,cbend, ccomb,crota] then Ella_Eval(i); //just to set the use flag of variable
  for i:=0 to High(Variable) do if Pos('G',Variable[i].nam)<>1 then Variable[i].use:=false; //use only G... variables
  edvar:=nil; labvar:=nil;
  ngv:=0;

  for i:=0 to High(Variable) do if Variable[i].use then begin
    setLength(edvar,  ngv+1);
    setLength(labvar, ngv+1);
    setLength(chkgvar, ngv+1);
    edvar[ngv] :=TEdit (FindComponent( 'edvar_'+IntToStr(ngv)));
    labvar[ngv]:=TLabel(FindComponent('labvar_'+IntToStr(ngv)));
    chkgvar[ngv]:=TCheckBox(FindComponent('chkgvar_'+IntToStr(ngv)));
    if edvar[ngv] = nil then begin
      edvar[ngv]:=TEdit.Create(self);
      edvar[ngv].name:= 'edvar_'+IntToStr(ngv);
      edvar[ngv].parent:=panmat;
      edvar[ngv].OnKeyPress:=edvar_KeyPress;
      edvar[ngv].OnExit    :=edvar_Exit;
    end;
    edvar[ngv].visible   :=true;
    edvar[ngv].text:= Ftos(Variable[i].val ,edgwid,edgdec);
    edvar[ngv].Tag:=i;
    if labvar[ngv] = nil then begin
      labvar[ngv]:=TLabel.Create(self);
      labvar[ngv].name:= 'labvar_'+IntToStr(ngv);
      labvar[ngv].parent:=panmat;
    end;
    labvar[ngv].caption:= Variable[i].nam;
    labvar[ngv].visible:=true;
    if chkgvar[ngv] = nil then begin
      chkgvar[ngv]:=TCheckBox.Create(self);
      chkgvar[ngv].name:='chkgvar_'+InttoStr(ngv);
      chkgvar[ngv].parent:=panmat;
      chkgvar[ngv].caption:='';
      chkgvar[ngv].Tag:=ngv;
      chkgvar[ngv].OnClick:=chkgvar_Click;
    end;
    chkgvar[ngv].Checked:=false;
    chkgvar[ngv].enabled:=false;
    chkgvar[ngv].Tag:=ngv;
//    chkgvar[ngv].OnClick:=chkgvar_Click;
    Inc(ngv);
  end;

// remove components previously created and not needed anymore
  for i:=ngv to 20 do begin
    edummy :=TEdit (FindComponent( 'edvar_'+IntToStr(i)));
    ldummy :=TLabel (FindComponent( 'labvar_'+IntToStr(i)));
    cdummy :=TCheckBox (FindComponent( 'chkgvar_'+IntToStr(i)));
    if edummy <> nil then FreeAndNil(edummy);
    if ldummy <> nil then FreeAndNil(ldummy);
    if cdummy <> nil then FreeAndNil(cdummy)
  end;

  setlength(matchknob,ngv);
  for i:=0 to ngedit do matchfunc[i]:=false;
  for i:=0 to ngv-1 do matchknob[i]:=false;

  OpenDialogLoad.InitialDir:=work_dir;
  geofiles:=nil;

  GirderSetup;
  resizeAll;

  CalcOrbit;
  CalcFaces;
  TransPoly;

  getMinMax;

  xmid:=xcenter; xwidth:=xfullwidth;
  ymid:=ycenter; ywidth:=yfullwidth;
  Sposition:=0.0;
  MakePlot;
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
  ButWMF.setbounds(margin,ypos, butwid,buthgt);
  ButList.setbounds(margin+dist,ypos, butwid,buthgt);
  ButRead.setbounds(margin+2*dist,ypos, butwid,buthgt);
  ypos:=ypos+buthgt+margin;
  PanParam.SetBounds(margin, ypos, Panwid, ClientHeight-margin-ypos);
  GridParam.SetBounds(margin, margin, gridwid, PanParam.Height-2*margin);

  edhgt:=20;
  HPanGeo:=40+2*margin+(NGEdit+1)*(edhgt+margin);
  HPanMat:=2+NGV*(edhgt+margin)+buthgt+margin;
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
  for i:=0 to NGV-1 do begin
    if labvar[i]<> nil then labvar[i].setbounds(2,ypos+2, xpos-2,edhgt);
    if edvar[i] <> nil then edvar[i].setbounds(xpos,ypos, edwid,edhgt);
    if chkgvar[i]<> nil then chkgvar[i].setbounds(xpos-22,ypos, 20,19);
    inc(ypos, edhgt+margin);
  end;
  if NGV >0 then begin
    butgoal.Visible:=true;
    butmatch.Visible:=true;
    butgoal.setBounds(xpos, ypos, butwid, buthgt);
    butmatch.setBounds(2, ypos, butwid, buthgt);
  end;
end;

procedure TGeometry.CalcOrbit;
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

  {
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

{
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
  rbcenter.enabled:=false;
  for i:=0 to High(midpt) do with midpt[i] do
  if (CompareText(nam, 'center')=0) and (cod=cmark) then begin
    vcenter0:=VecAdd3(vm, vcenter0);
    Inc(ncentermark);
  end;
  if ncentermark > 0 then begin
    vcenter0:=VecSca3(vcenter0, 1./ncentermark);
    rbcenter.Enabled:=True;
  end;
end;



procedure TGeometry.SetDrawMode (iedfoc: integer);
// translation and rotation of orbit etc. as stored in midpt
var
  xpos, ypos, zpos, angy, angx, angs: double;
  i: integer;
  vfin: Vektor_3;
  morf, r: Matrix_3;

begin

  xpos:=0; ypos:=0; zpos:=0; angy:=0; angx:=0; angs:=0;
  moripre:=moriact; vinipre:=viniact;

  for i:=0 to nGedit do edg[i].enabled:=false;

  case drawmode of

   -1: begin // zero point
      moriact:=morini0; morf:=morfin0;
      viniact:=vini0;   vfin:=vfin0;
    end;

    0: begin //center
      for i:=4 to 6 do edg[i].enabled:=true;

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
      for i:=1 to 6 do edg[i].enabled:=true;

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

      for i:=7 to 12 do edg[i].enabled:=true;

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

  Edg_SetVal(ixini,viniact[1]);  Edg_SetVal(iyini,viniact[2]);  Edg_SetVal(izini,viniact[3]);
  Edg_SetVal(ixfin,   vfin[1]);  Edg_SetVal(iyfin,   vfin[2]);  Edg_SetVal(izfin,    vfin[3]);

  Eulerang(moriact, angy, angx, angs, false);
  Edg_SetVal(ianzi,degrad*angy);    Edg_SetVal(ianxi,degrad*angx);    Edg_SetVal(iansi,degrad*angs);

  Eulerang(morf,    angy, angx, angs, false);
  Edg_SetVal(ianzf,degrad*angy);    Edg_SetVal(ianxf,degrad*angx);    Edg_SetVal(iansf,degrad*angs);

  Edg_SetVal(ileng,finpt.s);

  if (iedfoc>0) and (iedfoc <= ngedit) then edg[iedfoc].setFocus;

{
  opamessage(0,'--------- calco ----------------');
  for i:=0 to ngedit do opamessage(0,ftos(edg_val[i],15,8)+' '+labg_text[i]);
}
  // use negative iedfoc to suppress
  if iedfoc>=0 then begin
    TransPoly;
    Renewplot;
  end;

end;


procedure TGeometry.TransPoly;
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


procedure TGeometry.CalcPoly; // from faces (3D, vpt, face) to polygons (poly, ptx/y)
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



procedure TGeometry.CalcFaces;
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


procedure TGeometry.getMinMax;
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

procedure TGeometry.MakePlot;
var
  i:integer;
begin
//update grid to know the params
  with GridParam do  for i:=0 to NParam-1 do Cells[1,i]:=FtoS(Param[i],ParamWid[i], ParamDec[i]);
//call zoom function to calculate plot range
  Zoom;
  geo.plot.SetDefaultDragPen;
  geo.Init(xmin, ymin, xmax, ymax, 1, 1, 'X[m]', 'Y[m]', 3, chkAsprat.Checked);
  geo.EnableMark;


  for i:=0 to High(FPoly) do  with FPoly[i] do begin
    geo.plot.Polygon(ptx, pty, isp, npp, c, cf);
  end;

{
  for i:=0 to High(face) do with face[i] do begin
    geo.plot.setColor(dimcol(clblack, col,0.5));
    geo.plot.moveto(vpt[ist+npt][1],vpt[ist+npt][2]);
    for k:=1 to npt do geo.Plot.LineTo(vpt[ist+k][1],vpt[ist+k][2]);
  end;
}
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
end;


procedure TGeometry.FormPaint(Sender: TObject);
begin
//  opamessage(0, 'geo received formpaint event');
  MakePlot;
end;

procedure TGeometry.FormResize(Sender: TObject);
begin
  ResizeAll;
//  MakePlot;
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
        ReadFiles;
        getMinMax;
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
  end; //else no change of width & mid
  xmin:=xmid-xwidth/2;
  xmax:=xmid+xwidth/2;
  ymin:=ymid-ywidth/2;
  ymax:=ymid+ywidth/2;
end;

procedure TGeometry.RenewPlot;
begin
  ReadFiles;
  getMinMax;
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

procedure TGeometry.ButwmfClick(Sender: TObject);
var
  mfname: string;
begin
//insufficient precision!!
{  geo.beginMetaPlot(10);
  MakePlot;
  mfname:=ExtractFileName(FileName);
  mfname:=work_dir+Copy(mfname,0,Pos('.',mfname)-1);
  geo.endMetaPlot(mfname+'_geometry.wmf');
  MakePlot;
}
end;

procedure TGeometry.butlistClick(Sender: TObject);

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

procedure TGeometry.ReadFiles;
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



procedure TGeometry.chkOrbitClick(Sender: TObject);
begin
  MakePlot;
end;

procedure TGeometry.chkMarkerClick(Sender: TObject);
begin
  MakePlot;
end;

procedure TGeometry.chkAspratClick(Sender: TObject);
begin
  MakePlot;
end;

procedure TGeometry.geopPaint(Sender: TObject);
begin
  MakePlot; // this was disabled before 6.2.20, see change in asfigure pMouseUp
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

{
procedure TGeometry.edg_Action(edg: TEdit);
var
  i:integer;
begin
  i:=edg.Tag;
  Renewplot;
end;
}

function TGeometry.edg_ReadVal(iedg: integer): Real;
var
  x: real;
begin
  x:=0; if TEReadVal(edg[iedg], x, edgwid, edgdec) then edg_ReadVal:=x else edg_ReadVal:=0;
//  opamessage(0,'read val x ='+ftos(x,12,6));
end;

procedure TGeometry.edg_SetVal(iedg: integer; x:real);
begin
  if not matchfunc[iedg] then edg[iedg].Text:=FtoS(x,edgwid, edgdec);
  edg_val[iedg]:=x;
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
    CalcOrbit; //always from zero
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
  if ngv > 0 then begin
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
    for i:=0 to ngv-1 do chkgvar[i].enabled:=true;
  end else begin
    butgoal.Caption:='actual';
    edg_enable;
    for i:=0 to ngv-1 do chkgvar[i].enabled:=false;
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

procedure TGeometry.butmatchClick(Sender: TObject);

const
  kndiff=1e-4; //num diff for sensitivity matrix
  nitermax=50;
  penalmax=10.0;
  penaleps=1e-6 ; //micron

var
  niter, jk, jf, i, j: integer;
  bvec, cvec, knob0, knob, dknob, func0, func, funct, {dfunc,} aumat, wvec, wvecu, vmat: array of real;
  penal, penal0, kfrac: real;
  iknob, ifunc, iedvar: array of integer;
  failed: boolean;

begin
  setlength(iknob, Nmatchknob);
  setlength(knob , Nmatchknob);
  setlength(knob0, Nmatchknob);
  setlength(dknob, Nmatchknob);
  setlength(iedvar,Nmatchknob);

  setlength(ifunc, Nmatchfunc);
  setlength(func,  Nmatchfunc);
  setlength(funct, Nmatchfunc);
//  setlength(dfunc, Nmatchfunc);
  setlength(func0, Nmatchfunc);

  setlength(aumat, Nmatchfunc*Nmatchknob);
  setlength(wvec,  Nmatchknob+1);
  setlength(wvecu, Nmatchknob+1);
  setlength(vmat,  NMatchknob*Nmatchknob);

  setlength(bvec, Nmatchfunc+1);
  setlength(cvec, Nmatchknob+1);

  kfrac:=1.0;

  jf:=0; for i:=0 to NGEdit do if matchfunc[i] then begin ifunc[jf]:=i; inc(jf); end;
  jk:=0; for i:=0 to ngv-1  do if matchknob[i] then begin
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

  // get current func and knob and calc (local) response (sensitivity) matrix by num. diff.:

    for jk:=0 to Nmatchknob-1 do begin
      knob[jk]:=Variable[iknob[jk]].val; // current knobs
      if abs(knob[jk]) > 1 then dknob[jk]:=kndiff*knob[jk] else dknob[jk]:=kndiff;
    end;

    for jk:=0 to Nmatchknob-1 do begin
      variable[iknob[jk]].val:=knob[jk]+dknob[jk];
      for j:=1 to Glob.NElla do Ella_Eval(j);
      CalcOrbit; //starts at zero
      CalcFaces;
      SetDrawMode(-1); //updates edg_val
      for jf:=0 to Nmatchfunc-1 do  aumat[jf*Nmatchknob+jk] := (edg_val[ifunc[jf]]-func[jf])/dknob[jk]; //
      variable[iknob[jk]].val:=knob[jk];
    end;

 {  writeln(diagfil, 'response matrix');
    for jf:=0 to Nmatchfunc-1 do begin for jk:=0 to Nmatchknob-1 do write(diagfil, aumat[jf*NMatchknob+jk]);  writeln(diagfil); end;
 }
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
//      CalcFaces;
      SetDrawMode(-1);  //writes edg_val
//      for i:=0 to ngv-1 do if edvar[i].Tag=iknob[jk] then edvar[i].Text:=FtoS(knob[jk],edgwid, edgdec);
    end;

    penal:=0;
    for jf:=0 to Nmatchfunc-1 do begin
      func[jf]:= edg_val [ifunc[jf]]; // current values
      penal:=penal+sqr(funct[jf]-func[jf]);
    end;
    penal:=sqrt(penal/penal0);
    inc(niter);
    failed:=(penal > penalmax) or (niter > nitermax);

  end;

  //reset in case of failure
  if failed then  for jk:=0 to Nmatchknob-1 do begin
    variable[iknob[jk]].val:=knob0[jk];
    for j:=1 to Glob.NElla do Ella_Eval(j);
  end;

  //write latest known values, recalc orb in any case, replot and rewrite edit fields with actual values

  for jk:=0 to Nmatchknob-1 do edvar[iedvar[jk]].Text:=FtoS(Variable[iknob[jk]].val,edgwid, edgdec);

  //reset display from target to actual
  showgoal:=false;
  butgoal.Caption:='actual';
  edg_enable;
  for i:=0 to ngv-1 do chkgvar[i].enabled:=false;
  for i:=0 to ngedit do matchfunc[i]:=false;

  CalcOrbit;
  SetDrawMode(0);

  if failed then OPALog(2, 'geo match failed:     Nstep = '+inttostr(niter)+' pen = '+ftos(penal,-6,2))
            else OPALog(0, 'geo match successful: Nstep = '+inttostr(niter)+' pen = '+ftos(penal,-6,2))  ;



  iknob:=nil; knob:=nil; knob0:=nil; dknob:=nil;
  ifunc:=nil; func:=nil; funct:=nil; func0:=nil; //dfunc:=nil;
  aumat:=nil; wvec:=nil; wvecu:=nil; vmat:=nil;
  bvec:=nil; cvec:=nil;
end;
{ 4.8.2020
so far it works.
to be checked:
- reverse matching from final, does not work properly
- test more DoFs
what could be added:
- show iter, penalty etc.
- reset button if it was successful but I don't like the solution
- filtering of wvec
- ! only allow primary variable to be used (plain values)
}

end.
