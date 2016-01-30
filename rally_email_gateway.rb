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
print "Connecting to POP3 email with:\n"
print "\taddress   : <#{$mail_server}>\n"
print "\tport      : <#{$mail_port}>\n"
print "\tuser_name : <#{$mail_username}>\n"
print "\tenable_ssl: <#{$mail_enable_ssl}>\n\n"
pop = Net::POP3.new($mail_server, $mail_port)
pop.enable_ssl
pop.start($mail_username, $mail_password) 


# ------------------------------------------------------------------------------
# Should use something like this (not yet working).
#
            #User string                   #Rally artifact type
actions = [ 'defect'                    => 'defect',
            'story'                     => 'story',
            'userstory'                 => 'story',
            'hierarchicalrequirement'   => 'story',
            'hierarchical_requirement'  => 'story',
            'feature'                   => 'portfolioitem/feature',
            'portfolioitem/feature'     => 'portfolioitem/feature',
]


# ------------------------------------------------------------------------------
# Check for new mail.
#
if pop.mails.empty?
  print "No mail.\n"
else
  print "Will process the '#{pop.n_mails}' emails:\n"
  pop.each_mail do |m| 
    mail = Mail.new(m.pop)
    artifact = ''
    if mail.subject.downcase.start_with?('defect')
      artifact = :defect
      ignore = mail.subject.slice!(0, 7)
    elsif mail.subject.downcase.start_with?('story')
      artifact = :story
      ignore = mail.subject.slice!(0, 6)
    elsif mail.subject.downcase.start_with?('userstory')
      artifact = :story
      ignore = mail.subject.slice!(0, 10)
    elsif mail.subject.downcase.start_with?('hierarchical_requirement')
      artifact = :story
      ignore = mail.subject.slice!(0, 25)
    elsif mail.subject.downcase.start_with?('hierarchicalrequirement')
      artifact = :story
      ignore = mail.subject.slice!(0, 24)
    elsif mail.subject.downcase.start_with?('feature')
      artifact = 'portfolioitem/feature'
      ignore = mail.subject.slice!(0, 8)
    elsif mail.subject.downcase.start_with?('portfolioitem/feature')
      artifact = 'portfolioitem/feature'
      ignore = mail.subject.slice!(0, 22)
    else
      print "Skipping this email subject: #{mail.subject}\n"
    end

    if !artifact.empty?
      print "Creating a Rally '#{artifact.to_s}', Subject: #{mail.subject}\n"
      begin
        new_artifact = rally.create(artifact, :name => mail.subject, :description => mail.html_part.body)
      rescue Exception => ex
        print "ERROR: #{ex}\n"
      end
    end
    print "Deleting the email...\n"
    m.delete
  end
end
pop.finish

#[the end]#
