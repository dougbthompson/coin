
import re

html_text = open('icodrops.html').read()
text_filtered = re.sub(r'<(.*?)>', '', html_text)

