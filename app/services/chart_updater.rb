class ChartUpdater
  def self.update_burndown_chart(sprint, times)
    unless need_to_update_burndown_chart?(sprint, times)
      Rails.logger.error "The burndown chart doesn't need to be updated."
      return false
    end

    image_path = generate_image_and_upload_to_trello(sprint.number)
    unless image_path
      Rails.logger.error 'There was an error and the burndown chart was NOT updated.'
      return false
    end

    Rails.logger.info 'Burndown chart updated!'

    publish_image_to_dashboard(image_path)
    upload_to_github(image_path, sprint.number) if need_to_upload_to_github?(sprint, times)
  end

  def self.need_to_update_burndown_chart?(sprint, times)
    standup_from = times[:before_standup] - times[:interval]
    standup_to = times[:before_standup]

    need_to_upload_to_github?(sprint, times) || sprint.standup_will_start_within?(standup_from, standup_to)
  end

  def self.need_to_upload_to_github?(sprint, times)
    review_from = times[:after_review] + times[:interval]
    review_to = times[:after_review]

    sprint.review_has_finished_within?(review_from, review_to)
  end

  def self.generate_image_and_upload_to_trello(number)
    system "trollolo burndown --plot-to-board --output=trollolo --sprint-number=#{number}"
    image_path = "trollolo/burndown-#{number}.png"

    return nil unless $CHILD_STATUS.success? && File.exist?(image_path)

    image_path
  end
  private_class_method :generate_image_and_upload_to_trello

  def self.publish_image_to_dashboard(image_path)
    system "mv #{image_path} public/burndown.png"
  end
  private_class_method :publish_image_to_dashboard

  def self.upload_to_github(image_path, number)
    data_path = "trollolo/burndown-data-#{number}.yaml"
    correctly_updated = commit_and_push('New Sprint - yaml', data_path)
    correctly_updated &&= commit_and_push('New Sprint - burndown chart', image_path)

    unless correctly_updated
      Rails.logger.error 'There was an error and the burndown chart was NOT uploaded to Github.'
      return false
    end

    Rails.logger.info 'The burndown chart was uploaded to Github 😸'
    File.delete(data_path, 'rb')
    Rails.logger.info 'The local burndown chart data copy was removed.'
  end
  private_class_method :upload_to_github

  def self.commit_and_push(message, file_path)
    commiter = '"committer": {"name": "' + ENV['GITHUB_USER'] + '", "email": "' + ENV['GITHUB_EMAIL'] + '"}, '
    authorization = "Authorization: token #{ENV['GITHUB_TOKEN']}"
    file = File.open(file_path.to_s, 'rb')
    content = Base64.strict_encode64(file.read)
    options = '{"message": "' + message + '", ' + commiter + '"content": "' + content.to_s + '"}'
    filename = file_path.split('/').last

    system "curl -i -X PUT -H '#{authorization}' -d '#{options}' #{ENV['GITHUB_API']}/#{filename}"
  end
  private_class_method :commit_and_push
end
