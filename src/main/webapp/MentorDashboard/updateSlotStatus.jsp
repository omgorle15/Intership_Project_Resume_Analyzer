<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>

<%
String id = request.getParameter("id");
String status = request.getParameter("status");

try{

Connection con = DBConnection.getConnection();

PreparedStatement ps = con.prepareStatement(
"UPDATE mentor_timeslot SET status=? WHERE slot_id=?");

ps.setString(1, status);
ps.setInt(2, Integer.parseInt(id));

ps.executeUpdate();

response.sendRedirect("bookTimeSlot.jsp");

}catch(Exception e){
e.printStackTrace();
}
%>