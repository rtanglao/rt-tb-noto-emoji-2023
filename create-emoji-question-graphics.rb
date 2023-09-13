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

VERTICAL = true
HORIZONTAL = false

def append_image(image_to_be_appended, image, vertical_or_horizontal)
  image_list = Magick::ImageList.new(image_to_be_appended, image)
  appended_images = image_list.append(vertical_or_horizontal)
  appended_images.write(image)
end

def get_emojis_from_regex(emoji_regex, content, _logger)
  emoji_regex.find_yield({ emoji: UNKNOWN_EMOJI, matching_text: nil }) \
  { |er| { emoji: er[:emoji], matching_text: Regexp.last_match(1) } if content =~ er[:regex] }
end

def format_emoji_content(content, color, label, logger)
  logger.debug "matching_text: #{content[:matching_text]}"
  str = "\r<span foreground='#{color}' font='Latin Modern Roman Demi'><b>#{label}:</b>"
  str += "</span>#{content[:emoji]}"
  str + "<span font='Latin Modern Roman Demi'>#{content[:matching_text]}</span>"
end

if ARGV.length < 2
  puts "usage: #{$PROGRAM_NAME} <questions_CSV_file> <answers_CSV_file>"
  exit
end

all_questions = CSV.read(ARGV[0], headers: true)
all_answers = CSV.read(ARGV[1], headers: true)
fn_str = 'tb-question-emoji-%<id>s-%<yyyy>4.4d-%<mm>2.2d-%<dd>2.2d'
fn_str += '-%<hh>2.2d-%<min>2.2d-%<ss>2.2d'
fn_str += '-%<width>4.4dx%<height>4.4d.png'
current_hour = 30
daily_image = false
hourly_image = false
HOURLY_STR = "hourly-tb-emoji-%<yyyy>4.4d-%<mm>2.2d-%<dd>2.2d-%<hh>2.2d.png".freeze
all_questions.each do |q|
  content = "#{q['title']} #{q['content']}"
  question_creator = q['creator']
  all_answers.each do |a|
    content += " #{a['content']}" if a['creator'] == question_creator
  end
  content += " #{q['tags']}"
  id = q['id']
  logger.debug "id: #{id}"
  created = Time.parse(q['created']).utc
  hour = created.hour
  min = created.min
  current_hour = hour if current_hour.nil?
  year = created.year
  month = created.month
  day = created.day

  os_emoji_content = get_emojis_from_regex(OS_EMOJI_ARRAY, content, logger)
  created_str = "➖➖<span font='Latin Modern Roman Demi'><b>#{sprintf("%2.2d:%2.2d", hour, min)}</b></span>➖➖"
  pango_str = "pango:<span font='Noto Color Emoji'>#{created_str}\r"
  pango_str += "<span foreground='deeppink' font='Latin Modern Roman Demi'><b>id:</b>#{id}</span>"
  pango_str += format_emoji_content(os_emoji_content, 'black', 'OS', logger)
  topics_emoji_content = get_emojis_from_regex(TOPICS_EMOJI_ARRAY, q['tags'], logger)
  pango_str += format_emoji_content(topics_emoji_content, 'purple', 'Topic', logger)
  email_emoji_content = get_emojis_from_regex(EMAIL_EMOJI_ARRAY, content, logger)
  pango_str += format_emoji_content(email_emoji_content, 'darkblue', 'Email', logger)
  av_emoji_content = get_emojis_from_regex(ANTIVIRUS_EMOJI_ARRAY, content, logger)
  pango_str += format_emoji_content(av_emoji_content, 'darkred', 'AV', logger)
  userchrome_emoji_content = get_emojis_from_regex(USERCHROME_EMOJI_ARRAY, content, logger)
  pango_str += format_emoji_content(userchrome_emoji_content, 'darkgreen', 'userChrome', logger)
  pango_str += '\r➖➖➖➖➖➖</span>'
  image = Magick::Image.read(pango_str).first
  filename = format(
    fn_str,
    id: id, yyyy: year, mm: month, dd: day,
    hh: hour, min: min, ss: created.sec,
    width: image.columns,
    height: image.rows
  )
  hourly_filename = format(
    HOURLY_STR, yyyy: year, mm: month, dd: day, hh: hour
  )
  image.write(filename)
  logger.debug "width: #{image.columns}"
  logger.debug "height: #{image.rows}"
  logger.debug "filename: #{filename}"
  logger.debug "hourly_filename: #{hourly_filename}"

  # FIXME: Assume question ids are ascending and assume ids are ascending by time
  # append image to hourly image if it exists else create hourly image
  if hour == current_hour
    append_image(filename, hourly_filename, VERTICAL)
    exit
  else
    logger.debug 'Copying filename to hourly_filename'
    FileUtils.copy_file(filename, hourly_filename)
    current_hour = hour
  end
  # If daily image isn't new, append hourly image to previous hourly images OR
  # once a new day is reached or we reach end of questions,
  # create daily for previous day from previous day's hourly image.
end
