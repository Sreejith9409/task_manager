module CommonUtils
  
  def CommonUtils.get_current_date
    t = Time.zone.now
    Date.new(t.year, t.month, t.day)
  end

  def CommonUtils.alert_user_about_time_lapse(last_hour = false)
    if last_hour
      licence_condition = Task::IS_LAPSED_EMAIL_SENT
      time = Time.zone.now-1.hours
    else
      licence_condition = Task::IS_TIME_NEARING
      time = Time.zone.now-24.hours
    end
    tasks = Task.includes(:assigned_to).where("SUBSTRING(licences, #{licence_condition.to_i + 1}, 1) = '0' and estimated_completion_time is not null and estimated_completion_time >= ? and completed_on is null", time)
    if tasks.present?
      tasks.each do |task|
        task.send_alert_to_user(last_hour)
      end
    end
  end
end