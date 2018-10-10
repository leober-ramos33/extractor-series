# extractor-series

Extractor-Series is a set of scripts written in Bash to extract download links from TV series of pirated pages.

Just for the record, I did not create this tool to tolerate piracy, but it is inevitable and I know someone will use it for such purposes.
Regardless, the way you use this tool is entirely your responsibility.
Respect and support the creators of the series, along with their cast.

### Requirements:
* cURL
* zip
* pup (Only in www.seriesgato.tv) - (It comes with the folder of the script. It is of architecture amd64, if you want the one of i386 or any other architecture you can find it [here](https://github.com/ericchiang/pup/releases))

Usage: `./extractor-<page>.sh <id of serie> <episodes of 1 season> <episodes of 2 season>...<episodes of 15 season>`
  
Example: `./extractor-seriesgato.tv.sh 18-5-mr-robot-289590.html 10 12 10`

### Supported pages:
* http://pelisplus.co - Openload.co, Streamango
* https://www.seriesgato.tv - Openload.co, Stremango
