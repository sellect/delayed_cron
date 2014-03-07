# DelayedCron
run cron jobs with sidekiq, delayed_job, or resque

### DEPENDENCIES:
- background process handler: sidekiq, delayed_job, or resque

### INSTALL 

```ruby
gem "delayed_cron"
```

### USE IN MODEL
```ruby
class Product < ActiveRecord::Base

  ...

  # define in model
  # * this is an alternative to the methods array in config
  # - override default_inteveral from setup
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
