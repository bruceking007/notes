#### xml文件转为json

```python
# -*- coding: utf-8 -*-
import json
import xmltodict

# 主程序，执行入口
if __name__ == '__main__':
    with open('input1.xml', encoding="UTF-8") as xml_file:
        # 将xml文件转化为字典类型数据
        parsed_data = xmltodict.parse(xml_file.read())
        # 关闭文件流，其实 不关闭with也会帮你关闭
        xml_file.close()
        # 将字典类型转化为json格式的字符串
        json_conversion = json.dumps(parsed_data, ensure_ascii=False)
        # 将字符串写到文件中
        with open('output.json', 'w', encoding="UTF-8") as json_file:
            json_file.write(json_conversion)
            json_file.close()
```

https://zhuanlan.zhihu.com/p/588098227?utm_id=0