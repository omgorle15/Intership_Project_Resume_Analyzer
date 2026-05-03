<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page session="true" %>

<%
Integer userId = (Integer) session.getAttribute("userId");

if(userId == null){
    response.sendRedirect("../SignIn.jsp");
    return;
}

request.setCharacterEncoding("UTF-8");

Connection con = null;

try {

    con = DBConnection.getConnection();

    /* ==============================
       1️⃣ Get Form Data
    ============================== */

    String name = request.getParameter("name");
    String bio = request.getParameter("bio");
    String[] daysArray = request.getParameterValues("days");
    String startTime = request.getParameter("start_time");
    String endTime = request.getParameter("end_time");
    String slotDurationStr = request.getParameter("slot_duration");

    /* ==============================
       2️⃣ VALIDATION
    ============================== */

    if(name == null || name.trim().isEmpty()){
        response.sendRedirect("updateMentor.jsp?error=Name cannot be empty");
        return;
    }

    String availableDays = "";
    if(daysArray != null){
        availableDays = String.join(",", daysArray);
    }

    int slotDuration = 30; // default
    if(slotDurationStr != null && !slotDurationStr.isEmpty()){
        slotDuration = Integer.parseInt(slotDurationStr);
    }

    /* ==============================
       3️⃣ Update ONLY Name (NOT Email)
    ============================== */

    PreparedStatement psUser = con.prepareStatement(
        "UPDATE users SET name=? WHERE id=?"
    );

    psUser.setString(1, name.trim());
    psUser.setInt(2, userId);
    psUser.executeUpdate();
    psUser.close();

    /* ==============================
       4️⃣ Check if mentor_profile exists
    ============================== */

    PreparedStatement checkPs = con.prepareStatement(
        "SELECT id FROM mentor_profile WHERE user_id=?"
    );
    checkPs.setInt(1, userId);
    ResultSet rs = checkPs.executeQuery();

    if(rs.next()){

        /* ==============================
           UPDATE mentor_profile
        ============================== */

        PreparedStatement psUpdate = con.prepareStatement(
            "UPDATE mentor_profile SET bio=?, available_days=?, start_time=?, end_time=?, slot_duration=? WHERE user_id=?"
        );

        psUpdate.setString(1, bio);
        psUpdate.setString(2, availableDays);
        psUpdate.setString(3, startTime);
        psUpdate.setString(4, endTime);
        psUpdate.setInt(5, slotDuration);
        psUpdate.setInt(6, userId);

        psUpdate.executeUpdate();
        psUpdate.close();

    } else {

        /* ==============================
           INSERT mentor_profile
        ============================== */

        PreparedStatement psInsert = con.prepareStatement(
            "INSERT INTO mentor_profile (user_id, bio, available_days, start_time, end_time, slot_duration) VALUES (?, ?, ?, ?, ?, ?)"
        );

        psInsert.setInt(1, userId);
        psInsert.setString(2, bio);
        psInsert.setString(3, availableDays);
        psInsert.setString(4, startTime);
        psInsert.setString(5, endTime);
        psInsert.setInt(6, slotDuration);

        psInsert.executeUpdate();
        psInsert.close();
    }

    rs.close();
    checkPs.close();

    response.sendRedirect("MentorDashboard.jsp?success=Profile Updated Successfully");

} catch(Exception e) {

    e.printStackTrace();
    out.println("<h3 style='color:red'>Error: " + e.getMessage() + "</h3>");

} finally {

    if(con != null) con.close();
}
%>