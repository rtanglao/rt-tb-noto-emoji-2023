#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'amazing_print'
require 'json'
require 'time'
require 'date'
require 'csv'
require 'logger'
require 'rmagick'
require 'pry'
logger = Logger.new($stderr)
logger.level = Logger::DEBUG
MACOS_EMOJI = '🍎'.freeze
LINUX_EMOJI = '🐧'.freeze
WINDOWS_EMOJI = '🪟'.freeze
UNKNOWN_EMOJI = '❓'.freeze

def get_os_emoji(content, logger)
  logger.debug content
  case content
  when /(mac-os|os-x|osx|macos|ventura|macos|mac os|panther|snow leopard|leopard|jaguar|monterey|mavericks|sonoma|sierra|el capitan|mojave|catalina|big sur|yosemite)/i
    "#{MACOS_EMOJI} #{Regexp.last_match(1)}"
  when /(linux|ubuntu|redhat|debian|bsd)/i
    "#{LINUX_EMOJI} #{Regexp.last_match(1)}"
  when /(windows-7|windows-8|windows-10|windows-11|windows 10|\
    win 10|windows 11|win 11|windows 7|win 7|windows 8|win 8|\
    win7|win10|win8|win11)/i
    "#{WINDOWS_EMOJI} #{Regexp.last_match(1)}"
  else
    UNKNOWN_EMOJI
  end
end

if ARGV.length < 2
  puts "usage: #{$PROGRAM_NAME} <questions_CSV_file> <answers_CSV_file>"
  exit
end

all_questions = CSV.read(ARGV[0], headers: true)
all_answers = CSV.read(ARGV[1], headers: true)
fn_str = 'tb-question-emoji-%<id>s-%<yyyy>4.4d-%<mm>2.2d-%<dd>2.2d'
fn_str += '.png'
all_questions.each do |q|
  content = "#{q['title']} #{q['content']}"
  question_creator = q['creator']
  all_answers.each do |a|
    content += " #{a['content']}" if a['creator'] == question_creator
  end
  content += " #{q['tags']}"
  id = q['id']
  logger.debug "id: #{id}"
  emoji = get_os_emoji(content, logger)
  created = Time.parse(q['created']).utc
  image = Magick::Image.read(\
    "pango:<span font='Noto Color Emoji'>\
  <span foreground='pink'><b>id:</b></span>#{id} \r\
  <b>OS:</b>#{emoji}</span>"
  ).first
  filename = format(
    fn_str,
    id: id, yyyy: created.year, mm: created.month, dd: created.day
  )
  image.write(filename)
end
