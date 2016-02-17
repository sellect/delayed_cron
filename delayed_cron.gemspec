$:.push File.expand_path("../lib", __FILE__)
require "delayed_cron/version"

Gem::Specification.new do |s|
  s.name        = %q{delayed_cron}
  s.version     = DelayedCron::VERSION

  s.authors     = ["Justin Grubbs"]
  s.summary     = %q{Run your cron jobs with sidekiq, delayed_job, resque, or sucker_punch.}
  s.description = %q{Run your cron jobs with sidekiq, delayed_job, resque, or sucker_punch.}
  s.email       = %q{justin@sellect.com}
  s.homepage    = %q{http://github.com/sellect/delayed_cron}

  s.add_development_dependency "delayed_job"
  s.add_development_dependency "resque"
  s.add_development_dependency "sidekiq"
  s.add_development_dependency "sucker_punch"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rails"
  s.add_development_dependency "timecop"
  s.add_development_dependency "rspec-sidekiq"
  s.add_development_dependency "codeclimate-test-reporter"
  s.add_development_dependency "hashie"
  s.add_development_dependency "debugger"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
end
