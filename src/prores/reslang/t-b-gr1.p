/*********************************************************************
* Copyright (C) 2000 by Progress Software Corporation. All rights    *
* reserved. Prior versions of this work may contain portions         *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/
/* t-b-eng.p - English language definitions for Build subsystem */

{ prores/t-define.i }

DEFINE INPUT PARAMETER qbf-s AS INTEGER NO-UNDO.

IF qbf-s < 0 THEN RETURN.
qbf-lang = "".

/*--------------------------------------------------------------------------*/
/* b-build.p,b-again.p */
IF qbf-s = 1 THEN
  ASSIGN
                /* formats: x(10) x(45) x(8) */
    qbf-lang[ 1] = 'Ѥ�Ƥ����,"Database" ��� �����,������'
    qbf-lang[ 2] = '� ����� ������� (Checkpoint) ������������. ���Ƥ���� �� ����� .qc '
                 + '��� ����� ��� �ƈ�������� �Ё ��� ����.'
    qbf-lang[ 3] = '�І���Ơ�� ���'     /*format x(15)*/
    qbf-lang[ 4] = 'Compile'      /*format x(15)*/
    qbf-lang[ 5] = 'Re-Compiling'   /*format x(15)*/
    qbf-lang[ 6] = '�І���Ơ�� ��� ������,�І���Ơ�� ��� ������,�І���Ơ�� Ф�Ƥ�������'
    qbf-lang[ 7] = '؉� �� �Ђ��ƍ� ����� �� �ƈ���������. ['
                 + KBLABEL("RETURN") + '] Ƃ� �Ђ����/��줗�� �Ђ����.'
    qbf-lang[ 8] = 'Ѡ�袓� [' + KBLABEL("GO") + '] ���� �Ђ�팆�� � ['
                 + KBLABEL("END-ERROR") + '] Ƃ� �퉋�.'
    qbf-lang[ 9] = '���줆�� ����ᗡ Ƃ� �������� ������ �ᢓ� ����� Ѥ�����...'
    qbf-lang[10] = '����� ��ᢆ� ���� ��� ������ Ѥ�����; '
    qbf-lang[11] = '���줆�� 퍍���� ������� ����� -OF.'
    qbf-lang[12] = '�І���Ơ�� ��� �ᢓ�� ������� �����.'
    qbf-lang[13] = '��� �����ᢓ���� ���� �� ��碆��.'
    qbf-lang[14] = '���Ƥ��� ��� �ЂЉ틡 ������ᗡ ��� ������� �����.'
    qbf-lang[15] = '�Ђ����ᗢ� ������'
    qbf-lang[16] = '�䡋����� ������,��� ������'
    qbf-lang[17] = '���ơ��� ��� ������ ������� (checkpoint)...'
    qbf-lang[18] = '�������� ��� ������ ������� (checkpoint)...'
    qbf-lang[19] = '脇 �К����. ������������� �� ��'
    qbf-lang[20] = '�Р��ƈ�������� ��� ������'
    qbf-lang[21] = '���줆�� ��� ������ "~{1~}" Ƃ� ��������.'
    qbf-lang[22] = '��졠�� � �ƈ�������� ��� ������ �礂� RECID � UNIQUE INDEX '
    qbf-lang[23] = '� ����� ��� ������.'
    qbf-lang[24] = '��� ���������� "recompiling".'
    qbf-lang[25] = '��� �К���� ���� І�� ��� �����. ��� �������芇�� � �����.'
    qbf-lang[26] = '��� �К���� ���� І�� ��� �����. � �К���䢠 ����� ���Ƥ�����.'
    qbf-lang[27] = '���ᆢ� ��� �ᢓ�� ����ᗡ Ф�����.'
    qbf-lang[28] = '�䡋����� ������'
    qbf-lang[29] = '�퉋�!'
    qbf-lang[30] = '�Ћ���� "Compile" ��� "~{1~}".'
    qbf-lang[31] = '�������� ��� ������ Ѡ���퓤�� (config)'
    qbf-lang[32] = '�����ᢓ���� Ӛ�� ���� ��� ���� "�ƈ��������" ���/� "compile".'
                 + '^^Ѡ�袓� ��Ћ�� Љ舓�� Ƃ� �� ��ᓆ �� �������� ����� (query log file).'
                 + '� Ƥ���� Ћ� І������ �� ���� ���ᑋ����.'.

ELSE

/*--------------------------------------------------------------------------*/
IF qbf-s = 2 THEN
  ASSIGN

/* b-misc.p */
    /* 1..10 for qbf-l-auto[] */
    qbf-lang[ 1] = 'onoma,*onoma*,eponymia,*eponymia*,Name'
    qbf-lang[ 2] = 'contact,*contact*,ypeythinos,yp*opsin,Address'
    qbf-lang[ 3] = '*odos,dieyth*,*dieythinsh,*dieythinsh*1,Address2'
    qbf-lang[ 4] = '*tax*thyrida*,*dieythinsh*2'
    qbf-lang[ 5] = '*dieythinsh*3,City'
    qbf-lang[ 6] = 'tax*kod*,*tax*kvd*,t*k*,St'
    qbf-lang[ 7] = 'polh,*polh*,Zip'
    qbf-lang[ 8] = 't*p,*tax*polh*,tk*polh,t*k*polh'
    qbf-lang[ 9] = 'nomos,*nomos*'
    qbf-lang[10] = '*xvra*,*xora*'

    qbf-lang[15] = '���ƍ� ދ��� ���Ɨ��'.

/*--------------------------------------------------------------------------*/

RETURN.
