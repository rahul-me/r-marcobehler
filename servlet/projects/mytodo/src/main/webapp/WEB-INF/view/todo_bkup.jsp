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
<form action="/todo" method="POST">
What to do: <input type="text" name="todo"/> </br>

<input type="submit"/>
</form>
</br>
</br>

<%
Object[] todos = (Object[])request.getAttribute("todos");
if(todos != null) {
for(Object todo: todos){
String hi = (String) todo;
System.out.println(hi);
 %>
 <p><%= hi %></p></br>
 <% }} %>



</body>
</html>