#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
WHITE='\033[4;37m'
CYAN='\033[0;36m'
NOCOLOR='\033[0m'
bold=$(tput bold)
normal=$(tput sgr0)
paths=(
   'project/folder/src/Main.js'
   'project/folder/src/Root.js'
   'project/folder/src/index.html'
   'project/folder/srv/frontend/main.html'
   'project/folder/tests/mainTest.js'
   'project/folder/tests/e2eTest.js'
   'project/folder/tests/rootViewTest.js'
   'project/folder/tests/findUniques.py'
   'project/folder/methods/findUniques.py'
   'project/folder/methods/removeDuplicates.py'
   'project/folder/test/removeDuplicates.py'
)
wget https://www.iltalehti.fi/rss/uutiset.xml -q

xmlgetnext () {
   local IFS='>'
   read -d '<' TAG VALUE
}

cat ./uutiset.xml | while xmlgetnext ; do
   case $TAG in
      'item')
         title=''
         link=''
         pubDate=''
         description=''
         ;;
      'title')
         title="$VALUE"
         ;;
      'link')
         link="$VALUE"
         ;;
      'pubDate')
         # convert pubDate format for <time datetime="">
         datetime=$( date --date "$VALUE" --iso-8601=minutes )
         pubDate=$( date --date "$VALUE" '+%D %H:%M%P' )
         ;;
      'description')
         # convert '&lt;' and '&gt;' to '<' and '>'
         description=$( echo "$VALUE" | sed -e 's/&lt;/</g' -e 's/&gt;/>/g' )
         ;;
      '/item')
         rm1=$(( $RANDOM % 500 + 1))
         rm2=$(( $RANDOM % 500 + 1))
         rp1=$(( $RANDOM % 500 + 1))
         rp2=$(( $RANDOM % 500 + 1))
         rExpr=${paths[ $RANDOM % ${#paths[@]} ]}
         echo "diff --git a/$rExpr b/$rExpr" >> read.txt
         echo "index $(echo $RANDOM | md5sum | head -c 8)..$(echo $RANDOM | md5sum | head -c 8) $(echo $RANDOM | md5sum | head -c 5)" >> read.txt
         echo "\-\-\- a/$rExpr" >> read.txt
         echo "+++ b/$rExpr" >> read.txt
         echo "@@ -$rm1,$rm2 +$rp1,$rp2 @@" >> read.txt
         echo $pubDate >> read.txt
         echo $title >> read.txt
         echo $description >> read.txt
      esac  
done

while read line;
do
   int=$(( $RANDOM % 10 + 1 ))
   read -n 1 k <&1
   if [[ $k = "" ]]; then
      if [[ "$line" == *"@"* ]]; then
         printf "${CYAN}$line"
      elif [[ "$line" == *"diff"* ]] || [[ "$line" == *"index"* ]] || [[ "$line" == *"folder"* ]]; then
         printf "${bold}${WHITE}$line${normal}"
      elif [ $int -gt 3 ] && [ $int -lt 7 ]; then
         printf "${RED}-\t$line"
      elif [ $int -gt 6 ]; then
         printf "${NOCOLOR} $line"
      else
         printf "${GREEN}+\t$line"
      fi
   elif [[ $k = "q" ]]; then
      echo
      break
   fi
done < read.txt

rm ./read.txt
rm ./uutiset.xml