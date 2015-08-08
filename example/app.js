var window = Ti.UI.createWindow({
	backgroundColor : 'white'
});

var mod = require("com.au.qr");


var blob = mod.buildQrcode({
	"width" : 50,
	"text" : "What the hell is that!!!!"
});


var imageV = Ti.UI.createImageView({
	image : blob
});

window.add(imageV);

window.open();
