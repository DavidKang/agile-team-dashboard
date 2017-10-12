class Sprint < ApplicationRecord
  has_many :meetings, dependent: :destroy

  scope :finished, (-> { where('DATE(end_date) < ?', Time.zone.today).order(start_date: :asc) })

  validates :number, :start_date, :end_date, presence: true
  validate :starts_on_weekday, :ends_on_weekday, :ends_before_start, :sprint_collision

  after_create :create_meetings

  def self.current
    find_by('start_date <= :today AND end_date >= :today', today: Time.zone.today)
  end

  def unstarted_sprint?
    start_date.today? && !File.exist?("trollolo/burndown-data-#{number}.yaml")
  end

  def days
    1 + (end_date - start_date).to_i - (2 * number_weekends)
  end

  def weekend_lines
    first_line = 6.5 - start_date.cwday
    (0..(number_weekends - 1)).map { |i| first_line + (i * 5) }.join(' ')
  end

  private

  def starts_on_weekday
    return unless start_date
    errors[:start_date] << 'can not be on weekend' if start_date.try(:on_weekend?)
  end

  def ends_on_weekday
    return unless start_date && end_date
    errors[:end_date] << 'can not be on weekend' if end_date.try(:on_weekend?)
  end

  def ends_before_start
    return unless start_date && end_date
    errors[:end_date] << 'can not end before start' if start_date > end_date
  end

  def sprint_collision
    return unless Sprint.current
    if start_date && (Sprint.current.start_date..Sprint.current.end_date).cover?(start_date)
      errors[:start_date] << 'cannot start in current sprint days'
    end

    return unless end_date && (Sprint.current.start_date..Sprint.current.end_date).cover?(end_date)
    errors[:end_date] << 'cannot end in current sprint days'
  end

  def create_meetings
    CreateMeetings.run(self)
  end

  def number_weekends
    end_date.cweek - start_date.cweek
  end
end

# == Schema Information
#
# Table name: sprints
#
#  id         :integer          not null, primary key
#  start_date :date
#  end_date   :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
