#!/usr/bin/ruby
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

module Database
  require "sqlite3"
  require "json"
  
  FILE_NAME = "word.db"

  class DBManager

    def initialize
      @db = SQLite3::Database.new(FILE_NAME) 
    end

    def table_exists?
      table = false
      @db.execute( "SELECT name FROM sqlite_master WHERE type='table';" ) do |row|
        if row[0] == "word" then
          table = true
          break
        end
      end
      table
    end

    def create_table
      @db.execute(''' 
      CREATE TABLE  IF NOT EXISTS "main"."word" (
          "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          "keyword" varchar(150) NOT NULL,
          "pronounce" varchar(100),
          "voice" TEXT,
          "trans" TEXT,
          "web_trans" TEXT,
          "word_group" TEXT
      );
      ''')
    end

    def insert(data)
      if ! data.include? :keyword || data[:keyword] == "" then
        return nil
      end
      keyword = data[:keyword].downcase
      begin
        pronounce = data[:pronounce].to_json
      rescue
        pronounce = "[]"
      end
      begin
        voice = data[:voice].to_json
      rescue
        voice = "[]"
      end
      begin
        trans = data[:trans].to_json
      rescue
        trans = "[]"
      end
      begin
        web_trans = data[:web_trans].to_json
      rescue
        web_trans = "[]"
      end
      begin
        word_group = data[:word_group].to_json
      rescue
        word_group = "[]"
      end
      # TODO check sql syntax
      sql = """
        insert into word (keyword, pronounce, voice, trans, web_trans, word_group)
        values ('%s', '%s', '%s', '%s', '%s', '%s');""" % [ keyword, pronounce, voice, trans, web_trans, word_group ]
      @db.execute(sql)
    end

    def select(word)
      @db.execute( "SELECT * FROM word WHERE keyword='#{word}';" ) do |row|
        res = {}
        res[:keyword] = row[1]
        begin
          res[:pronounce] = JSON.parse row[2]
        rescue
          res[:pronounce] = []
        end

        begin
          res[:voice] = JSON.parse row[3]
        rescue
          res[:voice] = []
        end

        begin
          res[:trans] = JSON.parse row[4]
        rescue
          res[:trans] = []
        end

        begin
          res[:web_trans] = JSON.parse row[5]
        rescue
          res[:web_trans] = []
        end

        begin
          res[:word_group] = JSON.parse row[6]
        rescue
          res[:word_group] = []
        end
        return res
      end
      nil
    end

    def close
      @db.close
    end
  end

end
