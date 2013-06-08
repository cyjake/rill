define('foo', ['flag', 'ham', 'egg'], function(requre, exports) {
  // you choose to manage dependencies by hand
  require.async(require('flag').raised ? 'ham' : 'egg', function(ham_egg) {
      // ...
  })
})