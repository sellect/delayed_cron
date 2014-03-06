# DelayedCron
run cron jobs with sidekiq, delayed_job, or resque

### DEPENDENCIES:
- background process handler: sidekiq, delayed_job, or resque

### USE IN MODEL
```ruby
class Product < ActiveRecord::Base

  ...

  # define in model
  # * this is an alternative to the methods array in config
  # - override inteveral from setup
  cron_job :some_method_to_run_as_cron, interval: 15.minutes

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
  config.interval = 15.minutes

  # array of methods to run at the above configured interval
  # config.methods = [ SomeModel.some_interval_method, AnotherModel.another_interval_method ]

end
```
