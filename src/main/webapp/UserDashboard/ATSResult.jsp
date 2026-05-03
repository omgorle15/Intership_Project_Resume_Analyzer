<%@ page session="true" %>
<%@ include file="layout.jsp" %>

<%
String ai = (String) session.getAttribute("aiResponse");
Integer score = (Integer) session.getAttribute("atsScore");
String userQuery = (String) session.getAttribute("userQuery");

if(score == null){
score = 0;
}
%>

<div class="container-fluid">
<div class="row">
<div class="col-md-10 p-5">

<!-- ATS SCORE CARD -->

<div class="card shadow card-hover p-4 text-center rounded-4 mb-4">

<h5 class="fw-bold mb-3">
<i class="bi bi-bar-chart-fill text-success"></i>
Resume ATS Score
</h5>

<div class="progress" style="height:30px;border-radius:20px;">

<div class="progress-bar bg-success progress-bar-striped progress-bar-animated"
style="width:<%=score%>%">

<strong><%=score%>%</strong>

</div>

</div>

<p class="text-muted mt-3">
Higher ATS score means your resume is better optimized for recruiters.
</p>

</div>

<!-- USER QUESTION CARD -->

<% if(userQuery != null && !userQuery.trim().isEmpty()){ %>

<div class="card shadow p-4 rounded-4 mb-4">

<h5 class="fw-bold">
<i class="bi bi-question-circle text-primary"></i>
Your Question
</h5>

<p class="mt-2"><%= userQuery %></p>

</div>

<% } %>

<!-- AI ANALYSIS -->

<% if(ai != null){ %>

<div class="card shadow card-hover p-4 rounded-4 mb-4">

<h5 class="fw-bold mb-3">
<i class="bi bi-robot text-success"></i>
AI Resume Analysis
</h5>

<div class="alert alert-info">
<i class="bi bi-info-circle"></i>
AI generated feedback based on your resume.
</div>

<div class="bg-light p-4 rounded">

<div style="white-space:pre-wrap;font-size:15px;line-height:1.6;">
<%= ai.replace("\n","<br>") %>
</div>

</div>

</div>

<% } else { %>

<div class="alert alert-warning text-center mb-4">
No AI analysis available. Please upload and analyze your resume first.
</div>

<% } %>

<!-- ACTION BUTTONS SECTION -->

<div class="card shadow p-4 rounded-4 text-center">

<h5 class="mb-4">
<i class="bi bi-lightning-charge text-success"></i>
What would you like to do next?
</h5>

<div class="d-flex justify-content-center gap-3 flex-wrap">

<!-- Upload Again Button -->

<form action="UploadResume.jsp">
<button type="submit" class="btn btn-success px-4 py-3 rounded-pill">
<i class="bi bi-upload"></i> Upload New Resume
</button>
</form>

<!-- Generate Jobs Button -->

<form action="<%=request.getContextPath()%>/GenerateJobs" method="post">
<button type="submit" class="btn btn-primary px-4 py-3 rounded-pill">
<i class="bi bi-briefcase"></i> Generate Jobs For My Resume
</button>
</form>

</div>

</div>

</div>
</div>
</div>

<%@ include file="layoutFooter.jsp" %>
