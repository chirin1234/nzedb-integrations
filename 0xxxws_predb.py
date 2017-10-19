#!/usr/bin/env python3

import sys
import os
import re
import math
import html
import xml.etree.ElementTree as ET
import pycurl
import time
from collections import defaultdict
from bs4 import BeautifulSoup
from io import BytesIO


USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36"



nn_cats = {0: 'Other', 10: 'Other/Misc', 20: 'Other/Hashed', 1000: 'Console', 1010: 'Console/NDS', 1020: 'Console/PSP', 1030: 'Console/Wii', 1040: 'Console/Xbox', 1050: 'Console/Xbox 360', 1060: 'Console/Wiiware/VC', 1070: 'Console/XBOX 360 DLC', 1080: 'Console/PS3', 1999: 'Console/Other', 1110: 'Console/3DS', 1120: 'Console/PS Vita', 1130: 'Console/WiiU', 1140: 'Console/Xbox One', 1180: 'Console/PS4', 2000: 'Movies', 2010: 'Movies/Foreign', 2020: 'Movies/Other', 2030: 'Movies/SD', 2040: 'Movies/HD', 2050: 'Movies/3D', 2060: 'Movies/BluRay', 2070: 'Movies/DVD', 2080: 'Movies/WEBDL', 3000: 'Audio', 3010: 'Audio/MP3', 3020: 'Audio/Video', 3030: 'Audio/Audiobook', 3040: 'Audio/Lossless', 3999: 'Audio/Other', 3060: 'Audio/Foreign', 4000: 'PC', 4010: 'PC/0day', 4020: 'PC/ISO', 4030: 'PC/Mac', 4040: 'PC/Phone-Other', 4050: 'PC/Games', 4060: 'PC/Phone-IOS', 4070: 'PC/Phone-Android', 5000: 'TV', 5010: 'TV/WEB-DL', 5020: 'TV/FOREIGN', 5030: 'TV/SD', 5040: 'TV/HD', 5999: 'TV/OTHER', 5060: 'TV/Sport', 5070: 'TV/Anime', 5080: 'TV/Documentary', 6000: 'XXX', 6010: 'XXX/DVD', 6020: 'XXX/WMV', 6030: 'XXX/XviD', 6040: 'XXX/x264', 6999: 'XXX/Other', 6060: 'XXX/Imageset', 6070: 'XXX/Packs', 7000: 'Books', 7010: 'Books/Magazines', 7020: 'Books/Ebook', 7030: 'Books/Comics', 7040: 'Books/Technical', 7060: 'Books/Foreign', 7999: 'Books/Unknown'}

          
def main(args):
    # con = connect()
    # cur = con.cursor()
    # res = cur.execute(recent_spots)
    # for row in cur.fetchall():
    #     nzb_id = int(row[4])
    #     subdir = ''
    #     if math.floor(nzb_id/1000) > 1000:
    #         subdir = str(nzb_id)[0:2]
    #     else:
    #         subdir = str(math.floor(nzb_id/1000))
    #     spot_path = os.path.join(spotweb_cache_dir, 'nzb', subdir, str(nzb_id) + '.nzb')
    #     data = ''
    #     file_subject=''
    #     with open(spot_path, 'rb') as f:
    #         data = f.readlines()
    #     for line in data:
    #         if "subject=" in line.decode('unicode_escape'):
    #             match = re.match('.+subject="(.+?)"', line.decode('unicode_escape'))
    #             if match:
    #                 file_subject = match.expand('\\1')
    #                 file_subject = html.unescape(file_subject)
    #             break
    #     file_name = file_subject
    #     for name in re.findall(SUBJECT_FN_MATCHER, file_name):
    #         name = name.strip(' "')
    #         if name and RE_NORMAL_NAME.search(name):
    #             file_name = name
    #     file_name = re.sub(r'(\.vol[0-9\+]+(\+[0-9]+)?\.par2|\.par2|\.part[0-9]+\.rar|\.rar|\.nzb|\.mp4|\.avi|\.r[0-9][0-9]|\.nzb|\.mkv|\.wmv|\.0[0-9]][0-9])$','', file_name, flags=re.IGNORECASE)
    #     cat = 0
    #     acat = row[1].split('|')[0]
    #     zcat = row[2].split('|')[0]
    #     cat_str = 'Other'
    #     if acat in sw_cats:
    #         cat = cat + sw_cats[acat]
    #     if zcat in sw_cats:
    #         cat = cat + sw_cats[zcat]

        buf = BytesIO()
        curl = pycurl.Curl()
        curl.setopt(curl.URL, 'https://0xxx.ws/rss.xml')
        # curl.setopt(curl.URL, 'http://localhost/tt.html')
        curl.setopt(curl.WRITEDATA, buf)
        curl.setopt(curl.USERAGENT, USER_AGENT)
        curl.setopt(curl.SSL_VERIFYPEER, 1)
        curl.setopt(curl.SSL_VERIFYHOST, 2)
        curl.perform()
        curl.close()

        b = buf.getvalue()
        tree = ET.fromstring(b.decode('utf-8'))


        # tree = ET.parse('rss.xml').getroot()


        for child in tree[0]:
            title = ''
            created = ''
            source = '0xxx.ws'
            category = 'XXX/0day'
            filename = ''
            for node in child:
                if node.tag == 'title':
                    title = node.text.strip().replace(' ', '.')
                if node.tag == 'pubDate':
                    created = node.text.strip()
            if title == '':
                continue
            filename = title.lower()
            filename = filename.replace('1080p', 'fullhd')
            filename = filename.replace('2160p', '4k')
            filename = filename.replace('.XXX', '')
            filename = filename.replace('.720p', '')
            filename = filename.replace('.540p', '')
            filename = filename.replace('.480p', '')
            filename = re.sub('\.mp4-.+?$', '', filename)

            # 'title, nfo, size, files, filename, nuked, nukereason, category, created, source, requestid, groupname'
            out = "'{0}'\t\t\\N\t\t\\N\t\t\\N\t\t'{1}'\t\t0\t\t\\N\t\t'{2}'\t\t'{3}'\t\t'{4}'\t\t0\t\t\\N".format(title, filename, category, created, source)

            # nzedb's import script requires CRLF even on platforms where LF is preferred
            print(out, end='\r\n')
        





if __name__ == '__main__':
    main(sys.argv)
