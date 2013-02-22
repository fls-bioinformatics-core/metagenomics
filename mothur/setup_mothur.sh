#!/bin/sh -e
#
# Set up data files for mothur workflows
#
# This script should be run once to download and install the data
# necessary for the mothur workflow scripts
#
# Lookup files will be placed in the directory $MOTHUR_LOOKUP
# (defaults to $HOME/mothur)
#
# Reference alignment files will be placed in directory
# $MOTHUR_REF_DATA (defaults to $HOME/ref_data)
#
# Set the MOTHUR_LOOKUP and MOTHUR_REF_DATA variables in your
# environment to over ride the default locations, e.g.
#
# % export MOTHUR_LOOKUP=$HOME/mothur/lookup
# % export MOTHUR_REF_DATA=$HOME/mothur/ref_alignments
#
# Directories for data
: ${MOTHUR_LOOKUP:=$HOME/mothur}
: ${MOTHUR_REF_DATA:=$HOME/ref_data}
#
# Define function to fetch and unpack data files
# Usage: fetch_data URL
function fetch_data() {
    local url=$1
    local filen=`basename $url`
    local ext=${filen##*.}
    echo -n Fetching $filen ...
    wget -q $url
    if [ ! -f $filen ] ; then
	echo FAILED
	exit 1
    fi
    remove_file=yes
    if [ $ext == zip ] ; then
	unzip -qq $filen
    elif [ $ext == tgz ] ; then
	tar xzf $filen
    elif [ $ext == filter ] ; then
	remove_file=
    else
	echo FAILED: unknown extension $ext
    fi
    if [ -f $filen ] ; then
	echo OK
	if [ ! -z "$remove_file" ] ; then
	    rm -rf $filen
	fi
    fi
}
#
# Start
echo SETTING UP DATA FOR MOTHUR WORKFLOWS
echo
echo Data will be installed in the following locations:
echo $MOTHUR_LOOKUP: mothur lookup files
echo $MOTHUR_REF_DATA: reference alignment data files
echo
#
# Check for/make data directories
if [ ! -d $MOTHUR_LOOKUP ] ; then
    echo Creating $MOTHUR_LOOKUP for lookup files
    mkdir -p $MOTHUR_LOOKUP
else
    echo Found $MOTHUR_LOOKUP
fi
if [ ! -d $MOTHUR_REF_DATA ] ; then
    echo Creating $MOTHUR_REF_DATA for reference alignment data
    mkdir -p $MOTHUR_REF_DATA
else
    echo Found $MOTHUR_REF_DATA
fi
#
# Download look up files
pushd $MOTHUR_LOOKUP
echo
echo Installing lookup files in `pwd`
echo
echo Lookup files for shhh.flows: http://www.mothur.org/wiki/Lookup_files
for url in \
    http://www.mothur.org/w/images/9/96/LookUp_Titanium.zip \
    http://www.mothur.org/w/images/8/84/LookUp_GSFLX.zip \
    http://www.mothur.org/w/images/7/7b/LookUp_GS20.zip
do
    fetch_data $url
done
popd
#
# Download reference data
pushd $MOTHUR_REF_DATA
echo
echo Installing reference data files in `pwd`
echo
# RDP Reference files
echo RDP reference files: http://www.mothur.org/wiki/RDP_reference_files
for url in \
    http://www.mothur.org/w/images/2/29/Trainset7_112011.rdp.zip \
    http://www.mothur.org/w/images/4/4a/Trainset7_112011.pds.zip \
    http://www.mothur.org/w/images/3/36/FungiLSU_train_v7.zip
do
    fetch_data $url
done
echo
# Silva data
echo Silva reference files: http://www.mothur.org/wiki/Silva_reference_files
for url in \
    http://www.mothur.org/w/images/9/98/Silva.bacteria.zip \
    http://www.mothur.org/w/images/3/3c/Silva.archaea.zip \
    http://www.mothur.org/w/images/1/1a/Silva.eukarya.zip \
    http://www.mothur.org/w/images/f/f1/Silva.gold.bacteria.zip
do
    fetch_data $url
done
echo
# Greengenes data
echo Greengene-formatted databases: http://www.mothur.org/wiki/Greengenes-formatted_databases
for url in \
    http://www.mothur.org/w/images/7/72/Greengenes.alignment.zip \
    http://www.mothur.org/w/images/2/21/Greengenes.gold.alignment.zip \
    http://www.mothur.org/w/images/1/16/Greengenes.tax.tgz
do
    fetch_data $url
done
echo
# Secondary structure maps
echo Secondary structure maps: http://www.mothur.org/wiki/Secondary_structure_map
for url in \
    http://www.mothur.org/w/images/6/6d/Silva_ss_map.zip \
    http://www.mothur.org/w/images/4/4b/Gg_ss_map.zip
do
    fetch_data $url
done
echo
# Lane masks
echo Lane masks: http://www.mothur.org/wiki/Lane_mask
for url in \
    http://www.mothur.org/w/images/2/2a/Lane1241.gg.filter \
    http://www.mothur.org/w/images/a/a0/Lane1287.gg.filter \
    http://www.mothur.org/w/images/3/3d/Lane1349.gg.filter \
    http://www.mothur.org/w/images/6/6d/Lane1349.silva.filter
do
    fetch_data $url
done
#
# Clean up: remove __MACOSX dir
rm -rf __MACOSX
popd
echo Finished
exit
##
#