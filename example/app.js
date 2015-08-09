var window = Ti.UI.createWindow({
	backgroundColor : 'green'
});

var mod = require("com.au.qr");

var blob = mod.buildQrcode({
	"width" : 100,
	"text" : "I love this game",
	"color" : "#000000"
});

var imageV = Ti.UI.createImageView({
	image : blob
});

window.add(imageV);

window.open();
