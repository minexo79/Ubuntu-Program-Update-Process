# Linux Program Update Process

# Steps
1. 定義更新包的路徑、程式的根目錄、臨時目錄等常用變數。
2. 解壓更新包到臨時目錄。
3. 遍歷程式的根目錄下的所有資料夾，停止每個程式對應的服務。
4. 將解壓出的更新包內容複製到對應的程式資料夾中。
5. 刪除臨時目錄及其內容。
6. 重啟所有程式對應的服務。

## Example
```log
Start updating...
=================================================
Update package: /tmp/update_package.tar.gz
Program root directory: /home/minexo79/run
Temporary directory: /tmp/update_temp_1718036421
=================================================
Step 1: Extracting update package...
Update package extracted to /tmp/update_temp_1718036421.
Step 2: Stopping all services...
Stopping service program-a.service...
Stopping service program-b.service...
Stopping service program-c.service...
All services stopped.
Step 3: Updating all programs...
Updating program program-a...
Updating program program-b...
Updating program program-c...
All programs updated.
Step 4: Cleaning up temporary files...
Temporary files cleaned up.
Step 5: Restarting all services...
Starting service program-a.service...
Starting service program-b.service...
Starting service program-c.service...
All services restarted.
Update completed successfully.
```

# Services Example
```ini
[Unit]
Description=program-a test service

[Service]
Type=simple
ExecStart=<執行目錄>/program-a/program-a
User=<使用者名稱>
Restart=always

[Install]
WantedBy=multi-user.target
```