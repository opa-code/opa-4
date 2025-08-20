program opa;

// to get the terminal console in Windows, uncomment the lines with //WCON

  //      {$APPTYPE CONSOLE} //WCON
uses
 // windows,  //WCON
  Forms, Interfaces,
  opamenu in 'opamenu.pas' {MenuForm},
  OPAglobal,
  OPAEditor,
  OPAElements,
  EdElCreate in 'EdElCreate.pas' {EditElemCreate},
  EdElSet in 'EdElSet.pas' {EditElemSet},
  texteditor in 'texteditor.pas' {FormTxtEdt},
  EdSgSet in 'EdSgSet.pas' {EditSegSet},
  OpticView in 'OpticView.pas' {optic},
  OpticPlot in 'OpticPlot.pas',
  Opticstart in 'Opticstart.pas' {startsel},
  OpticEnvel in 'OpticEnvel.pas' {setMatchScan},
  OpticMatchScan in 'OpticMatchScan.pas' {setMatchScan},
  OpticMatch in 'OpticMatch.pas' {Match},
  OpticWOMK in 'OpticWOMK.pas' {WOMK},
  CHamLine in 'CHamLine.pas' {CHam: TFrame},
  OPAChroma in 'OPAChroma.pas' {Chroma},
  ChromLib in 'ChromLib.pas',
  OPAtrackP in 'OPAtrackP.pas' {trackp},
  tracklib in 'tracklib.pas',
  OPACurrents in 'OPACurrents.pas' {Currents},
  OpticTune in 'OpticTune.pas' {tuneMatrix},
  OPAmomentum in 'OPAmomentum.pas' {momentum},
  OPAGeometry in 'OPAGeometry.pas' {Geometry},
  OPAtune in 'OPAtune.pas' {tuneplot},
  OPAtrackT in 'OPAtrackT.pas' {trackT},
  OPAtrackDA in 'OPAtrackDA.pas' {trackDA},
  OPAChromaSVector in 'OPAChromaSVector.pas' {SVectorPlot},
  ChromGUILib1 in 'ChromGUILib1.pas',
  ChromGUILib2 in 'ChromGUILib2.pas',
  OPAorbit in 'OPAorbit.pas' {Orbit},
  asaux in '../com/asaux.pas',
  asfigure in '../com/asfigure.pas' {Figure: TFrame},
  Vgraph in '../com/Vgraph.pas',
  opatest in 'opatest.pas',
  LGBeditorLib in 'LGBeditorLib.pas',
  LGBeditor in 'LGBeditor.pas',
  Bucket in 'Bucket.pas' {BucketView},
  conrect in '../com/conrect.pas', OPALatticeFiles;

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
