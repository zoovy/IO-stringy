MODDIR = IO
MODPATH = IO/Stringy.pm

### Variables:
TOP      = ..
LIB      = ../lib
POD2HTML = perl \
	-I ~/dev/perl/podpeople/lib \
	-I /usr/lib/perl5/site-perl \
	~/dev/perl/podpeople/bin/pod2coolhtml
READMES  = ${TOP}/README \
           ${TOP}/README.system 


### Rules:
all:  Makefile readmes htmls

Makefile: Makefile.cfg
	pmdocmake

dist: all 

${TOP}/README : ${LIB}/${MODPATH} ${TOP}/Makefile
	pod2readme -t $< > ${TOP}/README

${TOP}/README.system : ${TOP}/Makefile
	perlsetup > ${TOP}/README.system

readmes: ${READMES}

htmls: ${LIB}/${MODPATH}
	( ${POD2HTML} -R ${LIB} -I ${MODDIR} -O . )




