#!/bin/sh -e
#
# Set up data files for mothur workflows
#
# This script should be run once to download and install the data
# necessary for the mothur workflow scripts
#
# Directories for data
MOTHUR_DATA_DIR=$HOME/mothur
REF_DATA_DIR=$HOME/ref_data
#
# Start
echo SETTING UP DATA FOR MOTHUR WORKFLOWS
echo
echo Data will be installed in the following locations:
echo $MOTHUR_DATA_DIR: mothur look up files
echo $REF_DATA_DIR: reference data files
echo
#
# Check for/make data directories
if [ ! -d $MOTHUR_DATA_DIR ] ; then
    echo Creating $MOTHUR_DATA_DIR for look up files
    mkdir $MOTHUR_DATA_DIR
else
    echo Found $MOTHUR_DATA_DIR
fi
if [ ! -d $REF_DATA_DIR ] ; then
    echo Creating $REF_DATA_DIR for reference data
    mkdir $REF_DATA_DIR
else
    echo Found $REF_DATA_DIR
fi
#
# Download look up files
pushd $MOTHUR_DATA_DIR
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
pushd $REF_DATA_DIR
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
    rmdir silva.bacteria
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