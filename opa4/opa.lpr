program opa;

// to get the terminal console in Windows, uncomment the lines with //WCON

  //      {$APPTYPE CONSOLE} //WCON
uses
 // windows,  //WCON
  Forms, Interfaces,
  opamenu in 'opamenu.pas' {MenuForm},
  globlib,
  opaeditor,
  elemlib,
  oelecreate in 'oelecreate.pas' {EditElemCreate},
  oeleedit in 'oeleedit.pas' {EditElemSet},
  opatexteditor in 'opatexteditor.pas' {FormTxtEdt},
  osegedit in 'osegedit.pas' {EditSegSet},
  opalinop in 'opalinop.pas' {optic},
  linoplib in 'linoplib.pas',
  ostartmenu in 'ostartmenu.pas' {startsel},
  obetenvmag in 'obetenvmag.pas' {setMatchScan},
  omatchscan in 'omatchscan.pas' {setMatchScan},
  omatching in 'omatching.pas' {Match},
  owriteomrk in 'owriteomrk.pas' {WOMK},
  chamframe in 'chamframe.pas' {CHam: TFrame},
  opachroma in 'opachroma.pas' {Chroma},
  chromlib in 'chromlib.pas',
  opatrackps in 'opatrackps.pas' {trackp},
  tracklib in 'tracklib.pas',
  opacurrents in 'opacurrents.pas' {Currents},
  otunematrix in 'otunematrix.pas' {tuneMatrix},
  opamomentum in 'opamomentum.pas' {momentum},
  opageometry in 'opageometry.pas' {Geometry},
  opatunediag in 'opatunediag.pas' {tuneplot},
  opatracktt in 'opatracktt.pas' {trackT},
  opatrackda in 'opatrackdaA.pas' {trackDA},
  ochromsvector in 'ochromsvector.pas' {SVectorPlot},
  chromreslib in 'chromreslib.pas',
  chromelelib in 'chromelelib.pas',
  opaorbit in 'opaorbit.pas' {Orbit},
  asaux in '../com/asaux.pas',
  asfigure in '../com/asfigure.pas' {Figure: TFrame},
  Vgraph in '../com/Vgraph.pas',
  testcode in 'testcode.pas',
  lgbeditlib in 'lgbeditlib.pas',
  opalgbedit in 'opalgbedit.pas',
  opabucket in 'opabucket.pas' {BucketView},
  conrect in '../com/conrect.pas', 
  latfilelib;

{$R *.res}

begin
//  ShowWindow(GetConsoleWindow, SW_SHOW); //WCON


  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMenuForm, MenuForm);

//  Application.CreateForm(TFormEdit, FormEdit);
  Application.CreateForm(TEditElemCreate, EditElemCreate);
  Application.CreateForm(TEditElemSet, EditElemSet);
//  Application.CreateForm(TFormTxtEdt, FormTxtEdt);
  Application.CreateForm(TEditSegSet, EditSegSet);
//  Application.CreateForm(Toptic, optic);
  Application.CreateForm(Tstartsel, startsel);
//  Application.CreateForm(TsetMomentum, setMomentum);
  Application.CreateForm(TsetEnvel, setEnvel);
  Application.CreateForm(TMatch, Match);
  Application.CreateForm(TsetMatchScan, setMatchScan);
  Application.CreateForm(TWOMK, WOMK);
//  Application.CreateForm(TChroma, Chroma);
//  Application.CreateForm(Ttrackp, trackp);
//  Application.CreateForm(TCurrents, Currents);
  Application.CreateForm(TtuneMatrix, tuneMatrix);
  Application.CreateForm(Tmomentum, momentum);
//  Application.CreateForm(TGeometry, Geometry);
  Application.CreateForm(Ttuneplot, tuneplot);
//  Application.CreateForm(TtrackT, trackT);
//  Application.CreateForm(TtrackDA, trackDA);
  Application.CreateForm(TSVectorPlot, SVectorPlot);
//  Application.CreateForm(TOrbit, Orbit);
//  Application.CreateForm(TLGBedit, LGBedit);
//  Application.CreateForm(TBucketView, BucketView);

  Application.Run;
end.
