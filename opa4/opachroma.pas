unit opachroma;

{$MODE Delphi}

{Sextupol-Optimization GUI}

{dependancies:
uses (compile time):                                                    
  opachroma --> csexframe, chamframe, chromreslib, chromelelib, chromlib
  csexframe --> ChromGUILib, chromlib [chamframe no longer needed]
  chromreslib --> chamframe, chromlib;
  chromelelib --> chromlib;
runtime:
  chamframe --> csexframe, chromlib
}

interface

uses
  LCLIntf, LCLType,  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  chamframe, csexframe, ExtCtrls, chromlib, chromreslib, chromelelib, globlib, asaux, MathLib,
  StdCtrls, opatunediag, ochromsvector;

type

  { TChroma }

  TChroma = class(TForm)
    ChkOctCx2: TCheckBox;
    ChkOctCy2: TCheckBox;
    ChkOctQxx: TCheckBox;
    ChkOctQxy: TCheckBox;
    ChkOctQyy: TCheckBox;
    LabHTarg: TLabel;
    LabHVal: TLabel;
    LabHWeight: TLabel;
    LabHinc: TLabel;
    LabSChrom: TLabel;
    LabSName: TLabel;
    LabSVal: TLabel;
    LabSlock: TLabel;
    Ed2Jx: TEdit;
    Ed2Jy: TEdit;
    Eddpp: TEdit;
    Lab2Jx: TLabel;
    Lab2Jy: TLabel;
    Labdpp: TLabel;
    edfac: TEdit;
    LabFac: TLabel;
    LabScal: TLabel;
    LabRangeS: TLabel;
    EdRangeS: TEdit;
    LabStepS: TLabel;
    EdStepS: TEdit;
    ButMin: TButton;
    LabMinAmp: TLabel;
    EdMinAmp: TEdit;
    butselect: TButton;
    ButEx: TButton;
    Check2Q: TCheckBox;
    CheckQxx: TCheckBox;
    CheckCr2: TCheckBox;
    CheckOct: TCheckBox;
    edper: TEdit;
    LabPen: TLabel;
    labper: TLabel;
    butsmat: TButton;
    LabRangeO: TLabel;
    LabStepO: TLabel;
    EdRangeO: TEdit;
    EdStepO: TEdit;
    LabRangeD: TLabel;
    LabStepD: TLabel;
    EdRangeD: TEdit;
    EdStepD: TEdit;
    ChkDecCx3: TCheckBox;
    ChkDecCy3: TCheckBox;
    LabOChk: TLabel;
    LabDChk: TLabel;
    panOsvd: TPanel;
    butOsvdDo: TButton;
    labOsvdCon: TLabel;
    labOsvdNw: TLabel;
    butOsvdNm: TButton;
    ButOsvdNp: TButton;
    chkOsvdAuto: TCheckBox;
    ButOsvdUndo: TButton;
    laba1L: TLabel;
    laba2L: TLabel;
    laba3l: TLabel;
    labpath: TLabel;
    butphase: TButton;
    LabNumDiff: TLabel;
    EdNumDiff: TEdit;
    ButOctOff: TButton;
    butoctres: TButton;
    ChkComb: TCheckBox;
  //  procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ButExClick(Sender: TObject);
    procedure EdScParKeyPress(Sender: TObject; var Key: Char);
    procedure EdScParExit(Sender: TObject);
    procedure Check2QClick(Sender: TObject);
    procedure CheckQxxClick(Sender: TObject);
    procedure CheckCr2Click(Sender: TObject);
    procedure CheckOctClick(Sender: TObject);
    procedure EdSODKeyPress(Sender: TObject; var Key: Char);
    procedure EdSODExit(Sender: TObject);
    procedure EdMinAmpKeyPress(Sender: TObject; var Key: Char);
    procedure EdMinAmpExit(Sender: TObject);
    procedure EdNumDiffKeyPress(Sender: TObject; var Key: Char);
    procedure EdNumDiffExit(Sender: TObject);
    procedure ButMinClick(Sender: TObject);
    procedure butselectClick(Sender: TObject);
    procedure edperKeyPress(Sender: TObject; var Key: Char);
    procedure edperExit(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure butsmatClick(Sender: TObject);
    procedure ChkOctClick(Sender: TObject);
    procedure butOsvdDoClick(Sender: TObject);
    procedure chkOsvdAutoClick(Sender: TObject);
    procedure butOsvdNmClick(Sender: TObject);
    procedure ButOsvdNpClick(Sender: TObject);
    procedure ButOsvdUndoClick(Sender: TObject);
    procedure butphaseClick(Sender: TObject);
    procedure ButOctOffClick(Sender: TObject);
    procedure butoctresClick(Sender: TObject);
    procedure ChkCombClick(Sender: TObject);
  private
  // fixed array for the hamiltonians, var array for the sextupole families:
    CH: array[0..nCHamilton] of TCHam;
    CSelect: array of TCheckBox;
    ChkOcHam: array of TCheckBox;
//    CSelect: array of TCSelect;
    CanResize:boolean;
//    procedure Osvd_status;
    procedure OctUpdate;
    procedure CSelectClick(Sender: TObject);
    procedure ResizeAll;
    procedure Display;
    procedure UpdateScPar(Ed: TEdit; v: real);
    procedure UpdateEdSOD  (Ed: TEdit; v: real);
    procedure UpdateMinAmp(v: real);
    procedure UpdateNumDiff(v: real);
    procedure UpdateChroma;
//    procedure UpdatePenalty;
    procedure VUpdate;
    procedure Exit;
  public
    procedure Start(TunePlotHandle: TTunePlot);
  end;

// has to stand here, otherwise Powell can't access it from mathlib
  function  PenaltyFunction(Var p: PowellVector): real;


var
  Chroma: TChroma;

implementation

{$R *.lfm}

const
  wid_ed: array[0..2] of integer=(5,5,5);
  dec_ed: array[0..2] of integer=(1,0,0);


var //temp, should go to mathlib?
  PowK: PowellVector;
// save old penalty values for minimizer:
  PenSave, PenOld, PenCur, PenNorm: real;
// index arrays relating minimizer knobs to Ella, resp. SexFam
// max. number of families is limited by the number Powell can handle
  iellapow, isfampow: array[1..Powellncom_max] of integer;

// declare the CS array here, otherwise Penaltyfunction can not access it
  CS: array of TCSex;


//-------------------------------------------------------------------------

procedure TChroma.Start(TunePlotHandle: TTunePlot);
var
  i, j, nsext, noctu, ndeca: integer;
  CHinst: TCHam;
  CSinst: TCSex;
//  CSelinst: TCSelect;
  CSelInst,CochamInst: TCheckBox;
  Cursor_save: TCursor;

  P: double;

begin
  CanResize:=False;
// define lines for the hamiltonian components
  for i:=0 to nCHamilton-1 do begin
    CHinst:=TCHam(FindComponent('ch_'+IntToStr(i)));
    if CHinst = nil then begin
      CHinst:=TCHam.Create(self);
      CHinst.Init(i, LabPen);
      CHinst.parent:=Self;
      CHinst.name:= 'ch_'+IntToStr(i);
      CHinst.SetLab(HamCap[i]);
      CH[i]:=CHinst;
    end;
  end;
  for i:=0 to nCHamilton-1 do CH[i].brothers(CH);

  setlabpenhandle(LabPen);// ->chromlib
  Pass_CH_handles(CH); //-> chromgui
  Pass_LabPath_handles(laba1l, laba2l, laba3l);
  Pass_osvd_handles(ButOsvdDo, ButOsvdNp, ButOsvdNm, ChkOsvdAuto, LabOsvdCon, LabOsvdNw);
  butoctres.enabled:=false;

  width:=1000; height:=700;
  if screen.width <width  then width :=screen.width;
  if screen.height<height then height:=screen.height;

//------------- up to here, was in FormCreate before -----------

  Cursor_save:=Screen.Cursor;
  Screen.Cursor:=crHourglass;

// pass tune diagram handle to chromlib
  SetTunePlotHandle(TunePlotHandle);
  ChromInit; //-> chromlib: get all initial info on sextupoles

  Screen.Cursor:=Cursor_Save;

  for i:=0 to nCHamilton-1 do begin
    CHinst:=TCHam(FindComponent('ch_'+IntToStr(i)));
    CHinst.SetTarget(HamTarg[i]);
    CHinst.SetWeight(HamWeight[i]);
  end;

// assign the vector diagram plot to screen, get canvas
//*  VDiag.assignscreen;

//check the boxes according to previous settings
//CAREFUL: this launches checkbox events!
  Check2Q.Checked  :=Include2Q;
  CheckQxx.Checked :=IncludeQxx;
  CheckCr2.Checked :=IncludeCr2;
  CheckOct.Checked :=IncludeOct;


{ //later: activate a decapole svd

  if Length(DecaFam)>0 then begin
    ChkDecCx3.Visible:=True;
    ChkDecCy3.Visible:=True;
    LabDChk.Visible:=True;
  end;
}

  VSelect:=0; VSelectOld:=0;
  if Include2Q then VSelectMax:=9 else VSelectMax:=6;

  osvd_wnull:=0.0;

  HamScaling;
  DriveTerms;
  P:=Penalty;
  UpdatePenalty(P);

  EdPer.Text:=InttoStr(NSexPer);
  Ed2Jx.Text:=FtoS(scaling[0],2,0);
  Ed2Jy.Text:=FtoS(scaling[1],2,0);
  EdDpp.Text:=FtoS(scaling[2],2,0);
  EdFac.Text:=FtoS(scaling[3],2,0);
  EdRangeS.Text:=FtoS(maxSexK,wid_ed[0],dec_ed[0]);
  EdStepS.Text :=FtoS(stepSexK,wid_ed[0], dec_ed[0]+2);
  EdRangeO.Text:=FtoS(maxOctK,wid_ed[1],dec_ed[1]);
  EdStepO.Text :=FtoS(stepOctK,wid_ed[1], dec_ed[1]+2);
  EdRangeD.Text:=FtoS(maxDecK,wid_ed[2],dec_ed[2]);
  EdStepD.Text :=FtoS(stepDecK,wid_ed[2], dec_ed[2]+2);
  EdMinAmp.Text:=FtoS(minAmp,5,3);
  EdNumDiff.Text:=FtoS(dppNumDiff*100,6,4);

  for i:=0 to nCHamilton-1 do begin
    CH[i].setValmax(HamAbsMax);
    CH[i].UpDateHam;
  end;

  nsext:=Length(SexFam); noctu:=Length(OctuFam); ndeca:=Length(DecaFam);
// create input lines for the sextupole families
  setlength(CS,nsext+noctu+ndeca);
  for i:=0 to High(CS) do begin
    CSinst:=TCSex(FindComponent('cs_'+IntToStr(i)));
    if CSinst = nil then begin
      CSinst:=TCSex.Create(self);
      CSinst.parent:=Self;
      CSinst.name:= 'cs_'+IntToStr(i);
      if i>=nsext+noctu then CSinst.Init(2, i-nsext-noctu)
      else if i>=nsext  then CSinst.Init(1, i-nsext      )
      else                   CSinst.Init(0, i            );
      CS[i]:=CSinst;
    end;
  end;
// give each sextupole handles to his 'brothers' (includes itself too):
//  for i:=0 to nsext-1 do CS[            i].Brothers(CS,          0,nsext);
//  for i:=0 to noctu-1 do CS[      nsext+i].Brothers(CS,      nsext,noctu);
//  for i:=0 to ndeca-1 do CS[noctu+nsext+i].Brothers(CS,nsext+noctu,ndeca);
  for i:=0 to High(CS) do CS[i].Brothers(CS,0,Length(CS));

//pass octupole Hamiltoninas, which are subject to svd, the handles to the octupoles:
  if noctu>0 then for j:=0 to noctu-1 do for i:=10 to 22 do CH[i].passOctupoleHandle(CS[nsext+j]);

  // create checkboxes to select chroma-sextupoles
  setlength(CSelect,Length(SexFam));
  for i:=0 to High(SexFam) do begin
    CSelInst:=TCheckBox(FindComponent('csel_'+ IntToStr(i)));
    if CSelInst = nil then begin
      CSelInst:=TCheckBox.Create(self);
      CSelInst.parent:=Self;
      CSelInst.name:= 'csel_'+IntToStr(i);
      CSelInst.Checked:=SexFam[i].ChromActive;
      CSelInst.OnClick:=CSelectClick;
      CSelInst.Tag:=i;
      CSelInst.Height:=16;
      CSelInst.Width:=16;
      CSelInst.Caption:='';
      CSelect[i]:=CSelInst;
    end;
  end;

  // create checkboxes to select octupole hamiltonians for octupole-svd
  if noctu>0 then begin
    LabOChk.Visible:=True;
    setlength(ChkOcHam,13);
    for i:=0 to 12 do begin
      CochamInst:=TCheckBox(FindComponent('cocham_'+ IntToStr(i)));
      if CochamInst = nil then begin
        CochamInst:=TCheckBox.Create(self);
        CochamInst.parent:=Self;
        CochamInst.name:= 'cocham_'+IntToStr(i);
        CochamInst.Checked:=false;
        CochamInst.Tag:=i+10;
        CochamInst.Height:=16;
        CochamInst.Width:=16;
        CochamInst.Caption:='';
        CochamInst.Visible:=true;
        CochamInst.OnClick:=ChkOctClick;
        ChkOcHam[i]:=CochamInst;
      end;
    end;
  end else ChkOcHam:=nil;

  if include_combined then begin
    for i:=0 to High(SexFam) do if Ella[SexFam[i].jel].cod=ccomb then CS[i].UnLock;
    ChkComb.State:=cbChecked;
  end else begin
    for i:=0 to High(SexFam) do if Ella[SexFam[i].jel].cod=ccomb then CS[i].Lock;
    ChkComb.State:=cbUnChecked;
  end;

  TDiagPlot;

  osvd_enable:=false;
  if noctu>0 then begin
    LabRangeO.Visible:=True; EdRangeO.Visible:=True;
    LabStepO.Visible:=True;  EdStepO.Visible:=True;
    PanOsvd.Visible:=True;   ButOctOff.Visible:=True; ButOctRes.Visible:=True;
    Osvd_status;
  end;
  if ndeca>0 then begin
    LabRangeD.Visible:=True; EdRangeD.Visible:=True;
    LabStepD.Visible:=True;  EdStepD.Visible:=True;
  end;

  oc_sx_addmode:=True;
  ButPhase.caption:='vec';

// call again to get octu contrib (?)
  HamScaling;
  DriveTerms;
  P:=Penalty;
  UpdatePenalty(P);

  ResizeAll;
  Display;
  CanResize:=True;
  status.Tuneshifts:=false;
end;

//----------------------------------------------------------------

procedure TChroma.OctUpdate;
var
  i: integer;
  P: double;
begin
  for i:=Length(SexFam) to Length(SexFam)+High(OctuFam) do CS[i].SetVal;
  DriveTerms;
  P:=Penalty;
  UpDateHamilton;
  LabPen.Caption:=FloatToStrF(P, ffexponent, 3, 2);
  TDiagPlot;
end;

procedure TChroma.butOsvdDoClick(Sender: TObject);
var
  i: integer;
begin
  for i:=0 to High(osvd_ifam) do with OctuFam[osvd_ifam[i]] do b4Lsave:=b4L;
  Oct_SVBKSB; // this sets octupoles to new values
  OctUpdate;
  ButOsvdUndo.Enabled:=True;
end;

procedure TChroma.ButOsvdUndoClick(Sender: TObject);
var
  i, ifam: integer;
begin
  for i:=0 to High(osvd_ifam) do begin
    ifam:=osvd_ifam[i];
    UpdateOctFamInt(ifam, OctuFam[ifam].b4Lsave);
  end;
  OctUpdate;
  ButOsvdUndo.Enabled:=false;
end;

procedure TChroma.chkOsvdAutoClick(Sender: TObject);
var
  i:integer;
begin
  osvd_active:=osvd_enable and ChkOsvdAuto.Checked;
  if osvd_active then for i:=0 to High(osvd_iham) do CH[osvd_iham[i]].mysetColor(dimcol(oc_col,clWhite,0.5))
  else begin for i:=10 to 11 do CH[i].mysetColor(clLightYellow);  for i:=12 to 22 do CH[i].mysetColor(clWhite); end;
  if osvd_active then begin
    butOsvdDoClick(Sender);
    ButOsvdUndo.Enabled:=false;
  end;
  Osvd_Status;
{
  Osvd_Status;
  if osvd_active then for i:=0 to High(osvd_iham) do CH[osvd_iham[i]].mysetColor(dimcol(oc_col,clWhite,0.5))
  else begin for i:=10 to 11 do CH[i].mysetColor(clLightYellow);  for i:=12 to 22 do CH[i].mysetColor(clWhite); end;
  if not osvd_active then oct_svdcmp // new svdcmp in case auto was switched off
  else begin
    butOsvdDoClick(Sender);
    ButOsvdUndo.Enabled:=false;
  end;
}
end;

procedure TChroma.butOsvdNmClick(Sender: TObject);
// take less values (min=1, i.e. max null = n-1), increase null space.
begin
  if osvd_null < High(osvd_w)-1 then Inc(osvd_null);
  Osvd_WFilter;
end;

procedure TChroma.ButOsvdNpClick(Sender: TObject);
begin
  if osvd_null> 0 then Dec(osvd_null);
  Osvd_WFilter;
end;

//---------------------------------------

procedure TChroma.ResizeAll;
// resize whole GUI
const
  wlab=20; cbxw=14; cbxh=16; hlab=13; wcol=75;
var
  hham, wham, hsex, wsex, wsep, hsep, hplot, wplot,
    hbotline, htopline, wbot, tbot, dist, i, hsxline, hseline, hexline,
    hspace, wsoff, hhoff, x, y, t: integer;
  lht, lhv, lhw, lhi, lsn, lsv, lsl, dt: integer;
begin
  dist:=4;
// heights of input rows defined by highest element:
  htopline:=LabHTarg.Height;
  hbotline:=Ed2Jx.Height;
  hsxline :=EdRangeS.Height;
  hseline :=EdMinAmp.Height;
  hexline := ButEx.Height;

// width separation
  wsep:=round(0.6*ClientWidth);


// available space on left side for Hamiltonians
  hspace:=ClientHeight-htopline-hbotline-4*dist;
// height for each Ham and offset:
  hham :=Trunc(hspace/nCHamilton);
  hhoff:=2*dist+htopline;
  if hham>30 then hham:=30;
// width for Hams
  wham:=wsep-4*dist-Check2Q.Width;

  for i:=nCHamilton-1 downto 0 do
    CH[i].SetSize(dist, hhoff+hham*i, wham, hham);

// add checkboxes
  Check2Q.setBounds (CH[ 7].Left+CH[ 7].Width+dist, CH[ 7].Top+(CH[ 7].Height- cbxh) div 2, cbxw, cbxh);
  CheckQxx.setBounds(CH[12].Left+CH[12].Width+dist, CH[12].Top+(CH[12].Height- cbxh) div 2, cbxw, cbxh);
  CheckCr2.setBounds(CH[10].Left+CH[10].Width+dist, CH[10].Top+(CH[10].Height- cbxh) div 2, cbxw, cbxh);
  CheckOct.setBounds(CH[15].Left+CH[15].Width+dist, CH[15].Top+(CH[15].Height- cbxh) div 2, cbxw, cbxh);

  lhi:=wham+dist;

// add octupole modes checkboxes
  x:=CheckCr2.Left+cbxw+dist;
  y:=CheckCr2.Top;
  for i:=0 to High(ChkOcHam) do begin
    ChkOcHam[i].setBounds(x,y+i*hham, cbxw, cbxh);
  end;
  LabOChk.SetBounds(x,y-hham, cbxw, cbxh);

  y:=CH[23].Top+(CH[23].Height- cbxh) div 2;
  ChkDecCx3.SetBounds(x,y       , cbxw, cbxh);
  ChkDecCy3.SetBounds(x,y+  hham, cbxw, cbxh);
  LabDChk.SetBounds(x,y-hham, cbxw, cbxh);



  y:=CH[22].Top;
  Butphase.setbounds(x,y,25,17);

// get "tabulators" to align top line
  CH[0].gettabs(lht, lhv, lhw);
  LabHTarg.Left:=dist+lht; LabHVal.Left:=dist+lhv;
  LabHweight.Left:=dist+lhw; LabHInc.Left:=dist+lhi;

// scaling of bottom line:
  tbot:= hhoff+hham*nCHamilton;
  edper.Left:=dist; edper.top:=tbot;
  x:=dist+edper.width+2;
  labper.left:=x; labper.top:=tbot+2;
  x:=x+labper.width+dist;
  LabScal.Left:=x;
  x:=x+LabScal.width+dist;
  LabScal.Top:=tbot;
  wbot:=(wham-x) div 4;
  Lab2Jx.Left:=x; Lab2Jx.Top:=tbot+2;
  Ed2Jx.Left:=Lab2Jx.Left+Lab2Jx.Width+dist; Ed2Jx.Top:=tbot;
  Lab2Jy.Left:=x+dist+wbot; Lab2Jy.Top:=tbot+2;
  Ed2Jy.Left:=Lab2Jy.Left+Lab2Jy.Width+dist; Ed2Jy.Top:=tbot;
  Labdpp.Left:=x+dist+2*wbot; Labdpp.Top:=tbot+2;
  Eddpp.Left:=Labdpp.Left+Labdpp.Width+dist; Eddpp.Top:=tbot;
  Labfac.Left:=x+dist+3*wbot; Labfac.Top:=tbot+2;
  Edfac.Left:=Labfac.Left+Labfac.Width+dist; Edfac.Top:=tbot;

// now the right column...
// available space for sextupoles:
// want to have
  hsex:=32;
  t:=Length(SexFam)+1;
  if Length(OctuFam)>0 then t:=t+Length(OctuFam)+1;
  if Length(DecaFam)>0 then t:=t+Length(DecaFam)+1;
  hspace:=hsex*t+(htopline+hsxline+4*dist);
  hsep:=round(0.7*clientheight);
  if hspace>hsep then hspace:=hsep else hsep:=hspace;
  hspace:=hsep-htopline-hsxline-4*dist;

// height of each line (offset as before)
  hsex :=Trunc(hspace/Length(CS));

// offset and width for right column
  wsoff:=cbxw+wsep;
  wsex:=ClientWidth-wsoff-dist;

  t:=hhoff;
  for i:=0 to High(SexFam) do begin
    CSelect[i].Left:=wsoff+dist;
    CSelect[i].Top:= hhoff+Round(hsex*(i+0.5)-0.5*CSelect[i].Height);
    CS[i].SetSize (wsoff+2*dist+cbxw,t ,wsex-dist-cbxw, hsex);
    Inc(t,hsex);
  end;
// scaling for sext controls line
  x:=wsoff+wlab;
  with LabRangeS do begin setbounds(x, t+(hsex-height) div 2,width,height); inc (x,Width+  dist); end;
  with EdRangeS  do begin setbounds(x, t+(hsex-height) div 2,width,height); inc (x,Width+2*dist); end;
  with LabStepS  do begin setbounds(x, t+(hsex-height) div 2,width,height); inc (x,Width+  dist); end;
  with EdStepS   do begin setbounds(x, t+(hsex-height) div 2,width,height); inc (x,Width+2*dist); end;
  Butsmat.setBounds(x,t,45,24);
  Inc(t,hsex);
  for i:=0 to High(OctuFam)do begin
    CS[i+Length(SexFam)].SetSize (wsoff+2*dist+cbxw,t ,wsex-dist-cbxw, hsex);
    Inc(t,hsex)
  end;
  if Length(OctuFam)>0 then begin
    x:=wsoff+wlab;
    with LabRangeO do begin setbounds(x, t+(hsex-height) div 2,width,height); inc (x,Width+  dist); end;
    with EdRangeO  do begin setbounds(x, t+(hsex-height) div 2,width,height); inc (x,Width+2*dist); end;
    with LabStepO  do begin setbounds(x, t+(hsex-height) div 2,width,height); inc (x,Width+  dist); end;
    with EdStepO   do begin setbounds(x, t+(hsex-height) div 2,width,height); inc (x,Width+2*dist); end;
    with butoctoff do begin setbounds(x, t+(hsex-height) div 2,30,17); inc(x,32); end;
    with butoctres do begin setbounds(x, t+(hsex-height) div 2,20,17); end;
    Inc(t,hsex);
    x:=wsoff+wlab;
    PanOsvd.SetBounds(x,t ,wsex,hsex);
    dt:=round((wsex-butosvddo.width-butosvdundo.width-chkosvdauto.width-labosvdcon.width-labosvdnw.width-2*butosvdnm.width-2*dist-2)/7);
    if dt<0 then dt:=0; if dt>10 then dt:=10;
    x:=dt;
    with butosvddo   do begin setbounds(x,(hsex-height) div 2, width, height); inc(x,width+dt); end;
    with butosvdundo do begin setbounds(x,(hsex-height) div 2, width, height); inc(x,width+dt); end;
    with chkosvdauto do begin setbounds(x,(hsex-height) div 2, width, height); inc(x,width+dt); end;
    with labosvdcon  do begin setbounds(x,(hsex-height) div 2, width, height); inc(x,width+dt); end;
    with labosvdnw   do begin setbounds(x,(hsex-height) div 2, width, height); inc(x,width+dt); end;
    with butosvdnm   do begin setbounds(x,(hsex-height) div 2, width, height); inc(x,width+2); end;
    with butosvdnp   do begin setbounds(x,(hsex-height) div 2, width, height); end;
    Inc(t,hsex);
  end;
  for i:=0 to High(DecaFam) do begin
    CS[i+Length(SexFam)+Length(OctuFam)].SetSize (wsoff+2*dist+cbxw,t ,wsex-dist-cbxw, hsex);
    Inc(t,hsex);
  end;
  if Length(DecaFam)>0 then begin
    x:=wsoff+wlab;
    with LabRangeD do begin setbounds(x, t+(hsex-height) div 2,width,height); inc (x,Width+  dist); end;
    with EdRangeD  do begin setbounds(x, t+(hsex-height) div 2,width,height); inc (x,Width+2*dist); end;
    with LabStepD  do begin setbounds(x, t+(hsex-height) div 2,width,height); inc (x,Width+  dist); end;
    with EdStepD   do begin setbounds(x, t+(hsex-height) div 2,width,height); inc (x,Width+2*dist); end;
    Inc(t,hsex);
  end;

  CS[0].gettabs(lsn, lsv, lsl);
  x:=wsoff+dist+cbxw;
  LabSChrom.Left:=wsoff+dist; LabSName.Left:=x+lsn;
  LabSVal.Left:=x+lsv; LabSLock.Left:=x+lsl;
  ChkComb.SetBounds(x+(lsv+lsl) div 2, 6, (lsl-lsv) div 2-2, 16);

// Plot starts below separator. offset and available space:
  hhoff:=hsep+dist;
  hspace:=ClientHeight-hsep-8*dist-hseline-hexline;

  hplot:=hspace;  wplot:=wsex;
// be square :
  if wplot>hplot then wplot:=hplot else hplot:=wplot;
//*  Vdiag.setSize(wsoff, hhoff, wplot, hplot);

// Offset at bottom of plot now (maybe reduced due to squaring):
// scaling of select line:
  t:=hhoff+hplot+2*dist;

  labpath.setbounds(wsoff, t           ,2*wcol, hlab);
  laba1l.setbounds (wsoff, t+   hlab+1 ,2*wcol, hlab);
  laba2l.setbounds (wsoff, t+2*(hlab+1),2*wcol, hlab);
  laba3l.setbounds (wsoff, t+3*(hlab+1),2*wcol, hlab);

  x:=wsoff+2*dist+ (3*wcol) div 2;
  ButSelect.Left:=x; ButSelect.top:=t;
  Inc(x, wcol+dist);
  LabMinAmp.Left:=x; LabMinAmp.Top:=t-8;
  LabNumDiff.Left:=x; LabNumDiff.Top:=t+8;
  Inc(x, LabMinAmp.Width+dist);
  EdMinAmp.Left:=x; EdMinAmp.Top:=t-8;
  EdNumDiff.Left:=x; EdNumDiff.Top:=t+8;

// scaling of minimizer/exit line:
  Inc(t, 2*dist+hseline);
  x:=wsoff+2*dist+(3*wcol) div 2;
  ButMin.Left:=x; ButMin.Top:=t;
  Inc(x, wcol+dist);
  LabPen.Left:=x; LabPen.Top:=t+2;
  Inc(x, LabPen.Width+3*dist);
  ButEx.Left:=x; ButEx.Top:=t;
end;

procedure TChroma.FormResize(Sender: TObject);
begin
   if CanResize then begin
     ResizeAll;
//*     VDiag.plot.ReSetScale;
//*     VDiagPlot; //replot the vector diagram since it is not saved
   end;
end;



procedure TChroma.Display;
begin
  UpdateHamilton;
end;



procedure TChroma.ButExClick(Sender: TObject);
var
  mr:word;

begin
{
//check for changes ella vs. elem
  check:=True; term:=True;

  for ia:=1 to glob.NElla do begin
    i:=0; repeat inc(i) until elem[i].nam=ella[ia].nam;
    case ella[ia].cod of
      csext: check:=check and (abs(elem[i].ms-ella[ia].ms)<epsi);
      ccomb: check:=check and (abs(elem[i].cms-ella[ia].cms)<epsi);
      coctu: check:=check and (abs(elem[i].rl-ella[ia].rl)<epsi);
      cdeca: check:=check and (abs(elem[i].sl-ella[ia].sl)<epsi);
    end;
  end;

  remember:=check;
// save: write ella to elem; no save: reset ella to elem
// (because only MakeLattice copies elem to ella)

  if not check then begin
    mresult:= MessageDlg('Accept new sextupoles values?', MtConfirmation, mbYesNoCancel,0);
    case mresult of
      mrCancel: begin
        term:=false;
      end;
      mrYes: begin
        for ia:=1 to glob.NElla do begin
          i:=0; repeat inc(i) until elem[i].nam=ella[ia].nam;
          elem[i]:=ella[ia];
        end;
        remember:=true;
      end;
      mrNo: begin
        for ia:=1 to glob.NElla do begin
          i:=0; repeat inc(i) until elem[i].nam=ella[ia].nam;
          ella[ia]:=elem[i];
        end;
      end;
    end;
  end;
}

  mr:=EllaSave;

  if mr=mrYes then begin
    status.Tuneshifts:=includeQxx;
    status.Chromas:=true;
    if includeQxx then setStatusLabel(stlab_tsh,status_flag) else setStatusLabel(stlab_tsh,status_void); 
    with SnapSave do begin
      qxx:=HamV[12].re;
      qxy:=HamV[13].re;
      qyy:=HamV[14].re;
      ChromX:=HamV[0].re;
      ChromY:=HamV[1].re;
      if includeCr2 then begin
        cx2:=HamV[10].re;
        cy2:=HamV[11].re;
        cx3:=HamV[23].re;
        cy3:=HamV[24].re;
      end else begin
        cx2:=0; cy2:=0; cx3:=0; cy3:=0;
      end;
    end;
  end;
  if mr<>mrCancel then Exit;
end;

procedure TChroma.Exit;
begin
//close tune diagram (in chromlib)
  CloseTuneDiagram;
  SVectorPlot.Close;
  ChromSaveDef;
  ChromDispose;
  CS:=nil;
  CSelect:=nil;
  Close;
  Chroma:=nil;
  Release;
end;

procedure TChroma.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CloseTuneDiagram;
  SVectorPlot.Close;
  ChromDispose;
  CS:=nil;
  CSelect:=nil;
  Chroma:=nil;
  Release;
end;

//---------------------------------------------------------
// common handler for the scaling parameter fields

procedure TChroma.UpdateScPar(Ed: TEdit; v: real);
var
  i: integer;
  P: double;
begin
  scaling[Ed.Tag]:=v;
  Ed.Text:=FtoS(v,2,0);
  HamScaling;
  P:=Penalty;
  UpdatePenalty(P);
  TDiagPlot;
  for i:=0 to nCHamilton-1 do begin
    CH[i].setValmax(HamAbsMax);
    CH[i].UpDateHam;
  end;
end;

//---------------------------------------------------------

procedure TCHroma.EdScParKeyPress(Sender: TObject; var Key: Char);
var
  Ed: TEdit;
  v0, v1: real;
begin
  Ed:=Sender as TEdit;
  v0:=scaling[Ed.Tag];
  v1:=v0;
  if TEKeyVal(Ed, Key, v1, 2, 0) then UpdateScPar(Ed, v1);
end;

//--------------------------------------------------------

procedure TChroma.EdScParExit(Sender: TObject);
var
  Ed: TEdit;
  v0: real;
begin
  Ed:=Sender as TEdit;
  v0:=scaling[Ed.Tag];
  UpdateScPar(Ed,v0);
end;

//-----------------------------------------------------------

procedure TChroma.Check2QClick(Sender: TObject);
var
  P: double;
begin
  Include2Q:=Check2Q.Checked;
  VUpdate;
  DriveTerms_2Q;
  P:=Penalty;
  UpdatePenalty(P);
  CH[7].MinInclude(Include2Q);
  CH[8].MinInclude(Include2Q);
  CH[9].MinInclude(Include2Q);
  CH[7].UpDateHam;
  CH[8].UpDateHam;
  CH[9].UpDateHam;
end;

procedure TChroma.CheckQxxClick(Sender: TObject);
var
  i: integer;
  P: double;
begin
  IncludeQxx:=CheckQxx.Checked;
  DriveTerms_Qxx;
  P:=Penalty;
  UpdatePenalty(P);
  for i:=12 to 14 do begin
    CH[i].UpdateHam;
    CH[i].MinInclude(IncludeQxx);
  end;
  TDiagPlot;
end;

procedure TChroma.CheckCr2Click(Sender: TObject);
var
  i: integer;
begin
  IncludeCr2:=CheckCr2.Checked;
  for i:= 10 to 11 do  CH[i].MinInclude(IncludeCr2);
  for i:=23 to 24 do   CH[i].MinInclude(IncludeCr2);
  UpdateChroma;
end;

procedure TChroma.UpdateChroma;
var
  i: integer;
  P: double;
begin
  IncludeCr2:=CheckCr2.Checked;
  DriveTerms_Cr2;
  P:=Penalty;
  UpdatePenalty(P);
  UpdatePath;
  for i:=  0 to  1 do  CH[i].UpdateHam;
  for i:= 10 to 11 do  CH[i].UpdateHam;
  for i:= 23 to 24 do  CH[i].UpdateHam;
  TDiagPlot;
end;



procedure TChroma.CheckOctClick(Sender: TObject);
var
  i: integer;
  P: double;
begin
  IncludeOct:=CheckOct.Checked;
  DriveTerms_Oct;
  P:=Penalty;
  UpdatePenalty(P);
  for i:=15 to 22 do begin
    CH[i].UpdateHam;
    CH[i].MinInclude(IncludeOct);
  end;
end;

{--------------------------------------------------------------
selection of a chroma check box
}

procedure TChroma.CSelectClick(Sender: TObject);
var
  cst: TCheckBox;
  myfam, j: integer;
  P: double;
begin
  cst:=Sender as TCheckBox;
  myfam:=cst.Tag;
  if cst.Checked then begin
    SexFam[myfam].chromactive:=True;
// if first place empty put there, else (if 2nd place empty or not), put
// there, and maybe overwrite previous
    if SFSDFlag[0]=-1 then SFSDFlag[0]:=myfam
    else begin
// clear family that was here:
      if SFSDFlag[1]>-1 then CSelect[SFSDFlag[1]].Checked:=False;
// other too?      if SFSDFlag[0]>-1 then CSelect[SFSDFlag[0]].Checked:=False;
// -> leads to double execution...?
      SFSDFlag[1]:=myfam;
    end;
  end else begin
    SexFam[myfam].chromactive:=False;
    if SFSDFlag[0]=myfam then SFSDFlag[0]:=-1;
    if SFSDFlag[1]=myfam then SFSDFlag[1]:=-1;
  end;
// auto-mode if two families have been selected
  AutoChrom:= (SFSDFlag[0]<>-1) and (SFSDFlag[1]<>-1);

  for j:=0 to High(SexFam) do begin
    CS[j].mySetColor(clWhite);
    if Ella[SexFam[j].jel].cod=csext then CS[j].ChromUnLock else if include_combined then CS[j].ChromUnLock;
    // not yet the best solution in case combs are used for chrom corr... 26.2.19
  end;


  if AutoChrom then begin
// update the chroma matrix - if it fails (because one sext fam has zero disp..)
// undo auto mode - else do a correction incl. new driveterms and mark
    if UpDateChromMatrix then begin
      MessageDlg('Chromaticity correction impossible with families '
        +Ella[SexFam[SFSDFlag[0]].jel].nam+' and '+Ella[SexFam[SFSDFlag[1]].jel].nam+'.',
         mtWarning, [mbok],0);
      AutoChrom:=false;
      CSelect[SFSDFlag[0]].Checked:=false;
      CSelect[SFSDFlag[1]].Checked:=false;
    end else begin
      ChromCorrect;
      if osvd_enable then begin
        DriveTerms_Cr2;
        DriveTerms_Qxx;
        Oct_SVBKSB;
        for j:=0 to High(OctuFam) do CS[length(SexFam)+j].SetVal;
      end;
      Driveterms;
      P:=Penalty;
      UpDatePenalty(P);
      Display;
      TDiagPlot;
      for j:=0 to 1 do begin
        CH[j].MinInclude(false);
        CH[j].UpdateWeight(0.0);
        CH[j].mySetColor(chromActiveColor);
        CS[SFSDFlag[j]].mySetColor(chromActiveColor);
        CS[SFSDFlag[j]].ChromLock;
        CS[SFSDFlag[j]].SetVal;
        CH[j].getChromSexHandles(CS[SFSDFlag[0]],CS[SFSDFlag[1]]);
      end;
    end;
  end else begin
    for j:=0 to 1 do begin
      CH[j].MinInclude(true);
      CH[j].mySetColor(clLightYellow);
    end;
  end;
end;
//---------------------------------------------------------

procedure TChroma.EdSODKeyPress(Sender: TObject; var Key: Char);
var
  v: real;
  ed: TEdit;
  dsd, id: integer;
begin
  Ed:=Sender as TEdit;
  id:=ed.Tag; dsd:=0; if id >=10 then begin Dec(id,10); Inc(dsd,2); end;
  case ed.Tag of
    0: v:=maxSexK;
    1: v:=maxoctK;
    2: v:=maxDecK;
    10: v:=stepSexK;
    11: v:=stepOctK;
    12: v:=stepDecK;
  end;
  if TEKeyVal(Ed, Key, v, wid_ed[id], dec_ed[id]+dsd) then UpdateEdSOD(Ed,v);
end;

procedure TChroma.EdSODExit(Sender: TObject);
var
  ed: TEdit;
begin
  Ed:=Sender as TEdit;
  case ed.Tag of
    0:  UpdateEdSOD(Ed,maxSexK);
    1:  UpdateEdSOD(Ed,maxOctK);
    2:  UpdateEdSOD(Ed,maxDecK);
   10:  UpdateEdSOD(Ed,stepSexK);
   11:  UpdateEdSOD(Ed,stepoctK);
   12:  UpdateEdSOD(Ed,stepDecK);
  end;
end;

//-------------------------------------

procedure TChroma.UpdateEdSOD(Ed: TEdit; v: real);
var
  dsd, id, i: integer;
begin
  id:=ed.Tag; dsd:=0; if id >=10 then begin Dec(id,10); Inc(dsd,2); end;
  Ed.Text:=FtoS(v,wid_ed[id], dec_ed[id]+dsd);
  case ed.Tag of
    0: maxSexK:=v;
    1: maxOctK:=v;
    2: maxDecK:=v;
   10: stepSexK:=v;
   11: stepOctK:=v;
   12: stepDecK:=v;
  end;
  for i:=0 to High(CS) do CS[i].SetRange;
end;

//-------------------------------------

procedure TChroma.UpdateMinAmp(v: real);
begin
  EdMinAmp.Text:=FtoS(v,5,3);
  minAmp:=v;
end;

procedure TChroma.UpdateNumDiff(v: real);
begin
  EdNumDiff.Text:=FtoS(v*100,5,3);
  dppNumDiff:=v;
  set_cd_matrix;
  UpdateChroma;
end;

procedure TChroma.EdMinAmpKeyPress(Sender: TObject; var Key: Char);
var v: real;
begin
  v:=minAmp;
  if TEKeyVal(EdMinAmp, Key, v, 5,3) then UpdateMinAmp(v);
end;

procedure TChroma.EdNumDiffKeyPress(Sender: TObject; var Key: Char);
var v: real;
begin
  v:=dppNumDiff*100;
  if TEKeyVal(EdNumDiff, Key, v, 6,4) then if Key=#0 then UpdateNumDiff(v/100);
end;

procedure TChroma.EdMinAmpExit(Sender: TObject);
begin
  UpdateMinAmp(minAmp);
end;

procedure TChroma.EdNumDiffExit(Sender: TObject);
begin
  UpdateNumDiff(dppNumDiff);
end;

{----------------------------------------------------------------------}

function PenaltyFunction (Var p: PowellVector): real;

  {calculates the penalty function, uses hyperbolic scaling of input parameters
   to avoid run off to infinity}

var
  j: Integer;
  kv: real;

begin
  Application.ProcessMessages;

  for j:=1 to Powellncom do begin
    kv:=maxSexK*p[j]/(1+Abs(p[j]));
    CS[isfampow[j]].UpdateValbyMin(kv);
  end;
  if AutoChrom then begin
    ChromCorrect;
    for j:=0 to 1 do CS[SFSDFlag[j]].SetVal;
  end;
  if osvd_active then begin
    DriveTerms_Qxx; DriveTerms_Cr2; // driveterms may have changed
    Oct_SVBKSB; // this sets octupoles to new values
    for j:=Length(SexFam) to Length(SexFam)+High(OctuFam) do CS[j].SetVal;
  end;
  DriveTerms;

  PenCur:=Penalty*PenNorm;
//opamessage(0,ftos(pencur,-5,2));
  if PenCur < PenOld then begin
    LabPen_handle.Font.Color:=clGreen;
    UpdateHamilton;
    SVectorPlot.Star;
    TDiagPlot;
    PenOld := PenCur;
  end
  else begin
    LabPen_handle.Font.Color:=clRed;
  end;
    LabPen_handle.Caption:=FloatToStrF(PenCur, ffexponent, 3, 2);
  PenaltyFunction:=PenCur;
end;

procedure TChroma.ButMinClick(Sender: TObject);

var
  isf, i, j: integer;
  kv: real;

begin
// start minimization procedure
// norm penalty to 1 to better see progress
  if (PowellStatus = 0) then begin
    PenSave:=Penalty;
    PenNorm:=1.0/(PenSave+1E-20);
    PenOld:=1.0;
    PowellLinMinStep:=minamp;

  // compose vector from available sexts (not locked, not used for chromkorr}
    Powellncom:=0;
    for isf:=0 to High(SexFam) do begin
      with SexFam[isf] do begin
        if not (ChromActive or locked) then begin
          inc(Powellncom);
          iellapow[Powellncom] :=jel; // runs from 1 to ncom
          isfampow[Powellncom] :=isf; // runs from 1 to ncom
        end;
//        if abs(getSexKval(jel))>maxSexK then begin
//          maxSexK:=1.001*abs(getSexKval(jel));
        if abs(ml*nslice)>maxSexK then begin
          maxSexK:=1.001*abs(ml*nslice);
          EdRangeS.Text:=FtoS(maxSexK,wid_ed[0],dec_ed[0]);
        end;
      end;
    end;

    for i:=1 to Powellncom do begin
      with SexFam[isfampow[i]] do begin
//        PowK[i]:=getSexKval(iellapow[i])/(maxSexK-abs(GetSexKval(iellapow[i])));
        PowK[i]:=ml*nslice/(maxSexK-abs(ml*nslice));
      end;
    end;

    PowellBreak:=False;
    PowellStatus:=1;
    ButMin.Caption:='Break';
//--------------------------------------------------------------------
    POWELL (PowK, {PowDirec,} Powellncom, 0.001, PenaltyFunction);
//--------------------------------------------------------------------
    PowellStatus:=0;
    ButMin.Caption:='Start';

    for j:=1 to Powellncom do begin
      kv:=maxSexK*PowK[j]/(1+Abs(PowK[j]));
      CS[isfampow[j]].UpdateValbyMin(kv);
    end;

    if AutoChrom then ChromCorrect;
    DriveTerms;
    if AutoChrom then for j:=0 to 1 do CS[SFSDFlag[j]].SetVal;

    PenCur:=Penalty*PenNorm;
    UpdateHamilton;

    if PowellBreak then LabPen.Font.Color:=clFuchsia else LabPen.Font.Color:=clBlue;
    LabPen.Caption:=FloatToStrF(PenCur, ffexponent, 3, 2);

  end else begin
    PowellBreak:=True;
  end;

end;


procedure TChroma.VUpdate;
var
  i: integer;
begin
  if Include2Q then VSelectMax:=9 else VSelectMax:=6;

  if VSelect > VSelectMax then begin
    VSelectOld:=VSelect;
    VSelect:=0;
  end;

  if (VSelectOld > 0) then begin
    if (VSelectOld = 1) then begin
      for i:=2 to VSelectMax do  CH[i].mySetColor(clWhite);
    end else begin
      CH[VSelectOld].mySetColor(clWhite);
    end;
  end;

  if (VSelect > 0) then begin
    if (VSelect = 1) then begin
      for i:=2 to VSelectMax do  CH[i].mySetColor(SexColor[i-2]);
    end else begin
      CH[VSelect].mySetColor(HamResActiveColor);
    end;
  end;
  SVectorPlot.Init;
end;

procedure TChroma.butselectClick(Sender: TObject);
begin
  VSelectOld:=VSelect;
  if VSelect < VSelectMax then Inc(VSelect) else VSelect:=0;
  VUpdate;
end;



procedure TChroma.edperKeyPress(Sender: TObject; var Key: Char);
var
  v1,r: real;
  i, oldper:integer;
  P: double;
begin
  if TEKeyVal(Edper, Key, v1, 2, 0) then begin
    NSexPer:=Round(v1);
    oldper:=PerScaFac;
    S_Period(NSexPer);
    r:=perscafac/oldper;
    for i:=0 to nCHamilton-1 do CH[i].setTarget(r*HamTarg[i]);
//    HamScaling;
    DriveTerms;
    P:=Penalty;
    UpdatePenalty(P);
    TDiagPlotFull;
    for i:=0 to nCHamilton-1 do begin
      CH[i].setValmax(HamAbsMax);
      CH[i].UpDateHam;
    end;
    UpdatePath;
  end;
end;

procedure TChroma.edperExit(Sender: TObject);
begin
  EdPer.Text:=FtoS(NSexPer,2,0);
end;

procedure TChroma.butsmatClick(Sender: TObject);
begin
  S_Testout;
end;

procedure TChroma.ChkOctClick(Sender: TObject);
var
//  cbx: TCheckBox;
  i: integer;
begin
//  cbx:=sender as TCheckBox;
  osvd_iham:=nil;
  for i:=0 to High(ChkOcHam) do begin
    if ChkOcHam[i].Checked then begin
      setlength(osvd_iham, length(osvd_iham)+1);
      osvd_iham[High(osvd_iham)]:=10+i;
    end;
  end;
  Oct_SVDCMP(false);
  Osvd_Status;
end;

//---------------------------------

procedure TChroma.butphaseClick(Sender: TObject);
var
  P:double;
begin
  oc_sx_addmode:=not oc_sx_addmode;
  if oc_sx_addmode then butphase.caption:='vec' else butphase.caption:='abs';
  DriveTerms;
  P:=Penalty;
  UpdateHamilton;
  UpdatePenalty(P);
end;


procedure TChroma.ButOctOffClick(Sender: TObject);
var    i: integer;
begin
  for i:=0 to High(OctuFam) do with OctuFam[i] do begin
    b4Lsave:=b4L;
    UpdateOctFamInt(i,0.0);
  end;
  OctUpdate;
  butoctres.enabled:=true;
end;

procedure TChroma.butoctresClick(Sender: TObject);
var    i: integer;
begin
  for i:=0 to High(OctuFam) do with OctuFam[i] do begin
    b4L:=b4Lsave;
    UpdateOctFamInt(i,b4L);
  end;
  OctUpdate;
  butoctres.enabled:=false;
end;

procedure TChroma.ChkCombClick(Sender: TObject);
var i: integer;
begin
  include_combined:=ChkComb.Checked;
  if include_combined then begin
    for i:=0 to High(SexFam) do if Ella[SexFam[i].jel].cod=ccomb then CS[i].UnLock;
  end else begin
    for i:=0 to High(SexFam) do if Ella[SexFam[i].jel].cod=ccomb then CS[i].Lock;
  end;
end;

end.
