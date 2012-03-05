#!/bin/bash

#$ -pe orte.pe 12
#$ -cwd
#$ -S /bin/bash
#$ -V
#$ -l vhighmem

#  for test on local machine only, comment out when use it on SGE 
NSLOTS=2  
####################################################################################################################################
#   This is a script which calls mothur's command and system command to 
#   do metagenomic analysis. 
#   
#   
#   Script: 	m_sample_cluster.sh
#   Input: 	1.fasta file  2. name file
#   Output:	OTUs
#		Sequence alignment
#		tree files
#		OTU reps
#   		Taxonomy of OTUs
#		Sample rarefaction curves
#		Phylodiversity
#
#
#   Dependency: mothur-1.23.0, bash
#    
#
#   To execute the script on a linux machine $ "m_sample_cluster.sh fasta_file_name"
#   To execute the scrip in csf server:$ qsub path/m_sample_cluster.sh sfffile_name
#
#   ping.wang@manchester.ac.uk, FLS, University of Manchester, 18/1/2012
###################################################################################################################################
cwd=$PWD
inf=$1 
fn=`echo $inf | sed "s/.[a-zA-Z0-9]*$//"`
nfn=`echo $inf | sed "s/.unique.[a-zA-Z0-9]*$//"`
mothur "#unique.seqs(fasta=$fn.fasta)"
mothur "#summary.seqs(fasta=$fn.unique.fasta)"

mothur "#pre.cluster(fasta=$fn.unique.fasta,name=$fn.names,diffs=3)"
mothur "#chimera.uchime(fasta=$fn.unique.precluster.fasta,reference=$HOME/ref_data/silva.gold.align, chimealns=T, minh=0.3, mindiv=0.5, xn=8.0, dn=1.4, xa=1.0, chunks=4, minchunk=64, idsmoothwindow=32, maxp=2, skipgaps=T, skipgaps2=T, minlen=10, maxlen=10000, ucl=false, queryfract=0.5)"
mothur "#remove.seqs(accnos=$fn.unique.precluster.uchime.accnos,name=$fn.unique.precluster.names)"
mothur "#remove.seqs(accnos=$fn.unique.precluster.uchime.accnos,fasta=$fn.unique.precluster.fasta)"

mothur "#summary.seqs(fasta=$fn.unique.precluster.pick.fasta)"

mothur "#align.seqs(candidate=$fn.unique.precluster.pick.fasta, template=$HOME/ref_data/silva.bacteria.fasta, search=kmer, ksize=8, align=needleman, match=1, mismatch=-2, gapopen=-1, flip=t, threshold=0.5, processors=$NSLOTS)"
mothur "#filter.seqs(fasta=$fn.unique.precluster.pick.align, trump=., vertical=T, processors=$NSLOTS)"
mothur "#dist.seqs(fasta=$fn.unique.precluster.pick.filter.fasta,calc=onegap,countends=F,cutoff=0.20,output=lt,processors=$NSLOTS)"
mothur "#cluster(phylip=$fn.unique.precluster.pick.filter.phylip.dist,name=$fn.unique.precluster.pick.names,cutoff=0.20,precision=100,hard=t,method=nearest)"


mothur "#get.oturep(phylip=$fn.unique.precluster.pick.filter.phylip.dist, fasta=$fn.unique.fasta, list=$fn.unique.precluster.pick.filter.phylip.nn.list,label=unique-0.01-0.03-0.05-0.10,name=$fn.unique.precluster.pick.names)"
mothur "#align.seqs(candidate=$fn.unique.precluster.pick.filter.phylip.nn.0.03.rep.fasta, template=$HOME/ref_data/silva.bacteria.fasta, search=kmer, ksize=8, align=needleman, match=1, mismatch=-2, gapopen=-1, flip=t, threshold=0.5, processors=$NSLOTS)"
mothur "#clearcut(fasta=$fn.unique.precluster.pick.filter.phylip.nn.0.03.rep.align, DNA=t)"

mothur "#phylo.diversity(tree=$fn.unique.precluster.pick.filter.phylip.nn.0.03.rep.tre,freq=0.1,rarefy=T)"  #,rarefy=T,, collect=T,name=$fn.unique.precluster.pick.names,rarefy=T

mothur "#classify.seqs(fasta=$fn.unique.precluster.pick.filter.phylip.nn.0.03.rep.fasta, template=$HOME/ref_data/silva.bacteria.fasta, taxonomy=$HOME/ref_data/silva.bacteria.silva.tax,method=bayesian,cutoff=95,probs=f)"
mothur "#classify.otu(taxonomy=$fn.unique.precluster.pick.filter.phylip.nn.0.03.rep.silva.taxonomy, list=$fn.unique.precluster.pick.filter.phylip.nn.list,basis=otu,probs=f)"


echo $fn
echo $nfn


kill $$


