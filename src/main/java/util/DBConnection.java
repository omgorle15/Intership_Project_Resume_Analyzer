package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String URL = "jdbc:mysql://root:OGsYVwGoeyaSEbYJxgdKcbdBsJGbqiJh@switchyard.proxy.rlwy.net:47810/railway";
    private static final String USER = "root";
    private static final String PASSWORD = "OGsYVwGoeyaSEbYJxgdKcbdBsJGbqiJh";
//    
	
//	 private static final String URL = "jdbc:mysql://localhost:3306/jobanalyzer";
//	    private static final String USER = "root";
//	    private static final String PASSWORD = "Omgorle@123";
	    
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
    
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
    
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}