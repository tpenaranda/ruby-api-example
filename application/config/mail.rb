require 'mail'
require 'premailer'

Mail.defaults do
  mail_uri = URI(MAIL_URL)
  delivery_method :smtp,
                  user_name: mail_uri.user,
                  password: mail_uri.password,
                  address: mail_uri.host,
                  port: mail_uri.port
end

# Mailer integration for Roda mailer plugin
module EmailLogExtension
  attr_accessor :email_log_type, :email_log_emailable, :replyable, :email_log_recipient_id, :metadata

  def deliver
    @metadata ||= {}
    # It defaults to UTF-8 anyway, this will suppress the warning
    self.charset = 'UTF-8' unless charset
    if parts
      parts.each do |x|
        x.charset = 'UTF-8' if x.content_type == 'text/html'
      end
    end

    email_log_type ||= metadata[:email_type]
    email_log = Api::Models::EmailLog.new(
      to: self[:to].to_s,
      cc: self[:cc] ? self[:cc].to_s : nil,
      from: self[:from].to_s,
      subject: self[:subject].to_s,
      type: email_log_type
    )
    if email_log_emailable
      email_log.emailable_type = email_log_emailable.class.to_s
      email_log.emailable_id = email_log_emailable.id
    end
    email_log.recipient_id = email_log_recipient_id if email_log_recipient_id
    email_log.save

    if replyable
      reply_to "reply.#{email_log.id}.#{email_log.emailable_id}.sample@#{REPLY_TO_DOMAIN}"
      # Make sure we don't have any existing references:
      self[:subject] = self[:subject].to_s.gsub(/\s\[ref\-sample\:[^\]]+\]/,'')
      # Add email log reference stamps in case they reply to the main email
      self[:subject] = "#{self[:subject]} [ref-sample:#{email_log.id}.#{email_log.emailable_id}]"
    end
    if html_part
      self.html_part.body = prepare_body(html_part.body.to_s, email_log, replyable)
    else
      self.body = prepare_body(body.to_s, email_log, replyable)
    end
    # Make sure we override all outgoing mail on staging
    to INTERNAL_EMAIL if RACK_ENV == 'staging'

    bcc_emails = bcc.to_a
    bcc_emails << INTERNAL_EMAIL if RACK_ENV == 'production'
    bcc bcc_emails

    # set the header info here
    metadata[:system] = 'sample'
    metadata[:environment] = RACK_ENV

    custom_headers = {}
    custom_headers['category'] = metadata[:email_type] ? "sample:#{metadata[:email_type]}" : 'sample'
    custom_headers['unique_args'] = metadata
    self.header['X-SMTPAPI'] = custom_headers.to_json

    tries = 2
    begin
      result = super
    rescue => e
      (tries -= 1) > 0 ? retry : raise(e.message)
    end

    email_log.reply_to = reply_to
    email_log.save
    result
  end

  def prepare_body(body, email_log, replyable = false)
    # Replace any existing refid tags or blank refid tags
    if replyable && email_log
      body = body.sub(/<refid>([^<]+)?<\/refid>/,"<refid>[ref-sample:#{email_log.id}.#{email_log.emailable_id}]</refid>")
    end
    body.gsub!('src="images/', "src=\"#{SITE_URL}images/")
    Premailer.new(body, with_html_string: true).to_inline_css
  end
end

module Mail
  class Message
    prepend EmailLogExtension
  end
end
