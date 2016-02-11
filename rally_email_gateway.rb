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
$mail_server        = 'pop.rallyemailgateway.mailinator.com'
$mail_port          = '995'
$mail_username      = 'rallyemailgateway'
$mail_password      = ''
$mail_enable_ssl    = true
$mail_debug_output  = false # Security warning: causes password to echo to screen


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
  print "Skipping optional require of '#{my_vars}' file...\n\n"
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
  return @caac
end

# ------------------------------------------------------------------------------
# Connect to mail server via POP3 
#
print "Connecting to POP3 email with:\n"
print "\taddress     : <#{$mail_server}>\n"
print "\tport        : <#{$mail_port}>\n"
print "\tuser_name   : <#{$mail_username}>\n"
print "\tenable_ssl  : <#{$mail_enable_ssl}>\n"
print "\tdebug_output: <#{$mail_debug_output}>\n\n"
pop = Net::POP3.new($mail_server, $mail_port)
pop.enable_ssl(OpenSSL::SSL::VERIFY_NONE)   if $mail_enable_ssl
pop.set_debug_output $stdout                if $mail_debug_output
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
    print "Email #{count} of #{pop.n_mails}, from '#{mail.from}', date '#{mail.date}':\n"
    artifact_type = ''

    if !mail.subject.nil?
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
    end

    if !artifact_type.empty?
      mail.subject.strip!
      print "    creating a CA Agile Central '#{artifact_type}', Name: #{mail.subject}\n"
      begin
        fields = {}
        fields['Name'] = mail.subject[0..255]
        if !mail.html_part.body.nil?
          fields['Description'] = mail.html_part.body.raw_source[0..32767]
        end
        new_artifact = @caac.create(artifact_type, fields)
      rescue Exception => ex
        print "ERROR: While attempting to create the CA Agile Central artifact. Message:\n"
        print "       #{ex}\n"
        next
      end
      print "    new '#{artifact_type}' created:"
      print "  FormattedID='#{new_artifact.FormattedID}'"
      print "  Date='#{new_artifact.CreationDate}'"
      print "  Project='#{new_artifact.Project.name}'"
      print "  Workspace='#{new_artifact.Workspace.name}'"
      print "\n"
    else
      print "    email subject is empty; nothing to create\n"
    end

    print "    now deleting the email.\n"
    m.delete
  end
end
pop.finish

#[the end]#
