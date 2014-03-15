[![Build Status](https://travis-ci.org/sellect/delayed_cron.png?branch=develop)](https://travis-ci.org/sellect/delayed_cron)
[![Code Climate](https://codeclimate.com/github/sellect/delayed_cron.png?branch=develop)](https://codeclimate.com/github/sellect/delayed_cron)

# DelayedCron
run cron jobs with sidekiq, delayed_job, or resque

### DEPENDENCIES:
- background process handler: sidekiq, delayed_job, or resque

### INSTALL 

```ruby
gem "delayed_cron", git: "git@github.com:sellect/delayed_cron", tag: "v0.1.0"
```

### USE IN MODEL
```ruby
class Product < ActiveRecord::Base

  ...

  # Define in Model
  # * this is an alternative to the methods array in config
  #
  # OPTIONS: *optional
  # - interval - override default_inteveral from setup
  # - at       - set time of day the cron should be run, timezone and seconds are optional
  cron_job :some_method_to_run_as_cron, interval: 3.days, at: "00:00:00 -0400"

  def some_method_to_run_as_cron
    # this method will be run every 15 minutes
  end

  ...

end
```

### CONFIGURE
```ruby
DelayedCron.setup do |config|

  # default interval to run cron jobs
  config.default_interval = 10.minutes

  # array of methods to run at the above configured interval
  config.cron_jobs = [ "SomeClass.expensive_task", "AnotherClass.other_expensive_task" ]

end
```

### NOTES:

- when using with sidekiq and rails there can be a config/initializer load order issue. Below is a fix to insure sidekiq is loaded first
```ruby
Rails.application.config.after_initialize do  
  DelayedCron.setup do |config|
    ...
  end
end
```
This initializes dealyed cron after all other initializers have loaded.


### TO DO:
- add support for Resque
- add support for DelayedJob
- add test suite, most likely rspec
