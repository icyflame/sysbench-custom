#!/usr/bin/env sysbench

-- Source: Basic script provided in https://www.percona.com/blog/creating-custom-sysbench-scripts/

if sysbench.cmdline.command == nil then
   error("Command is required. Supported commands: run, help")
end

-- Command line options
sysbench.cmdline.options = {
   table_size =
      {"Number of rows per table", 10000},
   tables =
      {"Number of tables in the database", 1},
   table_min_id =
      {"Minimum ID to use within the table. Useful when AUTO_INCREMENT is not 0 and the table_size number of rows are not between id = 1 and id = table_size", 0},
}

local function get_id()
   return sysbench.rand.default(1, sysbench.opt.table_size) + sysbench.opt.table_min_id
end

local c_value_template = "###########-###########-###########-"

function get_c_value()
   return sysbench.rand.string(c_value_template)
end

-- Called by sysbench one time to initialize this script
function thread_init()

  -- Create globals to be used elsewhere in the script

  -- drv - initialize the sysbench mysql driver
  drv = sysbench.sql.driver()

  -- con - represents the connection to MySQL
  con = drv:connect()

  -- custom
  stmt = {}
  prepare_statements()
end

function prepare_statements()
   prepare_begin()
   prepare_commit()

   -- Run our custom statements
   prepare_custom()
end

-- Called by sysbench when script is done executing
function thread_done()
  -- Disconnect/close connection to MySQL
  con:disconnect()
end

function begin()
   stmt.begin:execute()
end

function commit()
   stmt.commit:execute()
end

function prepare_begin()
   stmt.begin = con:prepare("BEGIN")
end

function prepare_commit()
   stmt.commit = con:prepare("COMMIT")
end

-- Called by sysbench for each execution
function event()
   begin()

   execute_custom()

   commit()
end

-- This file demonstrates how to write a custom benchmark
-- The functions `prepare_custom` and `execute_custom` are automatically being called.
--
-- The prepare_custom function should declare variables which will store the prepared
-- SQL statements, and a variable which will be used to store the parameters that
-- are required for the statement.
--
-- The execute_custom function should set appropriate parameters in the param varaible
-- and then, call "execute" on the prepared statement
--
-- All of this will happen inside a single transaction.
--
-- The following two functions are examples which show how a single row can be updated:
function prepare_custom_update_existing_row()
   requested = con:prepare("UPDATE sbtest1 SET c = ? WHERE id = ?")

   param = {}
   param[1] = requested:bind_create(sysbench.sql.type.CHAR, 120)
   param[2] = requested:bind_create(sysbench.sql.type.INT)

   requested:bind_param(unpack(param))
end

function execute_custom_update_existing_row()
   param[1]:set(get_c_value())
   param[2]:set(get_id())
   requested:execute()
end
