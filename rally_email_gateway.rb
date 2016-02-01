#!/usr/bin/env ruby

# ------------------------------------------------------------------------------
# CA Agile Central login settings.
#
$caac_server    = 'https://rally1.rallydev.com/slm'
$caac_username  = 'username@domain.com'
$caac_password  = 'mypwd'
$caac_version   = 'v2.0'

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
# Setup app information and connect to CA Agile Central.
#
@caac = nil
def connect_to_rally()
  custom_headers          = RallyAPI::CustomHttpHeader.new()
  custom_headers.name     = 'EMail-to-CA-Agile-Central'
  custom_headers.version  = '0.2'
  custom_headers.vendor   = 'CA Agile Central TechServices'

  $caac_server << '/slm' if !$caac_server.end_with?('/slm')

  print "Connecting to CA Agile Central with:\n"
  print "\tBaseURL  : <#{$caac_server}>\n"
  print "\tUserName : <#{$caac_username}>\n"
  print "\tVersion  : <#{$caac_version}>\n\n"

  config = {  :base_url   => $caac_server,
              :username   => $caac_username,
              :password   => $caac_password,
              :version    => $caac_version,
              :headers    => custom_headers
  }

  begin
    @caac = RallyAPI::RallyRestJson.new(config)
  rescue Exception => ex
    print "ERROR: While attempting to connect to CA Agile Central. Message:\n"
    print "       #{ex}\n"
  end
require 'byebug';byebug
  return @caac
end

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
            #User string                   #CA Agile Central artifact type
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
  @caac = connect_to_rally()
  print "Will now process the '#{pop.n_mails}' emails:\n"
  count = 0
  pop.each_mail do |m| 
    mail = Mail.new(m.pop)
    count = count + 1
    print "Email #{count} of #{pop.n_mails}:\n"
    artifact_type = ''
    if mail.subject.downcase.start_with?('defect')
      artifact_type = 'defect'
      ignore = mail.subject.slice!(0, 7)
    elsif mail.subject.downcase.start_with?('story')
      artifact_type = 'story'
      ignore = mail.subject.slice!(0, 6)
    elsif mail.subject.downcase.start_with?('userstory')
      artifact_type = 'story'
      ignore = mail.subject.slice!(0, 10)
    elsif mail.subject.downcase.start_with?('hierarchical_requirement')
      artifact_type = 'story'
      ignore = mail.subject.slice!(0, 25)
    elsif mail.subject.downcase.start_with?('hierarchicalrequirement')
      artifact_type = 'story'
      ignore = mail.subject.slice!(0, 24)
    elsif mail.subject.downcase.start_with?('feature')
      artifact_type = 'portfolioitem/feature'
      ignore = mail.subject.slice!(0, 8)
    elsif mail.subject.downcase.start_with?('portfolioitem/feature')
      artifact_type = 'portfolioitem/feature'
      ignore = mail.subject.slice!(0, 22)
    else
      # Default artifact type is Story
      artifact_type = 'story'
    end

    if !artifact_type.empty?
      print "    creating a CA Agile Central '#{artifact_type}', Name: #{mail.subject}\n"
      begin
        new_artifact = @caac.create(artifact_type, :name => mail.subject, :description => mail.html_part.body)
      rescue Exception => ex
        print "ERROR: While attempting to create the CA Agile Central artifact. Message:\n"
        print "       #{ex}\n"
      end
    end
    print "    new '#{artifact_type}' created: FormattedID=#{new_artifact.FormattedID}  Date='#{new_artifact.CreationDate}'  Project='#{new_artifact.Project.name}'  Workspace='#{new_artifact.Workspace.name}'\n"

    print "    now deleting the email.\n"
    m.delete
  end
end
pop.finish

#[the end]#
