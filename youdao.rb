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
require "./style"


def down_media(uri, file)
  # download phonetic mp3 file
  uri = URI(uri)
  Net::HTTP.start(uri.host, uri.port) do |http|
    request = Net::HTTP::Get.new uri

    http.request request do |response|
      open file, 'w' do |io|
        response.read_body do |chunk|
          io.write chunk
        end
      end
    end
  end
  file
end

class Youdao
  def initialize()
    @url = "http://dict.youdao.com/search?le=eng&q="
  end

  def request(word)
    url = "#{@url}#{URI.encode(word)}"
    Nokogiri::HTML(open(url))
  end

  def query(word)
    begin
      page = self.request word
    rescue Exception => e
      puts e
      return
    end
    result = page.xpath('//div[@id="results"]/div[@id="results-contents"]')


    basic = result.xpath('div[@id="phrsListTab"]')
    # keyword
    keyword = basic.xpath('h2/span[@class="keyword"]')
    if not keyword.empty? then
      key = keyword[0]
      printf("keyword:\t'%s'\n", key.text)
    end
    puts "-" * 20

    # pronounce
    pronounce = basic.xpath('h2/div[@class="baav"]/span')
    pronounce.each do |x|
      phonetic = x.xpath('span')
      voice = x.xpath('a')
      voice_url = "http://dict.youdao.com/dictvoice?audio=#{voice.attr('data-rel')}"
      printf("%s %s %s\n",
             x.child.to_s.strip,
             phonetic.text,
             voice_url)
    end
    puts "-" * 20

    # translation
    trans = basic.xpath('div/ul/li')
    trans.each do |x|
      p x.text.strip
    end

    puts "-" * 30

    # web translation
    webtrans = result.xpath('div[@id="webTrans"]/div/div[@id="tWebTrans"]')

    detail = webtrans.xpath('div[contains(@class,"wt-container")]')
    puts "网络释义"
    detail.each do |x|
      s = x.xpath('div/span')
      p s.text.strip
    end
    puts "-" * 20

    puts "短语"
    phrase = webtrans.xpath('div[@id="webPhrase"]/p[@class="wordGroup"]')
    phrase.each do |x|
      s = x.xpath('span')
      printf("'%s': '%s'\n",
             s.text.strip,
             x.children[-1].to_s.strip.gsub(/\n\s+/, ""))
    end
  end
end

#p down_media 'http://dict.youdao.com/dictvoice?audio=b', 'test'
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
  if word.match(/\p{Han}+/u)
    MyStyle::color_puts '仅支持英译汉!', MyStyle::NORMAL_RED
    redo
  end
  y.query word
  MyStyle::color_puts '-'*45, MyStyle::NORMAL_GREEN
end

__END__

