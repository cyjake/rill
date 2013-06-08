# encoding: utf-8
require 'test/unit'
require 'rill'

class RillTest < Test::Unit::TestCase

  def setup
    @rill = Rill.new(:base => '/Users/nil/Projects/webapp/creative-center/public',
                     :preloads => %w{ent})

    dir = File.join(Dir.pwd, 'test/cases', self.__name__.sub(/^test_/, ''))
    fpath_was = "#{dir}/was.js"
    fpath_expected = "#{dir}/expected.js"

    @code_was = File.open(fpath_was).read if File.exist? fpath_was
    @code_expected = File.open(fpath_expected).read if File.exist? fpath_expected
  end

  def teardown
    @rill = nil
  end

  def test_comment_removal
    assert_equal @code_expected, @rill.sans_comments(@code_was)
  end

  def test_parse_deps
    assert_equal %w(console i18n), @rill.parse_deps(@code_was)
  end

  def test_parse_deps_from_define
    deps = @rill.parse_deps_from_define(@code_was)

    assert_equal %w(flag ham egg), deps
  end

  def test_parse_deps_from_uglified_define
    deps = @rill.parse_deps_from_define(@code_was)

    assert_equal(['./bar', '../ham', 'cc/egg'], deps)
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
    deps = @rill.parse_deps(@code_was)
    mod = 'jquery/validator/messages'
    result = @rill.polish(mod, @code_was)
    proper_define = "define('#{mod}', [], function(require)"

    assert_equal [], deps
    assert result.start_with?(proper_define)
  end

  def test_resolve
    mods = %w{cc/show cc/templets/tbu/tw2/200x250 cc/renderer/tbcc cc/vender/tbu/hook cc/datasource/normal}
    @rill.resolve(mods)
    modules = @rill.modules

    assert modules.index('ent').nil?
    assert modules.include?('cc/mustache')
  end

  def test_polish
    assert_equal ['./a', '../theme/elf.css', '../b'],
                 @rill.parse_deps(@code_was)

    assert_equal @code_expected,
                 @rill.polish('cc/foo/bar', @code_was)
  end


  def test_polish_object
    assert_equal [], @rill.parse_deps(@code_was)
    assert_equal @code_expected, @rill.polish('cc/templets/4338', @code_was)
  end

  def test_polish_uglified_object
    assert_equal [], @rill.parse_deps(@code_was)
    assert_equal @code_expected, @rill.polish('cc/templets/4338', @code_was)
  end

  def test_polish_malformed_define
    assert_equal @code_expected,
                 @rill.polish('cc/foo/mal', @code_was)
  end
end