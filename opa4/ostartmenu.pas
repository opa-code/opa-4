unit ostartmenu;

 {$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, globlib, mathlib, ASaux, linoplib;

type

  { Tstartsel }

  Tstartsel = class(TForm)
    but_dpp: TButton;
    But_propper: TButton;
    chk_dpp: TCheckBox;
    chk_coup: TCheckBox;
    chk_flip: TCheckBox;
    ed_ax: TEdit;
    ed_ay: TEdit;
    ed_bx: TEdit;
    ed_by: TEdit;
    ed_c12: TEdit;
    ed_c11: TEdit;
    ed_c21: TEdit;
    ed_c22: TEdit;
    ed_di: TEdit;
    ed_diy: TEdit;
    ed_dp: TEdit;
    ed_dpp: TEdit;
    ed_dpy: TEdit;
    ed_x: TEdit;
    ed_xp: TEdit;
    ed_y: TEdit;
    ed_yp: TEdit;
    Lab_togo: TLabel;
    Lab_g2: TLabel;
    Lab_Loc: TLabel;
    Lab_cma: TLabel;
    Lab_ax: TLabel;
    Lab_ay: TLabel;
    lab_bx: TLabel;
    Lab_by: TLabel;
    Lab_di: TLabel;
    Lab_diy: TLabel;
    Lab_dp: TLabel;
    lab_dpp: TLabel;
    Lab_dpy: TLabel;
    lab_x: TLabel;
    lab_xp: TLabel;
    lab_y: TLabel;
    lab_yp: TLabel;
    pagini: TPageControl;
    rbutini: TRadioButton;
    rbutfin: TRadioButton;
    rbutper: TRadioButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    butclo: TButton;
    butexi: TButton;
    rbutsym: TRadioButton;
    butapply: TButton;
    taborb: TTabSheet;
    tabbet: TTabSheet;
    tabdis: TTabSheet;
    tabcou: TTabSheet;
    procedure rbutClick(Sender: TObject);
    procedure rbutperChange(Sender: TObject);
    procedure But_propperClick(Sender: TObject);
    procedure chk_coupChange(Sender: TObject);
    procedure chk_flipChange(Sender: TObject);
    procedure but_dppClick(Sender: TObject);
    procedure chk_dppChange(Sender: TObject);
    procedure ed_couKeyPress(Sender: TObject; var Key: char);
    procedure ed_couExit(Sender: TObject);
//    procedure ButOrbClick(Sender: TObject);
    procedure butapplyClick(Sender: TObject);
    procedure butcloClick(Sender: TObject);
    procedure butexiClick(Sender: TObject);
  private
    Fhandle: TForm;
    ooimode: integer; // 0 optic, 1 orbit, 2 injection
//    orbswitch: boolean;
    nomk: integer;
    procedure Go;
//    procedure Exit;
    procedure set_pan_ini;
    function get_pan_ini (imode: integer): boolean;
    procedure per_panini;
    procedure calc_g2;
    procedure setdppmode;
    procedure set_togo_lab;
  public
     {cancel_start, } orb_plot_enabled: boolean;
     procedure Load (ooimode_in: integer; calledfrom:TForm);
     procedure Exit;
  end;


const
  maxnomk=20;
var
  startsel: Tstartsel;
  ioma, joma: array[1..maxnomk] of integer;
  lablocs: array[1..maxnomk] of Elemstr;
  enable_chk: boolean;

implementation

{$R *.lfm}
procedure TStartSel.Load (ooimode_in: integer; calledfrom: TForm);

var
  i, k, j: integer;
  fnd: boolean;
  romk: TRadioButton;

begin
  Fhandle:=calledfrom;
  Fhandle.enabled:=false;

  //cancel_start:=false;
  orb_plot_enabled:=false;
  ooimode:=ooimode_in mod 10;

  {fixed by introducing orb_plot_enabled flag; on start plot shows empty figures, ok
   bypass: apply does not work because startsel called modal from orbit, orbit shown only after form close.
   suppress apply button in first call from orbit, then forced to use "done" to proceed. ~ok :-/ }
//  if ooimode_in>=10 then butapply.Visible:=false else butapply.Visible:=true;

  rbutper.Enabled:= ooimode<>2;
  rbutsym.Enabled:= ooimode<>2;
//  orbswitch:=false; // switch to orbit in optics mode (to set ini orbit)

//.  opamessage(0,'startsel: OpticStartMode ='+inttostr(OpticStartMode)+'  ooimode = '+inttostr(ooimode) );


// check last checked button
// crasht hier, falls orbit wiederholt gerufen oder falls nach linear optik gerufen - ??? 26.10.2020

//  if ooimode =0 then begin //tmp, nur um crash in orbit mode zu verhindern
    case OpticStartMode of
      0: rbutper.Checked:= ooimode<>2; //don't check if invisible in case of injection mode
      1: rbutsym.Checked:= ooimode<>2;
      2: rbutini.Checked:=True;
      3: rbutfin.Checked:=True;
      else
    end;
//  end;

  if ooimode=0 then pagini.TabIndex:=1 else  pagini.TabIndex:=0;


// find all optics markers (max 20) in the lattice:
  for j:=1 to maxnomk do joma[j]:=-1;
  nomk:=0;
  for i:=1 to Glob.NLatt do begin
    j:=FindEl(i);
    if Ella[j].cod=comrk then begin
      fnd:=false;
      for k:=1 to nomk do fnd:=fnd or (joma[k]=j);
      if not fnd then begin
        inc(nomk);
        joma[nomk]:=j;
        ioma[nomk]:=i;
      end;
    end;
  end;
  height:=rbutfin.top+(nomk+3)*24+80;
  if height < 304 then height:=304;
  butclo.top:=height-40; butexi.top:=butclo.top; butapply.top:=butclo.top; Lab_togo.top:=butclo.top;
  lab_dpp.top:=height-80; ed_dpp.top:=lab_dpp.top;
  but_dpp.top:=lab_dpp.top; chk_dpp.top:=lab_dpp.top;
  ed_dpp.text:=FtoS(dPmult,5,2);

  lablocs[1]:='- periodic - ' ; lablocs[2]:='- symmetric -';
  lablocs[3]:='initial values'; lablocs[4]:='final values';

  for i:=1 to nomk do begin
    romk:=TRadioButton(FindComponent('romk_'+IntToStr(i)));
    if romk = nil then begin
      romk:=TRadioButton.Create(self);
      romk.parent:=Self;
      romk.name:= 'romk_'+IntToStr(i);
      romk.caption:='Optics marker '+Ella[joma[i]].nam;
      lablocs[4+i]:=Ella[joma[i]].nam;
      romk.Tag:=i+3;
      romk.setBounds(rbutfin.left,rbutfin.top+i*24,200,24);
      if OpticStartMode=i+3 then romk.checked:=true;
      romk.OnClick:=rbutClick;
    end;
  end;
  butclo.Enabled:= (OpticStartMode>=0) and (OpticStartMode<=nomk+3);
  butapply.Enabled:=butclo.Enabled;

  setdppmode;

//throws change events; suppress
  enable_chk:=false;
  chk_coup.Checked:=not Status.Uncoupled;
  chk_flip.checked:=ExchangeModes;
  chk_dpp.checked :=MomMode;
  enable_chk:=true;
  chk_coup.visible:=(ooimode=0);
  chk_dpp.visible:=(ooimode=0);
  chk_flip.visible:=(not status.uncoupled) and (ooimode=0);
  but_propper.visible:=(not status.uncoupled) and (ooimode=0);

  set_pan_ini;
         {form was set "always on top" -> messageDlg appears BEHIND this form, to avoid hiding
         move this form to the upper left corner:}
  Left:=10; Top:=10;
end;


procedure TStartSel.Exit;
var
  i: integer;
  romk: TRadioButton;
begin
  for i:=1 to maxnomk do begin
    romk:=TRadioButton(FindComponent('romk_'+IntToStr(i)));
    if romk <> nil then romk.free;
  end;
  Close;
//  StartSel:=nil; // not necessary to destroy?
end;

procedure Tstartsel.butcloClick(Sender: TObject);
begin
  Go;
  Exit;
end;

procedure Tstartsel.butapplyClick(Sender: TObject);
begin
  Go;
end;

procedure Tstartsel.rbutperChange(Sender: TObject);
begin
  chk_flip.visible:=chk_coup.Checked and (ooimode=0) ;
  but_propper.visible:=chk_coup.Checked and (ooimode=0) ;
end;

procedure TStartsel.go;
var
  i, istart: integer;
  romk: TRadioButton;
begin
  Fhandle.enabled:=true;
  Status.Uncoupled:=not chk_coup.Checked;
  orb_plot_enabled:=true;
  //  UsePulsed:=chk_kick.Checked;
//  UseSext:=chk_nlin.Checked;

  PerMode:=False; SymMode:=False;
  if rbutper.checked then begin
    Permode:=True;
    istart:=0;
    OpticStartMode:=0;
    ExchangeModes:=chk_flip.Checked;
  end else if rbutsym.Checked then begin
     SymMode:=True;
     istart:=0;
     OpticStartMode:=1;
  end else if rbutini.Checked then begin
    istart:=0;
    OpticStartMode:=2;
  end else if rbutfin.Checked then begin
    istart:=Glob.NLatt;
    OpticStartMode:=3;
  end else begin
    for i:=1 to nomk do begin
      romk:=TRadioButton(FindComponent('romk_'+IntToStr(i)));
      if romk.Checked then begin
        istart:=ioma[i];
        OpticStartMode:=i+3;
      end;
    end;
  end;

  if get_pan_ini (OpticStartMode) then begin
    if ooimode >0 then begin
      OrbitCalc(istart);
      PlotOrbit;
    end else begin
      OpticCalc(istart);
      case OpticPlotMode of
        MagPlot: PLotMag;
        EnvPlot: PlotEnv;
        else PlotBeta;
      end;
    end;
    per_panini;
    //set_pan_ini; //works, but better have dedicated public update proc to be called from opticcalc
  end;
  Lab_togo.Caption:='   ';
end;

procedure Tstartsel.butexiClick(Sender: TObject);
begin
  Fhandle.Close;
  Exit;
end;

procedure TStartsel.setdppmode;
begin
  if dppmode then begin
    but_dpp.caption:='= ';
  end else begin
    but_dpp.caption:='=0';
  end;
  ed_dpp.visible:=dppmode;
  chk_dpp.visible:=dppmode and (ooimode=0);
end;

procedure Tstartsel.but_dppClick(Sender: TObject);
begin
  dppmode:=not dppmode;
  setdppmode;
  set_togo_lab;
end;

procedure Tstartsel.But_propperClick(Sender: TObject);
begin
  Proppertest:=true;
  Go;
end;

procedure Tstartsel.chk_dppChange(Sender: TObject);
begin
  set_togo_lab;
end;

procedure Tstartsel.set_togo_lab;
begin
  Lab_togo.Caption:='-->';
end;

procedure Tstartsel.chk_flipChange(Sender: TObject);
begin
  set_togo_lab;
end;

procedure Tstartsel.chk_coupChange(Sender: TObject);
begin
  chk_flip.visible:=chk_coup.Checked;
  set_togo_lab;
end;


procedure TStartsel.calc_g2;
var
  g2, val: real;
  cm: matrix_2;
begin
  if TEReadVal(ed_c11,val,6,3) then cm[1,1]:=val;
  if TEReadVal(ed_c12,val,6,3) then cm[1,2]:=val;
  if TEReadVal(ed_c21,val,6,3) then cm[2,1]:=val;
  if TEReadVal(ed_c22,val,6,3) then cm[2,2]:=val;
  g2:=1-matdet2(cm);
  if g2<0 then lab_g2.font.color:=clRed else lab_g2.font.color:=clgreen;
  lab_g2.caption:='g^2 = '+ftos(g2,7,4);
end;

procedure Tstartsel.ed_couKeyPress(Sender: TObject; var Key: char);
var
  x:real;
  ed: TEdit;
begin
  ed:=Sender as TEdit; x:=0;
  if TEKeyVal(ed, Key, x, 7, 4) then calc_g2;
end;

procedure Tstartsel.ed_couExit(Sender: TObject);
var
  x:real;
  ed: TEdit;
begin
  ed:=Sender as TEdit; x:=0;
  if TEReadVal(ed, x, 7, 4) then calc_g2;
end;


function Tstartsel.get_pan_ini( imode: integer): boolean;
var
  ox, oxp, oy, oyp, odpp,  bx, ax, by, ay, di, dp, diy, dpy, val: real;
  cm: matrix_2;
  f:boolean;
begin
  f:=true;
  if dppmode then begin
    if TEReadVal(ed_dpp ,val,6,3) then odpp :=val else f:=false; // dpp also in per mode
    if f then begin
      if ooimode=0 then begin
        dPMult:=odpp;
        MomMode:=chk_dpp.Checked;
{
        if chk_dpp.Checked then begin
          dPMult:=odpp/100.0;
          MomMode:=True;
        end else begin
          Glob.dpp:=odpp/100.0;
          MomMode:=False;
        end;
}
      end else begin
        Glob.dpp:=odpp/100;
      end;
    end;
  end else Glob.dpp:=0;

  if imode<=1 then begin
    get_pan_ini:=true;
  end else begin
//    if (ooimode > 0) {or orbswitch} then begin
    if TEReadVal(ed_x  ,val,6,3) then ox  :=val else f:=false;
    if TEReadVal(ed_xp ,val,6,3) then oxp :=val else f:=false;
    if TEReadVal(ed_y  ,val,6,3) then oy  :=val else f:=false;
    if TEReadVal(ed_yp ,val,6,3) then oyp :=val else f:=false;
    if f then begin
      if imode=2 then begin //ini
        Glob.Op0.orb[1]:=ox/1000; Glob.Op0.orb[2]:=oxp/1000;
        Glob.Op0.orb[3]:=oy/1000; Glob.Op0.orb[4]:=oyp/1000;
      end else if imode=3 then begin  //fin
        Glob.OpE.orb[1]:=ox/1000; Glob.OpE.orb[2]:=oxp/1000;
        Glob.OpE.orb[3]:=oy/1000; Glob.OpE.orb[4]:=oyp/1000;
      end else if imode>3 then begin
        with Ella[joma[imode-3]].om^ do begin
          orb[1]:=ox/1000; orb[2]:=oxp/1000; orb[3]:=oy/1000; orb[4]:=oyp/1000;
        end;
      end;
    end;

    if ooimode=0 then  begin
      if TEReadVal(ed_bx,val,6,3) then bx:=val else f:=false;
      if TEReadVal(ed_ax,val,6,3) then ax:=val else f:=false;
      if TEReadVal(ed_by,val,6,3) then by:=val else f:=false;
      if TEReadVal(ed_ay,val,6,3) then ay:=val else f:=false;
      if TEReadVal(ed_di,val,6,3) then di:=val else f:=false;
      if TEReadVal(ed_dp,val,6,3) then dp:=val else f:=false;
      if TEReadVal(ed_diy,val,6,3) then diy:=val else f:=false;
      if TEReadVal(ed_dpy,val,6,3) then dpy:=val else f:=false;
      if TEReadVal(ed_c11,val,6,3) then cm[1,1]:=val else f:=false;
      if TEReadVal(ed_c12,val,6,3) then cm[1,2]:=val else f:=false;
      if TEReadVal(ed_c21,val,6,3) then cm[2,1]:=val else f:=false;
      if TEReadVal(ed_c22,val,6,3) then cm[2,2]:=val else f:=false;
      calc_g2;

      if f then begin
        if imode=2 then begin //ini
          with Glob.Op0 do begin
            beta:=bx; alfa:=ax;
            betb:=by; alfb:=ay;
            disx:=di; dipx:=dp;
            disy:=diy; dipy:=dpy;
            cmat:=cm;
          end;
        end else if imode=3 then begin  //fin
          with Glob.OpE do begin
            beta:=bx; alfa:=ax;
            betb:=by; alfb:=ay;
            disx:=di; dipx:=dp;
            disy:=diy; dipy:=dpy;
            cmat:=cm;
          end;
        end else if imode>3 then begin
          with Ella[joma[imode-3]].om^ do begin
            bet[1]:=bx; bet[2]:=ax; bet[3]:=by; bet[4]:=ay;
            eta[1]:=di; eta[2]:=dp;
            eta[3]:=diy; eta[4]:=dpy;
            cma:=cm;
          end;
        end;
      end; // if f
    end; // ooimode=0
  end; // imode > 1
  get_pan_ini:=f;
end;

{procedure Tstartsel.ButOrbClick(Sender: TObject);
begin
  orbswitch:=not orbswitch;
  if orbswitch then begin
    butorb.caption:='Orbit';
  end else begin
    butorb.caption:='Betas';
  end;
//  set_pan_ini;
end;
}

procedure Tstartsel.set_pan_ini;
var
  i, icheck: integer;
  romk: TRadioButton;
  ox, oxp, oy, oyp, odpp, bx, ax, by, ay, di, dp, diy, dpy: real; cm: matrix_2;
begin
  icheck:=-1;
  if rbutper.checked then icheck:=0;
  if rbutsym.checked then icheck:=1;
  if rbutini.checked then icheck:=2;
  if rbutfin.checked then icheck:=3;
  for i:=1 to nomk do begin
    romk:=TRadioButton(FindComponent('romk_'+IntToStr(i)));
    if romk<>nil then if romk.Checked then icheck:=i+3; //check for nil helps to avoid crash - why?
  end;
  if icheck>=0 then begin
    Lab_Loc.Caption:=lablocs[icheck+1];
    butapply.enabled:=true;
    butclo.enabled:=true;
  end;

  if icheck <=1 then begin
    taborb.Enabled:=false;
    tabbet.Enabled:=false;
    tabdis.Enabled:=false;
    tabcou.Enabled:=false;
  end else begin
    taborb.Enabled:=true;

    if icheck=2 then begin // start
      ox  :=Glob.Op0.orb[1]*1000; oxp:=Glob.Op0.orb[2]*1000;
      oy  :=Glob.Op0.orb[3]*1000; oyp:=Glob.Op0.orb[4]*1000;
    end else if icheck=3 then begin
      ox  :=Glob.OpE.orb[1]*1000; oxp:=Glob.OpE.orb[2]*1000;
      oy  :=Glob.OpE.orb[3]*1000; oyp:=Glob.OpE.orb[4]*1000;
    end else if icheck>3 then begin
      with Ella[joma[icheck-3]].om^ do begin
        ox  :=orb[1]*1000; oxp:=orb[2]*1000; oy:=orb[3]*1000; oyp:=orb[4]*1000;
      end;
    end;

    ed_x.Text:=ftosv(ox,6,3); ed_xp.Text:=ftosv(oxp,6,3);
    ed_y.Text:=ftosv(oy,6,3); ed_yp.Text:=ftosv(oyp,6,3);

    if ooimode=0 then begin // optics mode only
      tabbet.Enabled:=true; tabdis.Enabled:=true;   tabcou.Enabled:=true;
      if icheck=2 then begin // start
        with Glob.Op0 do begin
          bx :=beta; ax :=alfa;
          by :=betb; ay :=alfb;
          di :=disx; dp :=dipx;
          diy:=disy; dpy:=dipy;
          cm:=cmat;
        end;
      end else if icheck=3 then begin
        with Glob.OpE do begin
          bx :=beta; ax :=alfa;
          by :=betb; ay :=alfb;
          di :=disx; dp :=dipx;
          diy:=disy; dpy:=dipy;
          cm:=cmat;
        end;
      end else if icheck>3 then begin
        with Ella[joma[icheck-3]].om^ do begin
          bx:=bet[1]; ax:=bet[2]; by:=bet[3]; ay:=bet[4];
          di:=eta[1]; dp:=eta[2]; diy:=eta[3]; dpy:=eta[4];
          cm:=cma;
        end;
      end;
      ed_bx.Text :=ftosv(bx,6,3); ed_ax.Text :=ftosv(ax,6,3);
      ed_by.Text :=ftosv(by,6,3); ed_ay.Text :=ftosv(ay,6,3);
      ed_di.Text :=ftosv(di,6,3); ed_dp.Text :=ftosv(dp,6,3);
      ed_diy.Text:=ftosv(diy,6,3); ed_dpy.Text:=ftosv(dpy,6,3);
      ed_c11.Text:=ftosv(cm[1,1],6,3); ed_c12.Text:=ftosv(cm[1,2],6,3);
      ed_c21.Text:=ftosv(cm[2,1],6,3); ed_c22.Text:=ftosv(cm[2,2],6,3);
      calc_g2;
    end else begin
      tabbet.Enabled:=false; tabdis.Enabled:=false; tabcou.Enabled:=false;
    end;
  end;
  if ooimode=0 then odpp:=dPmult else odpp:=Glob.dpp*100;
  ed_dpp.Text:=ftosv(odpp,6,3);
end;

procedure TStartsel.per_panini;
// update the fields in panini with data after per/sym solution: do automatically what would
// otherwise happen when clicking "initial" after running "per/sym"
begin
  if (PerMode and status.periodic) or (SymMode and status.symmetric)
  then with Glob.Op0 do begin
    ed_x.Text:=ftosv(orb[1]*1000,6,3); ed_xp.Text:=ftosv(orb[2]*1000,6,3);
    ed_y.Text:=ftosv(orb[3]*1000,6,3); ed_yp.Text:=ftosv(orb[4]*1000,6,3);
    if ooimode=0 then begin // optics mode only
      ed_bx.Text :=ftosv(beta,6,3); ed_ax.Text :=ftosv(alfa,6,3);
      ed_by.Text :=ftosv(betb,6,3); ed_ay.Text :=ftosv(alfb,6,3);
      ed_di.Text :=ftosv(disx,6,3); ed_dp.Text :=ftosv(dipx,6,3);
      ed_diy.Text:=ftosv(disy,6,3); ed_dpy.Text:=ftosv(dipy,6,3);
      ed_c11.Text:=ftosv(cmat[1,1],6,3); ed_c12.Text:=ftosv(cmat[1,2],6,3);
      ed_c21.Text:=ftosv(cmat[2,1],6,3); ed_c22.Text:=ftosv(cmat[2,2],6,3);
      calc_g2;
    end;
  end;
end;

//clicking ANY radiobutton enables the go-button:
procedure Tstartsel.rbutclick(Sender: TObject);
begin
  butclo.Enabled:=True;
  butapply.Enabled:=True;
  set_pan_ini;
end;







end.
