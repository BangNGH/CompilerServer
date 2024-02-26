#!/bin/bash

compiler=$COMPILER
file=$FILE

# Kiểm tra xem tập tin input.txt có tồn tại không
if [ -f "/tmp/input.txt" ]; then
    # Đọc giá trị của input từ file input.txt
    input=$(</tmp/input.txt)
else
    # Nếu tập tin không tồn tại, thiết lập input là rỗng
    input=""
fi

START=$(date +%s.%4N)
echo "{" > /tmp/result.json
echo -n "\"output\": \"" >> /tmp/result.json    # Sử dụng -n để không tạo dòng mới
# Chạy Main.java với giá trị của input
echo "$input" | $compiler $file | tr '\n' ' ' >> /tmp/result.json  # Thay thế ký tự xuống dòng bằng khoảng trắng
echo "\"," >> /tmp/result.json

END=$(date +%s.%4N)

runtime=$(echo "$END - $START" | bc)

echo "\"runtime\": \"$runtime\"" >> /tmp/result.json
echo "}" >> /tmp/result.json
