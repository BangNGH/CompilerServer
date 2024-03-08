#!/bin/bash

compiler=$COMPILER
file=$FILE
action=$ACTION
case "$action" in
"start")
  # Kiểm tra xem tập tin input.txt có tồn tại không
  if [ -f "/tmp/input.txt" ]; then
    # Đọc giá trị của input từ file input.txt
    input=$(</tmp/input.txt)
  else
    # Nếu tập tin không tồn tại, thiết lập input là rỗng
    input=""
  fi

  echo "{\"submissions\": [{" >/tmp/result.json

  START=$(date +%s.%4N)
  output=$(timeout 5s "$compiler" "$file" <<<"$input" 2>&1)
  END=$(date +%s.%4N)

  status=$?
  if [ $status -eq 124 ]; then
    echo " \"status\": \"124\", " >>/tmp/result.json
    echo "\"message\": \"Time exceeded\"," >>/tmp/result.json
    echo "\"stdin\": \"$input\"" >>/tmp/result.json

    echo "}" >>/tmp/result.json
    exit
  fi

  # Kiểm tra xem có lỗi không
  if [ $status -eq 0 ]; then
    if [ "$compiler" = "mcs" ]; then
      if echo "$output" | grep -q "error(s)"; then
        echo " \"status\": \"0\", " >>/tmp/result.json
        echo " \"message\": \"Compilation Failed\", " >>/tmp/result.json
        echo "\"stdin\": \"$input\"," >>/tmp/result.json
        echo -n "\"stdout\": \"" >>/tmp/result.json
        echo -n "$output" | base64 | tr -d '\n' >>/tmp/result.json
        echo "\"}" >>/tmp/result.json
      fi
      exit
    fi
    # Nếu không có lỗi, mã hoá output và ghi vào file
    echo " \"status\": \"1\", " >>/tmp/result.json
    echo " \"message\": \"Compilation Succeeded\", " >>/tmp/result.json
    echo "\"stdin\": \"$input\"," >>/tmp/result.json
    echo -n "\"stdout\": \"" >>/tmp/result.json
    echo -n "$output" | base64 | tr -d '\n' >>/tmp/result.json
    echo "\"," >>/tmp/result.json
  else
    # Nếu có lỗi, ghi lỗi vào file
    echo " \"status\": \"0\", " >>/tmp/result.json
    echo " \"message\": \" Compilation Failed\", " >>/tmp/result.json
    echo "\"stdin\": \"$input\"," >>/tmp/result.json
    echo -n "\"error\": \"" >>/tmp/result.json
    echo -n "$output" | base64 | tr -d '\n' >>/tmp/result.json
    echo "\"," >>/tmp/result.json
  fi

  runtime=$(echo "$END - $START" | bc)

  echo "\"time\": \"$runtime\"" >>/tmp/result.json
  echo "}" >>/tmp/result.json
  ;;
"loop")
  if [ -f "/tmp/input.txt" ]; then
    # Đọc giá trị của input từ file input.txt
    input=$(</tmp/input.txt)
  else
    # Nếu tập tin không tồn tại, thiết lập input là rỗng
    input=""
  fi

  START=$(date +%s.%4N)
  output=$(timeout 5s "$compiler" "$file" <<<"$input" 2>&1)
  END=$(date +%s.%4N)

  status=$?

  if [ $status -eq 124 ]; then
     echo ",{\"status\": \"124\", " >>/tmp/result.json
     echo "\"stdin\": \"$input\"," >>/tmp/result.json
    echo "\"message\": \"Time exceeded\"" >>/tmp/result.json
    echo "}" >>/tmp/result.json
    exit
  fi

  # Kiểm tra xem có lỗi không
  if [ $status -eq 0 ]; then
    if [ "$compiler" = "mcs" ]; then
         if echo "$output" | grep -q "error(s)"; then
           echo " ,{\"status\": \"0\", " >>/tmp/result.json
           echo " \"message\": \"Compilation Failed\", " >>/tmp/result.json
           echo "\"stdin\": \"$input\"," >>/tmp/result.json
           echo -n "\"stdout\": \"" >>/tmp/result.json
           echo -n "$output" | base64 | tr -d '\n' >>/tmp/result.json
           echo "\"}" >>/tmp/result.json
         fi
         exit
       fi
    # Nếu không có lỗi, mã hoá output và ghi vào file
    echo " ,{\"status\": \"1\", " >>/tmp/result.json
    echo " \"message\": \"Compilation Succeeded\", " >>/tmp/result.json
    echo "\"stdin\": \"$input\"," >>/tmp/result.json
    # Nếu không có lỗi, mã hoá output và ghi vào file
    echo -n "\"stdout\": \"" >>/tmp/result.json
    echo -n "$output" | base64 | tr -d '\n' >>/tmp/result.json
    echo "\"," >>/tmp/result.json
  else
    # Nếu có lỗi, ghi lỗi vào file
    echo ",{\"status\": \"0\", " >>/tmp/result.json
    echo "\"message\": \" Compilation Failed\", " >>/tmp/result.json
    echo "\"stdin\": \"$input\"," >>/tmp/result.json
    echo -n "\"error\": \"" >>/tmp/result.json
    echo -n "$output" | base64 | tr -d '\n' >>/tmp/result.json
    echo "\"," >>/tmp/result.json
  fi

  runtime=$(echo "$END - $START" | bc)

  echo "\"time\": \"$runtime\"" >>/tmp/result.json
  echo "}" >>/tmp/result.json
  ;;
"stop")
  if [ -f "/tmp/input.txt" ]; then
    # Đọc giá trị của input từ file input.txt
    input=$(</tmp/input.txt)
  else
    # Nếu tập tin không tồn tại, thiết lập input là rỗng
    input=""
  fi

  START=$(date +%s.%4N)
  output=$(timeout 5s "$compiler" "$file" <<<"$input" 2>&1)
  END=$(date +%s.%4N)

  status=$?


  if [ $status -eq 124 ]; then
     echo ",{\"status\": \"124\", " >>/tmp/result.json
    echo "\"message\": \"Time exceeded\"" >>/tmp/result.json
    echo "\"stdin\": \"$input\"," >>/tmp/result.json
    echo "}" >>/tmp/result.json
    exit
  fi

  # Kiểm tra xem có lỗi không
  if [ $status -eq 0 ]; then
    if [ "$compiler" = "mcs" ]; then
         if echo "$output" | grep -q "error(s)"; then
           echo " ,{\"status\": \"0\", " >>/tmp/result.json
           echo " \"message\": \"Compilation Failed\", " >>/tmp/result.json
           echo "\"stdin\": \"$input\"," >>/tmp/result.json
           echo -n "\"stdout\": \"" >>/tmp/result.json
           echo -n "$output" | base64 | tr -d '\n' >>/tmp/result.json
           echo "}" >>/tmp/result.json
         fi
         exit
       fi
    # Nếu không có lỗi, mã hoá output và ghi vào file
    echo " ,{\"status\": \"1\", " >>/tmp/result.json
    echo " \"message\": \"Compilation Succeeded\", " >>/tmp/result.json
    echo "\"stdin\": \"$input\"," >>/tmp/result.json
    # Nếu không có lỗi, mã hoá output và ghi vào file
    echo -n "\"stdout\": \"" >>/tmp/result.json
    echo -n "$output" | base64 | tr -d '\n' >>/tmp/result.json
    echo "\"," >>/tmp/result.json
  else
    # Nếu có lỗi, ghi lỗi vào file
    echo ",{\"status\": \"0\", " >>/tmp/result.json
    echo " \"message\": \" Compilation Failed\", " >>/tmp/result.json
    echo "\"stdin\": \"$input\"," >>/tmp/result.json
    echo -n "\"error\": \"" >>/tmp/result.json
    echo -n "$output" | base64 | tr -d '\n' >>/tmp/result.json
    echo "\"," >>/tmp/result.json
  fi

  runtime=$(echo "$END - $START" | bc)

  echo "\"time\": \"$runtime\"" >>/tmp/result.json
  echo "}]}" >>/tmp/result.json

  ;;
"singlefile")
 # Kiểm tra xem tập tin input.txt có tồn tại không
  if [ -f "/tmp/input.txt" ]; then
    # Đọc giá trị của input từ file input.txt
    input=$(</tmp/input.txt)
  else
    # Nếu tập tin không tồn tại, thiết lập input là rỗng
    input=""
  fi

  echo "{\"submissions\": [{" >/tmp/result.json

  START=$(date +%s.%4N)
  output=$(timeout 5s "$compiler" "$file" <<<"$input" 2>&1)
  END=$(date +%s.%4N)

  status=$?
  if [ $status -eq 124 ]; then
 echo " \"status\": \"124\", " >>/tmp/result.json
    echo "\"message\": \"Time exceeded\"," >>/tmp/result.json
    echo "\"stdin\": \"$input\"" >>/tmp/result.json
    echo "}" >>/tmp/result.json
    exit
  fi

  # Kiểm tra xem có lỗi không
  if [ $status -eq 0 ]; then
    if [ "$compiler" = "mcs" ]; then
      if echo "$output" | grep -q "error(s)"; then
        echo " \"status\": \"0\", " >>/tmp/result.json
        echo " \"message\": \"Compilation Failed\", " >>/tmp/result.json
        echo "\"stdin\": \"$input\"," >>/tmp/result.json
        echo -n "\"stdout\": \"" >>/tmp/result.json
        echo -n "$output" | base64 | tr -d '\n' >>/tmp/result.json
        echo "\"}]}" >>/tmp/result.json
      fi
      exit
    fi
    # Nếu không có lỗi, mã hoá output và ghi vào file
    echo " \"status\": \"1\", " >>/tmp/result.json
    echo " \"message\": \"Compilation Succeeded\", " >>/tmp/result.json
    echo "\"stdin\": \"$input\"," >>/tmp/result.json
    echo -n "\"stdout\": \"" >>/tmp/result.json
    echo -n "$output" | base64 | tr -d '\n' >>/tmp/result.json
    echo "\"," >>/tmp/result.json
  else
    # Nếu có lỗi, ghi lỗi vào file
    echo " \"status\": \"0\", " >>/tmp/result.json
    echo " \"message\": \" Compilation Failed\", " >>/tmp/result.json
    echo "\"stdin\": \"$input\"," >>/tmp/result.json
    echo -n "\"error\": \"" >>/tmp/result.json
    echo -n "$output" | base64 | tr -d '\n' >>/tmp/result.json
    echo "\"," >>/tmp/result.json
  fi

  runtime=$(echo "$END - $START" | bc)

  echo "\"time\": \"$runtime\"" >>/tmp/result.json
  echo "}]}" >>/tmp/result.json
  ;;
*)
  echo "Unknown action: $action"
  # Xử lý trường hợp không xác định được action
  ;;
esac
