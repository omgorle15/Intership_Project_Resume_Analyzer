<%@page import="util.DBConnection"%>
<%@ include file="layout.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"%>

<%
request.setCharacterEncoding("UTF-8");

String idParam = request.getParameter("id");

String name1="", email="", phone="", address="", linkedin="";
String objective="", skills="", certifications="", projects="";
String experienceType="", company="", jobRole="", duration="", jobDescription="";
String degreeStr="", collegeStr="", yearStr="", cgpaStr="";

String[] degrees=null, colleges=null, years=null, cgpas=null;

if(idParam != null){

    int id = Integer.parseInt(idParam);

    try(Connection con = DBConnection.getConnection()){

        PreparedStatement ps = con.prepareStatement(
            "SELECT * FROM resumes WHERE id=?"
        );
        ps.setInt(1,id);
        ResultSet rs = ps.executeQuery();

        if(rs.next()){
            name1 = rs.getString("name");
            email = rs.getString("user_email");
            phone = rs.getString("phone");
            address = rs.getString("address");
            linkedin = rs.getString("linkedin");
            objective = rs.getString("objective");
            skills = rs.getString("skills");
            certifications = rs.getString("certifications");
            projects = rs.getString("projects");

            experienceType = rs.getString("experience_type");
            company = rs.getString("company");
            jobRole = rs.getString("job_role");
            duration = rs.getString("duration");
            jobDescription = rs.getString("job_description");

            degreeStr = rs.getString("degree");
            collegeStr = rs.getString("college");
            yearStr = rs.getString("year");
            cgpaStr = rs.getString("cgpa");

            if(degreeStr != null) degrees = degreeStr.split(",");
            if(collegeStr != null) colleges = collegeStr.split(",");
            if(yearStr != null) years = yearStr.split(",");
            if(cgpaStr != null) cgpas = cgpaStr.split(",");
        }

        con.close();

    }catch(Exception e){
        out.println(e);
    }

}else{
    name1 = request.getParameter("name");
    email = request.getParameter("email");
    phone = request.getParameter("phone");
    address = request.getParameter("address");
    linkedin = request.getParameter("linkedin");
    objective = request.getParameter("objective");
    skills = request.getParameter("skills");
    certifications = request.getParameter("certifications");
    projects = request.getParameter("projects");
}
%>

<style>
body{
    background:#e6e6e6;
    font-family:'Segoe UI', sans-serif;
}

.download-btn{
    background:#6a1b9a;
    color:white;
    border:none;
    padding:12px 30px;
    border-radius:30px;
    font-weight:600;
    cursor:pointer;
    box-shadow:0 5px 15px rgba(0,0,0,0.2);
}

.download-btn:hover{
    background:#8e24aa;
}

.resume-container{
    width:210mm;
    min-height:297mm;
    margin:30px auto;
    background:white;
    display:flex;
    box-shadow:0 15px 40px rgba(0,0,0,0.15);
}

.left{
    width:30%;
    background:linear-gradient(180deg,#6a1b9a,#8e24aa);
    color:white;
    padding:35px;
}

.left h2{ margin-bottom:20px; }
.left p{ font-size:14px; margin:6px 0; }

.left h4{
    margin-top:30px;
    border-bottom:1px solid rgba(255,255,255,0.4);
    padding-bottom:5px;
}

.left ul{ margin-top:10px; padding-left:18px; }
.left ul li{ margin-bottom:8px; font-size:14px; }

.right{ width:70%; padding:40px; }

.section{ margin-bottom:30px; }

.section h3{
    color:#6a1b9a;
    border-bottom:2px solid #ddd;
    padding-bottom:6px;
    margin-bottom:15px;
}

.section p{ font-size:14px; line-height:1.6; }

.section ul{ padding-left:18px; }
.section ul li{ margin-bottom:8px; font-size:14px; }

/* PRINT FIX */

@page{
    size:A4;
    margin:0;
}

@media print{

    body *{
        visibility:hidden;
    }

    #resumeArea, #resumeArea *{
        visibility:visible;
    }

    #resumeArea{
        position:absolute;
        left:0;
        top:0;
        width:100%;
    }

    .download-btn{
        display:none;
    }

}
</style>

<div style="text-align:center; margin-top:20px;">
    <button class="download-btn" onclick="downloadResume()">Download Resume</button>
</div>

<!-- RESUME AREA -->
<div id="resumeArea" class="resume-container">

<div class="left">

<h2><%= name1 %></h2>

<p><strong>Email:</strong><br><%= email %></p>
<p><strong>Phone:</strong><br><%= phone %></p>
<p><strong>Address:</strong><br><%= address %></p>
<p><strong>LinkedIn:</strong><br><%= linkedin %></p>

<h4>Skills</h4>
<ul>
<%
if(skills != null){
String[] skillArray = skills.split(",");
for(String s : skillArray){
%>
<li><%= s.trim() %></li>
<% }} %>
</ul>

<h4>Certifications</h4>
<ul>
<%
if(certifications != null){
String[] certArray = certifications.split(",");
for(String c : certArray){
%>
<li><%= c.trim() %></li>
<% }} %>
</ul>

</div>

<div class="right">

<div class="section">
<h3>Summary</h3>
<p><%= objective %></p>
</div>

<div class="section">
<h3>Experience</h3>

<% if("Experienced".equals(experienceType)){ %>
<strong><%= jobRole %></strong><br>
<em><%= company %></em><br>
<small><%= duration %></small>
<ul>
<li><%= jobDescription %></li>
</ul>
<% } else { %>
<p>Fresher – Seeking an opportunity to begin professional career.</p>
<% } %>

</div>

<div class="section">
<h3>Education</h3>

<%
if(degrees != null){
for(int i=0; i<degrees.length; i++){
%>
<strong><%= degrees[i] %></strong><br>
<%= colleges[i] %><br>
<small><%= years[i] %> | CGPA: <%= cgpas[i] %></small>
<br><br>
<%
}}
%>

</div>

<div class="section">
<h3>Projects</h3>
<p><%= projects %></p>
</div>

</div>
</div>

<script>
function downloadResume(){
    window.print();
}
</script>

<%@ include file="layoutFooter.jsp" %>