[![Build Status](https://travis-ci.org/sellect/delayed_cron.png?branch=master)](https://travis-ci.org/sellect/delayed_cron)
[![Code Climate](https://codeclimate.com/github/sellect/delayed_cron.png?branch=master)](https://codeclimate.com/github/sellect/delayed_cron)

# DelayedCron
run cron jobs with sidekiq, delayed_job, resque, or sucker_punch

### DEPENDENCIES:
- background process handler: sidekiq, delayed_job, resque, or sucker_punch

### INSTALL

```ruby
gem "delayed_cron", "~> 0.2.9"
```

### USE IN MODEL
```ruby
class Product < ActiveRecord::Base

  ...

  # Define in Model
  # * this is an alternative to the cron_jobs array in config
  #
  # OPTIONS: *optional
  # - interval  - override default_interval from setup
  # - at        - set time of day the cron should be run, timezone and seconds are optional
  # - time_zone - override default time zone for this job
  # - precision - set to :hourly to run job at an hourly interval instead of daily
  #
  # NOTE: only one of interval or at will be used, at will take precedence if
  # both are specified
  cron_job :some_method_to_run_as_cron, at: "00:00:00 -0400"
  cron_job :some_hourly_job, at: "15:00", precision: :hourly

  def self.some_method_to_run_as_cron
    # this method will be run every every day at midnight
  end

  def self.some_hourly_job
    # this method will be run hourly at fifteen minutes past the hour
  end

  ...

end
```

### CONFIGURE
```ruby
DelayedCron.setup do |config|

  # default interval to run cron jobs
  config.default_interval = 10.minutes

  # default time zone for scheduling `:at` jobs
  # accepts an ActiveSupport or TZInfo time zone name
  config.default_time_zone = "Eastern Time (US & Canada)"


  # array of methods to run at the above configured interval
  config.cron_jobs = [
    "SomeClass.expensive_task", # will run at default interval
    { job: "AnotherClass.other_expensive_task", interval: 1.hour } # override default
  ]

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
