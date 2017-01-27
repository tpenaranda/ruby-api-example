require 'mail'
require 'sucker_punch'

class UserMailer
  include SuckerPunch::Job

  def perform(email, title)
    Mail.deliver do
      to      email
      from    SUPPORT_EMAIL
      subject title
    end
  end
end