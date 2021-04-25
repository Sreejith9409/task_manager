class Task < ApplicationRecord
  belongs_to :project

  validates :status, inclusion: {in: ['backlog', 'in-progress', 'done']}

  STATUS_OPTIONS = [['Backlog', 'backlog'], ['In-Progress', 'in-progress'], ['Done', 'done']]

  before_create :update_created_date
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by", :optional => true
  belongs_to :assigned_to, :class_name => "User", :foreign_key => "assigned_to", :optional => true
  before_update :update_estimation_time
  after_commit :send_google_notification

  IS_LAPSED_EMAIL_SENT = 0
  IS_TIME_NEARING = 1
  REMINDER_NOTIFICATION_SENT = 3

  def update_created_date
    self.created_date = CommonUtils.get_current_date
  end

  def color_class
    case status
    when 'backlog'
      'secondary'
    when 'in-progress'
      'info'
    when 'done'
      'success'
    end
  end

  def complete?
    status == 'done'
  end

  def in_progress?
    status == 'in-progress'
  end

  def backlog?
    status == 'backlog'
  end

  def readable_status
    case status
    when 'not-started'
      'Not started'
    when 'in-progress'
      'In progress'
    when 'complete'
      'Complete'
    end
  end

  def update_estimation_time
    self.assigned_on = Time.now if self.assigned_to_changed?
    if self.estimation_points.present? && self.status_changed? 
      self.estimated_completion_time = Time.zone.now + self.estimation_points.hours if self.status == 'in-progress'
      self.completed_on = Time.zone.now if self.status == 'complete'
    end
  end

  def update_license(index, value)
    licences_dup = self.licences.dup
    licences_dup[index.to_i, 1] = value
    self.licences = licences_dup
  end

  def send_alert_to_user(is_time_lapsed = false)
    email = self.assigned_to.email
    if is_time_lapsed
      message = "Your time to complete #{self.name} is going to complete in 1hr. Please push the code ASAP"
      self.update_license(IS_LAPSED_EMAIL_SENT, '1')
    else
      message = "Your time to complete #{self.name} is going to complete in 24hrs. Please push the code ASAP"
      self.update_license(IS_TIME_NEARING, '1')
    end
    UserMailer.send_alert_email_to_user(self.assigned_to.email, 'Notification email about Time Remaining', message).deliver!
    self.save
  end

  def send_google_notification
    begin
      if self.estimated_completion_time.present? && !self.is_enabled?(REMINDER_NOTIFICATION_SENT)
        client = CommonUtils.get_google_calendar_client(self.created_by)
        event = self.get_event
        client.insert_event('primary', event)
        self.update_license(REMINDER_NOTIFICATION_SENT, '1')
        self.save
      end
    rescue Exception => e
      puts e.backtrace
    end
  end

  def is_enabled?(index)
    self.licences[index.to_i, 1].to_i == 1
  end
  
  def get_event
    attendees = [self.assigned_to.email]
    event = Google::Apis::CalendarV3::Event.new({
      summary: self.name,
      description: self.description,
      start: {
        date_time: self.estimated_completion_time - 1.hour,
        time_zone: "Asia/Kolkata"
      },
      end: {
        date_time: self.estimated_completion_time,
        time_zone: "Asia/Kolkata"
      },
      attendees: attendees,
      reminders: {
        use_default: false,
        overrides: [
          Google::Apis::CalendarV3::EventReminder.new(reminder_method:"popup", minutes: 10),
          Google::Apis::CalendarV3::EventReminder.new(reminder_method:"email", minutes: 20)
        ]
      },
      notification_settings: {
        notifications: [
          {type: 'event_creation', method: 'email'},
          {type: 'event_change', method: 'email'},
          {type: 'event_cancellation', method: 'email'},
          {type: 'event_response', method: 'email'}
        ]
      }, 'primary': true
    })
  end
end
