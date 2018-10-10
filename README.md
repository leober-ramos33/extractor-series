# extractor-series

Extractor-Series es un conjunto de scripts escritos en Bash para extraer enlaces de descarga de series de TV de paginas piratas.

Solo para que conste, no creé esta herramienta para tolerar la piratería, pero es inevitable y sé que alguien la usará para tales fines.
Independientemente, la forma en que utilice esta herramienta es totalmente su responsabilidad.
Respete y apoye a los creadores de las series, junto a su elenco.

### Requisitos:
* cURL
* zip
* pup (Solamente en www.seriesgato.tv)

Uso: `./extractor-<pagina>.sh <id de la serie> <episodios de la primera temporada> <episodios de la 2 temporada>...<episodios de la 15 temporada>`

Ejemplo: `./extractor-pelisplus.co.sh mr-robot 10 12 10`

Paginas soportadas:
* http://pelisplus.co - Openload.co, Streamango
* https://www.seriesgato.tv - Openload.co, Stremango
