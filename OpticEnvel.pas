unit OpticEnvel;

// {$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpticPlot, StdCtrls, OPAglobal, ASaux, ExtCtrls;

type

  { TsetEnvel }

  TsetEnvel = class(TForm)
    butgo: TButton;
    butcan: TButton;
    chk_bfieldfix: TCheckBox;
    chk_betpp: TCheckBox;
    chk_betxy: TCheckBox;
    chk_betab: TCheckBox;
    ed_bfieldmin: TEdit;
    ed_bfieldmax: TEdit;
    lab_bfieldmin: TLabel;
    lab_bfieldmax: TLabel;
    rbbet: TRadioButton;
    rbenv: TRadioButton;
    rbmag: TRadioButton;
    rbu_orbi: TRadioButton;
    rbu_cdet: TRadioButton;
    rbu_disp: TRadioButton;
    rdg_disco: TRadioGroup;
    rgmod: TRadioGroup;
    panenv: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    rbueq: TRadioButton;
    rbuinp: TRadioButton;
    edcop: TEdit;
    edemx: TEdit;
    edemy: TEdit;
    eddpp: TEdit;
    panMag: TPanel;
    panBet: TPanel;
    edref: TEdit;
    labref: TLabel;
    Label9: TLabel;
    cbxbetamax: TCheckBox;
    edbetmax: TEdit;
    eddismax: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    procedure chk_betabChange(Sender: TObject);
    procedure chk_betppChange(Sender: TObject);
    procedure chk_betxyChange(Sender: TObject);
    procedure chk_bfieldfixClick(Sender: TObject);
    procedure rbuClick(Sender: TObject);
    procedure edcopKeyPress(Sender: TObject; var Key: Char);
    procedure edemxKeyPress(Sender: TObject; var Key: Char);
    procedure edemyKeyPress(Sender: TObject; var Key: Char);
    procedure eddppKeyPress(Sender: TObject; var Key: Char);
    procedure butcanClick(Sender: TObject);
    procedure butgoClick(Sender: TObject);
    procedure rbmodClick(Sender: TObject);
    procedure edrefKeyPress(Sender: TObject; var Key: Char);
    procedure edbetmaxKeyPress(Sender: TObject; var Key: Char);
    procedure eddismaxKeyPress(Sender: TObject; var Key: Char);
    procedure cbxbetamaxClick(Sender: TObject);
    procedure Exit;
    procedure rbu_cdetChange(Sender: TObject);
    procedure rbu_dispChange(Sender: TObject);
    procedure rbu_orbiChange(Sender: TObject);
  private
    senv_emix, senv_emiy, senv_sdpp, senv_rref, erat, emix, emiy, sdpp, rref, betmax, dismax, bfmax, bfmin: Real;
    smagplot, senvplot, suseeqemi, sbetamax, sbfieldmax, enable_chk: boolean;
    buyauto_handle: TButton;
    procedure Config;
    procedure MakePlot;
  public
    procedure Load (ba: TButton);
  end;

var
  setEnvel: TsetEnvel;

implementation

{$R *.lfm}

procedure TsetEnvel.config;
var
  envact:boolean;
begin
  panMag.visible:=(OpticPlotMode=MagPlot);
  panBet.visible:=(OpticPlotMode=BetPlot);
  envact:=(OpticPlotMode=EnvPlot);
  panEnv.Visible:=envact;
  edcop.enabled:=envact and UseEqEmi and status.UnCoupled;
  edemx.enabled:=envact and  not UseEqEmi;
  edemy.enabled:=envact and  not UseEqEmi;
  eddpp.enabled:=envact and  not UseEqEmi;
  rbueq.enabled:=envact;
  rbuinp.enabled:=envact;
  edbetmax.enabled:=sbetamax;
  eddismax.enabled:=sbetamax;
  ed_bfieldmax.enabled:=sbfieldmax;
  ed_bfieldmin.enabled:=sbfieldmax;
  if status.Uncoupled then begin
    chk_betab.visible:=false;
    chk_betxy.visible:=false;
    chk_betpp.visible:=false;
    rbu_cdet.enabled :=false;
  end else begin
    chk_betab.visible:=true;
    chk_betxy.visible:=true;
    chk_betpp.visible:=true;
    rbu_cdet.enabled :=true;
  end;
end;

procedure TsetEnvel.Load (ba: TButton);
begin
  buyauto_handle:=ba;
  env_emix:=FDefGet('envel/emix')/1e9;
  env_emiy:=FDefGet('envel/emiy')/1e9;
  env_sdpp:=FDefGet('envel/sdpp')/1e2;
  erat:=FDefGet('envel/erat')*1e2;
  env_rref:=FDefGet('envel/rref')/1e3;
  betmax:=FDefGet('envel/bfix');
  dismax:=FDefGet('envel/dfix');
  bfmax:=FDefGet('envel/bmax');
  bfmin:=FDefGet('envel/bmin');
// save -> in case of canceling restore
  sMagPlot:=(OpticPlotMode=MagPlot);
  sEnvPlot:=(OpticPlotMode=EnvPlot);
  sUseEqEmi:=UseEqEmi;
  if not(sMagPlot or sEnvPlot) then sbetamax:=not xautoscale;
  if sMagPlot then sbfieldmax:=not xautoscale;
  senv_emix:=env_emix;
  senv_emiy:=env_emiy;
  senv_sdpp:=env_sdpp;
  senv_rref:=env_rref;

  case OpticPlotMode of
    MagPlot: rbMag.checked:=true;
    EnvPlot: rbEnv.checked:=true;
    else rbBet.checked:=true;
  end;
  enable_chk:=false;
  rbuEq.checked:=UseEqEmi;
  rbuinp.checked:=not UseEqEmi;
  rbu_disp.checked:=true;
  chk_betab.checked:=true;
  chk_betxy.checked:=false;
  chk_betpp.checked:=false;
  enable_chk:=true;
  emix:=env_emix*1E9;
  emiy:=env_emiy*1E9;
  sdpp:=env_sdpp*1E2;
  rref:=env_rref*1e3;
  Config;
  edcop.enabled:=status.uncoupled;
  if status.uncoupled then edcop.text:=FtoS(erat,6,2) else if oBeam[0].EmitA >1e-16 then edcop.text:=FtoS(oBeam[0].EmitB/oBeam[0].EmitA*100,6,2) else edcop.text:='0';
  edemx.text:=FtoS(emix,6,3);
  edemy.text:=FtoS(emiy,6,3);
  eddpp.text:=FtoS(sdpp,6,3);
  edref.text:=FtoS(rref,6,2);
  edbetmax.text:=FtoS(betmax,6,2);
  eddismax.text:=FtoS(dismax,6,3);
  ed_bfieldmax.text:=FtoS(bfmax,6,2);
  ed_bfieldmin.text:=FtoS(bfmin,6,2);
end;


procedure TsetEnvel.rbmodClick(Sender: TObject);
begin
  if rbenv.Checked then OpticPlotMode:=EnvPlot else if rbmag.Checked then OpticPlotMode:=MagPlot else OpticPlotMode:=BetPlot;
  config;
  InitBetaTab; FillBetaTab(ibetamark);
  MakePlot;
end;


procedure TsetEnvel.rbuClick(Sender: TObject);
begin
  UseEqEmi:=rbueq.Checked;
  Config;
end;

procedure TsetEnvel.chk_betabChange(Sender: TObject);
begin
  ShowBetas[1]:=chk_betab.Checked;
  if enable_chk then PlotBeta;
end;

procedure TsetEnvel.chk_betxyChange(Sender: TObject);
begin
   ShowBetas[2]:=chk_betxy.Checked;
   if enable_chk then PlotBeta;
end;


procedure TsetEnvel.chk_betppChange(Sender: TObject);
begin
  ShowBetas[3]:=chk_betpp.Checked;
  if enable_chk then  PlotBeta;
end;

procedure TsetEnvel.edcopKeyPress(Sender: TObject; var Key: Char);
begin
  TEKeyVal(edcop, Key, erat , 6,2);
end;

procedure TsetEnvel.edemxKeyPress(Sender: TObject; var Key: Char);
begin
  TEKeyVal(edemx, Key, emix, 6,3);
end;

procedure TsetEnvel.edemyKeyPress(Sender: TObject; var Key: Char);
begin
  TEKeyVal(edemy, Key, emiy, 6,3);
end;

procedure TsetEnvel.eddppKeyPress(Sender: TObject; var Key: Char);
begin
  TEKeyVal(eddpp, Key, sdpp, 6,3);
end;

procedure TsetEnvel.edrefKeyPress(Sender: TObject; var Key: Char);
begin
  TEKeyVal(edref, Key, rref, 6,2);
end;

procedure TsetEnvel.butcanClick(Sender: TObject);
//these actions should become a "reset button!"

begin
//  if sMagPlot then OpticPlotMode:=MagPlot else if sEnvPlot then OpticPlotMode:= EnvPlot else OpticPlotMode:=BetPlot;
{  UseEqEmi:=sUseEqEmi;
  env_emix:=senv_emix;
  env_emiy:=senv_emiy;
  env_sdpp:=senv_sdpp;
}
  Exit;
end;

procedure TsetEnvel.butgoClick(Sender: TObject);
begin
  MakePlot;
  FillBetaTab (ibetamark);
end;

procedure TsetEnvel.MakePlot;
begin
  case OpticPlotMode of
    MagPlot: begin
      xautoscale:=not sbfieldmax;
      if sbfieldmax and TEReadVal(ed_bfieldmax, bfmax,6,2) and TEReadVal(ed_bfieldmin,bfmin,6,2) then begin
        buyauto_Handle.caption:='fixed';
        bfieldmax:=bfmax;
        bfieldmin:=bfmin;
        DefSet('envel/bmax',bfmax);
        DefSet('envel/bmin',bfmin);
      end;
      if TEReadVal(edref,rref,6,2) then begin
        env_rref:=rref/1e3;
        DefSet('envel/rref',rref);
        PlotMag; //Exit;
      end;
    end;
    EnvPlot: begin
      if TEReadVal(edcop,erat,6,3)
      and TEReadVal(edemx,emix,6,3)
      and TEReadVal(edemy,emiy,6,3)
      and TEReadVal(eddpp,sdpp,6,3) then begin
        if useEqEmi then begin
          if status.UnCoupled then begin
            env_erat:=erat/100.0;
            env_emix:=oBeam[0].EmitA/(1+env_erat*oBeam[0].Jb/oBeam[0].Ja); //uncoupled: Jb=1
            env_emiy:=env_emix*env_erat;
            DefSet('envel/erat',env_erat);
          end else begin
            env_emix:=oBeam[0].EmitA;
            env_emiy:=oBeam[0].EmitB;
          end;
          env_sdpp:=oBeam[0].sigmaE;
        end else begin
          env_emix:=emix*1E-9;
          env_emiy:=emiy*1E-9;
          env_sdpp:=sdpp*1E-2;
          DefSet('envel/emix',emix);
          DefSet('envel/emiy',emiy);
          DefSet('envel/sdpp',sdpp);
        end;
        xautoscale:=true;
//opamessage(0,'env emy ='+ftos(env_emiy*1e12,12,3));
        PlotEnv; //Exit;
      end;
    end;
    BetPlot: begin
      xautoscale:=not sbetamax;
      if sbetamax and TEReadVal(edbetmax,betmax,6,2) and TEReadVal(eddismax,dismax,6,3) then begin
        betamax:=betmax/1.5;
        dispmax:=dismax;
        buyauto_Handle.caption:='fixed';
        DefSet('envel/bfix',betmax);
        DefSet('envel/dfix',dismax);
      end else buyauto_Handle.caption:='auto';

      PlotBeta; //Exit;
    end;
  end;
end;

procedure TsetEnvel.edbetmaxKeyPress(Sender: TObject; var Key: Char);
begin
  TEKeyVal(edbetmax, Key, betmax, 6,2);
end;

procedure TsetEnvel.eddismaxKeyPress(Sender: TObject; var Key: Char);
begin
  TEKeyVal(eddismax, Key, dismax, 6,3);
end;

procedure TsetEnvel.cbxbetamaxClick(Sender: TObject);
begin
  sbetamax:=cbxbetamax.checked;
  edbetmax.enabled:=sbetamax;
  eddismax.enabled:=sbetamax;
end;

procedure TsetEnvel.chk_bfieldfixClick(Sender: TObject);
begin
  sbfieldmax:=chk_bfieldfix.checked;
  ed_bfieldmax.enabled:=sbfieldmax;
  ed_bfieldmin.enabled:=sbfieldmax;
end;


procedure TsetEnvel.Exit;
begin
  if SetEnvel<>nil then Close;
//  SetEnvel:=nil;
end;

procedure TsetEnvel.rbu_dispChange(Sender: TObject);
begin
  ShowDisp:=1;
  PlotBeta;
end;

procedure TsetEnvel.rbu_orbiChange(Sender: TObject);
begin
  ShowDisp:=2;
  PlotBeta;
end;

procedure TsetEnvel.rbu_cdetChange(Sender: TObject);
begin
  ShowDisp:=3;
  PlotBeta;
end;

end.
