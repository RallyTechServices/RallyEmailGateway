#!/usr/bin/env ruby

# ------------------------------------------------------------------------------
# Rally login settings.
#
$rally_server    = 'https://rally1.rallydev.com/slm'
$rally_username  = 'username@domain.com'
$rally_password  = 'mypwd'
$rally_version   = 'v2.0'

# ------------------------------------------------------------------------------
# POP3 mail server settings
#
$mail_server     = 'pop.rallyemailgateway.mailinator.com'
$mail_port       = '995'
$mail_username   = 'rallyemailgateway'
$mail_password   = ''
$mail_enable_ssl = true


# ------------------------------------------------------------------------------
# Check that we have access to the required Ruby GEM(s).
#
failed_requires = 0
%w{rubygems net/pop mail rally_api}.each do |this_Require|
  begin
    require this_Require
  rescue LoadError
    print "ERROR: This script requires Ruby GEM: '#{this_Require}'\n"
    failed_requires += 1
  end
end
if failed_requires > 0
  exit -1
end


# ------------------------------------------------------------------------------
# Load (and maybe override with) my personal/private variables from a file.
#
my_vars = './MyVars.rb'
if FileTest.exist?( my_vars )
  print "Sourcing '#{my_vars}'...\n\n"
  require my_vars
else
  print "File #{my_vars} not found; skipping require...\n\n"
end


# ------------------------------------------------------------------------------
# Setup app information and connect to Rally.
#
custom_headers          = RallyAPI::CustomHttpHeader.new()
custom_headers.name     = 'EMail-to-Rally'
custom_headers.version  = '0.2'
custom_headers.vendor   = 'Rally TechServices'

$rally_server << '/slm' if !$rally_server.end_with?('/slm')

print "Connecting to Rally with:\n"
print "\tBaseURL  : <#{$rally_server}>\n"
print "\tUserName : <#{$rally_username}>\n"
print "\tVersion  : <#{$rally_version}>\n\n"

config = {  :base_url   => $rally_server,
            :username   => $rally_username,
            :password   => $rally_password,
            :version    => $rally_version,
            :headers    => custom_headers
}

rally = RallyAPI::RallyRestJson.new(config)


# ------------------------------------------------------------------------------
# Connect to mail server via POP3 
#
if 1 == 2
    $mail_server     = 'sharklasers.com'
    $mail_port       = '995'
    $mail_username   = 'ndkebejt'
    $mail_password   = ''
    # Fails with:
    # /Users/jpkole/.rvm/rubies/ruby-2.2.4/lib/ruby/2.2.0/net/pop.rb:1005:
    #   in `check_response_auth':
    #   -ERR invalid command (Net::POPAuthenticationError)
    # from /Users/jpkole/.rvm/rubies/ruby-2.2.4/lib/ruby/2.2.0/net/pop.rb:904:in `auth'
    # from /Users/jpkole/.rvm/rubies/ruby-2.2.4/lib/ruby/2.2.0/net/pop.rb:566:in `do_start'
    # from /Users/jpkole/.rvm/rubies/ruby-2.2.4/lib/ruby/2.2.0/net/pop.rb:536:in `start'
    # from /Users/jpkole/.rvm/gems/ruby-2.2.4@rally_email_gateway-ruby-2.2.4/gems/mail-2.6.3/lib/mail/network/retriever_methods/pop3.rb:130:in `start'
    # from /Users/jpkole/.rvm/gems/ruby-2.2.4@rally_email_gateway-ruby-2.2.4/gems/mail-2.6.3/lib/mail/network/retriever_methods/pop3.rb:61:in `find'
    # from /Users/jpkole/.rvm/gems/ruby-2.2.4@rally_email_gateway-ruby-2.2.4/gems/mail-2.6.3/lib/mail/network/retriever_methods/base.rb:41:in `all'
    # from /Users/jpkole/.rvm/gems/ruby-2.2.4@rally_email_gateway-ruby-2.2.4/gems/mail-2.6.3/lib/mail/mail.rb:171:in `all'
    # from ./rally_email_gateway.rb:136:in `<main>'
end

if 1 == 2
    $mail_server     = 'pop.rallyemailgateway.mailinator.com'
    $mail_server     = 'pop.mailinator.com'
    $mail_port       = '995'
    $mail_username   = 'rallyemailgateway'
    $mail_password   = ''
    # Fails with:
    # /Users/jpkole/.rvm/rubies/ruby-2.2.4/lib/ruby/2.2.0/net/pop.rb:544:
    #   in `initialize':
    #   Connection refused - connect(2) for "pop.mailinator.com" port 995 (Errno::ECONNREFUSED)
    # from /Users/jpkole/.rvm/rubies/ruby-2.2.4/lib/ruby/2.2.0/net/pop.rb:544:in `open'
    # from /Users/jpkole/.rvm/rubies/ruby-2.2.4/lib/ruby/2.2.0/net/pop.rb:544:in `block in do_start'
    # from /Users/jpkole/.rvm/rubies/ruby-2.2.4/lib/ruby/2.2.0/timeout.rb:88:in `block in timeout'
    # from /Users/jpkole/.rvm/rubies/ruby-2.2.4/lib/ruby/2.2.0/timeout.rb:98:in `call'
    # from /Users/jpkole/.rvm/rubies/ruby-2.2.4/lib/ruby/2.2.0/timeout.rb:98:in `timeout'
    # from /Users/jpkole/.rvm/rubies/ruby-2.2.4/lib/ruby/2.2.0/net/pop.rb:543:in `do_start'
    # from /Users/jpkole/.rvm/rubies/ruby-2.2.4/lib/ruby/2.2.0/net/pop.rb:536:in `start'
    # from /Users/jpkole/.rvm/gems/ruby-2.2.4@rally_email_gateway-ruby-2.2.4/gems/mail-2.6.3/lib/mail/network/retriever_methods/pop3.rb:130:in `start'
    # from /Users/jpkole/.rvm/gems/ruby-2.2.4@rally_email_gateway-ruby-2.2.4/gems/mail-2.6.3/lib/mail/network/retriever_methods/pop3.rb:61:in `find'
    # from /Users/jpkole/.rvm/gems/ruby-2.2.4@rally_email_gateway-ruby-2.2.4/gems/mail-2.6.3/lib/mail/network/retriever_methods/base.rb:41:in `all'
    # from /Users/jpkole/.rvm/gems/ruby-2.2.4@rally_email_gateway-ruby-2.2.4/gems/mail-2.6.3/lib/mail/mail.rb:171:in `all'
    # from ./rally_email_gateway.rb:121:in `<main>'
end

if 1 == 2
    $mail_server     = 'pop.gmail.com'
    $mail_port       = '995'
    $mail_username   = 'jpkole@gmail.com'
    $mail_password   = 'xxxxxxxxxxxx'
    # Fails with:
    # /Users/jpkole/.rvm/rubies/ruby-2.2.4/lib/ruby/2.2.0/net/pop.rb:1005:
    #   in `check_response_auth':
    #   -ERR [AUTH] Web login required: https://support.google.com/mail/answer/78754 (Net::POPAuthenticationError)
    # from /Users/jpkole/.rvm/rubies/ruby-2.2.4/lib/ruby/2.2.0/net/pop.rb:904:in `auth'
    # from /Users/jpkole/.rvm/rubies/ruby-2.2.4/lib/ruby/2.2.0/net/pop.rb:566:in `do_start'
    # from /Users/jpkole/.rvm/rubies/ruby-2.2.4/lib/ruby/2.2.0/net/pop.rb:536:in `start'
    # from /Users/jpkole/.rvm/gems/ruby-2.2.4@rally_email_gateway-ruby-2.2.4/gems/mail-2.6.3/lib/mail/network/retriever_methods/pop3.rb:130:in `start'
    # from /Users/jpkole/.rvm/gems/ruby-2.2.4@rally_email_gateway-ruby-2.2.4/gems/mail-2.6.3/lib/mail/network/retriever_methods/pop3.rb:61:in `find'
    # from /Users/jpkole/.rvm/gems/ruby-2.2.4@rally_email_gateway-ruby-2.2.4/gems/mail-2.6.3/lib/mail/network/retriever_methods/base.rb:41:in `all'
    # from /Users/jpkole/.rvm/gems/ruby-2.2.4@rally_email_gateway-ruby-2.2.4/gems/mail-2.6.3/lib/mail/mail.rb:171:in `all'
    # from ./rally_email_gateway.rb:100:in `<main>'
    # and then sent email to admin:
    #   Someone just tried to sign in to your Google Account jpkole@gmail.com from an app that doesn't meet modern security standards.
    #       Details:
    #       Friday, January 29, 2016 12:44 PM (Mountain Standard Time)
    #       Boulder, CO, USA*
    #   We strongly recommend that you use a secure app, like Gmail, to access your account.
    #   All apps made by Google meet these security standards.
    #   Using a less secure app, on the other hand, could leave your account vulnerable. 
end
if 1 == 1
    $mail_server     = 'pop.zoho.com'
    $mail_port       = '995'
    $mail_username   = 'jpkole'
    $mail_password   = '689tgDR!!'
end

print "Connecting to POP3 email with:\n"
print "\taddress   : <#{$mail_server}>\n"
print "\tport      : <#{$mail_port}>\n"
print "\tuser_name : <#{$mail_username}>\n"
print "\tenable_ssl: <#{$mail_enable_ssl}>\n\n"

pop = Net::POP3.new($mail_server, $mail_port)
pop.enable_ssl
pop.start($mail_username, $mail_password) 

if pop.mails.empty?
  puts 'No mail.'
else
  pop.each_mail do |m| 
    mail = Mail.new(m.pop)
    if mail.subject.downcase.start_with?("defect")
      rally.create(:defect, :name => mail.subject, :description => mail.html_part.body)
    end

    if mail.subject.downcase.start_with?("story") || mail.subject.downcase.start_with?("userstory") ||  mail.subject.downcase.start_with?("hierarchical_requirement")
      rally.create(:story, :name => mail.subject, :description => mail.html_part.body)
    end
    m.delete
  end
end
pop.finish

#[the end]#
