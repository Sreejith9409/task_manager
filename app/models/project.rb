class Project < ApplicationRecord
  has_many :tasks
  belongs_to :user
  before_create :update_created_date
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by", :optional => true

  def update_created_date
    self.created_date = CommonUtils.get_current_date
  end

  def badge_color
    case status
    when 'backlog'
      'secondary'
    when 'in-progress'
      'info'
    when 'done'
      'success'
    end
  end

  def status
    return 'Not Started' if tasks.none?
    if tasks.all? {|task| task.complete?}
      'Done'
    elsif tasks.any? {|task| task.in_progress? || task.complete?}
      'In Progress'
    else
      'Not Started'
    end
  end

  def percent_complete
    return 0 if tasks.none?
    ((total_complete.to_f/ total_tasks.to_f) * 100).round
  end

  def total_complete
    tasks.select {|task| task.complete?}.count
  end

  def total_tasks
    tasks.count
  end
end
