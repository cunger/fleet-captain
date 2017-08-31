require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << '.'
  t.libs << 'app'
  t.warning = false
  t.verbose = true
  t.test_files = FileList['test/*_test.rb']
end
desc 'Run tests'
