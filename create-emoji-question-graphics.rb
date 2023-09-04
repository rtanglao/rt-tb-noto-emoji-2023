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
logger = Logger.new($stderr)
logger.level = Logger::DEBUG
MACOS_EMOJI = '🍎'.freeze
LINUX_EMOJI = '🐧'.freeze
WINDOWS_EMOJI = '🪟'.freeze
UNKNOWN_EMOJI = '❓'.freeze

def get_os_emoji(content)
  case content
  when /(mac-os|os-x|osx|macos|ventura|macos|mac os)/i
    "#{MACOS_EMOJI} #{$1}"
  when /(linux|ubuntu|redhat|debian|bsd)/i
    "#{LINUX_EMOJI} #{$1}"
  when /(windows-7|windows-8|windows-10|windows-11|windows 10\
    win 10|windows 11|win11|windows 7|win 7|windows 8|win 8)/i
    "#{WINDOWS_EMOJI} #{$1}"
  else
    "#{UNKNOWN_EMOJI}"
  end
end

if ARGV.length < 2
  puts "usage: #{$PROGRAM_NAME} <questions_CSV_file> <answers_CSV_file>"
  exit
end

all_questions = CSV.read(ARGV[0], headers: true)
all_answers = CSV.read(ARGV[1], headers: true)
all_questions.each do |q|
  content = "#{q['title']} #{q['content']}"
  question_creator = q['creator']
  all_answers.each do |a|
    content += " #{a['content']}" if a['creator'] == question_creator
  end
  content += " #{q['tags']}"
  emoji = get_os_emoji(content)
  image = Magick::Image.read(\
  "pango:<span font='Noto Color Emoji'>\
  <b>id:</b>#{q['id']} \r\
  <b>OS:</b>#{emoji}</span>").first
image.write('pango_sample1.png')
ap content
exit
end