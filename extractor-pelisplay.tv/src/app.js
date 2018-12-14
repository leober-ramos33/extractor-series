import cheerio from 'cheerio';
import axios from 'axios';
import ora from 'ora';
import colors from 'colors';

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
		const req = await axios(urlSerie);

		body = req.data;
	} catch (err) {
		spinner.stop();

		if (err.response.status === 404) {
			spinner.stop();
			console.error(`Serie "${id}" not found`.red);
			return;
		} else {
			console.error('Network Error'.red);
		}

		return;
	}

	const $ = await cheerio.load(body);

	spinner.stop();

	const title = $('h1.col-xs-12.col-sm-9.col-md-10').text();
	const timeOfEpisodes = $('div.name.row').next().text().trim().substr(0, 10).trim();
	const description = $('div.sinopsis.m-b-3').text();
	const titleOriginal = $('div.directed:nth-child(1) > span:nth-child(2)').text();
	const trailer = $('div.capa_trailer > iframe').attr('src')
		.replace(/www\.youtube\.com/g, 'youtu.be')
		.replace(/embed\//g, '');

	const seasons = $('div.posterpie > a.abrir_temporada');

	const getDirector = () => {
		const director = $('div.directed:nth-child(2) > span:nth-child(2)').text();

		if (director === 'Desconocido') return '\tDirector: Unknown';

		if (director.split(', ').length > 1) {
			const directors = director.replace(/, /g, ' - ');
			return `\tDirectors: ${directors}`;
		} else {
			return `\tDirector: ${director}`;
		}
	};

	const getCreator = () => {
		const creator = $('div.credits > span:nth-child(2)').text();

		if (creator === 'Desconocido') return '\tCreator: Unknown';

		if (creator.split(', ').length > 1) {
			const creators = creator.replace(/, /g, ' - ');
			return `\tCreators: ${creators}`;
		} else {
			return `\tCreator: ${creator}`;
		}
	};

	const getCategorys = () => {
		let categorysArray = [];
		let categorys = Array.from($('.category').children());
		const categorysTotal = categorys.length;

		for (let i = 0; i < categorys.length; i++) {
			categorysArray.push(categorys[i].children[0].data);
		}

		categorys = categorysArray.toString()
			.replace(/,/g, ' - ');

		if (categorysTotal === 0) return `\tCategorys(0): Unknown`;
		else if (categorysTotal === 1) return `\tCategory(${categorysTotal}): ${categorys}`;
		else return `\tCategorys(${categorysTotal}): ${categorys}`;
	};

	const getYear = () => {
		const year = parseInt($('div.name.row').next().text().trim().substr(10).trim());
		const yearNow = new Date().getFullYear();
		const yearAgo = yearNow - year;

		if (yearNow === year) return `\tYear: ${year}`;

		if (yearAgo > 1) return `\tYear: ${year} (${yearAgo} years ago)`;
		else return `\tYear: ${year} (${yearAgo} year ago)`;
	};

	const getStars = () => {
		const stars = $('div.questions.m-b-3 > div.list-star:nth-child(1) > i.star-active').length;
		let starsIcons = `\tStars(${stars}): `;

		if (stars === 0) starsIcons += 'Unknown';
		else {
			for (let i = 0; i < stars; i++) {
				starsIcons += String.fromCodePoint(11088);
			}
		}

		return starsIcons;
	};

	console.log('Extracting:', title.bold, '...\n');

	console.log('Information:'.bold);
	console.log(getYear());
	console.log('\tTime of the episodes:', timeOfEpisodes);
	console.log('\tDescription:', description);
	console.log(getStars());
	console.log('\tTitle Original:', titleOriginal);
	console.log(getDirector());
	console.log(getCreator());
	console.log(`\tTrailer:`, trailer);
	console.log(getCategorys());
	console.log('\tSeasons Total:', seasons.length, '\n');

	for (let i = 1; i <= seasons.length; i++) {
		const urlSeason = `${urlSerie}/temporada-${i}`;

		const spinner = ora().start();

		let body;

		try {
			const req = await axios(urlSeason);

			body = req.data;
		} catch (err) {
			spinner.stop();
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
				const req = await axios(urlEpisode);

				body = req.data;
			} catch (err) {
				console.error('\t\tNetwork Error'.red);
				continue;
			}
		}
	}
})();
