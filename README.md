# extractor-series

Extractor-Series es un script escrito en Bash para extraer los enlaces de las series (TV) de paginas web, como: `http://pelisplus.co`.


Demostración:

[YouTube Video](https://youtu.be/Tg2bG9De2gY)

Requisitos:
* cURL
* zip

Uso: `./extractor-pelisplus.co.sh {serie} {episodios de la primera temporada} {episodios de la 2 temporada}...{episodios de la 8 temporada}`
Ejemplo: `./extractor-pelisplus.co.sh mr-robot 10 12 10`
El nombre de la serie lo extraen del enlace, `http://pelisplus.co/serie/mr-robot`, extraen lo ultimo y quedaria como mr-robot

Paginas soportadas:
* http://pelisplus.co
