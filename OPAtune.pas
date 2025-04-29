unit OPAtune;

//{$MODE Delphi}
interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, OPAglobal, ASfigure, ASaux;

type

  { Ttuneplot }

  Ttuneplot = class(TForm)
    diag: TFigure;
    LabOrd: TLabel;
    butmore: TButton;
    ButLess: TButton;
    ChkNsys: TCheckBox;
    ChkSkew: TCheckBox;
    ButZin: TButton;
    ButZot: TButton;
    Lab1: TLabel;
    Buteps: TButton;
    butshl: TButton;
    Butshr: TButton;
    Butshu: TButton;
    butshd: TButton;
    butcen: TButton;
    edper: TEdit;
    LabPer: TLabel;
    p: TPaintBox;
    procedure FormClose(Sender: TObject; var mycloseAction: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure butmoreClick(Sender: TObject);
    procedure ButLessClick(Sender: TObject);
    procedure ChkNsysClick(Sender: TObject);
    procedure ChkSkewClick(Sender: TObject);
    procedure ButZinClick(Sender: TObject);
    procedure ButZotClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure ButepsClick(Sender: TObject);
    procedure diagpPaint(Sender: TObject);
    procedure butshlClick(Sender: TObject);
    procedure ButshrClick(Sender: TObject);
    procedure ButshuClick(Sender: TObject);
    procedure butshdClick(Sender: TObject);
    procedure butcenClick(Sender: TObject);
    procedure edperKeyPress(Sender: TObject; var Key: Char);
  private
    Qx0, Qy0, Qrange, dQx, dQy, Qx1, Qx2, Qy1, Qy2: Real; //midpoint, full range, shift
    MaxOrd: Integer;
    IncSkew, IncNsys: boolean;
    procedure ResizeAll;
    procedure GetLines;
    procedure PlotLines;
    procedure MarkTune(qx, qy, reldp: real; connect: boolean);
    procedure PlotChromLine;
    procedure PlotTushLines;
    procedure MakePlot;
  public
    procedure AddTunePoint (qxin, qyin, dpp, dppmax: real; connect: boolean);
    procedure AddChromLine (cx1, cy1, cx2, cy2, cx3, cy3, dppmax: real);
    procedure AddTushPoint (xmy:integer; qxin, qyin: real);
    procedure Diagram (qxin, qyin: real);
    procedure Refresh;
    procedure SaveDefaults;
  end;

var
  tuneplot: Ttuneplot;

implementation

const
  nchlpmax=50;

type
  ResLinType = record
    a, b, c, n, wid: integer;
    nsys, skew: boolean;
    x1,x2,y1,y2: real;
    col: TColor;
  end;

  QPointsType= record
    qx, qy, reldp: real;
    lineto: boolean;
    symcol: TColor;
  end;

  ChromLineType=record
    valid: boolean;
    qxp, qyp, qxm, qym: array[1..nchlpmax] of real;
  end;

const
  MaxMaxOrd=12;

var
  ResLin: array of ResLinType;
  Rescol: array[1..MaxMaxOrd] of TColor;
  QPoints: array of QPointsType;
  ChromLine: ChromLineType;
  Tushx, Tushm, Tushy: array of QPointsType;
  widfactor, useper: integer;
  
{$R *.lfm}
procedure Ttuneplot.FormCreate(Sender: TObject);
var
  i:integer;
  lab:TLabel;
  str: string;
begin
// create colors and labels
  ResCol[1]:=clGray;
  for i:=2 to MaxMaxOrd do begin
    if i<3 then ResCol[i]:=clGray else ResCol[i]:=ColorCircle((i-3)/MaxMaxOrd);
    lab:=TLabel(FindComponent('Lab'+IntToStr(i)));
    if lab = nil then begin
      lab:=TLabel.Create(self);
      lab.name:= 'Lab'+IntToStr(i);
      lab.parent:=tuneplot;
      lab.Font:=Lab1.font;
      lab.Font.color:=ResCol[i];
      str:=inttostr(i); if i<10 then str:=' '+str;
      Lab.Caption:=str;
    end;
  end;

  //assignscreen called first, creates paintbox
  Diag.assignScreen;
  Width :=IDefGet('tdiag/size');

  Qrange:=FDefGet('tdiag/qrang');
  dQx:=0.0; dQy:=0.0;
  MaxOrd:=IDefGet('tdiag/order');
  IncSkew:=(IDefGet('tdiag/skew')=1);
  IncNsys:=(IDefGet('tdiag/nsys')=1);
  ChkNsys.Checked:=IncNsys;
  ChkSkew.Checked:=IncSkew;
  widfactor:=1;
end;

procedure Ttuneplot.FormClose(Sender: TObject; var mycloseAction: TCloseAction);
begin
  QPoints:=nil;
  ResLin:=nil;
  Tushx:=nil; Tushm:=nil; Tushy:=nil;
  SaveDefaults;
end;

procedure Ttuneplot.FormResize(Sender: TObject);
begin
  ResizeAll;
end;

//================public=======================================

procedure Ttuneplot.Diagram (qxin, qyin: real);
begin
  visible:=status.periodic;
  if visible then begin

// move it to the default location:
    Top:=5;
    Left:=Screen.Width-Width-5;

    Qx0:=qxin;
    Qy0:=qyin;
    dQx:=0.0; dQy:=0.0; //center on working point
    QPoints:=nil;
    Tushx:=nil; Tushm:=nil; Tushy:=nil;
    ChromLine.valid:=false;
    useper:=Glob.NPer;
    Edper.Text:=Inttostr(useper);
    getLines;
    MakePlot;
  end;
end;

procedure TtunePlot.Refresh;
// same like Diagram, but no input of tune and no getlines,
// only clear the points
begin
  visible:=status.periodic;
  if visible then begin
    QPoints:=nil;
    Tushx:=nil; Tushm:=nil; Tushy:=nil;
    ChromLine.valid:=false;
    MakePlot;
  end;
end;


procedure Ttuneplot.AddTunePoint (qxin, qyin, dpp, dppmax: real; connect: boolean);
begin
  setLength(QPoints, Length(QPoints)+1);
  with QPoints[High(QPoints)] do begin
    qx:=qxin;
    qy:=qyin;
    lineto:=connect;
//opamessage(0,ftos(qx,10,5)+ftos(qy,10,5));
    if dppmax > 0 then reldp:=dpp/dppmax else reldp:=0;
    MarkTune(qx,qy,reldp,lineto);
  end;
end;

procedure TtunePlot.SaveDefaults;
begin
  Defset('tdiag/size',Width);
  Defset('tdiag/qrang',Qrange);
  Defset('tdiag/order',MaxOrd);
  if IncSkew then Defset('tdiag/skew',1) else Defset('tdiag/skew',0);
  if IncNsys then Defset('tdiag/nsys',1) else Defset('tdiag/nsys',0);
end;

procedure TtunePlot.AddChromLine (cx1, cy1, cx2, cy2, cx3, cy3, dppmax: real);
var
  i: integer;
  dpp: real;
begin
  with ChromLine do begin
    valid:=true;
    for i:=1 to nchlpmax do begin
      dpp:=dppmax/nchlpmax*i;
      qxp[i]:=qx0+dpp*(cx1+dpp*(cx2+dpp*cx3));
      qyp[i]:=qy0+dpp*(cy1+dpp*(cy2+dpp*cy3));
      qxm[i]:=qx0-dpp*(cx1-dpp*(cx2-dpp*cx3));
      qym[i]:=qy0-dpp*(cy1-dpp*(cy2-dpp*cy3));
    end;
  end;
  PlotChromLine;
end;

procedure TtunePlot.addTushPoint(xmy: integer; qxin, qyin: real);
var
  col: TColor;
begin
  case abs(xmy)-1 of
    0: begin
      setlength(tushx,length(tushx)+1);
      col:=clBlue; if xmy<0 then col:= clGray; //dimcol(col,clWhite,0.5);
      with tushx[high(tushx)] do begin qx:=qxin; qy:=qyin; symcol:=col; end;
      with Diag.plot do begin
        SetSymbol( 2, 2,col);  Symbol(qxin,qyin);
      end;
    end;
    1: begin
      setlength(tushm,length(tushm)+1);
      col:=dimcol(clBlue, clRed,0.5); if xmy<0 then col:=clGray;//dimcol(col,clWhite,0.5);
      with tushm[high(tushm)] do begin qx:=qxin; qy:=qyin; symcol:=col; end;
      with Diag.plot do begin
        SetSymbol( 2, 2,col ); Symbol(qxin,qyin);
      end;
    end;
    2: begin
      setlength(tushy,length(tushy)+1);
      col:=clRed; if xmy<0 then col:=clGray; //dimcol(col,clWhite,0.5);
      with tushy[high(tushy)] do begin qx:=qxin; qy:=qyin; symcol:=col; end;
      with Diag.plot do begin
        SetSymbol( 2, 2, col); Symbol(qxin,qyin);
      end;
    end;
  end;
end;

//=================================================================

procedure Ttuneplot.ResizeAll;
const
  dsr  =10; //dist to outside
  dxt  =18; dyt=16; // order label width & height
  ds   =6; // space
  dyb  =17; //but height
var
  x, y, wid, i: integer;
  Lab: TLabel;

begin

//  Top:=5;
  if Width<300 then Width:=300;
  if Width>Screen.Width div 2 then Width:=Screen.Width div 2;
//  Left:=Screen.Width-Width-5;
  x:=dsr+dxt+ds;
  y:=dyb+dsr+ds;
  wid:=ClientWidth-x-dsr;
  ClientHeight:=wid+2*y;
  Diag.SetSize(x,y,wid,wid);
  x:=dsr;
  for i:=1 to MaxMaxOrd do begin
    Lab:=TLabel(FindComponent('Lab'+IntToStr(i)));
    Lab.setBounds(x,y+2,dxt,dyt);
    Inc(y,dyt+3);
    Lab.Visible:=(i<=MaxOrd);
  end;
  LabOrd.Left:=dsr; LabOrd.Top:=dsr+2;
  x:=x+LabOrd.width+ds;
  y:=dsr;
  ButMore.setbounds(x,y,25,dyb);
  x:=x+ButMore.width+ds;
  ButLess.setbounds(x,y,25,dyb);
  x:=x+ButLess.width+2*ds;
  ChkNsys.setBounds(x,y,49,dyb);
  x:=x+ChkNsys.width+2*ds;
  ChkSkew.setBounds(x,y,49,dyb);
  x:=x+ChkNsys.width+2*ds;
  LabPer.setBounds(x,y,25,dyb);
  x:=x+LabPer.width+ds;
  EdPer.setBounds(x,y,25,dyb);



  y:=y+dyb+2*ds+wid;
  x:=dsr+dxt+ds;
  ButZin.setbounds(x,y,33,dyb);
  x:=x+ButZin.width+ds;
  ButZot.setbounds(x,y,33,dyb);
  x:=x+ButZot.width+ds;
  ButShL.setbounds(x,y,dyb,dyb);
  x:=x+dyb+ds;
  ButShR.setbounds(x,y,dyb,dyb);
  x:=x+dyb+ds;
  ButShU.setbounds(x,y,dyb,dyb);
  x:=x+dyb+ds;
  ButShD.setbounds(x,y,dyb,dyb);
  x:=x+dyb+ds;
  ButCen.setbounds(x,y,dyb,dyb);
  x:=x+dyb+ds;
  Buteps.setbounds(x,y,33,dyb);
  MakePlot;
end;

procedure Ttuneplot.GetLines;
{
 find all resonance lines visible in the interval
 [qx1,qx2]x[qy1,qy2] up to order MaxOrd,
 identify skew, nsys
 store in Reslin, highest orders first.
}
var
  ar, br, nr, ibr, erj, eru, ero: integer;
  yt, test: real;
  found: boolean;
begin
  Qx1:=Qx0+dQx-Qrange/2; Qx2:=Qx0+dQx+Qrange/2;
  Qy1:=Qy0+dQy-Qrange/2; Qy2:=Qy0+dQy+Qrange/2;
  ResLin:=nil;
//  for nr:= MaxOrd downto 1 do begin
  for nr:= 1 to MaxOrd do begin
    for ar:= nr downto 0 do begin
      for ibr:=0 to 1 do begin
        br:=(nr-ar)*(1-2*ibr);
        if br > 0 then begin
          eru:=Round(ar*qx1+br*qy1);
          ero:=Round(ar*qx2+br*qy2);
        end else begin
          eru:=Round(ar*qx1+br*qy2);
          ero:=Round(ar*qx2+br*qy1);
        end;
        for erj:=eru to ero do begin
          found:=false;

          if ar > Abs(br) then begin
            Test:=(erj-br*qy1)/ar;
            found:=found or ((qx2-Test)*(qx1-Test) <= 0);
            Test:=(erj-br*qy2)/ar;
            found:=found or ((qx2-Test)*(qx1-Test) <= 0);
          end else begin
            Test:=(erj-ar*qx1)/br;
            found:=found or ((qy2-Test)*(qy1-Test) <= 0);
            Test:=(erj-ar*qx2)/br;
            found:=found or ((qy2-Test)*(qy1-Test) <= 0);
          end;

          if found then begin
            setlength(ResLin,length(ResLin)+1);
            with ResLin[High(Reslin)] do begin
              a:=ar; b:=br; c:=erj; n:=nr;

              //calculate intersection with qrange square:
              if (ar*br) <> 0 then begin
                yt:=(erj-ar*qx1)/br;
                if          yt<Qy1 then begin
                  x1:=(erj-br*Qy1)/ar; y1:=Qy1;
                end else if yt>Qy2 then begin
                  x1:=(erj-br*Qy2)/ar; y1:=Qy2;
                end else begin
                  x1:=Qx1;             y1:=yt;
                end;
                yt:=(erj-ar*Qx2)/br;
                if          yt<Qy1 then begin
                  x2:=(erj-br*Qy1)/ar; y2:=Qy1;
                end else if yt>Qy2 then begin
                  x2:=(erj-br*Qy2)/ar; y2:=Qy2;
                end else begin
                  x2:=Qx2;             y2:=yt;
                end;
              end else begin
                if ar=0 then begin
                  x1:=Qx1; x2:=Qx2; y1:=erj/br; y2:=y1;
                end else begin //br=0
                  y1:=Qy1; y2:=Qy2; x1:=erj/ar; x2:=x1;
                end;
              end;
              col:=ResCol[nr];
//             if nr=1 then wid:=5;
//             if nr=2 then wid:=3;
              wid:=MaxOrd+1-nr;
              skew:=false; nsys:=false;
              if nr=1 then wid:=wid+2;
              if nr=2 then wid:=wid+1;
              if (nr > 1) then begin
                skew:= ((nr-ar) mod 2 <> 0);
                nsys:= ((erj mod useper <> 0) and (nr > 2));
              end;
            end; //with
          end; //found
        end; // erj
      end; // ibr
    end; // ar
  end; // nr
end;

procedure Ttuneplot.PlotLines;
var
  i: integer;
begin
  with Diag.plot do begin
    for i:=0 to High(ResLin) do with Reslin[i] do begin
      if skew then SetColor(dimcol(col,clWhite,0.5)) else SetColor(col);
      SetThick(wid*widfactor);
//      if skew then SetStyle(psDot) else SetStyle(psSolid);
      if  (((not skew) or (skew and IncSkew)) //always plot 1st and 2nd orders 17.3.19
      and ((not nsys) or (nsys and IncNsys))) or (n<=2) then Line(x1,y1,x2,y2);
    end;
    SetStyle(psSolid);
    SetThick(1);
  end;
end;

procedure Ttuneplot.MarkTune(qx, qy, reldp: real; connect: boolean);
var
  col: TColor;
begin
  if reldp=0 then col:=clLime
  else if reldp<0 then col:=dimcol(clAqua   ,clYellow, abs(reldp))
                  else col:=dimcol(clFuchsia,clYellow, abs(reldp));
  with Diag.plot do begin
    SetSymbol( 4, 1, col);
    if connect then Line(qx,qy,qx0,qy0);
    Setthick(3); Symbol( qx, qy);
    SetSymbol( 3, 1, clBlack);
    Setthick(1);     if reldp=0 then Symbol( qx, qy);
  end;
end;

procedure TtunePlot.PlotChromLine;
var
  i: integer;
begin
  with ChromLine do if valid then begin
    with Diag.Plot do begin
      setcolor(clFuchsia);
      Moveto(qx0,qy0);
      for i:=1 to nchlpmax do LineTo(qxp[i],qyp[i]); stroke;
      setcolor(clAqua);
      Moveto(qx0,qy0);
      for i:=1 to nchlpmax do LineTo(qxm[i],qym[i]); stroke;
      MarkTune(qxp[nchlpmax], qyp[nchlpmax], 1, false);
      MarkTune(qxm[nchlpmax], qym[nchlpmax],-1, false);
    end;
  end;
end;

procedure TtunePlot.PlotTushLines;
var
  i:integer;
begin
  with Diag.plot do begin
    SetSymbol(2,2,clBlack);
    for i:=0 to High(tushx) do with Tushx[i] do Symbolc(qx,qy,symcol);
    for i:=0 to High(tushm) do with Tushm[i] do Symbolc(qx,qy,symcol);
    for i:=0 to High(tushy) do with Tushy[i] do Symbolc(qx,qy,symcol);
  end;
end;

procedure Ttuneplot.MakePlot;
var
  i: integer;
begin
  Diag.Plot.setcolor(clBlack);
  Diag.Plot.Clear(clWhite);
  Diag.Init(Qx1, Qy1, Qx2, Qy2, 1,1,'Qx','Qy',3,false);
  PlotLines;
  MarkTune(qx0,qy0,0, false);
  for i:=0 to High(QPoints) do with QPoints[i] do  MarkTune(qx, qy, reldp, lineto);
  PlotChromLine;
  PlotTushLines;
end;


procedure Ttuneplot.butmoreClick(Sender: TObject);
begin
  if MaxOrd < MaxMaxOrd then begin
    Inc(MaxOrd);
    GetLines;
    ResizeAll;
  end;
end;

procedure Ttuneplot.ButLessClick(Sender: TObject);
begin
  if MaxOrd >1 then begin
    Dec(MaxOrd);
    GetLines;
    ResizeAll;
  end;
end;

procedure Ttuneplot.ChkNsysClick(Sender: TObject);
begin
  IncNsys:=ChkNsys.Checked;
  if IncNsys then EdPer.Text:='1' else begin
    useper:=Glob.NPer;
    EdPer.Text:=Inttostr(useper);
    GetLines;
  end;
  MakePlot;
end;

procedure Ttuneplot.ChkSkewClick(Sender: TObject);
begin
  IncSkew:=ChkSkew.Checked;
  MakePlot;
end;

procedure Ttuneplot.ButZinClick(Sender: TObject);
begin
  Qrange:=2*Qrange/3;
  GetLines;
  MakePlot;
end;

procedure Ttuneplot.ButZotClick(Sender: TObject);
begin
  Qrange:=3*Qrange/2;
  GetLines;
  MakePlot;
end;


procedure Ttuneplot.FormPaint(Sender: TObject);
begin
//  MakePlot;
end;

procedure Ttuneplot.ButepsClick(Sender: TObject);
var
  errmsg, epsfile: string;
begin
  epsfile:=ExtractFileName(FileName);
  epsfile:=work_dir+Copy(epsfile,0,Pos('.',epsfile)-1)+'_tune.eps';
  diag.plot.PS_start(epsfile,OPAversion, errmsg);
  if length(errmsg)>0 then begin
    MessageDlg('PS export failed: '+errmsg, MtError, [mbOK],0);
  end else begin
    widfactor:=2;
    MakePlot;
    widfactor:=1;
    diag.plot.PS_stop;
    MessageDlg('Graphics exported to '+epsfile, MtInformation, [mbOK],0);
    MakePlot;
  end;
end;


{var
  mfname: string;
begin
  Diag.beginMetaPlot(1);
  MakePlot;
  mfname:=ExtractFileName(FileName);
  mfname:=work_dir+Copy(mfname,0,Pos('.',mfname)-1);
  Diag.endMetaPlot(mfname+'_tuneplot.wmf');
  MakePlot;
end;
}

procedure Ttuneplot.diagpPaint(Sender: TObject);
begin
  MakePlot;
end;

procedure Ttuneplot.butshlClick(Sender: TObject);
begin
  dQx:=dQx-Qrange/3;  GetLines; MakePlot;
end;

procedure Ttuneplot.ButshrClick(Sender: TObject);
begin
  dQx:=dQx+Qrange/3;  GetLines; MakePlot;
end;

procedure Ttuneplot.ButshuClick(Sender: TObject);
begin
  dQy:=dQy+Qrange/3;  GetLines; MakePlot;
end;

procedure Ttuneplot.butshdClick(Sender: TObject);
begin
  dQy:=dQy-Qrange/3;  GetLines; MakePlot;
end;

procedure Ttuneplot.butcenClick(Sender: TObject);
begin
  dQx:=0.0; dQy:=0.0;  GetLines; MakePlot;
end;

procedure Ttuneplot.edperKeyPress(Sender: TObject; var Key: Char);
var
  kv: real;
begin
  kv:=0;
  if TEKeyVal(edper, Key, kv, 2, 0) then begin
    useper:=round(kv);
    if useper>1 then ChkNsys.State:=cbUnchecked;
    GetLines; MakePlot;
  end;
end;

end.
