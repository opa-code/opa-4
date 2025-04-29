unit CSexLine;

//{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OPAglobal, ASaux, ChromLib, ChromGUILib1, ChromGUILib2, OPAChromaSVector;

type
  TCSex = class(TFrame)
    LabName: TLabel;
    EdVal: TEdit;
    Butmm: TButton;
    Butm: TButton;
    Butp: TButton;
    Butpp: TButton;
    Butres: TButton;
    Butoff: TButton;
    CheckLock: TCheckBox;
    procedure EdValKeyPress(Sender: TObject; var Key: Char);
    procedure EdValExit(Sender: TObject);
    procedure ButmClick(Sender: TObject);
    procedure ButmmClick(Sender: TObject);
    procedure ButpClick(Sender: TObject);
    procedure ButppClick(Sender: TObject);
    procedure ButresClick(Sender: TObject);
    procedure ButoffClick(Sender: TObject);
    procedure CheckLockClick(Sender: TObject);
  private
    i_am: integer; // 0,1,2 for sext, oct, quad
    myfam: integer; // index of family associated with this instance
    myval: real;   // local copy of value
    maxK, stepK: real;
//    myslice: real; //=1/slices; factor applied for display. intern used b3l/slice, display b3l
    mycolor: TColor;
    CS_handle: array of TCSex;          // the other sextupoles
    procedure UpdateVal (kv: real);     //update value with many consequences
    procedure LimitVal(kv: real);
    procedure OsvdStep;
  public
    procedure Init(typ, index: integer);
    procedure SetSize(aleft, atop, awidth, aheight: integer);
    procedure SetVal;
    procedure SetRange;
    procedure gettabs(var n,v,l: integer);
    procedure mySetColor(col: TColor);
    procedure UpdateValbyLoad(kv: real);
    procedure UpdateValbyMin(kv: real);
    procedure Lock;
    procedure UnLock;
    procedure ChromLock;
    procedure ChromUnLock;
    procedure Brothers(cs: array of TCSex; istart, icount: integer);
    function getFam: integer;
  end;

implementation

{$R *.lfm}

//?? uses  CHamLine;

const
  sext=0; octu=1; deca=2;
  wid_ed: array[0..2] of integer=(8,8,8);
  dec_ed: array[0..2] of integer=(3,2,1);
  hmaxi=24;
  xspace=4;
  yspace=1;
// relative spacing of components
  rLabName=0.18;
  rEdVal =0.24;

procedure TCSex.Init(typ, index: integer);
var
  i: integer;
begin
  i_am:=typ;
  myfam :=index;
  case i_am of
    sext: begin
      maxK:=maxSexK; stepK:=stepSexK;
      with SexFam[myfam] do begin
        CheckLock.Checked:=Locked;
        LabName.Color:=col;
        LabName.Caption :=' '+Ella[jel].nam; for i:=length(Ella[jel].nam) to 12 do LabName.Caption:=LabName.Caption+' ';
        SetVal;
      end;
    end;
    octu: begin
      Color:=oc_col;
      maxK:=maxOctK; stepK:=stepOctK;
      with OctuFam[myfam] do begin
        LabName.Color:=col;
        CheckLock.Checked:=Locked;
        LabName.Caption :=' '+Ella[jel].nam;
        SetVal;
      end;
    end;
    deca: begin
      Color:=de_col;
      maxK:=maxDecK; stepK:=stepDecK;
      with DecaFam[myfam] do begin
        LabName.Color:=col;
        CheckLock.Checked:=Locked;
        LabName.Caption :=' '+Ella[jel].nam;
        SetVal;
      end;
    end;
  end;
end;

// ------------------------------------------------------------------
// get handles to the other mpoles of same kind:

procedure TCSex.Brothers(cs: array of TCSex; istart, icount: integer);
var
  i: integer;
begin
// include me, to have same indices (-> autochrom!)
  setLength(CS_handle, icount);
  for i:=0 to icount-1 do  CS_handle[i]:=cs[i+istart];
end;

// ------------------------------------------------------------------

function TCSex.getFam: integer;
begin
  getFam:=myfam;
end;

// ------------------------------------------------------------------

procedure TCSex.SetSize(aleft, atop, awidth, aheight: integer);
var
  h, ah,t, x, xspc, w, fs: integer;
  rsum: Real;
begin
  h:=aheight-2*yspace;
  if h>hmaxi then h:=hmaxi;
  ah:=h+2*yspace;
  SetBounds(aleft, atop+(aheight-ah) div 2, awidth, ah);
  t:=yspace;
  x:=xspace;
  xspc:=awidth-Butmm.width-Butm.Width-Butp.Width-Butpp.Width
        -Butres.Width-Butoff.Width-CheckLock.Width-12*xspace;
  rsum:=(rLabName+rEdVal);
  w:= round(rLabName/rsum*xspc);
  LabName.SetBounds(x,(ah-h) div 2 +1,w,h-2);
  Inc(x,w+xspace);
  Butmm.Left:=x; Butmm.Top:=(ah-Butmm.height) div 2;
  Inc(x,Butmm.Width+xspace);
  Butm.Left:=x; Butm.Top:=(ah-Butm.height) div 2;
  Inc(x,Butm.Width+xspace);
  w:= round(rEdVal/rsum*xspc);
  EdVal.SetBounds(x,t,w,h);
  Inc(x,w+xspace);
  Butp.Left:=x; Butp.Top:=(ah-Butp.height) div 2;
  Inc(x,Butp.Width+xspace);
  Butpp.Left:=x; Butpp.Top:=(ah-Butpp.height) div 2;
  Inc(x,Butpp.Width+xspace);
  Butres.Left:=x; Butres.Top:=(ah-Butres.height) div 2;
  Inc(x,Butres.Width+xspace);
  Butoff.Left:=x; Butoff.Top:=(ah-Butoff.height) div 2;
  Inc(x,Butoff.Width+xspace);
  CheckLock.Left:=x; CheckLock.Top:=(ah-CheckLock.height) div 2;
  fs:=12;
  if (ah<24) or (awidth<350) then fs:=10;
  if (ah<20) or (awidth<250) then fs:=8;
  LabName.Font.Size :=fs;
  EdVal.Font.Size  :=fs;
end;

procedure TCSex.gettabs(var n,v,l: integer);
begin
  n:=LabName.Left;
  v:=EdVal.Left;
  l:=CheckLock.Left;
end;

//---------------------------------------------------
// set edit field etc. from SexFam but no action, display only

procedure TCSex.SetVal;
begin
//writeln('myval, myfam:', myval,'  ', myfam);
//  myval:=getSexkval(SexFam[myfam].jel);
  case i_am of
    sext: with SexFam[myfam] do myval:=ml*nslice;
    octu: with OctuFam[myfam] do myval:=b4L;
    deca: with DecaFam[myfam] do myval:=b5L;
  end;
//  LimitVal(myval); // limitval sets to max and would req to recalc hamiltonian
  if abs(myval) >  maxK then EdVal.Color:=clRed else EdVal.Color:=clwhite;
  EdVal.Text:=FtoS(myval,wid_ed[i_am],dec_ed[i_am]);
end;

//---------------------------------------------------

procedure TCSex.SetRange;
begin
  case i_am of
    sext: begin maxK:=maxSexK; stepK:=stepSexK; end;
    octu: begin maxK:=maxOctK; stepK:=stepOctK; end;
    deca: begin maxK:=maxDecK; stepK:=stepDecK; end;
  end;
  LimitVal(myval);
end;

//---------------------------------------------------
{show edit field in red and limit myval to maxK if it is too large}
procedure TCSex.LimitVal(kv: real);
begin
  if abs(kv) >  maxK then begin
    if kv>0 then myval:= maxK else myval:=-maxK;
    EdVal.Color:=clRed;
  end else begin
    myval:=kv;
    EdVal.Color:=clwhite;
  end;
  EdVal.Text:=FtoS(myval,wid_ed[i_am], dec_ed[i_am]);
end;

//---------------------------------------------------
{
 full update of value, only executed upon manual changes of value
 (buttons or edit field). IF value has changed:
 - check of value within range
 - write to family and element (-> this updates all kids)
 - if auto mode for chroma corr, a chroma corr is performed
   (the chroma sexts can NOT be subject to this proc, because all
    their potential senders are disabled!)
 - full calculation of driveterms
 - display of all hamiltonians
 - update the 'brothers': only the 2 chroma families can change if auto mode
}

procedure TCSex.OsvdStep;
var
  i: integer;
  P: double;
begin
  if osvd_active then begin
    DriveTerms_Qxx; DriveTerms_Cr2; DriveTerms_Oct;// driveterms may have changed
    Oct_SVBKSB; // this sets octupoles to new values
    for i:=Length(SexFam) to Length(SexFam)+High(OctuFam) do CS_handle[i].SetVal;
    DriveTerms;
    P:=Penalty;
    UpdateHamilton;
    UpdatePenalty(P);
//    UpdatePenalty;
  end;
end;

procedure TCSex.UpdateVal(kv: real);
var
  i: integer;
  P: double;
begin
  if kv <> myval then begin
    LimitVal(kv);
    case i_am of
      sext: begin
        UpDateSexFamInt(myfam, myval);
        if AutoChrom then begin
          ChromCorrect;
          for i:=0 to 1 do CS_handle[SFSDFlag[i]].SetVal;
        end;
        OsvdStep;
      end;
      octu: begin
        UpDateOctFamInt(myfam, myval);
      end;
      deca: begin
        DecaFam[myfam].b5L:=myval; PutKval(myval,DecaFam[myfam].jel,0);
      end;
    end;
    DriveTerms;
    P:=Penalty;
    UpdateHamilton;
    UpdatePenalty(P);
//    if (i_am=sext) and AutoChrom then for i:=0 to 1 do CS_handle[SFSDFlag[i]].SetVal;
    SVectorPlot.Star;
    TDiagPlot;
  end; // else nothing to do
end;

procedure TCSex.UpdateValbyLoad(kv: real);
var
  P: double;
begin
  myval:=kv;
  if abs(myval) >  maxK then EdVal.Color:=clRed else EdVal.Color:=clwhite;
  EdVal.Text:=FtoS(myval, wid_ed[i_am], dec_ed[i_am]);
  case i_am of
    sext: begin
      UpDateSexFamInt(myfam, myval);
    end;
    octu: begin
      UpDateOctFamInt(myfam, myval);
    end;
    deca: begin
      DecaFam[myfam].b5L:=myval; PutKval(myval,DecaFam[myfam].jel,0);
    end;
  end;
  DriveTerms;
  P:=Penalty;
  UpdateHamilton;
  UpdatePenalty(P);
  SVectorPlot.Star;
  TDiagPlot;
end;


procedure TCSex.UpdateValbyMin(kv: real);
begin
  if i_am=sext then begin
    myval:=kv;
    EdVal.Text:=FtoS(myval,wid_ed[i_am], dec_ed[i_am]);
    UpDateSexFamInt(myfam, myval);
  end;
end;


//---------------------------------------------------------

procedure TCSex.EdValKeyPress(Sender: TObject; var Key: Char);
var
  kv: real;
begin
  kv:=myval;
  if TEKeyVal(EdVal, Key, kv, wid_ed[i_am], dec_ed[i_am]) then begin
    if Key=#0 then UpdateVal(kv);
  end else UpdateVal(myval);
end;

//--------------------------------------------------------

procedure TCSex.EdValExit(Sender: TObject);
var
  kv: real;
begin
  kv:=myval;
  if TEReadVal(EdVal, kv, wid_ed[i_am], dec_ed[i_am]) then UpdateVal(kv) else UpdateVal(myval);
end;

//--------------------------------------------------------

procedure TCSex.ButmClick(Sender: TObject);
begin
  UpDateVal(myval-stepK);
end;

procedure TCSex.ButmmClick(Sender: TObject);
begin
  UpDateVal(myval-20*stepK);
end;

procedure TCSex.ButpClick(Sender: TObject);
begin
  UpDateVal(myval+stepK);
end;

procedure TCSex.ButppClick(Sender: TObject);
begin
  UpDateVal(myval+20*stepK);
end;

procedure TCSex.ButresClick(Sender: TObject);
begin
  case i_am of
    sext: UpDateVal(SexFam[myfam].ml0);
    octu: UpDateVal(OctuFam[myfam].b4L0);
    deca: UpDateVal(DecaFam[myfam].b5L0);
  end;
end;

procedure TCSex.ButoffClick(Sender: TObject);
begin
  UpDateVal(0.0);
end;

//--------------------------------------------------------

procedure TCSex.mySetColor(col: TColor);
begin
  MyColor:=col;
  Color:=col;
end;

procedure TCSex.Lock;
begin
  CheckLock.State:=cbChecked;
  Butm.Enabled:=False;
  Butmm.Enabled:=False;
  Butp.Enabled:=False;
  Butpp.Enabled:=False;
  Butres.Enabled:=False;
  Butoff.Enabled:=False;
  EdVal.Enabled:=False;
  case i_am of
    sext:  SexFam[myfam].locked:=True;
    octu: begin
      OctuFam[myfam].locked:=True;
      Oct_SVDCMP(false);
      OSVD_Status;
      OsvdStep;
    end;
    deca: DecaFam[myfam].locked:=True;
  end;
end;

procedure TCSex.UnLock;
begin
  CheckLock.State:=cbUnchecked;
  Butm.Enabled:=True;
  Butmm.Enabled:=True;
  Butp.Enabled:=True;
  Butpp.Enabled:=True;
  Butres.Enabled:=True;
  Butoff.Enabled:=True;
  EdVal.Enabled:=True;
  case i_am of
    sext:  SexFam[myfam].locked:=False;
    octu: begin
      OctuFam[myfam].locked:=False;
      Oct_SVDCMP(false);
      OSVD_Status;
      OsvdStep;
    end;
    deca: DecaFam[myfam].locked:=False;
  end;
end;

procedure TCSex.ChromLock;
begin
  CheckLock.Checked  :=True;
  CheckLock.Enabled  :=False;
end;

procedure TCSex.ChromUnLock;
begin
  CheckLock.Checked  :=False;
  CheckLock.Enabled  :=True;
end;

procedure TCSex.CheckLockClick(Sender: TObject);
begin
  if CheckLock.Checked then Lock else UnLock;
end;

end.
