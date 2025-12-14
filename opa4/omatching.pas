{
extended to 18 functions, incl. x,x' 13.8.2013                 

matching of max. 14 functions

061205 scenario save: 14 functions, 14 checkboxes, ini,mat,mid points and
knob check boxes
}


unit omatching;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, globlib, asaux, linoplib, Math, Grids, knobframe, omatchscan,
  asfigure;

type
  TMatch = class(TForm)
    inipoint: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    matpoint: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    midpoint: TComboBox;
    csel_1: TCheckBox;
    csel_2: TCheckBox;
    csel_3: TCheckBox;
    csel_4: TCheckBox;
    csel_5: TCheckBox;
    csel_6: TCheckBox;
    csel_9: TCheckBox;
    csel_10: TCheckBox;
    csel_11: TCheckBox;
    csel_12: TCheckBox;
    csel_13: TCheckBox;
    csel_14: TCheckBox;
    csel_15: TCheckBox;
    csel_16: TCheckBox;
    panvalacm: TPanel;
    panvaltgm: TPanel;
    panvalaci: TPanel;
    panvaltgi: TPanel;
    ed_1: TEdit;
    ed_2: TEdit;
    ed_3: TEdit;
    ed_4: TEdit;
    ed_5: TEdit;
    ed_6: TEdit;
    ed_9: TEdit;
    ed_10: TEdit;
    ed_11: TEdit;
    ed_12: TEdit;
    ed_13: TEdit;
    ed_14: TEdit;
    ed_15: TEdit;
    ed_16: TEdit;
    lab_1: TLabel;
    lab_2: TLabel;
    lab_3: TLabel;
    lab_4: TLabel;
    lab_5: TLabel;
    lab_6: TLabel;
    lab_9: TLabel;
    lab_10: TLabel;
    lab_11: TLabel;
    lab_12: TLabel;
    lab_13: TLabel;
    lab_14: TLabel;
    lab_15: TLabel;
    lab_16: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    pantuac: TPanel;
    pantutg: TPanel;
    slabini: TLabel;
    slabmat: TLabel;
    slabmid: TLabel;
    gobut: TButton;
    canbut: TButton;
    edfrac: TEdit;
    Label8: TLabel;
    edsteps: TEdit;
    Label9: TLabel;
    panknobs: TPanel;
    edprec: TEdit;
    labprec: TLabel;
    Label7: TLabel;
    Label10: TLabel;
    panmat: TPanel;
    labit0: TLabel;
    labit: TLabel;
    labdk0: TLabel;
    labdk: TLabel;
    bustop: TButton;
    gridmat: TStringGrid;
    labresult: TLabel;
    butshow: TButton;
    butacc: TButton;
    butres: TButton;
    butrty: TButton;
    clearbut: TButton;
    csel_7: TCheckBox;
    csel_8: TCheckBox;
    csel_17: TCheckBox;
    csel_18: TCheckBox;
    lab_7: TLabel;
    lab_8: TLabel;
    lab_17: TLabel;
    lab_18: TLabel;
    ed_7: TEdit;
    ed_8: TEdit;
    ed_17: TEdit;
    ed_18: TEdit;
    Scan: TButton;
    panfig: TPanel;
    Scanfig: TFigure;
    labkno: TLabel;
    labfun: TLabel;
    butknodo: TButton;
    butknoup: TButton;
    butfundo: TButton;
    butfunup: TButton;
    labknonam: TLabel;
    labfunnam: TLabel;
    butscaclo: TButton;
    butscawri: TButton;
    edfnam: TEdit;
    cbxIncBends: TCheckBox;
    perbut: TButton;
    procedure inipointChange(Sender: TObject);
    procedure matpointChange(Sender: TObject);
    procedure midpointChange(Sender: TObject);
    procedure cselClick(Sender: TObject);
    procedure KnobSelect(Sender: TObject);
    procedure edKeyPress(Sender: TObject; var Key: Char);
    procedure edstepsKeyPress(Sender: TObject; var Key: Char);
    procedure edfracKeyPress(Sender: TObject; var Key: Char);
    procedure edExit(Sender: TObject);
    procedure edstepsExit(Sender: TObject);
    procedure edfracExit(Sender: TObject);
    procedure canbutClick(Sender: TObject);
    procedure gobutClick(Sender: TObject);
    procedure edprecExit(Sender: TObject);
    procedure edprecKeyPress(Sender: TObject; var Key: Char);
    procedure bustopClick(Sender: TObject);
    procedure butaccClick(Sender: TObject);
    procedure butresClick(Sender: TObject);
    procedure butrtyClick(Sender: TObject);
    procedure butshowClick(Sender: TObject);
    procedure clearbutClick(Sender: TObject);
    procedure ScanClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure butfunupClick(Sender: TObject);
    procedure butfundoClick(Sender: TObject);
    procedure butscacloClick(Sender: TObject);
    procedure butscawriClick(Sender: TObject);
    procedure butknodoClick(Sender: TObject);
    procedure butknoupClick(Sender: TObject);
    procedure cbxIncBendsClick(Sender: TObject);
    procedure perbutClick(Sender: TObject);
 private
    pwhandle: TPaintBox;
    knarrhandle: array of TKnob;
    nomk: integer;
    ioma, joma: array[1..20] of integer;
    knobs: array[1..40] of Integer;
    funcs: array[1..nMatchFunc] of Integer;
    funcval: MatchFuncType;
    ModeFlag,iposmat, iposini, iposmid, koffmid: integer;
    nknobs, nactive, nfuncs, nselect: Integer;
    MaxIt: integer;
    Fraction, Precision: Real;
    defknob, stopiter, persymfail: Boolean;
    iscanloop, nscanloop, ishowf, ishowk: integer;
    showfk: boolean;
    FScan: array of Matchfunctype;
    ValScan, KScan: array of real;
    Statscan: array of integer;
    usedvar: array of boolean;

    function getEllaNam(j: integer): string;
    procedure enableGoBut;
    procedure Knoblist;
    procedure setinival(j: integer);
    procedure setmatval(j: integer);
    procedure settuneval;
    procedure setmidval(j: integer);
    procedure ReLoadMid;
    procedure Exit;
    procedure PerSymCalc;
    procedure Go;
    function  Step: Boolean;
    procedure Term;
    procedure showBetas;
    function  Mgetkval(j: integer): real;
    procedure Mputkval(k: real; j: integer);
    procedure MLimitKval(j:integer);
    procedure RestoreOld;
    procedure MakePlot;
  public
    procedure Load(pw:TPaintBox; knarr: array of TKnob);
  end;


var
  Match: TMatch;


implementation

{$R *.lfm}
// constants and variables used everywhere here but not outside this unit
const
  epsilon=1E-20;
  maxdim=12;
  maxknobs=20;
type
  BigMatrixType=   array[1..maxdim,1..maxdim] of real;
var
  NIteration: Integer;
  ddPrec, MinDDPrec: real;
  Singular, MatchFlag: Boolean;
  UnitMEE : BigMatrixType;
  OldKvalues, BestKvalues : array[1..maxknobs] of real;
  permultune: array[1..nMatchFunc] of integer;
  funcwid, funcdec: array[1..nMatchFunc] of integer;

{exit procedure, saves default values:
   values of matching functions
   function checkbox status, i.e. which were to be matched
   active knobs as they appeared in the list
   initial, final and intermediate matching locations in lattice
   parameters: steps, fraction, precision
}

function TMatch.getEllaNam(j: integer): string;
begin
  if j<1000 then getEllaNam:=Ella[j].nam else getEllaNam:=Variable[j mod 1000].nam;
end;

function TMatch.Mgetkval(j:integer):real;
begin
  if j<1000 then Mgetkval:=getkval(j,0) else Mgetkval:=Variable[j mod 1000].val;
end;

procedure TMatch.Mputkval(k: real; j: integer);
begin
  if j<1000 then putkval(k,j,0) else  Variable[j mod 1000].val:=k;
end;

procedure TMatch.MLimitKval(j:integer);
// avoid negative drifts - could be generalized to min/max values for all elements/vars as-3.11.15
begin
  if j<1000 then if (Ella[j].cod=cdrif) then if Ella[j].l<0 then Ella[j].l:=0;
end;



procedure TMatch.Exit;
var
  c:TCheckBox;
  i: integer;
begin
  for i:=1 to nfuncs do DefSet('match/'+MatchFuncName[i],funcval[i]);
  for i:=1 to nfuncs do begin
    c:=TCheckBox(FindComponent('csel_'+IntToStr(i)));
    if c.Checked then DefSet('match/c'+MatchFuncName[i],1)
                 else DefSet('match/c'+MatchFuncName[i],0);
  end;
  for i:=1 to nknobs do begin
    c:=TCheckBox(FindComponent('cknb_'+IntToStr(i)));
    if c.Checked then DefSet('match/kn_'+InttoStr(i),1)
                 else DefSet('match/kn_'+InttoStr(i),0);
  end;
  DefSet('match/iini',inipoint.ItemIndex);
  DefSet('match/imat',matpoint.ItemIndex);
  DefSet('match/imid',midpoint.ItemIndex+koffmid);
  DefSet('match/step', Maxit);
  DefSet('match/frac',Fraction);
  DefSet('match/prec',Precision);

  Close;
//  Match:=nil;
//  Release;
end;

{startup prodecure
  accepts handels to the plot (paintbox) and the knobs of opalinop to be able to update them
  looks for markers as ini/fin/mid matching points
  reads defaults for matching functions, matching functins active (checkboxes),
  and matching locations ins lattice; not the knobs, because these are not defined at start up
}

procedure TMatch.Load(pw:TPaintBox; knarr: array of TKnob);
var
  j, i, k: integer;
  fnd: boolean;
  ed: TEdit;
  csel: TCheckBox;
begin

  pwhandle:=pw;
  setlength(knarrhandle, length(knarr));
  for i:=0 to length(knarr)-1 do knarrhandle[i]:=knarr[i];
  nfuncs:=nMatchFunc;
  nselect:=0;
  nknobs:=0;
  nactive:=0;
  iposmid:=0;

  for i:=1 to nfuncs do begin  funcwid[i]:=7; funcdec[i]:=4; end;
  for i:=9 to 10 do begin  funcwid[i]:=10; funcdec[i]:=6; end;
  for i:=17 to 18 do begin  funcwid[i]:=10; funcdec[i]:=6; end;


  for i:=1 to nfuncs do funcval[i]:=FDefGet('match/'+MatchFuncName[i]);
  MaxIt    :=IDefGet('match/step');
  Fraction :=FDefGet('match/frac');
  Precision:=FDefGet('match/prec');

  {find all optics markers in the lattice and append to the comboboxes}
  {ignore repeated appearance of OMKs}


  for j:=1 to 20 do joma[j]:=-1;
  nomk:=0;
  for i:=1 to Glob.NLatt do begin
    j:=FindEl(i);
//    if (Ella[j].cod=comrk) or (Ella[j].cod=cundu) then begin --> nein, das wird bgzl. StoVar usw. kompliziert, lieber Undu splitten.
    if Ella[j].cod=comrk then begin
      fnd:=false;
      for k:=1 to nomk do fnd:=fnd or (joma[k]=j);
      if not fnd then begin
        inc(nomk);
        joma[nomk]:=j;
        ioma[nomk]:=i;
        inipoint.Items.Add(Ella[j].nam);
        matpoint.Items.Add(Ella[j].nam);
        midpoint.Items.Add(Ella[j].nam);
      end;
    end;
  end;

// default settings: initial to matching plus a midpoint if one was saved
// else: set start/end/none
// only if ini and matching are valid, allow automatic default setting of knobs
  defknob:=true;
{writeln(  IDefget('match/iini'),' iini ',inipoint.Items.Count);
for i:=0 to inipoint.Items.Count-1 do writeln(i,' ',inipoint.Items[i]);
writeln(  IDefget('match/imat'),' imat ',matpoint.Items.Count);
for i:=0 to matpoint.Items.Count-1 do writeln(i,' ',matpoint.Items[i]);
writeln(  IDefget('match/imid'),' imid ',midpoint.Items.Count);
for i:=0 to midpoint.Items.Count-1 do writeln(i,' ',midpoint.Items[i]);
}
  if IDefget('match/iini')<inipoint.Items.Count
    then inipoint.ItemIndex:=IDefget('match/iini')
    else begin inipoint.ItemIndex:=0; defknob:=false; end;
  if IDefget('match/imat')<matpoint.Items.Count
    then matpoint.ItemIndex:=IDefget('match/imat')
    else begin matpoint.ItemIndex:=1; defknob:=false; end;
  if IDefget('match/imid')<midpoint.Items.Count
    then midpoint.ItemIndex:=IDefget('match/imid')
    else midpoint.ItemIndex:=0;

// remember the use flags of the variables, they may be needed again in opalinop/knobframe (?)
  setlength(usedvar,Length(Variable));
  for i:=0 to High(Variable) do usedvar[i]:=Variable[i].use;

//these procs allocate the available knobs in the region between ini and mat point,
// default allocation of knobs is done in Knoblist proc
  setinival(inipoint.ItemIndex);
  setmatval(matpoint.ItemIndex);
  setmidval(midpoint.ItemIndex);

  for i:=1 to nfuncs do permultune[i]:=1;
  perbut.caption:='x1';

   settuneval;

   edsteps.text :=InttoStr(Maxit);
  edfrac.text  :=InttoStr(Round(Fraction*100));
  edprec.text  :=InttoStr(-Round(Log10(Precision)));
  for i:=1 to nfuncs do begin
    ed  :=TEdit(FindComponent('ed_'+IntToStr(i)));
    ed.Text:=FtoS(funcval[i]*permultune[i],funcwid[i],funcdec[i]);
  end;

  // restore last scenario: check all boxes from defaults
  nselect:=0;
  for i:=1 to nfuncs do begin
    csel:=TCheckBox(FindComponent('csel_'+IntToStr(i)));
    ed  :=TEdit(FindComponent('ed_'+IntToStr(i)));
    if (IDefGet('match/c'+MatchFuncName[i])=1) then begin
      Inc(nselect);
      csel.Checked:=True;
      funcs[nselect]:=csel.Tag;
      ed.Enabled:=True;
      ed.Visible:=True;
    end else begin
      ed.Enabled:=False;
      ed.Visible:=False;
    end;
    scanpar[i].nam:=csel.Caption;
  end;
  iscanloop:=-1;
  iscan:=-1;
  enableGoBut ;



  MomMode:=False;          //usesext ?
  OpticPlotMode:=BetPlot;
  {OpticCalc}

  ScanFig.parent:=panfig;
  ScanFig.assignScreen;
  ScanFig.setsize(10,10,panfig.width-20, 300);
end;



{
reload midpoint ONLY with markers which are BETWEEN
 initial and matching point: clear all entries & reload valid ones}
procedure TMatch.ReLoadMid;

var k: integer;
    flag: boolean;
begin
  for k:=midpoint.Items.Count-1 downto 1 do midpoint.Items.Delete(k);
  flag:=true;
  for k:=1 to nomk do begin
    if (ioma[k]-iposini)*(ioma[k]-iposmat)<0 then begin
      midpoint.Items.Add(Ella[joma[k]].nam);
      if flag then begin
        flag:=false;
        koffmid:=k-1;
      end;
    end
  end;
  midpoint.ItemIndex:=0;
  setMidval(0);
end;

{
build list and checkboxes of available knobs for matching
  if matching locations are like at startup, knobs are assigned according
  to default info (convenient for repeated matchings)
}
procedure TMatch.Knoblist;
const
  nkmax=100;
//  ctyp: array[1..7] of Integer=(cquad, csole, cbend, ccomb, cdrif, clong, ccorh);
  ctyp: array[1..5] of Integer=(cquad, csole, cbend, ccomb, cdrif);
//  cbtop0=38;
var
  jkn: array[1..100] of integer;
  ico, i, k, j, i1, i2: integer;
  cbtop, cbleft, hpan, wcol, dykn: integer;
  active, fnd: boolean;
  cknb:TCheckBox;
//  cbtopmax: integer;

begin
{delete all checkboxes}
  for i:=1 to nknobs do begin
    cknb:=TCheckBox(FindComponent('cknb_'+IntToStr(i)));
    cknb.Free;
  end;
  nknobs:=0;

  for i:=1 to 100 do jkn[i]:=-1; //init, to avoid accidental agreement
  for i:=0 to High(Variable) do Variable[i].use:=false;
  for ico:=1 to 5 do if (ico<>cbend) or cbxIncBends.Checked then begin
    if iposini<iposmat then begin
      i1:=iposini; i2:=iposmat;
    end else begin
      i2:=iposini; i1:=iposmat;
    end;
    for i:=i1 + 1 to i2 {-1} do begin //mod: include last element in line 301105
      j:=findel(i);
      Ella_Eval(j); //just to set the use flag of variable
      if  Ella[j].cod = ctyp[ico] then begin
        fnd:=false;
        for k:=1 to nknobs do fnd:=fnd or (jkn[k]=j);
        if not fnd then with Ella[j] do begin
          active:=true;
          case ctyp[ico] of
            cdrif: active:=(  l_exp = nil);
            cquad: active:=( kq_exp = nil);
            cbend: active:=( kb_exp = nil);
            ccomb: active:=(ckq_exp = nil);
            else
          end;
          if active then begin
            if nknobs<nkmax then Inc(nknobs);
            jkn[nknobs]:=j;
          end;
        end;
      end;
    end;
  end;
  {create checkboxes for elements:}
  for i:=0 to High(Variable) do with Variable[i] do if use and (exp='') then begin
    if nknobs<nkmax then Inc(nknobs);
    jkn[nknobs]:=i+1000;
  end;

// the use info of variable was only needed temporarily, restore to initial values:
  for i:=0 to High(Variable) do Variable[i].use:=usedvar[i];

  hpan:=panknobs.Height-40;
  wcol:=panknobs.Width div 4; //later, better resize...
  dykn:=32;
{  if 2 *((hpan) div dykn) < nknobs then begin
    if 3*((hpan) div dykn) < nknobs then begin
      dykn:=3*(hpan) div nknobs;
      wcol:=panknobs.Width div 3;
    end;
  end;
}
  cbtop:=40-dykn; cbleft:=10;
  for i:=1 to nknobs do begin
    j:=jkn[i];
    if (cbtop+dykn) > hpan then begin
      cbtop:=40;
      cbleft:=cbleft+wcol;
    end else cbtop:=cbtop+dykn;
    cknb:=TCheckBox(FindComponent('cknb_'+IntToStr(i)));
    if cknb = nil then begin
      cknb:=TCheckBox.Create(self);
      cknb.parent:=panknobs;
      cknb.name:= 'cknb_'+IntToStr(i);
      cknb.caption:=getEllaNam(j);
      cknb.Color:=clSilver;
      if j<1000 then cknb.Font.color:=ElemCol[Ella[j].cod] else cknb.Font.color:=clYellow;
      cknb.Tag:=j;
      cknb.setBounds(cbleft, cbtop, wcol-12, dykn-2);
      cknb.OnClick:=knobSelect;
    end;
  end;

// extra loop because change of "checked" property calls knobselect via onClick event
// (knobselect still runs nknobs times, unelegant...)
  for i:=1 to nknobs do begin
    cknb:=TCheckBox(FindComponent('cknb_'+IntToStr(i)));
    cknb.Checked := defknob and (IDefGet('match/kn_'+InttoStr(i))=1);
  end;
end;

{
 update knoblist if a knob checkbox was selected
}
procedure TMatch.knobSelect(Sender: TObject);
var
  i: integer;
  cknb: TCheckBox;
begin
  nactive:=0;
  for i:=1 to nknobs do begin
    cknb:=TCheckBox(FindComponent('cknb_'+IntToStr(i)));
    if cknb.Checked then begin
      Inc(nactive);
      knobs[nactive]:=cknb.Tag; { =element index}
    end;
  end;
  enableGoBut;
end;


procedure TMatch.setinival(j: integer);
var ipos: integer;
begin
  j:=inipoint.itemIndex;
  modeflag:=0;
  case j of
    0: ipos:=0; {initial}
    1: ipos:=Glob.NLatt; {final}
    2: begin ipos:=0; modeflag:=1; end; {periodic !}
    3: begin ipos:=0; modeflag:=2; end; {symmetric!}
    else ipos:=ioma[j-3];
  end;
  iposini:=ipos;
  slabini.caption:='S = '+FtoS(Opval[0,ipos].spos,6,2)+' m';
  if modeflag >0 then begin
    iposmat:=Glob.NLatt;
    slabmat.caption:='S = '+FtoS(Opval[0,iposmat].spos,6,2)+' m';
    matpoint.enabled:=false;
    if modeflag=2 then begin {alfa make no sense in symmetric ?????}
      csel_2.checked:=false; csel_4.checked:=false; csel_6.checked:=false;
      csel_2.enabled:=false; csel_4.enabled:=false; csel_6.enabled:=false;
    end else begin
      csel_2.enabled:=true;  csel_4.enabled:=true;  csel_6.enabled:=true;
    end;
  end else begin
    matpoint.enabled:=true;
  end;
  Knoblist;
end;

procedure TMatch.setmatval(j:integer);
var
  ipos: integer;
begin
  case j of
    0: ipos:=0; {initial}
    1: ipos:=Glob.NLatt;
    else ipos:=ioma[j-1];
  end;
  with Opval[0,ipos] do begin
    slabmat.caption:='S = '+FtoS(spos,6,2)+' m';
    lab_1.caption:=FtoS(beta,funcwid[1],funcdec[1])+' m';
    lab_2.caption:=FtoS(alfa,funcwid[2],funcdec[2]);
    lab_3.caption:=FtoS(betb,funcwid[3],funcdec[3])+' m';
    lab_4.caption:=FtoS(alfb,funcwid[4],funcdec[4]);
    lab_5.caption:=FtoS(disx,funcwid[5],funcdec[5])+' m';
    lab_6.caption:=FtoS(dipx,funcwid[6],funcdec[6]);
    lab_7.caption:=FtoS(orb[1]*1000,funcwid[7],funcdec[7])+' mm';
    lab_8.caption:=FtoS(orb[2]*1000,funcwid[8],funcdec[8])+' mrad';
  end;
  iposmat:=ipos;
  Knoblist;
end;

procedure TMatch.settuneval;
//needs setinival, setmatval to be called first to define iposini,mat
begin
  lab_9.caption :=FtoS((abs(Opval[0,iposini].phia-OpVal[0,iposmat].phia))*permultune[9],funcwid[9],funcdec[9]);
  lab_10.caption:=FtoS((abs(Opval[0,iposini].phib-OpVal[0,iposmat].phib))*permultune[10],funcwid[10],funcdec[10]);
  if iposmid > 0 then begin
    lab_17.caption :=FtoS((abs(Opval[0,iposini].phia-OpVal[0,iposmid].phia)),funcwid[9],funcdec[9]);
    lab_18.caption :=FtoS((abs(Opval[0,iposini].phib-OpVal[0,iposmid].phib)),funcwid[10],funcdec[10]);
  end;
end;


procedure TMatch.setmidval(j:integer);
var
  i: integer;
  csel: TCheckBox;
begin
  if j>0 then begin
    for i:=11 to 18 do begin
      csel:=TCheckBox(FindComponent('csel_'+IntToStr(i)));
      csel.Visible:=True;
{      csel.Checked:=False;}
    end;
    iposmid:=ioma[j+koffmid];
    with Opval[0,iposmid] do begin
      panvalaci.Visible:=True;
      panvaltgi.Visible:=True;
      slabmid.caption:='S = '+FtoS(spos,6,2)+' m';
      lab_11.caption:=FtoS(beta,funcwid[11],funcdec[11])+' m';
      lab_12.caption:=FtoS(alfa,funcwid[12],funcdec[12]);
      lab_13.caption:=FtoS(betb,funcwid[13],funcdec[13])+' m';
      lab_14.caption:=FtoS(alfb,funcwid[14],funcdec[14]);
      lab_15.caption:=FtoS(disx,funcwid[15],funcdec[15])+' m';
      lab_16.caption:=FtoS(dipx,funcwid[16],funcdec[16]);
      lab_17.caption:=FtoS(orb[1]*1000,funcwid[17],funcdec[17]);
      lab_18.caption:=FtoS(orb[2]*1000,funcwid[18],funcdec[18]);
    end;
  end else begin
    iposmid:=0;
    panvalaci.Visible:=False;
    panvaltgi.Visible:=False;
    for i:=11 to 18 do begin
      csel:=TCheckBox(FindComponent('csel_'+IntToStr(i)));
      csel.Visible:=False;
      csel.Checked:=False;
    end;
    slabmid.caption:='';
  end;
end;

procedure TMatch.inipointChange(Sender: TObject);
begin
  defknob:=false;
  setinival(inipoint.itemindex);
  settuneval;
  ReLoadMid;
end;

procedure TMatch.matpointChange(Sender: TObject);
begin
  defknob:=false;
  setmatval(matpoint.itemIndex);
  settuneval;
  ReLoadMid;
end;

procedure TMatch.midpointChange(Sender: TObject);
begin
  setmidval(midpoint.itemIndex);
  settuneval;
end;

procedure TMatch.cselClick(Sender: TObject);
var
  i: integer;
  csel: TCheckBox;
  ed:   TEdit;
begin
  nselect:=0;
  for i:=1 to nfuncs do begin
    csel:=TCheckBox(FindComponent('csel_'+IntToStr(i)));
    ed  :=TEdit(FindComponent('ed_'+IntToStr(i)));
    if csel.Checked then begin
      Inc(nselect);
      funcs[nselect]:=csel.Tag;
      ed.Enabled:=True;
      ed.Visible:=True;
    end else begin
      ed.Enabled:=False;
      ed.Visible:=False;
    end;
  end;
  enableGoBut ;
end;

procedure TMatch.enableGoBut;
begin
  goBut.Enabled:= (nselect>0) and (nactive >=nselect);
  Scan.Enabled:= (nselect>0) and (nactive >=nselect);
end;


procedure TMatch.edKeyPress(Sender: TObject; var Key: Char);
{allow only numeric input and check for valid format if the enter key is pressed}
var
  v: Real;
  ed: TEdit;
  var i: integer;
begin
   for i:=1 to nfuncs do begin
     ed  :=TEdit(FindComponent('ed_'+IntToStr(i)));
     if ed=Sender then  TEKeyVal(ed, Key, v, 7,4);
  end;
end;

procedure TMatch.edExit(Sender: TObject);
{check edit fields on exit if they contain a valid number}
var
  i: integer;
  v: Real;
  ed: TEdit;
begin
  for i:=1 to nfuncs do begin
    ed  :=TEdit(FindComponent('ed_'+IntToStr(i)));
    if ed=Sender then TEReadVal(ed,v,7,4);
  end;
end;

procedure TMatch.edstepsKeyPress(Sender: TObject; var Key: Char);
var
  x:real;
begin
  TEKeyVal(edsteps, Key, x, 4, 0);
end;

procedure TMatch.edfracKeyPress(Sender: TObject; var Key: Char);
var
  x:real;
begin
  TEKeyVal(edfrac, Key, x, 3, 0);
end;

procedure TMatch.edprecKeyPress(Sender: TObject; var Key: Char);
var
  x:real;
begin
  TEKeyVal(edprec, Key, x, 2, 0);
end;

procedure TMatch.edstepsExit(Sender: TObject);
var
  x:real;
begin
  TEReadVal(edsteps, x, 4, 0);
end;

procedure TMatch.edfracExit(Sender: TObject);
var
  x:real;
begin
  TEReadVal(edfrac, x, 3, 0);
end;

procedure TMatch.edprecExit(Sender: TObject);
var
  x:real;
begin
  TEReadVal(edprec, x, 2, 0);
end;

procedure TMatch.canbutClick(Sender: TObject);
begin
  Exit;
end;

procedure TMatch.gobutClick(Sender: TObject);
begin
  Go;
end;

procedure TMatch.Go;
var
  jel,k,i,j: integer;
  val: Real;
  ed: TEdit;

begin
  {read all the edit fields:}
  for k:=1 to nselect do begin
    i:=funcs[k];
//writeln(diagfil,'ed_'+IntToStr(i));
    ed  :=TEdit(FindComponent('ed_'+IntToStr(i)));
    val:=funcval[i]*permultune[i];
//writeln(diagfil,funcval[i]);
    if TEReadVal(ed,val,7,4) then funcval[i]:=val/permultune[i];
//writeln(diagfil, val);
  end;
  if TEReadVal(edsteps, val, 4, 0) then
    MaxIt:=Round(val);
  if TEReadVal(edfrac, val, 3, 0) then
    if (val>=1) and (val<=100) then Fraction:=val*0.01;
  edfrac.Text:=InttoStr(Round(100*fraction));
  if TEReadVal(edprec, val, 2, 0) then
    if (val>=2) and (val<=20) then Precision:=Power(10.0,-val);
  edprec.Text:=InttoStr(-Round(Log10(Precision)));

{hide knob panel, show matching panel, load grid:}
  panknobs.Visible:=False;
  panmat.Visible:=True;
  with gridmat do begin
    RowCount:=nactive;
    for i:=1 to ColCount-1 do ColWidths[i]:=Width div ColCount;
    ColWidths[0]:=Width-(ColCount-1)*ColWidths[1];
    for i:=0 to nactive-1 do begin
      jel:=knobs[i+1] mod 1000;
      if knobs[i+1]<1000 then  begin
        Cells[0,i]:=Ella[jel].nam;
        Cells[1,i]:=strkparam[Ella[jel].cod];
        Cells[2,i]:=FtoS(getkval(jel,0),6,3);
      end else begin
        Cells[0,i]:=Variable[jel].nam;
        Cells[1,i]:='';
        Cells[2,i]:=FtoS(Variable[jel].val,9,4);
      end;
    end;
    ClientHeight:=GridHeight;
    //ClientHeight:=RowCount*(RowHeights[0]+GridLineWidth);
  end;

  {12x12 unit matrix}
  for i:=1 to maxdim do for j:=1 to 12 do UnitMEE[i,j]:=0;
  for i:=1 to maxdim do UnitMEE[i,i]:=1;

  for i:=1 to nactive do begin
    BestKvalues[i]:=MGetkval(knobs[i]);
    OldKvalues[i]:=BestKvalues[i];
  end;

  {disable buttons to avoid additional launches of iteration due to
   processMessages}
  goBut.enabled:=false;
  canBut.enabled:=false;
  labresult.Font.Color:=clBlue;
  labresult.Caption:=' . . . running . . . '   ;


  NIteration:=0;
  MatchFlag:=False;
  PerSymfail:=False;
  MinDDPrec:=1E3;
  stopiter:=false;
  // repeat iterations until result is true for whatever reason
  repeat
    Application.ProcessMessages;
  until Step;
  Term;


  // only in case of retry button
  canBut.enabled:=true;
end;

procedure TMatch.bustopClick(Sender: TObject);
begin
  stopiter:=True;
end;


procedure TMatch.PerSymCalc;

Var      i, j : word;

begin
  for j:=1 to Glob.NElla do Ella_Eval(j);
  if ModeFlag >0 then begin
// writeln(diagfil,'.modeflag,match,persymfail:',modeflag,' ',matchflag, persymfail);
    OptInit;
    for i:=1 to Glob.NLatt do Lattel (i, j, 0, 0.0);
//  status.betas:=True;
    if ModeFlag=1 then Periodic(persymfail) else {2} Symmetric(persymfail);
    MatchFlag:=persymfail;
//writeln(diagfil,'*modeflag,match,persymfail:',modeflag,' ',matchflag, persymfail);

  end;
end;


function TMatch.Step;

const
  dE   =1E-7;

var
  Y, dK : array[1..maxdim] of real;
  FI, F1 : MatchFuncType;
  Q : array[1..maxdim] of integer;
  XX, MN, ML, MU: BigMatrixType;
  EM : array[1..maxdim,1..maxknobs] of real;
  stmp, Max, dQ, FF1 : real;
  Imax, i, j, k, p: Integer;

//  ts: string;
  dkcol: TColor;
  tempFlag: boolean;


begin
// start of one iteration

    ddPrec:=1.0;
    if nselect>1 then  begin
                              { Berechnung der Empfindlichkeits-Matrix }
//writeln(diagfil,'--- 1');
      PerSymCalc;
      FI:=MatchValues(iposini, iposmat, iposmid);
      F1:=FI;
      for p:=1 to nactive do begin
        dQ:=dE*Abs(Mgetkval(knobs[p]));
        if dQ=0 then dQ:=dE;
        MPutKval(Mgetkval(knobs[p])+dQ, knobs[p]);
//writeln(diagfil,'--- 2 ',p);
        PerSymCalc;
        FI:=MatchValues(iposini, iposmat, iposmid);
        for j:=1 to nselect do begin
          EM[j,p]:=(FI[funcs[j]]-F1[funcs[j]])/dQ;
        end;
        MPutKval(MGetKval(knobs[p])-dQ,knobs[p]);
      end;
{
writeln(diagfil,'------------------------------');
      for j:=1 to nselect do begin
        for p:=1 to nactive do write(diagfil,' ',EM[j,p]:8);
        writeln(diagfil);
      end;
writeln(diagfil,'------------------------------');
}
                               { Ermittlung der empfindlichsten Elemente }

{counting DOWN because intermed funcs are listed last, and may have
zeros in sens.matrix from quads BEHIND the intermed point!}
      for k:=nselect downto 1 do begin
        Max:=0;
        for i:=1 to nactive do if Abs(EM[k,i])>Max then begin
          Max:=Abs(EM[k,i]);
          Imax:=i;
        end;
        Q[k]:=knobs[Imax];
        for j:=1 to nselect do begin
          MN[j,k]:=EM[j,Imax];
          EM[j,Imax]:=0
        end;
      end;
      tempFlag:=false;                         { existiert eine Loesung ? }
      for j:=1 to nselect do begin
        stmp:=0;
        for i:=1 to nselect do stmp:=stmp+Abs(MN[j,i]);
        if stmp=0 then tempFlag:=true;          { Flag=true : keine Loesung }
      end;
      MatchFlag:=MatchFlag or tempFlag;

             {Test to avoid crash in ill-conditioned problems, as-100596}
      Singular:=False;
      for k:=1 to nselect do Singular:=Singular or (Abs(MN[k,k])<epsilon);
      MatchFlag:=MatchFlag or Singular;

      if not MatchFlag then begin              { LU-Zerlegung der Matrix }
        ML:=UnitMEE;
        for k:=1 to nselect-1 do begin
          XX:=UnitMEE;
          for i:=k+1 to nselect do begin
                  {division by zero error occured here at 120595, as}
            XX[i,k]:=-MN[i,k]/MN[k,k];
            ML[i,k]:=-XX[i,k];
          end;
          for i:=1 to nselect do for j:=1 to nselect do begin
            MU[i,j]:=0;
            for p:=1 to nselect do MU[i,j]:=MU[i,j]+XX[i,p]*MN[p,j];
          end;
          for i:=1 to nselect do for j:=1 to nselect do MN[i,j]:=MU[i,j];
        end;
                                     { Loesung der Matrizengleichung }

        Y[1]:=funcval[funcs[1]]-F1[funcs[1]];
        for i:=2 to nselect do begin
          stmp:=0;
          for p:=1 to i-1 do stmp:=stmp+ML[i,p]*Y[p];
          Y[i]:=funcval[funcs[i]]-F1[funcs[i]]-stmp;
        end;

        dK[nselect]:=Y[nselect]/MU[nselect,nselect];  {crash here in tune matching}
        for i:=nselect-1 downto 1 do begin
          stmp:=0;
          for p:=i+1 to nselect do stmp:=stmp+MU[i,p]*dK[p];
          dK[i]:=(Y[i]-stmp)/MU[i,i];
        end;
        ddPrec:=0;             { Berechnung des Iterationsfehlers }
        for i:=1 to nselect do ddPrec:=ddPrec+Sqr(dK[i]);
        ddPrec:=Sqrt(ddPrec)/nselect;
      end;
    end
    else begin
//writeln(diagfil,'--- 3');
      PerSymCalc;
      FI:=MatchValues(iposini, iposmat, iposmid);
      FF1:=FI[funcs[1]];
      for p:=1 to nactive do begin
        dQ:=dE*Abs(MGetKval(knobs[p]));
        if dQ=0 then dQ:=dE;
        MPutKval(MGetKval(knobs[p])+dQ,knobs[p]);
//writeln(diagfil,'--- 4 ',p);
        PerSymCalc;
        FI:=MatchValues(iposini, iposmat, iposmid);
        XX[1,p]:=(FI[funcs[1]]-FF1)/dQ;
        MPutKval(MGetKval(knobs[p])-dQ,knobs[p]);
      end;
      Max:=0;
      for i:=1 to nactive do if Abs(XX[1,i])>Max then begin
        Max:=Abs(XX[1,i]);
        Imax:=i;
      end;
      ddPrec:=(funcval[funcs[1]]-FF1)/XX[1,Imax];
    end;

    Inc(NIteration);
    labit.Caption:=InttoStr(NIteration);
    if (NIteration<=MaxIt) and not MatchFlag then begin
      if Abs(ddPrec)<MinDDPrec then begin
        dkcol:=clGreen;
        MinDDPrec:=Abs(ddPrec);
             {Parameter fuer Bestwert festhalten:    (as 010992)  }
        for i:=1 to nactive do begin
          BestKvalues[i]:=MGetKval(knobs[i]);
          if knobs[i]<1000 then gridmat.Cells[3,i-1]:=FtoS(BestKvalues[i],10,5)
                           else gridmat.Cells[3,i-1]:=FtoS(BestKvalues[i],10,5);
        end;

      end else dkcol:=clRed;
      labdk.font.color:=dkcol;
      labdk.caption:=FloattoStrF(ddPrec,ffexponent,2,2);


      if nselect>1 then begin                 {begin - end inserted   S.Adam}
        for i:=1 to nselect do begin               {begin - end ins., as 310892}
          MPutKval(MGetKval(Q[i])+Fraction*dK[i],Q[i]);
          MLimitKval(Q[i]);
        end;
      end else begin                    {begin - end inserted   S.Adam}
        MPutKval(MGetKval(knobs[Imax])+Fraction*ddPrec,knobs[Imax]);
        MLimitKval(knobs[Imax]);
      end;
    end;

    MatchFlag:=MatchFlag or stopiter;

    Step:= (Abs(ddPrec)<Precision) or (NIteration>MaxIt) or MatchFlag or (Abs(ddPrec)>1E3);
  end;

//--------------------------------------------


procedure TMatch.Term;

var
  mstat, i: integer;
  F: MatchFuncType;
  lab: TLabel;
  persymfailed: boolean;
//  s1, s2: string;
//  cb: TCheckBox;

  begin
  {Uebernahme der Bestwerte unabh. von Erfolg der Iteration: (as 010992) }
  for i:=1 to nactive do MPutKval(BestKvalues[i],knobs[i]);

// writeln(diagfil,'--- end');
// keep persym status since it may (will?) recover when setting back to best values:
  Persymfailed:=PerSymfail;
  PerSymCalc;
  F:=MatchValues(iposini, iposmat, iposmid);

  for i:=1 to nfuncs do begin     //????
    lab  :=TLabel(FindComponent('lab_'+IntToStr(i)));
    lab.caption:=FtoS(F[i]*permultune[i],funcwid[i],funcdec[i]);
  end;

  if Abs(ddPrec) < Precision then begin
    MatchFlag:=False;
    labresult.Font.Color:=clgreen;
    labresult.Caption:=' Successful termination';
    mstat:=0;
  end
  else begin
    labresult.Font.Color:=clred;
    if (NIteration>MaXIt) then begin labresult.Caption:= ' Iteration failed  '; mstat:=1; end
    else if PerSymfailed then begin labresult.Caption:='Periodic/symmetric solution lost '; mstat:=2; end
    else if Abs(ddPrec)>1E3 then begin labresult.Caption :=' Iteration ran off  '; mstat:=3; end
    else if stopiter then begin labresult.Caption:=' Iteration aborted  '; mstat:=4; end
    else if Singular then begin labresult.Caption:=' Singular sensitivity matrix  '; mstat:=5; end
    else begin labresult.Caption:=' Apparently a solution does not exist  '; mstat:=6; end;
  end;

// save scan results
  if iscanloop > -1 then begin
    for i:=1 to nfuncs do Fscan[iscanloop,i]:=F[i]; //2nd index for matchfunctype starts at 1
    for i:=1 to nactive do Kscan[iscanloop*nactive+i-1]:=BestKvalues[i];
    Statscan[iscanloop]:=mstat;
  end;

{highlight recommended button:}
  if MatchFlag then butres.Font.Color:=clGreen else butacc.Font.Color:=clGreen;
{recalculate the current optic that linoplib shows the correct thing}
    showBetas;

end;

procedure TMatch.showBetas;
var
  i,j:integer;
begin
// erase old curves, calculate new from ini position and plot
  ncurves:=0;
  for j:=1 to Glob.NElla do Ella_Eval(j);
  OpticCalc(iposini);
  pwhandle.repaint;
  for i:=1 to length(knarrhandle) do begin
    with knarrhandle[i-1] do begin
      for j:=1 to nactive do begin
//writeln(diagfil, getella, ' ',getvar, ' ',knobs[j],' ',j);
        if (getella=knobs[j]) or (getvar =knobs[j] mod 1000) then KUpdate(MGetkval(knobs[j]),false);
      end;
{      for j:=1 to nknobs do if (Tag>0) and (Tag=knobs[j]) then begin
        KUpDate(Mgetkval(Tag),false);
      end;
}
    end;
  end;
end;

procedure TMatch.ScanClick(Sender: TObject);
// scan a parameter and save results
var
  i: integer;
  c: TCheckBox;
  ed: TEdit;
//  val: real;
//  s1: string;

begin
    panfig.visible:=false;
    panknobs.visible:=true;
    for i:=1 to nfuncs do begin
    c:=TCheckBox(FindComponent('csel_'+IntToStr(i)));
    if c.Checked then begin
      with scanpar[i] do begin
        val:=funcval[i]*permultune[i];
        act:=true;
      end;
    end else scanpar[i].act:=false;
  end;
  if setMatchScan=nil then setMatchScan:= TsetMatchScan.Create(Application);
  setMatchScan.Load;
  try
    setMatchScan.ShowModal;
  finally
    FreeAndNil(setMatchScan);
  end;
  iscanloop:=-1; nscanloop:=0;
  Valscan:=nil; FScan:=nil; Kscan:=nil; statscan:=nil;
  if iscan > 0 then begin
// start the scan loop
    with scanpar[iscan] do begin
//      opamessage(0, 'func, min, max, stp ='+nam+'  '+ftos(minval,8,4)+'  '+ftos(maxval,8,4)+'  '+inttostr(nstep));
      setLength(Valscan, nstep);
      setLength(Fscan,nstep);
      setLength(Kscan,nstep*nactive);
      setLength(statscan,nstep);
      nscanloop:=nstep-1;
      iscanloop:=0;
      repeat
// write value of scan parameter into corresponding edit field
        valscan[iscanloop]:=minval+((maxval-minval)*iscanloop)/nscanloop;
        ed  :=TEdit(FindComponent('ed_'+IntToStr(iscan)));
        ed.Text:=FtoS(valscan[iscanloop], funcwid[iscan],funcdec[iscan]);
        Go;
        for i:=1 to nactive do MPutKval(OldKvalues[i],knobs[i]);// restore initial values like reset
        inc(iscanloop);
      until (iscanloop > nscanloop);
    end;
    RestoreOld;

// panknobs.visible:=False;
// panmat.visible:=False;
    panfig.visible:=True;
    ishowf:=iscan;
    ishowk:=1;
    showfk:=false;
    LabFunNam.Caption:=scanpar[ishowf].nam;
    LabKnoNam.Caption:='';
    MakePlot;
  end;

end;


procedure TMatch.butaccClick(Sender: TObject);
// accept the new data and close
begin
  Exit;
end;

procedure TMatch.butresClick(Sender: TObject);
// restore the old data and close
var i: integer;
begin
  for i:=1 to nactive do MPutKval(OldKvalues[i],knobs[i]);
  showBetas;
  Exit;
end;

procedure TMatch.restoreOld;
var i: integer;
begin
// reload old values and recalc optics
  for i:=1 to nactive do MPutKval(OldKvalues[i],knobs[i]);
  showBetas;
// set fields to data
//  setinival(inipoint.ItemIndex);
//  setmatval(matpoint.ItemIndex);
//  settuneval;
//  setmidval(midpoint.ItemIndex);
//make knob panel visible again
  panknobs.Visible:=True;
  panmat.Visible:=False;
  goBut.enabled:=true;
  scan.enabled:=true;
end;

procedure TMatch.butrtyClick(Sender: TObject);
// restore old data and prepare for another trial
begin
  RestoreOld;
end;

procedure TMatch.butshowClick(Sender: TObject);
begin
  {hide this window, instead show question }
   Visible:=False;
   if (MessageDlg('..seen it?', MtConfirmation, [mbOK],0) = mrOK) then begin
   end;
  Visible:=True;

end;

//reset all defaults that had been loaded
procedure TMatch.clearbutClick(Sender: TObject);
var
  i:integer;
  csel: TCheckBox;
  ed: TEdit;
begin
  defknob:=false;
  inipoint.ItemIndex:=0;
  matpoint.ItemIndex:=1;
  midpoint.ItemIndex:=0;
  setinival(inipoint.ItemIndex);
  setmatval(matpoint.ItemIndex);
  settuneval;
  setmidval(midpoint.ItemIndex);
  nselect:=0;
  for i:=1 to nfuncs do begin
    csel:=TCheckBox(FindComponent('csel_'+IntToStr(i)));
    ed  :=TEdit(FindComponent('ed_'+IntToStr(i)));
    csel.Checked:=false;
    ed.Enabled:=False;
    ed.Visible:=False;
  end;
  enableGoBut;
end;

procedure TMatch.makeplot;
var
  i: integer;
  ymin, ymax: real;
begin
  if iscan>0 then begin
    with ScanFig do begin
      plot.setcolor(clBlack);
      ymin:=1e10; ymax:=-1e10;
      if showfk then begin
        for i:=0 to nscanloop do begin
          if ymax < Kscan[i*nactive+ishowk-1] then ymax:=Kscan[i*nactive+ishowk-1];
          if ymin > Kscan[i*nactive+ishowk-1] then ymin:=Kscan[i*nactive+ishowk-1];
        end;
        Init(scanpar[iscan].minval,ymin,scanpar[iscan].maxval, ymax, 1, 1, scanpar[iscan].nam, getEllaNam(knobs[ishowk]), 3,false);
        with plot do begin
          SetSymbol (3, 2, clTeal);
          for i:=0 to nscanloop do if StatScan[i]=0 then symbol(Valscan[i],KScan[i*nactive+ishowk-1]);
          SetSymbol (3, 0, clRed);
          for i:=0 to nscanloop do if StatScan[i]>0 then symbol(Valscan[i],KScan[i*nactive+ishowk-1]);
        end;
      end else begin
        for i:=0 to nscanloop do begin
          if ymax < Fscan[i, ishowf] then ymax:=Fscan[i,ishowf];
          if ymin > Fscan[i, ishowf] then ymin:=Fscan[i,ishowf];
        end;
        ymin:=ymin*permultune[ishowf];  ymax:=ymax*permultune[ishowf];
        Init(scanpar[iscan].minval,ymin,scanpar[iscan].maxval, ymax, 1, 1, scanpar[iscan].nam,scanpar[ishowf].nam , 3,false);
        with plot do begin
          SetSymbol (3, 2, clBlue);
          for i:=0 to nscanloop do if StatScan[i]=0 then symbol(Valscan[i],FScan[i,ishowf]*permultune[ishowf]);
          SetSymbol (3, 0, clRed);
          for i:=0 to nscanloop do if StatScan[i]>0 then symbol(Valscan[i],FScan[i,ishowf]*permultune[ishowf]);
        end;
      end;
    end;
  end;
end;


procedure TMatch.FormPaint(Sender: TObject);
begin
  makeplot;
end;


procedure TMatch.butfunupClick(Sender: TObject);
begin
  inc(ishowf);
  if ishowf>16 then ishowf:=1;
  LabFunNam.Caption:=scanpar[ishowf].nam;
  LabKnoNam.Caption:='';
  showfk:=false;
  MakePlot;
end;

procedure TMatch.butfundoClick(Sender: TObject);
begin
  dec(ishowf);
  if ishowf<1 then ishowf:=16;
  LabFunNam.Caption:=scanpar[ishowf].nam;
  LabKnoNam.Caption:='';
  showfk:=false;
  MakePlot;
end;

procedure TMatch.butknodoClick(Sender: TObject);
begin
  dec(ishowk);
  if ishowk<1 then ishowk:=nactive;
  LabKnoNam.Caption:=getEllaNam(knobs[ishowk]);
  LabFunNam.Caption:='';
  showfk:=true;
  MakePlot;
end;

procedure TMatch.butknoupClick(Sender: TObject);
begin
  inc (ishowk);
  if ishowk>nactive then ishowk:=1;
  LabKnoNam.Caption:=getEllaNam(knobs[ishowk]);
  LabFunNam.Caption:='';
  showfk:=true;
  MakePlot;
end;

procedure TMatch.butscacloClick(Sender: TObject);
begin
  panfig.visible:=false;
  panknobs.visible:=true;
end;

procedure TMatch.butscawriClick(Sender: TObject);
var
  suffix, s1: string;
  i, j: integer;
  isel: array[1..nMatchFunc] of boolean;
  mfname: string;
  outfi: textfile;
begin
  mfname:=ExtractFileName(FileName);
  mfname:=work_dir+Copy(mfname,0,Pos('.',mfname)-1);
//write plotted data to file
  if Pos('(',edfnam.text)=0 then suffix:='_'+TB(edfnam.text) else suffix:='';
  mfname:=mfname+'_scan'+suffix+'.txt';
  assignFile(outfi,mfname);
{$I-}
  rewrite(outfi);
{$I+}
  if IOResult =0 then begin
    s1:=FillB(MatchFuncName[iscan],10,1)+' |';
    for i:=1 to nfuncs do s1:=s1+FillB(MatchFuncName[i],10,1);
    s1:=s1+' |S|';
//?    for i:=1 to nactive do s1:=s1+FillB(Ella[knobs[i] mod 1000].nam,10,1);
    for i:=1 to nactive do s1:=s1+FillB(getEllaNam(knobs[i]),10,1);
    writeln(outfi,s1);
    for i:=1 to nfuncs do isel[i]:=false;
    for i:=1 to nselect do isel[funcs[i]]:=true;
    s1:=FillB('set value',10,1)+' |';
    for i:=1 to nfuncs do if isel[i] then s1:=s1+FillB('objective',10,1) else s1:=s1+'          ';
    writeln(outfi, s1);
    for j:=0 to nscanloop do begin
      s1:=FillB(Ftos(Valscan[j],8,4),10,1)+' |';
      for i:=1 to nfuncs do s1:=s1+FillB(Ftos(Fscan[j,i]*permultune[i],8,4),10,1);
      s1:=s1+' |'+inttostr(statscan[j])+'|';
      for i:=1 to nactive do s1:=s1+FillB(FtoS(Kscan[j*nactive+(i-1)],8,4),10,1);
      writeln(outfi, s1);
    end;
    CloseFile(outfi);
    MessageDlg('Data saved to text file '+mfname, MtInformation, [mbOK],0);
  end else begin
    OPALog(1,'could not write '+mfname);
  end;
end;

procedure TMatch.cbxIncBendsClick(Sender: TObject);
begin
  Knoblist;
end;

procedure TMatch.perbutClick(Sender: TObject);
begin
  if permultune[9]=1 then permultune[9]:=Glob.NPer else permultune[9]:=1;
  permultune[10]:=permultune[9];
  perbut.caption:='x'+inttostr(permultune[9]);
  ed_9.Text:=FtoS(funcval[9]*permultune[9],funcwid[9],funcdec[9]);
  ed_10.Text:=FtoS(funcval[10]*permultune[10],funcwid[10],funcdec[10]);
  settuneval;
end;

end.

