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
SOPHOS_EMOJI = '🇸'.freeze
USERCHROME_EMOJI = '🛠'.freeze

USERCHROME_EMOJI_ARRAY = [
  { regex: /(userchrome|usercontent)/i, emoji: USERCHROME_EMOJI }
].freeze

OS_EMOJI_ARRAY = [
  {
    regex: /(ventura|panther|\
    snow(-| )*leopard|leopard|jaguar|monterey|mavericks|sonoma|\
    sierra|el(-| )*capitan|mojave|catalina|big(-| )*sur|yosemite|\
    mac(-| )*os(-| )*x*[0-9]*\.*[0-9]*\.*[0-9]*|osx|os-x)/i,
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

ANTIVIRUS_EMOJI_ARRAY = [
  {
    regex: /(kaspersky)/i,
    emoji: KASPERSKY_EMOJI
  },
  { regex: /(bitdefender)/i,
    emoji: BITDEFENDER_EMOJI },
  { regex: /(avast|avg)/i,
    emoji: AVAST_EMOJI },
  { regex: /(avira)/i,
    emoji: AVIRA_EMOJI },
  { regex: /(zonealarm|zone alarm|checkpoint|check point)/i,
    emoji: ZONEALARM_EMOJI },
  { regex: /(comodo)/i,
    emoji: COMODO_EMOJI },
  { regex: /(eset|nod32)/i,
    emoji: ESET_EMOJI },
  { regex: /(fsecure|f-secure|f secure)/i,
    emoji: FSECURE_EMOJI },
  { regex: /(malwarebytes)/i,
    emoji: MALWAREBYTES_EMOJI },
  { regex: /(mcafee)/i,
    emoji: MCAFEE_EMOJI },
  { regex: /(norton)/i,
    emoji: NORTON_EMOJI },
  { regex: /(sophos)/i,
    emoji: SOPHOS_EMOJI },
  { regex: /(trendmicro|titanium)/i,
    emoji: TRENDMICRO_EMOJI },
  { regex: /(defender)/i,
    emoji: MSDEFENDER_EMOJI }
]

EMAIL_EMOJI_ARRAY = [
  { regex: /(gmail|google mail|googlemail)/i,
    emoji: GMAIL_EMOJI },
  { regex: /(live.com|msn|ms365|outlook|office365|office 365|\
    hotmail|livemail|passport|microsoft365|microsoft 365|\
    o365|ms 365|verizon|microsoft mail|microsoftmail|\
    timewarner|twc|godaddy|msexchange|ms exchange|\
    microsoft exchange|ms exchange|\
    spectrum|time warner|roadrunner)/i,
    emoji: MICROSOFT_EMAIL_EMOJI },
  { regex: /(protonmail|proton.me)/i,
    emoji: PROTONMAIL_EMOJI },
  { regex: /(fastmail|fastmail.fm)/i,
    emoji: FASTMAIL_EMOJI },
  { regex: /(yahoo)/i,
    emoji: YAHOOEMAIL_EMOJI }
].freeze
