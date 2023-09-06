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
GMAIL_EMOJI = '📮'.freeze
MICROSOFT_EMAIL_EMOJI = '📧'.freeze
PROTONMAIL_EMOJI = '📨'.freeze
FASTMAIL_EMOJI = '✉️'.freeze
KASPERSKY_EMOJI = '🇰'.freeze
BITDEFENDER_EMOJI = '🇧'.freeze
AVAST_EMOJI = '🅰'.freeze
AVIRA_EMOJI = '🇦'.freeze
ZONEALARM_EMOJI = '🇿'.freeze
COMODO_EMOJI = '🇨'.freeze
ESET_EMOJI = '🇪'.freeze
FSECURE_EMOJI = '🇫'.freeze
MALWAREBYTES_EMOJI = '🇲'.freeze
MCAFEE_EMOJI = 'Ⓜ'.freeze
NORTON_EMOJI = '🇳'.freeze
MCAFEE_EMOJI = 'M'.freeze
TRENDMICRO_EMOJI = '🇹'.freeze
MSDEFENDER_EMOJI = '🇩'.freeze

def get_antivus_emoji(content, logger)
  case content
  when /(kaspersky)/i
    "#{KASPERSKY_EMOJI} #{Regexp.last_match(1)}"
  when /(bitdefender)/i
    "#{BITDEFENDER_EMOJI} #{Regexp.last_match(1)}"
  when /(avast|avg)/i
    "#{AVAST_EMOJI} #{Regexp.last_match(1)}"
  when /(avira)/i
    "#{AVIRA_EMOJI} #{Regexp.last_match(1)}"
  when /(zonealarm|zone alarm|checkpoint|check point)/i
    "#{ZONEALARM_EMOJI} #{Regexp.last_match(1)}"
  when /(comodo)/i
    "#{COMODO_EMOJI} #{Regexp.last_match(1)}"
  when /(eset|nod32)/i
    "#{ESET_EMOJI} #{Regexp.last_match(1)}"
  when /(fsecure|f-secure|f secure)/i
    "#{FSECURE_EMOJI} #{Regexp.last_match(1)}"
  when /(malwarebytes)/i
    "#{MALWAREBYTES_EMOJI} #{Regexp.last_match(1)}"
  when /(mcafee)/i
    "#{MCAFEE_EMOJI} #{Regexp.last_match(1)}"
  when /(norton)/i
    "#{NORTON_EMOJI} #{Regexp.last_match(1)}"
  when /(sophos)/i
    "#{SOPHOS_EMOJI} #{Regexp.last_match(1)}"
  when /(trendmicro|titanium)/i
    "#{TRENDMICRO_EMOJI} #{Regexp.last_match(1)}"
  when /(defender)/i
    "#{MSDEFENDER_EMOJI} #{Regexp.last_match(1)}"
  else
    UNKNOWN_EMOJI
  end
end
def get_os_emoji(content, logger)
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

def get_email_emoji(content, logger)
  case content
  when /(gmail|google mail|googlemail)/i
    "#{GMAIL_EMOJI} #{Regexp.last_match(1)}"
  when /(live.com|msn|ms365|outlook|office365|office 365|\
    hotmail|livemail|passport|microsoft365|microsoft 365|\
    o365|ms 365|verizon|microsoft mail|microsoftmail|\
    timewarner|twc|godaddy|msexchange|ms exchange|\
    microsoft exchange|ms exchange|\
    spectrum|time warner|roadrunner)/i
    "#{MICROSOFT_EMAIL_EMOJI} #{Regexp.last_match(1)}"
  when /(protonmail|proton.me)/i
    "#{PROTONMAIL_EMOJI} #{Regexp.last_match(1)}"
  when /(fastmail|fastmail.fm)/i
    "#{FASTMAIL_EMOJI} #{Regexp.last_match(1)}"
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
  os_emoji = get_os_emoji(content, logger)
  email_emoji = get_email_emoji(content, logger)
  av_emoji = get_antivus_emoji(content, logger)
  created = Time.parse(q['created']).utc
  image = Magick::Image.read(\
    "pango:<span font='Noto Color Emoji'>\
  <span foreground='deeppink' letter_spacing='1'><b>id:</b></span>#{id} \r\
  <b>OS:</b>#{os_emoji}\r\
  <span foreground='darkblue'><b>email:</b>#{email_emoji}</span>\r\
  <span foreground='darkred'><b>Anti-virus:</b>#{av_emoji}</span>\r\
  </span>"
  ).first
  filename = format(
    fn_str,
    id: id, yyyy: created.year, mm: created.month, dd: created.day
  )
  image.write(filename)
end
