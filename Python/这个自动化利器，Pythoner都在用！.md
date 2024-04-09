# 这个自动化利器，Pythoner都在用！

[Python头条](javascript:void(0);) *2022-06-21 18:00* *发表于河南*

以下文章来源于Python技术 ，作者派森酱

[![img](http://wx.qlogo.cn/mmhead/Q3auHgzwzM6uOKrw4WrpicQ5ZuoSgGOl9P4DZ7UTmIqZsicVaYoawmFg/0)**Python技术**.Python 技术由一群热爱 Python 的技术人组建，专业输出高质量原创的 Python 系列文章，Python程序员都在这里。](https://mp.weixin.qq.com/s/-gDBElP6MSDh9vRmVUDG3g#)

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/SAy0yVjKWywF1B2sqROJSwGqkBTnf3iaCY0NicU3iaflojDougbyrWHezpZkPo7ViaglL4pQgXEANKZGRsts1PA2TQ/640?wx_fmt=jpeg&wxfrom=5&wx_lazy=1&wx_co=1)

文 | 闲欢

来源：Python 技术「ID: pythonall」

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/t8ibUxVnMTLPLUyAAdaDETpj5xxGvtM5pcns01OplkMfZrYaMeHJUFDOGIAjbOpGab87wO7uZhjEwv0WnhPbq1A/640?wx_fmt=jpeg&wxfrom=5&wx_lazy=1&wx_co=1)

我们在上篇文章《强烈推荐这款神器，一行命令将网页转PDF！》中介绍了一款将网页转换成 PDF 的神器——wkhtmltopdf。在不同的操作系统中安装这个小巧的软件，就可以通过命令行直接将网页转换成 PDF 和图片。

有小伙伴说这种处理方式跟用插件没什么区别，而且很不 Python！

于是，我去找了下，发现 wkhtmltopdf 这款软件有一个对应的 Python 版本的包——pdfkit。

今天我们就来看看这个包可以帮助我们做什么。

### pdfkit 是什么

pdfkit 是把 HTML+CSS 格式的文件转换成 PDF 的一种工具，它是 wkhtmltopdf 这个工具包的 python 封装。所以，我们使用 pdfkit 之前要先安装 wkhtmltopdf 。具体安装方法很简单，大家可以参照上篇文章。

### pdfkit 安装

安装完 wkhtmltopdf 之后，我们再来安装 pdfkit：

> pip install pdfkit

跟安装其他 python 包一样，只需要使用 pip 安装就行。

### pdfkit 应用

pdfkit 是基于 wkhtmltopdf 的封装，所以功能肯定也是基于 wkhtmltopdf 的。

#### URL 对应网页转 PDF

我们先来看一个例子：

```
path_wkthmltopdf = r'C:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe'
config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)
pdfkit.from_url(r"https://zhuanlan.zhihu.com/p/421726412", "studypython.pdf", configuration=config)
```

例子很简单，就三行代码。

第一行是 wkhtmltopdf 软件安装目录的 bin 目录地址；

第二行是将这个目录地址传入 pdfkit 的配置中；

第三行就是传入网页 URL 和生成文件的目标地址，传入配置信息，然后就可以生成 PDF 了。

运行之后，生成的 PDF 文件是这样的：

![图片](https://mmbiz.qpic.cn/mmbiz_png/pbRNVEA1d2y9hAicF44zISmML87dib1fhnQgIibSK2Z9NQ0yia4kRiaAQHqK2smqlbYkcbP1icSWFHPSrbsmgh6RD3oA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

#### HTML 文件转 PDF

这个方法也很简单，跟上一个类似，只需要将 pdfkit 调用的函数改一下即可：

```
path_wkthmltopdf = r'C:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe'
config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)
pdfkit.from_file(r'C:\Users\xxx\Downloads\ttest\test.html','html.pdf', configuration=config)
```

可以看到，前两行一样，第三行用了 `from_file` 函数。这里我传入的是一个简单的分页页面，生成的 PDF 文件如下：

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

#### 字符串转 PDF

如果你手中有大量的文档需要转 PDF 文件，比如说下载了很多部小说。这时候可以使用 pdfkit 的字符串转 PDF 功能，批量操作，进行转化。

```
path_wkthmltopdf = r'C:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe'
config = pdfkit.configuration(wkhtmltopdf=path_wkthmltopdf)
pdfkit.from_string('talk is cheap, show me your code!','str.pdf', configuration=config)
```

运行这段代码，生成 PDF 文件如下：

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

### 总结

本文介绍了一款轻量级的三方包——pdfkit，可以将 URL 对应的网页、HTML 文件和字符串转成 PDF 文件。

有人会问：有什么用？这些直接用软件操作，很容易就解决了。

当然，对于少量的单线程操作，确实没必要写代码，使用软件反而更快更好。但是，设想一下，如果你通过爬虫爬取了很多页面，想要将这些页面转成 PDF 文件保存，这时候直接写转换程序，然后和爬虫程序结合，是不是更好更高效？

像这些小工具，功能虽然简单，但是在合适的时候使用，会大大提高你的效率，平时积累一下，关键时刻才可以灵活运用！

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

喜欢此内容的人还喜欢

新手如何快速学会 Python ？

...

猴子数据分析

不喜欢

不看的原因

确定

- 内容质量低
-  

- 不看此公众号

被科学家鄙视的 goto 语句，Go语言为啥还要引入

...

网管叨bi叨

不喜欢

不看的原因

确定

- 内容质量低
-  

- 不看此公众号

从Go log库到Zap，怎么打造出好用又实用的Logger

...

Go招聘

不喜欢

不看的原因

确定

- 内容质量低
-  

- 不看此公众号

![img](https://mp.weixin.qq.com/mp/qrcode?scene=10000004&size=102&__biz=MzUyOTU2NDExNw==&mid=2247532734&idx=1&sn=67d1c41168ee4c2e04e131bbe5f75519&send_time=)

微信扫一扫
关注该公众号