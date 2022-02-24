<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>It is coming from JSP</title>
</head>
<body>
<h2 style="text-align:center">Login</h2>
<div style="text-align:center">
<form action="/login.do" method="POST">
Name:</br>
<input type="text" name="name"/> </br>
Password:</br>
<input type="text" name="password"/> </br>
<div>${ifError}</div>
<input type="submit"/>
</form>
</div>

<a href="/download">Download Document</a>
<br/>
Section for showing servlets init parameter
<br/>
${adminEmail}
<br/>
Context Parameter: ${contextParameter}

</body>
</html>