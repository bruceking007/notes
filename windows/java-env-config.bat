@echo off
 
 :: TODO:设置java环境变量
 :: Author: metazhou
 color 02
 ::设置java的安装路径，可方便切换不同的版本
 set input=
 set /p "input=请输入java的jdk路径（或回车默认路径为C:\Program Files\Java\jdk1.8.0_333）:"
 if defined input (echo jdk已设置) else (set input=C:\Program Files\Java\jdk1.8.0_333)
 echo jdk路径为%input%
 set javaPath=%input%
 
 ::如果有的话，先删除JAVA_HOME
 wmic ENVIRONMENT where "name='JAVA_HOME'" delete
 
 ::如果有的话，先删除ClASS_PATH
 wmic ENVIRONMENT where "name='CLASSPATH'" delete
 
 ::创建JAVA_HOME
 wmic ENVIRONMENT create name="JAVA_HOME",username="<system>",VariableValue="%javaPath%"
 
 ::创建CLASS_PATH
 wmic ENVIRONMENT create name="CLASSPATH",username="<system>",VariableValue=".;%JAVA_HOME%\lib\tools.jar;%JAVA_HOME%\lib;"
 
 ::在环境变量path中，剔除掉变量java_home中的字符，回显剩下的字符串
 call set xx=%Path%;%JAVA_HOME%\jre\bin;%JAVA_HOME%\bin
 
 ::echo %xx%
 
 ::将返回显的字符重新赋值到path中
 wmic ENVIRONMENT where "name='Path' and username='<system>'" set VariableValue="%xx%"
 
 pause