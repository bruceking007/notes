@echo off

:: TODO:����java��������
:: Author: Gwt
color 02
::����java�İ�װ·�����ɷ����л���ͬ�İ汾
set input=
set /p "input=������java��jdk·������س�Ĭ��·��ΪC:\Program Files\Java\jdk1.7.0_71��:"
if defined input (echo jdk������) else (set input=C:\Program Files\Java\jdk1.7.0_71)
echo jdk·��Ϊ%input%
set javaPath=%input%

::����еĻ�����ɾ��JAVA_HOME
wmic ENVIRONMENT where "name='JAVA_HOME'" delete

::����еĻ�����ɾ��ClASS_PATH 
wmic ENVIRONMENT where "name='CLASS_PATH'" delete

::����JAVA_HOME
wmic ENVIRONMENT create name="JAVA_HOME",username="<system>",VariableValue="%javaPath%"

::����CLASS_PATH
wmic ENVIRONMENT create name="CLASS_PATH",username="<system>",VariableValue=".;%%JAVA_HOME%%\lib\tools.jar;%%JAVA_HOME%%\lib\dt.jar;"

::�ڻ�������path�У��޳�������java_home�е��ַ�������ʣ�µ��ַ���
call set xx=%Path%;%JAVA_HOME%\jre\bin;%JAVA_HOME%\bin

::echo %xx%

::�������Ե��ַ����¸�ֵ��path��
wmic ENVIRONMENT where "name='Path' and username='<system>'" set VariableValue="%xx%"

pause