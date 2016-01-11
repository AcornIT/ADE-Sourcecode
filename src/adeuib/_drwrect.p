/*********************************************************************
* Copyright (C) 2000 by Progress Software Corporation ("PSC"),       *
* 14 Oak Park, Bedford, MA 01730, and other contributors as listed   *
* below.  All Rights Reserved.                                       *
*                                                                    *
* The Initial Developer of the Original Code is PSC.  The Original   *
* Code is Progress IDE code released to open source December 1, 2000.*
*                                                                    *
* The contents of this file are subject to the Possenet Public       *
* License Version 1.0 (the "License"); you may not use this file     *
* except in compliance with the License.  A copy of the License is   *
* available as of the date of this notice at                         *
* http://www.possenet.org/license.html                               *
*                                                                    *
* Software distributed under the License is distributed on an "AS IS"*
* basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. You*
* should refer to the License for the specific language governing    *
* rights and limitations under the License.                          *
*                                                                    *
* Contributors:                                                      *
*                                                                    *
*********************************************************************/
/*----------------------------------------------------------------------------

File: _drwrect.p

Description:
    Draw a rectangle in the current h_frame.

Input Parameters:
   <None>

Output Parameters:
   <None>

Author: D. Ross Hunter,  Wm.T.Wood

Date Created: 1992 

----------------------------------------------------------------------------*/
 
{adeuib/uniwidg.i}
{adeuib/layout.i}
{adeuib/sharvars.i}

&Scoped-define min-height-chars .2
&Scoped-define min-cols .2

DEFINE VAR cur-lo       AS CHARACTER                                  NO-UNDO.

DEFINE BUFFER parent_U FOR _U.
DEFINE BUFFER parent_L FOR _L.

FIND _U WHERE _U._HANDLE = _h_win.
cur-lo = _U._LAYOUT-NAME.
               

/* Get the RECID of the parent frame */
FIND parent_U WHERE parent_U._HANDLE = _h_frame.
FIND parent_L WHERE RECID(parent_L)  = parent_U._lo-recid.

/* Create a Universal Widget Record and populate it as much as possible. */
CREATE _U.
CREATE _L.
CREATE _F.

ASSIGN /* Rectangle-specific settings */
       _count[{&RECT}]      = _count[{&RECT}] + 1
       _U._NAME             = "RECT-" + STRING(_count[{&RECT}])
       _U._TYPE             = "RECTANGLE":U       
       _L._EDGE-PIXELS      = IF parent_L._3-D THEN 2  ELSE 1
       _L._FILLED           = IF parent_L._3-D THEN no ELSE yes
       _L._GRAPHIC-EDGE     = yes
       /* Standard Settings for Universal and Field records */
       { adeuib/std_uf.i &SECTION = "DRAW-SETUP" }
       . 

/* If the user just clicked, then use default sizes.  Otherwise use the
   size drawn by the user.  The default size is equal to the grid spacing
   (minus 1 pixel).  NOTE: the Custom Section may override this. */
IF (_second_corner_x eq _frmx) AND (_second_corner_y eq _frmy)
THEN ASSIGN _L._WIDTH  = ((_h_frame:GRID-UNIT-WIDTH-P * _h_frame:GRID-FACTOR-H)
                           - 1) / SESSION:PIXELS-PER-COLUMN 
            _L._HEIGHT = ((_h_frame:GRID-UNIT-HEIGHT-P * _h_frame:GRID-FACTOR-V)
                           - 1) / SESSION:PIXELS-PER-ROW.
ELSE ASSIGN _L._WIDTH  = (_second_corner_x - _frmx + 1) /
                           SESSION:PIXELS-PER-COLUMN / _cur_col_mult
            _L._HEIGHT = (_second_corner_y - _frmy + 1) / 
                           SESSION:PIXELS-PER-ROW / _cur_row_mult.

/* Are there any custom widget overrides?                               */
IF _custom_draw ne ? THEN RUN adeuib/_usecust.p (_custom_draw, RECID(_U)).

/* Create the rectangle based on the Universal widget record. */
RUN adeuib/_undrect.p (RECID(_U)).

/* FOR EACH layout other than the current layout, populate _L records for them */
{adeuib/multi_l.i}