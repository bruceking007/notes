@echo off
 
 :: TODO:����java��������
 :: Author: metazhou
 color 02
 ::����java�İ�װ·�����ɷ����л���ͬ�İ汾
 set input=
 set /p "input=������java��jdk·������س�Ĭ��·��ΪC:\Program Files\Java\jdk1.8.0_333��:"
 if defined input (echo jdk������) else (set input=C:\Program Files\Java\jdk1.8.0_333)
 echo jdk·��Ϊ%input%
 set javaPath=%input%
 
 ::����еĻ�����ɾ��JAVA_HOME
 wmic ENVIRONMENT where "name='JAVA_HOME'" delete
 
 ::����еĻ�����ɾ��ClASS_PATH
 wmic ENVIRONMENT where "name='CLASSPATH'" delete
 
 ::����JAVA_HOME
 wmic ENVIRONMENT create name="JAVA_HOME",username="<system>",VariableValue="%javaPath%"
 
 ::����CLASS_PATH
 wmic ENVIRONMENT create name="CLASSPATH",username="<system>",VariableValue=".;%JAVA_HOME%\lib\tools.jar;%JAVA_HOME%\lib;"
 
 ::�ڻ�������path�У��޳�������java_home�е��ַ�������ʣ�µ��ַ���
 call set xx=%Path%;%JAVA_HOME%\jre\bin;%JAVA_HOME%\bin
 
 ::echo %xx%
 
 ::�������Ե��ַ����¸�ֵ��path��
 wmic ENVIRONMENT where "name='Path' and username='<system>'" set VariableValue="%xx%"
 
 pause