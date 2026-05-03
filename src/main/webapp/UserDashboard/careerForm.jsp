<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ include file="layout.jsp" %>

<div class="container-fluid">

<div class="row">

<div class="col-md-10 p-5">

<div class="card shadow card-hover p-4 rounded-4">

<h4 class="fw-bold mb-4">
<i class="bi bi-lightbulb text-success"></i>
Career Guidance System
</h4>

<form action="../CareerServlet" method="post">

<div class="row">

<div class="col-md-6 mb-3">
<label class="form-label">Education</label>
<input type="text"
name="education"
class="form-control"
placeholder="Enter your education">
</div>

<div class="col-md-6 mb-3">
<label class="form-label">Skills</label>
<input type="text"
name="skills"
class="form-control"
placeholder="Enter your skills">
</div>

<div class="col-md-6 mb-3">
<label class="form-label">Interests</label>
<input type="text"
name="interests"
class="form-control"
placeholder="Enter your interests">
</div>

<div class="col-md-6 mb-3">
<label class="form-label">Experience</label>
<input type="text"
name="experience"
class="form-control"
placeholder="Enter your experience">
</div>

</div>

<div class="mt-3">

<button type="submit" class="btn btn-success px-4">
<i class="bi bi-search"></i> Get Career Guidance
</button>

</div>

</form>

</div>

</div>

</div>

</div>

<%@ include file="layoutFooter.jsp" %>