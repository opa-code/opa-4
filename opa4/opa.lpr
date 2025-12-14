program opa;

// to get the terminal console in Windows, uncomment the lines with //WCON

  //      {$APPTYPE CONSOLE} //WCON
uses
 // windows,  //WCON
  Forms, Interfaces,
  globlib,
  latfilelib,
  elemlib,
  linoplib,
  chromlib,
  chromreslib,
  chromelelib,
  lgbeditlib,
  tracklib,
  opamenu 	{MenuForm},
  opaeditor,
    oelecreate 	{EditElemCreate},
    oeleedit 	{EditElemSet},
    osegedit  	{EditSegSet},
  opatexteditor {FormTxtEdt},
  opalgbedit,
  opalinop  	{optic},
    ostartmenu  {startsel},
    obetenvmag  {setMatchScan},
    omatching  	{Match},
    omatchscan  {setMatchScan},
    otunematrix {tuneMatrix},
    owriteomrk  {WOMK},
  opatunediag 	{tuneplot},
  opamomentum 	{momentum},
  opabucket 	{BucketView},
  opachroma  	{Chroma},
    chamframe  	{CHam: TFrame},
    ochromsvector {SVectorPlot},
  opaorbit 	{Orbit},
  opageometry 	{Geometry},
  opacurrents 	{Currents},
  opatrackps 	{trackp},
  opatrackda  	{trackDA},
  opatracktt  	{trackT},
  asaux 	in '../com/asaux.pas',
  asfigure 	in '../com/asfigure.pas' {Figure: TFrame},
  vgraph 	in '../com/vgraph.pas',
  conrect 	in '../com/conrect.pas', 
  testcode;


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
