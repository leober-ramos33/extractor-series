# extractor-series

Extractor-Series is a set of scripts written in Bash to extract download links from TV series of pirated pages.

Just for the record, I did not create this tool to tolerate piracy, but it is inevitable and I know someone will use it for such purposes.
Regardless, the way you use this tool is entirely your responsibility.
Respect and support the creators of the series, along with their cast.

### Requirements:
* cURL
* zip
* pup (Only in SeriesGato and Fanpelis) - (x64 version bundled, you can get other versions from [here](https://github.com/ericchiang/pup/releases))


### Usage:
```
./extractor-<page>.sh <id of serie> <episodes of 1 season> <episodes of 2 season>...<episodes of 15 season>
```

### Examples:
```
./extractor-pelisplus.co.sh mr-robot 10 12 10
./extractor-seriesgato.tv.sh 18-5-mr-robot-289590.html 10 12 10
./extractor-fanpelis.com el-joven-sheldon 22
```

### Supported pages:
| Title | URL | Servers | Note |
|---|---|---|---|
| Pelisplus | http://pelisplus.co | Openload, Streamango ||
| SeriesGato | https://www.seriesgato.tv | Openload, Streamango | It doesn't work with series that contain numbers on their name |
| Fanpelis | http://fanpelis.com | Openload, Rapidvideo ||
