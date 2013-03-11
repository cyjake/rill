define(function(require, exports) {
    // require('rill');
    exports.hello = function() {
        require('console').log( require('i18n').t('hello, world') );
    };
});