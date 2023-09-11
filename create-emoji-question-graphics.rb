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
require 'facets/enumerable/find_yield'
require_relative 'regexes'

logger = Logger.new($stderr)
logger.level = Logger::DEBUG

def get_emojis_from_regex(emoji_regex, content, _logger)
  emoji_regex.find_yield({ emoji: UNKNOWN_EMOJI, matching_text: nil }) \
  { |er| { emoji: er[:emoji], matching_text: Regexp.last_match(1) } if content =~ er[:regex] }
end

def format_emoji_content(content, color, label)
  "\r<span foreground='#{color}' font='Latin Modern Roman Demi'>\
  <b>#{label}:</b></span>\
  #{content[:emoji]}
  <span font='Latin Modern Roman Demi'>#{content[:matching_text]}</span>"
end

if ARGV.length < 2
  puts "usage: #{$PROGRAM_NAME} <questions_CSV_file> <answers_CSV_file>"
  exit
end

all_questions = CSV.read(ARGV[0], headers: true)
all_answers = CSV.read(ARGV[1], headers: true)
fn_str = 'tb-question-emoji-%<id>s-%<yyyy>4.4d-%<mm>2.2d-%<dd>2.2d'
fn_str += '-%<hh>2.2d-%<min>2.2d-%<ss>2.2d.png'
all_questions.each do |q|
  content = "#{q['title']} #{q['content']}"
  question_creator = q['creator']
  all_answers.each do |a|
    content += " #{a['content']}" if a['creator'] == question_creator
  end
  content += " #{q['tags']}"
  id = q['id']
  logger.debug "id: #{id}"
  os_emoji_content = get_emojis_from_regex(OS_EMOJI_ARRAY, content, logger)
  pango_str = "pango:<span font='Noto Color Emoji'>\
  <span foreground='deeppink' font='Latin Modern Roman Demi'><b>id:</b>#{id}</span>"
  pango_str += format_emoji_content(os_emoji_content, 'black', 'OS')
  email_emoji_content = get_emojis_from_regex(EMAIL_EMOJI_ARRAY, content, logger)
  pango_str += format_emoji_content(email_emoji_content, 'darkblue', 'Email')
  av_emoji_content = get_emojis_from_regex(ANTIVIRUS_EMOJI_ARRAY, content, logger)
  pango_str += format_emoji_content(av_emoji_content, 'darkred', 'AV')
  userchrome_emoji_content = get_emojis_from_regex(USERCHROME_EMOJI_ARRAY, content, logger)
  pango_str += format_emoji_content(userchrome_emoji_content, 'darkgreen', 'userChrome')
  pango_str += '</span>'
  created = Time.parse(q['created']).utc
  image = Magick::Image.read(pango_str).first
  filename = format(
    fn_str,
    id: id, yyyy: created.year, mm: created.month, dd: created.day,
    hh: created.hour, min: created.min, ss: created.sec
  )
  image.write(filename)
  logger.debug "width: #{image.columns}"
  logger.debug "height: #{image.rows}"

end
