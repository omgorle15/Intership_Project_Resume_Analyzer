<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>

<%
Integer userId = (Integer) session.getAttribute("userId");

Connection con = DBConnection.getConnection();

PreparedStatement ps = con.prepareStatement(
"SELECT id,name,created_at FROM resumes WHERE user_id=?");

ps.setInt(1,userId);

ResultSet rs = ps.executeQuery();
%>

<h3>My Resumes</h3>

<table class="table table-bordered">

<tr>
<th>Name</th>
<th>Created</th>
<th>Action</th>
</tr>

<%
while(rs.next()){
%>

<tr>

<td><%= rs.getString("name") %></td>

<td><%= rs.getString("created_at") %></td>

<td>

<a href="../AnalyzeCreatedResume?resumeId=<%=rs.getInt("id")%>"
class="btn btn-warning">
Analyze
</a>

</td>

</tr>

<%
}
%>

</table>