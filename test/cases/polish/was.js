define(function(require, exports) {
    var a = require('./a');

    // require('../theme/blank.css');
    require('../theme/elf.css');
    alert(require('../b').hello());
    alert(require('../b').aloha());
});