<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>It is coming from JSP</title>
</head>
<body>
Welcome ${name}
<form action="/todo" method="POST">
What to do: <input type="text" name="todo"/> </br>

<input type="submit"/>
</form>
</br>
</br>

<ol>
<c:forEach items="${todos}" var="todo">
<li>${todo}</li>
</c:forEach>
</ol>



</body>
</html>