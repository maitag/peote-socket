haxe cli.hxml

@echo off
if not exist bin mkdir bin
@echo on

copy build\neko\peote-socket-test.n bin\peote-socket-test.n
copy build\cpp\MainCli.exe bin\peote-socket-test.exe

@echo off
REM creates (clickable;) batch files for neko test
if not exist bin\neko_test.bat (
  echo neko peote-socket-test.n -v
  echo pause
) > bin\neko_test.bat

REM creates (clickable;) batch files for cpp test
if not exist bin\test.bat (
  echo peote-socket-test.exe -v
  echo pause
) > bin\test.bat


if "%~1"=="" pause

@echo on