/*********************************************************************
* Copyright (C) 2001 by Progress Software Corporation ("PSC"),       *
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
*   Per S Digre (pdigre@progress.com)                                *
*                                                                    *
*********************************************************************/
/*--------------------------------------------------------------------
File: error.p
Purpose: Code to show current logs in a window programs.
Author(s) :Per S Digre/PSC
Updated: 04/04/00 pdigre@progress.com
           Initial version
         04/25/01 adams@progress.com
           WebSpeed integration
--------------------------------------------------------------------*/

{ src/web/method/cgidefs.i }
{ webtools/plus.i }

fHeader().

DYNAMIC-FUNCTION ("LogNote" IN web-utilities-hdl,
                  "error", "Error:" + get-value("error")) NO-ERROR.

{&OUT} '<H1>Error:</H1>~n' get-value("error").

fFooter().