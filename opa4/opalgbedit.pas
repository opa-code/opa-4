
unit opalgbedit;

{$MODE Delphi}

interface

uses
  lgbeditlib, Graphics, Controls, Sysutils, Forms, globlib, ASaux, ASfigure,
  StdCtrls, mathlib, Classes, Dialogs, ExtCtrls;


type

  { TLGBEdit }

  TLGBEdit = class(TForm)
    labang: TLabel;
    lablen: TLabel;
    labsli: TLabel;
    butsab: TButton;
    labnam: TLabel;
    labbetfoc: TLabel;
    labdislfo: TLabel;
    Edang: TEdit;
    Edlen: TEdit;
    Edsli: TEdit;
    Ednam: TEdit;
    Edbetmin: TEdit;
    Edbfimax: TEdit;
    Edpolwid: TEdit;
    Labbetfocres: TLabel;
    Labdislfores: TLabel;
    Labin5: TLabel;
    Labemi: TLabel;
    Labera: TLabel;
    labdpp: TLabel;
    Labin5res: TLabel;
    labemires: TLabel;
    Laberares: TLabel;
    Labdppres: TLabel;
    butemi: TButton;
    butsho: TButton;
    fig: TFigure;
    chkbetmin: TCheckBox;
    chkbfimax: TCheckBox;
    chkpolwid: TCheckBox;
    butrun: TButton;
    labbetfochom: TLabel;
    Labdislfohom: TLabel;
    labin5hom: TLabel;
    labemihom: TLabel;
    Laberahom: TLabel;
    Labdpphom: TLabel;
    butcre: TButton;
    ComboLGB: TComboBox;
    butdel: TButton;
    butovr: TButton;
    labcomtitle: TLabel;
    butex: TButton;
    labopstat: TLabel;
    buttxt: TButton;
    p: TPaintBox;
    procedure butsabClick(Sender: TObject);
    procedure butemiClick(Sender: TObject);
    procedure butshoClick(Sender: TObject);
    procedure EdangPress(Sender: TObject; var Key: Char);
    procedure EdangExit(Sender: TObject);
    procedure EdlenPress(Sender: TObject; var Key: Char);
    procedure EdlenExit(Sender: TObject);
    procedure EdsliPress(Sender: TObject; var Key: Char);
    procedure EdsliExit(Sender: TObject);
    procedure EdbetminPress(Sender: TObject; var Key: Char);
    procedure EdbetminExit(Sender: TObject);
    procedure EdbfimaxPress(Sender: TObject; var Key: Char);
    procedure EdbfimaxExit(Sender: TObject);
    procedure EdpolwidPress(Sender: TObject; var Key: Char);
    procedure EdpolwidExit(Sender: TObject);
    procedure chkbetminClick(Sender: TObject);
    procedure chkbfimaxClick(Sender: TObject);
    procedure chkpolwidClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure butrunClick(Sender: TObject);
    procedure butcreClick(Sender: TObject);
    procedure ComboLGBChange(Sender: TObject);
    procedure butdelClick(Sender: TObject);
    procedure butovrClick(Sender: TObject);
    procedure butexClick(Sender: TObject);
    procedure buttxtClick(Sender: TObject);


  private
    procedure CalcHom;
    procedure setbmax(kv:real);
    procedure ShowResults;
    procedure FindLGBs;
    procedure gethsmax;

  public
//    procedure Start;
  end;

  function  PowellFunction (Var p: PowellVector): real;

const
  capbutsab: array[0..1] of string=('Dispersion suppressor','Half symmetric bend');
  capbutemi: array[0..1] of string=('Minimize iso-mag emittance (I5/I2)','Minimize reduced emittance (I5)');
  capbutsho: array[0..3] of string=('Show dI5(s) = b^3 H','Show field B(s)','Show dispersion', 'Show beta function');
  caplabbetfoc: array[0..1] of String=('Beta at focus [m]','Beta at center [m]');
  caplabdislfo: array[0..1] of String=('Focus position [m]','Disp at center [mm]');


var
  LGBedit: TLGBedit;

implementation

{$R *.lfm}

procedure TLGBEdit.FormShow(Sender: TObject);
begin
  phideg :=FDefGet('lgbed/angle');
  len    :=FDefGet('lgbed/lengt');
  nsl    :=IDefGet('lgbed/nslic');
  bmax   :=FDefGet('lgbed/bpeak');
  betafix:=FDefGet('lgbed/betax');
  polwid :=FDefGet('lgbed/hpolw');

  nslmax:=Powellncom_max-2;
  if nsl > nslmax then nsl:=nslmax;

  sbm:=1;
  ered:=1;
  bfi:=1;

  butsab.Caption:=capbutsab[sbm];
  butemi.Caption:=capbutemi[ered];
  butsho.Caption:=capbutsho[bfi];
  Edang.Text   :=ftos(phideg,6,3);
  Edlen.Text   :=ftos(len,6,3);
  Edsli.Text   :=inttostr(nsl);
  Edbetmin.Text:=ftos(betafix,6,3);
  Edbfimax.Text:=ftos(bmax,5,2);
  Edpolwid.Text:=ftos(polwid*1000,5,1);

  labbetfoc.Caption:=caplabbetfoc[sbm];
  labdislfo.Caption:=caplabdislfo[sbm];

  fig_HANDLE:=fig;
  fig.assignScreen;
  fig.setsize(256,16,353,290);

  BName:='LGB';
  EdNam.Text:=BName;
  FindLGBs;
  CalcHom;
  ShowResults;
end;

procedure TLGBEdit.FormPaint(Sender: TObject);
begin
  MakePlot;
end;

{Find LGBs which are already in the lattice.
 Criteria:
  - segment contains olny elements, no segments.
  - segment contains opticsmarker in first place and else bends
  - all element names contain segment name at start, i.e. segm."Bbb", elements "BbbOM, Bbb01, Bbb02..."
 Fill combobox with corresponding segment names
 }
procedure TLGBedit.FindLGBs;
var
  ae: aept;
  fail, first: boolean;
  bnam:string;
  i, j: integer;
begin
  with ComboLGB do begin
    Clear;
    Text:='none.' ;
  end;
  for i:=1 to Glob.NSegm do begin
    bnam:=segm[i].nam;
    fail:=false;
    first:=true;
    ae:=segm[i].ini;
    while (ae<>nil) and not fail do begin
      if ae^.kin=ele then begin
        j:=0;
        repeat Inc(j); until Elem[j].nam = ae^.nam; // has to exist, no check required.
        with Elem[j] do begin
          fail:=not ( (Pos(bnam, nam)=1) and ((first and (cod=comrk)) or ((not first) and (cod=cbend))));
        end;
        first:=false;
      end else fail:=true;
      ae:=ae^.nex;
    end;
    if not fail then begin
      ComboLGB.Items.Add(Segm[i].nam);
    end;
  end;
  with ComboLGB do if Items.Count>0 then Text:='select LGB' else Text:='none';
end;


{calculate solution for the ideal TME homogeneous bend}
procedure TLGBedit.CalcHom;
begin
  HomInit;
// write solutions for homogeneous magnet
  labin5hom.caption:=FtoS(emrd_hom*1e6,8,3);
  labemihom.caption:=FtoS(emit_hom*1e12,8,2);
  labbetfochom.caption:=FtoS(betamin_hom,8,4);
  if sbm=1 then labdislfohom.caption:=FtoS(etamin_hom*1000,8,3) else labdislfohom.caption:=FtoS(sfocus_hom,8,3);
  laberahom.caption:=FtoS(erad_hom, 8,1);
  labdpphom.caption:=FtoS(sdpp_hom*1e3, 8,4);
  MakePlot;
  Butcre.enabled:=false;
  Butovr.enabled:=false;
end;

procedure TLGBedit.ShowResults;
begin
// write solutions from integration
  labin5res.caption:=FtoS(emrd*1e6,8,3);
  labemires.caption:=FtoS(emit*1e12,8,2);
  labbetfocres.caption:=FtoS(betamin,8,4);
  if sbm=1 then labdislfores.caption:=FtoS(eta0*1000,8,3) else labdislfores.caption:=FtoS(sfocus,8,3);
  laberares.caption:=FtoS(erad, 8,1);
  labdppres.caption:=FtoS(sdpp*1e3, 8,4);
  MakePlot;
end;

// event handlers

procedure TLGBEdit.butsabClick(Sender: TObject);
begin
  sbm:=1-sbm;
  butsab.Caption:=capbutsab[sbm];
  labbetfoc.Caption:=caplabbetfoc[sbm];
  labdislfo.Caption:=caplabdislfo[sbm];
  CalcHom;
end;

procedure TLGBEdit.butemiClick(Sender: TObject);
begin
  ered:=1-ered;
  butemi.Caption:=capbutemi[ered];
end;

procedure TLGBEdit.butshoClick(Sender: TObject);
begin
  bfi:=bfi-1;
  if bfi<0 then bfi:=High(capbutsho);
  butsho.Caption:=capbutsho[bfi];
  ShowResults;
end;

procedure TLGBEdit.EdangPress(Sender: TObject; var Key: Char);
var   kv: real;
begin
  if TEKeyVal(Edang, Key, kv, 6, 3) then if(Key=#0 ) then if kv<>phideg then begin
    phideg:=kv;
    CalcHom;
    setbmax(bmax);
  end;
end;
procedure TLGBedit.EdangExit(Sender: TObject);
var   kv: real;
begin
  if TEReadVal(Edang, kv, 6, 3) then if kv<>phideg then begin
    phideg:=kv;
    CalcHom;
    setbmax(bmax);
  end;
end;

procedure TLGBEdit.EdlenPress(Sender: TObject; var Key: Char);
var   kv: real;
begin
  if TEKeyVal(Edlen, Key, kv, 6, 3) then if(Key=#0 ) then if kv<>len then begin
    len:=kv;
    CalcHom;
    setbmax(bmax);
  end;
end;
procedure TLGBedit.EdlenExit(Sender: TObject);
var   kv: real;
begin
  if TEReadVal(Edlen, kv, 6, 3) then if kv<>len then begin
    len:=kv;
    CalcHom;
    setbmax(bmax);
  end;
end;

procedure TLGBEdit.EdsliPress(Sender: TObject; var Key: Char);
var   kv: real;
begin
  if TEKeyVal(Edsli, Key, kv, 3, 0) then if(Key=#0 ) then if kv<>nsl then begin
    nsl:=Round(kv);
    if nsl > nslmax then begin
      nsl:=nslmax;
      Edsli.Text:=inttostr(nsl);
    end;
    CalcHom;
  end;
end;
procedure TLGBedit.EdsliExit(Sender: TObject);
var   kv: real;
begin
  if TEReadVal(Edsli, kv, 3, 0) then if kv<>len then begin
    nsl:=Round(kv);
    if nsl > nslmax then begin
      nsl:=nslmax;
      Edsli.Text:=inttostr(nsl);
    end;
    CalcHom;
  end;
end;

procedure TLGBEdit.EdbetminPress(Sender: TObject; var Key: Char);
var   kv: real;
begin
  if TEKeyVal(Edbetmin, Key, kv, 6, 3) then if(Key=#0 ) then betafix:=kv;
end;
procedure TLGBedit.EdbetminExit(Sender: TObject);
var   kv: real;
begin
  if TEReadVal(Edbetmin, kv, 6, 3) then betafix:=kv;
end;

procedure TLGBedit.setbmax(kv:real);
var
  hmaxact: real; i: integer;
begin
  if kv > brho*phi/len then bmax:=kv else begin
    bmax:=brho*phi/len;
    Edbfimax.Text:=Ftos(bmax,6,3);
  end;
  hmaxact:=0; for i:=0 to nsl-1 do if hs[i]>hmaxact then hmaxact:=hs[i];
  if bmax<hmaxact*brho then CalcHom; //reset magnet if bmax < peak field, otherwise knobscale crash
end;
procedure TLGBEdit.EdbfimaxPress(Sender: TObject; var Key: Char);
var   kv: real;
begin
  if TEKeyVal(Edbfimax, Key, kv, 6, 3) then if(Key=#0 ) then setbmax(kv);
end;
procedure TLGBedit.EdbfimaxExit(Sender: TObject);
var   kv: real;
begin
  if TEReadVal(Edbfimax, kv, 6, 3) then setbmax(kv);
end;

procedure TLGBEdit.EdpolwidPress(Sender: TObject; var Key: Char);
var   kv: real;
begin
  if TEKeyVal(EdPolWid, Key, kv, 6, 1) then if(Key=#0 ) then polwid:=kv/1000;
end;

procedure TLGBedit.EdpolwidExit(Sender: TObject);
var   kv: real;
begin
  if TEReadVal(Edpolwid, kv, 6, 1) then polwid:=kv/1000;
end;

procedure TLGBEdit.chkbetminClick(Sender: TObject);
begin
  Edbetmin.Enabled:=chkbetmin.Checked;
  CalcHom;
end;

procedure TLGBEdit.chkbfimaxClick(Sender: TObject);
begin
  Edbfimax.Enabled:=chkbfimax.Checked;
  CalcHom;
end;

procedure TLGBEdit.chkpolwidClick(Sender: TObject);
begin
  Edpolwid.Enabled:=chkpolwid.Checked;
end;



procedure TLGBEdit.butrunClick(Sender: TObject);
var
  i: integer;
  PowK: Powellvector;
begin
{set up knob vector for minimizer:
 0..nsl-1 = slice curvatures hs scaled to cover infinite knob range
 nsl      = dispersion for SBM or sfocus for ABM
 [nsl+1  = sqrt(beta function), if not fixed ]
}
  if (PowellStatus = 0) then begin
    PowellBreak:=False;
    PowellStatus:=1;
    ButRun.Caption:='Interrupt';
    PowellLinMinStep:=0.5; //how to set?
    result_best:=1e20;

    SliceRescale; // does not change anything if called at init for hom dipole

    hlolim:=0;
    if chkbfimax.Checked then hhilim:=bmax/brho else hhilim:=1000.0;
    knobscale(hlolim, hhilim, phi, true);
    Setlength(kn,nsl+1);
    if sbm=1 then  kn[nsl]:=etamin else kn[nsl]:=sfocus;
    betaknob:= not chkbetmin.Checked;
    if betaknob then begin
      setlength(kn,nsl+2);
      kn[nsl+1]:=Sqrt(betamin);
      Powellncom:=nsl+2;
    end else Powellncom:=nsl+1;
    for i:=0 to Powellncom-1 do begin
      PowK[i+1]:=kn[i];
    end;
//    opamessage(0, 'powf='+ftose(Powellfunction(PowK),10,3));
    ShowResults;
//--------------------------------------------------------------------
    POWELL (PowK, Powellncom, 0.001, Powellfunction);
//--------------------------------------------------------------------
    if PowellBreak then begin   // restore best values so far
      for i:=0 to nsl-1 do hs[i]:=hs_best[i];
      beta0:=beta_best;
      if sbm=1 then eta0:=disfoc_best else sfocus:=disfoc_best;
    end;
    PowellStatus:=0;
    ShowResults;
    with LabOpStat do begin
      if PowellBreakMN then begin
        Font.Color:=clRed;
        Caption:='Optimizer ran away!';
      end else if Powellbreak then begin
        Font.Color:=clRed;
        Caption:='Interrupted.'
      end else begin
        Font.Color:=clGreen;
        Caption:='Successful termination.';
      end;
    end;
    ButRun.Caption:='Optimize field profile';
    Butcre.Enabled:=True;
    EdNam.Enabled:=True;
    if ComboLGB.ItemIndex > -1 then Butovr.enabled:=True;
  end else begin
    PowellBreak:=True;
  end;
end;

function PowellFunction (Var p: PowellVector): real;
var
  i: integer;
begin
  Application.ProcessMessages;
  for i:=0 to Powellncom-1 do kn[i]:=p[i+1];

{ problem with minimizer run-away due to asymptotic knobs: throw break into inner MNBRAK loop,
  this fires also PowellBreak and terminates.
  better: restart immediately without the saturated knob!}
  for i:=0 to nsl-1 do begin
    if abs(kn[i])>1e8 then begin // usually happens only to one knob at a time
//      opamessage(0,'knob '+inttostr(i)+' saturated at '+ftose(kn[i],10,3));
      powellbreakMN:=true;
    end;
  end;

  Knobscale(hlolim, hhilim, phi, false);
 { test on angle done, is ok
  ptest:=0; for i:=0 to nsl-1 do ptest:=ptest+ds[i]*hs[i]; opamessage(0,'ptest ='+ftos(ptest*degrad,12,6));}
  if betaknob then betamin:=sqr(kn[nsl+1]) else betamin:=betafix;
  if sbm=1 then begin
    eta0:=kn[nsl];
    etap0:=0;
    beta0:=betamin;
    alfa0:=0;
  end else begin //abm
    sfocus:=kn[nsl];
    eta0:=0;
    etap0:=0;
    beta0:=betamin+sqr(sfocus)/betamin;
    alfa0:=sfocus/betamin;
  end;
  RadInt;
  if ered=1 then result:=emrd else result:=emit;
// save best result so far
  if result < result_best then begin
    result_best:=result;
    for i:=0 to nsl-1 do hs_best[i]:=hs[i];
    beta_best:=beta0;
    if sbm=1 then disfoc_best:=eta0 else disfoc_best:=sfocus;
  end;
  Powellfunction:=result;
end;

procedure TLGBEdit.gethsmax;
var i: integer;
begin
  setkbmax:=chkpolwid.checked;
  if chkbfimax.checked then hsmax:=hhilim else begin
    hsmax:=0;
    for i:=0 to nsl do if abs(hs[i])>hsmax then hsmax:=abs(hs[i]);
  end;
end;

{creates an LGB and updates combobox}
procedure TLGBEdit.butcreClick(Sender: TObject);
var
  fnd: boolean;
  i: integer;
begin
  BName:=EdNam.Text;
  fnd:=false;
  for i:=1 to Glob.NSegm do fnd:=fnd or (BName=Segm[i].nam);
  for i:=1 to Glob.NElem do fnd:=fnd or (Pos(BName, Elem[i].nam)=1);
  if fnd then with labopstat do begin
    Font.Color:=clRed; Caption:=BName+' exists already! Find other name.';
  end
  else begin
    gethsmax;
    LGBcreate(BName);
    with labopstat do begin
      Font.Color:=clBlue; Caption:=BName+' created.';
    end;
    FindLGBs;
  end;
end;

{deletes a LGB from element and segment list and upates combobox}
procedure TLGBEdit.butdelClick(Sender: TObject);
begin
  LGBdelete(BName);
  with ComboLGB do begin
    Items.Delete(ItemIndex);
    ItemIndex:=-1;
  end;
  butdel.Enabled:=False;  butovr.Enabled:=False;
  butdel.Caption:='Delete';  butovr.Caption:='Overwrite';
  FindLGBs;
  CalcHom;
end;

procedure TLGBEdit.butovrClick(Sender: TObject);
begin
  LGBdelete(BName);
  gethsmax;
  LGBcreate(BName);
  with labopstat do begin
    Font.Color:=clBlue; Caption:=BName+' updated.';
  end;
end;


{ load an already existing LGB:
  - get the segment selected in combobox
  first pass:
    - count the bend slices, get total angle and length
    - find out, if it is sbm or abm (opticsmarker alfa<>0)
  calculate the corresponding HOM, this initializes fields and sets labels
  second pass:
    - load bend data into slices
    - load optics marker into initial conditions
  calculate radiation integrals and show results.
}
procedure TLGBEdit.ComboLGBChange(Sender: TObject);
var
  ae: aept;
  abmflag: boolean;
  i, j, iseg, bcount: integer;
  lentot, angtot: double;
begin
  with ComboLGB do begin
    BName:=Items[ItemIndex];
  end;
  for i:=1 to Glob.NSegm do with Segm[i] do begin
    if BName=nam then begin
      iseg:=i;
      ae:=ini;
      bcount:=0;
      lentot:=0;
      angtot:=0;
      while (ae<>nil) do begin
        j:=0; repeat Inc(j); until Elem[j].nam = ae^.nam;
        with Elem[j] do begin
          if (cod=cbend) then begin
            lentot:=lentot+l;
            angtot:=angtot+phi;
            Inc(bcount);
          end else if (cod=comrk) then begin
            abmflag:= abs(om^.bet[2])>1e-4; // alpha<>0 at omrk identifies abm
          end;
        end;
        ae:=ae^.nex;
      end;
    end;
  end;

  phideg:=angtot/raddeg;
  len:=lentot;
  if abmflag then sbm:=0 else sbm:=1;
  nsl:=bcount;

  butsab.Caption:=capbutsab[sbm];
  Edang.Text   :=ftos(phideg,6,3);
  Edlen.Text   :=ftos(len,6,3);
  Edsli.Text   :=inttostr(nsl);
  labbetfoc.Caption:=caplabbetfoc[sbm];
  labdislfo.Caption:=caplabdislfo[sbm];

  CalcHom;
  hsmax:=0;
  with Segm[iseg] do begin
    ae:=ini;
    i:=0;
    while (ae<>nil) do begin
      j:=0; repeat Inc(j); until Elem[j].nam = ae^.nam;
      with Elem[j] do begin
        if cod=comrk then begin
          beta0:=om^.bet[1]; alfa0:=om^.bet[2]; eta0:=om^.eta[1]; etap0:=om^.eta[2];
        end else if (cod=cbend) then begin
          hs[i]:=phi/l;
          if hs[i]>hsmax then hsmax:=hs[i];
          ds[i]:=l;
          Inc(i);
        end;
        ae:=ae^.nex;
      end;
    end;
  end;
  ss[0]:=0;
  for i:=0 to nsl-1 do ss[i+1]:=ss[i]+ds[i];
  RadInt;
  if sbm=1 then begin
    betamin:=beta0;
  end else begin
    betamin:=beta0/(1+sqr(alfa0));
    sfocus:=alfa0*betamin;
  end;

  ShowResults;
  butdel.Enabled:=True;
  butdel.Caption:='Delete '+BName;
  butovr.Caption:='Overwrite '+BName;
end;



procedure TLGBEdit.butexClick(Sender: TObject);
begin
  DefSet('lgbed/angle',phideg);
  DefSet('lgbed/lengt',len);
  DefSet('lgbed/nslic',nsl);
  DefSet('lgbed/bpeak',bmax);
  DefSet('lgbed/betax',betafix);
  DefSet('lgbed/hpolw',polwid);
  Close;
end;


procedure TLGBEdit.buttxtClick(Sender: TObject);
const
  b=' ';
  nix='          ';
var
  fname: string;
  outfi: textfile;
  i: integer;
  ang, dang: double;
begin
  fname:=ExtractFileName(FileName);
  fname:=work_dir+Copy(fname,0,Pos('.',fname)-1);
//write data to file
  fname:=fname+'_LGB_'+BName+'.txt';
  assignFile(outfi,fname);
{$I-}
  rewrite(outfi);
{$I+}
  if IOResult =0 then begin
    writeln(outfi, '#     S[m]       dS[m]  phi[deg]  dphi[deg]       B[T]   betax[m] alfax[rad]     etax[m] etaxp[rad]');
    writeln(outfi, '# -------------------------------------------------------------------------------------------------');
    ang:=0;
    for i:=0 to nsl-1 do begin
      dang:=hs[i]*ds[i]/raddeg;
        writeln(outfi, ftos(ss[i],-5,2), b, ftos(ds[i],-5,2), b, ftos(ang,-5,2), b, ftos(dang,-5,2), b, ftos(hs[i]*brho,-5,2),b,
          ftos(betas[i],-5,2), b, ftos(alfas[i],-5,2), b, ftos(etas[i],-5,2), b, ftos(etaps[i],-5,2));
      ang:=ang+dang;
    end;
    writeln(outfi, ftos(ss[nsl],-5,2), b, nix, b, ftos(ang,-5,2), b, nix, b, nix,b,
          ftos(betas[nsl],-5,2), b, ftos(alfas[nsl],-5,2), b, ftos(etas[nsl],-5,2), b, ftos(etaps[nsl],-5,2));
      ang:=ang+dang;
    writeln(outfi, '# -------------------------------------------------------------------------------------------------');
    CloseFile(outfi);
    MessageDlg('Data saved to text file '+fname, MtInformation, [mbOK],0);
  end else begin
    OPALog(1,'could not write '+fname);
  end;
end;

end.
