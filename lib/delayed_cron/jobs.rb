module DelayedCron
  module Jobs
    autoload :DelayedJob, 'delayed_cron/jobs/delayed_job'
    autoload :Resque,     'delayed_cron/jobs/resque'
    autoload :Sidekiq,    'delayed_cron/jobs/sidekiq'
  end
end
