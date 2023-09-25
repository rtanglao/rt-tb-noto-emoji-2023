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
require 'mini_magick'
logger = Logger.new($stderr)
logger.level = Logger::DEBUG

VERTICAL = true
HORIZONTAL = false

#
# <img src="workplace.jpg" alt="Workplace" usemap="#workmap">
#
# <map name="workmap">
#   <area shape="rect" coords="34,44,270,350" alt="Computer" href="computer.htm">
#   <area shape="rect" coords="290,172,333,250" alt="Phone" href="phone.htm">
#   <area shape="circle" coords="337,300,44" alt="Coffee" href="coffee.htm">
# </map>

def calculate_img_map_coordinates(daily, logger)
  day_id = daily[:day_id]
  day_filename = daily[:day_filename]
  day_width = daily[:day_width]
  day_height = daily[:day_height]
  html_str = "<img src='"
  html_str += "#{day_filename}' alt='#{day_id}' usemap='##{day_id}'>\n"
  html_str += "<map name='#{day_id}'>"
  bottom_right_x_offset = 0
  daily[:hourly_images].each_with_index do |h, hourly_index|
    logger.debug "hourly_image: #{h.ai}"
    bottom_right_y_offset = day_height
    hourly_width = h[:hourly_width]
    total_q_height = 0
    h[:questions].each_with_index do |q, question_index|
      q_width = q[:question_width]
      q_height = q[:question_height]
      total_q_height += q_height
      q_id = q[:question_id]
      top_left_x = hourly_index.zero? ? 0 : bottom_right_x_offset
      top_left_y = question_index.zero? ? day_height - q_height : day_height - total_q_height
      bottom_right_x = hourly_index.zero? ? q_width : q_width + bottom_right_x_offset
      bottom_right_y = question_index.zero? ? day_height : day_height - (total_q_height - q_height)
      bottom_right_y_offset -= q_height
      logger.debug "top_left_x: #{top_left_x} top_left_y: #{top_left_y}"
      logger.debug "bottom_right_x: #{bottom_right_x} bottom_right_y: #{bottom_right_y}"
      html_str += "\n<area shape='rect' "
      html_str += "coords='#{top_left_x},#{top_left_y},#{bottom_right_x},#{bottom_right_y}' "
      html_str += "alt='question:#{q_id}' href='https://support.mozilla.org/questions/#{q_id}'>"
      logger.debug "html_str: #{html_str}"
    end
    bottom_right_x_offset += hourly_width # + (5 * (hourly_index + 1))
  end
  html_str += "\n</map>"
end

def append_image(image_to_be_appended, image, vertical_or_horizontal)
  image_list = Magick::ImageList.new(image_to_be_appended, image)
  appended_images = image_list.append(vertical_or_horizontal)
  appended_images.write(image)
end

# if RMagick supported a smush option then it would work but it doesn't
# Therefore the RMagick version is commented out
#  def montage_images_horizontally(image_to_be_appended, image)
#   image_list = Magick::ImageList.new(image, image_to_be_appended)
#   montaged_images = image_list.montage do |i|
#     i.geometry = '+0+0'
#     i.gravity = Magick::SouthGravity
#     i.tile = 'x1' # Geometry.new(nil, 1, nil, nil, nil)
#   end
#   montaged_images.write(image)
# end

def montage_images_horizontally(image_to_be_appended, image)
  # following is from:
  # https://stackoverflow.com/questions/60357036/imagemagick-montage-how-to-align-images-to-bottom
  # convert -background white -gravity south [abc].png +smush 10 result.png
  MiniMagick::Tool::Magick.new do |m|
    m << '-gravity' << 'South'
    m << image
    m << image_to_be_appended
    m << '+smush' << '0' #'10'
    m << image
  end
end

# Can't get the following to work, keeping it for future reference
def montage_images_vertically(image_to_be_appended, image)
  # following is from:
  # https://stackoverflow.com/questions/60357036/imagemagick-montage-how-to-align-images-to-bottom
  # convert -background white -gravity south [abc].png +smush 10 result.png
  MiniMagick::Tool::Magick.new do |m|
    m.gravity('south')
    m << image_to_be_appended
    m << image
    m << '-smush' << '0' # stack vertically
    m << image
  end
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

HOURLY_STR = 'hourly-tb-emoji-%<yyyy>4.4d-%<mm>2.2d-%<dd>2.2d-%<hh>2.2d.png'.freeze
HOURID_STR = '%<yyyy>4.4d%<mm>2.2d%<dd>2.2d%<hh>2.2d'.freeze
DAY_STR = '%<yyyy>4.4d%<mm>2.2d%<dd>2.2d%'.freeze

hourly_images = []
daily_images = []

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
  year = created.year
  month = created.month
  day = created.day

  os_emoji_content = get_emojis_from_regex(OS_EMOJI_ARRAY, content, logger)
  created_str = "➖➖<span font='Latin Modern Roman Demi'><b>"
  created_str += format('%<hh>2.2d:%<min>2.2d', hh: hour, min: min)
  created_str += '</b></span>➖➖'
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
  question_image = Magick::Image.read(pango_str).first
  question_width = question_image.columns
  question_height = question_image.rows

  question_filename = format(
    fn_str,
    id: id, yyyy: year, mm: month, dd: day,
    hh: hour, min: min, ss: created.sec,
    width: question_width,
    height: question_height
  )
  question_image.write(question_filename)

  logger.debug "question_width: #{question_width}"
  logger.debug "question_height: #{question_height}"
  logger.debug "question_filename: #{question_filename}"
  question_hash = {
    question_filename: question_filename,
    question_id: id,
    question_width: question_width,
    question_height: question_height
  }
  # FIXME: Assume question ids are ascending and assume ids are ascending by time
  # append image to hourly image if it exists else create hourly image
  hourly_filename = format(
    HOURLY_STR, yyyy: year, mm: month, dd: day, hh: hour
  )
  logger.debug "hourly_filename: #{hourly_filename}"
  hour_id = format(HOURID_STR, yyyy: year, mm: month, dd: day, hh: hour)
  hourly_index = hourly_images.index { |hi| hi[:hour_id] == hour_id }
  if hourly_index
    # weird horizontal offset so montage_image_vertically() is commented out
    # montage_images_vertically(filename, hourly_filename)
    append_image(question_filename, hourly_filename, VERTICAL)
    image = Magick::ImageList.new(hourly_filename)
    logger.debug "hourly_index: #{hourly_index}"
    hourly_images[hourly_index][:hourly_width] = image.columns
    hourly_images[hourly_index][:hourly_height] = image.rows
    hourly_images[hourly_index][:questions].push(question_hash)
  else
    FileUtils.copy_file(question_filename, hourly_filename)
    image = Magick::ImageList.new(hourly_filename)
    hourly_images.push(
      {
        hour_id: hour_id,
        hourly_width: image.columns,
        hourly_height: image.rows,
        hourly_filename: hourly_filename,
        questions: [question_hash]
      }
    )
  end
end
# Add 2 pixel red border
hourly_images.each do |img|
  hourly_filename = img[:hourly_filename]
  MiniMagick::Tool::Magick.new do |m|
    m << hourly_filename
    m << '-bordercolor' << 'red'
    m << '-border' << '2'
    m << hourly_filename
  end
  image = Magick::ImageList.new(hourly_filename)
  img[:hourly_width] = image.columns
  img[:hourly_height] = image.rows
end

DAILY_STR = 'daily-tb-emoji-%<yyyymmdd>s.png'.freeze

hourly_images.each do |hourly_img|
  day_id = hourly_img[:hour_id][0...-2]
  daily_filename = format(DAILY_STR, yyyymmdd: day_id)
  hourly_filename = hourly_img[:hourly_filename]
  daily_index = daily_images.index { |di| di[:day_id] == day_id }
  if daily_index
    montage_images_horizontally(hourly_filename, daily_filename)
    image = Magick::ImageList.new(daily_filename)
    daily_images[daily_index][:day_width] = image.columns
    daily_images[daily_index][:day_height] = image.rows
    daily_images[daily_index][:hourly_images].push(hourly_img)
  else
    FileUtils.copy_file(hourly_filename, daily_filename)
    image = Magick::ImageList.new(daily_filename)
    daily_images.push(
      {
        day_id: day_id,
        day_width: image.columns,
        day_height: image.rows,
        day_filename: daily_filename,
        hourly_images: [hourly_img]
      }
    )
  end
end
logger.debug daily_images.ai

daily_images.each do |d|
  html_str = calculate_img_map_coordinates(d, logger)
  # write html to a file
  logger.debug html_str
end
# We know the top of the day_image is #day_height e.g. 1000px, which is y = 0
# We know the height of the hour image
# We know the height of the question image
# Top left X is the same for all images in that hour: 0 if first hour else sum of previous hour's widths
# Bottom right X is the same for all images in that hour: hourly image width if the first hour else sum of previous widths + current width + 10pixel border * (hourly_image index)
# Top left Y is day height minus question height if first else day hight minus (sum of previous question heights + current question height)
# Bottom Right Y is 0 if first question else height - sum of previous height
