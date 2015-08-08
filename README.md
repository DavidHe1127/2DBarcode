##2D Barcode generator - wrapper of iOS QR Code Encoder

[![Appcelerator
Titanium](http://www-static.appcelerator.com/badges/titanium-git-badge-sq.png)](http://appcelerator.com/titanium/)

#### Credit: [Jnis](https://github.com/Jnis)

### How to use
##### Reference module
Register your module with your application by editing `tiapp.xml` and adding your module.
Example:
````
<modules>
	<module version="0.1">com.au.qr</module>
</modules>
````

##### Use module in your code
````
var blob = mod.buildQrcode({
	"width" : 50,
	"text" : "What the hell is that!!!!"
});
````

## Version
* 1.0
  * Initial version

## License
MIT

