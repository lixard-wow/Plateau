#!/usr/bin/env bash
LUA="${LUA:-$(command -v lua5.1 || command -v lua51 || echo lua5.1)}"
status=0
for test in tests/*_test.lua; do
    output=$("$LUA" "$test" 2>&1)
    code=$?
    failed=$(echo "$output" | grep -c "^FAIL")
    passed=$(echo "$output" | grep -c "^PASS")
    if [ "$code" -ne 0 ]; then
        echo "$test: $passed passed, $failed failed, CRASHED"
        echo "$output" | grep -v "^PASS" | tail -5
        status=1
        continue
    fi
    echo "$test: $passed passed, $failed failed"
    echo "$output" | grep "^FAIL"
    [ "$failed" -gt 0 ] && status=1
done
exit $status
