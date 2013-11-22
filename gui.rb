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
    set_size_request 550, 350
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
    sw = Gtk::ScrolledWindow.new
    sw.add textview

    statusbar = Gtk::Statusbar.new
    statusbar.pack_start(Gtk::Label.new("作者：龙昌  http://www.xefan.com"), false, false)

    vbox = Gtk::VBox.new false
    vbox.pack_start hbox, false, false
    vbox.pack_start sw
    vbox.pack_start statusbar, false, false

    set_border_width 5

    button.signal_connect "clicked" do
      word = entry.text
      if word.strip! != "" then
        button.sensitive = false
        Thread.start {
          query button, word, textview
        }
      end
    end
    add vbox

    accel = Gtk::AccelGroup.new
    add_accel_group accel
    button.add_accelerator 'clicked', accel, 65293, 0, Gtk::ACCEL_VISIBLE   # Return
    button.add_accelerator 'clicked', accel, 65421, 0, Gtk::ACCEL_VISIBLE   # KP_ENTER
  end

  private
  def query(bt, word, textview)
    result = @youdao.query word.downcase, word.match(/\p{Han}+/u)
    bt.sensitive = true
    if result then
      string = ""
      if !result[:pronounce].empty? then
        string += "音标:\n"
        result[:pronounce].each do |x|
          string += "\t%s\n" % (x.strip.gsub("\t", ':'))
        end
      end
      if !result[:trans].empty? then
        string += "\n基本翻译:\n"
        result[:trans].each do |x|
          string += "\t#{x}\n"
        end
      end
      if !result[:web_trans].empty? then
        string += "\n网络翻译:\n"
        result[:web_trans].each do |x|
          string += "\t#{x}\n"
        end
      end
      if !result[:word_group].empty? then
        string += "\n词组:\n"
        result[:word_group].each do |x|
          string += "\t#{x}\n"
        end
      end
      textview.buffer.text = string
    end
  end
end


if __FILE__ == $0 then
  Gtk.init
  win = MainWin.new
  win.show_all
  Gtk.main
end
