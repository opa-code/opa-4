unit momentumlib;

//{$MODE Delphi}
interface

uses
  Graphics, Controls, globlib, ASaux, linoplib, ASfigure, opatunediag, StdCtrls, Grids, ExtCtrls, mathlib;

const
//  nfordmax=12; --> is now global constant to enable fit coefficients
  op_nmax=5;
  kn_nmax=32; // should be dynamic...
  ncl=100;
  nPlotMode=20;
  nResult=22;
  plot_cap: array[0..nPlotmode-1] of string[8]=
    ('dQX,dQY','QX,QY','QX','QY',
     'BetaX','BetaY','BetaX,Y','AlphaX','AlphaY','AlphaX,Y',
     'Disp.','Disp.''','X,Y','X'',Y''','AmpX',
     'JX,JY','EmittX,Y','Uloss','Espread','Dpath');
  plot_unit: array[0..nPlotmode-1] of string[9]=
    ('','','','',
     ' [m]',' [m]',' [m]',' [rad]',' [rad]',' [rad]',
     ' [m]',' [rad]',' [mm]',' [mrad]','[nm rad]',
     '',' [nm rad]',' [keV]',' [o/oo]',' [mm]');
  ires1: array[0..nPlotMode-1] of integer =
    ( 15, 0, 0, 1,  2, 3, 2, 4, 5, 4,  6, 7, 8, 9, 17, 10, 11, 12, 13, 14);
  ires2: array[0..nPlotMode-1] of integer =
    ( 16, 1,-1,-1, -1,-1, 3,-1,-1, 5, -1,-1,18,19, -1, 20, 21, -1, -1, -1);
  rescol: array[0..nresult-1] of TColor=
    (clBlue,clRed,   clBlue,clRed,clBlue, clRed,
     clGreen, clGreen,   clBlue,clBlue,
     clBlue,clBlue,clPurple,clPurple, clTeal,
     clBlue, clRed, clBlue, clRed, clRed, clRed, clRed);
  resformd: array[0..nresult-1] of integer =
    (4,4,3,3,4,4,4,4,4,4,6,3,2,3,4,6,6,3,4,4,6,3);
  res_cap: array[0..nresult-1] of string[8]=
    ('QX','QY', 'BetaX','BetaY','AlphaX','AlphaY','Disp.','Disp.''','X','X''',
     'JX','EmittX','Uloss','Espread','Dpath','dQX', 'dQY','AmpX','Y','Y''','JY','EmittY');
  res_funit: array[0..nresult-1] of real =
     (1,1,1,1,1,1,1,1,1000,1000,1,1e9,1e-3,1e3,1000,1,1,1e9,1000,1000,1,1e9);
  labfunitText: array[0..1] of string[24]=(' like plot [%,mm,..]',' S.I.[m,rad,eV]');

type
  result_type = array[0..nresult-1] of real;
   // 0   1   2   3    4   5  6  7   8  9  10    11    12     13     14  15  16   17   18  19  20  21
  // qx, qy, bx, by, ax, ay, d, dp, x, x', jx, emitx, uloss, sige, path  dqx  dqy  Ax  y   y'  Jb, emity



var

  tuneplot_HANDLE: TtunePlot;
  gfit_HANDLE: TStringGrid;
  ButFit_HANDLE: TButton;
  ChkPer_HANDLE: TCheckBox;
  fig_HANDLE: TFigure;
  Labpentot_HANDLE: TLabel;

  Want_periodic: boolean;
  NSteps, npoints, plotmode, nford: integer;
  dp: array of real;
  valid: array of boolean;
  qx0, qy0: double;
  bx0, ax0: real;
  LinDisp, ZeroOrbit: Vektor_4;
  latmode: integer;
  funitstat: integer;
  nknob: integer;
  Range: real;

  dpr, qxcl, qycl, resf1, resf2: array[-ncl..ncl] of real;
  result, resop_targ: array of result_type;
  op_butnam: array[0..op_nmax-1] of TButton;
  op_edtwgt: array[0..op_nmax-1] of TEdit;
  op_labpen: array[0..op_nmax-1] of TLabel;
  resop_wgt: array[0..nresult-1] of real;
  resop_pen: array[0..nresult-1] of real;
  resop_inc: array[0..nresult-1] of boolean;
  resop_cof: array[0..nresult-1,0..nMomFit_order] of real;
  kn_cbxnam: array[0..kn_nmax-1] of TCheckBox;
  kn_labval: array[0..kn_nmax-1] of TLabel;
  kn_edtvar: array[0..kn_nmax-1] of TEdit;
  kn_jel: array[0..kn_nmax-1] of integer;
  kn_val0, kn_var: array[0..kn_nmax-1] of real;
  iplot1:    array[0..nresult-1] of integer;
  plot_ymin, plot_ymax: array[0..nPlotMode-1] of real;
  Penalty, PenSave, PenOld, PenCur, PenNorm: real;
  iknpow: array of integer;
  Plot_Difference: boolean;

  procedure ShowPenalty;
  procedure MakePlot (NoRescale: boolean);
  procedure Calculate;
  procedure PostCalc;
  procedure FullCalc;
  procedure CalcPenalty;
  procedure CalcTarg;

implementation

procedure Makeplot (NoRescale:boolean);
var
  i, ir1, ir2: integer;
  ymin, ymax: real;
  dat, dpv, aco, sub: array of real;
  fit: array[-ncl..ncl] of real;

  procedure Plot_qcLines;
  var
    i: integer;
    qxoff, qyoff: real;
  begin
    if status.chromas and (plotmode <=3) then begin
      qxoff:=0; qyoff:=0;
      if plotmode=0 then begin qxoff:=qx0; qyoff:=qy0; end;
      with fig_HANDLE.plot do begin
        setcolor(clBlue);
        if plotmode in [0,1,2] then begin
          setcolor(clblue);
          moveto(dpr[-ncl], qxcl[-ncl]-qxoff);
          for i:=-ncl+1 to ncl do lineto(dpr[i], qxcl[i]-qxoff); stroke;
        end;
        if plotmode in [0,1,3] then begin
          setcolor(clred);
          moveto(dpr[-ncl], qycl[-ncl]-qyoff);
          for i:=-ncl+1 to ncl do lineto(dpr[i], qycl[i]-qyoff); stroke;
        end;
      end; //with
    end; //status
  end;

  procedure plot_target (ir, icol:integer);
  var
    k, i: integer;
    val: real;
  begin
    if not Plot_Difference then with fig_HANDLE.plot do begin
      SetSymbol (2, 1, clFuchsia);
      for i:=0 to npoints-1 do symbol(dp[i],resop_targ[i,ir]);
    end;
    for k:=0 to nford do begin
       // scaling to plot or SI units
      if funitstat=0 then val:=resop_cof[ir,k] else val:=resop_cof[ir,k]/res_funit[ir]*PowI(100.0,k);
//      gfit_HANDLE.cells[icol,k+1]:=ftos(val,-4,2);
      gfit_HANDLE.cells[icol,k+1]:=ftos(val,-3,2);
    end;
  end;


  procedure fit_and_plot (ir, icol:integer);
  var
    k, km, kv, i: integer;
    val: real;
  begin
    if ir<>-1 then begin

      kv:=0;
      for k:=0 to npoints-1 do if valid[k] then begin
        dat[kv]:=result[k,ir]-sub[k];
        inc(kv);
      end;
      Poly_fit(dpv, dat, nford, aco);
      for i:=-ncl to ncl do begin
        fit[i]:=aco[nford];
        for k:=nford-1 downto 0 do fit[i]:=fit[i]*dpr[i]+aco[k];
      end;
      with fig_HANDLE.plot do begin
        setcolor(clLime);
        moveto(dpr[-ncl], fit[-ncl]);
        for i:=-ncl+1 to ncl do lineto(dpr[i], fit[i]);  stroke;
      end;
      gfit_HANDLE.cells[icol,0]:=res_cap[ir];
      for k:=0 to nford do begin
        // scaling to plot or SI units
        if funitstat=0 then val:=aco[k] else val:=aco[k]/res_funit[ir]*PowI(100.0,k);
//        gfit_HANDLE.cells[icol,k+1]:=ftos(val,-4,2);
        gfit_HANDLE.cells[icol,k+1]:=ftos(val,-3,2);
      end;
      if PlotMode=19 then if icol=1 then begin
        if nford>5 then km:=5 else km:=nford;
        with snapsave do for k:=1 to km do alfaC[k-1]:=aco[k]/res_funit[ir]*PowI(100.0,k);
        status.alphas:=true;
        setStatusLabel(stlab_alf,status_flag);
      end;
    end;
  end;

begin
  if npoints>1 then begin
    dpv:=nil; dat:=nil;
    for i:=0 to npoints-1 do if valid[i] then begin
      setlength(dpv,length(dpv)+1);
      dpv[high(dpv)]:=dp[i];
    end;
    setlength(dat,length(dpv));
    setlength(sub,npoints);
    setlength(aco,nford+1);
// make plot
    fig_HANDLE.plot.setColor(clBlack);
    ir1:=ires1[plotmode];
    ir2:=ires2[plotmode];

// subtraction of target values for plot:
    if Plot_Difference and resop_inc[ir1] then begin
      for i:=0 to npoints-1 do sub[i]:=resop_targ[i,ir1];
    end else begin
      for i:=0 to npoints-1 do sub[i]:=0;
    end;

    if NoRescale and (abs(plot_ymin[PlotMode]-plot_ymax[PlotMode])>1e-12) then begin
      ymin:=plot_ymin[PlotMode]; ymax:=plot_ymax[PlotMode];
    end else begin
      ymin:=1e10; ymax:=-1e10;
      for i:=0 to npoints-1 do begin
        if valid[i] then begin
          if result[i,ir1]-sub[i] > ymax then ymax:=result[i,ir1]-sub[i];
          if result[i,ir1]-sub[i] < ymin then ymin:=result[i,ir1]-sub[i];
        end;
        if not Plot_Difference and resop_inc[ir1] then begin
          if resop_targ[i,ir1] > ymax then ymax:=resop_targ[i,ir1];
          if resop_targ[i,ir1] < ymin then ymin:=resop_targ[i,ir1];
        end;
      end;
      if ir2 <> -1 then for i:=0 to npoints-1 do begin
        if valid[i] then begin
          if result[i,ir2] > ymax then ymax:=result[i,ir2];
          if result[i,ir2] < ymin then ymin:=result[i,ir2];
        end;
      end;
      plot_ymin[PlotMode]:=ymin; plot_ymax[PlotMode]:=ymax;
    end;
    fig_HANDLE.Init(-Range, ymin, Range, ymax, 1, 1, 'dp/p [%]',plot_cap[plotmode]+plot_unit[plotmode], 3,false);
    if not Plot_Difference then Plot_qcLines;
    fig_HANDLE.plot.SetSymbol (2, 1, rescol[ir1]);

    for i:=0 to npoints-1 do if valid[i] then begin
      fig_HANDLE.plot.symbol(dp[i],result[i,ir1]-sub[i]);
    end;
    if ir2 <>-1 then begin
      fig_HANDLE.plot.SetSymbol (2, 1, rescol[ir2]);
      for i:=0 to npoints-1 do if valid[i] then fig_HANDLE.plot.symbol(dp[i],result[i,ir2]);
    end;

    fig_HANDLE.plot.setColor(clBlack);
    fit_and_plot(ir1,1);
    if ir2<>-1 then fit_and_plot(ir2,2);
    if resop_inc[ir1] then plot_target(ir1,2);
    dpv:=nil; dat:=nil; aco:=nil; sub:=nil;
  end;
end;

// show penalty values
procedure ShowPenalty;
var
  i: integer;
begin
  for i:=0 to op_nmax-1 do with op_butnam[i] do if Tag <> -1 then begin
    op_labpen[i].Caption:=FtoS(resop_pen[Tag],-2,2);
  end;
  Labpentot_HANDLE.Caption:=Ftos(Penalty,-3,2);
  for i:=0 to nknob-1 do begin
    kn_labval[i].Caption:=FtoS(getkval(kn_jel[i],0),-4,2);
    kn_edtvar[i].Text:=Ftos(kn_var[i],7,3);
  end;
end;


// -------------- Physics procedures ------------------------------

procedure PreCalc;
// prepare for calculations
var
  i, n: integer;
  nelem: word;
  noper: boolean;
  dpp: real;
begin
  for i:=-ncl to ncl do dpr[i]:=Range/ncl*i;
  Glob.dpp:=0;
//  UseSext:=False;
  UseSext:=True;
  if Want_periodic then begin
    ClosedOrbit(noper, do_twiss, 0.0);
    if noper then setStatusLabel(stlab_orb,status_failure) else setStatusLabel(stlab_orb,status_success);
  end else setStatusLabel(stlab_orb,status_forward);
  OptInit;
  for n:=1 to Glob.NLatt do Lattel (n, nelem, do_twiss, 0.0);
{check for periodic solution: if it does not exist, even for dp=0, we uncheck ChkPer.
 this will also set Want_periodic to false.}
  if Want_periodic then begin
    Periodic(noper);
    if noper then ChkPer_HANDLE.Checked:=False;
    if noper then setStatusLabel(stlab_per,status_failure) else setStatusLabel(stlab_per,status_success);
  end else setStatusLabel(stlab_per,status_forward);
{save on-momentum tunes and betas}
  qx0:=beam.Qa*Glob.NPer; qy0:=beam.Qb*Glob.NPer;
  bx0:=Glob.Op0.beta; ax0:=-Glob.Op0.alfa; {???? negative?}
  if status.Periodic then begin
{if a periodic solution exists, then show the tune diagram and draw the chromatic
 footprint if it had been calculated previously}
    TunePlot_HANDLE.Diagram(qx0,qy0);
    if status.chromas then with snapsave do begin
      TunePlot_HANDLE.AddChromLine(chromx, chromy, cx2, cy2, cx3, cy3, Range*0.01);
      for i:=-ncl to ncl do begin
        dpp:=dpr[i]*0.01;
        qxcl[i]:=qx0+dpp*(chromx+dpp*(cx2+dpp*cx3));
        qycl[i]:=qy0+dpp*(chromy+dpp*(cy2+dpp*cy3));
      end;
    end;
  end else tuneplot_HANDLE.Close;
{keep the dispersion to start the orbit for dp<>0, since glob.eta0 will be overwritten
by the off-momentum periodic solutions}
  LinDisp:=OpToDisp(Glob.Op0); ZeroOrbit:=OpToOrb(Glob.Op0);
  latmode:=do_twiss+do_chrom+do_radin+do_lpath;
end;


procedure Calculate;
{do the tracking: calculate single pass or periodic solutions and store the results
 requires that PreCalc has been called before to set the dp=0 solution etc.}
var
  orbfail, noper: boolean;
  np, i, jm0p, ja ,k: integer;
  dpp: real;
//  nelem: Word;
  qx, qy: double;
begin
  np:=Npoints div 2;
  noper:=true;

  for jm0p:=-1 to 1  do begin // -1, 0, 1
    for i:=abs(jm0p) to np*abs(jm0p) do begin // 1..np, 0..0, 1..np
      ja:=np+jm0p*i;   //  np-1..0,  np,   np+1..2*np
      dpp:=jm0p*i*Range/np/100.0;  // ( -1..-np,  0  , 1..np)*range/np/100
      dp[ja]:=dpp*100.0;
      Glob.dpp:=dpp;
      OptInit;
      UseSext:=True;

      if Want_periodic then begin
{
 if we want to find periodic solutions,
 increasing |dp|, the best initial value for the orbit finder is the previous solution
 for a slightly smaller |dp|, which is saved in glob.eta0 and set by OptInit.
 However, if the previous orbit search failed, the best we can do is to set the
 orbit to what we expect from the linear dispersion LinDisp, we saved:
 (i.e. noper is a local flag to tell the success of the previous search!)
}
//if noper then opamessage(0,' previous -> noper') else opamessage(0,'previous -> periodic');
        if noper then for k:=1 to 4 do Glob.Op0.orb[k]:=LinDisp[k]*dpp+ZeroOrbit[k];
        ClosedOrbit(orbfail, 0, dpp);

//if orbfail then opamessage(0, '  dpp = '+ftos(dp[ja],10,2)+' orb failed ') else
//                opamessage(0, '  dpp = '+ftos(dp[ja],10,2)+' orb OK ');
        if orbfail then begin
          valid[ja]:=false;
        end else begin
          Periodic(noper);
          valid[ja]:=status.periodic;
//          if noper then opamessage(0,'                no per***') else opamessage(0, '                  periodic ok');
        end;
      end else begin
{
in single pass, we assume matched initial conditions, i.e. the orbit starts at
x = eta.dp, so set it to LinDisp, which is equal to glob.eta0
}
        for k:=1 to 4 do Glob.Op0.orb[k]:=LinDisp[k]*dpp+ZeroOrbit[k];
        valid[ja]:=true;
      end;
      if valid[ja] then begin
        OptInit; UseSext:=True;
//write(diagfil, 'dpp =',dpp:14:9);
        AllocOpval;  MomMode:=False; ncurves:=0;
        LINOP(0,0,latmode,dpp);
        qx:=Beam.Qa; qy:=Beam.Qb;
        result[ja, 0]:=qx;
        result[ja, 1]:=qy;
        result[ja, 2]:=Glob.OpE.beta;
        result[ja, 3]:=Glob.OpE.betb;
        result[ja, 4]:=Glob.OpE.alfa;
        result[ja, 5]:=Glob.OpE.alfb;
        result[ja, 6]:=Glob.OpE.disx;
        result[ja, 7]:=Glob.OpE.dipx;
        result[ja, 8]:=Glob.OpE.orb[1];
        result[ja, 9]:=Glob.OpE.orb[2];
        result[ja,18]:=Glob.OpE.orb[3];
        result[ja,19]:=Glob.OpE.orb[4];
        result[ja,10]:=Beam.Ja;
        result[ja,20]:=Beam.Jb;
        result[ja,11]:=Beam.Emita;
        result[ja,21]:=Beam.Emitb;
        result[ja,12]:=Beam.U0*1e3; //is internally in keV
        result[ja,13]:=Beam.sigmaE;
        result[ja,14]:=PathDiff;
        result[ja,15]:=qx-qx0;
        result[ja,16]:=qy-qy0;
        result[ja,17]:=bx0*sqr(Glob.OpE.orb[2])+2*ax0*Glob.OpE.orb[1]*Glob.OpE.orb[2]+(1+sqr(ax0))/bx0*sqr(Glob.OpE.orb[1]);
        for k:=0 to nresult-1 do resop_cof[k,0]:=result[np,k];
        for k:=0 to nresult-1 do result[ja,k]:=result[ja,k]*res_funit[k]; // scale to nice dimensions
      end;
    end;
  end;
// recalc the dp=0 solution to leave cleanly
  Glob.dpp:=0;
  UseSext:=True;
  if Want_periodic then ClosedOrbit(noper, do_twiss, 0.0);
  if Want_periodic then Periodic(noper);
  OptInit;
//  for n:=1 to Glob.NLatt do Lattel (n, nelem, do_twiss, 0.0); not enough, use LINOP to reset equil.vals too
  LINOP(0,0,latmode,0.0);  qx:=Beam.Qa; qy:=Beam.Qb;
end;

procedure PostCalc;
// after: free fit button, make a plot and show the points in the tune diagram if periodic was selected
var
  i: integer;
begin
  butfit_HANDLE.enabled:=true;
  if Want_periodic then begin
    TunePlot.Refresh;
    for i:=0 to npoints-1 do if valid[i] then
    TunePlot_HANDLE.AddTunePoint(result[i,0], result[i,1], dp[i]/100.0, Range/100.0, false);
    TunePlot_HANDLE.AddTunePoint(Beam.Qa, Beam.Qb, 0, Range/100.0, false);
  end;
end;

procedure FullCalc;
begin
  PreCalc;
  Calculate;
  MakePlot(false);
  PostCalc;
  CalcPenalty;
  ShowPenalty;
end;

// calculate the penalties, deviations of results from targets
procedure CalcPenalty;
var
  nval, i, k: integer;
  valfrac: real;
begin
  Penalty:=0.0;
  if npoints>0 then begin
// weight with 1/number of valid points, to not get better penalty if we loose particles!
    nval:=0;
    for k:=0 to npoints-1 do if valid[k] then Inc(nval);
    valfrac:=nval*1.0/npoints;
    for i:=0 to nresult-1 do if resop_Inc[i] then begin
      resop_pen[i]:=0.0;
      for k:=0 to npoints-1 do if valid[k] then begin
        resop_pen[i]:=resop_pen[i]+Sqr(resop_targ[k,i]-result[k,i]);
      end;
      resop_pen[i]:=resop_wgt[i]*resop_pen[i]/valfrac;
      Penalty:=Penalty+resop_pen[i];
    end;
  end;
end;

// calculate the result targets from the polynomial coefficients
procedure CalcTarg;
var
  i,j,k: integer;
begin
  if npoints>0 then begin
    for i:=0 to nresult-1 do begin
      if resop_Inc[i] then begin
        for k:=0 to npoints-1 do begin
          resop_targ[k,i]:=resop_cof[i,nford];
          for j:=nford-1 downto 0 do resop_targ[k,i]:=resop_targ[k,i]*dp[k]+resop_cof[i,j];
        end;
      end;
    end;
  end;
end;



end.
