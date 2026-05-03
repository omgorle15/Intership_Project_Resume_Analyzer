<%@page import="util.DBConnection"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%@ include file="layout.jsp" %>
<%
if(session.getAttribute("userName") == null){
    response.sendRedirect("SignIn.jsp");
    return;
}

Integer uidObj = (Integer) session.getAttribute("userId");
if(uidObj == null){
    response.sendRedirect("SignIn.jsp");
    return;
}

int userid = uidObj;
%>

<!DOCTYPE html>
<html>
<head>
<title>View Resumes</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="bg-light">

<div class="container mt-5">
<div class="card shadow">
<div class="card-header bg-primary text-white text-center">
<h4>My Resumes</h4>
</div>

<div class="card-body">
<table class="table table-bordered">
<thead class="table-dark">
<tr>
<th>View</th>
<th>Update</th>
<th>ID</th>
<th>Name</th>
</tr>
</thead>
<tbody>

<%
try(Connection con = DBConnection.getConnection()){

PreparedStatement ps = con.prepareStatement(
"SELECT * FROM resumes WHERE user_id=?"
);
ps.setInt(1, userid);

ResultSet rs = ps.executeQuery();

while(rs.next()){
%>

<tr>
<td>
<a href="resumeTemplate.jsp?id=<%=rs.getInt("id")%>" class="btn btn-success btn-sm">View</a>
</td>
<td>
<a href="updateResume.jsp?id=<%=rs.getInt("id")%>" class="btn btn-warning btn-sm">Update</a>
</td>
<td><%=rs.getInt("id")%></td>
<td><%=rs.getString("name")%></td>
</tr>

<%
}
con.close();
}catch(Exception e){
out.println(e);
}
%>

</tbody>
</table>
</div>
</div>
</div>
<%@ include file="layoutFooter.jsp" %>
</body>
</html>