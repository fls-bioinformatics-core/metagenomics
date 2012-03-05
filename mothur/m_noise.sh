#!/bin/bash
#$ -pe orte.pe 12
#$ -cwd
#$ -S /bin/bash
#$ -V
#$ -l highmem 

#  for test on local machine only, comment out when use it on SGE 
NSLOTS=2  
####################################################################################################################################
#   This is a script which calls mothur's command and system command to 
#   denoise sequencing errors. The mothur's implemetation is based on Chris Quence's package of 
#   Ampliconnoise. 
#   The seqnoise step in the mothur's implementation does
#   not work at the moment yet.
#   
#   Script: 	m_noise.sh
#   Input: 	1.sff file, 2.map file for oligos
#   Output:	*.fna, denoised sequence file.
#		*.groups, a group file which labels the sample with a group name.
#		*.names, a name file contains grouping information about the samples.
#   Requires: 	A map file which provide the sequencing primer and sample barcode and sample name, saved as "map.oligos"
#   dependency: mothur-1.23.0, bash
#    		Lookup files: (GS FLX Titanium, GSFLX, GS20) http://www.mothur.org/wiki/Lookup_files
#		($HOME/mothur/LookUp_Titanium.pat)
#		Reference database: $HOME/ref_data/
#			Greengenes:  http://www.mothur.org/w/images/7/72/Greengenes.alignment.zip
#				     http://www.mothur.org/w/images/2/21/Greengenes.gold.alignment.zip
#				     http://www.mothur.org/w/images/1/16/Greengenes.tax.tgz
#			Silva	     http://www.mothur.org/w/images/9/98/Silva.bacteria.zip
#				     http://www.mothur.org/w/images/3/3c/Silva.archaea.zip
#				     http://www.mothur.org/w/images/1/1a/Silva.eukarya.zip
#				     http://www.mothur.org/w/images/f/f1/Silva.gold.bacteria.zip
#
#	forward	CATGCTGCCTCCCGTAGGAGT
#	reverse	TCAGAGTTTGATCCTGGCTCAG
#	barcode	ACGAGTGCGT	N0_1
#	barcode	ACGCTCGACA	N1_1
#	barcode	AGACGCACTC	N3_1
#
#   To execute the script on a linux machine $ "m_noise.sh sfffile_name"
#   To execute the scrip in csf server:$ qsub path/m_noise.sh sfffile_name
#
#   ping.wang@manchester.ac.uk, FLS, University of Manchester, 18/1/2012
###################################################################################################################################
inf=$1
fn=`echo $inf | sed "s/.[a-zA-Z0-9]*$//"`
sfx=`echo $inf | sed "s/^$fn.//"`
mothur "#sffinfo(sff=$fn.sff,flow=T,trim=t)"
mothur "#trim.flows(flow=$fn.flow,oligos=map.oligos,pdiffs=2, maxflows=720, bdiffs=1,processors=$NSLOTS)" 
mothur "#shhh.flows(flow=$fn.trim.flow,lookup=$HOME/mothur/LookUp_Titanium.pat,processors=$NSLOTS)"
mothur "#trim.seqs(fasta=$fn.trim.shhh.fasta,name=$fn.trim.shhh.names,oligos=map.oligos,minlength=400,maxambig=0,maxhomop=8,qaverage=25,qwindowaverage=35,qwindowsize=50, processors=$NSLOTS)"

#mothur "#shhh.seqs(fasta=$fn.trim.shhh.trim.fasta, name=$fn.trim.shhh.trim.names,group=$fn.trim.shhh.groups, sigma=0.01)"
#mothur "#shhh.seqs(fasta=$fn.$sfx, name=$fn.names,sigma=0.01, processors=$NSLOTS)"

mothur "#unique.seqs(fasta=$fn.trim.shhh.trim.fasta)"

mothur "#align.seqs(candidate=$fn.trim.shhh.trim.unique.fasta, template=$HOME/ref_data/silva.bacteria.fasta,search=kmer,ksize=8,align=needleman,match=1,mismatch=-2,gapopen=-1,flip=t,threshold=0.5,processors=$NSLOTS)"

mothur "#screen.seqs(fasta=$fn.trim.shhh.trim.unique.align, minlength=400, optimize=start, criteria=85, alignreport=$fn.trim.shhh.trim.unique.align.report,processors=4,group=$fn.trim.shhh.groups,name=$fn.trim.shhh.trim.names)"

mothur "#filter.seqs(fasta=$fn.trim.shhh.trim.unique.good.align, vertical=T, trump=., processors=$NSLOTS)"
mothur "#make.group(fasta=$fn.trim.shhh.trim.unique.good.filter.fasta, groups=$fn)"

#  $fn.trim.shhh.trim.good.names
#  $fn.trim.shhh.trim.unique.good.filter.fasta
#  $fn.trim.shhh.trim.unique.good.filter.groups

exit 0
