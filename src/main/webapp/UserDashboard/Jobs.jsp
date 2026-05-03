<%@ page import="java.util.*" %>
<%@ include file="layout.jsp" %>

<%
List<String[]> jobs = (List<String[]>) request.getAttribute("jobs");
%>

<div class="container-fluid">

<div class="row">

<div class="col-md-10 p-5">

<h3 class="mb-4">AI Recommended Jobs</h3>

<div class="row">

<%

if(jobs != null && !jobs.isEmpty()){

for(String[] job : jobs){

%>

<div class="col-md-4">

<div class="card shadow p-4 mb-4 rounded-4">

<h5 class="fw-bold"><%= job[0] %></h5>

<p><b>Company Type:</b> <%= job[1] %></p>

<p><b>Location:</b> <%= job[2] %></p>

<p><b>Skills:</b> <%= job[3] %></p>

<a href="https://www.google.com/search?q=<%= job[0].trim().replace(" ","+") %>+jobs"
target="_blank"
class="btn btn-success">
Apply
</a>

</div>		

</div>

<%
}

}else{
%>

<div class="alert alert-warning">
AI could not generate jobs.
</div>

<%
}
%>

</div>

</div>

</div>

</div>

<%@ include file="layoutFooter.jsp" %>