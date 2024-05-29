#!/usr/bin/env sysbench

require("oltp_benchmarks")

function prepare_custom_transaction_on_two_tables_using_shard_key()
   requested = {}
   requested[1] = con:prepare("UPDATE sbtest1 SET c = ? WHERE id = ?")
   requested[2] = con:prepare("UPDATE sbtest2 SET c = ? WHERE k = ?")

   param = {}
   for p = 1, #requested do
	  param[p] = {}

	  param[p][1] = requested[p]:bind_create(sysbench.sql.type.CHAR, 120)
	  param[p][2] = requested[p]:bind_create(sysbench.sql.type.INT)

	  requested[p]:bind_param(unpack(param[p]))
   end
end

function execute_custom_transaction_on_two_tables_using_shard_key()
   for p = 1, #requested do
	  param[p][1]:set(get_c_value())
	  param[p][2]:set(get_id())
	  requested[p]:execute()
   end
end

function prepare_custom()
   prepare_custom_transaction_on_two_tables_using_shard_key()
end

function execute_custom()
   execute_custom_transaction_on_two_tables_using_shard_key()
end
