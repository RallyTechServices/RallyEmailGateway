RallyEmailGateway
=================
README file for creating a Rally defect or story using a POP3 mail server

Tested with Ruby 2.2.4
Install gems:
    gem install mail mime-types rally_api httpclient mime-types-data

Create email account to be used to process all incoming Rally creation requests. For example, rallyrequest@domain.com.

Setup the Ruby script on a server to run a service when an incoming mail is sent to the email account created above.
For each email, the Ruby script will create an artifact of type:
*   defect - email subjects starting with 'defect'
*   story - email subjects starting with 'story' or 'userstory' or 'hierarchicalrequirement' or 'hierarchical_requirement'
*   Otherwise, the email is ignored

It will be created in the user's default Project/Workspace.

Edit Ruby script with appropriate Rally settings and POP3 mail server settings.

Create a cron job on a Unix/Mac server to run the script at a set interval or the equivalent for Windows.
