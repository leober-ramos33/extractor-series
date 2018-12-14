const path = require('path');

module.exports = {
	"entry": [ "@babel/polyfill", path.join(__dirname, "src", "app.js") ],
	"output": {
		"path": path.join(__dirname, "dist"),
		"filename": "extractor-pelisplay.tv.js"
	},
	"target": "node",
	"module": {
		"rules": [
			{
				"use": [ "babel-loader" ],
				"test": /\.js$/,
				"exclude": /node_modules/
			}
		]
	}
};
