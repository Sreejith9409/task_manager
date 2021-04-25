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


  def CommonUtils.get_google_calendar_client current_user
    client = Google::Apis::CalendarV3::CalendarService.new
    return unless (current_user.present? && current_user.access_token.present? && current_user.refresh_token.present?)
    secrets = Google::APIClient::ClientSecrets.new({
      "web" => {
        "access_token" => current_user.access_token,
        "refresh_token" => current_user.refresh_token,
        "client_id" => ENV["GOOGLE_API_KEY"],
        "client_secret" => ENV["GOOGLE_API_SECRET"]
      }
    })
    begin
      client.authorization = secrets.to_authorization
      client.authorization.grant_type = "refresh_token"

      if !current_user.present?
        client.authorization.refresh!
        current_user.update_attributes(
          access_token: client.authorization.access_token,
          refresh_token: client.authorization.refresh_token,
          expires_at: client.authorization.expires_at.to_i
        )
      end
    rescue => e
      flash[:error] = 'Your token has been expired. Please login again with google.'
      redirect_to :back
    end
    client
  end

  
end