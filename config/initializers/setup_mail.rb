ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "gmail.com",
  :user_name            => "melodyserra@gmail.com",
  :password             => Rails.application.secrets.my_smtp_password,
  :authentication       => "plain",
  :enable_starttls_auto => true
}