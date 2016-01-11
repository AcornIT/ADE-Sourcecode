/*********************************************************************
* Copyright (C) 2000 by Progress Software Corporation. All rights    *
* reserved. Prior versions of this work may contain portions         *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/
/* t-i-eng.p - English language definitions for Directory */

{ prores/t-define.i }

DEFINE INPUT PARAMETER qbf-s AS INTEGER NO-UNDO.

IF qbf-s < 0 THEN RETURN.
qbf-lang = "".

/*i-dir.p,i-pick.p,i-zap.p,a-info.p,i-read.p*/
ASSIGN
  qbf-lang[ 1] = '���Ɨ��,graph,����퓓�,query,����З��'
  qbf-lang[ 2] = '�碓� �� І��Ƥ��� ���'
  qbf-lang[ 3] = 'ǂ� �� �Ё ��� Р������ ��Ƌ� ������ ����� 
                  ���/� І�� Р�����Ћ���� :^'
               + '1) ؂ ������ "database" ��� ���� �䡄����^'
               + '2) ���� �ᡆ� �������� ��� ������ ��� "database"^'
               + '3) ��� ����� �����獠�� Ф�������'
  qbf-lang[ 4] = '� ������� ��� ���� ~{1~} Ф�І� �� �ᡠ� ��������. Ѡ������ �����碓�.'
  qbf-lang[ 5] = 'ؤ�� �Ћ�舆䢇� ����ᗡ. Ѡ������ ���Ƥ���� ������ ! '
               + '� ���Ƥ��� �Ё ��Ћ�� ������Ƌ ��Ơ�ᗡ �� �Ћ���䊆�碆� �礋.'
  qbf-lang[ 6] = 'ц��Ƥ���,Database-,Ѥ�Ƥ����'
  qbf-lang[ 7] = '�Ђ����ᗢ� �Ђ���䛇� ��� ������'
  qbf-lang[ 8] = '��'
  qbf-lang[ 9] = '�Ђ����'
  qbf-lang[10] = '����� ���Ɨ��,graph,����퓓��,query,����З���'
  qbf-lang[11] = '����� ���Ɨ��,graph,����퓓��,query,����З���'
  qbf-lang[12] = '����� ���Ɨ��,graph,��������,query,�����碆��'
  qbf-lang[13] = 'ދ��� ���Ɨ��,graph,ދ��� ��������,query,'
               + 'ؤ����� �����碆��'
  qbf-lang[14] = 'Ƃ� �������,Ƃ� �Ћ�舆䢇,Ƃ� ���Ƥ���'
  qbf-lang[15] = '���퉆��...'
  qbf-lang[16] = '������� ~{1~} �Ё ���� ������Ƌ'
  qbf-lang[17] = '�Ћ�舆䢇 �� ~{1~}'
  qbf-lang[18] = '��� ����ኆ���'
  qbf-lang[19] = '؉� �� �Ђ��ƍ� �� ���Ƥ����. ['
               + KBLABEL('RETURN') + '] Ƃ� �Ђ����/��줗�� �Ђ����.'
  qbf-lang[20] = 'Ѡ�袓� [' + KBLABEL('GO') + '] ���� �Ђ�팆��, � ['
               + KBLABEL('END-ERROR') + '] Ƃ� �퉋� ���� ���Ƥ���.'
  qbf-lang[21] = 'ކ���ᡇ�� ��� ~{1~} ��� �� ~{2~}.'
  qbf-lang[22] = '���Ƥ��� ��� ~{1~}.'
  qbf-lang[23] = '[' + KBLABEL("GO") + '] Ƃ� �Ђ����, ['
               + KBLABEL("INSERT-MODE") + '] Ƃ� ��������, ['
               + KBLABEL("END-ERROR") + '] Ƃ� �퉋�.'
  qbf-lang[24] = '�������� ��� ������Ƌ� �����碆�� �� ��� �������� ...'
/*a-info.p only:*/ /* 25..29 use format x(64) */
  qbf-lang[25] = '�䓁 �� Ф�Ƥ���� �����ᑆ� �� І��������� ��� ������'
  qbf-lang[26] = '������ᗡ ��袓� �Ё ��� ������Ɓ ���, ���������� Ћ��'
  qbf-lang[27] = '������Ƈ�� Ф�Ƥ������ ��舋� �� Ћ�� �����碆��,'
  qbf-lang[28] = '���Ɨ��,����퓓�� ���.'
  qbf-lang[29] = '�碓� ��� Љ複 ������� ��� "path" ��� ������ ".qd" ��� ��袓�:'
  qbf-lang[30] = '��� ��튇�� �� ����� Ћ� �碆��.'
  qbf-lang[31] = 'Ѥ�І� �� �碆�� ��� ��� Ф�툓��� ��� ������᠕ ".qd".'
  qbf-lang[32] = '���ơ��� ��� ������Ƌ�...'.

RETURN.
