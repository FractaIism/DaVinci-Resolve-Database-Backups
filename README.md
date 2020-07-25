# DaVinci-Resolve-Database-Backups
A batch script to backup DaVinci Resolve's default disk database. (for Windows only)

### Requirements:
- [7za](https://www.7-zip.org/download.html) - 7zip standalone command line utility
- [Git](https://git-scm.com/about) - for uploading to GitHub after each backup
- [System Scheduler](https://www.splinterware.com/products/scheduler.html) (optional) - for automatic backups

### How to Use:
1. Create a respository and copy "drdb_backup.bat" into it. (repos needs to be both on local and cloud)
2. Run "drdb_backup.bat" to backup the database. (stored as a .7z file in the Automatic Backups directory)
3. Create an event in System Scheduler to perform regular backups.
