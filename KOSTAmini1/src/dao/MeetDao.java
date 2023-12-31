package dao;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map.Entry;

import common.CRUD;
import common.DBConnect;
import common.Manager;
import vo.Meet;

public class MeetDao<T extends Meet> extends CRUD<Meet> {
    public MeetDao(Manager manager) {
        super(manager);
        db = DBConnect.getInstance();
    }

    @Override
    public void insert(Meet meet) throws SQLException {
        conn = db.conn();

        sql = "INSERT INTO MEETS(NO, RECURIT, ENTER, TITLE, CONTENT, DEADLINE, LOCATIONS_NO, MEMBERS_NO) " + 
                "VALUES (MEETS_NO_SEQUENCE.NEXTVAL, ?, ?, ?, ?, SYSDATE, ?, ?)";
        
        ps = conn.prepareStatement(sql);

        ps.setInt(1, meet.getRecurit());
        ps.setInt(2, 1);
        ps.setString(3, meet.getTitle());
        ps.setString(4, meet.getContent());
        ps.setInt(5, meet.getLocationNo());
        ps.setInt(6, meet.getMemberNo());

        ps.executeUpdate();
    }

    @Override
    public ArrayList<Meet> select(HashMap<String, String> args) throws SQLException {
        ArrayList<Meet> list = new ArrayList<>();

        conn = db.conn();
        
        sql = "SELECT * FROM MEETS";
        if(args.isEmpty()) {
            ps = conn.prepareStatement(sql);

            rs = ps.executeQuery();

            while(rs.next()) {
                list.add(new Meet(rs.getInt(1), rs.getInt(2), rs.getInt(3),
                        rs.getString(4), rs.getString(5), rs.getDate(6),
                        rs.getDate(7), rs.getDate(8), rs.getInt(9), rs.getInt(10)));
            }
        } else {
            sql += " WHERE ";
            int cnt = args.size() -1;
            for(Entry<String, String> entry : args.entrySet()) {
                if (cnt > 0) {
                    sql += entry.getKey() + " = \'" + entry.getValue() + "\' AND ";
                } else {
                    sql += entry.getKey() + " = \'" + entry.getValue() + "\' ";
                    
                }
                cnt--;
		    }

            ps = conn.prepareStatement(sql);

            rs = ps.executeQuery();

            while(rs.next()) {
                list.add(new Meet(rs.getInt(1), rs.getInt(2), rs.getInt(3),
                        rs.getString(4), rs.getString(5), rs.getDate(6),
                        rs.getDate(7), rs.getDate(8), rs.getInt(9), rs.getInt(10)));
            }
        }

        return list;
    }

    @Override
    public void update(Meet meet) throws SQLException {
        conn = db.conn();

        sql = "UPDATE MEETS SET" +
                " TITLE = \'" + meet.getTitle() + "\'," + 
                " CONTENT = \'" + meet.getContent() + "\'," +
                " RECURIT = \'" + meet.getRecurit() + "\'," +
                " E_DATE = SYSDATE" + 
                " WHERE NO = \'" + meet.getNo() + "\'";

        System.out.println(sql);

        ps = conn.prepareStatement(sql);

        ps.executeUpdate();
    }

    public void join(int no, int memberNo) throws SQLException {
        conn = db.conn();

        sql = "UPDATE MEETS SET ENTER = ? WHERE MEMBERS_NO = ? AND NO = ?";

        ps = conn.prepareStatement(sql);

        ps.setInt(1, memberNo);
        ps.setInt(2, no);

        ps.executeUpdate();
    }
    
    @Override
    public void delete(int no) throws SQLException {
        conn = db.conn();

        sql = "";

        ps = conn.prepareStatement(sql);
    }

    @Override
    public void close() throws Exception {
        if(rs != null)
            rs.close();
        ps.close();
        conn.close();
    }
}
