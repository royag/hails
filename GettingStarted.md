# Getting started #

## Installing hails ##

You must have Haxe 3 installed, and for the Java-target you will also need to have installed a JDK, and to point the JAVA\_HOME environment-variable to that JDK, as well as having installed hxjava, which is easily done by the command:

```
haxelib install hxjava
```

Hails is not yet in haxelib. In the future you will be able to install hails by typing "haxelib install hails", but until then:

Create the directory `C:\HaxeToolkit\haxe\lib\hails` .
Change to that directory and check out hails to 0,0,2 :
```
svn checkout http://hails.googlecode.com/svn/trunk/ 0,0,2
```
Create the file ".current", containing "0.0.2":
```
copy con .current
0.0.2[F6][ENTER]
```
For convenience, also create "hails.bat":

```
cd \HaxeToolkit\haxe
copy con hails.bat
@haxelib run hails %1 %2 %3 %4 %5 %6 %7 %8 %9[F6][ENTER]
```

## Create a project ##

Wherever you want to place a new project called "hailsdemo", type:

```
hails create hailsdemo
cd hailsdemo
```

You have now created a simple demo hails-app, with one controller `MainController`, and a simple model `User`, representing a database-table with two columns: `username` and the default autoincrementing `id`

The demo main controller contains three simple actions:
  * `index ("Hello World")`
  * `add (insert a new row into user-table)`
  * `some_test (list contents of the user-table)`

## Migrate the database ##

The template demo-app is set up to use Sqlite (see configuration under `config/dbconfig`), so you don't need to create a database in MySql or SqlServer.

Run the command:

```
hails migrate
```

Hails will now parse your models (the "User"-model) and create the database-tables accordingly.

```
Tip: Some Neko-installations on Windows complain about a missing msvcr71.dll when using sqlite.
If you experience this, you can grab it from a Java JDK
(like C:\jdk1.6.0_45\bin\msvcr71.dll) and copy it into C:\HaxeToolkit\neko.
```

## Build and run with Neko ##

Typing the command:

```
hails build neko run
```

will compile the app into a neko-binary at `nekoout/index.n`, and launch it with the nekotools server.

You should reach it at: http://localhost:2000/
Add user: http://localhost:2000/main/add
List users: http://localhost:2000/main/some_test

## Build and run with Java ##

Typing the command:

```
hails build java run
```

will compile the WAR-file `javaout/hailsdemo.war` and launch it in Jetty.

You should reach it at: http://localhost:8080/hailsdemo/
Add user: http://localhost:8080/hailsdemo/main/add
List users: http://localhost:8080/hailsdemo/main/some_test

## Build for PHP ##

Note that, when using Sqlite, and since `dbname` in `config/dbconfig` says `mytest`, the `hails migrate` command creates the file `mytest.db` in the current directory.

When you launch the PHP-code in Apache, Apache will not find that file in what _it_ conciders the current directory.

So before compiling to PHP, you should update the dbconfig to say something like:

```
dbname: /path/to/my/project/called/hailsdemo/mytest
```

Now, typing the command:

```
hails build php
```

will place the PHP-application into `phpout`

You will need to have installed Apache with PHP in order to run it.
I recommend installing XAMPP.

Having installed xampp under /xampp , edit the file:
```
/xampp/apache/conf/httpd.conf
```

Find the "DocumentRoot" and the 

&lt;Directory&gt;

-tag below that, and change it to point to your phpout-directory:
```
DocumentRoot "C:/path/to/my/project/called/hailsdemo/phpout"
<Directory "C:/path/to/my/project/called/hailsdemo/phpout">
```

Now go to `/xampp/apache/bin` and launch:

```
httpd.exe
```

You should reach the demo app at: http://localhost/index.php/
Add user: http://localhost/index.php/main/add
List users: http://localhost/index.php/main/some_test