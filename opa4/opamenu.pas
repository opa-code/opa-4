unit opamenu;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls, ComCtrls, printers,                                                 
  latfilelib, opaeditor, globlib, opatexteditor, opalinop, opachroma,
  opatrackps, opacurrents, opamomentum, opageometry, opatunediag, opatracktt,
  opatrackda, opaorbit, opalgbedit, opabucket, testcode, ExtCtrls,
  Imglist, ActnList, Buttons;


type


  { TMenu }

  { TMenuForm }

  TMenuForm = class(TForm)
    ButLogPrt: TButton;
    ButLogClr: TButton;
    MainMenu1: TMainMenu;
    tm_di3: TMenuItem;
    tm_di2: TMenuItem;
    tm_di1: TMenuItem;
    tm_di0: TMenuItem;
    tm_diaglev: TMenuItem;
//    tm_console: TMenuItem;
    tm_mag: TMenuItem;
    ds_geo: TMenuItem;
    tm_bdpattern: TMenuItem;
    tm_spectra: TMenuItem;
    ex_opanovar: TMenuItem;
    mi_file: TMenuItem;
    fi_open: TMenuItem;
    fi_save: TMenuItem;
    fi_svas: TMenuItem;
    fi_exit: TMenuItem;
    N1: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    ed_text: TMenuItem;
    mainErrLog: TMemo;
    LabFi0: TLabel;
    LabFileName: TLabel;
    LabSg0: TLabel;
    comboSeg: TComboBox;
    butlatsh: TButton;
    fi_new: TMenuItem;
    fi_last: TMenuItem;
    fi_expo: TMenuItem;
    mi_edit: TMenuItem;
    mi_desi: TMenuItem;
    mi_trac: TMenuItem;
    mi_extr: TMenuItem;
    tm_cur: TMenuItem;
    tr_phsp: TMenuItem;
    tr_dyna: TMenuItem;
    tr_ttau: TMenuItem;
    ds_opti: TMenuItem;
    ds_sext: TMenuItem;
    ed_oped: TMenuItem;
    tm_test: TMenuItem;
    panstatus: TPanel;
    labstflag: TLabel;
    labstelem: TLabel;
    labstdata: TLabel;
    ds_lgbo: TMenuItem;
    ds_orbc: TMenuItem;
    ds_injc: TMenuItem;
    ds_dppo: TMenuItem;
    ds_rfbu: TMenuItem;
    ex_tracy2: TMenuItem;
    ex_tracy3: TMenuItem;
    ex_elegant: TMenuItem;
    ex_madx: TMenuItem;
    ex_bmad: TMenuItem;

    procedure ButLogClrClick(Sender: TObject);
    procedure ButLogPrtClick(Sender: TObject);
    procedure exp_masterClick(Sender: TObject);
//    procedure tm_consoleClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject);
    procedure comboSegChange(Sender: TObject);
    procedure butlatshClick(Sender: TObject);

    procedure fi_newClick(Sender: TObject);
    procedure fi_openClick(Sender: TObject);
    procedure fi_saveClick(Sender: TObject);
    procedure fi_svasClick(Sender: TObject);
    procedure fi_lastClick(Sender: TObject);
    procedure fi_exitClick(Sender: TObject);

    procedure ex_tracy2Click(Sender: TObject);
    procedure ex_tracy3Click(Sender: TObject);
    procedure ex_madxClick(Sender: TObject);
    procedure ex_elegantClick(Sender: TObject);
    procedure ex_bmadClick(Sender: TObject);
    procedure ex_opanovarClick(Sender: TObject);

    procedure ed_opedClick(Sender: TObject);
    procedure ed_textClick(Sender: TObject);

    procedure ds_optiClick(Sender: TObject);
    procedure ds_dppoClick(Sender: TObject);
    procedure ds_sextClick(Sender: TObject);
    procedure ds_orbcClick(Sender: TObject);
    procedure ds_lgboClick(Sender: TObject);
    procedure ds_injcClick(Sender: TObject);
    procedure ds_rfbuClick(Sender: TObject);
    procedure ds_geoClick(Sender: TObject);

    procedure tr_phspClick(Sender: TObject);
    procedure tr_dynaClick(Sender: TObject);
    procedure tr_ttauClick(Sender: TObject);

    procedure tm_curClick(Sender: TObject);
    procedure tm_testClick(Sender: TObject);
    procedure tm_diClick(Sender: TObject);
    procedure tm_magClick(Sender: TObject);
    procedure tm_spectraClick(Sender: TObject);

  private
//    bitsym: array[0..6] of TBitMap;
    procedure UpDateLastUsed;
    procedure ReadFile(newfile: String);
    procedure SetLabFileName;
    procedure writeLatFile (mode: integer; outFileName: string);
    procedure ExitOPA;
  public
    { Public-Deklarationen }
  end;

var
  MenuForm: TMenuForm;

implementation

{$R *.lfm}

{===========================================================}


//----------------------------------------------------------------------

procedure TmenuForm.UpdateLastUsed;
{shift list of used files to the end, insert new select file = FileName
as first position}
var
  addItem, ifound, i: integer;
  Item: TMenuItem;
  index: array of integer;
begin

// find existing menu entries of last used files and delete them all
  setLength(index,countLastUsedFiles+1);
  for i:=1 to countLastUsedFiles do begin
    Item:=fi_last.Find(LastUsedFiles[i]);
    if Item <> nil then index[i]:=fi_last.IndexOf(Item) else index[i]:=-1;
    // nil MUST not happen, catch it anyway
    // writeln(LastUsedFiles[i],' i = ', i, 'index_i = ', index[i]);
  end;

// check if new selected file is already in the list:
  ifound:=0;
  addItem:=0;
  for i:=1 to countLastUsedFiles do begin
    if CompareStr(FileName,LastUsedFiles[i])=0 then ifound:=i;
  end;
  // it is:  put it on first place and shift all above prev position down:
  if ifound>0 then begin
    for i:=ifound downto 2 do LastUsedFiles[i]:=LastUsedFiles[i-1];
    LastUsedFiles[1]:=FileName;
  end
  // it is not: shift all down, expand list up to max if possible, else drop last one
  else begin
    if countLastUsedFiles<maxLastUsedFiles then addItem:=1;
    for i:=countLastUsedFiles+addItem downto 2 do LastUsedFiles[i]:=LastUsedFiles[i-1];
    LastUsedFiles[1]:=FileName;
  end;

// update names of item that may have changed:
  for i:=1 to countLastUsedFiles do begin
    if index[i]>-1 then begin
      (fi_last.Items[index[i]]).Caption:=LastUsedFiles[i];
    end;
  end;

// if list was expanded, last item has name of last file
  if addItem=1 then begin
    Inc(countLastUsedFiles);
    Item:=TMenuItem.Create(self);
    Item.Caption:=LastUsedFiles[countLastUsedFiles];
    Item.OnClick:=fi_lastClick;
    fi_last.Add(Item);
  end;

  fi_last.Visible:=(countLastUsedFiles>0);

end;


//-----------------------------------------------------------------------


procedure TmenuForm.SetLabFileName;
const smax=50;
begin
  if length(FileName)>smax
  then LabFileName.caption:='..'+Copy (FileName,length(FileName)-smax+1,smax)
  else LabFileName.caption:=FileName;
end;

//----------------------------------------------------------------------------
// quit OPA, save last used directory, and last defaults incl. file name
procedure TmenuForm.ExitOPA;
begin
  TunePlot.SaveDefaults;
  {TunePlot may be closed by opa exit, therefore need to save its defaults here}
  DefWriteFile;
  Close;
end;

//----------------------------------------------------------------------------
// read data file
{Opening a file copies it into the TextBuffer variable (linked list of char)}
procedure TmenuForm.ReadFile(newfile: String);

var
  f: TextFile;
  chpt: CharBufpt;
  firstchar: boolean;
  line: string;
  ich: integer;
  newdir: string;

  sall: string;

begin
// assign error logging window
  passErrLogHandle(mainErrLog);
  if FileExists(newfile) then begin

// get new directory (may have changed during 'open'
      newdir:=ExtractFilePath(newfile);

//??? write defaults if leaving a directory (if it is not OPA's own dir)
//??? if (newdir<>work_dir) and (work_dir <>OPA_dir) then DefWriteFile;
//??? up to now: defaults are ONLY written during saving  and on exit

// if the directory was changed update working dir and read defaults
// in the new work dir:
      if work_dir <> newdir then begin
//writeln('def write to ',work_dir, ' and read from ',newdir);
        DefWriteFile;
        work_dir:=newdir;
        DefReadFile;
      end;


      FileName:=newfile;
      ClearTextBuffer(TextBuffer);

      // if mad file, read and replace definitions without syntax check
      if ExtractFileExt(FileName) ='.mad' then begin
         madconvert(FileName, TextBuffer);
      end else if  (ExtractFileExt(FileName) ='.lte') or (ExtractFileExt(FileName) ='.ele') then begin
         lteconvert(FileName, TextBuffer);
      end else if ExtractFileExt(FileName) = '.seq' then begin
         madseqconvert(FileName, TextBuffer);
      end else begin

        try
          AssignFile(f,newfile);
          reset(f);

          firstchar:=true;
          New(chpt);
//    chpt.pre:=nil;
          chpt.nex:=nil;
          sall:='';
          while not eof(f) do begin
            readln(f, line);
            sall:=sall+line;
            for ich:=1 to Length(line) do begin
              chpt:=AppendChar(chpt,line[ich]);
              if firstchar then begin
                TextBuffer:=chpt;
                firstchar:=false;
              end
            end
          end;
          closefile(f);
        except
          on E: EInOutError do
          opaLog(1, 'File handling error occurred. Details: '+E.Message);
        end;
      end;

      if TextBuffer <> nil then begin

// read [interprete] Lattice from TextBuffer
        LatRead(TextBuffer);

//Latread(sall);

        OPALog(0,'Read '+FileName+': |>'+
          IntToStr(Glob.NElem)+' elements and '+IntToStr(Glob.Nsegm)+' segments.');
        LatReadCom(TextBuffer);
        if length(glob.text)>0 then OPALog(0,'"'+glob.text+'"');

// check here if lattice was ok ?
        SetLabFileName;
        FillComboSeg(ComboSeg);
// Latread uses always the last segment
        ComboSeg.ItemIndex:=Glob.NSegm-1;
//      butOp.Enabled:=status.lattice;
// after (more or less) successful reading of file, update the lastusedfiles list
        UpdateLastUsed;

      end else begin
        OPALog(1, 'nil pointer returned from reading '+FileName +' !');
      end;

    end else begin //file exists
      OPALog(1, 'file '+FileName +' does not exist !');
    end;
    MainButtonEnable;
end;

//----------------------------------------------------------------------------
// write data file
procedure TmenuForm.writeLatFile (mode: integer; outFileName: string);

var
  outfi: textfile;
  sall: string;

begin
 // assign error logging window
  passErrLogHandle(mainErrLog);

// create line buffer
  sall := WriteLattice(mode);
  sall := LowerCase(sall);

  assignFile(outfi,outFileName);
{$I-}
  rewrite(outfi);
{$I+}
  if IOResult =0 then begin
    write(outfi, sall);
    CloseFile(outfi);

  // update working directory, which may have changed during 'save as' and
  // write defaults there:

    if mode=0 then begin
      work_dir:=ExtractFilePath(OutFileName);
      DefWriteFile;
      UpdateLastUsed;
    end;

    OPALog(0,'Wrote'+OutFileName+': '+
      IntToStr(Glob.NElem)+' elements and '+IntToStr(Glob.Nsegm)+' segments.');

  end else begin
    OPALog(1,'could not write '+OutFileName);
  end; //IOResult

end;


//======= event handlers ====================================================

// create the form and dynamic components
procedure TmenuForm.FormCreate(Sender: TObject);
var
  Item: TMenuItem;
  stlab: TLabel;
  i,y: integer;
begin

// to do: diagnostic level none/essential/rich/all

//  if GlobDefGet('console')=1 then tm_console.caption:='hide console' else tm_console.caption:='show console';
{  tm_di0.Default:=(diaglevel=0);
  tm_di1.Default:=(diaglevel=1);
  tm_di2.Default:=(diaglevel=2);
  tm_di3.Default:=(diaglevel=3);
}
  tm_di0.Checked:=(diaglevel=0);
  tm_di1.Checked:=(diaglevel=1);
  tm_di2.Checked:=(diaglevel=2);
  tm_di3.Checked:=(diaglevel=3);

// load the 'last used' files item with subitems from ini-file:
  if countLastUsedFiles=0 then fi_last.Visible:=false else begin
    for i:=1 to countLastUsedFiles do begin
      Item:=TMenuItem.Create(self);
      Item.Caption:=LastUsedFiles[i];
      Item.OnClick:=fi_lastClick;
      fi_last.Add(Item);
    end;
    fi_last.Visible:=True;
  end;
  y:=-15;
{
  for i:=0 to 5 do bitsym[i]:=TBitMap.Create;
  bitsym[0].LoadFromFile(opa_dir+'blank.bmp');
  bitsym[1].LoadFromFile(opa_dir+'failure.bmp');
  bitsym[2].LoadFromFile(opa_dir+'success.bmp');
  bitsym[3].LoadFromFile(opa_dir+'lampoff.bmp');
  bitsym[4].LoadFromFile(opa_dir+'lampon.bmp');
  bitsym[5].LoadFromFile(opa_dir+'blueflag.bmp');
}
  for i:=0 to NStatusLabels-1 do begin
    if i=0 then begin
      inc(y,19); labstflag.setBounds(27,y,100,13);
    end;
    if i=3 then begin
      inc(y,18); labstelem.setBounds(27,y,100,13);
    end;
    if i=7 then begin
      inc(y,18); labstdata.setBounds(27,y,100,13);
    end;


    Inc(y,15);
    stlab:=TLabel(FindComponent('stlabn_'+IntToStr(i)));
    if stlab = nil then begin
      stlab:=TLabel.Create(self);
      stlab.name:= 'stlabn_'+IntToStr(i);
      stlab.caption:=StatusLabNCap[i];
      stlab.parent:=panstatus;
      stlab.setBounds(27,y,100,13);
      with stlab.Font do begin
        Name:='MS Sans Serif'; Size:=8; Color:=clBlack; Style:=[];
      end;
    end;


    stlab:=TLabel(FindComponent('stlabc_'+IntToStr(i)));
    if stlab = nil then begin
      stlab:=TLabel.Create(self);
      stlab.name:= 'stlabc_'+IntToStr(i);
      stlab.caption:=' ';
      stlab.parent:=panstatus;
      stlab.setBounds(8,y-1,17,16);
      with stlab.Font do begin
        Name:='Sans'; Size:=12; Color:=clBlack; Style:=[fsbold];
      end;
      stlab.Tag:=i;
      StatusLabels[i]:=stlab;
    end;

  end;

  Left:=10; Top:=10;
  PassMainButtonHandles(fi_new, fi_open, fi_save, fi_svas, fi_expo,
    ed_text, ed_oped,
    ds_opti,ds_dppo, ds_sext,ds_lgbo, ds_orbc, ds_injc, ds_rfbu,
    tr_phsp, tr_dyna, tr_ttau,
    ds_geo, tm_cur);
  passErrLogHandle(mainErrLog);

  OPAversion:=self.caption;
  OPALog(3,OPAversion+' Initialization complete');
end;


procedure TMenuForm.exp_masterClick(Sender: TObject);
begin
  bdpattern_export;
end;




//show or hide console --> overdone to do this at runtime and incompatible with Linux
//to get the console
//in Windows: modify (uncomment 3 lines) in opa.lpr
//in Linux: select in Laz IDE View->Debug Windows->terminal console
{
procedure TMenuForm.tm_consoleClick(Sender: TObject);
begin
  if GlobDefGet('console')=1 then begin // console was visible --> Hide and direct output to file
    ShowConsole(0);
    closeFile(diagfil);
    AssignFile(diagfil,OPA_dir+'diagopa.txt');
    rewrite(diagfil);
    tm_console.caption:='show console';
    GlobDefSet('console',0);
  end else begin // console was invisble --> Show and direct output to console
    ShowConsole(1);
    closeFile(diagfil);
    AssignFile(diagfil,'');
    rewrite(diagfil);
    tm_console.caption:='hide console';
    GlobDefSet('console',1);
  end;
end;
}


procedure TMenuForm.tm_diClick(Sender: TObject);
var
  m: TMenuItem;
begin
{  tm_di0.Default:=false;
  tm_di1.Default:=false;
  tm_di2.Default:=false;
  tm_di3.Default:=false;
}
  tm_di0.Checked:=false;
  tm_di1.Checked:=false;
  tm_di2.Checked:=false;
  tm_di3.Checked:=false;

  m:= Sender as TMenuItem;
//  m.Default:=True;
  m.Checked:=true;
  diaglevel:=m.Tag;
end;

procedure TMenuForm.tm_magClick(Sender: TObject);
begin
  MagParams;
end;

procedure TMenuForm.tm_spectraClick(Sender: TObject);
begin
  undulator_export;
end;

//----------------------------------------------------------------------------
// Close all files and remember path for next time
procedure TmenuForm.FormClose(Sender: TObject);
var
  f: textfile;
  i: integer;
begin
  // save last used files for restart:
  assignFile(f,OPA_dir+OPA_inipath_name);
  // no catch, should work and always write to Opa's directory
  rewrite(f);
  for i:=1 to countLastUsedFiles do writeln(f,LastUsedFiles[i]);
  closeFile(f);
  //close the diagnostics file
  CloseFile(diagfil);
  GlobDefSet('diaglev',diaglevel);
  GlobDefWriteFile;
end;

//----------------------------------------------------------------------------
// start new optics from scratch: delete all data (should be confirmed...)
procedure TmenuForm.fi_newClick(Sender: TObject);
begin
  ClearSegAll;
  GlobInit;
  LabFileName.caption:='New';
  FillComboSeg(comboseg);
  MainButtonEnable;
end;

//----------------------------------------------------------------------------
// read file
procedure TmenuForm.fi_openClick(Sender: TObject);

var
  newfile: string;

begin
  OpenDialog1.InitialDir:=work_dir;
  OpenDialog1.FileName:='';
  if OpenDialog1.Execute then begin
    newfile:= OpenDialog1.FileName;
    ReadFile(newfile);
  end;
end;

//----------------------------------------------------------------------------
// read a file with name as in caption of MenuItem field
// R70 im Kochbuch
procedure TmenuForm.fi_lastClick (Sender: TObject);
var
  name: String;
  i: integer;
begin
  if Sender <> fi_last then begin
    name:=(Sender as TMenuItem).Caption;
// remove '&' (underline character)
    i:=Pos('&',name);
    if i>0 then name:=Copy(name,1,i-1)+Copy(name,i+1,255);
//    writeln(name);
    ReadFile(name);
  end;
end;

//----------------------------------------------------------------------------
// save file
procedure TmenuForm.fi_saveClick(Sender: TObject);
begin
  writeLatFile(0,FileName);
end;

//----------------------------------------------------------------------------
// save with new name
procedure TmenuForm.fi_svasClick(Sender: TObject);

begin
  saveDialog1.FileName:=copy(FileName,1,Pos('.',FileName)-1);
  with saveDialog1 do begin
    saveDialog1.DefaultExt:='opa';
    InitialDir:=work_dir;
    Filter:='OPA lattice file (*.opa)|*.opa';
    if Execute then begin
      WriteLatFile(0, FileName);
    end;
  end;
  FileName:= SaveDialog1.FileName;
  SetLabFileName;
end;

//----------------------------------------------------------------------------
//exit
procedure TmenuForm.fi_exitClick(Sender: TObject);
begin
  ExitOPA;
end;

//----------------------------------------------------------------------------
// save in tracy / elegant / madx / bmad / tracy3 formats
procedure TmenuForm.ex_tracy2Click(Sender: TObject);
begin
  saveDialog1.FileName:=copy(FileName,1,Pos('.',FileName)-1)+'_tracy';
  with saveDialog1 do begin
    DefaultExt:='lat';
    Filter:='Tracy2 lattice file (*.lat)|*.lat';
    InitialDir:=work_dir;
    if Execute then begin
      WriteLatFile(1,FileName);
    end;
  end
end;

procedure TmenuForm.ex_tracy3Click(Sender: TObject);
begin
  saveDialog1.FileName:=copy(FileName,1,Pos('.',FileName)-1)+'_tracy3';
  with saveDialog1 do begin
    DefaultExt:='lat';
    Filter:='Tracy3 lattice file (*.lat)|*.lat';
    InitialDir:=work_dir;
    if Execute then begin
      WriteLatFile(5,FileName);
    end;
  end
end;

procedure TmenuForm.ex_elegantClick(Sender: TObject);
begin
  saveDialog1.FileName:=copy(FileName,1,Pos('.',FileName)-1)+'_ele';
  with saveDialog1 do begin
    DefaultExt:='lte';
    Filter:='Elegant lattice file (*.lte)|*.lte';
    InitialDir:=work_dir;
    if Execute then begin
      WriteLatFile(2,FileName);
    end;
  end;
end;

procedure TmenuForm.ex_madxClick(Sender: TObject);
begin
  saveDialog1.FileName:=copy(FileName,1,Pos('.',FileName)-1)+'_madx';
  with saveDialog1 do begin
    DefaultExt:='madx';
    Filter:='MADX lattice file (*.madx)|*.madx';
    InitialDir:=work_dir;
    if Execute then begin
      WriteLatFile(3,FileName);
    end;
  end;
end;

procedure TmenuForm.ex_bmadClick(Sender: TObject);
begin
  saveDialog1.FileName:=copy(FileName,1,Pos('.',FileName)-1)+'_bmad';
  with saveDialog1 do begin
    DefaultExt:='bmad';
    Filter:='BMAD lattice file (*.bmad)|*.bmad';
    InitialDir:=work_dir;
    if Execute then begin
      WriteLatFile(4,FileName);
    end;
  end;
end;

procedure TMenuForm.ex_opanovarClick(Sender: TObject);
begin
  saveDialog1.FileName:=copy(FileName,1,Pos('.',FileName)-1);
  with saveDialog1 do begin
    saveDialog1.DefaultExt:='opa';
    InitialDir:=work_dir;
    Filter:='OPA lattice file (*.opa)|*.opa';
    if Execute then begin
      WriteLatFile(6, FileName);
    end;
  end;
  FileName:= SaveDialog1.FileName;
  SetLabFileName;
end;


//----------------------------------------------------------------------------
// Open Text Editor with current data
procedure TmenuForm.ed_textClick(Sender: TObject);
begin
{create text editor form if it did not exist yet}
  if FormTxtEdt= nil then FormTxtEdt:=TFormTxtEdt.Create(Application);
  FormTxtEdt.Init (comboseg);
  FormTxtEdt.Show;
  FormTxtEdt.LoadLattice;
end;

//----------------------------------------------------------------------------
// start the OPA Editor
procedure TmenuForm.ed_opedClick(Sender: TObject);
begin
{create editor form if it did not exist yet}
  if FormEdit= nil then FormEdit:=TFormEdit.Create(Application);
  FormEdit.Init (ComboSeg);
  FormEdit.Show;
end;

//----------------------------------------------------------------------------
// start in interactive optic design (incl.matching)
procedure TmenuForm.ds_optiClick(Sender: TObject);
begin
  if Optic= nil then Optic:=TOptic.Create(Application);
  Optic.Init(TunePlot);
  Optic.Show;
end;

//----------------------------------------------------------------------------
// off momentum optics
procedure TmenuForm.ds_dppoClick(Sender: TObject);
begin
  if Tmomentum=nil then begin
    momentum:=Tmomentum.Create(Application);
  end;
  momentum.Start(TunePlot);
  momentum.Show;
end;
//----------------------------------------------------------------------------
// Open LGB Optimizer
procedure TmenuForm.ds_lgboClick(Sender: TObject);
begin
  if LGBedit=nil then LGBedit:=TLGBedit.Create(Application);
  LGBedit.Show;
end;

//----------------------------------------------------------------------------
// start sextupole optimization
procedure TmenuForm.ds_sextClick(Sender: TObject);
begin
 if Chroma= nil then Chroma:=TChroma.Create(Application);
 Chroma.Start(TunePlot);
 Chroma.Show;
end;

//----------------------------------------------------------------------------
// Orbit correction
procedure TmenuForm.ds_orbcClick(Sender: TObject);
begin
  if Orbit=nil then Orbit:=TOrbit.Create(Application);
//  if Orbit.Start(0) then Orbit.Show;
  Orbit.Start(0);
  Orbit.Show;
end;

//----------------------------------------------------------------------------
// Injection orbit
procedure TmenuForm.ds_injcClick(Sender: TObject);
begin
  if Orbit=nil then Orbit:=TOrbit.Create(Application);
//  if Orbit.Start(1) then Orbit.Show;
  Orbit.Start(1);
  Orbit.Show;
end;

//----------------------------------------------------------------------------
// RF bucket view
procedure TmenuForm.ds_rfbuClick(Sender: TObject);
begin
  if BucketView=nil then BucketView:=TBucketView.Create(Application);
  BucketView.Show
end;



//----------------------------------------------------------------------------
// phase space tracking
procedure TmenuForm.tr_phspClick(Sender: TObject);
begin
  if TrackP=nil then TrackP:=TtrackP.Create(Application);
  TrackP.Start(TunePlot);
  TrackP.Show;
end;

//----------------------------------------------------------------------------
// DA tracking
procedure TmenuForm.tr_dynaClick(Sender: TObject);
begin
  if TrackDA=nil then TrackDA:=TtrackDA.Create(Application);
  TrackDA.Start;
  TrackDA.Show;
end;

//----------------------------------------------------------------------------
// Touschek tracking
procedure TmenuForm.tr_ttauClick(Sender: TObject);
begin
  if TrackT=nil then TrackT:=TtrackT.Create(Application);
  TrackT.Start;
  TrackT.Show;
end;

//----------------------------------------------------------------------------
// export magnet currents
procedure TmenuForm.tm_curClick(Sender: TObject);
begin
  if Currents=nil then Currents:=TCurrents.Create(Application);
  Currents.Start;
  Currents.Show;
end;

//----------------------------------------------------------------------------
// lattice geometry and export
procedure TmenuForm.ds_geoClick(Sender: TObject);
begin
  if Geometry=nil then Geometry:=TGeometry.Create(Application);
  Geometry.Start;
  Geometry.Show;
end;

//----------------------------------------------------------------------------
// make new lattice after segment selection
procedure TmenuForm.comboSegChange(Sender: TObject);
begin
  with ComboSeg do begin
    actseg^.nam:=Items[ItemIndex];
  end;
  MakeLattice (status.lattice);
  MainButtonEnable;
end;

//----------------------------------------------------------------------------
// display lattice structure in message window
procedure TmenuForm.butlatshClick(Sender: TObject);
begin
  ShowLattice(mainErrLog);
end;

//----------------------------------------------------------------------------
procedure TMenuForm.ButLogPrtClick(Sender: TObject);
var
  fo: Text;
  fname: string;
begin
  fname:=work_dir+'LogPrint.txt';
  assignFile(fo,fname);
  try
    rewrite(fo);
    write(fo,mainErrLog.Text);
    CloseFile(fo);
    mainErrLog.Clear;
    OpaLog(0,'Content of this window saved to |>'+fname);
  except
    on E: EInOutError do
    OpaLog(1,'Could not write '+fname+'|>'+E.Message);
  end;
end;

//----------------------------------------------------------------------------
procedure TMenuForm.ButLogClrClick(Sender: TObject);
begin
  mainErrLog.Clear;
end;
//----------------------------------------------------------------------------
// test, temporary
procedure TmenuForm.tm_testClick(Sender: TObject);
begin
  Readkvalues;
//  ele_aper_export;
end;
end.
