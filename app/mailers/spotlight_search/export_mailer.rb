module SpotlightSearch
  class ExportMailer < ActionMailer::Base
    default from: "no-reply@#{Rails.application.config.action_mailer.default_url_options[:host]}"

    def send_excel_file(email, file_path, subject)
      attachments[file_path.split('/').last] = File.read(file_path)
      mail(to: email, subject: subject)
    end
  end
end
