# rt-tb-noto-emoji-2023
create noto emoji graphics
## 2023-09-05 how to generate a daily graphic with the questions laid out horizontally 
```bash
cd EMOJI_INFOGRAPHICS
../create-emoji-question-graphics.rb ../sorted-by-id-thunderbird-2023-04-01-2023-06-30-questions.csv \
../sorted-by-id-thunderbird-2023-04-01-2023-06-30-answers.csv 
montage -verbose -adjoin -tile x1 +frame +shadow +label tb*2023-04-01.png daily-2023-04-01.png
```
