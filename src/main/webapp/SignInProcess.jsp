<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%@ page import="util.DBConnection" %>

<%
String email = request.getParameter("email");
String password = request.getParameter("password");
String loginRole = request.getParameter("role");


if("omgorle5@gmail.com".equals(email) && "om".equals(password)){
    
    session.setAttribute("userName", "Admin");
    session.setAttribute("userRole", "admin");

    response.sendRedirect("AdminDashboard/AdminDashboard.jsp?login=success");
    return;
}

PreparedStatement ps = null;	
ResultSet rs = null;

try(Connection con = DBConnection.getConnection())
{
    ps = con.prepareStatement(
        "SELECT id, name, role, status FROM users WHERE email=? AND password=?"
    );

    ps.setString(1, email);
    ps.setString(2, password);

    rs = ps.executeQuery();

    if(rs.next()){

        int userId = rs.getInt("id");
        String userName = rs.getString("name");
        String dbRole = rs.getString("role");
        String status = rs.getString("status");

        if(!dbRole.equalsIgnoreCase(loginRole)){
%>
            <script>
                alert("You are not registered as <%= loginRole %>!");
                window.location="SignIn.jsp";
            </script>
<%
            return;
        }

        if("user".equalsIgnoreCase(dbRole)){

            session.setAttribute("userId", userId);
            session.setAttribute("userName", userName);
            session.setAttribute("userRole", "user");
            /* session timeout */
           session.setMaxInactiveInterval(600);
            response.sendRedirect("UserDashboard/UserDashboard.jsp?login=success");
        }

        else if("mentor".equalsIgnoreCase(dbRole)){

            if("approved".equalsIgnoreCase(status)){

                session.setAttribute("userId", userId);
                session.setAttribute("userName", userName);
                session.setAttribute("userRole", "mentor");
                /* session timeout */
               session.setMaxInactiveInterval(600);
                PreparedStatement ps2 = con.prepareStatement(
                    "SELECT id FROM mentor_profile WHERE user_id=?"
                );

                ps2.setInt(1, userId);
                ResultSet rs2 = ps2.executeQuery();

                if(rs2.next()){
                    int mentorProfileId = rs2.getInt("id");
                    session.setAttribute("mentorProfileId", mentorProfileId);
                }

                response.sendRedirect("MentorDashboard/MentorDashboard.jsp?login=success");
            }
            else{
%>
                <script>
                    alert("Your status is <%= status %>. Please wait for admin approval.");
                    window.location="SignIn.jsp";
                </script>
<%
            }
        }

    } 

    else{
%>
        <script>
            alert("Invalid Email or Password!");
            window.location="SignIn.jsp";
        </script>
<%
    }

} 

catch(Exception e){
    out.println(e);
}
%>