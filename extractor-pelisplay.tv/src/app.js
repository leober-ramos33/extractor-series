import cheerio from 'cheerio';
import axios from 'axios';
import ora from 'ora';
import colors from 'colors';
import boxen from 'boxen';

console.log(boxen('Extractor\nPelisPlay', {
	"borderStyle": "round",
	"align": "center"
}));

const basename = path => path.split('/').reverse()[0];
const args = process.argv.slice(1);
const cmd = basename(args[0]);

const usage = `Usage: ${cmd} <id of serie>
Example: ${cmd} marvel-s-the-defenders`;

if (args.length < 2) {
	console.error(usage);
	process.exit(1);
} else if (args.length > 2) {
	console.error(usage);
	process.exit(1);
}

const id = args[1];
const urlBase = 'https://www.pelisplay.tv';
const urlSerie = `${urlBase}/serie/${id}`;

(async () => {
	let body;

	const spinner = ora().start();

	try {
		const req = await axios({
			"method": "GET",
			"url": urlSerie
		});

		body = req.data;
	} catch (err) {
		console.error('\nNetwork Error'.red);
		return;
	}

	const $ = await cheerio.load(body);
	spinner.stop();

	const title = $('h1.col-xs-12.col-sm-9.col-md-10').text();
	const timeOfEpisodes = $('div.name.row').next().text().trim().substr(0, 10).trim();
	const year = $('div.name.row').next().text().trim().substr(10).trim();
	const description = $('div.sinopsis.m-b-3').text();
	const stars = $('div.questions.m-b-3 > div.list-star:nth-child(1)').children().length;
	const titleOriginal = $('div.directed:nth-child(1) > span:nth-child(2)').text();
	const trailer = $('div.capa_trailer > iframe').attr("src")
		.replace(/www\.youtube\.com/g, 'youtu.be')
		.replace(/embed\//g, '');
	const seasons = $('div.posterpie > a.abrir_temporada');

	const getDirector = () => {
		const director = $('div.directed:nth-child(2) > span:nth-child(2)').text();

		switch (director) {
		case 'Desconocido':
			return 'Unknown';
		default:
			return director;
		}
	};

	const getCreator = () => {
		const creator = $('div.credits > span:nth-child(2)').text();

		switch (creator) {
		case 'Desconocido':
			return 'Unknown';
		default:
			return creator;
		}
	};

	console.log('\nExtracting:', title.bold, '...\n');

	console.log('Information:'.bold);
	console.log('\tYear:', year);
	console.log('\tTime of episodes:', timeOfEpisodes);
	console.log('\tDescription:', description);
	console.log('\tStars:', stars);
	console.log('\tTitle Original:', titleOriginal);
	console.log('\tDirector:', getDirector());
	console.log('\tCreator:', getCreator());
	console.log('\tTrailer:', trailer);
	console.log('\tSeasons Total:', seasons.length, '\n');

	for (let i = 1; i <= seasons.length; i++) {
		const urlSeason = `${urlSerie}/temporada-${i}`;
		const spinner = ora().start();
		let body;

		try {
			const req = await axios({
				"method": "GET",
				"url": urlSeason
			});

			body = req.data;
		} catch (err) {
			console.error('Network Error'.red);
			continue;
		}

		const $ = await cheerio.load(body);
		spinner.stop();

		const episodes = $('ul.movie-carrusel > li');

		if (episodes.length) console.log(`Season ${i} (1-${episodes.length}):`.bold);
		else console.error(`Season ${i} (0-0): ( ${urlSeason} )`.bold);

		for (let ii = 1; ii <= episodes.length; ii++) {
			const urlEpisode = `${urlSeason}/episodio-${ii}`;

			if (ii < 10) console.log(`\t${i}x0${ii} ( ${urlEpisode} )`);
			else console.log(`\t${i}x${ii} ( ${urlEpisode} )`);

			let body;

			try {
				const req = await axios({
					"method": "GET",
					"url": urlEpisode
				});

				body = req.data;
			} catch (err) {
				console.error('\t\tNetwork Error'.red);
				continue;
			}
		}
	}
})();
