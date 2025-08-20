unit EdElSet;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  extctrls,StdCtrls, Grids, OPAglobal, OpticPlot, ASaux, asfigure;

type

  { TEditElemSet }

  TEditElemSet = class(TForm)
    p: TPaintBox;
    tab: TStringGrid;
    Label1: TLabel;
    ButOK: TButton;
    Butcancel: TButton;
    LabType: TLabel;
    EditName: TEdit;
    butApply: TButton;
    panpro: TPanel;
    figpro: TFigure;
    procedure ButOKClick(Sender: TObject);
    procedure ButcancelClick(Sender: TObject);
    procedure EditNameKeyPress(Sender: TObject; var Key: Char);
    procedure butApplyClick(Sender: TObject);
    procedure pPaint(Sender: TObject);
    procedure tabDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
//    procedure FormShow(Sender: TObject);
//    procedure FormPaint(Sender: TObject);
  private
    ListHandle: TListBox;
    pwHandle: TPaintBox;
    tablin: integer;
    jvar, jelem: integer;
//    ThickCods: set of 0..50;
    ElemTest: ElementType;
    vartest: variable_Type;
    editMode: boolean;
    procedure InitCom;
    procedure InitComVar;
    procedure SetElem;
    procedure SetVar;
    function CellGetVar (var val: real): string;
    function CellGet (var data: Real; var flag: Boolean; fac: real): string;
    procedure CellPut(spar: string; sunit: string; val: single; exp: Elem_Exp_pt; w,d: word);
    procedure CellPutVar(spar: string; val: real; exp: string);
    procedure PlotPro;
  public
    procedure InitE (handle: TListBox);
    procedure InitO (iel: integer; handle: TPaintBox);
    procedure InitEVar (handle: TListBox);
    procedure InitOVar (ivar: integer; handle: TPaintBox);
    procedure Exit;
    function getJelem: integer;
  end;

var
  EditElemSet: TEditElemSet;


implementation

{$R *.lfm}

function TEditElemSet.getJelem: integer;
begin
  getJelem:=jelem;
end;

procedure TEditElemSet.Exit;
begin
  if EditElemSet<>nil then begin
    Release;
    EditElemSet:=nil;
  end;
end;

procedure TEditElemSet.CellPut(spar: string; sunit: string; val: single; exp: Elem_exp_pt; w,d: word);
begin
  with tab do begin
    RowCount:=RowCount+1;
    cells[0,tablin]:=spar;
    cells[1,tablin]:=sunit;
    if exp=nil then begin
      if d=0 then cells[2,tablin]:=InttoStr(round(val))
      else cells[2,tablin]:=FtoSe(val, w,d);
    end else begin
      if editMode then cells[2,tablin]:=exp^ else cells[2,tablin]:=ftose(val,w,d)+' = '+exp^;
    end;
  end;
  Inc(tablin);
end;

procedure TEditElemSet.CellPutVar(spar: string; val: real; exp: string);
begin
  with tab do begin
    RowCount:=RowCount+1;
    cells[0,tablin]:=spar;
    if exp='' then cells[1,tablin]:=FtoSe(val, 10,5) else {begin
      if editMode then} cells[1,tablin]:=exp{ else cells[1,tablin]:=FtoSe(val,10,5)+' = '+exp;
    end;}
  end;
  Inc(tablin);
end;

// init from OptikView: pass elLA index
procedure TEditElemSet.InitO( iel: integer; handle: TPaintBox);
begin
  editMode:=False;
  pwHandle:=handle;
  ListHandle:=nil;
  jelem:=iel;
  ElemTest:=Ella[jelem];
  InitCom;
end;

// init from Editor: pass ListBoxhandle
procedure TEditElemSet.InitE (handle: TListBox);
begin
  editMode:=True;
  pwHandle:=nil;
  ListHandle:=handle;
  jelem:=ListHandle.ItemIndex;
  ElemTest:=Elem[jelem];
  InitCom;
end;

// init from OptikView for Variable, pass variable index
procedure TEditElemSet.InitOVar( ivar: integer; handle: TPaintBox);
begin
  editMode:=False;
  pwHandle:=handle;
  ListHandle:=nil;
  jvar:=ivar;
  VarTest:=Variable[jvar];
  InitComVar;
end;

// init from Editor for Variable, pass listbox handle
procedure TEditElemSet.InitEVar (handle: TListBox);
begin
  editMode:=True;
  pwHandle:=nil;
  ListHandle:=handle;
  jvar:=ListHandle.ItemIndex-Glob.NElem-1;
  VarTest:=Variable[jvar];
  InitComVar;
end;

// common init for variables
procedure TEditElemSet.InitComVar;
begin
  width:=530;
  jelem:=-1;
  EditName.Enabled:=editMode;
  butApply.Enabled:= not editMode;

  with EditElemSet.tab do begin
     ColCount:=2;
     Colwidths[0]:=120;
     Colwidths[1]:=380;
     RowCount:=1;
     Options:=[goEditing];
     FixedRows:=0;
     FixedCols:=1;
  end;
  tablin:=0;
  with VarTest do begin
    CellPutVar('Expression',val, exp);
    {cell put generated one line too many:}
    tab.RowCount:=tab.RowCount-1;
    LabType.Caption:='Variable';
    EditName.Text:=Nam;
  end;

end;

// common init for elements
procedure TEditElemSet.InitCom;
var
  temp: integer;
begin
  jvar:=-1;
//  opamessage(0,inttostr(left)+' '+inttostr(top));
//  ThickCods:=[cdrif,cquad,csext,cbend,ccomb,cundu,csept];
  EditName.Enabled:=editMode;
  butApply.Enabled:= not editMode; // no action in edit mode...**
  with EditElemSet.tab do begin
     ColCount:=3;
     Colwidths[0]:=180;
     Colwidths[1]:=50;
     Colwidths[2]:=270;
     RowCount:=1;
     Options:=[goEditing];
     FixedRows:=0;
     FixedCols:=2;
  end;
  tablin:=0;
  with ElemTest do begin
    if cod in [cquad, cbend, ccomb] then begin
      width:= 540+panpro.width;
      panpro.visible:=true;
      figpro.assignscreen;
      figpro.setsize  (5, 5, panpro.width-10, panpro.height-10);
      figpro.setbounds(5, 5, panpro.width-10, panpro.height-10);
      butApply.Enabled:=true; // **... except for update of profile plot.
    end else begin
      width:=530;
      panpro.visible:=false;
    end;

    if ElemThick[cod] then CellPut('Length','m',l,l_exp,8,4);
    case cod of
      cdrif: begin
        if block then temp:=1 else temp:=0;
        CellPut('protected (1=yes, 0=no)','',temp, nil,8,0);
      end;
      cquad: CellPut('Strength Kq = B''/B*rho','1/m2',kq, kq_exp,8,5);
      csole: CellPut('Strength Ks = B/2*B*rho','1/m',ks, nil,8,5);
      csext: begin
        CellPut('B3 [ *L ] = B"/(2 B*rho)[ *L ]','[m]/m3',ms, nil, 8,5);
        CellPut('Number of slices ','',sslice,nil,8,0);
      end;
      cbend: begin
         CellPut('Bending angle','°',degrad*phi, phi_exp, 9,6);
         CellPut('Entry edge angle','°',degrad*tin, tin_exp, 9,6);
         CellPut('Exit  edge angle','°',degrad*tex, tex_exp, 9,6);
         CellPut('Strength Kb = B''/B*rho','1/m2',kb,kb_exp, 8,5);
         CellPut('Full gap height','mm',1000*gap, nil, 8,3);
         CellPut('Fringe field K1 entry','',k1in, nil, 8,5);
         CellPut('Fringe field K1 exit ','',k1ex, nil, 8,5);
         CellPut('Fringe field K2 entry','',k2in, nil, 8,5);
         CellPut('Fringe field K2 exit ','',k2ex, nil, 8,5);
      end;
      cundu: begin
         CellPut('Period length','mm',1000*lam, nil, 8,1);
         CellPut('Peak field strength','T',Bmax, nil, 8,5);
         CellPut('Full gap height','mm',1000*ugap, nil, 8,3);
         CellPut('Pole integral F1','',fill1, nil, 8,5);
         CellPut('Pole integral F2','',fill2, nil, 8,5);
         CellPut('Pole integral F3','',fill3, nil, 8,5);
         if halfu then temp:=1 else temp:=0;
         CellPut('end poles (0) or open (1)','',temp, nil,8,0);
      end;
      ckick: begin
         CellPut('Multipole order n (1=dipole)','',mpol,nil,6,0);
         CellPut('Xpeak_NLK; x=0 -> pure m.pole','mm', xoff*1e3, nil, 8,3);
         CellPut('Kick NLK; x=0,n>1 -> BnL','m^-(n-1);mrad',amp,nil,10,3);
         CellPut('Half sine time','nsec',tau*1e9, nil, 8,3);
         CellPut('Delay','nsec',delay*1e9, nil, 8,3);
         CellPut('Number of slices ','',kslice,nil,8,0);
      end;
      csept: begin
         CellPut('Distance to stored beam orbit','mm',dis,nil, 8,3);
         CellPut('Septum thickness','mm',thk, nil, 8,3);
         CellPut('Deflection angle','°',degrad*ang, nil, 8,3);
      end;
      comrk: begin
         if screen then temp:=1 else temp:=0;
         CellPut('Marker is a screen (1=yes, 0=no)','',temp, nil,8,0);
         CellPut('Horizontal (a-mode) Beta ','m',     om^.Bet[1],nil,10,6);
         CellPut('Horizontal (a-mode) Alpha ','rad',  om^.Bet[2],nil,10,6);
         CellPut('Vertical   (b-mode) Beta ','m',     om^.Bet[3],nil,10,6);
         CellPut('Vertical   (b-mode) Alpha','rad',   om^.Bet[4],nil,10,6);
         CellPut('Horizontal Dispersion   ','m',      om^.Eta[1],nil,10,6);
         CellPut('Slope of hor. Dispersion','rad',    om^.Eta[2],nil,10,6);
         CellPut('Vertical   Dispersion   ','m',      om^.Eta[3],nil,10,6);
         CellPut('Slope of ver. Dispersion','rad',    om^.Eta[4],nil,10,6);
         CellPut('Horizontal Orbit Offset','mm', 1000*om^.orb[1],nil,10,3);
         CellPut('Horizontal Orbit Angle','mrad',1000*om^.orb[2],nil,10,3);
         CellPut('Vertical   Orbit Offset','mm', 1000*om^.orb[3],nil,10,3);
         CellPut('Vertical   Orbit Angle','mrad',1000*om^.orb[4],nil,10,3);
         CellPut('Coupling matrix C11     ','',       om^.cma[1,1],nil,10,6);
         CellPut('Coupling matrix C12     ','m',      om^.cma[1,2],nil,10,6);
         CellPut('Coupling matrix C21     ','1/m',    om^.cma[2,1],nil,10,6);
         CellPut('Coupling matrix C22     ','',       om^.cma[2,2],nil,10,6);
//         CellPut('Relative momentum dev.','%',100*om^.dpp,nil,10,3);
      end;
      ccomb: begin
        CellPut('Bending angle','°',degrad*cphi,cphi_exp,9,6);
        CellPut('Entrance edge angle','°',degrad*cerin,cerin_exp,9,6);
        CellPut('Exit edge angle','°',degrad*cerex,cerex_exp,9,6);
        CellPut('Full gap height','mm',1000*cgap,nil,8,3);
        CellPut('Fringe field K1 entry','',cek1in,nil,8,5);
        CellPut('Fringe field K1 exit ','',cek1ex,nil,8,5);
        CellPut('Quadrupole strength','1/m2',ckq,ckq_exp,8,5);
        CellPut('Sextupole  strength','1/m3',cms,nil,8,5);
        CellPut('Number of slices ','',cslice,nil,8,0);
      end;
      cxmrk: begin
        CellPut('Length of photon beam for plot','m',xl,nil,8,2);
        CellPut('Style (0=solid, 1=dotted)','',nstyle,nil,8,0);
        CellPut('Save to SNAPfile (0=off, 1=on)','',snap,nil,8,0);
      end;
      cgird: begin
        CellPut('Girder type (0,1,2)','',gtyp,nil,8,0);
        CellPut('Longitudinal shift','m',shift,nil,8,5);
      end;
      cmpol: begin
        CellPut('Multipole order n','',nord,nil,6,0);
        CellPut('Bn.L=B(n-1)/(n-1)!/B*rho','m^-(n-1)',bnl,nil,10,3);
        CellPut('Real magnet length','m',lmpol,nil,10,3); 
      end;
      ccorh: CellPut('Horizontal kick angle B(1)/(B*rho)','mrad',dxp*1000,nil,8,3);
      ccorv: CellPut('Vertical kick angle A(1)/(B*rho)','mrad',dyp*1000,nil,8,3);
    end;
    if cod in [cbend, cquad, csext, cundu, ccomb, cmpol, ckick, csept] then CellPut('Rotation angle','°',degrad*rot,nil,8,3);
    CellPut('Horizontal aperture','mm',ax,nil,8,1);
    CellPut('Vertical   aperture','mm',ay,nil,8,1);
    {cell put generated one line too many:}
    tab.RowCount:=tab.RowCount-1;
    LabType.Caption:=ElemName[cod];
    EditName.Text:=Nam;
  end;
end;


function TEditElemSet.CellGet (var data: Real; var flag: Boolean; fac: real): string;
var
  x: Real;
  exp, s: String;
  errcode:Integer;
  errexp: boolean;
begin
  exp:='';
  with tab do begin
    s:=UpperCase(Cells[2,tablin]);
    try
      Val(s,x,errcode);
    except
      OPALog(1,'ElemSet: invalid numeric format'); //need this message ?
    end;
    if errcode=0 then begin
      data:=x*fac;
    end else begin
      x:=Eval_exp(s,errexp);
      if errexp then begin
//        MessageBeep(mb_ok);
//        MessageDlg('Invalid numeric format'+#13+'for '+Cells[0,tablin],mtError, [mbOK],0);
        MessageDlg('Error for '+Cells[0,tablin]+#13+Get_Eval_exp_errmess,mtError, [mbOK],0);
        tab.setfocus;
        flag:=False;
      end else exp:=s;
    end;
  end;
  Inc(tablin);
  CellGet:=exp;
end;

function TEditElemSet.CellGetVar (var val: real): string;
var
  x: Real;
  exp, s: String;
  errexp: boolean;
begin
  exp:='';
  with tab do begin
    s:=UpperCase(Cells[1,tablin]);
    x:=Eval_exp(s,errexp);
    if errexp then begin
//      MessageBeep(mb_ok);
      MessageDlg('Error in expression '+#13+s+#13+Get_Eval_exp_errmess,mtError, [mbOK],0);
      tab.setfocus;
    end else begin
      val:=x;
      exp:=s;
    end;
  end;
  Inc(tablin);
  CellGetVar:=exp;
end;

procedure TEditElemSet.pPaint(Sender: TObject);
begin
   if panpro.visible then Plotpro;
end;

procedure TEditElemSet.butApplyClick(Sender: TObject);
begin
  if jelem >-1 then SetElem else if jvar > -1 then Setvar;
end;


procedure TEditElemSet.ButOKClick(Sender: TObject);
begin
  if jelem >-1 then SetElem else if jvar > -1 then Setvar;
  Exit;
end;

procedure TEditElemSet.SetElem;

var
  i, j: integer;
  f, fn, fnd: Boolean;
  temp: real;
  sexp, s, ustr: string;
  done: boolean;
  a: AEpt;


  procedure ExpUpdate (s: string; var exp: Elem_Exp_pt);
  begin
//    if exp=nil then sold:='' else sold:=exp^;
    if EditMode then begin
      if s='' then begin
        if exp <> nil then exp:=nil;
      end else begin
        if exp=nil then exp:=New(Elem_Exp_pt);
        exp^:=s;
      end;
    end;
  end;

begin

  if editMode then begin
  // this part only in edit mode, no rename in optics mode
    fn:=true;
    s:=EditName.text;
    if s <> ElemTest.nam then begin
// add: same procedure for vars: rename entry in all expressions if name was changed
//here: add more tests on mame (Charactgers. length, etc.)
      if not NameCheck(s) then begin
        fn:=false;
        EditName.setfocus;
      end else begin
        fnd:=false;
        for i:=0 to High(Variable) do
          fnd:=fnd or (Variable[i].nam=s);
        for i:=1 to glob.nelem do
          fnd:=fnd or ( (i<>jelem) and (elem[i].nam=s));
        for i:=1 to glob.nsegm do
          fnd:=fnd or ( segm[i].nam=s);
        if fnd then begin
          fn:=false;
//          MessageBeep(mb_ok);
          MessageDlg('An element or segment with name '+s+
               ' exists already!',mtError, [mbOK],0);
          EditName.setfocus;
        end;
      end;
// Name accepted. ask for renaming if element is used elsewhere
      if fn then begin
        ustr:='';
        for i:=1 to Glob.NSegm do begin
          a:=segm[i].ini;
          done:=false;
          while a<>nil do begin
            if a^.nam=ElemTest.nam then begin
              if not done then begin
                done:=true;
                ustr:=ustr+' '+Segm[i].nam;
              end;
            end;
             a:=a^.nex;
          end;
        end;
        if Length(ustr)>0 then begin
//          MessageBeep(mb_ok);
          if MessageDlg('This element is used by the following segments: '+ustr+
          ' Change name and entries in all these segments?', mtConfirmation,[mbYes,mbNo],0)
          = mrNo then fn:=false
          else begin
            for i:=1 to Glob.NSegm do begin
              a:=segm[i].ini;
              while a<>nil do begin
                if a^.nam=ElemTest.nam then a^.nam := s;
                a:=a^.nex;
              end;
            end;
          end;
        end;
      end;
    end;
    if fn then ElemTest.nam:=s else EditName.text:=ElemTest.nam;
  end else fn:=false;

  // common part:
  tablin:=0;
  f:=true;
  temp:=0;
  with ElemTest do begin

    if ElemThick[cod] then begin
      sexp:=CellGet(l, f,1); ExpUpdate(sexp,l_exp);
    end;
    case cod of
      cdrif: begin CellGet(temp,f,1); block:=round(temp)=1; end;
      cquad: begin sexp:=CellGet(kq, f, 1); ExpUpdate(sexp,kq_exp); end;
      csole: CellGet(ks, f, 1);
      csext: begin
               CellGet(ms,f, 1);
               CellGet(temp,f,1);
               sslice:=round(temp); if sslice<1 then sslice:=1;
              end;
      cbend: begin
               sexp:=CellGet(phi, f, raddeg);  ExpUpdate(sexp,phi_exp);
               sexp:=CellGet(tin, f, raddeg);  ExpUpdate(sexp,tin_exp);
               sexp:=CellGet(tex, f, raddeg);  ExpUpdate(sexp,tex_exp);
               sexp:=CellGet(kb,f, 1);         ExpUpdate(sexp,kb_exp);
               CellGet(gap, f, 0.001);
               CellGet(k1in,f,1);
               CellGet(k1ex,f,1);
               CellGet(k2in,f,1);
               CellGet(k2ex,f,1);
             end;
      cundu: begin
               CellGet(lam, f, 0.001);
               CellGet(bmax,f,1);
               CellGet(ugap,f,0.001);
               CellGet(fill1, f, 1);
               CellGet(fill2, f, 1);
               CellGet(fill3, f, 1);
               CellGet(temp,f,1); halfu:=round(temp)=1;
             end;
      ckick: begin
               CellGet(temp,f,1);
               mpol:=round(temp); if mpol<1 then mpol:=1;
               CellGet(xoff, f, 1e-3);
               CellGet(amp, f,1); //is saved in mrad in case of xoff<>0, else is BnL
               CellGet(tau, f,1e-9);
               CellGet(delay, f,1e-9);
               CellGet(temp,f,1);
               kslice:=round(temp); if (kslice<1) or (l=0) then kslice:=1;
             end;
      csept: begin
               CellGet(dis,f,1);
               CellGet(thk,f,1);
               CellGet(ang, f, raddeg);
             end;
      comrk: begin
               CellGet(temp,f,1); screen:=round(temp)=1;
               for i:=1 to 4 do CellGet(om^.bet[i],f,1);
               for i:=1 to 4 do CellGet(om^.eta[i],f,1);
               for i:=1 to 4 do CellGet(om^.orb[i],f,0.001);
               for i:=1 to 2 do for j:=1 to 2 do CellGet(om^.cma[i,j],f,1);
//               CellGet(om^.dpp,f, 0.01);
             end;
      ccomb: begin
               sexp:=CellGet(cphi,f,raddeg);   ExpUpdate(sexp,cphi_exp);
               sexp:=CellGet(cerin,f,raddeg);  ExpUpdate(sexp,cerin_exp);
               sexp:=CellGet(cerex,f,raddeg);  ExpUpdate(sexp,cerex_exp);
               CellGet(cgap, f, 0.001);
               CellGet(cek1in,f,1);
               CellGet(cek1ex,f,1);
               sexp:=CellGet(ckq,f,1);  ExpUpdate(sexp,ckq_exp);
               CellGet(cms,f,1);
               CellGet(temp,f,1);
               cslice:=round(temp); if cslice<1 then cslice:=1;
             end;
      cxmrk: begin
               CellGet(xl,f,1);
               CellGet(temp,f,1); nstyle:=round(temp);
               CellGet(temp,f,1); snap  :=round(temp);
             end;
      cgird: begin
               CellGet(temp,f,1); gtyp:=round(temp);
               CellGet(shift,f,1);
             end;
      cmpol: begin
               CellGet(temp,f,1);
               nord:=round(temp); if nord<2 then nord:=2;
               CellGet(bnl,f, 1);
               CellGet(lmpol,f,1);
             end;
      ccorh: CellGet(dxp,f,0.001);
      ccorv: CellGet(dyp,f,0.001);
    end; //case
    if cod in [cbend, cquad, csext, cundu, ccomb, cmpol, ckick, csept] then CellGet(rot,f,raddeg);
    CellGet(ax,f,1);
    CellGet(ay,f,1);
  end; //with

  if panpro.visible then Plotpro;


  if editMode then begin
    if f and fn then begin
      Elem[jelem]:=ElemTest;
      Listhandle.Items[jelem]:=ElemToStr(jelem);
    end;
  end else begin
    Ella[jelem]:=ElemTest;
    Ella_Eval(jelem);
    OpticReCalc;
    pwhandle.repaint;
  end;
end;

procedure TEditElemSet.SetVar;

var
  errcode, i: integer;
  f, fn, fnd, vfnd: Boolean;
  s, ustr: string;
  xv: real;


  procedure ExpUpdate (s: string; var exp: Elem_Exp_pt);
  begin
    if s='' then begin
      if exp <> nil then exp:=nil;
    end else begin
      if exp=nil then exp:=New(Elem_Exp_pt);
      exp^:=s;
    end;
  end;


begin

  if editMode then begin
  // this part only in edit mode, no rename in optics mode
    fn:=true;
    s:=EditName.text;
    if s <> VarTest.nam then begin
      if not NameCheck(s) then begin
        fn:=false;
        EditName.setfocus;
      end else begin
        fnd:=false;
        for i:=0 to High(Variable) do
          fnd:=fnd or ( (i<>jvar) and (Variable[i].nam=s));
        for i:=1 to glob.nelem do
          fnd:=fnd or (elem[i].nam=s);
        for i:=1 to glob.nsegm do
          fnd:=fnd or ( segm[i].nam=s);
        if fnd then begin
          fn:=false;
//          MessageBeep(mb_ok);
          MessageDlg('Variable, element or segment with name '+s+
               ' exists already!',mtError, [mbOK],0);
          EditName.setfocus;
        end;
      end;
// Name accepted. ask for renaming if variable is used elsewhere
      if fn then begin
        ustr:='';
        for i:=1 to Glob.NElem do with Elem[i] do begin
          vfnd:=false;
          if l_exp<>nil then vfnd:=(VarPos(Vartest.nam,l_exp^)>0);
          case cod of
            cquad: if kq_exp<>nil then vfnd:=vfnd or (VarPos(Vartest.nam,kq_exp^)>0);
            cbend: begin
              if kb_exp <>nil then vfnd:=vfnd or (VarPos(Vartest.nam,kb_exp^ )>0);
              if phi_exp<>nil then vfnd:=vfnd or (VarPos(Vartest.nam,phi_exp^)>0);
              if tin_exp<>nil then vfnd:=vfnd or (VarPos(Vartest.nam,tin_exp^)>0);
              if tex_exp<>nil then vfnd:=vfnd or (VarPos(Vartest.nam,tex_exp^)>0);
            end;
            ccomb: begin
              if ckq_exp  <>nil then vfnd:=vfnd or (VarPos(Vartest.nam,ckq_exp^  )>0);
              if cphi_exp <>nil then vfnd:=vfnd or (VarPos(Vartest.nam,cphi_exp^ )>0);
              if cerin_exp<>nil then vfnd:=vfnd or (VarPos(Vartest.nam,cerin_exp^)>0);
              if cerex_exp<>nil then vfnd:=vfnd or (VarPos(Vartest.nam,cerex_exp^)>0);
            end;
            else;
          end; //case
          if vfnd then ustr:=ustr+' '+Elem[i].nam;
        end; // for i
        for i:=0 to High(Variable) do if i<>jvar then with Variable[i] do begin
          if exp<>'' then if VarPos(Vartest.nam,exp)>0 then ustr:=ustr+' '+nam;
        end;
        if Length(ustr)>0 then begin
//          MessageBeep(mb_ok);
          if MessageDlg('This variable is used by the following variables or elements: '+ustr+
          ' Change name and entries in all these elements?', mtConfirmation,[mbYes,mbNo],0)
          = mrNo then fn:=false
          else begin
            for i:=1 to Glob.NElem do with Elem[i] do begin
              if l_exp<>nil then l_exp^:=VarReplace(l_exp^,Vartest.nam,s);
              case cod of
                cquad: if kq_exp<>nil then kq_exp^:=VarReplace(kq_exp^,Vartest.nam,s);
                cbend: begin
                  if kb_exp <>nil then kb_exp^ :=VarReplace(kb_exp^ ,Vartest.nam,s);
                  if phi_exp<>nil then phi_exp^:=VarReplace(phi_exp^,Vartest.nam,s);
                  if tin_exp<>nil then tin_exp^:=VarReplace(tin_exp^,Vartest.nam,s);
                  if tex_exp<>nil then tex_exp^:=VarReplace(tex_exp^,Vartest.nam,s);
                end;
                ccomb: begin
                  if ckq_exp  <>nil then ckq_exp^  :=VarReplace(ckq_exp^  ,Vartest.nam,s);
                  if cphi_exp <>nil then cphi_exp^ :=VarReplace(cphi_exp^ ,Vartest.nam,s);
                  if cerin_exp<>nil then cerin_exp^:=VarReplace(cerin_exp^,Vartest.nam,s);
                  if cerex_exp<>nil then cerex_exp^:=VarReplace(cerex_exp^,Vartest.nam,s);
                end;
                else;
              end; //case
            end; // for i Nelem..
            for i:=0 to High(Variable) do if i<>jvar then with Variable[i] do begin
              if exp<>'' then exp:=VarReplace(exp,Vartest.nam,s);
            end;
          end;
        end;
      end;
    end;
    if fn then VarTest.nam:=s else EditName.text:=VarTest.nam;
  end else fn:=false;

  // common part:
  tablin:=0;
  f:=true;
  with VarTest do begin
    exp:=CellGetVar(val);
  end; //with
// try number conversion to detect primary variable (=pure number) [like in Latread]
  try Val(VarTest.exp, xv,errcode); except end;
  if errcode=0 then VarTest.exp:='';

  if editMode then begin
    if f and fn then begin
      Variable[jvar]:=VarTest;
// change all, because we may have changed the name of a variable that appears in many expressions 1.12.2015
      with Listhandle do begin
        for i:=1 to Glob.NElem do Items[i]:=ElemToStr(i);
        for i:=0 to High(Variable) do Items[i+1+Glob.NElem]:=VariableToStr(i);
      end;
    end;
  end else begin
    Variable[jvar]:=VarTest;
    for i:=1 to Glob.Nella do Ella_Eval(i);
    OpticReCalc;
    pwhandle.repaint;
  end;
end;

procedure TEditElemSet.ButcancelClick(Sender: TObject);
begin
  Exit;
end;

procedure TEditElemSet.EditNameKeyPress(Sender: TObject; var Key: Char);
begin
  key:=UpCase(key);
end;

procedure TEditElemSet.tabDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  err: integer; xv: real;
begin
  with tab.Canvas do begin
    if (jelem > -1) and (not EditMode) and (Acol=2) then begin
      try Val(tab.Cells[Acol,Arow],xv,err) except end;
      if err<>0 then begin
        Brush.Color:=clBtnFace; Font.Color:=clRed; //clGray;
        FillRect(Rect);
        TextOut(Rect.Left+2, Rect.Top+2, UB(tab.Cells[ACol, ARow]));
      end;
    end;
  end;
end;

{
not needed, we only need  pPaint event for the figure
procedure TEditElemSet.FormShow(Sender: TObject);
begin
  if panpro.visible then PlotPro;
end;

procedure TEditElemSet.FormPaint(Sender: TObject);
begin
  if panpro.visible then PlotPro;
end;
}

procedure TEditElemSet.PlotPro;
const
  np=100; na=50;
var
  range, zoom, rad: real;
  ypos, dypos, xpos, xd, bpt, sq, del, radq, brho, g, b: real;
  x,y : array[0..2*np-1]of real;
  xa, ya, pa: array[0..na] of real;
  k: integer;
begin
  if ElemTest.cod in [cquad, cbend, ccomb] then if (ElemTest.l>0) then begin //safety first...
    rad:=FDefget('envel/rref')/1000;
    zoom:=2;
    brho:=Glob.Energy*1E9/speed_of_Light;
    with ElemTest do begin
      case cod of
        cquad: begin b:=0; g:=brho*kq; end;
        cbend: begin b:=brho*phi/l; g:=brho*kb; end;
        ccomb: begin b:=brho*cphi/l; g:=brho*ckq; end;
      end;
    end;
    for k:=0 to np-1 do begin
      x[np+k  ]:= (k+0.5)/np;
      x[np-k-1]:=-(k+0.5)/np;
    end;
    for k:=0 to 2*np-1 do x[k]:=x[k]*zoom*rad;

    //calculate radius and offset of shifted quad used as combined function bend:
    if g<>0 then begin
      del:= abs(b/g/rad);
      sq:=   sqrt(8+sqr(del));
      radq:=sqrt(sqrt((8 + 20*sqr(del)-sqr(sqr(del))+ del*sq*sq*sq)/8));
      del:=del*rad;
      if g*b < 0 then del:=-del;
      radq:=radq*rad;
      bpt:=abs(g)*radq;
      for k:=0 to 2*np-1 do begin
        xd:=x[k]+del;
        if abs(xd)>1e-6 then y[k]:=abs(sqr(radq)/2/xd) else y[k]:=zoom*rad;
      end;
    end else begin
      for k:=0 to 2*np-1 do y[k]:=rad;
      bpt:=abs(b);
      radq:=0; del:=0;
    end;
    for k:=0 to 2*np-1 do begin
      x[k]:=x[k]*1000; y[k]:=y[k]*1000;
    end;

    for k:=0 to na do begin
      pa[k]:=k/na*2*Pi;
      xa[k]:=cos(pa[k])*1000;
      ya[k]:=sin(pa[k])*1000;
    end;
    range:=1000*zoom*rad;

    with figpro.Plot do begin
      setcolor(clBlack);
      Clear(clWhite);
      figpro.Init(-range, -range, range, range, 1,1,'X [mm]', 'Y [mm]',3,false);
      setcolor(clRed);
      moveto(x[0],y[0]);
      for k:=1 to 2*np-1 do lineto(x[k],y[k]);
      line(-del*1000,-range, -del*1000, range);
      moveto(x[0],-y[0]);
      for k:=1 to 2*np-1 do lineto(x[k],-y[k]);
      setColor(clBlue);
      moveto(xa[0]*rad,ya[0]*rad);
      for k:=1 to na do lineto(xa[k]*rad,ya[k]*rad);
      setColor(clBlack);
      moveto(xa[0]*ElemTest.ax/1000,ya[0]*ElemTest.ay/1000);
      for k:=1 to na do lineto(xa[k]*ElemTest.ax/1000,ya[k]*ElemTest.ay/1000);
      xpos:=-range*0.9;
      ypos:= range*0.98; dypos:=range*0.08;
      TextAlign(ElemTest.nam, xpos, ypos,-1,-1, clBlack); ypos:=ypos-dypos;
      TextAlign('B0  = '+ftos(abs(b),7,3)+' T', xpos, ypos,-1,-1,clBlack);ypos:=ypos-dypos;
      TextAlign('B''  = '+ftos(abs(g),7,3)+' T/m', xpos, ypos,-1,-1,clBlack);ypos:=ypos-dypos;
      TextAlign('L   = '+ftos(ElemTest.l*1000,7,3)+' mm', xpos, ypos,-1,-1,clBlack);ypos:=ypos-dypos;
      TextAlign('Rad = '+ftos(rad *1000,7,3)+' mm', xpos, ypos,-1,-1,clBlack);ypos:=ypos-dypos;
      if abs(del) < 5*Rad then begin
        xpos:= range*0.1;         ypos:= range*0.98-dypos;
        TextAlign('Bqu = '+ftos(abs(bpt),7,3)+' T', xpos, ypos,-1,-1,clBlack);ypos:=ypos-dypos;
        TextAlign('Rqu = '+ftos(radq*1000,7,3)+' mm', xpos, ypos,-1,-1,clBlack);ypos:=ypos-dypos;
        TextAlign('Del = '+ftos(del *1000,7,3)+' mm', xpos, ypos,-1,-1,clBlack);ypos:=ypos-dypos;
      end;
      if elemtest.cod=ccomb then if abs(elemtest.cms)<>0 then
      TextAlign('[Sextupole not included in contour]', -range*0.93, -range*0.9,-1,-1,clBlack);
    end;
  end;
end;

end.
