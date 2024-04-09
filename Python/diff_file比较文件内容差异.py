#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
1.difflib的HtmlDiff类创建html表格用来展示文件差异，通过make_file方法
2.make_file方法使用
make_file(fromlines, tolines [, fromdesc][, todesc][, context][, numlines])
用来生成一个包含表格的html文件，其内容是用来展示差异。
fromlines和tolines,用于比较的内容，格式为字符串组成的列表
fromdesc和todesc，可选参数，对应的fromlines,tolines的差异化文件的标题，默认为空字符串
context 和 numlines，可选参数，context 为True时，只显示差异的上下文，为false，显示全文，numlines默认为5，
当context为True时，控制展示上下文的行数，当context为false时,控制不同差异的高亮之间移动时“next”的开始位置
3.使用argparse传入两个需要对比的文件
"""
import difflib
import argparse
import sys
import random
import string
 
# 创建打开文件函数，并按换行符分割内容
def readfile(filename):
    try:
        with open(filename, 'r') as fileHandle:
            text = fileHandle.read().splitlines()
        return text
    except IOError as e:
        print("Read file Error:", e)
        sys.exit()
 
# 比较两个文件并输出到html文件中
def diff_file(filename1, filename2):
    text1_lines = readfile(filename1)
    text2_lines = readfile(filename2)
    d = difflib.HtmlDiff()
    ranstr = ''.join(random.sample(string.ascii_letters + string.digits, 5))
    # context=True时只显示差异的上下文，默认显示5行，由numlines参数控制，context=False显示全文，差异部分颜色高亮，默认为显示全文
    result = d.make_file(text1_lines, text2_lines, filename1, filename2, context=False)
    # 内容保存到result.html文件中
    with open('result_%s.html' % ranstr, 'w') as resultfile:
        resultfile.write(result)
    # print(result)
 
 
if __name__ == '__main__':
    # 定义必须传入两个参数，使用格式-f1 filename1 -f2 filename
    parser = argparse.ArgumentParser(description="传入两个文件参数")
    #parser.add_argument('-f1', action='store', dest='filename1', required=True)
    #parser.add_argument('-f2', action='store', dest='filename2', required=True)

    # 定义必须传入两个参数，使用格式filename1 filename
    parser.add_argument(dest='filename1')
    parser.add_argument(dest='filename2')
    given_args = parser.parse_args()
    filename1 = given_args.filename1
    filename2 = given_args.filename2
    diff_file(filename1, filename2)
