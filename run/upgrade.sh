#!/bin/bash

# 定義常用變數
UPDATE_PACKAGE="/tmp/update_package.tar.gz"
PROG_ROOT_DIR="${HOME}/run"
TMP_DIR="/tmp/update_temp_$(date +%s)"  # 使用當前時間戳來避免臨時目錄衝突

# 使用者輸入sudo密碼
sudo .

echo "Start updating..."

# 印出訊息
echo "================================================="
echo "Update package: ${UPDATE_PACKAGE}"
echo "Program root directory: ${PROG_ROOT_DIR}"
echo "Temporary directory: ${TMP_DIR}"
echo "================================================="

# 步驟 1：解壓更新包
echo "Step 1: Extracting update package..."
mkdir -p ${TMP_DIR}
if tar -xzf ${UPDATE_PACKAGE} -C ${TMP_DIR}; then
    echo "Update package extracted to ${TMP_DIR}."
else
    echo "Failed to extract update package. Exiting."
    exit 1
fi

# 步驟 2：停止所有服務
echo "Step 2: Stopping all services..."
for prog_dir in ${PROG_ROOT_DIR}/*/; do
    prog_name=$(basename ${prog_dir})
    SERVICE_NAME="${prog_name,,}.service"  # 轉換為小寫並加上.service
    echo "Stopping service ${SERVICE_NAME}..."
    # 停止服務
    if ! sudo systemctl stop ${SERVICE_NAME}; then
        # 若上面指令回應服務不存在 (eg: not loaded.)，則跳過
        echo "Service ${SERVICE_NAME} not running. Skipping."
        continue
    fi
done
echo "All services stopped."

# 步驟 3：更新所有程式
echo "Step 3: Updating all programs..."
for prog_dir in ${PROG_ROOT_DIR}/*/; do
    prog_name=$(basename ${prog_dir})
    if [ -d "${TMP_DIR}/${prog_name,,}" ]; then
        echo "Updating program ${prog_name}..."
        if ! cp -r ${TMP_DIR}/${prog_name,,}/* ${prog_dir}; then
            echo "Failed to update program ${prog_name}. Exiting."
            exit 1
        fi
        # 設定可執行權限
        if ! chmod +x ${prog_dir}/${prog_name}; then
            echo "Failed to set execute permission for program ${prog_name}. Exiting."
            exit 1
        fi
    else
        echo "No update found for program ${prog_name}. Skipping."
    fi
done
echo "All programs updated."

# 步驟 4：清理臨時文件
echo "Step 4: Cleaning up temporary files..."
rm -rf ${TMP_DIR}
echo "Temporary files cleaned up."


# 步驟 5：重啟所有服務
echo "Step 5: Restarting all services..."
for prog_dir in ${PROG_ROOT_DIR}/*/; do
    prog_name=$(basename ${prog_dir})
    SERVICE_NAME="${prog_name,,}.service"  # 轉換為小寫並加上.service
    cd ${prog_dir}
    echo "Restart service ${SERVICE_NAME}..."
    if ! sudo cp ${SERVICE_NAME} /etc/systemd/system/; then
        echo "Failed to copy service file ${SERVICE_NAME}. Exiting."
        exit 1
    fi
    sudo systemctl daemon-reload
    # 啟用當前服務
    if ! sudo systemctl enable ${SERVICE_NAME}; then
        echo "Failed to enable service ${SERVICE_NAME}. Exiting."
        exit 1
    fi
    # 開啟服務
    if ! sudo systemctl start ${SERVICE_NAME}; then
        echo "Failed to start service ${SERVICE_NAME}. Exiting."
        exit 1
    fi
    cd ..
done

echo "All services restarted."

echo "Update completed successfully."
