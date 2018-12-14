#!/usr/bin/env node

const cheerio = require('cheerio');
const axios = require('axios');
const ora = require('ora');
const colors = require('colors');
const inquirer = require('inquirer');

const basename = path => path.split('/').reverse()[0];
const args = process.argv.slice(1);
const cmd = basename(args[0]);

const usage = `Usage: ${cmd} <id of serie>
Example: ${cmd} mr-robot`;

if (args.length < 2) {
	console.error(colors.grey(usage));
	process.exit(1);
} else if (args.length > 2) {
	console.log(colors.grey(usage), '\n');
}

const id = args[1];

if (id.indexOf('/') !== -1) {
	console.error(colors.red(`"${id}" is not valid id\n`));
	console.error(colors.grey(usage));
	process.exit(1);
}

const urlBase = 'https://www.pelisplay.tv';
const urlProcesarPlayer = `${urlBase}/entradas/procesar_player`;
const urlSerie = `${urlBase}/serie/${id}`;

(async () => {
	let body;

	const spinner = ora(`Loading serie "${id}"`).start();

	try {
		const req = await axios(urlSerie);

		body = req.data;
	} catch (err) {
		spinner.stop();

		if (err.response.status === 404) {
			spinner.stop();
			console.error(colors.red(`Serie "${id}" not found`));
			return;
		} else {
			spinner.stop();
			console.error(colors.red('Network Error'));
		}

		return;
	}

	const $ = await cheerio.load(body);

	spinner.stop();

	const titleWithYear = $('h1.col-xs-12.col-sm-9.col-md-10').text();
	const title = $('h1.col-xs-12.col-sm-9.col-md-10').text().replace(/\(\d+\)/g, '').trim();
	const titleOriginal = $('div.directed:nth-child(1) > span:nth-child(2)').text();
	const description = $('div.sinopsis.m-b-3').text();
	const director = $('div.directed:nth-child(2) > span:nth-child(2)').text();
	const creator = $('div.credits > span:nth-child(2)').text();
	const stars = $('div.questions.m-b-3 > div.list-star:nth-child(1) > i.star-active').length;
	let categorys = Array.from($('.category').children());
	const trailer = $('div.capa_trailer > iframe').attr('src')
		.replace(/www\.youtube\.com/g, 'youtu.be')
		.replace(/embed\//g, '');

	const seasons = $('div.posterpie > a.abrir_temporada');

	const getDirector = () => {
		if (director.split(', ').length > 1) {
			const directors = director.replace(/, /g, ' - ');
			return `Directors: ${directors}`;
		} else {
			return `Director: ${director}`;
		}
	};

	const getCreator = () => {
		if (creator.split(', ').length > 1) {
			const creators = creator.replace(/, /g, ' - ');
			return `Creators: ${creators}`;
		} else {
			return `Creator: ${creator}`;
		}
	};

	const getCategorys = () => {
		let categorysArray = [];
		const categorysTotal = categorys.length;

		for (let i = 0; i < categorys.length; i++) {
			categorysArray.push(categorys[i].children[0].data);
		}

		categorys = categorysArray.toString()
			.replace(/,/g, ' - ');

		if (categorysTotal === 1) return `Category(${categorysTotal}): ${categorys}`;
		else return `Categorys(${categorysTotal}): ${categorys}`;
	};

	const getYear = () => {
		const year = parseInt($('div.name.row').next().text().trim().substr(10).trim());
		const yearNow = new Date().getFullYear();
		const yearAgo = yearNow - year;

		if (yearNow === year) return `Year: ${year}`;

		if (yearAgo > 1) return `Year: ${year} (${yearAgo} years ago)`;
		else return `Year: ${year} (${yearAgo} year ago)`;
	};

	const getStars = () => {
		let starsIcons;
		const starIcon = String.fromCodePoint(11088);

		if (stars === 0) starsIcons = `Stars(${stars}): Unknown`;
		else if (stars === 1) starsIcons = `Star(${stars}): ${starIcon}`;
		else {
			starsIcons = `Stars(${stars}): `;
			for (let i = 0; i < stars; i++) {
				starsIcons += starIcon;
			}
		}

		return starsIcons;
	};

	const getTime = () => {
		const hours = $('div.name.row').next().text().trim().substr(0, 10).trim()
			.replace(/h.*/g, ' hours');
		const minutes = $('div.name.row').next().text().trim().substr(0, 10).trim()
			.replace(/.*h /g, '')
			.replace(/min/g, ' minutes');
		let timeString = `Time of the episodes: `;

		if (hours === '0 hours') timeString += minutes;
		else timeString += `${hours} ${minutes}`;

		return timeString;
	};

	console.log('Extracting:', colors.bold(titleWithYear), '...\n');

	console.log(colors.bold('Information:'));
	console.log('Title:', title);
	console.log(getYear());
	console.log(getTime());
	console.log('Description:', description);
	if (stars !== 0) console.log(getStars());
	if (title !== titleOriginal) console.log(`Title Original: ${titleOriginal}`);
	if (director !== 'Desconocido') console.log(getDirector());
	if (creator !== 'Desconocido') console.log(getCreator());
	console.log(`Trailer:`, trailer);
	if (categorys.length !== 0) console.log(getCategorys());
	console.log('Seasons:', seasons.length, '\n');

	for (let i = 1; i <= seasons.length; i++) {
		const urlSeason = `${urlSerie}/temporada-${i}`;

		const spinner = ora(`Loading season "${i}"`).start();

		let body;

		try {
			const req = await axios(urlSeason);

			body = req.data;
		} catch (err) {
			spinner.stop();
			console.error(colors.red('Network Error'));
			continue;
		}

		const $ = await cheerio.load(body);

		spinner.stop();

		const episodes = $('ul.movie-carrusel > li');

		if (episodes.length) console.log(colors.bold(`Season ${i} (1-${episodes.length}):`));
		else console.error(colors.bold(`Season ${i} (0-${episodes.length}):`));

		for (let ii = 1; ii <= episodes.length; ii++) {
			const urlEpisode = `${urlSeason}/episodio-${ii}`;
			let spinner;

			if (ii < 10) {
				console.log(`${i}x0${ii}:`);
				spinner = ora(`Loading ${i}x0${ii}`).start();
			} else {
				console.log(`${i}x${ii}:`);
				spinner = ora(`Loading ${i}x${ii}`).start();
			}

			let body;

			try {
				const req = await axios(urlEpisode);

				body = req.data;
			} catch (err) {
				spinner.stop();
				console.error(colors.red('Network Error'));
				continue;
			}

			const $ = cheerio.load(body);
			spinner.stop();

			const titleEpisode = $('h1.col-xs-12.col-sm-9.col-md-10').text().replace(/\(\d+\)/g, '').trim();
			const director = $('div.directed > span:nth-child(2)').text();
			const screenWriter = $('div.credits > span:nth-child(2)').text();

			const getDirector = () => {
				if (director.split(', ').length > 1) {
					const directors = director.replace(/, /g, ' - ');
					return `Directors: ${directors}`;
				} else {
					return `Director: ${director}`;
				}
			};

			const getScreenWriter = () => {
				if (screenWriter.split(', ').length > 1) {
					const screenWriters = screenWriter.replace(/, /g, ' - ');
					return `Screen Writers: ${screenWriters}`;
				} else {
					return `Screen Writer: ${screenWriter}`;
				}
			};

			console.log('Title:', titleEpisode);
			if (director !== 'Desconocido') console.log(getDirector());
			if (screenWriter !== 'Desconocido') console.log(getScreenWriter());
			console.log('');

			/* const episodeOptions = $('tr[data-lang="Latino"]');

			if (episodeOptions.length === 0) {
				console.error(colors.red('NOK!'));
				continue;
			}

			let choices = [];
			let tokens = [ $('#lista_online').data('token') ];

			for (let f = 0, g = 1; f < episodeOptions.length; f++) {
				const episodeOptionName = $(episodeOptions[f].children[3]).text();
				const tokenPlayer = $(episodeOptions[f].children[3].children[0]).attr('data-player');

				tokens.push({
					"player": tokenPlayer
				});

				choices.push(`${g}. ${episodeOptionName}`);

				g++;
			}

			const answer = await inquirer.prompt([{
				"type": "list",
				"name": "serverSelected",
				"message": "Select a server",
				"choices": choices
			}]);

			const serverSelected = parseInt(answer.serverSelected.charAt(0));
			const tokenPlayer = tokens[serverSelected].player;
			const token = tokens[0];

			console.log(tokenPlayer, '\n', token);

			try {
				const req = await axios({
					"method": "POST",
					"url": urlProcesarPlayer,
					"data": {
						"data": tokenPlayer,
						"tipo": "videohost",
						"_token": token
					}
				});

				body = req.data;
			} catch (err) {
				console.log(err.response.status);

				console.error(colors.red('Network Error'));
				continue;
			} */
		}
	}
})();
