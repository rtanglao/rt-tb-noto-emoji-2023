MACOS_EMOJI = '🍎'.freeze
LINUX_EMOJI = '🐧'.freeze
WINDOWS_EMOJI = '🪟'.freeze
UNKNOWN_EMOJI = '❓'.freeze
GMAIL_EMOJI = '📮'.freeze
MICROSOFT_EMAIL_EMOJI = '📧'.freeze
PROTONMAIL_EMOJI = '📨'.freeze
FASTMAIL_EMOJI = '✉️'.freeze
YAHOOEMAIL_EMOJI = '🇾'.freeze
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
TRENDMICRO_EMOJI = '🇹'.freeze
MSDEFENDER_EMOJI = '🇩'.freeze
USERCHROME_EMOJI = '🛠'.freeze

USERCHROME_EMOJI_ARRAY = [
  { regex: /(userchrome|usercontent)/i, emoji: USERCHROME_EMOJI }
].freeze

OS_EMOJI_ARRAY = [
  {
    regex: /(mac-os|os-x|osx|macos|ventura|macos|mac os|panther|\
    snow leopard|leopard|jaguar|monterey|mavericks|sonoma|\
    sierra|el capitan|mojave|catalina|big sur|yosemite)/i,
    emoji: MACOS_EMOJI
  },
  {
    regex: /(linux|ubuntu|redhat|debian|bsd)/i,
    emoji: LINUX_EMOJI
  },
  { regex: /(windows-7|windows-8|windows-10|windows-11|windows 10|\
    win 10|windows 11|win 11|windows 7|win 7|windows 8|win 8|\
    win7|win10|win8|win11)/i,
    emoji: WINDOWS_EMOJI }
].freeze