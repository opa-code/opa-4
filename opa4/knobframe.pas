unit knobframe;

// {$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Controls, Graphics,Forms, Dialogs,
  StdCtrls, ExtCtrls, globlib, ASaux, linoplib, mathlib, math;

type
  Tknob = class(TFrame)
    Bevel1: TBevel;
    LabNam: TLabel;
    butres: TButton;
    editK: TEdit;
    LabK: TLabel;
    slider: TScrollBar;
    editmin: TEdit;
    editmax: TEdit;
    butfree: TButton;
    butwid: TButton;
    butnar: TButton;
    compar: TComboBox;
    procedure editKKeyPress(Sender: TObject; var Key: Char);
    procedure editminKeyPress(Sender: TObject; var Key: Char);
    procedure editmaxKeyPress(Sender: TObject; var Key: Char);
    procedure butresClick(Sender: TObject);
    procedure sliderScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure butfreeClick(Sender: TObject);
    procedure butwidClick(Sender: TObject);
    procedure butnarClick(Sender: TObject);
  private
    Elsave: ElementType;
    Varsave: Variable_Type;
    jvar, jella, mynumber: integer; //mynumber is number N of knob named kn_N (1..9)
    kv, kvsave, kvmin, kvmax, kfactor: Real;
    brother: array of TKnob;
    pwhandle: TpaintBox;
    procedure Action;
    procedure SetKRange;
  public
    procedure Init(i:integer);
    procedure KUpdate(kvnew:real; act:boolean);
    procedure SetSize(aleft, atop, awidth, aheight: integer);
    procedure Load(j: integer; pw: TPaintBox);
    procedure Loadvar(j: integer; pw: TPaintBox);
    procedure UnLoad;
    function getella: integer;
    function getvar: integer;
    procedure Brotherhandles(knarr: array of TKnob);
  end;

implementation

{$R *.lfm}

procedure TKnob.Brotherhandles(knarr: array of TKnob);
var
  k: integer;
begin
  brother:=nil;
  setlength(brother, Length(knarr));
  for k:=0 to High(knarr) do begin
    brother[k]:=knarr[k];
  end;
end;

function TKnob.getElla: integer;
begin
  getElla:=jella;
end;

function TKnob.getVar: integer;
begin
  getVar:=jvar;
end;


procedure TKnob.Init(i: integer);
begin
  mynumber:=i;
  self.name:='kn_'+IntToStr(i);
  self.labNam.caption:='Knob '+inttostr(i);
  jella:=-1;
  jvar :=-1;
end;

procedure TKnob.SetSize( aleft, atop, awidth, aheight: integer);
const
  hspace=8; butw=34; buth=24; editwid=100; edithgt=24;
  slhgt=12; editmmhgt=16;  editmmwid=40; xfrsize=16;
  knwid=17;
var
  vspace, vpos: integer;
begin
// automatic sizing of frame
  SetBounds(aleft, atop, awidth, aheight);
  bevel1.setBounds(0,0,awidth, aheight);
  vspace:=(aheight - (edithgt + buth + slhgt + editmmhgt)) div 5;
  vpos:=vspace;
  labNam.left:=hspace; labNam.top:=vpos;
//  buted.setbounds (awidth-3*hspace-2*butwid-xfrsize,vpos, butwid, buthgt);
  butres.setbounds( awidth-2*hspace-butw-xfrsize, vpos, butw, buth);
  butfree.setbounds( awidth-hspace-xfrsize, vpos, xfrsize, xfrsize);
  inc(vpos,vspace+buth);
  labK.left:=hspace; labK.top:=vpos;
  editK.setBounds(awidth-hspace-editwid, vpos, editwid, edithgt);
  comPar.setBounds(hspace,vpos,awidth-3*hspace-editwid, edithgt);
  inc(vpos,vspace+edithgt);
  slider.setBounds(hspace,vpos, awidth-2*hspace,slhgt);
  inc(vpos,vspace+slhgt);
  editmin.setbounds(hspace, vpos, editmmwid, editmmhgt);
  editmax.setbounds(awidth-(hspace+editmmwid), vpos, editmmwid, editmmhgt);
  butnar.setbounds(awidth div 2 +knwid+2, vpos, knwid, editmmhgt);
  butwid.setbounds(awidth div 2 -knwid-2, vpos, knwid, editmmhgt);
end;

procedure TKnob.Load(j: integer; pw: TPaintBox);
// later: get min/max for magnet type
const
  kmin=-5.0; kmax= 5.0;
var
 // kv: real;
  s: string;
  nolock: boolean;
begin

{
  for i:=0 to High(Variable) do Variable[i].use:=false;
  Elem_Eval(j);
  s:=Elem[j].nam+' depends on';
  for i:=0 to High(Variable) do if Variable[i].use then s:=s+' '+Variable[i].nam;
  opaMessage(0,s);
// some time in future... fill combobox with all available parameters
  with ComPar do begin
    Clear;
    Text:='select!' ;
    for i:=0 to High(Variable) do if Variable[i].use then index:=Items.Add(Variable[i].nam);
  end;
}

  s:=strkparam[Ella[j].cod];

  Ella[j].Tag:=mynumber;
  if jella > -1 then Ella[jella].Tag:=-1; //untag an elem that was connected before
  if jvar > -1 then Variable[jvar].Tag:=-1;
  jvar :=-1;
  if s<>'' then with Ella[j] do begin
    nolock:=true;
    case cod of
      cdrif: nolock:=(  l_exp = nil);
      cquad: nolock:=( kq_exp = nil);
      cbend: nolock:=( kb_exp = nil);
      ccomb: nolock:=(ckq_exp = nil);
      crota: nolock:=(rot_exp = nil);
      else
    end;
    LabNam.Color:=ElemCol[cod];
    LabNam.Font.Color:=ElemTextCol[cod];
    jella:= j;
    pwhandle:=pw;
    Elsave:=Ella[jella];
    LabNam.caption:=' '+Elsave.nam+' ';
    LabK.caption:=s;
    kv:=  getKval(jella,0);
    kvsave:=kv;
    editK.text:=FtoSv(getKval(jella,0),7,3);
//opamessage(0,'load   edit k '+ftos(kv,10,5));
    kvmin:=kmin; kvmax:=kmax;
    if abs(kv)>1e-6 then begin
      kvmax:=RoundUp(abs(2*kv)); kvmin:=-kvmax;
    end;
    if Ella[j].cod=cdrif then kvmin:=0.0;
    SetKRange;
    if nolock then begin
      slider.enabled:=true;
      editK.enabled:=true;
      editmin.enabled:=true;
      editmax.enabled:=true;
      butres.enabled:=true;
    end else begin
      slider.enabled:=false;
      editK.enabled:=false;
      editmin.enabled:=false;
      editmax.enabled:=false;
      butres.enabled:=false;
    end;
    butfree.enabled:=true;
  end;
end;

procedure TKnob.Loadvar(j: integer; pw: TPaintBox);
// later: get min/max for magnet type
const
  kmin=-5.0; kmax= 5.0;
var
 // kv: real;
  nolock: boolean;
begin

  Variable[j].Tag:=mynumber;
  if jella > -1 then Ella[jella].Tag:=-1; //untag an elem that was connected before
  if jvar > -1 then Variable[jvar].Tag:=-1;
  jella:=-1;
  jvar:=j;
  nolock:=Variable[jvar].exp = '';
  pwhandle:=pw;
  Varsave:=Variable[jvar];
  LabNam.caption:=' '+Varsave.nam+' ';
  LabK.caption:='';
  kv:=  Variable[jvar].val;
  kvsave:=kv;
  editK.text:=FtoSv(kv,7,3);
//opamessage(0,'load   edit k '+ftos(kv,10,5));
  kvmin:=kmin; kvmax:=kmax;
  if abs(kv)>1e-6 then begin
    kvmax:=RoundUp(abs(2*kv)); kvmin:=-kvmax;
  end;
  SetKRange;
  if nolock then begin
    slider.enabled:=true;
    editK.enabled:=true;
    editmin.enabled:=true;
    editmax.enabled:=true;
    butres.enabled:=true;
    LabNam.Color:=clYellow;
    LabNam.Font.Color:=clBlack;
  end else begin
    slider.enabled:=false;
    editK.enabled:=false;
    editmin.enabled:=false;
    editmax.enabled:=false;
    butres.enabled:=false;
    LabNam.Color:=clLightYellow;
    LabNam.Font.Color:=clGray;
  end;
  butfree.enabled:=true;

end;

procedure TKnob.Action;
var
  j, k: integer;
//  otherKnob: TKnob;
  errvar: boolean;
  varstr: string;
begin
  if jella > -1 then begin
    putkval(kv, jella,0);
    if OOMode then begin
      OrbitReCalc;
      PlotOrbit;
    end else begin
      OpticReCalc;
      if Ella[jella].cod=cdrif then pwhandle.repaint else
      case OpticPlotMode of MagPlot: PLotMag;   EnvPlot: PlotEnv;  else PlotBeta; end;
    end
  end;

  if jvar > -1 then begin
    Variable[jvar].val:=kv;
    if OOMode then begin //?

    end else begin
      for j:=1 to Glob.NElla do Ella_Eval(j); // not very efficient to evaluate all elements when one variable is changed...
      for k:=0 to High(brother) do begin
        if brother[k].jella > -1 then brother[k].KupDate(getkval(brother[k].jella,0),false);
//        if brother[k].jvar > -1  then brother[k].KupDate(Variable[brother[k].jvar].val,false);
        if brother[k].jvar > -1  then begin
          varstr:= Variable[brother[k].jvar].exp;
          if varstr=''
            then brother[k].KupDate(         Variable[brother[k].jvar].val,false)
            else brother[k].KupDate(Eval_Exp(Variable[brother[k].jvar].exp, errvar),false);
//        opamessage(0,Variable[brother[k].jvar].exp);
          if errvar then opaLog(1,' error in Knob update: '+Get_Eval_exp_errmess);
        end;
      end;
      OpticReCalc;
      pwhandle.repaint;
    end;
  end;
end;

procedure Tknob.sliderScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
var kvold: real;
begin
{  case ScrollCode of
// bigger steps when using arrows:
    scLineUp:   ScrollPos:=ScrollPos-99;
    scLineDown: ScrollPos:=ScrollPos+99;
  end;
}
  kvold:=kv;
  kv:=ScrollPos/kfactor;
  editK.text:=FtoSv(kv,7,3);
  if kv <> kvold then action;
end;

procedure Tknob.Kupdate(kvnew:real; act:boolean);
var
  kvold, dkv: real;
begin
  kvold:=kv;
  kv:=kvnew;
//  writeln(kvold, kvnew);
// adjust min/max if input value exceeds range:
  if kv > kvmax then begin
    dkv:=(kvmax-kvmin)/2;
    repeat kvmax:=kvmax+dkv until kvmax>kv;
    editMax.Text:=FtoSv(kvmax,5,1);
    Slider.Max:=round(kfactor*kvmax);
  end;
  if kv < kvmin then begin
    dkv:=(kvmax-kvmin)/2;
    repeat kvmin:=kvmin-dkv until kvmin<kv;
    editMin.Text:=FtoSv(kvmin,5,1);
    Slider.Min:=round(kfactor*kvmin);
  end;
  Slider.position:=round(kfactor*kv);
//act true when called from keypress, false from matching or brother
  if (kv <> kvold) and act then Action else begin
    editK.Text:=FtoSv(kv,7,3);
//opamessage(0,'kupdate edit k '+ftos(kv,10,5));
  end;
end;

procedure Tknob.editKKeyPress(Sender: TObject; var Key: Char);
var kvnew: Real;
begin
  if TEKeyVal(editK, Key, kvnew, 7,4) then KUpdate(kvnew, true);
end;

procedure Tknob.editminKeyPress(Sender: TObject; var Key: Char);
begin
  if TEKeyVal(editmin, Key, kvmin, 5,1) then SetKRange;
end;

procedure Tknob.editmaxKeyPress(Sender: TObject; var Key: Char);
begin
  if TEKeyVal(editmax, Key, kvmax, 5,1) then SetKRange;
end;

procedure Tknob.butresClick(Sender: TObject);
begin
  kv:=kvsave;
  if jella > -1 then begin
    putkval(kv, jella,0);
    Ella[jella]:=ElSave;
  end;
  if jvar > -1 then begin
    Variable[jvar].val:=kv;
    Variable[jvar]:=Varsave;
  end;
  editK.text:=FtoSv(kv,7,3);
//opamessage(0,'butres edit k '+ftos(kv,10,5));
  slider.position:=round(kfactor*kv);
  action;
end;

procedure TKnob.UnLoad;
begin
    LabNam.caption:='Knob '+inttostr(mynumber);
    if jella > -1 then begin
      Ella[jella].Tag:=-1;
      if OOMode then PlotOrbit; // will overplot
      jella:=-1;
    end;
    if jvar > -1 then begin
      Variable[jvar].Tag:=-1;
      jvar:=-1;
    end;
    LabK.caption:='LabK';
    editK.text:='editK';
    editmin.text:='min';
    editmax.text:='max';
    slider.enabled:=false;
    editK.enabled:=false;
    editmin.enabled:=false;
    editmax.enabled:=false;
    butfree.enabled:=false;
    butres.enabled:=false;
//    buted.enabled:=false;
    LabNam.Color:=clBtnFace;
    LabNam.Font.Color:=clBlack;

 end;

procedure Tknob.butfreeClick(Sender: TObject);
begin
  UnLoad;
end;

procedure Tknob.butwidClick(Sender: TObject);
begin
  kvmin:=2*kvmin; kvmax:=2*kvmax;
  setKrange;
end;

procedure Tknob.butnarClick(Sender: TObject);
begin
  kvmin:=0.5*kvmin; kvmax:=0.5*kvmax;
  SetKRange;
end;

procedure TKnob.setKRange;
var
  kmaxabs: real;
begin
  editmin.text:=FtoSv(kvmin,5,1);
  editmax.text:=FtoSv(kvmax,5,1);
  kmaxabs:=max(abs(kvmin), abs(kvmax));
  kfactor:=10000.0/kmaxabs;
  slider.setParams(round(kfactor*kv), round(kfactor*kvmin), round(kfactor*kvmax));
  slider.smallChange:=10; { 1% step}
  slider.largeChange:=100; {10% step}
end;

end.
