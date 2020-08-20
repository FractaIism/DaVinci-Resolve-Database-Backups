@echo off
REM // Backup DaVici Resolve default disk database
REM // use System Scheduler to perform regular backups
REM // (DRDB stands for DaVinci Resolve Database)

REM // CMD note:
REM // space before "=" is part of variable name
REM // space after "=" is part of variable value
REM // comments using :: syntax create bullshit bugs in compound statements


REM // prevents certain problems with variables in loops
setlocal EnableDelayedExpansion

REM // disk database path (do NOT include backslash at the end)
set db_path=C:\Users\%username%\AppData\Roaming\Blackmagic Design\DaVinci Resolve\Support\Resolve Disk Database\..

REM // file extension (compress format)
set ext=7z

REM // datetime formatting
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

REM // log file separator
(
  echo. & echo.
  echo ------------------------------------------------------------------------
  echo. & echo.
) >> drdb_backup_log.txt

echo === %formatted_datetime_2% === >> drdb_backup_log.txt

REM // compress database, create notification file at D: in case of error
7za a -mmt8 -mx9 "Automatic Backups\DRDB_Backup_%formatted_datetime%.%ext%" "%db_path%\Resolve Disk Database" > drdb_temp_log.txt 2>&1 || ^
echo %formatted_datetime_2%: Error during DaVinci Resolve database backup, check the logs at %~dp0drdb_backup_log.txt >> "D:\DaVinci Resolve backup error notification.txt"



REM // check if database has changed
REM // if it hasn't changed, remove the backup file to save space

REM // file count
set fc=0

REM // use !var! in loops to expand variables at execution time
for %%f in ("Automatic Backups\*.*") do (
  set /a fc=fc+1
  if !fc! == 1 (
    set z0=%%f
  ) else (
    REM // move previous file to z1
    set z1=!z0!
    REM // store current file in z0
    set z0=%%f
  )
)

REM // hashing, not used because fc makes things easier
REM // CertUtil -hashfile %z0% md5 > hash0.txt  :: hash last file
REM // CertUtil -hashfile %z1% md5 > hash1.txt  :: hash second-to-last file

if %fc% EQU 1 (
  REM // only one backup present
  goto push_GitHub
) else (
  REM // compare this backup with the last one
  fc "%z0%" "%z1%" > nul
  if errorlevel 1 (
    REM // files differ
    goto push_GitHub
  ) else (
    REM // files are identical, perform cleanup
    (
      del "Automatic Backups\DRDB_Backup_%formatted_datetime%.%ext%"
      echo.
      echo No changes in database since last backup.
    ) >> drdb_backup_log.txt 2>&1
    goto cleanup
  )
)

exit
REM // end of script

:push_GitHub
type drdb_temp_log.txt >> drdb_backup_log.txt
(
  echo. & echo.
  echo Pushing to GitHub:
  echo.
  git add -A
  git commit --allow-empty-message -m ""
  git push
) >> drdb_backup_log.txt 2>&1
goto cleanup

:cleanup
del drdb_temp_log.txt