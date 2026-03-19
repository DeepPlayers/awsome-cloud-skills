#!/bin/bash
# 输出格式化工具

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 使用帮助
usage() {
    cat << EOF
CLI输出格式化工具

用法:
  $0 <command> [options]

命令:
  table <json> <cols> <rows>    表格化输出
  json <json>                   格式化JSON
  cols <json> <fields>          提取指定字段
  query <json> <jmespath>       JMESPath查询

示例:
  # 表格化输出
  aliyun ecs DescribeInstances | $0 table 'InstanceId,InstanceName,Status' 'Instances.Instance[]'

  # 格式化JSON
  aliyun ecs DescribeRegions | $0 json

  # 提取字段
  aliyun ecs DescribeRegions | $0 cols 'RegionId,LocalName'

  # JMESPath查询
  aliyun ecs DescribeInstances | $0 query 'Instances.Instance[?Status==`Running`].InstanceId'
EOF
}

# 表格化输出
format_table() {
    local input="$1"
    local cols="$2"
    local rows="$3"
    
    if [[ -z "$input" ]]; then
        input=$(cat)
    fi
    
    if [[ -z "$cols" ]] || [[ -z "$rows" ]]; then
        echo "$input" | jq -r
        return
    fi
    
    echo "$input" | jq -r --arg cols "$cols" --arg rows "$rows" '
        def format_table:
            . as $input |
            ($cols | split(",")) as $columns |
            $input |
            getpath($rows | split(".")) |
            if type == "array" then
                .[]
            else
                .
            end |
            . as $item |
            [
                $columns[] |
                . as $col |
                ($item | getpath($col | split("."))) | 
                if . == null then "" else . end |
                tostring
            ] |
            @tsv
        ;
        {
            cols: ($cols | split(",")),
            rows: [getpath($rows | split(".")) | if type == "array" then .[] else . end]
        } |
        .cols as $cols |
        .rows[] |
        . as $item |
        [$cols[] | ($item | getpath(. | split("."))) // "" | tostring] |
        @tsv
    ' | column -t -s $'\t'
}

# 格式化JSON
format_json() {
    local input="$1"
    
    if [[ -z "$input" ]]; then
        input=$(cat)
    fi
    
    echo "$input" | jq '.'
}

# 提取字段
extract_cols() {
    local input="$1"
    local fields="$2"
    
    if [[ -z "$input" ]]; then
        input=$(cat)
    fi
    
    if [[ -z "$fields" ]]; then
        echo "$input" | jq '.'
        return
    fi
    
    echo "$input" | jq -r --arg fields "$fields" '
        ($fields | split(",")) as $cols |
        if type == "array" then
            .[] | [.[$cols[]]] | @tsv
        else
            [.[$cols[]]] | @tsv
        end
    ' | column -t -s $'\t'
}

# JMESPath查询
jmespath_query() {
    local input="$1"
    local query="$2"
    
    if [[ -z "$input" ]]; then
        input=$(cat)
    fi
    
    if [[ -z "$query" ]]; then
        echo "$input" | jq '.'
        return
    fi
    
    # 使用jq实现简单的JMESPath查询
    echo "$input" | jq -r "$query"
}

# 主函数
main() {
    local command="$1"
    shift || true
    
    case "$command" in
        table)
            local json="$1"
            local cols="$2"
            local rows="$3"
            if [[ -z "$json" ]] || [[ "$json" == "-" ]]; then
                json=$(cat)
            fi
            format_table "$json" "$cols" "$rows"
            ;;
        json)
            local json="$1"
            if [[ -z "$json" ]] || [[ "$json" == "-" ]]; then
                json=$(cat)
            fi
            format_json "$json"
            ;;
        cols)
            local json="$1"
            local fields="$2"
            if [[ -z "$json" ]] || [[ "$json" == "-" ]]; then
                json=$(cat)
            fi
            extract_cols "$json" "$fields"
            ;;
        query)
            local json="$1"
            local query="$2"
            if [[ -z "$json" ]] || [[ "$json" == "-" ]]; then
                json=$(cat)
            fi
            jmespath_query "$json" "$query"
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            # 默认从标准输入读取并格式化
            format_json "$(cat)"
            ;;
    esac
}

main "$@"
