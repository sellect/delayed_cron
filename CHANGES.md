# 0.2.11

- Use ActiveSupport::Duration to apply time offsets

  Using seconds to apply the time offsets when the parsed time is in the
  past is not time zone aware. This causes issues when DST begins/ends
  between the two times. For example, daily jobs are scheduled an hour
  earlier than the are supposed to when DST ends since it doesn't take the
  extra hour into account. This causes further issues when calculating the
  next offset time, the offset to prevent scheduling past times doesn't
  apply as expected and the job is scheduled over and over. As a related
  issue, we sometimes need a two hour jump to bring the parsed time to the
  future, add a while loop to handle this case.

# 0.2.10

- Add ability to set a job time zone and also allow running a job at a specific minute of each hour.
  - PR https://github.com/sellect/delayed_cron/pull/17

# 0.2.9

- fix scheduling