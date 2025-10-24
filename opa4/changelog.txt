4.2.2 Sep. 18, 2025
- opatracktt
  ZAP export removed, obsolete

4.2.1 Sep. 4, 2025
- vgraph
  Changed Vgraph to vgraph to have all file names lowercase
- opa.lpr
  clean-up

4.2.0 Aug. 30, 2025
Renaming of all files and units, because some names were not meaningful and
capitalization was inconsistent. Now names are all small caps and systematic:
  opa* is a first level GUI, i.e. one of the main design programs,
  o*   is a second level GUI, launched by the first level GUI, e.g.  a start menu,
  *lib is a plain Pascal unit,
  *frame is a frame.
Replacement table new - old:
            globlib           OPAglobal
            opamenu           opamenu
            mathlib           mathlib
            latfilelib        opalatticefiles
            opatexteditor     texteditor
            opaeditor         OPAEditor
            oelecreate        EdElCreate
            oeleedit          EdEdSet
            osegedit          EdSgSet
            opalinop          opticview
            knobframe         knobframe
            ostartmenu        Opticstart
            obetenvmag        OpticEnvel
            otunematrix       OpticTune
            owriteomrk        OpticWOMK
            linoplib          opticplot
            elemlib           OPAElements
            omatching         OpticMatch
            omatchscan        OpticMatchScan
            opatunediag       OPAtune
            opamomentum       OPAmomentum
            momentumlib       momentumlib
            opabucket         Bucket
            opachroma         OPAChroma
            csexframe         CSexLine
            chamframe         CHAmLine
            chromreslib       ChromGUILib1
            chromelelib       ChromGUILib2
            ochromsvector     OPAChromaSVector
            chromlib          chromlib
            opaorbit          OPAorbit
            opatrackps        OPAtrackP
            opatrackda        OPAtrackDA
            opatracktt        OPAtrackT
            tracklib          tracklib
            opalgbedit        LGBeditor
            lgbeditlib        LGBeditorLib
            opageometry       OPAGeometry
            opacurrents       OPACurrents
            testcode          opatest
Files in the ../com folder were not changed, they are still named
            Vgraph, asfigure, asaux, conrect

4.1.1   June/July 2025
Some clean-up during documentation. Removed procs are found in v.4.063=v.4.1.0
- OPAOrbit
  no passing of form handles to asfigure instances, not needed.
  removed "txt" button to print text file, was no action behind, not needed.
  removed procedure butreadcorClick, was temporary to read Tracy data ("cormis")
- OPAChroma, CSExLine
  removed load button and corresponding procs to read values from a temp file
  and set families (was once implemented to import data from MOGA runs).
- Bucket
  empty proc pPaint removed
- OPAElements
  GetBAT moved to opticplot/NormalMode, because it is only used there.
- opticplot
  removed PlotGNU, became obsolete due to EPS export
- OPAglobal, OPACurrents
  Moved procedures getkfromI and getIfromK to OPACurrents

4.1.0 = 4.063
- new version numbering following semantic versioning https://semver.org/
  SemVer is for APIs - not applicable to OPA yet since it is standalone, so
  define a bit differently:
  MAJOR change with regard to compatibility with old lattice files, or a
    big step like conversion from Delphi to Lazarus (version 3 --> 4)
  MINOR change adding/modifying functionality which may affect the user,
    like the different weighting of Hamiltonians in 4.061
  PATCH is a bug fix or a minor modification/improvement not visible to the user

4.063 25.3.225
- EdSgSet
  bug fix: need to append a new line to segment list before writing to
  (was tolerated by Delphi before)

4.062 11.2.2025
- mathlib/PowR
  correction: case 0^0=1 not 0
- ChromLib/Hamscaling
  new index arrays jklmp to make code more clear.
-
4.061 6.2.2025
- ChromLib/HamScaling
  .changed the internal weighting of nonlinear terms: before the Hamiltonian
   modes included the amplitudes with correspomnding powers, however this was not done
   for chromaticities, and the resonant terms needed an extra factor to become
   comparable. Considering dphi/dt = dH/dJ in action angle variables, we now use the
   derivatives of the Hamiltonian modes. Then the factor for the resonances becomes
   obsolete and terms are compared at relevant amplitudes.

4.060 18.10.2024
- OpticPlot
  . export of transfer matrix included in lattice data .txt file,
    html export disabled

4.059 25.7.2024
- OPALatticeFiles, OPAGlobal, opatest
  . *new unit* OPALatticeFiles now contains procedures for reading and writing
    lattices including exports to and imports from other codes, removed from
    OPAGlobal, which is too large containing too many different things, and
    from opatest, which is meant for temporary stuff only.

4.058 24.7.2024
- opamenu and OPAGlobal/WriteLattice
  . support only .lte elegant files, sext kicks included too
  . Decimals for exporting lengths and bending angles increased
- opatest/lteconvert
  . improvement: exporting opa->lte and reading back .lte reproduces almost the .opa file.
    reading multipole order and strength from .lte file for proper conversion
  . bug fix for monitors and correctors
- OPATrackT
  . warning message and info when clicking FTT without DA before

4.057 21-23.7.2024
- VGraph/AxisPrivate
  . PS export improved for better guess of req'd axis space, and bug fixes
- OPATrackDA, OPATrackT, OPATrackP, OPAMomentum, MomentumLib, OPAOrbit
  . PS export implemented
  . in OPATrackP only for  ADTS plots, because scatter plots don't save data
  . in OPAOrbit modified orbit panel to get complete, separate orbit plots for export
- OPAOrbit, knobframe, OPACurrents
  . there was still color clInfoBk, replaced by clLightYellow (forgotten in conversion II)

4.056 8.1.2024
- Bucket
  .analytic calculation of bunch length instead of searching contours.

4.055 30.8.2023
- VGraph
  .started work to provide postscript output
   eps bounding box in pt is equal to screen image size in pixel
   new procedures PS_start, PS_stop to open/close *.eps file
   new procedure stroke req'd to show curve in PS
   extension of AxisPrivate procedure to draw proper axes, including
     postscript procedures for text alignment.
   constants for line thickness and font sizes etc.
- OpticView, OpticPlot/PlotBeta,Env,Mag
  .new button and eps export for beta, envel, magnet plots

- opamenu and Global
  .variable OPAversion to read version number from main form caption

4.054 29.3.2023
- OPAtrackDA/InitialVektor
  . bug fix: update of off-momentum acceptance was missing and gave too large dpp-DA
- OPAtrackDA/FloPoly and FloPinit
  . implemented Bernard Riemanns improved polygon construction (5+29.3.2023)
-OPAGlobal/DefInitAll
  . changed default for Touschek dpp resolution from 1e-6 to 1e-4

4.053 26.2.2023
- OPAtrackT/TrackMA_FTT
  . Import acceptance volume (x,x',dpp) if it was calculated before.
  . Perform tracking from any longitudinal location to end of lattice.
  . Discrimination of x,x' points at dpp interpolated polygons.
  . start with medium dpp (half range),
    then increase dpp from med to max and follow only accepted particles until they are lost,
    then decrease dpp from med to   0 and follow only lost particles until they are accepted.
    Then do the same for negative dpp.
- TrackLib/TrackToEnd
  . track from any longitudinal position to the ends. Reuse TMat matrix/kick
    arrays for speed up, but single element matrix until the first kick is reached.
    Required some care for proper edge treatments
. OPATrackDA
  . modified plot and logics (various places) for new mode.
  . corrected polygon calculation.
. OPAGlobal
  . set defaults for new mode dpp grid size.

4.052 6.2.2023
- OPATrackDA, tracklib
  . New Mode: calculate acceptance volume (x x' dpp) by flood fill and get
    polygon from flood map, save data in variables named FloP* in tracklib.
    MakePlot: some unelegant modifications to show results
- OPATrackDA
  . InitialVektor: calc x', y' of x, y using orbit (Opstart.orb) instead of
    (linear dispersion * dpp ), since Opstart is calculated for current dpp
    and contains even nonlinear dispersion.
  . InitialVektor: call Initdpp for new dpp instead of only TrackingMatrix and TrackPoint,
    since we also need betas from periodic solution: this was wrong before!

4.051 11.12.2022
- OPATrackDA
  .implemented also binary search along rays for comparison and added method selection radio group
  .flood fill restricted to x-y DA because ist would require frequent recalculation
   of momentum dependent transfer matrix. Consider binary search good and fast enough for
   off-momentum, code simplified in this context.
- tracklib
  . bug fix of mom-dep DA calculations that it shows from the beginning.

4.050 6.12.2022
- OPATrackDA
  .new fast DA tracking method based on flood fill implemented by Bernard Riemann
   works only for x-y DA, not for x-dpp and y-dpp
   method menu added including binary serach, grid probing and flood fill,
   but binary search is not yet implemented.

4.049 6.7.2022
- OpticStart
  .enable apply/close buttons from beginning if a startomode is selected.
- OpticEnvel
  .more decimals for sigma_dpp input field.
- OPAGeometry BUG in Linux version:  *************** NOT SOLVED YET ************
  .repaint of geometry plot and selecting a region with the mouse does not work,
   not yet understood, probably different event threading in Win10 and Ubuntu
   --> has to be organized in another way, to do.

4.048 27.6.2022
-TrackLib>Trackpoint:
  .bug fix: dpp offset was not included when calculationg orbit at trackpoint
-OpaTrackP> resgrid
  .Font set to courier new, but still in linux a problem with font style, text appears double (?!)
-OPAGeometry:
  .increased GridParam to show numbers in linux too

4.047 16.5.2022
-OPATrackP
 .united param and update buttons for FFT/Reso and removed button from panel,
  hope this solves the fft panel issue.
-TextEditor
 .Courier New 12pt --> 11pt to avoid line break in edit window.
-OpaGlobal > OpaLog
 .added feature: substring "|>" indicates linebreak in errlog window
-OpaMenu
 .added buttons to print errlog window content to file and to clear content
-OpticView, opticPlot
 .replaced all diagfil output by OpaLog (or removed/commented)
-asaux
 .new function Lastblank(s,nf) to return last blank in string s before or at Position nf

4.046 12.5.2022
- W10 installation upgraded to Laz 2.2.0 to have same version like Linux
  (backwards compatibility issues with ParentBackground property etc.)

==============================================================================
Linux conversion part II

---- problems ----------------------------------------

Different behaviour in linux, not yet fixed;

- OpticView: string grid: how to set it to last used item? ==> W too
- OpaTrackDA.OpticView apertures: no filling of Solid, why? (it works in OpticView magnets)
- [solved] OPAtrackP: fft panel not becoming invisible, why?   text double ?
- font size problems in many places, although free windows fonts were imported and used (in most places).


---- to do ------------------------------------------

- remove console, only log window

-texteditor: avoid line break: smaller font or wider window   ?

-opageometry: zoom dont work / param table too small
 . no repaint when mouse is not over figure (W too ?)


----solved -------------------------------------------

- OPAMenu: combobox ignores dropdowncount in Linux
  *** this is a known bug according to Lazarus forum, problem of GTK2 widget set

- OPAGlobal and other places
  .Colors: defined clLightYellow to replace clInfoBk which was unknown and appeared black

- OPAmenu/OPAglobal>OPALog
  .set cursor position to end of text in log window .setlength=length(.Text) ->W
  .highlighting diag level menuitem did not work with .Default, instead .Checked works. ->W

- OPAMenu
  .wingdings font not avail for status flags (tried to use bitmaps instead, failed),
   preliminary simple solution just using normal font and simple chars o x ! * with color

- OPAtrackT
  .changed color clInfoBk (appears black) to clSkyBlue
  .moved radiobuttons into rgshow group with auto scaling of positions (resizing still works)
   however could not change order of buttons (ok)
  .improved handling of zero emittance (warning only once, switch to uncoupled input) ->W

- OpticView
   .more space in tgrid

- OpticEnvel
  .radiobutton moved into group rgmod

- Vgraph > AxisPrivate
   .bug removed: insufficient string length had lead to weird axis annotations ->W

===============================================================================


4.045 4.5.2022
Console handling still requires different versions of opa.lpr and OPAWinConsole
in W10 and Linux, but OPAglobal is the same now. Differences:
- OPAWinConsole has no function in Linux, just a dummy unit
- opa.lpr contains {APPTYPE CONSOLE} directive in W10

- OPAtrackDA
  fixed invisible radioGroup in Linux, but in W10 complaint "parentbackground
  unknown property" (probably because newer Laz version on Linux), removed from .lfm, ok.
- OpticStart
  font size compromise W10<->Linux

4.044 3.5.2022
trying to get rid of the console again, since this is handled differently in W and L
- OPAglobal and other places:
  replaced OPAMessage by OPALog with more functionality (diagnostics output)

4.043 27.4.2022
Merge linux and windows forks: copy Linux version 4.040 back to Windows and update
with recent changes up to 4.042. Remaining differences only due to console control:
- OPAglobal: uses OPAWincontrol
- opa.lpr: {APPTYPE CONSOLE}

== debugging of linux version still in progress ===

4.042 25-26.4.2022
- OpticView > pwMouseDown
  replaced explicit image grab procedure by call to Vgraph.grabImage
- OPAElements > Bend_Matrix , MathLib > MatMul5_S
  Missing initialization in MatMul5_S fixed.
- OPAElements > Quadrupole
  corrected number-of-kicks calculation (makes no difference)
- OPAElements>MCC_coup, OpticPlot:
  testing new MF output

4.041 21.4.2022
- OPAelements > MCC_Prop
  phase advance calculation with mode flip now corrected to at least give correct fractional tunes

== Linux conversion ===========================================================================

Apr. 20, 2022

Conversion from W10/Laz 2.0.6  to Xubuntu 20.04/Laz 2.2.0

1) OPAWinConsole / opa.lpr
remove unit windows, remove {$APPTYPE CONSOLE}

2) reactivate {$MODE Delphi} in many units for different reasons:

a. tolerate local declaration of variables with same name like variables already
defined privately or in TForm
- OPAChroma, OPAChromSVectgor, OPAMomentum, OPAGeometry, Bucket, OPAOrbit
(basically all Forms where FormClose( ... Action) was defined
- OpticMatch: local varialbel named "active"

b. pass function name without parameters to event handler
- OpticStart (rbutClick), also OpticView and others

c. call of algebraic function (Rosetta code): (forward declaration?)
- OPAGlobal

d. avoid complaint about pointer dereferencing
- OpticPlot (curve.nex), OPAcurrents, opatest, opamenu

e. avoid complaint about incompatible types (real array element <-- real)
- tracklib (DataArrayType[] <-- Real)

(note that removing {$MODE Delphi} in 4.038 probably only worked, because the
W10 Laz compiler still remembered these options [?])

3) rename local variable if it was declared as private globally
- OPAtune (kfac/kfc) - probaly $MODE Delphi would have this fixed too.

4) Font substitutions
Problem: Microsoft fonts 'Courier' and 'Courier New' unreadable (no or wrong
replacement by Laz), others like 'MS Sans Serif' were automatically replaced by 'Sans'.

a) first solution: replace 'Courier' by 'FreeMono' - this works, but how about
compatibility when returning to W10?

b1) import 'Courier New' from Microsoft (free core fonts). Recipe
https://itsfoss.com/install-microsoft-fonts-ubuntu/
sudo apt install ttf-mscorefonts-installer

b2) replace 'Courier', which was not installed, by 'Courier New'.

5) OpticView>MouseDown: it seems Makeplot is called (probably via OnPaint) before
MouseUp is called, so the initializtion iselectedElem:=-1 was repeated and
erased the setting from MouseDown. Fixed by init only on first call.
Obviously in W10, no Makeplot is called between Mouse down and up - ?

6) OpticView>MakePlot: bts.create was called on every Makeplot and obviously left
behind a lot of unfreed memory ? Error messages on termination:
[TGtk2WidgetSet.Destroy] WARNING: There are 10 unreleased DCs, a detailed dump follows:
[TGtk2WidgetSet.Destroy]  DCs:   00007F3FDCF27640 00007F3FDCF27440 00007F3FDCF27240 00007F3FDCF27040 00007F3FDCF26E40 00007F3FDCF26C40 00007F3FDCF26A40
[TGtk2WidgetSet.Destroy] WARNING: There are 30 unreleased GDIObjects, a detailed dump follows:
[TGtk2WidgetSet.Destroy]   GDIOs: 00007F3FDA8FA640 00007F3FDA8FA740 00007F3FDA68DA40 00007F3FDA691A40 00007F3FDA691B40 00007F3FDA68D8C0 00007F3FDA68FDC0
[TGtk2WidgetSet.Destroy]   gdiBitmap: 30
A solution is here ==> https://forum.lazarus.freepascal.org/index.php/topic,45667.0.html

My quick fix: remove the bts.create in Makeplot and keep only one in Toptic.Init.
Further replaced bts.free by FreeAndNil(bts) in FormClose.

7) not yet resolved error message:
WARNING: TGtk2WidgetSet.InvalidateRect refused invalidating during paint message: Toptic

====================================================================================================== 


4.040 13-19.4.2022
- OpaMenu, OpaWinConsole
  MenuItem to hide/show console; new unit OpaWinConsole which is the only one to
  use the  "windows" unit; use of windows unit removed everywhere else.
- OpaMenu, OpaGlobal
  MenuItem to select amount of output, variable diaglevel (to console or diag file).
  boolean Function diag(i) in OPAGlobal, true if i <= diaglevel (not yet implemented everywhere)
- OpaGlobal
  new GlobDef variable to remember console & diaglevel settings for next session.
- MathLib
  null and unit matrix functions replaced by constants.
  old matrix procs removed, old proc MatMulS turned into func MatMul5_S for block diag mult
- all units
  refactorization to avoid most compiler warnings,
  except "Local variable not initialized", because many vars are initialized inside called procs
  (compiler message suppressed in project options).
- OPAelements, OPAGlobal, OPAEditor
  new global variable glob.rot_inv and lattice file keyword ROTINV for inversion of rotations,
  by default FALSE, i.e. direction of rotation is not inverted in inverted segment.
  Not yet implemented in export to other file formats.

4.039  5.4.2022
- replaced FGraph by VGraph in OpticView and OpticPlot, Fgraph removed from project.

4.038  28.3.2022
- disabled MODE DELPHI flag in most units (has no effect)
- temporary output .mpo file from OPAGeometry

4.038 10.2.2022
- OPAElements>Bending,Quadrupole
  corrected orbit effects on radiation integrals according to coupling paper v.3
  (makes virtually no difference)
- MomentumLib
  increased nresult to 22 to include Emittb and Jb in plot.

4.037 9.2.2022
- OPAElements>Undulator bug fix.
  KB=h*h+k was not updated without radiation integrals and gave wrong periodic solution.

ChangeLog started Feb 9, 2022
