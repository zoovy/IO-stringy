
TOP = ..
LIB = ../lib
P2CH = perl -I${HOME}/dev/perl/podpeople/lib ${HOME}/bin/pod2coolhtml

dist: all

all: readme htmls

readme: ../README

#../README : ${LIB}/IO/Scalar.pm
#	pod2readme -t $< > ../README

htmls:
	${P2CH} -R ../lib -O . -I IO




