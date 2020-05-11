# Redmine ISSUE SLA plugin

###### Redmine's plugin to allow to assign an SLA by issue priority and project. Setting up a first response (assign) and close expiration time after creation.

## Installation

   1. Navegate to redmine root folder
      (example: cd /var/www/html/redmine)
   2. Clone plugin
      git clone https://github.com/smlabonia/redmine_issue_sla.git plugins
   3. Run plugin migrations
      bundle exec rake redmine:plugins:migrate NAME=redmine_issue_sla RAILS_ENV=production
   4. Restart webserver
      sudo service apache2 restart

Installed plugins are listed and can be configured from 'Admin -> Plugins' screen.

## How to use

   1. Assign permissions to users/groups considering who can:
      a. View issues SLA
      b. Edit SLA settings
      c. Interfere on Issue SLA cicle of life (Assign Issue to complete first_response and closed on)
   2. Enable plugin on project
   3. Setup Project SLA for each priority and Assign expiration time and Close expiration time
   4. You will find those new columns in your issues list options

## Considerations

   1. When SLA is enabled on projects, old issues will be not changed. It only applies to new issues
   2. When SLA expiration times changes, expiration time on opened issues with SLA active will be extended
