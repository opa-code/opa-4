unit latfilelib;
{reading and writing *.opa lattice files
 export of lattice to tracy2+3, elegant, madx, bmad
 madx, bmad very basic only
 exports/imports are incomplete and may require further manual editing
 procs moved from globlib and testcode to this new unit 25.7.2024}

{$mode Delphi}

interface

uses
  globlib, asaux, mathlib,
  Dialogs, StrUtils, Classes, SysUtils;

procedure LatReadCom (TextBuffer: Pointer);
procedure LatRead (TextBuffer: pointer);
procedure ReadAllocation;
procedure ReadCalibration;
function  WriteLattice (latcode_in:integer): string;

procedure madseqconvert(seqfile:string; var TextBuffer: pointer);
procedure madconvert(madfile:string; var TextBuffer: pointer);
procedure lteconvert(ltefile:string; var TextBuffer: pointer);


implementation


procedure LatReadCom (TextBuffer: Pointer);
// to be called after Latread, searches for the comment
var
  s: AnsiString;
  chpt: CharBufPt;
  ici, icf: integer;
begin
  chpt:=TextBuffer; s:='';
  while chpt<>nil do begin
    s:=s+chpt^.ch;
    chpt:=chpt^.nex;
  end;
  ici:=Pos('{com',s);
  icf:=Pos('com}',s);
  if (ici>0) and (icf>0) then glob.text:=Copy(s,ici+5,icf-ici-6);
  s:='';
end;

procedure LatRead (TextBuffer: Pointer);
{TRACY style text lattice file, as-231296}
{replaced old buffer lines by string arrays}

const
  nglobkeyw=15;
  globkeyw: array[1..nglobkeyw] of string_12 =
        ('ENERGY','BETAX','BETAY',
         'ALPHAX','ALPHAY','ETAX','ETAY','ETAXP','ETAYP',
         'ORBITX','ORBITY','ORBITXP','ORBITYP','DPP','ROTINV');


var
  lats      : array of AnsiString;
  tok       : array of ShortString;
  line      : string;
  elemkeyw  : array[0..NElemKind+2] of string[12];
  temp, name: ElemStr;
  gpar, spar: string_12;
  sval      : string;
  chpt      : CharBufPt;
  p         : AEpt;
  xv        : real;
  copyflag  : boolean;
  icode,  {errvcode,} i, k, kt, i2, i3, i4, i8: integer;
  ilin: word;
  errint, nord_tmp: integer;
  keywfound, varfound: boolean;
  erreval, isexp: boolean;


begin
  GlobInit;
  chpt:=TextBuffer;

  for i:=0 to NElemKind do elemkeyw[i]:=UpperCase(ElemName[i]);
// for compatibility:
  elemkeyw[NElemKind+1]:='OCTUPOLE';
  elemkeyw[NElemKind+2]:='DECAPOLE';

// copy all non-comment text in string array, separate by ;
  setlength(lats,1);
  chpt:=TextBuffer;
  copyflag:=true;
  while chpt <> nil do begin
    case chpt^.ch of
      '{': copyflag:=false;
      '}': copyflag:=true;
      ';': if copyflag then setlength(lats,Length(lats)+1);
      else if copyflag then lats[high(lats)]:=lats[high(lats)]+UpCase(chpt^.ch);
    end;
    chpt:=chpt^.nex;
  end;

//crashes here if the textbuffer is empty
  for ilin:=0 to High(lats) -1 do begin
    line:=lats[ilin];

    i2:=Pos(':',line);
    if i2=0 then begin {must be one of the global parameters or a Variable}
{..........................................................................}
      i3:=Pos('=',line);
      if i3>0 then begin
        gpar:=Uppercase(TB(copy(line,1,i3-1)));
        sval:=TB(copy(line,i3+1,length(line)));
//        if Pos('=',sval)>0 then ErrLogHandle.lines.append('LATTICE ERROR > invalid input line : '+line);
        if Pos('=',sval)>0 then OpaLog(1,'Lattice: invalid input line : '+line);
        if gpar = 'TITLE' then glob.text:=glob.text+sval
        else if gpar = 'ALLOCATION' then begin
          allocationFile:=work_dir+sval; allocationFlag:=true;
          if (Pos('.dat',allocationFile)=0) and (Pos('.DAT',allocationFile)=0)
          then allocationFile:=allocationFile+'.dat';
        end else if gpar = 'CALIBRATION' then begin
          calibrationFile:=work_dir+sval; calibrationFlag:=true;
          if (Pos('.dat',calibrationFile)=0) and (Pos('.DAT',calibrationFile)=0)
          then calibrationFile:=calibrationFile+'.dat';
        end else begin
          keywfound:=false;
          for i:=1 to nglobkeyw do begin
            if globkeyw[i]=gpar then begin
              keywfound:=true;
//              Val(sval,xv,errvcode);
              Val(sval,xv);
              case i of
                 1: Glob.Energy        :=xv;
                 2: Glob.Op0.beta      :=xv;
                 3: Glob.Op0.betb      :=xv;
                 4: Glob.Op0.alfa      :=xv;
                 5: Glob.Op0.alfb      :=xv;
                 6: Glob.Op0.disx      :=xv;
                 7: Glob.Op0.disy      :=xv;
                 8: Glob.Op0.dipx      :=xv;
                 9: Glob.Op0.dipy      :=xv;
                10: Glob.Op0.orb[1]    :=xv;
                11: Glob.Op0.orb[2]    :=xv;
                12: Glob.Op0.orb[3]    :=xv;
                13: Glob.Op0.orb[4]    :=xv;
                14: Glob.dpp           :=xv;
                15: Glob.rot_inv       :=(xv=1);
                    //false by default, activate inversion of rotations by ROTINV=1
              end;
            end;
          end;
          if not keywfound then begin {is a variable}
// check, if a variable of this name exists already:
            varfound:=false;
            for i:=0 to High(Variable) do varfound:=varfound or (gpar = Variable[i].nam);
            if varfound then begin
//              ErrLogHandle.Lines.Append('LATTICE ERROR > duplicate variable '+gpar);
              OpaLog(1,'Lattice:  duplicate variable '+gpar);
            end else begin
//try conversion into number, if it fails it probably is an expression
              erreval:=false;
{$R-}
              Val(sval,xv,errint);
{$R+}
              xv:=Eval_Exp(sval,erreval); //(evaluation also works for pure numbers)

              if ((errint<>0) and erreval) then begin // failure only if not a number AND invalid expr.
//                ErrLogHandle.Lines.Append('LATTICE ERROR > expression "'+gpar+' = '+sval+'" : '+Eval_exp_errmess);
                OpaLog(1,'Lattice: error in expression "'+gpar+' = '+sval+'" : '+Get_Eval_exp_errmess);
              end else begin
// create new variable, evaluate AND store expression
                setLength(variable, Length(variable)+1);
                with variable[High(variable)] do begin
                  nam:=gpar;
                  val:=xv;
                  if errint=0 then exp:='' else exp:=sval;
                  use:=false;
                end; // no error in evaluation
              end; // variable not found
            end; // keyword not found
          end; // check global keywords loop
        end; // is not a filename for allocation or calibration
      end;  // = sign in input line
{..........................................................................}
    end   // no : sign in input line  {end of extracting global parameters and variables}

    else begin   {must be an element or a lattice segment}
{..........................................................................}
      name:=TB(copy(line,1,i2-1));
// check for duplicate entries:
//for i:=1 to Glob.NElem do if name=Elem[i].nam then ErrLogHandle.Lines.Append('LATTICE ERROR > duplicate entry: '+name);
//for i:=1 to Glob.NSegm do if name=Segm[i].nam then ErrLogHandle.Lines.Append('LATTICE ERROR > duplicate entry: '+name);
      for i:=1 to Glob.NElem do if name=Elem[i].nam then OpaLog(1,'Lattice: duplicate entry: '+name);
      for i:=1 to Glob.NSegm do if name=Segm[i].nam then OpaLog(1,'Lattice: duplicate entry: '+name);

      line:=TB(copy(line,i2+1,length(line)));
//      if Pos(':',line)>0 then ErrLogHandle.Lines.Append('LATTICE ERROR > invalid input line : '+line);
      if Pos(':',line)>0 then OpaLog(1,'Lattice: invalid input line : '+line);

// comma separated tokens for element or segment. string before colon =name
      setlength(tok,1);
      for k:=1 to Length(line) do
        if line[k]=',' then setlength(tok,length(tok)+1)
        else if line[k]<>' ' then tok[high(tok)]:=tok[high(tok)]+line[k];

//      for k:=0 to high(tok) do write(diagfil, tok[k], ' | '); writeln(diagfil);

      icode:=99;
      for i:=0 to NElemKind+2 do if Pos(elemkeyw[i],tok[0])=1 then icode:=i;

      if icode<99 then begin     {Element identified}
{. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .}
        Inc(Glob.NElem);
        with Elem[Glob.NElem] do begin
          Elem[Glob.NElem].Nam := name;
// special treatment for octupole and decapole appearing in old lattice files
          nord_tmp:=0;
          case icode of
            NElemKind+1: begin
              Cod:=cmpol;
              nord_tmp:=4;
            end;
            NElemKind+2: begin
              Cod:=cmpol;
              nord_tmp:=5;
            end;
            else Cod := icode;
          end;
        end;
        if icode=cundu then status.undulators:=true;
        IniElem(Glob.NElem);
        if Elem[Glob.NElem].cod=cmpol then Elem[Glob.NElem].nord:=nord_tmp;

        for i:=1 to high(tok) do begin    {read element parameters K,L,etc.}
          i8:=Pos('=',tok[i]);
          if i8>0 then begin
            temp:= TB(Copy(tok[i],1,i8-1));
            sval:= TB(Copy(tok[i],i8+1,255));
//try conversion into number, if it fails it probably is an expression
{$R-}
            Val(sval,xv,errint);
{$R+}
// this is being accepted for all properties even if not allowed to assign expressions!

            isexp:=(errint <> 0);
            if isexp then begin
              xv:=Eval_Exp(sval,erreval);
              if erreval then begin
                xv:=0;
//                ErrLogHandle.Lines.Append('LATTICE ERROR > expression "'+temp+' = '+sval+'" : '+Eval_exp_errmess);
                OpaLog(1,'Lattice:  expression "'+temp+' = '+sval+'" : '+Get_Eval_exp_errmess);
              end;
            end;
          end else begin // flag only, there is no = sign
            temp:= TB(tok[i]);
            xv:=0;
            isexp:=false;
          end;



          with elem[glob.nelem] do begin
              if temp='L'  then begin
                if ElemThick[cod] then begin
                  l:=xv; if isexp then begin l_exp:=New(Elem_Exp_pt); l_exp^:=sval; end;
                end else l:=0;
              end
              else if temp='AX' then ax:=xv
              else if temp='AY' then ay:=xv
              else if temp='ROT' then begin
                rot:=raddeg*xv; if isexp then begin rot_exp:=New(Elem_Exp_pt); rot_exp^:=sval; end
              end
              else begin
                case cod of
                  cdrif: begin
                           if temp='BLOCK' then block:=true;
                         end;
                  cquad: begin
                           if temp='K' then begin
                             kq:=xv;  if isexp then begin kq_exp:=New(Elem_Exp_pt); kq_exp^:=sval; end;
                           end;
                         end;
                  csext: begin
                           if temp='K' then ms:=xv;
                           if temp='N' then sslice:=round(xv);
                           if sslice<1 then sslice:=1;
                         end;
                  cbend: begin
                           if temp='K'  then begin
                             kb:=xv; if isexp then begin kb_exp:=New(Elem_Exp_pt); kb_exp^:=sval; end;
                           end;
                           if temp='T'  then begin
                             phi:=raddeg*xv; if isexp then begin phi_exp:=New(Elem_Exp_pt); phi_exp^:=sval; end;
                           end;
                           if temp='T1' then begin
                             tin:=raddeg*xv; if isexp then begin tin_exp:=New(Elem_Exp_pt); tin_exp^:=sval; end;
                           end;
                           if temp='T2' then begin
                             tex:=raddeg*xv; if isexp then begin tex_exp:=New(Elem_Exp_pt); tex_exp^:=sval; end;
                           end;
                           if temp='GAP' then gap:=xv/1000;
                             //set both edges same if nothing specified
                           if temp='K1' then begin k1in:=xv; k1ex:=xv; end;
                           if temp='K2' then begin k2in:=xv; k2ex:=xv; end;
                           if temp='K1IN'  then k1in:=xv;
                           if temp='K1EX'  then k1ex:=xv;
                           if temp='K2IN'  then k2in:=xv;
                           if temp='K2EX'  then k2ex:=xv;
                         end;
                  csole: begin
                           if temp='K' then ks:=xv;
                         end;
                  cundu: begin
                           if temp='LAMB' then lam:=xv;
                           if temp='BMAX' then bmax:=xv;
                           if temp='GAP' then ugap:=xv/1000;
                           if temp='F1' then fill1:=xv;
                           if temp='F2' then fill2:=xv;
                           if temp='F3' then fill3:=xv;
                           if temp='HALF' then halfu:=true;
                          end;
                  ckick: begin
                           if temp='K' then amp:=xv; //amp is kick in mrad at xoff
                           if temp='X' then xoff:=xv*1e-3; //xoff etc are all SI units
                           if temp='T' then tau:=xv*1e-9;
                           if temp='N' then mpol:=round(xv);
                           if temp='DELAY' then delay:=xv*1e-9;
                           if temp='NK' then kslice:=round(xv);
                         end;
                  csept: begin
                           if temp='ANGLE' then ang:=xv*Pi/180;
                           if temp='DIST'  then dis:=xv;
                           if temp='THICK' then thk:=xv;
                         end;
                  comrk: begin
                           if temp='BETAX'    then om^.bet[1]:=xv;
                           if temp='ALPHAX'   then om^.bet[2]:=xv;
                           if temp='BETAY'    then om^.bet[3]:=xv;
                           if temp='ALPHAY'   then om^.bet[4]:=xv;
                           if temp='ETAX'     then om^.eta[1]:=xv;
                           if temp='ETAXP'    then om^.eta[2]:=xv;
                           if temp='ETAY'     then om^.eta[3]:=xv;
                           if temp='ETAYP'    then om^.eta[4]:=xv;
                           if temp='ORBITX'   then om^.orb[1]:=xv/1000;
                           if temp='ORBITXP'  then om^.orb[2]:=xv/1000;
                           if temp='ORBITY'   then om^.orb[3]:=xv/1000;
                           if temp='ORBITYP'  then om^.orb[4]:=xv/1000;
//                           if temp='ORBITDPP' then om^.dpp:=xv/100;
                           if temp='SCREEN'   then screen:=true;
                           if temp='C11'      then om^.cma[1,1]:=xv;
                           if temp='C12'      then om^.cma[1,2]:=xv;
                           if temp='C21'      then om^.cma[2,1]:=xv;
                           if temp='C22'      then om^.cma[2,2]:=xv;
                         end;
                  ccomb: begin
                           if temp='K'  then begin
                             ckq:=xv; if isexp then begin ckq_exp:=New(Elem_Exp_pt); ckq_exp^:=sval; end;
                           end;
                           if temp='T'  then begin
                             cphi:=raddeg*xv; if isexp then begin cphi_exp:=New(Elem_Exp_pt); cphi_exp^:=sval; end;
                           end;
                           if temp='T1' then begin
                             cerin:=raddeg*xv; if isexp then begin cerin_exp:=New(Elem_Exp_pt); cerin_exp^:=sval; end;
                           end;
                           if temp='T2' then begin
                             cerex:=raddeg*xv; if isexp then begin cerex_exp:=New(Elem_Exp_pt); cerex_exp^:=sval; end;
                           end;
                           if temp='GAP' then cgap:=xv/1000;
                             //set both edges same if nothing specified
                           if temp='K1' then begin cek1in:=xv; cek1ex:=xv; end;
                           if temp='K1IN'  then cek1in:=xv;
                           if temp='K1EX'  then cek1ex:=xv;
                           if temp='M' then cms:=xv;
                           if temp='N' then cslice:=round(xv);
                           if cslice<1 then cslice:=1;
                         end;
                  cxmrk: begin
                           if temp='XL' then xl:=xv;
                           if temp='STYLE' then nstyle:=round(xv);
                           if temp='SNAP' then snap:=1;
                         end;
                  cgird: begin
                           if temp='TYP' then gtyp:=round(xv);
                           if temp='SHIFT' then shift:=xv;
                         end;
                  cmpol: begin
                           if temp='K' then bnl:=xv;
                           if temp='LMAG' then lmpol:=xv;
                           if temp='N' then nord:=round(xv);
                         end;
                  ccorh: begin
                           if temp='DXP' then dxp:=xv/1000.0;
                         end;
                  ccorv: begin
                           if temp='DYP' then dyp:=xv/1000.0;
                         end;
{                  crota: rot already included as basic property; nothing to do}
                end;   //case
            end;    //with
          end;     //else
        end;      //
{. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .}
      end   // icode


      else begin                                   {is a lattice segment}
{. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .}
//        name:=TB(copy(line,1,i2-1));                   {split line}
        inc(Glob.NSegm);
        Segm[Glob.NSegm].nam :=name;
        Segm[Glob.NSegm].ini :=nil;
        Segm[Glob.NSegm].nper:=1;
        New(p);
//first check for segment keywords, up to now only NPER
        k:=0;
        while k<=high(tok) do begin
          name:=tok[k];
          i4:=Pos('=',name);
          if i4>0 then begin
            spar:=Uppercase(TB(copy(name,1,i4-1)));
            sval:=TB(copy(name,i4+1,length(name)));
            if spar='NPER' then begin
//              Val(sval,xv,errvcode);
              Val(sval,xv);
              segm[glob.Nsegm].nper:=Round(xv);
            end;
            for kt:=k to high(tok)-1 do tok[kt]:=tok[kt+1];
            setlength(tok,high(tok));//reduce by 1 element
          end;
          Inc(k);
        end;
        for k:=0 to High(tok) do begin
          name:=tok[k];

{ also accept undefined elements and trust in seglat to clean up!}
//x       if Exist(glob.nelem, glob.nsegm-1, name) then begin}
            p:=AppendAE(p,name);
            if k=0 then begin
              Segm[glob.Nsegm].ini:=p;
              p^.pre:=nil;
            end;
            if k=high(tok) then begin
              Segm[glob.NSegm].fin:=p;
              p^.nex:=nil;
            end;
//x       end;}
        end;
{. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .}
      end;

      tok:=nil;
    end; // was an element or segment

  end; //all lines evaluated

  lats:=nil;
  meth_si4:= false;
  meth_mat:= true;
  status.elements:=glob.nelem>0;
  status.segments:=glob.nsegm>0;

  if calibrationFlag then ReadCalibration;
  if allocationFlag then ReadAllocation;
  status.Currents:=calibrationFlag and allocationFlag;

{ test Lattices made from ALL segments in order to find any error.
  Before, only last segment was used, and errors in other segments, which are
  not called by the active one, were overlooked. But export of those lattices e
  makes tracy crash, and there the bug is hard to find. So check all now.
                                                          as-5.10.2017}
  i:=1;
  repeat
    actseg^.nam:=Segm[i].nam;
    MakeLattice (status.lattice);
    Inc(i);
  until (i>Glob.NSegm) or not (status.lattice);
end;


{=======================================================================}


{ read a file of calibration data, which is in OPA style, i.e. not all parameters
need to be listed. syntax:
type: [imax= , bres= , tlin= , sfac= , isat= , aexp= , nexp= ];
}
procedure ReadCalibration;
var
  f: TextFile;
  s,line: string;
  cal: CalibrationType;
  ip {, ico}: integer;
  x: real;

begin
  // erase all data
  Calibration:=nil;
// read calibration file
  if FileExists(calibrationFile) then begin
    AssignFile(f,calibrationFile);
{$I-}
    reset(f);
{$I+}

  if IOResult =0 then begin
      while not eof(f) do begin
        readln(f,line); line:=UpperCase(line);
        ip:=Pos(':',line);
        cal.typename:=TB(Copy(line,1,ip-1));
        cal.imax:=1E6; cal.bres:=0.0; cal.tlin:=0.0; cal.sfac:=1; cal.isat:=0.0; cal.aexp:=1.0; cal.nexp:=1.0;
        line:=Copy(line,ip+1,300);
        ip:=Pos(',',line);
        while  ip> 0 do begin
          s:=TB(Copy(line,1,ip-1));
          if Pos('LENG',s)>0 then begin
            Val(TB(Copy(s,Pos('=',s)+1,100)),cal.leng{,ico});
          end;
          if Pos('MPOL',s)>0 then begin
            Val(TB(Copy(s,Pos('=',s)+1,100)),cal.mpol{,ico});
          end;
          if Pos('IMAX',s)>0 then begin
            Val(TB(Copy(s,Pos('=',s)+1,100)),cal.imax{,ico});
          end;
          if Pos('BRES',s)>0 then begin
            Val(TB(Copy(s,Pos('=',s)+1,100)),cal.bres{,ico});
          end;
          if Pos('TLIN',s)>0 then begin
            Val(TB(Copy(s,Pos('=',s)+1,100)),cal.tlin{,ico});
          end;
          if Pos('SFAC',s)>0 then begin
            Val(TB(Copy(s,Pos('=',s)+1,100)),cal.sfac{,ico});
          end;
          if Pos('ISAT',s)>0 then begin
            Val(TB(Copy(s,Pos('=',s)+1,100)),x{,ico}); cal.isat:=1.0/x; //store inverse of sat current
          end;
          if Pos('AEXP',s)>0 then begin
            Val(TB(Copy(s,Pos('=',s)+1,100)),cal.aexp{,ico});
          end;
          if Pos('NEXP',s)>0 then begin
            Val(TB(Copy(s,Pos('=',s)+1,100)),cal.nexp{,ico});
          end;
          line:=Copy(line,ip+1,300);
          ip:=Pos(',',line);
          if ip=0 then ip:=Pos(';',line);
        end;
        setLength(Calibration,Length(calibration)+1);
        Calibration[high(Calibration)]:=cal;
      end;
    closefile(f);
    end else calibrationFlag:=false;
  end;

  // test
{
  for i:=0 to high(calibration) do begin
    writeln(Calibration[i].typename,'|',Calibration[i].imax,'|',Calibration[i].bres,'|',Calibration[i].tlin,'|',Calibration[i].isat,'|',Calibration[i].aexp,'|',Calibration[i].nexp);
  end;
}
end;

{
Read a file with allocation of opa names to real names:
opa name, real name, type name, 0, polarity, topology, power supply name
The syntax of this file is NOT checked!
For each OPA-Element, a list of real names etc. is saved as a linked list of NameListpt
15.4.19: include typename too in namelist in order to have individual typenames even in case of no calibration
}
procedure ReadAllocation;
var
  ip, j{, ico}, k: integer;
  f: TextFile;
  line: string;
  opaname, typename, tstr: string_12;
  realname: string_25;
  np: NameListpt;

//  kmin, kmax {placeholder for future minmax limits}, cal: CalibrationType;
begin
  // erase all nameList pointers for all elements
  for j:=1 to Glob.NElem do with Elem[j] do while nl<>nil do begin
    np:=nl;
    nl:=np^.nex;
    dispose(np);
  end;
  // read typedata file
  if FileExists(allocationFile) then begin
    AssignFile(f,allocationFile);
{$I-}
    reset(f);
{$I+}

  if IOResult =0 then begin
      while not eof(f) do begin
      //read one line
        readln (f, line); line:=uppercase(line);
        ip:=pos(',',line); opaname:=trim(copy(line,1,ip-1)); line:=copy(line,ip+1,100);
//search element list if it meets the read opa name (=short name)
        for j:=1 to Glob.NElem do begin
          if CompareText(opaname, Elem[j].nam) =0 then with Elem[j] do begin
            ip:=pos(',',line); realname:=trim(copy(line,1,ip-1)); line:=copy(line,ip+1,100);
            ip:=pos(',',line); typename:=trim(copy(line,1,ip-1)); line:=copy(line,ip+1,100);
            TypNam:=typename;

// create a new Namelist pointer at the end of the list for THIS element
// if the namelist has not yet started:
            if nl=nil then begin
              np:=New(NameListpt);
              nl:=np;
//else set pointer to the end of the list and append:
            end else begin
              np:=nl;
              while np^.nex <> nil do np:=np^.nex;
              np^.nex:=New(namelistpt);
              np:=np^.nex;
            end;
//nex=nil terminates the namelist
            np^.nex:=nil;

//write the real name and the index for the calibration:
            np^.realname:=realname;
            np^.typ_name:=typename;
// look if we have a calibration
            np^.typeindex:=-1;
            for k:=0 to High(Calibration) do if typename=Calibration[k].typename then np^.typeindex:=k;

//parse rest of the input line to get the data (no checks!)
            ip:=pos(',',line);   {skip zero}                 line:=copy(line,ip+1,100);
            ip:=pos(',',line); tstr:=trim(copy(line,1,ip-1)); line:=copy(line,ip+1,100);
            if CompareText(tstr,'pos') =0 then np.polarity:= 1 else
            if CompareText(tstr,'neg') =0 then np.polarity:=-1 else np.polarity:=0; {bipolar}
            ip:=pos(',',line); tstr:=trim(copy(line,1,ip-1)); np.psname:=trim(copy(line,ip+1,100));
            Val(tstr,np.topology{,ico});
          end;
        end;
      end;
    end;
    closefile(f);
  end else allocationFlag:=false;

//test: check the namelists
{
  for j:=1 to Glob.NElem do with Elem[j] do begin
    writeln (nam,'------------------------------------------------------');
    np:=nl;
    while np<>nil do begin
      cal:=Calibration[np.typeindex];
      writeln( np.realname,'|', Calibration[np.typeindex].typename,'|',np.polarity, '|',np.topology, '|',np.psname);

//      case np.polarity of
//      1: begin kmax:=getkfromI(cal, cal.imax); kmin:=getkfromI(cal, 0.0); end;
//      -1:begin kmin:=getkfromI(cal, -cal.imax); kmax:=getkfromI(cal, 0.0); end;
//      0: begin kmin:=getkfromI(cal, -cal.imax); kmax:=getkfromI(cal, cal.imax); end;
//      end;
//      writeln( elem[j].nam, np.realname,'|', kmin:8:3,'|', kmax:8:3);


      np:=np^.nex;
    end;
  end;
}
end;

{-------------------------------------------------------------------------}




{-------------------------------------
general proc to write lattice files for various codes:
opa, elegant, tracy, mad, bmad
as-sept.2014
}

{to do (Apr.2022):
also handle inversion of rotations like inversion of bending magnets, depending
if glob.rot_inv is set or not, i.e. also introduce "inverted" skew quads of
-45 not +45 deg rotation, and generate inverted segments.
}

function WriteLattice (latcode_in:integer): string;

const
  opa=0; tracy=1; elegant=2; madx=3; bmad=4; tracy3=5; // opa(novar) latcode_in =6
  nLatCode=6; // opa, tracy, elegant, madx, bmad, tracy3
  nobendinv=[tracy,madx,bmad]; //programs which cannot invert bends
  sinv='I_';

  cr=#13#10; // carriage return & line feed - this is windows convention. export other progs in unix file format?
  seq=' = ';
  sk = ', '; // comma and space

// flag to evaluate expressions and export numbers:
// presently only for elegant, since it uses inverse polish noation for expressions as-20.9.18
  novar_def: array[0..nLatCode-1] of boolean=(false,false,true,false,false,false);
// special strings depending on code type,
// for line termination, new line, start comment, end comment, empty line
  sterm: array[0..nLatCode-1] of string=(';'+cr,';'+cr,cr,';'+cr,cr,';'+cr) ;
  snlin: array[0..nLatCode-1] of string=(cr,cr,'&'+cr,cr,cr,cr);
  scomi: array[0..nLatCode-1] of string=('{','{','!','!','!','{');
  scomf: array[0..nLatCode-1] of string=('}'+cr,'}'+cr,cr,cr,cr,'}'+cr);
  sempt: array[0..nLatCode-1] of string=(cr,cr,cr,'!'+cr,cr,cr);
// strings for magnet parameters
  s_kq:  array[0..nLatCode-1] of string=('K','K','k1','k1','k1','K');
  s_phi: array[0..nLatCode-1] of string=('T','T','angle','angle','angle','T');
  s_kb : array[0..nLatCode-1] of string=('K','K','k1','k1','k1','K');
  s_tin: array[0..nLatCode-1] of string=('T1','T1','e1','e1','e1','T1');
  s_tex: array[0..nLatCode-1] of string=('T2','T2','e2','e2','e2','T2');
  s_gap: array[0..nLatCode-1] of string=('Gap','Gap','hgap','hgap','hgap','Gap');
  s_k1in:array[0..nLatCode-1] of string=('k1in','XX','fint','fint' ,'fint','XX');
  s_k1ex:array[0..nLatCode-1] of string=('k1ex','XX','XX','fintx','fintx','XX');
  s_k1:  array[0..nLatCode-1] of string=('k1','XX','fint','fint' ,'fint','XX');
  s_cms: array[0..nLatCode-1] of string=('M','XX','K2','K2','K2','XX');
  s_ms:  array[0..nLatCode-1] of string=('K','K' ,'K2','K2','K2','K');
  s_sxnk:array[0..nLatCode-1] of string=('N','N','n_slices','','','N'); //sext kicks

// factors
  fgap: array[0..nLatCode-1] of real=(1000,1,0.5,0.5,0.5,1);
  fsex: array[0..nLatCode-1] of real=(1, 1, 2, 2, 2, 1);

// strings for non-opa element type names
  st_bend: array[1..nLatCode-1] of string=('bending','csbend','sbend','sbend','bending');
  st_sext: array[1..nLatCode-1] of string=('sextupole','ksext','sextupole','sextupole','sextupole');
  st_mult: array[1..nLatCode-1] of string=('multipole','mult','multipole','multipole','multipole');
  st_moni: array[1..nLatCode-1] of string=('beam position monitor','moni','monitor','monitor','beam position monitor');
  st_corh: array[1..nLatCode-1] of string=('corrector, horizontal','hkick','hkicker','hkicker','corrector, horizontal');
  st_corv: array[1..nLatCode-1] of string=('corrector, vertical'  ,'vkick','vkicker','vkicker','corrector, vertical');

  ssegi:  array[0..nLatCode-1] of string=('','' ,'line=(','line=(','line=(','');
  ssegf: array[0..nLatCode-1] of string=('','' ,')',')',')','');
type
  glisttype = record
    gnam: Elemstr;
    gtyp: integer;
  end;

var
  sn, st, se, sci, scf, sexp, sblo, scma: string;
  novar, icfound: boolean;
  latcode, i, ic, j, i8, smaxlen, kord , nbinv, ifound, jfound, k: integer;
  p: AEpt;
  sall, snam, stype, s, sln, sap, sfile, sval, segs, sindent, sberr, sunknown, sord: string;
  // sall is lngstring containing the complete lattice file

  // degree or radians
//  fang: array[0..nLatCode-1] of real;

// list of bends which require explicit inversion for the nobendinv list programs
  binvlist: array of ElemStr;
  glist: array of glisttype;

// function writing expressions, if existent
  function FtoSexp(val: real; exp: Elem_Exp_pt; w, d: integer): string;
  begin
    if (exp=nil) or novar then FtoSexp:=FtoS(val,w,d) else FtoSexp:=exp^;
  end;

  function FtoSexpDG(val: real; exp: Elem_Exp_pt; w, d: integer): string;
  begin
// exp will return angle in degrees, but value is in rad
    if latcode in [opa, tracy, tracy3] then FtoSexpDG:= FtoSexp(degrad*val, exp, w, d) else begin
      if (exp=nil) or novar then FtoSexpDG:=FtoS(val,w,d) else FtoSexpDG:='('+exp^+')*dtor';
    end;
  end;


// function compiling output string for bending magnets

  function bend_string(phi, kb, ms: real; ns: integer; tin, tex, gap, k1in, k1ex, k2in, k2ex: real;
                       phi_exp, kb_exp, tin_exp, tex_exp: Elem_Exp_pt): string;
  var
    sf: string;
  begin
    sberr:='';

    sf:=sk+s_phi[latcode]+seq+FtoSexpDG(phi, phi_exp, 13,10)+sk+s_kb[latcode]+seq+FtoSexp(kb,kb_exp,9,6)+sk+
        s_tin[latcode]+seq+FtoSexpDG(tin,tin_exp,11,8)+sk+s_tex[latcode]+seq+FtoSexpDG(tex,tex_exp,11,8);

    if ms<>0 then begin
      if not (latcode in [tracy,tracy3]) then begin
        sf:=sf+sk+s_cms[latcode]+seq+Ftosv(fsex[latcode]*ms,8,3);
        if latcode = opa then sf:=sf+sk+'N'+seq+InttoStr(ns);
      end else sberr:=sberr+sci+'sextupole component not included: k2='+Ftosv(fsex[latcode]*ms,8,3)+scf;
    end;

    if gap <> 0 then begin
      sf:=sf+sk+s_gap[latcode]+seq+ftos(fgap[latcode]*gap,9,4);

      if k1in <> k1ex then begin
        if not (latcode in [tracy, tracy3]) then begin
          if latcode = elegant then begin
            sf:=sf+sk+s_k1[latcode]+seq+FtoS((k1in+k1ex)/2.,6,4);
            sberr:=sberr+sci+'fint is average k1in/ex: k1in='+FtoS(k1in,6,4)+', k1ex='+ftos(k1ex,6,4)+scf;
          end else sf:=sf+sk+s_k1in[latcode]+seq+FtoS(k1in,6,4)+sk+s_k1ex[latcode]+seq+FtoS(k1ex,6,4);
        end else sberr:=sberr+sci+'fringe field parameters not included: k1in='+FtoS(k1in,6,4)+', k1ex='+ftos(k1ex,6,4)+scf;

      end else if k1in <> 0 then begin //k1ex is equal
        if not (latcode in [tracy,tracy3]) then begin
          sf:=sf+sk+s_k1[latcode]+seq+FtoS(k1in,6,4);
        end else sberr:=sberr+sci+'fringe field parameter not included: k1='+FtoS(k1in,6,4)+scf;
      end;

      if (k2in<>0) or (k2ex<>0) and (latcode=opa) then begin
        sf:=sf+sk+'K2IN = '+FtoS(k2in,6,4)+sk+'K2EX = '+FtoS(k2ex,6,4);
      end;//probably never used
    end;
    if latcode in [tracy,tracy3] then sf:=sf+sk+'n=nbend'+sk+'method=meth';
    bend_string:=sf;
  end;

  // later: move this to asaux unit and generalize, will be useful elsewhere too
  function getlastcomma(sa:string; frompos: integer): integer;
  var k, kfrom: integer;
  begin
    result:=0;
    kfrom:=frompos;
    if (frompos=0) or (frompos > length(sa)) then kfrom:=length(sa);
    for k:=kfrom downto 1 do if sa[k]=',' then Exit(k);
  end;

  procedure App(sa:string);
  var
    tstr: string;
    ico: integer;
  begin
    if length(sa) > 0 then begin
      if length(sa) < 79 then sall:=sall+sa else begin
        tstr:=sa;
        repeat
          ico:=getlastcomma(tstr,79);
          sall:=sall+Copy(tstr,1,ico)+sn;
          tstr:=sindent+Copy(tstr,ico+1);
        until (length(tstr)<79) or (ico=0);
        sall:=sall+tstr;
//        sall:=sall+WrapText(sa,sn+sindent,[','],79-length(sindent)); --> bad linebreaks
      end;
    end;
  end;


begin
  // special feature to write an opa file with expanded variables:
  if latcode_in = 6 then begin
    latcode:=0; novar:=true;
  end else begin
    latcode:=latcode_in;
    novar:=novar_def[latcode];
  end;

  st :=sterm[latcode];
  sn :=snlin[latcode];
  se :=sempt[latcode];
  sci:=scomi[latcode];
  scf:=scomf[latcode];
//  for i:=0 to 1 do fang[i]:=degrad;
//  for i:=2 to 4 do fang[i]:=1.0;
  glist:=nil;

  if length(FileName)>70
  then s:='..'+Copy (FileName,length(FileName)-69,70)
  else s:=FileName;
  sfile:=sci+s+scf;
  sall:=sfile;
  if Length(Glob.text)>0 then begin
    s:=WrapText(Glob.Text,70);
    if latcode=opa then s:='com '+s+' com';
    App(sci+s+scf);
  end;
  App(se);
  //headers
  case latcode of

    opa: begin
      if allocationFlag  then App('Allocation  = '+ExtractFileName(AllocationFile)+st);
      if calibrationFlag then App('Calibration = '+ExtractFileName(CalibrationFile)+st);
      App(se);
      App('Energy = '+FtoS(Glob.Energy,10,6)+st);
      if Glob.rot_inv then App('RotInv = 1;') else App('RotInv = 0;');
      App(se);
//      App('    BetaX   = '+FtoS(Glob.Op0.betx,12,7)+  '; AlphaX  = '+FtoS(Glob.Op0.alfx,12,7)+  st);
      App('    BetaX   = '+FtoS(Glob.Op0.beta,12,7)+  '; AlphaX  = '+FtoS(Glob.Op0.alfa,12,7)+  st);
      App('    EtaX    = '+FtoS(Glob.Op0.disx,12,7)+   '; EtaXP   = '+FtoS(Glob.Op0.dipx,12,7)+   st);
//      App('    BetaY   = '+FtoS(Glob.Op0.bety,12,7)+  '; AlphaY  = '+FtoS(Glob.Op0.alfy,12,7)+  st);
      App('    BetaY   = '+FtoS(Glob.Op0.betb,12,7)+  '; AlphaY  = '+FtoS(Glob.Op0.alfb,12,7)+  st);
      App('    EtaY    = '+FtoS(Glob.Op0.disy,12,7)+   '; EtaYP   = '+FtoS(Glob.Op0.dipy,12,7)+   st);
    end;

    tracy: begin
      App(sci+'OPA to Tracy-2 export'+scf);
      App(se);
      App('define lattice'+st);
      App('energy = '+FtoS(Glob.Energy,10,6)+st);
      App('dp = 1.0d-10;  codeps = 1.0d-6;  dk = 1.0d-6'+st);
      App('meth   = '+InttoStr(Glob.Method)+'; nbend = '+InttoStr(Glob.Nbkick)+'; nquad = '+InttoStr(Glob.Nqkick)+st);
    end;

    elegant: begin
      App(sci+'OPA to elegant export'+scf);
    end;

    madx: begin
      App(sci+'OPA to MAD-X export'+scf);
      App(se);
      App('Energy = '+FtoS(Glob.Energy,10,6)+st);
      App(sci+'check integration method and kicks per element!'+scf);
      App('pi = 4.0*arctan(1.0)'+st);
      App('c0 = 2.99792458e8'+st);
    end;

    bmad: begin
      App(sci+'OPA to BMAD export'+scf);
      App(se);
      App('parameter[particle] = ELECTRON'+st);
      App('parameter[e_tot] = '+ftose(glob.energy*1e9,12,8)+st);
    end;

    tracy3: begin
      App(sci+'OPA to Tracy-3 export'+scf);
      App(se);
      App('define lattice'+st);
      App('energy = '+FtoS(Glob.Energy,10,6)+st);
      App('dp = 1.0d-10;  codeps = 1.0d-6;  dk = 1.0d-6'+st);
      App('meth   = '+InttoStr(Glob.Method)+'; nbend = '+InttoStr(Glob.Nbkick)+'; nquad = '+InttoStr(Glob.Nqkick)+st);
    end;

  end;


   if novar then
  // expand variables not needed, this happens implicitly. All variables will be removed.
  else begin
    App(se);
    App(sci+'----- Variables ---------------------------------------------------'+scf);
    App(se);

    smaxlen:=0;
    for j:=0 to High(Variable) do if length(Variable[j].nam) > smaxlen then smaxlen:=length(Variable[j].nam);
    for j:=0 to High(Variable) do with Variable[j] do begin
      snam:=nam;  for i8:=length(nam) to smaxlen do snam:=snam+' ';
      if exp='' then sexp:=USNumber(floattostr(val)) else sexp:=exp;
      App(snam+seq+sexp+st);
    end;
    if latcode in [elegant, madx, bmad] then begin
      snam:='dtor'; for i8:=length(snam) to smaxlen do snam:=snam+' ';
      App(snam+seq+Ftos(raddeg,13,10)+st);
    end;
  end;


  App(se);
  App(sci+'----- Table of elements ---------------------------------------------'+scf);
  App(se);

  smaxlen:=0;
  for j:=1 to Glob.NElem do if length(Elem[j].nam) > smaxlen then smaxlen:=length(Elem[j].nam);
  sindent:=' '; for i:=1 to smaxlen+1 do sindent:=sindent+' ';
  binvlist:=nil;
  s:='';

  for ic:=0 to Nelemkind do begin
    icfound:=false;
    for j:=1 to Glob.NElem do begin
      with elem[j] do begin
        if cod=ic then begin
          icfound:=true;
          snam:=Elem[j].nam;
          for i8:=length(Elem[j].nam) to smaxlen do snam:=snam+' ';
         //  for unknown elements
          stype:=ElemName[ic]; // use opa type names as default
          snam:=snam+': ';
          sln:= sk+'L = '+FtoSexp(l,l_exp,10,8);
          if l<>0 then sunknown:=snam+'drift '+sln+st else sunknown:=snam+'marker'+st;
//          if l_exp = nil then sln:=sln+FtoS(l,8,6) else sln:=sln+l_exp^;

          if latcode=opa then begin
            sap:= sk+'Ax = '+FtoS(ax,5,2)+', Ay = '+FtoS(ay,5,2);
            if (abs(rot)>1e-6) or (rot_exp<>nil) then sap:=sk+'Rot = '+FtoSexpDG(rot, rot_exp,10,6)+sap;
          end else sap:='';
//to do: export rotation angle to other formats

          case ic of

            cmark:
              begin
                App(snam+stype+sap+st);
              end;

            cdrif:
              begin
                if block and (latcode = opa) then sblo:=sk+'BLOCK' else sblo:='';
                App(snam+stype+sln+sblo+sap+st);
              end;

            cquad:
              begin
                if latcode in [tracy,tracy3] then sap:=sk+'n=nquad'+sk+'method=meth';
                App(snam+stype+sln+sk+s_kq[latcode]+seq+FtoSexp(kq,kq_exp,9,6)+sap+st);
              end;

            cbend:
              begin
                if latcode<>opa then stype:=st_bend[latcode];
                sval:=bend_string(phi, kb, 0, 0, tin, tex, gap, k1in, k1ex, k2in, k2ex, phi_exp, kb_exp, tin_exp, tex_exp);
                App(snam+stype+sln+sval+sap+st);
                App(sberr);
                if (latcode in nobendinv) and ((tin<>tex) or (k1in<>k1ex)) then begin
                  setlength(binvlist, length(binvlist)+1); binvlist[High(binvlist)]:=Elem[j].nam;
                  s:=sinv+snam;
                  sval:=bend_string(phi, kb, 0, 0, tex, tin, gap, k1ex, k1in, k2ex, k2in, phi_exp, kb_exp, tex_exp, tin_exp);
                  App(s+stype+sln+sval+sap+st);
                end;
              end;

            csext:
              begin
                if latcode<>opa then stype:=st_sext[latcode];
                sval:=sk+s_ms[latcode]+seq+FtoS(fsex[latcode]*ms,9,6);
                if latcode in [opa,elegant, tracy,tracy3] then begin
                  sval:=sval+sk+s_sxnk[latcode]+' = '+InttoStr(sslice);
                  if latcode in  [tracy,tracy3] then sval:=sval+sk+'method=meth';
                end;
                App(snam+stype+sln+sval+sap+st);
              end;

            csole:
              begin
                if latcode=opa then begin
                  App(snam+stype+sln+sk+' K = '+FtoS(ks,9,6)+sap+st);
                end else App(sunknown);
              end;

            cundu:
              begin
                if latcode=opa then begin
                  if halfu then sblo:=sk+'HALF' else sblo:='';
                  App(snam+stype+sln+sk+'Lamb = '+FtoS(lam,8,6)+sk+'Bmax = '+FtoS(bmax,8,6)+sk+
                    'F1 = '+FtoS(fill1,8,6)+sk+'F2 = '+FtoS(fill2,8,6)+sk+'F3 = '+FtoS(fill3,8,6)+sk+
                    'GAP = '+FtoS(ugap*1000,8,3)+sblo+sap+st);
                end else App(sunknown);
              end;

            csept:
              begin
                if latcode=opa then begin
                  App(snam+stype+sln+sk+'Angle = '+FtoS(degrad*ang,8,5)+sk+'Dist = '+FtoS(dis,5,2)+sk+
                    'Thick = '+FtoS(thk,5,2)+sap+st);
                end else App(sunknown);
              end;

            ckick:
              begin
                if latcode=opa then begin
                  App(snam+stype+sln+sk+'N = '+InttoStr(mpol)+sk+' K = '+FtoS(amp,8,3)+sk+
                    ' X = '+FtoS(xoff*1e3,8,3)+sk+' T = '+FtoS(tau*1e9,8,3)+sk+' DELAY = '+FtoS(delay*1e9,8,3)+' NK = '+InttoStr(kslice)+sap+st);
                end else App(sunknown);
              end;

            comrk:
              begin
                if latcode=opa then begin
                 if screen then sblo:=sk+'screen' else sblo:='';
                 if (abs(om^.cma[1,1])+abs(om^.cma[1,2])+abs(om^.cma[2,1])+abs(om^.cma[2,2]))>1e-6
                   then scma:=sk+'C11 = '+FtoS(om^.cma[1,1],10,7)+sk+'C12 = '+FtoS(om^.cma[1,2],10,7)+sk+
                    'C21 = '+FtoS(om^.cma[2,1],10,7)+sk+'C22 = '+FtoS(om^.cma[2,2],10,7) else scma:='';
                  App(snam+stype+sk+'BetaX = '+FtoS(om^.bet[1],10,6)+sk+'AlphaX = '+FtoS(om^.bet[2],10,6)+sk+
                    'BetaY = '+FtoS(om^.bet[3],10,6)+sk+'AlphaY = '+FtoS(om^.bet[4],10,6)+sk+
                    'EtaX  = '+FtoS(om^.eta[1],10,6)+sk+'EtaXP  = '+FtoS(om^.eta[2],10,6)+sk+
                    'EtaY  = '+FtoS(om^.eta[3],10,6)+sk+'EtaYP  = '+FtoS(om^.eta[4],10,6)+scma+sblo+sap+st);
                end else App(sunknown);
              end;

            ccomb:
              begin
                if latcode<>opa then stype:=st_bend[latcode];
                sval:=bend_string(cphi, ckq, cms, cslice, cerin, cerex, cgap, cek1in, cek1ex, 0, 0, cphi_exp, ckq_exp, cerin_exp, cerex_exp);
                App(snam+stype+sln+sval+ sap+st);
                App(sberr);
                if (latcode in nobendinv) and ((cerin<>cerex) or (cek1in<>cek1ex)) then begin
                  setlength(binvlist, length(binvlist)+1); binvlist[High(binvlist)]:=Elem[j].nam;
                  s:=sinv+snam;
                  sval:=bend_string(cphi, ckq, cms, cslice, cerex, cerin, cgap, cek1ex, cek1in, 0, 0, cphi_exp, ckq_exp, cerex_exp, cerin_exp);
                  App(s+stype+sln+sval+sap+st);
                end;
              end;

            cxmrk:
              begin
                if latcode=opa then begin
                  App(snam+stype+sk+'XL = '+FtoS(xl,9,2)+sk+'Style = '+IntToStr(nstyle)+sk+'Snap = '+IntToStr(snap)+sap+st);
                end else App(sunknown);
              end;

            cgird:
              begin
                if latcode=opa then begin
                  App(snam+stype+sk+'typ = '+inttostr(gtyp)+sk+'shift = '+FtoS(shift,8,5)+sap+st);
                end else if latcode in [tracy, tracy3] then begin
                  setlength(glist, length(glist)+1);
                  glist[High(glist)].gtyp:=gtyp;
                  glist[High(glist)].gnam:=Elem[j].nam;
                end else App(sunknown);
              end ;

            cmpol:
              begin
                if latcode=opa then begin
                  sval:=     'N = '+InttoStr(nord)+sk+' K = '+FtoSe(bnl,12,8);
                  if lmpol>0 then sval:=sval+sk+' LMAG = '+FtoSe(lmpol,10,4);
                end else begin
                  stype:=st_mult[latcode];
                  case latcode of
                    tracy  : sval:='l = 0.0, hom = ('+inttostr(nord)+','+FtoSe(bnl,10,4)+',0)';
                    elegant: sval:='l = 0.0, knl = '+FtoSe(factorial(nord)*bnl,10,4)+', order='+inttostr(nord-1);
                    madx   : begin
                      sord:='0,';
                      for kord:=1 to nord-2 do sord:=sord+'0,';
                      sval:='KNL={'+sord+ftose(factorial(nord)*bnl,10,4)+'}';
                    end;
                    bmad   : begin
                      sord:='k'+Trim(inttostr(nord-1))+'l'+seq;
                      sval:='l= 0.0, '+sord+ftose(factorial(nord)*bnl,10,4);
                    end;
                    tracy3 : sval:='l = 0.0, hom = ('+inttostr(nord)+','+FtoSe(bnl,10,4)+',0)';
                  end;
                end;
                App(snam+stype+sk+sval+sap+st);
              end;

            cmoni:
              begin
                if latcode<>opa then stype:=st_moni[latcode];
                App(snam+stype+sap+st);
              end;

            ccorh:
              begin
                if latcode<>opa then stype:=st_corh[latcode];
//                App(snam+stype+'DXP = '+FtoS(dxp*1000,10,4)+sap+st);
                App(snam+stype+sap+st);
              end;

            ccorv:
              begin
                if latcode<>opa then stype:=st_corv[latcode];
//                App(snam+stype+'DYP = '+FtoS(dyp*1000,10,4)+sap+st);
                App(snam+stype+sap+st);
              end;

            crota:
              begin
                if latcode=opa then begin
                  App(snam+stype+sap+st);
                end else App(sunknown);
              end;

          end;
        end;
      end;
    end;
    if icfound then App(se);
  end; //ic
  if Length(glist)>0 then begin //tracy girder markers, if any
    App('gtyp0: marker'+st);      App('gtyp1: marker'+st);      App('gtyp2: marker'+st);      App('gtyp3: marker'+st);
  end;
  App(se);
  App(sci+'----- Table of segments ---------------------------------------------'+scf);
  App(se);

// special proc for programs that can not do bend inversion
// part 1: find the segment containing inverted bends or segments
  if latcode in nobendinv then begin
    nbinv:=   length(binvlist) ;
//    writeln(diagfil,nbinv,' bends to be inverted: ');
//    for j:=0 to High(binvlist) do writeln(diagfil, 'inverted bend '+binvlist[j]+'.');

    for i:=1 to Glob.NSegm do begin //0 or 1 ???
      p:=segm[i].ini;
      while p<>nil do begin
        for j:=0 to High(binvlist) do if (p^.nam) = (binvlist[j]) then begin
          if binvlist[High(binvlist)]<> Segm[i].nam then begin // don't append twice
            setlength(binvlist,length(binvlist)+1); binvlist[High(binvlist)]:=Segm[i].nam;
          end;
        end;
        p:=p^.nex;
      end;
    end;
//    for j:=nbinv to High(binvlist) do writeln(diagfil, 'inverted segments '+binvlist[j]+'.');
  end;
// end part 1

  smaxlen:=0;
  for j:=1 to Glob.NSegm do if length(Segm[j].nam) > smaxlen then smaxlen:=length(Segm[j].nam);
  sindent:=' '; for i:=1 to smaxlen+1 do sindent:=sindent+' ';

  for i:=1 to Glob.NSegm do begin
    segs:=Segm[i].nam;
    for i8:=length(Segm[i].nam) to smaxlen do segs:=segs+' ';
    segs:=segs+': '+ssegi[latcode];

    p:=segm[i].ini;
    while p<>nil do begin

      if latcode in [tracy,tracy3] then begin
        // special replacement of girder markers for tracy/cormis
        for k:=0 to high(glist) do if (p^.nam) = (glist[k].gnam) then begin
          p^.nam:='gtyp'+inttostr(glist[k].gtyp);
        end;
      end;

      if p^.inv then begin
        jfound:=-1;
        for j:=0 to High(binvlist) do if (p^.nam) = (binvlist[j]) then jfound:=j;
        if jfound > -1 then snam:=sinv+p^.nam else begin // replace by inverted element/segment name
          if latcode in [tracy,tracy3] then snam:='inv('+p^.nam+')' else snam:='-'+p^.nam;
        end;
      end else snam:=p^.nam;
      if p^.rep>1 then begin
// special MADX feature: replicated element has to be enclosed in brackets, but segment not!
        if (latcode=madx) and (p^.kin=ele) then snam:='('+snam+')';
        snam:=IntToStr(p^.rep)+'*'+snam;
      end;
      segs:=segs+snam;
      if p^.nex=nil then begin
        if latcode=opa then if Segm[i].nper>1 then segs:=segs+', NPER='+inttostr(Segm[i].nper);
        segs:=segs+ssegf[latcode]+st;
      end else segs:=segs+sk;
      p:=p^.nex;
    end; // while
    App(segs);

// special proc for programs that can not do bend inversion
// part 2: if the segment itself needs inversion, create an inverted segment.
// Note that all inversion have to be inverted...
// (will be execute only if binvlist <> nil, i.e. if latcode is in nobendinv
    ifound:=-1;
    if binvlist <> nil then for j:=nbinv to High(binvlist) do if (Segm[i].nam = binvlist[j]) then ifound:=j;
    if ifound > -1 then begin
      segs:=sinv+Segm[i].nam;
      for i8:=length(segs) to smaxlen do segs:=segs+' ';
      segs:=segs+': '+ssegi[latcode];
      p:=segm[i].fin;
      while p<>nil do begin
        if not p^.inv then begin
          jfound:=-1;
          for j:=0 to High(binvlist) do if (p^.nam) = (binvlist[j]) then jfound:=j;
// replace by inverted segment/element name if found; else only apply inversion to
// segments, since all elements to be inverted have been caught before, so only mirror-invariants are left.
          if jfound > -1 then snam:=sinv+p^.nam else begin
            if p^.kin = seg then begin
              if latcode=tracy then snam:='inv('+p^.nam+')' else snam:='-'+p^.nam;
            end else snam:=p^.nam;
          end;
        end else snam:=p^.nam;
        if p^.rep>1 then begin
          if (latcode=madx) and (p^.kin=ele) then snam:='('+snam+')';
          snam:=IntToStr(p^.rep)+'*'+snam;
        end;
        segs:=segs+snam;
        if p^.pre=nil then begin
          segs:=segs+ssegf[latcode]+st;
        end else segs:=segs+sk;
        p:=p^.pre;
      end; // while
      App(segs);
    end; // ifound; special treatment part 2
  end; // for i
  binvlist:=nil; // don't need anymore


  //footers
  case latcode of

    opa: begin
    end;

    tracy, tracy3: begin
      App(se);
      App('cell: '+Segm[Glob.NSegm].nam+', symmetry=1'+st);
      App(se);
      App('end'+st);
    end;

    elegant: begin
    end;

    madx: begin
      App(se);
      App('beam, particle = electron, energy = '+ftosv(Glob.energy,7,3)+st);
      App(se);
      App('use, sequence = '+ Segm[Glob.NSegm].nam+st);
      App(se);
//      App('select, flag=twiss, clear'+st);
//      App('select, flag=twiss, column= name, s, betx, alfx, bety, alfy,dx, dpx, dy, dpy, mux, muy'+st);
      App('select, flag = twiss, column=name, keyword, s, L, angle, K1L, X, Y, px, py, betx, bety, alfx, alfy, dx, dy, dpx, dpy'+st);
      App('twiss, sequence='+Segm[Glob.NSegm].nam+', file=twiss.dat'+st);
      App('stop'+st);
    end;

    bmad: begin
      App(se);
      App('sbend[ds_step] = 0.005'+st);
      App('sextupole[num_steps] = 16'+st);
      App('quad::*[num_steps] = 16'+st);
      App('sbend[fringe_type] = bend_linear'+st);
      App('parameter[taylor_order] = 6'+st);
      App('parameter[ptc_exact_model] = .false.'+st);
      App(se);
      App('use, '+ Segm[Glob.NSegm].nam+st);
    end;


  end;

  App(se);
  App(sfile);
  WriteLattice:=sall;
end;




procedure madseqconvert(seqfile: string; var TextBuffer: pointer);
// read expanded (no expressions) .seq file from madx
// yet incomplete and restricted to simple files
// as-6.1.2021

  type
    eletype=record
      nam: elemstr;
      len: real;
    end;
    seqtype=record
      iel: integer;
      pos: real;
    end;

  var
    inlin, s, seqline: string;
    tfIn: textfile;
    ifol, icom, i, k: integer;
//    mlin: TstringList;
    chpt: CharBufpt;
    firstchar: boolean;
    ich: integer;
    ele: array of eletype;
    seq: array of seqtype;
    drif: array of real;
    appflag: boolean;
    s1, s2, dis, seqlen: real;

    function extractval(lin, key1, key2 :string): real;
    // extract number from a string, finding delimiters before and after
    // --> should go to asaux, because it is of general use.
    var
      i1, i2, err: integer;
      xv: real;
      vstr: string;
    begin
      i1:=Pos(key1,lin)+length(key1);
      i2:=Pos(key2, copy(lin,i1,999));
      vstr:=Copy(lin,i1, i2-1);
 {$R-}
      Val(vstr,xv,err);
 {$R+}
      if err<>0 then xv:=0;
      extractval:=xv;
    end;

    // append a drift to the list, if > 1 micron and if we don't have yet a drift
    // of this length. Returns the drift index, -1 if zero length
    function appdri(dis:real):integer;
    const
      miceps=1e-6; //micron
    var
      k, kfnd: integer;
    begin
      kfnd:=-1;
      if abs(dis) > miceps then begin
        for k:=0 to High(drif) do if abs(dis-drif[k])<miceps then kfnd:=k;
        if kfnd = -1 then begin // not found, create new
          setlength(drif, length(drif)+1);
          drif[High(drif)]:=dis;
          kfnd:=High(drif);
        end;
      end;
      appdri:=kfnd;
    end;

    //append an element to the list, get name and length
    function appele (lin: string): boolean;
    var
      namin: string;
      lenin: real;
    begin
      namin:=copy(lin,0,pos(':',lin)-1);
      if length(namin)>1 then begin
        setlength(ele, Length(ele)+1);
        lenin:= extractval(lin,'l=',',');
        with ele[High(ele)] do begin
          nam:=namin; len:=lenin;
        end;
        appele:=true;
      end else appele:=false;
    end;

    // append an element name to the line up, but only if the element is known
    function appseq (lin: string): boolean;
    var
      namin: string;
      i1, i2, i, ifnd: integer;
      posin: real;
      fnd: boolean;
    begin
      i1:=Pos(':',lin)+1;
      i2:=Pos(',at=',lin);
      namin:=Copy(lin,i1, i2-i1);
      fnd:=false;
      for i:=0 to high(ele) do if (namin=ele[i].nam) then begin
        fnd:=true;
        ifnd:=i;
      end;
      if fnd then begin
        setlength(seq, Length(seq)+1);
        posin:=extractval(lin,'at=',';');
        with seq[High(seq)] do begin
          iel:=ifnd;
          pos:=posin;
        end;
        appseq:=true;
      end else begin
        appseq:=false;
      end;
    end;


  begin
    AssignFile(tfIn, seqfile);
    try
      reset(tfIn);
      // Keep reading lines until the end of the file is reached
      New(chpt);
      chpt.nex:=nil;
      firstchar:=true;
      inlin:='rtod='+ftos(degrad,12,8)+';';
      for ich:=1 to Length(inlin) do begin
        chpt:=AppendChar(chpt,inlin[ich]);
//        write(diagfil, chpt.ch);
        if firstchar then begin
          TextBuffer:=chpt;
          firstchar:=false;
        end
      end;
      ele:=nil;
      seq:=nil;
      inlin:='';
      while not eof(tfIn) do begin
        readln(tfIn, s);
        icom:=Pos('!',s);
        ifol:=Pos('&',s);
        if icom>0 then s:=Copy(s,1, icom-1);
        if ifol>0 then s:=Copy(s,1, ifol-1);
        inlin:=inlin+s;
        if ifol=0 then begin
          if length(inlin)>0 then begin
            appflag:=false;
            inlin:=LowerCase(DelSpace(inlin));

            // keyword at identifies entries in sequence list
            if Pos('at=',inlin)>0 then begin
              appseq(inlin);
            // special line, giving the total length of the sequence
            end else begin
              if Pos('sequence,', inlin) >0 then begin
                seqlen:=extractval(inlin,'l=',';');
              end;
              // check for element names, ignore unknowns
              // no interpretation except name and length, just copy content
              if Pos('sbend',inlin)>0 then begin
                inlin:=AnsiReplaceText(inlin, 'sbend','bending');
                inlin:=AnsiReplaceText(inlin, 'angle=','t=rtod*');
                inlin:=AnsiReplaceText(inlin, 'e1=','t1=rtod*');
                inlin:=AnsiReplaceText(inlin, 'e2=','t2=rtod*');
                inlin:=AnsiReplaceText(inlin, 'k1=','k=');
                appflag:=appele(inlin);
              end;
              if Pos('quadrupole', inlin)>0 then begin
                inlin:=AnsiReplaceText(inlin,'k1=','k=');
                appflag:=appele(inlin);

              end;
              if Pos('sextupole' , inlin)>0 then begin
                 inlin:=AnsiReplaceText(inlin,'k2=','k=1/2*');
                 appflag:=appele(inlin);
              end;
              if Pos('octupole',   inlin)>0 then begin
                inlin:=AnsiReplaceText(inlin,'octupole','multipole, n=4');
                inlin:=AnsiReplaceText(inlin,'k3=','k=1/6*');
                appflag:=appele(inlin);
              end;
              if Pos('kicker',   inlin)>0 then begin
                // tmp handling of kickers
                inlin:=AnsiReplaceText(inlin, 'hkicker','kicker');
                inlin:=AnsiReplaceText(inlin, 'vkicker','kicker');
                appflag:=appele(inlin);
              end;
            end;
            if inlin[high(inlin)]<>';' then inlin:=inlin+';';
            //unknown elements are not imported
            if appflag then begin
              for ich:=1 to Length(inlin) do chpt:=AppendChar(chpt,inlin[ich]);
            end;
          end;
          inlin:='';
        end;
      end;
      CloseFile(tfIn);

      // create drift spaces from distances in sequence
      // assuming that all positions refer to the center of the element
      // !! careful: madx allows alternative definitions
      // create a new sequence including drifts
      drif:=nil;
      seqline:='';
      s1:=0.0;
      for i:=0 to high(seq) do with seq[i] do begin
        s2:= pos - ele[iel].len/2; //entry
        dis:=s2-s1;
        k:=appdri(dis); //get index of drift
        if k>-1 then seqline:=seqline+', d'+copy(inttostr(10000+k),2,4);
        seqline:=seqline+', '+ele[iel].nam;
        s1:=s2+ele[iel].len; //exit
      end;
      dis:=seqlen-s1;
      k:=appdri(dis);
      if k>-1 then seqline:=seqline+', d'+copy(inttostr(10000+k),2,4);
      seqline:='line : '+copy(seqline,2)+';';

      //import the new created drifts
      for k:=0 to high(drif) do begin
        inlin:='d'+copy(inttostr(10000+k),2,4)+': drift, l='+ftos(drif[k],10,6)+';';
        for ich:=1 to Length(inlin) do chpt:=AppendChar(chpt,inlin[ich]);
      end;

      // import the new sequence
      for ich:=1 to Length(seqline) do chpt:=AppendChar(chpt,seqline[ich]);

    except
      on E: EInOutError do
       opaLog(1, 'File handling error occurred. Details: '+E.Message);
    end;

end;


procedure madconvert(madfile: string; var TextBuffer: pointer);
// read mad file, yet incomplete and restricted to simple files

  var
    inlin, s: string;
    tfIn: textfile;
    ifol, icom: integer;
//    mlin: TstringList;
    chpt: CharBufpt;
    firstchar: boolean;
    ich: integer;

  begin
    AssignFile(tfIn, madfile);
    // Embed the file handling in a try/except block to handle errors gracefully
    try
      reset(tfIn);
      // Keep reading lines until the end of the file is reached
//      mlin:=TStringList.Create;
      New(chpt);
      chpt.nex:=nil;
      firstchar:=true;
      inlin:='rtod='+ftos(degrad,12,8)+';';
      for ich:=1 to Length(inlin) do begin
        chpt:=AppendChar(chpt,inlin[ich]);
        if firstchar then begin
          TextBuffer:=chpt;
          firstchar:=false;
        end
      end;
      inlin:='';
      while not eof(tfIn) do begin
        readln(tfIn, s);
        icom:=Pos('!',s);
        ifol:=Pos('&',s);
        if icom>0 then s:=Copy(s,1, icom-1);
        if ifol>0 then s:=Copy(s,1, ifol-1);
        inlin:=inlin+s;
        if ifol=0 then begin
          if length(inlin)>0 then begin
            inlin:=LowerCase(DelSpace(inlin));
            if Pos('line=',inlin)>0 then begin
              inlin:=AnsiReplaceText(inlin, 'line=(','');
              inlin:=AnsiReplaceText(inlin, ')','');
//              inlin:=Copy(inlin,1,length(inlin)-2);
            end else begin
              if Pos('sbend',inlin)>0 then begin
                inlin:=AnsiReplaceText(inlin, 'sbend','bending');
                inlin:=AnsiReplaceText(inlin, 'angle=','t=rtod*');
                inlin:=AnsiReplaceText(inlin, 'e1=','t1=rtod*');
                inlin:=AnsiReplaceText(inlin, 'e2=','t2=rtod*');
                inlin:=AnsiReplaceText(inlin, 'k1=','k=');
              end;
              if Pos('quadrupole', inlin)>0 then inlin:=AnsiReplaceText(inlin,'k1=','k=');
              if Pos('sextupole' , inlin)>0 then inlin:=AnsiReplaceText(inlin,'k2=','k=1/2*');
              if Pos('octupole',   inlin)>0 then begin
                inlin:=AnsiReplaceText(inlin,'octupole','multipole, n=4');
                inlin:=AnsiReplaceText(inlin,'k3=','k=1/6*');
              end;
            end;
            if inlin[high(inlin)]<>';' then inlin:=inlin+';';
//            writeln(diagfil);
            for ich:=1 to Length(inlin) do begin
              chpt:=AppendChar(chpt,inlin[ich]);
            end;
//            mlin.add(inlin);
//            writeln(diagfil, inttostr(mlin.Count)+' '+mlin[mlin.Count-1]);
          end;
          inlin:='';
        end;
      end;

//      mlin.Free;
      CloseFile(tfIn);
    except
      on E: EInOutError do
       opalog(1, 'File handling error occurred. Details: '+E.Message);
    end;

end;


procedure lteconvert(ltefile: string; var TextBuffer: pointer);
// read elegant lte file, yet incomplete and restricted to simple files

  var
    inlin, s, sord, sval: string;
    stmp: array of string;
    tfIn: textfile;
    ifol, icom: integer;
//    mlin: TstringList;
    chpt: CharBufpt;
    firstchar: boolean;
    i,isto, ipop, ich, valcode, ival, iord: integer;
    nval: integer; kval:real;

  begin
    AssignFile(tfIn, ltefile);
    // Embed the file handling in a try/except block to handle errors gracefully
    try
      reset(tfIn);
      // Keep reading lines until the end of the file is reached
//      mlin:=TStringList.Create;
      New(chpt);
      chpt.nex:=nil;
      firstchar:=true;
      inlin:='rtod='+ftos(degrad,12,8)+';';
      for ich:=1 to Length(inlin) do begin
        chpt:=AppendChar(chpt,inlin[ich]);
//        write(diagfil, chpt.ch);
        if firstchar then begin
          TextBuffer:=chpt;
          firstchar:=false;
        end
      end;
      inlin:='';
      while not eof(tfIn) do begin
        readln(tfIn, s);
        icom:=Pos('!',s);
        ifol:=Pos('&',s);
        if icom>0 then s:=Copy(s,1, icom-1);
        if ifol>0 then s:=Copy(s,1, ifol-1);
        inlin:=inlin+s;
        if ifol=0 then begin
          if length(inlin)>0 then begin
            inlin:=LowerCase(DelSpace(inlin));
            if Pos('%',inlin)=1 then begin
              // variable definitions
              isto:=Pos('sto',inlin); ipop:=Pos('pop',inlin);
              if (isto>0) and (ipop>0) then begin
                inlin:=copy(inlin,isto+3,ipop-isto-3)+'='+copy(inlin,2,isto-2);
              end;
            end
            else if Pos('line=',inlin)>0 then begin
              inlin:=AnsiReplaceText(inlin, 'line=(','');
              inlin:=AnsiReplaceText(inlin, ')','');
//              inlin:=Copy(inlin,1,length(inlin)-2);
            end else begin
              if Pos('bend',inlin)>0 then begin
                inlin:=AnsiReplaceText(inlin, 'csbend','bending');
                inlin:=AnsiReplaceText(inlin, 'ccbend','{CC} combined');
                inlin:=AnsiReplaceText(inlin, 'angle=','t=rtod*');
                inlin:=AnsiReplaceText(inlin, 'e1=','t1=rtod*');
                inlin:=AnsiReplaceText(inlin, 'e2=','t2=rtod*');
                inlin:=AnsiReplaceText(inlin, 'hgap=','gap=2000*');
                inlin:=AnsiReplaceText(inlin, 'k1=','k='); //this first!
                inlin:=AnsiReplaceText(inlin, 'fint=','k1=');
              end
              else if Pos('kquad', inlin)>0 then begin
                inlin:=AnsiReplaceText(inlin,'kquad','quadrupole');
                inlin:=AnsiReplaceText(inlin,'k1=','k=');
              end
              else if Pos('quad', inlin)>0 then begin
                inlin:=AnsiReplaceText(inlin,'quad','quadrupole');
                inlin:=AnsiReplaceText(inlin,'k1=','k=');
              end
              else if Pos('edrift,' , inlin)>0 then inlin:=AnsiReplaceText(inlin,'edrift,','drift,')
              else if Pos('drif,' , inlin)>0 then inlin:=AnsiReplaceText(inlin,'drif,','drift,')
              else if Pos('ksext' , inlin)>0 then begin
                inlin:=AnsiReplaceText(inlin,'ksext','sextupole');
                inlin:=AnsiReplaceText(inlin,'k2=','k=1/2*');
                inlin:=AnsiReplaceText(inlin,'n_slices=','n=');
              end
              else if Pos('mult',   inlin)>0 then begin
                inlin:=AnsiReplaceText(inlin,'mult','multipole');
                stmp:=Splitstring(trim(inlin),',');
                sord:=''; sval:='';
                nval:=1; kval:=0.0;
                for i:=0 to High(stmp) do  if pos('order=',stmp[i])>0 then begin
                  iord:=i;
                  sord:=copy(stmp[i],Pos('order=',stmp[i])+6);
                  Val(sord, nval,valcode);
                  if valcode =0 then nval:=nval+1 else nval:=0;//opa mpol order = elegant order +1
                end;
                for i:=0 to High(stmp) do  if pos('knl=',stmp[i])>0 then begin
                  ival:=i;
                  sval:=copy(stmp[i],Pos('knl=',stmp[i])+4);
                  Val(sval, kval,valcode);
                  if valcode > 0 then kval:=0.0;
                end;
                if nval > 0 then kval:=kval/factorial(nval) else kval:=0;
                inlin:='';
                for i:=0 to High(stmp) do if not (i in [iord,ival]) then inlin:=inlin+stmp[i]+', ';
                inlin:=inlin+' n='+inttostr(nval)+', k='+ftos(kval,10,7);
              end
              else if Pos('kicker',inlin)>0 then {nothing, but hkick appears as property in kicker}
              else if Pos('hkick',inlin)>0 then begin
                inlin:=AnsiReplaceText(inlin,'hkick','h-corrector');
                inlin:=AnsiReplaceText(inlin,'kick=,','k=');
              end
              else if Pos('vkick',inlin)>0 then begin
                inlin:=AnsiReplaceText(inlin,'vkick','v-corrector');
                inlin:=AnsiReplaceText(inlin,'kick=','k=');
              end
              else if Pos('moni',inlin)>0 then begin
                inlin:=AnsiReplaceText(inlin,'moni','monitor');
              end
            end;
            if inlin[high(inlin)]<>';' then inlin:=inlin+';';
//            writeln(diagfil);
            for ich:=1 to Length(inlin) do begin
              chpt:=AppendChar(chpt,inlin[ich]);
//              write(diagfil, chpt.ch);
            end;
//            mlin.add(inlin);
//            writeln(diagfil, inttostr(mlin.Count)+' '+mlin[mlin.Count-1]);
          end;
          inlin:='';
        end;
      end;

//      mlin.Free;
      CloseFile(tfIn);
    except
      on E: EInOutError do
       opalog(1, 'File handling error occurred. Details: '+E.Message);
    end;

end;



end.

