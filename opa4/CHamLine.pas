unit CHamLine;

//{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, OPAglobal, ASaux, ChromLib, ChromGUILib2;


type

  { TCHam }

  TCHam = class(TFrame)
    LabName: TLabel;
    LabVal: TLabel;
    EdTarg: TEdit;
    ButMinus: TButton;
    ButPlus: TButton;
    EdWeight: TEdit;
    PanBar: TPaintBox;
    procedure PanBarPaint(Sender: TObject);
    procedure ButMinusClick(Sender: TObject);
    procedure ButPlusClick(Sender: TObject);
    procedure EdWeightKeyPress(Sender: TObject; var Key: Char);
    procedure EdWeightExit(Sender: TObject);
    procedure EdTargKeyPress(Sender: TObject; var Key: Char);
    procedure EdTargExit(Sender: TObject);
  private
    oldplotr, plotr: real;
    valmax: double;
    target, weight: real;
    iham: integer;
    PanBarHmid: integer;
    PlotColor, MyColor: TColor;
    CH_Handle: array[0..nCHamilton-1] of TCHam;
    LabPen_handle: TLabel;
//    osvd_act_handle: TCheckBox;
    procedure PlotBar;
  public
    procedure Init(i: integer; lp:TLabel);
    procedure Brothers(ch: array of TCHam);
    procedure SetSize(aleft, atop, awidth, aheight: integer);
    procedure SetLab(s: String);
    procedure UpdateHam;
    procedure SetValmax(x: double);
    procedure gettabs(var t,v,w: integer);
    procedure MinInclude(minact: boolean);
    procedure mySetColor(col: TColor);
    procedure SetWeight(kv: real);
    procedure UpdateWeight (kv: real);
    procedure SetTarget( kv: real);
    procedure UpdateTarget (kv: real);
    procedure getChromSexHandles(s1, s2: TFrame);
    procedure passOctupoleHandle(oct: TFrame);
  end;

implementation

// use csexline here in implementation to avoid reference cross over
uses
  CSexLine;

{$R *.lfm}

const
  hmaxi=24;
  xspace=4;
  yspace=2;
// relative spacing of components
  rLabName=0.12;
  rLabVal =0.10;
  rEdTarg =0.12;
  rPanBar =0.3;
  rEdWeight=0.08;

var
  ChromSex_Handles: array[0..1] of TCSex;
  Octupole_Handles: array of TCSex;

// pass handles via "as" since TCSex is not known at
// compile time and must not appear in interface
procedure TCHam.getChromSexHandles(s1, s2: TFrame);
begin
  ChromSex_Handles[0]:= s1 as TCSex;
  ChromSex_Handles[1]:= s2 as TCSex;
end;

procedure TCHam.passOctupoleHandle(oct: TFrame);
begin
  setlength(Octupole_Handles, Length(Octupole_Handles)+1);
  Octupole_Handles[High(Octupole_Handles)]:=oct as TCSex;
end;

procedure TCHam.Init(i: integer; lp: TLabel);
begin
  iham:=i;
  valmax:=1.0;
  EdTarg.Visible:=not HamResonant[iham];
//  LabVal.Caption:=FtoS(HamAbs[iham],7,2);
  SetWeight (1.0);
  target:=0;
  EdTarg.Text:=FtoS(target,6,2);
  HamTarg[iham]:=target;
  MinInclude(true);
  if iham in [0,1,10,11,23,24] then begin
    MyColor:=clLightYellow;
    PlotColor:=ChromActiveColor;
  end else begin
    MyColor:=clWhite;
    PlotColor:=clLime;
  end;
  mysetColor(MyColor);
  LabPen_handle:=lp;
  OctuPole_Handles:=nil;
end;

procedure TCHam.Brothers(ch: array of TCHam);
var
  i: integer;
begin
// include me, to have same indices
  for i:=0 to nCHamilton-1 do  CH_handle[i]:=ch[i];
end;

//--------------------------------------------------------------------

procedure TCHam.SetSize(aleft, atop, awidth, aheight: integer);
var
  x, w, wed, wla, xspc, ah, h, t, fs : integer;
  rsum: real;
begin
  h:=aheight-2*yspace;
  if h>hmaxi then h:=hmaxi;
  ah:=h+2*yspace;
  SetBounds(aleft, atop, awidth, ah);
  t:=yspace;
  xspc:=awidth-ButMinus.width-ButPlus.Width-9*xspace;
  rsum:=(rLabName+rLabVal+rEdTarg+rPanBar+rEdWeight);
  x:=xspace;
  if HamResonant[iham] then begin
    wla:=round((rLabName+rEdTarg)/rsum*xspc);
    wed:=0;
  end else begin
    wla:= round(rLabName/rsum*xspc);
    wed:= round(rEdTarg/rsum*xspc);
  end;
  LabName.SetBounds(x,t,wla,h);
  Inc(x,wla+xspace);
  EdTarg.SetBounds(x,t,wed,h);
  Inc(x,wed+xspace);
  w:= round(rLabVal/rsum*xspc);
  LabVal.SetBounds(x,t,w,h);
  Inc(x,w+xspace); w:= round(rPanBar/rsum*xspc);
  PanBar.SetBounds(x,t,w,h);
  Inc(x,w+xspace);
  ButMinus.Left:=x; ButMinus.Top:=(ah-ButMinus.height) div 2;
  Inc(x, xspace+ButMinus.Width);
  w:=round(rEdWeight/rsum*xspc);
  EdWeight.SetBounds(x,t,w,h);
  Inc(x,w+xspace);
  ButPlus.Left:=x; ButPlus.Top:=(ah-ButPlus.height) div 2;
  fs:=12;
  if (aheight<20) or (awidth<600) then fs:=10;
  if (aheight<18) or (awidth<500) then fs:=8;
  LabName.Font.Size :=fs;
  LabVal.Font.Size  :=fs;
  EdTarg.Font.Size  :=fs;
  EdWeight.Font.Size:=fs;
  PanBarHmid:=h div 2;
  PlotBar;
end;

//--------------------------------------------------------------------
procedure TCHam.mySetColor(col: TColor);
begin
  MyColor:=col;
  Color:=col;
end;

//--------------------------------------------------------------------

procedure TCHam.SetLab(s: string);
begin
  LabName.Caption:=s;
end;

//--------------------------------------------------------------------

procedure TCHam.SetValmax(x: double);
begin
  valmax:=x;
end;

//--------------------------------------------------------------------

procedure TCHam.UpDateHam;
begin
  LabVal.Caption:=FtoS( HamShow[iham],7,2);
  PlotBar;
end;

//--------------------------------------------------------------------

procedure TCHam.PlotBar;
begin
  plotr:=Abs(HamAbs[iham]/valmax);
  if plotr>1 then plotr:=1.05;
  plotr:=plotr*PanBar.width;
  with PanBar.Canvas do begin
//    writeln('plotbar ', iham,' ',plotr);
    MoveTo(-PanBarHmid,PanBarHmid);
    LineTo(round(oldplotr)-PanBarHmid, PanBarHmid);
    MoveTo(-PanBarHmid,PanBarHmid);
    LineTo(round(   plotr)-PanBarHmid, PanBarHmid);
//    Show;
  end;
  oldplotr:=plotr;

end;

//--------------------------------------------------------------------

procedure TCHam.PanBarPaint(Sender: TObject);
begin
  plotr:=Abs(HamAbs[iham]/valmax);
  if plotr>1 then oldplotr:=1.05;
  plotr:=plotr*PanBar.width;
  with PanBar.Canvas do begin
    brush.color:=clBlack;
    FillRect(Rect(0,0,width,height));
    pen.color:=PlotColor;
    pen.mode:=pmXor;
    pen.width:=PanBarHmid;
    MoveTo(-PanBarHmid,PanBarHmid);
    LineTo(round(   plotr)-PanBarHmid, PanBarHmid);
  end;
  oldplotr:=plotr;
end;

procedure TCHam.ButMinusClick(Sender: TObject);
begin
  weight:=weight-1.0;
  if weight<0.0 then weight:=0.0;
  UpDateWeight (weight);
end;

//---------------------------------------------------------

procedure TCHam.ButPlusClick(Sender: TObject);
begin
  weight:=weight+1.0;
  if weight>9 then weight:=9.0;
  UpdateWeight (weight);
end;

//---------------------------------------------------------

procedure TCHam.SetWeight(kv: real);
begin
  weight:=kv;
  EdWeight.Text:=FtoS(weight,3,1);
  if weight<0.1 then EdWeight.Color:=clBlack else
    EdWeight.Color:=dimcol(clRed, clNavy, weight/9.9);
  HamWeight[iham]:=weight;
end;

procedure TCHam.UpdateWeight(kv: real);
var
  i: integer;
//  p: double;
begin
  if kv > 9.9 then kv:=9.9;
  if kv < 0.0 then kv:=0.0;
  SetWeight(kv);
  LabPen_handle.Caption:=FloatToStrF(Penalty, ffexponent, 3, 2);
  UpDateHam;
  for i:=0 to nCHamilton-1 do begin
    CH_Handle[i].SetValmax(HamAbsMax);
    CH_Handle[i].PlotBar;
  end;
  if osvd_enable then begin
    Oct_svdcmp(true);
    OSVD_Wfilter; // use same number of Weight factors as before, includes osvd_status
    if osvd_active then begin
      Oct_SVBKSB;
      for i:=0 to High(Octupole_Handles) do Octupole_Handles[i].SetVal;
      Driveterms;
      {p:=} Penalty; //penalty performs internal updates
      // update all the octupole hamiltonians
      for i:=10 to nCHamilton-1 do begin
       CH_Handle[i].SetValmax(HamAbsMax);
       CH_handle[i].UpdateHam;
      end;
      TDiagPlot;
    end;
  end;
end;

//---------------------------------------------------------

procedure TCHam.EdWeightKeyPress(Sender: TObject; var Key: Char);
var
  kvold, kv: real;
begin
  kvold:=weight;
  kv:=weight;
  if TEKeyVal(EdWeight, Key, kv, 3,1) then begin
    if Key=#0 then UpdateWeight(kv);
  end else UpdateWeight(kvold);
end;

//--------------------------------------------------------

procedure TCHam.EdWeightExit(Sender: TObject);
var
  kv: real;
begin
  if TEReadVal(EdWeight, kv, 3,1) then UpdateWeight(kv) else UpdateWeight(weight);
end;

//---------------------------------------------------------

procedure TCHam.SetTarget(kv: real);
begin
  target:=kv;
  EdTarg.Text:=FtoS(target,6,2);
  HamTarg[iham]:=target;
end;

procedure TCHam.UpdateTarget(kv: real);
var
  i: integer;
  p: double;
begin
  if kv<>target then begin
    SetTarget(kv);
//one of the chromaticity target values has been changed:
    if ((iham=0) or (iham=1)) and AutoChrom then begin
      ChromCorrect;
      Driveterms;
      p:=Penalty;
      // update all the hamiltonians
      for i:=0 to nCHamilton-1 do begin
       CH_Handle[i].SetValmax(HamAbsMax);
       CH_handle[i].UpdateHam;
      end;
      // update the two chromatic sextupole families
      for i:=0 to 1 do ChromSex_Handles[i].SetVal;
    end else if osvd_active then begin
      Oct_SVBKSB;
      for i:=0 to High(Octupole_Handles) do Octupole_Handles[i].SetVal;
      Driveterms;
      p:=Penalty;
      // update all the octupole hamiltonians
      for i:=10 to nCHamilton-1 do begin
       CH_Handle[i].SetValmax(HamAbsMax);
       CH_handle[i].UpdateHam;
      end;
    end else begin
      // update only me
      UpDateHam;
      p:=Penalty;
      for i:=0 to nCHamilton-1 do begin
        CH_Handle[i].SetValmax(HamAbsMax);
        CH_Handle[i].PlotBar;
      end;
    end;
    TDiagPlot;
    LabPen_handle.Caption:=FloatToStrF(p, ffexponent, 3, 2);
  end;
end;

// ---------------------------------------------------------

procedure TCHam.EdTargKeyPress(Sender: TObject; var Key: Char);
var
  kvold, kv: real;
begin
  kvold:=target;
  kv:=target;
  if TEKeyVal(EdTarg, Key, kv, 6,2) then begin
    if Key=#0 then UpdateTarget(kv);
  end else UpdateTarget(kvold);
end;

//----------------------------------------------------------------

procedure TCHam.EdTargExit(Sender: TObject);
var
  kv: real;
begin
  if TEReadVal(EdTarg, kv, 6,2) then UpdateTarget(kv) else UpdateTarget(target);
end;

// -----------------------------------------------------------------------


procedure TCHam.MinInclude(minact: boolean);
begin
//  EdTarg.Enabled   :=minact;
  EdWeight.Enabled :=minact;
  ButMinus.Enabled :=minact;
  ButPlus.Enabled  :=minact;
  if minact then Color:=MyColor else Color:=clGray;
  // make Labval and PanBar invisible DURING minimization, not now (if minact=false)
end;

//----------------------------------------------------------------

procedure TCHam.gettabs(var t,v,w: integer);
begin
  t:=EdTarg.Left;
  v:=LabVal.Left;
  w:=EdWeight.Left;
end;

end.
