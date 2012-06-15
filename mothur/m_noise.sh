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
#		map.oligos				(file name)
#		#forward	CATGCTGCCTCCCGTAGGAGT	(file content)
#		#reverse	TCAGAGTTTGATCCTGGCTCAG
#		barcode	ACGAGTGCGT	N0_1
#		barcode	ACGCTCGACA	N1_1
#
#   dependency: mothur-1.25.0, bash
#    		Lookup files: (GS FLX Titanium, GSFLX, GS20) http://www.mothur.org/wiki/Lookup_files
#		($MOTHUR_LOOKUP/LookUp_Titanium.pat)
#		Reference database: $MOTHUR_REF_DATA/
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
#   ping.wang@manchester.ac.uk, FLS, University of Manchester, 02/5/2012
#   Updates: peter.briggs@manchester.ac.uk 15/6/2012
###################################################################################################################################
inf=$1
fn=`echo $inf | sed "s/.[a-zA-Z0-9]*$//"`
sfx=`echo $inf | sed "s/^$fn.//"`
#
# Locations of lookup and reference data files
: ${MOTHUR_LOOKUP:=$HOME/mothur}
: ${MOTHUR_REF_DATA:=$HOME/ref_data}
if [ ! -d "$MOTHUR_LOOKUP" ] ; then
    echo Missing lookup data directory $MOTHUR_LOOKUP
    echo Set the MOTHUR_LOOKUP variable to specify the location of the lookup data files
    echo if they are installed somewhere else
    exit 1
fi
if [ ! -d "$MOTHUR_REF_DATA" ] ; then
    echo Missing reference alignments data directory $MOTHUR_REF_DATA
    echo Set the MOTHUR_REF_DATA variable to specify the location of the reference files
    echo if they are installed somewhere else
    exit 1
fi
mothur "#sffinfo(sff=$fn.sff,flow=T,trim=t)"
mothur "#trim.flows(flow=$fn.flow,oligos=map.oligos,pdiffs=2, maxflows=720, bdiffs=1,processors=$NSLOTS)" 
mothur "#shhh.flows(flow=$fn.trim.flow,lookup=$MOTHUR_LOOKUP/LookUp_Titanium.pat,processors=$NSLOTS)"
mothur "#trim.seqs(fasta=$fn.trim.shhh.fasta,name=$fn.trim.shhh.names,oligos=map.oligos,minlength=400,maxambig=0,maxhomop=8,qaverage=25,qwindowaverage=35,qwindowsize=50, processors=$NSLOTS)"

mothur "#shhh.seqs(fasta=$fn.trim.shhh.trim.fasta, name=$fn.trim.shhh.trim.names,group=$fn.trim.shhh.groups, sigma=0.01)"
mothur "#shhh.seqs(fasta=$fn.$sfx, name=$fn.names,sigma=0.01, processors=$NSLOTS)"

mothur "#unique.seqs(fasta=$fn.trim.shhh.trim.fasta)"

mothur "#align.seqs(candidate=$fn.trim.shhh.trim.unique.fasta, template=$MOTHUR_REF_DATA/silva.bacteria.fasta,search=kmer,ksize=8,align=needleman,match=1,mismatch=-2,gapopen=-1,flip=t,threshold=0.5,processors=$NSLOTS)"

mothur "#screen.seqs(fasta=$fn.trim.shhh.trim.unique.align, minlength=400, optimize=start, criteria=85, alignreport=$fn.trim.shhh.trim.unique.align.report,processors=4,group=$fn.trim.shhh.groups,name=$fn.trim.shhh.trim.names)"

mothur "#filter.seqs(fasta=$fn.trim.shhh.trim.unique.good.align, vertical=T, trump=., processors=$NSLOTS)"
mothur "#make.group(fasta=$fn.trim.shhh.trim.unique.good.filter.fasta, groups=$fn)"

#  $fn.trim.shhh.trim.good.names
#  $fn.trim.shhh.trim.unique.good.filter.fasta
#  $fn.trim.shhh.trim.unique.good.filter.groups

exit 0
