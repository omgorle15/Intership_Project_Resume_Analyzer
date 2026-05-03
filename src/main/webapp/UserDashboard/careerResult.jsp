<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ include file="layout.jsp" %>

<style>

.result-card{
border-radius:15px;
box-shadow:0 8px 20px rgba(0,0,0,0.1);
}

.result-text{
white-space: pre-line;
font-size:16px;
line-height:1.7;
}

</style>

<div class="container-fluid">

<div class="row">

<div class="col-md-10 p-5">

<div class="card result-card shadow rounded-4">

<div class="card-header bg-success text-white">
<h4 class="mb-0">
<i class="bi bi-lightbulb"></i> Career Guidance Result
</h4>
</div>

<div class="card-body">

<%
String result = (String) request.getAttribute("careerResult");

if(result != null){
%>

<div class="result-text">
<%= result %>
</div>

<%
}else{
%>

<div class="alert alert-warning text-center">
No result found.
</div>

<%
}
%>

</div>

</div>

</div>

</div>

</div>

<%@ include file="layoutFooter.jsp" %>