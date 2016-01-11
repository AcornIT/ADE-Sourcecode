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
/* t-q-eng.p - English language definitions for Query module */

{ prores/t-define.i }

DEFINE INPUT PARAMETER qbf-s AS INTEGER NO-UNDO.

IF qbf-s < 0 THEN RETURN.
qbf-lang = "".

IF qbf-s = 1 THEN
  ASSIGN
    qbf-lang[ 1] = '��� ������� ������� �''���� �� �������� ����������.'
    qbf-lang[ 2] = '������ ��������,�����,��������� ��������'
    qbf-lang[ 3] = '������������ ���,���� ����,��� �����'
    qbf-lang[ 4] = '��� ����� ������ ������ ��''���� �� ������.'
    qbf-lang[ 5] = '����������� ��������� ��� ��������'
    qbf-lang[ 6] = '' /* special total message: created from #7 or #8 */
    qbf-lang[ 7] = '������� ��������.'
    qbf-lang[ 8] = '� ������� ���������� �������� ����� '
    qbf-lang[ 9] = '������� ��������...   ������� [' + KBLABEL("END-ERROR")
                 + '] ��� �������.'
    qbf-lang[10] = '������� ��,����� ��������� ���,����� ��������� ��� � ��� ��,'
                 + '����� ���������� ���,����� ���������� ��� � ��� ��,'
                 + '��� ������� ��,����������� ��,������� ���'
    qbf-lang[11] = '��� �������� ���������� ��������.'
    qbf-lang[13] = '����� ������ ��� ���� ����� ������� ��� �������.'
    qbf-lang[14] = '����� ������ ��� ���� ��������� ������� ��� �������.'
    qbf-lang[15] = '��� ����� ������ ����� ��������.'
    qbf-lang[16] = '��������'
    qbf-lang[17] = '�������� ��� �������� ��� ������ ��������.'
    qbf-lang[18] = '������� [' + KBLABEL("GO")
                 + '] � [' + KBLABEL("RETURN")
                 + '] ��� ������� ������, � [' + KBLABEL("END-ERROR")
                 + '] ��� �����.'
    qbf-lang[19] = '������� ��� ������ ��������...'
    qbf-lang[20] = '� ����� �������� (����� "compiled") ������ ��''���� �� ���������. '
                 + '������ �� ��������� ��� ���� :^1) ����� PROPATH,^2) ������ '
                 + '�� ������ �������� .r , �^3) �� ������  ����� "uncompiled" ������ .p.^(����� �� '
                 + '������ <dbname>.ql ��� �������� ������ ��� "compiler").^^�������� '
                 + '�� ����������, ���� ������ �� ���������� ������ ������ ��� ��������. '
                 + '������ �� ����������; '
    qbf-lang[21] = '������� ��� ������ "WHERE" ���� �������� ����� �������� '
                 + '��� ���� ����� ���� ��� ��������� (RUN-TIME). ���� ��� '
                 + '������������ ������� ����, ��� �������������. ������ �� '
                 + '���������� ��������� �� ������ WHERE; '
    qbf-lang[22] = '������� [' + KBLABEL("GET")
                 + '] ��� �� ������� ����������� ����� ���������.'.

ELSE

IF qbf-s = 2 THEN
  ASSIGN
    qbf-lang[ 1] = '����.,��������� ��� ������� �������.'
    qbf-lang[ 2] = '�����.,��������� ��� ����������� �������.'
    qbf-lang[ 3] = '�����,��������� ��� ����� �������.'
    qbf-lang[ 4] = '������.,��������� ��� ��������� �������.'
    qbf-lang[ 5] = '���,�������� ���� ��������.'
    qbf-lang[ 6] = '�����.,�������� ��� ��������� ��������.'
    qbf-lang[ 7] = '������.,��������� ��� ��������� �������� �� ��� �������.'
    qbf-lang[ 8] = '��������,�������� ��� ��������� ��������.'
    qbf-lang[ 9] = '�������,������� ����� ������ ��������.'
    qbf-lang[10] = '�����.,������ ��� �������� �� �� �������� ��� �������'
    qbf-lang[11] = '�����,����� �� �������� ��� ���� ������ ��� ����� �����.'
    qbf-lang[12] = '������.,��������� �� �������� ��������.'
    qbf-lang[13] = '����,������� �������� ��� ������� �������� �� �� ������ WHERE.'
    qbf-lang[14] = '�������,������� �������� ��� ������ ������ � ���������.'
    qbf-lang[15] = '�������.,������� ������������ ��������.'
    qbf-lang[16] = '�����.,������� ����� ��������.'
    qbf-lang[17] = '������.,����������� ��� �� �������� �������� ��������.'
    qbf-lang[18] = '�����.,����� ������������ ��� ������.'
    qbf-lang[19] = '�����,�����.'
    qbf-lang[20] = ''. /* terminator */

RETURN.
