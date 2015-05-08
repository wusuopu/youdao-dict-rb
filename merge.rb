#!/usr/bin/env ruby
#-*- coding:utf-8 -*-

# Copyright (C) 2012 ~ 2013 Deepin, Inc.
#               2012 ~ 2013 Long Changjin
# 
# Author:     Long Changjin <admin@longchangjin.cn>
# Maintainer: Long Changjin <admin@longchangjin.cn>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# 将多份词库的db文件进行合并

require "sqlite3"

def export dbname
  db = SQLite3::Database.new(dbname)
  select_state = db.prepare "SELECT * FROM word;"
  record_count = db.execute("select count(*) from word;")[0][0]

  select_state.execute.each_with_index do |result, index|
    yield result
    puts "importing #{index+1} / #{record_count}"
  end

  select_state.close
  db.close
end

if caller.length == 0
  if ARGV.length == 0
    puts "Usage: ruby merge.rb in-db [out-db]"
    puts "It will merge the data from in-db to out-db"
    exit 1
  end

  in_file = ARGV[0]
  out_file = ARGV[1] || 'word.db'

  unless File.exists? in_file
    puts "file '#{in_file}' is not exists."
    exit 2
  end
  unless File.exists? out_file
    puts "file '#{out_file}' is not exists."
    exit 2
  end

  out_db = SQLite3::Database.new(out_file)
  query_state = out_db.prepare "SELECT * FROM word WHERE keyword=(?);"
  insert_state = out_db.prepare "insert into word (keyword, pronounce, voice, trans, web_trans, word_group) values (?, ?, ?, ?, ?, ?)"

  export in_file do |record|
    if query_state.execute(record[1]).first
      next
    end
    insert_state.execute(*record[1..-1])
  end

  query_state.close
  insert_state.close
  out_db.close
end
