Set Shell = CreateObject("WScript.Shell")
Shell.Run "drdb_backup.bat", 0, False
'Shell.Run "cmd /k drdb_backup.bat"