This gem can help you to upload a backup of your database(Mysql)
How to use:

The library opens up the Mysql database and backups it to Dropbox.

Create an object of class BackupData and then call method start

Example:
#################  This is an example of how to use it  ########################
require 'md_mysql_dropbox_moh'
obj =BackupData.new
obj.start