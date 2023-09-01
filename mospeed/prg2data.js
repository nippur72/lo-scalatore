const fs = require('fs');

let file = fs.readFileSync("raster.prg");

let arr = Array.from(file).slice(2);

let s = "data "+arr.join(",");
console.log(s);
console.log(arr.length);