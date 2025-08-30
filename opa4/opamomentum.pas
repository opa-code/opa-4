
unit opamomentum;

{$MODE Delphi}
interface

uses
  momentumlib, LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  globlib, ASaux, linoplib, ASfigure, opatunediag, StdCtrls, Grids, ExtCtrls, mathlib;

type

  { Tmomentum }

  Tmomentum = class(TForm)
    fig: TFigure;
    butex: TButton;
    EdRange: TEdit;
    EdSteps: TEdit;
    labRange: TLabel;
    LabSteps: TLabel;
    Butgo: TButton;
    pancheck: TPanel;
    rgshow: TRadioGroup;
    butps: TButton;
    labrangunit: TLabel;
    pango: TPanel;
    panfit: TPanel;
    butfit: TButton;
    panctrl: TPanel;
    labnford: TLabel;
    Ednford: TEdit;
    chkper: TCheckBox;
    gfit: TStringGrid;
    butfunit: TButton;
    labfunit: TLabel;
    buttxt: TButton;
    PanMin: TPanel;
    LabName: TLabel;
    LabWeight: TLabel;
    LabPenCo: TLabel;
    LabPentot: TLabel;
    ButReset: TButton;
    ButOp: TButton;
    LabInc: TLabel;
    LabKno: TLabel;
    LabBnL: TLabel;
    butpdiff: TButton;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);

    procedure ButNamClick (Sender:TObject);
    procedure butexClick(Sender: TObject);
    procedure ButgoClick(Sender: TObject);
    procedure butpsClick(Sender: TObject);
    procedure butfunitClick(Sender: TObject);
    procedure buttxtClick(Sender: TObject);
    procedure butfitClick(Sender: TObject);

    procedure gfitKeyPress(Sender: TObject; var Key: Char);

    procedure rbClick(Sender: TObject);
    procedure cbCheck(Sender: TObject);

    procedure EdStepsKeyPress(Sender: TObject; var Key: Char);
    procedure EdStepsExit(Sender: TObject);
    procedure EdRangeKeyPress(Sender: TObject; var Key: Char);
    procedure EdRangeExit(Sender: TObject);
    procedure EdnfordExit(Sender: TObject);
    procedure EdnfordKeyPress(Sender: TObject; var Key: Char);
    procedure EdwgtExit(Sender: TObject);
    procedure EdwgtKeyPress(Sender: TObject; var Key: Char);
    procedure EdvarExit(Sender: TObject);
    procedure EdvarKeyPress(Sender: TObject; var Key: Char);
    procedure ButResetClick(Sender: TObject);
    procedure ButOpClick(Sender: TObject);
    procedure chkperClick(Sender: TObject);
    procedure butpdiffClick(Sender: TObject);

  private
    procedure MomResize;
    procedure MomFitDefaults (rw:boolean);
    procedure SetArrayLength;
    procedure gfitSetMode;
    procedure Gfitcell;
    procedure getknobs;
    procedure ReCalculate (itag: integer; relk: real);
  public
    procedure Start (TP:TtunePlot);

  end;

  function  PenaltyFunction (Var p: PowellVector): real;


var
  momentum: Tmomentum;

implementation

{$R *.lfm}


//------ Creator, called only once at program start -----------------------------

procedure Tmomentum.FormCreate(Sender: TObject);
var
  i: integer;
  rbpm: TRadioButton;
  cbpm: TCheckBox;
begin
  fig.assignScreen;
//dynamically create my radio buttons and check boxes
  for i:=0 to nPlotMode-1 do begin
    rbpm :=TRadioButton (FindComponent( 'rbpm_'+IntToStr(i)));
    if rbpm = nil then begin
      rbpm:=TRadioButton.Create(self);
      rbpm.name:= 'rbpm_'+IntToStr(i);
      rbpm.parent:=rgshow;
      rbpm.caption:= plot_cap[i];
      rbpm.Tag:=i;
      rbpm.OnClick:=rbClick;
      if ires2[i]=-1 then begin
        rbpm.font.Color:=rescol[ires1[i]];
        cbpm :=TCheckBox (FindComponent( 'cbpm_'+IntToStr(i)));
        if cbpm = nil then begin
          cbpm:=TCheckBox.Create(self);
          cbpm.name:= 'cbpm_'+IntToStr(i);
          cbpm.parent:=pancheck;
          cbpm.caption:='';
// tag checkbox with corresponding plot mode: cb.Tag=PlotMode
// Minimizer buttons and edit fields are tagged with ires1[cb.Tag]
          cbpm.Tag:=i;
          cbpm.OnClick:=cbCheck;
        end;
      end else rbpm.font.Color:=clBlack;
    end;
  end;
  for i:=0 to op_nmax-1 do begin
    if op_butnam[i]=nil then begin
      op_butnam[i]:=TButton.Create(self);
      with op_butnam[i] do begin
        name:='op_butnam_'+inttostr(i);
        caption:=' - - ';
        tag:=-1;
        parent:=PanMin;
        enabled:=false;
        OnClick:=ButNamClick;
      end;
    end;
    if op_edtwgt[i]=nil then begin
      op_edtwgt[i]:=TEdit.Create(self);
      with op_edtwgt[i] do begin
        name:='op_edtwgt_'+inttostr(i);
        text:='1.0';
        tag:=-1;
        parent:=PanMin;
        enabled:=false;
        OnKeyPress:=EdwgtKeyPress;
        OnExit:=EdwgtExit;
      end;
    end;
    if op_labpen[i]=nil then begin
      op_labpen[i]:=TLabel.Create(self);
      with op_labpen[i] do begin
        name:='op_labpen_'+inttostr(i);
        caption:='0.00E+00';
        tag:=-1;
        parent:=PanMin;
      end;
    end;
  end;
  for i:=0 to kn_nmax-1 do begin
    if kn_cbxnam[i]=nil then begin
      kn_cbxnam[i]:=TCheckBox.Create(self);
      with kn_cbxnam[i] do begin
        name:='kn_cbxnam_'+inttostr(i);
        caption:=' - - ';
        tag:=-1;
        parent:=PanMin;
        Visible:=False;
        Checked:=True;
      end;
    end;
    if kn_labval[i]=nil then begin
      kn_labval[i]:=TLabel.Create(self);
      with kn_labval[i] do begin
        name:='kn_labval_'+inttostr(i);
        caption:='0.00e+00';
        tag:=-1;
        parent:=PanMin;
        Visible:=False;
      end;
    end;
    if kn_edtvar[i]=nil then begin
      kn_edtvar[i]:=TEdit.Create(self);
      with kn_edtvar[i] do begin
        name:='kn_edtvar_'+inttostr(i);
        text:='1.0';
        tag:=-1;
        parent:=PanMin;
        enabled:=false;
        Visible:=False;
        OnKeyPress:=EdvarKeyPress;
        OnExit:=EdvarExit;
      end;
    end;

  end;
end;

//--------------- start, public called from opamenu for initialization ------

procedure Tmomentum.Start(TP: TtunePlot);
var
//  rbpm: TRadioButton;
//  cbpm: TCheckBox;
  i, k: integer;
begin
  tuneplot_HANDLE:=TP;
  gfit_HANDLE:=gfit;
  ChkPer_HANDLE:=ChkPer;
  ButFit_HANDLE:=ButFit;
  Labpentot_HANDLE:= Labpentot;
  Fig_HANDLE:=Fig;

  fig.assignScreen;
  Nsteps  :=IDefget('tshift/steps');
  Range   :=FDefget('tshift/range');
  left    :=IDefGet('tshift/lef'); if left<0 then left:=50;
  top     :=IDefGet('tshift/top'); if top< 0 then top:=50;
  nford   :=IDefget('tshift/nford');
  if nford > nMomFit_order then nford:=nMomFit_order;
  plotmode:=IDefget('tshift/pmode');
  funitstat:=IDefget('tshift/tmode');
  if (plotmode<0) or (plotmode >= nPlotmode) then Plotmode:=0;
  if (funitstat<0) or (funitstat>1) then funitstat:=0;
  clientwidth   :=IDefGet('tshift/wid');
  if (clientwidth<0) or (clientwidth>screen.width) then clientwidth:=400;
  clientheight  :=IDefGet('tshift/hei');
  if (clientheight<0) or (clientheight>screen.height) then clientheight:=550;


  EdRange.text:=FtoS(range,5,2);
  EdSteps.text:=InttoStr(NSteps);
  Ednford.text:=InttoStr(nford);
  SetArrayLength;
//  rbpm :=TRadioButton (FindComponent( 'rbpm_'+inttostr(plotmode)));
  Want_periodic:=status.Periodic;
  chkper.Checked:=Want_periodic;
  labfunit.caption:=labfunitText[funitstat];
  for i:=0 to nresult-1 do begin
    resop_inc[i]:=false;
    resop_wgt[i]:=1.0;
    for k:=0 to nford do resop_cof[i,k]:=0.0;
    // create an inverse index, to find the plotmode to each result1
//    for k:=0 to nPlotMode-1 do if ires1[k]=i then iplot1[i]:=k;
    for k:=nPlotMode-1 downto 0 do if ires1[k]=i then iplot1[i]:=k;
  end;
  GetKnobs; // set nknob
  Plot_Difference:=false;
  for i:=0 to nPlotMode-1 do begin
    plot_ymin[i]:=0.0; plot_ymax[i]:=0.0;
  end;
  MomFitDefaults (false); // read defaults for fit params
  MomResize;
  Powellstatus:=0;
//  FullCalc; // no calc at start, want to set params first
  opaLog(0,'momentum calculation: start done');
end;
//---------------------- resize --------------------------

procedure Tmomentum.MomResize;
const
  d=10;  df=2;
  colpanw=240;
  colrgw=110;
  colpancheck=25;
var
  xpos, dy, xwid, i, ypos, dx, yhgt, yhgtl, hpan, dox, doy: integer;
  rbpm: TRadioButton;
  cbpm: TCheckBox;
begin
  if clientwidth<550 then clientwidth:=550;
  if clientheight<400 then clientheight:=400;
  xwid:=clientwidth-2*d;
  yhgt:=clientheight-2*d;
  yhgtl:=yhgt-d;
  rgshow.setbounds(d,d, colrgw, yhgtl);
  pancheck.setbounds(colrgw +d,d, colpancheck, yhgtl);
  dy:=(yhgtl-d) div nPlotMode;
  for i:=0 to nPlotMode-1 do begin
    rbpm :=TRadioButton (FindComponent( 'rbpm_'+IntToStr(i)));
    if rbpm <> nil then rbpm.SetBounds(d,i*dy+d ,colrgw-4*d, dy-d);
    if ires2[i]=-1 then begin
      cbpm :=TCheckBox (FindComponent( 'cbpm_'+IntToStr(i)));
      if cbpm <> nil then cbpm.SetBounds(df ,i*dy+d ,d, dy-d);
    end;
  end;

  xpos:=clientwidth-d-colpanw;
  ypos:=d;
  dy:=pango.Height;
  pango.setbounds(xpos,d,colpanw,dy);
  ypos:=ypos+dy+d;
  dy:=panctrl.Height;
  ypos:=yhgt-dy;
  panctrl.setbounds(xpos,ypos, colpanw, dy);
  ypos:=pango.top+pango.height+d;
  dy:=panctrl.top-ypos-d;
  panfit.setbounds(xpos,ypos,colpanw, dy);
  gfit.height:=dy-d-gfit.top;
  dx:=xwid-2*d-colpanw-colrgw-colpancheck;
  xpos:=2*d+colrgw+colpancheck;
  dy:=round(0.6*yhgt);
  fig.setsize(xpos,d, dx, dy);
  hpan:=yhgt-dy-d;
  panmin.setbounds(xpos, 2*d+dy, dx, hpan);
  dox := dx div 6-df;
  doy := hpan div (op_nmax+2) -df;
  if doy > 16 then doy:=16;
  labName.setBounds  (  df      ,  df,dox,doy);
  labWeight.setBounds(2*df+  dox,  df,dox,doy);
  labPenCo.setBounds (3*df+2*dox,  df,dox,doy);
  labInc.setBounds   (4*df+3*dox,  df,dox-df,doy);
  labKno.setBounds   (4*df+4*dox,  df,dox,doy);
  labBnL.setBounds   (5*df+5*dox,  df,dox,doy);
  for i:=0 to op_nmax-1 do begin
    ypos:=(i+1)*(doy+df);
    op_ButNam[i].setBounds(  df      ,ypos+df, dox, doy);
    op_EdtWgt[i].setBounds(2*df+  dox,ypos   , dox, doy);
    op_LabPen[i].setBounds(3*df+2*dox,ypos+df, dox, doy);
  end;
  ypos:=(op_nmax+1)*(doy+df);
  LabPentot.setBounds(3*df+2*dox, ypos+df, dox, doy);
  ButReset.setBounds(2*df+dox, ypos+df, dox, doy);
  ButOp.setBounds(df,ypos+df,dox,doy);
  inc(ypos,doy+df);
  Butpdiff.setBounds(df,ypos+df,2*dox+df,doy);
  if nknob > 0 then begin
    doy:=hpan div (nknob)-df;
    if doy > 16 then doy:=16;
    for i:=0 to nknob-1 do begin //nknob-1 correct?
      ypos:=(i+1)*(doy+df);
      kn_CbxNam[i].setBounds(4*df+3*dox,ypos+df, dox-df, doy);
      kn_EdtVar[i].setBounds(4*df+4*dox,ypos   , dox, doy);
      kn_LabVal[i].setBounds(5*df+5*dox,ypos+df, dox, doy);
    end;
  end;
  Show;
  fig.plot.Clear(clWhite);
end;

//-------------------- Event handlers  -----------------------

// - - - for the form - - -

procedure Tmomentum.FormResize(Sender: TObject);
begin
  MomResize;
end;

procedure Tmomentum.FormPaint(Sender: TObject);
begin
  gfitSetMode;
  MakePlot (false);
end;

procedure Tmomentum.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: integer;
  cbpm: TCheckBox;
begin
  for i:=0 to nPlotMode-1 do begin
    cbpm :=TCheckBox (FindComponent( 'cbpm_'+IntToStr(i)));
    if cbpm<>nil then cbpm.Checked:=False;
  end;
  for i:=0 to op_nmax-1 do begin
    with op_ButNam[i] do begin Tag:=-1; Caption:=' - - '; Enabled:=False; end;
    with op_Edtwgt[i] do begin Tag:=-1; Text:='1.0'; Enabled:=False; end;
  end;
  dp:=nil; result:=nil; resop_targ:=nil;
  tuneplot_HANDLE.close;
end;

// - - -  for buttons - - -


procedure Tmomentum.butexClick(Sender: TObject);
var
  mr:word;
begin
// check for changes of elements
  mr:=EllaSave;
  if mr <> mrCancel then begin
// save the defaults
    Defset('tshift/steps',Nsteps);
    Defset('tshift/range',Range);
    DefSet('tshift/lef',Left);
    DefSet('tshift/top',Top);
    DefSet('tshift/wid',clientWidth);
    DefSet('tshift/hei',clientHeight);
    DefSet('tshift/nford',Nford);
    DefSet('tshift/pmode',PlotMode);
    DefSet('tshift/tmode',funitstat);
    MomFitDefaults(true);
    Close;
  end;
end;

procedure Tmomentum.ButgoClick(Sender: TObject);
begin
  CalcTarg;
  FullCalc;
end;

procedure Tmomentum.butfitClick(Sender: TObject);
begin
  CalcTarg; CalcPenalty; ShowPenalty;
  gfitSetMode;
  MakePlot(false);
end;

// run-time assigned handler for optimizer name buttons
procedure Tmomentum.ButNamClick (Sender:TObject);
var
  but: TButton;
  rbpm: TRadiobutton;
begin
  but:=Sender as TButton;
  Plotmode:=iplot1[but.Tag]; //Plotmode is overwritten with same value by rbclick called on rbpm.checked
  rbpm :=TRadioButton (FindComponent( 'rbpm_'+IntToStr(PlotMode)));
  if rbpm <> nil then rbpm.Checked:=True;
end;

// change units
procedure Tmomentum.butfunitClick(Sender: TObject);
begin
  funitstat:=1-funitstat;
  labfunit.caption:=labfunitText[funitstat];
  gfitSetMode;
  MakePlot(false);
end;

// export the plot as eps
procedure Tmomentum.butpsClick(Sender: TObject);
var
  errmsg, epsfile: string;
begin
  epsfile:=ExtractFileName(FileName);
  epsfile:=work_dir+Copy(epsfile,0,Pos('.',epsfile)-1);
  epsfile:=epsfile+'_momentum_'+inttostr(plotmode)+'.eps';
  fig.plot.PS_start(epsfile,OPAversion, errmsg);
  if length(errmsg)>0 then begin
    MessageDlg('PS export failed: '+errmsg, MtError, [mbOK],0);
  end else begin
    MakePlot(false);
    fig.plot.PS_stop;
    MessageDlg('Graphics exported to '+epsfile, MtInformation, [mbOK],0);
    MakePlot(false);
  end;
end;

// export the data as text
procedure Tmomentum.buttxtClick(Sender: TObject);
const
  sep: string[3]=' ';
var
  mfname: string;
  outfi: textfile;
  i, ir1, ir2:integer;

  function gridline(g:TStringGrid; i:integer): string;
  var
    tmpline:string;  k:integer;
  begin
    tmpline:='';
    with g do begin
      for k:=0 to Colcount-2 do tmpline:=tmpline+cells[k,i]+sep;
      gridline:=tmpline+cells[colcount-1,i];
    end;
  end;

begin
//write plotted data to file
  mfname:=ExtractFileName(FileName);
  mfname:=work_dir+Copy(mfname,0,Pos('.',mfname)-1);
  mfname:=mfname+'_momentum_'+inttostr(plotmode)+'.txt';
  assignFile(outfi,mfname);
{$I-}
  rewrite(outfi);
{$I+}
  if IOResult =0 then begin
    writeln(outfi, '#  '+'dp [%]'+sep+plot_cap[plotmode]+sep+plot_unit[plotmode]);
    ir1:=ires1[plotmode]; ir2:=ires2[plotmode];
    for i:=0 to npoints-1 do begin
      write(outfi, ftos(dp[i],10,3));
      if valid[i] then write(outfi, sep+ftos(result[i,ir1],12, resformd[ir1])) else write(outfi,sep+'        ');
      if ir2 <>-1 then
        if valid[i] then write(outfi, sep+ftos(result[i,ir2],12, resformd[ir2])) else write(outfi,sep+'        ');
      writeln(outfi);
    end;
    writeln(outfi, '# -----------------------------------------------------');
    writeln(outfi, '# Fit coefficients in units '+labfunittext[funitstat]);
    writeln(outfi, '# '+gridline(gfit,0));
    for i:=1 to gfit.RowCount-1 do begin
      writeln(outfi, gridline(gfit,i));
    end;
    writeln(outfi, '# -----------------------------------------------------');
    CloseFile(outfi);
    MessageDlg('Data saved to text file '+mfname, MtInformation, [mbOK],0);
  end else begin
    OPALog(1,'could not write '+mfname);
  end;
end;


// - - - for stringgrids - - -

procedure Tmomentum.gfitKeyPress(Sender: TObject; var Key: Char);
begin
  if key=',' then key:='.';
  if key=#13 then key:=#0;  {beep suppression}
  if key=#0 then gfitcell;
end;

// - - - for radio buttons - - -

procedure Tmomentum.rbClick(Sender: TObject);
var
  rb: TRadioButton;
begin
  rb:=Sender as TRadioButton;
  plotmode:=rb.Tag;
  gfitSetMode;
  MakePlot(false);
end;

// - - - for check boxes - - -

procedure Tmomentum.chkperClick(Sender: TObject);
begin
  Want_periodic:=chkPer.Checked;
end;

// run time assigned handler for check boxes to include result in optimizer
procedure Tmomentum.cbCheck(Sender:TObject);
var
  cb, cbu: TCheckBox;
  i,idel: integer;
begin
  cb:=Sender as TCheckBox;

  if cb.Checked then begin // select a new term, shift all others up
// if the last one will fall off, we have to search the corresponding checkbox
// and uncheck it, this will call THIS procedure again!
    if Op_butNam[op_nmax-1].Tag <>-1 then begin
      for i:=0 to nPlotmode-1 do begin
        cbu:=TCheckBox (FindComponent( 'cbpm_'+IntToStr(i)));
        if cbu <> nil then if cbu.Checked then if ires1[cbu.Tag]=Op_butNam[op_nmax-1].Tag then cbu.Checked:=False
      end;
    end;
    for i:=op_nmax-1 downto 1 do  Op_butNam[i].Tag:=Op_butNam[i-1].Tag;
    Op_butNam[0].Tag:=ires1[cb.Tag];
    resop_Inc[ires1[cb.Tag]]:=True;

  end else begin // remove a term, shift all others down
    for i:=0 to op_nmax-1 do if Op_butNam[i].Tag=ires1[cb.Tag] then idel:=i;
    for i:=idel+1 to op_nmax-1 do Op_butNam[i-1].Tag:=Op_butNam[i].Tag;
    Op_butNam[op_nmax-1].Tag:=-1;
    resop_Inc[ires1[cb.Tag]]:=False;
  end;

  for i:=0 to op_nmax-1 do begin
    with Op_butNam[i] do begin
      if Tag=-1 then begin
        Caption:=' - - ';
        Enabled:=False;
        Op_EdtWgt[i].Tag:=-1;
        Op_EdtWgt[i].Enabled:=False;
      end else begin
        Caption:= res_cap[Tag];
        Enabled:=True;
        Op_EdtWgt[i].Tag:=Tag;
        Op_EdtWgt[i].Enabled:=True;
        Op_EdtWgt[i].text:=Ftos(resop_wgt[Tag],-2,2);
      end;
    end;
  end;
  CalcTarg; CalcPenalty; ShowPenalty;
  if PlotMode = cb.Tag then begin
     gfitSetMode;
     MakePlot(false);
  end;
end;

// - - - for edit fields - - -

procedure Tmomentum.EdStepsKeyPress(Sender: TObject; var Key: Char);
var   kv: real;
begin
  if TEKeyVal(EdSteps, Key, kv, 3, 0) then if(Key=#0 ) then begin
    NSteps:=Round(kv);
    SetArrayLength;
  end;
end;

procedure Tmomentum.EdStepsExit(Sender: TObject);
var   kv: real;
begin
  if TEReadVal(EdSteps, kv, 3, 0) then begin
    NSteps:=Round(kv);
    SetArrayLength;
  end;
end;

procedure Tmomentum.EdRangeKeyPress(Sender: TObject; var Key: Char);
var   kv: real;
begin
  if TEKeyVal(EdRange, Key, kv, 5, 2) then if(Key=#0 ) then Range:=kv;
end;

procedure Tmomentum.EdRangeExit(Sender: TObject);
var   kv: real;
begin
  if TEReadVal(EdRange, kv, 5, 2) then Range:=kv;
end;

procedure Tmomentum.EdnfordKeyPress(Sender: TObject; var Key: Char);
var   kv: real;
begin
  if TEKeyVal(EdNford, Key, kv, 2, 0) then if(Key=#0 ) then nford:=Round(kv);
  if nford > nMomFit_order then begin nford:=nMomFit_order; EdNford.Text:=Inttostr(nford); end;
end;

procedure Tmomentum.EdnfordExit(Sender: TObject);
var   kv: real;
begin
  if TEReadVal(EdNford, kv, 2, 0) then Nford:=round(kv);
  if nford > nMomFit_order then begin nford:=nMomFit_order; EdNford.Text:=Inttostr(nford); end;
end;

// run time assigned handler for weight edit fields
procedure Tmomentum.EdwgtExit(Sender: TObject);
var
  kv: real;
  ed: TEdit;
begin
  ed:= Sender as TEdit;
  if TEReadVal(ed, kv, -2, 2) then begin
    resop_wgt[ed.Tag]:=kv;
    CalcPenalty; ShowPenalty;
  end;
end;

procedure Tmomentum.EdwgtKeyPress(Sender: TObject; var Key: Char);
var
  kv: real;
  ed: TEdit;
begin
  ed:= Sender as TEdit;
  if TEKeyVal(ed, Key, kv, -2, 2) then if(Key=#0 ) then begin
    resop_wgt[ed.Tag]:=kv;
    CalcPenalty; ShowPenalty;
  end;
end;

// run time assigned handler for knob variable fields
procedure Tmomentum.EdvarExit(Sender: TObject);
var
  kv: real;
  ed: TEdit;
begin
  ed:= Sender as TEdit;
  if TEReadVal(ed, kv, 7, 3) then begin
    Recalculate(ed.tag, kv);
  end;
end;

procedure Tmomentum.EdvarKeyPress(Sender: TObject; var Key: Char);
var
  kv: real;
  ed: TEdit;
begin
  ed:= Sender as TEdit;
  if TEKeyVal(ed, Key, kv, 7, 3) then if(Key=#0 ) then begin
    Recalculate(ed.tag, kv);
  end;
end;


//-------------- set variables and components ----------------

procedure TMomentum.MomFitDefaults (rw:boolean);
{read (false) or write (true) the defaults for fit target values, at least
for some most used parameters stored in globlib:MomFit_param.
Also read/write the weighting factors of the minimizer}
var
  i, j, ir1, k: integer;
  defnam: string;
begin
  for i:=0 to nPlotMode-1 do if ires2[i]=-1 then begin
    ir1:=ires1[i];
    for j:=1 to nMomFit_param do begin
      if UB(MomFit_param[j])=UB(res_cap[ir1]) then begin
        for k:=1 to nMomFit_order do begin
          defnam:= 'tmom/'+MomFit_param[j]+inttostr(k);
          if rw then DefSet(defnam, resop_cof[ir1,k]) else resop_cof[ir1,k]:=FDefGet(defnam);
        end;
      end;
    end;
  end;
end;


// create and set the arrays for results and targets
procedure Tmomentum.SetArrayLength;
var
  np:integer;
begin
  dp:=nil; result:=nil; resop_targ:=nil;
  np:=Nsteps div 2; if np<1 then np:=1;
  npoints:=2*np+1;
  setlength(result,npoints);  setlength(dp, npoints);  setlength(valid, npoints);
  setlength(resop_targ,npoints);
end;


// set mode of the gfit grid to change between target-edit and show-1or2 mode
procedure Tmomentum.gfitsetmode;
var
  flag: boolean; i: integer;
begin
{set the mode of gfit to editable if the result for the current Plotmode has been
 included in the optimizer, i.e. ires1 agrees with the Tag of one name button.
 Else, set to not editable and adjust rows and cols depending if 1 or 2 results.
}
  with gfit do begin
    gfit.ColWidths[0]:=32;
    gfit.cells[1,0]:=res_cap[ires1[PlotMode]];
    RowCount:=nford+2;
    for i:=0 to nford do gfit.cells[0,i+1]:='A'+inttostr(i);
    flag:=false;
    for i:=0 to op_nmax-1 do flag:=flag or (op_ButNam[i].Tag=ires1[PlotMode]);
    if flag then begin
      ColCount:=3;
      FixedRows:=2;
      FixedCols:=2;
      Options:=Options+[goEditing];
      gfit.cells[2,0]:='Target';
    end else begin
      if ires2[Plotmode]=-1 then ColCount:=2 else ColCount:=3;
      FixedRows:=1;
      FixedCols:=1;
      Options:=Options-[goEditing];
      if ires2[Plotmode]>=0 then gfit.cells[2,0]:=res_cap[ires2[PlotMode]]; //!
    end;
  end;
end;

// extract values from the gfit table, read coefficient if possible and recalc targets
procedure Tmomentum.gfitcell;
var
  x: Real;
  s: String;
  errcode, ir, k:Integer;
begin
  with gfit do begin
    s:=Cells[2,Row];   //gfit.row is currently set row
{$R-}
    Val(s,x,errcode);
{$R+}
    ir:=ires1[PlotMode]; k:=Row-1;
    if errcode=0 then begin
      if funitstat=0 then resop_cof[ir,k]:=x
                     else resop_cof[ir,k]:=x*res_funit[ir]/PowI(100,k);
    end;
//    if funitstat=0 then Cells[2,Row]:=ftos(resop_cof[ir,k],-4,2)
//                   else Cells[2,Row]:=ftos(resop_cof[ir,k]/res_funit[ir]*PowI(100,k),-4,2);
    if funitstat=0 then Cells[2,Row]:=ftos(resop_cof[ir,k],-3,2)
                   else Cells[2,Row]:=ftos(resop_cof[ir,k]/res_funit[ir]*PowI(100,k),-3,2);
    CalcTarg; CalcPenalty; ShowPenalty;
    gfitSetMode;
    MakePlot(false);
  end;
end;


//===================================================================

procedure TMomentum.getknobs;
var
  j, i: integer;
begin
  nknob:=0;
  for j:=1 to Glob.Nella do begin
    if (Ella[j].cod in [csext,cmpol]) and (nknob < kn_nmax) then begin
       kn_jel[nknob]:=j;
       kn_val0[nknob]:=getkval(j,0);
       kn_var[nknob]:=1.0;
{exclude zero knobs since minimizer works on relative values
 this is a cheap solution to avoid minimizer run off, better:
 use absolute not relative strength; powell can handle knobs of different magnitudes.}
       if abs(kn_val0[nknob])>1e-8 then Inc(nknob);
    end;
  end;
  for i:=0 to nknob-1 do begin
    with kn_cbxnam[i] do begin Caption:=Ella[kn_jel[i]].nam; Visible:=True; end;
    with kn_labval[i] do begin Caption:=FtoS(kn_val0[i],-4,2); Visible:=True; end;
    with kn_edtvar[i] do begin
      Text:=Ftos(kn_var[i],7,3);
      Enabled:=True; Visible:=True;
      Tag:=i;
    end;
  end;
  for i:=nknob to kn_nmax-1 do begin
    kn_cbxnam[i].Visible:=False;
    kn_labval[i].Visible:=False;
    kn_edtvar[i].Visible:=False;
  end;
end;

procedure TMomentum.recalculate (itag: integer; relk: real);
var
  kval:real;
begin
  kn_var[itag]:=relk;
  kn_edtvar[itag].Text:=Ftos(relk,7,3);
  kval:=kn_val0[itag]*relk;
  kn_labval[itag].caption:=Ftos(kval,-4,2);
  putkval(kval, kn_jel[itag],0);
  FullCalc;
end;

procedure Tmomentum.ButResetClick(Sender: TObject);
var
  kval:real;
  i: integer;
begin
  for i:=0 to nknob-1 do begin
    kn_var[i]:=1.0;
    kval:=kn_val0[i];
    kn_labval[i].caption:=Ftos(kval,-4,2);
    kn_edtvar[i].text:='1.00';
    putkval(kval, kn_jel[i],0);
  end;
  FullCalc;
end;


function PenaltyFunction (Var p: PowellVector): real;
var
  j, jm: Integer;
begin
  Application.ProcessMessages;

  for j:=1 to Powellncom do begin
    jm:=iknpow[j-1];
    kn_var[jm]:=p[j];
    putkval(kn_val0[jm]*kn_var[jm],kn_jel[jm],0);

  end;

  CALCULATE;
  CalcPenalty;
  ShowPenalty;

  PenCur:=Penalty*PenNorm;

  if PenCur < PenOld then begin
    LabPentot_handle.Font.Color:=clGreen;
    PenOld := PenCur;
    MakePlot(true);
    PostCalc;
  end
  else begin
    LabPentot_handle.Font.Color:=clRed;
  end;
  PenaltyFunction:=PenCur;
  LabPentot_handle.Caption:=FtoS(PenCur, -3,2);
end;


procedure Tmomentum.ButOpClick(Sender: TObject);
var
  i: integer;
  PowK: PowellVector;
begin
  if (PowellStatus = 0) then begin
    CalcPenalty;
    PenSave:=Penalty;
    PenNorm:=1.0/(PenSave+1E-20);
    PenOld:=1.0;
    PowellLinMinStep:=0.501; //temp. fixed val, since knobs norm to 1

// allocate available knobs
    iknpow:=nil;
    for i:=0 to nknob-1 do begin
      if kn_CbxNam[i].Checked then begin
        setlength(iknpow, length(iknpow)+1);
        iknpow[High(iknpow)]:=i;
      end;
    end;
    Powellncom:=Length(iknpow);

  // compose vector from available knobs
//*    Powellncom:=nknob;
    for i:=0 to Powellncom-1 do begin
      PowK[i+1]:=kn_var[iknpow[i]];
    end;

    PowellBreak:=False;
    PowellStatus:=1;
    ButOp.Caption:='Break';
//--------------------------------------------------------------------
    POWELL (PowK, Powellncom, 0.001, PenaltyFunction);
//--------------------------------------------------------------------
    PowellStatus:=0;
    ButOp.Caption:='Start';

//bascially not necessary to transfer final values, have been passed by putkval anyway
    for i:=1 to Powellncom do begin
      kn_var[iknpow[i-1]]:=PowK[i];
    end;

    PenCur:=Penalty*PenNorm;

    if PowellBreak then LabPentot.Font.Color:=clFuchsia else LabPentot.Font.Color:=clBlue;
    LabPentot.Caption:=FtoS(PenCur, -3,2);
// scale to new results
    MakePlot(false);

  end else begin
    PowellBreak:=True;
  end;
end;


procedure Tmomentum.butpdiffClick(Sender: TObject);
begin
  Plot_Difference:=not Plot_Difference;
  with Butpdiff do if Plot_Difference then Caption:='Plot difference' else Caption:='Plot absolute';
  MakePlot(false);
end;

end.
