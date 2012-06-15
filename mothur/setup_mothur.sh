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
for url in \
    http://www.mothur.org/w/images/9/96/LookUp_Titanium.zip \
    http://www.mothur.org/w/images/8/84/LookUp_GSFLX.zip \
    http://www.mothur.org/w/images/7/7b/LookUp_GS20.zip
do
    filen=`basename $url`
    echo -n Fetching $filen ...
    wget -q $url
    if [ ! -f $filen ] ; then
	echo FAILED
	exit 1
    fi
    unzip -qq $filen
    rm -rf $filen
    echo OK
done
popd
#
# Download reference data
pushd $MOTHUR_REF_DATA
echo
echo Installing reference data files in `pwd`
for url in \
    http://www.mothur.org/w/images/7/72/Greengenes.alignment.zip \
    http://www.mothur.org/w/images/2/21/Greengenes.gold.alignment.zip \
    http://www.mothur.org/w/images/1/16/Greengenes.tax.tgz \
    http://www.mothur.org/w/images/9/98/Silva.bacteria.zip \
    http://www.mothur.org/w/images/3/3c/Silva.archaea.zip \
    http://www.mothur.org/w/images/1/1a/Silva.eukarya.zip \
    http://www.mothur.org/w/images/f/f1/Silva.gold.bacteria.zip
do
    filen=`basename $url`
    ext=${filen##*.}
    echo -n Fetching $filen ...
    wget -q $url
    if [ ! -f $filen ] ; then
	echo FAILED
	exit 1
    fi
    if [ $ext == zip ] ; then
	unzip -qq $filen
    elif [ $ext == tgz ] ; then
	tar xzf $filen
    else
	echo FAILED: unknown extension
    fi
    rm -rf $filen
    echo OK
done
# Move silva.bacteria data out of subdir
if [ -d silva.bacteria ] ; then
    mv silva.bacteria/* .
    rm -rf silva.bacteria
else
    echo WARNING directory silva.bacteria not found
fi
# Remove __MACOSX dir
rm -rf __MACOSX
popd
echo Finished
exit
##
#