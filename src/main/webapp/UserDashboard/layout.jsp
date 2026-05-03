<%@ page session="true" %>
<%
if(session.getAttribute("userName") == null){
    response.sendRedirect("../SignIn.jsp");
}
String userName = (String) session.getAttribute("userName");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>User Panel</title>

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<style>
body {
    background-color: #f4f6f9;
}

.sidebar {
    height: 100vh;
    background: linear-gradient(to bottom, #198754, #20c997);
    color: white;
}

.sidebar a {
    color: white;
    text-decoration: none;
    display: block;
    padding: 12px 20px;
}

.sidebar a:hover {
    background: rgba(255,255,255,0.2);
}

.card-hover:hover {
    transform: translateY(-5px);
    transition: 0.3s;
}
</style>
</head>

<body>

<%@ include file="navbar.jsp" %>

<div class="container-fluid">
<div class="row">

<%@ include file="sidebar.jsp" %>

<div class="col-md-10 p-4">
