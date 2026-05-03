<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page session="true" %>
<%@ include file="layout.jsp" %>

<%
if(session.getAttribute("userName") == null){
    response.sendRedirect("SignIn.jsp");
}
%>
<%
String msg = (String) session.getAttribute("successMessage");

if(msg != null){
%>

<div class="alert alert-success text-center">
    <%= msg %>
</div>

<%
session.removeAttribute("successMessage");
}
%>
<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<style>

body{
background:#f4f6f9;
}

.upload-card{
background:white;
border-radius:20px;
padding:40px;
box-shadow:0 20px 40px rgba(0,0,0,0.1);
}

.upload-area{
border:2px dashed #198754;
border-radius:15px;
padding:40px;
text-align:center;
cursor:pointer;
transition:0.3s;
}

.upload-area:hover{
background:#f8f9fa;
transform:scale(1.02);
}

.btn-upload{
background:#198754;
color:white;
border-radius:25px;
padding:10px 30px;
}

.btn-upload:hover{
background:#157347;
}

</style>

<script>

function displayFileName(input){
const file=input.files[0];

if(file){
document.getElementById("fileName").innerHTML="Selected File: "+file.name;
}

}

</script>

<div class="container-fluid">
<div class="row">

<div class="col-md-10 p-5">

<div class="upload-card text-center">

<h3 class="mb-4">📄 Upload Your Resume</h3>

<form action="<%=request.getContextPath()%>/UploadResume"
      method="post"
      enctype="multipart/form-data">




<label for="resumeFile" class="upload-area w-100">

<h5>Click to Upload Resume</h5>
<p>PDF, DOC, DOCX (Max 5MB)</p>

<input type="file"
name="resumeFile"
id="resumeFile"
class="form-control d-none"
accept=".pdf,.doc,.docx"
onchange="displayFileName(this)"
required>

</label>
</br>
</br>
<!-- NEW QUERY BOX -->

<textarea 
name="userQuery"
class="form-control mb-3"
rows="4"
placeholder="Ask anything about your resume (Example: Give ATS score, suggest improvements, recommend jobs)">
</textarea>

<div id="fileName" class="mt-3 text-success"></div>

<div class="mt-4">
<button type="submit" class="btn btn-upload">
Analyze Resume
</button>
</div>

</form>

</div>

</div>

</div>
</div>

<%@ include file="layoutFooter.jsp" %>