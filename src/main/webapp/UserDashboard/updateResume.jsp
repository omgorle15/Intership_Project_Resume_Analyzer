<%@page import="util.DBConnection"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
if(session.getAttribute("userName") == null){
    response.sendRedirect("SignIn.jsp");
    return;
}

int id = Integer.parseInt(request.getParameter("id"));

String name="", email="", phone="", address="", objective="", skills="", projects="", certifications="";

try(Connection con = DBConnection.getConnection()){
	
	PreparedStatement ps = con.prepareStatement(
	"SELECT * FROM resumes WHERE id=?"
	);
	ps.setInt(1,id);
	
	ResultSet rs = ps.executeQuery();
	
	if(rs.next()){
	    name = rs.getString("name");
	    email = rs.getString("user_email");
	    phone = rs.getString("phone");
	    address = rs.getString("address");
	    objective = rs.getString("objective");
	    skills = rs.getString("skills");
	    projects = rs.getString("projects");
	    certifications = rs.getString("certifications");
	}

con.close();
}catch(Exception e){
out.println(e);
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Update Resume</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="bg-light">

<div class="container mt-5">
<div class="card shadow p-4">
<h3 class="text-center">Update Resume</h3>

<form action="updateResumeProcess.jsp" method="post">
<input type="hidden" name="id" value="<%=id%>">

<input type="text" name="name" value="<%=name%>" class="form-control mb-2">
<input type="email" name="email" value="<%=email%>" class="form-control mb-2">
<input type="text" name="phone" value="<%=phone%>" class="form-control mb-2">
<input type="text" name="address" value="<%=address%>" class="form-control mb-2">
<textarea name="objective" class="form-control mb-2"><%=objective%></textarea>
<input type="text" name="skills" value="<%=skills%>" class="form-control mb-2">
<textarea name="projects" class="form-control mb-2"><%=projects%></textarea>
<textarea name="certifications" class="form-control mb-2"><%=certifications%></textarea>

<div class="text-center">
<button class="btn btn-warning">Update</button>
</div>
</form>
</div>
</div>

</body>
</html>