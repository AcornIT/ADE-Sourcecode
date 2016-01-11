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
/* e-table.i - ascii code tables */

DEFINE VARIABLE qbf-ascii AS CHARACTER NO-UNDO.
DEFINE VARIABLE qbf-table AS CHARACTER NO-UNDO.

ASSIGN
  qbf-ascii
    = "nul,soh,stx,etx,eot,enq,ack,bel,bs,ht,lf,vt,ff,cr,so,si,":u
    + "dle,dc1,dc2,dc3,dc4,nak,syn,etb,can,em,sub,esc,fs,gs,rs,us,":u
    + "' ','!','~"','#','$','%','&',''','(',')','*','+',44,'-','.','/',":u
    + "'0','1','2','3','4','5','6','7','8','9',':','~;','<','=','>','?',":u
    + "'@','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O',":u
    + "'P','Q','R','S','T','U','V','W','X','Y','Z','[','~\',']','^','_',":u
    + "'`','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o',":u
    + "'p','q','r','s','t','u','v','w','x','y','z','~{','|','~}','~~',127,":u
    + "128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,":u
    + "144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,":u
    + "160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,":u
    + "176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,":u
    + "192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,":u
    + "208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,":u
    + "224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,":u
    + "240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255":u

  qbf-table = "nul  0 (00h),soh  1 (01h),stx  2 (02h),etx  3 (03h),":u
            + "eot  4 (04h),enq  5 (05h),ack  6 (06h),bel  7 (07h),":u
            + "bs   8 (08h),ht   9 (09h),lf  10 (0Ah),vt  11 (0Bh),":u
            + "ff  12 (0Ch),cr  13 (0Dh),so  14 (0Eh),si  15 (0Fh),":u
            + "dle 16 (10h),dc1 17 (11h),dc2 18 (12h),dc3 19 (13h),":u
            + "dc4 20 (14h),nak 21 (15h),syn 22 (16h),etb 23 (17h),":u
            + "can 24 (18h),em  25 (19h),sub 26 (1Ah),esc 27 (1Bh),":u
            + "fs  28 (1Ch),gs  29 (1Dh),rs  30 (1Eh),us  31 (1Fh)":u.

/* e-table.i - end of file */
