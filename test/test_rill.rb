# encoding: utf-8
require 'test/unit'
require 'rill'

class RillTest < Test::Unit::TestCase

  def setup
    @rill = Rill.new
  end

  def teardown
    @rill = nil
  end

  def test_comment_removal
    code = <<JS
/**
 * @author yicai.cyj@taobao.com
 */
// comment style two
define(function(require, exports) {
    // can you please remove this?
    exports.hello = function() {};
});
JS
    # the comment removal regexp will leave a blank line,
    # NOTE: please do not delete the blank line below.
    code_sans_comments = <<JS

define(function(require, exports) {
    exports.hello = function() {};
});
JS
    result = @rill.sans_comments(code)

    assert_equal code_sans_comments, result
  end

  def test_parse_deps
    code = <<JS
define(function(require, exports) {
    // require('rill');
    exports.hello = function() {
        require('console').log( require('i18n').t('hello, world') );
    };
});
JS
    deps = @rill.parse_deps(code)

    assert_equal %w(console i18n), deps
  end

  def test_parse_deps_from_define
    code = <<JS
define('foo', ['flag', 'ham', 'egg'], function(requre, exports) {
    // you choose to manage dependencies by hand
    require.async(require('flag').raised ? 'ham' : 'egg', function(ham_egg) {
        // ...
    });
});
JS
    deps = @rill.parse_deps_from_define(code)

    assert_equal %w(flag ham egg), deps
  end

  def test_expand_path
    deps = %w{./foo ../bar ../../ham ../../../egg}
    mod = 'road/to/alcanus/maghda'

    deps.map! do |dep|
      @rill.expand_path(dep, mod)
    end
    assert_equal 'road/to/alcanus/foo', deps[0]
    assert_equal 'road/to/bar', deps[1]
    assert_equal 'road/ham', deps[2]
    assert_equal 'egg', deps[3]
  end

  def test_terrylee
    code = <<JS
define(function(require) { return function(jQuery) {
/*
 * Translated default messages for the jQuery validation plugin.
 * Locale: TW (Taiwan - Traditional Chinese)
 */
jQuery.extend(jQuery.validator.messages, {
    required: "不能为空",
    remote: "您输入的有误",
    email: "请输入正确的邮箱地址",
    url: "请输入合法的URL",
    date: "请输入合法的日期",
    dateISO: "请输入合法的日期 (ISO).",
    number: "请输入数字",
    digits: "请输入整数",
    creditcard: "请输入合法的信用卡号码",
    equalTo: "请重复输入密码",
    accept: "请输入有效的后缀",
    maxlength: jQuery.validator.format("长度不能大于 {0}"),
    minlength: jQuery.validator.format("长度不能小于 {0}"),
    rangelength: jQuery.validator.format("请输入长度介于  {0} 和 {1} 之间"),
    range: jQuery.validator.format("请输入  {0} 和 {1} 之间的数字"),
    max: jQuery.validator.format("请输入小于 {0}的数字"),
    min: jQuery.validator.format("请输入大于 {0}的数字")
});
}});
JS
    deps = @rill.parse_deps(code)
    mod = 'jquery/validator/messages'
    result = @rill.polish(mod, code)
    proper_define = "define('#{mod}', [], function(require)"

    assert_equal [], deps
    assert result.start_with?(proper_define)
  end
end