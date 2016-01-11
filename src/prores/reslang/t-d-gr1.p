/*********************************************************************
* Copyright (C) 2000 by Progress Software Corporation. All rights    *
* reserved. Prior versions of this work may contain portions         *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/
/* t-d-eng.p - English language definitions for Data Export module */

{ prores/t-define.i }

DEFINE INPUT PARAMETER qbf-s AS INTEGER NO-UNDO.

IF qbf-s < 0 THEN RETURN.
qbf-lang = "".

/*--------------------------------------------------------------------------*/
/* d-edit.p,a-edit.p */
IF qbf-s = 1 THEN
/*
When entering codes, the following methods may be used:
  'x' - literal character enclosed in single quotes.
  ^x  - interpreted as control-character.
  ##h - one or two hex digits followed by the letter "h".
  ### - one, two or three digits, a decimal number.
  xxx - "xxx" is a symbol such as "lf" from the following table.
*/
  ASSIGN
    qbf-lang[ 1] = '� �썃��� �З�'
    qbf-lang[ 2] = '�Ё ��� Р������ �ᡠ��.'
    qbf-lang[ 3] = 'Ѡ�袓� [' + KBLABEL("GET")
                 + '] Ƃ� �Ђ����/��줗�� �Ђ���� ��� ������ ؤ�����.'
    /* format x(70): */
    qbf-lang[ 4] = 'Ҡ�� ��� ����Ɨ�� ������, �� Р������ �䡄�������� '
                 + '���슆�� :'
    /* format x(60): */
    qbf-lang[ 5] = '�Љ�� ������褠� �� �� ���� ����ƗƂ��.'
    qbf-lang[ 6] = '������솓�� � ������褠� �������.'
    qbf-lang[ 7] = '� � Р��К�� ���������� ���� �� �� Ƥ���� "h".'
    qbf-lang[ 8] = '�, �� � ��� ����, �� ��������� �������.'
    qbf-lang[ 9] = '�ᡠ� �ơ����� �������. Ѡ������ �����碓� ��.'
    qbf-lang[10] = '�І���Ơ�� ��� ������褗� ������� ��� ����З��...'.

ELSE

/*--------------------------------------------------------------------------*/
/* d-main.p */
IF qbf-s = 2 THEN
  ASSIGN
    qbf-lang[ 1] = '���. :,     :,     :,     :,     :'
    qbf-lang[ 2] = '⠌��:'
    qbf-lang[ 3] = '������� ���Ɨ��'
    qbf-lang[ 4] = '����ᠢ� ���Ɨ��'
    qbf-lang[ 5] = 'ц��:,      :,      :,      :,      :'
    qbf-lang[ 7] = ' ��Ћ� ���Ɨ��:'
    qbf-lang[ 8] = '�Ђ�����ᄠ:'
    qbf-lang[ 9] = '(Ф瓇 ��Ƥ���= ������ᆕ І�ᗡ)'
    qbf-lang[10] = '  ���� ��Ƥ���:'
    qbf-lang[11] = ' �퉋� ��Ƥ���:'
    qbf-lang[12] = ' ؤ���퓇� ц�.:'
    qbf-lang[13] = '���������� ц�:'
    qbf-lang[14] = '� ���Ɨ�� ������ᗡ ��� �Ћ����ᑆ� ��� �������䔋� '
                 + '�ᡠ���. ��� �������, �� ��������� �Ё ��� ���Ɨ��.'
                 + '^�퉆�� �� �䡆�ᢆ��; '
    qbf-lang[15] = '��졠�� � ���Ɨ�� ������ᗡ ���� ��� ������ І�ᗡ.'
    qbf-lang[21] = '��� ����� ���碆� ��� �����䢠 ����� ���Ɨ��. '
                 + '�퉆�� �� �䡆�ᢆ��; '
    qbf-lang[22] = '�������� ��� Ф�Ƥ������� ���Ɨ��...'
    qbf-lang[23] = '"Compile" ��� Ф�Ƥ������� ���Ɨ��...'
    qbf-lang[24] = '���퉆�� ��� Ф�Ƥ������� Ћ� �������芇��...'
    qbf-lang[25] = '��졠�� � �Ђ������� �� �� �����/������'
    qbf-lang[26] = '������� ���Ɨ��� ��Ƥ��� - ~{1~} .'
    qbf-lang[31] = '�Ђ����ᗢ� �Р���퓇��� ��� �䊍ᢆ�� ���Ɨ��'
    qbf-lang[32] = '�Ђ����ᗢ� ������ �Ё ��� ��� ��Ơ��'.

ELSE

/*--------------------------------------------------------------------------*/
/* d-main.p */
/* this set contains only export formats.  Each is composed of the */
/* internal RESULTS id and the description.  The description must  */
/* not contain a comma, and must fit within format x(32).          */
IF qbf-s = 3 THEN
  ASSIGN
    qbf-lang[ 1] = 'PROGRESS,���Ɨ�� PROGRESS'
    qbf-lang[ 2] = 'ASCII   ,ǆ���� ASCII (Generic)'
    qbf-lang[ 3] = 'ASCII-H ,ASCII �� �Ђ���.������᠕ І���'
    qbf-lang[ 4] = 'FIXED   ,ASCII �������� �舋� (SDF)'
    qbf-lang[ 5] = 'CSV     ,���������� �� ������� (CSV)'
    qbf-lang[ 6] = 'DIF     ,DIF'
    qbf-lang[ 7] = 'SYLK    ,SYLK'
    qbf-lang[ 8] = 'WS      ,WordStar'
    qbf-lang[ 9] = 'WORD    ,Microsoft Word'
    qbf-lang[10] = 'WORD4WIN,Microsoft Word Ƃ� Windows'
    qbf-lang[11] = 'WPERF   ,WordPerfect'
    qbf-lang[12] = 'OFISW   ,CTOS/BTOS OfisWriter'
    qbf-lang[13] = 'USER    ,Ҡ������� �Ё ��� ��袓�'
    qbf-lang[14] = '*'. /* terminator for list */

/*--------------------------------------------------------------------------*/

RETURN.
