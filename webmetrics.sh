#!/bin/bash

# author Jerry Xia
# McGill ID 260917329

# define function to print the usage.
Usage()
{
    echo "Usage: $0 <logfile>"
}

# check number of input arguments; script expects exactly 1.
if [[ $# != 1 ]]
then
        echo "Error: No log file given."
        Usage
        exit 1
fi

# checks if file exists or is not a file.
if [[ ! -e $1 || ! -f $1 ]]
then
    echo "Error: File '$1' does not exist."
    Usage
    exit 2
fi

DIR=$1

# accounting for absolute and relative paths
if [[ $DIR == /* ]]; then
       Source=$DIR
else
       Source=$(find $HOME -name $DIR | grep $DIR)
fi


# START


# part 1

echo "Number of requests per web browser"

awk '
BEGIN {sfrcount=0}
{ if(/Safari/) { sfrcount++ } }
END { print "Safari,"sfrcount }
' < $Source

awk '
BEGIN {mzlcount=0}
{ if(/Firefox/) { mzlcount++ } }
END { print "Firefox,"mzlcount }
' < $Source

awk '
BEGIN {chrcount=0}
{ if(/Chrome/) { chrcount++ } }
END { print "Chrome,"chrcount }
' < $Source


# part 2

errorcode=2
echo ""
echo "Number of distinct users per day"

# finds unique dates
DateNames=$(cat $Source | awk '{print $4}' | sed -e 's/:.*$//' -e 's/^.//' | sort -u)

# iterates through each unique date found and gets the number of users
for i in $DateNames;
do
	echo -n "$i,"; 
	cat $Source | grep $i | sed -e 's/-.*$//'| sort -u | wc -l; 
done;


# part 3

echo ""
echo "Top 20 popular product requests"

# gets all IDs, sorted by number, with entries that trail without a / after the product ID
cat $Source | awk '/GET \/product\/[0-9]{4,}\// {print $7}' | sed 's/^[^/]*[/]//' | sed -e 's/\<product\>//g' | sed 's/^[^/]*[/]//'| cut -f1 -d"/" | cut -f1 -d"?"| sort -n > allids.txt

# sorts and prints out all ids into a temporary file
uniq -c allids.txt | sort -n > tmp.txt

# prints in order specified
cat tmp.txt | awk '{print $1","$2}' | sort -u -t, -k1,1 | head -n 20 | sort -n | tac | awk 'BEGIN { FS="," } {print $2","$1}'

# removes all files used
rm allids.txt
rm tmp.txt

errorcode=0
exit $errorcode
echo ""
# done
