require 'json'

class Rill

  DEFAULT_CONFIG = {
    :base => Dir.pwd,
    :preloads => []
  }.freeze

  def initialize(attrs = nil)
    attrs = DEFAULT_CONFIG.merge(attrs || {})

    @base = attrs[:base]
    @preloads = attrs[:preloads].is_a?(Array) ? attrs[:preloads] : []
  end

  def modules
    @modules
  end

  def resolve(mods)
    @modules = []
    @codes = []

    if mods.is_a?(String)
      mods = [mods]
    end
    mods.each do |mod|
      resolve_module(mod)
    end
  end

  def resolve_module(mod)
    return if @preloads.include?(mod) || @modules.include?(mod)

    mod = parse_module(mod)
    path = File.join(@base, "#{mod}.js")
    code = File.open(path).read.lstrip

    unless code =~ /^define\(\s*(['"])[^'"]+\1/
      code = polish(mod, code)
      fio = File.open(path, 'w')
      fio.write(code)
    end
    @codes.unshift(code)
    @modules.unshift(mod)

    deps = parse_deps_from_define(code)
    deps.each do |dep|
      dep = expand_path(dep, mod)
      resolve_module(dep)
    end
  end

  def append(mod, code)
    @modules << mod
    @codes << polish(mod, code)
  end

  def bundle
    @preloads.each do |file|
      code = File.open(File.join(@base, "#{file}.js")).read
      @codes.unshift(code)
    end
    @codes.join("\n")
  end

  # mark the module id
  # parse and set the module dependencies if not present
  def polish(mod, code = nil)
    mod = parse_module(mod)

    if !code.nil?
      return polish_code(mod, code.lstrip)
    end

    path = File.join(@base, "#{mod}.js")
    code = File.open(path).read.lstrip

    unless code =~ /^define\(\s*(['"])[^'"]+\1/
      code = polish_code(mod, code)
      fio = File.open(path, 'w')
      fio.write(code)
      fio.close
    end

    code
  end

  def polish_code(mod, code)
    mod = parse_module(mod)

    if code =~ /^define\(\s*function/
      deps = parse_deps(code)
      deps -= @preloads
      deps_str = deps.length > 0 ? "['#{deps.join("', '")}']" : '[]'

      code.sub!(/^define\(\s*/, "define('#{mod}', #{deps_str}, ")
    elsif code =~ /^define\(\s*[\[\{]/
      code.sub!(/^define\(\s*/, "define('#{mod}', ")
    end

    code
  end

  def parse_module(mod)
    mod.sub(/^#{@base}\/?/, '').sub(/\.js$/, '')
  end

  def expand_path(dep, mod)
    # 与 File.expand_path 的逻辑还是有些分别的
    base = mod.include?('/') ? mod.slice(0, mod.rindex('/') + 1) : ''
    relativep = dep.start_with?('.')

    while dep.start_with?('.')
      dep = dep.sub(/^\.\//, '')
      if dep.start_with?('../')
        dep = dep.sub('../', '')
        base.sub!(/[^\/]+\/$/, '')
      end
    end

    relativep ? base + dep : dep
  end

  def parse_deps_from_define(code)
    pattern = /^define\(\s*(['"])[^'"]+\1,\s*(\[[^\]]+\])/
    match = pattern.match(code)
    deps = []

    if match
      deps = match[2]
      deps = JSON.parse(deps.gsub("'", '"'))
      deps.delete_if do |d|
        d.nil? || d =~ /^\s*$/
      end
    else
      pattern = /^define\(\s*(['"])[^'"]+\1,\s*(['"])([^\1]+)\1\.split/
      match = pattern.match(code)
      if match
        deps = match[3].split(/,\s*/)
      end
    end

    deps
  end

  def parse_deps(code)
    # Parse these `requires`:
    #   var a = require('a');
    #   someMethod(require('b'));
    #   require('c');
    #   ...
    # Doesn't parse:
    #   someInstance.require(...);
    pattern = /(?:^|[^.])\brequire\s*\(\s*(["'])([^"'\s\)]+)\1\s*\)/
    code = sans_comments(code)
    matches = code.scan(pattern)

    matches.map! do |m|
      m[1]
    end

    matches.uniq.compact
  end

  # http://lifesinger.github.com/lab/2011/remove-comments-safely/
  def sans_comments(code)
    code.gsub(/(?:^|\n|\r)\s*\/\*[\s\S]*?\*\/\s*(?:\r|\n|$)/, "\n").gsub(/(?:^|\n|\r)\s*\/\/.*(?:\r|\n|$)/, "\n")
  end
end