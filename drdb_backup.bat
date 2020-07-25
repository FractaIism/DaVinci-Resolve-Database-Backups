:: Backup DaVici Resolve default disk database
:: use System Scheduler to perform regular backups
:: (DRDB stands for DaVinci Resolve Database)

:: CMD note:
:: space before "=" is part of variable name
:: space after "=" is part of variable value

@echo off

:: prevents certain problems with variables in loops
setlocal EnableDelayedExpansion

:: disk database path (do NOT include backslash at the end)
set db_path=C:\Users\%username%\AppData\Roaming\Blackmagic Design\DaVinci Resolve\Support\Resolve Disk Database\..

:: file extension (compress format)
set ext=7z

:: datetime formatting
set year=%date:~6,4%
set month=%date:~0,2%
set day=%date:~3,2%
set dayOfWeek=%date:~11,3%
set hour=%time:~0,2%
set hour=%hour: =0%
set minute=%time:~3,2%
set second=%time:~6,2%
set formatted_datetime=%year%_%month%_%day%_%hour%%minute%%second%
set formatted_datetime_2=%year%/%month%/%day% %dayOfWeek% %hour%:%minute%:%second%

:: log file separator
echo. >> drdb_backup_log.txt
echo. >> drdb_backup_log.txt
echo ------------------------------------------------------------------------ >> drdb_backup_log.txt
echo. >> drdb_backup_log.txt
echo. >> drdb_backup_log.txt

echo === %formatted_datetime_2% === >> drdb_backup_log.txt

:: compress database, create notification file at D: in case of error
7za a "Automatic Backups\DRDB_Backup_%formatted_datetime%.%ext%" "%db_path%\Resolve Disk Database" >> drdb_backup_log.txt 2>&1 || echo %formatted_datetime_2%: Error during DaVinci Resolve database backup, check the logs at %~dp0drdb_backup_log.txt >> "D:\DaVinci Resolve backup error notification.txt"



:: check if database has changed
:: if it hasn't changed, remove the backup file to save space

:: file count
set fc=0

for %%f in ("Automatic Backups\*.*") do (
  set /a fc=fc+1
  echo !fc! %%f
  if !fc! == 1 (
    set z0=%%f
  ) else (
    :: move previous file to z1
    set z1=!z0!
    :: store current file in z0
    set z0=%%f
  )
)

:: hashing, not used because fc makes things easier
:: CertUtil -hashfile %z0% md5 > hash0.txt  :: hash last file
:: CertUtil -hashfile %z1% md5 > hash1.txt  :: hash second-to-last file

fc "%z0%" "%z1%"
if errorlevel 1 (  :: if files differ
  :: all is good
) else (  :: files are identical, perform cleanup
  del "Automatic Backups\DRDB_Backup_%formatted_datetime%.%ext%"
  echo. >> drdb_backup_log.txt
  echo No changes in database since last backup. New backup file removed. >> drdb_backup_log.txt
)

