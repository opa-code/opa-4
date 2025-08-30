unit opacurrents;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  globlib, MathLib, ASaux, Grids, StdCtrls;

type
  TCurrents = class(TForm)
    cgrid: TStringGrid;
    butex: TButton;
    edps: TEdit;
    pgrid: TStringGrid;
    busnapSLS: TButton;
    memlog: TMemo;
//    procedure FormCreate(Sender: TObject);
    procedure butexClick(Sender: TObject);
    procedure DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure cgridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure busnapSLSClick(Sender: TObject);

    procedure getCurrentsGLOB; // temp
    function getKfromI (c: CalibrationType; i: double): double;
    function getdkdIfac (c: CalibrationType; I: double): double;
    function getIfromK(cal:CalibrationType; kv:double): double;
   private
    { Private-Deklarationen }
  public
    procedure Start;
  end;

var
  Currents: TCurrents;

implementation

{const
  ceps = 1e-3; //tolerate 1 mA
}
type
  pstype = record
    name: string_25;
    n:integer;
    cavg, cmin, cmax, favg:double;
  end;

var
  ps: array of pstype;

{$R *.lfm}

{------------------------------------------------------------------------------}
procedure TCurrents.getCurrentsGLOB;
type
  pstype = record
    name: string_25;
    n:integer;
    cavg, cmin, cmax:double;
  end;

var
  cur, kv: double;
  cfac, j, ip, ips: integer;
  np: NameListpt;
  cal: CalibrationType;
  ps: array of pstype;

begin
  ps :=nil;
  for j:=1 to Glob.NElla do with Ella[j] do begin
//    writeln (nam,'------------------------------------------------------');
    np:=nl;
    while np<>nil do begin
      cal:=Calibration[np.typeindex];
// if original element has zero length, kv = kv*L, use cal.leng to get kv
// if element length not equal calibration length, adjust gradient to keep kv*L constant:
      if cod=cbend then kv:=phi/cal.leng else begin
        if l=0.0 then kv:= getkval(j,0)/cal.leng
                 else kv:= getkval(j,0)*l/cal.leng;
      end;
      if np.polarity=-1 then cfac:=-1 else cfac:=1;
      cur:=getIfromk(cal,kv*cfac);
//      writeln(nam,' | ', np.realname,' | ', getkval(j):8:3,' | ',kv:8:3,' | ', cur:8:3);
      ips:=-1;
      for ip:=0 to high(ps) do if ps[ip].name=np^.psname then ips:=ip;
//power supply not yet registered: create list entry
      if ips=-1 then begin
        setlength(ps,length(ps)+1);
        ps[high(ps)].name:=np^.psname;
        ps[high(ps)].n:=1;
        ps[high(ps)].cavg:=cur;
        ps[high(ps)].cmin:=cur;
        ps[high(ps)].cmax:=cur;
// power supply known: check if new current value is compatible with average up to now
      end else begin
        if cur < ps[ips].cmin then ps[ips].cmin:=cur;
        if cur > ps[ips].cmax then ps[ips].cmax:=cur;
        ps[ips].cavg:=(ps[ips].cavg*ps[ips].n+cur)/(ps[ips].n+1);
        inc(ps[ips].n);
      end;
      np:=np^.nex;
    end;
  end;

{
  for ip:=0 to high(ps) do begin
    write(diagfil,ps[ip].name+' ');
  end;
  writeln(diagfil);
  for ip:=0 to high(ps) do begin
    write(diagfil,ps[ip].cavg:12:4);
  end;
  writeln(diagfil);
}
end;


{get magnet strength from current:
give (n-1)th field derivative (B, B', B", ...) in units of T/m^(n-1) as a function of current
and normalize to energy for k-value

               /              |I|*tlin                    \
           b = | bres + --------------------------------- |*sign(I)
               \        (1+sfac*(|I|*(1/isat))^aexp)^nexp /

since most quads are unipolar assume remanence always same sign as current
for bends b is the curvature phi/leng
}
function TCurrents.getKfromI (c: CalibrationType; i: double): double;
var
  b: double;
begin
  b:=c.bres+abs(i)*c.tlin/PowR(1+c.sfac*PowR((abs(i)*c.isat),c.aexp),c.nexp);
  if i < 0 then b:=-b;
  getKfromI:= b/(glob.energy*1E9/speed_of_light)/factorial(c.mpol);
end;

{.......................................................................}

{attenuation factor for (dk/dI)/(dk/dI_linear) compared to linear calibration,
= (dBn/dI)/(dBn/dI_linear) i.e. derivative of above divided by tlin, without brho

                1 + (1-aexp*nexp)*sfac*(|I|/isat)^aexp)
           f = ----------------------------------------
                (1+sfac*(|I|*(1/isat))^aexp)^(nexp+1)
}
function TCurrents.getdkdIfac (c: CalibrationType; I: double): double;
var
  x: double;
begin
  x:=c.sfac*PowR( abs(I)*c.isat,c.aexp);
  getdkdIfac:= (1.0 + (1.0 - c.aexp*c.nexp)*x )/ PowR( 1.0+x, c.nexp+1);
end;

{.......................................................................}

{
  get current from magnet strength:
  nonlinear calibration: iterate to get current for k-value
  bisection root finder from numerical recipes
}

function TCurrents.getIfromK(cal:CalibrationType; kv:double): double;

const
  rtbIterations = 40;
  rtbAccuracy  = 1e-6; // 1 microAmp accuracy sufficient
  rtbRange = 0.2; // variation range, sufficient since functions are smooth

var
  i,x1, x2, f1, f2, rtb, dx, xmid, fmid{, lincurr}: double;
  jstep:integer;

  function rtbfunc (i, kvguess:double): double;
  begin
      // function to become = 0 for root finder
    rtbfunc:= getKfromI(cal,i) -kvguess;
  end;

begin
//  lincurr:=0.0;
  if cal.tlin=0 then begin
    i:=0.0;
    OPALog(1,'getIfromB: ZERO linear calibration factor found !');
  end else begin
  // result for linear, inititial guess for nonlinear
    i := (kv*glob.energy*1E9/speed_of_light*factorial(cal.mpol)-cal.bres)/cal.tlin;
//    lincurr:=i;
    if (cal.isat <> 0.0) then begin
      x1:=(1.0-rtbRange)*i;
      x2:=(1.0+rtbRange)*i;
      f1:=rtbfunc(x1,kv);
      f2:=rtbfunc(x2,kv);
      if ((f1*f2) > 0.0) then begin
        OPALog(1,'getIfromB > bracketing failed - use linear inversion.');
      end else begin
        if (f1 < 0) then begin
          rtb:=x1;
          dx :=x2-x1;
        end else begin
          rtb:=x2;
          dx :=x1-x2;
        end;
        jstep:=0;
        repeat
          inc(jstep);
          dx:=dx*0.5;
          xmid:=rtb+dx;
          fmid:=rtbfunc(xmid,kv);
          if (fmid <= 0.0) then rtb:=xmid;
        until (abs(dx) < rtbAccuracy) or (fmid = 0.0) or (jstep = rtbIterations);
        i:=rtb;
       end; //else
    end; //isat
  end; //tlin
  getIfromK:=i;
end;







//procedure TCurrents.FormCreate(Sender: TObject);
//begin
//end;

{------------------------------------------------------------------------------}

procedure TCurrents.Start;
var
  cur, kv, fac: double;
  cfac, j, ip, ips: integer;
  np: NameListpt;
  cal: CalibrationType;

begin
  ps :=nil;
  for j:=1 to Glob.NElla do with Ella[j] do begin
    if diag(2) then writeln (diagfil,nam,'------------------------------------------------------');
    np:=nl;
    while np<>nil do begin
      cal:=Calibration[np.typeindex];
// if original element has zero length, kv = kv*L, use cal.leng to get kv
// if element length not equal calibration length, adjust gradient to keep kv*L constant:

      write(diagfil, nam,' | ', cal.leng:8:3,' | ', l:8:3);
      if cod=cbend then begin
//use curvature for bends instead of k value
        kv:=phi/cal.leng;
      end else if cod=csext then begin
        kv:=getkval(j,0)/cal.leng;// because getkval returns int.strength for sext.
      end else begin
        if l=0.0 then kv:= getkval(j,0)/cal.leng
                 else kv:= getkval(j,0)*l/cal.leng;
      end;
      if np.polarity=-1 then cfac:=-1 else cfac:=1;
      if cal.tlin <> 0 then begin
        cur:=getIfromk(cal,kv*cfac);
        fac:=getdkdIfac (cal,cur);
            if diag(2) then writeln(diagfil,' | ', np.realname,' | ', getkval(j,0):8:3,' | ',kv:8:3,' | ', cur:8:3);
      end else begin
        cur:=0;
            if diag(2) then writeln(diagfil,' | ', np.realname,' | ', getkval(j,0):8:3,' | ',kv:8:3,' | ERROR (tlin=0)');
      end;
      ips:=-1;
      for ip:=0 to high(ps) do if ps[ip].name=np^.psname then ips:=ip;
//power supply not yet registered: create list entry
      if ips=-1 then begin
        setlength(ps,length(ps)+1);
        ps[high(ps)].name:=np^.psname;
        ps[high(ps)].n:=1;
        ps[high(ps)].cavg:=cur;
        ps[high(ps)].favg:=fac;
        ps[high(ps)].cmin:=cur;
        ps[high(ps)].cmax:=cur;
// power supply known: check if new current value is compatible with average up to now
      end else begin
        if cur < ps[ips].cmin then ps[ips].cmin:=cur;
        if cur > ps[ips].cmax then ps[ips].cmax:=cur;
        ps[ips].cavg:=(ps[ips].cavg*ps[ips].n+cur)/(ps[ips].n+1);
        ps[ips].favg:=(ps[ips].favg*ps[ips].n+fac)/(ps[ips].n+1);
        inc(ps[ips].n);
      end;
      np:=np^.nex;
    end;
  end;

  with cgrid do begin
    RowCount:=Length(ps)+1;
    Cells[0,0]:='Power Supply'; Cells[1,0]:='N'; Cells[2,0]:='Current [A]';
    for ip:=0 to high(ps) do begin
      Cells[0,ip+1]:=ps[ip].name;
      Cells[1,ip+1]:=IntToStr(ps[ip].n);
      Cells[2,ip+1]:=FtoS(ps[ip].cavg,8,3);
    end;
  end;

{
  for ip:=0 to high(ps) do begin
    write(diagfil, ps[ip].name); for j:=length(ps[ip].name) to 15 do write(diagfil,' ');
    write(diagfil,' ',ps[ip].n:3,'  ', ps[ip].cavg:8:3, ' ', ps[ip].cmin:8:3, ' ', ps[ip].cmax:8:3);
    if (abs(ps[ip].cmin-ps[ip].cavg)>ceps) or (abs(ps[ip].cmax-ps[ip].cavg)>ceps) then writeln(diagfil, ' ! ') else writeln(diagfil);
  end;

  for ip:=0 to high(ps) do begin
    write(diagfil,ps[ip].name+' ');
  end;
  writeln(diagfil);
  for ip:=0 to high(ps) do begin
    write(diagfil,ps[ip].cavg:12:4);
  end;
  writeln(diagfil);
}

end;

{------------------------------------------------------------------------------}

procedure TCurrents.DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  xp, xw: integer;
begin
  with cgrid.Canvas do begin
    xw:=TextWidth(cgrid.Cells[ACol,ARow]);
    if ARow=0 then begin
      Brush.Color:=clBtnFace;
      cgrid.ColWidths[ACol]:=20+ xw;
    end else begin
      if (gdfocused in State) or (gdselected in State) then begin
        Brush.Color:=clLightYellow;
      end else begin
        Brush.Color:=clWhite;
      end;
    end;
    case ACol of
      1: xp:=(Rect.Left+Rect.Right-xw) div 2; //center
      2: xp:=Rect.Right-xw-5; //right
      else xp:=Rect.Left+5; //left
    end;
    Font.Color:=clBlack;
    FillRect(Rect);
    TextOut(xp, Rect.Top+2, cgrid.Cells[ACol, ARow]);
  end;
end;

{------------------------------------------------------------------------------}

procedure TCurrents.cgridSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
const
  spol: array[-1..1] of char=('-','~','+');
var
  cfac,j,ip: integer;
  kv, cur: double;
  np: NameListpt;
  cal: CalibrationType;
begin
  ip:=Arow-1;
  if ip>=0 then begin
    edps.text:=ps[ip].name;
    pgrid.Cells[0,0]:='Element';
    pgrid.Cells[1,0]:='Channel';
    pgrid.Cells[2,0]:='Type';
    pgrid.Cells[3,0]:='pol';
    pgrid.Cells[4,0]:='K';
    pgrid.Cells[5,0]:='I [A]';
    pgrid.RowCount:=1;
    for j:=1 to Glob.NElla do with Ella[j] do begin
      np:=nl;
      while np<>nil do begin
        if np^.psname=ps[ip].name then begin
          cal:=Calibration[np.typeindex];
          if cod=cbend then begin
            kv:=phi/cal.leng;
          end else if cod=csext then begin
            kv:=getkval(j,0)/cal.leng;// because getkval returns int.strength for sext.
          end else begin
            if l=0.0 then kv:= getkval(j,0)/cal.leng
                     else kv:= getkval(j,0)*l/cal.leng;
          end;
          if np.polarity=-1 then cfac:=-1 else cfac:=1;
          if cal.tlin <> 0 then cur:=getIfromk(cal,kv*cfac) else cur:=0;
          pgrid.RowCount:=pgrid.RowCount+1;
          pgrid.Cells[0,pgrid.RowCount-1]:=nam;
          pgrid.Cells[1,pgrid.RowCount-1]:=np.realname;
          pgrid.Cells[2,pgrid.RowCount-1]:=cal.typename;
          pgrid.Cells[3,pgrid.RowCount-1]:=spol[np.polarity];
          pgrid.Cells[4,pgrid.RowCount-1]:=FtoS(kv,8,3);
          pgrid.Cells[5,pgrid.RowCount-1]:=FtoS(cur,8,3);
        end;
        np:=np^.nex;
      end;
    end;
  end;
end;

{------------------------------------------------------------------------------}

// for SLS control system: export SNAP file with storage ring optics settings
procedure TCurrents.busnapSLSClick(Sender: TObject);
var
  ip: integer;
  opticName, snapfile, snam: string;
  f: textfile;
begin
 // + single quad increments and modulator tuning factors
  memLog.Clear;

 // export the snap file:
  opticName:=LowerCase(ExtractFileName(FileName));
  opticName:=Copy(opticname,0,Pos('.opa',opticname)-1);
  snapfile:=ExtractFilePath(FileName)+opticName+'.snap';
  opticName:=UpperCase(Opticname);
  AssignFile(f,snapfile);
  rewrite(f);
  // snap header info
  writeln(f,'env{');
  writeln(f,'keywords{'+opticName+','+FtoS(glob.energy,6,4)+'GeV}');
  writeln(f,'}');
  writeln(f,'comments{'+glob.text+'}');
  writeln(f);
  writeln(f,'data{');
  writeln(f,'ARIMA-OPTIC:NAME-NOM.VAL{value{data{'+opticName+'}} sevr{NO_ALARM}}');
  writeln(f,'ARIMA-OPTIC:E-NOM.VAL{value{data{'+FtoS(glob.energy,6,4)+'}} sevr{NO_ALARM}}');
  if not Status.Tmatrix then MemLog.Lines.Append('found no data for tune and tune matrix!');
  if not Status.Cmatrix then MemLog.Lines.Append('found no data for chromaticities and chroma matrix!');
// tunes and chromaticities
  writeln(f,'ARIMA-OPTIC:QX-NOM.VAL{value{data{'+FtoS(Snapsave.Qx,12,8)+'}} sevr{NO_ALARM}}');
  writeln(f,'ARIMA-OPTIC:QY-NOM.VAL{value{data{'+FtoS(Snapsave.Qy,12,8)+'}} sevr{NO_ALARM}}');
  writeln(f,'ARIMA-OPTIC:CX-NOM.VAL{value{data{'+FtoS(Snapsave.ChromX,12,8)+'}} sevr{NO_ALARM}}');
  writeln(f,'ARIMA-OPTIC:CY-NOM.VAL{value{data{'+FtoS(SnapSave.ChromY,12,8)+'}} sevr{NO_ALARM}}');
// tuning matrix
  writeln(f,'ARIMA-OPTIC:QFX-FCTR.VAL{value{data{'+FtoS(SnapSave.tmfx,12,8)+'}} sevr{NO_ALARM}}');
  writeln(f,'ARIMA-OPTIC:QFY-FCTR.VAL{value{data{'+FtoS(SnapSave.tmfy,12,8)+'}} sevr{NO_ALARM}}');
  writeln(f,'ARIMA-OPTIC:QDX-FCTR.VAL{value{data{'+FtoS(SnapSave.tmdx,12,8)+'}} sevr{NO_ALARM}}');
  writeln(f,'ARIMA-OPTIC:QDY-FCTR.VAL{value{data{'+FtoS(SnapSave.tmdy,12,8)+'}} sevr{NO_ALARM}}');
// chroma matrix
  writeln(f,'ARIMA-OPTIC:SFX-FCTR.VAL{value{data{'+FtoS(SnapSave.cmfx,12,8)+'}} sevr{NO_ALARM}}');
  writeln(f,'ARIMA-OPTIC:SFY-FCTR.VAL{value{data{'+FtoS(SnapSave.cmfy,12,8)+'}} sevr{NO_ALARM}}');
  writeln(f,'ARIMA-OPTIC:SDX-FCTR.VAL{value{data{'+FtoS(SnapSave.cmdx,12,8)+'}} sevr{NO_ALARM}}');
  writeln(f,'ARIMA-OPTIC:SDY-FCTR.VAL{value{data{'+FtoS(SnapSave.cmdy,12,8)+'}} sevr{NO_ALARM}}');
// optical parameters at photon beam markers
  for ip:=0 to SnapSave.xbcount-1 do begin
    with SnapSave.xb[ip] do begin
      snam:=StringReplace(nam,'_','-',[rfReplaceAll]);
      writeln(f,snam+':BD-BETAX{value{data{'+FtoS(betax,10,3)+'}} servr{NO_ALARM}}');
      writeln(f,snam+':BD-BETAY{value{data{'+FtoS(betay,10,3)+'}} servr{NO_ALARM}}');
      writeln(f,snam+':BD-DISPX{value{data{'+FtoS(dispx,10,3)+'}} servr{NO_ALARM}}');
    end;
  end;
// currents and dk/dI attenuation factors:
  for ip:=0 to high(ps) do begin
    writeln(f,ps[ip].name+':I-NOM.VAL{value{data{'+FtoS(ps[ip].cavg,12,8)+'}} sevr{NO_ALARM}}');
    writeln(f,ps[ip].name+':B_I-GRAD.VAL{value{data{'+FtoS(ps[ip].favg,12,8)+'}} sevr{NO_ALARM}}');
  end;
  writeln(f,'}');
  closeFile(f);
  MemLog.Lines.Append('wrote '+snapfile);
end;

{------------------------------------------------------------------------------}

procedure TCurrents.butexClick(Sender: TObject);
begin
  Close;
  Currents:=nil;
  Release;
end;


end.
