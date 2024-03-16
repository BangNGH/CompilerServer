#!/bin/bash

compiler=$COMPILER
file=$FILE
action=$ACTION

# Kiểm tra xem tập tin input.txt có tồn tại không
if [ -f "/tmp/input.txt" ]; then
  # Đọc giá trị của input từ file input.txt
  input=$(</tmp/input.txt)
else
  # Nếu tập tin không tồn tại, thiết lập input là rỗng
  input=""
fi

if [ -f "/tmp/expected_output.txt" ]; then
  expect=$(</tmp/expected_output.txt)
else
  expect=""
fi

START=$(date +%s.%4N)
output=$(timeout 7s "$compiler" "$file" <<<"$input" 2>&1)
END=$(date +%s.%4N)
status=$?
runtime=$(echo "$END - $START" | bc)

output_base64=$(echo -n "$output" | base64 | tr -d '\n')
input_base64=$(echo -n "$input" | base64 | tr -d '\n')

case "$action" in
"start")
  echo "{\"submissions\": [{" >/tmp/result.json
  if [ $status -eq 124 ]; then
    echo " \"status\": \"124\", " >>/tmp/result.json
    echo "\"stdin\": \"$input_base64\"," >>/tmp/result.json
    echo "\"time\": \"$runtime\"," >>/tmp/result.json
    echo "\"message\": \"Time exceeded\"" >>/tmp/result.json
    echo "}" >>/tmp/result.json
    exit
  fi

  # Kiểm tra xem có lỗi không
  if [ $status -eq 0 ]; then
    if [ "$compiler" = "mcs" ]; then
      if echo "$output" | grep -q "error(s)"; then
        echo " \"status\": \"0\", " >>/tmp/result.json
        echo " \"message\": \"Compilation Failed\", " >>/tmp/result.json
        echo "\"time\": \"$runtime\"," >>/tmp/result.json
        echo "\"stdin\": \"$input_base64\"," >>/tmp/result.json
        echo "\"stdout\": \"$output_base64\"}" >>/tmp/result.json
      fi
      exit
    fi
    # Nếu không có lỗi, mã hoá output và ghi vào file
    if [ -n "$expect" ]; then
      expected=$(echo -n "$expect" | base64 | tr -d '\n')
      # So sánh hai chuỗi base64
  if [ "$expected" = "$output_base64" ]; then
        echo " \"status\": \"1\", " >>/tmp/result.json
        echo " \"message\": \"Accepted\", " >>/tmp/result.json
      else
        echo " \"status\": \"2\", " >>/tmp/result.json
        echo " \"message\": \"Wrong Answer\", " >>/tmp/result.json
        echo " \"expected_output\": \"$expected\", " >>/tmp/result.json
      fi
    else
      echo " \"status\": \"1\", " >>/tmp/result.json
      echo " \"message\": \"Compilation Succeeded\", " >>/tmp/result.json
    fi
    echo "\"stdin\": \"$input_base64\"," >>/tmp/result.json
    echo "\"stdout\": \"$output_base64\"," >>/tmp/result.json
  else
    # Nếu có lỗi, ghi lỗi vào file
    echo " \"status\": \"0\", " >>/tmp/result.json
    echo " \"message\": \" Compilation Failed\", " >>/tmp/result.json
    echo "\"stdin\": \"$input_base64\"," >>/tmp/result.json
    echo -n "\"error\": \"$output_base64\"," >>/tmp/result.json
  fi

  echo "\"time\": \"$runtime\"" >>/tmp/result.json
  echo "}" >>/tmp/result.json
  ;;
"loop")

  if [ $status -eq 124 ]; then
    echo ",{\"status\": \"124\", " >>/tmp/result.json
    echo "\"stdin\": \"$input_base64\"," >>/tmp/result.json
    echo "\"time\": \"$runtime\"," >>/tmp/result.json
    echo "\"message\": \"Time exceeded\"}" >>/tmp/result.json
    exit
  fi

  # Kiểm tra xem có lỗi không
  if [ $status -eq 0 ]; then
    if [ "$compiler" = "mcs" ]; then
      if echo "$output" | grep -q "error(s)"; then
        echo " ,{\"status\": \"0\", " >>/tmp/result.json
        echo " \"message\": \"Compilation Failed\", " >>/tmp/result.json
        echo "\"time\": \"$runtime\"," >>/tmp/result.json
        echo "\"stdin\": \"$input_base64\"," >>/tmp/result.json
        echo "\"stdout\": \"$output_base64\"}" >>/tmp/result.json
      fi
      exit
    fi

    # Nếu không có lỗi, mã hoá output và ghi vào file
    if [ -n "$expect" ]; then
        expected=$(echo -n "$expect" | base64 | tr -d '\n')
      # So sánh hai chuỗi base64
      if [ "$expected" = "$output_base64" ]; then
        echo " ,{\"status\": \"1\", " >>/tmp/result.json
        echo " \"message\": \"Accepted\", " >>/tmp/result.json
      else
        echo " ,{\"status\": \"2\", " >>/tmp/result.json
        echo " \"message\": \"Wrong Answer\", " >>/tmp/result.json
        echo " \"expected_output\": \"$expected\", " >>/tmp/result.json
      fi
    else
      echo " ,{\"status\": \"1\", " >>/tmp/result.json
      echo " \"message\": \"Compilation Succeeded\", " >>/tmp/result.json
    fi

    # Nếu không có lỗi, mã hoá output và ghi vào file
    echo "\"stdin\": \"$input_base64\"," >>/tmp/result.json
    # Nếu không có lỗi, mã hoá output và ghi vào file
    echo "\"stdout\": \"$output_base64\"," >>/tmp/result.json
  else
    # Nếu có lỗi, ghi lỗi vào file
    echo ",{\"status\": \"0\", " >>/tmp/result.json
    echo "\"message\": \" Compilation Failed\", " >>/tmp/result.json
    echo "\"stdin\": \"$input_base64\"," >>/tmp/result.json
    echo -n "\"error\": \"$output_base64\"," >>/tmp/result.json

  fi
  echo "\"time\": \"$runtime\"" >>/tmp/result.json
  echo "}" >>/tmp/result.json
  ;;
"stop")

  if [ $status -eq 124 ]; then
    echo ",{\"status\": \"124\", " >>/tmp/result.json
    echo "\"stdin\": \"$input_base64\"," >>/tmp/result.json
    echo "\"time\": \"$runtime\"," >>/tmp/result.json
    echo "\"message\": \"Time exceeded\"}" >>/tmp/result.json
    exit
  fi

  # Kiểm tra xem có lỗi không
  if [ $status -eq 0 ]; then
    if [ "$compiler" = "mcs" ]; then
      if echo "$output" | grep -q "error(s)"; then
        echo " ,{\"status\": \"0\", " >>/tmp/result.json
        echo " \"message\": \"Compilation Failed\", " >>/tmp/result.json
        echo "\"time\": \"$runtime\"," >>/tmp/result.json
        echo "\"stdin\": \"$input_base64\"," >>/tmp/result.json
        echo "\"stdout\": \"$output_base64\"}]}" >>/tmp/result.json
      fi
      exit
    fi

    # Nếu không có lỗi, mã hoá output và ghi vào file
    if [ -n "$expect" ]; then
        expected=$(echo -n "$expect" | base64 | tr -d '\n')
      # So sánh hai chuỗi base64
      if [ "$expected" = "$output_base64" ]; then
        echo " ,{\"status\": \"1\", " >>/tmp/result.json
        echo " \"message\": \"Accepted\", " >>/tmp/result.json
      else
        echo " ,{\"status\": \"2\", " >>/tmp/result.json
        echo " \"message\": \"Wrong Answer\", " >>/tmp/result.json
        echo " \"expected_output\": \"$expected\", " >>/tmp/result.json
      fi
    else
      echo " ,{\"status\": \"1\", " >>/tmp/result.json
      echo " \"message\": \"Compilation Succeeded\", " >>/tmp/result.json
    fi

    echo "\"stdin\": \"$input_base64\"," >>/tmp/result.json
    # Nếu không có lỗi, mã hoá output và ghi vào file
    echo "\"stdout\": \"$output_base64\"," >>/tmp/result.json
  else
    # Nếu có lỗi, ghi lỗi vào file
    echo ",{\"status\": \"0\", " >>/tmp/result.json
    echo " \"message\": \" Compilation Failed\", " >>/tmp/result.json
    echo "\"stdin\": \"$input_base64\"," >>/tmp/result.json
    echo -n "\"error\": \"$output_base64\"," >>/tmp/result.json
  fi

  echo "\"time\": \"$runtime\"" >>/tmp/result.json
  echo "}]}" >>/tmp/result.json

  ;;
"singlefile")
  echo "{\"submissions\": [{" >/tmp/result.json
  if [ $status -eq 124 ]; then
    echo " \"status\": \"124\", " >>/tmp/result.json
    echo "\"time\": \"$runtime\"," >>/tmp/result.json
    echo "\"stdin\": \"$input_base64\"," >>/tmp/result.json
    echo "\"message\": \"Time exceeded\"}" >>/tmp/result.json
    exit
  fi

  # Kiểm tra xem có lỗi không
  if [ $status -eq 0 ]; then
    if [ "$compiler" = "mcs" ]; then
      if echo "$output" | grep -q "error(s)"; then
        echo " \"status\": \"0\", " >>/tmp/result.json
        echo " \"message\": \"Compilation Failed\", " >>/tmp/result.json
        echo "\"time\": \"$runtime\"," >>/tmp/result.json
        echo "\"stdin\": \"$input_base64\"," >>/tmp/result.json
        echo "\"stdout\": \"$output_base64\"}]}" >>/tmp/result.json
      fi
      exit
    fi

    # Nếu không có lỗi, mã hoá output và ghi vào file
    if [ -n "$expect" ]; then
        expected=$(echo -n "$expect" | base64 | tr -d '\n')
      # So sánh hai chuỗi base64
      if [ "$expected" = "$output_base64" ]; then
        echo " \"status\": \"1\", " >>/tmp/result.json
        echo " \"message\": \"Accepted\", " >>/tmp/result.json
      else
        echo " \"status\": \"2\", " >>/tmp/result.json
        echo " \"message\": \"Wrong Answer\", " >>/tmp/result.json
        echo " \"expected_output\": \"$expected\", " >>/tmp/result.json
      fi
    else
      echo " \"status\": \"1\", " >>/tmp/result.json
      echo " \"message\": \"Compilation Succeeded\", " >>/tmp/result.json
    fi
    echo "\"stdin\": \"$input_base64\"," >>/tmp/result.json
    echo "\"stdout\": \"$output_base64\"," >>/tmp/result.json
  else
    # Nếu có lỗi, ghi lỗi vào file
    echo " \"status\": \"0\", " >>/tmp/result.json
    echo " \"message\": \" Compilation Failed\", " >>/tmp/result.json
    echo "\"stdin\": \"$input_base64\"," >>/tmp/result.json
    echo -n "\"error\": \"$output_base64\"," >>/tmp/result.json
  fi

  echo "\"time\": \"$runtime\"" >>/tmp/result.json
  echo "}]}" >>/tmp/result.json
  ;;
*)
  echo "Unknown action: $action"
  # Xử lý trường hợp không xác định được action
  ;;
esac
