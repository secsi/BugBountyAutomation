while getopts o:d: flag
do
    case "${flag}" in
        o) filePath=${OPTARG};;
        d) rootDomain=${OPTARG};;
    esac
done

tempPath="/tmp/wakkwakkawkkaw"

mkdir $tempPath
mkdir $filePath
mkdir $filePath/headers

python3 ~/gits/Sublist3r/sublist3r.py -n -o $filePath/subdomains.txt -d $rootDomain

while read domain; do
  curl -s --insecure --max-time 3.0 -i "https://$domain" > $tempPath/temp

  if [ -s $tempPath/temp ]
  then
    # File has contents
    echo "[+] $domain - is good"
    echo $domain>>$filePath/active_webpages.txt
    cp $tempPath/temp $filePath/headers/$domain-Header.txt
  else
    # curl found nothing... try http
    curl -s --insecure --max-time 3.0 -i "http://$domain" > $tempPath/temp
    if [ -s $tempPath/temp ]
    then
      echo "[+] $domain - is good (HTTP only)"
      echo $domain>>$filePath/active_webpages_http_only.txt
      cp $tempPath/temp $filePath/headers/$domain-Header.txt
    else
      # no web service attached to this domain (at least not on 80 or 443)
      echo $domain>>inactive_domains.txt
    fi
  fi
done <$filePath/subdomains.txt

rm -rf $tempPath
