if ENV['COVERAGE_REPORT']
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.coverage_dir 'reports/coverage'
  SimpleCov.start do
    add_filter "/spec/"
    add_filter "/features/"
  end
end
