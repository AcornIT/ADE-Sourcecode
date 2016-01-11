/*********************************************************************
* Copyright (C) 2000 by Progress Software Corporation. All rights    *
* reserved. Prior versions of this work may contain portions         *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/
/* t-c-eng.p - English language definitions for Scrolling Lists */

{ prores/t-define.i }

DEFINE INPUT PARAMETER qbf-s AS INTEGER NO-UNDO.

IF qbf-s < 0 THEN RETURN.
qbf-lang = "".

/*
As of [Thu Apr 25 15:13:33 EDT 1991], this
is a list of the scrolling list programs:
  u-browse.i     c-print.p
  b-pick.p       i-pick.p
  c-entry.p      i-zap.p
  c-field.p      s-field.p
  c-file.p       u-pick.p
  c-flag.p       u-print.p
  c-form.p
*/

/* c-entry.p,c-field.p,c-file.p,c-form.p,c-print.p,c-vector.p,s-field.p */
ASSIGN
  qbf-lang[ 1] = '�Ђ�팓� �� ����� Ƃ� ��� � Р�袓� ['
               + KBLABEL("END-ERROR") + '] Ƃ� �퉋�.'
  qbf-lang[ 2] = 'Ѡ�袓� [' + KBLABEL("GO") + '] ���� �Ђ�팆��,['
               + KBLABEL("INSERT-MODE") + '] Ƃ� ��������,['
               + KBLABEL("END-ERROR") + '] Ƃ� �퉋�.'
  qbf-lang[ 3] = 'Ѡ�袓� [' + KBLABEL("END-ERROR")
               + '] ���� �Ђ�팆�� �� �����.'
  qbf-lang[ 4] = 'Ѡ�袓� [' + KBLABEL("GO") + '] ���� �Ђ�팆��, ['
               + KBLABEL("INSERT-MODE")
               + '] �������� І��Ƥ./���./Ф�Ƥ.'
  qbf-lang[ 5] = '����퓓�/ء�����'
  qbf-lang[ 6] = 'ц��Ƥ���/ء�����-'
  qbf-lang[ 7] = '�����---,Ѥ�Ƥ����,ц��Ƥ���'
  qbf-lang[ 8] = '���줆�� ��� І�ᗡ...'
  qbf-lang[ 9] = '�Ђ���� ц�ᗡ'
  qbf-lang[10] = '�Ђ���� ������'
  qbf-lang[11] = '�Ђ���� ������ �� ���'
  qbf-lang[12] = '�Ђ���� ������ Ѥ�����'
  qbf-lang[13] = '�Ђ���� ދ����� ������'
  qbf-lang[14] = '�����' /* should match t-q-eng.p "Join" string */
  qbf-lang[16] = '        Database' /* max length 16 */
  qbf-lang[17] = '          �����' /* max length 16 */
  qbf-lang[18] = '           ц��' /* max length 16 */
  qbf-lang[19] = '  ��Ƃ��� Љ芋�' /* max length 16 */
  qbf-lang[20] = '� ����'
  qbf-lang[21] = '�І���ᡆ� �� Љ芋� ������ᗡ ��� �ᡠ�� - 1 ���'
  qbf-lang[22] = '֠ Ф������� ��� �퉋� ��� �К������ ������; '
  qbf-lang[23] = '��졠�� � �Ђ���� �� �� ��ƈ������ Ф������� ������'
  qbf-lang[24] = '�碓� ��� ������� ��� ������ ������'

               /* 12345678901234567890123456789012345678901234567890 */
  qbf-lang[27] = '��袓� �� ���� Ƃ� �������䔋 �ᡠ��, � �碓� ��'
  qbf-lang[28] = '�ᢓ� ��ƈ������� ������ᗡ ��� �ᡠ�� (������'
  qbf-lang[29] = '��������) Ƃ� ��������� ��艆� ���� ����З��.'
  qbf-lang[30] = '�碓� �� �ᢓ� ��ƈ������� ������ᗡ ��� �ᡠ��' 
  qbf-lang[31] = '(������ ��������) Ƃ� І�� �� ��������� ��艆�.'
  qbf-lang[32] = '�碓� ��� ��ሓ� ��� �������� ��� �ᡠ��.'.

RETURN.
