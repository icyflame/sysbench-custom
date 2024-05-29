#!/usr/bin/env sysbench

require("oltp_benchmarks")

function prepare_custom_point_selects()
   requested = con:prepare("SELECT * FROM sbtest1 WHERE id = ?")
   parameter = requested:bind_create(sysbench.sql.type.INT)
   requested:bind_param(parameter)
end

function execute_custom_point_selects()
   parameter:set(get_id())
   requested:execute()
end

function prepare_custom()
   prepare_custom_point_selects()
end

function execute_custom()
   execute_custom_point_selects()
end
