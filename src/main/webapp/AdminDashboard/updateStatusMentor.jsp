<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>

<%
String id = request.getParameter("id");
String status = request.getParameter("status");

if(id != null && status != null){

    try(Connection con = DBConnection.getConnection()){

        String sql = "UPDATE users SET status=? WHERE id=?";
        PreparedStatement ps = con.prepareStatement(sql);

        ps.setString(1, status);
        ps.setInt(2, Integer.parseInt(id));

        int rows = ps.executeUpdate();

        if(rows > 0){
            response.sendRedirect("ViewMentor.jsp");
        }else{
            out.println("Update failed!");
        }

    }catch(Exception e){
        out.println("Error: " + e.getMessage());
    }

}else{
    out.println("Invalid Request!");
}
%>