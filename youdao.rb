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

require "rubygems"
require "json"
require "net/http"
require 'open-uri'
require 'nokogiri'
require "./db.rb"
require "./style"

DOWNLOAD_PATH = File.join File.dirname(File.realpath(__FILE__)), "download"


def down_media(url, file)
  # download phonetic mp3 file
  begin
    if ! File.exists? DOWNLOAD_PATH then
      Dir.mkdir DOWNLOAD_PATH
    end
    if ! File.directory? DOWNLOAD_PATH then
      return url
    end
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new uri

      http.request request do |response|
        open(File.join(DOWNLOAD_PATH, file), 'wb') do |io|
          response.read_body do |chunk|
            io.write chunk
          end
        end
      end
    end
  rescue Exception => e
    p e
    return url
  end
  file
end

class Youdao
  def initialize()
    @url = "http://dict.youdao.com/search?le=eng&q="
    @db = Database::DBManager.new
    if ! @db.table_exists?
      @db.create_table
    end
  end

  def close_db
    @db.close
  end

  def query(word, is_chinese=False)
    begin
      result = query_sql word
      if !result then
        url = "#{@url}#{URI.encode(word)}"
        page = Nokogiri::HTML(open(url))
        result = parse_xpath page, is_chinese
      end
    rescue Exception => e
      puts e
      return
    end
    return result
  end

  def parse_res(result)
    if !result then
      return
    end
    if !result[:pronounce].empty? then
      MyStyle::color_puts "音标", MyStyle::NORMAL_RED
      result[:pronounce].each do |x|
        puts "\t%s" % (x.strip.gsub("\t", ':'))
      end
    end
    if !result[:trans].empty? then
      MyStyle::color_puts "基本翻译", MyStyle::NORMAL_RED
      result[:trans].each do |x|
        puts "\t#{x}"
      end
    end
    if !result[:web_trans].empty? then
      MyStyle::color_puts "网络翻译", MyStyle::NORMAL_RED
      result[:web_trans].each do |x|
        puts "\t#{x}"
      end
    end
    if !result[:word_group].empty? then
      MyStyle::color_puts "词组", MyStyle::NORMAL_RED
      result[:word_group].each do |x|
        puts "\t#{x}"
      end
    end
  end

  private
  def query_sql(word)
    @db.select word
  end

  def insert_sql(result)
    @db.insert result
  end

  def parse_xpath(page, is_chinese)
    res = {}
    result = page.xpath('//div[@id="results"]/div[@id="results-contents"]')


    basic = result.xpath('div[@id="phrsListTab"]')
    # keyword
    search_keyword = basic.xpath('h2/span[@class="keyword"]')
    if not search_keyword.empty? then
      key = search_keyword[0]
      res[:keyword] = key.text.strip
    else
      res[:keyword] = ""
    end

    # pronounce
    pronounce = []
    voice_arr = []
    word_pronounce = basic.xpath('h2/div[@class="baav"]/span')
    word_pronounce.each do |x|
      phonetic = x.xpath('span')
      voice = x.xpath('a')
      # 下载音标音频文件
      #voice_url = down_media(
        #"http://dict.youdao.com/dictvoice?audio=#{voice.attr('data-rel')}",
        #"%f.mp3" % Time.now)
      voice_url = "http://dict.youdao.com/dictvoice?audio=#{voice.attr('data-rel')}"
      pronounce.push "#{x.child.to_s.strip}\t#{phonetic.text}"
      voice_arr.push voice_url
    end
    res[:pronounce] = pronounce
    res[:voice] = voice_arr

    # translation
    translation = []
    if is_chinese then
      trans_group = basic.xpath('div/ul/p')
      trans_group.each do |x|
        text = ''
        x.xpath('span/a').each do |t|
          text += t.text + " "
        end
        translation.push text.strip
      end
    else
      trans = basic.xpath('div/ul/li')
      trans.each do |x|
        translation.push x.text.strip
      end
    end
    res[:trans] = translation

    # web translation
    web_translation = []
    webtrans = result.xpath('div[@id="webTrans"]/div/div[@id="tWebTrans"]')

    detail = webtrans.xpath('div[contains(@class,"wt-container")]')
    detail.each do |x|
      s = x.xpath('div/span')
      web_translation.push s.text.strip
    end
    res[:web_trans] = web_translation

    word_group = []
    phrase = webtrans.xpath('div[@id="webPhrase"]/p[@class="wordGroup"]')
    phrase.each do |x|
      s = x.xpath('span')
      word_group.push "#{s.text.strip}\t#{x.children[-1].to_s.strip.gsub(/\n\s+/, '')}"
    end
    res[:word_group] = word_group
    if res[:keyword] != "" then
      insert_sql(res)
    end
    res
  end
end

if caller.length == 0 then
  y = Youdao.new
  while true
    print ">>>"
    word = gets
    if ! word
      exit
    end
    if word.strip! == ""
      redo
    end
    y.parse_res (y.query word.downcase, word.match(/\p{Han}+/u))
    MyStyle::color_puts '-'*45, MyStyle::NORMAL_GREEN
  end

  y.close_db
end
__END__

