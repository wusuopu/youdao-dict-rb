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


module MyStyle
  NORMAL_BLACK = 0
  NORMAL_RED = 1
  NORMAL_GREEN = 2
  NORMAL_YELLOW = 3
  NORMAL_BLUE = 4
  NORMAL_MAGENTA = 5
  NORMAL_CYAN = 6
  NORMAL_WHITE = 7
  BRIGHT_BLACK = 8
  BRIGHT_RED = 9
  BRIGHT_GREEN = 10
  BRIGHT_YELLOW = 11
  BRIGHT_BLUE = 12
  BRIGHT_MAGENTA = 13
  BRIGHT_CYAN = 14
  BRIGHT_WHITE = 15

  BG_ESCAPE = "\x1b[48;5;%dm"
  FG_ESCAPE = "\x1b[38;5;%dm"
  END_ESCAPE = "\x1b[0m"

  def color_puts(str, fg=nil, bg=nil)
    if fg
      fg = FG_ESCAPE % fg
      str = "#{fg}#{str}#{END_ESCAPE}"
    end
    if bg
      bg = BG_ESCAPE % bg
      str = "#{bg}#{str}#{END_ESCAPE}"
    end
    puts str
  end

  module_function :color_puts
end
