#!/bin/sh

# Create various files from RFC2629-formatted source
# 
# Copyright (c) 2010-2015, Julian Reschke (julian.reschke@greenbytes.de)
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of Julian Reschke nor the names of its contributors
#   may be used to endorse or promote products derived from this software
#   without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

xslt() {
	if type saxon-xslt >/dev/null 2> /dev/null; then
		saxon-xslt $1 $2 basename=$base 
	elif type saxon >/dev/null 2> /dev/null; then
		saxon $1 $2 basename=$base 
	elif type xsltproc >/dev/null 2> /dev/null; then
		xsltproc --stringparam basename $base $2 $1 
	else
		echo $0: needs either "saxon", "saxon-xslt", or "xsltproc" >&2
	fi
	err=$?
	if [ $err -ne 0 ] ; 
	then 
		echo "process returned errorlevel $err" >&2
		exit $err
	fi
}

cleanup() {
	rm -rf $tmpfolder 2>/dev/null
}

usage() {
	echo "Usage: $0 [-pdf|-ps|-epub] xmlsourcefile" >&2
	exit 2
}

errorMsg() {
	echo "$1" >&2
	exit 110
}

prepXslt() {
	cp $1 .
	[ -f $1.res ] && for f in $(cat $1.res); do cp $xmldir/$f .;done
}

# Print help text in case of missing parameters
if [ $# != 1 -a $# != 2 ] ; then
	echo "Error: wrong count of parameters" >&2
	usage
fi

# Check target (if there is none specified take from filename)
if test "$1" = "-epub" 
then 
	target=epub
	shift
elif [ "$1" = "-pdf" ]
then 
	target=pdf
	shift
elif [ "$1" = "-ps" ]
then 
	target=ps
	shift
else	
	target=$0
	target=${target##*mk}
	target=${target%%.sh}
fi

#Check if target valid
if [ "$target" != "epub" -a "$target" != "pdf" -a "$target" != "ps" ]
then
	echo "Error: target type $target is in valid" >&2
	usage
fi	

# check if prerquisite program exists
command -v saxon >/dev/null 2>&1 || command -v saxon-xslt >/dev/null 2>&1 || command -v xsltproc >/dev/null 2>&1 || { echo "Error: program saxon or xsltproc is required but not found ... Aborting." >&2 ; exit 100; }
if [ "$target" = "epub" ]
then
	command -v zip >/dev/null 2>&1 || { echo "Error: program zip is required but not found ... Aborting." >&2 ; exit 100; }
fi	
if [ "$target" = "pdf" -o "$target" = "ps" ]
then
	command -v fop >/dev/null 2>&1 || { echo "Error: program fop is required but not found ... Aborting." >&2 ; exit 100; }
fi	


# check if source file exists
if [ ! -r $1 ] ; then
  echo $0: can\'t read $1
  exit 1
fi

# calculate outfile name
outfile="$(readlink -f $1)"
outfile="$(basename ${outfile%%.xml}.$target)"

# extract xslt dir 
xmldir="$(readlink -f $0)"
xmldir="$(dirname $xmldir)"
xmldir="$xmldir/../lib/"
base="$(basename $outfile .$target)"

# setup trap to cleanup if we die
#trap cleanup 1 2 3 6 15

# create temp dir
tmpfolder=$(mktemp --directory)

# output intention line 
echo "converting $(basename $1) to $(basename $outfile)"

# preprocess fop if target is pdf or ps
if [ "$target" = "pdf" -o  "$target" = "ps" ]
then
	(
		cp $1 $tmpfolder/$base.xml
		cd $tmpfolder
		
		echo "  creating generic FO file"
		prepXslt $xmldir/rfc2629toFO.xslt
		xslt $base.xml rfc2629toFO.xslt >$base.fo || errorMsg "Fatal error while converting XM to FO" || exit $?
		
		echo "  creating FOP compliant file from FO file"
		xslt $base.fo $xmldir/xsl11toFop.xslt >$base.fop || exit 100
	)
fi	

if [ "$target" = "pdf" ]
then
	# create pdf from fop
	echo "  creating pdf file"
	fop $tmpfolder/$base.fop -pdf $outfile
elif [ "$target" = "ps" ]
then
	# create ps from fop
	echo "  creating ps file"
	fop $tmpfolder/$base.fop -ps $outfile
elif [ "$target" = "epub" ]
then
	# creating epub file in temp structure
	echo "  creating epub file"
	srcdir=$(pwd)
	(
	  # change to target dir
	  cd $tmpfolder
	  
	  # create mimetype file 
	  echo "  creating mimetype" 
	  echo -n "application/epub+zip" > mimetype
	  
	  #write dummy meta information
	  echo "  creating container.xpf" 
	  mkdir META-INF
	  echo '<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
	  <rootfiles>
	    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
	  </rootfiles>
	  </container>
	  ' > META-INF/container.xml
	
	  # create and populate content dir
	  cp $srcdir/$1 ./$base.xml
	  echo "  creating content.opf" 
	  mkdir OEBPS
	  prepXslt $xmldir/rfc2629toOpf.xslt
	  xslt $base.xml rfc2629toOpf.xslt > OEBPS/content.opf
	  
	  echo "  creating toc.ncx" 
	  prepXslt $xmldir/rfc2629toNcx.xslt
	  xslt $base.xml rfc2629toNcx.xslt > OEBPS/toc.ncx
	  
	  echo "  creating $base.xhtml" 
	  prepXslt $xmldir/rfc2629toEPXHTML.xslt
	  xslt $base.xml rfc2629toEPXHTML.xslt > OEBPS/$base.xhtml
	  
	  echo "  creating $base-cover.xhtml" 
	  prepXslt $xmldir/rfc2629toEPCover.xslt
	  xslt $base.xml rfc2629toEPCover.xslt > OEBPS/$base-cover.xhtml
	  
	  echo "  creating rfc2629xslt.css" 
	  xslt $base.xml $xmldir/extractInlineCss.xslt > OEBPS/rfc2629xslt.css
	  
	  echo "  copying ressources" 
	  xslt $base.xml $xmldir/extractExtRefs.xslt | while read filename
	  do
	  	    cp $srcdir/$filename OEBPS/
	  done
	  cp $xmldir/IETF_Logo.svg OEBPS/
	  
	  # remove outfile if it exists
	  echo "  creating target file $outfile"
	  [ -r $srcdir/$outfile ] && rm $srcdir/$outfile
	  
	  # create zipped epub file 
	  zip $srcdir/$outfile -X0 mimetype >/dev/null
	  zip $srcdir/$outfile -Xr META-INF OEBPS >/dev/null
	)
fi

# remove temporary file structure
#cleanup
