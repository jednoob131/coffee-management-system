package Dao;

import java.sql.Date;
import java.util.List;
import entity.Bill;

public interface BillDao {

    void insert(Bill bill);

    void update(Bill bill);

    void delete(int billId);

    Bill findById(int billId);

    Bill findByOrderCode(String orderCode);

    List<Bill> findAll();

    List<Bill> findByUsername(String username);

    List<Bill> findPaidByUsername(String username);

    int insertAndGetId(Bill bill);

    List<Bill> findByDateAndUsername(Date from, Date to, String username);

    List<Bill> findPaidByDateAndUsername(Date from, Date to, String username);
}