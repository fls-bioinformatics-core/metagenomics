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
#   do metagenomic analysis. 
#   
#   
#   Script: 	m_samples_cluster.sh
#   Input: 	fasta file (make sure you have the files but it is not necessary to provide any)
#   		group file
#   Output:	OTUs
#		Sequence alignment
#		tree files
#		OTU reps 
#   		Taxonomy of OTUs
#		Sample rarefaction curves
#		Phylodiversity
#		heat maps alpha diversity
#		heat maps beta diversity
#		unifrac statistic test
#
#   Dependency: mothur-1.23.0, bash
#    
#
#   To execute the script on a linux machine $ "m_samples_cluster.sh"
#   To execute the scrip in csf server:$ qsub path/m_samples_cluster.sh
#
#   ping.wang@manchester.ac.uk, FLS, University of Manchester, 18/1/2012
###################################################################################################################################

cat *.trim.shhh.trim.unique.good.filter.groups > merge.groups
cat *.trim.shhh.trim.unique.good.filter.fasta > merge.fasta
cat *.trim.shhh.trim.good.names > merge.names
inf=merge.fasta
fn=`echo $inf | sed "s/.[a-zA-Z0-9]*$//"`

mothur "#summary.seqs(fasta=$fn.fasta)"

mothur "#pre.cluster(fasta=$fn.fasta,name=$fn.names,diffs=3)"
mothur "#chimera.uchime(fasta=$fn.precluster.fasta,reference=$HOME/ref_data/silva.gold.align, chimealns=T, minh=0.3, mindiv=0.5, xn=8.0, dn=1.4, xa=1.0, chunks=4, minchunk=64, idsmoothwindow=32, maxp=2, skipgaps=T, skipgaps2=T, minlen=10, maxlen=10000, ucl=false, queryfract=0.5)"
mothur "#remove.seqs(accnos=$fn.precluster.uchime.accnos,name=$fn.precluster.names)"
mothur "#remove.seqs(accnos=$fn.precluster.uchime.accnos,fasta=$fn.precluster.fasta)"
mothur "#remove.seqs(accnos=$fn.precluster.uchime.accnos,group=$fn.groups)"


mothur "#summary.seqs(fasta=$fn.precluster.pick.fasta)"

mothur "#align.seqs(candidate=$fn.precluster.pick.fasta, template=$HOME/ref_data/silva.bacteria.fasta, search=kmer, ksize=8, align=needleman, match=1, mismatch=-2, gapopen=-1, flip=t, threshold=0.5, processors=$NSLOTS)"
mothur "#filter.seqs(fasta=$fn.precluster.pick.align, trump=., vertical=T, processors=$NSLOTS)"
mothur "#dist.seqs(fasta=$fn.precluster.pick.filter.fasta,calc=onegap,countends=F,cutoff=0.20,output=lt,processors=$NSLOTS)"

mothur "#cluster(phylip=$fn.precluster.pick.filter.phylip.dist,name=$fn.precluster.pick.names,cutoff=0.20,precision=100,hard=t,method=nearest)"

mothur "#make.shared(list=$fn.precluster.pick.filter.phylip.nn.list, group=$fn.pick.groups, label=unique-0.01-0.03-0.10)"
mothur "#remove.seqs(accnos=$fn.precluster.pick.filter.phylip.nn.missing.name,group=$fn.pick.groups)"
mothur "#make.shared(list=$fn.precluster.pick.filter.phylip.nn.list, group=$fn.pick.pick.groups, label=unique-0.01-0.03-0.10)"

mothur "#summary.shared(shared=$fn.precluster.pick.filter.phylip.nn.shared,groups=$fn.precluster.pick.groups,calc=sharedsobs-sharedchao-jest,label=unique-0.01-0.03-0.10)"
mothur "#rarefaction.shared(shared=$fn.precluster.pick.filter.phylip.nn.shared, groups=all)"

mothur "#summary.single(shared=$fn.precluster.pick.filter.phylip.nn.shared,calc=ace-bootstrap-chao,abund=10,label=unique-0.01-0.03-0.05-0.10)"
mothur "#rarefaction.single(shared=$fn.precluster.pick.filter.phylip.nn.shared,calc=bootstrap-chao-sobs-invsimpson,abund=10,iters=1000,label=unique-0.01-0.03-0.10,freq=0.1,processors=$NSLOTS)" #using estimator, such as chao

mothur "#collect.single(shared=$fn.precluster.pick.filter.phylip.nn.shared,calc=bootstrap-chao-sobs-jack, freq=0.1)" #richness

mothur "#heatmap.bin(shared=$fn.precluster.pick.filter.phylip.nn.shared,label=unique-0.01-0.03-0.10)" #alpha diversity

mothur "#tree.shared(shared=$fn.precluster.pick.filter.phylip.nn.shared,calc=thetayc, groups=all)" #prepare tree file at all availabe otu definitions

mothur "#heatmap.sim(shared=$fn.precluster.pick.filter.phylip.nn.shared)" #beta diversity

mothur "#venn(shared=$fn.precluster.pick.filter.phylip.nn.shared,nseqs=T,permute=t,calc=sharedsobs-sharedchao)" shared richness

mothur "#get.oturep(phylip=$fn.precluster.pick.filter.phylip.dist, fasta=$fn.fasta, list=$fn.precluster.pick.filter.phylip.nn.list,label=unique-0.01-0.03-0.05-0.10,name=$fn.names,group=merge.groups)"
mothur "#align.seqs(candidate=$fn.precluster.pick.filter.phylip.nn.0.03.rep.fasta, template=$HOME/ref_data/silva.bacteria.fasta, search=kmer, ksize=8, align=needleman, match=1, mismatch=-2, gapopen=-1, flip=t, threshold=0.5, processors=$NSLOTS)"
mothur "#clearcut(fasta=$fn.precluster.pick.filter.phylip.nn.0.03.rep.align, DNA=t)"

mothur "#phylo.diversity(tree=$fn.precluster.pick.filter.phylip.nn.0.03.rep.tre,group=merge.groups,freq=0.1,rarefy=T)"  #,rarefy=T,, collect=T,name=$fn.precluster.pick.names,rarefy=T

mothur "#classify.seqs(fasta=$fn.precluster.pick.filter.phylip.nn.rep.fasta, template=$HOME/ref_data/silva.bacteria.fasta, taxonomy=$HOME/ref_data/silva.bacteria/silva.bacteria.silva.tax,method=bayesian,cutoff=95,probs=f)"
mothur "#classify.otu(taxonomy=$fn.precluster.pick.filter.phylip.nn.rep.silva.taxonomy, list=$fn.precluster.pick.filter.phylip.nn.list,basis=otu,probs=f)"

mothur "#unifrac.weighted(tree=$fn.precluster.pick.filter.phylip.nn.0.03.rep.tre, group=merge.groups,name=merge.precluster.pick.filter.phylip.nn.0.03.rep.names,random=t,distance=square)"
mothur "#unifrac.unweighted(tree=$fn.precluster.pick.filter.phylip.nn.0.03.rep.tre, group=merge.groups,name=merge.precluster.pick.filter.phylip.nn.0.03.rep.names,random=t,distance=square)"



kill $$


