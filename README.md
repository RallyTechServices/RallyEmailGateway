# RallyEmailGateway
A Ruby script for creating a CA Agile Central (aka Rally) artifact using a POP3 mail server.

## Testing done
* Ruby 2.2.4
* Install gems: gem install mail mime-types rally_api httpclient mime-types-data

## Usage
1. Create an email account to be used to process all incoming CA Agile Central (aka Rally) creation requests. For example, CAAgilerequest@domain.com.

2. Setup the Ruby script on a server to run a service when an incoming mail is sent to the email account created above.

3. For each email, the Ruby script will create an artifact of type:

..* defect  - email subjects starting with 'defect'
..* feature - email subjects starting with 'feature' or 'portfolioitem/feature'
..* story   - email subjects starting with 'story' or 'userstory' or 'hierarchicalrequirement' or 'hierarchical_requirement'
..* story   - if the email subject does not start with any of the above

4. The CA Agile Central (aka Rally) artifact will be created in the user's default Project/Workspace.

5. Edit the Ruby script with appropriate CA Agile Central (aka Rally) settings and POP3 mail server settings.

6. Create a cron job on a Unix/Mac server to run the script at a set interval (or the equivalent for Windows system).
