##
# Mailer methods can be defined using the simple format:
#
# email :registration_email do |name, user|
#   from 'admin@site.com'
#   to   user.email
#   subject 'Welcome to the site!'
#   locals  :name => name
#   content_type 'text/html'       # optional, defaults to plain/text
#   via     :sendmail              # optional, to smtp if defined, otherwise sendmail
#   render  'registration_email'
# end
#
# You can set the default delivery settings from your app through:
#
#   set :delivery_method, :smtp => {
#     :address         => 'smtp.yourserver.com',
#     :port            => '25',
#     :user_name       => 'user',
#     :password        => 'pass',
#     :authentication  => :plain, # :plain, :login, :cram_md5, no auth by default
#     :domain          => "localhost.localdomain" # the HELO domain provided by the client to the server
#   }
#
# or sendmail (default):
#
#   set :delivery_method, :sendmail
#
# or for tests:
#
#   set :delivery_method, :test
#
# and then all delivered mail will use these settings unless otherwise specified.
#

Reactor2::App.mailer :user_notifier do

  email :confirmation do |user|
    from 'support@improva.com'
    to user.email
    host = PADRINO_ENV == 'production' ? 'ec2-54-245-59-116.us-west-2.compute.amazonaws.com' : 'localhost:3000'
    link = "http://#{host}/api/v1/confirmation/#{user.hashs}"
    subject 'Improva: sign up confirmation'
    locals user: user, link: link
    render 'user_notifier/confirmation_email'
    content_type :html
  end

end
