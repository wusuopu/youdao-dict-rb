#!/usr/bin/env ruby
#-*- coding:utf-8 -*-

require "gtk2"
require "./youdao.rb"


class MainWin < Gtk::Window
  def initialize()
    super

    signal_connect "destroy" do
      Gtk.main_quit
    end
    set_title "有道词典简易版"
    set_size_request 500, 300
    set_resizable false
    set_window_position Gtk::Window::POS_CENTER
    @youdao = Youdao.new

    init_ui
  end

  def init_ui
    hbox = Gtk::HBox.new false
    entry = Gtk::Entry.new
    button = Gtk::Button.new "搜索"
    hbox.pack_start entry
    hbox.pack_start button, false, false

    textview = Gtk::TextView.new
    textview.editable = false

    statusbar = Gtk::Statusbar.new
    statusbar.pack_start(Gtk::Label.new("作者：龙昌  http://www.xefan.com"), false, false)

    vbox = Gtk::VBox.new false
    vbox.pack_start hbox, false, false
    vbox.pack_start textview
    vbox.pack_start statusbar, false, false

    set_border_width 5

    button.signal_connect "clicked" do
      puts entry.text, entry.text.encoding
      word = entry.text
      if word.strip! != "" then
        button.sensitive = false
        Thread.start {
          query button, word
        }
      end
    end
    add vbox
  end

  private
  def query(bt, word)
    @youdao.query word.downcase, word.match(/\p{Han}+/u)
    bt.sensitive = true
  end
end


if __FILE__ == $0 then
  Gtk.init
  win = MainWin.new
  win.show_all
  Gtk.main
end
