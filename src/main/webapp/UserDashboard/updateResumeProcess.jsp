<%@page import="util.DBConnection"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
if(session.getAttribute("userName")==null){
response.sendRedirect("SignIn.jsp");
return;
}

int id=Integer.parseInt(request.getParameter("id"));

String name=request.getParameter("name");
String email=request.getParameter("email");
String phone=request.getParameter("phone");
String address=request.getParameter("address");
String objective=request.getParameter("objective");
String skills=request.getParameter("skills");
String projects=request.getParameter("projects");
String certifications=request.getParameter("certifications");

try(Connection con = DBConnection.getConnection()){

PreparedStatement ps=con.prepareStatement(
"UPDATE resumes SET name=?,user_email=?,phone=?,address=?,objective=?,skills=?,projects=?,certifications=? WHERE id=?"
);

ps.setString(1,name);
ps.setString(2,email);
ps.setString(3,phone);
ps.setString(4,address);
ps.setString(5,objective);
ps.setString(6,skills);
ps.setString(7,projects);
ps.setString(8,certifications);
ps.setInt(9,id);

ps.executeUpdate();

response.sendRedirect("viewResume.jsp");

}catch(Exception e){
out.println(e);
}
%>