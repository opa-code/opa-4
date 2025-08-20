{
contour plot program downloaded from http://paulbourke.net/papers/conrec/
as-Jan.2018

Modifications:
- changed to Unit
- defined type ConLinesArray to store the results and return as variable
- testprogram disabled, in comment section
}

//------------------------------------------------------------------------------
{
IMPLEMENTATION BY 2000-2001 Alexander Weidauer for the Delphi/V Code.

This software is only IMPLEMENTED by Alexander Weidauer.
This code is based on the work of Nicholas Yue CONREC.C
and the Paul D. Bourke CONREC.F routine.

The authors hereby grant permission to use, copy, and distribute this
software and its documentation for any purpose, provided that existing
copyright notices are retained in all copies and that this notice is included
verbatim in any distributions. Additionally, the authors grant permission to
modify this software and its documentation for any purpose, provided that
such modifications are not distributed without the explicit consent of the
authors and that existing copyright notices are retained in all copies. Some
of the algorithms implemented by this software are patented, observe all
applicable patent law.

IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY FOR
DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY DERIVATIVES THEREOF,
EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES, INCLUDING,
BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE IS PROVIDED ON AN
"AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE NO OBLIGATION TO PROVIDE
MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
}
//------------------------------------------------------------------------------


//==============================================================================
//
//     CONREC is a contouring subroutine for rectangularily spaced data.
//
//     It emits calls to a line drawing subroutine supplied by the user
//     which draws a contour map corresponding to float (4 byte) on a randomly
//     spaced rectangular grid. The coordinates emitted are in the same
//     units given in the x[] and y[] arrays as sample:
//
//     x[0]:=0; x[1]:=1;..x[dimx-1]:=dimx-1; and
//     y[0]:=0; y[1]:=1;..y[dimy-1]:=dimy-1;.
//
//
//     Any number of contour levels may be specified but they must be
//     in order of increasing value as sample:
//     z[0]:=-100; z[1]:=-50;..z[dimh-1]:=100;
//     and the number of contur levels must be given as sample dimh.
//
//
//     As this code is ported as from FORTRAN-77, ANSI C, Delphi and the
//     procedural is of course a PASCALIAN
//     please be very careful of the various indices like ilb,iub,jlb and jub,
//     remeber that C/C++ and for dynamic arrays in delphi indices
//     starts from zero (0)
//
//==============================================================================
Unit conrect;

//{$MODE Delphi}

interface

//------------------------------------------------------------------------------
uses
  SysUtils,
  Math;

//------------------------------------------------------------------------------
Type ConMatrix    = Array Of Array of Double;
     ConVector    = Array Of Double;
     ConVectorL4D = Array [0..4] of Double;
     ConVectorL4I = Array [0..4] of Integer;
     ConCastArray = Array [0..2,0..2,0..2] of Integer;

     ConLinesType= record
       x1, y1, x2, y2: double;
       ih: integer;
     end;
     ConLinesArray = Array of ConLinesType;

Procedure Conrec      ( D:  ConMatrix ; // 2D - Data field
                          ilb,iub,           // west - east   ilb lower bound
                                             //               iub upper bound
                          jlb,jub : Integer; // north - south jlb lower bound
                                             //               jub upper bound
                          x : ConVector;       // coord. vector west - east
                          y : ConVector;       // coord. vector north - south
                          nc: Integer;       // nc number of cut levels
                          z : ConVector;      // values of cut levelsprocedure Conrec
                          var ConLines: ConLinesArray);

{procedure ConRecTest (var CL: ConLinesArray);}

implementation

//------------------------------------------------------------------------------
Procedure Conrec      ( D:  ConMatrix ; // 2D - Data field
                          ilb,iub,           // west - east   ilb lower bound
                                             //               iub upper bound
                          jlb,jub : Integer; // north - south jlb lower bound
                                             //               jub upper bound
                          x : ConVector;       // coord. vector west - east
                          y : ConVector;       // coord. vector north - south
                          nc: Integer;       // nc number of cut levels
                          z : ConVector;      // values of cut levelsprocedure Conrec
                          var ConLines: ConLinesArray);
//------------------------------------------------------------------------------
Const
 im : Array [0..3] of Integer = (0,1,1,0);   // coord. cast array west - east
 jm : Array [0..3] of Integer = (0,0,1,1);   // coord. cast array north - south
//------------------------------------------------------------------------------
Var
 m1,m2,m3,deside:Integer;
 dmin,dmax {,x1,x2,y1,y2} :Double;
 {lcnt,} i,j,k,m:Integer;
 casttab : ConCastArray;
 h       : ConVectorL4D;
 sh      : ConVectorL4I;
 xh,yh   : ConVectorL4D;
 temp1,temp2:Double ;
 // r:Byte;

 // ------- service xsec west east lin. interpol -------------------------------
 Function xsec(p1,p2:Integer):Double;
  Begin
   result:=(h[p2]*xh[p1]-h[p1]*xh[p2])/(h[p2]-h[p1]);
  End;

 //------- service ysec north south lin interpol -------------------------------
 Function ysec(p1,p2:Integer):Double;
  Begin
   result := (h[p2]*yh[p1]-h[p1]*yh[p2])/(h[p2]-h[p1]);
  End;

Begin
 // set casting array
 casttab[0,0,0]:=0;casttab[0,0,1]:=0;casttab[0,0,2]:=8;
 casttab[0,1,0]:=0;casttab[0,1,1]:=2;casttab[0,1,2]:=5;
 casttab[0,2,0]:=7;casttab[0,2,1]:=6;casttab[0,2,2]:=9;

 casttab[1,0,0]:=0;casttab[1,0,1]:=3;casttab[1,0,2]:=4;
 casttab[1,1,0]:=1;casttab[1,1,1]:=3;casttab[1,1,2]:=1;
 casttab[1,2,0]:=4;casttab[1,2,1]:=3;casttab[1,2,2]:=0;

 casttab[2,0,0]:=9;casttab[2,0,1]:=6;casttab[2,0,2]:=7;
 casttab[2,1,0]:=5;casttab[2,1,1]:=2;casttab[2,1,2]:=0;
 casttab[2,2,0]:=8;casttab[2,2,1]:=0;casttab[2,2,2]:=0;

 // set line counter
// lcnt:=0;
 //-----------------------------------------------------------------------------
 For j:=jub-1 DownTo jlb Do Begin     // over all north - south and              +For j
  For i:=ilb To iub-1 Do Begin        // east - west coordinates of datafield    +For i
   // set casting bounds from array
   temp1 := min(D[i  , j],D[i  ,j+1]);
   temp2 := min(D[i+1, j],D[i+1,j+1]);
   dmin  := min(temp1, temp2);
   temp1 := max(D[i  , j],D[i  ,j+1]);
   temp2 := max(D[i+1, j],D[i+1,j+1]);
   dmax  := max(temp1, temp2);
   If (dmax>=z[0]) And (dmin<=z[nc-1]) Then Begin // ask horzintal cut avail.    +If dmin && dmax in z[0] .. z[nc-1]
    For k:=0 To nc-1 Do Begin                     // over all possible cuts ---- +For k
     If (z[k]>dmin) And (z[k]<=dmax) Then Begin   // aks for cut intervall ----- +If z[k] in dmin .. dmax
       //-----------------------------------------------------------------------
       For m:=4 Downto 0 Do Begin  // deteriening the cut casts and set the ---- +For m
       If (m>0) Then Begin         // height and coordinate vectors
        h[m]  := D[i+im[m-1],j+jm[m-1]]-z[k];
        xh[m] := x[i+im[m-1]];
        yh[m] := y[j+jm[m-1]];
       End Else Begin
        h[0]  := (h[1]+h[2]+h[3]+h[4])/4;
        xh[0] := (x[i]+x[i+1])/2;
        yh[0] := (y[j]+y[j+1])/2;
       End; // If m>0 then Else
       If h[m]>0 Then sh[m]:=1
        Else If h[m]<0 Then sh[m]:=-1
         Else sh[m]:=0;
       End; // ----------------------------------------------------------------- -For m

       //-----------------------------------------------------------------------
      For m:=1 to 4 Do Begin // set directional casttable
        //
        // Note: at this stage the relative heights of the corners and the
        // centre are in the h array, and the corresponding coordinates are
        // in the xh and yh arrays. The centre of the box is indexed by 0
        // and the 4 corners by 1 to 4 as shown below.
        // Each triangle is then indexed by the parameter m, and the 3
        // vertices of each triangle are indexed by parameters m1,m2,and
        // m3.
        // It is assumed that the centre of the box is always vertex 2
        // though this isimportant only when all 3 vertices lie exactly on
        // the same contour level, in which case only the side of the box
        // is drawn.
        //
        //      AS ANY BODY NOWS IST FROM THE ORIGINAL    
        //
        //      vertex 4 +-------------------+ vertex 3
        //               | \               / |
        //               |   \    m-3    /   |
        //               |     \       /     |
        //               |       \   /       |
        //               |  m=2    X   m=2   |       the centre is vertex 0
        //               |       /   \       |
        //               |     /       \     |
        //               |   /    m=1    \   |
        //               | /               \ |
        //      vertex 1 +-------------------+ vertex 2
        //
        //
        //
        //               Scan each triangle in the box
        //
       m1 := m; m2 := 0;
       If NOT(m=4) Then m3 := m+1 Else m3 :=1;
       deside := casttab[sh[m1]+1 ,sh[m2]+1, sh[m3]+1];

       If NOT(deside=0) Then Begin // ask is there a desition available -------- +If If NOT(deside=0)
        // append to ConLines array for export:
        setLength(conlines, Length(conlines)+1);
        with ConLines[High(ConLines)] do begin
          ih:=k;
        Case deside Of // ------- determin the by desided cast cuts ------------ +Case deside;
          1: Begin x1:=xh[m1]; y1:=yh[m1]; x2:=xh[m2]; y2:=yh[m2]; End;
          2: Begin x1:=xh[m2]; y1:=yh[m2]; x2:=xh[m3]; y2:=yh[m3]; End;
          3: Begin x1:=xh[m3]; y1:=yh[m3]; x2:=xh[m1]; y2:=yh[m1]; End;
          4: Begin x1:=xh[m1]; y1:=yh[m1]; x2:=xsec(m2,m3); y2:=ysec(m2,m3);
             End;
          5: Begin x1:=xh[m2]; y1:=yh[m2]; x2:=xsec(m3,m1); y2:=ysec(m3,m1);
             End;
          6: Begin x1:=xh[m3]; y1:=yh[m3]; x2:=xsec(m1,m2); y2:=ysec(m1,m2);
             End;
          7: Begin x1:=xsec(m1,m2); y1:=ysec(m1,m2);
                   x2:=xsec(m2,m3); y2:=ysec(m2,m3);
             End;
          8: Begin x1:=xsec(m2,m3); y1:=ysec(m2,m3);
                   x2:=xsec(m3,m1); y2:=ysec(m3,m1);
             End;
          9: Begin x1:=xsec(m3,m1); y1:=ysec(m3,m1);
                   x2:=xsec(m1,m2); y2:=ysec(m1,m2);
             End;
        End; // ---------------------------------------------------------------  -Case deside;
        end; // with

        // -------------------------------------------------------------------
       End; // -----------------------------------------------------------------  -If Not(deside=0)
      End; // ------------------------------------------------------------------  -For m
     End; // -------------------------------------------------------------------  -If z[k] in dmin .. dmax
    End; // --------------------------------------------------------------------  -For k
   End; // ---------------------------------------------------------------------  -If dmin && dmax in z[0] .. z[nc-1]
  End; // ----------------------------------------------------------------------  -For i
 End; // -----------------------------------------------------------------------  -For j
End;
//------ End of ----------------------------------------------------------------


{

procedure ConRecTest (var CL: ConLinesArray);

//------------------------------------------------------------------------------
// TestProcedure
//------------------------------------------------------------------------------

Const dimx = 100;  // dimension west - east
      dimy = 100;  // dimenstion north west
      dimh = 10;   // dimension for contour levels
//------------------------------------------------------------------------------
Var
 Mat:ConMatrix;  // 2D - Datafield
 scx:ConVector;  // scaling vector west - east
 scy:ConVector;  // scaling vector north - west
 hgt:ConVector;  // vector for the countur levels
 i,j:Integer;  // adress indexes
 x,y:Double;   // coord. values
 mi,ma:Double; // for minimum & maximum

//------------------------------------------------------------------------------

Begin
 setlength(scx,dimx); // create dynamicly the vectors and datafield
 setlength(scy,dimy);
 setlength(hgt,dimh);
 setlength(mat,dimx);
 For i:=0 to dimx-1 Do Setlength(mat[i],dimy);

 For i:=0 to dimx-1 Do scx[i]:= i * 10; // set scaling vector west - east
 For i:=0 to dimy-1 Do scy[i]:= i * 10; // set scaling vector north - south

 For i:=0 to dimx-1 Do  // ----------------------------------- set 2d data field
  For j:=0 to dimy-1 Do Begin
   x:=i-dimx/2;
   y:=j-dimy/2;
   mat[i,j]:= (sin(x/dimx*4*pi)    * cos(y/dimy*4*pi)) +
              (sin(x/dimx*2*pi)    * cos(y/dimy*2*pi)) +
              (sin(x/dimx*1*pi)    * cos(y/dimy*1*pi)) +
              (sin(x/dimx*0.5*pi)  * cos(y/dimy*0.5*pi))+
              (sin(x/dimx*0.25*pi) * cos(y/dimy*0.25*pi));
 End; // -----------------------------------------------------------------------

 mi:=1e16;    // ------------    Set the minimunm and maximum fof the data field
 ma:=-1e16;
 For i:=0 to dimx-1 Do
  For j:=0 to dimy-1 Do Begin
   if mat[i,j]<mi then mi:=mat[i,j];
   if mat[i,j]>ma then ma:=mat[i,j];
  End;        //----------------------------------------------------------------

For i:=0 to dimh-1 Do hgt[i]:=mi+i*(ma-mi)/(dimh-1); // ----- create cut levels

  CL:=nil;

 conrec(mat,0,dimx-1,0,dimy-1,scx,scy,dimh,hgt,CL); // call the contour algorithm

End;
}

End.
// --- EndOf File --------------------------------------------------------------


