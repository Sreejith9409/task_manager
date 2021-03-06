class UserMailer < ApplicationMailer

  def send_alert_email_to_user(emails, subject, message)
    @recipients = emails
    @subject = subject
    @sent_on = Time.now
    @body = message
    @from = 'sreejith.s@ticketsimply.com'
    mail(:from => @from, :to => @recipients, :subject =>@subject, :date => Time.now)
  end
end
