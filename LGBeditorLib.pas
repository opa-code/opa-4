unit LGBeditorLib;

{$MODE Delphi}

interface

uses
  Math, Graphics, OPAglobal, ASfigure, asaux, SysUtils;


const
  cq_emi=3.84E-13;

var
  fig_HANDLE: TFigure;
  sbm, ered, bfi: integer;
  phideg, len, betafix, bmax, polwid: double;
  egamma, brho, erad_fac: double;
  nsl, nslmax: integer;
  phi, havg, dphi: double;
  betamin_hom, etamin_hom, sfocus_hom, emrd_hom, emit_hom, i2_hom, erad_hom, sdpp_hom: double;
  betamin, etamin, sfocus, emrd, emit, erad, sdpp: double;
  kn, hs, ds, ss, betas, alfas, etas, etaps, di5in, di5ot: array of double;
  hs_hom, ss_hom, betas_hom, etas_hom, di5in_hom, di5ot_hom, ss_best, hs_best: array of double;
  beta0, alfa0, eta0, etap0, gamma0, i5, i2, i3: double;
  hsmax, betamax, etamax, hmax, di5max, hlolim, hhilim, beta_best, disfoc_best, result_best: double;
  setkbmax, betaknob: boolean;
  BName: string;

procedure HomInit;
procedure RadInt;
procedure SliceRescale;
procedure MakePlot;
procedure knobscale (hlo, hhi, intref: double; revert: boolean);
procedure LGBcreate (bn: string);
procedure LGBdelete (bn: string);


implementation

{calculate solution for the ideal TME homogeneous bend, also initializes arrays etc.}
procedure HomInit;
var
  i: integer;
begin
  brho:=Glob.Energy*1e9/speed_of_light;
  egamma:=Glob.Energy*1e9/electron_mc2;
  erad_fac:=electron_charge/3* sqr(speed_of_light)*4*Pi*1e-10; {88.5 keV *gamma^4/R}

  phi:=phideg*raddeg;
  havg:=phi/len;
  i2_hom:=sqr(havg)*len;
  emrd_hom:=Power(len,4)*Power(havg,5)/(12*sqrt(15));
  if sbm=1 then begin
    betamin_hom:=len/sqrt(15);
    etamin_hom :=phi*len/6;
    emrd_hom:=8*emrd_hom;
  end else begin
    betamin_hom:=len*sqrt(3/320);
    sfocus_hom:=3/8*len;
    emrd_hom:=3*emrd_hom;
  end;
  emit_hom:=cq_emi*sqr(egamma)*emrd_hom/i2_hom;
  erad_hom:=erad_fac*power(egamma,4)*havg;
  sdpp_hom:=sqrt(cq_emi* power(abs(havg),3)*len / i2_hom /2 )*egamma;

  sfocus :=sfocus_hom;
  betamin:=betamin_hom;
  etamin :=etamin_hom;

{allocate arrays for data of (s)}

  setlength(hs, nsl);
  setlength(ss, nsl+1);
  setlength(ds, nsl);
  setlength(betas, nsl+1);
  setlength(alfas, nsl+1);
  setlength(etas, nsl+1);
  setlength(etaps, nsl+1);
  setlength(di5in, nsl);
  setlength(di5ot, nsl);
  setlength(kn, nsl);


  dphi:=phi/nsl;
  for i:=0 to nsl-1 do hs[i]:=havg;
  for i:=0 to nsl-1 do ds[i]:=dphi/hs[i];
  ss[0]:=0;
  for i:=0 to nsl-1 do ss[i+1]:=ss[i]+ds[i];

// get beta etc. at magnet entry:
  if sbm=1 then begin
    beta0:=betamin_hom;
    alfa0:=0;
    eta0 :=etamin_hom;
    etap0:=0;
  end else begin
    beta0:=betamin_hom+sqr(sfocus_hom)/betamin_hom;
    alfa0:=sfocus_hom/betamin_hom;
    eta0:=0;
    etap0:=0;
  end;

  RadInt;

// keep for plotting, to compare solution to HOM
  setlength(hs_hom, nsl);
  setlength(ss_hom, nsl+1);
  setlength(betas_hom, nsl+1);
  setlength(etas_hom, nsl+1);
  setlength(di5in_hom, nsl);
  setlength(di5ot_hom, nsl);
  for i:=0 to nsl do begin
    ss_hom[i]:=ss[i];
    betas_hom[i]:=betas[i];
    etas_hom[i] :=etas[i];
  end;
  for i:=0 to nsl-1 do begin
    hs_hom[i]:=hs[i];
    di5in_hom[i]:=di5in[i];
    di5ot_hom[i]:=di5ot[i];
  end;
// array to keep best results from minimizer
  setlength(ss_best, nsl+1);
  setlength(hs_best, nsl);

end;


{calculate radiation integrals and give beta, disp, dI5 as function of s for plotting}
procedure RadInt;
var
  i: integer;
  hc, h3: double;

function gethc (bet, alf, gam, eta, etp: double): double;
begin
  gethc:=sqr(etp)*bet+2*eta*etp*alf+sqr(eta)*gam;
end;

begin
  gamma0:=(1+sqr(alfa0))/beta0;
  for i:=0 to nsl do begin
    betas[i]:=beta0-2*alfa0*ss[i]+gamma0*sqr(ss[i]);
    alfas[i]:=alfa0-gamma0*ss[i];
  end;
  etas[0]:=eta0; etaps[0]:=etap0;
  for i:=1 to nsl do begin
    etaps[i]:=etaps[i-1]+hs[i-1]*ds[i-1];
    etas[i] :=etas[i-1]+etaps[i-1]*ds[i-1]+hs[i-1]*Sqr(ds[i-1])/2;
  end;
  hc:=gethc(betas[0], alfas[0], gamma0, etas[0], etaps[0]);
  i2:=0; i3:=0; i5:=0;
  for i:=0 to nsl-1 do begin
    h3:=power(abs(hs[i]),3);
    di5in[i]:=hc*h3;
    hc:=gethc(betas[i+1], alfas[i+1], gamma0, etas[i+1], etaps[i+1]);
    di5ot[i]:=hc*h3;
    i5:=i5+(di5in[i]+di5ot[i])/2*ds[i]; // simple trapezoidal integration; later: do analytic?
    i2:=i2+sqr(hs[i])*ds[i];
    i3:=i3+h3*ds[i];
  end;
  emrd:=i5;
  emit:=cq_emi*sqr(egamma)*emrd/i2;
  erad:=erad_fac*power(egamma,4)*i2/phi;  {equivalent h = i2 / phi}
  sdpp:=sqrt(cq_emi* i3 / i2 / 2 )*egamma;
end;


procedure knobscale (hlo, hhi, intref: double; revert: boolean);
// scale kn = -infty...0...+infty to hs = hlo...(hlo+hhi)/2....hhi
const
  tiny=1e-6;
  big=1e12;
var
  b, m, del, r, ty, hran, intmin, intmax, int, dfac: double;
  n, i: integer;
begin
  b:=(hhi-hlo)/2;
  m:=(hhi+hlo)/2;
  n:=nsl;

  if revert then begin
//reverse scaling, avoid to restore infinte values for kn by slightly queezing the interval of hs-values
    hran:=hhi-hlo;
    del:=tiny*hran;
    for i:=0 to n-1 do begin
      r:=(hs[i]-hlo)/hran;
      ty:=(hlo+del)*(1-r)+(hhi-del)*r;
      kn[i]:=b*(ty-m)/sqrt(sqr(b)-sqr(ty-m));
    end;
  end else begin
    for i:=0 to n-1 do begin
      if abs(kn[i]) < big then begin
        hs[i]:= m+ b*kn[i]/sqrt(sqr(b)+sqr(kn[i]))
      end else begin
 //       if kn[i]>0 then hs[i]:=hhi-power(b,3)/2/sqr(big) else hs[i]:=hlo+power(b,3)/2/sqr(big);
       if kn[i]>0 then hs[i]:=hhi else hs[i]:=hlo;
      end;
    end;
//check the integral and adjust all values if necessary
    int:=0;
    for i:=0 to n-1 do int:=int+ds[i]*hs[i];
    if int > intref then begin
      intmin:=len*hlo;
      if intmin >= intref then dfac:=1 else dfac:= (intref-int)/(intmin-int);
      for i:=0 to n-1 do hs[i]:=hs[i]+(hlo-hs[i])*dfac;
    end else if int < intref then begin
      intmax:=len*hhi;
      if intmax <= intref then dfac:=1 else dfac:= (intref-int)/(intmax-int);
      for i:=0 to n-1 do hs[i]:=hs[i]+(hhi-hs[i])*dfac;
    end;
  end;
end;


procedure SliceRescale;
var
  i,j,k: integer;
  dphi, phin: double;
  phis: array of double;
begin
//writeln(diagfil,'old curvatures');
//for i:=0 to nsl-1 do write(diagfil,hs[i]:8:4); writeln(diagfil);
  dphi:=phi/nsl;
  setlength(phis, nsl+1);
  phis[0]:=0;
  for i:=1 to nsl do phis[i]:=phis[i-1]+hs[i-1]*ds[i-1];
//writeln(diagfil,'old angles phis');
//for i:=0 to nsl-1 do write(diagfil,phis[i]*degrad:8:4); writeln(diagfil);
//writeln(diagfil,'old positions');
//for i:=0 to nsl do write(diagfil,ss[i]:8:4); writeln(diagfil);
  for i:=1 to nsl-1 do begin
    phin:=i*dphi;
    for k:=1 to nsl-1 do if (phin-phis[k])*(phin-phis[k-1])<0 then begin
      ss[i]:=0;
      for j:=0 to (k-2) do ss[i]:=ss[i]+ds[j];
      ss[i]:=ss[i]+(phin-phis[k-1])/(phis[k]-phis[k-1])*ds[k-1]
    end;
  end;
  ss[nsl]:=len;
  for i:=0 to nsl-1 do begin
    ds[i]:=ss[i+1]-ss[i];
    hs[i]:=dphi/ds[i];
  end;
//writeln(diagfil,'new curvatures');
//for i:=0 to nsl-1 do write(diagfil,hs[i]:8:4); writeln(diagfil);
//writeln(diagfil,'new distances');
//for i:=0 to nsl-1 do write(diagfil,ds[i]:8:4); writeln(diagfil);
//writeln(diagfil,'new positions');
//for i:=0 to nsl do write(diagfil,ss[i]:8:4); writeln(diagfil);
end;

procedure MakePlot;
var
  i: integer;

procedure stepplot(s,y1,y2: array of double; f: double);
var
  i: integer;
begin
  with Fig_HANDLE.Plot do begin
    if sbm=0 then Line(s[0],0,s[0],f*y1[0]);
    Line(s[nsl],0,s[nsl],f*y2[nsl-1]);
    for i:=1 to nsl-1 do Line(s[i],f*y2[i-1],s[i  ],f*y1[i]);
    for i:=0 to nsl-1 do Line(s[i],f*y1[i  ],s[i+1],f*y2[i]);
  end;
end;

begin
  case bfi of
    0:begin
      di5max:=0;
      for i:=0 to nsl-1 do if di5ot_hom[i] > di5max then di5max:=di5ot_hom[i];
      for i:=0 to nsl-1 do if di5ot[i] > di5max then di5max:=di5ot[i];
      with fig_HANDLE.Plot do begin
        setcolor(clBlack);
        Clear(clWhite);
        fig_HANDLE.Init(0, 0, len*1.05, di5max*1.05, 1,1,'S [m]','b^3 H [1/m^2]',3,false);
        setcolor(clBlue); setThick(3);
        stepplot(ss_hom, di5in_hom, di5ot_hom, 1);
        setcolor(clRed); setThick(3);
        stepplot(ss, di5in, di5ot, 1);
      end;
    end;
    1:begin
      hmax:=0;
      for i:=0 to nsl-1 do if hs[i] > hmax then hmax:=hs[i];
      for i:=0 to nsl-1 do if hs_hom[i] > hmax then hmax:=hs_hom[i];
      with fig_HANDLE.Plot do begin
        setcolor(clBlack);
        Clear(clWhite);
        fig_HANDLE.Init(0, 0, len*1.05, hmax*brho*1.05, 1,1,'S [m]','B [T]',3,false);
        setcolor(clBlue); setThick(3);
        stepplot(ss_hom, hs_hom, hs_hom, brho);
        setcolor(clRed); setThick(3);
        stepplot(ss, hs, hs, brho);
{        if sbm=0 then Line(ss[0],0,ss[0],hs[0]*brho);
        Line(ss[nsl],0,ss[nsl],hs[nsl-1]*brho);
        for i:=1 to nsl-1 do Line(ss[i],hs[i-1]*brho, ss[i], hs[i]*brho);
        for i:=0 to nsl-1 do Line(ss[i],hs[i]*brho, ss[i+1], hs[i]*brho);
//        moveto(0,0); lineto(0,bavg); lineto(len, bavg); lineto(len,0);
}
      end;
    end;
    2:begin
      etamax:=0;
      for i:=0 to nsl do if etas[i] > etamax then etamax:=etas[i];
      for i:=0 to nsl do if etas_hom[i] > etamax then etamax:=etas_hom[i];
      with fig_HANDLE.Plot do begin
        setcolor(clBlack);
        Clear(clWhite);
        fig_HANDLE.Init(0, 0, len*1.05, etamax*1.05, 1,1,'S [m]','Dispersion [m]',3,false);
        setcolor(clBlue); setThick(3);
        moveto(ss_hom[0],etas_hom[0]); for i:=1 to nsl do LineTo(ss_hom[i],etas_hom[i]);
       setcolor(clRed); setThick(3);
        moveto(ss[0],etas[0]); for i:=1 to nsl do LineTo(ss[i],etas[i]);
      end;
    end;
    3:begin
      betamax:=0;
      for i:=0 to nsl do if betas[i] > betamax then betamax:=betas[i];
      for i:=0 to nsl do if betas_hom[i] > betamax then betamax:=betas_hom[i];
      with fig_HANDLE.Plot do begin
        setcolor(clBlack);
        Clear(clWhite);
        fig_HANDLE.Init(0, 0, len*1.05, betamax*1.05, 1,1,'S [m]','Beta [m]',3,false);
        setcolor(clBlue); setThick(3);
        moveto(ss_hom[0],betas_hom[0]);  for i:=1 to nsl do LineTo(ss_hom[i],betas_hom[i]);
        setcolor(clRed); setThick(3);
        moveto(ss[0],betas[0]);  for i:=1 to nsl do LineTo(ss[i],betas[i]);
      end;
//writeln(diagfil,'makeplot positions');
//for i:=0 to nsl do write(diagfil,ss[i]:8:4); writeln(diagfil);
//writeln(diagfil,'makeplot betas');
//for i:=0 to nsl do write(diagfil,betas[i]:8:4); writeln(diagfil);
    end;
  end;
end;

procedure LGBcreate(bn: string);
var
  j,i,iomk,ib: integer;
  bang, bein, beot, kbmax: double;
  sn, kbvarnam: string;
  p: AEpt;
begin
// if we want to scale the transverse gradient, introduce a variable for attenuation:
  if setkbmax then begin
    kbvarnam:=bn+'kpw'+inttostr(round(polwid*1000));
    setLength(variable, Length(variable)+1);
    with variable[High(variable)] do begin
      nam:=kbvarnam;
      val:=0;
      exp:='';
    end;
//    hsmax:=-1000; for i:=0 to nsl do if hs[i]>hsmax then hsmax:=hs[ib];
  end;

  iomk:=0; // preliminary; ok for SBM, but optics marker better at focus for ABM (requires slice split);
  beot:=0;
  j:=Glob.NElem+1;
  ib:=0;
  for i:=0 to nsl do begin
    if i=iomk then begin
      with Elem[j+i] do begin
        cod:=comrk;
        nam:=bn+'OM';
        IniElem(j+i);
        om^.bet[1]:=beta0;
        om^.bet[2]:=alfa0;
        om^.eta[1]:=eta0;
        om^.eta[2]:=etap0;
      end;
    end else begin
      bein:=-beot;
      bang:=hs[ib]*ds[ib];
      beot:=beot+bang;
      sn:=inttostr(ib);
      if ib<10 then sn:='0'+sn;
      sn:=bn+sn;
      with  Elem[j+i] do begin
        cod:=cbend;
        nam:=sn;
        IniElem(j+i);
        l:=ds[ib];
        phi:=bang;
        tin:=bein;
        tex:=beot;
        if setkbmax then begin
//          if hs[ib] > 0.5*hsmax then kbmax:=(hsmax-hs[ib])/polwid else kbmax:=hs[ib]/polwid ;
          if hs[ib] > 0.5*hsmax then kbmax:=(hsmax-hs[ib])/polwid else kbmax:=hs[ib]/polwid*(hs[ib]/(0.5*hsmax));
//          writeln(diagfil, hsmax, hs[ib], polwid, kbmax);
          kb_exp :=New(Elem_Exp_pt);
          kb_exp^:=FtoS(kbmax,10,6)+'*'+kbvarnam;
          kb:=kbmax;
        end else kb:=0;
      end;
      inc(ib);
    end;
  end;
  Inc(Glob.NElem,nsl+1);


  Inc(Glob.NSegm);
  for i:=Glob.NSegm downto 2 do Segm[i]:=Segm[i-1];
  New(p);
  with Segm[1] do begin
    nam :=bn;
    ini :=nil;
    nper:=1;
    for i:=0 to nsl do begin
      p:=AppendAE(p,Elem[j+i].nam);
//if (p^.kin=ele) then opamessage(0, 'p.kin = ele '+p^.nam) else opamessage(0,'p.kin = seg '+p^.nam);
      if i=0 then begin
        ini:=p;
        p^.pre:=nil;
      end;
      if i=nsl then begin
        fin:=p;
        p^.nex:=nil;
      end;
    end; //i
  end;
end;

procedure LGBdelete(bn: string);
var
  ae: aept;
  i, j, k, iseg, ndel, ivarfnd: integer;
  fnd: boolean;
  delelist: array[0..100] of integer; //don't expect more than 100 slices
begin
  for i:=1 to Glob.NSegm do with Segm[i] do begin
    if bn=nam then begin
      iseg:=i;
      ae:=ini;
      k:=0;
      while (ae<>nil) do begin
        j:=0; repeat Inc(j); until Elem[j].nam = ae^.nam;
        delelist[k]:=j;
        Inc(k);
        ae:=ae^.nex;
      end;
    end;
  end;
  ndel:=k;
  i:=0;
  for j:=0 to Glob.NElem do begin
    fnd:=false;
    for k:=0 to ndel-1 do fnd:=fnd or (j=delelist[k]);
    if not fnd then begin
      Elem[i]:=Elem[j];
      Inc(i);
    end;
  end;
  Dec(Glob.NElem,ndel);
  for i:=iseg to Glob.NSegm-1 do Segm[i]:=Segm[i+1];
  Dec(Glob.NSegm);
  ivarfnd:=-1;
  for i:=0 to High(Variable) do begin
    if (Pos(UpperCase(bn+'kpw'),UpperCase(Variable[i].nam))=1) then ivarfnd:=i;
//    writeln(diagfil,bn+'kpw', '|', Variable[i].nam,'|', i,'|',ivarfnd,'|',Pos(UpperCase(bn+'kpw'),UpperCase(Variable[i].nam)));
  end;
  if (ivarfnd <> -1) then begin
    Variable[ivarfnd]:=Variable[High(Variable)];
    setLength(Variable, length(Variable)-1);
  end;
end;

end.
