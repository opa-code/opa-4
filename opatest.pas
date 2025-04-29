unit opatest;

{$MODE Delphi}

interface

uses OPAglobal, OpticPlot, asaux, sysutils, Classes, strutils, dialogs, mathlib;

 procedure readkvalues;
 procedure magparams;
 procedure undulator_export;
 procedure bdpattern_export;
 procedure ele_aper_export;

//procedure Ctouschek_table;
//procedure Eulertest;
//function combination(n,k: integer): double;


implementation

procedure Readkvalues;

const
//  csmul=1.1345;
  csmul=-1.0;
  qamul=1.0;
  csfile='b073_skew';
  qafile='nonexistent';
//  qafile='ID_corr_1';
//  csfile='skew_1';

var
 tfIn: textfile;
 line, kfile, nind, sval: string;
 err, nco,j: integer;
 kval: real;

begin

  kfile:=work_dir+csfile+'.out';
  AssignFile(tfIn, kfile);
  try
    reset(tfIn);
    // Keep reading lines until the end of the file is reached
    nco:=0;
    while not Eof(tfIn) do begin
      readln(tfIn, line);
      if Pos('#',line)=0 then begin
        nind:=Extractword(1,line,[' ']);
        while length(nind)<3 do nind:='0'+nind;
        nind:=oco_csname+nind;
//        writeln(diagfil, nind);
        for j:=1 to Glob.Nella do if Ella[j].cod=cquad then if Ella[j].nam=nind then begin
          sval:=Extractword(4,line,[' ']);
          {$R-}
          Val(sval,kval,err);
          {$R+}
          if err<>0 then kval:=0 else inc(nco);
kval:=kval*csmul;
          if Ella[j].l>1e-6 then Ella[j].kq:=kval/Ella[j].l;
//          writeln(Ella[j].nam, ' ', Ella[j].kq);
        end;
      end;
    end;
    CloseFile(tfIn);
    MessageDlg(inttostr(nco)+' k-values read from '+kfile, MtInformation, [mbOK],0);
  except
    on E: EInOutError do
    MessageDlg('Could not read '+kfile+'. '+E.Message, MtError, [mbOK],0);
  end;

  kfile:=work_dir+qafile+'.out';
  AssignFile(tfIn, kfile);
  try
    reset(tfIn);
    // Keep reading lines until the end of the file is reached
    nco:=0;
    while not Eof(tfIn) do begin
      readln(tfIn, line);
      if Pos('#',line)=0 then begin
        nind:=Extractword(2,line,[' ']);
        while length(nind)<3 do nind:='0'+nind;
        nind:=oco_qaname+nind;
//        writeln(diagfil, nind);
        for j:=1 to Glob.Nella do if Ella[j].cod=cquad then if Ella[j].nam=nind then begin
          sval:=Extractword(3,line,[' ']);
          {$R-}
          Val(sval,kval,err);
          {$R+}
          if err<>0 then kval:=0 else inc(nco);
kval:=kval*qamul;
          if Ella[j].l>1e-6 then Ella[j].kq:=kval/Ella[j].l;
//          Ella[j].kq:=kval;
//          writeln(Ella[j].nam, ' ', Ella[j].kq);
        end;
      end;
    end;
    CloseFile(tfIn);
    MessageDlg(inttostr(nco)+' k-values read from '+kfile, MtInformation, [mbOK],0);
  except
    on E: EInOutError do
    MessageDlg('Could not read '+kfile+'. '+E.Message, MtError, [mbOK],0);
  end;

end;

procedure MagParams;
const
  Cmagparam: array [0..8] of integer =
    (Cbend,Ccomb,Cquad,Csole,Csext,Cmpol,Csept,Ckick,Cundu);
  mpolnam: array[1..6] of elemstr =
    ('dipole','quadrupole','sextupole','octupole','decapole','dodecapole');
var
  i, j: integer;
  brho: real;
  fname, mnam, smpm, smpm1, smpm2: string;
  fo: textfile;
begin
  fname:=ExtractFileName(FileName);
  fname:=work_dir+Copy(fname,0,Pos('.',fname)-1)+'_magpar.txt';
  assignFile(fo,fname);
  try
    rewrite(fo);
    brho:=glob.energy*1E9/speed_of_light;
    for i:=0 to 8 do begin
      for j:=1 to Glob.NElem do with Elem[j] do if cod = Cmagparam[i] then begin
        case cod of
          cbend: begin
            writeln(fo); writeln(fo,Nam+': bending magnet');
            writeln(fo, '  arc length [m]   = ', l:9:6);
            writeln(fo, '  angle      [deg] = ', phi*degrad:9:6);
            writeln(fo, '  entry edge [deg] = ', tin*degrad:9:6);
            writeln(fo, '  exit  edge [deg] = ', tex*degrad:9:6);
            writeln(fo, '  full gap   [mm]  = ', gap*1000:8:3);
            writeln(fo, '  entry fringe K1  = ', k1in:6:3);
            writeln(fo, '  entry fringe K2  = ', k2in:6:3);
            writeln(fo, '  exit  fringe K1  = ', k1ex:6:3);
            writeln(fo, '  exit  fringe K2  = ', k2ex:6:3);
            writeln(fo, '  field B     [T]  = ', phi/l*brho:9:5);
            writeln(fo, '  gradient B''[T/m] = ', kb*brho:9:4);
          end;
          ccomb: begin
            writeln(fo); writeln(fo,Nam+': combined function ');
            writeln(fo, '  arc length [m]   = ', l:9:6);
            writeln(fo, '  angle      [deg] = ', cphi*degrad:9:6);
            writeln(fo, '  entry edge [deg] = ', cerin*degrad:9:6);
            writeln(fo, '  exit  edge [deg] = ', cerex*degrad:9:6);
            writeln(fo, '  full gap   [mm]  = ', cgap*1000:8:3);
            writeln(fo, '  entry fringe K1  = ', cek1in:6:3);
            writeln(fo, '  exit  fringe K1  = ', cek1ex:6:3);
            writeln(fo, '  field B     [T]  = ', cphi/l*brho:9:5);
            writeln(fo, '  gradient B''[T/m] = ', ckq*brho:9:4);
            writeln(fo, '  curv. B"/2[T/m2] = ', cms*brho:9:4);
          end;
          cquad: begin
            writeln(fo); writeln(fo,Nam+': quadrupole');
            writeln(fo, '  length [m]       = ', l:9:6);
            writeln(fo, '  gradient B''[T/m] = ', kq*brho:9:4);
          end;
          csole: begin
            writeln(fo); writeln(fo,Nam+': solenoid');
            writeln(fo, '  length [m]       = ', l:9:6);
            writeln(fo, '  field B [T]      = ', 2*ks*brho:9:4);
          end;
          csext: begin
            writeln(fo); writeln(fo,Nam+': sextupole');
            if l=0 then writeln(fo, '  int B"/2*L [T/m] = ', ms*l*brho:9:3)
            else begin
              writeln(fo, '  length [m]       = ', l:9:6);
              writeln(fo, '  curv. B"/2[T/m2] = ', ms*brho:9:4);
            end;
          end;
          cmpol: begin
            if abs(nord)>7 then mnam:=inttostr(2*(abs(nord)))+'-mpole' else mnam:=mpolnam[abs(nord)];
            smpm:=inttostr(abs(nord)); smpm1:=inttostr(abs(nord)-1);  smpm2:=inttostr(abs(nord)-2);
            writeln(fo); writeln(fo,Nam+': '+mnam+' ( n = '+smpm+' )');
            if lmpol=0 then writeln(fo, '  B('+smpm1+')L/'+smpm1+'![T/m^'+smpm2+'] = ', bnl*brho:12:3)
            else begin
               writeln(fo, '  length [m]       = ', lmpol:9:6);
               writeln(fo, '  B('+smpm1+')/'+smpm1+'! [T/m^'+smpm1+'] = ', bnl/lmpol*brho:12:3)
            end;
          end;
          cundu: begin
            writeln(fo); write(fo,Nam+': undulator');
            if halfu then writeln(fo, ' (half) ') else writeln(fo, ' (full) ');
            writeln(fo, '  length [m]       = ', l:9:6);
            writeln(fo, '  period [mm]      = ', lam:9:6);
            writeln(fo, '  peak field [T]   = ', bmax:9:4);
            writeln(fo, '  full gap   [mm]  = ', ugap*1000:8:3);
            writeln(fo, '  fill factor B    = ', fill1:8:5);
            writeln(fo, '  fill factor B^2  = ', fill2:8:5);
            writeln(fo, '  fill factor B^3  = ', fill3:8:5);
          end;
          csept: begin
            writeln(fo); writeln(fo,Nam+': septum');
            writeln(fo, '  straight len.[m] = ', l:9:6);
            writeln(fo, '  distance   [mm]  = ', dis:9:6);
            writeln(fo, '  thickness  [mm]  = ', thk:9:6);
          end;
          ckick: begin
            writeln(fo); writeln(fo,Nam+': kicker');
            writeln(fo, '  length [m]       = ', l:9:6);
            writeln(fo, '  multipole order  = ', mpol:5);
            writeln(fo, '  kick at Xo [mrad]= ',amp:9:6);
            writeln(fo, '  ref.pos Xo [mm]  = ',xoff*1000:9:6);
            writeln(fo, '  half sine [nsec] = ',tau*1E9:9:3);
            writeln(fo, '  delay     [nsec] = ',delay*1E9:9:3);
          end;
          else;
        end;
      end;
    end;
    CloseFile(fo);
    MessageDlg('Magnet parameters written to '+fname, MtInformation, [mbOK],0);
  except
    on E: EInOutError do
    MessageDlg('Could not write '+fname+'. '+E.Message, MtError, [mbOK],0);
  end;
end;



procedure undulator_export;
// starting an export to SPECTRA code, incomplete
// undu HAS to be defined in 2 halfs: UND,x,y,z,-UND with option HALF in undulator, and x,y,z length=0 elements
var
  i, iupre, jel, npole: integer;
  {Emitx, Emity, }lamu, kvalx, kvaly, itot, coup: real;
  fsp: textfile;
  fnam, fnam0: string;

begin
  // check status, periodic, undulators, etc.
  // assume that a solution for the lattice, betas etc, exists



  AllocOpval;
  MomMode:=False;
  ncurves:=0;
  //Permode:=True;
  // start forward from initial values, whatever they are:
  Linop(0,0,do_twiss+do_radin, 0.0);

  coup:=FDefGet('trackt/coup')/100;
  itot:=FDefGet('trackt/itot');

  fnam:=ExtractFileName(FileName);
  fnam0:=Copy(fnam,0,Pos('.',fnam)-1);
  fnam:=work_dir+fnam0+'.prm';
  assignFile(fsp, fnam);
  try
    rewrite(fsp);
    writeln(fsp, '[ACCELERATOR]');
    writeln(fsp, 'Name    ',fnam0);
    writeln(fsp, 'eGeV    ', Glob.Energy:6:3);
    writeln(fsp, 'imA     ',itot:6:3);
    with oBeam[0] do begin
      if not status.uncoupled then coup:=Emitb/Emita;
// (temp solution, spectra uses simple coupling model neglecting Jx,Jy)
      writeln(fsp, 'cirm    ', circ:9:3);
      writeln(fsp, 'emitt   ', ftos(Emita,-4,6));
      writeln(fsp, 'coupl    ',abs(coup):9:7);
      writeln(fsp, 'espread ', sigmaE:9:7);
    end;
    iupre:=-1;
    writeln(fsp, '[SOURCE]');
    for i:=1 to Glob.NLatt do begin
      jel:=findel(i);
      if Ella[jel].cod=cundu then begin
        if iupre = -1 then iupre:=i else begin //found 2nd half of undu, no l>0 elements between
          jel:=findel(iupre);// do the export  after iupre
          with Ella[jel] do begin
            writeln(fsp, 'Name    ', nam);
            //writeln(diagfil, jel,' ', iupre, ' ', i, ' ',ella[jel].nam);
            npole:=round(2*l/lam);
            lamu:=2*l/npole;
            kvaly:=bmax*lamu/2/pi/electron_mc2*speed_of_light;
            kvalx:=0;
            //opa uses implicitly "end correction magnets" option of Spectra
            writeln(fsp, 'length ',2*l-2*lamu:6:3);
            writeln(fsp, 'lu     ',lamu*100:6:3);
            writeln(fsp, 'kx     ',kvalx:6:3);
            writeln(fsp, 'ky     ',kvaly:6:3);
            writeln(fsp, 'gap    ',ugap*1000:6:3);
          end;
          with Opval[0,iupre] do begin
            //writeln(fsp, 'spos ',spos:8:3);
            writeln(fsp, 'betax   ',beta:8:4);
            writeln(fsp, 'alphax  ',alfa:8:4);
            writeln(fsp, 'betay   ',betb:8:4);
            writeln(fsp, 'alphay  ',alfb:8:4);
            writeln(fsp, 'eta     ',disx:8:5);
            writeln(fsp, 'deta    ',dipx:8:5);
            writeln(fsp, 'etay    ',disy:8:5);
            writeln(fsp, 'detay   ',dipy:8:5);
          end;
          writeln(fsp, '----------------------------------------------------------');
        end;
      end else if Ella[jel].l > 0 then iupre:=-1;
    end;
    CloseFile(fsp);
  except
    on E: EInOutError do opaLog(1, 'File handling error occurred. Details: '+E.Message);
  end;
end;




// yet incomplete export of bd patterms to masamitsu's master generator June 2020
procedure bdpattern_export;
var
  fbd: textfile;
  fnam: string;
  ic,j: integer;
  icfound: boolean;
  snam: string;
begin
  fnam:=ExtractFileName(FileName);
  fnam:=Copy(fnam,0,Pos('.',fnam)-1);
  fnam:=work_dir+'BDpattern.'+fnam+'.py';
  assignFile(fbd, fnam);
  try
    rewrite(fbd);

    for ic:=0 to Nelemkind do begin
      icfound:=false;
      for j:=1 to Glob.NElem do begin
        with elem[j] do begin
          if cod=ic then begin
            icfound:=true;
            snam:=Elem[j].nam;
            snam:='Strength['''+snam+''']=';
            case cod of
              cquad: writeln(fbd,snam+FtoS(kq,12,9));
              cbend: writeln(fbd,snam+FtoS(kb,12,9));
              csext: writeln(fbd,snam+FtoS(ms,12,9)); // always l>0
              ckick: ;
              csept: ;
              ccomb: writeln(fbd,snam+FtoS(ckq,12,9));
              cmpol: writeln(fbd,snam+FtoS(bnl,12,7));
              else; //nothing
            end;
          end;
        end;
      end;
      if icfound then writeln(fbd);
    end;

    CloseFile(fbd);
  except
    on E: EInOutError do
      opaLog(1, 'File handling error occurred. Details: '+E.Message);
  end;
end;

procedure ele_aper_export;
//aperture export to elegant (perhaps include automatically in elegant export)
var
  fap: textfile;
  fnam: string;
  i,j: integer;
  spos: double;
begin
  fnam:=ExtractFileName(FileName);
  fnam:=Copy(fnam,0,Pos('.',fnam)-1);
  fnam:=work_dir+fnam+'_'+Segm[iactseg].nam+'.ap';
  assignFile(fap, fnam);
  try
    rewrite(fap);
    writeln(fap, 'SDDS1ASTRA2ELEGANT2003');
    writeln(fap, '&column name=s, units=m, type=double, &end');
    writeln(fap, '&column name=xHalfAperture, units=m, type=double, &end');
    writeln(fap, '&column name=yHalfAperture, units=m, type=double, &end');
    writeln(fap, '&column name=xCenter, units=m, type=double, &end');
    writeln(fap, '&column name=yCenter, units=m, type=double, &end');
    writeln(fap, '&data mode=ascii, &end');
    writeln(fap, '! page number 1');

    writeln(fap, Glob.NLatt*2);
    spos:=0;
    for i:=1 to Glob.Nlatt do begin
      j:=Findel(i);
      with Ella[j] do begin
        writeln(fap, spos, ax*1e-3, ay*1e-3, ' 0.0 0.0');
        spos:=spos+l;
        writeln(fap, spos, ax*1e-3, ay*1e-3, ' 0.0 0.0');
      end;
    end;
    CloseFile(fap);
  except
    on E: EInOutError do
      opaLog(1, 'File handling error occurred. Details: '+E.Message);
  end;
end;




{ ************* DEAD BODIES ********************** }


{
// das war nur eine Tabellierung der Touschek Funktion --> kann weg
procedure Ctouschek_table;
var
  i, n: integer;
  z: double;

begin
  n:=1000;
  for i:=0 to n do begin
    z:=PowR(10,-3.5+5.5*i/n);
    writeln(diagfil,z, Ctouschek(z), Ctouschek_pol(z));
  end;
end;
}

{
// test der Euler Winkel --> kann weg
procedure Eulertest;
var
  rom: matrix_3;
  ainy, ainx, ains, ay, ax, ass: double;
begin
  ainy:=12;
  ainx:=90;
  ains:=13;

  rom:=MatMul3(RotMat3(1,raddeg*ains), MatMul3(RotMat3(2,raddeg*ainx), RotMat3(3,raddeg*ainy)));
  EulerAng(rom, ay, ax, ass, false);
  writeln(diagfil, 'input ', ainy:8:2, ainx:8:2, ains:8:2);
  writeln(diagfil, 'eulr1 ', ay*degrad:8:2, ax*degrad:8:2, ass*degrad:8:2);
  EulerAng(rom, ay, ax, ass, true);
  writeln(diagfil, 'eulr2 ', ay*degrad:8:2, ax*degrad:8:2, ass*degrad:8:2);
  writeln(diagfil);
  printmat3(rom);
  writeln(diagfil);


end;
}


{
//only a test for efficient calculation of binominal coefficients, not used in OPA.
//becomes wrong for very large numbers, probably due to round-off, to be improved using other data types.
//but ok tested for n~50
function combination(n,k: integer): double;
var
  g,s,i: integer; x: double;
begin
  if k > n /2 then begin
    g:=k; s:=n-k;
  end else begin
     g:=n-k; s:=k;
  end;
  if s < 0 then combination:=0 else if s = 0 then combination:=1 else begin
    x:=1;
    for i:=1 to s do begin
      x:=x*(g+i);
      x:=x/i;
    end;
    combination:=x;
  end;
end;
}


end.
