#### RallyEmailGateway
A Ruby script for creating a CA Agile Central (aka Rally) artifact using a POP3 mail server.

##### Testing done
1. Ruby 2.2.4
1. Installed Ruby gems:
   * gem  install  mail  mime-types  rally_api  httpclient  mime-types-data

##### Setup
1. Create an email account to be used to process all incoming CA Agile Central (aka Rally) creation requests. For example, CAAgilerequest@domain.com
1. Setup the Ruby script on a server to run a service when an incoming mail is sent to the email account created above
1. Edit the Ruby script with appropriate CA Agile Central (aka Rally) settings and POP3 mail server settings
1. Create a cron job on a Unix/Mac server to run the script at a set interval (or the equivalent for a Windows system)

##### Usage
1. For each email, the Ruby script will create an artifact of type:
   * defect  - email subjects starting with 'defect'
   * feature - email subjects starting with 'feature' or 'portfolioitem/feature'
   * story   - email subjects starting with 'story' or 'userstory' or 'hierarchicalrequirement' or 'hierarchical_requirement'
   * story   - if the email subject does not start with any of the above keywords
1. The above keywords are case-insensitive
1. The CA Agile Central (aka Rally) artifact will be created in the user's default Workspace and Project
1. The artifact will be created as follows:
   * The ```Name``` will be composed of the Email Subject with any leading keyword (above) removed
   * The ```Description``` will be composed of the Email Body
1. The Email will be deleted (via POP3) when the artifact is created
