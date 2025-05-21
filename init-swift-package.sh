#!/bin/bash

# 1. 參數檢查
if [ -z "$1" ]; then
  echo "用法: $0 <專案名稱>"
  exit 1
fi
PROJECT_NAME=$1

# 2. 建立並切換到新專案資料夾
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit 1

# 3. 初始化 Swift 可執行專案
swift package init --type executable

# 刪除預設的 main.swift 檔案
rm -f Sources/main.swift
echo "已刪除預設的 main.swift 檔案"

# 4. 複製模板內容
cp -R "../Templates/." .

# 5. 替換 __PROJECT_NAME__ 為實際專案名稱（內容與檔名）
# 初始化檔案與資料夾池
declare -a swiftFilePool=()
declare -a folderPool=()

# 初始掃描根目錄
echo "開始處理檔案與資料夾替換..."
folderPool+=(".")

# 遞迴處理所有資料夾與檔案
while [ ${#folderPool[@]} -gt 0 ] || [ ${#swiftFilePool[@]} -gt 0 ]; do
  # 優先處理檔案池中的檔案
  if [ ${#swiftFilePool[@]} -gt 0 ]; then
    # 取出一個檔案處理
    current_file="${swiftFilePool[0]}"
    swiftFilePool=("${swiftFilePool[@]:1}") # 移除已處理的檔案
    
    echo "處理檔案: $current_file"
    
    # 替換檔案內容
    sed -i '' "s/__PROJECT_NAME__/$PROJECT_NAME/g" "$current_file"
    
    # 檢查檔案名稱是否需要替換
    new_filename=$(echo "$current_file" | sed "s/__PROJECT_NAME__/$PROJECT_NAME/g")
    if [ "$current_file" != "$new_filename" ]; then
      # 建立必要的目錄結構
      mkdir -p "$(dirname "$new_filename")"
      # 重命名檔案
      mv "$current_file" "$new_filename"
      echo "  重命名: $current_file -> $new_filename"
    fi
  else
    # 檔案池空了，從資料夾池取出一個資料夾處理
    if [ ${#folderPool[@]} -gt 0 ]; then
      current_folder="${folderPool[0]}"
      folderPool=("${folderPool[@]:1}") # 移除已處理的資料夾
      
      echo "掃描資料夾: $current_folder"
      
      # 掃描當前資料夾中的所有 Swift 檔案和子資料夾
      for file in "$current_folder"/*.swift; do
        swiftFilePool+=("$file")
      done
      
      # 掃描子資料夾
      for dir in "$current_folder"/*; do
        if [ -d "$dir" ]; then
          # 忽略 .build 目錄
          if [[ "$(basename "$dir")" == ".build" ]]; then
            echo "  忽略 .build 目錄: $dir"
            continue
          fi
          
          if [ "$dir" != "$current_folder" ]; then
            # 檢查資料夾名稱是否需要替換
            new_dirname=$(echo "$dir" | sed "s/__PROJECT_NAME__/$PROJECT_NAME/g")
            
            if [ "$dir" != "$new_dirname" ]; then
              # 如果資料夾名稱需要替換，先將其加入資料夾池，稍後再處理
              echo "  發現需要重命名的資料夾: $dir -> $new_dirname"
              
              # 建立新資料夾
              mkdir -p "$new_dirname"
              
              # 將舊資料夾中的內容移動到新資料夾
              cp -R "$dir"/* "$new_dirname"/ 2>/dev/null || true
              
              # 將新資料夾加入資料夾池
              folderPool+=("$new_dirname")
              
              # 刪除舊資料夾
              rm -rf "$dir"
            else
              # 資料夾名稱不需要替換，直接加入資料夾池
              folderPool+=("$dir")
            fi
          fi
        fi
      done
    fi
  fi
done

# 6. 設定檔案權限
find . -type f -exec chmod 644 {} +
find . -type d -exec chmod 755 {} +

# 7. 設定擁有權
CURRENT_USER=$(whoami)
CURRENT_GROUP=$(id -gn "$CURRENT_USER")
chown -R "$CURRENT_USER":"$CURRENT_GROUP" .

# 8. 完成提示
echo "專案 '$PROJECT_NAME' 已建立完成。"