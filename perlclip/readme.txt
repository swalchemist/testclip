PerlClip 
by James Bach and Danny Faught 
(uses Win32::Clipboard, by Aldo Calpini)

This program is released under the GPL 2.0 license.

Sometimes you need to test a text field with different kinds of stressful inputs. But,
it can be a pain to prepare the text strings. PerlClip is a tool that helps you do that.
PerlClip places prepared text into the Windows clipboard so you can paste it wherever
you need it. Press ctrl-c to exit the progam.

You can run the Perl script, or click on the EXE version (a DOS console window appears when you
do that). Enter the text pattern you want to produce. You can enter the following
things:

- any Perl code, such as the following:

"james" produces james
"james" x 5 produces jamesjamesjamesjamesjames
"a" x (2 ** 16) produces a string of "a" 2 to the 16th power (65536) in length 
chr(13) x 10 produces ten carriage returns 
"X" x 1000000 produces a string of one million X's
join "\r\n", (1..100) produces the number 1 through 100, each on its own line

- '$allchars' produces a string that includes all character codes from 1 to 255 (0 not
included).

- 'counterstring {num} [{char}]' produces a special string of length {num} that counts
its own characters. "counterstring 10" would produce "*3*5*7*10*" which is a ten
character long string, such that each asterisk is at a position in the string equal to
the number that precedes it. This is useful for pasting into fields that cut off text,
so that you can tell how many characters were actually pasted.

You can specify a separator other than asterisk. "counterstring 15 A" would produce
"A3A5A7A9A12A15A"

- textfile {name} loads the contents of a specified text file into the clipboard.


- u: 
("bisect up") if given after  two consecutive counterstring commands it will return 
a counterstring that is half-way between the two counterstring lengths. If given 
after another bisect command, it will bisect the range between the most recent bisection
and the upper limit of the range of the earlier bisection.
	
- d:
("bisect down") if given after  two consecutive counterstring commands it will return
a counterstring that is half-way between the two counterstring lengths. If given 
after another bisect command, it will bisect the range between the most recent 
bisection and the lower limit of the range of the earlier bisection.

- help:
Print the instructions.

When you see the "Ready to Paste!" message, the clipboard is prepared.