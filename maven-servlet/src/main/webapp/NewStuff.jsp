<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Insert title here</title>
</head>
<body>
<form action="/psms/save" method="post">
Name: <input type="text" name="name"><br>
Description: <input type="text" name="description"><br>
Quantity: <input type="text" name="quantity"><br>
Location: <input type="text" name="location"><br>
<input type="submit" value="save">
</form>
</body>
</html>